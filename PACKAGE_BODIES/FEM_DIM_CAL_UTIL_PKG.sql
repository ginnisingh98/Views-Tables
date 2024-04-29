--------------------------------------------------------
--  DDL for Package Body FEM_DIM_CAL_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_DIM_CAL_UTIL_PKG" AS
--$Header: fem_dimcal_pkb.plb 120.0 2005/06/06 20:46:42 appldev noship $
/*==========================================================================+
 |    Copyright (c) 1997 Oracle Corporation, Redwood Shores, CA, USA        |
 |                         All rights reserved.                             |
 +==========================================================================+
 | FILENAME
 |
 |    fem_dimcal_pkb.plb
 |
 | NAME
 |
 |    FEM_DIM_CAL_UTIL_PKG
 |
 | DESCRIPTION
 |
 |   Package Body for FEM_DIM_CAL_UTIL_PKG
 |
 | HISTORY
 |
 |    17-JAN-05 tmoore  Bug 4106880 - added following APIs:
 |                         New_Calendar
 |                         New_Time_Group_Type_Code
 |                         New_Time_Dimension_Group
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

                            New_Calendar

*************************************************************************/

PROCEDURE New_Calendar (
   p_api_version     IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list   IN VARCHAR2   DEFAULT c_false,
   p_commit          IN VARCHAR2   DEFAULT c_false,
   p_encoded         IN VARCHAR2   DEFAULT c_true,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_msg_count      OUT NOCOPY NUMBER,
   x_msg_data       OUT NOCOPY VARCHAR2,
   x_calendar_id    OUT NOCOPY NUMBER,
   p_cal_disp_code   IN VARCHAR2,
   p_calendar_name   IN VARCHAR2,
   p_source_cd       IN NUMBER,
   p_period_set_name IN VARCHAR2,
   p_ver_name        IN VARCHAR2,
   p_ver_disp_cd     IN VARCHAR2,
   p_calendar_desc   IN VARCHAR2,
   p_include_adj_per_flg IN VARCHAR2,
   p_default_cal_per IN NUMBER DEFAULT NULL,
   p_default_member  IN NUMBER DEFAULT NULL,
   p_default_load_member IN NUMBER DEFAULT NULL,
   p_default_hier    IN NUMBER DEFAULT NULL
)
IS

c_module_prg   CONSTANT   VARCHAR2(160) := c_module_pkg||'.new_calendar';

c_dim_label    CONSTANT   VARCHAR2(30) := 'CALENDAR';
c_enbld_flg    CONSTANT   VARCHAR2(1)  := 'Y';
c_ro_flg       CONSTANT   VARCHAR2(1)  := 'N';
c_pers_flg     CONSTANT   VARCHAR2(1)  := 'N';
c_obj_ver_no   CONSTANT   NUMBER       := 1;
c_aw_flg       CONSTANT   VARCHAR2(1)  := 'N';

v_row_id       VARCHAR2(20) := '';

v_dim_id       NUMBER;
v_cal_id        NUMBER;
v_ver_id       NUMBER;
v_attr_id      NUMBER;
v_xdim_id      NUMBER;
v_xdim_tab     VARCHAR2(30);
v_xdim_col     VARCHAR2(30);
v_xdim_cd_col  VARCHAR2(30);
v_attr_col     VARCHAR2(30);
v_attr_label   VARCHAR2(30);
v_attr_value   VARCHAR2(1000);
v_reqd_flg     VARCHAR2(1);
v_attr_num     NUMBER;
v_attr_vch     VARCHAR2(30);
v_attr_date    DATE;

v_sql_cmd      VARCHAR2(32767);

CURSOR cv_dim_attr IS
   SELECT attribute_id,
          attribute_varchar_label,
          attribute_dimension_id,
          attribute_value_column_name,
          attribute_required_flag
   FROM fem_dim_attributes_b
   WHERE dimension_id =
      (SELECT dimension_id
       FROM fem_dimensions_b
       WHERE dimension_varchar_label = c_dim_label);

TYPE cv_curs_type IS REF CURSOR;
cv_attr_dim   cv_curs_type;

BEGIN

x_return_status := c_success;
x_calendar_id := -1;

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

------------------------
-- Get New Calendar ID --
------------------------
SELECT dimension_id
INTO v_dim_id
FROM fem_dimensions_b
WHERE dimension_varchar_label = c_dim_label;

