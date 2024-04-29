--------------------------------------------------------
--  DDL for Package Body FEM_OBJECT_CATALOG_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_OBJECT_CATALOG_UTIL_PKG" AS
/* $Header: fem_objcat_utl.plb 120.8 2006/07/28 19:41:29 dyung ship $ */

/* ***********************
** Package constants
** ***********************/
pc_pkg_name            CONSTANT VARCHAR2(30) := 'fem_object_catalog_util_pkg';

pc_ret_sts_success        CONSTANT VARCHAR2(1):= fnd_api.g_ret_sts_success;
pc_ret_sts_error          CONSTANT VARCHAR2(1):= fnd_api.g_ret_sts_error;
pc_ret_sts_unexp_error    CONSTANT VARCHAR2(1):= fnd_api.g_ret_sts_unexp_error;

pc_resp_app_id            CONSTANT NUMBER := FND_GLOBAL.RESP_APPL_ID;
pc_last_update_login      CONSTANT NUMBER := FND_GLOBAL.Login_Id;
pc_user_id                CONSTANT NUMBER := FND_GLOBAL.USER_ID;

pc_object_version_number  CONSTANT NUMBER := 1;

pc_log_level_statement    CONSTANT  NUMBER  := fnd_log.level_statement;
pc_log_level_procedure    CONSTANT  NUMBER  := fnd_log.level_procedure;
pc_log_level_event        CONSTANT  NUMBER  := fnd_log.level_event;
pc_log_level_exception    CONSTANT  NUMBER  := fnd_log.level_exception;
pc_log_level_error        CONSTANT  NUMBER  := fnd_log.level_error;
pc_log_level_unexpected   CONSTANT  NUMBER  := fnd_log.level_unexpected;


/* ***********************
** Package variables
** ***********************/
--dbms_utility.format_call_stack                 VARCHAR2(2000);

/* ***********************
** Package exceptions
** ***********************/
e_cannot_create_definition     EXCEPTION;
e_invalid_object_type          EXCEPTION;
e_invalid_object_origin        EXCEPTION;
e_invalid_object_access_code   EXCEPTION;
e_invalid_folder               EXCEPTION;
e_invalid_effective_date_range EXCEPTION;
e_cannot_delete_object         EXCEPTION;
e_invalid_local_vs_combo_id    EXCEPTION;
e_cannot_write_to_object       EXCEPTION;
e_duplicate_obj_name           EXCEPTION;

gv_prg_msg      VARCHAR2(2000);
gv_callstack    VARCHAR2(2000);


/* ******************************************************************************/
PROCEDURE create_object (x_object_id            OUT NOCOPY NUMBER,
                         x_object_definition_id OUT NOCOPY NUMBER,
                         x_msg_count            OUT NOCOPY NUMBER,
                         x_msg_data             OUT NOCOPY VARCHAR2,
                         x_return_status        OUT NOCOPY VARCHAR2,
                         p_api_version          IN  NUMBER,
                         p_commit               IN  VARCHAR2,
                         p_object_type_code     IN  VARCHAR2,
                         p_folder_id            IN  NUMBER,
                         p_local_vs_combo_id    IN  NUMBER,
                         p_object_access_code   IN  VARCHAR2,
                         p_object_origin_code   IN  VARCHAR2,
                         p_object_name          IN  VARCHAR2,
                         p_description          IN  VARCHAR2,
                         p_effective_start_date IN  DATE DEFAULT sysdate,
                         p_effective_end_date   IN  DATE DEFAULT to_date('9999/01/01','YYYY/MM/DD'),
                         p_obj_def_name         IN  VARCHAR2)
IS

