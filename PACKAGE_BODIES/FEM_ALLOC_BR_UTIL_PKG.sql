--------------------------------------------------------
--  DDL for Package Body FEM_ALLOC_BR_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_ALLOC_BR_UTIL_PKG" AS
--$Header: fem_alloc_br_utl.plb 120.23.12000000.3 2007/08/21 10:51:51 asadadek noship $
/*==========================================================================+
 |    Copyright (c) 1997 Oracle Corporation, Redwood Shores, CA, USA        |
 |                         All rights reserved.                             |
 +==========================================================================+
 | FILENAME
 |
 |    fem_alloc_br_utl.plb
 |
 | NAME FEM_ALLOC_BR_UTIL_PKG
 |
 | DESCRIPTION
 |
 |   Package Body for the FEM Mapping Utility Package
 |
 | HISTORY
 |
 |    19-JAN-07  RFlippo  initial creation
 |    22-FEB-07  RFlippo  added generate_condition_summary
 |    16-MAR-07  RFlippo  modified generate_condition_summary to store
 |                        attr data type in the gt table
 |    20-MAR-07  RFlippo  modfied refresh_maprule_from_snapshot to handle
 |                        data in fem_object_dependencies
 |    27-MAR-07  RFlippo  fixed issues with cr_new_ver_from_defaults; added
 |                        get_default_definition
 |    29-MAR-07  RFlippo  added insert into fem_alloc_br_objects when create
 |                        new default rule
 |    12-APR-07  RFlippo  fixed issues with Table data components in
 |                        generate_condition_summary
 |    26-APR-07  RFlippo  added generate_fctr_summary API for creating the
 |                        Factor table summary data for the Factor table Details
 |                        pluggable region
 |    10-MAY-07  RFlippo  added commit for when p_commit is TRUE on all procedures
 |                        except for gen_cond_summary and gen_fctr_summary;
 |                        also changed start/end date default logic to use
 |                        profile options first
 |    24-MAY-07  RFlippo  modified get_default_definition so that
 |                        it does not try to insert into fem_alloc_br_objects
 |                        when a default definition already exists
 |   29-JUN-2007 asadadek bug#6158146. Call  API delete_map_rule_content to handle
 |                        deletion of map rule contents minus the helper records
 |			  instead of DeleteObjectDefinition.
 |   2-JUL-07  RFlippo    Bug#6146396 Set any dimension cols in the Mapping Output list
 |                        = "SAME_AS_SOURCE" if they don't have a default
 |                        assigned in fem_alloc_br_dimensions for the
 |                        default rule
 |   7-JUL-07  RFlippo    Bug#6179151  Modify so that for Adj rules, the default
 |                        is VALUE
 |   6-JUL-07  RFlippo    Need to get a unique object name for the snapshot objects.
 |                        To do this, will concatenate the sysdate, include MI:SS
 |                        so that we can have multiple snapshots (Preview, Edit, etc)
 |                        for a given mapping rule.  Can even support multiple snapshots
 |                        of the same object type (i.e, Preview) without any conflict;
 |                        Also change logic for creating a new default rule,
 |                        so that the default rule obj def name and description
 |                        come from the seeded default rule (gvsc=null)
 |   10-JUL-07 Rflippo    bug#6196776 Modify set_dim_usage_dflt so that it only does
 |                        defaults for enabled_flg='Y'
 |
 |   21-AUG-07 asadadek   Bug 6348530. Added private API set_VT_attributes to set the visual
 |                        trace attributes upon save.
 |
 +=========================================================================*/

-----------------------
-- Package Constants --
-----------------------
c_resp_app_id CONSTANT NUMBER := FND_GLOBAL.RESP_APPL_ID;

c_user_id CONSTANT NUMBER := FND_GLOBAL.USER_ID;
c_login_id    NUMBER := FND_GLOBAL.Login_Id;

c_module_pkg   CONSTANT  VARCHAR2(80) := 'fem.plsql.fem_alloc_br_util_pkg';
G_PKG_NAME     CONSTANT  VARCHAR2(30) := 'FEM_ALLOC_BR_UTIL_PKG';

f_set_status  BOOLEAN;

c_log_level_1  CONSTANT  NUMBER  := fnd_log.level_statement;
c_log_level_2  CONSTANT  NUMBER  := fnd_log.level_procedure;
c_log_level_3  CONSTANT  NUMBER  := fnd_log.level_event;
c_log_level_4  CONSTANT  NUMBER  := fnd_log.level_exception;
c_log_level_5  CONSTANT  NUMBER  := fnd_log.level_error;
c_log_level_6  CONSTANT  NUMBER  := fnd_log.level_unexpected;

c_object_version CONSTANT NUMBER := 1;

C_SNAP_OBJTYPE      CONSTANT VARCHAR2(30)  := 'MAPPING_EDIT_SNAPSHOT';
C_DFLT_OBJTYPE      CONSTANT VARCHAR2(30)  := 'MAPPING_RULE_DEFAULTS';
C_RULE_OBJTYPE      CONSTANT VARCHAR2(30)  := 'MAPPING_RULE';

C_MAX_END_DATE           CONSTANT DATE          := to_date('12/31/9999','MM/DD/YYYY');


-----------------------
-- Package Variables --
-----------------------
v_module_log   VARCHAR2(255);


v_token_value  VARCHAR2(150);
v_token_trans  VARCHAR2(1);

v_msg_text     VARCHAR2(4000);

gv_prg_msg      VARCHAR2(2000);
gv_callstack    VARCHAR2(2000);


-----------------------
-- Private Procedures --
-----------------------
PROCEDURE Validate_OA_Params (
   p_api_version     IN NUMBER,
   p_init_msg_list   IN VARCHAR2,
   p_commit          IN VARCHAR2,
   p_encoded         IN VARCHAR2,
   x_return_status   OUT NOCOPY VARCHAR2
);


PROCEDURE set_dim_usage_dflt (p_object_definition_id IN NUMBER);
procedure set_VT_attributes(p_object_definition_id NUMBER);

/*************************************************************************

                       set_dim_usage_dflt

PURPOSE:  Set any dimension cols in the Mapping Output list
  that do not have a default assigned to "SAME_AS_SOURCE" (bug#6146396)

  Here's the logic:
     We always insert a set of rows for the target table
     However - if post_to_ledger_flg = 'Y' on fem_alloc_br_formula,
     then we insert another set of records for FEM_BALANCES

7/5/2007 Rflippo  Bug#6179151  Modify so that for Adj rules, the default
                  is VALUE
7/10/2007 Rflippo bug#6196776 Only do defaults for enabled_flg='Y'
*************************************************************************/

PROCEDURE set_dim_usage_dflt (p_object_definition_id IN NUMBER) IS

  cursor c_tgttab (p_obj_def_id IN VARCHAR2) is
     SELECT function_seq, table_name, post_to_ledger_flg, function_cd
     FROM fem_alloc_br_formula
     WHERE object_definition_id = p_obj_def_id
     AND function_cd IN ('CREDIT','DEBIT')
     AND enable_flg <> 'N';

  cursor c_dimcol (p_obj_def_id IN VARCHAR2, p_func_seq IN NUMBER, p_tgt_table IN VARCHAR2) is
     SELECT column_name
     FROM fem_tab_column_prop
     WHERE table_name = p_tgt_table
     AND column_property_code = 'MAPPING_UI_OUTPUT'
     AND column_name NOT IN (
        SELECT alloc_dim_col_name
        FROM fem_alloc_br_dimensions
        WHERE object_definition_id = p_obj_def_id
        AND function_seq = p_func_seq);

  cursor c_bal_dimcol (p_obj_def_id IN VARCHAR2, p_func_seq IN NUMBER) is
     SELECT column_name
     FROM fem_tab_column_prop
     WHERE table_name = 'FEM_BALANCES'
     AND column_property_code = 'MAPPING_UI_OUTPUT'
     AND column_name NOT IN (
        SELECT alloc_dim_col_name
        FROM fem_alloc_br_dimensions
        WHERE object_definition_id = p_obj_def_id
        AND function_seq = p_func_seq);

   v_rule_type_code VARCHAR2(30);
   v_object_id NUMBER;
   v_dflt_usage VARCHAR2(30);

   C_MODULE            CONSTANT FND_LOG_MESSAGES.module%TYPE :=
      'fem.plsql.fem_alloc_br_util_pkg.set_dim_usage_dflt';


BEGIN

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;


-- Identify the rule type
  SELECT object_id
  INTO v_object_id
  FROM fem_objdef_helper_rules
  WHERE helper_obj_def_id = p_object_definition_id
  AND helper_object_type_code = 'MAPPING_EDIT_SNAPSHOT';

  SELECT map_rule_type_code
  INTO v_rule_type_code
  FROM fem_alloc_br_objects
  WHERE map_rule_object_id = v_object_id;

  IF v_rule_type_code = 'ADJUSTMENT' THEN
     v_dflt_usage := 'VALUE';
  ELSE v_dflt_usage := 'SAME_AS_SOURCE';

  END IF;


  FOR func_seq IN c_tgttab (p_object_definition_id) LOOP
   -- do the insert for the "non post to balances" records
     FOR dimcol IN c_dimcol (p_object_definition_id, func_seq.function_seq, func_seq.table_name) LOOP
        insert into fem_alloc_br_dimensions (
        OBJECT_DEFINITION_ID
        ,FUNCTION_SEQ
        ,ALLOC_DIM_COL_NAME
        ,POST_TO_BALANCES_FLAG
        ,FUNCTION_CD
        ,ALLOC_DIM_USAGE_CODE
        ,DIMENSION_VALUE
        ,DIMENSION_VALUE_CHAR
        ,PERCENT_DISTRIBUTION_CODE
        ,CREATED_BY
        ,CREATION_DATE
        ,LAST_UPDATED_BY
        ,LAST_UPDATE_DATE
        ,LAST_UPDATE_LOGIN
        ,OBJECT_VERSION_NUMBER      )
        values (p_object_definition_id, func_seq.function_seq, dimcol.column_name,
                'N', func_seq.function_cd,
                v_dflt_usage,null,null,null,c_user_id,sysdate,
                c_user_id,sysdate,null,1);
     END LOOP;

    -- do the insert for the post_to_balances record if 'Y' for post_to_ledger_flg
     IF func_seq.post_to_ledger_flg = 'Y' THEN
       FOR baldimcol IN c_bal_dimcol (p_object_definition_id, func_seq.function_seq) LOOP
         insert into fem_alloc_br_dimensions (
           OBJECT_DEFINITION_ID
          ,FUNCTION_SEQ
          ,ALLOC_DIM_COL_NAME
          ,POST_TO_BALANCES_FLAG
          ,FUNCTION_CD
          ,ALLOC_DIM_USAGE_CODE
          ,DIMENSION_VALUE
          ,DIMENSION_VALUE_CHAR
          ,PERCENT_DISTRIBUTION_CODE
          ,CREATED_BY
          ,CREATION_DATE
          ,LAST_UPDATED_BY
          ,LAST_UPDATE_DATE
          ,LAST_UPDATE_LOGIN
          ,OBJECT_VERSION_NUMBER      )
          values (p_object_definition_id, func_seq.function_seq, baldimcol.column_name,
                  'Y', func_seq.function_cd,
                  v_dflt_usage,null,null,null,c_user_id,sysdate,
                  c_user_id,sysdate,null,1);
       END LOOP;
     END IF;

  END LOOP;

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;

END set_dim_usage_dflt;

/*************************************************************************

                       Create_snapshot

PURPOSE:  Creates a new empty snapshot object (Mapping helper rule) and object definition,
and registers the association to the true mapping rule in FEM_OBJDEF_HELPER_RULES.

06-JUL-07  RFlippo  Need to get a unique object name for the snapshot objects.
                    To do this, will concatenate the sysdate, include MI:SS
                    so that we can have multiple snapshots (Preview, Edit, etc)
                    for a given mapping rule.  Can even support multiple snapshots
                    of the same object type (i.e, Preview) without any conflict.

*************************************************************************/

