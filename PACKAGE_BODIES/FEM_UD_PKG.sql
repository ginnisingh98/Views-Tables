--------------------------------------------------------
--  DDL for Package Body FEM_UD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_UD_PKG" AS
-- $Header: fem_ud_eng.plb 120.13.12010000.3 2009/09/01 01:43:41 ghall ship $ */
-- ***********************
-- Package constants
-- ***********************
pc_pkg_name CONSTANT VARCHAR2(30) := 'fem_ud_pkg';

G_FEM                  constant varchar2(3)  := 'FEM';
G_YES                  CONSTANT VARCHAR2(1) := 'Y';
G_NO                   CONSTANT VARCHAR2(1) := 'N';

pc_ret_sts_success      CONSTANT VARCHAR2(1):= fnd_api.g_ret_sts_success;
pc_ret_sts_error        CONSTANT VARCHAR2(1):= fnd_api.g_ret_sts_error;
pc_ret_sts_unexp_error  CONSTANT VARCHAR2(1):= fnd_api.g_ret_sts_unexp_error;

pv_resp_app_id                   NUMBER := FND_GLOBAL.RESP_APPL_ID;
pv_login_id                      NUMBER := FND_GLOBAL.Login_Id;
pv_apps_user_id                  NUMBER := FND_GLOBAL.USER_ID;
pv_request_id                    NUMBER := fnd_global.conc_request_id;
pv_program_id                    NUMBER := FND_GLOBAL.Conc_Program_Id;
pv_program_app_id                NUMBER := FND_GLOBAL.Prog_Appl_ID;
pv_concurrent_status             BOOLEAN;

pc_log_level_statement  CONSTANT  NUMBER  := fnd_log.level_statement;
pc_log_level_procedure  CONSTANT  NUMBER  := fnd_log.level_procedure;
pc_log_level_event      CONSTANT  NUMBER  := fnd_log.level_event;
pc_log_level_exception  CONSTANT  NUMBER  := fnd_log.level_exception;
pc_log_level_error      CONSTANT  NUMBER  := fnd_log.level_error;
pc_log_level_unexpected CONSTANT  NUMBER  := fnd_log.level_unexpected;

-- Bug 4309949.  Hardcode folder to the "Default" folder
pc_undo_folder_id CONSTANT  NUMBER  := 1100;

-- ***********************
-- Package variables
-- ***********************

-- ***********************
-- Notification variables
-- ***********************
pv_undo_object_name            VARCHAR2(150);
pv_undo_flag                   VARCHAR2(1);
pv_parameter_list              wf_parameter_list_t := wf_parameter_list_t();

-- ***********************
-- Exceptions
-- ***********************
e_cannot_create_object         EXCEPTION;
e_cannot_delete_object         EXCEPTION;
e_undo_list_exec_not_success   EXCEPTION;
e_edit_lock_exists             EXCEPTION;
e_cannot_generate_dependents   EXCEPTION;
e_invalid_p_commit             EXCEPTION;

e_not_found_table_or_view      EXCEPTION;
e_not_found_index              EXCEPTION;
e_not_found_package            EXCEPTION;
e_not_found_materialized_view  EXCEPTION;
e_not_found_database_link      EXCEPTION;
e_not_found_sequence           EXCEPTION;
e_not_found_rollback_segment   EXCEPTION;
e_not_found_synonym            EXCEPTION;
e_not_found_dblink_in_dml      EXCEPTION;
e_null_undo_list_name          EXCEPTION;
e_invalid_dependencies_flag    EXCEPTION;
e_invalid_dependency_errs_flag EXCEPTION;
e_mp_error                     EXCEPTION;

e_invalid_undo_list            EXCEPTION;
e_pl_reg_request_failed        EXCEPTION;
e_pl_reg_obj_exec_failed       EXCEPTION;
e_pl_reg_obj_def_failed        EXCEPTION;
e_could_not_process_undo_list  EXCEPTION;
e_object_execution_not_found   EXCEPTION;
e_invalid_folder               EXCEPTION;
e_cannot_create_undo_list      EXCEPTION;
e_cannot_add_candidate         EXCEPTION;
e_list_has_no_candidates       EXCEPTION;
e_cannot_undo_obj_exec_err     EXCEPTION;
e_request_not_found            EXCEPTION;
e_multiple_requests_found      EXCEPTION;
e_dependencies_found           EXCEPTION;
e_request_is_running           EXCEPTION;
e_objexec_is_running           EXCEPTION;
e_engine_specific_proc_err     EXCEPTION;
e_cannot_submit_request        EXCEPTION;
e_cannot_gen_cand_upd_dep      EXCEPTION;

e_cannot_read_object           EXCEPTION;
e_invalid_preview_flag         EXCEPTION;
e_invalid_undolist_objdefid    EXCEPTION;
e_invalid_session_id           EXCEPTION;
e_invalid_dependency_type      EXCEPTION;
e_cannot_delete_execution_log  EXCEPTION;
e_cannot_validate_dependents   EXCEPTION;
e_cannot_validate_candidates   EXCEPTION;

e_undo_action_not_supported    EXCEPTION;
e_unexp_error                  EXCEPTION;

PRAGMA EXCEPTION_INIT(e_not_found_table_or_view,-942);
PRAGMA EXCEPTION_INIT(e_not_found_index,-1418);
PRAGMA EXCEPTION_INIT(e_not_found_package,-4043);
PRAGMA EXCEPTION_INIT(e_not_found_materialized_view,-12003);
PRAGMA EXCEPTION_INIT(e_not_found_database_link,-2024);
PRAGMA EXCEPTION_INIT(e_not_found_sequence,-2289);
PRAGMA EXCEPTION_INIT(e_not_found_rollback_segment,-1534);
PRAGMA EXCEPTION_INIT(e_not_found_synonym,-1434);
PRAGMA EXCEPTION_INIT(e_not_found_dblink_in_dml,-2019);

-- ***************************************************************************
--  Private procedure signatures:
-- ***************************************************************************
PROCEDURE calc_accttbl_upd_dependents   (
   x_msg_count                    OUT NOCOPY NUMBER,
   x_msg_data                     OUT NOCOPY VARCHAR2,
   x_return_status                OUT NOCOPY VARCHAR2,
   x_upd_dep_calc_id              OUT NOCOPY NUMBER,
   p_request_id                   IN  NUMBER,
   p_object_id                    IN  NUMBER);

PROCEDURE delete_execution_log (
   x_return_status                OUT NOCOPY VARCHAR2,
   x_msg_count                    OUT NOCOPY NUMBER,
   x_msg_data                     OUT NOCOPY VARCHAR2,
   p_api_version                  IN  NUMBER,
   p_commit                       IN  VARCHAR2,
   p_request_id                   IN  NUMBER,
   p_object_id                    IN  NUMBER);

PROCEDURE raise_undo_business_event (p_event_name IN VARCHAR,
                                     p_request_id IN NUMBER,
                                     p_object_id IN NUMBER,
                                     p_status IN VARCHAR DEFAULT NULL);

PROCEDURE Prepare_PL_Register_Record (
   x_pl_register_record           IN OUT nocopy pl_register_record,
   x_return_status                OUT NOCOPY VARCHAR2
);

PROCEDURE Get_Dim_Attribute_Value (
  p_dimension_varchar_label       in varchar2
  ,p_attribute_varchar_label      in varchar2
  ,p_member_id                    in number
  ,x_dim_attribute_varchar_member out nocopy varchar2
  ,x_date_assign_value            out nocopy date,
  x_return_status                OUT NOCOPY VARCHAR2
);

PROCEDURE Get_Dim_Attribute (
  p_dimension_varchar_label       in varchar2
  ,p_attribute_varchar_label      in varchar2
  ,x_dimension_rec                out nocopy dim_attr_record
  ,x_attribute_id                 out nocopy number
  ,x_attr_version_id              out nocopy number
  ,x_return_status                OUT NOCOPY VARCHAR2
);

PROCEDURE Get_Object_Definition (
  p_object_id                     in number
  ,p_effective_date               in date
  ,x_obj_def_id                   out nocopy number
);

PROCEDURE write_debug (
   p_msg_data        IN   VARCHAR2,
   p_user_msg        IN   VARCHAR2,
   p_module          IN   VARCHAR2);


-- ***************************************************************************
--  Private procedure bodies:
-- ***************************************************************************

-- ============================================================================
-- PRIVATE
-- Procedure for getting messages off the stack and posting to the debug or
-- concurrent log.
-- The procedure always posts messages to the debug log, and only posts to the
-- concurrent log if p_user_msg = 'Y'.
-- p_user_msg - Valid values 'Y','N'.  Indicates whether or not to post message
--              to concurrent log.
-- p_module   - Module from which get_put_messages is called.
-- ============================================================================
PROCEDURE Get_Put_Messages (
                                    p_msg_count       IN   NUMBER,
                                    p_msg_data        IN   VARCHAR2,
                                    p_user_msg        IN   VARCHAR2,
                                    p_module          IN   VARCHAR2)       AS

v_msg_count        NUMBER;
v_msg_data         VARCHAR2(32000);
v_msg_out          NUMBER;
v_message          VARCHAR2(32000);

v_block  CONSTANT  VARCHAR2(300) :=
   p_module||'.get_put_messages';

BEGIN

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => pc_log_level_procedure,
  p_module => v_block,
  p_msg_text => 'MSG_COUNT: '||p_msg_count);

v_msg_data := p_msg_data;

IF (p_msg_count = 1)
THEN
   FND_MESSAGE.Set_Encoded(v_msg_data);
   v_message := FND_MESSAGE.Get;

   IF p_user_msg = 'Y' THEN
      FEM_ENGINES_PKG.User_Message(
        p_msg_text => v_message);
   END IF;

   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => pc_log_level_event,
     p_module => v_block,
     p_msg_text => v_message);

ELSIF (p_msg_count > 1)
THEN
   FOR i IN 1..p_msg_count
   LOOP
      FND_MSG_PUB.Get(
      p_msg_index => i,
      p_encoded => FND_API.G_FALSE,
      p_data => v_message,
      p_msg_index_out => v_msg_out);

      IF p_user_msg = 'Y' THEN
         FEM_ENGINES_PKG.User_Message(
           p_msg_text => v_message);
      END IF;

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => pc_log_level_event,
        p_module => v_block,
        p_msg_text => v_message);


   END LOOP;
END IF;

   FND_MSG_PUB.Initialize;

END Get_Put_Messages;
-- ******************************************************************************

PROCEDURE raise_undo_business_event (p_event_name IN VARCHAR,
                                     p_request_id IN NUMBER,
                                     p_object_id IN NUMBER,
                                     p_status IN VARCHAR DEFAULT NULL) IS
-- ============================================================================
-- PRIVATE
-- This procedure raises the business event that is passed in along
-- with all the parameters that are associated with the rule execution
-- being removed.
--
-- p_event_name - Name of the business event
-- p_request_id - Request ID of the rule execution being removed
-- p_object_id  - Object ID of the rule execution being removed
-- ============================================================================

  C_MODULE             CONSTANT FND_LOG_MESSAGES.module%TYPE :=
     'fem.plsql.fem_ud_pkg.raise_undo_business_event';
  C_API_NAME           CONSTANT VARCHAR2(30) := 'Raise_Undo_Business_Event';
  v_calendar_id                 NUMBER;
  v_cal_period_id               NUMBER;
  v_ledger_id                   NUMBER;
  v_output_dataset_code         NUMBER;
  v_object_execution_date       DATE;
  v_source_system_code          NUMBER;
  v_object_name                 FEM_OBJECT_CATALOG_VL.object_name%TYPE;
  v_cal_period_name             FEM_CAL_PERIODS_VL.cal_period_name%TYPE;
  v_calendar_display_code       FEM_CALENDARS_VL.calendar_display_code%TYPE;
  v_calendar_name               FEM_CALENDARS_VL.calendar_name%TYPE;
  v_dataset_display_code        FEM_DATASETS_VL.dataset_display_code%TYPE;
  v_dataset_name                FEM_DATASETS_VL.dataset_name%TYPE;
  v_ledger_display_code         FEM_LEDGERS_VL.ledger_display_code%TYPE;
  v_ledger_name                 FEM_LEDGERS_VL.ledger_name%TYPE;
  v_source_system_display_code  FEM_SOURCE_SYSTEMS_VL.source_system_display_code%TYPE;
  v_source_system_name          FEM_SOURCE_SYSTEMS_VL.source_system_name%TYPE;
  v_display_flag                FEM_PL_OBJECT_EXECUTIONS.display_flag%TYPE;

BEGIN

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
      p_msg_text => 'p_event_name = '||p_event_name);
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'p_request_id = '||to_char(p_request_id));
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'p_object_id = '||to_char(p_object_id));
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'p_status = '||p_status);
  END IF;

  -- First check to make sure if this rule execution belongs to
  -- any of specials rules where the same rule can be executed
  -- repeatedly, for the same parameter set.
  -- If yes, then skip for all where FEM_PL_OBJECT_EXECUTIONS.display_flag
  -- is N to avoid duplicate events being raised when Undoing the "same"
  -- rule execution.
  BEGIN
    SELECT nvl(display_flag,'Y')
    INTO v_display_flag
    FROM fem_pl_object_executions
    WHERE request_id = p_request_id
    AND object_id = p_object_id;
  EXCEPTION
    WHEN others THEN
      v_display_flag := 'Y';
  END;

  IF v_display_flag = 'N' THEN
    RETURN;  -- Not the best programming style, but beats one huge IF stmt
  END IF;

  -- Only reset the workflow parameter list when the event being raised
  -- is the first event: 'oracle.apps.fem.ud.submit'.
  -- Otherwise, just add status to the list and raise the event:
  -- 'oracle.apps.fem.ud.complete'
  IF p_event_name = 'oracle.apps.fem.ud.submit' THEN

    pv_parameter_list.DELETE;
    pv_parameter_list := wf_parameter_list_t();

    -- **************************************************************
    -- ** Retrieve notification parameters
    -- **************************************************************

    -- Retrieve object execution parameters
    BEGIN
      SELECT cal_period_id, ledger_id, output_dataset_code,
             creation_date, source_system_code
      INTO v_cal_period_id, v_ledger_id,  v_output_dataset_code,
           v_object_execution_date, v_source_system_code
      FROM fem_pl_requests
      WHERE request_id = p_request_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
    END;

    -- Retrieve Object Name
    BEGIN
      SELECT object_name
      INTO v_object_name
      FROM fem_object_catalog_vl
      WHERE object_id = p_object_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      v_object_name := 'OBJECT_ID:'||p_object_id;
    END;

    -- Retrieve Calendar Period
    BEGIN
      SELECT calendar_id, cal_period_name
      INTO v_calendar_id, v_cal_period_name
      FROM fem_cal_periods_vl
      WHERE cal_period_id = v_cal_period_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
    END;

    -- Retrieve Dataset
    BEGIN
      SELECT dataset_display_code, dataset_name
      INTO v_dataset_display_code, v_dataset_name
      FROM fem_datasets_vl
      WHERE dataset_code = v_output_dataset_code;
    EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
    END;

    -- Retrieve Ledger
    BEGIN
      SELECT ledger_display_code, ledger_name
      INTO v_ledger_display_code, v_ledger_name
      FROM fem_ledgers_vl
      WHERE ledger_id = v_ledger_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
    END;

    -- Retrieve Source System
    BEGIN
      SELECT source_system_display_code, source_system_name
      INTO v_source_system_display_code, v_source_system_name
      FROM fem_source_systems_vl
      WHERE source_system_code = v_source_system_code;
    EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
    END;

    -- Retrieve Calendar
    BEGIN
      SELECT calendar_display_code, calendar_name
      INTO v_calendar_display_code, v_calendar_name
      FROM fem_calendars_vl
      WHERE calendar_id = v_calendar_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
    END;

    -- **************************************************************
    -- ** Add notification parameters to workflow parameter list.
    -- **************************************************************
    wf_event.AddParameterToList(
      p_name=>'SUBMITTER_NAME',
      p_value=>fnd_global.user_name,
      p_parameterlist=>pv_parameter_list
    );

    wf_event.AddParameterToList(
      p_name=>'UNDO_REQUEST_ID',
      p_value=> pv_request_id,
      p_parameterlist=>pv_parameter_list
    );

    wf_event.AddParameterToList(
      p_name=>'RULE_REQUEST_ID',
      p_value=> p_request_id,
      p_parameterlist=>pv_parameter_list
    );

    wf_event.AddParameterToList(
      p_name=>'RULE_OBJECT_NAME',
      p_value=> v_object_name,
      p_parameterlist=>pv_parameter_list
    );

    wf_event.AddParameterToList(
      p_name=>'DATASET_CODE',
      p_value=> v_output_dataset_code,
      p_parameterlist=>pv_parameter_list
    );

    wf_event.AddParameterToList(
      p_name=>'DATASET_DISPLAY_CODE',
      p_value=> v_dataset_display_code,
      p_parameterlist=>pv_parameter_list
    );

    wf_event.AddParameterToList(
      p_name=>'DATASET_NAME',
      p_value=> v_dataset_name,
      p_parameterlist=>pv_parameter_list
    );

    wf_event.AddParameterToList(
      p_name=>'LEDGER_ID',
      p_value=> v_ledger_id,
      p_parameterlist=>pv_parameter_list
    );

    wf_event.AddParameterToList(
      p_name=>'LEDGER_DISPLAY_CODE',
      p_value=> v_ledger_display_code,
      p_parameterlist=>pv_parameter_list
    );

    wf_event.AddParameterToList(
      p_name=>'LEDGER_NAME',
      p_value=> v_ledger_name,
      p_parameterlist=>pv_parameter_list
    );

    wf_event.AddParameterToList(
      p_name=>'CAL_PERIOD_ID',
      p_value=> v_cal_period_id,
      p_parameterlist=>pv_parameter_list
    );

    wf_event.AddParameterToList(
      p_name=>'CAL_PERIOD_NAME',
      p_value=> v_cal_period_name,
      p_parameterlist=>pv_parameter_list
    );

    wf_event.AddParameterToList(
      p_name=>'CALENDAR_NAME',
      p_value=> v_calendar_name,
      p_parameterlist=>pv_parameter_list
    );

    wf_event.AddParameterToList(
      p_name=>'CALENDAR_DISPLAY_CODE',
      p_value=> v_calendar_display_code,
      p_parameterlist=>pv_parameter_list
    );

    wf_event.AddParameterToList(
      p_name=>'SOURCE_SYSTEM_CODE',
      p_value=> v_source_system_code,
      p_parameterlist=>pv_parameter_list
    );

    wf_event.AddParameterToList(
      p_name=>'SOURCE_SYSTEM_DISPLAY_CODE',
      p_value=> v_source_system_display_code,
      p_parameterlist=>pv_parameter_list
    );

    wf_event.AddParameterToList(
      p_name=>'SOURCE_SYSTEM_NAME',
      p_value=> v_source_system_name,
      p_parameterlist=>pv_parameter_list
    );

    wf_event.AddParameterToList(
      p_name=>'OBJECT_EXECUTION_DATE',
      p_value=>FND_DATE.date_to_canonical(v_object_execution_date),
      p_parameterlist=>pv_parameter_list
    );

  ELSIF p_event_name = 'oracle.apps.fem.ud.complete' THEN
    -- Send completion notification
    wf_event.AddParameterToList(
      p_name=>'STATUS',
      p_value=> p_status,
      p_parameterlist=>pv_parameter_list
    );

  ELSE
    RAISE e_unexp_error;

  END IF; -- p_event_name = 'oracle.apps.fem.ud.submit'


  -- **************************************************************
  -- ** Raise notification event
  -- **************************************************************

  wf_event.raise(
    p_event_name => p_event_name,
    p_event_key => 'FEMUNDO_SUBMIT '||to_char(sysdate,'MM/DD/YYYY HH24:MI:SS'),
    p_parameters => pv_parameter_list
  );

  COMMIT;

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;
--
EXCEPTION WHEN OTHERS THEN

   FEM_ENGINES_PKG.Tech_Message
     (p_severity => pc_log_level_unexpected,
      p_module   => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
      p_msg_text => SQLERRM);

   FEM_ENGINES_PKG.Tech_Message
     (p_severity => pc_log_level_unexpected,
      p_module   => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
      p_msg_text => dbms_utility.format_call_stack);

END raise_undo_business_event;

-- ******************************************************************************
PROCEDURE delete_execution_log (x_return_status                OUT NOCOPY VARCHAR2,
                                x_msg_count                    OUT NOCOPY NUMBER,
                                x_msg_data                     OUT NOCOPY VARCHAR2,
                                p_api_version                  IN  NUMBER,
                                p_commit                       IN  VARCHAR2,
                                p_request_id                   IN  NUMBER,
                                p_object_id                    IN  NUMBER) AS

-- ============================================================================
-- PRIVATE
-- This procedure removes an execution log from the FEM_PL_xxx tables.  It
-- drops all temporary objects created by the object execution whose log is
-- being removed, then deletes the execution log from the FEM_PL_xxx tables.
-- ============================================================================

c_api_name          CONSTANT VARCHAR2(30) := 'delete_execution_log';
c_api_version       CONSTANT NUMBER := 1.0;
v_count_tmpobjs     NUMBER := 0;
v_object_type_code  FEM_OBJECT_TYPES.object_type_code%TYPE;
v_pb_object_id      FEM_OBJECT_CATALOG_B.object_id%TYPE;

-- This cursor retrieves all temporary objects created by the object execution.
CURSOR c3 IS
   SELECT object_name, object_type
   FROM fem_pl_temp_objects
   WHERE request_id = p_request_id
   AND object_id = p_object_id
   ORDER BY object_type, object_name;


BEGIN

   fem_engines_pkg.tech_message(p_severity => pc_log_level_procedure,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'Begin.  P_REQUEST_ID:'||p_request_id||
   ' P_OBJECT_ID: '||p_object_id);

   -- Standard Start of API savepoint
   SAVEPOINT  delete_execution_log_pub;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (c_api_version,
                  p_api_version,
                  c_api_name,
                  pc_pkg_name)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --  Initialize API return status to success
   x_return_status := pc_ret_sts_success;

   SELECT object_type_code
   INTO v_object_type_code
   FROM fem_object_catalog_b
   WHERE object_id = p_object_id;

-- ============================================================================
-- STEP 1:
-- Drop objects listed in FEM_PL_TEMP_OBJECTS
-- If an object is not found, a message is posted and the loop continues
-- to drop the remaining objects.
-- ============================================================================
   fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'STEP 1: Drop objects listed in FEM_PL_TEMP_OBJECTS.');

   FOR tmpobj IN c3 LOOP

      v_count_tmpobjs := c3%ROWCOUNT;

      -- If rule type of "p_object_id" is MAPPING_PREVIEW" use
      -- its associated MAPPING_RULE to get the Process Behavior Parameters.
      IF v_object_type_code = 'MAPPING_PREVIEW' THEN
        SELECT object_id
        INTO v_pb_object_id
        FROM fem_objdef_helper_rules
        WHERE helper_object_id = p_object_id
        AND helper_object_type_code = 'MAPPING_PREVIEW';
      ELSE
        v_pb_object_id := p_object_id;
      END IF;

      FEM_DATABASE_UTIL_PKG.Drop_Temp_DB_Objects (
        p_init_msg_list    => FND_API.G_FALSE,
        p_commit           => FND_API.G_FALSE,
        p_encoded          => FND_API.G_TRUE,
        x_return_status    => x_return_status,
        x_msg_count        => x_msg_count,
        x_msg_data         => x_msg_data,
        p_request_id       => p_request_id,
        p_object_id        => p_object_id,
        p_pb_object_id     => v_pb_object_id);

      IF x_return_status <> pc_ret_sts_success THEN
        FEM_ENGINES_PKG.tech_message(p_severity => pc_log_level_statement,
          p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
          p_msg_text => 'FEM_DATABASE_UTIL_PKG.Drop_Temp_DB_Objects '
                      ||'failed with return status of: '||x_return_status);

        RAISE e_unexp_error;
      END IF;

   END LOOP;

   fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'Number of temporary objects found in FEM_TEMP_OBJECTS: '||v_count_tmpobjs);

-- ============================================================================
-- STEP 2:
-- Delete object execution from process lock tables (FEM_PL_xxxx).
-- ============================================================================
   fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'STEP 2: Delete object execution from process lock tables (FEM_PL_xxxx).');

   DELETE fem_pl_temp_objects
   WHERE request_id = p_request_id
   AND object_id = p_object_id;

   -- Bug 4382068: Only remove data edit locks if object is of type
   -- 'OGL_INTG_CAL_RULE','OGL_INTG_DIM_RULE','OGL_INTG_HIER_RULE'
   IF v_object_type_code IN ('OGL_INTG_CAL_RULE','OGL_INTG_DIM_RULE',
                             'OGL_INTG_HIER_RULE') THEN
     fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
     p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
     p_msg_text => 'Object type is: '||v_object_type_code||'. Only remove edit locks.');

     -- Remove all defs for the object, regardless of the request
     -- because these OGL rules can be run again and again
     -- but Undo only displays the last execution in the conc program UI.
     DELETE fem_pl_object_defs
     WHERE object_id = p_object_id;

     -- Once "undone", these rule executions should no longer show up
     -- in the Undo CM UI.
     UPDATE fem_pl_object_executions
     SET display_flag = 'N'
     WHERE object_id = p_object_id
     AND display_flag = 'Y';
   ELSE
     DELETE fem_pl_obj_exec_steps
     WHERE request_id = p_request_id
     AND object_id = p_object_id;

     DELETE fem_pl_tab_updated_cols
     WHERE request_id = p_request_id
     AND object_id = p_object_id;

     DELETE fem_pl_tables
     WHERE request_id = p_request_id
     AND object_id = p_object_id;

     DELETE fem_pl_chains
     WHERE request_id = p_request_id
     AND object_id = p_object_id;

     DELETE fem_pl_object_defs
     WHERE request_id = p_request_id
     AND object_id = p_object_id;

     DELETE fem_pl_object_executions
     WHERE request_id = p_request_id
     AND object_id = p_object_id;

     -- Only delete request if there are no other executions
     -- for that request.
     DELETE fem_pl_requests
     WHERE request_id = p_request_id
     AND request_id NOT IN
      (select request_id FROM fem_pl_object_executions);
   END IF; -- OGL object type

   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   fem_engines_pkg.tech_message(p_severity => pc_log_level_procedure,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'End. X_RETURN_STATUS: '||x_return_status);

   FND_MSG_PUB.Count_And_Get
      (p_count => x_msg_count,
       p_data  => x_msg_data);

   EXCEPTION
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO delete_execution_log_pub;
         x_return_status := pc_ret_sts_unexp_error;

         fem_engines_pkg.tech_message(p_severity => pc_log_level_unexpected,
         p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
         p_app_name =>'FEM',
         p_msg_name => 'FEM_BAD_P_API_VER_ERR',p_token1 => 'VALUE',
         p_value1 => p_api_version, p_trans1 => 'N');

         fem_engines_pkg.put_message(
         p_app_name =>'FEM',
         p_msg_name => 'FEM_BAD_P_API_VER_ERR',p_token1 => 'VALUE',
         p_value1 => p_api_version, p_trans1 => 'N');

         FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data);

      WHEN OTHERS THEN
      -- Unexpected exceptions
         x_return_status := pc_ret_sts_unexp_error;

      -- Log the call stack and the Oracle error message to
      -- FND_LOG with the "unexpected exception" severity level.

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_unexpected,
            p_module   => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
            p_msg_text => SQLERRM);

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_unexpected,
            p_module   => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
            p_msg_text => dbms_utility.format_call_stack);

      -- Log the Oracle error message to the stack.
         FEM_ENGINES_PKG.put_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UNEXPECTED_ERROR',
            P_TOKEN1 => 'ERR_MSG',
            P_VALUE1 => SQLERRM);

         FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data);

         ROLLBACK TO delete_execution_log_pub;
END delete_execution_log;
-- ****************************************************************************

-- ***************************************************************************
--  Private procedure bodies:
-- ***************************************************************************

-- ****************************************************************************
   PROCEDURE create_undo_list     (x_undo_list_obj_id             OUT NOCOPY NUMBER,
                                   x_undo_list_obj_def_id         OUT NOCOPY NUMBER,
                                   x_return_status                OUT NOCOPY VARCHAR2,
                                   x_msg_count                    OUT NOCOPY NUMBER,
                                   x_msg_data                     OUT NOCOPY VARCHAR2,
                                   p_api_version                  IN  NUMBER,
                                   p_commit                       IN  VARCHAR2,
                                   p_undo_list_name               IN  VARCHAR2,
                                   p_folder_id                    IN  NUMBER,
                                   p_include_dependencies_flag    IN  VARCHAR2,
                                   p_ignore_dependency_errs_flag  IN  VARCHAR2,
                                   p_execution_date               IN  DATE) AS
-- ============================================================================
-- PUBLIC
-- This procedure is used to create an undo list.
-- ============================================================================

c_api_name  CONSTANT VARCHAR2(30) := 'create_undo_list';
c_api_version  CONSTANT NUMBER := 1.0;

BEGIN

   fem_engines_pkg.tech_message(p_severity => pc_log_level_procedure,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'Begin.  P_COMMIT:'||p_commit||
   ' P_UNDO_LIST_NAME: '||p_undo_list_name||
   ' P_FOLDER_ID: '||p_folder_id||
   ' P_INCLUDE_DEPENDENCIES_FLAG: '||p_include_dependencies_flag||
   ' P_IGNORE_DEPENDENCY_ERRS_FLAG:'||p_ignore_dependency_errs_flag||
   ' P_EXECUTION_DATE:'||fnd_date.date_to_displaydate(p_execution_date));

   -- Standard Start of API savepoint
   SAVEPOINT  create_undo_list_pub;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (c_api_version,
                  p_api_version,
                  c_api_name,
                  pc_pkg_name)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --  Initialize API return status to success
   x_return_status := pc_ret_sts_success;

-- ============================================================================
-- Validate parameters
-- If p_execution_date is null, it is set to sysdate - so no need to validate it
-- It is assumed that p_folder_id is validated in the user interface.  It is
-- also validated in fem_object_catalog_util_pkg.create_object.
-- ============================================================================
   IF p_undo_list_name IS NULL THEN
      RAISE e_null_undo_list_name;
   ELSIF p_include_dependencies_flag NOT IN ('Y','N') THEN
      RAISE e_invalid_dependencies_flag;
   ELSIF p_ignore_dependency_errs_flag NOT IN ('Y','N') THEN
      RAISE e_invalid_dependency_errs_flag;
   ELSIF p_commit NOT IN (FND_API.G_FALSE, FND_API.G_TRUE) THEN
      RAISE e_invalid_p_commit;
   END IF;

-- ============================================================================
-- Create object and object definition
-- ============================================================================
   fem_object_catalog_util_pkg.create_object(p_api_version => 1.0,
      p_commit               =>  FND_API.G_FALSE,
      p_object_type_code     =>  'UNDO',
      p_folder_id            =>  pc_undo_folder_id,
      p_local_vs_combo_id    =>  NULL,
      p_object_access_code   =>  'W',
      p_object_origin_code   =>  'USER',
      p_object_name          =>  p_undo_list_name,
      p_description          =>  p_undo_list_name,
      p_effective_start_date =>  sysdate,
      p_effective_end_date   =>  to_date('9999/01/01','YYYY/MM/DD'),
      p_obj_def_name         =>  p_undo_list_name,
      x_object_id            =>  x_undo_list_obj_id,
      x_object_definition_id =>  x_undo_list_obj_def_id,
      x_msg_count            =>  x_msg_count,
      x_msg_data             =>  x_msg_data,
      x_return_status        =>  x_return_status);

   IF x_return_status = pc_ret_sts_success THEN
-- ============================================================================
-- Create list header in FEM_UD_LISTS
-- ============================================================================

      INSERT INTO fem_ud_lists (undo_list_obj_def_id ,include_dependencies_flag ,
      ignore_dependency_errs_flag,execution_date,
      object_version_number,created_by,creation_date,
      last_updated_by,last_update_date,last_update_login)
      VALUES(x_undo_list_obj_def_id ,p_include_dependencies_flag ,
      p_ignore_dependency_errs_flag,NVL(p_execution_date,sysdate)
      ,1,pv_apps_user_id,sysdate,pv_apps_user_id,sysdate,pv_login_id);

   ELSE
      RAISE e_cannot_create_object;
   END IF;


   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   fem_engines_pkg.tech_message(p_severity => pc_log_level_procedure,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'End. x_return_status: '||x_return_status||
   ' x_undo_list_obj_id:'||x_undo_list_obj_id||
   ' x_undo_list_obj_def_id'||x_undo_list_obj_def_id);

   EXCEPTION
      WHEN e_null_undo_list_name THEN
         x_return_status := pc_ret_sts_error;

         fem_engines_pkg.put_message(p_app_name =>'FEM',
         p_msg_name => 'FEM_UD_NULL_LIST_NAME_ERR');

         FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data);
      WHEN e_invalid_dependencies_flag THEN
         x_return_status := pc_ret_sts_error;

         fem_engines_pkg.put_message(p_app_name =>'FEM',
         p_msg_name => 'FEM_UD_BAD_DEPENDENCIES_ERR');

         FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data);
      WHEN e_invalid_dependency_errs_flag THEN
         x_return_status := pc_ret_sts_error;

         fem_engines_pkg.put_message(p_app_name =>'FEM',
         p_msg_name => 'FEM_UD_BAD_DEP_ERRS_ERR');

         FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data);
      WHEN e_invalid_p_commit THEN
         x_return_status := pc_ret_sts_error;

         fem_engines_pkg.put_message(p_app_name =>'FEM',
         p_msg_name => 'FEM_BAD_P_COMMIT_ERR');

         FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data);
      WHEN e_cannot_create_object THEN
         ROLLBACK TO create_undo_list_pub;
         x_return_status := pc_ret_sts_error;

         fem_engines_pkg.put_message(p_app_name =>'FEM',
         p_msg_name => 'FEM_CANNOT_CREATE_OBJ_ERR');

         FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO create_undo_list_pub;
         x_return_status := pc_ret_sts_unexp_error;

         fem_engines_pkg.tech_message(p_severity => pc_log_level_unexpected,
         p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
         p_app_name =>'FEM',
         p_msg_name => 'FEM_BAD_P_API_VER_ERR',p_token1 => 'VALUE',
         p_value1 => p_api_version, p_trans1 => 'N');

      WHEN OTHERS THEN
      -- Unexpected exceptions
         x_return_status := pc_ret_sts_unexp_error;

      -- Log the call stack and the Oracle error message to
      -- FND_LOG with the "unexpected exception" severity level.

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_unexpected,
            p_module   => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
            p_msg_text => SQLERRM);

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_unexpected,
            p_module   => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
            p_msg_text => dbms_utility.format_call_stack);

      -- Log the Oracle error message to the stack.
         FEM_ENGINES_PKG.put_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UNEXPECTED_ERROR',
            P_TOKEN1 => 'ERR_MSG',
            P_VALUE1 => SQLERRM);
         ROLLBACK TO create_undo_list_pub;

END create_undo_list;
-- *****************************************************************************
PROCEDURE delete_undo_list              (x_return_status                OUT NOCOPY VARCHAR2,
                                         x_msg_count                    OUT NOCOPY NUMBER,
                                         x_msg_data                     OUT NOCOPY VARCHAR2,
                                         p_api_version                  IN  NUMBER,
                                         p_commit                       IN  VARCHAR2,
                                         p_undo_list_obj_id             IN  NUMBER) AS

-- ============================================================================
-- PUBLIC
-- This procedure is used to delete an undo list.
-- ============================================================================
c_api_name  CONSTANT VARCHAR2(30) := 'delete_undo_list';
c_api_version  CONSTANT NUMBER := 1.0;
v_undo_list_obj_def_id NUMBER;
v_undo_list_exec_successfully VARCHAR2(1);
v_count NUMBER;

BEGIN

   fem_engines_pkg.tech_message(p_severity => pc_log_level_procedure,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'Begin.  P_COMMIT:'||p_commit||
   ' P_UNDO_LIST_OBJ_ID: '||p_undo_list_obj_id);

   -- Standard Start of API savepoint
   SAVEPOINT  delete_undo_list_pub;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (c_api_version,
                  p_api_version,
                  c_api_name,
                  pc_pkg_name)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --  Initialize API return status to success
   x_return_status := pc_ret_sts_success;

-- ============================================================================
-- V01: Check to see if p_undo_list_obj_id is for a valid undo list.
-- ============================================================================
   fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'V01: Check to see if p_undo_list_obj_id is for a valid undo list.');

   BEGIN

      SELECT object_definition_id
      INTO v_undo_list_obj_def_id
      FROM fem_object_catalog_b o, fem_object_definition_b d
      WHERE o.object_id = p_undo_list_obj_id
      AND o.object_type_code = 'UNDO'
      AND o.object_id = d.object_id;


   EXCEPTION WHEN NO_DATA_FOUND THEN
      RAISE e_invalid_undo_list;
   END;

-- ============================================================================
-- V02: Check to see if user list may be deleted (ie. check to make sure all
-- candidates and dependents in the list have been processed successfully).
-- ============================================================================
   fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'V02: Check to see if user list may be deleted.');

   SELECT DECODE(count(*),0,'Y','N') INTO v_undo_list_exec_successfully
   FROM (select exec_status_code
            from fem_ud_list_candidates
            where undo_list_obj_def_id = v_undo_list_obj_def_id
            and exec_status_code IS NOT NULL
            and exec_status_code <> 'SUCCESS'
         UNION
            select exec_status_code
            from fem_ud_list_dependents
            where undo_list_obj_def_id = v_undo_list_obj_def_id
            and exec_status_code IS NOT NULL
            and exec_status_code <> 'SUCCESS'
         UNION
            select exec_status_code
            from fem_ud_lists
            where undo_list_obj_def_id = v_undo_list_obj_def_id
            and exec_status_code IS NOT NULL
            and exec_status_code <> 'SUCCESS');


   IF v_undo_list_exec_successfully = 'N' THEN

      RAISE e_undo_list_exec_not_success;

   END IF;

