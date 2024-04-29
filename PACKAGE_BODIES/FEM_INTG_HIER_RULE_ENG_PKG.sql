--------------------------------------------------------
--  DDL for Package Body FEM_INTG_HIER_RULE_ENG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_INTG_HIER_RULE_ENG_PKG" AS
/* $Header: fem_intg_hir_eng.plb 120.25 2008/04/01 06:57:34 rguerrer ship $ */
/***********************************************************************
 *              PACKAGE VARIABLES                                      *
 ***********************************************************************/
  pc_log_level_statement     CONSTANT NUMBER := FND_LOG.level_statement;
  pc_log_level_procedure     CONSTANT NUMBER := FND_LOG.level_procedure;
  pc_log_level_event         CONSTANT NUMBER := FND_LOG.level_event;
  pc_log_level_error         CONSTANT NUMBER := FND_LOG.level_error;
  pc_log_level_unexpected    CONSTANT NUMBER := FND_LOG.level_unexpected;
  pc_api_version             CONSTANT NUMBER := 1.0;
  pv_req_id                  CONSTANT NUMBER := FND_GLOBAL.Conc_Request_Id;
  pv_user_id                 CONSTANT NUMBER := FND_GLOBAL.User_Id;
  pv_login_id                CONSTANT NUMBER := FND_GLOBAL.Login_Id;
  pc_max_disp_len            constant number := 15;
  pc_success                 constant number := 0;
  pc_failure                 constant number := 2;
  v_new_hier_obj_def_created   BOOLEAN         := FALSE;
  pv_new_hier_obj_created      BOOLEAN         := FALSE;
  pv_hier_obj_id               NUMBER;
  pv_hier_rule_obj_name             VARCHAR2(150);
  pv_folder_id                 NUMBER;
  pv_hier_rule_start_date      DATE;
  pv_hier_rule_end_date        DATE;
  pv_dim_mapping_option_code   VARCHAR2(30);
  v_req_id                     NUMBER;
  pv_flatten_hier_flag         VARCHAR2(1);
  pv_sequence_enforced_flag    VARCHAR2(1);
  pv_grp_seq_code	       VARCHAR2(30);
  pv_top_dimension_group_id    NUMBER;
  v_dim_group_seq              NUMBER;
/***********************************************************************
 *              PRIVATE FUNCTIONS                                      *
 ***********************************************************************/
