--------------------------------------------------------
--  DDL for Package Body FEM_INTG_NEW_DIM_MEMBER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_INTG_NEW_DIM_MEMBER_PKG" AS
/* $Header: fem_intg_dimmemb.plb 120.15.12010000.4 2009/11/17 00:42:09 arastogi ship $ */
   pc_log_level_statement     CONSTANT NUMBER := FND_LOG.level_statement;
   pc_log_level_procedure     CONSTANT NUMBER := FND_LOG.level_procedure;
   pc_log_level_event         CONSTANT NUMBER := FND_LOG.level_event;
   pc_log_level_exception     CONSTANT NUMBER := FND_LOG.level_exception;
   pc_log_level_error         CONSTANT NUMBER := FND_LOG.level_error;
   pc_log_level_unexpected    CONSTANT NUMBER := FND_LOG.level_unexpected;
   pc_module_name             CONSTANT VARCHAR2(100)
                                := 'fem.plsql.fem_intg_new_dim_member_pkg';
   pc_loop_counter_max        CONSTANT NUMBER := 50;
   pc_sleep_second            CONSTANT NUMBER := 10;
   pc_lock_timeout            CONSTANT INTEGER := 1;
   pc_lockmode                CONSTANT INTEGER := 6;
   pc_expiration_secs         CONSTANT INTEGER := 6;
   pc_release_on_commit       CONSTANT BOOLEAN := TRUE;

   pv_progress                VARCHAR2(100);
   pv_crlf            CONSTANT VARCHAR2(1) := '';

   pv_user_id               CONSTANT NUMBER := FND_GLOBAL.User_Id;
   pv_login_id              CONSTANT NUMBER := FND_GLOBAL.Login_Id;

   pv_dim_id                NUMBER;
   pv_dim_vs_id             NUMBER;

   --bugfix 8780516
   NonNullFlag              BOOLEAN;

   -- start bug fix 5377544
   pv_batch_size            CONSTANT NUMBER := 10000;
   --PROCEDURE Check_All_CCIDS_Mapped(x_result OUT NOCOPY VARCHAR2);
   -- end bug fix 5377544
   --bugfix 8780516
  FUNCTION get_signage(p_ext_acct_type_code VARCHAR2) RETURN NUMBER
  IS
    v_signage_value NUMBER;
  BEGIN
    SELECT feata.number_assign_value
    INTO v_signage_value
    FROM fem_dim_attributes_b dab,
         fem_dim_attr_versions_b davb,
         fem_ext_acct_types_attr feata
    WHERE dab.attribute_varchar_label = 'SIGN'
    AND davb.attribute_id = dab.attribute_id
    AND davb.default_version_flag = 'Y'
    AND feata.ext_account_type_code = p_ext_acct_type_code
    AND feata.attribute_id = dab.attribute_id
    AND feata.version_id = davb.version_id;

    return v_signage_value;
  EXCEPTION
    WHEN OTHERS THEN
      return null;
  END get_signage;


  /* ======================================================================
    Procedure
      Populate_Dimension_Attribute
    Purpose
      This routine populates dimension attributes. It constructs MERGE
      statements dynamically based on various factors, e.g. mapping method,
      a type associated value set, dimension, and etc.

      The following is a sample dynamic MERGE statement for Natural Account
      dimension, Single Detail level segment, Independent value set:

        MERGE INTO FEM_NAT_ACCTS_ATTR ATTR
        USING (
          SELECT
            A.ATTRIBUTE_ID,
            AV.VERSION_ID,
            M.NATURAL_ACCOUNT_ID,
            :pv_fem_vs_id VALUE_SET_ID,
            NULL DIM_ATTRIBUTE_VALUE_SET_ID,
             DECODE(
               A.ATTRIBUTE_VARCHAR_LABEL,
               'SOURCE_SYSTEM_CODE', :pv_source_system_code_id,
               NULL
             ) DIM_ATTRIBUTE_NUMERIC_MEMBER,
             DECODE(
               A.ATTRIBUTE_VARCHAR_LABEL,
               'EXTENDED_ACCOUNT_TYPE',
               DECODE(
                 SUBSTR(
                   FND_GLOBAL.NEWLINE ||
                   V.COMPILED_VALUE_ATTRIBUTES ||
                   FND_GLOBAL.NEWLINE,
                   INSTR(
                     FND_GLOBAL.NEWLINE ||
                     V.COMPILED_VALUE_ATTRIBUTES ||
                     FND_GLOBAL.NEWLINE,
                     FND_GLOBAL.NEWLINE,
                     1, :v_account_type_pos
                   )+1,
                   1
                 ),
                 'A', 'ASSET',
                 'E', 'EXPENSE',
                 'R', 'REVENUE',
                 'L', 'LIABILITY',
                 'O', 'EQUITY',
		 --bugfix 8780516
                 'D', 'BUDGETARY_DEBIT',
                 'C', 'BUDGETARY_CREDIT'
               ),
               'BUDGET_ALLOWED_FLAG',
               SUBSTR(
                 FND_GLOBAL.NEWLINE ||
                 V.COMPILED_VALUE_ATTRIBUTES ||
                 FND_GLOBAL.NEWLINE,
                 INSTR(
                   FND_GLOBAL.NEWLINE ||
                   V.COMPILED_VALUE_ATTRIBUTES ||
                   FND_GLOBAL.NEWLINE,
                   FND_GLOBAL.NEWLINE,
                   1, :v_budget_pos
                 )+1,
                 1
               ),
               'NAT_ACCT_EXPENSE_TYPE_CODE', 'FIXED',
               'INVENTORIABLE_FLAG', 'N',
               'RECON_LEAF_NODE_FLAG', :v_leaf_flag,
               NULL
             ) DIM_ATTRIBUTE_VARCHAR_MEMBER,

            1 OBJECT_VERSION_NUMBER,
            'N' AW_SNAPSHOT_FLAG,
            'Y' READ_ONLY_FLAG,
            :b_sysdate CREATION_DATE,
            :pv_user_id CREATED_BY,
            :b_sysdate LAST_UPDATE_DATE,
            :pv_user_id LAST_UPDATED_BY,
            :pv_login_id LAST_UPDATE_LOGIN
          FROM
            FEM_NAT_ACCTS_B M,
          FND_FLEX_VALUES V,
            FEM_DIM_ATTRIBUTES_B A,
            FEM_DIM_ATTR_VERSIONS_B AV
          WHERE
            M.VALUE_SET_ID = :b_driving_where_vs_id ||
                             :b_m_vs_id || :b_gt_dim_id AND
              V.FLEX_VALUE_SET_ID = :b_flex_value_where_vs_id1 AND
              V.FLEX_VALUE = M.NATURAL_ACCOUNT_DISPLAY_CODE ||
                             :b_flex_value_where_vs_id2 AND
            A.DIMENSION_ID = :b_a_dim_id AND
            AV.ATTRIBUTE_ID = A.ATTRIBUTE_ID AND
            AV.DEFAULT_VERSION_FLAG = 'Y' || :b_pv_gvsc_id || :b_pv_dim_id AND
            A.ATTRIBUTE_VARCHAR_LABEL IN (
              'SOURCE_SYSTEM_CODE',
              'EXTENDED_ACCOUNT_TYPE',
              'BUDGET_ALLOWED_FLAG',
              'NAT_ACCT_EXPENSE_TYPE_CODE',
              'INVENTORIABLE_FLAG',
              'RECON_LEAF_NODE_FLAG'
            )
        ) S
        ON (
          ATTR.ATTRIBUTE_ID = S.ATTRIBUTE_ID AND
          ATTR.VERSION_ID = S.VERSION_ID AND
          ATTR.NATURAL_ACCOUNT_ID = S.NATURAL_ACCOUNT_ID AND
          ATTR.VALUE_SET_ID = S.VALUE_SET_ID
        )
        WHEN MATCHED THEN UPDATE
          SET ATTR.LAST_UPDATE_DATE = SYSDATE
        WHEN NOT MATCHED THEN INSERT (
          ATTR.ATTRIBUTE_ID,
          ATTR.VERSION_ID,
          ATTR.NATURAL_ACCOUNT_ID,
          ATTR.VALUE_SET_ID,
          ATTR.DIM_ATTRIBUTE_VALUE_SET_ID,
          ATTR.DIM_ATTRIBUTE_NUMERIC_MEMBER,
          ATTR.DIM_ATTRIBUTE_VARCHAR_MEMBER,
          ATTR.OBJECT_VERSION_NUMBER,
          ATTR.AW_SNAPSHOT_FLAG,
          ATTR.READ_ONLY_FLAG,
          ATTR.CREATION_DATE,
          ATTR.CREATED_BY,
          ATTR.LAST_UPDATE_DATE,
          ATTR.LAST_UPDATED_BY,
          ATTR.LAST_UPDATE_LOGIN
        ) VALUES (
          S.ATTRIBUTE_ID,
          S.VERSION_ID,
          S.NATURAL_ACCOUNT_ID,
          S.VALUE_SET_ID,
          S.DIM_ATTRIBUTE_VALUE_SET_ID,
          S.DIM_ATTRIBUTE_NUMERIC_MEMBER,
          S.DIM_ATTRIBUTE_VARCHAR_MEMBER,
          S.OBJECT_VERSION_NUMBER,
          S.AW_SNAPSHOT_FLAG,
          S.READ_ONLY_FLAG,
          S.CREATION_DATE,
          S.CREATED_BY,
          S.LAST_UPDATE_DATE,
          S.LAST_UPDATED_BY,
          S.LAST_UPDATE_LOGIN
        )
        USING pv_fem_vs_id, 10, v_account_type_pos, v_budget_pos, 'Y',
              SYSDATE, pv_user_id, SYSDATE, pv_user_id, pv_login_id,
              pv_fem_vs_id, NULL, NULL, pv_mapped_segs(1).vs_id, NULL,
              pv_dim_id, NULL, NULL
  ====================================================================== */
  PROCEDURE Populate_Dimension_Attribute(
    p_summary_flag IN VARCHAR,
    x_completion_code OUT NOCOPY NUMBER,
    x_row_count_tot OUT NOCOPY NUMBER
  ) IS
    v_module_name VARCHAR2(100);
    v_func_name VARCHAR2(100);
    v_attribute_num NUMBER;
    v_leaf_flag VARCHAR2(1);

    v_member_col VARCHAR2(30);

    v_member_id_col_name VARCHAR2(200);
    v_member_dc_col_name VARCHAR2(200);

    v_decode_company VARCHAR2(200) := NULL;
    v_decode_cost_center VARCHAR2(200) := NULL;
    v_limit_attribute_company VARCHAR2(200) := NULL;
    v_limit_attribute_cost_center VARCHAR2(200) := NULL;

    v_attributes_where VARCHAR2(1000);
    v_driving_from VARCHAR2(1000) := NULL;
    v_driving_where VARCHAR2(1000) := NULL;
    v_flex_value_from1 VARCHAR2(1000) := NULL;
    v_flex_value_from2 VARCHAR2(1000) := NULL;
    v_flex_value_where1 VARCHAR2(1000);
    v_flex_value_where2 VARCHAR2(1000);
    v_gvsc_from VARCHAR2(1000) := NULL;
    v_gvsc_where VARCHAR2(1000);
    v_from VARCHAR2(4000);
    v_where VARCHAR2(4000);

    v_account_type_pos NUMBER := NULL;
    v_budget_pos NUMBER := NULL;

    v_dim_attr_value_set_id VARCHAR2(1000);
    v_dim_attr_numeric_member VARCHAR2(4000);
    v_dim_attr_varchar_member1 VARCHAR2(4000);
    v_dim_attr_varchar_member2 VARCHAR2(4000) := NULL;

    v_stmt1 VARCHAR2(4000);
    v_stmt2 VARCHAR2(4000);
    v_stmt3 VARCHAR2(4000);
    v_stmt4 VARCHAR2(4000);
    v_stmt5 VARCHAR2(4000);
    v_stmt6 VARCHAR2(4000);

    b_driving_where_vs_id NUMBER := NULL;
    b_m_vs_id NUMBER := NULL;
    b_gt_dim_id NUMBER := NULL;
    b_flex_value_where_vs_id1 NUMBER := NULL;
    b_flex_value_where_vs_id2 NUMBER := NULL;
    b_a_dim_id NUMBER;
    b_gv_gvsc_id NUMBER := NULL;
    b_gv_dim_id NUMBER := NULL;

    --bugfix 8780516
    v_asset_sign NUMBER;
    v_liability_sign NUMBER;
    v_equity_sign NUMBER;
    v_revenue_sign NUMBER;
    v_expense_sign NUMBER;
    v_bud_debit_sign NUMBER;
    v_bud_credit_sign NUMBER;
    --end bugfix

    FEM_INTG_DIM_RULE_fatal_err EXCEPTION;

    --
    -- Find a Natural Account Segment Qualifier position
    --
    CURSOR SegmentQualifierPosition(seg_num NUMBER, qualifier VARCHAR2) IS
      SELECT POSITION
      FROM (
        SELECT ROWNUM POSITION, VALUE_ATTRIBUTE_TYPE
        FROM (
          SELECT VALUE_ATTRIBUTE_TYPE
          FROM FND_FLEX_VALIDATION_QUALIFIERS
          WHERE ID_FLEX_APPLICATION_ID = 101
          AND   ID_FLEX_CODE = 'GL#'
          AND   SEGMENT_ATTRIBUTE_TYPE IN ('GL_GLOBAL', 'GL_ACCOUNT')
          AND   FLEX_VALUE_SET_ID =
                  FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(seg_num).vs_id
          ORDER BY ASSIGNMENT_DATE, VALUE_ATTRIBUTE_TYPE
        )
      )
      WHERE VALUE_ATTRIBUTE_TYPE = qualifier;

  BEGIN

    --piush_util.put_line('Entering fem_intg_dim.populate_dimension_attribute');

    v_module_name := 'fem.plsql.fem_intg_dim.populate_dimension_attribute';
    v_func_name := 'FEM_INTG_NEW_DIM_MEMBER_PKG.Populate_Dimension_Attribute';
    v_flex_value_where1 := ' || :b_flex_value_where_vs_id1';
    v_flex_value_where2 := ' || :b_flex_value_where_vs_id2';
    v_gvsc_where := ' || :b_pv_gvsc_id || :b_pv_dim_id';
    b_a_dim_id := FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_id;

    IF FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_varchar_label = 'INTERCOMPANY' THEN
      v_member_col := FEM_INTG_DIM_RULE_ENG_PKG.pv_cctr_org_member_col;
    ELSE
      v_member_col := FEM_INTG_DIM_RULE_ENG_PKG.pv_member_col;
    END IF;

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_procedure,
      p_module   => v_module_name || '.begin',
      p_app_name => 'FEM',
      p_msg_name => 'FEM_GL_POST_201',
      p_token1   => 'FUNC_NAME',
      p_value1   => v_func_name,
      p_token2   => 'TIME',
      p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
    );

    x_completion_code := 0;
    x_row_count_tot := 0;

    --
    -- Find the number of dimension attributes
    --
    SELECT COUNT(ATTRIBUTE_ID)
    INTO v_attribute_num
    FROM FEM_DIM_ATTRIBUTES_B
    WHERE DIMENSION_ID = FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_id;

    --piush_util.put_line('v_attribute_num = ' || v_attribute_num);

    IF v_attribute_num <> 0 THEN

      --piush_util.put_line('begin preparation 1 for attribute population');

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_statement,
        p_module   => v_module_name || '.begin_prep1_populate_attribute',
        p_msg_text => 'begin preparation 1 for attribute population'
      );

      --
      -- Find Segment Qualifier Positions
      --
      IF FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_varchar_label = 'NATURAL_ACCOUNT' THEN

        OPEN SegmentQualifierPosition(
          FEM_INTG_DIM_RULE_ENG_PKG.pv_natural_account_segment_num,
          'GL_ACCOUNT_TYPE'
        );
        FETCH SegmentQualifierPosition INTO v_account_type_pos;
        CLOSE SegmentQualifierPosition;

        OPEN SegmentQualifierPosition(
          FEM_INTG_DIM_RULE_ENG_PKG.pv_natural_account_segment_num,
          'DETAIL_BUDGETING_ALLOWED'
        );
        FETCH SegmentQualifierPosition INTO v_budget_pos;
        CLOSE SegmentQualifierPosition;

        FEM_ENGINES_PKG.Tech_Message(
          p_severity => pc_log_level_statement,
          p_module   => v_module_name || '.segment_qualifier_positions',
          p_msg_text => 'v_account_type_pos=' || v_account_type_pos || ', ' ||
                        'v_budget_pos=' || v_budget_pos
        );

        --piush_util.put_line('segment_qualifier_positions. v_account_type_pos=' || v_account_type_pos || ', ' ||  'v_budget_pos=' || v_budget_pos);

      ELSIF FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_varchar_label = 'LINE_ITEM' THEN

        OPEN SegmentQualifierPosition(
          FEM_INTG_DIM_RULE_ENG_PKG.pv_natural_account_segment_num,
          'GL_ACCOUNT_TYPE'
        );
        FETCH SegmentQualifierPosition INTO v_account_type_pos;
        CLOSE SegmentQualifierPosition;

        FEM_ENGINES_PKG.Tech_Message(
          p_severity => pc_log_level_statement,
          p_module   => v_module_name || '.segment_qualifier_positions',
          p_msg_text => 'v_account_type_pos=' || v_account_type_pos
        );

        --piush_util.put_line('v_account_type_pos=' || v_account_type_pos);

      END IF;

      --
      -- Set Dynamic SQL elements based on the mapping option and the value set type
      --
      IF FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_mapping_option_code = 'SINGLESEG' AND
         p_summary_flag = 'N' THEN
        /*
          Single Segment, Detail Level
        */
        v_leaf_flag := 'Y';

        v_member_id_col_name := 'M.' || v_member_col;
        v_member_dc_col_name := 'M.' || FEM_INTG_DIM_RULE_ENG_PKG.pv_member_display_code_col;

        v_driving_from := '
            ' || FEM_INTG_DIM_RULE_ENG_PKG.pv_member_b_table_name || ' M,';

        v_driving_where := '
            M.VALUE_SET_ID = :b_driving_where_vs_id || :b_m_vs_id || :b_gt_dim_id';

        b_driving_where_vs_id := FEM_INTG_DIM_RULE_ENG_PKG.pv_fem_vs_id;

        /*
          Member id is used for COMPANY_COST_CENTER_ORG's attributes.
        */
        IF FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_varchar_label = 'COMPANY_COST_CENTER_ORG' OR
           FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_varchar_label = 'INTERCOMPANY' THEN

          IF FEM_INTG_DIM_RULE_ENG_PKG.pv_balancing_segment_num = 1 THEN
            /*
               Join to Company member table to access member id
            */
            v_flex_value_from1 := '
            FEM_COMPANIES_B COMPANY,';

            v_flex_value_where1 := ' AND
            COMPANY.VALUE_SET_ID = :b_flex_value_where_vs_id1 AND
            COMPANY.COMPANY_DISPLAY_CODE = ' || v_member_dc_col_name;

            b_flex_value_where_vs_id1 := FEM_INTG_DIM_RULE_ENG_PKG.pv_com_vs_id;

            v_decode_company := '
              ''COMPANY'', COMPANY.COMPANY_ID,';
            v_limit_attribute_company := '
              ''COMPANY'',';
          ELSE
            /*
               Join to Cost Center member table to access member id
            */
            v_flex_value_from1 := '
            FEM_COST_CENTERS_B COST_CENTER,';

            v_flex_value_where1 := ' AND
            COST_CENTER.VALUE_SET_ID = :b_flex_value_where_vs_id1 AND
            COST_CENTER.COST_CENTER_DISPLAY_CODE = ' || v_member_dc_col_name;

            b_flex_value_where_vs_id1 := FEM_INTG_DIM_RULE_ENG_PKG.pv_cc_vs_id;

            v_decode_cost_center := '
              ''COST_CENTER'', COST_CENTER.COST_CENTER_ID,';
            v_limit_attribute_cost_center := '
              ''COST_CENTER'',';

          END IF;

          /*
            Join to FEM_GLOBAL_VS_COMBO_DEFS to get
            DIM_ATTRIBUTE_VALUE_SET_ID.
          */
          v_gvsc_from := ',
            FEM_GLOBAL_VS_COMBO_DEFS GV';

          v_gvsc_where := ' AND
            GV.GLOBAL_VS_COMBO_ID = :b_gv_gvsc_id AND
            GV.DIMENSION_ID = DECODE(
                                A.ATTRIBUTE_VARCHAR_LABEL,
                                ''COMPANY'', A.ATTRIBUTE_DIMENSION_ID,
                                ''COST_CENTER'', A.ATTRIBUTE_DIMENSION_ID,
                                :b_gv_dim_id
                              )';

          b_gv_gvsc_id := FEM_INTG_DIM_RULE_ENG_PKG.pv_gvsc_id;
          b_gv_dim_id := FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_id;

        ELSIF FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_varchar_label = 'NATURAL_ACCOUNT' OR
              FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_varchar_label = 'LINE_ITEM' THEN

          /*
            Join to Value Set table to get Segment Qualifiers.

          */
          IF FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(1).table_validated_flag = 'N' THEN

            v_flex_value_from1 := '
          FND_FLEX_VALUES V,';

          ELSE
            v_flex_value_from1 := '
         (SELECT' || '
          ' || FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(1).vs_id || ' FLEX_VALUE_SET_ID,' || '
          ' || NVL(FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(1).id_col_name, 'NULL') || ' FLEX_VALUE_ID,' || '
          ' || FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(1).val_col_name || ' FLEX_VALUE,' || '
          ' || FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(1).compiled_attr_col_name ||
               ' COMPILED_VALUE_ATTRIBUTES
          FROM' || '
          ' || FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(1).table_name || '
          ' || FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(1).where_clause || ') V,';

          END IF;

          v_flex_value_where1 := ' AND
              V.FLEX_VALUE_SET_ID = :b_flex_value_where_vs_id1 AND
              V.FLEX_VALUE = M.' || FEM_INTG_DIM_RULE_ENG_PKG.pv_member_display_code_col;

          b_flex_value_where_vs_id1 := FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(1).vs_id;

        END IF;

        v_from := v_driving_from || v_flex_value_from1 || v_flex_value_from2 || '
            FEM_DIM_ATTRIBUTES_B A,
            FEM_DIM_ATTR_VERSIONS_B AV' || v_gvsc_from;

        v_where := v_driving_where || v_flex_value_where1 || v_flex_value_where2 || ' AND
            A.DIMENSION_ID = :b_a_dim_id AND
            AV.ATTRIBUTE_ID = A.ATTRIBUTE_ID AND
            AV.DEFAULT_VERSION_FLAG = ''Y''' || v_gvsc_where;

      ELSIF (FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_mapping_option_code = 'SINGLESEG' AND
             p_summary_flag = 'Y') OR
            (FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_mapping_option_code = 'MULTISEG' AND
             p_summary_flag = 'N') THEN


        --piush_util.put_line('Inside the ElseIf FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_mapping_option_code = MULTISEG');
        /*
           Notes
           -----
           - For Single Segment Summary level, there should not be no
             Table Validated value set.

           - For Multiple Segments and Single Segment Summary level,
             GT table is a driving table.

           - A support for Multiple Segments hierarchy (summary level) is to
             be provided in a later release.
        */

        IF p_summary_flag = 'Y' THEN
          v_leaf_flag := 'N';
        ELSE
          v_leaf_flag := 'Y';
        END IF;

        v_member_id_col_name := 'M.' || v_member_col;

        IF FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_varchar_label = 'COMPANY_COST_CENTER_ORG' OR
           FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_varchar_label = 'INTERCOMPANY' THEN

          --piush_util.put_line('COMPANY_COST_CENTER_ORG or INTERCOMPANY');

          IF FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_mapping_option_code = 'MULTISEG' OR
             FEM_INTG_DIM_RULE_ENG_PKG.pv_balancing_segment_num = 1 THEN
            /*
               Join to Company member table to access member id
            */
            v_flex_value_from1 := '
              FEM_COMPANIES_B COMPANY,';

            v_flex_value_where1 := ' AND
              COMPANY.VALUE_SET_ID = :b_flex_value_where_vs_id1 AND
              COMPANY.COMPANY_DISPLAY_CODE = GT.SEGMENT' ||
                FEM_INTG_DIM_RULE_ENG_PKG.pv_balancing_segment_num || '_VALUE';

            b_flex_value_where_vs_id1 := FEM_INTG_DIM_RULE_ENG_PKG.pv_com_vs_id;

            v_decode_company := '
            ''COMPANY'', COMPANY.COMPANY_ID,';
            v_limit_attribute_company := '
              ''COMPANY'',';

          END IF;

          IF FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_mapping_option_code = 'MULTISEG' OR
             FEM_INTG_DIM_RULE_ENG_PKG.pv_balancing_segment_num <> 1 THEN
            /*
               Join to Cost Center member table to access member id
            */
            v_flex_value_from2 := '
              FEM_COST_CENTERS_B COST_CENTER,';

            v_flex_value_where2 := ' AND
              COST_CENTER.VALUE_SET_ID = :b_flex_value_where_vs_id2 AND
              COST_CENTER.COST_CENTER_DISPLAY_CODE = GT.SEGMENT' ||
                FEM_INTG_DIM_RULE_ENG_PKG.pv_cost_center_segment_num || '_VALUE';

            b_flex_value_where_vs_id2 := FEM_INTG_DIM_RULE_ENG_PKG.pv_cc_vs_id;

            v_decode_cost_center := '
            ''COST_CENTER'', COST_CENTER.COST_CENTER_ID,';
            v_limit_attribute_cost_center := '
              ''COST_CENTER'',';

          END IF;

          v_gvsc_from := ',
            FEM_GLOBAL_VS_COMBO_DEFS GV';
          v_gvsc_where := ' AND
              GV.GLOBAL_VS_COMBO_ID = :b_gv_gvsc_id AND
              GV.DIMENSION_ID = DECODE(
                                  A.ATTRIBUTE_VARCHAR_LABEL,
                                  ''COMPANY'', A.ATTRIBUTE_DIMENSION_ID,
                                  ''COST_CENTER'', A.ATTRIBUTE_DIMENSION_ID,
                                  :b_gv_dim_id
                                )';

          b_gv_gvsc_id := FEM_INTG_DIM_RULE_ENG_PKG.pv_gvsc_id;
          b_gv_dim_id := FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_id;

        ELSIF FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_varchar_label = 'NATURAL_ACCOUNT' OR
              FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_varchar_label = 'LINE_ITEM' THEN

          /*
             Join to Value Set table to access Segment Qualifiers
          */
          IF FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(FEM_INTG_DIM_RULE_ENG_PKG.pv_natural_account_segment_num).table_validated_flag = 'N' THEN
            v_flex_value_from1 := '
              FND_FLEX_VALUES V,';
          ELSE
            v_flex_value_from1 := '
              (SELECT ' || '
 ' || FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(FEM_INTG_DIM_RULE_ENG_PKG.pv_natural_account_segment_num).vs_id || ' FLEX_VALUE_SET_ID,' || '
 ' || NVL(FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(FEM_INTG_DIM_RULE_ENG_PKG.pv_natural_account_segment_num).id_col_name, 'NULL') || ' FLEX_VALUE_ID,' || '
 ' || FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(FEM_INTG_DIM_RULE_ENG_PKG.pv_natural_account_segment_num).val_col_name || ' FLEX_VALUE,' || '
 ' || FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(FEM_INTG_DIM_RULE_ENG_PKG.pv_natural_account_segment_num).compiled_attr_col_name || ' COMPILED_VALUE_ATTRIBUTES
               FROM ' || '
                 ' || FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(FEM_INTG_DIM_RULE_ENG_PKG.pv_natural_account_segment_num).table_name || '
                 ' || FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(FEM_INTG_DIM_RULE_ENG_PKG.pv_natural_account_segment_num).where_clause || ') V,';
          END IF;

          v_flex_value_where1 := ' AND
            V.FLEX_VALUE_SET_ID = :b_flex_value_where_vs_id1 AND
            V.FLEX_VALUE = GT.SEGMENT' || FEM_INTG_DIM_RULE_ENG_PKG.pv_natural_account_segment_num || '_VALUE';

          b_flex_value_where_vs_id1 := FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(FEM_INTG_DIM_RULE_ENG_PKG.pv_natural_account_segment_num).vs_id;

        END IF;

        v_from := '
              ' || FEM_INTG_DIM_RULE_ENG_PKG.pv_member_b_table_name || ' M,
              FEM_INTG_DIM_MEMBERS_GT GT,' || v_flex_value_from1  || v_flex_value_from2 || '
              FEM_DIM_ATTRIBUTES_B A,
              FEM_DIM_ATTR_VERSIONS_B AV' || v_gvsc_from;

        v_where := '
              M.VALUE_SET_ID = :b_driving_where_vs_id || :b_m_vs_id AND
              GT.DIMENSION_ID = :b_gt_dim_id AND
              GT.CONCAT_SEGMENT_VALUE = M.' || FEM_INTG_DIM_RULE_ENG_PKG.pv_member_display_code_col || v_flex_value_where1 || v_flex_value_where2 || ' AND
              A.DIMENSION_ID = :b_a_dim_id AND
              AV.ATTRIBUTE_ID = A.ATTRIBUTE_ID AND
              AV.DEFAULT_VERSION_FLAG = ''Y''' || v_gvsc_where;

        b_m_vs_id := FEM_INTG_DIM_RULE_ENG_PKG.pv_fem_vs_id;
        b_gt_dim_id := FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_id;

      END IF;

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_statement,
        p_module   => v_module_name || '.end_prep1_populate_attribute',
        p_msg_text => 'end preparation 1 for attribute population'
      );

      --piush_util.put_line('end preparation 1 for attribute population');

      v_dim_attr_value_set_id := 'NULL';
      v_dim_attr_varchar_member2 := ' '; -- using a single space as NULL
                                         -- will be replaced with a word NULL
                                         -- by FND logging
      --
      -- Set Attributes
      --
      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_statement,
        p_module   => v_module_name || '.begin_prep2_populate_attribute',
        p_msg_text => 'begin preparation 2 for attribute population'
      );

      --piush_util.put_line('begin preparation 2 for attribute population');

      IF FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_varchar_label = 'COMPANY_COST_CENTER_ORG' OR
         FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_varchar_label = 'INTERCOMPANY' THEN

        v_dim_attr_value_set_id :=
            'DECODE(
              A.ATTRIBUTE_VARCHAR_LABEL,
              ''COMPANY'', GV.VALUE_SET_ID,
              ''COST_CENTER'', GV.VALUE_SET_ID,
              NULL
            )';

        v_dim_attr_numeric_member :=
