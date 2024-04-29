--------------------------------------------------------
--  DDL for Package Body GCS_WEBADI_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_WEBADI_PKG" AS
/* $Header: gcswebadib.pls 120.45 2008/02/05 14:28:44 hakumar noship $ */
--
-- PRIVATE GLOBAL VARIABLES
--

-- The API name
g_pkg_name CONSTANT VARCHAR2(30) := 'gcs.plsql.GCS_WEBADI_PKG';
-- dimension info from gcs_utility_pkg
g_dimension_attr_info gcs_utility_pkg.t_hash_dimension_attr_info := gcs_utility_pkg.g_dimension_attr_info;
g_gcs_dimension_info  gcs_utility_pkg.t_hash_gcs_dimension_info := gcs_utility_pkg.g_gcs_dimension_info;
-- A newline character. Included for convenience when writing long strings.
g_nl VARCHAR2(1) := '
';

--
-- Exceptions
--
level_program_error EXCEPTION;


PROCEDURE init_dimension_attrs IS
  TYPE t_index_dimension_info IS TABLE OF r_dimension_info;
  l_index_dimension_info t_index_dimension_info;
BEGIN
  SELECT fdb.DIMENSION_VARCHAR_LABEL,
         fxd.MEMBER_B_TABLE_NAME,
         fxd.INTF_MEMBER_B_TABLE_NAME,
         fxd.INTF_MEMBER_TL_TABLE_NAME,
         fxd.INTF_ATTRIBUTE_TABLE_NAME,
         fxd.HIERARCHY_TABLE_NAME || '_T',
         fxd.MEMBER_DISPLAY_CODE_COL,
         fxd.MEMBER_NAME_COL,
         fdb.dimension_id,
         fxd.LOADER_OBJECT_DEF_ID
   BULK COLLECT INTO l_index_dimension_info
    FROM fem_xdim_dimensions fxd, fem_dimensions_b fdb
   WHERE fxd.dimension_id = fdb.dimension_id
     AND fxd.member_col IN
         ('COMPANY_COST_CENTER_ORG_ID', 'FINANCIAL_ELEM_ID', 'PRODUCT_ID',
          'NATURAL_ACCOUNT_ID', 'CHANNEL_ID', 'LINE_ITEM_ID', 'PROJECT_ID',
          'CUSTOMER_ID', 'TASK_ID', 'USER_DIM1_ID', 'USER_DIM2_ID',
          'USER_DIM3_ID', 'USER_DIM4_ID', 'USER_DIM5_ID', 'USER_DIM6_ID',
          'USER_DIM7_ID', 'USER_DIM8_ID', 'USER_DIM9_ID', 'USER_DIM10_ID',
          'COMPANY_ID', 'COST_CENTER_ID');

  IF l_index_dimension_info.FIRST IS NOT NULL THEN
    FOR l_counter IN l_index_dimension_info.FIRST .. l_index_dimension_info.LAST LOOP
      g_dimension_info(l_index_dimension_info(l_counter).dimension_varchar_label) := l_index_dimension_info(l_counter);
    END LOOP;
  END IF;


END init_dimension_attrs;
--
-- PUBLIC PROCEDURES
--
---------------------------------------------------------------------------
/*
** datasub_upload
*/
-- Bugfix : 5690166 , added logic for uploading the Header info. to gcs_dat_sub_dtls
PROCEDURE datasub_upload(
                         p_load_id       IN NUMBER,
                         p_load_name     IN VARCHAR2,
                         p_entity_name   IN VARCHAR2,
                         p_period        IN VARCHAR2,
                         p_balance_type  IN VARCHAR2,
                         p_load_method   IN VARCHAR2,
                         p_currency_type IN VARCHAR2,
                         p_currency_code IN VARCHAR2,
                         p_amount_type   IN VARCHAR2,
                         p_measure_type  IN VARCHAR2,
                         p_rule_set      IN VARCHAR2) IS
  l_user_id           NUMBER := fnd_global.user_id;
  l_login_id          NUMBER := fnd_global.login_id;
  l_api_name CONSTANT VARCHAR2(30) := 'datasub_upload';

