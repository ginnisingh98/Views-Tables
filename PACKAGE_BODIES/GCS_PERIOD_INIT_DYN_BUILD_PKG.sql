--------------------------------------------------------
--  DDL for Package Body GCS_PERIOD_INIT_DYN_BUILD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_PERIOD_INIT_DYN_BUILD_PKG" AS
/* $Header: gcspinbb.pls 120.5 2006/09/08 00:30:34 skamdar noship $ */

  --
  -- PRIVATE GLOBAL VARIABLES
  --
  g_api         CONSTANT VARCHAR2(40) := 'gcs.plsql.GCS_PERIOD_INIT_DYN_BUILD_PKG';
  g_line_size	NUMBER       := 250;

  g_sel_stmt    VARCHAR2(8000);

  --
  -- PRIVATE FUNCTIONS
  --

  --
  -- Procedure
  --   build_dim_str
  --
  PROCEDURE build_dim_str(p_dim_col  VARCHAR2) IS
    fn_name      VARCHAR2(30);
    dim_required VARCHAR2(1);
    dim_str      VARCHAR2(400);
  BEGIN
    fn_name := 'BUILD_DIM_STR';
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.' || fn_name,
                     GCS_UTILITY_PKG.g_module_enter || fn_name ||
                     to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));
    END IF;
    --FND_FILE.PUT_LINE(FND_FILE.LOG, GCS_UTILITY_PKG.g_module_enter ||
    --                  fn_name || to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));

    -- **************************************************

    dim_required := GCS_UTILITY_PKG.get_dimension_required(UPPER(p_dim_col));

    IF (dim_required = 'Y') THEN
      dim_str := ',
        decode(p_sec_track_col,
               ''' || UPPER(p_dim_col) || ''', l2.' || p_dim_col || ',
               decode(feata.dim_attribute_varchar_member,
                      ''REVENUE'', p_re_template.' || p_dim_col || ',
                      ''EXPENSE'', p_re_template.' || p_dim_col || ',
                      l2.' || p_dim_col || '))';

      g_sel_stmt := g_sel_stmt || dim_str;
    END IF;

    -- **************************************************

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.' || fn_name,
                     GCS_UTILITY_PKG.g_module_success || fn_name ||
                     to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));
    END IF;
    --FND_FILE.PUT_LINE(FND_FILE.LOG, GCS_UTILITY_PKG.g_module_success ||
    --                 fn_name || to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));

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
  END build_dim_str;

  --
  -- Procedure
  --   build_re_stmt
  -- Notes
  --   The final g_sel_stmt does NOT have a trailing ',' after the last
  --   dimension. The string will be used in both select and group by, and
  --   each usage will end the string properly (either ',' or ';').
  PROCEDURE build_re_stmt IS
    fn_name      VARCHAR2(30);
  BEGIN
    fn_name := 'BUILD_RE_STMT';
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.' || fn_name,
                     GCS_UTILITY_PKG.g_module_enter || fn_name ||
                     to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));
    END IF;
    --FND_FILE.PUT_LINE(FND_FILE.LOG, GCS_UTILITY_PKG.g_module_enter ||
    --                  fn_name || to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));

    -- **************************************************

    -- Company_Cost_Center_Org_Id, Intercompany_Id, and Line_Item_Id
    g_sel_stmt :=
