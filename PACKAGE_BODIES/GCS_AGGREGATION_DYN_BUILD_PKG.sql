--------------------------------------------------------
--  DDL for Package Body GCS_AGGREGATION_DYN_BUILD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_AGGREGATION_DYN_BUILD_PKG" AS
/* $Header: gcsaggbb.pls 120.3 2006/03/06 23:05:29 yingliu noship $ */

  --
  -- PRIVATE GLOBAL VARIABLES
  --
  g_api         VARCHAR2(40) := 'gcs.plsql.GCS_AGGREGATION_DYN_BUILD_PKG';
  g_line_size   NUMBER       := 250;

  g_common_str  VARCHAR2(6500);
  g_subqry_sel  VARCHAR2(1000);
  g_subqry_grp  VARCHAR2(600);

  --
  -- PRIVATE FUNCTIONS
  --

  --
  -- Procedure
  --   build_dim_match_str
  -- Notes
  --   Build nested DECODE to match the dimensions with the given template.
  --   =============================================================
  --   decode(fb.<dimA>, <template alias>.<dimA>,
  --    decode(fb.<dimB>, <template_alias>.<dimB>,
  --     ...
  --   'Y'), ... 'N'),
  --   =============================================================
  FUNCTION build_dim_match_str(p_template_alias VARCHAR2) RETURN VARCHAR2 IS
    fn_name     VARCHAR2(30) := 'BUILD_DIM_MATCH_STR';
    l_col_name  VARCHAR2(30);
    l_dim_req   VARCHAR2(1);
    l_num_dims  NUMBER;

    l_prefix    VARCHAR2(1800);
    l_suffix    VARCHAR2(200);
  BEGIN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.' || fn_name,
                     GCS_UTILITY_PKG.g_module_enter || fn_name ||
                     to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));
    END IF;
    --FND_FILE.PUT_LINE(FND_FILE.LOG, GCS_UTILITY_PKG.g_module_enter ||
    --                  fn_name || to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));

    -- **************************************************

    l_col_name := GCS_UTILITY_PKG.g_gcs_dimension_info.FIRST;
    l_num_dims := 0;
    l_prefix := '';
    l_suffix := '';

    LOOP
      EXIT WHEN (l_col_name IS NULL);

      l_dim_req := GCS_UTILITY_PKG.get_dimension_required(l_col_name);

      -- skip certain dimensions, and only process required dimensions
      IF (    l_dim_req = 'Y'
          AND l_col_name NOT IN ('COMPANY_COST_CENTER_ORG_ID',
                                 'ENTITY_ID',
                                 'INTERCOMPANY_ID')) THEN
        l_num_dims := l_num_dims + 1;

        -- add a level of decode on the dimension
        l_prefix := l_prefix || lpad(' ', l_num_dims) ||
                    'decode(fb.' || l_col_name || ', ' || p_template_alias ||
                            '.' || l_col_name || ',
        ';

        IF (l_num_dims = 1) THEN
          l_suffix := l_suffix || ' ''Y''),';
        ELSE
          l_suffix := l_suffix || ' ''N''),';
        END IF;
      END IF;

      l_col_name := GCS_UTILITY_PKG.g_gcs_dimension_info.NEXT(l_col_name);
    END LOOP;

    -- **************************************************

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.' || fn_name,
                     GCS_UTILITY_PKG.g_module_success || fn_name ||
                     to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));
    END IF;
    --FND_FILE.PUT_LINE(FND_FILE.LOG, GCS_UTILITY_PKG.g_module_success ||
    --                  fn_name || to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));

    -- **************************************************
    RETURN (l_prefix || l_suffix);
    -- **************************************************
  EXCEPTION
    WHEN OTHERS THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                       g_api || '.' || fn_name,
                       GCS_UTILITY_PKG.g_module_failure || fn_name ||
                       to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));
      END IF;
      --FND_FILE.PUT_LINE(FND_FILE.LOG, GCS_UTILITY_PKG.g_module_failure ||
      --                  fn_name || to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));
      RAISE;
  END build_dim_match_str;

  --
  -- Procedure
  --   build_org_id_str
  -- Notes
  --   The select/group by string to be used by org and intercompany id:
  --   =============================================================
  --   decode(l_bal_by_org_flag, 'N',
  --          decode('Y',
  --                 <RE?>,       <consolidation entity's org id>,
  --                 <SUSPENSE?>, <consolidation entity's org id>,
  --                 <CTA?>,      <consolidation entity's org id>,
  --                 company_cost_center_org_id),
  --          company_cost_center_org_id),
  --   =============================================================
  --   RE and Suspense are the same for the whole hierarchy, therefore were
  --   retrieved once and compared with the dimensions using nested DECODE.
  --   CTA is optional and can differ by relationship. The GCT table in the
  --   statement already takes care of the matching, so simply check if
  --   any column in GCT is not null will suffice.
  --
  PROCEDURE build_org_id_str IS
    fn_name     VARCHAR2(30) := 'BUILD_ORG_ID_STR';
  BEGIN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.' || fn_name,
                     GCS_UTILITY_PKG.g_module_enter || fn_name ||
                     to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));
    END IF;
    --FND_FILE.PUT_LINE(FND_FILE.LOG, GCS_UTILITY_PKG.g_module_enter ||
    --                  fn_name || to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));

    -- **************************************************
    -- GCS_UTILITY_PKG.init_dimension_info;

    g_common_str := '        decode(''Y'',
         -- matching against Retained Earnings Account template
        ' || build_dim_match_str('l_re_template') || ' l_default_org_id,
         -- matching against Suspense Account template
        ' || build_dim_match_str('l_sus_template') || ' l_default_org_id,
        company_cost_center_org_id),';

    -- **************************************************
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.' || fn_name,
                     GCS_UTILITY_PKG.g_module_success || fn_name ||
                     to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));
    END IF;
    --FND_FILE.PUT_LINE(FND_FILE.LOG, GCS_UTILITY_PKG.g_module_success ||
    --                  fn_name || to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));

  EXCEPTION
    WHEN OTHERS THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                       g_api || '.' || fn_name,
                       GCS_UTILITY_PKG.g_module_failure || fn_name ||
                       to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));
      END IF;
      --FND_FILE.PUT_LINE(FND_FILE.LOG, GCS_UTILITY_PKG.g_module_failure ||
      --                  fn_name || to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));
      RAISE;
  END build_org_id_str;

  --
  -- Procedure
  --   build_gct_subqry_clauses
  -- Purpose
  --   Build the select/group by strings for the GCT query table.
  -- Notes
  --   The CTA_ prefix in user dimension column names are omitted in the
  --   final alias, so the join can utilize utility procedures.
  --
  PROCEDURE build_gct_subqry_clauses IS
    fn_name     VARCHAR2(30) := 'BUILD_GCT_SUBQRY_CLAUSES';
    l_col_name  VARCHAR2(30);
    l_dim_req   VARCHAR2(1);
    l_ct_prefix VARCHAR2(10);
  BEGIN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.' || fn_name,
                     GCS_UTILITY_PKG.g_module_enter || fn_name ||
                     to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));
    END IF;
    g_subqry_sel := '';
    g_subqry_grp := '';

    l_col_name := GCS_UTILITY_PKG.g_gcs_dimension_info.FIRST;
    LOOP
      EXIT WHEN (l_col_name IS NULL);

      l_dim_req := GCS_UTILITY_PKG.get_dimension_required(l_col_name);

      -- skip certain dimensions, and only process required dimensions
      IF (    l_dim_req = 'Y'
          AND l_col_name NOT IN ('COMPANY_COST_CENTER_ORG_ID',
                                 'ENTITY_ID',
                                 'INTERCOMPANY_ID',
                                 'LINE_ITEM_ID')) THEN
        -- CTA: user dimensions are prefixed with 'CTA_'
        IF (SUBSTR(l_col_name, 1, 8) = 'USER_DIM') THEN
          l_ct_prefix := 'CTA_';
        ELSE
          l_ct_prefix := '';
        END IF;

        -- CTA columns will not have the CTA prefix in the alias
        g_subqry_sel := g_subqry_sel || '                ' ||
                        l_ct_prefix || l_col_name || ' ' || l_col_name || ',
