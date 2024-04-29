--------------------------------------------------------
--  DDL for Package Body FEM_ADMIN_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_ADMIN_UTIL_PKG" AS
-- $Header: fem_adm_utl.plb 120.18.12010000.2 2010/04/26 23:09:06 ghall ship $

-------------------------------
-- Declare Package Variables --
-------------------------------

c_user_id      CONSTANT  NUMBER := FND_GLOBAL.USER_ID;
c_success      CONSTANT  VARCHAR2(1)  := FND_API.G_RET_STS_SUCCESS;
c_error        CONSTANT  VARCHAR2(1)  := FND_API.G_RET_STS_ERROR;
c_unexp        CONSTANT  VARCHAR2(1)  := FND_API.G_RET_STS_UNEXP_ERROR;
G_PKG_NAME     CONSTANT  VARCHAR2(30) := 'FEM_ADMIN_UTIL_PKG';

bad_gvsc_id    EXCEPTION;
e_unexp        EXCEPTION;
e_error        EXCEPTION;

--------------------------------------------------------------
-- Private Procedures
--------------------------------------------------------------

-- "Table handler" procedures for the Table Classification
-- Logging global temporary tables.

PROCEDURE Trunc_Table_Class_Log_Tables (
p_tab_name           IN         VARCHAR2) IS
  C_MODULE            CONSTANT FND_LOG_MESSAGES.module%TYPE :=
     'fem.plsql.fem_admin_util_pkg.trunc_table_class_log_tables';
BEGIN

  BEGIN
    DELETE FROM fem_tab_class_status_gt
    WHERE table_name = p_tab_name;
  EXCEPTION
    WHEN others THEN
      IF FND_LOG.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FEM_ENGINES_PKG.TECH_MESSAGE(
          p_severity => FND_LOG.level_exception,
          p_module   => C_MODULE,
          p_msg_text => 'Delete from FEM_TAB_CLASS_STATUS_GT failed with: '||SQLERRM);
      END IF;
  END;

  BEGIN
    DELETE FROM fem_tab_class_errors_gt
    WHERE table_name = p_tab_name;
  EXCEPTION
    WHEN others THEN
      IF FND_LOG.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FEM_ENGINES_PKG.TECH_MESSAGE(
          p_severity => FND_LOG.level_exception,
          p_module   => C_MODULE,
          p_msg_text => 'Delete from FEM_TAB_CLASS_ERRORS_GT failed with: '||SQLERRM);
      END IF;
  END;

END Trunc_Table_Class_Log_Tables;


PROCEDURE Log_Table_Class_Error (
p_tab_name           IN  VARCHAR2,
p_tab_class_cd       IN  VARCHAR2,
p_msg_name           IN  VARCHAR2 DEFAULT NULL,
p_msg_count          IN  NUMBER DEFAULT NULL,
p_token1             IN  VARCHAR2 DEFAULT NULL,
p_value1             IN  VARCHAR2 DEFAULT NULL,
p_token2             IN  VARCHAR2 DEFAULT NULL,
p_value2             IN  VARCHAR2 DEFAULT NULL,
p_token3             IN  VARCHAR2 DEFAULT NULL,
p_value3             IN  VARCHAR2 DEFAULT NULL,
p_token4             IN  VARCHAR2 DEFAULT NULL,
p_value4             IN  VARCHAR2 DEFAULT NULL
) IS
  C_MODULE           CONSTANT FND_LOG_MESSAGES.module%TYPE :=
     'fem.plsql.fem_admin_util_pkg.log_table_class_error';

  TYPE msg_array     IS VARRAY(8) OF VARCHAR2(2000);
  tokens_values      msg_array;

  v_token            VARCHAR2(30);
  v_value            VARCHAR2(2000);
  v_msg_data         VARCHAR2(2000);
  v_dummy            NUMBER;
BEGIN

  IF p_msg_count IS NOT NULL THEN
    FOR i IN 1..p_msg_count LOOP
      FND_MSG_PUB.Get(
        p_msg_index => i,
        p_encoded => c_false,
        p_data => v_msg_data,
        p_msg_index_out => v_dummy);

      INSERT INTO fem_tab_class_errors_gt
       (TABLE_NAME, TABLE_CLASSIFICATION_CODE, MESSAGE_TEXT)
      VALUES
       (p_tab_name, p_tab_class_cd, nvl(v_msg_data,'?'));
    END LOOP;

    FND_MSG_PUB.initialize;
  ELSE
    -- Get message from dictionary
    fnd_message.set_name('FEM',p_msg_name);

    -- Load token/value array
    tokens_values := msg_array
                     (p_token1,p_value1,
                      p_token2,p_value2,
                      p_token3,p_value3,
                      p_token4,p_value4);

    -- Substitute values for tokens
    FOR i IN 1..8 LOOP
      IF (MOD(i,2) = 1) THEN
        v_token := tokens_values(i);
        IF (v_token IS NOT NULL) THEN
          v_value := tokens_values(i+1);
          fnd_message.set_token(v_token,v_value);
        ELSE
          EXIT;
        END IF;
      END IF;
    END LOOP;

    v_msg_data := FND_MESSAGE.Get;

    INSERT INTO fem_tab_class_errors_gt
     (TABLE_NAME, TABLE_CLASSIFICATION_CODE, MESSAGE_TEXT)
    VALUES
     (p_tab_name, p_tab_class_cd, nvl(v_msg_data,'?'));

  END IF; -- p_msg_txt IS NOT NULL

EXCEPTION
  WHEN others THEN
    IF FND_LOG.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_exception,
        p_module   => C_MODULE,
        p_msg_text => 'Insert into FEM_TAB_CLASS_ERRORS_GT failed with: '||SQLERRM);
    END IF;
END Log_Table_Class_Error;


PROCEDURE Log_Table_Class_Status (
p_tab_name           IN         VARCHAR2,
p_tab_class_cd       IN         VARCHAR2,
p_passed_validation         IN         VARCHAR2) IS
  C_MODULE            CONSTANT FND_LOG_MESSAGES.module%TYPE :=
     'fem.plsql.fem_admin_util_pkg.log_table_class_status';
BEGIN

  INSERT INTO fem_tab_class_status_gt
    (TABLE_NAME, TABLE_CLASSIFICATION_CODE, VALID_FLAG)
  VALUES
    (p_tab_name, p_tab_class_cd, decode(p_passed_validation,c_true,'Y','N'));

EXCEPTION
  WHEN others THEN
    IF FND_LOG.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_exception,
        p_module   => C_MODULE,
        p_msg_text => 'Insert into FEM_TAB_CLASS_STATUS_GT failed with: '||SQLERRM);
    END IF;
END Log_Table_Class_Status;

------------------------------------
-- Bug 4534907. Short term solution to create the extra metadata necessary
-- for a table to be supported by the Detail Client Data Loader program.
-- This metadata consists of:
-- * Rule and rule definintion for the table (FEM_OBJECT_CATALOG_VL,
--                                            FEM_OBJECT_DEFINITION_VL)
-- * Multiprocessing options for the new rule (FEM_MP_PROCESS_OPTIONS)
-- * Link between the new rule and client data table (FEM_DATA_LOADER_OBJECTS)

-- This procedure enables user-defined tables that qualify as a
-- clieant data loader table to be supported by the loader.
------------------------------------

FUNCTION Create_Data_Loader_Rule (
p_tab_name           IN         VARCHAR2,
p_tab_class_cd       IN         VARCHAR2
) RETURN VARCHAR2
AS
  C_MODULE            CONSTANT FND_LOG_MESSAGES.module%TYPE :=
     'fem.plsql.fem_admin_util_pkg.create_data_loader_rule';

  v_count          INTEGER;
  v_obj_name       FEM_OBJECT_CATALOG_TL.object_name%TYPE;
  v_obj_id         FEM_OBJECT_CATALOG_B.object_id%TYPE;
  v_obj_def_id     FEM_OBJECT_DEFINITION_B.object_id%TYPE;
  v_tab_disp_name  FEM_TABLES_TL.display_name%TYPE;
  v_msg_count      NUMBER;
  v_msg_data       VARCHAR2(4000);
  v_return_status  VARCHAR2(1);
BEGIN

  SAVEPOINT  create_data_loader_rule_pub;

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;

  SELECT count(*)
  INTO v_count
  FROM fem_data_loader_objects
  WHERE table_name = p_tab_name;

  IF v_count = 0 THEN
    BEGIN
      SELECT display_name
      INTO v_tab_disp_name
      FROM fem_tables_vl
      WHERE table_name = p_tab_name;
    EXCEPTION WHEN others THEN null;
    END;
    FND_MESSAGE.Set_Name('FEM','FEM_SD_LDR_OBJECT_NAME_TXT');
    FND_MESSAGE.Set_Token('TAB_DISP_NAME',nvl(v_tab_disp_name,p_tab_name));
    FND_MESSAGE.Set_Token('TAB_NAME',p_tab_name);
    v_obj_name := substr(FND_MESSAGE.Get,1,150);

    fem_object_catalog_util_pkg.create_object(p_api_version => 1.0,
      p_commit               =>  c_false,
      p_object_type_code     =>  'SOURCE_DATA_LOADER',
      p_folder_id            =>  1000, -- hardcoded to Data Intg folder
      p_local_vs_combo_id    =>  NULL,
      p_object_access_code   =>  'R',
      p_object_origin_code   =>  'USER',
      p_object_name          =>  v_obj_name,
      p_description          =>  v_obj_name,
      p_effective_start_date =>  sysdate,
      p_effective_end_date   =>  to_date('9999/01/01','YYYY/MM/DD'),
      p_obj_def_name         =>  v_obj_name,
      x_object_id            =>  v_obj_id,
      x_object_definition_id =>  v_obj_def_id,
      x_msg_count            =>  v_msg_count,
      x_msg_data             =>  v_msg_data,
      x_return_status        =>  v_return_status);

    IF v_return_status <> c_success THEN
      IF FND_LOG.level_error >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FEM_ENGINES_PKG.TECH_MESSAGE(
          p_severity => FND_LOG.level_error,
          p_module   => C_MODULE,
          p_msg_text => 'Call to fem_object_catalog_util_pkg.create_object '
                      ||'did not return successfully: status = '
                      ||v_return_status);
      END IF;

      IF v_return_status = c_unexp OR nvl(v_msg_count,0) = 0 THEN
        ROLLBACK TO create_data_loader_rule_pub;
        RAISE e_unexp;
      END IF;

      Log_Table_Class_Error(
        p_tab_name      => p_tab_name,
        p_tab_class_cd  => p_tab_class_cd,
        p_msg_count     => v_msg_count);

      RETURN c_false;
    ELSE
      IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FEM_ENGINES_PKG.TECH_MESSAGE(
          p_severity => FND_LOG.level_statement,
          p_module   => C_MODULE,
          p_msg_text => 'New loader object id = '||v_obj_id
                     ||' , object def id = '||v_obj_def_id);
      END IF;

      INSERT INTO fem_mp_process_options (
        OBJECT_TYPE_CODE,
        STEP_NAME,
        OBJECT_ID,
        DATA_SLICE_TYPE_CODE,
        PROCESS_DATA_SLICES_CD,
        PROCESS_PARTITION_CD,
        NUM_OF_PROCESSES,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,
        OBJECT_VERSION_NUMBER )
      VALUES (
        'SOURCE_DATA_LOADER',
        'ALL',
        v_obj_id,
        2,
        1000,
        0,
        1,
        c_user_id,
        sysdate,
        c_user_id,
        sysdate,
        FND_GLOBAL.Login_Id,
        1 );

      INSERT INTO fem_data_loader_objects (
        OBJECT_ID,
        TABLE_NAME,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN )
      VALUES (
        v_obj_id,
        p_tab_name,
        c_user_id,
        sysdate,
        c_user_id,
        sysdate,
        FND_GLOBAL.Login_Id );

    END IF;
  END IF; -- v_count = 0

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;

  RETURN c_true;

EXCEPTION
  WHEN others THEN
    IF FND_LOG.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_exception,
        p_module   => C_MODULE,
        p_msg_text => 'Create_Data_Loader_Rule failed unexpectedly: '||SQLERRM);
    END IF;
    Log_Table_Class_Error(
      p_tab_name      => p_tab_name,
      p_tab_class_cd  => p_tab_class_cd,
      p_msg_name => 'FEM_RSM_UNEXPECTED_ERROR',
      p_token1 => 'ROUTINE_NAME',
      p_value1 => C_MODULE);

    ROLLBACK TO create_data_loader_rule_pub;
    RETURN c_false;