'        decode(p_bal_by_org,
               ''Y'', l2.company_cost_center_org_id,
               decode(feata.dim_attribute_varchar_member,
                      ''REVENUE'', l_default_org_id,
                      ''EXPENSE'', l_default_org_id,
                      l2.company_cost_center_org_id)),
        -- RE: use org id only if there is no specified intercompany id
        decode(feata.dim_attribute_varchar_member,
               ''REVENUE'', nvl(l_intercompany_id,
                              decode(p_bal_by_org,
                                     ''Y'', l2.company_cost_center_org_id,
                                     l_default_org_id)),
               ''EXPENSE'', nvl(l_intercompany_id,
                              decode(p_bal_by_org,
                                     ''Y'', l2.company_cost_center_org_id,
                                     l_default_org_id)),
               l2.intercompany_id),
        -- line item (cannot be secondary tracking column)
        decode(feata.dim_attribute_varchar_member,
               ''REVENUE'', p_re_template.line_item_id,
               ''EXPENSE'', p_re_template.line_item_id,
               l2.line_item_id)';

    -- below must be in the same order as GCS_DYNAMIC_UTIL_PKG.Build_Comma_List
    build_dim_str('financial_elem_id');
    build_dim_str('product_id');
    build_dim_str('natural_account_id');
    build_dim_str('channel_id');
    build_dim_str('project_id');
    build_dim_str('customer_id');
    build_dim_str('task_id');
    build_dim_str('user_dim1_id');
    build_dim_str('user_dim2_id');
    build_dim_str('user_dim3_id');
    build_dim_str('user_dim4_id');
    build_dim_str('user_dim5_id');
    build_dim_str('user_dim6_id');
    build_dim_str('user_dim7_id');
    build_dim_str('user_dim8_id');
    build_dim_str('user_dim9_id');
    build_dim_str('user_dim10_id');

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
  END build_re_stmt;


  --
  -- PUBLIC FUNCTIONS
  --

  PROCEDURE create_package IS
    fn_name               VARCHAR2(30);

    -- control each line to < 80 chars and put in <= 50 lines each time
    body_block  VARCHAR2(20000);
    body_len    NUMBER;

    curr_pos    NUMBER;
    line_num    NUMBER := 1;

    comp_err    VARCHAR2(10);
  BEGIN
    fn_name := 'CREATE_PACKAGE';
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.' || fn_name,
                     GCS_UTILITY_PKG.g_module_enter || fn_name ||
                     to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));
    END IF;
    --FND_FILE.PUT_LINE(FND_FILE.LOG, GCS_UTILITY_PKG.g_module_enter ||
    --                  fn_name || to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));

    -- initialization
    GCS_UTILITY_PKG.init_dimension_info;
    build_re_stmt;

    body_block :=
