--------------------------------------------------------
--  DDL for Package Body FEM_DIM_HIER_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_DIM_HIER_UTIL_PKG" AS
--$Header: fem_dimhier_pkb.plb 120.3 2005/06/13 15:30:56 appldev  $
/*==========================================================================+
 |    Copyright (c) 1997 Oracle Corporation, Redwood Shores, CA, USA        |
 |                         All rights reserved.                             |
 +==========================================================================+
 | FILENAME
 |
 |    fem_di9mhier_pkh.pls
 |
 | NAME fem_dim_hier_util_pkg
 |
 | DESCRIPTION
 |
 |   Package Body for fem_dim_hier_util_pkg
 |
 | HISTORY
 |
 |    17-JAN-05 tmoore  Bug 4106880 - added following APIs:
 |                         New_Hier_Object
 |                         New_Hier_Object_Def
 |                         New_GL_Cal_Period_Hier
 |    13-JUN-05 gcheng  Bug 4425976. Modified New_Hier_Object to validate
 |                      against FND Lookups instead of relying on a
 |                      hard-coded list of values.
 |
 +=========================================================================*/

-----------------------
-- Package Constants --
-----------------------
c_resp_app_id CONSTANT NUMBER := FND_GLOBAL.RESP_APPL_ID;

c_user_id CONSTANT NUMBER := FND_GLOBAL.USER_ID;
c_login_id    NUMBER := FND_GLOBAL.Login_Id;

c_module_pkg   CONSTANT  VARCHAR2(80) := 'fem.plsql.fem_dimension_util_pkg';

f_set_status  BOOLEAN;

c_log_level_1  CONSTANT  NUMBER  := fnd_log.level_statement;
c_log_level_2  CONSTANT  NUMBER  := fnd_log.level_procedure;
c_log_level_3  CONSTANT  NUMBER  := fnd_log.level_event;
c_log_level_4  CONSTANT  NUMBER  := fnd_log.level_exception;
c_log_level_5  CONSTANT  NUMBER  := fnd_log.level_error;
c_log_level_6  CONSTANT  NUMBER  := fnd_log.level_unexpected;

-----------------------
-- Package Variables --
-----------------------
v_module_log   VARCHAR2(255);

v_session_ledger_id NUMBER := NULL;

v_varchar      VARCHAR2(255);
v_param_req    BOOLEAN;

v_attr_label   VARCHAR2(30);
v_attr_code    VARCHAR2(150);

v_token_value  VARCHAR2(150);
v_token_trans  VARCHAR2(1);

v_msg_text     VARCHAR2(4000);

gv_prg_msg      VARCHAR2(2000);
gv_callstack    VARCHAR2(2000);

------------------------
-- Package Exceptions --
------------------------
e_bad_param_value     EXCEPTION;
e_null_param_value    EXCEPTION;
e_no_value_found      EXCEPTION;
e_many_values_found   EXCEPTION;
e_no_version_name     EXCEPTION;
e_bad_dim_id          EXCEPTION;
e_dup_mem_id          EXCEPTION;
e_user_exception      EXCEPTION;
e_dup_display_code    EXCEPTION;
e_req_attr_assign     EXCEPTION;
e_FEM_XDIM_UTIL_ATTR_NODEFAULT EXCEPTION;

/*************************************************************************

                            New_Hier_Object

*************************************************************************/

