--------------------------------------------------------
--  DDL for Package Body FEM_INTG_DIM_RULE_ENG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_INTG_DIM_RULE_ENG_PKG" AS
/* $Header: fem_intg_dim_eng.plb 120.10.12010000.4 2009/09/10 04:09:43 amantri ship $ */

  pc_log_level_statement  CONSTANT NUMBER := FND_LOG.level_statement;
  pc_log_level_procedure  CONSTANT NUMBER := FND_LOG.level_procedure;
  pc_log_level_event      CONSTANT NUMBER := FND_LOG.level_event;
  pc_log_level_exception  CONSTANT NUMBER := FND_LOG.level_exception;
  pc_log_level_error      CONSTANT NUMBER := FND_LOG.level_error;
  pc_log_level_unexpected CONSTANT NUMBER := FND_LOG.level_unexpected;
  pc_module_name          CONSTANT VARCHAR2(100) := 'fem.plsql.fem_intg_dim_rule_eng_pkg';
  pv_crlf                 CONSTANT VARCHAR2(1) := '';
  --bugfix 8780516
  pc_sleep_second CONSTANT NUMBER := 10;
  -- end bugfix

  pv_progress varchar2(100) ;

  PROCEDURE create_map_placeholder_records(
    p_coa_id IN NUMBER,
    p_gvsc_id IN NUMBER,
    p_max_ccid_in_map_table IN NUMBER,
    p_max_ccid_in_glccid_table IN NUMBER,
    x_rows_processed OUT NOCOPY NUMBER
  );

  PROCEDURE print_pkg_variable_values;
  PROCEDURE register_fem_value_set (p_fem_value_set_id   IN            NUMBER
                                   ,p_regiser_type       IN            VARCHAR2
                                   ,p_fnd_vs_id          IN            NUMBER
                                   ,p_dim_id             IN            NUMBER
                                   ,x_status             IN OUT NOCOPY NUMBER);


  PROCEDURE Init IS
    v_object_id NUMBER;
    c_func_name  CONSTANT         VARCHAR2(30) := '.init';
    FEMOGL_com_dim_missing        EXCEPTION;
    FEMOGL_cc_dim_missing         EXCEPTION;
    FEMOGL_cctr_org_dim_missing   EXCEPTION;

    --
    -- Find FlexField Qualified Segment number
    --
    -- Note that a matched segment column name is compared with
    -- a list of mapping column names in FEM_INTG_DIM_RULE_DEFS
    -- and a matched index number of the list will be returned.
    --
    CURSOR FlexQualifiedSegmentNum(
             c_qualifier VARCHAR2,
             c_dimension_id NUMBER
           ) IS
      SELECT
        CASE
          WHEN D.APPLICATION_COLUMN_NAME1 =
               A.APPLICATION_COLUMN_NAME THEN 1
          WHEN D.APPLICATION_COLUMN_NAME2 =
               A.APPLICATION_COLUMN_NAME THEN 2
          WHEN D.APPLICATION_COLUMN_NAME3 =
               A.APPLICATION_COLUMN_NAME THEN 3
          WHEN D.APPLICATION_COLUMN_NAME4 =
               A.APPLICATION_COLUMN_NAME THEN 4
          WHEN D.APPLICATION_COLUMN_NAME5 =
               A.APPLICATION_COLUMN_NAME THEN 5
          ELSE NULL
        END SEGMENT_NUMBER
      FROM
        FEM_INTG_DIM_RULES R,
        FEM_OBJECT_DEFINITION_B OD,
        FEM_INTG_DIM_RULE_DEFS D,
        FND_SEGMENT_ATTRIBUTE_VALUES A
      WHERE
        R.CHART_OF_ACCOUNTS_ID = pv_coa_id AND
        R.DIMENSION_ID = c_dimension_id AND
        OD.OBJECT_ID = R.DIM_RULE_OBJ_ID AND
        D.DIM_RULE_OBJ_DEF_ID = OD.OBJECT_DEFINITION_ID AND
        A.APPLICATION_ID = 101 AND
        A.ID_FLEX_CODE = 'GL#' AND
        A.ID_FLEX_NUM = pv_coa_id AND
        A.SEGMENT_ATTRIBUTE_TYPE = c_qualifier AND
        A.ATTRIBUTE_VALUE = 'Y';

  BEGIN
    pv_progress := 'Start';
    FEM_ENGINES_PKG.Tech_Message
      ( p_severity => pc_log_level_procedure
       ,p_module   => pc_module_name||c_func_name
       ,p_app_name => 'FEM'
       ,p_msg_name => 'FEM_GL_POST_201'
       ,p_token1   => 'FUNC_NAME'
       ,p_value1   => pc_module_name||c_func_name
       ,p_token2   => 'TIME'
       ,p_value2   =>  TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

    pv_progress := 'Fetch dim_id, varchar lable, coa_id , coa name';

    SELECT R.DIMENSION_ID
          ,DECODE(R.DIMENSION_ID,
                  0, 'INTERCOMPANY',
                  B.DIMENSION_VARCHAR_LABEL)
          ,R.CHART_OF_ACCOUNTS_ID
          ,F.ID_FLEX_STRUCTURE_CODE
    INTO  pv_dim_id
         ,pv_dim_varchar_label
         ,pv_coa_id
         ,pv_coa_name
    FROM  FEM_INTG_DIM_RULES R
         ,FND_ID_FLEX_STRUCTURES F
         ,FEM_DIMENSIONS_B B
    WHERE R.DIM_RULE_OBJ_ID  = pv_dim_rule_obj_id
      AND F.APPLICATION_ID = 101
      AND F.ID_FLEX_CODE = 'GL#'
      AND F.ID_FLEX_NUM = R.CHART_OF_ACCOUNTS_ID
      AND DECODE(R.DIMENSION_ID,
                 0, B.DIMENSION_VARCHAR_LABEL,
                 B.DIMENSION_ID) =
          DECODE(R.DIMENSION_ID,
                 0, 'COMPANY_COST_CENTER_ORG',
                 R.DIMENSION_ID);

    FEM_ENGINES_PKG.Tech_Message
      ( p_severity => pc_log_level_procedure
       ,p_module   => pc_module_name||c_func_name
       ,p_msg_text => 'Initialize pv_mapped_segs array');

    pv_progress := 'Extend mapped segs';
    FOR i IN pv_mapped_segs.count()..4
    LOOP
       pv_mapped_segs.extend();
    END LOOP;

    pv_progress := 'Initialize major package variables 1 of 3';

    FEM_ENGINES_PKG.Tech_Message
      ( p_severity => pc_log_level_procedure
       ,p_module   => pc_module_name||c_func_name
       ,p_msg_text => 'Initialize major package variables 1 of 3 ');

    SELECT SEGMENT_COUNT
         , DIM_MAPPING_OPTION_CODE
         , DEFAULT_MEMBER_ID
         , DEFAULT_MEMBER_VALUE_SET_ID
         , NVL(MAX_CCID_PROCESSED,-1)
         , NVL(MAX_FLEX_VALUE_ID_PROCESSED,-1)
         , DECODE(DIM_MAPPING_OPTION_CODE, 'SINGLEVAL'
                                        ,DEFAULT_MEMBER_VALUE_SET_ID,
                        NVL(FEM_VALUE_SET_ID,-1))
         , APPLICATION_COLUMN_NAME1
         , NVL(APPLICATION_COLUMN_NAME2,'-99')
         , NVL(APPLICATION_COLUMN_NAME3,'-99')
         , NVL(APPLICATION_COLUMN_NAME4,'-99')
         , NVL(APPLICATION_COLUMN_NAME5,'-99')
    INTO   pv_segment_count
         , pv_dim_mapping_option_code
         , pv_default_member_id
         , pv_default_member_vs_id
         , pv_max_ccid_processed
         , pv_max_flex_value_id_processed
         , pv_fem_vs_id
         , pv_mapped_segs(1).application_column_name
         , pv_mapped_segs(2).application_column_name
         , pv_mapped_segs(3).application_column_name
         , pv_mapped_segs(4).application_column_name
         , pv_mapped_segs(5).application_column_name
    FROM FEM_INTG_DIM_RULE_DEFS
    WHERE DIM_RULE_OBJ_DEF_ID = pv_dim_rule_obj_def_id;

    FOR i in 1..5
    LOOP
      pv_mapped_segs(i).vs_id := -99;
    END LOOP;

    FEM_ENGINES_PKG.Tech_Message
      ( p_severity => pc_log_level_procedure
       ,p_module   => pc_module_name||c_func_name
       ,p_msg_text => 'Initialize major package variables 2 of 3 ');

    FOR i IN 1..pv_segment_count LOOP
      BEGIN
        SELECT NVL(S.FLEX_VALUE_SET_ID,-99),
               DECODE(V.VALIDATION_TYPE, 'F', 'Y', 'N'),
               T.APPLICATION_TABLE_NAME,
               T.ID_COLUMN_NAME,
               T.VALUE_COLUMN_NAME,
               T.COMPILED_ATTRIBUTE_COLUMN_NAME,
               T.MEANING_COLUMN_NAME,
               T.ADDITIONAL_WHERE_CLAUSE,
               DECODE(V.VALIDATION_TYPE,'D','Y','N'),
               DECODE(V.VALIDATION_TYPE,'D',V.PARENT_FLEX_VALUE_SET_ID,NULL)
        INTO   pv_mapped_segs(i).vs_id,
               pv_mapped_segs(i).table_validated_flag,
               pv_mapped_segs(i).table_name,
               pv_mapped_segs(i).id_col_name,
               pv_mapped_segs(i).val_col_name,
               pv_mapped_segs(i).compiled_attr_col_name,
               pv_mapped_segs(i).meaning_col_name,
               pv_mapped_segs(i).where_clause,
               pv_mapped_segs(i).dependent_value_set_flag,
               pv_mapped_segs(i).dependent_vs_id
        FROM   FND_ID_FLEX_SEGMENTS S,
               FND_FLEX_VALUE_SETS V,
               FND_FLEX_VALIDATION_TABLES T
        WHERE S.APPLICATION_ID = 101
        AND   S.ID_FLEX_CODE = 'GL#'
        AND   S.ID_FLEX_NUM = pv_coa_id
        AND   S.APPLICATION_COLUMN_NAME =
                pv_mapped_segs(i).application_column_name
        AND   V.FLEX_VALUE_SET_ID = NVL(S.FLEX_VALUE_SET_ID, -99)
        AND   T.FLEX_VALUE_SET_ID (+) = V.FLEX_VALUE_SET_ID;
      EXCEPTION
        WHEN OTHERS THEN
          FEM_ENGINES_PKG.Tech_Message
            ( p_severity => pc_log_level_procedure
             ,p_module   => pc_module_name||c_func_name
             ,p_msg_text => 'Cannot find value set id in a given colum name');

          pv_mapped_segs(i).vs_id := -99;
      END;
    END LOOP;

    FOR i in 1..pv_segment_count
    LOOP
      IF pv_mapped_segs(i).dependent_value_set_flag = 'Y'
      THEN
        IF i = 2
        THEN
          pv_mapped_segs(i).dependent_segment_column := 'segment1_value';
        ELSE
          FOR k in 1..i
          LOOP
            IF pv_mapped_segs(k).vs_id = pv_mapped_segs(i).dependent_vs_id
            THEN
              pv_mapped_segs(i).dependent_segment_column := 'segment'||k||'_value';
            END IF;
          END LOOP;
        END IF;
      END IF;
    END LOOP;

    -- ----------------------------------------------------------
    -- Get Org dimension ID
    -- ----------------------------------------------------------
    BEGIN
      SELECT DIMENSION_ID
      INTO pv_cctr_org_dim_id
      FROM FEM_DIMENSIONS_B
      WHERE DIMENSION_VARCHAR_LABEL = 'COMPANY_COST_CENTER_ORG';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        pv_cctr_org_dim_id := -1;
      WHEN OTHERS THEN
        RAISE;
    END;

    -- ----------------------------------------------------------
    -- Get financial element dimension ID
    -- ----------------------------------------------------------

    BEGIN
      SELECT DIMENSION_ID
      INTO pv_fin_element_dim_id
      FROM FEM_DIMENSIONS_B
      WHERE DIMENSION_VARCHAR_LABEL = 'FINANCIAL_ELEMENT';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        pv_fin_element_dim_id := -1;
      WHEN OTHERS THEN
        RAISE;
    END;


    -- ----------------------------------------------------------
    -- Get financial element value set ID
    -- ----------------------------------------------------------

    BEGIN
      SELECT value_set_id
      INTO   pv_fin_element_vs_id
      FROM   FEM_FIN_ELEMS_B
      WHERE  ROWNUM = 1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        pv_fin_element_vs_id := -1;
      WHEN OTHERS THEN
        RAISE;
    END;

    pv_progress := 'Get extended acct type attribute id';
    SELECT  a.attribute_id
           ,v.version_id
    INTO    pv_ext_acct_type_attr_id
           ,pv_ext_acct_attr_version_id
    FROM    fem_dim_attributes_b a,
            fem_dim_attr_versions_b v
    WHERE  a.dimension_id = 2
      AND a.attribute_varchar_label='EXTENDED_ACCOUNT_TYPE'
      AND v.attribute_id            = a.attribute_id
      AND v.default_version_flag    = 'Y';

    pv_progress := 'Get source system code';

    SELECT SOURCE_SYSTEM_CODE
    INTO   pv_source_system_code_id
    FROM   FEM_SOURCE_SYSTEMS_B
    WHERE  SOURCE_SYSTEM_DISPLAY_CODE = 'OGL';

    IF pv_dim_varchar_label IN ('COMPANY_COST_CENTER_ORG', 'INTERCOMPANY')
    THEN
      BEGIN
        pv_progress := 'Get pv_com_dim_id';
        SELECT DIMENSION_ID
        INTO pv_com_dim_id
        FROM FEM_DIMENSIONS_B
        WHERE DIMENSION_VARCHAR_LABEL = 'COMPANY';

        pv_progress := 'Get pv_cc_dim_id';
        SELECT DIMENSION_ID
        INTO pv_cc_dim_id
        FROM FEM_DIMENSIONS_B
        WHERE DIMENSION_VARCHAR_LABEL = 'COST_CENTER';
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          IF pv_dim_mapping_option_code = 'MULTISEG'
          THEN
            IF  pv_progress = 'Get pv_com_dim_id'
            THEN
              RAISE FEMOGL_com_dim_missing;
            ELSE
              RAISE FEMOGL_cc_dim_missing;
            END IF;
          ELSE
            NULL; -- raise no error
          END IF;
      END;

      OPEN FlexQualifiedSegmentNUM('GL_BALANCING', pv_cctr_org_dim_id);
      FETCH FlexQualifiedSegmentNUM INTO pv_balancing_segment_num;
      CLOSE FlexQualifiedSegmentNUM;

      OPEN FlexQualifiedSegmentNUM('FA_COST_CTR', pv_cctr_org_dim_id);
      FETCH FlexQualifiedSegmentNUM INTO pv_cost_center_segment_num;
      CLOSE FlexQualifiedSegmentNUM;

    ELSIF pv_dim_varchar_label = 'NATURAL_ACCOUNT' THEN

      pv_natural_account_segment_num := 1;

    ELSIF pv_dim_varchar_label = 'LINE_ITEM' THEN

      IF pv_dim_mapping_option_code = 'SINGLESEG' THEN
        pv_natural_account_segment_num := 1;
      ELSE
        OPEN FlexQualifiedSegmentNUM('GL_ACCOUNT', pv_dim_id);
        FETCH FlexQualifiedSegmentNUM INTO pv_natural_account_segment_num;
        CLOSE FlexQualifiedSegmentNUM;
      END IF;

    END IF;

    FEM_ENGINES_PKG.Tech_Message
      ( p_severity => pc_log_level_procedure
       ,p_module   => pc_module_name||c_func_name
       ,p_msg_text => 'Initialize major package variables 3 of 3 ');

    pv_progress := 'Get table info for dimension';
    IF pv_dim_id <> 0 THEN

      SELECT MEMBER_B_TABLE_NAME
            ,MEMBER_TL_TABLE_NAME
            ,MEMBER_COL
            ,MEMBER_NAME_COL
            ,MEMBER_VL_OBJECT_NAME
            ,MEMBER_DESCRIPTION_COL
            ,MEMBER_DISPLAY_CODE_COL
            ,ATTRIBUTE_TABLE_NAME
      INTO   pv_member_b_table_name
            ,pv_member_tl_table_name
            ,pv_member_col
            ,pv_member_name_col
            ,pv_member_vl_object_name
            ,pv_member_desc_col
            ,pv_member_display_code_col
            ,pv_attr_table_name
      FROM  FEM_XDIM_DIMENSIONS
      WHERE DIMENSION_ID = pv_dim_id;

    ELSE

      FEM_ENGINES_PKG.Tech_Message
       ( p_severity => pc_log_level_procedure
        ,p_module   => pc_module_name||c_func_name
        ,p_msg_text => '- Intercompany case -  ');


      IF pv_cctr_org_dim_id = -1
      THEN
        RAISE FEMOGL_cctr_org_dim_missing;
      END IF;

      SELECT MEMBER_B_TABLE_NAME,
             MEMBER_TL_TABLE_NAME,
             MEMBER_VL_OBJECT_NAME,
             MEMBER_COL,
             MEMBER_DISPLAY_CODE_COL,
             MEMBER_NAME_COL,
             ATTRIBUTE_TABLE_NAME
      INTO  pv_member_b_table_name,
            pv_member_tl_table_name,
            pv_member_vl_object_name,
            pv_cctr_org_member_col,
            pv_member_display_code_col,
            pv_member_name_col,
            pv_attr_table_name
      FROM  FEM_XDIM_DIMENSIONS
      WHERE DIMENSION_ID = pv_cctr_org_dim_id;

      pv_member_col := 'INTERCOMPANY_ID';

    END IF;

    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => pc_module_name || c_func_name,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_202',
       p_token1   => 'FUNC_NAME',
       p_value1   => pc_module_name||c_func_name,
       p_token2   => 'TIME',
       p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
  EXCEPTION
    WHEN FEMOGL_cctr_org_dim_missing THEN
      FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_error
      ,p_module   => pc_module_name||c_func_name||'.unexpected_exception'
      ,p_msg_text => 'Cannot find CCTR-ORG dimension ID');

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_error
        ,p_module   => pc_module_name||c_func_name
        ,p_app_name => 'FEM'
        ,p_msg_name => 'FEM_INTG_DIM_ENG_101'
        ,p_token1   => 'DIM_ID'
        ,p_value1   =>  pv_dim_id);

      FEM_ENGINES_PKG.Tech_Message
       (p_severity    => pc_log_level_error
       ,p_module   => pc_module_name||c_func_name||'.unexpected_exception'
       ,p_app_name => 'FEM'
       ,p_msg_name => 'FEM_GL_POST_203'
       ,p_token1   => 'FUNC_NAME'
       ,p_value1   => pc_module_name||c_func_name
       ,p_token2   => 'TIME'
       ,p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

      fnd_message.set_name('FEM','FEM_INTG_DIM_ENG_101');
      fnd_message.set_token('DIM_ID',pv_dim_id);

      app_exception.raise_exception;

    WHEN FEMOGL_com_dim_missing THEN
      FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_error
      ,p_module   => pc_module_name||c_func_name||'.unexpected_exception'
      ,p_msg_text => 'Cannot find company dimension ID');

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_error
        ,p_module   => pc_module_name||c_func_name
        ,p_app_name => 'FEM'
        ,p_msg_name => 'FEM_INTG_DIM_ENG_102'
        ,p_token1   => 'DIM_ID'
        ,p_value1   =>  pv_dim_id);

      FEM_ENGINES_PKG.Tech_Message
       (p_severity    => pc_log_level_error
       ,p_module   => pc_module_name||c_func_name||'.unexpected_exception'
       ,p_app_name => 'FEM'
       ,p_msg_name => 'FEM_GL_POST_203'
       ,p_token1   => 'FUNC_NAME'
       ,p_value1   => c_func_name
       ,p_token2   => 'TIME'
       ,p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

      fnd_message.set_name('FEM','FEM_INTG_DIM_ENG_102');
      fnd_message.set_token('DIM_ID',pv_dim_id);

      app_exception.raise_exception;

    WHEN FEMOGL_cc_dim_missing THEN
      FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_error
      ,p_module   => pc_module_name||c_func_name||'.unexpected_exception'
      ,p_msg_text => 'Cannot find cost center dimension ID');

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_error
        ,p_module   => pc_module_name||c_func_name
        ,p_app_name => 'FEM'
        ,p_msg_name => 'FEM_INTG_DIM_ENG_103'
        ,p_token1   => 'DIM_ID'
        ,p_value1   =>  pv_dim_id);

      FEM_ENGINES_PKG.Tech_Message
       (p_severity    => pc_log_level_error
       ,p_module   => pc_module_name||c_func_name||'.unexpected_exception'
       ,p_app_name => 'FEM'
       ,p_msg_name => 'FEM_GL_POST_203'
       ,p_token1   => 'FUNC_NAME'
       ,p_value1   => c_func_name
       ,p_token2   => 'TIME'
       ,p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

      fnd_message.set_name('FEM','FEM_INTG_DIM_ENG_103');
      fnd_message.set_token('DIM_ID',pv_dim_id);

      app_exception.raise_exception;

    WHEN OTHERS THEN
      FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_unexpected
      ,p_module   => pc_module_name||c_func_name||'.unexpected_exception'
      ,p_msg_text => sqlerrm);

      FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_unexpected
      ,p_module   => pc_module_name||c_func_name||'.unexpected_exception'
      ,p_msg_text => 'Location before failure: '||pv_progress);

      FEM_ENGINES_PKG.User_Message
       (p_msg_text => sqlerrm);

      FEM_ENGINES_PKG.Tech_Message
       (p_severity    => pc_log_level_procedure
       ,p_module   => pc_module_name||c_func_name||'.unexpected_exception'
       ,p_app_name => 'FEM'
       ,p_msg_name => 'FEM_GL_POST_203'
       ,p_token1   => 'FUNC_NAME'
       ,p_value1   => pc_module_name||c_func_name
       ,p_token2   => 'TIME'
       ,p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

      raise_application_error(-20001, fnd_message.get);
  END;


  PROCEDURE main (x_errbuf OUT NOCOPY  VARCHAR2,
                  x_retcode OUT NOCOPY VARCHAR2,
                  p_dim_rule_obj_def_id IN NUMBER,
                  p_execution_mode IN VARCHAR2)
  IS
    v_max_ccid_in_map_table            NUMBER;
    v_max_ccid_in_glccid_table         NUMBER;
    v_completion_code                  NUMBER;
    v_dim_process_row_cnt              NUMBER;
    v_ccc_org_dim_id                   NUMBER;
    FEMOGL_fatal_err                   EXCEPTION;
    FEMOGL_gvsc_not_set                EXCEPTION;
    FEMOGL_warn                        EXCEPTION;
    FEMOGL_no_data_to_load             EXCEPTION;
    FEMOGL_all_data_invalid            EXCEPTION;
    v_compl_code                       NUMBER;
    v_cp_status                        VARCHAR2(30);
    c_func_name                        CONSTANT VARCHAR2(30) := '.Main';
    v_global_defs_vs_id                NUMBER;
    v_completion_code_register         NUMBER;
    v_completion_code_final            NUMBER;
    v_map_records_inserted_count       NUMBER;
    v_status                           NUMBER;
    v_rowcount                         NUMBER;
    v_temp_vs_id                       NUMBER;
    v_cctr_map_option_code             VARCHAR2(30);
    v_cctr_seg_count                   NUMBER;
    v_com_fnd_vs_id                    NUMBER;
    v_cc_fnd_vs_id                     NUMBER;

    v_interco_req_id		NUMBER;
    v_interco_rule_def_id	NUMBER;

    --bugfix 8780516
    v_fem_vs_id_at_first               NUMBER;
    --end bugfix


    -- Bug#6057664: Added as output parameters for the call.
    l_return_status                    VARCHAR2(1);
    l_msg_count                        NUMBER;
    l_msg_data                         VARCHAR2(2000);

--correct GSCC Warnings
    l_status VARCHAR2(100);
   l_industry VARCHAR2(100);
   l_schema VARCHAR2(10);
   l_ret_status BOOLEAN;

    TYPE INDEX_NAME is TABLE OF VARCHAR2(30);
    pv_index_name INDEX_NAME;
  BEGIN
    pv_progress := 'Main Start';
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => pc_module_name||c_func_name,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_201',
       p_token1   => 'FUNC_NAME',
       p_value1   => pc_module_name||c_func_name,
       p_token2   => 'TIME',
       p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

    pv_dim_rule_obj_def_id  := p_dim_rule_obj_def_id;
    pv_user_id              := NVL(FND_GLOBAL.USER_ID,'-1');
    pv_login_id             := NVL(FND_GLOBAL.CONC_LOGIN_ID,
                                      FND_GLOBAL.LOGIN_ID);
    pv_req_id               := NVL(FND_GLOBAL.CONC_REQUEST_ID,1);
    pv_pgm_id               := NVL(FND_GLOBAL.CONC_PROGRAM_ID,1);
    pv_pgm_app_id           := NVL(FND_GLOBAL.PROG_APPL_ID,274);

    pv_progress := 'Before select of object id and folder id';

    SELECT O.OBJECT_ID, O.FOLDER_ID
    INTO    pv_dim_rule_obj_id, pv_folder_id
    FROM    FEM_OBJECT_DEFINITION_B B,
            FEM_OBJECT_CATALOG_B O
    WHERE B.OBJECT_DEFINITION_ID = pv_dim_rule_obj_def_id
    AND   O.OBJECT_ID = B.OBJECT_ID
    AND   O.OBJECT_TYPE_CODE = 'OGL_INTG_DIM_RULE';

    /*
    -- ----------------------------------------------------------
    -- Check if User has authorization to run dimension rules
    -- ----------------------------------------------------------
    -- REMOVED CODE */

    -- -----------------------------------
    -- *** Register Process Execution ***
    -- -----------------------------------

    pv_progress := 'Calling FEM_GL_POST_PROCESS_PKG.Register_Process_Execution';

    FEM_ENGINES_PKG.Tech_Message
      ( p_severity => pc_log_level_event
       ,p_module   => pc_module_name||c_func_name
       ,p_msg_text => 'Before calling Process lock');


    FEM_INTG_PL_PKG.Register_Process_Execution(
      p_obj_id => pv_dim_rule_obj_id,
      p_obj_def_id => pv_dim_rule_obj_def_id,
      p_req_id => pv_req_id,
      p_user_id => pv_user_id,
      p_login_id => pv_login_id,
      p_pgm_id => pv_pgm_id,
      p_pgm_app_id => pv_pgm_app_id,
      p_module_name => pc_module_name,
      x_completion_code => v_completion_code_register
    );

    IF v_completion_code_register = 2 THEN
      FEM_ENGINES_PKG.Tech_Message
        ( p_severity => pc_log_level_error
         ,p_module   => pc_module_name||c_func_name
         ,p_msg_text => 'Before calling Process lock');
      RAISE FEMOGL_fatal_err;
    END IF;

    -- ------------------------------------
    -- *** Initialize Package Variables ***
    -- ------------------------------------

    pv_progress := 'Calling to initialize';

    FEM_ENGINES_PKG.Tech_Message
      ( p_severity => pc_log_level_error
       ,p_module   => pc_module_name||c_func_name
       ,p_msg_text => 'Before calling Init');

    FEM_ENGINES_PKG.User_Message(
        p_app_name => 'FEM',
        p_msg_name => 'FEM_INTG_DIM_ENG_501'
      );

    Init;

    --Bugfix 8780516
    SELECT fem_value_set_id
    INTO v_fem_vs_id_at_first
    FROM fem_intg_dim_rule_defs
    WHERE dim_rule_obj_def_id = p_dim_rule_obj_def_id;
    --end bugfix

    pv_progress := 'Before select of GVSC ID';
    BEGIN
      SELECT COA.GLOBAL_VS_COMBO_ID
      INTO   pv_gvsc_id
      FROM   FEM_OBJECT_DEFINITION_B DEF,
             FEM_INTG_COA_GVSC_MAP COA
      WHERE DEF.OBJECT_DEFINITION_ID = p_dim_rule_obj_def_id
        AND COA.CHART_OF_ACCOUNTS_ID = pv_coa_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE FEMOGL_gvsc_not_set;
    END;

    IF pv_fem_vs_id = -1
    AND  pv_dim_mapping_option_code <> 'SINGLEVAL'
    THEN
      pv_progress := 'FEM_ID is -1, entered IF';
      IF NVL(pv_dim_varchar_label,'X') <> 'INTERCOMPANY'
      THEN
        BEGIN
          pv_progress := 'select fem_vs_id from AOL valuse set map';
          SELECT fem_value_set_id
          INTO   pv_fem_vs_id
          FROM   FEM_INTG_AOL_VALSET_MAP
          WHERE  DIMENSION_ID = pv_dim_id
            AND  NVL(SEGMENT1_VALUE_SET_ID,-99) = pv_mapped_segs(1).vs_id
            AND  NVL(SEGMENT2_VALUE_SET_ID,-99) = pv_mapped_segs(2).vs_id
            AND  NVL(SEGMENT3_VALUE_SET_ID,-99) = pv_mapped_segs(3).vs_id
            AND  NVL(SEGMENT4_VALUE_SET_ID,-99) = pv_mapped_segs(4).vs_id
            AND  NVL(SEGMENT5_VALUE_SET_ID,-99) = pv_mapped_segs(5).vs_id;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            --
            -- Create FEM Value Set
            --

            SELECT FEM_VALUE_SETS_B_S.nextval
            INTO pv_fem_vs_id
            FROM DUAL;

            pv_progress := 'insert fem vs into aol mapping table';

            INSERT INTO FEM_INTG_AOL_VALSET_MAP(
               FEM_VALUE_SET_ID,
               DIMENSION_ID,
               SEGMENT1_VALUE_SET_ID,
               SEGMENT2_VALUE_SET_ID,
               SEGMENT3_VALUE_SET_ID,
               SEGMENT4_VALUE_SET_ID,
               SEGMENT5_VALUE_SET_ID,
               CREATION_DATE,
               CREATED_BY,
               LAST_UPDATE_DATE,
               LAST_UPDATED_BY,
               LAST_UPDATE_LOGIN
            )
            VALUES
            (
               pv_fem_vs_id,
               pv_dim_id,
               pv_mapped_segs(1).vs_id,
               pv_mapped_segs(2).vs_id,
               pv_mapped_segs(3).vs_id,
               pv_mapped_segs(4).vs_id,
               pv_mapped_segs(5).vs_id,
               SYSDATE,
               pv_user_id,
               SYSDATE,
               pv_user_id,
               pv_login_id
            );

            pv_progress := 'register fem value set';
            --------------------------------------------------
            --  Register FEM value set
            ---------------------------------------------------
            register_fem_value_set (p_fem_value_set_id  => pv_fem_vs_id
                                   ,p_regiser_type      => 'STANDARD'
                                   ,p_fnd_vs_id         => NULL
                                   ,p_dim_id            => pv_dim_id
                                   ,x_status            => v_status);
            IF v_status = 0
            THEN
              FEM_ENGINES_PKG.Tech_Message
                   ( p_severity => pc_log_level_error
                    ,p_module   => pc_module_name||c_func_name
                    ,p_msg_text => 'Unexpected error while registering FEM value set');
              raise_application_error(-20001, fnd_message.get);
            END IF;

          WHEN OTHERS THEN
            FEM_ENGINES_PKG.Tech_Message
                 ( p_severity => pc_log_level_error
                  ,p_module   => pc_module_name||c_func_name
                  ,p_msg_text => 'Following error during selecting fem VSID
                                  from FEM_INTG_AOL_VALSET_MAP: '||sqlerrm);
              raise_application_error(-20001, fnd_message.get);
        END;

        IF(pv_dim_id = 8) THEN
            UPDATE fem_intg_dim_rule_defs def
              SET default_member_value_set_id = pv_fem_vs_id,
                  default_member_id =
                  (SELECT org.company_cost_center_org_id
                   FROM fem_cctr_orgs_b org
                   WHERE org.cctr_org_display_code = 'Default'
                   AND org.value_set_id = pv_fem_vs_id)
              WHERE def.dim_rule_obj_def_id =
                    (SELECT odb.object_definition_id
                     FROM fem_object_definition_b odb,
                          fem_intg_dim_rules rule
                     WHERE odb.object_id = rule.dim_rule_obj_id
                     AND rule.chart_of_accounts_id = pv_coa_id
                     AND rule.dimension_id = 0)
              AND def.dim_mapping_option_code = 'SINGLEVAL';
         END IF;

      ELSE /* Intercompany case */

        pv_progress := 'Check if Org defintion and Intercompany definition are of same type';

        SELECT ruledef.DIM_MAPPING_OPTION_CODE
             , ruledef.SEGMENT_COUNT
        INTO   v_cctr_map_option_code
             , v_cctr_seg_count
        from fem_intg_dim_rules rules
           , fem_intg_dim_rule_defs ruledef
           , fem_object_definition_b objdef
        where rules.chart_of_accounts_id = pv_coa_id
          and rules.dim_rule_obj_id = objdef.object_id
          and objdef.object_definition_id = ruledef.dim_rule_obj_def_id
          and rules.dimension_id = pv_cctr_org_dim_id;

        IF (pv_segment_count <> v_cctr_seg_count)
        OR (pv_dim_mapping_option_code <> v_cctr_map_option_code)
        THEN
          FEM_ENGINES_PKG.User_Message(
              p_app_name => 'FEM',
              p_msg_name => 'FEM_INTG_DIM_ENG_508'
              );
          fnd_message.set_name('FEM','FEM_INTG_DIM_ENG_508');
          app_exception.raise_exception;
        END IF;


        pv_progress := 'select fem_valueset_id  for intercompany based on CCTR org dimension';
        BEGIN
          SELECT value_set_id
          INTO pv_fem_vs_id
          FROM fem_global_vs_combo_defs
          WHERE global_vs_combo_id = pv_gvsc_id
          AND   dimension_id = pv_cctr_org_dim_id;

          SELECT value_set_id
          INTO pv_com_vs_id
          FROM fem_global_vs_combo_defs
          WHERE global_vs_combo_id = pv_gvsc_id
          AND   dimension_id = pv_com_dim_id;

          SELECT value_set_id
          INTO pv_cc_vs_id
          FROM fem_global_vs_combo_defs
          WHERE global_vs_combo_id = pv_gvsc_id
          AND   dimension_id = pv_cc_dim_id;

        EXCEPTION
          WHEN OTHERS THEN
            FEM_ENGINES_PKG.Tech_Message
            ( p_severity => pc_log_level_procedure
             ,p_module   => pc_module_name||c_func_name
             ,p_msg_text => 'varlable'||pv_dim_varchar_label);
            raise_application_error(-20001, fnd_message.get);
        END;

        IF pv_fem_vs_id = -1
        THEN
          FEM_ENGINES_PKG.User_Message(
              p_app_name => 'FEM',
              p_msg_name => 'FEM_INTG_DIM_ENG_507'
              );
          fnd_message.set_name('FEM','FEM_INTG_DIM_ENG_507');
          app_exception.raise_exception;

        ELSE
          --
          -- Register value set id in FEM_GLOBAL_VS_COMBO_DEFS for
          -- intercompany dimension
          --
          pv_progress := 'Update FEM_GLOBAL_VS_COMBO_DEFS for intercompany dimension';

          UPDATE FEM_GLOBAL_VS_COMBO_DEFS
          SET    VALUE_SET_ID        = pv_fem_vs_id
                ,LAST_UPDATED_BY     = pv_user_id
                ,LAST_UPDATE_DATE    = SYSDATE
                ,LAST_UPDATE_LOGIN   = pv_login_id
          WHERE GLOBAL_VS_COMBO_ID = pv_gvsc_id
            AND DIMENSION_ID       = pv_dim_id;
        END IF;

      END IF; /* INTERCOMPANY */

    END IF; /* pv_fem_vs_id IS NULL */

    IF NVL(pv_dim_varchar_label,'X') <> 'INTERCOMPANY'
    THEN
      BEGIN
        SELECT VALUE_SET_ID
        INTO   v_global_defs_vs_id
        FROM   FEM_GLOBAL_VS_COMBO_DEFS
        WHERE  GLOBAL_VS_COMBO_ID = pv_gvsc_id
          AND  DIMENSION_ID = pv_dim_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
           FEM_ENGINES_PKG.Tech_Message
                   ( p_severity => pc_log_level_error
                    ,p_module   => pc_module_name||c_func_name
                    ,p_msg_text => 'Unexpected error while getting value set from FEM_GLOBAL_VS_COMBO_DEFS');
           raise_application_error(-20001, fnd_message.get);
      END;
      IF v_global_defs_vs_id = -1
      THEN
        pv_progress := 'Update FEM_GLOBAL_VS_COMBO_DEFS';
        UPDATE FEM_GLOBAL_VS_COMBO_DEFS
        SET    VALUE_SET_ID        = pv_fem_vs_id
              ,LAST_UPDATED_BY     = pv_user_id
              ,LAST_UPDATE_DATE    = SYSDATE
              ,LAST_UPDATE_LOGIN   = pv_login_id
        WHERE GLOBAL_VS_COMBO_ID = pv_gvsc_id
          AND DIMENSION_ID       = pv_dim_id;

        IF pv_dim_varchar_label = 'NATURAL_ACCOUNT'
        THEN
          UPDATE FEM_GLOBAL_VS_COMBO_DEFS
           SET    VALUE_SET_ID        = pv_fin_element_vs_id
                 ,LAST_UPDATED_BY     = pv_user_id
                 ,LAST_UPDATE_DATE    = SYSDATE
                 ,LAST_UPDATE_LOGIN   = pv_login_id
          WHERE GLOBAL_VS_COMBO_ID = pv_gvsc_id
           AND DIMENSION_ID       = pv_fin_element_dim_id;
        END IF;
      END IF;
    END IF;


    IF pv_dim_varchar_label = 'INTERCOMPANY'
    THEN
      SELECT value_set_id
      INTO pv_com_vs_id
      FROM fem_global_vs_combo_defs
      WHERE global_vs_combo_id = pv_gvsc_id
      AND   dimension_id = pv_com_dim_id;

      SELECT value_set_id
      INTO pv_cc_vs_id
      FROM fem_global_vs_combo_defs
      WHERE global_vs_combo_id = pv_gvsc_id
      AND   dimension_id = pv_cc_dim_id;
    END IF;


    IF pv_dim_varchar_label = 'COMPANY_COST_CENTER_ORG'
    THEN

      --
      -- Splitting the logic for Single segment and multi segment case for stability
      -- because code changes were done at last minute.  Need to revisit
      -- this section and combine the logic together for next release.
      --
      --
      IF pv_dim_mapping_option_code = 'MULTISEG'
      THEN
        pv_progress := 'Handling special ORG processing logic for CO/CC for Multi Segment';
        -- Create Company and Cost Center FEM Value Sets if not exists
        --
        pv_progress := 'select fem_vs_id from AOL valuse set map for com vsid';
        BEGIN
          SELECT fem_value_set_id
          INTO   pv_com_vs_id
          FROM   FEM_INTG_AOL_VALSET_MAP
          WHERE  DIMENSION_ID = pv_com_dim_id
            AND  NVL(SEGMENT1_VALUE_SET_ID,-99) = pv_mapped_segs(1).vs_id
            AND  NVL(SEGMENT2_VALUE_SET_ID,-99) = -99
            AND  NVL(SEGMENT3_VALUE_SET_ID,-99) = -99
            AND  NVL(SEGMENT4_VALUE_SET_ID,-99) = -99
            AND  NVL(SEGMENT5_VALUE_SET_ID,-99) = -99;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            pv_com_vs_id := -1;
          WHEN OTHERS THEN
            pv_progress := 'unexpected error whiel selecting pv_com_vs_id from FEM_INTG_AOL_VALSET_MAP: ' ||sqlerrm;
            raise_application_error(-20001, fnd_message.get);
        END;

        IF pv_com_vs_id = -1
        THEN
          --
          -- Create FEM Value Set
          --
          pv_progress := 'insert newly created company vset into aol mapping table';

          SELECT FEM_VALUE_SETS_B_S.nextval
          INTO pv_com_vs_id
          FROM DUAL;

          INSERT INTO FEM_INTG_AOL_VALSET_MAP
          (
             FEM_VALUE_SET_ID,
             DIMENSION_ID,
             SEGMENT1_VALUE_SET_ID,
             SEGMENT2_VALUE_SET_ID,
             SEGMENT3_VALUE_SET_ID,
             SEGMENT4_VALUE_SET_ID,
             SEGMENT5_VALUE_SET_ID,
             CREATION_DATE,
             CREATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_LOGIN
          )
          VALUES
          (
            pv_com_vs_id,
            pv_com_dim_id,
            pv_mapped_segs(1).vs_id,
            -99,
            -99,
            -99,
            -99,
            SYSDATE,
            pv_user_id,
            SYSDATE,
            pv_user_id,
            pv_login_id
          );

          --------------------------------------------------
          --  Register FEM value set
          ---------------------------------------------------
          register_fem_value_set (p_fem_value_set_id  => pv_com_vs_id
                                 ,p_regiser_type      => 'COMPANY'
                                 ,p_fnd_vs_id         => pv_mapped_segs(1).vs_id
                                 ,p_dim_id            => pv_com_dim_id
                                 ,x_status            => v_status);
          IF v_status = 0
          THEN
            FEM_ENGINES_PKG.Tech_Message
              ( p_severity => pc_log_level_error
               ,p_module   => pc_module_name||c_func_name
               ,p_msg_text => 'Unexpected error while registering company value set');
            raise_application_error(-20001, fnd_message.get);
          END IF;

        END IF;
        --
        -- Bug fix 4190298
        -- Placed the update out of If statement as this was never done for SINGLESEG case
        --
        pv_progress := 'Update FEM_GLOBAL_VS_COMBO_DEFS for company dim';

        UPDATE FEM_GLOBAL_VS_COMBO_DEFS
        SET    VALUE_SET_ID        = pv_com_vs_id
              ,LAST_UPDATED_BY     = pv_user_id
              ,LAST_UPDATE_DATE    = SYSDATE
              ,LAST_UPDATE_LOGIN   = pv_login_id
        WHERE GLOBAL_VS_COMBO_ID = pv_gvsc_id
          AND DIMENSION_ID       = pv_com_dim_id;

        --
        -- Create Company Cost Center FEM Value Sets if not exists
        --
        pv_progress := 'select fem_vs_id from AOL valuse set map for cc vsid';

        IF pv_dim_mapping_option_code = 'SINGLESEG'
        THEN
          v_temp_vs_id := pv_mapped_segs(1).vs_id;
        ELSE
          v_temp_vs_id := pv_mapped_segs(2).vs_id;
        END IF;
        BEGIN
          SELECT fem_value_set_id
          INTO   pv_cc_vs_id
          FROM   FEM_INTG_AOL_VALSET_MAP
          WHERE  DIMENSION_ID = pv_cc_dim_id
            AND  NVL(SEGMENT1_VALUE_SET_ID,-99) = v_temp_vs_id
            AND  NVL(SEGMENT2_VALUE_SET_ID,-99) = -99
            AND  NVL(SEGMENT3_VALUE_SET_ID,-99) = -99
            AND  NVL(SEGMENT4_VALUE_SET_ID,-99) = -99
            AND  NVL(SEGMENT5_VALUE_SET_ID,-99) = -99;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            pv_cc_vs_id := -1;
          WHEN OTHERS THEN
            pv_progress := 'unexpected error while selecting pv_cc_vs_id
                           from FEM_INTG_AOL_VALSET_MAP: ' ||sqlerrm;
            raise_application_error(-20001, fnd_message.get);
        END;

        IF pv_cc_vs_id = -1
        THEN


          SELECT FEM_VALUE_SETS_B_S.nextval
          INTO pv_cc_vs_id
          FROM DUAL;

          pv_progress := 'insert newly created cc vset into aol mapping table';

          INSERT INTO FEM_INTG_AOL_VALSET_MAP
          (
             FEM_VALUE_SET_ID,
             DIMENSION_ID,
             SEGMENT1_VALUE_SET_ID,
             SEGMENT2_VALUE_SET_ID,
             SEGMENT3_VALUE_SET_ID,
             SEGMENT4_VALUE_SET_ID,
             SEGMENT5_VALUE_SET_ID,
             CREATION_DATE,
             CREATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_LOGIN
          )
          VALUES
          (
            pv_cc_vs_id,
            pv_cc_dim_id,
            v_temp_vs_id,
            -99,
            -99,
            -99,
            -99,
            SYSDATE,
            pv_user_id,
            SYSDATE,
            pv_user_id,
            pv_login_id
          );

          --------------------------------------------------
          --  Register FEM value set
          ---------------------------------------------------
	  --bugfix 8780516
          register_fem_value_set (p_fem_value_set_id  => pv_cc_vs_id
                                 ,p_regiser_type      => 'COST_CENTER'
                                 ,p_fnd_vs_id         => v_temp_vs_id
                                 ,p_dim_id            => pv_cc_dim_id
                                 ,x_status            => v_status);

          --end bugfix
          IF v_status = 0
          THEN
            FEM_ENGINES_PKG.Tech_Message
              ( p_severity => pc_log_level_error
               ,p_module   => pc_module_name||c_func_name
               ,p_msg_text => 'Unexpected error while registering Cost-center value set');
            raise_application_error(-20001, fnd_message.get);
          END IF;

        END IF;

        pv_progress := 'Insert into FEM_GLOBAL_VS_COMBO_DEFS for cc dim';
        UPDATE FEM_GLOBAL_VS_COMBO_DEFS
        SET    VALUE_SET_ID        = pv_cc_vs_id
              ,LAST_UPDATED_BY     = pv_user_id
              ,LAST_UPDATE_DATE    = SYSDATE
              ,LAST_UPDATE_LOGIN   = pv_login_id
        WHERE GLOBAL_VS_COMBO_ID = pv_gvsc_id
          AND DIMENSION_ID       = pv_cc_dim_id;
      ELSE
        pv_progress := 'Handling special ORG processing logic for CO/CC for Single Segment';

        IF pv_balancing_segment_num = 1
        THEN
             v_com_fnd_vs_id :=   pv_mapped_segs(1).vs_id;
             v_cc_fnd_vs_id :=   -1;
        ELSE
             v_com_fnd_vs_id :=   -1;
             v_cc_fnd_vs_id :=   pv_mapped_segs(1).vs_id;
        END IF;

        BEGIN
          SELECT fem_value_set_id
          INTO   pv_com_vs_id
          FROM   FEM_INTG_AOL_VALSET_MAP
          WHERE  DIMENSION_ID = pv_com_dim_id
            AND  NVL(SEGMENT1_VALUE_SET_ID,-99) = v_com_fnd_vs_id
            AND  NVL(SEGMENT2_VALUE_SET_ID,-99) = -99
            AND  NVL(SEGMENT3_VALUE_SET_ID,-99) = -99
            AND  NVL(SEGMENT4_VALUE_SET_ID,-99) = -99
            AND  NVL(SEGMENT5_VALUE_SET_ID,-99) = -99;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            pv_com_vs_id := -1;
        END;

        BEGIN
          SELECT fem_value_set_id
          INTO   pv_cc_vs_id
          FROM   FEM_INTG_AOL_VALSET_MAP
          WHERE  DIMENSION_ID = pv_cc_dim_id
            AND  NVL(SEGMENT1_VALUE_SET_ID,-99) = v_cc_fnd_vs_id
            AND  NVL(SEGMENT2_VALUE_SET_ID,-99) = -99
            AND  NVL(SEGMENT3_VALUE_SET_ID,-99) = -99
            AND  NVL(SEGMENT4_VALUE_SET_ID,-99) = -99
            AND  NVL(SEGMENT5_VALUE_SET_ID,-99) = -99;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            pv_cc_vs_id := -1;
        END;

        IF pv_com_vs_id = -1
        THEN
          --
          -- Create FEM Value Set
          --
          pv_progress := 'insert newly created company vset into aol mapping table';

          IF v_com_fnd_vs_id = -1
          THEN
            SELECT default_value_set_id
            INTO pv_com_vs_id
            FROM fem_xdim_dimensions
            WHERE dimension_id = pv_com_dim_id;
          ELSE
            SELECT FEM_VALUE_SETS_B_S.nextval
            INTO pv_com_vs_id
            FROM DUAL;
          END IF;

          INSERT INTO FEM_INTG_AOL_VALSET_MAP
          (
            FEM_VALUE_SET_ID,
            DIMENSION_ID,
            SEGMENT1_VALUE_SET_ID,
            SEGMENT2_VALUE_SET_ID,
            SEGMENT3_VALUE_SET_ID,
            SEGMENT4_VALUE_SET_ID,
            SEGMENT5_VALUE_SET_ID,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN
          )
          VALUES
          (
            pv_com_vs_id,
            pv_com_dim_id,
            v_com_fnd_vs_id,
            -99,
            -99,
            -99,
            -99,
            SYSDATE,
            pv_user_id,
            SYSDATE,
            pv_user_id,
            pv_login_id
          );

          IF  v_com_fnd_vs_id <> -1
          THEN
            --------------------------------------------------
            --  Register FEM value set
            ---------------------------------------------------
            register_fem_value_set (p_fem_value_set_id  => pv_com_vs_id
                                   ,p_regiser_type      => 'COMPANY'
                                   ,p_fnd_vs_id         => v_com_fnd_vs_id
                                   ,p_dim_id            => pv_com_dim_id
                                   ,x_status            => v_status);
            IF v_status = 0
            THEN
              FEM_ENGINES_PKG.Tech_Message
                ( p_severity => pc_log_level_error
                 ,p_module   => pc_module_name||c_func_name
                 ,p_msg_text => 'Unexpected error while registering company value set');
              raise_application_error(-20001, fnd_message.get);
            END IF; /* IF v_status = 0 */
          END IF; /* IF  v_com_fnd_vs_id <> -1 */
        END IF;  /* IF pv_com_vs_id = -1 */

        pv_progress := 'Update FEM_GLOBAL_VS_COMBO_DEFS for company dim';

        UPDATE FEM_GLOBAL_VS_COMBO_DEFS
        SET    VALUE_SET_ID        = pv_com_vs_id
              ,LAST_UPDATED_BY     = pv_user_id
              ,LAST_UPDATE_DATE    = SYSDATE
              ,LAST_UPDATE_LOGIN   = pv_login_id
        WHERE GLOBAL_VS_COMBO_ID = pv_gvsc_id
          AND DIMENSION_ID       = pv_com_dim_id;

        IF pv_cc_vs_id = -1
        THEN
          --
          -- Create FEM Value Set
          --
          pv_progress := 'insert newly created cost center vset into aol mapping table';

          IF v_cc_fnd_vs_id = -1
          THEN
            SELECT default_value_set_id
            INTO pv_cc_vs_id
            FROM fem_xdim_dimensions
            WHERE dimension_id = pv_cc_dim_id;
          ELSE
            SELECT FEM_VALUE_SETS_B_S.nextval
            INTO pv_cc_vs_id
            FROM DUAL;
          END IF;

          INSERT INTO FEM_INTG_AOL_VALSET_MAP
          (
            FEM_VALUE_SET_ID,
            DIMENSION_ID,
            SEGMENT1_VALUE_SET_ID,
            SEGMENT2_VALUE_SET_ID,
            SEGMENT3_VALUE_SET_ID,
            SEGMENT4_VALUE_SET_ID,
            SEGMENT5_VALUE_SET_ID,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN
          )
          VALUES
          (
            pv_cc_vs_id,
            pv_cc_dim_id,
            v_cc_fnd_vs_id,
            -99,
            -99,
            -99,
            -99,
            SYSDATE,
            pv_user_id,
            SYSDATE,
            pv_user_id,
            pv_login_id
          );

          IF  v_cc_fnd_vs_id <> -1
          THEN
            --------------------------------------------------
            --  Register FEM value set
            ---------------------------------------------------
	    --bugfix 8780516
            register_fem_value_set (p_fem_value_set_id  => pv_cc_vs_id
                                   ,p_regiser_type      => 'COST_CENTER'
                                   ,p_fnd_vs_id         =>  v_cc_fnd_vs_id
                                   ,p_dim_id            => pv_cc_dim_id
                                   ,x_status            => v_status);
	    --end bugfix
            IF v_status = 0
            THEN
              FEM_ENGINES_PKG.Tech_Message
                ( p_severity => pc_log_level_error
                 ,p_module   => pc_module_name||c_func_name
                 ,p_msg_text => 'Unexpected error while registering cost center value set');
              raise_application_error(-20001, fnd_message.get);
            END IF; /* IF v_status = 0 */
          END IF; /* IF  v_cc_fnd_vs_id <> -1 */
        END IF;  /* IF pv_cc_vs_id = -1 */

        pv_progress := 'Insert into FEM_GLOBAL_VS_COMBO_DEFS for cc dim';
        UPDATE FEM_GLOBAL_VS_COMBO_DEFS
        SET    VALUE_SET_ID        = pv_cc_vs_id
              ,LAST_UPDATED_BY     = pv_user_id
              ,LAST_UPDATE_DATE    = SYSDATE
              ,LAST_UPDATE_LOGIN   = pv_login_id
        WHERE GLOBAL_VS_COMBO_ID = pv_gvsc_id
          AND DIMENSION_ID       = pv_cc_dim_id;

      END IF; /* IF pv_dim_mapping_option_code = 'MULTISEG' */
    END IF; /* IF pv_dim_varchar_label = 'COMPANY_COST_CENTER_ORG' */

    pv_progress := 'Before update fem_intg_dim_rule_defs';

    FEM_ENGINES_PKG.Tech_Message
      ( p_severity => pc_log_level_event
       ,p_module   => pc_module_name||c_func_name
       ,p_msg_text => 'Before updating fem_global_vs_combo_defs with'
                       ||pv_fem_vs_id||' for dimension '||pv_dim_id);

    FEM_ENGINES_PKG.User_Message(
        p_app_name => 'FEM',
        p_msg_name => 'FEM_INTG_DIM_ENG_502',
        p_token1   => 'VERSION_ID',
        p_value1   => p_dim_rule_obj_def_id,
        p_token2   => 'VALUE_SET_ID',
        p_value2   => pv_fem_vs_id
      );

    UPDATE fem_intg_dim_rule_defs
    SET    fem_value_set_id = pv_fem_vs_id
    WHERE  dim_rule_obj_def_id = p_dim_rule_obj_def_id;

    /*
     * create place holder records in mapping table
     * =============================================
     */

    FEM_ENGINES_PKG.Tech_Message
     ( p_severity => pc_log_level_event
      ,p_module   => pc_module_name||c_func_name
      ,p_msg_text => 'Before locking fem_intg_ogl_ccid_map');

    --bugfix 8780516
    -- Bug 5946597:
    -- Only take the following steps to update the mapping table information if
    -- we are dealing with the intercompany dimension or a concatenated segment
    -- rule.

    IF NVL(pv_dim_varchar_label,'X') = 'INTERCOMPANY' OR
       pv_dim_mapping_option_code = 'MULTISEG' THEN

    --end 8780516


    -- Bug fix 4301926
    LOCK TABLE FEM_INTG_OGL_CCID_MAP IN EXCLUSIVE MODE;

    -- Get max_id of place holder records

    SELECT NVL(MAX(CODE_COMBINATION_ID),-1)
    INTO   v_max_ccid_in_map_table
    FROM   FEM_INTG_OGL_CCID_MAP
    WHERE  GLOBAL_VS_COMBO_ID = pv_gvsc_id;


    --Get max_id of records in CCID table

    SELECT NVL(MAX(CODE_COMBINATION_ID),-1)
    INTO   v_max_ccid_in_glccid_table
    FROM   GL_CODE_COMBINATIONS
    WHERE  CHART_OF_ACCOUNTS_ID = pv_coa_id;

    IF v_max_ccid_in_map_table < v_max_ccid_in_glccid_table
    THEN
      FEM_ENGINES_PKG.Tech_Message
      ( p_severity => pc_log_level_event
       ,p_module   => pc_module_name||c_func_name
       ,p_msg_text => 'Before calling create_map_placeholder_records');

      FEM_ENGINES_PKG.User_Message(
        p_app_name => 'FEM',
        p_msg_name => 'FEM_INTG_DIM_ENG_503');

      create_map_placeholder_records(
        pv_coa_id,
        pv_gvsc_id,
        v_max_ccid_in_map_table,
        v_max_ccid_in_glccid_table,
        v_map_records_inserted_count
      );
    ELSE
      FEM_ENGINES_PKG.Tech_Message
      ( p_severity => pc_log_level_event
       ,p_module   => pc_module_name||c_func_name
       ,p_msg_text => 'Not creating mapping records ');
    END IF;

    COMMIT;

    pv_max_ccid_to_be_mapped := v_max_ccid_in_glccid_table;

    --bugfix 8780516
    END IF;


    ---------------------------------------------------------------------------
    -- *** Print all package level variable values to debug log
    ---------------------------------------------------------------------------

    IF NVL(pv_dim_varchar_label,'X') = 'INTERCOMPANY' THEN
      pv_dim_id := pv_cctr_org_dim_id;
    END IF;

    print_pkg_variable_values;

    /*
     *  Call sub-modules Single value/Single Segment/Multiple Segment
     *  based on type
     */
    pv_progress := 'Before Case';
    CASE pv_dim_mapping_option_code
      WHEN 'SINGLESEG'
      THEN
        FEM_ENGINES_PKG.Tech_Message
        ( p_severity => pc_log_level_event
         ,p_module   => pc_module_name||c_func_name
         ,p_msg_text => 'Before calling Detail_Single_Segment');

        FEM_ENGINES_PKG.User_Message(
          p_app_name => 'FEM',
          p_msg_name => 'FEM_INTG_DIM_ENG_504');

        FEM_INTG_NEW_DIM_MEMBER_PKG.Detail_Single_Segment (v_completion_code
                                                         ,v_dim_process_row_cnt);
      -- start bug fix 5377544
      -- Start bug fix 5560443 - Since intercomapny rule is going to launch the worker requests
      -- we need to have entry point for launch workers incase intercompany is singleval segment
      WHEN 'SINGLEVAL'
      THEN
        IF pv_dim_varchar_label = 'INTERCOMPANY' THEN
           FEM_ENGINES_PKG.Tech_Message
           ( p_severity => pc_log_level_event
            ,p_module   => pc_module_name||c_func_name
            ,p_msg_text => 'Before calling Detail_Single_Value');

           FEM_ENGINES_PKG.User_Message(
             p_app_name => 'FEM',
             p_msg_name => 'FEM_INTG_DIM_ENG_505');

           FEM_INTG_NEW_DIM_MEMBER_PKG.Detail_Single_Value (v_completion_code
                                                           ,v_dim_process_row_cnt);
        END IF;
      -- End bug fix 5560443
      -- end bug fix 5377544

      WHEN 'MULTISEG'
      THEN
        FEM_ENGINES_PKG.Tech_Message
        ( p_severity => pc_log_level_event
         ,p_module   => pc_module_name||c_func_name
         ,p_msg_text => 'Before calling Detail_Multi_Segment');

        FEM_ENGINES_PKG.User_Message(
          p_app_name => 'FEM',
          p_msg_name => 'FEM_INTG_DIM_ENG_506');

        FEM_INTG_NEW_DIM_MEMBER_PKG.Detail_Multi_Segment (v_completion_code
                                                     ,v_dim_process_row_cnt);
      ELSE
        FEM_ENGINES_PKG.Tech_Message
        ( p_severity => pc_log_level_event
         ,p_module   => pc_module_name||c_func_name
         ,p_msg_text => 'Case statement for calling segment population not
                         satisfied: '||pv_dim_mapping_option_code);
    END CASE;
    IF v_completion_code <> 0
    THEN
      raise_application_error(-20001, fnd_message.get);
    END IF;

    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => pc_module_name || c_func_name,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_202',
       p_token1   => 'FUNC_NAME',
       p_value1   => pc_module_name||c_func_name,
       p_token2   => 'TIME',
       p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));


    FEM_INTG_PL_PKG.Final_Process_Logging(
      p_obj_id => pv_dim_rule_obj_id,
      p_obj_def_id => pv_dim_rule_obj_def_id,
      p_req_id => pv_req_id,
      p_user_id => pv_user_id,
      p_login_id => pv_login_id,
      p_exec_status => 'SUCCESS',
      p_row_num_loaded => v_dim_process_row_cnt,
      p_err_num_count => 0,
      p_final_msg_name => 'FEM_INTG_PROC_SUCCESS',
      p_module_name => pc_module_name,
      x_completion_code => v_completion_code_final
    );


    -- Run Intercompany if applicable
    IF pv_dim_varchar_label = 'COMPANY_COST_CENTER_ORG' THEN
      SELECT odb.object_definition_id
      INTO v_interco_rule_def_id
      FROM fem_object_definition_b odb,
           fem_intg_dim_rules rule
      WHERE odb.object_id = rule.dim_rule_obj_id
      AND   rule.chart_of_accounts_id = pv_coa_id
      AND   rule.dimension_id = 0;

      v_interco_req_id := FND_REQUEST.submit_request(
        'FEM', 'FEM_INTG_DIM_RULE_ENGINE', null, null, FALSE,
        to_char(v_interco_rule_def_id), 'MEMBER');

      --bugfix 8780516
      -- Bugfix 6073810
      ELSIF pv_dim_varchar_label = 'LINE_ITEM' THEN
      -- Bugfix 6476319
      commit;

      UPDATE fem_ln_items_attr ln_attr
         SET dim_attribute_varchar_member = 'RETAINED_EARNINGS'
       WHERE EXISTS ( SELECT 1
                       FROM fem_dim_attributes_b a,
                            fem_dim_attr_versions_b v
                      WHERE a.dimension_id = 14
                        AND a.attribute_varchar_label = 'EXTENDED_ACCOUNT_TYPE'
                        AND v.attribute_id            = a.attribute_id
                        AND v.default_version_flag    = 'Y'
                        AND a.attribute_id            = ln_attr.attribute_id
                        AND v.version_id              = ln_attr.version_id )
         AND EXISTS ( SELECT 1
                        FROM gl_sets_of_books sob,
                             fem_intg_ogl_ccid_map maps
                       WHERE sob.chart_of_accounts_id  = pv_coa_id
                         AND maps.code_combination_id   = sob.ret_earn_code_combination_id
                         AND maps.line_item_id        = ln_attr.line_item_id );
    --end bugfix


    END IF;

    commit;

    -- Bug 8780516
    -- Bug 5946597
    -- Only gather statistics if this is the first time we are running
    -- this rule. We get that info by looking at the fem_value_set_id
    -- value in fem_intg_dim_rule_defs. If it is -1 at the beginning
    -- of execution, then this is the first time.

    IF v_fem_vs_id_at_first IS NULL THEN
    -- end bugfix


    FEM_ENGINES_PKG.Tech_Message
    ( p_severity => pc_log_level_event
     ,p_module   => pc_module_name||c_func_name
     ,p_msg_text => 'Gathering statistics for FEM');

/*	FEM_ENGINES_PKG.User_Message
    ( p_msg_text => 'Before Gathering statistics for FEM');*/

--    fnd_stats.gather_schema_statistics('FEM', null, null, null, null);
-- Bug 5084804
-- changed to make in sync with R12 code
    fnd_stats.GATHER_TABLE_STATS('FEM','FEM_INTG_AOL_VALSET_MAP');
    fnd_stats.GATHER_TABLE_STATS('FEM','FEM_INTG_OGL_CCID_MAP');
    fnd_stats.GATHER_TABLE_STATS('FEM','FEM_COMPANIES_B');
    fnd_stats.GATHER_TABLE_STATS('FEM','FEM_COMPANIES_TL');
    fnd_stats.GATHER_TABLE_STATS('FEM','FEM_COST_CENTERS_B');
    fnd_stats.GATHER_TABLE_STATS('FEM','FEM_COST_CENTERS_TL');

    fnd_stats.GATHER_TABLE_STATS('FEM', pv_member_b_table_name);
    fnd_stats.GATHER_TABLE_STATS('FEM', pv_member_tl_table_name);
    fnd_stats.GATHER_TABLE_STATS('FEM', pv_attr_table_name);

    --correct GSCC Warnings
    l_ret_status := fnd_installation.get_app_info('FEM',l_status,l_industry,l_schema);

    select INDEX_NAME BULK COLLECT
    INTO pv_index_name
    from all_indexes where table_name in('FEM_INTG_AOL_VALSET_MAP',
                                         'FEM_INTG_OGL_CCID_MAP',
                                         'FEM_COMPANIES_B',
                                         'FEM_COMPANIES_TL',
                                         'FEM_COST_CENTERS_B',
                                         'FEM_COST_CENTERS_TL',
                                          pv_member_b_table_name,
                                          pv_member_tl_table_name,
                                          pv_attr_table_name)
                            AND table_owner = l_schema and owner = l_schema;

    IF (pv_index_name.FIRST IS NOT NULL AND pv_index_name.LAST IS NOT NULL) THEN
      FOR i in pv_index_name.FIRST.. pv_index_name.LAST
      LOOP
         --bug fix 5489150
         --fnd_stats.GATHER_INDEX_STATS('FEM',pv_index_name(i),null,null,null);
         fnd_stats.GATHER_INDEX_STATS('FEM',pv_index_name(i));
      END LOOP;
    END IF;

    END IF;

	/*FEM_ENGINES_PKG.User_Message
    ( p_msg_text => 'After Gathering statistics for FEM');*/

    --
    -- Bug#6057664: Added to maintain FEM_LEDGER_DIM_VS_MAPS mapping table.
    --
    FEM_ENGINES_PKG.Tech_Message
    ( p_severity => pc_log_level_event
     ,p_module   => pc_module_name||c_func_name
     ,p_msg_text => 'Calling Refresh_ledger_vs_maps API'
    ) ;

    FEM_GLOBAL_VS_COMBO_UTIL_PKG.Refresh_ledger_vs_maps
    (
      x_return_status      => l_return_status,
      x_msg_count          => l_msg_count,
      x_msg_data           => l_msg_data,
      p_global_vs_combo_id => pv_gvsc_id
    ) ;
    --
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF ;
    -- Bug#6057664: End

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_statement,
      p_module   => pc_module_name || '.return_values',
      p_msg_text => 'v_completion_code=' || v_completion_code_final ||
                    ', v_dim_process_row_cnt=' || v_dim_process_row_cnt ||
                    ', v_completion_code_final=' || v_completion_code_final
    );

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      ROLLBACK;
      print_pkg_variable_values;

      FEM_ENGINES_PKG.User_Message
       (p_msg_text => fnd_message.get);

      FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_unexpected
      ,p_module   => pc_module_name||c_func_name||'.unexpected_exception'
      ,p_msg_text => sqlerrm);

      FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_unexpected
      ,p_module   => pc_module_name||c_func_name||'.unexpected_exception'
      ,p_msg_text => 'Location before failure: '||pv_progress);

      FEM_ENGINES_PKG.Tech_Message
       (p_severity    => pc_log_level_procedure
       ,p_module   => pc_module_name||c_func_name||'.unexpected_exception'
       ,p_app_name => 'FEM'
       ,p_msg_name => 'FEM_GL_POST_203'
       ,p_token1   => 'FUNC_NAME'
       ,p_value1   => pc_module_name||c_func_name
       ,p_token2   => 'TIME'
       ,p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

      FEM_INTG_PL_PKG.Final_Process_Logging(
        p_obj_id => pv_dim_rule_obj_id,
        p_obj_def_id => pv_dim_rule_obj_def_id,
        p_req_id => pv_req_id,
        p_user_id => pv_user_id,
        p_login_id => pv_login_id,
        p_exec_status => 'ERROR_RERUN',
        p_row_num_loaded => 0,
        p_err_num_count => v_dim_process_row_cnt,
        p_final_msg_name => 'FEM_INTG_PROC_FAILURE',
        p_module_name => pc_module_name,
        x_completion_code => v_completion_code_final
      );
      x_retcode := 2;
      x_errbuf := fnd_message.get;

    WHEN OTHERS THEN
      ROLLBACK;
      print_pkg_variable_values;

      FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_unexpected
      ,p_module   => pc_module_name||c_func_name||'.unexpected_exception'
      ,p_msg_text => sqlerrm);

      FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_unexpected
      ,p_module   => pc_module_name||c_func_name||'.unexpected_exception'
      ,p_msg_text => 'Location before failure: '||pv_progress);

      FEM_ENGINES_PKG.User_Message
       (p_msg_text => sqlerrm);

      FEM_ENGINES_PKG.Tech_Message
       (p_severity    => pc_log_level_procedure
       ,p_module   => pc_module_name||c_func_name||'.unexpected_exception'
       ,p_app_name => 'FEM'
       ,p_msg_name => 'FEM_GL_POST_203'
       ,p_token1   => 'FUNC_NAME'
       ,p_value1   => pc_module_name||c_func_name
       ,p_token2   => 'TIME'
       ,p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

      FEM_INTG_PL_PKG.Final_Process_Logging(
        p_obj_id => pv_dim_rule_obj_id,
        p_obj_def_id => pv_dim_rule_obj_def_id,
        p_req_id => pv_req_id,
        p_user_id => pv_user_id,
        p_login_id => pv_login_id,
        p_exec_status => 'ERROR_RERUN',
        p_row_num_loaded => 0,
        p_err_num_count => v_dim_process_row_cnt,
        p_final_msg_name => 'FEM_INTG_PROC_FAILURE',
        p_module_name => pc_module_name,
        x_completion_code => v_completion_code_final
      );

      x_retcode := 2;
      x_errbuf := fnd_message.get;

  -- bugfix 8780516
  END main;


  PROCEDURE create_map_placeholder_records
                               (p_coa_id IN NUMBER
                               ,p_gvsc_id IN NUMBER
                               ,p_max_ccid_in_map_table IN NUMBER
                               ,p_max_ccid_in_glccid_table IN NUMBER
                               ,x_rows_processed OUT NOCOPY NUMBER)
  IS
    v_user_id number;
    v_login_id number;
    c_func_name constant varchar2(30) := 'create_map_placeholder_records';
  BEGIN
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => pc_module_name||c_func_name,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_201',
       p_token1   => 'FUNC_NAME',
       p_value1   => pc_module_name||c_func_name,
       p_token2   => 'TIME',
       p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

    INSERT INTO FEM_INTG_OGL_CCID_MAP(
         CODE_COMBINATION_ID,
         GLOBAL_VS_COMBO_ID,
         COMPANY_COST_CENTER_ORG_ID,
         NATURAL_ACCOUNT_ID,
         LINE_ITEM_ID,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATE_LOGIN,
         PRODUCT_ID,
         CHANNEL_ID,
         PROJECT_ID,
         CUSTOMER_ID,
         ENTITY_ID,
         INTERCOMPANY_ID,
         USER_DIM1_ID,
         USER_DIM2_ID,
         USER_DIM3_ID,
         USER_DIM4_ID,
         USER_DIM5_ID,
         USER_DIM6_ID,
         USER_DIM7_ID,
         USER_DIM8_ID,
         USER_DIM9_ID,
         USER_DIM10_ID,
         TASK_ID,
         EXTENDED_ACCOUNT_TYPE)
        SELECT
         GLCC.CODE_COMBINATION_ID,
         p_gvsc_id,
         -1,
         -1,
         -1,
         SYSDATE,
         pv_user_id,
         SYSDATE,
         pv_user_id,
         pv_login_id,
         -1,
         -1,
         -1,
         -1,
         -1,
         -1,
         -1,
         -1,
         -1,
         -1,
         -1,
         -1,
         -1,
         -1,
         -1,
         -1,
         -1,
         -1
        FROM  GL_CODE_COMBINATIONS GLCC
       WHERE  GLCC.CODE_COMBINATION_ID BETWEEN
              p_max_ccid_in_map_table+1 AND p_max_ccid_in_glccid_table
         AND  CHART_OF_ACCOUNTS_ID = p_coa_id
         AND  GLCC.SUMMARY_FLAG = 'N';

    x_rows_processed := SQL%ROWCOUNT;
    FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_statement
        ,p_module   => pc_module_name||c_func_name
        ,p_app_name => 'FEM'
        ,p_msg_name => 'FEM_GL_POST_216'
        ,p_token1   => 'TABLE'
        ,p_value1   => 'FEM_INTG_OGL_CCID_MAP'
        ,p_token2   => 'NUM'
        ,p_value2   => x_rows_processed);

    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => pc_module_name || c_func_name,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_202',
       p_token1   => 'FUNC_NAME',
       p_value1   => pc_module_name||c_func_name,
       p_token2   => 'TIME',
       p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
  EXCEPTION
    WHEN OTHERS THEN
      FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_unexpected
      ,p_module   => pc_module_name||c_func_name||'.unexpected_exception'
      ,p_msg_text => sqlerrm);


      FEM_ENGINES_PKG.User_Message
       (p_msg_text => sqlerrm);

      FEM_ENGINES_PKG.Tech_Message
       (p_severity    => pc_log_level_procedure
       ,p_module   => pc_module_name||c_func_name||'.unexpected_exception'
       ,p_app_name => 'FEM'
       ,p_msg_name => 'FEM_GL_POST_203'
       ,p_token1   => 'FUNC_NAME'
       ,p_value1   => pc_module_name||c_func_name
       ,p_token2   => 'TIME'
       ,p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
  END;

  PROCEDURE register_fem_value_set (p_fem_value_set_id   IN            NUMBER
                                   ,p_regiser_type       IN            VARCHAR2
                                   ,p_fnd_vs_id          IN            NUMBER
                                   ,p_dim_id             IN            NUMBER
                                   ,x_status             IN OUT NOCOPY NUMBER) IS
    v_vs_name  VARCHAR2(755)   := null;
    v_vs_desc  VARCHAR2(1500)  := null;
    v_seg_name VARCHAR2(60)    := null;
    v_seg_desc VARCHAR2(240)   := null;
    v_rowid    ROWID;
    c_func_name       CONSTANT VARCHAR2(30) := '.register_fem_value_set';
    v_vs_count   NUMBER;

    v_return_status	VARCHAR2(100);
    v_msg_count		NUMBER;
    v_msg_data		VARCHAR2(2000);
  BEGIN
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => pc_module_name||c_func_name,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_201',
       p_token1   => 'FUNC_NAME',
       p_value1   => pc_module_name||c_func_name,
       p_token2   => 'TIME',
       p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
    x_status := 1;

    IF p_regiser_type = 'STANDARD'
    THEN
      SELECT flex_value_set_name
            ,description
      INTO   v_vs_name
            ,v_vs_desc
      FROM   FND_FLEX_VALUE_SETS
      WHERE  flex_value_set_id = pv_mapped_segs(1).vs_id;

      IF pv_segment_count > 1
      THEN
        FOR i in 2..pv_segment_count
        LOOP
          SELECT flex_value_set_name
                ,description
          INTO   v_seg_name
                ,v_seg_desc
          FROM   FND_FLEX_VALUE_SETS
          WHERE  flex_value_set_id = pv_mapped_segs(i).vs_id;

          v_vs_name := v_vs_name || '-'||v_seg_name;
          v_vs_desc := v_vs_desc || '-'||v_seg_desc;

        END LOOP;
      END IF;
    ELSE
      SELECT flex_value_set_name
            ,description
      INTO   v_vs_name
            ,v_vs_desc
      FROM   FND_FLEX_VALUE_SETS
      WHERE  flex_value_set_id = p_fnd_vs_id;
    END IF;

    --
    -- Check to see if the valueset already exists
    --
    SELECT count(*)
    INTO   v_vs_count
    FROM   FEM_VALUE_SETS_B
    WHERE  value_set_id = p_fem_value_set_id;

    IF length(v_vs_name) > 140
    THEN
      v_vs_name := substr(v_vs_name, 1,140)||':DIM:'||p_dim_id;
    ELSE
      v_vs_name := v_vs_name||':DIM:'||p_dim_id;
    END IF;

    IF length(v_vs_desc) > 245
    THEN
      v_vs_desc := substr(v_vs_desc, 1,245)||':DIM:'||p_dim_id;
    ELSE
      v_vs_desc := v_vs_desc||':DIM:'||p_dim_id;
    END IF;

    IF v_vs_count = 0
    THEN
      BEGIN
        FEM_ENGINES_PKG.Tech_Message
        ( p_severity => pc_log_level_statement
         ,p_module   => pc_module_name||c_func_name
         ,p_msg_text => 'Calling FEM_VALUE_SETS_PKG.insert_row with' ||pv_crlf||
         'X_VALUE_SET_ID               => '||p_fem_value_set_id||pv_crlf||
         'X_DEFAULT_LOAD_MEMBER_ID     => NULL'||pv_crlf||
         'X_DEFAULT_MEMBER_ID          => NULL'||pv_crlf||
         'X_OBJECT_VERSION_NUMBER      => 1'||pv_crlf||
         'X_DEFAULT_HIERARCHY_OBJ_ID   => NULL'||pv_crlf||
         'X_READ_ONLY_FLAG             => N'||pv_crlf||
         'X_VALUE_SET_DISPLAY_CODE     => '||v_vs_name||pv_crlf||
         'X_DIMENSION_ID               => '||p_dim_id||pv_crlf||
         'X_VALUE_SET_NAME             => '||v_vs_name||pv_crlf||
         'X_DESCRIPTION                => '||v_vs_desc);

        FEM_VALUE_SETS_PKG.insert_row
          ( X_ROWID                      => v_rowid
          , X_VALUE_SET_ID               => p_fem_value_set_id
          , X_DEFAULT_LOAD_MEMBER_ID     => NULL
          , X_DEFAULT_MEMBER_ID          => NULL
          , X_OBJECT_VERSION_NUMBER      => 1
          , X_DEFAULT_HIERARCHY_OBJ_ID   => NULL
          , X_READ_ONLY_FLAG             => 'N'
          , X_VALUE_SET_DISPLAY_CODE     => v_vs_name
          , X_DIMENSION_ID               => p_dim_id
          , X_VALUE_SET_NAME             => v_vs_name
          , X_DESCRIPTION                => v_vs_desc
          , X_CREATION_DATE              => SYSDATE
          , X_CREATED_BY                 => pv_user_id
          , X_LAST_UPDATE_DATE           => SYSDATE
          , X_LAST_UPDATED_BY            => pv_user_id
          , X_LAST_UPDATE_LOGIN          => pv_login_id);

        FEM_ENGINES_PKG.Tech_Message
        ( p_severity => pc_log_level_statement
         ,p_module   => pc_module_name||c_func_name
         ,p_msg_text => 'Row ID returned'||v_rowid);

        IF v_rowid IS NULL
        THEN
          x_status := 0;
        END IF;

        -- Now create the default value and update the dimension rule
        IF pv_dim_varchar_label = 'COMPANY_COST_CENTER_ORG' AND
           p_regiser_type = 'STANDARD' THEN
          fem_dimension_util_pkg.generate_default_load_member
          (x_return_status	=> v_return_status,
           x_msg_count		=> v_msg_count,
           x_msg_data		=> v_msg_data,
           p_vs_id		=> p_fem_value_set_id);

          UPDATE fem_cctr_orgs_b
          SET read_only_flag = 'Y'
          WHERE cctr_org_display_code = 'Default'
          AND value_set_id = p_fem_value_set_id;

        END IF;

      EXCEPTION
        WHEN OTHERS THEN
          x_status := 0;
          FEM_ENGINES_PKG.Tech_Message
          (p_severity => pc_log_level_unexpected
          ,p_module   => pc_module_name||c_func_name||'.unexpected_exception'
          ,p_msg_text => sqlerrm);
          raise_application_error(-20001, fnd_message.get);
      END;
    ELSE
      FEM_ENGINES_PKG.Tech_Message
      ( p_severity => pc_log_level_statement
       ,p_module   => pc_module_name||c_func_name
       ,p_msg_text => 'FEM valueset already exists for '||p_fem_value_set_id);

    END IF;
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => pc_module_name || c_func_name,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_202',
       p_token1   => 'FUNC_NAME',
       p_value1   => pc_module_name||c_func_name,
       p_token2   => 'TIME',
       p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

  EXCEPTION
    WHEN OTHERS THEN
      x_status := 0;
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_unexpected
        ,p_module   => pc_module_name||c_func_name||'.unexpected_exception'
        ,p_msg_text => sqlerrm);

      FEM_ENGINES_PKG.User_Message
       (p_msg_text => sqlerrm);

      FEM_ENGINES_PKG.Tech_Message
       (p_severity    => pc_log_level_procedure
       ,p_module   => pc_module_name||c_func_name||'.unexpected_exception'
       ,p_app_name => 'FEM'
       ,p_msg_name => 'FEM_GL_POST_203'
       ,p_token1   => 'FUNC_NAME'
       ,p_value1   => pc_module_name||c_func_name
       ,p_token2   => 'TIME'
       ,p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

      raise_application_error(-20001, fnd_message.get);

  END;

  PROCEDURE print_pkg_variable_values IS
     c_func_name  CONSTANT         VARCHAR2(30) := '.print_pkg_variable_values';
  BEGIN
      FEM_ENGINES_PKG.Tech_Message
      ( p_severity => pc_log_level_procedure
       ,p_module   => pc_module_name||c_func_name
       ,p_msg_text => 'Values of package variables'||pv_crlf||
       'pv_dim_rule_obj_id:'||pv_dim_rule_obj_id||pv_crlf||
       'pv_dim_rule_obj_def_id:'||pv_dim_rule_obj_def_id||pv_crlf||
       'pv_dim_id:'||pv_dim_id||pv_crlf||
       'pv_user_id:'||pv_user_id||pv_crlf||
       'pv_dim_varchar_label:'||pv_dim_varchar_label||pv_crlf||
       'pv_member_b_table_name:'||pv_member_b_table_name||pv_crlf||
       'pv_member_tl_table_name:'||pv_member_tl_table_name||pv_crlf||
       'pv_member_vl_object_name:'||pv_member_vl_object_name||pv_crlf||
       'pv_member_col:'||pv_member_col||pv_crlf||
       'pv_member_display_code_col:'||pv_member_display_code_col||pv_crlf||
       'pv_member_name_col:'||pv_member_name_col||pv_crlf||
       'pv_member_desc_col:'||pv_member_desc_col||pv_crlf||
       'pv_attr_table_name:'||pv_attr_table_name||pv_crlf||
       'pv_coa_id:'||pv_coa_id||pv_crlf||
       'pv_gvsc_id:'||pv_gvsc_id||pv_crlf||
       'pv_fem_vs_id:'||pv_fem_vs_id||pv_crlf||
       'pv_ledger_attr_varchar_label:'||pv_ledger_attr_varchar_label||pv_crlf||
       'pv_com_dim_id:'||pv_com_dim_id||pv_crlf||
       'pv_cc_dim_id:'||pv_cc_dim_id||pv_crlf||
       'pv_cctr_org_dim_id:'||pv_cctr_org_dim_id||pv_crlf||
       'pv_dim_mapping_option_code:'||pv_dim_mapping_option_code||pv_crlf||
       'pv_default_member_id:'||pv_default_member_id||pv_crlf||
       'pv_default_member_vsid:'||pv_default_member_vs_id||pv_crlf||
       'pv_segment_count:'||pv_segment_count||pv_crlf||
       'pv_balancing_segment_num:'||pv_balancing_segment_num||pv_crlf||
       'pv_cost_center_segment_num:'||pv_cost_center_segment_num||pv_crlf||
       'pv_natural_account_segment_num:'||pv_natural_account_segment_num||pv_crlf||
       'pv_source_system_code_id:'||pv_source_system_code_id||pv_crlf||
       'pv_max_ccid_processed:'||pv_max_ccid_processed||pv_crlf||
       'pv_max_ccid_to_be_mapped:'||pv_max_ccid_to_be_mapped||pv_crlf||
       'pv_max_ccid_in_map_table:'||pv_max_ccid_in_map_table||pv_crlf||
       'pv_max_flex_value_id_processed:'||pv_max_flex_value_id_processed||pv_crlf||
       'pv_ext_acct_type_attr_id:'||pv_ext_acct_type_attr_id||pv_crlf||
       'pv_ext_acct_attr_version_id:'||pv_ext_acct_attr_version_id||pv_crlf||
       'pv_req_id:'||pv_req_id||pv_crlf||
       'pv_com_vs_id:'||pv_com_vs_id||pv_crlf||
       'pv_cc_vs_id:'||pv_cc_vs_id||pv_crlf||
       'pv_req_id:'||pv_req_id||pv_crlf||
       'pv_pgm_id:'||pv_pgm_id||pv_crlf||
       'pv_pgm_app_id:'||pv_pgm_app_id||pv_crlf||
       'pv_login_id:'||pv_login_id);
       IF pv_mapped_segs.count() = 5
       THEN
         FEM_ENGINES_PKG.Tech_Message
         ( p_severity => pc_log_level_procedure
          ,p_module   => pc_module_name||c_func_name
          ,p_msg_text => 'Map Seg Info Contents'||pv_crlf||
          '-->pv_mapped_segs(1).application_column_name:'||pv_mapped_segs(1).application_column_name||pv_crlf||
          '-->pv_mapped_segs(1).vs_id:'||pv_mapped_segs(1).vs_id||pv_crlf||
          '-->pv_mapped_segs(1).table_validated_flag:'||pv_mapped_segs(1).table_validated_flag||pv_crlf||
          '-->pv_mapped_segs(1).table_name:'||pv_mapped_segs(1).table_name||pv_crlf||
          '-->pv_mapped_segs(1).id_col_name:'||pv_mapped_segs(1).id_col_name||pv_crlf||
          '-->pv_mapped_segs(1).val_col_name:'||pv_mapped_segs(1).val_col_name||pv_crlf||
          '-->pv_mapped_segs(1).compiled_attr_col_name:'||pv_mapped_segs(1).compiled_attr_col_name||pv_crlf||
          '-->pv_mapped_segs(1).meaning_col_name:'||pv_mapped_segs(1).meaning_col_name||pv_crlf||
          '-->pv_mapped_segs(1).where_clause:'||pv_mapped_segs(1).where_clause||pv_crlf||
          '-->pv_mapped_segs(1).dependent_value_set_flag:'||pv_mapped_segs(1).dependent_value_set_flag||pv_crlf||
          '-->pv_mapped_segs(1).dependent_segment_column:'||pv_mapped_segs(1).dependent_segment_column||pv_crlf||
          '-->pv_mapped_segs(1).dependent_vs_id:'||pv_mapped_segs(1).dependent_vs_id||pv_crlf||pv_crlf||

          '-->pv_mapped_segs(2).application_column_name:'||pv_mapped_segs(2).application_column_name||pv_crlf||
          '-->pv_mapped_segs(2).vs_id:'||pv_mapped_segs(2).vs_id||pv_crlf||
          '-->pv_mapped_segs(2).table_validated_flag:'||pv_mapped_segs(2).table_validated_flag||pv_crlf||
          '-->pv_mapped_segs(2).table_name:'||pv_mapped_segs(2).table_name||pv_crlf||
          '-->pv_mapped_segs(2).id_col_name:'||pv_mapped_segs(2).id_col_name||pv_crlf||
          '-->pv_mapped_segs(2).val_col_name:'||pv_mapped_segs(2).val_col_name||pv_crlf||
          '-->pv_mapped_segs(2).compiled_attr_col_name:'||pv_mapped_segs(2).compiled_attr_col_name||pv_crlf||
          '-->pv_mapped_segs(2).meaning_col_name:'||pv_mapped_segs(2).meaning_col_name||pv_crlf||
          '-->pv_mapped_segs(2).where_clause:'||pv_mapped_segs(2).where_clause||pv_crlf||
          '-->pv_mapped_segs(2).dependent_value_set_flag:'||pv_mapped_segs(2).dependent_value_set_flag||pv_crlf||
          '-->pv_mapped_segs(2).dependent_segment_column:'||pv_mapped_segs(2).dependent_segment_column||pv_crlf||
          '-->pv_mapped_segs(2).dependent_vs_id:'||pv_mapped_segs(2).dependent_vs_id||pv_crlf||pv_crlf||

          '-->pv_mapped_segs(3).application_column_name:'||pv_mapped_segs(3).application_column_name||pv_crlf||
          '-->pv_mapped_segs(3).vs_id:'||pv_mapped_segs(3).vs_id||pv_crlf||
          '-->pv_mapped_segs(3).table_validated_flag:'||pv_mapped_segs(3).table_validated_flag||pv_crlf||
          '-->pv_mapped_segs(3).table_name:'||pv_mapped_segs(3).table_name||pv_crlf||
          '-->pv_mapped_segs(3).id_col_name:'||pv_mapped_segs(3).id_col_name||pv_crlf||
          '-->pv_mapped_segs(3).val_col_name:'||pv_mapped_segs(3).val_col_name||pv_crlf||
          '-->pv_mapped_segs(3).compiled_attr_col_name:'||pv_mapped_segs(3).compiled_attr_col_name||pv_crlf||
          '-->pv_mapped_segs(3).meaning_col_name:'||pv_mapped_segs(3).meaning_col_name||pv_crlf||
          '-->pv_mapped_segs(3).where_clause:'||pv_mapped_segs(3).where_clause||pv_crlf||
          '-->pv_mapped_segs(3).dependent_value_set_flag:'||pv_mapped_segs(3).dependent_value_set_flag||pv_crlf||
          '-->pv_mapped_segs(3).dependent_segment_column:'||pv_mapped_segs(3).dependent_segment_column||pv_crlf||
          '-->pv_mapped_segs(3).dependent_vs_id:'||pv_mapped_segs(3).dependent_vs_id||pv_crlf||pv_crlf||

          '-->pv_mapped_segs(4).application_column_name:'||pv_mapped_segs(4).application_column_name||pv_crlf||
          '-->pv_mapped_segs(4).vs_id:'||pv_mapped_segs(4).vs_id||pv_crlf||
          '-->pv_mapped_segs(4).table_validated_flag:'||pv_mapped_segs(4).table_validated_flag||pv_crlf||
          '-->pv_mapped_segs(4).table_name:'||pv_mapped_segs(4).table_name||pv_crlf||
          '-->pv_mapped_segs(4).id_col_name:'||pv_mapped_segs(4).id_col_name||pv_crlf||
          '-->pv_mapped_segs(4).val_col_name:'||pv_mapped_segs(4).val_col_name||pv_crlf||
          '-->pv_mapped_segs(4).compiled_attr_col_name:'||pv_mapped_segs(4).compiled_attr_col_name||pv_crlf||
          '-->pv_mapped_segs(4).meaning_col_name:'||pv_mapped_segs(4).meaning_col_name||pv_crlf||
          '-->pv_mapped_segs(4).where_clause:'||pv_mapped_segs(4).where_clause||pv_crlf||
          '-->pv_mapped_segs(4).dependent_value_set_flag:'||pv_mapped_segs(4).dependent_value_set_flag||pv_crlf||
          '-->pv_mapped_segs(4).dependent_segment_column:'||pv_mapped_segs(4).dependent_segment_column||pv_crlf||
          '-->pv_mapped_segs(4).dependent_vs_id:'||pv_mapped_segs(4).dependent_vs_id||pv_crlf||pv_crlf||

          '-->pv_mapped_segs(5).application_column_name:'||pv_mapped_segs(5).application_column_name||pv_crlf||
          '-->pv_mapped_segs(5).vs_id:'||pv_mapped_segs(5).vs_id||pv_crlf||
          '-->pv_mapped_segs(5).table_validated_flag:'||pv_mapped_segs(5).table_validated_flag||pv_crlf||
          '-->pv_mapped_segs(5).table_name:'||pv_mapped_segs(5).table_name||pv_crlf||
          '-->pv_mapped_segs(5).id_col_name:'||pv_mapped_segs(5).id_col_name||pv_crlf||
          '-->pv_mapped_segs(5).val_col_name:'||pv_mapped_segs(5).val_col_name||pv_crlf||
          '-->pv_mapped_segs(5).compiled_attr_col_name:'||pv_mapped_segs(5).compiled_attr_col_name||pv_crlf||
          '-->pv_mapped_segs(5).meaning_col_name:'||pv_mapped_segs(5).meaning_col_name||pv_crlf||
          '-->pv_mapped_segs(5).where_clause:'||pv_mapped_segs(5).where_clause||pv_crlf||
          '-->pv_mapped_segs(5).dependent_value_set_flag:'||pv_mapped_segs(5).dependent_value_set_flag||pv_crlf||
          '-->pv_mapped_segs(5).dependent_segment_column:'||pv_mapped_segs(5).dependent_segment_column||pv_crlf||
          '-->pv_mapped_segs(5).dependent_vs_id:'||pv_mapped_segs(5).dependent_vs_id||pv_crlf
         );
      END IF;

  END;

-- ======================================================================
-- Procedure
--     UNDO_DIM_RULE
-- Purpose
--     This procedure in package  FEM_INTG_DIM_RULE_ENG_PKG
--  History
--     12-22-05  Gaurav Nayyar  Created
-- Arguments
--     x_errbuf                   Standard Concurrent Program parameter
--     x_retcode                  Standard Concurrent Program parameter
--     p_dim_rule_obj_id          Dimension rule object ID
-- ======================================================================

PROCEDURE UNDO_DIM_RULE (x_errbuf OUT NOCOPY VARCHAR2,
                         x_retcode OUT NOCOPY VARCHAR2,
                         p_dim_rule_obj_id IN NUMBER)
IS

  l_func_name  CONSTANT         VARCHAR2(30) := '.UNDO_DIM_RULE';
  l_chart_of_accounts_id NUMBER;
  l_global_vs_combo_id NUMBER;
  l_obj_id NUMBER;
  l_obj_def_id NUMBER;
  l_intercomp_obj_id NUMBER;
  l_intercomp_obj_def_id NUMBER;
  l_dim_id Number;
  l_dim_mapping_Option_code VARCHAR2(32);
  l_request_id Number;
  l_memb_b_tab_name VARCHAR2(64);
  l_memb_tl_tab_name VARCHAR2(64);
  l_hier_tab_name VARCHAR2(64);
  l_attr_tab_name VARCHAR2(64);
  l_memb_col_name VARCHAR2(64);
  l_value_set_id NUMBER;
  comp_val_set_id NUMBER;
  cctr_val_set_id NUMBER;
  l_found_hier_flag BOOLEAN :=true;
  temp_query VARCHAR2(256);
  l_gvsc_exist_flag BOOLEAN :=true;
  temp_stmt VARCHAR2(256);
  dummy_val NUMBER;
  count1 NUMBER;

  TYPE refcursor IS REF CURSOR;
  exec_cur refcursor;

  Cursor BalRuleExec(c_charts_of_account_id NUMBER) IS
          SELECT 1 FROM fem_pl_object_executions
              WHERE object_id
              IN  (SELECT BAL_RULE_OBJ_ID
                   FROM fem_intg_bal_rules
                   WHERE chart_of_accounts_id =c_charts_of_account_id );

  Cursor FemDataExists(c_gvsc_id NUMBER) IS
         SELECT 1
         FROM fem_data_locations fdl,
              fem_ledgers_attr fla,
              fem_dim_attributes_b fdab,
              fem_dim_attr_versions_b fdavb
         WHERE fdab.attribute_varchar_label = 'GLOBAL_VS_COMBO'
         AND   fdavb.attribute_id = fdab.attribute_id
         AND   fdavb.default_version_flag = 'Y'
         AND   fla.attribute_id = fdab.attribute_id
         AND   fla.version_id = fdavb.version_id
         AND   fla.dim_attribute_numeric_member = c_gvsc_id
         AND   fdl.ledger_id = fla.ledger_id
         AND   fdl.table_name <> 'FEM_BALANCES';

  Cursor GVSCExistsForFemValueSet(c_gvsc_id Number,
                                  c_dim_id Number,
                                  c_val_set_id Number)
          IS
          select 1 from fem_global_vs_combo_defs
                   where global_vs_combo_id <> c_gvsc_id
                   and dimension_id = c_dim_id
                   and value_set_id = c_val_set_id ;

BEGIN

FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => pc_module_name || l_func_name,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_201',
       p_token1   => 'FUNC_NAME',
       p_value1   => 'FEM_INTG_DIM_RULE_ENG_PKG.UNDO_DIM_RULE',
       p_token2   => 'TIME',
       p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

-- retrieving the chart of accounts,dimension id for dimension rule
  SELECT chart_of_accounts_id,
         dimension_id
  INTO l_chart_of_accounts_id,
       l_dim_id
  FROM fem_intg_dim_rules
  WHERE dim_rule_obj_id = p_dim_rule_obj_id;

-- retrieving the global value set combination id for chart of accounts

  SELECT GLOBAL_VS_COMBO_ID
  INTO l_global_vs_combo_id
  FROM fem_intg_coa_gvsc_map
  WHERE chart_of_accounts_id = l_chart_of_accounts_id;

-- get the object definition id for the dimension rule object id passed in

  SELECT object_definition_id
        INTO l_obj_def_id
  FROM fem_object_definition_b
  WHERE object_id = p_dim_rule_obj_id ;

FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => pc_module_name || l_func_name,
       p_msg_text => 'l_chart_of_accounts_id:= ' || l_chart_of_accounts_id
                     ||' l_global_vs_combo_id := ' || l_global_vs_combo_id
                     ||' object_id:= '|| p_dim_rule_obj_id
                     ||' object_definition_id:= ' || l_obj_def_id);