';

        g_subqry_grp := g_subqry_grp || '           ' ||
                        l_ct_prefix || l_col_name || ',
';
      END IF;

      l_col_name := GCS_UTILITY_PKG.g_gcs_dimension_info.NEXT(l_col_name);
    END LOOP;

    -- **************************************************

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.' || fn_name,
                     GCS_UTILITY_PKG.g_module_success || fn_name ||
                     to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));
    END IF;
    --FND_FILE.PUT_LINE(FND_FILE.LOG, GCS_UTILITY_PKG.g_module_success ||
    --                  fn_name || to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));

  EXCEPTION
    WHEN OTHERS THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                       g_api || '.' || fn_name,
                       GCS_UTILITY_PKG.g_module_failure || fn_name ||
                       to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));
      END IF;
      --FND_FILE.PUT_LINE(FND_FILE.LOG, GCS_UTILITY_PKG.g_module_failure ||
      --                  fn_name || to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));
      RAISE;
  END build_gct_subqry_clauses;


  --
  -- PUBLIC FUNCTIONS
  --
  PROCEDURE create_package IS
    fn_name     VARCHAR2(30) := 'CREATE_PACKAGE';

    -- example: control each line to < 80 chars and put <= 50 lines each time
    body_block  VARCHAR2(4000);
    body_len    NUMBER;

    curr_pos    NUMBER;
    line_num    NUMBER := 1;
    comp_err    VARCHAR2(10);

    l_org_dim_str VARCHAR2(6500);
    l_ic_dim_str  VARCHAR2(6500);
  BEGIN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.' || fn_name,
                     GCS_UTILITY_PKG.g_module_enter || fn_name ||
                     to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));
    END IF;
    --FND_FILE.PUT_LINE(FND_FILE.LOG, GCS_UTILITY_PKG.g_module_enter ||
    --                  fn_name || to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));

    -- prepare building block strings
    build_org_id_str;
    build_gct_subqry_clauses;

    l_org_dim_str := '        -- company_cost_center_org_id
