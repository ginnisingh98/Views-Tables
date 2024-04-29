--------------------------------------------------------
--  DDL for Package Body FEM_PL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_PL_PKG" AS
/* $Header: fem_pl_pkb.plb 120.10.12000000.3 2007/08/10 21:08:51 gcheng ship $ */

-- ***********************
-- Package constants
-- ***********************
g_pkg_name CONSTANT VARCHAR2(30) := 'fem_pl_pkg';

g_ret_sts_success     CONSTANT VARCHAR2(1):= fnd_api.g_ret_sts_success;
g_ret_sts_error       CONSTANT VARCHAR2(1):= fnd_api.g_ret_sts_error;
g_ret_sts_unexp_error CONSTANT VARCHAR2(1):= fnd_api.g_ret_sts_unexp_error;

c_resp_app_id CONSTANT NUMBER := FND_GLOBAL.RESP_APPL_ID;

c_log_level_1  CONSTANT  NUMBER  := fnd_log.level_statement;
c_log_level_2  CONSTANT  NUMBER  := fnd_log.level_procedure;
c_log_level_3  CONSTANT  NUMBER  := fnd_log.level_event;
c_log_level_4  CONSTANT  NUMBER  := fnd_log.level_exception;
c_log_level_5  CONSTANT  NUMBER  := fnd_log.level_error;
c_log_level_6  CONSTANT  NUMBER  := fnd_log.level_unexpected;

E_UNEXP        EXCEPTION;


-- ***************************************************************************
--  Private procedure signatures:
-- ***************************************************************************

PROCEDURE Perform_Standard_API_Steps (
  p_current_api_version  IN NUMBER,
  p_caller_api_version   IN NUMBER,
  p_api_name	           IN VARCHAR2,
  p_pkg_name	    	     IN VARCHAR2,
  p_init_msg_list        IN VARCHAR2);

PROCEDURE Get_Translated_Name (
  p_vl_view_name    IN VARCHAR2,
  p_trans_col_name  IN VARCHAR2,
  p_id_col_name     IN VARCHAR2,
  p_id_value        IN NUMBER,
  x_trans_name      OUT NOCOPY VARCHAR2);

PROCEDURE preview_exec_lock_exists (
  p_object_id                 IN  NUMBER,
  p_exec_object_definition_id IN  NUMBER,
  p_calling_context           IN  VARCHAR2 DEFAULT 'ENGINE',
  x_exec_state                OUT NOCOPY VARCHAR2,
  x_prev_request_id           OUT NOCOPY NUMBER,
  x_msg_count                 OUT NOCOPY NUMBER,
  x_msg_data                  OUT NOCOPY VARCHAR2,
  x_exec_lock_exists          OUT NOCOPY VARCHAR2);

-- ***************************************************************************
--  Private procedure bodies:
-- ***************************************************************************

PROCEDURE Perform_Standard_API_Steps (
   p_current_api_version  IN NUMBER,
   p_caller_api_version   IN NUMBER,
   p_api_name	    	    	IN VARCHAR2,
   p_pkg_name	    	    	IN VARCHAR2,
   p_init_msg_list        IN VARCHAR2) IS
--
  C_MODULE  CONSTANT FND_LOG_MESSAGES.module%TYPE :=
                       'fem.plsql.'||g_pkg_name||'.perform_standard_api_steps';
--
BEGIN
-- ==========================================================================
--  Performs the common steps that all standard API's need to perform:
--    1. Check API version compatibility.
--    2. Initialize FND_MSG_PUB message queue if necessary.
-- ==========================================================================

  -- Check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (
           p_current_version_number  => p_current_api_version,
           p_caller_version_number   => p_caller_api_version,
           p_api_name	    	    	   => p_api_name,
           p_pkg_name	    	    	   => p_api_name) THEN
    IF FND_LOG.level_unexpected >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_unexpected,
        p_module   => C_MODULE,
        p_msg_text => 'INTERNAL ERROR: API Version ('||p_current_api_version||') not compatible with '
                    ||'passed in version ('||p_caller_api_version||')');
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize FND message queue
  IF p_init_msg_list = FND_API.G_TRUE then
    FND_MSG_PUB.Initialize;
  END IF;

END Perform_Standard_API_Steps;

-- ***************************************************************************

PROCEDURE Get_Translated_Name (
  p_vl_view_name    IN VARCHAR2,
  p_trans_col_name  IN VARCHAR2,
  p_id_col_name     IN VARCHAR2,
  p_id_value        IN NUMBER,
  x_trans_name      OUT NOCOPY VARCHAR2) IS
--
  v_sql    VARCHAR2(1000);
--
BEGIN
-- ==========================================================================
--  This procedure returns the user translated name given the ID value.
--  Any errors in this API will simply result in the return of the ID as the
--  name.  This includes the case where the ID is not found.
-- ==========================================================================

  v_sql := 'SELECT '||p_trans_col_name
        ||' FROM '||p_vl_view_name
        ||' WHERE '||p_id_col_name||' = :id';
   fem_engines_pkg.tech_message (
      p_severity => c_log_level_1,
      p_module => 'fem.plsql.'||g_pkg_name||'.get_translated_name',
      p_msg_text => 'v_sql: '||v_sql);

  BEGIN
    EXECUTE IMMEDIATE v_sql INTO x_trans_name USING p_id_value;
  EXCEPTION
    WHEN others THEN
      x_trans_name := to_char(p_id_value);
  END;

END Get_Translated_Name;

-- ***************************************************************************
--  Public procedures:
-- ***************************************************************************

-- ***************************************************************************

PROCEDURE obj_def_data_edit_lock_exists (
   p_object_definition_id   IN  NUMBER,
   x_data_edit_lock_exists  OUT NOCOPY VARCHAR2
) IS
-- ==========================================================================
--  Check if data lock exists for the object definition
--  If object is one which cannot be modified if it has been read whilst
--     generating results (i.e FEM_OBJECT_TYPES.DATA_EDIT_LOCK_FLAG='Y') then,
--     Check to see if object definition read by existing executions.
--     If object definition read, OR,
--        object definition is a seeded definition (i.e ID < 10000), then,
--        it means data lock exists.
--     else
--        data lock does not exist.
-- ==========================================================================
v_count NUMBER;
v_object_id NUMBER;
v_data_edit_lock_flag VARCHAR2(1);
l_api_name CONSTANT VARCHAR2(30) := 'obj_def_data_edit_lock_exists';

BEGIN

   fem_engines_pkg.tech_message (
      p_severity => c_log_level_1,
      p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
      p_msg_text => 'Begin.  P_OBJECT_DEFINITION_ID:'||
      p_object_definition_id);

   SELECT object_id
   INTO v_object_id
   FROM fem_object_definition_b
   WHERE object_definition_id = p_object_definition_id;

   SELECT t.data_edit_lock_flag
   INTO v_data_edit_lock_flag
   FROM fem_object_definition_b d,
        fem_object_catalog_b o,
        fem_object_types t
   WHERE d.object_definition_id = p_object_definition_id
   AND d.object_id = o.object_id
   AND o.object_type_code = t.object_type_code;

   SELECT COUNT(*)
   INTO v_count
   FROM fem_pl_object_defs
   WHERE object_definition_id = p_object_definition_id;

   IF (p_object_definition_id < 10000) THEN
      x_data_edit_lock_exists := 'T';
   ELSIF (v_data_edit_lock_flag = 'Y') AND (v_count > 0) THEN
      x_data_edit_lock_exists := 'T';
   ELSE
      x_data_edit_lock_exists := 'F';
   END IF;

   fem_engines_pkg.tech_message (
      p_severity => c_log_level_1,
      p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
      p_msg_text => 'End. X_DATA_EDIT_LOCK_EXISTS:'||
      x_data_edit_lock_exists);

END obj_def_data_edit_lock_exists;
-- ******************************************************************************

PROCEDURE effective_date_incl_rslt_data (
     p_api_version              IN  NUMBER,
     p_init_msg_list            IN  VARCHAR2   DEFAULT FND_API.G_FALSE,
     p_encoded                  IN  VARCHAR2   DEFAULT FND_API.G_TRUE,
     x_return_status            OUT NOCOPY VARCHAR2,
     x_msg_count                OUT NOCOPY NUMBER,
     x_msg_data                 OUT NOCOPY VARCHAR2,
     p_object_definition_id     IN  NUMBER,
     p_new_effective_start_date IN  DATE,
     p_new_effective_end_date   IN  DATE,
     x_date_incl_rslt_data      OUT NOCOPY VARCHAR2) IS

-- ==========================================================================
--  Note: The code assumes p_new_effective_start_date<=p_new_effective_end_date
-- ==========================================================================
--  If new effective start date is greater than earliest effective date used
--     to select object definition for processing OR
--      new effective end date is less than latest effective date used
--     to select object definition for processing THEN
--     Effective date does not include result data range (Return false).
--  else
--     Effective date includes result data range (Return true).
--  end if.
-- ==========================================================================

   C_API_NAME      CONSTANT VARCHAR2(30) := 'effective_date_incl_rslt_data';
   C_MODULE        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
                              'fem.plsql.'||g_pkg_name||'.'||C_API_NAME;
   C_API_VERSION   CONSTANT NUMBER := 1.0;

   v_rslts_start_date   DATE;
   v_rslts_end_date     DATE;
   v_obj_def_name            FEM_OBJECT_DEFINITION_TL.display_name%TYPE;

BEGIN

   IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fem_engines_pkg.tech_message(p_severity => c_log_level_1,
         p_module => C_MODULE,
         p_msg_text => 'Begin.  P_OBJECT_DEFINITION_ID:'
           ||p_object_definition_id||' P_NEW_EFFECTIVE_START_DATE:'
           ||fnd_date.date_to_displaydate(p_new_effective_start_date)
           ||' P_NEW_EFFECTIVE_END_DATE:'
           ||fnd_date.date_to_displaydate(p_new_effective_end_date));
   END IF;

   Perform_Standard_API_Steps(
      p_current_api_version  => C_API_VERSION,
      p_caller_api_version   => p_api_version,
      p_api_name	    	     => C_API_NAME,
      p_pkg_name	    	     => G_PKG_NAME,
      p_init_msg_list        => p_init_msg_list);

   SELECT min(r.effective_date), max(r.effective_date)
   INTO v_rslts_start_date, v_rslts_end_date
   FROM fem_pl_requests r, fem_pl_object_defs d
   WHERE r.request_id = d.request_id
   AND d.object_definition_id = p_object_definition_id;

   IF p_new_effective_start_date > v_rslts_start_date OR
      p_new_effective_end_date < v_rslts_end_date THEN

      Get_Translated_Name (
         p_vl_view_name    => 'FEM_OBJECT_DEFINITION_VL',
         p_trans_col_name  => 'DISPLAY_NAME',
         p_id_col_name     => 'OBJECT_DEFINITION_ID',
         p_id_value        => p_object_definition_id,
         x_trans_name      => v_obj_def_name);
      fem_engines_pkg.put_message(
         p_app_name => 'FEM',
         p_msg_name =>'FEM_PL_EFFDT_OUTSIDE_RSLTS_ERR',
         p_token1 => 'OBJ_DEF_NAME',
         p_value1 => v_obj_def_name,
         p_trans1 => 'N',
         p_token2 => 'RESULT_DATA_START_DATE',
         p_value2 => fnd_date.date_to_displaydate(v_rslts_start_date),
         p_trans2 => 'N',
         p_token3 => 'RESULT_DATA_END_DATE',
         p_value3 => fnd_date.date_to_displaydate(v_rslts_end_date),
         p_trans3 => 'N');

      x_date_incl_rslt_data := 'F';
   ELSE
      x_date_incl_rslt_data := 'T';
   END IF;

   IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fem_engines_pkg.tech_message(
         p_severity => c_log_level_1,
         p_module => C_MODULE,
         p_msg_text => 'End.  X_DATE_INCL_RSLT_DATA:'||
         x_date_incl_rslt_data);
   END IF;

   FND_MSG_PUB.Count_And_Get(p_encoded => p_encoded,
                             p_count => x_msg_count,
                             p_data => x_msg_data);

   -- Returning error if this API is putting an error message
   -- on the stack so OAF code will detect the error and pull
   -- that message off the stack.
   IF x_date_incl_rslt_data = 'F' THEN
      x_return_status := g_ret_sts_error;
   ELSE
      x_return_status := g_ret_sts_success;
   END IF;

EXCEPTION
  WHEN others THEN
    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'Unexpected error.');
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => SQLERRM);
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded => p_encoded,
                              p_count => x_msg_count,
                              p_data => x_msg_data);
    x_date_incl_rslt_data := 'F';
    x_return_status := g_ret_sts_unexp_error;

END effective_date_incl_rslt_data;


PROCEDURE effective_date_incl_rslt_data (
     p_object_definition_id     IN  NUMBER,
     p_new_effective_start_date IN  DATE,
     p_new_effective_end_date   IN  DATE,
     x_msg_count                OUT NOCOPY NUMBER,
     x_msg_data                 OUT NOCOPY VARCHAR2,
     x_date_incl_rslt_data      OUT NOCOPY VARCHAR2) IS
-- ==========================================================================
-- API signature kept for backward compatibility.  It simply calls the
--   effective_date_incl_rslt_data that follows the FND API standards.
-- ==========================================================================
   v_return_status VARCHAR2(1);
BEGIN
   effective_date_incl_rslt_data (
      p_api_version              => 1.0,
      x_return_status            => v_return_status,
      x_msg_count                => x_msg_count,
      x_msg_data                 => x_msg_data,
      p_object_definition_id     => p_object_definition_id,
      p_new_effective_start_date => p_new_effective_start_date,
      p_new_effective_end_date   => p_new_effective_end_date,
      x_date_incl_rslt_data      => x_date_incl_rslt_data);
END effective_date_incl_rslt_data;

-- ******************************************************************************
PROCEDURE obj_def_approval_lock_exists (p_object_definition_id IN  NUMBER,
                                        x_approval_edit_lock_exists  OUT NOCOPY VARCHAR2) IS
-- ==========================================================================
--  Return true if object definition has been submitted for approval.
-- ==========================================================================
v_count NUMBER;
l_api_name  CONSTANT VARCHAR2(30) := 'obj_def_approval_lock_exists';

BEGIN

   fem_engines_pkg.tech_message(p_severity => c_log_level_1,
   p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
   p_msg_text => 'Begin.  P_OBJECT_DEFINITION_ID:'||p_object_definition_id);

   SELECT COUNT(*) INTO v_count
   FROM fem_object_definition_b
   WHERE object_definition_id = p_object_definition_id
   AND approval_status_code IN ('SUBMIT_APPROVAL','SUBMIT_DELETE');

   IF v_count = 1 THEN
      x_approval_edit_lock_exists := 'T';
   ELSE
     x_approval_edit_lock_exists := 'F';
  END IF;

    fem_engines_pkg.tech_message(p_severity => c_log_level_1,
    p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
    p_msg_text => 'End. X_APPROVAL_EDIT_LOCK_EXISTS:'||
    x_approval_edit_lock_exists);

END obj_def_approval_lock_exists;
-- ******************************************************************************
PROCEDURE get_object_def_edit_locks (p_object_definition_id IN  NUMBER,
                                     x_approval_edit_lock_exists  OUT NOCOPY VARCHAR2,
                                     x_data_edit_lock_exists  OUT NOCOPY VARCHAR2) IS
-- ==========================================================================
--  Return x_approval_edit_lock_exists = 'T' if object definition has been
--  submitted for approval.
--  Return x_data_edit_lock_exists = 'T' if object definition is referenced by
--  result data.
-- ==========================================================================
v_count NUMBER;
l_api_name  CONSTANT VARCHAR2(30) := 'get_object_def_edit_locks';

BEGIN

   fem_engines_pkg.tech_message(p_severity => c_log_level_1,
   p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
   p_msg_text => 'Begin.  P_OBJECT_DEFINITION_ID:'||p_object_definition_id);

   obj_def_approval_lock_exists(p_object_definition_id, x_approval_edit_lock_exists);
   obj_def_data_edit_lock_exists(p_object_definition_id, x_data_edit_lock_exists);

   fem_engines_pkg.tech_message(p_severity => c_log_level_1,
   p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
   p_msg_text => 'End. X_APPROVAL_EDIT_LOCK_EXISTS:'||
   x_approval_edit_lock_exists||' X_DATA_EDIT_LOCK_EXISTS:'||x_data_edit_lock_exists);

END get_object_def_edit_locks;

-- ***************************************************************************

PROCEDURE can_delete_object_def (
   p_api_version              IN  NUMBER,
   p_init_msg_list            IN  VARCHAR2   DEFAULT FND_API.G_FALSE,
   p_encoded                  IN  VARCHAR2   DEFAULT FND_API.G_TRUE,
   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2,
   p_object_definition_id     IN  NUMBER,
   p_process_type             IN  NUMBER DEFAULT NULL,
   p_calling_program          IN  VARCHAR2 DEFAULT NULL,
   x_can_delete_obj_def       OUT NOCOPY VARCHAR2) IS
-- ==========================================================================
-- Purpose
--    Checks to see if a rule (object) can be deleted or not.
-- Arguments
--    p_object_definition_id  ID of the rule version being checked
--    p_process_type          1 indicates procedure called from a workflow
--                              process.  This parameter should only be
--                              used by workflow code.
--    p_calling_program       This parameter should only be used if this API is
--                              being called by the "can_delete_object" API.
--    x_can_delete_obj_def    Returns 'T' if the rule version can be deleted;
--                              'F' otherwise.
--    x_return_status         Returns 'S' if the rule version can be deleted;
--                              'E' if rule version cannot be deleted and
--                              this API has placed error message(s) on
--                              the stack; 'U' for unexpected error.
-- Logic
--   A rule version can only be deleted if it is not is not seeded
--   (i.e ID < 10000), AND it is not Data Edit Locked, AND it is not the
--   only version defined for the rule, AND it is not Approval locked
--   (unless this is called from a workflow process and the
--   Approval Status is 'SUBMIT_DELETE').
-- ==========================================================================

C_API_NAME      CONSTANT VARCHAR2(30) := 'can_delete_object_def';
C_MODULE        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
                           'fem.plsql.'||g_pkg_name||'.'||C_API_NAME;
C_API_VERSION   CONSTANT NUMBER := 1.0;

v_object_id               NUMBER(9);
v_approval_status_code    VARCHAR2(30);
v_num_of_definitions      NUMBER;
v_data_edit_lock_exists   VARCHAR2(1);
v_approval_edit_lock_exists VARCHAR2(1);
v_obj_name                FEM_OBJECT_CATALOG_TL.object_name%TYPE;
v_obj_def_id              FEM_OBJECT_DEFINITION_B.object_definition_id%TYPE;
v_obj_def_name            FEM_OBJECT_DEFINITION_TL.display_name%TYPE;
v_dep_obj_id              FEM_OBJECT_CATALOG_B.object_id%TYPE;
v_dep_obj_name            FEM_OBJECT_CATALOG_TL.object_name%TYPE;

e_definition_is_seeded    EXCEPTION;
e_data_edit_locked        EXCEPTION;
e_only_definition         EXCEPTION;
e_approval_edit_locked    EXCEPTION;