'CREATE OR REPLACE PACKAGE BODY GCS_PERIOD_INIT_DYNAMIC_PKG AS
/* $Header: gcspinbb.pls 120.5 2006/09/08 00:30:34 skamdar noship $ */

  --
  -- PRIVATE GLOBAL VARIABLES
  --
  g_api    VARCHAR2(40) := ''gcs.plsql.GCS_PERIOD_INIT_DYNAMIC_PKG'';
  g_li_eat_attr_id    NUMBER := GCS_UTILITY_PKG.g_dimension_attr_info
                           (''LINE_ITEM_ID-EXTENDED_ACCOUNT_TYPE'').attribute_id;
  g_li_eat_ver_id    NUMBER := GCS_UTILITY_PKG.g_dimension_attr_info
                           (''LINE_ITEM_ID-EXTENDED_ACCOUNT_TYPE'').version_id;
  g_acct_type_attr_id NUMBER := GCS_UTILITY_PKG.g_dimension_attr_info
                           (''EXT_ACCOUNT_TYPE_CODE-BASIC_ACCOUNT_TYPE_CODE'').attribute_id;
  g_acct_type_ver_id  NUMBER := GCS_UTILITY_PKG.g_dimension_attr_info
                           (''EXT_ACCOUNT_TYPE_CODE-BASIC_ACCOUNT_TYPE_CODE'').version_id;


  --
  -- PUBLIC FUNCTIONS
  --

  PROCEDURE insert_entry_lines(
    p_run_name             VARCHAR2,
    p_hierarchy_id         NUMBER,
    p_entity_id            NUMBER,
    p_currency_code        VARCHAR2,
    p_bal_by_org           VARCHAR2,
    p_sec_track_col        VARCHAR2,
    p_is_elim_entity       VARCHAR2,
    p_cons_entity_id       NUMBER,
    p_re_template          GCS_TEMPLATES_PKG.TemplateRecord,
    p_cross_year_flag      VARCHAR2,
    p_category_code        VARCHAR2,
    p_init_entry_id        NUMBER,
    p_init_xlate_entry_id  NUMBER,
    p_init_stat_entry_id   NUMBER,
    p_recur_entry_id       NUMBER,
    p_recur_xlate_entry_id NUMBER,
    p_recur_stat_entry_id  NUMBER,
    --Bugfix 5449718: Added the calendar period year and net to re flag as parameters
    p_cal_period_year      NUMBER,
    p_net_to_re_flag       VARCHAR2)
  IS
    fn_name                VARCHAR2(30) := ''INSERT_ENTRY_LINES'';
    l_default_org_id       NUMBER;
    l_intercompany_id      NUMBER;

    --Bugfix 5449718: Add two lists to store recurring entries. List 1 will store recurring entries where the RE has not yet rolled forward.
    --List 2 will store entries where RE needs to be rolled forward
    TYPE r_entry_list IS RECORD (entry_id            NUMBER(15),
                                 year_to_apply_RE    NUMBER(15),
                                 currency_code       VARCHAR2(30),
                                 period_init_entry   VARCHAR2(1),
                                 diff_in_cal_periods NUMBER );
    TYPE t_entry_list IS TABLE OF r_entry_list;

    l_entry_id_list        t_entry_list;
    l_recur_entry_id_list  t_entry_list := t_entry_list();
    l_num_recur_entry_id   NUMBER(15)  := 0;
    l_entry_list           DBMS_SQL.NUMBER_TABLE;
    l_currency_code_list   DBMS_SQL.VARCHAR2_TABLE;


  BEGIN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || ''.'' || fn_name,
                     GCS_UTILITY_PKG.g_module_enter || fn_name ||
                     to_char(sysdate, '' DD-MON-YYYY HH:MI:SS''));
    END IF;

    --Bugfix 5449718: Adding information on key parameters
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || ''.''|| fn_name, ''<<<<<Begin List of Parameters>>>>>>'');
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || ''.''|| fn_name, ''Run Name            : '' || p_run_name);
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || ''.''|| fn_name, ''Consolidation Entity: '' || p_cons_entity_id);
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || ''.''|| fn_name, ''Category Code       : '' || p_category_code);
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || ''.''|| fn_name, ''Cross Year Flag     : '' || p_cross_year_flag);
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || ''.''|| fn_name, ''Net to RE Flag      : '' || p_net_to_re_flag);
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, g_api || ''.''|| fn_name, ''<<<<<End List of Parameters>>>>>>'');
    END IF;

    IF ( p_is_elim_entity = ''Y'' ) THEN

      --Bugfix 5449718: Retrieving additional information  year_to_apply_re, currency_code
      --If cross year flag = N then do not select any entries where year to apply RE >= current year

      IF ( p_cross_year_flag = ''N'') THEN
        SELECT NVL(gcerd.entry_id, gcerd.stat_entry_id),
               geh.year_to_apply_re,
               geh.currency_code,
               ''N'',
               0
          BULK COLLECT INTO
               l_entry_id_list
          FROM gcs_cons_eng_run_dtls gcerd,
               gcs_entry_headers geh
         WHERE gcerd.run_name                   = p_run_name
           AND gcerd.consolidation_entity_id    = p_cons_entity_id
           AND gcerd.child_entity_id           IS NOT NULL
           AND gcerd.category_code              = p_category_code
           AND gcerd.entry_id                   = geh.entry_id
           AND geh.period_init_entry_flag       = ''N''
           AND p_cal_period_year                < NVL(geh.year_to_apply_re, p_cal_period_year+1);
      ELSIF (p_net_to_re_flag = ''N'') THEN
        SELECT NVL(gcerd.entry_id, gcerd.stat_entry_id),
               geh.year_to_apply_re,
               geh.currency_code,
               ''N'',
               0
          BULK COLLECT INTO
               l_entry_id_list
          FROM gcs_cons_eng_run_dtls gcerd,
               gcs_entry_headers geh
         WHERE gcerd.run_name                   = p_run_name
           AND gcerd.consolidation_entity_id    = p_cons_entity_id
           AND gcerd.child_entity_id           IS NOT NULL
           AND gcerd.category_code              = p_category_code
           AND gcerd.entry_id                   = geh.entry_id
           AND geh.period_init_entry_flag       = ''N'';
      ELSE
        SELECT NVL(gcerd.entry_id, gcerd.stat_entry_id),
               geh.year_to_apply_re,
               geh.currency_code,
               geh.period_init_entry_flag,
               NVL(geh.end_cal_period_id, geh.start_cal_period_id) - geh.start_cal_period_id
          BULK COLLECT INTO
               l_entry_id_list
          FROM gcs_cons_eng_run_dtls gcerd,
               gcs_entry_headers geh
         WHERE gcerd.run_name                   = p_run_name
           AND gcerd.consolidation_entity_id    = p_cons_entity_id
           AND gcerd.child_entity_id           IS NOT NULL
           AND gcerd.category_code              = p_category_code
           AND gcerd.entry_id                   = geh.entry_id;
      END IF;

    ELSE

      IF ( p_cross_year_flag = ''N'') THEN
        SELECT NVL(gcerd.entry_id, gcerd.stat_entry_id),
               geh.year_to_apply_re,
               geh.currency_code,
               ''N'',
               0
          BULK COLLECT INTO
               l_entry_id_list
          FROM gcs_cons_eng_run_dtls gcerd,
               gcs_entry_headers geh
         WHERE gcerd.run_name                   = p_run_name
           AND gcerd.consolidation_entity_id    = p_cons_entity_id
           AND gcerd.child_entity_id            = p_entity_id
           AND gcerd.category_code              = p_category_code
           AND gcerd.entry_id                   = geh.entry_id
           AND geh.period_init_entry_flag       = ''N''
           AND p_cal_period_year                < NVL(geh.year_to_apply_re, p_cal_period_year+1);
      ELSIF (p_net_to_re_flag = ''N'') THEN
        SELECT NVL(gcerd.entry_id, gcerd.stat_entry_id),
               geh.year_to_apply_re,
               geh.currency_code,
               ''N'',
               0
          BULK COLLECT INTO
               l_entry_id_list
          FROM gcs_cons_eng_run_dtls gcerd,
               gcs_entry_headers geh
         WHERE gcerd.run_name                   = p_run_name
           AND gcerd.consolidation_entity_id    = p_cons_entity_id
           AND gcerd.child_entity_id            = p_entity_id
           AND gcerd.category_code              = p_category_code
           AND gcerd.entry_id                   = geh.entry_id
           AND geh.period_init_entry_flag       = ''N'';
      ELSE
        SELECT NVL(gcerd.entry_id, gcerd.stat_entry_id),
               geh.year_to_apply_re,
               geh.currency_code,
               geh.period_init_entry_flag,
               NVL(geh.end_cal_period_id, geh.start_cal_period_id) - geh.start_cal_period_id
          BULK COLLECT INTO
               l_entry_id_list
          FROM gcs_cons_eng_run_dtls gcerd,
               gcs_entry_headers geh
         WHERE gcerd.run_name                   = p_run_name
           AND gcerd.consolidation_entity_id    = p_cons_entity_id
           AND gcerd.child_entity_id            = p_entity_id
           AND gcerd.category_code              = p_category_code
           AND gcerd.entry_id                   = geh.entry_id;
      END IF;

    END IF;

    --Bugfix 5449718: Do not need to copy entries to a single variable anymore.
    /* FOR i IN l_stat_entry_id_list.FIRST.. l_stat_entry_id_list.LAST LOOP
        l_entry_id_list(l_entry_id_list.LAST + i) := l_stat_entry_id_list(i);
       END LOOP;
    */
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || ''.''|| fn_name, ''Number of entries to process: '' || l_entry_id_list.COUNT);
    END IF;

    --Bufix 5449718: Go to the end of the procedure as a safe net if there are no entries to process
    IF (l_entry_id_list.COUNT = 0) THEN
      GOTO  norowstoprocess;
    END IF;

    --Bugfix 5449718: Must reclassify entries that are crossing the year end boundary to make sure the appropriate lines are applied
    IF (p_net_to_re_flag = ''Y'') THEN
      FOR i IN l_entry_id_list.FIRST..l_entry_id_list.LAST LOOP
        IF (l_entry_id_list(i).period_init_entry = ''Y'' AND
            l_entry_id_list(i).diff_in_cal_periods = 0) THEN
          l_entry_id_list.DELETE(i);
        ELSIF (l_entry_id_list(i).year_to_apply_re IS NOT NULL) THEN
          l_num_recur_entry_id := l_num_recur_entry_id + 1;
          l_recur_entry_id_list.EXTEND(1);
          l_recur_entry_id_list(l_num_recur_entry_id) := l_entry_id_list(i);
          l_entry_id_list.DELETE(i);
        END IF;
      END LOOP;
    END IF;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || ''.'' || fn_name, ''Number of single year entries: '' || l_entry_id_list.COUNT);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || ''.'' || fn_name, ''Recurring Entries Where Year to Apply RE is not null: '' || l_recur_entry_id_list.COUNT);
    END IF;

    IF (p_cross_year_flag = ''N'') THEN

      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || ''.'' || fn_name, ''Processing Within Year'');
      END IF;

      IF (l_entry_id_list.COUNT > 0) THEN
        --Cannot reference tables of records in BULK statements so initializing individual tables
        l_entry_list.DELETE;
        l_currency_code_list.DELETE;

        FOR i IN l_entry_id_list.FIRST..l_entry_id_list.LAST LOOP
          l_entry_list(i) := l_entry_id_list(i).entry_id;
          l_currency_code_list(i) := l_entry_id_list(i).currency_code;
        END LOOP;

        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || ''.'' || fn_name, ''Beginning Collection of Single Year Entries'');
        END IF;

        --Bugfix 5449718: Need to insert into GCS_ENTRY_LINES_GT to avoid unique constraint errors
        FORALL i IN l_entry_id_list.FIRST.. l_entry_id_list.LAST
        INSERT INTO GCS_ENTRY_LINES_GT
       (entry_id,
        description,
        company_cost_center_org_id,
        intercompany_id,
        line_item_id,
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
'       xtd_balance_e,
        ytd_balance_e,
        ptd_debit_balance_e,
        ptd_credit_balance_e,
        ytd_debit_balance_e,
        ytd_credit_balance_e)
      SELECT
        --Bugfix 5449718: Remove the references to the init_xlate_entry_id, and removed all group by calcs as this is happening on a line by line basis.
        --Also remove join to gcs_entry_headers as all of the information is available in the PL/SQL collection
        decode(l_currency_code_list(i), ''STAT'', p_init_stat_entry_id,
                                 p_init_entry_id),
        decode(feata.dim_attribute_varchar_member,
               ''REVENUE'', ''PROFIT_LOSS'',
               ''EXPENSE'', ''PROFIT_LOSS'',
               ''BALANCE_SHEET''),
        l2.company_cost_center_org_id,
        l2.intercompany_id,
        l2.line_item_id,
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
			'        l2.', GCS_UTILITY_PKG.g_nl, '', line_num);

    body_block :=