PROCEDURE create_snapshot (
   p_map_rule_obj_def_id IN NUMBER,
   p_snapshot_obj_type_code IN VARCHAR2 DEFAULT 'MAPPING_EDIT_SNAPSHOT',
   p_api_version         IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list       IN VARCHAR2   DEFAULT c_false,
   p_commit              IN VARCHAR2   DEFAULT c_false,
   p_encoded             IN VARCHAR2   DEFAULT c_true,
   x_snapshot_object_id  OUT NOCOPY NUMBER,
   x_snapshot_objdef_id  OUT NOCOPY NUMBER,
   x_return_status       OUT NOCOPY VARCHAR2,
   x_msg_count           OUT NOCOPY NUMBER,
   x_msg_data            OUT NOCOPY VARCHAR2) IS

  C_MODULE            CONSTANT FND_LOG_MESSAGES.module%TYPE :=
     'fem.plsql.fem_alloc_br_util_pkg.create_snapshot';
  C_API_NAME          CONSTANT VARCHAR2(30)  := 'Create_Snapshot';

  e_unexp       EXCEPTION;
  e_error       EXCEPTION;
  e_invalid_obj EXCEPTION;
  e_noobj       EXCEPTION;
  e_helper_reg  EXCEPTION;
  e_objtype     EXCEPTION;

  v_folder_id  FEM_FOLDERS_B.folder_id%TYPE;
  v_local_vs_combo_id FEM_OBJECT_CATALOG_B.local_vs_combo_id%TYPE;
  v_object_access_code FEM_OBJECT_CATALOG_B.object_access_code%TYPE;
  v_object_origin_code FEM_OBJECT_CATALOG_B.object_origin_code%TYPE;
  v_object_name FEM_OBJECT_CATALOG_TL.object_name%TYPE;
  v_description FEM_OBJECT_CATALOG_TL.description%TYPE;
  v_display_name FEM_OBJECT_DEFINITION_TL.display_name%TYPE;
  v_object_type_code FEM_OBJECT_CATALOG_B.object_type_code%TYPE;

  v_profile_start_value VARCHAR2(1000);
  v_profile_end_value VARCHAR2(1000);
  v_effective_start_date DATE;
  v_effective_end_date DATE;

  v_sysdate VARCHAR2(50);

  v_count number;

  v_objdef_desc varchar2(255);

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT  create_snapshot_pub;


  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;


  -- Initialize return status to unexpected error
  x_return_status := c_unexp;

  -- Check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (c_api_version,
                p_api_version,
                C_API_NAME,
                G_PKG_NAME)
  THEN
    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'API Version ('||C_API_VERSION||') not compatible with '
                    ||'passed in version ('||p_api_version||')');
    END IF;
    RAISE e_unexp;
  END IF;


  Validate_OA_Params (
    p_api_version => p_api_version,
    p_init_msg_list => p_init_msg_list,
    p_commit => p_commit,
    p_encoded => p_encoded,
    x_return_status => x_return_status);

  IF (x_return_status <> c_success) THEN
    RAISE e_error;
  END IF;

/*  Convert the sysdate to a string so we can concatenate it into the
    snapshot object name  */
    SELECT to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS')
    INTO v_sysdate
    FROM dual;


/* Verify the mapping rule is valid and get mapping rule object info
   NOTE: object_name for the snapshot will be = true rule object_id, because
   not possible for the snapshot object and the true rule object to
   share the same object_name*/
BEGIN

   SELECT C.folder_id, C.local_vs_combo_id, C.object_access_code,
          C.object_origin_code, C.object_id, C.description, D.display_name,
          D.description
   INTO v_folder_id, v_local_vs_combo_id, v_object_access_code,
        v_object_origin_code, v_object_name, v_description, v_display_name,
        v_objdef_desc
   FROM fem_object_catalog_vl C, fem_object_definition_vl D
   WHERE D.object_id = C.object_id
   AND D.object_definition_id = p_map_rule_obj_def_id
   AND C.object_type_code IN (C_RULE_OBJTYPE, C_DFLT_OBJTYPE);

EXCEPTION
   WHEN no_data_found THEN
      RAISE e_invalid_obj;

END;

/* Verify the object type code for the snapshot rule */
BEGIN
   SELECT object_type_code
   INTO v_object_type_code
   FROM fem_object_types_vl
   WHERE object_type_code IN ('MAPPING_EDIT_SNAPSHOT','MAPPING_PREVIEW')
   AND object_type_code = p_snapshot_obj_type_code;

EXCEPTION
   WHEN no_data_found THEN
      RAISE e_objtype;
END;

/* Get the profile option start/end dates  */
v_profile_start_value := fnd_profile.value_specific (
                                     'FEM_EFFECTIVE_START_DATE'
                                     ,fnd_global.user_id
                                     ,fnd_global.resp_id
                                     ,fnd_global.prog_appl_id);


v_profile_end_value := fnd_profile.value_specific (
                                     'FEM_EFFECTIVE_END_DATE'
                                     ,fnd_global.user_id
                                     ,fnd_global.resp_id
                                     ,fnd_global.prog_appl_id);

/*   Try to get the date value from the profile option
     if date value no good, just use the sysdate for start
     and maxdate for end*/
BEGIN

   IF v_profile_start_value IS NOT NULL THEN
      v_effective_start_date := to_date(v_profile_start_value,'YYYY-MM-DD');
   ELSE
      v_effective_start_date := sysdate;
   END IF;

EXCEPTION WHEN OTHERS THEN v_effective_start_date := null;
END;

BEGIN

   IF v_profile_end_value IS NOT NULL THEN
      v_effective_end_date := to_date(v_profile_end_value,'YYYY-MM-DD');
   ELSE
      v_effective_end_date := C_MAX_END_DATE;
   END IF;

EXCEPTION WHEN OTHERS THEN v_effective_end_date := null;
END;




/* create the snapshot */
fem_object_catalog_util_pkg.create_object (x_object_id => x_snapshot_object_id
,x_object_definition_id => x_snapshot_objdef_id
,X_MSG_COUNT => x_msg_count
,X_MSG_DATA  => x_msg_data
,X_RETURN_STATUS => x_return_status
,P_API_VERSION => C_API_VERSION
,P_COMMIT  => C_FALSE
,P_OBJECT_TYPE_CODE => p_snapshot_obj_type_code
,P_FOLDER_ID      => v_folder_id
,P_LOCAL_VS_COMBO_ID   => v_local_vs_combo_id
,P_OBJECT_ACCESS_CODE  => v_object_access_code
,P_OBJECT_ORIGIN_CODE  => v_object_origin_code
,P_OBJECT_NAME         => v_object_name||v_sysdate
,P_DESCRIPTION         => v_description
,P_EFFECTIVE_START_DATE => v_effective_start_date
,P_EFFECTIVE_END_DATE   => v_effective_end_date
,P_OBJ_DEF_NAME         => v_display_name);


IF x_return_status NOT IN (c_success) THEN
   RAISE e_noobj;
END IF;

/*  Need to update the description of the snapshot
    to be the same as the source default rule (since
    the create_object api doesn't allow us to specify
    description */
update fem_object_definition_tl
set description = v_objdef_desc
where object_definition_id = x_snapshot_objdef_id;


/*  Register the association between the snapshot and the true rule */
fem_helper_rule_util_pkg.register_helper_rule (
   p_rule_obj_def_id  => p_map_rule_obj_def_id,
   p_helper_obj_def_id => x_snapshot_objdef_id,
   p_helper_object_type_code => p_snapshot_obj_type_code,
   p_api_version  => c_api_version,
   p_init_msg_list => c_false,
   p_commit => c_false,
   p_encoded => c_true,
   x_return_status => x_return_status,
   x_msg_count => x_msg_count,
   x_msg_data  => x_msg_data);

IF x_return_status NOT IN (c_success) THEN
   RAISE e_helper_reg;
END IF;

x_return_status := c_success;

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;

IF FND_API.To_Boolean( p_commit ) THEN
   COMMIT WORK;
END IF;


EXCEPTION
 WHEN e_invalid_obj THEN
    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'Mapping Rule Object Definition does not exist'||p_map_rule_obj_def_id);
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded => p_encoded,
                              p_count => x_msg_count,
                              p_data => x_msg_data);
    ROLLBACK TO create_snapshot_pub;
    x_return_status := c_error;

 WHEN e_objtype THEN
    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'Snapshot object type must be either MAPPING_EDIT_SNAPSHOT or MAPPING_PREVIEW');
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded => p_encoded,
                              p_count => x_msg_count,
                              p_data => x_msg_data);
    ROLLBACK TO create_snapshot_pub;
    x_return_status := c_error;

 WHEN e_helper_reg THEN
    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'Unable to register Helper Rule metadata');
    FND_MSG_PUB.Count_And_Get(p_encoded => p_encoded,
                              p_count => x_msg_count,
                              p_data => x_msg_data);
    END IF;
    ROLLBACK TO create_snapshot_pub;
    x_return_status := c_error;

 WHEN e_noobj THEN
    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'Unable to create Snapshot Object and Object Definition ID');
    FND_MSG_PUB.Count_And_Get(p_encoded => p_encoded,
                              p_count => x_msg_count,
                              p_data => x_msg_data);
    END IF;
    ROLLBACK TO create_snapshot_pub;
    x_return_status := c_error;


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
    ROLLBACK TO create_snapshot_pub;
    x_return_status := c_unexp;


END create_snapshot;




/*************************************************************************

                       Refresh_maprule_from_snapshot

PURPOSE:  updates the true mapping rule definition with content from the
          Edit snapshot

*************************************************************************/

PROCEDURE refresh_maprule_from_snapshot (
   p_map_rule_obj_def_id IN NUMBER,
   p_api_version         IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list       IN VARCHAR2   DEFAULT c_false,
   p_commit              IN VARCHAR2   DEFAULT c_false,
   p_encoded             IN VARCHAR2   DEFAULT c_true,
   x_snapshot_objdef_id  OUT NOCOPY NUMBER,
   x_return_status       OUT NOCOPY VARCHAR2,
   x_msg_count           OUT NOCOPY NUMBER,
   x_msg_data            OUT NOCOPY VARCHAR2) IS

  C_MODULE            CONSTANT FND_LOG_MESSAGES.module%TYPE :=
     'fem.plsql.fem_alloc_br_util_pkg.refresh_maprule_from_snapshot';
  C_API_NAME          CONSTANT VARCHAR2(30)  := 'Refresh_maprule_from_Snapshot';
  C_SNAP_OBJTYPE      CONSTANT VARCHAR2(30)  := 'MAPPING_EDIT_SNAPSHOT';

  v_return_status   VARCHAR2(30);
  v_msg_count       NUMBER;
  v_msg_data        VARCHAR2(4000);

  v_helper_obj_def_id FEM_OBJECT_DEFINITION_B.object_definition_id%TYPE;
  v_snap_objdef_name FEM_OBJECT_DEFINITION_TL.display_name%TYPE;
  v_snap_objdef_desc FEM_OBJECT_DEFINITION_TL.description%TYPE;
  v_snap_start_date FEM_OBJECT_DEFINITION_B.effective_start_date%TYPE;
  v_snap_end_date FEM_OBJECT_DEFINITION_B.effective_start_date%TYPE;


  e_unexp       EXCEPTION;
  e_error       EXCEPTION;
  e_invalid_obj EXCEPTION;


  v_count number;

  cursor c1 (p_object_definition_id IN NUMBER) IS
     SELECT distinct sub_object_id, creation_date, last_update_date
     FROM fem_alloc_br_formula
     WHERE object_definition_id = p_object_definition_id
     AND sub_object_id IS NOT NULL;

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT  refresh_map_from_snapshot_pub;


  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;


  -- Initialize return status to unexpected error
  x_return_status := c_unexp;

  -- Check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (c_api_version,
                p_api_version,
                C_API_NAME,
                G_PKG_NAME)
  THEN
    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'API Version ('||C_API_VERSION||') not compatible with '
                    ||'passed in version ('||p_api_version||')');
    END IF;
    RAISE e_unexp;
  END IF;


  Validate_OA_Params (
    p_api_version => p_api_version,
    p_init_msg_list => p_init_msg_list,
    p_commit => p_commit,
    p_encoded => p_encoded,
    x_return_status => x_return_status);

  IF (x_return_status <> c_success) THEN
    RAISE e_error;
  END IF;



/* Verify the mapping rule is valid*/
BEGIN

   SELECT 1
   INTO v_count
   FROM fem_object_catalog_vl C, fem_object_definition_vl D
   WHERE D.object_id = C.object_id
   AND D.object_definition_id = p_map_rule_obj_def_id
   AND C.object_type_code IN (C_RULE_OBJTYPE, C_DFLT_OBJTYPE);

EXCEPTION
   WHEN no_data_found THEN
      RAISE e_invalid_obj;

END;

