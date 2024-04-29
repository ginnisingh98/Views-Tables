--------------------------------------------------------
--  DDL for Package Body GCS_PERIOD_INIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_PERIOD_INIT_PKG" AS
/* $Header: gcspinib.pls 120.4 2007/05/15 21:33:40 skamdar ship $ */

  --
  -- GLOBAL DATA TYPES
  --

  --Bugfix 5449718: Add Net To RE Information to PL/SQL Record
  TYPE r_entry_info IS RECORD
			(category_code           VARCHAR2(50),
			 num_init_stat_sources   NUMBER(15),
			 num_recur_sources       NUMBER(15),
			 num_recur_stat_sources  NUMBER(15),
                         net_to_re_flag          VARCHAR2(1));
  TYPE t_entry_info IS TABLE OF r_entry_info;

  --
  -- PRIVATE GLOBAL VARIABLES
  --
  g_api      VARCHAR2(40) := 'gcs.plsql.GCS_PERIOD_INIT_PKG';

  g_entry_info t_entry_info;

  --
  -- PRIVATE EXCEPTIONS
  --
  GCS_PI_ENTRY_FAILURE	EXCEPTION;

  --
  -- PRIVATE FUNCTIONS
  --

  --
  -- Function
  --   prepare_entry_header
  -- Purpose
  --   Create a period initialization/recurring entry if not already exists,
  --   else clean up its entry lines. Return the entry id found or created.
  --
  FUNCTION prepare_entry_header(
    p_errbuf              OUT NOCOPY VARCHAR2,
    p_retcode             OUT NOCOPY VARCHAR2,
    p_hierarchy_id        NUMBER,
    p_entity_id           NUMBER,
    p_currency_code       VARCHAR2,
    p_start_cal_period_id NUMBER,
    p_end_cal_period_id   NUMBER,
    p_balance_type_code   VARCHAR2,
    p_category_code       VARCHAR2) RETURN NUMBER
  IS
    fn_name                VARCHAR2(30) := 'PREPARE_ENTRY_HEADER';

    l_entry_id             NUMBER;
    l_entry_existed        VARCHAR2(1);

    l_target_entity_code   VARCHAR2(30);
    l_is_elim_entity       VARCHAR2(1);
    l_cons_entity_id       NUMBER;
    l_query_entity_id      NUMBER; -- Use the parent entity id if this is
                                   -- an elimination entity with the target
                                   -- entity code 'PARENT'

    CURSOR find_entry(c_entity_id NUMBER) IS
      SELECT min(entry_id), decode(min(entry_id), NULL, 'N', 'Y')
      FROM   GCS_ENTRY_HEADERS
      WHERE  hierarchy_id = p_hierarchy_id
      AND    entity_id = c_entity_id
      AND    currency_code = p_currency_code
      AND    balance_type_code = p_balance_type_code
      AND    start_cal_period_id = p_start_cal_period_id
      AND    nvl(end_cal_period_id, -1) = nvl(p_end_cal_period_id, -1)
      AND    category_code = p_category_code
      AND    period_init_entry_flag = 'Y';
  BEGIN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.' || fn_name,
                     GCS_UTILITY_PKG.g_module_enter || fn_name ||
                     to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));
    END IF;
    --FND_FILE.PUT_LINE(FND_FILE.LOG, GCS_UTILITY_PKG.g_module_enter ||
    --                 fn_name || to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));

    -- Initialize this, and overwrite if necessary
    l_query_entity_id := p_entity_id;

    SELECT target_entity_code
    INTO   l_target_entity_code
    FROM   gcs_categories_b
    WHERE  category_code = p_category_code;

    IF (l_target_entity_code = 'PARENT') THEN
      SELECT nvl(decode(dim_attribute_varchar_member, 'E', 'Y', 'N'), 'N')
      INTO   l_is_elim_entity
      FROM   FEM_ENTITIES_ATTR
      WHERE  attribute_id = GCS_UTILITY_PKG.g_dimension_attr_info
                            ('ENTITY_ID-ENTITY_TYPE_CODE').attribute_id
      AND    version_id = GCS_UTILITY_PKG.g_dimension_attr_info
                            ('ENTITY_ID-ENTITY_TYPE_CODE').version_id
      AND    entity_id = p_entity_id
      AND    value_set_id = GCS_UTILITY_PKG.g_gcs_dimension_info
                            ('ENTITY_ID').associated_value_set_id;

      IF (l_is_elim_entity = 'Y') THEN
        SELECT oper_fea.dim_attribute_numeric_member
        INTO   l_query_entity_id
        FROM   fem_entities_attr oper_fea,
               fem_entities_attr elim_fea
        WHERE  elim_fea.attribute_id = GCS_UTILITY_PKG.g_dimension_attr_info
                                       ('ENTITY_ID-ELIMINATION_ENTITY').attribute_id
        AND    elim_fea.version_id = GCS_UTILITY_PKG.g_dimension_attr_info
                                       ('ENTITY_ID-ELIMINATION_ENTITY').version_id
        AND    elim_fea.value_set_id = GCS_UTILITY_PKG.g_gcs_dimension_info
                                       ('ENTITY_ID').associated_value_set_id
        AND    elim_fea.dim_attribute_numeric_member = p_entity_id
        AND    oper_fea.entity_id = elim_fea.entity_id
        AND    oper_fea.attribute_id = GCS_UTILITY_PKG.g_dimension_attr_info
                                       ('ENTITY_ID-OPERATING_ENTITY').attribute_id
        AND    oper_fea.version_id = GCS_UTILITY_PKG.g_dimension_attr_info
                                       ('ENTITY_ID-OPERATING_ENTITY').version_id
        AND    oper_fea.value_set_id = GCS_UTILITY_PKG.g_gcs_dimension_info
                                       ('ENTITY_ID').associated_value_set_id;
      END IF;
    END IF;

    OPEN find_entry(l_query_entity_id);
    FETCH find_entry INTO l_entry_id, l_entry_existed;
    CLOSE find_entry;

    IF (l_entry_existed = 'N') THEN
      -- need a new entry header
      GCS_ENTRY_PKG.create_entry_header(
        p_errbuf, p_retcode,
        l_entry_id,
        p_hierarchy_id,
        l_query_entity_id,
        p_start_cal_period_id,
        p_end_cal_period_id,
        'AUTOMATIC',
        p_balance_type_code,
        p_currency_code,
        'ALL_RUN_FOR_PERIOD',
        p_category_code,
        null, null, 'Y');

      IF (p_retcode = fnd_api.g_ret_sts_unexp_error) THEN
        RAISE GCS_PI_ENTRY_FAILURE;
      END IF;

    ELSIF (l_entry_existed = 'Y') THEN
      -- clear original entry lines
      DELETE FROM GCS_ENTRY_LINES
      WHERE entry_id = l_entry_id;
    END IF;

    RETURN l_entry_id;

  EXCEPTION
    WHEN GCS_PI_ENTRY_FAILURE THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
                       g_api || '.' || fn_name,
                       GCS_UTILITY_PKG.g_module_failure || fn_name ||
                       to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));
      END IF;
      --FND_FILE.PUT_LINE(FND_FILE.LOG, GCS_UTILITY_PKG.g_module_failure ||
      --                  fn_name || to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));
      RAISE GCS_PI_ENTRY_FAILURE;
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
  END prepare_entry_header;

  --
  -- Procedure
  --   maintain_entries
  -- Purpose
  --   Create or update the initialization and recurring entries.
  --
  PROCEDURE maintain_entries(
    p_errbuf               OUT NOCOPY VARCHAR2,
    p_retcode              OUT NOCOPY VARCHAR2,
    p_run_name             VARCHAR2,
    p_hierarchy_id         NUMBER,
    p_entity_id            NUMBER,
    p_currency_code        VARCHAR2,
    p_is_elim_entity       VARCHAR2,
    p_cons_entity_id       NUMBER,
    p_cons_entity_curr     VARCHAR2,
    p_translation_required VARCHAR2,
    p_next_cal_period_id   NUMBER,
    p_balance_type_code    VARCHAR2,
    p_bal_by_org_flag      VARCHAR2,
    p_sec_track_col_name   VARCHAR2,
    p_re_template          GCS_TEMPLATES_PKG.TemplateRecord,
    p_cross_year_flag      VARCHAR2,
    p_cat_index            NUMBER,
    --Bugfix 5449718: Added parameter to get the current calendar period year
    p_cal_period_year      NUMBER)
  IS
    fn_name                VARCHAR2(30) := 'MAINTAIN_ENTRIES';

    l_category_code        VARCHAR2(30);
    l_net_to_re_flag       VARCHAR2(30);

    l_last_cal_period_id   NUMBER;

    l_init_entry_id        NUMBER;
    l_init_xlate_entry_id  NUMBER;
    l_init_stat_entry_id   NUMBER;
    l_recur_entry_id       NUMBER;
    l_recur_xlate_entry_id NUMBER;
    l_recur_stat_entry_id  NUMBER;

      CURSOR last_period_c IS
      SELECT	lp.cal_period_id
      FROM	fem_cal_periods_b lp,
		fem_cal_periods_b fp,
		fem_cal_periods_attr lp_year,
		fem_cal_periods_attr fp_year,
		fem_cal_periods_attr lp_num
      WHERE	fp.cal_period_id = p_next_cal_period_id
      AND	lp.dimension_group_id = fp.dimension_group_id
      AND	lp.calendar_id = fp.calendar_id
      AND	lp_year.cal_period_id = lp.cal_period_id
      AND	lp_year.attribute_id = GCS_UTILITY_PKG.g_dimension_attr_info('CAL_PERIOD_ID-ACCOUNTING_YEAR').attribute_id
      AND	lp_year.version_id = GCS_UTILITY_PKG.g_dimension_attr_info('CAL_PERIOD_ID-ACCOUNTING_YEAR').version_id
      AND	fp_year.cal_period_id = fp.cal_period_id
      AND	fp_year.attribute_id = GCS_UTILITY_PKG.g_dimension_attr_info('CAL_PERIOD_ID-ACCOUNTING_YEAR').attribute_id
      AND	fp_year.version_id = GCS_UTILITY_PKG.g_dimension_attr_info('CAL_PERIOD_ID-ACCOUNTING_YEAR').version_id
      AND	lp_year.number_assign_value = fp_year.number_assign_value
      AND	lp_num.cal_period_id = lp.cal_period_id
      AND	lp_num.attribute_id = GCS_UTILITY_PKG.g_dimension_attr_info('CAL_PERIOD_ID-GL_PERIOD_NUM').attribute_id
      AND	lp_num.version_id = GCS_UTILITY_PKG.g_dimension_attr_info('CAL_PERIOD_ID-GL_PERIOD_NUM').version_id
      ORDER BY lp_num.number_assign_value desc;

  BEGIN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.' || fn_name,
                     GCS_UTILITY_PKG.g_module_enter || fn_name ||
                     to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));
    END IF;
    --FND_FILE.PUT_LINE(FND_FILE.LOG, GCS_UTILITY_PKG.g_module_enter ||
    --                  fn_name || to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));

    l_category_code := g_entry_info(p_cat_index).category_code;

    --Bugfix 5449718: No longer need to query  Net to RE Flag as its available on g_entry_info
    /*
    SELECT	net_to_re_flag
    INTO	l_net_to_re_flag
    FROM	gcs_categories_b
    WHERE	category_code = l_category_code;
    */
    l_net_to_re_flag := g_entry_info(p_cat_index).net_to_re_flag;

    --SKAMDAR: Added debugging statement
    fnd_file.put_line(fnd_file.log, '<<<<<Maintain Entries>>>>');
    fnd_file.put_line(fnd_file.log, 'Category Code: ' || l_category_code);
    fnd_file.put_line(fnd_file.log, 'Net to RE Flag: ' || l_net_to_re_flag);
    fnd_file.put_line(fnd_file.log, '<<<<<Maintain Entries>>>>');

    -- INITIALIZATION ENTRIES FOR NEXT PERIOD
    -- entity-currency entry
    IF (p_cross_year_flag <> 'Y' OR l_net_to_re_flag <> 'Y') THEN

      fnd_file.put_line(fnd_file.log, 'In the individual period area');

      l_init_entry_id := prepare_entry_header(
		p_errbuf, p_retcode, p_hierarchy_id, p_entity_id,
		p_currency_code, p_next_cal_period_id, p_next_cal_period_id,
		p_balance_type_code, l_category_code);

      --Bugfix 5449718: Removed calls to initialize the xlate entry as they are no longer required
      /*
      -- check if translation entry is required
      IF (p_translation_required = 'Y') THEN
        l_init_xlate_entry_id := prepare_entry_header(
		p_errbuf, p_retcode, p_hierarchy_id, p_entity_id,
		p_cons_entity_curr, p_next_cal_period_id, p_next_cal_period_id,
		p_balance_type_code, l_category_code);
      END IF;
      */

      -- check if STAT entry is required
      IF (g_entry_info(p_cat_index).num_init_stat_sources > 0) THEN
        l_init_stat_entry_id := prepare_entry_header(
		p_errbuf, p_retcode, p_hierarchy_id, p_entity_id,
		'STAT', p_next_cal_period_id, p_next_cal_period_id,
		p_balance_type_code, l_category_code);
      END IF;

    -- CARRY-FORWARD RECURRING ENTRIES FOR NEXT YEAR
    ELSE
      fnd_file.put_line(fnd_file.log, 'Entering the carry forward area');

      -- Get the last period of the new year
      OPEN last_period_c;
      FETCH last_period_c INTO l_last_cal_period_id;
      CLOSE last_period_c;

      -- check if entity-currency entry is required
      IF (g_entry_info(p_cat_index).num_recur_sources > 0) THEN
        l_recur_entry_id := prepare_entry_header(
		p_errbuf, p_retcode, p_hierarchy_id, p_entity_id,
		p_currency_code, p_next_cal_period_id, l_last_cal_period_id,
		p_balance_type_code, l_category_code);

        --Bugfix 5449718: Removed calls to initialize the xlate entry as they are no longer required
        /*
        -- check if translation entry is required
        IF (p_translation_required = 'Y') THEN
          l_recur_xlate_entry_id := prepare_entry_header(
		p_errbuf, p_retcode, p_hierarchy_id, p_entity_id,
		p_cons_entity_curr, p_next_cal_period_id, l_last_cal_period_id,
		p_balance_type_code, l_category_code);
        END IF;
        */
      END IF;

      -- check if STAT entry is required
      IF (g_entry_info(p_cat_index).num_recur_stat_sources > 0) THEN
        l_recur_stat_entry_id := prepare_entry_header(
		p_errbuf, p_retcode, p_hierarchy_id, p_entity_id,
		'STAT', p_next_cal_period_id, l_last_cal_period_id,
		p_balance_type_code, l_category_code);
      END IF;
    END IF;  -- if cross year

    -- calculate the lines
    GCS_PERIOD_INIT_DYNAMIC_PKG.insert_entry_lines(p_run_name,
						   p_hierarchy_id,
						   p_entity_id,
						   p_currency_code,
						   p_bal_by_org_flag,
						   p_sec_track_col_name,
						   p_is_elim_entity,
						   p_cons_entity_id,
						   p_re_template,
						   p_cross_year_flag,
						   l_category_code,
						   l_init_entry_id,
						   l_init_xlate_entry_id,
						   l_init_stat_entry_id,
						   l_recur_entry_id,
						   l_recur_xlate_entry_id,
						   l_recur_stat_entry_id,
                                                   --Bugfix 5449718: Passing the calendar period year and net to re flag
                                                   p_cal_period_year,
                                                   l_net_to_re_flag);

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.' || fn_name,
                     GCS_UTILITY_PKG.g_module_success || fn_name ||
                     to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));
    END IF;
    --FND_FILE.PUT_LINE(FND_FILE.LOG, GCS_UTILITY_PKG.g_module_success ||
    --                  fn_name || to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));

  EXCEPTION
    WHEN GCS_PI_ENTRY_FAILURE THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
                       g_api || '.' || fn_name,
                       GCS_UTILITY_PKG.g_module_failure || fn_name ||
                       to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));
      END IF;
      --FND_FILE.PUT_LINE(FND_FILE.LOG, GCS_UTILITY_PKG.g_module_failure ||
      --                 fn_name || to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));
      RAISE GCS_PI_ENTRY_FAILURE;
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
  END maintain_entries;


  --
  -- PUBLIC FUNCTIONS
  --

  PROCEDURE Create_Period_Init_Entries(
    p_errbuf               OUT NOCOPY VARCHAR2,
    p_retcode              OUT NOCOPY VARCHAR2,
    p_run_name             VARCHAR2,
    p_hierarchy_id         NUMBER,
    p_relationship_id      NUMBER,
    p_entity_id            NUMBER,
    p_cons_entity_id       NUMBER,
    p_translation_required VARCHAR2,
    p_cal_period_id        NUMBER,
    p_balance_type_code    VARCHAR2,
    p_category_code        VARCHAR2 DEFAULT NULL)
  IS
    fn_name                VARCHAR2(30) := 'CREATE_PERIOD_INIT_ENTRIES';

    l_bal_by_org_flag      VARCHAR2(1);
    l_sec_track_col_name   VARCHAR2(30);
    l_entity_curr          VARCHAR2(30);
    l_cons_entity_curr     VARCHAR2(30);
    l_is_elim_entity       VARCHAR2(1);
    l_re_template          GCS_TEMPLATES_PKG.TemplateRecord;

    l_cal_period_info      GCS_UTILITY_PKG.r_cal_period_info;
    l_last_period_of_year  VARCHAR2(1);
  BEGIN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.' || fn_name,
                     GCS_UTILITY_PKG.g_module_enter || fn_name ||
                     to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));

      -- parameters passed in
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.' || fn_name,
                     'p_run_name = ' || p_run_name);
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.' || fn_name,
                     'p_hierarchy_id = ' || to_char(p_hierarchy_id));
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.' || fn_name,
                     'p_relationship_id = ' || to_char(p_relationship_id));
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.' || fn_name,
                     'p_entity_id = ' || to_char(p_entity_id));
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.' || fn_name,
                     'p_cons_entity_id = ' || to_char(p_cons_entity_id));
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.' || fn_name,
                     'p_translation_required = ' || p_translation_required);
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.' || fn_name,
                     'p_cal_period_id = ' || to_char(p_cal_period_id));
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.' || fn_name,
                     'p_balance_type_code = ' || p_balance_type_code);
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.' || fn_name,
                     'p_category_code = ' || p_category_code);
    END IF;
    --FND_FILE.PUT_LINE(FND_FILE.LOG, GCS_UTILITY_PKG.g_module_enter ||
    --                  fn_name || to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));

    -- In case of an error, roll back to this point
    SAVEPOINT gcs_period_init_start;

    -- ***** Setup *****
    g_fnd_user_id := fnd_global.user_id;
    g_fnd_login_id := fnd_global.login_id;

    GCS_UTILITY_PKG.init_dimension_info;
    GCS_UTILITY_PKG.init_dimension_attr_info;

    -- get entity and parent entity's currencies
    SELECT currency_code
    INTO   l_entity_curr
    FROM   GCS_ENTITY_CONS_ATTRS
    WHERE  hierarchy_id = p_hierarchy_id
    AND    entity_id = p_entity_id;

    --Bugfix 5449718: We do not need to create initialized entries for translated results
    --Commenting the query below
    /*
    IF (p_translation_required = 'Y') THEN
      SELECT currency_code
      INTO   l_cons_entity_curr
      FROM   GCS_ENTITY_CONS_ATTRS
      WHERE  hierarchy_id = p_hierarchy_id
      AND    entity_id = p_cons_entity_id;
    END IF;
    */

    -- get hierarchy setting: balance by org and/or secondary dim
    SELECT balance_by_org_flag, column_name
    INTO   l_bal_by_org_flag, l_sec_track_col_name
    FROM   gcs_hierarchies_b
    WHERE  hierarchy_id = p_hierarchy_id;

    -- determine if the entity is an elimination entity
    SELECT nvl(decode(dim_attribute_varchar_member, 'E', 'Y', 'N'), 'N')
    INTO   l_is_elim_entity
    FROM   FEM_ENTITIES_ATTR
    WHERE  attribute_id = GCS_UTILITY_PKG.g_dimension_attr_info
                          ('ENTITY_ID-ENTITY_TYPE_CODE').attribute_id
    AND    version_id = GCS_UTILITY_PKG.g_dimension_attr_info
                          ('ENTITY_ID-ENTITY_TYPE_CODE').version_id
    AND    entity_id = p_entity_id
    AND    value_set_id = GCS_UTILITY_PKG.g_gcs_dimension_info
                          ('ENTITY_ID').associated_value_set_id;

    -- get retained earnings template
    GCS_TEMPLATES_PKG.get_dimension_template(p_hierarchy_id, 'RE',
                                             p_balance_type_code,
                                             l_re_template);

    GCS_UTILITY_PKG.get_cal_period_details(p_cal_period_id,
                                           l_cal_period_info);

    IF (l_cal_period_info.cal_period_number =
                       l_cal_period_info.cal_periods_per_year) THEN
      l_last_period_of_year := 'Y';
    ELSE
      l_last_period_of_year := 'N';
    END IF;

    -- ***** Main Process *****
    -- populate g_entry_info: find categories to be processed

    --Bugfix 5449718: Modify query into two separate queries for performance purposes
    IF (l_is_elim_entity = 'Y') THEN
      --If the entity passed from the engine is an elimination entity must generate period initializiation entries for any
      --category that hits the parent or elimination entities
      SELECT gcb.category_code,
             count(gcerd.stat_entry_id),
             count(decode(gcb.net_to_re_flag, 'N', null, gcerd.entry_id)),
             count(decode(gcb.net_to_re_flag, 'N', null, gcerd.stat_entry_id)),
             min(gcb.net_to_re_flag)
      BULK COLLECT INTO g_entry_info
      FROM   gcs_cons_eng_run_dtls gcerd,
             gcs_categories_b      gcb
      WHERE  gcerd.run_name                  = p_run_name
      AND    gcerd.consolidation_entity_id   = p_cons_entity_id
      AND    gcerd.child_entity_id           IS NOT NULL
      AND    gcerd.category_code             = gcb.category_code
      AND    gcb.target_entity_code         IN ('PARENT', 'ELIMINATION')
      GROUP  BY gcb.category_code;

    ELSE
      --If the entity passed is an operating entity you should only process categories where the target is a child
      SELECT gcb.category_code,
             count(gcerd.stat_entry_id),
             count(decode(gcb.net_to_re_flag, 'N', null, gcerd.entry_id)),
             count(decode(gcb.net_to_re_flag, 'N', null, gcerd.stat_entry_id)),
             min(gcb.net_to_re_flag)
      BULK COLLECT INTO g_entry_info
      FROM   gcs_cons_eng_run_dtls gcerd,
             gcs_categories_b      gcb
      WHERE  gcerd.run_name                  = p_run_name
      AND    gcerd.consolidation_entity_id   = p_cons_entity_id
      AND    gcerd.child_entity_id           = p_entity_id
      AND    gcerd.category_code             = gcb.category_code
      AND    gcb.target_entity_code          = 'CHILD'
      --Bugfix 6037112
      AND    gcb.category_type_code          <> 'PROCESS'
      GROUP  BY gcb.category_code;
    END IF;

    -- Process by category
    FOR cat_index IN 1..g_entry_info.COUNT LOOP
      --Bugfix 5449718: Added the current calendar period year as a parameter
      maintain_entries(p_errbuf,
                       p_retcode,
                       p_run_name,
                       p_hierarchy_id,
                       p_entity_id,
                       l_entity_curr,
                       l_is_elim_entity,
                       p_cons_entity_id,
                       l_cons_entity_curr,
                       p_translation_required,
                       l_cal_period_info.next_cal_period_id,
                       p_balance_type_code,
                       l_bal_by_org_flag,
                       l_sec_track_col_name,
                       l_re_template,
                       l_last_period_of_year,
                       cat_index,
                       l_cal_period_info.cal_period_year);
    END LOOP;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.' || fn_name,
                     GCS_UTILITY_PKG.g_module_success || fn_name ||
                     to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));
    END IF;
    --FND_FILE.PUT_LINE(FND_FILE.LOG, GCS_UTILITY_PKG.g_module_success ||
    --                  fn_name || to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));

  EXCEPTION
    WHEN GCS_PI_ENTRY_FAILURE THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
                       g_api || '.' || fn_name,
                       GCS_UTILITY_PKG.g_module_failure || fn_name ||
                       to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));
      END IF;
      --FND_FILE.PUT_LINE(FND_FILE.LOG, GCS_UTILITY_PKG.g_module_failure ||
      --                  fn_name || to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));

      ROLLBACK TO gcs_period_init_start;
      -- p_errbuf and p_retcode are set by GCS_ENTRY_PKG.create_entry_header()
    WHEN NO_DATA_FOUND THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
                       g_api || '.' || fn_name,
                       'Entity Curr = ' || l_entity_curr);
        FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
                       g_api || '.' || fn_name,
                       'Cons Entity Curr = ' || l_cons_entity_curr);
        FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
                       g_api || '.' || fn_name,
                       'Balance By Org Flag = ' || l_bal_by_org_flag);
        FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
                       g_api || '.' || fn_name,
                       'Secondary Tracking Column = ' || l_sec_track_col_name);
        FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
                       g_api || '.' || fn_name,
                       'Is Elimination Entity = ' || l_is_elim_entity);

        FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
                       g_api || '.' || fn_name,
                       GCS_UTILITY_PKG.g_module_failure || fn_name ||
                       to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));
      END IF;
      --FND_FILE.PUT_LINE(FND_FILE.LOG, GCS_UTILITY_PKG.g_module_failure ||
      --                  fn_name || to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));

      ROLLBACK TO gcs_period_init_start;
      p_errbuf := 'GCS_PI_NO_DATA_FOUND';
      p_retcode := '2';
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

      ROLLBACK TO gcs_period_init_start;
      p_errbuf := 'GCS_PI_UNHANDLED_EXCEPTION';
      p_retcode := '2';
  END Create_Period_Init_Entries;

END GCS_PERIOD_INIT_PKG;

/
