--------------------------------------------------------
--  DDL for Package Body FEM_FOLDERS_UTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_FOLDERS_UTL_PKG" AS
/* $Header: fem_folders_utl.plb 120.2 2005/07/26 14:10:30 appldev ship $ */

-- ***********************
-- Package constants
-- ***********************
g_pkg_name CONSTANT VARCHAR2(30) := 'fem_folders_utl_pkg';

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

-- ******************************************************************************
PROCEDURE get_personal_folder (p_user_id IN NUMBER, p_folder_id OUT NOCOPY NUMBER) AS

-- ==========================================================================
-- Check if folder exists which was created by the user with the
-- same name as the user name.  If the folder does not exist,
-- create the folder.
-- ==========================================================================

v_user_name VARCHAR2(30);
v_last_update_login NUMBER := FND_GLOBAL.LOGIN_ID;

BEGIN
   -- Retrieve user name
   SELECT user_name INTO v_user_name
      FROM fnd_user
      WHERE user_id = p_user_id;

   -- Retrieve personal folder
   SELECT folder_id INTO p_folder_id
      FROM fem_folders_vl
      WHERE created_by = p_user_id
      AND upper(folder_name) = UPPER(v_user_name);

   EXCEPTION WHEN NO_DATA_FOUND THEN

      IF v_user_name IS NOT NULL THEN
         -- Create new personal folder since one does not exist
         SELECT fem_folder_id_seq.nextval INTO p_folder_id FROM DUAL;

         INSERT INTO fem_folders_b (folder_id, object_version_number,
            created_by, creation_date, last_updated_by,
            last_update_date, last_update_login) VALUES
            (p_folder_id, 1, p_user_id, sysdate, p_user_id, sysdate, v_last_update_login);

         INSERT INTO fem_folders_tl (folder_id, folder_name, description,
            created_by, creation_date, last_updated_by,
            last_update_date, last_update_login, language, source_lang)
            SELECT
            p_folder_id, v_user_name, v_user_name,
            p_user_id, sysdate, p_user_id, sysdate, v_last_update_login,
            l.language_code, userenv('LANG')
            FROM fnd_languages l
            WHERE l.installed_flag IN ('I', 'B')
            AND NOT EXISTS
              (SELECT NULL
              FROM fem_folders_tl t
              WHERE t.folder_id = p_folder_id
              AND t.language = l.language_code);

          INSERT INTO fem_user_folders (folder_id, user_id, write_flag,
            object_version_number, created_by, creation_date, last_updated_by,
            last_update_date, last_update_login) VALUES
            (p_folder_id, p_user_id, 'Y',1, p_user_id, sysdate, p_user_id,
            sysdate, v_last_update_login);

         COMMIT;

         fem_engines_pkg.tech_message(p_severity => 3,
         p_module => 'fem.plsql.fem_folder_utl_pkg.get_default_folder',
         p_msg_text => 'Created personal folder for USER_ID: '||p_user_id||' FOLDER_ID: '||p_folder_id||' FOLDER_NAME: '||v_user_name);

      END IF;

END get_personal_folder;

-- ******************************************************************************
PROCEDURE assign_user_to_folder (p_api_version      IN  NUMBER,
                                 p_commit           IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
                                 p_user_id          IN NUMBER DEFAULT FND_GLOBAL.USER_ID,
                                 p_folder_id        IN NUMBER,
                                 p_write_flag       IN VARCHAR2 DEFAULT 'N',
                                 x_msg_count        OUT NOCOPY NUMBER,
                                 x_msg_data         OUT NOCOPY VARCHAR2,
                                 x_return_status    OUT NOCOPY VARCHAR2) AS

-- ==========================================================================
-- Assign user to a folder.
-- ==========================================================================
v_last_update_login NUMBER := FND_GLOBAL.Login_Id;
l_api_name  CONSTANT VARCHAR2(30) := 'assign_user_to_folder';
l_api_version  CONSTANT NUMBER := 1.0;

BEGIN

   fem_engines_pkg.tech_message(p_severity => c_log_level_1,
   p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
   p_msg_text => 'Begin. P_USER_ID: '||p_user_id||
   ' P_FOLDER_ID:'||p_folder_id||
   ' P_WRITE_FLAG:'||p_write_flag||' P_COMMIT:'||p_commit);

   -- Standard Start of API savepoint
    SAVEPOINT  assign_user_to_folder_pub;

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

   --  Assign user to folder. (The select statement serves as a validation
   --  to ensure that the folder is valid).
   INSERT INTO fem_user_folders (folder_id, user_id, write_flag,
      object_version_number, created_by, creation_date, last_updated_by,
      last_update_date, last_update_login)
      SELECT
      folder_id, p_user_id, p_write_flag,
      1, p_user_id, sysdate, p_user_id,
      sysdate, v_last_update_login
      FROM fem_folders_vl
      WHERE folder_id = p_folder_id;

   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   fem_engines_pkg.tech_message(p_severity => c_log_level_1,
   p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
   p_msg_text => 'End. X_RETURN_STATUS: '||x_return_status);

   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
         fem_engines_pkg.tech_message(p_severity => c_log_level_3,
         p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
         p_msg_text => 'End. User already assigned to folder. X_RETURN_STATUS: '||x_return_status);

      WHEN NO_DATA_FOUND THEN
         ROLLBACK TO assign_user_to_folder_pub;
         x_return_status := g_ret_sts_error;

         fem_engines_pkg.put_message(p_app_name =>'FEM',
         p_msg_name =>'FEM_FOLDER_DOES_NOT_EXIST_ERR',
         p_token1 => 'FOLDER_ID',
         p_value1 => p_folder_id,
         p_trans1 => 'N');

         fem_engines_pkg.tech_message(p_severity => c_log_level_3,
         p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
         p_msg_name =>'FEM_FOLDER_DOES_NOT_EXIST_ERR',
         p_token1 => 'FOLDER_ID',
         p_value1 => p_folder_id,
         p_trans1 => 'N');

         -- Standard call to get message count and if count is 1, get message info.
         FND_MSG_PUB.Count_And_Get
            (p_count => x_msg_count,
             p_data => x_msg_data);

         fem_engines_pkg.tech_message(p_severity => c_log_level_3,
         p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
         p_msg_text => 'End. X_RETURN_STATUS: '||x_return_status);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO assign_user_to_folder_pub;
         x_return_status := g_ret_sts_unexp_error;

         fem_engines_pkg.tech_message(p_severity => c_log_level_2,
         p_module => 'fem.plsql.'||g_pkg_name||'.'||l_api_name,
         p_msg_text => 'Incompatible API call made to '||g_pkg_name||'.'||
         l_api_name||' version: '||l_api_version);


END assign_user_to_folder;

-- ******************************************************************************
END fem_folders_utl_pkg;

/