/* ==========================================================================
** This procedure creates a new Object in the FEM Object Catalog.
** It also creates a new Object Definition for the new Object
** ==========================================================================
** ==========================================================================*/
c_api_name  CONSTANT VARCHAR2(30) := 'create_object';
c_api_version  CONSTANT NUMBER := 1.0;
v_rowid VARCHAR2(100);
v_count NUMBER;
v_folder_name varchar2(150);


   BEGIN

      fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
      p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
      p_msg_text => 'Begin. P_OBJECT_TYPE_CODE: '||p_object_type_code||
      ' P_FOLDER_ID:'||p_folder_id||
      ' P_LOCAL_VS_COMBO_ID:'||p_local_vs_combo_id||
      ' P_OBJECT_ACCESS_CODE:'||p_object_access_code||
      ' P_OBJECT_ORIGIN_CODE:'||p_object_origin_code||
      ' P_OBJECT_NAME:'||p_object_name||
      ' P_DESCRIPTION:'||p_description||
      ' P_EFFECTIVE_START_DATE:'||p_effective_start_date||
      ' P_EFFECTIVE_END_DATE:'||p_effective_end_date||
      ' P_OBJ_DEF_NAME:'||p_obj_def_name||
      ' P_COMMIT: '||p_commit);

      /* Standard Start of API savepoint */
       SAVEPOINT  create_object_pub;

      /* Standard call to check for call compatibility. */
      IF NOT FND_API.Compatible_API_Call (c_api_version,
                     p_api_version,
                     c_api_name,
                     pc_pkg_name)
      THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      /* Initialize API return status to success */
      x_return_status := pc_ret_sts_success;

      /* Validate that the Object Type exists  */
      SELECT count(*)
      INTO v_count
      FROM fem_object_types_b
      WHERE object_type_code = p_object_type_code;

      IF v_count = 0 THEN
         RAISE e_invalid_object_type;
      END IF;  /* object_type_code validation */

      /* Validate that the Object Origin exists in FND_LOOKUP_VALUES */
      SELECT count(*)
      INTO v_count
      FROM fnd_lookup_values
      WHERE lookup_type = 'FEM_OBJECT_ORIGIN_DSC'
      AND lookup_code = p_object_origin_code;

      IF v_count = 0 THEN
         RAISE e_invalid_object_origin;
      END IF;  /* object_origin_code validation */

      /* Validate that the Object Access Code exists in FND_LOOKUP_VALUES */
      SELECT count(*)
      INTO v_count
      FROM fnd_lookup_values
      WHERE lookup_type = 'FEM_OBJECT_ACCESS_DSC'
      AND lookup_code = p_object_access_code;

      IF v_count = 0 THEN
         RAISE e_invalid_object_access_code;
      END IF;  /* object_access_code validation */

     -- validate that the folder exists and get the name if it does
     BEGIN
        SELECT folder_name
        INTO v_folder_name
        FROM fem_folders_vl
        WHERE folder_id = p_folder_id;

     EXCEPTION
       WHEN no_data_found THEN raise e_invalid_folder;

     END;

      -- Bug 4309949: ignore folder security for Undo objects
      IF p_object_type_code <> 'UNDO' THEN
        -- validate that the Folder ID exists and that
        -- the user can write to the folder
        SELECT count(*)
        INTO v_count
        FROM fem_user_folders
        WHERE user_id = pc_user_id
        AND folder_id = p_folder_id
        AND write_flag = 'Y';

        IF v_count = 0 THEN
           RAISE e_invalid_folder;
        END IF;  /* folder_id validation*/
      END IF;

      /* validate that the start date and end date are consistent */
      IF p_effective_start_date >= p_effective_end_date THEN
         RAISE e_invalid_effective_date_range;
      END IF;  /* effective date validation */

      /* Validate local_vs_combo_id  */
      IF p_local_vs_combo_id IS NOT NULL THEN
         SELECT count(*)
         INTO v_count
         FROM fem_global_vs_combos_vl
         WHERE global_vs_combo_id = p_local_vs_combo_id;

         IF v_count = 0 THEN
            RAISE e_invalid_local_vs_combo_id;
         END IF;  /* local_vs_combo_id validation */
      END IF;

      SELECT fem_object_id_seq.nextval
      INTO x_object_id
      FROM dual;

      BEGIN
      FEM_OBJECT_CATALOG_PKG.INSERT_ROW (
         X_ROWID => v_rowid,
         X_OBJECT_ID => x_object_id,
         X_OBJECT_TYPE_CODE => p_object_type_code,
         X_FOLDER_ID => p_folder_id,
         X_LOCAL_VS_COMBO_ID => p_local_vs_combo_id,
         X_OBJECT_ACCESS_CODE => p_object_access_code,
         X_OBJECT_ORIGIN_CODE => p_object_origin_code,
         X_OBJECT_VERSION_NUMBER => pc_object_version_number,
         X_OBJECT_NAME => p_object_name,
         X_DESCRIPTION => p_description,
         X_CREATION_DATE => sysdate,
         X_CREATED_BY => pc_user_id,
         X_LAST_UPDATE_DATE => sysdate,
         X_LAST_UPDATED_BY => pc_user_id,
         X_LAST_UPDATE_LOGIN => pc_last_update_login);
       EXCEPTION
          WHEN dup_val_on_index THEN raise e_duplicate_obj_name;
       END;

      create_object_definition  (p_api_version => 1.0,
                                 p_commit => FND_API.G_FALSE,
                                 p_object_id => x_object_id,
                                 p_effective_start_date => p_effective_start_date,
                                 p_effective_end_date => p_effective_end_date,
                                 p_obj_def_name => p_obj_def_name,
                                 p_object_origin_code => p_object_origin_code,
                                 x_object_definition_id => x_object_definition_id,
                                 x_msg_count => x_msg_count,
                                 x_msg_data => x_msg_data,
                                 x_return_status => x_return_status);


      IF x_return_status <> pc_ret_sts_success THEN
         RAISE e_cannot_create_definition;
      END IF;

      IF FND_API.To_Boolean( p_commit ) THEN
         COMMIT WORK;
      END IF;

      fem_engines_pkg.put_message(p_app_name =>'FEM',
      p_msg_name =>'FEM_CREATED_OBJ_TXT',
      p_token1 => 'OBJECT_NAME',
      p_value1 => p_object_name,
      p_trans1 => 'N');

      fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
      p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
      p_msg_text => 'End. X_RETURN_STATUS: '||x_return_status);

      FND_MSG_PUB.Count_And_Get
         (p_count => x_msg_count,
          p_data => x_msg_data);

   EXCEPTION
      WHEN e_duplicate_obj_name THEN
         ROLLBACK TO create_object_pub;
         x_return_status := pc_ret_sts_error;

         fem_engines_pkg.put_message(p_app_name =>'FEM'
         ,p_msg_name =>'FEM_BR_OBJ_NAME_ERR'
         ,p_token1 => 'OBJECT_TYPE_MEANING'
         ,p_value1 => p_object_type_code
         ,p_token2 => 'FOLDER_NAME'
         ,p_value2 => v_folder_name
         ,p_token3 => 'OBJECT_NAME'
         ,p_value3 => p_object_name);

      FND_MSG_PUB.Count_And_Get
         (p_count => x_msg_count,
          p_data => x_msg_data);



      WHEN e_invalid_local_vs_combo_id THEN
         ROLLBACK TO create_object_pub;
         x_return_status := pc_ret_sts_error;
         fem_engines_pkg.put_message(p_app_name =>'FEM'
         ,p_msg_name =>'FEM_INVALID_LOCAL_VS_COMBO_ID'
         ,p_token1 => 'LOCAL_VS_COMBO_ID'
         ,p_value1 => p_local_vs_combo_id);

      FND_MSG_PUB.Count_And_Get
         (p_count => x_msg_count,
          p_data => x_msg_data);

      WHEN e_invalid_object_type THEN
         ROLLBACK TO create_object_pub;
         x_return_status := pc_ret_sts_error;
         fem_engines_pkg.put_message(p_app_name =>'FEM'
         ,p_msg_name =>'FEM_INVALID_OBJECT_TYPE'
         ,p_token1 => 'OBJTYPE'
         ,p_value1 => p_object_type_code);

      FND_MSG_PUB.Count_And_Get
         (p_count => x_msg_count,
          p_data => x_msg_data);

      WHEN e_invalid_object_origin THEN
         ROLLBACK TO create_object_pub;
         x_return_status := pc_ret_sts_error;
         fem_engines_pkg.put_message(p_app_name =>'FEM'
         ,p_msg_name =>'FEM_INVALID_OBJECT_ORIGIN'
         ,p_token1 => 'OBJORIG'
         ,p_value1 => p_object_origin_code);

      FND_MSG_PUB.Count_And_Get
         (p_count => x_msg_count,
          p_data => x_msg_data);


      WHEN e_invalid_object_access_code THEN
         ROLLBACK TO create_object_pub;
         x_return_status := pc_ret_sts_error;
         fem_engines_pkg.put_message(p_app_name =>'FEM'
         ,p_msg_name =>'FEM_INVALID_OBJ_ACCESS_CODE'
         ,p_token1 => 'OBJACC'
         ,p_value1 => p_object_access_code);

      FND_MSG_PUB.Count_And_Get
         (p_count => x_msg_count,
          p_data => x_msg_data);

      WHEN e_invalid_folder THEN
         ROLLBACK TO create_object_pub;
         x_return_status := pc_ret_sts_error;
         fem_engines_pkg.put_message(p_app_name =>'FEM',
         p_msg_name =>'FEM_IMPEXP_INVALID_FOLDER_ERR',
         p_token1 => 'FOLDER',
         p_value1 => v_folder_name);

      FND_MSG_PUB.Count_And_Get
         (p_count => x_msg_count,
          p_data => x_msg_data);

      WHEN e_invalid_effective_date_range THEN
         ROLLBACK TO create_object_pub;
         x_return_status := pc_ret_sts_error;
         fem_engines_pkg.put_message(p_app_name =>'FEM',
         p_msg_name =>'FEM_BR_END_LT_START_DATE_ERR',
         p_token1 => 'END_DATE',
         p_value1 => fnd_date.date_to_displaydate(p_effective_end_date),
         p_trans1 => 'N',
         p_token2 => 'START_DATE',
         p_value2 => fnd_date.date_to_displaydate(p_effective_start_date),
         p_trans2 => 'N');

      FND_MSG_PUB.Count_And_Get
         (p_count => x_msg_count,
          p_data => x_msg_data);

      WHEN e_cannot_create_definition THEN
         ROLLBACK TO create_object_pub;
         x_return_status := pc_ret_sts_error;
         x_object_id := NULL;
         fem_engines_pkg.put_message(p_app_name =>'FEM'
         ,p_msg_name =>'FEM_CANNOT_CREATE_DEF_ERR'
         ,p_token1 => 'DEFNAME'
         ,p_value1 => p_obj_def_name);

      FND_MSG_PUB.Count_And_Get
         (p_count => x_msg_count,
          p_data => x_msg_data);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO create_object_pub;
         x_return_status := pc_ret_sts_unexp_error;

         fem_engines_pkg.tech_message(p_severity => pc_log_level_unexpected,
         p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
         p_msg_name => 'FEM_BAD_P_API_VER_ERR'
         ,p_token1 => 'VALUE'
         ,p_value1 => p_api_version
         ,p_trans1 => 'N');

      FND_MSG_PUB.Count_And_Get
         (p_count => x_msg_count,
          p_data => x_msg_data);

      WHEN OTHERS THEN
      /* Unexpected exceptions */
         x_return_status := pc_ret_sts_unexp_error;
         gv_prg_msg   := SQLERRM;
         gv_callstack := dbms_utility.format_call_stack;

      /* Log the call stack and the Oracle error message to
      ** FND_LOG with the "unexpected exception" severity level. */

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_unexpected,
            p_module   => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
            p_msg_text => gv_prg_msg);

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_unexpected,
            p_module   => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
            p_msg_text => gv_callstack);

      /* Log the Oracle error message to the stack. */
         FEM_ENGINES_PKG.put_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UNEXPECTED_ERROR',
            P_TOKEN1 => 'ERR_MSG',
            P_VALUE1 => gv_prg_msg);
         ROLLBACK TO create_object_pub;

      FND_MSG_PUB.Count_And_Get
         (p_count => x_msg_count,
          p_data => x_msg_data);

