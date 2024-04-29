--------------------------------------------------------
--  DDL for Package Body FEM_DIM_ATTRIBUTES_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_DIM_ATTRIBUTES_UTIL_PKG" AS
/* $Header: fem_dimattr_utl.plb 120.3 2006/08/16 22:10:06 rflippo ship $ */
/*=======================================================================+
Copyright (c) 1995 Oracle Corporation Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 | FILENAME
 |   fem_dimattr_utl.plb
 |
 | DESCRIPTION
 |   Creates body for package used to create user defined attributes
 |
 | MODIFICATION HISTORY
 |   Robert Flippo       05/27/2004 Created
 |
 |   Robert Flippo       06/30/2004 Fix problem with attr_dim_id being
 |                                  inserted as the dim_id
 |   Rob Flippo  03/21/2005 Bug#4215137 Added x_user_assign_allowed_flag to the
 |                          INSERT_ROW call for FEM_DIM_ATTRIBUTES_PKG.  All
 |                          attributes created from this pkg will have 'Y'
 |                          for this flag (since only seeded attributes can be
 |                          'N')
 |
 |   Tim Moore   05/02/2005 Bug#4036498 Added following functions:
 |                          Get_Dim_Attribute_Value
 |                          Get_Dim_Attr_Value_Set
 |
 |   Tim Moore   05/24/2005 Bug#4050785 Added following procedures:
 |                          New_Dim_Attr_Version
 |                          New_Dim_Attr_Default
 |   Rob Flippo  08/16/2006 Bug#5463488 overlad get_dim_attribute_value
 |                          function so can be called via sql stmt
 *=======================================================================*/

/* ***********************
** Package constants
** ***********************/


/* ***********************
** Package variables
** ***********************/
--dbms_utility.format_call_stack                 VARCHAR2(2000);

/* ***********************
** Package exceptions
** ***********************/
e_invalid_dimension  EXCEPTION;
e_invalid_attr_dimension  EXCEPTION;
e_existing_attr_varchar_label EXCEPTION;
e_invalid_order_type EXCEPTION;
e_existing_attr_name EXCEPTION;
e_invalid_attr_data_type_code EXCEPTION;

gv_prg_msg      VARCHAR2(2000);
gv_callstack    VARCHAR2(2000);


/*************************************************************************

                           Create Attibute

*************************************************************************/

PROCEDURE create_attribute (x_attribute_id                  OUT NOCOPY NUMBER
                           ,x_msg_count                     OUT NOCOPY NUMBER
                           ,x_msg_data                      OUT NOCOPY VARCHAR2
                           ,x_return_status                 OUT NOCOPY VARCHAR2
                           ,p_api_version                   IN  NUMBER
                           ,p_commit                        IN  VARCHAR2
                           ,p_attr_varchar_label            IN  VARCHAR2
                           ,p_attr_name                     IN  VARCHAR2
                           ,p_attr_description              IN  VARCHAR2
                           ,p_dimension_varchar_label       IN  VARCHAR2
                           ,p_allow_mult_versions_flag      IN  VARCHAR2
                           ,p_queryable_for_reporting_flag  IN  VARCHAR2
                           ,p_use_inheritance_flag          IN  VARCHAR2
                           ,p_attr_order_type_code          IN  VARCHAR2
                           ,p_allow_mult_assign_flag        IN  VARCHAR2
                           ,p_personal_flag                 IN  VARCHAR2
                           ,p_attr_data_type_code           IN  VARCHAR2
                           ,p_attr_dimension_varchar_label  IN  VARCHAR2
                           ,p_version_display_code          IN  VARCHAR2
                           ,p_version_name                  IN  VARCHAR2
                           ,p_version_description           IN  VARCHAR2)
IS

/* ==========================================================================
** This procedure creates a new user defined attribute in the FEM xDimension metadata.
** It also creates a "default" attribute version for the attribute
** ==========================================================================
** ==========================================================================*/
c_api_name  CONSTANT VARCHAR2(30) := 'create_attribute';
c_api_version  CONSTANT NUMBER := 1.0;
v_rowid VARCHAR2(100);
v_count NUMBER;

v_dimension_id                 NUMBER;
v_attribute_id                 NUMBER;
v_allow_mult_versions_flag     VARCHAR2(1);
v_queryable_for_reporting_flag VARCHAR2(1);
v_use_inheritance_flag         VARCHAR2(1);
v_allow_mult_assign_flag       VARCHAR2(1);
v_personal_flag                VARCHAR2(1);
v_attr_required_flag           VARCHAR2(1);
v_attr_data_type_code          VARCHAR2(30);
v_attr_value_column_name       VARCHAR2(30);
v_attr_dimension_id            NUMBER;

