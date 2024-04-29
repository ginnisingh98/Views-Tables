--------------------------------------------------------
--  DDL for Package Body FEM_DIM_SNAPSHOT_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_DIM_SNAPSHOT_UTIL_PKG" AS
--$Header: fem_dimsnap_utl.plb 120.0 2005/10/19 19:25:45 appldev noship $
/*==========================================================================+
 |    Copyright (c) 1997 Oracle Corporation, Redwood Shores, CA, USA        |
 |                         All rights reserved.                             |
 +==========================================================================+
 | FILENAME
 |
 |    fem_dim_snapshot_utl.plb
 |
 | NAME fem_dim_snapshot_utl_pkg
 |
 | DESCRIPTION
 |
 |   Package body for fem_dim_snapshot_utl_pkg.
 |   For more information about the purpose of this package, please refer
 |   to the package spec.
 |
 | HISTORY
 |
 |    1-JUL-05  Created
 |
 |
 +=========================================================================*/

-----------------------
-- Package Constants --
-----------------------
pc_pkg_name            CONSTANT VARCHAR2(30) := 'fem_object_catalog_util_pkg';
pc_log_level_unexpected   CONSTANT  NUMBER  := fnd_log.level_unexpected;

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
   e_bad_p_api_ver         EXCEPTION;
   e_bad_p_init_msg_list   EXCEPTION;
   e_bad_p_commit          EXCEPTION;
   e_bad_p_encoded         EXCEPTION;
BEGIN

x_return_status := c_success;

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

CASE p_commit
   WHEN c_false THEN NULL;
   WHEN c_true THEN NULL;
   ELSE RAISE e_bad_p_commit;
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

   WHEN e_bad_p_commit THEN
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_BAD_P_COMMIT_ERR');
      x_return_status := c_error;

END Validate_OA_Params;


/*===========================================================================+
 | PROCEDURE
 |              ADD_DIMENSION
 |
 | DESCRIPTION
 |                 Procedure for adding a dimension to a Dimension Snapshot
 |                 Rule definition
 |
 | SCOPE - PUBLIC
 |
 | NOTES
 |    If the dimension to be added already exists in the rule definition,
 |    the procedure does nothing (i.e., - it still returns success).
 |
 |
 | MODIFICATION HISTORY
 |    Rob Flippo   01-JUL-05  Created
 +===========================================================================*/


PROCEDURE Add_Dimension (
   x_return_status             OUT NOCOPY VARCHAR2,
   x_msg_count                 OUT NOCOPY NUMBER,
   x_msg_data                  OUT NOCOPY VARCHAR2,
   p_api_version               IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list             IN VARCHAR2   DEFAULT c_false,
   p_commit                    IN VARCHAR2   DEFAULT c_false,
   p_encoded                   IN VARCHAR2   DEFAULT c_true,
   p_dim_snapshot_obj_def_id   IN NUMBER,
   p_dimension_varchar_label   IN VARCHAR2
)

IS

   e_invalid_dim        EXCEPTION;
   e_invalid_obj_def_id EXCEPTION;
   e_invalid_oa_parms   EXCEPTION;
   v_count              NUMBER;
   v_dimension_id       NUMBER;

   c_api_name  CONSTANT VARCHAR2(30) := 'add_dimension';


BEGIN

  /* Standard Start of API savepoint */
  SAVEPOINT  add_dimension;

x_return_status := c_success;
/* Standard call to check for call compatibility. */
  IF NOT FND_API.Compatible_API_Call (c_api_version,
               p_api_version,
               c_api_name,
               pc_pkg_name)
  THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;


Validate_OA_Params (
   p_init_msg_list => p_init_msg_list,
   p_commit => p_commit,
   p_encoded => p_encoded,
   x_return_status => x_return_status);

IF (x_return_status <> c_success) THEN
   RAISE e_invalid_oa_parms;
END IF;

-- Checking if the specified object_definition is a Dimension Snapshot rule def
SELECT count(*)
INTO v_count
FROM fem_object_definition_b D, fem_object_catalog_b O
WHERE D.object_definition_id = p_dim_snapshot_obj_def_id
AND D.object_id = O.object_id
AND O.object_type_code = 'DIMENSION_SNAPSHOT';

IF v_count = 0 THEN
   RAISE e_invalid_obj_def_id;
END IF;

-- Checking if the dimension passed in is an actual dimension in fem_xdim_dimensions
BEGIN
   SELECT dimension_id
   INTO v_dimension_id
   FROM fem_xdim_dimensions_vl
   WHERE dimension_varchar_label = p_dimension_varchar_label;
EXCEPTION
   WHEN no_data_found THEN raise e_invalid_dim;
END;

BEGIN
   INSERT INTO fem_dsnp_rule_dims (
      DIM_SNAPSHOT_OBJ_DEF_ID
     ,DIMENSION_ID
     ,CREATION_DATE
     ,CREATED_BY
     ,LAST_UPDATED_BY
     ,LAST_UPDATE_DATE
     ,LAST_UPDATE_LOGIN   )
   SELECT p_dim_snapshot_obj_def_id
         ,v_dimension_id
         ,sysdate
         ,c_user_id
         ,c_user_id
         ,sysdate
         ,c_login_id
   FROM dual;
EXCEPTION
   WHEN dup_val_on_index THEN null;
END;

