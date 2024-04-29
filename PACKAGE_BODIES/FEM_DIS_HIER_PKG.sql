--------------------------------------------------------
--  DDL for Package Body FEM_DIS_HIER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_DIS_HIER_PKG" AS
/* $Header: fem_dis_hier.plb 120.1 2007/07/18 22:13:14 srawat ship $ */
  --
  -- Package variables
  --
  pv_req_id   NUMBER;
  pv_user_id  NUMBER;
  pv_login_id NUMBER;

  --
  -- Constants
  --
  pc_delimiter        CONSTANT VARCHAR2(10) := '/';
  pc_delimiter_length CONSTANT NUMBER := LENGTH(pc_delimiter);

  pc_dummy_member_id             CONSTANT NUMBER := -1;

  -- Orphan nodes also use the same display order num
  pc_dummy_display_order_num CONSTANT NUMBER := 10000;

  pc_log_level_statement    CONSTANT NUMBER := FND_LOG.level_statement;
  pc_log_level_procedure    CONSTANT NUMBER := FND_LOG.level_procedure;
  pc_log_level_event        CONSTANT NUMBER := FND_LOG.level_event;
  pc_log_level_exception    CONSTANT NUMBER := FND_LOG.level_exception;
  pc_log_level_error        CONSTANT NUMBER := FND_LOG.level_error;
  pc_log_level_unexpected   CONSTANT NUMBER := FND_LOG.level_unexpected;


  -- ======================================================================
  -- Procedure
  --   Print_DSQL_Insert_B
  -- Purpose
  --   Print Dynamic SQL for Insert B table
  -- History
  --   06-22-05  Shintaro Okuda  Created
  -- Arguments
  --   p_module                      Module Name
  --   p_dis_hierarchy_table_name_b  Table Name
  --   p_insert_b1                   Insert Statement Fragment 1
  --   p_insert_b2                   Insert Statement Fragment 2
  --   p_insert_b3                   Insert Statement Fragment 3
  --   p_insert_b4                   Insert Statement Fragment 4
  --   p_insert_b5                   Insert Statement Fragment 5
  --   p_insert_b6                   Insert Statement Fragment 6
  --   p_insert_b7                   Insert Statement Fragment 7
  --   p_insert_b8                   Insert Statement Fragment 8
  --   p_insert_b9                   Insert Statement Fragment 9
  --   p_insert_b10                  Insert Statement Fragment 10
  --   p_insert_b11                  Insert Statement Fragment 11
  --   p_insert_b12                  Insert Statement Fragment 12
  --   p_insert_b13                  Insert Statement Fragment 13
  --   p_insert_b14                  Insert Statement Fragment 14
  --   p_using1                      Using Statement Fragment 1
  --   p_using2                      Using Statement Fragment 2
  --   p_using3                      Using Statement Fragment 3
  --   p_using4                      Using Statement Fragment 4
  --   p_using5                      Using Statement Fragment 5
  --   p_using6                      Using Statement Fragment 6
  --   p_using7                      Using Statement Fragment 7
  --   p_using8                      Using Statement Fragment 8
  --   p_using9                      Using Statement Fragment 9
  --   p_using10                     Using Statement Fragment 10
  --   p_using11                     Using Statement Fragment 11
  -- ======================================================================
  PROCEDURE Print_DSQL_Insert_B(
    p_module                     IN VARCHAR2,
    p_dis_hierarchy_table_name_b IN VARCHAR2,
    p_insert_b1                  IN VARCHAR2,
    p_insert_b2                  IN VARCHAR2,
    p_insert_b3                  IN VARCHAR2,
    p_insert_b4                  IN VARCHAR2,
    p_insert_b5                  IN VARCHAR2,
    p_insert_b6                  IN VARCHAR2,
    p_insert_b7                  IN VARCHAR2,
    p_insert_b8                  IN VARCHAR2,
    p_insert_b9                  IN VARCHAR2,
    p_insert_b10                 IN VARCHAR2,
    p_insert_b11                 IN VARCHAR2,
    p_insert_b12                 IN VARCHAR2,
    p_insert_b13                 IN VARCHAR2,
    p_insert_b14                 IN VARCHAR2,
    p_using1                     IN VARCHAR2,
    p_using2                     IN VARCHAR2,
    p_using3                     IN VARCHAR2,
    p_using4                     IN VARCHAR2,
    p_using5                     IN VARCHAR2,
    p_using6                     IN VARCHAR2,
    p_using7                     IN VARCHAR2,
    p_using8                     IN VARCHAR2,
    p_using9                     IN VARCHAR2,
    p_using10                    IN VARCHAR2,
    p_using11                    IN VARCHAR2
  ) IS
  BEGIN

    --
    -- Print Dynamic SQL Elements for INSERT INTO _B table to Debug Log
    --
    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_statement,
      p_module   => p_module || '.dsql_insert_into_' || p_dis_hierarchy_table_name_b,
      p_msg_text => p_insert_b1
    );

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_statement,
      p_module   => p_module || '.dsql_insert_into_' || p_dis_hierarchy_table_name_b,
      p_msg_text => p_insert_b2
    );

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_statement,
      p_module   => p_module || '.dsql_insert_into_' || p_dis_hierarchy_table_name_b,
      p_msg_text => p_insert_b3
    );

    IF p_insert_b4 IS NOT NULL THEN
      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_statement,
        p_module   => p_module || '.dsql_insert_into_' || p_dis_hierarchy_table_name_b,
        p_msg_text => p_insert_b4
      );
    END IF;

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_statement,
      p_module   => p_module || '.dsql_insert_into_' || p_dis_hierarchy_table_name_b,
      p_msg_text => p_insert_b5
    );

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_statement,
      p_module   => p_module || '.dsql_insert_into_' || p_dis_hierarchy_table_name_b,
      p_msg_text => p_insert_b6
    );

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_statement,
      p_module   => p_module || '.dsql_insert_into_' || p_dis_hierarchy_table_name_b,
      p_msg_text => p_insert_b7
    );

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_statement,
      p_module   => p_module || '.dsql_insert_into_' || p_dis_hierarchy_table_name_b,
      p_msg_text => p_insert_b8
    );

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_statement,
      p_module   => p_module || '.dsql_insert_into_' || p_dis_hierarchy_table_name_b,
      p_msg_text => p_insert_b9
    );

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_statement,
      p_module   => p_module || '.dsql_insert_into_' || p_dis_hierarchy_table_name_b,
      p_msg_text => p_insert_b10
    );

    IF p_insert_b11 IS NOT NULL THEN
      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_statement,
        p_module   => p_module || '.dsql_insert_into_' || p_dis_hierarchy_table_name_b,
        p_msg_text => p_insert_b11
      );
    END IF;

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_statement,
      p_module   => p_module || '.dsql_insert_into_' || p_dis_hierarchy_table_name_b,
      p_msg_text => p_insert_b12
    );

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_statement,
      p_module   => p_module || '.dsql_insert_into_' || p_dis_hierarchy_table_name_b,
      p_msg_text => p_insert_b13
    );

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_statement,
      p_module   => p_module || '.dsql_insert_into_' || p_dis_hierarchy_table_name_b,
      p_msg_text => p_insert_b14
    );
    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_statement,
      p_module   => p_module || '.dsql_insert_into_' || p_dis_hierarchy_table_name_b,
      p_msg_text => 'USING '  ||
                    p_using1  || ', ' ||
                    p_using2  || ', ' ||
                    p_using3  || ', ''' ||
                    p_using4  || ''', ' ||
                    p_using5  || ', ' ||
                    p_using6  || ', ' ||
                    p_using7  || ', ' ||
                    p_using8  || ', ' ||
                    p_using9  || ', ' ||
                    p_using10 || ', ' ||
                    p_using11 || '
                    '
    );

  END Print_DSQL_Insert_B;


  -- ======================================================================
  -- Procedure
  --   Print_DSQL_Insert_TL
  -- Purpose
  --   Print Dynamic SQL for Insert into TL table
  -- History
  --   06-22-05  Shintaro Okuda  Created
  -- Arguments
  --   p_module                       Module Name
  --   p_dis_hierarchy_table_name_tl  Table Name
  --   p_insert_tl1                   Insert Statement Fragment 1
  --   p_insert_tl2                   Insert Statement Fragment 2
  --   p_insert_tl3                   Insert Statement Fragment 3
  --   p_insert_tl4                   Insert Statement Fragment 4
  --   p_insert_tl5                   Insert Statement Fragment 5
  --   p_using1                       Using Statement Fragment 1
  --   p_using2                       Using Statement Fragment 2
  --   p_using3                       Using Statement Fragment 3
  -- ======================================================================
  PROCEDURE Print_DSQL_Insert_TL(
    p_module                      IN VARCHAR2,
    p_dis_hierarchy_table_name_tl IN VARCHAR2,
    p_insert_tl1                  IN VARCHAR2,
    p_insert_tl2                  IN VARCHAR2,
    p_insert_tl3                  IN VARCHAR2,
    p_insert_tl4                  IN VARCHAR2,
    p_insert_tl5                  IN VARCHAR2,
    p_using1                      IN VARCHAR2,
    p_using2                      IN VARCHAR2,
    p_using3                      IN VARCHAR2
  ) IS
  BEGIN

    --
    -- Print Dynamic SQL Elements for INSERT INTO _TL table to Debug Log
    --
    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_statement,
      p_module   => p_module || '.dsql_insert_into_' || p_dis_hierarchy_table_name_tl,
      p_msg_text => p_insert_tl1
    );

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_statement,
      p_module   => p_module || '.dsql_insert_into_' || p_dis_hierarchy_table_name_tl,
      p_msg_text => p_insert_tl2
    );

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_statement,
      p_module   => p_module || '.dsql_insert_into_' || p_dis_hierarchy_table_name_tl,
      p_msg_text => p_insert_tl3
    );

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_statement,
      p_module   => p_module || '.dsql_insert_into_' || p_dis_hierarchy_table_name_tl,
      p_msg_text => p_insert_tl4
    );

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_statement,
      p_module   => p_module || '.dsql_insert_into_' || p_dis_hierarchy_table_name_tl,
      p_msg_text => p_insert_tl5
    );

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_statement,
      p_module   => p_module || '.dsql_insert_into_' || p_dis_hierarchy_table_name_tl,
      p_msg_text => 'USING ' ||
                    p_using1 || ', ' ||
                    p_using2 || ', ' ||
                    p_using3 || '
                    '
    );

  END Print_DSQL_Insert_TL;


  -- ======================================================================
  -- Function
  --   Transformation
  -- Purpose
  --   Transforms an individual dimension's hierarchy
  -- History
  --   06-22-05  Shintaro Okuda  Created
  -- Arguments
  --   p_dimension_varchar_label Dimension Varchar Label
  -- ======================================================================
  FUNCTION Transformation(
    p_dimension_varchar_label IN VARCHAR2
  ) RETURN VARCHAR2 IS

    v_dimension_id             FEM_DIMENSIONS_VL.DIMENSION_ID%TYPE;
    v_dimension_name           FEM_DIMENSIONS_VL.DIMENSION_NAME%TYPE;
    v_member_b_table_name      FEM_XDIM_DIMENSIONS.MEMBER_B_TABLE_NAME%TYPE;
    v_member_tl_table_name     FEM_XDIM_DIMENSIONS.MEMBER_TL_TABLE_NAME%TYPE;
    v_member_vl_object_name    FEM_XDIM_DIMENSIONS.MEMBER_VL_OBJECT_NAME%TYPE;
    v_member_col               FEM_XDIM_DIMENSIONS.MEMBER_COL%TYPE;
    v_member_display_code_col  FEM_XDIM_DIMENSIONS.MEMBER_DISPLAY_CODE_COL%TYPE;
    v_member_name_col          FEM_XDIM_DIMENSIONS.MEMBER_NAME_COL%TYPE;
    v_member_description_col   FEM_XDIM_DIMENSIONS.MEMBER_DESCRIPTION_COL%TYPE;
    v_hierarchy_table_name     FEM_XDIM_DIMENSIONS.HIERARCHY_TABLE_NAME%TYPE;
    v_attribute_table_name     FEM_XDIM_DIMENSIONS.ATTRIBUTE_TABLE_NAME%TYPE;
    v_composite_dimension_flag FEM_XDIM_DIMENSIONS.COMPOSITE_DIMENSION_FLAG%TYPE;
    v_value_set_required_flag  FEM_XDIM_DIMENSIONS.VALUE_SET_REQUIRED_FLAG%TYPE;
    v_dummy_parent_name        FEM_LOOKUPS.MEANING%TYPE;

    v_dis_hierarchy_table_name    VARCHAR2(30);
    v_dis_hierarchy_table_name_b  VARCHAR2(30);
    v_dis_hierarchy_table_name_tl VARCHAR2(30);

    v_attribute_from_orphan  VARCHAR2(200);
    v_attribute_where_orphan VARCHAR2(1000);

    v_from_composite_only  VARCHAR2(400);
    v_where_composite_only VARCHAR2(400);

    v_vs_column_parent_union1  VARCHAR2(100);
    v_vs_column_child_union1   VARCHAR2(100);
    v_vs_column_parent_union2  VARCHAR2(100);
    v_vs_column_child_union2   VARCHAR2(100);
    v_vs_column_parent_union3  VARCHAR2(100);
    v_vs_column_child_union3   VARCHAR2(100);
    v_vs_column_orphan         VARCHAR2(100);
    v_vs_column_subquery_q     VARCHAR2(100);
    v_vs_column_subquery_r     VARCHAR2(100);
    v_vs_column_list           VARCHAR2(100);
    v_vs_column_member_b_table VARCHAR2(100);

    v_vs_where_attribute         VARCHAR2(200);
    v_vs_where_exclude_nonleaf   VARCHAR2(200);
    v_vs_where_connect_by        VARCHAR2(200);
    v_vs_where_display_code      VARCHAR2(200);
    v_vs_where_display_order_num VARCHAR2(200);
    v_vs_where_root              VARCHAR2(200);
    v_vs_where_root_o            VARCHAR2(200);
    v_vs_where_hier              VARCHAR2(400);
    v_vs_where_member            VARCHAR2(200);
    v_vs_where_tl                VARCHAR2(200);

    v_insert_b_column_list     VARCHAR2(4000);
    v_insert_b_display_code1   VARCHAR2(4000);
    v_insert_b_display_code2   VARCHAR2(4000);
    v_insert_b_with_o          VARCHAR2(4000);
    v_insert_b_with_p1         VARCHAR2(4000);
    v_insert_b_with_p2         VARCHAR2(4000);
    v_insert_b_with_p3         VARCHAR2(4000);
    v_insert_b_subquery_r1     VARCHAR2(4000);
    v_insert_b_subquery_r2     VARCHAR2(4000);
    v_insert_b_subquery_h11    VARCHAR2(4000);
    v_insert_b_subquery_h11_o  VARCHAR2(4000);
    v_insert_b_subquery_h12    VARCHAR2(4000);
    v_insert_b_exclude_nonleaf VARCHAR2(4000);
    v_insert_b_exclude_nonleaf_o VARCHAR2(4000);
    v_insert_b_subquery_q1     VARCHAR2(4000);
    v_insert_b_subquery_q2     VARCHAR2(4000);

    v_insert_b_column_list_l     NUMBER;
    v_insert_b_display_code1_l   NUMBER;
    v_insert_b_display_code2_l   NUMBER;
    v_insert_b_with_o_l          NUMBER;
    v_insert_b_with_p1_l         NUMBER;
    v_insert_b_with_p2_l         NUMBER;
    v_insert_b_with_p3_l         NUMBER;
    v_insert_b_subquery_r1_l     NUMBER;
    v_insert_b_subquery_r2_l     NUMBER;
    v_insert_b_subquery_h11_l    NUMBER;
    v_insert_b_subquery_h11_o_l  NUMBER;
    v_insert_b_subquery_h12_l    NUMBER;
    v_insert_b_exclude_nonleaf_l NUMBER;
    v_insert_b_exclude_nonleaf_o_l NUMBER;
    v_insert_b_subquery_q1_l     NUMBER;
    v_insert_b_subquery_q2_l     NUMBER;

    v_insert_tl_column_list  VARCHAR2(4000);
    v_insert_tl_name1        VARCHAR2(4000);
    v_insert_tl_name2        VARCHAR2(4000);
    v_insert_tl_description1 VARCHAR2(4000);
    v_insert_tl_description2 VARCHAR2(4000);

    v_insert_tl_column_list_l  NUMBER;
    v_insert_tl_name1_l        NUMBER;
    v_insert_tl_name2_l        NUMBER;
    v_insert_tl_description1_l NUMBER;
    v_insert_tl_description2_l NUMBER;

    v_deleted_b   NUMBER;
    v_deleted_tl  NUMBER;
    v_inserted_b1 NUMBER;
    v_inserted_b2 NUMBER;
    v_inserted_tl NUMBER;

    TYPE Varchar2Tab IS TABLE OF VARCHAR2(150);
    TYPE NumberTab IS TABLE OF NUMBER;

    v_object_name_array     Varchar2Tab;
    v_object_id_array       NumberTab;
    v_multi_vs_num          NUMBER;

    v_module VARCHAR2(100) := 'fem.plsql.fem_dis_hier_pkg.transformation';
    v_func_name VARCHAR2(100) := 'FEM_DIS_HIER_PKG.Transformation';

  BEGIN

    v_module := v_module || '.' || LOWER(p_dimension_varchar_label);
    v_func_name := v_func_name || '.' ||  p_dimension_varchar_label;

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_procedure,
      p_module   => v_module || '.begin',
      p_app_name => 'FEM',
      p_msg_name => 'FEM_GL_POST_201',
      p_token1   => 'FUNC_NAME',
      p_value1   => v_func_name,
      p_token2   => 'TIME',
      p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
    );

    FEM_ENGINES_PKG.User_Message(
      p_app_name => 'FEM',
      p_msg_name => 'FEM_GL_POST_201',
      p_token1   => 'FUNC_NAME',
      p_value1   => v_func_name,
      p_token2   => 'TIME',
      p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
    );

    /************************************************************************
      Get dimension properties
    *************************************************************************/
    SELECT
      V.DIMENSION_ID,
      V.DIMENSION_NAME,
      X.MEMBER_B_TABLE_NAME,
      X.MEMBER_TL_TABLE_NAME,
      X.MEMBER_VL_OBJECT_NAME,
      X.MEMBER_COL,
      X.MEMBER_DISPLAY_CODE_COL,
      X.MEMBER_NAME_COL,
      X.MEMBER_DESCRIPTION_COL,
      X.HIERARCHY_TABLE_NAME,
      X.ATTRIBUTE_TABLE_NAME,
      X.COMPOSITE_DIMENSION_FLAG,
      X.VALUE_SET_REQUIRED_FLAG
    INTO
      v_dimension_id,
      v_dimension_name,
      v_member_b_table_name,
      v_member_tl_table_name,
      v_member_vl_object_name,
      v_member_col,
      v_member_display_code_col,
      v_member_name_col,
      v_member_description_col,
      v_hierarchy_table_name,
      v_attribute_table_name,
      v_composite_dimension_flag,
      v_value_set_required_flag
    FROM
      FEM_DIMENSIONS_VL V,
      FEM_XDIM_DIMENSIONS X
    WHERE
      X.DIMENSION_ID = V.DIMENSION_ID AND
      V.DIMENSION_VARCHAR_LABEL = p_dimension_varchar_label;

    /************************************************************************
      Get translated name for dummay parent node
    *************************************************************************/
    BEGIN
      SELECT MEANING
      INTO v_dummy_parent_name
      FROM FEM_LOOKUPS
      WHERE LOOKUP_TYPE = 'FEM_DIS_DUMMY_PARENT'
      AND   LOOKUP_CODE = 'DUMMY_PARENT_NAME';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_dummy_parent_name := 'DUMMY';
      WHEN OTHERS THEN
        RAISE;
    END;

    /************************************************************************
      Constructlements of the SQL statement based on dimension's
      properties in FEM_XDIM_DIMENSIONS (value_set_required_flag,
      attribute_table_name, hierarchy_table_name, composite_dimension_flag,
      and etc)
    *************************************************************************/
    --
    -- Based on hierarchy_table_name
    --
    --
    v_dis_hierarchy_table_name := replace(
                                    v_hierarchy_table_name,
                                    'FEM_',
                                    'FEM_DIS_'
                                  );

    IF p_dimension_varchar_label = 'CAL_PERIOD' THEN
      v_dis_hierarchy_table_name := 'FEM_DIS_CAL_PER_HIER';
    ELSIF p_dimension_varchar_label = 'COST_CENTER' THEN
      v_dis_hierarchy_table_name := 'FEM_DIS_CST_CNTRS_HIER';
    ELSIF p_dimension_varchar_label = 'PRODUCT_TYPE' THEN
      v_dis_hierarchy_table_name := 'FEM_DIS_PRD_TYPES_HIER';
    ELSIF SUBSTR(p_dimension_varchar_label, 1, 8) = 'USER_DIM' THEN
      v_dis_hierarchy_table_name := 'FEM_DIS_USR_DIM' ||
                                    SUBSTR(p_dimension_varchar_label, 9) ||
                                    '_HIER';
    END IF;

    IF v_member_tl_table_name IS NOT NULL THEN
      v_dis_hierarchy_table_name_b  := v_dis_hierarchy_table_name || '_B';
      v_dis_hierarchy_table_name_tl := v_dis_hierarchy_table_name || '_TL';
    ELSE
      v_dis_hierarchy_table_name_b  := v_dis_hierarchy_table_name || '_B';
      v_dis_hierarchy_table_name_tl := NULL;
    END IF;

    --
    -- Based on value_set_required_flag
    --
    IF v_value_set_required_flag = 'Y' THEN

      v_vs_column_parent_union1 := '
          H.PARENT_VALUE_SET_ID,';

      v_vs_column_child_union1 := '
          H.CHILD_VALUE_SET_ID,';

      v_vs_column_parent_union2 := '
            O.CHILD_VALUE_SET_ID PARENT_VALUE_SET_ID,';

      v_vs_column_child_union2 := '
            O.CHILD_VALUE_SET_ID,';

      v_vs_column_parent_union3 := '
            O.CHILD_VALUE_SET_ID PARENT_VALUE_SET_ID,';

      v_vs_column_child_union3 := '
            O.VALUE_SET_ID CHILD_VALUE_SET_ID,';

      v_vs_column_orphan := '
              H.CHILD_VALUE_SET_ID,
              M.VALUE_SET_ID VALUE_SET_ID,';

      v_where_composite_only := NULL;

      v_from_composite_only := NULL;

      v_vs_column_subquery_r := '
        H1.CHILD_VALUE_SET_ID VALUE_SET_ID,';

      v_vs_column_list := '
  VALUE_SET_ID,';

      v_vs_column_member_b_table := '
    B.VALUE_SET_ID,';

      v_vs_column_subquery_q := '
    P.VALUE_SET_ID,';

      v_vs_where_attribute := '
              A.VALUE_SET_ID = M.VALUE_SET_ID AND';

      v_vs_where_exclude_nonleaf := '
          H1.CHILD_VALUE_SET_ID = H3.PARENT_VALUE_SET_ID AND';

      v_vs_where_connect_by := '
      H1.PARENT_VALUE_SET_ID = PRIOR H1.CHILD_VALUE_SET_ID AND';

      v_vs_where_display_code := '
    AND   B.VALUE_SET_ID = Q.VALUE_SET_ID';

      v_vs_where_display_order_num := '
        AND   H4.PARENT_VALUE_SET_ID = R.VALUE_SET_ID
        AND   H4.CHILD_VALUE_SET_ID = R.VALUE_SET_ID';

      v_vs_where_root := 'H.PARENT_VALUE_SET_ID = H.CHILD_VALUE_SET_ID AND ';

      v_vs_where_root_o := 'H1.PARENT_VALUE_SET_ID = H1.CHILD_VALUE_SET_ID AND ';

      --
      -- This is used for WITH query O to filter out hierarchy versions
      -- which do not have a value set used by a orphan node.
      --
      v_vs_where_hier := '
              EXISTS (
                SELECT 1
                FROM FEM_HIER_VALUE_SETS VS
                WHERE
                  VS.HIERARCHY_OBJ_ID = HIER.HIERARCHY_OBJ_ID AND
                  VS.VALUE_SET_ID = M.VALUE_SET_ID
              ) AND';

      v_vs_where_member := '
                  H2.CHILD_VALUE_SET_ID = M.VALUE_SET_ID AND';

      v_vs_where_tl := '
    AND   TL.VALUE_SET_ID = B.VALUE_SET_ID';


    ELSE -- IF v_value_set_required_flag = 'Y' THEN

      v_vs_column_orphan := NULL;
      v_vs_where_attribute := NULL;
      v_vs_where_exclude_nonleaf := NULL;
      v_vs_where_connect_by := NULL;
      v_vs_where_member := NULL;

      --
      -- Based on composite_dimension_flag (to be supported in later release)
      --
      IF v_composite_dimension_flag = 'Y' THEN

        v_vs_column_parent_union1 := '
          M.LOCAL_VS_COMBO_ID,';

        v_vs_column_child_union1 := '
          M.LOCAL_VS_COMBO_ID,';

        v_vs_column_parent_union2 := '
            M.LOCAL_VS_COMBO_ID,';

        v_vs_column_child_union2 := '
            M.LOCAL_VS_COMBO_ID,';

        v_vs_column_parent_union3 := '
            M.LOCAL_VS_COMBO_ID,';

        v_vs_column_child_union3 := '
            M.LOCAL_VS_COMBO_ID,';

        v_where_composite_only := 'AND
          M.' || v_member_col || ' = H.CHILD_ID';

        v_from_composite_only := ',
         ' || v_member_vl_object_name || ' M';

        v_vs_column_subquery_r := '
        H1.LOCAL_VS_COMBO_ID,';

        v_vs_column_list := '
  LOCAL_VS_COMBO_ID,';

        v_vs_column_member_b_table := '
  B.LOCAL_VS_COMBO_ID,';

        v_vs_column_subquery_q := '
    P.LOCAL_VS_COMBO_ID,';

        v_vs_where_display_code := '
    AND   B.LOCAL_VS_COMBO_ID = Q.LOCAL_VS_COMBO_ID';

        v_vs_where_display_order_num := NULL;

      ELSE -- IF v_composite_dimension_flag = 'Y' THEN

        v_vs_column_parent_union1 := NULL;
        v_vs_column_child_union1 := NULL;
        v_vs_column_parent_union2 := NULL;
        v_vs_column_child_union2 := NULL;
        v_vs_column_parent_union3 := NULL;
        v_vs_column_child_union3 := NULL;
        v_where_composite_only := NULL;
        v_from_composite_only := NULL;
        v_vs_column_subquery_r := NULL;
        v_vs_column_list := NULL;
        v_vs_column_member_b_table := NULL;
        v_vs_column_subquery_q := NULL;
        v_vs_where_display_code := NULL;
        v_vs_where_display_order_num := NULL;

      END IF; -- IF v_composite_dimension_flag = 'Y' THEN

      v_vs_where_root := NULL;
      v_vs_where_root_o := NULL;
      v_vs_where_hier := NULL;
      v_vs_where_tl := NULL;

    END IF; -- IF v_value_set_required_flag = 'Y' THEN

    --
    -- Based on attribute_table_name
    --
    IF v_attribute_table_name IS NOT NULL THEN

      v_attribute_from_orphan := '
              FEM_DIM_ATTRIBUTES_B ATTR,
              FEM_DIM_ATTR_VERSIONS_B ATTRV,
             ' || v_attribute_table_name || ' A,';

      v_attribute_where_orphan := ' AND
              ATTR.DIMENSION_ID = :dimension_id AND
              ATTR.ATTRIBUTE_VARCHAR_LABEL = ''RECON_LEAF_NODE_FLAG'' AND
              ATTRV.ATTRIBUTE_ID = ATTR.ATTRIBUTE_ID AND
              ATTRV.DEFAULT_VERSION_FLAG = ''Y'' AND
              A.ATTRIBUTE_ID = ATTR.ATTRIBUTE_ID AND
              A.VERSION_ID = ATTRV.VERSION_ID AND
              A.' || v_member_col || ' = M.' || v_member_col || ' AND ' ||
              v_vs_where_attribute || '
              A.DIM_ATTRIBUTE_VARCHAR_MEMBER = ''Y''';

    ELSE -- IF v_attribute_table_name IS NOT NULL THEN

      v_attribute_from_orphan := NULL;
      v_attribute_where_orphan := NULL;

    END IF; -- IF v_attribute_table_name IS NOT NULL THEN


    /************************************************************************
      Construct Dynamic SQL Elements for INSERT INTO _B table
    *************************************************************************/
    --
    -- Construct Dynamic SQL Elements for INSERT INTO _B table (column list)
    --
    v_insert_b_column_list := '