/* identify the edit snapshot for the mapping rule */
fem_helper_rule_util_pkg.get_helper_rule (
   p_rule_obj_def_id  => p_map_rule_obj_def_id,
   p_helper_object_type_code => C_SNAP_OBJTYPE,
   p_api_version    => C_API_VERSION,
   p_init_msg_list => C_FALSE,
   p_commit    => C_FALSE,
   p_encoded    => C_TRUE,
   x_return_status => v_return_status,
   x_msg_count   => v_msg_count,
   x_msg_data   => v_msg_data,
   x_helper_obj_def_id => v_helper_obj_def_id   );

IF v_return_status NOT IN (c_success) THEN
   RAISE e_unexp;
END IF;


/* delete the content for the true rule */
 FEM_BR_MAPPING_RULE_PVT.delete_map_rule_content(p_map_rule_obj_def_id);



IF x_return_status NOT IN (c_success) THEN
   RAISE e_unexp;
END IF;


/* copy the content from the snapshot to the true rule */
fem_br_mapping_rule_pvt.CopyObjectDefinition (
   p_copy_type_code => fem_business_rule_pvt.g_duplicate
  ,p_source_obj_def_id =>  v_helper_obj_def_id
  ,p_target_obj_def_id => p_map_rule_obj_def_id
  ,p_created_by => c_user_id
  ,p_creation_date => sysdate);

/*  update the objdef name/description */
SELECT display_name, description, effective_start_date, effective_end_date
INTO v_snap_objdef_name, v_snap_objdef_desc, v_snap_start_date, v_snap_end_date
FROM fem_object_definition_vl
WHERE object_definition_id = v_helper_obj_def_id;

UPDATE fem_object_definition_vl
SET display_name = v_snap_objdef_name, description = v_snap_objdef_desc,
    effective_start_date = v_snap_start_date, effective_end_date = v_snap_end_date
WHERE object_definition_id = p_map_rule_obj_def_id;

/* Refresh the data in fem_object_dependencies with the new dependency data
   for the rule.  */

DELETE FROM fem_object_dependencies
WHERE object_definition_id = p_map_rule_obj_def_id;

FOR subobj IN c1 (p_map_rule_obj_def_id) LOOP
   INSERT INTO fem_object_dependencies
     (OBJECT_DEFINITION_ID
     ,REQUIRED_OBJECT_ID
     ,CREATED_BY
     ,CREATION_DATE
     ,LAST_UPDATED_BY
     ,LAST_UPDATE_DATE
     ,LAST_UPDATE_LOGIN
     ,OBJECT_VERSION_NUMBER  )
   VALUES (p_map_rule_obj_def_id
          ,subobj.sub_object_id
          ,c_user_id
          ,subobj.creation_date
          ,c_user_id
          ,subobj.last_update_date
          ,c_login_id
          ,c_object_version);

END LOOP;

--Bug 6348530. Set the visual trace attributes.
set_VT_attributes(p_map_rule_obj_def_id);

x_snapshot_objdef_id := v_helper_obj_def_id;
x_return_status := c_success;



  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;

IF FND_API.To_Boolean( p_commit ) THEN
   COMMIT WORK;
END IF;


EXCEPTION
 WHEN e_invalid_obj THEN
    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'Mapping Rule Object Definition does not exist'||p_map_rule_obj_def_id);
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded => p_encoded,
                              p_count => x_msg_count,
                              p_data => x_msg_data);
    ROLLBACK TO refresh_map_from_snapshot_pub;
    x_return_status := c_error;



 WHEN OTHERS THEN
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
    ROLLBACK TO refresh_map_from_snapshot_pub;
    x_return_status := c_unexp;


END refresh_maprule_from_snapshot;




/*************************************************************************

                       Refresh_snapshot_from_maprule

PURPOSE:  updates the snapshot definition with content from the
          true mapping rule

*************************************************************************/

PROCEDURE refresh_snapshot_from_maprule (
   p_map_rule_obj_def_id IN NUMBER,
   p_api_version         IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list       IN VARCHAR2   DEFAULT c_false,
   p_commit              IN VARCHAR2   DEFAULT c_false,
   p_encoded             IN VARCHAR2   DEFAULT c_true,
   x_snapshot_objdef_id  OUT NOCOPY NUMBER,
   x_return_status       OUT NOCOPY VARCHAR2,
   x_msg_count           OUT NOCOPY NUMBER,
   x_msg_data            OUT NOCOPY VARCHAR2) IS

  C_MODULE            CONSTANT FND_LOG_MESSAGES.module%TYPE :=
     'fem.plsql.fem_alloc_br_util_pkg.refresh_snapshot_from_maprule';
  C_API_NAME          CONSTANT VARCHAR2(30)  := 'Refresh_Snapshot_from_snapshot';

  v_return_status   VARCHAR2(30);
  v_msg_count       NUMBER;
  v_msg_data        VARCHAR2(4000);

  v_helper_obj_def_id FEM_OBJECT_DEFINITION_B.object_definition_id%TYPE;

  v_maprule_objdef_name FEM_OBJECT_DEFINITION_TL.display_name%TYPE;
  v_maprule_objdef_desc FEM_OBJECT_DEFINITION_TL.description%TYPE;
  v_maprule_start_date FEM_OBJECT_DEFINITION_B.effective_start_date%TYPE;
  v_maprule_end_date FEM_OBJECT_DEFINITION_B.effective_start_date%TYPE;

  v_snapshot_object_id  FEM_OBJECT_DEFINITION_B.object_definition_id%TYPE;


  e_unexp       EXCEPTION;
  e_no_helper   EXCEPTION;
  e_error       EXCEPTION;
  e_invalid_obj EXCEPTION;
  e_objtype     EXCEPTION;


  v_count number;

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT  refresh_snapshot_from_map_pub;


  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;


  -- Initialize return status to unexpected error
  x_return_status := c_unexp;

  -- Check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (c_api_version,
                p_api_version,
                C_API_NAME,
                G_PKG_NAME)
  THEN
    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'API Version ('||C_API_VERSION||') not compatible with '
                    ||'passed in version ('||p_api_version||')');
    END IF;
    RAISE e_unexp;
  END IF;


  Validate_OA_Params (
    p_api_version => p_api_version,
    p_init_msg_list => p_init_msg_list,
    p_commit => p_commit,
    p_encoded => p_encoded,
    x_return_status => x_return_status);

  IF (x_return_status <> c_success) THEN
    RAISE e_error;
  END IF;


/* Verify the mapping rule is valid*/
BEGIN

   SELECT 1
   INTO v_count
   FROM fem_object_catalog_vl C, fem_object_definition_vl D
   WHERE D.object_id = C.object_id
   AND D.object_definition_id = p_map_rule_obj_def_id
   AND C.object_type_code IN (C_RULE_OBJTYPE, C_DFLT_OBJTYPE);

EXCEPTION
   WHEN no_data_found THEN
      RAISE e_invalid_obj;

END;

/* identify the edit snapshot for the mapping rule */
fem_helper_rule_util_pkg.get_helper_rule (
   p_rule_obj_def_id  => p_map_rule_obj_def_id,
   p_helper_object_type_code => C_SNAP_OBJTYPE,
   p_api_version    => C_API_VERSION,
   p_init_msg_list => C_FALSE,
   p_commit    => C_FALSE,
   p_encoded    => C_TRUE,
   x_return_status => v_return_status,
   x_msg_count   => v_msg_count,
   x_msg_data   => v_msg_data,
   x_helper_obj_def_id => v_helper_obj_def_id   );

IF v_return_status NOT IN (c_success) THEN

   create_snapshot (
      p_map_rule_obj_def_id => p_map_rule_obj_def_id,
      x_snapshot_object_id => v_snapshot_object_id,
      x_snapshot_objdef_id => v_helper_obj_def_id,
      x_return_status => x_return_status,
      x_msg_count   => v_msg_count,
      x_msg_data   => v_msg_data);

END IF;

IF x_return_status NOT IN (c_success) THEN
   RAISE e_unexp;
END IF;


/* delete the content for the snapshot */
  FEM_BR_MAPPING_RULE_PVT.delete_map_rule_content(v_helper_obj_def_id);


IF x_return_status NOT IN (c_success) THEN
   RAISE e_unexp;
END IF;


/* copy the content from the true rule to the snapshot */
fem_br_mapping_rule_pvt.CopyObjectDefinition (
   p_copy_type_code => fem_business_rule_pvt.g_duplicate
  ,p_source_obj_def_id => p_map_rule_obj_def_id
  ,p_target_obj_def_id => v_helper_obj_def_id
  ,p_created_by => c_user_id
  ,p_creation_date => sysdate);

/*  update the objdef name/description */
SELECT display_name, description, effective_start_date, effective_end_date
INTO v_maprule_objdef_name, v_maprule_objdef_desc,v_maprule_start_date, v_maprule_end_date
FROM fem_object_definition_vl
WHERE object_definition_id = p_map_rule_obj_def_id;

UPDATE fem_object_definition_vl
SET display_name = v_maprule_objdef_name, description = v_maprule_objdef_desc,
    effective_start_date = v_maprule_start_date, effective_end_date = v_maprule_end_date
WHERE object_definition_id = v_helper_obj_def_id;


x_snapshot_objdef_id := v_helper_obj_def_id;
x_return_status := c_success;

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;

IF FND_API.To_Boolean( p_commit ) THEN
   COMMIT WORK;
END IF;


EXCEPTION
 WHEN e_invalid_obj THEN
    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'Mapping Rule Object Definition does not exist '||p_map_rule_obj_def_id);
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded => p_encoded,
                              p_count => x_msg_count,
                              p_data => x_msg_data);
    ROLLBACK TO refresh_snapshot_from_map_pub;
    x_return_status := c_error;

 WHEN e_no_helper THEN
    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'Unable to identify snapshot for map_rule_obj_def_id = '||p_map_rule_obj_def_id);
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded => p_encoded,
                              p_count => x_msg_count,
                              p_data => x_msg_data);
    ROLLBACK TO refresh_snapshot_from_map_pub;
    x_return_status := c_error;



 WHEN OTHERS THEN
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
    ROLLBACK TO refresh_snapshot_from_map_pub;
    x_return_status := c_unexp;


END refresh_snapshot_from_maprule;



/*************************************************************************

                       Refresh_snapshot_from_defaults

PURPOSE:  updates the snapshot definition with content from the
          seeded default

HISTORY:
 6/26/2007 Rflippo Bug#6146396 Set any dimension cols in the Mapping Output list
                               = "SAME_AS_SOURCE" if they don't have a default
                               assigned in fem_alloc_br_dimensions for the
                               default rule

*************************************************************************/

PROCEDURE refresh_snapshot_from_defaults (
   p_map_rule_obj_def_id IN NUMBER,
   p_api_version         IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list       IN VARCHAR2   DEFAULT c_false,
   p_commit              IN VARCHAR2   DEFAULT c_false,
   p_encoded             IN VARCHAR2   DEFAULT c_true,
   x_snapshot_objdef_id  OUT NOCOPY NUMBER,
   x_return_status       OUT NOCOPY VARCHAR2,
   x_msg_count           OUT NOCOPY NUMBER,
   x_msg_data            OUT NOCOPY VARCHAR2) IS

  C_MODULE            CONSTANT FND_LOG_MESSAGES.module%TYPE :=
     'fem.plsql.fem_alloc_br_util_pkg.refresh_snapshot_from_defaults';
  C_API_NAME          CONSTANT VARCHAR2(30)  := 'Refresh_Snapshot_from_defaults';

  v_return_status   VARCHAR2(30);
  v_msg_count       NUMBER;
  v_msg_data        VARCHAR2(4000);

  v_dflt_obj_def_id FEM_OBJECT_DEFINITION_B.object_definition_id%TYPE;
  v_map_rule_type_code FEM_ALLOC_BR_OBJECTS.map_rule_type_code%TYPE;
  v_helper_obj_def_id FEM_OBJECT_DEFINITION_B.object_definition_id%TYPE;
  v_global_vs_combo_id fem_global_vs_combos_b.global_vs_combo_id%TYPE;

  e_unexp       EXCEPTION;
  e_no_default   EXCEPTION;
  e_error       EXCEPTION;
  e_invalid_obj EXCEPTION;
  e_no_helper   EXCEPTION;



  v_count number;



BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT  refresh_snapshot_from_dflt_pub;


  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;


  -- Initialize return status to unexpected error
  x_return_status := c_unexp;

  -- Check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (c_api_version,
                p_api_version,
                C_API_NAME,
                G_PKG_NAME)
  THEN
    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'API Version ('||C_API_VERSION||') not compatible with '
                    ||'passed in version ('||p_api_version||')');
    END IF;
    RAISE e_unexp;
  END IF;


  Validate_OA_Params (
    p_api_version => p_api_version,
    p_init_msg_list => p_init_msg_list,
    p_commit => p_commit,
    p_encoded => p_encoded,
    x_return_status => x_return_status);

  IF (x_return_status <> c_success) THEN
    RAISE e_error;
  END IF;