' || g_common_str || GCS_UTILITY_PKG.g_nl;

    l_ic_dim_str := '        -- intercompany_id
        decode(intercompany_id, company_cost_center_org_id,
        decode(l_intercompany_id, NULL,
' || g_common_str || '
        intercompany_id), intercompany_id),' || GCS_UTILITY_PKG.g_nl;

    body_block :=
'CREATE OR REPLACE PACKAGE BODY GCS_AGGREGATION_DYNAMIC_PKG AS
/* $Header: gcsaggbb.pls 120.3 2006/03/06 23:05:29 yingliu noship $ */

  --
  -- PRIVATE GLOBAL VARIABLES
  --
  g_api    VARCHAR2(40) := ''gcs.plsql.GCS_AGGREGATION_DYNAMIC_PKG'';

  TYPE t_entity_org_info IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  g_entity_org_info      T_ENTITY_ORG_INFO;

  --
  -- PUBLIC FUNCTIONS
  --

  FUNCTION retrieve_org_id(p_entity_id NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN g_entity_org_info(p_entity_id);
  END retrieve_org_id;

  --
  -- Procedure
  --   insert_full_entry_lines
  -- Notes
  --   The QRY select table has the following structure:
  --    <entity id> <CTA template dimensions> <default org id>
  --    Entity id                Child entities of the consolidation entity
  --                             that has any CTAs from the hierarchy under it
  --    Default org id           Default org id for the entity id
  --    CTA template dimensions  All CTAs from the hierarchy under the entity
  --
  PROCEDURE insert_full_entry_lines(
    p_entry_id           NUMBER,
    p_stat_entry_id      NUMBER,
    p_cons_entity_id     NUMBER,
    p_hierarchy_id       NUMBER,
    p_relationship_id    NUMBER,
    p_cal_period_id      NUMBER,
    p_period_end_date    DATE,
    p_currency_code      VARCHAR2,
    p_balance_type_code  VARCHAR2,
    p_dataset_code       NUMBER)
  IS
    fn_name               VARCHAR2(30) := ''INSERT_FULL_ENTRY_LINES'';

    l_bal_by_org_flag     VARCHAR2(1);
    l_default_org_id      NUMBER;
    l_intercompany_id     NUMBER;

    l_re_template         GCS_TEMPLATES_PKG.TemplateRecord;
    l_sus_template        GCS_TEMPLATES_PKG.TemplateRecord;

    CURSOR get_child_info IS
      SELECT child_entity_id,
             gcs_utility_pkg.get_org_id(child_entity_id, hierarchy_id) org_id
      FROM  gcs_cons_relationships
      WHERE hierarchy_id = p_hierarchy_id
      AND   parent_entity_id = p_cons_entity_id
      AND   actual_ownership_flag = ''Y'';

  BEGIN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || ''.'' || fn_name,
                     GCS_UTILITY_PKG.g_module_enter || fn_name ||
                     to_char(sysdate, '' DD-MON-YYYY HH:MI:SS''));
    END IF;
    --FND_FILE.PUT_LINE(FND_FILE.LOG, GCS_UTILITY_PKG.g_module_enter ||
    --                  fn_name || to_char(sysdate, '' DD-MON-YYYY HH:MI:SS''));

    -- Get information of the hierarchy
    SELECT balance_by_org_flag
    INTO   l_bal_by_org_flag
    FROM   gcs_hierarchies_b
    WHERE  hierarchy_id = p_hierarchy_id;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || ''.'' || fn_name,
                     ''l_bal_by_org_flag = '' || l_bal_by_org_flag || '' '' ||
                     to_char(sysdate, '' DD-MON-YYYY HH:MI:SS''));
    END IF;

    -- Balancing by org or by entity
    IF (l_bal_by_org_flag = ''Y'') THEN  -- Balancing by org

      -- Create entry lines
      -- bug fix 5066467: removed ordered hint
      INSERT /*+ APPEND */ INTO GCS_ENTRY_LINES
        (entry_id, line_type_code,
         company_cost_center_org_id, line_item_id, intercompany_id,
';

    curr_pos := 1;
    body_len := LENGTH(body_block);
    WHILE curr_pos <= body_len LOOP
      ad_ddl.build_statement(SUBSTR(body_block, curr_pos, g_line_size),
                             line_num);
      curr_pos := curr_pos + g_line_size;
      line_num := line_num + 1;
    END LOOP;

    line_num := GCS_DYNAMIC_UTIL_PKG.Build_Comma_List(
			'         ', GCS_UTILITY_PKG.g_nl, '', line_num);

    body_block :=
'         xtd_balance_e, ytd_balance_e,
         ptd_debit_balance_e, ptd_credit_balance_e,
         ytd_debit_balance_e, ytd_credit_balance_e,
         creation_date, created_by,
         last_update_date, last_updated_by, last_update_login)
      SELECT
        decode(currency_code, ''STAT'', p_stat_entry_id, p_entry_id), null,
        company_cost_center_org_id, line_item_id, intercompany_id,