INSERT INTO ' || v_dis_hierarchy_table_name_b || ' (
  OBJECT_ID,
  OBJECT_DEFINITION_ID,' ||
  v_vs_column_list || '
  LEVEL1_ID,
  LEVEL2_ID,
  LEVEL3_ID,
  LEVEL4_ID,
  LEVEL5_ID,
  LEVEL6_ID,
  LEVEL7_ID,
  LEVEL8_ID,
  LEVEL9_ID,
  LEVEL10_ID,
  LEVEL11_ID,
  LEVEL12_ID,
  LEVEL13_ID,
  LEVEL14_ID,
  LEVEL15_ID,
  LEVEL16_ID,
  LEVEL17_ID,
  LEVEL18_ID,
  LEVEL19_ID,
  LEVEL20_ID,
  LEVEL1_DISPLAY_ORDER_NUM,
  LEVEL2_DISPLAY_ORDER_NUM,
  LEVEL3_DISPLAY_ORDER_NUM,
  LEVEL4_DISPLAY_ORDER_NUM,
  LEVEL5_DISPLAY_ORDER_NUM,
  LEVEL6_DISPLAY_ORDER_NUM,
  LEVEL7_DISPLAY_ORDER_NUM,
  LEVEL8_DISPLAY_ORDER_NUM,
  LEVEL9_DISPLAY_ORDER_NUM,
  LEVEL10_DISPLAY_ORDER_NUM,
  LEVEL11_DISPLAY_ORDER_NUM,
  LEVEL12_DISPLAY_ORDER_NUM,
  LEVEL13_DISPLAY_ORDER_NUM,
  LEVEL14_DISPLAY_ORDER_NUM,
  LEVEL15_DISPLAY_ORDER_NUM,
  LEVEL16_DISPLAY_ORDER_NUM,
  LEVEL17_DISPLAY_ORDER_NUM,
  LEVEL18_DISPLAY_ORDER_NUM,
  LEVEL19_DISPLAY_ORDER_NUM,
  LEVEL20_DISPLAY_ORDER_NUM,
  LEVEL1_DISPLAY_CODE,
  LEVEL2_DISPLAY_CODE,
  LEVEL3_DISPLAY_CODE,
  LEVEL4_DISPLAY_CODE,
  LEVEL5_DISPLAY_CODE,
  LEVEL6_DISPLAY_CODE,
  LEVEL7_DISPLAY_CODE,
  LEVEL8_DISPLAY_CODE,
  LEVEL9_DISPLAY_CODE,
  LEVEL10_DISPLAY_CODE,
  LEVEL11_DISPLAY_CODE,
  LEVEL12_DISPLAY_CODE,
  LEVEL13_DISPLAY_CODE,
  LEVEL14_DISPLAY_CODE,
  LEVEL15_DISPLAY_CODE,
  LEVEL16_DISPLAY_CODE,
  LEVEL17_DISPLAY_CODE,
  LEVEL18_DISPLAY_CODE,
  LEVEL19_DISPLAY_CODE,
  LEVEL20_DISPLAY_CODE,
  CREATION_DATE,
  CREATED_BY,
  LAST_UPDATE_DATE,
  LAST_UPDATED_BY,
  LAST_UPDATE_LOGIN
)
SELECT
  Q.*,';

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_statement,
      p_module   => v_module || '.length_insert_into_' || v_dis_hierarchy_table_name_b,
      p_msg_text => 'v_insert_b_column_list_l='||LENGTH(v_insert_b_column_list)
    );

    --
    -- Construct Dynamic SQL Elements for INSERT INTO _B table (display_code 1)
    --
    v_insert_b_display_code1 := '
  (
    SELECT B.' || v_member_display_code_col || '
    FROM ' || v_member_b_table_name || ' B
    WHERE B.' || v_member_col || ' = Q.LEVEL1_ID ' ||
    v_vs_where_display_code || '
  ),
  DECODE(Q.LEVEL2_ID, ' || pc_dummy_member_id || ', ''' || v_dummy_parent_name || ''',
    (
      SELECT B.' || v_member_display_code_col || '
      FROM ' || v_member_b_table_name || ' B
      WHERE B.' || v_member_col || ' = Q.LEVEL2_ID ' ||
      v_vs_where_display_code || '
    )
  ),
  (
    SELECT B.' || v_member_display_code_col || '
    FROM ' || v_member_b_table_name || ' B
    WHERE B.' || v_member_col || ' = Q.LEVEL3_ID ' ||
    v_vs_where_display_code || '
  ),
  (
    SELECT B.' || v_member_display_code_col || '
    FROM ' || v_member_b_table_name || ' B
    WHERE B.' || v_member_col || ' = Q.LEVEL4_ID ' ||
    v_vs_where_display_code || '
  ),
  (
    SELECT B.' || v_member_display_code_col || '
    FROM ' || v_member_b_table_name || ' B
    WHERE B.' || v_member_col || ' = Q.LEVEL5_ID ' ||
    v_vs_where_display_code || '
  ),
  (
    SELECT B.' || v_member_display_code_col || '
    FROM ' || v_member_b_table_name || ' B
    WHERE B.' || v_member_col || ' = Q.LEVEL6_ID ' ||
    v_vs_where_display_code || '
  ),
  (
    SELECT B.' || v_member_display_code_col || '
    FROM ' || v_member_b_table_name || ' B
    WHERE B.' || v_member_col || ' = Q.LEVEL7_ID ' ||
    v_vs_where_display_code || '
  ),
  (
    SELECT B.' || v_member_display_code_col || '
    FROM ' || v_member_b_table_name || ' B
    WHERE B.' || v_member_col || ' = Q.LEVEL8_ID ' ||
    v_vs_where_display_code || '
  ),
  (
    SELECT B.' || v_member_display_code_col || '
    FROM ' || v_member_b_table_name || ' B
    WHERE B.' || v_member_col || ' = Q.LEVEL9_ID ' ||
    v_vs_where_display_code || '
  ),
  (
    SELECT B.' || v_member_display_code_col || '
    FROM ' || v_member_b_table_name || ' B
    WHERE B.' || v_member_col || ' = Q.LEVEL10_ID ' ||
    v_vs_where_display_code || '
  ),';

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_statement,
      p_module   => v_module || '.length_insert_into_' || v_dis_hierarchy_table_name_b,
      p_msg_text => 'v_insert_b_display_code1_l='||LENGTH(v_insert_b_display_code1)
    );

    --
    -- Construct Dynamic SQL Elements for INSERT INTO _B table (display_code 2)
    --
    v_insert_b_display_code2 := '
  (
    SELECT B.' || v_member_display_code_col || '
    FROM ' || v_member_b_table_name || ' B
    WHERE B.' || v_member_col || ' = Q.LEVEL11_ID ' ||
    v_vs_where_display_code || '
  ),
  (
    SELECT B.' || v_member_display_code_col || '
    FROM ' || v_member_b_table_name || ' B
    WHERE B.' || v_member_col || ' = Q.LEVEL12_ID ' ||
    v_vs_where_display_code || '
  ),
  (
    SELECT B.' || v_member_display_code_col || '
    FROM ' || v_member_b_table_name || ' B
    WHERE B.' || v_member_col || ' = Q.LEVEL13_ID ' ||
    v_vs_where_display_code || '
  ),
  (
    SELECT B.' || v_member_display_code_col || '
    FROM ' || v_member_b_table_name || ' B
    WHERE B.' || v_member_col || ' = Q.LEVEL14_ID ' ||
    v_vs_where_display_code || '
  ),
  (
    SELECT B.' || v_member_display_code_col || '
    FROM ' || v_member_b_table_name || ' B
    WHERE B.' || v_member_col || ' = Q.LEVEL15_ID ' ||
    v_vs_where_display_code || '
  ),
  (
    SELECT B.' || v_member_display_code_col || '
    FROM ' || v_member_b_table_name || ' B
    WHERE B.' || v_member_col || ' = Q.LEVEL16_ID ' ||
    v_vs_where_display_code || '
  ),
  (
    SELECT B.' || v_member_display_code_col || '
    FROM ' || v_member_b_table_name || ' B
    WHERE B.' || v_member_col || ' = Q.LEVEL17_ID ' ||
    v_vs_where_display_code || '
  ),
  (
    SELECT B.' || v_member_display_code_col || '
    FROM ' || v_member_b_table_name || ' B
    WHERE B.' || v_member_col || ' = Q.LEVEL18_ID ' ||
    v_vs_where_display_code || '
  ),
  (
    SELECT B.' || v_member_display_code_col || '
    FROM ' || v_member_b_table_name || ' B
    WHERE B.' || v_member_col || ' = Q.LEVEL19_ID ' ||
    v_vs_where_display_code || '
  ),
  (
    SELECT B.' || v_member_display_code_col || '
    FROM ' || v_member_b_table_name || ' B
    WHERE B.' || v_member_col || ' = Q.LEVEL20_ID ' ||
    v_vs_where_display_code || '
  ),
  SYSDATE CREATION_DATE,
  :pv_user_id CREATED_BY,
  SYSDATE LAST_UPDATE_DATE,
  :pv_user_id LAST_UPDATED_BY,
  :pv_login_id LAST_UPDATE_LOGIN