-- getting the dimension mapping option

  SELECT dim_mapping_Option_code
  INTO l_dim_mapping_Option_code
  FROM fem_intg_dim_rule_defs
  WHERE dim_rule_obj_def_id = l_obj_def_id;

FEM_ENGINES_PKG.Tech_Message
       (p_severity => pc_log_level_statement,
       p_module   => pc_module_name || l_func_name,
       p_msg_text => 'l_dim_mapping_Option_code:'|| l_dim_mapping_Option_code);

-- getting the table and column name for the dimension

  SELECT MEMBER_B_TABLE_NAME,
         MEMBER_TL_TABLE_NAME,
         HIERARCHY_TABLE_NAME,
         ATTRIBUTE_TABLE_NAME,
         MEMBER_COL
  INTO l_memb_b_tab_name,
       l_memb_tl_tab_name,
       l_hier_tab_name,
       l_attr_tab_name,
       l_memb_col_name
  FROM fem_xdim_dimensions
  WHERE dimension_id = l_dim_id;

FEM_ENGINES_PKG.Tech_Message
       (p_severity => pc_log_level_statement,
       p_module   => pc_module_name || l_func_name,
       p_msg_text => 'dimension_id:' || l_dim_id ||
                      'MEMBER_B_TABLE_NAME:=' || l_memb_b_tab_name ||
                      'MEMBER_TL_TABLE_NAME:=' || l_memb_tl_tab_name ||
                      'HIERARCHY_TABLE_NAME:=' || l_hier_tab_name ||
                      'ATTRIBUTE_TABLE_NAME:=' || l_attr_tab_name ||
                      'MEMBER_COL:=' || l_memb_col_name);