END Create_Data_Loader_Rule;


-- Validate_Prop_Col_Req:
-- Procedure to validate the column requirements a
-- table property may have.

PROCEDURE Validate_Prop_Col_Req (
p_tab_name           IN         VARCHAR2,
p_tab_class_cd       IN         VARCHAR2,
p_tab_prop_cd        IN         VARCHAR2,
p_prop_type          IN         VARCHAR2,
p_col_req_type       IN         VARCHAR2,
x_passed_validation  OUT NOCOPY VARCHAR2
) IS
  C_MODULE           CONSTANT FND_LOG_MESSAGES.module%TYPE :=
     'fem.plsql.fem_admin_util_pkg.validate_prop_col_req';

  TYPE CurTyp IS REF CURSOR;
  cols_cv CurTyp;

  -- Table Property required columns
  CURSOR c_req_cols IS
    SELECT column_name
    FROM fem_table_prop_col_req
    WHERE table_property_code = p_tab_prop_cd;

  v_sql              VARCHAR2(4000);
  v_col_list         VARCHAR2(2000);
  v_col_name         ALL_TAB_COLUMNS.column_name%TYPE;
  v_obj_name         FND_LOOKUP_VALUES.meaning%TYPE;
  v_col_prop_cd      FEM_TAB_COLUMN_PROP.column_property_code%TYPE;
  v_msg_name         FND_NEW_MESSAGES.message_name%TYPE;
  v_vsr_flag         FEM_XDIM_DIMENSIONS.value_set_required_flag%TYPE;
  v_count            NUMBER;
  v_vsr_count        NUMBER;
  v_passed_valid     VARCHAR2(1);
BEGIN
  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;
  IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'p_tab_name = '||p_tab_name);
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'p_tab_class_cd = '||p_tab_class_cd);
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'p_tab_prop_cd = '||p_tab_prop_cd);
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'p_prop_type = '||p_prop_type);
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'p_col_req_type = '||p_col_req_type);
  END IF;

  -- Init var
  v_passed_valid := c_true;
  -- Hard-coding this for now - may change if validation
  -- gets extended to other "column properties"
  v_col_prop_cd := 'PROCESSING_KEY';

  -- Object that is being validated against
  SELECT meaning
  INTO v_obj_name
  FROM fnd_lookup_values_vl
  WHERE lookup_type = 'FEM_TAB_CLASS_OBJECTS'
  AND lookup_code = p_prop_type;

  -- First, test for the case where a fixed column set is required.
  IF substr(p_col_req_type,1,5) = 'FIXED' THEN
    v_sql := 'SELECT column_name'
          ||' FROM fem_table_prop_col_req'
          ||' WHERE table_property_code = :1 ';
    IF p_prop_type = 'TABLE_COLUMN' THEN
      v_sql := v_sql||'AND column_name NOT IN '
                    ||'(SELECT column_name'
                    ||' FROM fem_tab_columns_b'
                    ||' WHERE table_name = :2'
                    ||' AND enabled_flag = ''Y'')';
    ELSE
      v_sql := v_sql||'AND column_name NOT IN '
                    ||'(SELECT column_name'
                    ||' FROM fem_tab_column_prop'
                    ||' WHERE table_name = :2'
                    ||' AND column_property_code = '''||v_col_prop_cd||''')';
    END IF; -- p_prop_type

    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'v_sql(10) = '||v_sql);
    END IF;

    v_count := 0;
    OPEN cols_cv FOR v_sql USING p_tab_prop_cd,p_tab_name;
    LOOP
      FETCH cols_cv INTO v_col_name;
      EXIT WHEN cols_cv%NOTFOUND;
      IF v_count = 0 THEN
        v_col_list := v_col_name;
      ELSE
        v_col_list := v_col_list||', '||v_col_name;
      END IF;
      v_count := v_count+1;
    END LOOP;
    CLOSE cols_cv;

    IF v_count > 0 THEN
      Log_Table_Class_Error(
        p_tab_name      => p_tab_name,
        p_tab_class_cd  => p_tab_class_cd,
        p_msg_name      => 'FEM_TABCLASS_MISS_REQ_COL',
        p_token1        => 'OBJECT',
        p_value1        => v_obj_name,
        p_token2        => 'COL_LIST',
        p_value2        => v_col_list);
      v_passed_valid := c_false;
    END IF;

  ELSIF p_col_req_type = 'ONE_ANY' THEN
    v_sql := 'SELECT count(*)';
    IF p_prop_type = 'TABLE_COLUMN' THEN
      v_sql := v_sql||' FROM fem_tab_columns_b'
                    ||' WHERE table_name = :1'
                    ||' AND enabled_flag = ''Y''';
    ELSE
      v_sql := v_sql||' FROM fem_tab_column_prop'
                    ||' WHERE table_name = :1'
                    ||' AND column_property_code = '''||v_col_prop_cd||'''';
    END IF; -- p_prop_type

    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'v_sql(20) = '||v_sql);
    END IF;

    EXECUTE IMMEDIATE v_sql INTO v_count USING p_tab_name;
    IF v_count = 0 THEN
      Log_Table_Class_Error(
        p_tab_name      => p_tab_name,
        p_tab_class_cd  => p_tab_class_cd,
        p_msg_name      => 'FEM_TABCLASS_NO_COLS',
        p_token1        => 'OBJECT',
        p_value1        => v_obj_name);
      v_passed_valid := c_false;
    END IF;
  END IF; -- substr(p_col_req_type,1,5) = 'FIXED'

  -- Continue validation only if previous validation succeeded.
  -- If yes, then for Column Req Type other than FIXED_ANY and ONE_ANY,
  -- validate the columns defined outside the set of
  -- columns defined in FEM_TABLE_PROP_COL_REQ.
  IF v_passed_valid = c_true AND
     p_col_req_type NOT IN ('FIXED_ANY','ONE_ANY') THEN

    v_sql := 'SELECT t.column_name, nvl(x.value_set_required_flag,''N'')'
          ||' FROM fem_tab_columns_b t, fem_xdim_dimensions x'
          ||' WHERE t.dimension_id = x.dimension_id(+)'
          ||' AND t.table_name = :1'
          ||' AND enabled_flag = ''Y'''
          ||' AND t.column_name NOT IN '
            ||'(SELECT column_name'
            ||' FROM fem_table_prop_col_req'
            ||' WHERE table_property_code = :2) ';
    IF p_prop_type <> 'TABLE_COLUMN' THEN
      v_sql := v_sql||'AND t.column_name IN '
                    ||'(SELECT column_name'
                    ||' FROM fem_tab_column_prop'
                    ||' WHERE table_name = '''||p_tab_name||''''
                    ||' AND column_property_code = '''||v_col_prop_cd||''')';
    END IF;
    IF p_col_req_type = 'FIXED_AND_ONE_NUMBER' THEN
      v_sql := v_sql||' AND t.fem_data_type_code = ''NUMBER''';
    ELSIF p_col_req_type = 'FIXED_AND_ANY_VSR_DIM_COL' THEN
      v_sql := v_sql||' AND nvl(x.value_set_required_flag,''N'') = ''N''';
    END IF;

    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'v_sql(30) = '||v_sql);
    END IF;

    v_count := 0;
    v_vsr_count := 0;
    v_col_list := NULL;
    OPEN cols_cv FOR v_sql USING p_tab_name, p_tab_prop_cd;
    LOOP
      FETCH cols_cv INTO v_col_name, v_vsr_flag;
      EXIT WHEN cols_cv%NOTFOUND;
      v_count := v_count + 1;

      -- For Column Req Type of FIXED, there should be no
      -- other columns defined outside the set of required columns.
      -- Exit loop once one is found.
      -- For Column Req Type of FIXED_AND_ONE_NUMBER and OTHER_THAN,
      -- just need to verify at least one exists.  Exit loop
      -- once one is found.
      EXIT WHEN (p_col_req_type IN ('FIXED',
                                    'FIXED_AND_ONE_NUMBER',
                                    'OTHER_THAN'));

      -- For Column Req Type of FIXED_AND_ONE_VSR_DIM_COL,
      -- need to make sure that at least one VSR column is
      -- defined, outside the required columns
      IF p_col_req_type = 'FIXED_AND_ONE_VSR_DIM_COL' THEN
        IF v_vsr_flag = 'Y' THEN
          v_vsr_count := 1;
        END IF;
      END IF;

      -- For Column Req Type of FIXED_AND_ONE_VSR_DIM_COL and
      -- FIXED_AND_ANY_VSR_DIM_COL, need to make sure that all columns
      -- outside the required columns are VSR dimension columns.
      IF p_col_req_type IN ('FIXED_AND_ONE_VSR_DIM_COL',
                            'FIXED_AND_ANY_VSR_DIM_COL') THEN
        IF v_vsr_flag = 'N' THEN
          -- Bug 4645761: For LEDGER_PK property, CURRENCY_TYPE_CODE column
          -- is an exception in that it is not required but is also not a
          -- VSR dimension column.  To resolve this in the short term,
          -- we will just mark as error if the non-VSR column is
          -- CURRENCY_TYPE_CODE.  Remove this code once the long term
          -- solution (bug 4669790) is implemented.

          -- Start bug code (4645761 and 6503068) --
          IF p_tab_prop_cd LIKE '%LEDGER_PK'
             AND v_col_name = 'CURRENCY_TYPE_CODE' THEN
            null;
          -- End bug code --

          ELSIF v_col_list IS NULL THEN
            v_col_list := v_col_name;
          ELSE
            v_col_list := v_col_list||', '||v_col_name;
          END IF;
        END IF;
      END IF; -- p_col_req_type
    END LOOP;
    CLOSE cols_cv;

    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'v_count = '||v_count||'; v_vsr_count = '||v_vsr_count);
    END IF;

    -- For Column Req Type of FIXED_AND_ONE_VSR_DIM_COL and
    -- FIXED_AND_ANY_VSR_DIM_COL, see if any non-VSR dim cols exist
    IF p_col_req_type IN ('FIXED_AND_ONE_VSR_DIM_COL',
                          'FIXED_AND_ANY_VSR_DIM_COL') AND
       v_col_list IS NOT NULL THEN
      Log_Table_Class_Error(
        p_tab_name      => p_tab_name,
        p_tab_class_cd  => p_tab_class_cd,
        p_msg_name      => 'FEM_TABCLASS_NOT_VSR_DIM_COL',
        p_token1        => 'OBJECT',
        p_value1        => v_obj_name,
        p_token2        => 'COL_LIST',
        p_value2        => v_col_list);
      v_passed_valid := c_false;
    END IF;

    v_msg_name := NULL;
    IF v_vsr_count = 0 AND
       p_col_req_type = 'FIXED_AND_ONE_VSR_DIM_COL' THEN
      v_msg_name := 'FEM_TABCLASS_MISS_VSRDIM_COL';
    ELSIF v_count = 0 THEN
      -- For Column Req Type of OTHER_THAN or FIXED_AND_ONE%,
      -- there were no column defined outside
      -- the set of "other than" or "required" columns
      IF p_col_req_type = 'OTHER_THAN' THEN
        v_msg_name := 'FEM_TABCLASS_MISS_OTHER_COL';
      ELSIF p_col_req_type = 'FIXED_AND_ONE_NUMBER' THEN
        v_msg_name := 'FEM_TABCLASS_MISS_NUMBER_COL';
      END IF; -- p_col_req_type
    ELSE  -- v_count > 0
      -- For Column Req Type of FIXED, there were other
      -- columns defined outside the set of required columns.
      IF p_col_req_type = 'FIXED' THEN
        v_msg_name := 'FEM_TABCLASS_EXTRA_COLS';
      END IF;
    END IF;  -- v_count = 0

    IF v_msg_name IS NOT NULL THEN
      -- Generate list of required (or excluded) columns
      -- only if the list has not already been generated.
      v_count := 0;
      FOR req_cols IN c_req_cols LOOP
        IF v_count = 0 THEN
          v_col_list := req_cols.column_name;
        ELSE
          v_col_list := v_col_list||', '||req_cols.column_name;
        END IF;
        v_count := v_count + 1;
      END LOOP;

      Log_Table_Class_Error(
        p_tab_name      => p_tab_name,
        p_tab_class_cd  => p_tab_class_cd,
        p_msg_name      => v_msg_name,
        p_token1        => 'OBJECT',
        p_value1        => v_obj_name,
        p_token2        => 'COL_LIST',
        p_value2        => v_col_list);
      v_passed_valid := c_false;
    END IF; -- v_msg_name IS NOT NULL

  END IF; -- p_col_req_type NOT IN ('FIXED_ANY','ONE_ANY')

  x_passed_validation := v_passed_valid;

  IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'x_passed_validation = '||x_passed_validation);
  END IF;
  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;