v_version_id                   NUMBER;

   BEGIN

      fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
      p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
      p_msg_text => 'Begin. P_ATTR_VARCHAR_LABEL: '||p_attr_varchar_label||
      ' P_ATTR_NAME:'||p_attr_name||
      ' P_ATTR_DESCRIPTION:'||p_attr_description||
      ' P_DIMENSION_VARCHAR_LABEL:'||p_dimension_varchar_label||
      ' P_ALLOW_MULT_VERSIONS_FLAG:'||p_allow_mult_versions_flag||
      ' P_QUERYABLE_FOR_REPORTING_FLAG:'||p_queryable_for_reporting_flag||
      ' P_USE_INHERITANCE_FLAG:'||p_use_inheritance_flag||
      ' P_ATTR_ORDER_TYPE_CODE:'||p_attr_order_type_code||
      ' P_ALLOW_MULT_ASSIGN_FLAG:'||p_allow_mult_assign_flag||
      ' P_ATTR_DATA_TYPE_CODE:'||p_attr_data_type_code||
      ' P_ATTR_DIMENSION_VARCHAR_LABEL:'||p_attr_dimension_varchar_label||
      ' P_VERSION_DISPLAY_CODE:'||p_version_display_code||
      ' P_VERSION_NAME:'||p_version_name||
      ' P_VERSION_DESCRPTION:'||p_version_description||
      ' P_COMMIT: '||p_commit);

      /* Standard Start of API savepoint */
       SAVEPOINT  create_attribute_pub;

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

      /* Validate that the Dimension Varchar Label exists */
      BEGIN
         SELECT B.dimension_id
         INTO v_dimension_id
         FROM fem_dimensions_b B, fem_xdim_dimensions X
         WHERE B.dimension_varchar_label = p_dimension_varchar_label
         AND B.dimension_id = X.dimension_id
         AND X.attribute_table_name IS NOT NULL;

      EXCEPTION
         WHEN no_data_found THEN
            RAISE e_invalid_dimension;
      END;

      /* Validate that the Attribute Varchar Label does not already exist
         for the specified dimension */
      SELECT count(*)
      INTO v_count
      FROM fem_dim_attributes_b
      WHERE attribute_varchar_label = p_attr_varchar_label
      AND dimension_id = v_dimension_id ;

      IF v_count > 0 THEN
         RAISE e_existing_attr_varchar_label;
      END IF;  /* attr_varchar_label validation */

      /* Validate that the Attribute Name does not already exist
         in any language*/
      SELECT count(*)
      INTO v_count
      FROM fem_dim_attributes_tl
      WHERE attribute_name = p_attr_name;

      IF v_count > 0 THEN
         RAISE e_existing_attr_name;
      END IF;  /* attr_name validation */

      /* Validate that the Attribute Order Type Code exists in FND_LOOKUP_VALUES */
      SELECT count(*)
      INTO v_count
      FROM fnd_lookup_values
      WHERE lookup_type = 'FEM_ATTRIBUTE_ORDER_TYPE_DSC'
      AND lookup_code = p_attr_order_type_code;

      IF v_count = 0 THEN
         RAISE e_invalid_order_type;
      END IF;  /* attr_order_type_code validation */

      -- Set the flags - anything but a Y or y means the flag is 'N'
      v_attr_required_flag := 'N';

      IF p_allow_mult_versions_flag IN ('y', 'Y') THEN
         v_allow_mult_versions_flag := 'Y';
      ELSE v_allow_mult_versions_flag := 'N';
      END IF;

      IF p_queryable_for_reporting_flag IN ('y', 'Y') THEN
         v_queryable_for_reporting_flag := 'Y';
      ELSE v_queryable_for_reporting_flag := 'N';
      END IF;

      IF p_use_inheritance_flag IN ('y', 'Y') THEN
         v_use_inheritance_flag := 'Y';
      ELSE v_use_inheritance_flag := 'N';
      END IF;

      IF p_allow_mult_assign_flag IN ('y', 'Y') THEN
         v_allow_mult_assign_flag := 'Y';
      ELSE v_allow_mult_assign_flag := 'N';
      END IF;

      IF p_personal_flag IN ('y', 'Y') THEN
         v_personal_flag := 'Y';
      ELSE v_personal_flag := 'N';
      END IF;


      /* Validate that the Attribute Data Type Code is a valid value */
      IF p_attr_data_type_code = 'NUMBER' THEN
         v_attr_value_column_name := 'NUMBER_ASSIGN_VALUE';
      ELSIF p_attr_data_type_code = 'VARCHAR' THEN
         v_attr_value_column_name := 'VARCHAR_ASSIGN_VALUE';
      ELSIF p_attr_data_type_code = 'DATE' THEN
         v_attr_value_column_name := 'DATE_ASSIGN_VALUE';
      ELSIF p_attr_data_type_code = 'DIMENSION' THEN
         BEGIN
         SELECT dimension_id,
           DECODE(member_data_type_code,'VARCHAR',
                  'DIM_ATTRIBUTE_VARCHAR_MEMBER',
                  'NUMBER','DIM_ATTRIBUTE_NUMERIC_MEMBER',null)
         INTO v_attr_dimension_id, v_attr_value_column_name
         FROM fem_xdim_dimensions
         WHERE dimension_id IN (SELECT dimension_id FROM fem_dimensions_b
                                WHERE dimension_varchar_label = p_attr_dimension_varchar_label);
         EXCEPTION
            WHEN no_data_found THEN
            RAISE e_invalid_attr_dimension;
         END;


      ELSE RAISE e_invalid_attr_data_type_code;
      END IF;  /* attr_data_type_code validation */

      SELECT fem_dim_attributes_b_s.nextval
      INTO v_attribute_id
      FROM dual;

      SELECT fem_dim_attr_versions_b_s.nextval
      INTO v_version_id
      FROM dual;

      FEM_DIM_ATTRIBUTES_PKG.INSERT_ROW(
         X_ROWID => v_rowid
        ,X_ATTRIBUTE_ID => v_attribute_id
        ,X_READ_ONLY_FLAG => 'N'
        ,X_OBJECT_VERSION_NUMBER => 1
        ,X_USER_ASSIGN_ALLOWED_FLAG => 'Y'
        ,X_ASSIGNMENT_IS_READ_ONLY_FLAG => 'N'
        ,X_PERSONAL_FLAG => v_personal_flag
        ,X_DIMENSION_ID => v_dimension_id
        ,X_ATTRIBUTE_DIMENSION_ID => v_attr_dimension_id
        ,X_ATTRIBUTE_VALUE_COLUMN_NAME => v_attr_value_column_name
        ,X_ATTRIBUTE_DATA_TYPE_CODE => p_attr_data_type_code
        ,X_ALLOW_MULTIPLE_ASSIGNMENT_FL => v_allow_mult_assign_flag
        ,X_ATTRIBUTE_ORDER_TYPE_CODE => p_attr_order_type_code
        ,X_ATTRIBUTE_REQUIRED_FLAG => v_attr_required_flag
        ,X_USE_INHERITANCE_FLAG => v_use_inheritance_flag
        ,X_QUERYABLE_FOR_REPORTING_FLAG => v_queryable_for_reporting_flag
        ,X_ALLOW_MULTIPLE_VERSIONS_FLAG => v_allow_mult_versions_flag
        ,X_ATTRIBUTE_VARCHAR_LABEL => p_attr_varchar_label
        ,X_ATTRIBUTE_NAME => p_attr_name
        ,X_DESCRIPTION  => p_attr_description
        ,X_CREATION_DATE => sysdate
        ,X_CREATED_BY => pc_user_id
        ,X_LAST_UPDATE_DATE => sysdate
        ,X_LAST_UPDATED_BY => pc_user_id
        ,X_LAST_UPDATE_LOGIN => pc_last_update_login);

      FEM_DIM_ATTR_VERSIONS_PKG.INSERT_ROW(
         X_ROWID => v_rowid
        ,X_VERSION_ID => v_version_id
        ,X_ATTRIBUTE_ID => v_attribute_id
        ,X_AW_SNAPSHOT_FLAG => 'N'
        ,X_VERSION_DISPLAY_CODE => p_version_display_code
        ,X_OBJECT_VERSION_NUMBER => 1
        ,X_DEFAULT_VERSION_FLAG => 'Y'
        ,X_PERSONAL_FLAG => v_personal_flag
        ,X_VERSION_NAME => p_version_name
        ,X_DESCRIPTION => p_version_description
        ,X_CREATION_DATE => sysdate
        ,X_CREATED_BY => pc_user_id
        ,X_LAST_UPDATE_DATE => sysdate
        ,X_LAST_UPDATED_BY => pc_user_id
        ,X_LAST_UPDATE_LOGIN => pc_last_update_login);


      IF FND_API.To_Boolean( p_commit ) THEN
         COMMIT WORK;
      END IF;

      x_attribute_id := v_attribute_id;

      fem_engines_pkg.put_message(p_app_name =>'FEM'
      ,p_msg_name =>'FEM_XDIM_ATTR_TXT'
      ,p_token1 => 'LABEL'
      ,p_value1 => p_attr_varchar_label
      ,p_trans1 => 'N'
      ,p_token2 => 'ATTR_ID'
      ,p_value2 => x_attribute_id
      ,p_trans2 => 'N'      );

      fem_engines_pkg.tech_message(p_severity => pc_log_level_statement,
      p_module => 'fem.plsql.'||pc_pkg_name||'.'||c_api_name,
      p_msg_text => 'End. X_RETURN_STATUS: '||x_return_status);

      FND_MSG_PUB.Count_And_Get
         (p_count => x_msg_count,
          p_data => x_msg_data);

   EXCEPTION
      WHEN e_invalid_dimension THEN
         ROLLBACK TO create_attribute_pub;
         x_return_status := pc_ret_sts_error;
         fem_engines_pkg.put_message(p_app_name =>'FEM'
         ,p_msg_name =>'FEM_XDIM_INVALID_ATTR_DIM'
         ,p_token1 => 'LABEL'
         ,p_value1 => p_dimension_varchar_label);

      FND_MSG_PUB.Count_And_Get
         (p_count => x_msg_count,
          p_data => x_msg_data);

      WHEN e_invalid_attr_dimension THEN
         ROLLBACK TO create_attribute_pub;
         x_return_status := pc_ret_sts_error;
         fem_engines_pkg.put_message(p_app_name =>'FEM'
         ,p_msg_name =>'FEM_XDIM_INVALID_DIM'
         ,p_token1 => 'LABEL'
         ,p_value1 => p_attr_dimension_varchar_label);

      FND_MSG_PUB.Count_And_Get
         (p_count => x_msg_count,
          p_data => x_msg_data);

      WHEN e_existing_attr_name THEN
         ROLLBACK TO create_attribute_pub;
         x_return_status := pc_ret_sts_error;
         fem_engines_pkg.put_message(p_app_name =>'FEM'
         ,p_msg_name =>'FEM_XDIM_ATTR_NAME_EXISTS'
         ,p_token1 => 'NAME'
         ,p_value1 => p_attr_name);

      FND_MSG_PUB.Count_And_Get
         (p_count => x_msg_count,
          p_data => x_msg_data);

      WHEN e_existing_attr_varchar_label THEN
         ROLLBACK TO create_attribute_pub;
         x_return_status := pc_ret_sts_error;
         fem_engines_pkg.put_message(p_app_name =>'FEM'
         ,p_msg_name =>'FEM_XDIM_ATTR_EXISTS'
         ,p_token1 => 'ATTR'
         ,p_value1 => p_attr_varchar_label
         ,p_token2 => 'DIM'
         ,p_value2 => p_dimension_varchar_label);

      FND_MSG_PUB.Count_And_Get
         (p_count => x_msg_count,
          p_data => x_msg_data);

      WHEN e_invalid_order_type THEN
         ROLLBACK TO create_attribute_pub;
         x_return_status := pc_ret_sts_error;
         fem_engines_pkg.put_message(p_app_name =>'FEM'
         ,p_msg_name =>'FEM_XDIM_INVALID_ATTR_ORDRTYP'
         ,p_token1 => 'TYPE'
         ,p_value1 => p_attr_order_type_code);

      FND_MSG_PUB.Count_And_Get
         (p_count => x_msg_count,
          p_data => x_msg_data);

      WHEN e_invalid_attr_data_type_code THEN
         ROLLBACK TO create_attribute_pub;
         x_return_status := pc_ret_sts_error;
         fem_engines_pkg.put_message(p_app_name =>'FEM'
         ,p_msg_name =>'FEM_XDIM_INVALID_ATTR_DATATYP'
         ,p_token1 => 'TYPE'
         ,p_value1 => p_attr_data_type_code);

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
         gv_prg_msg   := gv_prg_msg;
         gv_callstack := gv_callstack;

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
         ROLLBACK TO create_attribute_pub;

      FND_MSG_PUB.Count_And_Get
         (p_count => x_msg_count,
          p_data => x_msg_data);