BEGIN

   IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fem_engines_pkg.tech_message (
         p_severity => c_log_level_1,
         p_module => C_MODULE,
         p_msg_text => 'Begin.  P_OBJECT_DEFINITION_ID:'||
         p_object_definition_id||' P_PROCESS_TYPE:'||p_process_type);
   END IF;

   Perform_Standard_API_Steps(
      p_current_api_version  => C_API_VERSION,
      p_caller_api_version   => p_api_version,
      p_api_name	    	     => C_API_NAME,
      p_pkg_name	    	     => G_PKG_NAME,
      p_init_msg_list        => p_init_msg_list);

   BEGIN
      SELECT object_id, approval_status_code
      INTO v_object_id, v_approval_status_code
      FROM fem_object_definition_b
      WHERE object_definition_id = p_object_definition_Id;
   EXCEPTION
      -- If no_data_found, then the version does not exist
      -- and is safe to delete.  Skip all other checks and exit procedure.
      WHEN no_data_found THEN
         IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            fem_engines_pkg.tech_message(
            p_severity => c_log_level_2,
            p_module => C_MODULE,
            p_msg_text => 'No data found for object definition. '||
               'OBJECT_DEFINITION_ID:'||p_object_definition_id);
         END IF;
         x_can_delete_obj_def := 'T';
         x_return_status := g_ret_sts_success;
         RETURN;
   END;

   -- Cannot delete version if it is seeded
   IF (p_object_definition_id < 10000) THEN
      RAISE e_definition_is_seeded;
   END IF;

   get_object_def_edit_locks (
      p_object_definition_id,
      v_approval_edit_lock_exists,
      v_data_edit_lock_exists);

   -- Cannot delete if data edit lock exists
   IF (v_data_edit_lock_exists = 'T') THEN
      RAISE e_data_edit_locked;
   END IF;

   -- If this API is not called by 'can_delete_object',
   -- then we need to check if this is the only version defined for
   -- the rule.  If it is, then the version cannot be deleted.
   -- If this API is called by 'can_delete_object', then this check
   -- is not necessary because deleting the object will delete the versions.
   IF (nvl(p_calling_program,'X') <> 'can_delete_object') THEN
      SELECT COUNT(*)
      INTO v_num_of_definitions
      FROM fem_object_definition_b
      WHERE object_id = v_object_id
      AND old_approved_copy_flag = 'N';

      IF (v_num_of_definitions = 1) THEN
         RAISE e_only_definition;
      END IF;
   END IF;

   -- If the approval edit lock exists, the version cannot be
   -- deleted unless the API is being called from a workflow process
   -- and the approval status code is 'SUBMIT_DELETE'.
   IF (v_approval_edit_lock_exists = 'T') THEN
      IF ((p_process_type = 1) AND
          (v_approval_status_code = 'SUBMIT_DELETE')) THEN
         null;
      ELSE
         RAISE e_approval_edit_locked;
      END IF;
   END IF;

   x_can_delete_obj_def := 'T';

   FND_MSG_PUB.Count_And_Get
      (p_encoded => p_encoded,
       p_count => x_msg_count,
       p_data => x_msg_data);

   IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fem_engines_pkg.tech_message(
         p_severity => c_log_level_1,
         p_module => C_MODULE,
         p_msg_text => 'End. X_CAN_DELETE_OBJ_DEF:'||x_can_delete_obj_def);
   END IF;

   x_return_status := g_ret_sts_success;

EXCEPTION
   WHEN e_definition_is_seeded THEN
      Get_Translated_Name (
         p_vl_view_name    => 'FEM_OBJECT_DEFINITION_VL',
         p_trans_col_name  => 'DISPLAY_NAME',
         p_id_col_name     => 'OBJECT_DEFINITION_ID',
         p_id_value        => p_object_definition_id,
         x_trans_name      => v_obj_def_name);
      fem_engines_pkg.put_message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_PL_CANNOT_DEL_SEEDED_DEF',
         p_token1 => 'OBJECT_DEF_NAME',
         p_value1 => v_obj_def_name);
      FND_MSG_PUB.Count_And_Get(p_encoded => p_encoded,
                                p_count => x_msg_count,
                                p_data => x_msg_data);
      x_can_delete_obj_def := 'F';
      -- Returning error so OAF code will detect error
      -- and get the messages off the stack.
      x_return_status := g_ret_sts_error;

   WHEN e_data_edit_locked THEN
      Get_Translated_Name (
         p_vl_view_name    => 'FEM_OBJECT_DEFINITION_VL',
         p_trans_col_name  => 'DISPLAY_NAME',
         p_id_col_name     => 'OBJECT_DEFINITION_ID',
         p_id_value        => p_object_definition_id,
         x_trans_name      => v_obj_def_name);
      fem_engines_pkg.put_message(
         p_app_name => 'FEM',
         p_msg_name =>'FEM_PL_DATA_LOCKED_DEF_ERR',
         p_token1 => 'OBJECT_DEF_NAME',
         p_value1 => v_obj_def_name);
      FND_MSG_PUB.Count_And_Get(p_encoded => p_encoded,
                                p_count => x_msg_count,
                                p_data => x_msg_data);
      x_can_delete_obj_def := 'F';
      x_return_status := g_ret_sts_error;

   WHEN e_only_definition THEN
      Get_Translated_Name (
         p_vl_view_name    => 'FEM_OBJECT_CATALOG_VL',
         p_trans_col_name  => 'OBJECT_NAME',
         p_id_col_name     => 'OBJECT_ID',
         p_id_value        => v_object_id,
         x_trans_name      => v_obj_name);
      Get_Translated_Name (
         p_vl_view_name    => 'FEM_OBJECT_DEFINITION_VL',
         p_trans_col_name  => 'DISPLAY_NAME',
         p_id_col_name     => 'OBJECT_DEFINITION_ID',
         p_id_value        => p_object_definition_id,
         x_trans_name      => v_obj_def_name);
      fem_engines_pkg.put_message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_PL_CANNOT_DEL_LAST_DEF',
         p_token1 => 'OBJECT_DEF_NAME',
         p_value1 => v_obj_def_name,
         p_token2 => 'OBJECT_NAME',
         p_value2 => v_obj_name);
      FND_MSG_PUB.Count_And_Get(p_encoded => p_encoded,
                                p_count => x_msg_count,
                                p_data => x_msg_data);
      x_can_delete_obj_def := 'F';
      x_return_status := g_ret_sts_error;

   WHEN e_approval_edit_locked THEN
      Get_Translated_Name (
         p_vl_view_name    => 'FEM_OBJECT_DEFINITION_VL',
         p_trans_col_name  => 'DISPLAY_NAME',
         p_id_col_name     => 'OBJECT_DEFINITION_ID',
         p_id_value        => p_object_definition_id,
         x_trans_name      => v_obj_def_name);
      fem_engines_pkg.put_message(
         p_app_name => 'FEM',
         p_msg_name =>'FEM_PL_SUBMITTED_DEF_ERR',
         p_token1 => 'OBJECT_DEF_NAME',
         p_value1 => v_obj_def_name);
      FND_MSG_PUB.Count_And_Get(p_encoded => p_encoded,
                                p_count => x_msg_count,
                                p_data => x_msg_data);
      x_can_delete_obj_def := 'F';
      x_return_status := g_ret_sts_error;

   WHEN others THEN
      IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FEM_ENGINES_PKG.TECH_MESSAGE(
            p_severity => FND_LOG.level_statement,
            p_module   => C_MODULE,
            p_msg_text => 'Unexpected error.');
         FEM_ENGINES_PKG.TECH_MESSAGE(
            p_severity => FND_LOG.level_statement,
            p_module   => C_MODULE,
            p_msg_text => SQLERRM);
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded => p_encoded,
                                p_count => x_msg_count,
                                p_data => x_msg_data);
      x_can_delete_obj_def := 'F';
      x_return_status := g_ret_sts_unexp_error;

END can_delete_object_def;


PROCEDURE can_delete_object_def (
   p_object_definition_id     IN  NUMBER,
   x_can_delete_obj_def       OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2,
   p_process_type             IN  NUMBER DEFAULT NULL,
   p_calling_program          IN  VARCHAR2 DEFAULT NULL) IS
-- ==========================================================================
-- API signature kept for backward compatibility.  It simply calls the
--   can_delete_object_def that follows the FND API standards.
-- ==========================================================================
   v_return_status VARCHAR2(1);
BEGIN
   can_delete_object_def (
      p_api_version          => 1.0,
      x_return_status        => v_return_status,
      x_msg_count            => x_msg_count,
      x_msg_data             => x_msg_data,
      p_object_definition_id => p_object_definition_id,
      p_process_type         => p_process_type,
      p_calling_program      => p_calling_program,
      x_can_delete_obj_def   => x_can_delete_obj_def);
END can_delete_object_def;

-- **************************************************************************

PROCEDURE can_delete_object (
   p_api_version          IN  NUMBER,
   p_init_msg_list        IN  VARCHAR2   DEFAULT FND_API.G_FALSE,
   p_encoded              IN  VARCHAR2   DEFAULT FND_API.G_TRUE,
   x_return_status        OUT NOCOPY VARCHAR2,
   x_msg_count            OUT NOCOPY NUMBER,
   x_msg_data             OUT NOCOPY VARCHAR2,
   p_object_id            IN  NUMBER,
   p_process_type         IN  NUMBER DEFAULT NULL,
   x_can_delete_obj       OUT NOCOPY VARCHAR2) IS
-- ==========================================================================
-- Purpose
--    Checks to see if a rule (object) can be deleted or not.
-- Arguments
--    p_object_id        ID of the rule being checked
--    p_process_type     1 indicates procedure called from a workflow process.
--                         This parameter should only be used by workflow code.
--    x_can_delete_obj   Returns 'T' if rule can be deleted; 'F' otherwise.
--    x_return_status    Returns 'S' if rule can be deleted; 'E' if rule
--                         cannot be deleted and this API has placed error
--                         message(s) on the stack; 'U' for unexpected error.
-- Logic
--   A rule can only be deleted if all of its versions can be
--   deleted AND the rule is not seeded (i.e ID < 10000),
--   AND the rule is not referenced by another rule.
-- ==========================================================================

CURSOR c1 IS
   SELECT object_definition_id
   FROM fem_object_definition_b
   WHERE object_id = p_object_id
   AND old_approved_copy_flag = 'N';

CURSOR c_object_dependencies (p_object_id NUMBER) IS
   SELECT object_definition_id
   FROM fem_object_dependencies
   WHERE required_object_id = p_object_id;

C_API_NAME      CONSTANT VARCHAR2(30) := 'can_delete_object';
C_MODULE        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
                            'fem.plsql.'||g_pkg_name||'.'||C_API_NAME;
C_API_VERSION   CONSTANT NUMBER := 1.0;

v_can_delete_object_def   VARCHAR2(1);
v_obj_name                FEM_OBJECT_CATALOG_TL.object_name%TYPE;
v_obj_def_id              FEM_OBJECT_DEFINITION_B.object_definition_id%TYPE;
v_obj_def_name            FEM_OBJECT_DEFINITION_TL.display_name%TYPE;
v_dep_obj_id              FEM_OBJECT_CATALOG_B.object_id%TYPE;
v_dep_obj_name            FEM_OBJECT_CATALOG_TL.object_name%TYPE;
v_return_status           VARCHAR2(1);

e_cannot_del_version      EXCEPTION;
e_object_is_seeded        EXCEPTION;
e_dependencies_exist      EXCEPTION;

BEGIN

   IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fem_engines_pkg.tech_message(
         p_severity => c_log_level_1,
         p_module => C_MODULE,
         p_msg_text => 'Begin.  P_OBJECT_ID:'||
                       p_object_id||' P_PROCESS_TYPE:'||p_process_type);
   END IF;

   Perform_Standard_API_Steps(
      p_current_api_version  => C_API_VERSION,
      p_caller_api_version   => p_api_version,
      p_api_name	    	     => C_API_NAME,
      p_pkg_name	    	     => G_PKG_NAME,
      p_init_msg_list        => p_init_msg_list);

   -- Check to see if the rule can be removed.
   IF (p_object_id < 10000) THEN
      RAISE e_object_is_seeded;
   END IF;

   -- Check to make sure the versions themselves
   -- can be deleted.  This check is done before the
   -- dependencies check to make sure
   -- the error messaging is consistent regardless if
   -- the UI calls can_delete_object_def or this API when
   -- the user wants to delete a version or rule.
   -- See bug 4600065 for details of this issue.
   FOR adef IN c1 LOOP
      can_delete_object_def(
         p_api_version          => 1.0,
         p_init_msg_list        => FND_API.G_FALSE,
         p_encoded              => p_encoded,
         x_return_status        => v_return_status,
         x_msg_count            => x_msg_count,
         x_msg_data             => x_msg_data,
         p_object_definition_id => adef.object_definition_id,
         p_process_type         => p_process_type,
         p_calling_program      => 'can_delete_object',
         x_can_delete_obj_def   => v_can_delete_object_def);

      IF (v_return_status = g_ret_sts_unexp_error) THEN
         RAISE E_UNEXP;
      END IF;

      IF (v_can_delete_object_def = 'F') THEN
         v_obj_def_id := adef.object_definition_id;
         RAISE e_cannot_del_version;
      END IF;
   END LOOP;

   -- Check to see if rule is referenced by any other rules.
   OPEN c_object_dependencies(p_object_id);
   FETCH c_object_dependencies INTO v_obj_def_id;
   CLOSE c_object_dependencies;

   IF (v_obj_def_id IS NOT NULL) THEN
      RAISE e_dependencies_exist;
   END IF;

   FND_MSG_PUB.Count_And_Get(p_encoded => p_encoded,
                             p_count => x_msg_count,
                             p_data => x_msg_data);

   x_can_delete_obj := 'T';
   x_return_status := g_ret_sts_success;

   IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fem_engines_pkg.tech_message(
         p_severity => c_log_level_1,
         p_module => C_MODULE,
         p_msg_text => 'End.  X_CAN_DELETE_OBJ:'||x_can_delete_obj);
   END IF;

EXCEPTION
   WHEN e_cannot_del_version THEN
      Get_Translated_Name (
         p_vl_view_name    => 'FEM_OBJECT_CATALOG_VL',
         p_trans_col_name  => 'OBJECT_NAME',
         p_id_col_name     => 'OBJECT_ID',
         p_id_value        => p_object_id,
         x_trans_name      => v_obj_name);
      Get_Translated_Name (
         p_vl_view_name    => 'FEM_OBJECT_DEFINITION_VL',
         p_trans_col_name  => 'DISPLAY_NAME',
         p_id_col_name     => 'OBJECT_DEFINITION_ID',
         p_id_value        => v_obj_def_id,
         x_trans_name      => v_obj_def_name);
      fem_engines_pkg.put_message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_PL_CANNOT_DELETE_DEF_ERR',
         p_token1 => 'OBJECT_NAME',
         p_value1 => v_obj_name,
         p_token2 => 'OBJECT_DEF_NAME',
         p_value2 => v_obj_def_name);
      FND_MSG_PUB.Count_And_Get(p_encoded => p_encoded,
                                p_count => x_msg_count,
                                p_data => x_msg_data);
      x_can_delete_obj := 'F';
      -- Returning error so OAF code will detect error
      -- and get the messages off the stack.
      x_return_status := g_ret_sts_error;

   WHEN e_object_is_seeded THEN
      Get_Translated_Name (
         p_vl_view_name    => 'FEM_OBJECT_CATALOG_VL',
         p_trans_col_name  => 'OBJECT_NAME',
         p_id_col_name     => 'OBJECT_ID',
         p_id_value        => p_object_id,
         x_trans_name      => v_obj_name);
      fem_engines_pkg.put_message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_PL_CANNOT_DEL_SEEDED_OBJ',
         p_token1 => 'OBJECT_NAME',
         p_value1 => v_obj_name,
         p_trans1 => 'N');
      FND_MSG_PUB.Count_And_Get(p_encoded => p_encoded,
                                p_count => x_msg_count,
                                p_data => x_msg_data);
      x_can_delete_obj := 'F';
      x_return_status := g_ret_sts_error;

   WHEN e_dependencies_exist THEN
      Get_Translated_Name (
         p_vl_view_name    => 'FEM_OBJECT_CATALOG_VL',
         p_trans_col_name  => 'OBJECT_NAME',
         p_id_col_name     => 'OBJECT_ID',
         p_id_value        => p_object_id,
         x_trans_name      => v_obj_name);
      Get_Translated_Name (
         p_vl_view_name    => 'FEM_OBJECT_DEFINITION_VL',
         p_trans_col_name  => 'DISPLAY_NAME',
         p_id_col_name     => 'OBJECT_DEFINITION_ID',
         p_id_value        => v_obj_def_id,
         x_trans_name      => v_obj_def_name);

      SELECT c.object_id, c.object_name
      INTO v_dep_obj_id, v_dep_obj_name
      FROM fem_object_catalog_vl c, fem_object_definition_b d
      WHERE c.object_id = d.object_id
      AND d.object_definition_id = v_obj_def_id;

      fem_engines_pkg.put_message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_PL_REFERENCED_OBJ_ERR',
         p_token1 => 'OBJECT_NAME',
         p_value1 => v_obj_name,
         p_token2 => 'DEP_OBJECT_NAME',
         p_value2 => v_dep_obj_name,
         p_token3 => 'DEP_OBJECT_DEF_NAME',
         p_value3 => v_obj_def_name);
      FND_MSG_PUB.Count_And_Get(p_encoded => p_encoded,
                                p_count => x_msg_count,
                                p_data => x_msg_data);
      x_can_delete_obj := 'F';
      x_return_status := g_ret_sts_error;

   WHEN others THEN
     IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FEM_ENGINES_PKG.TECH_MESSAGE(
           p_severity => FND_LOG.level_statement,
           p_module   => C_MODULE,
           p_msg_text => 'Unexpected error.');
        FEM_ENGINES_PKG.TECH_MESSAGE(
           p_severity => FND_LOG.level_statement,
           p_module   => C_MODULE,
           p_msg_text => SQLERRM);
     END IF;
     FND_MSG_PUB.Count_And_Get(p_encoded => p_encoded,
                               p_count => x_msg_count,
                               p_data => x_msg_data);
     x_can_delete_obj := 'd';
     x_return_status := g_ret_sts_unexp_error;

END can_delete_object;


PROCEDURE can_delete_object (
   p_object_id            IN  NUMBER,
   p_process_type         IN  NUMBER DEFAULT NULL,
   x_can_delete_obj       OUT NOCOPY VARCHAR2,
   x_msg_count            OUT NOCOPY NUMBER,
   x_msg_data             OUT NOCOPY VARCHAR2) IS
-- ==========================================================================
-- API signature kept for backward compatibility.  It simply calls the
--   can_delete_object that follows the FND API standards.
-- ==========================================================================
   v_return_status VARCHAR2(1);
BEGIN
   can_delete_object (
      p_api_version          => 1.0,
      x_return_status        => v_return_status,
      x_msg_count            => x_msg_count,
      x_msg_data             => x_msg_data,
      p_object_id            => p_object_id,
      p_process_type         => p_process_type,
      x_can_delete_obj       => x_can_delete_obj);
END can_delete_object;

-- ******************************************************************************
PROCEDURE obj_execution_lock_exists  (p_object_id            IN  NUMBER,
                                      p_exec_object_definition_id IN NUMBER,
                                      p_ledger_id            IN  NUMBER DEFAULT NULL,
                                      p_cal_period_id        IN  NUMBER DEFAULT NULL,
                                      p_output_dataset_code  IN  NUMBER DEFAULT NULL,
                                      p_source_system_code   IN  NUMBER DEFAULT NULL,
                                      p_exec_mode_code       IN  VARCHAR2 DEFAULT NULL,
                                      p_dimension_id         IN  NUMBER DEFAULT NULL,
                                      p_table_name           IN  VARCHAR2 DEFAULT NULL,
                                      p_hierarchy_name       IN  VARCHAR2 DEFAULT NULL,
                                      p_calling_context      IN  VARCHAR2 DEFAULT 'ENGINE',
                                      x_exec_state           OUT NOCOPY VARCHAR2,
                                      x_prev_request_id      OUT NOCOPY NUMBER,
                                      x_msg_count            OUT NOCOPY NUMBER,
                                      x_msg_data             OUT NOCOPY VARCHAR2,
                                      x_exec_lock_exists     OUT NOCOPY VARCHAR2) IS