PROCEDURE New_Hier_Object (
   p_api_version           IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list         IN VARCHAR2   DEFAULT c_false,
   p_commit                IN VARCHAR2   DEFAULT c_false,
   p_encoded               IN VARCHAR2   DEFAULT c_true,
   x_return_status        OUT NOCOPY VARCHAR2,
   x_msg_count            OUT NOCOPY NUMBER,
   x_msg_data             OUT NOCOPY VARCHAR2,
   x_hier_obj_id          OUT NOCOPY NUMBER,
   x_hier_obj_def_id      OUT NOCOPY NUMBER,
   p_folder_id             IN NUMBER,
   p_global_vs_combo_id    IN NUMBER,
   p_object_access_code    IN VARCHAR2,
   p_object_origin_code    IN VARCHAR2,
   p_object_name           IN VARCHAR2,
   p_description           IN VARCHAR2,
   p_effective_start_date  IN DATE   DEFAULT sysdate,
   p_effective_end_date    IN DATE   DEFAULT to_date
                                     ('9999/01/01','YYYY/MM/DD'),
   p_obj_def_name          IN VARCHAR2,
   p_dimension_id          IN NUMBER,
   p_hier_type_code        IN VARCHAR2,
   p_grp_seq_code          IN VARCHAR2,
   p_multi_top_flg         IN VARCHAR2,
   p_fin_ctg_flg           IN VARCHAR2,
   p_multi_vs_flg          IN VARCHAR2,
   p_hier_usage_code       IN VARCHAR2,
   p_flat_rows_flag        IN VARCHAR2  DEFAULT 'N',
   p_gl_period_type        IN VARCHAR2  DEFAULT NULL,
   p_calendar_id           IN NUMBER    DEFAULT NULL,
   p_val_set_id1           IN NUMBER    DEFAULT NULL,
   p_val_set_id2           IN NUMBER    DEFAULT NULL,
   p_val_set_id3           IN NUMBER    DEFAULT NULL,
   p_val_set_id4           IN NUMBER    DEFAULT NULL,
   p_val_set_id5           IN NUMBER    DEFAULT NULL,
   p_val_set_id6           IN NUMBER    DEFAULT NULL,
   p_val_set_id7           IN NUMBER    DEFAULT NULL,
   p_val_set_id8           IN NUMBER    DEFAULT NULL,
   p_val_set_id9           IN NUMBER    DEFAULT NULL,
   p_dim_grp_id1           IN NUMBER    DEFAULT NULL,
   p_dim_grp_id2           IN NUMBER    DEFAULT NULL,
   p_dim_grp_id3           IN NUMBER    DEFAULT NULL,
   p_dim_grp_id4           IN NUMBER    DEFAULT NULL,
   p_dim_grp_id5           IN NUMBER    DEFAULT NULL,
   p_dim_grp_id6           IN NUMBER    DEFAULT NULL,
   p_dim_grp_id7           IN NUMBER    DEFAULT NULL,
   p_dim_grp_id8           IN NUMBER    DEFAULT NULL,
   p_dim_grp_id9           IN NUMBER    DEFAULT NULL
)
IS

v_dim_name          VARCHAR2(80);
v_dim_label         VARCHAR2(150);
v_dim_hier_table    VARCHAR2(30);
v_hier_allowed_code VARCHAR2(30);
v_group_use_code    VARCHAR2(30);
v_vs_reqd_flg       VARCHAR2(1);
v_object_id         NUMBER;
v_obj_def_id        NUMBER;
v_val_set_id        NUMBER;
v_dim_grp_id        NUMBER;
v_dim_grp_seq       NUMBER;
v_calendar_id       NUMBER;
v_dim_grp_count     NUMBER;
v_val_set_count     NUMBER;
v_lookup_code       FND_LOOKUP_VALUES.lookup_code%TYPE;

-------------------------------------
-- Cursor to fetch Value Sets
-------------------------------------
CURSOR c_value_sets IS
   SELECT value_set_id
   FROM fem_value_sets_b
   WHERE dimension_id = p_dimension_id
   AND value_set_id IN
      (p_val_set_id1,p_val_set_id2,p_val_set_id3,
       p_val_set_id4,p_val_set_id5,p_val_set_id6,
       p_val_set_id7,p_val_set_id8,p_val_set_id9);

-------------------------------------------
-- Cursor to fetch Dimension Groups
-------------------------------------------
CURSOR c_dim_grps IS
   SELECT dimension_group_id
   FROM fem_dimension_grps_b
   WHERE dimension_id = p_dimension_id
   AND   dimension_group_id IN
      (p_dim_grp_id1,p_dim_grp_id2,p_dim_grp_id3,
       p_dim_grp_id4,p_dim_grp_id5,p_dim_grp_id6,
       p_dim_grp_id7,p_dim_grp_id8,p_dim_grp_id9)
   ORDER BY dimension_group_seq;

-------------------------------------------
-- Cursor to fetch FND Lookup Codes
-------------------------------------------
CURSOR c_fnd_lookups(p_lookup_type VARCHAR2, p_lookup_code VARCHAR2) IS
   SELECT lookup_code
   FROM fnd_lookup_values_vl
   WHERE lookup_type = p_lookup_type
   AND lookup_code = p_lookup_code;