';

    curr_pos := 1;
    body_len := LENGTH(body_block);
    WHILE curr_pos <= body_len LOOP
      ad_ddl.build_statement(SUBSTR(body_block, curr_pos, g_line_size),
                             line_num);
      curr_pos := curr_pos + g_line_size;
      line_num := line_num + 1;
    END LOOP;

    line_num := GCS_DYNAMIC_UTIL_PKG.Build_Comma_List(
			'        ', GCS_UTILITY_PKG.g_nl, '', line_num);

    body_block :=
'        sum(xtd_balance_e), sum(ytd_balance_e),
        sum(ptd_debit_balance_e), sum(ptd_credit_balance_e),
        sum(ytd_debit_balance_e), sum(ytd_credit_balance_e),
        sysdate, GCS_AGGREGATION_PKG.g_fnd_user_id,
        sysdate, GCS_AGGREGATION_PKG.g_fnd_user_id,
        GCS_AGGREGATION_PKG.g_fnd_login_id
      FROM
        GCS_HIERARCHIES_B      ghb,
        FEM_BALANCES           fb,
        GCS_CONS_RELATIONSHIPS gcr,
        GCS_TREATMENTS_B       gt
      WHERE
          ghb.hierarchy_id = p_hierarchy_id
      AND gcr.hierarchy_id = ghb.hierarchy_id
      AND gcr.parent_entity_id = p_cons_entity_id
      AND gcr.actual_ownership_flag = ''Y''
      AND p_period_end_date BETWEEN gcr.start_date
                                AND nvl(gcr.end_date, p_period_end_date)
      AND gt.treatment_id (+) = gcr.treatment_id
      AND nvl(gt.consolidation_type_code, ''FULL'') <> ''NONE''
      AND fb.dataset_code = p_dataset_code
      AND fb.ledger_id = ghb.fem_ledger_id
      AND fb.cal_period_id = p_cal_period_id
      AND fb.source_system_code = GCS_UTILITY_PKG.g_gcs_source_system_code
      AND fb.currency_code IN (p_currency_code, ''STAT'')
      AND fb.entity_id = gcr.child_entity_id
      GROUP BY
        fb.currency_code,
        fb.company_cost_center_org_id,
        fb.intercompany_id,