-- ==========================================================================
--  Returns true if an object execution lock exists.
--    Calls specialized procedures for specific object types.  If object is
--      execution locked and does not have a specified procedure, uses
--      the procedure for mapping rules.
--      This procedure does not detect execution state for non execution locked
--      objects.
-- ==========================================================================
-- BEGIN obj_execution_lock_exists
-- IF an approval edit lock exists for the object definition to be executed THEN
--    Return T;
--    Fem_engines_pkg.put_message (FEM_PL_SUBMITTED_DEF_ERR).
-- ELSIF object_type IN ('XGL_INTEGRATION', 'OGL_INTG_BAL_RULE',
--                       'SOURCE_DATA_LOADER', EGL_INTG_BAL_RULE') THEN
--    Call specialized procedure (FEM_PL_INCR_PKG.Obj_Exec_Lock_Exists)
-- ELSIF object_type IN ('DIM_MEMBER_LOADER',
--                       'OGL_INTG_DIM_RULE',
--                       'OGL_INTG_CAL_RULE',
--                       'EGL_INTG_DIM_RULE',
--                       'EGL_INTG_CAL_RULE',
--                       'UNDO',
--                       'REFRESH_ENGINE'),
--                       'DIM_MEMBER_MIGRATION',
--                       'HIERARCHY_MIGRATION') THEN
--    Call specialized procedure (fem_pl_pkg.dim_mbr_ldr_Exec_Lock_Exists)
-- ELSIF object_type = 'DATAX_LOADER' THEN
--    Call specialized procedure (fem_pl_pkg.datax_ldr_Exec_Lock_Exists)
-- ELSIF object_type in ('HIERARCHY_LOADER', 'OGL_INTG_HIER_RULE',
--                       'EGL_INTG_HIER_RULE')  THEN
--    Call specialized procedure (fem_pl_pkg.hier_ldr_Exec_Lock_Exists)
-- ELSIF object_type in ('RCM_PROCESS_RULE','TP_PROCESS_RULE')  THEN
--    Call specialized procedure (fem_pl_pkg.rcm_proc_Exec_Lock_Exists)
-- ELSIF object_type = 'MAPPING_PREVIEW'  THEN
--    Call specialized procedure (fem_pl_pkg.Preview_Exec_Lock_Exists)
-- ELSIF an executable locked object (i.e FEM_OBJECT_TYPES.EXECUTABLE_LOCK = Y) THEN
--    Call specialized procedure (fem_pl_pkg.mapping_Exec_Lock_Exists)
-- ELSIF not an executable locked object
--    (i.e FEM_OBJECT_TYPES.EXECUTABLE_LOCK = N) THEN
--    Set execution state (IF object execution is
--    already registered and is running THEN x_exec_state='RESTART' ELSE
--    x_exec_state = 'NORMAL).
--    Return F.
-- ELSE
--    Return T and put message ('FEM_PL_RESULTS_EXIST_ERR');
-- End if;
-- END obj_execution_lock_exists;
-- ==========================================================================

v_approval_edit_lock_exists VARCHAR2(1);
v_executable_lock_flag VARCHAR2(1);
v_request_id NUMBER;
v_object_type_code VARCHAR2(30);
v_restart VARCHAR2(1);
v_normal_run VARCHAR2(1);
v_rerun VARCHAR2(1);
l_api_name  CONSTANT VARCHAR2(30) := 'obj_execution_lock_exists';

BEGIN

   fem_engines_pkg.tech_message(p_severity => c_log_level_1,
   p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
   p_msg_text => 'Begin.   P_OBJECT_ID:'||p_object_id||
    ' P_LEDGER_ID:'||p_ledger_id||' P_CAL_PERIOD_ID:'||p_cal_period_id||
    ' P_OUTPUT_DATASET_CODE:'||p_output_dataset_code||
    ' P_DIMENSION_ID:'||p_dimension_id||' P_TABLE_NAME:'||p_table_name||
    ' P_HIERARCHY_NAME:'||p_hierarchy_name||' P_EXEC_MODE_CODE:'||p_exec_mode_code||
    ' P_CALLING_CONTEXT:'||p_calling_context);

   x_msg_count := 0;
   x_exec_state := NULL;
   x_prev_request_id := NULL;

   -- Check for approval edit lock
   obj_def_approval_lock_exists(p_exec_object_definition_id, v_approval_edit_lock_exists);

   -- Retrieve object type code and check to see if the object
   -- type is executable locked.
   SELECT t.executable_lock_flag, o.object_type_code
      INTO v_executable_lock_flag, v_object_type_code
      FROM fem_object_types t, fem_object_catalog_b o
      WHERE o.object_id = p_object_id
      AND o.object_type_code = t.object_type_code;

   IF v_approval_edit_lock_exists = 'T' THEN
      x_exec_lock_exists := 'T';
      fem_engines_pkg.put_message(p_app_name =>'FEM',p_msg_name =>'FEM_PL_SUBMITTED_DEF_ERR',
      p_token1 => 'OBJECT_DEFINITION_ID', p_value1 => p_exec_object_definition_id, p_trans1 => 'N');

   ELSIF v_object_type_code IN ('OGL_INTG_BAL_RULE','XGL_INTEGRATION',
                                'SOURCE_DATA_LOADER','EGL_INTG_BAL_RULE') THEN

      -- call specialized procedure.
      fem_pl_incr_pkg.exec_lock_exists(
      p_calling_context => p_calling_context,
      p_object_id => p_object_id,
      p_obj_def_id => p_exec_object_definition_id,
      p_cal_period_id => p_cal_period_id,
      p_ledger_id => p_ledger_id,
      p_dataset_code => p_output_dataset_code,
      p_source_system_code => p_source_system_code,
      p_table_name => p_table_name,
      p_exec_mode => p_exec_mode_code,
      x_exec_lock_exists => x_exec_lock_exists,
      x_exec_state => x_exec_state,
      x_prev_request_id => x_prev_request_id,
      x_num_msg => x_msg_count);

   ELSIF v_object_type_code IN ('DIM_MEMBER_LOADER',
                                'OGL_INTG_DIM_RULE',
                                'OGL_INTG_CAL_RULE',
                                'EGL_INTG_DIM_RULE',
                                'EGL_INTG_CAL_RULE',
                                'UNDO',
                                'REFRESH_ENGINE',
                                'DIM_MEMBER_MIGRATION',
                                'HIERARCHY_MIGRATION') THEN

     -- call specialized procedure. (This procedure checks to make
     -- sure that the same OBJECT_ID is not executed while an execution
     -- of that same OBJECT_ID is in progress.  It does not check any other
     -- parameters.)
      dim_mbr_ldr_exec_lock_exists(p_object_id => p_object_id,
      p_exec_object_definition_id => p_exec_object_definition_id,
      p_calling_context => p_calling_context,
      x_exec_state => x_exec_state,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data,
      x_exec_lock_exists => x_exec_lock_exists,
      x_prev_request_id => x_prev_request_id);

   ELSIF v_object_type_code = 'DATAX_LOADER' THEN

     -- call specialized procedure.
      datax_ldr_exec_lock_exists(p_object_id => p_object_id,
      p_exec_object_definition_id => p_exec_object_definition_id,
      p_ledger_id => p_ledger_id,
      p_cal_period_id => p_cal_period_id,
      p_output_dataset_code => p_output_dataset_code,
      p_source_system_code => p_source_system_code,
      p_table_name => p_table_name,
      p_calling_context => p_calling_context,
      x_exec_state => x_exec_state,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data,
      x_exec_lock_exists => x_exec_lock_exists,
      x_prev_request_id => x_prev_request_id);

   ELSIF v_object_type_code in ('HIERARCHY_LOADER','OGL_INTG_HIER_RULE',
                                'EGL_INTG_HIER_RULE') THEN

     -- call specialized procedure.
      hier_ldr_exec_lock_exists(p_object_id => p_object_id,
      p_exec_object_definition_id => p_exec_object_definition_id,
      p_hierarchy_name => p_hierarchy_name,
      p_calling_context => p_calling_context,
      x_exec_state => x_exec_state,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data,
      x_exec_lock_exists => x_exec_lock_exists,
      x_prev_request_id => x_prev_request_id);

   ELSIF v_object_type_code in ('RCM_PROCESS_RULE','TP_PROCESS_RULE') THEN

     -- call specialized procedure.
      rcm_proc_exec_lock_exists(p_object_id => p_object_id,
      p_exec_object_definition_id => p_exec_object_definition_id,
      p_ledger_id => p_ledger_id,
      p_cal_period_id => p_cal_period_id,
      p_output_dataset_code => p_output_dataset_code,
      p_calling_context => p_calling_context,
      x_exec_state => x_exec_state,
      x_prev_request_id => x_prev_request_id,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data,
      x_exec_lock_exists => x_exec_lock_exists);

   ELSIF (v_object_type_code = 'MAPPING_PREVIEW') THEN

     -- call specialized procedure.
      preview_exec_lock_exists(
         p_object_id => p_object_id,
         p_exec_object_definition_id => p_exec_object_definition_id,
         p_calling_context => p_calling_context,
         x_exec_state => x_exec_state,
         x_prev_request_id => x_prev_request_id,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         x_exec_lock_exists => x_exec_lock_exists);

   ELSIF v_executable_lock_flag = 'Y' THEN

     -- call specialized procedure for mapping rules.  This is for mapping
     -- rules, and is the default for all other rules that are execution
     -- locked, but do not have specialized procedures.

      mapping_exec_lock_exists(p_object_id => p_object_id,
      p_exec_object_definition_id => p_exec_object_definition_id,
      p_ledger_id => p_ledger_id,
      p_cal_period_id => p_cal_period_id,
      p_output_dataset_code => p_output_dataset_code,
      p_calling_context => p_calling_context,
      x_exec_state => x_exec_state,
      x_prev_request_id => x_prev_request_id,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data,
      x_exec_lock_exists => x_exec_lock_exists);

   ELSE
      -- This is for objects which are not execution locked i.e.
      -- v_executable_lock_flag = 'N'

      v_request_id := FND_GLOBAL.CONC_REQUEST_ID;

      -- If this object execution is already registered and is currently running,
      -- then it is a restart, else it is a normal run.
      SELECT DECODE(COUNT(*),1,'RESTART','NORMAL') INTO x_exec_state
         FROM fem_pl_object_executions o, fem_pl_requests r
         WHERE r.request_id = v_request_id
         AND r.request_id = o.request_id
         AND o.object_id = p_object_id
         AND o.exec_status_code = 'RUNNING';

      x_exec_lock_exists := 'F';

   END IF;

    fem_engines_pkg.tech_message(p_severity => c_log_level_1,
    p_module => 'fem.plsql.'||g_pkg_name||'.obj_execution_lock_exists',
    p_msg_text => 'End.  Object execution lock exists:'||x_exec_lock_exists||
    '; Execution state:'||x_exec_state||' X_PREV_REQUEST_ID:'||x_prev_request_id);

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
      (p_count => x_msg_count,
       p_data => x_msg_data);

END  obj_execution_lock_exists;
-- ******************************************************************************
PROCEDURE register_object_execution  (p_api_version          IN  NUMBER,
                                      p_commit               IN  VARCHAR2 := FND_API.G_FALSE,
                                      p_request_id           IN  NUMBER,
                                      p_object_id            IN  NUMBER,
                                      p_exec_object_definition_id IN NUMBER,
                                      p_user_id              IN NUMBER,
                                      p_last_update_login    IN NUMBER,
                                      p_exec_mode_code       IN  VARCHAR2 DEFAULT NULL,
                                      x_exec_state           OUT NOCOPY VARCHAR2,
                                      x_prev_request_id      OUT NOCOPY NUMBER,
                                      x_msg_count            OUT NOCOPY NUMBER,
                                      x_msg_data             OUT NOCOPY VARCHAR2,
                                      x_return_status        OUT NOCOPY VARCHAR2) IS
-- ==========================================================================
--  NOTE: The p_commit flag is currently ignored to ensure that the
--        exclusive lock on FEM_PL_OBJECT_EXECUTIONS is always released at
--        the end of the procedure.  Bug# 3981986
-- ==========================================================================
--  x_return_status returns: S=successful, E=error, U=unexpected error.
-- ==========================================================================
--BEGIN register_object_execution
--   Acquire table lock (Wait until lock available)
--   IF execution lock exists THEN
--      Rollback to release exclusive table lock.
--         post message CANNOT_EXECUTE_LOCKED_OBJ;
--         set x_return_status = E;
--   ELSE
--      Insert object execution data in FEM_PL_OBJECT_EXECUTIONS.
--      IF object is a GL incremental load, RCM_PROCESS_RULE, or TP_PROCESS_RULE THEN
--         Set FEM_PL_OBJECT_EXECUTIONS.DISPLAY_FLAG = N for previous executions.
--      END IF;
--      Register executed object definition in FEM_PL_OBJECT_DEFS.
--      IF cannot register object definition, rollback and return an error status ELSE
--      Issue a commit to release exclusive table lock. END IF;
--   END IF;
--   EXCEPTION
--      Rollback to release exclusive table lock.
--      WHEN DUP_VAL_ON_INDEX THEN (This happens in a restart)
--      x_return_status := 1;
--END register_object_execution
-- ==========================================================================
v_obj_execution_lock_exists  VARCHAR2(1);
v_ledger_id NUMBER;
v_cal_period_id NUMBER;
v_output_dataset_code NUMBER;
v_source_system_code NUMBER;
v_table_name VARCHAR2(30);
v_exec_mode_code VARCHAR2(30);
v_dimension_id NUMBER;
v_hierarchy_name VARCHAR2(150);
l_api_name  CONSTANT VARCHAR2(30) := 'register_object_execution';
l_api_version  CONSTANT NUMBER := 1.0;
v_undo_flag VARCHAR2(1);
v_object_type_code  FEM_OBJECT_TYPES.object_type_code%TYPE;
v_display_flag VARCHAR2(1);

-- This cursor retrieves all previous executions of an
-- object that has the same parameters as the current
-- execution.
CURSOR c1 IS
   SELECT r.request_id
      FROM fem_pl_requests r, fem_pl_object_executions pl
      WHERE pl.object_id = p_object_id
      AND pl.request_id = r.request_id
      AND r.ledger_id = v_ledger_id
      AND r.cal_period_Id = v_cal_period_id
      AND r.output_dataset_code = v_output_dataset_code
      AND r.source_system_code = v_source_system_code
      AND r.dimension_id = v_dimension_id
      AND r.table_name = v_table_name
      AND r.hierarchy_name = v_hierarchy_name;

BEGIN

    fem_engines_pkg.tech_message(p_severity => c_log_level_1,
    p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
    p_msg_text => 'Begin.  P_USER_ID:'||p_user_id||
    ' P_REQUEST_ID:'||p_request_id||' P_OBJECT_ID:'||p_object_id||
    ' P_EXEC_OBJECT_DEFINITION_ID:'||p_exec_object_definition_id);

    -- Standard Start of API savepoint
    SAVEPOINT  register_object_execution_pub;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                  p_api_version,
                  l_api_name,
                  g_pkg_name)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;

    -- Retrieve request's parameters
    SELECT ledger_id, cal_period_id, output_dataset_code, source_system_code,
       dimension_id, table_Name, exec_mode_code, hierarchy_name INTO
       v_ledger_id, v_cal_period_id, v_output_dataset_code,
       v_source_system_code, v_dimension_id, v_table_Name,
       v_exec_mode_code, v_hierarchy_name
       FROM fem_pl_requests
       WHERE request_id = p_request_id;

    -- Retrieve undo_flag
    SELECT undo_flag INTO v_undo_flag
       FROM fem_object_catalog_b o, fem_object_types t
       WHERE o.object_id = p_object_id
       AND o.object_type_code = t.object_type_code;

    -- Acquire table lock
    LOCK TABLE fem_pl_object_executions IN EXCLUSIVE MODE;

    fem_engines_pkg.tech_message(p_severity => c_log_level_1,
    p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
    p_msg_text => 'Table FEM_PL_OBJECT_EXECUTIONS locked in exclusive mode.');

    obj_execution_lock_exists (
    p_object_id => p_object_id,
    p_exec_object_definition_id => p_exec_object_definition_id,
    p_ledger_id => v_ledger_id,
    p_cal_period_id => v_cal_period_id,
    p_output_dataset_code => v_output_dataset_code,
    p_source_system_code => v_source_system_code,
    p_dimension_id => v_dimension_id,
    p_table_name => v_table_name,
    p_hierarchy_name => v_hierarchy_name,
    p_exec_mode_code => v_exec_mode_code,
    x_exec_state => x_exec_state,
    x_prev_request_id => x_prev_request_id,
    x_msg_count => x_msg_count,
    x_msg_data => x_msg_data,
    x_exec_lock_exists => v_obj_execution_lock_exists);

    IF v_obj_execution_lock_exists = 'T' THEN

       ROLLBACK TO register_object_execution_pub;

       fem_engines_pkg.put_message(p_app_name =>'FEM',
       p_msg_name =>'FEM_PL_OBJ_EXECLOCK_EXISTS_ERR');

       fem_engines_pkg.tech_message(p_severity => c_log_level_4,
       p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
       p_msg_name =>'FEM_PL_OBJ_EXECLOCK_EXISTS_ERR');

       fem_engines_pkg.tech_message(p_severity => c_log_level_1,
       p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
       p_msg_text => 'Released exclusive lock on FEM_PL_OBJECT_EXECUTIONS .');

       x_return_status := g_ret_sts_error;

    ELSE
       -- Determine object type code for the object
       SELECT object_type_code
       INTO v_object_type_code
       FROM fem_object_catalog_b
       WHERE object_id = p_object_id;

       -- If no locks exist register object execution.

       -- Set the display flag to 'N' for all previous
       -- rules of the following types OGL_INTG_BAL_RULE, XGL_INTEGRATION,
       -- RCM_PROCESS_RULE, TP_PROCESS_RULE, EGL_INTG_BAL_RULE
       -- that have the same OBJECT_ID, LEDGER_ID, CAL_PERIOD_ID and
       -- OUTPUT_DATASET_CODE as the current object execution.
       IF v_object_type_code IN ('RCM_PROCESS_RULE','OGL_INTG_BAL_RULE',
                                 'TP_PROCESS_RULE','EGL_INTG_BAL_RULE') THEN
          UPDATE fem_pl_object_executions SET display_flag = 'N'
          WHERE object_id = p_object_id
          AND display_flag = 'Y'
          AND request_id IN
             (SELECT r.request_id FROM fem_pl_requests r, fem_pl_requests a
                WHERE a.request_id = p_request_id
                AND r.request_id <> p_request_id
                AND a.cal_period_id = r.cal_period_id
                AND a.ledger_id = r.ledger_id
                AND a.output_dataset_code = r.output_dataset_code);
       -- Also set the display flag to 'N' for all previous executions
       -- of the same rule so only the latest execution is displayed
       -- in the Undo UI.
       ELSIF v_object_type_code IN ('OGL_INTG_CAL_RULE','OGL_INTG_DIM_RULE',
                                    'OGL_INTG_HIER_RULE',
                                    'EGL_INTG_CAL_RULE','EGL_INTG_DIM_RULE',
                                    'EGL_INTG_HIER_RULE') THEN
          UPDATE fem_pl_object_executions SET display_flag = 'N'
          WHERE object_id = p_object_id
          AND request_id <> p_request_id;
       END IF;

       -- Bug 4379913: For XGL, OGL Bal, DataX and Client loader executions,
       -- default display to N and set it to yes only if the execution
       -- produces output rows (to be set in
       -- the update_num_of_output_rows procecure).
       IF v_object_type_code IN ('SOURCE_DATA_LOADER','DATAX_LOADER',
                                 'XGL_INTEGRATION') THEN
         v_display_flag := 'N';
       ELSE
         v_display_flag := 'Y';
       END IF;

       -- Register object execution
       INSERT INTO fem_pl_object_executions (request_id, object_id,
         exec_object_definition_id, event_order, display_flag, exec_status_code,
         created_by, creation_date, last_updated_by, last_update_date, last_update_login)
       VALUES (p_request_id, p_object_id, p_exec_object_definition_id,
         fem_event_order_seq.NEXTVAL, v_display_flag,'RUNNING',p_user_id, SYSDATE,
         p_user_id, SYSDATE, p_last_update_login);

       -- Register definition of executed object
       register_object_def(
         p_api_version            => 1.0,
         p_commit                 => FND_API.G_FALSE,
         p_request_id             => p_request_id,
         p_object_id              => p_object_id,
         p_object_definition_id   => p_exec_object_definition_id,
         p_user_id                => p_user_id,
         p_last_update_login      => p_last_update_login,
         x_msg_count              => x_msg_count,
         x_msg_data               => x_msg_data,
         x_return_status          => x_return_status);

       IF x_return_status = g_ret_sts_success THEN
          COMMIT WORK;
          fem_engines_pkg.tech_message(p_severity => c_log_level_3,
          p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
          p_msg_text => 'Registered object execution. REQUEST_ID:'||p_request_id||' OBJECT_ID:'||p_object_id);

          fem_engines_pkg.tech_message(p_severity => c_log_level_1,
          p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
          p_msg_text => 'Released exclusive lock on FEM_PL_OBJECT_EXECUTIONS.');

       ELSE
       -- If cannot acquire an edit lock for the object, then rollback and return a failure status.

          ROLLBACK TO register_object_execution_pub;
          FEM_ENGINES_PKG.user_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_PL_REG_OBJ_DEF_ERR');

          fem_engines_pkg.tech_message(p_severity => c_log_level_5,
          p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
          p_msg_name =>'FEM_PL_REG_OBJ_DEF_ERR');

          fem_engines_pkg.tech_message(p_severity => c_log_level_1,
          p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
          p_msg_text => 'Released exclusive lock on FEM_PL_OBJECT_EXECUTIONS.');

          x_return_status := g_ret_sts_error;

       END IF;

    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
      (p_count => x_msg_count,
       p_data  => x_msg_data);

    fem_engines_pkg.tech_message(p_severity => c_log_level_1,
    p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
    p_msg_text => 'End.  X_RETURN_STATUS:'||x_return_status);

    EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         ROLLBACK TO register_object_execution_pub;
         fem_engines_pkg.tech_message(p_severity => c_log_level_1,
         p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
         p_msg_text => 'Released exclusive lock on FEM_PL_OBJECT_EXECUTIONS .');

         fem_engines_pkg.tech_message(p_severity => c_log_level_3,
         p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
         p_msg_text => 'End.  Object execution already registered. X_RETURN_STATUS:'||x_return_status);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO register_object_execution_pub;
         x_return_status := g_ret_sts_unexp_error;

         fem_engines_pkg.tech_message(p_severity => c_log_level_1,
         p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
         p_msg_text => 'Released exclusive lock on FEM_PL_OBJECT_EXECUTIONS.');

         fem_engines_pkg.tech_message(p_severity => c_log_level_6,
         p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
         p_msg_text => 'Incompatible API call made to '||g_pkg_name||'.'||
         l_api_name||' version: '||l_api_version);

         FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data);

      WHEN OTHERS THEN
      -- Unexpected exceptions
         ROLLBACK TO register_object_execution_pub;
         x_return_status := g_ret_sts_unexp_error;

         fem_engines_pkg.tech_message(p_severity => c_log_level_1,
         p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
         p_msg_text => 'Released exclusive lock on FEM_PL_OBJECT_EXECUTIONS.');

      -- Log the call stack and the Oracle error message to
      -- FND_LOG with the "unexpected exception" severity level.

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => c_log_level_6,
            p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
            p_msg_text => SQLERRM);

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => c_log_level_6,
            p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
            p_msg_text => dbms_utility.format_call_stack);

      -- Log the Oracle error message to the stack.
         FEM_ENGINES_PKG.put_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UNEXPECTED_ERROR',
            P_TOKEN1 => 'ERR_MSG',
            P_VALUE1 => SQLERRM);

         FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data);