v_cal_id := FEM_Dimension_Util_Pkg.Generate_Member_ID(
              p_api_version => p_api_version,
              p_init_msg_list => c_false,
              p_commit => c_false,
              p_encoded => p_encoded,
              x_return_status => x_return_status,
              x_msg_count => x_msg_count,
              x_msg_data => x_msg_data,
              p_dim_id => v_dim_id);

IF (x_return_status <> c_success)
THEN
   RETURN;
END IF;

-------------------------------
-- Insert New Calendar Member --
-------------------------------
BEGIN
   FEM_CALENDARS_PKG.INSERT_ROW(
      x_rowid => v_row_id,
      x_calendar_id => v_cal_id,
      x_enabled_flag => c_enbld_flg,
      x_calendar_display_code => p_cal_disp_code,
      x_read_only_flag => c_ro_flg,
      x_personal_flag => c_pers_flg,
      x_object_version_number => c_obj_ver_no,
      x_calendar_name => p_calendar_name,
      x_description => p_calendar_desc,
      x_creation_date => sysdate,
      x_created_by => c_user_id,
      x_last_update_date => sysdate,
      x_last_updated_by => c_user_id,
      x_last_update_login => null);
EXCEPTION
   WHEN dup_val_on_index THEN
      RAISE e_dup_display_code;
END;