-- ============================================================================
-- Delete object and object definition (delete_object
-- procedure checks for locks to make sure that
-- object can be deleted before deletion.  This procedure also checks to
-- make sure that the user has write access to the folder before deleting
-- object.)
-- ============================================================================

   fem_object_catalog_util_pkg.delete_object(p_api_version => 1.0,
      p_commit               =>  FND_API.G_FALSE,
      p_object_id            =>  p_undo_list_obj_id,
      x_msg_count            =>  x_msg_count,
      x_msg_data             =>  x_msg_data,
      x_return_status        =>  x_return_status);

   IF x_return_status = pc_ret_sts_success THEN
-- ============================================================================
-- If the object and its definition were deleted successfully, then
-- delete the list from all the undo tables.
-- ============================================================================

      DELETE fem_ud_list_dependents
      WHERE undo_list_obj_def_id = v_undo_list_obj_def_id;

      DELETE fem_ud_list_candidates
      WHERE undo_list_obj_def_id = v_undo_list_obj_def_id;

      DELETE fem_ud_lists
      WHERE undo_list_obj_def_id = v_undo_list_obj_def_id;

   ELSE
      RAISE e_cannot_delete_object;
   END IF;


   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   fem_engines_pkg.tech_message(p_severity => pc_log_level_procedure,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'End. X_RETURN_STATUS: '||x_return_status);

   FND_MSG_PUB.Count_And_Get
      (p_count => x_msg_count,
       p_data  => x_msg_data);

   EXCEPTION
      WHEN e_invalid_undo_list THEN
         x_return_status := pc_ret_sts_error;
         ROLLBACK;
         FEM_ENGINES_PKG.put_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UD_INVALID_UNDO_LIST_ERR',
            p_token1 => 'OBJECT_ID',
            p_value1 => p_undo_list_obj_id,
            p_trans1 => 'N');

         FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data);

      WHEN e_undo_list_exec_not_success THEN
         ROLLBACK TO delete_undo_list_pub;
         x_return_status := pc_ret_sts_error;

         fem_engines_pkg.put_message(p_app_name =>'FEM',
         p_msg_name => 'FEM_UD_LIST_EXEC_INCOMPLT_ERR');

         FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data);

      WHEN e_cannot_delete_object THEN
         ROLLBACK TO delete_undo_list_pub;
         x_return_status := pc_ret_sts_error;

         fem_engines_pkg.put_message(p_app_name =>'FEM',
         p_msg_name => 'FEM_CANNOT_DELETE_OBJ_ERR',p_token1 => 'OBJECT',
         p_value1 => p_undo_list_obj_id, p_trans1 => 'N');

         FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO delete_undo_list_pub;
         x_return_status := pc_ret_sts_unexp_error;

         fem_engines_pkg.tech_message(p_severity => pc_log_level_unexpected,
         p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
         p_app_name =>'FEM',
         p_msg_name => 'FEM_BAD_P_API_VER_ERR',p_token1 => 'VALUE',
         p_value1 => p_api_version, p_trans1 => 'N');

      WHEN OTHERS THEN
      -- Unexpected exceptions
         x_return_status := pc_ret_sts_unexp_error;

      -- Log the call stack and the Oracle error message to
      -- FND_LOG with the "unexpected exception" severity level.

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_unexpected,
            p_module   => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
            p_msg_text => SQLERRM);

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_unexpected,
            p_module   => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
            p_msg_text => dbms_utility.format_call_stack);

      -- Log the Oracle error message to the stack.
         FEM_ENGINES_PKG.put_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UNEXPECTED_ERROR',
            P_TOKEN1 => 'ERR_MSG',
            P_VALUE1 => SQLERRM);

         ROLLBACK TO delete_undo_list_pub;

END delete_undo_list;
-- *****************************************************************************
PROCEDURE add_candidate                 (x_return_status                OUT NOCOPY VARCHAR2,
                                         x_msg_count                    OUT NOCOPY NUMBER,
                                         x_msg_data                     OUT NOCOPY VARCHAR2,
                                         p_api_version                  IN  NUMBER,
                                         p_commit                       IN  VARCHAR2,
                                         p_undo_list_obj_def_id         IN  NUMBER,
                                         p_request_id                   IN  NUMBER,
                                         p_object_id                    IN  NUMBER) AS

-- ============================================================================
-- PUBLIC
-- This procedure is used to add an object execution to an undo list.
-- ============================================================================
c_api_name  CONSTANT VARCHAR2(30) := 'add_candidate';
c_api_version  CONSTANT NUMBER := 1.0;
v_approval_edit_lock_exists VARCHAR2(1);
v_data_edit_lock_exists VARCHAR2(1);
v_undo_list_ever_executed VARCHAR2(1);
v_dependency_type VARCHAR2(30);
v_include_dependencies_flag VARCHAR2(1);
v_ignore_dependency_errs_flag VARCHAR2(1);
v_count NUMBER;
v_exec_status_code VARCHAR2(30);
v_obj_def_name    FEM_OBJECT_DEFINITION_TL.display_name%TYPE;
v_object_name FEM_OBJECT_CATALOG_TL.object_name%TYPE;

-- This cursor retrieves the snapshot and all other incremental loads that make
-- up a GL load.
-- 10-AUG-04 KFN - The cursor also retrieves all RCM Process Rule executions
-- that have the same ledger, calendar period and dataset code as the current
-- candidate.
-- Bug 4382591: Also retrieve all DataX and Client Data Loader rule
-- executions to the list that have the same ledger, calendar period,
-- dataset code and source system as the current candidate.
-- Bug 5011140 (FP:4596447): Also retrieve all TP Process Rule executions.
CURSOR c1 IS
   SELECT pl.request_id, pl.object_id
   FROM fem_pl_object_executions pl, fem_object_catalog_b o, fem_pl_requests r1, fem_pl_requests r2
   WHERE pl.object_id = o.object_id
   AND o.object_id = p_object_id
   AND o.object_type_code IN ('OGL_INTG_BAL_RULE','XGL_INTEGRATION',
                              'RCM_PROCESS_RULE','TP_PROCESS_RULE',
                              'SOURCE_DATA_LOADER','DATAX_LOADER')
   AND pl.request_id = r1.request_id
   AND r1.request_id <> p_request_id
   AND r2.request_id = p_request_id
   AND r2.cal_period_id = r1.cal_period_id
   AND r2.ledger_id = r1.ledger_id
   AND r2.output_dataset_code = r1.output_dataset_code
   AND (r2.source_system_code = r1.source_system_code
        OR o.object_type_code IN ('OGL_INTG_BAL_RULE','XGL_INTEGRATION',
                                  'RCM_PROCESS_RULE','TP_PROCESS_RULE'));

BEGIN

   fem_engines_pkg.tech_message(p_severity => pc_log_level_procedure,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'Begin.  P_COMMIT:'||p_commit||
   ' P_UNDO_LIST_OBJ_DEF_ID: '||p_undo_list_obj_def_id||
   ' P_REQUEST_ID: '||p_request_id||
   ' P_OBJECT_ID: '||p_object_id);

   -- Standard Start of API savepoint
   SAVEPOINT  add_candidate_pub;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (c_api_version,
                  p_api_version,
                  c_api_name,
                  pc_pkg_name)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --  Initialize API return status to success
   x_return_status := pc_ret_sts_success;

-- ============================================================================
-- VALIDATIONS:
-- ============================================================================

-- ============================================================================
-- STEP V1: Check to see if user can execute the rule.  In FEM.D, if a user
-- can read a rule, then they can execute a rule.
-- ============================================================================
   SELECT  count(*) INTO v_count
   FROM fem_user_folders u, fem_object_catalog_b o
   WHERE o.object_id = p_object_id
   AND o.folder_id = u.folder_id
   AND u.user_id = pv_apps_user_id;

   IF v_count = 0 THEN
      RAISE e_cannot_read_object;
   END IF;
-- ============================================================================
-- STEP V2: Check edit locks.  Cannot update list if it has ever been run, or
-- if it is edit locked.
-- ============================================================================
-- Check for edit locks.  Cannot update list if it is locked.
fem_pl_pkg.get_object_def_edit_locks (
   p_object_definition_id         => p_undo_list_obj_def_id,
   x_approval_edit_lock_exists    => v_approval_edit_lock_exists,
   x_data_edit_lock_exists        => v_data_edit_lock_exists);

-- This query checks to see if the undo list has ever been run, (as
-- the execution may no longer be in the PL tables).
   SELECT DECODE(count(*),0,'N','Y') INTO v_undo_list_ever_executed
   FROM (select exec_status_code
            from fem_ud_list_candidates
            where undo_list_obj_def_id = p_undo_list_obj_def_id
            and exec_status_code IS NOT NULL
         UNION
            select exec_status_code
            from fem_ud_list_dependents
            where undo_list_obj_def_id = p_undo_list_obj_def_id
            and exec_status_code IS NOT NULL
         UNION
            select exec_status_code
            from fem_ud_lists
            where undo_list_obj_def_id = p_undo_list_obj_def_id
            and exec_status_code IS NOT NULL);


   IF v_approval_edit_lock_exists = 'T' OR v_data_edit_lock_exists = 'T'
      OR v_undo_list_ever_executed = 'Y' THEN
      RAISE e_edit_lock_exists;
   END IF;

-- ============================================================================
-- STEP V3: Check for dependencies, if ignore_dependency_errs_flag = 'N' AND
-- include_dependencies_flag = 'N'.
-- NOTE: This only checks for CHAIN dependencies, as UPDATE dependencies are
-- ALWAYS added to the undo list.
-- ============================================================================
   SELECT include_dependencies_flag, ignore_dependency_errs_flag,
   DECODE(include_dependencies_flag,'Y','ALL','UPDATE')
   INTO v_include_dependencies_flag, v_ignore_dependency_errs_flag,v_dependency_type
   FROM fem_ud_lists
   WHERE undo_list_obj_def_id = p_undo_list_obj_def_id;

   IF v_include_dependencies_flag = 'N' AND v_ignore_dependency_errs_flag = 'N'
   THEN

      SELECT count(*) INTO v_count
      FROM fem_pl_chains
      WHERE source_created_by_request_id = p_request_id
      AND source_created_by_object_id = p_object_id;

      IF v_count > 0 THEN
         RAISE e_dependencies_found;
      END IF;
   END IF;

-- ============================================================================
-- STEP V4: Validate that the object execution is not 'RUNNING'.
-- ============================================================================

   -- Bug 6443224. If for some reason a rule is in an undo list but is
   -- no longer in the PL tables, the concurrent manager must have crashed
   -- or Undo must have been killed in mid-processing, before it
   -- was able to clean up the undo list.
   -- So, if no data found in this query, we can assume it was previously
   -- removed and is not currently 'RUNNING'.
   BEGIN
      SELECT exec_status_code INTO v_exec_status_code
      FROM fem_pl_object_executions
      WHERE request_id = p_request_id
      AND object_id = p_object_id;

      IF v_exec_status_code = 'RUNNING' THEN
      -- Verify that the request is still running using fem_pl_pkg.set_exec_state

         fem_pl_pkg.set_exec_state (p_api_version => 1.0,
            p_commit => p_commit,
            p_request_id => p_request_id,
            p_object_id => p_object_id,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data,
            x_return_status => x_return_status);

         IF x_msg_count > 0 THEN
            Get_Put_Messages(
               p_msg_count       => x_msg_count,
               p_msg_data        => x_msg_data,
               p_user_msg        => 'N',
               p_module          => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name);
         END IF;
      END IF;

      SELECT exec_status_code INTO v_exec_status_code
      FROM fem_pl_object_executions
      WHERE request_id = p_request_id
      AND object_id = p_object_id;
   EXCEPTION
      WHEN no_data_found THEN
         v_exec_status_code := 'NORMAL';
   END;

   IF v_exec_status_code = 'RUNNING' THEN
      RAISE e_objexec_is_running;
   END IF;

-- ============================================================================
-- If the list has never been run, add the candidate to the list and
-- generate the candidate's dependents.
-- ============================================================================

   INSERT INTO fem_ud_list_candidates (undo_list_obj_def_id,
      object_id, request_id, object_version_number, created_by, creation_date,
      last_updated_by, last_update_date, last_update_login)
   VALUES (p_undo_list_obj_def_id, p_object_id, p_request_id,
   1, pv_apps_user_id, sysdate, pv_apps_user_id, sysdate, pv_login_id);

   generate_cand_dependents (
      x_return_status                => x_return_status,
      x_msg_count                    => x_msg_count,
      x_msg_data                     => x_msg_data,
      p_api_version                  => 2.0,
      p_commit                       => FND_API.G_FALSE,
      p_undo_list_obj_def_id         => p_undo_list_obj_def_id,
      p_request_id                   => p_request_id,
      p_object_id                    => p_object_id,
      p_dependency_type              => v_dependency_type);

   IF x_return_status <> pc_ret_sts_success THEN
      RAISE e_cannot_generate_dependents;
   END IF;

-- ============================================================================
-- If this candidate is an OGL or XGL integration, add all its incremental loads
-- and the initial snapshot to the list as candidates, and generate their dependents.
-- 08/10/2004 KFN - If this candidate is an RCM Process Rule, add all executions
-- of that rule that have the same calendar period, ledger and output dataset code
-- to the list as candidates, and generate their dependents.  (Note: c1 query
-- modified to include RCM Process Rules).
-- Bug 4382591: Also retrieve all DataX and Client Data Loader rule
-- executions to the list that have the same ledger, calendar period,
-- dataset code and source system as the current candidate.
-- ============================================================================
   FOR an_integration_load_exec IN c1 LOOP

      INSERT INTO fem_ud_list_candidates (undo_list_obj_def_id,
         object_id, request_id, object_version_number, created_by, creation_date,
         last_updated_by, last_update_date, last_update_login)
      VALUES (p_undo_list_obj_def_id, an_integration_load_exec.object_id,
      an_integration_load_exec.request_id, 1, pv_apps_user_id, sysdate,
      pv_apps_user_id, sysdate, pv_login_id);

      generate_cand_dependents (
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_api_version                  => 2.0,
        p_commit                       => FND_API.G_FALSE,
        p_undo_list_obj_def_id         => p_undo_list_obj_def_id,
        p_request_id                   => an_integration_load_exec.request_id,
        p_object_id                    => an_integration_load_exec.object_id,
        p_dependency_type              => v_dependency_type);

      IF x_return_status <> pc_ret_sts_success THEN
         RAISE e_cannot_generate_dependents;
      END IF;

   END LOOP;

   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   fem_engines_pkg.tech_message(p_severity => pc_log_level_procedure,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'End. X_RETURN_STATUS: '||x_return_status);

   FND_MSG_PUB.Count_And_Get
      (p_count => x_msg_count,
       p_data  => x_msg_data);

   EXCEPTION
      WHEN e_edit_lock_exists THEN
         ROLLBACK TO add_candidate_pub;
         x_return_status := pc_ret_sts_error;

         IF  v_data_edit_lock_exists = 'T' THEN
            fem_engines_pkg.put_message(p_app_name =>'FEM',
            p_msg_name =>'FEM_UD_LOCKED_OBJ_DEF_ERR',
            p_token1 => 'OBJECT_DEFINITION_ID',
            p_value1 => p_undo_list_obj_def_id,
            p_trans1 => 'N');
         ELSIF v_undo_list_ever_executed = 'T' THEN
            fem_engines_pkg.put_message(p_app_name =>'FEM',
            p_msg_name =>'FEM_UD_EXECUTED_OBJ_DEF_ERR',
            p_token1 => 'OBJECT_DEFINITION_ID',
            p_value1 => p_undo_list_obj_def_id,
            p_trans1 => 'N');
         ELSIF v_approval_edit_lock_exists = 'T' THEN
            SELECT display_name
            INTO v_obj_def_name
            FROM fem_object_definition_vl
            WHERE object_definition_id = p_undo_list_obj_def_id;

            fem_engines_pkg.put_message(p_app_name =>'FEM',
            p_msg_name =>'FEM_PL_SUBMITTED_DEF_ERR',
            p_token1 => 'OBJ_DEF_NAME',
            p_value1 => v_obj_def_name);
         END IF;

      FND_MSG_PUB.Count_And_Get
         (p_count => x_msg_count,
          p_data  => x_msg_data);
   WHEN e_dependencies_found THEN
         ROLLBACK TO add_candidate_pub;
         x_return_status := pc_ret_sts_error;

         BEGIN
           SELECT object_name
           INTO v_object_name
           FROM fem_object_catalog_vl
           WHERE object_id = p_object_id;
         EXCEPTION
           WHEN others THEN
             v_object_name := to_char(p_object_id);
         END;

         FEM_ENGINES_PKG.put_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UD_CAND_DEP_FOUND_ERR',
            p_token1 => 'REQUEST_ID',
            p_value1 => p_request_id,
            p_token2 => 'OBJECT_NAME',
            p_value2 => v_object_name);

         FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data);

   WHEN e_cannot_read_object THEN
      ROLLBACK TO add_candidate_pub;
      x_return_status := pc_ret_sts_error;

      FEM_ENGINES_PKG.put_message(p_app_name =>'FEM',
         p_msg_name => 'FEM_UD_CANNOT_READ_OBJECT_ERR');

      FND_MSG_PUB.Count_And_Get
         (p_count => x_msg_count,
          p_data  => x_msg_data);

   WHEN e_cannot_generate_dependents THEN
      ROLLBACK TO add_candidate_pub;
      x_return_status := pc_ret_sts_error;

         FEM_ENGINES_PKG.put_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UD_CANNOT_GEN_DEPENDENTS');

         FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO add_candidate_pub;
         x_return_status := pc_ret_sts_unexp_error;

         fem_engines_pkg.tech_message(p_severity => pc_log_level_unexpected,
         p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
         p_app_name =>'FEM',
         p_msg_name => 'FEM_BAD_P_API_VER_ERR',p_token1 => 'VALUE',
         p_value1 => p_api_version, p_trans1 => 'N');

      WHEN OTHERS THEN
      -- Unexpected exceptions
         x_return_status := pc_ret_sts_unexp_error;

      -- Log the call stack and the Oracle error message to
      -- FND_LOG with the "unexpected exception" severity level.

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_unexpected,
            p_module   => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
            p_msg_text => SQLERRM);

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_unexpected,
            p_module   => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
            p_msg_text => dbms_utility.format_call_stack);

      -- Log the Oracle error message to the stack.
         FEM_ENGINES_PKG.put_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UNEXPECTED_ERROR',
            P_TOKEN1 => 'ERR_MSG',
            P_VALUE1 => SQLERRM);

         FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data);

         ROLLBACK TO add_candidate_pub;

END add_candidate;
-- *****************************************************************************
PROCEDURE remove_candidate              (x_return_status                OUT NOCOPY VARCHAR2,
                                         x_msg_count                    OUT NOCOPY NUMBER,
                                         x_msg_data                     OUT NOCOPY VARCHAR2,
                                         p_api_version                  IN  NUMBER,
                                         p_commit                       IN  VARCHAR2,
                                         p_undo_list_obj_def_id         IN  NUMBER,
                                         p_request_id                   IN  NUMBER,
                                         p_object_id                    IN  NUMBER) AS

-- ============================================================================
-- PUBLIC
-- This procedure is used to remove a candidate from an undo list.
-- ============================================================================
c_api_name  CONSTANT VARCHAR2(30) := 'remove_candidate';
c_api_version  CONSTANT NUMBER := 1.0;
v_approval_edit_lock_exists VARCHAR2(1);
v_data_edit_lock_exists VARCHAR2(1);
v_undo_list_ever_executed VARCHAR2(1);
v_obj_def_name    FEM_OBJECT_DEFINITION_TL.display_name%TYPE;

-- This cursor retrieves the snapshot and all other incremental loads that make
-- up a GL load.
-- 10-AUG-04 KFN - The cursor also retrieves all RCM Process Rule executions
-- that have the same ledger, calendar period and dataset code as the current
-- candidate.
-- Bug 4382591: Also retrieve all DataX and Client Data Loader rule
-- executions to the list that have the same ledger, calendar period,
-- dataset code and source system as the current candidate.
-- Bug 5011140 (FP:4596447): Also retrieve all TP Process Rule executions.
CURSOR c1 IS
   SELECT c.request_id, c.object_id
   FROM fem_ud_list_candidates c, fem_object_catalog_b o, fem_pl_requests r1, fem_pl_requests r2
   WHERE c.object_id = o.object_id
   AND o.object_type_code IN ('OGL_INTG_BAL_RULE','XGL_INTEGRATION',
                              'RCM_PROCESS_RULE','TP_PROCESS_RULE',
                              'SOURCE_DATA_LOADER','DATAX_LOADER')
   AND c.request_id = r1.request_id
   AND r1.request_id <> p_request_id
   AND r2.request_id = p_request_id
   AND r2.cal_period_id = r1.cal_period_id
   AND r2.ledger_id = r1.ledger_id
   AND r2.output_dataset_code = r1.output_dataset_code
   AND (r2.source_system_code = r1.source_system_code
        OR o.object_type_code IN ('OGL_INTG_BAL_RULE','XGL_INTEGRATION',
                                  'RCM_PROCESS_RULE','TP_PROCESS_RULE'));

BEGIN

   fem_engines_pkg.tech_message(p_severity => pc_log_level_procedure,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'Begin.  P_COMMIT:'||p_commit||
   ' P_UNDO_LIST_OBJ_DEF_ID: '||p_undo_list_obj_def_id||
   ' P_REQUEST_ID: '||p_request_id||
   ' P_OBJECT_ID: '||p_object_id);

   -- Standard Start of API savepoint
   SAVEPOINT  remove_candidate_pub;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (c_api_version,
                  p_api_version,
                  c_api_name,
                  pc_pkg_name)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --  Initialize API return status to success
   x_return_status := pc_ret_sts_success;

-- ============================================================================
-- VALIDATIONS:
-- Check for edit locks.
-- Cannot update list if it is locked.
-- The list is locked if it has an entry in the FEM_PL tables, OR if
-- it has been processed at least once, and the execution
-- was not successful.
-- ============================================================================
   fem_pl_pkg.get_object_def_edit_locks (
      p_object_definition_id         => p_undo_list_obj_def_id,
      x_approval_edit_lock_exists    => v_approval_edit_lock_exists,
      x_data_edit_lock_exists        => v_data_edit_lock_exists);

   -- This query checks to see if the undo list has ever been run, (as
   -- the execution may no longer be in the PL tables).
   SELECT DECODE(count(*),0,'N','Y') INTO v_undo_list_ever_executed
   FROM (select exec_status_code
            from fem_ud_list_candidates
            where undo_list_obj_def_id = p_undo_list_obj_def_id
            and exec_status_code IS NOT NULL
         UNION
            select exec_status_code
            from fem_ud_list_dependents
            where undo_list_obj_def_id = p_undo_list_obj_def_id
            and exec_status_code IS NOT NULL
         UNION
            select exec_status_code
            from fem_ud_lists
            where undo_list_obj_def_id = p_undo_list_obj_def_id
            and exec_status_code IS NOT NULL);

   IF v_approval_edit_lock_exists = 'T' OR v_data_edit_lock_exists = 'T'
      OR v_undo_list_ever_executed = 'T' THEN
      RAISE e_edit_lock_exists;
   END IF;

-- ============================================================================
-- Delete the candidate and its dependents if no edit locks are found.
-- ============================================================================
   DELETE fem_ud_list_candidates
      WHERE undo_list_obj_def_id = p_undo_list_obj_def_id
      AND request_id = p_request_id
      AND object_id = p_object_id;

   DELETE fem_ud_list_dependents
      WHERE undo_list_obj_def_id = p_undo_list_obj_def_id
      AND request_id = p_request_id
      AND object_id = p_object_id;

-- ============================================================================
-- If this candidate is an OGL or XGL integration, delete all its incremental loads
-- and the initial snapshot.
-- 08/10/2004 KFN - If this candidate is an RCM Process Rule, delete all executions
-- of that rule that are listed as candidates, which have the same calendar period,
-- ledger and output dataset code as that of the candidate.
-- Bug 4382591: Also retrieve all DataX and Client Data Loader rule
-- executions to the list that have the same ledger, calendar period,
-- dataset code and source system as the current candidate.
-- ============================================================================
   FOR an_integration_load_exec IN c1 LOOP

      DELETE fem_ud_list_candidates
         WHERE undo_list_obj_def_id = p_undo_list_obj_def_id
         AND request_id = an_integration_load_exec.request_id
         AND object_id = an_integration_load_exec.object_id;

      DELETE fem_ud_list_dependents
         WHERE undo_list_obj_def_id = p_undo_list_obj_def_id
         AND request_id = an_integration_load_exec.request_id
         AND object_id = an_integration_load_exec.object_id;

   END LOOP;

   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   fem_engines_pkg.tech_message(p_severity => pc_log_level_procedure,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'End. X_RETURN_STATUS: '||x_return_status);

   FND_MSG_PUB.Count_And_Get
      (p_count => x_msg_count,
       p_data  => x_msg_data);

   EXCEPTION
      WHEN e_edit_lock_exists THEN
         ROLLBACK TO remove_candidate_pub;
         x_return_status := pc_ret_sts_error;

         IF  v_data_edit_lock_exists = 'T' THEN
            fem_engines_pkg.put_message(p_app_name =>'FEM',
            p_msg_name =>'FEM_UD_LOCKED_OBJ_DEF_ERR',
            p_token1 => 'OBJECT_DEFINITION_ID',
            p_value1 => p_undo_list_obj_def_id,
            p_trans1 => 'N');
         ELSIF v_undo_list_ever_executed = 'T' THEN
            fem_engines_pkg.put_message(p_app_name =>'FEM',
            p_msg_name =>'FEM_UD_EXECUTED_OBJ_DEF_ERR',
            p_token1 => 'OBJECT_DEFINITION_ID',
            p_value1 => p_undo_list_obj_def_id,
            p_trans1 => 'N');
         ELSIF v_approval_edit_lock_exists = 'T' THEN
            SELECT display_name
            INTO v_obj_def_name
            FROM fem_object_definition_vl
            WHERE object_definition_id = p_undo_list_obj_def_id;

            fem_engines_pkg.put_message(p_app_name =>'FEM',
            p_msg_name =>'FEM_PL_SUBMITTED_DEF_ERR',
            p_token1 => 'OBJ_DEF_NAME',
            p_value1 => v_obj_def_name);
         END IF;

      FND_MSG_PUB.Count_And_Get
         (p_count => x_msg_count,
          p_data  => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO remove_candidate_pub;
         x_return_status := pc_ret_sts_unexp_error;

         fem_engines_pkg.tech_message(p_severity => pc_log_level_unexpected,
         p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
         p_app_name =>'FEM',
         p_msg_name => 'FEM_BAD_P_API_VER_ERR',p_token1 => 'VALUE',
         p_value1 => p_api_version, p_trans1 => 'N');

      WHEN OTHERS THEN
      -- Unexpected exceptions
         x_return_status := pc_ret_sts_unexp_error;

      -- Log the call stack and the Oracle error message to
      -- FND_LOG with the "unexpected exception" severity level.

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_unexpected,
            p_module   => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
            p_msg_text => SQLERRM);

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_unexpected,
            p_module   => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
            p_msg_text => dbms_utility.format_call_stack);

      -- Log the Oracle error message to the stack.
         FEM_ENGINES_PKG.put_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UNEXPECTED_ERROR',
            P_TOKEN1 => 'ERR_MSG',
            P_VALUE1 => SQLERRM);

         FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data);

         ROLLBACK TO remove_candidate_pub;

END remove_candidate;

-- *****************************************************************************
PROCEDURE calc_accttbl_upd_dependents   (x_msg_count                    OUT NOCOPY NUMBER,
                                         x_msg_data                     OUT NOCOPY VARCHAR2,
                                         x_return_status                OUT NOCOPY VARCHAR2,
                                         x_upd_dep_calc_id              OUT NOCOPY NUMBER,
                                         p_request_id                   IN  NUMBER,
                                         p_object_id                    IN  NUMBER) AS

-- ============================================================================
-- PRIVATE
-- This procedure calculates all the account table 'UPDATE' dependents
-- for a given object execution.
-- There are two types of 'UPDATE' dependencies that this procedure tracks.
-- Type 1:  An object execution that has updated the same column within the
-- same set of data as an undo list candidate.
-- Type 2:     An object execution that has updated a column on a row
-- that was inserted by an undo list candidate.
-- In either case, a dependent must have the same parameters (ledger,
-- cal period, dataset) as the candidate.
-- Currently, 'UPDATE' dependencies only apply to account tables.
-- ============================================================================

c_api_name  CONSTANT VARCHAR2(30) := 'calc_accttbl_upd_dependents';
v_ledger_id NUMBER;
v_output_dataset_code NUMBER;
v_cal_period_id NUMBER;
v_new_type1 BOOLEAN;
v_new_type2 BOOLEAN;
v_new_dependents BOOLEAN;
v_new_columns BOOLEAN;
v_num_dep_rows NUMBER;

BEGIN

   fem_engines_pkg.tech_message(p_severity => pc_log_level_procedure,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'Begin.  P_REQUEST_ID: '||p_request_id||
   ' P_OBJECT_ID: '||p_object_id);

   -- Standard Start of API savepoint
   SAVEPOINT  calc_accttbl_upd_dep_pub;

   -- Initialize variables
   v_new_type1 := FALSE;
   v_new_type2 := FALSE;
   v_new_columns := FALSE;

   -- Retrieve number to identify this calculation from the sequence
   SELECT fem_ud_upd_dep_s.nextval INTO x_upd_dep_calc_id
   FROM dual;

   -- Retrieve ledger, dataset code and calendar period for the candidate
   SELECT ledger_id, output_dataset_code, cal_period_id
   INTO v_ledger_id, v_output_dataset_code, v_cal_period_id
   FROM fem_pl_requests
   WHERE request_id = p_request_id;

   -- Retrieve initial list of type 2 dependents of the candidate.
   INSERT INTO fem_ud_upd_dep_t (upd_dep_calc_id, dependent_request_id, dependent_object_id)
     SELECT DISTINCT x_upd_dep_calc_id, t1.request_id, t1.object_id
     FROM fem_pl_tables t1
     WHERE t1.request_id IN (
       SELECT r.request_id
       FROM fem_pl_requests r
       WHERE r.ledger_id = v_ledger_id
       AND r.cal_period_id = v_cal_period_id
       AND r.output_dataset_code = v_output_dataset_code)
     AND t1.table_name IN (
       SELECT t2.table_name
       FROM fem_pl_tables t2, fem_table_class_assignmt_v t
       WHERE t2.request_id = p_request_id
       AND t2.object_id = p_object_id
       AND t2.statement_type = 'INSERT'
       AND t2.table_name = t.table_name
       AND t.table_classification_code IN
        ('ACCOUNT_PROFITABILITY','FTP_CASH_FLOW',
         'FTP_NON_CASH_FLOW','FTP_OPTION_COST') )
     AND t1.statement_type = 'UPDATE';

   v_new_dependents := (SQL%ROWCOUNT > 0);
   v_num_dep_rows := SQL%ROWCOUNT;

   fem_engines_pkg.tech_message(p_severity => pc_log_level_procedure,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'Init Type2 dependents found: '||SQL%ROWCOUNT);

   -- Retrieve initial list of updated account table columns.  The query
   -- retrieves all account table columns updated by the candidate.
   INSERT INTO fem_ud_upd_cols_t (upd_dep_calc_id, table_name, column_name, checked_flag)
     SELECT DISTINCT x_upd_dep_calc_id, c.table_name, c.column_name, 'N'
     FROM fem_pl_tab_updated_cols c
     WHERE request_id = p_request_id
     AND object_id = p_object_id
     AND c.table_name IN (
       SELECT t.table_name
       FROM fem_table_class_assignmt_v t
       WHERE t.table_classification_code IN
        ('ACCOUNT_PROFITABILITY','FTP_CASH_FLOW',
         'FTP_NON_CASH_FLOW','FTP_OPTION_COST') );

   v_new_columns := (SQL%ROWCOUNT > 0);

   fem_engines_pkg.tech_message(p_severity => pc_log_level_procedure,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'Init Type1 dependents found: '||SQL%ROWCOUNT);

   LOOP
     -- Keep looping until no more columns are being added to
     -- fem_ud_upd_cols_t AND no more dependents are being added
     -- to fem_ud_upd_dep_t.
     IF (NOT v_new_columns) AND (NOT v_new_dependents) THEN
       EXIT;
     END IF;

     -- Find type 1 dependents.
     -- Technical note: Columns that have previously been checked for
     -- dependencies will have fem_ud_upd_cols_t.checked_flag set to 'Y'.
     -- In this query, we only want to find update dependencies for columns
     -- that have not been checked yet.
     INSERT INTO fem_ud_upd_dep_t (upd_dep_calc_id, dependent_request_id, dependent_object_id)
       SELECT DISTINCT x_upd_dep_calc_id, c.request_id, c.object_id
       FROM fem_pl_tab_updated_cols c
       WHERE c.request_id IN (
         SELECT r.request_id
         FROM fem_pl_requests r
         WHERE r.ledger_id = v_ledger_id
         AND r.cal_period_id = v_cal_period_id
         AND r.output_dataset_code = v_output_dataset_code)
       AND (c.table_name, c.column_name) IN (
         SELECT table_name, column_name
         FROM fem_ud_upd_cols_t
         WHERE upd_dep_calc_id = x_upd_dep_calc_id
         AND checked_flag = 'N')
       AND (c.request_id, c.object_id) NOT IN (
         SELECT dependent_request_id, dependent_object_id
         FROM fem_ud_upd_dep_t
         WHERE upd_dep_calc_id = x_upd_dep_calc_id);

     v_new_type1 := (SQL%ROWCOUNT > 0);
     v_num_dep_rows := v_num_dep_rows + SQL%ROWCOUNT;

     -- Now that these columns have been checked, mark them as such.
     UPDATE fem_ud_upd_cols_t SET checked_flag = 'Y'
     WHERE upd_dep_calc_id = x_upd_dep_calc_id
     AND checked_flag = 'N';

     -- Find type 2 dependents.
     INSERT INTO fem_ud_upd_dep_t (upd_dep_calc_id, dependent_request_id, dependent_object_id)
       SELECT DISTINCT x_upd_dep_calc_id, t1.request_id, t1.object_id
       FROM fem_pl_tables t1
       WHERE t1.request_id IN (
         SELECT r.request_id
         FROM fem_pl_requests r
         WHERE r.ledger_id = v_ledger_id
         AND r.cal_period_id = v_cal_period_id
         AND r.output_dataset_code = v_output_dataset_code)
       AND t1.table_name IN (
         SELECT t2.table_name
         FROM fem_pl_tables t2, fem_table_class_assignmt_v t
         WHERE t2.table_name = t.table_name
         AND t.table_classification_code IN
          ('ACCOUNT_PROFITABILITY','FTP_CASH_FLOW',
           'FTP_NON_CASH_FLOW','FTP_OPTION_COST')
         AND t2.statement_type = 'INSERT'
         AND (t2.request_id, t2.object_id) IN (
           SELECT dependent_request_id, dependent_object_id
           FROM fem_ud_upd_dep_t
           WHERE upd_dep_calc_id = x_upd_dep_calc_id))
       AND t1.statement_type = 'UPDATE'
       AND (t1.request_id, t1.object_id) NOT IN (
         SELECT dependent_request_id, dependent_object_id
         FROM fem_ud_upd_dep_t
         WHERE upd_dep_calc_id = x_upd_dep_calc_id);

     v_new_type2 := (SQL%ROWCOUNT > 0);
     v_new_dependents := (v_new_type1 OR v_new_type2);
     v_num_dep_rows := v_num_dep_rows + SQL%ROWCOUNT;

     -- If any new dependents were found, then see if the
     -- dependents are updating any columns that have not
     -- already been captured by fem_ud_upd_cols_t).
     IF v_new_dependents THEN
       INSERT INTO fem_ud_upd_cols_t (upd_dep_calc_id, table_name, column_name, checked_flag)
         SELECT DISTINCT x_upd_dep_calc_id, c.table_name, c.column_name, 'N'
         FROM fem_pl_tab_updated_cols c
         WHERE (c.request_id, c.object_id) IN (
           SELECT d.dependent_request_id, d.dependent_object_id
           FROM fem_ud_upd_dep_t d
           WHERE d.upd_dep_calc_id = x_upd_dep_calc_id)
         AND c.table_name IN (
           SELECT t.table_name
           FROM fem_table_class_assignmt_v t
           WHERE t.table_classification_code IN
            ('ACCOUNT_PROFITABILITY','FTP_CASH_FLOW',
             'FTP_NON_CASH_FLOW','FTP_OPTION_COST') )
         AND (c.table_name, c.column_name) NOT IN (
           SELECT e.table_name, e.column_name
           FROM fem_ud_upd_cols_t e
           WHERE e.upd_dep_calc_id = x_upd_dep_calc_id);

       v_new_columns := (SQL%ROWCOUNT > 0);
     ELSE
       v_new_columns := FALSE;
     END IF; -- v_num_new_dep
   END LOOP;

   fem_engines_pkg.tech_message(p_severity => pc_log_level_procedure,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'Number of dependents found: '||v_num_dep_rows);

   -- Update API return status to success
   x_return_status := pc_ret_sts_success;

   fem_engines_pkg.tech_message(p_severity => pc_log_level_procedure,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'End. X_RETURN_STATUS: '||x_return_status||' x_upd_dep_calc_id:'||x_upd_dep_calc_id);

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
         ROLLBACK TO calc_accttbl_upd_dep_pub;
         x_return_status := pc_ret_sts_error;
         FEM_ENGINES_PKG.user_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UD_REQUEST_NOT_FOUND_WRN',
            p_token1 => 'REQUEST_ID',
            p_value1 => p_request_id,
            p_trans1 => 'N');

         FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data);

     WHEN OTHERS THEN
      -- Unexpected exceptions
         x_return_status := pc_ret_sts_unexp_error;

      -- Log the call stack and the Oracle error message to
      -- FND_LOG with the "unexpected exception" severity level.

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_unexpected,
            p_module   => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
            p_msg_text => SQLERRM);

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_unexpected,
            p_module   => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
            p_msg_text => dbms_utility.format_call_stack);

      -- Log the Oracle error message to the stack.
         FEM_ENGINES_PKG.put_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UNEXPECTED_ERROR',
            P_TOKEN1 => 'ERR_MSG',
            P_VALUE1 => SQLERRM);

         FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data);