EXCEPTION
  WHEN others THEN
    IF FND_LOG.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_exception,
        p_module   => C_MODULE,
        p_msg_text => 'Validate_Prop_Col_Req failed unexpectedly: '||SQLERRM);
    END IF;
    x_passed_validation := c_false;

END Validate_Prop_Col_Req;


------------------------------------
-- Non-Generic Validation Procedures
------------------------------------

-- Validate_PK_Cols_Not_Null:
-- Makes sure that all columns in the Processing Key is not null.

PROCEDURE Validate_PK_Cols_Not_Null (
p_tab_name           IN         VARCHAR2,
p_tab_class_cd       IN         VARCHAR2,
p_tab_owner          IN         VARCHAR2,
p_db_tab_name        IN         VARCHAR2,
x_passed_validation  OUT NOCOPY VARCHAR2) IS
  C_MODULE            CONSTANT FND_LOG_MESSAGES.module%TYPE :=
     'fem.plsql.fem_admin_util_pkg.validate_pk_cols_not_null';

  CURSOR c_null_cols (p_tab_name VARCHAR2, p_owner VARCHAR2) IS
    SELECT a.column_name
    FROM all_tab_columns a, fem_tab_column_prop p
    WHERE a.table_name = p_tab_name
    AND a.owner = p_owner
    AND a.nullable = 'Y'
    AND a.table_name = p.table_name
    AND a.column_name = p.column_name
    AND p.column_property_code = 'PROCESSING_KEY'
    ORDER BY a.column_name;

  v_count    NUMBER;
  v_col_list VARCHAR2(2000);
BEGIN
  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;

  v_col_list := null;
  v_count := 1;
  FOR null_cols IN c_null_cols(p_db_tab_name, p_tab_owner) LOOP
    IF v_count = 1 THEN
      v_col_list := null_cols.column_name;
    ELSE
      v_col_list := v_col_list || ', '||null_cols.column_name;
    END IF;
    v_count := v_count + 1;
  END LOOP;

  IF v_col_list IS NULL THEN
    x_passed_validation := c_true;
  ELSE
    Log_Table_Class_Error(
      p_tab_name      => p_tab_name,
      p_tab_class_cd  => p_tab_class_cd,
      p_msg_name => 'FEM_TABCLASS_PK_COLS_NULL',
      p_token1 => 'COLS',
      p_value1 => v_col_list);
    x_passed_validation := c_false;
  END IF;

  IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'x_passed_validation = '||x_passed_validation);
  END IF;
  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;
EXCEPTION
  WHEN others THEN
    IF FND_LOG.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_exception,
        p_module   => C_MODULE,
        p_msg_text => 'Validate_PK_Cols_Not_Null failed unexpectedly: '||SQLERRM);
    END IF;
    x_passed_validation := c_false;

END Validate_PK_Cols_Not_Null;

-- Validate_Editable:
-- Makes sure all object columns are updateable, insertable, deletable

PROCEDURE Validate_Editable (
p_tab_name           IN         VARCHAR2,
p_tab_class_cd       IN         VARCHAR2,
x_passed_validation  OUT NOCOPY VARCHAR2) IS
  C_MODULE            CONSTANT FND_LOG_MESSAGES.module%TYPE :=
     'fem.plsql.fem_admin_util_pkg.validate_editable';

  v_obj_type          USER_OBJECTS.object_type%TYPE;
  v_count             NUMBER;
BEGIN
  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;

  SELECT object_type
  INTO v_obj_type
  FROM user_objects
  WHERE object_name = p_tab_name;

  IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'v_obj_type = '||v_obj_type);
  END IF;

  IF v_obj_type = 'SYNONYM' THEN
    x_passed_validation := c_true;
  ELSIF v_obj_type = 'VIEW' THEN
    SELECT count(*)
    INTO v_count
    FROM user_updatable_columns
    WHERE table_name = p_tab_name
    AND (updatable = 'NO'
      OR insertable = 'NO'
      OR deletable = 'NO');

    IF v_count > 0 THEN
      Log_Table_Class_Error(
        p_tab_name      => p_tab_name,
        p_tab_class_cd  => p_tab_class_cd,
        p_msg_name      => 'FEM_TABCLASS_NOT_EDITABLE');
      x_passed_validation := c_false;
    ELSE
      x_passed_validation := c_true;
    END IF;
  ELSE
    x_passed_validation := c_false;
  END IF; -- v_obj_type

  IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'x_passed_validation = '||x_passed_validation);
  END IF;
  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;
EXCEPTION
  WHEN others THEN
    IF FND_LOG.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_exception,
        p_module   => C_MODULE,
        p_msg_text => 'Validate_Editable failed unexpectedly: '||SQLERRM);
    END IF;
    x_passed_validation := c_false;

END Validate_Editable;

-- Validate_Table_Name_Restrict:
-- Makes sure table name conforms to the requirements of the classification.
-- Currently, this is not metadata driven and only applies to the Ledger
-- classifications.  This checks to make sure that only FEM_BALANCES can
-- receive the Ledger classifications.

PROCEDURE Validate_Table_Name_Restrict (
p_tab_name           IN         VARCHAR2,
p_tab_class_cd       IN         VARCHAR2,
x_passed_validation  OUT NOCOPY VARCHAR2) IS
  C_MODULE            CONSTANT FND_LOG_MESSAGES.module%TYPE :=
     'fem.plsql.fem_admin_util_pkg.validate_table_name_restriction';
BEGIN
  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;

  -- Init as passed
  x_passed_validation := c_true;

  IF p_tab_name <> 'FEM_BALANCES' THEN
    Log_Table_Class_Error(
      p_tab_name      => p_tab_name,
      p_tab_class_cd  => p_tab_class_cd,
      p_msg_name      => 'FEM_TABCLASS_TAB_NAME_RESTRICT',
      p_token1        => 'TAB_NAME',
      p_value1        => 'FEM_BALANCES');

    x_passed_validation := c_false;
  END IF;

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;
EXCEPTION
  WHEN others THEN
    IF FND_LOG.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_exception,
        p_module   => C_MODULE,
        p_msg_text => 'Validate_Table_Name_Restriction failed unexpectedly: '||SQLERRM);
    END IF;
    x_passed_validation := c_false;

END Validate_Table_Name_Restrict;

/*  Change history
   06/12/2007  RFLIPPO  Bug#6034150 allow non-dimension nullable columns
                        to be unmapped.
*/
-- Validate_Data_Loader:
-- Procedure to perform validation specific to the
-- SOURCE_DATA_TABLE classification.
-- At this time, this procedure does not test to see if the
-- mapped interface columns have compatible data types base columns.

    -----------------------------------------------------------
    -- Bug#5226300 Verify that the interface column characteristics
    -- match those of the target column
    --
    -- The logic is as follows:
    --  For all cols in the target table where col_name not in
    --   ('CAL_PERIOD_ID','CREATED_BY_REQUEST_ID','CREATED_BY_OBJECT_ID'
    --    'LAST_UPDATED_BY_REQUEST_ID','LAST_UPDATED_BY_OBJECT_ID') LOOP
    --    IF fem_data_type_code <> 'DIMENSION' OR
    --       (fem_data_type_code= 'DIMENSION' AND
    --        the dimension has no surrogate key) THEN
    --       compare col characteristics of the interface col
    --       directly with target col.  If anything doesn't
    --       match, give error.
    --    ELSE fem_data_type_code = 'DIMENSION' AND
    --       dimension has surrogate key THEN
    --         verify that the interface column characteristics match the
    --          display_code col for that dimension in the dimension _B table
    --    END IF;
    --    END LOOP;
    --------------------------------------------------------------


PROCEDURE Validate_Data_Loader (
p_tab_name           IN         VARCHAR2,
p_tab_class_cd       IN         VARCHAR2,
p_tab_owner          IN         VARCHAR2,
p_db_tab_name        IN         VARCHAR2,
x_passed_validation  OUT NOCOPY VARCHAR2) IS
  C_MODULE            CONSTANT FND_LOG_MESSAGES.module%TYPE :=
     'fem.plsql.fem_admin_util_pkg.validate_data_loader';

  CURSOR c_uniq_idx(p_owner VARCHAR2, p_name VARCHAR2) IS
    SELECT index_name
    FROM   all_indexes
    WHERE  table_name = p_name
      AND  table_owner = p_owner
      AND  uniqueness = 'UNIQUE';

  CURSOR c_int_col (p_owner VARCHAR2, p_name VARCHAR2) IS
    SELECT column_name, data_type, data_length, data_precision
    FROM   all_tab_columns
    WHERE  owner = p_owner
    AND  table_name = p_name
    AND  nullable = 'N'
    AND  column_name IN ('CAL_PERIOD_NUMBER',
                         'CALP_DIM_GRP_DISPLAY_CODE',
                         'CAL_PERIOD_END_DATE',
                         'STATUS')
    ORDER BY column_name;

  /*Bug#6034150 only require DIMENSION cols or NOT NULL cols
    to have interface col mapping.  For all other cols it is
    optional*/
  CURSOR c_missing_int_col (p_owner VARCHAR2, p_name VARCHAR2) IS
    SELECT f.column_name
    FROM fem_tab_columns_v f, all_tab_columns a
    WHERE f.table_name = p_name
      AND f.column_name NOT IN ('CREATED_BY_REQUEST_ID',
                              'LAST_UPDATED_BY_REQUEST_ID',
                              'CREATED_BY_OBJECT_ID',
                              'LAST_UPDATED_BY_OBJECT_ID',
                              'CAL_PERIOD_ID')
      AND f.interface_column_name IS NULL
      AND f.table_name = a.table_name
      AND a.owner = p_owner
      AND a.column_name = f.column_name
      AND (f.fem_data_type_code = 'DIMENSION' OR a.nullable = 'N')
    ORDER BY f.column_name;

  CURSOR c_tgt_col (p_name IN VARCHAR2, p_owner IN VARCHAR2) IS
     SELECT F.column_name, F.interface_column_name, F.fem_data_type_code, F.dimension_id,
            A.data_type, A.data_length, A.data_precision, A.data_scale
     FROM fem_tab_columns_b F, all_tab_columns A
     WHERE F.table_name = p_name
     AND F.column_name NOT IN ('CREATED_BY_REQUEST_ID',
                              'LAST_UPDATED_BY_REQUEST_ID',
                              'CREATED_BY_OBJECT_ID',
                              'LAST_UPDATED_BY_OBJECT_ID',
                              'CAL_PERIOD_ID')
      AND F.interface_column_name IS NOT NULL
      AND F.table_name = A.table_name
      AND F.column_name = A.column_name
      AND A.owner = p_tab_owner;


  v_count            NUMBER;
  v_passed_valid     VARCHAR2(1);
  v_return_status    VARCHAR2(1);
  v_int_tab_name     ALL_TABLES.table_name%TYPE;
  v_int_db_tab_name  ALL_TABLES.table_name%TYPE;
  v_int_owner        ALL_TABLES.owner%TYPE;
  v_col_prop         FEM_TAB_COLUMN_PROP.column_property_code%TYPE;
  v_matched          VARCHAR2(1);
  v_msg_data         VARCHAR2(2000);
  v_col_list         VARCHAR2(4000);

  -- Bug#5226300
  v_sql_stmt           VARCHAR2(4000);
  v_surrogate_key_flag VARCHAR2(1);
  v_dim_mbr_table      VARCHAR2(30);
  v_dim_mbr_col        VARCHAR2(30);
  v_dim_mbr_dc_col     VARCHAR2(30);
  v_dim_label          VARCHAR2(30);

  v_data_type          ALL_TAB_COLUMNS.data_type%TYPE;
  v_data_length        ALL_TAB_COLUMNS.data_length%TYPE;
  v_data_precision     ALL_TAB_COLUMNS.data_precision%TYPE;
  v_data_scale         ALL_TAB_COLUMNS.data_scale%TYPE;

  v_dim_dc_data_length ALL_TAB_COLUMNS.data_length%TYPE;
  v_dim_dc_data_type   ALL_TAB_COLUMNS.data_type%TYPE;
  v_mbr_b_owner        ALL_TABLES.owner%TYPE;
  v_mbr_b_table_name   ALL_TABLES.table_name%TYPE;
