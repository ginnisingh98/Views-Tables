--------------------------------------------------------
--  DDL for Package Body FEM_INTG_BAL_ENG_LOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_INTG_BAL_ENG_LOAD_PKG" AS
/* $Header: fem_intg_be_load.plb 120.3.12010000.3 2009/09/04 11:53:57 amantri ship $ */


--
-- PRIVATE GLOBAL VARIABLES
--
  pc_log_level_statement       CONSTANT NUMBER   := fnd_log.level_statement;
  pc_log_level_procedure       CONSTANT NUMBER   := fnd_log.level_procedure;
  pc_log_level_event           CONSTANT NUMBER   := fnd_log.level_event;
  pc_log_level_exception       CONSTANT NUMBER   := fnd_log.level_exception;
  pc_log_level_error           CONSTANT NUMBER   := fnd_log.level_error;
  pc_log_level_unexpected      CONSTANT NUMBER   := fnd_log.level_unexpected;


  -- holds a new line character
  pv_nl	VARCHAR2(1);


--
-- PRIVATE PROCEDURES
--

  --
  -- Function
  --   Get_Flex_Values_Query
  -- Purpose
  --   Gets the query to pick up the all the ledger's bsvs.
  -- Return Value
  --   The text SQL query to get the balances segment values
  -- Example
  --   FEM_INTG_BAL_ENG_LOAD_PKG.Get_Flex_Value_Query;
  -- Notes
  --
  FUNCTION Get_Flex_Values_Query RETURN VARCHAR2 IS
    v_query	VARCHAR2(2000);

    v_value_set_id	NUMBER;
    v_value_set_type	VARCHAR2(30);

    v_table_name	VARCHAR2(50);
    v_value_col_name	VARCHAR2(50);
    v_where_clause	VARCHAR2(1000);
    v_summary_col_name	VARCHAR2(50);
  BEGIN

    SELECT	fvs.flex_value_set_id,
		fvs.validation_type
    INTO	v_value_set_id,
		v_value_set_type
    FROM	gl_ledgers lgr,
		fnd_segment_attribute_values sav,
		fnd_id_flex_segments ifs,
		fnd_flex_value_sets fvs
    WHERE	lgr.ledger_id = FEM_GL_POST_PROCESS_PKG.pv_ledger_id
    AND		sav.application_id = 101
    AND		sav.id_flex_code = 'GL#'
    AND		sav.id_flex_num = lgr.chart_of_accounts_id
    AND		sav.segment_attribute_type = 'GL_BALANCING'
    AND		sav.attribute_value = 'Y'
    AND		ifs.application_id = 101
    AND		ifs.id_flex_code = 'GL#'
    AND		ifs.id_flex_num = lgr.chart_of_accounts_id
    AND		ifs.application_column_name = sav.application_column_name
    AND		fvs.flex_value_set_id = ifs.flex_value_set_id;

    -- Set the query text based on the value set type
    IF v_value_set_type = 'I' THEN -- Independent value set
      v_query :=
'SELECT flex_value' || pv_nl ||
'FROM   fnd_flex_values' || pv_nl ||
'WHERE  flex_value_set_id = ' || v_value_set_id || pv_nl ||
'AND    summary_flag <> ''Y''';
    ELSE -- Table-validated value set
      SELECT	application_table_name,
		value_column_name,
		additional_where_clause,
		summary_column_name
      INTO	v_table_name,
		v_value_col_name,
		v_where_clause,
		v_summary_col_name
      FROM	fnd_flex_validation_tables
      WHERE	flex_value_set_id = v_value_set_id;

      v_query :=
'SELECT flex.flex_value' || pv_nl ||
'FROM   (SELECT ' || v_value_col_name || ' flex_value,' || pv_nl ||
'               ' || v_summary_col_name || ' summary_flag' || pv_nl ||
'        FROM   ' || v_table_name || pv_nl ||
'        ' || v_where_clause || ') flex' || pv_nl ||
'WHERE  flex.summary_flag <> ''Y''';
    END IF;

    RETURN v_query;
  END Get_Flex_Values_Query;




--
-- PUBLIC PROCEDURES
--

  PROCEDURE Load_Std_Balances(	x_completion_code	OUT NOCOPY NUMBER,
				x_num_rows_inserted	OUT NOCOPY NUMBER,
				p_bsv_range_low		VARCHAR2,
				p_bsv_range_high	VARCHAR2,
				p_maintain_qtd		VARCHAR2) IS
    v_sql	VARCHAR2(32767);
    v_sql_incr	VARCHAR2(32767); -- For holding incremental load statements

    -- These three will hold common code that will be used in the statements
    v_insert		VARCHAR2(2000);
    v_ccmap_selection	VARCHAR2(1000);
    v_ccmap_join	VARCHAR2(2000);
    v_ccy_join		VARCHAR2(1000);

    v_intermediate_rows_inserted	NUMBER;

    v_xat_basic_type_attr_id	NUMBER;
    v_xat_basic_type_v_id	NUMBER;
    v_xat_sign_attr_id		NUMBER;
    v_xat_sign_v_id		NUMBER;

    v_error_code		NUMBER;

    v_bsv_low			VARCHAR2(100);
    v_bsv_high			VARCHAR2(100);

    CURSOR unmapped_exists_c IS
    SELECT 1
    FROM fem_bal_post_interim_gt
    WHERE posting_error_flag = 'Y'
    AND   (nvl(xtd_balance_e,0) <> 0 OR
           nvl(xtd_balance_f,0) <> 0 OR
           nvl(ytd_balance_e,0) <> 0 OR
           nvl(ytd_balance_f,0) <> 0 OR
           nvl(qtd_balance_e,0) <> 0 OR
           nvl(qtd_balance_f,0) <> 0 OR
           nvl(ptd_debit_balance_e,0) <> 0 OR
           nvl(ptd_credit_balance_e,0) <> 0 OR
           nvl(ytd_debit_balance_e,0) <> 0 OR
           nvl(ytd_credit_balance_e,0) <> 0);

    dummy	NUMBER;

    v_module	VARCHAR2(100);

    --bug fix 5585720
    v_flex_query_stmt	VARCHAR2(2000);

  BEGIN
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => v_module,
       p_msg_text => 'BEGIN');

    pv_nl := '
';
    v_module := 'fem.plsql.fem_intg_bal_eng_load.load_std_balances';

    x_completion_code := 0;
    x_num_rows_inserted := 0;

    FEM_DIMENSION_UTIL_PKG.get_dim_attr_id_ver_id(
      p_dim_id		=> FEM_GL_POST_PROCESS_PKG.pv_ext_acct_type_dim_id,
      p_attr_label	=> 'BASIC_ACCOUNT_TYPE_CODE',
      x_attr_id		=> v_xat_basic_type_attr_id,
      x_ver_id		=> v_xat_basic_type_v_id,
      x_err_code	=> v_error_code);

    FEM_DIMENSION_UTIL_PKG.get_dim_attr_id_ver_id(
      p_dim_id		=> FEM_GL_POST_PROCESS_PKG.pv_ext_acct_type_dim_id,
      p_attr_label	=> 'SIGN',
      x_attr_id		=> v_xat_sign_attr_id,
      x_ver_id		=> v_xat_sign_v_id,
      x_err_code	=> v_error_code);


    v_insert :=
'INSERT INTO FEM_BAL_POST_INTERIM_GT(INTERFACE_ROWID, DELTA_RUN_ID, ' ||
'BAL_POST_TYPE_CODE, DATASET_CODE, CAL_PERIOD_ID,  LEDGER_ID, ' ||
'SOURCE_SYSTEM_CODE, COMPANY_COST_CENTER_ORG_ID, FINANCIAL_ELEM_ID, ' ||
'PRODUCT_ID, NATURAL_ACCOUNT_ID, CHANNEL_ID, LINE_ITEM_ID, PROJECT_ID, ' ||
'CUSTOMER_ID, ENTITY_ID, INTERCOMPANY_ID, TASK_ID, USER_DIM1_ID, ' ||
'USER_DIM2_ID, USER_DIM3_ID, USER_DIM4_ID, USER_DIM5_ID, USER_DIM6_ID, ' ||
'USER_DIM7_ID, USER_DIM8_ID, USER_DIM9_ID, USER_DIM10_ID, CURRENCY_CODE, ' ||
'CURRENCY_TYPE_CODE, POSTING_ERROR_FLAG, CODE_COMBINATION_ID, ' ||
'XTD_BALANCE_E,  QTD_BALANCE_E, YTD_BALANCE_E, XTD_BALANCE_F, ' ||
'QTD_BALANCE_F,  YTD_BALANCE_F, PTD_DEBIT_BALANCE_E, PTD_CREDIT_BALANCE_E, ' ||
'YTD_DEBIT_BALANCE_E, YTD_CREDIT_BALANCE_E)' || pv_nl;

    v_ccmap_selection :=
'  ccmap.PRODUCT_ID,' || pv_nl ||
'  ccmap.NATURAL_ACCOUNT_ID,' || pv_nl ||
'  ccmap.CHANNEL_ID,' || pv_nl ||
'  ccmap.LINE_ITEM_ID,' || pv_nl ||
'  ccmap.PROJECT_ID,' || pv_nl ||
'  ccmap.CUSTOMER_ID,' || pv_nl ||
'  ccmap.ENTITY_ID,' || pv_nl ||
'  ccmap.INTERCOMPANY_ID,' || pv_nl ||
'  ccmap.TASK_ID,' || pv_nl ||
'  ccmap.USER_DIM1_ID,' || pv_nl ||
'  ccmap.USER_DIM2_ID,' || pv_nl ||
'  ccmap.USER_DIM3_ID,' || pv_nl ||
'  ccmap.USER_DIM4_ID,' || pv_nl ||
'  ccmap.USER_DIM5_ID,' || pv_nl ||
'  ccmap.USER_DIM6_ID,' || pv_nl ||
'  ccmap.USER_DIM7_ID,' || pv_nl ||
'  ccmap.USER_DIM8_ID,' || pv_nl ||
'  ccmap.USER_DIM9_ID,' || pv_nl ||
'  ccmap.USER_DIM10_ID,' || pv_nl;

    v_ccmap_join :=
'AND   ccmap.global_vs_combo_id (+)= ' || FEM_GL_POST_PROCESS_PKG.pv_global_vs_combo_id || pv_nl ||
'AND   ccmap.COMPANY_COST_CENTER_ORG_ID (+)<> -1' || pv_nl ||
'AND   ccmap.NATURAL_ACCOUNT_ID (+)<> -1' || pv_nl ||
'AND   ccmap.LINE_ITEM_ID (+)<> -1' || pv_nl ||
'AND   ccmap.PRODUCT_ID (+)<> -1' || pv_nl ||
'AND   ccmap.CHANNEL_ID (+)<> -1' || pv_nl ||
'AND   ccmap.PROJECT_ID (+)<> -1' || pv_nl ||
'AND   ccmap.CUSTOMER_ID (+)<> -1' || pv_nl ||
'AND   ccmap.ENTITY_ID (+)<> -1' || pv_nl ||
'AND   ccmap.INTERCOMPANY_ID (+)<> -1' || pv_nl ||
'AND   ccmap.USER_DIM1_ID (+)<> -1' || pv_nl ||
'AND   ccmap.USER_DIM2_ID (+)<> -1' || pv_nl ||
'AND   ccmap.USER_DIM3_ID (+)<> -1' || pv_nl ||
'AND   ccmap.USER_DIM4_ID (+)<> -1' || pv_nl ||
'AND   ccmap.USER_DIM5_ID (+)<> -1' || pv_nl ||
'AND   ccmap.USER_DIM6_ID (+)<> -1' || pv_nl ||
'AND   ccmap.USER_DIM7_ID (+)<> -1' || pv_nl ||
'AND   ccmap.USER_DIM8_ID (+)<> -1' || pv_nl ||
'AND   ccmap.USER_DIM9_ID (+)<> -1' || pv_nl ||
'AND   ccmap.USER_DIM10_ID (+)<> -1' || pv_nl ||
'AND   ccmap.TASK_ID (+)<> -1' || pv_nl;


    v_ccy_join := '';
    IF FEM_GL_POST_PROCESS_PKG.pv_curr_option = 'ENTERED' THEN
      IF FEM_GL_POST_PROCESS_PKG.pv_xlated_bal_option = 'SPECIFIC' THEN
        v_ccy_join :=