-- ======================================================================
-- Procedure
--     Init
-- Purpose
--     This routine will initailize the package variables.
--  History
--     10-28-04  Jee Kim  Created
--     10-20-05  A.Budnik Modification for MULTISEG case.
-- Arguments
--     p_hier_rule_obj_def_id   The hierarchy rule version to be processed
--     x_completion_code        Completion status of the routine
-- ======================================================================
  PROCEDURE Init (p_hier_rule_obj_def_id IN NUMBER,
                  x_completion_code  OUT NOCOPY NUMBER) IS
     -- Added items below to support the Mulit Segment Hierarchy case ****
    v_Num_hiers                 NUMBER;
    v_aol_vs_id1                NUMBER;
    v_aol_vs_id2                NUMBER;
    v_aol_vs_id3                NUMBER;
    v_aol_vs_id4                NUMBER;
    v_aol_vs_id5                NUMBER;
    v_app_col_name1             varchar2(12);
    v_app_col_name2             varchar2(12);
    v_app_col_name3             varchar2(12);
    v_app_col_name4             varchar2(12);
    v_app_col_name5             varchar2(12);
     -- defined for the traversal array
    CURSOR c_traversal_info is
          SELECT display_order_num,
          application_column_name,
          top_parent_value
          FROM fem_intg_hier_def_segs
    WHERE  hier_rule_obj_def_id = pv_hier_rule_obj_def_id
    ORDER BY display_order_num;
    v_traversal_info c_traversal_info%ROWTYPE;
    l_rec  r_hier_traversal;
    FEM_INTG_fatal_err EXCEPTION;
  BEGIN
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => 'fem.plsql.fem_intg.hier_eng.Init',
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_201',
       p_token1   => 'FUNC_NAME',
       p_value1   => 'FEM_INTG_HIER_RULE_ENG_PKG.Init',
       p_token2   => 'TIME',
       p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
    -- Obtain hierarchy object ID and the latest hierarchy object
    -- definition ID associated with the hierarchy rule definition
    BEGIN
      SELECT nvl(h.hierarchy_obj_id, -1), o.object_name
      INTO   pv_hier_obj_id,
       pv_hier_rule_obj_name
      FROM   fem_object_definition_b b,
             fem_object_catalog_vl o,
             fem_intg_hier_rules h
      WHERE  b.object_definition_id = pv_hier_rule_obj_def_id
      AND    b.object_id = o.object_id
      AND    o.object_id = h.hier_rule_obj_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        pv_hier_obj_id := -1;
    END;
    -- Get hier_obj_def_id if (pv_hier_obj_id <> -1)
    IF (pv_hier_obj_id <> -1) THEN
     BEGIN
     SELECT nvl(hier_obj_def_id,-1)
     INTO pv_hier_obj_def_id
     FROM fem_intg_hier_def_segs
     WHERE hier_rule_obj_def_id = pv_hier_rule_obj_def_id
     AND display_order_num = 1;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          pv_hier_obj_def_id := -1;
      END;
    END IF;
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => 'fem.plsql.fem_intg_hier_rule_eng_pkg',
       p_msg_text => 'pv_hier_obj_id:' || pv_hier_obj_id
                     ||' pv_hier_rule_obj_name:'||pv_hier_rule_obj_name
                     ||' pv_hier_obj_def_id:'||pv_hier_obj_def_id);
     -- Initialize dimension rule related information just for
     -- pv_dim_mapping_option_code. Must be available to do MUlit segment
     -- case below.
     BEGIN
       SELECT DIM_MAPPING_OPTION_CODE
              INTO pv_dim_mapping_option_code
        FROM fem_intg_hier_rules h,
             fem_intg_dim_rule_defs d
        WHERE HIER_RULE_OBJ_ID = pv_hier_rule_obj_id
        AND h.DIM_RULE_OBJ_DEF_ID = d.DIM_RULE_OBJ_DEF_ID;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
           RAISE FEM_INTG_fatal_err;
      END;
       FEM_ENGINES_PKG.Tech_Message
       (p_severity => pc_log_level_statement,
       p_module   => 'fem.plsql.fem_intg_hier_rule_eng_pkg.get_mapping_option',
       p_msg_text => 'pv_dim_mapping_option_code:'||pv_dim_mapping_option_code);
    BEGIN
    CASE
      pv_dim_mapping_option_code
      WHEN 'SINGLESEG' THEN
      SELECT dr.chart_of_accounts_id,
       dr.dimension_id,
       drf.fem_value_set_id,
       seg.top_parent_value,
       v.flex_value_id,
       d.member_vl_object_name,
       d.member_tl_table_name,
       d.member_b_table_name,
       d.member_col,
       d.member_display_code_col,
       d.member_name_col,
       d.member_description_col,
       d.hierarchy_table_name,
       d.attribute_table_name,
       drf.segment_count,
             hir.dim_rule_obj_def_id,
             dr.dim_rule_obj_id,
             v.flex_value_set_id,
             nvl(hir.flatten_hier_flag,'N'),
             nvl(hir.sequence_enforced_flag,'N')
      INTO   pv_coa_id,
       pv_dim_id,
       pv_dim_vs_id,
       pv_top_parent_disp_code,
       pv_top_parent_id,
       pv_dim_memb_vl_obj,
       pv_dim_memb_tl_tab,
       pv_dim_memb_b_tab,
       pv_dim_memb_col,
       pv_dim_memb_disp_col,
       pv_dim_memb_name_col,
       pv_dim_memb_desc_col,
       pv_dim_hier_tab,
       pv_dim_attr_tab,
       pv_segment_count,
             pv_dim_rule_obj_def_id,
             pv_dim_rule_obj_id,
             pv_aol_vs_id,
             pv_flatten_hier_flag,
             pv_sequence_enforced_flag
      FROM   fem_intg_hier_rules hir,
       fem_object_definition_b b1,
       fem_intg_dim_rules dr,
       fem_intg_dim_rule_defs drf,
       fem_intg_hier_def_segs seg,
       fnd_flex_values v,
       fem_xdim_dimensions d,
             fem_intg_aol_valset_map m
      WHERE  hir.hier_rule_obj_id = pv_hier_rule_obj_id
      AND    b1.object_definition_id = hir.dim_rule_obj_def_id
      AND    dr.dim_rule_obj_id = b1.object_id
      AND    drf.dim_rule_obj_def_id = hir.dim_rule_obj_def_id
      AND    seg.hier_rule_obj_def_id = pv_hier_rule_obj_def_id
      AND    drf.fem_value_set_id = m.fem_value_set_id
      AND    v.flex_value_set_id = m.segment1_value_set_id
      AND    v.flex_value = seg.top_parent_value
      AND    d.dimension_id = dr.dimension_id;
      --  11AUG05 For multi segment case *****************
      WHEN 'MULTISEG' THEN
      SELECT distinct dr.chart_of_accounts_id,
       dr.dimension_id,
       drf.fem_value_set_id,
       d.member_vl_object_name,
       d.member_tl_table_name,
       d.member_b_table_name,
       d.member_col,
       d.member_display_code_col,
       d.member_name_col,
       d.member_description_col,
       d.hierarchy_table_name,
       d.attribute_table_name,
       drf.segment_count,
       hir.dim_rule_obj_def_id,
       dr.dim_rule_obj_id,
       m.segment1_value_set_id,
       m.segment2_value_set_id,
       m.segment3_value_set_id,
       m.segment4_value_set_id,
       m.segment5_value_set_id,
       nvl(hir.flatten_hier_flag,'N'),
       nvl(hir.sequence_enforced_flag,'N'),
       drf.application_column_name1,
       drf.application_column_name2,
       drf.application_column_name3,
       drf.application_column_name4,
       drf.application_column_name5
      INTO   pv_coa_id,
       pv_dim_id,
       pv_dim_vs_id,
       pv_dim_memb_vl_obj,
       pv_dim_memb_tl_tab,
       pv_dim_memb_b_tab,
       pv_dim_memb_col,
       pv_dim_memb_disp_col,
       pv_dim_memb_name_col,
       pv_dim_memb_desc_col,
       pv_dim_hier_tab,
       pv_dim_attr_tab,
       pv_segment_count,
       pv_dim_rule_obj_def_id,
       pv_dim_rule_obj_id,
       v_aol_vs_id1,
       v_aol_vs_id2,
       v_aol_vs_id3,
       v_aol_vs_id4,
       v_aol_vs_id5,
       pv_flatten_hier_flag,
       pv_sequence_enforced_flag,
       v_app_col_name1,
       v_app_col_name2,
       v_app_col_name3,
       v_app_col_name4,
       v_app_col_name5
      FROM   fem_intg_hier_rules hir,
       fem_object_definition_b b1,
       fem_intg_dim_rules dr,
       fem_intg_dim_rule_defs drf,
       fem_intg_hier_def_segs seg,
       fnd_flex_values v,
       fem_xdim_dimensions d,
       fem_intg_aol_valset_map m
      WHERE  hir.hier_rule_obj_id = pv_hier_rule_obj_id
      AND    b1.object_definition_id = hir.dim_rule_obj_def_id
      AND    dr.dim_rule_obj_id = b1.object_id
      AND    drf.dim_rule_obj_def_id = hir.dim_rule_obj_def_id
      AND    seg.hier_rule_obj_def_id = pv_hier_rule_obj_def_id
      AND    drf.fem_value_set_id = m.fem_value_set_id
      AND    v.flex_value_set_id = m.segment1_value_set_id
      AND    v.flex_value = seg.top_parent_value
      AND    d.dimension_id = dr.dimension_id;
      if pv_traversal_rarray.count > 0 then
         pv_traversal_rarray.DELETE;
      end if;
      -- Population of pv_traversal_rarray - dispaly_order will overload the fem_intg_dim_hier_gt.hier_obj_def_id
      -- as ID for temporary component hierarchy
      FOR v_traversal_info in c_traversal_info LOOP
      l_rec.display_order   :=  v_traversal_info.display_order_num;
      l_rec.top_parent_value   :=  v_traversal_info.top_parent_value;
      -- Using application_column_name to get value set ID
      SELECT decode(v_traversal_info.application_column_name,
                              v_app_col_name1, v_aol_vs_id1,
                              v_app_col_name2, v_aol_vs_id2,
                              v_app_col_name3, v_aol_vs_id3,
                              v_app_col_name4, v_aol_vs_id4,
                              v_app_col_name5, v_aol_vs_id5,
                              null) INTO l_rec.aol_vs_id FROM DUAL;
      -- Using application_column_name to get dimension segment concatenation order
      SELECT decode(v_traversal_info.application_column_name,
                              v_app_col_name1, 1,
                              v_app_col_name2, 2,
                              v_app_col_name3, 3,
                              v_app_col_name4, 4,
                              v_app_col_name5, 5,
                              null) INTO l_rec.concat_segment FROM DUAL;
      -- Using l_rec.aol_vs_id and l_rec.top_parent_value to get l_rec.top_parent_id
      select flex_value_id into l_rec.top_parent_id
        from fnd_flex_values
        where flex_value_set_id=l_rec.aol_vs_id
        and  flex_value= l_rec.top_parent_value ;
      pv_traversal_rarray.extend;
      pv_traversal_rarray(c_traversal_info%ROWCOUNT) := l_rec;
      v_Num_hiers := c_traversal_info%ROWCOUNT;
      END LOOP;
      FEM_ENGINES_PKG.Tech_Message
       (p_severity => pc_log_level_event,
        p_module   => 'fem.plsql.fem_intg_hier_eng.Init.traversal_rarray_set',
        p_msg_text => ' v_Num_hiers:' || v_num_hiers ||
                     ' pv_dim_mapping_option_code:' || pv_dim_mapping_option_code,
        p_token1   => 'TIME',
        p_value1   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
      -- Mult seg definition only has one sgement
      if v_num_hiers < 2 then
        FEM_ENGINES_PKG.Tech_Message
          (p_severity => pc_log_level_unexpected,
           p_module   => 'fem.plsql.fem_intg_hier_eng.Init.traversal_rarray_set' ,
           p_msg_text => 'Cannot initialize MULTISEG option with < two hierarchies.'
            ||' pv_dim_mapping_option_code:'||pv_dim_mapping_option_code);
        RAISE FEM_INTG_fatal_err;
      end if;
      ELSE
        -- if no MULTISEG or SINGLESEG case then error
        FEM_ENGINES_PKG.Tech_Message
          (p_severity => pc_log_level_unexpected,
           p_module   => 'fem.plsql.fem_intg_hier_eng' ,
           p_msg_text => 'Cannot initialize dimension rule information'
            ||' pv_dim_mapping_option_code:'||pv_dim_mapping_option_code);
        RAISE FEM_INTG_fatal_err;
    END CASE;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        FEM_ENGINES_PKG.Tech_Message
          (p_severity => pc_log_level_unexpected,
           p_module   => 'fem.plsql.fem_intg_hier_eng' ,
           p_msg_text => 'Cannot initialize dimension rule information');
        RAISE FEM_INTG_fatal_err;
    END;
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => 'fem.plsql.fem_intg_hier_rule_eng_pkg',
       p_msg_text => 'pv_coa_id:' || pv_coa_id
                     ||' pv_dim_id:'||pv_dim_id
                     ||' pv_dim_vs_id:'||pv_dim_vs_id
                     ||' pv_aol_vs_id:'||pv_aol_vs_id
                     ||' pv_top_parent_disp_code:'||pv_top_parent_disp_code
                     ||' pv_top_parent_id:'||pv_top_parent_id);
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => 'fem.plsql.fem_intg_hier_rule_eng_pkg',
       p_msg_text => 'pv_dim_memb_vl_obj:'||pv_dim_memb_vl_obj
                     ||' pv_dim_memb_tl_tab:'||pv_dim_memb_tl_tab
                     ||' pv_dim_memb_b_tab:'||pv_dim_memb_b_tab
                     ||' pv_dim_memb_col:'||pv_dim_memb_col
                     ||' pv_dim_memb_disp_col:'||pv_dim_memb_disp_col
                     ||' pv_dim_memb_name_col:'||pv_dim_memb_name_col
                     ||' pv_dim_memb_desc_col:'||pv_dim_memb_desc_col);
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => 'fem.plsql.fem_intg_hier_rule_eng_pkg',
       p_msg_text =>'pv_dim_hier_tab:'||pv_dim_hier_tab
                     ||' pv_dim_attr_tab:'||pv_dim_attr_tab
                     ||' pv_dim_mapping_option_code:'||pv_dim_mapping_option_code
                     ||' pv_segment_count:'||pv_segment_count
                     ||' pv_dim_rule_obj_def_id:'||pv_dim_rule_obj_def_id
                     ||' pv_dim_rule_obj_id:'||pv_dim_rule_obj_id);
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => 'fem.plsql.fem_intg_hier_rule_eng_pkg',
       p_msg_text => 'pv_hier_rule_start_date:' ||pv_hier_rule_start_date
                     ||' pv_hier_rule_end_date:'||pv_hier_rule_end_date);
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => 'fem.plsql.fem_intg_hier_rule_eng_pkg',
       p_msg_text => 'pv_flatten_hier_flag:' ||pv_flatten_hier_flag);
     -- Initialize global value set combo ID
    BEGIN
      SELECT global_vs_combo_id
      INTO   pv_gvsc_id
      FROM   fem_intg_coa_gvsc_map
      WHERE  chart_of_accounts_id = pv_coa_id
      AND    effective_start_date <= pv_hier_rule_start_date
      AND    effective_end_date >= pv_hier_rule_end_date;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        FEM_ENGINES_PKG.Tech_Message
          (p_severity => pc_log_level_unexpected,
           p_module   => 'fem.plsql.fem_intg_hier_eng' ,
           p_msg_text => 'Cannot find Global Value Set Combination');
        RAISE FEM_INTG_fatal_err;
    END;
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => 'fem.plsql.fem_intg_hier_rule_eng_pkg',
       p_msg_text => 'pv_gvsc_id:'||pv_gvsc_id);
    -- Initialize the variables requred for FEM_INTG_DIM_RULE_ENG_PKG.Init
    FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_rule_obj_id := pv_dim_rule_obj_id;
    FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_rule_obj_def_id := pv_dim_rule_obj_def_id;
    FEM_INTG_DIM_RULE_ENG_PKG.Init;
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => 'fem.plsql.fem_intg_hier_eng.Init.',
       p_msg_text => ' pv_dim_varchar_label:' || FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_varchar_label);
    x_completion_code := 0;
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => 'fem.plsql.fem_intg_hier_eng.init.',
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_202',
       p_token1   => 'FUNC_NAME',
       p_value1   => 'FEM_INTG_HIER_RULE_ENG_PKG.Init',
       p_token2   => 'TIME',
       p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
    return;
  EXCEPTION
    WHEN FEM_INTG_fatal_err THEN
      ROLLBACk;
      FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_unexpected,
       p_module   => 'fem.plsql.fem_intg_hier_eng.init.'||'exception ',
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
   p_module   => 'fem.plsql.fem_intg_hier_eng.init.'||'exception ',
   p_app_name => 'FEM',
   p_msg_name => 'FEM_GL_POST_203',
   p_token1   => 'FUNC_NAME',
   p_value1   => 'FEM_INTG_HIER_RULE_ENG_PKG.Init',
   p_token2   => 'TIME',
   p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
      x_completion_code := 2;
      return;
    WHEN OTHERS THEN
      ROLLBACK;
      --raise;
      FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_unexpected,
       p_module   => 'fem.plsql.fem_intg_hier_eng.init.' ||'exception others',
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_215',
       p_token1   => 'ERR_MSG',
       p_value1   => SQLERRM);
      FEM_ENGINES_PKG.Tech_Message
  (p_severity => pc_log_level_procedure,
   p_module   => 'fem.plsql.fem_intg_hier_eng.init.' || '',
   p_app_name => 'FEM',
   p_msg_name => 'FEM_GL_POST_203',
   p_token1   => 'FUNC_NAME',
   p_value1   => 'FEM_INTG_HIER_RULE_ENG_PKG.Init',
   p_token2   => 'TIME',
   p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
      x_completion_code := 2;
      return;
  END Init;
-- ======================================================================
-- Procedure
--     Bld_Hier_Single_Segment
-- Purpose
--     This routine will populate the global temporary hierarchy table
--     with hierarchical information based on the starting parent value
--     and the mapped segment in the selected hierarchy rule. It is also
--     responsible for calling routines to create new parent members and
--     to populate their attributes.
-- History
--     10-28-04  Jee Kim  Created
-- Arguments
--     x_completion_code        Completion status of the routine
--     x_row_count_tot          Number of records inserted
-- ======================================================================
  PROCEDURE Bld_Hier_Single_Segment
                (x_completion_code  OUT NOCOPY NUMBER,
                 x_row_count_tot OUT NOCOPY NUMBER) IS
    FEM_INTG_fatal_err EXCEPTION;
    v_msg_count                 NUMBER;
    v_msg_data                  VARCHAR2(4000);
    v_API_return_status         VARCHAR2(30);
    v_row_count                 NUMBER;
    v_row_count2                NUMBER;
    v_row_count3                NUMBER;
    v_parent_level              NUMBER;
    v_seq_name                  VARCHAR2(30);
    v_seq_stmt                  VARCHAR2(2000);
    v_sql_stmt                  VARCHAR2(2000);
    v_compl_code                NUMBER;
    v_dimension_group_id        NUMBER;
    v_dim_group_name_seq        NUMBER;
    v_rel_dim_group_seq         NUMBER;
  BEGIN
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => 'fem.plsql.fem_intg.hier_eng.Bld_Hier_Single_Segment',
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_201',
       p_token1   => 'FUNC_NAME',
       p_value1   => 'FEM_INTG_HIER_RULE_ENG_PKG.Bld_Hier_Single_Segment',
       p_token2   => 'TIME',
       p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
    x_completion_code  := 0;
    x_row_count_tot := 0;
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => 'fem.plsql.fem_intg_hier_eng.Bld_Hier_Single_Segment.',
       p_msg_text => ' pv_hier_obj_def_id:' || pv_hier_obj_def_id ||
                     ' pv_top_parent_id:' || pv_top_parent_id ||
                     ' pv_top_parent_disp_code:' || pv_top_parent_disp_code);

    -- Insert self mapping record for hierarchy top node into the _GT table
    INSERT INTO fem_intg_dim_hier_gt
      (hierarchy_obj_def_id,
       parent_depth_num,
       parent_id,
       parent_display_code,
       child_depth_num,
       child_id,
       child_display_code,
       single_depth_flag,
       display_order_num,
       dimension_group_id)
    VALUES
      (pv_hier_obj_def_id,
       1,
       pv_top_parent_id,
       pv_top_parent_disp_code,
       1,
       pv_top_parent_id,
       pv_top_parent_disp_code,
       'Y',
       1,
       pv_top_dimension_group_id);



    v_row_count := SQL%ROWCOUNT;
    x_row_count_tot :=  x_row_count_tot + v_row_count;
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => 'fem.plsql.fem_intg_hier_eng.row_count.',
       p_msg_text => 'v_row_count:' || v_row_count ||
                     ' x_row_count_tot:' || x_row_count_tot);
    COMMIT;
    v_parent_level := 1;
    v_seq_name := 'FEM_INTG_HIER_SEQ_' || pv_req_id || '_S';
    v_seq_stmt := 'CREATE SEQUENCE '||v_seq_name||' START WITH 2';
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => 'fem.plsql.fem_intg_hier_eng.Bld_Hier_Single_Segment.',
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'v_seq_stmt',
       p_token2   => 'VAR_VAL',
       p_value2   => v_seq_stmt);
    EXECUTE IMMEDIATE v_seq_stmt;

    COMMIT;
    -- Infinite loop to insert immediate children for each parent member.
    -- Only children who are themselves parenet values will be inserted here.
    -- The exit condition is when the inserted number of row is 0
    LOOP
      -- to create level-based hierarchy
      v_dim_group_name_seq := (v_parent_level+1)*100;
      FEM_ENGINES_PKG.Tech_Message
  (p_severity => pc_log_level_procedure,
   p_module   => 'fem.plsql.fem_intg_hier_eng.Infinite loop.',
   p_msg_text => 'v_dim_group_name_seq:' || v_dim_group_name_seq);
 -- Call API to create new dimension group
  --dedutta : 5035567 : if check for pv_sequence_enforced_flag
  IF (pv_sequence_enforced_flag = 'Y') THEN
    FEM_DIM_GROUPS_UTIL_PKG.create_dim_group
       (x_return_status        => v_API_return_status,
        x_msg_count            => v_msg_count,
        x_msg_data             => v_msg_data,
        p_encoded              => FND_API.G_FALSE,
        p_init_msg_list        => FND_API.G_TRUE,
        x_dimension_group_id   => v_dimension_group_id,
        x_dim_group_sequence   => v_dim_group_seq,
        p_dimension_varchar_label  =>
        FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_varchar_label,
        p_dim_group_name           =>
        FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_varchar_label ||' '|| v_dim_group_name_seq,
        p_dim_group_display_code   =>
        FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_varchar_label ||' '|| v_dim_group_name_seq,
        p_dim_group_description    =>
        FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_varchar_label ||' '|| v_dim_group_name_seq);
  END IF;

   FEM_ENGINES_PKG.Tech_Message
  (p_severity => pc_log_level_procedure,
   p_module   => 'fem.plsql.fem_intg_hier_eng.Infinite loop.',
   p_msg_text => 'v_dimension_group_id:' || v_dimension_group_id);
      IF (v_API_return_status NOT IN  ('S')) THEN
    FEM_ENGINES_PKG.Tech_Message
    (p_severity => pc_log_level_statement,
     p_module   => 'fem.plsql.fem_intg_hier_rule_eng_pkg.'||'return_status',
     p_msg_text => 'v_API_return_status:' || v_API_return_status);
        FEM_ENGINES_PKG.Tech_Message
          (p_severity => pc_log_level_statement,
     p_module   => 'fem.plsql.fem_intg_hier_rule_eng_pkg.'||'After create_dim_group',
           p_msg_text => 'v_msg_data:' || v_msg_data);
  FEM_ENGINES_PKG.User_Message
    (p_app_name => 'FEM',
     p_msg_text => v_msg_data);
  FEM_ENGINES_PKG.User_Message
    (p_app_name => 'FEM',
     p_msg_name => 'FEM_INTG_FAIL_DIM_GRP');
  RAISE FEM_INTG_fatal_err;
      END IF;
      FEM_ENGINES_PKG.Tech_Message
  (p_severity => pc_log_level_procedure,
   p_module   => 'fem.plsql.fem_intg_hier_eng.Infinite loop.',
   p_msg_text => 'pv_hier_obj_def_id:' || pv_hier_obj_def_id ||
                       ' v_parent_level:' || v_parent_level ||
                       ' pv_dim_vs_id:' || pv_dim_vs_id);
      -- Insert immediate children for each parent into the _GT table
      v_sql_stmt :=
  'INSERT INTO fem_intg_dim_hier_gt
     (hierarchy_obj_def_id,
      parent_depth_num,
      parent_id,
      parent_display_code,
      child_depth_num,
      child_id,
      child_display_code,
      single_depth_flag,
      display_order_num,
            dimension_group_id)
   SELECT DISTINCT :pv_hier_obj_def_id,
      gt.child_depth_num,
      gt.child_id,
      gt.child_display_code,
      (gt.child_depth_num + 1),
      ff.flex_value_id,
      ff.flex_value,
      ''Y'',
            -1,
            :v_dimension_group_id
   FROM fem_intg_dim_hier_gt gt,
        fnd_flex_value_norm_hierarchy vh,
        fnd_flex_values ff
   WHERE gt.child_depth_num = :v_parent_level
   AND   vh.flex_value_set_id = :pv_aol_vs_id
   AND   vh.parent_flex_value = gt.child_display_code
   AND   vh.range_attribute = ''P''
   AND   ff.flex_value_set_id = :pv_aol_vs_id
   AND   ff.summary_flag = ''Y''
   AND   ff.flex_value
   BETWEEN vh.child_flex_value_low
   AND   vh.child_flex_value_high
   ORDER BY ff.flex_value';
       FEM_ENGINES_PKG.Tech_Message
   (p_severity => pc_log_level_procedure,
    p_module   => 'fem.plsql.fem_intg_hier_eng.Bld_Hier_Single_Segment.',
    p_app_name => 'FEM',
    p_msg_name => 'FEM_GL_POST_204',
    p_token1   => 'VAR_NAME',
    p_value1   => 'v_sql_stmt',
    p_token2   => 'VAR_VAL',
    p_value2   => v_sql_stmt);

      EXECUTE IMMEDIATE v_sql_stmt
              USING pv_hier_obj_def_id,
                    v_dimension_group_id,
                    v_parent_level,
                    pv_aol_vs_id,
                    pv_aol_vs_id;
      v_row_count2 := SQL%ROWCOUNT;


      x_row_count_tot :=  x_row_count_tot + v_row_count2;
      COMMIT;
      FEM_ENGINES_PKG.Tech_Message
  (p_severity => pc_log_level_procedure,
   p_module   => 'fem.plsql.fem_intg_hier_eng.row_count.',
   p_msg_text => 'v_row_count2:' || v_row_count2 ||
                       ' x_row_count_tot:' || x_row_count_tot);
      -- update the display_order num. Not handled in above insert statement
      -- because the distinct not allowed with nextval.
      v_sql_stmt :=
  'UPDATE fem_intg_dim_hier_gt
         SET display_order_num = '||v_seq_name||'.nextval
         WHERE rowid in
               (select rowid
                from fem_intg_dim_hier_gt)
         AND display_order_num = -1';


       FEM_ENGINES_PKG.Tech_Message
   (p_severity => pc_log_level_procedure,
    p_module   => 'fem.plsql.fem_intg_hier_eng.Bld_Hier_Single_Segment.seq.nextval',
    p_app_name => 'FEM',
    p_msg_name => 'FEM_GL_POST_204',
    p_token1   => 'VAR_NAME',
    p_value1   => 'v_sql_stmt',
    p_token2   => 'VAR_VAL',
    p_value2   => v_sql_stmt);
      EXECUTE IMMEDIATE v_sql_stmt;

      -- When no more row is inserted, Exit the loop
      IF (v_row_count2 = 0) THEN
        EXIT;
      END IF;
      IF (pv_new_hier_obj_created) THEN
  v_rel_dim_group_seq := v_parent_level+1;
  FEM_ENGINES_PKG.Tech_Message
    (p_severity => pc_log_level_statement,
     p_module   => 'fem.plsql.'||'insert into fem_hier_dimension_grps',
     p_msg_text => 'v_dimension_group_id:' || v_dimension_group_id ||
       ' v_rel_dim_group_seq:' || v_rel_dim_group_seq);
  -- insert the new level to fem_hier_dimension_grps
  --dedutta : 5035567 : if check for pv_sequence_enforced_flag
  IF (pv_sequence_enforced_flag = 'Y') THEN
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
     (v_dimension_group_id,
      pv_hier_obj_id,
      v_rel_dim_group_seq,
      sysdate,
      pv_user_id,
      pv_user_id,
      sysdate,
      pv_login_id,
      1);
    END IF;
      END IF;
      FEM_ENGINES_PKG.Tech_Message
  (p_severity => pc_log_level_procedure,
   p_module   => 'fem.plsql.fem_intg_hier_eng.',
   p_msg_text => 'v_parent_level :' || v_parent_level );
      v_parent_level := v_parent_level + 1;
    END LOOP;
    COMMIT;
    FEM_INTG_NEW_DIM_MEMBER_PKG.Create_Parent_Members(
      x_completion_code                => v_compl_code);
    IF (v_compl_code = 2) THEN
       RAISE FEM_INTG_fatal_err;
    END IF;
    -- to create level-based hierarchy for bottom level children
    v_dim_group_name_seq := (v_parent_level+1)*100;
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => 'fem.plsql.fem_intg_hier_eng.Infinite loop.',
       p_msg_text => 'v_dim_group_name_seq:' || v_dim_group_name_seq);
 -- Call API to create new dimension group
 --dedutta : 5035567 : if check for pv_sequence_enforced_flag
    IF (pv_sequence_enforced_flag = 'Y') THEN
      FEM_DIM_GROUPS_UTIL_PKG.create_dim_group
      (x_return_status        => v_API_return_status,
       x_msg_count            => v_msg_count,
       x_msg_data             => v_msg_data,
       p_encoded              => FND_API.G_FALSE,
       p_init_msg_list        => FND_API.G_TRUE,
       x_dimension_group_id   => v_dimension_group_id,
       x_dim_group_sequence   => v_dim_group_seq,
       p_dimension_varchar_label  =>
       FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_varchar_label,
       p_dim_group_name           =>
       FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_varchar_label ||' '|| v_dim_group_name_seq,
       p_dim_group_display_code   =>
       FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_varchar_label ||' '|| v_dim_group_name_seq,
       p_dim_group_description    =>
       FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_varchar_label ||' '|| v_dim_group_name_seq);
    END IF;

    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => 'fem.plsql.fem_intg_hier_eng.',
       p_msg_text => 'v_dimension_group_id:' || v_dimension_group_id);
    IF (v_API_return_status NOT IN  ('S')) THEN
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_statement,
         p_module   => 'fem.plsql.fem_intg_hier_rule_eng_pkg.'||'return_status',
         p_msg_text => 'v_API_return_status:' || v_API_return_status);
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_statement,
         p_module   => 'fem.plsql.fem_intg_hier_rule_eng_pkg.'||'After create_dim_group',
         p_msg_text => 'v_msg_data:' || v_msg_data);
      FEM_ENGINES_PKG.User_Message
        (p_app_name => 'FEM',
         p_msg_text => v_msg_data);
      FEM_ENGINES_PKG.User_Message
        (p_app_name => 'FEM',
         p_msg_name => 'FEM_INTG_FAIL_DIM_GRP');
      RAISE FEM_INTG_fatal_err;
    END IF;
    IF (pv_new_hier_obj_created) THEN
      v_rel_dim_group_seq := v_parent_level+1 ;
      FEM_ENGINES_PKG.Tech_Message
  (p_severity => pc_log_level_statement,
   p_module   => 'fem.plsql.'||'insert into fem_hier_dimension_grps',
   p_msg_text => 'v_dimension_group_id:' || v_dimension_group_id ||
           ' v_rel_dim_group_seq:' || v_rel_dim_group_seq);
  -- insert the new level to fem_hier_dimension_grps
  --dedutta : 5035567 : if check for pv_sequence_enforced_flag
  IF (pv_sequence_enforced_flag = 'Y') THEN
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
  (v_dimension_group_id,
   pv_hier_obj_id,
   v_rel_dim_group_seq,
   sysdate,
   pv_user_id,
   pv_user_id,
   sysdate,
   pv_login_id,
   1);
  END IF;
  END IF;

    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => 'fem.plsql.fem_intg_hier_eng.Bld_Hier_Single_Segment.',
       p_msg_text => 'pv_hier_obj_def_id:' || pv_hier_obj_def_id ||
                     ' pv_dim_memb_col:' ||pv_dim_memb_col ||
                     ' pv_dim_memb_disp_col:' || pv_dim_memb_disp_col||
                     ' pv_dim_memb_b_tab:' ||pv_dim_memb_b_tab ||
                     ' pv_dim_vs_id:' || pv_dim_vs_id||
                     ' pv_dim_memb_disp_col:' ||pv_dim_memb_disp_col);

    -- insert all bottom level detail children
    --dedutta : 5035567 : introduced the bind variable dgid
    v_sql_stmt :=
      'INSERT INTO fem_intg_dim_hier_gt
         (hierarchy_obj_def_id,
    parent_depth_num,
    parent_id,
    parent_display_code,
    child_depth_num,
    child_id,
    child_display_code,
      single_depth_flag,
      display_order_num,
          dimension_group_id)
       SELECT DISTINCT '
    ||pv_hier_obj_def_id||',
          gt.child_depth_num,
    gt.child_id,
    gt.child_display_code,
    (gt.child_depth_num + 1),
          m.'||pv_dim_memb_col||',
    m.'||pv_dim_memb_disp_col||',
    ''Y'',
          -1,
           :dgid
       FROM fem_intg_dim_hier_gt gt,
      fnd_flex_value_norm_hierarchy vh,
            '||pv_dim_memb_b_tab||' m
       WHERE vh.flex_value_set_id = '||pv_aol_vs_id||'
       AND   vh.parent_flex_value = gt.child_display_code
       AND   vh.range_attribute = ''C''
       AND   m.value_set_id = '||pv_dim_vs_id||'
       AND   m.'||pv_dim_memb_disp_col||'
             BETWEEN vh.child_flex_value_low AND vh.child_flex_value_high
       AND   m.'||pv_dim_memb_col||' NOT IN
             (SELECT inner_gt.child_id
              FROM fem_intg_dim_hier_gt inner_gt)
       AND   m.'||pv_dim_memb_col||' NOT IN
             (SELECT mh.parent_id
              FROM '||pv_dim_hier_tab||' mh,
                   fem_object_definition_b odb,
                   fem_intg_hier_rules ihr
              WHERE mh.hierarchy_obj_def_id = odb.object_definition_id
              AND   odb.object_id = ihr.hierarchy_obj_id
              AND   ihr.dim_rule_obj_def_id = '||pv_dim_rule_obj_def_id||'
              AND   mh.parent_value_set_id = '||pv_dim_vs_id||'
              AND   mh.child_value_set_id = '||pv_dim_vs_id||'
              AND   mh.child_id <> mh.parent_id)
       ORDER BY m.'||pv_dim_memb_disp_col;



    v_row_count3 := SQL%ROWCOUNT;
    x_row_count_tot :=  x_row_count_tot + v_row_count3;
     FEM_ENGINES_PKG.Tech_Message
   (p_severity => pc_log_level_procedure,
    p_module   => 'fem.plsql.fem_intg_hier_eng.Bld_Hier_Single_Segment',
    p_app_name => 'FEM',
    p_msg_name => 'FEM_GL_POST_204',
    p_token1   => 'VAR_NAME',
    p_value1   => 'v_sql_stmt',
    p_token2   => 'VAR_VAL',
    p_value2   => v_sql_stmt);
    EXECUTE IMMEDIATE v_sql_stmt using v_dimension_group_id;
    COMMIT;
    --  update the display_order num. Not handled in above insert statement
    -- because the distinct not allowed with nextval.
    v_sql_stmt :=
  'UPDATE fem_intg_dim_hier_gt
         SET display_order_num = '||v_seq_name||'.nextval
         WHERE rowid in
               (select rowid
                from fem_intg_dim_hier_gt)
         AND display_order_num = -1';
     FEM_ENGINES_PKG.Tech_Message
   (p_severity => pc_log_level_procedure,
    p_module   => 'fem.plsql.fem_intg_hier_eng.Bld_Hier_Single_Segment.seq.nextval',
    p_app_name => 'FEM',
    p_msg_name => 'FEM_GL_POST_204',
    p_token1   => 'VAR_NAME',
    p_value1   => 'v_sql_stmt',
    p_token2   => 'VAR_VAL',
    p_value2   => v_sql_stmt);
    EXECUTE IMMEDIATE v_sql_stmt;
    v_seq_stmt := 'DROP SEQUENCE ' || v_seq_name;
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => 'fem.plsql.fem_intg_hier_eng.Bld_Hier_Single_Segment',
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'v_seq_stmt',
       p_token2   => 'VAR_VAL',
       p_value2   => v_seq_stmt);
    EXECUTE IMMEDIATE v_seq_stmt;
    COMMIT;
    x_completion_code := 0;
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => 'fem.plsql.fem_intg_hier_eng.Bld_Hier_Single_Segment.',
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_202',
       p_token1   => 'FUNC_NAME',
       p_value1   => 'FEM_INTG_HIER_RULE_ENG_PKG.Bld_Hier_Single_Segment',
       p_token2   => 'TIME',
       p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
    return;
  EXCEPTION
    WHEN FEM_INTG_fatal_err THEN
      ROLLBACk;
      FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_unexpected,
       p_module   => 'fem.plsql.fem_intg_hier_eng.Bld_Hier_Single_Segment.' ||'FEM_INTG_fatal_err',
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
   p_module   => 'fem.plsql.fem_intg_hier_eng.Bld_Hier_Single_Segment.' || 'FEM_INTG_fatal_err',
   p_app_name => 'FEM',
   p_msg_name => 'FEM_GL_POST_203',
   p_token1   => 'FUNC_NAME',
   p_value1   => 'FEM_INTG_HIER_RULE_ENG_PKG.Bld_Hier_Single_Segment',
   p_token2   => 'TIME',
   p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
      x_completion_code := 2;
      return;
    WHEN OTHERS THEN
      ROLLBACK;
      IF (v_seq_name IS NOT NULL) THEN
  v_seq_stmt := 'DROP SEQUENCE ' || v_seq_name;
  FEM_ENGINES_PKG.Tech_Message
    (p_severity => pc_log_level_procedure,
     p_module   => 'fem.plsql.fem_intg_hier_eng.Bld_Hier_Single_Segment.'
                         || 'exceptoin others',
     p_app_name => 'FEM',
     p_msg_name => 'FEM_GL_POST_204',
     p_token1   => 'VAR_NAME',
     p_value1   => 'v_seq_stmt',
     p_token2   => 'VAR_VAL',
     p_value2   => v_seq_stmt);
  EXECUTE IMMEDIATE v_seq_stmt;
        COMMIT;
      END IF;
      FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_unexpected,
       p_module   => 'fem.plsql.fem_intg_hier_eng.Bld_Hier_Single_Segment.' || 'exceptoin others',
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
   p_module   => 'fem.plsql.fem_intg_hier_eng.Bld_Hier_Single_Segment.' || 'exceptoin others',
   p_app_name => 'FEM',
   p_msg_name => 'FEM_GL_POST_203',
   p_token1   => 'FUNC_NAME',
   p_value1   => 'FEM_INTG_HIER_RULE_ENG_PKG.Bld_Hier_Single_Segment',
   p_token2   => 'TIME',
   p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
      x_completion_code := 2;
      return;
  END Bld_Hier_Single_Segment;
