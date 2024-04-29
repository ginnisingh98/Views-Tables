--------------------------------------------------------
--  DDL for Package Body FEM_DIM_SNAPSHOT_ENG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_DIM_SNAPSHOT_ENG_PKG" AS
--$Header: fem_dimsnap_eng.plb 120.0 2005/10/19 19:27:27 appldev noship $
/*==========================================================================+
 |    Copyright (c) 1997 Oracle Corporation, Redwood Shores, CA, USA        |
 |                         All rights reserved.                             |
 +==========================================================================+
 | FILENAME
 |
 |    fem_dim_snapshot_eng.plb
 |
 | NAME fem_dim_snapshot_eng_pkg
 |
 | DESCRIPTION
 |
 |   Package body for fem_dim_snapshot_eng_pkg.
 |   For more information about the purpose of this package, please refer
 |   to the package spec.
 |
 | HISTORY
 |
 |    29-JUN-05  Created
 |
 |
 +=========================================================================*/

-----------------------
-- Package Constants --
-----------------------
pc_pkg_name               CONSTANT VARCHAR2(30) := 'fem_object_catalog_util_pkg';
pc_log_level_unexpected   CONSTANT  NUMBER  := fnd_log.level_unexpected;
pc_log_level_1            CONSTANT  NUMBER  := fnd_log.level_statement;
pc_log_level_2            CONSTANT  NUMBER  := fnd_log.level_procedure;
pc_log_level_3            CONSTANT  NUMBER  := fnd_log.level_event;
pc_log_level_4            CONSTANT  NUMBER  := fnd_log.level_exception;
pc_log_level_5            CONSTANT  NUMBER  := fnd_log.level_error;


-----------------------
-- Package Variables --
-----------------------
gv_prg_msg      VARCHAR2(2000);
gv_callstack    VARCHAR2(2000);



PROCEDURE Validate_OA_Params (
   p_init_msg_list   IN VARCHAR2,
   p_commit          IN VARCHAR2,
   p_encoded         IN VARCHAR2,
   x_return_status   OUT NOCOPY VARCHAR2
);