FROM (
  WITH'; -- Q

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_statement,
      p_module   => v_module || '.length_insert_into_' || v_dis_hierarchy_table_name_b,
      p_msg_text => 'v_insert_b_display_code2_l='||LENGTH(v_insert_b_display_code2)
    );

    --
    -- Construct Dynamic SQL Elements for INSERT INTO _B table (with o)
    --
    -- This WITH query returns orphan nodes - only used for RECONCILIATION type.
    --
    v_insert_b_with_o := '
  O AS (
    SELECT
      H.HIERARCHY_OBJ_DEF_ID,
      ' || pc_dummy_display_order_num || ' DUMMY_DISPLAY_ORDER_NUM,
      ' || pc_dummy_member_id || ' DUMMY_MEMBER_ID,' ||
      v_vs_column_orphan || '
      H.CHILD_ID,
      M.' || v_member_col || ' MEMBER_ID
    FROM
      FEM_HIERARCHIES HIER,
      FEM_OBJECT_DEFINITION_B DEF,
      FEM_OBJECT_CATALOG_B CAT, ' ||
      v_attribute_from_orphan || '
      ' || v_member_b_table_name || ' M,
      ' || v_hierarchy_table_name || ' H ' ||
      v_from_composite_only || '
    WHERE
      HIER.MULTI_VALUE_SET_FLAG = ''N'' AND
      HIER.HIERARCHY_TYPE_CODE = ''RECONCILIATION'' AND
      HIER.DIMENSION_ID = :dimension_id AND
      HIER.PERSONAL_FLAG = ''N'' AND
      CAT.OBJECT_ID = HIER.HIERARCHY_OBJ_ID AND
      DEF.OBJECT_ID = CAT.OBJECT_ID AND
      H.HIERARCHY_OBJ_DEF_ID = DEF.OBJECT_DEFINITION_ID AND ' ||
      v_vs_where_root || '
      H.PARENT_ID = H.CHILD_ID AND
      H.PARENT_DEPTH_NUM = 1 AND ' ||
      v_vs_where_hier || '
      NOT EXISTS (
        SELECT 1
        FROM
          FEM_HIERARCHIES HIER2,
          FEM_OBJECT_DEFINITION_B DEF2,
          FEM_OBJECT_CATALOG_B CAT2,
          ' || v_hierarchy_table_name || ' H2
        WHERE
          HIER2.MULTI_VALUE_SET_FLAG = ''N'' AND
          HIER2.HIERARCHY_TYPE_CODE = ''RECONCILIATION'' AND
          HIER2.DIMENSION_ID = :dimension_id AND
          HIER2.PERSONAL_FLAG = ''N'' AND
          CAT2.OBJECT_ID = HIER2.HIERARCHY_OBJ_ID AND
          DEF2.OBJECT_ID = CAT2.OBJECT_ID AND
          H2.HIERARCHY_OBJ_DEF_ID = DEF2.OBJECT_DEFINITION_ID AND ' ||
          v_vs_where_member || '
          H2.CHILD_ID = M.' || v_member_col || '
      )' ||
      v_attribute_where_orphan ||
      v_where_composite_only || '
    ),';

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_statement,
      p_module   => v_module || '.length_insert_into_' || v_dis_hierarchy_table_name_b,
      p_msg_text => 'v_insert_b_with_o_l='||LENGTH(v_insert_b_with_o)
    );

    --
    -- Construct Dynamic SQL Elements for INSERT INTO _B table (with p1)
    --
    -- In multi-top hierarchy, relying solely on a single LEVEL_ID
    -- is not sufficient as there are multiple child-parent
    -- relationships. Child ID and parent ID are needed to find a
    -- DISPLAY_ORDER_NUM. Furthermore, if both child ID and parent ID
    -- are padded, a tree needs to be traversed to find out the last
    -- non-padded child-parent relationship.
    --
    -- To support these, conditions on both child ID and parent ID
    -- are added to the sub queries for DISPLAY_ORDER_NUM and these
    -- sub queries were moved from outside of the sub query P to
    -- inside of the sub query P, where padding is not performed yet.
    --
    v_insert_b_with_p1 := '
  P AS (
    SELECT
      R.*,
      (
        SELECT H4.DISPLAY_ORDER_NUM
        FROM ' || v_hierarchy_table_name || ' H4
        WHERE H4.HIERARCHY_OBJ_DEF_ID = R.HIERARCHY_OBJ_DEF_ID ' ||
        v_vs_where_display_order_num || '
        AND H4.PARENT_ID = R.L1
        AND H4.CHILD_ID = R.L1
      ) N1,
      (
        SELECT H4.DISPLAY_ORDER_NUM
        FROM ' || v_hierarchy_table_name || ' H4
        WHERE H4.HIERARCHY_OBJ_DEF_ID = R.HIERARCHY_OBJ_DEF_ID ' ||
        v_vs_where_display_order_num || '
        AND H4.PARENT_ID = R.L1
        AND H4.CHILD_ID = R.L2
      ) N2,
      (
        SELECT H4.DISPLAY_ORDER_NUM
        FROM ' || v_hierarchy_table_name || ' H4
        WHERE H4.HIERARCHY_OBJ_DEF_ID = R.HIERARCHY_OBJ_DEF_ID ' ||
        v_vs_where_display_order_num || '
        AND H4.PARENT_ID = R.L2
        AND H4.CHILD_ID = R.L3
      ) N3,
      (
        SELECT H4.DISPLAY_ORDER_NUM
        FROM ' || v_hierarchy_table_name || ' H4
        WHERE H4.HIERARCHY_OBJ_DEF_ID = R.HIERARCHY_OBJ_DEF_ID ' ||
        v_vs_where_display_order_num || '
        AND H4.PARENT_ID = R.L3
        AND H4.CHILD_ID = R.L4
      ) N4,
      (
        SELECT H4.DISPLAY_ORDER_NUM
        FROM ' || v_hierarchy_table_name || ' H4
        WHERE H4.HIERARCHY_OBJ_DEF_ID = R.HIERARCHY_OBJ_DEF_ID ' ||
        v_vs_where_display_order_num || '
        AND H4.PARENT_ID = R.L4
        AND H4.CHILD_ID = R.L5
      ) N5,
      (
        SELECT H4.DISPLAY_ORDER_NUM
        FROM ' || v_hierarchy_table_name || ' H4
        WHERE H4.HIERARCHY_OBJ_DEF_ID = R.HIERARCHY_OBJ_DEF_ID ' ||
        v_vs_where_display_order_num || '
        AND H4.PARENT_ID = R.L5
        AND H4.CHILD_ID = R.L6
      ) N6,';

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_statement,
      p_module   => v_module || '.length_insert_into_' || v_dis_hierarchy_table_name_b,
      p_msg_text => 'v_insert_b_with_p1_l='||LENGTH(v_insert_b_with_p1)
    );


    --
    -- Construct Dynamic SQL Elements for INSERT INTO _B table (with p2)
    --
    v_insert_b_with_p2:= '
      (
        SELECT H4.DISPLAY_ORDER_NUM
        FROM ' || v_hierarchy_table_name || ' H4
        WHERE H4.HIERARCHY_OBJ_DEF_ID = R.HIERARCHY_OBJ_DEF_ID ' ||
        v_vs_where_display_order_num || '
        AND H4.PARENT_ID = R.L6
        AND H4.CHILD_ID = R.L7
      ) N7,
      (
        SELECT H4.DISPLAY_ORDER_NUM
        FROM ' || v_hierarchy_table_name || ' H4
        WHERE H4.HIERARCHY_OBJ_DEF_ID = R.HIERARCHY_OBJ_DEF_ID ' ||
        v_vs_where_display_order_num || '
        AND H4.PARENT_ID = R.L7
        AND H4.CHILD_ID = R.L8
      ) N8,
      (
        SELECT H4.DISPLAY_ORDER_NUM
        FROM ' || v_hierarchy_table_name || ' H4
        WHERE H4.HIERARCHY_OBJ_DEF_ID = R.HIERARCHY_OBJ_DEF_ID ' ||
        v_vs_where_display_order_num || '
        AND H4.PARENT_ID = R.L8
        AND H4.CHILD_ID = R.L9
      ) N9,
      (
        SELECT H4.DISPLAY_ORDER_NUM
        FROM ' || v_hierarchy_table_name || ' H4
        WHERE H4.HIERARCHY_OBJ_DEF_ID = R.HIERARCHY_OBJ_DEF_ID ' ||
        v_vs_where_display_order_num || '
        AND H4.PARENT_ID = R.L9
        AND H4.CHILD_ID = R.L10
      ) N10,
      (
        SELECT H4.DISPLAY_ORDER_NUM
        FROM ' || v_hierarchy_table_name || ' H4
        WHERE H4.HIERARCHY_OBJ_DEF_ID = R.HIERARCHY_OBJ_DEF_ID ' ||
        v_vs_where_display_order_num || '
        AND H4.PARENT_ID = R.L10
        AND H4.CHILD_ID = R.L11
      ) N11,
      (
        SELECT H4.DISPLAY_ORDER_NUM
        FROM ' || v_hierarchy_table_name || ' H4
        WHERE H4.HIERARCHY_OBJ_DEF_ID = R.HIERARCHY_OBJ_DEF_ID ' ||
        v_vs_where_display_order_num || '
        AND H4.PARENT_ID = R.L11
        AND H4.CHILD_ID = R.L12
      ) N12,
      (
        SELECT H4.DISPLAY_ORDER_NUM
        FROM ' || v_hierarchy_table_name || ' H4
        WHERE H4.HIERARCHY_OBJ_DEF_ID = R.HIERARCHY_OBJ_DEF_ID ' ||
        v_vs_where_display_order_num || '
        AND H4.PARENT_ID = R.L12
        AND H4.CHILD_ID = R.L13
      ) N13,';

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_statement,
      p_module   => v_module || '.length_insert_into_' || v_dis_hierarchy_table_name_b,
      p_msg_text => 'v_insert_b_with_p2_l='||LENGTH(v_insert_b_with_p2)
    );


    --
    -- Construct Dynamic SQL Elements for INSERT INTO _B table (with p3)
    --
    v_insert_b_with_p3 := '
      (
        SELECT H4.DISPLAY_ORDER_NUM
        FROM ' || v_hierarchy_table_name || ' H4
        WHERE H4.HIERARCHY_OBJ_DEF_ID = R.HIERARCHY_OBJ_DEF_ID ' ||
        v_vs_where_display_order_num || '
        AND H4.PARENT_ID = R.L13
        AND H4.CHILD_ID = R.L14
      ) N14,
      (
        SELECT H4.DISPLAY_ORDER_NUM
        FROM ' || v_hierarchy_table_name || ' H4
        WHERE H4.HIERARCHY_OBJ_DEF_ID = R.HIERARCHY_OBJ_DEF_ID ' ||
        v_vs_where_display_order_num || '
        AND H4.PARENT_ID = R.L14
        AND H4.CHILD_ID = R.L15
      ) N15,
      (
        SELECT H4.DISPLAY_ORDER_NUM
        FROM ' || v_hierarchy_table_name || ' H4
        WHERE H4.HIERARCHY_OBJ_DEF_ID = R.HIERARCHY_OBJ_DEF_ID ' ||
        v_vs_where_display_order_num || '
        AND H4.PARENT_ID = R.L15
        AND H4.CHILD_ID = R.L16
      ) N16,
      (
        SELECT H4.DISPLAY_ORDER_NUM
        FROM ' || v_hierarchy_table_name || ' H4
        WHERE H4.HIERARCHY_OBJ_DEF_ID = R.HIERARCHY_OBJ_DEF_ID ' ||
        v_vs_where_display_order_num || '
        AND H4.PARENT_ID = R.L16
        AND H4.CHILD_ID = R.L17
      ) N17,
      (
        SELECT H4.DISPLAY_ORDER_NUM
        FROM ' || v_hierarchy_table_name || ' H4
        WHERE H4.HIERARCHY_OBJ_DEF_ID = R.HIERARCHY_OBJ_DEF_ID ' ||
        v_vs_where_display_order_num || '
        AND H4.PARENT_ID = R.L17
        AND H4.CHILD_ID = R.L18
      ) N18,
      (
        SELECT H4.DISPLAY_ORDER_NUM
        FROM ' || v_hierarchy_table_name || ' H4
        WHERE H4.HIERARCHY_OBJ_DEF_ID = R.HIERARCHY_OBJ_DEF_ID ' ||
        v_vs_where_display_order_num || '
        AND H4.PARENT_ID = R.L18
        AND H4.CHILD_ID = R.L19
      ) N19,
      (
        SELECT H4.DISPLAY_ORDER_NUM
        FROM ' || v_hierarchy_table_name || ' H4
        WHERE H4.HIERARCHY_OBJ_DEF_ID = R.HIERARCHY_OBJ_DEF_ID ' ||
        v_vs_where_display_order_num || '
        AND H4.PARENT_ID = R.L19
        AND H4.CHILD_ID = R.L20
      ) N20
    FROM ('; -- R

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_statement,
      p_module   => v_module || '.length_insert_into_' || v_dis_hierarchy_table_name_b,
      p_msg_text => 'v_insert_b_with_p3_l='||LENGTH(v_insert_b_with_p3)
    );

    --
    -- Construct Dynamic SQL Elements for INSERT INTO _B table (subquery r1)
    --
    v_insert_b_subquery_r1 := '
      SELECT
        H1.HIERARCHY_OBJ_DEF_ID, ' ||
        v_vs_column_subquery_r || '
        CAST(
          SUBSTR(
            SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''',
            INSTR(SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''', ''' || pc_delimiter || ''', 1, 1)+' || pc_delimiter_length || ',
            INSTR(SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''', ''' || pc_delimiter || ''', 1, 2)-
            INSTR(SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''', ''' || pc_delimiter || ''', 1, 1)-' || pc_delimiter_length || '
          ) AS NUMBER
        ) L1,
        CAST(
          SUBSTR(
            SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''',
            INSTR(SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''', ''' || pc_delimiter || ''', 1, 2)+' || pc_delimiter_length ||',
            INSTR(SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''', ''' || pc_delimiter || ''', 1, 3)-
            INSTR(SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''', ''' || pc_delimiter || ''', 1, 2)-' || pc_delimiter_length || '
          ) AS NUMBER
        ) L2,
        CAST(
          SUBSTR(
            SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''',
            INSTR(SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''', ''' || pc_delimiter || ''', 1, 3)+' || pc_delimiter_length || ',
            INSTR(SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''', ''' || pc_delimiter || ''', 1, 4)-
            INSTR(SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''', ''' || pc_delimiter || ''', 1, 3)-' || pc_delimiter_length || '
          ) AS NUMBER
        ) L3,
        CAST(
          SUBSTR(
            SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''',
            INSTR(SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''', ''' || pc_delimiter || ''', 1, 4)+' || pc_delimiter_length || ',
            INSTR(SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''', ''' || pc_delimiter || ''', 1, 5)-
            INSTR(SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''', ''' || pc_delimiter || ''', 1, 4)-' || pc_delimiter_length || '
          ) AS NUMBER
        ) L4,
        CAST(
          SUBSTR(
            SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''',
            INSTR(SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''', ''' || pc_delimiter || ''', 1, 5)+' || pc_delimiter_length || ',
            INSTR(SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''', ''' || pc_delimiter || ''', 1, 6)-
            INSTR(SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''', ''' || pc_delimiter || ''', 1, 5)-' || pc_delimiter_length || '
          ) AS NUMBER
        ) L5,
        CAST(
          SUBSTR(
            SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''',
            INSTR(SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''', ''' || pc_delimiter || ''', 1, 6)+' || pc_delimiter_length || ',
            INSTR(SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''', ''' || pc_delimiter || ''', 1, 7)-
            INSTR(SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''', ''' || pc_delimiter || ''', 1, 6)-' || pc_delimiter_length || '
          ) AS NUMBER
        ) L6,
        CAST(
          SUBSTR(
            SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''',
            INSTR(SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''', ''' || pc_delimiter || ''', 1, 7)+' || pc_delimiter_length || ',
            INSTR(SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''', ''' || pc_delimiter || ''', 1, 8)-
            INSTR(SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''', ''' || pc_delimiter || ''', 1, 7)-' || pc_delimiter_length || '
          ) AS NUMBER
        ) L7,
        CAST(
          SUBSTR(
            SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''',
            INSTR(SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''', ''' || pc_delimiter || ''', 1, 8)+' || pc_delimiter_length || ',
            INSTR(SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''', ''' || pc_delimiter || ''', 1, 9)-
            INSTR(SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''', ''' || pc_delimiter || ''', 1, 8)-' || pc_delimiter_length || '
          ) AS NUMBER
        ) L8,
        CAST(
          SUBSTR(
            SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''',
            INSTR(SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''', ''' || pc_delimiter || ''', 1, 9)+' || pc_delimiter_length || ',
            INSTR(SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''', ''' || pc_delimiter || ''', 1, 10)-
            INSTR(SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''', ''' || pc_delimiter || ''', 1, 9)-' || pc_delimiter_length || '
          ) AS NUMBER
        ) L9,
        CAST(
          SUBSTR(
            SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''',
            INSTR(SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''', ''' || pc_delimiter || ''', 1, 10)+' || pc_delimiter_length || ',
            INSTR(SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''', ''' || pc_delimiter || ''', 1, 11)-
            INSTR(SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''', ''' || pc_delimiter || ''', 1, 10)-' || pc_delimiter_length || '
          ) AS NUMBER
        ) L10,';

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_statement,
      p_module   => v_module || '.length_insert_into_' || v_dis_hierarchy_table_name_b,
      p_msg_text => 'v_insert_b_subquery_r1_l='||LENGTH(v_insert_b_subquery_r1)
    );

    --
    -- Construct Dynamic SQL Elements for INSERT INTO _B table (subquery r2)
    --
    v_insert_b_subquery_r2 := '
        CAST(
          SUBSTR(
            SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''',
            INSTR(SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''', ''' || pc_delimiter || ''', 1, 11)+' || pc_delimiter_length || ',
            INSTR(SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''', ''' || pc_delimiter || ''', 1, 12)-
            INSTR(SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''', ''' || pc_delimiter || ''', 1, 11)-' || pc_delimiter_length || '
          ) AS NUMBER
        ) L11,
        CAST(
          SUBSTR(
            SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''',
            INSTR(SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''', ''' || pc_delimiter || ''', 1, 12)+' || pc_delimiter_length || ',
            INSTR(SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''', ''' || pc_delimiter || ''', 1, 13)-
            INSTR(SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''', ''' || pc_delimiter || ''', 1, 12)-' || pc_delimiter_length || '
          ) AS NUMBER
        ) L12,
        CAST(
          SUBSTR(
            SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''',
            INSTR(SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''', ''' || pc_delimiter || ''', 1, 13)+' || pc_delimiter_length || ',
            INSTR(SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''', ''' || pc_delimiter || ''', 1, 14)-
            INSTR(SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''', ''' || pc_delimiter || ''', 1, 13)-' || pc_delimiter_length || '
          ) AS NUMBER
        ) L13,
        CAST(
          SUBSTR(
            SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''',
            INSTR(SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''', ''' || pc_delimiter || ''', 1, 14)+' || pc_delimiter_length || ',
            INSTR(SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''', ''' || pc_delimiter || ''', 1, 15)-
            INSTR(SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''', ''' || pc_delimiter || ''', 1, 14)-' || pc_delimiter_length || '
          ) AS NUMBER
        ) L14,
        CAST(
          SUBSTR(
            SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''',
            INSTR(SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''', ''' || pc_delimiter || ''', 1, 15)+' || pc_delimiter_length || ',
            INSTR(SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''', ''' || pc_delimiter || ''', 1, 16)-
            INSTR(SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''', ''' || pc_delimiter || ''', 1, 15)-' || pc_delimiter_length || '
          ) AS NUMBER
        ) L15,
        CAST(
          SUBSTR(
            SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''',
            INSTR(SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''', ''' || pc_delimiter || ''', 1, 16)+' || pc_delimiter_length || ',
            INSTR(SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''', ''' || pc_delimiter || ''', 1, 17)-
            INSTR(SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''', ''' || pc_delimiter || ''', 1, 16)-' || pc_delimiter_length || '
          ) AS NUMBER
        ) L16,
        CAST(
          SUBSTR(
            SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''',
            INSTR(SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''', ''' || pc_delimiter || ''', 1, 17)+' || pc_delimiter_length || ',
            INSTR(SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''', ''' || pc_delimiter || ''', 1, 18)-
            INSTR(SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''', ''' || pc_delimiter || ''', 1, 17)-' || pc_delimiter_length || '
          ) AS NUMBER
        ) L17,
        CAST(
          SUBSTR(
            SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''',
            INSTR(SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''', ''' || pc_delimiter || ''', 1, 18)+' || pc_delimiter_length || ',
            INSTR(SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''', ''' || pc_delimiter || ''', 1, 19)-
            INSTR(SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''', ''' || pc_delimiter || ''', 1, 18)-' || pc_delimiter_length || '
          ) AS NUMBER
        ) L18,
        CAST(
          SUBSTR(
            SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''',
            INSTR(SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''', ''' || pc_delimiter || ''', 1, 19)+' || pc_delimiter_length || ',
            INSTR(SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''', ''' || pc_delimiter || ''', 1, 20)-
            INSTR(SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''', ''' || pc_delimiter || ''', 1, 19)-' || pc_delimiter_length || '
          ) AS NUMBER
        ) L19,
        CAST(
          SUBSTR(
            SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''',
            INSTR(SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''', ''' || pc_delimiter || ''', 1, 20)+' || pc_delimiter_length || ',
            INSTR(SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''', ''' || pc_delimiter || ''', 1, 21)-
            INSTR(SYS_CONNECT_BY_PATH(H1.CHILD_ID, ''' || pc_delimiter || ''') || ''' || pc_delimiter || ''', ''' || pc_delimiter || ''', 1, 20)-' || pc_delimiter_length || '
          ) AS NUMBER
        ) L20';

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_statement,
      p_module   => v_module || '.length_insert_into_' || v_dis_hierarchy_table_name_b,
      p_msg_text => 'v_insert_b_subquery_r2_l='||LENGTH(v_insert_b_subquery_r2)
    );


    --
    -- Construct Dynamic SQL Elements for INSERT INTO _B table (subquery h11)
    --
    -- (for RECONCILIATION hierarchy type)
    v_insert_b_subquery_h11 := '
     FROM ( -- H1
        SELECT
          H.HIERARCHY_OBJ_DEF_ID,
          H.DISPLAY_ORDER_NUM, ' ||
          v_vs_column_parent_union1 || '
          CASE
            WHEN H.PARENT_ID = H.CHILD_ID AND H.PARENT_DEPTH_NUM = 1 THEN NULL
            ELSE H.PARENT_ID
          END PARENT_ID, ' ||
          v_vs_column_child_union1 || '
          H.CHILD_ID
        FROM
          FEM_HIERARCHIES HIER,
          FEM_OBJECT_DEFINITION_B DEF,
          FEM_OBJECT_CATALOG_B CAT,
          ' || v_hierarchy_table_name || ' H ' ||
          v_from_composite_only || '
        WHERE
          HIER.MULTI_VALUE_SET_FLAG = ''N'' AND
          HIER.HIERARCHY_TYPE_CODE = :hier_type_code AND
          HIER.DIMENSION_ID = :dimension_id AND
          HIER.PERSONAL_FLAG = ''N'' AND
          CAT.OBJECT_ID = HIER.HIERARCHY_OBJ_ID AND
          DEF.OBJECT_ID = CAT.OBJECT_ID AND
          H.HIERARCHY_OBJ_DEF_ID = DEF.OBJECT_DEFINITION_ID AND
          ((' || v_vs_where_root || 'H.PARENT_ID = H.CHILD_ID AND H.PARENT_DEPTH_NUM = 1) OR
          H.CHILD_DEPTH_NUM - H.PARENT_DEPTH_NUM = 1) ' ||
          v_where_composite_only;

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_statement,
      p_module   => v_module || '.length_insert_into_' || v_dis_hierarchy_table_name_b,
      p_msg_text => 'v_insert_b_subquery_h11_l='||LENGTH(v_insert_b_subquery_h11)
    );


    --
    -- Construct Dynamic SQL Elements for INSERT INTO _B table (subquery h11_open)
    --
    -- (for OPEN hierarchy type)
    v_insert_b_subquery_h11_o := '
      FROM
        FEM_HIERARCHIES HIER,
        FEM_OBJECT_DEFINITION_B DEF,
        FEM_OBJECT_CATALOG_B CAT,
        ' || v_hierarchy_table_name || ' H1 ' ||
        v_from_composite_only || '
      WHERE
        HIER.MULTI_VALUE_SET_FLAG = ''N'' AND
        HIER.HIERARCHY_TYPE_CODE = :hier_type_code AND
        HIER.DIMENSION_ID = :dimension_id AND
        HIER.PERSONAL_FLAG = ''N'' AND
        CAT.OBJECT_ID = HIER.HIERARCHY_OBJ_ID AND
        DEF.OBJECT_ID = CAT.OBJECT_ID AND
        H1.HIERARCHY_OBJ_DEF_ID = DEF.OBJECT_DEFINITION_ID AND
        ((' || v_vs_where_root_o || 'H1.PARENT_ID = H1.CHILD_ID AND H1.PARENT_DEPTH_NUM = 1) OR
        H1.CHILD_DEPTH_NUM - H1.PARENT_DEPTH_NUM = 1) ' ||
        v_where_composite_only;

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_statement,
      p_module   => v_module || '.length_insert_into_' || v_dis_hierarchy_table_name_b,
      p_msg_text => 'v_insert_b_subquery_h11_o_l='||LENGTH(v_insert_b_subquery_h11_o)
    );


    --
    -- Construct Dynamic SQL Elements for INSERT INTO _B table (subquery h12)
    --
    -- (for RECONCILIATION hierarchy type which contains orphan node)
    --
    -- For a root node and a dummy parent node reltionship,
    -- use root node's VALUE_SET_ID (PARENT_VALUE_SET_ID = CHILD_VALUE_SET_ID)
    -- for both a root node and a dummy parent node
    --
    -- For a dummy parent node and an orphan node reltionship,
    -- use root node's VALUE_SET_ID (PARENT_VALUE_SET_ID = CHILD_VALUE_SET_ID)
    -- for a dummy parent node and
    -- use orphan node's VALUE_SET_ID for an orphan node
    --
    v_insert_b_subquery_h12 := '
        UNION ALL
        SELECT DISTINCT
          O.HIERARCHY_OBJ_DEF_ID,
          O.DUMMY_DISPLAY_ORDER_NUM, ' ||
          v_vs_column_parent_union2 || '
          O.CHILD_ID PARENT_ID, ' ||
          v_vs_column_child_union2 || '
          O.DUMMY_MEMBER_ID CHILD_ID
        FROM O
        UNION ALL
        SELECT
          O.HIERARCHY_OBJ_DEF_ID,
          O.DUMMY_DISPLAY_ORDER_NUM, ' ||
          v_vs_column_parent_union3 || '
          O.DUMMY_MEMBER_ID PARENT_ID, ' ||
          v_vs_column_child_union3 || '
          O.MEMBER_ID CHILD_ID
        FROM O';

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_statement,
      p_module   => v_module || '.length_insert_into_' || v_dis_hierarchy_table_name_b,
      p_msg_text => 'v_insert_b_subquery_h12_l='||LENGTH(v_insert_b_subquery_h12)
    );

    --
    -- Construct Dynamic SQL Elements for INSERT INTO _B table (exclude nonleaf)
    --
    -- (for RECONCILIATION hierarchy type)
    -- These conditoins are needed to filter out intermediate nodes.
    -- Having paths from a root node to intermediate nodes will generate
    -- duplicate values at intermediate levels, e.g. /1/2/3 and /1/2.
    --
    v_insert_b_exclude_nonleaf := '
      ) H1
      WHERE
        H1.CHILD_ID <> ' || pc_dummy_member_id || ' AND
        NOT EXISTS (
          SELECT 1
          FROM
            FEM_HIERARCHIES HIER3,
            FEM_OBJECT_DEFINITION_B DEF3,
            FEM_OBJECT_CATALOG_B CAT3,
           ' || v_hierarchy_table_name || ' H3
          WHERE
            HIER3.MULTI_VALUE_SET_FLAG = ''N'' AND
            HIER3.HIERARCHY_TYPE_CODE = :hier_type_code AND
            HIER3.DIMENSION_ID = :dimension_id AND
            HIER3.PERSONAL_FLAG = ''N'' AND
            CAT3.OBJECT_ID = HIER3.HIERARCHY_OBJ_ID AND
            DEF3.OBJECT_ID = CAT3.OBJECT_ID AND
            H3.HIERARCHY_OBJ_DEF_ID = DEF3.OBJECT_DEFINITION_ID AND
            H3.CHILD_DEPTH_NUM - H3.PARENT_DEPTH_NUM = 1 AND
            H1.HIERARCHY_OBJ_DEF_ID = H3.HIERARCHY_OBJ_DEF_ID AND ' ||
            v_vs_where_exclude_nonleaf || '
            H1.CHILD_ID =
              CASE
                WHEN H3.PARENT_ID = H3.CHILD_ID AND H3.PARENT_DEPTH_NUM = 1 THEN NULL
                ELSE H3.PARENT_ID
              END
        )
      START WITH
        H1.PARENT_ID IS NULL
      CONNECT BY
        H1.HIERARCHY_OBJ_DEF_ID = PRIOR H1.HIERARCHY_OBJ_DEF_ID AND ' ||
        v_vs_where_connect_by || '
        H1.PARENT_ID = PRIOR H1.CHILD_ID
      ) R
    )'; -- P

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_statement,
      p_module   => v_module || '.length_insert_into_' || v_dis_hierarchy_table_name_b,
      p_msg_text => 'v_insert_b_exclude_nonleaf_l='||LENGTH(v_insert_b_exclude_nonleaf)
    );


    --
    -- Construct Dynamic SQL Elements for INSERT INTO _B table (exclude nonleaf)
    --
    -- (for OPEN hierarchy type)
    -- These conditoins are needed to filter out intermediate nodes.
    -- Having paths from a root node to intermediate nodes will generate
    -- duplicate values at intermediate levels, e.g. /1/2/3 and /1/2.
    --
    v_insert_b_exclude_nonleaf_o := '
        AND H1.CHILD_ID <> ' || pc_dummy_member_id || ' AND
        NOT EXISTS (
          SELECT 1
          FROM
            FEM_HIERARCHIES HIER3,
            FEM_OBJECT_DEFINITION_B DEF3,
            FEM_OBJECT_CATALOG_B CAT3,
           ' || v_hierarchy_table_name || ' H3
          WHERE
            HIER3.MULTI_VALUE_SET_FLAG = ''N'' AND
            HIER3.HIERARCHY_TYPE_CODE = :hier_type_code AND
            HIER3.DIMENSION_ID = :dimension_id AND
            HIER3.PERSONAL_FLAG = ''N'' AND
            CAT3.OBJECT_ID = HIER3.HIERARCHY_OBJ_ID AND
            DEF3.OBJECT_ID = CAT3.OBJECT_ID AND
            H3.HIERARCHY_OBJ_DEF_ID = DEF3.OBJECT_DEFINITION_ID AND
            H3.CHILD_DEPTH_NUM - H3.PARENT_DEPTH_NUM = 1 AND
            H1.HIERARCHY_OBJ_DEF_ID = H3.HIERARCHY_OBJ_DEF_ID AND ' ||
            v_vs_where_exclude_nonleaf || '
            H1.CHILD_ID = H3.PARENT_ID AND
            NOT (H3.PARENT_ID = H3.CHILD_ID AND H3.PARENT_DEPTH_NUM = 1)
        )
      START WITH
        H1.PARENT_ID = H1.CHILD_ID AND H1.PARENT_DEPTH_NUM = 1
      CONNECT BY
        H1.HIERARCHY_OBJ_DEF_ID = PRIOR H1.HIERARCHY_OBJ_DEF_ID AND ' ||
        v_vs_where_connect_by || '
        H1.PARENT_ID = PRIOR H1.CHILD_ID
        AND H1.SINGLE_DEPTH_FLAG = ''Y'' AND H1.CHILD_DEPTH_NUM <> 1
      ) R
    )'; -- P

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_statement,
      p_module   => v_module || '.length_insert_into_' || v_dis_hierarchy_table_name_b,
      p_msg_text => 'v_insert_b_exclude_nonleaf_o_l='||LENGTH(v_insert_b_exclude_nonleaf_o)
    );


    --
    -- Construct Dynamic SQL Elements for INSERT INTO _B table (subquery q1)
    --
    v_insert_b_subquery_q1 := '
  SELECT
    D.OBJECT_ID,
    D.OBJECT_DEFINITION_ID, ' ||
    v_vs_column_subquery_q || '
    P.L1 LEVEL1_ID,
    COALESCE(P.L2,P.L1) LEVEL2_ID,
    COALESCE(P.L3,P.L2,P.L1) LEVEL3_ID,
    COALESCE(P.L4,P.L3,P.L2,P.L1) LEVEL4_ID,
    COALESCE(P.L5,P.L4,P.L3,P.L2,P.L1) LEVEL5_ID,
    COALESCE(P.L6,P.L5,P.L4,P.L3,P.L2,P.L1) LEVEL6_ID,
    COALESCE(P.L7,P.L6,P.L5,P.L4,P.L3,P.L2,P.L1) LEVEL7_ID,
    COALESCE(P.L8,P.L7,P.L6,P.L5,P.L4,P.L3,P.L2,P.L1) LEVEL8_ID,
    COALESCE(P.L9,P.L8,P.L7,P.L6,P.L5,P.L4,P.L3,P.L2,P.L1) LEVEL9_ID,
    COALESCE(P.L10,P.L9,P.L8,P.L7,P.L6,P.L5,P.L4,P.L3,P.L2,P.L1) LEVEL10_ID,
    COALESCE(P.L11,P.L10,P.L9,P.L8,P.L7,P.L6,P.L5,P.L4,P.L3,P.L2,P.L1) LEVEL11_ID,
    COALESCE(P.L12,P.L11,P.L10,P.L9,P.L8,P.L7,P.L6,P.L5,P.L4,P.L3,P.L2,P.L1) LEVEL12_ID,
    COALESCE(P.L13,P.L12,P.L11,P.L10,P.L9,P.L8,P.L7,P.L6,P.L5,P.L4,P.L3,P.L2,P.L1) LEVEL13_ID,
    COALESCE(P.L14,P.L13,P.L12,P.L11,P.L10,P.L9,P.L8,P.L7,P.L6,P.L5,P.L4,P.L3,P.L2,P.L1) LEVEL14_ID,
    COALESCE(P.L15,P.L14,P.L13,P.L12,P.L11,P.L10,P.L9,P.L8,P.L7,P.L6,P.L5,P.L4,P.L3,P.L2,P.L1) LEVEL15_ID,
    COALESCE(P.L16,P.L15,P.L14,P.L13,P.L12,P.L11,P.L10,P.L9,P.L8,P.L7,P.L6,P.L5,P.L4,P.L3,P.L2,P.L1) LEVEL16_ID,
    COALESCE(P.L17,P.L16,P.L15,P.L14,P.L13,P.L12,P.L11,P.L10,P.L9,P.L8,P.L7,P.L6,P.L5,P.L4,P.L3,P.L2,P.L1) LEVEL17_ID,
    COALESCE(P.L18,P.L17,P.L16,P.L15,P.L14,P.L13,P.L12,P.L11,P.L10,P.L9,P.L8,P.L7,P.L6,P.L5,P.L4,P.L3,P.L2,P.L1) LEVEL18_ID,
    COALESCE(P.L19,P.L18,P.L17,P.L16,P.L15,P.L14,P.L13,P.L12,P.L11,P.L10,P.L9,P.L8,P.L7,P.L6,P.L5,P.L4,P.L3,P.L2,P.L1) LEVEL19_ID,
    COALESCE(P.L20,P.L19,P.L18,P.L17,P.L16,P.L15,P.L14,P.L13,P.L12,P.L11,P.L10,P.L9,P.L8,P.L7,P.L6,P.L5,P.L4,P.L3,P.L2,P.L1) LEVEL20_ID,';

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_statement,
      p_module   => v_module || '.length_insert_into_' || v_dis_hierarchy_table_name_b,
      p_msg_text => 'v_insert_b_subquery_q1_l='||LENGTH(v_insert_b_subquery_q1)
    );


    --
    -- Construct Dynamic SQL Elements for INSERT INTO _B table (subquery q2)
    --
    v_insert_b_subquery_q2 := '
    P.N1 LEVEL1_DISPLAY_ORDER_NUM,
    COALESCE(P.N2,P.N1) LEVEL2_DISPLAY_ORDER_NUM,
    COALESCE(P.N3,P.N2,P.N1) LEVEL3_DISPLAY_ORDER_NUM,
    COALESCE(P.N4,P.N3,P.N2,P.N1) LEVEL4_DISPLAY_ORDER_NUM,
    COALESCE(P.N5,P.N4,P.N3,P.N2,P.N1) LEVEL5_DISPLAY_ORDER_NUM,
    COALESCE(P.N6,P.N5,P.N4,P.N3,P.N2,P.N1) LEVEL6_DISPLAY_ORDER_NUM,
    COALESCE(P.N7,P.N6,P.N5,P.N4,P.N3,P.N2,P.N1) LEVEL7_DISPLAY_ORDER_NUM,
    COALESCE(P.N8,P.N7,P.N6,P.N5,P.N4,P.N3,P.N2,P.N1) LEVEL8_DISPLAY_ORDER_NUM,
    COALESCE(P.N9,P.N8,P.N7,P.N6,P.N5,P.N4,P.N3,P.N2,P.N1) LEVEL9_DISPLAY_ORDER_NUM,
    COALESCE(P.N10,P.N9,P.N8,P.N7,P.N6,P.N5,P.N4,P.N3,P.N2,P.N1) LEVEL10_DISPLAY_ORDER_NUM,
    COALESCE(P.N11,P.N10,P.N9,P.N8,P.N7,P.N6,P.N5,P.N4,P.N3,P.N2,P.N1) LEVEL11_DISPLAY_ORDER_NUM,
    COALESCE(P.N12,P.N11,P.N10,P.N9,P.N8,P.N7,P.N6,P.N5,P.N4,P.N3,P.N2,P.N1) LEVEL12_DISPLAY_ORDER_NUM,
    COALESCE(P.N13,P.N12,P.N11,P.N10,P.N9,P.N8,P.N7,P.N6,P.N5,P.N4,P.N3,P.N2,P.N1) LEVEL13_DISPLAY_ORDER_NUM,
    COALESCE(P.N14,P.N13,P.N12,P.N11,P.N10,P.N9,P.N8,P.N7,P.N6,P.N5,P.N4,P.N3,P.N2,P.N1) LEVEL14_DISPLAY_ORDER_NUM,
    COALESCE(P.N15,P.N14,P.N13,P.N12,P.N11,P.N10,P.N9,P.N8,P.N7,P.N6,P.N5,P.N4,P.N3,P.N2,P.N1) LEVEL15_DISPLAY_ORDER_NUM,
    COALESCE(P.N16,P.N15,P.N14,P.N13,P.N12,P.N11,P.N10,P.N9,P.N8,P.N7,P.N6,P.N5,P.N4,P.N3,P.N2,P.N1) LEVEL16_DISPLAY_ORDER_NUM,
    COALESCE(P.N17,P.N16,P.N15,P.N14,P.N13,P.N12,P.N11,P.N10,P.N9,P.N8,P.N7,P.N6,P.N5,P.N4,P.N3,P.N2,P.N1) LEVEL17_DISPLAY_ORDER_NUM,
    COALESCE(P.N18,P.N17,P.N16,P.N15,P.N14,P.N13,P.N12,P.N11,P.N10,P.N9,P.N8,P.N7,P.N6,P.N5,P.N4,P.N3,P.N2,P.N1) LEVEL18_DISPLAY_ORDER_NUM,
    COALESCE(P.N19,P.N18,P.N17,P.N16,P.N15,P.N14,P.N13,P.N12,P.N11,P.N10,P.N9,P.N8,P.N7,P.N6,P.N5,P.N4,P.N3,P.N2,P.N1) LEVEL19_DISPLAY_ORDER_NUM,
    COALESCE(P.N20,P.N19,P.N18,P.N17,P.N16,P.N15,P.N14,P.N13,P.N12,P.N11,P.N10,P.N9,P.N8,P.N7,P.N6,P.N5,P.N4,P.N3,P.N2,P.N1) LEVEL20_DISPLAY_ORDER_NUM
  FROM
    P,
    FEM_HIERARCHIES H,
    FEM_OBJECT_DEFINITION_B D,
    FEM_OBJECT_CATALOG_B C
  WHERE
    D.OBJECT_DEFINITION_ID = P.HIERARCHY_OBJ_DEF_ID AND
    H.DIMENSION_ID = :dimension_id AND
    D.OBJECT_ID = H.HIERARCHY_OBJ_ID AND
    C.OBJECT_ID = D.OBJECT_ID
) Q';

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_statement,
      p_module   => v_module || '.length_insert_into_' || v_dis_hierarchy_table_name_b,
      p_msg_text => 'v_insert_b_subquery_q2_l='||LENGTH(v_insert_b_subquery_q2)
    );


    /************************************************************************
      Construct Dynamic SQL Elements for INSERT INTO _TL table
    *************************************************************************/
    --
    -- Construct Dynamic SQL Elements for INSERT INTO _TL table (Part 1)
    --
    v_insert_tl_column_list := '
INSERT INTO ' || v_dis_hierarchy_table_name_tl || ' (
  OBJECT_ID,
  OBJECT_DEFINITION_ID, ' ||
  v_vs_column_list || '
  LEVEL1_ID,
  LEVEL2_ID,
  LEVEL3_ID,
  LEVEL4_ID,
  LEVEL5_ID,
  LEVEL6_ID,
  LEVEL7_ID,
  LEVEL8_ID,
  LEVEL9_ID,
  LEVEL10_ID,
  LEVEL11_ID,
  LEVEL12_ID,
  LEVEL13_ID,
  LEVEL14_ID,
  LEVEL15_ID,
  LEVEL16_ID,
  LEVEL17_ID,
  LEVEL18_ID,
  LEVEL19_ID,
  LEVEL20_ID,
  LANGUAGE,
  SOURCE_LANG,
  OBJECT_NAME,
  OBJECT_DEFINITION_NAME,
  LEVEL1_NAME,
  LEVEL2_NAME,
  LEVEL3_NAME,
  LEVEL4_NAME,
  LEVEL5_NAME,
  LEVEL6_NAME,
  LEVEL7_NAME,
  LEVEL8_NAME,
  LEVEL9_NAME,
  LEVEL10_NAME,
  LEVEL11_NAME,
  LEVEL12_NAME,
  LEVEL13_NAME,
  LEVEL14_NAME,
  LEVEL15_NAME,
  LEVEL16_NAME,
  LEVEL17_NAME,
  LEVEL18_NAME,
  LEVEL19_NAME,
  LEVEL20_NAME,
  LEVEL1_DESCRIPTION,
  LEVEL2_DESCRIPTION,
  LEVEL3_DESCRIPTION,
  LEVEL4_DESCRIPTION,
  LEVEL5_DESCRIPTION,
  LEVEL6_DESCRIPTION,
  LEVEL7_DESCRIPTION,
  LEVEL8_DESCRIPTION,
  LEVEL9_DESCRIPTION,
  LEVEL10_DESCRIPTION,
  LEVEL11_DESCRIPTION,
  LEVEL12_DESCRIPTION,
  LEVEL13_DESCRIPTION,
  LEVEL14_DESCRIPTION,
  LEVEL15_DESCRIPTION,
  LEVEL16_DESCRIPTION,
  LEVEL17_DESCRIPTION,
  LEVEL18_DESCRIPTION,
  LEVEL19_DESCRIPTION,
  LEVEL20_DESCRIPTION,
  CREATION_DATE,
  CREATED_BY,
  LAST_UPDATE_DATE,
  LAST_UPDATED_BY,
  LAST_UPDATE_LOGIN
)
SELECT
  B.OBJECT_ID,
  B.OBJECT_DEFINITION_ID, ' ||
  v_vs_column_member_b_table || '
  B.LEVEL1_ID,
  B.LEVEL2_ID,
  B.LEVEL3_ID,
  B.LEVEL4_ID,
  B.LEVEL5_ID,
  B.LEVEL6_ID,
  B.LEVEL7_ID,
  B.LEVEL8_ID,
  B.LEVEL9_ID,
  B.LEVEL10_ID,
  B.LEVEL11_ID,
  B.LEVEL12_ID,
  B.LEVEL13_ID,
  B.LEVEL14_ID,
  B.LEVEL15_ID,
  B.LEVEL16_ID,
  B.LEVEL17_ID,
  B.LEVEL18_ID,
  B.LEVEL19_ID,
  B.LEVEL20_ID,
  L.LANGUAGE_CODE,';

    --
    -- Construct Dynamic SQL Elements for INSERT INTO _TL table (Part 2)
    --
    v_insert_tl_name1 := '
  (
    SELECT SL.LANGUAGE_CODE
    FROM FND_LANGUAGES SL
    WHERE SL.INSTALLED_FLAG = ''B''
  ),
  (
    SELECT TL.OBJECT_NAME
    FROM FEM_OBJECT_CATALOG_TL TL
    WHERE TL.OBJECT_ID = B.OBJECT_ID
    AND   TL.LANGUAGE = L.LANGUAGE_CODE
  ),
  (
    SELECT TL.DISPLAY_NAME
    FROM FEM_OBJECT_DEFINITION_TL TL
    WHERE TL.OBJECT_DEFINITION_ID = B.OBJECT_DEFINITION_ID
    AND   TL.LANGUAGE = L.LANGUAGE_CODE
  ),
  (
    SELECT TL.' || v_member_name_col || '
    FROM ' || v_member_tl_table_name || ' TL
    WHERE TL.' || v_member_col || ' = B.LEVEL1_ID ' ||
    v_vs_where_tl || '
    AND   TL.LANGUAGE = L.LANGUAGE_CODE
  ),
  DECODE(B.LEVEL2_ID, ' || pc_dummy_member_id || ', ''' || v_dummy_parent_name || ''',
    (
      SELECT TL.' || v_member_name_col || '
      FROM ' || v_member_tl_table_name || ' TL
      WHERE TL.' || v_member_col || ' = B.LEVEL2_ID ' ||
      v_vs_where_tl || '
      AND   TL.LANGUAGE = L.LANGUAGE_CODE
    )
  ),
  (
    SELECT TL.' || v_member_name_col || '
    FROM ' || v_member_tl_table_name || ' TL
    WHERE TL.' || v_member_col || ' = B.LEVEL3_ID ' ||
    v_vs_where_tl || '
    AND   TL.LANGUAGE = L.LANGUAGE_CODE
  ),
  (
    SELECT TL.' || v_member_name_col || '
    FROM ' || v_member_tl_table_name || ' TL
    WHERE TL.' || v_member_col || ' = B.LEVEL4_ID ' ||
    v_vs_where_tl || '
    AND   TL.LANGUAGE = L.LANGUAGE_CODE
  ),
  (
    SELECT TL.' || v_member_name_col || '
    FROM ' || v_member_tl_table_name || ' TL
    WHERE TL.' || v_member_col || ' = B.LEVEL5_ID ' ||
    v_vs_where_tl || '
    AND   TL.LANGUAGE = L.LANGUAGE_CODE
  ),
  (
    SELECT TL.' || v_member_name_col || '
    FROM ' || v_member_tl_table_name || ' TL
    WHERE TL.' || v_member_col || ' = B.LEVEL6_ID ' ||
    v_vs_where_tl || '
    AND   TL.LANGUAGE = L.LANGUAGE_CODE
  ),
  (
    SELECT TL.' || v_member_name_col || '
    FROM ' || v_member_tl_table_name || ' TL
    WHERE TL.' || v_member_col || ' = B.LEVEL7_ID ' ||
    v_vs_where_tl || '
    AND   TL.LANGUAGE = L.LANGUAGE_CODE
  ),
  (
    SELECT TL.' || v_member_name_col || '
    FROM ' || v_member_tl_table_name || ' TL
    WHERE TL.' || v_member_col || ' = B.LEVEL8_ID ' ||
    v_vs_where_tl || '
    AND   TL.LANGUAGE = L.LANGUAGE_CODE
  ),
  (
    SELECT TL.' || v_member_name_col || '
    FROM ' || v_member_tl_table_name || ' TL
    WHERE TL.' || v_member_col || ' = B.LEVEL9_ID ' ||
    v_vs_where_tl || '
    AND   TL.LANGUAGE = L.LANGUAGE_CODE
  ),
  (
    SELECT TL.' || v_member_name_col || '
    FROM ' || v_member_tl_table_name || ' TL
    WHERE TL.' || v_member_col || ' = B.LEVEL10_ID ' ||
    v_vs_where_tl || '
    AND   TL.LANGUAGE = L.LANGUAGE_CODE
  ),';

    --
    -- Construct Dynamic SQL Elements for INSERT INTO _TL table (Part 3)
    --
    v_insert_tl_name2 := '
  (
    SELECT TL.' || v_member_name_col || '
    FROM ' || v_member_tl_table_name || ' TL
    WHERE TL.' || v_member_col || ' = B.LEVEL11_ID ' ||
    v_vs_where_tl || '
    AND   TL.LANGUAGE = L.LANGUAGE_CODE
  ),
  (
    SELECT TL.' || v_member_name_col || '
    FROM ' || v_member_tl_table_name || ' TL
    WHERE TL.' || v_member_col || ' = B.LEVEL12_ID ' ||
    v_vs_where_tl || '
    AND   TL.LANGUAGE = L.LANGUAGE_CODE
  ),
  (
    SELECT TL.' || v_member_name_col || '
    FROM ' || v_member_tl_table_name || ' TL
    WHERE TL.' || v_member_col || ' = B.LEVEL13_ID ' ||
    v_vs_where_tl || '
    AND   TL.LANGUAGE = L.LANGUAGE_CODE
  ),
  (
    SELECT TL.' || v_member_name_col || '
    FROM ' || v_member_tl_table_name || ' TL
    WHERE TL.' || v_member_col || ' = B.LEVEL14_ID ' ||
    v_vs_where_tl || '
    AND   TL.LANGUAGE = L.LANGUAGE_CODE
  ),
  (
    SELECT TL.' || v_member_name_col || '
    FROM ' || v_member_tl_table_name || ' TL
    WHERE TL.' || v_member_col || ' = B.LEVEL15_ID ' ||
    v_vs_where_tl || '
    AND   TL.LANGUAGE = L.LANGUAGE_CODE
  ),
  (
    SELECT TL.' || v_member_name_col || '
    FROM ' || v_member_tl_table_name || ' TL
    WHERE TL.' || v_member_col || ' = B.LEVEL16_ID ' ||
    v_vs_where_tl || '
    AND   TL.LANGUAGE = L.LANGUAGE_CODE
  ),
  (
    SELECT TL.' || v_member_name_col || '
    FROM ' || v_member_tl_table_name || ' TL
    WHERE TL.' || v_member_col || ' = B.LEVEL17_ID ' ||
    v_vs_where_tl || '
    AND   TL.LANGUAGE = L.LANGUAGE_CODE
  ),
  (
    SELECT TL.' || v_member_name_col || '
    FROM ' || v_member_tl_table_name || ' TL
    WHERE TL.' || v_member_col || ' = B.LEVEL18_ID ' ||
    v_vs_where_tl || '
    AND   TL.LANGUAGE = L.LANGUAGE_CODE
  ),
  (
    SELECT TL.' || v_member_name_col || '
    FROM ' || v_member_tl_table_name || ' TL
    WHERE TL.' || v_member_col || ' = B.LEVEL19_ID ' ||
    v_vs_where_tl || '
    AND   TL.LANGUAGE = L.LANGUAGE_CODE
  ),
  (
    SELECT TL.' || v_member_name_col || '
    FROM ' || v_member_tl_table_name || ' TL
    WHERE TL.' || v_member_col || ' = B.LEVEL20_ID ' ||
    v_vs_where_tl || '
    AND   TL.LANGUAGE = L.LANGUAGE_CODE
  ),';

    --
    -- Construct Dynamic SQL Elements for INSERT INTO _TL table (Part 4)
    --
    v_insert_tl_description1 := '
  (
    SELECT TL.DESCRIPTION
    FROM ' || v_member_tl_table_name || ' TL
    WHERE TL.' || v_member_col || ' = B.LEVEL1_ID ' ||
    v_vs_where_tl || '
    AND   TL.LANGUAGE = L.LANGUAGE_CODE
  ),
  DECODE(B.LEVEL2_ID, ' || pc_dummy_member_id || ', ''' || v_dummy_parent_name || ''',
    (
      SELECT TL.DESCRIPTION
      FROM ' || v_member_tl_table_name || ' TL
      WHERE TL.' || v_member_col || ' = B.LEVEL2_ID ' ||
      v_vs_where_tl || '
      AND   TL.LANGUAGE = L.LANGUAGE_CODE
    )
  ),
  (
    SELECT TL.DESCRIPTION
    FROM ' || v_member_tl_table_name || ' TL
    WHERE TL.' || v_member_col || ' = B.LEVEL3_ID ' ||
    v_vs_where_tl || '
    AND   TL.LANGUAGE = L.LANGUAGE_CODE
  ),
  (
    SELECT TL.DESCRIPTION
    FROM ' || v_member_tl_table_name || ' TL
    WHERE TL.' || v_member_col || ' = B.LEVEL4_ID ' ||
    v_vs_where_tl || '
    AND   TL.LANGUAGE = L.LANGUAGE_CODE
  ),
  (
    SELECT TL.DESCRIPTION
    FROM ' || v_member_tl_table_name || ' TL
    WHERE TL.' || v_member_col || ' = B.LEVEL5_ID ' ||
    v_vs_where_tl || '
    AND   TL.LANGUAGE = L.LANGUAGE_CODE
  ),
  (
    SELECT TL.DESCRIPTION
    FROM ' || v_member_tl_table_name || ' TL
    WHERE TL.' || v_member_col || ' = B.LEVEL6_ID ' ||
    v_vs_where_tl || '
    AND   TL.LANGUAGE = L.LANGUAGE_CODE
  ),
  (
    SELECT TL.DESCRIPTION
    FROM ' || v_member_tl_table_name || ' TL
    WHERE TL.' || v_member_col || ' = B.LEVEL7_ID ' ||
    v_vs_where_tl || '
    AND   TL.LANGUAGE = L.LANGUAGE_CODE
  ),
  (
    SELECT TL.DESCRIPTION
    FROM ' || v_member_tl_table_name || ' TL
    WHERE TL.' || v_member_col || ' = B.LEVEL8_ID ' ||
    v_vs_where_tl || '
    AND   TL.LANGUAGE = L.LANGUAGE_CODE
  ),
  (
    SELECT TL.DESCRIPTION
    FROM ' || v_member_tl_table_name || ' TL
    WHERE TL.' || v_member_col || ' = B.LEVEL9_ID ' ||
    v_vs_where_tl || '
    AND   TL.LANGUAGE = L.LANGUAGE_CODE
  ),
  (
    SELECT TL.DESCRIPTION
    FROM ' || v_member_tl_table_name || ' TL
    WHERE TL.' || v_member_col || ' = B.LEVEL10_ID ' ||
    v_vs_where_tl || '
    AND   TL.LANGUAGE = L.LANGUAGE_CODE
  ),';

    --
    -- Construct Dynamic SQL Elements for INSERT INTO _TL table (Part 5)
    --
    v_insert_tl_description2 := '
  (
    SELECT TL.DESCRIPTION
    FROM ' || v_member_tl_table_name || ' TL
    WHERE TL.' || v_member_col || ' = B.LEVEL11_ID ' ||
    v_vs_where_tl || '
    AND   TL.LANGUAGE = L.LANGUAGE_CODE
  ),
  (
    SELECT TL.DESCRIPTION
    FROM ' || v_member_tl_table_name || ' TL
    WHERE TL.' || v_member_col || ' = B.LEVEL12_ID ' ||
    v_vs_where_tl || '
    AND   TL.LANGUAGE = L.LANGUAGE_CODE
  ),
  (
    SELECT TL.DESCRIPTION
    FROM ' || v_member_tl_table_name || ' TL
    WHERE TL.' || v_member_col || ' = B.LEVEL13_ID ' ||
    v_vs_where_tl || '
    AND   TL.LANGUAGE = L.LANGUAGE_CODE
  ),
  (
    SELECT TL.DESCRIPTION
    FROM ' || v_member_tl_table_name || ' TL
    WHERE TL.' || v_member_col || ' = B.LEVEL14_ID ' ||
    v_vs_where_tl || '
    AND   TL.LANGUAGE = L.LANGUAGE_CODE
  ),
  (
    SELECT TL.DESCRIPTION
    FROM ' || v_member_tl_table_name || ' TL
    WHERE TL.' || v_member_col || ' = B.LEVEL15_ID ' ||
    v_vs_where_tl || '
    AND   TL.LANGUAGE = L.LANGUAGE_CODE
  ),
  (
    SELECT TL.DESCRIPTION
    FROM ' || v_member_tl_table_name || ' TL
    WHERE TL.' || v_member_col || ' = B.LEVEL16_ID ' ||
    v_vs_where_tl || '
    AND   TL.LANGUAGE = L.LANGUAGE_CODE
  ),
  (
    SELECT TL.DESCRIPTION
    FROM ' || v_member_tl_table_name || ' TL
    WHERE TL.' || v_member_col || ' = B.LEVEL17_ID ' ||
    v_vs_where_tl || '
    AND   TL.LANGUAGE = L.LANGUAGE_CODE
  ),
  (
    SELECT TL.DESCRIPTION
    FROM ' || v_member_tl_table_name || ' TL
    WHERE TL.' || v_member_col || ' = B.LEVEL18_ID ' ||
    v_vs_where_tl || '
    AND   TL.LANGUAGE = L.LANGUAGE_CODE
  ),
  (
    SELECT TL.DESCRIPTION
    FROM ' || v_member_tl_table_name || ' TL
    WHERE TL.' || v_member_col || ' = B.LEVEL19_ID ' ||
    v_vs_where_tl || '
    AND   TL.LANGUAGE = L.LANGUAGE_CODE
  ),
  (
    SELECT TL.DESCRIPTION
    FROM ' || v_member_tl_table_name || ' TL
    WHERE TL.' || v_member_col || ' = B.LEVEL20_ID ' ||
    v_vs_where_tl || '
    AND   TL.LANGUAGE = L.LANGUAGE_CODE
  ),
  SYSDATE CREATION_DATE,
  :pv_user_id CREATED_BY,
  SYSDATE LAST_UPDATE_DATE,
  :pv_user_id LAST_UPDATED_BY,
  :pv_login_id LAST_UPDATE_LOGIN
FROM
  ' || v_dis_hierarchy_table_name_b || ' B,
  FND_LANGUAGES L
WHERE
  L.INSTALLED_FLAG IN (''B'', ''I'')';


    /************************************************************************
      Execute Dynamic SQLs for _B
    *************************************************************************/
    --
    -- Execute Dynamic SQL for DELETE FROM _B table
    --
    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_statement,
      p_module   => v_module || '.delete_from_b',
      p_msg_text => 'Deleting from _B table'
    );

    EXECUTE IMMEDIATE '
DELETE FROM ' || v_dis_hierarchy_table_name_b;

    v_deleted_b := SQL%ROWCOUNT;

    --
    -- Execute Dynamic SQL for INSERT INTO _B table
    --
    -- Open hierarchy type
    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_statement,
      p_module   => v_module || '.insert_into_b_open_attr_enabled_dim',
      p_msg_text => 'Inserting into _B table for Open hierarchy (attribute enabled dimension)'
    );

    Print_DSQL_Insert_B(
      v_module,
      v_dis_hierarchy_table_name_b,
      v_insert_b_column_list,
      v_insert_b_display_code1,
      v_insert_b_display_code2,
      NULL,
      v_insert_b_with_p1,
      v_insert_b_with_p2,
      v_insert_b_with_p3,
      v_insert_b_subquery_r1,
      v_insert_b_subquery_r2,
      v_insert_b_subquery_h11_o,
      NULL,
      v_insert_b_exclude_nonleaf_o,
      v_insert_b_subquery_q1,
      v_insert_b_subquery_q2,
      pv_user_id,
      pv_user_id,
      pv_login_id,
      'OPEN',
      v_dimension_id,
      v_dimension_id,
      'OPEN',
      v_dimension_id,
      NULL,
      NULL,
      NULL
    );

    EXECUTE IMMEDIATE
      v_insert_b_column_list ||
      v_insert_b_display_code1 ||
      v_insert_b_display_code2 ||
      '' ||
      v_insert_b_with_p1 ||
      v_insert_b_with_p2 ||
      v_insert_b_with_p3 ||
      v_insert_b_subquery_r1 ||
      v_insert_b_subquery_r2 ||
      v_insert_b_subquery_h11_o ||
      '' ||
      v_insert_b_exclude_nonleaf_o ||
      v_insert_b_subquery_q1 ||
      v_insert_b_subquery_q2
    USING
      pv_user_id,
      pv_user_id,
      pv_login_id,
      'OPEN',
      v_dimension_id,
      'OPEN',
      v_dimension_id,
      v_dimension_id;

    v_inserted_b1 := SQL%ROWCOUNT;

    IF v_attribute_table_name IS NOT NULL THEN

      -- Reconciliation hierarchy type
      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_statement,
        p_module   => v_module || '.insert_into_b_recon_attr_enabled_dim',
        p_msg_text => 'Inserting into _B table for Reconciliation hierarchy (attribute enabled dimension)'
      );

      Print_DSQL_Insert_B(
        v_module,
        v_dis_hierarchy_table_name_b,
        v_insert_b_column_list,
        v_insert_b_display_code1,
        v_insert_b_display_code2,
        v_insert_b_with_o,
        v_insert_b_with_p1,
        v_insert_b_with_p2,
        v_insert_b_with_p3,
        v_insert_b_subquery_r1,
        v_insert_b_subquery_r2,
        v_insert_b_subquery_h11,
        v_insert_b_subquery_h12,
        v_insert_b_exclude_nonleaf,
        v_insert_b_subquery_q1,
        v_insert_b_subquery_q2,
        pv_user_id,
        pv_user_id,
        pv_login_id,
        v_dimension_id,
        v_dimension_id,
        v_dimension_id,
        'RECONCILIATION',
        v_dimension_id,
        'RECONCILIATION',
        v_dimension_id,
        v_dimension_id
      );

      EXECUTE IMMEDIATE
        v_insert_b_column_list ||
        v_insert_b_display_code1 ||
        v_insert_b_display_code2 ||
        v_insert_b_with_o ||
        v_insert_b_with_p1 ||
        v_insert_b_with_p2 ||
        v_insert_b_with_p3 ||
        v_insert_b_subquery_r1 ||
        v_insert_b_subquery_r2 ||
        v_insert_b_subquery_h11 ||
        v_insert_b_subquery_h12 ||
        v_insert_b_exclude_nonleaf ||
        v_insert_b_subquery_q1 ||
        v_insert_b_subquery_q2
      USING
        pv_user_id,
        pv_user_id,
        pv_login_id,
        v_dimension_id,
        v_dimension_id,
        v_dimension_id,
        'RECONCILIATION',
        v_dimension_id,
        'RECONCILIATION',
        v_dimension_id,
        v_dimension_id;

    ELSE -- IF v_attribute_table_name IS NOT NULL THEN

      -- Reconciliation hierarchy type
      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_statement,
        p_module   => v_module || '.insert_into_b_recon_attr_disabled_dim',
        p_msg_text => 'Inserting into _B table for Reconciliation hierarchy (attribute disabled dimension)'
      );

      Print_DSQL_Insert_B(
        v_module,
        v_dis_hierarchy_table_name_b,
        v_insert_b_column_list,
        v_insert_b_display_code1,
        v_insert_b_display_code2,
        v_insert_b_with_o,
        v_insert_b_with_p1,
        v_insert_b_with_p2,
        v_insert_b_with_p3,
        v_insert_b_subquery_r1,
        v_insert_b_subquery_r2,
        v_insert_b_subquery_h11,
        v_insert_b_subquery_h12,
        v_insert_b_exclude_nonleaf,
        v_insert_b_subquery_q1,
        v_insert_b_subquery_q2,
        pv_user_id,
        pv_user_id,
        pv_login_id,
        v_dimension_id,
        v_dimension_id,
        'RECONCILIATION',
        v_dimension_id,
        'RECONCILIATION',
        v_dimension_id,
        v_dimension_id,
        NULL
      );

      EXECUTE IMMEDIATE
        v_insert_b_column_list ||
        v_insert_b_display_code1 ||
        v_insert_b_display_code2 ||
        v_insert_b_with_o ||
        v_insert_b_with_p1 ||
        v_insert_b_with_p2 ||
        v_insert_b_with_p3 ||
        v_insert_b_subquery_r1 ||
        v_insert_b_subquery_r2 ||
        v_insert_b_subquery_h11 ||
        v_insert_b_subquery_h12 ||
        v_insert_b_exclude_nonleaf ||
        v_insert_b_subquery_q1 ||
        v_insert_b_subquery_q2
      USING
        pv_user_id,
        pv_user_id,
        pv_login_id,
        v_dimension_id,
        v_dimension_id,
        'RECONCILIATION',
        v_dimension_id,
        'RECONCILIATION',
        v_dimension_id,
        v_dimension_id;

    END IF;

    v_inserted_b2 := SQL%ROWCOUNT;


    /************************************************************************
      Execute Dynamic SQLs for _TL
    *************************************************************************/
    IF v_member_tl_table_name IS NOT NULL THEN

      --
      -- Execute Dynamic SQL for DELETE FROM _TL table
      --
      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_statement,
        p_module   => v_module || '.delete_from_tl',
        p_msg_text => 'Deleting from _TL table'
      );

      EXECUTE IMMEDIATE '
DELETE FROM ' || v_dis_hierarchy_table_name_tl;

      v_deleted_tl := SQL%ROWCOUNT;

      --
      -- Execute Dynamic SQL for INSERT INTO _TL table
      --
      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_statement,
        p_module   => v_module || '.delete_from_tl',
        p_msg_text => 'Inserting into _TL table'
      );

      Print_DSQL_Insert_TL(
        v_module,
        v_dis_hierarchy_table_name_tl,
        v_insert_tl_column_list,
        v_insert_tl_name1,
        v_insert_tl_name2,
        v_insert_tl_description1,
        v_insert_tl_description2,
        pv_user_id,
        pv_user_id,
        pv_login_id
      );

      EXECUTE IMMEDIATE
        v_insert_tl_column_list ||
        v_insert_tl_name1 ||
        v_insert_tl_name2 ||
        v_insert_tl_description1 ||
        v_insert_tl_description2
      USING
        pv_user_id,
        pv_user_id,
        pv_login_id;

      v_inserted_tl := SQL%ROWCOUNT;

    END IF;

    COMMIT;

    --
    -- Get a list of muti value set enabled hierarchies
    --
    EXECUTE IMMEDIATE '
      SELECT DISTINCT
        CAT.OBJECT_NAME,
        CAT.OBJECT_ID
      FROM
        FEM_HIERARCHIES HIER,
        FEM_OBJECT_DEFINITION_VL DEF,
        FEM_OBJECT_CATALOG_VL CAT,
       ' || v_hierarchy_table_name || ' H
      WHERE
        HIER.MULTI_VALUE_SET_FLAG = ''Y'' AND
        HIER.DIMENSION_ID = :dimension_id AND
        HIER.PERSONAL_FLAG = ''N'' AND
        CAT.OBJECT_ID = HIER.HIERARCHY_OBJ_ID AND
        DEF.OBJECT_ID = CAT.OBJECT_ID AND
        H.HIERARCHY_OBJ_DEF_ID = DEF.OBJECT_DEFINITION_ID AND ' ||
        v_vs_where_root || '
        H.PARENT_ID = H.CHILD_ID AND H.PARENT_DEPTH_NUM = 1'
      BULK COLLECT INTO
        v_object_name_array,
        v_object_id_array
      USING v_dimension_id;

    v_multi_vs_num := SQL%ROWCOUNT;

    IF v_multi_vs_num > 0 THEN
      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_statement,
        p_module   => v_module || '.multi_vs',
        p_app_name => 'FEM',
        p_msg_name => 'FEM_DIS_HIER_MULTI_VALUE_SETS',
        p_token1   => 'DIMENSION',
        p_value1   => v_dimension_name
      );

      FEM_ENGINES_PKG.User_Message(
        p_app_name => 'FEM',
        p_msg_name => 'FEM_DIS_HIER_MULTI_VALUE_SETS',
        p_token1   => 'DIMENSION',
        p_value1   => v_dimension_name
      );

      FOR i IN 1..v_multi_vs_num LOOP
        FEM_ENGINES_PKG.Tech_Message(
          p_severity => pc_log_level_statement,
          p_module   => v_module || '.multi_vs',
          p_msg_text => '  ' ||
            v_object_name_array(i) || '(' ||
            v_object_id_array(i) || ')'
        );

        FEM_ENGINES_PKG.User_Message(
          p_msg_text => '  ' ||
            v_object_name_array(i) || '(' ||
            v_object_id_array(i) || ')'
        );
      END LOOP;

    END IF;

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_statement,
      p_module   => v_module || '.rowcount',
      p_msg_text => 'v_deleted_b='    || v_deleted_b   || ', ' ||
                    'v_inserted_b1='  || v_inserted_b1  || ', ' ||
                    'v_inserted_b2='  || v_inserted_b2  || ', ' ||
                    'v_deleted_tl='   || v_deleted_tl  || ', ' ||
                    'v_inserted_tl='  || v_inserted_tl
    );

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_procedure,
      p_module   => v_module || '.end',
      p_app_name => 'FEM',
      p_msg_name => 'FEM_GL_POST_202',
      p_token1   => 'FUNC_NAME',
      p_value1   => v_func_name,
      p_token2   => 'TIME',
      p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
    );

    FEM_ENGINES_PKG.User_Message(
      p_app_name => 'FEM',
      p_msg_name => 'FEM_GL_POST_202',
      p_token1   => 'FUNC_NAME',
      p_value1   => v_func_name,
      p_token2   => 'TIME',
      p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
    );

    RETURN('NORMAL');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_exception,
        p_module   => v_module || '.others',
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

      v_insert_b_column_list_l     := LENGTH(v_insert_b_column_list_l);
      v_insert_b_display_code1_l   := LENGTH(v_insert_b_display_code1_l);
      v_insert_b_display_code2_l   := LENGTH(v_insert_b_display_code2_l);
      v_insert_b_with_p1_l         := LENGTH(v_insert_b_with_p1_l);
      v_insert_b_with_p2_l         := LENGTH(v_insert_b_with_p2_l);
      v_insert_b_with_p3_l         := LENGTH(v_insert_b_with_p3_l);
      v_insert_b_subquery_r1_l     := LENGTH(v_insert_b_subquery_r1_l);
      v_insert_b_subquery_r2_l     := LENGTH(v_insert_b_subquery_r2_l);
      v_insert_b_subquery_h11_o_l  := LENGTH(v_insert_b_subquery_h11_o_l);
      v_insert_b_subquery_h11_l    := LENGTH(v_insert_b_subquery_h11_l);
      v_insert_b_subquery_h12_l    := LENGTH(v_insert_b_subquery_h12_l);
      v_insert_b_exclude_nonleaf_o_l := LENGTH(v_insert_b_exclude_nonleaf_o_l);
      v_insert_b_exclude_nonleaf_l := LENGTH(v_insert_b_exclude_nonleaf_l);
      v_insert_b_subquery_q1_l     := LENGTH(v_insert_b_subquery_q1_l);
      v_insert_b_subquery_q2_l     := LENGTH(v_insert_b_subquery_q2_l);

      v_insert_tl_column_list_l  := LENGTH(v_insert_tl_column_list);
      v_insert_tl_name1_l        := LENGTH(v_insert_tl_name1);
      v_insert_tl_name2_l        := LENGTH(v_insert_tl_name2);
      v_insert_tl_description1_l := LENGTH(v_insert_tl_description1);
      v_insert_tl_description2_l := LENGTH(v_insert_tl_description2);

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_exception,
        p_module   => v_module || '.others',
        p_msg_text => 'v_insert_b_column_list_l='|| v_insert_b_column_list_l || ', ' ||
                      'v_insert_b_display_code1_l='|| v_insert_b_display_code1_l || ', ' ||
                      'v_insert_b_display_code2_l='|| v_insert_b_display_code2_l || ', ' ||
                      'v_insert_b_with_p1_l='|| v_insert_b_with_p1_l || ', ' ||
                      'v_insert_b_with_p2_l='|| v_insert_b_with_p2_l || ', ' ||
                      'v_insert_b_with_p3_l='|| v_insert_b_with_p3_l || ', ' ||
                      'v_insert_b_subquery_r1_l='|| v_insert_b_subquery_r1_l || ', ' ||
                      'v_insert_b_subquery_r2_l='|| v_insert_b_subquery_r2_l || ', ' ||
                      'v_insert_b_subquery_h11_o_l='|| v_insert_b_subquery_h11_o_l || ', ' ||
                      'v_insert_b_subquery_h11_l='|| v_insert_b_subquery_h11_l || ', ' ||
                      'v_insert_b_subquery_h12_l='|| v_insert_b_subquery_h12_l || ', ' ||
                      'v_insert_b_exclude_nonleaf_o_l='|| v_insert_b_exclude_nonleaf_o_l || ', ' ||
                      'v_insert_b_exclude_nonleaf_l='|| v_insert_b_exclude_nonleaf_l || ', ' ||
                      'v_insert_b_subquery_q1_l='|| v_insert_b_subquery_q1_l || ', ' ||
                      'v_insert_b_subquery_q2_l='|| v_insert_b_subquery_q2_l || ', ' ||
                      'v_insert_tl_column_list_l=' ||v_insert_tl_column_list_l  ||', ' ||
                      'v_insert_tl_name1_l=' ||v_insert_tl_name1_l  ||', ' ||
                      'v_insert_tl_name2_l=' ||v_insert_tl_name2_l  ||', ' ||
                      'v_insert_tl_description1_l=' ||v_insert_tl_description1_l  ||', ' ||
                      'v_insert_tl_description2_l=' ||v_insert_tl_description2_l
      );


      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_exception,
        p_module   => v_module || '.others',
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_203',
        p_token1   => 'FUNC_NAME',
        p_value1   => v_func_name,
        p_token2   => 'TIME',
        p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
      );

      FEM_ENGINES_PKG.User_Message(
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_203',
        p_token1   => 'FUNC_NAME',
        p_value1   => v_func_name,
        p_token2   => 'TIME',
        p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
      );

      RETURN('ERROR');

  END Transformation;


  -- ======================================================================
  -- Procedure
  --   Run_Transformation
  -- Purpose
  --   Runs Hierarchy Transformation for all supported dimensions
  -- History
  --   06-22-05  Shintaro Okuda  Created
  -- Arguments
  --   x_errbuf                  Standard Concurrent Program parameter
  --   x_retcode                 Standard Concurrent Program parameter
  --   p_dimension_varchar_label Dimension Varchar Label
  -- ======================================================================
  PROCEDURE Run_Transformation(
    x_errbuf                  OUT NOCOPY VARCHAR2,
    x_retcode                 OUT NOCOPY VARCHAR2,
    p_dimension_varchar_label IN VARCHAR2
  ) IS

    CURSOR CurDim IS
      SELECT *
      FROM FEM_DIS_DIMENSIONS_V
      WHERE DIMENSION_VARCHAR_LABEL <> 'ALL';

    CURSOR CurReq(p_parent_request_id NUMBER) IS
      SELECT *
      FROM FND_CONCURRENT_REQUESTS
      WHERE PARENT_REQUEST_ID = p_parent_request_id;

    TYPE DisDims IS TABLE OF FEM_DIS_DIMENSIONS_V%ROWTYPE;
    TYPE ChildReqs IS TABLE OF FND_CONCURRENT_REQUESTS%ROWTYPE;

    v_dis_dims DisDims;
    v_child_requests ChildReqs;

    v_request_data VARCHAR2(100);

    v_child_request_id NUMBER;

    v_dimension_name VARCHAR2(80);

    v_phase      VARCHAR2(100);
    v_status     VARCHAR2(100);
    v_dev_phase  VARCHAR2(100);
    v_dev_status VARCHAR2(100);
    v_message    VARCHAR2(500);

    v_dummy_number  NUMBER;
    v_dummy_boolean BOOLEAN;

    v_completion_status VARCHAR2(30);

    v_warnings NUMBER := 0;
    v_errors   NUMBER := 0;

    v_module VARCHAR2(100) := 'fem.plsql.fem_dis_hier_pkg.run_transformation';
    v_func_name VARCHAR2(100) := 'FEM_DIS_HIER_PKG.Run_Transformation';

    HIER_TRANS_INVALID_DIMENSION EXCEPTION;
    HIER_TRANS_CHILD_SUB_FAILED  EXCEPTION;

  BEGIN

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_procedure,
      p_module   => v_module || '.begin',
      p_app_name => 'FEM',
      p_msg_name => 'FEM_GL_POST_201',
      p_token1   => 'FUNC_NAME',
      p_value1   => v_func_name,
      p_token2   => 'TIME',
      p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
    );

    FEM_ENGINES_PKG.User_Message(
      p_app_name => 'FEM',
      p_msg_name => 'FEM_GL_POST_201',
      p_token1   => 'FUNC_NAME',
      p_value1   => v_func_name,
      p_token2   => 'TIME',
      p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
    );

    --
    -- Initialize package variables
    --
    pv_req_id   := NVL(FND_GLOBAL.Conc_Request_ID,-1);
    pv_user_id  := NVL(FND_GLOBAL.User_ID,'-1');
    pv_login_id := NVL(FND_GLOBAL.Conc_Login_ID, FND_GLOBAL.Login_ID);

    --
    -- Validate input parameter
    --
    BEGIN
      SELECT 1 INTO v_dummy_number
      FROM FEM_DIS_DIMENSIONS_V
      WHERE DIMENSION_VARCHAR_LABEL = p_dimension_varchar_label;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE HIER_TRANS_INVALID_DIMENSION;
      WHEN OTHERS THEN
        RAISE;
    END;


    IF p_dimension_varchar_label <> 'ALL' THEN

      /***********************************************************************
        Individual execution does not use FND_CONC_GLOBAL
      ************************************************************************/

      -- Run Transformation
      v_completion_status :=
        Transformation(p_dimension_varchar_label => p_dimension_varchar_label);

    ELSE

      /***********************************************************************
        Batch execution uses FND_CONC_GLOBAL

        Read the value from REQUEST_DATA. If this is the first run of
        the program, then this value will be NULL. Thus, submitting
        child requests. Otherwise,the program is reawaken and REQUEST_DATA
        will be the value that we passed to SET_REQ_GLOBALS on the previous
        run.

        References for PL/SQL Concurrent Processing Recursive Calls
        -----------------------------------------------------------
        1. Chapter 21: PL/SQL APIs for Concurrent Processing,
          Oracle Applications Developers Guide,
        2. Note 221542.1: Sample Code for FND_SUBMIT and FND_REQUEST API's
        3. WSHDDSHB.pls
        4. cefcshfb.pls
      ************************************************************************/

      v_request_data := FND_CONC_GLOBAL.Request_Data;

      IF v_request_data IS NULL THEN

        /**********************************************************************
          Parent is initiated
        **********************************************************************/
        -- Get Dimension information
        OPEN CurDim;
        FETCH CurDim BULK COLLECT INTO v_dis_dims;
        CLOSE CUrDIm;

        -- Run transformation for each dimension using a child process
        FOR i IN 1..v_dis_dims.LAST LOOP

          v_child_request_id :=
            FND_REQUEST.Submit_Request(
              application => 'FEM',
              program => 'FEM_DIS_HIER_TRANS',
              description => v_dis_dims(i).dimension_name,
              start_time => NULL,
              sub_request => TRUE,
              argument1 => v_dis_dims(i).dimension_varchar_label
            );

          IF v_child_request_id = 0 THEN

            -- If a request submission is failed, raise an exception

            v_dimension_name := v_dis_dims(i).dimension_name;

            x_errbuf := FND_MESSAGE.Get;

            RAISE HIER_TRANS_CHILD_SUB_FAILED;

          ELSE

            FEM_ENGINES_PKG.User_Message(
              p_app_name => 'FEM',
              p_msg_name => 'FEM_DIS_HIER_REQ_SUB_SUCCESS',
              p_token1   => 'DIMENSION',
              p_value1   => v_dis_dims(i).dimension_name,
              p_token2   => 'REQ_ID',
              p_value2   => TO_CHAR(v_child_request_id)
            );

            FEM_ENGINES_PKG.Tech_Message(
              p_severity => pc_log_level_statement,
              p_module   => v_module || '.child_req_submission',
              p_app_name => 'FEM',
              p_msg_name => 'FEM_DIS_HIER_REQ_SUB_SUCCESS',
              p_token1   => 'DIMENSION',
              p_value1   => v_dis_dims(i).dimension_name,
              p_token2   => 'REQ_ID',
              p_value2   => TO_CHAR(v_child_request_id)
            );

          END IF;

        END LOOP;

        --
        -- Put the program into the PAUSED status and indicate the end of
        -- initial execution
        --
        FND_CONC_GLOBAL.Set_Req_Globals(
          conc_status => 'PAUSED',
          request_data => 'SUBMITTED'
        );

        v_completion_status := 'NORMAL';

      ELSE -- IF v_request_data IS NULL THEN

        /**********************************************************************
          Parent is reawaken
        **********************************************************************/
        -- Get child process ids
        OPEN CurReq(pv_req_id);
        FETCH CurReq BULK COLLECT INTO v_child_requests;
        CLOSE CurReq;

        FOR i IN 1..v_child_requests.LAST LOOP

          v_status := NULL;
          v_dev_status := NULL;

          v_dummy_boolean :=
            FND_CONCURRENT.Get_Request_Status(
              request_id => v_child_requests(i).request_id,
              phase      => v_phase,
              status     => v_status,
              dev_phase  => v_dev_phase,
              dev_status => v_dev_status,
              message    => v_message
            );

          IF v_dev_status = 'WARNING' THEN
            v_warnings:= v_warnings + 1;
          ELSIF v_dev_status <> 'NORMAL' THEN
            v_errors := v_errors + 1;
          END IF;

          FEM_ENGINES_PKG.Tech_Message(
            p_severity => pc_log_level_statement,
            p_module   => v_module || 'child_req_status',
            p_app_name => 'FEM',
            p_msg_name => 'FEM_DIS_HIER_REQ_STATUS',
            p_token1   => 'DIMENSION',
            p_value1   => v_child_requests(i).description,
            p_token2   => 'REQ_ID',
            p_value2   => TO_CHAR(v_child_requests(i).request_id),
            p_token3   => 'STATUS',
            p_value3   => v_status
          );

          FEM_ENGINES_PKG.User_Message(
            p_app_name => 'FEM',
            p_msg_name => 'FEM_DIS_HIER_REQ_STATUS',
            p_token1   => 'DIMENSION',
            p_value1   => v_child_requests(i).description,
            p_token2   => 'REQ_ID',
            p_value2   => TO_CHAR(v_child_requests(i).request_id),
            p_token3   => 'STATUS',
            p_value3   => v_status
          );

        END LOOP;

        IF v_errors = 0  AND v_warnings = 0 THEN
          -- If all dimensions transformations are successful
          v_completion_status := 'NORMAL';

        ELSIF (v_errors > 0) AND (v_errors = v_child_requests.count) THEN
          -- If all dimensions transformations are failed
          v_completion_status := 'ERROR';

        ELSE
          -- If some dimensions transformations are successful
          v_completion_status := 'WARNING';

        END IF;

      END IF; -- IF v_request_data IS NULL THEN

    END IF; -- IF p_dimension_varchar_label = 'ALL' THEN

    --
    -- Set request completion status
    --
    IF v_completion_status = 'NORMAL' THEN
      x_retcode := '0';

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_procedure,
        p_module   => v_module || '.end',
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_202',
        p_token1   => 'FUNC_NAME',
        p_value1   => v_func_name,
        p_token2   => 'TIME',
        p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
      );

      FEM_ENGINES_PKG.User_Message(
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_202',
        p_token1   => 'FUNC_NAME',
        p_value1   => v_func_name,
        p_token2   => 'TIME',
        p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
      );

    ELSIF v_completion_status = 'WARNING' THEN
      x_retcode := '1';

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_procedure,
        p_module   => v_module || '.end',
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_206'
      );

      FEM_ENGINES_PKG.User_Message(
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_206'
      );

    ELSE
      x_retcode := '2';

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_procedure,
        p_module   => v_module || '.end',
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_203',
        p_token1   => 'FUNC_NAME',
        p_value1   => v_func_name,
        p_token2   => 'TIME',
        p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
      );

      FEM_ENGINES_PKG.User_Message(
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_203',
        p_token1   => 'FUNC_NAME',
        p_value1   => v_func_name,
        p_token2   => 'TIME',
        p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
      );

    END IF;

  EXCEPTION
    WHEN HIER_TRANS_INVALID_DIMENSION THEN
      ROLLBACK;

      x_retcode := '2';

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_exception,
        p_module   => v_module || '.invalid_dimension',
        p_app_name => 'FEM',
        p_msg_name => 'FEM_DIS_HIER_INVALID_DIMENSION',
        p_token1   => 'DIMENSION',
        p_value1   => p_dimension_varchar_label
      );

      FEM_ENGINES_PKG.User_Message(
        p_app_name => 'FEM',
        p_msg_name => 'FEM_DIS_HIER_INVALID_DIMENSION',
        p_token1   => 'DIMENSION',
        p_value1   => p_dimension_varchar_label
      );

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_exception,
        p_module   => v_module || '.invalid_dimension',
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_203',
        p_token1   => 'FUNC_NAME',
        p_value1   => v_func_name,
        p_token2   => 'TIME',
        p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
      );

      FEM_ENGINES_PKG.User_Message(
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_203',
        p_token1   => 'FUNC_NAME',
        p_value1   => v_func_name,
        p_token2   => 'TIME',
        p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
      );

    WHEN HIER_TRANS_CHILD_SUB_FAILED THEN
      ROLLBACK;

      x_retcode := '2';

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_exception,
        p_module   => v_module || '.sub_failed',
        p_app_name => 'FEM',
        p_msg_name => 'FEM_DIS_HIER_REQ_SUB_FAILURE',
        p_token1   => 'DIMENSION',
        p_value1   => v_dimension_name
      );

      FEM_ENGINES_PKG.User_Message(
        p_app_name => 'FEM',
        p_msg_name => 'FEM_DIS_HIER_REQ_SUB_FAILURE',
        p_token1   => 'DIMENSION',
        p_value1   => v_dimension_name
      );

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_exception,
        p_module   => v_module || '.sub_failed',
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_203',
        p_token1   => 'FUNC_NAME',
        p_value1   => v_func_name,
        p_token2   => 'TIME',
        p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
      );

      FEM_ENGINES_PKG.User_Message(
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_203',
        p_token1   => 'FUNC_NAME',
        p_value1   => v_func_name,
        p_token2   => 'TIME',
        p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
      );

    WHEN OTHERS THEN
      ROLLBACK;

      x_retcode := '2';

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_exception,
        p_module   => v_module || '.others',
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
        p_severity => pc_log_level_exception,
        p_module   => v_module || '.others',
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_203',
        p_token1   => 'FUNC_NAME',
        p_value1   => v_func_name,
        p_token2   => 'TIME',
        p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
      );

      FEM_ENGINES_PKG.User_Message(
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_203',
        p_token1   => 'FUNC_NAME',
        p_value1   => v_func_name,
        p_token2   => 'TIME',
        p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS')
      );

  END Run_Transformation;

END FEM_DIS_HIER_PKG;

/