IF (l_dim_mapping_Option_code = 'SINGLESEG' OR l_dim_mapping_Option_code = 'MULTISEG') THEN

     SELECT value_set_id
     INTO l_value_set_id
     FROM fem_global_vs_combo_defs
     WHERE global_vs_combo_Id = l_global_vs_combo_id
     and dimension_id = l_dim_id;

     FEM_ENGINES_PKG.Tech_Message
       (p_severity => pc_log_level_statement,
       p_module   => pc_module_name || l_func_name,
       p_msg_text => 'l_value_set_id:'|| l_value_set_id);

    IF(l_dim_id = 8) THEN

        SELECT value_set_id
        INTO comp_val_set_id
        FROM fem_global_vs_combo_defs
        WHERE dimension_id =112
        AND global_vs_combo_Id = l_global_vs_combo_id;

        SELECT value_set_id
        INTO cctr_val_set_id
        FROM fem_global_vs_combo_defs
        WHERE dimension_id =113
        AND global_vs_combo_Id = l_global_vs_combo_id;
    END IF;

END IF;

-- For organization dimension get object_id and object_definition_id for intercompany dimension rule
IF(l_dim_id = 8) THEN

    SELECT odb.object_id,odb.object_definition_id
    INTO l_intercomp_obj_id,l_intercomp_obj_def_id
    FROM fem_object_definition_b odb,
         fem_intg_dim_rules idr
    WHERE odb.object_id = idr.dim_rule_obj_id
    And idr.chart_of_accounts_id = l_chart_of_accounts_id
    AND idr.dimension_id = 0;

    FEM_ENGINES_PKG.Tech_Message
       (p_severity => pc_log_level_statement,
        p_module   => pc_module_name || l_func_name,
        p_msg_text => 'l_intercomp_obj_id:'|| l_intercomp_obj_id ||
                      'l_intercomp_obj_def_id:'|| l_intercomp_obj_def_id);