/* Verify the mapping rule is valid*/
BEGIN

   SELECT O.map_rule_type_code
   INTO v_map_rule_type_code
   FROM fem_object_catalog_vl C, fem_object_definition_vl D,
        fem_alloc_br_objects O
   WHERE D.object_id = C.object_id
   AND D.object_definition_id = p_map_rule_obj_def_id
   AND C.object_type_code = 'MAPPING_RULE'
   AND C.object_id = O.map_rule_object_id;

EXCEPTION
   WHEN no_data_found THEN
      RAISE e_invalid_obj;

END;

/* identify the default definition for the mapping rule */
   v_global_vs_combo_id := fem_dimension_util_pkg.global_vs_combo_id(
         p_ledger_id => null
        ,x_return_status => v_return_status
        ,x_msg_count => v_msg_count
        ,x_msg_data => v_msg_data);

BEGIN
   SELECT min (D.object_definition_id)
   INTO v_dflt_obj_def_id
   FROM fem_object_definition_b D, fem_alloc_br_objects O,
        fem_object_catalog_b C
   WHERE C.object_id = D.object_id
   AND C.object_type_code = C_DFLT_OBJTYPE
   AND C.object_id = O.map_rule_object_id
   AND O.map_rule_type_code = v_map_rule_type_code
   AND C.local_vs_combo_id = v_global_vs_combo_id;

EXCEPTION

   WHEN no_data_found THEN v_dflt_obj_def_id := null;

END;

IF v_dflt_obj_def_id IS NULL THEN
      RAISE e_no_default;
END IF;
/* identify the edit snapshot for the mapping rule */
fem_helper_rule_util_pkg.get_helper_rule (
   p_rule_obj_def_id  => p_map_rule_obj_def_id,
   p_helper_object_type_code => C_SNAP_OBJTYPE,
   p_api_version    => C_API_VERSION,
   p_init_msg_list => C_FALSE,
   p_commit    => C_FALSE,
   p_encoded    => C_TRUE,
   x_return_status => v_return_status,
   x_msg_count   => v_msg_count,
   x_msg_data   => v_msg_data,
   x_helper_obj_def_id => v_helper_obj_def_id   );

IF v_return_status NOT IN (c_success) THEN
   RAISE e_no_helper;
END IF;


/* delete the content for the snapshot */
  FEM_BR_MAPPING_RULE_PVT.delete_map_rule_content(v_helper_obj_def_id);


IF x_return_status NOT IN (c_success) THEN
   RAISE e_unexp;
END IF;


/* copy the content from the default rule to the snapshot */
fem_br_mapping_rule_pvt.CopyObjectDefinition (
   p_copy_type_code => fem_business_rule_pvt.g_duplicate
  ,p_source_obj_def_id => v_dflt_obj_def_id
  ,p_target_obj_def_id => v_helper_obj_def_id
  ,p_created_by => c_user_id
  ,p_creation_date => sysdate);

/*Bug#6146396 Set any dimension cols in the Mapping Output list
  that do not have a default assigned to "SAME_AS_SOURCE"
  */
  set_dim_usage_dflt (v_helper_obj_def_id);

x_snapshot_objdef_id := v_helper_obj_def_id;
x_return_status := c_success;

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;

IF FND_API.To_Boolean( p_commit ) THEN
   COMMIT WORK;
END IF;


EXCEPTION
 WHEN e_invalid_obj THEN
    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'Mapping Rule Object Definition does not exist '||p_map_rule_obj_def_id);
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded => p_encoded,
                              p_count => x_msg_count,
                              p_data => x_msg_data);
    ROLLBACK TO refresh_snapshot_from_dflt_pub;
    x_return_status := c_error;

 WHEN e_no_default THEN
    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'Mapping Rule defaults seed data is missing');
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded => p_encoded,
                              p_count => x_msg_count,
                              p_data => x_msg_data);
    ROLLBACK TO refresh_snapshot_from_dflt_pub;
    x_return_status := c_error;

WHEN e_no_helper THEN
    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'Unable to identify snapshot for map_rule_obj_def_id = '||p_map_rule_obj_def_id);
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded => p_encoded,
                              p_count => x_msg_count,
                              p_data => x_msg_data);
    ROLLBACK TO refresh_snapshot_from_dflt_pub;
    x_return_status := c_error;



 WHEN OTHERS THEN
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
    ROLLBACK TO refresh_snapshot_from_dflt_pub;
    x_return_status := c_unexp;


END refresh_snapshot_from_defaults;



/*************************************************************************

                       get_default_definition

PURPOSE:  This procedure queries the db for a default rule definition
          for the given rule type.  If one exists, it returns it.  If
          one does not exist, it creates and copies the content from
          the seeded default rule definition of that type.

06-JUL-07 RFlippo  When creating a default rule, get the obj def name
                   and description from the seeded default rule
*************************************************************************/

PROCEDURE get_default_definition (
   p_map_rule_type_code  IN VARCHAR2,
   p_target_folder_id    IN VARCHAR2   DEFAULT NULL,
   p_api_version         IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list       IN VARCHAR2   DEFAULT c_false,
   p_commit              IN VARCHAR2   DEFAULT c_false,
   p_encoded             IN VARCHAR2   DEFAULT c_true,
   x_dflt_objdef_id      OUT NOCOPY NUMBER,
   x_return_status       OUT NOCOPY VARCHAR2,
   x_msg_count           OUT NOCOPY NUMBER,
   x_msg_data            OUT NOCOPY VARCHAR2) IS

  C_MODULE            CONSTANT FND_LOG_MESSAGES.module%TYPE :=
     'fem.plsql.fem_alloc_br_util_pkg.get_default_definition';
  C_API_NAME          CONSTANT VARCHAR2(30)  := 'Get_default_definition';

  v_return_status   VARCHAR2(30);
  v_msg_count       NUMBER;
  v_msg_data        VARCHAR2(4000);

  v_count           NUMBER;

  v_dflt_obj_def_id FEM_OBJECT_DEFINITION_B.object_definition_id%TYPE;
  v_map_rule_type_code FEM_ALLOC_BR_OBJECTS.map_rule_type_code%TYPE;
  v_helper_obj_def_id FEM_OBJECT_DEFINITION_B.object_definition_id%TYPE;

  v_global_vs_combo_id fem_global_vs_combos_b.global_vs_combo_id%TYPE;
  v_object_name fem_object_catalog_tl.object_name%TYPE;
  v_description fem_object_catalog_tl.description%TYPE;
  v_dflt_object_id fem_object_catalog_b.object_id%TYPE;
  v_seeded_dflt_obj_def_id fem_object_definition_b.object_definition_id%TYPE;
  v_seeded_dflt_object_id fem_object_catalog_b.object_id%TYPE;
  v_new_dflt_object_id fem_object_catalog_b.object_id%TYPE;
  v_folder_id fem_object_catalog_b.folder_id%TYPE;
  v_dflt_folder_id fem_object_catalog_b.folder_id%TYPE;

  v_profile_start_value VARCHAR2(1000);
  v_profile_end_value VARCHAR2(1000);
  v_effective_start_date DATE;
  v_effective_end_date DATE;
  v_objdef_name VARCHAR2(150);
  v_objdef_desc VARCHAR2(255);


  e_unexp       EXCEPTION;
  e_no_default   EXCEPTION;
  e_error       EXCEPTION;
  e_noobj EXCEPTION;
  e_no_helper   EXCEPTION;
  e_no_seeded_dflt EXCEPTION;
  e_invalid_rule_type EXCEPTION;



BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT  get_dflt_def_pub;


  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;


  -- Initialize return status to unexpected error
  x_return_status := c_unexp;

  -- Check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (c_api_version,
                p_api_version,
                C_API_NAME,
                G_PKG_NAME)
  THEN
    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'API Version ('||C_API_VERSION||') not compatible with '
                    ||'passed in version ('||p_api_version||')');
    END IF;
    RAISE e_unexp;
  END IF;


  Validate_OA_Params (
    p_api_version => p_api_version,
    p_init_msg_list => p_init_msg_list,
    p_commit => p_commit,
    p_encoded => p_encoded,
    x_return_status => x_return_status);

  IF (x_return_status <> c_success) THEN
    RAISE e_error;
  END IF;

/* Verify the rule type is valid*/

   SELECT count(*)
   INTO v_count
   FROM fem_map_rule_types_b
   WHERE map_rule_type_code = p_map_rule_type_code;

   IF v_count = 0 THEN
      RAISE e_invalid_rule_type;
   END IF;


/* identify the default definition for the rule type and gvsc*/
BEGIN

   v_global_vs_combo_id := fem_dimension_util_pkg.global_vs_combo_id(
         p_ledger_id => null
        ,x_return_status => v_return_status
        ,x_msg_count => v_msg_count
        ,x_msg_data => v_msg_data);

   SELECT min (D.object_definition_id)
   INTO x_dflt_objdef_id
   FROM fem_object_definition_b D, fem_alloc_br_objects O,
        fem_object_catalog_b C
   WHERE C.object_id = D.object_id
   AND C.object_type_code = C_DFLT_OBJTYPE
   AND C.object_id = O.map_rule_object_id
   AND O.map_rule_type_code = p_map_rule_type_code
   AND C.local_vs_combo_id = v_global_vs_combo_id;




EXCEPTION
   WHEN no_data_found THEN x_dflt_objdef_id := null;
END;

IF x_dflt_objdef_id IS NULL THEN
/* No default definition for this gvsc, so we're going to create one */
      BEGIN
      /* Identify the seeded default rule where gvsc = null for this rule type */
         SELECT D1.objdef, C1.object_id
         INTO v_seeded_dflt_obj_def_id,v_seeded_dflt_object_id
         FROM
         (SELECT min (D.object_definition_id) objdef
         FROM fem_object_definition_b D, fem_alloc_br_objects O,
              fem_object_catalog_b C
         WHERE C.object_id = D.object_id
         AND C.object_type_code = C_DFLT_OBJTYPE
         AND C.object_id = O.map_rule_object_id
         AND O.map_rule_type_code = p_map_rule_type_code
         AND C.local_vs_combo_id IS NULL) D1,
         fem_object_definition_b C1
         WHERE D1.objdef = C1.object_definition_id;



      EXCEPTION
         WHEN no_data_found THEN
            raise e_no_seeded_dflt;
      END;


      SELECT object_name, description, folder_id
      INTO v_object_name, v_description, v_dflt_folder_id
      FROM fem_object_catalog_vl C
      WHERE object_id = v_seeded_dflt_object_id;

      IF p_target_folder_id IS NULL THEN
         v_folder_id := v_dflt_folder_id;
      ELSE v_folder_id := p_target_folder_id;
      END IF;

      SELECT display_name, description
      INTO v_objdef_name, v_objdef_desc
      FROM fem_object_definition_vl
      WHERE object_definition_id = v_seeded_dflt_obj_def_id;

      /* Get the profile option start/end dates  */
      v_profile_start_value := fnd_profile.value_specific (
                                     'FEM_EFFECTIVE_START_DATE'
                                     ,fnd_global.user_id
                                     ,fnd_global.resp_id
                                     ,fnd_global.prog_appl_id);


      v_profile_end_value := fnd_profile.value_specific (
                                     'FEM_EFFECTIVE_END_DATE'
                                     ,fnd_global.user_id
                                     ,fnd_global.resp_id
                                     ,fnd_global.prog_appl_id);

      /*   Try to get the date value from the profile option
           if date value no good, just use the sysdate for start
           and maxdate for end*/
      BEGIN

         IF v_profile_start_value IS NOT NULL THEN
            v_effective_start_date := to_date(v_profile_start_value,'YYYY-MM-DD');
         ELSE
            v_effective_start_date := sysdate;
         END IF;

      EXCEPTION WHEN OTHERS THEN v_effective_start_date := null;
      END;

      BEGIN

         IF v_profile_end_value IS NOT NULL THEN
            v_effective_end_date := to_date(v_profile_end_value,'YYYY-MM-DD');
         ELSE
            v_effective_end_date := C_MAX_END_DATE;
         END IF;

      EXCEPTION WHEN OTHERS THEN v_effective_end_date := null;
      END;


      /* create the new default definition
         Note that to ensure uniqueness, the object_name is
         concatenated with the global combo*/
      fem_object_catalog_util_pkg.create_object (x_object_id => v_new_dflt_object_id
      ,x_object_definition_id => x_dflt_objdef_id
      ,X_MSG_COUNT => x_msg_count
      ,X_MSG_DATA  => x_msg_data
      ,X_RETURN_STATUS => x_return_status
      ,P_API_VERSION => C_API_VERSION
      ,P_COMMIT  => C_FALSE
      ,P_OBJECT_TYPE_CODE => C_DFLT_OBJTYPE
      ,P_FOLDER_ID      => v_folder_id
      ,P_LOCAL_VS_COMBO_ID   => v_global_vs_combo_id
      ,P_OBJECT_ACCESS_CODE  => 'W'
      ,P_OBJECT_ORIGIN_CODE  => 'USER'
      ,P_OBJECT_NAME         => v_object_name||':'||v_global_vs_combo_id
      ,P_DESCRIPTION         => v_description
      ,P_EFFECTIVE_START_DATE => v_effective_start_date
      ,P_EFFECTIVE_END_DATE   => v_effective_end_date
      ,P_OBJ_DEF_NAME         => v_objdef_name);

      IF x_return_status NOT IN (c_success) THEN
         RAISE e_noobj;
      END IF;