'            DECODE(
              A.ATTRIBUTE_VARCHAR_LABEL,
              ''SOURCE_SYSTEM_CODE'', :pv_source_system_code_id,' || v_decode_company || v_decode_cost_center || '
              NULL
            )';

        v_dim_attr_varchar_member1 :=
'            DECODE(
              A.ATTRIBUTE_VARCHAR_LABEL,
              ''HIDDEN_FLAG'', ''N'',
              ''RECON_LEAF_NODE_FLAG'', :v_account_type_pos || :v_budget_pos || :v_leaf_flag,
              ''CCTR_ORG_TYPE'', ''OTHER'',
              NULL
            )';

        /*
           Limit attributes
        */
        v_attributes_where := ' AND
            A.ATTRIBUTE_VARCHAR_LABEL IN (
              ''SOURCE_SYSTEM_CODE'',' || v_limit_attribute_company || v_limit_attribute_cost_center || '
              ''HIDDEN_FLAG'',
              ''RECON_LEAF_NODE_FLAG'',
              ''CCTR_ORG_TYPE''
            )';

      ELSIF FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_varchar_label = 'NATURAL_ACCOUNT' THEN

        v_dim_attr_numeric_member :=
'             DECODE(
               A.ATTRIBUTE_VARCHAR_LABEL,
               ''SOURCE_SYSTEM_CODE'', :pv_source_system_code_id,
               NULL
             )';

        v_dim_attr_varchar_member1 :=
'             DECODE(
               A.ATTRIBUTE_VARCHAR_LABEL,
               ''EXTENDED_ACCOUNT_TYPE'',
               DECODE(
                 SUBSTR(
                   FND_GLOBAL.NEWLINE ||
                   V.COMPILED_VALUE_ATTRIBUTES ||
                   FND_GLOBAL.NEWLINE,
                   INSTR(
                     FND_GLOBAL.NEWLINE ||
                     V.COMPILED_VALUE_ATTRIBUTES ||
                     FND_GLOBAL.NEWLINE,
                     FND_GLOBAL.NEWLINE,
                     1, :v_account_type_pos
                   )+1,
                   1
                 ),
                 ''A'', ''ASSET'',
                 ''E'', ''EXPENSE'',
                 ''R'', ''REVENUE'',
                 ''L'', ''LIABILITY'',
                 ''O'', ''EQUITY'',
		 --bugfix 8780516
                 ''D'', ''BUDGETARY_DEBIT'',
                 ''C'', ''BUDGETARY_CREDIT''
               )';

        v_dim_attr_varchar_member2 :=
'               ''BUDGET_ALLOWED_FLAG'',
               SUBSTR(
                 FND_GLOBAL.NEWLINE ||
                 V.COMPILED_VALUE_ATTRIBUTES ||
                 FND_GLOBAL.NEWLINE,
                 INSTR(
                   FND_GLOBAL.NEWLINE ||
                   V.COMPILED_VALUE_ATTRIBUTES ||
                   FND_GLOBAL.NEWLINE,
                   FND_GLOBAL.NEWLINE,
                   1, :v_budget_pos
                 )+1,
                 1
               ),
               ''NAT_ACCT_EXPENSE_TYPE_CODE'', ''FIXED'',
               ''INVENTORIABLE_FLAG'', ''N'',
               ''RECON_LEAF_NODE_FLAG'', :v_leaf_flag,
               NULL
             )';

        /*
           Limit attributes
        */
        v_attributes_where := ' AND
            A.ATTRIBUTE_VARCHAR_LABEL IN (
              ''SOURCE_SYSTEM_CODE'',
              ''EXTENDED_ACCOUNT_TYPE'',
              ''BUDGET_ALLOWED_FLAG'',
              ''NAT_ACCT_EXPENSE_TYPE_CODE'',
              ''INVENTORIABLE_FLAG'',
              ''RECON_LEAF_NODE_FLAG''
            )';

      ELSIF FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_varchar_label = 'LINE_ITEM' THEN

        v_dim_attr_numeric_member :=
'          DECODE(
            A.ATTRIBUTE_VARCHAR_LABEL,
            ''SOURCE_SYSTEM_CODE'', :pv_source_system_code_id,
            NULL
      )';

        v_dim_attr_varchar_member1 :=
'          DECODE(
            A.ATTRIBUTE_VARCHAR_LABEL,
            ''EXTENDED_ACCOUNT_TYPE'',
            DECODE(
              SUBSTR(
                FND_GLOBAL.NEWLINE ||
                V.COMPILED_VALUE_ATTRIBUTES ||
                FND_GLOBAL.NEWLINE,
                INSTR(
                  FND_GLOBAL.NEWLINE ||
                  V.COMPILED_VALUE_ATTRIBUTES ||
                  FND_GLOBAL.NEWLINE,
                  FND_GLOBAL.NEWLINE,
                  1, :v_account_type_pos
                )+1,
                1
              ),
              ''A'', ''ASSET'',
              ''E'', ''EXPENSE'',
              ''R'', ''REVENUE'',
              ''L'', ''LIABILITY'',
              ''O'', ''EQUITY'',
	      --bugfix 8780516
              ''D'', ''BUDGETARY_DEBIT'',
              ''C'', ''BUDGETARY_CREDIT''
            ),
	    --bugfix 8780516
	    -- ''BETTER_FLAG'', ''N'',
            ''BETTER_FLAG'',
            DECODE(
              SUBSTR(
                FND_GLOBAL.NEWLINE ||
                V.COMPILED_VALUE_ATTRIBUTES ||
                FND_GLOBAL.NEWLINE,
                INSTR(
                  FND_GLOBAL.NEWLINE ||
                  V.COMPILED_VALUE_ATTRIBUTES ||
                  FND_GLOBAL.NEWLINE,
                  FND_GLOBAL.NEWLINE,
                  1, :v_account_type_pos
                )+1,
                1
              ),
              ''A'', decode(:v_asset_sign, 1, ''Y'', ''N''),
              ''L'', decode(:v_liability_sign, 1, ''Y'', ''N''),
              ''O'', decode(:v_equity_sign, 1, ''Y'', ''N''),
              ''R'', decode(:v_revenue_sign, 1, ''N'', ''Y''),
              ''E'', decode(:v_expense_sign, 1, ''N'', ''Y''),
              ''D'', decode(:v_bud_debit_sign, 1, ''N'', ''Y''),
              ''C'', decode(:v_bud_credit_sign, 1, ''N'', ''Y'')
            ),
	    --end 8780516
            ''RECON_LEAF_NODE_FLAG'', :v_budget_pos || :v_leaf_flag,
            NULL
          )';

        /*
           Limit attributes
        */
        v_attributes_where := ' AND
            A.ATTRIBUTE_VARCHAR_LABEL IN (
              ''SOURCE_SYSTEM_CODE'',
              ''EXTENDED_ACCOUNT_TYPE'',
              ''BETTER_FLAG'',
              ''RECON_LEAF_NODE_FLAG''
            )';

      ELSIF FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_varchar_label = 'PRODUCT' THEN

        v_dim_attr_numeric_member :=
'            DECODE(
              A.ATTRIBUTE_VARCHAR_LABEL,
              ''SOURCE_SYSTEM_CODE'', :pv_source_system_code_id,
              NULL
            )';

        v_dim_attr_varchar_member1 :=
'            DECODE(
              A.ATTRIBUTE_VARCHAR_LABEL,
              ''PRODUCT_UOM'', ''EACH'',
              ''PRODUCT_MATERIAL_FLAG'', ''N'',
              ''RECON_LEAF_NODE_FLAG'', :v_account_type_pos || :v_budget_pos || :v_leaf_flag,
               NULL
             )';

        /*
           Limit attributes
        */
        v_attributes_where := ' AND
            A.ATTRIBUTE_VARCHAR_LABEL IN (
              ''SOURCE_SYSTEM_CODE'',
              ''PRODUCT_UOM'',
              ''PRODUCT_MATERIAL_FLAG'',
              ''RECON_LEAF_NODE_FLAG''
            )';

      ELSIF FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_varchar_label IN (
              'CHANNEL', 'CUSTOMER', 'ENTITY', 'PROJECT', 'TASK', 'GEOGRAPHY',
              'USER_DIM1', 'USER_DIM2', 'USER_DIM3', 'USER_DIM4', 'USER_DIM5',
              'USER_DIM6', 'USER_DIM7', 'USER_DIM8', 'USER_DIM9', 'USER_DIM10'
            ) THEN

        v_dim_attr_numeric_member :=
'            DECODE(
              A.ATTRIBUTE_VARCHAR_LABEL,
              ''SOURCE_SYSTEM_CODE'', :pv_source_system_code_id,
              NULL
            )';

        v_dim_attr_varchar_member1 :=