END IF;

-- if Balance rule executed for ledger then error

OPEN BalRuleExec(l_chart_of_accounts_id);
FETCH BalRuleExec INTO count1;
IF BalRuleExec%FOUND THEN
    close BalRuleExec;
    -- throw error out
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_unexpected,
         p_module   => pc_module_name || l_func_name ,
         p_msg_name => 'FEM_INTG_DIM_RULE_POST_05');

    x_retcode:=2;
    x_errbuf:=FND_MESSAGE.Get_String('FEM', 'FEM_INTG_DIM_RULE_POST_05');

    FEM_ENGINES_PKG.User_Message
    (p_app_name => 'FEM',
     p_msg_text => x_errbuf);

    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => pc_module_name || l_func_name,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_203',
       p_token1   => 'FUNC_NAME',
       p_value1   => 'FEM_INTG_DIM_RULE_ENG_PKG.UNDO_DIM_RULE',
       p_token2   => 'TIME',
       p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

    return;
ELSE
    close BalRuleExec;
END IF;


OPEN FemDataExists(l_global_vs_combo_id);
FETCH FemDataExists INTO count1;
IF FemDataExists%FOUND THEN
    close FemDataExists;
    -- throw error out
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_unexpected,
         p_module   => pc_module_name || l_func_name ,
         p_msg_name => 'FEM_INTG_DIM_RULE_POST_03');

    x_retcode:=2;
    x_errbuf:=FND_MESSAGE.Get_String('FEM', 'FEM_INTG_DIM_RULE_POST_03');

    FEM_ENGINES_PKG.User_Message
    (p_app_name => 'FEM',
     p_msg_text => x_errbuf);

    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => pc_module_name || l_func_name,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_203',
       p_token1   => 'FUNC_NAME',
       p_value1   => 'FEM_INTG_DIM_RULE_ENG_PKG.UNDO_DIM_RULE',
       p_token2   => 'TIME',
       p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

    return;