';

    curr_pos := 1;
    body_len := LENGTH(body_block);
    WHILE curr_pos <= body_len LOOP
      ad_ddl.build_statement(SUBSTR(body_block, curr_pos, g_line_size),
                             line_num);
      curr_pos := curr_pos + g_line_size;
      line_num := line_num + 1;
    END LOOP;

    line_num := GCS_DYNAMIC_UTIL_PKG.Build_Comma_List(
			'        fb.', GCS_UTILITY_PKG.g_nl, '', line_num);

    body_block :=
'        fb.line_item_id;

    ELSE  -- Balancing by Entity: need special handling of RE/Suspense/CTA

      -- Values used for the special processing:
      -- * default org id for the consolidation entity
      l_default_org_id := GCS_UTILITY_PKG.get_org_id(p_cons_entity_id,
                                                     p_hierarchy_id);

      -- * For determining intercompany type
      SELECT specific_intercompany_id
      INTO   l_intercompany_id
      FROM   GCS_CATEGORIES_B
      WHERE  category_code = ''AGGREGATION'';

      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                       g_api || ''.'' || fn_name,
                       ''l_intercompany_id = '' || l_intercompany_id || '' '' ||
                       to_char(sysdate, '' DD-MON-YYYY HH:MI:SS''));
      END IF;

      -- * Retained earnings account template
      GCS_TEMPLATES_PKG.get_dimension_template(p_hierarchy_id, ''RE'',
                                               p_balance_type_code,
                                               l_re_template);

      -- * Suspense account template
      GCS_TEMPLATES_PKG.get_dimension_template(p_hierarchy_id, ''SUSPENSE'',
                                               p_balance_type_code,
                                               l_sus_template);

      -- For CTA processing: find default org id of all direct child entities
      FOR rec IN get_child_info LOOP
        g_entity_org_info(rec.child_entity_id) := rec.org_id;
      END LOOP;


      -- bug fix 5066467: rewrite the code for hanlding RE/SUSPENSE/CTA
      -- Now we first select the rows from fb to gcs_entry_lines_gt table, RE/SUSPENSE will be handled in this step
      -- Then we update gcs_entry_lines_gt for CTA lines
      -- Lastly, we move everything from gcs_entry_lines_gt to gcs_entry_lines
      INSERT INTO gcs_entry_lines_gt
        (entry_id, line_item_id, company_cost_center_org_id, intercompany_id,
';

    curr_pos := 1;
    body_len := LENGTH(body_block);
    WHILE curr_pos <= body_len LOOP
      ad_ddl.build_statement(SUBSTR(body_block, curr_pos, g_line_size),
                             line_num);
      curr_pos := curr_pos + g_line_size;
      line_num := line_num + 1;
    END LOOP;

    line_num := GCS_DYNAMIC_UTIL_PKG.Build_Comma_List(
			'         ', GCS_UTILITY_PKG.g_nl, '', line_num);

    body_block :=
'         xtd_balance_e, ytd_balance_e,
         ptd_debit_balance_e, ptd_credit_balance_e,
         ytd_debit_balance_e, ytd_credit_balance_e)
      SELECT
        decode(currency_code, ''STAT'', p_stat_entry_id, p_entry_id),
        fb.line_item_id,
