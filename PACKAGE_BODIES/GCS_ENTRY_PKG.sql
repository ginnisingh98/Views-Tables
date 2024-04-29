--------------------------------------------------------
--  DDL for Package Body GCS_ENTRY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_ENTRY_PKG" AS
  /* $Header: gcsentryb.pls 120.12 2007/10/17 22:27:17 skamdar ship $ */
  --
  -- PRIVATE GLOBAL VARIABLES
  --
  -- The API name
  g_pkg_name CONSTANT VARCHAR2(30) := 'gcs.plsql.GCS_ENTRY_PKG';
  -- dimension info from gcs_utility_pkg
  g_dimension_attr_info gcs_utility_pkg.t_hash_dimension_attr_info := gcs_utility_pkg.g_dimension_attr_info;
  g_gcs_dimension_info  gcs_utility_pkg.t_hash_gcs_dimension_info := gcs_utility_pkg.g_gcs_dimension_info;
  -- A newline character. Included for convenience when writing long strings.
  g_nl VARCHAR2(1) := '
';
  -- session id
  g_session_id NUMBER;
  -- Record to store entry name and description
  TYPE r_entry_header IS RECORD(
    NAME        VARCHAR2(80),
    description VARCHAR2(240));
  no_re_template_error EXCEPTION;
  invalid_entity_error EXCEPTION;
  invalid_rule_error EXCEPTION;
  import_header_error EXCEPTION;
  --
  -- PRIVATE PROCEDURES
  --
  ---------------------------------------------------------------------------
  --  Enhancement : 6416736, Created a new procedure
  -- Procedure
  --   import_hier_grp_entry()
  -- Purpose
  --   Inserts rows into gcs_entry_headers and gcs_entry_lines,
  --   for all the hierarchies in the chosen hierarchy group
  -- Arguments
  --   p_entry_id            Entry ID
  --   p_end_cal_period_id   End Calendar Period ID
  --   p_hierarchy_grp_id    Hierarchy Group ID
  --   p_entity_id           Entity ID associated with process (parent entity in case of rules)
  --   p_start_cal_period_id Start Calendar Period ID
  --   p_currency_code       Currency Code of Entry
  --   p_process_code        Process COde for ther Entry
  --   p_description         Description of the Entry
  --   p_entry_name          Name of the Entry
  --   p_category_code       Category Code
  --   p_balance_type_code   Balance Type Code
  --   p_ledger_id           Ledger ID for Writeback
  --   p_cal_period_name     Calendar Period Name for Writeback
  --   p_conversion_type     Conversion Type for Writeback
  -- Notes
  --

  /*
  ** import_hier_grp_entry
  */
  PROCEDURE import_hier_grp_entry(p_entry_id            IN NUMBER,
                                  p_end_cal_period_id   IN VARCHAR2,
                                  p_hierarchy_grp_id    IN NUMBER,
                                  p_entity_id           IN NUMBER,
                                  p_start_cal_period_id IN VARCHAR2,
                                  p_currency_code       IN VARCHAR2,
                                  p_process_code        IN VARCHAR2,
                                  p_description         IN VARCHAR2,
                                  p_entry_name          IN VARCHAR2,
                                  p_category_code       IN VARCHAR2,
                                  p_balance_type_code   IN VARCHAR2,
                                  p_ledger_id           IN VARCHAR2,
                                  p_cal_period_name     IN VARCHAR2,
                                  p_conversion_type     IN VARCHAR2) IS

    TYPE l_hierarchy_id_tbl_type IS TABLE OF GCS_HIERARCHIES_B.HIERARCHY_ID%TYPE INDEX BY BINARY_INTEGER;
    l_hierarchy_id l_hierarchy_id_tbl_type;

    TYPE l_entry_id_tbl_type IS TABLE OF GCS_ENTRY_HEADERS.ENTRY_ID%TYPE INDEX BY BINARY_INTEGER;
    l_entry_id l_entry_id_tbl_type;

    l_api_name            VARCHAR2(30) := 'IMPORT_HIER_GRP_ENTRY';
    l_end_cal_period_id   NUMBER;
    l_start_cal_period_id NUMBER;
    l_net_to_re_flag      VARCHAR2(1);
    l_entry_type_code     VARCHAR2(30);
    l_balance_code        VARCHAR2(30);
    l_entity_id           NUMBER(15);
    l_precision           NUMBER(15, 5);
    l_year_to_apply_re    NUMBER(4) := NULL;
    l_event_name          VARCHAR2(100) := 'oracle.apps.gcs.transaction.adjustment.update';
    l_event_key           VARCHAR2(100) := NULL;
    l_parameter_list      wf_parameter_list_t;
    l_user_id             NUMBER := fnd_global.user_id;
    l_login_id            NUMBER := fnd_global.login_id;
    l_wf_itemkey          VARCHAR2(100);

  BEGIN

    l_end_cal_period_id   := to_number(p_end_cal_period_id);
    l_start_cal_period_id := to_number(p_start_cal_period_id);

    SAVEPOINT gcs_import_hier_grp_start;

    IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure THEN
      fnd_log.STRING(fnd_log.level_procedure,
                     g_pkg_name || '.' || l_api_name,
                     gcs_utility_pkg.g_module_enter || ' ' || l_api_name ||
                     '() ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
    END IF;

    IF fnd_log.g_current_runtime_level <= fnd_log.level_statement THEN
      fnd_log.STRING(fnd_log.level_statement,
                     g_pkg_name || '.' || l_api_name,
                     'SELECT net_to_re_flag' || g_nl ||
                     'INTO l_net_to_re_flag' || g_nl ||
                     'FROM gcs_categories_b' || g_nl ||
                     'WHERE category_code = ' || p_category_code);
    END IF;

    SELECT net_to_re_flag
      INTO l_net_to_re_flag
      FROM gcs_categories_b
     WHERE category_code = p_category_code;

    IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure THEN
      fnd_log.STRING(fnd_log.level_procedure,
                     g_pkg_name || '.' || l_api_name,
                     'SELECT CASE fcpa_start_year.number_assign_value
                WHEN NVL (fcpa_end_year.number_assign_value, 0)
                   THEN NULL
                ELSE fcpa_start_year.number_assign_value + 1
             END
        INTO l_year_to_apply_re
        FROM fem_cal_periods_attr fcpa_start_year,
             fem_cal_periods_attr fcpa_end_year
       WHERE fcpa_start_year.cal_period_id = ' ||
                      l_start_cal_period_id || '
         AND fcpa_start_year.attribute_id = ' ||
                      g_dimension_attr_info('CAL_PERIOD_ID-ACCOUNTING_YEAR')
                     .attribute_id || '
         AND fcpa_start_year.version_id = ' ||
                      g_dimension_attr_info('CAL_PERIOD_ID-ACCOUNTING_YEAR')
                     .version_id || '
         AND fcpa_end_year.cal_period_id(+) = ' ||
                      l_end_cal_period_id || '
         AND fcpa_end_year.attribute_id(+) = fcpa_start_year.attribute_id
         AND fcpa_end_year.version_id(+) = fcpa_start_year.version_id');
    END IF;

    IF (l_net_to_re_flag = 'N') THEN
      l_year_to_apply_re := NULL;
    ELSIF (l_end_cal_period_id = l_start_cal_period_id) THEN
      l_year_to_apply_re := NULL;
    ELSE
      SELECT CASE fcpa_start_year.number_assign_value
               WHEN NVL(fcpa_end_year.number_assign_value, 0) THEN
                NULL
               ELSE
                fcpa_start_year.number_assign_value + 1
             END
        INTO l_year_to_apply_re
        FROM fem_cal_periods_attr fcpa_start_year,
             fem_cal_periods_attr fcpa_end_year
       WHERE fcpa_start_year.cal_period_id = l_start_cal_period_id
         AND fcpa_start_year.attribute_id =
             g_dimension_attr_info('CAL_PERIOD_ID-ACCOUNTING_YEAR')
      .attribute_id
         AND fcpa_start_year.version_id =
             g_dimension_attr_info('CAL_PERIOD_ID-ACCOUNTING_YEAR')
      .version_id
         AND fcpa_end_year.cal_period_id(+) = l_end_cal_period_id
         AND fcpa_end_year.attribute_id(+) = fcpa_start_year.attribute_id
         AND fcpa_end_year.version_id(+) = fcpa_start_year.version_id;
    END IF;

    -- Retreive the hierarchies , present in teh chosen hierarchy group
    -- Create a new entry ID for each of the hierarchy
    SELECT hierarchy_id, gcs_entry_headers_s.NEXTVAL BULK COLLECT
      INTO l_hierarchy_id, l_entry_id
      FROM gcs_hier_grp_members
     WHERE hierarchy_grp_id = p_hierarchy_grp_id;

    -- Insert the header information of the adjustment into gcs_entry_headers, for all of the hierarchies
    FORALL l_counter IN l_hierarchy_id.FIRST .. l_hierarchy_id.LAST
      INSERT INTO gcs_entry_headers
        (entry_id,
         entry_name,
         hierarchy_id,
         disabled_flag,
         entity_id,
         currency_code,
         balance_type_code,
         start_cal_period_id,
         end_cal_period_id,
         year_to_apply_re,
         description,
         entry_type_code,
         assoc_entry_id,
         processed_run_name,
         category_code,
         process_code,
         creation_date,
         created_by,
         last_update_date,
         last_updated_by,
         last_update_login,
         period_init_entry_flag)
      VALUES
        (l_entry_id(l_counter),
         p_entry_name,
         l_hierarchy_id(l_counter),
         'N',
         p_entity_id,
         p_currency_code,
         p_balance_type_code,
         l_start_cal_period_id,
         l_end_cal_period_id,
         l_year_to_apply_re,
         p_description,
         'MANUAL',
         null,
         null,
         p_category_code,
         p_process_code,
         sysdate,
         l_user_id,
         sysdate,
         l_user_id,
         l_user_id,
         'N');

    -- Insert the lines information of the adjustment into gcs_entry_lines,
    -- for all of the hierarchies

    FORALL l_counter IN l_entry_id.FIRST .. l_entry_id.LAST EXECUTE
                                            IMMEDIATE
                                            'INSERT INTO gcs_entry_lines(
                          entry_id ,
                          line_type_code,
                          description ,
                          company_cost_center_org_id,
                          financial_elem_id,
                          product_id ,
                          natural_account_id,
                          channel_id ,
                          line_item_id,
                          project_id ,
                          customer_id,
                          intercompany_id ,
                          task_id ,
                          user_dim1_id,
                          user_dim2_id,
                          user_dim3_id,
                          user_dim4_id,
                          user_dim5_id,
                          user_dim6_id,
                          user_dim7_id,
                          user_dim8_id,
                          user_dim9_id,
                          user_dim10_id ,
                          xtd_balance_e,
                          ytd_balance_e ,
                          ptd_debit_balance_e ,
                          ptd_credit_balance_e,
                          ytd_debit_balance_e ,
                          ytd_credit_balance_e,
                          creation_date ,
                          created_by,
                          last_update_date,
                          last_updated_by ,
                          last_update_login,
                          entry_line_number )
                  SELECT  :1,
                          line_type_code,
                          description ,
                          company_cost_center_org_id,
                          financial_elem_id,
                          product_id ,
                          natural_account_id,
                          channel_id ,
                          line_item_id,
                          project_id ,
                          customer_id,
                          intercompany_id ,
                          task_id ,
                          user_dim1_id,
                          user_dim2_id,
                          user_dim3_id,
                          user_dim4_id,
                          user_dim5_id,
                          user_dim6_id,
                          user_dim7_id,
                          user_dim8_id,
                          user_dim9_id,
                          user_dim10_id ,
                          xtd_balance_e ,
                          ytd_balance_e ,
                          ptd_debit_balance_e,
                          ptd_credit_balance_e,
                          ytd_debit_balance_e ,
                          ytd_credit_balance_e,
                          creation_date ,
                          created_by,
                          last_update_date,
                          last_updated_by ,
                          last_update_login,
                          entry_line_number
                    FROM  gcs_entry_lines
                   WHERE  entry_id  = :2 '
                                            USING l_entry_id(l_counter),
                                            p_entry_id
      ;

    IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure THEN
      fnd_log.STRING(fnd_log.level_procedure,
                     g_pkg_name || '.' || l_api_name,
                     'SELECT decode(start_cal_period_id, end_cal_period_id, ''ONE_TIME'',
                    ''RECURRING''), year_to_apply_re, hierarchy_id, balance_type_code,
                    entity_id, NVL (minimum_accountable_unit, POWER (10, -PRECISION))' || g_nl ||
                     'INTO l_entry_type_code, l_year_to_apply_re, l_hierarchy_id,
                 l_balance_code, l_entity_id, l_precision' || g_nl ||
                     'FROM fnd_currencies fc, gcs_entry_headers geh' || g_nl ||
                     'WHERE fc.currency_code = geh.currency_code ' || g_nl ||
                     'AND geh.entry_id = ' || l_entry_id(1));
    END IF;

    SELECT DECODE(start_cal_period_id,
                  end_cal_period_id,
                  'ONE_TIME',
                  'RECURRING'),
           NVL(minimum_accountable_unit, POWER(10, -PRECISION))
      INTO l_entry_type_code, l_precision
      FROM fnd_currencies fc, gcs_entry_headers geh
     WHERE fc.currency_code = geh.currency_code
       AND geh.entry_id = l_entry_id(1);

    IF (l_entry_type_code = 'RECURRING') THEN
      FORALL l_counter IN l_entry_id.FIRST .. l_entry_id.LAST
        UPDATE gcs_entry_lines
           SET ytd_debit_balance_e  = ROUND(ytd_debit_balance_e /
                                            l_precision) * l_precision,
               ytd_credit_balance_e = ROUND(ytd_credit_balance_e /
                                            l_precision) * l_precision,
               ytd_balance_e        = ROUND(nvl(ytd_debit_balance_e, 0) /
                                            l_precision) * l_precision -
                                      ROUND(nvl(ytd_credit_balance_e, 0) /
                                            l_precision) * l_precision,
               line_type_code       = CASE WHEN (SELECT feata.dim_attribute_varchar_member
                             FROM fem_ext_acct_types_attr feata,
                                  fem_ln_items_attr       flia
                            WHERE gcs_entry_lines.line_item_id =
                                  flia.line_item_id
                              AND flia.value_set_id =
                                  g_gcs_dimension_info('LINE_ITEM_ID')
                           .associated_value_set_id
                              AND flia.attribute_id =
                                  g_dimension_attr_info('LINE_ITEM_ID-EXTENDED_ACCOUNT_TYPE')
                           .attribute_id
                              AND feata.attribute_id =
                                  g_dimension_attr_info('EXT_ACCOUNT_TYPE_CODE-BASIC_ACCOUNT_TYPE_CODE')
                           .attribute_id
                              AND flia.version_id =
                                  g_dimension_attr_info('LINE_ITEM_ID-EXTENDED_ACCOUNT_TYPE')
                           .version_id
                              AND feata.version_id =
                                  g_dimension_attr_info('EXT_ACCOUNT_TYPE_CODE-BASIC_ACCOUNT_TYPE_CODE')
                           .version_id
                              AND feata.DIM_ATTRIBUTE_NUMERIC_MEMBER IS NULL
                              AND feata.ext_account_type_code =
                                  flia.dim_attribute_varchar_member) IN ('REVENUE', 'EXPENSE') THEN 'PROFIT_LOSS' ELSE 'BALANCE_SHEET' END
         WHERE entry_id = l_entry_id(l_counter);

      IF l_year_to_apply_re IS NOT NULL THEN
        FOR l_counter IN l_entry_id.FIRST .. l_entry_id.LAST LOOP

          gcs_templates_dynamic_pkg.calculate_re(p_entry_id      => l_entry_id(l_counter),
                                                 p_hierarchy_id  => l_hierarchy_id(l_counter),
                                                 p_bal_type_code => p_balance_type_code,
                                                 p_entity_id     => p_entity_id);
        END LOOP;
      END IF;
    ELSE
      FORALL l_counter IN l_entry_id.FIRST .. l_entry_id.LAST
        UPDATE gcs_entry_lines
           SET ytd_debit_balance_e  = ROUND(ytd_debit_balance_e /
                                            l_precision) * l_precision,
               ytd_credit_balance_e = ROUND(ytd_credit_balance_e /
                                            l_precision) * l_precision,
               ytd_balance_e        = ROUND(nvl(ytd_debit_balance_e, 0) /
                                            l_precision) * l_precision -
                                      ROUND(nvl(ytd_credit_balance_e, 0) /
                                            l_precision) * l_precision
         WHERE entry_id = l_entry_id(l_counter);
    END IF;

    FOR l_counter IN l_entry_id.FIRST .. l_entry_id.LAST LOOP
      -- Enhancement for Adjustment Approval Process
      IF fnd_profile.value('AME_INSTALLED_FLAG') = 'Y' THEN
        GCS_ADJ_APPROVAL_WF_PKG.create_gcsadj_process(p_entry_id        => l_entry_id(l_counter),
                                                      p_user_id         => fnd_global.user_id,
                                                      p_user_name       => fnd_global.user_name,
                                                      p_orig_entry_id   => l_entry_id(l_counter),
                                                      p_ledger_id       => to_number(p_ledger_id),
                                                      p_cal_period_name => p_cal_period_name,
                                                      p_conversion_type => p_conversion_type,
                                                      p_writeback_flag  => 'N',
                                                      p_wfitemkey       => l_wf_itemkey);

      ELSE
        wf_event.addparametertolist(p_name          => 'ENTRY_ID',
                                    p_value         => l_entry_id(l_counter),
                                    p_parameterlist => l_parameter_list);
        BEGIN
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
                            g_pkg_name || '.' || l_api_name ||
                            ' RAISE WF_EVENT');
          FND_FILE.NEW_LINE(FND_FILE.OUTPUT);
          wf_event.RAISE(p_event_name => l_event_name,
                         p_event_key  => l_event_key,
                         p_parameters => l_parameter_list);
        EXCEPTION
          WHEN OTHERS THEN
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
                              g_pkg_name || '.' || l_api_name ||
                              ' ERROR : ' || SQLERRM);
            FND_FILE.NEW_LINE(FND_FILE.OUTPUT);
            IF fnd_log.g_current_runtime_level <= fnd_log.level_error THEN
              fnd_log.STRING(fnd_log.level_error,
                             g_pkg_name || '.' || l_api_name,
                             ' wf_event.raise failed ' || ' ' ||
                             TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
            END IF;
        END;
      END IF;

    END LOOP;

    -- Delete the rows in the gcs_entry_lines table (lines information) as the same data
    -- is pushed for all of the hierarchies (present in the chosen hierarchy group).

    DELETE FROM gcs_entry_lines WHERE entry_id = p_entry_id;

    -- Write the appropriate information to the execution report
    IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure THEN
      fnd_log.STRING(fnd_log.level_procedure,
                     g_pkg_name || '.' || l_api_name,
                     gcs_utility_pkg.g_module_success || ' ' || l_api_name ||
                     '() ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
    END IF;

  EXCEPTION
    WHEN OTHERS THEN

      ROLLBACK TO gcs_import_hier_grp_start;
      fnd_message.set_name('GCS', 'GCS_ENTRY_UNEXPECTED_ERR');
      -- Write the appropriate information to the execution report

      IF fnd_log.g_current_runtime_level <= fnd_log.level_error THEN
        fnd_log.STRING(fnd_log.level_error,
                       g_pkg_name || '.' || l_api_name,
                       gcs_utility_pkg.g_module_failure || ' ' || SQLERRM || ' ' ||
                       TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
        fnd_log.STRING(fnd_log.level_error,
                       g_pkg_name || '.' || l_api_name,
                       gcs_utility_pkg.g_module_failure || ' ' ||
                       l_api_name || '() ' ||
                       TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));

        RAISE import_header_error;
      END IF;

  END import_hier_grp_entry;

  /*
  ** import_entry_headers
  */
  PROCEDURE import_entry_headers(p_entry_id            IN NUMBER,
                                 p_end_cal_period_id   IN VARCHAR2,
                                 p_hierarchy_id        IN NUMBER,
                                 p_entity_id           IN NUMBER,
                                 p_start_cal_period_id IN VARCHAR2,
                                 p_currency_code       IN VARCHAR2,
                                 p_process_code        IN VARCHAR2,
                                 p_description         IN VARCHAR2,
                                 p_entry_name          IN VARCHAR2,
                                 p_category_code       IN VARCHAR2,
                                 p_balance_type_code   IN VARCHAR2,
                                 p_new_entry_id        IN NUMBER,
                                 p_entry_lines_id      IN OUT NOCOPY NUMBER,
                                 p_orig_entry_id       IN OUT NOCOPY NUMBER) IS
    l_processed_entry_flag VARCHAR2(1);
    l_existed_entry_flag   VARCHAR2(1);
    l_new_entry_id         NUMBER(15);
    l_end_cal_period_id    NUMBER;
    l_start_cal_period_id  NUMBER;
    -- l_balance_type_code      VARCHAR2 (30);
    l_line_type_code   VARCHAR(30) := NULL;
    l_year_to_apply_re NUMBER(4) := NULL;
    l_errbuf           VARCHAR2(200);
    l_retcode          VARCHAR2(1);
    l_api_name         VARCHAR2(30) := 'IMPORT_ENTRY_HEADERS';

    --Bugfix 5449718: Added check for net to RE Flag
    l_net_to_re_flag VARCHAR2(1);

  BEGIN
    l_end_cal_period_id   := to_number(p_end_cal_period_id);
    l_start_cal_period_id := to_number(p_start_cal_period_id);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
                      g_pkg_name || '.' || l_api_name || ' ENTER');
    FND_FILE.NEW_LINE(FND_FILE.OUTPUT);
    IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure THEN
      fnd_log.STRING(fnd_log.level_procedure,
                     g_pkg_name || '.' || l_api_name,
                     gcs_utility_pkg.g_module_enter || ' ' || l_api_name ||
                     '() ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
    END IF;
    -- In case of an error, we will roll back to this point in time.
    SAVEPOINT gcs_entry_upload_headers_start;
    -- Bug fix 3805520
    -- only when end-start cross year end boundary
    IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure THEN
      fnd_log.STRING(fnd_log.level_procedure,
                     g_pkg_name || '.' || l_api_name,
                     'SELECT CASE fcpa_start_year.number_assign_value
                WHEN NVL (fcpa_end_year.number_assign_value, 0)
                   THEN NULL
                ELSE fcpa_start_year.number_assign_value + 1
             END
        INTO l_year_to_apply_re
        FROM fem_cal_periods_attr fcpa_start_year,
             fem_cal_periods_attr fcpa_end_year
       WHERE fcpa_start_year.cal_period_id = ' ||
                      l_start_cal_period_id || '
         AND fcpa_start_year.attribute_id = ' ||
                      g_dimension_attr_info('CAL_PERIOD_ID-ACCOUNTING_YEAR')
                     .attribute_id || '
         AND fcpa_start_year.version_id = ' ||
                      g_dimension_attr_info('CAL_PERIOD_ID-ACCOUNTING_YEAR')
                     .version_id || '
         AND fcpa_end_year.cal_period_id(+) = ' ||
                      l_end_cal_period_id || '
         AND fcpa_end_year.attribute_id(+) = fcpa_start_year.attribute_id
         AND fcpa_end_year.version_id(+) = fcpa_start_year.version_id');
    END IF;
    /***
     -- determine the balance type
     IF fnd_log.g_current_runtime_level <= fnd_log.level_statement THEN
        fnd_log.STRING(fnd_log.level_statement,
               g_pkg_name || '.' || l_api_name,
                  'SELECT DECODE (COUNT (entry_id), 0, ''ACTUAL'', ''ADB'')'
               || g_nl
               || 'INTO l_balance_type_code'
               || g_nl
               || 'FROM gcs_entry_lines'
               || g_nl
               || 'WHERE entry_id = '||p_new_entry_id
               || g_nl
               || 'AND FINANCIAL_ELEM_ID = 140'
              );
     END IF;
     SELECT DECODE (COUNT (entry_id), 0, 'ACTUAL', 'ADB')
       INTO l_balance_type_code
       FROM gcs_entry_lines
      WHERE entry_id = p_new_entry_id AND financial_elem_id = 140;
    ***/

    --Bugfix 5449718: Added check for net to re flag before populated l_year_to_apply_re
    BEGIN

      SELECT net_to_re_flag
        INTO l_net_to_re_flag
        FROM gcs_categories_b
       WHERE category_code = p_category_code;

      IF (l_net_to_re_flag = 'N') THEN
        l_year_to_apply_re := NULL;
      ELSIF (l_end_cal_period_id = l_start_cal_period_id) THEN
        l_year_to_apply_re := NULL;
      ELSE
        SELECT CASE fcpa_start_year.number_assign_value
                 WHEN NVL(fcpa_end_year.number_assign_value, 0) THEN
                  NULL
                 ELSE
                  fcpa_start_year.number_assign_value + 1
               END
          INTO l_year_to_apply_re
          FROM fem_cal_periods_attr fcpa_start_year,
               fem_cal_periods_attr fcpa_end_year
         WHERE fcpa_start_year.cal_period_id = l_start_cal_period_id
           AND fcpa_start_year.attribute_id =
               g_dimension_attr_info('CAL_PERIOD_ID-ACCOUNTING_YEAR')
        .attribute_id
           AND fcpa_start_year.version_id =
               g_dimension_attr_info('CAL_PERIOD_ID-ACCOUNTING_YEAR')
        .version_id
           AND fcpa_end_year.cal_period_id(+) = l_end_cal_period_id
           AND fcpa_end_year.attribute_id(+) = fcpa_start_year.attribute_id
           AND fcpa_end_year.version_id(+) = fcpa_start_year.version_id;
      END IF;

    END;

    BEGIN
      SELECT 'Y'
        INTO l_existed_entry_flag
        FROM gcs_entry_headers geh
       WHERE geh.entry_id = p_entry_id;
      -- case 1: this is a newly created entry
      -- we'll just do an insertion
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        insert_entry_header(p_entry_id            => p_new_entry_id,
                            p_hierarchy_id        => p_hierarchy_id,
                            p_entity_id           => p_entity_id,
                            p_year_to_apply_re    => l_year_to_apply_re,
                            p_start_cal_period_id => l_start_cal_period_id,
                            p_end_cal_period_id   => l_end_cal_period_id,
                            p_entry_type_code     => 'MANUAL',
                            p_balance_type_code   => p_balance_type_code,
                            p_currency_code       => p_currency_code,
                            p_process_code        => p_process_code,
                            p_description         => p_description,
                            p_entry_name          => p_entry_name,
                            p_category_code       => p_category_code,
                            x_errbuf              => l_errbuf,
                            x_retcode             => l_retcode);
        p_entry_lines_id := p_new_entry_id;
        p_orig_entry_id  := NULL;
        RETURN;
    END; -- end of case 1
    IF l_existed_entry_flag = 'Y' THEN
      -- case 2: update an existing entry which has never been process before
      -- we simply update this entry
      BEGIN
        SELECT 'Y'
          INTO l_processed_entry_flag
          FROM DUAL
         WHERE EXISTS (SELECT run_detail_id
                  FROM gcs_cons_eng_run_dtls gcerd
                 WHERE gcerd.entry_id = p_entry_id);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          IF fnd_log.g_current_runtime_level <= fnd_log.level_error THEN
            fnd_log.STRING(fnd_log.level_error,
                           g_pkg_name || '.' || l_api_name,
                           'UPDATE gcs_entry_headers' || g_nl ||
                           'SET balance_type_code = ' ||
                           p_balance_type_code || ',' || g_nl ||
                           ' end_cal_period_id = ' || l_end_cal_period_id || ',' || g_nl ||
                           ' entry_type_code = MANUAL,' || g_nl ||
                           ' hierarchy_id = ' || p_hierarchy_id || ',' || g_nl ||
                           ' entity_id = ' || p_entity_id || ',' || g_nl ||
                           ' start_cal_period_id = ' ||
                           l_start_cal_period_id || ',' || g_nl ||
                           ' currency_code = ' || p_currency_code || ',' || g_nl ||
                           ' process_code = ' || p_process_code || ',' || g_nl ||
                           ' description = ' || p_description || ',' || g_nl ||
                           ' entry_name = ' || p_entry_name || ',' || g_nl ||
                           ' category_code = ' || p_category_code || ',' || g_nl ||
                           ' last_update_date = SYSDATE,' || g_nl ||
                           ' last_updated_by = ' || fnd_global.user_id ||
                           ' WHERE entry_id = ' || p_entry_id);
          END IF;
          UPDATE gcs_entry_headers
             SET balance_type_code   = p_balance_type_code,
                 end_cal_period_id   = l_end_cal_period_id,
                 year_to_apply_re    = l_year_to_apply_re,
                 entry_type_code     = 'MANUAL',
                 hierarchy_id        = p_hierarchy_id,
                 entity_id           = p_entity_id,
                 start_cal_period_id = l_start_cal_period_id,
                 currency_code       = p_currency_code,
                 process_code        = p_process_code,
                 description         = p_description,
                 entry_name          = p_entry_name,
                 category_code       = p_category_code,
                 last_update_date    = SYSDATE,
                 last_updated_by     = fnd_global.user_id
           WHERE entry_id = p_entry_id;
          -- delete old entry lines and flag new lines as loaded
          IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure THEN
            fnd_log.STRING(fnd_log.level_procedure,
                           g_pkg_name || '.' || l_api_name,
                           'DELETE FROM gcs_entry_lines' || g_nl ||
                           'WHERE entry_id = ' || p_entry_id);
          END IF;
          DELETE FROM gcs_entry_lines WHERE entry_id = p_entry_id;
          IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure THEN
            fnd_log.STRING(fnd_log.level_procedure,
                           g_pkg_name || '.' || l_api_name,
                           'UPDATE gcs_entry_lines' || g_nl ||
                           'set entry_id = ' || p_entry_id || g_nl ||
                           'WHERE entry_id = ' || p_new_entry_id);
          END IF;
          UPDATE gcs_entry_lines
             SET entry_id = p_entry_id
           WHERE entry_id = p_new_entry_id;
          p_entry_lines_id := p_entry_id;
          p_orig_entry_id  := p_entry_id;
      END;
    END IF; -- end of case 2
    -- case 3: update an existing entry which has been process before
    -- we disable the existing entry and create a new one
    IF l_processed_entry_flag = 'Y' THEN
      IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure THEN
        fnd_log.STRING(fnd_log.level_procedure,
                       g_pkg_name || '.' || l_api_name,
                       'UPDATE gcs_entry_headers' || g_nl ||
                       'SET disabled_flag = ''Y'', entry_name = substr(entry_name, 0, 55) || '' OLD -'' || ' ||
                       p_new_entry_id || g_nl || 'WHERE entry_id = ' ||
                       p_entry_id);
      END IF;
      UPDATE gcs_entry_headers
         SET disabled_flag = 'Y',
             entry_name    = substr(entry_name, 0, 55) || ' OLD -' ||
                             p_new_entry_id,
             --Bugfix 6351281: Update the disabled cal period id as well
             disabled_cal_period_id = start_cal_period_id
       WHERE entry_id = p_entry_id;
      insert_entry_header(p_entry_id            => p_new_entry_id,
                          p_hierarchy_id        => p_hierarchy_id,
                          p_entity_id           => p_entity_id,
                          p_year_to_apply_re    => l_year_to_apply_re,
                          p_start_cal_period_id => l_start_cal_period_id,
                          p_end_cal_period_id   => l_end_cal_period_id,
                          p_entry_type_code     => 'MANUAL',
                          p_balance_type_code   => p_balance_type_code,
                          p_currency_code       => p_currency_code,
                          p_process_code        => p_process_code,
                          p_description         => p_description,
                          p_entry_name          => p_entry_name,
                          p_category_code       => p_category_code,
                          x_errbuf              => l_errbuf,
                          x_retcode             => l_retcode);
      p_entry_lines_id := p_new_entry_id;
      p_orig_entry_id  := p_entry_id;
    END IF; -- end of case 3
    -- Write the appropriate information to the execution report
    IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure THEN
      fnd_log.STRING(fnd_log.level_procedure,
                     g_pkg_name || '.' || l_api_name,
                     gcs_utility_pkg.g_module_success || ' ' || l_api_name ||
                     '() ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
    END IF;
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
                      g_pkg_name || '.' || l_api_name || ' EXIT');
    FND_FILE.NEW_LINE(FND_FILE.OUTPUT);
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO gcs_entry_upload_headers_start;
      fnd_message.set_name('GCS', 'GCS_ENTRY_UNEXPECTED_ERR');
      -- Write the appropriate information to the execution report
      IF fnd_log.g_current_runtime_level <= fnd_log.level_error THEN
        fnd_log.STRING(fnd_log.level_error,
                       g_pkg_name || '.' || l_api_name,
                       gcs_utility_pkg.g_module_failure || ' ' ||
                       l_api_name || '() ' ||
                       TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
        RAISE import_header_error;
      END IF;
  END import_entry_headers;

  -- Procedure
  --   get_entry_header()
  -- Purpose
  --   generates a unique name, and appropriate description for all automated GCS II processes
  -- Arguments
  --   p_category_code  Category Code for Data Prep, Translation, Aggregation,Acquisitions and Disposals,
  --                      Pre-Intercompany, Intercompany, Post-Intercompany,
  --                      Minority Interest, Post-Minority Interest
  --   p_entry_id       Entry ID
  --   p_entity_id      Entity ID associated with process (parent entity in case of rules)
  --   p_currency_code  Currency Code of Entry
  --   p_rule_id        Required Only for Automated Rules
  -- Notes
  --
  PROCEDURE get_entry_header(p_category_code VARCHAR2,
                             p_xlate_flag    VARCHAR2,
                             p_entry_id      NUMBER,
                             p_entity_id     NUMBER,
                             p_currency_code VARCHAR2,
                             p_rule_id       NUMBER DEFAULT NULL,
                             p_entry_header  IN OUT NOCOPY r_entry_header) IS
    l_entity_name       VARCHAR2(150);
    l_rule_name         VARCHAR2(80);
    l_entry_description VARCHAR2(240);
    l_temp              VARCHAR2(1);
    l_api_name          VARCHAR2(30) := 'GET_ENTRY_HEADER';
  BEGIN
    IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure THEN
      fnd_log.STRING(fnd_log.level_procedure,
                     g_pkg_name || '.' || l_api_name,
                     gcs_utility_pkg.g_module_enter || ' ' || l_api_name ||
                     '() ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
    END IF;
    IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure THEN
      fnd_log.STRING(fnd_log.level_procedure,
                     g_pkg_name || '.' || l_api_name,
                     'SELECT entity_name INTO l_entity_name ' ||
                     ' FROM fem_entities_vl WHERE entity_id = ' ||
                     p_entity_id);
    END IF;
    BEGIN
      SELECT entity_name
        INTO l_entity_name
        FROM fem_entities_vl
       WHERE entity_id = p_entity_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE invalid_entity_error;
    END;
    IF (p_category_code = 'DATAPREPARATION') THEN
      l_entry_description := 'Data Preparation of ' || l_entity_name;
    ELSIF (p_category_code = 'TRANSLATION') THEN
      l_entry_description := 'Translation of ' || l_entity_name || ' to ' ||
                             p_currency_code;
    ELSIF (p_category_code = 'AGGREGATION') THEN
      l_entry_description := 'Aggregation of ' || l_entity_name;
    ELSIF (p_rule_id is not null) THEN
      BEGIN
        IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure THEN
          fnd_log.STRING(fnd_log.level_procedure,
                         g_pkg_name || '.' || l_api_name,
                         'SELECT rule_name INTO l_rule_name ' ||
                         ' FROM gcs_elim_rules_vl WHERE rule_id = ' ||
                         p_rule_id);
        END IF;
        SELECT rule_name
          INTO l_rule_name
          FROM gcs_elim_rules_vl
         WHERE rule_id = p_rule_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RAISE invalid_rule_error;
      END;
      l_entry_description := substr(l_rule_name || ' Executed For ' ||
                                    l_entity_name,
                                    0,
                                    239);
    END IF;
    p_entry_header.NAME        := p_entry_id;
    p_entry_header.description := l_entry_description;
    IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure THEN
      fnd_log.STRING(fnd_log.level_procedure,
                     g_pkg_name || '.' || l_api_name,
                     'return p_entry_header.name = ' || p_entry_id ||
                     ' and p_entry_header.description = ' ||
                     l_entry_description);
    END IF;
    IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure THEN
      fnd_log.STRING(fnd_log.level_procedure,
                     g_pkg_name || '.' || l_api_name,
                     gcs_utility_pkg.g_module_success || ' ' || l_api_name ||
                     '() ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
    END IF;
  END get_entry_header;

  PROCEDURE insert_entry_header(x_errbuf                 OUT NOCOPY VARCHAR2,
                                x_retcode                OUT NOCOPY VARCHAR2,
                                p_entry_id               IN NUMBER,
                                p_hierarchy_id           IN NUMBER,
                                p_entity_id              IN NUMBER,
                                p_year_to_apply_re       IN NUMBER,
                                p_start_cal_period_id    IN NUMBER,
                                p_end_cal_period_id      IN NUMBER,
                                p_entry_type_code        IN VARCHAR2,
                                p_balance_type_code      IN VARCHAR2,
                                p_currency_code          IN VARCHAR2,
                                p_process_code           IN VARCHAR2,
                                p_category_code          IN VARCHAR2,
                                p_entry_name             IN VARCHAR2,
                                p_description            IN VARCHAR2,
                                p_period_init_entry_flag IN VARCHAR2 DEFAULT 'N') IS
    l_api_name VARCHAR2(30) := 'INSERT_ENTRY_HEADER';
  BEGIN
    SAVEPOINT gcs_insert_header_start;
    IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure THEN
      fnd_log.STRING(fnd_log.level_procedure,
                     g_pkg_name || '.' || l_api_name,
                     gcs_utility_pkg.g_module_enter || ' ' || l_api_name ||
                     '() ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
    END IF;
    IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure THEN
      fnd_log.STRING(fnd_log.level_procedure,
                     g_pkg_name || '.' || l_api_name,
                     'INSERT INTO gcs_entry_headers' || g_nl ||
                     '(entry_id, entry_name, hierarchy_id, disabled_flag,' || g_nl ||
                     'entity_id, currency_code, balance_type_code,' || g_nl ||
                     'start_cal_period_id, end_cal_period_id,' || g_nl ||
                     'year_to_apply_re, description, entry_type_code,' || g_nl ||
                     'assoc_entry_id, processed_run_name, category_code,' || g_nl ||
                     'process_code, creation_date, created_by,' || g_nl ||
                     'last_update_date, last_updated_by, last_update_login, period_init_entry_flag' || g_nl ||
                     ')VALUES (' || p_entry_id || ', ''' || p_entry_name ||
                     ''', ' || p_hierarchy_id || ', ''N'',' || g_nl ||
                     p_entity_id || ', ''' || p_currency_code || ''', ''' ||
                     p_balance_type_code || ''', ' || g_nl ||
                     p_start_cal_period_id || ', ' || p_end_cal_period_id || ', ' || g_nl ||
                     p_year_to_apply_re || ', ''' || p_description ||
                     ''', ''' || p_entry_type_code || ''', ' || g_nl ||
                     'NULL, NULL, ''' || p_category_code || ''', ''' || g_nl ||
                     p_process_code || ''', SYSDATE, ' ||
                     fnd_global.user_id || ', ' || g_nl || 'SYSDATE, ' ||
                     fnd_global.user_id || ', ' || fnd_global.login_id ||
                     ', ''' || p_period_init_entry_flag || ''');');
    END IF;
    INSERT INTO gcs_entry_headers
      (entry_id,
       entry_name,
       hierarchy_id,
       disabled_flag,
       entity_id,
       currency_code,
       balance_type_code,
       start_cal_period_id,
       end_cal_period_id,
       year_to_apply_re,
       description,
       entry_type_code,
       assoc_entry_id,
       processed_run_name,
       category_code,
       process_code,
       creation_date,
       created_by,
       last_update_date,
       last_updated_by,
       last_update_login,
       period_init_entry_flag)
    VALUES
      (p_entry_id,
       p_entry_name,
       p_hierarchy_id,
       'N',
       p_entity_id,
       p_currency_code,
       p_balance_type_code,
       p_start_cal_period_id,
       p_end_cal_period_id,
       p_year_to_apply_re,
       p_description,
       p_entry_type_code,
       NULL,
       NULL,
       p_category_code,
       p_process_code,
       SYSDATE,
       fnd_global.user_id,
       SYSDATE,
       fnd_global.user_id,
       fnd_global.login_id,
       p_period_init_entry_flag);
    x_retcode := fnd_api.g_ret_sts_success;
    IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure THEN
      fnd_log.STRING(fnd_log.level_procedure,
                     g_pkg_name || '.' || l_api_name,
                     gcs_utility_pkg.g_module_success || ' ' || l_api_name ||
                     '() ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
    END IF;
  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      ROLLBACK TO gcs_insert_header_start;
      fnd_message.set_name('GCS', 'GCS_INVALID_ENTRY_ID');
      x_errbuf  := fnd_message.get;
      x_retcode := fnd_api.g_ret_sts_error;
      -- Write the appropriate information to the execution report
      IF fnd_log.g_current_runtime_level <= fnd_log.level_error THEN
        fnd_log.STRING(fnd_log.level_error,
                       g_pkg_name || '.' || l_api_name,
                       gcs_utility_pkg.g_module_failure || ' ' || x_errbuf ||
                       TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
      END IF;
  END insert_entry_header;

  PROCEDURE create_entry_header(x_errbuf                 OUT NOCOPY VARCHAR2,
                                x_retcode                OUT NOCOPY VARCHAR2,
                                p_entry_id               IN OUT NOCOPY NUMBER,
                                p_hierarchy_id           IN NUMBER,
                                p_entity_id              IN NUMBER,
                                p_start_cal_period_id    IN NUMBER,
                                p_end_cal_period_id      IN NUMBER,
                                p_entry_type_code        IN VARCHAR2,
                                p_balance_type_code      IN VARCHAR2,
                                p_currency_code          IN VARCHAR2,
                                p_process_code           IN VARCHAR2,
                                p_category_code          IN VARCHAR2,
                                p_xlate_flag             IN VARCHAR2 DEFAULT 'N',
                                p_rule_id                IN NUMBER DEFAULT NULL,
                                p_period_init_entry_flag IN VARCHAR2 DEFAULT 'N') IS
    l_header_info r_entry_header;
    l_api_name    VARCHAR2(30) := 'CREATE_ENTRY_HEADER';
  BEGIN
    SAVEPOINT gcs_create_header_start;
    IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure THEN
      fnd_log.STRING(fnd_log.level_procedure,
                     g_pkg_name || '.' || l_api_name,
                     gcs_utility_pkg.g_module_enter || ' ' || l_api_name ||
                     '() ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
    END IF;
    IF p_entry_id IS NULL THEN
      SELECT gcs_entry_headers_s.NEXTVAL INTO p_entry_id FROM DUAL;
    END IF;
    get_entry_header(p_category_code => p_category_code,
                     p_xlate_flag    => p_xlate_flag,
                     p_entry_id      => p_entry_id,
                     p_entity_id     => p_entity_id,
                     p_currency_code => p_currency_code,
                     p_rule_id       => p_rule_id,
                     p_entry_header  => l_header_info);
    insert_entry_header(p_entry_id               => p_entry_id,
                        p_hierarchy_id           => p_hierarchy_id,
                        p_entity_id              => p_entity_id,
                        p_year_to_apply_re       => NULL,
                        p_start_cal_period_id    => p_start_cal_period_id,
                        p_end_cal_period_id      => p_end_cal_period_id,
                        p_entry_type_code        => p_entry_type_code,
                        p_balance_type_code      => p_balance_type_code,
                        p_currency_code          => p_currency_code,
                        p_process_code           => p_process_code,
                        p_description            => l_header_info.description,
                        p_entry_name             => l_header_info.NAME,
                        p_category_code          => p_category_code,
                        x_errbuf                 => x_errbuf,
                        x_retcode                => x_retcode,
                        p_period_init_entry_flag => p_period_init_entry_flag);
    IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure THEN
      fnd_log.STRING(fnd_log.level_procedure,
                     g_pkg_name || '.' || l_api_name,
                     gcs_utility_pkg.g_module_success || ' ' || l_api_name ||
                     '() ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
    END IF;
  EXCEPTION
    WHEN invalid_entity_error THEN
      ROLLBACK TO gcs_create_header_start;
      fnd_message.set_name('GCS', 'GCS_INVALID_ENTITY_ERR');
      x_errbuf  := fnd_message.get;
      x_retcode := fnd_api.g_ret_sts_unexp_error;
      -- Write the appropriate information to the execution report
      IF fnd_log.g_current_runtime_level <= fnd_log.level_error THEN
        fnd_log.STRING(fnd_log.level_error,
                       g_pkg_name || '.' || l_api_name,
                       gcs_utility_pkg.g_module_failure || ' ' || x_errbuf ||
                       TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
      END IF;
    WHEN invalid_rule_error THEN
      ROLLBACK TO gcs_create_header_start;
      fnd_message.set_name('GCS', 'GCS_INVALID_RULE_ERR');
      x_errbuf  := fnd_message.get;
      x_retcode := fnd_api.g_ret_sts_unexp_error;
      -- Write the appropriate information to the execution report
      IF fnd_log.g_current_runtime_level <= fnd_log.level_error THEN
        fnd_log.STRING(fnd_log.level_error,
                       g_pkg_name || '.' || l_api_name,
                       gcs_utility_pkg.g_module_failure || ' ' || x_errbuf ||
                       TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
      END IF;
    WHEN OTHERS THEN
      ROLLBACK TO gcs_create_header_start;
      fnd_message.set_name('GCS', 'GCS_ENTRY_UNEXPECTED_ERR');
      x_errbuf  := fnd_message.get;
      x_retcode := fnd_api.g_ret_sts_unexp_error;
      -- Write the appropriate information to the execution report
      IF fnd_log.g_current_runtime_level <= fnd_log.level_error THEN
        fnd_log.STRING(fnd_log.level_error,
                       g_pkg_name || '.' || l_api_name,
                       gcs_utility_pkg.g_module_failure || ' ' || x_errbuf ||
                       TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
      END IF;
  END create_entry_header;
  --
  -- PUBLIC PROCEDURES
  --
  ---------------------------------------------------------------------------
  /*
  ** Manual_Entries_Import
  */
  PROCEDURE manual_entries_import(p_entry_id_char       IN VARCHAR2,
                                  p_end_cal_period_id   IN VARCHAR2,
                                  p_hierarchy_id        IN NUMBER,
                                  p_entity_id_char      IN VARCHAR2,
                                  p_start_cal_period_id IN VARCHAR2,
                                  p_currency_code       IN VARCHAR2,
                                  p_process_code        IN VARCHAR2,
                                  p_description         IN VARCHAR2,
                                  p_entry_name          IN VARCHAR2,
                                  p_category_code       IN VARCHAR2,
                                  p_balance_type_code   IN VARCHAR2,
                                  p_writeback_needed    IN VARCHAR2,
                                  p_ledger_id           IN VARCHAR2,
                                  p_cal_period_name     IN VARCHAR2,
                                  p_conversion_type     IN VARCHAR2,
                                  p_new_entry_id        IN NUMBER,
                                  p_hierarchy_grp_flag  IN VARCHAR2) IS
    l_entry_type_code  VARCHAR2(30);
    l_balance_code     VARCHAR2(30);
    l_hierarchy_id     NUMBER(15);
    l_entry_id         NUMBER(15);
    l_entity_id        NUMBER(15);
    l_precision        NUMBER(15, 5);
    l_year_to_apply_re NUMBER(4) := NULL;
    l_event_name       VARCHAR2(100) := 'oracle.apps.gcs.transaction.adjustment.update';
    l_event_key        VARCHAR2(100) := NULL;
    l_parameter_list   wf_parameter_list_t;
    l_orig_entry_id    NUMBER(15);
    l_api_name         VARCHAR2(30) := 'MANUAL_ENTRIES_IMPORT';
    l_request_id       NUMBER(15);
    p_entry_id         NUMBER(15) := TO_NUMBER(p_entry_id_char);
    p_wf_itemkey       VARCHAR2(100);
    p_entity_id        NUMBER(15) := TO_NUMBER(p_entity_id_char);

  BEGIN
    -- In case of an error, we will roll back to this point in time.

    SAVEPOINT gcs_me_import_start;

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
                      g_pkg_name || '.' || l_api_name || ' ENTER');
    FND_FILE.NEW_LINE(FND_FILE.OUTPUT);

    IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure THEN
      fnd_log.STRING(fnd_log.level_procedure,
                     g_pkg_name || '.' || l_api_name,
                     gcs_utility_pkg.g_module_enter || ' p_entry_id = ' ||
                     p_entry_id || ' p_end_cal_period_id = ' ||
                     p_end_cal_period_id || ' p_hierarchy_id = ' ||
                     p_hierarchy_id || ' p_entity_id = ' || p_entity_id ||
                     ' p_start_cal_period_id = ' || p_start_cal_period_id ||
                     ' p_currency_code = ' || p_currency_code ||
                     ' p_process_code = ' || p_process_code ||
                     ' p_description = ' || p_description ||
                     ' p_entry_name = ' || p_entry_name ||
                     ' p_category_code = ' || p_category_code ||
                     ' p_balance_type_code = ' || p_balance_type_code ||
                     ' p_writeback_needed = ' || p_writeback_needed ||
                     ' p_ledger_id  = ' || p_ledger_id ||
                     ' p_cal_period_name = ' || p_cal_period_name ||
                     ' p_conversion_type = ' || p_conversion_type ||
                     ' p_new_entry_id = ' || p_new_entry_id ||
                     ' p_hierarchy_grp_flag = ' || p_hierarchy_grp_flag || ' ' ||
                     TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
    END IF;

    -- Enhancement : 6416736, Chack if the adjustments are submitted for a stand alone hierarchy or a hierarchy group.

    IF (p_hierarchy_grp_flag = 'Y') THEN
      -- Adjustment is submitted for a hierarchy group
      import_hier_grp_entry(p_new_entry_id,
                            p_end_cal_period_id,
                            p_hierarchy_id,
                            p_entity_id,
                            p_start_cal_period_id,
                            p_currency_code,
                            p_process_code,
                            p_description,
                            p_entry_name,
                            p_category_code,
                            p_balance_type_code,
                            p_ledger_id,
                            p_cal_period_name,
                            p_conversion_type);
    ELSE
      -- Adjustment is submitted for a stand alone hierarchy.

      import_entry_headers(p_entry_id,
                           p_end_cal_period_id,
                           p_hierarchy_id,
                           p_entity_id,
                           p_start_cal_period_id,
                           p_currency_code,
                           p_process_code,
                           p_description,
                           p_entry_name,
                           p_category_code,
                           p_balance_type_code,
                           p_new_entry_id,
                           l_entry_id,
                           l_orig_entry_id);
      IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure THEN
        fnd_log.STRING(fnd_log.level_procedure,
                       g_pkg_name || '.' || l_api_name,
                       'SELECT decode(start_cal_period_id, end_cal_period_id, ''ONE_TIME'',
                    ''RECURRING''), year_to_apply_re, hierarchy_id, balance_type_code,
                    entity_id, NVL (minimum_accountable_unit, POWER (10, -PRECISION))' || g_nl ||
                       'INTO l_entry_type_code, l_year_to_apply_re, l_hierarchy_id,
                 l_balance_code, l_entity_id, l_precision' || g_nl ||
                       'FROM fnd_currencies fc, gcs_entry_headers geh' || g_nl ||
                       'WHERE fc.currency_code = geh.currency_code ' || g_nl ||
                       'AND geh.entry_id = ' || l_entry_id);
      END IF;

      SELECT DECODE(start_cal_period_id,
                    end_cal_period_id,
                    'ONE_TIME',
                    'RECURRING'),
             year_to_apply_re,
             hierarchy_id,
             balance_type_code,
             entity_id,
             NVL(minimum_accountable_unit, POWER(10, -PRECISION))
        INTO l_entry_type_code,
             l_year_to_apply_re,
             l_hierarchy_id,
             l_balance_code,
             l_entity_id,
             l_precision
        FROM fnd_currencies fc, gcs_entry_headers geh
       WHERE fc.currency_code = geh.currency_code
         AND geh.entry_id = l_entry_id;

      IF (l_entry_type_code = 'RECURRING') THEN
        -- update the line_type_code for recurring entry lines
        IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure THEN
          fnd_log.STRING(fnd_log.level_procedure,
                         g_pkg_name || '.' || l_api_name,
                         'UPDATE gcs_entry_lines' || g_nl ||
                          'SET ytd_debit_balance_e = ROUND (ytd_debit_balance_e / l_precision)
                              * l_precision, ' || g_nl ||
                          'ytd_credit_balance_e = ROUND (ytd_credit_balance_e / l_precision)
                             * l_precision, ' || g_nl ||
                          'ytd_balance_e = ROUND (nvl(ytd_debit_balance_e, 0) / l_precision) * l_precision ' || g_nl ||
                          '- ROUND (nvl(ytd_credit_balance_e, 0) / l_precision) * l_precision, ' || g_nl ||
                          ' line_type_code =
                         CASE
                            WHEN (SELECT feata.dim_attribute_varchar_member
                                    FROM fem_ext_acct_types_attr feata,
                                         fem_ln_items_attr flia
                                   WHERE gcs_entry_lines.line_item_id = flia.line_item_id
                  AND flia.attribute_id = ' ||
                          g_dimension_attr_info('LINE_ITEM_ID-EXTENDED_ACCOUNT_TYPE')
                         .attribute_id || '
                  AND feata.attribute_id = ' ||
                          g_dimension_attr_info('EXT_ACCOUNT_TYPE_CODE-BASIC_ACCOUNT_TYPE_CODE')
                         .attribute_id || '
                  AND flia.version_id = ' ||
                          g_dimension_attr_info('LINE_ITEM_ID-EXTENDED_ACCOUNT_TYPE')
                         .version_id || '
                  AND feata.version_id = ' ||
                          g_dimension_attr_info('EXT_ACCOUNT_TYPE_CODE-BASIC_ACCOUNT_TYPE_CODE')
                         .version_id || '
                  AND feata.DIM_ATTRIBUTE_NUMERIC_MEMBER IS NULL
                                     AND flia.value_set_id =' ||
                          g_gcs_dimension_info('LINE_ITEM_ID')
                         .associated_value_set_id ||
                          '              AND feata.ext_account_type_code =
                                                   flia.dim_attribute_varchar_member) IN
                                                             (''REVENUE'', ''EXPENSE'')
                               THEN ''PROFIT_LOSS''
                            ELSE ''BALANCE_SHEET''
                         END ' ||
                          'WHERE entry_id = ' || l_entry_id);
        END IF;

        UPDATE gcs_entry_lines
           SET ytd_debit_balance_e  = ROUND(ytd_debit_balance_e /
                                            l_precision) * l_precision,
               ytd_credit_balance_e = ROUND(ytd_credit_balance_e /
                                            l_precision) * l_precision,
               ytd_balance_e        = ROUND(nvl(ytd_debit_balance_e, 0) /
                                            l_precision) * l_precision -
                                      ROUND(nvl(ytd_credit_balance_e, 0) /
                                            l_precision) * l_precision,
               line_type_code       = CASE WHEN (SELECT feata.dim_attribute_varchar_member
                             FROM fem_ext_acct_types_attr feata,
                                  fem_ln_items_attr       flia
                            WHERE gcs_entry_lines.line_item_id =
                                  flia.line_item_id
                              AND flia.value_set_id =
                                  g_gcs_dimension_info('LINE_ITEM_ID')
                           .associated_value_set_id
                              AND flia.attribute_id =
                                  g_dimension_attr_info('LINE_ITEM_ID-EXTENDED_ACCOUNT_TYPE')
                           .attribute_id
                              AND feata.attribute_id =
                                  g_dimension_attr_info('EXT_ACCOUNT_TYPE_CODE-BASIC_ACCOUNT_TYPE_CODE')
                           .attribute_id
                              AND flia.version_id =
                                  g_dimension_attr_info('LINE_ITEM_ID-EXTENDED_ACCOUNT_TYPE')
                           .version_id
                              AND feata.version_id =
                                  g_dimension_attr_info('EXT_ACCOUNT_TYPE_CODE-BASIC_ACCOUNT_TYPE_CODE')
                           .version_id
                              AND feata.DIM_ATTRIBUTE_NUMERIC_MEMBER IS NULL
                              AND feata.ext_account_type_code =
                                  flia.dim_attribute_varchar_member) IN ('REVENUE', 'EXPENSE') THEN 'PROFIT_LOSS' ELSE 'BALANCE_SHEET' END
         WHERE entry_id = l_entry_id;

        IF l_year_to_apply_re IS NOT NULL THEN
          gcs_templates_dynamic_pkg.calculate_re(p_entry_id      => l_entry_id,
                                                 p_hierarchy_id  => l_hierarchy_id,
                                                 p_bal_type_code => l_balance_code,
                                                 p_entity_id     => l_entity_id);
        END IF;
      ELSE
        IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure THEN
          fnd_log.STRING(fnd_log.level_procedure,
                         g_pkg_name || '.' || l_api_name,
                         'UPDATE gcs_entry_lines' || g_nl ||
                         'SET  ytd_debit_balance_e = ROUND (ytd_debit_balance_e / l_precision) * l_precision, ' || g_nl ||
                         'ytd_credit_balance_e = ROUND (ytd_credit_balance_e / l_precision) * l_precision, ' || g_nl ||
                         'ytd_balance_e = ROUND (nvl(ytd_debit_balance_e, 0) / l_precision) * l_precision ' || g_nl ||
                         '- ROUND (nvl(ytd_credit_balance_e, 0) / l_precision) * l_precision, ' || g_nl ||
                         'WHERE entry_id = ' || l_entry_id);
        END IF;
        UPDATE gcs_entry_lines
           SET ytd_debit_balance_e  = ROUND(ytd_debit_balance_e /
                                            l_precision) * l_precision,
               ytd_credit_balance_e = ROUND(ytd_credit_balance_e /
                                            l_precision) * l_precision,
               ytd_balance_e        = ROUND(nvl(ytd_debit_balance_e, 0) /
                                            l_precision) * l_precision -
                                      ROUND(nvl(ytd_credit_balance_e, 0) /
                                            l_precision) * l_precision
         WHERE entry_id = l_entry_id;
      END IF;

      -- Enhancement for Adjustment Approval Process
      IF fnd_profile.value('AME_INSTALLED_FLAG') = 'Y' THEN
        GCS_ADJ_APPROVAL_WF_PKG.create_gcsadj_process(p_entry_id        => l_entry_id,
                                                      p_user_id         => fnd_global.user_id,
                                                      p_user_name       => fnd_global.user_name,
                                                      p_orig_entry_id   => l_orig_entry_id,
                                                      p_ledger_id       => to_number(p_ledger_id),
                                                      p_cal_period_name => p_cal_period_name,
                                                      p_conversion_type => p_conversion_type,
                                                      p_writeback_flag  => p_writeback_needed,
                                                      p_wfitemkey       => p_wf_itemkey);

        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
                          g_pkg_name || '.' || l_api_name || 'EXIT');
        FND_FILE.NEW_LINE(FND_FILE.OUTPUT);

        IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure THEN
          fnd_log.STRING(fnd_log.level_procedure,
                         g_pkg_name || '.' || l_api_name,
                         gcs_utility_pkg.g_module_success || ' ' ||
                         l_api_name || '() ' ||
                         TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS')

                         );
        END IF;
      ELSE

        wf_event.addparametertolist(p_name          => 'ENTRY_ID',
                                    p_value         => l_entry_id,
                                    p_parameterlist => l_parameter_list);
        wf_event.addparametertolist(p_name          => 'ORIG_ENTRY_ID',
                                    p_value         => l_orig_entry_id,
                                    p_parameterlist => l_parameter_list);
        BEGIN
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
                            g_pkg_name || '.' || l_api_name ||
                            ' RAISE WF_EVENT');
          FND_FILE.NEW_LINE(FND_FILE.OUTPUT);
          wf_event.RAISE(p_event_name => l_event_name,
                         p_event_key  => l_event_key,
                         p_parameters => l_parameter_list);
        EXCEPTION
          WHEN OTHERS THEN
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
                              g_pkg_name || '.' || l_api_name ||
                              ' ERROR : ' || SQLERRM);
            FND_FILE.NEW_LINE(FND_FILE.OUTPUT);
            IF fnd_log.g_current_runtime_level <= fnd_log.level_error THEN
              fnd_log.STRING(fnd_log.level_error,
                             g_pkg_name || '.' || l_api_name,
                             ' wf_event.raise failed ' || ' ' ||
                             TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
            END IF;
        END;

        -- Bug fix : 5260258
        IF (p_writeback_needed = 'Y') THEN
          l_request_id := fnd_request.submit_request(application => 'GCS',
                                                     program     => 'FCH_ENTRY_WRITEBACK',
                                                     sub_request => FALSE,
                                                     argument1   => l_entry_id,
                                                     argument2   => l_entry_id,
                                                     argument3   => to_number(p_ledger_id),
                                                     argument4   => p_cal_period_name,
                                                     argument5   => p_conversion_type);

          FND_FILE.PUT_LINE(FND_FILE.LOG,
                            'Submitted request id : ' || l_request_id);
          FND_FILE.NEW_LINE(FND_FILE.OUTPUT);
        END IF;

        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
                          g_pkg_name || '.' || l_api_name || ' EXIT');
        FND_FILE.NEW_LINE(FND_FILE.OUTPUT);

      END IF;

    END IF;
    IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure THEN
      fnd_log.STRING(fnd_log.level_procedure,
                     g_pkg_name || '.' || l_api_name,
                     gcs_utility_pkg.g_module_success || ' ' || l_api_name ||
                     '() ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
    END IF;

  EXCEPTION
    WHEN OTHERS THEN

      ROLLBACK TO gcs_me_import_start;
      fnd_message.set_name('GCS', 'GCS_ENTRY_UNEXPECTED_ERR');
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
                        g_pkg_name || '.' || l_api_name || ' ERROR : ' ||
                        SQLERRM);
      FND_FILE.NEW_LINE(FND_FILE.OUTPUT);
      -- Write the appropriate information to the execution report
      IF fnd_log.g_current_runtime_level <= fnd_log.level_error THEN
        fnd_log.STRING(fnd_log.level_error,
                       g_pkg_name || '.' || l_api_name,
                       gcs_utility_pkg.g_module_failure || ' ' || SQLERRM || ' ' ||
                       TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
      END IF;
  END manual_entries_import;

  ---------------------------------------------------------------------------
  /*
  ** upload_entry_headers
  */
  PROCEDURE upload_entry_headers(p_entry_id_char       IN OUT NOCOPY VARCHAR2,
                                 p_end_cal_period_id   IN VARCHAR2,
                                 p_hierarchy_id        IN NUMBER,
                                 p_entity_id           IN VARCHAR2,
                                 p_start_cal_period_id IN VARCHAR2,
                                 p_currency_code       IN VARCHAR2,
                                 p_process_code        IN VARCHAR2,
                                 p_description         IN VARCHAR2,
                                 p_entry_name          IN VARCHAR2,
                                 p_category_code       IN VARCHAR2,
                                 p_balance_type_code   IN VARCHAR2,
                                 p_writeback_needed    IN VARCHAR2,
                                 p_ledger_id           IN VARCHAR2,
                                 p_cal_period_name     IN VARCHAR2,
                                 p_conversion_type     IN VARCHAR2,
                                 p_hierarchy_grp_flag  IN VARCHAR2) IS
  BEGIN
    null;
  END upload_entry_headers;
  ---------------------------------------------------------------------------
  --
  -- Procedure
  --   delete_entry
  -- Purpose
  --   An API to delete an entry
  -- Arguments
  -- Notes
  --
  PROCEDURE delete_entry(p_entry_id IN NUMBER,
                         x_errbuf   OUT NOCOPY VARCHAR2,
                         x_retcode  OUT NOCOPY VARCHAR2) IS
    l_api_name VARCHAR2(30) := 'DELETE_ENTRY';
  BEGIN
    SAVEPOINT gcs_delete_entry_start;
    IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure THEN
      fnd_log.STRING(fnd_log.level_procedure,
                     g_pkg_name || '.' || l_api_name,
                     gcs_utility_pkg.g_module_enter || ' ' || l_api_name ||
                     '() ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
    END IF;
    IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure THEN
      fnd_log.STRING(fnd_log.level_procedure,
                     g_pkg_name || '.' || l_api_name,
                     'DELETE FROM gcs_entry_headers' || g_nl ||
                     'WHERE entry_id = ' || p_entry_id);
    END IF;
    /*
          DELETE FROM gcs_entry_headers
                WHERE entry_id = p_entry_id;
    */
    IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure THEN
      fnd_log.STRING(fnd_log.level_procedure,
                     g_pkg_name || '.' || l_api_name,
                     'DELETE FROM gcs_entry_lines' || g_nl ||
                     'WHERE entry_id = ' || p_entry_id);
    END IF;
    DELETE FROM gcs_entry_lines WHERE entry_id = p_entry_id;
    x_retcode := fnd_api.g_ret_sts_success;
    IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure THEN
      fnd_log.STRING(fnd_log.level_procedure,
                     g_pkg_name || '.' || l_api_name,
                     gcs_utility_pkg.g_module_success || ' ' || l_api_name ||
                     '() ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      ROLLBACK TO gcs_delete_entry_start;
      fnd_message.set_name('GCS', 'GCS_INVALID_ENTRY_ID');
      x_errbuf  := fnd_message.get;
      x_retcode := fnd_api.g_ret_sts_error;
      -- Write the appropriate information to the execution report
      IF fnd_log.g_current_runtime_level <= fnd_log.level_error THEN
        fnd_log.STRING(fnd_log.level_error,
                       g_pkg_name || '.' || l_api_name,
                       gcs_utility_pkg.g_module_failure || ' ' || x_errbuf ||
                       TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
      END IF;
    WHEN OTHERS THEN
      ROLLBACK TO gcs_delete_entry_start;
      fnd_message.set_name('GCS', 'GCS_ENTRY_UNEXPECTED_ERR');
      x_errbuf  := fnd_message.get;
      x_retcode := fnd_api.g_ret_sts_unexp_error;
      -- Write the appropriate information to the execution report
      IF fnd_log.g_current_runtime_level <= fnd_log.level_error THEN
        fnd_log.STRING(fnd_log.level_error,
                       g_pkg_name || '.' || l_api_name,
                       gcs_utility_pkg.g_module_failure || ' ' || x_errbuf ||
                       TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
      END IF;
  END delete_entry;

  --
  -- Procedure
  --   raise_disable_event
  -- Purpose
  --   An API to disable an entry and track impact analysis and notify
  -- Arguments
  --   p_entry_id      Entry Identifier
  --   p_cal_period_id Calendar Period Identifier
  -- Notes
  --   Bugfix 5613302
  PROCEDURE raise_disable_event(p_entry_id      IN NUMBER,
                                p_cal_period_id IN NUMBER) IS
    l_event_name     VARCHAR2(100) := 'oracle.apps.gcs.transaction.adjustment.disable';
    l_event_key      VARCHAR2(100) := NULL;
    l_parameter_list wf_parameter_list_t;
    l_api_name       VARCHAR2(30) := 'RAISE_DISABLE_EVENT';

  BEGIN

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
                      g_pkg_name || '.' || l_api_name || ' ENTER');
    FND_FILE.NEW_LINE(FND_FILE.OUTPUT);
    wf_event.addparametertolist(p_name          => 'ENTRY_ID',
                                p_value         => p_entry_id,
                                p_parameterlist => l_parameter_list);
    wf_event.addparametertolist(p_name          => 'CAL_PERIOD_ID',
                                p_value         => p_cal_period_id,
                                p_parameterlist => l_parameter_list);

    BEGIN
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
                        g_pkg_name || '.' || l_api_name ||
                        ' RAISE WF_EVENT');
      FND_FILE.NEW_LINE(FND_FILE.OUTPUT);
      wf_event.RAISE(p_event_name => l_event_name,
                     p_event_key  => l_event_key,
                     p_parameters => l_parameter_list);
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
                        g_pkg_name || '.' || l_api_name || ' EXIT');
      FND_FILE.NEW_LINE(FND_FILE.OUTPUT);
    EXCEPTION
      WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
                          g_pkg_name || '.' || l_api_name || ' ERROR : ' ||
                          SQLERRM);
        FND_FILE.NEW_LINE(FND_FILE.OUTPUT);
        IF fnd_log.g_current_runtime_level <= fnd_log.level_error THEN
          fnd_log.STRING(fnd_log.level_error,
                         g_pkg_name || '.' || l_api_name,
                         ' wf_event.raise failed ' || ' ' ||
                         TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
        END IF;
    END;
  END raise_disable_event;
END gcs_entry_pkg;


/