ELSE
    close FemDataExists;
END IF;




FEM_ENGINES_PKG.User_Message
    (p_app_name => 'FEM',
     p_msg_name => 'FEM_INTG_DIM_RULE_POST_01');

-- getting the max reuest ID

SELECT max(o.request_id)
INTO l_request_id
FROM fem_pl_object_executions o
WHERE o.display_flag = 'Y'
AND o.object_id = p_dim_rule_obj_id;

FEM_ENGINES_PKG.Tech_Message
       (p_severity => pc_log_level_statement,
       p_module   => pc_module_name || l_func_name,
       p_msg_text => 'Most recent request Id ' || l_request_id || ' for object id ' || p_dim_rule_obj_id);


-- Starting the concurrent program FEM_UNDO_OBJ_EXEC

l_request_id := fnd_request.submit_request
                      (application => 'FEM',
                       program => 'FEM_UNDO_OBJ_EXEC',
                       sub_request => FALSE,
                       argument1 => to_char(p_dim_rule_obj_id),
                       argument2 => to_char(l_request_id),
                       argument3 => 1100,
                       argument4 => 'Y',
                       argument5 => 'N');

FEM_ENGINES_PKG.User_Message
    (p_app_name => 'FEM',
     p_msg_name => 'FEM_INTG_DIM_RULE_POST_02',
     p_token1 => 'DIM_RULE_OBJ_ID',
     p_value1 => p_dim_rule_obj_id);