----------------------------------------------------
-- Arrays to store Value Set and Dimension Group IDs
----------------------------------------------------
TYPE number_array IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
a_val_set_id  number_array;
a_dim_grp_id  number_array;
v_arr   NUMBER;  -- Array index

-------------
-- Exceptions
-------------
e_bad_dim_id          EXCEPTION;
e_no_hiers            EXCEPTION;
e_bad_hier_type       EXCEPTION;
e_no_hier_type        EXCEPTION;
e_bad_multi_top       EXCEPTION;
e_bad_fin_ctg         EXCEPTION;
e_bad_hier_usage      EXCEPTION;
e_bad_multi_vs        EXCEPTION;
e_no_calendar         EXCEPTION;
e_bad_calendar        EXCEPTION;
e_no_val_sets         EXCEPTION;
e_no_multi_vs         EXCEPTION;
e_bad_val_set         EXCEPTION;
e_no_value_set        EXCEPTION;
e_bad_grp_seq1        EXCEPTION;
e_bad_grp_seq2        EXCEPTION;
e_bad_grp_seq3        EXCEPTION;
e_no_dim_grps         EXCEPTION;
e_bad_dim_grp         EXCEPTION;
e_no_dim_group        EXCEPTION;

BEGIN

x_return_status := c_success;
x_hier_obj_id := -1;
x_hier_obj_def_id := -1;