END calc_accttbl_upd_dependents;

-- *****************************************************************************
PROCEDURE report_cand_dependents        (x_msg_count                    OUT NOCOPY NUMBER,
                                         x_msg_data                     OUT NOCOPY VARCHAR2,
                                         p_request_id                   IN  NUMBER,
                                         p_object_id                    IN  NUMBER,
                                         p_dependency_type              IN  VARCHAR2) AS

-- ============================================================================
-- PUBLIC
-- This procedure reports a list of all object executions that used the
-- result data of an undo list candidate as input.  The list of dependents are
-- posted as messages in the message stack.  It is up to the calling program
-- to retrieve the list of dependents from the message stack.
-- Valid values for p_dependency_type: 'ALL','UPDATE','CHAIN'
-- ============================================================================

c_api_name  CONSTANT VARCHAR2(30) := 'report_cand_dependents';
v_count NUMBER := 0;
v_ledger_id NUMBER;
v_cal_period_id NUMBER;
v_output_dataset_code NUMBER;
v_num_of_upd_dependents NUMBER;
v_upd_dep_calc_id NUMBER;
v_return_status VARCHAR2(30);
v_object_name FEM_OBJECT_CATALOG_TL.object_name%TYPE;

-- Cursor to retrieve an object execution's UPDATE dependents
-- Note that this only applies to ACCOUNT tables.
CURSOR c1 (v_upd_dep_calc_id IN NUMBER) IS
   SELECT c.upd_dep_calc_id, c.dependent_request_id, c.dependent_object_id
   FROM fem_ud_upd_dep_t c
   WHERE c.upd_dep_calc_id = v_upd_dep_calc_id
   AND NOT (c.dependent_request_id = p_request_id
        AND c.dependent_object_id = p_object_id);

-- Cursor to retrieve an object execution's CHAIN dependents
CURSOR c2 IS
   SELECT DISTINCT object_id, request_id
   FROM fem_pl_chains
   START WITH source_created_by_request_id = p_request_id
   AND source_created_by_object_id = p_object_id
   CONNECT BY
   PRIOR object_id=source_created_by_object_id AND
   PRIOR request_id=source_created_by_request_id;

BEGIN

   fem_engines_pkg.tech_message(p_severity => pc_log_level_procedure,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'Begin.  '||
   ' P_REQUEST_ID: '||p_request_id||
   ' P_OBJECT_ID: '||p_object_id||
   ' P_DEPENDENCY_TYPE: '||p_dependency_type);

   FEM_ENGINES_PKG.put_message(p_app_name =>'FEM',
      p_msg_name => 'FEM_UD_CAND_DEPENDENTS_TXT',
      p_token1 => 'REQUEST_ID',
      p_value1 => p_request_id,
      p_trans1 => 'N',
      p_token2 => 'OBJECT_ID',
      p_value2 => p_object_id,
      p_trans2 => 'N');

-- ============================================================================
-- STEP 1: Report UPDATE dependents. Note: Update dependents only applicable
-- to ACCOUNT tables.
-- ============================================================================

IF p_dependency_type IN ('ALL','UPDATE') THEN
   fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'STEP 1: Report UPDATE dependents.');

   BEGIN
      calc_accttbl_upd_dependents (
           x_msg_count               => x_msg_count,
           x_msg_data                => x_msg_data,
           x_return_status           => v_return_status,
           x_upd_dep_calc_id         => v_upd_dep_calc_id,
           p_request_id              => p_request_id,
           p_object_id               => p_object_id);

      IF v_return_status <> pc_ret_sts_success THEN
         RAISE e_cannot_gen_cand_upd_dep;
      END IF;
      v_count := 0;
      FOR an_update_dependent IN c1(v_upd_dep_calc_id) LOOP
      v_count := c1%ROWCOUNT;

         FEM_ENGINES_PKG.put_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UD_DEPENDENT_OBJEXEC_TXT',
            p_token1 => 'REQUEST_ID',
            p_value1 => an_update_dependent.dependent_request_id,
            p_trans1 => 'N',
            p_token2 => 'OBJECT_ID',
            p_value2 => an_update_dependent.dependent_object_id,
            p_trans2 => 'N',
            p_token3 => 'DEPENDENT_TYPE',
            p_value3 => 'UPDATE',
            p_trans3 => 'N');

      END LOOP;

      IF v_count = 0 THEN -- If no dependents found, post message
         fem_engines_pkg.put_message(p_app_name =>'FEM',
         p_msg_name => 'FEM_UD_NO_UPDATE_DEP_FOUND_TXT');
      END IF;

      -- Delete update dependent list from temporary tables as no longer needed.
      DELETE fem_ud_upd_dep_t WHERE upd_dep_calc_id = v_upd_dep_calc_id;
      DELETE fem_ud_upd_cols_t WHERE upd_dep_calc_id = v_upd_dep_calc_id;
      COMMIT;

   EXCEPTION
      WHEN e_cannot_gen_cand_upd_dep THEN
         BEGIN
           SELECT object_name
           INTO v_object_name
           FROM fem_object_catalog_vl
           WHERE object_id = p_object_id;
         EXCEPTION
           WHEN others THEN
             v_object_name := to_char(p_object_id);
         END;

         FEM_ENGINES_PKG.put_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UD_CANNOT_GEN_CAND_DEP_ERR',
            p_token1 => 'REQUEST_ID',
            p_value1 => p_request_id,
            p_token2 => 'OBJECT_NAME',
            p_value2 => v_object_name);
   END;
END IF;

-- ============================================================================
-- STEP 2: Report CHAIN dependents.
-- ============================================================================
IF p_dependency_type IN ('ALL','CHAIN') THEN

   fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'STEP 2: Report CHAIN dependents.');

   v_count := 0;
   FOR a_chain_dependent IN c2 LOOP
   v_count := c2%ROWCOUNT;

      FEM_ENGINES_PKG.put_message(p_app_name =>'FEM',
         p_msg_name => 'FEM_UD_DEPENDENT_OBJEXEC_TXT',
         p_token1 => 'REQUEST_ID',
         p_value1 => a_chain_dependent.request_id,
         p_trans1 => 'N',
         p_token2 => 'OBJECT_ID',
         p_value2 => a_chain_dependent.object_id,
         p_trans2 => 'N',
         p_token3 => 'DEPENDENT_TYPE',
         p_value3 => 'CHAIN',
         p_trans3 => 'N');

   END LOOP;

   IF v_count = 0 THEN -- If no dependents found, post message
      fem_engines_pkg.put_message(p_app_name =>'FEM',
      p_msg_name => 'FEM_UD_NO_CHAIN_DEP_FOUND_TXT');
   END IF;

END IF;

   fem_engines_pkg.tech_message(p_severity => pc_log_level_procedure,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'End.');

   FND_MSG_PUB.Count_And_Get
      (p_count => x_msg_count,
       p_data  => x_msg_data);

EXCEPTION
   WHEN OTHERS THEN
   -- Unexpected exceptions
   -- Log the call stack and the Oracle error message to
   -- FND_LOG with the "unexpected exception" severity level.

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_unexpected,
         p_module   => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
         p_msg_text => SQLERRM);

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_unexpected,
         p_module   => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
         p_msg_text => dbms_utility.format_call_stack);

   -- Log the Oracle error message to the stack.
      FEM_ENGINES_PKG.put_message(p_app_name =>'FEM',
         p_msg_name => 'FEM_UNEXPECTED_ERROR',
         P_TOKEN1 => 'ERR_MSG',
         P_VALUE1 => SQLERRM);

      FND_MSG_PUB.Count_And_Get
         (p_count => x_msg_count,
          p_data  => x_msg_data);

END report_cand_dependents;
-- *****************************************************************************
PROCEDURE generate_cand_dependents      (x_return_status                OUT NOCOPY VARCHAR2,
                                         x_msg_count                    OUT NOCOPY NUMBER,
                                         x_msg_data                     OUT NOCOPY VARCHAR2,
                                         p_api_version                  IN  NUMBER,
                                         p_commit                       IN  VARCHAR2,
                                         p_undo_list_obj_def_id         IN  NUMBER DEFAULT NULL,
                                         p_request_id                   IN  NUMBER,
                                         p_object_id                    IN  NUMBER,
                                         p_dependency_type              IN  VARCHAR2,
                                         p_ud_session_id                IN  NUMBER DEFAULT NULL,
                                         p_preview_flag                 IN  VARCHAR2 DEFAULT 'N') AS

-- ============================================================================
-- PUBLIC
-- This procedure generates a list of all object executions that used the
-- result data of an undo list candidate as input.  The list of dependents are
-- stored in FEM_UD_LIST_DEPENDENTS when p_preview_flag = 'N' and are stored in
-- FEM_UD_PRVIEW_DEPENDENTS when p_preview_flag = 'Y'.  This procedure always
-- generates update dependents, and will only generate chain dependents if
-- p_dependency_type = 'ALL'.
-- Note: Original logic allowed user to specify the type of dependencies to
-- include.  Current logic always includes update dependencies.
-- Valid values for p_dependency_type: 'ALL','UPDATE'
-- ============================================================================
c_api_name  CONSTANT VARCHAR2(30) := 'generate_cand_dependents';
c_api_version  CONSTANT NUMBER := 2.0;
v_count NUMBER := 0;
v_ledger_id NUMBER;
v_cal_period_id NUMBER;
v_output_dataset_code NUMBER;
v_undo_list_ever_exec VARCHAR2(1);
v_num_of_upd_dependents NUMBER;
v_upd_dep_calc_id NUMBER;
v_exec_status_code VARCHAR2(30);
v_object_name FEM_OBJECT_CATALOG_TL.object_name%TYPE;

-- Cursor to retrieve an object execution's UPDATE dependents
-- Note that this only applies to ACCOUNT tables.
CURSOR c1 IS
   SELECT c.upd_dep_calc_id, c.dependent_request_id, c.dependent_object_id
   FROM fem_ud_upd_dep_t c
   WHERE c.upd_dep_calc_id = v_upd_dep_calc_id
   AND NOT (c.dependent_request_id = p_request_id
        AND c.dependent_object_id = p_object_id);

-- Cursor to retrieve an object execution's CHAIN dependents
CURSOR c2 IS
   SELECT DISTINCT object_id, request_id
   FROM fem_pl_chains
   START WITH source_created_by_request_id = p_request_id
   AND source_created_by_object_id = p_object_id
   CONNECT BY
   PRIOR object_id=source_created_by_object_id AND
   PRIOR request_id=source_created_by_request_id;

-- Bug 5103063: Add all "hidden" executions onto the preview
-- dependencies list to give the user a more complete picture of what
-- is being undone in the Undo Confirmation Page.
CURSOR c_repeat_execs (p_req_id NUMBER, p_obj_id NUMBER) IS
   SELECT pl.request_id, pl.object_id
   FROM fem_pl_object_executions pl, fem_object_catalog_b o,
        fem_pl_requests r1, fem_pl_requests r2
   WHERE pl.object_id = o.object_id
   AND o.object_id = p_obj_id
   AND o.object_type_code IN ('OGL_INTG_BAL_RULE','XGL_INTEGRATION',
                              'RCM_PROCESS_RULE','TP_PROCESS_RULE',
                              'SOURCE_DATA_LOADER','DATAX_LOADER')
   AND pl.request_id = r1.request_id
   AND r1.request_id <> p_req_id
   AND r2.request_id = p_req_id
   AND r2.cal_period_id = r1.cal_period_id
   AND r2.ledger_id = r1.ledger_id
   AND r2.output_dataset_code = r1.output_dataset_code
   AND (r2.source_system_code = r1.source_system_code
        OR o.object_type_code IN ('OGL_INTG_BAL_RULE','XGL_INTEGRATION',
                                  'RCM_PROCESS_RULE','TP_PROCESS_RULE'));

-- Cursor to retrieve all of an object execution's dependents.  This
-- cursor is used to validate the dependents.  Use this query when
-- p_preview_flag = 'N'
CURSOR c3 IS
   SELECT d.dependent_request_id, d.dependent_object_id, u.folder_id
   FROM fem_ud_list_dependents d, fem_object_catalog_b o, fem_user_folders u
   WHERE undo_list_obj_def_id = p_undo_list_obj_def_id
   AND d.request_id = p_request_id
   AND d.object_id = p_object_id
   AND d.dependent_object_id = o.object_id
   AND o.folder_id = u.folder_id (+)
   AND u.user_id(+) = pv_apps_user_id;

-- Cursor to retrieve all of an object execution's dependents.  This
-- cursor is used to validate the dependents.  Use this query when
-- p_preview_flag = 'Y'
CURSOR c4 IS
   SELECT d.dependent_request_id, d.dependent_object_id, u.folder_id
   FROM fem_ud_prview_dependents d, fem_object_catalog_b o, fem_user_folders u
   WHERE d.ud_session_id = p_ud_session_id
   AND d.request_id = p_request_id
   AND d.object_id = p_object_id
   AND d.dependent_object_id = o.object_id
   AND o.folder_id = u.folder_id (+)
   AND u.user_id(+) = pv_apps_user_id;


BEGIN

   fem_engines_pkg.tech_message(p_severity => pc_log_level_procedure,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'Begin.  P_COMMIT:'||p_commit||
   ' P_PREVIEW_FLAG: '||p_preview_flag||
   ' P_UD_SESSION_ID: '||p_ud_session_id||
   ' P_UNDO_LIST_OBJ_DEF_ID: '||p_undo_list_obj_def_id||
   ' P_REQUEST_ID: '||p_request_id||
   ' P_OBJECT_ID: '||p_object_id||
   ' P_DEPENDENCY_TYPE: '||p_dependency_type);

   -- Standard Start of API savepoint
   SAVEPOINT  generate_cand_dependents_pub;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (c_api_version,
                  p_api_version,
                  c_api_name,
                  pc_pkg_name)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --  Initialize API return status to success
   x_return_status := pc_ret_sts_success;


-- ============================================================================
-- == VALIDATIONS: Validate input parameters
-- ============================================================================
-- STEP V1: Validate p_preview_flag
-- ============================================================================

   IF p_preview_flag NOT IN ('N','Y') THEN
      RAISE e_invalid_preview_flag;
   END IF;
-- ============================================================================
-- STEP V2: Validate p_ud_session_id
-- ============================================================================

   IF p_preview_flag = 'Y' AND p_ud_session_id IS NULL THEN
      RAISE e_invalid_session_id;
   END IF;

-- ============================================================================
-- STEP V3: Validate p_undo_list_obj_def_id
-- ============================================================================
   IF p_preview_flag = 'N' AND p_undo_list_obj_def_id IS NULL THEN
      RAISE e_invalid_undolist_objdefid;
   END IF;

-- ============================================================================
-- STEP V4: Validate p_dependency_type
-- ============================================================================
   IF p_dependency_type NOT IN ('ALL','UPDATE') THEN
      RAISE e_invalid_dependency_type;
   END IF;


-- ============================================================================
-- STEP 1: DELETE existing dependents for the candidate if the undo list has
-- never been run.
-- ============================================================================
   fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'STEP 1: DELETE existing dependents for the candidate.');

   IF p_preview_flag = 'N' THEN
      SELECT DECODE(count(*),0,'N','Y') INTO v_undo_list_ever_exec
      FROM (select exec_status_code
               from fem_ud_list_candidates
               where undo_list_obj_def_id = p_undo_list_obj_def_id
               and exec_status_code IS NOT NULL
            UNION
               select exec_status_code
               from fem_ud_list_dependents
               where undo_list_obj_def_id = p_undo_list_obj_def_id
               and exec_status_code IS NOT NULL
            UNION
               select exec_status_code
               from fem_ud_lists
               where undo_list_obj_def_id = p_undo_list_obj_def_id
               and exec_status_code IS NOT NULL);

      IF v_undo_list_ever_exec = 'N' THEN

         DELETE fem_ud_list_dependents
         WHERE undo_list_obj_def_id = p_undo_list_obj_def_id
         AND request_id = p_request_id
         AND object_id = p_object_id;

      END IF;
   ELSIF p_preview_flag = 'Y' THEN
   -- Delete dependents for preview list candidate.
      DELETE fem_ud_prview_dependents
      WHERE ud_session_id = p_ud_session_id
      AND request_id = p_request_id
      AND object_id = p_object_id;

   END IF;
-- ============================================================================
-- STEP 2: Generate UPDATE dependents.
-- Update dependents are only applicable to ACCOUNT tables.
-- ============================================================================
   fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'STEP 2: Generate UPDATE dependents.');

   BEGIN

      calc_accttbl_upd_dependents (
           x_msg_count               => x_msg_count,
           x_msg_data                => x_msg_data,
           x_return_status           => x_return_status,
           x_upd_dep_calc_id         => v_upd_dep_calc_id,
           p_request_id              => p_request_id,
           p_object_id               => p_object_id);

      IF x_return_status <> pc_ret_sts_success THEN
         RAISE e_cannot_gen_cand_upd_dep;
      END IF;

      v_count := 0;
      FOR updated_col IN c1 LOOP
         v_count := c1%ROWCOUNT;

         BEGIN

            IF  p_preview_flag = 'N' THEN
               INSERT INTO fem_ud_list_dependents (undo_list_obj_def_id,
               request_id, object_id, dependent_request_id, dependent_object_id,
               created_by, creation_date, last_updated_by, last_update_date,
               last_update_login, object_version_Number)
               VALUES (p_undo_list_obj_def_id, p_request_id, p_object_id,
               updated_col.dependent_request_id, updated_col.dependent_object_id,
               pv_apps_user_id, sysdate, pv_apps_user_id, sysdate, pv_login_id,1);
            ELSE -- p_preview_flag = 'Y'
               INSERT INTO fem_ud_prview_dependents (ud_session_id,
               request_id, object_id, dependent_request_id, dependent_object_id,
               created_by, creation_date, last_updated_by, last_update_date,
               last_update_login, object_version_Number)
               VALUES (p_ud_session_id, p_request_id, p_object_id,
               updated_col.dependent_request_id, updated_col.dependent_object_id,
               pv_apps_user_id, sysdate, pv_apps_user_id, sysdate, pv_login_id,1);
            END IF;
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN NULL;
         END;

      END LOOP;

      IF v_count = 0 THEN
      -- If no UPDATE dependents found, post message
         fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
         p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
         p_app_name =>'FEM',
         p_msg_name => 'FEM_UD_NO_UPDATE_DEP_FOUND_TXT');
      END IF;

      -- Delete update dependent list from temporary tables as no longer needed.
      DELETE fem_ud_upd_dep_t WHERE upd_dep_calc_id = v_upd_dep_calc_id;
      DELETE fem_ud_upd_cols_t WHERE upd_dep_calc_id = v_upd_dep_calc_id;

   EXCEPTION
      WHEN e_cannot_gen_cand_upd_dep THEN
         ROLLBACK TO generate_cand_dependents_pub;

         BEGIN
           SELECT object_name
           INTO v_object_name
           FROM fem_object_catalog_vl
           WHERE object_id = p_object_id;
         EXCEPTION
           WHEN others THEN
             v_object_name := to_char(p_object_id);
         END;

         FEM_ENGINES_PKG.put_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UD_CANNOT_GEN_CAND_DEP_ERR',
            p_token1 => 'REQUEST_ID',
            p_value1 => p_request_id,
            p_token2 => 'OBJECT_NAME',
            p_value2 => v_object_name);

         FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data);
   END;

-- ============================================================================
-- STEP 3: Generate CHAIN dependents.
-- The current logic ignores p_ignore_dependency_errs_flag
-- Original logic: If p_ignore_dependency_errs_flag = 'Y', and p_dependency_type='ALL'
-- but chain dependents are found, THEN post an error message.
-- ============================================================================
   IF p_dependency_type = 'ALL' THEN
      fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
      p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
      p_msg_text => 'STEP 3: Generate CHAIN dependents.');

      v_count := 0;
      FOR achain IN c2 LOOP
      v_count := c2%ROWCOUNT;

         BEGIN

            IF  p_preview_flag = 'N' THEN
               INSERT INTO fem_ud_list_dependents (undo_list_obj_def_id, request_id,
               object_id, dependent_request_id, dependent_object_id, created_by, creation_date,
               last_updated_by, last_update_date, last_update_login, object_version_Number)
               VALUES (p_undo_list_obj_def_id, p_request_id, p_object_id, achain.request_id,
               achain.object_id, pv_apps_user_id, sysdate, pv_apps_user_id, sysdate,
               pv_login_id,1);
            ELSE -- p_preview_flag = 'Y'
               INSERT INTO fem_ud_prview_dependents (ud_session_id,
               request_id, object_id, dependent_request_id, dependent_object_id,
               created_by, creation_date, last_updated_by, last_update_date,
               last_update_login, object_version_number)
               VALUES (p_ud_session_id, p_request_id, p_object_id,
               achain.request_id, achain.object_id, pv_apps_user_id,
               sysdate, pv_apps_user_id, sysdate, pv_login_id,1);
            END IF;

         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN NULL;
         END;

      END LOOP;

      IF v_count = 0 THEN -- If no CHAIN dependents found, post message
         fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
         p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
         p_msg_name => 'FEM_UD_NO_CHAIN_DEP_FOUND_TXT');
      END IF;

   END IF;

-- ============================================================================
-- STEP 3.5: Generate dependents for "repeat" rule executions that
-- was run for the same rule, cal period, data set, etc. as the undo
-- candidate.  Only perform this in the Preview mode.
-- (Added to satisfy bug 5103063)
-- ============================================================================
   IF  p_preview_flag = 'Y' THEN
      IF (pc_log_level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
            p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
            p_msg_text => 'STEP 3.5: Generate "REPEAT" dependents.');
      END IF;

      v_count := 0;
      FOR repeat_execs IN c_repeat_execs(p_request_id, p_object_id) LOOP
         v_count := v_count + 1;
         BEGIN
            INSERT INTO fem_ud_prview_dependents
              (ud_session_id,request_id, object_id, dependent_request_id,
               dependent_object_id,created_by, creation_date, last_updated_by,
               last_update_date,last_update_login, object_version_Number)
            VALUES
              (p_ud_session_id, p_request_id, p_object_id, repeat_execs.request_id,
               repeat_execs.object_id, pv_apps_user_id, sysdate, pv_apps_user_id,
               sysdate, pv_login_id, 1);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN NULL;
         END;
      END LOOP;

      IF (pc_log_level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
            p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
            p_msg_text => 'STEP 3.5: Number of REPEAT dependencies found: '||v_count);
      END IF;
   END IF;

-- ============================================================================
-- STEP 4: Validate that user can undo dependents.
-- Note:  For undo lists (p_preview_flag = 'N'), when a dependent does
-- not pass validation, an error is raised and no other dependents are
-- validated.  For preview lists (p_preview_flag = 'Y'), when a dependent
-- does not pass validation, its status is set accordingly, and the program
-- continues validating all the other dependents. If one or more dependents
-- are found to not pass validation, the status of the candidate is set
-- accordingly.
-- ============================================================================

   IF p_preview_flag = 'N' THEN
      FOR a_dep IN c3 LOOP

      -- =========================================================================
      -- Validate that the user can execute (same as user can read) the dependent
      -- =========================================================================
         IF a_dep.folder_id IS NULL THEN
         -- User cannot read the dependent.
            RAISE e_cannot_read_object;
         END IF;

      -- =========================================================================
      -- Validate that the dependent is not 'RUNNING'.
      -- =========================================================================

         -- Bug 6443224. See earlier comment for this bug.
         BEGIN
            SELECT exec_status_code INTO v_exec_status_code
            FROM fem_pl_object_executions
            WHERE request_id = a_dep.dependent_request_id
            AND object_id = a_dep.dependent_object_id;

            IF v_exec_status_code = 'RUNNING' THEN
               -- Verify that the request is still running using
               -- fem_pl_pkg.set_exec_state
               fem_pl_pkg.set_exec_state (p_api_version => 1.0,
                  p_commit => fnd_api.g_true,
                  p_request_id => a_dep.dependent_request_id,
                  p_object_id => a_dep.dependent_object_id,
                  x_msg_count => x_msg_count,
                  x_msg_data => x_msg_data,
                  x_return_status => x_return_status);

               IF x_msg_count > 0 THEN
                  Get_Put_Messages(
                     p_msg_count       => x_msg_count,
                     p_msg_data        => x_msg_data,
                     p_user_msg        => 'N',
                     p_module          => 'fem.plsql.'||pc_pkg_name||'.'
                                        ||c_api_name);
               END IF;
            END IF;

            SELECT exec_status_code INTO v_exec_status_code
            FROM fem_pl_object_executions
            WHERE request_id = a_dep.dependent_request_id
            AND object_id = a_dep.dependent_object_id;
         EXCEPTION
            WHEN no_data_found THEN
               v_exec_status_code := 'NORMAL';
         END;

         IF v_exec_status_code = 'RUNNING'THEN
            RAISE e_objexec_is_running;
         END IF;

      END LOOP; -- End a_dep loop

   ELSIF p_preview_flag = 'Y' THEN

      v_count := 0;
      FOR a_prvw_dep IN c4 LOOP

      -- =========================================================================
      -- Validate that the user can execute (same as user can read) the dependent
      -- =========================================================================
         IF a_prvw_dep.folder_id IS NULL THEN
            v_count := v_count + 1;
            UPDATE fem_ud_prview_dependents
            SET validation_status_code = 'FEM_UD_CANNOT_READ_OBJECT_ERR',
            last_Update_date = sysdate, last_Updated_by = pv_apps_user_id
            WHERE ud_session_id = p_ud_session_id
            AND dependent_request_id = a_prvw_dep.dependent_request_id
            AND dependent_object_id = a_prvw_dep.dependent_object_id;

         ELSE -- Need to perform second validation only if it passes first one.
         -- =========================================================================
         -- Validate that the dependent is not 'RUNNING'.
         -- =========================================================================

            SELECT exec_status_code INTO v_exec_status_code
            FROM fem_pl_object_executions
            WHERE request_id = a_prvw_dep.dependent_request_id
            AND object_id = a_prvw_dep.dependent_object_id;

            IF v_exec_status_code = 'RUNNING' THEN
            -- Verify that the request is still running using fem_pl_pkg.set_exec_state

               fem_pl_pkg.set_exec_state (p_api_version => 1.0,
                  p_commit => fnd_api.g_true,
                  p_request_id => a_prvw_dep.dependent_request_id,
                  p_object_id => a_prvw_dep.dependent_object_id,
                  x_msg_count => x_msg_count,
                  x_msg_data => x_msg_data,
                  x_return_status => x_return_status);

               IF x_msg_count > 0 THEN
                  Get_Put_Messages(
                     p_msg_count       => x_msg_count,
                     p_msg_data        => x_msg_data,
                     p_user_msg        => 'N',
                     p_module          => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name);
               END IF;
            END IF;

            SELECT exec_status_code INTO v_exec_status_code
            FROM fem_pl_object_executions
            WHERE request_id = a_prvw_dep.dependent_request_id
            AND object_id = a_prvw_dep.dependent_object_id;

            IF v_exec_status_code = 'RUNNING' THEN
               v_count := v_count + 1;
               UPDATE fem_ud_prview_dependents
               SET validation_status_code = 'FEM_UD_OBJEXEC_IS_RUNNING_ERR',
               last_Update_date = sysdate, last_updated_by = pv_apps_user_id
               WHERE ud_session_id = p_ud_session_id
               AND dependent_request_id = a_prvw_dep.dependent_request_id
               AND dependent_object_id = a_prvw_dep.dependent_object_id;
            END IF;
         END IF;
      END LOOP; -- End a_prvw_dep loop

      -- Set validation status of dependents that passed validation to 'VALID'
      UPDATE fem_ud_prview_dependents
      SET validation_status_code = 'FEM_UD_VALID_TXT',
      last_update_date = sysdate, last_updated_By = pv_apps_user_id
      WHERE ud_session_id = p_ud_session_id
      AND request_id = p_request_id
      AND object_id = p_object_id
      AND validation_status_code IS NULL;

   END IF;

   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   fem_engines_pkg.tech_message(p_severity => pc_log_level_procedure,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'End. x_return_status: '||x_return_status);

   FND_MSG_PUB.Count_And_Get
      (p_count => x_msg_count,
       p_data  => x_msg_data);

   EXCEPTION
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO generate_cand_dependents_pub;
         x_return_status := pc_ret_sts_unexp_error;

         fem_engines_pkg.tech_message(p_severity => pc_log_level_unexpected,
         p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
         p_app_name =>'FEM',
         p_msg_name => 'FEM_BAD_P_API_VER_ERR',p_token1 => 'VALUE',
         p_value1 => p_api_version, p_trans1 => 'N');

         fem_engines_pkg.put_message(
         p_app_name =>'FEM',
         p_msg_name => 'FEM_BAD_P_API_VER_ERR',p_token1 => 'VALUE',
         p_value1 => p_api_version, p_trans1 => 'N');

         FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data);

      WHEN e_invalid_preview_flag THEN
         x_return_status := pc_ret_sts_error;

         FEM_ENGINES_PKG.put_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UD_INVALID_PREVIEW_FLAG');

         FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data);

      WHEN e_invalid_undolist_objdefid THEN
         x_return_status := pc_ret_sts_error;

         FEM_ENGINES_PKG.put_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UD_INVALID_UDLISTOBJDEFID');

         FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data);

      WHEN e_invalid_dependency_type THEN
         x_return_status := pc_ret_sts_error;

         FEM_ENGINES_PKG.put_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UD_INVALID_DEPENDENCY_TYPE');

         FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data);

      WHEN e_invalid_session_id THEN
         x_return_status := pc_ret_sts_error;

         FEM_ENGINES_PKG.put_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UD_INVALID_SESSIONID');

         FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data);

      WHEN e_objexec_is_running THEN
         x_return_status := pc_ret_sts_error;

         FEM_ENGINES_PKG.put_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UD_OBJEXEC_IS_RUNNING_ERR');

         FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data);

      WHEN e_cannot_read_object THEN
         x_return_status := pc_ret_sts_error;

         FEM_ENGINES_PKG.put_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UD_CANNOT_READ_OBJECT_ERR');

         FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data);

      WHEN OTHERS THEN
      -- Unexpected exceptions
         x_return_status := pc_ret_sts_unexp_error;

      -- Log the call stack and the Oracle error message to
      -- FND_LOG with the "unexpected exception" severity level.

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_unexpected,
            p_module   => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
            p_msg_text => SQLERRM);

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_unexpected,
            p_module   => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
            p_msg_text => dbms_utility.format_call_stack);

      -- Log the Oracle error message to the stack.
         FEM_ENGINES_PKG.put_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UNEXPECTED_ERROR',
            P_TOKEN1 => 'ERR_MSG',
            P_VALUE1 => SQLERRM);

         FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data);

         ROLLBACK TO generate_cand_dependents_pub;
END generate_cand_dependents;
-- *****************************************************************************
PROCEDURE validate_candidates           (x_return_status                OUT NOCOPY VARCHAR2,
                                         x_msg_count                    OUT NOCOPY NUMBER,
                                         x_msg_data                     OUT NOCOPY VARCHAR2,
                                         p_api_version                  IN  NUMBER,
                                         p_commit                       IN  VARCHAR2,
                                         p_undo_list_obj_def_id         IN  NUMBER DEFAULT NULL,
                                         p_dependency_type              IN  VARCHAR2,
                                         p_ud_session_id                IN  NUMBER DEFAULT NULL,
                                         p_preview_flag                 IN  VARCHAR2 DEFAULT 'N') AS
-- ============================================================================
-- PUBLIC
-- This procedure validates all object executions that in the specified undo
-- list or specified undo session.  It also generates and validates all
-- dependent object executions.
-- ============================================================================
c_api_name  CONSTANT VARCHAR2(30) := 'validate_candidates';
c_api_version  CONSTANT NUMBER := 2.0;
v_count NUMBER := 0;
v_count_candidates NUMBER:=0;
v_exec_status_code VARCHAR2(30);

-- This cursor retrieves all candidates in an undo list that have not yet been processed.
CURSOR c1 IS
   SELECT request_id, object_id
   FROM fem_ud_list_candidates
   WHERE undo_list_obj_def_id = p_undo_list_obj_def_id
   AND (exec_status_code IS NULL OR
    exec_status_code <> 'SUCCESS');

-- This cursor retrieves all candidates in an undo list session
CURSOR c2 IS
   SELECT request_id, object_id
   FROM fem_ud_prview_candidates
   WHERE ud_session_id = p_ud_session_id;

BEGIN

   fem_engines_pkg.tech_message(p_severity => pc_log_level_procedure,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'Begin.  P_COMMIT:'||p_commit||
   ' P_PREVIEW_FLAG: '||p_preview_flag||
   ' P_UD_SESSION_ID: '||p_ud_session_id||
   ' P_UNDO_LIST_OBJ_DEF_ID: '||p_undo_list_obj_def_id||
   ' P_DEPENDENCY_TYPE: '||p_dependency_type);

   -- Standard Start of API savepoint
   SAVEPOINT  validate_candidates_pub;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (c_api_version,
                  p_api_version,
                  c_api_name,
                  pc_pkg_name)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --  Initialize API return status to success
   x_return_status := pc_ret_sts_success;

-- ============================================================================
-- == VALIDATIONS: Validate input parameters
-- ============================================================================
-- STEP V1: Validate p_preview_flag
-- ============================================================================

   IF p_preview_flag NOT IN ('N','Y') THEN
      RAISE e_invalid_preview_flag;
   END IF;
-- ============================================================================
-- STEP V2: Validate p_ud_session_id
-- ============================================================================

   IF p_preview_flag = 'Y' AND p_ud_session_id IS NULL THEN
      RAISE e_invalid_session_id;
   END IF;

-- ============================================================================
-- STEP V3: Validate p_undo_list_obj_def_id
-- ============================================================================
   IF p_preview_flag = 'N' AND p_undo_list_obj_def_id IS NULL THEN
      RAISE e_invalid_undolist_objdefid;
   END IF;