'AND   (glb.translated_flag IS NULL OR' || pv_nl ||
'       glb.translated_flag = ''R'' OR' || pv_nl ||
'       (glb.translated_flag IN (''Y'', ''N'') AND' || pv_nl ||
'        EXISTS' || pv_nl ||
'        (SELECT 1' || pv_nl ||
'         FROM FEM_INTG_BAL_DEF_CURRS ccy' || pv_nl ||
'         WHERE ccy.bal_rule_obj_def_id = ' || FEM_GL_POST_PROCESS_PKG.pv_rule_obj_def_id || pv_nl ||
'         AND   ccy.xlated_currency_code = glb.currency_code)))' || pv_nl;
      ELSIF FEM_GL_POST_PROCESS_PKG.pv_xlated_bal_option = 'NONE' THEN
        v_ccy_join :=
'AND   (glb.translated_flag IS NULL OR' || pv_nl ||
'       glb.translated_flag = ''R'')' || pv_nl;
      END IF;
    ELSIF FEM_GL_POST_PROCESS_PKG.pv_curr_option = 'FUNCTIONAL' THEN
      IF FEM_GL_POST_PROCESS_PKG.pv_xlated_bal_option = 'SPECIFIC' THEN
        v_ccy_join :=
'AND   (glb.translated_flag IS NULL OR' || pv_nl ||
'       (glb.translated_flag IN (''Y'', ''N'') AND' || pv_nl ||
'        EXISTS' || pv_nl ||
'        (SELECT 1' || pv_nl ||
'         FROM FEM_INTG_BAL_DEF_CURRS ccy' || pv_nl ||
'         WHERE ccy.bal_rule_obj_def_id = ' || FEM_GL_POST_PROCESS_PKG.pv_rule_obj_def_id || pv_nl ||
'         AND   ccy.xlated_currency_code = glb.currency_code)))' || pv_nl;
      ELSIF FEM_GL_POST_PROCESS_PKG.pv_xlated_bal_option = 'ALL' THEN
        v_ccy_join :=
'AND   (glb.translated_flag IS NULL OR' || pv_nl ||
'       glb.translated_flag IN (''Y'', ''N''))' || pv_nl;
      ELSE -- No translated balances
        v_ccy_join :=
'AND   glb.translated_flag IS NULL' || pv_nl;
      END IF;
    ELSE -- Translated only
      IF FEM_GL_POST_PROCESS_PKG.pv_xlated_bal_option = 'SPECIFIC' THEN
        v_ccy_join :=
'AND   glb.translated_flag IN (''Y'', ''N'')' || pv_nl ||
'AND   EXISTS' || pv_nl ||
'      (SELECT 1' || pv_nl ||
'       FROM FEM_INTG_BAL_DEF_CURRS ccy' || pv_nl ||
'       WHERE ccy.bal_rule_obj_def_id = ' || FEM_GL_POST_PROCESS_PKG.pv_rule_obj_def_id || pv_nl ||
'       AND   ccy.xlated_currency_code = glb.currency_code)' || pv_nl;
      ELSE -- All translated balances
        v_ccy_join :=
'AND   glb.translated_flag IN (''Y'', ''N'')' || pv_nl;
      END IF;
    END IF;


    -- If we are doing any snapshots, do it here
    IF FEM_GL_POST_PROCESS_PKG.pv_from_gl_bal_flag = 'Y' THEN
      v_sql :=
v_insert ||
'SELECT' || pv_nl ||
'  glb.ROWID,' || pv_nl ||
'  null,' || pv_nl ||
'  ''R'',' || pv_nl ||
'  param.OUTPUT_DATASET_CODE,' || pv_nl ||
'  param.CAL_PERIOD_ID,' || pv_nl ||
'  ' || FEM_GL_POST_PROCESS_PKG.pv_ledger_id || ',' || pv_nl ||
'  ' || FEM_GL_POST_PROCESS_PKG.pv_gl_source_system_code || ',' || pv_nl ||
'  ccmap.COMPANY_COST_CENTER_ORG_ID,' || pv_nl ||
'  decode(glb.currency_code,' || pv_nl ||
'         ''STAT'', 10000,' || pv_nl ||
'          decode(xat_acct.dim_attribute_varchar_member,' || pv_nl ||
'                 ''REVENUE'', 455,' || pv_nl ||
'                 ''EXPENSE'', 457,' || pv_nl ||
'                 100)),' || pv_nl ||
v_ccmap_selection ||
'  glb.CURRENCY_CODE,' || pv_nl ||
'  decode(glb.translated_flag,' || pv_nl ||
'         ''Y'', ''TRANSLATED'',' || pv_nl ||
'         ''N'', ''TRANSLATED'',' || pv_nl ||
'         ''ENTERED''),' || pv_nl ||
'  decode(ccmap.code_combination_id, null, ''Y'', ''N''),' || pv_nl ||
'  glb.code_combination_id,' || pv_nl ||
-- 8781563
'  decode(glb.currency_code,' || pv_nl ||
'         ''STAT'', abs(xat_sign.number_assign_value),' || pv_nl ||
'  xat_sign.number_assign_value) *' || pv_nl ||
'  decode(xat_acct.dim_attribute_varchar_member,' || pv_nl ||
'         ''REVENUE'', nvl(glb.period_net_dr,0) -' || pv_nl ||
'                    nvl(glb.period_net_cr,0),' || pv_nl ||
'         ''EXPENSE'', nvl(glb.period_net_dr,0) -' || pv_nl ||
'                    nvl(glb.period_net_cr,0),' || pv_nl ||
'         nvl(glb.begin_balance_dr,0)+nvl(glb.period_net_dr,0) -' || pv_nl ||
'         nvl(glb.begin_balance_cr,0)-nvl(glb.period_net_cr,0)),' || pv_nl;

      IF p_maintain_qtd = 'Y' THEN
        v_sql := v_sql ||
-- 8781563
'  decode(glb.currency_code,' || pv_nl ||
'         ''STAT'', abs(xat_sign.number_assign_value),' || pv_nl ||
'  xat_sign.number_assign_value) *' || pv_nl ||
'  (nvl(glb.begin_balance_dr,0) + nvl(glb.period_net_dr,0) -' || pv_nl ||
'   nvl(glb.begin_balance_cr,0) - nvl(glb.period_net_cr,0)),' || pv_nl;
      ELSE
        v_sql := v_sql ||
'  null,' || pv_nl;
      END IF;

      v_sql := v_sql ||
-- 8781563
'  decode(glb.currency_code,' || pv_nl ||
'         ''STAT'', abs(xat_sign.number_assign_value),' || pv_nl ||
'  xat_sign.number_assign_value) *' || pv_nl ||
'  (nvl(glb.begin_balance_dr,0) + nvl(glb.period_net_dr,0) -' || pv_nl ||
'   nvl(glb.begin_balance_cr,0) - nvl(glb.period_net_cr,0)), ' || pv_nl ||
-- 8781563
'  decode(glb.currency_code,' || pv_nl ||
'         ''STAT'', abs(xat_sign.number_assign_value),' || pv_nl ||
'  xat_sign.number_assign_value) *' || pv_nl ||
'  decode' || pv_nl ||
'  (glb.translated_flag,' || pv_nl ||
'   ''Y'', null,' || pv_nl ||
'   ''N'', null,' || pv_nl ||
'   ''R'', decode' || pv_nl ||
'        (xat_acct.dim_attribute_varchar_member,' || pv_nl ||
'         ''REVENUE'', nvl(glb.period_net_dr_beq,0) -' || pv_nl ||
'                    nvl(glb.period_net_cr_beq,0),' || pv_nl ||
'         ''EXPENSE'', nvl(glb.period_net_dr_beq,0) -' || pv_nl ||
'                    nvl(glb.period_net_cr_beq,0),' || pv_nl ||
'         nvl(glb.begin_balance_dr_beq,0) +' || pv_nl ||
'         nvl(glb.period_net_dr_beq,0) -' || pv_nl ||
'         nvl(glb.begin_balance_cr_beq,0) -' || pv_nl ||
'         nvl(glb.period_net_cr_beq,0)),' || pv_nl ||
'   decode' || pv_nl ||
'   (xat_acct.dim_attribute_varchar_member,' || pv_nl ||
'    ''REVENUE'', nvl(glb.period_net_dr,0) -' || pv_nl ||
'               nvl(glb.period_net_cr,0),' || pv_nl ||
'    ''EXPENSE'', nvl(glb.period_net_dr,0) -' || pv_nl ||
'               nvl(glb.period_net_cr,0),' || pv_nl ||
'    nvl(glb.begin_balance_dr,0) + nvl(glb.period_net_dr,0) -' || pv_nl ||
'    nvl(glb.begin_balance_cr,0) - nvl(glb.period_net_cr,0))), ' || pv_nl;

      IF p_maintain_qtd = 'Y' THEN
        v_sql := v_sql ||
-- 8781563
'  decode(glb.currency_code,' || pv_nl ||
'         ''STAT'', abs(xat_sign.number_assign_value),' || pv_nl ||
'  xat_sign.number_assign_value) *' || pv_nl ||
'  decode(glb.translated_flag,' || pv_nl ||
'         ''Y'', null,' || pv_nl ||
'         ''N'', null,' || pv_nl ||
'         ''R'', nvl(glb.begin_balance_dr_beq,0) +' || pv_nl ||
'              nvl(glb.period_net_dr_beq,0) -' || pv_nl ||
'              nvl(glb.begin_balance_cr_beq,0) -' || pv_nl ||
'              nvl(glb.period_net_cr_beq,0),' || pv_nl ||
'         nvl(glb.begin_balance_dr,0)+nvl(glb.period_net_dr,0) -' || pv_nl ||
'         nvl(glb.begin_balance_cr,0)-nvl(glb.period_net_cr,0)),' || pv_nl;
      ELSE
        v_sql := v_sql ||
'  null,' || pv_nl;
      END IF;

      v_sql := v_sql ||
-- 8781563
'  decode(glb.currency_code,' || pv_nl ||
'         ''STAT'', abs(xat_sign.number_assign_value),' || pv_nl ||
'  xat_sign.number_assign_value) *' || pv_nl ||
'  decode(glb.translated_flag,' || pv_nl ||
'         ''Y'', null,' || pv_nl ||
'         ''N'', null,' || pv_nl ||
'         ''R'', nvl(glb.begin_balance_dr_beq,0) +' || pv_nl ||
'              nvl(glb.period_net_dr_beq,0) -' || pv_nl ||
'              nvl(glb.begin_balance_cr_beq,0) -' || pv_nl ||
'              nvl(glb.period_net_cr_beq,0),' || pv_nl ||
'         nvl(glb.begin_balance_dr,0)+nvl(glb.period_net_dr,0) -' || pv_nl ||
'         nvl(glb.begin_balance_cr,0)-nvl(glb.period_net_cr,0)),' || pv_nl ||
'  nvl(glb.period_net_dr,0),' || pv_nl ||
'  nvl(glb.period_net_cr,0),' || pv_nl ||
'  nvl(glb.begin_balance_dr,0) + nvl(glb.period_net_dr,0),' || pv_nl ||
'  nvl(glb.begin_balance_cr,0) + nvl(glb.period_net_cr,0)' || pv_nl ||
'FROM' || pv_nl ||
'  FEM_INTG_EXEC_PARAMS_GT param,' || pv_nl ||
'  GL_BALANCES glb,' || pv_nl;

      IF FEM_GL_POST_PROCESS_PKG.pv_bsv_option = 'SPECIFIC' THEN
        v_sql := v_sql ||
'  FEM_INTG_BAL_DEF_BSVS bsv,' || pv_nl;
      END IF;

      v_sql := v_sql ||
'  GL_CODE_COMBINATIONS cc,' || pv_nl ||
'  FEM_INTG_OGL_CCID_MAP ccmap,' || pv_nl ||
'  FEM_EXT_ACCT_TYPES_ATTR xat_acct,' || pv_nl ||
'  FEM_EXT_ACCT_TYPES_ATTR xat_sign' || pv_nl ||
'WHERE param.error_code IS NULL' || pv_nl;

      IF FEM_GL_POST_PROCESS_PKG.pv_ds_balance_type_cd <> 'BUDGET' THEN
        v_sql := v_sql ||
'AND   param.load_method_code = ''S''' || pv_nl;
      END IF;

      v_sql := v_sql ||
'AND   param.request_id IS NOT NULL' || pv_nl ||
'AND   glb.ledger_id = ' || FEM_GL_POST_PROCESS_PKG.pv_ledger_id || pv_nl ||
'AND   glb.period_name = param.period_name' || pv_nl;

      IF FEM_GL_POST_PROCESS_PKG.pv_ds_balance_type_cd = 'ACTUAL' THEN
        v_sql := v_sql ||
