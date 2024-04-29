--------------------------------------------------------
--  DDL for Package Body GCS_TRANS_DYNAMIC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_TRANS_DYNAMIC_PKG" AS
 
  -- The API name
  g_api             VARCHAR2(50) := 'gcs.plsql.GCS_TRANS_DYNAMIC_PKG';
 
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
  --   GCS_TRANSLATION_PKG.Module_Log_Write
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
  --   GCS_TRANSLATION_PKG.Write_To_Log
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
  -- Function
  --   Get_RE_Data_Exists
  -- Purpose
  --   Determines whether the data was loaded for the given combination or not.
  -- Arguments
  --   p_hier_dataset_code   The dataset code in FEM_BALANCES.
  --   p_cal_period_id       The current period's cal_period_id.
  --   p_source_system_code  GCS source system code.
  --   p_from_ccy            From currency code.
  --   p_ledger_id           The ledger in FEM_BALANCES.
  --   p_entity_id           Entity on which the translation is being performed.
  --   p_line_item_id        Line Item Id of retained earnings selected for the hierarchy.
  -- Example
  --   GCS_TRANSLATION_PKG.Get_RE_Data_Exists
  -- Notes
  --
 
  FUNCTION Get_RE_Data_Exists(
                     p_hier_dataset_code  NUMBER,
                     p_cal_period_id      NUMBER,
                     p_source_system_code NUMBER,
                     p_from_ccy           VARCHAR2,
                     p_ledger_id          NUMBER,
                     p_entity_id          NUMBER,
                     p_line_item_id       NUMBER) RETURN VARCHAR2 IS
 
    l_re_data_flag VARCHAR2(10);
    CURSOR re_data_cur (
                     p_hier_dataset_code  NUMBER,
                     p_cal_period_id      NUMBER,
                     p_source_system_code NUMBER,
                     p_from_ccy           VARCHAR2,
                     p_ledger_id          NUMBER,
                     p_entity_id          NUMBER,
                     p_line_item_id       NUMBER) IS
    SELECT 'X'
      FROM FEM_BALANCES fb
     WHERE fb.dataset_code       =  p_hier_dataset_code
       AND fb.cal_period_id      =  p_cal_period_id
       AND fb.source_system_code =  p_source_system_code
       AND fb.currency_code      =  p_from_ccy
       AND fb.ledger_id          =  p_ledger_id
       AND fb.entity_id          =  p_entity_id
       AND fb.line_item_id       =  p_line_item_id;
 
  BEGIN
    OPEN re_data_cur (
                     p_hier_dataset_code,
                     p_cal_period_id,
                     p_source_system_code,
                     p_from_ccy,
                     p_ledger_id,
                     p_entity_id,
                     p_line_item_id);
    FETCH re_data_cur INTO l_re_data_flag;
    CLOSE re_data_cur;
 
    IF l_re_data_flag IS NOT NULL THEN
      l_re_data_flag := 'Y';
    ELSE
      l_re_data_flag := 'N';
    END IF;
 
    RETURN l_re_data_flag;
 
  END Get_RE_Data_Exists;
 
 
--
-- Public procedures
--
 
 
   PROCEDURE Initialize_Data_Load_Status (
                   p_hier_dataset_code  NUMBER,
                   p_cal_period_id      NUMBER,
                   p_source_system_code NUMBER,
                   p_from_ccy           VARCHAR2,
                   p_ledger_id          NUMBER,
                   p_entity_id          NUMBER,
                   p_line_item_id       NUMBER) IS
   BEGIN
     re_data_loaded_flag :=
              Get_RE_Data_Exists (
                       p_hier_dataset_code,
                       p_cal_period_id,
                       p_source_system_code,
                       p_from_ccy,
                       p_ledger_id,
                       p_entity_id,
                       p_line_item_id);
   END;
 
 