BEGIN
  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;

  -- Init variables
  v_passed_valid := c_true;
  v_col_prop := 'PROCESSING_KEY';

  -- Interface table must be registered
  BEGIN
    SELECT interface_table_name
    INTO v_int_tab_name
    FROM fem_tables_b
    WHERE table_name = p_tab_name
      AND interface_table_name IS NOT NULL;

    -- Get interface table name and owner
    FEM_Database_Util_Pkg.Get_Table_Owner (
      x_return_status => v_return_status,
      x_msg_count => v_count,
      x_msg_data => v_msg_data,
      p_syn_name => v_int_tab_name,
      x_tab_name => v_int_db_tab_name,
      x_tab_owner => v_int_owner);

    IF v_return_status <> c_success THEN
      IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FEM_ENGINES_PKG.TECH_MESSAGE(
          p_severity => FND_LOG.level_statement,
          p_module   => C_MODULE,
          p_msg_text => 'Call to FEM_Database_Util_Pkg.Get_Table_Owner failed');
      END IF;
      RAISE e_unexp;
    ELSE
      IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FEM_ENGINES_PKG.TECH_MESSAGE(
          p_severity => FND_LOG.level_statement,
          p_module   => C_MODULE,
          p_msg_text => 'v_int_db_tab_name = '||v_int_db_tab_name);
      END IF;
      IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FEM_ENGINES_PKG.TECH_MESSAGE(
          p_severity => FND_LOG.level_statement,
          p_module   => C_MODULE,
          p_msg_text => 'v_int_owner = '||v_int_owner);
      END IF;
    END IF;
  EXCEPTION
    WHEN others THEN
      Log_Table_Class_Error(
        p_tab_name      => p_tab_name,
        p_tab_class_cd  => p_tab_class_cd,
        p_msg_name      => 'FEM_TABCLASS_NO_INTERFACE_TAB');

      RAISE e_error;
  END;

  -- Only continue the validation if a valid interface table was designated.
  IF v_passed_valid = c_true THEN
    -- All dimension and not null columns should have an interface column mapping.
    v_col_list := null;
    v_count := 0;
    FOR missing_int_cols IN c_missing_int_col(p_tab_owner, p_tab_name) LOOP
      v_count := v_count + 1;
      IF v_count = 1 THEN
        v_col_list := missing_int_cols.column_name;
      ELSIF v_count < 134 THEN  -- ceil(4000/30) = 134
        v_col_list := v_col_list||', '||missing_int_cols.column_name;
      ELSE
        EXIT;
      END IF;
    END LOOP;

    IF v_col_list IS NOT NULL THEN
      Log_Table_Class_Error(
        p_tab_name      => p_tab_name,
        p_tab_class_cd  => p_tab_class_cd,
        p_msg_name      => 'FEM_TABCLASS_REQCOL_REQINTCOL',
        p_token1        => 'COLS',
        p_value1        => v_col_list);
      RAISE e_error;
    END IF;

    -- Make sure the three required Cal Period columns
    -- and the Status column
    -- are on the interface table with the proper data types.
    v_count := 0;
    FOR int_cols IN c_int_col (v_int_owner, v_int_db_tab_name) LOOP
      IF int_cols.column_name = 'CAL_PERIOD_NUMBER' THEN
        IF int_cols.data_type = 'NUMBER' AND
           nvl(int_cols.data_precision,38) <= 15 THEN
          v_count := v_count + 1;
        END IF;
      ELSIF int_cols.column_name = 'CALP_DIM_GRP_DISPLAY_CODE' THEN
        IF int_cols.data_type = 'VARCHAR2' AND
           int_cols.data_length <= 150 THEN
          v_count := v_count + 10;
        END IF;
      ELSIF int_cols.column_name = 'CAL_PERIOD_END_DATE' THEN
        IF int_cols.data_type = 'DATE' THEN
          v_count := v_count + 100;
        END IF;
      ELSIF int_cols.column_name = 'STATUS' THEN
        IF int_cols.data_type = 'VARCHAR2' AND
           int_cols.data_length = 60 THEN
          v_count := v_count + 1000;
        END IF;
      END IF;
    END LOOP;

    IF v_count <> 1111 THEN
      IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FEM_ENGINES_PKG.TECH_MESSAGE(
          p_severity => FND_LOG.level_statement,
          p_module   => C_MODULE,
          p_msg_text => 'v_count (int_reqcol) = '||v_count);
      END IF;
      Log_Table_Class_Error(
          p_tab_name      => p_tab_name,
          p_tab_class_cd  => p_tab_class_cd,
          p_msg_name      => 'FEM_TABCLASS_LDR_REQCOLS');

      RAISE e_error;
    END IF;

    -- Bug#5226300 Verify that the interface column characteristics
    FOR col IN c_tgt_col (p_tab_name, p_tab_owner) LOOP
       v_surrogate_key_flag := '';
       IF col.fem_data_type_code = 'DIMENSION' THEN
         SELECT member_b_table_name, member_col, member_display_code_col, dimension_varchar_label
         INTO v_dim_mbr_table, v_dim_mbr_col, v_dim_mbr_dc_col, v_dim_label
         FROM fem_xdim_dimensions_vl
         WHERE dimension_id = col.dimension_id;

         IF v_dim_mbr_col = v_dim_mbr_dc_col THEN
            v_surrogate_key_flag := 'N';
         ELSE v_surrogate_key_flag := 'Y';
         END IF;
       END IF;

       -- get the interface col characteristics

       BEGIN
          SELECT data_type, data_length, data_precision, data_scale
          INTO v_data_type, v_data_length, v_data_precision, v_data_scale
          FROM   all_tab_columns
          WHERE  owner = v_int_owner
          AND  table_name = v_int_db_tab_name
          AND column_name = col.interface_column_name;
       EXCEPTION
          WHEN no_data_found THEN -- this should never occur since the UI requires the interface_col to exist
             Log_Table_Class_Error(
              p_tab_name      => p_tab_name,
              p_tab_class_cd  => p_tab_class_cd,
              p_msg_name      => 'FEM_TABCLASS_LDR_NOINTFCOL',
              p_token1        => 'INTFCOL',
              p_value1        => col.interface_column_name,
              p_token2        => 'COL',
              p_value2        => col.column_name,
              p_token3        => 'TAB',
              p_value3        => v_int_db_tab_name);

              RAISE e_error;

       END;
       IF (col.fem_data_type_code <> 'DIMENSION') OR
         (col.fem_data_type_code = 'DIMENSION' AND v_surrogate_key_flag = 'N') THEN

          IF col.data_type <> v_data_type THEN
             Log_Table_Class_Error(
              p_tab_name      => p_tab_name,
              p_tab_class_cd  => p_tab_class_cd,
              p_msg_name      => 'FEM_TABCLASS_LDR_INTFDATATYPE',
              p_token1        => 'INTFCOL',
              p_value1        => col.interface_column_name,
              p_token2        => 'COL',
              p_value2        => col.column_name);


             RAISE e_error;
          ELSIF col.data_length < v_data_length
             OR NVL(col.data_precision,col.data_length) < NVL(v_data_precision,v_data_length)
             OR NVL(col.data_scale,col.data_length) < NVL(v_data_scale,v_data_length) THEN

             Log_Table_Class_Error(
              p_tab_name      => p_tab_name,
              p_tab_class_cd  => p_tab_class_cd,
              p_msg_name      => 'FEM_TABCLASS_LDR_INTFCHAR',
              p_token1        => 'INTFCOL',
              p_value1        => col.interface_column_name,
              p_token2        => 'COL',
              p_value2        => col.column_name);


             RAISE e_error;
          END IF;
       ELSE -- column is for a surrogate key DIMENSION
          -- Get Dimension Member _B table name and owner
          BEGIN
             FEM_Database_Util_Pkg.Get_Table_Owner (
               x_return_status => v_return_status,
               x_msg_count => v_count,
               x_msg_data => v_msg_data,
               p_syn_name => v_dim_mbr_table,
               x_tab_name => v_mbr_b_table_name,
               x_tab_owner => v_mbr_b_owner);

             IF v_return_status <> c_success THEN
               IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                 FEM_ENGINES_PKG.TECH_MESSAGE(
                   p_severity => FND_LOG.level_statement,
                   p_module   => C_MODULE,
                   p_msg_text => 'Call to FEM_Database_Util_Pkg.Get_Table_Owner failed');
               END IF;
               RAISE e_unexp;
             ELSE
               IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                 FEM_ENGINES_PKG.TECH_MESSAGE(
                   p_severity => FND_LOG.level_statement,
                   p_module   => C_MODULE,
                   p_msg_text => 'v_mbr_b_table_name = '||v_mbr_b_table_name);
               END IF;
               IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                 FEM_ENGINES_PKG.TECH_MESSAGE(
                   p_severity => FND_LOG.level_statement,
                   p_module   => C_MODULE,
                   p_msg_text => 'v_mbr_b_owner = '||v_mbr_b_owner);
               END IF;
             END IF;
           EXCEPTION
              WHEN others THEN
                 Log_Table_Class_Error(
                    p_tab_name      => p_tab_name,
                    p_tab_class_cd  => p_tab_class_cd,
                    p_msg_name      => 'FEM_TABCLASS_LDR_DIM_METADATA',
                    p_token1        => 'TAB',
                    p_value1        => v_mbr_b_table_name);

                 RAISE e_error;
           END;

           -- get display_code metadata for the dimension
           -- we only need to get the data_type and data length, because all
           -- display_code columns are varchar2 by definition
           SELECT data_type,data_length
           INTO v_dim_dc_data_type,v_dim_dc_data_length
           FROM all_tab_columns
           WHERE owner = v_mbr_b_owner
           AND table_name = v_mbr_b_table_name
           AND column_name = v_dim_mbr_dc_col;


           IF v_data_type <> v_dim_dc_data_type THEN

              Log_Table_Class_Error(
                 p_tab_name      => p_tab_name,
                 p_tab_class_cd  => p_tab_class_cd,
                 p_msg_name      => 'FEM_TABCLASS_LDR_DIMDATATYPE',
                 p_token1        => 'INTFCOL',
                 p_value1        => col.interface_column_name,
                 p_token2        => 'COL',
                 p_value2        => col.column_name,
                 p_token3        => 'DIM',
                 p_value3        => v_dim_label);


               RAISE e_error;
           ELSIF v_dim_dc_data_length < v_data_length THEN
              Log_Table_Class_Error(
                 p_tab_name      => p_tab_name,
                 p_tab_class_cd  => p_tab_class_cd,
                 p_msg_name      => 'FEM_TABCLASS_LDR_DIMCHAR',
                 p_token1        => 'INTFCOL',
                 p_value1        => col.interface_column_name,
                 p_token2        => 'COL',
                 p_value2        => col.column_name,
                 p_token3        => 'DIM',
                 p_value3        => v_dim_label);


              RAISE e_error;
           END IF;

       END IF;

    END LOOP;

    -- Make sure a unique key of the interface table matches
    -- with the processing key of the base table.
    v_matched := c_false;
    FOR idx IN c_uniq_idx(v_int_owner, v_int_db_tab_name) LOOP
      -- First see if any columns are in the interface index but not in the
      -- proc key.  Need to exclude columns in the proc key if they do not
      -- have a direct mapping (CAL_PERIOD_ID) or no mapping at all
      -- (Undo WHO columns).
      SELECT count(*)
      INTO v_count
      FROM all_ind_columns i, fem_tab_columns_b c
      WHERE i.index_name = idx.index_name
        AND i.table_owner = v_int_owner
        AND i.table_name = v_int_db_tab_name
        AND c.table_name = p_tab_name
        AND i.column_name = c.interface_column_name
        AND i.column_name NOT IN ('CAL_PERIOD_NUMBER',
                                  'CALP_DIM_GRP_DISPLAY_CODE',
                                  'CAL_PERIOD_END_DATE')
        AND c.column_name NOT IN
         (SELECT column_name
          FROM fem_tab_column_prop
          WHERE table_name = p_tab_name
            AND column_property_code = v_col_prop
            AND column_name NOT IN ('CAL_PERIOD_ID',
                                    'CREATED_BY_REQUEST_ID',
                                    'LAST_UPDATED_BY_REQUEST_ID',
                                    'CREATED_BY_OBJECT_ID',
                                    'LAST_UPDATED_BY_OBJECT_ID'));

      IF v_count = 0 THEN
        v_matched := c_true;
      END IF;

      -- Then see if any columns are in the proc key but not in the index
      IF v_matched = c_true THEN
        SELECT count(*)
        INTO v_count
        FROM fem_tab_column_prop
        WHERE table_name = p_tab_name
          AND column_property_code = v_col_prop
          AND column_name NOT IN ('CAL_PERIOD_ID',
                                  'CREATED_BY_REQUEST_ID',
                                  'LAST_UPDATED_BY_REQUEST_ID',
                                  'CREATED_BY_OBJECT_ID',
                                  'LAST_UPDATED_BY_OBJECT_ID')
          AND column_name NOT IN
           (SELECT c.column_name
            FROM all_ind_columns i, fem_tab_columns_b c
            WHERE i.index_name = idx.index_name
              AND i.table_owner = v_int_owner
              AND i.table_name = v_int_db_tab_name
              AND c.table_name = p_tab_name
              AND i.column_name = c.interface_column_name
              AND i.column_name NOT IN ('CAL_PERIOD_NUMBER',
                'CALP_DIM_GRP_DISPLAY_CODE','CAL_PERIOD_END_DATE'));

        IF v_count > 0 THEN
          v_matched := c_false;
        END IF;
      END IF; -- v_matched = c_true

      -- Check to make sure that if CAL_PERIOD_ID is part
      -- of the processing key of the base table, the corresponding
      -- three cal period interface columns are part of the
      -- matching unique index.
      IF v_matched = c_true THEN
        SELECT count(*)
        INTO v_count
        FROM fem_tab_column_prop
        WHERE table_name = p_tab_name
          AND column_property_code = v_col_prop
          AND column_name = 'CAL_PERIOD_ID';

        IF v_count > 0 THEN
          SELECT count(*)
          INTO v_count
          FROM all_ind_columns i
          WHERE i.index_name = idx.index_name
            AND i.table_owner = v_int_owner
            AND i.table_name = v_int_db_tab_name
            AND i.column_name IN ('CAL_PERIOD_NUMBER',
              'CALP_DIM_GRP_DISPLAY_CODE','CAL_PERIOD_END_DATE');

          IF v_count <> 3 THEN
            v_matched := c_false;
          END IF;
        END IF;
      END IF; -- v_matched = c_true

      EXIT WHEN (v_matched = c_true);
    END LOOP; -- c_uniq_idx

    IF v_matched = c_false THEN
      Log_Table_Class_Error(
          p_tab_name      => p_tab_name,
          p_tab_class_cd  => p_tab_class_cd,
          p_msg_name      => 'FEM_TABCLASS_LDR_PK_NOMATCH');
      v_passed_valid := c_false;
    END IF;
  END IF; -- v_passed_valid = c_true

  -- Bug 4534907: Create client data loader rule related metadata
  IF v_passed_valid = c_true THEN
    v_passed_valid := Create_Data_Loader_Rule(
                            p_tab_name     => p_tab_name,
                            p_tab_class_cd => p_tab_class_cd);
  END IF;

  x_passed_validation := v_passed_valid;

  IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'x_passed_validation = '||x_passed_validation);
  END IF;
  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;