END  register_object_execution;
-- ******************************************************************************
   PROCEDURE register_request     (p_api_version            IN  NUMBER,
                                   p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
                                   p_cal_period_id          IN  NUMBER DEFAULT NULL,
                                   p_ledger_id              IN  NUMBER DEFAULT NULL,
                                   p_dataset_io_obj_def_id  IN  NUMBER DEFAULT NULL,
                                   p_output_dataset_code    IN  NUMBER DEFAULT NULL,
                                   p_source_system_code     IN  NUMBER DEFAULT NULL,
                                   p_effective_date         IN  DATE DEFAULT NULL,
                                   p_rule_set_obj_def_id    IN  NUMBER DEFAULT NULL,
                                   p_rule_set_name          IN  VARCHAR2 DEFAULT NULL,
                                   p_request_id             IN  NUMBER,
                                   p_user_id                IN  NUMBER,
                                   p_last_update_login      IN  NUMBER,
                                   p_program_id             IN  NUMBER,
                                   p_program_login_id       IN  NUMBER,
                                   p_program_application_id IN  NUMBER,
                                   p_exec_mode_code         IN  VARCHAR2 DEFAULT NULL,
                                   p_dimension_id           IN  NUMBER DEFAULT NULL,
                                   p_table_name             IN  VARCHAR2 DEFAULT NULL,
                                   p_hierarchy_name         IN  VARCHAR2 DEFAULT NULL,
                                   x_msg_count              OUT NOCOPY NUMBER,
                                   x_msg_data               OUT NOCOPY VARCHAR2,
                                   x_return_status          OUT NOCOPY VARCHAR2) IS
-- ==========================================================================
-- x_return_status returns: S=successful, E=error, U=unexpected error.
-- ==========================================================================
--BEGIN register request
--   Insert row into FEM_PL_REQUESTS.
--   IF request already exists in fem_pl_requests THEN
--      Set p_request_id = existing request ID;
--    END IF;
--END register_request
-- ==========================================================================

l_api_name     CONSTANT VARCHAR2(30) := 'register_request';
l_api_version  CONSTANT NUMBER := 1.0;

BEGIN

   fem_engines_pkg.tech_message(p_severity => c_log_level_1,
   p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
   p_msg_text => 'Begin. REQUEST_ID:'||p_request_id||
   ' P_RULE_SET_OBJ_DEF_ID:'||p_rule_set_obj_def_id||
   ' P_RULE_SET_NAME:'||p_rule_set_name||
   ' P_EFFECTIVE_DATE:'||fnd_date.date_to_displaydate(p_effective_date)||
   ' P_SOURCE_SYSTEM_CODE:'||p_source_system_code||
   ' P_LEDGER_ID:'||p_ledger_id||' P_CAL_PERIOD_ID:'||p_cal_period_id||
   ' P_DATASET_IO_OBJ_DEF_ID:'||p_dataset_io_obj_def_id||
   ' P_OUTPUT_DATASET_CODE:'||p_output_dataset_code||
   ' P_DIMENSION_ID:'||p_dimension_id||' P_TABLE_NAME:'||p_table_name||
   ' P_HIERARCHY_NAME:'||p_hierarchy_name||' P_EXEC_MODE_CODE:'||p_exec_mode_code);

   -- Standard Start of API savepoint
    SAVEPOINT  register_request_pub;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                  p_api_version,
                  l_api_name,
                  g_pkg_name)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;

   INSERT INTO fem_pl_requests (request_id, exec_status_code,
      created_by, creation_date, last_updated_by, last_update_date,
      last_update_login, program_id, program_login_id,
      program_application_id, rule_set_obj_def_id, rule_set_name,
      effective_date, cal_period_id, ledger_id, dataset_io_obj_def_id,
      output_dataset_code, source_system_code,exec_mode_code, dimension_id,
      table_name, hierarchy_name)
      VALUES (p_request_id, 'RUNNING',
      p_user_id, sysdate, p_user_id, sysdate,
      p_last_update_login, p_program_id, p_program_login_id,
      p_program_application_id, p_rule_set_obj_def_id, p_rule_set_name,
      p_effective_date, p_cal_period_id, p_ledger_id, p_dataset_io_obj_def_id,
      p_output_dataset_code, p_source_system_code,p_exec_mode_code, p_dimension_id,
      p_table_name, p_hierarchy_name);

   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   fem_engines_pkg.tech_message(p_severity => c_log_level_1,
   p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
   p_msg_text => 'End.  Registered request. X_RETURN_STATUS:'||x_return_status);

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
      (p_count => x_msg_count,
       p_data  => x_msg_data);

   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;

         IF FND_API.To_Boolean( p_commit ) THEN
            COMMIT WORK;
         ELSE
            ROLLBACK TO register_request_pub;
         END IF;

         fem_engines_pkg.tech_message(p_severity => c_log_level_3,
         p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
         p_msg_text => 'End. Request already registered. X_RETURN_STATUS:'||x_return_status);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO register_request_pub;
         x_return_status := g_ret_sts_unexp_error;

         fem_engines_pkg.tech_message(p_severity => c_log_level_2,
         p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
         p_msg_text => 'Incompatible API call made to '||g_pkg_name||'.'||
         l_api_name||' version: '||l_api_version);

         FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data  => x_msg_data);

END register_request;
-- ******************************************************************************
   PROCEDURE unregister_request            (p_api_version            IN  NUMBER,
                                            p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
                                            p_request_id             IN  NUMBER,
                                            x_msg_count              OUT NOCOPY NUMBER,
                                            x_msg_data               OUT NOCOPY VARCHAR2,
                                            x_return_status          OUT NOCOPY VARCHAR2) IS
-- ==========================================================================
-- x_return_status returns: S=successful, E=error, U=unexpected error.
-- ==========================================================================
-- BEGIN unregister request
-- If any data is found for the request in FEM_PL_OBJECT_EXECUTIONS THEN
--    x_return_status = E;
-- ELSE
--    Delete FEM_PL_REQUESTS where request_id = p_request_id;
--    x_return_status = S;
-- END unregister request
-- ==========================================================================
v_count NUMBER;
l_api_name  CONSTANT VARCHAR2(30) := 'unregister_request';
l_api_version  CONSTANT NUMBER := 1.0;

BEGIN

   fem_engines_pkg.tech_message(p_severity => c_log_level_1,
   p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
   p_msg_text => 'Begin. REQUEST_ID: '||p_request_id||
   ' P_COMMIT:'||p_commit);

   -- Standard Start of API savepoint
    SAVEPOINT  unregister_request_pub;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                  p_api_version,
                  l_api_name,
                  g_pkg_name)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;

   SELECT count(*) INTO v_count
      FROM fem_pl_object_executions
      WHERE request_id = p_request_id;

   IF v_count = 0 THEN
      DELETE fem_pl_requests WHERE request_id = p_request_id;
   ELSE
      fem_engines_pkg.tech_message(p_severity => c_log_level_3,
      p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
      p_msg_text => 'Cannot unregister REQUEST_ID: '||p_request_id||
      ' Data exists for request in FEM_PL_OBJECT_EXECUTIONS');

      x_return_status := G_RET_STS_ERROR;

   END IF;

   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   fem_engines_pkg.tech_message(p_severity => c_log_level_1,
   p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
   p_msg_text => 'End. X_RETURN_STATUS: '||x_return_status);

   EXCEPTION
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO unregister_request_pub;
         x_return_status := g_ret_sts_unexp_error;

          fem_engines_pkg.tech_message(p_severity => c_log_level_2,
          p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
          p_msg_text => 'Incompatible API call made to '||g_pkg_name||'.'||
          l_api_name||' version: '||l_api_version);

END unregister_request;
-- ******************************************************************************
PROCEDURE update_request_status      (p_api_version            IN  NUMBER,
                                      p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
                                      p_request_id             IN  NUMBER,
                                      p_exec_status_code       IN  VARCHAR2,
                                      p_user_id                IN  NUMBER,
                                      p_last_update_login      IN  NUMBER,
                                      x_msg_count              OUT NOCOPY NUMBER,
                                      x_msg_data               OUT NOCOPY VARCHAR2,
                                      x_return_status          OUT NOCOPY VARCHAR2) IS

l_api_name  CONSTANT VARCHAR2(30) := 'update_request_status';
l_api_version  CONSTANT NUMBER := 1.0;

BEGIN

   fem_engines_pkg.tech_message(p_severity => c_log_level_1,
   p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
   p_msg_text => 'Begin. REQUEST_ID: '||p_request_id||
   ' P_COMMIT:'||p_commit||' P_EXEC_STATUS_CODE:'||p_exec_status_code);

   -- Standard Start of API savepoint
    SAVEPOINT  update_request_status_pub;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                  p_api_version,
                  l_api_name,
                  g_pkg_name)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;

   UPDATE fem_pl_requests SET exec_status_code = p_exec_status_code,
      last_updated_by = p_user_id, last_update_date = sysdate,
      last_update_login = p_last_update_login
      WHERE request_id = p_request_id;

   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   fem_engines_pkg.tech_message(p_severity => c_log_level_1,
   p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
   p_msg_text => 'End. X_RETURN_STATUS: '||x_return_status);

   EXCEPTION
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO update_request_status_pub;
         x_return_status := g_ret_sts_unexp_error;

          fem_engines_pkg.tech_message(p_severity => c_log_level_2,
          p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
          p_msg_text => 'Incompatible API call made to '||g_pkg_name||'.'||
          l_api_name||' version: '||l_api_version);

END update_request_status;
-- ******************************************************************************
PROCEDURE update_obj_exec_status  (p_api_version            IN  NUMBER,
                                   p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
                                   p_request_id             IN  NUMBER,
                                   p_object_id              IN  NUMBER,
                                   p_exec_status_code       IN  VARCHAR2,
                                   p_user_id                IN  NUMBER,
                                   p_last_update_login      IN  NUMBER,
                                   x_msg_count              OUT NOCOPY NUMBER,
                                   x_msg_data               OUT NOCOPY VARCHAR2,
                                   x_return_status          OUT NOCOPY VARCHAR2) IS

l_api_name  CONSTANT VARCHAR2(30) := 'update_obj_exec_status';
l_api_version  CONSTANT NUMBER := 1.0;

BEGIN

   fem_engines_pkg.tech_message(p_severity => c_log_level_1,
   p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
   p_msg_text => 'Begin. REQUEST_ID: '||p_request_id||
   ' P_OBJECT_ID:'||p_object_id||' P_COMMIT:'||p_commit||
   ' P_EXEC_STATUS_CODE:'||p_exec_status_code);

   -- Standard Start of API savepoint
    SAVEPOINT  update_obj_exec_status_pub;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                  p_api_version,
                  l_api_name,
                  g_pkg_name)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;

   UPDATE fem_pl_object_executions SET exec_status_code = p_exec_status_code,
      last_updated_by = p_user_id, last_update_date = sysdate,
      last_update_login = p_last_update_login
      WHERE request_id = p_request_id
        AND object_id = p_object_id;

   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   fem_engines_pkg.tech_message(p_severity => c_log_level_1,
   p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
   p_msg_text => 'End. X_RETURN_STATUS: '||x_return_status);

   EXCEPTION
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO update_obj_exec_status_pub;
         x_return_status := g_ret_sts_unexp_error;

          fem_engines_pkg.tech_message(p_severity => c_log_level_2,
          p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
          p_msg_text => 'Incompatible API call made to '||g_pkg_name||'.'||
          l_api_name||' version: '||l_api_version);

END update_obj_exec_status;
-- ******************************************************************************
PROCEDURE update_obj_exec_errors     (p_api_version            IN  NUMBER,
                                      p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
                                      p_request_id             IN  NUMBER,
                                      p_object_id              IN  NUMBER,
                                      p_errors_reported        IN  NUMBER,
                                      p_errors_reprocessed     IN  NUMBER,
                                      p_user_id                IN  NUMBER,
                                      p_last_update_login      IN  NUMBER,
                                      x_msg_count              OUT NOCOPY NUMBER,
                                      x_msg_data               OUT NOCOPY VARCHAR2,
                                      x_return_status          OUT NOCOPY VARCHAR2) IS

l_api_name  CONSTANT VARCHAR2(30) := 'update_obj_exec_errors';
l_api_version  CONSTANT NUMBER := 1.0;

BEGIN

   fem_engines_pkg.tech_message(p_severity => c_log_level_1,
   p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
   p_msg_text => 'Begin. REQUEST_ID: '||p_request_id||
   ' P_OBJECT_ID:'||p_object_id||' P_COMMIT:'||p_commit||
   ' P_ERRORS_REPORTED:'||p_errors_reported||
   ' P_ERRORS_REPROCESSED:'||p_errors_reprocessed);

   -- Standard Start of API savepoint
    SAVEPOINT  update_obj_exec_errors_pub;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                  p_api_version,
                  l_api_name,
                  g_pkg_name)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;

   UPDATE fem_pl_object_executions
      SET errors_reported = p_errors_reported,
      errors_reprocessed=p_errors_reprocessed,
      last_updated_by = p_user_id, last_update_date = sysdate,
      last_update_login = p_last_update_login
      WHERE request_id = p_request_id
        AND object_id = p_object_id;

   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   fem_engines_pkg.tech_message(p_severity => c_log_level_1,
   p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
   p_msg_text => 'End. X_RETURN_STATUS: '||x_return_status);

   EXCEPTION
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO update_obj_exec_errors_pub;
         x_return_status := g_ret_sts_unexp_error;

          fem_engines_pkg.tech_message(p_severity => c_log_level_2,
          p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
          p_msg_text => 'Incompatible API call made to '||g_pkg_name||'.'||
          l_api_name||' version: '||l_api_version);

END update_obj_exec_errors;
-- ******************************************************************************
PROCEDURE register_object_def  (p_api_version            IN  NUMBER,
                                p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
                                p_request_id             IN  NUMBER,
                                p_object_id              IN  NUMBER,
                                p_object_definition_id   IN  NUMBER,
                                p_user_id                IN  NUMBER,
                                p_last_update_login      IN  NUMBER,
                                x_msg_count              OUT NOCOPY NUMBER,
                                x_msg_data               OUT NOCOPY VARCHAR2,
                                x_return_status          OUT NOCOPY VARCHAR2) IS

l_api_name  CONSTANT VARCHAR2(30) := 'register_object_def';
l_api_version  CONSTANT NUMBER := 1.0;

BEGIN

   fem_engines_pkg.tech_message(p_severity => c_log_level_1,
   p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
   p_msg_text => 'Begin. REQUEST_ID: '||p_request_id||
   ' P_OBJECT_ID:'||p_object_id||' P_COMMIT:'||p_commit||
   ' P_OBJECT_DEFINITION_ID:'||p_object_definition_id);

   -- Standard Start of API savepoint
    SAVEPOINT  register_object_def_pub;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                  p_api_version,
                  l_api_name,
                  g_pkg_name)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;

   INSERT INTO fem_pl_object_defs (request_id, object_id, object_definition_id,
      created_by, creation_date, last_updated_by, last_update_date,
      last_update_login)
      SELECT
      request_id, object_id, p_object_definition_id,
      p_user_id, sysdate, p_user_id, sysdate,p_last_update_login
      FROM fem_pl_object_executions
      WHERE request_id = p_request_id
      AND object_id = p_object_id;

   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   fem_engines_pkg.tech_message(p_severity => c_log_level_1,
   p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
   p_msg_text => 'End. X_RETURN_STATUS: '||x_return_status);

   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
         IF FND_API.To_Boolean( p_commit ) THEN
            COMMIT WORK;
         ELSE
            ROLLBACK TO register_object_def_pub;
         END IF;
        fem_engines_pkg.tech_message(p_severity => c_log_level_3,
         p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
         p_msg_text => 'End. Object definition already registered. X_RETURN_STATUS: '||x_return_status);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO register_object_def_pub;
         x_return_status := g_ret_sts_unexp_error;

          fem_engines_pkg.tech_message(p_severity => c_log_level_2,
          p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
          p_msg_text => 'Incompatible API call made to '||g_pkg_name||'.'||
          l_api_name||' version: '||l_api_version);

END  register_object_def;
-- ******************************************************************************
PROCEDURE register_dependent_objdefs (p_api_version            IN  NUMBER,
                                      p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
                                      p_request_id             IN  NUMBER,
                                      p_object_id              IN  NUMBER,
                                      p_exec_object_definition_id IN NUMBER,
                                      p_effective_date         IN  DATE,
                                      p_user_id                IN  NUMBER,
                                      p_last_update_login      IN  NUMBER,
                                      x_msg_count              OUT NOCOPY NUMBER,
                                      x_msg_data               OUT NOCOPY VARCHAR2,
                                      x_return_status          OUT NOCOPY VARCHAR2) IS

l_api_name  CONSTANT VARCHAR2(30) := 'register_dependent_objdefs';
l_api_version  CONSTANT NUMBER := 1.0;
v_object_definition_id NUMBER(9);

------------------------------------------------------------------------
-- In order to retrieve a hierarchical list of required objects,
-- no validation is performed.  The cursor that retrieves the required
-- objects will not determine if a required object is missing a valid
-- definition for the specified effective date.  It only retrieves the
-- required objects that DO have a valid definition for the given
-- effective date.
------------------------------------------------------------------------
CURSOR c1 IS
   SELECT D.required_object_id
   FROM fem_object_dependencies D,
        fem_object_definition_b B
   WHERE D.required_object_id = B.object_id
   AND B.effective_start_date <= p_effective_date
   AND B.effective_end_date >= p_effective_date
   AND B.old_approved_copy_flag = 'N'
   AND B.approval_status_code NOT IN ('SUBMIT_APPROVAL','SUBMIT_DELETE')
   START WITH D.object_definition_id = p_exec_object_definition_id
   CONNECT BY PRIOR B.object_definition_id = D.object_definition_id;

BEGIN

   fem_engines_pkg.tech_message(p_severity => c_log_level_1,
   p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
   p_msg_text => 'Begin. REQUEST_ID: '||p_request_id||
   ' P_OBJECT_ID:'||p_object_id||
   ' P_EFFECTIVE_DATE:'||fnd_date.date_to_displaydate(p_effective_date)||
   ' P_COMMIT:'||p_commit);

   -- Standard Start of API savepoint
    SAVEPOINT  register_dependent_objdefs_pub;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                  p_api_version,
                  l_api_name,
                  g_pkg_name)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;

   FOR a_dependent_objdef IN c1 LOOP
      SELECT object_definition_id INTO v_object_definition_id
      FROM fem_object_definition_b
      WHERE object_id = a_dependent_objdef.required_object_id
         AND effective_start_date <= p_effective_date
         AND effective_end_date >= p_effective_date
         AND old_approved_copy_flag = 'N'
         AND approval_status_code NOT IN ('SUBMIT_APPROVAL','SUBMIT_DELETE');

      register_object_def(
        p_api_version            => 1.0,
        p_commit                 => FND_API.G_FALSE,
        p_request_id             => p_request_id,
        p_object_id              => p_object_id,
        p_object_definition_id   => v_object_definition_id,
        p_user_id                => p_user_id,
        p_last_update_login      => p_last_update_login,
        x_msg_count              => x_msg_count,
        x_msg_data               => x_msg_data,
        x_return_status          => x_return_status);

     IF x_return_status <> g_ret_sts_success THEN
        EXIT;
     END IF;

   END LOOP;

   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   fem_engines_pkg.tech_message(p_severity => c_log_level_1,
   p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
   p_msg_text => 'End. X_RETURN_STATUS: '||x_return_status);

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         ROLLBACK TO register_dependent_objdefs_pub;
         x_return_status := g_ret_sts_error;
         fem_engines_pkg.tech_message(p_severity => c_log_level_5,
         p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
         p_msg_name => 'FEM_PL_NO_DEP_OBJ_DEF_ERR',
         p_token1 => 'OBJECT_ID',
         p_value1 => p_object_id,
         p_trans1 => 'N');

         fem_engines_pkg.put_message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_PL_NO_DEP_OBJ_DEF_ERR',
         p_token1 => 'OBJECT_ID',
         p_value1 => p_object_id,
         p_trans1 => 'N');

         FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data => x_msg_data);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO register_dependent_objdefs_pub;
         x_return_status := g_ret_sts_unexp_error;

          fem_engines_pkg.tech_message(p_severity => c_log_level_2,
          p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
          p_msg_text => 'Incompatible API call made to '||g_pkg_name||'.'||
          l_api_name||' version: '||l_api_version);

