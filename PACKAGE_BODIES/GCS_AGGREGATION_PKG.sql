--------------------------------------------------------
--  DDL for Package Body GCS_AGGREGATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_AGGREGATION_PKG" AS
/* $Header: gcsaggrb.pls 120.3 2006/02/06 19:34:28 yingliu noship $ */

  --
  -- PRIVATE GLOBAL VARIABLES
  --
  g_api     VARCHAR2(40) := 'gcs.plsql.GCS_AGGREGATION_PKG';

  --
  -- PRIVATE EXCEPTIONS
  --
  GCS_AGGR_ENTRY_FAILURE         EXCEPTION;

  --
  -- PRIVATE FUNCTIONS
  --

  --
  -- Procedure
  --   insert_prop_entry_lines
  -- Purpose
  --   Given the entry id with the "full" (100%) amount lines, create the
  --   lines for the proportional calculation entry by multiplying the amounts
  --   by the ownership percent.
  -- Notes
  --
  PROCEDURE insert_prop_entry_lines(
    p_prop_entry_id      NUMBER,
    p_full_entry_id      NUMBER,
    p_ownership_percent  NUMBER,
    p_curr_round_factor  NUMBER)
  IS
    fn_name               VARCHAR2(30) := 'INSERT_PROP_ENTRY_LINES';
  BEGIN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.' || fn_name,
                     GCS_UTILITY_PKG.g_module_enter || fn_name ||
                     to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));
    END IF;
    --FND_FILE.PUT_LINE(FND_FILE.LOG, GCS_UTILITY_PKG.g_module_enter ||
    --                  fn_name || to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));

    INSERT INTO GCS_ENTRY_LINES gel1
	(entry_id, line_type_code,
	 company_cost_center_org_id, financial_elem_id, product_id,
	 natural_account_id, channel_id, line_item_id, project_id,
	 customer_id, intercompany_id, task_id,
	 user_dim1_id, user_dim2_id, user_dim3_id, user_dim4_id,
	 user_dim5_id, user_dim6_id, user_dim7_id, user_dim8_id,
	 user_dim9_id, user_dim10_id,
	 xtd_balance_e, ytd_balance_e,
	 ptd_debit_balance_e, ptd_credit_balance_e,
	 ytd_debit_balance_e, ytd_credit_balance_e,
	 creation_date, created_by,
	 last_update_date, last_updated_by, last_update_login)
    SELECT
	p_prop_entry_id, line_type_code,
	company_cost_center_org_id, financial_elem_id, product_id,
	natural_account_id, channel_id, line_item_id, project_id,
	customer_id, intercompany_id, task_id,
	user_dim1_id, user_dim2_id, user_dim3_id, user_dim4_id,
	user_dim5_id, user_dim6_id, user_dim7_id, user_dim8_id,
	user_dim9_id, user_dim10_id,
	round((xtd_balance_e * p_ownership_percent / 100) /
	      p_curr_round_factor) * p_curr_round_factor,
	round((ytd_balance_e * p_ownership_percent / 100) /
	      p_curr_round_factor) * p_curr_round_factor,
	round((ptd_debit_balance_e * p_ownership_percent / 100) /
	      p_curr_round_factor) * p_curr_round_factor,
	round((ptd_credit_balance_e * p_ownership_percent / 100) /
	      p_curr_round_factor) * p_curr_round_factor,
	round((ytd_debit_balance_e * p_ownership_percent / 100) /
	      p_curr_round_factor) * p_curr_round_factor,
	round((ytd_credit_balance_e * p_ownership_percent / 100) /
	      p_curr_round_factor) * p_curr_round_factor,
	sysdate, created_by,
	sysdate, last_updated_by, last_update_login
    FROM   GCS_ENTRY_LINES gel2
    WHERE  gel2.entry_id = p_full_entry_id;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.' || fn_name,
                     'Inserted ' || to_char(SQL%ROWCOUNT) || ' row(s)');
    END IF;

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
  END insert_prop_entry_lines;

  --
  -- Procedure
  --   maintain_entries
  -- Purpose
  --   Create the aggregation entries and lines.
  -- Notes
  --
  PROCEDURE maintain_entries(
    p_errbuf             OUT NOCOPY VARCHAR2,
    p_retcode            OUT NOCOPY VARCHAR2,
    p_entry_id           OUT NOCOPY NUMBER,
    p_stat_entry_id      OUT NOCOPY NUMBER,
    p_prop_entry_id      OUT NOCOPY NUMBER,
    p_stat_prop_entry_id OUT NOCOPY NUMBER,
    p_consolidation_type VARCHAR2,
    p_ownership_percent  NUMBER,
    p_curr_round_factor  NUMBER,
    p_stat_round_factor  NUMBER,
    p_stat_required      VARCHAR2,
    p_hierarchy_id       NUMBER,
    p_relationship_id    NUMBER,
    p_cons_entity_id     NUMBER,
    p_cons_entity_curr   VARCHAR2,
    p_cal_period_id      NUMBER,
    p_period_end_date    DATE,
    p_balance_type_code  VARCHAR2,
    p_dataset_code       VARCHAR2)
  IS
    fn_name               VARCHAR2(30) := 'MAINTAIN_ENTRIES';

    l_category_code       VARCHAR2(30);
  BEGIN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.' || fn_name,
                     GCS_UTILITY_PKG.g_module_enter || fn_name ||
                     to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));
    END IF;
    --FND_FILE.PUT_LINE(FND_FILE.LOG, GCS_UTILITY_PKG.g_module_enter ||
    --                  fn_name || to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));

    -- Prepare all entry headers needed

    -- Decide the category for the full entries
    IF (p_consolidation_type = 'PARTIAL') THEN
      l_category_code := 'PROPORTIONAL';
    ELSE
      l_category_code := 'AGGREGATION';
    END IF;

    GCS_ENTRY_PKG.create_entry_header(
      p_errbuf, p_retcode,
      p_entry_id,
      p_hierarchy_id,
      p_cons_entity_id,
      p_cal_period_id,
      p_cal_period_id,
      'AUTOMATIC',
      p_balance_type_code,
      p_cons_entity_curr,
      'SINGLE_RUN_FOR_PERIOD',
      l_category_code);

    IF (p_retcode = fnd_api.g_ret_sts_unexp_error) THEN
      RAISE GCS_AGGR_ENTRY_FAILURE;
    END IF;

    IF (p_stat_required = 'Y') THEN
      GCS_ENTRY_PKG.create_entry_header(
        p_errbuf, p_retcode,
        p_stat_entry_id,
        p_hierarchy_id,
        p_cons_entity_id,
        p_cal_period_id,
        p_cal_period_id,
        'AUTOMATIC',
        p_balance_type_code,
        'STAT',
        'SINGLE_RUN_FOR_PERIOD',
        l_category_code);

      IF (p_retcode = fnd_api.g_ret_sts_unexp_error) THEN
        RAISE GCS_AGGR_ENTRY_FAILURE;
      END IF;
    END IF;

    IF (p_consolidation_type = 'PARTIAL') THEN
      GCS_ENTRY_PKG.create_entry_header(
        p_errbuf, p_retcode,
        p_prop_entry_id,
        p_hierarchy_id,
        p_cons_entity_id,
        p_cal_period_id,
        p_cal_period_id,
        'AUTOMATIC',
        p_balance_type_code,
        p_cons_entity_curr,
        'SINGLE_RUN_FOR_PERIOD',
        'AGGREGATION');

      IF (p_retcode = fnd_api.g_ret_sts_unexp_error) THEN
        RAISE GCS_AGGR_ENTRY_FAILURE;
      END IF;

      IF (p_stat_required = 'Y') THEN
        GCS_ENTRY_PKG.create_entry_header(
          p_errbuf, p_retcode,
          p_stat_prop_entry_id,
          p_hierarchy_id,
          p_cons_entity_id,
          p_cal_period_id,
          p_cal_period_id,
          'AUTOMATIC',
          p_balance_type_code,
          'STAT',
          'SINGLE_RUN_FOR_PERIOD',
          'AGGREGATION');

        IF (p_retcode = fnd_api.g_ret_sts_unexp_error) THEN
          RAISE GCS_AGGR_ENTRY_FAILURE;
        END IF;
      END IF;
    END IF;

    -- Create the FULL amount lines for both entity's currency and STAT
    GCS_AGGREGATION_DYNAMIC_PKG.insert_full_entry_lines(
      p_entry_id,
      p_stat_entry_id,
      p_cons_entity_id,
      p_hierarchy_id,
      p_relationship_id,
      p_cal_period_id,
      p_period_end_date,
      p_cons_entity_curr,
      p_balance_type_code,
      p_dataset_code);

    -- Create proportional lines if necessary
    IF (p_consolidation_type = 'PARTIAL') THEN
      insert_prop_entry_lines(p_prop_entry_id,
                              p_entry_id,
                              p_ownership_percent,
                              p_curr_round_factor);

      IF (p_stat_entry_id IS NOT NULL) THEN
        insert_prop_entry_lines(p_stat_prop_entry_id,
                                p_stat_entry_id,
                                p_ownership_percent,
                                p_stat_round_factor);
      END IF;
    END IF;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.' || fn_name,
                     GCS_UTILITY_PKG.g_module_success || fn_name ||
                     to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));
    END IF;
    --FND_FILE.PUT_LINE(FND_FILE.LOG, GCS_UTILITY_PKG.g_module_success ||
    --                  fn_name || to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));

  EXCEPTION
    WHEN GCS_AGGR_ENTRY_FAILURE THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
                       g_api || '.' || fn_name,
                       GCS_UTILITY_PKG.g_module_failure || fn_name ||
                       to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));
      END IF;
      --FND_FILE.PUT_LINE(FND_FILE.LOG, GCS_UTILITY_PKG.g_module_failure ||
      --                  fn_name || to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));
      RAISE GCS_AGGR_ENTRY_FAILURE;
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

  PROCEDURE Aggregate(
    p_errbuf            OUT NOCOPY VARCHAR2,
    p_retcode           OUT NOCOPY VARCHAR2,
    p_run_detail_id     NUMBER,
    p_hierarchy_id      NUMBER,
    p_relationship_id   NUMBER,
    p_cons_entity_id    NUMBER,
    p_cal_period_id     NUMBER,
    p_period_end_date   DATE,
    p_balance_type_code VARCHAR2,
    p_stat_required     VARCHAR2,
    p_hier_dataset_code   NUMBER)
  IS
    fn_name               VARCHAR2(30) := 'AGGREGATE';

    l_cons_entity_curr    VARCHAR2(30);
    l_consolidation_type  VARCHAR2(30);
    l_ownership_percent   NUMBER;

    l_entry_id            NUMBER;
    l_prop_entry_id       NUMBER;
    l_stat_entry_id       NUMBER;
    l_stat_prop_entry_id  NUMBER;

    l_curr_round_factor   NUMBER;
    l_stat_round_factor   NUMBER;
  BEGIN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.' || fn_name,
                     GCS_UTILITY_PKG.g_module_enter || fn_name ||
                     to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));

      -- parameters passed in
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.' || fn_name,
                     'p_run_detail_id = ' || to_char(p_run_detail_id));
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.' || fn_name,
                     'p_hierarchy_id = ' || to_char(p_hierarchy_id));
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.' || fn_name,
                     'p_relationship_id = ' || to_char(p_relationship_id));
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.' || fn_name,
                     'p_cons_entity_id = ' || to_char(p_cons_entity_id));
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.' || fn_name,
                     'p_cal_period_id = ' || to_char(p_cal_period_id));
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.' || fn_name,
                     'p_period_end_date = ' || to_char(p_period_end_date,
                                                       'DD-MON-YYYY'));
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.' || fn_name,
                     'p_balance_type_code = ' || p_balance_type_code);
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.' || fn_name,
                     'p_stat_required = ' || p_stat_required);
    END IF;
    --FND_FILE.PUT_LINE(FND_FILE.LOG, GCS_UTILITY_PKG.g_module_enter ||
    --                  fn_name || to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));

    -- In case of an error, roll back to this point
    SAVEPOINT gcs_aggregation_start;

    -- ***** Setup *****
    g_fnd_user_id := fnd_global.user_id;
    g_fnd_login_id := fnd_global.login_id;

    -- get the consolidation entity's currency
    SELECT currency_code
    INTO   l_cons_entity_curr
    FROM   GCS_ENTITY_CONS_ATTRS
    WHERE  hierarchy_id = p_hierarchy_id
    AND    entity_id = p_cons_entity_id;

    -- get the consolidation type and ownership percent
    SELECT nvl(min(gt.consolidation_type_code), 'FULL'),
           min(gcr.ownership_percent)
    INTO   l_consolidation_type, l_ownership_percent
    FROM   GCS_CONS_RELATIONSHIPS gcr,
           GCS_TREATMENTS_B gt
    WHERE  gcr.cons_relationship_id = p_relationship_id
    AND    gcr.actual_ownership_flag = 'Y'
    AND    gt.treatment_id = gcr.treatment_id;

    IF (l_consolidation_type = 'PARTIAL') THEN
      -- get minimum accountable unit for the currency
      SELECT nvl(minimum_accountable_unit, power(10, -precision))
      INTO   l_curr_round_factor
      FROM   FND_CURRENCIES
      WHERE  currency_code = l_cons_entity_curr;

      IF (p_stat_required = 'Y') THEN
        -- get minimum accountable unit for STAT
        SELECT nvl(minimum_accountable_unit, power(10, -precision))
        INTO   l_stat_round_factor
        FROM   FND_CURRENCIES
        WHERE  currency_code = 'STAT';
      END IF;
    END IF;

    -- ***** Main Process *****
    maintain_entries(
      p_errbuf,
      p_retcode,
      l_entry_id ,
      l_stat_entry_id,
      l_prop_entry_id,
      l_stat_prop_entry_id,
      l_consolidation_type,
      l_ownership_percent,
      l_curr_round_factor,
      l_stat_round_factor,
      p_stat_required,
      p_hierarchy_id,
      p_relationship_id,
      p_cons_entity_id,
      l_cons_entity_curr,
      p_cal_period_id,
      p_period_end_date,
      p_balance_type_code,
      p_hier_dataset_code);

    -- Update run details with the new entry id's
    IF (l_consolidation_type = 'PARTIAL') THEN
      GCS_CONS_ENG_RUN_DTLS_PKG.update_entry_headers(p_run_detail_id,
                                                     l_prop_entry_id,
                                                     l_stat_prop_entry_id,
                                                     l_entry_id,
                                                     l_stat_entry_id);

    ELSE
      GCS_CONS_ENG_RUN_DTLS_PKG.update_entry_headers(p_run_detail_id,
                                                     l_entry_id,
                                                     l_stat_entry_id);
    END IF;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.' || fn_name,
                     GCS_UTILITY_PKG.g_module_success || fn_name ||
                     to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));
    END IF;
    --FND_FILE.PUT_LINE(FND_FILE.LOG, GCS_UTILITY_PKG.g_module_success ||
    --                  fn_name || to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));

  EXCEPTION
    WHEN GCS_AGGR_ENTRY_FAILURE THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
                       g_api || '.' || fn_name,
                       GCS_UTILITY_PKG.g_module_failure || fn_name ||
                       to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));
      END IF;
      --FND_FILE.PUT_LINE(FND_FILE.LOG, GCS_UTILITY_PKG.g_module_failure ||
      --                  fn_name || to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));

      ROLLBACK TO gcs_aggregation_start;
      -- p_errbuf and p_retcode are set by GCS_ENTRY_PKG.create_entry_header()
    WHEN NO_DATA_FOUND THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
                       g_api || '.' || fn_name,
                       'Consolidation Entity Curr = ' || l_cons_entity_curr);
        FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
                       g_api || '.' || fn_name,
                       'Dataset Code = ' || to_char(p_hier_dataset_code));
        FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
                       g_api || '.' || fn_name,
                       'Consolidation Type = ' || l_consolidation_type);
        FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
                       g_api || '.' || fn_name,
                       'Ownership Percent = ' || to_char(l_ownership_percent));
        FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
                       g_api || '.' || fn_name,
                       'Currency MAU = ' || to_char(l_curr_round_factor));
        FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
                       g_api || '.' || fn_name,
                       'STAT MAU = ' || to_char(l_stat_round_factor));

        FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
                       g_api || '.' || fn_name,
                       GCS_UTILITY_PKG.g_module_failure || fn_name ||
                       to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));
      END IF;
      --FND_FILE.PUT_LINE(FND_FILE.LOG, GCS_UTILITY_PKG.g_module_failure ||
      --                  fn_name || to_char(sysdate, ' DD-MON-YYYY HH:MI:SS'));

      ROLLBACK TO gcs_aggregation_start;
      p_errbuf := 'GCS_AGGR_NO_DATA_FOUND';
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

      ROLLBACK TO gcs_aggregation_start;
      p_errbuf := 'GCS_AGGR_UNHANDLED_EXCEPTION';
      p_retcode := '2';
  END Aggregate;

END GCS_AGGREGATION_PKG;

/