-- Start bugfix 5707630: Added public procedure for Roll_Forward_Rates, 
-- Translate_First_Ever_Period, Translate_Subsequent_Period and 
-- Create_New_Entry procedures.This public procedures will call theier respective
-- private procedures (one for historical rates and the other for retained earnings).
--
  PROCEDURE Roll_Forward_Rates
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
    module    VARCHAR2(30) := 'ROLL_FORWARD_RATES:PUBLIC';
  BEGIN
    write_to_log(module, FND_LOG.LEVEL_PROCEDURE,g_module_enter);
 
    GCS_TRANS_HRATES_DYNAMIC_PKG.Roll_Forward_Historical_Rates
      (p_hier_dataset_code, 
       p_source_system_code, 
       p_ledger_id, 
       p_cal_period_id, 
       p_prev_period_id, 
       p_entity_id, 
       p_hierarchy_id, 
       p_from_ccy, 
       p_to_ccy, 
       p_eq_xlate_mode, 
       p_hier_li_id);
 
    GCS_TRANS_RE_DYNAMIC_PKG.Roll_Forward_Retained_Earnings
      (p_hier_dataset_code, 
       p_source_system_code, 
       p_ledger_id, 
       p_cal_period_id, 
       p_prev_period_id, 
       p_entity_id, 
       p_hierarchy_id, 
       p_from_ccy, 
       p_to_ccy, 
       p_eq_xlate_mode, 
       p_hier_li_id);
 
    write_to_log(module, FND_LOG.LEVEL_PROCEDURE,g_module_success);
  END Roll_Forward_Rates;
 
 
--
  PROCEDURE Translate_First_Ever_Period
    (p_hier_dataset_code  NUMBER,
     p_source_system_code NUMBER,
     p_ledger_id          NUMBER,
     p_cal_period_id      NUMBER,
     p_entity_id          NUMBER,
     p_hierarchy_id       NUMBER,
     p_from_ccy           VARCHAR2,
     p_to_ccy             VARCHAR2,
     p_eq_xlate_mode      VARCHAR2,
     p_is_xlate_mode      VARCHAR2,
     p_avg_rate           NUMBER,
     p_end_rate           NUMBER,
     p_group_by_flag      VARCHAR2,
     p_round_factor       NUMBER,
     p_hier_li_id         NUMBER) IS
    module    VARCHAR2(50) := 'TRANSLATE_FIRST_EVER_PERIOD:PUBLIC';
  BEGIN
    write_to_log(module, FND_LOG.LEVEL_PROCEDURE,g_module_enter);
 
    GCS_TRANS_HRATES_DYNAMIC_PKG.Trans_HRates_First_Per
      (p_hier_dataset_code,
       p_source_system_code,
       p_ledger_id,
       p_cal_period_id,
       p_entity_id,
       p_hierarchy_id,
       p_from_ccy,
       p_to_ccy,
       p_eq_xlate_mode,
       p_is_xlate_mode,
       p_avg_rate,
       p_end_rate,
       p_group_by_flag,
        p_round_factor,
       p_hier_li_id);
 
    IF re_data_loaded_flag = 'Y' THEN
    GCS_TRANS_RE_DYNAMIC_PKG.Trans_RE_First_Per
      (p_hier_dataset_code,
       p_source_system_code,
       p_ledger_id,
       p_cal_period_id,
       p_entity_id,
       p_hierarchy_id,
       p_from_ccy,
       p_to_ccy,
       p_eq_xlate_mode,
       p_is_xlate_mode,
       p_avg_rate,
       p_end_rate,
       p_group_by_flag,
       p_round_factor,
       p_hier_li_id);
    END IF;
 
    write_to_log(module, FND_LOG.LEVEL_PROCEDURE,g_module_success);
  END Translate_First_Ever_Period;
 
 
--
  PROCEDURE Translate_Subsequent_Period
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
    module    VARCHAR2(50) := 'TRANSLATE_SUBSEQUENT_PERIOD:PUBLIC';
  BEGIN
    write_to_log(module, FND_LOG.LEVEL_PROCEDURE,g_module_enter);
 
    GCS_TRANS_HRATES_DYNAMIC_PKG.Trans_HRates_Subseq_Per
      (p_hier_dataset_code,
       p_cal_period_id,
       p_prev_period_id,
       p_entity_id,
       p_hierarchy_id,
       p_ledger_id,
       p_from_ccy,
       p_to_ccy,
       p_eq_xlate_mode,
       p_is_xlate_mode,
       p_avg_rate,
       p_end_rate,
       p_group_by_flag,
          p_round_factor,
       p_source_system_code,
       p_hier_li_id);
 
    IF re_data_loaded_flag = 'Y' THEN
    GCS_TRANS_RE_DYNAMIC_PKG.Trans_RE_Subseq_Per
      (p_hier_dataset_code,
       p_cal_period_id,
       p_prev_period_id,
       p_entity_id,
       p_hierarchy_id,
       p_ledger_id,
       p_from_ccy,
       p_to_ccy,
       p_eq_xlate_mode,
       p_is_xlate_mode,
       p_avg_rate,
       p_end_rate,
       p_group_by_flag,
       p_round_factor,
       p_source_system_code,
       p_hier_li_id);
    END IF;
 
    write_to_log(module, FND_LOG.LEVEL_PROCEDURE,g_module_success);
  END Translate_Subsequent_Period;
 
 