-----------------------------------
-- Insert New Calendar Attributes --
-----------------------------------
FOR r_dim_attr IN cv_dim_attr
LOOP
   v_attr_id := r_dim_attr.attribute_id;
   v_attr_label := r_dim_attr.attribute_varchar_label;
   v_xdim_id := r_dim_attr.attribute_dimension_id;
   v_attr_col := r_dim_attr.attribute_value_column_name;
   v_reqd_flg := r_dim_attr.attribute_required_flag;

   -------------------------------
   -- Check Attribute's Version --
   -------------------------------
   SELECT MIN(version_id)
   INTO v_ver_id
   FROM fem_dim_attr_versions_b
   WHERE attribute_id = v_attr_id
   AND default_version_flag = 'Y';

   IF (v_ver_id IS NULL)
   THEN
      IF (p_ver_name IS NULL)
      THEN
         RAISE e_no_version_name;
      ELSIF (p_ver_disp_cd IS NULL)
      THEN
         RAISE e_no_version_name;
      END IF;

      SELECT fem_dim_attr_versions_b_s.NEXTVAL
      INTO v_ver_id FROM dual;

      FEM_DIM_ATTR_VERSIONS_PKG.INSERT_ROW(
         x_rowid => v_row_id,
         x_version_id => v_ver_id,
         x_aw_snapshot_flag => c_aw_flg,
         x_version_display_code => p_ver_disp_cd,
         x_object_version_number => c_obj_ver_no,
         x_default_version_flag => 'Y',
         x_personal_flag => c_pers_flg,
         x_attribute_id => v_attr_id,
         x_version_name => p_ver_name,
         x_description => null,
         x_creation_date => sysdate,
         x_created_by => c_user_id,
         x_last_update_date => sysdate,
         x_last_updated_by => c_user_id,
         x_last_update_login => null);
   END IF;

   -----------------------------
   -- Get Attribute Parameter --
   -----------------------------
   CASE v_attr_label
      WHEN 'DEFAULT_CAL_PERIOD' THEN
         v_attr_value := p_default_cal_per;
      WHEN 'DEFAULT_MEMBER' THEN
         v_attr_value := p_default_member;
      WHEN 'DEFAULT_LOAD_MEMBER' THEN
         v_attr_value := p_default_load_member;
      WHEN 'DEFAULT_HIERARCHY' THEN
         v_attr_value := p_default_hier;
      WHEN 'INCLUDE_ADJ_PERIOD_FLAG' THEN
         v_attr_value := p_include_adj_per_flg;
      WHEN 'SOURCE_SYSTEM_CODE' THEN
         v_attr_value := p_source_cd;
      WHEN 'PERIOD_SET_NAME' THEN
         v_attr_value := p_period_set_name;
      ELSE
         v_attr_value := null;
         FEM_ENGINES_PKG.Tech_Message(
            p_severity => c_log_level_1,
            p_module => c_module_pkg||'.New_Calendar.bad_attr_list',
            p_msg_text => 'The Calendar attribute '||v_attr_label||
                          ' is in FEM_DIM_ATTRIBUTES_B but not in'||
                          ' the API''s list of attribute labels');

         FEM_ENGINES_PKG.Put_Message(
            p_app_name => 'FEM',
            p_msg_name => 'FEM_BAD_ATTR_LIST_WARN',
            p_token1 => 'ATTR',
            p_value1 => v_attr_label);
   END CASE;

   IF (v_attr_value IS NULL)
   THEN
      CASE v_reqd_flg
         WHEN 'Y' THEN
            RAISE e_null_param_value;
         ELSE null;
      END CASE;
   ELSE
      IF (v_attr_col = 'DIM_ATTRIBUTE_NUMERIC_MEMBER' OR
          v_attr_col = 'DIM_ATTRIBUTE_VARCHAR_MEMBER')
      THEN
         -------------------------------------
         -- Attribute is a Dimension Attribute
         --  which needs to be validated
         -------------------------------------
         SELECT member_b_table_name,
                member_col
         INTO v_xdim_tab,
              v_xdim_col
         FROM fem_xdim_dimensions
         WHERE dimension_id = v_xdim_id;

         v_sql_cmd :=
            'SELECT '||v_xdim_col||
            ' FROM '||v_xdim_tab||
            ' WHERE '||v_xdim_col||' = :b_attr_value';

         IF (v_attr_col = 'DIM_ATTRIBUTE_NUMERIC_MEMBER')
         THEN
            BEGIN
               EXECUTE IMMEDIATE v_sql_cmd
               INTO v_attr_num
               USING v_attr_value;
            EXCEPTION
               WHEN no_data_found THEN
                  RAISE e_bad_param_value;
            END;
            v_attr_vch := '';
         ELSIF (v_attr_col = 'DIM_ATTRIBUTE_VARCHAR_MEMBER')
         THEN
            BEGIN
               EXECUTE IMMEDIATE v_sql_cmd
               INTO v_attr_vch
               USING v_attr_value;
            EXCEPTION
               WHEN no_data_found THEN
                  RAISE e_bad_param_value;
            END;
            v_attr_num := '';
         END IF;

         INSERT INTO fem_calendars_attr(
            attribute_id,
            version_id,
            calendar_id,
            dim_attribute_numeric_member,
            dim_attribute_varchar_member,
            number_assign_value,
            varchar_assign_value,
            date_assign_value,
            creation_date,
            created_by,
            last_updated_by,
            last_update_date,
            last_update_login,
            aw_snapshot_flag,
            object_version_number)
         VALUES(
            v_attr_id,
            v_ver_id,
            v_cal_id,
            v_attr_num,
            v_attr_vch,
            null,
            null,
            null,
            sysdate,
            c_user_id,
            c_user_id,
            sysdate,
            null,
            c_aw_flg,
            c_obj_ver_no);

      ELSIF (v_attr_col = 'NUMBER_ASSIGN_VALUE')
      THEN
         ----------------------------------------
         -- Attribute is an assigned number value
         ----------------------------------------
         INSERT INTO fem_calendars_attr(
            attribute_id,
            version_id,
            calendar_id,
            dim_attribute_numeric_member,
            dim_attribute_varchar_member,
            number_assign_value,
            varchar_assign_value,
            date_assign_value,
            creation_date,
            created_by,
            last_updated_by,
            last_update_date,
            last_update_login,
            aw_snapshot_flag,
            object_version_number)
         VALUES(
            v_attr_id,
            v_ver_id,
            v_cal_id,
            null,
            null,
            v_attr_value,
            null,
            null,
            sysdate,
            c_user_id,
            c_user_id,
            sysdate,
            null,
            c_aw_flg,
            c_obj_ver_no);

      ELSIF (v_attr_col = 'VARCHAR_ASSIGN_VALUE')
      THEN
         -----------------------------------------
         -- Attribute is an assigned varchar value
         -----------------------------------------
         INSERT INTO fem_calendars_attr(
            attribute_id,
            version_id,
            calendar_id,
            dim_attribute_numeric_member,
            dim_attribute_varchar_member,
            number_assign_value,
            varchar_assign_value,
            date_assign_value,
            creation_date,
            created_by,
            last_updated_by,
            last_update_date,
            last_update_login,
            aw_snapshot_flag,
            object_version_number)
         VALUES(
            v_attr_id,
            v_ver_id,
            v_cal_id,
            null,
            null,
            null,
            v_attr_value,
            null,
            sysdate,
            c_user_id,
            c_user_id,
            sysdate,
            null,
            c_aw_flg,
            c_obj_ver_no);

      ELSIF (v_attr_col = 'DATE_ASSIGN_VALUE')
      THEN
         --------------------------------------
         -- Attribute is an assigned date value
         --------------------------------------
         INSERT INTO fem_calendars_attr(
            attribute_id,
            version_id,
            calendar_id,
            dim_attribute_numeric_member,
            dim_attribute_varchar_member,
            number_assign_value,
            varchar_assign_value,
            date_assign_value,
            creation_date,
            created_by,
            last_updated_by,
            last_update_date,
            last_update_login,
            aw_snapshot_flag,
            object_version_number)
         VALUES(
            v_attr_id,
            v_ver_id,
            v_cal_id,
            null,
            null,
            null,
            null,
            v_attr_date,
            sysdate,
            c_user_id,
            c_user_id,
            sysdate,
            null,
            c_aw_flg,
            c_obj_ver_no);
      END IF;

   END IF;