END create_object;
/* ******************************************************************************/
PROCEDURE create_object_definition (x_object_definition_id OUT NOCOPY NUMBER,
                                    x_msg_count            OUT NOCOPY NUMBER,
                                    x_msg_data             OUT NOCOPY VARCHAR2,
                                    x_return_status        OUT NOCOPY VARCHAR2,
                                    p_api_version          IN  NUMBER,
                                    p_commit               IN  VARCHAR2,
                                    p_object_id            IN  NUMBER,
                                    p_effective_start_date IN  DATE,
                                    p_effective_end_date   IN  DATE,
                                    p_obj_def_name         IN  VARCHAR2,
                                    p_object_origin_code   IN VARCHAR2)
IS

c_api_name  CONSTANT VARCHAR2(30) := 'create_object_definition';
c_api_version  CONSTANT NUMBER := 1.0;
v_date_range_is_valid VARCHAR2(1);
v_rowid VARCHAR2(100);
v_approval_status_code VARCHAR2(30);
v_count NUMBER;
v_object_type_code FEM_OBJECT_TYPES.object_type_code%TYPE;

/* ==========================================================================
** This procedure creates a new Object Definition for the specified Object ID.
** It calls validate_obj_def_effdate to verify that the Start Date and
** End Date parameters for the new Object Definition do not conflict with
** existing Object Definition of the specified Object ID.
** This procedure will only create the definition if the user can write to
** the object.
** ==========================================================================*/
      BEGIN

      fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
      p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
      p_msg_text => 'Begin. P_OBJECT_ID: '||p_object_id||
      ' P_DESCRIPTION:'||p_obj_def_name||
      ' P_EFFECTIVE_START_DATE:'||p_effective_start_date||
      ' P_EFFECTIVE_END_DATE:'||p_effective_end_date||
      ' P_OBJ_DEF_NAME:'||p_obj_def_name||
      ' P_COMMIT: '||p_commit);

      /* Standard Start of API savepoint */
       SAVEPOINT  create_object_definition_pub;

      /* Standard call to check for call compatibility. */
      IF NOT FND_API.Compatible_API_Call (c_api_version,
                     p_api_version,
                     c_api_name,
                     pc_pkg_name)
      THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize API return status to success
      x_return_status := pc_ret_sts_success;

      -- Validate that the Object Origin exists in FND_LOOKUP_VALUES
      SELECT count(*)
      INTO v_count
      FROM fnd_lookup_values
      WHERE lookup_type = 'FEM_OBJECT_ORIGIN_DSC'
      AND lookup_code = p_object_origin_code;

      IF v_count = 0 THEN
         RAISE e_invalid_object_origin;
      END IF;  /* object_origin_code validation */

      -- Bug 4309949: ignore folder security for Undo objects
      SELECT object_type_code
      INTO v_object_type_code
      FROM fem_object_catalog_b
      WHERE object_id = p_object_id;

      IF v_object_type_code <> 'UNDO' THEN
        -- Validate that the user can write to the object
        -- User can only write to an object if they can write to the folder,
        -- and, either, the user object is not read only, or,
        -- the user created the object
        SELECT count(*)
        INTO v_count
        FROM fem_object_catalog_b o, fem_user_folders f
        WHERE o.object_id = p_object_id
        AND (o.object_access_code = 'W' OR o.created_by = pc_user_id)
        AND o.folder_id = f.folder_id
        AND f.user_id = pc_user_id
        AND f.write_flag = 'Y';

        IF v_count = 0 THEN
           RAISE e_cannot_write_to_object;
        END IF;  /* user can write to object validation */
      END IF;

      -- Validate effective date range
      validate_obj_def_effdate (p_object_id => p_object_id,
                                p_new_effective_start_date => p_effective_start_date,
                                p_new_effective_end_date => p_effective_end_date,
                                x_date_range_is_valid => v_date_range_is_valid,
                                x_msg_count => x_msg_count,
                                x_msg_data => x_msg_data);

      IF v_date_range_is_valid = 'Y' THEN
         SELECT fem_object_definition_id_seq.nextval
         INTO x_object_definition_id
         FROM dual;

         SELECT DECODE(t.workflow_enabled_flag,'Y','NEW','NOT_APPLICABLE')
         INTO v_approval_status_code
         FROM fem_object_types t, fem_object_catalog_b o
         WHERE o.object_id = p_object_id
         AND o.object_type_code = t.object_type_code;


         FEM_OBJECT_DEFINITION_PKG.INSERT_ROW (
            X_ROWID => v_rowid,
            X_OBJECT_DEFINITION_ID => x_object_definition_id,
            X_OBJECT_VERSION_NUMBER => pc_object_version_number,
            X_OBJECT_ID => p_object_id,
            X_EFFECTIVE_START_DATE => p_effective_start_date,
            X_EFFECTIVE_END_DATE => p_effective_end_date,
            X_OBJECT_ORIGIN_CODE => p_object_origin_code,
            X_APPROVAL_STATUS_CODE => v_approval_status_code,
            X_OLD_APPROVED_COPY_FLAG => 'N',
            X_OLD_APPROVED_COPY_OBJ_DEF_ID => null,
            X_APPROVED_BY => null,
            X_APPROVAL_DATE => null,
            X_DISPLAY_NAME => p_obj_def_name,
            X_DESCRIPTION => p_obj_def_name,
            X_CREATION_DATE => sysdate,
            X_CREATED_BY => pc_user_id,
            X_LAST_UPDATE_DATE => sysdate,
            X_LAST_UPDATED_BY => pc_user_id,
            X_LAST_UPDATE_LOGIN => null);

         fem_engines_pkg.put_message(p_app_name =>'FEM',
         p_msg_name =>'FEM_CREATED_DEF_TXT',
         p_token1 => 'OBJECT_DEFINITION_NAME',
         p_value1 => p_obj_def_name,
         p_trans1 => 'N');

      ELSE

         RAISE e_invalid_effective_date_range;

      END IF;

   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'End. X_RETURN_STATUS: '||x_return_status);

   FND_MSG_PUB.Count_And_Get
      (p_count => x_msg_count,
       p_data => x_msg_data);

   EXCEPTION
      WHEN e_invalid_object_origin THEN
         ROLLBACK TO create_object_definition_pub;
         x_return_status := pc_ret_sts_error;
         fem_engines_pkg.put_message(p_app_name =>'FEM'
         ,p_msg_name =>'FEM_INVALID_OBJECT_ORIGIN'
         ,p_token1 => 'OBJORIG'
         ,p_value1 => p_object_origin_code);

      FND_MSG_PUB.Count_And_Get
         (p_count => x_msg_count,
          p_data => x_msg_data);

      WHEN e_cannot_write_to_object THEN
         ROLLBACK TO create_object_definition_pub;
         x_return_status := pc_ret_sts_error;
         fem_engines_pkg.put_message(p_app_name =>'FEM'
         ,p_msg_name =>'FEM_CANNOT_WRITE_TO_OBJECT_ERR');

      FND_MSG_PUB.Count_And_Get
         (p_count => x_msg_count,
          p_data => x_msg_data);

      WHEN e_invalid_effective_date_range THEN
         ROLLBACK TO create_object_definition_pub;
         x_return_status := pc_ret_sts_error;
         fem_engines_pkg.put_message(p_app_name =>'FEM',
         p_msg_name =>'FEM_INVALID_DATE_RANGE_ERR');

         FND_MSG_PUB.Count_And_Get
         (p_count => x_msg_count,
          p_data => x_msg_data);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO create_object_definition_pub;
         x_return_status := pc_ret_sts_unexp_error;

         fem_engines_pkg.tech_message(p_severity => pc_log_level_unexpected,
         p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
         p_msg_name => 'FEM_BAD_P_API_VER_ERR',p_token1 => 'VALUE',
         p_value1 => p_api_version, p_trans1 => 'N');

      WHEN OTHERS THEN
      /* Unexpected exceptions */
         x_return_status := pc_ret_sts_unexp_error;
         gv_prg_msg   := SQLERRM;
         gv_callstack := dbms_utility.format_call_stack;

      /* Log the call stack and the Oracle error message to
      ** FND_LOG with the "unexpected exception" severity level. */

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_unexpected,
            p_module   => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
            p_msg_text => gv_prg_msg);

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_unexpected,
            p_module   => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
            p_msg_text => gv_callstack);

      /* Log the Oracle error message to the stack. */
         FEM_ENGINES_PKG.put_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UNEXPECTED_ERROR',
            P_TOKEN1 => 'ERR_MSG',
            P_VALUE1 => gv_prg_msg);
         ROLLBACK TO create_object_definition_pub;

      FND_MSG_PUB.Count_And_Get
         (p_count => x_msg_count,
          p_data => x_msg_data);