'            DECODE(
              A.ATTRIBUTE_VARCHAR_LABEL,
              ''RECON_LEAF_NODE_FLAG'', :v_account_type_pos || :v_budget_pos || :v_leaf_flag,
               NULL
            )';

        /*
           Limit attributes
        */
        v_attributes_where := ' AND
            A.ATTRIBUTE_VARCHAR_LABEL IN (
              ''SOURCE_SYSTEM_CODE'',
              ''RECON_LEAF_NODE_FLAG''
            )';

      END IF;

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_statement,
        p_module   => v_module_name || '.end_prep2_populate_attribute',
        p_msg_text => 'end preparation 2 for attribute population'
      );

      --piush_util.put_line('end preparation 2 for attribute population');

      --
      -- Construct Dynamic SQL
      --
      v_stmt1 := '
        MERGE INTO ' || FEM_INTG_DIM_RULE_ENG_PKG.pv_attr_table_name || ' ATTR
        USING (
          SELECT
            A.ATTRIBUTE_ID,
            AV.VERSION_ID' || ',
            ' || v_member_id_col_name || ',
            :pv_fem_vs_id VALUE_SET_ID,
            ' || v_dim_attr_value_set_id || ' DIM_ATTRIBUTE_VALUE_SET_ID,';

      v_stmt2 := v_dim_attr_numeric_member || ' DIM_ATTRIBUTE_NUMERIC_MEMBER,';

        IF v_dim_attr_varchar_member2 = ' ' THEN
          v_stmt3 := v_dim_attr_varchar_member1 || ' DIM_ATTRIBUTE_VARCHAR_MEMBER,';
          v_stmt4 := v_dim_attr_varchar_member2;
        ELSE
          v_stmt3 := v_dim_attr_varchar_member1 || ',';
          v_stmt4 := v_dim_attr_varchar_member2 || ' DIM_ATTRIBUTE_VARCHAR_MEMBER,';
        END IF;

      v_stmt5 := '
            1 OBJECT_VERSION_NUMBER,
            ''N'' AW_SNAPSHOT_FLAG,
	    --bugfix 8780516
	    --''Y'' READ_ONLY_FLAG,
            decode(a.attribute_varchar_label, ''BETTER_FLAG'', ''N'', ''Y'') READ_ONLY_FLAG,
            :b_sysdate CREATION_DATE,
            :pv_user_id CREATED_BY,
            :b_sysdate LAST_UPDATE_DATE,
            :pv_user_id LAST_UPDATED_BY,
            :pv_login_id LAST_UPDATE_LOGIN
          FROM ' || v_from || '
          WHERE ' || v_where || v_attributes_where;

      v_stmt6 :=
'        ) S
        ON (
          ATTR.ATTRIBUTE_ID = S.ATTRIBUTE_ID AND
          ATTR.VERSION_ID = S.VERSION_ID AND
          ATTR.' || v_member_col || ' = S.' || v_member_col || ' AND
          ATTR.VALUE_SET_ID = S.VALUE_SET_ID
        )
        WHEN MATCHED THEN UPDATE
          SET ATTR.LAST_UPDATE_DATE = SYSDATE
        WHEN NOT MATCHED THEN INSERT (
          ATTR.ATTRIBUTE_ID,
          ATTR.VERSION_ID,
          ATTR.' || v_member_col || ',
          ATTR.VALUE_SET_ID,
          ATTR.DIM_ATTRIBUTE_VALUE_SET_ID,
          ATTR.DIM_ATTRIBUTE_NUMERIC_MEMBER,
          ATTR.DIM_ATTRIBUTE_VARCHAR_MEMBER,
          ATTR.OBJECT_VERSION_NUMBER,
          ATTR.AW_SNAPSHOT_FLAG,
          ATTR.READ_ONLY_FLAG,
          ATTR.CREATION_DATE,
          ATTR.CREATED_BY,
          ATTR.LAST_UPDATE_DATE,
          ATTR.LAST_UPDATED_BY,
          ATTR.LAST_UPDATE_LOGIN
        ) VALUES (
          S.ATTRIBUTE_ID,
          S.VERSION_ID,
          S.' || v_member_col || ',
          S.VALUE_SET_ID,
          S.DIM_ATTRIBUTE_VALUE_SET_ID,
          S.DIM_ATTRIBUTE_NUMERIC_MEMBER,
          S.DIM_ATTRIBUTE_VARCHAR_MEMBER,
          S.OBJECT_VERSION_NUMBER,
          S.AW_SNAPSHOT_FLAG,
          S.READ_ONLY_FLAG,
          S.CREATION_DATE,
          S.CREATED_BY,
          S.LAST_UPDATE_DATE,
          S.LAST_UPDATED_BY,
          S.LAST_UPDATE_LOGIN
        )';

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_statement,
        p_module   => v_module_name || '.dsql_insert_merge_into_' ||
                      FEM_INTG_DIM_RULE_ENG_PKG.pv_attr_table_name,
        p_msg_text => v_stmt1
      );

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_statement,
        p_module   => v_module_name || '.dsql_insert_merge_into_' ||
                      FEM_INTG_DIM_RULE_ENG_PKG.pv_attr_table_name,
        p_msg_text => v_stmt2
      );

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_statement,
        p_module   => v_module_name || '.dsql_insert_merge_into_' ||
                      FEM_INTG_DIM_RULE_ENG_PKG.pv_attr_table_name,
        p_msg_text => v_stmt3
      );

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_statement,
        p_module   => v_module_name || '.dsql_insert_merge_into_' ||
                      FEM_INTG_DIM_RULE_ENG_PKG.pv_attr_table_name,
        p_msg_text => v_stmt4
      );

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_statement,
        p_module   => v_module_name || '.dsql_insert_merge_into_' ||
                      FEM_INTG_DIM_RULE_ENG_PKG.pv_attr_table_name,
        p_msg_text => v_stmt5
      );

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_statement,
        p_module   => v_module_name || '.dsql_insert_merge_into_' ||
                      FEM_INTG_DIM_RULE_ENG_PKG.pv_attr_table_name,
        p_msg_text => v_stmt6
      );

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_statement,
        p_module   => v_module_name || '.dsql_insert_merge_into_' ||
                      FEM_INTG_DIM_RULE_ENG_PKG.pv_attr_table_name,
        p_msg_text => 'USING ' ||
              TO_CHAR(FEM_INTG_DIM_RULE_ENG_PKG.pv_fem_vs_id) || ', ' ||
              TO_CHAR(FEM_INTG_DIM_RULE_ENG_PKG.pv_source_system_code_id) || ', ' ||
              TO_CHAR(v_account_type_pos) || ', ' ||
              TO_CHAR(v_budget_pos) || ', ' ||
              v_leaf_flag || ', ' ||
              TO_CHAR(SYSDATE, 'YYYY/MM/DD') || ', ' ||
              TO_CHAR(pv_user_id) || ', ' ||
              TO_CHAR(SYSDATE, 'YYYY/MM/DD') || ', ' ||
              TO_CHAR(pv_user_id) || ', ' ||
              TO_CHAR(pv_login_id) || ', ' ||
              TO_CHAR(b_driving_where_vs_id) || ', ' ||
              TO_CHAR(b_m_vs_id) || ', ' ||
              TO_CHAR(b_gt_dim_id) || ', ' ||
              TO_CHAR(b_flex_value_where_vs_id1) || ', ' ||
              TO_CHAR(b_flex_value_where_vs_id2) || ', ' ||
              TO_CHAR(b_a_dim_id) || ', ' ||
              TO_CHAR(b_gv_gvsc_id) || ', ' ||
              TO_CHAR(b_gv_dim_id)
      );

    --piush_util.put_line('Stmt = ' ||  v_stmt1 || v_stmt2 || v_stmt3 || v_stmt4 || v_stmt5 || v_stmt6);

       --bugfix 8780516
      IF FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_varchar_label = 'LINE_ITEM' THEN
        v_asset_sign := get_signage('ASSET');
        v_liability_sign := get_signage('LIABILITY');
        v_equity_sign := get_signage('EQUITY');
        v_revenue_sign := get_signage('REVENUE');
        v_expense_sign := get_signage('EXPENSE');
        v_bud_debit_sign := get_signage('BUDGETARY_DEBIT');
        v_bud_credit_sign := get_signage('BUDGETARY_CREDIT');


        EXECUTE IMMEDIATE v_stmt1 || v_stmt2 || v_stmt3 || v_stmt4 ||
                        v_stmt5 || v_stmt6
        USING
        FEM_INTG_DIM_RULE_ENG_PKG.pv_fem_vs_id, -- Always
        FEM_INTG_DIM_RULE_ENG_PKG.pv_source_system_code_id, -- Always
        v_account_type_pos,                     -- NATURAL_ACCOUNT/LINE_ITEM
        v_account_type_pos,                     -- LINE_ITEM
        v_asset_sign,                           -- LINE ITEM
        v_liability_sign,                       -- LINE ITEM
        v_equity_sign,                          -- LINE ITEM
        v_revenue_sign,                         -- LINE ITEM
        v_expense_sign,                         -- LINE ITEM
        v_bud_debit_sign,                       -- LINE ITEM
        v_bud_credit_sign,                      -- LINE ITEM
        v_budget_pos,                           -- NATURAL_ACCOUNT
        v_leaf_flag,                            -- Always
        SYSDATE,                                -- Always
        pv_user_id,   -- Always
        SYSDATE,                                -- Always
        pv_user_id,   -- Always
        pv_login_id,  -- Always
        b_driving_where_vs_id,    -- Single Seg Detail
        b_m_vs_id,                -- Single Seg Summary/Multi Seg Detail
        b_gt_dim_id,              -- Single Seg Summary/Multi Seg Detail
        b_flex_value_where_vs_id1, -- 1. Single Seg Detail, Table Validated
                                   --    COMPARNY_COST_CENTER_ORG/
                                   --    NATURAL_ACCOUNT/LINE_ITEM
                                   -- 2. Single Seg Summary/Multi Seg Detail
                                   --    NATURAL_ACCOUNT/LINE_ITEM
        b_flex_value_where_vs_id2, -- 1. Multi Seg Detail
                                   --    COMPARNY_COST_CENTER_ORG
        b_a_dim_id,                -- Always
        b_gv_gvsc_id,              -- COMPANY_COST_CENTER_ORG/INTERCOMPANY
        b_gv_dim_id;               -- COMPANY_COST_CENTER_ORG/INTERCOMPANY
      ELSE
        EXECUTE IMMEDIATE v_stmt1 || v_stmt2 || v_stmt3 || v_stmt4 ||
                        v_stmt5 || v_stmt6
      USING
      --end 8780516
        FEM_INTG_DIM_RULE_ENG_PKG.pv_fem_vs_id, -- Always
        FEM_INTG_DIM_RULE_ENG_PKG.pv_source_system_code_id, -- Always
        v_account_type_pos,                     -- NATURAL_ACCOUNT/LINE_ITEM
        v_budget_pos,                           -- NATURAL_ACCOUNT
        v_leaf_flag,                            -- Always
        SYSDATE,                                -- Always
        pv_user_id,   -- Always
        SYSDATE,                                -- Always
        pv_user_id,   -- Always
        pv_login_id,  -- Always
        b_driving_where_vs_id,    -- Single Seg Detail
        b_m_vs_id,                -- Single Seg Summary/Multi Seg Detail
        b_gt_dim_id,              -- Single Seg Summary/Multi Seg Detail
        b_flex_value_where_vs_id1, -- 1. Single Seg Detail, Table Validated
                                   --    COMPARNY_COST_CENTER_ORG/
                                   --    NATURAL_ACCOUNT/LINE_ITEM
                                   -- 2. Single Seg Summary/Multi Seg Detail
                                   --    NATURAL_ACCOUNT/LINE_ITEM
        b_flex_value_where_vs_id2, -- 1. Multi Seg Detail
                                   --    COMPARNY_COST_CENTER_ORG
        b_a_dim_id,                -- Always
        b_gv_gvsc_id,              -- COMPANY_COST_CENTER_ORG/INTERCOMPANY
        b_gv_dim_id;               -- COMPANY_COST_CENTER_ORG/INTERCOMPANY
      --bugfix 8780516
      END IF;

      x_row_count_tot := SQL%ROWCOUNT;

      --piush_util.put_line('SQL%ROWCOUNT = ' || SQL%ROWCOUNT);

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_statement,
        p_module   => v_module_name || '.cnt_insert_merge_into_' ||
                      FEM_INTG_DIM_RULE_ENG_PKG.pv_attr_table_name,
        p_msg_text => x_row_count_tot
      );

    END IF;

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_procedure,
      p_module   => v_module_name || '.end',
      p_app_name => 'FEM',
      p_msg_name => 'FEM_GL_POST_202',
      p_token1   => 'FUNC_NAME',
      p_value1   => v_func_name,
      p_token2   => 'TIME',
      p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
    );

  EXCEPTION

    WHEN FEM_INTG_DIM_RULE_fatal_err THEN

      ROLLBACK;

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_procedure,
        p_module   => v_module_name || 'unexpected_exception',
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_203',
        p_token1   => 'FUNC_NAME',
        p_value1   => v_func_name,
        p_token2   => 'TIME',
        p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
      );

      x_completion_code := 2;

    WHEN OTHERS THEN

      ROLLBACK;

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_unexpected,
        p_module   => v_module_name || '.unexpected_exception',
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_215',
        p_token1   => 'ERR_MSG',
        p_value1   => SQLERRM
      );

      FEM_ENGINES_PKG.User_Message(
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_215',
        p_token1   => 'ERR_MSG',
        p_value1   => SQLERRM
      );

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_procedure,
        p_module   => v_module_name || 'unexpected_exception',
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_203',
        p_token1   => 'FUNC_NAME',
        p_value1   => v_func_name,
        p_token2   => 'TIME',
        p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
      );

      x_completion_code := 2;

      --raise;

  END Populate_Dimension_Attribute;


  PROCEDURE Detail_Single_Value(
    x_completion_code OUT NOCOPY NUMBER,
    x_row_count_tot   OUT NOCOPY NUMBER
  ) IS

   --bugfix 8780516

   /*v_rows_processed              NUMBER;
    c_func_name                   CONSTANT VARCHAR2(30)
                                      := '.Detail_Single_Value';
    v_upd_map_table_stmt          VARCHAR2(4000);
    v_column_list                       VARCHAR2(1000);
    v_value_list                        VARCHAR2(1000);

    v_lockhandle                        VARCHAR2(100);
    v_lock_result                       NUMBER;
    v_loop_counter                      NUMBER;

    FEM_INTG_DIM_RULE_ulock_err EXCEPTION;


    CURSOR ColumnList IS
      SELECT COLUMN_NAME
      FROM FEM_TAB_COLUMNS_B
      WHERE TABLE_NAME = 'FEM_BALANCES'
      AND FEM_DATA_TYPE_CODE = 'DIMENSION'
      AND DIMENSION_ID = FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_id;*/
    c_func_name                   CONSTANT VARCHAR2(30)
                                      := '.Detail_Single_Value';
    v_module_name            VARCHAR2(100);
    v_func_name              VARCHAR2(100);
    v_Num_Workers            NUMBER;
    X_errbuf                 VARCHAR2(2000);
    v_dim_rule_req_count     NUMBER;

    FEM_INTG_DIM_RULE_worker_err EXCEPTION;

    -- Start bug Fix 5579716
    v_request_id                       NUMBER;
    v_gcs_vs_id                        NUMBER;
    --Bugfix 9114881
    l_new_max_ccid_processed           NUMBER;
    v_fch_vs_select_stmt               VARCHAR2(1000):=
                                    'SELECT 1
                                       FROM fem_global_vs_combo_defs fch_vs_combo
                                      WHERE fch_vs_combo.global_vs_combo_id = ( SELECT fch_global_vs_combo_id
                                                                                FROM gcs_system_options )
                                        AND fch_vs_combo.dimension_id = 8
                                        AND fch_vs_combo.value_set_id = :fem_value_set_id';

    TYPE vs_cursor IS REF CURSOR;
    fch_vs_cursor vs_cursor;

    -- End bug Fix 5579716

   --bugfix 8780516
    -- Start bug fix 5844990
    v_max_ccid_to_be_mapped  NUMBER;
    -- End bug fix 5844990
  BEGIN
  --bugfix 8780516
    v_module_name := 'fem.plsql.fem_intg_dim.detail_single_value';
    v_func_name := 'FEM_INTG_NEW_DIM_MEMBER_PKG.Detail_Single_Value';

    FEM_ENGINES_PKG.Tech_Message
      ( p_severity => pc_log_level_procedure
       ,p_module   => pc_module_name||c_func_name
       ,p_app_name => 'FEM'
       ,p_msg_name => 'FEM_GL_POST_201'
       ,p_token1   => 'FUNC_NAME'
       ,p_value1   => pc_module_name||c_func_name
       ,p_token2   => 'TIME'
       ,p_value2   =>  TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

    x_completion_code := 0;
    --Bugfix 8780516
    /*
    v_rows_processed := 0;

    DBMS_LOCK.ALLOCATE_UNIQUE(
        'FEM_INTG_DIM_RULE' || FEM_INTG_DIM_RULE_ENG_PKG.pv_fem_vs_id,
        v_lockhandle,
        pc_expiration_secs
      );

    v_loop_counter := 1;

    LOOP
      IF v_loop_counter > pc_loop_counter_max
      THEN

        FEM_ENGINES_PKG.Tech_Message(
            p_severity => pc_log_level_statement
           ,p_module   => pc_module_name||c_func_name
           ,p_msg_text => 'raising FEM_INTG_DIM_RULE_ulock_err'
          );
        RAISE FEM_INTG_DIM_RULE_ulock_err;
      END IF;

      v_lock_result := DBMS_LOCK.REQUEST(
                           v_lockhandle,
                           pc_lockmode,
                           pc_lock_timeout,
                           pc_release_on_commit
                         );

      IF v_lock_result = 0 OR v_lock_result = 4
      THEN
        EXIT;
      ELSE
        v_loop_counter := v_loop_counter + 1;

        FEM_ENGINES_PKG.Tech_Message(
              p_severity => pc_log_level_statement
             ,p_module   => pc_module_name||c_func_name
             ,p_msg_text => 'sleeping ' || pc_sleep_second || ' second'
            );
        DBMS_LOCK.SLEEP(pc_sleep_second);
      END IF;
    END LOOP;

    IF FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_varchar_label <> 'GEOGRAPHY'
    THEN

      IF FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_varchar_label = 'INTERCOMPANY'
      THEN

        v_column_list :=  FEM_INTG_DIM_RULE_ENG_PKG.pv_member_col;
        v_value_list :=  FEM_INTG_DIM_RULE_ENG_PKG.pv_default_member_id;

      ELSIF FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_varchar_label
                           = 'COMPANY_COST_CENTER_ORG'
      THEN

        FOR rec IN ColumnList LOOP
          IF rec.column_name <> 'INTERCOMPANY_ID' THEN
            v_column_list := v_column_list || rec.column_name || ',';
            v_value_list := v_value_list || FEM_INTG_DIM_RULE_ENG_PKG.pv_default_member_id || ',';
          END IF;
        END LOOP;

        v_column_list :=  '(' || TRIM(TRAILING ',' FROM v_column_list) || ')';
        v_value_list := TRIM(TRAILING ',' FROM v_value_list);

      ELSE

        FOR rec IN ColumnList LOOP
          v_column_list := v_column_list || rec.column_name || ',';
          v_value_list := v_value_list || FEM_INTG_DIM_RULE_ENG_PKG.pv_default_member_id || ',';
        END LOOP;

        v_column_list :=  '(' || TRIM(TRAILING ',' FROM v_column_list) || ')';
        v_value_list := TRIM(TRAILING ',' FROM v_value_list);
      END IF;

      v_upd_map_table_stmt :=
         'UPDATE fem_intg_ogl_ccid_map fiocm
          SET '||v_column_list||' = '||v_value_list||'
          WHERE fiocm.code_combination_id between
                :v_low and :v_high
            AND fiocm.global_vs_combo_id = :v_gvsc_id';

      FEM_ENGINES_PKG.Tech_Message
            (p_severity => pc_log_level_statement
            ,p_module   => pc_module_name||c_func_name
            ,p_app_name => 'FEM'
            ,p_msg_name => 'FEM_GL_POST_204'
            ,p_token1   => 'VAR_NAME'
            ,p_value1   => 'SQL Statement'
            ,p_token2   => 'VAR_VAL'
            ,p_value2   => v_upd_map_table_stmt);

      EXECUTE IMMEDIATE v_upd_map_table_stmt
      USING FEM_INTG_DIM_RULE_ENG_PKG.pv_max_ccid_processed+1
           ,FEM_INTG_DIM_RULE_ENG_PKG.pv_max_ccid_to_be_mapped
           ,FEM_INTG_DIM_RULE_ENG_PKG.pv_gvsc_id;

      v_rows_processed := v_rows_processed + SQL%ROWCOUNT;

      FEM_ENGINES_PKG.Tech_Message
            (p_severity => pc_log_level_statement
            ,p_module   => pc_module_name||c_func_name
            ,p_app_name => 'FEM'
            ,p_msg_name => 'FEM_GL_POST_216'
            ,p_token1   => 'TABLE'
            ,p_value1   => 'fem_intg_ogl_ccid_map'
            ,p_token2   => 'NUM'
            ,p_value2   => SQL%ROWCOUNT);

      v_rows_processed := v_rows_processed + SQL%ROWCOUNT;

      pv_progress := 'after executing update map';
      --piush_util.put_line(pv_progress);

    END IF;

    --------------------------------------------------------------
    -- Update Dimension definition table with max_ccid_processed
    --------------------------------------------------------------

    UPDATE fem_intg_dim_rule_defs
    SET    max_ccid_processed = fem_intg_dim_rule_eng_pkg.pv_max_ccid_to_be_mapped
    WHERE  dim_rule_obj_def_id = fem_intg_dim_rule_eng_pkg.pv_dim_rule_obj_def_id;
    v_rows_processed := v_rows_processed + SQL%ROWCOUNT;


    x_row_count_tot := v_rows_processed;
    */

    x_row_count_tot := 0;

    -- Since requests will reach completed phase irrespective of status
    -- Check if any dimension rule requests which are not having completed phase
    -- for any dimension other than intercompany dimension for the same chart of account
    -- If any request found then issue sleep timer
    LOOP
    BEGIN
          SELECT 1
            INTO v_dim_rule_req_count
            FROM dual
           WHERE EXISTS ( SELECT 1
                            FROM fnd_concurrent_programs fcp,
                                 fnd_concurrent_requests fcr,
                                 fem_intg_dim_rules idr,
                                 fem_object_definition_b fodb
                           WHERE fcp.concurrent_program_id = fcr.concurrent_program_id
                             AND fcp.application_id = fcr.program_application_id
                             AND fcp.application_id = 274
                             AND fcp.concurrent_program_name = 'FEM_INTG_DIM_RULE_ENGINE'
                             AND fcr.phase_code <> 'C'
                             AND idr.dim_rule_obj_id = fodb.object_id
                             AND idr.chart_of_accounts_id = FEM_INTG_DIM_RULE_ENG_PKG.pv_coa_id
                             AND idr.dimension_id <> 0
                             AND fcr.argument1 = fodb.object_definition_id
                             AND fcr.argument2 = 'MEMBER');

          DBMS_LOCK.SLEEP(pc_sleep_second);
          EXCEPTION WHEN NO_DATA_FOUND THEN EXIT;

    END;
    END LOOP;

    select nvl(value,1)*2 no_of_workers
    into v_Num_Workers
    from v$parameter
    where name = 'cpu_count';

    FEM_ENGINES_PKG.User_Message(
      p_app_name => 'FEM',
      p_msg_text => 'Kicking off '||v_Num_Workers||' workers requests at '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')
    );

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_statement,
      p_module   => v_module_name || '.dsql_update_fem_intg_ogl_ccid_map',
      p_msg_text => 'USING ' ||
          TO_CHAR(FEM_INTG_DIM_RULE_ENG_PKG.pv_coa_id) || ', ' ||
          TO_CHAR(FEM_INTG_DIM_RULE_ENG_PKG.pv_gvsc_id)
        );

    -- AD Parallel framework Manager processing

    --Purge all the info from ad processing tables
     ad_parallel_updates_pkg.purge_processed_units
                                         (X_owner  => 'FEM',
                                          X_table  => 'FEM_INTG_OGL_CCID_MAP',
                                          X_script => FEM_INTG_DIM_RULE_ENG_PKG.pv_coa_id);

     ad_parallel_updates_pkg.delete_update_information
                                         (X_update_type => ad_parallel_updates_pkg.ROWID_RANGE,
                                          X_owner       =>  'FEM',
                                          X_table       =>  'FEM_INTG_OGL_CCID_MAP',
                                          X_script      =>  FEM_INTG_DIM_RULE_ENG_PKG.pv_coa_id);

     -- submit update CCID worker
     AD_CONC_UTILS_PKG.submit_subrequests( X_errbuf                    => X_errbuf,
                                           X_retcode                   => x_completion_code,
                                           X_WorkerConc_app_shortname  => 'FEM',
                                           X_WorkerConc_progname       => 'FEM_INTG_DIM_RULE_WORKER',
                                           X_batch_size                => pv_batch_size,
                                           X_Num_Workers               => v_Num_Workers,
                                           X_Argument4                 => FEM_INTG_DIM_RULE_ENG_PKG.pv_coa_id,
                                           X_Argument5                 => FEM_INTG_DIM_RULE_ENG_PKG.pv_gvsc_id,
                                           X_Argument6                 => FEM_INTG_DIM_RULE_ENG_PKG.pv_max_ccid_processed,
                                           X_Argument7                 => FEM_INTG_DIM_RULE_ENG_PKG.pv_max_ccid_to_be_mapped
                                         );

     IF x_completion_code = 2 THEN

       RAISE FEM_INTG_DIM_RULE_worker_err;

     END IF;

     --
     -- Update dimension rule definitions for single segment/value rules
     --
     -- Start bug fix 5844990
     BEGIN
     --Added the fix for 9114881

      BEGIN
      select min(map.code_combination_id)
        INTO l_new_max_ccid_processed
         FROM gl_code_combinations gcc,
         fem_intg_ogl_ccid_map map
         WHERE gcc.chart_of_accounts_id = FEM_INTG_DIM_RULE_ENG_PKG.pv_coa_id
         AND gcc.summary_flag = 'N'
         AND map.code_combination_id = gcc.code_combination_id
         AND map.global_vs_combo_id = FEM_INTG_DIM_RULE_ENG_PKG.pv_gvsc_id
         AND ( map.COMPANY_COST_CENTER_ORG_ID = -1 OR
                  map.NATURAL_ACCOUNT_ID = -1 OR
                  map.LINE_ITEM_ID = -1 OR
                  map.PRODUCT_ID = -1 OR
                  map.CHANNEL_ID = -1 OR
                  map.PROJECT_ID = -1 OR
                  map.CUSTOMER_ID = -1 OR
                  map.ENTITY_ID = -1 OR
                  map.INTERCOMPANY_ID = -1 OR
                  map.USER_DIM1_ID = -1 OR
                  map.USER_DIM2_ID = -1 OR
                  map.USER_DIM3_ID = -1 OR
                  map.USER_DIM4_ID = -1 OR
                  map.USER_DIM5_ID = -1 OR
                  map.USER_DIM6_ID = -1 OR
                  map.USER_DIM7_ID = -1 OR
                  map.USER_DIM8_ID = -1 OR
                  map.USER_DIM9_ID = -1 OR
                  map.USER_DIM10_ID = -1 OR
                  map.TASK_ID = -1 OR
                  map.EXTENDED_ACCOUNT_TYPE = '-1');

     EXCEPTION
     WHEN OTHERS THEN
          FEM_ENGINES_PKG.Tech_Message(
          p_severity => pc_log_level_statement,
          p_module   => v_module_name || 'Value of Max_ccid_processed',
          p_msg_text => 'USING ' ||
             TO_CHAR(l_new_max_ccid_processed) || ', ' ||
               'for  unmapped accounts excepton raised'
           );


       END;


       FEM_ENGINES_PKG.User_Message(
         p_app_name => 'FEM',
         p_msg_text => 'Value of Max_ccid_processed  '||l_new_max_ccid_processed ||' at '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')
         );

        FEM_ENGINES_PKG.Tech_Message(
          p_severity => pc_log_level_statement,
          p_module   => v_module_name || 'Value of Max_ccid_processed',
          p_msg_text => 'USING ' ||
             TO_CHAR(l_new_max_ccid_processed) || ', ' ||
               'for  unmapped accounts'
           );

       SELECT min(gcc.code_combination_id) - 1
         INTO v_max_ccid_to_be_mapped
         FROM gl_code_combinations gcc,
              fem_intg_ogl_ccid_map map
        WHERE gcc.chart_of_accounts_id = FEM_INTG_DIM_RULE_ENG_PKG.pv_coa_id
          AND gcc.summary_flag = 'N'
          AND gcc.code_combination_id BETWEEN NVL(l_new_max_ccid_processed ,FEM_INTG_DIM_RULE_ENG_PKG.pv_max_ccid_processed)
                                          AND FEM_INTG_DIM_RULE_ENG_PKG.pv_max_ccid_to_be_mapped
          AND map.code_combination_id = gcc.code_combination_id
          AND map.global_vs_combo_id = FEM_INTG_DIM_RULE_ENG_PKG.pv_gvsc_id
          AND ( map.COMPANY_COST_CENTER_ORG_ID = -1 OR
                map.NATURAL_ACCOUNT_ID = -1 OR
                map.LINE_ITEM_ID = -1 OR
                map.PRODUCT_ID = -1 OR
                map.CHANNEL_ID = -1 OR
                map.PROJECT_ID = -1 OR
                map.CUSTOMER_ID = -1 OR
                map.ENTITY_ID = -1 OR
                map.INTERCOMPANY_ID = -1 OR
                map.USER_DIM1_ID = -1 OR
                map.USER_DIM2_ID = -1 OR
                map.USER_DIM3_ID = -1 OR
                map.USER_DIM4_ID = -1 OR
                map.USER_DIM5_ID = -1 OR
                map.USER_DIM6_ID = -1 OR
                map.USER_DIM7_ID = -1 OR
                map.USER_DIM8_ID = -1 OR
                map.USER_DIM9_ID = -1 OR
                map.USER_DIM10_ID = -1 OR
                map.TASK_ID = -1 OR
                map.EXTENDED_ACCOUNT_TYPE = '-1');

       EXCEPTION WHEN OTHERS THEN
       NULL;
     END;

     FEM_ENGINES_PKG.User_Message(
         p_app_name => 'FEM',
         p_msg_text => 'set max_ccid_processed to v_max_ccid_to_be_mapped  value : '||v_max_ccid_to_be_mapped ||' at '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')
         );

        FEM_ENGINES_PKG.Tech_Message(
          p_severity => pc_log_level_statement,
          p_module   => v_module_name || 'Value of v_max_ccid_to_be_mapped',
          p_msg_text => 'USING ' ||
             TO_CHAR(v_max_ccid_to_be_mapped) || ', ' ||
               'for  unmapped accounts'
           );
     --end bugfix 9114881

     UPDATE FEM_INTG_DIM_RULE_DEFS
     SET MAX_CCID_PROCESSED = NVL( v_max_ccid_to_be_mapped,
                                   FEM_INTG_DIM_RULE_ENG_PKG.pv_max_ccid_to_be_mapped )
     WHERE DIM_RULE_OBJ_DEF_ID IN (   SELECT defs.dim_rule_obj_def_id
                                        FROM fem_intg_dim_rules idr,
                                             fem_object_definition_b fodb,
                                             fem_xdim_dimensions fxd,
                                             fem_intg_dim_rule_defs defs,
                                             fem_tab_columns_b ftcb
                                       WHERE ftcb.table_name = 'FEM_BALANCES'
                                         AND ftcb.fem_data_type_code = 'DIMENSION'
                                         AND ftcb.dimension_id = fxd.dimension_id
                                         AND DECODE(ftcb.column_name,'INTERCOMPANY_ID', 0, fxd.dimension_id) = idr.dimension_id
                                         AND idr.chart_of_accounts_id = FEM_INTG_DIM_RULE_ENG_PKG.pv_coa_id
                                         AND idr.dim_rule_obj_id = fodb.object_id
                                         AND defs.dim_rule_obj_def_id = fodb.object_definition_id);
                                         --Bugfix 5946597
                                         --AND defs.dim_mapping_option_code IN ('SINGLESEG','SINGLEVAL') );

     -- End bug fix 5844990
     x_row_count_tot := SQL%ROWCOUNT;

     COMMIT;

     FEM_ENGINES_PKG.Tech_Message(
         p_severity => pc_log_level_statement,
         p_module   => v_module_name || '.cnt_update_FEM_INTG_DIM_RULE_DEFS',
         p_msg_text => x_row_count_tot
        );

     FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_statement,
      p_module   => v_module_name || '.end_mapping_table',
      p_msg_text => 'end update mapping table'
    );

     -- Start bug Fix 5579716
     BEGIN
        OPEN fch_vs_cursor FOR v_fch_vs_select_stmt USING FEM_INTG_DIM_RULE_ENG_PKG.pv_fem_vs_id;
        FETCH fch_vs_cursor INTO v_gcs_vs_id;

        IF (v_gcs_vs_id IS NOT NULL) THEN

            -- submit entity orgs synch program
            v_request_id := FND_REQUEST.submit_request( application => 'GCS',
                                                        program     => 'FCH_UPDATE_ENTITY_ORGS',
                                                        sub_request => FALSE);

            FEM_ENGINES_PKG.User_Message(
              p_app_name => 'FEM',
              p_msg_text => 'Submitted Update Entity Organizations Request ' || v_request_id
            );

        END IF;

        CLOSE fch_vs_cursor;

        EXCEPTION WHEN OTHERS THEN NULL;
     END;
     -- End bug Fix 5579716

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_procedure,
      --bugfix 8780516
      p_module   => v_module_name || '.end',
      p_app_name => 'FEM',
      p_msg_name => 'FEM_GL_POST_202',
      p_token1   => 'FUNC_NAME',
      p_value1   => v_func_name,
      p_token2   => 'TIME',
      p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
    );

  EXCEPTION
    -- bugfix 8780516
    --WHEN FEM_INTG_DIM_RULE_ulock_err THEN
    WHEN FEM_INTG_DIM_RULE_worker_err THEN

      ROLLBACK;
      --bugfix 8780516
      /*
        FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_exception,
        p_module   => pc_module_name||c_func_name || '.ulock_err_exception',
        p_app_name => 'FEM',
        p_msg_name => 'FEM_INTG_DIM_RULE_ULOCK_EXISTS'
      );

      FEM_ENGINES_PKG.User_Message(
        p_app_name => 'FEM',
        p_msg_name => 'FEM_INTG_DIM_RULE_ULOCK_EXISTS'
      );

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_procedure,
        p_module   => pc_module_name||c_func_name||'.ulock_err_exception',
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_203',
        p_token1   => 'FUNC_NAME',
        p_value1   => c_func_name,
        p_token2   => 'TIME',
        p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
      */

      FEM_ENGINES_PKG.Tech_Message(
         p_severity => pc_log_level_statement,
         p_module   => v_module_name || '.worker_err',
         p_msg_text => 'Dimension Rule Worker Error: ' || X_errbuf
       );

      FEM_ENGINES_PKG.User_Message(
         p_app_name => 'FEM',
         p_msg_text => 'Dimension Rule Worker Error: ' || X_errbuf
      );

      x_completion_code := 2;

    WHEN OTHERS THEN
      FEM_ENGINES_PKG.Tech_Message
         (p_severity => pc_log_level_statement
         ,p_module   => pc_module_name||c_func_name
         ,p_msg_text => 'Error: ' || pv_progress);

      FEM_ENGINES_PKG.Tech_Message
         (p_severity => pc_log_level_statement
         ,p_module   => pc_module_name||c_func_name
         ,p_msg_text => 'Error: ' || sqlerrm);

      FEM_ENGINES_PKG.User_Message
       (p_msg_text => sqlerrm);

      FEM_ENGINES_PKG.Tech_Message
       (p_severity    => pc_log_level_procedure
       ,p_module   => pc_module_name||c_func_name||'.unexpected_exception'
       ,p_app_name => 'FEM'
       ,p_msg_name => 'FEM_GL_POST_203'
       ,p_token1   => 'FUNC_NAME'
       ,p_value1   => c_func_name
       ,p_token2   => 'TIME'
       ,p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));


     x_completion_code := 2;
  END;


  /* ======================================================================
    Procedure
      Populate_Single_Segment
    Purpose
      This routine is a private routine called by the Detail_Single_Segment
      routine. It populates dimension member tables for a single segment
      mapping case. The routine constructs MERGE statements dynamically based
      a type associated value set.

      The following is a sample dynamic MERGE statement for _B table
      in a case of Independent value set:

        MERGE INTO p_member_b_table_name B
  USING (
          SELECT
            :p_vs_id VALUE_SET_ID,
            FLEX_VALUE_ID MEMBER_ID,
            FLEX_VALUE MEMBER_DISPLAY_CODE,
	    --bugfix 8780516
            ENABLED_FLAG
          FROM
            FND_FLEX_VALUES
          WHERE
            FLEX_VALUE_SET_ID = :v_vs_id_b AND
            SUMMARY_FLAG = 'N'
        ) S
        ON (
          B.VALUE_SET_ID = S.VALUE_SET_ID AND
          B.<p_member_display_code_col> = S.MEMBER_DISPLAY_CODE
        )
        WHEN MATCHED THEN UPDATE
          SET B.LAST_UPDATE_DATE = SYSDATE
        WHEN NOT MATCHED THEN INSERT (
          VALUE_SET_ID,
          <p_member_col>,
          <p_member_display_code_col>,
          ENABLED_FLAG,
          PERSONAL_FLAG,
          READ_ONLY_FLAG,
          OBJECT_VERSION_NUMBER,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN
        ) VALUES (
          S.VALUE_SET_ID,
          S.MEMBER_ID,
          S.MEMBER_DISPLAY_CODE,
	  --bugfix 8780516
          S.ENABLED_FLAG,
          'N',
          'Y',
          1,
          :b_sysdate,
          :pv_user_id,
          :b_sysdate,
          :pv_user_id,
          :pv_login_id
        )
        USING p_vs_id, pv_mapped_segs(1).vs_id,
              SYSDATE, pv_user_id, SYSDATE, pv_user_id, pv_login_id
  ====================================================================== */
  PROCEDURE Populate_Single_Segment(
    p_dim_id IN NUMBER,
    p_vs_id IN NUMBER,
    p_member_b_table_name IN VARCHAR2,
    p_member_tl_table_name IN VARCHAR2,
    p_member_col IN VARCHAR2,
    p_member_display_code_col IN VARCHAR2,
    p_member_name_col IN VARCHAR2,
    x_row_count_tot OUT NOCOPY NUMBER
  ) IS
    v_module_name VARCHAR2(100);
    v_func_name VARCHAR2(100);
    v_row_count_tot1 NUMBER;
    v_row_count_tot2 NUMBER;
    v_stmt1 VARCHAR2(4000);
    v_stmt2 VARCHAR2(4000);
    v_stmt3 VARCHAR2(4000);
    v_stmt4 VARCHAR2(4000);
    v_using_b VARCHAR2(4000);
    v_using_tl VARCHAR2(4000);
    v_vs_id_b NUMBER;
    v_member_id_val VARCHAR2(50);
    v_source_lang VARCHAR2(50);
    v_cr VARCHAR2(100);
  BEGIN
    v_module_name := 'fem.plsql.fem_intg_dim.populate_single_segment';
    v_func_name := 'FEM_INTG_NEW_DIM_MEMBER_PKG.Populate_Single_Segment';

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_procedure,
      p_module   => v_module_name || '.begin',
      p_app_name => 'FEM',
      p_msg_name => 'FEM_GL_POST_201',
      p_token1   => 'FUNC_NAME',
      p_value1   => v_func_name,
      p_token2   => 'TIME',
      p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
    );

    IF FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(1).table_validated_flag = 'N' THEN

      v_using_b := '
      USING (
        SELECT
          :p_vs_id VALUE_SET_ID,
          FLEX_VALUE_ID MEMBER_ID,
          FLEX_VALUE MEMBER_DISPLAY_CODE,
	  --bugfix 8780516
          ENABLED_FLAG
        FROM
          FND_FLEX_VALUES
        WHERE
          FLEX_VALUE_SET_ID = :v_vs_id_b AND
          SUMMARY_FLAG = ''N''
      ) S';

      v_using_tl := '
      USING (
        SELECT
          M.VALUE_SET_ID,
          T.FLEX_VALUE_ID MEMBER_COL,
          T.FLEX_VALUE_MEANING MEMBER_NAME,
          T.DESCRIPTION MEMBER_DESC,
          T.LANGUAGE LANGUAGE_CODE,
          T.SOURCE_LANG
        FROM
          ' || p_member_b_table_name || ' M,
          FND_FLEX_VALUES B,
          FND_FLEX_VALUES_TL T
        WHERE
          M.VALUE_SET_ID = :p_vs_id AND
          T.FLEX_VALUE_ID = M.' || p_member_col || ' AND
          B.FLEX_VALUE_ID = T.FLEX_VALUE_ID AND
          B.FLEX_VALUE_SET_ID = :v_vs_id_b AND
          B.SUMMARY_FLAG = ''N''
      ) S';

      v_vs_id_b := FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(1).vs_id;

      v_member_id_val := 'S.MEMBER_ID';
      v_source_lang := 'S.SOURCE_LANG';

    ELSE

      IF FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(1).where_clause IS NOT NULL THEN
        v_cr := '
        ';
      ELSE
        v_cr := '';
      END IF;

     --bugfix 8780516
      v_using_b := '
      USING (
        SELECT
          :p_vs_id || :v_vs_id_b VALUE_SET_ID,
          ' || FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(1).val_col_name || ' MEMBER_DISPLAY_CODE,
          ''Y'' ENABLED_FLAG
        FROM
          ' || FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(1).table_name ||
          v_cr || FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(1).where_clause || '
      ) S';

     --bugfix 8780516
      v_using_tl := '
      USING (
        SELECT
          B.VALUE_SET_ID,
          B.' || p_member_col || ' MEMBER_COL,
          V.MEMBER_NAME,
          V.MEMBER_DESC,
          L.LANGUAGE_CODE
        FROM (
          SELECT
            ' || FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(1).val_col_name || ' MEMBER_DISPLAY_CODE,
            ' || FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(1).val_col_name || ' MEMBER_NAME,
            ' || NVL(FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(1).meaning_col_name, 'NULL') || ' MEMBER_DESC
          FROM
            ' || FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(1).table_name ||
            v_cr || FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(1).where_clause || '
          ) V,
          ' || p_member_b_table_name || ' B,
          FND_LANGUAGES L
        WHERE
          B.VALUE_SET_ID = :p_vs_id || :v_vs_id_b AND
          B.' || p_member_display_code_col || ' = V.MEMBER_DISPLAY_CODE AND
          L.INSTALLED_FLAG IN (''B'', ''I'')
      ) S';

      v_vs_id_b := '';

      v_member_id_val := 'FND_FLEX_VALUES_S.NEXTVAL';
      v_source_lang := 'S.LANGUAGE_CODE';

    END IF;
    -- Bugfix 5333726
    v_stmt1 := '
      MERGE INTO ' || p_member_b_table_name || ' B' || v_using_b || '
      ON (
        B.VALUE_SET_ID = S.VALUE_SET_ID AND
        B.' || p_member_display_code_col || ' = S.MEMBER_DISPLAY_CODE
      )';
    -- Bug 4393061 - changed read_only_flag to 'N'
    --bugfix 8780516
    v_stmt2 := '
      WHEN MATCHED THEN UPDATE
        SET B.LAST_UPDATE_DATE = SYSDATE,
        B.ENABLED_FLAG = S.ENABLED_FLAG
      WHEN NOT MATCHED THEN INSERT (
        VALUE_SET_ID,
        ' || p_member_col || ',
        ' || p_member_display_code_col || ',
        ENABLED_FLAG,
        PERSONAL_FLAG,
        READ_ONLY_FLAG,
        OBJECT_VERSION_NUMBER,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN
      ) VALUES (
        S.VALUE_SET_ID,
        ' || v_member_id_val || ',
        S.MEMBER_DISPLAY_CODE,
        S.ENABLED_FLAG,
        ''N'',
        ''N'',
        1,
        :b_sysdate,
        :pv_user_id,
        :b_sysdate,
        :pv_user_id,
        :pv_login_id
      )';

    v_stmt3 := '
      MERGE INTO ' || p_member_tl_table_name || ' TL' || v_using_tl || '
      ON (
        TL.VALUE_SET_ID = S.VALUE_SET_ID AND
        TL.' || p_member_col || ' = S.MEMBER_COL AND
        TL.LANGUAGE = S.LANGUAGE_CODE
      )';

    v_stmt4 := '
      WHEN MATCHED THEN UPDATE
        SET TL.LAST_UPDATE_DATE = SYSDATE,
        TL.DESCRIPTION = S.MEMBER_DESC
      WHEN NOT MATCHED THEN INSERT (
        VALUE_SET_ID,
        ' || p_member_col || ',
        ' || p_member_name_col || ',
        DESCRIPTION,
        LANGUAGE,
        SOURCE_LANG,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN
      ) VALUES (
        S.VALUE_SET_ID,
        S.MEMBER_COL,
        S.MEMBER_NAME,
        S.MEMBER_DESC,
        S.LANGUAGE_CODE,
        ' || v_source_lang || ',
        :b_sysdate,
        :pv_user_id,
        :b_sysdate,
        :pv_user_id,
        :pv_login_id
      )';

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_statement,
      p_module   => v_module_name || '.dsql_merge_into_' ||
                    p_member_b_table_name,
      p_msg_text => v_stmt1
    );

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_statement,
      p_module   => v_module_name || '.dsql_merge_into_' ||
                    p_member_b_table_name,
      p_msg_text => v_stmt2
    );

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_statement,
      p_module   => v_module_name || '.dsql_merge_into_' ||
                    p_member_b_table_name,
      p_msg_text => 'USING ' ||
        TO_CHAR(p_vs_id) || ', ' ||
        TO_CHAR(v_vs_id_b) || ', ' ||
        TO_CHAR(SYSDATE, 'YYYY/MM/DD') || ', ' ||
        TO_CHAR(pv_user_id) || ', ' ||
        TO_CHAR(SYSDATE, 'YYYY/MM/DD') || ', ' ||
        TO_CHAR(pv_user_id) || ', ' ||
        TO_CHAR(pv_login_id)
    );

    EXECUTE IMMEDIATE v_stmt1 || v_stmt2
    USING
      p_vs_id,
      v_vs_id_b,
      SYSDATE,
      pv_user_id,
      SYSDATE,
      pv_user_id,
      pv_login_id;

    v_row_count_tot1 := SQL%ROWCOUNT;

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_statement,
      p_module   => v_module_name || '.cnt_merge_into_' ||
                    p_member_tl_table_name,
      p_msg_text => v_row_count_tot1
    );

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_statement,
      p_module   => v_module_name || '.dsql_merge_into_' ||
                    p_member_tl_table_name,
      p_msg_text => v_stmt3
    );

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_statement,
      p_module   => v_module_name || '.dsql_merge_into_' ||
                    p_member_tl_table_name,
      p_msg_text => v_stmt4
    );

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_statement,
      p_module   => v_module_name || '.dsql_merge_into_' ||
                    p_member_tl_table_name,
      p_msg_text => 'USING ' ||
        TO_CHAR(p_vs_id) || ', ' ||
        TO_CHAR(v_vs_id_b) || ', ' ||
        TO_CHAR(SYSDATE, 'YYYY/MM/DD') || ', ' ||
        TO_CHAR(pv_user_id) || ', ' ||
        TO_CHAR(SYSDATE, 'YYYY/MM/DD') || ', ' ||
        TO_CHAR(pv_user_id) || ', ' ||
        TO_CHAR(pv_login_id)
    );

    EXECUTE IMMEDIATE v_stmt3 || v_stmt4
    USING
      p_vs_id,
      v_vs_id_b,
      SYSDATE,
      pv_user_id,
      SYSDATE,
      pv_user_id,
      pv_login_id;

    v_row_count_tot2 := SQL%ROWCOUNT;

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_statement,
      p_module   => v_module_name || '.cnt_merge_into_' ||
                    p_member_tl_table_name,
      p_msg_text => v_row_count_tot2
    );

    x_row_count_tot := v_row_count_tot1 + v_row_count_tot2;

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_procedure,
      p_module   => v_module_name || '.end',
      p_app_name => 'FEM',
      p_msg_name => 'FEM_GL_POST_202',
      p_token1   => 'FUNC_NAME',
      p_value1   => v_func_name,
      p_token2   => 'TIME',
      p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
    );

  END Populate_Single_Segment;


  /* ======================================================================
    Procedure
      Detail_Single_Segment
    Purpose
      This routine populates dimension member tables as well as dimension
      member attribute tables by calling the Populate_Single_Segment and
      the Populate_Dimension_Attribute routines, respectively.

      The routine also updates FEM_INTG_OGL_CCID_MAP table through
      a dynamically constructed UPDATE statement based on dimension.

      The following is a sample dynamic UPDATE statement for Company Cost
      Center Organization:

        UPDATE FEM_INTG_OGL_CCID_MAP M
        SET (COMPANY_COST_CENTER_ORG_ID) = (
          SELECT
            B.COMPANY_COST_CENTER_ORG_ID
          FROM
            FEM_CCTR_ORGS_B B,
            GL_CODE_COMBINATIONS G
          WHERE
            B.VALUE_SET_ID = :pv_fem_vs_id AND
            B.CCTR_ORG_DISPLAY_CODE =
              G.<pv_mapped_segs(1).application_column_name> AND
            G.CHART_OF_ACCOUNTS_ID = :pv_coa_id AND
            G.SUMMARY_FLAG = 'N' AND
            M.CODE_COMBINATION_ID = G.CODE_COMBINATION_ID
        )
        WHERE M.GLOBAL_VS_COMBO_ID = :pv_gvsc_id
        AND M.CODE_COMBINATION_ID IN (
          SELECT
            M2.CODE_COMBINATION_ID
          FROM
            FEM_CCTR_ORGS_B B2,
            FEM_INTG_OGL_CCID_MAP M2,
            GL_CODE_COMBINATIONS G2
          WHERE
            B2.VALUE_SET_ID = :pv_fem_vs_id AND
            B2.CCTR_ORG_DISPLAY_CODE =
              G2.<pv_mapped_segs(1).application_column_name> AND
            G2.CHART_OF_ACCOUNTS_ID = :pv_coa_id AND
            G2.SUMMARY_FLAG = 'N' AND
            M2.CODE_COMBINATION_ID = G2.CODE_COMBINATION_ID AND
            M2.GLOBAL_VS_COMBO_ID = :pv_gvsc_id AND
            M2.CODE_COMBINATION_ID BETWEEN :pv_max_ccid_processed+1 AND
                                           :pv_max_ccid_to_be_mapped
        )
        USING pv_fem_vs_id, pv_coa_id, pv_gvsc_id, pv_fem_vs_id, pv_coa_id,
              pv_gvsc_id, pv_max_ccid_processed+1, pv_max_ccid_to_be_mapped

      Note that there is a possible redundant where clause when updating the
      FEM_INTG_OGL_CCID_MAP table. For details, see bug4350641.

  ====================================================================== */
  PROCEDURE Detail_Single_Segment(
    x_completion_code OUT NOCOPY NUMBER,
    x_row_count_tot OUT NOCOPY NUMBER
  ) IS
    v_module_name VARCHAR2(100);
    v_func_name VARCHAR2(100);

     --bugfix 8780516
    /*v_lockhandle VARCHAR2(100);
    v_lock_result NUMBER;
    v_loop_counter NUMBER;*/
    v_member_col            VARCHAR2(30);

    --bugfix 8780516
    /*v_stmt1 VARCHAR2(4000);
    v_stmt2 VARCHAR2(4000);
    v_stmt3 VARCHAR2(4000);*/

    v_completion_code NUMBER;
    v_row_count_tot NUMBER;


    --Bugfix 9114881
    l_new_max_ccid_processed           NUMBER;


     --bugfix 8780516
    /*v_column_list VARCHAR2(1000);
    v_value_list VARCHAR2(1000);
    v_result      VARCHAR2(20);*/

    FEM_INTG_DIM_RULE_fatal_err EXCEPTION;
    FEM_INTG_DIM_RULE_ulock_err EXCEPTION;
    FEM_INTG_DIM_RULE_attr_err EXCEPTION;

    --start bug fix 5560443
    /*
    CURSOR ColumnList IS
      SELECT COLUMN_NAME
      FROM FEM_TAB_COLUMNS_B
      WHERE TABLE_NAME = 'FEM_BALANCES'
      AND FEM_DATA_TYPE_CODE = 'DIMENSION'
      AND DIMENSION_ID = FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_id;
    --bugfix 8780516
    ColumnList_rec ColumnList%ROWTYPE;
    */
    --End bug fix 5560443

    -- start bug fix 5377544
    v_Num_Workers            NUMBER;
    X_errbuf                 VARCHAR2(2000);
    v_dim_rule_req_count     NUMBER;
    FEM_INTG_DIM_RULE_worker_err EXCEPTION;
    -- end bug fix 5377544

    --bugfix 8780516
    -- Start bug fix 5844990
    v_max_ccid_to_be_mapped  NUMBER;
    -- End bug fix 5844990
  BEGIN

    v_module_name := 'fem.plsql.fem_intg_dim.detail_single_segment';
    v_func_name := 'FEM_INTG_NEW_DIM_MEMBER_PKG.Detail_Single_Segment';

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_procedure,
      p_module   => v_module_name || '.begin',
      p_app_name => 'FEM',
      p_msg_name => 'FEM_GL_POST_201',
      p_token1   => 'FUNC_NAME',
      p_value1   => v_func_name,
      p_token2   => 'TIME',
      p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
    );

    x_completion_code :=  0;
    x_row_count_tot := 0;

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_statement,
      p_module   => v_module_name || '.begin_dim_member_populate_' ||
                    LOWER(FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_varchar_label),
      p_msg_text => 'begin '||FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_varchar_label||
                    ' dimension member population'
    );

   --bugfix 8780516
   /*
    DBMS_LOCK.ALLOCATE_UNIQUE(
      'FEM_INTG_DIM_RULE' || FEM_INTG_DIM_RULE_ENG_PKG.pv_fem_vs_id,
      v_lockhandle,
      pc_expiration_secs
    );

    v_loop_counter := 0;

    LOOP
      IF v_loop_counter > pc_loop_counter_max THEN

        FEM_ENGINES_PKG.Tech_Message(
          p_severity => pc_log_level_statement,
          p_module   => v_module_name || '.ulock_err',
          p_msg_text => 'raising FEM_INTG_DIM_RULE_ulock_err'
        );

        RAISE FEM_INTG_DIM_RULE_ulock_err;
      END IF;

      v_lock_result := DBMS_LOCK.REQUEST(
                         v_lockhandle,
                         pc_lockmode,
                         pc_lock_timeout,
                         pc_release_on_commit
                       );

      IF v_lock_result = 0 OR v_lock_result = 4 THEN
        EXIT;
      ELSE
        v_loop_counter := v_loop_counter + 1;

        FEM_ENGINES_PKG.Tech_Message(
          p_severity => pc_log_level_statement,
          p_module   => v_module_name || '.ulock_sleep',
          p_msg_text => 'sleeping ' || pc_sleep_second || ' second'
        );

        DBMS_LOCK.SLEEP(pc_sleep_second);
      END IF;

    END LOOP;*/

    --
    -- Populate Single Segment member tables for
    -- COMPANY_COST_CENTER_ORG/INTERCOMPANY
    --
    IF FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_varchar_label = 'COMPANY_COST_CENTER_ORG' OR
       FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_varchar_label = 'INTERCOMPANY' THEN

      IF FEM_INTG_DIM_RULE_ENG_PKG.pv_balancing_segment_num = 1 THEN
        -- When a Single Segment is a Balancing Segment
        Populate_Single_Segment(
          p_dim_id                  => FEM_INTG_DIM_RULE_ENG_PKG.pv_com_dim_id,
          p_vs_id                   => FEM_INTG_DIM_RULE_ENG_PKG.pv_com_vs_id,
          p_member_b_table_name     => 'FEM_COMPANIES_B',
          p_member_tl_table_name    => 'FEM_COMPANIES_TL',
          p_member_col              => 'COMPANY_ID',
          p_member_display_code_col => 'COMPANY_DISPLAY_CODE',
          p_member_name_col         => 'COMPANY_NAME',
          x_row_count_tot           => v_row_count_tot
        );
        x_row_count_tot := x_row_count_tot + v_row_count_tot;

      ELSE
        -- When a Single Segment is a Cost Center Segment
        Populate_Single_Segment(
          p_dim_id                  => FEM_INTG_DIM_RULE_ENG_PKG.pv_cc_dim_id,
          p_vs_id                   => FEM_INTG_DIM_RULE_ENG_PKG.pv_cc_vs_id,
          p_member_b_table_name     => 'FEM_COST_CENTERS_B',
          p_member_tl_table_name    => 'FEM_COST_CENTERS_TL',
          p_member_col              => 'COST_CENTER_ID',
          p_member_display_code_col => 'COST_CENTER_DISPLAY_CODE',
          p_member_name_col         => 'COST_CENTER_NAME',
          x_row_count_tot           => v_row_count_tot
        );
        x_row_count_tot := x_row_count_tot + v_row_count_tot;

      END IF;

    END IF;

    IF FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_varchar_label = 'INTERCOMPANY' THEN
      v_member_col := FEM_INTG_DIM_RULE_ENG_PKG.pv_cctr_org_member_col;
    ELSE
      v_member_col := FEM_INTG_DIM_RULE_ENG_PKG.pv_member_col;
    END IF;

    --
    -- Populate Single Segment member tables
    --
    Populate_Single_Segment(
      p_dim_id                  => FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_id,
      p_vs_id                   => FEM_INTG_DIM_RULE_ENG_PKG.pv_fem_vs_id,
      p_member_b_table_name     => FEM_INTG_DIM_RULE_ENG_PKG.pv_member_b_table_name,
      p_member_tl_table_name    => FEM_INTG_DIM_RULE_ENG_PKG.pv_member_tl_table_name,
      p_member_col              => v_member_col,
      p_member_display_code_col => FEM_INTG_DIM_RULE_ENG_PKG.pv_member_display_code_col,
      p_member_name_col         => FEM_INTG_DIM_RULE_ENG_PKG.pv_member_name_col,
      x_row_count_tot           => v_row_count_tot
    );
    x_row_count_tot := x_row_count_tot + v_row_count_tot;

    --
    -- Populate dimension attributes
    -- (COMPANY and CCTR do not have attributes to populate)
    --
    FEM_ENGINES_PKG.User_Message(
      p_app_name => 'FEM',
      p_msg_name => 'FEM_INTG_DIM_MEMB_501'
    );

    Populate_Dimension_Attribute(
      p_summary_flag       => NVL(FEM_INTG_DIM_RULE_ENG_PKG.pv_summary_flag, 'N'),
      x_completion_code    => v_completion_code,
      x_row_count_tot      => v_row_count_tot
    );

    IF v_completion_code = 2 THEN

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_statement,
        p_module   => v_module_name || '.populate_attribute_err',
        p_msg_text => 'raising FEM_INTG_DIM_RULE_attr_err'
      );

      RAISE FEM_INTG_DIM_RULE_attr_err;
    END IF;

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_statement,
      p_module   => v_module_name || '.populate_attribute_err_return',
      p_msg_text => 'v_completion_code=' || v_completion_code ||
                    ', v_row_count_tot=' || v_row_count_tot
    );

    x_row_count_tot := x_row_count_tot + v_row_count_tot;

    COMMIT;

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_statement,
      p_module   => v_module_name || '.end_dim_member_populate_' ||
                    lower(FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_varchar_label),
      p_msg_text => 'end ' || FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_varchar_label
                    || ' dimension member population'
    );

    /*
      Although the Dimension Rule Engine should create dimension values for
      the Geography dimension if there is a dimension rule defined for it,
      it should not attempt to update FEM_INTG_OGL_CCID_MAP with its members.
      This is because the GEOGRAPHY_ID column does not exist in both
      FEM_BALANCES and FEM_INTG_OGL_CCID_MAP tables. For details,
      see bug4093543.
    */
    --Start bug fix 5560443
    /*
    --dedutta: removed the Geography check here
    NonNullFlag := false;
    open ColumnList;
    fetch ColumnList into ColumnList_rec;
    if ColumnList%found then
      NonNullFlag := true;
    end if;
    close ColumnList;

    IF NonNullFlag  THEN
    */
       -- start bug fix 5377544
        IF FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_varchar_label = 'INTERCOMPANY' THEN

    --End bug fix 5560443

             -- Since requests will reach completed phase irrespective of status
             -- Check if any dimension rule requests which are not having completed phase
             -- for any dimension other than org dimension for the same chart of account
             -- If any request found then issue sleep timer
             LOOP
             BEGIN
                   SELECT 1
                     INTO v_dim_rule_req_count
                     FROM dual
                    WHERE EXISTS ( SELECT 1
                                     FROM fnd_concurrent_programs fcp,
                                          fnd_concurrent_requests fcr,
                                          fem_intg_dim_rules idr,
                                          fem_object_definition_b fodb
                                    WHERE fcp.concurrent_program_id = fcr.concurrent_program_id
                                      AND fcp.application_id = fcr.program_application_id
                                      AND fcp.application_id = 274
                                      AND fcp.concurrent_program_name = 'FEM_INTG_DIM_RULE_ENGINE'
                                      AND fcr.phase_code <> 'C'
                                      AND idr.dim_rule_obj_id = fodb.object_id
                                      AND idr.chart_of_accounts_id = FEM_INTG_DIM_RULE_ENG_PKG.pv_coa_id
                                      --Start bug fix 5560443
                                      AND idr.dimension_id <> 0
                                      --End bug fix 5560443
                                      AND fcr.argument1 = fodb.object_definition_id
                                      AND fcr.argument2 = 'MEMBER');
                   DBMS_LOCK.SLEEP(pc_sleep_second);
                   EXCEPTION WHEN NO_DATA_FOUND THEN EXIT;
             END;
             END LOOP;

             select nvl(value,1)*2 no_of_workers
             into v_Num_Workers
             from v$parameter
             where name = 'cpu_count';

             FEM_ENGINES_PKG.User_Message(
               p_app_name => 'FEM',
               p_msg_text => 'Kicking off '||v_Num_Workers||' workers requests at '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')
             );

             FEM_ENGINES_PKG.Tech_Message(
               p_severity => pc_log_level_statement,
               p_module   => v_module_name || '.dsql_update_fem_intg_ogl_ccid_map',
               p_msg_text => 'USING ' ||
                   TO_CHAR(FEM_INTG_DIM_RULE_ENG_PKG.pv_coa_id) || ', ' ||
                   TO_CHAR(FEM_INTG_DIM_RULE_ENG_PKG.pv_gvsc_id)
                 );

             -- AD Parallel framework Manager processing

             --Purge all the info from ad processing tables
              ad_parallel_updates_pkg.purge_processed_units
                                                  (X_owner  => 'FEM',
                                                   X_table  => 'FEM_INTG_OGL_CCID_MAP',
                                                   X_script => FEM_INTG_DIM_RULE_ENG_PKG.pv_coa_id);

              ad_parallel_updates_pkg.delete_update_information
                                                  (X_update_type => ad_parallel_updates_pkg.ROWID_RANGE,
                                                   X_owner       =>  'FEM',
                                                   X_table       =>  'FEM_INTG_OGL_CCID_MAP',
                                                   X_script      =>  FEM_INTG_DIM_RULE_ENG_PKG.pv_coa_id);

              -- submit update CCID worker
              AD_CONC_UTILS_PKG.submit_subrequests( X_errbuf                    => X_errbuf,
                                                    X_retcode                   => v_completion_code,
                                                    X_WorkerConc_app_shortname  => 'FEM',
                                                    X_WorkerConc_progname       => 'FEM_INTG_DIM_RULE_WORKER',
                                                    X_batch_size                => pv_batch_size,
                                                    X_Num_Workers               => v_Num_Workers,
                                                    X_Argument4                 => FEM_INTG_DIM_RULE_ENG_PKG.pv_coa_id,
                                                    X_Argument5                 => FEM_INTG_DIM_RULE_ENG_PKG.pv_gvsc_id,
                                                    X_Argument6                 => FEM_INTG_DIM_RULE_ENG_PKG.pv_max_ccid_processed,
                                                    X_Argument7                 => FEM_INTG_DIM_RULE_ENG_PKG.pv_max_ccid_to_be_mapped
                                                  );

              IF v_completion_code = 2 THEN

                RAISE FEM_INTG_DIM_RULE_worker_err;

              END IF;

              --
              -- Update dimension rule definitions for single segment/value rules
              --bugfix 8780516
              -- Start bug fix 5844990
          BEGIN
          --Added fix for 9114881
          BEGIN

          select min(map.code_combination_id)
            INTO l_new_max_ccid_processed
            FROM gl_code_combinations gcc,
                 fem_intg_ogl_ccid_map map
            WHERE gcc.chart_of_accounts_id = FEM_INTG_DIM_RULE_ENG_PKG.pv_coa_id
            AND gcc.summary_flag = 'N'
            AND map.code_combination_id = gcc.code_combination_id
            AND map.global_vs_combo_id = FEM_INTG_DIM_RULE_ENG_PKG.pv_gvsc_id
            AND ( map.COMPANY_COST_CENTER_ORG_ID = -1 OR
                  map.NATURAL_ACCOUNT_ID = -1 OR
                  map.LINE_ITEM_ID = -1 OR
                  map.PRODUCT_ID = -1 OR
                  map.CHANNEL_ID = -1 OR
                  map.PROJECT_ID = -1 OR
                  map.CUSTOMER_ID = -1 OR
                  map.ENTITY_ID = -1 OR
                  map.INTERCOMPANY_ID = -1 OR
                  map.USER_DIM1_ID = -1 OR
                  map.USER_DIM2_ID = -1 OR
                  map.USER_DIM3_ID = -1 OR
                  map.USER_DIM4_ID = -1 OR
                  map.USER_DIM5_ID = -1 OR
                  map.USER_DIM6_ID = -1 OR
                  map.USER_DIM7_ID = -1 OR
                  map.USER_DIM8_ID = -1 OR
                  map.USER_DIM9_ID = -1 OR
                  map.USER_DIM10_ID = -1 OR
                  map.TASK_ID = -1 OR
                  map.EXTENDED_ACCOUNT_TYPE = '-1');

        EXCEPTION
        WHEN OTHERS THEN
          FEM_ENGINES_PKG.Tech_Message(
          p_severity => pc_log_level_statement,
          p_module   => v_module_name || 'Value of Max_ccid_processed',
          p_msg_text => 'USING ' ||
             TO_CHAR(l_new_max_ccid_processed) || ', ' ||
               'for  unmapped accounts excepton raised'
           );


        END;


       FEM_ENGINES_PKG.User_Message(
         p_app_name => 'FEM',
         p_msg_text => 'Value of Max_ccid_processed  '||l_new_max_ccid_processed ||' at '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')
         );

        FEM_ENGINES_PKG.Tech_Message(
          p_severity => pc_log_level_statement,
          p_module   => v_module_name || 'Value of Max_ccid_processed',
          p_msg_text => 'USING ' ||
             TO_CHAR(l_new_max_ccid_processed) || ', ' ||
               'for  unmapped accounts'
           );


                SELECT min(gcc.code_combination_id) - 1
                  INTO v_max_ccid_to_be_mapped
                  FROM gl_code_combinations gcc,
                       fem_intg_ogl_ccid_map map
                 WHERE gcc.chart_of_accounts_id = FEM_INTG_DIM_RULE_ENG_PKG.pv_coa_id
                   AND gcc.summary_flag = 'N'
                   AND gcc.code_combination_id BETWEEN NVL(l_new_max_ccid_processed ,FEM_INTG_DIM_RULE_ENG_PKG.pv_max_ccid_processed)
                                                   AND FEM_INTG_DIM_RULE_ENG_PKG.pv_max_ccid_to_be_mapped
                   AND map.code_combination_id = gcc.code_combination_id
                   AND map.global_vs_combo_id = FEM_INTG_DIM_RULE_ENG_PKG.pv_gvsc_id
                   AND ( map.COMPANY_COST_CENTER_ORG_ID = -1 OR
                         map.NATURAL_ACCOUNT_ID = -1 OR
                         map.LINE_ITEM_ID = -1 OR
                         map.PRODUCT_ID = -1 OR
                         map.CHANNEL_ID = -1 OR
                         map.PROJECT_ID = -1 OR
                         map.CUSTOMER_ID = -1 OR
                         map.ENTITY_ID = -1 OR
                         map.INTERCOMPANY_ID = -1 OR
                         map.USER_DIM1_ID = -1 OR
                         map.USER_DIM2_ID = -1 OR
                         map.USER_DIM3_ID = -1 OR
                         map.USER_DIM4_ID = -1 OR
                         map.USER_DIM5_ID = -1 OR
                         map.USER_DIM6_ID = -1 OR
                         map.USER_DIM7_ID = -1 OR
                         map.USER_DIM8_ID = -1 OR
                         map.USER_DIM9_ID = -1 OR
                         map.USER_DIM10_ID = -1 OR
                         map.TASK_ID = -1 OR
                         map.EXTENDED_ACCOUNT_TYPE = '-1');

                EXCEPTION WHEN OTHERS THEN NULL;
              END;

              FEM_ENGINES_PKG.User_Message(
                p_app_name => 'FEM',
                p_msg_text => 'set max_ccid_processed to v_max_ccid_to_be_mapped  value : '||v_max_ccid_to_be_mapped ||' at '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')
                );

             FEM_ENGINES_PKG.Tech_Message(
                p_severity => pc_log_level_statement,
                p_module   => v_module_name || 'Value of v_max_ccid_to_be_mapped',
                p_msg_text => 'USING ' ||
                TO_CHAR(v_max_ccid_to_be_mapped) || ', ' ||
               'for  unmapped accounts'
                );
          --end bugfix 9114881

              UPDATE FEM_INTG_DIM_RULE_DEFS
              SET MAX_CCID_PROCESSED = NVL( v_max_ccid_to_be_mapped,
                                            FEM_INTG_DIM_RULE_ENG_PKG.pv_max_ccid_to_be_mapped )
              WHERE DIM_RULE_OBJ_DEF_ID IN (   SELECT defs.dim_rule_obj_def_id
                                                 FROM fem_intg_dim_rules idr,
                                                      fem_object_definition_b fodb,
                                                      fem_xdim_dimensions fxd,
                                                      fem_intg_dim_rule_defs defs,
                                                      fem_tab_columns_b ftcb
                                                WHERE ftcb.table_name = 'FEM_BALANCES'
                                                  AND ftcb.fem_data_type_code = 'DIMENSION'
                                                  AND ftcb.dimension_id = fxd.dimension_id
                                                  AND DECODE(ftcb.column_name,'INTERCOMPANY_ID', 0, fxd.dimension_id) = idr.dimension_id
                                                  AND idr.chart_of_accounts_id = FEM_INTG_DIM_RULE_ENG_PKG.pv_coa_id
                                                  AND idr.dim_rule_obj_id = fodb.object_id
                                                  AND defs.dim_rule_obj_def_id = fodb.object_definition_id);
                                                  --Bugfix 5946597
                                                  --AND defs.dim_mapping_option_code IN ('SINGLESEG','SINGLEVAL') );

              -- End bug fix 5844990
              v_row_count_tot := SQL%ROWCOUNT;

              FEM_ENGINES_PKG.Tech_Message(
                  p_severity => pc_log_level_statement,
                  p_module   => v_module_name || '.cnt_update_FEM_INTG_DIM_RULE_DEFS',
                  p_msg_text => v_row_count_tot
                 );

              x_row_count_tot := x_row_count_tot + v_row_count_tot;

        END IF;

        x_completion_code := v_completion_code;

    --Start bug fix 5560443
    --END IF;
    --End bug fix 5560443

    -- end bug fix 5377544

    COMMIT;

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_statement,
      p_module   => v_module_name || '.end_mapping_table',
      p_msg_text => 'end update mapping table'
    );
    --bugfix 8780516
    -- Start Bugfix 6476319
    IF ( FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_varchar_label = 'LINE_ITEM' OR
         FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_varchar_label = 'NATURAL_ACCOUNT' OR
         FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_varchar_label = 'INTERCOMPANY') THEN

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
                       WHERE sob.chart_of_accounts_id  = FEM_INTG_DIM_RULE_ENG_PKG.pv_coa_id
                         AND maps.code_combination_id   = sob.ret_earn_code_combination_id
                         AND maps.line_item_id        = ln_attr.line_item_id );
      COMMIT;
    END IF;
    -- End Bugfix 6476319

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_procedure,
      p_module   => v_module_name || '.end',
      p_app_name => 'FEM',
      p_msg_name => 'FEM_GL_POST_202',
      p_token1   => 'FUNC_NAME',
      p_value1   => v_func_name,
      p_token2   => 'TIME',
      p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
    );

  EXCEPTION

    WHEN FEM_INTG_DIM_RULE_fatal_err THEN

      ROLLBACK;

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_procedure,
        p_module   => v_module_name || 'unexpected_exception',
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_203',
        p_token1   => 'FUNC_NAME',
        p_value1   => v_func_name,
        p_token2   => 'TIME',
        p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
      );

      x_completion_code := 2;

    WHEN FEM_INTG_DIM_RULE_ulock_err THEN

      ROLLBACK;

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_exception,
        p_module   => v_module_name || '.ulock_err_exception',
        p_app_name => 'FEM',
        p_msg_name => 'FEM_INTG_DIM_RULE_ULOCK_EXISTS'
      );

      FEM_ENGINES_PKG.User_Message(
        p_app_name => 'FEM',
        p_msg_name => 'FEM_INTG_DIM_RULE_ULOCK_EXISTS'
      );

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_procedure,
        p_module   => v_module_name || '.ulock_err_exception',
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_203',
        p_token1   => 'FUNC_NAME',
        p_value1   => v_func_name,
        p_token2   => 'TIME',
        p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
      );

      x_completion_code := 2;

    WHEN FEM_INTG_DIM_RULE_attr_err THEN

      ROLLBACK;

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_exception,
        p_module   => v_module_name || '.attr_err_exception',
        p_app_name => 'FEM',
        p_msg_name => 'FEM_INTG_DIM_RULE_ATTR_FAILURE'
      );

      FEM_ENGINES_PKG.User_Message(
        p_app_name => 'FEM',
        p_msg_name => 'FEM_INTG_DIM_RULE_ATTR_FAILURE'
      );

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_procedure,
        p_module   => v_module_name || '.attr_err_exception',
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_203',
        p_token1   => 'FUNC_NAME',
        p_value1   => v_func_name,
        p_token2   => 'TIME',
        p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
      );

      x_completion_code := 2;

    WHEN FEM_INTG_DIM_RULE_worker_err THEN

      ROLLBACK;

      FEM_ENGINES_PKG.Tech_Message(
         p_severity => pc_log_level_statement,
         p_module   => v_module_name || '.worker_err',
         p_msg_text => 'Dimension Rule Worker Error: ' || X_errbuf
       );

      FEM_ENGINES_PKG.User_Message(
         p_app_name => 'FEM',
         p_msg_text => 'Dimension Rule Worker Error: ' || X_errbuf
      );

      x_completion_code := 2;

    WHEN OTHERS THEN

      ROLLBACK;

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_unexpected,
        p_module   => v_module_name || '.unexpected_exception',
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_215',
        p_token1   => 'ERR_MSG',
        p_value1   => SQLERRM
      );

      FEM_ENGINES_PKG.User_Message(
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_215',
        p_token1   => 'ERR_MSG',
        p_value1   => SQLERRM
      );

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_procedure,
        p_module   => v_module_name || '.unexpected_exception',
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_203',
        p_token1   => 'FUNC_NAME',
        p_value1   => v_func_name,
        p_token2   => 'TIME',
        p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
      );

      x_completion_code := 2;

  END Detail_Single_Segment;


  PROCEDURE Detail_Multi_Segment(
    x_completion_code OUT NOCOPY NUMBER,
    x_row_count_tot   OUT NOCOPY NUMBER,
    p_calling_module IN varchar default null
  ) is
    TYPE r_id_array is TABLE OF VARCHAR2(30);
    c_func_name                         CONSTANT VARCHAR2(30) := '.Detail_Multi_Segment';
    v_rows_processed                    NUMBER;
    v_attr_completion_code              VARCHAR2(30);
    v_attr_row_count                    NUMBER;
    v_sql_stmt                          VARCHAR2(4000);
    v_main_gt_insert_stmt               VARCHAR2(4000);
    v_main_insert_gt_count              NUMBER;
    v_comp_gt_insert_stmt               VARCHAR2(4000);
    v_cc_gt_insert_stmt                 VARCHAR2(4000);
    v_comp_insert_gt_count              NUMBER;
    v_cc_insert_gt_count                NUMBER;
    v_comp_member_b_count               NUMBER;
    v_cc_member_b_count                 NUMBER;
    v_comp_member_tl_count              NUMBER;
    v_comp_member_vl_count              NUMBER;
    v_cc_member_tl_count                NUMBER;
    v_cc_member_vl_count                NUMBER;
    v_insert_member_b_stmt              VARCHAR2(4000);
    v_insert_member_b_count             NUMBER;
    v_insert_member_vl_stmt             VARCHAR2(4000);
    v_insert_member_vl_count             NUMBER;
    v_merge_stmt                        VARCHAR2(4000);
    v_merge_count            NUMBER;
    v_insert_cc_vl_stmt                 VARCHAR2(4000);
    v_insert_comp_vl_stmt               VARCHAR2(4000);
    v_upd_map_table_stmt                VARCHAR2(4000);
    v_upd_map_table_count               NUMBER;
    v_lockhandle                        VARCHAR2(100);
    v_lock_result                       NUMBER;
    v_loop_counter                      NUMBER;
    v_cols                              VARCHAR2(100);
    v_column_list                       VARCHAR2(1000);
    v_value_list                        VARCHAR2(1000);
    --bugfix 8780516
    -- v_result                            VARCHAR2(20);
    v_seg1_vs_id                        NUMBER;
    v_seg2_vs_id                        NUMBER;
    v_seg3_vs_id                        NUMBER;
    v_seg4_vs_id                        NUMBER;
    v_seg5_vs_id                        NUMBER;
     --Bugfix 9114881
    l_new_max_ccid_processed           NUMBER;

    FEM_INTG_DIM_RULE_ulock_err EXCEPTION;
    FEM_INTG_DIM_RULE_attr_err EXCEPTION;

    CURSOR ColumnList IS
      SELECT COLUMN_NAME
      FROM FEM_TAB_COLUMNS_B
      WHERE TABLE_NAME = 'FEM_BALANCES'
      AND FEM_DATA_TYPE_CODE = 'DIMENSION'
      AND DIMENSION_ID = FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_id;

    --bugfix 8780516
    ColumnList_rec ColumnList%ROWTYPE;

    -- start bug fix 5377544
    v_Num_Workers                      NUMBER;
    X_errbuf                           VARCHAR2(2000);
    v_completion_code                  NUMBER;
    v_dim_rule_req_count               NUMBER;
    FEM_INTG_DIM_RULE_worker_err       EXCEPTION;
    -- end bug fix 5377544

    -- Start bug Fix 5447696
    v_request_id                       NUMBER;
    v_gcs_vs_id                        NUMBER;
    v_fch_vs_select_stmt               VARCHAR2(1000):=
                                    'SELECT 1
                                       FROM fem_global_vs_combo_defs fch_vs_combo
                                      WHERE fch_vs_combo.global_vs_combo_id = ( SELECT fch_global_vs_combo_id
                                                                                FROM gcs_system_options )
                                        AND fch_vs_combo.dimension_id = 8
                                        AND fch_vs_combo.value_set_id = :fem_value_set_id';

    TYPE vs_cursor IS REF CURSOR;
    fch_vs_cursor vs_cursor;

    -- End bug Fix 5447696

    --bugfix 8780516
    -- Start bug fix 5844990
    v_max_ccid_to_be_mapped  NUMBER;
    -- End bug fix 5844990
  BEGIN

    --piush_util.put_line('Now entering FEM_INTG_NEW_DIM_MEMBER_PKG.Detail_Multi_Segment ********************');

    x_completion_code := 0;

    FEM_ENGINES_PKG.Tech_Message
      ( p_severity => pc_log_level_procedure
       ,p_module   => pc_module_name||c_func_name
       ,p_app_name => 'FEM'
       ,p_msg_name => 'FEM_GL_POST_201'
       ,p_token1   => 'FUNC_NAME'
       ,p_value1   => pc_module_name||c_func_name
       ,p_token2   => 'TIME'
       ,p_value2   =>  TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));



    DBMS_LOCK.ALLOCATE_UNIQUE(
        'FEM_INTG_DIM_RULE' || FEM_INTG_DIM_RULE_ENG_PKG.pv_fem_vs_id,
        v_lockhandle,
        pc_expiration_secs
      );

    v_loop_counter := 0;

    LOOP
      IF v_loop_counter > pc_loop_counter_max
      THEN

        FEM_ENGINES_PKG.Tech_Message(
            p_severity => pc_log_level_statement
           ,p_module   => pc_module_name||c_func_name
           ,p_msg_text => 'raising FEM_INTG_DIM_RULE_ulock_err'
          );
        --piush_util.put_line('Raising exception FEM_INTG_DIM_RULE_ulock_err');
        RAISE FEM_INTG_DIM_RULE_ulock_err;
      END IF;

      v_lock_result := DBMS_LOCK.REQUEST(
                           v_lockhandle,
                           pc_lockmode,
                           pc_lock_timeout,
                           pc_release_on_commit
                         );

      IF v_lock_result = 0 OR v_lock_result = 4
      THEN
        EXIT;
      ELSE
        v_loop_counter := v_loop_counter + 1;

        FEM_ENGINES_PKG.Tech_Message(
              p_severity => pc_log_level_statement
             ,p_module   => pc_module_name||c_func_name
             ,p_msg_text => 'sleeping ' || pc_sleep_second || ' second'
            );

        DBMS_LOCK.SLEEP(pc_sleep_second);
      END IF;
    END LOOP;
    pv_progress := 'Start dynamic building of GT insert';
    --piush_util.put_line(pv_progress);
    x_row_count_tot := 0;

    IF FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_varchar_label = 'INTERCOMPANY'
    THEN
      pv_local_member_col :=  FEM_INTG_DIM_RULE_ENG_PKG.pv_cctr_org_member_col;
    ELSE
      pv_local_member_col :=  FEM_INTG_DIM_RULE_ENG_PKG.pv_member_col;
    END IF;

    ------------------------------------------------------------------------------
    -- Build dyanmic SQL to insert all the unique combination of concatenaned
    -- members into GT table FEM_INTG_DIM_MEMBERS_GT
    ------------------------------------------------------------------------------

    --piush_util.put_line('p_calling_module = ' || p_calling_module);

    if p_calling_module is null then

      --piush_util.put_line('if p_calling_module is null');

      v_main_gt_insert_stmt
        := ' INSERT INTO FEM_INTG_DIM_MEMBERS_GT
              ( DIMENSION_ID
              , SEGMENT1_VALUE
              , SEGMENT2_VALUE
              , SEGMENT3_VALUE
              , SEGMENT4_VALUE
              , SEGMENT5_VALUE
              , CONCAT_SEGMENT_VALUE)
	      --bugfix 8780516
	      -- SELECT DISTINCT
              SELECT /*+ index(gcc gl_code_combinations_u1) */ DISTINCT
                :v_dim_id, '||
                 FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(1).application_column_name||'
              ,'||FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(2).application_column_name;
      IF fem_intg_dim_rule_eng_pkg.pv_segment_count > 2
      THEN
        v_main_gt_insert_stmt := v_main_gt_insert_stmt || ','||
             FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(3).application_column_name;
     ELSE
         v_main_gt_insert_stmt := v_main_gt_insert_stmt || ',-1';
      END IF;

      IF fem_intg_dim_rule_eng_pkg.pv_segment_count > 3
      THEN
        v_main_gt_insert_stmt := v_main_gt_insert_stmt || ','||
             FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(4).application_column_name;
      ELSE
         v_main_gt_insert_stmt := v_main_gt_insert_stmt || ',-1';
      END IF;

      IF fem_intg_dim_rule_eng_pkg.pv_segment_count > 4
      THEN
        v_main_gt_insert_stmt := v_main_gt_insert_stmt || ','||
             FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(5).application_column_name;
      ELSE
         v_main_gt_insert_stmt := v_main_gt_insert_stmt || ',-1';
      END IF;

      v_main_gt_insert_stmt := v_main_gt_insert_stmt ||','
                ||FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(1).application_column_name
                || '||''-''||'
                ||FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(2).application_column_name;

      IF fem_intg_dim_rule_eng_pkg.pv_segment_count > 2
      THEN
        v_main_gt_insert_stmt := v_main_gt_insert_stmt || '||''-''||'||
             FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(3).application_column_name;
      END IF;

      IF fem_intg_dim_rule_eng_pkg.pv_segment_count > 3
      THEN
         v_main_gt_insert_stmt := v_main_gt_insert_stmt || '||''-''||'||
              FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(4).application_column_name;
      END IF;

      IF fem_intg_dim_rule_eng_pkg.pv_segment_count > 4
      THEN
        v_main_gt_insert_stmt := v_main_gt_insert_stmt ||'||''-''||'||
              FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(5).application_column_name;
      END IF;
      v_main_gt_insert_stmt := v_main_gt_insert_stmt ||
       ' FROM  GL_CODE_COMBINATIONS GCC
          WHERE code_combination_id <= :v_high
            AND summary_flag = ''N''
            AND chart_of_accounts_id = :v_coa_id';

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_statement
        ,p_module   => pc_module_name||c_func_name
        ,p_app_name => 'FEM'
        ,p_msg_name => 'FEM_GL_POST_204'
        ,p_token1   => 'VAR_NAME'
        ,p_value1   => 'SQL Statement'
        ,p_token2   => 'VAR_VAL'
        ,p_value2   => v_main_gt_insert_stmt);

      pv_progress := 'Before executing GT population for dimension';
      --piush_util.put_line(pv_progress);
      EXECUTE IMMEDIATE v_main_gt_insert_stmt
      USING
             FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_id