IF FND_API.To_Boolean( p_commit ) THEN
   COMMIT WORK;
END IF;


EXCEPTION
   WHEN e_invalid_oa_parms THEN
      ROLLBACK TO add_dimension;
      x_return_status := c_error;

      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);

   WHEN e_invalid_obj_def_id THEN
      ROLLBACK TO add_dimension;
      x_return_status := c_error;
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_DSNP_INVALID_OBJ_DEF',
         p_token1 => 'OBJDEF_ID',
         p_value1 => p_dim_snapshot_obj_def_id);
         x_return_status := c_error;

      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);

   WHEN e_invalid_dim THEN
      ROLLBACK TO add_dimension;
      x_return_status := c_error;
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_XDIM_INVALID_DIM',
         p_token1 => 'LABEL',
         p_value1 => p_dimension_varchar_label);

         x_return_status := c_error;

      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO add_dimension;
         x_return_status := c_error;

         fem_engines_pkg.tech_message(p_severity => pc_log_level_unexpected,
         p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
         p_msg_name => 'FEM_BAD_P_API_VER_ERR'
         ,p_token1 => 'VALUE'
         ,p_value1 => p_api_version
         ,p_trans1 => 'N');

      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
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
         ROLLBACK TO add_dimension;

      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);

END Add_Dimension;

/*===========================================================================+
 | PROCEDURE
 |              REMOVE_DIMENSION
 |
 | DESCRIPTION
 |                 Procedure for removing a dimension to a Dimension Snapshot
 |                 Rule definition
 |
 | SCOPE - PUBLIC
 |
 | NOTES
 |    If the dimension to be removed doesn't exist in the rule definition,
 |    the procedure does nothing (i.e., - it still returns success).
 |
 | MODIFICATION HISTORY
 |    Rob Flippo   01-JUL-05  Created
 +===========================================================================*/

PROCEDURE Remove_Dimension (
   x_return_status             OUT NOCOPY VARCHAR2,
   x_msg_count                 OUT NOCOPY NUMBER,
   x_msg_data                  OUT NOCOPY VARCHAR2,
   p_api_version               IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list             IN VARCHAR2   DEFAULT c_false,
   p_commit                    IN VARCHAR2   DEFAULT c_false,
   p_encoded                   IN VARCHAR2   DEFAULT c_true,
   p_dim_snapshot_obj_def_id   IN NUMBER,
   p_dimension_varchar_label   IN VARCHAR2
)

IS

   e_invalid_dim        EXCEPTION;
   e_invalid_obj_def_id EXCEPTION;
   e_invalid_oa_parms   EXCEPTION;
   v_count              NUMBER;
   v_dimension_id       NUMBER;

   c_api_name  CONSTANT VARCHAR2(30) := 'remove_dimension';



BEGIN
  /* Standard Start of API savepoint */
  SAVEPOINT remove_dimension;


x_return_status := c_success;

/* Standard call to check for call compatibility. */
  IF NOT FND_API.Compatible_API_Call (c_api_version,
               p_api_version,
               c_api_name,
               pc_pkg_name)
  THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;


Validate_OA_Params (
   p_init_msg_list => p_init_msg_list,
   p_commit => p_commit,
   p_encoded => p_encoded,
   x_return_status => x_return_status);

IF (x_return_status <> c_success) THEN
   RAISE e_invalid_oa_parms;
END IF;

-- Checking if the specified object_definition is a Dimension Snapshot rule def
SELECT count(*)
INTO v_count
FROM fem_object_definition_b D, fem_object_catalog_b O
WHERE D.object_definition_id = p_dim_snapshot_obj_def_id
AND D.object_id = O.object_id
AND O.object_type_code = 'DIMENSION_SNAPSHOT';

IF v_count = 0 THEN
   RAISE e_invalid_obj_def_id;
END IF;

-- Checking if the dimension passed in is an actual dimension in fem_xdim_dimensions
BEGIN
   SELECT dimension_id
   INTO v_dimension_id
   FROM fem_xdim_dimensions_vl
   WHERE dimension_varchar_label = p_dimension_varchar_label;
EXCEPTION
   WHEN no_data_found THEN raise e_invalid_dim;
END;

DELETE FROM fem_dsnp_rule_dims
WHERE dim_snapshot_obj_def_id = p_dim_snapshot_obj_def_id
AND dimension_id = v_dimension_id;

IF FND_API.To_Boolean( p_commit ) THEN
   COMMIT WORK;
END IF;

EXCEPTION
   WHEN e_invalid_oa_parms THEN
      ROLLBACK TO remove_dimension;
      x_return_status := c_error;

      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);

   WHEN e_invalid_obj_def_id THEN
      ROLLBACK TO remove_dimension;
      x_return_status := c_error;
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_DSNP_INVALID_OBJ_DEF',
         p_token1 => 'OBJDEF_ID',
         p_value1 => p_dim_snapshot_obj_def_id);
         x_return_status := c_error;

      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);

   WHEN e_invalid_dim THEN
      ROLLBACK TO remove_dimension;
      x_return_status := c_error;
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_XDIM_INVALID_DIM',
         p_token1 => 'LABEL',
         p_value1 => p_dimension_varchar_label);

      x_return_status := c_error;

      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
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
         ROLLBACK TO remove_dimension;

      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);

END Remove_Dimension;


END fem_dim_snapshot_util_pkg;

/