-- ============================================================================
-- Validate candidates.
-- ============================================================================
   v_count_candidates := 0;
   IF p_preview_flag = 'N' THEN
      fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
      p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
      p_msg_text => 'I am in the section where p_preview_flag = ''N''.');

      FOR a_candidate IN c1 LOOP
         v_count_candidates := c1%ROWCOUNT;

         fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
         p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
         p_msg_text => 'Candidate number:'||v_count_candidates||' REQUEST_ID:'||a_candidate.request_id||
         ' OBJECT_ID:'||a_candidate.object_id);
         -- ============================================================================
         -- V1: Check to make sure user can execute/read the object.
         -- ============================================================================
            fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
            p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
            p_msg_text => 'Checking to make sure user can read/execute the object');

            SELECT  count(*) INTO v_count
            FROM fem_user_folders u, fem_object_catalog_b o
            WHERE o.object_id = a_candidate.object_id
            AND o.folder_id = u.folder_id
            AND u.user_id = pv_apps_user_id;

            IF v_count = 0 THEN
               RAISE e_cannot_read_object;
            END IF;

         -- ============================================================================
         -- V2: Check to make sure object execution is not RUNNING.
         -- ============================================================================
            fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
            p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
            p_msg_text => 'Checking to make sure object is not ''RUNNING''');

            -- Bug 6443224. See earlier comment for this bug.
            BEGIN
               SELECT exec_status_code INTO v_exec_status_code
               FROM fem_pl_object_executions
               WHERE request_id = a_candidate.request_id
               AND object_id = a_candidate.object_id;

               IF v_exec_status_code = 'RUNNING' THEN
                  -- Verify that the request is still running using
                  -- fem_pl_pkg.set_exec_state
                  fem_pl_pkg.set_exec_state (p_api_version => 1.0,
                     p_commit => p_commit,
                     p_request_id => a_candidate.request_id,
                     p_object_id => a_candidate.object_id,
                     x_msg_count => x_msg_count,
                     x_msg_data => x_msg_data,
                     x_return_status => x_return_status);

                  IF x_msg_count > 0 THEN
                     Get_Put_Messages(
                        p_msg_count       => x_msg_count,
                        p_msg_data        => x_msg_data,
                        p_user_msg        => 'N',
                        p_module          => 'fem.plsql.'||pc_pkg_name||'.'
                                            ||c_api_name);
                  END IF;
               END IF;

               SELECT exec_status_code INTO v_exec_status_code
               FROM fem_pl_object_executions
               WHERE request_id = a_candidate.request_id
               AND object_id = a_candidate.object_id;
            EXCEPTION
               WHEN no_data_found THEN
                  v_exec_status_code := 'NORMAL';
            END;

            IF v_exec_status_code = 'RUNNING' THEN
               RAISE e_objexec_is_running;
            END IF;

         -- ============================================================================
         -- V3: Check to make sure user can undo all the candidate's dependents.
         -- ============================================================================
            fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
            p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
            p_msg_text => 'Checking to make sure can undo all candidate''s dependents');

            generate_cand_dependents (
               p_api_version                  => 2.0,
               p_commit                       => p_commit,
               p_undo_list_obj_def_id         => p_undo_list_obj_def_id,
               p_request_id                   => a_candidate.request_id,
               p_object_id                    => a_candidate.object_id,
               p_dependency_type              => p_dependency_type,
               p_preview_flag                 => 'N',
               x_return_status                => x_return_status,
               x_msg_count                    => x_msg_count,
               x_msg_data                     => x_msg_data);

            IF x_return_status <> pc_ret_sts_success THEN
               RAISE e_cannot_validate_dependents;
            END IF;
      END LOOP;
   ELSE -- p_preview_flag = 'Y'
      fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
      p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
      p_msg_text => 'I am in the section where p_preview_flag = ''Y''.');

      FOR a_candidate IN c2 LOOP
         v_count_candidates := c2%ROWCOUNT;

         fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
         p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
         p_msg_text => 'Candidate number:'||v_count_candidates||' REQUEST_ID:'||a_candidate.request_id||
         ' OBJECT_ID:'||a_candidate.object_id);
         BEGIN
         -- ============================================================================
         -- V1: Check to make sure user can execute/read the object.
         -- ============================================================================
            fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
            p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
            p_msg_text => 'Checking to make sure user can read/execute the object');

            SELECT  count(*) INTO v_count
            FROM fem_user_folders u, fem_object_catalog_b o
            WHERE o.object_id = a_candidate.object_id
            AND o.folder_id = u.folder_id
            AND u.user_id = pv_apps_user_id;

            IF v_count = 0 THEN
               RAISE e_cannot_read_object;
            END IF;

         -- ============================================================================
         -- V2: Check to make sure object execution is not RUNNING.
         -- ============================================================================
            fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
            p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
            p_msg_text => 'Checking to make sure object is not ''RUNNING''');

            -- Bug 6443224. See earlier comment for this bug.
            BEGIN
               SELECT exec_status_code INTO v_exec_status_code
               FROM fem_pl_object_executions
               WHERE request_id = a_candidate.request_id
               AND object_id = a_candidate.object_id;

               IF v_exec_status_code = 'RUNNING' THEN
                  -- Verify that the request is still running using
                  --fem_pl_pkg.set_exec_state
                  fem_pl_pkg.set_exec_state (p_api_version => 1.0,
                     p_commit => p_commit,
                     p_request_id => a_candidate.request_id,
                     p_object_id => a_candidate.object_id,
                     x_msg_count => x_msg_count,
                     x_msg_data => x_msg_data,
                     x_return_status => x_return_status);

                  IF x_msg_count > 0 THEN
                     Get_Put_Messages(
                        p_msg_count       => x_msg_count,
                        p_msg_data        => x_msg_data,
                        p_user_msg        => 'N',
                        p_module          => 'fem.plsql.'||pc_pkg_name||'.'
                                            ||c_api_name);
                  END IF;
               END IF;

               SELECT exec_status_code INTO v_exec_status_code
               FROM fem_pl_object_executions
               WHERE request_id = a_candidate.request_id
               AND object_id = a_candidate.object_id;
            EXCEPTION
               WHEN no_data_found THEN
                  v_exec_status_code := 'NORMAL';
            END;

            IF v_exec_status_code = 'RUNNING' THEN
               RAISE e_objexec_is_running;
            END IF;

         -- ============================================================================
         -- V3: Check to make sure user can undo all the candidate's dependents.
         -- ============================================================================
            fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
            p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
            p_msg_text => 'Checking to make sure can undo all candidate''s dependents');

            generate_cand_dependents (
               p_api_version                  => 2.0,
               p_commit                       => p_commit,
               p_ud_session_id                => p_ud_session_id,
               p_request_id                   => a_candidate.request_id,
               p_object_id                    => a_candidate.object_id,
               p_dependency_type              => p_dependency_type,
               p_preview_flag                 => 'Y',
               x_return_status                => x_return_status,
               x_msg_count                    => x_msg_count,
               x_msg_data                     => x_msg_data);

            IF x_return_status <> pc_ret_sts_success THEN
               RAISE e_cannot_validate_dependents;
            END IF;

         -- ============================================================================
         -- Since the candidate has passed all validations, set its validation
         -- status code = 'FEM_UD_VALID_TXT'.
         -- ============================================================================
         fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
         p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
         p_msg_text => 'Set candidate''s status to ''FEM_UD_VALID_TXT''');

            UPDATE fem_ud_prview_candidates
            SET validation_status_code = 'FEM_UD_VALID_TXT',
            last_update_date = sysdate, last_Updated_by = pv_apps_user_id
            WHERE ud_session_id = p_ud_session_id
            AND request_id = a_candidate.request_id
            AND object_id = a_candidate.object_id;

         EXCEPTION
            WHEN e_cannot_read_object THEN
               UPDATE fem_ud_prview_candidates
               SET validation_status_code = 'FEM_UD_CANNOT_READ_OBJECT_ERR',
               last_update_date = sysdate, last_Updated_by = pv_apps_user_id
               WHERE ud_session_id = p_ud_session_id
               AND request_id = a_candidate.request_id
               AND object_id = a_candidate.object_id;
            WHEN e_objexec_is_running THEN
               UPDATE fem_ud_prview_candidates
               SET validation_status_code = 'FEM_UD_OBJEXEC_IS_RUNNING_ERR',
               last_update_date = sysdate, last_updated_by = pv_apps_user_id
               WHERE ud_session_id = p_ud_session_id
               AND request_id = a_candidate.request_id
               AND object_id = a_candidate.object_id;
            WHEN e_cannot_validate_dependents THEN
               UPDATE fem_ud_prview_candidates
               SET validation_status_code = 'FEM_UD_CANNOT_UNDO_DEPENDENTS',
               last_update_date = sysdate, last_Updated_by = pv_apps_user_id
               WHERE ud_session_id = p_ud_session_id
               AND request_id = a_candidate.request_id
               AND object_id = a_candidate.object_id;
         END;

      END LOOP;

   END IF;

   IF v_count_candidates = 0 THEN
      x_return_status := pc_ret_sts_error;
      RAISE e_list_has_no_candidates;
   ELSE
      x_return_status := pc_ret_sts_success;
   END IF;

   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   fem_engines_pkg.tech_message(p_severity => pc_log_level_procedure,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'End. X_RETURN_STATUS: '||x_return_status);

   EXCEPTION
      WHEN e_invalid_preview_flag THEN
         x_return_status := pc_ret_sts_error;

         FEM_ENGINES_PKG.put_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UD_INVALID_PREVIEW_FLAG');

         FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data);
      WHEN e_invalid_undolist_objdefid THEN
         x_return_status := pc_ret_sts_error;

         FEM_ENGINES_PKG.put_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UD_INVALID_UDLISTOBJDEFID');

         FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data);
      WHEN e_invalid_session_id THEN
         x_return_status := pc_ret_sts_error;

         FEM_ENGINES_PKG.put_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UD_INVALID_SESSIONID');

         FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data);
      WHEN e_cannot_validate_dependents THEN
         x_return_status := pc_ret_sts_error;

         FEM_ENGINES_PKG.put_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UD_CANNOT_UNDO_DEPENDENTS');

         FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data);
      WHEN e_cannot_read_object THEN
         x_return_status := pc_ret_sts_error;

         FEM_ENGINES_PKG.put_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UD_CANNOT_READ_OBJECT_ERR');

         FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data);
      WHEN e_objexec_is_running THEN
         x_return_status := pc_ret_sts_error;

         FEM_ENGINES_PKG.put_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UD_OBJEXEC_IS_RUNNING_ERR');

         FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data);
      WHEN e_list_has_no_candidates THEN
         ROLLBACK TO validate_candidates_pub;
         x_return_status := pc_ret_sts_error;

         FEM_ENGINES_PKG.put_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UD_NO_CANDIDATES_ERR');

         fem_engines_pkg.tech_message(p_severity => pc_log_level_error,
         p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
         p_app_name =>'FEM',
         p_msg_name => 'FEM_UD_NO_CANDIDATES_ERR');

         FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO validate_candidates_pub;
         x_return_status := pc_ret_sts_unexp_error;

         fem_engines_pkg.tech_message(p_severity => pc_log_level_unexpected,
         p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
         p_app_name =>'FEM',
         p_msg_name => 'FEM_BAD_P_API_VER_ERR',p_token1 => 'VALUE',
         p_value1 => p_api_version, p_trans1 => 'N');

      WHEN OTHERS THEN
      -- Unexpected exceptions
         x_return_status := pc_ret_sts_unexp_error;

      -- Log the call stack and the Oracle error message to
      -- FND_LOG with the "unexpected exception" severity level.

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_unexpected,
            p_module   => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
            p_msg_text => SQLERRM);

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_unexpected,
            p_module   => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
            p_msg_text => dbms_utility.format_call_stack);

      -- Log the Oracle error message to the stack.
         FEM_ENGINES_PKG.put_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UNEXPECTED_ERROR',
            P_TOKEN1 => 'ERR_MSG',
            P_VALUE1 => SQLERRM);

         FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data);

         ROLLBACK TO validate_candidates_pub;
END validate_candidates;
-- *****************************************************************************
-- *****************************************************************************
PROCEDURE perform_undo_actions          (x_return_status                OUT NOCOPY VARCHAR2,
                                         p_undo_list_obj_def_id         IN  NUMBER,
                                         p_obj_exec_type                IN  VARCHAR2,
                                         p_request_id                   IN  NUMBER,
                                         p_object_id                    IN  NUMBER) AS

-- ============================================================================
-- PUBLIC
-- This is the main procedure of the 'Undo Engine' that processes each
-- object execution.
-- ============================================================================
c_api_name  CONSTANT VARCHAR2(30) := 'perform_undo_actions';
v_sql_stmt      VARCHAR2(2000);
v_where_clause  VARCHAR2(2000);
v_count_tbls    NUMBER := 0;
v_count_cols    NUMBER := 0;
v_object_type_code   VARCHAR2(30);
v_obj_exec_status VARCHAR2(30);
v_mp_step_name  VARCHAR2(30);
v_mp_prg_stat VARCHAR2(100);
v_mp_exception_code VARCHAR2(30);
v_mp_stmt_id VARCHAR2(40);
v_undo_list_obj_id NUMBER;
v_rows_processed NUMBER;
v_undo_flag VARCHAR2(1);
v_msg_count NUMBER;
v_msg_data VARCHAR2(32000);
v_tab_name FEM_PL_TABLES.table_name%TYPE;
v_tab_class FEM_TABLE_CLASS_ASSIGNMT.table_classification_code%TYPE;
v_stmt_type FEM_PL_TABLES.statement_type%TYPE;
v_col_name FEM_PL_TAB_UPDATED_COLS.column_name%TYPE;
v_object_name FEM_OBJECT_CATALOG_VL.object_name%TYPE;

-- Returns a distinct list of tables and undo actions
CURSOR c1 IS
   SELECT distinct p.statement_type, p.table_name,
          max(t.undo_type) over (partition by p.table_name)
            undo_type,
          DECODE(p.statement_type, 'INSERT','DELETE','MERGE',
                 'INSERT and DELETE','UPDATE') undo_statement_type
   FROM fem_pl_tables p,
        (select decode(table_classification_code,
                      'TRANSACTION_PROFITABILITY','ZERO_COLUMN_BY_OBJECT',
                      'CUSTOMER_PROFIT_RESULT','ZERO_COLUMN_BY_OBJECT',
                      'ACCOUNT_PROFITABILITY','ZERO_COLUMN_BY_PERIOD',
                      'FTP_CASH_FLOW','ZERO_COLUMN_BY_PERIOD',
                      'FTP_NON_CASH_FLOW','ZERO_COLUMN_BY_PERIOD',
                      'FTP_OPTION_COST','ZERO_COLUMN_BY_PERIOD',NULL)
                undo_type, table_name
         from fem_table_class_assignmt_v) t
   WHERE p.request_id = p_request_id
   AND p.object_id = p_object_id
   AND p.table_name = t.table_name(+)
   ORDER BY table_name, statement_type;

CURSOR c2 (v_table_name IN VARCHAR2, v_statement_type IN VARCHAR2) IS
   SELECT column_name AS colname
   FROM fem_pl_tab_updated_cols
   WHERE request_id = p_request_id
   AND object_id = p_object_id
   AND table_name = v_table_name
   AND statement_type = v_statement_type
   ORDER BY column_name;

BEGIN

   fem_engines_pkg.tech_message(p_severity => pc_log_level_procedure,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'Begin. P_UNDO_LIST_OBJ_DEF_ID: '||p_undo_list_obj_def_id||
   ' P_REQUEST_ID: '||p_request_id||
   ' P_OBJECT_ID: '||p_object_id||
   ' P_OBJ_EXEC_TYPE: '||p_obj_exec_type);

   --  Initialize return status to success
   x_return_status := pc_ret_sts_success;

   -- Retrieve object_type of the object execution.
   BEGIN
      SELECT o.object_type_code, t.undo_flag
      INTO v_object_type_code, v_undo_flag
      FROM fem_object_catalog_b o, fem_object_types t
      WHERE o.object_id = p_object_id
      AND t.object_type_code = o.object_type_code;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN

         fem_engines_pkg.tech_message(p_severity => pc_log_level_event,
         p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
         p_msg_text => 'Could not retrieve OBJECT_TYPE_CODE for OBJECT_ID: '||p_object_id);

   END;

   -- Retrieve undo list object id
   SELECT object_id INTO v_undo_list_obj_id
   FROM fem_object_definition_b
   WHERE object_definition_id = p_undo_list_obj_def_id;

-- ============================================================================
-- STEP 1:
-- Set status of object execution in undo list to 'RUNNING'.
-- ============================================================================
   fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'STEP 1: Set status of object execution in undo list to ''RUNNING''');

   -- Get rule name
   BEGIN
     SELECT object_name
     INTO v_object_name
     FROM fem_object_catalog_vl
     WHERE object_id = p_object_id;
   EXCEPTION
     WHEN others THEN
       v_object_name := to_char(p_object_id);
   END;

   fem_engines_pkg.user_message(p_app_name =>'FEM',
     p_msg_name => 'FEM_UD_PROCESSING_OBJEXEC_TXT',
     p_token1 => 'RULE_NAME',
     p_value1 => v_object_name,
     p_token2 => 'REQUEST_ID',
     p_value2 => p_request_id);

   fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
     p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
     p_app_name =>'FEM',
     p_msg_name => 'FEM_UD_PROCESSING_OBJEXEC_TXT',
     p_token1 => 'RULE_NAME',
     p_value1 => v_object_name,
     p_token2 => 'REQUEST_ID',
     p_value2 => p_request_id);

   IF p_obj_exec_type = 'DEPENDENT' THEN
      UPDATE fem_ud_list_dependents
      SET exec_status_code = 'RUNNING',
      last_update_date = sysdate, last_updated_by = pv_apps_user_id
      WHERE undo_list_obj_def_id = p_undo_list_obj_def_id
      AND dependent_request_id = p_request_id
      AND dependent_object_id = p_object_id;
   ELSE
   -- p_obj_exec_type = 'CANDIDATE'
      UPDATE fem_ud_list_candidates
      SET exec_status_code = 'RUNNING',
      last_update_date = sysdate, last_Updated_by = pv_apps_user_id
      WHERE undo_list_obj_def_id = p_undo_list_obj_def_id
      AND request_id = p_request_id
      AND object_id = p_object_id;
   END IF;
   COMMIT;

   IF v_undo_flag = 'N' THEN

      fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
      p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
      p_msg_text => 'v_undo_flag:'||v_undo_flag||' IGNORE Step 2:Process statements in FEM_PL_TABLES');

   ELSE

-- ============================================================================
-- STEP 2:
-- Process statements in FEM_PL_TABLES.
-- ============================================================================
      fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
      p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
      p_msg_text => 'STEP 2: Process statements in FEM_PL_TABLES');

      FOR atbl IN C1 LOOP
      fem_engines_pkg.tech_message(p_severity => pc_log_level_event,
      p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
      p_app_name => 'FEM',
      p_msg_name => 'FEM_UD_TABLE_STATEMENT_TXT',
      p_token1 => 'TABLE_NAME',
      p_value1 => atbl.table_name,
      p_trans1 => 'N',
      p_token2 => 'STATEMENT_TYPE',
      p_value2 => atbl.undo_statement_type,
      p_trans2 => 'N');


      -- set variables for error message
      v_tab_name := atbl.table_name;
      v_stmt_type := atbl.statement_type;

         -- Determine MP step name
         BEGIN
            SELECT max(decode(table_classification_code,'GENERIC_DATA_TABLE',
                          'GENERIC_DATA_TABLE','LEDGER')) INTO v_mp_step_name
            FROM fem_table_class_assignmt_v
            WHERE (table_classification_code = 'GENERIC_DATA_TABLE'
                OR table_classification_code like '%LEDGER')
            AND table_name = atbl.table_name;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_mp_step_name := 'ALL';
         END;

         v_count_tbls := c1%ROWCOUNT;

         IF atbl.statement_type = 'INSERT' THEN
   -- ============================================================================
   -- S2A: Process statements in FEM_PL_TABLES (INSERT statement section)
   -- ============================================================================

            -- Bug 5738732: Added {{table_partition}} token
            v_sql_stmt := 'DELETE '||atbl.table_name||' {{table_partition}} ';
            v_where_clause := ' CREATED_BY_REQUEST_ID = '||p_request_id||
               ' AND CREATED_BY_OBJECT_ID = '||p_object_id;

            v_sql_stmt := v_sql_stmt||' WHERE '||v_where_clause||' AND {{data_slice}} ';
            v_mp_stmt_id := atbl.table_name||'_DELETE_'||v_count_tbls;

            -- submit statement to MP engine.
            -- EXECUTE IMMEDIATE v_sql_stmt||' '||v_where_clause; (pre MP testing)
            fem_multi_proc_pkg.master(
               x_prg_stat       => v_mp_prg_stat,
               x_exception_code => v_mp_exception_code,
               p_rule_id        => v_undo_list_obj_id,
               p_eng_step       => v_mp_step_name,
               p_data_table     => atbl.table_name,
               p_eng_sql        => v_sql_stmt,
               p_run_name       => v_mp_stmt_id,
               p_condition      => v_where_clause);

            IF v_mp_prg_stat = 'COMPLETE:NORMAL' THEN
               -- retrieve number of rows processed and send technical message.
               SELECT NVL(SUM(rows_processed),0)
               INTO v_rows_processed
               FROM fem_mp_process_ctl_t
               WHERE req_id = pv_request_id;

               fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
               p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
               p_msg_text => 'Number of rows processed:'||v_rows_processed||' ');

            ELSIF v_mp_exception_code = 'FEM_MP_NO_DATA_SLICES_ERR' THEN
               v_rows_processed := 0;

               fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
               p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
               p_msg_text => 'Number of rows processed: 0');

            ELSE
               fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
               p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
               p_msg_text => 'MP framework return status:'||v_mp_prg_stat||
               ' MP exception code:'||v_mp_exception_code||' SQL statement: '||v_sql_stmt);

               RAISE e_mp_error;

            END IF;

            fem_engines_pkg.user_message(p_app_name =>'FEM',
                 p_msg_name => 'FEM_UD_DELETE_SUMMARY_TXT',
                 p_token1 => 'NUM_ROWS',
                 p_value1 => v_rows_processed,
                 p_token2 => 'TABLE_NAME',
                 p_value2 => v_tab_name);

            fem_multi_proc_pkg.delete_data_slices(
               p_req_id       => pv_request_id);

         ELSIF atbl.statement_type = 'UPDATE' AND
               atbl.undo_type IN ('ZERO_COLUMN_BY_PERIOD',
                                  'ZERO_COLUMN_BY_OBJECT') THEN
   -- ============================================================================
   -- S2B: Process statements in FEM_PL_TABLES (UPDATE statement section)
   -- For the FEM.D release. Update statements are only processed for
   -- tables that belong to classifications that allow the undo of updates.
   -- The list of classifications is currently hard-coded for FEM.D and
   -- will be metadata driven in the future.  For now, the list can be
   -- determined by looking at the "c1" cursor definition.
   -- ============================================================================

            v_sql_stmt := 'UPDATE '||atbl.table_name
                                   ||' {{table_partition}} SET';

            FOR acol IN c2(atbl.table_name, atbl.statement_type) LOOP
               v_count_cols := c2%ROWCOUNT;  -- Set counter to indicate that at least one column found.

               IF v_count_cols = 1 THEN -- If this is first row
                  v_sql_stmt := v_sql_stmt||' '||acol.colname||'=0';
               ELSE
                  v_sql_stmt := v_sql_stmt||', '||acol.colname||'=0';
               END IF;

            END LOOP;

            IF v_count_cols = 0 THEN
            -- No column found

               fem_engines_pkg.tech_message(p_severity => pc_log_level_exception,
               p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
               p_app_name =>'FEM',
               p_msg_name => 'FEM_UD_NO_UPD_COL_FOUND_WRN');

            ELSE
            -- at least one column exists
               IF atbl.undo_type = 'ZERO_COLUMN_BY_PERIOD' THEN
                  SELECT ' CAL_PERIOD_ID = '||cal_period_id||
                     ' AND LEDGER_ID = '||ledger_id||
                     ' AND DATASET_CODE = '||output_dataset_code
                  INTO v_where_clause
                  FROM fem_pl_requests
                  WHERE request_id = p_request_id;
               ELSE -- atbl.undo_type = 'ZERO_COLUMN_BY_OBJECT'
                  v_where_clause := ' LAST_UPDATED_BY_REQUEST_ID = '||p_request_id||
                                    ' AND LAST_UPDATED_BY_OBJECT_ID = '||p_object_id;
               END IF;
               -- prepare statement
               v_sql_stmt := v_sql_stmt||' WHERE '||v_where_clause||' AND {{data_slice}} ';
               v_mp_stmt_id := atbl.table_name||'_UPDATE_'||v_count_tbls;

               -- submit statement to MP engine.
               -- EXECUTE IMMEDIATE v_sql_stmt||' '||v_where_clause; (pre MP testing)
               fem_multi_proc_pkg.master(
                  x_prg_stat       => v_mp_prg_stat,
                  x_exception_code => v_mp_exception_code,
                  p_rule_id        => v_undo_list_obj_id,
                  p_eng_step       => v_mp_step_name,
                  p_data_table     => atbl.table_name,
                  p_eng_sql        => v_sql_stmt,
                  p_run_name       => v_mp_stmt_id,
                  p_condition      => v_where_clause);

               IF v_mp_prg_stat = 'COMPLETE:NORMAL' THEN
                  -- retrieve number of rows processed and send technical message.
                  SELECT NVL(SUM(rows_processed),0)
                  INTO v_rows_processed
                  FROM fem_mp_process_ctl_t
                  WHERE req_id = pv_request_id;

                  fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
                  p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
                  p_msg_text => 'Number of rows processed:'||v_rows_processed||' ');
               ELSIF v_mp_exception_code = 'FEM_MP_NO_DATA_SLICES_ERR' THEN
                  v_rows_processed := 0;

                  fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
                  p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
                  p_msg_text => 'Number of rows processed: 0');
               ELSE
                  fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
                  p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
                  p_msg_text => 'MP framework return status:'||v_mp_prg_stat||
                  ' MP exception code:'||v_mp_exception_code||' SQL statement: '||v_sql_stmt);

                  RAISE e_mp_error;
               END IF;

               fem_engines_pkg.user_message(p_app_name =>'FEM',
                 p_msg_name => 'FEM_UD_UPDATE_SUMMARY_TXT',
                 p_token1 => 'NUM_ROWS',
                 p_value1 => v_rows_processed,
                 p_token2 => 'TABLE_NAME',
                 p_value2 => v_tab_name);

            END IF;

            fem_multi_proc_pkg.delete_data_slices(
               p_req_id       => pv_request_id);

         ELSIF atbl.statement_type = 'MERGE' THEN
         -- For Merge statements, do a DELETE and an UPDATE.
   -- =========================================================================
   -- S2C: Process statements in FEM_PL_TABLES (MERGE statement section)
   -- Undo handles MERGE statements with the same logic as undoing an INSERT
   -- statement followed by the undoing of an UPDATE statement (using the
   -- same undo logic as above for the individual statements).
   -- =========================================================================

            -- Test to make sure that if Rule registered update columns,
            -- that the table being updated is an undo type that
            -- this undo program knows how to handle
            OPEN c2(atbl.table_name, atbl.statement_type);
            FETCH c2 INTO v_col_name;
            -- If no columns, then do not do update, just delete
            IF c2%NOTFOUND THEN
              CLOSE c2;
            ELSE
              CLOSE c2;
              IF nvl(atbl.undo_type,'XX') NOT IN
                                          ('ZERO_COLUMN_BY_OBJECT',
                                           'ZERO_COLUMN_BY_PERIOD') THEN
                RAISE e_undo_action_not_supported;
              END IF;
            END IF;

            ------------------
            -- DELETE statement
            ------------------
            v_sql_stmt := 'DELETE '||atbl.table_name||' {{table_partition}} ';
            v_where_clause := ' CREATED_BY_REQUEST_ID = '||p_request_id||
               ' AND CREATED_BY_OBJECT_ID = '||p_object_id;

            -- prepare statement
            v_sql_stmt := v_sql_stmt||' WHERE '||v_where_clause||' AND {{data_slice}} ';
            v_mp_stmt_id := atbl.table_name||'_MERGE_DEL_'||v_count_tbls;

            -- submit statement to MP engine.
            -- EXECUTE IMMEDIATE v_sql_stmt||' '||v_where_clause; (pre MP testing)
            fem_multi_proc_pkg.master(
               x_prg_stat       => v_mp_prg_stat,
               x_exception_code => v_mp_exception_code,
               p_rule_id        => v_undo_list_obj_id,
               p_eng_step       => v_mp_step_name,
               p_data_table     => atbl.table_name,
               p_eng_sql        => v_sql_stmt,
               p_run_name       => v_mp_stmt_id,
               p_condition      => v_where_clause);

            IF v_mp_prg_stat = 'COMPLETE:NORMAL' THEN
               -- retrieve number of rows processed and send technical message.
               SELECT NVL(SUM(rows_processed),0)
               INTO v_rows_processed
               FROM fem_mp_process_ctl_t
               WHERE req_id = pv_request_id;

               fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
               p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
               p_msg_text => 'Number of rows processed:'||v_rows_processed||' ');
            ELSIF v_mp_exception_code = 'FEM_MP_NO_DATA_SLICES_ERR' THEN
               v_rows_processed := 0;

               fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
               p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
               p_msg_text => 'Number of rows processed: 0');
            ELSE
               fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
               p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
               p_msg_text => 'MP framework return status:'||v_mp_prg_stat||
               ' MP exception code:'||v_mp_exception_code||' SQL statement: '||v_sql_stmt);

               RAISE e_mp_error;
            END IF;

            fem_engines_pkg.user_message(p_app_name =>'FEM',
                 p_msg_name => 'FEM_UD_DELETE_SUMMARY_TXT',
                 p_token1 => 'NUM_ROWS',
                 p_value1 => v_rows_processed,
                 p_token2 => 'TABLE_NAME',
                 p_value2 => v_tab_name);

            fem_multi_proc_pkg.delete_data_slices(
               p_req_id       => pv_request_id);


            -------------------
            -- UPDATE statement
            -------------------

            -- FEM.D Only handles the following undo types
            IF atbl.undo_type IN ('ZERO_COLUMN_BY_PERIOD',
                                  'ZERO_COLUMN_BY_OBJECT') THEN

               v_sql_stmt := 'UPDATE '||atbl.table_name
                                      ||' {{table_partition}} SET';

               FOR acol IN c2(atbl.table_name, atbl.statement_type) LOOP
                  v_count_cols := c2%ROWCOUNT;  -- Set counter to indicate that at least one column found.

                  IF v_count_cols = 1 THEN -- If this is first row
                     v_sql_stmt := v_sql_stmt||' '||acol.colname||'=0';
                  ELSE
                     v_sql_stmt := v_sql_stmt||', '||acol.colname||'=0';
                  END IF;

               END LOOP;

               IF v_count_cols = 0 THEN
               -- No column found

                  fem_engines_pkg.tech_message(p_severity => pc_log_level_exception,
                  p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
                  p_app_name =>'FEM',
                  p_msg_name => 'FEM_UD_NO_UPD_COL_FOUND_WRN');

               ELSE
               -- at least one column exists

                  IF atbl.undo_type = 'ZERO_COLUMN_BY_PERIOD' THEN
                     SELECT ' CAL_PERIOD_ID = '||cal_period_id||
                        ' AND LEDGER_ID = '||ledger_id||
                        ' AND DATASET_CODE = '||output_dataset_code
                     INTO v_where_clause
                     FROM fem_pl_requests
                     WHERE request_id = p_request_id;
                  ELSE -- atbl.undo_type = 'ZERO_COLUMN_BY_OBJECT'
                     v_where_clause := ' LAST_UPDATED_BY_REQUEST_ID = '||p_request_id||
                                       ' AND LAST_UPDATED_BY_OBJECT_ID = '||p_object_id;
                  END IF;

                  -- prepare statement
                  v_sql_stmt := v_sql_stmt||' WHERE '||v_where_clause||' AND {{data_slice}} ';
                  v_mp_stmt_id := atbl.table_name||'_MERGE_UPD_'||v_count_tbls;

                  -- submit statement to MP engine.
                  -- EXECUTE IMMEDIATE v_sql_stmt||' '||v_where_clause; (pre MP testing)
                  fem_multi_proc_pkg.master(
                     x_prg_stat       => v_mp_prg_stat,
                     x_exception_code => v_mp_exception_code,
                     p_rule_id        => v_undo_list_obj_id,
                     p_eng_step       => v_mp_step_name,
                     p_data_table     => atbl.table_name,
                     p_eng_sql        => v_sql_stmt,
                     p_run_name       => v_mp_stmt_id,
                     p_condition      => v_where_clause);

                  IF v_mp_prg_stat = 'COMPLETE:NORMAL' THEN
                     -- retrieve number of rows processed and send technical message.
                     SELECT NVL(SUM(rows_processed),0)
                     INTO v_rows_processed
                     FROM fem_mp_process_ctl_t
                     WHERE req_id = pv_request_id;

                     fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
                     p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
                     p_msg_text => 'Number of rows processed:'||v_rows_processed||' ');

                  ELSIF v_mp_exception_code = 'FEM_MP_NO_DATA_SLICES_ERR' THEN
                     v_rows_processed := 0;

                     fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
                     p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
                     p_msg_text => 'Number of rows processed: 0');

                  ELSE

                     fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
                     p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
                     p_msg_text => 'MP framework return status:'||v_mp_prg_stat||
                     ' MP exception code:'||v_mp_exception_code||' SQL statement: '||v_sql_stmt);

                     RAISE e_mp_error;
                  END IF;

                  fem_engines_pkg.user_message(p_app_name =>'FEM',
                    p_msg_name => 'FEM_UD_UPDATE_SUMMARY_TXT',
                    p_token1 => 'NUM_ROWS',
                    p_value1 => v_rows_processed,
                    p_token2 => 'TABLE_NAME',
                    p_value2 => v_tab_name);

                  fem_multi_proc_pkg.delete_data_slices(
                     p_req_id       => pv_request_id);

               END IF; -- v_count_cols = 0

            END IF; -- atbl.undo_type IN (...)
                    -- End update portion of merge statement

         ELSE
            -- Undo does not support the undo of such statement types/tables
            RAISE e_undo_action_not_supported;

         END IF; -- End statement_type processing.

      END LOOP;

      IF v_count_tbls = 0 THEN
      -- If no table found then
         fem_engines_pkg.tech_message(p_severity => pc_log_level_exception,
         p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
         p_app_name =>'FEM',
         p_msg_name => 'FEM_UD_NO_TABLE_FOUND_WRN');

         FEM_ENGINES_PKG.user_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UD_NO_TABLE_FOUND_WRN');
      END IF;

      Get_Put_Messages(
         p_msg_count       => v_msg_count,
         p_msg_data        => v_msg_data,
         p_user_msg        => 'N',
         p_module          => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name);
     -- End table processing (Step 2 done only if fem_object_types.undo_flag = 'Y').

-- ============================================================================
-- STEP 3:
-- Delete data from the data location tables (FEM_DL_xxxx).
-- This is only required in cases where fem_object_Types.undo_flag='Y'.
-- ============================================================================
      fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
      p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
      p_msg_text => 'STEP 3: Delete data from the data location tables (FEM_DL_xxxx).');

      fem_dimension_util_pkg.unregister_data_location(
         p_request_id => p_request_id,
         p_object_id  => p_object_id);

   END IF;

-- ============================================================================
-- STEP 4:
-- Execute all engine specific procedures.
-- ============================================================================
   fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'STEP 4: Execute all engine specific procedures.');

   IF v_object_type_code IN ('OGL_INTG_BAL_RULE','XGL_INTEGRATION') THEN

      fem_gl_post_process_pkg.undo_xgl_interface_error_rows (
         p_request_id                   => p_request_id,
         x_return_status                => x_return_status,
         x_msg_count                    => v_msg_count,
         x_msg_data                     => v_msg_data);

      IF x_return_status <> pc_ret_sts_success THEN

         Get_Put_Messages(
            p_msg_count       => v_msg_count,
            p_msg_data        => v_msg_data,
            p_user_msg        => 'Y',
            p_module          => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name||'.undo_xgl_interface_error_rows');

         RAISE e_engine_specific_proc_err;
      ELSIF v_msg_count > 0 THEN
         Get_Put_Messages(
            p_msg_count       => v_msg_count,
            p_msg_data        => v_msg_data,
            p_user_msg        => 'N',
            p_module          => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name||'.undo_xgl_interface_error_rows');

      END IF;

   END IF;


-- ============================================================================
-- STEP 5:
-- Remove object execution log.
-- ============================================================================

   fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'STEP 5: Remove object execution log.');

   delete_execution_log (
      p_commit               => FND_API.G_TRUE,
      p_api_version          => 1.0,
      p_request_id           => p_request_id,
      p_object_id            => p_object_id,
      x_return_status        => x_return_status,
      x_msg_count            => v_msg_count,
      x_msg_data             => v_msg_data);

   IF x_return_status <> pc_ret_sts_success THEN
      Get_Put_Messages(
         p_msg_count       => v_msg_count,
         p_msg_data        => v_msg_data,
         p_user_msg        => 'Y',
         p_module          => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name||'.delete_execution_log');

      RAISE e_cannot_delete_execution_log;
   END IF;