'AND   glb.actual_flag = ''A''' || pv_nl;
      ELSIF FEM_GL_POST_PROCESS_PKG.pv_ds_balance_type_cd = 'BUDGET' THEN
        v_sql := v_sql ||
'AND   glb.actual_flag = ''B''' || pv_nl ||
'AND   glb.budget_version_id = param.budget_id' || pv_nl;
      ELSE -- encumbrances
        v_sql := v_sql ||
'AND   glb.actual_flag = ''E''' || pv_nl ||
'AND   glb.encumbrance_type_id = param.encumbrance_type_id' || pv_nl;
      END IF;

      IF FEM_GL_POST_PROCESS_PKG.pv_bsv_option = 'SPECIFIC' THEN
        v_sql := v_sql ||
'AND   bsv.bal_rule_obj_def_id = ' || FEM_GL_POST_PROCESS_PKG.pv_rule_obj_def_id || pv_nl ||
'AND   bsv.balance_seg_value = cc.' || FEM_GL_POST_PROCESS_PKG.pv_bsv_app_col_name || pv_nl;
      END IF;


      v_sql := v_sql ||
'AND   cc.code_combination_id = glb.code_combination_id' || pv_nl ||
'AND   cc.template_id IS NULL' || pv_nl ||
'AND   ccmap.code_combination_id (+)= cc.code_combination_id' || pv_nl ||
v_ccmap_join ||
'AND   xat_acct.attribute_id (+)= ' || v_xat_basic_type_attr_id || pv_nl ||
'AND   xat_acct.version_id (+)= ' || v_xat_basic_type_v_id || pv_nl ||
'AND   xat_acct.ext_account_type_code (+)= ccmap.extended_account_type' || pv_nl ||
'AND   xat_sign.attribute_id (+)= ' || v_xat_sign_attr_id || pv_nl ||
'AND   xat_sign.version_id (+)= ' || v_xat_sign_v_id || pv_nl ||
'AND   xat_sign.ext_account_type_code (+)= ccmap.extended_account_type' || pv_nl;

      -- If there is a range, only pick up delta loads for bsv's in the range
      IF p_bsv_range_low IS NOT NULL AND p_bsv_range_high IS NOT NULL THEN
        v_sql := v_sql ||
'AND   (NOT EXISTS' || pv_nl ||
'       (SELECT 1' || pv_nl ||
'        FROM fem_balances fb_curr' || pv_nl ||
'        WHERE fb_curr.ledger_id = ' || FEM_GL_POST_PROCESS_PKG.pv_ledger_id || pv_nl ||
'        AND fb_curr.dataset_code = param.output_dataset_code' || pv_nl ||
'        AND fb_curr.cal_period_id = param.cal_period_id)' || pv_nl ||
'       OR cc.' || FEM_GL_POST_PROCESS_PKG.pv_bsv_app_col_name || ' BETWEEN ' || p_bsv_range_low || ' AND ' || p_bsv_range_high || ')' || pv_nl;
      END IF;

      -- Add the joins for the currency information here
      v_sql := v_sql || v_ccy_join;


      -- Print the snapshot upload statement
      FOR iterator IN 1..trunc((length(v_sql)+1499)/1500) LOOP
        FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_statement,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_204',
         p_token1   => 'VAR_NAME',
         p_value1   => 'v_sql: ' || iterator,
         p_token2   => 'VAR_VAL',
         p_value2   => substr(v_sql, iterator*1500-1499, 1500));
      END LOOP;

      EXECUTE IMMEDIATE v_sql;

      v_intermediate_rows_inserted := SQL%ROWCOUNT;

      -- Print the number of rows inserted
      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_statement,
        p_module   => v_module,
        p_msg_text => 'Inserted ' || TO_CHAR(v_intermediate_rows_inserted) ||
                      ' rows into FEM_BAL_POST_INTERIM_GT');

      x_num_rows_inserted := v_intermediate_rows_inserted;
    END IF;



    -- If we are doing any incremental loads, do them here
    IF FEM_GL_POST_PROCESS_PKG.pv_from_gl_delta_flag = 'Y' THEN

    --start bug fix 5585720
    v_flex_query_stmt := get_flex_values_query;

    v_sql :=
'INSERT INTO FEM_INTG_DELTA_LOADS dl' || pv_nl ||
'( LEDGER_ID' || pv_nl ||
'   ,DATASET_CODE' || pv_nl ||
'   ,CAL_PERIOD_ID' || pv_nl ||
'   ,DELTA_RUN_ID' || pv_nl ||
'   ,LOADED_FLAG' || pv_nl ||
'   ,CREATION_DATE' || pv_nl ||
'   ,CREATED_BY' || pv_nl ||
'   ,LAST_UPDATE_DATE' || pv_nl ||
'   ,LAST_UPDATED_BY' || pv_nl ||
'   ,LAST_UPDATE_LOGIN' || pv_nl ||
'   ,BALANCE_SEG_VALUE)' || pv_nl ||
' SELECT '|| pv_nl ||
        FEM_GL_POST_PROCESS_PKG.pv_ledger_id || pv_nl ||
'       ,param_in.output_dataset_code' || pv_nl ||
'       ,param_in.cal_period_id' || pv_nl ||
'       ,-1' || pv_nl ||
'       ,''Y''' || pv_nl ||
'       ,sysdate' || pv_nl ||
'       ,'|| FEM_GL_POST_PROCESS_PKG.pv_user_id|| pv_nl ||
'       ,sysdate' || pv_nl ||
'       ,'|| FEM_GL_POST_PROCESS_PKG.pv_user_id || pv_nl ||
'       ,'||FEM_GL_POST_PROCESS_PKG.pv_login_id || pv_nl ||
'       ,flex.flex_value' || pv_nl ||
'FROM   FEM_INTG_EXEC_PARAMS_GT param_in,' || pv_nl ||
'        (    '||v_flex_query_stmt||' ) flex' || pv_nl ||
'WHERE  param_in.error_code IS NULL' || pv_nl ||
'AND    param_in.request_id IS NOT NULL' || pv_nl ||
'AND    param_in.load_method_code = ''I''' || pv_nl ||
'AND    NOT EXISTS ( SELECT 1' || pv_nl ||
'                    FROM FEM_INTG_DELTA_LOADS' || pv_nl ||
'                    WHERE LEDGER_ID= '||FEM_GL_POST_PROCESS_PKG.pv_ledger_id || pv_nl ||
'                    AND DATASET_CODE = param_in.output_dataset_code' || pv_nl ||
'                    AND CAL_PERIOD_ID = param_in.cal_period_id' || pv_nl ||
'                    AND BALANCE_SEG_VALUE = flex.flex_value)';

      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_statement,
        p_module   => v_module,
        p_msg_text => v_sql );

      EXECUTE IMMEDIATE v_sql;

      --end bug fix 5585720

      -- In this case, v_sql will not hold the entire sql statement, since
      -- two very similar statements must be executed. Instead, v_sql will
      -- hold the common parts of the two statements, and the rest will be
      -- appended when the statements are executed.
      v_sql :=
v_insert ||
'SELECT' || pv_nl ||
'  glb.ROWID,' || pv_nl ||
'  glb.delta_run_id,' || pv_nl ||
'  ''A'',' || pv_nl ||
'  param.OUTPUT_DATASET_CODE,' || pv_nl ||
'  param.CAL_PERIOD_ID,' || pv_nl ||
'  ' || FEM_GL_POST_PROCESS_PKG.pv_ledger_id || ',' || pv_nl ||
'  ' || FEM_GL_POST_PROCESS_PKG.pv_gl_source_system_code || ',' || pv_nl ||
'  ccmap.COMPANY_COST_CENTER_ORG_ID,' || pv_nl ||
'  decode(glb.currency_code,' || pv_nl ||
'         ''STAT'', 10000,' || pv_nl ||
'          decode(xat_acct.dim_attribute_varchar_member,' || pv_nl ||
'                 ''REVENUE'', 455,' || pv_nl ||
'                 ''EXPENSE'', 457,' || pv_nl ||
'                 100)),' || pv_nl ||
v_ccmap_selection ||
'  glb.CURRENCY_CODE,' || pv_nl ||
'  decode(glb.translated_flag,' || pv_nl ||
'         ''Y'', ''TRANSLATED'',' || pv_nl ||
'         ''N'', ''TRANSLATED'',' || pv_nl ||
'         ''ENTERED''),' || pv_nl ||
'  decode(ccmap.code_combination_id, null, ''Y'', ''N''), ' || pv_nl ||
'  glb.code_combination_id,' || pv_nl ||
-- 8781563
'  decode(glb.currency_code,' || pv_nl ||
'         ''STAT'', abs(xat_sign.number_assign_value),' || pv_nl ||
'  xat_sign.number_assign_value) *' || pv_nl ||
'  decode(xat_acct.dim_attribute_varchar_member,' || pv_nl ||
'         ''REVENUE'',nvl(glb.period_net_dr,0)-nvl(glb.period_net_cr,0),' || pv_nl ||
'         ''EXPENSE'',nvl(glb.period_net_dr,0)-nvl(glb.period_net_cr,0),' || pv_nl ||
'         nvl(glb.begin_balance_dr,0)+nvl(glb.period_net_dr,0)-' || pv_nl ||
'         nvl(glb.begin_balance_cr,0)-nvl(glb.period_net_cr,0)), ' || pv_nl;

      IF p_maintain_qtd = 'Y' THEN
        v_sql := v_sql ||
-- 8781563
'  decode(glb.currency_code,' || pv_nl ||
'         ''STAT'', abs(xat_sign.number_assign_value),' || pv_nl ||
'  xat_sign.number_assign_value) *' || pv_nl ||
'  (nvl(glb.begin_balance_dr,0) + nvl(glb.period_net_dr,0) -' || pv_nl ||
'   nvl(glb.begin_balance_cr,0) - nvl(glb.period_net_cr,0)),' || pv_nl;
      ELSE
        v_sql := v_sql ||
'  null,' || pv_nl;
      END IF;

      v_sql := v_sql ||
-- 8781563
'  decode(glb.currency_code,' || pv_nl ||
'         ''STAT'', abs(xat_sign.number_assign_value),' || pv_nl ||
'  xat_sign.number_assign_value) *' || pv_nl ||
'  (nvl(glb.begin_balance_dr,0) + nvl(glb.period_net_dr,0) -' || pv_nl ||
'   nvl(glb.begin_balance_cr,0) - nvl(glb.period_net_cr,0)),' || pv_nl ||
-- 8781563
'  decode(glb.currency_code,' || pv_nl ||
'         ''STAT'', abs(xat_sign.number_assign_value),' || pv_nl ||
'  xat_sign.number_assign_value) *' || pv_nl ||
'  decode' || pv_nl ||
'  (glb.translated_flag,' || pv_nl ||
'   ''Y'', null,' || pv_nl ||
'   ''N'', null,' || pv_nl ||
'   ''R'', decode' || pv_nl ||
'        (xat_acct.dim_attribute_varchar_member,' || pv_nl ||
'         ''REVENUE'', nvl(glb.period_net_dr_beq,0) -' || pv_nl ||
'              nvl(glb.period_net_cr_beq,0),' || pv_nl ||
'         ''EXPENSE'', nvl(glb.period_net_dr_beq,0) -' || pv_nl ||
'              nvl(glb.period_net_cr_beq,0),' || pv_nl ||
'         nvl(glb.begin_balance_dr_beq,0) +' || pv_nl ||
'         nvl(glb.period_net_dr_beq,0) -' || pv_nl ||
'         nvl(glb.begin_balance_cr_beq,0) -' || pv_nl ||
'         nvl(glb.period_net_cr_beq,0)),' || pv_nl ||
'   decode' || pv_nl ||
'   (xat_acct.dim_attribute_varchar_member,' || pv_nl ||
'    ''REVENUE'', nvl(glb.period_net_dr,0) - nvl(glb.period_net_cr,0),' || pv_nl ||
'    ''EXPENSE'', nvl(glb.period_net_dr,0) - nvl(glb.period_net_cr,0),' || pv_nl ||
'    nvl(glb.begin_balance_dr,0) + nvl(glb.period_net_dr,0) -' || pv_nl ||
'    nvl(glb.begin_balance_cr,0) - nvl(glb.period_net_cr,0))), ' || pv_nl;

      IF p_maintain_qtd = 'Y' THEN
        v_sql := v_sql ||