END create_attribute;

/*************************************************************************

                      Get Dim Attribute Value

  This API returns the member value of an attribute assignment of either a
   dimension member or a dimension member/value set combination.
  If an attribute version is not specified, the default is used.
*************************************************************************/

FUNCTION Get_Dim_Attribute_Value (
   p_api_version     IN NUMBER     DEFAULT 1.0,
   p_init_msg_list   IN VARCHAR2   DEFAULT pc_false,
   p_commit          IN VARCHAR2   DEFAULT pc_false,
   p_encoded         IN VARCHAR2   DEFAULT pc_true,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_msg_count      OUT NOCOPY NUMBER,
   x_msg_data       OUT NOCOPY VARCHAR2,
   p_dimension_varchar_label     IN VARCHAR2,
   p_attribute_varchar_label     IN VARCHAR2,
   p_member_id                   IN NUMBER,
   p_value_set_id                IN NUMBER     DEFAULT NULL,
   p_attr_version_display_code   IN VARCHAR2   DEFAULT NULL,
   p_return_attr_assign_mbr_id   IN VARCHAR2   DEFAULT NULL
) RETURN VARCHAR2
IS

c_api_version    NUMBER := 1.0;

v_dim_id         NUMBER;
v_attr_id        NUMBER;
v_attr_tab       VARCHAR2(30);
v_attr_val_col   VARCHAR2(30);
v_attr_ver_id    NUMBER;
v_vs_req_flg     VARCHAR2(1);
v_vs_id          NUMBER;
v_mem_id         NUMBER;
v_mem_b_tab      VARCHAR2(30);
v_mem_col        VARCHAR2(30);
v_mem_dc_col     VARCHAR2(30);
v_attr_dim_id    NUMBER;

v_sql_stmt       VARCHAR2(4000);

v_attr_value     VARCHAR2(150) := -1;  -- Stores return value

e_bad_dim_label    EXCEPTION;
e_no_dim_attr      EXCEPTION;
e_bad_attr_label   EXCEPTION;
e_bad_vs_code      EXCEPTION;
e_bad_mem_vs_code  EXCEPTION;
e_bad_mem_code     EXCEPTION;
e_vs_req           EXCEPTION;
e_bad_default_ver  EXCEPTION;
e_bad_version      EXCEPTION;
e_no_attr_value    EXCEPTION;

BEGIN

x_return_status := pc_ret_sts_success;

---------------------------
-- Verify the OA parameters
---------------------------
FEM_Dimension_Util_Pkg.Validate_OA_Params (
   p_api_version => c_api_version,
   p_init_msg_list => p_init_msg_list,
   p_commit => p_commit,
   p_encoded => p_encoded,
   x_return_status => x_return_status);

IF (x_return_status <> pc_ret_sts_success)
THEN
   FND_MSG_PUB.Count_and_Get(
      p_encoded => pc_false,
      p_count => x_msg_count,
      p_data => x_msg_data);
   RETURN -1;
END IF;

---------------------------------
-- Verify the specified Dimension
---------------------------------
BEGIN
   SELECT dimension_id
   INTO   v_dim_id
   FROM   fem_dimensions_b
   WHERE  dimension_varchar_label = p_dimension_varchar_label;
EXCEPTION
   WHEN no_data_found THEN
      RAISE e_bad_dim_label;
END;

-------------------------------
-- Get the Dimension's metadata
-------------------------------
SELECT attribute_table_name,
       member_b_table_name,
       member_col,
       value_set_required_flag
INTO   v_attr_tab,
       v_mem_b_tab,
       v_mem_col,
       v_vs_req_flg
FROM   fem_xdim_dimensions
WHERE  dimension_id = v_dim_id;

------------------------------------------
-- Verify that the Dimension is attributed
------------------------------------------
IF (v_attr_tab IS NULL)
THEN
   RAISE e_no_dim_attr;
END IF;

---------------------------------
-- Verify the specified Attribute
---------------------------------
BEGIN
   SELECT attribute_id,
          attribute_dimension_id,
          attribute_value_column_name
   INTO   v_attr_id,
          v_attr_dim_id,
          v_attr_val_col
   FROM   fem_dim_attributes_b
   WHERE  attribute_varchar_label = p_attribute_varchar_label
   AND    dimension_id = v_dim_id;
EXCEPTION
   WHEN no_data_found THEN
      RAISE e_bad_attr_label;
END;

---------------------------------------------
-- Verify just the specified Dimension member
---------------------------------------------
v_sql_stmt :=
'SELECT '||v_mem_col||
' FROM '||v_mem_b_tab||
' WHERE '||v_mem_col||' = :b_member_id';

BEGIN
   EXECUTE IMMEDIATE v_sql_stmt
   INTO v_mem_id
   USING p_member_id;
EXCEPTION
   WHEN no_data_found THEN
      RAISE e_bad_mem_code;
END;

IF (v_vs_req_flg = 'Y')
THEN
   --------------------------------------------------------------
   -- Verify the specified Dimension member/Value Set combination
   --------------------------------------------------------------
   IF (p_value_set_id IS NOT NULL)
   THEN
      BEGIN
         SELECT value_set_id
         INTO v_vs_id
         FROM fem_value_sets_b
         WHERE value_set_id = p_value_set_id;
      EXCEPTION
         WHEN no_data_found THEN
            RAISE e_bad_vs_code;
      END;

      v_sql_stmt :=
      'SELECT '||v_mem_col||
      ' FROM '||v_mem_b_tab||
      ' WHERE '||v_mem_col||' = :b_member_id'||
      ' AND value_set_id = :b_vs_id';

      BEGIN
         EXECUTE IMMEDIATE v_sql_stmt
         INTO v_mem_id
         USING p_member_id,
               v_vs_id;
      EXCEPTION
         WHEN no_data_found THEN
            RAISE e_bad_mem_vs_code;
      END;
   ELSE
      RAISE e_vs_req;
   END IF;
ELSE
   v_vs_id := null;
END IF;

IF (p_attr_version_display_code IS NULL)
THEN
   ------------------------------------
   -- Get the default Attribute version
   ------------------------------------
   BEGIN
      SELECT version_id
      INTO v_attr_ver_id
      FROM fem_dim_attr_versions_b
      WHERE attribute_id =
         (SELECT attribute_id
          FROM   fem_dim_attributes_b
          WHERE  attribute_id = v_attr_id
          AND    dimension_id = v_dim_id)
      AND default_version_flag = 'Y';
   EXCEPTION
      WHEN no_data_found THEN
         RAISE e_bad_default_ver;
      WHEN too_many_rows THEN
         RAISE e_bad_default_ver;
   END;