END  register_dependent_objdefs;
-- ******************************************************************************
PROCEDURE register_table (p_api_version            IN  NUMBER,
                          p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
                          p_request_id             IN  NUMBER,
                          p_object_id              IN  NUMBER,
                          p_table_name             IN  VARCHAR2,
                          p_statement_type         IN  VARCHAR2,
                          p_num_of_output_rows     IN  NUMBER,
                          p_user_id                IN  NUMBER,
                          p_last_update_login      IN  NUMBER,
                          x_msg_count              OUT NOCOPY NUMBER,
                          x_msg_data               OUT NOCOPY VARCHAR2,
                          x_return_status          OUT NOCOPY VARCHAR2) IS

l_api_name  CONSTANT VARCHAR2(30) := 'register_table';
l_api_version  CONSTANT NUMBER := 1.0;

BEGIN

   fem_engines_pkg.tech_message(p_severity => c_log_level_1,
   p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
   p_msg_text => 'Begin. REQUEST_ID: '||p_request_id||
   ' P_OBJECT_ID:'||p_object_id||' P_COMMIT:'||p_commit||
   ' P_TABLE_NAME:'||p_table_name||
   ' P_STATEMENT_TYPE:'||p_statement_type||
   ' P_NUM_OF_OUTPUT_ROWS:'||p_num_of_output_rows);

   -- Standard Start of API savepoint
    SAVEPOINT  register_table_pub;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                  p_api_version,
                  l_api_name,
                  g_pkg_name)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;
   INSERT INTO fem_pl_tables (request_id, object_id, table_name,
      statement_type, num_of_output_rows,
      created_by, creation_date, last_updated_by, last_update_date,
      last_update_login)
      SELECT
      request_id, object_id, p_table_name,
      p_statement_type, p_num_of_output_rows,
      p_user_id, sysdate, p_user_id, sysdate,p_last_update_login
      FROM fem_pl_object_executions
      WHERE request_id = p_request_id
      AND object_id = p_object_id;

   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   fem_engines_pkg.tech_message(p_severity => c_log_level_1,
   p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
   p_msg_text => 'End. X_RETURN_STATUS: '||x_return_status);

   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
         IF FND_API.To_Boolean( p_commit ) THEN
            COMMIT WORK;
         ELSE
            ROLLBACK TO register_table_pub;
         END IF;
        fem_engines_pkg.tech_message(p_severity => c_log_level_2,
         p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
         p_msg_text => 'End.  Table already registered. X_RETURN_STATUS: '||x_return_status);
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO register_table_pub;
         x_return_status := g_ret_sts_unexp_error;

          fem_engines_pkg.tech_message(p_severity => c_log_level_2,
          p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
          p_msg_text => 'Incompatible API call made to '||g_pkg_name||'.'||
          l_api_name||' version: '||l_api_version);

END  register_table;
-- ******************************************************************************
PROCEDURE update_num_of_output_rows  (p_api_version        IN  NUMBER,
                                      p_commit             IN  VARCHAR2 := FND_API.G_FALSE,
                                      p_request_id         IN  NUMBER,
                                      p_object_id          IN  NUMBER,
                                      p_table_name         IN  VARCHAR2,
                                      p_statement_type     IN  VARCHAR2,
                                      p_num_of_output_rows IN  NUMBER,
                                      p_user_id            IN  NUMBER,
                                      p_last_update_login  IN  NUMBER,
                                      x_msg_count          OUT NOCOPY NUMBER,
                                      x_msg_data           OUT NOCOPY VARCHAR2,
                                      x_return_status      OUT NOCOPY VARCHAR2) IS

l_api_name  CONSTANT VARCHAR2(30) := 'update_num_of_output_rows';
l_api_version  CONSTANT NUMBER := 1.0;

v_object_type_code  FEM_OBJECT_TYPES.object_type_code%TYPE;

BEGIN

   fem_engines_pkg.tech_message(p_severity => c_log_level_1,
   p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
   p_msg_text => 'Begin. REQUEST_ID: '||p_request_id||
   ' P_OBJECT_ID:'||p_object_id||' P_COMMIT:'||p_commit||
   ' P_TABLE_NAME:'||p_table_name||
   ' P_STATEMENT_TYPE:'||p_statement_type||
   ' P_NUM_OF_OUTPUT_ROWS:'||p_num_of_output_rows);

   -- Standard Start of API savepoint
    SAVEPOINT  update_num_of_output_rows_pub;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                  p_api_version,
                  l_api_name,
                  g_pkg_name)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize API return status to unexp error
   x_return_status := G_RET_STS_UNEXP_ERROR;

   UPDATE fem_pl_tables SET num_of_output_rows = p_num_of_output_rows,
      last_updated_by = p_user_id, last_update_date = sysdate,
      last_update_login = p_last_update_login
      WHERE request_id = p_request_id
         AND object_id = p_object_id
         AND table_name = p_table_name
         AND statement_type = p_statement_type;

   -- Bug 4379913, 4382591: For XGL, OGL, DataX and Client loader executions,
   -- set FEM_PL_OBJECT_EXECUTIONS.display_flag to Yes if the
   -- execution actually produced results (i.e. output rows > 0).
   -- Also make sure that earlier executions of the same rule with
   -- the same parameter combination have display_flag set to No.

   IF p_num_of_output_rows > 0 THEN

     -- Determine object type code for the object
     SELECT object_type_code
     INTO v_object_type_code
     FROM fem_object_catalog_b
     WHERE object_id = p_object_id;

     IF v_object_type_code IN ('XGL_INTEGRATION',
                               'SOURCE_DATA_LOADER','DATAX_LOADER') THEN
       UPDATE fem_pl_object_executions
       SET display_flag = 'Y'
       WHERE request_id = p_request_id
         AND object_id = p_object_id
         AND display_flag <> 'Y';

       -- Since this API is called per table and one object execution
       -- can insert/update multiple tables, only perform the following
       -- SQL once for each object execution.
       IF SQL%ROWCOUNT > 0 THEN
         -- For OGL/XGL, processing parameters only include ledger,
         -- cal period and dataset.  For DataX/Client loaders, the parameters
         -- also include source system.
         IF v_object_type_code = 'XGL_INTEGRATION' THEN
           UPDATE fem_pl_object_executions
           SET display_flag = 'N'
           WHERE object_id = p_object_id
           AND display_flag = 'Y'
           AND request_id IN
           (SELECT r1.request_id FROM fem_pl_requests r1, fem_pl_requests r2
            WHERE r2.request_id = p_request_id
             AND r1.request_id <> p_request_id
             AND r2.cal_period_id = r1.cal_period_id
             AND r2.ledger_id = r1.ledger_id
             AND r2.output_dataset_code = r1.output_dataset_code);
         ELSIF v_object_type_code IN ('SOURCE_DATA_LOADER','DATAX_LOADER') THEN
           UPDATE fem_pl_object_executions
           SET display_flag = 'N'
           WHERE object_id = p_object_id
           AND display_flag = 'Y'
           AND request_id IN
           (SELECT r1.request_id FROM fem_pl_requests r1, fem_pl_requests r2
            WHERE r2.request_id = p_request_id
             AND r1.request_id <> p_request_id
             AND r2.cal_period_id = r1.cal_period_id
             AND r2.ledger_id = r1.ledger_id
             AND r2.output_dataset_code = r1.output_dataset_code
             AND r2.source_system_code = r1.source_system_code);
         END IF; -- v_object_type_code
       END IF;  -- rowcount > 0
     END IF; -- v_object_type_code
   END IF; -- p_num_of_output_rows > 0

   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   -- Update API return status to success
   x_return_status := G_RET_STS_SUCCESS;

   fem_engines_pkg.tech_message(p_severity => c_log_level_1,
   p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
   p_msg_text => 'End. X_RETURN_STATUS: '||x_return_status);

   EXCEPTION
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO update_num_of_output_rows_pub;
         x_return_status := g_ret_sts_unexp_error;

          fem_engines_pkg.tech_message(p_severity => c_log_level_2,
          p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
          p_msg_text => 'Incompatible API call made to '||g_pkg_name||'.'||
          l_api_name||' version: '||l_api_version);

END  update_num_of_output_rows;
-- ******************************************************************************
PROCEDURE register_updated_column (p_api_version            IN  NUMBER,
                                   p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
                                   p_request_id             IN  NUMBER,
                                   p_object_id              IN  NUMBER,
                                   p_table_name             IN  VARCHAR2,
                                   p_statement_type         IN  VARCHAR2,
                                   p_column_name            IN  VARCHAR2,
                                   p_user_id                IN  NUMBER,
                                   p_last_update_login      IN  NUMBER,
                                   x_msg_count              OUT NOCOPY NUMBER,
                                   x_msg_data               OUT NOCOPY VARCHAR2,
                                   x_return_status          OUT NOCOPY VARCHAR2) IS

l_api_name  CONSTANT VARCHAR2(30) := 'register_updated_column';
l_api_version  CONSTANT NUMBER := 1.0;

BEGIN

   fem_engines_pkg.tech_message(p_severity => c_log_level_1,
   p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
   p_msg_text => 'Begin. REQUEST_ID: '||p_request_id||
   ' P_OBJECT_ID:'||p_object_id||' P_COMMIT:'||p_commit||
   ' P_TABLE_NAME:'||p_table_name||
   ' P_STATEMENT_TYPE:'||p_statement_type||
   ' P_COLUMN_NAME:'||p_column_name);

   -- Standard Start of API savepoint
    SAVEPOINT  register_updated_column_pub;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                  p_api_version,
                  l_api_name,
                  g_pkg_name)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;

   INSERT INTO fem_pl_tab_updated_cols (request_id, object_id, table_name,
      statement_type, column_name,
      created_by, creation_date, last_updated_by, last_update_date,
      last_update_login)
      SELECT
      request_id, object_id, table_name,
      statement_type, p_column_name,
      p_user_id, sysdate, p_user_id, sysdate,p_last_update_login
      FROM fem_pl_tables
      WHERE request_id = p_request_id
      AND object_id = p_object_id
      AND table_name = p_table_name
      AND statement_type = p_statement_type;

   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   fem_engines_pkg.tech_message(p_severity => c_log_level_1,
   p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
   p_msg_text => 'End. X_RETURN_STATUS:'||x_return_status);

   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
         IF FND_API.To_Boolean( p_commit ) THEN
            COMMIT WORK;
         ELSE
            ROLLBACK TO register_updated_column_pub;
         END IF;
         fem_engines_pkg.tech_message(p_severity => c_log_level_2,
         p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
         p_msg_text => 'End.  Updated column already registered. X_RETURN_STATUS:'||x_return_status);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO register_updated_column_pub;
         x_return_status := g_ret_sts_unexp_error;

          fem_engines_pkg.tech_message(p_severity => c_log_level_2,
          p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
          p_msg_text => 'Incompatible API call made to '||g_pkg_name||'.'||
          l_api_name||' version: '||l_api_version);

END  register_updated_column;
-- ******************************************************************************
PROCEDURE register_chain (p_api_version            IN  NUMBER,
                          p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
                          p_request_id             IN  NUMBER,
                          p_object_id              IN  NUMBER,
                          p_source_created_by_request_id  IN  NUMBER,
                          p_source_created_by_object_id   IN  NUMBER,
                          p_user_id                IN  NUMBER,
                          p_last_update_login      IN  NUMBER,
                          x_msg_count              OUT NOCOPY NUMBER,
                          x_msg_data               OUT NOCOPY VARCHAR2,
                          x_return_status          OUT NOCOPY VARCHAR2) IS

l_api_name  CONSTANT VARCHAR2(30) := 'register_chain';
l_api_version  CONSTANT NUMBER := 1.0;

BEGIN

   fem_engines_pkg.tech_message(p_severity => c_log_level_1,
   p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
   p_msg_text => 'Begin. REQUEST_ID: '||p_request_id||
   ' P_OBJECT_ID:'||p_object_id||' P_COMMIT:'||p_commit||
   ' P_SOURCE_CREATED_BY_REQUEST_ID:'||p_source_created_by_request_id||
   ' P_SOURCE_CREATED_BY_OBJECT_ID:'||p_source_created_by_object_id);

   -- Standard Start of API savepoint
    SAVEPOINT  register_chain_pub;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                  p_api_version,
                  l_api_name,
                  g_pkg_name)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;

   INSERT INTO fem_pl_chains (request_id, object_id,
      source_created_by_request_id, source_created_by_object_id,
      created_by, creation_date, last_updated_by, last_update_date,
      last_update_login)
      SELECT
      request_id, object_id,
      p_source_created_by_request_id, p_source_created_by_object_id,
      p_user_id, sysdate, p_user_id, sysdate,p_last_update_login
      FROM fem_pl_object_executions
      WHERE request_id = p_request_id
      AND object_id = p_object_id;

   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   fem_engines_pkg.tech_message(p_severity => c_log_level_1,
   p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
   p_msg_text => 'End. X_RETURN_STATUS:'||x_return_status);

   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;

         IF FND_API.To_Boolean( p_commit ) THEN
             COMMIT WORK;
         ELSE
             ROLLBACK TO register_chain_pub;
         END IF;
         fem_engines_pkg.tech_message(p_severity => c_log_level_2,
         p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
         p_msg_text => 'End. Processing chain already registered. X_RETURN_STATUS:'||x_return_status);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO register_chain_pub;
         x_return_status := g_ret_sts_unexp_error;

          fem_engines_pkg.tech_message(p_severity => c_log_level_2,
          p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
          p_msg_text => 'Incompatible API call made to '||g_pkg_name||'.'||
          l_api_name||' version: '||l_api_version);

END  register_chain;
-- ******************************************************************************
PROCEDURE register_temp_object (p_api_version            IN  NUMBER,
                                p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
                                p_request_id             IN  NUMBER,
                                p_object_id              IN  NUMBER,
                                p_object_type            IN  VARCHAR2,
                                p_object_name            IN  VARCHAR2,
                                p_user_id                IN  NUMBER,
                                p_last_update_login      IN  NUMBER,
                                x_msg_count              OUT NOCOPY NUMBER,
                                x_msg_data               OUT NOCOPY VARCHAR2,
                                x_return_status          OUT NOCOPY VARCHAR2) IS

l_api_name  CONSTANT VARCHAR2(30) := 'register_temp_object';
l_api_version  CONSTANT NUMBER := 1.0;

BEGIN

   fem_engines_pkg.tech_message(p_severity => c_log_level_1,
   p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
   p_msg_text => 'Begin. REQUEST_ID: '||p_request_id||
   ' P_OBJECT_ID:'||p_object_id||' P_COMMIT:'||p_commit||
   ' P_OBJECT_TYPE:'||p_object_type||
   ' P_OBJECT_NAME:'||p_object_name);

   -- Standard Start of API savepoint
    SAVEPOINT  register_temp_object_pub;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                  p_api_version,
                  l_api_name,
                  g_pkg_name)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;

   INSERT INTO fem_pl_temp_objects (request_id, object_id, object_type,
      object_name,
      created_by, creation_date, last_updated_by, last_update_date,
      last_update_login)
      SELECT
      request_id, object_id, p_object_type,p_object_name,
      p_user_id, sysdate, p_user_id, sysdate,p_last_update_login
      FROM fem_pl_object_executions
      WHERE request_id = p_request_id
      AND object_id = p_object_id;

   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   fem_engines_pkg.tech_message(p_severity => c_log_level_1,
   p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
   p_msg_text => 'End. X_RETURN_STATUS:'||x_return_status);

   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
         IF FND_API.To_Boolean( p_commit ) THEN
            COMMIT WORK;
         ELSE
            ROLLBACK TO register_temp_object_pub;
         END IF;

         fem_engines_pkg.tech_message(p_severity => c_log_level_2,
         p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
         p_msg_text => 'End.  Temporary object already registered. X_RETURN_STATUS:'||x_return_status);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO register_temp_object_pub;
         x_return_status := g_ret_sts_unexp_error;

          fem_engines_pkg.tech_message(p_severity => c_log_level_2,
          p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
          p_msg_text => 'Incompatible API call made to '||g_pkg_name||'.'||
          l_api_name||' version: '||l_api_version);

END  register_temp_object;
-- ******************************************************************************
PROCEDURE update_num_of_input_rows   (p_api_version            IN  NUMBER,
                                      p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
                                      p_request_id             IN  NUMBER,
                                      p_object_id              IN  NUMBER,
                                      p_num_of_input_rows      IN  NUMBER,
                                      p_user_id                IN  NUMBER,
                                      p_last_update_login      IN  NUMBER,
                                      x_msg_count              OUT NOCOPY NUMBER,
                                      x_msg_data               OUT NOCOPY VARCHAR2,
                                      x_return_status          OUT NOCOPY VARCHAR2) IS

l_api_name  CONSTANT VARCHAR2(30) := 'update_num_of_input_rows';
l_api_version  CONSTANT NUMBER := 1.0;

BEGIN

   fem_engines_pkg.tech_message(p_severity => c_log_level_1,
   p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
   p_msg_text => 'Begin. REQUEST_ID: '||p_request_id||
   ' P_OBJECT_ID:'||p_object_id||' P_COMMIT:'||p_commit||
   ' P_NUM_OF_INPUT_ROWS:'||p_num_of_input_rows);

   -- Standard Start of API savepoint
    SAVEPOINT  update_num_of_input_rows_pub;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                  p_api_version,
                  l_api_name,
                  g_pkg_name)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;

   UPDATE fem_pl_object_executions SET num_of_input_rows = p_num_of_input_rows,
      last_updated_by = p_user_id, last_update_date = sysdate,
      last_update_login = p_last_update_login
      WHERE request_id = p_request_id
         AND object_id = p_object_id;

   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   fem_engines_pkg.tech_message(p_severity => c_log_level_1,
   p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
   p_msg_text => 'End. X_RETURN_STATUS:'||x_return_status);

   EXCEPTION
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO update_num_of_input_rows_pub;
         x_return_status := g_ret_sts_unexp_error;

          fem_engines_pkg.tech_message(p_severity => c_log_level_2,
          p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
          p_msg_text => 'Incompatible API call made to '||g_pkg_name||'.'||
          l_api_name||' version: '||l_api_version);

END  update_num_of_input_rows;
-- ******************************************************************************
PROCEDURE register_obj_exec_step  (p_api_version            IN  NUMBER,
                                   p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
                                   p_request_id             IN  NUMBER,
                                   p_object_id              IN  NUMBER,
                                   p_exec_step              IN  VARCHAR2,
                                   p_exec_status_code       IN  VARCHAR2,
                                   p_user_id                IN  NUMBER,
                                   p_last_update_login      IN  NUMBER,
                                   x_msg_count              OUT NOCOPY NUMBER,
                                   x_msg_data               OUT NOCOPY VARCHAR2,
                                   x_return_status          OUT NOCOPY VARCHAR2) IS

l_api_name  CONSTANT VARCHAR2(30) := 'register_obj_exec_step';
l_api_version  CONSTANT NUMBER := 1.0;

BEGIN

   fem_engines_pkg.tech_message(p_severity => c_log_level_1,
   p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
   p_msg_text => 'Begin. REQUEST_ID: '||p_request_id||
   ' P_OBJECT_ID:'||p_object_id||' P_COMMIT:'||p_commit||
   ' P_EXEC_STEP:'||p_exec_step||
   ' P_EXEC_STATUS_CODE:'||p_exec_status_code);

   -- Standard Start of API savepoint
    SAVEPOINT  register_obj_exec_step_pub;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                  p_api_version,
                  l_api_name,
                  g_pkg_name)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;
   INSERT INTO fem_pl_obj_exec_steps (request_id, object_id, exec_step,
      exec_status_code, created_by, creation_date, last_updated_by,
      last_update_date, last_update_login)
      SELECT
      request_id, object_id, p_exec_step, p_exec_status_code,
      p_user_id, sysdate, p_user_id, sysdate, p_last_update_login
      FROM fem_pl_object_executions
      WHERE request_id = p_request_id
      AND object_id = p_object_id;

   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   fem_engines_pkg.tech_message(p_severity => c_log_level_1,
   p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
   p_msg_text => 'End. X_RETURN_STATUS:'||x_return_status);

   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN

         NULL;
         IF FND_API.To_Boolean( p_commit ) THEN
            COMMIT WORK;
         ELSE
            ROLLBACK TO register_obj_exec_step_pub;
         END IF;
         fem_engines_pkg.tech_message(p_severity => c_log_level_2,
         p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
         p_msg_text => 'End.  Object execution step already registered. X_RETURN_STATUS:'||x_return_status);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO register_obj_exec_step_pub;
         x_return_status := g_ret_sts_unexp_error;

          fem_engines_pkg.tech_message(p_severity => c_log_level_2,
          p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
          p_msg_text => 'Incompatible API call made to '||g_pkg_name||'.'||
          l_api_name||' version: '||l_api_version);