EXCEPTION
  WHEN e_error THEN
    x_passed_validation := c_false;

  WHEN others THEN
    IF FND_LOG.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_exception,
        p_module   => C_MODULE,
        p_msg_text => 'Validate_Data_Loader failed unexpectedly: '||SQLERRM);
    END IF;
    Log_Table_Class_Error(
      p_tab_name      => p_tab_name,
      p_tab_class_cd  => p_tab_class_cd,
      p_msg_name => 'FEM_RSM_UNEXPECTED_ERROR',
      p_token1 => 'ROUTINE_NAME',
      p_value1 => C_MODULE);

    x_passed_validation := c_false;

END Validate_Data_Loader;


/***************************************************************************
 ***************************************************************************
 *
 *                   ====================================
 *                   Procedure: Delete_Obj_Tuning_Options
 *                   ====================================
 *
 ***************************************************************************
 **************************************************************************/

PROCEDURE Delete_Obj_Tuning_Options (
p_api_version     IN         NUMBER     DEFAULT c_api_version,
p_init_msg_list   IN         VARCHAR2   DEFAULT c_false,
p_commit          IN         VARCHAR2   DEFAULT c_false,
p_encoded         IN         VARCHAR2   DEFAULT c_true,
x_return_status   OUT NOCOPY VARCHAR2,
x_msg_count       OUT NOCOPY NUMBER,
x_msg_data        OUT NOCOPY VARCHAR2,
p_object_id       IN         NUMBER
) IS

   C_MODULE        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
     'fem.plsql.fem_admin_util_pkg.delete_obj_tuning_options';
   C_API_NAME      CONSTANT VARCHAR2(30)  := 'Delete_Obj_Tuning_Options';

   v_process_ds_cd NUMBER;

-- Select all multiprocessing option assignments specific to the given Object ID.
   CURSOR c1 (cp_object_id IN NUMBER) IS
      SELECT process_data_slices_cd
      FROM fem_mp_process_options
      WHERE object_id = cp_object_id
      FOR UPDATE;

BEGIN

  -- Initialize return status to unexpected error
  x_return_status := c_unexp;

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;

  IF p_init_msg_list = c_true THEN
     FND_MSG_PUB.Initialize;
  END IF;

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

-- --------------------------------------------------------------------------
-- Delete each MP process option assignment for the given Object ID, and if
-- it references a data slice definition that is not referenced by any other
-- MP process option assignment, then delete it too.
-- --------------------------------------------------------------------------

   FOR process_option IN c1 (p_object_id) LOOP

      v_process_ds_cd := process_option.process_data_slices_cd;

      DELETE FROM fem_mp_process_options
      WHERE CURRENT OF c1;

      DELETE FROM fem_mp_data_slices
      WHERE process_data_slices_cd = v_process_ds_cd
        AND NOT EXISTS
           (SELECT NULL
            FROM fem_mp_process_options
            WHERE process_data_slices_cd = v_process_ds_cd);

      DELETE FROM fem_mp_data_slice_cols
      WHERE process_data_slices_cd = v_process_ds_cd
        AND NOT EXISTS
           (SELECT NULL
            FROM fem_mp_process_options
            WHERE process_data_slices_cd = v_process_ds_cd);

   END LOOP;

-- --------------------------------------------------------------------------
-- Delete Object ID-specific process behavior parameter assignments for the
-- current object.
-- --------------------------------------------------------------------------

   DELETE FROM fem_pb_parameters p
   WHERE object_id = p_object_id;

   IF (p_commit = c_true) THEN
     COMMIT;
   END IF;

   -- In case any messages are generated
   FND_MSG_PUB.Count_And_Get(p_encoded => p_encoded,
                             p_count => x_msg_count,
                             p_data => x_msg_data);

   x_return_status := c_success;

   IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
         p_severity => FND_LOG.level_procedure,
         p_module   => C_MODULE,
         p_msg_text => 'End Procedure');
   END IF;

EXCEPTION
  WHEN others THEN
    IF FND_LOG.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_exception,
        p_module   => C_MODULE,
        p_msg_text => 'Unexpected error: '||SQLERRM);
    END IF;
    IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_procedure,
        p_module   => C_MODULE,
        p_msg_text => 'End Procedure');
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded => p_encoded,
                              p_count => x_msg_count,
                              p_data => x_msg_data);

    x_return_status := c_unexp;

END Delete_Obj_Tuning_Options;


/***************************************************************************
 ***************************************************************************
 *                                                                         *
 *                   ================================                      *
 *                   Procedure: New Local_VS_Combo_ID                      *
 *                   ================================                      *
 *                                                                         *
 ***************************************************************************
 **************************************************************************/

PROCEDURE New_Local_VS_Combo_ID (
p_api_version     IN         NUMBER     DEFAULT c_api_version,
p_init_msg_list   IN         VARCHAR2   DEFAULT c_false,
p_commit          IN         VARCHAR2   DEFAULT c_false,
p_encoded         IN         VARCHAR2   DEFAULT c_true,
x_return_status   OUT NOCOPY VARCHAR2,
x_msg_count       OUT NOCOPY NUMBER,
x_msg_data        OUT NOCOPY VARCHAR2,
p_gvsc_id         IN  NUMBER
)
IS
BEGIN
  x_return_status := c_success;
END New_Local_VS_Combo_ID;


/***************************************************************************
 ***************************************************************************
 *                                                                         *
 *                  =================================                      *
 *                  Procedure: Validate Table Columns                      *
 *                  =================================                      *
 *                                                                         *
 ***************************************************************************
 ***************************************************************************

 This procedure validates that table property required columns
 satifies the column requirements as defined by FEM_COLUMN_REQUIREMNT_B.

 **************************************************************************/

PROCEDURE Validate_Column_Req (
p_tab_name          IN         VARCHAR2,
p_tab_class_cd      IN         VARCHAR2,
p_tab_owner         IN         VARCHAR2,
p_db_tab_name       IN         VARCHAR2,
x_passed_validation OUT NOCOPY VARCHAR2
)
IS
  C_MODULE            CONSTANT FND_LOG_MESSAGES.module%TYPE :=
     'fem.plsql.fem_admin_util_pkg.validate_column_req';

  -- Cursor to fetch all registered columns that match
  -- those in FEM_COLUMN_REQUIREMNT_B
  CURSOR c_req_col (p_owner VARCHAR2, p_syn_name VARCHAR2,
                    p_db_name VARCHAR2, p_tab_class_cd IN VARCHAR2) IS
    SELECT DISTINCT t.column_name,
           t.fem_data_type_code col_fem_data_type_code,
           r.fem_data_type_code req_fem_data_type_code,
           a.data_length||', '||a.data_precision||', '||a.data_scale col_data_length,
           r.data_length||', '||r.data_precision||', '||r.data_scale req_data_length,
           a.data_type col_data_type, r.data_type req_data_type,
           a.nullable col_nullable, tp.nullable_flag req_nullable
    FROM fem_tab_columns_b t, fem_column_requiremnt_b r, all_tab_columns a,
         fem_table_prop_col_req tp, fem_table_class_prop tc
    WHERE t.table_name = p_syn_name
      AND t.column_name = r.column_name
      AND a.table_name = p_db_name
      AND a.owner = p_tab_owner
      AND t.column_name = a.column_name
      AND t.column_name = tp.column_name
      AND tp.table_property_code = tc.table_property_code
      AND tc.table_classification_code = p_tab_class_cd;

  v_passed_valid        VARCHAR2(1);
  v_fem_data_type_name  FEM_TAB_COLUMNS_B.fem_data_type_code%TYPE;