'        decode(feata.dim_attribute_varchar_member,
               ''REVENUE'', NVL(ytd_credit_balance_e,0) - NVL(ytd_debit_balance_e,0),
               ''EXPENSE'', NVL(ytd_credit_balance_e,0) - NVL(ytd_debit_balance_e,0),
               0),
        0,
        -1*(ytd_debit_balance_e),
        -1*(ytd_credit_balance_e),
        0,
        0
      FROM
        GCS_ENTRY_LINES l2,
        FEM_LN_ITEMS_ATTR lia,
        FEM_EXT_ACCT_TYPES_ATTR feata
      WHERE l2.entry_id = l_entry_list(i)
      AND lia.attribute_id = g_li_eat_attr_id
      AND lia.version_id = g_li_eat_ver_id
      AND lia.line_item_id = l2.line_item_id
      AND feata.attribute_id = g_acct_type_attr_id
      AND feata.version_id   = g_acct_type_ver_id
      AND feata.ext_account_type_code = lia.dim_attribute_varchar_member;

      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || ''.'' || fn_name, ''Completed Collection of Single Year Entries'');
      END IF;

    END IF;

      --Bugfix 5449718: Need to insert into GCS_ENTRY_LINES_GT to avoid unique constraint errors. Handle entries where only balance sheet lines must be applied
     IF (l_recur_entry_id_list.COUNT > 0) THEN
       --Cannot reference tables of records in BULK statements so initializing individual tables

       l_entry_list.DELETE;
       l_currency_code_list.DELETE;

       FOR i IN l_recur_entry_id_list.FIRST..l_recur_entry_id_list.LAST LOOP
         l_entry_list(i) := l_recur_entry_id_list(i).entry_id;
         l_currency_code_list(i) := l_recur_entry_id_list(i).currency_code;
       END LOOP;

       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || ''.'' || fn_name, ''Beginning Collection of Recurring Entries'');
       END IF;

       FORALL i IN l_recur_entry_id_list.FIRST.. l_recur_entry_id_list.LAST
       INSERT INTO GCS_ENTRY_LINES_GT l1
       (entry_id,
        description,
        company_cost_center_org_id,
        intercompany_id,
        line_item_id,
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
'       xtd_balance_e,
        ytd_balance_e,
        ptd_debit_balance_e,
        ptd_credit_balance_e,
        ytd_debit_balance_e,
        ytd_credit_balance_e)
      SELECT
        --Bugfix 5449718: Remove the references to the init_xlate_entry_id, and removed all group by calcs as this is happening on a line by line basis.
        --Also remove join to gcs_entry_headers as all of the information is available in the PL/SQL collection
        --Join to line type is no longer required as all rows for recurring entries have the line type code populated
        decode(l_currency_code_list(i), ''STAT'', p_init_stat_entry_id,
                                 p_init_entry_id),
        l2.line_type_code,
        l2.company_cost_center_org_id,
        l2.intercompany_id,
        l2.line_item_id,
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
			'        l2.', GCS_UTILITY_PKG.g_nl, '', line_num);

    body_block :=