END  register_obj_exec_step;
-- ******************************************************************************
PROCEDURE unregister_obj_exec_step   (p_api_version            IN  NUMBER,
                                      p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
                                      p_request_id             IN  NUMBER,
                                      p_object_id              IN  NUMBER,
                                      p_exec_step              IN  VARCHAR2,
                                      x_msg_count              OUT NOCOPY NUMBER,
                                      x_msg_data               OUT NOCOPY VARCHAR2,
                                      x_return_status          OUT NOCOPY VARCHAR2) IS

l_api_name  CONSTANT VARCHAR2(30) := 'unregister_obj_exec_step';
l_api_version  CONSTANT NUMBER := 1.0;

BEGIN

   fem_engines_pkg.tech_message(p_severity => c_log_level_1,
   p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
   p_msg_text => 'Begin. REQUEST_ID: '||p_request_id||
   ' P_OBJECT_ID:'||p_object_id||' P_COMMIT:'||p_commit||
   ' P_EXEC_STEP:'||p_exec_step);

   -- Standard Start of API savepoint
    SAVEPOINT  unregister_obj_exec_step_pub;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                  p_api_version,
                  l_api_name,
                  g_pkg_name)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;

   DELETE fem_pl_obj_exec_steps
      WHERE request_id = p_request_id
        AND object_id = p_object_id
        AND exec_step = p_exec_step;

   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   fem_engines_pkg.tech_message(p_severity => c_log_level_1,
   p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
   p_msg_text => 'End. X_RETURN_STATUS:'||x_return_status);

   EXCEPTION
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO unregister_obj_exec_step_pub;
         x_return_status := g_ret_sts_unexp_error;

          fem_engines_pkg.tech_message(p_severity => c_log_level_2,
          p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
          p_msg_text => 'Incompatible API call made to '||g_pkg_name||'.'||
          l_api_name||' version: '||l_api_version);

END  unregister_obj_exec_step;
-- ******************************************************************************
PROCEDURE unregister_obj_exec_steps  (p_api_version            IN  NUMBER,
                                      p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
                                      p_request_id             IN  NUMBER,
                                      p_object_id              IN  NUMBER,
                                      x_msg_count              OUT NOCOPY NUMBER,
                                      x_msg_data               OUT NOCOPY VARCHAR2,
                                      x_return_status          OUT NOCOPY VARCHAR2)IS

l_api_name  CONSTANT VARCHAR2(30) := 'unregister_obj_exec_steps';
l_api_version  CONSTANT NUMBER := 1.0;

BEGIN

   fem_engines_pkg.tech_message(p_severity => c_log_level_1,
   p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
   p_msg_text => 'Begin. REQUEST_ID: '||p_request_id||
   ' P_OBJECT_ID:'||p_object_id||' P_COMMIT:'||p_commit);

   -- Standard Start of API savepoint
    SAVEPOINT  unregister_obj_exec_steps_pub;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                  p_api_version,
                  l_api_name,
                  g_pkg_name)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;

   DELETE fem_pl_obj_exec_steps
      WHERE request_id = p_request_id
        AND object_id = p_object_id;

   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   fem_engines_pkg.tech_message(p_severity => c_log_level_1,
   p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
   p_msg_text => 'End. X_RETURN_STATUS:'||x_return_status);

   EXCEPTION
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO unregister_obj_exec_steps_pub;
         x_return_status := g_ret_sts_unexp_error;

          fem_engines_pkg.tech_message(p_severity => c_log_level_2,
          p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
          p_msg_text => 'Incompatible API call made to '||g_pkg_name||'.'||
          l_api_name||' version: '||l_api_version);

END  unregister_obj_exec_steps;
-- ******************************************************************************
PROCEDURE update_obj_exec_step_status   (p_api_version            IN  NUMBER,
                                         p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
                                         p_request_id             IN  NUMBER,
                                         p_object_id              IN  NUMBER,
                                         p_exec_step              IN  VARCHAR2,
                                         p_exec_status_code       IN  VARCHAR2,
                                         p_user_id                IN  NUMBER,
                                         p_last_update_login      IN  NUMBER,
                                         x_msg_count              OUT NOCOPY NUMBER,
                                         x_msg_data               OUT NOCOPY VARCHAR2,
                                         x_return_status          OUT NOCOPY VARCHAR2) IS

l_api_name  CONSTANT VARCHAR2(30) := 'update_obj_exec_step_status';
l_api_version  CONSTANT NUMBER := 1.0;

BEGIN

   fem_engines_pkg.tech_message(p_severity => c_log_level_1,
   p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
   p_msg_text => 'Begin. REQUEST_ID: '||p_request_id||
   ' P_OBJECT_ID:'||p_object_id||' P_COMMIT:'||p_commit||
   ' P_EXEC_STEP:'||p_exec_step||
   ' P_EXEC_STATUS_CODE:'||p_exec_status_code);

   -- Standard Start of API savepoint
    SAVEPOINT  update_obj_exec_step_statu_pub;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                  p_api_version,
                  l_api_name,
                  g_pkg_name)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;

   UPDATE fem_pl_obj_exec_steps SET exec_status_code = p_exec_status_code,
      last_updated_by = p_user_id, last_update_date = sysdate,
      last_update_login = p_last_update_login
      WHERE request_id = p_request_id
        AND object_id = p_object_id
        AND exec_step = p_exec_step;

   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   fem_engines_pkg.tech_message(p_severity => c_log_level_1,
   p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
   p_msg_text => 'End. X_RETURN_STATUS:'||x_return_status);

   EXCEPTION
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO update_obj_exec_step_statu_pub;
         x_return_status := g_ret_sts_unexp_error;

          fem_engines_pkg.tech_message(p_severity => c_log_level_2,
          p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
          p_msg_text => 'Incompatible API call made to '||g_pkg_name||'.'||
          l_api_name||' version: '||l_api_version);

END  update_obj_exec_step_status;
-- ******************************************************************************
PROCEDURE set_exec_state    (p_api_version            IN  NUMBER,
                             p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
                             p_request_id             IN  NUMBER,
                             p_object_id              IN  NUMBER,
                             x_msg_count              OUT NOCOPY NUMBER,
                             x_msg_data               OUT NOCOPY VARCHAR2,
                             x_return_status          OUT NOCOPY VARCHAR2) IS

v_always_rerunnable_flag VARCHAR2(1);
v_call_status BOOLEAN;
v_request_id NUMBER := p_request_id;
v_rphase   VARCHAR2(80);
v_rstatus  VARCHAR2(80);
v_drphase  VARCHAR2(30);
v_dstatus  VARCHAR2(30);
v_message  VARCHAR2 (240);
v_user_id  NUMBER := FND_GLOBAL.User_Id;
v_last_update_login NUMBER := FND_GLOBAL.Login_Id;
l_api_name  CONSTANT VARCHAR2(30) := 'set_exec_state';
l_api_version  CONSTANT NUMBER := 1.0;

v_cancelled_status  VARCHAR2(30);
v_error_status      VARCHAR2(30);

BEGIN

   fem_engines_pkg.tech_message(p_severity => c_log_level_1,
   p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
   p_msg_text => 'Begin. P_REQUEST_ID: '||p_request_id||
   ' P_OBJECT_ID:'||p_object_id||' P_COMMIT:'||p_commit);

   -- Standard Start of API savepoint
    SAVEPOINT  set_exec_state_pub;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                  p_api_version,
                  l_api_name,
                  g_pkg_name)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;

   -- Check to see if a previous run exists which did not terminate gracefully
   -- enough to populate the FEM_PL_xxx tables.  IF such a previous run exists,
   -- set its execution state appropriately.
   v_call_status := fnd_concurrent.get_request_status (
                      request_id => v_request_id,
                      phase => v_rphase,
                      status => v_rstatus,
                      dev_phase => v_drphase,
                      dev_status => v_dstatus,
                      message => v_message);

   SELECT always_rerunnable_flag INTO v_always_rerunnable_flag
      FROM fem_object_types t, fem_object_catalog_b o
      WHERE o.object_id = p_object_id
        AND o.object_type_code = t.object_type_code;

   IF v_always_rerunnable_flag = 'Y' THEN
      v_cancelled_status := 'CANCELLED_RERUN';
      v_error_status := 'ERROR_RERUN';
   ELSE
      v_cancelled_status := 'CANCELLED_UNDO';
      v_error_status := 'ERROR_UNDO';
   END IF;

   -- If call returned false and request is in 'RUNNING' state,
   -- set request to an error status
   IF (NOT v_call_status) THEN
      fem_engines_pkg.tech_message(p_severity => c_log_level_1,
       p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
       p_msg_text => 'Call to fnd_concurrent.get_request_status failed');

      UPDATE fem_pl_requests SET exec_status_code = v_error_status,
         last_updated_by = v_user_id, last_update_date = sysdate,
         last_update_login = v_last_update_login
         WHERE request_id = p_request_id
         AND exec_status_code = 'RUNNING';

      UPDATE fem_pl_object_executions SET exec_status_code = v_error_status,
         last_updated_by = v_user_id, last_update_date = sysdate,
         last_update_login = v_last_update_login
         WHERE request_id = p_request_id
           AND exec_status_code = 'RUNNING';

   ELSIF v_drphase = 'COMPLETE' AND v_dstatus IN ('NORMAL','WARNING') THEN

      UPDATE fem_pl_requests SET exec_status_code = 'SUCCESS',
         last_updated_by = v_user_id, last_update_date = sysdate,
         last_update_login = v_last_update_login
         WHERE request_id = p_request_id;

      UPDATE fem_pl_object_executions SET exec_status_code = 'SUCCESS',
         last_updated_by = v_user_id, last_update_date = sysdate,
         last_update_login = v_last_update_login
         WHERE request_id = p_request_id
           AND exec_status_code = 'RUNNING';

   ELSIF v_drphase = 'COMPLETE' AND v_dstatus IN ('ERROR','CANCELLED','TERMINATED','DELETED') THEN

      UPDATE fem_pl_requests SET exec_status_code =
      DECODE(v_dstatus,'ERROR',v_error_status,v_cancelled_status),
         last_updated_by = v_user_id, last_update_date = sysdate,
         last_update_login = v_last_update_login
         WHERE request_id = p_request_id;

      UPDATE fem_pl_object_executions SET exec_status_code =
      DECODE(v_dstatus,'ERROR',v_error_status,v_cancelled_status),
         last_updated_by = v_user_id, last_update_date = sysdate,
         last_update_login = v_last_update_login
         WHERE request_id = p_request_id
           AND exec_status_code = 'RUNNING';

   END IF;

   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

    fem_engines_pkg.tech_message(p_severity => c_log_level_2
    ,p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
    p_msg_text => 'End. Request Phase:'||v_drphase||
    '  Request Status:'||v_dstatus||' Always Rerunnable Flag: '||
    v_always_rerunnable_flag||' X_RETURN_STATUS:'||x_return_status);

   EXCEPTION
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO set_exec_state_pub;
         x_return_status := g_ret_sts_unexp_error;

          fem_engines_pkg.tech_message(p_severity => c_log_level_2,
          p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
          p_msg_text => 'Incompatible API call made to '||g_pkg_name||'.'||
          l_api_name||' version: '||l_api_version);

END  set_exec_state;
-- ******************************************************************************
   PROCEDURE mapping_exec_lock_exists   (p_object_id                 IN  NUMBER,
                                         p_exec_object_definition_id IN  NUMBER,
                                         p_ledger_id                 IN  NUMBER,
                                         p_cal_period_id             IN  NUMBER,
                                         p_output_dataset_code       IN  NUMBER,
                                         p_calling_context           IN  VARCHAR2 DEFAULT 'ENGINE',
                                         x_exec_state                OUT NOCOPY VARCHAR2,
                                         x_prev_request_id           OUT NOCOPY NUMBER,
                                         x_msg_count              OUT NOCOPY NUMBER,
                                         x_msg_data               OUT NOCOPY VARCHAR2,
                                         x_exec_lock_exists          OUT NOCOPY VARCHAR2) IS
-- ==========================================================================
--  Returns true if an object execution lock exists.
--  ** Note: This does not check for an execution lock based on approval locks
--           hence this procedure must not be called directly.  Always call
--           obj_execution_lock_exists.
-- ==========================================================================
-- Mapping Rule may not be run for the same ledger, calendar period and dataset code.
-- ==========================================================================
-- BEGIN mapping_obj_execution_lock_exists
-- IF an object execution log does not exists with the same parameters
--    passed into the procedure  THEN
--    Return IF and set x_exec_state = NORMAL;
-- ELSIF an object execution log already exists with the same parameters as the
--    current object execution request, and the status of the existing object execution
--    IS IN (CANCELLED_RERUN,ERROR_RERUN) (This detects a rerun) THEN
--    Return IF and set x_exec_state = RERUN;
-- ELSIF P_calling_context = ENGINE AND an object execution log
--    already exists with the same parameters as the current object execution
--    request, and the status of the object execution IS RUNNING and the
--    request_id is the same as that of the current request (This detects a
--    restart) THEN
--    Return IF and set x_exec_state = RESTART;
-- ELSE
--    Return T and put message ('FEM_PL_RESULTS_EXIST_ERR');
-- End if;
-- END mapping_obj_execution_lock_exists;
-- ==========================================================================

v_request_id NUMBER;
v_restart VARCHAR2(1) := 'F';
v_normal_run VARCHAR2(1);
v_rerun VARCHAR2(1) := 'F';
v_return_status VARCHAR2(1);
l_api_name  CONSTANT VARCHAR2(30) := 'mapping_exec_lock_exists';


CURSOR c1 IS
   SELECT r.request_id
      FROM fem_pl_object_executions o, fem_pl_requests r
      WHERE r.request_id = o.request_id
      AND o.object_id = p_object_id
      AND r.cal_period_id = p_cal_period_id
      AND r.ledger_id = p_ledger_id
      AND r.output_dataset_code = p_output_dataset_code
      AND o.exec_status_code = 'RUNNING';


BEGIN

   fem_engines_pkg.tech_message(p_severity => c_log_level_1,
   p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
   p_msg_text => 'Begin. P_CALLING_CONTEXT: '||p_calling_context||
   ' P_OBJECT_ID:'||p_object_id||
    ' P_LEDGER_ID:'||p_ledger_id||' P_CAL_PERIOD_ID:'||p_cal_period_id||
    ' P_OUTPUT_DATASET_CODE:'||p_output_dataset_code);

   x_msg_count := 0;
   x_exec_state := NULL;

   FOR a_prev_run IN c1 LOOP

      set_exec_state (p_api_version => 1.0,
         p_commit => fnd_api.g_false,
         p_request_id => a_prev_run.request_id,
         p_object_id => p_object_id,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         x_return_status => v_return_status);

   END LOOP;

   -- Check if this is a normal run. (If no object executions exist for
   -- the same LEDGER, CALENDAR PERIOD and OUTPUT DATASET CODE then it
   -- is a normal run).
   SELECT DECODE(COUNT(*),0,'T','F') INTO v_normal_run
      FROM fem_pl_object_executions o, fem_pl_requests r
      WHERE r.request_id = o.request_id
      AND o.object_id = p_object_id
      AND r.cal_period_id = p_cal_period_id
      AND r.ledger_id = p_ledger_id
      AND r.output_dataset_code = p_output_dataset_code;

   IF v_normal_run = 'F' AND p_calling_context = 'ENGINE' THEN

      v_request_id := FND_GLOBAL.CONC_REQUEST_ID;

      -- Check if this is a restart
      SELECT DECODE(COUNT(*),1,'T','F') INTO v_restart
         FROM fem_pl_object_executions o, fem_pl_requests r
         WHERE r.request_id = v_request_id
         AND r.request_id = o.request_id
         AND o.object_id = p_object_id
         AND o.exec_status_code = 'RUNNING';

   END IF;

   IF v_normal_run = 'F' AND v_restart = 'F' THEN

      -- Check if this is a rerun. (If object executions exist with
      -- the for the same LEDGER, CALENDAR PERIOD and OUTPUT DATASET CODE but
      -- the status of the executions is NOT IN ('CANCELLED_RERUN','ERROR_RERUN')
      -- then it is not a rerun).
      SELECT DECODE(COUNT(*),0,'T','F') INTO v_rerun
         FROM fem_pl_object_executions o, fem_pl_requests r
         WHERE r.request_id = o.request_id
         AND o.object_id = p_object_id
         AND r.cal_period_id = p_cal_period_id
         AND r.ledger_id = p_ledger_id
         AND r.output_dataset_code = p_output_dataset_code
         AND o.exec_status_code NOT IN ('CANCELLED_RERUN','ERROR_RERUN');

   END IF;

   IF v_normal_run = 'T' THEN

      x_exec_lock_exists := 'F';
      x_exec_state := 'NORMAL';

   ELSIF v_restart = 'T' THEN

      x_exec_lock_exists := 'F';
      x_exec_state := 'RESTART';

   ELSIF v_rerun = 'T' THEN

      x_exec_lock_exists := 'F';
      x_exec_state := 'RERUN';

      -- Use MAX because there could be more than one cancelled/error rerun
      -- requests for the same object and parameter set.
      SELECT MAX(r.request_id) INTO x_prev_request_id
         FROM fem_pl_object_executions o, fem_pl_requests r
         WHERE r.request_id = o.request_id
         AND o.object_id = p_object_id
         AND r.cal_period_id = p_cal_period_id
         AND r.ledger_id = p_ledger_id
         AND r.output_dataset_code = p_output_dataset_code
         AND o.exec_status_code IN ('CANCELLED_RERUN','ERROR_RERUN');

   ELSE

      x_exec_lock_exists := 'T';
      fem_engines_pkg.put_message(p_app_name =>'FEM',
      p_msg_name =>'FEM_PL_RESULTS_EXIST_ERR');

   END IF;

    fem_engines_pkg.tech_message(p_severity => c_log_level_2,
    p_module => 'fem.plsql.'||g_pkg_name||'.mapping_exec_lock_exists',
    p_msg_text => 'End.  Object execution lock exists:'||x_exec_lock_exists||
    'Execution state:'||x_exec_state||
    ' V_NORMAL_RUN:'||v_normal_run||' V_RESTART:'||v_restart||
    ' V_RERUN:'||v_rerun||' X_PREV_REQUEST_ID:'||x_prev_request_id);

   FND_MSG_PUB.Count_And_Get
      (p_count => x_msg_count,
       p_data  => x_msg_data);

END  mapping_exec_lock_exists;
-- ******************************************************************************
PROCEDURE dim_mbr_ldr_exec_lock_exists  (p_object_id                 IN  NUMBER,
                                         p_exec_object_definition_id IN  NUMBER,
                                         p_calling_context           IN  VARCHAR2 DEFAULT 'ENGINE',
                                         x_exec_state                OUT NOCOPY VARCHAR2,
                                         x_msg_count                 OUT NOCOPY NUMBER,
                                         x_msg_data                  OUT NOCOPY VARCHAR2,
                                         x_exec_lock_exists          OUT NOCOPY VARCHAR2,
                                         x_prev_request_id           OUT NOCOPY NUMBER) IS
-- ==========================================================================
--  Returns true if an object execution lock exists.
--  ** Note: This does not check for an execution lock based on approval locks
--           hence this procedure must not be called directly.  Always call
--           obj_execution_lock_exists.
--           This procedure also assumes that a dimension loader rule is for
--           a single dimension, and only one dimension loader rule exists
--           per dimension.
-- ==========================================================================
-- Dimension Loader OR any rule type for which this procedure is called,
-- may not be run if another execution of that same rule is still running.
-- UNDO: An undo rule may not be processed if the same rule is already running.
-- DIMENSION_LOADER: A dimension loader rule cannot be processed if the rule is already running.
-- ==========================================================================
-- BEGIN dim_mbr_ldr_exec_lock_exists
-- IF an object execution log does not exist THEN
--    Return F and set x_exec_state = NORMAL;
-- ELSIF an object execution log already exists, and the status of the existing object execution
--    IS IN (SUCCESS,CANCELLED_RERUN,ERROR_RERUN) (This detects a rerun) THEN
--    Return F and set x_exec_state = RERUN;
-- ELSIF P_calling_context = ENGINE AND an object execution log
--    already exists, and the status of the object execution IS RUNNING and the
--    request_id is the same as that of the current request (This detects a
--    restart) THEN
--    Return F and set x_exec_state = RESTART;
-- ELSE
--    Return T and put message ('FEM_PL_OBJ_RUNNING');
-- End if;
-- END dim_mbr_ldr_exec_lock_exists;
-- ==========================================================================