-- 8781563
'  decode(glb.currency_code,' || pv_nl ||
'         ''STAT'', abs(xat_sign.number_assign_value),' || pv_nl ||
'  xat_sign.number_assign_value) *' || pv_nl ||
'  decode(glb.translated_flag,' || pv_nl ||
'         ''Y'', null,' || pv_nl ||
'         ''N'', null,' || pv_nl ||
'         ''R'', nvl(glb.begin_balance_dr_beq,0) +' || pv_nl ||
'              nvl(glb.period_net_dr_beq,0) -' || pv_nl ||
'              nvl(glb.begin_balance_cr_beq,0) -' || pv_nl ||
'              nvl(glb.period_net_cr_beq,0),' || pv_nl ||
'         nvl(glb.begin_balance_dr,0)+nvl(glb.period_net_dr,0) -' || pv_nl ||
'         nvl(glb.begin_balance_cr,0)-nvl(glb.period_net_cr,0)),' || pv_nl;
      ELSE
        v_sql := v_sql ||
'  null,' || pv_nl;
      END IF;

      v_sql := v_sql ||
-- 8781563
'  decode(glb.currency_code,' || pv_nl ||
'         ''STAT'', abs(xat_sign.number_assign_value),' || pv_nl ||
'  xat_sign.number_assign_value) *' || pv_nl ||
'  decode(glb.translated_flag,' || pv_nl ||
'         ''Y'', null,' || pv_nl ||
'         ''N'', null,' || pv_nl ||
'         ''R'', nvl(glb.begin_balance_dr_beq,0) +' || pv_nl ||
'              nvl(glb.period_net_dr_beq,0) -' || pv_nl ||
'              nvl(glb.begin_balance_cr_beq,0) -' || pv_nl ||
'              nvl(glb.period_net_cr_beq,0),' || pv_nl ||
'         nvl(glb.begin_balance_dr,0)+nvl(glb.period_net_dr,0) -' || pv_nl ||
'         nvl(glb.begin_balance_cr,0)-nvl(glb.period_net_cr,0)),' || pv_nl ||
'  nvl(glb.period_net_dr,0),' || pv_nl ||
'  nvl(glb.period_net_cr,0),' || pv_nl ||
'  nvl(glb.begin_balance_dr,0) + nvl(glb.period_net_dr,0),' || pv_nl ||
'  nvl(glb.begin_balance_cr,0) + nvl(glb.period_net_cr,0)' || pv_nl ||
'FROM' || pv_nl ||
'  FEM_INTG_EXEC_PARAMS_GT param,' || pv_nl ||
'  GL_BALANCES_DELTA glb,' || pv_nl ||
'  FEM_INTG_DELTA_LOADS dl,' || pv_nl;

      IF FEM_GL_POST_PROCESS_PKG.pv_bsv_option = 'SPECIFIC' THEN
        v_sql := v_sql ||
'  FEM_INTG_BAL_DEF_BSVS bsv,' || pv_nl;
      END IF;

      v_sql := v_sql ||
'  GL_CODE_COMBINATIONS cc,' || pv_nl ||
'  FEM_INTG_OGL_CCID_MAP ccmap,' || pv_nl ||
'  FEM_EXT_ACCT_TYPES_ATTR xat_acct,' || pv_nl ||
'  FEM_EXT_ACCT_TYPES_ATTR xat_sign' || pv_nl ||
'WHERE param.load_method_code = ''I''' || pv_nl ||
'AND   param.error_code IS NULL' || pv_nl ||
'AND   param.request_id IS NOT NULL' || pv_nl ||
'AND   dl.ledger_id = ' || FEM_GL_POST_PROCESS_PKG.pv_ledger_id || pv_nl ||
'AND   dl.dataset_code = param.output_dataset_code' || pv_nl ||
'AND   dl.cal_period_id = param.cal_period_id' || pv_nl ||
'AND   glb.ledger_id = ' || FEM_GL_POST_PROCESS_PKG.pv_ledger_id || pv_nl ||
'AND   glb.period_name = param.period_name' || pv_nl;

      IF FEM_GL_POST_PROCESS_PKG.pv_ds_balance_type_cd = 'ACTUAL' THEN
        v_sql := v_sql ||
'AND   glb.actual_flag = ''A''' || pv_nl;
      ELSIF FEM_GL_POST_PROCESS_PKG.pv_ds_balance_type_cd = 'BUDGET' THEN
        v_sql := v_sql ||
'AND   glb.actual_flag = ''B''' || pv_nl ||
'AND   glb.budget_version_id = param.budget_id' || pv_nl;
      ELSE -- encumbrances
        v_sql := v_sql ||
'AND   glb.actual_flag = ''E''' || pv_nl ||
'AND   glb.encumbrance_type_id = param.encumbrance_type_id' || pv_nl;
      END IF;

      IF FEM_GL_POST_PROCESS_PKG.pv_bsv_option = 'SPECIFIC' THEN
        v_sql := v_sql ||
'AND   bsv.bal_rule_obj_def_id = ' || FEM_GL_POST_PROCESS_PKG.pv_rule_obj_def_id || pv_nl ||
'AND   bsv.balance_seg_value = cc.' || FEM_GL_POST_PROCESS_PKG.pv_bsv_app_col_name || pv_nl;
      END IF;

      -- If there is a range specified, only pull data in that range
      v_sql := v_sql ||
'AND   cc.' || FEM_GL_POST_PROCESS_PKG.pv_bsv_app_col_name || ' = dl.balance_seg_value' || pv_nl;

      v_sql := v_sql ||
'AND   cc.code_combination_id = glb.code_combination_id' || pv_nl ||
'AND   cc.template_id IS NULL' || pv_nl ||
'AND   ccmap.code_combination_id (+)= cc.code_combination_id' || pv_nl ||
v_ccmap_join ||
'AND   xat_acct.attribute_id (+)= ' || v_xat_basic_type_attr_id || pv_nl ||
'AND   xat_acct.version_id (+)= ' || v_xat_basic_type_v_id || pv_nl ||
'AND   xat_acct.ext_account_type_code (+)= ccmap.extended_account_type' || pv_nl ||
'AND   xat_sign.attribute_id (+)= ' || v_xat_sign_attr_id || pv_nl ||
'AND   xat_sign.version_id (+)= ' || v_xat_sign_v_id || pv_nl ||
'AND   xat_sign.ext_account_type_code (+)= ccmap.extended_account_type' || pv_nl;

      -- If there is a range, only pick up delta loads for bsv's in the range
      IF p_bsv_range_low IS NOT NULL AND p_bsv_range_high IS NOT NULL THEN
        v_sql := v_sql ||
'AND   dl.balance_seg_value BETWEEN ' || p_bsv_range_low || ' AND ' ||
p_bsv_range_high || pv_nl;
      END IF;

      -- Add the joins for the currency information here
      v_sql := v_sql || v_ccy_join;

      v_sql_incr := v_sql ||
'AND   dl.loaded_flag = ''N''' || pv_nl ||
'AND   glb.delta_run_id = dl.delta_run_id';


      -- Print the incremental upload statement
      FOR iterator IN 1..trunc((length(v_sql_incr)+1499)/1500) LOOP
        FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_statement,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_204',
         p_token1   => 'VAR_NAME',
         p_value1   => 'v_sql_incr: ' || iterator,
         p_token2   => 'VAR_VAL',
         p_value2   => substr(v_sql_incr, iterator*1500-1499, 1500));
      END LOOP;

      EXECUTE IMMEDIATE v_sql_incr;

      v_intermediate_rows_inserted := SQL%ROWCOUNT;

      -- Print the number of rows inserted
      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_statement,
        p_module   => v_module,
        p_msg_text => 'Inserted ' || TO_CHAR(v_intermediate_rows_inserted) ||
                      ' rows into FEM_BAL_POST_INTERIM_GT');

      x_num_rows_inserted := x_num_rows_inserted + v_intermediate_rows_inserted;


      v_sql_incr := v_sql ||
'AND   dl.loaded_flag = ''Y''' || pv_nl ||
'AND   glb.delta_run_id BETWEEN dl.delta_run_id + 1 AND ' || FEM_GL_POST_PROCESS_PKG.pv_max_delta_run_id;

      -- Print the incremental upload statement
      FOR iterator IN 1..trunc((length(v_sql_incr)+1499)/1500) LOOP
        FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_statement,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_204',
         p_token1   => 'VAR_NAME',
         p_value1   => 'v_sql_incr: ' || iterator,
         p_token2   => 'VAR_VAL',
         p_value2   => substr(v_sql_incr, iterator*1500-1499, 1500));
      END LOOP;

      EXECUTE IMMEDIATE v_sql_incr;

      v_intermediate_rows_inserted := SQL%ROWCOUNT;

      -- Print the number of rows inserted
      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_statement,
        p_module   => v_module,
        p_msg_text => 'Inserted ' || TO_CHAR(v_intermediate_rows_inserted) ||
                      ' rows into FEM_BAL_POST_INTERIM_GT');

      x_num_rows_inserted := x_num_rows_inserted + v_intermediate_rows_inserted;
    END IF;

    OPEN unmapped_exists_c;
    FETCH unmapped_exists_c INTO dummy;
    IF unmapped_exists_c%FOUND THEN
      x_completion_code := 1;
    END IF;
    CLOSE unmapped_exists_c;

    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => v_module,
       p_msg_text => 'END');

  EXCEPTION
    WHEN OTHERS THEN
      x_completion_code := 2;

      FEM_ENGINES_PKG.User_Message
        (p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_215',
         p_token1   => 'ERR_MSG',
         p_value1   => SQLERRM);

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_unexpected,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_215',
         p_token1   => 'ERR_MSG',
         p_value1   => SQLERRM);

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_procedure,
         p_module   => v_module,
         p_msg_text => 'END');
  END Load_Std_Balances;




  PROCEDURE Load_Avg_Balances(	x_completion_code	OUT NOCOPY NUMBER,
				x_num_rows_inserted	OUT NOCOPY NUMBER,
				p_effective_date	DATE,
				p_bsv_range_low		VARCHAR2,
				p_bsv_range_high	VARCHAR2) IS

    -- Since the statements are only going to vary by a few parts of the
    -- string, it makes more sense to create a template, and then replace the
    -- necessary parts of the statement with the information for each period
    v_sql_template	VARCHAR2(32767);
    v_sql		VARCHAR2(32767);

    v_intermediate_rows_inserted	NUMBER;

    -- This is used to loop through all periods for which average balances
    -- should be uploaded
    CURSOR	load_periods_c IS
    SELECT DISTINCT
	param.period_name,
	ps.end_date period_end_date,
	ps.start_date period_start_date,
	ps.quarter_start_date,
	ps.year_start_date
    FROM FEM_INTG_EXEC_PARAMS_GT param,
         GL_PERIOD_STATUSES ps
    WHERE param.error_code IS NULL
    AND   param.request_id IS NOT NULL
    AND   ps.application_id = 101
    AND   ps.ledger_id = FEM_GL_POST_PROCESS_PKG.pv_ledger_id
    AND   ps.period_name = param.period_name;

    v_end_date	DATE; -- Date to be used in calculating average balances

    v_xat_basic_type_attr_id	NUMBER;
    v_xat_basic_type_v_id	NUMBER;
    v_xat_sign_attr_id		NUMBER;
    v_xat_sign_v_id		NUMBER;

    v_error_code		NUMBER;

    v_module	VARCHAR2(100);
  BEGIN
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => v_module,
       p_msg_text => 'BEGIN');

    pv_nl := '
';
    v_module := 'fem.plsql.fem_intg_bal_eng_load.load_avg_balances';

    x_completion_code := 0;
    x_num_rows_inserted := 0;

    FEM_DIMENSION_UTIL_PKG.get_dim_attr_id_ver_id(
      p_dim_id		=> FEM_GL_POST_PROCESS_PKG.pv_ext_acct_type_dim_id,
      p_attr_label	=> 'BASIC_ACCOUNT_TYPE_CODE',
      x_attr_id		=> v_xat_basic_type_attr_id,
      x_ver_id		=> v_xat_basic_type_v_id,
      x_err_code	=> v_error_code);

    FEM_DIMENSION_UTIL_PKG.get_dim_attr_id_ver_id(
      p_dim_id		=> FEM_GL_POST_PROCESS_PKG.pv_ext_acct_type_dim_id,
      p_attr_label	=> 'SIGN',
      x_attr_id		=> v_xat_sign_attr_id,
      x_ver_id		=> v_xat_sign_v_id,
      x_err_code	=> v_error_code);

    -- Print the As-of-date
    FEM_ENGINES_PKG.Tech_Message(
	p_severity => pc_log_level_statement,
	p_module   => v_module,
	p_app_name => 'FEM',
	p_msg_name => 'FEM_GL_POST_204',
	p_token1   => 'VAR_NAME',
	p_value1   => 'p_effective_date',
	p_token2   => 'VAR_VAL',
	p_value2   => p_effective_date);


    -- We will now create the load statement template. The portions inside the
    -- '<<<' and '>>>' will be replaced by actual numbers when we actually run
    -- the statement itself.
    v_sql_template :=