'        --XTD Balance should be determined by the line type code
        DECODE(l2.line_type_code, ''PROFIT_LOSS'', NVL(ytd_credit_balance_e, 0) - NVL(ytd_debit_balance_e, 0),
               0),
        0,
        -1*(ytd_debit_balance_e),
        -1*(ytd_credit_balance_e),
        0,
        0
      FROM
        GCS_ENTRY_LINES l2
      WHERE l2.entry_id = l_entry_list(i)
      AND l2.line_type_code IN (''PROFIT_LOSS'', ''BALANCE_SHEET'');

      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || ''.'' || fn_name, ''Completed Collection of Recurring Entries'');
      END IF;

     END IF;

    --Bugfix 5449718: Needed to add a condition if the Net to RE Flag is N versus Y when crossing the year-end boundary for performance purposes
    ELSIF (p_net_to_re_flag = ''N'') THEN

      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || ''.'' || fn_name, ''Processing for Next Year with Net to RE set to N'');
      END IF;

      -- find default org id for RE, in case bal_by_org is ''N''
      l_default_org_id := GCS_UTILITY_PKG.get_org_id(p_entity_id,
                                                     p_hierarchy_id);

      -- find default intercompany id for RE if specified
      SELECT specific_intercompany_id
      INTO   l_intercompany_id
      FROM   GCS_CATEGORIES_B
      WHERE  category_code = ''INTRACOMPANY'';

      IF (l_entry_id_list.COUNT > 0) THEN
        --Cannot reference tables of records in BULK statements so initializing individual tables
        l_entry_list.DELETE;
        l_currency_code_list.DELETE;

        FOR i IN l_entry_id_list.FIRST..l_entry_id_list.LAST LOOP
          l_entry_list(i) := l_entry_id_list(i).entry_id;
          l_currency_code_list(i) := l_entry_id_list(i).currency_code;
        END LOOP;

        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || ''.'' || fn_name, ''Beginning Collection of Single Year Entries'');
        END IF;

        FORALL i IN l_entry_id_list.FIRST.. l_entry_id_list.LAST
        INSERT INTO GCS_ENTRY_LINES_GT l1
        (entry_id,
        description,
        company_cost_center_org_id,
        intercompany_id,
        line_item_id,
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
'       xtd_balance_e,
        ytd_balance_e,
        ptd_debit_balance_e,
        ptd_credit_balance_e,
        ytd_debit_balance_e,
        ytd_credit_balance_e)
      SELECT
        --Bugfix 5449718: No longer need the target entries
        decode(l_currency_code_list(i), ''STAT'', p_init_stat_entry_id,
                                 p_init_entry_id),
        ''BALANCE_SHEET'',