END LOOP;

x_calendar_id := v_cal_id;

IF (p_commit = c_true)
THEN
   COMMIT;
END IF;

FND_MSG_PUB.Count_and_Get(
   p_encoded => p_encoded,
   p_count => x_msg_count,
   p_data => x_msg_data);

EXCEPTION
   WHEN e_bad_param_value THEN
      ROLLBACK;
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_BAD_PARAM_VALUE_ERR',
         p_token1 => 'PARAM',
         p_value1 => FEM_Dimension_Util_Pkg.Get_Dim_Attr_Name(
                    p_attr_id => v_attr_id),
         p_token2 => 'VALUE',
         p_value2 => v_attr_value);
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;

   WHEN e_null_param_value THEN
      ROLLBACK;
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_NULL_PARAM_VALUE_ERR',
         p_token1 => 'PARAM',
         p_value1 => FEM_Dimension_Util_Pkg.Get_Dim_Attr_Name(
                    p_attr_id => v_attr_id));
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;

   WHEN e_no_version_name THEN
      ROLLBACK;
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_NO_VERSION_NAME_ERR',
         p_token1 => 'ENTITY',
         p_value1 => FEM_Dimension_Util_Pkg.Get_Dim_Attr_Name(
                        p_attr_id => v_attr_id));
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;

   WHEN e_dup_display_code THEN
      ROLLBACK;
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_DUP_DISPLAY_CODE_ERR',
         p_token1 => 'VALUE',
         p_value1 => p_cal_disp_code);
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;

END New_Calendar;

/*************************************************************************

                            New_Time_Group_Type

*************************************************************************/

PROCEDURE New_Time_Group_Type (
   p_api_version     IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list   IN VARCHAR2   DEFAULT c_false,
   p_commit          IN VARCHAR2   DEFAULT c_false,
   p_encoded         IN VARCHAR2   DEFAULT c_true,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_msg_count      OUT NOCOPY NUMBER,
   x_msg_data       OUT NOCOPY VARCHAR2,
   p_time_grp_type_code   IN VARCHAR2,
   p_time_grp_type_name   IN VARCHAR2,
   p_time_grp_type_desc   IN VARCHAR2 DEFAULT NULL,
   p_periods_in_year      IN NUMBER,
   p_ver_name             IN VARCHAR2,
   p_ver_disp_cd          IN VARCHAR2,
   p_read_only_flag       IN VARCHAR2  DEFAULT 'N'
)
IS
   c_enbld_flg    CONSTANT   VARCHAR2(1)  := 'Y';
   c_pers_flg     CONSTANT   VARCHAR2(1)  := 'N';
   c_obj_ver_no   CONSTANT   NUMBER       := 1;
   c_aw_flg       CONSTANT   VARCHAR2(1)  := 'N';

   v_row_id       VARCHAR2(20) := '';

   v_ver_id       NUMBER;
   v_attr_id      NUMBER;
   v_attr_col     VARCHAR2(30);
   v_attr_label   VARCHAR2(30);

   v_xdim_id      NUMBER;
   v_xdim_tab     VARCHAR2(30);
   v_xdim_col     VARCHAR2(30);
   v_xdim_cd_col  VARCHAR2(30);

BEGIN