'INSERT INTO FEM_BAL_POST_INTERIM_GT(INTERFACE_ROWID, BAL_POST_TYPE_CODE, ' ||
'DATASET_CODE, CAL_PERIOD_ID,  LEDGER_ID, SOURCE_SYSTEM_CODE, ' ||
'COMPANY_COST_CENTER_ORG_ID, FINANCIAL_ELEM_ID, PRODUCT_ID, ' ||
'NATURAL_ACCOUNT_ID, CHANNEL_ID, LINE_ITEM_ID, PROJECT_ID, CUSTOMER_ID, ' ||
'ENTITY_ID, INTERCOMPANY_ID, TASK_ID, USER_DIM1_ID, USER_DIM2_ID, ' ||
'USER_DIM3_ID, USER_DIM4_ID, USER_DIM5_ID, USER_DIM6_ID, USER_DIM7_ID, ' ||
'USER_DIM8_ID, USER_DIM9_ID, USER_DIM10_ID, CURRENCY_CODE, ' ||
'CURRENCY_TYPE_CODE, POSTING_ERROR_FLAG, CODE_COMBINATION_ID, ' ||
'XTD_BALANCE_E, QTD_BALANCE_E, YTD_BALANCE_E, XTD_BALANCE_F, ' ||
'QTD_BALANCE_F, YTD_BALANCE_F, PTD_DEBIT_BALANCE_E, PTD_CREDIT_BALANCE_E, ' ||
'YTD_DEBIT_BALANCE_E, YTD_CREDIT_BALANCE_E)' || pv_nl ||
'SELECT' || pv_nl ||
'  glb.ROWID,' || pv_nl ||
'  ''R'',' || pv_nl ||
'  param.OUTPUT_DATASET_CODE,' || pv_nl ||
'  param.CAL_PERIOD_ID,' || pv_nl ||
'  ' || FEM_GL_POST_PROCESS_PKG.pv_ledger_id || ',' || pv_nl ||
'  ' || FEM_GL_POST_PROCESS_PKG.pv_gl_source_system_code || ',' || pv_nl ||
'  ccmap.COMPANY_COST_CENTER_ORG_ID,' || pv_nl ||
'  140,' || pv_nl ||
'  ccmap.PRODUCT_ID,' || pv_nl ||
'  ccmap.NATURAL_ACCOUNT_ID,' || pv_nl ||
'  ccmap.CHANNEL_ID,' || pv_nl ||
'  ccmap.LINE_ITEM_ID,' || pv_nl ||
'  ccmap.PROJECT_ID,' || pv_nl ||
'  ccmap.CUSTOMER_ID,' || pv_nl ||
'  ccmap.ENTITY_ID,' || pv_nl ||
'  ccmap.INTERCOMPANY_ID,' || pv_nl ||
'  ccmap.TASK_ID,' || pv_nl ||
'  ccmap.USER_DIM1_ID,' || pv_nl ||
'  ccmap.USER_DIM2_ID,' || pv_nl ||
'  ccmap.USER_DIM3_ID,' || pv_nl ||
'  ccmap.USER_DIM4_ID,' || pv_nl ||
'  ccmap.USER_DIM5_ID,' || pv_nl ||
'  ccmap.USER_DIM6_ID,' || pv_nl ||
'  ccmap.USER_DIM7_ID,' || pv_nl ||
'  ccmap.USER_DIM8_ID,' || pv_nl ||
'  ccmap.USER_DIM9_ID,' || pv_nl ||
'  ccmap.USER_DIM10_ID,' || pv_nl ||
'  glb.CURRENCY_CODE,' || pv_nl ||
'  decode(glb.currency_type,' || pv_nl ||
'         ''T'', ''TRANSLATED'',' || pv_nl ||
'         ''O'', ''TRANSLATED'',' || pv_nl ||
-- BugFix 6795389: Added the functional total currency_type for the total in the functional currency ('U' rows)
'         ''U'', ''FUNCTIONALTOTAL'',' || pv_nl ||
'         ''ENTERED''),' || pv_nl ||
'  decode(ccmap.code_combination_id, null, ''Y'', ''N''),' || pv_nl ||
'  glb.code_combination_id,' || pv_nl ||
'  round(xat_sign.number_assign_value *' || pv_nl ||
'        nvl(glb.period_aggregate<<<period_days>>>,0) / <<<period_days>>> / ccy_mau.mau) * ccy_mau.mau,' || pv_nl ||
'  round(xat_sign.number_assign_value *' || pv_nl ||
'        decode(glb.currency_type,' || pv_nl ||
'               ''T'', nvl(glb.quarter_aggregate<<<period_days>>>,0),' || pv_nl ||
'               ''O'', nvl(glb.quarter_aggregate<<<period_days>>>,0),' || pv_nl ||
'               nvl(glb.opening_quarter_aggregate,0) +' || pv_nl ||
'               nvl(glb.period_aggregate<<<period_days>>>,0)) /' || pv_nl ||
'        <<<quarter_days>>> / ccy_mau.mau) * ccy_mau.mau,' || pv_nl ||
'  round(xat_sign.number_assign_value *' || pv_nl ||
'        decode(glb.currency_type,' || pv_nl ||
'               ''T'', nvl(glb.year_aggregate<<<period_days>>>,0),' || pv_nl ||
'               ''O'', nvl(glb.year_aggregate<<<period_days>>>,0),' || pv_nl ||
'               nvl(glb.opening_year_aggregate,0) +' || pv_nl ||
'               nvl(glb.period_aggregate<<<period_days>>>,0)) /' || pv_nl ||
'        <<<year_days>>> / ccy_mau.mau) * ccy_mau.mau,' || pv_nl ||
'  round(xat_sign.number_assign_value *' || pv_nl ||
'        decode(glb.currency_type,' || pv_nl ||
'               ''T'', null,' || pv_nl ||
'               ''O'', null,' || pv_nl;

/* BugFix 6795389: Changed the nvl(glbc.period_aggregate<<<period_days>>>,0) to nvl(glbc.period_aggregate<<<period_days>>>,glb.period_aggregate<<<period_days>>>)
 to include the entered balances in the functional currency for all the f columns */
    IF FEM_GL_POST_PROCESS_PKG.pv_curr_option = 'ENTERED' THEN
      v_sql_template := v_sql_template ||
'               ''E'', nvl(glbc.period_aggregate<<<period_days>>>,glb.period_aggregate<<<period_days>>>),' || pv_nl;
    END IF;

    v_sql_template := v_sql_template ||
'               nvl(glb.period_aggregate<<<period_days>>>,0)) /' || pv_nl ||
'        <<<period_days>>> / nvl(ccy_mau_c.mau, ccy_mau.mau)) * nvl(ccy_mau_c.mau, ccy_mau.mau),' || pv_nl ||
'  round(xat_sign.number_assign_value *' || pv_nl ||
'        decode(glb.currency_type,' || pv_nl ||
'               ''T'', null,' || pv_nl ||
'               ''O'', null,' || pv_nl;

    IF FEM_GL_POST_PROCESS_PKG.pv_curr_option = 'ENTERED' THEN
      v_sql_template := v_sql_template ||
'               ''E'', nvl(glbc.opening_quarter_aggregate,0) +' || pv_nl ||
'                    nvl(glbc.period_aggregate<<<period_days>>>,glb.period_aggregate<<<period_days>>>),' || pv_nl;
    END IF;

    v_sql_template := v_sql_template ||
'               nvl(glb.opening_quarter_aggregate,0) +' || pv_nl ||
'               nvl(glb.period_aggregate<<<period_days>>>,0)) /' || pv_nl ||
'        <<<quarter_days>>> / nvl(ccy_mau_c.mau, ccy_mau.mau)) * nvl(ccy_mau_c.mau, ccy_mau.mau),' || pv_nl ||
'  round(xat_sign.number_assign_value *' || pv_nl ||
'  decode(glb.currency_type,' || pv_nl ||
'               ''T'', null,' || pv_nl ||
'               ''O'', null,' || pv_nl;

    IF FEM_GL_POST_PROCESS_PKG.pv_curr_option = 'ENTERED' THEN
      v_sql_template := v_sql_template ||
'               ''E'', nvl(glbc.opening_year_aggregate,0) +' || pv_nl ||
'                    nvl(glbc.period_aggregate<<<period_days>>>,glb.period_aggregate<<<period_days>>>),' || pv_nl;
    END IF;

    v_sql_template := v_sql_template ||
'               nvl(glb.opening_year_aggregate,0) +' || pv_nl ||
'               nvl(glb.period_aggregate<<<period_days>>>,0)) /' || pv_nl ||
'        <<<year_days>>> / nvl(ccy_mau_c.mau, ccy_mau.mau)) * nvl(ccy_mau_c.mau, ccy_mau.mau),' || pv_nl ||
'  decode(sign(glb.period_aggregate<<<period_days>>>),' || pv_nl ||
'         -1, null,' || pv_nl ||
'         round(nvl(glb.period_aggregate<<<period_days>>>,0) / <<<period_days>>> / ccy_mau.mau) * ccy_mau.mau),' || pv_nl ||
'  decode(sign(glb.period_aggregate<<<period_days>>>),' || pv_nl ||
'         -1, -round(nvl(glb.period_aggregate<<<period_days>>>,0) / <<<period_days>>> / ccy_mau.mau) * ccy_mau.mau,' || pv_nl ||
'         null),' || pv_nl ||
'  decode(sign(decode(glb.currency_type,' || pv_nl ||
'                     ''T'', nvl(glb.year_aggregate<<<period_days>>>,0),' || pv_nl ||
'                     ''O'', nvl(glb.year_aggregate<<<period_days>>>,0),' || pv_nl ||
'                     nvl(glb.opening_year_aggregate,0) +' || pv_nl ||
'                     nvl(glb.period_aggregate<<<period_days>>>,0))),' || pv_nl ||
'         -1, null,' || pv_nl ||
'         round(decode(glb.currency_type,' || pv_nl ||
'                      ''T'', nvl(glb.year_aggregate<<<period_days>>>,0),' || pv_nl ||
'                      ''O'', nvl(glb.year_aggregate<<<period_days>>>,0),' || pv_nl ||
'                      nvl(glb.opening_year_aggregate,0) +' || pv_nl ||
'                      nvl(glb.period_aggregate<<<period_days>>>,0)) /' || pv_nl ||
'               <<<year_days>>> / ccy_mau.mau) * ccy_mau.mau),' || pv_nl ||
'  decode(sign(decode(glb.currency_type,' || pv_nl ||
'                     ''T'', nvl(glb.year_aggregate<<<period_days>>>,0),' || pv_nl ||
'                     ''O'', nvl(glb.year_aggregate<<<period_days>>>,0),' || pv_nl ||
'                     nvl(glb.opening_year_aggregate,0) +' || pv_nl ||
'                     nvl(glb.period_aggregate<<<period_days>>>,0))),' || pv_nl ||
'         -1, -round(decode(glb.currency_type,' || pv_nl ||
'                           ''T'', nvl(glb.year_aggregate<<<period_days>>>,0),' || pv_nl ||
'                           ''O'', nvl(glb.year_aggregate<<<period_days>>>,0),' || pv_nl ||
'                           nvl(glb.opening_year_aggregate,0) +' || pv_nl ||
'                           nvl(glb.period_aggregate<<<period_days>>>,0)) /' || pv_nl ||
'                    <<<year_days>>> / ccy_mau.mau) * ccy_mau.mau,' || pv_nl ||
'         null)' || pv_nl ||
'FROM' || pv_nl ||
'  FEM_INTG_EXEC_PARAMS_GT param,' || pv_nl ||
'  GL_DAILY_BALANCES glb,' || pv_nl;

    IF FEM_GL_POST_PROCESS_PKG.pv_curr_option = 'ENTERED' THEN
      v_sql_template := v_sql_template ||
