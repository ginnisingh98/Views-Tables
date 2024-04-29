--------------------------------------------------------
--  DDL for Package Body FEM_AW_SNAPSHOT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_AW_SNAPSHOT_PKG" AS
-- $Header: fem_aw_snapshot.plb 120.1 2005/07/07 15:26:13 appldev ship $

PROCEDURE Create_Snapshot(
x_err_code OUT NOCOPY NUMBER,
x_num_msg  OUT NOCOPY NUMBER
)

IS

v_dim_id NUMBER;
v_dim_attr_tab  VARCHAR2(30);
v_member_col  VARCHAR2(30);
v_attr_id NUMBER;
v_attr_name VARCHAR2(80);
v_old_ver_id NUMBER;
v_new_ver_id NUMBER;
v_def_ver_id NUMBER;
v_source_lang VARCHAR2(4);
v_ver_name VARCHAR2(80);
v_ver_dc VARCHAR2(150);
v_ver_desc VARCHAR2(255);
v_vs_col_exists NUMBER;
v_tl_ver_exists NUMBER;

v_rowid                   VARCHAR2(20) := '';
c_user_id      CONSTANT   NUMBER       := FND_GLOBAL.USER_ID;
c_lang         CONSTANT   VARCHAR2(4)  := userenv('LANG');

v_msg_num NUMBER;

v_sql_cmd1  VARCHAR2(4000);
v_sql_cmd2  VARCHAR2(4000);

CURSOR cv_dims IS
SELECT distinct dimension_id
FROM   fem_dim_attributes_b;

CURSOR cv_attrs IS
SELECT attribute_id
FROM   fem_dim_attributes_b
WHERE  dimension_id = v_dim_id;

BEGIN

x_err_code := 0;
x_num_msg := 0;