';

    curr_pos := 1;
    body_len := LENGTH(body_block);
    WHILE curr_pos <= body_len LOOP
      ad_ddl.build_statement(SUBSTR(body_block, curr_pos, g_line_size),
                             line_num);
      curr_pos := curr_pos + g_line_size;
      line_num := line_num + 1;
    END LOOP;

    -- company_cost_center_org_id
    curr_pos := 1;
    body_len := LENGTH(l_org_dim_str);
    WHILE curr_pos <= body_len LOOP
      ad_ddl.build_statement(SUBSTR(l_org_dim_str, curr_pos, g_line_size),
                             line_num);
      curr_pos := curr_pos + g_line_size;
      line_num := line_num + 1;
    END LOOP;

    -- intercompany_id
    curr_pos := 1;
    body_len := LENGTH(l_ic_dim_str);
    WHILE curr_pos <= body_len LOOP
      ad_ddl.build_statement(SUBSTR(l_ic_dim_str, curr_pos, g_line_size),
                             line_num);
      curr_pos := curr_pos + g_line_size;
      line_num := line_num + 1;
    END LOOP;

    -- optional active dimensions
    line_num := GCS_DYNAMIC_UTIL_PKG.Build_Comma_List(
			'        fb.', GCS_UTILITY_PKG.g_nl, '', line_num);

    body_block :=
'        sum(xtd_balance_e), sum(ytd_balance_e),
        sum(ptd_debit_balance_e), sum(ptd_credit_balance_e),
        sum(ytd_debit_balance_e), sum(ytd_credit_balance_e)
      FROM
        GCS_HIERARCHIES_B      ghb,
        FEM_BALANCES           fb,
        GCS_CONS_RELATIONSHIPS gcr,
        GCS_TREATMENTS_B       gt
      WHERE ghb.hierarchy_id = p_hierarchy_id
        AND gcr.hierarchy_id = p_hierarchy_id
        AND gcr.parent_entity_id = p_cons_entity_id
        AND gcr.actual_ownership_flag = ''Y''
        AND p_period_end_date BETWEEN gcr.start_date AND
                              NVL (gcr.end_date, p_period_end_date)
        AND gt.treatment_id(+) = gcr.treatment_id
        AND NVL(gt.consolidation_type_code, ''FULL'') <> ''NONE''
        AND fb.dataset_code = p_dataset_code
        AND fb.ledger_id = ghb.fem_ledger_id
        AND fb.cal_period_id = p_cal_period_id
        AND fb.source_system_code = gcs_utility_pkg.g_gcs_source_system_code
        AND fb.currency_code IN (p_currency_code, ''STAT'')
        AND fb.entity_id = gcr.child_entity_id
      GROUP BY
        fb.currency_code,
';

    curr_pos := 1;
    body_len := LENGTH(body_block);
    WHILE curr_pos <= body_len LOOP
      ad_ddl.build_statement(SUBSTR(body_block, curr_pos, g_line_size),
                             line_num);
      curr_pos := curr_pos + g_line_size;
      line_num := line_num + 1;
    END LOOP;

    -- company_cost_center_org_id
    curr_pos := 1;
    body_len := LENGTH(l_org_dim_str);
    WHILE curr_pos <= body_len LOOP
      ad_ddl.build_statement(SUBSTR(l_org_dim_str, curr_pos, g_line_size),
                             line_num);
      curr_pos := curr_pos + g_line_size;
      line_num := line_num + 1;
    END LOOP;

    -- intercompany_id
    curr_pos := 1;
    body_len := LENGTH(l_ic_dim_str);
    WHILE curr_pos <= body_len LOOP
      ad_ddl.build_statement(SUBSTR(l_ic_dim_str, curr_pos, g_line_size),
                             line_num);
      curr_pos := curr_pos + g_line_size;
      line_num := line_num + 1;
    END LOOP;

    -- optional active dimensions
    line_num := GCS_DYNAMIC_UTIL_PKG.Build_Comma_List(
			'        fb.', GCS_UTILITY_PKG.g_nl, '', line_num);

    body_block :=