PROCEDURE Validate_OA_Params (
   p_init_msg_list   IN VARCHAR2,
   p_commit          IN VARCHAR2,
   p_encoded         IN VARCHAR2,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
   e_bad_p_init_msg_list   EXCEPTION;
   e_bad_p_encoded         EXCEPTION;


BEGIN

x_return_status := c_success;

----------------------------------------
-- Validate Input params
----------------------------------------
-- NOTE:  The engine ignores the value in p_commit
-- since the it always commits by dimension in order
-- to prevent rollback errors

CASE p_init_msg_list
   WHEN c_false THEN NULL;
   WHEN c_true THEN
      FND_MSG_PUB.Initialize;
   ELSE RAISE e_bad_p_init_msg_list;
END CASE;

CASE p_encoded
   WHEN c_false THEN NULL;
   WHEN c_true THEN NULL;
   ELSE RAISE e_bad_p_encoded;
END CASE;


EXCEPTION
   WHEN e_bad_p_init_msg_list THEN
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_BAD_P_INIT_MSG_LIST_ERR');
      x_return_status := c_error;

   WHEN e_bad_p_encoded THEN
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_BAD_P_ENCODED_ERR');
      x_return_status := c_error;



END Validate_OA_Params;


/*==========================================================================+
 |    Copyright (c) 1997 Oracle Corporation, Redwood Shores, CA, USA        |
 |                         All rights reserved.                             |
 +==========================================================================+
 |
 | PROCEDURE NAME:  Main
 |
 |   This is the procedure called to launch the Dimension Snapshot
 |   Engine.  It performs the following:
 |
 |     1. Validates the input paramters
 |     2. Deletes all previously captured version TL information for the
 |        same created_by_object_id
 |     3. Inserts the version TL information into the
 |        FEM_DSNP_DIM_ATTR_VRS_TL table for all shared versions in the system.
 |        As of FEM.D, there is no "personal version" concept (i.e,. all versions
 |        are shared), however the dynamic SQL filters on personal_Flag = 'N'
 |        just in case for future implementation of such a feature.
 |     4. Deletes all previously captured attribute assignments from the
 |        target DNSP ATTR table for the same created_by_object_id
 |     5. Fetches the list of all attributed dimensions (with target snapshot
 |        tables into a cursor
 |     6. For each fetched dimension it inserts all attribute assignment rows
 |        for shared dimension members into the target DNSP ATTR table.  It
 |        commits after each dimension.
 |
 | HISTORY
 |
 |    29-JUN-05  Created
 |
 |
 +=========================================================================*/

PROCEDURE Main (
   x_return_status                OUT NOCOPY VARCHAR2,
   x_msg_count                    OUT NOCOPY NUMBER,
   x_msg_data                     OUT NOCOPY VARCHAR2,
   p_api_version                   IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list                 IN VARCHAR2   DEFAULT c_false,
   p_commit                        IN VARCHAR2   DEFAULT c_true,
   p_encoded                       IN VARCHAR2   DEFAULT c_true,
   p_dim_snapshot_obj_def_id       IN NUMBER
)

IS
   c_api_name  CONSTANT VARCHAR2(30) := 'main';

   v_object_id          NUMBER;  -- Dim Snapshot object_id of the obj_def_id parm
   v_count              NUMBER;
   v_sysdate            DATE;  -- tracks the sysdate so that all records get
                               -- the exact same creation_date/last_update_date

   -- variables for dynamic sql statements
   v_sql_delete_stmt      VARCHAR2(4000);
   v_sql_insert_stmt      VARCHAR2(4000);
   v_sql_vers_delete_stmt VARCHAR2(4000);
   v_sql_vers_insert_stmt VARCHAR2(4000);

   e_invalid_obj_def_id     EXCEPTION;
   e_invalid_dim           EXCEPTION;

   CURSOR c1_attr_dims IS
   SELECT X.dimension_id
      , X.dimension_varchar_label
      , X.value_set_required_flag
      , X.member_col
      , X.attribute_table_name
      , X.dsnp_attribute_table_name
      , X.member_b_table_name
   FROM fem_xdim_dimensions_vl X, fem_dsnp_rule_dims R
   WHERE X.attribute_table_name is not null
   AND X.dsnp_attribute_table_name is not null
   AND X.dimension_id = R.dimension_id
   AND R.dim_snapshot_obj_def_id = p_dim_snapshot_obj_def_id
   ORDER BY dimension_id;


BEGIN

x_return_status := c_success;

/* Standard call to check for call compatibility. */
  IF NOT FND_API.Compatible_API_Call (c_api_version,
               p_api_version,
               c_api_name,
               pc_pkg_name)
  THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

-- Validate the OA framework parameters, but ignore p_commit
-- since the engine always performs a commit after each dimension
Validate_OA_Params (
   p_init_msg_list => p_init_msg_list,
   p_commit => p_commit,
   p_encoded => p_encoded,
   x_return_status => x_return_status);

IF (x_return_status <> c_success)
THEN
   FND_MSG_PUB.Count_and_Get(
      p_encoded => c_false,
      p_count => x_msg_count,
      p_data => x_msg_data);
   RETURN;
END IF;

-- Checking if the specified object_definition is a Dimension Snapshot rule def
-- and getting the object_id for it
SELECT O.object_id
INTO v_object_id
FROM fem_object_definition_b D, fem_object_catalog_b O
WHERE D.object_definition_id = p_dim_snapshot_obj_def_id
AND D.object_id = O.object_id
AND O.object_type_code = 'DIMENSION_SNAPSHOT';

IF v_count = 0 THEN
   RAISE e_invalid_obj_def_id;
END IF;


-- get sysdate for insert time
SELECT sysdate
INTO v_sysdate
FROM dual;

-- build the delete statement for the target DSNP VERS table
v_sql_vers_delete_stmt :=
   'DELETE FROM fem_dsnp_dim_attr_vrs_tl '||
   ' WHERE created_by_object_id = '||v_object_id;

FEM_ENGINES_PKG.Tech_Message
  (p_severity => pc_log_level_1,
   p_module   => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name||'.v_sql_vers_delete_stmt',
   p_msg_text => v_sql_vers_delete_stmt);


-- build the insert statement for the DSNP VERS table
	v_sql_vers_insert_stmt :=
       'INSERT INTO fem_dsnp_dim_attr_vrs_tl '||
       '(created_by_object_id'||
       ', version_id'||
       ', language'||
       ', source_lang'||
       ', version_name'||
       ', description'||
       ', created_by'||
       ', creation_date'||
       ', last_updated_by'||
       ', last_update_date'||
       ', last_update_login)'||
       ' SELECT '||v_object_id||
       ', V.version_id'||
       ', V.language'||
       ', V.source_lang'||
       ', V.version_name'||
       ', V.description'||
       ' ,'||c_user_id||
       ' ,:b_v_sysdate'||
       ' ,'||c_user_id||
       ' ,:b_v_sysdate'||
       ' ,'||c_login_id||
       ' FROM fem_dim_attr_Versions_tl V, fem_dsnp_rule_dims R'||
       ', fem_dim_attributes_b A ,fem_dim_attr_versions_b VB'||
       ' WHERE VB.default_version_flag = ''Y'''||
       ' AND VB.personal_flag = ''N'''||
       ' AND V.version_id = VB.version_id'||
       ' AND VB.attribute_id = A.attribute_id'||
       ' AND A.dimension_id = R.dimension_id'||
       ' AND R.dim_snapshot_obj_def_id = '||p_dim_snapshot_obj_def_id;

FEM_ENGINES_PKG.Tech_Message
  (p_severity => pc_log_level_1,
   p_module   => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name||'.v_sql_vers_insert_stmt',
   p_msg_text => v_sql_vers_insert_stmt);

-- Delete/Insert the version data for FEM_DSNP_DIM_ATTR_VERS_TL
   EXECUTE IMMEDIATE v_sql_vers_delete_stmt;
   COMMIT;

FEM_ENGINES_PKG.Tech_Message
  (p_severity => pc_log_level_1,
   p_module   => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'after version delete');

   EXECUTE IMMEDIATE v_sql_vers_insert_stmt
     USING v_sysdate
          ,v_sysdate;
   COMMIT;

FEM_ENGINES_PKG.Tech_Message
  (p_severity => pc_log_level_1,
   p_module   => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'after version insert');


FOR dim IN c1_attr_dims LOOP

   -- build delete statement for the target DNSP ATTR table
   v_sql_delete_stmt :=
      'DELETE FROM '||dim.dsnp_attribute_table_name||
      ' WHERE created_by_object_id = '||v_object_id;


   -- build insert statement for the target DSNP ATTR table
   IF dim.value_set_required_flag = 'Y' THEN
      v_sql_insert_stmt :=
         'INSERT INTO '||dim.dsnp_attribute_table_name||
         ' (created_by_object_id'||
         ' ,attribute_id'||
         ' ,version_id'||
         ' ,'||dim.member_col||
         ' ,value_set_id'||
         ' ,dim_attribute_numeric_member'||
         ' ,dim_attribute_value_set_id'||
         ' ,dim_attribute_varchar_member'||
         ' ,number_assign_value'||
         ' ,varchar_assign_value'||
         ' ,date_assign_value'||
         ' ,created_by'||
         ' ,creation_date'||
         ' ,last_updated_by'||
         ' ,last_update_date'||
         ' ,last_update_login)'||
         ' SELECT '||v_object_id||
         ' ,A.attribute_id'||
         ' ,A.version_id'||
         ' ,A.'||dim.member_col||
         ' ,A.value_set_id'||
         ' ,A.dim_attribute_numeric_member'||
         ' ,A.dim_attribute_value_set_id'||
         ' ,A.dim_attribute_varchar_member'||
         ' ,A.number_assign_value'||
         ' ,A.varchar_assign_value'||
         ' ,A.date_assign_value'||
         ' ,'||c_user_id||
         ' ,:b_v_sysdate'||
         ' ,'||c_user_id||
         ' ,:b_v_sysdate'||
         ' ,'||c_login_id||
         ' FROM '||dim.attribute_table_name||' A'||
         ', fem_dim_attr_versions_b V'||
         ','||dim.member_b_table_name||' B'||
         ' WHERE V.version_id = A.version_id'||
         ' AND V.default_version_flag = ''Y'''||
         ' AND A.'||dim.member_col||' = B.'||dim.member_col||
         ' AND A.value_set_id = B.value_set_id'||
         ' AND B.personal_flag = ''N''';
   ELSE
      v_sql_insert_stmt :=
         'INSERT INTO '||dim.dsnp_attribute_table_name||
         '(created_by_object_id'||
         ' ,attribute_id'||
         ' ,version_id'||
         ' ,'||dim.member_col||
         ' ,dim_attribute_numeric_member'||
         ' ,dim_attribute_value_set_id'||
         ' ,dim_attribute_varchar_member'||
         ' ,number_assign_value'||
         ' ,varchar_assign_value'||
         ' ,date_assign_value'||
         ' ,created_by'||
         ' ,creation_date'||
         ' ,last_updated_by'||
         ' ,last_update_date'||
         ' ,last_update_login)'||
         ' SELECT '||v_object_id||
         ' ,A.attribute_id'||
         ' ,A.version_id'||
         ' ,A.'||dim.member_col||
         ' ,A.dim_attribute_numeric_member'||
         ' ,A.dim_attribute_value_set_id'||
         ' ,A.dim_attribute_varchar_member'||
         ' ,A.number_assign_value'||
         ' ,A.varchar_assign_value'||
         ' ,A.date_assign_value'||
         ' ,'||c_user_id||
         ' ,:b_v_sysdate'||
         ' ,'||c_user_id||
         ' ,:b_v_sysdate'||
         ' ,'||c_login_id||
         ' FROM '||dim.attribute_table_name||' A'||
         ', fem_dim_attr_versions_b V'||
         ','||dim.member_b_table_name||' B'||
         ' WHERE V.version_id = A.version_id'||
         ' AND V.default_version_flag = ''Y'''||
         ' AND A.'||dim.member_col||' = B.'||dim.member_col||
         ' AND B.personal_flag = ''N''';
   END IF;

FEM_ENGINES_PKG.Tech_Message
  (p_severity => pc_log_level_1,
   p_module   => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name||'.v_sql_insert_stmt',
   p_msg_text => v_sql_insert_stmt);


  -- delete from the target table for the object_id
   EXECUTE IMMEDIATE v_sql_delete_stmt;
   COMMIT;

FEM_ENGINES_PKG.Tech_Message
  (p_severity => pc_log_level_1,
   p_module   => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
   p_msg_text => 'after attribute delete');


   -- insert attr rows into the target table
   EXECUTE IMMEDIATE v_sql_insert_stmt
      USING v_sysdate
        ,v_sysdate;
   COMMIT;


END LOOP;

EXCEPTION

   WHEN e_invalid_obj_def_id THEN

      x_return_status := c_error;
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_DSNP_INVALID_OBJ_DEF',
         p_token1 => 'OBJDEF_ID',
         p_value1 => p_dim_snapshot_obj_def_id);
         x_return_status := c_error;

      FND_MSG_PUB.Count_And_Get
         (p_count => x_msg_count,
          p_data => x_msg_data);

      WHEN OTHERS THEN
      /* Unexpected exceptions */
         x_return_status := c_error;
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



END Main;

END fem_dim_snapshot_eng_pkg;

/