'  GL_DAILY_BALANCES glbc,' || pv_nl;
    END IF;

    IF FEM_GL_POST_PROCESS_PKG.pv_bsv_option = 'SPECIFIC' THEN
      v_sql_template := v_sql_template ||
'  FEM_INTG_BAL_DEF_BSVS bsv,' || pv_nl;
    END IF;

    v_sql_template := v_sql_template ||
'  GL_CODE_COMBINATIONS cc,' || pv_nl ||
'  FEM_INTG_OGL_CCID_MAP ccmap,' || pv_nl ||
'  FEM_EXT_ACCT_TYPES_ATTR xat_sign,' || pv_nl ||
'  (SELECT currency_code,' || pv_nl ||
'          nvl(minimum_accountable_unit, power(10,-precision)) mau' || pv_nl ||
'   FROM   FND_CURRENCIES fccy) ccy_mau,' || pv_nl ||
'  (SELECT currency_code,' || pv_nl ||
'          nvl(minimum_accountable_unit, power(10,-precision)) mau' || pv_nl ||
'   FROM   FND_CURRENCIES fccy) ccy_mau_c' || pv_nl ||
'WHERE param.error_code IS NULL' || pv_nl ||
'AND   param.request_id IS NOT NULL' || pv_nl ||
'AND   param.period_name = ''<<<period_name>>>''' || pv_nl ||
'AND   ccy_mau.currency_code = glb.currency_code' || pv_nl;

    IF FEM_GL_POST_PROCESS_PKG.pv_curr_option = 'ENTERED' THEN
      v_sql_template := v_sql_template ||
'AND   ccy_mau_c.currency_code (+)= glbc.currency_code' || pv_nl;
    ELSE
      v_sql_template := v_sql_template ||
'AND   ccy_mau_c.currency_code = glb.currency_code' || pv_nl;
    END IF;

    v_sql_template := v_sql_template ||
'AND   glb.ledger_id = ' || FEM_GL_POST_PROCESS_PKG.pv_ledger_id || pv_nl ||
'AND   glb.period_name = param.period_name' || pv_nl ||
'AND   glb.actual_flag = ''A''' || pv_nl ||
'AND   glb.currency_code <> ''STAT''' || pv_nl;

    IF FEM_GL_POST_PROCESS_PKG.pv_curr_option = 'ENTERED' THEN
      v_sql_template := v_sql_template ||
'AND   glbc.ledger_id (+)= ' || FEM_GL_POST_PROCESS_PKG.pv_ledger_id || pv_nl ||
'AND   glbc.code_combination_id (+)= glb.code_combination_id' || pv_nl ||
'AND   glbc.currency_code (+)= ''' || FEM_GL_POST_PROCESS_PKG.pv_func_ccy_code || '''' || pv_nl ||
'AND   glbc.currency_type (+)= ''C''' || pv_nl ||
'AND   glbc.actual_flag (+)= ''A''' || pv_nl ||
'AND   glbc.period_name (+)= glb.period_name' || pv_nl ||
'AND   glbc.converted_from_currency (+)= glb.currency_code' || pv_nl;
    END IF;

    IF FEM_GL_POST_PROCESS_PKG.pv_bsv_option = 'SPECIFIC' THEN
      v_sql_template := v_sql_template ||
'AND   bsv.bal_rule_obj_def_id = ' || FEM_GL_POST_PROCESS_PKG.pv_rule_obj_def_id || pv_nl ||
'AND   bsv.balance_seg_value = cc.' || FEM_GL_POST_PROCESS_PKG.pv_bsv_app_col_name || pv_nl;
    END IF;

    v_sql_template := v_sql_template ||
'AND   cc.code_combination_id = glb.code_combination_id' || pv_nl ||
'AND   cc.template_id IS NULL' || pv_nl ||
'AND   ccmap.code_combination_id (+)= cc.code_combination_id' || pv_nl ||
'AND   ccmap.global_vs_combo_id (+)= ' || FEM_GL_POST_PROCESS_PKG.pv_global_vs_combo_id || pv_nl ||
'AND   ccmap.COMPANY_COST_CENTER_ORG_ID (+)<> -1' || pv_nl ||
'AND   ccmap.NATURAL_ACCOUNT_ID (+)<> -1' || pv_nl ||
'AND   ccmap.LINE_ITEM_ID (+)<> -1' || pv_nl ||
'AND   ccmap.PRODUCT_ID (+)<> -1' || pv_nl ||
'AND   ccmap.CHANNEL_ID (+)<> -1' || pv_nl ||
'AND   ccmap.PROJECT_ID (+)<> -1' || pv_nl ||
'AND   ccmap.CUSTOMER_ID (+)<> -1' || pv_nl ||
'AND   ccmap.ENTITY_ID (+)<> -1' || pv_nl ||
'AND   ccmap.INTERCOMPANY_ID (+)<> -1' || pv_nl ||
'AND   ccmap.USER_DIM1_ID (+)<> -1' || pv_nl ||
'AND   ccmap.USER_DIM2_ID (+)<> -1' || pv_nl ||
'AND   ccmap.USER_DIM3_ID (+)<> -1' || pv_nl ||
'AND   ccmap.USER_DIM4_ID (+)<> -1' || pv_nl ||
'AND   ccmap.USER_DIM5_ID (+)<> -1' || pv_nl ||
'AND   ccmap.USER_DIM6_ID (+)<> -1' || pv_nl ||
'AND   ccmap.USER_DIM7_ID (+)<> -1' || pv_nl ||
'AND   ccmap.USER_DIM8_ID (+)<> -1' || pv_nl ||
'AND   ccmap.USER_DIM9_ID (+)<> -1' || pv_nl ||
'AND   ccmap.USER_DIM10_ID (+)<> -1' || pv_nl ||
'AND   ccmap.TASK_ID (+)<> -1' || pv_nl ||
'AND   xat_sign.attribute_id (+)= ' || v_xat_sign_attr_id || pv_nl ||
'AND   xat_sign.version_id (+)= ' || v_xat_sign_v_id || pv_nl ||
'AND   xat_sign.ext_account_type_code (+)= ccmap.extended_account_type' || pv_nl;


    -- If there is a range, only pick up delta loads for bsv's in the range
    IF p_bsv_range_low IS NOT NULL AND p_bsv_range_high IS NOT NULL THEN
      v_sql_template := v_sql_template ||
'AND   (NOT EXISTS' || pv_nl ||
'       (SELECT 1' || pv_nl ||
'        FROM fem_balances fb_curr' || pv_nl ||
'        WHERE fb_curr.ledger_id = ' || FEM_GL_POST_PROCESS_PKG.pv_ledger_id || pv_nl ||
'        AND fb_curr.dataset_code = param.output_dataset_code' || pv_nl ||
'        AND fb_curr.cal_period_id = param.cal_period_id)' || pv_nl ||
'       OR cc.' || FEM_GL_POST_PROCESS_PKG.pv_bsv_app_col_name || ' BETWEEN ' || p_bsv_range_low || ' AND ' || p_bsv_range_high || ')' || pv_nl;
    END IF;

    IF FEM_GL_POST_PROCESS_PKG.pv_curr_option = 'ENTERED' THEN
      IF FEM_GL_POST_PROCESS_PKG.pv_xlated_bal_option = 'SPECIFIC' THEN
        v_sql_template := v_sql_template ||
'AND   (glb.currency_type IN (''U'', ''E'') OR' || pv_nl ||
'       (glb.currency_type IN (''T'', ''O'') AND' || pv_nl ||
'        EXISTS' || pv_nl ||
'        (SELECT 1' || pv_nl ||
'         FROM FEM_INTG_BAL_DEF_CURRS ccy' || pv_nl ||
'         WHERE ccy.bal_rule_obj_def_id = ' || FEM_GL_POST_PROCESS_PKG.pv_rule_obj_def_id || pv_nl ||
'         AND   ccy.xlated_currency_code = glb.currency_code)))' || pv_nl;
      ELSIF FEM_GL_POST_PROCESS_PKG.pv_xlated_bal_option = 'ALL' THEN
        v_sql_template := v_sql_template ||
'AND   glb.currency_type IN (''U'', ''E'', ''T'', ''O'')' || pv_nl;
      ELSE -- no translated balances
        v_sql_template := v_sql_template ||
'AND   glb.currency_type IN (''U'', ''E'')' || pv_nl;
      END IF;
    ELSIF FEM_GL_POST_PROCESS_PKG.pv_curr_option = 'FUNCTIONAL' THEN
      IF FEM_GL_POST_PROCESS_PKG.pv_xlated_bal_option = 'SPECIFIC' THEN
        v_sql_template := v_sql_template ||
'AND   (glb.currency_type = ''U'' OR' || pv_nl ||
'       (glb.currency_type IN (''T'', ''O'') AND' || pv_nl ||
'        EXISTS' || pv_nl ||
'        (SELECT 1' || pv_nl ||
'         FROM FEM_INTG_BAL_DEF_CURRS ccy' || pv_nl ||
'         WHERE ccy.bal_rule_obj_def_id = ' || FEM_GL_POST_PROCESS_PKG.pv_rule_obj_def_id || pv_nl ||
'         AND   ccy.xlated_currency_code = glb.currency_code)))' || pv_nl;
      ELSIF FEM_GL_POST_PROCESS_PKG.pv_xlated_bal_option = 'ALL' THEN
        v_sql_template := v_sql_template ||
'AND   glb.currency_type IN (''U'', ''T'', ''O'')' || pv_nl;
      ELSE -- no translated balances
        v_sql_template := v_sql_template ||
'AND   glb.currency_type = ''U''' || pv_nl;
      END IF;
    ELSE -- Translated balances only
      IF FEM_GL_POST_PROCESS_PKG.pv_xlated_bal_option = 'SPECIFIC' THEN
        v_sql_template := v_sql_template ||
'AND   glb.currency_type IN (''T'', ''O'')' || pv_nl ||
'AND   EXISTS' || pv_nl ||
'      (SELECT 1' || pv_nl ||
'       FROM FEM_INTG_BAL_DEF_CURRS ccy' || pv_nl ||
'       WHERE ccy.bal_rule_obj_def_id = ' || FEM_GL_POST_PROCESS_PKG.pv_rule_obj_def_id || pv_nl ||
'       AND   ccy.xlated_currency_code = glb.currency_code)' || pv_nl;
      ELSE -- All translated balances
        v_sql_template := v_sql_template ||
'AND   glb.currency_type IN (''T'', ''O'')' || pv_nl;
      END IF;
    END IF;


    -- Print the statement template
    FOR iterator IN 1..trunc((length(v_sql_template)+1499)/1500) LOOP
      FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'v_sql_template: ' || iterator,
       p_token2   => 'VAR_VAL',
       p_value2   => substr(v_sql_template, iterator*1500-1499, 1500));
    END LOOP;

    -- Loop through all periods being loaded, and load the information
    FOR load_period_info IN load_periods_c LOOP

      -- If the as-of-date is in this period, then use it instead of the
      -- period end date
      IF p_effective_date < load_period_info.period_end_date THEN
        v_end_date := p_effective_date;
      ELSE
        v_end_date := load_period_info.period_end_date;
      END IF;

      v_sql := v_sql_template;

      -- Start replacing the artificial tags we put in the template
      v_sql := replace(	v_sql,
			'<<<period_days>>>',
			v_end_date - load_period_info.period_start_date + 1);

      v_sql := replace(	v_sql,
			'<<<quarter_days>>>',
			v_end_date - load_period_info.quarter_start_date + 1);

      v_sql := replace(	v_sql,
			'<<<year_days>>>',
			v_end_date - load_period_info.year_start_date + 1);

      v_sql := replace(	v_sql,
			'<<<period_name>>>',
			load_period_info.period_name);


      -- Print the statement
      FOR iterator IN 1..trunc((length(v_sql)+1499)/1500) LOOP
        FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_statement,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_204',
         p_token1   => 'VAR_NAME',
         p_value1   => 'v_sql: ' || iterator,
         p_token2   => 'VAR_VAL',
         p_value2   => substr(v_sql, iterator*1500-1499, 1500));
      END LOOP;

      EXECUTE IMMEDIATE v_sql;

      v_intermediate_rows_inserted := SQL%ROWCOUNT;
      x_num_rows_inserted := x_num_rows_inserted+v_intermediate_rows_inserted;

      -- Print the number of rows inserted
      FEM_ENGINES_PKG.Tech_Message(
        p_severity => pc_log_level_statement,
        p_module   => v_module,
        p_msg_text => 'Inserted ' || TO_CHAR(v_intermediate_rows_inserted) ||
                      ' rows into FEM_BAL_POST_INTERIM_GT');

    END LOOP;

    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => v_module,
       p_msg_text => 'END');

  EXCEPTION
    WHEN OTHERS THEN
      x_completion_code := 2;

      FEM_ENGINES_PKG.User_Message
        (p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_215',
         p_token1   => 'ERR_MSG',
         p_value1   => SQLERRM);

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_unexpected,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_215',
         p_token1   => 'ERR_MSG',
         p_value1   => SQLERRM);

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_procedure,
         p_module   => v_module,
         p_msg_text => 'END');

  END Load_Avg_Balances;


  PROCEDURE Load_Post_Process(x_completion_code	OUT NOCOPY NUMBER) IS

    v_module	VARCHAR2(100);
  BEGIN
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => v_module,
       p_msg_text => 'BEGIN');

    pv_nl := '