FEM_ENGINES_PKG.Tech_Message
       (p_severity => pc_log_level_statement,
       p_module   => pc_module_name || l_func_name,
       p_msg_name => 'FEM_INTG_DIM_RULE_POST_02',
       p_token1 => 'DIM_RULE_OBJ_ID',
       p_value1 => p_dim_rule_obj_id);

-- Updating the FEM_INTG_OGL_CCID_MAP

IF (l_dim_id <> 29) THEN

    FEM_ENGINES_PKG.Tech_Message
       (p_severity => pc_log_level_statement,
       p_module   => pc_module_name || l_func_name,
       p_msg_text => 'Updating FEM_INTG_OGL_CCID_MAP setting ' || l_memb_col_name || ' to -1');

    temp_stmt:= 'UPDATE fem_intg_ogl_ccid_map
                  SET ' || l_memb_col_name ||' =-1 ' ;

    IF (l_dim_id = 8) THEN
        temp_stmt := temp_stmt || ' ,INTERCOMPANY_ID=-1 ';
    END IF;

    IF (l_dim_id = 2) THEN
        temp_stmt := temp_stmt || ' ,EXTENDED_ACCOUNT_TYPE=-1 ';
    END IF;

    temp_stmt := temp_stmt || ' WHERE GLOBAL_VS_COMBO_ID =:1 ' ;

    FEM_ENGINES_PKG.Tech_Message
       (p_severity => pc_log_level_statement,
        p_module   => pc_module_name || l_func_name,
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_204',
        p_token1   => 'VAR_NAME',
        p_value1   => 'temp_stmt',
        p_token2   => 'VAR_VAL',
        p_value2   => temp_stmt);

    EXECUTE IMMEDIATE temp_stmt
    USING l_global_vs_combo_id;