-- ======================================================================
-- Procedure
--     Bld_Component_Hiers
-- Purpose
--     Populates the fem_intg_dim_hier_gt table with each single segement
--     hierarchy to be used as base components for to build the
--     mult segment concatenatned hierarchy.
--     The selected Multi Segment hierarchy rule is the driving defintion.
--     Uses PL/SQL table tr_hier_traversal to do this.
-- History
--     08-03-05  A. Budnik  Created
-- Arguments
--     x_completion_code        Completion status of the routine
-- ======================================================================
  PROCEDURE Bld_Component_Hiers
                (x_completion_code  OUT NOCOPY NUMBER) IS
    FEM_INTG_fatal_err EXCEPTION;
    v_row_count             NUMBER;
    v_row_count2          NUMBER;
    v_row_count3                NUMBER;
    v_parent_level          NUMBER;
    v_Num_hiers                 NUMBER;
    v_aol_vs_id                 number;
    v_sumcol      varchar2(30);
    v_seq_name                  VARCHAR2(30);
    v_duplicate_parent          VARCHAR2(12);
    V_summary             varchar2(2000);
    v_seq_stmt                  VARCHAR2(2000);
    v_sql_stmt                  VARCHAR2(2000);
    i_hier_ctr                  number;
    i_concat                    number;
    V_sql_stmt_start            VARCHAR2(4000);
    V_sql_stmt_end              VARCHAR2(4000);
    v_add_where                 VARCHAR2(4000);
    V_where                     VARCHAR2(4000);

    -- bug fix 4563603
    v_display_code                VARCHAR2(150);
    v_parent_display_code         VARCHAR2(150);
    v_offending_parents_list      VARCHAR2(4000);

    TYPE ReferenceCursor IS REF CURSOR;

    c_child_of_multi_parent ReferenceCursor;
    c_multi_parent ReferenceCursor;

    -- bug fix 4563603

  BEGIN

   FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => 'fem.plsql.fem_intg.hier_eng.Bld_Component_Hier',
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_201',
       p_token1   => 'FUNC_NAME',
       p_value1   => 'FEM_INTG_HIER_RULE_ENG_PKG.Bld_Component_Hier',
       p_token2   => 'TIME',
       p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
       x_completion_code  := 0;

   FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => 'fem.plsql.fem_intg_hier_eng.Bld_Component_Hier.Dimension_Init.',
       p_msg_text => ' pv_hier_obj_def_id:' || pv_hier_obj_def_id ||
                     ' pv_dim_rule_obj_id:' || pv_dim_rule_obj_id ||
                     ' pv_dim_rule_obj_def_id:' || pv_dim_rule_obj_def_id ||
                     ' pv_dim_id:' || pv_dim_id ||
                     ' pv_coa_id' || pv_coa_id);

    -- run intialize dimension package variables
    -- sets up pv_mapped_segs structure which is used below.
    FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_rule_obj_id := pv_dim_rule_obj_id;
    FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_rule_obj_def_id := pv_dim_rule_obj_def_id;
    FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_id := pv_dim_id;
    FEM_INTG_DIM_RULE_ENG_PKG.pv_coa_id := pv_coa_id;

    -- bug 4752271 - Add code to populate the company and cost center
    -- dimension and value set id values.
    IF pv_dim_id = 8 THEN

      SELECT dimension_id
      INTO FEM_INTG_DIM_RULE_ENG_PKG.pv_com_dim_id
      FROM fem_dimensions_b
      WHERE dimension_varchar_label = 'COMPANY';

      SELECT dimension_id
      INTO FEM_INTG_DIM_RULE_ENG_PKG.pv_cc_dim_id
      FROM fem_dimensions_b
      WHERE dimension_varchar_label = 'COST_CENTER';

      SELECT value_set_id
      INTO FEM_INTG_DIM_RULE_ENG_PKG.pv_com_vs_id
      FROM fem_global_vs_combo_defs
      WHERE global_vs_combo_id = pv_gvsc_id
      AND   dimension_id = FEM_INTG_DIM_RULE_ENG_PKG.pv_com_dim_id;

      SELECT value_set_id
      INTO FEM_INTG_DIM_RULE_ENG_PKG.pv_cc_vs_id
      FROM fem_global_vs_combo_defs
      WHERE global_vs_combo_id = pv_gvsc_id
      AND   dimension_id = FEM_INTG_DIM_RULE_ENG_PKG.pv_cc_dim_id;

    END IF;

    FEM_INTG_DIM_RULE_ENG_PKG.Init;

    -- loop and buid each component hierarchy based on
    -- pv_traversal_rarray which is base on hier rule definition
    i_hier_ctr := pv_traversal_rarray.first;

    while i_hier_ctr is not null
    loop

        -- Mapping pv_traversal_rarray to  .pv_mapped_segs()
        i_Concat := pv_traversal_rarray(i_hier_ctr).concat_segment;
        v_aol_vs_id  :=  pv_traversal_rarray(i_hier_ctr).aol_vs_id;

        -- these should be the same or there are rule definition inconsistencies
        if pv_traversal_rarray(i_hier_ctr).aol_vs_id  <>
            FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(i_Concat).vs_id THEN

           -- set messages and have fatial error.
           FEM_ENGINES_PKG.Tech_Message
              (p_severity => pc_log_level_unexpected,
               p_module   => 'fem.plsql.fem_intg_hier_eng.Bld_Component_Hier.VSID_MISSMATCH.' ,
               p_msg_text => 'Structure pv_mapped_segs().vs_id does not correspond to pv_traversal_rarray().aol_vs_id');
           RAISE FEM_INTG_fatal_err;

         else

           -- Insert top node
           FEM_ENGINES_PKG.Tech_Message
             (p_severity => pc_log_level_procedure,
              p_module   => 'fem.plsql.fem_intg_hier_eng.Bld_Component_Hier.Main_Loop.',
              p_msg_text => ' pv_hier_obj_def_id:' || pv_hier_obj_def_id ||
              ' traversal display_order:' || pv_traversal_rarray(i_hier_ctr).display_order ||
              ' traversal top_parent_id:' || pv_traversal_rarray(i_hier_ctr).top_parent_id ||
              ' traversal top_parent_disp_code:' || pv_traversal_rarray(i_hier_ctr).top_parent_value);


           CASE pv_traversal_rarray(i_hier_ctr).display_order
             WHEN 1 THEN
               INSERT INTO fem_intg_dim_hier_c1_gt
               (parent_depth_num,
                parent_id,
                parent_display_code,
                child_depth_num,
                child_id,
                child_display_code,
                single_depth_flag,
                display_order_num,
                child_leaf_flag)
               VALUES
                (1,
                 pv_traversal_rarray(i_hier_ctr).top_parent_id,
                 pv_traversal_rarray(i_hier_ctr).top_parent_value,
                 1,
                 pv_traversal_rarray(i_hier_ctr).top_parent_id,
                 pv_traversal_rarray(i_hier_ctr).top_parent_value,
                 'Y',
                 1,
                 'N');

             WHEN 2 THEN
               INSERT INTO fem_intg_dim_hier_c2_gt
               (parent_depth_num,
                parent_id,
                parent_display_code,
                child_depth_num,
                child_id,
                child_display_code,
                single_depth_flag,
                display_order_num,
                child_leaf_flag)
               VALUES
                (1,
                 pv_traversal_rarray(i_hier_ctr).top_parent_id,
                 pv_traversal_rarray(i_hier_ctr).top_parent_value,
                 1,
                 pv_traversal_rarray(i_hier_ctr).top_parent_id,
                 pv_traversal_rarray(i_hier_ctr).top_parent_value,
                 'Y',
                 1,
                 'N');

             WHEN 3 THEN
               INSERT INTO fem_intg_dim_hier_c3_gt
               (parent_depth_num,
                parent_id,
                parent_display_code,
                child_depth_num,
                child_id,
                child_display_code,
                single_depth_flag,
                display_order_num,
                child_leaf_flag)
               VALUES
                (1,
                 pv_traversal_rarray(i_hier_ctr).top_parent_id,
                 pv_traversal_rarray(i_hier_ctr).top_parent_value,
                 1,
                 pv_traversal_rarray(i_hier_ctr).top_parent_id,
                 pv_traversal_rarray(i_hier_ctr).top_parent_value,
                 'Y',
                 1,
                 'N');

             WHEN 4 THEN
               INSERT INTO fem_intg_dim_hier_c4_gt
               (parent_depth_num,
                parent_id,
                parent_display_code,
                child_depth_num,
                child_id,
                child_display_code,
                single_depth_flag,
                display_order_num,
                child_leaf_flag)
               VALUES
                (1,
                 pv_traversal_rarray(i_hier_ctr).top_parent_id,
                 pv_traversal_rarray(i_hier_ctr).top_parent_value,
                 1,
                 pv_traversal_rarray(i_hier_ctr).top_parent_id,
                 pv_traversal_rarray(i_hier_ctr).top_parent_value,
                 'Y',
                 1,
                 'N');

             WHEN 5 THEN
               INSERT INTO fem_intg_dim_hier_c5_gt
               (parent_depth_num,
                parent_id,
                parent_display_code,
                child_depth_num,
                child_id,
                child_display_code,
                single_depth_flag,
                display_order_num,
                child_leaf_flag)
               VALUES
                (1,
                 pv_traversal_rarray(i_hier_ctr).top_parent_id,
                 pv_traversal_rarray(i_hier_ctr).top_parent_value,
                 1,
                 pv_traversal_rarray(i_hier_ctr).top_parent_id,
                 pv_traversal_rarray(i_hier_ctr).top_parent_value,
                 'Y',
                 1,
                 'N');

           END CASE; -- End initial insert

           v_row_count := SQL%ROWCOUNT;

           FEM_ENGINES_PKG.Tech_Message
             (p_severity => pc_log_level_procedure,
             p_module   => 'fem.plsql.fem_intg_hier_eng.Bld_Component_Hier.row_count.',
             p_msg_text => 'traversal hierarchy_obj_def_id:' || pv_traversal_rarray(i_hier_ctr).display_order ||
                     ' v_row_count:' || v_row_count);

           -- insert intermediate nodes  LOOP!
           -- loop to insert immediate children for each parent member.
           -- Only children who are themselves parenet values will be inserted here.
           -- The exit condition is when the inserted number of row is 0
           v_parent_level := 1;
           v_seq_name := 'FEM_INTG_HIER_SEQ_' || pv_req_id || '_S';
           v_seq_stmt := 'CREATE SEQUENCE '||v_seq_name||' START WITH 2';

           FEM_ENGINES_PKG.Tech_Message
            (p_severity => pc_log_level_procedure,
            p_module   => 'fem.plsql.fem_intg_hier_eng.Bld_Component_Hier.',
            p_app_name => 'FEM',
            p_msg_name => 'FEM_GL_POST_204',
            p_token1   => 'VAR_NAME',
            p_value1   => 'v_seq_stmt',
            p_token2   => 'VAR_VAL',
            p_value2   => v_seq_stmt);
           EXECUTE IMMEDIATE v_seq_stmt;

        -- Insert immediate children for each parent into the _GT table
        LOOP

          FEM_ENGINES_PKG.Tech_Message
               (p_severity => pc_log_level_procedure,
                 p_module   => 'fem.plsql.fem_intg_hier_eng.Bld_Component_Hier.Intermediate_Loop.',
                 p_msg_text => 'pv_hier_obj_def_id:' || pv_hier_obj_def_id ||
                 ' traversal hierarchy_obj_def_id:' || pv_traversal_rarray(i_hier_ctr).display_order ||
                 ' v_parent_level:' || v_parent_level);

          CASE pv_traversal_rarray(i_hier_ctr).display_order
            WHEN 1 THEN
              INSERT INTO fem_intg_dim_hier_c1_gt
              (parent_depth_num,
               parent_id,
               parent_display_code,
               child_depth_num,
               child_id,
               child_display_code,
               single_depth_flag,
               display_order_num,
               child_leaf_flag)
              SELECT DISTINCT gt.child_depth_num,
                     gt.child_id,
                     gt.child_display_code,
                     (gt.child_depth_num + 1),
                     ff.flex_value_id,
                     ff.flex_value,
                     'Y',
                     -1,
                     'N'
                FROM fem_intg_dim_hier_c1_gt gt,
                     fnd_flex_value_norm_hierarchy vh,
                     fnd_flex_values ff
               WHERE gt.child_depth_num = v_parent_level
               AND   vh.flex_value_set_id = v_aol_vs_id
               AND   vh.parent_flex_value = gt.child_display_code
               AND   vh.range_attribute = 'P'
               AND   ff.flex_value_set_id = v_aol_vs_id
               AND   ff.summary_flag = 'Y'
               AND   ff.flex_value
               BETWEEN vh.child_flex_value_low
               AND   vh.child_flex_value_high
               ORDER BY ff.flex_value;

            WHEN 2 THEN
              INSERT INTO fem_intg_dim_hier_c2_gt
              (parent_depth_num,
               parent_id,
               parent_display_code,
               child_depth_num,
               child_id,
               child_display_code,
               single_depth_flag,
               display_order_num,
               child_leaf_flag)
              SELECT DISTINCT gt.child_depth_num,
                     gt.child_id,
                     gt.child_display_code,
                     (gt.child_depth_num + 1),
                     ff.flex_value_id,
                     ff.flex_value,
                     'Y',
                     -1,
                     'N'
                FROM fem_intg_dim_hier_c2_gt gt,
                     fnd_flex_value_norm_hierarchy vh,
                     fnd_flex_values ff
               WHERE gt.child_depth_num = v_parent_level
               AND   vh.flex_value_set_id = v_aol_vs_id
               AND   vh.parent_flex_value = gt.child_display_code
               AND   vh.range_attribute = 'P'
               AND   ff.flex_value_set_id = v_aol_vs_id
               AND   ff.summary_flag = 'Y'
               AND   ff.flex_value
               BETWEEN vh.child_flex_value_low
               AND   vh.child_flex_value_high
               ORDER BY ff.flex_value;

            WHEN 3 THEN
              INSERT INTO fem_intg_dim_hier_c3_gt
              (parent_depth_num,
               parent_id,
               parent_display_code,
               child_depth_num,
               child_id,
               child_display_code,
               single_depth_flag,
               display_order_num,
               child_leaf_flag)
              SELECT DISTINCT gt.child_depth_num,
                     gt.child_id,
                     gt.child_display_code,
                     (gt.child_depth_num + 1),
                     ff.flex_value_id,
                     ff.flex_value,
                     'Y',
                     -1,
                     'N'
                FROM fem_intg_dim_hier_c3_gt gt,
                     fnd_flex_value_norm_hierarchy vh,
                     fnd_flex_values ff
               WHERE gt.child_depth_num = v_parent_level
               AND   vh.flex_value_set_id = v_aol_vs_id
               AND   vh.parent_flex_value = gt.child_display_code
               AND   vh.range_attribute = 'P'
               AND   ff.flex_value_set_id = v_aol_vs_id
               AND   ff.summary_flag = 'Y'
               AND   ff.flex_value
               BETWEEN vh.child_flex_value_low
               AND   vh.child_flex_value_high
               ORDER BY ff.flex_value;

            WHEN 4 THEN
              INSERT INTO fem_intg_dim_hier_c4_gt
              (parent_depth_num,
               parent_id,
               parent_display_code,
               child_depth_num,
               child_id,
               child_display_code,
               single_depth_flag,
               display_order_num,
               child_leaf_flag)
              SELECT DISTINCT gt.child_depth_num,
                     gt.child_id,
                     gt.child_display_code,
                     (gt.child_depth_num + 1),
                     ff.flex_value_id,
                     ff.flex_value,
                     'Y',
                     -1,
                     'N'
                FROM fem_intg_dim_hier_c4_gt gt,
                     fnd_flex_value_norm_hierarchy vh,
                     fnd_flex_values ff
               WHERE gt.child_depth_num = v_parent_level
               AND   vh.flex_value_set_id = v_aol_vs_id
               AND   vh.parent_flex_value = gt.child_display_code
               AND   vh.range_attribute = 'P'
               AND   ff.flex_value_set_id = v_aol_vs_id
               AND   ff.summary_flag = 'Y'
               AND   ff.flex_value
               BETWEEN vh.child_flex_value_low
               AND   vh.child_flex_value_high
               ORDER BY ff.flex_value;

            WHEN 5 THEN
              INSERT INTO fem_intg_dim_hier_c5_gt
              (parent_depth_num,
               parent_id,
               parent_display_code,
               child_depth_num,
               child_id,
               child_display_code,
               single_depth_flag,
               display_order_num,
               child_leaf_flag)
              SELECT DISTINCT gt.child_depth_num,
                     gt.child_id,
                     gt.child_display_code,
                     (gt.child_depth_num + 1),
                     ff.flex_value_id,
                     ff.flex_value,
                     'Y',
                     -1,
                     'N'
                FROM fem_intg_dim_hier_c5_gt gt,
                     fnd_flex_value_norm_hierarchy vh,
                     fnd_flex_values ff
               WHERE gt.child_depth_num = v_parent_level
               AND   vh.flex_value_set_id = v_aol_vs_id
               AND   vh.parent_flex_value = gt.child_display_code
               AND   vh.range_attribute = 'P'
               AND   ff.flex_value_set_id = v_aol_vs_id
               AND   ff.summary_flag = 'Y'
               AND   ff.flex_value
               BETWEEN vh.child_flex_value_low
               AND   vh.child_flex_value_high
               ORDER BY ff.flex_value;

          END CASE; -- Finish finding immediate children that are also parent values

          v_row_count2 := SQL%ROWCOUNT;

          FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_procedure,
            p_module   => 'fem.plsql.fem_intg.hier_eng.Bld_Component_Hier.Intermediate_Inserted.',
            p_msg_text => ' v_row_count2:' || v_row_count2 ||
                               ' v_parent_level :' || v_parent_level );

          -- When no more row is inserted, Exit the loop
          IF (v_row_count2 = 0) THEN
             EXIT;
          END IF;

          -- 2nd update the display_order num. Not handled in above insert statement
          -- because the distinct not allowed with nextval.
          v_sql_stmt :=
          'UPDATE fem_intg_dim_hier_c' || pv_traversal_rarray(i_hier_ctr).display_order || '_gt
           SET display_order_num = '||v_seq_name||'.nextval
           WHERE display_order_num = -1';

           FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_procedure,
            p_module   => 'fem.plsql.fem_intg_hier_eng.hier_eng.Bld_Component_Hier.seq.nextval',
            p_app_name => 'FEM',
            p_msg_name => 'FEM_GL_POST_204',
            p_token1   => 'VAR_NAME',
            p_value1   => 'v_sql_stmt',
            p_token2   => 'VAR_VAL',
            p_value2   => v_sql_stmt);

          EXECUTE IMMEDIATE v_sql_stmt;

          v_parent_level := v_parent_level + 1;

       END loop;  -- end of intermediate paraent loop

       -- Test to use user defind tables versus fnd_flex_values for bottom leaves
       CASE FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(i_Concat).table_validated_flag
         WHEN 'N' THEN

          -- bottom level detail from fnd_flex_values

           FEM_ENGINES_PKG.Tech_Message
             (p_severity => pc_log_level_procedure,
              p_module   => 'fem.plsql.fem_intg_hier_eng.Bld_Component_Hier.Bottom_Standard.',
              p_msg_text => 'pv_hier_obj_def_id:' || pv_hier_obj_def_id ||
              ' traversal hierarchy_obj_def_id:' || pv_traversal_rarray(i_hier_ctr).display_order);

           CASE pv_traversal_rarray(i_hier_ctr).display_order
             WHEN 1 THEN
               INSERT INTO fem_intg_dim_hier_c1_gt
               (parent_depth_num,
                parent_id,
                parent_display_code,
                child_depth_num,
                child_id,
                child_display_code,
                single_depth_flag,
                display_order_num,
                child_leaf_flag)
               SELECT DISTINCT gt.child_depth_num,
                      gt.child_id,
                      gt.child_display_code,
                      (gt.child_depth_num + 1),
                      ff.flex_value_id,
                      ff.flex_value,
                      'Y',
                      -1,
                      'Y'
                 FROM fem_intg_dim_hier_c1_gt gt,
                      fnd_flex_value_norm_hierarchy vh,
                      fnd_flex_values ff
                WHERE vh.flex_value_set_id = v_aol_vs_id
                AND   vh.parent_flex_value = gt.child_display_code
                AND   vh.range_attribute = 'C'
                AND   ff.flex_value_set_id = v_aol_vs_id
                AND   ff.summary_flag = 'N'
                AND   ff.flex_value  BETWEEN vh.child_flex_value_low AND vh.child_flex_value_high
               ORDER BY ff.flex_value;

             WHEN 2 THEN
               INSERT INTO fem_intg_dim_hier_c2_gt
               (parent_depth_num,
                parent_id,
                parent_display_code,
                child_depth_num,
                child_id,
                child_display_code,
                single_depth_flag,
                display_order_num,
                child_leaf_flag)
               SELECT DISTINCT gt.child_depth_num,
                      gt.child_id,
                      gt.child_display_code,
                      (gt.child_depth_num + 1),
                      ff.flex_value_id,
                      ff.flex_value,
                      'Y',
                      -1,
                      'Y'
                 FROM fem_intg_dim_hier_c2_gt gt,
                      fnd_flex_value_norm_hierarchy vh,
                      fnd_flex_values ff
                WHERE vh.flex_value_set_id = v_aol_vs_id
                AND   vh.parent_flex_value = gt.child_display_code
                AND   vh.range_attribute = 'C'
                AND   ff.flex_value_set_id = v_aol_vs_id
                AND   ff.summary_flag = 'N'
                AND   ff.flex_value  BETWEEN vh.child_flex_value_low AND vh.child_flex_value_high
               ORDER BY ff.flex_value;

             WHEN 3 THEN
               INSERT INTO fem_intg_dim_hier_c3_gt
               (parent_depth_num,
                parent_id,
                parent_display_code,
                child_depth_num,
                child_id,
                child_display_code,
                single_depth_flag,
                display_order_num,
                child_leaf_flag)
               SELECT DISTINCT gt.child_depth_num,
                      gt.child_id,
                      gt.child_display_code,
                      (gt.child_depth_num + 1),
                      ff.flex_value_id,
                      ff.flex_value,
                      'Y',
                      -1,
                      'Y'
                 FROM fem_intg_dim_hier_c3_gt gt,
                      fnd_flex_value_norm_hierarchy vh,
                      fnd_flex_values ff
                WHERE vh.flex_value_set_id = v_aol_vs_id
                AND   vh.parent_flex_value = gt.child_display_code
                AND   vh.range_attribute = 'C'
                AND   ff.flex_value_set_id = v_aol_vs_id
                AND   ff.summary_flag = 'N'
                AND   ff.flex_value  BETWEEN vh.child_flex_value_low AND vh.child_flex_value_high
               ORDER BY ff.flex_value;

             WHEN 4 THEN
               INSERT INTO fem_intg_dim_hier_c4_gt
               (parent_depth_num,
                parent_id,
                parent_display_code,
                child_depth_num,
                child_id,
                child_display_code,
                single_depth_flag,
                display_order_num,
                child_leaf_flag)
               SELECT DISTINCT gt.child_depth_num,
                      gt.child_id,
                      gt.child_display_code,
                      (gt.child_depth_num + 1),
                      ff.flex_value_id,
                      ff.flex_value,
                      'Y',
                      -1,
                      'Y'
                 FROM fem_intg_dim_hier_c4_gt gt,
                      fnd_flex_value_norm_hierarchy vh,
                      fnd_flex_values ff
                WHERE vh.flex_value_set_id = v_aol_vs_id
                AND   vh.parent_flex_value = gt.child_display_code
                AND   vh.range_attribute = 'C'
                AND   ff.flex_value_set_id = v_aol_vs_id
                AND   ff.summary_flag = 'N'
                AND   ff.flex_value  BETWEEN vh.child_flex_value_low AND vh.child_flex_value_high
               ORDER BY ff.flex_value;

             WHEN 5 THEN
               INSERT INTO fem_intg_dim_hier_c5_gt
               (parent_depth_num,
                parent_id,
                parent_display_code,
                child_depth_num,
                child_id,
                child_display_code,
                single_depth_flag,
                display_order_num,
                child_leaf_flag)
               SELECT DISTINCT gt.child_depth_num,
                      gt.child_id,
                      gt.child_display_code,
                      (gt.child_depth_num + 1),
                      ff.flex_value_id,
                      ff.flex_value,
                      'Y',
                      -1,
                      'Y'
                 FROM fem_intg_dim_hier_c5_gt gt,
                      fnd_flex_value_norm_hierarchy vh,
                      fnd_flex_values ff
                WHERE vh.flex_value_set_id = v_aol_vs_id
                AND   vh.parent_flex_value = gt.child_display_code
                AND   vh.range_attribute = 'C'
                AND   ff.flex_value_set_id = v_aol_vs_id
                AND   ff.summary_flag = 'N'
                AND   ff.flex_value  BETWEEN vh.child_flex_value_low AND vh.child_flex_value_high
               ORDER BY ff.flex_value;


           END CASE; -- Finish working with independent value set leaf values

           v_row_count3 := SQL%ROWCOUNT;

         ELSE

         -- dynamic sql generation
          /*
          bottom level detail based on user defined table
          we use pv_mapped_segs to get this info  and use dynamic sql to
          construct a statement like this:
         The varing items are:
             FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(i_Concat).val_col_name
             FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(i_Concat).table_name
             FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(i_Concat).id_col_name
         INSERT INTO fem_intg_dim_hier_gt
            (hierarchy_obj_def_id,
             parent_depth_num,
             parent_id,
             parent_display_code,
             child_depth_num,
             child_id,
             child_display_code,
             single_depth_flag,
             display_order_num,
             child_leaf_flag)
         SELECT DISTINCT 1,
            gt.child_depth_num,
            gt.child_id,
            gt.child_display_code,
           (gt.child_depth_num + 1),
            -1,
            MEANING,
           'Y',
           -1,
           'Y'
         FROM fem_intg_dim_hier_gt gt,
         FND_LOOKUPS,
         fnd_flex_value_norm_hierarchy vh
         WHERE FND_LOOKUPS.LOOKUP_TYPE = 'YES_NO'
         AND vh.flex_value_set_id = 1002723
         AND   gt.hierarchy_obj_def_id = 1
         AND vh.parent_flex_value = gt.child_display_code
         AND vh.range_attribute = 'C'
         AND MEANING
         BETWEEN vh.child_flex_value_low
         AND  vh.child_flex_value_high
         ORDER BY MEANING
         */

          FEM_ENGINES_PKG.Tech_Message
             (p_severity => pc_log_level_procedure,
              p_module   => 'fem.plsql.fem_intg_hier_eng.Bld_Component_Hier.Bottom_User_table.',
              p_msg_text => 'pv_hier_obj_def_id:' || pv_hier_obj_def_id ||
              ' traversal hierarchy_obj_def_id:' || pv_traversal_rarray(i_hier_ctr).display_order);

          --  Use the pv_mapped_segs(i_Concat)  structure  to construct dynamic sql
          --  statement to insert bottom level children
          --  If ADDITIONAL_WHERE_CLAUSE is populated use it in dynamic sql.
          Select ADDITIONAL_WHERE_CLAUSE
            into v_add_where
            from fnd_flex_validation_tables
            where pv_traversal_rarray(i_hier_ctr).aol_vs_id = FLEX_VALUE_SET_ID;

          if v_add_where is NULL or Instr(upper(v_add_where), 'WHERE', 1) = 0 then
             V_Where :=  ' WHERE vh.flex_value_set_id = ' || v_aol_vs_id || '
                     AND   vh.parent_flex_value = gt.child_display_code
                     AND   vh.range_attribute = ''C''  ' ;
          Else
             V_Where  :=   v_add_where || '
             AND vh.flex_value_set_id = ' || v_aol_vs_id || '
             AND vh.parent_flex_value = gt.child_display_code
             AND vh.range_attribute = ''C'' ';
          End if;

          -- Begining of dynamic insert
          V_sql_stmt_start := 'INSERT INTO fem_intg_dim_hier_c' || pv_traversal_rarray(i_hier_ctr).display_order || '_gt
           (parent_depth_num,
           parent_id,
           parent_display_code,
           child_depth_num,
           child_id,
           child_display_code,
           single_depth_flag,
           display_order_num,
           child_leaf_flag)
         SELECT DISTINCT gt.child_depth_num,
          gt.child_id,
          gt.child_display_code,
          (gt.child_depth_num + 1),
          -1,
          ' || FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(i_Concat).val_col_name || ',
          ''Y'',
          -1,
          ''Y''
         FROM fem_intg_dim_hier_c' || pv_traversal_rarray(i_hier_ctr).display_order || '_gt gt,
          ' || FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(i_Concat).table_name || ',
          fnd_flex_value_norm_hierarchy vh
          ';
          -- ending concatinated to where that was assigned above
          V_sql_stmt_end  := '
          AND ' || FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(i_Concat).val_col_name || '
          '  || 'BETWEEN vh.child_flex_value_low
          AND  vh.child_flex_value_high
          ORDER BY ' ||  FEM_INTG_DIM_RULE_ENG_PKG.pv_mapped_segs(i_Concat).val_col_name ;
          -- concatenate three sections
          V_sql_stmt := V_sql_stmt_start || v_where || V_sql_stmt_end;

          FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_procedure,
            p_module   => 'fem.plsql.fem_intg_hier_eng.Bld_Component_Hier',
            p_app_name => 'FEM',
            p_msg_name => 'FEM_GL_POST_204',
            p_token1   => 'VAR_NAME',
            p_value1   => 'v_sql_stmt',
            p_token2   => 'VAR_VAL',
            p_value2   => v_sql_stmt);

          EXECUTE IMMEDIATE v_sql_stmt;
          v_row_count3 := SQL%ROWCOUNT;

        END CASE;   -- end bottom leaf inserts

        FEM_ENGINES_PKG.Tech_Message
          (p_severity => pc_log_level_procedure,
           p_module   => 'fem.plsql.fem_intg.hier_eng.Bld_Component_Hier.Bottom_level.',
           p_msg_text => ' v_row_count3:' || v_row_count3 ||
                               ' v_parent_level :' || v_parent_level);
          -- 3rd update the display_order num. Not handled in above insert statement
          -- because the distinct not allowed with nextval.
          v_sql_stmt :=
         'UPDATE fem_intg_dim_hier_c' || pv_traversal_rarray(i_hier_ctr).display_order || '_gt
           SET display_order_num = '||v_seq_name||'.nextval
           WHERE display_order_num = -1';

        EXECUTE IMMEDIATE v_sql_stmt;

        v_seq_stmt := 'DROP SEQUENCE ' || v_seq_name;
        EXECUTE IMMEDIATE v_seq_stmt;

        END if;   -- end of build of this component single seg hierarchy

        -- Check if any children within the hierarchy are assigned to
        -- multiple parents.
        BEGIN

         CASE pv_traversal_rarray(i_hier_ctr).display_order

           WHEN 1 THEN
             SELECT 'Duplicate'
             INTO v_duplicate_parent
              FROM dual
              WHERE EXISTS
              (SELECT gt.child_display_code
               FROM fem_intg_dim_hier_c1_gt gt
               WHERE gt.parent_display_code <> gt.child_display_code
               GROUP BY gt.child_display_code
               HAVING count(gt.child_display_code) > 1);

           WHEN 2 THEN
             SELECT 'Duplicate'
             INTO v_duplicate_parent
              FROM dual
              WHERE EXISTS
              (SELECT gt.child_display_code
               FROM fem_intg_dim_hier_c2_gt gt
               WHERE gt.parent_display_code <> gt.child_display_code
               GROUP BY gt.child_display_code
               HAVING count(gt.child_display_code) > 1);

           WHEN 3 THEN
             SELECT 'Duplicate'
             INTO v_duplicate_parent
              FROM dual
              WHERE EXISTS
              (SELECT gt.child_display_code
               FROM fem_intg_dim_hier_c3_gt gt
               WHERE gt.parent_display_code <> gt.child_display_code
               GROUP BY gt.child_display_code
               HAVING count(gt.child_display_code) > 1);

           WHEN 4 THEN
             SELECT 'Duplicate'
             INTO v_duplicate_parent
              FROM dual
              WHERE EXISTS
              (SELECT gt.child_display_code
               FROM fem_intg_dim_hier_c4_gt gt
               WHERE gt.parent_display_code <> gt.child_display_code
               GROUP BY gt.child_display_code
               HAVING count(gt.child_display_code) > 1);

           WHEN 5 THEN
             SELECT 'Duplicate'
             INTO v_duplicate_parent
              FROM dual
              WHERE EXISTS
              (SELECT gt.child_display_code
               FROM fem_intg_dim_hier_c5_gt gt
               WHERE gt.parent_display_code <> gt.child_display_code
               GROUP BY gt.child_display_code
               HAVING count(gt.child_display_code) > 1);

         END CASE; -- End duplicate check

        EXCEPTION
         WHEN NO_DATA_FOUND THEN
           null;
        END;

        IF (v_duplicate_parent = 'Duplicate') THEN
         FEM_ENGINES_PKG.Tech_Message
          (p_severity => pc_log_level_procedure,
           p_module   => 'fem.plsql.fem_intg_hier_eng.Bld_Component_Hier.' || 'duplicate',
           p_app_name => 'FEM',
           p_msg_name => 'FEM_INTG_HIER_MULTI_PARENT_ERR',
           p_token1   => 'VAR_NAME',
           p_value1   => 'v_duplicate_parent',
           p_token2   => 'VAR_VAL',
           p_value2   => v_duplicate_parent);
          FEM_ENGINES_PKG.User_Message
           (p_app_name => 'FEM',
            p_msg_name => 'FEM_INTG_HIER_MULTI_PARENT_ERR');

          --bug fix 4563603
          FEM_ENGINES_PKG.Tech_Message
             (p_severity => pc_log_level_procedure,
              p_module   => 'fem.plsql.fem_intg_hier_eng.Bld_Component_Hier.' || 'duplicate',
              p_app_name => 'FEM',
              p_msg_text => ' ');

          FEM_ENGINES_PKG.User_Message
              (p_app_name => 'FEM',
               p_msg_text => ' ');

          FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_procedure,
            p_module   => 'fem.plsql.fem_intg_hier_eng.Bld_Component_Hier.' || 'duplicate',
            p_app_name => 'FEM',
            p_msg_name => 'FEM_INTG_HIER_MULT_PARENTS');

           FEM_ENGINES_PKG.User_Message
            (p_app_name => 'FEM',
             p_msg_name => 'FEM_INTG_HIER_MULT_PARENTS');

          OPEN c_child_of_multi_parent  FOR
          'SELECT  gt.child_display_code
           FROM fem_intg_dim_hier_c' || pv_traversal_rarray(i_hier_ctr).display_order || '_gt gt
           WHERE gt.parent_display_code <> gt.child_display_code
           GROUP BY gt.child_display_code
           HAVING count(gt.child_display_code) > 1';

          LOOP
              FETCH c_child_of_multi_parent INTO v_display_code;
              EXIT WHEN c_child_of_multi_parent%NOTFOUND;

              --Bug fix 5577544
              v_offending_parents_list := NULL;

              OPEN c_multi_parent FOR
              'SELECT  DISTINCT gt.parent_display_code
               FROM fem_intg_dim_hier_c' || pv_traversal_rarray(i_hier_ctr).display_order || '_gt gt
               WHERE gt.parent_display_code <> gt.child_display_code
               and gt.child_display_code = :child_display_code' USING v_display_code;

              LOOP
                  FETCH c_multi_parent INTO v_parent_display_code;
                  EXIT WHEN c_multi_parent%NOTFOUND;
                  v_offending_parents_list := v_offending_parents_list || v_parent_display_code || ', ';
              END LOOP;
              CLOSE c_multi_parent;
              v_offending_parents_list := SUBSTR(v_offending_parents_list,1,LENGTH(v_offending_parents_list)-2);

              FEM_ENGINES_PKG.Tech_Message
               (p_severity => pc_log_level_procedure,
                p_module   => 'fem.plsql.fem_intg.hier_eng.',
                p_app_name => 'FEM',
                p_msg_name => 'FEM_INTG_HIER_PARENT_CHILD_LST',
                p_token1   => 'CHILD',
                p_value1   => v_display_code,
                p_token2   => 'PARENTS',
                p_value2   => v_offending_parents_list);
              FEM_ENGINES_PKG.User_Message
              (p_app_name => 'FEM',
               p_msg_name => 'FEM_INTG_HIER_PARENT_CHILD_LST',
               p_token1   => 'CHILD',
               p_value1   => v_display_code,
               p_token2   => 'PARENTS',
               p_value2   => v_offending_parents_list);

          END LOOP;

          CLOSE c_child_of_multi_parent;
          FEM_ENGINES_PKG.Tech_Message
             (p_severity => pc_log_level_procedure,
              p_module   => 'fem.plsql.fem_intg_hier_eng.Bld_Component_Hier.' || 'duplicate',
              p_app_name => 'FEM',
              p_msg_text => ' ');

          FEM_ENGINES_PKG.User_Message
              (p_app_name => 'FEM',
               p_msg_text => ' ');
           --bug fix 4563603

          RAISE FEM_INTG_fatal_err;
        END IF;

        i_hier_ctr := pv_traversal_rarray.next(i_hier_ctr);
        commit;  -- one component hier has been built to fem_intg_dim_hier_gt

    END loop;    -- Main Loop for traversing each component hierarchy

    x_completion_code := 0;

    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => 'fem.plsql.fem_intg_hier_eng.Bld_Component_Hier.',
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_202',
       p_token1   => 'FUNC_NAME',
       p_value1   => 'FEM_INTG_HIER_RULE_ENG_PKG.Bld_Component_Hier',
       p_token2   => 'TIME',
       p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));


    return;

   EXCEPTION
    WHEN FEM_INTG_fatal_err THEN
      ROLLBACK;
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_unexpected,
       p_module   => 'fem.plsql.fem_intg.hier_eng.Bld_Component_Hier.' ||'FEM_INTG_fatal_err',
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
       p_module   => 'fem.plsql.fem_intg.hier_eng.Bld_Component_Hier.' || 'FEM_INTG_fatal_err',
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_203',
       p_token1   => 'FUNC_NAME',
       p_value1   => 'FEM_INTG_HIER_RULE_ENG_PKG.Bld_Component_Hier',
       p_token2   => 'TIME',
       p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
    x_completion_code := 2;
    return;
   WHEN OTHERS THEN
    ROLLBACK;
    IF (v_seq_name IS NOT NULL) THEN
      v_seq_stmt := 'DROP SEQUENCE ' || v_seq_name;
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => 'fem.plsql.fem_intg_hier_eng.Bld_Component_Hier.'
             || 'exceptoin others',
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'v_seq_stmt',
       p_token2   => 'VAR_VAL',
       p_value2   => v_seq_stmt);
    EXECUTE IMMEDIATE v_seq_stmt;
    COMMIT;
    END IF;
      FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_unexpected,
       p_module   => 'fem.plsql.fem_intg_hier_eng.Bld_Component_Hier.' || 'exceptoin others',
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
        p_module   => 'fem.plsql.fem_intg_hier_eng.Bld_Component_Hier.' || 'exceptoin others',
        p_app_name => 'FEM',
        p_msg_name => 'FEM_GL_POST_203',
        p_token1   => 'FUNC_NAME',
        p_value1   => 'FEM_INTG_HIER_RULE_ENG_PKG.Bld_Component_Hier',
        p_token2   => 'TIME',
        p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
      x_completion_code := 2;
      return;
  END Bld_Component_Hiers;