-- ============================================================================
-- STEP 6:
-- Update status of object execution in undo list.
-- ============================================================================
   fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'STEP 6: Update status of object execution in undo list to SUCCESS.');

   IF p_obj_exec_type = 'DEPENDENT' THEN
      UPDATE fem_ud_list_dependents
      SET exec_status_code = 'SUCCESS',
      last_Update_date = sysdate, last_Updated_by = pv_apps_user_id
      WHERE undo_list_obj_def_id = p_undo_list_obj_def_id
      AND dependent_request_id = p_request_id
      AND dependent_object_id = p_object_id;
   ELSE
   -- p_obj_exec_type = 'CANDIDATE'
      UPDATE fem_ud_list_candidates
      SET exec_status_code = 'SUCCESS',
      last_update_date = sysdate, last_updated_by = pv_apps_user_id
      WHERE undo_list_obj_def_id = p_undo_list_obj_def_id
      AND request_id = p_request_id
      AND object_id = p_object_id;
   END IF;
   COMMIT;

   fem_engines_pkg.tech_message(p_severity => pc_log_level_procedure,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'End. x_return_status: '||x_return_status);

   EXCEPTION
      WHEN e_undo_action_not_supported THEN
         x_return_status := pc_ret_sts_error;

         v_tab_class := null;
         BEGIN
           SELECT max(table_classification_code)
           INTO v_tab_class
           FROM fem_table_class_assignmt_v
           WHERE table_classification_code NOT IN ('CUSTOMER_PROFIT_RESULT',
             'TRANSACTION_PROFITABILITY','ACCOUNT_PROFITABILITY',
             'FTP_CASH_FLOW','FTP_NON_CASH_FLOW','FTP_OPTION_COST')
           AND table_name = v_tab_name;
         EXCEPTION WHEN others THEN null;
         END;

         FEM_ENGINES_PKG.tech_message(
            p_severity => pc_log_level_statement,
            p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
            p_msg_text => 'Cannot undo table '||v_tab_name
                       ||' if it belongs to '||v_tab_class||' table class.');

         FEM_ENGINES_PKG.tech_message(
            p_severity => pc_log_level_statement,
            p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
            p_msg_text => 'Statement type = '||v_stmt_type);

         FEM_ENGINES_PKG.user_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UD_ACTION_NOT_SUPPORTED',
            p_token1 => 'TAB_NAME',
            p_value1 => v_tab_name);

      -- Update status of object execution in undo list.
         fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
         p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
         p_msg_text => 'Update status of object execution in undo list to ERROR_RERUN');

         IF p_obj_exec_type = 'DEPENDENT' THEN
            UPDATE fem_ud_list_dependents
            SET exec_status_code = 'ERROR_RERUN',
            last_update_date = sysdate, last_Updated_by = pv_apps_User_id
            WHERE undo_list_obj_def_id = p_undo_list_obj_def_id
            AND dependent_request_id = p_request_id
            AND dependent_object_id = p_object_id;

            UPDATE fem_ud_list_candidates
            SET exec_status_code = 'ERROR_RERUN',
            last_update_date = sysdate, last_Updated_by = pv_apps_user_id
            WHERE undo_list_obj_def_id = p_undo_list_obj_def_id
            AND exec_status_code = 'RUNNING';
            COMMIT;

         ELSE
         -- p_obj_exec_type = 'CANDIDATE'
            UPDATE fem_ud_list_candidates
            SET exec_status_code = 'ERROR_RERUN',
            last_update_date = sysdate, last_updated_by = pv_apps_user_id
            WHERE undo_list_obj_def_id = p_undo_list_obj_def_id
            AND request_id = p_request_id
            AND object_id = p_object_id;
         END IF;
         COMMIT;

      WHEN e_mp_error THEN
         x_return_status := pc_ret_sts_error;
         FEM_ENGINES_PKG.user_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_MP_ERR');

      -- Update status of object execution in undo list.
         fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
         p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
         p_msg_text => 'Update status of object execution in undo list to ERROR_RERUN');

         IF p_obj_exec_type = 'DEPENDENT' THEN
            UPDATE fem_ud_list_dependents
            SET exec_status_code = 'ERROR_RERUN',
            last_update_date = sysdate, last_Updated_by = pv_apps_User_id
            WHERE undo_list_obj_def_id = p_undo_list_obj_def_id
            AND dependent_request_id = p_request_id
            AND dependent_object_id = p_object_id;

            UPDATE fem_ud_list_candidates
            SET exec_status_code = 'ERROR_RERUN',
            last_update_date = sysdate, last_Updated_by = pv_apps_user_id
            WHERE undo_list_obj_def_id = p_undo_list_obj_def_id
            AND exec_status_code = 'RUNNING';
            COMMIT;

         ELSE
         -- p_obj_exec_type = 'CANDIDATE'
            UPDATE fem_ud_list_candidates
            SET exec_status_code = 'ERROR_RERUN',
            last_update_date = sysdate, last_updated_by = pv_apps_user_id
            WHERE undo_list_obj_def_id = p_undo_list_obj_def_id
            AND request_id = p_request_id
            AND object_id = p_object_id;
         END IF;
         COMMIT;

      WHEN e_engine_specific_proc_err THEN
         x_return_status := pc_ret_sts_error;

      -- Update status of object execution in undo list.
         fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
         p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
         p_msg_text => 'Update status of object execution in undo list to ERROR_RERUN');

         IF p_obj_exec_type = 'DEPENDENT' THEN
            UPDATE fem_ud_list_dependents
            SET exec_status_code = 'ERROR_RERUN',
            last_update_date = sysdate, last_Updated_by = pv_apps_user_id
            WHERE undo_list_obj_def_id = p_undo_list_obj_def_id
            AND dependent_request_id = p_request_id
            AND dependent_object_id = p_object_id;

            UPDATE fem_ud_list_candidates
            SET exec_status_code = 'ERROR_RERUN',
            last_update_date = sysdate, last_Updated_by = pv_apps_user_id
            WHERE undo_list_obj_def_id = p_undo_list_obj_def_id
            AND exec_status_code = 'RUNNING';
            COMMIT;

         ELSE -- p_obj_exec_type = 'CANDIDATE'
            UPDATE fem_ud_list_candidates
            SET exec_status_code = 'ERROR_RERUN',
            last_update_date = sysdate, last_Updated_by = pv_apps_user_id
            WHERE undo_list_obj_def_id = p_undo_list_obj_def_id
            AND request_id = p_request_id
            AND object_id = p_object_id;
         END IF;
         COMMIT;
      WHEN e_cannot_delete_execution_log THEN
         x_return_status := pc_ret_sts_error;

         FEM_ENGINES_PKG.user_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UD_CANNOT_DELETE_EXEC_LOG');

      -- Update status of object execution in undo list.
         fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
         p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
         p_msg_text => 'Update status of object execution in undo list to ERROR_RERUN');

         IF p_obj_exec_type = 'DEPENDENT' THEN
            UPDATE fem_ud_list_dependents
            SET exec_status_code = 'ERROR_RERUN',
            last_update_date = sysdate, last_Updated_by = pv_apps_user_id
            WHERE undo_list_obj_def_id = p_undo_list_obj_def_id
            AND dependent_request_id = p_request_id
            AND dependent_object_id = p_object_id;

            UPDATE fem_ud_list_candidates
            SET exec_status_code = 'ERROR_RERUN',
            last_Update_date = sysdate, last_Updated_by = pv_apps_user_id
            WHERE undo_list_obj_def_id = p_undo_list_obj_def_id
            AND exec_status_code = 'RUNNING';
            COMMIT;

         ELSE -- p_obj_exec_type = 'CANDIDATE'
            UPDATE fem_ud_list_candidates
            SET exec_status_code = 'ERROR_RERUN',
            last_update_date = sysdate, last_Updated_by = pv_apps_user_id
            WHERE undo_list_obj_def_id = p_undo_list_obj_def_id
            AND request_id = p_request_id
            AND object_id = p_object_id;
         END IF;
         COMMIT;
      WHEN OTHERS THEN
      -- Unexpected exceptions
         x_return_status := pc_ret_sts_unexp_error;

      -- Log the call stack and the Oracle error message to
      -- FND_LOG with the "unexpected exception" severity level.

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_unexpected,
            p_module   => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
            p_msg_text => SQLERRM);

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_unexpected,
            p_module   => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
            p_msg_text => dbms_utility.format_call_stack);

      -- Log the Oracle error message to the stack.
         FEM_ENGINES_PKG.user_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UNEXPECTED_ERROR',
            P_TOKEN1 => 'ERR_MSG',
            P_VALUE1 => SQLERRM);

      -- Update status of object execution in undo list.
         fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
         p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
         p_msg_text => 'Update status of object execution in undo list to ERROR_RERUN.');

         IF p_obj_exec_type = 'DEPENDENT' THEN
            UPDATE fem_ud_list_dependents
            SET exec_status_code = 'ERROR_RERUN',
            last_Update_date = sysdate, last_Updated_by = pv_apps_user_id
            WHERE undo_list_obj_def_id = p_undo_list_obj_def_id
            AND dependent_request_id = p_request_id
            AND dependent_object_id = p_object_id;

            UPDATE fem_ud_list_candidates
            SET exec_status_code = 'ERROR_RERUN',
            last_update_date = sysdate, last_updated_by = pv_apps_user_id
            WHERE undo_list_obj_def_id = p_undo_list_obj_def_id
            AND exec_status_code = 'RUNNING';
            COMMIT;

         ELSE -- p_obj_exec_type = 'CANDIDATE'
            UPDATE fem_ud_list_candidates
            SET exec_status_code = 'ERROR_RERUN',
            last_Update_date = sysdate, last_Updated_by = pv_apps_user_id
            WHERE undo_list_obj_def_id = p_undo_list_obj_def_id
            AND request_id = p_request_id
            AND object_id = p_object_id;
         END IF;
         COMMIT;

END perform_undo_actions;
-- *****************************************************************************
PROCEDURE set_process_status (p_undo_list_obj_id IN NUMBER,
                              p_undo_list_obj_def_id IN NUMBER,
                              p_execution_status IN VARCHAR2) AS
-- ============================================================================
-- PRIVATE
-- This procedure sets the status of an undo run.
-- ============================================================================

   c_api_name  CONSTANT VARCHAR2(30) := 'set_process_status';
   v_msg_count NUMBER;
   v_msg_data VARCHAR2(32000);
   v_api_return_status VARCHAR2(30);
   e_post_process EXCEPTION;
   v_exec_status VARCHAR2(150);

BEGIN
   fem_engines_pkg.tech_message(p_severity => pc_log_level_procedure,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'Begin. P_OBJECT_ID: '||p_undo_list_obj_id||
   ' P_EXECUTION_STATUS: '||p_execution_status);

   -- Update status of undo list
   UPDATE fem_ud_lists
   SET exec_status_code = p_execution_status,
   last_update_date = sysdate, last_Updated_by = pv_apps_user_id
   WHERE undo_list_obj_def_id = p_undo_list_obj_def_id;

   -- Update Object Execution Status
   FEM_PL_PKG.Update_Obj_Exec_Status(
     P_API_VERSION               => 1.0,
     P_COMMIT                    => FND_API.G_TRUE,
     P_REQUEST_ID                => pv_request_id,
     P_OBJECT_ID                 => p_undo_list_obj_id,
     P_EXEC_STATUS_CODE          => p_execution_status,
     P_USER_ID                   => pv_apps_user_id,
     P_LAST_UPDATE_LOGIN         => null,
     X_MSG_COUNT                 => v_msg_count,
     X_MSG_DATA                  => v_msg_data,
     X_RETURN_STATUS             => v_API_return_status);

   IF v_api_return_status <> pc_ret_sts_success THEN

      FEM_ENGINES_PKG.USER_MESSAGE
       (P_APP_NAME => 'FEM'
       ,P_MSG_NAME => 'FEM_PL_UPD_OBJEXEC_STATUS_ERR'
       ,P_TOKEN1   => 'REQUEST_ID'
       ,P_VALUE1   =>  pv_request_id
       ,P_TRANS1   => 'N'
       ,P_TOKEN2   => 'OBJECT_ID'
       ,P_VALUE2   =>  p_undo_list_obj_id
       ,P_TRANS2   => 'N'
       ,P_TOKEN3   => 'EXEC_STATUS'
       ,P_VALUE3   =>  p_execution_status
       ,P_TRANS3   => 'N');

      FEM_ENGINES_PKG.USER_MESSAGE
       (P_APP_NAME => 'FEM'
       ,P_MSG_NAME => 'FEM_POST_PROC_ERR');

      Get_Put_Messages(
         p_msg_count       => v_msg_count,
         p_msg_data        => v_msg_data,
         p_user_msg        => 'N',
         p_module          => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name);

   END IF;

   -- Update Request Status
   FEM_PL_PKG.Update_Request_Status(
     P_API_VERSION               => 1.0,
     P_COMMIT                    => FND_API.G_TRUE,
     P_REQUEST_ID                => pv_request_id,
     P_EXEC_STATUS_CODE          => p_execution_status,
     P_USER_ID                   => pv_apps_user_id,
     P_LAST_UPDATE_LOGIN         => null,
     X_MSG_COUNT                 => v_msg_count,
     X_MSG_DATA                  => v_msg_data,
     X_RETURN_STATUS             => v_API_return_status);

   IF v_api_return_status <> pc_ret_sts_success THEN

      FEM_ENGINES_PKG.USER_MESSAGE
       (P_APP_NAME => 'FEM'
       ,P_MSG_NAME => 'FEM_PL_UPD_REQUEST_STATUS_ERR'
       ,P_TOKEN1   => 'REQUEST_ID'
       ,P_VALUE1   =>  pv_request_id
       ,P_TRANS1   => 'N'
       ,P_TOKEN2   => 'EXEC_STATUS'
       ,P_VALUE2   =>  p_execution_status
       ,P_TRANS2   => 'N');

      FEM_ENGINES_PKG.USER_MESSAGE
       (P_APP_NAME => 'FEM'
       ,P_MSG_NAME => 'FEM_POST_PROC_ERR');

      Get_Put_Messages(
         p_msg_count       => v_msg_count,
         p_msg_data        => v_msg_data,
         p_user_msg        => 'N',
         p_module          => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name);

   END IF;

   -- Post Messages
   BEGIN
      SELECT meaning INTO v_exec_status
      FROM fnd_lookup_values
      WHERE lookup_type = 'FEM_EXEC_STATUS_DSC'
      AND lookup_code = p_execution_status
      AND language = USERENV('LANG');
   EXCEPTION WHEN NO_DATA_FOUND THEN
      v_exec_status := p_execution_status;
   END;

   -- Set status of request
   IF p_execution_status = 'SUCCESS' THEN
      FEM_ENGINES_PKG.USER_MESSAGE
       (P_APP_NAME => 'FEM'
       ,P_MSG_NAME => 'FEM_EXEC_SUCCESS');

      pv_concurrent_status := fnd_concurrent.set_completion_status('NORMAL',null);

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_unexpected,
         p_module   => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
         P_MSG_NAME => 'FEM_EXEC_SUCCESS');
   ELSIF p_execution_status IN ('ERROR_RERUN') THEN
      FEM_ENGINES_PKG.USER_MESSAGE
       (P_APP_NAME => 'FEM'
       ,P_MSG_NAME => 'FEM_EXEC_RERUN');

      pv_concurrent_status := fnd_concurrent.set_completion_status('ERROR',null);

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_unexpected,
         p_module   => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
         P_MSG_NAME => 'FEM_EXEC_RERUN');
   END IF;

   fem_engines_pkg.tech_message(p_severity => pc_log_level_procedure,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'End');

EXCEPTION
      WHEN OTHERS THEN
      -- Unexpected exceptions

      -- Log the call stack and the Oracle error message to
      -- FND_LOG with the "unexpected exception" severity level.

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_unexpected,
            p_module   => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
            p_msg_text => SQLERRM);

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_unexpected,
            p_module   => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
            p_msg_text => dbms_utility.format_call_stack);

      -- Log the Oracle error message to the stack.
         FEM_ENGINES_PKG.user_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UNEXPECTED_ERROR',
            P_TOKEN1 => 'ERR_MSG',
            P_VALUE1 => SQLERRM);

END set_process_status;
-- *****************************************************************************
PROCEDURE execute_undo_list  (errbuf                  OUT NOCOPY VARCHAR2,
                              retcode                 OUT NOCOPY VARCHAR2,
                              p_undo_list_obj_id      IN  NUMBER) AS
-- ============================================================================
-- PUBLIC
-- This is the main procedure of the 'Undo Engine' that will be invoked
-- via concurrent manager.  This procedure processes the specified undo list.
-- ============================================================================

c_api_name  CONSTANT           VARCHAR2(30) := 'execute_undo_list';
v_count                        NUMBER;
v_undo_list_obj_def_id         NUMBER;
v_previous_request_id          NUMBER;
v_exec_state                   VARCHAR2(30);
v_msg_count                    NUMBER;
v_msg_data                     VARCHAR2(32000);
v_return_status                VARCHAR2(1);
v_include_dependencies_flag    VARCHAR2(1);
v_ignore_dependency_errs_flag  VARCHAR2(1);
v_dependency_type              VARCHAR2(10);
v_can_user_read_rule_flag      VARCHAR2(1);

-- This cursor retrives all candidates in an undo list that have not
-- been executed successfully.
CURSOR c10 IS
   SELECT request_id, object_id
   FROM fem_ud_list_candidates
   WHERE undo_list_obj_def_id = v_undo_list_obj_def_id
   AND (exec_status_code IS NULL OR
    exec_status_code <> 'SUCCESS')
   ORDER BY request_id, object_id;

-- This cursor retrives all dependents for a candidate.
CURSOR c20 (v_request_id IN NUMBER, v_object_id IN NUMBER) IS
   SELECT dependent_request_id, dependent_object_id
   FROM fem_ud_list_dependents
   WHERE undo_list_obj_def_id = v_undo_list_obj_def_id
   AND request_id = v_request_id
   AND object_id = v_object_id
   AND (exec_status_code IS NULL OR
    exec_status_code <> 'SUCCESS')
   ORDER BY dependent_request_id, dependent_object_id;

-- This cursor retrieves all executions of the undo list
CURSOR c3 IS
   SELECT request_id
   FROM fem_pl_object_executions
   WHERE object_id = p_undo_list_obj_id;

BEGIN
   fem_engines_pkg.tech_message(p_severity => pc_log_level_procedure,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'Begin. P_UNDO_LIST_OBJ_ID: '||p_undo_list_obj_id);

-- ============================================================================
-- VALIDATIONS
-- ============================================================================
   fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'Begin VALIDATIONS: '||to_char(sysdate,'MM/DD/YYYY HH:MI:SS'));

-- ============================================================================
-- V01: Check to see if p_undo_list_obj_id is for a valid undo list.
-- ============================================================================
   fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'V01: Check to see if p_undo_list_obj_id is for a valid undo list.');

   BEGIN

      SELECT u.undo_list_obj_def_id
      INTO v_undo_list_obj_def_id
      FROM fem_object_catalog_b o, fem_object_definition_b d, fem_ud_lists u
      WHERE o.object_id = p_undo_list_obj_id
      AND o.object_type_code = 'UNDO'
      AND o.object_id = d.object_id
      AND d.object_definition_id = u.undo_list_obj_def_id;

   EXCEPTION WHEN NO_DATA_FOUND THEN
      RAISE e_invalid_undo_list;
   END;


-- Bug 4309949: Ignore folder security for Undo rules
-- ============================================================================
-- V02: Check to see if user has privileges to execute the list.
-- ============================================================================
--   fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
--   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
--   p_msg_text => 'V02: Check to see if user can read p_undo_list_obj_id.');

--   BEGIN

--      SELECT 'Y'
--      INTO v_can_user_read_rule_flag
--      FROM fem_object_catalog_b o, fem_user_folders u
--      WHERE o.object_id = p_undo_list_obj_id
--      AND o.folder_id = u.folder_id
--      AND u.user_id = pv_apps_user_id;

--   EXCEPTION WHEN NO_DATA_FOUND THEN
--      RAISE e_cannot_read_object;
--   END;


-- ============================================================================
-- V03: Check for dependencies, if ignore_dependency_errs_flag = 'N' AND
-- include_dependencies_flag = 'N'.
-- NOTE: This only checks for CHAIN dependencies, as UPDATE dependencies are
-- ALWAYS added to the undo list.
-- Missing Integration and RCM Process rule candidates are added to the list
-- before checking for dependencies.
-- ============================================================================

   SELECT include_dependencies_flag, ignore_dependency_errs_flag
   INTO v_include_dependencies_flag, v_ignore_dependency_errs_flag
   FROM fem_ud_lists
   WHERE undo_list_obj_def_id = v_undo_list_obj_def_id;

   IF v_include_dependencies_flag = 'N' AND v_ignore_dependency_errs_flag = 'N'
   THEN

      SELECT count(*) INTO v_count
      FROM fem_pl_chains pl
      WHERE (pl.source_created_by_request_id, pl.source_created_by_object_id) IN (
         SELECT c.request_id, c.object_id
         FROM fem_ud_list_candidates c
         WHERE c.undo_list_obj_def_id = v_undo_list_obj_def_id);

      IF v_count > 0 THEN
         RAISE e_dependencies_found;
      END IF;
   END IF;

   -- Set dependency type
   IF v_include_dependencies_flag = 'Y' THEN
      v_dependency_type := 'ALL';
   ELSE
      v_dependency_type := 'UPDATE';
   END IF;

-- ============================================================================
-- REGISTRATION
-- ============================================================================
   fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'Begin REGISTRATION: '||to_char(sysdate,'MM/DD/YYYY HH:MI:SS'));

-- ============================================================================
-- R01:  Register request
-- ============================================================================
      FEM_PL_PKG.Register_Request
        (P_API_VERSION            => 1.0,
         P_COMMIT                 => FND_API.G_FALSE,
         P_REQUEST_ID             => pv_request_id,
         P_USER_ID                => pv_apps_user_id,
         P_LAST_UPDATE_LOGIN      => pv_login_id,
         P_PROGRAM_ID             => pv_program_id,
         P_PROGRAM_LOGIN_ID       => pv_login_id,
         P_PROGRAM_APPLICATION_ID => pv_program_app_id,
         X_MSG_COUNT              => v_msg_count,
         X_MSG_DATA               => v_msg_data,
         X_RETURN_STATUS          => v_return_status);

      IF v_return_status <> pc_ret_sts_success THEN

         Get_Put_Messages(
            p_msg_count       => v_msg_count,
            p_msg_data        => v_msg_data,
            p_user_msg        => 'N',
            p_module          => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name);

         RAISE e_pl_reg_request_failed;

      END IF;
-- ============================================================================
-- R02:  Register object execution
-- ============================================================================
      FEM_PL_PKG.Register_Object_Execution
        (P_API_VERSION               => 1.0,
         P_COMMIT                    => FND_API.G_FALSE,
         P_REQUEST_ID                => pv_request_id,
         P_OBJECT_ID                 => p_undo_list_obj_id,
         P_EXEC_OBJECT_DEFINITION_ID => v_undo_list_obj_def_id,
         P_USER_ID                   => pv_apps_user_id,
         P_LAST_UPDATE_LOGIN         => pv_login_id,
         X_EXEC_STATE                => v_exec_state,
         X_PREV_REQUEST_ID           => v_previous_request_id,
         X_MSG_COUNT                 => v_msg_count,
         X_MSG_DATA                  => v_msg_data,
         X_RETURN_STATUS             => v_return_status);

      IF v_return_status <> pc_ret_sts_success THEN

         Get_Put_Messages(
            p_msg_count       => v_msg_count,
            p_msg_data        => v_msg_data,
            p_user_msg        => 'N',
            p_module          => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name);

         RAISE e_pl_reg_obj_exec_failed;

      END IF;
-- ============================================================================
-- R02:  Register undo list in FEM_PL_OBJECT_DEFS
-- ============================================================================
      FEM_PL_PKG.Register_Object_Def
        (P_API_VERSION               => 1.0,
         P_COMMIT                    => FND_API.G_FALSE,
         P_REQUEST_ID                => pv_request_id,
         P_OBJECT_ID                 => p_undo_list_obj_id,
         P_OBJECT_DEFINITION_ID      => v_undo_list_obj_def_id,
         P_USER_ID                   => pv_apps_user_id,
         P_LAST_UPDATE_LOGIN         => pv_login_id,
         X_MSG_COUNT                 => v_msg_count,
         X_MSG_DATA                  => v_msg_data,
         X_RETURN_STATUS             => v_return_status);

      IF v_return_status <> pc_ret_sts_success THEN

         Get_Put_Messages(
            p_msg_count       => v_msg_count,
            p_msg_data        => v_msg_data,
            p_user_msg        => 'N',
            p_module          => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name);

         RAISE e_pl_reg_obj_def_failed;

      END IF;

-- ============================================================================
-- R04:  COMMIT registration steps
-- ============================================================================
      COMMIT;
   fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'End REGISTRATION: '||to_char(sysdate,'MM/DD/YYYY HH:MI:SS'));

-- ============================================================================
-- PROCESSING
-- ============================================================================
   fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'Begin PROCESSING: '||to_char(sysdate,'MM/DD/YYYY HH:MI:SS'));


   --  Set status of undo list to 'RUNNING'
   UPDATE fem_ud_lists
   SET exec_status_code = 'RUNNING',
   last_update_date = sysdate, last_updated_by = pv_apps_User_id
   WHERE undo_list_obj_def_id = v_undo_list_obj_def_id;
   COMMIT;

   SELECT count(*) INTO v_count
   FROM fem_ud_list_candidates
   WHERE undo_list_obj_def_id = v_undo_list_obj_def_id
   AND (exec_status_code IS NULL OR exec_status_code <> 'SUCCESS');

   IF v_count > 0 THEN
/*
      -- Generate dependents
      generate_dependents(
         x_return_status                => v_return_status,
         x_msg_count                    => v_msg_count,
         x_msg_data                     => v_msg_data,
         p_api_version                  => 2.0,
         p_commit                       => FND_API.G_TRUE,
         p_undo_list_obj_def_id         => v_undo_list_obj_def_id,
         p_dependency_type              => v_dependency_type);
*/

      -- Validate candidates
      validate_candidates(
         x_return_status                => v_return_status,
         x_msg_count                    => v_msg_count,
         x_msg_data                     => v_msg_data,
         p_api_version                  => 2.0,
         p_commit                       => FND_API.G_TRUE,
         p_undo_list_obj_def_id         => v_undo_list_obj_def_id,
         p_dependency_type              => v_dependency_type);

      IF v_return_status <> pc_ret_sts_success THEN
         Get_Put_Messages(
            p_msg_count       => v_msg_count,
            p_msg_data        => v_msg_data,
            p_user_msg        => 'Y',
            p_module          => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name);

         RAISE e_cannot_validate_candidates;

      END IF;

   END IF;

   -- Post following message to output log before undoing executions:
   --  "Removing the following rule executions:"
   FEM_ENGINES_PKG.user_message(p_app_name =>'FEM',
     p_msg_name => 'FEM_UD_PROCESSING_LIST_TXT');

   -- Process all candidates in the list.
   FOR a_candidate IN c10 LOOP
      v_count := c10%ROWCOUNT;

      -- Submit business event: 'oracle.apps.fem.ud.submit'
      -- when undo first processes the Undo candidate
      raise_undo_business_event (p_event_name => 'oracle.apps.fem.ud.submit',
                                 p_request_id => a_candidate.request_id,
                                 p_object_id  => a_candidate.object_id);

      UPDATE fem_ud_list_candidates
      SET exec_status_code = 'RUNNING',
      last_Update_date = sysdate, last_updated_by = pv_apps_user_Id
      WHERE undo_list_obj_def_id = v_undo_list_obj_def_id
      AND request_id = a_candidate.request_id
      AND object_id = a_candidate.object_id;
      COMMIT;

      FOR a_dependent IN c20(a_candidate.request_id, a_candidate.object_id) LOOP

         perform_undo_actions(
            p_undo_list_obj_def_id         => v_undo_list_obj_def_id,
            p_obj_exec_type                => 'DEPENDENT',
            p_request_id                   => a_dependent.dependent_request_id,
            p_object_id                    => a_dependent.dependent_object_id,
            x_return_status                => v_return_status);

         IF v_return_status <> pc_ret_sts_success THEN

            RAISE e_cannot_undo_obj_exec_err;

         END IF;

      END LOOP;

      -- Undo candidate after all its dependents have been processed successfully
      perform_undo_actions(
         p_undo_list_obj_def_id         => v_undo_list_obj_def_id,
         p_obj_exec_type                => 'CANDIDATE',
         p_request_id                   => a_candidate.request_id,
         p_object_id                    => a_candidate.object_id,
         x_return_status                => v_return_status);

      -- Submit business event: 'oracle.apps.fem.ud.submit'
      -- when undo first processes the Undo candidate
      raise_undo_business_event (p_event_name => 'oracle.apps.fem.ud.complete',
                                 p_request_id => a_candidate.request_id,
                                 p_object_id  => a_candidate.object_id,
                                 p_status     => v_return_status);

      IF v_return_status <> pc_ret_sts_success THEN

         RAISE e_cannot_undo_obj_exec_err;

      END IF;

   END LOOP;

   IF v_count = 0 THEN
      FEM_ENGINES_PKG.user_message(p_app_name =>'FEM',
         p_msg_name => 'FEM_UD_NO_CANDIDATES_ERR');
   ELSE
      -- If at least one candidate was processed, print a new line in the
      -- concurrent output log to separate out the messages printed out
      -- in the call to perform_undo_action from any more messages to be
      -- printed out later in this execution.
      FEM_ENGINES_PKG.user_message(p_app_name =>'FEM',
         p_msg_name => 'FEM_NEW_LINE');
   END IF;

   fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'End PROCESSING: '||to_char(sysdate,'MM/DD/YYYY HH:MI:SS'));


-- ============================================================================
-- Since the undo run was successful, delete the registration information for
-- this execution, and all executions of this undo list, then also delete
-- the undo list.
-- ============================================================================
   fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'Since the undo run was successful, delete the undo list and its registration information.');

-- Delete object execution from process lock tables (FEM_PL_xxxx).
   fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'Delete undo run from process lock tables (FEM_PL_xxxx).');

   FOR undo_objexec IN c3 LOOP

      delete_execution_log (
         p_commit               => FND_API.G_TRUE,
         p_api_version          => 1.0,
         p_request_id           => undo_objexec.request_id,
         p_object_id            => p_undo_list_obj_id,
         x_return_status        => v_return_status,
         x_msg_count            => v_msg_count,
         x_msg_data             => v_msg_data);

      IF v_return_status <> pc_ret_sts_success THEN
         Get_Put_Messages(
            p_msg_count       => v_msg_count,
            p_msg_data        => v_msg_data,
            p_user_msg        => 'Y',
            p_module          => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name||'.delete_execution_log');

         FEM_ENGINES_PKG.user_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UD_CANNOT_DELETE_UNDOEXEC');

      END IF;

   END LOOP;

   -- Delete undo list.
   --  Set status of undo list to 'SUCCESS'
   UPDATE fem_ud_lists
   SET exec_status_code = 'SUCCESS',
   last_update_date = sysdate, last_updated_by = pv_apps_user_id
   WHERE undo_list_obj_def_id = v_undo_list_obj_def_id;
   COMMIT;

   delete_undo_list(
     p_api_version         => 1.0,
     p_commit              => FND_API.G_TRUE,
     p_undo_list_obj_id    => p_undo_list_obj_id,
     x_return_status       => v_return_status,
     x_msg_count           => v_msg_count,
     x_msg_data            => v_msg_data);

   Get_Put_Messages(
      p_msg_count       => v_msg_count,
      p_msg_data        => v_msg_data,
      p_user_msg        => 'N',
      p_module          => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name);

   IF v_return_status <> pc_ret_sts_success THEN

      fem_engines_pkg.user_message(p_app_name =>'FEM',
      p_msg_name => 'FEM_UD_CANNOT_DELETE_LIST_ERR');

   END IF;

-- ============================================================================
-- SET STATUS
-- ============================================================================
   set_process_status (p_undo_list_obj_id => p_undo_list_obj_id,
                       p_undo_list_obj_def_id => v_undo_list_obj_def_id,
                       p_execution_status => 'SUCCESS');
   fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'End. '||to_char(sysdate,'MM/DD/YYYY HH:MI:SS'));
-- ============================================================================
-- EXCEPTIONS
-- ============================================================================
   EXCEPTION
      WHEN e_invalid_undo_list THEN
         ROLLBACK;
         FEM_ENGINES_PKG.user_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UD_INVALID_UNDO_LIST_ERR',
            p_token1 => 'OBJECT_ID',
            p_value1 => p_undo_list_obj_id,
            p_trans1 => 'N');

         fem_engines_pkg.tech_message(p_severity => pc_log_level_exception,
            p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
            p_msg_name => 'FEM_UD_INVALID_UNDO_LIST_ERR',
            p_token1 => 'OBJECT_ID',
            p_value1 => p_undo_list_obj_id,
            p_trans1 => 'N');

         set_process_status (p_undo_list_obj_id => p_undo_list_obj_id,
                             p_undo_list_obj_def_id => v_undo_list_obj_def_id,
                             p_execution_status => 'ERROR_RERUN');

      WHEN e_cannot_read_object THEN
         ROLLBACK;
         FEM_ENGINES_PKG.user_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UD_CANNOT_READ_OBJECT_ERR');

         fem_engines_pkg.tech_message(p_severity => pc_log_level_exception,
            p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
            p_msg_name => 'FEM_UD_CANNOT_READ_OBJECT_ERR');

         set_process_status (p_undo_list_obj_id => p_undo_list_obj_id,
                             p_undo_list_obj_def_id => v_undo_list_obj_def_id,
                             p_execution_status => 'ERROR_RERUN');

      WHEN e_dependencies_found THEN
            ROLLBACK;
         FEM_ENGINES_PKG.user_message (p_app_name =>'FEM',
            p_msg_name => 'FEM_UD_DEPENDENTS_FOUND_ERR',
               p_token1 => 'OBJECT_ID',
               p_value1 => p_undo_list_obj_id,
               p_trans1 => 'N');

         FOR a_candidate IN c10 LOOP
            report_cand_dependents (
               x_msg_count       => v_msg_count,
               x_msg_data        => v_msg_data,
               p_request_id      => a_candidate.request_id,
               p_object_id       => a_candidate.object_id,
               p_dependency_type => 'CHAIN');

         END LOOP;

      Get_Put_Messages(
         p_msg_count       => v_msg_count,
         p_msg_data        => v_msg_data,
         p_user_msg        => 'Y',
         p_module          => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name);

         set_process_status (p_undo_list_obj_id => p_undo_list_obj_id,
                             p_undo_list_obj_def_id => v_undo_list_obj_def_id,
                             p_execution_status => 'ERROR_RERUN');

      WHEN e_pl_reg_request_failed THEN
         ROLLBACK;
         FEM_ENGINES_PKG.user_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_PL_REG_REQUEST_ERR');

         fem_engines_pkg.tech_message(p_severity => pc_log_level_exception,
         p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
         p_msg_name =>'FEM_PL_REG_REQUEST_ERR');

         set_process_status (p_undo_list_obj_id => p_undo_list_obj_id,
                             p_undo_list_obj_def_id => v_undo_list_obj_def_id,
                             p_execution_status => 'ERROR_RERUN');

      WHEN e_pl_reg_obj_exec_failed THEN
         ROLLBACK;
         FEM_ENGINES_PKG.user_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_PL_REG_OBJ_EXEC_ERR');

         fem_engines_pkg.tech_message(p_severity => pc_log_level_exception,
         p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
         p_msg_name =>'FEM_PL_REG_OBJ_EXEC_ERR');

         set_process_status (p_undo_list_obj_id => p_undo_list_obj_id,
                             p_undo_list_obj_def_id => v_undo_list_obj_def_id,
                             p_execution_status => 'ERROR_RERUN');

      WHEN e_pl_reg_obj_def_failed THEN
         ROLLBACK;
         FEM_ENGINES_PKG.user_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_PL_REG_OBJ_DEF_ERR');

         fem_engines_pkg.tech_message(p_severity => pc_log_level_exception,
         p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
         p_msg_name =>'FEM_PL_REG_OBJ_DEF_ERR');

         set_process_status (p_undo_list_obj_id => p_undo_list_obj_id,
                             p_undo_list_obj_def_id => v_undo_list_obj_def_id,
                             p_execution_status => 'ERROR_RERUN');

      WHEN e_cannot_validate_candidates THEN

         FEM_ENGINES_PKG.user_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UD_CANNOT_VAL_CANDIDATES');

         fem_engines_pkg.tech_message(p_severity => pc_log_level_exception,
         p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
         p_msg_name =>'FEM_UD_CANNOT_VAL_CANDIDATES');

         set_process_status (p_undo_list_obj_id => p_undo_list_obj_id,
                             p_undo_list_obj_def_id => v_undo_list_obj_def_id,
                             p_execution_status => 'ERROR_RERUN');

      WHEN e_cannot_undo_obj_exec_err THEN

         FEM_ENGINES_PKG.user_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UD_CANNOT_UNDO_OBJ_EXEC');

         fem_engines_pkg.tech_message(p_severity => pc_log_level_exception,
         p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
         p_msg_name =>'FEM_UD_CANNOT_UNDO_OBJ_EXEC');

         set_process_status (p_undo_list_obj_id => p_undo_list_obj_id,
                             p_undo_list_obj_def_id => v_undo_list_obj_def_id,
                             p_execution_status => 'ERROR_RERUN');

      WHEN e_could_not_process_undo_list THEN
         ROLLBACK;
         FEM_ENGINES_PKG.user_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UD_INVALID_UNDO_LIST_ERR',
            p_token1 => 'OBJECT_ID',
            p_value1 => p_undo_list_obj_id,
            p_trans1 => 'N');

         fem_engines_pkg.tech_message(p_severity => pc_log_level_exception,
            p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
            p_msg_name => 'FEM_UD_INVALID_UNDO_LIST_ERR',
            p_token1 => 'OBJECT_ID',
            p_value1 => p_undo_list_obj_id,
            p_trans1 => 'N');

         set_process_status (p_undo_list_obj_id => p_undo_list_obj_id,
                             p_undo_list_obj_def_id => v_undo_list_obj_def_id,
                             p_execution_status => 'ERROR_RERUN');

      WHEN OTHERS THEN
      -- Unexpected exceptions
      -- Log the call stack and the Oracle error message to
      -- FND_LOG with the "unexpected exception" severity level.

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_unexpected,
            p_module   => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
            p_msg_text => SQLERRM);

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_unexpected,
            p_module   => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
            p_msg_text => dbms_utility.format_call_stack);

      -- Log the Oracle error message to the stack.
         FEM_ENGINES_PKG.user_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UNEXPECTED_ERROR',
            P_TOKEN1 => 'ERR_MSG',
            P_VALUE1 => SQLERRM);

         set_process_status (p_undo_list_obj_id => p_undo_list_obj_id,
                             p_undo_list_obj_def_id => v_undo_list_obj_def_id,
                             p_execution_status => 'ERROR_RERUN');

END execute_undo_list;
-- *****************************************************************************
PROCEDURE submit_undo_lists  (errbuf                OUT NOCOPY VARCHAR2,
                              retcode               OUT NOCOPY VARCHAR2) AS
-- ============================================================================
-- PUBLIC
-- This procedure will submit all undo lists that were created with an
-- execution date which is earlier than or equal to the current date.  This
-- will be invoked via concurrent manager.
-- ============================================================================


c_api_name  CONSTANT           VARCHAR2(30) := 'submit_undo_lists';
v_msg_count                    NUMBER;
v_msg_data                     VARCHAR2(32000);
v_subrequest_id                NUMBER;
v_total_requests               NUMBER := 0;
v_failed_subrequests           NUMBER := 0;
v_req_phase   VARCHAR2(80);
v_req_status  VARCHAR2(80);
v_dev_phase  VARCHAR2(30);
v_dev_status  VARCHAR2(30);
v_req_message  VARCHAR2 (240);
v_prg_stat     VARCHAR2(40) := 'NORMAL';
v_check_status BOOLEAN;

CURSOR c1 IS
   SELECT o.object_id
   FROM fem_object_catalog_b o, fem_object_definition_b d, fem_ud_lists u
   WHERE o.object_type_code = 'UNDO'
   AND o.object_id = d.object_id
   AND d.object_definition_id = u.undo_list_obj_def_id
   AND (u.execution_date < SYSDATE OR u.execution_date = SYSDATE)
   AND (u.exec_status_code IS NULL OR u.exec_status_code NOT IN ('RUNNING','SUCCESS'));

CURSOR c2 IS
   SELECT c.request_id
   FROM   fnd_concurrent_requests c
   WHERE  c.parent_request_id = pv_request_id
   ORDER BY c.request_id;

BEGIN
   fem_engines_pkg.tech_message(p_severity => pc_log_level_procedure,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'Begin.');


-- ============================================================================
-- SUBMIT undo lists for processing.
-- ============================================================================

   FOR undolist IN c1 LOOP
      v_total_requests := c1%ROWCOUNT;

      v_subrequest_id :=  FND_REQUEST.SUBMIT_REQUEST(
                        application => 'FEM',
                        program => 'FEM_UNDO_LIST',
                        sub_request => FALSE,
                        argument1 => undolist.object_id);

      IF (v_subrequest_id = 0) THEN
         v_failed_subrequests := v_failed_subrequests + 1;
         FEM_ENGINES_PKG.user_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UD_SUBMIT_LIST_ERR',
            P_TOKEN1 => 'OBJECT_ID',
            P_VALUE1 => undolist.object_id,
            P_TRANS1 => 'N');
      ELSE
         FEM_ENGINES_PKG.user_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UD_SUBMIT_LIST_TXT',
            P_TOKEN1 => 'OBJECT_ID',
            P_VALUE1 => undolist.object_id,
            P_TRANS1 => 'N',
            P_TOKEN2 => 'REQUEST_ID',
            P_VALUE2 => v_subrequest_id,
            P_TRANS2 => 'N'     );
      END IF;
      COMMIT;

   END LOOP;

   fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'Total number of undo lists whose execution date is less than or equal to '||
   TO_CHAR(sysdate,'DD-MON-YYYY')||':'||v_total_requests);

   fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'Total number of undo lists which were not submitted for processing:'||v_failed_subrequests);

   FEM_ENGINES_PKG.put_message(p_app_name =>'FEM',
      p_msg_name => 'FEM_UD_SUBMIT_LIST_COMPLTD_TXT');