END IF;

-- Updating the fem_global_vs_combo_defs

FEM_ENGINES_PKG.Tech_Message
   (p_severity => pc_log_level_statement,
   p_module   => pc_module_name || l_func_name,
   p_msg_text => 'Updating fem_global_vs_combo_defs setting value_set_id to -1 ');

IF (l_dim_id = 8) THEN
   UPDATE fem_global_vs_combo_defs
   SET value_set_id = -1
   WHERE global_vs_combo_id = l_global_vs_combo_id
   AND dimension_id in (8,112,113);
ELSE
   UPDATE fem_global_vs_combo_defs
   SET value_set_id = -1
   WHERE global_vs_combo_id = l_global_vs_combo_id
   AND dimension_id = l_dim_id;
END IF;

-- updating the dimension rule defs.

FEM_ENGINES_PKG.Tech_Message
   (p_severity => pc_log_level_statement,
   p_module   => pc_module_name || l_func_name,
   p_msg_text => 'Updating fem_intg_dim_rule_defs setting MAX_CCID_PROCESSED,MAX_FLEX_VALUE_ID_PROCESSED,FEM_VALUE_SET_ID to null ');

UPDATE fem_intg_dim_rule_defs
SET MAX_CCID_PROCESSED = null,
MAX_FLEX_VALUE_ID_PROCESSED = null,
FEM_VALUE_SET_ID = null
WHERE DIM_RULE_OBJ_DEF_ID = l_obj_def_id;

-- set intercompany dimension rule definition  values if dimension is organization