/*  Update the default rule description (for all languages),
    since we couldn't provide it when we created the default rule object */
UPDATE fem_object_definition_tl
SET description = v_objdef_desc
WHERE object_definition_id = x_dflt_objdef_id;

/* copy the content from the seeded gvsc = null default rule to the new default rule */
fem_br_mapping_rule_pvt.CopyObjectDefinition (
   p_copy_type_code => fem_business_rule_pvt.g_duplicate
  ,p_source_obj_def_id => v_seeded_dflt_obj_def_id
  ,p_target_obj_def_id => x_dflt_objdef_id
  ,p_created_by => c_user_id
  ,p_creation_date => sysdate);

/* Insert the rule type information into fem_alloc_br_objects   */
  INSERT INTO fem_alloc_br_objects (
   MAP_RULE_OBJECT_ID
   ,MAP_RULE_TYPE_CODE
   ,OBJECT_VERSION_NUMBER
   ,CREATION_DATE
   ,CREATED_BY
   ,LAST_UPDATED_BY
   ,LAST_UPDATE_DATE
   ,LAST_UPDATE_LOGIN )
   VALUES (v_new_dflt_object_id
   , p_map_rule_type_code
   ,1
   ,sysdate
   ,C_USER_ID
   ,C_USER_ID
   ,sysdate
   ,C_LOGIN_ID);


END IF;
x_return_status := c_success;

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;

IF FND_API.To_Boolean( p_commit ) THEN
   COMMIT WORK;
END IF;


EXCEPTION
 WHEN e_invalid_rule_type THEN
    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'Mapping Rule Type does not exist '||p_map_rule_type_code);
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded => p_encoded,
                              p_count => x_msg_count,
                              p_data => x_msg_data);
    ROLLBACK TO get_dflt_def_pub;
    x_return_status := c_error;

 WHEN e_no_seeded_dflt THEN
    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'Mapping Rule defaults seed data is missing');
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded => p_encoded,
                              p_count => x_msg_count,
                              p_data => x_msg_data);
    ROLLBACK TO get_dflt_def_pub;
    x_return_status := c_error;

WHEN e_noobj THEN
    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'Unable to create object for default rule type = '||p_map_rule_type_code||
                      ' and global_vs_combo_id ='||v_global_vs_combo_id);
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded => p_encoded,
                              p_count => x_msg_count,
                              p_data => x_msg_data);
    ROLLBACK TO get_dflt_def_pub;
    x_return_status := c_error;



 WHEN OTHERS THEN
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
    ROLLBACK TO get_dflt_def_pub;
    x_return_status := c_unexp;


END get_default_definition;




/*************************************************************************

                         OA Exception Handler

*************************************************************************/

PROCEDURE Validate_OA_Params (
   p_api_version     IN NUMBER,
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

CASE p_api_version
   WHEN c_api_version THEN NULL;
   ELSE RAISE e_bad_p_api_ver;
END CASE;

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
   WHEN e_bad_p_api_ver THEN
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_BAD_P_API_VER_ERR',
         p_token1 => 'VALUE',
         p_value1 => p_api_version);
      x_return_status := c_error;

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

/*************************************************************************

                         get_rule_dirty_flag
   This function identifies if the content for a true mapping rule matches
   the content stored in the edit snapshot for that rule

*************************************************************************/
FUNCTION get_rule_dirty_flag (p_map_rule_obj_def_id IN NUMBER) RETURN VARCHAR2 IS

v_helper_obj_def_id    NUMBER;

v_rule_date            DATE;
v_snaprule_date        DATE;

C_SNAP_OBJTYPE      CONSTANT VARCHAR2(30)  := 'MAPPING_EDIT_SNAPSHOT';

v_return_status   VARCHAR2(30);
v_msg_count       NUMBER;
v_msg_data        VARCHAR2(4000);

e_dirty_rule       EXCEPTION;

TYPE cv_curs IS REF CURSOR;
TYPE date_type IS TABLE OF DATE INDEX BY BINARY_INTEGER;
TYPE nbr_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE char_type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

cv_get_ruleformuladata cv_curs;
cv_get_snapformuladata cv_curs;
cv_get_ruledimdata     cv_curs;
cv_get_snapdimdata     cv_curs;

v_br_cost_flag VARCHAR2(1);
v_br_acc_flag  VARCHAR2(1);
v_sbr_cost_flag VARCHAR2(1);
v_sbr_acc_flag VARCHAR2(1);

t_br_function_seq nbr_type;
t_br_function_cd char_type;
t_br_sub_object_id nbr_type;
t_br_value nbr_type;
t_br_table_name char_type;
t_br_column_name char_type;
t_br_math char_type;
t_br_form_macro_cd char_type;
t_br_force char_type;
t_br_enable char_type;
t_br_post_to_ledger char_type;
t_br_open char_type;
t_br_close char_type;
t_br_apply char_type;

t_br_dim_col char_type;
t_br_post_to_balances char_type;
t_br_alloc_dim_usage char_type;
t_br_dim_value nbr_type;
t_br_dim_value_char char_type;
t_br_percent char_type;

t_sbr_function_seq nbr_type;
t_sbr_function_cd char_type;
t_sbr_sub_object_id nbr_type;
t_sbr_value nbr_type;
t_sbr_table_name char_type;
t_sbr_column_name char_type;
t_sbr_math char_type;
t_sbr_form_macro_cd char_type;
t_sbr_force char_type;
t_sbr_enable char_type;
t_sbr_post_to_ledger char_type;
t_sbr_open char_type;
t_sbr_close char_type;
t_sbr_apply char_type;

t_sbr_dim_col char_type;
t_sbr_post_to_balances char_type;
t_sbr_alloc_dim_usage char_type;
t_sbr_dim_value nbr_type;
t_sbr_dim_value_char char_type;
t_sbr_percent char_type;



v_sql       VARCHAR2(4000);

BEGIN


/* identify the edit snapshot for the mapping rule */
fem_helper_rule_util_pkg.get_helper_rule (
   p_rule_obj_def_id  => p_map_rule_obj_def_id,
   p_helper_object_type_code => C_SNAP_OBJTYPE,
   p_api_version    => C_API_VERSION,
   p_init_msg_list => C_FALSE,
   p_commit    => C_FALSE,
   p_encoded    => C_TRUE,
   x_return_status => v_return_status,
   x_msg_count   => v_msg_count,
   x_msg_data   => v_msg_data,
   x_helper_obj_def_id => v_helper_obj_def_id   );

IF v_return_status NOT IN (c_success) THEN
   RAISE e_dirty_rule;
END IF;


/* get the business rule data */
SELECT cost_contribution_flag, accumulate_flag
INTO v_br_cost_flag,v_br_acc_flag
FROM fem_alloc_business_rule
WHERE object_definition_id = p_map_rule_obj_def_id;

/* get the snapshot business rule data */
SELECT cost_contribution_flag, accumulate_flag
INTO v_sbr_cost_flag,v_sbr_acc_flag
FROM fem_alloc_business_rule
WHERE object_definition_id = v_helper_obj_def_id;


IF v_br_cost_flag <> v_sbr_cost_flag OR v_br_acc_flag <> v_sbr_acc_flag THEN
  RAISE e_dirty_rule;
END IF;

/* get br_formula data */
v_sql := 'SELECT function_seq, function_cd, sub_object_id, value, table_name, '||
         'column_name, math_operator_cd,formula_macro_cd,force_to_100_flg,'||
         'enable_flg, post_to_ledger_flg, open_paren, close_paren,'||
         'apply_to_debit_code'||
         ' FROM fem_alloc_br_formula'||
         ' WHERE object_definition_id = :1'||
         ' ORDER BY function_seq';

OPEN cv_get_ruleformuladata FOR v_sql USING p_map_rule_obj_def_id;

FETCH cv_get_ruleformuladata BULK COLLECT
INTO t_br_function_seq
    ,t_br_function_cd
    ,t_br_sub_object_id
    ,t_br_value
    ,t_br_table_name
    ,t_br_column_name
    ,t_br_math
    ,t_br_form_macro_cd
    ,t_br_force
    ,t_br_enable
    ,t_br_post_to_ledger
    ,t_br_open
    ,t_br_close
    ,t_br_apply;


OPEN cv_get_snapformuladata FOR v_sql USING v_helper_obj_def_id;
FETCH cv_get_snapformuladata BULK COLLECT
INTO t_sbr_function_seq
    ,t_sbr_function_cd
    ,t_sbr_sub_object_id
    ,t_sbr_value
    ,t_sbr_table_name
    ,t_sbr_column_name
    ,t_sbr_math
    ,t_sbr_form_macro_cd
    ,t_sbr_force
    ,t_sbr_enable
    ,t_sbr_post_to_ledger
    ,t_sbr_open
    ,t_sbr_close
    ,t_sbr_apply;


IF t_br_function_seq.LAST = t_sbr_function_seq.LAST THEN
   FOR i IN 1..t_br_function_seq.LAST LOOP
      IF t_br_function_seq(i) <> t_sbr_function_seq(i) OR
         t_br_function_cd(i) <> t_sbr_function_cd(i) OR
         t_br_sub_object_id(i) <> t_sbr_sub_object_id(i) OR
         t_br_value(i) <> t_sbr_value(i) OR
         t_br_table_name(i) <> t_sbr_table_name(i) OR
         t_br_column_name(i) <> t_sbr_column_name(i) OR
         t_br_math(i) <> t_sbr_math(i) OR
         t_br_form_macro_cd(i) <> t_sbr_form_macro_cd(i) OR
         t_br_force(i) <> t_sbr_force(i) OR
         t_br_enable(i) <> t_sbr_enable(i) OR
         t_br_post_to_ledger(i) <> t_sbr_post_to_ledger(i) OR
         t_br_open(i) <> t_sbr_open(i) OR
         t_br_close(i) <> t_sbr_close(i) OR
         t_br_apply(i) <> t_sbr_apply(i) THEN
         RAISE e_dirty_rule;
      END IF;
   END LOOP;
ELSE RAISE e_dirty_rule;
END IF;

t_br_function_seq.DELETE;
t_br_function_cd.DELETE;
t_sbr_function_seq.DELETE;
t_sbr_function_cd.DELETE;


/* get br_dimensions data */
v_sql := 'SELECT function_seq, alloc_dim_col_name, post_to_balances_flag, '||
         'function_cd, alloc_dim_usage_code, dimension_value, dimension_value_char,'||
         'percent_distribution_code'||
         ' FROM fem_alloc_br_dimensions'||
         ' WHERE object_definition_id = :1'||
         ' ORDER BY function_seq, alloc_dim_col_name, post_to_balances_flag';

OPEN cv_get_ruledimdata FOR v_sql USING p_map_rule_obj_def_id;
FETCH cv_get_ruledimdata BULK COLLECT
INTO t_br_function_seq
    ,t_br_dim_col
    ,t_br_post_to_balances
    ,t_br_function_cd
    ,t_br_alloc_dim_usage
    ,t_br_dim_value
    ,t_br_dim_value_char
    ,t_br_percent;


OPEN cv_get_snapdimdata FOR v_sql USING v_helper_obj_def_id;
FETCH cv_get_snapdimdata BULK COLLECT
INTO t_sbr_function_seq
    ,t_sbr_dim_col
    ,t_sbr_post_to_balances
    ,t_sbr_function_cd
    ,t_sbr_alloc_dim_usage
    ,t_sbr_dim_value
    ,t_sbr_dim_value_char
    ,t_sbr_percent;