';

    curr_pos := 1;
    body_len := LENGTH(body_block);
    WHILE curr_pos <= body_len LOOP
      ad_ddl.build_statement(SUBSTR(body_block, curr_pos, g_line_size),
                             line_num);
      curr_pos := curr_pos + g_line_size;
      line_num := line_num + 1;
    END LOOP;

    -- g_sel_stmt
    curr_pos := 1;
    body_len := LENGTH(g_sel_stmt);
    WHILE curr_pos <= body_len LOOP
      ad_ddl.build_statement(SUBSTR(g_sel_stmt, curr_pos, g_line_size),
                             line_num);
      curr_pos := curr_pos + g_line_size;
      line_num := line_num + 1;
    END LOOP;

    body_block := ',
        --Bugfix 5449718: If net to re flag is N then all balances except ptd debit and ptd credit will be zero
        0,
        0,
        -1*(l2.ytd_debit_balance_e),
        -1*(l2.ytd_credit_balance_e),
        0,
        0
      FROM
        --Bugfix 5449718: Remove source, target entry, and category joins.
        GCS_ENTRY_LINES l2,
        FEM_LN_ITEMS_ATTR lia,
        FEM_EXT_ACCT_TYPES_ATTR feata
      WHERE
          l2.entry_id = l_entry_list(i)
      AND lia.attribute_id = g_li_eat_attr_id
      AND lia.version_id = g_li_eat_ver_id
      AND lia.line_item_id = l2.line_item_id
      AND feata.attribute_id = g_acct_type_attr_id
      AND feata.version_id   = g_acct_type_ver_id
      AND feata.ext_account_type_code = lia.dim_attribute_varchar_member;
      -- Bugfix 5449718: Group by is no longer necessary

      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || ''.'' || fn_name, ''Completed Collection of Single Year Entries'');
      END IF;

      END IF;
';

    curr_pos := 1;
    body_len := LENGTH(body_block);
    WHILE curr_pos <= body_len LOOP
      ad_ddl.build_statement(SUBSTR(body_block, curr_pos, g_line_size),
                             line_num);
      curr_pos := curr_pos + g_line_size;
      line_num := line_num + 1;
    END LOOP;

    body_block :=
