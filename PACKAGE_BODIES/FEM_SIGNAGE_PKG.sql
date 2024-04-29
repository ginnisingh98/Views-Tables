--------------------------------------------------------
--  DDL for Package Body FEM_SIGNAGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_SIGNAGE_PKG" AS
-- $Header: fem_signage_utl.plb 120.0 2005/06/15 18:21:01 appldev noship $

/***************************************************************************

                       Package Variables

 **************************************************************************/

c_user_id      CONSTANT  NUMBER := FND_GLOBAL.User_ID;
c_login_id     CONSTANT  NUMBER := FND_GLOBAL.Login_ID;
c_conc_prg_id  CONSTANT  NUMBER := FND_GLOBAL.Conc_Program_ID;
c_prg_app_id   CONSTANT  NUMBER := FND_GLOBAL.Prog_Appl_ID;

c_false        CONSTANT  VARCHAR2(1)  := FND_API.G_FALSE;
c_true         CONSTANT  VARCHAR2(1)  := FND_API.G_TRUE;

c_log_level_1  CONSTANT  NUMBER  := fnd_log.level_statement;
c_log_level_2  CONSTANT  NUMBER  := fnd_log.level_procedure;
c_log_level_3  CONSTANT  NUMBER  := fnd_log.level_event;
c_log_level_4  CONSTANT  NUMBER  := fnd_log.level_exception;
c_log_level_5  CONSTANT  NUMBER  := fnd_log.level_error;
c_log_level_6  CONSTANT  NUMBER  := fnd_log.level_unexpected;

c_signage_method CONSTANT VARCHAR2(80) := FND_PROFILE.VALUE_SPECIFIC (
   name => 'FEM_SIGNAGE_METHOD',
   user_id => c_user_id);

f_set_status             BOOLEAN;

/***************************************************************************

                 PROCEDURE: Sign_Ext_Acct_Types

 **************************************************************************/

PROCEDURE Sign_Ext_Acct_Types (
   errbuf          OUT NOCOPY VARCHAR2,
   retcode         OUT NOCOPY VARCHAR2
)
IS

------------------
-- Declarations --
------------------
v_equity_sign NUMBER;
v_asset_sign NUMBER;
v_liab_sign NUMBER;
v_expense_sign NUMBER;
v_revenue_sign NUMBER;
v_na_sign NUMBER;
v_sign_val NUMBER;

v_mem_code VARCHAR2(30);
v_mem_attr VARCHAR2(30);

v_count NUMBER;
v_sign_attr NUMBER;
v_sign_vers NUMBER;
v_type_attr NUMBER;
v_type_vers NUMBER;
v_aw_flag VARCHAR2(1);
v_mem_b_tab VARCHAR2(30);

v_message VARCHAR2(4000);

v_block  CONSTANT  VARCHAR2(80) :=
   'fem.plsql.fem_signage_pkg.ext_acct_types';

v_sql_cmd VARCHAR(32767);

CURSOR c_member IS
   SELECT distinct ext_account_type_code,dim_attribute_varchar_member
   FROM fem_ext_acct_types_attr
   WHERE attribute_id = v_type_attr
   ORDER BY ext_account_type_code;

e_no_sign_val EXCEPTION;
e_bad_sign_val EXCEPTION;
e_sign_vers EXCEPTION;
e_type_vers EXCEPTION;

BEGIN

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_3,
  p_module => v_block,
  p_msg_text => 'Begin');

---------------------------------------------
-- Set Signage Values based on Signage Method
---------------------------------------------
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.signage_method',
  p_msg_text => c_signage_method);

IF (c_signage_method IS NULL)
THEN
   RAISE e_no_sign_val;

ELSIF (c_signage_method = 'ABSOLUTE_VALUE')
THEN
   v_equity_sign := -1;
   v_asset_sign := 1;
   v_liab_sign := -1;
   v_expense_sign := 1;
   v_revenue_sign := -1;
   v_na_sign := 1;

ELSIF (c_signage_method = 'GAAP_STANDARD')
THEN
   v_equity_sign := 1;
   v_asset_sign := 1;
   v_liab_sign := 1;
   v_expense_sign := 1;
   v_revenue_sign := 1;
   v_na_sign := 1;