END create_object_definition;
/* ******************************************************************************/
PROCEDURE validate_obj_def_effdate (x_date_range_is_valid  OUT NOCOPY VARCHAR2,
                                    x_msg_count            OUT NOCOPY NUMBER,
                                    x_msg_data             OUT NOCOPY VARCHAR2,
                                    p_object_id            IN  NUMBER,
                                    p_new_effective_start_date IN DATE,
                                    p_new_effective_end_date   IN DATE)
IS

/* ==========================================================================
**  If new effective start date is between any of the start date/end date
**  of existing Object Definitions for the specified Object ID, then
**  x_date_range_is_valid = 'N'
**  If new effective end date is between any of the start date/end date
**  of existing Object Definitions for the specified Object ID, then
**  x_date_range_is_valid = 'N'
**  else
**     x_date_range_is_valid = 'Y'
**  end if.
** ==========================================================================*/

   CURSOR c1 IS
      SELECT object_definition_id, display_name, effective_start_date, effective_end_date
      FROM fem_object_definition_vl
      WHERE object_id = p_object_id;

   BEGIN
      x_date_range_is_valid := 'Y';


         IF p_new_effective_start_date >= p_new_effective_end_date THEN
            x_date_range_is_valid := 'N';
            fem_engines_pkg.put_message(p_app_name =>'FEM',
            p_msg_name =>'FEM_BR_END_LT_START_DATE_ERR',
            p_token1 => 'END_DATE',
            p_value1 => fnd_date.date_to_displaydate(p_new_effective_end_date),
            p_trans1 => 'N',
            p_token2 => 'START_DATE',
            p_value2 => fnd_date.date_to_displaydate(p_new_effective_start_date),
            p_trans2 => 'N');

         ELSE

         FOR object_def IN c1 LOOP

            --dbms_output.put_line('old start date = '||object_def.effective_start_date);
            --dbms_output.put_line('old end date = '||object_def.effective_end_date);
            --dbms_output.put_line('new start date = '||p_new_effective_start_date);
            --dbms_output.put_line('new end date = '||p_new_effective_end_date);

            IF ((p_new_effective_start_date >= object_def.effective_start_date AND
               p_new_effective_start_date <= object_def.effective_end_date)  OR
               (p_new_effective_end_date <= object_def.effective_end_date AND
               p_new_effective_end_date >= object_def.effective_start_date)) THEN
               x_date_range_is_valid := 'N';

                  fem_engines_pkg.put_message(p_app_name =>'FEM',
                  p_msg_name =>'FEM_BR_OVRLP_OBJ_DEF_ERR',
                  p_token1 => 'VERSION_NAME',
                  p_value1 => object_def.display_name,
                  p_trans1 => 'Y',
                  p_token2 => 'START_DATE',
                  p_value2 => fnd_date.date_to_displaydate(object_def.effective_start_date),
                  p_trans2 => 'N',
                  p_token3 => 'END_DATE',
                  p_value3 => fnd_date.date_to_displaydate(object_def.effective_end_date),
                  p_trans3 => 'N');

               EXIT;
             END IF;
         END LOOP;

      END IF;  /* effective date validation */

   /* Standard call to get message count and if count is 1, get message info. */
   FND_MSG_PUB.Count_And_Get
      (p_count => x_msg_count,
       p_data => x_msg_data);

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         x_date_range_is_valid := 'Y';

         FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data => x_msg_data);