-- ============================================================================
-- SET STATUS
-- ============================================================================
   pv_concurrent_status := FND_CONCURRENT.Set_Completion_Status
      (status  => v_prg_stat, message => NULL);

   fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'End. '||to_char(sysdate,'MM/DD/YYYY HH:MI:SS'));
-- ============================================================================
-- EXCEPTIONS
-- ============================================================================
   EXCEPTION
      WHEN OTHERS THEN
      -- Unexpected exceptions
      -- Log the call stack and the Oracle error message to
      -- FND_LOG with the "unexpected exception" severity level.

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_unexpected,
            p_module   => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
            p_msg_text => SQLERRM);

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_unexpected,
            p_module   => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
            p_msg_text => dbms_utility.format_call_stack);

      -- Log the Oracle error message to the stack.
         FEM_ENGINES_PKG.user_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UNEXPECTED_ERROR',
            P_TOKEN1 => 'ERR_MSG',
            P_VALUE1 => SQLERRM,
            P_TRANS1 => 'N');

         fem_engines_pkg.user_message
          (p_app_name => 'FEM'
          ,p_msg_name => 'FEM_EXEC_RERUN');

         pv_concurrent_status := FND_CONCURRENT.Set_Completion_Status
         (status  => 'ERROR', message => NULL);

END submit_undo_lists;
-- *****************************************************************************
PROCEDURE undo_object_execution   (errbuf                         OUT NOCOPY VARCHAR2,
                                   retcode                        OUT NOCOPY VARCHAR2,
                                   p_object_id                    IN  NUMBER,
                                   p_request_id                   IN  NUMBER,
                                   p_folder_id                    IN  NUMBER,
                                   p_include_dependencies_flag    IN  VARCHAR2,
                                   p_ignore_dependency_errs_flag  IN  VARCHAR2) AS
-- ============================================================================
-- PUBLIC
-- This procedure procedure creates an undo list for the object execution, then
-- calls execute_undo_list.  This procedure will be invoked via concurrent manager.
-- ============================================================================

c_api_name  CONSTANT           VARCHAR2(30) := 'undo_object_execution';
v_count                        NUMBER;
v_undo_list_obj_def_id         NUMBER;
v_undo_list_obj_id             NUMBER;
v_previous_request_id          NUMBER;
v_return_status                VARCHAR2(30);
v_msg_count                    NUMBER;
v_msg_data                     VARCHAR2(32000);
v_req_phase   VARCHAR2(80);
v_req_status  VARCHAR2(80);
v_dev_phase  VARCHAR2(30);
v_dev_status  VARCHAR2(30);
v_req_message  VARCHAR2 (240);
v_prg_stat     VARCHAR2(40) := 'NORMAL';
v_check_status BOOLEAN;
v_subrequest_id                NUMBER;
v_exec_status_code VARCHAR2(80);
v_undo_list_exists VARCHAR2(1);


BEGIN
   fem_engines_pkg.tech_message(p_severity => pc_log_level_procedure,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'Begin. P_REQUEST_ID: '||p_request_id||
   ' P_FOLDER_ID: '||p_folder_id||
   ' P_OBJECT_ID: '||p_object_id||
   ' P_INCLUDE_DEPENDENCIES_FLAG: '||p_include_dependencies_flag||
   ' P_IGNORE_DEPENDENCY_ERRS_FLAG:'||p_ignore_dependency_errs_flag);

-- ============================================================================
-- VALIDATIONS
-- ============================================================================
   fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'Begin VALIDATIONS: '||to_char(sysdate,'MM/DD/YYYY HH:MI:SS'));

-- ============================================================================
-- V01a: Check to make sure object execution exists.
-- ============================================================================

   SELECT COUNT(*)
   INTO v_count
   FROM fem_pl_object_executions
   WHERE request_id = p_request_id
   AND object_id = p_object_id;

   IF v_count = 0 THEN
      RAISE e_object_execution_not_found;
   END IF;

-- ============================================================================
-- V01b: Check to make sure user can execute/read the object.
-- ============================================================================
   SELECT  count(*) INTO v_count
   FROM fem_user_folders u, fem_object_catalog_b o
   WHERE o.object_id = p_object_id
   AND o.folder_id = u.folder_id
   AND u.user_id = pv_apps_user_id;

   IF v_count = 0 THEN
      RAISE e_cannot_read_object;
   END IF;

-- Bug 4309949: Ignore folder security for Undo rules
-- ============================================================================
-- V02: Check to make sure folder exists, and that user has write access to folder.
-- This is the folder in which the undo list will be created.
-- ============================================================================
--   SELECT count(*)
--   INTO v_count
--   FROM fem_folders_b b
--   WHERE b.folder_id = p_folder_id
--   AND b.folder_id IN (SELECT u.folder_id FROM fem_user_folders u
--                     WHERE u.user_id = pv_apps_user_id
--                     AND u.write_flag = 'Y');

--   IF v_count = 0 THEN
--      RAISE e_invalid_folder;
--   END IF;

-- ============================================================================
-- V03: Check to make sure object execution is not RUNNING.
-- ============================================================================
   SELECT exec_status_code INTO v_exec_status_code
   FROM fem_pl_object_executions
   WHERE request_id = p_request_id
   AND object_id = p_object_id;

   IF v_exec_status_code = 'RUNNING' THEN
   -- Verify that the request is still running using fem_pl_pkg.set_exec_state

      fem_pl_pkg.set_exec_state (p_api_version => 1.0,
         p_commit => fnd_api.g_true,
         p_request_id => p_request_id,
         p_object_id => p_object_id,
         x_msg_count => v_msg_count,
         x_msg_data => v_msg_data,
         x_return_status => v_return_status);

      IF v_msg_count > 0 THEN
         Get_Put_Messages(
            p_msg_count       => v_msg_count,
            p_msg_data        => v_msg_data,
            p_user_msg        => 'N',
            p_module          => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name);
      END IF;
   END IF;

   SELECT exec_status_code INTO v_exec_status_code
   FROM fem_pl_object_executions
   WHERE request_id = p_request_id
   AND object_id = p_object_id;

   IF v_exec_status_code = 'RUNNING' THEN
      RAISE e_objexec_is_running;
   ELSE
   -- Create and execute undo list if object execution status <> 'RUNNING'.
   -- ============================================================================
   -- CREATE or RETRIEVE UNDO LIST
   -- ============================================================================
   -- If undo list already exists with the same name, post message and retrieve
   -- list ID from the database.
      BEGIN

         SELECT o.object_id, d.object_definition_id, o.object_name
         INTO v_undo_list_obj_id, v_undo_list_obj_def_id, pv_undo_object_name
         FROM fem_object_catalog_vl o, fem_object_definition_b d
         WHERE o.object_type_code = 'UNDO'
         AND o.object_id = d.object_id
         AND o.object_name = 'UNDO - REQUEST_ID: '||p_request_id||' OBJECT_ID: '||p_object_id;
         v_undo_list_exists := 'T';
      EXCEPTION WHEN NO_DATA_FOUND THEN
         v_undo_list_exists := 'F';
      END;

      IF v_undo_list_exists = 'F' THEN
      -- ============================================================================
      -- C1: Create undo list if it does not exist
      -- ============================================================================
         create_undo_list (p_api_version  => 1.0,
           p_commit                       => FND_API.G_TRUE,
           p_undo_list_name               => 'UNDO - REQUEST_ID: '||p_request_id||' OBJECT_ID: '||p_object_id,
           p_folder_id                    => pc_undo_folder_id,
           p_include_dependencies_flag    => NVL(p_include_dependencies_flag,'Y'),
           p_ignore_dependency_errs_flag  => NVL(p_ignore_dependency_errs_flag,'N'),
           p_execution_date               => sysdate,
           x_undo_list_obj_id             => v_undo_list_obj_id,
           x_undo_list_obj_def_id         => v_undo_list_obj_def_id,
           x_return_status                => v_return_status,
           x_msg_count                    => v_msg_count,
           x_msg_data                     => v_msg_data);

         IF v_return_status <> pc_ret_sts_success THEN
            Get_Put_Messages(
               p_msg_count       => v_msg_count,
               p_msg_data        => v_msg_data,
               p_user_msg        => 'Y',
               p_module          => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name);
            ROLLBACK;
            RAISE e_cannot_create_undo_list;
         ELSIF v_msg_count > 0 THEN
            Get_Put_Messages(
               p_msg_count       => v_msg_count,
               p_msg_data        => v_msg_data,
               p_user_msg        => 'N',
               p_module          => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name);
         END IF;

         pv_undo_object_name := 'UNDO - REQUEST_ID: '||p_request_id||' OBJECT_ID: '||p_object_id;
      -- ============================================================================
      -- C2: Add object execution to undo list as candidate
      -- ============================================================================
         add_candidate (p_api_version     => 1.0,
           p_commit                       => FND_API.G_TRUE,
           p_undo_list_obj_def_id         => v_undo_list_obj_def_id,
           p_request_id                   => p_request_id,
           p_object_id                    => p_object_id,
           x_return_status                => v_return_status,
           x_msg_count                    => v_msg_count,
           x_msg_data                     => v_msg_data);

         IF v_return_status <> pc_ret_sts_success THEN
            Get_Put_Messages(
               p_msg_count       => v_msg_count,
               p_msg_data        => v_msg_data,
               p_user_msg        => 'Y',
               p_module          => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name);
            ROLLBACK;
            RAISE e_cannot_add_candidate;

         ELSIF v_msg_count > 0 THEN
            Get_Put_Messages(
               p_msg_count       => v_msg_count,
               p_msg_data        => v_msg_data,
               p_user_msg        => 'N',
               p_module          => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name);
         END IF;
      END IF;

   -- =========================================================================
   -- SUBMIT undo list for processing.
   -- =========================================================================
      execute_undo_list(
         errbuf                         => errbuf,
         retcode                        => retcode,
         p_undo_list_obj_id             => v_undo_list_obj_id);

   END IF;
-- ============================================================================
-- SET STATUS
-- ============================================================================
   fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'End. '||to_char(sysdate,'MM/DD/YYYY HH:MI:SS'));
-- ============================================================================
-- EXCEPTIONS
-- ============================================================================
   EXCEPTION
      WHEN e_object_execution_not_found THEN
         FEM_ENGINES_PKG.user_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UD_OBJ_EXEC_NOT_FOUND_WRN',
            p_token1 => 'REQUEST_ID',
            p_value1 => p_request_id,
            p_trans1 => 'N',
            p_token2 => 'OBJECT_ID',
            p_value2 => p_object_id,
            p_trans2 => 'N');

         FEM_ENGINES_PKG.user_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UD_CANNOT_CREATE_LIST_ERR');

         fem_engines_pkg.tech_message(p_severity => pc_log_level_exception,
         p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
            p_msg_name => 'FEM_UD_OBJ_EXEC_NOT_FOUND_WRN',
            p_token1 => 'REQUEST_ID',
            p_value1 => p_request_id,
            p_trans1 => 'N',
            p_token2 => 'OBJECT_ID',
            p_value2 => p_object_id,
            p_trans2 => 'N');

         fem_engines_pkg.tech_message(p_severity => pc_log_level_exception,
         p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
         p_msg_name =>'FEM_UD_CANNOT_CREATE_LIST_ERR');

         FEM_ENGINES_PKG.USER_MESSAGE
          (P_APP_NAME => 'FEM'
          ,P_MSG_NAME => 'FEM_EXEC_RERUN');

         pv_concurrent_status := FND_CONCURRENT.Set_Completion_Status
         (status  => 'ERROR', message => NULL);

      WHEN e_cannot_read_object THEN
         ROLLBACK;
         FEM_ENGINES_PKG.user_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UD_CANNOT_READ_OBJECT_ERR');

         fem_engines_pkg.tech_message(p_severity => pc_log_level_exception,
            p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
            p_msg_name => 'FEM_UD_CANNOT_READ_OBJECT_ERR');

         FEM_ENGINES_PKG.USER_MESSAGE
          (P_APP_NAME => 'FEM'
          ,P_MSG_NAME => 'FEM_EXEC_RERUN');

         pv_concurrent_status := FND_CONCURRENT.Set_Completion_Status
         (status  => 'ERROR', message => NULL);

      WHEN e_invalid_folder THEN
         fem_engines_pkg.user_message(p_app_name =>'FEM',
         p_msg_name =>'FEM_IMPEXP_INVALID_FOLDER_ERR',
         p_token1 => 'FOLDER',
         p_value1 => p_folder_id,
         p_trans1 => 'N');

         fem_engines_pkg.tech_message(p_severity => pc_log_level_exception,
         p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
         p_msg_name =>'FEM_IMPEXP_INVALID_FOLDER_ERR',
         p_token1 => 'FOLDER',
         p_value1 => p_folder_id,
         p_trans1 => 'N');

         FEM_ENGINES_PKG.USER_MESSAGE
          (P_APP_NAME => 'FEM'
          ,P_MSG_NAME => 'FEM_EXEC_RERUN');

         pv_concurrent_status := FND_CONCURRENT.Set_Completion_Status
         (status  => 'ERROR', message => NULL);

      WHEN e_objexec_is_running THEN
         FEM_ENGINES_PKG.user_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UD_OBJEXEC_IS_RUNNING_ERR');

         fem_engines_pkg.tech_message(p_severity => pc_log_level_exception,
         p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
         p_msg_name =>'FEM_UD_OBJEXEC_IS_RUNNING_ERR');

         FEM_ENGINES_PKG.USER_MESSAGE
          (P_APP_NAME => 'FEM'
          ,P_MSG_NAME => 'FEM_EXEC_RERUN');

         pv_concurrent_status := FND_CONCURRENT.Set_Completion_Status
         (status  => 'ERROR', message => NULL);

      WHEN e_cannot_create_undo_list THEN
         fem_engines_pkg.user_message(p_app_name =>'FEM',
         p_msg_name =>'FEM_UD_CANNOT_CREATE_LIST_ERR');

         fem_engines_pkg.tech_message(p_severity => pc_log_level_exception,
         p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
         p_msg_name =>'FEM_UD_CANNOT_CREATE_LIST_ERR');

         FEM_ENGINES_PKG.USER_MESSAGE
          (P_APP_NAME => 'FEM'
          ,P_MSG_NAME => 'FEM_EXEC_RERUN');

         pv_concurrent_status := FND_CONCURRENT.Set_Completion_Status
         (status  => 'ERROR', message => NULL);

      WHEN e_cannot_add_candidate THEN
         fem_engines_pkg.user_message(p_app_name =>'FEM',
         p_msg_name =>'FEM_UD_CANNOT_ADD_CANDIDT_ERR');

         fem_engines_pkg.tech_message(p_severity => pc_log_level_exception,
         p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
         p_msg_name =>'FEM_UD_CANNOT_ADD_CANDIDT_ERR');

         FEM_ENGINES_PKG.USER_MESSAGE
          (P_APP_NAME => 'FEM'
          ,P_MSG_NAME => 'FEM_EXEC_RERUN');

         pv_concurrent_status := FND_CONCURRENT.Set_Completion_Status
         (status  => 'ERROR', message => NULL);

      WHEN OTHERS THEN
      -- Unexpected exceptions
      -- Log the call stack and the Oracle error message to
      -- FND_LOG with the "unexpected exception" severity level.

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_unexpected,
            p_module   => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
            p_msg_text => SQLERRM);

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_unexpected,
            p_module   => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
            p_msg_text => dbms_utility.format_call_stack);

      -- Log the Oracle error message to the stack.
         FEM_ENGINES_PKG.user_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UNEXPECTED_ERROR',
            P_TOKEN1 => 'ERR_MSG',
            P_VALUE1 => SQLERRM);

         FEM_ENGINES_PKG.USER_MESSAGE
          (P_APP_NAME => 'FEM'
          ,P_MSG_NAME => 'FEM_EXEC_RERUN');

         pv_concurrent_status := FND_CONCURRENT.Set_Completion_Status
         (status  => 'ERROR', message => NULL);

END undo_object_execution;

-- *****************************************************************************
PROCEDURE undo_request_by_rule_set (errbuf                         OUT NOCOPY VARCHAR2,
                                    retcode                        OUT NOCOPY VARCHAR2,
                                    p_rule_set_obj_def_id          IN  NUMBER,
                                    p_ledger_id                    IN  NUMBER,
                                    p_ds_io_obj_def_id             IN  NUMBER,
                                    p_include_dependencies_flag    IN  VARCHAR2,
                                    p_ignore_dependency_errs_flag  IN  VARCHAR2,
                                    p_output_period                IN  NUMBER) AS
-- ============================================================================
-- PUBLIC
-- This procedure uses its parameters to look up a single Request ID, which it
-- passes to the Undo_All_Obj_Execs_In_Request procedure, to undo that request.
-- This procedure will be invoked via concurrent manager.  See ER# 7562331.
-- ============================================================================

c_api_name    CONSTANT           VARCHAR2(30) := 'undo_request_by_rule_set';

v_request_id  NUMBER;

BEGIN

   FEM_ENGINES_PKG.tech_message
     (p_severity => pc_log_level_procedure,
      p_module   => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
      p_msg_text => 'Begin...');

-- Find matching Request ID

   BEGIN

      SELECT request_id
      INTO v_request_id
      FROM fem_pl_requests
      WHERE rule_set_obj_def_id   = p_rule_set_obj_def_id
        AND ledger_id             = p_ledger_id
        AND dataset_io_obj_def_id = p_ds_io_obj_def_id
        AND cal_period_id         = p_output_period;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RAISE e_request_not_found;

      WHEN TOO_MANY_ROWS THEN
         RAISE e_multiple_requests_found;

   END;

-- Rule Set execution found:  Request ID: || TO_CHAR(v_request_id)

   FEM_ENGINES_PKG.user_message
     (p_app_name => 'FEM',
      p_msg_name => 'FEM_UNDO_FOUND_REQUEST',
      p_token1   => 'REQUEST_ID',
      p_value1   => TO_CHAR(v_request_id));

   FEM_ENGINES_PKG.tech_message
     (p_severity => pc_log_level_event,
      p_module   => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
      p_msg_name => 'FEM_UNDO_FOUND_REQUEST',
      p_token1   => 'REQUEST_ID',
      p_value1   => TO_CHAR(v_request_id));

-- Call Executed Rule Request Removal (undo_all_obj_execs_in_request)

   undo_all_obj_execs_in_request
     (errbuf                        => errbuf,
      retcode                       => retcode,
      p_request_id                  => v_request_id,
      p_folder_id                   => 1100,
      p_include_dependencies_flag   => p_include_dependencies_flag,
      p_ignore_dependency_errs_flag => p_ignore_dependency_errs_flag);

-- Status is already set by undo_all_obj_execs_in_request

   FEM_ENGINES_PKG.tech_message
     (p_severity => pc_log_level_procedure,
      p_module   => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
      p_msg_text => 'End.');

EXCEPTION
   WHEN e_request_not_found THEN
   -- ERROR:  No rule set execution was found for the specified
   -- rule set, ledger, dataset group and calendar period.

      FEM_ENGINES_PKG.user_message
        (p_app_name => 'FEM',
         p_msg_name => 'FEM_UNDO_REQUEST_NOT_FOUND');

      fem_engines_pkg.tech_message
        (p_severity => pc_log_level_error,
         p_module   => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
         p_msg_name => 'FEM_UNDO_REQUEST_NOT_FOUND');

      pv_concurrent_status := FND_CONCURRENT.Set_Completion_Status
                                 (status  => 'ERROR', message => NULL);

   WHEN e_multiple_requests_found THEN
   -- ERROR:  More than one rule set execution was found for the
   -- specified rule set, ledger, dataset group and calendar period.
   -- Please contact Oracle Support.
      FEM_ENGINES_PKG.user_message
        (p_app_name => 'FEM',
         p_msg_name => 'FEM_UNDO_TOO_MANY_REQUESTS');

      fem_engines_pkg.tech_message
        (p_severity => pc_log_level_error,
         p_module   => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
         p_msg_name => 'FEM_UNDO_TOO_MANY_REQUESTS');

      pv_concurrent_status := FND_CONCURRENT.Set_Completion_Status
                                 (status  => 'ERROR', message => NULL);

END undo_request_by_rule_set;

-- *****************************************************************************
PROCEDURE undo_all_obj_execs_in_request (errbuf                         OUT NOCOPY VARCHAR2,
                                         retcode                        OUT NOCOPY VARCHAR2,
                                         p_request_id                   IN  NUMBER,
                                         p_folder_id                    IN  NUMBER,
                                         p_include_dependencies_flag    IN  VARCHAR2,
                                         p_ignore_dependency_errs_flag  IN  VARCHAR2) AS
-- ============================================================================
-- PUBLIC
-- This procedure creates an undo list for all object executions in a request,
-- then submits the newly created undo list to the undo engine.  This
-- procedure will be invoked via concurrent manager.
-- ============================================================================

c_api_name  CONSTANT           VARCHAR2(30) := 'undo_all_obj_execs_in_request';
v_count                        NUMBER;
v_undo_list_obj_def_id         NUMBER;
v_undo_list_obj_id             NUMBER;
v_previous_request_id          NUMBER;
v_return_status                VARCHAR2(30);
v_msg_count                    NUMBER;
v_msg_data                     VARCHAR2(32000);
v_req_phase   VARCHAR2(80);
v_req_status  VARCHAR2(80);
v_dev_phase  VARCHAR2(30);
v_dev_status  VARCHAR2(30);
v_req_message  VARCHAR2 (240);
v_prg_stat     VARCHAR2(40) := 'NORMAL';
v_check_status BOOLEAN;
v_subrequest_id NUMBER;
v_request_id NUMBER := p_request_id;
v_exec_status_code VARCHAR2(150);
v_undo_list_exists VARCHAR2(1);
v_object_id NUMBER;

CURSOR c1 IS
   SELECT object_id
   FROM fem_pl_object_executions
   WHERE request_id = p_request_id
   ORDER BY event_order;

BEGIN
   fem_engines_pkg.tech_message(p_severity => pc_log_level_procedure,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'Begin. P_REQUEST_ID: '||p_request_id||
   ' P_FOLDER_ID: '||p_folder_id||
   ' P_INCLUDE_DEPENDENCIES_FLAG: '||p_include_dependencies_flag||
   ' P_IGNORE_DEPENDENCY_ERRS_FLAG:'||p_ignore_dependency_errs_flag);

-- ============================================================================
-- VALIDATIONS
-- ============================================================================
   fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'Begin VALIDATIONS: '||to_char(sysdate,'MM/DD/YYYY HH:MI:SS'));

-- Bug 4309949: Ignore folder security for Undo rules
-- ============================================================================
-- V01: Check to make sure folder exists, and that user has write access to folder
-- ============================================================================
--   SELECT count(*)
--   INTO v_count
--   FROM fem_folders_b b
--   WHERE b.folder_id = p_folder_id
--   AND b.folder_id IN (SELECT u.folder_id FROM fem_user_folders u
--                     WHERE u.user_id = pv_apps_user_id
--                     AND u.write_flag = 'Y');

--   IF v_count = 0 THEN
--      RAISE e_invalid_folder;
--   END IF;

-- ============================================================================
-- V02: Check to make sure request exists.
-- ============================================================================

   SELECT COUNT(*)
   INTO v_count
   FROM fem_pl_requests
   WHERE request_id = p_request_id;

   IF v_count = 0 THEN
      RAISE e_request_not_found;
   END IF;

-- ============================================================================
-- V03: Check to make sure request is not running.
-- ============================================================================
   v_check_status := fnd_concurrent.get_request_status (
       request_id    => v_request_id,
       phase         => v_req_phase,
       status        => v_req_status,
       dev_phase     => v_dev_phase,
       dev_status    => v_dev_status,
       message       => v_req_message);

   IF v_dev_phase <> 'COMPLETE' THEN
      RAISE e_request_is_running;
   END IF;

-- ============================================================================
-- V04: Check to make sure request has one or more object executions.
-- If request has no object executions, then unregister the request.
-- ============================================================================

   SELECT count(*) INTO v_count
   FROM fem_pl_object_executions
   WHERE request_id = p_request_id;

   IF v_count = 0 THEN
   -- IF there are no candidates (no object executions) for this request,
   -- then unregister the request.

      fem_pl_pkg.unregister_request (
         p_api_version            => 1.0,
         p_commit                 => FND_API.G_TRUE,
         p_request_id             => p_request_id,
         x_msg_count              => v_msg_count,
         x_msg_data               => v_msg_data,
         x_return_status          => v_return_status);


      IF v_return_status = pc_ret_sts_success THEN

         DELETE fem_pl_temp_objects
         WHERE request_id = p_request_id;

         DELETE fem_pl_obj_exec_steps
         WHERE request_id = p_request_id;

         DELETE fem_pl_chains
         WHERE request_id = p_request_id;

         DELETE fem_pl_object_defs
         WHERE request_id = p_request_id;

         COMMIT;

         FEM_ENGINES_PKG.USER_MESSAGE
          (P_APP_NAME => 'FEM'
          ,P_MSG_NAME => 'FEM_EXEC_SUCCESS');

         pv_concurrent_status := FND_CONCURRENT.Set_Completion_Status
            (status  => 'NORMAL', message => NULL);

      ELSE
         FEM_ENGINES_PKG.USER_MESSAGE
          (P_APP_NAME => 'FEM'
          ,P_MSG_NAME => 'FEM_EXEC_RERUN');

         pv_concurrent_status := FND_CONCURRENT.Set_Completion_Status
            (status  => 'ERROR', message => NULL);
      END IF;

   ELSE

   -- ============================================================================
   -- V05: Check to make sure user can execute/read all objects in the request.
   -- ============================================================================

      SELECT  count(*) INTO v_count
      FROM fem_object_catalog_b o, fem_pl_object_executions p
      WHERE p.request_id = p_request_id
      AND p.object_id = o.object_id
      AND o.folder_id NOT IN
         (SELECT folder_id
            FROM fem_user_folders
            WHERE user_id = pv_apps_user_id);

      IF v_count > 0 THEN
         RAISE e_cannot_read_object;
      END IF;


   -- Create and execute undo list if request status <> 'RUNNING'.
   -- ============================================================================
   -- CREATE or RETRIEVE UNDO LIST
   -- ============================================================================
   -- If undo list already exists with the same name, post message and retrieve
   -- list ID from the database.
      BEGIN

         SELECT o.object_id, d.object_definition_id, o.object_name
         INTO v_undo_list_obj_id, v_undo_list_obj_def_id, pv_undo_object_name
         FROM fem_object_catalog_vl o, fem_object_definition_b d
         WHERE o.object_type_code = 'UNDO'
         AND o.object_id = d.object_id
         AND o.object_name = 'UNDO - REQUEST_ID: '||p_request_id;
         v_undo_list_exists := 'T';

         fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
         p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
         p_msg_text => 'Undo list already exists.  OBJECT_ID:'||v_undo_list_obj_id||
         ' OBJECT_DEFINITION_ID:'||v_undo_list_obj_def_id);

      EXCEPTION WHEN NO_DATA_FOUND THEN
         v_undo_list_exists := 'F';
      END;

      IF v_undo_list_exists = 'F' THEN
      -- ============================================================================
      -- CREATE UNDO LIST
      -- ============================================================================
      -- ============================================================================
      -- C1: Create undo list
      -- ============================================================================
         create_undo_list (p_api_version  => 1.0,
           p_commit                       => FND_API.G_TRUE,
           p_undo_list_name               => 'UNDO - REQUEST_ID: '||p_request_id,
           p_folder_id                    => pc_undo_folder_id,
           p_include_dependencies_flag    => NVL(p_include_dependencies_flag,'Y'),
           p_ignore_dependency_errs_flag  => NVL(p_ignore_dependency_errs_flag,'N'),
           p_execution_date               => sysdate,
           x_undo_list_obj_id             => v_undo_list_obj_id,
           x_undo_list_obj_def_id         => v_undo_list_obj_def_id,
           x_return_status                => v_return_status,
           x_msg_count                    => v_msg_count,
           x_msg_data                     => v_msg_data);

         IF v_return_status <> pc_ret_sts_success THEN
            Get_Put_Messages(
               p_msg_count       => v_msg_count,
               p_msg_data        => v_msg_data,
               p_user_msg        => 'Y',
               p_module          => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name);
            ROLLBACK;
            RAISE e_cannot_create_undo_list;
         ELSIF v_msg_count > 0 THEN
            Get_Put_Messages(
               p_msg_count       => v_msg_count,
               p_msg_data        => v_msg_data,
               p_user_msg        => 'N',
               p_module          => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name);
         END IF;

         pv_undo_object_name := 'UNDO - REQUEST_ID: '||p_request_id;
      -- ============================================================================
      -- C2: Add object executions to undo list as candidates
      -- ============================================================================
         v_count := 0;

         FOR acandidate IN c1 LOOP
            v_count := c1%ROWCOUNT;
            add_candidate (p_api_version     => 1.0,
              p_commit                       => FND_API.G_TRUE,
              p_undo_list_obj_def_id         => v_undo_list_obj_def_id,
              p_request_id                   => p_request_id,
              p_object_id                    => acandidate.object_id,
              x_return_status                => v_return_status,
              x_msg_count                    => v_msg_count,
              x_msg_data                     => v_msg_data);

            IF v_return_status <> pc_ret_sts_success THEN
               Get_Put_Messages(
                  p_msg_count       => v_msg_count,
                  p_msg_data        => v_msg_data,
                  p_user_msg        => 'Y',
                  p_module          => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name);
               ROLLBACK;
               RAISE e_cannot_add_candidate;

            ELSIF v_msg_count > 0 THEN
               Get_Put_Messages(
                  p_msg_count       => v_msg_count,
                  p_msg_data        => v_msg_data,
                  p_user_msg        => 'N',
                  p_module          => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name);
            END IF;

          END LOOP;

         IF v_count = 0 THEN
            RAISE e_list_has_no_candidates;
         END IF;
      END IF;

   -- =========================================================================
   -- SUBMIT undo list for processing.
   -- =========================================================================

         execute_undo_list(
            errbuf                         => errbuf,
            retcode                        => retcode,
            p_undo_list_obj_id             => v_undo_list_obj_id);

   END IF;
-- ============================================================================
-- SET STATUS
-- ============================================================================
   fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'End. '||to_char(sysdate,'MM/DD/YYYY HH:MI:SS'));
-- ============================================================================
-- EXCEPTIONS
-- ============================================================================
   EXCEPTION
      WHEN e_request_not_found THEN
         FEM_ENGINES_PKG.user_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UD_REQUEST_NOT_FOUND_WRN',
            p_token1 => 'REQUEST_ID',
            p_value1 => p_request_id,
            p_trans1 => 'N');

         FEM_ENGINES_PKG.user_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UD_CANNOT_CREATE_LIST_ERR');

         FEM_ENGINES_PKG.USER_MESSAGE
          (P_APP_NAME => 'FEM'
          ,P_MSG_NAME => 'FEM_EXEC_RERUN');

         fem_engines_pkg.tech_message(p_severity => pc_log_level_exception,
         p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
            p_msg_name => 'FEM_UD_REQUEST_NOT_FOUND_WRN',
            p_token1 => 'REQUEST_ID',
            p_value1 => p_request_id,
            p_trans1 => 'N');

         fem_engines_pkg.tech_message(p_severity => pc_log_level_exception,
         p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
         p_msg_name =>'FEM_UD_CANNOT_CREATE_LIST_ERR');

         pv_concurrent_status := FND_CONCURRENT.Set_Completion_Status
         (status  => 'ERROR', message => NULL);

      WHEN e_invalid_folder THEN
         fem_engines_pkg.user_message(p_app_name =>'FEM',
         p_msg_name =>'FEM_IMPEXP_INVALID_FOLDER_ERR',
         p_token1 => 'FOLDER',
         p_value1 => p_folder_id,
         p_trans1 => 'N');

         FEM_ENGINES_PKG.USER_MESSAGE
          (P_APP_NAME => 'FEM'
          ,P_MSG_NAME => 'FEM_EXEC_RERUN');

         fem_engines_pkg.tech_message(p_severity => pc_log_level_exception,
         p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
         p_msg_name =>'FEM_IMPEXP_INVALID_FOLDER_ERR');

         pv_concurrent_status := FND_CONCURRENT.Set_Completion_Status
         (status  => 'ERROR', message => NULL);

      WHEN e_request_is_running THEN
         FEM_ENGINES_PKG.user_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UD_REQUEST_IS_RUNNING_ERR');

         FEM_ENGINES_PKG.user_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UD_CANNOT_UNDO_REQUEST_ERR');

         FEM_ENGINES_PKG.USER_MESSAGE
          (P_APP_NAME => 'FEM'
          ,P_MSG_NAME => 'FEM_EXEC_RERUN');

         fem_engines_pkg.tech_message(p_severity => pc_log_level_exception,
         p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
         p_msg_name =>'FEM_UD_REQUEST_IS_RUNNING_ERR');

         pv_concurrent_status := FND_CONCURRENT.Set_Completion_Status
         (status  => 'ERROR', message => NULL);

      WHEN e_cannot_read_object THEN

         FEM_ENGINES_PKG.user_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UD_CANNOT_READ_OBJECT_ERR');

         FEM_ENGINES_PKG.user_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UD_CANNOT_UNDO_REQUEST_ERR');

         fem_engines_pkg.tech_message(p_severity => pc_log_level_exception,
            p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
            p_msg_name => 'FEM_UD_CANNOT_READ_OBJECT_ERR');


         FEM_ENGINES_PKG.USER_MESSAGE
          (P_APP_NAME => 'FEM'
          ,P_MSG_NAME => 'FEM_EXEC_RERUN');

         pv_concurrent_status := FND_CONCURRENT.Set_Completion_Status
         (status  => 'ERROR', message => NULL);

      WHEN e_cannot_create_undo_list THEN
         fem_engines_pkg.user_message(p_app_name =>'FEM',
         p_msg_name =>'FEM_UD_CANNOT_CREATE_LIST_ERR');

         FEM_ENGINES_PKG.USER_MESSAGE
          (P_APP_NAME => 'FEM'
          ,P_MSG_NAME => 'FEM_EXEC_RERUN');

         fem_engines_pkg.tech_message(p_severity => pc_log_level_exception,
         p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
         p_msg_name =>'FEM_UD_CANNOT_CREATE_LIST_ERR');

         pv_concurrent_status := FND_CONCURRENT.Set_Completion_Status
         (status  => 'ERROR', message => NULL);

      WHEN e_cannot_add_candidate THEN
         fem_engines_pkg.user_message(p_app_name =>'FEM',
         p_msg_name =>'FEM_UD_CANNOT_ADD_CANDIDT_ERR');

         FEM_ENGINES_PKG.user_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UD_CANNOT_UNDO_REQUEST_ERR');

         FEM_ENGINES_PKG.USER_MESSAGE
          (P_APP_NAME => 'FEM'
          ,P_MSG_NAME => 'FEM_EXEC_RERUN');

         fem_engines_pkg.tech_message(p_severity => pc_log_level_exception,
         p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
         p_msg_name =>'FEM_UD_CANNOT_ADD_CANDIDT_ERR');

        pv_concurrent_status := FND_CONCURRENT.Set_Completion_Status
         (status  => 'ERROR', message => NULL);

      WHEN e_list_has_no_candidates THEN
         retcode := pc_ret_sts_error;

         FEM_ENGINES_PKG.user_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UD_NO_CANDIDATES_ERR');

         fem_engines_pkg.tech_message(p_severity => pc_log_level_exception,
         p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
         p_msg_name =>'FEM_UD_NO_CANDIDATES_ERR');

         FEM_ENGINES_PKG.USER_MESSAGE
          (P_APP_NAME => 'FEM'
          ,P_MSG_NAME => 'FEM_EXEC_RERUN');

         pv_concurrent_status := FND_CONCURRENT.Set_Completion_Status
         (status  => 'ERROR', message => NULL);

      WHEN OTHERS THEN
      -- Unexpected exceptions
      -- Log the call stack and the Oracle error message to
      -- FND_LOG with the "unexpected exception" severity level.

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_unexpected,
            p_module   => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
            p_msg_text => SQLERRM);

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_unexpected,
            p_module   => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
            p_msg_text => dbms_utility.format_call_stack);

      -- Log the Oracle error message to the stack.
         FEM_ENGINES_PKG.user_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UNEXPECTED_ERROR',
            P_TOKEN1 => 'ERR_MSG',
            P_VALUE1 => SQLERRM,
            P_TRANS1 => 'N');

         FEM_ENGINES_PKG.USER_MESSAGE
          (P_APP_NAME => 'FEM'
          ,P_MSG_NAME => 'FEM_EXEC_RERUN');

         pv_concurrent_status := FND_CONCURRENT.Set_Completion_Status
         (status  => 'ERROR', message => NULL);
 END undo_all_obj_execs_in_request;

-- *****************************************************************************
PROCEDURE create_and_submit_prview_list (x_request_id                   OUT NOCOPY NUMBER,
                                         x_undo_list_obj_id             OUT NOCOPY NUMBER,
                                         x_undo_list_obj_def_id         OUT NOCOPY NUMBER,
                                         x_return_status                OUT NOCOPY VARCHAR2,
                                         x_msg_count                    OUT NOCOPY NUMBER,
                                         x_msg_data                     OUT NOCOPY VARCHAR2,
                                         p_api_version                  IN  NUMBER,
                                         p_undo_list_name               IN  VARCHAR2,
                                         p_folder_id                    IN  NUMBER,
                                         p_ud_session_id                IN  NUMBER) AS