';
    v_module := 'fem.plsql.fem_intg_bal_eng_load.load_post_process';

    x_completion_code := 0;

    -- Print the As-of-date
    FEM_ENGINES_PKG.Tech_Message(
	p_severity => pc_log_level_statement,
	p_module   => v_module,
	p_app_name => 'FEM',
	p_msg_name => 'FEM_GL_POST_204',
	p_token1   => 'VAR_NAME',
	p_value1   => 'FEM_GL_POST_PROCESS_PKG.pv_func_ccy_code',
	p_token2   => 'VAR_VAL',
	p_value2   => FEM_GL_POST_PROCESS_PKG.pv_func_ccy_code);

    INSERT INTO fem_intg_bpi_curr_gt(
 dataset_code, cal_period_id, code_combination_id, financial_elem_id,
 delta_run_id, xtd_balance_f_sum, qtd_balance_f_sum, ytd_balance_f_sum)
    SELECT /*+ full(fem_bal_post_interim_gt) */
           dataset_code, cal_period_id, code_combination_id,
           financial_elem_id, delta_run_id,
           SUM(nvl(xtd_balance_f,0)),
           SUM(nvl(qtd_balance_f,0)),
           SUM(nvl(ytd_balance_f,0))
    FROM fem_bal_post_interim_gt
    WHERE currency_code <> FEM_GL_POST_PROCESS_PKG.pv_func_ccy_code
    AND   currency_code <> 'STAT'
    AND   currency_type_code = 'ENTERED'
    AND   posting_error_flag = 'N'
    GROUP BY dataset_code, cal_period_id, code_combination_id,
             financial_elem_id, delta_run_id;

    UPDATE /*+ FULL(bpi) */ FEM_BAL_POST_INTERIM_GT bpi
    SET (xtd_balance_e,
         qtd_balance_e,
         ytd_balance_e,
         xtd_balance_f,
         qtd_balance_f,
         ytd_balance_f) =
    (SELECT
       bpi.xtd_balance_e - nvl(bpi_beq.xtd_balance_f_sum,0),
       bpi.qtd_balance_e - nvl(bpi_beq.qtd_balance_f_sum,0),
       bpi.ytd_balance_e - nvl(bpi_beq.ytd_balance_f_sum,0),
       bpi.xtd_balance_e - nvl(bpi_beq.xtd_balance_f_sum,0),
       bpi.qtd_balance_e - nvl(bpi_beq.qtd_balance_f_sum,0),
       bpi.ytd_balance_e - nvl(bpi_beq.ytd_balance_f_sum,0)
     FROM FEM_INTG_BPI_CURR_GT bpi_beq
     WHERE bpi_beq.dataset_code = bpi.dataset_code
     AND   bpi_beq.cal_period_id = bpi.cal_period_id
     AND   bpi_beq.code_combination_id = bpi.code_combination_id
     AND   bpi_beq.financial_elem_id = bpi.financial_elem_id
     AND   ((bpi_beq.delta_run_id IS NULL AND bpi.delta_run_id IS NULL) OR
            bpi_beq.delta_run_id = bpi.delta_run_id)
    )
    WHERE bpi.currency_code = FEM_GL_POST_PROCESS_PKG.pv_func_ccy_code
-- BugFix 6795389: Added the condition AND  FINANCIAL_ELEM_ID <> 140
-- To update rows for actual balances only
    AND BPI.FINANCIAL_ELEM_ID <> 140
    AND   bpi.posting_error_flag = 'N'
    AND   EXISTS
    (SELECT 1
     FROM fem_intg_bpi_curr_gt bpi_beq
     WHERE bpi_beq.dataset_code = bpi.dataset_code
     AND   bpi_beq.cal_period_id = bpi.cal_period_id
     AND   bpi_beq.code_combination_id = bpi.code_combination_id
     AND   bpi_beq.financial_elem_id = bpi.financial_elem_id
     AND   ((bpi_beq.delta_run_id IS NULL AND bpi.delta_run_id IS NULL) OR
            bpi_beq.delta_run_id = bpi.delta_run_id));

    -- Print the number of rows inserted
    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_statement,
      p_module   => v_module,
      p_msg_text => 'Updated ' || TO_CHAR(SQL%ROWCOUNT) ||
                    ' rows in FEM_BAL_POST_INTERIM_GT');

    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => v_module,
       p_msg_text => 'END');

  EXCEPTION
    WHEN OTHERS THEN
      x_completion_code := 2;

      FEM_ENGINES_PKG.User_Message
        (p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_215',
         p_token1   => 'ERR_MSG',
         p_value1   => SQLERRM);

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_unexpected,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_215',
         p_token1   => 'ERR_MSG',
         p_value1   => SQLERRM);

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_procedure,
         p_module   => v_module,
         p_msg_text => 'END');

  END Load_Post_Process;


  PROCEDURE Map_Adv_LI_FE(x_completion_code	OUT NOCOPY NUMBER) IS
    v_na_fe_attr_id	NUMBER;
    v_na_fe_v_id	NUMBER;
    v_na_li_attr_id	NUMBER;
    v_na_li_v_id	NUMBER;

    v_error_code		NUMBER;

    v_module	VARCHAR2(100);
  BEGIN
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => v_module,
       p_msg_text => 'BEGIN');

    pv_nl := '
';
    v_module := 'fem.plsql.fem_intg_bal_eng_load.map_adv_li_fe';

    x_completion_code := 0;

    FEM_DIMENSION_UTIL_PKG.get_dim_attr_id_ver_id(
      p_dim_id		=> FEM_GL_POST_PROCESS_PKG.pv_nat_acct_dim_id,
      p_attr_label	=> 'FINANCIAL_ELEMENT',
      x_attr_id		=> v_na_fe_attr_id,
      x_ver_id		=> v_na_fe_v_id,
      x_err_code	=> v_error_code);

    FEM_DIMENSION_UTIL_PKG.get_dim_attr_id_ver_id(
      p_dim_id		=> FEM_GL_POST_PROCESS_PKG.pv_nat_acct_dim_id,
      p_attr_label	=> 'LINE_ITEM',
      x_attr_id		=> v_na_li_attr_id,
      x_ver_id		=> v_na_li_v_id,
      x_err_code	=> v_error_code);


    UPDATE FEM_BAL_POST_INTERIM_GT bpi
    SET (FINANCIAL_ELEM_ID, LINE_ITEM_ID) =
    (SELECT nvl(naa_fe.dim_attribute_numeric_member, bpi.financial_elem_id),
            nvl(naa_li.dim_attribute_numeric_member, bpi.line_item_id)
     FROM   FEM_NAT_ACCTS_ATTR naa_fe,
            FEM_NAT_ACCTS_ATTR naa_li
     WHERE  naa_fe.attribute_id (+)= v_na_fe_attr_id
     AND    naa_fe.version_id (+)= v_na_fe_v_id
     AND    naa_fe.natural_account_id (+)= bpi.natural_account_id
     AND    naa_li.attribute_id (+)= v_na_li_attr_id
     AND    naa_li.version_id (+)= v_na_li_v_id
     AND    naa_li.natural_account_id (+)= bpi.natural_account_id)
    WHERE  bpi.posting_error_flag = 'N';

    -- Print the number of rows updated. This may not be the number of
    -- overrides performed, since the outer-joins will also give you rows
    -- without overrides.
    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_statement,
      p_module   => v_module,
      p_msg_text => 'Updated ' || TO_CHAR(SQL%ROWCOUNT) ||
                    ' rows in FEM_BAL_POST_INTERIM_GT');

    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => v_module,
       p_msg_text => 'END');

  EXCEPTION
    WHEN OTHERS THEN
      x_completion_code := 2;

      FEM_ENGINES_PKG.User_Message
        (p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_215',
         p_token1   => 'ERR_MSG',
         p_value1   => SQLERRM);

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_unexpected,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_215',
         p_token1   => 'ERR_MSG',
         p_value1   => SQLERRM);

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_procedure,
         p_module   => v_module,
         p_msg_text => 'END');

  END Map_Adv_LI_FE;

  PROCEDURE Mark_Posted_Incr_Bal(x_completion_code	OUT NOCOPY NUMBER,
				 p_bsv_range_low	VARCHAR2,
				 p_bsv_range_high	VARCHAR2) IS
    v_actual_flag	VARCHAR2(1);

    v_delete_stmt	VARCHAR2(4000);
    v_insert_stmt	VARCHAR2(4000);
    v_merge_stmt	VARCHAR2(8000);
    v_update_stmt	VARCHAR2(4000);
    v_flex_query_stmt	VARCHAR2(2000);

    v_module	VARCHAR2(100);
  BEGIN
    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => v_module,
       p_msg_text => 'BEGIN');

    pv_nl := '
';
    v_module := 'fem.plsql.fem_intg_bal_eng_load.mark_posted_incr_bal';

    x_completion_code := 0;

    IF FEM_GL_POST_PROCESS_PKG.pv_ds_balance_type_cd = 'ACTUAL' THEN
      v_actual_flag := 'A';
    ELSIF FEM_GL_POST_PROCESS_PKG.pv_ds_balance_type_cd = 'BUDGET' THEN
      v_actual_flag := 'B';
    ELSE -- Encumbrance
      v_actual_flag := 'E';
    END IF;


    -- First, insert rows into GL_TRACK_DELTA_BALANCES to flag that delta
    -- balances should be tracked from now in GL
    INSERT INTO GL_TRACK_DELTA_BALANCES(
      ledger_id, program_code, period_name, actual_flag,
      extract_level_code, currency_type_code, enabled_flag, last_update_date,
      last_updated_by, creation_date, created_by, last_update_login)
    SELECT DISTINCT FEM_GL_POST_PROCESS_PKG.pv_ledger_id,
                    'FEM',
                    param.period_name,
                    v_actual_flag,
                    'DTL',
                    'B',
                    'Y',
                    sysdate,
                    FEM_GL_POST_PROCESS_PKG.pv_user_id,
                    sysdate,
                    FEM_GL_POST_PROCESS_PKG.pv_user_id,
                    FEM_GL_POST_PROCESS_PKG.pv_login_id
    FROM   FEM_INTG_EXEC_PARAMS_GT param
    WHERE  param.error_code IS NULL
    AND    param.request_id IS NOT NULL
    AND    NOT EXISTS
           (SELECT 1
            FROM   GL_TRACK_DELTA_BALANCES tdb
            WHERE  tdb.ledger_id = FEM_GL_POST_PROCESS_PKG.pv_ledger_id
            AND    tdb.program_code = 'FEM'
            AND    tdb.period_name = param.period_name
            AND    tdb.actual_flag = v_actual_flag
            AND    tdb.extract_level_code = 'DTL'
            AND    tdb.currency_type_code = 'B'
            AND    tdb.enabled_flag = 'Y');

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_statement,
      p_module   => v_module,
      p_msg_text => 'Inserted ' || TO_CHAR(SQL%ROWCOUNT) ||
                    ' rows into GL_TRACK_DELTA_BALANCES');


    -- Now, remove rows from FEM_INTG_DELTA_LOADS if previously errored
    -- delta runs were successfully loaded
    v_delete_stmt :=
'DELETE FROM FEM_INTG_DELTA_LOADS dl' || pv_nl ||
'WHERE  dl.ledger_id = ' || FEM_GL_POST_PROCESS_PKG.pv_ledger_id || pv_nl ||
'AND    dl.loaded_flag = ''N''' || pv_nl;

    -- Now, remove rows from FEM_INTG_DELTA_LOADS if previously errored
    -- delta runs were successfully loaded
    IF p_bsv_range_low IS NOT NULL AND p_bsv_range_high IS NOT NULL THEN
      v_delete_stmt := v_delete_stmt ||