IF(l_dim_id = 8) THEN
  FEM_ENGINES_PKG.Tech_Message
     (p_severity => pc_log_level_statement,
     p_module   => pc_module_name || l_func_name,
     p_msg_text => 'Updating fem_intg_dim_rule_defs setting DEFAULT_MEMBER_ID,DEFAULT_MEMBER_VALUE_SET_ID to null for intercompany dimension');

  UPDATE fem_intg_dim_rule_defs
  SET MAX_CCID_PROCESSED = null,
  MAX_FLEX_VALUE_ID_PROCESSED = null,
  FEM_VALUE_SET_ID = null,
  DEFAULT_MEMBER_ID = null,
  DEFAULT_MEMBER_VALUE_SET_ID = null
  WHERE DIM_RULE_OBJ_DEF_ID = l_intercomp_obj_def_id;

END IF;

x_retcode:=0;

IF (l_dim_mapping_Option_code = 'SINGLESEG' OR l_dim_mapping_Option_code = 'MULTISEG') THEN

    -- no other global value set combination exists
    -- that uses this fem value set


    OPEN GVSCExistsForFemValueSet(l_global_vs_combo_id,l_dim_id,l_value_set_id);
    FETCH GVSCExistsForFemValueSet INTO dummy_val;
    IF GVSCExistsForFemValueSet%NOTFOUND THEN
        close GVSCExistsForFemValueSet;
        l_gvsc_exist_flag := false;
        FEM_ENGINES_PKG.Tech_Message
          (p_severity => pc_log_level_statement,
           p_module   => pc_module_name || l_func_name,
           p_msg_text => 'NO global value set combination exists for value set:= ' || l_value_set_id);
    ELSE
        close GVSCExistsForFemValueSet;
    END IF;


    -- no hierarchy exists that uses this fem value set

      temp_query := 'SELECT 1 from ' || l_hier_tab_name ||
                   ' WHERE parent_value_set_id =:1 OR child_value_set_id =:2 ';

      OPEN exec_cur FOR temp_query using l_value_set_id,l_value_set_id;


      FETCH exec_cur INTO dummy_val;
      IF exec_cur%NOTFOUND THEN
        close exec_cur;
        l_found_hier_flag := false;

        FEM_ENGINES_PKG.Tech_Message
          (p_severity => pc_log_level_statement,
           p_module   => pc_module_name || l_func_name,
           p_msg_text => 'no hierarchy exists that uses this fem value set');
      ELSE
         close exec_cur;
      END IF;

    IF(NOT l_gvsc_exist_flag  AND NOT l_found_hier_flag) THEN

        temp_query := 'Delete from ' || l_memb_b_tab_name ||
                      ' where value_set_id =:1 ';

       FEM_ENGINES_PKG.Tech_Message
         (p_severity => pc_log_level_statement,
          p_module   => pc_module_name || l_func_name,
          p_app_name => 'FEM',
          p_msg_name => 'FEM_GL_POST_204',
          p_token1   => 'VAR_NAME',
          p_value1   => 'temp_query',
          p_token2   => 'VAR_VAL',
          p_value2   => temp_query);

        EXECUTE IMMEDIATE temp_query using l_value_set_id;

        temp_query := 'Delete from ' || l_memb_tl_tab_name ||
                      ' where value_set_id =:1 ';

       FEM_ENGINES_PKG.Tech_Message
         (p_severity => pc_log_level_statement,
          p_module   => pc_module_name || l_func_name,
          p_app_name => 'FEM',
          p_msg_name => 'FEM_GL_POST_204',
          p_token1   => 'VAR_NAME',
          p_value1   => 'temp_query',
          p_token2   => 'VAR_VAL',
          p_value2   => temp_query);

        EXECUTE IMMEDIATE temp_query using l_value_set_id;

        temp_query := 'Delete from ' || l_attr_tab_name ||
                      ' where value_set_id =:1 ';

       FEM_ENGINES_PKG.Tech_Message
         (p_severity => pc_log_level_statement,
          p_module   => pc_module_name || l_func_name,
          p_app_name => 'FEM',
          p_msg_name => 'FEM_GL_POST_204',
          p_token1   => 'VAR_NAME',
          p_value1   => 'temp_query',
          p_token2   => 'VAR_VAL',
          p_value2   => temp_query);

        EXECUTE IMMEDIATE temp_query using l_value_set_id;

        -- removing the rows for value sets
        FEM_ENGINES_PKG.Tech_Message
          (p_severity => pc_log_level_statement,
           p_module   => pc_module_name || l_func_name ,
           p_msg_text => 'removing the rows for value sets');

        delete from fem_value_sets_b where value_set_id = l_value_set_id;
        delete from fem_value_sets_tl where value_set_id = l_value_set_id;

        IF (l_dim_id = 8) THEN

          -- retriveing company value set_id for the retrieved global_value_set_id

             IF (comp_val_set_id<>-1 AND comp_val_set_id<>112) THEN
               FEM_ENGINES_PKG.Tech_Message
                  (p_severity => pc_log_level_statement,
                   p_module   => pc_module_name || l_func_name ,
                   p_msg_text => 'deleting the company value sets');

                DELETE FROM FEM_COMPANIES_B WHERE value_set_id = comp_val_set_id;
                DELETE FROM FEM_COMPANIES_TL WHERE value_set_id = comp_val_set_id;
                DELETE FROM FEM_COMPANIES_ATTR WHERE value_set_id = comp_val_set_id;

                -- deleting the company value sets

                delete from fem_value_sets_b where value_set_id = comp_val_set_id;
	        delete from fem_value_sets_tl where value_set_id = comp_val_set_id;

		delete from fem_intg_aol_valset_map where fem_value_set_id = comp_val_set_id;


          END IF;

          -- retriveing cost center value set_id for the retrieved global_value_set_id

           IF (cctr_val_set_id<>-1 AND cctr_val_set_id<>113) THEN
               FEM_ENGINES_PKG.Tech_Message
                  (p_severity => pc_log_level_statement,
                   p_module   => pc_module_name || l_func_name ,
                   p_msg_text => 'deleting the cost center value sets');

                DELETE FROM FEM_COST_CENTERS_B WHERE value_set_id = cctr_val_set_id;
                DELETE FROM FEM_COST_CENTERS_TL WHERE value_set_id = cctr_val_set_id;
                DELETE FROM FEM_COST_CENTERS_ATTR WHERE value_set_id = cctr_val_set_id;

                -- deleting the cost center value sets
               delete from fem_value_sets_b where value_set_id = cctr_val_set_id;
	       delete from fem_value_sets_tl where value_set_id = cctr_val_set_id;

		delete from fem_intg_aol_valset_map where fem_value_set_id = cctr_val_set_id;


          END IF;

        END IF;

        -- remove row from fem_intg_aol_valset_map
        FEM_ENGINES_PKG.Tech_Message
          (p_severity => pc_log_level_statement,
           p_module   => pc_module_name || l_func_name ,
           p_msg_text => 'removing row from fem_intg_aol_valset_map');

        delete from fem_intg_aol_valset_map  where fem_value_set_id = l_value_set_id;

    ELSE
      IF(l_gvsc_exist_flag) THEN
          x_errbuf:= FND_MESSAGE.Get_String('FEM', 'FEM_INTG_DIM_RULE_POST_03');
      ELSIF (l_found_hier_flag) THEN
          x_errbuf:= FND_MESSAGE.Get_String('FEM', 'FEM_INTG_DIM_RULE_POST_04');
      END IF;

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_exception,
         p_module   => pc_module_name || l_func_name ,
         p_msg_text => x_errbuf);

      FEM_ENGINES_PKG.User_Message
        (p_app_name => 'FEM',
         p_msg_text => x_errbuf);

      x_retcode:=1;

    END IF;

END IF;

FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_procedure,
         p_module   => pc_module_name || l_func_name ,
         p_msg_name => 'FEM_GL_POST_202',
         p_token1 => 'FUNC_NAME',
         p_value1 => 'FEM_INTG_DIM_RULE_ENG_PKG.UNDO_DIM_RULE',
         p_token2 => 'TIME',
         p_value2 => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

EXCEPTION

  WHEN OTHERS THEN
      ROLLBACK;

      x_retcode:=2;
      x_errbuf:=SQLERRM;

    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_exception,
       p_module   => pc_module_name || l_func_name,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_215',
       p_token1   => 'ERR_MSG',
       p_value1   => SQLERRM);

    FEM_ENGINES_PKG.User_Message
      (p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_215',
       p_token1   => 'ERR_MSG',
       p_value1   => SQLERRM);

    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => pc_module_name || l_func_name,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_203',
       p_token1   => 'FUNC_NAME',
       p_value1   => 'FEM_INTG_DIM_RULE_ENG_PKG.UNDO_DIM_RULE',
       p_token2   => 'TIME',
       p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));


END UNDO_DIM_RULE;

--bugfix 8780516
-- ======================================================================
-- Procedure
--     SUBMIT_ALL_DIM_HIER_RULES
-- Purpose
--     To support execution of all the dimension and hierarchy rules
--     for a particular chart of accounts
--  History
--     05-15-07  Harish Kumar  Created for bugfix5892771
-- Arguments
--     x_errbuf                   Standard Concurrent Program parameter
--     x_retcode                  Standard Concurrent Program parameter
--     p_coa_id                   Chart of Accounts ID
-- ======================================================================
  PROCEDURE SUBMIT_ALL_DIM_HIER_RULES (x_errbuf  OUT NOCOPY  VARCHAR2,
                                       x_retcode OUT NOCOPY VARCHAR2,
                                       p_coa_id  IN NUMBER)
  IS
    v_request_id             NUMBER;
    v_cctr_org_request_id    NUMBER;
    v_dim_rule_req_count     NUMBER;
    v_hier_rule_obj_def_id   NUMBER;
    v_dim_rule_obj_def_list  DBMS_SQL.NUMBER_TABLE;
    --v_dim_rule_obj_list      DBMS_SQL.NUMBER_TABLE;
    v_dim_rule_dim_list      DBMS_SQL.NUMBER_TABLE;
    l_func_name  CONSTANT    VARCHAR2(30) := '.SUBMIT_ALL_DIM_HIER_RULES';

    CURSOR c_dim_rules(p_coa_id NUMBER)
        IS
    SELECT fodb.object_definition_id,
           --idr.dim_rule_obj_id,
           idr.dimension_id
      FROM fem_intg_dim_rules idr,
           fem_object_definition_b fodb
     WHERE fodb.object_id = idr.dim_rule_obj_id
       AND idr.chart_of_accounts_id = p_coa_id
       AND idr.dimension_id <> 0;

    CURSOR c_hier_rule_versions (p_dim_rule_obj_def_id NUMBER)
        IS
    SELECT fodb.object_definition_id
      FROM fem_intg_hier_rules ihr,
           fem_object_definition_b fodb
     WHERE ihr.dim_rule_obj_def_id = p_dim_rule_obj_def_id
       AND ihr.hier_rule_obj_id = fodb.object_id ;

  BEGIN

       FEM_ENGINES_PKG.Tech_Message(
         p_severity => pc_log_level_procedure,
         p_module   => pc_module_name || l_func_name || '.begin',
         p_msg_text => '<< Start of dimension and hierarchy rules program execution >>'
       );

       FEM_ENGINES_PKG.User_Message(
          p_app_name => 'FEM',
          p_msg_text => '<< Start of dimension and hierarchy rules program execution >>'
        );

    -- Get dimension rules for given chart of account
    OPEN c_dim_rules(p_coa_id);
    FETCH c_dim_rules BULK COLLECT INTO v_dim_rule_obj_def_list,
                                        --v_dim_rule_obj_list,
                                        v_dim_rule_dim_list;

    IF (v_dim_rule_obj_def_list.FIRST IS NOT NULL AND v_dim_rule_obj_def_list.LAST IS NOT NULL) THEN

      -- Submit dimension rule request for each of the dimension rules
      FOR i IN v_dim_rule_obj_def_list.FIRST..v_dim_rule_obj_def_list.LAST LOOP
        v_request_id := FND_REQUEST.submit_request( application => 'FEM',
                                                    program     => 'FEM_INTG_DIM_RULE_ENGINE',
                                                    sub_request => FALSE,
                                                    argument1   => v_dim_rule_obj_def_list(i),
                                                    argument2   => 'MEMBER');
        IF (v_dim_rule_dim_list(i) = 8) THEN
          v_cctr_org_request_id := v_request_id;
        END IF;

        FEM_ENGINES_PKG.Tech_Message(
          p_severity => pc_log_level_statement,
          p_module   => pc_module_name || l_func_name || '.begin',
          p_msg_text => 'Submitted request '||v_request_id||'for dimension rule '||v_dim_rule_obj_def_list(i)
        );

      END LOOP;
      COMMIT;

      LOOP
        BEGIN
            SELECT 1
              INTO v_dim_rule_req_count
              FROM dual
             WHERE EXISTS (
                            SELECT 1
                              FROM fnd_concurrent_programs fcp,
                                   fnd_concurrent_requests fcr,
                                   fem_intg_dim_rules idr,
                                   fem_object_definition_b fodb
                             WHERE fcp.concurrent_program_id = fcr.concurrent_program_id
                               AND fcp.application_id = fcr.program_application_id
                               AND fcp.application_id = 274
                               AND fcp.concurrent_program_name = 'FEM_INTG_DIM_RULE_ENGINE'
                               AND fcr.request_id > v_cctr_org_request_id
                               AND fcr.phase_code = 'C'
                               AND idr.dim_rule_obj_id = fodb.object_id
                               AND idr.chart_of_accounts_id = p_coa_id
                               AND idr.dimension_id = 0
                               AND fcr.argument1 = fodb.object_definition_id
                               AND fcr.argument2 = 'MEMBER');
            -- If the intercompany rule is completed then exit
            EXIT;

            EXCEPTION WHEN NO_DATA_FOUND THEN
                           DBMS_LOCK.SLEEP(pc_sleep_second);
        END;
      END LOOP;


      -- Retrieve hierarchy rules for above dimension rules
      -- and submit hierarchy rules requests
      FOR j IN v_dim_rule_obj_def_list.FIRST..v_dim_rule_obj_def_list.LAST LOOP

        v_hier_rule_obj_def_id := null;

        OPEN c_hier_rule_versions(v_dim_rule_obj_def_list(j));
        FETCH c_hier_rule_versions INTO v_hier_rule_obj_def_id;

        IF (v_hier_rule_obj_def_id IS NOT NULL) THEN
          v_request_id := FND_REQUEST.submit_request( application => 'FEM',
                                                      program     => 'FEM_INTG_HIER_RULE_ENGINE',
                                                      sub_request => FALSE,
                                                      argument1   => v_hier_rule_obj_def_id);
          FEM_ENGINES_PKG.Tech_Message(
            p_severity => pc_log_level_statement,
            p_module   => pc_module_name || l_func_name || '.begin',
            p_msg_text => 'Submitted request '||v_request_id||'for hierarchy rule '||v_hier_rule_obj_def_id
           );

        END IF;
        CLOSE c_hier_rule_versions;
      END LOOP;

    END IF;

    CLOSE c_dim_rules;
    COMMIT;

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_procedure,
      p_module   => pc_module_name || l_func_name || '.end',
      p_msg_text => '<< End of dimension and hierarchy rules program execution >>'
    );

    FEM_ENGINES_PKG.User_Message(
       p_app_name => 'FEM',
       p_msg_text => '<< End of dimension and hierarchy rules program execution >>'
     );

  END;
--end bugfix

END;

/