ELSE
   -----------------------------------------
   -- Verify the specified Attribute version
   -----------------------------------------
   BEGIN
      SELECT version_id
      INTO v_attr_ver_id
      FROM fem_dim_attr_versions_b
      WHERE attribute_id =
         (SELECT attribute_id
          FROM   fem_dim_attributes_b
          WHERE  attribute_id = v_attr_id
          AND    dimension_id = v_dim_id)
      AND version_display_code = p_attr_version_display_code;
   EXCEPTION
      WHEN no_data_found THEN
         RAISE e_bad_version;
   END;
END IF;

-----------------------------------
-- Get the Attribute assigned value
-----------------------------------
IF (v_vs_id IS NOT NULL)
THEN
   v_sql_stmt :=
   'SELECT '||v_attr_val_col||
   ' FROM '||v_attr_tab||' A,'||
   '      fem_dim_attributes_b B'||
   ' WHERE B.attribute_id = :b_attr_id'||
   ' AND A.attribute_id = B.attribute_id'||
   ' AND A.value_set_id = :b_vs_id'||
   ' AND A.version_id = :b_attr_ver_id'||
   ' AND A.'||v_mem_col||' = :b_mem_id';

   BEGIN
      EXECUTE IMMEDIATE v_sql_stmt
      INTO v_attr_value
      USING v_attr_id,
            v_vs_id,
            v_attr_ver_id,
            v_mem_id;
   EXCEPTION
      WHEN no_data_found THEN
         RAISE e_no_attr_value;
   END;
ELSE
   v_sql_stmt :=
   'SELECT '||v_attr_val_col||
   ' FROM '||v_attr_tab||' A,'||
   '      fem_dim_attributes_b B'||
   ' WHERE B.attribute_id = :b_attr_id'||
   ' AND A.attribute_id = B.attribute_id'||
   ' AND A.version_id = :b_attr_ver_id'||
   ' AND A.'||v_mem_col||' = :b_mem_id';

   BEGIN
      EXECUTE IMMEDIATE v_sql_stmt
      INTO v_attr_value
      USING v_attr_id,
            v_attr_ver_id,
            v_mem_id;
   EXCEPTION
      WHEN no_data_found THEN
         RAISE e_no_attr_value;
   END;
END IF;

IF (v_attr_val_col = 'DIM_ATTRIBUTE_NUMERIC_MEMBER' AND
    NVL(p_return_attr_assign_mbr_id,'N') = 'N')
THEN
   -------------------------------
   -- Get the Attribute's metadata
   -------------------------------
   SELECT member_b_table_name,
          member_col,
          member_display_code_col
   INTO   v_mem_b_tab,
          v_mem_col,
          v_mem_dc_col
   FROM   fem_xdim_dimensions
   WHERE  dimension_id = v_attr_dim_id;

   --------------------------------------------------
   -- Get the Attribute assigned value's Display Code
   --------------------------------------------------
   v_sql_stmt :=
   'SELECT '||v_mem_dc_col||
   ' FROM '||v_mem_b_tab||
   ' WHERE '||v_mem_col||' = :b_attr_value';

   BEGIN
      EXECUTE IMMEDIATE v_sql_stmt
      INTO v_attr_value
      USING v_attr_value;
   EXCEPTION
      WHEN no_data_found THEN
         RAISE e_no_attr_value;
   END;
END IF;

RETURN v_attr_value;

EXCEPTION

WHEN e_bad_dim_label THEN
   FEM_ENGINES_PKG.Put_Message(
      p_app_name => 'FEM',
      p_msg_name => 'FEM_DIM_ATTR_BAD_DIM_LABEL',
      p_token1 => 'DIM_LABEL',
      p_value1 => p_dimension_varchar_label);
   FND_MSG_PUB.Count_and_Get(
      p_encoded => p_encoded,
      p_count => x_msg_count,
      p_data => x_msg_data);
   x_return_status := pc_ret_sts_error;
   RETURN -1;

WHEN e_no_dim_attr THEN
   FEM_ENGINES_PKG.Put_Message(
      p_app_name => 'FEM',
      p_msg_name => 'FEM_DIM_ATTR_NO_DIM_ATTR',
      p_token1 => 'DIM_LABEL',
      p_value1 => p_dimension_varchar_label);
   FND_MSG_PUB.Count_and_Get(
      p_encoded => p_encoded,
      p_count => x_msg_count,
      p_data => x_msg_data);
   x_return_status := pc_ret_sts_error;
   RETURN -1;

WHEN e_bad_attr_label THEN
   FEM_ENGINES_PKG.Put_Message(
      p_app_name => 'FEM',
      p_msg_name => 'FEM_DIM_ATTR_BAD_ATTR_LABEL',
      p_token1 => 'ATTR_LABEL',
      p_value1 => p_attribute_varchar_label);
   FND_MSG_PUB.Count_and_Get(
      p_encoded => p_encoded,
      p_count => x_msg_count,
      p_data => x_msg_data);
   x_return_status := pc_ret_sts_error;
   RETURN -1;

WHEN e_bad_vs_code THEN
   FEM_ENGINES_PKG.Put_Message(
      p_app_name => 'FEM',
      p_msg_name => 'FEM_DIM_ATTR_BAD_VS_CODE',
      p_token1 => 'VS_CODE',
      p_value1 => p_value_set_id);
   FND_MSG_PUB.Count_and_Get(
      p_encoded => p_encoded,
      p_count => x_msg_count,
      p_data => x_msg_data);
   x_return_status := pc_ret_sts_error;
   RETURN -1;

WHEN e_bad_mem_vs_code THEN
   FEM_ENGINES_PKG.Put_Message(
      p_app_name => 'FEM',
      p_msg_name => 'FEM_DIM_ATTR_BAD_MEM_VS_CODE',
      p_token1 => 'MEM_CODE',
      p_value1 => p_member_id,
      p_token2 => 'VS_CODE',
      p_value2 => p_value_set_id);
   FND_MSG_PUB.Count_and_Get(
      p_encoded => p_encoded,
      p_count => x_msg_count,
      p_data => x_msg_data);
   x_return_status := pc_ret_sts_error;
   RETURN -1;

WHEN e_bad_mem_code THEN
   FEM_ENGINES_PKG.Put_Message(
      p_app_name => 'FEM',
      p_msg_name => 'FEM_DIM_ATTR_BAD_MEM_CODE',
      p_token1 => 'MEM_CODE',
      p_value1 => p_member_id,
      p_token2 => 'DIM_LABEL',
      p_value2 => p_dimension_varchar_label);
   FND_MSG_PUB.Count_and_Get(
      p_encoded => p_encoded,
      p_count => x_msg_count,
      p_data => x_msg_data);
   x_return_status := pc_ret_sts_error;
   RETURN -1;

WHEN e_vs_req THEN
   FEM_ENGINES_PKG.Put_Message(
      p_app_name => 'FEM',
      p_msg_name => 'FEM_DIM_ATTR_VS_REQUIRED',
      p_token1 => 'DIM_LABEL',
      p_value1 => p_dimension_varchar_label);
   FND_MSG_PUB.Count_and_Get(
      p_encoded => p_encoded,
      p_count => x_msg_count,
      p_data => x_msg_data);
   x_return_status := pc_ret_sts_error;
   RETURN -1;

WHEN e_bad_default_ver THEN
   FEM_ENGINES_PKG.Put_Message(
      p_app_name => 'FEM',
      p_msg_name => 'FEM_DIM_ATTR_BAD_DEFAULT_VER',
      p_token1 => 'DIM_LABEL',
      p_value1 => p_dimension_varchar_label,
      p_token2 => 'ATTR_LABEL',
      p_value2 => p_attribute_varchar_label);
   FND_MSG_PUB.Count_and_Get(
      p_encoded => p_encoded,
      p_count => x_msg_count,
      p_data => x_msg_data);
   x_return_status := pc_ret_sts_error;
   RETURN -1;