-- ======================================================================
-- Procedure
--     Bld_Hier_Multi_Segment
-- Purpose
--
--
--
--
-- History
--     10-18-05  A. Budnik bugs 4652450 and 4681970
--     08-14-05  Piush Gupta Added code to stub
--     08-03-05  A. Budnik  Created
-- Arguments
--     x_completion_code        Completion status of the routine
--
-- To Do : Use bind variables in dynamically generated SQL to minimize
--         parsing.
-- ======================================================================
  PROCEDURE Bld_Hier_Multi_Segment (x_completion_code  OUT NOCOPY NUMBER) IS
    FEM_INTG_fatal_err EXCEPTION;
    v_compl_code                NUMBER;
    v_Num_hiers                 NUMBER;
    v_concated_segment          NUMBER(1);
    v_counter                   integer;
    v_hier_counter              integer;
    TYPE t_concat_order is table of number;
    v_concat_rarray             t_concat_order := t_concat_order();
    v_sql                       varchar2(4000);
    v_debug                     number;
    v_sql_temp                  varchar2(4000);
    v_completion_code           number;
    v_dim_process_row_cnt       number;
    v_dim_group_name_seq        number;
    V_API_RETURN_STATUS         varchar2(30);
    v_msg_count                 number;
    v_msg_data                  varchar2(4000);
    V_DIMENSION_GROUP_ID        number;
    v_seq_name                  VARCHAR2(30);
    v_seq_stmt                  VARCHAR2(2000);
    v_sql_stmt                  VARCHAR2(2000);
  BEGIN
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => 'fem.plsql.fem_intg.hier_eng.Bld_Hier_Multi_Segment',
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_201',
       p_token1   => 'FUNC_NAME',
       p_value1   => 'FEM_INTG_HIER_RULE_ENG_PKG.Bld_Hier_Multi_Segment',
       p_token2   => 'TIME',
       p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
    -- trim the display codes to 15 chars
    update FEM_INTG_DIM_HIER_GT
      set child_display_code = substr(child_display_code, 1, pc_max_disp_len)
      , parent_display_code =  substr(parent_display_code, 1, pc_max_disp_len);
    -- create a pl/sql table that holds the segments in concatenations order
    v_concat_rarray.extend(pv_traversal_rarray.count);
    v_counter := pv_traversal_rarray.first;
    while v_counter is not null
    loop
      v_concat_rarray(pv_traversal_rarray(v_counter).concat_segment) := v_counter;
      v_counter := pv_traversal_rarray.next(v_counter);
    end loop;
    -- create dynamic SQL to insert the leaf nodes
    /*
      Sample SQL stmt :
      INSERT INTO FEM_INTG_DIM_HIER_GT
        (HIERARCHY_OBJ_DEF_ID
        , child_display_code
        , child_id
        , parent_display_code
        , parent_id
        , child_depth_num
        , parent_depth_num
        , child_leaf_flag
        , single_depth_flag
        , display_order_num
        )
      (SELECT 20861
        , gt1.child_display_code || '-' || gt2.child_display_code || '-' || gt3.child_display_code || '-' ||
        gt4.child_display_code || '-' || gt5.child_display_code, b.CUSTOMER_ID  ,gt1.parent_display_code || '-' ||
        gt2.child_display_code || '-' || gt3.child_display_code || '-' || gt4.child_display_code || '-' ||
        gt5.child_display_code
        , -1
        , (gt1.child_depth_num + gt2.child_depth_num + gt3.child_depth_num + gt4.child_depth_num + gt5.child_depth_num- 5 + 1)
        , (gt1.parent_depth_num + gt2.parent_depth_num + gt3.parent_depth_num + gt4.parent_depth_num + gt5.parent_depth_num)
        , 'Y'
        , 'N'
        , -1
      from
        FEM_INTG_DIM_HIER_GT gt1
        , FEM_INTG_DIM_HIER_GT gt2
        , FEM_INTG_DIM_HIER_GT gt3
        , FEM_INTG_DIM_HIER_GT gt4
        , FEM_INTG_DIM_HIER_GT gt5
        , FEM_CUSTOMERS_B b
      WHERE gt1.hierarchy_obj_def_id = 1
        and gt1.child_leaf_flag = 'Y'
        and gt2.hierarchy_obj_def_id = 2
        and gt2.child_leaf_flag = 'Y'
        and gt3.hierarchy_obj_def_id = 3
        and gt3.child_leaf_flag = 'Y'
        and gt4.hierarchy_obj_def_id = 4
        and gt4.child_leaf_flag = 'Y'
        and gt5.hierarchy_obj_def_id = 5
        and gt5.child_leaf_flag = 'Y'
        and b.CUSTOMER_DISPLAY_CODE = gt1.child_display_code || '-' || gt2.child_display_code || '-' || gt3.child_display_code || '-' || gt4.child_display_code || '-' || gt5.child_display_code
        and b.value_set_id = :pv_aol_vs_id)
    */
    v_sql := 'INSERT INTO FEM_INTG_DIM_HIER_GT
  (HIERARCHY_OBJ_DEF_ID
  , child_display_code
  , child_id
  , parent_display_code
  , parent_id
  , child_depth_num
  , parent_depth_num
  , child_leaf_flag
  , single_depth_flag
  , display_order_num
)
(SELECT ' || pv_hier_obj_def_id || '
  , ';

    -- construct sql for : gt1.child_display_code||'-'||gt2.child_display_code
    v_counter := v_concat_rarray.first;
    while v_counter is not null
    loop
      v_sql := v_sql || 'gt' || v_concat_rarray(v_counter) || '.child_display_code';
      if v_counter < v_concat_rarray.count then
        v_sql := v_sql || ' || ''-'' || ';
      end if;
       v_counter := v_concat_rarray.next(v_counter);
    end loop;
    v_sql := v_sql ||   ', b.' || pv_dim_memb_col || '  ,';

    -- construct sql for : gt1.parent_display_code||'-'||gt2.child_display_code
    v_counter := v_concat_rarray.first;
    while v_counter is not null
    loop
      v_sql := v_sql || 'gt' || v_concat_rarray(v_counter);
      if v_concat_rarray(v_counter) = pv_traversal_rarray.first then
        v_sql := v_sql || '.parent_display_code';
      else
        v_sql := v_sql || '.child_display_code';
      end if;
      if v_counter < v_concat_rarray.count then
        v_sql := v_sql || ' || ''-'' || ';
      end if;
       v_counter := v_concat_rarray.next(v_counter);
    end loop;
    v_sql := v_sql || '
  , -1';

    -- construct sql for : , (gt1.child_depth_num + gt2.child_depth_num - p_num_hiers + 1)
    v_sql_temp := ', (';
    v_counter := pv_traversal_rarray.first;
    while v_counter is not null
    loop
      v_sql_temp := v_sql_temp || 'gt' || v_counter || '.child_depth_num';
      if v_counter < pv_traversal_rarray.count then
        v_sql_temp := v_sql_temp || ' + ';
      end if;
      v_counter := pv_traversal_rarray.next(v_counter);
    end loop;
    v_sql_temp := v_sql_temp || '- ' ||  pv_traversal_rarray.count || ' + 1)';
    v_sql := v_sql || v_sql_temp || '
  , (';

    -- Construct sql for : , (gt1.parent_depth_num + gt2.parent_depth_num)
    v_counter := pv_traversal_rarray.first;
    while v_counter is not null
    loop
      v_sql := v_sql || 'gt' || v_counter || '.parent_depth_num';
      if v_counter < pv_traversal_rarray.count then
        v_sql := v_sql || ' + ';
      end if;
      v_counter := pv_traversal_rarray.next(v_counter);
    end loop;
    v_sql := v_sql || ')
  , ''Y''
  , ''N''
  , -1
from ';

    -- construct sql for : FROM  FEM_INTG_DIM_HIER_GT gt1, FEM_INTG_DIM_HIER_GT gt2, fem_cctr_orgs_b b
    v_counter := pv_traversal_rarray.first;
    while v_counter is not null
    loop
      v_sql := v_sql || 'FEM_INTG_DIM_HIER_C' || v_counter || '_GT gt' || v_counter;
      if v_counter < pv_traversal_rarray.count then
        v_sql := v_sql || ', ';
      end if;
      v_counter := pv_traversal_rarray.next(v_counter);
    end loop;
    v_sql := v_sql || ', ' || pv_dim_memb_b_tab || ' b  WHERE ';

    -- construct sql for :  gt1.child_leaf_flag = 'Y'
    v_counter := pv_traversal_rarray.first;
    while v_counter is not null
    loop
      v_sql := v_sql || ' gt' || v_counter || '.child_leaf_flag = ''Y''';
      if v_counter < pv_traversal_rarray.count then
        v_sql := v_sql || ' and ';
      end if;
      v_counter := pv_traversal_rarray.next(v_counter);
    end loop;

    -- construct sql for : and b.CCTR_ORG_DISPLAY_CODE = gt1.child_display_code||'-'||gt2.child_display_code
    v_sql := v_sql || ' and b.' || pv_dim_memb_disp_col || ' = ';
    v_counter := v_concat_rarray.first;
    while v_counter is not null
    loop
      v_sql := v_sql || 'gt' || v_concat_rarray(v_counter) || '.child_display_code';
      if v_counter < v_concat_rarray.count then
        v_sql := v_sql || ' || ''-'' || ';
      end if;
      v_counter := v_concat_rarray.next(v_counter);
    end loop;

    -- contruct SQL for : and b.value_set_id = :pv_dim_vs_id
    v_sql := v_sql || ' and b.value_set_id = :pv_dim_vs_id ';

    -- the final )
    v_sql := v_sql || ')';

    -- execute the SQL to insert the leaf nodes
    select count(*) into v_debug from FEM_INTG_DIM_HIER_GT;

        FEM_ENGINES_PKG.Tech_Message(
          p_severity => pc_log_level_statement,
          p_module   => 'fem.plsql.Bld_Hier_Multi_Segment1',
          p_msg_text => v_sql);

    execute immediate v_sql using pv_dim_vs_id;
    COMMIT;
    -- walk up the concatenated hierarchy one-level-per-segment at a time
    v_hier_counter := pv_traversal_rarray.first;
    v_counter := 1;
    while v_hier_counter is not null
    loop
      loop
        /*
          Sample SQL stmt :
            INSERT INTO FEM_INTG_DIM_HIER_GT
              (HIERARCHY_OBJ_DEF_ID
              , child_display_code
              , child_id
              , parent_display_code
              , parent_id
              , child_depth_num
              , parent_depth_num
              , child_leaf_flag
              , single_depth_flag
              , display_order_num
              --, counter_num
            )'
            (SELECT distinct 20861
              , gtm.parent_display_code
              , gtm.parent_id


------------ before hierarchy rule performance fix
              , decode(1,
                       1, gts.parent_display_code || '-' || substr(gtm.parent_display_code, instr(gtm.parent_display_code, '-')+1),
                       5, substr(gtm.parent_display_code, 1, instr(gtm.parent_display_code, '-', 1, 5-1)-1) || '-' || gts.parent_display_code,
                          substr(gtm.parent_display_code, 1, instr(gtm.parent_display_code, '-', 1, 0)-1) || '-' ||
                          gts.parent_display_code || '-' ||
                          substr(gtm.parent_display_code, instr(gtm.parent_display_code, '-', 1, 1)+1))
------------ before hierarchy rule performance fix
------------ after (one of the three)
             1. , gts.parent_display_code || '-' || substr(gtm.parent_display_code, instr(gtm.parent_display_code, '-')+1)
             2. , substr(gtm.parent_display_code, 1, instr(gtm.parent_display_code, '-', 1, 5-1)-1) || '-' || gts.parent_display_code
             3. , substr(gtm.parent_display_code, 1, instr(gtm.parent_display_code, '-', 1, 0)-1) || '-' ||
                  gts.parent_display_code || '-' ||
                  substr(gtm.parent_display_code, instr(gtm.parent_display_code, '-', 1, 1)+1))
------------ after (one of the three)


              , -1
              , gtm.parent_depth_num
              , gtm.parent_depth_num-1
              , 'N'
              , 'N'
              , -1
              --, 1
            FROM
              FEM_INTG_DIM_HIER_GT gtm
              , FEM_INTG_DIM_HIER_GT gts
------------            WHERE gtm.HIERARCHY_OBJ_DEF_ID = :pv_hier_obj_def_id
------------              AND gts.hierarchy_obj_def_id = :display_order
------------              AND gts.child_display_code =
            WHERE gts.child_display_code =

------------ before hierarchy rule performance fix
                decode(1,
                       1, substr(gtm.parent_display_code, 1, instr(gtm.parent_display_code, '-')-1),
                       5, substr(gtm.parent_display_code, instr(gtm.parent_display_code, '-', 1, 0)+1),
                          substr(gtm.parent_display_code, instr(gtm.parent_display_code, '-', 1, 0)+1,
                          instr(gtm.parent_display_code, '-', 1, 1)-instr(gtm.parent_display_code, '-', 1, 0)-1))
------------ before hierarchy rule performance fix
------------ after (one of the three)
             1. substr(gtm.parent_display_code, 1, instr(gtm.parent_display_code, '-')-1)
             2. substr(gtm.parent_display_code, instr(gtm.parent_display_code, '-', 1, 0)+1)
             3. substr(gtm.parent_display_code, instr(gtm.parent_display_code, '-', 1, 0)+1,
                instr(gtm.parent_display_code, '-', 1, 1)-instr(gtm.parent_display_code, '-', 1, 0)-1))
------------ after (one of the three)


              AND gts.child_display_code <> gts.parent_display_code
              and not exists (select 1 from FEM_INTG_DIM_HIER_GT gte where gte.child_display_code = gtm.parent_display_code)
        */
         v_sql := 'INSERT INTO FEM_INTG_DIM_HIER_GT
  (HIERARCHY_OBJ_DEF_ID
  , child_display_code
  , child_id
  , parent_display_code
  , parent_id
  , child_depth_num
  , parent_depth_num
  , child_leaf_flag
  , single_depth_flag
  , display_order_num
  )
  (SELECT distinct ' || pv_hier_obj_def_id || '
    , gtm.parent_display_code
    , gtm.parent_id
    , ';

        IF v_hier_counter = v_concat_rarray(v_concat_rarray.first) THEN
          v_sql := v_sql || 'gts.parent_display_code || ''-'' || substr(gtm.parent_display_code, instr(gtm.parent_display_code, ''-'')+1)';
        ELSIF v_hier_counter = v_concat_rarray(v_concat_rarray.last) THEN
          v_sql := v_sql || 'substr(gtm.parent_display_code, 1, instr(gtm.parent_display_code, ''-'', 1, ' || v_concat_rarray.count || '-1)-1) || ''-'' || gts.parent_display_code';
        ELSE
          v_sql := v_sql || 'substr(gtm.parent_display_code, 1, instr(gtm.parent_display_code, ''-'', 1, ' ||
                            (pv_traversal_rarray(v_hier_counter).concat_segment-1) ||
                            ')-1) || ''-'' || gts.parent_display_code || ''-'' || substr(gtm.parent_display_code, instr(gtm.parent_display_code, ''-'', 1, ' ||
                            pv_traversal_rarray(v_hier_counter).concat_segment ||
                            ')+1)';
        END IF;

        v_sql := v_sql || '
    , -1
    , gtm.parent_depth_num
    , gtm.parent_depth_num-1
    , ''N''
    , ''N''
    , -1
  FROM
    FEM_INTG_DIM_HIER_GT gtm
    , FEM_INTG_DIM_HIER_C' || pv_traversal_rarray(v_hier_counter).display_order || '_GT gts
  WHERE gts.child_display_code = ';

        IF v_hier_counter = v_concat_rarray(v_concat_rarray.first) THEN
          v_sql := v_sql || 'substr(gtm.parent_display_code, 1, instr(gtm.parent_display_code, ''-'')-1)';
        ELSIF v_hier_counter = v_concat_rarray(v_concat_rarray.last) THEN
          v_sql := v_sql || 'substr(gtm.parent_display_code, instr(gtm.parent_display_code, ''-'', 1, ' || (pv_traversal_rarray(v_hier_counter).concat_segment-1) || ')+1)';
        ELSE
          v_sql := v_sql ||
                   'substr(gtm.parent_display_code, instr(gtm.parent_display_code, ''-'', 1, ' ||
                   (pv_traversal_rarray(v_hier_counter).concat_segment-1) ||
                   ')+1, instr(gtm.parent_display_code, ''-'', 1, ' ||
                   (pv_traversal_rarray(v_hier_counter).concat_segment) ||
                   ')-instr(gtm.parent_display_code, ''-'', 1, ' ||
                   (pv_traversal_rarray(v_hier_counter).concat_segment-1) ||
                   ')-1)';
        END IF;

	v_sql := v_sql || '
    AND gts.child_display_code <> gts.parent_display_code
    and not exists (select 1 from FEM_INTG_DIM_HIER_GT gte where gte.child_display_code = gtm.parent_display_code))';
        select count(*) into v_debug from FEM_INTG_DIM_HIER_GT;

        FEM_ENGINES_PKG.Tech_Message(
          p_severity => pc_log_level_statement,
          p_module   => 'fem.plsql.Bld_Hier_Multi_Segment2',
          p_msg_text => v_sql);

       execute immediate v_sql;
        v_counter := v_counter + 1;
        exit when SQL%ROWCOUNT = 0;
        select count(*) into v_debug from FEM_INTG_DIM_HIER_GT;
      end loop;
      v_hier_counter := pv_traversal_rarray.next(v_hier_counter);
    end loop;
    -- insert the SQL for the top member
    INSERT INTO FEM_INTG_DIM_HIER_GT
      (HIERARCHY_OBJ_DEF_ID
      , child_display_code
      , child_id
      , parent_display_code
      , parent_id
      , child_depth_num
      , parent_depth_num
      , child_leaf_flag
      , single_depth_flag
      , display_order_num
      )
    (SELECT distinct pv_hier_obj_def_id
      , gtm.parent_display_code
      , gtm.parent_id
      , gtm.parent_display_code
      , gtm.parent_id
      , gtm.parent_depth_num
      , gtm.parent_depth_num
      , 'N'
      , 'N'
      , -1
    FROM  FEM_INTG_DIM_HIER_GT gtm
    WHERE not exists (select 1 from FEM_INTG_DIM_HIER_GT gte where gte.child_display_code = gtm.parent_display_code));
    -- Processing for creating level based hierarchies
    v_counter :=1;
    -- 17OCT2005 BUG 4681970
    -- CREATE sequence for display order
    v_seq_name := 'FEM_INTG_HIER_SEQ_' || pv_req_id || '_S';
    v_seq_stmt := 'CREATE SEQUENCE '||v_seq_name||' START WITH 1';
    EXECUTE IMMEDIATE v_seq_stmt;
    COMMIT;
    loop
      v_dim_group_name_seq := v_counter*100;
  -- Call API to create new dimension group
  --dedutta : 5035567 : if check for pv_sequence_enforced_flag
    IF (pv_sequence_enforced_flag = 'Y') THEN
      FEM_DIM_GROUPS_UTIL_PKG.create_dim_group
       (x_return_status        => v_API_return_status,
        x_msg_count            => v_msg_count,
        x_msg_data             => v_msg_data,
        p_encoded              => FND_API.G_FALSE,
        p_init_msg_list        => FND_API.G_TRUE,
        x_dimension_group_id   => v_dimension_group_id,
        x_dim_group_sequence   => v_dim_group_seq,
        p_dimension_varchar_label  => FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_varchar_label,
        p_dim_group_name           => FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_varchar_label ||' '|| v_dim_group_name_seq,
        p_dim_group_display_code   => FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_varchar_label ||' '|| v_dim_group_name_seq,
        p_dim_group_description    => FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_varchar_label ||' '|| v_dim_group_name_seq
      );
    END IF;
      IF (v_API_return_status NOT IN  ('S')) THEN
        FEM_ENGINES_PKG.Tech_Message
          (p_severity => pc_log_level_statement,
          p_module   => 'fem.plsql.fem_intg_hier_rule_eng_pkg.'||'return_status',
          p_msg_text => 'v_API_return_status:' || v_API_return_status);
        FEM_ENGINES_PKG.Tech_Message
          (p_severity => pc_log_level_statement,
          p_module   => 'fem.plsql.fem_intg_hier_rule_eng_pkg.'||'After create_dim_group',
          p_msg_text => 'v_msg_data:' || v_msg_data);
        FEM_ENGINES_PKG.User_Message
          (p_app_name => 'FEM',
          p_msg_text => v_msg_data);
        FEM_ENGINES_PKG.User_Message
          (p_app_name => 'FEM',
          p_msg_name => 'FEM_INTG_FAIL_DIM_GRP');
        RAISE FEM_INTG_fatal_err;
      END IF;
      -- insert the new level to fem_hier_dimension_grps
      -- 14OCT2005 b4652450 MOVED HERE WAS AFTER fem_hier_dimension_grps INSERT
      -- update the _GT table with the dimension_group_id
      update fem_intg_dim_hier_gt
      set dimension_group_id = v_dimension_group_id
      where child_depth_num = v_counter;
      if SQL%ROWCOUNT <= 0 then
        exit;
      end if;
       -- 17OCT2005 BUG 4681970
      v_sql_stmt :=
      'UPDATE fem_intg_dim_hier_gt
         SET display_order_num = '||v_seq_name||'.nextval
         WHERE child_depth_num = '||v_counter||' AND display_order_num = -1';

        FEM_ENGINES_PKG.Tech_Message(
          p_severity => pc_log_level_statement,
          p_module   => 'fem.plsql.Bld_Hier_Multi_Segment3',
          p_msg_text => v_sql_stmt);

      EXECUTE IMMEDIATE v_sql_stmt;
      COMMIT;
      IF (pv_new_hier_obj_created) THEN
        FEM_ENGINES_PKG.Tech_Message(
          p_severity => pc_log_level_statement,
          p_module   => 'fem.plsql.'||'insert into fem_hier_dimension_grps',
          p_msg_text => 'v_dimension_group_id:' || v_dimension_group_id || ' v_rel_dim_group_seq:' || v_counter);
        -- 14OCT2005 b4652450 first is already added from call in Main()
        if v_counter > 1 then
        --dedutta : 5035567 : if check for pv_sequence_enforced_flag
        IF (pv_sequence_enforced_flag = 'Y') THEN
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
          (v_dimension_group_id,
           pv_hier_obj_id,
           v_counter,
           sysdate,
           pv_user_id,
           pv_user_id,
           sysdate,
           pv_login_id,
           1);
        END IF;
        end if;
      END IF;
      v_counter := v_counter + 1;
    end loop;
    -- 17OCT2005 BUG 4681970
    v_seq_stmt := 'DROP SEQUENCE ' || v_seq_name;
    EXECUTE IMMEDIATE v_seq_stmt;
    COMMIT;
    FEM_INTG_NEW_DIM_MEMBER_PKG.Detail_Multi_Segment (v_completion_code, v_dim_process_row_cnt, 'HIER_MULTI_SEG');
    IF v_completion_code <> 0
    THEN
      raise_application_error(-20001, fnd_message.get);
    END IF;
    -- update the hier GT table with the member_ids
    v_sql :=  'update FEM_INTG_DIM_HIER_GT gt
  set gt.parent_id = (select distinct b1.' || fem_intg_new_dim_member_pkg.pv_local_member_col || ' from ' || FEM_INTG_DIM_RULE_ENG_PKG.pv_member_b_table_name || ' b1 ';
    v_sql := v_sql || ' where b1.' || FEM_INTG_DIM_RULE_ENG_PKG.pv_member_display_code_col || ' = gt.parent_display_code and b1.VALUE_SET_ID = :pv_dim_vs_id)';
    v_sql := v_sql || ', gt.child_id = (select distinct b2.' || fem_intg_new_dim_member_pkg.pv_local_member_col || ' from ' || FEM_INTG_DIM_RULE_ENG_PKG.pv_member_b_table_name || ' b2 ';
    v_sql := v_sql || ' where b2.' || FEM_INTG_DIM_RULE_ENG_PKG.pv_member_display_code_col || ' = gt.child_display_code and b2.VALUE_SET_ID  = :pv_dim_vs_id)';

        FEM_ENGINES_PKG.Tech_Message(
          p_severity => pc_log_level_statement,
          p_module   => 'fem.plsql.Bld_Hier_Multi_Segment4',
          p_msg_text => v_sql);

    execute immediate v_sql using pv_dim_vs_id, pv_dim_vs_id;
    COMMIT;
    x_completion_code := PC_SUCCESS;
    return;
  EXCEPTION
    WHEN others THEN
        x_completion_code := PC_FAILURE;
  END Bld_Hier_Multi_segment;
/*****************************************************************
 *              PUBLIC PROCEDURES                                *
 *****************************************************************/
-- ======================================================================
-- Procedure
--     Main
-- Purpose
--     This routine is the Main of the FEM_INTG_HIER_RULE_ENG_PKG
--  History
--     10-28-04  Jee Kim  Created
--     10-20-05  A.Budnik Modification for MultiSeg case.
-- Arguments
--     x_errbuf                   Standard Concurrent Program parameter
--     x_retcode                  Standard Concurrent Program parameter
--     p_hier_rule_obj_def_id     Hierarchy rule version ID
-- ======================================================================
  PROCEDURE Main (x_errbuf OUT NOCOPY  VARCHAR2,
                x_retcode OUT NOCOPY VARCHAR2,
                p_hier_rule_obj_def_id IN NUMBER) IS
    FEM_INTG_fatal_err EXCEPTION;
    TYPE DimensionGroupID_cursor IS REF CURSOR;
    DimensionGroupID   DimensionGroupID_cursor;
    pv_pgm_id                CONSTANT NUMBER := FND_GLOBAL.Conc_Program_Id;
    pv_pgm_app_id            CONSTANT NUMBER := FND_GLOBAL.Prog_Appl_ID;
    v_msg_count                 NUMBER;
    v_msg_data                  VARCHAR2(4000);
    v_API_return_status         VARCHAR2(30);
    v_compl_code                NUMBER;
    v_row_count_tot             NUMBER;
    v_err_count_tot             NUMBER := 0;
    v_duplicate_parent          VARCHAR2(30);
    v_ret_status                BOOLEAN;
    v_sql_stmt                  VARCHAR2(2000);
    v_data_edit_lock_exists     VARCHAR2(30);
    v_rowcount                  NUMBER;
    v_dim_group_conflict        BOOLEAN := FALSE;
    v_child_display_code        VARCHAR2(150);
    l_temp_top_dimension_group_id NUMBER;
    -- bug fix 4563603
    v_display_code                VARCHAR2(150);
    v_parent_display_code         VARCHAR2(150);
    v_offending_parents_list      VARCHAR2(4000);
    CURSOR c_child_of_multi_parent IS
          SELECT  gt.child_display_code
          FROM fem_intg_dim_hier_gt gt
          WHERE gt.parent_display_code <> gt.child_display_code
          and gt.hierarchy_obj_def_id = pv_hier_obj_def_id
          GROUP BY gt.child_display_code
          HAVING count(gt.child_display_code) > 1;

    CURSOR c_multi_parent (p_child_display_code VARCHAR2) IS
          SELECT  DISTINCT gt.parent_display_code
          FROM fem_intg_dim_hier_gt gt
          WHERE gt.parent_display_code <> gt.child_display_code
          and gt.hierarchy_obj_def_id = pv_hier_obj_def_id
          and gt.child_display_code = p_child_display_code;
    -- bug fix 4563603
  BEGIN
  -- Main
  -- 1. Get the hierarchy rule object ID associated with the rule version
  -- 2. Initaillize the requried variables - call Init()
  -- 3. If the hierarchy rule has never been processed before.
  --      (1) Create Object - FEM_Dim_Hier_Util_Pkg.New_Hier_Object
  --      (2) Update hierarchy_obj_id
  --      (3) Update fem_intg_hier_def_segs.hier_obj_def_id
  --    ELSIF the version has not been run before
  --      (1) Create Object Definition - FEM_Dim_Hier_Util_Pkg.New_Hier_Object_Def
  --      (2) Update fem_intg_hier_def_segs.hier_obj_def_id
  --    ELSE
  --      (1) Call FEM_PL_PKG.Obj_Def_Data_Edit_Lock_Exists
  -- 4.If (pv_dim_mapping_option_code = SINGLESEG) then
  --   Call Bld_Hier_Single_Segment( )
  -- 5. Check if any children within the hierarchy are assigned to
  --    multiple parents.
  -- 6. IF v_new_hier_obj_def_created = TRUE THEN
  --      Call INSERT statement to copy hierarchy structure from the
  --      global temporary table FEM_INTG_DIM_HIER_GT to the FEM hierarchy table
  --    ELSE
  --      Call DELETE statement to delete existing hierarchy structure
  --      for the hierarchy object definition.
  --      Call INSERT statement to copy hierarchy structure from the
  --      global temporary table FEM_INTG_DIM_HIER_GT to the FEM hierarchy table
  -- 7. Call routine FEM_INTG_PL_PKG.Final_Process_Logging( ) to complete
  --    final process logging.  Message name to print will be
  --    FEM_INTG_PROC_SUCCESS and the number of output rows will be the
  --    return row count from the hierarchy building routine
  -- 8. Call the Concurrent Program DHMHVFLW to flatten out every hierarchy
  --    version after it has been pushed in FEM
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => 'fem.plsql.fem_intg.hier_eng.main',
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_201',
       p_token1   => 'FUNC_NAME',
       p_value1   => 'FEM_INTG_HIER_RULE_ENG_PKG.Main',
       p_token2   => 'TIME',
       p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
    BEGIN
      -- obtain the hierarchy rule object ID associated
      -- with the rule version
      SELECT o.object_id, o.folder_id, b.object_definition_id,
       b.effective_start_date, b.effective_end_date
      INTO    pv_hier_rule_obj_id,
        pv_folder_id,
        pv_hier_rule_obj_def_id,
        pv_hier_rule_start_date,
        pv_hier_rule_end_date
      FROM    fem_object_definition_b b,
        fem_object_catalog_b o
      WHERE b.object_definition_id = p_hier_rule_obj_def_id
      AND o.object_id = b.object_id
      AND o.object_type_code='OGL_INTG_HIER_RULE';
    EXCEPTION
      -- p_hier_rule_obj_def_id is invalid
      WHEN NO_DATA_FOUND THEN
     FEM_ENGINES_PKG.Tech_Message
    (p_severity => pc_log_level_procedure,
     p_module   => 'fem.plsql.fem_intg.hier_eng.main.no_data_found',
     p_app_name => 'FEM',
     p_msg_name => 'FEM_INTG_HIER_OBJ_NOTFOUND_ERR',
     p_token1   => 'ERR_MSG',
     p_value1   => SQLERRM);
     FEM_ENGINES_PKG.User_Message
    (p_app_name => 'FEM',
     p_msg_name => 'FEM_INTG_HIER_OBJ_NOTFOUND_ERR',
     p_token1   => 'ERR_MSG',
     p_value1   => SQLERRM);
     RAISE FEM_INTG_fatal_err;
    END;
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => 'fem.plsql.fem_intg_hier_rule_eng_pkg',
       p_msg_text => 'pv_user_id:' || pv_user_id
                     ||' pv_folder_id:'||pv_folder_id);

    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => 'fem.plsql.fem_intg_hier_rule_eng_pkg',
       p_msg_text => 'pv_hier_rule_obj_id:' || pv_hier_rule_obj_id
                     ||' pv_hier_rule_obj_def_id:'|| pv_hier_rule_obj_def_id);

    FEM_INTG_PL_PKG.Register_Process_Execution
      (p_obj_id       => pv_hier_rule_obj_id,
       p_obj_def_id     => pv_hier_rule_obj_def_id,
       p_req_id       => pv_req_id,
       p_user_id      => pv_user_id,
       p_login_id     => pv_login_id,
       p_pgm_id       => pv_pgm_id,
       p_pgm_app_id     => pv_pgm_app_id,
       p_module_name      => 'fem.plsql.fem_intg_hier_eng_pkg.' ||
                                     'register_process_execution',
       p_hierarchy_name             => 'Hierarchy for Rule ' ||pv_hier_rule_obj_name,
       x_completion_code                => v_compl_code);
    IF (v_compl_code = 2) THEN
       RAISE FEM_INTG_fatal_err;
    END IF;
    -- Initialize package variables
    Init
      (p_hier_rule_obj_def_id  => p_hier_rule_obj_def_id,
       x_completion_code       => v_compl_code);
    IF (v_compl_code = 2) THEN
       RAISE FEM_INTG_fatal_err;
    END IF;
    -- to create level-based hierarchy
    -- Call API to create new dimension group
    -- 14OCT2005 b4652450 removed space afte 100 in call
  --dedutta : 5035567 : if check for pv_sequence_enforced_flag
  IF (pv_sequence_enforced_flag = 'Y') THEN
    FEM_DIM_GROUPS_UTIL_PKG.create_dim_group
      (x_return_status        => v_API_return_status,
       x_msg_count            => v_msg_count,
       x_msg_data             => v_msg_data,
       p_encoded              => FND_API.G_FALSE,
       p_init_msg_list        => FND_API.G_TRUE,
       x_dimension_group_id   => pv_top_dimension_group_id,
       x_dim_group_sequence   => v_dim_group_seq,
       p_dimension_varchar_label  =>
       FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_varchar_label,
       p_dim_group_name           =>
       FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_varchar_label || ' 100',
       p_dim_group_display_code   =>
       FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_varchar_label || ' 100',
       p_dim_group_description    =>
       FEM_INTG_DIM_RULE_ENG_PKG.pv_dim_varchar_label || ' 100');
  END IF;
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => 'fem.plsql.fem_intg_hier_eng.Infinite loop.',
       p_msg_text => 'pv_top_dimension_group_id:' || pv_top_dimension_group_id);
    IF (v_API_return_status NOT IN  ('S')) THEN
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_statement,
         p_module   => 'fem.plsql.fem_intg_hier_rule_eng_pkg.'||'return_status',
         p_msg_text => 'v_API_return_status:' || v_API_return_status);
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_statement,
         p_module   => 'fem.plsql.fem_intg_hier_rule_eng_pkg.'||'After create_dim_group',
         p_msg_text => 'v_msg_data:' || v_msg_data);
      FEM_ENGINES_PKG.User_Message
        (p_app_name => 'FEM',
         p_msg_text => v_msg_data);
      FEM_ENGINES_PKG.User_Message
        (p_app_name => 'FEM',
         p_msg_name => 'FEM_INTG_FAIL_DIM_GRP');
      RAISE FEM_INTG_fatal_err;
    END IF;
    IF (pv_sequence_enforced_flag = 'N') THEN
    	pv_grp_seq_code := 'NO_GROUPS';
        l_temp_top_dimension_group_id := NULL;
    ElSE
    	pv_grp_seq_code := 'SEQUENCE_ENFORCED_SKIP_LEVEL';
        l_temp_top_dimension_group_id := pv_top_dimension_group_id;
    END IF;
    -- This hierarchy rule has never been processed before,
    -- then create hier object.
    IF (pv_hier_obj_id = -1) THEN
       FEM_Dim_Hier_Util_Pkg.New_Hier_Object
        (p_api_version          => pc_api_version,
         p_commit               => 'T',
         p_encoded              => FND_API.G_FALSE,
         p_init_msg_list        => FND_API.G_TRUE,
         x_return_status        => v_API_return_status,
         x_msg_count            => v_msg_count,
         x_msg_data             => v_msg_data,
         x_hier_obj_id          => pv_hier_obj_id,
         x_hier_obj_def_id      => pv_hier_obj_def_id,
         p_folder_id            => pv_folder_id,
         p_global_vs_combo_id   => pv_gvsc_id,
         p_object_access_code   => 'R',
         p_object_origin_code   => 'USER',
         p_object_name          => 'Hierarchy for Rule ' || substr(pv_hier_rule_obj_name,1,100),
         p_description          => NULL,
         p_effective_start_date => pv_hier_rule_start_date,
         p_effective_end_date   => pv_hier_rule_end_date,
         p_obj_def_name         => 'Hierarchy for Rule ' || substr(pv_hier_rule_obj_name,1,100) ||' '|| to_char(sysdate,'MM/DD/YYYY HH24:MI:SS'),
         p_dimension_id         => pv_dim_id,
         p_hier_type_code       => 'OPEN',
         p_grp_seq_code         => pv_grp_seq_code,
         p_multi_top_flg        => 'N',
         p_fin_ctg_flg          => 'N',
         p_multi_vs_flg         => 'N',
         p_hier_usage_code      => 'STANDARD',
         p_val_set_id1          => pv_dim_vs_id,
         p_dim_grp_id1          => l_temp_top_dimension_group_id,
         p_flat_rows_flag       => pv_flatten_hier_flag);
      IF (v_API_return_status NOT IN  ('S')) THEN
        FEM_ENGINES_PKG.Tech_Message
          (p_severity => pc_log_level_statement,
           p_module   => 'fem.plsql.fem_intg_hier_rule_eng_pkg.'||'return_status',
           p_msg_text => 'v_API_return_status:' || v_API_return_status);
        FEM_ENGINES_PKG.Tech_Message
          (p_severity => pc_log_level_statement,
           p_module   => 'fem.plsql.fem_intg_hier_eng.' ||'after New_Hier_Object',
            p_msg_text => 'v_msg_data:' || v_msg_data);
        FEM_ENGINES_PKG.User_Message
         (p_app_name => 'FEM',
          p_msg_text => v_msg_data);
        FEM_ENGINES_PKG.User_Message
         (p_app_name => 'FEM',
          p_msg_name => 'FEM_INTG_FAIL_NEW_HIER');
         RAISE FEM_INTG_fatal_err;
      END IF;
      pv_new_hier_obj_created := TRUE;
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_statement,
         p_module   => 'fem.plsql.fem_intg_hier_eng.' ||'after New_Hier_Object',
         p_msg_text => 'pv_hier_obj_id:' ||  pv_hier_obj_id||
                       ' pv_hier_obj_def_id:' || pv_hier_obj_def_id);
      -- Update hierarchy_obj_id
      UPDATE fem_intg_hier_rules
      SET hierarchy_obj_id  = pv_hier_obj_id,
          last_updated_by   = pv_user_id,
          last_update_date  = sysdate,
          last_update_login = pv_login_id
      WHERE hier_rule_obj_id = pv_hier_rule_obj_id;
      -- Update fem_hierarchies
      UPDATE fem_hierarchies
      SET value_set_id = pv_dim_vs_id
      WHERE hierarchy_obj_id = pv_hier_obj_id;
      -- Update hierarchy_obj_id
      UPDATE fem_intg_hier_def_segs
      SET hier_obj_def_id   = pv_hier_obj_def_id,
          last_updated_by   = pv_user_id,
          last_update_date  = sysdate,
          last_update_login = pv_login_id
      WHERE  hier_rule_obj_def_id = pv_hier_rule_obj_def_id
      AND    display_order_num = 1;
      v_new_hier_obj_def_created := TRUE;
      COMMIT;
    ELSIF (pv_hier_obj_def_id = -1) THEN
      -- If the rule version has never been run before,
      -- create a new version of the hierarchy.
      FEM_Dim_Hier_Util_Pkg.New_Hier_Object_Def
        (p_api_version          => pc_api_version,
         p_commit               => 'T',
         p_encoded              => FND_API.G_FALSE,
         p_init_msg_list        => FND_API.G_TRUE,
         x_return_status        => v_API_return_status,
         x_msg_count            => v_msg_count,
         x_msg_data             => v_msg_data,
         x_hier_obj_def_id      => pv_hier_obj_def_id,
         p_hier_obj_id          => pv_hier_obj_id,
         p_obj_def_name         => 'Hierarchy for Rule ' || substr(pv_hier_rule_obj_name,1,100) ||' '|| to_char(sysdate,'MM/DD/YYYY HH24:MI:SS'),
         p_effective_start_date => pv_hier_rule_start_date,
         p_effective_end_date   => pv_hier_rule_end_date,
          p_object_origin_code   => 'USER');
      IF (v_API_return_status NOT IN  ('S')) THEN
        FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_statement,
         p_module   => 'fem.plsql.fem_intg_hier_rule_eng_pkg.'||'return_status',
         p_msg_text => 'v_API_return_status:' || v_API_return_status);
        FEM_ENGINES_PKG.Tech_Message
          (p_severity => pc_log_level_statement,
           p_module   => 'fem.plsql.fem_intg_hier_eng.' ||'after New_Hier_Object_Def',
           p_msg_text => 'v_msg_data:' || v_msg_data);
        FEM_ENGINES_PKG.User_Message
          (p_app_name => 'FEM',
           p_msg_text => v_msg_data);
        FEM_ENGINES_PKG.User_Message
          (p_app_name => 'FEM',
           p_msg_name => 'FEM_INTG_FAIL_NEW_HIER');
        RAISE FEM_INTG_fatal_err;
      END IF;
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_statement,
         p_module   => 'fem.plsql.fem_intg_hier_eng.' ||'after New_Hier_Object_Def',
         p_msg_text => 'pv_hier_obj_id:' ||  pv_hier_obj_id||
                       ' pv_hier_obj_def_id:' || pv_hier_obj_def_id);
      -- Update hierarchy obj def id
      UPDATE fem_intg_hier_def_segs
      SET hier_obj_def_id   = pv_hier_obj_def_id,
          last_updated_by   = pv_user_id,
          last_update_date  = sysdate,
          last_update_login = pv_login_id
      WHERE  hier_rule_obj_def_id = pv_hier_rule_obj_def_id
      AND    display_order_num = 1;
      v_new_hier_obj_def_created := TRUE;
      COMMIT;
    ELSE
    -- the hierarchy object definition already exists,
    -- check for the data edit locks for overwrite.
      FEM_PL_PKG.Obj_Def_Data_Edit_Lock_Exists(
    p_object_definition_id    =>  pv_hier_obj_def_id,
    x_data_edit_lock_exists   =>  v_data_edit_lock_exists);
      IF (v_data_edit_lock_exists = 'T') THEN
       FEM_ENGINES_PKG.User_Message
        (p_app_name => 'FEM',
         p_msg_name => 'FEM_INTG_DATA_LOCK_EXIST');
        RAISE FEM_INTG_fatal_err;
      END IF;
    END IF;
    IF (pv_dim_mapping_option_code = 'SINGLESEG') THEN
      FEM_ENGINES_PKG.Tech_Message
         (p_severity => pc_log_level_statement,
          p_module   => 'fem.plsql.fem_intg_hier_eng.Bld_Hier_Single_Segment',
          p_msg_text => 'pv_dim_mapping_option_code:' || pv_dim_mapping_option_code);
      Bld_Hier_Single_Segment
        (x_completion_code       => v_compl_code,
         x_row_count_tot         => v_row_count_tot);

      IF (v_compl_code = 2) THEN
         RAISE FEM_INTG_fatal_err;
      END IF;
     -- MULTISEG Hierarchy case
     ELSIF (pv_dim_mapping_option_code = 'MULTISEG') THEN
      FEM_ENGINES_PKG.Tech_Message
         (p_severity => pc_log_level_statement,
          p_module   => 'fem.plsql.fem_intg_hier_eng.Bld_component_Hiers',
          p_msg_text => 'pv_dim_mapping_option_code:' || pv_dim_mapping_option_code);
      -- Build single segment component hierarchies as basis for concatenated hierarcy
      Bld_component_Hiers
        (x_completion_code       => v_compl_code);
      IF (v_compl_code = 2) THEN
          RAISE FEM_INTG_fatal_err;
      END IF;

      -- Build Multi segment hierarchy  using above componenets
      Bld_Hier_Multi_Segment (x_completion_code       => v_compl_code);

      IF (v_compl_code = 2) THEN
           RAISE FEM_INTG_fatal_err;
      END IF;
    ELSE
      -- Not single seg or multi seg so raise error
      FEM_ENGINES_PKG.Tech_Message
        (p_severity    => pc_log_level_procedure,
         p_module   => 'fem.plsql.fem_intg_hier_eng.main.',
         p_app_name => 'FEM',
         p_msg_name => 'FEM_INTG_HIER_MULTISEG_ERR',
         p_token1   => 'VAR_NAME',
         p_value1   => 'pv_dim_mapping_option_code',
         p_token2   => 'VAR_VAL',
         p_value2   => pv_dim_mapping_option_code);
      FEM_ENGINES_PKG.User_Message
        (p_app_name => 'FEM',
         p_msg_name => 'FEM_INTG_HIER_MULTISEG_ERR');
      RAISE FEM_INTG_fatal_err;
    END IF;
    -- Check if any children within the hierarchy are assigned to
    -- multiple parents. Just single segment case here. For multi seg case
    -- this is done in bld_component_hiers in loop for each component hier
    IF (pv_dim_mapping_option_code = 'SINGLESEG') THEN
    BEGIN
      SELECT 'Duplicate'
      INTO v_duplicate_parent
      FROM dual
      WHERE EXISTS
     (SELECT gt.child_id
      FROM fem_intg_dim_hier_gt gt
      WHERE gt.parent_id <> gt.child_id
      GROUP BY gt.child_id
      HAVING count(gt.child_id) > 1);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        null;
    END;
    IF (v_duplicate_parent = 'Duplicate') THEN
      FEM_ENGINES_PKG.Tech_Message
       (p_severity => pc_log_level_procedure,
        p_module   => 'fem.plsql.fem_intg_hier_eng.main.' || 'duplicate',
        p_app_name => 'FEM',
        p_msg_name => 'FEM_INTG_HIER_MULTI_PARENT_ERR',
        p_token1   => 'VAR_NAME',
        p_value1   => 'v_duplicate_parent',
        p_token2   => 'VAR_VAL',
        p_value2   => v_duplicate_parent);
      FEM_ENGINES_PKG.User_Message
        (p_app_name => 'FEM',
         p_msg_name => 'FEM_INTG_HIER_MULTI_PARENT_ERR');
          --bug fix 4563603
          FEM_ENGINES_PKG.Tech_Message
             (p_severity => pc_log_level_procedure,
              p_module   => 'fem.plsql.fem_intg_hier_eng.Bld_Component_Hier.' || 'duplicate',
              p_app_name => 'FEM',
              p_msg_text => ' ');

          FEM_ENGINES_PKG.User_Message
              (p_app_name => 'FEM',
               p_msg_text => ' ');

          FEM_ENGINES_PKG.Tech_Message
           (p_severity => pc_log_level_procedure,
            p_module   => 'fem.plsql.fem_intg_hier_eng.Bld_Component_Hier.' || 'duplicate',
            p_app_name => 'FEM',
            p_msg_name => 'FEM_INTG_HIER_MULT_PARENTS');

           FEM_ENGINES_PKG.User_Message
            (p_app_name => 'FEM',
             p_msg_name => 'FEM_INTG_HIER_MULT_PARENTS');

          OPEN c_child_of_multi_parent;
          LOOP
              FETCH c_child_of_multi_parent INTO v_display_code;
              EXIT WHEN c_child_of_multi_parent%NOTFOUND;

              --Bug fix 5577544
              v_offending_parents_list := NULL;

              OPEN c_multi_parent(v_display_code);
              LOOP
                  FETCH c_multi_parent INTO v_parent_display_code;
                  EXIT WHEN c_multi_parent%NOTFOUND;
                  v_offending_parents_list := v_offending_parents_list || v_parent_display_code || ', ';
              END LOOP;
              CLOSE c_multi_parent;
              v_offending_parents_list := SUBSTR(v_offending_parents_list,1,LENGTH(v_offending_parents_list)-2);

              FEM_ENGINES_PKG.Tech_Message
               (p_severity => pc_log_level_procedure,
                p_module   => 'fem.plsql.fem_intg.hier_eng.',
                p_app_name => 'FEM',
                p_msg_name => 'FEM_INTG_HIER_PARENT_CHILD_LST',
                p_token1   => 'CHILD',
                p_value1   => v_display_code,
                p_token2   => 'PARENTS',
                p_value2   => v_offending_parents_list);

              FEM_ENGINES_PKG.User_Message
              (p_app_name => 'FEM',
               p_msg_name => 'FEM_INTG_HIER_PARENT_CHILD_LST',
               p_token1   => 'CHILD',
               p_value1   => v_display_code,
               p_token2   => 'PARENTS',
               p_value2   => v_offending_parents_list);

          END LOOP;
          CLOSE c_child_of_multi_parent;
          FEM_ENGINES_PKG.Tech_Message
             (p_severity => pc_log_level_procedure,
              p_module   => 'fem.plsql.fem_intg_hier_eng.Bld_Component_Hier.' || 'duplicate',
              p_app_name => 'FEM',
              p_msg_text => ' ');

          FEM_ENGINES_PKG.User_Message
              (p_app_name => 'FEM',
               p_msg_text => ' ');
           --bug fix 4563603

      RAISE FEM_INTG_fatal_err;
    END IF;
    END IF;
    -- To check for the confict dimension group
    v_sql_stmt :=
         'SELECT gt.child_display_code
            FROM '||pv_dim_memb_b_tab||' b,
            fem_intg_dim_hier_gt gt
     WHERE b.'||pv_dim_memb_disp_col ||'= gt.child_display_code
             AND b.value_set_id = '||pv_dim_vs_id||'
             AND b.dimension_group_id <> gt.dimension_group_id';
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => 'fem.plsql.fem_intg_hier_eng.main.' ,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'v_sql_stmt',
       p_token2   => 'VAR_VAL',
       p_value2   => v_sql_stmt);
    OPEN DimensionGroupID FOR v_sql_stmt;
    LOOP
      FETCH DimensionGroupID INTO v_child_display_code;
      EXIT WHEN DimensionGroupID%NOTFOUND;
      v_dim_group_conflict := TRUE;
      FEM_ENGINES_PKG.Tech_Message
       (p_severity => pc_log_level_procedure,
        p_module   => 'fem.plsql.fem_intg.hier_eng.',
        p_app_name => 'FEM',
        p_msg_name => 'FEM_INTG_HIER_CONFLICT_DIM_GRP',
        p_token1   => 'DISP_CODE',
        p_value1   => v_child_display_code);
      FEM_ENGINES_PKG.User_Message
      (p_app_name => 'FEM',
       p_msg_name => 'FEM_INTG_HIER_CONFLICT_DIM_GRP',
       p_token1   => 'DISP_CODE',
       p_value1   => v_child_display_code);
    END LOOP;
    CLOSE DimensionGroupID;
    IF (v_dim_group_conflict = TRUE) THEN
      RAISE FEM_INTG_fatal_err;
    END IF;
    -- Update member b table for the dimension_group_id
   IF (pv_sequence_enforced_flag = 'Y') THEN
    v_sql_stmt :=
      'UPDATE ' ||pv_dim_memb_b_tab||'
    SET dimension_group_id =
        (SELECT dimension_group_id
     FROM fem_intg_dim_hier_gt
    WHERE child_display_code = '||pv_dim_memb_disp_col||'),
              last_updated_by   = :pv_user_id,
              last_update_date  = sysdate,
              last_update_login = :pv_login_id
   WHERE value_set_id = :pv_dim_vs_id
           AND '||pv_dim_memb_col||' IN
               (SELECT child_id
                  FROM fem_intg_dim_hier_gt)';
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => 'fem.plsql.fem_intg_hier_eng.main.' ,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'v_sql_stmt',
       p_token2   => 'VAR_VAL',
       p_value2   => v_sql_stmt);
    EXECUTE IMMEDIATE v_sql_stmt
            USING pv_user_id,
                  pv_login_id,
                  pv_dim_vs_id;
    END IF;
    COMMIT;
    IF (v_new_hier_obj_def_created = TRUE) THEN
      -- Call INSERT statement to copy hierarchy structure from the
      -- global temporary table FEM_INTG_DIM_HIER_GT to the FEM hierarchy table
      -- 29AUG05 added WHERE hierarchy_obj_def_id = :pv_hier_obj_def_id
      v_sql_stmt :=
  'INSERT INTO '||pv_dim_hier_tab||'
  (hierarchy_obj_def_id, parent_depth_num, parent_id,
     parent_value_set_id, child_depth_num, child_id,
     child_value_set_id, single_depth_flag,
     display_order_num, weighting_pct,
     creation_date, created_by, last_update_date,
     last_updated_by, last_update_login, object_version_number)
  SELECT
     :pv_hier_obj_def_id,
     gt.parent_depth_num,
     gt.parent_id,
     :pv_dim_vs_id,
     gt.child_depth_num,
     gt.child_id,
     :pv_dim_vs_id,
     ''Y'',
     gt.display_order_num, NULL,
     SYSDATE,
     :pv_user_id,
     SYSDATE,
     :pv_user_id,
     :pv_login_id,
     1
  FROM fem_intg_dim_hier_gt gt
  WHERE hierarchy_obj_def_id = :pv_hier_obj_def_id';
  FEM_ENGINES_PKG.Tech_Message
  (p_severity => pc_log_level_procedure,
   p_module   => 'fem.plsql.fem_intg_hier_eng.main.' ,
   p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_204',
         p_token1   => 'VAR_NAME',
         p_value1   => 'v_sql_stmt',
         p_token2   => 'VAR_VAL',
         p_value2   => v_sql_stmt);
      EXECUTE IMMEDIATE v_sql_stmt
              USING pv_hier_obj_def_id,
                    pv_dim_vs_id,
                    pv_dim_vs_id,
                    pv_user_id,
                    pv_user_id,
                    pv_login_id,
                    pv_hier_obj_def_id;
      COMMIT;
    ELSE
    -- Call DELETE statement to delete existing hierarchy structure
    -- for the hierarchy object definition.
    v_sql_stmt := 'DELETE FROM '||pv_dim_hier_tab||'
                   WHERE hierarchy_obj_def_id = :pv_hier_obj_def_id';
  FEM_ENGINES_PKG.Tech_Message
  (p_severity => pc_log_level_procedure,
   p_module   => 'fem.plsql.fem_intg_hier_eng.main.',
   p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_204',
         p_token1   => 'VAR_NAME',
         p_value1   => 'v_sql_stmt',
         p_token2   => 'VAR_VAL',
         p_value2   => v_sql_stmt);
      EXECUTE IMMEDIATE v_sql_stmt
              USING pv_hier_obj_def_id;
      -- Call INSERT statement to copy hierarchy structure from the
      -- global temporary table FEM_INTG_DIM_HIER_GT to the FEM hierarchy table
      v_sql_stmt :=
  'INSERT INTO '||pv_dim_hier_tab||'
  (hierarchy_obj_def_id, parent_depth_num, parent_id,
     parent_value_set_id, child_depth_num, child_id,
     child_value_set_id, single_depth_flag,
     display_order_num, weighting_pct,
     creation_date, created_by, last_update_date,
     last_updated_by, last_update_login, object_version_number)
  SELECT
     :pv_hier_obj_def_id,
     gt.parent_depth_num,
     gt.parent_id,
     :pv_dim_vs_id,
     gt.child_depth_num,
     gt.child_id,
     :pv_dim_vs_id,
     ''Y'',
     gt.display_order_num, NULL,
     SYSDATE,
     :pv_user_id,
     SYSDATE,
     :pv_user_id,
     :pv_login_id,
     1
   FROM fem_intg_dim_hier_gt gt
   WHERE gt.hierarchy_obj_def_id = :pv_hier_obj_def_id';
      FEM_ENGINES_PKG.Tech_Message
  (p_severity => pc_log_level_procedure,
   p_module   => 'fem.plsql.fem_intg_hier_eng.main.',
   p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_204',
         p_token1   => 'VAR_NAME',
         p_value1   => 'v_sql_stmt',
         p_token2   => 'VAR_VAL',
         p_value2   => v_sql_stmt);
      EXECUTE IMMEDIATE v_sql_stmt
              USING pv_hier_obj_def_id,
        pv_dim_vs_id,
        pv_dim_vs_id,
        pv_user_id,
        pv_user_id,
        pv_login_id,
        pv_hier_obj_def_id;
    END IF;
    COMMIT;
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => 'fem.plsql.fem_intg_hier_eng.',
       p_msg_text => 'before the Final_Process_Logging');
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => 'fem.plsql.fem_intg_hier_eng.',
       p_msg_text => 'pv_hier_rule_obj_id: ' ||pv_hier_rule_obj_id||
                     ' pv_hier_rule_obj_def_id:' ||pv_hier_rule_obj_def_id ||
                     ' pv_req_id:' ||pv_req_id ||
                     ' pv_user_id:' ||pv_user_id ||
                     ' pv_login_id:' || pv_login_id);
    -- Call routine FEM_INTG_PL_PKG.Final_Process_Logging( ) to complete
    -- final process logging.  Message name to print will be
    -- FEM_INTG_PROC_SUCCESS and the number of output rows will be the
    -- return row count from the hierarchy building routine
    FEM_INTG_PL_PKG.Final_Process_Logging
      (p_obj_id       => pv_hier_rule_obj_id,
       p_obj_def_id     => pv_hier_rule_obj_def_id,
       p_req_id       => pv_req_id,
       p_user_id      => pv_user_id,
       p_login_id     => pv_login_id,
       p_exec_status      => 'SUCCESS',
       p_row_num_loaded     => v_row_count_tot,
       p_err_num_count      => v_err_count_tot,
       p_final_msg_name     => 'FEM_INTG_PROC_SUCCESS',
       p_module_name      =>'fem.plsql.fem_intg_hier_eng_pkg.' ||
                        'final_process_logging',
       x_completion_code                => v_compl_code);
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => 'fem.plsql.fem_intg_hier_eng.',
       p_msg_text => 'after the Final_Process_Logging');
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => 'fem.plsql.fem_intg_hier_eng.',
       p_msg_text => 'v_row_count_tot:' || v_row_count_tot||
                     ' v_err_count_tot:' || v_err_count_tot||
                     ' v_compl_code:' ||v_compl_code);
    COMMIT;
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => 'fem.plsql.fem_intg_hier_eng.main.' ,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_202',
       p_token1   => 'FUNC_NAME',
       p_value1   => 'FEM_INTG_HIER_RULE_ENG_PKG.Main',
       p_token2   => 'TIME',
       p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
    v_ret_status := FND_CONCURRENT.Set_Completion_Status
                      (status => 'NORMAL', message => NULL);
    IF (pv_flatten_hier_flag = 'Y') THEN
     -- To flatten out every hierarchy version after it has been pushed in FEM.
     -- To do this, call the Concurrent Program DHMHVFLW
      v_req_id := FND_REQUEST.Submit_Request
      (application  => 'FEM',
       program => 'DHMHVFLW',
       argument1 => pv_hier_obj_id,
       argument2 => pv_hier_obj_def_id);
      FEM_ENGINES_PKG.Tech_Message
  (p_severity => pc_log_level_procedure,
   p_module   => 'fem.plsql.fem_intg.hier_eng.Main',
   p_app_name => 'FEM',
   p_msg_name => 'FEM_INTG_HIER_DHMHVFLW_SUBMIT',
   p_token1   => 'REQ_ID',
   p_value1   => v_req_id);
      FEM_ENGINES_PKG.User_Message
  (p_app_name => 'FEM',
   p_msg_name => 'FEM_INTG_HIER_DHMHVFLW_SUBMIT',
   p_token1   => 'REQ_ID',
   p_value1   => v_req_id);

    END IF;
  EXCEPTION
    WHEN FEM_INTG_fatal_err THEN
      ROLLBACk;
      FEM_INTG_PL_PKG.Final_Process_Logging
  (p_obj_id     => pv_hier_rule_obj_id,
   p_obj_def_id     => pv_hier_rule_obj_def_id,
   p_req_id     => pv_req_id,
   p_user_id      => pv_user_id,
   p_login_id     => pv_login_id,
   p_exec_status      => 'ERROR_RERUN',
   p_row_num_loaded   => 0,
   p_err_num_count    => v_err_count_tot,
   p_final_msg_name   => 'FEM_INTG_PROC_FAILURE',
   p_module_name      =>'fem.plsql.fem_intg_hier_eng_pkg.' ||
              'final_process_logging',
       x_completion_code                => v_compl_code);
      FEM_ENGINES_PKG.Tech_Message
  (p_severity => pc_log_level_procedure,
   p_module   => 'fem.plsql.fem_intg_hier_eng.main.',
   p_app_name => 'FEM',
   p_msg_name => 'FEM_GL_POST_203',
   p_token1   => 'FUNC_NAME',
   p_value1   => 'FEM_INTG_HIER_RULE_ENG_PKG.Main',
   p_token2   => 'TIME',
   p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
      v_ret_status := FND_CONCURRENT.Set_Completion_Status
                      (status => 'ERROR', message => NULL);
    WHEN OTHERS THEN
      ROLLBACK;
      FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_unexpected,
       p_module   => 'fem.plsql.fem_intg_hier_eng.main.' ,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_215',
       p_token1   => 'ERR_MSG',
       p_value1   => SQLERRM);
      FEM_ENGINES_PKG.User_Message
      (p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_215',
       p_token1   => 'ERR_MSG',
       p_value1   => SQLERRM);
      FEM_INTG_PL_PKG.Final_Process_Logging
  (p_obj_id     => pv_hier_rule_obj_id,
   p_obj_def_id     => pv_hier_rule_obj_def_id,
   p_req_id     => pv_req_id,
   p_user_id      => pv_user_id,
   p_login_id     => pv_login_id,
   p_exec_status      => 'ERROR_RERUN',
   p_row_num_loaded   => 0,
   p_err_num_count    => v_err_count_tot,
   p_final_msg_name   => 'FEM_INTG_PROC_FAILURE',
   p_module_name      =>'fem.plsql.fem_intg_hier_eng_pkg.' ||
              'final_process_logging',
       x_completion_code                => v_compl_code);
      FEM_ENGINES_PKG.Tech_Message
  (p_severity => pc_log_level_procedure,
   p_module   => 'fem.plsql.fem_intg_hier_eng.main.',
   p_app_name => 'FEM',
   p_msg_name => 'FEM_GL_POST_203',
   p_token1   => 'FUNC_NAME',
   p_value1   => 'FEM_INTG_HIER_RULE_ENG_PKG.Main',
   p_token2   => 'TIME',
   p_value2   => TO_CHAR(SYSDATE)||' '||TO_CHAR(SYSDATE,'HH24:MI:SS'));
      v_ret_status := FND_CONCURRENT.Set_Completion_Status
                      (status => 'ERROR', message => NULL);
  END Main;
END FEM_INTG_HIER_RULE_ENG_PKG;

/