END validate_obj_def_effdate;
/* ******************************************************************************/
PROCEDURE delete_object (x_msg_count            OUT NOCOPY NUMBER,
                         x_msg_data             OUT NOCOPY VARCHAR2,
                         x_return_status        OUT NOCOPY VARCHAR2,
                         p_api_version          IN  NUMBER,
                         p_commit               IN  VARCHAR2,
                         p_object_id            IN  NUMBER)

IS

c_api_name  CONSTANT VARCHAR2(30) := 'delete_object';
c_api_version  CONSTANT NUMBER := 1.0;
v_can_delete_object VARCHAR2(1);
v_count NUMBER;
v_object_type_code FEM_OBJECT_TYPES.object_type_code%TYPE;
v_object_name VARCHAR2(150);

BEGIN

   fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'Begin. P_OBJECT_ID: '||p_object_id||' P_COMMIT: '||p_commit);

   /* Standard Start of API savepoint */
    SAVEPOINT  delete_object_pub;

   /* Standard call to check for call compatibility. */
   IF NOT FND_API.Compatible_API_Call (c_api_version,
                  p_api_version,
                  c_api_name,
                  pc_pkg_name)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   /* Initialize API return status to success */
   x_return_status := pc_ret_sts_success;

   -- Bug 4309949: ignore folder security for Undo objects
   SELECT object_type_code
   INTO v_object_type_code
   FROM fem_object_catalog_b
   WHERE object_id = p_object_id;

   IF v_object_type_code <> 'UNDO' THEN
     -- Validate that the user can write to the Folder
     -- User can only delete if object if user can write to the
     -- folder, and either the object is not read only, or the
     -- user is the creator of the object.
     SELECT count(*)
     INTO v_count
     FROM fem_object_catalog_b o, fem_user_folders f
     WHERE o.object_id = p_object_id
     AND (o.object_access_code = 'W' OR o.created_by = pc_user_id)
     AND o.folder_id = f.folder_id
     AND f.user_id = pc_user_id
     AND f.write_flag = 'Y';

     IF v_count = 0 THEN
        RAISE e_cannot_write_to_object;
     END IF;  /* user can write to object validation */
   END IF;

   /* Check if can delete object. */
   fem_pl_pkg.can_delete_object (
      p_object_id => p_object_id,
      x_can_delete_obj => v_can_delete_object,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data);

   IF v_can_delete_object = 'T' THEN
      /* get the object name to display in the message */
      SELECT object_name
      INTO v_object_name
      FROM fem_object_catalog_vl
      WHERE object_id = p_object_id;

      DELETE fem_object_dependencies
         WHERE object_definition_id IN (
            SELECT object_definition_id
            FROM fem_object_definition_b
            WHERE object_id = p_object_id);

      DELETE fem_object_definition_tl
         WHERE object_id = p_object_id;

      DELETE fem_object_definition_b
         WHERE object_id = p_object_id;

      DELETE fem_object_catalog_tl
         WHERE object_id = p_object_id;

      DELETE fem_object_catalog_b
         WHERE object_id = p_object_id;

      fem_engines_pkg.put_message(p_app_name =>'FEM',
      p_msg_name => 'FEM_DELETED_OBJ_TXT',p_token1 => 'OBJECT_NAME',
      p_value1 => v_object_name, p_trans1 => 'N');

   ELSE
   /* (v_can_delete_object = 'F') */
      RAISE e_cannot_delete_object;

   END IF;

   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
   p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'End. X_RETURN_STATUS: '||x_return_status);

   /* Standard call to get message count and if count is 1, get message info. */
   FND_MSG_PUB.Count_And_Get
      (p_count => x_msg_count,
       p_data => x_msg_data);

   EXCEPTION
      WHEN e_cannot_delete_object THEN
         x_return_status := pc_ret_sts_error;
         fem_engines_pkg.put_message(p_app_name =>'FEM',
         p_msg_name => 'FEM_CANNOT_DELETE_OBJ_ERR'
         ,p_token1 => 'OBJECT'
         ,p_value1 => p_object_id
         ,p_trans1 => 'N');

      WHEN e_cannot_write_to_object THEN
         ROLLBACK TO delete_object_pub;
         x_return_status := pc_ret_sts_error;
         fem_engines_pkg.put_message(p_app_name =>'FEM'
         ,p_msg_name =>'FEM_CANNOT_WRITE_TO_OBJECT_ERR');

      FND_MSG_PUB.Count_And_Get
         (p_count => x_msg_count,
          p_data => x_msg_data);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO delete_object_pub;
         x_return_status := pc_ret_sts_unexp_error;

         fem_engines_pkg.tech_message(p_severity => pc_log_level_unexpected,
         p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
         p_msg_name => 'FEM_BAD_P_API_VER_ERR'
         ,p_token1 => 'VALUE'
         ,p_value1 => p_api_version
         ,p_trans1 => 'N');

      WHEN OTHERS THEN
      /* Unexpected exceptions */
         x_return_status := pc_ret_sts_unexp_error;
         gv_prg_msg := SQLERRM;
         gv_callstack := dbms_utility.format_call_stack;

      /* Log the call stack and the Oracle error message to
      ** FND_LOG with the "unexpected exception" severity level. */

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_unexpected,
            p_module   => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
            p_msg_text => gv_prg_msg);

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_unexpected,
            p_module   => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
            p_msg_text => gv_callstack);

      /* Log the Oracle error message to the stack. */
         FEM_ENGINES_PKG.put_message(p_app_name =>'FEM',
            p_msg_name => 'FEM_UNEXPECTED_ERROR',
            P_TOKEN1 => 'ERR_MSG',
            P_VALUE1 => gv_prg_msg);
         ROLLBACK TO delete_object_pub;

      FND_MSG_PUB.Count_And_Get
         (p_count => x_msg_count,
          p_data => x_msg_data);

END delete_object;
/* ******************************************************************************/

END fem_object_catalog_util_pkg;

/