WHEN e_bad_version THEN
   FEM_ENGINES_PKG.Put_Message(
      p_app_name => 'FEM',
      p_msg_name => 'FEM_DIM_ATTR_BAD_VERSION',
      p_token1 => 'ATTR_VER_CODE',
      p_value1 => p_attr_version_display_code,
      p_token2 => 'DIM_LABEL',
      p_value2 => p_dimension_varchar_label,
      p_token3 => 'ATTR_LABEL',
      p_value3 => p_attribute_varchar_label);
   FND_MSG_PUB.Count_and_Get(
      p_encoded => p_encoded,
      p_count => x_msg_count,
      p_data => x_msg_data);
   x_return_status := pc_ret_sts_error;
   RETURN -1;

WHEN e_no_attr_value THEN
   FEM_ENGINES_PKG.Put_Message(
      p_app_name => 'FEM',
      p_msg_name => 'FEM_DIM_ATTR_NO_ATTR_VALUE');
   FND_MSG_PUB.Count_and_Get(
      p_encoded => p_encoded,
      p_count => x_msg_count,
      p_data => x_msg_data);
   x_return_status := pc_ret_sts_error;
   RETURN -1;

END Get_Dim_Attribute_Value;


FUNCTION Get_Dim_Attribute_Value (
   p_dimension_varchar_label     IN VARCHAR2,
   p_attribute_varchar_label     IN VARCHAR2,
   p_member_id                   IN NUMBER,
   p_value_set_id                IN NUMBER     DEFAULT NULL,
   p_attr_version_display_code   IN VARCHAR2   DEFAULT NULL,
   p_return_attr_assign_mbr_id   IN VARCHAR2   DEFAULT NULL
) RETURN VARCHAR2
IS

x_return_value VARCHAR2(1000);
v_return_status VARCHAR2(100);
v_msg_count NUMBER;
v_msg_data VARCHAR2(1000);

BEGIN

x_return_value := Get_Dim_Attribute_Value (
   p_api_version => 1.0,
   p_init_msg_list => pc_false,
   p_commit => pc_false,
   p_encoded => pc_true,
   x_return_status => v_return_status,
   x_msg_count => v_msg_count,
   x_msg_data => v_msg_data,
   p_dimension_varchar_label => p_dimension_varchar_label,
   p_attribute_varchar_label => p_attribute_varchar_label,
   p_member_id  => p_member_id,
   p_value_set_id => p_value_set_id,
   p_attr_version_display_code => p_attr_version_display_code,
   p_return_attr_assign_mbr_id => p_return_attr_assign_mbr_id);

RETURN x_return_value;

END Get_Dim_Attribute_Value;


/*************************************************************************

                      Get Dim Attr Value Set

 This API returns the value set of an attribute assignment of either
  a dimension member or a dimension member/value set combination.
 If an attribute version is not specified, the default is used.
*************************************************************************/

FUNCTION Get_Dim_Attr_Value_Set (
   p_api_version     IN NUMBER     DEFAULT 1.0,
   p_init_msg_list   IN VARCHAR2   DEFAULT pc_false,
   p_commit          IN VARCHAR2   DEFAULT pc_false,
   p_encoded         IN VARCHAR2   DEFAULT pc_true,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_msg_count      OUT NOCOPY NUMBER,
   x_msg_data       OUT NOCOPY VARCHAR2,
   p_dimension_varchar_label     IN VARCHAR2,
   p_attribute_varchar_label     IN VARCHAR2,
   p_member_id                   IN NUMBER,
   p_value_set_id                IN NUMBER     DEFAULT NULL,
   p_attr_version_display_code   IN VARCHAR2   DEFAULT NULL,
   p_return_attr_assign_vs_id    IN VARCHAR2   DEFAULT NULL
) RETURN VARCHAR2
IS

c_api_version    NUMBER := 1.0;

v_dim_id         NUMBER;
v_attr_id        NUMBER;
v_attr_tab       VARCHAR2(30);
v_attr_val_col   VARCHAR2(30);
v_attr_ver_id    NUMBER;
v_vs_req_flg     VARCHAR2(1);
v_vs_id          NUMBER;
v_mem_id         NUMBER;
v_mem_b_tab      VARCHAR2(30);
v_mem_col        VARCHAR2(30);
v_mem_dc_col     VARCHAR2(30);
v_attr_dim_id    NUMBER;
v_attr_vs_id     NUMBER;

v_sql_stmt       VARCHAR2(4000);

v_attr_value     VARCHAR2(150) := -1;  -- Stores return value

e_bad_dim_label     EXCEPTION;
e_no_dim_attr       EXCEPTION;
e_bad_attr_label    EXCEPTION;
e_bad_vs_code       EXCEPTION;
e_bad_mem_vs_code   EXCEPTION;
e_bad_mem_code      EXCEPTION;
e_vs_req            EXCEPTION;
e_bad_default_ver   EXCEPTION;
e_bad_version       EXCEPTION;
e_no_attr_value     EXCEPTION;

BEGIN

x_return_status := pc_ret_sts_success;

---------------------------
-- Verify the OA parameters
---------------------------
FEM_Dimension_Util_Pkg.Validate_OA_Params (
   p_api_version => c_api_version,
   p_init_msg_list => p_init_msg_list,
   p_commit => p_commit,
   p_encoded => p_encoded,
   x_return_status => x_return_status);

IF (x_return_status <> pc_ret_sts_success)
THEN
   FND_MSG_PUB.Count_and_Get(
      p_encoded => pc_false,
      p_count => x_msg_count,
      p_data => x_msg_data);
   RETURN -1;
END IF;

---------------------------------
-- Verify the specified Dimension
---------------------------------
BEGIN
   SELECT dimension_id
   INTO   v_dim_id
   FROM   fem_dimensions_b
   WHERE  dimension_varchar_label = p_dimension_varchar_label;
EXCEPTION
   WHEN no_data_found THEN
      RAISE e_bad_dim_label;
END;

-------------------------------
-- Get the Dimension's metadata
-------------------------------
SELECT attribute_table_name,
       member_b_table_name,
       member_col,
       value_set_required_flag
INTO   v_attr_tab,
       v_mem_b_tab,
       v_mem_col,
       v_vs_req_flg
FROM   fem_xdim_dimensions
WHERE  dimension_id = v_dim_id;

------------------------------------------
-- Verify that the Dimension is attributed
------------------------------------------
IF (v_attr_tab IS NULL)
THEN
   RAISE e_no_dim_attr;
END IF;

---------------------------------
-- Verify the specified Attribute
---------------------------------
BEGIN
   SELECT attribute_id,
          attribute_dimension_id,
          attribute_value_column_name
   INTO   v_attr_id,
          v_attr_dim_id,
          v_attr_val_col
   FROM   fem_dim_attributes_b
   WHERE  attribute_varchar_label = p_attribute_varchar_label
   AND    dimension_id = v_dim_id;
EXCEPTION
   WHEN no_data_found THEN
      RAISE e_bad_attr_label;
END;

---------------------------------------------
-- Verify just the specified Dimension member
---------------------------------------------
v_sql_stmt :=
'SELECT '||v_mem_col||
' FROM '||v_mem_b_tab||
' WHERE '||v_mem_col||' = :b_member_id';

BEGIN
   EXECUTE IMMEDIATE v_sql_stmt
   INTO v_mem_id
   USING p_member_id;
EXCEPTION
   WHEN no_data_found THEN
      RAISE e_bad_mem_code;
END;