'AND    dl.balance_seg_value BETWEEN ' || p_bsv_range_low || ' AND ' ||
p_bsv_range_high || pv_nl;
    END IF;

    v_delete_stmt := v_delete_stmt ||
'AND    EXISTS' || pv_nl ||
'       (SELECT 1' || pv_nl ||
'        FROM   FEM_INTG_EXEC_PARAMS_GT param' || pv_nl ||
'        WHERE  param.output_dataset_code  = dl.dataset_code' || pv_nl ||
'        AND    param.cal_period_id = dl.cal_period_id' || pv_nl ||
'        AND    param.error_code IS NULL' || pv_nl ||
'        AND    param.request_id IS NOT NULL)' || pv_nl ||
'AND    NOT EXISTS' || pv_nl ||
'       (SELECT 1' || pv_nl ||
'        FROM   FEM_BAL_POST_INTERIM_GT bpi,' || pv_nl ||
'               GL_CODE_COMBINATIONS from_cc' || pv_nl ||
'        WHERE  bpi.delta_run_id = dl.delta_run_id' || pv_nl ||
'        AND    bpi.posting_error_flag = ''Y''' || pv_nl ||
'        AND    from_cc.code_combination_id = bpi.code_combination_id' || pv_nl ||
'        AND    from_cc.' || FEM_GL_POST_PROCESS_PKG.pv_bsv_app_col_name ||
' = dl.balance_seg_value)';

    -- Print the statement
    FOR iterator IN 1..trunc((length(v_delete_stmt)+1499)/1500) LOOP
      FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'v_delete_stmt: ' || iterator,
       p_token2   => 'VAR_VAL',
       p_value2   => substr(v_delete_stmt, iterator*1500-1499, 1500));
    END LOOP;

    EXECUTE IMMEDIATE v_delete_stmt;

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_statement,
      p_module   => v_module,
      p_msg_text => 'Deleted ' || TO_CHAR(SQL%ROWCOUNT) ||
                    ' rows from FEM_INTG_DELTA_LOADS');


    -- Now, insert errored delta runs that were attempted for the first
    -- time in this load
    v_insert_stmt :=
'INSERT INTO FEM_INTG_DELTA_LOADS(LEDGER_ID, DATASET_CODE, CAL_PERIOD_ID, ' ||
'DELTA_RUN_ID, BALANCE_SEG_VALUE, LOADED_FLAG, CREATION_DATE, CREATED_BY, ' ||
'LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN)' || pv_nl ||
'SELECT DISTINCT ' || FEM_GL_POST_PROCESS_PKG.pv_ledger_id || ',' || pv_nl ||
'                param.output_dataset_code,' || pv_nl ||
'                param.cal_period_id,' || pv_nl ||
'                bpi.delta_run_id,' || pv_nl ||
'                dl.balance_seg_value,' || pv_nl ||
'                ''N'',' || pv_nl ||
'                sysdate,' || pv_nl ||
'                ' || FEM_GL_POST_PROCESS_PKG.pv_user_id || ',' || pv_nl ||
'                sysdate,' || pv_nl ||
'                ' || FEM_GL_POST_PROCESS_PKG.pv_user_id || ',' || pv_nl ||
'                ' || FEM_GL_POST_PROCESS_PKG.pv_login_id || pv_nl ||
'FROM   FEM_INTG_EXEC_PARAMS_GT param,' || pv_nl ||
'       FEM_BAL_POST_INTERIM_GT bpi,' || pv_nl ||
'       GL_CODE_COMBINATIONS from_cc,' || pv_nl ||
'       FEM_INTG_DELTA_LOADS dl' || pv_nl ||
'WHERE  param.load_method_code = ''I''' || pv_nl ||
'AND    param.error_code IS NULL' || pv_nl ||
'AND    param.request_id IS NOT NULL' || pv_nl ||
'AND    dl.ledger_id = ' || FEM_GL_POST_PROCESS_PKG.pv_ledger_id || pv_nl ||
'AND    dl.dataset_code = param.output_dataset_code' || pv_nl ||
'AND    dl.cal_period_id = param.cal_period_id' || pv_nl ||
'AND    dl.loaded_flag = ''Y''' || pv_nl;

    IF p_bsv_range_low IS NOT NULL AND p_bsv_range_high IS NOT NULL THEN
      v_insert_stmt := v_insert_stmt ||
'AND    dl.balance_seg_value BETWEEN ' || p_bsv_range_low || ' AND ' ||
p_bsv_range_high || pv_nl;
    END IF;

    v_insert_stmt := v_insert_stmt ||
'AND    from_cc.code_combination_id = bpi.code_combination_id' || pv_nl ||
'AND    from_cc.' || FEM_GL_POST_PROCESS_PKG.pv_bsv_app_col_name ||
' = dl.balance_seg_value' || pv_nl ||
'AND    bpi.dataset_code = param.output_dataset_code' || pv_nl ||
'AND    bpi.cal_period_id = param.cal_period_id' || pv_nl ||
'AND    bpi.bal_post_type_code = ''A''' || pv_nl ||
'AND    bpi.posting_error_flag = ''Y''' || pv_nl ||
'AND    bpi.delta_run_id BETWEEN dl.delta_run_id + 1 AND ' ||
FEM_GL_POST_PROCESS_PKG.pv_max_delta_run_id;


    -- Print the statement
    FOR iterator IN 1..trunc((length(v_insert_stmt)+1499)/1500) LOOP
      FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'v_insert_stmt: ' || iterator,
       p_token2   => 'VAR_VAL',
       p_value2   => substr(v_insert_stmt, iterator*1500-1499, 1500));
    END LOOP;

    EXECUTE IMMEDIATE v_insert_stmt;

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_statement,
      p_module   => v_module,
      p_msg_text => 'Inserted ' || TO_CHAR(SQL%ROWCOUNT) ||
                    ' rows into FEM_INTG_DELTA_LOADS');

    v_flex_query_stmt := get_flex_values_query;

    v_merge_stmt :=
'MERGE INTO FEM_INTG_DELTA_LOADS dl' || pv_nl ||
'USING (SELECT param_in.output_dataset_code,' || pv_nl ||
'              param_in.cal_period_id,' || pv_nl ||
'              flex.flex_value' || pv_nl ||
'       FROM   FEM_INTG_EXEC_PARAMS_GT param_in,' || pv_nl ||
'              (' || v_flex_query_stmt || ') flex' || pv_nl ||
'       WHERE  param_in.error_code IS NULL' || pv_nl ||
'       AND    param_in.request_id IS NOT NULL' || pv_nl ||
'       AND    param_in.load_method_code = ''S'') param' || pv_nl ||
'ON (dl.ledger_id = ' || FEM_GL_POST_PROCESS_PKG.pv_ledger_id || ' AND' || pv_nl ||
'    dl.dataset_code = param.output_dataset_code AND' || pv_nl ||
'    dl.cal_period_id = param.cal_period_id AND' || pv_nl ||
'    dl.balance_seg_value = param.flex_value AND' || pv_nl ||
'    dl.loaded_flag = ''Y'')' || pv_nl ||
'WHEN MATCHED THEN' || pv_nl ||
'  UPDATE SET dl.delta_run_id = ' || FEM_GL_POST_PROCESS_PKG.pv_max_delta_run_id || ',' || pv_nl ||
'             dl.last_update_date = sysdate,' || pv_nl ||
'             dl.last_updated_by = ' || FEM_GL_POST_PROCESS_PKG.pv_user_id || ',' || pv_nl ||
'             dl.last_update_login = ' || FEM_GL_POST_PROCESS_PKG.pv_login_id || pv_nl ||
'WHEN NOT MATCHED THEN' || pv_nl ||
'  INSERT(LEDGER_ID, DATASET_CODE, CAL_PERIOD_ID, DELTA_RUN_ID, ' ||
'BALANCE_SEG_VALUE, LOADED_FLAG, CREATION_DATE, CREATED_BY, ' ||
'LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN)' || pv_nl ||
'  VALUES' || pv_nl ||
'  (' || FEM_GL_POST_PROCESS_PKG.pv_ledger_id || ',' || pv_nl ||
'   param.output_dataset_code,' || pv_nl ||
'   param.cal_period_id,' || pv_nl ||
'   ' || FEM_GL_POST_PROCESS_PKG.pv_max_delta_run_id || ',' || pv_nl ||
'   param.flex_value,' || pv_nl ||
'   ''Y'',' || pv_nl ||
'   sysdate,' || pv_nl ||
'   ' || FEM_GL_POST_PROCESS_PKG.pv_user_id || ',' || pv_nl ||
'   sysdate,' || pv_nl ||
'   ' || FEM_GL_POST_PROCESS_PKG.pv_user_id || ',' || pv_nl ||
'   ' || FEM_GL_POST_PROCESS_PKG.pv_login_id || ')';


    FOR iterator IN 1..trunc((length(v_merge_stmt)+1499)/1500) LOOP
      FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'v_merge_stmt: ' || iterator,
       p_token2   => 'VAR_VAL',
       p_value2   => substr(v_merge_stmt, iterator*1500-1499, 1500));
    END LOOP;

    EXECUTE IMMEDIATE v_merge_stmt;

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_statement,
      p_module   => v_module,
      p_msg_text => 'Merged ' || TO_CHAR(SQL%ROWCOUNT) ||
                    ' rows into FEM_INTG_DELTA_LOADS');

    v_update_stmt :=
'UPDATE fem_intg_delta_loads dl' || pv_nl ||
'SET    delta_run_id = ' || FEM_GL_POST_PROCESS_PKG.pv_max_delta_run_id || ',' || pv_nl ||
'       last_update_date = sysdate,' || pv_nl ||
'       last_updated_by = ' || FEM_GL_POST_PROCESS_PKG.pv_user_id || ',' || pv_nl ||
'       last_update_login = ' || FEM_GL_POST_PROCESS_PKG.pv_login_id || pv_nl ||
'WHERE  dl.ledger_id = ' || FEM_GL_POST_PROCESS_PKG.pv_ledger_id || pv_nl ||
'AND    dl.loaded_flag = ''Y''' || pv_nl;

    IF p_bsv_range_low IS NOT NULL AND p_bsv_range_high IS NOT NULL THEN
      v_update_stmt := v_update_stmt ||
'AND    dl.balance_seg_value BETWEEN ' || p_bsv_range_low || ' AND ' ||
p_bsv_range_high || pv_nl;
    END IF;

    v_update_stmt := v_update_stmt ||
'AND    (dataset_code, cal_period_id) IN' || pv_nl ||
'       (SELECT param.output_dataset_code,' || pv_nl ||
'               param.cal_period_id' || pv_nl ||
'        FROM   fem_intg_exec_params_gt param' || pv_nl ||
'        WHERE  param.error_code IS NULL' || pv_nl ||
'        AND    param.request_id IS NOT NULL' || pv_nl ||
'        AND    param.load_method_code = ''I'')';


    FOR iterator IN 1..trunc((length(v_update_stmt)+1499)/1500) LOOP
      FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_statement,
       p_module   => v_module,
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'v_update_stmt: ' || iterator,
       p_token2   => 'VAR_VAL',
       p_value2   => substr(v_update_stmt, iterator*1500-1499, 1500));
    END LOOP;

    EXECUTE IMMEDIATE v_update_stmt;

    FEM_ENGINES_PKG.Tech_Message(
      p_severity => pc_log_level_statement,
      p_module   => v_module,
      p_msg_text => 'Updated ' || TO_CHAR(SQL%ROWCOUNT) ||
                    ' rows into FEM_INTG_DELTA_LOADS');

    FEM_ENGINES_PKG.Tech_Message
      (p_severity => pc_log_level_procedure,
       p_module   => v_module,
       p_msg_text => 'END');

  EXCEPTION
    WHEN OTHERS THEN
      x_completion_code := 2;

      FEM_ENGINES_PKG.User_Message
        (p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_215',
         p_token1   => 'ERR_MSG',
         p_value1   => SQLERRM);

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_unexpected,
         p_module   => v_module,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_215',
         p_token1   => 'ERR_MSG',
         p_value1   => SQLERRM);

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => pc_log_level_procedure,
         p_module   => v_module,
         p_msg_text => 'END');

  END Mark_Posted_Incr_Bal;

END FEM_INTG_BAL_ENG_LOAD_PKG;

/