'        fb.line_item_id;

    UPDATE gcs_entry_lines_gt gelg
       SET company_cost_center_org_id = l_default_org_id,
           intercompany_id = DECODE(intercompany_id, company_cost_center_org_id,
                                    DECODE(l_intercompany_id, NULL, l_default_org_id),
                                    intercompany_id)
     WHERE (
';

    curr_pos := 1;
    body_len := LENGTH(body_block);
    WHILE curr_pos <= body_len LOOP
      ad_ddl.build_statement(SUBSTR(body_block, curr_pos, g_line_size),
                             line_num);
      curr_pos := curr_pos + g_line_size;
      line_num := line_num + 1;
    END LOOP;

    -- optional active dimensions
    line_num := GCS_DYNAMIC_UTIL_PKG.Build_Comma_List(
			'        ', GCS_UTILITY_PKG.g_nl, '', line_num);

    body_block :=
' line_item_id, company_cost_center_org_id) IN (
                   SELECT
' || g_subqry_grp;

    curr_pos := 1;
    body_len := LENGTH(body_block);
    WHILE curr_pos <= body_len LOOP
      ad_ddl.build_statement(SUBSTR(body_block, curr_pos, g_line_size),
                             line_num);
      curr_pos := curr_pos + g_line_size;
      line_num := line_num + 1;
    END LOOP;

    body_block :=
'                           line_item_id,
                            retrieve_org_id (cr2.child_entity_id)
                       FROM gcs_cons_relationships cr2,
                            gcs_curr_treatments_b gctb
                      WHERE cr2.parent_entity_id = p_cons_entity_id
                        AND cr2.hierarchy_id = p_hierarchy_id
                        AND cr2.actual_ownership_flag = ''Y''
                        AND p_period_end_date BETWEEN cr2.start_date
                                                  AND NVL (cr2.end_date,
                                                           p_period_end_date
                                                          )
                        AND gctb.curr_treatment_id IN (
                               SELECT     gcr.curr_treatment_id
                                     FROM gcs_cons_relationships gcr
                               START WITH gcr.hierarchy_id = p_hierarchy_id
                                      AND gcr.parent_entity_id =
                                                              p_cons_entity_id
                                      AND gcr.actual_ownership_flag = ''Y''
                                      AND p_period_end_date
                                             BETWEEN gcr.start_date
                                                 AND NVL (gcr.end_date,
                                                          p_period_end_date
                                                         )
                               CONNECT BY PRIOR gcr.child_entity_id =
                                                          gcr.parent_entity_id
                                      AND gcr.hierarchy_id = p_hierarchy_id
                                      AND gcr.actual_ownership_flag = ''Y''
                                      AND p_period_end_date
                                             BETWEEN gcr.start_date
                                                 AND NVL (gcr.end_date,
                                                          p_period_end_date
                                                         ))
                   GROUP BY
' || g_subqry_grp ||'  line_item_id, cr2.child_entity_id);

         INSERT /*+ append */INTO gcs_entry_lines
                     (entry_id, company_cost_center_org_id, line_item_id,
                      intercompany_id,
 ';

    curr_pos := 1;
    body_len := LENGTH(body_block);
    WHILE curr_pos <= body_len LOOP
      ad_ddl.build_statement(SUBSTR(body_block, curr_pos, g_line_size),
                             line_num);
      curr_pos := curr_pos + g_line_size;
      line_num := line_num + 1;
    END LOOP;

    -- optional active dimensions
    line_num := GCS_DYNAMIC_UTIL_PKG.Build_Comma_List(
			'        ', GCS_UTILITY_PKG.g_nl, '', line_num);

    body_block :=
' xtd_balance_e, ytd_balance_e,
                      ptd_debit_balance_e, ptd_credit_balance_e,
                      ytd_debit_balance_e, ytd_credit_balance_e,
                      creation_date, created_by, last_update_date,
                      last_updated_by, last_update_login)
            SELECT   entry_id, company_cost_center_org_id, line_item_id,
                     intercompany_id,
 ';

    curr_pos := 1;
    body_len := LENGTH(body_block);
    WHILE curr_pos <= body_len LOOP
      ad_ddl.build_statement(SUBSTR(body_block, curr_pos, g_line_size),
                             line_num);
      curr_pos := curr_pos + g_line_size;
      line_num := line_num + 1;
    END LOOP;

    -- optional active dimensions
    line_num := GCS_DYNAMIC_UTIL_PKG.Build_Comma_List(
			'        ', GCS_UTILITY_PKG.g_nl, '', line_num);

    body_block :=