IF (v_vs_req_flg = 'Y')
THEN
   --------------------------------------------------------------
   -- Verify the specified Dimension member/Value Set combination
   --------------------------------------------------------------
   IF (p_value_set_id IS NOT NULL)
   THEN
      BEGIN
         SELECT value_set_id
         INTO v_vs_id
         FROM fem_value_sets_b
         WHERE value_set_id = p_value_set_id;
      EXCEPTION
         WHEN no_data_found THEN
            RAISE e_bad_vs_code;
      END;

      v_sql_stmt :=
      'SELECT '||v_mem_col||
      ' FROM '||v_mem_b_tab||
      ' WHERE '||v_mem_col||' = :b_member_id'||
      ' AND value_set_id = :b_vs_id';

      BEGIN
         EXECUTE IMMEDIATE v_sql_stmt
         INTO v_mem_id
         USING p_member_id,
               v_vs_id;
      EXCEPTION
         WHEN no_data_found THEN
            RAISE e_bad_mem_vs_code;
      END;
   ELSE
      RAISE e_vs_req;
   END IF;
ELSE
   v_vs_id := null;
END IF;

IF (p_attr_version_display_code IS NULL)
THEN
   ------------------------------------
   -- Get the default Attribute version
   ------------------------------------
   BEGIN
      SELECT version_id
      INTO v_attr_ver_id
      FROM fem_dim_attr_versions_b
      WHERE attribute_id =
         (SELECT attribute_id
          FROM   fem_dim_attributes_b
          WHERE  attribute_id = v_attr_id
          AND    dimension_id = v_dim_id)
      AND default_version_flag = 'Y';
   EXCEPTION
      WHEN no_data_found THEN
         RAISE e_bad_default_ver;
      WHEN too_many_rows THEN
         RAISE e_bad_default_ver;
   END;
ELSE
   -----------------------------------------
   -- Verify the specified Attribute version
   -----------------------------------------
   BEGIN
      SELECT version_id
      INTO v_attr_ver_id
      FROM fem_dim_attr_versions_b
      WHERE attribute_id =
         (SELECT attribute_id
          FROM   fem_dim_attributes_b
          WHERE  attribute_id = v_attr_id
          AND    dimension_id = v_dim_id)
      AND version_display_code = p_attr_version_display_code;
   EXCEPTION
      WHEN no_data_found THEN
         RAISE e_bad_version;
   END;
END IF;

---------------------------------
-- Get the Attribute Value Set ID
---------------------------------
IF (v_vs_id IS NOT NULL)
THEN
   v_sql_stmt :=
   'SELECT dim_attribute_value_set_id'||
   ' FROM '||v_attr_tab||
   ' WHERE '||v_mem_col||' = :b_mem_id'||
   ' AND value_set_id = :b_vs_id'||
   ' AND attribute_id = :b_attr_id';

   BEGIN
      EXECUTE IMMEDIATE v_sql_stmt
      INTO v_attr_vs_id
      USING v_mem_id,
            v_vs_id,
            v_attr_id;
   EXCEPTION
      WHEN no_data_found THEN
         RAISE e_no_attr_value;
   END;
ELSE
   v_sql_stmt :=
   'SELECT dim_attribute_value_set_id'||
   ' FROM '||v_attr_tab||
   ' WHERE '||v_mem_col||' = :b_mem_id'||
   ' AND attribute_id = :b_attr_id';

   BEGIN
      EXECUTE IMMEDIATE v_sql_stmt
      INTO v_attr_vs_id
      USING v_mem_id,
            v_attr_id;
   EXCEPTION
      WHEN no_data_found THEN
         RAISE e_no_attr_value;
   END;
END IF;

IF (NVL(p_return_attr_assign_vs_id,'N') = 'N')
THEN
   -------------------------------------------
   -- Get the Attribute Value Set Display Code
   -------------------------------------------
   SELECT value_set_display_code
   INTO v_attr_value
   FROM fem_value_sets_b
   WHERE value_set_id = v_attr_vs_id
   AND dimension_id = v_attr_dim_id;
ELSE
   v_attr_value := v_attr_vs_id;
END IF;

RETURN v_attr_value;

EXCEPTION

WHEN e_bad_dim_label THEN
   FEM_ENGINES_PKG.Put_Message(
      p_app_name => 'FEM',
      p_msg_name => 'FEM_DIM_ATTR_BAD_DIM_LABEL',
      p_token1 => 'DIM_LABEL',
      p_value1 => p_dimension_varchar_label);
   FND_MSG_PUB.Count_and_Get(
      p_encoded => p_encoded,
      p_count => x_msg_count,
      p_data => x_msg_data);
   x_return_status := pc_ret_sts_error;
   RETURN -1;

WHEN e_no_dim_attr THEN
   FEM_ENGINES_PKG.Put_Message(
      p_app_name => 'FEM',
      p_msg_name => 'FEM_DIM_ATTR_NO_DIM_ATTR',
      p_token1 => 'DIM_LABEL',
      p_value1 => p_dimension_varchar_label);
   FND_MSG_PUB.Count_and_Get(
      p_encoded => p_encoded,
      p_count => x_msg_count,
      p_data => x_msg_data);
   x_return_status := pc_ret_sts_error;
   RETURN -1;

WHEN e_bad_attr_label THEN
   FEM_ENGINES_PKG.Put_Message(
      p_app_name => 'FEM',
      p_msg_name => 'FEM_DIM_ATTR_BAD_ATTR_LABEL',
      p_token1 => 'ATTR_LABEL',
      p_value1 => p_attribute_varchar_label);
   FND_MSG_PUB.Count_and_Get(
      p_encoded => p_encoded,
      p_count => x_msg_count,
      p_data => x_msg_data);
   x_return_status := pc_ret_sts_error;
   RETURN -1;

WHEN e_bad_vs_code THEN
   FEM_ENGINES_PKG.Put_Message(
      p_app_name => 'FEM',
      p_msg_name => 'FEM_DIM_ATTR_BAD_VS_CODE',
      p_token1 => 'VS_CODE',
      p_value1 => p_value_set_id);
   FND_MSG_PUB.Count_and_Get(
      p_encoded => p_encoded,
      p_count => x_msg_count,
      p_data => x_msg_data);
   x_return_status := pc_ret_sts_error;
   RETURN -1;

WHEN e_bad_mem_vs_code THEN
   FEM_ENGINES_PKG.Put_Message(
      p_app_name => 'FEM',
      p_msg_name => 'FEM_DIM_ATTR_BAD_MEM_VS_CODE',
      p_token1 => 'MEM_CODE',
      p_value1 => p_member_id,
      p_token2 => 'VS_CODE',
      p_value2 => p_value_set_id);
   FND_MSG_PUB.Count_and_Get(
      p_encoded => p_encoded,
      p_count => x_msg_count,
      p_data => x_msg_data);
   x_return_status := pc_ret_sts_error;
   RETURN -1;

WHEN e_bad_mem_code THEN
   FEM_ENGINES_PKG.Put_Message(
      p_app_name => 'FEM',
      p_msg_name => 'FEM_DIM_ATTR_BAD_MEM_CODE',
      p_token1 => 'MEM_CODE',
      p_value1 => p_member_id,
      p_token2 => 'DIM_LABEL',
      p_value2 => p_dimension_varchar_label);
   FND_MSG_PUB.Count_and_Get(
      p_encoded => p_encoded,
      p_count => x_msg_count,
      p_data => x_msg_data);
   x_return_status := pc_ret_sts_error;
   RETURN -1;

WHEN e_vs_req THEN
   FEM_ENGINES_PKG.Put_Message(
      p_app_name => 'FEM',
      p_msg_name => 'FEM_DIM_ATTR_VS_REQUIRED',
      p_token1 => 'DIM_LABEL',
      p_value1 => p_dimension_varchar_label);
   FND_MSG_PUB.Count_and_Get(
      p_encoded => p_encoded,
      p_count => x_msg_count,
      p_data => x_msg_data);
   x_return_status := pc_ret_sts_error;
   RETURN -1;

WHEN e_bad_default_ver THEN
   FEM_ENGINES_PKG.Put_Message(
      p_app_name => 'FEM',
      p_msg_name => 'FEM_DIM_ATTR_BAD_DEFAULT_VER',
      p_token1 => 'DIM_LABEL',
      p_value1 => p_dimension_varchar_label,
      p_token2 => 'ATTR_LABEL',
      p_value2 => p_attribute_varchar_label);
   FND_MSG_PUB.Count_and_Get(
      p_encoded => p_encoded,
      p_count => x_msg_count,
      p_data => x_msg_data);
   x_return_status := pc_ret_sts_error;
   RETURN -1;