IF t_br_function_seq.LAST = t_sbr_function_seq.LAST THEN
   FOR i IN 1..t_br_function_seq.LAST LOOP
      IF t_br_function_seq(i) <> t_sbr_function_seq(i) OR
         t_br_dim_col(i) <> t_sbr_dim_col(i) OR
         t_br_post_to_balances(i) <> t_sbr_post_to_balances(i) OR
         t_br_function_cd(i) <> t_sbr_function_cd(i) OR
         t_br_alloc_dim_usage(i) <> t_sbr_alloc_dim_usage(i) OR
         t_br_dim_value(i) <> t_sbr_dim_value(i) OR
         t_br_dim_value_char(i) <> t_sbr_dim_value_char(i) OR
         t_br_percent(i) <> t_sbr_percent(i) THEN
         RAISE e_dirty_rule;
      END IF;
   END LOOP;
ELSE RAISE e_dirty_rule;
END IF;

CLOSE cv_get_ruleformuladata;
CLOSE cv_get_snapformuladata;
CLOSE cv_get_ruledimdata;
CLOSE cv_get_snapdimdata;

RETURN 'N';

EXCEPTION
   WHEN e_dirty_rule THEN return 'Y';

   WHEN OTHERS THEN return 'Y';

END get_rule_dirty_flag;


/*************************************************************************

                         generate_condition_summary
   This procedure generates the condition summary info and populates the
   FEM_ALLOC_BR_COND_SUM_GT table with it

*************************************************************************/
PROCEDURE generate_condition_summary (
    p_condition_object_id IN NUMBER,
    p_api_version         IN NUMBER     DEFAULT c_api_version,
    p_init_msg_list       IN VARCHAR2   DEFAULT c_false,
    p_commit              IN VARCHAR2   DEFAULT c_false,
    p_encoded             IN VARCHAR2   DEFAULT c_true,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2) IS

   C_MODULE            CONSTANT FND_LOG_MESSAGES.module%TYPE :=
      'fem.plsql.fem_alloc_br_util_pkg.generate_condition_summary';
   C_API_NAME          CONSTANT VARCHAR2(30)  := 'Generate_condition_summary';

   v_return_status             VARCHAR2(30);
   v_msg_count                 NUMBER;
   v_msg_data                  VARCHAR2(4000);

   e_unexp                     EXCEPTION;
   e_invalid_obj               EXCEPTION;

   v_cond_obj_def_id           NUMBER;

   v_sql varchar2(4000);

   -- Dimension Component Properties
   v_table_name                FEM_ALLOC_BR_COND_SUM_GT.table_display_name%TYPE;
   v_cond_type_code            FEM_LOOKUPS.lookup_code%TYPE;
   v_cond_type                 FEM_ALLOC_BR_COND_SUM_GT.condition_type%TYPE;
   v_cond_column               FEM_ALLOC_BR_COND_SUM_GT.column_display_name%TYPE;
   v_cond_value                FEM_ALLOC_BR_COND_SUM_GT.condition_value%TYPE;
   v_temp_cond_value           FEM_ALLOC_BR_COND_SUM_GT.condition_value%TYPE;
   v_temp_min_cond_value       FEM_ALLOC_BR_COND_SUM_GT.condition_value%TYPE;
   v_temp_max_cond_value       FEM_ALLOC_BR_COND_SUM_GT.condition_value%TYPE;
   v_hier_attr                 FEM_ALLOC_BR_COND_SUM_GT.hier_attr_display_name%TYPE;
   v_dim_comp_type             VARCHAR2(1); -- Not shown on the screen - differentiates
                                -- hierarchy components from Attribute components
   v_value_set_id              NUMBER; -- Not shown on the screen - identifies the value_set
                                       -- if the member comes from a value set dimension


   v_any_table            FEM_LOOKUPS.meaning%TYPE;
   v_operator_name             FEM_LOOKUPS.meaning%TYPE;
   v_and_name                  FEM_LOOKUPS.meaning%TYPE;
   -- Dimension Metadata
   v_member_table              VARCHAR2(30);
   v_member_col                VARCHAR2(30);
   v_member_name_col           VARCHAR2(30);
   v_vsr_flag                  VARCHAR2(1); -- value_set_required_flag for the dimension


   cursor c_objdef (p_cond_object_id IN NUMBER) IS
      SELECT object_definition_id
      FROM fem_object_definition_b
      WHERE object_id = p_cond_object_id
      ORDER BY effective_end_date;

   -- Identify the condition components for that Condition Object:
   cursor c_comp (p_object_definition_id IN NUMBER) IS
      SELECT C.cond_component_obj_id, O.object_definition_id cond_comp_obj_def_id,
             C.data_dim_flag,
             OB.local_vs_combo_id global_vs_combo_id
      FROM fem_cond_components C,
           fem_object_definition_b O,
           fem_object_catalog_b OB
      WHERE C.cond_component_obj_id = O.object_id
      AND C.condition_obj_def_id = p_object_definition_id
      AND O.object_id = OB.object_id;


   cursor c_dimcomp (p_cond_comp_obj_def_id IN NUMBER) IS
      SELECT D.dim_comp_type, D.dim_id, D.dim_column, D.value,
             T.dimension_name
      FROM fem_cond_dim_components D,
           fem_dimensions_vl T
      WHERE D.cond_dim_cmp_obj_def_id = p_cond_comp_obj_def_id
      AND D.dim_id = T.dimension_id;


   cursor c_hier (p_cond_obj_def_id IN NUMBER) IS
      SELECT D.hierarchy_obj_id, O.object_name
      FROM (SELECT DISTINCT hierarchy_obj_id
            FROM fem_cond_dim_cmp_dtl D
            WHERE cond_dim_cmp_obj_def_id = p_cond_obj_def_id) D,
      fem_object_catalog_vl O
      WHERE D.hierarchy_obj_id = O.object_id;


   cursor c_attr (p_cond_obj_def_id IN NUMBER, p_dimension_id IN NUMBER) IS
      SELECT A.attribute_id, A.attribute_name, A.attribute_dimension_id,
             A.attribute_data_type_code, D.dim_attr_value
      FROM fem_dim_attributes_vl A, fem_cond_dim_cmp_dtl D, fem_cond_dim_components C
      WHERE A.dimension_id = p_dimension_id
      AND A.dimension_id = C.dim_id
      AND D.cond_dim_cmp_obj_def_id = p_cond_obj_def_id
      AND D.cond_dim_cmp_obj_def_id = C.cond_dim_cmp_obj_def_id
      AND A.attribute_varchar_label = D.dim_attr_varchar_label;

   cursor c_steps (p_cond_comp_obj_def_id IN NUMBER) IS
      SELECT S.step_sequence, S.table_name, S.step_type, S.column_name, S.operator,
             D.value, D.max_range_value,
             T.fem_data_type_code, T.dimension_id, T.display_name col_display_name, TA.display_name table_display_name
      FROM fem_cond_data_cmp_steps S, fem_cond_data_cmp_st_dtl D,
           fem_tab_columns_vl T, fem_tables_vl TA
      WHERE S.step_sequence = D.step_sequence
      AND S.cond_data_cmp_obj_def_id = D.cond_data_cmp_obj_def_id
      AND S.table_name= D.table_name
      AND S.cond_data_cmp_obj_def_id = p_cond_comp_obj_def_id
      AND S.table_name = T.table_name
      AND S.column_name = T.column_name
      AND T.table_name = TA.table_name;