/****************************************
Stubbed for bug#4173291 since the Dimension Snapshot Engine
replaces this package

--------------------------
-- Get Distinct Dimensions
--------------------------
FOR r_dims IN cv_dims
LOOP
   v_dim_id := r_dims.dimension_id;

   SELECT member_col,
          attribute_table_name
   INTO   v_member_col,
          v_dim_attr_tab
   FROM   fem_xdim_dimensions
   WHERE  dimension_id = v_dim_id;

   ---------------------------------------
   -- Get Attributes for Current Dimension
   ---------------------------------------
   FOR r_attrs IN cv_attrs
   LOOP
      v_attr_id := r_attrs.attribute_id;

      ---------------------
      -- Get Attribute Name
      ---------------------
      v_attr_name := FEM_Dimension_Util_Pkg.Get_Dim_Attr_Name
                     (p_attr_id => v_attr_id);

      -------------------------
      -- Delete Old AW Snapshot
      -------------------------
      BEGIN
         SELECT version_id
         INTO   v_old_ver_id
         FROM   fem_dim_attr_versions_b
         WHERE  attribute_id = v_attr_id
         AND    aw_snapshot_flag = 'Y';

         FEM_DIM_ATTR_VERSIONS_PKG.DELETE_ROW
           (x_version_id => v_old_ver_id);

         IF (v_dim_attr_tab IS NOT NULL)
         THEN
            EXECUTE IMMEDIATE
             'DELETE FROM '||v_dim_attr_tab||
             ' WHERE attribute_id = '||v_attr_id||
             ' AND version_id = '||v_old_ver_id;
         END IF;
      EXCEPTION
         WHEN no_data_found THEN null;
      END;

      ----------------------------------
      -- Get Default Version to Snapshot
      ----------------------------------
      BEGIN
         SELECT version_id
         INTO   v_def_ver_id
         FROM   fem_dim_attr_versions_b
         WHERE  attribute_id = v_attr_id
         AND    default_version_flag = 'Y';
      EXCEPTION
         WHEN no_data_found THEN
            v_def_ver_id := '';

            FEM_ENGINES_PKG.PUT_MESSAGE
            (p_app_name => 'FEM',
             p_msg_name => 'FEM_AWSS_NO_DEF_VER_WARN',
             p_token1 => 'ATTRIBUTE',
             p_value1 => v_attr_name);

             x_err_code := 1;
             x_num_msg := x_num_msg + 1;

         WHEN too_many_rows THEN
            v_def_ver_id := '';

            FEM_ENGINES_PKG.PUT_MESSAGE
            (p_app_name => 'FEM',
             p_msg_name => 'FEM_AWSS_MANY_DEF_VER_WARN',
             p_token1 => 'ATTRIBUTE',
             p_value1 => v_attr_name);

             x_err_code := 1;
             x_num_msg := x_num_msg + 1;
      END;

      IF (v_def_ver_id IS NOT NULL)
      THEN
         ----------------------------------
         -- Get Default Version's TL Record
         ----------------------------------
         v_tl_ver_exists := 1;
         BEGIN
            SELECT source_lang,
                   version_name,
                   description,
                   version_display_code
            INTO   v_source_lang,
                   v_ver_name,
                   v_ver_desc,
                   v_ver_dc
            FROM   fem_dim_attr_versions_tl T,
                   fem_dim_attr_versions_b  B
            WHERE  T.version_id = v_def_ver_id
            AND    B.version_id = T.version_id
            AND    T.language = c_lang;
         EXCEPTION
            WHEN no_data_found THEN
               v_tl_ver_exists := 0;

               FEM_ENGINES_PKG.PUT_MESSAGE
               (p_app_name => 'FEM',
                p_msg_name => 'FEM_AWSS_NO_DEF_VER_TL_WARN',
                p_token1 => 'ATTRIBUTE',
                p_value1 => v_attr_name);

                x_err_code := 1;
                x_num_msg := x_num_msg + 1;

            WHEN too_many_rows THEN
               v_tl_ver_exists := 0;

               FEM_ENGINES_PKG.PUT_MESSAGE
               (p_app_name => 'FEM',
                p_msg_name => 'FEM_AWSS_MANY_DEF_VER_TL_WARN',
                p_token1 => 'ATTRIBUTE',
                p_value1 => v_attr_name);

                x_err_code := 1;
                x_num_msg := x_num_msg + 1;
         END;

         IF (v_tl_ver_exists = 1)
         THEN
            ------------------------------------------
            -- Create Snapshot Copy of Default Version
            ------------------------------------------
            SELECT fem_dim_attr_versions_b_s.NEXTVAL
            INTO v_new_ver_id FROM dual;

            v_ver_dc := v_ver_dc||':'||v_new_ver_id;

            FEM_DIM_ATTR_VERSIONS_PKG.INSERT_ROW(
              x_rowid => v_rowid,
              x_version_id => v_new_ver_id,
              x_aw_snapshot_flag => 'Y',
              x_version_display_code => v_ver_dc,
              x_object_version_number => 1,
              x_default_version_flag => 'N',
              x_personal_flag => 'N',
              x_attribute_id => v_attr_id,
              x_version_name => v_ver_name,
              x_description => v_ver_desc,
              x_creation_date => sysdate,
              x_created_by => c_user_id,
              x_last_update_date => sysdate,
              x_last_updated_by => c_user_id,
              x_last_update_login => null);

            IF (v_dim_attr_tab IS NULL)
            THEN
               FEM_ENGINES_PKG.PUT_MESSAGE
               (p_app_name => 'FEM',
                p_msg_name => 'FEM_AWSS_NO_ATTR_TAB_WARN',
                p_token1 => 'ATTRIBUTE',
                p_value1 => v_attr_name);

                x_err_code := 1;
                x_num_msg := x_num_msg + 1;
            ELSE
               ----------------------------------------------
               -- Build SQL Statement to Create Snapshot Copy
               --  in Dimension's ATTR Table
               ----------------------------------------------
               v_sql_cmd1 :=
                 'INSERT INTO '||v_dim_attr_tab||
                   '(attribute_id,'||
                   'version_id,'||
                   v_member_col||','||
                   'dim_attribute_numeric_member,'||
                   'dim_attribute_varchar_member,'||
                   'number_assign_value,'||
                   'varchar_assign_value,'||
                   'date_assign_value,'||
                   'creation_date,'||
                   'created_by,'||
                   'last_updated_by,'||
                   'last_update_date,'||
                   'object_version_number,'||
                   'aw_snapshot_flag';
               v_sql_cmd2 :=
                 'SELECT '||
                   v_attr_id||','||
                   v_new_ver_id||','||
                   v_member_col||','||
                   'dim_attribute_numeric_member,'||
                   'dim_attribute_varchar_member,'||
                   'number_assign_value,'||
                   'varchar_assign_value,'||
                   'date_assign_value,'||
                   ''''||sysdate||''','||
                   c_user_id||','||
                   c_user_id||','||
                   ''''||sysdate||''','||
                   1||','||
                   '''Y'' ';

               --------------------------------------
               -- Determine if Dimension's ATTR Table
               --  has VALUE_SET_ID column
               --------------------------------------
               BEGIN
                  SELECT 1
                  INTO v_vs_col_exists
                  FROM all_tab_columns
                  WHERE owner = 'FEM'
                  AND table_name = v_dim_attr_tab
                  AND column_name = 'VALUE_SET_ID';
               EXCEPTION
                  WHEN no_data_found THEN
                     v_vs_col_exists := 0;
               END;

               IF (v_vs_col_exists = 1)
               THEN
                  v_sql_cmd1 := v_sql_cmd1||','||
                      'value_set_id)';
                  v_sql_cmd2 := v_sql_cmd2||','||
                     'value_set_id';
               ELSE
                  v_sql_cmd1 := v_sql_cmd1||')';
               END IF;

               v_sql_cmd2 := v_sql_cmd2||
                 ' FROM '||v_dim_attr_tab||
                 ' WHERE attribute_id = '||v_attr_id||
                 ' AND version_id = '||v_def_ver_id;

               ------------------------------------------------
               -- Execute SQL Statement to Create Snapshot Copy
               --  in Dimension's ATTR Table
               ------------------------------------------------
               BEGIN
                  EXECUTE IMMEDIATE v_sql_cmd1||v_sql_cmd2;
               EXCEPTION
                  WHEN no_data_found THEN
                     FEM_ENGINES_PKG.PUT_MESSAGE
                     (p_app_name => 'FEM',
                      p_msg_name => 'FEM_AWSS_NO_ATTR_DEF_WARN',
                      p_token1 => 'ATTRIBUTE',
                      p_value1 => v_attr_name,
                      p_token2 => 'ATTR_TAB',
                      p_value2 => v_dim_attr_tab);

                      x_err_code := 1;
                      x_num_msg := x_num_msg + 1;
               END;

            END IF;
         END IF;
      END IF;

   END LOOP;
END LOOP;

COMMIT;
*/
END Create_Snapshot;

END FEM_AW_Snapshot_Pkg;

/