WHEN e_bad_version THEN
   FEM_ENGINES_PKG.Put_Message(
      p_app_name => 'FEM',
      p_msg_name => 'FEM_DIM_ATTR_BAD_VERSION',
      p_token1 => 'ATTR_VER_CODE',
      p_value1 => p_attr_version_display_code,
      p_token2 => 'DIM_LABEL',
      p_value2 => p_dimension_varchar_label,
      p_token3 => 'ATTR_LABEL',
      p_value3 => p_attribute_varchar_label);
   FND_MSG_PUB.Count_and_Get(
      p_encoded => p_encoded,
      p_count => x_msg_count,
      p_data => x_msg_data);
   x_return_status := pc_ret_sts_error;
   RETURN -1;

WHEN e_no_attr_value THEN
   FEM_ENGINES_PKG.Put_Message(
      p_app_name => 'FEM',
      p_msg_name => 'FEM_DIM_ATTR_NO_ATTR_VALUE');
   FND_MSG_PUB.Count_and_Get(
      p_encoded => p_encoded,
      p_count => x_msg_count,
      p_data => x_msg_data);
   x_return_status := pc_ret_sts_error;
   RETURN -1;

END Get_Dim_Attr_Value_Set;

/*************************************************************************

                         New Dim Attr Version

    This API creates a new version for a specified dimension attribute

*************************************************************************/

PROCEDURE New_Dim_Attr_Version (
   p_api_version     IN NUMBER     DEFAULT 1.0,
   p_init_msg_list   IN VARCHAR2   DEFAULT pc_false,
   p_commit          IN VARCHAR2   DEFAULT pc_false,
   p_encoded         IN VARCHAR2   DEFAULT pc_true,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_msg_count      OUT NOCOPY NUMBER,
   x_msg_data       OUT NOCOPY VARCHAR2,
   p_dimension_varchar_label     IN  VARCHAR2,
   p_attribute_varchar_label     IN  VARCHAR2,
   p_version_display_code        IN  VARCHAR2,
   p_version_name                IN  VARCHAR2,
   p_version_desc                IN  VARCHAR2   DEFAULT NULL,
   p_default_version_flag        IN  VARCHAR2   DEFAULT 'N'
)
IS

c_api_version  CONSTANT  NUMBER := 1.0;

c_pers_flg     CONSTANT  VARCHAR2(1)  := 'N';
c_obj_ver_no   CONSTANT  NUMBER       := 1;
c_aw_flg       CONSTANT  VARCHAR2(1)  := 'N';

v_row_id         VARCHAR2(20) := '';

v_dim_id         NUMBER;
v_attr_id        NUMBER;
v_attr_tab       VARCHAR2(30);
v_mult_ver_flg   VARCHAR2(1);
v_attr_req_flg   VARCHAR2(1);
v_ver_id         NUMBER;

e_bad_dim_label    EXCEPTION;
e_no_dim_attr      EXCEPTION;
e_bad_attr_label   EXCEPTION;
e_no_mult_versions EXCEPTION;
e_no_ver_disp_code EXCEPTION;
e_no_version_name  EXCEPTION;

BEGIN

x_return_status := pc_ret_sts_success;

---------------------------
-- Verify the OA parameters
---------------------------
FEM_Dimension_Util_Pkg.Validate_OA_Params (
   p_api_version => c_api_version,
   p_init_msg_list => p_init_msg_list,
   p_commit => p_commit,
   p_encoded => p_encoded,
   x_return_status => x_return_status);

IF (x_return_status <> pc_ret_sts_success)
THEN
   FND_MSG_PUB.Count_and_Get(
      p_encoded => pc_false,
      p_count => x_msg_count,
      p_data => x_msg_data);
END IF;

---------------------------------
-- Verify the specified Dimension
---------------------------------
BEGIN
   SELECT dimension_id
   INTO   v_dim_id
   FROM   fem_dimensions_b
   WHERE  dimension_varchar_label = p_dimension_varchar_label;
EXCEPTION
   WHEN no_data_found THEN
      RAISE e_bad_dim_label;
END;

------------------------------------------
-- Verify that the Dimension is attributed
------------------------------------------
SELECT attribute_table_name
INTO   v_attr_tab
FROM   fem_xdim_dimensions
WHERE  dimension_id = v_dim_id;

IF (v_attr_tab IS NULL)
THEN
   RAISE e_no_dim_attr;
END IF;

---------------------------------
-- Verify the specified Attribute
---------------------------------
BEGIN
   SELECT attribute_id,
          attribute_required_flag,
          allow_multiple_versions_flag
   INTO   v_attr_id,
          v_attr_req_flg,
          v_mult_ver_flg
   FROM   fem_dim_attributes_b
   WHERE  attribute_varchar_label = p_attribute_varchar_label
   AND    dimension_id = v_dim_id;
EXCEPTION
   WHEN no_data_found THEN
      RAISE e_bad_attr_label;
END;

IF (v_mult_ver_flg = 'N' OR
    v_attr_req_flg = 'Y')
THEN
   RAISE e_no_mult_versions;
END IF;

---------------------------------------
-- Verify Version Display Code and Name
---------------------------------------
IF (p_version_display_code IS NULL)
THEN
   RAISE e_no_ver_disp_code;
END IF;

IF (p_version_name IS NULL)
THEN
   RAISE e_no_version_name;
END IF;

---------------------
-- Create New Version
---------------------
SELECT fem_dim_attr_versions_b_s.NEXTVAL
INTO v_ver_id FROM dual;

FEM_DIM_ATTR_VERSIONS_PKG.INSERT_ROW(
   x_rowid => v_row_id,
   x_version_id => v_ver_id,
   x_aw_snapshot_flag => c_aw_flg,
   x_version_display_code => p_version_display_code,
   x_object_version_number => c_obj_ver_no,
   x_default_version_flag => p_default_version_flag,
   x_personal_flag => c_pers_flg,
   x_attribute_id => v_attr_id,
   x_version_name => p_version_name,
   x_description => p_version_desc,
   x_creation_date => sysdate,
   x_created_by => pc_user_id,
   x_last_update_date => sysdate,
   x_last_updated_by => pc_user_id,
   x_last_update_login => pc_last_update_login);

IF (p_default_version_flag = 'Y')
THEN
   UPDATE fem_dim_attr_versions_b
   SET default_version_flag='N'
   WHERE attribute_id = v_attr_id
   AND version_id <> v_ver_id;
END IF;

EXCEPTION

WHEN e_bad_dim_label THEN
   FEM_ENGINES_PKG.Put_Message(
      p_app_name => 'FEM',
      p_msg_name => 'FEM_DIM_ATTR_BAD_DIM_LABEL',
      p_token1 => 'DIM_LABEL',
      p_value1 => p_dimension_varchar_label);
   FND_MSG_PUB.Count_and_Get(
      p_encoded => p_encoded,
      p_count => x_msg_count,
      p_data => x_msg_data);
   x_return_status := pc_ret_sts_error;

WHEN e_no_dim_attr THEN
   FEM_ENGINES_PKG.Put_Message(
      p_app_name => 'FEM',
      p_msg_name => 'FEM_DIM_ATTR_NO_DIM_ATTR',
      p_token1 => 'DIM_LABEL',
      p_value1 => p_dimension_varchar_label);
   FND_MSG_PUB.Count_and_Get(
      p_encoded => p_encoded,
      p_count => x_msg_count,
      p_data => x_msg_data);
   x_return_status := pc_ret_sts_error;

WHEN e_bad_attr_label THEN
   FEM_ENGINES_PKG.Put_Message(
      p_app_name => 'FEM',
      p_msg_name => 'FEM_DIM_ATTR_BAD_ATTR_LABEL',
      p_token1 => 'ATTR_LABEL',
      p_value1 => p_attribute_varchar_label);
   FND_MSG_PUB.Count_and_Get(
      p_encoded => p_encoded,
      p_count => x_msg_count,
      p_data => x_msg_data);
   x_return_status := pc_ret_sts_error;

