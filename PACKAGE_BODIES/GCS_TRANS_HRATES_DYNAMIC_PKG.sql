--------------------------------------------------------
--  DDL for Package Body GCS_TRANS_HRATES_DYNAMIC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_TRANS_HRATES_DYNAMIC_PKG" AS

      -- The API name
      g_api             VARCHAR2(50) := 'gcs.plsql.GCS_TRANS_HRATES_DYNAMIC_PKG';

      -- Action types for writing module information to the log file. Used for
      -- the procedure log_file_module_write.
      g_module_enter    VARCHAR2(2) := '>>';
      g_module_success  VARCHAR2(2) := '<<';
      g_module_failure  VARCHAR2(2) := '<x';

      -- A newline character. Included for convenience when writing long strings.
      g_nl              VARCHAR2(1) := '
';

    --
    -- PRIVATE EXCEPTIONS
    --
      GCS_CCY_NO_DATA               EXCEPTION;
      GCS_CCY_ENTRY_CREATE_FAILED   EXCEPTION;

    --
    -- PRIVATE PROCEDURES/FUNCTIONS
    --

      --
      -- Procedure
      --   Module_Log_Write
      -- Purpose
      --   Write the procedure or function entered or exited, and the time that
      --   this happened. Write it to the log repository.
      -- Arguments
      --   p_module       Name of the module
      --   p_action_type  Entered, Exited Successfully, or Exited with Failure
      -- Example
      --   GCS_TRANS_HRATES_DYNAMIC_PKG.Module_Log_Write
      -- Notes
      --
      PROCEDURE Module_Log_Write
        (p_module       VARCHAR2,
         p_action_type  VARCHAR2) IS
      BEGIN
        -- Only print if the log level is set at the appropriate level
        IF FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE THEN
          fnd_log.string(FND_LOG.LEVEL_PROCEDURE, g_api || '.' || p_module,
                         p_action_type || ' ' || p_module || '() ' ||
                         to_char(sysdate, 'DD-MON-YYYY HH:MI:SS'));
        END IF;
        FND_FILE.PUT_LINE(FND_FILE.LOG, p_action_type || ' ' || p_module ||
                          '() ' || to_char(sysdate, 'DD-MON-YYYY HH:MI:SS'));
      END Module_Log_Write;



      --
      -- Procedure
      --   Write_To_Log
      -- Purpose
      --   Write the text given to the log in 3500 character increments
      --   this happened. Write it to the log repository.
      -- Arguments
      --   p_module		Name of the module
      --   p_level		Logging level
      --   p_text		Text to write
      -- Example
      --   GCS_TRANS_HRATES_DYNAMIC_PKG.Write_To_Log
      -- Notes
      --
      PROCEDURE Write_To_Log
        (p_module	VARCHAR2,
         p_level	NUMBER,
         p_text	VARCHAR2)
      IS
        api_module_concat	VARCHAR2(200);
        text_with_date	VARCHAR2(32767);
        text_with_date_len	NUMBER;
        curr_index		NUMBER;
      BEGIN
        -- Only print if the log level is set at the appropriate level
        IF FND_LOG.G_CURRENT_RUNTIME_LEVEL <= p_level THEN
          api_module_concat := g_api || '.' || p_module;
          text_with_date := to_char(sysdate,'DD-MON-YYYY HH:MI:SS')||g_nl||p_text;
          text_with_date_len := length(text_with_date);
          curr_index := 1;
          WHILE curr_index <= text_with_date_len LOOP
            fnd_log.string(p_level, api_module_concat,
                           substr(text_with_date, curr_index, 3500));
            curr_index := curr_index + 3500;
          END LOOP;
        END IF;
      END Write_To_Log;


    --
    -- Public procedures
      --
      PROCEDURE Roll_Forward_Historical_Rates
        (p_hier_dataset_code  NUMBER,
         p_source_system_code NUMBER,
         p_ledger_id          NUMBER,
         p_cal_period_id      NUMBER,
         p_prev_period_id     NUMBER,
         p_entity_id          NUMBER,
         p_hierarchy_id       NUMBER,
         p_from_ccy           VARCHAR2,
         p_to_ccy             VARCHAR2,
         p_eq_xlate_mode      VARCHAR2,
         p_hier_li_id         NUMBER) IS

        module        VARCHAR2(50) := 'ROLL_FORWARD_HISTORICAL_RATES';
      BEGIN
        write_to_log(module, FND_LOG.LEVEL_PROCEDURE,g_module_enter);

        --Bugfix 6111815: Added Standard RE Rate Flag
        write_to_log(module, FND_LOG.LEVEL_STATEMENT,
    'UPDATE gcs_historical_rates ghr' || g_nl ||
    'SET    (translated_rate, translated_amount, rate_type_code, ' ||
    'last_update_date, last_updated_by, last_update_login) =' || g_nl ||
    '       (SELECT ghr1.translated_rate, ghr1.translated_amount, ''P'', ' ||
    'sysdate, ' || gcs_translation_pkg.g_fnd_user_id || ', ' ||
    gcs_translation_pkg.g_fnd_login_id || g_nl ||
    '        FROM   gcs_historical_rates ghr1' || g_nl ||
    '        WHERE  ghr1.entity_id = ghr.entity_id' || g_nl ||
    '        AND    ghr1.hierarchy_id = ghr.hierarchy_id' || g_nl ||
    '        AND    ghr1.from_currency = ghr.from_currency' || g_nl ||
    '        AND    ghr1.to_currency = ghr.to_currency' || g_nl ||
    '        AND    ghr1.line_item_id = ghr.line_item_id' || g_nl ||
    '        AND    ghr1.standard_re_rate_flag IS NULL ' || g_nl ||'        AND    ghr1.cal_period_id = ' || p_prev_period_id || ')' || g_nl ||
    'WHERE  ghr.rowid IN ( ' || g_nl ||
    '        SELECT ghr3.rowid' || g_nl ||
    '        FROM   GCS_HISTORICAL_RATES ghr2, ' || g_nl ||
    '               GCS_HISTORICAL_RATES ghr3' || g_nl ||
    '        WHERE  ghr2.entity_id = ' || p_entity_id || g_nl ||
    '        AND    ghr2.hierarchy_id = ' || p_hierarchy_id || g_nl ||
    '        AND    ghr2.from_currency = ''' || p_from_ccy || '''' || g_nl ||
    '        AND    ghr2.to_currency = ''' || p_to_ccy || '''' || g_nl ||
    '        AND    ghr2.rate_type_code in (''H'',''P'',''C'')' || g_nl ||
    '        AND    ghr2.account_type_code IN (''ASSET'',''LIABILITY'',decode(''' || p_eq_xlate_mode || ''', ''YTD'', ''EQUITY'', NULL))' || g_nl ||
    '        AND    ghr2.stop_rollforward_flag = ''N''' || g_nl ||
    '        AND    ghr3.entity_id = ghr2.entity_id' || g_nl ||
    '        AND    ghr3.hierarchy_id = ghr2.hierarchy_id' || g_nl ||
    '        AND    ghr2.cal_period_id = ' || p_prev_period_id || g_nl ||
    '        AND    ghr3.cal_period_id = ' || p_cal_period_id || g_nl ||
    '        AND    ghr3.line_item_id = ghr2.line_item_id' || g_nl ||
    '        AND    ghr3.standard_re_rate_flag IS NULL' || g_nl ||'        AND    ghr3.from_currency = ghr2.from_currency' || g_nl ||
    '        AND    ghr3.to_currency = ghr2.to_currency ' || g_nl ||
    '        AND    ghr3.rate_type_code IN (''P'', ''E'')' || g_nl ||
    '        AND    (nvl(to_char(ghr2.translated_rate), ''X'') <>' || g_nl ||
    '                nvl(to_char(ghr3.translated_rate), ''X'')' || g_nl ||
    '                OR' || g_nl ||
    '                nvl(to_char(ghr2.translated_amount), ''X'') <>' || g_nl ||
    '                nvl(to_char(ghr3.translated_amount), ''X'')))');

        -- First, update historical rates for balance sheet accounts if:
        --   1. A historical rate exists in the current period and the rate type
        --      is not historical.
        --   2. A historical rate exists in the previous period and the rate type
        --      is Prior or Historical.
        --   3. The historical rates of current and previous periods are different.
        --   4. The historical rate is not marked with stop rolling forward.
        -- Bugfix 6111815: Added Standard RE Rate Flag
        UPDATE   gcs_historical_rates ghr
        SET      (translated_rate, translated_amount, rate_type_code,
                  last_update_date, last_updated_by, last_update_login) =
        (SELECT ghr1.translated_rate, ghr1.translated_amount, 'P', sysdate,
                gcs_translation_pkg.g_fnd_user_id, gcs_translation_pkg.g_fnd_login_id
         FROM   gcs_historical_rates ghr1
         WHERE  ghr1.entity_id = ghr.entity_id
         AND    ghr1.hierarchy_id = ghr.hierarchy_id
         AND    ghr1.from_currency = ghr.from_currency
         AND    ghr1.to_currency = ghr.to_currency
         AND    ghr1.line_item_id = ghr.line_item_id
         AND    ghr1.standard_re_rate_flag IS NULL    AND    ghr1.cal_period_id = p_prev_period_id)
        WHERE  ghr.rowid IN (
        SELECT ghr3.rowid
        FROM   GCS_HISTORICAL_RATES ghr2,
               GCS_HISTORICAL_RATES ghr3
         WHERE ghr2.entity_id = p_entity_id
         AND    ghr2.hierarchy_id = p_hierarchy_id
         AND    ghr2.from_currency = p_from_ccy
         AND    ghr2.to_currency = p_to_ccy
         AND    ghr2.rate_type_code in ('H','P','C')
         AND    ghr2.account_type_code IN ('ASSET','LIABILITY',decode(p_eq_xlate_mode, 'YTD', 'EQUITY', NULL))
         AND    ghr2.stop_rollforward_flag = 'N'
         AND    ghr3.entity_id = ghr2.entity_id
         AND    ghr3.hierarchy_id = ghr2.hierarchy_id
         AND    ghr2.cal_period_id = p_prev_period_id
         AND    ghr3.cal_period_id = p_cal_period_id
         AND    ghr3.line_item_id = ghr2.line_item_id
         AND    ghr3.standard_re_rate_flag IS NULL     AND    ghr3.from_currency = ghr2.from_currency
         AND    ghr3.to_currency = ghr2.to_currency
         AND    ghr3.rate_type_code IN ('P', 'E')
         AND    (nvl(to_char(ghr2.translated_rate), 'X') <>
                 nvl(to_char(ghr3.translated_rate), 'X')
                 OR
                 nvl(to_char(ghr2.translated_amount), 'X') <>
                 nvl(to_char(ghr3.translated_amount), 'X')));

    --Bugfix 6111815: Added Standard RE Rate Flag
        write_to_log(module, FND_LOG.LEVEL_STATEMENT,
    'DELETE FROM gcs_historical_rates ghr' || g_nl ||
    'WHERE  (rowid, ''E'') IN (' || g_nl ||
    '        SELECT ghr3.rowid, nvl(ghr2.rate_type_code, ''E'')' || g_nl ||
    '        FROM   GCS_HISTORICAL_RATES ghr3, ' || g_nl ||
    '               GCS_HISTORICAL_RATES ghr2' || g_nl ||
    '        WHERE  ghr3.entity_id = ' || p_entity_id || g_nl ||
    '        AND    ghr3.hierarchy_id = ' || p_hierarchy_id || g_nl ||
    '        AND    ghr3.rate_type_code = ''P''' || g_nl ||
    '        AND    ghr3.account_type_code IN (''ASSET'',''LIABILITY'',decode(''' || p_eq_xlate_mode || ''', ''YTD'', ''EQUITY'', NULL))' || g_nl ||
    '        AND    ghr3.cal_period_id = ' || p_cal_period_id || g_nl ||
    '        AND    ghr3.from_currency = ''' || p_from_ccy || '''' || g_nl ||
    '        AND    ghr3.to_currency = ''' || p_to_ccy || '''' || g_nl ||
    '        AND    ghr2.cal_period_id (+)= ' || p_prev_period_id || g_nl ||
    '        AND    ghr2.entity_id (+)= ' || p_entity_id || g_nl ||
    '        AND    ghr2.hierarchy_id (+)= ' || p_hierarchy_id || g_nl ||
    '        AND    ghr2.from_currency (+)= ''' || p_from_ccy || '''' || g_nl ||
    '        AND    ghr2.to_currency (+)= ''' || p_to_ccy || '''' || g_nl ||
    '        AND    ghr2.stop_rollforward_flag (+)= ''N''' || g_nl ||
    '        AND    ghr2.line_item_id (+)= ghr3.line_item_id' || g_nl ||
    '        AND    ghr3.standard_re_rate_flag IS NULL ' || g_nl ||'       )');

        -- Next, delete historical rates for balance sheet accounts if:
        --   1. A historical rate exists in the current period and the rate
        --      type is Prior.
        --   2. There is no historical rate in the previous period or a historical
        --      rate exists in the previous period with the rate type Period.
        -- Bugfix 6111815: Added Standard RE Rate Flag
        DELETE FROM gcs_historical_rates ghr
        WHERE (rowid, 'E') IN (
               SELECT ghr3.rowid, nvl(ghr2.rate_type_code, 'E')
               FROM   GCS_HISTORICAL_RATES ghr3,
                      GCS_HISTORICAL_RATES ghr2
               WHERE  ghr3.entity_id = p_entity_id
               AND    ghr3.hierarchy_id = p_hierarchy_id
               AND    ghr3.rate_type_code = 'P'
               AND    ghr3.account_type_code IN ('ASSET','LIABILITY',decode(p_eq_xlate_mode, 'YTD', 'EQUITY', NULL))
               AND    ghr3.cal_period_id = p_cal_period_id
               AND    ghr3.from_currency = p_from_ccy
               AND    ghr3.to_currency = p_to_ccy
               AND    ghr2.cal_period_id (+)= p_prev_period_id
               AND    ghr2.entity_id (+)= p_entity_id
               AND    ghr2.hierarchy_id (+)= p_hierarchy_id
               AND    ghr2.from_currency (+)= p_from_ccy
               AND    ghr2.to_currency (+)= p_to_ccy
               AND    ghr2.stop_rollforward_flag (+)= 'N'
               AND    ghr2.line_item_id (+)= ghr3.line_item_id
               AND    ghr3.standard_re_rate_flag IS NULL          );

    --Bugfix 6111815: Added Standard RE Rate Flag
        write_to_log(module, FND_LOG.LEVEL_STATEMENT,
    'INSERT /*+ parallel (gcs_historical_rates) */ INTO gcs_historical_rates(entity_id, hierarchy_id, ' ||
    'cal_period_id, from_currency, to_currency, line_item_id, ' ||
    'company_cost_center_org_id, intercompany_id, financial_elem_id, ' ||
    'product_id, natural_account_id, channel_id, project_id, customer_id, task_id, ' ||
    'user_dim1_id, user_dim2_id, user_dim3_id, user_dim4_id, user_dim5_id, ' ||
    'user_dim6_id, user_dim7_id, user_dim8_id, user_dim9_id, user_dim10_id, ' ||
    'translated_rate, translated_amount, rate_type_code, update_flag, ' ||
    'account_type_code, stop_rollforward_flag, last_update_date, last_updated_by, ' ||
    'last_update_login, creation_date, created_by)' || g_nl ||
    'SELECT ' || g_nl ||
    'ghr.entity_id, ghr.hierarchy_id, ' || p_cal_period_id || ', '||
    'ghr.from_currency, ghr.to_currency, ghr.line_item_id, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'ghr.translated_rate, ghr.translated_amount, ''P'', ''N'', ' ||
    'ghr.account_type_code, ''N'', sysdate, ' ||
    gcs_translation_pkg.g_fnd_user_id || ', ' || gcs_translation_pkg.g_fnd_login_id ||
    ', sysdate, ' || gcs_translation_pkg.g_fnd_user_id || g_nl ||
    'FROM   gcs_historical_rates ghr' || g_nl ||
    'WHERE  ghr.entity_id = ' || p_entity_id || g_nl ||
    'AND    ghr.hierarchy_id = ' || p_hierarchy_id || g_nl ||
    'AND    ghr.to_currency = ''' || p_to_ccy || '''' || g_nl ||
    'AND    ghr.from_currency = ''' || p_from_ccy || '''' || g_nl ||
    'AND    ghr.rate_type_code in (''H'', ''P'', ''C'')' || g_nl ||
    'AND    ghr.cal_period_id = ' || p_prev_period_id || g_nl ||
    'AND    ghr.account_type_code IN (''ASSET'',''LIABILITY'',decode(''' || p_eq_xlate_mode || ''', ''YTD'', ''EQUITY'', NULL))' || g_nl ||
    'AND    ghr.stop_rollforward_flag = ''N''' || g_nl ||
    'AND    ghr.standard_re_rate_flag IS NULL ' || g_nl ||
    '    AND NOT EXISTS (' || g_nl ||
    '           SELECT 1 FROM gcs_historical_rates ghr1' || g_nl ||
    '           WHERE ghr1.entity_id  = p_entity_id' || g_nl ||
    '    AND    ghr1.hierarchy_id = p_hierarchy_id' || g_nl ||
    '    AND    ghr1.cal_period_id = p_cal_period_id' || g_nl ||
    '    AND    ghr1.line_item_id = ghr.line_item_id' || g_nl ||'    AND    ghr1.update_flag = ''N''' || g_nl ||
    '    AND    ghr1.from_currency = ghr.from_currency' || g_nl ||
    '    AND    ghr1.to_currency = ghr.to_currency);' || g_nl );

        -- Next, insert historical rates for balance sheet accounts if:
        --   1. No historical rate exists for the current period.
        --   2. A historical rate is defined for the previous period with Prior or
        --      Historical rate type and the stop roll forward flag is not checked.
        INSERT /*+ parallel (gcs_historical_rates) */ INTO gcs_historical_rates(
          entity_id, hierarchy_id, cal_period_id, from_currency,
          to_currency, line_item_id, company_cost_center_org_id, intercompany_id,
          financial_elem_id, product_id, natural_account_id,
          channel_id, project_id, customer_id, task_id, user_dim1_id, user_dim2_id,
          user_dim3_id, user_dim4_id, user_dim5_id, user_dim6_id, user_dim7_id,
          user_dim8_id, user_dim9_id, user_dim10_id, translated_rate,
          translated_amount, rate_type_code, update_flag, account_type_code,
          stop_rollforward_flag, last_update_date, last_updated_by,
          last_update_login, creation_date, created_by)
        SELECT
          ghr.entity_id, ghr.hierarchy_id,
          p_cal_period_id, ghr.from_currency, ghr.to_currency,
          ghr.line_item_id,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,      ghr.translated_rate, ghr.translated_amount, 'P', 'N',
          ghr.account_type_code, 'N', sysdate, gcs_translation_pkg.g_fnd_user_id,
          gcs_translation_pkg.g_fnd_login_id, sysdate,
          gcs_translation_pkg.g_fnd_user_id
        FROM   gcs_historical_rates ghr
        WHERE  ghr.entity_id = p_entity_id
        AND    ghr.hierarchy_id = p_hierarchy_id
        AND    ghr.to_currency = p_to_ccy
        AND    ghr.from_currency = p_from_ccy
        AND    ghr.rate_type_code in ('H', 'P', 'C')
        AND    ghr.cal_period_id = p_prev_period_id
        AND    ghr.account_type_code IN ('ASSET','LIABILITY',decode(p_eq_xlate_mode, 'YTD', 'EQUITY', NULL))
        AND    ghr.stop_rollforward_flag = 'N'
        AND    ghr.standard_re_rate_flag IS NULL
        AND NOT EXISTS (
               SELECT 1 FROM gcs_historical_rates ghr1
               WHERE ghr1.entity_id  = p_entity_id
        AND    ghr1.hierarchy_id = p_hierarchy_id
        AND    ghr1.cal_period_id = p_cal_period_id
        AND    ghr1.line_item_id = ghr.line_item_id    AND    ghr1.update_flag = 'N'
        AND    ghr1.from_currency = ghr.from_currency
        AND    ghr1.to_currency = ghr.to_currency);

        write_to_log(module, FND_LOG.LEVEL_PROCEDURE,g_module_success);
      EXCEPTION
        WHEN OTHERS THEN
          FND_MESSAGE.set_name('GCS', 'GCS_CCY_RF_UNEXPECTED_ERR');
          GCS_TRANSLATION_PKG.g_error_text := FND_MESSAGE.get;
          write_to_log(module, FND_LOG.LEVEL_UNEXPECTED, GCS_TRANSLATION_PKG.g_error_text);
          write_to_log(module, FND_LOG.LEVEL_UNEXPECTED, SQLERRM);
          module_log_write(module, g_module_failure);
          raise GCS_TRANSLATION_PKG.GCS_CCY_SUBPROGRAM_RAISED;
      END Roll_Forward_Historical_Rates;


      --
      PROCEDURE Trans_HRates_First_Per
        (p_hier_dataset_code    NUMBER,
         p_source_system_code NUMBER,
         p_ledger_id       NUMBER,
         p_cal_period_id   NUMBER,
         p_entity_id       NUMBER,
         p_hierarchy_id    NUMBER,
         p_from_ccy        VARCHAR2,
         p_to_ccy          VARCHAR2,
         p_eq_xlate_mode   VARCHAR2,
         p_is_xlate_mode   VARCHAR2,
         p_avg_rate        NUMBER,
         p_end_rate        NUMBER,
         p_group_by_flag   VARCHAR2,
         p_round_factor    NUMBER,
         p_hier_li_id      NUMBER) IS

        -- Rate to use for equity accounts, income statement accounts if there
        -- are no historical rates defined.
        eq_rate   NUMBER;
        is_rate   NUMBER;

        module    VARCHAR2(50) := 'TRANS_HRATES_FIRST_PER';
      BEGIN
        write_to_log(module, FND_LOG.LEVEL_PROCEDURE,g_module_enter);

        IF p_eq_xlate_mode = 'YTD' THEN
          eq_rate := p_end_rate;
        ELSE
          eq_rate := p_avg_rate;
        END IF;

        IF p_is_xlate_mode = 'YTD' THEN
          is_rate := p_end_rate;
        ELSE
          is_rate := p_avg_rate;
        END IF;

        IF p_group_by_flag = 'Y' THEN
          write_to_log(module, FND_LOG.LEVEL_STATEMENT,
    'INSERT /*+ parallel (GCS_TRANSLATION_GT) */ INTO GCS_TRANSLATION_GT(translate_rule_code, account_type_code, ' ||
    'line_item_id, company_cost_center_org_id, intercompany_id, financial_elem_id, ' ||
    'product_id, natural_account_id, channel_id, ' ||
    'project_id, customer_id, task_id, user_dim1_id, user_dim2_id, user_dim3_id, ' ||
    'user_dim4_id, user_dim5_id, user_dim6_id, user_dim7_id, user_dim8_id, ' ||
    'user_dim9_id, user_dim10_id, t_amount_dr, t_amount_cr, begin_ytd_dr, ' ||
    'begin_ytd_cr, xlate_ptd_dr, xlate_ptd_cr, xlate_ytd_dr, xlate_ytd_cr)' || g_nl ||
    'SELECT' || g_nl ||
    'decode(fxata.dim_attribute_varchar_member,' || g_nl ||
    '       ''REVENUE'', ''' || p_is_xlate_mode || ''',' || g_nl ||
    '       ''EXPENSE'', ''' || p_is_xlate_mode || ''',' || g_nl ||
    '       ''EQUITY'', ''' || p_eq_xlate_mode || ''',' || g_nl ||
    '            ''YTD''),' || g_nl ||
    'fxata.dim_attribute_varchar_member, fb.line_item_id, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'0, 0, 0, 0,' || g_nl ||
    'round(nvl(ghr.translated_amount * 0,' || g_nl ||
    '          nvl(fb.sum_ytd_debit_balance_e, 0) *' || g_nl ||
    '          nvl(ghr.translated_rate,' || g_nl ||
    '              decode(fxata.dim_attribute_varchar_member,' || g_nl ||
    '                     ''REVENUE'', ' || is_rate || ',' || g_nl ||
    '                     ''EXPENSE'', ' || is_rate || ',' || g_nl ||
    '                     ''EQUITY'', ' || eq_rate || ',' || g_nl ||
    '                          ' || p_end_rate || '))) /' || g_nl ||
    '      ' || p_round_factor || ') *' || g_nl ||
    p_round_factor || ',' || g_nl ||
    'round(nvl(ghr.translated_amount,' || g_nl ||
    '          nvl(fb.sum_ytd_credit_balance_e, 0) *' || g_nl ||
    '          nvl(ghr.translated_rate,' || g_nl ||
    '              decode(fxata.dim_attribute_varchar_member,' || g_nl ||
    '                     ''REVENUE'', ' || is_rate || ',' || g_nl ||
    '                     ''EXPENSE'', ' || is_rate || ',' || g_nl ||
    '                     ''EQUITY'', ' || eq_rate || ',' || g_nl ||
    '                          ' || p_end_rate || '))) /' || g_nl ||
    '      ' || p_round_factor || ') *' || g_nl ||
    p_round_factor || ',' || g_nl ||
    'round(nvl(ghr.translated_amount * 0,' || g_nl ||
    '          nvl(fb.sum_ytd_debit_balance_e, 0) *' || g_nl ||
    '          nvl(ghr.translated_rate,' || g_nl ||
    '              decode(fxata.dim_attribute_varchar_member,' || g_nl ||
    '                     ''REVENUE'', ' || is_rate || ',' || g_nl ||
    '                     ''EXPENSE'', ' || is_rate || ',' || g_nl ||
    '                     ''EQUITY'', ' || eq_rate || ',' || g_nl ||
    '                          ' || p_end_rate || '))) /' || g_nl ||
    '      ' || p_round_factor || ') *' || g_nl ||
    p_round_factor || ',' || g_nl ||
    'round(nvl(ghr.translated_amount,' || g_nl ||
    '          nvl(fb.sum_ytd_credit_balance_e, 0) *' || g_nl ||
    '          nvl(ghr.translated_rate,' || g_nl ||
    '              decode(fxata.dim_attribute_varchar_member,' || g_nl ||
    '                     ''REVENUE'', ' || is_rate || ',' || g_nl ||
    '                     ''EXPENSE'', ' || is_rate || ',' || g_nl ||
    '                     ''EQUITY'', ' || eq_rate || ',' || g_nl ||
    '                          ' || p_end_rate || '))) /' || g_nl ||
    '      ' || p_round_factor || ') *' || g_nl ||
    p_round_factor || g_nl ||
    'FROM   (SELECT' || g_nl ||
    '          fb_in.line_item_id,' || g_nl ||'          SUM(ytd_debit_balance_e) sum_ytd_debit_balance_e,' || g_nl ||
    '          SUM(ytd_credit_balance_e) sum_ytd_credit_balance_e' || g_nl ||
    '        FROM   FEM_BALANCES fb_in' || g_nl ||
    '        WHERE  fb_in.dataset_code = ' || p_hier_dataset_code || g_nl ||
    '        AND    fb_in.cal_period_id = ' || p_cal_period_id || g_nl ||
    '        AND    fb_in.source_system_code = ' || p_source_system_code || g_nl ||
    '        AND    fb_in.currency_code = ''' || p_from_ccy || '''' || g_nl ||
    '        AND    fb_in.ledger_id = ' || p_ledger_id || g_nl ||
    '        AND    fb_in.entity_id = ' || p_entity_id || g_nl ||
    '        GROUP BY ' || g_nl ||'          fb_in.line_item_id) fb,' || g_nl ||
    '       FEM_LN_ITEMS_ATTR li,' || g_nl ||
    '       FEM_EXT_ACCT_TYPES_ATTR fxata,' || g_nl ||
    '       GCS_HISTORICAL_RATES ghr' || g_nl ||
    'WHERE  li.line_item_id = fb.line_item_id' || g_nl ||
    'AND    li.attribute_id = ' || gcs_translation_pkg.g_li_acct_type_attr_id || g_nl ||
    'AND    li.version_id = ' || gcs_translation_pkg.g_li_acct_type_v_id || g_nl ||
    'AND    fxata.ext_account_type_code = li.dim_attribute_varchar_member' || g_nl ||
    'AND    fxata.attribute_id = ' || gcs_translation_pkg.g_xat_basic_acct_type_attr_id || g_nl ||
    'AND    fxata.version_id = ' || gcs_translation_pkg.g_xat_basic_acct_type_v_id || g_nl ||
    'AND    ghr.entity_id(+) = ' || p_entity_id || g_nl ||
    'AND    ghr.hierarchy_id (+) = ' || p_hierarchy_id || g_nl ||
    'AND    ghr.from_currency (+) = ''' || p_from_ccy || '''' || g_nl ||
    'AND    ghr.to_currency (+) = ''' || p_to_ccy || '''' || g_nl ||
    'AND    ghr.cal_period_id (+) = ' || p_cal_period_id || g_nl ||
    'AND    ghr.line_item_id (+) = fb.line_item_id' || g_nl ||
    'AND    ghr.update_flag (+) = ''N'' ' || g_nl ||'');

          INSERT /*+ parallel (GCS_TRANSLATION_GT) */ INTO GCS_TRANSLATION_GT(
            translate_rule_code, account_type_code, line_item_id,
            company_cost_center_org_id, intercompany_id, financial_elem_id,
            product_id, natural_account_id, channel_id, project_id,
            customer_id, task_id, user_dim1_id, user_dim2_id, user_dim3_id,
            user_dim4_id, user_dim5_id, user_dim6_id, user_dim7_id, user_dim8_id,
            user_dim9_id, user_dim10_id, t_amount_dr, t_amount_cr, begin_ytd_dr,
            begin_ytd_cr, xlate_ptd_dr, xlate_ptd_cr, xlate_ytd_dr, xlate_ytd_cr)
          SELECT /*+ ordered */
            decode(fxata.dim_attribute_varchar_member,
                   'REVENUE', p_is_xlate_mode,
                   'EXPENSE', p_is_xlate_mode,
                   'EQUITY', p_eq_xlate_mode,
                        'YTD'),
            fxata.dim_attribute_varchar_member, fb.line_item_id,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,        0, 0, 0, 0,
            round(nvl(ghr.translated_amount * 0,
                      nvl(fb.sum_ytd_debit_balance_e, 0) *
                      nvl(ghr.translated_rate,
                          decode(fxata.dim_attribute_varchar_member,
                                 'REVENUE', is_rate,
                                 'EXPENSE', is_rate,
                                 'EQUITY', eq_rate,
                                      p_end_rate))) /
                  p_round_factor) *
            p_round_factor,
            round(nvl(ghr.translated_amount,
                      nvl(fb.sum_ytd_credit_balance_e, 0) *
                      nvl(ghr.translated_rate,
                          decode(fxata.dim_attribute_varchar_member,
                                 'REVENUE', is_rate,
                                 'EXPENSE', is_rate,
                                 'EQUITY', eq_rate,
                                      p_end_rate))) /
                  p_round_factor) *
            p_round_factor,
            round(nvl(ghr.translated_amount * 0,
                      nvl(fb.sum_ytd_debit_balance_e, 0) *
                      nvl(ghr.translated_rate,
                          decode(fxata.dim_attribute_varchar_member,
                                 'REVENUE', is_rate,
                                 'EXPENSE', is_rate,
                                 'EQUITY', eq_rate,
                                      p_end_rate))) /
                  p_round_factor) *
            p_round_factor,
            round(nvl(ghr.translated_amount,
                      nvl(fb.sum_ytd_credit_balance_e, 0) *
                      nvl(ghr.translated_rate,
                          decode(fxata.dim_attribute_varchar_member,
                                 'REVENUE', is_rate,
                                 'EXPENSE', is_rate,
                                 'EQUITY', eq_rate,
                                      p_end_rate))) /
                  p_round_factor) *
            p_round_factor
          FROM   (SELECT
                    fb_in.line_item_id,                SUM(ytd_debit_balance_e) sum_ytd_debit_balance_e,
                    SUM(ytd_credit_balance_e) sum_ytd_credit_balance_e
                  FROM   FEM_BALANCES fb_in
                  WHERE  fb_in.dataset_code = p_hier_dataset_code
                  AND    fb_in.cal_period_id = p_cal_period_id
                  AND    fb_in.source_system_code = p_source_system_code
                  AND    fb_in.currency_code = p_from_ccy
                  AND    fb_in.ledger_id = p_ledger_id
                  AND    fb_in.entity_id = p_entity_id
                  GROUP BY             fb_in.line_item_id) fb,
                 FEM_LN_ITEMS_ATTR li,
                 FEM_EXT_ACCT_TYPES_ATTR fxata,
                 GCS_HISTORICAL_RATES ghr
          WHERE  li.line_item_id = fb.line_item_id
          AND    li.attribute_id = gcs_translation_pkg.g_li_acct_type_attr_id
          AND    li.version_id = gcs_translation_pkg.g_li_acct_type_v_id
          AND    fxata.ext_account_type_code = li.dim_attribute_varchar_member
          AND    fxata.attribute_id = gcs_translation_pkg.g_xat_basic_acct_type_attr_id
          AND    fxata.version_id = gcs_translation_pkg.g_xat_basic_acct_type_v_id
          AND    ghr.entity_id(+) = p_entity_id
          AND    ghr.hierarchy_id (+) = p_hierarchy_id
          AND    ghr.from_currency (+) = p_from_ccy
          AND    ghr.to_currency (+) = p_to_ccy
          AND    ghr.cal_period_id (+) = p_cal_period_id
          AND    ghr.line_item_id (+) = fb.line_item_id
          AND    ghr.update_flag (+) = 'N'
          AND   NOT EXISTS (SELECT 'X'
                            FROM   gcs_historical_rates ghr_retained
                            WHERE  ghr_retained.standard_re_rate_flag = 'Y'
                            AND    ghr_retained.hierarchy_id          = p_hierarchy_id
                            AND    ghr_retained.entity_id             = p_entity_id
                            AND    ghr_retained.cal_period_id         = p_cal_period_id
                            AND    ghr_retained.line_item_id          = fb.line_item_id    );

        ELSE
          write_to_log(module, FND_LOG.LEVEL_STATEMENT,
    'INSERT /*+ parallel (GCS_TRANSLATION_GT) */ INTO GCS_TRANSLATION_GT(translate_rule_code, account_type_code, ' ||
    'line_item_id, company_cost_center_org_id, intercompany_id, financial_elem_id, ' ||
    'product_id, natural_account_id, channel_id, ' ||
    'project_id, customer_id, task_id, user_dim1_id, user_dim2_id, user_dim3_id, ' ||
    'user_dim4_id, user_dim5_id, user_dim6_id, user_dim7_id, user_dim8_id, ' ||
    'user_dim9_id, user_dim10_id, t_amount_dr, t_amount_cr, begin_ytd_dr, ' ||
    'begin_ytd_cr, xlate_ptd_dr, xlate_ptd_cr, xlate_ytd_dr, xlate_ytd_cr)' || g_nl ||
    'SELECT' || g_nl ||
    'decode(fxata.dim_attribute_varchar_member,' || g_nl ||
    '       ''REVENUE'', ''' || p_is_xlate_mode || ''',' || g_nl ||
    '       ''EXPENSE'', ''' || p_is_xlate_mode || ''',' || g_nl ||
    '       ''EQUITY'', ''' || p_eq_xlate_mode || ''',' || g_nl ||
    '            ''YTD''),' || g_nl ||
    'fxata.dim_attribute_varchar_member, fb.line_item_id, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'0, 0, 0, 0,' || g_nl ||
    'round(nvl(ghr.translated_amount * 0,' || g_nl ||
    '          nvl(fb.sum_ytd_debit_balance_e, 0) *' || g_nl ||
    '          nvl(ghr.translated_rate,' || g_nl ||
    '              decode(fxata.dim_attribute_varchar_member,' || g_nl ||
    '                     ''REVENUE'', ' || is_rate || ',' || g_nl ||
    '                     ''EXPENSE'', ' || is_rate || ',' || g_nl ||
    '                     ''EQUITY'', ' || eq_rate || ',' || g_nl ||
    '                          ' || p_end_rate || '))) /' || g_nl ||
    '      ' || p_round_factor || ') *' || g_nl ||
    p_round_factor || ',' || g_nl ||
    'round(nvl(ghr.translated_amount,' || g_nl ||
    '          nvl(fb.sum_ytd_credit_balance_e, 0) *' || g_nl ||
    '          nvl(ghr.translated_rate,' || g_nl ||
    '              decode(fxata.dim_attribute_varchar_member,' || g_nl ||
    '                     ''REVENUE'', ' || is_rate || ',' || g_nl ||
    '                     ''EXPENSE'', ' || is_rate || ',' || g_nl ||
    '                     ''EQUITY'', ' || eq_rate || ',' || g_nl ||
    '                          ' || p_end_rate || '))) /' || g_nl ||
    '      ' || p_round_factor || ') *' || g_nl ||
    p_round_factor || ',' || g_nl ||
    'round(nvl(ghr.translated_amount * 0,' || g_nl ||
    '          nvl(fb.sum_ytd_debit_balance_e, 0) *' || g_nl ||
    '          nvl(ghr.translated_rate,' || g_nl ||
    '              decode(fxata.dim_attribute_varchar_member,' || g_nl ||
    '                     ''REVENUE'', ' || is_rate || ',' || g_nl ||
    '                     ''EXPENSE'', ' || is_rate || ',' || g_nl ||
    '                     ''EQUITY'', ' || eq_rate || ',' || g_nl ||
    '                          ' || p_end_rate || '))) /' || g_nl ||
    '      ' || p_round_factor || ') *' || g_nl ||
    p_round_factor || ',' || g_nl ||
    'round(nvl(ghr.translated_amount,' || g_nl ||
    '          nvl(fb.sum_ytd_credit_balance_e, 0) *' || g_nl ||
    '          nvl(ghr.translated_rate,' || g_nl ||
    '              decode(fxata.dim_attribute_varchar_member,' || g_nl ||
    '                     ''REVENUE'', ' || is_rate || ',' || g_nl ||
    '                     ''EXPENSE'', ' || is_rate || ',' || g_nl ||
    '                     ''EQUITY'', ' || eq_rate || ',' || g_nl ||
    '                          ' || p_end_rate || '))) /' || g_nl ||
    '      ' || p_round_factor || ') *' || g_nl ||
    p_round_factor || g_nl ||
    'FROM   (SELECT' || g_nl ||
    '          fb_in.line_item_id,' || g_nl ||'          ytd_debit_balance_e sum_ytd_debit_balance_e,' || g_nl ||
    '          ytd_credit_balance_e sum_ytd_credit_balance_e' || g_nl ||
    '        FROM   FEM_BALANCES fb_in' || g_nl ||
    '        WHERE  fb_in.dataset_code = ' || p_hier_dataset_code || g_nl ||
    '        AND    fb_in.cal_period_id = ' || p_cal_period_id || g_nl ||
    '        AND    fb_in.source_system_code = ' || p_source_system_code || g_nl ||
    '        AND    fb_in.currency_code = ''' || p_from_ccy || '''' || g_nl ||
    '        AND    fb_in.ledger_id = ' || p_ledger_id || g_nl ||
    '        AND    fb_in.entity_id = ' || p_entity_id || ') fb,' || g_nl ||
    '       FEM_LN_ITEMS_ATTR li,' || g_nl ||
    '       FEM_EXT_ACCT_TYPES_ATTR fxata,' || g_nl ||
    '       GCS_HISTORICAL_RATES ghr' || g_nl ||
    'WHERE  li.line_item_id = fb.line_item_id' || g_nl ||
    'AND    li.attribute_id = ' || gcs_translation_pkg.g_li_acct_type_attr_id || g_nl ||
    'AND    li.version_id = ' || gcs_translation_pkg.g_li_acct_type_v_id || g_nl ||
    'AND    fxata.ext_account_type_code = li.dim_attribute_varchar_member' || g_nl ||
    'AND    fxata.attribute_id = ' || gcs_translation_pkg.g_xat_basic_acct_type_attr_id || g_nl ||
    'AND    fxata.version_id = ' || gcs_translation_pkg.g_xat_basic_acct_type_v_id || g_nl ||
    'AND    ghr.entity_id(+) = ' || p_entity_id || g_nl ||
    'AND    ghr.hierarchy_id (+) = ' || p_hierarchy_id || g_nl ||
    'AND    ghr.from_currency (+) = ''' || p_from_ccy || '''' || g_nl ||
    'AND    ghr.to_currency (+) = ''' || p_to_ccy || '''' || g_nl ||
    'AND    ghr.cal_period_id (+) = ' || p_cal_period_id || g_nl ||
    'AND    ghr.line_item_id (+) = fb.line_item_id' || g_nl ||
    'AND    ghr.update_flag (+) = ''N'' ' || g_nl ||'');

          INSERT /*+ parallel (GCS_TRANSLATION_GT) */ INTO GCS_TRANSLATION_GT(
            translate_rule_code, account_type_code, line_item_id,
            company_cost_center_org_id, intercompany_id, financial_elem_id,
            product_id, natural_account_id, channel_id, project_id,
            customer_id, task_id, user_dim1_id, user_dim2_id, user_dim3_id,
            user_dim4_id, user_dim5_id, user_dim6_id, user_dim7_id, user_dim8_id,
            user_dim9_id, user_dim10_id, t_amount_dr, t_amount_cr, begin_ytd_dr,
            begin_ytd_cr, xlate_ptd_dr, xlate_ptd_cr, xlate_ytd_dr, xlate_ytd_cr)
          SELECT /*+ ordered */
            decode(fxata.dim_attribute_varchar_member,
                   'REVENUE', p_is_xlate_mode,
                   'EXPENSE', p_is_xlate_mode,
                   'EQUITY', p_eq_xlate_mode,
                        'YTD'),
            fxata.dim_attribute_varchar_member, fb.line_item_id,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,        0, 0, 0, 0,
            round(nvl(ghr.translated_amount * 0,
                      nvl(fb.sum_ytd_debit_balance_e, 0) *
                      nvl(ghr.translated_rate,
                          decode(fxata.dim_attribute_varchar_member,
                                 'REVENUE', is_rate,
                                 'EXPENSE', is_rate,
                                 'EQUITY', eq_rate,
                                      p_end_rate))) /
                  p_round_factor) *
            p_round_factor,
            round(nvl(ghr.translated_amount,
                      nvl(fb.sum_ytd_credit_balance_e, 0) *
                      nvl(ghr.translated_rate,
                          decode(fxata.dim_attribute_varchar_member,
                                 'REVENUE', is_rate,
                                 'EXPENSE', is_rate,
                                 'EQUITY', eq_rate,
                                      p_end_rate))) /
                  p_round_factor) *
            p_round_factor,
            round(nvl(ghr.translated_amount * 0,
                      nvl(fb.sum_ytd_debit_balance_e, 0) *
                      nvl(ghr.translated_rate,
                          decode(fxata.dim_attribute_varchar_member,
                                 'REVENUE', is_rate,
                                 'EXPENSE', is_rate,
                                 'EQUITY', eq_rate,
                                      p_end_rate))) /
                  p_round_factor) *
            p_round_factor,
            round(nvl(ghr.translated_amount,
                      nvl(fb.sum_ytd_credit_balance_e, 0) *
                      nvl(ghr.translated_rate,
                          decode(fxata.dim_attribute_varchar_member,
                                 'REVENUE', is_rate,
                                 'EXPENSE', is_rate,
                                 'EQUITY', eq_rate,
                                      p_end_rate))) /
                  p_round_factor) *
            p_round_factor
          FROM   (SELECT
                    fb_in.line_item_id,                ytd_debit_balance_e sum_ytd_debit_balance_e,
                    ytd_credit_balance_e sum_ytd_credit_balance_e
                  FROM   FEM_BALANCES fb_in
                  WHERE  fb_in.dataset_code = p_hier_dataset_code
                  AND    fb_in.cal_period_id = p_cal_period_id
                  AND    fb_in.source_system_code = p_source_system_code
                  AND    fb_in.currency_code = p_from_ccy
                  AND    fb_in.ledger_id = p_ledger_id
                  AND    fb_in.entity_id = p_entity_id) fb,
                 FEM_LN_ITEMS_ATTR li,
                 FEM_EXT_ACCT_TYPES_ATTR fxata,
                 GCS_HISTORICAL_RATES ghr
          WHERE  li.line_item_id = fb.line_item_id
          AND    li.attribute_id = gcs_translation_pkg.g_li_acct_type_attr_id
          AND    li.version_id = gcs_translation_pkg.g_li_acct_type_v_id
          AND    fxata.ext_account_type_code = li.dim_attribute_varchar_member
          AND    fxata.attribute_id = gcs_translation_pkg.g_xat_basic_acct_type_attr_id
          AND    fxata.version_id = gcs_translation_pkg.g_xat_basic_acct_type_v_id
          AND    ghr.entity_id(+) = p_entity_id
          AND    ghr.hierarchy_id (+) = p_hierarchy_id
          AND    ghr.from_currency (+) = p_from_ccy
          AND    ghr.to_currency (+) = p_to_ccy
          AND    ghr.cal_period_id (+) = p_cal_period_id
          AND    ghr.line_item_id (+) = fb.line_item_id
          AND    ghr.update_flag (+) = 'N'
          AND   NOT EXISTS (SELECT 'X'
                            FROM   gcs_historical_rates ghr_retained
                            WHERE  ghr_retained.standard_re_rate_flag = 'Y'
                            AND    ghr_retained.hierarchy_id          = p_hierarchy_id
                            AND    ghr_retained.entity_id             = p_entity_id
                            AND    ghr_retained.cal_period_id         = p_cal_period_id
                            AND    ghr_retained.line_item_id          = fb.line_item_id    );

        END IF;

        -- No data was found to translate.
        IF SQL%ROWCOUNT = 0 THEN
          raise GCS_CCY_NO_DATA;
        END IF;

        write_to_log(module, FND_LOG.LEVEL_PROCEDURE,g_module_success);
      EXCEPTION
        WHEN GCS_CCY_NO_DATA THEN
          FND_MESSAGE.set_name('GCS', 'GCS_CCY_NO_TRANSLATE_DATA_ERR');
          GCS_TRANSLATION_PKG.g_error_text := FND_MESSAGE.get;
          write_to_log(module, FND_LOG.LEVEL_UNEXPECTED, GCS_TRANSLATION_PKG.g_error_text);
          module_log_write(module, g_module_failure);
          raise GCS_TRANSLATION_PKG.GCS_CCY_SUBPROGRAM_RAISED;
        WHEN OTHERS THEN
          FND_MESSAGE.set_name('GCS', 'GCS_CCY_FIRST_UNEXPECTED_ERR');
          GCS_TRANSLATION_PKG.g_error_text := FND_MESSAGE.get;
          write_to_log(module, FND_LOG.LEVEL_UNEXPECTED, GCS_TRANSLATION_PKG.g_error_text);
          write_to_log(module, FND_LOG.LEVEL_UNEXPECTED, SQLERRM);
          module_log_write(module, g_module_failure);
          raise GCS_TRANSLATION_PKG.GCS_CCY_SUBPROGRAM_RAISED;
      END Trans_HRates_First_Per;


      --
      PROCEDURE Trans_HRates_Subseq_Per
        (p_hier_dataset_code       NUMBER,
         p_cal_period_id      NUMBER,
         p_prev_period_id     NUMBER,
         p_entity_id          NUMBER,
         p_hierarchy_id       NUMBER,
         p_ledger_id          NUMBER,
         p_from_ccy           VARCHAR2,
         p_to_ccy             VARCHAR2,
         p_eq_xlate_mode      VARCHAR2,
         p_is_xlate_mode      VARCHAR2,
         p_avg_rate           NUMBER,
         p_end_rate           NUMBER,
         p_group_by_flag      VARCHAR2,
         p_round_factor       NUMBER,
         p_source_system_code NUMBER,
         p_hier_li_id         NUMBER) IS

        -- Rate to use for equity accounts, income statement accounts if there
        -- are no historical rates defined.
        eq_rate   NUMBER;
        is_rate   NUMBER;

        fb_object_id NUMBER;
        CURSOR get_object_id IS
        SELECT cb.associated_object_id
        FROM   gcs_categories_b cb
        WHERE  cb.category_code = 'TRANSLATION';

        module    VARCHAR2(50) := 'TRANS_HRATES_SUBSEQ_PER';
      BEGIN
        module_log_write(module, g_module_enter);

        IF p_eq_xlate_mode = 'YTD' THEN
          eq_rate := p_end_rate;
        ELSE
          eq_rate := p_avg_rate;
        END IF;

        IF p_is_xlate_mode = 'YTD' THEN
          is_rate := p_end_rate;
        ELSE
          is_rate := p_avg_rate;
        END IF;

        OPEN get_object_id;
        FETCH get_object_id INTO fb_object_id;
        CLOSE get_object_id;

        IF p_group_by_flag = 'Y' THEN
          write_to_log(module, FND_LOG.LEVEL_STATEMENT,
    'INSERT  /*+ parallel (GCS_TRANSLATION_GT) */ INTO GCS_TRANSLATION_GT(translate_rule_code, account_type_code, ' ||
    'line_item_id, company_cost_center_org_id, ' ||
    'intercompany_id, financial_elem_id, product_id, ' ||
    'natural_account_id, channel_id, project_id, customer_id, task_id, ' ||
    'user_dim1_id, user_dim2_id, user_dim3_id, user_dim4_id, user_dim5_id, ' ||
    'user_dim6_id, user_dim7_id, user_dim8_id, user_dim9_id, user_dim10_id, ' ||
    't_amount_dr, t_amount_cr, begin_ytd_dr, begin_ytd_cr, xlate_ptd_dr, ' ||
    'xlate_ptd_cr, xlate_ytd_dr,xlate_ytd_cr)' || g_nl ||
    'SELECT' || g_nl ||
    'decode(fxata.dim_attribute_varchar_member,' || g_nl ||
    '       ''REVENUE'', ''' || p_is_xlate_mode || ''',' || g_nl ||
    '       ''EXPENSE'', ''' || p_is_xlate_mode || ''',' || g_nl ||
    '       ''EQUITY'', ''' || p_eq_xlate_mode || ''',' || g_nl ||
    '            ''YTD''),' || g_nl ||
    'fxata.dim_attribute_varchar_member, fb.line_item_id, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||g_nl ||
    'round(nvl(ghr.translated_amount * 0,' || g_nl ||
    '          nvl(decode(fxata.dim_attribute_varchar_member,' || g_nl ||
    '                     ''REVENUE'', decode(''' || p_is_xlate_mode || ''',' || g_nl ||
    '                                 ''YTD'', fb.sum_ytd_debit_balance_e,' || g_nl ||
    '                                        fb.sum_ptd_debit_balance_e),' || g_nl ||
    '                     ''EXPENSE'', decode(''' || p_is_xlate_mode || ''',' || g_nl ||
    '                                 ''YTD'', fb.sum_ytd_debit_balance_e,' || g_nl ||
    '                                        fb.sum_ptd_debit_balance_e),' || g_nl ||
    '                     ''EQUITY'', decode(''' || p_eq_xlate_mode || ''',' || g_nl ||
    '                                 ''YTD'', fb.sum_ytd_debit_balance_e,' || g_nl ||
    '                                        fb.sum_ptd_debit_balance_e),' || g_nl ||
    '                          fb.sum_ytd_debit_balance_e),' || g_nl ||
    '              0) *' || g_nl ||
    '          nvl(ghr.translated_rate,' || g_nl ||
    '              decode(fxata.dim_attribute_varchar_member,' || g_nl ||
    '                     ''REVENUE'', ' || is_rate || ',' || g_nl ||
    '                     ''EXPENSE'', ' || is_rate || ',' || g_nl ||
    '                     ''EQUITY'', ' || eq_rate || ',' || g_nl ||
    '                          ' || p_end_rate || '))) /' || g_nl ||
    '      ' || p_round_factor || ') *' || g_nl ||
    p_round_factor || ',' || g_nl ||
    'round(nvl(ghr.translated_amount,' || g_nl ||
    '          nvl(decode(fxata.dim_attribute_varchar_member,' || g_nl ||
    '                     ''REVENUE'', decode(''' || p_is_xlate_mode || ''',' || g_nl ||
    '                                 ''YTD'', fb.sum_ytd_credit_balance_e,' || g_nl ||
    '                                        fb.sum_ptd_credit_balance_e),' || g_nl ||
    '                     ''EXPENSE'', decode(''' || p_is_xlate_mode || ''',' || g_nl ||
    '                                 ''YTD'', fb.sum_ytd_credit_balance_e,' || g_nl ||
    '                                        fb.sum_ptd_credit_balance_e),' || g_nl ||
    '                     ''EQUITY'', decode(''' || p_eq_xlate_mode || ''',' || g_nl ||
    '                                 ''YTD'', fb.sum_ytd_credit_balance_e,' || g_nl ||
    '                                        fb.sum_ptd_credit_balance_e),' || g_nl ||
    '                          fb.sum_ytd_credit_balance_e),' || g_nl ||
    '              0) *' || g_nl ||
    '          nvl(ghr.translated_rate,' || g_nl ||
    '              decode(fxata.dim_attribute_varchar_member,' || g_nl ||
    '                     ''REVENUE'', ' || is_rate || ',' || g_nl ||
    '                     ''EXPENSE'', ' || is_rate || ',' || g_nl ||
    '                     ''EQUITY'', ' || eq_rate || ',' || g_nl ||
    '                          ' || p_end_rate || '))) /' || g_nl ||
    '      ' || p_round_factor || ') *' || g_nl ||
    p_round_factor || ',' || g_nl ||
    'nvl(fbp.ytd_debit_balance_e,0),' || g_nl ||
    'nvl(fbp.ytd_credit_balance_e,0), 0, 0, 0, 0' || g_nl ||
    'FROM   (SELECT' || g_nl ||
    '          fb_in.line_item_id,' || g_nl ||'          SUM(ptd_debit_balance_e) sum_ptd_debit_balance_e,' || g_nl ||
    '          SUM(ptd_credit_balance_e) sum_ptd_credit_balance_e,' || g_nl ||
    '          SUM(ytd_debit_balance_e) sum_ytd_debit_balance_e,' || g_nl ||
    '          SUM(ytd_credit_balance_e) sum_ytd_credit_balance_e' || g_nl ||
    '        FROM   FEM_BALANCES fb_in' || g_nl ||
    '        WHERE  fb_in.dataset_code = ' || p_hier_dataset_code || g_nl ||
    '        AND    fb_in.cal_period_id = ' || p_cal_period_id || g_nl ||
    '        AND    fb_in.source_system_code = ' || p_source_system_code || g_nl ||
    '        AND    fb_in.currency_code = ''' || p_from_ccy || '''' || g_nl ||
    '        AND    fb_in.ledger_id = ' || p_ledger_id || g_nl ||
    '        AND    fb_in.entity_id = ' || p_entity_id || g_nl ||
    '        GROUP BY ' || g_nl ||'          fb_in.line_item_id) fb,' || g_nl ||
    '       FEM_BALANCES fbp,' || g_nl ||
    '       GCS_HISTORICAL_RATES ghr,' || g_nl ||
    '       FEM_LN_ITEMS_ATTR li,' || g_nl ||
    '       FEM_EXT_ACCT_TYPES_ATTR fxata' || g_nl ||
    'WHERE  fbp.created_by_object_id (+)= ' || fb_object_id || g_nl ||
    'AND    li.line_item_id = fb.line_item_id' || g_nl ||
    'AND    li.attribute_id = ' || gcs_translation_pkg.g_li_acct_type_attr_id || g_nl ||
    'AND    li.version_id = ' || gcs_translation_pkg.g_li_acct_type_v_id || g_nl ||
    'AND    fxata.ext_account_type_code = li.dim_attribute_varchar_member' || g_nl ||
    'AND    fxata.attribute_id = ' || gcs_translation_pkg.g_xat_basic_acct_type_attr_id || g_nl ||
    'AND    fxata.version_id = ' || gcs_translation_pkg.g_xat_basic_acct_type_v_id || g_nl ||
    'AND    fbp.dataset_code (+)= ' || p_hier_dataset_code || g_nl ||
    'AND    fbp.cal_period_id (+)= ' || p_prev_period_id || g_nl ||
    'AND    fbp.source_system_code (+)= ' || p_source_system_code || g_nl ||
    'AND    fbp.currency_code (+)= ''' || p_to_ccy || '''' || g_nl ||
    'AND    fbp.ledger_id (+)= ' || p_ledger_id || g_nl ||
    'AND    fbp.entity_id (+)= ' || p_entity_id || g_nl ||
    'AND    fbp.line_item_id (+)= fb.line_item_id' || g_nl || 'AND    ghr.entity_id (+)= ' || p_entity_id || g_nl ||
    'AND    ghr.hierarchy_id (+)= ' || p_hierarchy_id || g_nl ||
    'AND    ghr.from_currency (+)= ''' || p_from_ccy || '''' || g_nl ||
    'AND    ghr.to_currency (+)= ''' || p_to_ccy || '''' || g_nl ||
    'AND    ghr.cal_period_id (+)= ' || p_cal_period_id || g_nl ||
    'AND    ghr.line_item_id (+)= fb.line_item_id' || g_nl ||
    'AND    ghr.update_flag (+)= ''N''' || g_nl ||'');

          INSERT /*+ parallel (GCS_TRANSLATION_GT) */ INTO GCS_TRANSLATION_GT(
            translate_rule_code, account_type_code, line_item_id,
            company_cost_center_org_id, intercompany_id, financial_elem_id,
            product_id, natural_account_id, channel_id, project_id,
            customer_id, task_id, user_dim1_id, user_dim2_id, user_dim3_id,
            user_dim4_id, user_dim5_id, user_dim6_id, user_dim7_id, user_dim8_id,
            user_dim9_id, user_dim10_id, t_amount_dr, t_amount_cr, begin_ytd_dr,
            begin_ytd_cr, xlate_ptd_dr, xlate_ptd_cr, xlate_ytd_dr,xlate_ytd_cr)
          SELECT
            decode(fxata.dim_attribute_varchar_member,
                   'REVENUE', p_is_xlate_mode,
                   'EXPENSE', p_is_xlate_mode,
                   'EQUITY', p_eq_xlate_mode,
                        'YTD'),
            fxata.dim_attribute_varchar_member, fb.line_item_id,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,        round(nvl(ghr.translated_amount * 0,
                        nvl(decode(fxata.dim_attribute_varchar_member,
                                 'REVENUE', decode(p_is_xlate_mode,
                                             'YTD', fb.sum_ytd_debit_balance_e,
                                                    fb.sum_ptd_debit_balance_e),
                                 'EXPENSE', decode(p_is_xlate_mode,
                                             'YTD', fb.sum_ytd_debit_balance_e,
                                                    fb.sum_ptd_debit_balance_e),
                                 'EQUITY', decode(p_eq_xlate_mode,
                                             'YTD', fb.sum_ytd_debit_balance_e,
                                                    fb.sum_ptd_debit_balance_e),
                                      fb.sum_ytd_debit_balance_e),
                            0) *
                        nvl(ghr.translated_rate,
                            decode(fxata.dim_attribute_varchar_member,
                                 'REVENUE', is_rate,
                                 'EXPENSE', is_rate,
                                 'EQUITY', eq_rate,
                                      p_end_rate))) /
                    p_round_factor) *
              p_round_factor,
            round(nvl(ghr.translated_amount,
                        nvl(decode(fxata.dim_attribute_varchar_member,
                                 'REVENUE', decode(p_is_xlate_mode,
                                             'YTD', fb.sum_ytd_credit_balance_e,
                                                    fb.sum_ptd_credit_balance_e),
                                 'EXPENSE', decode(p_is_xlate_mode,
                                             'YTD', fb.sum_ytd_credit_balance_e,
                                                    fb.sum_ptd_credit_balance_e),
                                 'EQUITY', decode(p_eq_xlate_mode,
                                             'YTD', fb.sum_ytd_credit_balance_e,
                                                    fb.sum_ptd_credit_balance_e),
                                      fb.sum_ytd_credit_balance_e),
                            0) *
                        nvl(ghr.translated_rate,
                            decode(fxata.dim_attribute_varchar_member,
                                 'REVENUE', is_rate,
                                 'EXPENSE', is_rate,
                                 'EQUITY', eq_rate,
                                      p_end_rate))) /
                    p_round_factor) *
              p_round_factor,
            nvl(fbp.ytd_debit_balance_e,0),
            nvl(fbp.ytd_credit_balance_e,0), 0,0,0,0
          FROM   (SELECT
                    fb_in.line_item_id,                 SUM(ptd_debit_balance_e) sum_ptd_debit_balance_e,
                    SUM(ptd_credit_balance_e) sum_ptd_credit_balance_e,
                    SUM(ytd_debit_balance_e) sum_ytd_debit_balance_e,
                    SUM(ytd_credit_balance_e) sum_ytd_credit_balance_e
                  FROM   FEM_BALANCES fb_in
                  WHERE  fb_in.dataset_code = p_hier_dataset_code
                  AND    fb_in.cal_period_id = p_cal_period_id
                  AND    fb_in.source_system_code = p_source_system_code
                  AND    fb_in.currency_code = p_from_ccy
                  AND    fb_in.ledger_id = p_ledger_id
                  AND    fb_in.entity_id = p_entity_id
                  GROUP BY             fb_in.line_item_id) fb,
                 FEM_BALANCES fbp,
                 GCS_HISTORICAL_RATES ghr,
                 FEM_LN_ITEMS_ATTR li,
                 FEM_EXT_ACCT_TYPES_ATTR fxata
          WHERE  fbp.created_by_object_id (+)= fb_object_id
          AND    li.line_item_id = fb.line_item_id
          AND    li.attribute_id = gcs_translation_pkg.g_li_acct_type_attr_id
          AND    li.version_id = gcs_translation_pkg.g_li_acct_type_v_id
          AND    fxata.ext_account_type_code = li.dim_attribute_varchar_member
          AND    fxata.attribute_id = gcs_translation_pkg.g_xat_basic_acct_type_attr_id
          AND    fxata.version_id = gcs_translation_pkg.g_xat_basic_acct_type_v_id
          AND    fbp.dataset_code (+)= p_hier_dataset_code
          AND    fbp.cal_period_id (+)= p_prev_period_id
          AND    fbp.source_system_code (+)= p_source_system_code
          AND    fbp.currency_code (+)= p_to_ccy
          AND    fbp.ledger_id (+)= p_ledger_id
          AND    fbp.entity_id (+)= p_entity_id
          AND    fbp.line_item_id (+)= fb.line_item_id      AND    ghr.entity_id (+)= p_entity_id
          AND    ghr.hierarchy_id (+)= p_hierarchy_id
          AND    ghr.from_currency (+)= p_from_ccy
          AND    ghr.to_currency (+)= p_to_ccy
          AND    ghr.cal_period_id (+)= p_cal_period_id
          AND    ghr.line_item_id (+)= fb.line_item_id
          AND    ghr.update_flag (+)= 'N'
          AND   NOT EXISTS (SELECT 'X'
                            FROM   gcs_historical_rates ghr_retained
                            WHERE  ghr_retained.standard_re_rate_flag = 'Y'
                            AND    ghr_retained.hierarchy_id          = p_hierarchy_id
                            AND    ghr_retained.entity_id             = p_entity_id
                            AND    ghr_retained.cal_period_id         = p_cal_period_id
                            AND    ghr_retained.line_item_id          = fb.line_item_id    );

        ELSE
          write_to_log(module, FND_LOG.LEVEL_STATEMENT,
    'INSERT  /*+ parallel (GCS_TRANSLATION_GT) */ INTO GCS_TRANSLATION_GT(translate_rule_code, account_type_code, ' ||
    'line_item_id, company_cost_center_org_id, ' ||
    'intercompany_id, financial_elem_id, product_id, ' ||
    'natural_account_id, channel_id, project_id, customer_id, task_id, ' ||
    'user_dim1_id, user_dim2_id, user_dim3_id, user_dim4_id, user_dim5_id, ' ||
    'user_dim6_id, user_dim7_id, user_dim8_id, user_dim9_id, user_dim10_id, ' ||
    't_amount_dr, t_amount_cr, begin_ytd_dr, begin_ytd_cr, xlate_ptd_dr, ' ||
    'xlate_ptd_cr, xlate_ytd_dr,xlate_ytd_cr)' || g_nl ||
    'SELECT' || g_nl ||
    'decode(fxata.dim_attribute_varchar_member,' || g_nl ||
    '       ''REVENUE'', ''' || p_is_xlate_mode || ''',' || g_nl ||
    '       ''EXPENSE'', ''' || p_is_xlate_mode || ''',' || g_nl ||
    '       ''EQUITY'', ''' || p_eq_xlate_mode || ''',' || g_nl ||
    '            ''YTD''),' || g_nl ||
    'fxata.dim_attribute_varchar_member, fb.line_item_id, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||'NULL, ' ||g_nl ||
    'round(nvl(ghr.translated_amount * 0,' || g_nl ||
    '          nvl(decode(fxata.dim_attribute_varchar_member,' || g_nl ||
    '                     ''REVENUE'', decode(''' || p_is_xlate_mode || ''',' || g_nl ||
    '                                 ''YTD'', fb.sum_ytd_debit_balance_e,' || g_nl ||
    '                                        fb.sum_ptd_debit_balance_e),' || g_nl ||
    '                     ''EXPENSE'', decode(''' || p_is_xlate_mode || ''',' || g_nl ||
    '                                 ''YTD'', fb.sum_ytd_debit_balance_e,' || g_nl ||
    '                                        fb.sum_ptd_debit_balance_e),' || g_nl ||
    '                     ''EQUITY'', decode(''' || p_eq_xlate_mode || ''',' || g_nl ||
    '                                 ''YTD'', fb.sum_ytd_debit_balance_e,' || g_nl ||
    '                                        fb.sum_ptd_debit_balance_e),' || g_nl ||
    '                          fb.sum_ytd_debit_balance_e),' || g_nl ||
    '              0) *' || g_nl ||
    '          nvl(ghr.translated_rate,' || g_nl ||
    '              decode(fxata.dim_attribute_varchar_member,' || g_nl ||
    '                     ''REVENUE'', ' || is_rate || ',' || g_nl ||
    '                     ''EXPENSE'', ' || is_rate || ',' || g_nl ||
    '                     ''EQUITY'', ' || eq_rate || ',' || g_nl ||
    '                          ' || p_end_rate || '))) /' || g_nl ||
    '      ' || p_round_factor || ') *' || g_nl ||
    p_round_factor || ',' || g_nl ||
    'round(nvl(ghr.translated_amount,' || g_nl ||
    '          nvl(decode(fxata.dim_attribute_varchar_member,' || g_nl ||
    '                     ''REVENUE'', decode(''' || p_is_xlate_mode || ''',' || g_nl ||
    '                                 ''YTD'', fb.sum_ytd_credit_balance_e,' || g_nl ||
    '                                        fb.sum_ptd_credit_balance_e),' || g_nl ||
    '                     ''EXPENSE'', decode(''' || p_is_xlate_mode || ''',' || g_nl ||
    '                                 ''YTD'', fb.sum_ytd_credit_balance_e,' || g_nl ||
    '                                        fb.sum_ptd_credit_balance_e),' || g_nl ||
    '                     ''EQUITY'', decode(''' || p_eq_xlate_mode || ''',' || g_nl ||
    '                                 ''YTD'', fb.sum_ytd_credit_balance_e,' || g_nl ||
    '                                        fb.sum_ptd_credit_balance_e),' || g_nl ||
    '                          fb.sum_ytd_credit_balance_e),' || g_nl ||
    '              0) *' || g_nl ||
    '          nvl(ghr.translated_rate,' || g_nl ||
    '              decode(fxata.dim_attribute_varchar_member,' || g_nl ||
    '                     ''REVENUE'', ' || is_rate || ',' || g_nl ||
    '                     ''EXPENSE'', ' || is_rate || ',' || g_nl ||
    '                     ''EQUITY'', ' || eq_rate || ',' || g_nl ||
    '                          ' || p_end_rate || '))) /' || g_nl ||
    '      ' || p_round_factor || ') *' || g_nl ||
    p_round_factor || ',' || g_nl ||
    'nvl(fbp.ytd_debit_balance_e,0),' || g_nl ||
    'nvl(fbp.ytd_credit_balance_e,0), 0, 0, 0, 0' || g_nl ||
    'FROM   (SELECT' || g_nl ||
    '          fb_in.line_item_id,' || g_nl ||'          ptd_debit_balance_e sum_ptd_debit_balance_e,' || g_nl ||
    '          ptd_credit_balance_e sum_ptd_credit_balance_e,' || g_nl ||
    '          ytd_debit_balance_e sum_ytd_debit_balance_e,' || g_nl ||
    '          ytd_credit_balance_e sum_ytd_credit_balance_e' || g_nl ||
    '        FROM   FEM_BALANCES fb_in' || g_nl ||
    '        WHERE  fb_in.dataset_code = ' || p_hier_dataset_code || g_nl ||
    '        AND    fb_in.cal_period_id = ' || p_cal_period_id || g_nl ||
    '        AND    fb_in.source_system_code = ' || p_source_system_code || g_nl ||
    '        AND    fb_in.currency_code = ''' || p_from_ccy || '''' || g_nl ||
    '        AND    fb_in.ledger_id = ' || p_ledger_id || g_nl ||
    '        AND    fb_in.entity_id = ' || p_entity_id || ') fb,' || g_nl ||
    '       FEM_BALANCES fbp,' || g_nl ||
    '       GCS_HISTORICAL_RATES ghr,' || g_nl ||
    '       FEM_LN_ITEMS_ATTR li,' || g_nl ||
    '       FEM_EXT_ACCT_TYPES_ATTR fxata' || g_nl ||
    'WHERE  fbp.created_by_object_id (+)= ' || fb_object_id || g_nl ||
    'AND    li.line_item_id = fb.line_item_id' || g_nl ||
    'AND    li.attribute_id = ' || gcs_translation_pkg.g_li_acct_type_attr_id || g_nl ||
    'AND    li.version_id = ' || gcs_translation_pkg.g_li_acct_type_v_id || g_nl ||
    'AND    fxata.ext_account_type_code = li.dim_attribute_varchar_member' || g_nl ||
    'AND    fxata.attribute_id = ' || gcs_translation_pkg.g_xat_basic_acct_type_attr_id || g_nl ||
    'AND    fxata.version_id = ' || gcs_translation_pkg.g_xat_basic_acct_type_v_id || g_nl ||
    'AND    fbp.dataset_code (+)= ' || p_hier_dataset_code || g_nl ||
    'AND    fbp.cal_period_id (+)= ' || p_prev_period_id || g_nl ||
    'AND    fbp.source_system_code (+)= ' || p_source_system_code || g_nl ||
    'AND    fbp.currency_code (+)= ''' || p_to_ccy || '''' || g_nl ||
    'AND    fbp.ledger_id (+)= ' || p_ledger_id || g_nl ||
    'AND    fbp.entity_id (+)= ' || p_entity_id || g_nl ||
    'AND    fbp.line_item_id (+)= fb.line_item_id' || g_nl ||'AND    ghr.entity_id (+)= ' || p_entity_id || g_nl ||
    'AND    ghr.hierarchy_id (+)= ' || p_hierarchy_id || g_nl ||
    'AND    ghr.from_currency (+)= ''' || p_from_ccy || '''' || g_nl ||
    'AND    ghr.to_currency (+)= ''' || p_to_ccy || '''' || g_nl ||
    'AND    ghr.cal_period_id (+)= ' || p_cal_period_id || g_nl ||
    'AND    ghr.line_item_id (+)= fb.line_item_id' || g_nl ||
    'AND    ghr.update_flag (+)= ''N''' || g_nl ||'');

          INSERT /*+ parallel (GCS_TRANSLATION_GT) */ INTO GCS_TRANSLATION_GT(
            translate_rule_code, account_type_code, line_item_id,
            company_cost_center_org_id, intercompany_id, financial_elem_id,
            product_id, natural_account_id, channel_id, project_id,
            customer_id, task_id, user_dim1_id, user_dim2_id, user_dim3_id,
            user_dim4_id, user_dim5_id, user_dim6_id, user_dim7_id, user_dim8_id,
            user_dim9_id, user_dim10_id, t_amount_dr, t_amount_cr, begin_ytd_dr,
            begin_ytd_cr, xlate_ptd_dr, xlate_ptd_cr, xlate_ytd_dr,xlate_ytd_cr)
          SELECT
            decode(fxata.dim_attribute_varchar_member,
                   'REVENUE', p_is_xlate_mode,
                   'EXPENSE', p_is_xlate_mode,
                   'EQUITY', p_eq_xlate_mode,
                        'YTD'),
            fxata.dim_attribute_varchar_member, fb.line_item_id,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,      NULL,        round(nvl(ghr.translated_amount * 0,
                        nvl(decode(fxata.dim_attribute_varchar_member,
                                 'REVENUE', decode(p_is_xlate_mode,
                                             'YTD', fb.sum_ytd_debit_balance_e,
                                                    fb.sum_ptd_debit_balance_e),
                                 'EXPENSE', decode(p_is_xlate_mode,
                                             'YTD', fb.sum_ytd_debit_balance_e,
                                                    fb.sum_ptd_debit_balance_e),
                                 'EQUITY', decode(p_eq_xlate_mode,
                                             'YTD', fb.sum_ytd_debit_balance_e,
                                                    fb.sum_ptd_debit_balance_e),
                                      fb.sum_ytd_debit_balance_e),
                            0) *
                        nvl(ghr.translated_rate,
                            decode(fxata.dim_attribute_varchar_member,
                                 'REVENUE', is_rate,
                                 'EXPENSE', is_rate,
                                 'EQUITY', eq_rate,
                                      p_end_rate))) /
                    p_round_factor) *
              p_round_factor,
            round(nvl(ghr.translated_amount,
                        nvl(decode(fxata.dim_attribute_varchar_member,
                                 'REVENUE', decode(p_is_xlate_mode,
                                             'YTD', fb.sum_ytd_credit_balance_e,
                                                    fb.sum_ptd_credit_balance_e),
                                 'EXPENSE', decode(p_is_xlate_mode,
                                             'YTD', fb.sum_ytd_credit_balance_e,
                                                    fb.sum_ptd_credit_balance_e),
                                 'EQUITY', decode(p_eq_xlate_mode,
                                             'YTD', fb.sum_ytd_credit_balance_e,
                                                    fb.sum_ptd_credit_balance_e),
                                      fb.sum_ytd_credit_balance_e),
                            0) *
                        nvl(ghr.translated_rate,
                            decode(fxata.dim_attribute_varchar_member,
                                 'REVENUE', is_rate,
                                 'EXPENSE', is_rate,
                                 'EQUITY', eq_rate,
                                      p_end_rate))) /
                    p_round_factor) *
              p_round_factor,
            nvl(fbp.ytd_debit_balance_e,0),
            nvl(fbp.ytd_credit_balance_e,0), 0,0,0,0
          FROM   (SELECT
                    fb_in.line_item_id,                ptd_debit_balance_e sum_ptd_debit_balance_e,
                    ptd_credit_balance_e sum_ptd_credit_balance_e,
                    ytd_debit_balance_e sum_ytd_debit_balance_e,
                    ytd_credit_balance_e sum_ytd_credit_balance_e
                  FROM   FEM_BALANCES fb_in
                  WHERE  fb_in.dataset_code = p_hier_dataset_code
                  AND    fb_in.cal_period_id = p_cal_period_id
                  AND    fb_in.source_system_code = p_source_system_code
                  AND    fb_in.currency_code = p_from_ccy
                  AND    fb_in.ledger_id = p_ledger_id
                  AND    fb_in.entity_id = p_entity_id) fb,
                 FEM_BALANCES fbp,
                 GCS_HISTORICAL_RATES ghr,
                 FEM_LN_ITEMS_ATTR li,
                 FEM_EXT_ACCT_TYPES_ATTR fxata
          WHERE  fbp.created_by_object_id (+)= fb_object_id
          AND    li.line_item_id = fb.line_item_id
          AND    li.attribute_id = gcs_translation_pkg.g_li_acct_type_attr_id
          AND    li.version_id = gcs_translation_pkg.g_li_acct_type_v_id
          AND    fxata.ext_account_type_code = li.dim_attribute_varchar_member
          AND    fxata.attribute_id = gcs_translation_pkg.g_xat_basic_acct_type_attr_id
          AND    fxata.version_id = gcs_translation_pkg.g_xat_basic_acct_type_v_id
          AND    fbp.dataset_code (+)= p_hier_dataset_code
          AND    fbp.cal_period_id (+)= p_prev_period_id
          AND    fbp.source_system_code (+)= p_source_system_code
          AND    fbp.currency_code (+)= p_to_ccy
          AND    fbp.ledger_id (+)= p_ledger_id
          AND    fbp.entity_id (+)= p_entity_id
          AND    fbp.line_item_id (+)= fb.line_item_id      AND    ghr.entity_id (+)= p_entity_id
          AND    ghr.hierarchy_id (+)= p_hierarchy_id
          AND    ghr.from_currency (+)= p_from_ccy
          AND    ghr.to_currency (+)= p_to_ccy
          AND    ghr.cal_period_id (+)= p_cal_period_id
          AND    ghr.line_item_id (+)= fb.line_item_id
          AND    ghr.update_flag (+)= 'N'
          AND   NOT EXISTS (SELECT 'X'
                            FROM   gcs_historical_rates ghr_retained
                            WHERE  ghr_retained.standard_re_rate_flag = 'Y'
                            AND    ghr_retained.hierarchy_id          = p_hierarchy_id
                            AND    ghr_retained.entity_id             = p_entity_id
                            AND    ghr_retained.cal_period_id         = p_cal_period_id
                            AND    ghr_retained.line_item_id          = fb.line_item_id    );

        END IF;

        -- No data was found to translate.
        IF SQL%ROWCOUNT = 0 THEN
          raise GCS_CCY_NO_DATA;
        END IF;

        write_to_log(module, FND_LOG.LEVEL_PROCEDURE,g_module_success);
      EXCEPTION
        WHEN GCS_CCY_NO_DATA THEN
          FND_MESSAGE.set_name('GCS', 'GCS_CCY_NO_TRANSLATE_DATA_ERR');
          GCS_TRANSLATION_PKG.g_error_text := FND_MESSAGE.get;
          write_to_log(module, FND_LOG.LEVEL_UNEXPECTED, GCS_TRANSLATION_PKG.g_error_text);
          module_log_write(module, g_module_failure);
          raise GCS_TRANSLATION_PKG.GCS_CCY_SUBPROGRAM_RAISED;
        WHEN OTHERS THEN
          FND_MESSAGE.set_name('GCS', 'GCS_CCY_SUBSQ_UNEXPECTED_ERR');
          GCS_TRANSLATION_PKG.g_error_text := FND_MESSAGE.get;
          write_to_log(module, FND_LOG.LEVEL_UNEXPECTED, GCS_TRANSLATION_PKG.g_error_text);
          write_to_log(module, FND_LOG.LEVEL_UNEXPECTED, SQLERRM);
          module_log_write(module, g_module_failure);
          raise GCS_TRANSLATION_PKG.GCS_CCY_SUBPROGRAM_RAISED;
      END Trans_HRates_Subseq_Per;

    END GCS_TRANS_HRATES_DYNAMIC_PKG;

/