BEGIN

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;


  -- Initialize return status to unexpected error
  x_return_status := c_unexp;

  -- Check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (c_api_version,
                p_api_version,
                C_API_NAME,
                G_PKG_NAME)
  THEN
    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'API Version ('||C_API_VERSION||') not compatible with '
                    ||'passed in version ('||p_api_version||')');
    END IF;
    RAISE e_unexp;
  END IF;


  Validate_OA_Params (
    p_api_version => p_api_version,
    p_init_msg_list => p_init_msg_list,
    p_commit => p_commit,
    p_encoded => p_encoded,
    x_return_status => x_return_status);

  IF (x_return_status <> c_success) THEN
    RAISE e_unexp;
  END IF;


   -- initialize
   DELETE FROM fem_alloc_br_cond_sum_gt
   WHERE condition_obj_def_id IN (SELECT object_definition_id
   FROM fem_object_definition_b
   WHERE object_id = p_condition_object_id);

   SELECT meaning
   INTO v_any_table
   FROM fem_lookups
   WHERE lookup_type = 'FEM_CONDITION_TABLE_MACROS'
   AND lookup_code = 'ANY';


   -- get the list of Condition object definitions
   FOR objdef IN c_objdef (p_condition_object_id) LOOP

      -- Get the list of Condition Component Object Definitions for that Condition
      FOR comp in c_comp (objdef.object_definition_id) LOOP


      /*************************************************************************
      Dimension Components
      ***************************************************************************/
         IF comp.data_dim_flag IN ('D','V') THEN
            v_table_name := v_any_table;

            FOR dimcomp IN c_dimcomp (comp.cond_comp_obj_def_id) LOOP
               v_cond_column := dimcomp.dimension_name;

               IF comp.data_dim_flag = 'D' AND NVL(dimcomp.dim_comp_type,'X') = 'H' THEN
                  -------------------------------------------------------------------
   	          -- Hierarchy component
	          SELECT meaning
	          INTO v_cond_type
	          FROM fem_lookups
	          WHERE lookup_type = 'FEM_CONDITION_DIM_COMP_TYPES'
	          AND lookup_code = 'HIERARCHY';

                  FOR hier IN c_hier (comp.cond_comp_obj_def_id) LOOP
                     v_hier_attr := hier.object_name;
                     v_cond_value := null;

                     INSERT INTO FEM_ALLOC_BR_COND_SUM_GT (
                        CONDITION_OBJ_DEF_ID,
                        TABLE_DISPLAY_NAME,
     	                COLUMN_DISPLAY_NAME,
	                CONDITION_TYPE,
	                HIER_ATTR_DISPLAY_NAME,
                        CONDITION_VALUE )
                     VALUES (objdef.object_definition_id,
                             v_table_name,
                             v_cond_column,
                             v_cond_type,
                             v_hier_attr,
                             v_cond_value);
                  END LOOP;
                  -------------------------------------------------------------------
               ELSIF comp.data_dim_flag = 'D' AND NVL(dimcomp.dim_comp_type,'X') = 'A' THEN
                  -------------------------------------------------------------------
   	          -- Attribute component
                  SELECT meaning
                  INTO v_cond_type
                  FROM fem_lookups
                  WHERE lookup_type = 'FEM_CONDITION_DIM_COMP_TYPES'
                  AND lookup_code = 'ATTRIBUTE';

                  FOR attr IN c_attr (comp.cond_comp_obj_def_id,dimcomp.dim_id) LOOP
                     v_hier_attr := attr.attribute_name;

                     IF attr.attribute_data_type_code = 'DIMENSION' THEN

                        SELECT value_set_required_flag
                        INTO v_vsr_flag
                        FROM fem_xdim_dimensions
                        WHERE dimension_id = attr.attribute_dimension_id;

                        IF v_vsr_flag = 'Y' THEN
                           v_value_set_id := fem_dimension_util_pkg.dimension_value_set_id (attr.attribute_dimension_id);
                        ELSE v_value_set_id := null;
                        END IF;

                        v_cond_value :=
                          fem_dimension_util_pkg.get_dim_member_name
                           (attr.attribute_dimension_id,
                            attr.dim_attr_value,
                            v_value_set_id);

                     ELSE -- NUMBER, VARCHAR or DATE attribute
                        v_cond_value := attr.dim_attr_value;
                     END IF;

                     INSERT INTO FEM_ALLOC_BR_COND_SUM_GT (
                        CONDITION_OBJ_DEF_ID,
                        TABLE_DISPLAY_NAME,
        	        COLUMN_DISPLAY_NAME,
	                CONDITION_TYPE,
	                HIER_ATTR_DISPLAY_NAME,
                        CONDITION_VALUE,
                        COND_VALUE_ATTR_DATA_TYPE )
                     VALUES (objdef.object_definition_id,
                             v_table_name,
                             v_cond_column,
                             v_cond_type,
                             v_hier_attr,
                             v_cond_value,
                             attr.attribute_data_type_code);

                  END LOOP;  -- c_attr

               ELSIF comp.data_dim_flag = 'V'  THEN
                  -------------------------------------------------------------------

   	          -- Dimension value component
                  v_hier_attr := null;

                  SELECT meaning
                  INTO v_cond_type
                  FROM fem_lookups
                  WHERE lookup_type = 'FEM_CONDITION_DIM_COMP_TYPES'
                  AND lookup_code = 'VALUE';

                  SELECT value_set_required_flag
                  INTO v_vsr_flag
                  FROM fem_xdim_dimensions
                  WHERE dimension_id = dimcomp.dim_id;

                  IF v_vsr_flag = 'Y' THEN
                     v_value_set_id := fem_dimension_util_pkg.dimension_value_set_id (dimcomp.dim_id);
                  ELSE v_value_set_id := null;
                  END IF;

                  v_cond_value :=
                    fem_dimension_util_pkg.get_dim_member_name
                     (dimcomp.dim_id,
                      dimcomp.value,
                      v_value_set_id);


                  INSERT INTO FEM_ALLOC_BR_COND_SUM_GT (
                     CONDITION_OBJ_DEF_ID,
                     TABLE_DISPLAY_NAME,
                     COLUMN_DISPLAY_NAME,
                     CONDITION_TYPE,
                     HIER_ATTR_DISPLAY_NAME,
                     CONDITION_VALUE )
                  VALUES (objdef.object_definition_id,
                          v_table_name,
                          v_cond_column,
                          v_cond_type,
                          v_hier_attr,
                          v_cond_value);

               END IF; -- data_dim_flag
            END LOOP;  -- c_dimcomp
         ELSIF comp.data_dim_flag IN ('T') THEN
         -------------------------------------------------------------------
         -- Table component
         v_hier_attr := null;

            FOR step IN c_steps (comp.cond_comp_obj_def_id) LOOP


               SELECT meaning
               INTO v_operator_name
               FROM fem_lookups
               WHERE lookup_type = 'FEM_CONDITION_OPERATOR'
               AND lookup_code = step.operator;

               IF step.step_type ='DATA_SPECIFIC' THEN
                  SELECT meaning
                  INTO v_cond_type
                  FROM fem_lookups
                  WHERE lookup_type = 'FEM_CONDITION_DATA_STEP_TYPE'
                  AND lookup_code = 'DATA_SPECIFIC';


                  IF step.fem_data_type_code = 'DIMENSION' THEN
                     SELECT value_set_required_flag
                     INTO v_vsr_flag
                     FROM fem_xdim_dimensions
                     WHERE dimension_id = step.dimension_id;

                     IF v_vsr_flag = 'Y' THEN
                        v_value_set_id := fem_dimension_util_pkg.dimension_value_set_id (step.dimension_id);
                     ELSE v_value_set_id := null;
                     END IF;

                     v_temp_cond_value :=
                       fem_dimension_util_pkg.get_dim_member_name
                        (step.dimension_id,
                         step.value,
                         v_value_set_id);

                  ELSE v_temp_cond_value := step.value;

                  END IF;

                  v_cond_value := v_operator_name||' '||v_temp_cond_value;

               ELSIF step.step_type = 'DATA_RANGE' THEN

                  SELECT meaning
	          INTO v_cond_type
	          FROM fem_lookups
	          WHERE lookup_type = 'FEM_CONDITION_DATA_STEP_TYPE'
	          AND lookup_code = 'DATA_RANGE';

	       	  SELECT meaning
	       	  INTO v_and_name
	       	  FROM fem_lookups
	       	  WHERE	 lookup_type = 'FEM_CONDITION_OPERATOR_AND'
	          AND lookup_code = 'AND';

	          IF step.fem_data_type_code = 'DIMENSION' THEN
                     SELECT value_set_required_flag
                     INTO v_vsr_flag
                     FROM fem_xdim_dimensions
                     WHERE dimension_id = step.dimension_id;

                     IF v_vsr_flag = 'Y' THEN
                        v_value_set_id := fem_dimension_util_pkg.dimension_value_set_id (step.dimension_id);
                     ELSE v_value_set_id := null;
                     END IF;

                     v_temp_min_cond_value :=
                       fem_dimension_util_pkg.get_dim_member_name
                        (step.dimension_id,
                         step.value,
                         v_value_set_id);

                     v_temp_min_cond_value :=
                       fem_dimension_util_pkg.get_dim_member_name
                        (step.dimension_id,
                         step.max_range_value,
                         v_value_set_id);
                  ELSE v_temp_min_cond_value := step.value;
                   	v_temp_max_cond_value := step.max_range_value;

	          END IF;
                  v_cond_value := v_operator_name||' '||
                                  v_temp_min_cond_value||' '||
                                  v_and_name||v_temp_max_cond_value;


               ELSIF step.step_type = 'DATA_ANOTHER_COL' THEN
                  SELECT meaning
                  INTO v_cond_type
                  FROM fem_lookups
                  WHERE lookup_type = 'FEM_CONDITION_DATA_STEP_TYPE'
                  AND lookup_code = 'ANOTHER_COL';

                  v_cond_value := step.value;

               END IF; -- step_type

               SELECT display_name
               INTO v_table_name
               FROM fem_tables_vl
               WHERE table_name = step.table_name;

               SELECT display_name
               INTO v_cond_column
               FROM fem_tab_columns_vl
               WHERE table_name = step.table_name
               AND column_name = step.column_name;


               INSERT INTO FEM_ALLOC_BR_COND_SUM_GT (
                  CONDITION_OBJ_DEF_ID,
                  TABLE_DISPLAY_NAME,
                  COLUMN_DISPLAY_NAME,
                  CONDITION_TYPE,
                  HIER_ATTR_DISPLAY_NAME,
                  CONDITION_VALUE )
               VALUES (objdef.object_definition_id,
                       v_table_name,
                       v_cond_column,
                       v_cond_type,
                       v_hier_attr,
                       v_cond_value);

            END LOOP; -- c_steps
         END IF;  -- data_dim_flag
      END LOOP;  -- c_comp
   END LOOP; -- c_objdef

x_return_status := c_success;

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;

EXCEPTION
 WHEN OTHERS THEN
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
    x_return_status := c_unexp;


END generate_condition_summary;

/*************************************************************************

                       create_new_ver_from_defaults

PURPOSE:  To create a new mapping rule object definition, and copy
          the content from the default mapping rule associated with
          that Rule Type

NOTES:    Given a Mapping Rule Object ID, this API does the following:
          1) Creates an object definition for that mapping rule
          2) Creates an edit snapshot for that Mapping Rule Object if
             one doesn't already exist (uses the existing snapshot if
             it already exists)
          3) Populates the snapshot content with the content from the
             default for that rule type
          4) Populates the mapping rule content with the content from
             the snapshot

*************************************************************************/


PROCEDURE create_new_ver_from_defaults (
   p_map_rule_obj_id	 IN NUMBER,
   p_api_version         IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list       IN VARCHAR2   DEFAULT c_false,
   p_commit              IN VARCHAR2   DEFAULT c_false,
   p_encoded             IN VARCHAR2   DEFAULT c_true,
   x_map_rule_objdef_id	 OUT NOCOPY NUMBER,
   x_snapshot_objdef_id  OUT NOCOPY NUMBER,
   x_return_status       OUT NOCOPY VARCHAR2,
   x_msg_count           OUT NOCOPY NUMBER,
   x_msg_data            OUT NOCOPY VARCHAR2) IS

  C_MODULE            CONSTANT FND_LOG_MESSAGES.module%TYPE :=
     'fem.plsql.fem_alloc_br_util_pkg.create_new_ver_from_defaults';
  C_API_NAME          CONSTANT VARCHAR2(30)  := 'create_new_ver_from_defaults';

  v_return_status   VARCHAR2(30);
  v_msg_count       NUMBER;
  v_msg_data        VARCHAR2(4000);

  v_fem_obj_def_row FEM_OBJECT_DEFINITION_VL%ROWTYPE;


  v_dflt_obj_def_id FEM_OBJECT_DEFINITION_B.object_definition_id%TYPE;
  v_snap_obj_id FEM_OBJECT_DEFINITION_B.object_definition_id%TYPE;
  v_snap_objdef_id FEM_OBJECT_DEFINITION_B.object_definition_id%TYPE;
  v_map_rule_type_code FEM_ALLOC_BR_OBJECTS.map_rule_type_code%TYPE;


  v_folder_id fem_folders_b.folder_id%TYPE;
  v_object_name fem_object_catalog_tl.object_name%TYPE;
  v_description fem_object_catalog_tl.description%TYPE;
  v_dflt_object_id fem_object_catalog_b.object_id%TYPE;


  e_unexp       EXCEPTION;
  e_no_default   EXCEPTION;
  e_no_objdef       EXCEPTION;
  e_invalid_obj EXCEPTION;
  e_no_seeded_dflt EXCEPTION;
  e_noobj EXCEPTION;




  v_count number;

BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT  create_new_ver_from_dflt_pub;


  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;


  -- Initialize return status to unexpected error
  x_return_status := c_unexp;

  -- Check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (c_api_version,
                p_api_version,
                C_API_NAME,
                G_PKG_NAME)
  THEN
    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'API Version ('||C_API_VERSION||') not compatible with '
                    ||'passed in version ('||p_api_version||')');
    END IF;
    RAISE e_unexp;
  END IF;


  Validate_OA_Params (
    p_api_version => p_api_version,
    p_init_msg_list => p_init_msg_list,
    p_commit => p_commit,
    p_encoded => p_encoded,
    x_return_status => x_return_status);

  IF (x_return_status <> c_success) THEN
    RAISE e_unexp;
  END IF;


/* Verify the mapping rule is valid*/
BEGIN

   SELECT O.map_rule_type_code, C.folder_id
   INTO v_map_rule_type_code, v_folder_id
   FROM fem_object_catalog_b C, fem_alloc_br_objects O
   WHERE C.object_id = p_map_rule_obj_id
   AND C.object_type_code = 'MAPPING_RULE'
   AND C.object_id = O.map_rule_object_id;

EXCEPTION
   WHEN no_data_found THEN
      RAISE e_invalid_obj;

END;

/* identify the default definition for the rule type and gvsc*/
get_default_definition (
   p_map_rule_type_code  => v_map_rule_type_code,
   p_target_folder_id => v_folder_id,
   x_dflt_objdef_id  => v_dflt_obj_def_id,
   x_return_status  => v_return_status,
   x_msg_count  => v_msg_count,
   x_msg_data => v_msg_data);



/*  Create the mapping rule object definition using default obj def as a template */
SELECT *
INTO v_fem_obj_def_row
FROM fem_object_definition_vl
WHERE object_definition_id = v_dflt_obj_def_id;

 FEM_OBJECT_CATALOG_UTIL_PKG.create_object_definition(x_object_definition_id => x_map_rule_objdef_id,
						x_msg_count => x_msg_count,
						x_msg_data => x_msg_data,
						x_return_status => x_return_status,
						p_api_version => 1.0,
						p_commit => FND_API.G_FALSE,
						p_object_id => p_map_rule_obj_id,
						p_effective_start_date => v_fem_obj_def_row.effective_start_date,
						p_effective_end_date => v_fem_obj_def_row.effective_end_date,
						p_obj_def_name => v_fem_obj_def_row.display_name,
						p_object_origin_code => 'USER'
						);

if(x_return_status <> c_success) THEN
 RAISE e_no_objdef;
END IF;

UPDATE fem_object_definition_vl
SET description = v_fem_obj_def_row.description
WHERE object_definition_id = x_map_rule_objdef_id;

/* identify the edit snapshot for the mapping rule */
fem_helper_rule_util_pkg.get_helper_rule (
   p_rule_obj_def_id  => x_map_rule_objdef_id,
   p_helper_object_type_code => C_SNAP_OBJTYPE,
   p_api_version    => C_API_VERSION,
   p_init_msg_list => C_FALSE,
   p_commit    => C_FALSE,
   p_encoded    => C_TRUE,
   x_return_status => v_return_status,
   x_msg_count   => v_msg_count,
   x_msg_data   => v_msg_data,
   x_helper_obj_def_id => v_snap_objdef_id   );

IF v_return_status NOT IN (c_success) THEN

  /*  Since there is no existing Edit Snapshot, create one for the Mapping Rule */
   create_snapshot(
      p_map_rule_obj_def_id => x_map_rule_objdef_id,
      x_snapshot_object_id  => v_snap_obj_id,
      x_snapshot_objdef_id  => v_snap_objdef_id,
      x_return_status       => v_return_status,
      x_msg_count           => v_msg_count,
      x_msg_data            => v_msg_data);

END IF;