'
                     SUM (xtd_balance_e), SUM (ytd_balance_e),
                     SUM (ptd_debit_balance_e), SUM (ptd_credit_balance_e),
                     SUM (ytd_debit_balance_e), SUM (ytd_credit_balance_e),
                     SYSDATE, gcs_aggregation_pkg.g_fnd_user_id, SYSDATE,
                     gcs_aggregation_pkg.g_fnd_user_id,
                     gcs_aggregation_pkg.g_fnd_login_id
                FROM gcs_entry_lines_gt
            GROUP BY entry_id,
 ';

    curr_pos := 1;
    body_len := LENGTH(body_block);
    WHILE curr_pos <= body_len LOOP
      ad_ddl.build_statement(SUBSTR(body_block, curr_pos, g_line_size),
                             line_num);
      curr_pos := curr_pos + g_line_size;
      line_num := line_num + 1;
    END LOOP;

    -- optional active dimensions
    line_num := GCS_DYNAMIC_UTIL_PKG.Build_Comma_List(
			'        ', GCS_UTILITY_PKG.g_nl, '', line_num);

    body_block :=
'                     company_cost_center_org_id,
                     line_item_id,
                     intercompany_id;
    END IF; -- l_bal_by_org_flag

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || ''.'' || fn_name,
                     ''Inserted '' || to_char(SQL%ROWCOUNT) || '' row(s)'');
    END IF;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || ''.'' || fn_name,
                     GCS_UTILITY_PKG.g_module_success || fn_name ||
                     to_char(sysdate, '' DD-MON-YYYY HH:MI:SS''));
    END IF;
    --FND_FILE.PUT_LINE(FND_FILE.LOG, GCS_UTILITY_PKG.g_module_success ||
    --                  fn_name || to_char(sysdate, '' DD-MON-YYYY HH:MI:SS''));

  EXCEPTION
    WHEN OTHERS THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                       g_api || ''.'' || fn_name,
                       GCS_UTILITY_PKG.g_module_failure || fn_name ||
                       to_char(sysdate, '' DD-MON-YYYY HH:MI:SS''));
      END IF;
      --FND_FILE.PUT_LINE(FND_FILE.LOG, GCS_UTILITY_PKG.g_module_failure ||
      --                  fn_name || to_char(sysdate, '' DD-MON-YYYY HH:MI:SS''));
      RAISE;
  END insert_full_entry_lines;

END GCS_AGGREGATION_DYNAMIC_PKG;';

    curr_pos := 1;
    body_len := LENGTH(body_block);
    WHILE curr_pos <= body_len LOOP
      ad_ddl.build_statement(SUBSTR(body_block, curr_pos, g_line_size),
                             line_num);
      curr_pos := curr_pos + g_line_size;
      line_num := line_num + 1;
    END LOOP;

    ad_ddl.create_plsql_object(GCS_DYNAMIC_UTIL_PKG.g_applsys_username,
			       'GCS', 'GCS_AGGREGATION_DYNAMIC_PKG',
			       1, line_num - 1, 'FALSE', comp_err);

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.' || fn_name,
                     GCS_UTILITY_PKG.g_module_success || fn_name ||
                     to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));
    END IF;
    --FND_FILE.PUT_LINE(FND_FILE.LOG, GCS_UTILITY_PKG.g_module_success ||
    --                  fn_name || to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));

  EXCEPTION
    WHEN OTHERS THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                       g_api || '.' || fn_name,
                       SUBSTR(SQLERRM, 1, 4000));
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                       g_api || '.' || fn_name,
                       GCS_UTILITY_PKG.g_module_failure || fn_name ||
                       to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));
      END IF;
      --FND_FILE.PUT_LINE(FND_FILE.LOG, GCS_UTILITY_PKG.g_module_failure ||
      --                  fn_name || to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));
  END create_package;

END GCS_AGGREGATION_DYN_BUILD_PKG;

/