ELSIF (c_signage_method = 'GAAP_REVERSE')
THEN
   v_equity_sign := -1;
   v_asset_sign := -1;
   v_liab_sign := -1;
   v_expense_sign := -1;
   v_revenue_sign := -1;
   v_na_sign := -1;

ELSE
   RAISE e_bad_sign_val;
END IF;

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_3,
  p_module => v_block||'.equity_sign',
  p_msg_text => v_equity_sign);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_3,
  p_module => v_block||'.asset_sign',
  p_msg_text => v_asset_sign);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_3,
  p_module => v_block||'.liab_sign',
  p_msg_text => v_liab_sign);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_3,
  p_module => v_block||'.expense_sign',
  p_msg_text => v_expense_sign);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_3,
  p_module => v_block||'.revenue_sign',
  p_msg_text => v_revenue_sign);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_3,
  p_module => v_block||'.na_sign',
  p_msg_text => v_na_sign);

-------------------------------
-- Verify SIGN Attribute Values
-------------------------------
SELECT min(aw_snapshot_flag),
       min(attribute_id),
       min(version_id),
       count(*)
INTO   v_aw_flag,
       v_sign_attr,
       v_sign_vers,
       v_count
FROM   fem_dim_attr_versions_b
WHERE  attribute_id =
       (SELECT attribute_id
        FROM fem_dim_attributes_b
        WHERE attribute_varchar_label = 'SIGN'
        AND dimension_id =
           (SELECT A.dimension_id
            FROM fem_dimensions_b A
            WHERE A.dimension_varchar_label = 'EXTENDED_ACCOUNT_TYPE'))
AND    default_version_flag='Y';

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.sign_aw_snapshot_flag',
  p_msg_text => v_aw_flag);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.sign_attribute_id',
  p_msg_text => v_sign_attr);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.sign_version_id',
  p_msg_text => v_sign_vers);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.sign_version_count',
  p_msg_text => v_count);

IF (v_count <> 1)
THEN
------------------------------------------------------
-- SIGN Attribute does NOT have single default version
------------------------------------------------------
   RAISE e_sign_vers;
END IF;

------------------------------------
-- Verify TYPE_CODE Attribute Values
------------------------------------
SELECT min(attribute_id),
       min(version_id),
       count(*)
INTO   v_type_attr,
       v_type_vers,
       v_count
FROM   fem_dim_attr_versions_b
WHERE  attribute_id =
       (SELECT attribute_id
        FROM fem_dim_attributes_b
        WHERE attribute_varchar_label = 'BASIC_ACCOUNT_TYPE_CODE'
        AND dimension_id =
            (SELECT A.dimension_id
             FROM fem_dimensions_b A
             WHERE A.dimension_varchar_label = 'EXTENDED_ACCOUNT_TYPE'))
AND   default_version_flag='Y';

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.type_attribute_id',
  p_msg_text => v_type_attr);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.type_version_id',
  p_msg_text => v_type_vers);
FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.type_version_count',
  p_msg_text => v_count);

IF (v_count <> 1)
THEN
-----------------------------------------------------------
-- TYPE_CODE Attribute does NOT have single default version
-----------------------------------------------------------
   RAISE e_type_vers;
END IF;

----------------------------
-- Delete old signage values
----------------------------
v_sql_cmd :=
   'DELETE FROM fem_ext_acct_types_attr'||
   ' WHERE attribute_id = :b_sign_attr'||
   ' AND version_id = :b_sign_vers';

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_1,
  p_module => v_block||'.delete_sql_stmt',
  p_msg_text => v_sql_cmd);

EXECUTE IMMEDIATE
   v_sql_cmd
USING v_sign_attr,v_sign_vers;