v_request_id NUMBER;
v_restart VARCHAR2(1) := 'F';
v_normal_run VARCHAR2(1);
v_rerun VARCHAR2(1) := 'F';
v_return_status VARCHAR2(1);
l_api_name  CONSTANT VARCHAR2(30) := 'dim_mbr_ldr_exec_lock_exists';

CURSOR c1 IS
   SELECT r.request_id
      FROM fem_pl_object_executions o, fem_pl_requests r
      WHERE r.request_id = o.request_id
      AND o.object_id = p_object_id
      AND o.exec_status_code = 'RUNNING';

BEGIN

   fem_engines_pkg.tech_message(p_severity => c_log_level_1,
   p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
   p_msg_text => 'Begin. P_CALLING_CONTEXT: '||p_calling_context||
   ' P_OBJECT_ID:'||p_object_id);

   x_msg_count := 0;
   x_exec_state := NULL;

   FOR a_prev_run IN c1 LOOP

      set_exec_state (p_api_version => 1.0,
         p_commit => fnd_api.g_false,
         p_request_id => a_prev_run.request_id,
         p_object_id => p_object_id,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         x_return_status => v_return_status);

   END LOOP;

   -- Check if this is a normal run. (If no object executions are currently
   -- running then it is a normal run).
   SELECT DECODE(COUNT(*),0,'T','F') INTO v_normal_run
      FROM fem_pl_object_executions o, fem_pl_requests r
      WHERE r.request_id = o.request_id
      AND o.object_id = p_object_id
      AND o.exec_status_code = 'RUNNING';

   IF v_normal_run = 'F' AND p_calling_context = 'ENGINE' THEN

      v_request_id := FND_GLOBAL.CONC_REQUEST_ID;

      -- Check if this is a restart
      SELECT DECODE(COUNT(*),1,'T','F') INTO v_restart
         FROM fem_pl_object_executions o, fem_pl_requests r
         WHERE r.request_id = v_request_id
         AND r.request_id = o.request_id
         AND o.object_id = p_object_id
         AND o.exec_status_code = 'RUNNING';

   END IF;

   IF v_normal_run = 'F' AND v_restart = 'F' THEN

      -- Check if this is a rerun. (If object executions exist but
      -- the status of the executions is NOT IN ('CANCELLED_RERUN','ERROR_RERUN',
      -- 'SUCCESS') then it is not a rerun).
      SELECT DECODE(COUNT(*),0,'T','F') INTO v_rerun
         FROM fem_pl_object_executions o, fem_pl_requests r
         WHERE r.request_id = o.request_id
         AND o.object_id = p_object_id
         AND o.exec_status_code NOT IN ('SUCCESS','CANCELLED_RERUN','ERROR_RERUN');

   END IF;

   IF v_normal_run = 'T' THEN

      x_exec_lock_exists := 'F';
      x_exec_state := 'NORMAL';

   ELSIF v_restart = 'T' THEN

      x_exec_lock_exists := 'F';
      x_exec_state := 'RESTART';

   ELSIF v_rerun = 'T' THEN

      x_exec_lock_exists := 'F';
      x_exec_state := 'RERUN';

      -- Use MAX because there could be more than one cancelled/error rerun
      -- requests for the same object and parameter set.
      SELECT MAX(r.request_id) INTO x_prev_request_id
         FROM fem_pl_object_executions o, fem_pl_requests r
         WHERE r.request_id = o.request_id
         AND o.object_id = p_object_id
         AND o.exec_status_code IN ('SUCCESS','CANCELLED_RERUN','ERROR_RERUN');

   ELSE

      x_exec_lock_exists := 'T';
      fem_engines_pkg.put_message(p_app_name =>'FEM',p_msg_name =>'FEM_PL_OBJ_RUNNING');

   END IF;

    fem_engines_pkg.tech_message(p_severity => c_log_level_2,
    p_module => 'fem.plsql.'||g_pkg_name||'.dim_mbr_ldr_exec_lock_exists',
    p_msg_text => 'End.  Object execution lock exists:'||x_exec_lock_exists||
    'Execution state:'||x_exec_state||
    ' V_NORMAL_RUN:'||v_normal_run||' V_RESTART:'||v_restart||
    ' V_RERUN:'||v_rerun||' X_PREV_REQUEST_ID:'||x_prev_request_id);

   FND_MSG_PUB.Count_And_Get
      (p_count => x_msg_count,
       p_data  => x_msg_data);

END  dim_mbr_ldr_exec_lock_exists;
-- ******************************************************************************
PROCEDURE datax_ldr_exec_lock_exists (p_object_id                 IN  NUMBER,
                                      p_exec_object_definition_id IN  NUMBER,
                                      p_ledger_id                 IN  NUMBER,
                                      p_cal_period_id             IN  NUMBER,
                                      p_output_dataset_code       IN  NUMBER,
                                      p_source_system_code        IN  NUMBER,
                                      p_table_name                IN  VARCHAR2,
                                      p_calling_context           IN  VARCHAR2 DEFAULT 'ENGINE',
                                      x_exec_state                OUT NOCOPY VARCHAR2,
                                      x_prev_request_id           OUT NOCOPY NUMBER,
                                      x_msg_count                 OUT NOCOPY NUMBER,
                                      x_msg_data                  OUT NOCOPY VARCHAR2,
                                      x_exec_lock_exists          OUT NOCOPY VARCHAR2) IS
-- ==========================================================================
--  Returns true if an object execution lock exists.
--  ** Note: This does not check for an execution lock based on approval locks
--           hence this procedure must not be called directly.  Always call
--           obj_execution_lock_exists.
-- ==========================================================================
-- Data Loader Rule (DATAX_LOADER) and Detail client data loader (SOURCE_DATA_LOADER)
-- may not be run for the same ledger, calendar period,
-- dataset code, source_system_code and table name.
-- ==========================================================================
-- BEGIN datax_ldr_exec_lock_exists
-- IF an object execution log does not exists with the same parameters
--    passed into the procedure  THEN
--    Return F and set x_exec_state = NORMAL;
-- ELSIF an object execution log already exists with the same parameters as the
--    current object execution request, and the status of the existing object execution
--    IS IN (CANCELLED_RERUN,ERROR_RERUN) (This detects a rerun) THEN
--    Return F and set x_exec_state = RERUN;
-- ELSIF P_calling_context = ENGINE AND an object execution log
--    already exists with the same parameters as the current object execution
--    request, and the status of the object execution IS RUNNING and the
--    request_id is the same as that of the current request (This detects a
--    restart) THEN
--    Return F and set x_exec_state = RESTART;
-- ELSE
--    Return T and put message ('FEM_PL_RESULTS_EXIST_ERR');
-- End if;
-- END datax_ldr_exec_lock_exists;
-- ==========================================================================

v_request_id NUMBER;
v_restart VARCHAR2(1) := 'F';
v_normal_run VARCHAR2(1);
v_rerun VARCHAR2(1) := 'F';
v_return_status VARCHAR2(1);
l_api_name  CONSTANT VARCHAR2(30) := 'datax_ldr_exec_lock_exists';

CURSOR c1 IS
   SELECT r.request_id
      FROM fem_pl_object_executions o, fem_pl_requests r
      WHERE r.request_id = o.request_id
      AND o.object_id = p_object_id
      AND r.cal_period_id = p_cal_period_id
      AND r.ledger_id = p_ledger_id
      AND r.output_dataset_code = p_output_dataset_code
      AND r.source_system_code = p_source_system_code
      AND r.table_name = p_table_name
      AND o.exec_status_code = 'RUNNING';


BEGIN

   fem_engines_pkg.tech_message(p_severity => c_log_level_1,
   p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
   p_msg_text => 'Begin. P_CALLING_CONTEXT: '||p_calling_context||
   ' P_OBJECT_ID:'||p_object_id||
    ' P_LEDGER_ID:'||p_ledger_id||' P_CAL_PERIOD_ID:'||p_cal_period_id||
    ' P_OUTPUT_DATASET_CODE:'||p_output_dataset_code||
    ' P_SOURCE_SYSTEM_CODE:'||p_source_system_code||
    ' P_TABLE_NAME:'||p_table_name);

   x_msg_count := 0;
   x_exec_state := NULL;

   FOR a_prev_run IN c1 LOOP

      set_exec_state (p_api_version => 1.0,
         p_commit => fnd_api.g_false,
         p_request_id => a_prev_run.request_id,
         p_object_id => p_object_id,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         x_return_status => v_return_status);

   END LOOP;

   -- Check if this is a normal run. (If no object executions exist for
   -- the same LEDGER, CALENDAR PERIOD, SOURCE SYSTEM CODE and
   -- OUTPUT DATASET CODE then it is a normal run).
   SELECT DECODE(COUNT(*),0,'T','F') INTO v_normal_run
      FROM fem_pl_object_executions o, fem_pl_requests r
      WHERE r.request_id = o.request_id
      AND o.object_id = p_object_id
      AND r.cal_period_id = p_cal_period_id
      AND r.ledger_id = p_ledger_id
      AND r.table_name = p_table_name
      AND r.output_dataset_code = p_output_dataset_code
      AND r.source_system_code = p_source_system_code;

   IF v_normal_run = 'F' AND p_calling_context = 'ENGINE' THEN

      v_request_id := FND_GLOBAL.CONC_REQUEST_ID;

      -- Check if this is a restart
      SELECT DECODE(COUNT(*),1,'T','F') INTO v_restart
         FROM fem_pl_object_executions o, fem_pl_requests r
         WHERE r.request_id = v_request_id
         AND r.request_id = o.request_id
         AND o.object_id = p_object_id
         AND r.table_name = p_table_name
         AND o.exec_status_code = 'RUNNING';

   END IF;

   IF v_normal_run = 'F' AND v_restart = 'F' THEN

      -- Check if this is a rerun. (If object executions exist with
      -- the for the same LEDGER, CALENDAR PERIOD and OUTPUT DATASET CODE but
      -- the status of the executions is NOT IN ('CANCELLED_RERUN','ERROR_RERUN')
      -- then it is not a rerun).
      SELECT DECODE(COUNT(*),0,'T','F') INTO v_rerun
         FROM fem_pl_object_executions o, fem_pl_requests r
         WHERE r.request_id = o.request_id
         AND o.object_id = p_object_id
         AND r.cal_period_id = p_cal_period_id
         AND r.ledger_id = p_ledger_id
         AND r.output_dataset_code = p_output_dataset_code
         AND r.source_system_code = p_source_system_code
         AND r.table_name = p_table_name
         AND o.exec_status_code NOT IN ('CANCELLED_RERUN','ERROR_RERUN');

   END IF;

   IF v_normal_run = 'T' THEN

      x_exec_lock_exists := 'F';
      x_exec_state := 'NORMAL';

   ELSIF v_restart = 'T' THEN

      x_exec_lock_exists := 'F';
      x_exec_state := 'RESTART';

   ELSIF v_rerun = 'T' THEN

      x_exec_lock_exists := 'F';
      x_exec_state := 'RERUN';

      -- Use MAX because there could be more than one cancelled/error rerun
      -- requests for the same object and parameter set.
      SELECT MAX(r.request_id) INTO x_prev_request_id
         FROM fem_pl_object_executions o, fem_pl_requests r
         WHERE r.request_id = o.request_id
         AND o.object_id = p_object_id
         AND r.cal_period_id = p_cal_period_id
         AND r.ledger_id = p_ledger_id
         AND r.output_dataset_code = p_output_dataset_code
         AND r.source_system_code = p_source_system_code
         AND r.table_name = p_table_name
         AND o.exec_status_code IN ('CANCELLED_RERUN','ERROR_RERUN');

   ELSE

      x_exec_lock_exists := 'T';
      fem_engines_pkg.put_message(p_app_name =>'FEM',
      p_msg_name =>'FEM_PL_RESULTS_EXIST_ERR');

   END IF;

    fem_engines_pkg.tech_message(p_severity => c_log_level_2,
    p_module => 'fem.plsql.'||g_pkg_name||'.datax_ldr_exec_lock_exists',
    p_msg_text => 'End.  Object execution lock exists:'||x_exec_lock_exists||
    'Execution state:'||x_exec_state||
    ' V_NORMAL_RUN:'||v_normal_run||' V_RESTART:'||v_restart||
    ' V_RERUN:'||v_rerun||' X_PREV_REQUEST_ID:'||x_prev_request_id);

   FND_MSG_PUB.Count_And_Get
      (p_count => x_msg_count,
       p_data  => x_msg_data);

END  datax_ldr_exec_lock_exists;
-- ******************************************************************************
PROCEDURE hier_ldr_exec_lock_exists  (p_object_id                 IN  NUMBER,
                                      p_exec_object_definition_id IN  NUMBER,
                                      p_hierarchy_name            IN  VARCHAR2,
                                      p_calling_context           IN  VARCHAR2 DEFAULT 'ENGINE',
                                      x_exec_state                OUT NOCOPY VARCHAR2,
                                      x_msg_count                 OUT NOCOPY NUMBER,
                                      x_msg_data                  OUT NOCOPY VARCHAR2,
                                      x_exec_lock_exists          OUT NOCOPY VARCHAR2,
                                      x_prev_request_id           OUT NOCOPY NUMBER) IS
-- ==========================================================================
--  Returns true if an object execution lock exists.
--  ** Note: This does not check for an execution lock based on approval locks
--           hence this procedure must not be called directly.  Always call
--           obj_execution_lock_exists.
-- ==========================================================================
-- Hierarchy Loader may not be run for the same hierarchy if another execution
-- is still running for that same hierarchy.
-- ==========================================================================
-- BEGIN hier_ldr_exec_lock_exists
-- IF an object execution log does not exists with the same parameters
--    passed into the procedure  THEN
--    Return F and set x_exec_state = NORMAL;
-- ELSIF an object execution log already exists with the same parameters as the
--    current object execution request, and the status of the existing object execution
--    IS IN (SUCCESS,CANCELLED_RERUN,ERROR_RERUN) (This detects a rerun) THEN
--    Return F and set x_exec_state = RERUN;
-- ELSIF P_calling_context = ENGINE AND an object execution log
--    already exists with the same parameters as the current object execution
--    request, and the status of the object execution IS RUNNING and the
--    request_id is the same as that of the current request (This detects a
--    restart) THEN
--    Return F and set x_exec_state = RESTART;
-- ELSE
--    Return T and put message ('FEM_PL_OBJ_RUNNING');
-- End if;
-- END hier_ldr_exec_lock_exists;
-- ==========================================================================

v_request_id NUMBER;
v_restart VARCHAR2(1) := 'F';
v_normal_run VARCHAR2(1);
v_rerun VARCHAR2(1) := 'F';
v_return_status VARCHAR2(1);
l_api_name  CONSTANT VARCHAR2(30) := 'hier_ldr_exec_lock_exists';

CURSOR c1 IS
   SELECT r.request_id
      FROM fem_pl_object_executions o, fem_pl_requests r
      WHERE r.request_id = o.request_id
      AND o.object_id = p_object_id
      AND r.hierarchy_name = p_hierarchy_name
      AND o.exec_status_code = 'RUNNING';

BEGIN

   fem_engines_pkg.tech_message(p_severity => c_log_level_1,
   p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
   p_msg_text => 'Begin. P_CALLING_CONTEXT: '||p_calling_context||
   ' P_OBJECT_ID:'||p_object_id||' P_hierarchy_name:'||p_hierarchy_name);

   x_msg_count := 0;
   x_exec_state := NULL;

   FOR a_prev_run IN c1 LOOP

      set_exec_state (p_api_version => 1.0,
         p_commit => fnd_api.g_false,
         p_request_id => a_prev_run.request_id,
         p_object_id => p_object_id,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         x_return_status => v_return_status);

   END LOOP;

   -- Check if this is a normal run. (If no object executions are currently
   -- running for the same HIERARCHY then it is a normal run).
   SELECT DECODE(COUNT(*),0,'T','F') INTO v_normal_run
      FROM fem_pl_object_executions o, fem_pl_requests r
      WHERE r.request_id = o.request_id
      AND o.object_id = p_object_id
      AND r.hierarchy_name = p_hierarchy_name
      AND o.exec_status_code = 'RUNNING';

   IF v_normal_run = 'F' AND p_calling_context = 'ENGINE' THEN

      v_request_id := FND_GLOBAL.CONC_REQUEST_ID;

      -- Check if this is a restart
      SELECT DECODE(COUNT(*),1,'T','F') INTO v_restart
         FROM fem_pl_object_executions o, fem_pl_requests r
         WHERE r.request_id = v_request_id
         AND r.request_id = o.request_id
         AND o.object_id = p_object_id
         AND r.hierarchy_name = p_hierarchy_name
         AND o.exec_status_code = 'RUNNING';

   END IF;

   IF v_normal_run = 'F' AND v_restart = 'F' THEN

      -- Check if this is a rerun. (If object executions exist with
      -- the for the same HIERARCHY but
      -- the status of the executions is NOT IN ('SUCCESS','CANCELLED_RERUN','ERROR_RERUN')
      -- then it is not a rerun).
      SELECT DECODE(COUNT(*),0,'T','F') INTO v_rerun
         FROM fem_pl_object_executions o, fem_pl_requests r
         WHERE r.request_id = o.request_id
         AND o.object_id = p_object_id
         AND r.hierarchy_name = p_hierarchy_name
         AND o.exec_status_code NOT IN ('SUCCESS','CANCELLED_RERUN','ERROR_RERUN');

   END IF;

   IF v_normal_run = 'T' THEN

      x_exec_lock_exists := 'F';
      x_exec_state := 'NORMAL';

   ELSIF v_restart = 'T' THEN

      x_exec_lock_exists := 'F';
      x_exec_state := 'RESTART';

   ELSIF v_rerun = 'T' THEN

      x_exec_lock_exists := 'F';
      x_exec_state := 'RERUN';

      -- Use MAX because there could be more than one cancelled/error rerun
      -- requests for the same object and parameter set.
      SELECT MAX(r.request_id) INTO x_prev_request_id
         FROM fem_pl_object_executions o, fem_pl_requests r
         WHERE r.request_id = o.request_id
         AND o.object_id = p_object_id
         AND r.hierarchy_name = p_hierarchy_name
         AND o.exec_status_code IN ('SUCCESS','CANCELLED_RERUN','ERROR_RERUN');

   ELSE

      x_exec_lock_exists := 'T';
      fem_engines_pkg.put_message(p_app_name =>'FEM',
      p_msg_name =>'FEM_PL_OBJ_RUNNING');

   END IF;

    fem_engines_pkg.tech_message(p_severity => c_log_level_2,
    p_module => 'fem.plsql.'||g_pkg_name||'.hier_ldr_exec_lock_exists',
    p_msg_text => 'End.  Object execution lock exists:'||x_exec_lock_exists||
    'Execution state:'||x_exec_state||
    ' V_NORMAL_RUN:'||v_normal_run||' V_RESTART:'||v_restart||
    ' V_RERUN:'||v_rerun||' X_PREV_REQUEST_ID:'||x_prev_request_id);

   FND_MSG_PUB.Count_And_Get
      (p_count => x_msg_count,
       p_data  => x_msg_data);

END  hier_ldr_exec_lock_exists;
-- ******************************************************************************
   PROCEDURE rcm_proc_exec_lock_exists   (p_object_id                IN  NUMBER,
                                         p_exec_object_definition_id IN  NUMBER,
                                         p_ledger_id                 IN  NUMBER,
                                         p_cal_period_id             IN  NUMBER,
                                         p_output_dataset_code       IN  NUMBER,
                                         p_calling_context           IN  VARCHAR2 DEFAULT 'ENGINE',
                                         x_exec_state                OUT NOCOPY VARCHAR2,
                                         x_prev_request_id           OUT NOCOPY NUMBER,
                                         x_msg_count                 OUT NOCOPY NUMBER,
                                         x_msg_data                  OUT NOCOPY VARCHAR2,
                                         x_exec_lock_exists          OUT NOCOPY VARCHAR2) IS