BEGIN

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;
  IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'p_tab_class_cd = '||p_tab_class_cd);
  END IF;

  -- Init var
  v_passed_valid := c_true;

  FOR req_cols IN c_req_col(p_tab_owner, p_tab_name,
                            p_db_tab_name, p_tab_class_cd) LOOP
    -- Check FEM Data Type Code
    IF req_cols.col_fem_data_type_code <> req_cols.req_fem_data_type_code THEN
      BEGIN
       SELECT fem_data_type_name
       INTO v_fem_data_type_name
       FROM fem_data_types_vl
       WHERE fem_data_type_code = req_cols.req_fem_data_type_code;
      EXCEPTION
        WHEN others THEN
          v_fem_data_type_name := req_cols.req_fem_data_type_code;
      END;
      Log_Table_Class_Error(
        p_tab_name      => p_tab_name,
        p_tab_class_cd  => p_tab_class_cd,
        p_msg_name => 'FEM_ADM_BAD_DATA_CODE_ERR',
        p_token1 => 'PROP_REQ_COL',
        p_value1 => req_cols.column_name,
        p_token2 => 'FEM_DATA_TYPE',
        p_value2 => v_fem_data_type_name);
      v_passed_valid := c_false;
    END IF;

    IF req_cols.col_data_type = req_cols.req_data_type THEN
      IF req_cols.col_data_length <> req_cols.req_data_length THEN
        Log_Table_Class_Error(
          p_tab_name      => p_tab_name,
          p_tab_class_cd  => p_tab_class_cd,
          p_msg_name => 'FEM_ADM_BAD_DATA_LENGTH_ERR',
          p_token1 => 'PROP_REQ_COL',
          p_value1 => req_cols.column_name,
          p_token2 => 'DATA_LENGTH',
          p_value2 => req_cols.req_data_length);
        v_passed_valid := c_false;
      END IF;
    ELSE
      Log_Table_Class_Error(
        p_tab_name      => p_tab_name,
        p_tab_class_cd  => p_tab_class_cd,
        p_msg_name => 'FEM_ADM_BAD_DATA_TYPE_ERR',
        p_token1 => 'PROP_REQ_COL',
        p_value1 => req_cols.column_name,
        p_token2 => 'DATA_TYPE',
        p_value2 => req_cols.req_data_type);
      v_passed_valid := c_false;
    END IF;

    IF req_cols.req_nullable = 'N' AND
       req_cols.col_nullable = 'Y' THEN
      Log_Table_Class_Error(
        p_tab_name      => p_tab_name,
        p_tab_class_cd  => p_tab_class_cd,
        p_msg_name => 'FEM_ADM_BAD_NULLABILITY_ERR',
        p_token1 => 'PROP_REQ_COL',
        p_value1 => req_cols.column_name);
      v_passed_valid := c_false;
    END IF;


  END LOOP; -- c_req_col

  x_passed_validation := v_passed_valid;

  IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'x_passed_validation = '||x_passed_validation);
  END IF;
  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;
EXCEPTION
  WHEN others THEN
    IF FND_LOG.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_exception,
        p_module   => C_MODULE,
        p_msg_text => 'Validate_Column_Req failed unexpectedly: '||SQLERRM);
    END IF;
    Log_Table_Class_Error(
      p_tab_name      => p_tab_name,
      p_tab_class_cd  => p_tab_class_cd,
      p_msg_name => 'FEM_RSM_UNEXPECTED_ERROR',
      p_token1 => 'ROUTINE_NAME',
      p_value1 => C_MODULE);

    x_passed_validation := c_false;

END Validate_Column_Req;

/***************************************************************************
 ***************************************************************************
 *                                                                         *
 *                  ==================================                     *
 *                  Procedure: Validate Processing Key                     *
 *                  ==================================                     *
 *                                                                         *
 ***************************************************************************
 ***************************************************************************

 This procedure validates that the set of processing key columns
 (as stored in the FEM_TAB_COLUMN_PROP metadata table)
 match the set of unique index columns designated as the processing key index.

 **************************************************************************/

PROCEDURE Validate_Processing_Key_Idx (
p_tab_name          IN         VARCHAR2,
p_tab_class_cd      IN         VARCHAR2,
p_tab_owner         IN         VARCHAR2,
p_db_tab_name       IN         VARCHAR2,
x_passed_validation OUT NOCOPY VARCHAR2
)
IS
  C_MODULE            CONSTANT FND_LOG_MESSAGES.module%TYPE :=
     'fem.plsql.fem_admin_util_pkg.validate_processing_key_idx';

  v_count      NUMBER;
  v_idx_name   FEM_TABLES_B.proc_key_index_name%TYPE;
  v_idx_owner  FEM_TABLES_B.proc_key_index_owner%TYPE;
  v_matched    VARCHAR2(1);

  e_no_idx                EXCEPTION;
  e_exit_successfully     EXCEPTION;
  e_mismatch_idx          EXCEPTION;
BEGIN

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;

  v_matched := c_false;

  -- First make sure the index actually exists
  BEGIN
    SELECT proc_key_index_name, proc_key_index_owner
    INTO v_idx_name, v_idx_owner
    FROM fem_tables_b
    WHERE table_name = p_tab_name;

    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'Processing key index = '||v_idx_owner||'.'||v_idx_name);
    END IF;

    IF v_idx_name IS NULL AND v_idx_owner IS NULL THEN
      SELECT count(*)
      INTO v_count
      FROM fem_tab_column_prop
      WHERE table_name = p_tab_name
        AND column_property_code = 'PROCESSING_KEY';

      -- Only error if no index is specified but proc key metadata is populated
      IF v_count = 0 THEN
        RAISE e_exit_successfully;
      ELSE
        RAISE e_mismatch_idx;
      END IF;
    END IF; -- v_idx_name IS NULL AND ...
  END;

  -- If PROC_KEY_INDEX_OWNER is null, default index owner to table owner
  IF v_idx_owner IS NULL THEN
    v_idx_owner := p_tab_owner;
  END IF;

  -- Make sure index exists
  SELECT count(*)
  INTO v_count
  FROM all_indexes
  WHERE index_name= v_idx_name
  AND owner = v_idx_owner
  AND table_name = p_db_tab_name
  AND table_owner = p_tab_owner
  AND uniqueness = 'UNIQUE';

  IF v_count = 0 THEN
    RAISE e_no_idx;
  END IF;

  -- Then make sure the Proc Key metadata matches with the index
  SELECT count(*)
  INTO v_count
  FROM all_ind_columns
  WHERE index_owner = v_idx_owner
    AND index_name = v_idx_name
    AND table_owner = p_tab_owner
    AND table_name = p_db_tab_name
    AND column_name NOT IN
     (SELECT column_name
      FROM fem_tab_column_prop
      WHERE table_name = p_tab_name
        AND column_property_code = 'PROCESSING_KEY');

  IF v_count = 0 THEN
    v_matched := c_true;
  END IF;

  IF v_matched = c_true THEN
    SELECT count(*)
    INTO v_count
    FROM fem_tab_column_prop
    WHERE table_name = p_tab_name
      AND column_property_code = 'PROCESSING_KEY'
      AND column_name NOT IN
           (SELECT column_name
            FROM all_ind_columns
            WHERE index_owner = v_idx_owner
            AND index_name = v_idx_name
            AND table_owner = p_tab_owner
            AND table_name = p_db_tab_name);

    IF v_count > 0 THEN
      v_matched := c_false;
    END IF;
  END IF; -- v_matched = c_true

  IF v_matched = c_false THEN
    RAISE e_mismatch_idx;
  END IF;

  x_passed_validation := v_matched;

  IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'x_passed_validation = '||x_passed_validation);
  END IF;
  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;
EXCEPTION
  WHEN e_exit_successfully THEN
    x_passed_validation := c_true;

  WHEN e_mismatch_idx THEN
    Log_Table_Class_Error(
      p_tab_name      => p_tab_name,
      p_tab_class_cd  => p_tab_class_cd,
      p_msg_name => 'FEM_ADM_NO_UI_PK_MATCH_ERR',
      p_token1 => 'INDEX_NAME',
      p_value1 => v_idx_owner||'.'||v_idx_name);

    x_passed_validation := c_false;

  WHEN e_no_idx THEN
    Log_Table_Class_Error(
      p_tab_name      => p_tab_name,
      p_tab_class_cd  => p_tab_class_cd,
      p_msg_name => 'FEM_TABCLASS_PK_NO_INDEX',
      p_token1 => 'INDEX_NAME',
      p_value1 => v_idx_owner||'.'||v_idx_name);

    x_passed_validation := c_false;

  WHEN others THEN
    IF FND_LOG.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_exception,
        p_module   => C_MODULE,
        p_msg_text => 'Validate_Column_Req failed unexpectedly: '||SQLERRM);
    END IF;
    Log_Table_Class_Error(
      p_tab_name      => p_tab_name,
      p_tab_class_cd  => p_tab_class_cd,
      p_msg_name => 'FEM_RSM_UNEXPECTED_ERROR',
      p_token1 => 'ROUTINE_NAME',
      p_value1 => C_MODULE);

    x_passed_validation := c_false;

END Validate_Processing_Key_Idx;


/***************************************************************************
 ***************************************************************************
 *                                                                         *
 *                  =============================                          *
 *                  Procedure: Validate OGL DimCol                         *
 *                  =============================                          *
 *                                                                         *
 ***************************************************************************
 ***************************************************************************

 This procedure validates that all of the dimension columns on FEM_BALANCES
 that the OGL Integration uses have been assigned to a VSR dimension.

 **************************************************************************/

PROCEDURE Validate_OGL_Dimcol (
p_tab_name           IN         VARCHAR2,
p_tab_class_cd       IN         VARCHAR2,
x_passed_validation  OUT NOCOPY VARCHAR2) IS
  C_MODULE            CONSTANT FND_LOG_MESSAGES.module%TYPE :=
     'fem.plsql.fem_admin_util_pkg.validate_ogl_dimcol';

  CURSOR c_dimcol (p_name VARCHAR2) IS
    SELECT column_name, dimension_id
    FROM   fem_tab_columns_b
    WHERE  table_name = p_name
      AND  fem_data_type_code = 'DIMENSION'
      AND  column_name IN ('COMPANY_COST_CENTER_ORG_ID'
      ,'NATURAL_ACCOUNT_ID'
      ,'LINE_ITEM_ID'
      ,'PRODUCT_ID'
      ,'CHANNEL_ID'
      ,'PROJECT_ID'
      ,'CUSTOMER_ID'
      ,'ENTITY_ID'
      ,'INTERCOMPANY_ID'
      ,'TASK_ID'
      ,'USER_DIM1_ID'
      ,'USER_DIM2_ID'
      ,'USER_DIM3_ID'
      ,'USER_DIM4_ID'
      ,'USER_DIM5_ID'
      ,'USER_DIM6_ID'
      ,'USER_DIM7_ID'
      ,'USER_DIM8_ID'
      ,'USER_DIM9_ID'
      ,'USER_DIM10_ID')
      ORDER BY column_name;


  v_count            NUMBER;
  v_col_list         VARCHAR2(4000);
  v_col_count        NUMBER;
  v_not_vsr_flag     VARCHAR2(1); -- a 'Y' designates that a non-VSR dim was found
  v_passed_valid     VARCHAR2(1);
  v_return_status    VARCHAR2(1);
  v_matched          VARCHAR2(1);
  v_msg_data         VARCHAR2(2000);

BEGIN
  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;

  -- Init variables
  v_passed_valid := c_true;


  v_col_list := null;
  v_col_count := 1;
  v_not_vsr_flag := 'N';

  -- Verify that the column maps to a value set dimension
  -- with the caveat, that COMPANY and COST_CENTER dimensions
  -- are not valid targets (OGL integration requires that
  -- these are not mapped directly on FEM_BALANCES because
  -- they are attributes of the Company Cost Center Org
  -- dimension
  FOR col IN c_dimcol (p_tab_name) LOOP
     SELECT count(*)
     INTO v_count
     FROM fem_xdim_dimensions_vl
     WHERE dimension_id = col.dimension_id
     AND value_set_required_flag = 'Y'
     AND dimension_varchar_label not in ('COMPANY','COST_CENTER');


     IF v_count = 0 THEN
        v_not_vsr_flag := 'Y';
        IF v_col_count = 1 THEN
           v_col_list := col.column_name;
        ELSE
           v_col_list := v_col_list||', '||col.column_name;
        END IF;

     END IF;

  v_col_count := v_col_count + 1;
  END LOOP;

  IF v_not_vsr_flag = 'Y' THEN

     Log_Table_Class_Error(
         p_tab_name      => p_tab_name,
         p_tab_class_cd  => p_tab_class_cd,
         p_msg_name      => 'FEM_TABCLASS_OGL_BAD_DIMCOL',
         p_token1        => 'COL',
         p_value1        => v_col_list);

      RAISE e_error;
   END IF;


  x_passed_validation := v_passed_valid;

  IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'x_passed_validation = '||x_passed_validation);
  END IF;
  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;
EXCEPTION
  WHEN e_error THEN
    x_passed_validation := c_false;

  WHEN others THEN
    IF FND_LOG.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_exception,
        p_module   => C_MODULE,
        p_msg_text => 'Validate_OGL_Dimcol failed unexpectedly: '||SQLERRM);
    END IF;
    Log_Table_Class_Error(
      p_tab_name      => p_tab_name,
      p_tab_class_cd  => p_tab_class_cd,
      p_msg_name => 'FEM_RSM_UNEXPECTED_ERROR',
      p_token1 => 'ROUTINE_NAME',
      p_value1 => C_MODULE);

    x_passed_validation := c_false;