FEM_Dimension_Util_Pkg.Validate_OA_Params (
   p_api_version => p_api_version,
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

----------------------------
-- Get dimension xdim values
----------------------------
BEGIN
   SELECT dimension_name,
          dimension_varchar_label,
          hierarchy_table_name,
          hier_type_allowed_code,
          group_use_code,
          decode(dimension_varchar_label,'CAL_PERIOD','C',
                                         value_set_required_flag)
   INTO v_dim_name,
        v_dim_label,
        v_dim_hier_table,
        v_hier_allowed_code,
        v_group_use_code,
        v_vs_reqd_flg
   FROM fem_xdim_dimensions X,
        fem_dimensions_vl V
   WHERE X.dimension_id = p_dimension_id
   AND   V.dimension_id = X.dimension_id;
EXCEPTION
   WHEN no_data_found THEN
      RAISE e_bad_dim_id;
END;

---------------------------------------------
-- Verify that dimension can have hierarchies
---------------------------------------------
IF (v_dim_hier_table IS NULL OR
    v_hier_allowed_code = 'NONE')
THEN
   RAISE e_no_hiers;
END IF;

--------------------------------------
-- Verify hierarchy type specification
--------------------------------------
OPEN c_fnd_lookups('FEM_HIERARCHY_TYPE_DSC',p_hier_type_code);
FETCH c_fnd_lookups INTO v_lookup_code;
IF c_fnd_lookups%NOTFOUND THEN
   CLOSE c_fnd_lookups;
   RAISE e_bad_hier_type;
ELSE
   CLOSE c_fnd_lookups;
END IF;

-- Hier type code need to match the hier allowed code
-- unless what is allowed is ALL
IF (v_hier_allowed_code <> 'ALL' AND
       v_hier_allowed_code <> p_hier_type_code)
THEN
   RAISE e_no_hier_type;
END IF;

----------------------------------------
-- Verify other hierarchy specifications
----------------------------------------
IF (p_multi_top_flg NOT IN ('Y','N'))
THEN
   RAISE e_bad_multi_top;
END IF;

IF (p_fin_ctg_flg NOT IN ('Y','N'))
THEN
   RAISE e_bad_fin_ctg;
END IF;

OPEN c_fnd_lookups('FEM_HIERARCHY_USAGE_DSC',p_hier_usage_code);
FETCH c_fnd_lookups INTO v_lookup_code;
IF c_fnd_lookups%NOTFOUND THEN
   CLOSE c_fnd_lookups;
   RAISE e_bad_hier_usage;
ELSE
   CLOSE c_fnd_lookups;
END IF;

--------------------------------
-- Verify value set requirements
--------------------------------
IF (v_vs_reqd_flg <> 'C' AND
    p_multi_vs_flg NOT IN ('Y','N'))
THEN
   RAISE e_bad_multi_vs;
END IF;

IF (v_vs_reqd_flg = 'C' AND p_calendar_id IS NULL)
THEN
   RAISE e_no_calendar;
END IF;

IF (v_vs_reqd_flg = 'C')
THEN
   BEGIN
      SELECT calendar_id
      INTO v_calendar_id
      FROM fem_calendars_b
      WHERE calendar_id = p_calendar_id;
   EXCEPTION
      WHEN no_data_found THEN
         RAISE e_bad_calendar;
   END;
END IF;

--------------------
-- Verify Value Sets
--------------------
v_val_set_count := 0;
IF (v_vs_reqd_flg <> 'C')
THEN
   a_val_set_id(1) := p_val_set_id1;
   a_val_set_id(2) := p_val_set_id2;
   a_val_set_id(3) := p_val_set_id3;
   a_val_set_id(4) := p_val_set_id4;
   a_val_set_id(5) := p_val_set_id5;
   a_val_set_id(6) := p_val_set_id6;
   a_val_set_id(7) := p_val_set_id7;
   a_val_set_id(8) := p_val_set_id8;
   a_val_set_id(9) := p_val_set_id9;

   FOR v_arr IN 1..9 LOOP
      IF (a_val_set_id(v_arr) IS NOT NULL)
      THEN
         IF (v_vs_reqd_flg = 'N')
         THEN
            RAISE e_no_val_sets;
         END IF;

         v_val_set_count := v_val_set_count + 1;

         IF (p_multi_vs_flg = 'N' AND
             v_val_set_count > 1)
         THEN
            RAISE e_no_multi_vs;
         END IF;

         BEGIN
            SELECT value_set_id
            INTO v_val_set_id
            FROM fem_value_sets_b
            WHERE dimension_id = p_dimension_id
            AND value_set_id = a_val_set_id(v_arr);
         EXCEPTION
            WHEN no_data_found THEN
               v_val_set_id := a_val_set_id(v_arr);
               RAISE e_bad_val_set;
         END;
      END IF;
   END LOOP;

   IF (v_vs_reqd_flg = 'Y' AND
       v_val_set_count = 0)
   THEN
      RAISE e_no_value_set;
   END IF;
END IF;

--------------------------------
-- Verify grouping specification
--------------------------------
OPEN c_fnd_lookups('FEM_GROUP_SEQ_ENFORCED_DSC',p_grp_seq_code);
FETCH c_fnd_lookups INTO v_lookup_code;
IF c_fnd_lookups%NOTFOUND THEN
   CLOSE c_fnd_lookups;
   RAISE e_bad_grp_seq1;
ELSE
   CLOSE c_fnd_lookups;
END IF;

IF (v_group_use_code = 'REQUIRED' AND
    p_grp_seq_code = 'NO_GROUPS')
THEN
   RAISE e_bad_grp_seq2;
END IF;

IF (v_group_use_code = 'NOT_SUPPORTED' AND
    p_grp_seq_code <> 'NO_GROUPS')
THEN
   RAISE e_bad_grp_seq3;
END IF;

--------------------------
-- Verify dimension groups
--------------------------
v_dim_grp_count := 0;

a_dim_grp_id(1) := p_dim_grp_id1;
a_dim_grp_id(2) := p_dim_grp_id2;
a_dim_grp_id(3) := p_dim_grp_id3;
a_dim_grp_id(4) := p_dim_grp_id4;
a_dim_grp_id(5) := p_dim_grp_id5;
a_dim_grp_id(6) := p_dim_grp_id6;
a_dim_grp_id(7) := p_dim_grp_id7;
a_dim_grp_id(8) := p_dim_grp_id8;
a_dim_grp_id(9) := p_dim_grp_id9;

FOR v_arr IN 1..9 LOOP
   IF (a_dim_grp_id(v_arr) IS NOT NULL)
   THEN
      IF (p_grp_seq_code = 'NO_GROUPS')
      THEN
         RAISE e_no_dim_grps;
      END IF;

      v_dim_grp_count := v_dim_grp_count + 1;

      BEGIN
         SELECT dimension_group_id
         INTO v_dim_grp_id
         FROM fem_dimension_grps_b
         WHERE dimension_id = p_dimension_id
         AND   dimension_group_id = a_dim_grp_id(v_arr);
      EXCEPTION
         WHEN no_data_found THEN
            v_dim_grp_id := a_dim_grp_id(v_arr);
            RAISE e_bad_dim_grp;
      END;

   END IF;
END LOOP;

IF (p_grp_seq_code <> 'NO_GROUPS' AND
    v_dim_grp_count = 0)
THEN
   RAISE e_no_dim_group;
END IF;

----------------
-- Create Object
----------------
FEM_Object_Catalog_Util_Pkg.Create_Object (
   x_object_id => v_object_id,
   x_object_definition_id => v_obj_def_id,
   x_msg_count => x_msg_count,
   x_msg_data => x_msg_data,
   x_return_status => x_return_status,
   p_api_version => p_api_version,
   p_commit => p_commit,
   p_object_type_code => 'HIERARCHY',
   p_folder_id => p_folder_id,
   p_local_vs_combo_id => p_global_vs_combo_id,
   p_object_access_code => p_object_access_code,
   p_object_origin_code => p_object_origin_code,
   p_object_name => p_object_name,
   p_description => p_description,
   p_effective_start_date => p_effective_start_date,
   p_effective_end_date => p_effective_end_date,
   p_obj_def_name => p_obj_def_name);

IF (x_return_status <> c_success)
THEN
   FND_MSG_PUB.Count_and_Get(
      p_encoded => c_false,
      p_count => x_msg_count,
      p_data => x_msg_data);
   RETURN;
END IF;

-------------------
-- Create Hierarchy
-------------------
INSERT INTO fem_hierarchies
  (hierarchy_obj_id,
   dimension_id,
   hierarchy_type_code,
   group_sequence_enforced_code,
   multi_top_flag,
   financial_category_flag,
   multi_value_set_flag,
   calendar_id,
   period_type,
   hierarchy_usage_code,
   creation_date,
   created_by,
   last_updated_by,
   last_update_date,
   last_update_login,
   personal_flag,
   flattened_rows_flag,
   object_version_number)
VALUES
  (v_object_id,
   p_dimension_id,
   p_hier_type_code,
   p_grp_seq_code,
   p_multi_top_flg,
   p_fin_ctg_flg,
   p_multi_vs_flg,
   v_calendar_id,
   p_gl_period_type,
   p_hier_usage_code,
   sysdate,
   c_user_id,
   c_user_id,
   sysdate,
   null,
   'N',
   p_flat_rows_flag,
   1);

INSERT INTO fem_hier_definitions
  (hierarchy_obj_def_id,
   creation_date,
   created_by,
   last_updated_by,
   last_update_date,
   last_update_login,
   object_version_number,
   flattened_rows_completion_code)
VALUES
  (v_obj_def_id,
   sysdate,
   c_user_id,
   c_user_id,
   sysdate,
   null,
   1,'PENDING');

--------------------------
-- Create Hierarchy Groups
--------------------------
IF (p_grp_seq_code <> 'NO_GROUPS')
THEN
   v_dim_grp_seq := 0;
   FOR r_dim_grp IN c_dim_grps
   LOOP
      v_dim_grp_seq := v_dim_grp_seq + 1;
      v_dim_grp_id := r_dim_grp.dimension_group_id;

      INSERT INTO fem_hier_dimension_grps
        (dimension_group_id,
         hierarchy_obj_id,
         relative_dimension_group_seq,
         creation_date,
         created_by,
         last_updated_by,
         last_update_date,
         last_update_login,
         object_version_number)
      VALUES
        (v_dim_grp_id,
         v_object_id,
         v_dim_grp_seq,
         sysdate,
         c_user_id,
         c_user_id,
         sysdate,
         null,1);

   END LOOP;
END IF;

------------------------------
-- Create Hierarchy Value Sets
------------------------------
IF (v_vs_reqd_flg = 'Y')
THEN
   FOR r_value_set IN c_value_sets
   LOOP
      v_val_set_id := r_value_set.value_set_id;

      INSERT INTO fem_hier_value_sets
        (hierarchy_obj_id,
         value_set_id,
         creation_date,
         created_by,
         last_updated_by,
         last_update_date,
         last_update_login,
         object_version_number)
      VALUES
        (v_object_id,
         v_val_set_id,
         sysdate,
         c_user_id,
         c_user_id,
         sysdate,
         null,1);
   END LOOP;

ELSIF (v_vs_reqd_flg = 'C')
THEN
   INSERT INTO fem_hier_value_sets
     (hierarchy_obj_id,
      value_set_id,
      creation_date,
      created_by,
      last_updated_by,
      last_update_date,
      last_update_login,
      object_version_number)
   VALUES
     (v_object_id,
      v_calendar_id,
      sysdate,
      c_user_id,
      c_user_id,
      sysdate,
      null,1);
END IF;

IF (p_commit = c_true)
THEN
   COMMIT;
END IF;

x_hier_obj_id := v_object_id;
x_hier_obj_def_id := v_obj_def_id;

EXCEPTION
   WHEN e_bad_dim_id THEN
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_NEW_HIER_OBJ_BAD_DIM_ID',
         p_token1 => 'DIM_ID',
         p_value1 => p_dimension_id);
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;

   WHEN e_no_hiers THEN
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_NEW_HIER_OBJ_NO_HIERS',
         p_token1 => 'DIM_NAME',
         p_value1 => v_dim_name);
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;

   WHEN e_bad_hier_type THEN
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_NEW_HIER_OBJ_BAD_HIER_TYPE',
         p_token1 => 'HIER_TYPE_CODE',
         p_value1 => p_hier_type_code);
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;

   WHEN e_no_hier_type THEN
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_NEW_HIER_OBJ_NO_HIER_TYPE',
         p_token1 => 'DIM_NAME',
         p_value1 => v_dim_name,
         p_token2 => 'HIER_TYPE_CODE',
         p_value2 => v_hier_allowed_code);
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;

   WHEN e_bad_multi_top THEN
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_NEW_HIER_OBJ_BAD_MULTI_TOP');
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;

   WHEN e_bad_fin_ctg THEN
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_NEW_HIER_OBJ_BAD_FIN_CTG');
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;

   WHEN e_bad_hier_usage THEN
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_NEW_HIER_OBJ_BAD_HIER_USG',
         p_token1 => 'HIER_USAGE',
         p_value1 => p_hier_usage_code);
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;

   WHEN e_bad_multi_vs THEN
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_NEW_HIER_OBJ_BAD_MULTI_VS');
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;

   WHEN e_no_calendar THEN
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_NEW_HIER_OBJ_NO_CALENDAR',
         p_token1 => 'DIM_NAME',
         p_value1 => v_dim_name);
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;

   WHEN e_bad_calendar THEN
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_NEW_HIER_OBJ_BAD_CALENDAR',
         p_token1 => 'CAL_ID',
         p_value1 => p_calendar_id);
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;

   WHEN e_no_val_sets THEN
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_NEW_HIER_OBJ_NO_VAL_SETS',
         p_token1 => 'DIM_NAME',
         p_value1 => v_dim_name);
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;

   WHEN e_bad_val_set THEN
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_NEW_HIER_OBJ_BAD_VAL_SET',
         p_token1 => 'VAL_SET',
         p_value1 => v_val_set_id,
         p_token2 => 'DIM_NAME',
         p_value2 => v_dim_name);
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;

   WHEN e_no_multi_vs THEN
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_NEW_HIER_OBJ_NO_MULTI_VS');
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;

   WHEN e_no_value_set THEN
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_NEW_HIER_OBJ_NO_VALUE_SET',
         p_token1 => 'DIM_NAME',
         p_value1 => v_dim_name);
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;

   WHEN e_bad_grp_seq1 THEN
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_NEW_HIER_OBJ_BAD_GRP_SEQ1',
         p_token1 => 'GRP_SEQ_CODE',
         p_value1 => p_grp_seq_code);
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;

   WHEN e_bad_grp_seq2 THEN
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_NEW_HIER_OBJ_BAD_GRP_SEQ2',
         p_token1 => 'DIM_NAME',
         p_value1 => v_dim_name);
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;

   WHEN e_bad_grp_seq3 THEN
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_NEW_HIER_OBJ_BAD_GRP_SEQ3',
         p_token1 => 'DIM_NAME',
         p_value1 => v_dim_name);
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;

   WHEN e_no_dim_grps THEN
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_NEW_HIER_OBJ_NO_DIM_GRPS',
         p_token1 => 'DIM_NAME',
         p_value1 => v_dim_name);
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;

   WHEN e_bad_dim_grp THEN
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_NEW_HIER_OBJ_BAD_DIM_GRP',
         p_token1 => 'DIM_GRP',
         p_value1 => v_dim_grp_id,
         p_token2 => 'DIM_NAME',
         p_value2 => v_dim_name);
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;

   WHEN e_no_dim_group THEN
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_NEW_HIER_OBJ_NO_DIM_GROUP',
         p_token1 => 'DIM_NAME',
         p_value1 => v_dim_name);
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;