-- ============================================================================
-- PUBLIC
-- This procedure creates an undo list and submits it to concurrent manager
-- for processing by the undo engine.
-- The logic of this procedure is designed to support the initial phase of the
-- undo user interface (FEM.D).  In this release, folder security is implemented,
-- and the user interface does not provide a means for the user to review an
-- existing undo list.  That is why the undo list is deleted if it is not
-- successfully submitted to concurrent manager, as the user will not have
-- a means to resubmit the list to concurrent manager.
-- Parameter descriptions:
-- p_api_version - Version of the API
-- p_undo_list_name - Name of undo list
-- p_folder_id - Name of folder in which undo will be created.  References
--               fem_folders_vl.folder_id.
-- p_ud_session_id - This is the identifier for the user interface session.  It
--                is used to identify the rows to retrieve from the
--                FEM_UD_PRVIEW_xxx tables.
-- ============================================================================
c_api_name  CONSTANT           VARCHAR2(30) := 'create_and_submit_prview_list';
v_count                        NUMBER;
v_undo_list_obj_def_id         NUMBER;
v_undo_list_obj_id             NUMBER;
v_exec_status_code             VARCHAR2(80);
v_undo_list_exists             VARCHAR2(1);

-- This query retrieves all candidate object executions in undo session.
CURSOR  c1 IS
   SELECT c.request_id, c.object_id, pl.exec_status_code
   FROM fem_ud_prview_candidates c, fem_pl_object_executions pl
   WHERE c.ud_session_id = p_ud_session_id
   AND c.request_id = pl.request_id (+)
   AND c.object_id = pl.object_id (+)
   ORDER BY c.request_id, c.object_id;

BEGIN
   fem_engines_pkg.tech_message(p_severity => pc_log_level_procedure,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'Begin. P_UNDO_LIST_NAME: '||p_undo_list_name||
   ' P_FOLDER_ID: '||p_folder_id||
   ' P_UD_SESSION_ID: '||p_ud_session_id);

   x_return_status := pc_ret_sts_success;

-- ============================================================================
-- VALIDATIONS
-- ============================================================================
   fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'Begin VALIDATIONS: '||to_char(sysdate,'MM/DD/YYYY HH:MI:SS'));

-- Bug 4309949: Ignore folder security for Undo rules
-- ============================================================================
-- V02: Check to make sure folder exists, and that user has write privileges
-- on the folder.
-- ============================================================================
--   SELECT count(*)
--   INTO v_count
--   FROM fem_folders_b b
--   WHERE b.folder_id = p_folder_id
--   AND b.folder_id IN (SELECT u.folder_id FROM fem_user_folders u
--                     WHERE u.user_id = pv_apps_user_id
--                     AND u.write_flag = 'Y');

--   IF v_count = 0 THEN
--      RAISE e_invalid_folder;
--   END IF;

-- ============================================================================
-- V03: Check to make sure object executions are not RUNNING.
-- ============================================================================
   fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'V03: Check to make sure object executions are not RUNNING: '||to_char(sysdate,'MM/DD/YYYY HH:MI:SS'));

   FOR cand_num IN c1 LOOP

      fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
      p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
      p_msg_text => 'Candidate Number:'||c1%ROWCOUNT||' REQUEST_ID:'||cand_num.request_id||
      ' OBJECT_ID:'||cand_num.object_id||to_char(sysdate,'MM/DD/YYYY HH:MI:SS'));

      IF cand_num.exec_status_code = 'RUNNING' THEN
      -- Verify that the request is still running using fem_pl_pkg.set_exec_state

         fem_pl_pkg.set_exec_state (p_api_version => 1.0,
            p_commit => fnd_api.g_true,
            p_request_id => cand_num.request_id,
            p_object_id => cand_num.object_id,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data,
            x_return_status => x_return_status);

         IF x_msg_count > 0 THEN
            Get_Put_Messages(
               p_msg_count       => x_msg_count,
               p_msg_data        => x_msg_data,
               p_user_msg        => 'N',
               p_module          => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name);
         END IF;
      END IF;

      SELECT exec_status_code INTO v_exec_status_code
      FROM fem_pl_object_executions
      WHERE request_id = cand_num.request_id
      AND object_id = cand_num.object_id;

      IF v_exec_status_code = 'RUNNING' THEN
         RAISE e_objexec_is_running;
      END IF;
   END LOOP;

-- Create and execute undo list if all object executions' status <> 'RUNNING'.
-- ============================================================================
-- CREATE or RETRIEVE UNDO LIST
-- ============================================================================
-- If undo list already exists with the same name, post message and retrieve
-- list ID from the database.
   BEGIN

      SELECT o.object_id, d.object_definition_id
      INTO v_undo_list_obj_id, v_undo_list_obj_def_id
      FROM fem_object_catalog_vl o, fem_object_definition_b d
      WHERE o.object_type_code = 'UNDO'
      AND o.object_id = d.object_id
      AND o.object_name = p_undo_list_name;
      v_undo_list_exists := 'T';
   EXCEPTION WHEN NO_DATA_FOUND THEN
      v_undo_list_exists := 'F';
   END;

   IF v_undo_list_exists = 'F' THEN
   -- ============================================================================
   -- C1: Create undo list if it does not exist
   -- ============================================================================
      create_undo_list (p_api_version  => 1.0,
        p_commit                       => FND_API.G_FALSE,
        p_undo_list_name               => p_undo_list_name,
        p_folder_id                    => pc_undo_folder_id,
        p_include_dependencies_flag    => ('Y'),
        p_ignore_dependency_errs_flag  => ('N'),
        p_execution_date               => sysdate,
        x_undo_list_obj_id             => v_undo_list_obj_id,
        x_undo_list_obj_def_id         => v_undo_list_obj_def_id,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data);

      IF x_return_status <> pc_ret_sts_success THEN
         Get_Put_Messages(
            p_msg_count       => x_msg_count,
            p_msg_data        => x_msg_data,
            p_user_msg        => 'Y',
            p_module          => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name);
         ROLLBACK;
         RAISE e_cannot_create_undo_list;
      ELSIF x_msg_count > 0 THEN
         Get_Put_Messages(
            p_msg_count       => x_msg_count,
            p_msg_data        => x_msg_data,
            p_user_msg        => 'N',
            p_module          => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name);
      END IF;

   -- ============================================================================
   -- C2: Add object executions to undo list as candidates
   -- ============================================================================
      FOR cand_num IN c1 LOOP
         add_candidate (p_api_version     => 1.0,
           p_commit                       => FND_API.G_FALSE,
           p_undo_list_obj_def_id         => v_undo_list_obj_def_id,
           p_request_id                   => cand_num.request_id,
           p_object_id                    => cand_num.object_id,
           x_return_status                => x_return_status,
           x_msg_count                    => x_msg_count,
           x_msg_data                     => x_msg_data);

         IF x_return_status <> pc_ret_sts_success THEN
            Get_Put_Messages(
               p_msg_count       => x_msg_count,
               p_msg_data        => x_msg_data,
               p_user_msg        => 'Y',
               p_module          => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name);
            ROLLBACK;
            RAISE e_cannot_add_candidate;

         ELSIF x_msg_count > 0 THEN
            Get_Put_Messages(
               p_msg_count       => x_msg_count,
               p_msg_data        => x_msg_data,
               p_user_msg        => 'N',
               p_module          => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name);
         END IF;
      END LOOP;
   END IF;

   COMMIT;

-- ============================================================================
-- SUBMIT undo list for processing.  If list is not submitted successfully,
-- delete list.
-- ============================================================================
   x_request_id :=   FND_REQUEST.SUBMIT_REQUEST(
                     application => 'FEM',
                     program => 'FEM_UNDO_LIST',
                     sub_request => FALSE,
                     argument1 => v_undo_list_obj_id);

   IF (x_request_id = 0) THEN

      RAISE e_cannot_submit_request;

   END IF;

   -- Bug 4337210.  Last step is to clean up the preview tables.
   -- First delete the preview dependents
   DELETE FROM fem_ud_prview_dependents
   WHERE ud_session_id = p_ud_session_id;
   -- Then delete the preview candidates
   DELETE FROM fem_ud_prview_candidates
   WHERE ud_session_id = p_ud_session_id;

   COMMIT;

   fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'Undo list processed using REQUEST_ID:'||x_request_id);
   fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'End. '||to_char(sysdate,'MM/DD/YYYY HH:MI:SS'));
-- ============================================================================
-- EXCEPTIONS
-- ============================================================================
   EXCEPTION
      WHEN e_invalid_folder THEN
         x_return_status := pc_ret_sts_error;
         fem_engines_pkg.put_message(p_app_name =>'FEM',
         p_msg_name =>'FEM_IMPEXP_INVALID_FOLDER_ERR',
         p_token1 => 'FOLDER',
         p_value1 => p_folder_id,
         p_trans1 => 'N');

         fem_engines_pkg.tech_message(p_severity => pc_log_level_exception,
         p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
         p_msg_name =>'FEM_IMPEXP_INVALID_FOLDER_ERR',
         p_token1 => 'FOLDER',
         p_value1 => p_folder_id,
         p_trans1 => 'N');

         -- Standard call to get message count and if count is 1, get message info.
         FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data => x_msg_data);

      WHEN e_objexec_is_running THEN
         x_return_status := pc_ret_sts_error;
         FEM_ENGINES_PKG.put_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UD_OBJEXEC_IS_RUNNING_ERR');

         fem_engines_pkg.tech_message(p_severity => pc_log_level_exception,
         p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
         p_msg_name =>'FEM_UD_OBJEXEC_IS_RUNNING_ERR');

         -- Standard call to get message count and if count is 1, get message info.
         FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data => x_msg_data);

      WHEN e_cannot_create_undo_list THEN
         x_return_status := pc_ret_sts_error;
         fem_engines_pkg.put_message(p_app_name =>'FEM',
         p_msg_name =>'FEM_UD_CANNOT_CREATE_LIST_ERR');

         fem_engines_pkg.tech_message(p_severity => pc_log_level_exception,
         p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
         p_msg_name =>'FEM_UD_CANNOT_CREATE_LIST_ERR');

         -- Standard call to get message count and if count is 1, get message info.
         FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data => x_msg_data);

      WHEN e_cannot_add_candidate THEN
         x_return_status := pc_ret_sts_error;
         fem_engines_pkg.put_message(p_app_name =>'FEM',
         p_msg_name =>'FEM_UD_CANNOT_ADD_CANDIDT_ERR');

         fem_engines_pkg.tech_message(p_severity => pc_log_level_exception,
         p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
         p_msg_name =>'FEM_UD_CANNOT_ADD_CANDIDT_ERR');

         -- Standard call to get message count and if count is 1, get message info.
         FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data => x_msg_data);


      WHEN e_cannot_submit_request THEN

         FEM_ENGINES_PKG.put_message(p_app_name =>'FEM',
         p_msg_name => 'FEM_UD_SUBMIT_LIST_ERR',
         P_TOKEN1 => 'OBJECT_ID',
         P_VALUE1 => v_undo_list_obj_id,
         P_TRANS1 => 'N');

         fem_engines_pkg.tech_message(p_severity => pc_log_level_exception,
         p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
         p_msg_name => 'FEM_UD_SUBMIT_LIST_ERR',
         P_TOKEN1 => 'OBJECT_ID',
         P_VALUE1 => v_undo_list_obj_id,
         P_TRANS1 => 'N');

         delete_undo_list (
         x_return_status                => x_return_status,
         x_msg_count                    => x_msg_count,
         x_msg_data                     => x_msg_data,
         p_api_version                  => 1.0,
         p_commit                       => FND_API.G_TRUE,
         p_undo_list_obj_id             => v_undo_list_obj_id);

         IF x_msg_count > 0 THEN
            Get_Put_Messages(
            p_msg_count       => x_msg_count,
            p_msg_data        => x_msg_data,
            p_user_msg        => 'N',
            p_module          => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name);
         END IF;
         x_return_status := pc_ret_sts_unexp_error;

         -- Standard call to get message count and if count is 1, get message info.
         FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data => x_msg_data);

      WHEN OTHERS THEN
      -- Unexpected exceptions
      -- Log the call stack and the Oracle error message to
      -- FND_LOG with the "unexpected exception" severity level.
         x_return_status := pc_ret_sts_unexp_error;

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_unexpected,
            p_module   => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
            p_msg_text => SQLERRM);

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_unexpected,
            p_module   => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
            p_msg_text => dbms_utility.format_call_stack);

      -- Log the Oracle error message to the stack.
         FEM_ENGINES_PKG.put_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UNEXPECTED_ERROR',
            P_TOKEN1 => 'ERR_MSG',
            P_VALUE1 => SQLERRM);

         -- Standard call to get message count and if count is 1, get message info.
         FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data => x_msg_data);

END create_and_submit_prview_list;
-- ****************************************************************************
PROCEDURE insert_preview_candidates (x_return_status   OUT NOCOPY VARCHAR2,
                                     x_msg_count       OUT NOCOPY NUMBER,
                                     x_msg_data        OUT NOCOPY VARCHAR2,
                                     p_api_version     IN  NUMBER,
                                     p_ud_session_id   IN  NUMBER,
                                     p_request_ids     IN  FEM_NUMBER_TABLE,
                                     p_object_ids      IN  FEM_NUMBER_TABLE,
                                     p_commit          IN  VARCHAR2) AS
-- ============================================================================
-- PUBLIC
-- This procedure inserts the Undo Preview Candidates for
-- a given Undo Session.
-- ============================================================================
c_api_name  CONSTANT VARCHAR2(30) := 'insert_preview_candidates';
c_api_version  CONSTANT NUMBER := 1.0;
v_count NUMBER := 0;

BEGIN

   fem_engines_pkg.tech_message(p_severity => pc_log_level_procedure,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'Begin.  P_COMMIT:'||p_commit||
   ' P_UD_SESSION_ID: '||p_ud_session_id);

   -- Standard Start of API savepoint
   SAVEPOINT  insert_preview_candidates_pub;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (c_api_version,
                  p_api_version,
                  c_api_name,
                  pc_pkg_name)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

-- ============================================================================
-- STEP V2: Validate p_ud_session_id
-- ============================================================================

   IF p_ud_session_id IS NULL THEN
      RAISE e_invalid_session_id;
   END IF;

   --  Initialize API return status to success
   x_return_status := pc_ret_sts_success;

   v_count := p_object_ids.COUNT;

   IF v_count > 0 THEN
      FORALL i in 1..v_count
         INSERT INTO fem_ud_prview_candidates(ud_session_id,
            request_id, object_id, validation_status_code,
            created_by, creation_date, last_updated_by, last_update_date,
            last_update_login, object_version_Number)
            VALUES (p_ud_session_id, p_request_ids(i), p_object_ids(i),
            null,pv_apps_user_id, sysdate, pv_apps_user_id, sysdate, pv_login_id,1);
   END  IF;

   IF v_count = 0 THEN
      x_return_status := pc_ret_sts_error;
      RAISE e_list_has_no_candidates;
   ELSE
      x_return_status := pc_ret_sts_success;
   END IF;

   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   fem_engines_pkg.tech_message(p_severity => pc_log_level_procedure,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'End. X_RETURN_STATUS: '||x_return_status);

   EXCEPTION
      WHEN e_invalid_session_id THEN
         x_return_status := pc_ret_sts_error;

         FEM_ENGINES_PKG.put_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UD_INVALID_SESSIONID');

         FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data);

      WHEN e_list_has_no_candidates THEN
         ROLLBACK TO insert_preview_candidates_pub;
         x_return_status := pc_ret_sts_error;

         FEM_ENGINES_PKG.put_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UD_NO_CANDIDATES_ERR');

         fem_engines_pkg.tech_message(p_severity => pc_log_level_error,
         p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
         p_app_name =>'FEM',
         p_msg_name => 'FEM_UD_NO_CANDIDATES_ERR');

         FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO insert_preview_candidates_pub;
         x_return_status := pc_ret_sts_unexp_error;

         fem_engines_pkg.tech_message(p_severity => pc_log_level_unexpected,
         p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
         p_app_name =>'FEM',
         p_msg_name => 'FEM_BAD_P_API_VER_ERR',p_token1 => 'VALUE',
         p_value1 => p_api_version, p_trans1 => 'N');

      WHEN OTHERS THEN
      -- Unexpected exceptions
         x_return_status := pc_ret_sts_unexp_error;

      -- Log the call stack and the Oracle error message to
      -- FND_LOG with the "unexpected exception" severity level.

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_unexpected,
            p_module   => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
            p_msg_text => SQLERRM);

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_unexpected,
            p_module   => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
            p_msg_text => dbms_utility.format_call_stack);

      -- Log the Oracle error message to the stack.
         FEM_ENGINES_PKG.put_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UNEXPECTED_ERROR',
            P_TOKEN1 => 'ERR_MSG',
            P_VALUE1 => SQLERRM);

         FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data);

         ROLLBACK TO insert_preview_candidates_pub;
END insert_preview_candidates;
-- ****************************************************************************

PROCEDURE Delete_Balances (
     p_api_version         IN  NUMBER     DEFAULT 1.0,
     p_init_msg_list       IN  VARCHAR2   DEFAULT FND_API.G_FALSE,
     p_commit              IN  VARCHAR2   DEFAULT FND_API.G_FALSE,
     p_encoded             IN  VARCHAR2   DEFAULT FND_API.G_TRUE,
     x_return_status       OUT NOCOPY VARCHAR2,
     x_msg_count           OUT NOCOPY NUMBER,
     x_msg_data            OUT NOCOPY VARCHAR2,
     p_current_request_id  IN  NUMBER,
     p_object_id           IN  NUMBER,
     p_cal_period_id       IN  NUMBER,
     p_ledger_id           IN  NUMBER,
     p_dataset_code        IN  NUMBER
) IS
-- =========================================================================
-- Purpose
--    Deletes all FEM Balances data of a given ledger, calendar period,
--    and dataset that was created by previous executions of a given rule.
--    Data can only be deleted if the data is not being used by another
--    rule as a data source (i.e. chained) and if the object executions
--    that created the data have finished running.
--
--    Note that this API only works against FEM Balances and can only be
--    called for balances created by the TP_PROCESS_RULE rules.
-- History
--    01-30-06  G Cheng    Bug 4596447. Created.
--    06-28-06  G Cheng    Bug 5360424. Added p_current_request_id param.
-- Arguments
--    p_current_request_id   Request ID of execution currently running
--    p_object_id            Object ID
--    p_cal_period_id        Calendar Period ID
--    p_ledger_id            Ledger ID
--    p_dataset_code         Dataset Code
-- Return Logic
--    Set x_return_status to 'U' (Unexpected Error) if object type
--    is not TP_PROCESS_RULE.
--    Set x_return_status to 'E' (Error) if the object executions that
--    created the existing FEM Balances data are chained or are still running.
--    Otherwise, set x_return_status to 'S' (Success) after deleting the
--    balances and all related Process Locks and Data Locations related data.
-- =========================================================================
  C_MODULE            CONSTANT FND_LOG_MESSAGES.module%TYPE :=
     'fem.plsql.fem_ud_pkg.delete_balances';
  C_API_NAME          CONSTANT VARCHAR2(30) := 'Delete_Balances';
  C_API_VERSION       CONSTANT NUMBER := 1.0;
  C_FEM_BALANCES      CONSTANT VARCHAR2(30) := 'FEM_BALANCES';
--
  e_api_error         EXCEPTION;
  e_objexec_running   EXCEPTION;
  e_chain_exists      EXCEPTION;
  v_object_type       FEM_OBJECT_CATALOG_B.object_type_code%TYPE;
  v_object_name       FEM_OBJECT_CATALOG_TL.object_name%TYPE;
  v_request_id        FEM_PL_REQUESTS.request_id%TYPE;
  v_dep_req_id        FEM_PL_REQUESTS.request_id%TYPE;
  v_dep_obj_id        FEM_OBJECT_CATALOG_B.object_id%TYPE;
  v_exec_status_code  FEM_PL_REQUESTS.exec_status_code%TYPE;
  v_return_status     VARCHAR2(1);
  v_chain_exists      VARCHAR2(1);
  v_count             NUMBER;
  v_sql               VARCHAR2(1000);
--
  CURSOR c_pl_obj_execs (p_current_request_id NUMBER, p_object_id NUMBER,
                         p_table_name VARCHAR2, p_cal_period_id NUMBER,
                         p_ledger_id NUMBER, p_dataset_code NUMBER) IS
    SELECT R.request_id, T.object_id, T.table_name
    FROM fem_pl_requests R, fem_pl_tables T
    WHERE R.request_id = T.request_id
    AND R.request_id <> p_current_request_id
    AND T.object_id = p_object_id
    AND T.table_name = p_table_name
    AND R.cal_period_id = p_cal_period_id
    AND R.ledger_id = p_ledger_id
    AND R.output_dataset_code = p_dataset_code;

  CURSOR c_object_name (p_object_id NUMBER) IS
    SELECT object_name
    FROM fem_object_catalog_vl
    WHERE object_id = p_object_id;
--
BEGIN
--
  -- Standard Start of API savepoint
  SAVEPOINT  delete_balances_pub;

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;

  -- Initialize return status to unexpected error
  x_return_status := pc_ret_sts_unexp_error;

  -- Check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (C_API_VERSION,
                p_api_version,
                C_API_NAME,
                pc_pkg_name)
  THEN
    IF FND_LOG.level_unexpected >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_unexpected,
        p_module   => C_MODULE,
        p_msg_text => 'INTERNAL ERROR: API Version ('||C_API_VERSION||') not compatible with '
                    ||'passed in version ('||p_api_version||')');
    END IF;
    RAISE e_unexp_error;
  END IF;

  -- This API is only exposed for TP Process Rules at the moment.
  -- Any other object types will result in error.
  SELECT object_type_code
  INTO v_object_type
  FROM fem_object_catalog_b
  WHERE object_id = p_object_id;

  IF nvl(v_object_type,'BADTYPE') <> 'TP_PROCESS_RULE' THEN
    IF FND_LOG.level_unexpected >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_unexpected,
        p_module   => C_MODULE,
        p_msg_text => 'INTERNAL ERROR: p_object_id ('||to_char(p_object_id)
                    ||') belongs to '||v_object_type||'. This API only '
                    ||'operates on TP_PROCESS_RULE object types.');
    END IF;
    RAISE e_unexp_error;
  END IF;

  -- Log procedure param values
  IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'p_current_request_id = '||to_char(p_current_request_id));
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'p_object_id = '||to_char(p_object_id));
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'p_cal_period_id = '||to_char(p_cal_period_id));
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'p_ledger_id = '||to_char(p_ledger_id));
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'p_dataset_code = '||to_char(p_dataset_code));
  END IF;

  -- Initialize FND message queue
  IF p_init_msg_list = FND_API.G_TRUE then
    FND_MSG_PUB.Initialize;
  END IF;

  -- For now, only restrict to FEM_BALANCES since that is the
  -- table that TP Process Rules wants to remove data from.
  -- Loop through all object executions to make sure they can be removed.
  -- Checks being made are:
  --  1. No chaining on the object executions
  --  2. Object executions are not in the RUNNING state
  -- If data from object execution can be removed, delete data from table.
  FOR obj_execs IN c_pl_obj_execs (p_current_request_id, p_object_id,
                                   C_FEM_BALANCES, p_cal_period_id,
                                   p_ledger_id, p_dataset_code) LOOP

    -- Check to make sure object execution is not chained.
    FEM_PL_PKG.check_chaining (
      p_commit         => FND_API.G_FALSE,
      p_encoded        => p_encoded,
      x_return_status  => v_return_status,
      x_msg_count      => x_msg_count,
      x_msg_data       => x_msg_data,
      p_request_id     => obj_execs.request_id,
      p_object_id      => obj_execs.object_id,
      x_dep_request_id => v_dep_req_id,
      x_dep_object_id  => v_dep_obj_id,
      x_chain_exists   => v_chain_exists);

    IF v_chain_exists = FND_API.G_TRUE THEN
      v_request_id := obj_execs.request_id;
      RAISE e_chain_exists;
    END IF;

    -- Check to make sure object execution is not RUNNING.
    FEM_PL_PKG.Get_Exec_Status (
      p_commit         => FND_API.G_FALSE,
      p_encoded        => p_encoded,
      x_return_status  => v_return_status,
      x_msg_count      => x_msg_count,
      x_msg_data       => x_msg_data,
      p_request_id     => obj_execs.request_id,
      p_object_id      => obj_execs.object_id,
      x_exec_status_code => v_exec_status_code);

    IF v_exec_status_code = 'RUNNING' THEN
      v_request_id := obj_execs.request_id;
      RAISE e_objexec_running;
    END IF;

    -- Delete data from the table
    v_sql := 'DELETE FROM ' ||C_FEM_BALANCES
            ||' WHERE CREATED_BY_REQUEST_ID = '||obj_execs.request_id
          ||'   AND CREATED_BY_OBJECT_ID = '||obj_execs.object_id;
    BEGIN
      EXECUTE IMMEDIATE v_sql;
    EXCEPTION
      WHEN others THEN
        IF FND_LOG.level_unexpected >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          FEM_ENGINES_PKG.TECH_MESSAGE(
            p_severity => FND_LOG.level_unexpected,
            p_module   => C_MODULE,
            p_msg_text => 'The following SQL failed unexpected: '||v_sql);
        END IF;
        RAISE E_UNEXP_ERROR;
    END;

    -- Delete PL Tables registration information
    DELETE FROM fem_pl_tables
    WHERE object_id = obj_execs.object_id
    AND request_id = obj_execs.request_id
    AND table_name = obj_execs.table_name;

    -- Unregister Data Locations
    FEM_DIMENSION_UTIL_PKG.UnRegister_Data_Location (
      p_request_id  => obj_execs.request_id,
      p_object_id   => obj_execs.object_id,
      p_table_name  => obj_execs.table_name);

    -- Check FEM_PL_TABLES.
    -- If there are no more tables registered for the request,
    -- the whole object execution should be removed.
    SELECT count(*)
    INTO v_count
    FROM fem_pl_tables
    WHERE object_id = obj_execs.object_id
    AND request_id = obj_execs.request_id;

    IF v_count = 0 THEN
      delete_execution_log (x_return_status    => x_return_status,
                            x_msg_count        => x_msg_count,
                            x_msg_data         => x_msg_data,
                            p_api_version      => 1.0,
                            p_commit           => FND_API.G_FALSE,
                            p_request_id       => obj_execs.request_id,
                            p_object_id        => obj_execs.object_id);
      IF x_return_status <> pc_ret_sts_success THEN
        RAISE e_api_error;
      END IF;
    END IF;
  END LOOP;

  x_return_status := pc_ret_sts_success;

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
  WHEN e_objexec_running THEN
    ROLLBACK TO delete_balances_pub;

    OPEN c_object_name(p_object_id);
    FETCH c_object_name INTO v_object_name;
    CLOSE c_object_name;

    FEM_ENGINES_PKG.put_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UD_NO_DEL_RUNNING_OBJEXEC',
            p_token1 => 'RULE_NAME',
            p_value1 => v_object_name,
            p_token2 => 'REQ_ID',
            p_value2 => v_request_id);

    FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data);
    x_return_status := pc_ret_sts_error;

  WHEN e_chain_exists THEN
    ROLLBACK TO delete_balances_pub;

    OPEN c_object_name(p_object_id);
    FETCH c_object_name INTO v_object_name;
    CLOSE c_object_name;

    FEM_ENGINES_PKG.put_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UD_NO_DEL_CHAINED_OBJEXEC',
            p_token1 => 'DEP_RULE_NAME',
            p_value1 => v_dep_obj_id,
            p_token2 => 'DEP_REQ_ID',
            p_value2 => v_dep_req_id,
            p_token3 => 'RULE_NAME',
            p_value3 => v_object_name,
            p_token4 => 'REQ_ID',
            p_value4 => v_request_id);

    FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data);

    x_return_status := pc_ret_sts_error;

  -- When a call to an API fails, just exit because all return params
   -- have already been set by the API itself.
  WHEN e_api_error THEN
    ROLLBACK TO delete_balances_pub;
  WHEN others THEN
    ROLLBACK TO delete_balances_pub;

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
    x_return_status := pc_ret_sts_unexp_error;
--
END Delete_Balances;
-- ****************************************************************************

PROCEDURE Remove_Process_Locks (
     p_api_version         IN  NUMBER,
     p_init_msg_list       IN  VARCHAR2   DEFAULT FND_API.G_FALSE,
     p_commit              IN  VARCHAR2   DEFAULT FND_API.G_FALSE,
     p_encoded             IN  VARCHAR2   DEFAULT FND_API.G_TRUE,
     x_return_status       OUT NOCOPY VARCHAR2,
     x_msg_count           OUT NOCOPY NUMBER,
     x_msg_data            OUT NOCOPY VARCHAR2,
     p_request_id          IN  NUMBER,
     p_object_id           IN  NUMBER
) IS
-- =========================================================================
-- Purpose
--    Removes all process locks and all registered temporary objects for
--    those rules that register with the Process Locks framework but is
--    not removed as part of the Undo framework.  This API calls the
--    existing private procedure FEM_UD_PKG.Delete_Execution_Log once it
--    verifies that the rule execution being passed in belongs to a rule
--    type that has its Undo Flag attribute set to No, has not registered
--    any tables in FEM_PL_TABLES (i.e. has not output data), and is not
--    still running.
-- History
--    01-05-07  G Cheng    Bug 5746626. Created.
-- Arguments
--    p_request_id         Request ID of execution being removed
--    p_object_id          Object ID of execution being removed
-- Return Logic
--    Set x_return_status to 'U' (Unexpected Error) if the object type's
--    Undo Flag attribute is set to No or any tables were registered.
--    Set x_return_status to 'E' (Error) if the execution is still running.
--    Otherwise, set x_return_status to 'S' (Success) after deleting
--    all Process Locks data.
-- =========================================================================
  C_MODULE            CONSTANT FND_LOG_MESSAGES.module%TYPE :=
     'fem.plsql.fem_ud_pkg.remove_process_locks';
  C_API_NAME          CONSTANT VARCHAR2(30) := 'Remove_Process_Locks';
  C_API_VERSION       CONSTANT NUMBER := 1.0;
--
  e_api_error         EXCEPTION;
  e_objexec_running   EXCEPTION;
  v_undo_flag         FEM_OBJECT_TYPES_B.undo_flag%TYPE;
  v_object_name       FEM_OBJECT_CATALOG_TL.object_name%TYPE;
  v_exec_status_code  FEM_PL_REQUESTS.exec_status_code%TYPE;
  v_count             NUMBER;
--
  CURSOR c_object_name (p_object_id NUMBER) IS
    SELECT object_name
    FROM fem_object_catalog_vl
    WHERE object_id = p_object_id;
--
BEGIN
--
  -- Standard Start of API savepoint
  SAVEPOINT  remove_process_locks_pub;

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;

  -- Initialize return status to unexpected error
  x_return_status := pc_ret_sts_unexp_error;

  -- Check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (C_API_VERSION,
                p_api_version,
                C_API_NAME,
                pc_pkg_name)
  THEN
    IF FND_LOG.level_unexpected >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_unexpected,
        p_module   => C_MODULE,
        p_msg_text => 'INTERNAL ERROR: API Version ('||C_API_VERSION
                    ||') not compatible with '
                    ||'passed in version ('||p_api_version||')');
    END IF;
    RAISE e_unexp_error;
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
      p_msg_text => 'p_request_id = '||to_char(p_request_id));
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'p_object_id = '||to_char(p_object_id));
  END IF;

  -- This API should only be called to remove rules where its rule type
  -- Undo Flag attribute is set to N.
  SELECT undo_flag
  INTO v_undo_flag
  FROM fem_object_catalog_b oc, fem_object_types_b ot
  WHERE oc.object_id = p_object_id
  AND oc.object_type_code = ot.object_type_code;

  IF nvl(v_undo_flag,'XX') <> 'N' THEN
    IF FND_LOG.level_unexpected >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_unexpected,
        p_module   => C_MODULE,
        p_msg_text => 'INTERNAL ERROR: p_object_id ('||to_char(p_object_id)
                    ||') belongs to a rule type where its Undo Flag'
                    ||' attribute is set to: '||v_undo_flag
                    ||'. This API only operates on rule types where its'
                    ||' Undo Flag is set to N.');
    END IF;
    RAISE e_unexp_error;
  END IF;

  -- This API should only be called to remove rule types that do not
  -- register any tables (i.e. output any data).
  SELECT count(*)
  INTO v_count
  FROM fem_pl_tables
  WHERE object_id = p_object_id
  AND request_id = p_request_id;

  IF v_count > 0 THEN
    IF FND_LOG.level_unexpected >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_unexpected,
        p_module   => C_MODULE,
        p_msg_text => 'INTERNAL ERROR: p_object_id ('||to_char(p_object_id)
                    ||') registered this many tables: '||v_count
                    ||'. This API can only process against rules that do'
                    ||' NOT output data.');
    END IF;
    RAISE e_unexp_error;
  END IF;

  -- Check to make sure object execution is not RUNNING.
  FEM_PL_PKG.Get_Exec_Status (
    p_commit           => FND_API.G_FALSE,
    p_encoded          => p_encoded,
    x_return_status    => x_return_status,
    x_msg_count        => x_msg_count,
    x_msg_data         => x_msg_data,
    p_request_id       => p_request_id,
    p_object_id        => p_object_id,
    x_exec_status_code => v_exec_status_code);

  IF x_return_status <> pc_ret_sts_success THEN
    IF FND_LOG.level_unexpected >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_unexpected,
        p_module   => C_MODULE,
        p_msg_text => 'INTERNAL ERROR: Call to FEM_PL_PKG.Get_Exec_Status'
                    ||' failed with return status: '||x_return_status);
    END IF;

    RAISE e_api_error;
  END IF;

  IF v_exec_status_code = 'RUNNING' THEN
    RAISE e_objexec_running;
  END IF;

  -- Passed all checks, can remove process locks now.
  delete_execution_log (x_return_status    => x_return_status,
                        x_msg_count        => x_msg_count,
                        x_msg_data         => x_msg_data,
                        p_api_version      => 1.0,
                        p_commit           => FND_API.G_FALSE,
                        p_request_id       => p_request_id,
                        p_object_id        => p_object_id);

  IF x_return_status <> pc_ret_sts_success THEN
    IF FND_LOG.level_unexpected >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_unexpected,
        p_module   => C_MODULE,
        p_msg_text => 'INTERNAL ERROR: Call to FEM_PL_PKG.Get_Exec_Status'
                    ||' failed with return status: '||x_return_status);
    END IF;

    RAISE e_api_error;
  END IF;

  x_return_status := pc_ret_sts_success;

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
  WHEN e_objexec_running THEN
    ROLLBACK TO remove_process_locks_pub;

    OPEN c_object_name(p_object_id);
    FETCH c_object_name INTO v_object_name;
    CLOSE c_object_name;

    FEM_ENGINES_PKG.put_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UD_NO_DEL_RUNNING_OBJEXEC',
            p_token1 => 'RULE_NAME',
            p_value1 => v_object_name,
            p_token2 => 'REQ_ID',
            p_value2 => p_request_id);

    FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data);
    x_return_status := pc_ret_sts_error;

  WHEN e_api_error THEN
    -- When a call to an API fails, just exit because all return params
    -- have already been set by the API itself.
    ROLLBACK TO remove_process_locks_pub;
  WHEN others THEN
    ROLLBACK TO remove_process_locks_pub;

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
    x_return_status := pc_ret_sts_unexp_error;
--
END Remove_Process_Locks;

/*============================================================================+
 | PROCEDURE
 |   Repair_PL_Request
 |
 | DESCRIPTION
 |   Main concurrent program to repair the Process Log/Process Lock entries based on
 |   the Created_By_Request_ID and Created_By_Object_ID columns, etc. from
 |   FEM_BALANCES, such as to restore the entries sufficiently in the executed
 |   Rules UI for Undo to be invoked again to finish the job. See bug 7260263.
 |
 | SCOPE - PUBLIC
 |
 | MODIFICATION HISTORY
 |   huli   26-AUG-2008  Created
 |
 +============================================================================*/

PROCEDURE Repair_PL_Request (
  errbuf                          out nocopy varchar2
  ,retcode                        out nocopy varchar2
  ,p_request_id                   in number default null
  ,p_object_id                    in number default null
)
IS

  -----------------------
  -- Declare constants --
  -----------------------
  l_api_name             constant varchar2(30) := 'Repair_PL_Request';
  l_reg_rec              pl_register_record;

  l_return_status                 varchar2(1);
  l_msg_count                     NUMBER;
  l_msg_data                      varchar2(2000);
  l_obj_def_id           fem_object_definition_b.object_definition_id%TYPE := NULL;
  l_exec_state                    varchar2(30); -- normal, restart, rerun
  l_prev_request_id               number;

  l_prg_msg                       VARCHAR2(2000);
  l_callstack                     VARCHAR2(2000);
  l_exe_ok                        BOOLEAN := TRUE;
  l_not_found_exe                 BOOLEAN := TRUE;



  ----------------------------
  -- Declare static cursors --
  ----------------------------
  cursor c_missing_pl_entry is
  select row_count, bal.created_by_object_id, bal.created_by_request_id, bal.ledger_id bal_ledger_id,
         bal.cal_period_id bal_cal_period_id, bal.source_system_code bal_source_system_code,
         bal.dataset_code bal_dataset_code, exe.request_id execution_request_id,
         requests.request_id request_request_id, tab.request_id tab_request_id,
         requests.effective_date request_effective_date, requests.cal_period_id request_cal_period_id, requests.ledger_id request_ledger_id,
         requests.dataset_io_obj_def_id request_dataset_io_obj_def_id, requests.output_dataset_code request_output_dataset_code,
         requests.source_system_code request_source_system_code, requests.program_id, requests.program_application_id,
         requests.exec_status_code, requests.last_updated_by, requests.program_login_id, obj.object_name
  from (select count(*) row_count, created_by_object_id, created_by_request_id, ledger_id, cal_period_id, source_system_code,
               dataset_code
       from fem_balances
       WHERE (p_request_id IS NULL OR created_by_request_id = p_request_id)
       AND (p_object_id IS NULL OR created_by_object_id = p_object_id)
       AND source_system_code = (SELECT source_system_code
                                 FROM fem_source_systems_b src_system
                                 WHERE src_system.source_system_display_code = 'PFT'
                                 and src_system.personal_flag = 'N')
       GROUP BY created_by_object_id, created_by_request_id, ledger_id, cal_period_id, source_system_code,
               dataset_code) bal,
       fem_pl_object_executions exe,
       fem_pl_requests requests,
       fem_pl_tables tab,
       fem_object_catalog_vl obj
  where bal.created_by_object_id = obj.object_id
  and obj.object_type_code = 'MAPPING_RULE'
  and exe.object_id(+) = bal.created_by_object_id
  and exe.request_id(+) = bal.created_by_request_id
  and requests.request_id(+) = bal.created_by_request_id
  and tab.object_id(+) = bal.created_by_object_id
  and tab.request_id(+) = bal.created_by_request_id
  and tab.table_name(+) = 'FEM_BALANCES'
  and (exe.object_id is null or exe.request_id is null or requests.request_id is null
      or tab.object_id is null or tab.request_id is null) ;