'
    --Bugfix 5449718: Needed to add a condition if the Net to RE Flag is N versus Y when crossing the year-end boundary for performance purposes
    ELSIF (p_net_to_re_flag = ''Y'') THEN

      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || ''.'' || fn_name, ''Processing for Next Year with Net to RE set to Y'');
      END IF;

      -- find default org id for RE, in case bal_by_org is ''N''
      l_default_org_id := GCS_UTILITY_PKG.get_org_id(p_entity_id,
                                                     p_hierarchy_id);

      -- find default intercompany id for RE if specified
      SELECT specific_intercompany_id
      INTO   l_intercompany_id
      FROM   GCS_CATEGORIES_B
      WHERE  category_code = ''INTRACOMPANY'';

      l_entry_list.DELETE;
      l_currency_code_list.DELETE;

      IF (l_entry_id_list.COUNT > 0) THEN
        --Cannot reference tables of records in BULK statements so initializing individual tables
        FOR i IN l_entry_id_list.FIRST..l_entry_id_list.LAST LOOP
          l_entry_list(i) := l_entry_id_list(i).entry_id;
          l_currency_code_list(i) := l_entry_id_list(i).currency_code;
        END LOOP;

        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || ''.'' || fn_name, ''Beginning Collection of Single Year Entries'');
        END IF;

        FORALL i IN l_entry_id_list.FIRST.. l_entry_id_list.LAST
        INSERT INTO GCS_ENTRY_LINES_GT l1
        (entry_id,
        description,
        company_cost_center_org_id,
        intercompany_id,
        line_item_id,
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
'       xtd_balance_e,
        ytd_balance_e,
        ptd_debit_balance_e,
        ptd_credit_balance_e,
        ytd_debit_balance_e,
        ytd_credit_balance_e)
      SELECT
        --Bugfix 5449718: No longer need the target entries
        decode(l_currency_code_list(i), ''STAT'', p_recur_stat_entry_id,
                                 p_recur_entry_id),
        ''BALANCE_SHEET'',
';

    curr_pos := 1;
    body_len := LENGTH(body_block);
    WHILE curr_pos <= body_len LOOP
      ad_ddl.build_statement(SUBSTR(body_block, curr_pos, g_line_size),
                             line_num);
      curr_pos := curr_pos + g_line_size;
      line_num := line_num + 1;
    END LOOP;

    -- g_sel_stmt
    curr_pos := 1;
    body_len := LENGTH(g_sel_stmt);
    WHILE curr_pos <= body_len LOOP
      ad_ddl.build_statement(SUBSTR(g_sel_stmt, curr_pos, g_line_size),
                             line_num);
      curr_pos := curr_pos + g_line_size;
      line_num := line_num + 1;
    END LOOP;

    body_block := ',
        --Bugfix 5449718: If net to re flag is Y then all balances except ptd debit and ptd credit will be zero
        ytd_balance_e,
        ytd_balance_e,
        0,
        0,
        ytd_debit_balance_e,
        ytd_credit_balance_e
      FROM
        --Bugfix 5449718: Remove source, target entry, and category joins. Add join to fem_ext_acct_types_attr
        GCS_ENTRY_LINES l2,
        FEM_LN_ITEMS_ATTR lia,
        FEM_EXT_ACCT_TYPES_ATTR feata
      WHERE
          l2.entry_id = l_entry_list(i)
      AND lia.attribute_id = g_li_eat_attr_id
      AND lia.version_id = g_li_eat_ver_id
      AND lia.line_item_id = l2.line_item_id
      AND feata.attribute_id = g_acct_type_attr_id
      AND feata.version_id   = g_acct_type_ver_id
      AND feata.ext_account_type_code = lia.dim_attribute_varchar_member;
      -- Bugfix 5449718: Group by is no longer necessary

      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || ''.'' || fn_name, ''Completed Collection of Single Year'');
      END IF;

';

    curr_pos := 1;
    body_len := LENGTH(body_block);
    WHILE curr_pos <= body_len LOOP
      ad_ddl.build_statement(SUBSTR(body_block, curr_pos, g_line_size),
                             line_num);
      curr_pos := curr_pos + g_line_size;
      line_num := line_num + 1;
    END LOOP;

    body_block :=