END New_Hier_Object;

/*************************************************************************

                            New_Hier_Object_Def

*************************************************************************/

PROCEDURE New_Hier_Object_Def (
   p_api_version           IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list         IN VARCHAR2   DEFAULT c_false,
   p_commit                IN VARCHAR2   DEFAULT c_false,
   p_encoded               IN VARCHAR2   DEFAULT c_true,
   x_return_status        OUT NOCOPY VARCHAR2,
   x_msg_count            OUT NOCOPY NUMBER,
   x_msg_data             OUT NOCOPY VARCHAR2,
   x_hier_obj_def_id      OUT NOCOPY NUMBER,
   p_hier_obj_id           IN NUMBER,
   p_obj_def_name          IN VARCHAR2,
   p_effective_start_date  IN DATE,
   p_effective_end_date    IN DATE,
   p_object_origin_code    IN VARCHAR2
)
IS

v_hier_obj_id  NUMBER;
v_obj_def_id   NUMBER;

e_no_hier_obj_id   EXCEPTION;

BEGIN

x_return_status := c_success;
x_hier_obj_def_id := -1;

FEM_Dimension_Util_Pkg.Validate_OA_Params (
   p_api_version => p_api_version,
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

-----------------------------
-- Verify Hierarchy Object ID
-----------------------------
BEGIN
   SELECT hierarchy_obj_id
   INTO v_hier_obj_id
   FROM fem_hierarchies
   WHERE hierarchy_obj_id = p_hier_obj_id;
EXCEPTION
   WHEN no_data_found THEN
      RAISE e_no_hier_obj_id;
END;

------------------------------
-- Create Hierarchy Definition
------------------------------
FEM_Object_Catalog_Util_Pkg.Create_Object_Definition (
   x_object_definition_id => v_obj_def_id,
   x_msg_count => x_msg_count,
   x_msg_data => x_msg_data,
   x_return_status => x_return_status,
   p_api_version => p_api_version,
   p_commit => p_commit,
   p_object_id => v_hier_obj_id,
   p_effective_start_date => p_effective_start_date,
   p_effective_end_date => p_effective_end_date,
   p_obj_def_name => p_obj_def_name,
   p_object_origin_code => p_object_origin_code);

IF (x_return_status <> c_success)
THEN
   FND_MSG_PUB.Count_and_Get(
      p_encoded => c_false,
      p_count => x_msg_count,
      p_data => x_msg_data);
   RETURN;
END IF;

INSERT INTO fem_hier_definitions
  (hierarchy_obj_def_id,
   creation_date,
   created_by,
   last_updated_by,
   last_update_date,
   last_update_login,
   object_version_number,
   flattened_rows_completion_code)
VALUES
  (v_obj_def_id,
   sysdate,
   c_user_id,
   c_user_id,
   sysdate,
   null,
   1,'PENDING');

IF (p_commit = c_true)
THEN
   COMMIT;
END IF;

x_hier_obj_def_id := v_obj_def_id;

EXCEPTION
   WHEN e_no_hier_obj_id THEN
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_NEW_HIER_OBJ_NO_HIER_OBJ',
         p_token1 => 'HIER_OBJ',
         p_value1 => p_hier_obj_id);
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;