--            ,FEM_INTG_DIM_RULE_ENG_PKG.pv_max_flex_value_id_processed + 1
            ,FEM_INTG_DIM_RULE_ENG_PKG.pv_max_ccid_to_be_mapped
            ,FEM_INTG_DIM_RULE_ENG_PKG.pv_coa_id;

    else

      --piush_util.put_line('else block');

      --piush_util.put_line('FEM_INTG_HIER_RULE_ENG_PKG.pv_hier_obj_def_id = ' || FEM_INTG_HIER_RULE_ENG_PKG.pv_hier_obj_def_id);

       v_main_gt_insert_stmt
        := ' INSERT INTO FEM_INTG_DIM_MEMBERS_GT
( DIMENSION_ID
, SEGMENT1_VALUE
, SEGMENT2_VALUE
, SEGMENT3_VALUE
, SEGMENT4_VALUE
, SEGMENT5_VALUE
, CONCAT_SEGMENT_VALUE)
SELECT DISTINCT :v_dim_id
  , substr(hgt.child_display_code, 1
      , decode(instr(hgt.child_display_code, ''-'', 1, 1), 0
        , length(hgt.child_display_code)
        , instr(hgt.child_display_code, ''-'', 1, 1)-1))
  , decode(instr(hgt.child_display_code, ''-'', 1, 1), 0, ''-1''
    , substr(hgt.child_display_code, instr(hgt.child_display_code, ''-'', 1, 1)+1
      , decode(instr(hgt.child_display_code, ''-'', 1, 2), 0
        , length(hgt.child_display_code) - instr(hgt.child_display_code, ''-'', 1, 1)
        , instr(hgt.child_display_code, ''-'', 1, 2)-instr(hgt.child_display_code, ''-'', 1, 1)-1)))
  , decode(instr(hgt.child_display_code, ''-'', 1, 2), 0, ''-1''
    , substr(hgt.child_display_code, instr(hgt.child_display_code, ''-'', 1, 2)+1
      , decode(instr(hgt.child_display_code, ''-'', 1, 3), 0
        , length(hgt.child_display_code) - instr(hgt.child_display_code, ''-'', 1, 2)
        , instr(hgt.child_display_code, ''-'', 1, 3)-instr(hgt.child_display_code, ''-'', 1, 2)-1)))
  , decode(instr(hgt.child_display_code, ''-'', 1, 3), 0, ''-1''
    , substr(hgt.child_display_code, instr(hgt.child_display_code, ''-'', 1, 3)+1
      , decode(instr(hgt.child_display_code, ''-'', 1, 4), 0
        , length(hgt.child_display_code) - instr(hgt.child_display_code, ''-'', 1, 3)
        , instr(hgt.child_display_code, ''-'', 1, 4)-instr(hgt.child_display_code, ''-'', 1, 3)-1)))
  , decode(instr(hgt.child_display_code, ''-'', 1, 4), 0, ''-1''
    , substr(hgt.child_display_code, instr(hgt.child_display_code, ''-'', 1, 4)+1, length(hgt.child_display_code)-instr(hgt.child_display_code, ''-'', 1, 3)))
  , hgt.child_display_code