'
      END IF;


      l_entry_list.DELETE;
      l_currency_code_list.DELETE;

      IF (l_recur_entry_id_list.COUNT > 0) THEN
        --Cannot reference tables of records in BULK statements so initializing individual tables
        FOR i IN l_recur_entry_id_list.FIRST..l_recur_entry_id_list.LAST LOOP
          l_entry_list(i) := l_recur_entry_id_list(i).entry_id;
          l_currency_code_list(i) := l_recur_entry_id_list(i).currency_code;
        END LOOP;

        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || ''.'' || fn_name, ''Beginning Collection of Recurring Entries'');
        END IF;

        FORALL i IN l_recur_entry_id_list.FIRST.. l_recur_entry_id_list.LAST
        INSERT INTO GCS_ENTRY_LINES_GT l1
        (entry_id,
        description,
        company_cost_center_org_id,
        intercompany_id,
        line_item_id,
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
'       xtd_balance_e,
        ytd_balance_e,
        ptd_debit_balance_e,
        ptd_credit_balance_e,
        ytd_debit_balance_e,
        ytd_credit_balance_e)
      SELECT
        --Bugfix 5449718: No longer need the target entries
        decode(l_currency_code_list(i), ''STAT'', p_recur_stat_entry_id,
                                 p_recur_entry_id),
        ''BALANCE_SHEET'',
        l2.company_cost_center_org_id,
        l2.intercompany_id,
        l2.line_item_id,
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
                        '        l2.', GCS_UTILITY_PKG.g_nl, '', line_num);

    body_block := '
        --Bugfix 5449718: If net to re flag is N then all balances except ptd debit and ptd credit will be zero
        0,
        0,
        -1*ytd_debit_balance_e,
        -1*ytd_credit_balance_e,
        0,
        0
      FROM
        --Bugfix 5449718: Remove source, target entry, and category joins.
        GCS_ENTRY_LINES l2
      WHERE
          l2.entry_id = l_entry_list(i)
      AND l2.line_type_code IN (''CALCULATED'', ''BALANCE_SHEET'');
      -- Bugfix 5449718: Group by is no longer necessary

      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, g_api || ''.'' || fn_name, ''Completed Collection of Recurring Entries'');
      END IF;
';

    curr_pos := 1;
    body_len := LENGTH(body_block);
    WHILE curr_pos <= body_len LOOP
      ad_ddl.build_statement(SUBSTR(body_block, curr_pos, g_line_size),
                             line_num);
      curr_pos := curr_pos + g_line_size;
      line_num := line_num + 1;
    END LOOP;

body_block :=
'
      END IF;
    END IF; --if..then..cross year flag

    --Bugfix 5449718: Move data from gcs_entry_lines_gt into gcs_entry_lines
    INSERT INTO gcs_entry_lines
    (entry_id,
     line_type_code,
     company_cost_center_org_id,
     intercompany_id,
     line_item_id,
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
'
      xtd_balance_e,
      ytd_balance_e,
      ptd_debit_balance_e,
      ptd_credit_balance_e,
      ytd_debit_balance_e,
      ytd_credit_balance_e,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login)
    SELECT
      entry_id,
      MIN(description),
      company_cost_center_org_id,
      intercompany_id,
      line_item_id,
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
'
      SUM(NVL(xtd_balance_e,0)),
      SUM(NVL(ytd_balance_e,0)),
      SUM(NVL(ptd_debit_balance_e,0)),
      SUM(NVL(ptd_credit_balance_e,0)),
      SUM(NVL(ytd_debit_balance_e,0)),
      SUM(NVL(ytd_credit_balance_e,0)),
      sysdate,
      GCS_PERIOD_INIT_PKG.g_fnd_user_id,
      sysdate,
      GCS_PERIOD_INIT_PKG.g_fnd_user_id,
      GCS_PERIOD_INIT_PKG.g_fnd_login_id
    FROM gcs_entry_lines_gt
    GROUP BY entry_id,
             company_cost_center_org_id,
             line_item_id,

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
'        intercompany_id;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || ''.'' || fn_name,
                     ''Inserted '' || to_char(SQL%ROWCOUNT) || '' row(s)'');
    END IF;

    <<norowstoprocess>>

    COMMIT;

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
      FND_FILE.PUT_LINE(FND_FILE.LOG, GCS_UTILITY_PKG.g_module_failure ||
                        fn_name || to_char(sysdate, '' DD-MON-YYYY HH:MI:SS''));
      RAISE;
  END insert_entry_lines;

END GCS_PERIOD_INIT_DYNAMIC_PKG;';

    curr_pos := 1;
    body_len := LENGTH(body_block);
    WHILE curr_pos <= body_len LOOP
      ad_ddl.build_statement(SUBSTR(body_block, curr_pos, g_line_size),
                             line_num);
      curr_pos := curr_pos + g_line_size;
      line_num := line_num + 1;
    END LOOP;

    ad_ddl.create_plsql_object(GCS_DYNAMIC_UTIL_PKG.g_applsys_username,
			       'GCS', 'GCS_PERIOD_INIT_DYNAMIC_PKG',
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


END GCS_PERIOD_INIT_DYN_BUILD_PKG;

/