WHEN e_no_mult_versions THEN
   FEM_ENGINES_PKG.Put_Message(
      p_app_name => 'FEM',
      p_msg_name => 'FEM_DIM_ATTR_NO_MULT_VERSIONS');
   FND_MSG_PUB.Count_and_Get(
      p_encoded => p_encoded,
      p_count => x_msg_count,
      p_data => x_msg_data);
   x_return_status := pc_ret_sts_error;

WHEN e_no_version_name THEN
   FEM_ENGINES_PKG.Put_Message(
      p_app_name => 'FEM',
      p_msg_name => 'FEM_DIM_ATTR_NO_VERSION_NAME');
   FND_MSG_PUB.Count_and_Get(
      p_encoded => p_encoded,
      p_count => x_msg_count,
      p_data => x_msg_data);
   x_return_status := pc_ret_sts_error;

WHEN e_no_ver_disp_code THEN
   FEM_ENGINES_PKG.Put_Message(
      p_app_name => 'FEM',
      p_msg_name => 'FEM_DIM_ATTR_NO_VERSION_CODE');
   FND_MSG_PUB.Count_and_Get(
      p_encoded => p_encoded,
      p_count => x_msg_count,
      p_data => x_msg_data);
   x_return_status := pc_ret_sts_error;

END New_Dim_Attr_Version;

/*************************************************************************

                         New Dim Attr Default

  This API changes the default version for a specified dimension attribute

*************************************************************************/

PROCEDURE New_Dim_Attr_Default (
   p_api_version     IN NUMBER     DEFAULT 1.0,
   p_init_msg_list   IN VARCHAR2   DEFAULT pc_false,
   p_commit          IN VARCHAR2   DEFAULT pc_false,
   p_encoded         IN VARCHAR2   DEFAULT pc_true,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_msg_count      OUT NOCOPY NUMBER,
   x_msg_data       OUT NOCOPY VARCHAR2,
   p_dimension_varchar_label     IN  VARCHAR2,
   p_attribute_varchar_label     IN  VARCHAR2,
   p_version_display_code        IN  VARCHAR2
)
IS

c_api_version  CONSTANT  NUMBER := 1.0;

v_dim_id         NUMBER;
v_attr_id        NUMBER;
v_attr_tab       VARCHAR2(30);
v_mult_ver_flg   VARCHAR2(1);
v_attr_req_flg   VARCHAR2(1);
v_ver_id         NUMBER;

e_bad_dim_label    EXCEPTION;
e_no_dim_attr      EXCEPTION;
e_bad_attr_label   EXCEPTION;
e_no_mult_versions EXCEPTION;
e_no_ver_disp_code EXCEPTION;

BEGIN

x_return_status := pc_ret_sts_success;

---------------------------
-- Verify the OA parameters
---------------------------
FEM_Dimension_Util_Pkg.Validate_OA_Params (
   p_api_version => c_api_version,
   p_init_msg_list => p_init_msg_list,
   p_commit => p_commit,
   p_encoded => p_encoded,
   x_return_status => x_return_status);

IF (x_return_status <> pc_ret_sts_success)
THEN
   FND_MSG_PUB.Count_and_Get(
      p_encoded => pc_false,
      p_count => x_msg_count,
      p_data => x_msg_data);
END IF;

---------------------------------
-- Verify the specified Dimension
---------------------------------
BEGIN
   SELECT dimension_id
   INTO   v_dim_id
   FROM   fem_dimensions_b
   WHERE  dimension_varchar_label = p_dimension_varchar_label;
EXCEPTION
   WHEN no_data_found THEN
      RAISE e_bad_dim_label;
END;

------------------------------------------
-- Verify that the Dimension is attributed
------------------------------------------
SELECT attribute_table_name
INTO   v_attr_tab
FROM   fem_xdim_dimensions
WHERE  dimension_id = v_dim_id;

IF (v_attr_tab IS NULL)
THEN
   RAISE e_no_dim_attr;
END IF;

---------------------------------
-- Verify the specified Attribute
---------------------------------
BEGIN
   SELECT attribute_id,
          attribute_required_flag,
          allow_multiple_versions_flag
   INTO   v_attr_id,
          v_attr_req_flg,
          v_mult_ver_flg
   FROM   fem_dim_attributes_b
   WHERE  attribute_varchar_label = p_attribute_varchar_label
   AND    dimension_id = v_dim_id;
EXCEPTION
   WHEN no_data_found THEN
      RAISE e_bad_attr_label;
END;

IF (v_mult_ver_flg = 'N' OR
    v_attr_req_flg = 'Y')
THEN
   RAISE e_no_mult_versions;
END IF;

---------------------------
-- Verify Attribute Version
---------------------------
BEGIN
   SELECT version_id
   INTO v_ver_id
   FROM fem_dim_attr_versions_b
   WHERE attribute_id = v_attr_id
   AND   version_display_code = p_version_display_code;
EXCEPTION
   WHEN no_data_found THEN
      RAISE e_no_ver_disp_code;
END;

---------------------------
-- Update Attribute Default
---------------------------
UPDATE fem_dim_attr_versions_b
SET default_version_flag='N'
WHERE attribute_id = v_attr_id
AND version_id <> v_ver_id;

UPDATE fem_dim_attr_versions_b
SET default_version_flag='Y'
WHERE attribute_id = v_attr_id
AND version_id = v_ver_id;

EXCEPTION

WHEN e_bad_dim_label THEN
   FEM_ENGINES_PKG.Put_Message(
      p_app_name => 'FEM',
      p_msg_name => 'FEM_DIM_ATTR_BAD_DIM_LABEL',
      p_token1 => 'DIM_LABEL',
      p_value1 => p_dimension_varchar_label);
   FND_MSG_PUB.Count_and_Get(
      p_encoded => p_encoded,
      p_count => x_msg_count,
      p_data => x_msg_data);
   x_return_status := pc_ret_sts_error;

WHEN e_no_dim_attr THEN
   FEM_ENGINES_PKG.Put_Message(
      p_app_name => 'FEM',
      p_msg_name => 'FEM_DIM_ATTR_NO_DIM_ATTR',
      p_token1 => 'DIM_LABEL',
      p_value1 => p_dimension_varchar_label);
   FND_MSG_PUB.Count_and_Get(
      p_encoded => p_encoded,
      p_count => x_msg_count,
      p_data => x_msg_data);
   x_return_status := pc_ret_sts_error;

WHEN e_bad_attr_label THEN
   FEM_ENGINES_PKG.Put_Message(
      p_app_name => 'FEM',
      p_msg_name => 'FEM_DIM_ATTR_BAD_ATTR_LABEL',
      p_token1 => 'ATTR_LABEL',
      p_value1 => p_attribute_varchar_label);
   FND_MSG_PUB.Count_and_Get(
      p_encoded => p_encoded,
      p_count => x_msg_count,
      p_data => x_msg_data);
   x_return_status := pc_ret_sts_error;

WHEN e_no_mult_versions THEN
   FEM_ENGINES_PKG.Put_Message(
      p_app_name => 'FEM',
      p_msg_name => 'FEM_DIM_ATTR_NO_MULT_VERSIONS');
   FND_MSG_PUB.Count_and_Get(
      p_encoded => p_encoded,
      p_count => x_msg_count,
      p_data => x_msg_data);
   x_return_status := pc_ret_sts_error;

WHEN e_no_ver_disp_code THEN
   FEM_ENGINES_PKG.Put_Message(
      p_app_name => 'FEM',
      p_msg_name => 'FEM_DIM_ATTR_NO_VERSION_CODE');
   FND_MSG_PUB.Count_and_Get(
      p_encoded => p_encoded,
      p_count => x_msg_count,
      p_data => x_msg_data);
   x_return_status := pc_ret_sts_error;

END New_Dim_Attr_Default;

END FEM_DIM_ATTRIBUTES_UTIL_PKG;

/