-- ==========================================================================
--  PRIVATE
--  Returns true if an object execution lock exists.
--  ** Note: This does not check for an execution lock based on approval locks
--           hence this procedure must not be called directly.  Always call
--           obj_execution_lock_exists.
-- ==========================================================================
-- RCM_PROCESS_RULE: An RCM Process Rule may not be run if the same rule is
--       still running for the same ledger, calendar period and dataset code.
-- ==========================================================================
-- BEGIN rcm_proc_exec_lock_exists
-- IF an object execution log does not exist with the same parameters
--    passed into the procedure THEN
--    Return F and set x_exec_state = NORMAL;
-- ELSIF an object execution log already exists with the same parameters as the
--    current object execution request, and the status of the existing object execution
--    IS IN (SUCCESS,CANCELLED_RERUN,ERROR_RERUN) (This detects a rerun) THEN
--    Return F and set x_exec_state = RERUN;
-- ELSIF P_calling_context = ENGINE AND an object execution log
--    already exists with the same parameters as the current object execution
--    request, and the status of the object execution IS RUNNING and the
--    request_id is the same as that of the current request (This detects a
--    restart) THEN
--    Return F and set x_exec_state = RESTART;
-- ELSE
--    Return T and put message ('FEM_PL_OBJ_RUNNING');
-- End if;
-- END rcm_proc_exec_lock_exists;
-- ==========================================================================

v_request_id NUMBER;
v_restart VARCHAR2(1) := 'F';
v_normal_run VARCHAR2(1);
v_rerun VARCHAR2(1) := 'F';
v_return_status VARCHAR2(1);
l_api_name  CONSTANT VARCHAR2(30) := 'rcm_proc_exec_lock_exists';


CURSOR c1 IS
   SELECT r.request_id
      FROM fem_pl_object_executions o, fem_pl_requests r
      WHERE r.request_id = o.request_id
      AND o.object_id = p_object_id
      AND r.cal_period_id = p_cal_period_id
      AND r.ledger_id = p_ledger_id
      AND r.output_dataset_code = p_output_dataset_code
      AND o.exec_status_code = 'RUNNING';


BEGIN

   fem_engines_pkg.tech_message(p_severity => c_log_level_1,
   p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
   p_msg_text => 'Begin. P_CALLING_CONTEXT: '||p_calling_context||
   ' P_OBJECT_ID:'||p_object_id||
    ' P_LEDGER_ID:'||p_ledger_id||' P_CAL_PERIOD_ID:'||p_cal_period_id||
    ' P_OUTPUT_DATASET_CODE:'||p_output_dataset_code);

   x_msg_count := 0;
   x_exec_state := NULL;

   FOR a_prev_run IN c1 LOOP

      set_exec_state (p_api_version => 1.0,
         p_commit => fnd_api.g_false,
         p_request_id => a_prev_run.request_id,
         p_object_id => p_object_id,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         x_return_status => v_return_status);

   END LOOP;

   -- Check if this is a normal run. (If no object executions is currently
   -- running with the same LEDGER, CALENDAR PERIOD and OUTPUT DATASET CODE
   -- then it is a normal run).
   SELECT DECODE(COUNT(*),0,'T','F') INTO v_normal_run
      FROM fem_pl_object_executions o, fem_pl_requests r
      WHERE r.request_id = o.request_id
      AND o.object_id = p_object_id
      AND r.cal_period_id = p_cal_period_id
      AND r.ledger_id = p_ledger_id
      AND r.output_dataset_code = p_output_dataset_code
      AND o.exec_status_code = 'RUNNING';

   IF v_normal_run = 'F' AND p_calling_context = 'ENGINE' THEN

      v_request_id := FND_GLOBAL.CONC_REQUEST_ID;

      -- Check if this is a restart
      SELECT DECODE(COUNT(*),1,'T','F') INTO v_restart
         FROM fem_pl_object_executions o, fem_pl_requests r
         WHERE r.request_id = v_request_id
         AND r.request_id = o.request_id
         AND o.object_id = p_object_id
         AND o.exec_status_code = 'RUNNING';

   END IF;

   IF v_normal_run = 'F' AND v_restart = 'F' THEN

      -- Check if this is a rerun. (If object executions exist with
      -- the same LEDGER, CALENDAR PERIOD and OUTPUT DATASET CODE but
      -- the status of the executions is NOT IN ('CANCELLED_RERUN','ERROR_RERUN',
      -- 'SUCCESS') then it is not a rerun).
      SELECT DECODE(COUNT(*),0,'T','F') INTO v_rerun
         FROM fem_pl_object_executions o, fem_pl_requests r
         WHERE r.request_id = o.request_id
         AND o.object_id = p_object_id
         AND r.cal_period_id = p_cal_period_id
         AND r.ledger_id = p_ledger_id
         AND r.output_dataset_code = p_output_dataset_code
         AND o.exec_status_code NOT IN ('CANCELLED_RERUN','ERROR_RERUN','SUCCESS');

   END IF;

   IF v_normal_run = 'T' THEN

      x_exec_lock_exists := 'F';
      x_exec_state := 'NORMAL';

   ELSIF v_restart = 'T' THEN

      x_exec_lock_exists := 'F';
      x_exec_state := 'RESTART';

   ELSIF v_rerun = 'T' THEN

      x_exec_lock_exists := 'F';
      x_exec_state := 'RERUN';

      -- Use MAX because there could be more than one cancelled/error rerun
      -- requests for the same object and parameter set.
      SELECT MAX(r.request_id) INTO x_prev_request_id
         FROM fem_pl_object_executions o, fem_pl_requests r
         WHERE r.request_id = o.request_id
         AND o.object_id = p_object_id
         AND r.cal_period_id = p_cal_period_id
         AND r.ledger_id = p_ledger_id
         AND r.output_dataset_code = p_output_dataset_code
         AND o.exec_status_code IN ('CANCELLED_RERUN','ERROR_RERUN','SUCCESS');

   ELSE

      x_exec_lock_exists := 'T';
      fem_engines_pkg.put_message(p_app_name =>'FEM',
      p_msg_name =>'FEM_PL_OBJ_RUNNING');

   END IF;

    fem_engines_pkg.tech_message(p_severity => c_log_level_2,
    p_module => 'fem.plsql.'||g_pkg_name||'.mapping_exec_lock_exists',
    p_msg_text => 'End.  Object execution lock exists:'||x_exec_lock_exists||
    'Execution state:'||x_exec_state||
    ' V_NORMAL_RUN:'||v_normal_run||' V_RESTART:'||v_restart||
    ' V_RERUN:'||v_rerun||' X_PREV_REQUEST_ID:'||x_prev_request_id);

   FND_MSG_PUB.Count_And_Get
      (p_count => x_msg_count,
       p_data  => x_msg_data);

END  rcm_proc_exec_lock_exists;
-- ****************************************************************************

PROCEDURE preview_exec_lock_exists (
      p_object_id                 IN  NUMBER,
      p_exec_object_definition_id IN  NUMBER,
      p_calling_context           IN  VARCHAR2 DEFAULT 'ENGINE',
      x_exec_state                OUT NOCOPY VARCHAR2,
      x_prev_request_id           OUT NOCOPY NUMBER,
      x_msg_count                 OUT NOCOPY NUMBER,
      x_msg_data                  OUT NOCOPY VARCHAR2,
      x_exec_lock_exists          OUT NOCOPY VARCHAR2) IS
-- ==========================================================================
--  Returns true if an object execution lock exists.
--  ** Note: This does not check for an execution lock based on approval locks
-- ==========================================================================
-- Preview Rule versions may not be run more than once, regardless of the
--    runtime parameters.
-- ==========================================================================
-- BEGIN preview_obj_execution_lock_exists
-- IF an object execution log does not exists for the same Preview Rule version THEN
--    Return F and set x_exec_state = NORMAL;
-- ELSIF (P_calling_context = ENGINE
--    AND an object execution log already exists for the same Preview Rule
--    AND the status of the object execution IS RUNNING
--    AND registered request_id is the same as that of the current request) THEN
--    Return F and set x_exec_state = RESTART;
-- ELSE
--    Return T and put message ('FEM_PL_RESULTS_EXIST_ERR');
-- End if;
-- END preview_obj_execution_lock_exists;
-- ==========================================================================

v_request_id NUMBER;
v_restart VARCHAR2(1);
v_normal_run VARCHAR2(1);
v_return_status VARCHAR2(1);
l_api_name  CONSTANT VARCHAR2(30) := 'preview_exec_lock_exists';

CURSOR c1 IS
   SELECT o.request_id
      FROM fem_pl_object_executions o
      WHERE o.exec_object_definition_id = p_exec_object_definition_id
      AND o.exec_status_code = 'RUNNING';

BEGIN

   fem_engines_pkg.tech_message(p_severity => c_log_level_1,
     p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
     p_msg_text => 'Begin. P_CALLING_CONTEXT: '||p_calling_context
                 ||'; P_OBJECT_ID:'||p_object_id
                 ||'; P_EXEC_OBJECT_DEFINITION_ID:'||p_exec_object_definition_id);

   FOR a_prev_run IN c1 LOOP

      set_exec_state (p_api_version => 1.0,
         p_commit => fnd_api.g_false,
         p_request_id => a_prev_run.request_id,
         p_object_id => p_object_id,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         x_return_status => v_return_status);

   END LOOP;

   -- Check if this is a normal run. (If no object executions exist for
   -- the same Preview Rule version then it is a normal run).
   SELECT DECODE(COUNT(*),0,'T','F') INTO v_normal_run
      FROM fem_pl_object_executions o
      WHERE o.exec_object_definition_id = p_exec_object_definition_id;

   IF v_normal_run = 'F' AND p_calling_context = 'ENGINE' THEN

      v_request_id := FND_GLOBAL.CONC_REQUEST_ID;

      -- Check if this is a restart
      SELECT DECODE(COUNT(*),1,'T','F') INTO v_restart
         FROM fem_pl_object_executions o
         WHERE o.request_id = v_request_id
         AND o.exec_object_definition_id = p_exec_object_definition_id
         AND o.exec_status_code = 'RUNNING';

   END IF;

   IF v_normal_run = 'T' THEN

      x_exec_lock_exists := 'F';
      x_exec_state := 'NORMAL';

   ELSIF v_restart = 'T' THEN

      x_exec_lock_exists := 'F';
      x_exec_state := 'RESTART';

   ELSE

      x_exec_lock_exists := 'T';
      fem_engines_pkg.put_message(p_app_name =>'FEM',
         p_msg_name =>'FEM_PL_RESULTS_EXIST_ERR');

   END IF;

   fem_engines_pkg.tech_message(p_severity => c_log_level_2,
      p_module => 'fem.plsql.'||g_pkg_name||'.preview_exec_lock_exists',
      p_msg_text => 'End.  Object execution lock exists:'||x_exec_lock_exists
                  ||'; Execution state:'||x_exec_state
                  ||'; V_NORMAL_RUN:'||v_normal_run
                  ||'; V_RESTART:'||v_restart
                  ||'; X_PREV_REQUEST_ID:'||x_prev_request_id);

   FND_MSG_PUB.Count_And_Get
      (p_count => x_msg_count,
       p_data  => x_msg_data);

END  preview_exec_lock_exists;
-- ****************************************************************************

PROCEDURE check_chaining (
   p_api_version     IN NUMBER     DEFAULT 1.0,
   p_init_msg_list   IN  VARCHAR2   DEFAULT FND_API.G_FALSE,
   p_commit          IN  VARCHAR2   DEFAULT FND_API.G_FALSE,
   p_encoded         IN  VARCHAR2   DEFAULT FND_API.G_TRUE,
   x_return_status   OUT NOCOPY VARCHAR2,
   x_msg_count       OUT NOCOPY NUMBER,
   x_msg_data        OUT NOCOPY VARCHAR2,
   p_request_id      IN  NUMBER,
   p_object_id       IN  NUMBER,
   x_dep_request_id  OUT NOCOPY NUMBER,
   x_dep_object_id   OUT NOCOPY NUMBER,
   x_chain_exists    OUT NOCOPY VARCHAR2
) IS
-- =========================================================================
-- Purpose
--    Given an object execution, check if it has been chained to other
--    object executions.  If yes, this procedure also returns one
--    of the object executions chained to the given object execution.
-- History
--    01-30-06  G Cheng    Created
-- Arguments
--    p_request_id         Request ID of the object execution being checked
--                         for chaining.
--    p_object_id          Object ID of the object execution being checked
--                         for chaining.
--    x_dep_request_id     Request ID of the object execution that depends on
--                         the input object execution
--    x_dep_object_id      Object ID of the object execution that depends on
--                         the input object execution
--    x_chain_exists       Flag to indicate if the input object execution
--                         has been chained to another execution.
-- Logic
--    Checks fem_pl_chains table to see if the input object execution
--    exists as a source.  If yes, then set x_chain_exists to 'T' and also
--    set x_dep_request/object_id parameters with the dependent object
--    execution information.  Otherwise, set x_chain_exists to 'F'.
-- =========================================================================
  C_MODULE            CONSTANT FND_LOG_MESSAGES.module%TYPE :=
     'fem.plsql.fem_pl_pkg.check_chaining';
  C_API_NAME          CONSTANT VARCHAR2(30)  := 'Check_Chaining';
  C_API_VERSION       CONSTANT NUMBER := 1.0;
--
  v_count               NUMBER;
  e_unexp               EXCEPTION;
--
  CURSOR c_chains (p_request_id NUMBER, p_object_id NUMBER) IS
    SELECT request_id, object_id
    FROM fem_pl_chains
    WHERE source_created_by_request_id = p_request_id
    AND source_created_by_object_id = p_object_id;
--
BEGIN
--
  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;

  -- Initialize return status to unexpected error
  x_return_status := g_ret_sts_unexp_error;

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
        p_msg_text => 'INTERNAL ERROR: API Version ('||C_API_VERSION||') not compatible with '
                    ||'passed in version ('||p_api_version||')');
    END IF;
    RAISE e_unexp;
  END IF;

  -- Initialize FND message queue
  IF p_init_msg_list = FND_API.G_TRUE then
    FND_MSG_PUB.Initialize;
  END IF;

  -- Check to see this request has been chanined to another process.
  OPEN c_chains(p_request_id, p_object_id);
  FETCH c_chains INTO x_dep_request_id, x_dep_object_id;
  IF c_chains%NOTFOUND THEN
    x_chain_exists := FND_API.G_FALSE;
  ELSE
    x_chain_exists := FND_API.G_TRUE;
  END IF;
  CLOSE c_chains;

  x_return_status := g_ret_sts_success;

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
  WHEN others THEN
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
    x_return_status := g_ret_sts_unexp_error;

END check_chaining;
-- ****************************************************************************

PROCEDURE get_exec_status (
   p_api_version     IN NUMBER     DEFAULT 1.0,
   p_init_msg_list     IN  VARCHAR2   DEFAULT FND_API.G_FALSE,
   p_commit            IN  VARCHAR2   DEFAULT FND_API.G_FALSE,
   p_encoded           IN  VARCHAR2   DEFAULT FND_API.G_TRUE,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   p_request_id        IN  NUMBER,
   p_object_id         IN  NUMBER,
   x_exec_status_code  OUT NOCOPY VARCHAR2
) IS
-- =========================================================================
-- Purpose
--    Given an object execution, returns the execution status code.
-- History
--    01-30-06  G Cheng    Created
--    01-10-07  G Cheng    Bug 5746626. Mapping Preview project.
-- Arguments
--    p_request_id         Request ID of the object execution
--    p_object_id          Object ID of the object execution
--    x_exec_status_code   Execution status code of the object execution
-- Logic
--    Checks fem_pl_object_executions table to obtain the execution status
--    of the input object execution.  If the status is RUNNING, make sure
--    that the execution is still actually running by checking the
--    FND Concurrent Program status.  The FND Concurrent Program status is
--    more accurate.
-- =========================================================================
  C_MODULE            CONSTANT FND_LOG_MESSAGES.module%TYPE :=
     'fem.plsql.fem_pl_pkg.get_exec_status';
  C_API_NAME          CONSTANT VARCHAR2(30)  := 'Get_Exec_Status';
  C_API_VERSION       CONSTANT NUMBER := 1.0;
--
  v_count               NUMBER;
  e_unexp               EXCEPTION;
  e_api_error           EXCEPTION;
  v_exec_status_code    FEM_PL_OBJECT_EXECUTIONS.exec_status_code%TYPE;
  v_object_type_code    FEM_OBJECT_CATALOG_B.object_type_code%TYPE;
  v_call_status         BOOLEAN;
  v_request_id          FND_CONCURRENT_REQUESTS.request_id%TYPE;
  v_req_phase           FND_CONCURRENT_REQUESTS.phase_code%TYPE;
  v_req_status          FND_CONCURRENT_REQUESTS.status_code%TYPE;
  v_req_dev_phase       VARCHAR2(30);
  v_rec_dev_status      VARCHAR2(30);
  v_rec_message         FND_CONCURRENT_REQUESTS.completion_text%TYPE;
--
BEGIN
--
  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure: p_request_id = '||to_char(p_request_id)
                  ||'; p_object_id = '||to_char(p_object_id));
  END IF;

  -- Initialize return status to unexpected error
  x_return_status := g_ret_sts_unexp_error;

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
        p_msg_text => 'INTERNAL ERROR: API Version ('||C_API_VERSION||') not compatible with '
                    ||'passed in version ('||p_api_version||')');
    END IF;
    RAISE e_unexp;
  END IF;

  -- Initialize FND message queue
  IF p_init_msg_list = FND_API.G_TRUE then
    FND_MSG_PUB.Initialize;
  END IF;

  -- Standard Start of API savepoint
  SAVEPOINT get_exec_status_pub;

  -- Get the exec status code as recorded in FEM_PL_OBJECT_EXECUTIONS
  BEGIN
    SELECT exec_status_code
    INTO v_exec_status_code
    FROM fem_pl_object_executions
    WHERE request_id = p_request_id
    AND object_id = p_object_id;

    -- If the PL status indicates that the execution is still running
    -- we need to double check that the execution is indeed still running
    -- by calling set_exec_state.  Set_exec_state will set the updated
    -- status in FEM_PL_OBJECT_EXECUTIONS.
    IF v_exec_status_code = 'RUNNING' THEN
      set_exec_state (p_api_version => 1.0,
         p_commit => FND_API.G_FALSE,
         p_request_id => p_request_id,
         p_object_id => p_object_id,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data,
         x_return_status => x_return_status);

      IF x_return_status <> g_ret_sts_success THEN
        RAISE e_api_error;
      END IF;

      -- Get the status again
      SELECT exec_status_code
      INTO v_exec_status_code
      FROM fem_pl_object_executions
      WHERE request_id = p_request_id
      AND object_id = p_object_id;
    END IF;

  EXCEPTION
    -- Bug 5746626. Mapping Preview project.
    -- If the object type is MAPPING_PREVIEW, in the case that
    -- the object execution is not yet registered, check the
    -- concurrent request status to see if it has completed running or not.
    -- If not, set exec_status_code as RUNNING.  Otherwise, raise
    -- unexpected error because if the concurrent program has finished
    -- running, the engine should have registered the object execution already.
    WHEN no_data_found THEN
      SELECT object_type_code
      INTO v_object_type_code
      FROM fem_object_catalog_b
      WHERE object_id = p_object_id;

      IF v_object_type_code = 'MAPPING_PREVIEW' THEN
        -- needed because request_id is an IN OUT param
        v_request_id := p_request_id;
        v_call_status := FND_CONCURRENT.get_request_status (
                           request_id  => v_request_id,
                           phase       => v_req_phase,
                           status      => v_req_status,
                           dev_phase   => v_req_dev_phase,
                           dev_status  => v_rec_dev_status,
                           message     => v_rec_message);
        IF v_call_status THEN
          -- As of 1/7/07, the possible values for dev_phase are:
          --   RUNNING, PENDING, COMPLETE, INACTIVE
          IF v_req_dev_phase <> 'COMPLETE' THEN
            v_exec_status_code := 'RUNNING';
          ELSE
            IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
              FEM_ENGINES_PKG.TECH_MESSAGE(
                p_severity => FND_LOG.level_statement,
                p_module   => C_MODULE,
                p_msg_text => 'Call to FND_CONCURRENT.get_request_status '
                            ||'returned with dev phase of: '||v_req_dev_phase);
            END IF;
            RAISE e_unexp;
          END IF;
        ELSE
          -- If concurrent request is no longer present, it must have
          -- already ran and since been removed from FND_REQUESTS due to
          -- system cleanup.  Set v_exec_status_code to SUCCESS in this case.
          v_exec_status_code := 'SUCCESS';
        END IF;
      ELSE
        RAISE;
      END IF;
  END;

  x_exec_status_code := v_exec_status_code;
  x_return_status := g_ret_sts_success;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure: x_return_status = '||x_return_status
                  ||'; x_exec_status_code = '||x_exec_status_code);
  END IF;
--
EXCEPTION
  WHEN e_api_error THEN
    ROLLBACK TO get_exec_status_pub;
  WHEN others THEN
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
    ROLLBACK TO get_exec_status_pub;
    x_return_status := g_ret_sts_unexp_error;

END get_exec_status;
-- ****************************************************************************


END fem_pl_pkg;

/