x_return_status := c_success;

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

---------------------------------------
-- Insert New Time Group Type Member --
---------------------------------------
BEGIN
   FEM_TIME_GROUP_TYPES_PKG.INSERT_ROW(
      x_rowid => v_row_id,
      x_time_group_type_code => p_time_grp_type_code,
      x_enabled_flag => c_enbld_flg,
      x_personal_flag => c_pers_flg,
      x_object_version_number => c_obj_ver_no,
      x_read_only_flag => p_read_only_flag,
      x_time_group_type_name => p_time_grp_type_name,
      x_description => p_time_grp_type_desc,
      x_creation_date => sysdate,
      x_created_by => c_user_id,
      x_last_update_date => sysdate,
      x_last_updated_by => c_user_id,
      x_last_update_login => null);
EXCEPTION
   WHEN dup_val_on_index THEN
      RAISE e_dup_display_code;
END;

-------------------------------------------
-- Insert New Time Group Type Attributes --
-------------------------------------------
SELECT attribute_id,
       attribute_varchar_label,
       attribute_dimension_id,
       attribute_value_column_name
INTO   v_attr_id,
       v_attr_label,
       v_xdim_id,
       v_attr_col
FROM fem_dim_attributes_b
WHERE dimension_id =
   (SELECT dimension_id
    FROM fem_dimensions_b
    WHERE dimension_varchar_label = 'TIME_GROUP_TYPE')
AND attribute_varchar_label = 'PERIODS_IN_YEAR';

-------------------------------
-- Check Attribute's Version --
-------------------------------
SELECT MIN(version_id)
INTO v_ver_id
FROM fem_dim_attr_versions_b
WHERE attribute_id = v_attr_id
AND default_version_flag = 'Y';

IF (v_ver_id IS NULL)
THEN
   IF (p_ver_name IS NULL)
   THEN
      RAISE e_no_version_name;
   ELSIF (p_ver_disp_cd IS NULL)
   THEN
      RAISE e_no_version_name;
   END IF;

   SELECT fem_dim_attr_versions_b_s.NEXTVAL
   INTO v_ver_id FROM dual;

   FEM_DIM_ATTR_VERSIONS_PKG.INSERT_ROW(
      x_rowid => v_row_id,
      x_version_id => v_ver_id,
      x_aw_snapshot_flag => c_aw_flg,
      x_version_display_code => p_ver_disp_cd,
      x_object_version_number => c_obj_ver_no,
      x_default_version_flag => 'Y',
      x_personal_flag => c_pers_flg,
      x_attribute_id => v_attr_id,
      x_version_name => p_ver_name,
      x_description => null,
      x_creation_date => sysdate,
      x_created_by => c_user_id,
      x_last_update_date => sysdate,
      x_last_updated_by => c_user_id,
      x_last_update_login => null);
END IF;

-----------------------------
-- Insert Attribute Values --
-----------------------------
INSERT INTO fem_time_grp_types_attr(
   attribute_id,
   version_id,
   time_group_type_code,
   dim_attribute_numeric_member,
   dim_attribute_value_set_id,
   dim_attribute_varchar_member,
   number_assign_value,
   varchar_assign_value,
   date_assign_value,
   creation_date,
   created_by,
   last_updated_by,
   last_update_date,
   last_update_login,
   aw_snapshot_flag,
   object_version_number)
VALUES(
   v_attr_id,
   v_ver_id,
   p_time_grp_type_code,
   null,
   null,
   null,
   p_periods_in_year,
   null,
   null,
   sysdate,
   c_user_id,
   c_user_id,
   sysdate,
   null,
   c_aw_flg,
   c_obj_ver_no);

IF (p_commit = c_true)
THEN
   COMMIT;
END IF;

EXCEPTION
   WHEN e_dup_display_code THEN
      ROLLBACK;
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_DUP_DISPLAY_CODE_ERR',
         p_token1 => 'VALUE',
         p_value1 => p_time_grp_type_code);
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;

   WHEN e_no_version_name THEN
      ROLLBACK;
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_NO_VERSION_NAME_ERR',
         p_token1 => 'ENTITY',
         p_value1 => FEM_Dimension_Util_Pkg.Get_Dim_Attr_Name(
                        p_attr_id => v_attr_id));
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;

END New_Time_Group_Type;

/*************************************************************************

                            New_Time_Dimension_Group

*************************************************************************/