BEGIN

 IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure THEN
    fnd_log.STRING(fnd_log.level_procedure,
                   g_pkg_name || '.' || l_api_name,
                   gcs_utility_pkg.g_module_enter || ' ' || l_api_name ||
                   '() p_load_id= ' || p_load_id ||
                   ' p_load_name= ' || p_load_name ||
                   ' p_entity_name= ' || p_entity_name ||
                   ' p_balance_type= ' || p_balance_type || ' ' ||
                   ' p_period= ' || p_period || ' ' ||
                   ' p_load_method= ' || p_load_method || ' ' ||
                   ' p_currency_type= ' || p_currency_type || ' ' ||
                   ' p_currency_code= ' || p_currency_code || ' ' ||
                   ' p_amount_type= ' || p_amount_type || ' ' ||
                   ' p_measure_type= ' || p_measure_type || ' ' ||
                   ' p_rule_set= ' || p_rule_set || ' ' ||
                   TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
  END IF;

 -- Delete the row created by Data Submission OA UI
 -- Bugfix 5736334: Added nvl for curreny_code as it can be null for transactional currency.
 DELETE FROM
 gcs_data_sub_dtls
 WHERE
 entity_id                  = p_entity_name
 AND to_char(cal_period_id) = p_period
 AND balance_type_code      = p_balance_type
 AND currency_type_code     = p_currency_type
 AND nvl(currency_code, 'NULL') = nvl(p_currency_code,'NULL')
 AND most_recent_flag       = 'X'
 AND EXISTS (SELECT  'X'
                  FROM   gcs_data_sub_dtls check_exists
                  WHERE  check_exists.entity_id              = p_entity_name
                  AND    to_char(check_exists.cal_period_id) = p_period
                  AND    check_exists.balance_type_code      = p_balance_type
                  AND    check_exists.currency_type_code     = p_currency_type
                  AND    nvl(check_exists.currency_code, 'NULL') = nvl(p_currency_code, 'NULL')
                  AND    check_exists. most_recent_flag       = 'X' );

 -- Always create a new row with the Header data.

  INSERT INTO gcs_data_sub_dtls
   ( load_id,
     load_name,
     entity_id,
     cal_period_id,
     currency_code,
     balance_type_code,
     load_method_code,
     currency_type_code,
     amount_type_code,
     measure_type_code,
     rule_set_id,
     notify_options_code,
     notification_text,
     creation_date,
     created_by,
     last_update_date,
     last_updated_by,
     last_update_login,
     object_version_number,
     start_time,
     end_time,
     status_code,
     locked_flag,
     most_recent_flag,
     associated_request_id,
     validation_rule_set_id,
     balances_rule_id)
   VALUES(
     p_load_id,
     p_load_name,
     p_entity_name,
     p_period,
     p_currency_code,
     p_balance_type,
     p_load_method,
     p_currency_type,
     p_amount_type,
     p_measure_type,
     p_rule_set,
     'N',
     null,
     sysdate,
     l_user_id,
     sysdate,
     l_user_id,
     l_login_id,
     1,
     sysdate,
     null,
     'IN_PROGRESS',
     'N',
     'X',
     null,
     null,
     null);

   IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure THEN
    fnd_log.STRING(fnd_log.level_procedure,
                   g_pkg_name || '.' || l_api_name,
                   gcs_utility_pkg.g_module_success || ' ' || l_api_name ||
                   '() ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
  END IF;


END;


/*
** HRATE_Import
*/
PROCEDURE hrate_import(p_hierarchy_id  IN NUMBER,
                       p_entity_id     IN NUMBER,
                       p_cal_period_id IN NUMBER) IS
  l_event_name     VARCHAR2(100) := 'oracle.apps.gcs.setup.historicalrates.update';
  l_event_key      VARCHAR2(100) := NULL;
  l_parameter_list wf_parameter_list_t;
  l_api_name       VARCHAR2(30) := 'HRATE_IMPORT';
BEGIN
  -- In case of an error, we will roll back to this point in time.
  SAVEPOINT gcs_hrate_import_start;

  FND_FILE.PUT_LINE(FND_FILE.LOG,
                    g_pkg_name || '.' || l_api_name || ' ENTER');
  FND_FILE.NEW_LINE(FND_FILE.LOG);

  IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure THEN
    fnd_log.STRING(fnd_log.level_procedure,
                   g_pkg_name || '.' || l_api_name,
                   gcs_utility_pkg.g_module_enter || ' ' || l_api_name ||
                   '() p_hierarchy_id= ' || p_hierarchy_id ||
                   ' p_entity_id= ' || p_entity_id ||
                   ' p_cal_period_id= ' || p_cal_period_id || ' ' ||
                   TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
  END IF;

  -- Bug Fix : 5352902
  /***
  IF fnd_log.g_current_runtime_level <= fnd_log.level_statement THEN
    fnd_log.STRING(fnd_log.level_statement,
                   g_pkg_name || '.' || l_api_name,
                   'DELETE FROM gcs_historical_rates ' || g_nl ||
                   ' WHERE hierarchy_id = ' || p_hierarchy_id || g_nl ||
                   ' AND entity_id = ' || p_entity_id || g_nl ||
                   ' AND cal_period_id = ' || p_cal_period_id || g_nl ||
                   ' AND update_flag = ''N''');
  END IF;

  DELETE FROM gcs_historical_rates
   WHERE hierarchy_id = p_hierarchy_id
     AND entity_id = p_entity_id
     AND cal_period_id = p_cal_period_id
     AND update_flag = 'N';

  ***/

  IF fnd_log.g_current_runtime_level <= fnd_log.level_statement THEN
    fnd_log.STRING(fnd_log.level_statement,
                   g_pkg_name || '.' || l_api_name,
                   ' UPDATE gcs_historical_rates ghr set update_flag = ''N'', account_type_code = ' || g_nl ||
                    '( select dim_attribute_varchar_member from fem_ln_items_attr ' || g_nl ||
                    '  where attribute_id = ' ||
                    gcs_utility_pkg.g_dimension_attr_info('LINE_ITEM_ID-EXTENDED_ACCOUNT_TYPE')
                   .attribute_id || g_nl || '  AND version_id = ' ||
                    gcs_utility_pkg.g_dimension_attr_info('LINE_ITEM_ID-EXTENDED_ACCOUNT_TYPE')
                   .version_id || g_nl ||
                    ' and line_item_id = ghr.line_item_id)' || g_nl ||
                    ' WHERE hierarchy_id = ' || p_hierarchy_id || g_nl ||
                    ' AND entity_id = ' || p_entity_id || g_nl ||
                    ' AND cal_period_id = ' || p_cal_period_id);
  END IF;

  UPDATE gcs_historical_rates ghr
     SET update_flag       = 'N',
         account_type_code = (select dim_attribute_varchar_member
                                from fem_ln_items_attr
                               where attribute_id =
                                     gcs_utility_pkg.g_dimension_attr_info('LINE_ITEM_ID-EXTENDED_ACCOUNT_TYPE')
                              .attribute_id
                                 and version_id =
                                     gcs_utility_pkg.g_dimension_attr_info('LINE_ITEM_ID-EXTENDED_ACCOUNT_TYPE')
                              .version_id
                                 and line_item_id = ghr.line_item_id)
   WHERE hierarchy_id = p_hierarchy_id
     AND entity_id = p_entity_id
     AND cal_period_id = p_cal_period_id;

  wf_event.addparametertolist(p_name          => 'PERIOD_ID',
                              p_value         => p_cal_period_id,
                              p_parameterlist => l_parameter_list);
  wf_event.addparametertolist(p_name          => 'HIERARCHY_ID',
                              p_value         => p_hierarchy_id,
                              p_parameterlist => l_parameter_list);
  wf_event.addparametertolist(p_name          => 'ENTITY_ID',
                              p_value         => p_entity_id,
                              p_parameterlist => l_parameter_list);
  begin
    FND_FILE.PUT_LINE(FND_FILE.LOG,
                      g_pkg_name || '.' || l_api_name ||
                      ' RAISE WF_EVENT');
    FND_FILE.NEW_LINE(FND_FILE.LOG);
    wf_event.RAISE(p_event_name => l_event_name,
                   p_event_key  => l_event_key,
                   p_parameters => l_parameter_list);
  EXCEPTION
    WHEN OTHERS THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,
                        g_pkg_name || '.' || l_api_name ||
                        ' WF_EVENT FAILED');
      FND_FILE.NEW_LINE(FND_FILE.LOG);
      IF fnd_log.g_current_runtime_level <= fnd_log.level_error THEN
        fnd_log.STRING(fnd_log.level_error,
                       g_pkg_name || '.' || l_api_name,
                       ' wf_event.raise failed ' || ' ' ||
                       TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
      END IF;
  END;

  FND_FILE.PUT_LINE(FND_FILE.LOG,
                    g_pkg_name || '.' || l_api_name || ' EXIT');
  FND_FILE.NEW_LINE(FND_FILE.LOG);

  IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure THEN
    fnd_log.STRING(fnd_log.level_procedure,
                   g_pkg_name || '.' || l_api_name,
                   gcs_utility_pkg.g_module_success || ' ' || l_api_name ||
                   '() ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO gcs_hrate_import_start;

    FND_FILE.PUT_LINE(FND_FILE.LOG,
                      g_pkg_name || '.' || l_api_name || ' ERROR : ' ||
                      SQLERRM);
    FND_FILE.NEW_LINE(FND_FILE.LOG);

    -- Write the appropriate information to the execution report
    IF fnd_log.g_current_runtime_level <= fnd_log.level_error THEN
      fnd_log.STRING(fnd_log.level_error,
                     g_pkg_name || '.' || l_api_name,
                     gcs_utility_pkg.g_module_failure || ' ' || SQLERRM || ' ' ||
                     TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
    END IF;
END hrate_import;

---------------------------------------------------------------------------
---------------------------------------------------------------------------
/*
** Execute_Event
*/
FUNCTION execute_event(p_subscription_guid IN RAW,
                       p_event             IN OUT NOCOPY wf_event_t)
  RETURN VARCHAR2 IS
  TYPE dim_info_rec_type IS RECORD(
    dim_col       VARCHAR2(30),
    dim_col_name  VARCHAR2(30),
    tl_table_name VARCHAR2(30));

  TYPE index_dim_info_tbl_type IS TABLE OF dim_info_rec_type INDEX BY BINARY_INTEGER;

  -- start bugfix: 5496678 - IF we have a record with all these parameters, bulk
  -- update with forall will not work, so we will create multiple tables and
  -- bulk-fetch into them.
  TYPE l_interface_code_tbl_type IS TABLE OF BNE_INTERFACE_COLS_B.INTERFACE_CODE%TYPE INDEX BY BINARY_INTEGER;
  TYPE l_sequence_num_tbl_type   IS TABLE OF BNE_INTERFACE_COLS_B.SEQUENCE_NUM%TYPE INDEX BY BINARY_INTEGER;
  TYPE l_display_name_tbl_type   IS TABLE OF FEM_TAB_COLUMNS_TL.DISPLAY_NAME%TYPE INDEX BY BINARY_INTEGER;
  TYPE l_language_tbl_type       IS TABLE OF BNE_INTERFACE_COLS_TL.LANGUAGE%TYPE INDEX BY BINARY_INTEGER;

  l_interface_code l_interface_code_tbl_type;
  l_sequence_num   l_sequence_num_tbl_type;
  l_display_name   l_display_name_tbl_type;
  l_language       l_language_tbl_type;
  -- end bugbix: 5496678

  l_index_dim_info    index_dim_info_tbl_type;
  l_query             VARCHAR2(5000);
  l_select_cols       VARCHAR2(2500);
  l_view_select_cols  VARCHAR2(2500);
  l_from_clause       VARCHAR2(500);
  l_where_clause      VARCHAR2(2500);
  l_index_column_name VARCHAR2(30);
  l_user_id           NUMBER := fnd_global.user_id;
  l_login_id          NUMBER := fnd_global.login_id;
  l_app_id CONSTANT NUMBER(15) := 266;
  body VARCHAR2(5000);
  l_api_name CONSTANT VARCHAR2(30) := 'Execute_Event';

  g_non_ds_cnt NUMBER := -1;
  g_non_ds_req_dimensions DBMS_SQL.varchar2_table;

  --- Bug Fix   : 5707630, HRates Enhancemnent
  l_hrate_select_cols       VARCHAR2(2500);
  l_hrate_view_select_cols  VARCHAR2(2500);
  l_hrate_from_clause       VARCHAR2(500);
  l_hrate_where_clause      VARCHAR2(2500);

  -- Bug fix: 5968398
  l_hr_re_where_clause      VARCHAR2(2500);
  l_hr_dim_counter          NUMBER := 0 ;
  l_hrate_where_dim_clause  VARCHAR2(2500);

  l_hrate_drm_cnt           NUMBER := -1;
  l_hrate_drm_dimensions    DBMS_SQL.varchar2_table;


BEGIN

  IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure THEN
    fnd_log.STRING(fnd_log.level_procedure,
                   g_pkg_name || '.' || l_api_name,
                   gcs_utility_pkg.g_module_enter || ' ' || l_api_name ||
                   '() ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
  END IF;

  gcs_utility_pkg.init_dimension_info;

  -- Bugfix 5052607: Adding checks for dimension information count
  IF (fnd_log.g_current_runtime_level <= fnd_log.level_statement) THEN
    fnd_log.STRING(fnd_log.level_statement, g_pkg_name || '.' || l_api_name,
                                            'Active dimension count: ' || gcs_utility_pkg.g_gcs_dimension_info.COUNT);
  END IF;

  IF (gcs_utility_pkg.g_gcs_dimension_info.COUNT = 0) THEN
    --We must skip the rest of the program if the active dimensions haven't been defined
    return 'SUCCESS';
  END IF;

  -- start bugfix: 5496678 - Retrieve the display name for the dimensions to be
  -- updated in the bne_interface_tl table.
  -- bugfix 5655870: Added the special decode for company cost center for data sub interface.
  -- Bug Fix   : 6502423, Update bne_interface_cols_tl for HRate RE interface to show user display names

  SELECT interface_code,
         sequence_num,
         display_name,
         language
  BULK COLLECT
    INTO l_interface_code,
         l_sequence_num,
         l_display_name,
         l_language
    FROM (SELECT bicb.interface_code,
                 bicb.sequence_num,
                 ftctl.display_name,
                 ftctl.language
            FROM fem_tab_columns_tl ftctl,
                 bne_interface_cols_b bicb,
                 fem_tab_columns_b ftcb
           WHERE ftctl.table_name = 'FEM_BALANCES'
             AND bicb.application_id = l_app_id
             AND ftcb.table_name = ftctl.table_name
             AND ftcb.column_name = ftctl.column_name
             AND ftcb.fem_data_type_code = 'DIMENSION'
             AND ((bicb.interface_code IN ('GCS_AD_TB_INTF',
                                           'GCS_HRATE_INTF',
                                           'GCS_ENTRY_LINES_INTF',
                                           'GCS_AD_ENTRY_LINE_INTF',
                                           'GCS_HRATE_RE_INTF')
                  AND ftctl.column_name = bicb.interface_col_name)
                 OR
                  (bicb.interface_code IN ('GCS_DATASUB_LINE_INTF',
                                           'GCS_DATASUB_IDT_LINE_INTF')
                  AND bicb.interface_col_name =
                       decode(ftctl.column_name,
                          'COMPANY_COST_CENTER_ORG_ID', 'CCTR_ORG_DISPLAY_CODE',
                          SUBSTR(ftctl.column_name, 0, LENGTH(
                          ftctl.column_name) - 3) ||
                          '_DISPLAY_CODE'))));

  -- update the table bne_interface_cols_tl's dimension display name.
  IF (l_interface_code.COUNT <> 0) THEN
    FORALL l_counter IN l_interface_code.FIRST .. l_interface_code.LAST
      UPDATE bne_interface_cols_tl
         SET prompt_left       = l_display_name(l_counter),
             prompt_above      = l_display_name(l_counter),
             --Bug Fix   : 5563482
             --last_update_date  = SYSDATE,
             last_update_login = l_login_id,
             last_updated_by   = l_user_id
       WHERE application_id = l_app_id
         AND interface_code = l_interface_code(l_counter)
         AND language       = l_language(l_counter)
         AND sequence_num   = l_sequence_num(l_counter);
  END IF;
  -- end bugbix: 5496678

  -- initiate l_gcs_user_dim_info
  SELECT * BULK COLLECT
    INTO l_index_dim_info
    FROM (SELECT fxd.member_col,
                 fxd.member_name_col,
                 fxd.MEMBER_TL_TABLE_NAME
            FROM fem_xdim_dimensions fxd
           WHERE fxd.member_col IN
                 ('COMPANY_COST_CENTER_ORG_ID', 'FINANCIAL_ELEM_ID',
                  'PRODUCT_ID', 'NATURAL_ACCOUNT_ID', 'CHANNEL_ID',
                  'LINE_ITEM_ID', 'PROJECT_ID', 'CUSTOMER_ID', 'TASK_ID',
                  'USER_DIM1_ID', 'USER_DIM2_ID', 'USER_DIM3_ID',
                  'USER_DIM4_ID', 'USER_DIM5_ID', 'USER_DIM6_ID',
                  'USER_DIM7_ID', 'USER_DIM8_ID', 'USER_DIM9_ID',
                  'USER_DIM10_ID')
          UNION ALL
          SELECT 'INTERCOMPANY_ID',
                 'INTERCOMPANY_NAME',
                 'FEM_CCTR_ORGS_TL'
            FROM dual);

  -- update bne_interface_cols_b table for visible dimensions
  -- first hide all dimension columns
  -- Bug fix 3809676: limit interface_col_name not to include "TRIALBALANCE_SEQ_NUM"
  UPDATE bne_interface_cols_b
     SET display_flag      = 'N',
         not_null_flag     = 'N',
         required_flag     = 'N',
         --Bug Fix   : 5563482
         --last_update_date  = SYSDATE,
         last_update_login = l_login_id
   WHERE application_id = l_app_id
     AND interface_code IN ('GCS_AD_TB_INTF', 'GCS_ENTRY_LINES_INTF',
          'GCS_HRATE_INTF', 'GCS_HRATE_RE_INTF','GCS_AD_ENTRY_LINE_INTF')
     AND interface_col_name IN
         ('COMPANY_COST_CENTER_ORG_ID', 'FINANCIAL_ELEM_ID', 'PRODUCT_ID',
          'NATURAL_ACCOUNT_ID', 'CHANNEL_ID', 'LINE_ITEM_ID', 'PROJECT_ID',
          'CUSTOMER_ID', 'INTERCOMPANY_ID', 'TASK_ID', 'USER_DIM1_ID',
          'USER_DIM2_ID', 'USER_DIM3_ID', 'USER_DIM4_ID', 'USER_DIM5_ID',
          'USER_DIM6_ID', 'USER_DIM7_ID', 'USER_DIM8_ID', 'USER_DIM9_ID',
          'USER_DIM10_ID');

  UPDATE bne_interface_cols_b
     SET display_flag      = 'N',
         not_null_flag     = 'N',
         required_flag     = 'N',
         --Bug Fix   : 5563482
         --last_update_date  = SYSDATE,
         last_update_login = l_login_id
   WHERE application_id = l_app_id
     AND interface_code = 'GCS_DATASUB_LINE_INTF'
     AND interface_col_name LIKE '%_DISPLAY_CODE';


  FOR l_counter IN l_index_dim_info.FIRST .. l_index_dim_info.LAST LOOP
    l_index_column_name := l_index_dim_info(l_counter).dim_col;


    --Ensure the column is required for FEM
    IF (gcs_utility_pkg.Get_Fem_Dim_Required(l_index_column_name) = 'Y' and
       l_index_column_name <> 'ENTITY_ID') THEN
      -- then set the user-chosen dimensions as visible and not-null
      UPDATE bne_interface_cols_b
         SET display_flag      = 'Y',
             not_null_flag     = 'Y',
             required_flag     = 'Y',
             --Bug Fix   : 5563482
             --last_update_date  = SYSDATE,
             last_update_login = l_login_id
       WHERE application_id = l_app_id
         AND interface_code = 'GCS_DATASUB_LINE_INTF'
         AND interface_col_name =
             decode(l_index_column_name,
                    'COMPANY_COST_CENTER_ORG_ID',
                    'CCTR_ORG_DISPLAY_CODE',
                    SUBSTR(l_index_column_name,
                           0,
                           LENGTH(l_index_column_name) - 3) ||
                    '_DISPLAY_CODE');

    END IF;


    --Ensure the column is required for GCS II
    IF (gcs_utility_pkg.get_dimension_required(l_index_column_name) = 'Y' and
       l_index_column_name <> 'ENTITY_ID') THEN

       --Code for DRM of Spread sheets other than Data Submission
       g_non_ds_cnt := g_non_ds_cnt + 1;
       g_non_ds_req_dimensions(g_non_ds_cnt) := l_index_column_name;


      -- then set the user-chosen dimensions as visible and not-null
      UPDATE bne_interface_cols_b
         SET display_flag      = 'Y',
             not_null_flag     = 'Y',
             required_flag     = 'Y',
             --Bug Fix   : 5563482
             --last_update_date  = SYSDATE,
             last_update_login = l_login_id
       WHERE application_id = l_app_id
         AND interface_code in
             ('GCS_AD_TB_INTF', 'GCS_HRATE_RE_INTF', 'GCS_ENTRY_LINES_INTF',
              'GCS_AD_ENTRY_LINE_INTF')
         AND interface_col_name = l_index_column_name;

      l_view_select_cols := l_view_select_cols || ', ' ||
                            l_index_dim_info(l_counter).dim_col_name;

      IF (l_index_column_name = 'INTERCOMPANY_ID') THEN
        l_select_cols  := l_select_cols ||
                          ', inter.company_cost_center_org_name intercompany_name';
        l_from_clause  := l_from_clause || ', fem_cctr_orgs_tl inter';
        l_where_clause := l_where_clause ||
                          ' and tb.intercompany_id = inter.company_cost_center_org_id  ' ||
                          ' and inter.language = USERENV(''LANG'')';
        -- Bug fix: 5968398
        l_hr_re_where_clause := l_hr_re_where_clause ||
                          ' and tb.intercompany_id = inter.company_cost_center_org_id  ' ||
                          ' and inter.language = userenv(''LANG'')';

      ELSIF (l_index_column_name = 'COMPANY_COST_CENTER_ORG_ID') THEN
        l_select_cols  := l_select_cols ||
                          ', fcot.company_cost_center_org_name ';
        l_from_clause  := l_from_clause || ', fem_cctr_orgs_tl fcot';
        l_where_clause := l_where_clause ||
                          ' and tb.company_cost_center_org_id = fcot.company_cost_center_org_id ' ||
                          ' and fcot.language = userenv(''LANG'')';
        -- Bug fix: 5968398
        l_hr_re_where_clause := l_hr_re_where_clause ||
                          ' and tb.company_cost_center_org_id = fcot.company_cost_center_org_id ' ||
                          ' and fcot.language = userenv(''LANG'')';
      ELSE
        l_select_cols := l_select_cols || ', ' ||
                         l_index_dim_info(l_counter).dim_col_name;

        l_from_clause  := l_from_clause || ', ' ||
                          l_index_dim_info(l_counter).tl_table_name;
        l_where_clause := l_where_clause || ' and tb.' ||
                          l_index_column_name || ' = ' ||
                          l_index_dim_info(l_counter)
                         .tl_table_name || '.' || l_index_column_name ||
                          ' and ' || l_index_dim_info(l_counter)
                         .tl_table_name ||
                          '.language = userenv(''LANG'')';

        -- Bug fix: 5968398
        l_hr_re_where_clause := l_hr_re_where_clause || ' and tb.' ||
                                l_index_column_name || ' = ' ||
                                l_index_dim_info(l_counter)
                                .tl_table_name || '.' || l_index_column_name ||
                                ' and ' || l_index_dim_info(l_counter)
                                .tl_table_name ||
                                '.language = userenv(''LANG'') '  ;

      END IF;
    END IF;


    --- Bug Fix   : 5707630, HRates Enhancement
    --- Start of the fix : 5707630
    IF (gcs_utility_pkg.get_Hrate_Dim_required(l_index_column_name) = 'Y' and
       l_index_column_name <> 'ENTITY_ID') THEN

       --Code for DRM of HIstorical Rates Spread sheet
       l_hrate_drm_cnt := l_hrate_drm_cnt + 1;
       l_hrate_drm_dimensions(l_hrate_drm_cnt) := l_index_column_name;


      -- then set the user-chosen dimensions as visible and not-null
      UPDATE bne_interface_cols_b
         SET display_flag      = 'Y',
             not_null_flag     = 'Y',
             required_flag     = 'Y',
             last_update_login = l_login_id
       WHERE application_id     = l_app_id
         AND interface_code     = 'GCS_HRATE_INTF'
         AND interface_col_name = l_index_column_name;

      l_hrate_view_select_cols := l_hrate_view_select_cols || ', ' ||
                            l_index_dim_info(l_counter).dim_col_name;

      IF (l_index_column_name = 'INTERCOMPANY_ID') THEN
        l_hrate_select_cols  := l_hrate_select_cols ||
                          ', inter.company_cost_center_org_name intercompany_name';
        l_hrate_from_clause  := l_hrate_from_clause || ', fem_cctr_orgs_tl inter';
        l_hrate_where_clause := l_hrate_where_clause ||
                          ' and tb.intercompany_id = inter.company_cost_center_org_id  ' ||
                          ' and inter.language = userenv(''LANG'')';
      ELSIF (l_index_column_name = 'COMPANY_COST_CENTER_ORG_ID') THEN
        l_hrate_select_cols  := l_hrate_select_cols ||
                          ', fcot.company_cost_center_org_name ';
        l_hrate_from_clause  := l_hrate_from_clause || ', fem_cctr_orgs_tl fcot';
        l_hrate_where_clause := l_hrate_where_clause ||
                          ' and tb.company_cost_center_org_id = fcot.company_cost_center_org_id ' ||
                          ' and fcot.language = userenv(''LANG'')';
      ELSE
        l_hrate_select_cols := l_hrate_select_cols || ', ' ||
                         l_index_dim_info(l_counter).dim_col_name;

        l_hrate_from_clause  := l_hrate_from_clause || ', ' ||
                          l_index_dim_info(l_counter).tl_table_name;

        -- Bug fix: 5968398
        l_hrate_where_clause := l_hrate_where_clause || ' and tb.' ||
                                l_index_column_name || ' = ' ||
                                l_index_dim_info(l_counter)
                                .tl_table_name || '.' || l_index_column_name ||
                                ' and ' || l_index_dim_info(l_counter)
                                .tl_table_name ||
                                '.language = userenv(''LANG'') ' ;

         IF l_hr_dim_counter = 0 THEN
            l_hrate_where_dim_clause :=  ' gdt.' ||
                                     l_index_column_name || ' <> tb.' ||
                                     l_index_column_name ;
            l_hr_dim_counter := l_hr_dim_counter+1 ;
         ELSE
            l_hrate_where_dim_clause :=  l_hrate_where_dim_clause || ' OR gdt.' ||
                                     l_index_column_name || ' <> tb.' ||
                                     l_index_column_name ;

        END IF;

      END IF;
    END IF;
     --- End of the fix : 5707630

  END LOOP;


  -- Bugfix 5052607: Added additional debug information
  IF (fnd_log.g_current_runtime_level <= fnd_log.level_statement) THEN
    fnd_log.STRING(fnd_log.level_statement, g_pkg_name || '.' || l_api_name,
                                           'Select Columns: ' || l_select_cols);
    fnd_log.STRING(fnd_log.level_statement, g_pkg_name || '.' || l_api_name,
                                           'From Clause: ' || l_from_clause);
    fnd_log.STRING(fnd_log.level_statement, g_pkg_name || '.' || l_api_name,
                                           'Where Clause: ' || l_where_clause);
  END IF;



  --- Bug Fix   : 5707630, HRates Enhancement
  --- Start of the fix : 5707630

  --- Code for DRM
  DELETE
  FROM
  BNE_INTERFACE_KEY_COLS
  WHERE APPLICATION_ID = 266
  AND   SEQUENCE_NUM > 9
  AND   INTERFACE_CODE IN ('GCS_AD_ENTRY_LINE_INTF',
        'GCS_AD_TB_INTF','GCS_HRATE_INTF', 'GCS_HRATE_RE_INTF');

  -- Bug Fix : 5679021
  -- Key columns for Entry interface ('GCS_ENTRY_LINES_INTF') not needed, as DRM is dropped.


  --- DRM for Historical Rates - Retained Earnings added
  IF (g_non_ds_cnt >= 0) THEN
    FORALL i IN g_non_ds_req_dimensions.FIRST .. g_non_ds_req_dimensions.LAST
      INSERT INTO BNE_INTERFACE_KEY_COLS
        (APPLICATION_ID,
         KEY_CODE,
         SEQUENCE_NUM,
         OBJECT_VERSION_NUMBER,
         INTERFACE_APP_ID,
         INTERFACE_CODE,
         INTERFACE_SEQ_NUM,
         CREATED_BY,
         CREATION_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATE_LOGIN,
         LAST_UPDATE_DATE)
      SELECT
         l_app_id,
         decode(INTERFACE_CODE,
           'GCS_AD_ENTRY_LINE_INTF',
           'GCS_AD_ENTRY_KEY_CODE',
           'GCS_AD_TB_INTF',
           'GCS_AD_TB_KEY_CODE',
           'GCS_HRATE_RE_INTF',
           'GCS_HRATE_RE_KEY_CODE' ),
         SEQUENCE_NUM+10,
           1,
         l_app_id,
         INTERFACE_CODE,
         SEQUENCE_NUM,
         l_user_id,
         CREATION_DATE,
         l_user_id,
         l_login_id,
         --Bug Fix   : 5563482
         LAST_UPDATE_DATE
      FROM  bne_interface_cols_b
      WHERE interface_col_name = g_non_ds_req_dimensions(i)
      AND   interface_code IN
           ('GCS_AD_ENTRY_LINE_INTF', 'GCS_AD_TB_INTF',
            'GCS_HRATE_RE_INTF' ); -- HRates Enhancement
  END IF;


  --- DRM for Historical Rates
  IF (l_hrate_drm_cnt >= 0) THEN
    FORALL i IN l_hrate_drm_dimensions.FIRST .. l_hrate_drm_dimensions.LAST
      INSERT INTO BNE_INTERFACE_KEY_COLS
        (APPLICATION_ID,
         KEY_CODE,
         SEQUENCE_NUM,
         OBJECT_VERSION_NUMBER,
         INTERFACE_APP_ID,
         INTERFACE_CODE,
         INTERFACE_SEQ_NUM,
         CREATED_BY,
         CREATION_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATE_LOGIN,
         LAST_UPDATE_DATE)
      SELECT
         l_app_id,
         'GCS_HRATE_KEY_CODE',
         SEQUENCE_NUM+5,
         1,
         l_app_id,
         INTERFACE_CODE,
         SEQUENCE_NUM,
         l_user_id,
         CREATION_DATE,
         l_user_id,
         l_login_id,
         LAST_UPDATE_DATE
      FROM  bne_interface_cols_b
      WHERE interface_col_name = l_hrate_drm_dimensions(i)
      AND   interface_code     = 'GCS_HRATE_INTF' ;
  END IF;

  --- End of the fix : 5707630


  l_query := 'SELECT  ''Trial Balance'' template_type,flv2.meaning category_code, gat.transaction_date,ght.hierarchy_name,' ||
             ' fet1.entity_name consolidation_entity_name,fct.NAME currency_code, ' ||
             ' fet2.entity_name operating_entity_name,gat.ad_transaction_id, entry.entry_name recur_entry_name, ' ||
             ' entry.description, gat.total_consideration consideration_amount, flv.meaning trial_balance_seq, ' ||
             ' credit_amount, debit_amount' || l_view_select_cols ||
             ' FROM fnd_lookup_values flv, gcs_ad_transactions gat, gcs_entry_headers entry, ' ||
             ' fnd_lookup_values flv2, fem_entities_tl fet1, fem_entities_tl fet2, gcs_cons_relationships gcr, ' ||
             ' gcs_entity_cons_attrs geca, gcs_hierarchies_tl ght, fnd_currencies_tl fct, ' ||
             ' (SELECT tb.ad_transaction_id, credit_amount, debit_amount,
             tb.trial_balance_seq ' || l_select_cols ||
             ' FROM gcs_ad_trial_balances tb' || l_from_clause ||
             ' WHERE ' || substr(l_where_clause, 5) || ') adtb' ||
             ' WHERE adtb.ad_transaction_id(+) = gat.ad_transaction_id AND gat.assoc_entry_id = entry.entry_id(+) ' ||
             ' AND nvl(gat.post_cons_relationship_id, gat.pre_cons_relationship_id) = gcr.cons_relationship_id AND fet1.entity_id = gcr.parent_entity_id ' ||
             ' AND fet1.language = USERENV(''LANG'') AND fet2.language = USERENV(''LANG'') ' ||
             ' AND ght.language = USERENV(''LANG'') AND fct.language = USERENV(''LANG'') ' ||
             ' AND fet2.entity_id = gcr.child_entity_id AND geca.entity_id = gcr.parent_entity_id ' ||
             ' AND geca.hierarchy_id = gcr.hierarchy_id AND gcr.hierarchy_id = ght.hierarchy_id ' ||
             ' AND geca.currency_code = fct.currency_code AND gat.transaction_type_code = flv2.lookup_code ' ||
             ' AND flv2.lookup_type = ''TRANSACTION_TYPE_CODE'' AND NVL (adtb.trial_balance_seq, 1) = flv.lookup_code ' ||
             ' AND flv.lookup_type = ''GCS_TB_SEQUENCE'' AND flv.LANGUAGE = USERENV (''LANG'') AND flv2.LANGUAGE = USERENV (''LANG'') ' ||
             ' AND flv.view_application_id = 266 AND flv2.view_application_id = 266  ';

  body := ' CREATE OR REPLACE FORCE VIEW GCS_TB_WEBADI_VL AS ' || l_query;

  -- Bugfix 5052607: Adding additional debug information
  IF (fnd_log.g_current_runtime_level <= fnd_log.level_statement) THEN
    fnd_log.STRING(fnd_log.level_statement, g_pkg_name || '.' || l_api_name,
                                            'View Definition for GCS_TB_WEBADI_VL');
    fnd_log.STRING(fnd_log.level_statement, g_pkg_name || '.' || l_api_name,
                                            body);

  END IF;

  ad_ddl.do_ddl(GCS_DYNAMIC_UTIL_PKG.g_applsys_username,
                'GCS',
                ad_ddl.create_view,
                body,
                'GCS_TB_WEBADI_VL');

  l_query := 'SELECT  template_type, category_code, transaction_date,hierarchy_name,' ||
             ' consolidation_entity_name,currency_code, ' ||
             ' operating_entity_name,ad_transaction_id, recur_entry_name, ' ||
             ' description, consideration_amount, trial_balance_seq, ' ||
             ' credit_amount, debit_amount' || l_view_select_cols ||
             ' FROM gcs_tb_webadi_vl ' ||
             ' WHERE ad_transaction_id = $param$.xns_id ';

  -- update stored SQL
  IF fnd_log.g_current_runtime_level <= fnd_log.level_statement THEN
    fnd_log.STRING(fnd_log.level_statement,
                   g_pkg_name || '.' || l_api_name,
                   'UPDATE bne_stored_SQL SET QUERY=' || l_query ||
                   gcs_utility_pkg.g_nl ||
                   ' WHERE application_id=l_app_id AND content_code=''GCS_AD_TB_CNT''');
  END IF;

  UPDATE bne_stored_sql
     SET QUERY = l_query
         --Bug Fix   : 5563482
         --last_update_date = SYSDATE
   WHERE application_id = l_app_id
     AND content_code = 'GCS_AD_TB_CNT';

  l_query := 'SELECT ''Manual Adjustment'' template_type, flv2.meaning category_code,' ||
             ' gat.transaction_date, ght.hierarchy_name,' ||
             ' fet1.entity_name consolidation_entity_name, fct.NAME currency_code,' ||
             ' fet2.entity_name operating_entity_name, gat.ad_transaction_id,' ||
             ' entry.entry_name recur_entry_name, entry.description,' ||
             ' gat.total_consideration consideration_amount, ' ||
             ' adtb.description lines_description, ' ||
             ' credit_amount, debit_amount' || l_view_select_cols ||
             ' FROM gcs_ad_transactions gat,gcs_entry_headers entry,' ||
             ' fnd_lookup_values flv2, fem_entities_tl fet1,fem_entities_tl fet2,gcs_cons_relationships gcr,' ||
             ' gcs_entity_cons_attrs geca, gcs_hierarchies_tl ght, fnd_currencies_tl fct,' ||
             ' (SELECT tb.entry_id, ytd_credit_balance_e credit_amount,
             ytd_debit_balance_e debit_amount, tb.description ' ||
             l_select_cols || ' FROM gcs_entry_lines tb' || l_from_clause ||
             ' WHERE NVL (tb.line_type_code, '' '') <> ''CALCULATED'' ' ||
             l_where_clause || ') adtb ' ||
             ' WHERE adtb.entry_id(+) = gat.assoc_entry_id  AND gat.assoc_entry_id = entry.entry_id(+) ' ||
             ' AND NVL (gat.post_cons_relationship_id, gat.pre_cons_relationship_id) = gcr.cons_relationship_id ' ||
             ' AND fet1.entity_id = gcr.parent_entity_id AND fet2.entity_id = gcr.child_entity_id ' ||
             ' AND fet1.language = USERENV(''LANG'') AND fet2.language = USERENV(''LANG'') ' ||
             ' AND ght.language = USERENV(''LANG'') AND fct.language = USERENV(''LANG'') ' ||
             ' AND geca.entity_id = gcr.parent_entity_id AND geca.hierarchy_id = gcr.hierarchy_id ' ||
             ' AND gcr.hierarchy_id = ght.hierarchy_id AND geca.currency_code = fct.currency_code ' ||
             ' AND gat.transaction_type_code = flv2.lookup_code AND flv2.lookup_type = ''TRANSACTION_TYPE_CODE'' ' ||
             ' AND flv2.LANGUAGE = USERENV (''LANG'') AND flv2.view_application_id = 266 ';

  body := ' CREATE OR REPLACE FORCE VIEW GCS_ADENTRY_WEBADI_VL AS ' ||
          l_query;

  -- Bugfix 5052607: Adding additional debug information
  IF (fnd_log.g_current_runtime_level <= fnd_log.level_statement) THEN
    fnd_log.STRING(fnd_log.level_statement, g_pkg_name || '.' || l_api_name,
                                            'View Definition for GCS_ADENTRY_WEBADI_VL');
    fnd_log.STRING(fnd_log.level_statement, g_pkg_name || '.' || l_api_name,
                                            body);

  END IF;

  ad_ddl.do_ddl(GCS_DYNAMIC_UTIL_PKG.g_applsys_username,
                'GCS',
                ad_ddl.create_view,
                body,
                'GCS_ADENTRY_WEBADI_VL');

  l_query := 'SELECT template_type, category_code,' ||
             ' transaction_date, hierarchy_name,' ||
             ' consolidation_entity_name, currency_code,' ||
             ' operating_entity_name, ad_transaction_id,' ||
             ' recur_entry_name, description,' ||
             ' consideration_amount, ' || ' lines_description,' ||
             ' credit_amount, debit_amount' || l_view_select_cols ||
             ' FROM gcs_adentry_webadi_vl ' ||
             ' WHERE ad_transaction_id = $param$.xns_id ';
  IF fnd_log.g_current_runtime_level <= fnd_log.level_statement THEN
    fnd_log.STRING(fnd_log.level_statement,
                   g_pkg_name || '.' || l_api_name,
                   'UPDATE bne_stored_SQL SET QUERY=' || l_query ||
                   gcs_utility_pkg.g_nl ||
                   ' WHERE application_id=l_app_id AND content_code=''GCS_AD_ENTRY_CNT''');
  END IF;

  UPDATE bne_stored_sql
     SET QUERY = l_query
         --Bug Fix   : 5563482
         --last_update_date = SYSDATE
   WHERE application_id = l_app_id
     AND content_code = 'GCS_AD_ENTRY_CNT';

  --- Bug Fix   : 5707630, HRates Enhancement
  --- Start of the fix : 5707630

  l_query := ' SELECT hierarchy_name, entity_name, fct_from.NAME from_currency, ' ||
             ' fct_to.NAME to_currency, translated_rate rate, ' ||
             ' translated_amount amount, flv.meaning AS rate_type, period.cal_period_name period, ' ||
             ' tb.hierarchy_id, tb.entity_id, tb.cal_period_id ' ||
             l_select_cols ||
             ' FROM gcs_dimension_templates gdt,gcs_hierarchies_tl ght, fnd_lookup_values flv, fem_entities_tl entity, ' ||
             ' gcs_historical_rates tb, fnd_currencies_tl fct_from, fnd_currencies_tl fct_to, ' ||
             ' fem_cal_periods_tl period ' || l_from_clause ||
             ' WHERE gdt.hierarchy_id = tb.hierarchy_id AND gdt.template_code = ''RE''' ||
             ' AND tb.hierarchy_id = ght.hierarchy_id AND tb.entity_id = entity.entity_id ' ||
             ' AND tb.rate_type_code = flv.lookup_code AND flv.lookup_type = ''HISTORICAL_RATE_TYPE'' ' ||
             ' AND flv.LANGUAGE = USERENV (''LANG'') and flv.view_application_id = 266 ' ||
             ' AND fct_from.LANGUAGE = USERENV (''LANG'') and fct_to.LANGUAGE = USERENV (''LANG'')  ' ||
             ' AND ght.LANGUAGE = USERENV (''LANG'') and entity.LANGUAGE = USERENV (''LANG'')  ' ||
             ' AND tb.cal_period_id = period.cal_period_id AND period.language = USERENV(''LANG'')' ||
             ' AND fct_to.currency_code = tb.to_currency AND fct_from.currency_code = tb.from_currency ' ||
             ' AND fct_to.language = USERENV(''LANG'') AND fct_from.language = USERENV(''LANG'') ' ||
             l_hr_re_where_clause ; --  Bug Fix - 5968398

  body := ' CREATE OR REPLACE FORCE VIEW GCS_HR_RE_WEBADI_VL AS ' || l_query;

  -- Bugfix 5052607: Adding additional debug information
  IF (fnd_log.g_current_runtime_level <= fnd_log.level_statement) THEN
    fnd_log.STRING(fnd_log.level_statement, g_pkg_name || '.' || l_api_name,
                                            'View Definition for GCS_HR_RE_WEBADI_VL');
    fnd_log.STRING(fnd_log.level_statement, g_pkg_name || '.' || l_api_name,
                                            body);

  END IF;

  ad_ddl.do_ddl(GCS_DYNAMIC_UTIL_PKG.g_applsys_username,
                'GCS',
                ad_ddl.create_view,
                body,
                'GCS_HR_RE_WEBADI_VL');

  l_query := ' SELECT hierarchy_name, entity_name, from_currency, ' ||
             ' to_currency, rate, ' || ' amount, rate_type, period ' ||
             l_view_select_cols || ' FROM gcs_hr_re_webadi_vl tb ' ||
             ' WHERE hierarchy_id = $param$.hierarchy_id AND entity_id = $param$.entity_id ' ||
             ' AND cal_period_id = $param$.cal_period_id ';

  IF fnd_log.g_current_runtime_level <= fnd_log.level_statement THEN
    fnd_log.STRING(fnd_log.level_statement,
                   g_pkg_name || '.' || l_api_name,
                   'UPDATE bne_stored_SQL SET QUERY=' || l_query ||
                   gcs_utility_pkg.g_nl ||
                   ' WHERE application_id=l_app_id AND content_code=''GCS_HRATE_RE_CNT''');
  END IF;

  UPDATE bne_stored_sql
     SET QUERY = l_query
   WHERE application_id = l_app_id
     AND content_code = 'GCS_HRATE_RE_CNT';

  -- Historical Rates View

  l_query := ' SELECT hierarchy_name, entity_name, fct_from.NAME from_currency, ' ||
             ' fct_to.NAME to_currency, translated_rate rate, ' ||
             ' translated_amount amount, flv.meaning AS rate_type, period.cal_period_name period, ' ||
             ' tb.hierarchy_id, tb.entity_id, tb.cal_period_id ' ||
             l_hrate_select_cols ||
             ' FROM gcs_dimension_templates gdt, gcs_hierarchies_tl ght, fnd_lookup_values flv, fem_entities_tl entity, ' ||
             ' gcs_historical_rates tb, fnd_currencies_tl fct_from, fnd_currencies_tl fct_to, ' ||
             ' fem_cal_periods_tl period ' || l_hrate_from_clause ||
             ' WHERE gdt.hierarchy_id = tb.hierarchy_id AND gdt.template_code = ''RE''' ||
             ' AND tb.hierarchy_id = ght.hierarchy_id AND tb.entity_id = entity.entity_id ' ||
             ' AND tb.rate_type_code = flv.lookup_code AND flv.lookup_type = ''HISTORICAL_RATE_TYPE'' ' ||
             ' AND flv.LANGUAGE = USERENV (''LANG'') and flv.view_application_id = 266 ' ||
             ' AND fct_from.LANGUAGE = USERENV (''LANG'') and fct_to.LANGUAGE = USERENV (''LANG'')  ' ||
             ' AND ght.LANGUAGE = USERENV (''LANG'') and entity.LANGUAGE = USERENV (''LANG'')  ' ||
             ' AND tb.cal_period_id = period.cal_period_id AND period.language = USERENV(''LANG'')' ||
             ' AND fct_to.currency_code = tb.to_currency AND fct_from.currency_code = tb.from_currency ' ||
             ' AND fct_to.language = USERENV(''LANG'') AND fct_from.language = USERENV(''LANG'') ' ||
             l_hrate_where_clause || ' AND ( '|| l_hrate_where_dim_clause || ' )';

  body := ' CREATE OR REPLACE FORCE VIEW GCS_HR_WEBADI_VL AS ' || l_query;

  -- Bugfix 5052607: Adding additional debug information
  IF (fnd_log.g_current_runtime_level <= fnd_log.level_statement) THEN
    fnd_log.STRING(fnd_log.level_statement, g_pkg_name || '.' || l_api_name,
                                            'View Definition for GCS_HR_WEBADI_VL');
    fnd_log.STRING(fnd_log.level_statement, g_pkg_name || '.' || l_api_name,
                                            body);

  END IF;

  ad_ddl.do_ddl(GCS_DYNAMIC_UTIL_PKG.g_applsys_username,
                'GCS',
                ad_ddl.create_view,
                body,
                'GCS_HR_WEBADI_VL');

  l_query := ' SELECT hierarchy_name, entity_name, from_currency, ' ||
             ' to_currency, rate, ' || ' amount, rate_type, period ' ||
             l_hrate_view_select_cols || ' FROM gcs_hr_webadi_vl tb ' ||
             ' WHERE hierarchy_id = $param$.hierarchy_id AND entity_id = $param$.entity_id ' ||
             ' AND cal_period_id = $param$.cal_period_id ';


  IF fnd_log.g_current_runtime_level <= fnd_log.level_statement THEN
    fnd_log.STRING(fnd_log.level_statement,
                   g_pkg_name || '.' || l_api_name,
                   'UPDATE bne_stored_SQL SET QUERY=' || l_query ||
                   gcs_utility_pkg.g_nl ||
                   ' WHERE application_id=l_app_id AND content_code=''GCS_HRATE_CNT''');
  END IF;

  UPDATE bne_stored_sql
     SET QUERY = l_query
   WHERE application_id = l_app_id
     AND content_code = 'GCS_HRATE_CNT';

   --- End of the fix : 5707630

 l_query := ' SELECT hierarchy_name, gct.category_name as category_code,gdtctl.data_type_name as balance_type_code, ' ||
               ' entity_name, eh.description, fct.NAME currency_code, credit, ' ||
               ' debit, flv1.meaning as process_code, start_period.cal_period_name start_period, ' ||
               ' end_period.cal_period_name end_period, eh.entry_name, eh.entry_id ,adtb.ENTRY_LINES_DESCRIPTION ' ||
               l_view_select_cols ||
               ' FROM gcs_hierarchies_tl ght, fnd_lookup_values flv1, gcs_categories_tl gct, fem_entities_tl entity, ' ||
               ' gcs_entry_headers eh, fnd_currencies_tl fct, fem_cal_periods_tl start_period, '||
               ' gcs_data_type_codes_b gdtcb,gcs_data_type_codes_tl gdtctl, ' ||
               ' fem_cal_periods_tl end_period, ' ||
               ' (SELECT tb.entry_id, tb.description ENTRY_LINES_DESCRIPTION, ytd_credit_balance_e credit,
               ytd_debit_balance_e debit ' || l_select_cols ||
               ' FROM gcs_entry_lines tb' || l_from_clause ||
               ' WHERE NVL(tb.line_type_code, '' '') <> ''CALCULATED'' ' ||
               l_where_clause || ') adtb ' ||
               ' WHERE eh.hierarchy_id = ght.hierarchy_id AND eh.entity_id = entity.entity_id ' ||
               ' AND eh.process_code = flv1.lookup_code and flv1.lookup_type = ''GCS_ENTRY_PROCESS_CODE'' ' ||
               ' AND flv1.LANGUAGE = USERENV (''LANG'') AND eh.category_code = gct.category_code ' ||
               ' AND ght.LANGUAGE = USERENV (''LANG'') AND flv1.view_application_id = 266 ' ||
               ' AND entity.LANGUAGE = USERENV (''LANG'') AND fct.LANGUAGE = USERENV (''LANG'') ' ||
               ' AND start_period.LANGUAGE = USERENV (''LANG'') AND end_period.LANGUAGE (+)= USERENV (''LANG'') ' ||
               ' AND gct.LANGUAGE = USERENV (''LANG'') AND eh.start_cal_period_id = start_period.cal_period_id ' ||
               ' AND eh.end_cal_period_id = end_period.cal_period_id (+) AND eh.entry_id = adtb.entry_id (+)' ||
               ' AND fct.currency_code = eh.currency_code '||
               ' AND eh.balance_type_code = gdtcb.data_type_code '||
               ' AND gdtcb.data_type_id = gdtctl.data_type_id '||
               ' AND gdtctl.LANGUAGE = USERENV(''LANG'') ';

  body := ' CREATE OR REPLACE FORCE VIEW GCS_ENTRY_WEBADI_VL AS ' ||
          l_query;

  -- Bugfix 5052607: Adding additional debug information
  IF (fnd_log.g_current_runtime_level <= fnd_log.level_statement) THEN
    fnd_log.STRING(fnd_log.level_statement, g_pkg_name || '.' || l_api_name,
                                            'View Definition for GCS_ENTRY_WEBADI_VL');
    fnd_log.STRING(fnd_log.level_statement, g_pkg_name || '.' || l_api_name,
                                            body);

  END IF;

  ad_ddl.do_ddl(GCS_DYNAMIC_UTIL_PKG.g_applsys_username,
                'GCS',
                ad_ddl.create_view,
                body,
                'GCS_ENTRY_WEBADI_VL');

 l_query := ' SELECT hierarchy_name, category_code, balance_type_code, ' ||
             ' entity_name, description, currency_code, credit, ' ||
             ' debit, process_code, start_period, ' ||
             ' end_period, entry_name, entry_id, ENTRY_LINES_DESCRIPTION ' || l_view_select_cols ||
             ' FROM gcs_entry_webadi_vl tb ' ||
             ' WHERE tb.entry_id=$PARAM$.entry_id ';

  IF fnd_log.g_current_runtime_level <= fnd_log.level_statement THEN
    fnd_log.STRING(fnd_log.level_statement,
                   g_pkg_name || '.' || l_api_name,
                   'UPDATE bne_stored_SQL SET QUERY=' || l_query ||
                   gcs_utility_pkg.g_nl ||
                   ' WHERE application_id=l_app_id AND content_code=''GCS_ENTRY_LINES_CNT''');
  END IF;

  UPDATE bne_stored_sql
     SET QUERY = l_query
         --Bug Fix   : 5563482
         --last_update_date = SYSDATE
   WHERE application_id = l_app_id
     AND content_code = 'GCS_ENTRY_LINES_CNT';

  COMMIT;

  -- Write the appropriate information to the execution report
  IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure THEN
    fnd_log.STRING(fnd_log.level_procedure,
                   g_pkg_name || '.' || l_api_name,
                   gcs_utility_pkg.g_module_success || ' ' || l_api_name ||
                   '() ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
  END IF;

  RETURN 'SUCCESS';
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    --Bugfix 5052607: Commented calling WF_CORE APIs and setting message name
    --fnd_message.set_name('GCS', 'GCS_AD_TB_UNEXPECTED_ERR');

    -- Write the appropriate information to the execution report
    IF fnd_log.g_current_runtime_level <= fnd_log.level_error THEN
      fnd_log.STRING(fnd_log.level_error,
                     g_pkg_name || '.' || l_api_name,
                     gcs_utility_pkg.g_module_failure || ' ' ||
                     l_api_name || '() ' ||
                     TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
      fnd_log.STRING(fnd_log.level_error,
                     g_pkg_name || '.' || l_api_name,
                     SQLERRM);
    END IF;

    --wf_core.CONTEXT(g_pkg_name,
    --                l_api_name,
    --                p_event.geteventname(),
    --                p_subscription_guid);
    --wf_event.seterrorinfo(p_event, 'ERROR');
    RETURN 'ERROR';
END execute_event;


--
-- Procedure
--   Dim_Member_Import
-- Purpose
--   An API to import dimension members from Web ADI
-- Arguments
-- Notes
--
PROCEDURE dim_member_import(x_errbuf                  OUT NOCOPY VARCHAR2,
                            x_retcode                 OUT NOCOPY VARCHAR2,
                            p_sequence_num            IN NUMBER,
                            p_dimension_varchar_label IN VARCHAR2) IS

  l_attribute_id_list           DBMS_SQL.varchar2_table;
  l_member_display_code_list    DBMS_SQL.varchar2_table;
  l_member_b_table_list         DBMS_SQL.varchar2_table;
  l_member_col_list             DBMS_SQL.varchar2_table;
  l_default_assign_list         DBMS_SQL.varchar2_table;
  l_attr_varchar_list           DBMS_SQL.varchar2_table;

  -- Bug Fix : 5232709 , Variables for holding the _tl, _attr table names of the upload dimension
  l_member_tl_table_name     VARCHAR2(30);
  l_member_attr_table_name   VARCHAR2(30);

  l_status_code         VARCHAR2(1);

  l_api_name VARCHAR2(30) := 'DIM_MEMBER_IMPORT';
BEGIN
  SAVEPOINT dm_import_start;

  FND_FILE.NEW_LINE(FND_FILE.LOG);
  FND_FILE.PUT_LINE(FND_FILE.LOG, '<<<< Beginning Dimension Member Load >>>>');
  FND_FILE.NEW_LINE(FND_FILE.LOG);
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Beginning of Parameters');
  FND_FILE.NEW_LINE(FND_FILE.LOG);
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Sequence Number:  ' || p_sequence_num);
  FND_FILE.NEW_LINE(FND_FILE.LOG);
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Dimension Varchar Label: ' || p_dimension_varchar_label);
  FND_FILE.NEW_LINE(FND_FILE.LOG);
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'End of Parameters');
  FND_FILE.NEW_LINE(FND_FILE.LOG);


  IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure THEN
    fnd_log.STRING(fnd_log.level_procedure,
                   g_pkg_name || '.' || l_api_name,
                   gcs_utility_pkg.g_module_enter || ' p_sequence_num = ' ||
                   p_sequence_num || ', p_dimension_varchar_label = ' ||
                   p_dimension_varchar_label || ' ' ||
                   TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
  END IF;

  -- Bug Fix : 5116449, Inserted dimension_group_display_code to the FEM dimension interface tables

  IF (p_dimension_varchar_label = 'FINANCIAL_ELEMENT') THEN
    EXECUTE IMMEDIATE
            'INSERT INTO ' ||
            g_dimension_info(p_dimension_varchar_label).b_t_table_name || ' (' ||
            g_dimension_info(p_dimension_varchar_label).display_code || ',
            value_set_display_code,
            status )
     SELECT display_code,
            value_set_display_code,
            ''LOAD''
       FROM gcs_dimension_members_t
      WHERE sequence_num = :1 '
      USING p_sequence_num;
  ELSE
    EXECUTE IMMEDIATE
            'INSERT INTO ' ||
            g_dimension_info(p_dimension_varchar_label).b_t_table_name || ' (' ||
            g_dimension_info(p_dimension_varchar_label).display_code || ',
            value_set_display_code,
            status,
            dimension_group_display_code)
     SELECT display_code,
            value_set_display_code,
            ''LOAD'',
            dimension_group_display_code
       FROM gcs_dimension_members_t
      WHERE sequence_num = :1 '
      USING p_sequence_num;
  END IF;

  EXECUTE IMMEDIATE
          'INSERT INTO ' ||
          g_dimension_info(p_dimension_varchar_label).tl_t_table_name || ' (' ||
          g_dimension_info(p_dimension_varchar_label).display_code || ',
          value_set_display_code,
          language, ' ||
           g_dimension_info(p_dimension_varchar_label).name || ',
           description,
           status)
    SELECT display_code,
           value_set_display_code,
           USERENV(''LANG''),
           name,
           description,
           ''LOAD''
      FROM gcs_dimension_members_t
     WHERE sequence_num = :1 '
     USING p_sequence_num;

SELECT fdab.attribute_id, fxd.member_display_code_col, fxd.member_b_table_name,
       fxd.member_col, fdab.default_assignment, fdab.attribute_varchar_label
   BULK COLLECT INTO l_attribute_id_list, l_member_display_code_list, l_member_b_table_list,
        l_member_col_list, l_default_assign_list, l_attr_varchar_list
  FROM fem_xdim_dimensions fxd, fem_dim_attributes_b fdab
 WHERE fxd.dimension_id (+)= fdab.attribute_dimension_id
   AND fdab.dimension_id = g_dimension_info(p_dimension_varchar_label).dimension_id
   AND fdab.attribute_required_flag = 'Y';

FOR i IN l_member_col_list.FIRST .. l_member_col_list.LAST LOOP
    IF ( l_member_col_list(i) IS NOT NULL) THEN
        EXECUTE IMMEDIATE
          'SELECT ' || l_member_display_code_list(i) || '
           FROM ' || l_member_b_table_list(i) || '
           WHERE ' || l_member_col_list(i) || ' = :1 '
        INTO l_default_assign_list(i)
        USING l_default_assign_list(i);
    END IF;
END LOOP;

FORALL i IN l_default_assign_list.FIRST .. l_default_assign_list.LAST
  EXECUTE IMMEDIATE
  ' INSERT INTO ' ||
         g_dimension_info(p_dimension_varchar_label).attr_t_table_name || ' (' ||
         g_dimension_info(p_dimension_varchar_label).display_code || ',
         value_set_display_code,
         attribute_varchar_label,
         attribute_assign_value,
         attr_assign_vs_display_code,
         version_display_code ,
         status)
    SELECT gdmt.display_code,
         gdmt.value_set_display_code,
         :1,
         DECODE(:2, ''EXTENDED_ACCOUNT_TYPE'',
                gdmt.ext_account_type_code, :3),
         NULL,
         fdavb.version_display_code,
         ''LOAD''
    FROM gcs_dimension_members_t gdmt,
         fem_dim_attr_versions_b fdavb
   WHERE fdavb.default_version_flag = ''Y''
   AND   fdavb.attribute_id = :4
   AND   gdmt.sequence_num = :5 '
   USING l_attr_varchar_list(i),
         l_attr_varchar_list(i),
         l_default_assign_list(i),
         l_attribute_id_list(i),
         p_sequence_num;

  IF (p_dimension_varchar_label = 'COMPANY_COST_CENTER_ORG') THEN

  INSERT INTO fem_cctr_orgs_attr_t
         (cctr_org_display_code,
         value_set_display_code,
         attribute_varchar_label,
         attribute_assign_value,
         attr_assign_vs_display_code,
         version_display_code,
         status)
  SELECT display_code,
         value_set_display_code,
         fdab.attribute_varchar_label,
         cost_center_display_code,
         cost_center_vs_display_code,
         fdavb.version_display_code,
         'LOAD'
    FROM gcs_dimension_members_t ,
         fem_dim_attr_versions_b fdavb,
         fem_dim_attributes_b fdab
   WHERE fdavb.default_version_flag = 'Y'
     AND fdavb.attribute_id = fdab.attribute_id
     AND fdab.attribute_varchar_label = 'COST_CENTER'
     AND fdab.dimension_id = 8
     AND sequence_num = p_sequence_num
     AND cost_center_display_code is not null;

  INSERT INTO fem_cctr_orgs_attr_t
         (cctr_org_display_code,
         value_set_display_code,
         attribute_varchar_label,
         attribute_assign_value,
         attr_assign_vs_display_code,
         version_display_code,
         status)
  SELECT display_code,
         value_set_display_code,
         fdab.attribute_varchar_label,
         company_display_code,
         company_vs_display_code,
         fdavb.version_display_code,
         'LOAD'
    FROM gcs_dimension_members_t ,
         fem_dim_attr_versions_b fdavb,
         fem_dim_attributes_b fdab
   WHERE fdavb.default_version_flag = 'Y'
     AND fdavb.attribute_id = fdab.attribute_id
     AND fdab.attribute_varchar_label = 'COMPANY'
     AND fdab.dimension_id = 8
     AND sequence_num = p_sequence_num
     AND company_display_code is not null;

  END IF;


  FND_FILE.PUT_LINE(FND_FILE.LOG,'Executing EPF Loader');
  FND_FILE.NEW_LINE(FND_FILE.LOG);

  FEM_DIM_MEMBER_LOADER_PKG.Main(errbuf             => x_errbuf,
                                 retcode            => x_retcode,
                                 p_execution_mode   => 'S',
                                 p_dimension_id     => g_dimension_info(p_dimension_varchar_label)
                                                      .dimension_id);

  SELECT status_code
    INTO l_status_code
    FROM Fnd_Concurrent_Requests
   WHERE request_id = FND_GLOBAL.conc_request_id;


  IF (l_status_code = 'E') THEN

   -- Bug Fix : 5232709 , Start
   -- Retreive the _tl, _attr table names of the upload dimension and display the error message

   SELECT fxd.member_tl_table_name ,
          fxd.attribute_table_name
   INTO   l_member_tl_table_name,
          l_member_attr_table_name
   FROM   fem_xdim_dimensions fxd
   WHERE  fxd.dimension_id = g_dimension_info(p_dimension_varchar_label).dimension_id ;

    FND_MESSAGE.set_name( 'GCS', 'GCS_DM_IMPORT_FEM_LDR_ERR' );
    FND_MESSAGE.set_token( 'DIM_B_TABLE' , g_dimension_info(p_dimension_varchar_label).b_table_name   );
    FND_MESSAGE.set_token( 'DIM_TL_TABLE' , l_member_tl_table_name);
    FND_MESSAGE.set_token( 'DIM_ATTR_TABLE', l_member_attr_table_name );

    FND_FILE.PUT_LINE(FND_FILE.LOG,'<<<<  Beginning of Error  >>>>');
    FND_FILE.NEW_LINE(FND_FILE.LOG);
    FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.get );
    FND_FILE.NEW_LINE(FND_FILE.LOG);
    FND_FILE.PUT_LINE(FND_FILE.LOG,'<<<<      End of Error    >>>>');
    FND_FILE.NEW_LINE(FND_FILE.LOG);

    IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure THEN
    fnd_log.STRING(fnd_log.level_procedure,
                   g_pkg_name || '.' || l_api_name, FND_MESSAGE.get );
     END IF;

  ELSE

    FND_FILE.PUT_LINE(FND_FILE.LOG,'<<<<<    Dimension Member Load completed successfully  >>>>>> ');
    FND_FILE.NEW_LINE(FND_FILE.LOG);
  -- Bug Fix : 5232709 , End

  END IF ;

EXCEPTION

  -- Bug Fix : 5232709 , Start
  -- Catch the Unique Constraint Validation exception on the interface tables and display the error message.
  WHEN DUP_VAL_ON_INDEX THEN
     ROLLBACK TO dm_import_start;
     FND_MESSAGE.set_name( 'GCS', 'GCS_DM_IMPORT_DUP_VAL_ERR' );
     FND_MESSAGE.set_token( 'DIM_B_TABLE' , g_dimension_info(p_dimension_varchar_label).b_t_table_name   );
     FND_MESSAGE.set_token( 'DIM_TL_TABLE' , g_dimension_info(p_dimension_varchar_label).tl_t_table_name );
     FND_MESSAGE.set_token( 'DIM_ATTR_TABLE' ,g_dimension_info(p_dimension_varchar_label).attr_t_table_name );

     FND_FILE.PUT_LINE(FND_FILE.LOG,'<<<<  Beginning of Error  >>>>');
     FND_FILE.NEW_LINE(FND_FILE.LOG);
     FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.get );
     FND_FILE.NEW_LINE(FND_FILE.LOG);
     FND_FILE.PUT_LINE(FND_FILE.LOG,'<<<<      End of Error    >>>>');
     FND_FILE.NEW_LINE(FND_FILE.LOG);

     x_errbuf  := SQLERRM;
     x_retcode := '2';

    -- delete submitted data for this run
    DELETE FROM gcs_dimension_members_t
     WHERE sequence_num = p_sequence_num;


    -- Write the appropriate information to the execution report
    IF fnd_log.g_current_runtime_level <= fnd_log.level_error THEN
      fnd_log.STRING(fnd_log.level_error,
                     g_pkg_name || '.' || l_api_name,
                     gcs_utility_pkg.g_module_failure || ' ' || x_errbuf || ' ' ||
                     TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
    END IF;

   -- Bug Fix : 5232709 , End

  WHEN OTHERS THEN
    ROLLBACK TO dm_import_start;

    x_errbuf  := SQLERRM;
    x_retcode := '2';

    -- delete submitted data for this run
    DELETE FROM gcs_dimension_members_t
     WHERE sequence_num = p_sequence_num;

     FND_FILE.PUT_LINE(FND_FILE.LOG,'<<<<  Beginning of Error  >>>>');
     FND_FILE.NEW_LINE(FND_FILE.LOG);
     FND_FILE.PUT_LINE(FND_FILE.LOG, x_errbuf );
     FND_FILE.NEW_LINE(FND_FILE.LOG);
     FND_FILE.PUT_LINE(FND_FILE.LOG,'<<<<      End of Error    >>>>');
     FND_FILE.NEW_LINE(FND_FILE.LOG);

    -- Write the appropriate information to the execution report
    IF fnd_log.g_current_runtime_level <= fnd_log.level_error THEN
      fnd_log.STRING(fnd_log.level_error,
                     g_pkg_name || '.' || l_api_name,
                     gcs_utility_pkg.g_module_failure || ' ' || x_errbuf || ' ' ||
                     TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
    END IF;
END dim_member_import;

---*************************************************************-----

--
-- Procedure
--   DIM_HIER_IMPORT
-- Purpose
--   An API to import dimension hierarchies from Web ADI
-- Arguments
-- Notes
--
PROCEDURE dim_hier_import(x_errbuf                  OUT NOCOPY VARCHAR2,
                          x_retcode                 OUT NOCOPY VARCHAR2,
                          p_sequence_num            IN NUMBER,
                          p_dimension_varchar_label IN VARCHAR2,
                          p_hierarchy_name          IN VARCHAR2,
                          p_version_name            IN VARCHAR2,
                          p_version_start_dt        IN VARCHAR2,
                          p_version_end_dt          IN VARCHAR2,
                          p_analysis_flag           IN VARCHAR2,
                          p_parent_vs_display_code  IN VARCHAR2,
                          p_mvs_flag                IN VARCHAR2) IS
  l_err_parent_display_code    DBMS_SQL.varchar2_table;
  l_err_child_display_code     DBMS_SQL.varchar2_table;
  l_err_parent_vs_display_code DBMS_SQL.varchar2_table;
  l_err_child_vs_display_code  DBMS_SQL.varchar2_table;
  l_err_status                 DBMS_SQL.varchar2_table;

  l_level_exists_flag VARCHAR2(1);
  l_status_code       VARCHAR2(1);
  l_folder_name       VARCHAR2(150);
  l_statement         VARCHAR2(1000);
  l_user_id           NUMBER := fnd_global.user_id;
  l_login_id          NUMBER := fnd_global.login_id;
  l_api_name          VARCHAR2(30) := 'DIM_HIER_IMPORT';

--Bugfix 4665921: Added support for causing impact when value set map is uploaded
  l_object_id                   NUMBER;
  l_dimension_id                NUMBER(15);
  l_consolidation_vs_id         NUMBER;
  l_effective_start_date        DATE;
  l_effective_end_date          DATE;
--Bugfix 4924074 : Date Fromat error
  p_version_start_date          DATE;
  p_version_end_date            DATE;

BEGIN
  SAVEPOINT dh_import_start;

  p_version_start_date :=  FND_CONC_DATE.STRING_TO_DATE(p_version_start_dt);
  p_version_end_date   :=  FND_CONC_DATE.STRING_TO_DATE(p_version_end_dt);

  FND_FILE.NEW_LINE(FND_FILE.LOG);
  FND_FILE.PUT_LINE(FND_FILE.LOG,
                    g_pkg_name || '.' || l_api_name ||
                    ' ENTER : p_sequence_num = ' || p_sequence_num ||
                    ', p_dimension_varchar_label = ' ||
                    p_dimension_varchar_label || ', p_hierarchy_name = ' ||
                    p_hierarchy_name || ', p_version_name = ' ||
                    p_version_name || ', p_version_start_date = ' ||
                    p_version_start_date || ', p_version_end_date = ' ||
                    p_version_end_date || ', p_analysis_flag = ' ||
                    p_analysis_flag || ', p_mvs_flag = ' || p_mvs_flag ||
                    ', p_parent_vs_display_code = ' ||
                    p_parent_vs_display_code);

  IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure THEN
    fnd_log.STRING(fnd_log.level_procedure,
                   g_pkg_name || '.' || l_api_name,
                   gcs_utility_pkg.g_module_enter ||
                   '  p_sequence_num = ' || p_sequence_num ||
                   ', p_dimension_varchar_label = ' ||
                   p_dimension_varchar_label || ', p_hierarchy_name = ' ||
                   p_hierarchy_name || ', p_version_name = ' ||
                   p_version_name || ', p_version_start_date = ' ||
                   p_version_start_date || ', p_version_end_date = ' ||
                   p_version_end_date || ', p_analysis_flag = ' ||
                   p_analysis_flag || ', p_mvs_flag = ' || p_mvs_flag ||
                   ', p_parent_vs_display_code = ' ||
                   p_parent_vs_display_code);
  END IF;

  IF (p_mvs_flag = 'Y') THEN
    -- add root nodes
    INSERT INTO gcs_hier_members_t
      (sequence_num,
       parent_vs_display_code,
       parent_display_code,
       child_vs_display_code,
       child_display_code,
       object_version_number,
       creation_date,
       created_by,
       last_update_date,
       last_updated_by,
       last_update_login)
      SELECT DISTINCT p_sequence_num,
                      parent_vs_display_code,
                      parent_display_code,
                      parent_vs_display_code,
                      parent_display_code,
                      1,
                      SYSDATE,
                      l_user_id,
                      SYSDATE,
                      l_user_id,
                      l_login_id
        FROM gcs_hier_members_t
       WHERE sequence_num = p_sequence_num;

  END IF;

  SELECT folder_name
    INTO l_folder_name
    FROM fem_folders_tl
   WHERE language = userenv('LANG')
     AND folder_id = 1100;

  INSERT INTO fem_hierarchies_t
    (hierarchy_object_name,
     folder_name,
     language,
     dimension_varchar_label,
     hierarchy_type_code,
     group_sequence_enforced_code,
     multi_top_flag,
     multi_value_set_flag,
     hierarchy_usage_code,
     flattened_rows_flag,
     status,
     hier_obj_def_display_name,
     effective_start_date,
     effective_end_date,
     calendar_display_code)
  VALUES
    (p_hierarchy_name,
     l_folder_name,
     USERENV('LANG'),
     p_dimension_varchar_label,
     'OPEN',
     decode(p_analysis_flag,
            'Y',
            'SEQUENCE_ENFORCED_SKIP_LEVEL',
            'NO_GROUPS'),
     'Y',
     p_mvs_flag,
     'STANDARD',
     decode(p_mvs_flag, 'Y', 'N', 'Y'),
     'LOAD',
     p_version_name,
     p_version_start_date,
     nvl(p_version_end_date, p_version_start_date + 365 * 20),
     null);

   DELETE FROM fem_hier_value_sets_t
         WHERE hierarchy_object_name = p_hierarchy_name;

  INSERT INTO fem_hier_value_sets_t
    (hierarchy_object_name, value_set_display_code, language, status)
    SELECT DISTINCT p_hierarchy_name,
                    child_vs_display_code,
                    USERENV('LANG'),
                    'LOAD'
      FROM gcs_hier_members_t
     WHERE sequence_num = p_sequence_num;

  BEGIN
    INSERT INTO fem_hier_value_sets_t
      (hierarchy_object_name, value_set_display_code, language, status)
      SELECT DISTINCT p_hierarchy_name,
                      parent_vs_display_code,
                      USERENV('LANG'),
                      'LOAD'
        FROM gcs_hier_members_t
       WHERE sequence_num = p_sequence_num;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  l_statement := 'INSERT INTO ' ||
                 g_dimension_info(p_dimension_varchar_label)
                .hier_t_table_name || ' (
      hierarchy_object_name,
      hierarchy_obj_def_display_name,
      parent_display_code,
parent_value_set_display_code,
      child_display_code,
      child_value_set_display_code,
display_order_num,
      weighting_pct,
      status,
      language)
    SELECT :1,
           :2,
           NVL(parent_display_code, child_display_code),
           parent_vs_display_code,
           child_display_code,
           child_vs_display_code,
           rownum,   -- bugfix : 5411156
           NULL,
           ''LOAD'',
           USERENV(''LANG'')
      FROM gcs_hier_members_t
     WHERE sequence_num = :3 ';

  IF fnd_log.g_current_runtime_level <= fnd_log.level_statement THEN
    fnd_log.STRING(fnd_log.level_statement,
                   g_pkg_name || '.' || l_api_name,
                   ' l_statement = ' || l_statement);
  END IF;

  EXECUTE IMMEDIATE l_statement
    USING p_hierarchy_name, p_version_name, p_sequence_num;

  FND_FILE.PUT_LINE(FND_FILE.LOG,
                    g_pkg_name || '.' || l_api_name ||
                    ' calling FEM_HIER_LOADER_PKG ');
  FND_FILE.NEW_LINE(FND_FILE.LOG);

  fem_hier_loader_pkg.Main(errbuf                      => x_errbuf,
                           retcode                     => x_retcode,
                           p_execution_mode            => 'S',
                           p_object_definition_id      => g_dimension_info(p_dimension_varchar_label)
                                                         .obj_defn_id,
                           p_dimension_varchar_label   => p_dimension_varchar_label,
                           p_hierarchy_object_name     => p_hierarchy_name,
                           p_hier_obj_def_display_name => p_version_name);

  SELECT status_code
    INTO l_status_code
    FROM Fnd_Concurrent_Requests
   WHERE request_id = FND_GLOBAL.conc_request_id;

  FND_FILE.PUT_LINE(FND_FILE.LOG,
                    g_pkg_name || '.' || l_api_name ||
                    ' FEM_HIER_LOADER_PKG return status : ' ||
                    l_status_code);
  FND_FILE.NEW_LINE(FND_FILE.LOG);

  IF (l_status_code = 'E') THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG,
                      g_pkg_name || '.' || l_api_name ||
                      ' FEM_HIER_LOADER_PKG failed');
    FND_FILE.NEW_LINE(FND_FILE.LOG);

    EXECUTE IMMEDIATE 'SELECT dim_table.parent_display_code, dim_table.child_display_code, ' ||
                      ' dim_table.parent_value_set_display_code, dim_table.child_value_set_display_code, dim_table.status ' ||
                      ' FROM ' ||
                      g_dimension_info(p_dimension_varchar_label)
                     .hier_t_table_name ||
                      ' dim_table, gcs_hier_members_t intf_table' ||
                      ' WHERE intf_table.parent_display_code = dim_table.parent_display_code ' ||
                      ' AND intf_table.child_display_code = dim_table.child_display_code ' ||
                      ' AND intf_table.sequence_num = :1 ' BULK COLLECT
      INTO l_err_parent_display_code, l_err_child_display_code, l_err_parent_vs_display_code, l_err_child_vs_display_code, l_err_status
      USING p_sequence_num;

    IF l_err_parent_display_code.FIRST IS NOT NULL THEN
      FOR i IN l_err_parent_display_code.FIRST .. l_err_parent_display_code.LAST LOOP
        FND_FILE.PUT_LINE(FND_FILE.LOG,
                          ' Errored parent : ' ||
                          l_err_parent_display_code(i) ||
                          '; Errored parent value set : ' ||
                          l_err_parent_vs_display_code(i) ||
                          '; Errored child : ' ||
                          l_err_child_display_code(i) ||
                          '; Errored child value set : ' ||
                          l_err_child_vs_display_code(i) ||
                          '; Errored cause : ' || l_err_status(i));
        FND_FILE.NEW_LINE(FND_FILE.LOG);
      END LOOP;

      DELETE FROM fem_hierarchies_t
       WHERE hierarchy_object_name = p_hierarchy_name
         AND hier_obj_def_display_name = p_version_name;

      DELETE FROM fem_hier_value_sets_t
       WHERE hierarchy_object_name = p_hierarchy_name;

      FORALL i IN l_err_parent_display_code.FIRST .. l_err_parent_display_code.LAST
          EXECUTE IMMEDIATE
             'DELETE FROM ' ||
             g_dimension_info(p_dimension_varchar_label).hier_t_table_name || '
              WHERE parent_display_code =:1
              AND child_display_code = :2
              AND parent_value_set_display_code = :3
              AND child_value_set_display_code = :4
              AND hierarchy_object_name = :5
              AND hierarchy_obj_def_display_name = :6'
           USING
              l_err_parent_display_code(i),
              l_err_child_display_code(i),
              l_err_parent_vs_display_code(i),
              l_err_child_vs_display_code(i),
              p_hierarchy_name,
              p_version_name
        ;

    END IF;

  ELSIF (p_mvs_flag = 'Y') THEN

    --Bugfix 4665921: Added support for causing impact when value set map is uploaded
    SELECT foct.object_id,
           fh.dimension_id,
           fgvcd.value_set_id,
           fodb.effective_start_date,
           fodb.effective_end_date
    INTO   l_object_id,
           l_dimension_id,
           l_consolidation_vs_id,
           l_effective_start_date,
           l_effective_end_date
    FROM   fem_object_catalog_tl        foct,
           fem_object_definition_b      fodb,
           fem_object_definition_tl     fodt,
           fem_hierarchies              fh,
           fem_global_vs_combo_defs     fgvcd,
           gcs_system_options           gso
    WHERE  foct.language                =       USERENV('LANG')
    AND    fodb.object_definition_id    =       fodt.object_definition_id
    AND    foct.object_name             =       p_hierarchy_name
    AND    foct.object_id               =       fodt.object_id
    AND    fodt.display_name            =       p_version_name
    AND    fodt.language                =       USERENV('LANG')
    AND    foct.object_id               =       fh.hierarchy_obj_id
    AND    gso.fch_global_vs_combo_id   =       fgvcd.global_vs_combo_id
    AND    fgvcd.dimension_id           =       fh.dimension_id;

    UPDATE fem_xdim_dimensions fxd
    SET    default_mvs_hierarchy_obj_id = l_object_id
    WHERE  dimension_id                 = l_dimension_id;

    gcs_cons_impact_analysis_pkg.value_set_map_updated( p_dimension_id         =>       l_dimension_id,
                                                        p_eff_start_date       =>       l_effective_start_date,
                                                        p_eff_end_date         =>       l_effective_end_date,
                                                        p_consolidation_vs_id  =>       l_consolidation_vs_id);

  END IF;

  -- delete submitted data for this run
  DELETE FROM gcs_hier_members_t WHERE sequence_num = p_sequence_num;

  FND_FILE.PUT_LINE(FND_FILE.LOG,
                    g_pkg_name || '.' || l_api_name || ' EXIT');
  FND_FILE.NEW_LINE(FND_FILE.LOG);

  IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure THEN
    fnd_log.STRING(fnd_log.level_procedure,
                   g_pkg_name || '.' || l_api_name,
                   gcs_utility_pkg.g_module_success || ' ' || l_api_name ||
                   '() ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
  END IF;

EXCEPTION
  WHEN level_program_error THEN
    ROLLBACK TO dh_import_start;

    x_retcode := '2';

    DELETE FROM gcs_hier_members_t WHERE sequence_num = p_sequence_num;

    FND_FILE.PUT_LINE(FND_FILE.LOG,
                      g_pkg_name || '.' || l_api_name || ' ERROR : ' ||
                      x_errbuf);
    FND_FILE.NEW_LINE(FND_FILE.LOG);
    FND_FILE.PUT_LINE(FND_FILE.LOG,
                      'Conflicting levels exist for some members');
    FND_FILE.NEW_LINE(FND_FILE.LOG);

  WHEN OTHERS THEN
    ROLLBACK TO dh_import_start;

    x_errbuf  := SQLERRM;
    x_retcode := '2';

    DELETE FROM gcs_hier_members_t WHERE sequence_num = p_sequence_num;

    FND_FILE.PUT_LINE(FND_FILE.LOG,
                      g_pkg_name || '.' || l_api_name || ' ERROR : ' ||
                      x_errbuf);
    FND_FILE.NEW_LINE(FND_FILE.LOG);

    -- Write the appropriate information to the execution report
    IF fnd_log.g_current_runtime_level <= fnd_log.level_error THEN
      fnd_log.STRING(fnd_log.level_error,
                     g_pkg_name || '.' || l_api_name,
                     gcs_utility_pkg.g_module_failure || ' ' || x_errbuf || ' ' ||
                     TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
    END IF;
END dim_hier_import;

--
-- Procedure
--   dim_hier_upload
-- Purpose
--   An API to upload dimension hierarchies header info from Web ADI
-- Arguments
-- Notes
--
PROCEDURE dim_hier_upload(p_dimension_varchar_label IN VARCHAR2,
                          p_hierarchy_name          IN VARCHAR2,
                          p_version_name            IN VARCHAR2,
                          p_version_start_date      IN VARCHAR2,
                          p_version_end_date        IN VARCHAR2,
                          p_analysis_flag           IN VARCHAR2,
                          p_mvs_flag                IN VARCHAR2) IS
BEGIN
  NULL;
END;

--
-- Procedure
--   handle_interco_map_flag
-- Purpose
--   An API to set the value for the GCS_SYSTEM_OPTIONS.INTERCO_MAP_ENABLED_FLAG
-- Arguments
-- Notes
--
PROCEDURE handle_interco_map_flag IS
   l_cnt               NUMBER ;
   l_api_name          VARCHAR2(30) := 'handle_interco_map_flag';
BEGIN
  FND_FILE.NEW_LINE(FND_FILE.LOG);
  FND_FILE.PUT_LINE(FND_FILE.LOG,
                    g_pkg_name || '.' || l_api_name );
  IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure THEN
    fnd_log.STRING(fnd_log.level_procedure,
                   g_pkg_name || '.' || l_api_name ,'Begin');
  END IF;
  IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure THEN
    fnd_log.STRING(fnd_log.level_procedure,
                   g_pkg_name || '.' || l_api_name ,
                   ' SELECT count(*)
                    INTO  l_cnt
                    FROM gcs_interco_map_dtls; ');
  END IF;
  SELECT count(*)
      INTO  l_cnt
      FROM gcs_interco_map_dtls;

  IF l_cnt > 0 THEN
     IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure THEN
     fnd_log.STRING(fnd_log.level_procedure,
                   g_pkg_name || '.' || l_api_name ,
                   ' UPDATE GCS_SYSTEM_OPTIONS
                     SET  INTERCO_MAP_ENABLED_FLAG = ''Y''; ');
     END IF;
     UPDATE GCS_SYSTEM_OPTIONS
       SET  INTERCO_MAP_ENABLED_FLAG = 'Y';

  ELSE
     IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure THEN
     fnd_log.STRING(fnd_log.level_procedure,
                   g_pkg_name || '.' || l_api_name ,
                   ' UPDATE GCS_SYSTEM_OPTIONS
                     SET  INTERCO_MAP_ENABLED_FLAG = ''N''; ');
     END IF;
     UPDATE GCS_SYSTEM_OPTIONS
       SET  INTERCO_MAP_ENABLED_FLAG = 'N';

  END IF;
  COMMIT;
END handle_interco_map_flag ;

BEGIN

init_dimension_attrs();

END gcs_webadi_pkg;


/