END New_Hier_Object_Def;

/*************************************************************************

                            New_GL_Cal_Period_Hier

*************************************************************************/

PROCEDURE New_GL_Cal_Period_Hier (
   p_api_version           IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list         IN VARCHAR2   DEFAULT c_false,
   p_commit                IN VARCHAR2   DEFAULT c_false,
   p_encoded               IN VARCHAR2   DEFAULT c_true,
   x_return_status        OUT NOCOPY VARCHAR2,
   x_msg_count            OUT NOCOPY NUMBER,
   x_msg_data             OUT NOCOPY VARCHAR2,
   x_hier_obj_id          OUT NOCOPY NUMBER,
   x_hier_obj_def_id      OUT NOCOPY NUMBER,
   p_folder_id             IN NUMBER,
   p_object_access_code    IN VARCHAR2,
   p_object_origin_code    IN VARCHAR2,
   p_object_name           IN VARCHAR2,
   p_description           IN VARCHAR2,
   p_effective_start_date  IN DATE   DEFAULT sysdate,
   p_effective_end_date    IN DATE   DEFAULT to_date
                                     ('9999/01/01','YYYY/MM/DD'),
   p_obj_def_name          IN VARCHAR2,
   p_grp_seq_code          IN VARCHAR2,
   p_multi_top_flg         IN VARCHAR2,
   p_gl_period_type        IN VARCHAR2,
   p_dim_grp_id            IN NUMBER,
   p_calendar_id           IN NUMBER
)
IS