/******************************************************************************
 *                                                                            *
 *                              Repair_PL_Request                             *
 *                              Execution Block                               *
 *                                                                            *
 ******************************************************************************/

BEGIN

  -- Initialize Message Stack on FND_MSG_PUB
  FND_MSG_PUB.Initialize;

  write_debug(
      p_msg_data        => 'BEGIN',
      p_user_msg        => 'N',
      p_module          => 'fem.plsql.'||pc_pkg_name||'.'||l_api_name
  );
  /****
  write_debug (' Repair_PL_Request 1');

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => pc_log_level_procedure
    ,p_module   => 'fem.plsql.'||pc_pkg_name||'.'|| l_api_name
    ,p_msg_text => 'BEGIN'
  );
  ****/

  SAVEPOINT Repair_PL_Request;
  ------------------------------------------------
  -- Initialize Package and Procedure Variables --
  ------------------------------------------------
  l_reg_rec.accurate_eff_dt_flg := G_NO;

  --write_debug (' Repair_PL_Request 2');
  write_debug(
      p_msg_data        => 'Repair_PL_Request 2',
      p_user_msg        => 'N',
      p_module          => 'fem.plsql.'||pc_pkg_name||'.'||l_api_name
  );

  FOR missing_entry IN c_missing_pl_entry  LOOP
     l_not_found_exe := FALSE;

     l_exe_ok := TRUE;
     l_reg_rec.object_id              := missing_entry.created_by_object_id;
     l_reg_rec.request_id             := missing_entry.created_by_request_id;
     l_reg_rec.cal_period_id          := missing_entry.bal_cal_period_id;
     l_reg_rec.ledger_id              := missing_entry.bal_ledger_id;
     l_reg_rec.output_dataset_code    := missing_entry.bal_dataset_code;
     l_reg_rec.source_system_code     := missing_entry.bal_source_system_code;
     l_reg_rec.program_id             := missing_entry.program_id;
     l_reg_rec.program_application_id := missing_entry.program_application_id;
     l_reg_rec.exec_status_code       := missing_entry.exec_status_code;

     --write_debug (' Repair_PL_Request 3, l_reg_rec.object_id:'
     --             || l_reg_rec.object_id || ' l_reg_rec.request_id:'
     --             || l_reg_rec.request_id || ' l_reg_rec.cal_period_id:'
     --             || l_reg_rec.cal_period_id || ' l_reg_rec.ledger_id:'
     --             || l_reg_rec.ledger_id || ' l_reg_rec.output_dataset_code:'
     --             || l_reg_rec.output_dataset_code);

     write_debug(
        p_msg_data        => ' Repair_PL_Request 3, l_reg_rec.object_id:'
                              || l_reg_rec.object_id || ' l_reg_rec.request_id:'
                              || l_reg_rec.request_id || ' l_reg_rec.cal_period_id:'
                              || l_reg_rec.cal_period_id || ' l_reg_rec.ledger_id:'
                              || l_reg_rec.ledger_id || ' l_reg_rec.output_dataset_code:'
                              || l_reg_rec.output_dataset_code,
        p_user_msg        => 'N',
        p_module          => 'fem.plsql.'||pc_pkg_name||'.'||l_api_name
     );
     --Call the rountine FEM_PL_PKG.Register_Request to register the request if the request entry is missing
     IF (missing_entry.request_request_id IS NULL) THEN
        write_debug(
           p_msg_data        => ' Repair_PL_Request 4',
           p_user_msg        => 'N',
           p_module          => 'fem.plsql.'||pc_pkg_name||'.'||l_api_name
        );

        Prepare_PL_Register_Record (
           x_pl_register_record    => l_reg_rec,
           x_return_status         =>l_return_status
        );
        IF ( l_return_status <> pc_ret_sts_success) THEN
           l_exe_ok := FALSE;
           write_debug(
              p_msg_data        => ' Repair_PL_Request 4A, fails to call Prepare_PL_Register_Record ',
              p_user_msg        => 'N',
              p_module          => 'fem.plsql.'||pc_pkg_name||'.'||l_api_name
           );
           FEM_ENGINES_PKG.User_Message (
              p_app_name  => G_FEM
             ,p_msg_name => 'FEM_UD_CANT_REPAIR_EXEC'
             ,p_token1   => 'object_name'
             ,p_value1   => missing_entry.object_name
             ,p_token2   => 'request_id'
             ,p_value2   => missing_entry.created_by_request_id
             ,p_token3   => 'object_id'
             ,p_value3   => missing_entry.created_by_object_id
           );
        END IF;

        IF (l_exe_ok) THEN
           write_debug(
              p_msg_data        => ' Repair_PL_Request 5, before calling FEM_PL_PKG.Register_Request ',
              p_user_msg        => 'N',
              p_module          => 'fem.plsql.'||pc_pkg_name||'.'||l_api_name
           );

           FEM_PL_PKG.Register_Request (
              p_api_version             => 1.0
             ,p_commit                 => FND_API.G_FALSE
             ,p_cal_period_id          => l_reg_rec.cal_period_id
             ,p_ledger_id              => l_reg_rec.ledger_id
             ,p_dataset_io_obj_def_id  => l_reg_rec.dataset_io_obj_def_id
             ,p_output_dataset_code    => l_reg_rec.output_dataset_code
             ,p_source_system_code     => l_reg_rec.source_system_code
             ,p_effective_date         => l_reg_rec.effective_date
             ,p_rule_set_obj_def_id    => NULL
             ,p_rule_set_name          => NULL
             ,p_request_id             => l_reg_rec.request_id
             ,p_user_id                => l_reg_rec.user_id
             ,p_last_update_login      => l_reg_rec.login_id
             ,p_program_id             => l_reg_rec.program_id
             ,p_program_login_id       => l_reg_rec.login_id
             ,p_program_application_id => l_reg_rec.program_application_id
             ,p_exec_mode_code         => null
             ,p_dimension_id           => null
             ,p_table_name             => null
             ,p_hierarchy_name         => null
             ,x_msg_count              => l_msg_count
             ,x_msg_data               => l_msg_data
             ,x_return_status          => l_return_status
           );


           if (l_return_status <> pc_ret_sts_success) then
              FEM_ENGINES_PKG.User_Message (
                 p_app_name  => G_FEM
                ,p_msg_name => 'FEM_UD_CANT_REPAIR_EXEC'
                ,p_token1   => 'object_name'
                ,p_value1   => missing_entry.object_name
                ,p_token2   => 'request_id'
                ,p_value2   => missing_entry.created_by_request_id
                ,p_token3   => 'object_id'
                ,p_value3   => missing_entry.created_by_object_id
              );
              Get_Put_Messages(
                  p_msg_count       => l_msg_count,
                  p_msg_data        => l_msg_data,
                  p_user_msg        => G_YES,
                  p_module          => 'fem.plsql.'||pc_pkg_name||'.'||l_api_name);

              --write_debug (' Repair_PL_Request 6, fail to call FEM_PL_PKG.Register_Request, l_msg_count:'
              --             || l_msg_count || ' l_msg_data:' || l_msg_data);
              l_exe_ok := FALSE;
           end if;
        END IF; --(l_exe_ok)

     ELSE
        l_reg_rec.user_id              := missing_entry.last_updated_by;
        l_reg_rec.login_id             := missing_entry.program_login_id;
        l_reg_rec.request_id           := missing_entry.request_request_id;
        l_reg_rec.cal_period_id        := missing_entry.bal_cal_period_id;
        l_reg_rec.ledger_id            := missing_entry.bal_ledger_id;
        l_reg_rec.output_dataset_code  := missing_entry.bal_dataset_code;
        l_reg_rec.source_system_code   := missing_entry.bal_source_system_code;
        l_reg_rec.effective_date       := missing_entry.request_effective_date;
        l_reg_rec.accurate_eff_dt_flg  := G_YES;
        write_debug(
           p_msg_data        => ' Repair_PL_Request 6',
           p_user_msg        => 'N',
           p_module          => 'fem.plsql.'||pc_pkg_name||'.'||l_api_name
        );

     END IF;

     --Call the process lock API FEM_PL_PKG.Register_Object_Execution to register
     --the object executions, also call the process lock API FEM_PL_PKG.Register_Object_Def
     --to register object definition if the entry in the fem_pl_object_executions is missing
     IF (l_exe_ok AND
         missing_entry.execution_request_id IS NULL) THEN
        write_debug(
           p_msg_data        => ' Repair_PL_Request 7',
           p_user_msg        => 'N',
           p_module          => 'fem.plsql.'||pc_pkg_name||'.'||l_api_name
        );
        Get_Object_Definition (
           p_object_id                     => l_reg_rec.object_id
           ,p_effective_date               => l_reg_rec.effective_date
           ,x_obj_def_id                   => l_obj_def_id
        );
        IF (l_obj_def_id IS NOT NULL)  THEN
           write_debug(
              p_msg_data        => ' Repair_PL_Request 8, before FEM_PL_PKG.Register_Object_Execution, l_reg_rec.user_id:'
                                 || l_reg_rec.user_id || ' l_reg_rec.login_id:'
                                 || l_reg_rec.login_id || ' l_obj_def_id:' || l_obj_def_id,
              p_user_msg        => 'N',
              p_module          => 'fem.plsql.'||pc_pkg_name||'.'||l_api_name
           );

           FEM_PL_PKG.Register_Object_Execution (
              p_api_version                => 1.0
             ,p_commit                    => FND_API.G_FALSE
             ,p_request_id                => l_reg_rec.request_id
             ,p_object_id                 => l_reg_rec.object_id
             ,p_exec_object_definition_id => l_obj_def_id
             ,p_user_id                   => l_reg_rec.user_id
             ,p_last_update_login         => l_reg_rec.login_id
             ,p_exec_mode_code            => null
             ,x_exec_state                => l_exec_state
             ,x_prev_request_id           => l_prev_request_id
             ,x_msg_count                 => l_msg_count
             ,x_msg_data                  => l_msg_data
             ,x_return_status             => l_return_status
           );

           IF (l_return_status <> pc_ret_sts_success) THEN
              FEM_ENGINES_PKG.User_Message (
                 p_app_name  => G_FEM
                ,p_msg_name => 'FEM_UD_CANT_REPAIR_EXEC'
                ,p_token1   => 'object_name'
                ,p_value1   => missing_entry.object_name
                ,p_token2   => 'request_id'
                ,p_value2   => missing_entry.created_by_request_id
                ,p_token3   => 'object_id'
                ,p_value3   => missing_entry.created_by_object_id
              );
              Get_Put_Messages(
                 p_msg_count       => l_msg_count,
                 p_msg_data        => l_msg_data,
                 p_user_msg        => G_YES,
                 p_module          => 'fem.plsql.'||pc_pkg_name||'.'||l_api_name);
              l_exe_ok := FALSE;
              --write_debug (' Repair_PL_Request 10, fail to call FEM_PL_PKG.Register_Object_Execution, l_msg_count:'
              --             || l_msg_count || ' l_msg_data:' || l_msg_data);
           ELSE
              FEM_PL_PKG.Update_Obj_Exec_Status(
                P_API_VERSION               => 1.0,
                P_COMMIT                    => FND_API.G_FALSE,
                P_REQUEST_ID                => l_reg_rec.request_id,
                P_OBJECT_ID                 => l_reg_rec.object_id,
                P_EXEC_STATUS_CODE          => 'SUCCESS',
                P_USER_ID                   => l_reg_rec.user_id,
                P_LAST_UPDATE_LOGIN         => l_reg_rec.login_id,
                X_MSG_COUNT                 => l_msg_count,
                X_MSG_DATA                  => l_msg_data,
                X_RETURN_STATUS             => l_return_status);
              IF (l_return_status <> pc_ret_sts_success) THEN
                 FEM_ENGINES_PKG.User_Message (
                    p_app_name  => G_FEM
                   ,p_msg_name => 'FEM_UD_CANT_REPAIR_EXEC'
                   ,p_token1   => 'object_name'
                   ,p_value1   => missing_entry.object_name
                   ,p_token2   => 'request_id'
                   ,p_value2   => missing_entry.created_by_request_id
                   ,p_token3   => 'object_id'
                   ,p_value3   => missing_entry.created_by_object_id
                 );

                 Get_Put_Messages(
                    p_msg_count       => l_msg_count,
                    p_msg_data        => l_msg_data,
                    p_user_msg        => G_YES,
                    p_module          => 'fem.plsql.'||pc_pkg_name||'.'||l_api_name);
              END IF;
           END IF;

           IF (l_exe_ok
               AND l_reg_rec.accurate_eff_dt_flg = G_YES) THEN
              --write_debug (' Repair_PL_Request 11, before Register_Object_Def');
              write_debug(
                 p_msg_data        => ' Repair_PL_Request 9',
                 p_user_msg        => 'N',
                 p_module          => 'fem.plsql.'||pc_pkg_name||'.'||l_api_name
              );

              FEM_PL_PKG.Register_Object_Def (
                p_api_version           => 1.0
                ,p_commit               => FND_API.G_FALSE
                ,p_request_id           => l_reg_rec.request_id
                ,p_object_id            => l_reg_rec.object_id
                ,p_object_definition_id => l_obj_def_id
                ,p_user_id              => l_reg_rec.user_id
                ,p_last_update_login    => l_reg_rec.login_id
                ,x_msg_count            => l_msg_count
                ,x_msg_data             => l_msg_data
                ,x_return_status        => l_return_status
              );
              IF (l_return_status <> pc_ret_sts_success) THEN
                 FEM_ENGINES_PKG.User_Message (
                    p_app_name  => G_FEM
                   ,p_msg_name => 'FEM_UD_CANT_REPAIR_EXEC'
                   ,p_token1   => 'object_name'
                   ,p_value1   => missing_entry.object_name
                   ,p_token2   => 'request_id'
                   ,p_value2   => missing_entry.created_by_request_id
                   ,p_token3   => 'object_id'
                   ,p_value3   => missing_entry.created_by_object_id
                 );
                 Get_Put_Messages(
                    p_msg_count       => l_msg_count,
                    p_msg_data        => l_msg_data,
                    p_user_msg        => G_YES,
                    p_module          => 'fem.plsql.'||pc_pkg_name||'.'||l_api_name);
                 l_exe_ok := FALSE;
                 --write_debug (' Repair_PL_Request 12, fail to call Register_Object_Def, l_msg_count:'
                 --          || l_msg_count || ' l_msg_data:' || l_msg_data);
              END IF;

           END IF;
        END IF;
     END IF;--l_exe_ok AND missing_entry.execution_request_id IS NULL

     --Call the process lock API FEM_PL_PKG.Register_Table to register the FEM_BALANCES
     --table if the corresponding entry is missing from the fem_pl_tables
     IF (l_exe_ok AND missing_entry.tab_request_id IS NULL) THEN
        --write_debug (' Repair_PL_Request 13, before Register_Table');
        write_debug(
           p_msg_data        => ' Repair_PL_Request 10',
           p_user_msg        => 'N',
           p_module          => 'fem.plsql.'||pc_pkg_name||'.'||l_api_name
        );

        FEM_PL_PKG.Register_Table (
          p_api_version         => 1.0
          ,p_commit             => FND_API.G_FALSE
          ,p_request_id         => l_reg_rec.request_id
          ,p_object_id          => l_reg_rec.object_id
          ,p_table_name         => 'FEM_BALANCES'
          ,p_statement_type     => 'INSERT'
          ,p_num_of_output_rows => missing_entry.row_count
          ,p_user_id            => l_reg_rec.user_id
          ,p_last_update_login  => l_reg_rec.login_id
          ,x_msg_count          => l_msg_count
          ,x_msg_data           => l_msg_data
          ,x_return_status      => l_return_status
        );
        IF (l_return_status <> pc_ret_sts_success) THEN
           FEM_ENGINES_PKG.User_Message (
              p_app_name  => G_FEM
             ,p_msg_name => 'FEM_UD_CANT_REPAIR_EXEC'
             ,p_token1   => 'object_name'
             ,p_value1   => missing_entry.object_name
             ,p_token2   => 'request_id'
             ,p_value2   => missing_entry.created_by_request_id
             ,p_token3   => 'object_id'
             ,p_value3   => missing_entry.created_by_object_id
           );
           Get_Put_Messages(
              p_msg_count       => l_msg_count,
              p_msg_data        => l_msg_data,
              p_user_msg        => G_YES,
              p_module          => 'fem.plsql.'||pc_pkg_name||'.'||l_api_name);
           l_exe_ok := FALSE;
           --write_debug (' Repair_PL_Request 14, fail to call Register_Table, l_msg_count:'
           --                || l_msg_count || ' l_msg_data:' || l_msg_data);
        END IF;
     END IF;

     IF (l_exe_ok) THEN
        --write_debug (' Repair_PL_Request 15, before Register_Data_Location');
        write_debug(
           p_msg_data        => ' Repair_PL_Request 11',
           p_user_msg        => 'N',
           p_module          => 'fem.plsql.'||pc_pkg_name||'.'||l_api_name
        );

        FEM_ENGINES_PKG.User_Message (
           p_app_name  => G_FEM
           ,p_msg_name => 'FEM_UD_REPAIR_SUCCESS'
           ,p_token1   => 'object_name'
           ,p_value1   => missing_entry.object_name
           ,p_token2   => 'object_id'
           ,p_value2   => missing_entry.created_by_object_id
           ,p_token3   => 'request_id'
           ,p_value3   => missing_entry.created_by_request_id
        );

        FEM_DIMENSION_UTIL_PKG.Register_Data_Location (
           p_request_id   => l_reg_rec.request_id
           ,p_object_id   => l_reg_rec.object_id
           ,p_table_name  => 'FEM_BALANCES'
           ,p_ledger_id   => l_reg_rec.ledger_id
           ,p_cal_per_id  => l_reg_rec.cal_period_id
           ,p_dataset_cd  => l_reg_rec.output_dataset_code
           ,p_source_cd   => l_reg_rec.source_system_code
           ,p_load_status => null
        );
     END IF;--l_exe_ok


  END LOOP;

  IF (l_not_found_exe) THEN

     FEM_ENGINES_PKG.User_Message (
        p_app_name  => G_FEM
       ,p_msg_name => 'FEM_UD_NO_NEED_REPAIR_EXEC'
     );

  END IF;
  --write_debug (' Repair_PL_Request 16, before commit');
  write_debug(
     p_msg_data        => ' Repair_PL_Request 12',
     p_user_msg        => 'N',
     p_module          => 'fem.plsql.'||pc_pkg_name||'.'||l_api_name
  );

  COMMIT;

EXCEPTION
   WHEN OTHERS THEN

      l_prg_msg := SQLERRM;
      l_callstack := DBMS_UTILITY.Format_Call_Stack;

      IF (c_missing_pl_entry%ISOPEN) THEN CLOSE c_missing_pl_entry;
      END IF;

      --write_debug (' Repair_PL_Request 17, l_prg_msg:' || l_prg_msg
      --             || ' l_callstack:' || l_callstack);
      write_debug(
         p_msg_data        => ' Repair_PL_Request 17, l_prg_msg:' || l_prg_msg
                              || ' l_callstack:' || l_callstack,
         p_user_msg        => 'N',
         p_module          => 'fem.plsql.'||pc_pkg_name||'.'||l_api_name
      );

      pv_concurrent_status := FND_CONCURRENT.Set_Completion_Status('ERROR',null);


      FEM_ENGINES_PKG.Tech_Message (
        p_severity  => pc_log_level_unexpected
        ,p_module   => 'fem.plsql.'||pc_pkg_name||'.'|| l_api_name
        ,p_msg_text => l_prg_msg
      );

      FEM_ENGINES_PKG.Tech_Message (
         p_severity  => pc_log_level_unexpected
         ,p_module   => 'fem.plsql.'||pc_pkg_name||'.'|| l_api_name
         ,p_msg_text => l_callstack
      );

      FEM_ENGINES_PKG.User_Message (
         p_app_name  => G_FEM
         ,p_msg_name => 'FEM_UNEXPECTED_ERROR'
         ,p_token1   => 'ERR_MSG'
         ,p_value1   => l_prg_msg
      );


      ROLLBACK TO Repair_PL_Request;

END Repair_PL_Request;


/*============================================================================+
 | PROCEDURE
 |   Prepare_PL_Register_Record
 |
 | DESCRIPTION
 |   Retrieve the following information
 |      1. effective date based on either the concurrent program parameters or
 |         the end date of cal period
 |
 |
 |
 | SCOPE - PRIVATE
 |
 +============================================================================*/

PROCEDURE Prepare_PL_Register_Record (
   x_pl_register_record           IN OUT nocopy pl_register_record,
   x_return_status                OUT NOCOPY VARCHAR2
)
IS

   CURSOR c_fnd_concurrent (p_request_id IN NUMBER) IS
   SELECT STATUS_CODE, ARGUMENT1, ARGUMENT2, ARGUMENT3, ARGUMENT4,
          ARGUMENT5, ARGUMENT6, ARGUMENT7, ARGUMENT8, requested_by,
          conc_login_id, CONCURRENT_PROGRAM_ID, PROGRAM_APPLICATION_ID
   FROM FND_CONCURRENT_REQUESTS
   WHERE request_id = p_request_id;


   CURSOR c_get_output_ds_obj_def_id IS
   select dataset_io_obj_def_id
   from   fem_ds_input_output_defs
   where  output_dataset_code = x_pl_register_record.output_dataset_code
   and rownum = 1;


   l_fnd_concurrent_rec            c_fnd_concurrent%ROWTYPE;

   l_dummy                         VARCHAR2(30);
   l_api_name                      constant varchar2(30) := 'Prepare_PL_Register_Record';
   l_prg_msg                       VARCHAR2(2000);
   l_callstack                     VARCHAR2(2000);
   l_prepare_pl_register_rc_err    exception;

BEGIN
   x_return_status := pc_ret_sts_success;
   OPEN c_fnd_concurrent (x_pl_register_record.request_id);
   FETCH c_fnd_concurrent INTO l_fnd_concurrent_rec;

   --FEM_ENGINES_PKG.Tech_Message (
   --   p_severity  => pc_log_level_procedure
   --   ,p_module   => 'fem.plsql.'||pc_pkg_name||'.'|| l_api_name
   --   ,p_msg_text => 'request_id:' || x_pl_register_record.request_id
   --                  || ' and object_id:' || x_pl_register_record.object_id
   --);

   write_debug(
      p_msg_data        => 'request_id:' || x_pl_register_record.request_id
                        || ' and object_id:' || x_pl_register_record.object_id,
      p_user_msg        => 'N',
      p_module          => 'fem.plsql.'||pc_pkg_name||'.'|| l_api_name
   );

   -- the request is wiped out from the FND_CONCURRENT_REQUESTS
   IF (c_fnd_concurrent%notfound) THEN

      --FEM_ENGINES_PKG.Tech_Message (
      --   p_severity  => pc_log_level_procedure
      --   ,p_module   => 'fem.plsql.'||pc_pkg_name||'.'|| l_api_name
      --   ,p_msg_text => 'request_id:' || x_pl_register_record.request_id
      --                  || ' wiped out from the FND_CONCURRENT_REQUESTS'
      --);

      write_debug(
         p_msg_data        => 'request_id:' || x_pl_register_record.request_id
                              || ' wiped out from the FND_CONCURRENT_REQUESTS',
         p_user_msg        => 'N',
         p_module          => 'fem.plsql.'||pc_pkg_name||'.'|| l_api_name
      );

      Get_Dim_Attribute_Value (
         p_dimension_varchar_label       => 'CAL_PERIOD'
         ,p_attribute_varchar_label      => 'CAL_PERIOD_END_DATE'
         ,p_member_id                    => x_pl_register_record.cal_period_id
         ,x_dim_attribute_varchar_member => l_dummy
         ,x_date_assign_value            => x_pl_register_record.effective_date
         ,x_return_status                => x_return_status
      );
      IF (x_return_status <> pc_ret_sts_success) THEN
         --FEM_ENGINES_PKG.Tech_Message (
         --p_severity  => pc_log_level_procedure
         --,p_module   => 'fem.plsql.'||pc_pkg_name||'.'|| l_api_name
         --,p_msg_text => 'Can not retrieve the ending date for cal period:'
         --               || x_pl_register_record.cal_period_id);
         write_debug(
            p_msg_data        => 'Can not retrieve the ending date for cal period:'
                                || x_pl_register_record.cal_period_id,
            p_user_msg        => 'N',
            p_module          => 'fem.plsql.'||pc_pkg_name||'.'|| l_api_name
         );

         RAISE l_prepare_pl_register_rc_err;
      END IF;

      write_debug(
         p_msg_data        => 'x_pl_register_record.effective_date:'
                             || x_pl_register_record.effective_date,
         p_user_msg        => 'N',
         p_module          => 'fem.plsql.'||pc_pkg_name||'.'|| l_api_name
      );


      x_pl_register_record.dataset_io_obj_def_id := NULL;

      OPEN c_get_output_ds_obj_def_id;
      FETCH c_get_output_ds_obj_def_id INTO x_pl_register_record.dataset_io_obj_def_id;
      CLOSE c_get_output_ds_obj_def_id;

      IF (x_pl_register_record.dataset_io_obj_def_id IS NULL) THEN

         --FEM_ENGINES_PKG.Tech_Message (
         --p_severity  => pc_log_level_procedure
         --,p_module   => 'fem.plsql.'||pc_pkg_name||'.'|| l_api_name
         --,p_msg_text => 'Can not retrieve data set object definition id for the data set code:'
         --               || x_pl_register_record.output_dataset_code);

         write_debug(
            p_msg_data  => 'Can not retrieve data set object definition id for the data set code:'
                        || x_pl_register_record.output_dataset_code,
            p_user_msg  => 'N',
            p_module    => 'fem.plsql.'||pc_pkg_name||'.'|| l_api_name
         );

         RAISE l_prepare_pl_register_rc_err;

      END IF;

      x_pl_register_record.user_id := FND_GLOBAL.user_id;
      x_pl_register_record.login_id := FND_GLOBAL.login_id;
      x_pl_register_record.program_id := FND_GLOBAL.conc_program_id;
      x_pl_register_record.program_application_id := FND_GLOBAL.prog_appl_id;
   ELSE
      x_pl_register_record.cal_period_id := TO_NUMBER(l_fnd_concurrent_rec.ARGUMENT4);
      x_pl_register_record.effective_date := FND_DATE.Canonical_To_Date(l_fnd_concurrent_rec.ARGUMENT2);
      x_pl_register_record.dataset_io_obj_def_id := TO_NUMBER(l_fnd_concurrent_rec.ARGUMENT5);
      x_pl_register_record.user_id := l_fnd_concurrent_rec.requested_by;
      x_pl_register_record.login_id := l_fnd_concurrent_rec.conc_login_id;
      x_pl_register_record.program_id := l_fnd_concurrent_rec.CONCURRENT_PROGRAM_ID;
      x_pl_register_record.program_application_id := l_fnd_concurrent_rec.PROGRAM_APPLICATION_ID;
      x_pl_register_record.program_application_id := l_fnd_concurrent_rec.PROGRAM_APPLICATION_ID;
      x_pl_register_record.accurate_eff_dt_flg  := G_YES;
  END IF;

  --FEM_ENGINES_PKG.Tech_Message (
  --   p_severity  => pc_log_level_procedure
  --   ,p_module   => 'fem.plsql.'||pc_pkg_name||'.'|| l_api_name
  --   ,p_msg_text => 'cal_period_id:' || x_pl_register_record.cal_period_id
  --                  || ' and effective_date:' || x_pl_register_record.effective_date
  --                  || ' and dataset_io_obj_def_id:' || x_pl_register_record.dataset_io_obj_def_id
  --);

  write_debug(
     p_msg_data  => 'cal_period_id:' || x_pl_register_record.cal_period_id
                    || ' and effective_date:' || x_pl_register_record.effective_date
                    || ' and dataset_io_obj_def_id:' || x_pl_register_record.dataset_io_obj_def_id,
     p_user_msg  => 'N',
     p_module    => 'fem.plsql.'||pc_pkg_name||'.'|| l_api_name
  );


  CLOSE c_fnd_concurrent;

EXCEPTION

   WHEN l_prepare_pl_register_rc_err THEN
      IF (c_fnd_concurrent%ISOPEN) THEN CLOSE c_fnd_concurrent;
      END IF;
      x_return_status := pc_ret_sts_error;

   WHEN OTHERS THEN
      IF (c_fnd_concurrent%ISOPEN) THEN CLOSE c_fnd_concurrent;
      END IF;

      l_prg_msg := SQLERRM;
      l_callstack := DBMS_UTILITY.Format_Call_Stack;

      write_debug(
         p_msg_data  => ' l_prg_msg:' || l_prg_msg || ' and l_callstack:' || l_callstack,
         p_user_msg  => 'N',
         p_module    => 'fem.plsql.'||pc_pkg_name||'.'|| l_api_name
      );


      FEM_ENGINES_PKG.Tech_Message (
        p_severity  => pc_log_level_unexpected
        ,p_module   => 'fem.plsql.'||pc_pkg_name||'.'|| l_api_name
        ,p_msg_text => l_prg_msg
      );

      FEM_ENGINES_PKG.Tech_Message (
         p_severity  => pc_log_level_unexpected
         ,p_module   => 'fem.plsql.'||pc_pkg_name||'.'|| l_api_name
         ,p_msg_text => l_callstack
      );

      FEM_ENGINES_PKG.User_Message (
         p_app_name  => G_FEM
         ,p_msg_name => 'FEM_UNEXPECTED_ERROR'
         ,p_token1   => 'ERR_MSG'
         ,p_value1   => l_prg_msg
      );
      x_return_status := pc_ret_sts_unexp_error;
END;


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
  ,x_date_assign_value            out nocopy date,
  x_return_status                OUT NOCOPY VARCHAR2
)
IS

  l_api_name             constant varchar2(30) := 'Get_Dim_Attribute_Value';

  l_dimension_rec        dim_attr_record;

  l_dimension_id         number;
  l_attribute_id         number;
  l_attr_version_id      number;

  l_get_dim_attr_val_error        exception;

BEGIN
   x_return_status := pc_ret_sts_success;

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => pc_log_level_procedure
    ,p_module   => 'fem.plsql.'||pc_pkg_name||'.' ||l_api_name
    ,p_msg_text => 'BEGIN'
  );

  Get_Dim_Attribute (
    p_dimension_varchar_label  => p_dimension_varchar_label
    ,p_attribute_varchar_label => p_attribute_varchar_label
    ,x_dimension_rec           => l_dimension_rec
    ,x_attribute_id            => l_attribute_id
    ,x_attr_version_id         => l_attr_version_id
    ,x_return_status           => x_return_status
  );

  begin
    write_debug(
      p_msg_data  => ' select dim_attribute_varchar_member'||
                   ' ,date_assign_value'||
                   ' from '||l_dimension_rec.attr_table||
                   ' where attribute_id = :b_attribute_id'||
                   ' and version_id = :b_attr_version_id'||
                   ' and '||l_dimension_rec.member_col||' = :b_member_id',
      p_user_msg  => 'N',
      p_module    => 'fem.plsql.'||pc_pkg_name||'.'|| l_api_name
    );

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

      write_debug(
         p_msg_data  => ' exception:' || SQLERRM,
         p_user_msg  => 'N',
         p_module    => 'fem.plsql.'||pc_pkg_name||'.'|| l_api_name
      );

      FEM_ENGINES_PKG.User_Message (
        p_app_name  => 'FEM'
        ,p_msg_name => 'FEM_ENG_NO_DIM_ATTR_VAL_ERR'
        ,p_token1   => 'DIMENSION_VARCHAR_LABEL'
        ,p_value1   => p_dimension_varchar_label
        ,p_token2   => 'ATTRIBUTE_VARCHAR_LABEL'
        ,p_value2   => p_attribute_varchar_label
      );
      raise l_get_dim_attr_val_error;
  end;

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => pc_log_level_procedure
    ,p_module   => 'fem.plsql.'||pc_pkg_name||'.' ||l_api_name
    ,p_msg_text => 'END'
  );

EXCEPTION

  when l_get_dim_attr_val_error then

    FEM_ENGINES_PKG.Tech_Message (
       p_severity  => pc_log_level_unexpected
       ,p_module   => 'fem.plsql.'||pc_pkg_name||'.' ||l_api_name
       ,p_msg_text => 'Get Dimension Attribute Value Exception'
    );

    x_return_status := pc_ret_sts_unexp_error;

END Get_Dim_Attribute_Value;


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
  ,x_dimension_rec                out nocopy dim_attr_record
  ,x_attribute_id                 out nocopy number
  ,x_attr_version_id              out nocopy number
  ,x_return_status                OUT NOCOPY VARCHAR2
)
IS

  l_api_name             constant varchar2(30) := 'Get_Dim_Attribute';

  l_get_dim_attr_error            exception;

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => pc_log_level_procedure
    ,p_module   => 'fem.plsql.'||pc_pkg_name||'.' ||l_api_name
    ,p_msg_text => 'BEGIN'
  );


  begin
    select att.attribute_id
    ,ver.version_id
    ,dim.member_col
    ,dim.attribute_table_name
    into x_attribute_id
    ,x_attr_version_id
    ,x_dimension_rec.member_col
    ,x_dimension_rec.attr_table
    from fem_dim_attributes_b att
    ,fem_dim_attr_versions_b ver
    ,fem_xdim_dimensions_vl dim
    where att.attribute_varchar_label = p_attribute_varchar_label
    AND dim.dimension_varchar_label = p_dimension_varchar_label
    AND dim.dimension_id = att.dimension_id
    and att.attribute_id = ver.attribute_id
    and ver.default_version_flag = 'Y';
  exception
    when others then
      FEM_ENGINES_PKG.User_Message (
        p_app_name  => G_FEM
        ,p_msg_name => 'FEM_ENG_NO_DIM_ATTR_VER_ERR'
        ,p_token1   => 'DIMENSION_VARCHAR_LABEL'
        ,p_value1   => p_dimension_varchar_label
        ,p_token2   => 'ATTRIBUTE_VARCHAR_LABEL'
        ,p_value2   => p_attribute_varchar_label
      );
      raise l_get_dim_attr_error;
  end;

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => pc_log_level_procedure
    ,p_module   => 'fem.plsql.'||'.'||l_api_name
    ,p_msg_text => 'END'
  );

EXCEPTION

  when l_get_dim_attr_error then

     FEM_ENGINES_PKG.Tech_Message (
        p_severity  => pc_log_level_unexpected
        ,p_module   => 'fem.plsql.'||pc_pkg_name||'.' ||l_api_name
        ,p_msg_text => 'Get Dimension Attribute Exception'
     );

    x_return_status := pc_ret_sts_error;

END Get_Dim_Attribute;


/*============================================================================+
 | PROCEDURE
 |   Get_Object_Definition
 |
 | DESCRIPTION
 |   Get the object definition id for the specified object id and effective date.
 |
 |
 | SCOPE - PRIVATE
 |
 +============================================================================*/

PROCEDURE Get_Object_Definition (
  p_object_id                     in number
  ,p_effective_date               in date
  ,x_obj_def_id                   out nocopy number
)
IS

  l_api_name             constant varchar2(30) := 'Get_Object_Definition';

  l_object_name                   varchar2(150);
  l_object_type_code              varchar2(30);

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
     p_severity  => pc_log_level_procedure
     ,p_module   => 'fem.plsql.'||pc_pkg_name||'.' ||l_api_name
     ,p_msg_text => 'BEGIN'
  );

  select d.object_definition_id
  into x_obj_def_id
  from fem_object_definition_b d
  where d.object_id = p_object_id
  and p_effective_date between d.effective_start_date and d.effective_end_date
  and d.old_approved_copy_flag = 'N';

  FEM_ENGINES_PKG.Tech_Message (
     p_severity  => pc_log_level_procedure
     ,p_module   => 'fem.plsql.'||pc_pkg_name||'.' ||l_api_name
     ,p_msg_text => 'BEGIN'
  );

EXCEPTION

   when no_data_found then

      select d.object_definition_id
      into x_obj_def_id
      from fem_object_definition_b d
      where d.object_id = p_object_id
      AND ROWNUM = 1;

      FEM_ENGINES_PKG.Tech_Message (
         p_severity  => pc_log_level_unexpected
         ,p_module   => 'fem.plsql.'||pc_pkg_name||'.' ||l_api_name
         ,p_msg_text => 'No Object Definition was found for Object:' || p_object_id
                        || ' and effective date:' || p_effective_date
      );

END Get_Object_Definition;

PROCEDURE write_debug (
   p_msg_data        IN   VARCHAR2,
   p_user_msg        IN   VARCHAR2,
   p_module          IN   VARCHAR2)
IS
BEGIN
   FEM_ENGINES_PKG.Tech_Message (
      p_severity  => pc_log_level_event
      ,p_module   => p_module
      ,p_msg_text => p_msg_data
   );

   --DBMS_OUTPUT.PUT_LINE (' p_module:' || p_module || ' message:');
   --DBMS_OUTPUT.PUT_LINE ( p_msg_data);
END write_debug;

-- ****************************************************************************

END fem_ud_pkg;

/