from FEM_INTG_DIM_HIER_GT hgt
where hgt.HIERARCHY_OBJ_DEF_ID = :v_hier_obj_def_id';

      --piush_util.put_line('v_main_gt_insert_stmt = ' || v_main_gt_insert_stmt);


      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_statement
        ,p_module   => pc_module_name||c_func_name
        ,p_app_name => 'FEM'
        ,p_msg_name => 'FEM_GL_POST_204'
        ,p_token1   => 'VAR_NAME'
        ,p_value1   => 'SQL Statement'
        ,p_token2   => 'VAR_VAL'
        ,p_value2   => v_main_gt_insert_stmt);

      EXECUTE IMMEDIATE v_main_gt_insert_stmt
      USING FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_id
        , FEM_INTG_HIER_RULE_ENG_PKG.pv_hier_obj_def_id;

    end if;

    --piush_util.put_line('Execute v_main_gt_insert_stmt');

    v_main_insert_gt_count := SQL%ROWCOUNT;

    --piush_util.put_line('Number of rows inserted = ' || SQL%ROWCOUNT);

    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement
      ,p_module   => pc_module_name||c_func_name
      ,p_app_name => 'FEM'
      ,p_msg_name => 'FEM_GL_POST_216'
      ,p_token1   => 'TABLE'
      ,p_value1   => 'FEM_INTG_DIM_MEMBERS_GT'
      ,p_token2   => 'NUM'
      ,p_value2   => v_main_insert_gt_count);


    pv_progress := 'After executing GT population for dimension';
    --piush_util.put_line(pv_progress);

    -------------------------------------------------------------------
    -- ***** MEMBER TABLE POPULATION ******
    --
    -- Build dyanmic SQL to insert new members into FEM mebers table
    -- only new members will be inserted into the table
    -------------------------------------------------------------------
    v_insert_member_b_stmt :=
             'INSERT INTO '||
             FEM_INTG_DIM_RULE_ENG_PKG.pv_member_b_table_name||' (  '||
             pv_local_member_col||'
             , value_set_id
             , dimension_group_id
             , '||FEM_INTG_DIM_RULE_ENG_PKG.pv_member_display_code_col||'
             , enabled_flag
             , personal_flag
             , creation_date
             , created_by
             , last_updated_by
             , last_update_date
             , last_update_login
             , object_version_number
             , read_only_flag)
             SELECT
             fnd_flex_values_s.nextval
             , :v_fem_vs_id
             , null
             , concat_segment_value
             , ''Y''
             , ''N''
             , sysdate
             , :v_userid
             , :v_userid
             , sysdate
             , :v_login_id
             , 1
             , ''N''
             FROM fem_intg_dim_members_gt tab1
             WHERE NOT EXISTS (SELECT ''x''
                 FROM   ' || -- Bug 4393061 - changed read_only_flag to 'N'
       FEM_INTG_DIM_RULE_ENG_PKG.pv_member_b_table_name ||' tab2
                 WHERE  tab2.value_set_id = :v_fem_vs_id
                   AND  tab1.concat_segment_value
                    = tab2.'||
               FEM_INTG_DIM_RULE_ENG_PKG.pv_member_display_code_col
                         ||')';

    pv_progress := 'Before executing member_b population';
    --piush_util.put_line(pv_progress);
    --piush_util.put_line('v_insert_member_b_stmt = ' || v_insert_member_b_stmt);

    FEM_ENGINES_PKG.Tech_Message
          (p_severity => pc_log_level_statement
          ,p_module   => pc_module_name||c_func_name
          ,p_app_name => 'FEM'
          ,p_msg_name => 'FEM_GL_POST_204'
          ,p_token1   => 'VAR_NAME'
          ,p_value1   => 'SQL Statement'
          ,p_token2   => 'VAR_VAL'
          ,p_value2   => v_insert_member_b_stmt);

    EXECUTE IMMEDIATE v_insert_member_b_stmt
    USING
          FEM_INTG_DIM_RULE_ENG_PKG.pv_fem_vs_id
          , pv_user_id
          , pv_user_id
          , pv_login_id
          ,FEM_INTG_DIM_RULE_ENG_PKG.pv_fem_vs_id;

    v_insert_member_b_count := SQL%ROWCOUNT;

    FEM_ENGINES_PKG.Tech_Message
       (p_severity => pc_log_level_statement
       ,p_module   => pc_module_name||c_func_name
       ,p_app_name => 'FEM'
       ,p_msg_name => 'FEM_GL_POST_216'
       ,p_token1   => 'TABLE'
       ,p_value1   => FEM_INTG_DIM_RULE_ENG_PKG.pv_member_b_table_name
       ,p_token2   => 'NUM'
       ,p_value2   => v_insert_member_b_count);

    pv_progress := 'after executing member_b population';
    --piush_util.put_line(pv_progress);

    --------------------------------------------------------
    ------------Insert into Member_TL table  ----------------
    --------------------------------------------------------

    FOR i in 1..fem_intg_dim_rule_eng_pkg.pv_segment_count
    LOOP
      IF  NVL(fem_intg_dim_rule_eng_pkg.pv_mapped_segs(i).table_validated_flag,'N') = 'Y'
      AND fem_intg_dim_rule_eng_pkg.pv_mapped_segs(i).meaning_col_name is NULL
      THEN
        fem_intg_dim_rule_eng_pkg.pv_mapped_segs(i).meaning_col_name := ''' ''';
      END IF;
    END LOOP;

IF NVL(fem_intg_dim_rule_eng_pkg.pv_mapped_segs(1).table_validated_flag, 'N') = 'Y'
    THEN
      v_seg1_vs_id := -99;
    ELSE
      v_seg1_vs_id := fem_intg_dim_rule_eng_pkg.pv_mapped_segs(1).vs_id;
    END IF;

    IF NVL(fem_intg_dim_rule_eng_pkg.pv_mapped_segs(2).table_validated_flag, 'N') = 'Y'
    THEN
      v_seg2_vs_id := -99;
    ELSE
      v_seg2_vs_id := fem_intg_dim_rule_eng_pkg.pv_mapped_segs(2).vs_id;
    END IF;

    IF NVL(fem_intg_dim_rule_eng_pkg.pv_mapped_segs(3).table_validated_flag, 'N') = 'Y'
    THEN
          v_seg3_vs_id := -99;
    ELSE
          v_seg3_vs_id := fem_intg_dim_rule_eng_pkg.pv_mapped_segs(3).vs_id;
    END IF;

    IF NVL(fem_intg_dim_rule_eng_pkg.pv_mapped_segs(4).table_validated_flag, 'N') = 'Y'
    THEN
          v_seg4_vs_id := -99;
    ELSE
          v_seg4_vs_id := fem_intg_dim_rule_eng_pkg.pv_mapped_segs(4).vs_id;
    END IF;

    IF NVL(fem_intg_dim_rule_eng_pkg.pv_mapped_segs(5).table_validated_flag, 'N') = 'Y'
    THEN
          v_seg5_vs_id := -99;
    ELSE
          v_seg5_vs_id := fem_intg_dim_rule_eng_pkg.pv_mapped_segs(5).vs_id;
    END IF;


v_merge_stmt:= 'Merge into ' || fem_intg_dim_rule_eng_pkg.pv_member_tl_table_name || ' TL
USING(';

 v_merge_stmt := v_merge_stmt || 'SELECT tab1.'||pv_local_member_col||' MEM_COL
        , tab1.value_set_id VAL_SET_ID
        , fil.language_code MEM_LANG
        , fil_source.language_code LANG_CODE
        , '||fem_intg_dim_rule_eng_pkg.pv_member_display_code_col || ' DISP_CODE_COL';
    IF NVL(fem_intg_dim_rule_eng_pkg.pv_mapped_segs(1).table_validated_flag,'N') = 'Y'
    THEN
      v_merge_stmt := v_merge_stmt||',SUBSTR(TL1.DESCR,1,50)';
    ELSE
      v_merge_stmt := v_merge_stmt||',SUBSTR(TL1.description,1,50)';
    END IF;

    IF NVL(fem_intg_dim_rule_eng_pkg.pv_mapped_segs(2).table_validated_flag,'N') = 'Y'
    THEN
      v_merge_stmt := v_merge_stmt||'||''-''||SUBSTR(TL2.DESCR,1,50)';
    ELSE
      v_merge_stmt := v_merge_stmt||'||''-''||SUBSTR(TL2.description,1,50)';
    END IF;


    IF fem_intg_dim_rule_eng_pkg.pv_segment_count > 2
    THEN
      IF NVL(fem_intg_dim_rule_eng_pkg.pv_mapped_segs(3).table_validated_flag,'N') = 'Y'
      THEN
        v_merge_stmt := v_merge_stmt||
                        '||''-''||SUBSTR(TL3.DESCR,1,50)';
      ELSE
        v_merge_stmt := v_merge_stmt||'||''-''||SUBSTR(TL3.description,1,50)';
      END IF;
    END IF;

    IF fem_intg_dim_rule_eng_pkg.pv_segment_count > 3
    THEN
      IF NVL(fem_intg_dim_rule_eng_pkg.pv_mapped_segs(4).table_validated_flag,'N') = 'Y'
      THEN
        v_merge_stmt := v_merge_stmt||
                        '||''-''||SUBSTR(TL4.DESCR,1,50)';
      ELSE
        v_merge_stmt := v_merge_stmt || '||''-''||SUBSTR(TL4.description,1,50)';
      END IF;
    END IF;

    IF fem_intg_dim_rule_eng_pkg.pv_segment_count > 4
    THEN
      IF NVL(fem_intg_dim_rule_eng_pkg.pv_mapped_segs(5).table_validated_flag,'N') = 'Y'
      THEN
        v_merge_stmt := v_merge_stmt||
                        '||''-''||SUBSTR(TL5.DESCR,1,50)';
      ELSE
        v_merge_stmt := v_merge_stmt || '||''-''||SUBSTR(TL5.description,1,50)';
      END IF;
    END IF;

    v_merge_stmt := v_merge_stmt || ' MEMB_DESC';
    v_merge_stmt := v_merge_stmt ||
                          ',sysdate CREATED_DATE
                           ,:v_userid CREATED_BY
                           ,:v_userid UPDATED_BY
                           ,sysdate UPDATED_DATE
                           ,:v_login_id UPDATE_LOGIN
                        FROM '||fem_intg_dim_rule_eng_pkg.pv_member_b_table_name ||' tab1,
                            fem_intg_dim_members_gt GT
                           ,fnd_languages fil
                           ,fnd_languages fil_source';

    IF NVL(fem_intg_dim_rule_eng_pkg.pv_mapped_segs(1).table_validated_flag,'N') = 'Y'
    THEN
      v_merge_stmt := v_merge_stmt|| ',( SELECT '
           || FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(1).meaning_col_name
           ||' DESCR ,'
           ||FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(1).val_col_name
           || ' flex_value FROM '
           || FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(1).table_name || ' '
           || FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(1).where_clause || ') TL1';
    ELSE
      v_merge_stmt := v_merge_stmt
                        ||' ,fnd_flex_values flex1
                           ,fnd_flex_values_tl TL1';
    END IF;

    IF NVL(fem_intg_dim_rule_eng_pkg.pv_mapped_segs(2).table_validated_flag,'N') = 'Y'
    THEN
      v_merge_stmt := v_merge_stmt|| ',( SELECT '
        || FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(2).meaning_col_name
        ||' DESCR ,'
        ||FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(2).val_col_name
        || ' flex_value FROM '
        || FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(2).table_name || ' '
        || FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(2).where_clause || ') TL2';
    ELSE
      v_merge_stmt := v_merge_stmt
                        ||' ,fnd_flex_values flex2
                           ,fnd_flex_values_tl TL2';
    END IF;

    IF fem_intg_dim_rule_eng_pkg.pv_segment_count > 2
    THEN
      IF NVL(fem_intg_dim_rule_eng_pkg.pv_mapped_segs(3).table_validated_flag,'N') = 'Y'
      THEN
        v_merge_stmt := v_merge_stmt|| ',( SELECT '
             || FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(3).meaning_col_name
             ||' DESCR ,'
             ||FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(3).val_col_name
             || ' flex_value FROM '
             || FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(3).table_name || ' '
             || FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(3).where_clause || ') TL3';
      ELSE
        v_merge_stmt := v_merge_stmt
                        ||',fnd_flex_values flex3
                           , fnd_flex_values_tl TL3';
     END IF;
   END IF;

   IF fem_intg_dim_rule_eng_pkg.pv_segment_count > 3
   THEN
     IF NVL(fem_intg_dim_rule_eng_pkg.pv_mapped_segs(4).table_validated_flag,'N') = 'Y'
     THEN
       v_merge_stmt := v_merge_stmt|| ',( SELECT '
         || FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(4).meaning_col_name
         ||' DESCR ,'
         ||FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(4).val_col_name
         || ' flex_value FROM '
         || FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(4).table_name || ' '
         || FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(4).where_clause || ') TL4';
     ELSE
       v_merge_stmt := v_merge_stmt
         ||',fnd_flex_values flex4
            , fnd_flex_values_tl TL4';
     END IF;
   END IF;

   IF fem_intg_dim_rule_eng_pkg.pv_segment_count > 4
   THEN
     IF NVL(fem_intg_dim_rule_eng_pkg.pv_mapped_segs(5).table_validated_flag,'N') = 'Y'
     THEN
       v_merge_stmt := v_merge_stmt|| ',( SELECT '
         || FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(5).meaning_col_name
         ||' DESCR ,'
         ||FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(5).val_col_name
         || ' flex_value FROM '
         || FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(5).table_name || ' '
         || FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(5).where_clause || ') TL5';
      ELSE
        v_merge_stmt := v_merge_stmt
          ||',fnd_flex_values flex5
             ,fnd_flex_values_tl TL5';
      END IF;
    END IF;

    v_merge_stmt := v_merge_stmt
             || ' WHERE fil.installed_flag in (''B'', ''I'')
                  AND fil_source.installed_flag = ''B''
                  AND GT.concat_segment_value = tab1.'||
                      fem_intg_dim_rule_eng_pkg.pv_member_display_code_col||'
                  AND GT.dimension_id = :v_dim_id
                  AND tab1.value_set_id = :v_fem_vs_id';

    IF NVL(fem_intg_dim_rule_eng_pkg.pv_mapped_segs(1).table_validated_flag,'N') = 'Y'
    THEN
      v_merge_stmt := v_merge_stmt ||'
          AND -99 = :map_seg1_vs_id
          AND TL1.flex_value = gt.segment1_value';
    ELSE
      v_merge_stmt := v_merge_stmt ||'
          AND TL1.language = fil.language_code
          AND flex1.flex_value_set_id = :map_seg1_vs_id
                AND flex1.flex_value_id = TL1.flex_value_id
                AND flex1.flex_value = gt.segment1_value';
        END IF;


    IF NVL(fem_intg_dim_rule_eng_pkg.pv_mapped_segs(2).table_validated_flag,'N') = 'Y'
    THEN
      v_merge_stmt := v_merge_stmt ||'
          AND -99 = :map_seg2_vs_id
          AND TL2.flex_value = gt.segment2_value';
    ELSE
      v_merge_stmt := v_merge_stmt ||'
          AND TL2.language = fil.language_code
          AND flex2.flex_value_set_id = :map_seg2_vs_id
          AND flex2.flex_value_id = TL2.flex_value_id
          AND flex2.flex_value = gt.segment2_value';
      IF fem_intg_dim_rule_eng_pkg.pv_mapped_segs(2).dependent_value_set_flag = 'Y'
      THEN
        v_merge_stmt := v_merge_stmt || '
          AND flex2.parent_flex_value_low = '
             ||fem_intg_dim_rule_eng_pkg.pv_mapped_segs(2).dependent_segment_column;
      END IF;
    END IF;

    IF fem_intg_dim_rule_eng_pkg.pv_segment_count > 2
    THEN
      IF NVL(fem_intg_dim_rule_eng_pkg.pv_mapped_segs(3).table_validated_flag,'N') = 'Y'
      THEN
        v_merge_stmt := v_merge_stmt ||'
                AND -99 = :map_seg3_vs_id
                AND TL3.flex_value = gt.segment3_value';
      ELSE
        v_merge_stmt := v_merge_stmt || '
                AND TL3.language = fil.language_code
                AND flex3.flex_value_set_id = :map_seg3_vs_id
                AND flex3.flex_value_id = TL3.flex_value_id
                AND flex3.flex_value = gt.segment3_value';
        IF fem_intg_dim_rule_eng_pkg.pv_mapped_segs(3).dependent_value_set_flag = 'Y'
        THEN
          v_merge_stmt := v_merge_stmt || '
                AND flex3.parent_flex_value_low = '
                 ||fem_intg_dim_rule_eng_pkg.pv_mapped_segs(3).dependent_segment_column;
        END IF;
      END IF;
    END IF;

    IF fem_intg_dim_rule_eng_pkg.pv_segment_count > 3
    THEN
      IF NVL(fem_intg_dim_rule_eng_pkg.pv_mapped_segs(4).table_validated_flag,'N') = 'Y'
      THEN
        v_merge_stmt := v_merge_stmt ||'
                AND -99 = :map_seg4_vs_id
                AND TL4.flex_value = gt.segment4_value';
      ELSE
        v_merge_stmt := v_merge_stmt || '
                AND TL4.language = fil.language_code
                AND flex4.flex_value_set_id = :map_seg4_vs_id
                AND flex4.flex_value_id = TL4.flex_value_id
                AND flex4.flex_value = gt.segment4_value';
        IF fem_intg_dim_rule_eng_pkg.pv_mapped_segs(4).dependent_value_set_flag = 'Y'
        THEN
          v_merge_stmt := v_merge_stmt || '
                AND flex4.parent_flex_value_low = '||fem_intg_dim_rule_eng_pkg.pv_mapped_segs(4).dependent_segment_column;
        END IF;
      END IF;
    END IF;

    IF fem_intg_dim_rule_eng_pkg.pv_segment_count > 4
    THEN
      IF NVL(fem_intg_dim_rule_eng_pkg.pv_mapped_segs(5).table_validated_flag,'N') = 'Y'
      THEN
        v_merge_stmt := v_merge_stmt ||'
                AND -99 = :map_seg5_vs_id
                AND TL5.flex_value = gt.segment5_value';
      ELSE
        v_merge_stmt := v_merge_stmt || '
                AND TL5.language = fil.language_code
                AND flex5.flex_value_set_id = :map_seg5_vs_id
                AND flex5.flex_value_id = TL5.flex_value_id
                AND flex5.flex_value = gt.segment5_value';
        IF fem_intg_dim_rule_eng_pkg.pv_mapped_segs(5).dependent_value_set_flag = 'Y'
        THEN
          v_merge_stmt := v_merge_stmt || '
                  AND flex5.parent_flex_value_low = '
                  ||fem_intg_dim_rule_eng_pkg.pv_mapped_segs(5).dependent_segment_column;
        END IF;
      END IF;
    END IF;

       v_merge_stmt := v_merge_stmt || ') D
       ON(
              TL.VALUE_SET_ID = D.VAL_SET_ID
          AND TL.LANGUAGE = D.MEM_LANG
          AND TL.'||pv_local_member_col||' = D.MEM_COL';


       v_merge_stmt := v_merge_stmt|| ')
                          WHEN MATCHED THEN UPDATE
                          SET TL.DESCRIPTION = D.MEMB_DESC
                          WHEN NOT MATCHED THEN Insert ('||
                             pv_local_member_col||',
                             VALUE_SET_ID
                           , LANGUAGE
                           , SOURCE_LANG
                           , ' ||fem_intg_dim_rule_eng_pkg.pv_member_name_col||'
                           , DESCRIPTION
                           , CREATION_DATE
                           , CREATED_BY
                           , LAST_UPDATED_BY
                           , LAST_UPDATE_DATE
                           , LAST_UPDATE_LOGIN )
                           VALUES(
                             D.MEM_COL,
                             D.VAL_SET_ID,
                             D.MEM_LANG,
                             D.LANG_CODE,
                             D.DISP_CODE_COL,
                             D.MEMB_DESC,
                             D.CREATED_DATE,
                             D.CREATED_BY,
                             D.UPDATED_BY,
                             D.UPDATED_DATE,
                             D.UPDATE_LOGIN)';


    FEM_ENGINES_PKG.Tech_Message
       (
        p_severity => pc_log_level_statement
       ,p_module   => pc_module_name||c_func_name
       ,p_msg_text => v_merge_stmt);

    --
    -- Execute built statement for inserting dimension members
    --
    CASE fem_intg_dim_rule_eng_pkg.pv_segment_count
    WHEN 1
      THEN
      EXECUTE IMMEDIATE v_merge_stmt
      USING
           pv_user_id
          ,pv_user_id
          ,pv_login_id
          ,fem_intg_dim_rule_eng_pkg.pv_dim_id
          ,FEM_INTG_DIM_RULE_ENG_PKG.pv_fem_vs_id
          ,v_seg1_vs_id;
--          ,FEM_INTG_DIM_RULE_ENG_PKG.pv_fem_vs_id;
    WHEN 2
      THEN
      EXECUTE IMMEDIATE v_merge_stmt
      USING
           pv_user_id
          ,pv_user_id
          ,pv_login_id
          ,fem_intg_dim_rule_eng_pkg.pv_dim_id
          ,FEM_INTG_DIM_RULE_ENG_PKG.pv_fem_vs_id
          ,v_seg1_vs_id
          ,v_seg2_vs_id;
--          ,FEM_INTG_DIM_RULE_ENG_PKG.pv_fem_vs_id;
    WHEN 3
      THEN
      EXECUTE IMMEDIATE v_merge_stmt
      USING
           pv_user_id
          ,pv_user_id
          ,pv_login_id
          ,fem_intg_dim_rule_eng_pkg.pv_dim_id
          ,FEM_INTG_DIM_RULE_ENG_PKG.pv_fem_vs_id
          ,v_seg1_vs_id
          ,v_seg2_vs_id
          ,v_seg3_vs_id;
--          ,FEM_INTG_DIM_RULE_ENG_PKG.pv_fem_vs_id;
    WHEN 4
      THEN
      EXECUTE IMMEDIATE v_merge_stmt
      USING
           pv_user_id
          ,pv_user_id
          ,pv_login_id
          ,fem_intg_dim_rule_eng_pkg.pv_dim_id
          ,FEM_INTG_DIM_RULE_ENG_PKG.pv_fem_vs_id
          ,v_seg1_vs_id
          ,v_seg2_vs_id
          ,v_seg3_vs_id
          ,v_seg4_vs_id;
--          ,FEM_INTG_DIM_RULE_ENG_PKG.pv_fem_vs_id;
    WHEN 5
      THEN
      EXECUTE IMMEDIATE v_merge_stmt
      USING
           pv_user_id
          ,pv_user_id
          ,pv_login_id
          ,fem_intg_dim_rule_eng_pkg.pv_dim_id
          ,FEM_INTG_DIM_RULE_ENG_PKG.pv_fem_vs_id
          ,v_seg1_vs_id
          ,v_seg2_vs_id
          ,v_seg3_vs_id
          ,v_seg4_vs_id
          ,v_seg5_vs_id;
--          ,FEM_INTG_DIM_RULE_ENG_PKG.pv_fem_vs_id;
    END CASE;

    v_merge_count := SQL%ROWCOUNT;


    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement
      ,p_module   => pc_module_name||c_func_name
      ,p_app_name => 'FEM'
      ,p_msg_name => 'FEM_GL_POST_216'
      ,p_token1   => 'TABLE'
      ,p_value1   => FEM_INTG_DIM_RULE_ENG_PKG.pv_member_tl_table_name
      ,p_token2   => 'NUM'
      ,p_value2   => v_merge_count);

    pv_progress := 'after executing member_tl population';


    /* MEMBER TABLE POPULATION
     * =======================
     *
     * Build dyanmic SQL to insert new members into FEM mebers table
     * Only new members will be inserted into the table
     */

    IF upper( FEM_INTG_DIM_RULE_ENG_PKG.pv_member_b_table_name) = 'FEM_CCTR_ORGS_B'
    THEN
      FEM_ENGINES_PKG.Tech_Message
       (
        p_severity => pc_log_level_event
       ,p_module   => pc_module_name||c_func_name
       ,p_msg_text => 'Processing dimension is of type CCTR-ORG');

      pv_progress := 'Before creating dynamic GT insert for Company';
      --piush_util.put_line(pv_progress);
      v_comp_gt_insert_stmt :=
                'INSERT INTO FEM_INTG_DIM_MEMBERS_GT GT
                 ( DIMENSION_ID
                 , SEGMENT1_VALUE
                 , SEGMENT2_VALUE
                 , SEGMENT3_VALUE
                 , SEGMENT4_VALUE
                 , SEGMENT5_VALUE
                 , CONCAT_SEGMENT_VALUE)
                 SELECT DISTINCT
                   :v_dest_dim_id
                 , -1
                 , -1
                 , -1
                 , -1
                 , -1
                 , segment1_value
                FROM FEM_INTG_DIM_MEMBERS_GT GT2
                WHERE GT2.dimension_id  = :v_dim_id';


      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_statement
        ,p_module   => pc_module_name||c_func_name
        ,p_app_name => 'FEM'
        ,p_msg_name => 'FEM_GL_POST_204'
        ,p_token1   => 'VAR_NAME'
        ,p_value1   => 'SQL Statement'
        ,p_token2   => 'VAR_VAL'
        ,p_value2   => v_comp_gt_insert_stmt);

      -- Execute population of GT table for company dimension members
      EXECUTE IMMEDIATE v_comp_gt_insert_stmt
      USING FEM_INTG_DIM_RULE_ENG_PKG.pv_com_dim_id
           ,FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_id;

      v_comp_insert_gt_count := SQL%ROWCOUNT;
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_statement
        ,p_module   => pc_module_name||c_func_name
        ,p_app_name => 'FEM'
        ,p_msg_name => 'FEM_GL_POST_216'
        ,p_token1   => 'TABLE'
        ,p_value1   => 'FEM_INTG_DIM_MEMBERS_GT (for Comp dim)'
        ,p_token2   => 'NUM'
        ,p_value2   => v_comp_insert_gt_count);


      -- Insert individual dimension members for company

      IF FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(1).table_validated_flag = 'N'
      THEN
        pv_progress := 'Before insert into fem_companies_b';
        --piush_util.put_line(pv_progress);
        INSERT INTO fem_companies_b
        (
          company_id,
          value_set_id,
          company_display_code,
          enabled_flag,
          personal_flag,
          creation_date,
          created_by,
          last_updated_by,
          last_update_date,
          last_update_login,
          read_only_flag,
          object_version_number
        )
        SELECT flex.FLEX_VALUE_ID
              ,fem_intg_dim_rule_eng_pkg.pv_com_vs_id
              ,tab1.concat_segment_value
	      --bugfic 8780516
              --Bugfix 5333726
              --,'Y'
              ,flex.enabled_flag
              ,'N'
              ,SYSDATE
              ,pv_user_id
              ,pv_user_id
              ,SYSDATE
              ,pv_login_id
              ,'N' -- Bug 4393061 - changed read_only_flag to 'N'
              ,1
        FROM  fem_intg_dim_members_gt  tab1
             ,fnd_flex_values flex
        WHERE dimension_id = fem_intg_dim_rule_eng_pkg.pv_com_dim_id
          AND flex.FLEX_VALUE_SET_ID = fem_intg_dim_rule_eng_pkg.pv_mapped_segs(1).vs_id
          AND flex.flex_value = tab1.concat_segment_value
          AND not exists ( SELECT 'x'
                           FROM  fem_companies_b tab2
                       WHERE tab2.value_set_id = fem_intg_dim_rule_eng_pkg.pv_com_vs_id
                       AND tab1.concat_segment_value = tab2.company_display_code);

        v_comp_member_b_count := SQL%ROWCOUNT;

        FEM_ENGINES_PKG.Tech_Message
          (p_severity => pc_log_level_statement
          ,p_module   => pc_module_name||c_func_name
          ,p_app_name => 'FEM'
          ,p_msg_name => 'FEM_GL_POST_216'
          ,p_token1   => 'TABLE'
          ,p_value1   => 'FEM_COMPANIES_B'
          ,p_token2   => 'NUM'
          ,p_value2   => v_comp_member_b_count);

        pv_progress := 'Before insert into fem_companies_tl';
        --piush_util.put_line(pv_progress);

        INSERT INTO fem_companies_tl
        (
          company_id,
          value_set_id,
          language,
          source_lang,
          company_name,
          description,
          creation_date,
          created_by,
          last_updated_by,
          last_update_date,
          last_update_login
        )
        SELECT TL.FLEX_VALUE_ID
              ,tab1.value_set_id
              ,TL.language
              ,TL.source_lang
              ,tab1.company_display_code
              ,TL.description
              ,SYSDATE
              ,pv_user_id
              ,pv_user_id
              ,SYSDATE
                  ,pv_login_id
        FROM   fem_companies_b tab1
              ,fnd_flex_values_tl TL
        WHERE tab1.value_set_id = fem_intg_dim_rule_eng_pkg.pv_com_vs_id
          AND tab1.company_id = TL.flex_value_id
          AND not exists ( SELECT 'x'
                           FROM  fem_companies_tl tab2
                           WHERE tab1.value_set_id = tab2.value_set_id
                             AND tab1.company_id = tab2.company_id
                             AND TL.language  = tab2.language );

        v_comp_member_tl_count := SQL%ROWCOUNT;

        FEM_ENGINES_PKG.Tech_Message
          (p_severity => pc_log_level_statement
          ,p_module   => pc_module_name||c_func_name
          ,p_app_name => 'FEM'
          ,p_msg_name => 'FEM_GL_POST_216'
          ,p_token1   => 'TABLE'
          ,p_value1   => 'FEM_COMPANIES_TL'
          ,p_token2   => 'NUM'
          ,p_value2   => v_comp_member_tl_count);

      ELSE /* table validated value set */

        pv_progress := 'Before insert into fem_companies_vl';
        --piush_util.put_line(pv_progress);

        v_insert_comp_vl_stmt := 'INSERT INTO fem_companies_vl
                 (
                 company_id,
                 value_set_id,
                 company_display_code,
                 enabled_flag,
                 personal_flag,
                 creation_date,
                 created_by,
                 last_updated_by,
                 last_update_date,
                 last_update_login,
                 read_only_flag,
                 object_version_number,
                 company_name,
                 description
               )
               SELECT FND_FLEX_VALUES_S.nextval
                 ,:v_seg1_vs_id
                 ,concat_segment_value
                 ,''Y''
                 ,''N''
                 ,SYSDATE
                 ,:v_user_id
                 ,:v_user_id
                 ,SYSDATE
                 ,:v_login_id
                 ,''N''
                 ,1
                 ,concat_segment_value
                 ,flex.descr
           FROM  fem_intg_dim_members_gt  tab1';

        v_insert_comp_vl_stmt := v_insert_comp_vl_stmt|| ',( SELECT '
          || FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(1).meaning_col_name
          ||' DESCR ,'
          ||FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(1).val_col_name
          || ' flex_value FROM '
          || FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(1).table_name || ' '
          || FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(1).where_clause || ') FLEX';

        v_insert_comp_vl_stmt := v_insert_comp_vl_stmt|| '
            WHERE dimension_id = :v_com_dim_id
              AND flex.flex_value = tab1.concat_segment_value
              AND not exists ( SELECT ''x''
                           FROM  fem_companies_vl tab2
                           WHERE :v_seg1_vs_id = tab2.value_set_id
                             AND tab1.concat_segment_value = tab2.company_display_code)';

        FEM_ENGINES_PKG.Tech_Message
          (p_severity => pc_log_level_statement
          ,p_module   => pc_module_name||c_func_name
          ,p_msg_text => 'Executing SQL Statement: '||v_insert_comp_vl_stmt||
                       'Using: '||fem_intg_dim_rule_eng_pkg.pv_mapped_segs(1).vs_id
                           ||','||pv_user_id
                           ||','||pv_user_id
                           ||','||pv_login_id
                           ||','||fem_intg_dim_rule_eng_pkg.pv_com_dim_id
                           ||','||fem_intg_dim_rule_eng_pkg.pv_mapped_segs(1).vs_id);

        EXECUTE IMMEDIATE v_insert_comp_vl_stmt
        USING fem_intg_dim_rule_eng_pkg.pv_com_vs_id,
              pv_user_id,
              pv_user_id,
              pv_login_id,
              fem_intg_dim_rule_eng_pkg.pv_com_dim_id,
              fem_intg_dim_rule_eng_pkg.pv_com_vs_id;

        v_comp_member_vl_count := SQL%ROWCOUNT;

        FEM_ENGINES_PKG.Tech_Message
          (p_severity => pc_log_level_statement
          ,p_module   => pc_module_name||c_func_name
          ,p_app_name => 'FEM'
          ,p_msg_name => 'FEM_GL_POST_216'
          ,p_token1   => 'TABLE'
          ,p_value1   => 'FEM_COMPANIES_VL'
          ,p_token2   => 'NUM'
          ,p_value2   => v_comp_member_vl_count);

      END IF;


      -- Execute population of GT table for cost center dimension members

      pv_progress := 'Before building dynamic stmt for CostCenter GT INSERT';
      --piush_util.put_line(pv_progress);
      v_cc_gt_insert_stmt :=
                'INSERT INTO FEM_INTG_DIM_MEMBERS_GT GT
                 ( DIMENSION_ID
                 , SEGMENT1_VALUE
                 , SEGMENT2_VALUE
                 , SEGMENT3_VALUE
                 , SEGMENT4_VALUE
                 , SEGMENT5_VALUE
                 , CONCAT_SEGMENT_VALUE)
                 SELECT DISTINCT
                   :v_dest_dim_id
                 , -1
                 , -1
                 , -1
                 , -1
                 , -1
                 , segment2_value
                    FROM FEM_INTG_DIM_MEMBERS_GT GT2
                WHERE GT2.dimension_id  = :v_dim_id';

      pv_progress := 'Before EXECUTION of CostCenter GT INSERT';
      --piush_util.put_line(pv_progress);

      EXECUTE IMMEDIATE v_cc_gt_insert_stmt
      USING FEM_INTG_DIM_RULE_ENG_PKG.pv_cc_dim_id
           ,FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_id;

      v_cc_insert_gt_count := SQL%ROWCOUNT;

      FEM_ENGINES_PKG.Tech_Message
            (p_severity => pc_log_level_statement
            ,p_module   => pc_module_name||c_func_name
            ,p_app_name => 'FEM'
            ,p_msg_name => 'FEM_GL_POST_216'
            ,p_token1   => 'TABLE'
            ,p_value1   => 'FEM_INTG_DIM_MEMBERS_GT (FOR CC DIM)'
            ,p_token2   => 'NUM'
            ,p_value2   => v_cc_insert_gt_count);


          -- Insert individual dimension members for cost center


      IF FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(2).table_validated_flag = 'N'
      THEN
        pv_progress := 'Before insert into fem_cost_centers_b';
        --piush_util.put_line(pv_progress);
        IF fem_intg_dim_rule_eng_pkg.pv_mapped_segs(2).dependent_value_set_flag = 'Y'
        THEN
          INSERT INTO fem_cost_centers_b
            (
              cost_center_id,
              value_set_id,
              cost_center_display_code,
              enabled_flag,
              personal_flag,
              creation_date,
              created_by,
              last_updated_by,
              last_update_date,
              last_update_login,
              read_only_flag,
              object_version_number
            )
          SELECT flex.FLEX_VALUE_ID
              ,fem_intg_dim_rule_eng_pkg.pv_cc_vs_id
              ,segment2_value
	      --bugfix 8780516
              --Bugfix 5333726
              --,'Y'
              ,flex.enabled_flag
              ,'N'
              ,SYSDATE
              ,pv_user_id
              ,pv_user_id
              ,SYSDATE
              ,pv_login_id
              ,'N'
              ,1
        FROM  fem_intg_dim_members_gt  tab1
              ,fnd_flex_values flex
        WHERE dimension_id = fem_intg_dim_rule_eng_pkg.pv_dim_id /* Because dependent VS*/
          AND flex.FLEX_VALUE_SET_ID = fem_intg_dim_rule_eng_pkg.pv_mapped_segs(2).vs_id
              AND flex.parent_flex_value_low = tab1.segment1_value
              AND flex.flex_value = tab1.segment2_value
              AND not exists ( SELECT 'x'
                               FROM  fem_cost_centers_b tab2
                               WHERE tab2.value_set_id = fem_intg_dim_rule_eng_pkg.pv_cc_vs_id
                                 AND tab1.segment2_value = tab2.cost_center_display_code);                  v_cc_member_b_count := SQL%ROWCOUNT;

        ELSE /* Independent value set */
          INSERT INTO fem_cost_centers_b
          (
            cost_center_id,
            value_set_id,
            cost_center_display_code,
            enabled_flag,
            personal_flag,
            creation_date,
            created_by,
            last_updated_by,
            last_update_date,
            last_update_login,
            read_only_flag,
            object_version_number
          )
          SELECT flex.FLEX_VALUE_ID
                ,fem_intg_dim_rule_eng_pkg.pv_cc_vs_id
                ,concat_segment_value
		--bugfix 8780516
                --Bugfix 5333726
                --,'Y'
                ,flex.enabled_flag
                ,'N'
                ,SYSDATE
                ,pv_user_id
                ,pv_user_id
                ,SYSDATE
                ,pv_login_id
                ,'N' -- Bug 4393061 - changed read_only_flag to 'N'
                ,1
          FROM  fem_intg_dim_members_gt  tab1
                ,fnd_flex_values flex
          WHERE dimension_id = fem_intg_dim_rule_eng_pkg.pv_cc_dim_id
            AND flex.FLEX_VALUE_SET_ID = fem_intg_dim_rule_eng_pkg.pv_mapped_segs(2).vs_id
            AND flex.flex_value = tab1.concat_segment_value
            AND not exists ( SELECT 'x'
                             FROM  fem_cost_centers_b tab2
                             WHERE tab2.value_set_id = fem_intg_dim_rule_eng_pkg.pv_cc_vs_id
                               AND tab1.concat_segment_value = tab2.cost_center_display_code);

          v_cc_member_b_count := SQL%ROWCOUNT;
        END IF;

        FEM_ENGINES_PKG.Tech_Message
          (p_severity => pc_log_level_statement
          ,p_module   => pc_module_name||c_func_name
          ,p_app_name => 'FEM'
          ,p_msg_name => 'FEM_GL_POST_216'
          ,p_token1   => 'TABLE'
          ,p_value1   => 'FEM_COST_CENTERS_B'
          ,p_token2   => 'NUM'
          ,p_value2   => v_cc_member_b_count);

        pv_progress := 'Before insert into fem_cost_centers_tl';
        --piush_util.put_line(pv_progress);
        INSERT INTO fem_cost_centers_tl
        (
          cost_center_id,
          value_set_id,
          language,
          source_lang,
          cost_center_name,
          description,
          creation_date,
          created_by,
          last_updated_by,
          last_update_date,
          last_update_login
        )
        SELECT TL.FLEX_VALUE_ID
              ,tab1.value_set_id
              ,TL.language
              ,TL.source_lang
              ,tab1.cost_center_display_code
              ,TL.description
              ,SYSDATE
              ,pv_user_id
              ,pv_user_id
              ,SYSDATE
              ,pv_login_id
        FROM   fem_cost_centers_b tab1
              ,fnd_flex_values_tl TL
        WHERE tab1.value_set_id = fem_intg_dim_rule_eng_pkg.pv_cc_vs_id
          AND tab1.cost_center_id = TL.flex_value_id
          AND not exists ( SELECT 'x'
                           FROM  fem_cost_centers_tl tab2
                           WHERE tab1.value_set_id = tab2.value_set_id
                             AND tab1.cost_center_id = tab2.cost_center_id
                             AND TL.language  = tab2.language );

        v_cc_member_tl_count := SQL%ROWCOUNT;
        FEM_ENGINES_PKG.Tech_Message
          (p_severity => pc_log_level_statement
          ,p_module   => pc_module_name||c_func_name
          ,p_app_name => 'FEM'
          ,p_msg_name => 'FEM_GL_POST_216'
          ,p_token1   => 'TABLE'
          ,p_value1   => 'FEM_COST_CENTERS_TL'
          ,p_token2   => 'NUM'
          ,p_value2   => v_cc_member_tl_count);

      ELSE /* CC is of table validated case */

        pv_progress := 'Before insert into fem_cost_centers_vl';
        --piush_util.put_line(pv_progress);

        v_insert_cc_vl_stmt := 'INSERT INTO fem_cost_centers_vl
                 (
                 cost_center_id,
                 value_set_id,
                 cost_center_display_code,
                 enabled_flag,
                 personal_flag,
                 creation_date,
                 created_by,
                 last_updated_by,
                 last_update_date,
                 last_update_login,
                 read_only_flag,
                 object_version_number,
                 cost_center_name,
                 description
                   )
                   SELECT FND_FLEX_VALUES_S.nextval
                 ,:v_seg2_vs_id
                 ,concat_segment_value
                 ,''Y''
                 ,''N''
                 ,SYSDATE
                 ,:v_user_id
                 ,:v_user_id
                 ,SYSDATE
                 ,:v_login_id
                 ,''N''
                 ,1
                 ,concat_segment_value
                 ,flex.descr
           FROM  fem_intg_dim_members_gt  tab1';
         -- Bug 4393061 - changed read_only_flag to 'N'
        v_insert_cc_vl_stmt := v_insert_cc_vl_stmt|| ',( SELECT '
               || FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(2).meaning_col_name
               ||' DESCR ,'
               ||FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(2).val_col_name
               || ' flex_value FROM '
               || FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(2).table_name || ' '
               || FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(2).where_clause || ') FLEX';

        v_insert_cc_vl_stmt := v_insert_cc_vl_stmt|| '
           WHERE dimension_id = :v_cc_dim_id
             AND flex.flex_value = tab1.concat_segment_value
             AND not exists ( SELECT ''x''
                          FROM  fem_cost_centers_vl tab2
                          WHERE :v_seg2_vs_id = tab2.value_set_id
                       AND tab1.concat_segment_value = tab2.cost_center_display_code)';

        FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_statement
        ,p_module   => pc_module_name||c_func_name
        ,p_msg_text => 'Executing SQL Statement: '||v_insert_cc_vl_stmt||
                      'Using: '||fem_intg_dim_rule_eng_pkg.pv_mapped_segs(2).vs_id
                          ||','||pv_user_id
                          ||','||pv_user_id
                          ||','||pv_login_id
                          ||','||fem_intg_dim_rule_eng_pkg.pv_cc_dim_id
                          ||','||fem_intg_dim_rule_eng_pkg.pv_mapped_segs(2).vs_id);

        EXECUTE IMMEDIATE v_insert_cc_vl_stmt
        USING fem_intg_dim_rule_eng_pkg.pv_cc_vs_id,
             pv_user_id,
             pv_user_id,
             pv_login_id,
             fem_intg_dim_rule_eng_pkg.pv_cc_dim_id,
             fem_intg_dim_rule_eng_pkg.pv_cc_vs_id;

        v_cc_member_vl_count := SQL%ROWCOUNT;

        FEM_ENGINES_PKG.Tech_Message
         (p_severity => pc_log_level_statement
         ,p_module   => pc_module_name||c_func_name
         ,p_app_name => 'FEM'
         ,p_msg_name => 'FEM_GL_POST_216'
         ,p_token1   => 'TABLE'
         ,p_value1   => 'FEM_COST_CENTERS_VL'
         ,p_token2   => 'NUM'
         ,p_value2   => v_cc_member_vl_count);

      END IF;
    ELSE /* Not of CCTR type */
      FEM_ENGINES_PKG.Tech_Message
        (
         p_severity => pc_log_level_event
        ,p_module   => pc_module_name||c_func_name
        ,p_msg_text => 'Processing dimension is not of type CCTR-ORG');

    END IF;

    v_attr_completion_code := 0;
    FEM_ENGINES_PKG.User_Message(
           p_app_name => 'FEM',
           p_msg_name => 'FEM_INTG_DIM_MEMB_501'
    );

    pv_progress := 'Before calling Populate_Dimension_Attribute';
    --piush_util.put_line(pv_progress);
    Populate_Dimension_Attribute(
                         p_summary_flag         => 'N'
                        ,x_completion_code      => v_attr_completion_code
                        ,x_row_count_tot        => v_attr_row_count
                                                            );
    IF v_attr_completion_code <> 0
    THEN
      FEM_ENGINES_PKG.Tech_Message
          (
           p_severity => pc_log_level_event
          ,p_module   => pc_module_name||c_func_name
          ,p_msg_text => 'Unexpected error from Populate_Dimension_Attribute');
      --piush_util.put_line('Raising exception FEM_INTG_DIM_RULE_attr_err');
      RAISE FEM_INTG_DIM_RULE_attr_err;
    END IF;


    -------------------------------------------------------------------------
    --  Store MAX flex value ID from member table into
    --  fem_intg_dim_rule_defs.max_flex_value_id_Processed
    -------------------------------------------------------------------------
    pv_progress := 'Before update of fem_intg_dim_rule_defs.max_flex_value_id_processed';
    --piush_util.put_line(pv_progress);

    UPDATE fem_intg_dim_rule_defs
    SET    max_flex_value_id_processed
                = FEM_INTG_DIM_RULE_ENG_PKG.pv_max_ccid_to_be_mapped
    WHERE  dim_rule_obj_def_id = FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_rule_obj_def_id;

    FEM_ENGINES_PKG.Tech_Message
    (
       p_severity => pc_log_level_procedure
      ,p_module   => pc_module_name||c_func_name
      ,p_msg_text => 'Update fem_intg_dim_rule_defs.max_flex_value_id_processed'||
           'with '||FEM_INTG_DIM_RULE_ENG_PKG.pv_max_ccid_to_be_mapped);

  v_rows_processed :=
               NVL(v_main_insert_gt_count,0)
             + NVL(v_comp_insert_gt_count,0)
             + NVL(v_cc_insert_gt_count,0)
             + NVL(v_comp_member_b_count,0)
             + NVL(v_comp_member_vl_count,0)
             + NVL(v_cc_member_b_count,0)
             + NVL(v_comp_member_tl_count,0)
             + NVL(v_cc_member_tl_count,0)
             + NVL(v_cc_member_vl_count,0)
             + NVL(v_insert_member_b_count,0)
             + NVL(v_merge_count,0)
             + NVL(v_insert_member_vl_count,0)
             + NVL(v_comp_member_vl_count,0)
             + NVL(v_attr_row_count, 0);
    COMMIT;

    pv_progress := 'Before getting list of columns to be mapped';
    --piush_util.put_line(pv_progress);

    /*
     * Get the columns to be updated
     */

    pv_progress := 'Before building map table dynamic update stmt';
    --piush_util.put_line(pv_progress);

    /* UPDATE MAPPING TABLE
     * =======================
     *
     * Build dyanmic SQL to insert new members into FEM mebers table
     * Only new members will be inserted into the table
     */

    IF FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_varchar_label = 'INTERCOMPANY'
    THEN

      v_column_list :=  FEM_INTG_DIM_RULE_ENG_PKG.pv_member_col;
      v_value_list := 'member_table.COMPANY_COST_CENTER_ORG_ID';

    ELSIF FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_varchar_label
                         = 'COMPANY_COST_CENTER_ORG'
    THEN

      FOR rec IN ColumnList LOOP
        IF rec.column_name <> 'INTERCOMPANY_ID' THEN
          v_column_list := v_column_list || rec.column_name || ',';
          v_value_list := v_value_list || 'member_table.'|| FEM_INTG_DIM_RULE_ENG_PKG.pv_member_col || ',';
        END IF;
      END LOOP;

      v_column_list :=  '(' || TRIM(TRAILING ',' FROM v_column_list) || ')';
      v_value_list := TRIM(TRAILING ',' FROM v_value_list);

    ELSE

      FOR rec IN ColumnList LOOP
        v_column_list := v_column_list || rec.column_name || ',';
        v_value_list := v_value_list || 'member_table.'|| FEM_INTG_DIM_RULE_ENG_PKG.pv_member_col || ',';
      END LOOP;

      v_column_list :=  '(' || TRIM(TRAILING ',' FROM v_column_list) || ')';
      v_value_list := TRIM(TRAILING ',' FROM v_value_list);
    END IF;

    FEM_ENGINES_PKG.Tech_Message
      (
         p_severity => pc_log_level_procedure
        ,p_module   => pc_module_name||c_func_name
        ,p_msg_text => 'Columns '||v_column_list||' will be updated in mapping table');

   --bugfix 8780516
   -- IF FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_varchar_label <> 'GEOGRAPHY'
   -- THEN
    --dedutta : removed the geography-check
    NonNullFlag := false;
    open ColumnList;
    fetch ColumnList into ColumnList_rec;
    if ColumnList%found then
      NonNullFlag := true;
    end if;
    close ColumnList;

    IF NonNullFlag   THEN

      v_upd_map_table_stmt := 'UPDATE fem_intg_ogl_ccid_map fiocm
                               SET ' || v_column_list || ' = (
                               SELECT ' || v_value_list || '
                               FROM '|| FEM_INTG_DIM_RULE_ENG_PKG.pv_member_vl_object_name||' member_table
               ,   gl_code_combinations GCC
              WHERE GCC.code_combination_id = fiocm.code_combination_id
                AND member_table.value_set_id = :v_fem_vs_id
                AND member_table.'||FEM_INTG_DIM_RULE_ENG_PKG.pv_member_display_code_col
                 ||' = ';
      v_upd_map_table_stmt := v_upd_map_table_stmt || 'GCC.'||
            FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(1).application_column_name||'||''-''
             ||GCC.'||FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(2).application_column_name;

      IF fem_intg_dim_rule_eng_pkg.pv_segment_count > 2
      THEN
        v_upd_map_table_stmt := v_upd_map_table_stmt || '||''-''||GCC.';
        v_upd_map_table_stmt := v_upd_map_table_stmt ||
            FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(3).application_column_name;
      END IF;

      IF FEM_INTG_DIM_RULE_ENG_PKG.pv_segment_count > 3
      THEN
        v_upd_map_table_stmt := v_upd_map_table_stmt ||'||''-''||GCC.'||
           FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(4).application_column_name;
      END IF;

      IF FEM_INTG_DIM_RULE_ENG_PKG.pv_segment_count > 4
      THEN
        v_upd_map_table_stmt := v_upd_map_table_stmt ||'||''-''||GCC.'||
           FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(5).application_column_name;
      END IF;
      v_upd_map_table_stmt := v_upd_map_table_stmt ||')';

      IF FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_varchar_label = 'NATURAL_ACCOUNT'
      THEN
      v_upd_map_table_stmt := v_upd_map_table_stmt || ', extended_account_type =
                       (select attr.dim_attribute_varchar_member
                       from   fem_nat_accts_attr attr
                             ,fem_nat_accts_b b
                             ,gl_code_combinations g
                       where  attr.value_set_id = b.value_set_id
                         and  attr.natural_account_id = b.natural_account_id
                         and  attr.value_set_id = :v_fem_vs_id
                         and  g.chart_of_accounts_id = :pv_coa_id
                         and  attr.attribute_id = :v_ext_acct_type_attr_id
                         and  attr.version_id = :v_ext_acct_type_ver_id
                         and  b.natural_account_display_code =  g.'
                                    ||FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(1).application_column_name ||'||''-''
             ||g.'||FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(2).application_column_name;
        IF fem_intg_dim_rule_eng_pkg.pv_segment_count > 2
        THEN
          v_upd_map_table_stmt := v_upd_map_table_stmt || '||''-''||g.';
          v_upd_map_table_stmt := v_upd_map_table_stmt ||
              FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(3).application_column_name;      END IF;

        IF FEM_INTG_DIM_RULE_ENG_PKG.pv_segment_count > 3
        THEN
          v_upd_map_table_stmt := v_upd_map_table_stmt ||'||''-''||g.'||
           FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(4).application_column_name;
        END IF;

        IF FEM_INTG_DIM_RULE_ENG_PKG.pv_segment_count > 4
        THEN
          v_upd_map_table_stmt := v_upd_map_table_stmt ||'||''-''||g.'||
           FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(5).application_column_name;
        END IF;

        v_upd_map_table_stmt := v_upd_map_table_stmt || ' and  g.summary_flag = ''N''
        and  fiocm.code_combination_id = g.code_combination_id)';

      END IF;

      v_upd_map_table_stmt := v_upd_map_table_stmt ||' WHERE fiocm.code_combination_id between :v_ccid_low AND :v_ccidhigh
                   AND fiocm.global_vs_combo_id = :v_gvsc_id';


      --
      -- Execute built statement for updating mapping table
      -- with correct dimension member ID values
      --
      pv_progress := 'Before executing update map';
      --piush_util.put_line(pv_progress);

      FEM_ENGINES_PKG.Tech_Message
          (p_severity => pc_log_level_statement
          ,p_module   => pc_module_name||c_func_name
          ,p_app_name => 'FEM'
          ,p_msg_name => 'FEM_GL_POST_204'
          ,p_token1   => 'VAR_NAME'
          ,p_value1   => 'SQL Statement'
          ,p_token2   => 'VAR_VAL'
          ,p_value2   => v_upd_map_table_stmt);

      IF FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_varchar_label = 'NATURAL_ACCOUNT'
      THEN
        EXECUTE IMMEDIATE v_upd_map_table_stmt
        USING FEM_INTG_DIM_RULE_ENG_PKG.pv_fem_vs_id
             ,FEM_INTG_DIM_RULE_ENG_PKG.pv_fem_vs_id
             ,FEM_INTG_DIM_RULE_ENG_PKG.pv_coa_id
             ,FEM_INTG_DIM_RULE_ENG_PKG.pv_ext_acct_type_attr_id
             ,FEM_INTG_DIM_RULE_ENG_PKG.pv_ext_acct_attr_version_id
             ,FEM_INTG_DIM_RULE_ENG_PKG.pv_max_ccid_processed+1
             ,FEM_INTG_DIM_RULE_ENG_PKG.pv_max_ccid_to_be_mapped
             ,FEM_INTG_DIM_RULE_ENG_PKG.pv_gvsc_id;
      ELSE
        EXECUTE IMMEDIATE v_upd_map_table_stmt
        USING FEM_INTG_DIM_RULE_ENG_PKG.pv_fem_vs_id
             ,FEM_INTG_DIM_RULE_ENG_PKG.pv_max_ccid_processed+1
             ,FEM_INTG_DIM_RULE_ENG_PKG.pv_max_ccid_to_be_mapped
             ,FEM_INTG_DIM_RULE_ENG_PKG.pv_gvsc_id;
      END IF;

      v_upd_map_table_count := SQL%ROWCOUNT;
      v_rows_processed := v_rows_processed + v_upd_map_table_count;
      FEM_ENGINES_PKG.Tech_Message
         (p_severity => pc_log_level_statement
         ,p_module   => pc_module_name||c_func_name
         ,p_app_name => 'FEM'
         ,p_msg_name => 'FEM_GL_POST_217'
         ,p_token1   => 'TABLE'
         ,p_value1   => 'fem_intg_ogl_ccid_map'
         ,p_token2   => 'NUM'
         ,p_value2   => v_upd_map_table_count);

      pv_progress := 'after executing update map';
      --piush_util.put_line(pv_progress);

    x_row_count_tot := v_rows_processed;

  END IF;

  COMMIT;

      -- start bug fix 5377544

      --Start bug fix 5560443
      IF ( FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_varchar_label = 'INTERCOMPANY' AND
      --Start bug fix 5578766
           (p_calling_module IS NULL OR p_calling_module <> 'HIER_MULTI_SEG')) THEN
      --End bug fix 5578766

      --End bug fix 5560443

             -- Since requests will reach completed phase irrespective of status
             -- Check if any dimension rule requests which are not having completed phase
             -- for any dimension other than org dimension for the same chart of account
             -- If any request found then issue sleep timer
             LOOP
             BEGIN
                   SELECT 1
                     INTO v_dim_rule_req_count
                     FROM dual
                    WHERE EXISTS ( SELECT 1
                                     FROM fnd_concurrent_programs fcp,
                                          fnd_concurrent_requests fcr,
                                          fem_intg_dim_rules idr,
                                          fem_object_definition_b fodb
                                    WHERE fcp.concurrent_program_id = fcr.concurrent_program_id
                                      AND fcp.application_id = fcr.program_application_id
                                      AND fcp.application_id = 274
                                      AND fcp.concurrent_program_name = 'FEM_INTG_DIM_RULE_ENGINE'
                                      AND fcr.phase_code <> 'C'
                                      AND idr.dim_rule_obj_id = fodb.object_id
                                      AND idr.chart_of_accounts_id = FEM_INTG_DIM_RULE_ENG_PKG.pv_coa_id
                                      --Start bug fix 5560443
                                      AND idr.dimension_id <> 0
                                      --End bug fix 5560443
                                      AND fcr.argument1 = fodb.object_definition_id
                                      AND fcr.argument2 = 'MEMBER');
                   DBMS_LOCK.SLEEP(pc_sleep_second);
                   EXCEPTION WHEN NO_DATA_FOUND THEN EXIT;
             END;
             END LOOP;

             select nvl(value,1)*2 no_of_workers
             into v_Num_Workers
             from v$parameter
             where name = 'cpu_count';

             FEM_ENGINES_PKG.User_Message(
               p_app_name => 'FEM',
               p_msg_text => 'Kicking off '||v_Num_Workers||' workers requests at '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')
             );

             FEM_ENGINES_PKG.Tech_Message(
               p_severity => pc_log_level_statement,
               p_module   => pc_module_name||c_func_name,
               p_msg_text => 'USING ' ||
                   TO_CHAR(FEM_INTG_DIM_RULE_ENG_PKG.pv_coa_id) || ', ' ||
                   TO_CHAR(FEM_INTG_DIM_RULE_ENG_PKG.pv_gvsc_id)
                 );

             -- AD Parallel framework Manager processing

             --Purge all the info from ad processing tables
              ad_parallel_updates_pkg.purge_processed_units
                                                  (X_owner  => 'FEM',
                                                   X_table  => 'FEM_INTG_OGL_CCID_MAP',
                                                   X_script => FEM_INTG_DIM_RULE_ENG_PKG.pv_coa_id);

              ad_parallel_updates_pkg.delete_update_information
                                                  (X_update_type => ad_parallel_updates_pkg.ROWID_RANGE,
                                                   X_owner       =>  'FEM',
                                                   X_table       =>  'FEM_INTG_OGL_CCID_MAP',
                                                   X_script      =>  FEM_INTG_DIM_RULE_ENG_PKG.pv_coa_id);

              -- submit update CCID worker
              AD_CONC_UTILS_PKG.submit_subrequests( X_errbuf                    => X_errbuf,
                                                    X_retcode                   => v_completion_code,
                                                    X_WorkerConc_app_shortname  => 'FEM',
                                                    X_WorkerConc_progname       => 'FEM_INTG_DIM_RULE_WORKER',
                                                    X_batch_size                => pv_batch_size,
                                                    X_Num_Workers               => v_Num_Workers,
                                                    X_Argument4                 => FEM_INTG_DIM_RULE_ENG_PKG.pv_coa_id,
                                                    X_Argument5                 => FEM_INTG_DIM_RULE_ENG_PKG.pv_gvsc_id,
                                                    X_Argument6                 => FEM_INTG_DIM_RULE_ENG_PKG.pv_max_ccid_processed,
                                                    X_Argument7                 => FEM_INTG_DIM_RULE_ENG_PKG.pv_max_ccid_to_be_mapped
                                                  );

              IF v_completion_code = 2 THEN

                RAISE FEM_INTG_DIM_RULE_worker_err;

              END IF;

              --
              -- Update dimension rule definitions for single segment/value rules
              --bugfix 8780516
              -- Start bug fix 5844990
       BEGIN
       --bug 9114881
        BEGIN
         select min(map.code_combination_id)
           INTO l_new_max_ccid_processed
           FROM gl_code_combinations gcc,
               fem_intg_ogl_ccid_map map
           WHERE gcc.chart_of_accounts_id = FEM_INTG_DIM_RULE_ENG_PKG.pv_coa_id
            AND gcc.summary_flag = 'N'
            AND map.code_combination_id = gcc.code_combination_id
            AND map.global_vs_combo_id = FEM_INTG_DIM_RULE_ENG_PKG.pv_gvsc_id
            AND ( map.COMPANY_COST_CENTER_ORG_ID = -1 OR
                  map.NATURAL_ACCOUNT_ID = -1 OR
                  map.LINE_ITEM_ID = -1 OR
                  map.PRODUCT_ID = -1 OR
                  map.CHANNEL_ID = -1 OR
                  map.PROJECT_ID = -1 OR
                  map.CUSTOMER_ID = -1 OR
                  map.ENTITY_ID = -1 OR
                  map.INTERCOMPANY_ID = -1 OR
                  map.USER_DIM1_ID = -1 OR
                  map.USER_DIM2_ID = -1 OR
                  map.USER_DIM3_ID = -1 OR
                  map.USER_DIM4_ID = -1 OR
                  map.USER_DIM5_ID = -1 OR
                  map.USER_DIM6_ID = -1 OR
                  map.USER_DIM7_ID = -1 OR
                  map.USER_DIM8_ID = -1 OR
                  map.USER_DIM9_ID = -1 OR
                  map.USER_DIM10_ID = -1 OR
                  map.TASK_ID = -1 OR
                  map.EXTENDED_ACCOUNT_TYPE = '-1');

     EXCEPTION
     WHEN OTHERS THEN
          FEM_ENGINES_PKG.Tech_Message(
          p_severity => pc_log_level_statement,
          p_module   => pc_module_name || 'Value of Max_ccid_processed',
          p_msg_text => 'USING ' ||
             TO_CHAR(l_new_max_ccid_processed) || ', ' ||
               'for  unmapped accounts excepton raised'
           );


       END;


       FEM_ENGINES_PKG.User_Message(
         p_app_name => 'FEM',
         p_msg_text => 'Value of Max_ccid_processed  '||l_new_max_ccid_processed ||' at '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')
         );

        FEM_ENGINES_PKG.Tech_Message(
          p_severity => pc_log_level_statement,
          p_module   => pc_module_name || 'Value of Max_ccid_processed',
          p_msg_text => 'USING ' ||
             TO_CHAR(l_new_max_ccid_processed) || ', ' ||
               'for  unmapped accounts'
           );



                SELECT min(gcc.code_combination_id) - 1
                  INTO v_max_ccid_to_be_mapped
                  FROM gl_code_combinations gcc,
                       fem_intg_ogl_ccid_map map
                 WHERE gcc.chart_of_accounts_id = FEM_INTG_DIM_RULE_ENG_PKG.pv_coa_id
                   AND gcc.summary_flag = 'N'
                   AND gcc.code_combination_id BETWEEN NVL(l_new_max_ccid_processed ,FEM_INTG_DIM_RULE_ENG_PKG.pv_max_ccid_processed)
                                                   AND FEM_INTG_DIM_RULE_ENG_PKG.pv_max_ccid_to_be_mapped
                   AND map.code_combination_id = gcc.code_combination_id
                   AND map.global_vs_combo_id = FEM_INTG_DIM_RULE_ENG_PKG.pv_gvsc_id
                   AND ( map.COMPANY_COST_CENTER_ORG_ID = -1 OR
                         map.NATURAL_ACCOUNT_ID = -1 OR
                         map.LINE_ITEM_ID = -1 OR
                         map.PRODUCT_ID = -1 OR
                         map.CHANNEL_ID = -1 OR
                         map.PROJECT_ID = -1 OR
                         map.CUSTOMER_ID = -1 OR
                         map.ENTITY_ID = -1 OR
                         map.INTERCOMPANY_ID = -1 OR
                         map.USER_DIM1_ID = -1 OR
                         map.USER_DIM2_ID = -1 OR
                         map.USER_DIM3_ID = -1 OR
                         map.USER_DIM4_ID = -1 OR
                         map.USER_DIM5_ID = -1 OR
                         map.USER_DIM6_ID = -1 OR
                         map.USER_DIM7_ID = -1 OR
                         map.USER_DIM8_ID = -1 OR
                         map.USER_DIM9_ID = -1 OR
                         map.USER_DIM10_ID = -1 OR
                         map.TASK_ID = -1 OR
                         map.EXTENDED_ACCOUNT_TYPE = '-1');

                EXCEPTION WHEN OTHERS THEN NULL;
              END;

               FEM_ENGINES_PKG.User_Message(
                p_app_name => 'FEM',
                p_msg_text => 'set max_ccid_processed to v_max_ccid_to_be_mapped  value : '||v_max_ccid_to_be_mapped ||' at '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS')
         );

               FEM_ENGINES_PKG.Tech_Message(
                p_severity => pc_log_level_statement,
                p_module   => pc_module_name || 'Value of v_max_ccid_to_be_mapped',
                p_msg_text => 'USING ' ||
                  TO_CHAR(v_max_ccid_to_be_mapped) || ', ' ||
                  'for  unmapped accounts'
           );
           --end bugfix 9114881


              UPDATE FEM_INTG_DIM_RULE_DEFS
              SET MAX_CCID_PROCESSED = NVL( v_max_ccid_to_be_mapped,
                                            FEM_INTG_DIM_RULE_ENG_PKG.pv_max_ccid_to_be_mapped )
              WHERE DIM_RULE_OBJ_DEF_ID IN (   SELECT defs.dim_rule_obj_def_id
                                                 FROM fem_intg_dim_rules idr,
                                                      fem_object_definition_b fodb,
                                                      fem_xdim_dimensions fxd,
                                                      fem_intg_dim_rule_defs defs,
                                                      fem_tab_columns_b ftcb
                                                WHERE ftcb.table_name = 'FEM_BALANCES'
                                                  AND ftcb.fem_data_type_code = 'DIMENSION'
                                                  AND ftcb.dimension_id = fxd.dimension_id
                                                  AND DECODE(ftcb.column_name,'INTERCOMPANY_ID', 0, fxd.dimension_id) = idr.dimension_id
                                                  AND idr.chart_of_accounts_id = FEM_INTG_DIM_RULE_ENG_PKG.pv_coa_id
                                                  AND idr.dim_rule_obj_id = fodb.object_id
                                                  AND defs.dim_rule_obj_def_id = fodb.object_definition_id);
                                                  -- Bugfix 5946597
                                                  --AND defs.dim_mapping_option_code IN ('SINGLESEG','SINGLEVAL') );

              -- End bug fix 5844990
              v_rows_processed := SQL%ROWCOUNT;

              COMMIT;

              FEM_ENGINES_PKG.Tech_Message(
                  p_severity => pc_log_level_statement,
                  p_module   => pc_module_name || '.cnt_update_FEM_INTG_DIM_RULE_DEFS',
                  p_msg_text => v_rows_processed
                 );

              x_row_count_tot := x_row_count_tot + v_rows_processed;

              -- Start bug Fix 5447696
              BEGIN
                 OPEN fch_vs_cursor FOR v_fch_vs_select_stmt USING FEM_INTG_DIM_RULE_ENG_PKG.pv_fem_vs_id;
                 FETCH fch_vs_cursor INTO v_gcs_vs_id;

                 IF (v_gcs_vs_id IS NOT NULL) THEN

                     -- submit entity orgs synch program
                     v_request_id := FND_REQUEST.submit_request( application => 'GCS',
                                                                 program     => 'FCH_UPDATE_ENTITY_ORGS',
                                                                 sub_request => FALSE);

                     FEM_ENGINES_PKG.User_Message(
                       p_app_name => 'FEM',
                       p_msg_text => 'Submitted Update Entity Organizations Request ' || v_request_id
                     );

                 END IF;

                 CLOSE fch_vs_cursor;

                 EXCEPTION WHEN OTHERS THEN NULL;
              END;
             -- End bug Fix 5447696

      END IF;

      x_completion_code := v_completion_code;
      -- end bug fix 5377544

  FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => pc_module_name || c_func_name,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_202',
       p_token1   => 'FUNC_NAME',
       p_value1   => c_func_name,
       p_token2   => 'TIME',
       p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

  EXCEPTION
    WHEN FEM_INTG_DIM_RULE_ulock_err THEN

      ROLLBACK;

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_exception,
        p_module   => PC_module_name || c_func_name|| '.ulock_err_exception',
        p_app_name => 'FEM',
        p_msg_name => 'FEM_INTG_DIM_RULE_ULOCK_EXISTS'
      );

      FEM_ENGINES_PKG.User_Message(
        p_app_name => 'FEM',
        p_msg_name => 'FEM_INTG_DIM_RULE_ULOCK_EXISTS'
      );

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_procedure,
        p_module   => pc_module_name || c_func_name|| '.ulock_err_exception',
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_203',
        p_token1   => 'FUNC_NAME',
        p_value1   => c_func_name,
        p_token2   => 'TIME',
        p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
      );

      x_completion_code := 2;

    WHEN FEM_INTG_DIM_RULE_worker_err THEN

      ROLLBACK;

      FEM_ENGINES_PKG.Tech_Message(
         p_severity => pc_log_level_statement,
         p_module   => pc_module_name || '.worker_err',
         p_msg_text => 'Dimension Rule Worker Error: ' || X_errbuf
       );

      FEM_ENGINES_PKG.User_Message(
         p_app_name => 'FEM',
         p_msg_text => 'Dimension Rule Worker Error: ' || X_errbuf
      );

      x_completion_code := 2;

    WHEN OTHERS THEN
      --piush_util.put_line('Exception Block');
      --piush_util.put_line('SQLCODE = ' || SQLCODE);
      --piush_util.put_line('SQLERRM = ' || SQLERRM);
      --raise;
      ROLLBACK;
      FEM_ENGINES_PKG.Tech_Message
         (p_severity => pc_log_level_statement
         ,p_module   => pc_module_name||c_func_name
         ,p_msg_text => 'Error: ' || pv_progress);

      FEM_ENGINES_PKG.Tech_Message
         (p_severity => pc_log_level_statement
         ,p_module   => pc_module_name||c_func_name
         ,p_msg_text => 'Error: ' || sqlerrm);
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
       ,p_value1   => c_func_name
       ,p_token2   => 'TIME'
       ,p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));


     x_completion_code := 2;
  END;