PROCEDURE New_Time_Dimension_Group (
   p_api_version     IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list   IN VARCHAR2   DEFAULT c_false,
   p_commit          IN VARCHAR2   DEFAULT c_false,
   p_encoded         IN VARCHAR2   DEFAULT c_true,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_msg_count      OUT NOCOPY NUMBER,
   x_msg_data       OUT NOCOPY VARCHAR2,
   x_dim_grp_id     OUT NOCOPY NUMBER,
   p_time_grp_type_code  IN VARCHAR2,
   p_dim_grp_name        IN VARCHAR2,
   p_dim_grp_disp_cd     IN VARCHAR2,
   p_dim_grp_desc        IN VARCHAR2  DEFAULT NULL,
   p_read_only_flag      IN VARCHAR2  DEFAULT 'N'
)
IS
   c_enbld_flg    CONSTANT   VARCHAR2(1)  := 'Y';
   c_pers_flg     CONSTANT   VARCHAR2(1)  := 'N';
   c_obj_ver_no   CONSTANT   NUMBER       := 1;

   v_row_id       VARCHAR2(20) := '';

   v_time_grp_type_code  VARCHAR2(30);
   v_dim_grp_id       NUMBER;
   v_dim_grp_key      NUMBER;
   v_cal_per_dim_id   NUMBER;
   v_dim_grp_seq      NUMBER;

BEGIN

x_return_status := c_success;
x_dim_grp_id := -1;

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

---------------------------------
-- Verify Time_Group_Type_Code --
---------------------------------
BEGIN
   SELECT time_group_type_code
   INTO v_time_grp_type_code
   FROM fem_time_group_types_b
   WHERE time_group_type_code = p_time_grp_type_code;
EXCEPTION
   WHEN no_data_found THEN
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_NEW_TIME_GRP_BAD_GRP_TYPE',
         p_token1 => 'GRP_TYPE',
         p_value1 => NVL(p_time_grp_type_code,'NULL'));
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;
      RETURN;
END;

---------------------------------
-- Get Cal Period Dimension ID --
---------------------------------
SELECT dimension_id
INTO v_cal_per_dim_id
FROM fem_dimensions_b
where dimension_varchar_label = 'CAL_PERIOD';

--------------------------------
-- Get New Dimension Group ID --
--------------------------------
SELECT fem_dimension_grps_b_s.NEXTVAL
INTO v_dim_grp_id
FROM dual;

---------------------------------
-- Get New Dimension Group Key --
---------------------------------
SELECT fem_time_dimension_group_key_s.NEXTVAL
INTO v_dim_grp_key
FROM dual;

---------------------------------
-- Set New Dimension Group Seq --
---------------------------------
SELECT MAX(dimension_group_seq)+1
INTO v_dim_grp_seq
FROM fem_dimension_grps_b;

---------------------------------------
-- Insert New Dimension Group Member --
---------------------------------------
BEGIN
   FEM_DIMENSION_GRPS_PKG.INSERT_ROW(
      x_rowid => v_row_id,
      x_dimension_group_id => v_dim_grp_id,
      x_time_dimension_group_key => v_dim_grp_key,
      x_dimension_id => v_cal_per_dim_id,
      x_dimension_group_seq => v_dim_grp_seq,
      x_time_group_type_code => p_time_grp_type_code,
      x_read_only_flag => p_read_only_flag,
      x_object_version_number => c_obj_ver_no,
      x_personal_flag => c_pers_flg,
      x_enabled_flag => c_enbld_flg,
      x_dimension_group_display_code => p_dim_grp_disp_cd,
      x_dimension_group_name => p_dim_grp_name,
      x_description => p_dim_grp_desc,
      x_creation_date => sysdate,
      x_created_by => c_user_id,
      x_last_update_date => sysdate,
      x_last_updated_by => c_user_id,
      x_last_update_login => null);
EXCEPTION
   WHEN dup_val_on_index THEN
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_DUP_DISPLAY_CODE_ERR',
         p_token1 => 'VALUE',
         p_value1 => p_dim_grp_disp_cd);
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;
      RETURN;
END;

IF (p_commit = c_true)
THEN
   COMMIT;
END IF;

x_dim_grp_id := v_dim_grp_id;

END New_Time_Dimension_Group;

---------------------------------------------

END FEM_DIM_CAL_UTIL_PKG;

/