END Validate_OGL_Dimcol;



/***************************************************************************
 ***************************************************************************
 *                                                                         *
 *                  =============================                          *
 *                  Procedure: Validate Tab Class                          *
 *                  =============================                          *
 *                                                                         *
 ***************************************************************************
 ***************************************************************************

 This procedure is a wrapper that calls other table validation APIs in
 this package.

 History:
   09/05/06 Rob Flippo   Bug#5500573 Added validate_ogl_dimcol to the procedure
                         list

 **************************************************************************/

PROCEDURE Validate_Tab_Class (
p_tab_name          IN         VARCHAR2,
p_tab_class_cd      IN         VARCHAR2,
x_passed_validation OUT NOCOPY VARCHAR2
)
IS
  C_MODULE            CONSTANT FND_LOG_MESSAGES.module%TYPE :=
     'fem.plsql.fem_admin_util_pkg.validate_tab_class';

  CURSOR c_class_prop (p_class VARCHAR2) IS
    SELECT p.table_property_code, p.property_type, p.column_req_type
    FROM fem_table_class_prop c, fem_table_properties p
    WHERE c.table_classification_code = p_class
      AND c.table_property_code = p.table_property_code
      AND p.property_type <> 'OTHER';

  CURSOR c_procedure (p_class VARCHAR2) IS
    SELECT DISTINCT S.stored_procedure_name
    FROM   fem_table_class_prop C,
           fem_table_prop_stp S
    WHERE  C.table_classification_code = p_class
    AND    C.table_property_code = S.table_property_code;

  v_return_status      VARCHAR2(1);
  v_passed_valid_out   VARCHAR2(1);
  v_passed             VARCHAR2(1);
  v_msg_count          NUMBER;
  v_msg_data           VARCHAR2(2000);

  v_db_tab_name        ALL_TABLES.table_name%TYPE;
  v_tab_owner       ALL_TABLES.owner%TYPE;
  v_procedure          FEM_TABLE_PROP_STP.stored_procedure_name%TYPE;
BEGIN
  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;

  -- Init var
  v_passed_valid_out := c_true;
  v_passed := c_true;

  -- Get table name and owner
  FEM_Database_Util_Pkg.Get_Table_Owner (
    x_return_status => v_return_status,
    x_msg_count => v_msg_count,
    x_msg_data => v_msg_data,
    p_syn_name => p_tab_name,
    x_tab_name => v_db_tab_name,
    x_tab_owner => v_tab_owner);

  IF v_return_status <> c_success THEN
    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'Call to FEM_Database_Util_Pkg.Get_Table_Owner failed');
    END IF;
    RAISE e_unexp;
  END IF;

  -- Check if column requirements are met
  Validate_Column_Req (
    p_tab_name          => p_tab_name,
    p_tab_class_cd      => p_tab_class_cd,
    p_tab_owner         => v_tab_owner,
    p_db_tab_name       => v_db_tab_name,
    x_passed_validation => v_passed_valid_out);

  IF v_passed_valid_out = c_false THEN
    v_passed := c_false;
  END IF;

  -- Make sure the processing key columns matches up with a unique index
  /* Validate_Processing_Key_Idx (
    p_tab_name          => p_tab_name,
    p_tab_class_cd      => p_tab_class_cd,
    p_tab_owner         => v_tab_owner,
    p_db_tab_name       => v_db_tab_name,
    x_passed_validation => v_passed_valid_out);
  */
  IF v_passed_valid_out = c_false THEN
    v_passed := c_false;
  END IF;

  FOR p IN c_class_prop (p_tab_class_cd) LOOP
    Validate_Prop_Col_Req (
      p_tab_name          => p_tab_name,
      p_tab_class_cd      => p_tab_class_cd,
      p_tab_prop_cd       => p.table_property_code,
      p_prop_type         => p.property_type,
      p_col_req_type      => p.column_req_type,
      x_passed_validation => v_passed_valid_out);

    IF v_passed_valid_out = c_false THEN
      v_passed := c_false;
    END IF;
  END LOOP;

  -- Run other specified procedures for this table class
  FOR r IN c_procedure (p_tab_class_cd) LOOP
    v_procedure := r.stored_procedure_name;

    IF (v_procedure = 'FEM_ADMIN_UTIL_PKG.VALIDATE_TABLE_NAME_RESTRICT') THEN
      Validate_Table_Name_Restrict (
        p_tab_name           => p_tab_name,
        p_tab_class_cd       => p_tab_class_cd,
        x_passed_validation  => v_passed_valid_out);
    ELSIF (v_procedure = 'FEM_ADMIN_UTIL_PKG.VALIDATE_EDITABLE') THEN
      Validate_Editable (
        p_tab_name           => p_tab_name,
        p_tab_class_cd       => p_tab_class_cd,
        x_passed_validation  => v_passed_valid_out);
    ELSIF (v_procedure = 'FEM_ADMIN_UTIL_PKG.VALIDATE_DATA_LOADER') THEN
      Validate_Data_Loader (
        p_tab_name           => p_tab_name,
        p_tab_class_cd       => p_tab_class_cd,
        p_tab_owner          => v_tab_owner,
        p_db_tab_name        => v_db_tab_name,
        x_passed_validation  => v_passed_valid_out);
    ELSIF (v_procedure = 'FEM_ADMIN_UTIL_PKG.VALIDATE_PK_COLS_NOT_NULL') THEN
      Validate_PK_Cols_Not_Null (
        p_tab_name           => p_tab_name,
        p_tab_class_cd       => p_tab_class_cd,
        p_tab_owner          => v_tab_owner,
        p_db_tab_name        => v_db_tab_name,
        x_passed_validation  => v_passed_valid_out);
    ELSIF (v_procedure = 'FEM_ADMIN_UTIL_PKG.VALIDATE_OGL_DIMCOL') THEN
      Validate_OGL_Dimcol (
        p_tab_name           => p_tab_name,
        p_tab_class_cd       => p_tab_class_cd,
        x_passed_validation  => v_passed_valid_out);
    ELSIF (v_procedure = 'FEM_ADMIN_UTIL_PKG.VALIDATE_PROCESSING_KEY_IDX') THEN
      Validate_Processing_Key_Idx (
        p_tab_name          => p_tab_name,
        p_tab_class_cd      => p_tab_class_cd,
        p_tab_owner         => v_tab_owner,
        p_db_tab_name       => v_db_tab_name,
        x_passed_validation => v_passed_valid_out);
    ELSE
      IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FEM_ENGINES_PKG.TECH_MESSAGE(
          p_severity => FND_LOG.level_statement,
          p_module   => C_MODULE,
          p_msg_text => 'No such procedure: '||v_procedure);
      END IF;
      RAISE e_unexp;
    END IF;

    IF v_passed_valid_out = c_false THEN
      v_passed := c_false;
    END IF;
  END LOOP;

  x_passed_validation := v_passed;

EXCEPTION
  WHEN others THEN
    IF FND_LOG.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_exception,
        p_module   => C_MODULE,
        p_msg_text => 'Validate_Tab_Class failed unexpectedly: '||SQLERRM);
    END IF;
    Log_Table_Class_Error(
      p_tab_name      => p_tab_name,
      p_tab_class_cd  => p_tab_class_cd,
      p_msg_name => 'FEM_RSM_UNEXPECTED_ERROR',
      p_token1 => 'ROUTINE_NAME',
      p_value1 => C_MODULE);

    x_passed_validation := c_false;

END Validate_Tab_Class;


PROCEDURE Validate_Tab_Class_Assignmt (
p_api_version       IN         NUMBER     DEFAULT c_api_version,
p_init_msg_list     IN         VARCHAR2   DEFAULT c_false,
p_commit            IN         VARCHAR2   DEFAULT c_false,
p_encoded           IN         VARCHAR2   DEFAULT c_true,
x_return_status     OUT NOCOPY VARCHAR2,
x_msg_count         OUT NOCOPY NUMBER,
x_msg_data          OUT NOCOPY VARCHAR2,
p_tab_name          IN         VARCHAR2
)
IS
  C_MODULE            CONSTANT FND_LOG_MESSAGES.module%TYPE :=
     'fem.plsql.fem_admin_util_pkg.validate_tab_class_assignmt';
  C_API_NAME      CONSTANT VARCHAR2(30)  := 'Validate_Tab_Class_Assignmt';

  v_passed_validation  VARCHAR2(1);
  v_tab_class_cd   VARCHAR2(30);

  CURSOR c_table_classes IS
    SELECT lookup_code
    FROM fnd_lookup_values_vl
    WHERE lookup_type = 'FEM_TABLE_CLASSIFICATION_DSC';


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

  -- Clean out the log tables before each run
  Trunc_Table_Class_Log_Tables(p_tab_name);

  FOR table_classes IN c_table_classes LOOP
    Validate_Tab_Class (
      p_tab_name          => p_tab_name,
      p_tab_class_cd      => table_classes.lookup_code,
      x_passed_validation => v_passed_validation);

    Log_Table_Class_Status(
      p_tab_name          => p_tab_name,
      p_tab_class_cd      => table_classes.lookup_code,
      p_passed_validation => v_passed_validation);
  END LOOP;

  IF (p_commit = c_true) THEN
    COMMIT;
  END IF;

  -- In case any messages are generated
  FND_MSG_PUB.Count_And_Get(p_encoded => p_encoded,
                            p_count => x_msg_count,
                            p_data => x_msg_data);

  x_return_status := c_success;

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;

EXCEPTION
  WHEN others THEN
    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'Unexpected error: '||SQLERRM);
    END IF;
    IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_procedure,
        p_module   => C_MODULE,
        p_msg_text => 'End Procedure');
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded => p_encoded,
                              p_count => x_msg_count,
                              p_data => x_msg_data);

    x_return_status := c_unexp;

END Validate_Tab_Class_Assignmt;


/**************************************************************************/

/***************************************************************************
 ***************************************************************************
 *                                                                         *
 *                  =============================                          *
 *                  Procedure: Validate_obj_Class_Assignmt                 *
 *                  =============================                          *
 *                                                                         *
 ***************************************************************************
 ***************************************************************************

 This procedure calls the  Validate_Tab_Class_Assignmt if the object type is
 a table loads the classifications for views.

 **************************************************************************/

PROCEDURE Validate_obj_Class_Assignmt (
p_api_version       IN         NUMBER     DEFAULT c_api_version,
p_init_msg_list     IN         VARCHAR2   DEFAULT c_false,
p_commit            IN         VARCHAR2   DEFAULT c_false,
p_encoded           IN         VARCHAR2   DEFAULT c_true,
x_return_status     OUT NOCOPY VARCHAR2,
x_msg_count         OUT NOCOPY NUMBER,
x_msg_data          OUT NOCOPY VARCHAR2,
p_obj_name          IN         VARCHAR2,
p_obj_type          IN         VARCHAR2
)
IS
  C_MODULE            CONSTANT FND_LOG_MESSAGES.module%TYPE :=
     'fem.plsql.fem_admin_util_pkg.validate_obj_class_assignmt';
  C_API_NAME      CONSTANT VARCHAR2(30)  := 'Validate_obj_Class_Assignmt';

  v_passed_validation  VARCHAR2(1);
  v_tab_class_cd   VARCHAR2(30);

  /* Select only those classifications for which properties do not need validation
   EXCEPT(
	'FEM_ADMIN_UTIL_PKG.VALIDATE_TABLE_NAME_RESTRICT',
	'FEM_ADMIN_UTIL_PKG.VALIDATE_DATA_LOADER',
	'FEM_ADMIN_UTIL_PKG.VALIDATE_EDITABLE')
  */

  CURSOR c_table_classes IS
	SELECT lookup_code
    FROM  fnd_lookup_values_vl flv
    WHERE flv.lookup_type = 'FEM_TABLE_CLASSIFICATION_DSC'
    AND not exists(
      select ftcp.table_classification_code
	  from  fem_table_class_prop ftcp,
		    fem_table_prop_stp   ftps
	  where	ftcp.table_classification_code = flv.lookup_code
	  and   ftcp.table_property_code = ftps.table_property_code
	  and   ftps.stored_procedure_name in(
          	'FEM_ADMIN_UTIL_PKG.VALIDATE_TABLE_NAME_RESTRICT',
         	'FEM_ADMIN_UTIL_PKG.VALIDATE_DATA_LOADER',
        	'FEM_ADMIN_UTIL_PKG.VALIDATE_EDITABLE')
			);