-- ======================================================================
-- Procedure
--     Create_Parent_Members
-- Purpose
--     This routine
--  History
--     11-05-04  Jee Kim  Created
-- Arguments
--     x_completion_code        Completion status of the routine
-- ======================================================================

  PROCEDURE Create_Parent_Members(
      x_completion_code OUT NOCOPY NUMBER) IS

    FEM_INTG_fatal_err EXCEPTION;

    v_sql_stmt         VARCHAR2(2000);
    v_compl_code                NUMBER := 0;
    v_row_count_tot             NUMBER := 0;

  BEGIN

    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => 'fem.plsql.fem_intg_new_dim_member.Create_Parent_Members',
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_201',
       p_token1   => 'FUNC_NAME',
       p_value1   => 'FEM_INTG_NEW_DIM_MEMBER_PKG.Create_Parent_Members',
       p_token2   => 'TIME',
       p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

    x_completion_code := 0;

    -- Insert all distinct parent members from the hierarchy into
    -- the member GT table FEM_INTG_DIM_MEMBERS_GT
    v_sql_stmt :=
    'INSERT INTO fem_intg_dim_members_gt
      (dimension_id,
       segment1_value,
       segment2_value,
       segment3_value,
       segment4_value,
       segment5_value,
       concat_segment_value)
    SELECT DISTINCT
       '||FEM_INTG_HIER_RULE_ENG_PKG.pv_dim_id||',
       hgt.child_display_code,
       ''-1'',
       ''-1'',
       ''-1'',
       ''-1'',
       hgt.child_display_code
    FROM FEM_INTG_DIM_HIER_GT hgt,
         FND_FLEX_VALUES ff
    WHERE ff.flex_value_set_id = '||FEM_INTG_HIER_RULE_ENG_PKG.pv_aol_vs_id||'
    AND   ff.flex_value = hgt.child_display_code';



      FEM_ENGINES_PKG.Tech_Message
  (p_severity => pc_log_level_procedure,
   p_module   => 'fem.plsql.fem_intg_new_dim_member.Create_Parent_Members',
   p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_204',
         p_token1   => 'VAR_NAME',
         p_value1   => 'v_sql_stmt',
         p_token2   => 'VAR_VAL',
         p_value2   => v_sql_stmt);

      EXECUTE IMMEDIATE v_sql_stmt;
      COMMIT;
    --bugfix 8780516
    -- Bugfix 5333726
    -- Merge all parent members into the FEM member _B and _TL tables
    v_sql_stmt :=
      'MERGE INTO '||FEM_INTG_HIER_RULE_ENG_PKG.pv_dim_memb_b_tab||' b
       USING (SELECT gt.concat_segment_value,
               ffv.flex_value_id,
               ffv.enabled_flag
        FROM fem_intg_dim_members_gt gt,
             fnd_flex_values ffv
        WHERE ffv.flex_value_set_id = :pv_aol_vs_id
        AND   ffv.flex_value = gt.concat_segment_value) s
  ON (b.'||FEM_INTG_HIER_RULE_ENG_PKG.pv_dim_memb_col||' =s.flex_value_id
      AND b.value_set_id = :pv_dim_vs_id)
  WHEN MATCHED THEN UPDATE
  SET b.last_update_date = SYSDATE,
      b.ENABLED_FLAG = S.ENABLED_FLAG
  WHEN NOT MATCHED THEN
    INSERT
      (b.'||FEM_INTG_HIER_RULE_ENG_PKG.pv_dim_memb_col||',
       b.value_set_id,
       b.dimension_group_id,
       b.'||FEM_INTG_HIER_RULE_ENG_PKG.pv_dim_memb_disp_col||',
       b.enabled_flag,
       b.personal_flag,
       b.creation_date,
       b.created_by,
       b.last_updated_by,
       b.last_update_login,
       b.last_update_date,
       b.read_only_flag,
       b.object_version_number)
          VALUES
            (s.flex_value_id,
       :pv_dim_vs_id,
             NULL,
             s.concat_segment_value,
       s.enabled_flag,
       ''N'',
       SYSDATE,
       :pv_user_id,
       :pv_user_id,
       :pv_login_id,
       SYSDATE,
       ''N'',
       1)';

    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => 'fem.plsql.fem_intg_new_dim_member.Create_Parent_Members.',
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'v_sql_stmt',
       p_token2   => 'VAR_VAL',
       p_value2   => v_sql_stmt);

    EXECUTE IMMEDIATE v_sql_stmt
            USING FEM_INTG_HIER_RULE_ENG_PKG.pv_aol_vs_id,
      FEM_INTG_HIER_RULE_ENG_PKG.pv_dim_vs_id,
      FEM_INTG_HIER_RULE_ENG_PKG.pv_dim_vs_id,
      pv_user_id,
      pv_user_id,
      pv_login_id;

   --bugfix 8780516
    v_sql_stmt :=
      'MERGE INTO '||FEM_INTG_HIER_RULE_ENG_PKG.pv_dim_memb_tl_tab||' b
       USING (SELECT tl.flex_value_id, ffv.flex_value,
                     tl.description,
               tl.language, tl.source_lang
         FROM fem_intg_dim_members_gt gt,
              fnd_flex_values_tl tl,
              fnd_flex_values ffv
         WHERE tl.flex_value_id = ffv.flex_value_id
         AND   ffv.flex_value_set_id = :pv_aol_vs_id
         AND   ffv.flex_value = gt.concat_segment_value) s
       ON (b.'||FEM_INTG_HIER_RULE_ENG_PKG.pv_dim_memb_col||' = s.flex_value_id
           AND b.language = s.language
     AND b.value_set_id = :pv_dim_vs_id)
       WHEN MATCHED THEN UPDATE
            SET b.last_update_date = SYSDATE,
                b.description = s.description
       WHEN NOT MATCHED THEN
         INSERT
           (b.'||FEM_INTG_HIER_RULE_ENG_PKG.pv_dim_memb_col||',
            b.value_set_id,
      b.'||FEM_INTG_HIER_RULE_ENG_PKG.pv_dim_memb_name_col||',
      b.language,
      b.source_lang,
            b.creation_date,
      b.created_by,
      b.last_updated_by,
      b.last_update_login,
      b.last_update_date,
            b.description)
         VALUES
     (s.flex_value_id,
      :pv_dim_vs_id,
            s.flex_value,
            s.language,
      s.source_lang,
            SYSDATE,
      :pv_user_id,
      :pv_user_id,
      :pv_login_id,
      SYSDATE,
      s.description)';

    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => 'fem.plsql.fem_intg_new_dim_member.Create_Parent_Members.',
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'v_sql_stmt',
       p_token2   => 'VAR_VAL',
       p_value2   => v_sql_stmt);

    EXECUTE IMMEDIATE v_sql_stmt
            USING FEM_INTG_HIER_RULE_ENG_PKG.pv_aol_vs_id,
      FEM_INTG_HIER_RULE_ENG_PKG.pv_dim_vs_id,
      FEM_INTG_HIER_RULE_ENG_PKG.pv_dim_vs_id,
      pv_user_id,
      pv_user_id,
      pv_login_id;


    -- Initialize the variables requred for Populate_Attr( )
    FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_rule_obj_id
                      := FEM_INTG_HIER_RULE_ENG_PKG.pv_dim_rule_obj_id;
    FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_rule_obj_def_id
                      := FEM_INTG_HIER_RULE_ENG_PKG.pv_dim_rule_obj_def_id;
    FEM_INTG_DIM_RULE_ENG_PKG.pv_user_id := pv_user_id;

    FEM_INTG_DIM_RULE_ENG_PKG.Init;

    FEM_ENGINES_PKG.User_Message(
       p_app_name => 'FEM',
       p_msg_name => 'FEM_INTG_DIM_MEMB_501');

    -- Call FEM_INTG_NEW_MEMBER_PKG.Populate_Attr( ).
    fem_intg_new_dim_member_pkg.Populate_Dimension_Attribute(
      p_summary_flag                => 'Y',
      x_completion_code             => v_compl_code,
      x_row_count_tot               => v_row_count_tot);

    IF v_compl_code = 2 THEN
       RAISE FEM_INTG_fatal_err;
    END IF;

    COMMIT;

    x_completion_code := 0;

    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => 'fem.plsql.fem_intg_new_dim_member.Create_Parent_Members',
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_202',
       p_token1   => 'FUNC_NAME',
       p_value1   => 'FEM_INTG_NEW_DIM_MEMBER_PKG.Create_Parent_Members',
       p_token2   => 'TIME',
       p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

    return;

  EXCEPTION

    WHEN FEM_INTG_fatal_err THEN
      ROLLBACk;

      FEM_ENGINES_PKG.Tech_Message
  (p_severity => pc_log_level_unexpected,
   p_module   => 'fem.plsql.fem_intg_new_dim_member.Create_Parent_Members',
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
         p_module   => 'fem.plsql.fem_intg_new_dim_member.Create_Parent_Members',
   p_app_name => 'FEM',
   p_msg_name => 'FEM_GL_POST_203',
   p_token1   => 'FUNC_NAME',
         p_value1   => 'FEM_INTG_NEW_DIM_MEMBER_PKG.Create_Parent_Members',
   p_token2   => 'TIME',
   p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

      x_completion_code := 2;
      return;

    WHEN OTHERS THEN

      ROLLBACK;

      FEM_ENGINES_PKG.Tech_Message
  (p_severity => pc_log_level_unexpected,
   p_module   => 'fem.plsql.fem_intg_new_dim_member.Create_Parent_Members',
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
         p_module   => 'fem.plsql.fem_intg_new_dim_member.Create_Parent_Members',
   p_app_name => 'FEM',
   p_msg_name => 'FEM_GL_POST_203',
   p_token1   => 'FUNC_NAME',
         p_value1   => 'FEM_INTG_NEW_DIM_MEMBER_PKG.Create_Parent_Members',
   p_token2   => 'TIME',
   p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));

      x_completion_code := 2;
      return;

  END Create_Parent_Members;

  -- start Bug fix 5377544
  /*
  PROCEDURE Check_All_CCIDS_Mapped(x_result OUT NOCOPY VARCHAR2) IS
    v_unmapped_count NUMBER;
    v_mapped_count NUMBER;
  BEGIN
    x_result := 'ALL_MAPPED';
    IF FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_varchar_label = 'INTERCOMPANY'
    THEN
      SELECT nvl(sum(decode(intercompany_id,-1,1,0)),0)
            ,nvl(sum(decode(intercompany_id,-1,0,1)),0)
      INTO   v_unmapped_count
            ,v_mapped_count
      FROM   fem_intg_ogl_ccid_map
      WHERE  global_vs_combo_id = FEM_INTG_DIM_RULE_ENG_PKG.pv_gvsc_id;
      IF v_unmapped_count > 0
      THEN
        IF v_mapped_count = 0
        THEN
          x_result := 'NOTHING_MAPPED';
        ELSE
          x_result := 'SOME_UNMAPPED';
        END IF;
      ELSE
        x_result := 'ALL_MAPPED';
      END IF;
    END IF;
  END;
  */
  -- start Bug fix 5377544

  --
  -- Worker program API for FEM_INTG_OGL_CCID_MAP table update
  -- for single_segment dimension rules
  -- leveraging AD Parallel framework for Bug fix 5377544
  --

  PROCEDURE fem_intg_dim_rule_worker( X_errbuf                    OUT NOCOPY VARCHAR2,
                                          X_retcode                   OUT NOCOPY VARCHAR2,
                                          p_batch_size                IN NUMBER,
                                          p_Worker_Id                 IN NUMBER,
                                          p_Num_Workers               IN NUMBER,
                                          p_coa_id                    IN VARCHAR2,
                                          p_gvsc_id                   IN VARCHAR2,
                                          p_max_ccid_processed        IN VARCHAR2,
                                          p_max_ccid_to_be_mapped     IN VARCHAR2
                                         )
  IS
      v_product               VARCHAR2(30) := 'FEM';
      v_table_name            VARCHAR2(30) := 'FEM_INTG_OGL_CCID_MAP';
      v_update_name           VARCHAR2(30);
      v_status                VARCHAR2(30);
      v_industry              VARCHAR2(30);
      v_retstatus             BOOLEAN;
      v_table_owner           VARCHAR2(30);
      --bugfix 8780516
      v_any_rows_to_process   BOOLEAN := FALSE;
      v_start_rowid           ROWID;
      v_end_rowid             ROWID;
      v_rows_processed        NUMBER;
      v_module_name           VARCHAR2(100);
      --bugfix 8780516
      v_upd_stmt1             VARCHAR2(25000);
      v_upd_stmt2             VARCHAR2(1000);
      v_upd_stmt3             VARCHAR2(200);
      v_ccid_cur_stmt         VARCHAR2(3000);
      v_ccid_update_stmt      VARCHAR2(26000);
      -- end 8780516
      v_ext_acct_type_attr_id NUMBER;
      v_ext_acct_type_ver_id  NUMBER;
      v_start_pos             NUMBER;
      --bugfix 8780516
      -- Start bugfix 5864123
      --TYPE ccid_cur_type IS REF CURSOR;
      --v_ccid_cur ccid_cur_type;
      --TYPE ccid_list_type IS TABLE OF NUMBER;
      --v_ccid_list ccid_list_type;
      v_segment_list_stmt            VARCHAR2(2000);
      v_collection_list_select_stmt  VARCHAR2(2000);
      v_collection_list_declare_stmt VARCHAR2(5000);
      v_mapping_update_block         VARCHAR2(32000);
      -- End bugfix 5864123
      --end 8780516

      CURSOR c_upd_dim_list_cur (p_coa_id NUMBER)
      IS
      SELECT ftcb.column_name target_col,
             fxd.member_col source_col,
             fxd.member_b_table_name source_b_table_name,
             fxd.member_display_code_col source_display_code_col,
             NVL(defs.fem_value_set_id,-1) fem_value_set_id,
             defs.application_column_name1,
             defs.default_member_id,
             defs.dim_mapping_option_code
        FROM fem_intg_dim_rules idr,
             fem_object_definition_b fodb,
             fem_xdim_dimensions fxd,
             fem_intg_dim_rule_defs defs,
             fem_tab_columns_b ftcb
       WHERE ftcb.table_name = 'FEM_BALANCES'
         AND ftcb.fem_data_type_code = 'DIMENSION'
         AND ftcb.dimension_id = fxd.dimension_id
         AND DECODE(ftcb.column_name,'INTERCOMPANY_ID', 0, fxd.dimension_id) = idr.dimension_id
         AND idr.dim_rule_obj_id = fodb.object_id
         AND idr.chart_of_accounts_id = p_coa_id
         AND defs.dim_rule_obj_def_id = fodb.object_definition_id
         AND defs.dim_mapping_option_code IN ('SINGLESEG','SINGLEVAL');

  BEGIN

      v_module_name := 'fem.plsql.fem_intg_dim.FEM_INTG_DIM_RULE_WORKER';

       FEM_ENGINES_PKG.Tech_Message(
         p_severity => pc_log_level_procedure,
         p_module   => v_module_name || '.start_worker',
         p_msg_text => 'Start of mapping table update worker id : '||p_Worker_Id
       );

       FEM_ENGINES_PKG.User_Message(
          p_app_name => 'FEM',
          p_msg_text => '<< Start of mapping table update worker >>'
        );
       FEM_ENGINES_PKG.User_Message(
          p_app_name => 'FEM',
          p_msg_text => 'p_Worker_Id             : '||p_Worker_Id
        );
       FEM_ENGINES_PKG.User_Message(
          p_app_name => 'FEM',
          p_msg_text => 'p_coa_id                : '||p_coa_id
        );
       FEM_ENGINES_PKG.User_Message(
          p_app_name => 'FEM',
          p_msg_text => 'p_gvsc_id               : '||p_gvsc_id
        );
       FEM_ENGINES_PKG.User_Message(
          p_app_name => 'FEM',
          p_msg_text => 'p_Num_Workers           : '||p_Num_Workers
        );
       FEM_ENGINES_PKG.User_Message(
          p_app_name => 'FEM',
          p_msg_text => 'p_Worker_Id             : '||p_Worker_Id
        );
       FEM_ENGINES_PKG.User_Message(
          p_app_name => 'FEM',
          p_msg_text => 'p_max_ccid_processed    : '||p_max_ccid_processed
        );
       FEM_ENGINES_PKG.User_Message(
          p_app_name => 'FEM',
          p_msg_text => 'p_max_ccid_to_be_mapped : '||p_max_ccid_to_be_mapped
        );

      --
      -- get schema name of the table for ROWID range processing
      --
      v_retstatus := fnd_installation.get_app_info( v_product,
                                                    v_status,
                                                    v_industry,
                                                    v_table_owner);

      if ((v_retstatus = FALSE) OR (v_table_owner is null)) then
           raise_application_error(-20001, 'Cannot get schema name for product : '||v_product);
      end if;

       --bugfix 8780516
          v_upd_stmt1 := 'UPDATE FEM_INTG_OGL_CCID_MAP M  SET ';

          FOR v_upd_dim_list IN c_upd_dim_list_cur (p_coa_id) LOOP

              IF v_upd_dim_list.TARGET_COL = 'NATURAL_ACCOUNT_ID' THEN

              -- Natural Account will always be SINGLESEG
              -- so explicit dim_mapping_option_code check not required

                    SELECT a.attribute_id
                           ,v.version_id
                      INTO v_ext_acct_type_attr_id
                           ,v_ext_acct_type_ver_id
                      FROM fem_dim_attributes_b a,
                           fem_dim_attr_versions_b v
                     WHERE a.dimension_id = 2
                       AND a.attribute_varchar_label='EXTENDED_ACCOUNT_TYPE'
                       AND v.attribute_id            = a.attribute_id
                       AND v.default_version_flag    = 'Y';

                    --Start Bugfix 5653284
                    --Start bugfix 5864123
                    v_upd_stmt1 := v_upd_stmt1 ||
                    'EXTENDED_ACCOUNT_TYPE = NVL(('||
                    'SELECT '||
                    'attr.dim_attribute_varchar_member '||
                    'FROM '||
                    'fem_nat_accts_attr attr,'||
                    'fem_nat_accts_b b '||
                    'WHERE '||
                    'attr.value_set_id=b.value_set_id AND '||
                    'attr.natural_account_id=b.natural_account_id AND '||
                    'attr.value_set_id='||v_upd_dim_list.FEM_VALUE_SET_ID||' AND '||
                    'b.natural_account_display_code=v_' ||
                                                lower(v_upd_dim_list.APPLICATION_COLUMN_NAME1) ||
                                                '_list(i) AND '||
                    'attr.attribute_id='||v_ext_acct_type_attr_id||' AND '||
                    'attr.version_id='||v_ext_acct_type_ver_id||
                    '),-1),';

              END IF;

              IF v_upd_dim_list.dim_mapping_option_code = 'SINGLESEG' THEN
                  v_upd_stmt1 := v_upd_stmt1 ||
                                 v_upd_dim_list.TARGET_COL || ' = NVL(('||
                                                                      'SELECT '||
                                                                      v_upd_dim_list.SOURCE_COL ||
                                                                      ' FROM '||
                                                                      v_upd_dim_list.SOURCE_B_TABLE_NAME || ' b '||
                                                                      'WHERE '||
                                                                      'b.value_set_id = '||v_upd_dim_list.FEM_VALUE_SET_ID||' AND '||
                                                                      'b.' || v_upd_dim_list.SOURCE_DISPLAY_CODE_COL ||
                                                                      '=v_' ||
                                                                             lower(v_upd_dim_list.APPLICATION_COLUMN_NAME1) ||
                                                                             '_list(i)),-1),';
                     -- Bugfix 6367995
                    IF (v_segment_list_stmt IS NULL OR INSTR(v_segment_list_stmt,lower(v_upd_dim_list.APPLICATION_COLUMN_NAME1 || ',')) = 0) THEN
                      v_segment_list_stmt := v_segment_list_stmt ||
                                             ',NVL(' ||
                                             lower(v_upd_dim_list.APPLICATION_COLUMN_NAME1) ||
                                             ',-1)';
                      v_collection_list_select_stmt := v_collection_list_select_stmt ||
                                                ',v_' ||
                                                lower(v_upd_dim_list.APPLICATION_COLUMN_NAME1) ||
                                                '_list';
                      v_collection_list_declare_stmt := v_collection_list_declare_stmt ||
                                                'v_' ||
                                                lower(v_upd_dim_list.APPLICATION_COLUMN_NAME1) ||
                                                '_list'||' segment_list_type;';
                    END IF;

                    --End Bugfix 5653284
              ELSE
                  v_upd_stmt1 := v_upd_stmt1 ||
                                 v_upd_dim_list.TARGET_COL || ' = '|| v_upd_dim_list.DEFAULT_MEMBER_ID || ',';
              END IF;

          END LOOP;

          v_upd_stmt1 := substr(v_upd_stmt1, 1, length(v_upd_stmt1)-1);

          v_upd_stmt2 := ' WHERE m.global_vs_combo_id = '||p_gvsc_id||' AND'||
                         ' m.code_combination_id = v_ccid_list(i);';

          v_ccid_update_stmt := v_upd_stmt1 || v_upd_stmt2;

          v_ccid_cur_stmt :=    'SELECT gcc.code_combination_id' ||
                                v_segment_list_stmt ||
                                ' FROM gl_code_combinations gcc,'||
                                'fem_intg_ogl_ccid_map map'||
                                ' WHERE gcc.chart_of_accounts_id = p_coa_id'||
                                ' AND gcc.summary_flag = ''N'''||
                                ' AND gcc.code_combination_id BETWEEN p_max_ccid_processed AND p_max_ccid_to_be_mapped'||
                                ' AND map.code_combination_id = gcc.code_combination_id'||
                                ' AND map.global_vs_combo_id = p_gvsc_id'||
                                ' AND map.rowid BETWEEN p_start_rowid and p_end_rowid' ||
                                -- Bugfix 5946597
                                ' AND -1 IN (map.COMPANY_COST_CENTER_ORG_ID,map.NATURAL_ACCOUNT_ID,map.LINE_ITEM_ID,' ||
                                'map.PRODUCT_ID,map.CHANNEL_ID,map.PROJECT_ID,map.CUSTOMER_ID,map.ENTITY_ID,map.INTERCOMPANY_ID,' ||
                                'map.USER_DIM1_ID,map.USER_DIM2_ID,map.USER_DIM3_ID,map.USER_DIM4_ID,map.USER_DIM5_ID,map.USER_DIM6_ID,' ||
                                'map.USER_DIM7_ID,map.USER_DIM8_ID,map.USER_DIM9_ID,map.USER_DIM10_ID,map.TASK_ID);';

      --end 8780516

      -- Worker processing
      --

      v_update_name := p_coa_id;

      ad_parallel_updates_pkg.initialize_rowid_range( ad_parallel_updates_pkg.ROWID_RANGE,
                                                      v_table_owner,
                                                      v_table_name,
                                                      v_update_name,
                                                      p_Worker_Id,
                                                      p_Num_Workers,
                                                      p_batch_size,
                                                      0);

      ad_parallel_updates_pkg.get_rowid_range( v_start_rowid,
                                               v_end_rowid,
                                               v_any_rows_to_process,
                                               p_batch_size,
                                               TRUE);
       --bugfix 8780516
        /*WHILE (v_any_rows_to_process = TRUE)  LOOP

          FEM_ENGINES_PKG.User_Message(
             p_app_name => 'FEM',
             p_msg_text => 'Processing rowid from ' || v_start_rowid || ' to '|| v_end_rowid || pv_crlf
           );

          v_upd_stmt1 := '
          UPDATE FEM_INTG_OGL_CCID_MAP M  SET ';

          FOR v_upd_dim_list IN c_upd_dim_list_cur (p_coa_id) LOOP

              IF v_upd_dim_list.TARGET_COL = 'NATURAL_ACCOUNT_ID' THEN

              -- Natural Account will always be SINGLESEG
              -- so explicit dim_mapping_option_code check not required

                    SELECT a.attribute_id
                           ,v.version_id
                      INTO v_ext_acct_type_attr_id
                           ,v_ext_acct_type_ver_id
                      FROM fem_dim_attributes_b a,
                           fem_dim_attr_versions_b v
                     WHERE a.dimension_id = 2
                       AND a.attribute_varchar_label='EXTENDED_ACCOUNT_TYPE'
                       AND v.attribute_id            = a.attribute_id
                       AND v.default_version_flag    = 'Y';

                    --Start Bugfix 5653284
                    v_upd_stmt1 := v_upd_stmt1 ||'
                    EXTENDED_ACCOUNT_TYPE = NVL( (
                      SELECT
                        attr.dim_attribute_varchar_member
                      FROM
                        fem_nat_accts_attr attr,
                        fem_nat_accts_b b,
                        gl_code_combinations g
                      WHERE
                        attr.value_set_id = b.value_set_id AND
                        attr.natural_account_id = b.natural_account_id AND
                        attr.value_set_id = '||v_upd_dim_list.FEM_VALUE_SET_ID||' AND
                        b.natural_account_display_code =  g.' ||
                        v_upd_dim_list.APPLICATION_COLUMN_NAME1 || ' AND
                        g.chart_of_accounts_id = '||p_coa_id||' AND
                        attr.attribute_id = '||v_ext_acct_type_attr_id||' AND
                        attr.version_id = '||v_ext_acct_type_ver_id||' AND
                        g.summary_flag = ''N'' AND
                        m.code_combination_id = g.code_combination_id
                    ), -1), ';

              END IF;

              IF v_upd_dim_list.dim_mapping_option_code = 'SINGLESEG' THEN
                  v_upd_stmt1 := v_upd_stmt1 ||'
                  '|| v_upd_dim_list.TARGET_COL || ' = NVL( (
                   SELECT
                     b.' || v_upd_dim_list.SOURCE_COL || '
                   FROM
                     ' || v_upd_dim_list.SOURCE_B_TABLE_NAME || ' B,
                     gl_code_combinations g
                   WHERE
                     b.value_set_id = '||v_upd_dim_list.FEM_VALUE_SET_ID||' AND
                     b.' || v_upd_dim_list.SOURCE_DISPLAY_CODE_COL ||
                     ' = g.' || v_upd_dim_list.APPLICATION_COLUMN_NAME1 ||' AND
                     g.chart_of_accounts_id = '||p_coa_id||' AND
                     g.summary_flag = ''N'' AND
                     m.code_combination_id = g.code_combination_id
                    ), -1), ';
                    --End Bugfix 5653284
               ELSE
                  v_upd_stmt1 := v_upd_stmt1 ||'
                  '|| v_upd_dim_list.TARGET_COL || ' = '|| v_upd_dim_list.DEFAULT_MEMBER_ID || ', ';
               END IF;

             END LOOP;

             v_upd_stmt1 := substr(v_upd_stmt1, 1, length(v_upd_stmt1)-2);

             v_upd_stmt3 := '
             WHERE m.global_vs_combo_id = :pv_gvsc_id AND
                   m.code_combination_id = :pv_ccid_val ';

             v_ccid_update_stmt := v_upd_stmt1 || v_upd_stmt3;

             v_ccid_cur_stmt :=    'SELECT code_combination_id
                                     FROM  fem_intg_ogl_ccid_map
                                     WHERE global_vs_combo_id = :pv_gvsc_id
                                       AND code_combination_id BETWEEN :max_ccid_processed AND :max_ccid_to_be_mapped
                                       AND rowid BETWEEN :rowid_low and :rowid_high';

      IF (v_ccid_cur_stmt IS NOT NULL AND v_ccid_update_stmt IS NOT NULL) THEN

          FEM_ENGINES_PKG.User_Message(
             p_app_name => 'FEM',
             p_msg_text => 'v_ccid_cur_stmt         : '||v_ccid_cur_stmt
           );

           FEM_ENGINES_PKG.User_Message(
              p_app_name => 'FEM',
              p_msg_text => 'v_ccid_update_stmt      : '
            );

          v_start_pos := 1;

          LOOP

              FEM_ENGINES_PKG.User_Message(
                 p_app_name => 'FEM',
                 p_msg_text => substr(v_ccid_update_stmt, v_start_pos, 4000)
               );

               v_start_pos := v_start_pos + 4000;
               EXIT WHEN v_start_pos > length(v_ccid_update_stmt);

          END LOOP;
      END IF;

          -- start table update logic
          OPEN v_ccid_cur FOR v_ccid_cur_stmt
          USING  p_gvsc_id, p_max_ccid_processed + 1, p_max_ccid_to_be_mapped, v_start_rowid, v_end_rowid;

          LOOP

              FETCH v_ccid_cur BULK COLLECT INTO v_ccid_list LIMIT pv_batch_size;

              IF (v_ccid_list.FIRST IS NOT NULL AND v_ccid_list.LAST IS NOT NULL) THEN

                  FORALL i IN v_ccid_list.FIRST..v_ccid_list.LAST
                      EXECUTE IMMEDIATE v_ccid_update_stmt
                      USING  p_gvsc_id, v_ccid_list(i);

              END IF;
              EXIT WHEN v_ccid_cur%NOTFOUND;
          END LOOP;

          CLOSE v_ccid_cur;
          -- end FEM update logic
          v_rows_processed := SQL%ROWCOUNT;
          ad_parallel_updates_pkg.processed_rowid_range( v_rows_processed,
                                                         v_end_rowid);
          COMMIT;*/
          -- start table update logic, For execute immediate we need not have new line characters in the
          -- executable code. Please don't bother about code formatting due to varchar2 variable's length issue
          v_mapping_update_block :=  'DECLARE ' ||
                                     'CURSOR v_ccid_cur(p_coa_id NUMBER,' ||
                                     'p_max_ccid_processed NUMBER,' ||
                                     'p_max_ccid_to_be_mapped NUMBER,' ||
                                     'p_gvsc_id NUMBER,' ||
                                     'p_start_rowid ROWID,' ||
                                     'p_end_rowid ROWID) IS ' ||
                                     v_ccid_cur_stmt ||
                                     'TYPE ccid_list_type IS TABLE OF NUMBER;' ||
                                     'v_ccid_list FEM_INTG_NEW_DIM_MEMBER_PKG.ccid_list_type;' ||
                                     'TYPE segment_list_type IS TABLE OF VARCHAR2(25);' ||
                                      v_collection_list_declare_stmt ||
                                     'v_rows_processed NUMBER :=0;' ||
                                     -- Bugfix 5946597
                                     -- 'v_end_rowid ROWID := ''' || v_end_rowid || ''';' ||
                                     'v_end_rowid ROWID := :1;' ||
                                     'v_retcode NUMBER;' ||
                                     'BEGIN ' ||
                                     'OPEN v_ccid_cur(' ||
                                                       p_coa_id || ',' ||
                                                       p_max_ccid_processed || '+ 1 ,' ||
                                                       p_max_ccid_to_be_mapped || ',' ||
                                                       -- Bugfix 5946597
                                                       --p_gvsc_id || ',''' ||
                                                       --v_start_rowid || ''',''' ||
                                                       --v_end_rowid || ''');' ||
                                                       p_gvsc_id || ',' ||
                                                       ':2,' ||
                                                       ':3);' ||
                                     'LOOP ' ||
                                     'FETCH v_ccid_cur ' ||
                                     'BULK COLLECT INTO v_ccid_list' ||
                                     v_collection_list_select_stmt ||
                                     ' LIMIT ' || pv_batch_size || ';' ||
                                     'IF (v_ccid_list.FIRST IS NOT NULL AND v_ccid_list.LAST IS NOT NULL) THEN ' ||
                                     'FORALL i IN v_ccid_list.FIRST..v_ccid_list.LAST ' ||
                                      v_ccid_update_stmt ||
                                     'v_rows_processed := v_rows_processed + SQL%ROWCOUNT;' ||
									 ' fem_intg_extension_pkg.update_mapping_table(v_ccid_list); ' ||
                                     'END IF;' ||
                                     'EXIT WHEN v_ccid_cur%NOTFOUND;' ||
                                     'END LOOP;' ||
                                     'CLOSE v_ccid_cur;' ||
                                     'ad_parallel_updates_pkg.processed_rowid_range( v_rows_processed, v_end_rowid);' ||
                                     'COMMIT;' ||
                                     'EXCEPTION WHEN OTHERS THEN ' ||
                                     'BEGIN ' ||
                                     'ROLLBACK;' ||
                                     'IF (v_ccid_cur%ISOPEN) THEN ' ||
                                     'CLOSE v_ccid_cur;' ||
                                     'END IF;' ||
                                     'ad_parallel_updates_pkg.processed_rowid_range( v_rows_processed, v_end_rowid);' ||
                                     'FEM_ENGINES_PKG.User_Message(p_app_name => ''FEM'',' ||
                                     'p_msg_text => substr(SQLERRM, 1, 4000));' ||
                                     'v_retcode := AD_CONC_UTILS_PKG.CONC_FAIL;' ||
                                     'RAISE;' ||
                                     'END;' ||
                                     'END;';
          -- Bugfix 5946597
          --IF (v_mapping_update_block IS NOT NULL) THEN
            v_start_pos := 1;
            LOOP
               FEM_ENGINES_PKG.Tech_Message(
                         p_severity => pc_log_level_statement,
                         p_module   => v_module_name || '.mapping_update_block',
                         p_msg_text => substr(v_mapping_update_block, v_start_pos, 4000)
                       );
               v_start_pos := v_start_pos + 4000;
               EXIT WHEN v_start_pos > length(v_mapping_update_block);
            END LOOP;
          --END IF;

      WHILE (v_any_rows_to_process = TRUE)  LOOP
          -- Bugfix 5946597
          --FEM_ENGINES_PKG.User_Message(
          --   p_app_name => 'FEM',
          --   p_msg_text => 'Processing rowid from ' || v_start_rowid || ' to '|| v_end_rowid || pv_crlf
          -- );

          FEM_ENGINES_PKG.Tech_Message(
             p_severity => pc_log_level_statement,
             p_module   => v_module_name || '.update_processing',
             p_msg_text => 'Processing rowid from ' || v_start_rowid || ' to '|| v_end_rowid
           );

          EXECUTE IMMEDIATE  v_mapping_update_block USING v_end_rowid, v_start_rowid, v_end_rowid;
          COMMIT;
          -- end FEM update logic
          --End bugfix 5864123

	  --end 8780516
          ad_parallel_updates_pkg.get_rowid_range( v_start_rowid,
                                                   v_end_rowid,
                                                   v_any_rows_to_process,
                                                   p_batch_size,
                                                   FALSE);

      END LOOP;

      X_retcode := AD_CONC_UTILS_PKG.CONC_SUCCESS;

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_procedure,
        p_module   => v_module_name || '.end_worker',
        p_msg_text => '<< end of mapping table update worker >>'
      );

      FEM_ENGINES_PKG.User_Message(
        p_app_name => 'FEM',
        p_msg_text => '<< end of mapping table update worker >>'
      );

      EXCEPTION
              WHEN OTHERS THEN
                  FEM_ENGINES_PKG.Tech_Message(
                     p_severity => pc_log_level_exception,
                     p_module   => v_module_name || '.err_worker',
                     p_msg_text => 'Worker Error '||SQLERRM
                   );

                 FEM_ENGINES_PKG.User_Message(
                   p_app_name => 'FEM',
                   p_msg_text => 'Worker Error '||SQLERRM
                 );

                 X_retcode := AD_CONC_UTILS_PKG.CONC_FAIL;
                 raise;

  END; -- end worker  API

END fem_intg_new_dim_member_pkg;

/