----------------------------
-- Insert new signage values
----------------------------
FOR r_member IN c_member
LOOP
   v_mem_code := r_member.ext_account_type_code;
   v_mem_attr := r_member.dim_attribute_varchar_member;

   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_1,
     p_module => v_block||'.acct_type_code',
     p_msg_text => v_mem_code);
   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_1,
     p_module => v_block||'.varchar_member',
     p_msg_text => v_mem_attr);

   CASE v_mem_attr
      WHEN 'EQUITY' THEN v_sign_val := v_equity_sign;
      WHEN 'ASSET' THEN v_sign_val := v_asset_sign;
      WHEN 'LIABILITY' THEN v_sign_val := v_liab_sign;
      WHEN 'EXPENSE' THEN v_sign_val := v_expense_sign;
      WHEN 'REVENUE' THEN v_sign_val := v_revenue_sign;
      WHEN 'NOT_APPLICABLE' THEN v_sign_val := v_na_sign;
      WHEN 'STATISTICAL' THEN v_sign_val := 1;
      ELSE null;
   END CASE;

   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_1,
     p_module => v_block||'.sign_value',
     p_msg_text => v_sign_val);

   v_sql_cmd := 'INSERT INTO fem_ext_acct_types_attr'||
                '(attribute_id,version_id,ext_account_type_code'||
                ',number_assign_value,creation_date,created_by'||
                ',last_updated_by,last_update_date'||
                ',object_version_number,aw_snapshot_flag)'||
                ' VALUES '||
                '('||v_sign_attr||','||v_sign_vers||','''||v_mem_code||''''||
                ','||v_sign_val||','''||sysdate||''','||c_user_id||
                ','||c_user_id||','''||sysdate||''''||
                ',1,'''||v_aw_flag||''')';

   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_1,
     p_module => v_block||'.insert_sql_stmt',
     p_msg_text => v_sql_cmd);

   EXECUTE IMMEDIATE
      v_sql_cmd;

END LOOP;
COMMIT;

--------------------------
-- Post Completion Message
--------------------------
FEM_ENGINES_PKG.PUT_MESSAGE
 (p_app_name => 'FEM',
  p_msg_name => 'FEM_SIGN_COMPLETION_TXT');
v_message :=FND_MSG_PUB.GET(p_encoded => c_false);

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_3,
  p_module => v_block||'.Complete',
  p_msg_text => v_message);

FEM_ENGINES_PKG.USER_MESSAGE
 (p_msg_text => v_message);

----------------
-- Exceptions --
----------------
EXCEPTION

WHEN e_no_sign_val THEN

   FEM_ENGINES_PKG.PUT_MESSAGE
    (p_app_name => 'FEM',
     p_msg_name => 'FEM_SIGN_NO_SIGN_VAL_ERR');

   v_message := FND_MSG_PUB.GET(p_encoded => c_false);

   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.no_sign_val',
     p_msg_text => v_message);

   FEM_ENGINES_PKG.USER_MESSAGE
    (p_msg_text => v_message);

   f_set_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',null);

WHEN e_bad_sign_val THEN

   FEM_ENGINES_PKG.PUT_MESSAGE
    (p_app_name => 'FEM',
     p_msg_name => 'FEM_SIGN_BAD_SIGN_VAL_ERR',
     p_token1 => 'SIGN',
     p_value1 => c_signage_method);

   v_message := FND_MSG_PUB.GET(p_encoded => c_false);

   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.bad_sign_val',
     p_msg_text => v_message);

   FEM_ENGINES_PKG.USER_MESSAGE
    (p_msg_text => v_message);

   f_set_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',null);

WHEN e_sign_vers THEN

   FEM_ENGINES_PKG.PUT_MESSAGE
    (p_app_name => 'FEM',
     p_msg_name => 'FEM_SIGN_BAD_SIGN_VER_ERR');

   v_message := FND_MSG_PUB.GET(p_encoded => c_false);

   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.bad_sign_ver',
     p_msg_text => v_message);

   FEM_ENGINES_PKG.USER_MESSAGE
    (p_msg_text => v_message);

   f_set_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',null);

WHEN e_type_vers THEN

   FEM_ENGINES_PKG.PUT_MESSAGE
    (p_app_name => 'FEM',
     p_msg_name => 'FEM_SIGN_BAD_TYPE_VER_ERR');

   v_message := FND_MSG_PUB.GET(p_encoded => c_false);

   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.bad_type_ver',
     p_msg_text => v_message);

   FEM_ENGINES_PKG.USER_MESSAGE
    (p_msg_text => v_message);

   f_set_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',null);

WHEN others THEN

   v_message := sqlerrm;

   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_6,
     p_module => v_block||'.Exception',
     p_msg_text => sqlerrm);

   FEM_ENGINES_PKG.USER_MESSAGE
    (p_msg_text => v_message);

END Sign_Ext_Acct_Types;

END FEM_Signage_Pkg;

/