-- Create_New_Entry will not split as it does not use gcs_historical_rates table.
--
  PROCEDURE Create_New_Entry
    (p_new_entry_id			NUMBER,
     p_hierarchy_id			NUMBER,
     p_entity_id			NUMBER,
     p_cal_period_id		NUMBER,
     p_balance_type_code		VARCHAR2,
     p_to_ccy			VARCHAR2) IS
    module    VARCHAR2(50) := 'CREATE_NEW_ENTRY:PUBLIC';
    -- Used to keep information for gcs_entry_pkg.create_entry_header.
    errbuf        VARCHAR2(2000);
    retcode       VARCHAR2(2000);
 
    -- Used because we need an IN OUT parameter
    new_entry_id  NUMBER := p_new_entry_id;
 
  BEGIN
    write_to_log(module, FND_LOG.LEVEL_PROCEDURE,g_module_enter);
 
 
     -- Create the entry
     GCS_ENTRY_PKG.create_entry_header(
              x_errbuf                 => errbuf,
              x_retcode                => retcode,
              p_entry_id               => new_entry_id,
              p_hierarchy_id           => p_hierarchy_id,
              p_entity_id              => p_entity_id,
              p_start_cal_period_id    => p_cal_period_id,
              p_end_cal_period_id      => p_cal_period_id,
              p_entry_type_code        => 'AUTOMATIC',
              p_balance_type_code      => p_balance_type_code,
              p_currency_code          => p_to_ccy,
              p_process_code           => 'SINGLE_RUN_FOR_PERIOD',
              p_category_code          => 'TRANSLATION',
              p_xlate_flag             => 'Y',
              p_period_init_entry_flag => 'N');
 
     IF retcode IN (fnd_api.g_ret_sts_error, fnd_api.g_ret_sts_unexp_error) THEN
       raise GCS_CCY_ENTRY_CREATE_FAILED;
     END IF;
 
        write_to_log(module, FND_LOG.LEVEL_STATEMENT,
    'INSERT /*+ parallel (gcs_entry_lines) */ INTO gcs_entry_lines(entry_id, ' ||
    'line_item_id, company_cost_center_org_id, ' ||
    'intercompany_id, financial_elem_id, product_id, ' ||
    'natural_account_id, channel_id, project_id, customer_id, task_id, ' ||
    'user_dim1_id, user_dim2_id, user_dim3_id, user_dim4_id, user_dim5_id, ' ||
    'user_dim6_id, user_dim7_id, user_dim8_id, user_dim9_id, user_dim10_id, ' ||
    'xtd_balance_e, ytd_balance_e, ptd_debit_balance_e, ptd_credit_balance_e, ' ||
    'ytd_debit_balance_e, ytd_credit_balance_e, creation_date, created_by, ' ||
    'last_update_date, last_updated_by, last_update_login)' || g_nl ||
    'SELECT ' || p_new_entry_id || ', ' ||
    'tgt.line_item_id, ' ||
'NULL, ' ||
'NULL, ' ||
'NULL, ' ||
'NULL, ' ||
'NULL, ' ||
'NULL, ' ||
'NULL, ' ||
'NULL, ' ||
'NULL, ' ||
'NULL, ' ||
'NULL, ' ||
'NULL, ' ||
'NULL, ' ||
'NULL, ' ||
'NULL, ' ||
'NULL, ' ||
'NULL, ' ||
'NULL, ' ||
'NULL, ' ||
    g_nl ||
    'fxata.number_assign_value *' || g_nl ||
    'decode(tgt.account_type_code,' || g_nl ||
    '       ''REVENUE'', tgt.xlate_ptd_dr - tgt.xlate_ptd_cr,' || g_nl ||
    '       ''EXPENSE'', tgt.xlate_ptd_dr - tgt.xlate_ptd_cr,' || g_nl ||
    '            tgt.xlate_ytd_dr - tgt.xlate_ytd_cr),' || g_nl ||
    'fxata.number_assign_value * (tgt.xlate_ytd_dr - tgt.xlate_ytd_cr),' || g_nl ||
    'tgt.xlate_ptd_dr, tgt.xlate_ptd_cr, tgt.xlate_ytd_dr, tgt.xlate_ytd_cr, sysdate, ' ||
    gcs_translation_pkg.g_fnd_user_id || ', sysdate, ' ||
    gcs_translation_pkg.g_fnd_user_id || ', ' ||
    gcs_translation_pkg.g_fnd_login_id || g_nl ||
    'FROM   gcs_translation_gt, tgt,' || g_nl ||
    '       fem_ln_items_attr li,' || g_nl ||
    '       fem_ext_acct_types_attr fxata' || g_nl ||
    'WHERE  li.line_item_id = tgt.line_item_id' || g_nl ||
    'AND    li.attribute_id = ' || gcs_translation_pkg.g_li_acct_type_attr_id || g_nl ||
    'AND    li.version_id = ' || gcs_translation_pkg.g_li_acct_type_v_id || g_nl ||
    'AND    fxata.ext_account_type_code = li.dim_attribute_varchar_label' || g_nl ||
    'AND    fxata.attribute_id = ' || gcs_translation_pkg.g_xat_sign_attr_id || g_nl ||
    'AND    fxata.version_id = ' || gcs_translation_pkg.g_xat_sign_v_id);
 
        INSERT /*+ parallel (gcs_entry_lines) */ INTO gcs_entry_lines(
          entry_id, line_item_id, company_cost_center_org_id,
          intercompany_id, financial_elem_id,
          product_id, natural_account_id, channel_id, project_id, customer_id,
          task_id, user_dim1_id, user_dim2_id, user_dim3_id, user_dim4_id,
          user_dim5_id, user_dim6_id, user_dim7_id, user_dim8_id, user_dim9_id,
          user_dim10_id, xtd_balance_e, ytd_balance_e, ptd_debit_balance_e,
          ptd_credit_balance_e, ytd_debit_balance_e, ytd_credit_balance_e,
          creation_date, created_by, last_update_date, last_updated_by,
          last_update_login)
        SELECT
          p_new_entry_id,
          tgt.line_item_id,
 
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
         fxata.number_assign_value *
          decode(tgt.account_type_code,
                 'REVENUE', tgt.xlate_ptd_dr - tgt.xlate_ptd_cr,
                 'EXPENSE', tgt.xlate_ptd_dr - tgt.xlate_ptd_cr,
                      tgt.xlate_ytd_dr - tgt.xlate_ytd_cr),
          fxata.number_assign_value * (tgt.xlate_ytd_dr - tgt.xlate_ytd_cr),
          tgt.xlate_ptd_dr, tgt.xlate_ptd_cr, tgt.xlate_ytd_dr, tgt.xlate_ytd_cr,
          sysdate, gcs_translation_pkg.g_fnd_user_id, sysdate,
    gcs_translation_pkg.g_fnd_user_id, gcs_translation_pkg.g_fnd_login_id
        FROM   gcs_translation_gt tgt,
               fem_ln_items_attr li,
               fem_ext_acct_types_attr fxata
        WHERE  li.line_item_id = tgt.line_item_id
        AND    li.attribute_id = gcs_translation_pkg.g_li_acct_type_attr_id
        AND    li.version_id = gcs_translation_pkg.g_li_acct_type_v_id
        AND    fxata.ext_account_type_code = li.dim_attribute_varchar_member
        AND    fxata.attribute_id = gcs_translation_pkg.g_xat_sign_attr_id
        AND    fxata.version_id = gcs_translation_pkg.g_xat_sign_v_id;
 
        write_to_log(module, FND_LOG.LEVEL_PROCEDURE,g_module_success);
      EXCEPTION
        WHEN GCS_CCY_ENTRY_CREATE_FAILED THEN
          module_log_write(module, g_module_failure);
          raise GCS_TRANSLATION_PKG.GCS_CCY_SUBPROGRAM_RAISED;
        WHEN OTHERS THEN
          FND_MESSAGE.set_name('GCS', 'GCS_CCY_NEW_ENTRY_UNEXP_ERR');
          GCS_TRANSLATION_PKG.g_error_text := FND_MESSAGE.get;
          write_to_log(module, FND_LOG.LEVEL_UNEXPECTED, GCS_TRANSLATION_PKG.g_error_text);
          write_to_log(module, FND_LOG.LEVEL_UNEXPECTED, SQLERRM);
          module_log_write(module, g_module_failure);
          raise GCS_TRANSLATION_PKG.GCS_CCY_SUBPROGRAM_RAISED;
 
 
    write_to_log(module, FND_LOG.LEVEL_PROCEDURE,g_module_success);
  END Create_New_Entry;
 
 
END GCS_TRANS_DYNAMIC_PKG;

/