/* copy the content from the default rule to the snapshot */
fem_br_mapping_rule_pvt.CopyObjectDefinition (
   p_copy_type_code => fem_business_rule_pvt.g_duplicate
  ,p_source_obj_def_id => v_dflt_obj_def_id
  ,p_target_obj_def_id => v_snap_objdef_id
  ,p_created_by => c_user_id
  ,p_creation_date => sysdate);

/*Bug#6146396 Set any dimension cols in the Mapping Output list
  that do not have a default assigned to "SAME_AS_SOURCE"
  */
  set_dim_usage_dflt (v_snap_objdef_id);


/* copy the content from the snapshot to the rule*/
fem_br_mapping_rule_pvt.CopyObjectDefinition (
   p_copy_type_code => fem_business_rule_pvt.g_duplicate
  ,p_source_obj_def_id => v_snap_objdef_id
  ,p_target_obj_def_id => x_map_rule_objdef_id
  ,p_created_by => c_user_id
  ,p_creation_date => sysdate);

x_snapshot_objdef_id := v_snap_objdef_id;
x_return_status := c_success;

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;

IF FND_API.To_Boolean( p_commit ) THEN
   COMMIT WORK;
END IF;


EXCEPTION
 WHEN e_invalid_obj THEN
    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'Mapping Rule Object does not exist '||p_map_rule_obj_id);
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded => p_encoded,
                              p_count => x_msg_count,
                              p_data => x_msg_data);
    ROLLBACK TO create_new_ver_from_dflt_pub;
    x_return_status := c_error;

 WHEN e_no_default THEN
    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'Mapping Rule defaults seed data is missing');
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded => p_encoded,
                              p_count => x_msg_count,
                              p_data => x_msg_data);
    ROLLBACK TO create_new_ver_from_dflt_pub;
    x_return_status := c_error;

 WHEN e_no_objdef THEN
    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'Unable to create new object definition');
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded => p_encoded,
                              p_count => x_msg_count,
                              p_data => x_msg_data);
    ROLLBACK TO create_new_ver_from_dflt_pub;
    x_return_status := c_error;


 WHEN OTHERS THEN
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
    ROLLBACK TO create_new_ver_from_dflt_pub;
    x_return_status := c_unexp;


END create_new_ver_from_defaults;

/*************************************************************************

                       defaults_exist

PURPOSE:  To identify whether or not a default rule exists for a given rule type

**************************************************************************/

FUNCTION defaults_exist(p_map_rule_type_code IN VARCHAR2) RETURN VARCHAR2 IS

  C_MODULE            CONSTANT FND_LOG_MESSAGES.module%TYPE :=
     'fem.plsql.fem_alloc_br_util_pkg.defaults_exist';
  C_API_NAME          CONSTANT VARCHAR2(30)  := 'Defaults_exist';


  v_defaults_exist_flag VARCHAR2(1) := 'N';

  v_return_status   VARCHAR2(30);
  v_msg_count       NUMBER;
  v_msg_data        VARCHAR2(4000);

  v_count           NUMBER;

  v_global_vs_combo_id fem_global_vs_combos_b.global_vs_combo_id%TYPE;
  v_dflt_objdef_id fem_object_definition_b.object_definition_id%TYPE;


BEGIN


  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;


/* identify the default definition for the rule type and gvsc*/


   v_global_vs_combo_id := fem_dimension_util_pkg.global_vs_combo_id(
         p_ledger_id => null
        ,x_return_status => v_return_status
        ,x_msg_count => v_msg_count
        ,x_msg_data => v_msg_data);

   BEGIN
      SELECT min (D.object_definition_id)
      INTO v_dflt_objdef_id
      FROM fem_object_definition_b D, fem_alloc_br_objects O,
           fem_object_catalog_b C
      WHERE C.object_id = D.object_id
      AND C.object_type_code = C_DFLT_OBJTYPE
      AND C.object_id = O.map_rule_object_id
      AND O.map_rule_type_code = p_map_rule_type_code
      AND C.local_vs_combo_id = v_global_vs_combo_id;

   EXCEPTION
      WHEN no_data_found THEN v_dflt_objdef_id := null;
   END;

   IF v_dflt_objdef_id IS NOT NULL THEN
      v_defaults_exist_flag := 'Y';
   END IF;

   RETURN v_defaults_exist_flag;

EXCEPTION
   WHEN OTHERS THEN RETURN 'N';

END defaults_exist;


/*************************************************************************

                         generate_fctr_summary
   This procedure generates the Factor table summary info and populates the
   FEM_ALLOC_BR_FCTR_SUM_GT table with it

*************************************************************************/
PROCEDURE generate_fctr_summary (
    p_fctr_object_id IN NUMBER,
    p_api_version         IN NUMBER     DEFAULT c_api_version,
    p_init_msg_list       IN VARCHAR2   DEFAULT c_false,
    p_commit              IN VARCHAR2   DEFAULT c_false,
    p_encoded             IN VARCHAR2   DEFAULT c_true,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2) IS

   C_MODULE            CONSTANT FND_LOG_MESSAGES.module%TYPE :=
      'fem.plsql.fem_alloc_br_util_pkg.generate_fctr_summary';
   C_API_NAME          CONSTANT VARCHAR2(30)  := 'Generate_fctr_summary';

   v_return_status             VARCHAR2(30);
   v_msg_count                 NUMBER;
   v_msg_data                  VARCHAR2(4000);

   e_unexp                     EXCEPTION;
   e_invalid_obj               EXCEPTION;

   v_fctr_obj_def_id           NUMBER;

   v_sql varchar2(4000);

   -- Dimension Component Properties
   v_matching_dimension_name   FEM_ALLOC_BR_FCTR_SUM_GT.matching_dimension_name%TYPE;
   v_hier_relation_code        FEM_LOOKUPS.lookup_code%TYPE;
   v_hier_name                 FEM_ALLOC_BR_FCTR_SUM_GT.hierarchy_name%TYPE;
   v_group_name                FEM_ALLOC_BR_FCTR_SUM_GT.dimension_group_name%TYPE;
   v_hier_relation_desc        FEM_ALLOC_BR_FCTR_SUM_GT.hier_relation_desc%TYPE;



   cursor c_objdef (p_cond_object_id IN NUMBER) IS
      SELECT object_definition_id
      FROM fem_object_definition_b
      WHERE object_id = p_fctr_object_id
      ORDER BY effective_end_date;

   -- Identify the factor table dimensions for that Factor Table Object:
   cursor c_dim (p_object_definition_id IN NUMBER) IS
      SELECT D.dimension_name, F.hier_object_id, F.hier_group_id, F.hier_relation_code
      FROM fem_dimensions_vl D, fem_factor_table_dims F
      WHERE F.dimension_id = D.dimension_id
      AND F.object_definition_id = p_object_definition_id
      AND F.dim_usage_code = 'MATCH';


BEGIN

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;


  -- Initialize return status to unexpected error
  x_return_status := c_unexp;

  -- Check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (c_api_version,
                p_api_version,
                C_API_NAME,
                G_PKG_NAME)
  THEN
    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'API Version ('||C_API_VERSION||') not compatible with '
                    ||'passed in version ('||p_api_version||')');
    END IF;
    RAISE e_unexp;
  END IF;


  Validate_OA_Params (
    p_api_version => p_api_version,
    p_init_msg_list => p_init_msg_list,
    p_commit => p_commit,
    p_encoded => p_encoded,
    x_return_status => x_return_status);

  IF (x_return_status <> c_success) THEN
    RAISE e_unexp;
  END IF;


   -- initialize
   DELETE FROM fem_alloc_br_fctr_sum_gt
   WHERE factor_obj_def_id IN (SELECT object_definition_id
   FROM fem_object_definition_b
   WHERE object_id = p_fctr_object_id);



   -- get the list of Factor Table object definitions
   FOR objdef IN c_objdef (p_fctr_object_id) LOOP

      -- Get the list of Factor Table Dimensions
      FOR dim in c_dim (objdef.object_definition_id) LOOP

      /*************************************************************************
      Factor Table Dimensions
      ***************************************************************************/
         IF dim.hier_object_id IS NOT NULL THEN

            SELECT object_name
            INTO v_hier_name
            FROM fem_object_catalog_vl
            WHERE object_id = dim.hier_object_id;
         END IF;

         IF dim.hier_group_id IS NOT NULL THEN

            SELECT dimension_group_name
            INTO v_group_name
            FROM fem_dimension_grps_vl
            WHERE dimension_group_id = dim.hier_group_id;
         END IF;

         IF dim.hier_relation_code IS NOT NULL THEN
            SELECT meaning
            INTO v_hier_relation_desc
            FROM fem_lookups
            WHERE lookup_type = 'FEM_COND_HIER_RELATIONS'
            AND lookup_code = dim.hier_relation_code;

         END IF;

         INSERT INTO FEM_ALLOC_BR_FCTR_SUM_GT (
           FACTOR_OBJ_DEF_ID,
           MATCHING_DIMENSION_NAME,
           HIERARCHY_NAME,
           DIMENSION_GROUP_NAME,
           HIER_RELATION_DESC )
         VALUES (objdef.object_definition_id,
                 dim.dimension_name,
                 v_hier_name,
                 v_group_name,
                 v_hier_relation_desc );
      END LOOP; -- c_dim
   END LOOP; -- c_objdef

x_return_status := c_success;

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;

EXCEPTION
 WHEN OTHERS THEN
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
    x_return_status := c_unexp;


END generate_fctr_summary;

procedure set_VT_attributes(p_object_definition_id NUMBER)
IS
 v_map_rule_type_code VARCHAR2(30) := NULL;
 v_src_flag NUMBER := 0;
 v_drv_flag NUMBER := 0;
 v_trace_contrib_flag NUMBER := 0;
 v_stat_count NUMBER := 0;
 v_row_count NUMBER := 0;
 e_unexp       EXCEPTION;
 C_MODULE    CONSTANT FND_LOG_MESSAGES.module%TYPE :=
      'fem.plsql.fem_alloc_br_util_pkg.set_VT_attributes';

BEGIN

--Get the mapping Rule Type Code.
  BEGIN

  select map_rule_type_code into v_map_rule_type_code
  from fem_alloc_br_objects abo,fem_object_definition_b defs
  where defs.object_definition_id = p_object_definition_id
  and abo.map_rule_object_id = defs.object_id  ;

  EXCEPTION
   WHEN no_data_found THEN
        raise e_unexp;
  END;

 IF v_map_rule_type_code <> 'ADJUSTMENT' THEN
    v_src_flag := 1;
 END IF;

 IF v_map_rule_type_code = 'PERCENT_DISTRIBUTION' THEN
    v_drv_flag := 1;
 ELSIF  v_map_rule_type_code = 'DIMENSION' THEN
    v_drv_flag := 1;
 ELSIF  v_map_rule_type_code = 'RETRIEVE_STATISTICS' THEN
     --Get the no. of statistics within the rule.
     select count(*) into v_stat_count
     from fem_alloc_br_formula
     where object_definition_id = p_object_definition_id
     and function_cd = 'TABLE_ACCESS';

     IF v_stat_count = 1 THEN
        v_drv_flag := 1;
     END IF;

 END IF;

 --Get the Track Contributions flag.
 BEGIN
 select decode(NVL(cost_contribution_flag,'N'),'Y',1,0)
 into v_trace_contrib_flag
 from fem_alloc_business_rule
 where object_definition_id = p_object_definition_id;

 EXCEPTION
   WHEN no_data_found THEN
      raise e_unexp;
 END;


    SELECT count(*) INTO v_row_count
    FROM fem_vt_obj_def_attribs
    WHERE object_definition_id = p_object_definition_id;

    IF v_row_count = 0 THEN
          INSERT INTO fem_vt_obj_def_attribs(object_definition_id,source_enabled_flg,
          driver_enabled_flg,trace_contribution_enabled_flg,
          created_by,creation_date,last_updated_by,
          last_update_date,last_update_login,object_version_number)
          VALUES (p_object_definition_id,v_src_flag,
          v_drv_flag,v_trace_contrib_flag,
          c_user_id,sysdate,c_user_id,sysdate,c_login_id,0);
     ELSE

            UPDATE fem_vt_obj_def_attribs
            SET  source_enabled_flg = v_src_flag,driver_enabled_flg = v_drv_flag,
                 trace_contribution_enabled_flg =  v_trace_contrib_flag ,
                 Last_update_date = sysdate,last_update_login =c_login_id,
                 last_updated_by=c_user_id,object_version_number = (object_version_number+1)
            WHERE object_definition_id = p_object_definition_id;
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
        raise e_unexp;
    END IF;


END set_VT_attributes;

END FEM_alloc_br_Util_Pkg;

/