v_hier_allowed_code VARCHAR2(30);
v_cal_per_dim_id NUMBER;
v_year_grp_id  NUMBER;
v_qtr_grp_id  NUMBER;

BEGIN

FEM_Dimension_Util_Pkg.Validate_OA_Params (
   p_api_version => p_api_version,
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

-----------------------------
-- Get Cal Period Xdim Values
-----------------------------
SELECT B.dimension_id,
       X.hier_type_allowed_code
INTO v_cal_per_dim_id,
     v_hier_allowed_code
FROM fem_xdim_dimensions X,
     fem_dimensions_b B
WHERE B.dimension_varchar_label = 'CAL_PERIOD'
AND   B.dimension_id = X.dimension_id;

-----------------------------------------------
-- Get Dimension Group IDs for Year and Quarter
-----------------------------------------------
IF (p_dim_grp_id IS NOT NULL)
THEN
   SELECT Y.dimension_group_id,
          Q.dimension_group_id
   INTO v_year_grp_id,
        v_qtr_grp_id
   FROM fem_dimension_grps_b Y,
        fem_dimension_grps_b Q
   WHERE Y.dimension_group_display_code = 'Year'
   AND   Q.dimension_group_display_code = 'Quarter'
   AND   Y.dimension_id = 1
   AND   Q.dimension_id = 1;
ELSE
   v_year_grp_id := null;
   v_qtr_grp_id := null;
END IF;

-------------------
-- Create Hierarchy
-------------------
New_Hier_Object (
   p_api_version => p_api_version,
   p_init_msg_list => p_init_msg_list,
   p_commit => p_commit,
   p_encoded => p_encoded,
   x_return_status => x_return_status,
   x_msg_count => x_msg_count,
   x_msg_data => x_msg_data,
   x_hier_obj_id => x_hier_obj_id,
   x_hier_obj_def_id => x_hier_obj_def_id,
   p_folder_id => p_folder_id,
   p_global_vs_combo_id => null,
   p_object_access_code => p_object_access_code,
   p_object_origin_code => p_object_origin_code,
   p_object_name => p_object_name,
   p_description => p_description,
   p_effective_start_date => p_effective_start_date,
   p_effective_end_date => p_effective_end_date,
   p_obj_def_name => p_obj_def_name,
   p_dimension_id => v_cal_per_dim_id,
   p_hier_type_code => v_hier_allowed_code,
   p_grp_seq_code => p_grp_seq_code,
   p_multi_top_flg => p_multi_top_flg,
   p_fin_ctg_flg => 'N',
   p_multi_vs_flg => 'N',
   p_hier_usage_code => 'STANDARD',
   p_gl_period_type => p_gl_period_type,
   p_calendar_id => p_calendar_id,
   p_dim_grp_id1 => p_dim_grp_id,
   p_dim_grp_id2 => v_year_grp_id,
   p_dim_grp_id3 => v_qtr_grp_id);

IF (p_commit = c_true)
THEN
   COMMIT;
END IF;

END New_GL_Cal_Period_Hier;

END FEM_Dim_Hier_Util_Pkg;

/