BEGIN

  IF p_obj_type = 'FEM_TABLE' THEN

    Validate_Tab_Class_Assignmt (
             x_return_status=> x_return_status,
             x_msg_count    => x_msg_count,
             x_msg_data     => x_msg_data,
             p_tab_name     => p_obj_name
             );

  ELSE IF  p_obj_type = 'FEM_VIEW' THEN

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

  -- Clean out the log tables before each run
  Trunc_Table_Class_Log_Tables(p_obj_name);

  FOR table_classes IN c_table_classes LOOP

	Validate_View_Class (
      p_view_name         => p_obj_name,
      p_tab_class_cd      => table_classes.lookup_code,
      x_passed_validation => v_passed_validation);

    Log_Table_Class_Status(
      p_tab_name          => p_obj_name,
      p_tab_class_cd      => table_classes.lookup_code,
      p_passed_validation => v_passed_validation);

  END LOOP;


  IF (p_commit = c_true) THEN
    COMMIT;
  END IF;

  -- In case any messages are generated
  FND_MSG_PUB.Count_And_Get(p_encoded => p_encoded,
                            p_count => x_msg_count,
                            p_data => x_msg_data);

  x_return_status := c_success;

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;

 END IF;

 END IF;
EXCEPTION
  WHEN others THEN
    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'Unexpected error: '||SQLERRM);
    END IF;
    IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_procedure,
        p_module   => C_MODULE,
        p_msg_text => 'End Procedure');
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded => p_encoded,
                              p_count => x_msg_count,
                              p_data => x_msg_data);

    x_return_status := c_unexp;

END Validate_obj_Class_Assignmt;

/*============================================================================+
 | PROCEDURE
 |   Get_Table_Owner_for_View
 |
 | DESCRIPTION
 |   This Procedure returns the underlying base table and owner for passed view name
 |
 | SCOPE - PUBLIC
 +============================================================================*/

PROCEDURE Get_Table_Owner_for_View (
            p_api_version     IN         NUMBER     DEFAULT c_api_version,
            p_init_msg_list   IN         VARCHAR2   DEFAULT c_false,
            p_commit          IN         VARCHAR2   DEFAULT c_false,
            p_encoded         IN         VARCHAR2   DEFAULT c_true,
            x_return_status   OUT NOCOPY VARCHAR2,
            x_msg_count       OUT NOCOPY NUMBER,
            x_msg_data        OUT NOCOPY VARCHAR2,
            p_view_name       IN         VARCHAR2,
            x_tab_name        OUT NOCOPY VARCHAR2,
            x_tab_owner       OUT NOCOPY VARCHAR2 ) IS
-- =========================================================================
-- Returns the underlying table name and table owner for a specified user defined view for the selected index.
-- =========================================================================

C_MODULE            CONSTANT FND_LOG_MESSAGES.module%TYPE :=
     'fem.plsql.fem_admin_util_pkg.Get_Table_Owner_for_View';
BEGIN

   x_return_status := c_success;

   ---------------------------------
   -- Get underlying table name and table owner
   ---------------------------------
   --need to think abt this
    SELECT tiig.table_name, tig.owner
	INTO   x_tab_name,x_tab_owner
    FROM   fem_tab_indx_info_gt tiig,
	       fem_tables_b ftb,
		   fem_tab_info_gt tig
    WHERE  ftb.table_name = p_view_name
    AND    ftb.PROC_KEY_INDEX_NAME = tiig.INDEX_NAME
    AND    tig.table_name = tiig.table_name
	AND    tig.owner is NOT NULL
    AND ROWNUM = 1;

EXCEPTION

   WHEN no_data_found THEN

      x_tab_owner:= NULL;
	  x_tab_name:= NULL;

   WHEN others THEN

     FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Unexpected Exception: '||SQLERRM);

	  x_return_status := c_error;

END Get_Table_Owner_for_view;

/*============================================================================+
 | PROCEDURE
 |   Get_Index_Owner_for_View
 |
 | DESCRIPTION
 |   This Procedure returns the underlying base table and Index owner for passed
 |   view name and Index Name
 |
 | SCOPE - PUBLIC
 +============================================================================*/

PROCEDURE Get_Index_Owner_for_View (
            p_api_version     IN         NUMBER     DEFAULT c_api_version,
            p_init_msg_list   IN         VARCHAR2   DEFAULT c_false,
            p_commit          IN         VARCHAR2   DEFAULT c_false,
            p_encoded         IN         VARCHAR2   DEFAULT c_true,
            x_return_status   OUT NOCOPY VARCHAR2,
            x_msg_count       OUT NOCOPY NUMBER,
            x_msg_data        OUT NOCOPY VARCHAR2,
            p_view_name       IN         VARCHAR2,
			p_index_name      IN         VARCHAR2,
            x_tab_name        OUT NOCOPY VARCHAR2,
            x_tab_owner       OUT NOCOPY VARCHAR2 ) IS
-- =========================================================================
-- Returns the underlying table name and Index owner for a specified user defined view and the selected index.
-- =========================================================================

C_MODULE            CONSTANT FND_LOG_MESSAGES.module%TYPE :=
     'fem.plsql.fem_admin_util_pkg.Get_Index_Owner_for_View';


BEGIN

   x_return_status := c_success;

   ---------------------------------
   -- Get underlying table name and table owner
   ---------------------------------

	SELECT tiig.table_name, tig.owner
	INTO   x_tab_name,x_tab_owner
    FROM   fem_tab_indx_info_gt tiig,
		    fem_tab_info_gt tig
    WHERE  tig.table_name = tiig.table_name
    AND    tiig.INDEX_NAME = p_index_name
	AND    tig.owner is NOT NULL
    AND ROWNUM = 1;

EXCEPTION

   WHEN no_data_found THEN

      x_tab_owner:= NULL;
	  x_tab_name:= NULL;

   WHEN others THEN
     FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Unexpected Exception: '||SQLERRM);

      x_return_status := c_error;

END Get_Index_Owner_for_view;


/***************************************************************************
 ***************************************************************************
 *                                                                         *
 *                  =============================                          *
 *                  Procedure: Validate View Class                          *
 *                  =============================                          *
 *                                                                         *
 ***************************************************************************
 ***************************************************************************

 This procedure is a wrapper that calls other View validation APIs in
 this package.

 **************************************************************************/

PROCEDURE Validate_View_Class (
p_view_name         IN         VARCHAR2,
p_tab_class_cd      IN         VARCHAR2,
x_passed_validation OUT NOCOPY VARCHAR2
)
IS
  C_MODULE            CONSTANT FND_LOG_MESSAGES.module%TYPE :=
     'fem.plsql.fem_admin_util_pkg.validate_view_class';

  CURSOR c_class_prop (p_class VARCHAR2) IS
    SELECT p.table_property_code, p.property_type, p.column_req_type
    FROM fem_table_class_prop c, fem_table_properties p
    WHERE c.table_classification_code = p_class
      AND c.table_property_code = p.table_property_code
      AND p.property_type <> 'OTHER';

  CURSOR c_procedure (p_class VARCHAR2) IS
    SELECT DISTINCT S.stored_procedure_name
    FROM   fem_table_class_prop C,
           fem_table_prop_stp S
    WHERE  C.table_classification_code = p_class
    AND    C.table_property_code = S.table_property_code;

  v_return_status      VARCHAR2(1);
  v_passed_valid_out   VARCHAR2(1);
  v_passed             VARCHAR2(1);
  v_msg_count          NUMBER;
  v_msg_data           VARCHAR2(2000);

  v_db_tab_name        VARCHAR2(30);
  v_tab_owner          VARCHAR2(30);
  v_procedure          FEM_TABLE_PROP_STP.stored_procedure_name%TYPE;
  l_apps               VARCHAR2(30):=USER;

BEGIN
  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;

  -- Init var
  v_passed_valid_out := c_true;
  v_passed := c_true;

  -----------------------------
  -- get the owner for the underlying base table of processing key.
  -- Get table name and owner
  ----------------------------

  Get_Table_Owner_for_View (
    x_return_status => v_return_status,
    x_msg_count => v_msg_count,
    x_msg_data =>  v_msg_data,
    p_view_name => p_view_name,
    x_tab_name =>  v_db_tab_name,
    x_tab_owner => v_tab_owner);

  IF v_return_status <> c_success THEN
    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'Call to Get_Table_Owner_for_view failed');
    END IF;
    RAISE e_unexp;
  END IF;

   -- Check if column requirements are met
  Validate_Column_Req (
    p_tab_name          => p_view_name,
    p_tab_class_cd      => p_tab_class_cd,
    p_tab_owner         => l_apps,-- pass owner as 'APPS' because we will check for view columns and pass
    p_db_tab_name       => p_view_name,--p_db_tab_name = view_name because it will be mapped to all_tab_columns
    x_passed_validation => v_passed_valid_out);

  IF v_passed_valid_out = c_false THEN
    v_passed := c_false;
  END IF;

  -- Make sure the processing key columns matches up with a unique index
  -- This validation is done in the last
 /* Validate_Processing_Key_Idx (
    p_tab_name          => p_view_name,
    p_tab_class_cd      => p_tab_class_cd,
    p_tab_owner         => v_tab_owner,
    p_db_tab_name       => v_db_tab_name,
    x_passed_validation => v_passed_valid_out);
 */

  IF v_passed_valid_out = c_false THEN
    v_passed := c_false;
  END IF;

  FOR p IN c_class_prop (p_tab_class_cd) LOOP
    Validate_Prop_Col_Req (
      p_tab_name          => p_view_name,
      p_tab_class_cd      => p_tab_class_cd,
      p_tab_prop_cd       => p.table_property_code,
      p_prop_type         => p.property_type,
      p_col_req_type      => p.column_req_type,
      x_passed_validation => v_passed_valid_out);

    IF v_passed_valid_out = c_false THEN
      v_passed := c_false;
    END IF;
  END LOOP;

  -- Run other specified procedures for this table class
  FOR r IN c_procedure (p_tab_class_cd) LOOP
    v_procedure := r.stored_procedure_name;

    IF (v_procedure = 'FEM_ADMIN_UTIL_PKG.VALIDATE_PK_COLS_NOT_NULL') THEN
      Validate_PK_Cols_Not_Null (
        p_tab_name           => p_view_name,
        p_tab_class_cd       => p_tab_class_cd,
        p_tab_owner          => l_apps,
        p_db_tab_name        => p_view_name,
        x_passed_validation  => v_passed_valid_out);

	ELSIF (v_procedure = 'FEM_ADMIN_UTIL_PKG.VALIDATE_PROCESSING_KEY_IDX') THEN
      Validate_Processing_Key_Idx (
        p_tab_name          => p_view_name,
        p_tab_class_cd      => p_tab_class_cd,
        p_tab_owner         => v_tab_owner,
        p_db_tab_name       => v_db_tab_name,
        x_passed_validation => v_passed_valid_out);

    ELSIF(FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FEM_ENGINES_PKG.TECH_MESSAGE(
          p_severity => FND_LOG.level_statement,
          p_module   => C_MODULE,
          p_msg_text => 'No such procedure: '||v_procedure);

		RAISE e_unexp;


	END IF;

    IF v_passed_valid_out = c_false THEN
      v_passed := c_false;
    END IF;
  END LOOP;

  x_passed_validation := v_passed;

EXCEPTION
  WHEN others THEN
    IF FND_LOG.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_exception,
        p_module   => C_MODULE,
        p_msg_text => 'Validate_Tab_Class failed unexpectedly: '||SQLERRM);
    END IF;
    Log_Table_Class_Error(
      p_tab_name      => p_view_name,
      p_tab_class_cd  => p_tab_class_cd,
      p_msg_name => 'FEM_RSM_UNEXPECTED_ERROR',
      p_token1 => 'ROUTINE_NAME',
      p_value1 => C_MODULE);

    x_passed_validation := c_false;

END Validate_view_Class;


/**************************************************************************/


END FEM_Admin_Util_Pkg;

/
