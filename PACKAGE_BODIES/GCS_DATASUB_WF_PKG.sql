--------------------------------------------------------
--  DDL for Package Body GCS_DATASUB_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_DATASUB_WF_PKG" as
  /* $Header: gcs_datasub_wfb.pls 120.29 2007/09/25 13:29:45 akeesara noship $ */

  g_api VARCHAR2(80) := 'gcs.plsql.GCS_DATASUB_WF_PKG';

  -- Dimension Attribute Information
  g_entity_ledger_attr      NUMBER(15) := gcs_utility_pkg.g_dimension_attr_info('ENTITY_ID-LEDGER_ID')
                                         .attribute_id;
  g_entity_ledger_version   NUMBER(15) := gcs_utility_pkg.g_dimension_attr_info('ENTITY_ID-LEDGER_ID')
                                         .version_id;
  g_ledger_curr_attr        NUMBER(15) := gcs_utility_pkg.g_dimension_attr_info('LEDGER_ID-LEDGER_FUNCTIONAL_CRNCY_CODE')
                                         .attribute_id;
  g_ledger_curr_version     NUMBER(15) := gcs_utility_pkg.g_dimension_attr_info('LEDGER_ID-LEDGER_FUNCTIONAL_CRNCY_CODE')
                                         .version_id;
  g_ledger_system_attr      NUMBER(15) := gcs_utility_pkg.g_dimension_attr_info('LEDGER_ID-SOURCE_SYSTEM_CODE')
                                         .attribute_id;
  g_ledger_system_version   NUMBER(15) := gcs_utility_pkg.g_dimension_attr_info('LEDGER_ID-SOURCE_SYSTEM_CODE')
                                         .version_id;
  g_ledger_vs_combo_attr    NUMBER(15) := gcs_utility_pkg.g_dimension_attr_info('LEDGER_ID-GLOBAL_VS_COMBO')
                                         .attribute_id;
  g_ledger_vs_combo_version NUMBER(15) := gcs_utility_pkg.g_dimension_attr_info('LEDGER_ID-GLOBAL_VS_COMBO')
                                         .version_id;

  -- Beginning of Private Procedures

  -- Bugfix 4969879: Removed get_reference_data_info

  PROCEDURE get_datasub_dtls(p_load_id      IN NUMBER,
                             p_datasub_info IN OUT NOCOPY r_datasub_info) IS

    -- Bugfix 5066041: Added support for additional data types
    l_balance_type_attr           NUMBER := gcs_utility_pkg.g_dimension_attr_info('DATASET_CODE-DATASET_BALANCE_TYPE_CODE')
                                            .attribute_id;
    l_balance_type_version        NUMBER := gcs_utility_pkg.g_dimension_attr_info('DATASET_CODE-DATASET_BALANCE_TYPE_CODE')
                                            .version_id;
    l_budget_attr                 NUMBER := gcs_utility_pkg.g_dimension_attr_info('DATASET_CODE-BUDGET_ID')
                                            .attribute_id;
    l_budget_version              NUMBER := gcs_utility_pkg.g_dimension_attr_info('DATASET_CODE-BUDGET_ID')
                                            .version_id;
    l_encumbrance_attr            NUMBER := gcs_utility_pkg.g_dimension_attr_info('DATASET_CODE-ENCUMBRANCE_TYPE_ID')
                                            .attribute_id;
    l_encumbrance_version         NUMBER := gcs_utility_pkg.g_dimension_attr_info('DATASET_CODE-ENCUMBRANCE_TYPE_ID')
                                            .version_id;

    -- Bug Fix: 5843592, Get the attribute id and version id of the CAL_PERIOD_END_DATE of calendar period
    l_period_end_date_attr        NUMBER := gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-CAL_PERIOD_END_DATE')
                                            .attribute_id;
    l_period_end_date_version     NUMBER := gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-CAL_PERIOD_END_DATE')
                                            .version_id;

  BEGIN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.GET_DATASUB_DTLS.begin',
                     '<<Enter>>');
    END IF;

    --Bugfix 4969879: Added support for data types data model.
    --Bugfix 5843592: Query modified to get the date effective source data details from gcs_entities_attr

    SELECT gdsd.load_id,
           gdsd.load_name,
           gdsd.entity_id,
           gdsd.cal_period_id,
           gdsd.currency_code,
           gdsd.balance_type_code,
           gdsd.load_method_code,
           gdsd.currency_type_code,
           gdsd.amount_type_code,
           gdsd.measure_type_code,
           gdsd.notify_options_code,
           gea.ledger_id,
           feb.entity_display_code,
           flb.ledger_display_code,
           gea.transform_rule_set_id,
           gea.validation_rule_set_id,
           gea.balances_rule_id,
           gea.source_system_code,
           gdtcb.source_dataset_code,
           fda.dim_attribute_varchar_member
      INTO p_datasub_info.load_id,
           p_datasub_info.load_name,
           p_datasub_info.entity_id,
           p_datasub_info.cal_period_id,
           p_datasub_info.currency_code,
           p_datasub_info.balance_type_code,
           p_datasub_info.load_method_code,
           p_datasub_info.currency_type_code,
           p_datasub_info.amount_type_code,
           p_datasub_info.measure_type_code,
           p_datasub_info.notify_options_code,
           p_datasub_info.ledger_id,
           p_datasub_info.entity_display_code,
           p_datasub_info.ledger_display_code,
           p_datasub_info.transform_rule_set_id,
           p_datasub_info.validation_rule_set_id,
           p_datasub_info.balances_rule_id,
           p_datasub_info.source_system_code,
           p_datasub_info.dataset_code,
           p_datasub_info.ds_balance_type_code
      FROM gcs_data_sub_dtls     gdsd,
           fem_entities_b        feb,
           fem_ledgers_b         flb,
           gcs_entities_attr     gea,
           gcs_data_type_codes_b gdtcb,
           fem_datasets_attr     fda,
 		       fem_cal_periods_attr  fcpa
     WHERE gdsd.load_id           = p_load_id
       AND gdsd.entity_id         = feb.entity_id
       AND feb.entity_id          = gea.entity_id
       AND gea.data_type_code     = gdsd.balance_type_code
       AND gdsd.balance_type_code = gdtcb.data_type_code
       AND flb.ledger_id          = gea.ledger_id
       AND fda.dataset_code       = gdtcb.source_dataset_code
       AND fda.attribute_id       = l_balance_type_attr
       AND fda.version_id         = l_balance_type_version
	     AND fcpa.cal_period_id     = gdsd.cal_period_id
	     AND fcpa.attribute_id      = l_period_end_date_attr
	     AND fcpa.version_id        = l_period_end_date_version
	     AND fcpa.date_assign_value BETWEEN gea.effective_start_date
	                        	      AND NVL(gea.effective_end_date, fcpa.date_assign_value ) ;

    --Bugfix 5066041: Check the encumbrance type id or budget id
    IF (p_datasub_info.ds_balance_type_code = 'BUDGET') THEN
      SELECT fb.budget_id,
             fb.budget_display_code
        INTO p_datasub_info.budget_id,
             p_datasub_info.budget_display_code
        FROM fem_datasets_attr fda,
             fem_budgets_b fb
       WHERE fda.dataset_code = p_datasub_info.dataset_code
         AND fda.attribute_id = l_budget_attr
         AND fda.version_id   = l_budget_version
         AND fb.budget_id     = fda.dim_attribute_numeric_member;

    ELSIF (p_datasub_info.ds_balance_type_code = 'ENCUMBRANCE') THEN
      SELECT fetb.encumbrance_type_id,
             fetb.encumbrance_type_code
        INTO p_datasub_info.encumbrance_type_id,
             p_datasub_info.encumbrance_type_code
        FROM fem_datasets_attr fda,
             fem_encumbrance_types_b fetb
       WHERE fda.dataset_code = p_datasub_info.dataset_code
         AND fda.attribute_id = l_encumbrance_attr
         AND fda.version_id   = l_encumbrance_version
         AND fetb.encumbrance_type_id = fda.dim_attribute_numeric_member;

    END IF;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.GET_DATASUB_DTLS.end',
                     '<<Exit>>');
    END IF;
  END get_datasub_dtls;

  PROCEDURE process_external_entity(p_load_id      NUMBER,
                                    p_datasub_info r_datasub_info)

   IS
    l_execution_mode     VARCHAR2(1);
    l_errbuf             VARCHAR2(200);
    l_retcode            VARCHAR2(200);
    l_status_code        VARCHAR2(30);
    l_ret_status_code    BOOLEAN;
    l_event_key          VARCHAR2(200);
    l_dataset_code       NUMBER;
    l_source_system_code NUMBER;
    l_request_id         NUMBER(15);
  BEGIN

    fnd_file.put_line(fnd_file.log, 'Processing an External Entity');

    --Bugfix 4969879: Remove call to get_reference_data_info as this is already stored on p_datasub_info

    l_event_key := 'Load Identifier : ' || p_load_id;

    -- Launch the Workflow
    fnd_file.put_line(fnd_file.log, 'Launching Workflow');
    --Bugfix 5197891: Pass the corrrect owner rather than null value for workflow
    WF_ENGINE.CreateProcess('DATASUB',
                            l_event_key,
                            'GCSDATASUB',
                            l_event_key,
                            FND_GLOBAL.USER_NAME);
    WF_ENGINE.SetItemAttrNumber('DATASUB',
                                l_event_key,
                                'LOAD_ID',
                                p_load_id);
    WF_ENGINE.StartProcess('DATASUB', l_event_key);

    SELECT status_code
      INTO l_status_code
      FROM gcs_data_sub_dtls
     WHERE load_id = p_load_id;

    fnd_file.put_line(fnd_file.log, 'Completed Workflow');

    IF (l_status_code = 'IN_PROGRESS') THEN
      -- Submit the Engine
      BEGIN
        SELECT 'I'
          INTO l_execution_mode
          FROM fem_data_locations fdl,
               fem_ledgers_attr fla
         WHERE fdl.ledger_id     = p_datasub_info.ledger_id
           AND fdl.cal_period_id = p_datasub_info.cal_period_id
           AND fdl.dataset_code  = p_datasub_info.dataset_code
           AND fdl.source_system_code = p_datasub_info.source_system_code
           AND ROWNUM < 2;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_execution_mode := 'S';
      END;

      fnd_file.put_line(fnd_file.log,
                        'Executing External Ledger Integration');

      FEM_XGL_POST_ENGINE_PKG.Main(x_errbuf             => l_errbuf,
                                   x_retcode            => l_retcode,
                                   p_execution_mode     => l_execution_mode,
                                   p_ledger_id          => p_datasub_info.ledger_id,
                                   p_cal_period_id      => p_datasub_info.cal_period_id,
                                   p_budget_id          => p_datasub_info.budget_id,
                                   p_enc_type_id        => p_datasub_info.encumbrance_type_id,
                                   p_dataset_code       => p_datasub_info.dataset_code,
                                   p_xgl_int_obj_def_id => 1000,
                                   p_qtd_ytd_code       => 'YTD');

      COMMIT;

      fnd_file.put_line(fnd_file.log,
                        'Completed External Ledger Integration');

      fnd_file.put_line(fnd_file.log, 'Raising Pristine Data Event');

      raise_impact_analysis_event(p_load_id   => p_load_id,
                                  p_ledger_id => p_datasub_info.ledger_id);

      fnd_file.put_line(fnd_file.log, 'Updating Process Status');

      update_status(p_load_id => p_load_id);

      fnd_file.put_line(fnd_file.log, 'Updating Data Status');

      -- Bugfix 5676634: Submit request for data status update instead of API call
      -- issuing a commit prior to request submission to ensure information is going
      --to be available to the concurrent program which will run in different context/session

      --gcs_cons_monitor_pkg.update_data_status(p_load_id          => p_load_id,
      --                                        p_cons_rel_id      => null,
      --                                        p_hierarchy_id     => null,
      --                                        p_transaction_type => null);
      COMMIT;
      l_request_id := fnd_request.submit_request(application => 'GCS',
                                                 program     => 'FCH_UPDATE_DATA_STATUS',
                                                 sub_request => FALSE,
                                                 argument1   => p_load_id,
                                                 argument2   => NULL,
                                                 argument3   => NULL,
                                                 argument4   => NULL);

      --gcs_xml_gen_pkg.generate_ds_xml(p_load_id => p_load_id);
      l_request_id := fnd_request.submit_request(application => 'GCS',
                                                 program     => 'FCH_XML_WRITER',
                                                 sub_request => FALSE,
                                                 argument1   => 'DATASUBMISSION',
                                                 argument2   => NULL,
                                                 argument3   => NULL,
                                                 argument4   => p_load_id);

      fnd_file.put_line(fnd_file.log,
                        'Submitted XML Generation Request Id: ' ||
                        l_request_id);

    ELSE
      -- Bug Fix : 5234796
      fnd_file.put_line(fnd_file.log, '<<<<< Beginning of Error >>>>>');
      IF (l_status_code = 'VALIDATION_MEMBERS_FAILED') THEN
        fnd_file.put_line(fnd_file.log,
                          'Validations on dimension members failed. Please review the error_message_code column or data loaded report to see which members are invalid.');
      ELSIF (l_status_code = 'VALIDATION_FAILED') THEN
        fnd_file.put_line(fnd_file.log,
                          'Validations on data failed. Please review the error_message_code column or data loaded report to see which trial balance rows are invalid.');
        --Bugfix 5261560: Added new validations on whether the transfer processed correctly or not
      ELSIF (l_status_code = 'INVALID_FEM_INDEX') THEN
        fnd_file.put_line(fnd_file.log,
                          'The index defined on FEM_BAL_INTERFACE_T does not contain all columns that are part of the processing key. Please review the index definition.');
      ELSIF (l_status_code = 'TRANSFER_ERROR') THEN
        fnd_file.put_line(fnd_file.log,
                          'The transfer of data from GCS_BAL_INTERFACE_T to FEM_BAL_INTERFACE_T failed. Please review the information in FND_LOG_MESSAGES for more details.');
      ELSE
        fnd_file.put_line(fnd_file.log, 'Transformation on data failed.');
      END IF;
      fnd_file.put_line(fnd_file.log, '<<<<< End of Error >>>>>');

      -- Transformation or Validation Failed
      UPDATE gcs_data_sub_dtls
         SET status_code       = 'ERROR',
             end_time          = sysdate,
             last_updated_by   = FND_GLOBAL.USER_ID,
             last_update_login = FND_GLOBAL.LOGIN_ID,
             last_update_date  = sysdate
       WHERE load_id = p_load_id;

      --gcs_xml_gen_pkg.generate_ds_xml(p_load_id => p_load_id);
      -- There is no need to launch the XML Generator if the data submission errored. This skep may be skipped. The code is being deleted.
      l_ret_status_code := fnd_concurrent.set_completion_status(status  => 'ERROR',
                                                                message => NULL);
    END IF;

  END process_external_entity;

  PROCEDURE process_internal_entity(p_load_id      NUMBER,
                                    p_datasub_info r_datasub_info)

   IS
    l_errbuf                  VARCHAR2(200);
    l_retcode                 VARCHAR2(200);
    l_chart_of_accounts_id    NUMBER(15);
    l_enable_avg_bal_flag     VARCHAR2(1);
    l_company_value_low       VARCHAR2(150);
    l_company_value_high      VARCHAR2(150);
    l_currency_code           VARCHAR2(30);
    l_currency_option_code    VARCHAR2(30);
    l_xlated_bal_option_code  VARCHAR2(30);
    l_bal_rule_obj_def_id     NUMBER;
    l_cal_period_end_date     DATE;


    l_period_end_date_attr    NUMBER := gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-CAL_PERIOD_END_DATE')
                                       .attribute_id;
    l_period_end_date_version NUMBER := gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-CAL_PERIOD_END_DATE')
                                       .version_id;
    l_balances_rule_attr      NUMBER := gcs_utility_pkg.g_dimension_attr_info('ENTITY_ID-BALANCES_RULE_ID')
                                       .attribute_id;
    l_balances_rule_version   NUMBER := gcs_utility_pkg.g_dimension_attr_info('ENTITY_ID-BALANCES_RULE_ID')
                                       .version_id;
    l_global_vs_combo_attr    NUMBER := gcs_utility_pkg.g_dimension_attr_info('LEDGER_ID-GLOBAL_VS_COMBO')
                                       .attribute_id;
    l_global_vs_combo_version NUMBER := gcs_utility_pkg.g_dimension_attr_info('LEDGER_ID-GLOBAL_VS_COMBO')
                                       .version_id;
    l_company_attr            NUMBER := gcs_utility_pkg.g_dimension_attr_info('COMPANY_COST_CENTER_ORG_ID-COMPANY')
                                       .attribute_id;
    l_company_version         NUMBER := gcs_utility_pkg.g_dimension_attr_info('COMPANY_COST_CENTER_ORG_ID-COMPANY')
                                       .version_id;
    l_global_vs_combo_id      NUMBER(9);
    l_status_code             VARCHAR2(1);
    l_hier_obj_definition_id  NUMBER(9);
    l_hier_obj_id             NUMBER(9);
    l_company_vs_id           NUMBER;
    l_fch_company_vs_id       NUMBER;
    l_org_vs_id               NUMBER;
    l_fch_org_vs_id           NUMBER;
    l_cal_period_name         VARCHAR2(150);
    l_error_occurred          BOOLEAN := FALSE;
    l_code_point              VARCHAR2(200);
    l_request_id              NUMBER(15);

    CURSOR c_generated_loads IS
      SELECT gdsd.load_id
        FROM gcs_data_sub_dtls gdsd
       WHERE gdsd.associated_request_id = FND_GLOBAL.CONC_REQUEST_ID;

    --Bugfix 4507953: Rely on translated balances select, rather than REQUEST_ID select
    CURSOR c_translated_balances(p_request_id NUMBER, p_object_id NUMBER, p_ledger_id NUMBER, p_cal_period_id NUMBER) IS

      SELECT DISTINCT translated_currency
        FROM fem_dl_trans_curr
       WHERE request_id   >= p_request_id
         AND object_id     = p_object_id
         AND ledger_id     = p_ledger_id
         AND cal_period_id = p_cal_period_id;

  BEGIN

    fnd_file.put_line(fnd_file.log, 'Processing an Internal Entity');

    fnd_file.put_line(fnd_file.log,
                      'Retrieving Chart of Accounts Information');

    SELECT gsob.chart_of_accounts_id,
           gsob.currency_code
      INTO l_chart_of_accounts_id,
           l_currency_code
      FROM gl_sets_of_books gsob
     WHERE gsob.set_of_books_id = p_datasub_info.ledger_id;

    fnd_file.put_line(fnd_file.log, 'Retrieving Balances Rule Information');

    SELECT fibrd.bal_rule_obj_def_id,
           fibrd.currency_option_code,
           fibrd.xlated_bal_option_code,
           fibr.include_avg_bal_flag,
           fcpa.date_assign_value,
           fcpv.cal_period_name
      INTO l_bal_rule_obj_def_id,
           l_currency_option_code,
           l_xlated_bal_option_code,
           l_enable_avg_bal_flag,
           l_cal_period_end_date,
           l_cal_period_name
      FROM fem_intg_bal_rule_defs  fibrd,
           fem_intg_bal_rules      fibr,
           fem_object_definition_b fodb,
           fem_cal_periods_attr    fcpa,
           fem_cal_periods_vl      fcpv
     WHERE fibrd.bal_rule_obj_def_id = fodb.object_definition_id
       AND fibr.bal_rule_obj_id      = fodb.object_id
       AND fodb.object_id            = p_datasub_info.balances_rule_id
       AND fcpa.cal_period_id        = p_datasub_info.cal_period_id
       AND fcpa.cal_period_id        = fcpv.cal_period_id
       AND fcpa.attribute_id         = l_period_end_date_attr
       AND fcpa.version_id           = l_period_end_date_version
       AND fcpa.date_assign_value BETWEEN fodb.effective_start_date AND
           fodb.effective_end_date;

    UPDATE gcs_data_sub_dtls
       SET currency_code = l_currency_code
     WHERE load_id       = p_datasub_info.load_id;

    --Check if ADB enabled
    fnd_file.put_line(fnd_file.log,
                      'Checking if Average Balances is Enabled');

    IF (l_enable_avg_bal_flag = 'Y') THEN
      -- Bugfix 5630225: Added balances_rule_id to the insert statement
      INSERT INTO gcs_data_sub_dtls
        (load_id,
         load_name,
         entity_id,
         cal_period_id,
         currency_code,
         balance_type_code,
         load_method_code,
         currency_type_code,
         amount_type_code,
         measure_type_code,
         notify_options_code,
         notification_text,
         creation_date,
         created_by,
         last_update_date,
         last_updated_by,
         last_update_login,
         object_version_number,
         start_time,
         locked_flag,
         most_recent_flag,
         associated_request_id,
         status_code,
         balances_rule_id)
        SELECT gcs_data_sub_dtls_s.nextval,
               gcs_data_sub_dtls_s.nextval,
               gdsd.entity_id,
               gdsd.cal_period_id,
               gdsd.currency_code,
               'ADB',
               gdsd.load_method_code,
               gdsd.currency_type_code,
               gdsd.amount_type_code,
               gdsd.measure_type_code,
               gdsd.notify_options_code,
               gdsd.notification_text,
               sysdate,
               fnd_global.user_id,
               sysdate,
               fnd_global.user_id,
               fnd_global.login_id,
               1,
               gdsd.start_time,
               gdsd.locked_flag,
               gdsd.most_recent_flag,
               gdsd.associated_request_id,
               gdsd.status_code,
               gdsd.balances_rule_id
          FROM gcs_data_sub_dtls gdsd
         WHERE gdsd.load_id = p_datasub_info.load_id;
    END IF;

    IF (p_datasub_info.load_method_code = 'SNAPSHOT') THEN
      fnd_file.put_line(fnd_file.log, 'Performing a snapshot load');
      -- Submit Data for All Entities Associated to Balances Rules
      -- Bugfix 5630225: Added balances_rule_id to the insert statement
      -- BugFix 5843592 : Use gcs_entities_attr instead of fem_entities_attr
      INSERT INTO gcs_data_sub_dtls
        (load_id,
         load_name,
         entity_id,
         cal_period_id,
         currency_code,
         balance_type_code,
         load_method_code,
         currency_type_code,
         amount_type_code,
         measure_type_code,
         notify_options_code,
         notification_text,
         creation_date,
         created_by,
         last_update_date,
         last_updated_by,
         last_update_login,
         object_version_number,
         start_time,
         locked_flag,
         most_recent_flag,
         associated_request_id,
         status_code,
         balances_rule_id)
        SELECT gcs_data_sub_dtls_s.nextval,
               gcs_data_sub_dtls_s.nextval,
               gea.entity_id,
               gdsd.cal_period_id,
               gdsd.currency_code,
               gdsd.balance_type_code,
               gdsd.load_method_code,
               gdsd.currency_type_code,
               gdsd.amount_type_code,
               gdsd.measure_type_code,
               gdsd.notify_options_code,
               gdsd.notification_text,
               SYSDATE,
               fnd_global.user_id,
               SYSDATE,
               fnd_global.user_id,
               fnd_global.login_id,
               1,
               gdsd.start_time,
               gdsd.locked_flag,
               gdsd.most_recent_flag,
               gdsd.associated_request_id,
               gdsd.status_code,
               gdsd.balances_rule_id
          FROM gcs_data_sub_dtls    gdsd,
               gcs_entities_attr    gea,
               fem_cal_periods_attr fcpa
         WHERE gdsd.associated_request_id = FND_GLOBAL.CONC_REQUEST_ID
           AND gea.entity_id              <> p_datasub_info.entity_id
           AND gea.balances_rule_id       = gdsd.balances_rule_id
           AND gea.data_type_code         = gdsd.balance_type_code
           AND fcpa.cal_period_id         = gdsd.cal_period_id
	         AND fcpa.attribute_id          = l_period_end_date_attr
	         AND fcpa.version_id            = l_period_end_date_version
	         AND fcpa.date_assign_value BETWEEN gea.effective_start_date
	                        	        AND NVL(gea.effective_end_date, fcpa.date_assign_value ) ;


      fnd_file.put_line(fnd_file.log,
                        'Submitting the balances integration');

      BEGIN
        --Submit the concurrent program
        FEM_INTG_BAL_RULE_ENG_PKG.Main(x_errbuf              => l_errbuf,
                                       x_retcode             => l_retcode,
                                       p_bal_rule_obj_def_id => l_bal_rule_obj_def_id,
                                       p_coa_id              => l_chart_of_accounts_id,
                                       p_from_period         => l_cal_period_name,
                                       p_to_period           => l_cal_period_name,
                                       p_effective_date      => NULL,
                                       p_bsv_range_low       => NULL,
                                       p_bsv_range_high      => NULL);
      EXCEPTION
        WHEN OTHERS THEN
          l_error_occurred := TRUE;
          fnd_file.put_line(fnd_file.log,
                            'An error occurred while synchronizing balances.');
          fnd_file.put_line(fnd_file.log,
                            'Please review the output of the request for more details.');
      END;
    ELSE
      BEGIN
        fnd_file.put_line(fnd_file.log, 'Submitting an incremental load');

        fnd_file.put_line(fnd_file.log,
                          'Checking if chart of accounts mapping is required');
        --Check if chart of accounts mapping is required

        l_code_point := 'RETRIEVE_LOCAL_VALUE_SETS';

        SELECT fla.dim_attribute_numeric_member,
               fgvcd_local_company.value_set_id,
               fgvcd_local_org.value_set_id
          INTO l_global_vs_combo_id,
               l_company_vs_id,
               l_org_vs_id
          FROM fem_ledgers_attr         fla,
               fem_global_vs_combo_defs fgvcd_local_company,
               fem_global_vs_combo_defs fgvcd_local_org
         WHERE fla.ledger_id    = p_datasub_info.ledger_id
           AND fla.attribute_id = l_global_vs_combo_attr
           AND fla.version_id   = l_global_vs_combo_version
           AND fla.dim_attribute_numeric_member =
               fgvcd_local_company.global_vs_combo_id
           AND fgvcd_local_company.dimension_id = 112
           AND fla.dim_attribute_numeric_member =
               fgvcd_local_org.global_vs_combo_id
           AND fgvcd_local_org.dimension_id = 8;

        l_code_point := 'RETRIEVE_CONSOLIDATION_VALUE_SETS';

        SELECT fgvcd_fch_company.value_set_id,
               fgvcd_fch_org.value_set_id
          INTO l_fch_company_vs_id,
               l_fch_org_vs_id
          FROM fem_global_vs_combo_defs fgvcd_fch_company,
               fem_global_vs_combo_defs fgvcd_fch_org
         WHERE fgvcd_fch_company.global_vs_combo_id =
               gcs_utility_pkg.g_fch_global_vs_combo_id
           AND fgvcd_fch_org.global_vs_combo_id =
               fgvcd_fch_company.global_vs_combo_id
           AND fgvcd_fch_org.dimension_id = 8
           AND fgvcd_fch_company.dimension_id = 112;

        IF ((l_fch_company_vs_id <> l_company_vs_id) AND
           (l_fch_org_vs_id <> l_org_vs_id)) THEN

          fnd_file.put_line(fnd_file.log,
                            'Chart of Accounts mapping is reuqired');

          l_code_point := 'RETRIEVE_DEFAULT_HIERARCHY';

          SELECT fxd.default_mvs_hierarchy_obj_id,
                 fodb.object_definition_id
            INTO l_hier_obj_id,
                 l_hier_obj_definition_id
            FROM fem_xdim_dimensions fxd,
                 fem_object_definition_b fodb
           WHERE fxd.dimension_id = 8
             AND fxd.default_mvs_hierarchy_obj_id = fodb.object_id
             AND l_cal_period_end_date BETWEEN fodb.effective_start_date AND
                 fodb.effective_end_date;

          l_code_point := 'RETRIEVING_COMPANY_VALUE_RANGES';

          SELECT min(fcmin.company_display_code),
                 min(fcmax.company_display_code)
            INTO l_company_value_low,
                 l_company_value_high
            FROM fem_companies_b    fcmin,
                 fem_companies_b    fcmax,
                 fem_cctr_orgs_hier fcoh,
                 fem_cctr_orgs_attr fcoa
           WHERE fcoh.hierarchy_obj_def_id = l_hier_obj_definition_id
             AND fcoh.parent_value_set_id  = l_fch_org_vs_id
             AND fcoh.child_value_set_id   = l_org_vs_id
             AND fcoh.child_id             = fcoa.company_cost_center_org_id
             AND fcoh.child_value_set_id   = fcoa.value_set_id
             AND fcoa.attribute_id         = l_company_attr
             AND fcoa.version_id           = l_company_version
             AND fcoa.dim_attribute_numeric_member = fcmin.company_id
             AND fcoa.dim_attribute_numeric_member = fcmax.company_id
             AND fcmin.value_set_id        = l_fch_company_vs_id
             AND fcmax.value_set_id        = l_fch_company_vs_id;
        ELSE
          fnd_file.put_line(fnd_file.log,
                            'Chart of accounts mapping is not required');

          l_code_point := 'RETRIEVING_COMPANY_VALUE_RANGES';

          SELECT min(fcmin.company_display_code),
                 min(fcmax.company_display_code)
            INTO l_company_value_low,
                 l_company_value_high
            FROM fem_companies_b          fcmin,
                 fem_companies_b          fcmax,
                 gcs_entity_organizations geo
           WHERE geo.entity_id                  = p_datasub_info.entity_id
             AND geo.company_cost_center_org_id = fcmin.company_id
             AND geo.company_cost_center_org_id = fcmax.company_id;
        END IF;

        fnd_file.put_line(fnd_file.log, 'Loading the balances data');

        l_code_point := 'SUBMITTING_INTEGRATION';

        --Submit the concurrent program
        FEM_INTG_BAL_RULE_ENG_PKG.Main(x_errbuf              => l_errbuf,
                                       x_retcode             => l_retcode,
                                       p_bal_rule_obj_def_id => l_bal_rule_obj_def_id,
                                       p_coa_id              => l_chart_of_accounts_id,
                                       p_from_period         => l_cal_period_name,
                                       p_to_period           => l_cal_period_name,
                                       p_effective_date      => NULL,
                                       p_bsv_range_low       => l_company_value_low,
                                       p_bsv_range_high      => l_company_value_high);
      EXCEPTION
        WHEN OTHERS THEN
          l_error_occurred := TRUE;
          IF (l_code_point = 'SUBMITING_INTEGRATION') THEN
            fnd_file.put_line(fnd_file.log,
                              'Error occurred while synchronizing balances.');
            fnd_file.put_line(fnd_file.log,
                              'Please review the output file for more details.');
          ELSIF (l_code_point = 'RETRIEVING_COMPANY_VALUE_RANGES') THEN
            fnd_file.put_line(fnd_file.log,
                              'Error while retrieving company values.');
          ELSIF (l_code_point = 'RETRIEVE_DEFAULT_HIERARCHY') THEN
            fnd_file.put_line(fnd_file.log,
                              'The default value set map is not available on the Org Hierarchy');
          ELSIF (l_code_point = 'RETRIEVE_CONSOLIDATION_VALUE_SETS') THEN
            fnd_file.put_line(fnd_file.log,
                              ' Error retrieving the consolidation value sets for the Org and Company dimension.');
          ELSIF (l_code_point = 'RETRIEVE_LOCAL_VALUE_SETS') THEN
            fnd_file.put_line(fnd_file.log,
                              'Error retrieving the local value sets for the Org and Company dimension.');
          END IF;
      END;
    END IF;

    IF (NOT l_error_occurred) THEN

      fnd_file.put_line(fnd_file.log, 'Reviewing translation balances');

      FOR v_translated_balances IN c_translated_balances(FND_GLOBAL.CONC_REQUEST_ID,
                                                         p_datasub_info.balances_rule_id,
                                                         p_datasub_info.ledger_id,
                                                         p_datasub_info.cal_period_id) LOOP
        INSERT INTO gcs_data_sub_dtls
          (load_id,
           load_name,
           entity_id,
           cal_period_id,
           currency_code,
           balance_type_code,
           load_method_code,
           currency_type_code,
           amount_type_code,
           measure_type_code,
           notify_options_code,
           notification_text,
           creation_date,
           created_by,
           last_update_date,
           last_updated_by,
           last_update_login,
           object_version_number,
           start_time,
           locked_flag,
           most_recent_flag,
           associated_request_id,
           status_code,
           balances_rule_id)
          SELECT gcs_data_sub_dtls_s.nextval,
                 gcs_data_sub_dtls_s.nextval,
                 gdsd.entity_id,
                 gdsd.cal_period_id,
                 v_translated_balances.translated_currency,
                 gdsd.balance_type_code,
                 gdsd.load_method_code,
                 gdsd.currency_type_code,
                 gdsd.amount_type_code,
                 gdsd.measure_type_code,
                 gdsd.notify_options_code,
                 gdsd.notification_text,
                 SYSDATE,
                 fnd_global.user_id,
                 SYSDATE,
                 fnd_global.user_id,
                 fnd_global.login_id,
                 1,
                 gdsd.start_time,
                 gdsd.locked_flag,
                 gdsd.most_recent_flag,
                 gdsd.associated_request_id,
                 'IN_PROGRESS',
                 gdsd.balances_rule_id
            FROM gcs_data_sub_dtls gdsd
           WHERE gdsd.associated_request_id = FND_GLOBAL.CONC_REQUEST_ID;

      END LOOP;

      fnd_file.put_line(fnd_file.log,
                        'Setting the concurrent request status');

      SELECT status_code
        INTO l_status_code
        FROM fnd_concurrent_requests
       WHERE request_id = FND_GLOBAL.conc_request_id;

      UPDATE gcs_data_sub_dtls
         SET status_code       = DECODE(l_status_code,
                                        'C',
                                        'COMPLETED',
                                        'E',
                                        'ERROR',
                                        'W',
                                        'WARNING',
                                        'WARNING'),
             end_time          = SYSDATE,
             last_updated_by   = FND_GLOBAL.USER_ID,
             last_update_login = FND_GLOBAL.LOGIN_ID,
             last_update_date  = SYSDATE
       WHERE associated_request_id = FND_GLOBAL.conc_request_id;

      -- Bugfix 5347804: Need to update the most recent flag to 'N' for prior loads
      UPDATE gcs_data_sub_dtls prev_runs
         SET most_recent_flag = 'N'
       WHERE EXISTS (SELECT 'X'
                FROM gcs_data_sub_dtls curr_run
               WHERE curr_run.associated_request_id =
                     FND_GLOBAL.conc_request_id
                 AND curr_run.entity_id     = prev_runs.entity_id
                 AND curr_run.cal_period_id = prev_runs.cal_period_id
                 AND curr_run.currency_code = prev_runs.currency_code
                 AND curr_run.balance_type_code =
                     prev_runs.balance_type_code
                 AND prev_runs.load_id      < curr_run.load_id);

      COMMIT;

      FOR v_generated_loads IN c_generated_loads LOOP

        -- Bugfix 5347804: Raising the impact analysis and updating the data status should only be done if the request completed successfully

        -- Fixed bug 5632567, Added l_retcode <> 1 condition, since incase of incremental load
        -- if no new balances are processed by the balances rule engine
        -- it will set retcode = 1 and request status set to normal completion
        -- So if retcode is 1 then we need not do below processing since nothing has changed since last load
        IF (l_status_code = 'C') THEN
          -- Bugfix 5569620: l_retcode will be null in case load was successful
          -- so raise pristine data event for this case to sync data status
          IF (l_retcode IS NULL OR l_retcode <> 1) THEN
            fnd_file.put_line(fnd_file.log, 'Raising Pristine Data Event');
            raise_impact_analysis_event(p_load_id   => v_generated_loads.load_id,
                                        p_ledger_id => p_datasub_info.ledger_id);

            -- Bugfix 5347804: Do not need to call update status as it is done in prior call
            --
            --fnd_file.put_line(fnd_file.log, 'Updating Process Status');
            --update_status
            --         (p_load_id    =>      v_generated_loads.load_id);

            fnd_file.put_line(fnd_file.log, 'Updating Data Status');

            -- Bugfix 5676634: Submit request for data status update instead of API call

            --gcs_cons_monitor_pkg.update_data_status(p_load_id          => v_generated_loads.load_id,
            --                                        p_cons_rel_id      => null,
            --                                        p_hierarchy_id     => null,
            --                                        p_transaction_type => null);
            l_request_id := fnd_request.submit_request(application => 'GCS',
                                                       program     => 'FCH_UPDATE_DATA_STATUS',
                                                       sub_request => FALSE,
                                                       argument1   => v_generated_loads.load_id,
                                                       argument2   => NULL,
                                                       argument3   => NULL,
                                                       argument4   => NULL);
          END IF;
          --gcs_xml_gen_pkg.generate_ds_xml(p_load_id => v_generated_loads.load_id);
          l_request_id := fnd_request.submit_request(application => 'GCS',
                                                     program     => 'FCH_XML_WRITER',
                                                     sub_request => FALSE,
                                                     argument1   => 'DATASUBMISSION',
                                                     argument2   => NULL,
                                                     argument3   => NULL,
                                                     argument4   => v_generated_loads.load_id);

          --Bugfix 5347804: Commenting out println statement
          --fnd_file.put_line(fnd_file.log, 'Submitted XML Generation Request Id: '||l_request_id);
        END IF;

      END LOOP;

    ELSE
      UPDATE gcs_data_sub_dtls
         SET status_code       = DECODE(l_status_code,
                                        'C',
                                        'COMPLETED',
                                        'E',
                                        'ERROR',
                                        'W',
                                        'WARNING',
                                        'WARNING'),
             end_time          = sysdate,
             last_updated_by   = FND_GLOBAL.USER_ID,
             last_update_login = FND_GLOBAL.LOGIN_ID,
             last_update_date  = sysdate
       WHERE associated_request_id = FND_GLOBAL.conc_request_id;

      --gcs_xml_gen_pkg.generate_ds_xml(p_load_id => p_load_id);
      --Bugfix 5347804: Commenting out call to XML Generation if the process ends in error
      -- l_request_id :=     fnd_request.submit_request(
      --                                  application     => 'GCS',
      --                                  program         => 'FCH_XML_WRITER',
      --                                  sub_request     => FALSE,
      --                                  argument1       => 'DATASUBMISSION',
      --                                  argument2       => NULL,
      --                                  argument3       => NULL,
      --                                  argument4       => p_load_id);

      -- fnd_file.put_line(fnd_file.log, 'Submitted XML Generation Request Id: '||l_request_id);

      l_error_occurred := fnd_concurrent.set_completion_status(status  => 'ERROR',
                                                               message => NULL);
    END IF;

    COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.log, 'An unexpected error occurred');
      fnd_file.put_line(fnd_file.log,
                        'The following SQL Error happened : ' || SQLERRM);

      UPDATE gcs_data_sub_dtls
         SET status_code           = DECODE(l_status_code,
                                        'C',
                                        'COMPLETED',
                                        'E',
                                        'ERROR',
                                        'W',
                                        'WARNING',
                                        'WARNING'),
             end_time              = SYSDATE,
             last_updated_by       = FND_GLOBAL.USER_ID,
             last_update_login     = FND_GLOBAL.LOGIN_ID,
             last_update_date      = SYSDATE
       WHERE associated_request_id = FND_GLOBAL.conc_request_id;

      -- Bugfix 5347804: Need to update the most recent flag to 'N' for prior loads
      UPDATE gcs_data_sub_dtls prev_runs
         SET most_recent_flag = 'N'
       WHERE EXISTS (SELECT 'X'
                FROM gcs_data_sub_dtls curr_run
               WHERE curr_run.associated_request_id =
                     FND_GLOBAL.conc_request_id
                 AND curr_run.entity_id         = prev_runs.entity_id
                 AND curr_run.cal_period_id     = prev_runs.cal_period_id
                 AND curr_run.currency_code     = prev_runs.currency_code
                 AND curr_run.balance_type_code = prev_runs.balance_type_code
                 AND prev_runs.load_id          < curr_run.load_id);

      l_error_occurred := fnd_concurrent.set_completion_status(status  => 'ERROR',
                                                               message => NULL);
  END process_internal_entity;

  -- End of private procedures

  PROCEDURE submit_datasub(x_errbuf  OUT NOCOPY VARCHAR2,
                           x_retcode OUT NOCOPY VARCHAR2,
                           p_load_id IN NUMBER)

   IS

    l_datasub_info r_datasub_info;
    l_locked_flag 	VARCHAR2(1);

  BEGIN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.SUBMIT_DATASUB.begin',
                     '<<Enter>>');
    END IF;

    fnd_file.put_line(fnd_file.log, 'Beginning Data Submission Execution');

    get_datasub_dtls(p_load_id      => p_load_id,
                     p_datasub_info => l_datasub_info);

    --Bugfix 6016288: Getting the most recent lock status for load entity, and preventing the data submission if
    --locked flag is 'Y'

    BEGIN
    SELECT gdsd.locked_flag
      INTO l_locked_flag
      FROM gcs_data_sub_dtls gdsd
     WHERE gdsd.entity_id		= l_datasub_info.entity_id
       AND gdsd.cal_period_id           = l_datasub_info.cal_period_id
       AND gdsd.balance_type_code       = l_datasub_info.balance_type_code
       AND NVL(gdsd.currency_code, 'X') = l_datasub_info.currency_code
       AND gdsd.most_recent_flag	= 'Y';

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_locked_flag :='N';
    END;

    IF (l_locked_flag = 'N') THEN

    UPDATE gcs_data_sub_dtls
       SET most_recent_flag = 'N'
     WHERE entity_id               = l_datasub_info.entity_id
       AND cal_period_id           = l_datasub_info.cal_period_id
       AND NVL(currency_code, 'X') = l_datasub_info.currency_code
       AND balance_type_code       = l_datasub_info.balance_type_code;

    UPDATE gcs_data_sub_dtls
       SET most_recent_flag      = 'Y',
           associated_request_id = FND_GLOBAL.conc_request_id
     WHERE load_id = p_load_id;

    COMMIT;

    fnd_file.put_line(fnd_file.log,
                      'Checking Entity Type either External versus Oracle');

    --Bugfix 4969879: Remove call to check source system, as it has moved to get_datasub_info
    fnd_file.put_line(fnd_file.log,
                      'Source System Code is : ' ||
                      l_datasub_info.source_system_code);

    --Bugfix 5112626: Need to use l_datasub_info.source_system_code rather than l_ledger_source_system_code

    IF (l_datasub_info.source_system_code = 10) THEN
      process_internal_entity(p_load_id      => p_load_id,
                              p_datasub_info => l_datasub_info);
    ELSE
      process_external_entity(p_load_id      => p_load_id,
                              p_datasub_info => l_datasub_info);
    END IF;

    --Bugfix 6016288: If Locked, Put the message into log file, set the request status to warning and delete the
    --record from gcs_data_sub_dtls which is failed to submit.
    ElSE
      fnd_file.put_line(fnd_file.log,
			'Recent Submission is locked, Unlock it and Resubmit');

     DELETE gcs_data_sub_dtls
       WHERE load_id = l_datasub_info.load_id;

      x_retcode := 1;

    END IF;

    COMMIT;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.SUBMIT_DATASUB.end',
                     '<<Exit>>');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.log, SQLERRM);
  END submit_datasub;

  PROCEDURE update_amounts_autonomous(p_datasub_info       IN r_datasub_info,
                                      p_first_ever_loaded  IN VARCHAR2,
                                      p_currency_type_code IN VARCHAR2) IS
    PRAGMA AUTONOMOUS_TRANSACTION;

    l_datasub_info       r_datasub_info := p_datasub_info;
    l_first_ever_loaded  VARCHAR2(1)    := p_first_ever_loaded;
    l_currency_type_code VARCHAR2(30)   := p_currency_type_code;

  BEGIN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.UPDATE_AMOUNTS_AUTONOMOUS.begin',
                     '<<Enter>>');
    END IF;

    IF (l_currency_type_code = 'TRANSLATED') THEN
      UPDATE gcs_bal_interface_t
         SET ytd_debit_balance_e  = DECODE(l_datasub_info.measure_type_code,
                                           'BALANCE',
                                           DECODE(SIGN(ytd_balance_e),
                                                  1,
                                                  ytd_balance_e,
                                                  0),
                                           ytd_debit_balance_e),
             ytd_credit_balance_e = DECODE(l_datasub_info.measure_type_code,
                                           'BALANCE',
                                           DECODE(SIGN(ytd_balance_e),
                                                  -1,
                                                  ABS(ytd_balance_e),
                                                  0),
                                           ytd_credit_balance_e),
             ytd_balance_e        = DECODE(l_datasub_info.measure_type_code,
                                           'DEBIT_CREDIT',
                                           NVL(ytd_debit_balance_e, 0) -
                                           NVL(ytd_credit_balance_e, 0),
                                           ytd_balance_e),
             ptd_debit_balance_e  = DECODE(l_first_ever_loaded,
                                           'Y',
                                           DECODE(l_datasub_info.measure_type_code,
                                                  'BALANCE',
                                                  DECODE(SIGN(ytd_balance_e),
                                                         1,
                                                         ytd_balance_e,
                                                         0),
                                                  ytd_debit_balance_e),
                                           0),
             ptd_credit_balance_e = DECODE(l_first_ever_loaded,
                                           'Y',
                                           DECODE(l_datasub_info.measure_type_code,
                                                  'BALANCE',
                                                  DECODE(SIGN(ytd_balance_e),
                                                         -1,
                                                         ABS(ytd_balance_e),
                                                         0),
                                                  ytd_credit_balance_e),
                                           0),
             ptd_balance_e        = DECODE(l_first_ever_loaded,
                                           'Y',
                                           DECODE(l_datasub_info.measure_type_code,
                                                  'DEBIT_CREDIT',
                                                  NVL(ytd_debit_balance_e, 0) -
                                                  NVL(ytd_credit_balance_e, 0),
                                                  ytd_balance_e),
                                           0),
             currency_code        = DECODE(financial_elem_display_code,
                                           '10000',
                                           'STAT',
                                           l_datasub_info.currency_code)
       WHERE load_id = l_datasub_info.load_id;

    ELSIF (l_datasub_info.currency_type_code = 'BASE_CURRENCY') THEN
      UPDATE gcs_bal_interface_t
         SET ytd_debit_balance_e  = DECODE(l_datasub_info.measure_type_code,
                                           'BALANCE',
                                           DECODE(SIGN(ytd_balance_e),
                                                  1,
                                                  ytd_balance_e,
                                                  0),
                                           ytd_debit_balance_e),
             ytd_credit_balance_e = DECODE(l_datasub_info.measure_type_code,
                                           'BALANCE',
                                           DECODE(SIGN(ytd_balance_e),
                                                  -1,
                                                  ABS(ytd_balance_e),
                                                  0),
                                           ytd_credit_balance_e),
             ytd_balance_e        = DECODE(l_datasub_info.measure_type_code,
                                           'DEBIT_CREDIT',
                                           NVL(ytd_debit_balance_e, 0) -
                                           NVL(ytd_credit_balance_e, 0),
                                           ytd_balance_e),
             ytd_debit_balance_f  = DECODE(l_datasub_info.measure_type_code,
                                           'BALANCE',
                                           DECODE(SIGN(ytd_balance_e),
                                                  1,
                                                  ytd_balance_e,
                                                  0),
                                           ytd_debit_balance_e),
             ytd_credit_balance_f = DECODE(l_datasub_info.measure_type_code,
                                           'BALANCE',
                                           DECODE(SIGN(ytd_balance_e),
                                                  -1,
                                                  ABS(ytd_balance_e),
                                                  0),
                                           ytd_credit_balance_e),
             ytd_balance_f        = DECODE(l_datasub_info.measure_type_code,
                                           'DEBIT_CREDIT',
                                           NVL(ytd_debit_balance_e, 0) -
                                           NVL(ytd_credit_balance_e, 0),
                                           ytd_balance_e),
             ptd_debit_balance_e  = DECODE(l_datasub_info.measure_type_code,
                                           'BALANCE',
                                           DECODE(SIGN(ytd_balance_e),
                                                  1,
                                                  ytd_balance_e,
                                                  0),
                                           ytd_debit_balance_e),
             ptd_credit_balance_e = DECODE(l_datasub_info.measure_type_code,
                                           'BALANCE',
                                           DECODE(SIGN(ytd_balance_e),
                                                  -1,
                                                  ABS(ytd_balance_e),
                                                  0),
                                           ytd_credit_balance_e),
             ptd_balance_e        = DECODE(l_datasub_info.measure_type_code,
                                           'DEBIT_CREDIT',
                                           NVL(ytd_debit_balance_e, 0) -
                                           NVL(ytd_credit_balance_e, 0),
                                           ytd_balance_e),
             ptd_debit_balance_f  = DECODE(l_datasub_info.measure_type_code,
                                           'BALANCE',
                                           DECODE(SIGN(ytd_balance_e),
                                                  1,
                                                  ytd_balance_e,
                                                  0),
                                           ytd_debit_balance_e),
             ptd_credit_balance_f = DECODE(l_datasub_info.measure_type_code,
                                           'BALANCE',
                                           DECODE(SIGN(ytd_balance_e),
                                                  -1,
                                                  ABS(ytd_balance_e),
                                                  0),
                                           ytd_credit_balance_e),
             ptd_balance_f        = DECODE(l_datasub_info.measure_type_code,
                                           'DEBIT_CREDIT',
                                           NVL(ytd_debit_balance_e, 0) -
                                           NVL(ytd_credit_balance_e, 0),
                                           ytd_balance_e),
             currency_code        = DECODE(financial_elem_display_code,
                                           '10000',
                                           'STAT',
                                           l_datasub_info.currency_code)
       WHERE load_id = l_datasub_info.load_id;

    ELSE
      UPDATE gcs_bal_interface_t
         SET ytd_debit_balance_e         = DECODE(l_datasub_info.measure_type_code,
                                                  'BALANCE',
                                                  DECODE(SIGN(ytd_balance_e),
                                                         1,
                                                         ytd_balance_e,
                                                         0),
                                                  ytd_debit_balance_e),
             ytd_credit_balance_e        = DECODE(l_datasub_info.measure_type_code,
                                                  'BALANCE',
                                                  DECODE(SIGN(ytd_balance_e),
                                                         -1,
                                                         ABS(ytd_balance_e),
                                                         0),
                                                  ytd_credit_balance_e),
             ytd_balance_e               = DECODE(l_datasub_info.measure_type_code,
                                                  'DEBIT_CREDIT',
                                                  NVL(ytd_debit_balance_e, 0) -
                                                  NVL(ytd_credit_balance_e, 0),
                                                  ytd_balance_e),
             ytd_debit_balance_f         = DECODE(l_datasub_info.measure_type_code,
                                                  'BALANCE',
                                                  DECODE(SIGN(ytd_balance_f),
                                                         1,
                                                         ytd_balance_f,
                                                         0),
                                                  ytd_debit_balance_f),
             ytd_credit_balance_f        = DECODE(l_datasub_info.measure_type_code,
                                                  'BALANCE',
                                                  DECODE(SIGN(ytd_balance_f),
                                                         -1,
                                                         ABS(ytd_balance_f),
                                                         0),
                                                  ytd_credit_balance_f),
             ytd_balance_f               = DECODE(l_datasub_info.measure_type_code,
                                                  'DEBIT_CREDIT',
                                                  NVL(ytd_debit_balance_f, 0) -
                                                  NVL(ytd_credit_balance_f, 0),
                                                  ytd_balance_f),
             ptd_debit_balance_e         = DECODE(l_datasub_info.measure_type_code,
                                                  'BALANCE',
                                                  DECODE(SIGN(ytd_balance_e),
                                                         1,
                                                         ytd_balance_e,
                                                         0),
                                                  ytd_debit_balance_e),
             ptd_credit_balance_e        = DECODE(l_datasub_info.measure_type_code,
                                                  'BALANCE',
                                                  DECODE(SIGN(ytd_balance_e),
                                                         -1,
                                                         ABS(ytd_balance_e),
                                                         0),
                                                  ytd_credit_balance_e),
             ptd_balance_e               = DECODE(l_datasub_info.measure_type_code,
                                                  'DEBIT_CREDIT',
                                                  NVL(ytd_debit_balance_e, 0) -
                                                  NVL(ytd_credit_balance_e, 0),
                                                  ytd_balance_e),
             ptd_debit_balance_f         = DECODE(l_datasub_info.measure_type_code,
                                                  'BALANCE',
                                                  DECODE(SIGN(ytd_balance_f),
                                                         1,
                                                         ytd_balance_f,
                                                         0),
                                                  ytd_debit_balance_f),
             ptd_credit_balance_f        = DECODE(l_datasub_info.measure_type_code,
                                                  'BALANCE',
                                                  DECODE(SIGN(ytd_balance_f),
                                                         -1,
                                                         ABS(ytd_balance_f),
                                                         0),
                                                  ytd_credit_balance_f),
             ptd_balance_f               = DECODE(l_datasub_info.measure_type_code,
                                                  'DEBIT_CREDIT',
                                                  NVL(ytd_debit_balance_f, 0) -
                                                  NVL(ytd_credit_balance_f, 0),
                                                  ytd_balance_f),
             financial_elem_display_code = DECODE(currency_code,
                                                  'STAT',
                                                  '10000',
                                                  financial_elem_display_code),
             currency_code               = DECODE(financial_elem_display_code,
                                                  '10000',
                                                  'STAT',
                                                  currency_code)
       WHERE load_id = l_datasub_info.load_id;

    END IF;

    COMMIT;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.UPDATE_AMOUNTS_AUTONOMOUS.end',
                     '<<Exit>>');
    END IF;

  END update_amounts_autonomous;

  PROCEDURE transfer_data_autonomous(p_ledger_disp_code        IN VARCHAR2,
                                     p_source_system_disp_code IN VARCHAR2,
                                     p_dim_grp_disp_code       IN VARCHAR2,
                                     p_cal_period_number       IN NUMBER,
                                     p_cal_period_end_date     IN DATE,
                                     p_load_method_code        IN VARCHAR2,
                                     p_bal_post_type_code      IN VARCHAR2,
                                     p_currency_type_code      IN VARCHAR2,
                                     p_entity_display_code     IN VARCHAR2,
                                     p_load_id                 IN NUMBER,
                                     p_line_item_vs_id         IN NUMBER,
                                     p_ds_balance_type_code    IN VARCHAR2,
                                     --Bugfix 5066041: Added support for additional data types
                                     p_budget_display_code   IN VARCHAR2,
                                     p_encumbrance_type_code IN VARCHAR2,
                                     --Bugfix 5261560: Added variable to track if transfer was successful
                                     p_transfer_status OUT NOCOPY VARCHAR2)

   IS
    PRAGMA AUTONOMOUS_TRANSACTION;

    l_line_item_type_attr    NUMBER(15) := gcs_utility_pkg.g_dimension_attr_info('LINE_ITEM_ID-EXTENDED_ACCOUNT_TYPE')
                                          .attribute_id;
    l_line_item_type_version NUMBER(15) := gcs_utility_pkg.g_dimension_attr_info('LINE_ITEM_ID-EXTENDED_ACCOUNT_TYPE')
                                          .version_id;
    l_acct_type_attr         NUMBER(15) := gcs_utility_pkg.g_dimension_attr_info('EXT_ACCOUNT_TYPE_CODE-BASIC_ACCOUNT_TYPE_CODE')
                                          .attribute_id;
    l_acct_type_version      NUMBER(15) := gcs_utility_pkg.g_dimension_attr_info('EXT_ACCOUNT_TYPE_CODE-BASIC_ACCOUNT_TYPE_CODE')
                                          .version_id;

  BEGIN

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.TRANSFER_DATA_AUTONOMOUS.begin',
                     '<<Enter>>');
    END IF;

    INSERT INTO fem_bal_interface_t
      (load_set_id,
       load_method_code,
       bal_post_type_code,
       cal_per_dim_grp_display_code,
       cal_period_number,
       cal_period_end_date,
       cctr_org_display_code,
       currency_code,
       currency_type_code,
       ds_balance_type_code,
       source_system_display_code,
       ledger_display_code,
       financial_elem_display_code,
       product_display_code,
       natural_account_display_code,
       channel_display_code,
       line_item_display_code,
       project_display_code,
       customer_display_code,
       entity_display_code,
       intercompany_display_code,
       task_display_code,
       user_dim1_display_code,
       user_dim2_display_code,
       user_dim3_display_code,
       user_dim4_display_code,
       user_dim5_display_code,
       user_dim6_display_code,
       user_dim7_display_code,
       user_dim8_display_code,
       user_dim9_display_code,
       user_dim10_display_code,
       xtd_balance_e,
       xtd_balance_f,
       ytd_balance_e,
       ytd_balance_f,
       ptd_debit_balance_e,
       ptd_credit_balance_e,
       ytd_debit_balance_e,
       ytd_credit_balance_e,
       --Bugfix 5066041: Added additional columns to support additional data types
       budget_display_code,
       encumbrance_type_code)
      SELECT p_load_id,
             p_load_method_code,
             p_bal_post_type_code,
             p_dim_grp_disp_code,
             p_cal_period_number,
             p_cal_period_end_date,
             gbit.cctr_org_display_code,
             gbit.currency_code,
             p_currency_type_code,
             p_ds_balance_type_code,
             p_source_system_disp_code,
             p_ledger_disp_code,
             gbit.financial_elem_display_code,
             gbit.product_display_code,
             gbit.natural_account_display_code,
             gbit.channel_display_code,
             gbit.line_item_display_code,
             gbit.project_display_code,
             gbit.customer_display_code,
             p_entity_display_code,
             gbit.intercompany_display_code,
             gbit.task_display_code,
             gbit.user_dim1_display_code,
             gbit.user_dim2_display_code,
             gbit.user_dim3_display_code,
             gbit.user_dim4_display_code,
             gbit.user_dim5_display_code,
             gbit.user_dim6_display_code,
             gbit.user_dim7_display_code,
             gbit.user_dim8_display_code,
             gbit.user_dim9_display_code,
             gbit.user_dim10_display_code,
             DECODE(feata.dim_attribute_varchar_member,
                    'REVENUE',
                    NVL(gbit.ptd_balance_e, gbit.ytd_balance_e),
                    'EXPENSE',
                    NVL(gbit.ptd_balance_e, gbit.ytd_balance_e),
                    NVL(gbit.ytd_balance_e, gbit.ptd_balance_e)),
             DECODE(feata.dim_attribute_varchar_member,
                    'REVENUE',
                    NVL(gbit.ptd_balance_f, gbit.ytd_balance_f),
                    'EXPENSE',
                    NVL(gbit.ptd_balance_f, gbit.ytd_balance_f),
                    NVL(gbit.ytd_balance_f, gbit.ptd_balance_f)),
             NVL(gbit.ytd_balance_e, gbit.ptd_balance_e),
             NVL(gbit.ytd_balance_f, gbit.ptd_balance_f),
             DECODE(feata.ext_account_type_code,
                    'RETAINED_EARNINGS',
                    0,
                    NVL(gbit.ptd_debit_balance_e,
                        NVL(gbit.ytd_debit_balance_e, 0))),
             DECODE(feata.ext_account_type_code,
                    'RETAINED_EARNINGS',
                    0,
                    NVL(gbit.ptd_credit_balance_e,
                        NVL(gbit.ytd_credit_balance_e, 0))),
             NVL(gbit.ytd_debit_balance_e, NVL(gbit.ptd_debit_balance_e, 0)),
             NVL(gbit.ytd_credit_balance_e,
                 NVL(gbit.ptd_credit_balance_e, 0)),
             --Bugfix 5066041: Added additional columns to support new data types
             p_budget_display_code,
             p_encumbrance_type_code
        FROM gcs_bal_interface_t     gbit,
             fem_ln_items_b          flb,
             fem_ln_items_attr       flia,
             fem_ext_acct_types_attr feata
       WHERE gbit.load_id                = p_load_id
         AND gbit.line_item_display_code = flb.line_item_display_code
         AND flb.line_item_id            = flia.line_item_id
         AND flb.value_set_id            = p_line_item_vs_id
            -- Attribute for Extended Account Type
            -- Bugfix 4644576: Removed assigning the attributes using hardcoded literals
         AND flia.attribute_id           = l_line_item_type_attr
         AND flia.version_id             = l_line_item_type_version
         AND flia.value_set_id           = flb.value_set_id
         AND flia.dim_attribute_varchar_member =
             feata.ext_account_type_code
         AND feata.attribute_id          = l_acct_type_attr
         AND feata.version_id            = l_acct_type_version;

    COMMIT;

    --Bugfix 5261560: Setting the transfer status to OK
    p_transfer_status := 'OK';

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.TRANSFER_DATA_AUTONOMOUS.end',
                     '<<Exit>>');
    END IF;

    --Bugfix 5261560: Trap errors on transfer to inform the user on errors
  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      UPDATE gcs_data_sub_dtls
         SET status_code = 'INVALID_FEM_INDEX'
       WHERE load_id     = p_load_id;

      p_transfer_status := 'ERROR';

      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
                       g_api || '.TRANSFER_DATA_AUTONOMOUS',
                       '<<Beginning of Error>>');
        FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
                       g_api || '.TRANSFER_DATA_AUTONOMOUS',
                       SQLERRM);
        FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
                       g_api || '.TRANSFER_DATA_AUTONOMOUS',
                       '<<End of Error>>');
      END IF;
      COMMIT;

    WHEN OTHERS THEN
      UPDATE gcs_data_sub_dtls
         SET status_code = 'TRANSFER_ERROR'
       WHERE load_id = p_load_id;

      p_transfer_status := 'ERROR';

      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
                       g_api || '.TRANSFER_DATA_AUTONOMOUS',
                       '<<Beginning of Error>>');
        FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
                       g_api || '.TRANSFER_DATA_AUTONOMOUS',
                       SQLERRM);
        FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
                       g_api || '.TRANSFER_DATA_AUTONOMOUS',
                       '<<End of Error>>');
      END IF;
      COMMIT;

  END transfer_data_autonomous;

  PROCEDURE execute_autonomous(p_logic_type    IN VARCHAR2,
                               p_set_id        IN NUMBER,
                               p_load_id       IN NUMBER,
                               p_return_status IN OUT NOCOPY VARCHAR2) IS

    PRAGMA AUTONOMOUS_TRANSACTION;

    l_msg_count NUMBER(15);
    l_msg_data  VARCHAR2(2000);

  BEGIN

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.EXECUTE_AUTONOMOUS.begin',
                     '<<Exit>>');
    END IF;

    IF (p_logic_type = 'TRANSFORMATION') THEN

      gcs_lex_map_api_pkg.apply_map(p_api_version          => 1.0,
                                    p_init_msg_list        => FND_API.G_FALSE,
                                    p_commit               => FND_API.G_TRUE,
                                    p_validation_level     => NULL,
                                    x_return_status        => p_return_status,
                                    x_msg_count            => l_msg_count,
                                    x_msg_data             => l_msg_data,
                                    p_rule_set_id          => p_set_id,
                                    p_staging_table_name   => 'GCS_BAL_INTERFACE_T',
                                    p_debug_mode           => NULL,
                                    p_filter_column_name1  => 'LOAD_ID',
                                    p_filter_column_value1 => p_load_id);

    ELSIF (p_logic_type = 'VALIDATION') THEN

      gcs_lex_map_api_pkg.apply_validation(p_api_version          => 1.0,
                                           p_init_msg_list        => FND_API.G_FALSE,
                                           p_commit               => FND_API.G_TRUE,
                                           p_validation_level     => NULL,
                                           x_return_status        => p_return_status,
                                           x_msg_count            => l_msg_count,
                                           x_msg_data             => l_msg_data,
                                           p_rule_set_id          => p_set_id,
                                           p_staging_table_name   => 'GCS_BAL_INTERFACE_T',
                                           p_debug_mode           => NULL,
                                           p_filter_column_name1  => 'LOAD_ID',
                                           p_filter_column_value1 => p_load_id);

    END IF;

    COMMIT;
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.EXECUTE_AUTONOMOUS.end',
                     '<<Exit>>');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
                       g_api || '.EXECUTE_AUTONOMOUS',
                       SQLERRM);
      END IF;
      p_return_status := FND_API.G_RET_STS_ERROR;
  END;

  -- End of Private Procedures

  PROCEDURE check_idt_required(p_itemtype IN VARCHAR2,
                               p_itemkey  IN VARCHAR2,
                               p_actid    IN NUMBER,
                               p_funcmode IN VARCHAR2,
                               p_result   IN OUT NOCOPY VARCHAR2) IS

    l_datasub_info r_datasub_info;

  BEGIN

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.CHECK_IDT_REQUIRED.begin',
                     '<<Enter for itemkey : ' || p_itemkey || ' >>');
    END IF;

    get_datasub_dtls(p_load_id      => WF_ENGINE.GetItemAttrNumber(p_itemtype,
                                                                   p_itemkey,
                                                                   'LOAD_ID',
                                                                   FALSE),
                     p_datasub_info => l_datasub_info);

    IF (l_datasub_info.transform_rule_set_id IS NOT NULL) THEN
      p_result := 'COMPLETE:T';
    ELSE
      p_result := 'COMPLETE:F';
    END IF;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.CHECK_IDT_REQUIRED.end',
                     '<<Exit for itemkey : ' || p_itemkey || ' >>');
    END IF;

  END check_idt_required;

  PROCEDURE execute_idt(p_itemtype IN VARCHAR2,
                        p_itemkey  IN VARCHAR2,
                        p_actid    IN NUMBER,
                        p_funcmode IN VARCHAR2,
                        p_result   IN OUT NOCOPY VARCHAR2) IS

    l_datasub_info  r_datasub_info;
    l_return_status VARCHAR2(1);

  BEGIN

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.EXECUTE_IDT.begin',
                     '<<Enter for itemkey : ' || p_itemkey || ' >>');
    END IF;

    get_datasub_dtls(p_load_id      => WF_ENGINE.GetItemAttrNumber(p_itemtype,
                                                                   p_itemkey,
                                                                   'LOAD_ID',
                                                                   FALSE),
                     p_datasub_info => l_datasub_info);

    execute_autonomous(p_logic_type    => 'TRANSFORMATION',
                       p_set_id        => l_datasub_info.transform_rule_set_id,
                       p_load_id       => l_datasub_info.load_id,
                       p_return_status => l_return_status);

    IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
      p_result := 'COMPLETE:T';
    ELSE
      p_result := 'COMPLETE:F';
      UPDATE gcs_data_sub_dtls
         SET status_code = 'TRANSFORMATION_FAILED'
       WHERE load_id = l_datasub_info.load_id;
    END IF;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.EXECUTE_IDT.end',
                     '<<Exit for itemkey : ' || p_itemkey || ' >>');
    END IF;

  END execute_idt;

  PROCEDURE check_validation_required(p_itemtype IN VARCHAR2,
                                      p_itemkey  IN VARCHAR2,
                                      p_actid    IN NUMBER,
                                      p_funcmode IN VARCHAR2,
                                      p_result   IN OUT NOCOPY VARCHAR2) IS

    l_datasub_info r_datasub_info;

  BEGIN

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.CHECK_VALIDATION_REQUIRED.begin',
                     '<<Enter for itemkey : ' || p_itemkey || ' >>');
    END IF;

    get_datasub_dtls(p_load_id      => WF_ENGINE.GetItemAttrNumber(p_itemtype,
                                                                   p_itemkey,
                                                                   'LOAD_ID',
                                                                   FALSE),
                     p_datasub_info => l_datasub_info);

    IF (l_datasub_info.validation_rule_set_id IS NOT NULL) THEN
      p_result := 'COMPLETE:T';
    ELSE
      p_result := 'COMPLETE:F';
    END IF;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.CHECK_VALIDATION_REQUIRED.end',
                     '<<Exit for itemkey : ' || p_itemkey || ' >>');
    END IF;

  END check_validation_required;

  PROCEDURE execute_validation(p_itemtype IN VARCHAR2,
                               p_itemkey  IN VARCHAR2,
                               p_actid    IN NUMBER,
                               p_funcmode IN VARCHAR2,
                               p_result   IN OUT NOCOPY VARCHAR2) IS

    l_datasub_info  r_datasub_info;
    l_return_status VARCHAR2(1);

  BEGIN

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.EXECUTE_VALIDATION.begin',
                     '<<Enter for itemkey : ' || p_itemkey || ' >>');
    END IF;

    get_datasub_dtls(p_load_id      => WF_ENGINE.GetItemAttrNumber(p_itemtype,
                                                                   p_itemkey,
                                                                   'LOAD_ID',
                                                                   FALSE),
                     p_datasub_info => l_datasub_info);

    execute_autonomous(p_logic_type    => 'VALIDATION',
                       p_set_id        => l_datasub_info.validation_rule_set_id,
                       p_load_id       => l_datasub_info.load_id,
                       p_return_status => l_return_status);

    IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
      p_result := 'COMPLETE:T';
    ELSE
      p_result := 'COMPLETE:F';
      UPDATE gcs_data_sub_dtls
         SET status_code = 'VALIDATION_FAILED'
       WHERE load_id = l_datasub_info.load_id;
    END IF;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.EXECUTE_VALIDATION.end',
                     '<<Exit for itemkey : ' || p_itemkey || ' >>');
    END IF;

  END execute_validation;

  PROCEDURE init_datasub_process(p_itemtype IN VARCHAR2,
                                 p_itemkey  IN VARCHAR2,
                                 p_actid    IN NUMBER,
                                 p_funcmode IN VARCHAR2,
                                 p_result   IN OUT NOCOPY VARCHAR2) IS

    l_datasub_info       r_datasub_info;
    l_currency_type_code VARCHAR2(30);
    l_first_ever_loaded  VARCHAR2(1);
    l_func_crncy_code    VARCHAR2(30);
    l_execution_mode     VARCHAR2(1);

  BEGIN

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.INIT_DATASUB_PROCESS.begin',
                     '<<Enter for itemkey : ' || p_itemkey || ' >>');
    END IF;

    get_datasub_dtls(p_load_id      => WF_ENGINE.GetItemAttrNumber(p_itemtype,
                                                                   p_itemkey,
                                                                   'LOAD_ID',
                                                                   FALSE),
                     p_datasub_info => l_datasub_info);

    --Bugfix 4969879: Remove call to get_reference_data_info

    SELECT fla.dim_attribute_varchar_member
      INTO l_func_crncy_code
      FROM fem_ledgers_attr fla
     WHERE fla.ledger_id    = l_datasub_info.ledger_id
       AND fla.attribute_id = g_ledger_curr_attr
       AND fla.version_id   = g_ledger_curr_version;

    IF (l_datasub_info.currency_type_code = 'BASE_CURRENCY') THEN
      IF (l_datasub_info.currency_code <> l_func_crncy_code) THEN
        l_currency_type_code := 'TRANSLATED';
      ELSE
        l_currency_type_code := 'ENTERED';
      END IF;
    ELSE
      l_currency_type_code := 'ENTERED';
    END IF;

    -- Check if this is first ever period
    IF (l_datasub_info.load_method_code IN
       ('INITIAL_LOAD', 'UNDO_AND_REPLACE', 'REPLACE')) THEN
      BEGIN
        SELECT 'N'
          INTO l_first_ever_loaded
          FROM gcs_data_sub_dtls gdsd
         WHERE gdsd.entity_id         = l_datasub_info.entity_id
           AND gdsd.balance_type_code = l_datasub_info.balance_type_code
           AND gdsd.cal_period_id     < l_datasub_info.cal_period_id
           AND NVL(gdsd.currency_code, l_func_crncy_code) =
               NVL(l_datasub_info.currency_code, l_func_crncy_code)
           AND ROWNUM < 2;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_first_ever_loaded := 'Y';
      END;
    ELSE
      l_first_ever_loaded := 'N';
    END IF;

    IF (l_first_ever_loaded = 'N') AND
       (l_datasub_info.load_method_code = 'INCREMENTAL') THEN
      l_first_ever_loaded := 'Y';
    END IF;

    --Check to see if it is first load for the period
    BEGIN
      SELECT 'I'
        INTO l_execution_mode
        FROM fem_data_locations fdl
       WHERE fdl.ledger_id          = l_datasub_info.ledger_id
         AND fdl.cal_period_id      = l_datasub_info.cal_period_id
         AND fdl.dataset_code       = l_datasub_info.dataset_code
         AND fdl.source_system_code = l_datasub_info.source_system_code
         AND rownum < 2;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_execution_mode := 'S';
    END;

    WF_ENGINE.SetItemAttrText(p_itemtype,
                              p_itemkey,
                              'CURRENCYTYPE',
                              l_currency_type_code);
    WF_ENGINE.SetItemAttrText(p_itemtype,
                              p_itemkey,
                              'FIRSTEVERPERIOD',
                              l_first_ever_loaded);
    WF_ENGINE.SetItemAttrText(p_itemtype,
                              p_itemkey,
                              'FUNCCURRENCYCODE',
                              l_func_crncy_code);
    WF_ENGINE.SetItemAttrNumber(p_itemtype,
                                p_itemkey,
                                'LEDGERID',
                                l_datasub_info.ledger_id);
    WF_ENGINE.SetItemAttrText(p_itemtype,
                              p_itemkey,
                              'CALPERIODID',
                              l_datasub_info.cal_period_id);
    WF_ENGINE.SetItemAttrText(p_itemtype,
                              p_itemkey,
                              'EXECUTIONMODE',
                              l_execution_mode);

    p_result := 'COMPLETE';

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.INIT_DATASUB_PROCESS.end',
                     '<<Exit for itemkey : ' || p_itemkey || ' >>');
    END IF;

  END init_datasub_process;

  PROCEDURE update_amounts(p_itemtype IN VARCHAR2,
                           p_itemkey  IN VARCHAR2,
                           p_actid    IN NUMBER,
                           p_funcmode IN VARCHAR2,
                           p_result   IN OUT NOCOPY VARCHAR2) IS

    l_datasub_info       r_datasub_info;
    l_currency_type_code VARCHAR2(30);
    l_first_ever_loaded  VARCHAR2(1);
    l_cal_period_info    gcs_utility_pkg.r_cal_period_info;

  BEGIN

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.UPDATE_AMOUNTS.begin',
                     '<<Enter for itemkey : ' || p_itemkey || ' >>');
    END IF;

    l_currency_type_code := WF_ENGINE.GetItemAttrText(p_itemtype,
                                                      p_itemkey,
                                                      'CURRENCYTYPE',
                                                      FALSE);
    l_first_ever_loaded  := WF_ENGINE.GetItemAttrText(p_itemtype,
                                                      p_itemkey,
                                                      'FIRSTEVERPERIOD',
                                                      FALSE);

    get_datasub_dtls(p_load_id      => WF_ENGINE.GetItemAttrNumber(p_itemtype,
                                                                   p_itemkey,
                                                                   'LOAD_ID',
                                                                   FALSE),
                     p_datasub_info => l_datasub_info);

    update_amounts_autonomous(p_datasub_info       => l_datasub_info,
                              p_currency_type_code => l_currency_type_code,
                              p_first_ever_loaded  => l_first_ever_loaded);

    IF (l_first_ever_loaded = 'N') THEN
      gcs_utility_pkg.get_cal_period_details(p_cal_period_id     => l_datasub_info.cal_period_id,
                                             p_cal_period_record => l_cal_period_info);

      --Bugfix 4969879: Remove call to get_reference_data_info

      IF (l_datasub_info.amount_type_code = 'PERIOD_ACTIVITY') THEN
        -- Calculate the YTD Amounts Based off of Beginning Balances
        gcs_datasub_utility_pkg.update_ytd_balances(p_load_id            => l_datasub_info.load_id,
                                                    p_source_system_code => l_datasub_info.source_system_code,
                                                    p_dataset_code       => l_datasub_info.dataset_code,
                                                    p_cal_period_id      => l_cal_period_info.prev_cal_period_id,
                                                    p_ledger_id          => l_datasub_info.ledger_id,
                                                    p_currency_type      => l_currency_type_code,
                                                    p_currency_code      => l_datasub_info.currency_code);
      ELSE
        -- Calculate the PTD Amount Based off of Difference of Ending Balances

        IF (l_cal_period_info.cal_period_number <> 1) THEN

          gcs_datasub_utility_pkg.update_ptd_balances(p_load_id            => l_datasub_info.load_id,
                                                      p_source_system_code => l_datasub_info.source_system_code,
                                                      p_dataset_code       => l_datasub_info.dataset_code,
                                                      p_cal_period_id      => l_cal_period_info.prev_cal_period_id,
                                                      p_ledger_id          => l_datasub_info.ledger_id,
                                                      p_currency_type      => l_currency_type_code,
                                                      p_currency_code      => l_datasub_info.currency_code);
        ELSE

          gcs_datasub_utility_pkg.update_ptd_balance_sheet(p_load_id            => l_datasub_info.load_id,
                                                           p_source_system_code => l_datasub_info.source_system_code,
                                                           p_dataset_code       => l_datasub_info.dataset_code,
                                                           p_cal_period_id      => l_cal_period_info.prev_cal_period_id,
                                                           p_ledger_id          => l_datasub_info.ledger_id,
                                                           p_currency_type      => l_currency_type_code,
                                                           p_currency_code      => l_datasub_info.currency_code);
        END IF;

      END IF;

    END IF;

    p_result := 'COMPLETE';

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.UPDATE_AMOUNTS.end',
                     '<<Exit for itemkey : ' || p_itemkey || ' >>');
    END IF;
  END update_amounts;

  PROCEDURE transfer_data_to_interface(p_itemtype IN VARCHAR2,
                                       p_itemkey  IN VARCHAR2,
                                       p_actid    IN NUMBER,
                                       p_funcmode IN VARCHAR2,
                                       p_result   IN OUT NOCOPY VARCHAR2) IS

    l_datasub_info             r_datasub_info;
    l_currency_type_code       VARCHAR2(30);
    l_first_ever_loaded        VARCHAR2(1);
    l_cal_period_info          gcs_utility_pkg.r_cal_period_info;
    l_period_end_date_attr     NUMBER := gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-CAL_PERIOD_END_DATE')
                                        .attribute_id;
    l_period_end_date_version  NUMBER := gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-CAL_PERIOD_END_DATE')
                                        .version_id;
    l_period_num_attr          NUMBER := gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-GL_PERIOD_NUM')
                                        .attribute_id;
    l_period_num_version       NUMBER := gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-GL_PERIOD_NUM')
                                        .version_id;
    l_period_end_date          DATE;
    l_period_num               NUMBER(15);
    l_period_dim_grp_disp_code VARCHAR2(50);
    l_source_system_disp_code  VARCHAR2(50);
    l_load_method_code         VARCHAR2(1);
    l_bal_post_type_code       VARCHAR2(1);
    l_line_item_vs_id          NUMBER;
    l_transfer_status          VARCHAR2(30);

  BEGIN

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.TRANSFER_DATA_TO_INTERFACE.begin',
                     '<<Enter for itemkey : ' || p_itemkey || ' >>');
    END IF;

    l_currency_type_code := WF_ENGINE.GetItemAttrText(p_itemtype,
                                                      p_itemkey,
                                                      'CURRENCYTYPE',
                                                      FALSE);

    get_datasub_dtls(p_load_id      => WF_ENGINE.GetItemAttrNumber(p_itemtype,
                                                                   p_itemkey,
                                                                   'LOAD_ID',
                                                                   FALSE),
                     p_datasub_info => l_datasub_info);

    --Bugfix 4969879: Remove calls to get_reference_data_info

    --Initialize Workflow Attributes for Dataset Code and Object Id
    WF_ENGINE.SetItemAttrText(p_itemtype,
                              p_itemkey,
                              'DATASETCODE',
                              l_datasub_info.dataset_code);
    WF_ENGINE.SetItemAttrText(p_itemtype, p_itemkey, 'XGLOBJECTID', '1000');

    SELECT fdgb.dimension_group_display_code,
           fcpa_end_date.date_assign_value,
           fcpa_period_num.number_assign_value
      INTO l_period_dim_grp_disp_code,
           l_period_end_date,
           l_period_num
      FROM fem_cal_periods_b    fcpb,
           fem_dimension_grps_b fdgb,
           fem_cal_periods_attr fcpa_end_date,
           fem_cal_periods_attr fcpa_period_num
     WHERE fcpb.cal_period_id           = l_datasub_info.cal_period_id
       AND fcpb.dimension_group_id      = fdgb.dimension_group_id
       AND fcpb.cal_period_id           = fcpa_end_date.cal_period_id
       AND fcpa_end_date.attribute_id   = l_period_end_date_attr
       AND fcpa_end_date.version_id     = l_period_end_date_version
       AND fcpb.cal_period_id           = fcpa_period_num.cal_period_id
       AND fcpa_period_num.attribute_id = l_period_num_attr
       AND fcpa_period_num.version_id   = l_period_num_version;

    SELECT source_system_display_code
      INTO l_source_system_disp_code
      FROM fem_source_systems_b
     WHERE source_system_code = l_datasub_info.source_system_code;

    BEGIN
      SELECT 'I'
        INTO l_load_method_code
        FROM fem_data_locations fdl,
             fem_ledgers_attr fla
       WHERE fdl.ledger_id          = l_datasub_info.ledger_id
         AND fdl.cal_period_id      = l_datasub_info.cal_period_id
         AND fdl.dataset_code       = l_datasub_info.dataset_code
         AND fdl.source_system_code = l_datasub_info.source_system_code
         AND rownum < 2;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_load_method_code := 'S';
    END;

    IF (l_datasub_info.load_method_code = 'INITIAL_LOAD') THEN
      l_bal_post_type_code := 'R';
    ELSE
      IF (l_datasub_info.load_method_code = 'INCREMENTAL') THEN
        l_bal_post_type_code := 'A';
      ELSE
        l_bal_post_type_code := 'R';
      END IF;
    END IF;

    SELECT fgvcd.value_set_id
      INTO l_line_item_vs_id
      FROM fem_ledgers_attr fla,
           fem_global_vs_combo_defs fgvcd
     WHERE fla.ledger_id            = l_datasub_info.ledger_id
       AND fgvcd.global_vs_combo_id = fla.dim_attribute_numeric_member
       AND fla.attribute_id         = g_ledger_vs_combo_attr
       AND fla.version_id           = g_ledger_vs_combo_version
       AND fgvcd.dimension_id       = 14;

    transfer_data_autonomous(p_ledger_disp_code        => l_datasub_info.ledger_display_code,
                             p_source_system_disp_code => l_source_system_disp_code,
                             p_dim_grp_disp_code       => l_period_dim_grp_disp_code,
                             p_cal_period_number       => l_period_num,
                             p_cal_period_end_date     => l_period_end_date,
                             p_load_method_code        => l_load_method_code,
                             p_bal_post_type_code      => l_bal_post_type_code,
                             p_currency_type_code      => l_currency_type_code,
                             p_entity_display_code     => l_datasub_info.entity_display_code,
                             p_load_id                 => l_datasub_info.load_id,
                             p_line_item_vs_id         => l_line_item_vs_id,
                             p_ds_balance_type_code    => l_datasub_info.ds_balance_type_code,
                             p_budget_display_code     => l_datasub_info.budget_display_code,
                             p_encumbrance_type_code   => l_datasub_info.encumbrance_type_code,
                             -- Bugfix 5261560: Added p_transfer_status
                             p_transfer_status => l_transfer_status);

    --Bugfix 5261560: Determine whether to continue with the rest of the submission depending on the state of the workflow
    IF (l_transfer_status = 'OK') THEN
      p_result := 'COMPLETE:T';
    ELSE
      p_result := 'COMPLETE:F';
    END IF;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.TRANSFER_DATA_TO_INTERFACE.end',
                     '<<Exit for itemkey : ' || p_itemkey || ' >>');
    END IF;

  END transfer_data_to_interface;

  PROCEDURE update_status(p_load_id IN NUMBER)

   IS

    l_datasub_info r_datasub_info;
    l_status_code  VARCHAR2(1);

  BEGIN

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.UPDATE_STATUS.begin',
                     '<<Enter>>');
    END IF;

    get_datasub_dtls(p_load_id      => p_load_id,
                     p_datasub_info => l_datasub_info);

    SELECT status_code
      INTO l_status_code
      FROM fnd_concurrent_requests
     WHERE request_id = FND_GLOBAL.conc_request_id;

    UPDATE gcs_data_sub_dtls
       SET status_code       = DECODE(l_status_code,
                                      'C',
                                      'COMPLETED',
                                      'E',
                                      'ERROR',
                                      'W',
                                      'WARNING',
                                      'WARNING'),
           end_time          = sysdate,
           last_updated_by   = FND_GLOBAL.USER_ID,
           last_update_login = FND_GLOBAL.LOGIN_ID,
           last_update_date  = sysdate
     WHERE load_id = l_datasub_info.load_id;

    IF (l_status_code <> 'C') THEN
      IF (l_status_code = 'E') THEN
        -- Update the entire set of rows with the same error message
        UPDATE gcs_bal_interface_t
           SET error_message_code = 'Please refer to concurrent request : ' ||
                                    FND_GLOBAL.conc_request_id ||
                                    ' for more details.'
         WHERE load_id = l_datasub_info.load_id;
      ELSE
        -- Update the rows to check FEM_BAL_INTERFACE_T for remaining issues
        UPDATE gcs_bal_interface_t
           SET error_message_code = 'Please refer to FEM_BAL_INTERFACE_T to see if any rows failed.'
         WHERE load_id = l_datasub_info.load_id;
      END IF;
    END IF;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.UPDATE_STATUS.end',
                     '<<Exit>>');
    END IF;

  END update_status;

  PROCEDURE raise_impact_analysis_event(p_load_id   IN NUMBER,
                                        p_ledger_id IN NUMBER)

   IS

    l_event_name     VARCHAR2(100) := 'oracle.apps.gcs.pristinedata.altered';
    l_parameter_list wf_parameter_list_t;

  BEGIN

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.RAISE_IMPACT_ANALYSIS_EVENT.begin',
                     '<<Enter>>');
    END IF;

    wf_event.addparametertolist(p_name          => 'LOAD_ID',
                                p_value         => p_load_id,
                                p_parameterlist => l_parameter_list);

    wf_event.addparametertolist(p_name          => 'LEDGER_ID',
                                p_value         => p_ledger_id,
                                p_parameterlist => l_parameter_list);

    wf_event.raise(p_event_name => l_event_name,
                   p_event_key  => p_load_id,
                   p_parameters => l_parameter_list);

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.RAISE_IMPACT_ANALYSIS_EVENT.end',
                     '<<Exit>>');
    END IF;

  END raise_impact_analysis_event;

  PROCEDURE submit_ogl_datasub(p_load_id    IN NUMBER,
                               p_request_id OUT NOCOPY NUMBER) IS

  BEGIN

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.SUBMIT_OGL_DATASUB.begin',
                     '<<Enter>>');
    END IF;

    p_request_id := fnd_request.submit_request(application => 'GCS',
                                               program     => 'FCH_DATA_SUBMISSION',
                                               sub_request => FALSE,
                                               argument1   => p_load_id);

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.SUBMIT_OGL_DATASUB.end',
                     '<<Exit>>');
    END IF;

  END;

  -- Bug Fix : 5234796, Start
  PROCEDURE validate_member_values(p_itemtype IN VARCHAR2,
                                   p_itemkey  IN VARCHAR2,
                                   p_actid    IN NUMBER,
                                   p_funcmode IN VARCHAR2,
                                   p_result   IN OUT NOCOPY VARCHAR2) IS

    l_datasub_info r_datasub_info;

    TYPE msg_info_rec_type IS RECORD(
      error_msg CLOB);
    TYPE t_msg_info IS TABLE OF msg_info_rec_type;
    l_msg_info t_msg_info;

  BEGIN

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.VALIDATE_MEMBER_VALUES.begin',
                     '<<Enter for itemkey : ' || p_itemkey || ' >>');
    END IF;

    get_datasub_dtls(p_load_id      => WF_ENGINE.GetItemAttrNumber(p_itemtype,
                                                                   p_itemkey,
                                                                   'LOAD_ID',
                                                                   FALSE),
                     p_datasub_info => l_datasub_info);

    gcs_datasub_utility_pkg.validate_dimension_members(p_load_id => l_datasub_info.load_id);

    SELECT error_message_code BULK COLLECT
      INTO l_msg_info
      FROM gcs_bal_interface_t
     WHERE load_id = l_datasub_info.load_id;

    p_result := 'COMPLETE:T';

    IF l_msg_info.FIRST IS NOT NULL THEN
      FOR l_counter in l_msg_info.FIRST .. l_msg_info.LAST LOOP
        IF l_msg_info(l_counter).error_msg IS NOT NULL THEN

          FND_FILE.PUT_LINE(FND_FILE.LOG, '<<<<  Beginning of Error  >>>>');
          FND_FILE.NEW_LINE(FND_FILE.LOG);
          FND_FILE.PUT_LINE(FND_FILE.LOG,
                            'One or more of the dimension members are invalid.Please refer View Data Loaded Report');
          FND_FILE.NEW_LINE(FND_FILE.LOG);
          FND_FILE.PUT_LINE(FND_FILE.LOG, '<<<<      End of Error    >>>>');
          FND_FILE.NEW_LINE(FND_FILE.LOG);

          UPDATE gcs_data_sub_dtls
             SET status_code = 'VALIDATION_MEMBERS_FAILED'
           WHERE load_id = l_datasub_info.load_id;

          p_result := 'COMPLETE:F';
          EXIT;
        END IF;
      END LOOP;
    END IF;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     g_api || '.VALIDATE_MEMBER_VALUES.end',
                     '<<Exit for itemkey : ' || p_itemkey || ' >>');
    END IF;

    COMMIT;

  END validate_member_values;
  -- Bug Fix : 5234796, End

  --
  -- function
  --   populate_ogl_datasub_dtls
  -- Purpose
  --   An API to populate the gcs_dats_sub_dtls.
  --   This API has subscription with the business event "oracle.apps.fem.oglintg.balrule.execute"
  -- Arguments
  --   p_subscription_guid - This subscription GUID is passed when the event is raised
  --   p_event             - wf_event_t param
  -- Notes
  --

  FUNCTION populate_ogl_datasub_dtls(p_subscription_guid in raw,
                                     p_event             in out nocopy wf_event_t)
    RETURN VARCHAR2 IS
    l_parameter_list         wf_parameter_list_t;
    l_bal_rule_version_id    NUMBER;
    l_bal_rule_id            NUMBER;
    l_ledger_id              NUMBER;
    l_ds_bal_type_code       VARCHAR2(30);
    l_cal_period_id          NUMBER;
    l_request_id             NUMBER;
    l_base_request_id        NUMBER;
    l_load_method_code       VARCHAR2(1);
    l_load_method            VARCHAR2(30);
    l_start_date             DATE;
    l_status_code            VARCHAR2(30);
    l_status                 VARCHAR2(30);
    l_user_id                NUMBER;
    l_login_id               NUMBER;
    l_bsv_low                VARCHAR2(150);
    l_bsv_high               VARCHAR2(150);
    l_data_sub_exists_via_ui VARCHAR2(1);
    l_curr_code              VARCHAR2(30);
    l_avg_bal_flag           VARCHAR2(30);
    l_cal_period_end_date    DATE;

    l_global_vs_combo_id     NUMBER(9);
    l_company_vs_id          NUMBER;
    l_org_vs_id              NUMBER;
    l_fch_company_vs_id      NUMBER;
    l_fch_org_vs_id          NUMBER;
    l_hier_obj_definition_id NUMBER(9);

    l_entity_list         DBMS_SQL.NUMBER_TABLE;
    l_xlated_curr_list    DBMS_SQL.VARCHAR2_TABLE;
    l_generated_load_list DBMS_SQL.NUMBER_TABLE;

    l_global_vs_combo_attr    NUMBER := gcs_utility_pkg.g_dimension_attr_info('LEDGER_ID-GLOBAL_VS_COMBO')
                                       .attribute_id;
    l_global_vs_combo_version NUMBER := gcs_utility_pkg.g_dimension_attr_info('LEDGER_ID-GLOBAL_VS_COMBO')
                                       .version_id;
    l_company_attr            NUMBER := gcs_utility_pkg.g_dimension_attr_info('COMPANY_COST_CENTER_ORG_ID-COMPANY')
                                       .attribute_id;
    l_company_version         NUMBER := gcs_utility_pkg.g_dimension_attr_info('COMPANY_COST_CENTER_ORG_ID-COMPANY')
                                       .version_id;
    l_period_end_date_attr    NUMBER := gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-CAL_PERIOD_END_DATE')
                                       .attribute_id;
    l_period_end_date_version NUMBER := gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-CAL_PERIOD_END_DATE')
                                       .version_id;

  BEGIN

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.POPULATE_OGL_DATASUB_DTLS.begin',
                     '<< Enter >>');
    END IF;

    l_parameter_list         := p_event.getParameterList();
    l_bal_rule_version_id    := TO_NUMBER(WF_EVENT.getValueForParameter('BAL_RULE_OBJ_DEF_ID',
                                                                        l_parameter_list));
    l_cal_period_id          := TO_NUMBER(WF_EVENT.getValueForParameter('CAL_PERIOD_ID',
                                                                        l_parameter_list));
    l_request_id             := TO_NUMBER(WF_EVENT.getValueForParameter('REQUEST_ID',
                                                                        l_parameter_list));
    l_base_request_id        := TO_NUMBER(WF_EVENT.getValueForParameter('BASE_REQUEST_ID',
                                                                        l_parameter_list));
    l_load_method_code       := WF_EVENT.getValueForParameter('LOAD_METHOD_CODE',
                                                              l_parameter_list);
    l_bsv_low                := WF_EVENT.getValueForParameter('BSV_RANGE_LOW',
                                                              l_parameter_list);
    l_bsv_high               := WF_EVENT.getValueForParameter('BSV_RANGE_HIGH',
                                                              l_parameter_list);
    l_status_code            := WF_EVENT.getValueForParameter('STATUS_CODE',
                                                              l_parameter_list);
    l_user_id                := FND_GLOBAL.user_id;
    l_login_id               := FND_GLOBAL.login_id;
    l_data_sub_exists_via_ui := 'N';

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.POPULATE_OGL_DATASUB_DTLS',
                     '<< Parameters on event   : Start >>');
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.POPULATE_OGL_DATASUB_DTLS',
                     'Balance  Rule Version Id : ' || l_bal_rule_version_id);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.POPULATE_OGL_DATASUB_DTLS',
                     'Cal Period Id            : ' || l_cal_period_id);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.POPULATE_OGL_DATASUB_DTLS',
                     'Request Id               : ' || l_request_id);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.POPULATE_OGL_DATASUB_DTLS',
                     'Base Request Id          : ' || l_base_request_id);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.POPULATE_OGL_DATASUB_DTLS',
                     'Load Method Code         : ' || l_load_method_code);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.POPULATE_OGL_DATASUB_DTLS',
                     'BSV low                  : ' || l_bsv_low);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.POPULATE_OGL_DATASUB_DTLS',
                     'BSV high                 : ' || l_bsv_high);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.POPULATE_OGL_DATASUB_DTLS',
                     'Status Code              : ' || l_status_code);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.POPULATE_OGL_DATASUB_DTLS',
                     '<< Parameters on event   : End >>');
    END IF;

    -- If the data submission is done via FCH Data Submission UI then, no need to process further.
    BEGIN

      SELECT 'Y'
        INTO l_data_sub_exists_via_ui
        FROM gcs_data_sub_dtls
       WHERE associated_request_id = l_base_request_id
         AND cal_period_id         = l_cal_period_id
         AND ROWNUM < 2;

      IF l_data_sub_exists_via_ui = 'Y' THEN

        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                         g_api || '.POPULATE_OGL_DATASUB_DTLS',
                         '<< Data Load Submitted via UI >>');
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                         g_api || '.POPULATE_OGL_DATASUB_DTLS.end',
                         '<< Exit >>');
        END IF;

        RETURN 'SUCCESS';
      END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN

        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                         g_api || '.POPULATE_OGL_DATASUB_DTLS',
                         '<< Data Load Submitted via Balances Rule Engine >>');
        END IF;

        NULL;
    END;

    --Since we are interested in only "ACTUAL" loads, we dont need to process further for other balance_types
    SELECT fodb.object_id balances_rule_id,
           fibr.ledger_id,
           fibr.ds_bal_type_code,
           gsob.currency_code,
           fibr.include_avg_bal_flag,
           fcpa.date_assign_value
      INTO l_bal_rule_id,
           l_ledger_id,
           l_ds_bal_type_code,
           l_curr_code,
           l_avg_bal_flag,
           l_cal_period_end_date
      FROM fem_intg_bal_rule_defs  fibrd,
           fem_intg_bal_rules      fibr,
           fem_object_definition_b fodb,
           gl_sets_of_books        gsob,
           fem_cal_periods_attr    fcpa
     WHERE gsob.set_of_books_id      = fibr.ledger_id
       AND fibrd.bal_rule_obj_def_id = fodb.object_definition_id
       AND fibr.bal_rule_obj_id      = fodb.object_id
       AND fibrd.bal_rule_obj_def_id = l_bal_rule_version_id
       AND fcpa.cal_period_id        = l_cal_period_id
       AND fcpa.attribute_id         = l_period_end_date_attr
       AND fcpa.version_id           = l_period_end_date_version
       AND fcpa.date_assign_value BETWEEN fodb.effective_start_date AND
           fodb.effective_end_date;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.POPULATE_OGL_DATASUB_DTLS',
                     'Balances Rule Id      : ' || l_bal_rule_id);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.POPULATE_OGL_DATASUB_DTLS',
                     'Ledger Id             : ' || l_ledger_id);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.POPULATE_OGL_DATASUB_DTLS',
                     'Balance Type Code     : ' || l_ds_bal_type_code);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.POPULATE_OGL_DATASUB_DTLS',
                     'Currency Code         : ' || l_curr_code);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.POPULATE_OGL_DATASUB_DTLS',
                     'Cal Period End Date   : ' || l_cal_period_end_date);
    END IF;

    IF l_ds_bal_type_code <> 'ACTUAL' THEN

      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                       g_api || '.POPULATE_OGL_DATASUB_DTLS',
                       '<< Data Load Submitted for other than actuals >>');
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                       g_api || '.POPULATE_OGL_DATASUB_DTLS',
                       '<< Exit >>');
      END IF;

      RETURN 'SUCCESS';

    END IF;

    IF l_load_method_code = 'I' THEN
      l_load_method := 'INCREMENTAL';
    ELSE
      l_load_method := 'SNAPSHOT';
    END IF;

    IF l_status_code = 'NORMAL' THEN
      l_status := 'COMPLETED';
    ELSIF l_status_code = 'WARNING' THEN
      l_status := 'WARNING';
    ELSE
      l_status := 'ERROR';
    END IF;

    SELECT requested_start_date
      INTO l_start_date
      FROM fnd_concurrent_requests
     WHERE request_id = l_base_request_id;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.POPULATE_OGL_DATASUB_DTLS',
                     'Requested Status Date : ' || l_start_date);
    END IF;

    IF (l_load_method_code = 'S' OR
       (l_load_method_code = 'I' AND l_bsv_low IS NULL AND
       l_bsv_high IS NULL)) THEN

      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                       g_api || '.POPULATE_OGL_DATASUB_DTLS',
                       ' Snapshot or Incremtal with no bsv range : << Enter >>');
      END IF;

      -- Bugfix: 5843592, select entity ids

      SELECT gea.entity_id BULK COLLECT
        INTO l_entity_list
        FROM gcs_entities_attr    gea,
             fem_entities_b       feb,
             fem_cal_periods_attr fcpa
       WHERE gea.balances_rule_id   = l_bal_rule_id
         AND gea.source_system_code = 10
         AND gea.data_type_code     = 'ACTUAL'
         AND gea.entity_id          = feb.entity_id
         AND feb.enabled_flag       = 'Y'
         AND fcpa.cal_period_id     = l_cal_period_id
         AND fcpa.attribute_id      = l_period_end_date_attr
         AND fcpa.version_id        = l_period_end_date_version
         AND fcpa.date_assign_value BETWEEN gea.effective_start_date
                                        AND NVL(gea.effective_end_date, fcpa.date_assign_value);

      IF l_entity_list.FIRST IS NOT NULL AND l_entity_list.LAST IS NOT NULL THEN

        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                         g_api || '.POPULATE_OGL_DATASUB_DTLS',
                         ' Updating gcs_data_sub_dtls for ACTUAL');
        END IF;

        FORALL i IN l_entity_list.FIRST .. l_entity_list.LAST
          UPDATE gcs_data_sub_dtls
             SET most_recent_flag  = 'N'
           WHERE most_recent_flag  = 'Y'
             AND cal_period_id     = l_cal_period_id
             AND balance_type_code = 'ACTUAL'
             AND entity_id         = l_entity_list(i);

        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                         g_api || '.POPULATE_OGL_DATASUB_DTLS',
                         ' Inserting into gcs_data_sub_dtls for ACTUAL');
        END IF;

        FORALL i IN l_entity_list.FIRST .. l_entity_list.LAST
          INSERT INTO gcs_data_sub_dtls
            (load_id,
             load_name,
             entity_id,
             cal_period_id,
             currency_code,
             balance_type_code,
             load_method_code,
             currency_type_code,
             amount_type_code,
             measure_type_code,
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
             locked_flag,
             most_recent_flag,
             associated_request_id,
             status_code,
             balances_rule_id)
          VALUES
            (gcs_data_sub_dtls_s.nextval,
             gcs_data_sub_dtls_s.nextval,
             l_entity_list(i),
             l_cal_period_id,
             l_curr_code,
             'ACTUAL',
             l_load_method,
             'BASE_CURRENCY',
             'ENDING_BALANCE',
             'BALANCE',
             'N',
             NULL,
             sysdate,
             l_user_id,
             sysdate,
             l_user_id,
             l_login_id,
             1,
             l_start_date,
             sysdate,
             'N',
             'Y',
             l_base_request_id,
             l_status,
             l_bal_rule_id);
      ELSE

        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                         g_api || '.POPULATE_OGL_DATASUB_DTLS',
                         '<< No Entities found for update/insert >>');
        END IF;

      END IF;

      IF l_avg_bal_flag = 'Y' THEN
        IF l_entity_list.FIRST IS NOT NULL AND
           l_entity_list.LAST IS NOT NULL THEN

          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                           g_api || '.POPULATE_OGL_DATASUB_DTLS',
                           ' Updating gcs_data_sub_dtls for ADB');
          END IF;

          FORALL i IN l_entity_list.FIRST .. l_entity_list.LAST
            UPDATE gcs_data_sub_dtls
               SET most_recent_flag  = 'N'
             WHERE most_recent_flag  = 'Y'
               AND cal_period_id     = l_cal_period_id
               AND balance_type_code = 'ADB'
               AND entity_id         = l_entity_list(i);

          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                           g_api || '.POPULATE_OGL_DATASUB_DTLS',
                           ' Inserting into gcs_data_sub_dtls for ADB');
          END IF;

          FORALL i IN l_entity_list.FIRST .. l_entity_list.LAST
            INSERT INTO gcs_data_sub_dtls
              (load_id,
               load_name,
               entity_id,
               cal_period_id,
               currency_code,
               balance_type_code,
               load_method_code,
               currency_type_code,
               amount_type_code,
               measure_type_code,
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
               locked_flag,
               most_recent_flag,
               associated_request_id,
               status_code,
               balances_rule_id)
            VALUES
              (gcs_data_sub_dtls_s.nextval,
               gcs_data_sub_dtls_s.nextval,
               l_entity_list(i),
               l_cal_period_id,
               l_curr_code,
               'ADB',
               l_load_method,
               'BASE_CURRENCY',
               'ENDING_BALANCE',
               'BALANCE',
               'N',
               NULL,
               sysdate,
               l_user_id,
               sysdate,
               l_user_id,
               l_login_id,
               1,
               l_start_date,
               sysdate,
               'N',
               'Y',
               l_base_request_id,
               l_status,
               l_bal_rule_id);
        ELSE

          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                           g_api || '.POPULATE_OGL_DATASUB_DTLS',
                           '<< No Entities found for update/insert >>');
          END IF;

        END IF;
      END IF;

      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                       g_api || '.POPULATE_OGL_DATASUB_DTLS',
                       ' Snapshot or Incremtal with no bsv range : << Exit >>');
      END IF;

    ELSE

      --Incremental case code goes here
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                       g_api || '.POPULATE_OGL_DATASUB_DTLS',
                       ' Incremtal with bsv range : << Enter >>');
      END IF;

      --Check if chart of accounts mapping is required
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                       g_api || '.POPULATE_OGL_DATASUB_DTLS',
                       ' Check if chart of accounts mapping is required');
      END IF;

      BEGIN
        SELECT fla.dim_attribute_numeric_member,
               fgvcd_local_company.value_set_id,
               fgvcd_local_org.value_set_id
          INTO l_global_vs_combo_id,
               l_company_vs_id,
               l_org_vs_id
          FROM fem_ledgers_attr         fla,
               fem_global_vs_combo_defs fgvcd_local_company,
               fem_global_vs_combo_defs fgvcd_local_org
         WHERE fla.ledger_id    = l_ledger_id
           AND fla.attribute_id = l_global_vs_combo_attr
           AND fla.version_id   = l_global_vs_combo_version
           AND fla.dim_attribute_numeric_member =
               fgvcd_local_company.global_vs_combo_id
           AND fgvcd_local_company.dimension_id = 112
           AND fla.dim_attribute_numeric_member =
               fgvcd_local_org.global_vs_combo_id
           AND fgvcd_local_org.dimension_id = 8;

        SELECT fgvcd_fch_company.value_set_id,
               fgvcd_fch_org.value_set_id
          INTO l_fch_company_vs_id,
               l_fch_org_vs_id
          FROM fem_global_vs_combo_defs fgvcd_fch_company,
               fem_global_vs_combo_defs fgvcd_fch_org,
               gcs_system_options       gso
         WHERE fgvcd_fch_company.global_vs_combo_id =
               gso.fch_global_vs_combo_id
           AND fgvcd_fch_org.global_vs_combo_id =
               fgvcd_fch_company.global_vs_combo_id
           AND fgvcd_fch_org.dimension_id = 8
           AND fgvcd_fch_company.dimension_id = 112;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                           g_api || '.POPULATE_OGL_DATASUB_DTLS',
                           '<< No Data Found while finding out Master and Local value sets >>');
          END IF;
          NULL;
      END;

      IF (l_fch_org_vs_id <> l_org_vs_id) THEN

        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                         g_api || '.POPULATE_OGL_DATASUB_DTLS',
                         ' Chart of Accounts mapping is reuqired');
        END IF;

        BEGIN
          SELECT fodb.object_definition_id
            INTO l_hier_obj_definition_id
            FROM fem_xdim_dimensions fxd,
                 fem_object_definition_b fodb
           WHERE fxd.dimension_id = 8
             AND fxd.default_mvs_hierarchy_obj_id = fodb.object_id
             AND l_cal_period_end_date BETWEEN fodb.effective_start_date AND
                 fodb.effective_end_date;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             g_api || '.POPULATE_OGL_DATASUB_DTLS',
                             '<< No Data Found while finding out hierarchy object def Id In case of COA map required >>');
            END IF;
            NULL;
        END;

        -- Bugfix 5843592

        SELECT DISTINCT geco.entity_id BULK COLLECT
          INTO l_entity_list
          FROM fem_companies_b      f,
               fem_cctr_orgs_hier   fcoh,
               fem_cctr_orgs_attr   fcoa,
               gcs_entity_cctr_orgs geco,
               gcs_entities_attr    gea,
               fem_entities_b       feb,
               fem_cal_periods_attr fcpa
         WHERE feb.entity_id = gea.entity_id
           AND geco.entity_id = gea.entity_id
           AND geco.company_cost_center_org_id   = fcoa.company_cost_center_org_id
           AND fcoh.hierarchy_obj_def_id         = l_hier_obj_definition_id
           AND fcoh.parent_value_set_id          = l_fch_company_vs_id
           AND fcoh.child_value_set_id           = l_company_vs_id
           AND fcoh.child_id                     = fcoa.company_cost_center_org_id
           AND fcoh.child_value_set_id           = fcoa.value_set_id
           AND fcoa.attribute_id                 = l_company_attr
           AND fcoa.version_id                   = l_company_version
           AND fcoa.dim_attribute_numeric_member = f.company_id
           AND fcoa.value_set_id                 = f.value_set_id
           AND gea.balances_rule_id              = l_bal_rule_id
           AND gea.source_system_code            = 10
           AND gea.data_type_code                = 'ACTUAL'
           AND fcpa.cal_period_id                = l_cal_period_id
           AND fcpa.attribute_id                 = l_period_end_date_attr
           AND fcpa.version_id                   = l_period_end_date_version
           AND fcpa.date_assign_value BETWEEN gea.effective_start_date
                                          AND NVL(gea.effective_end_date, fcpa.date_assign_value)
           AND feb.enabled_flag                  = 'Y'
           AND f.company_display_code      BETWEEN l_bsv_low AND l_bsv_high;

      ELSE

        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                         g_api || '.POPULATE_OGL_DATASUB_DTLS',
                         ' Chart of Accounts mapping is not reuqired');
        END IF;

        SELECT DISTINCT geo.entity_id BULK COLLECT
          INTO l_entity_list
          FROM fem_companies_b          fcb,
               gcs_entity_organizations geo,
               gcs_entities_attr        gea,
               fem_entities_b           feb
         WHERE feb.entity_id                  = gea.entity_id
           AND geo.entity_id                  = gea.entity_id
           AND feb.enabled_flag               = 'Y'
           AND gea.balances_rule_id           = l_bal_rule_id
           AND gea.source_system_code         = 10
           AND gea.data_type_code             = 'ACTUAL'
           AND geo.company_cost_center_org_id = fcb.company_id
           AND fcb.value_set_id               = l_company_vs_id
           AND fcb.company_display_code BETWEEN l_bsv_low AND l_bsv_high;

      END IF;

      IF l_entity_list.FIRST IS NOT NULL AND l_entity_list.LAST IS NOT NULL THEN

        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                         g_api || '.POPULATE_OGL_DATASUB_DTLS',
                         ' Updating gcs_data_sub_dtls for ACTUAL');
        END IF;

        FORALL i IN l_entity_list.FIRST .. l_entity_list.LAST
          UPDATE gcs_data_sub_dtls
             SET most_recent_flag = 'N'
           WHERE most_recent_flag = 'Y'
             AND cal_period_id = l_cal_period_id
             AND balance_type_code = 'ACTUAL'
             AND entity_id = l_entity_list(i);

        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                         g_api || '.POPULATE_OGL_DATASUB_DTLS',
                         ' Inserting gcs_data_sub_dtls for ACTUAL');
        END IF;

        FORALL i IN l_entity_list.FIRST .. l_entity_list.LAST
          INSERT INTO gcs_data_sub_dtls
            (load_id,
             load_name,
             entity_id,
             cal_period_id,
             currency_code,
             balance_type_code,
             load_method_code,
             currency_type_code,
             amount_type_code,
             measure_type_code,
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
             locked_flag,
             most_recent_flag,
             associated_request_id,
             status_code,
             balances_rule_id)
          VALUES
            (gcs_data_sub_dtls_s.nextval,
             gcs_data_sub_dtls_s.nextval,
             l_entity_list(i),
             l_cal_period_id,
             l_curr_code,
             'ACTUAL',
             l_load_method,
             'BASE_CURRENCY',
             'ENDING_BALANCE',
             'BALANCE',
             'N',
             NULL,
             sysdate,
             l_user_id,
             sysdate,
             l_user_id,
             l_login_id,
             1,
             l_start_date,
             sysdate,
             'N',
             'Y',
             l_base_request_id,
             l_status,
             l_bal_rule_id);
      ELSE

        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                         g_api || '.POPULATE_OGL_DATASUB_DTLS',
                         '<< No entities found for update/insert >>');
        END IF;

      END IF;

      IF l_avg_bal_flag = 'Y' THEN
        IF l_entity_list.FIRST IS NOT NULL AND
           l_entity_list.LAST IS NOT NULL THEN

          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                           g_api || '.POPULATE_OGL_DATASUB_DTLS',
                           ' Updating gcs_data_sub_dtls for ADB');
          END IF;

          FORALL i IN l_entity_list.FIRST .. l_entity_list.LAST
            UPDATE gcs_data_sub_dtls
               SET most_recent_flag  = 'N'
             WHERE most_recent_flag  = 'Y'
               AND cal_period_id     = l_cal_period_id
               AND balance_type_code = 'ADB'
               AND entity_id         = l_entity_list(i);

          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                           g_api || '.POPULATE_OGL_DATASUB_DTLS',
                           ' Inserting into gcs_data_sub_dtls for ADB');
          END IF;

          FORALL i IN l_entity_list.FIRST .. l_entity_list.LAST
            INSERT INTO gcs_data_sub_dtls
              (load_id,
               load_name,
               entity_id,
               cal_period_id,
               currency_code,
               balance_type_code,
               load_method_code,
               currency_type_code,
               amount_type_code,
               measure_type_code,
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
               locked_flag,
               most_recent_flag,
               associated_request_id,
               status_code,
               balances_rule_id)
            VALUES
              (gcs_data_sub_dtls_s.nextval,
               gcs_data_sub_dtls_s.nextval,
               l_entity_list(i),
               l_cal_period_id,
               l_curr_code,
               'ADB',
               l_load_method,
               'BASE_CURRENCY',
               'ENDING_BALANCE',
               'BALANCE',
               'N',
               NULL,
               sysdate,
               l_user_id,
               sysdate,
               l_user_id,
               l_login_id,
               1,
               l_start_date,
               sysdate,
               'N',
               'Y',
               l_base_request_id,
               l_status,
               l_bal_rule_id);
        ELSE

          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                           g_api || '.POPULATE_OGL_DATASUB_DTLS',
                           '<< No entities found for update/insert >>');
          END IF;

        END IF;

      END IF;

      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                       g_api || '.POPULATE_OGL_DATASUB_DTLS',
                       ' Incremtal with bsv range : << Exit >>');
      END IF;

    END IF;

    COMMIT;

    --Handle Translated balances
    SELECT DISTINCT translated_currency BULK COLLECT
      INTO l_xlated_curr_list
      FROM fem_dl_trans_curr
     WHERE request_id   >= l_base_request_id
       AND object_id     = l_bal_rule_id
       AND ledger_id     = l_ledger_id
       AND cal_period_id = l_cal_period_id;

    IF l_xlated_curr_list.FIRST IS NOT NULL AND
       l_xlated_curr_list.LAST IS NOT NULL THEN

      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                       g_api || '.POPULATE_OGL_DATASUB_DTLS',
                       '<< Processing Translated Currencies >>');
      END IF;

      FORALL i IN l_xlated_curr_list.FIRST .. l_xlated_curr_list.LAST
        INSERT INTO gcs_data_sub_dtls
          (load_id,
           load_name,
           entity_id,
           cal_period_id,
           currency_code,
           balance_type_code,
           load_method_code,
           currency_type_code,
           amount_type_code,
           measure_type_code,
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
           locked_flag,
           most_recent_flag,
           associated_request_id,
           status_code,
           balances_rule_id)
          SELECT gcs_data_sub_dtls_s.nextval,
                 gcs_data_sub_dtls_s.nextval,
                 gdsd.entity_id,
                 gdsd.cal_period_id,
                 l_xlated_curr_list(i),
                 gdsd.balance_type_code,
                 gdsd.load_method_code,
                 gdsd.currency_type_code,
                 gdsd.amount_type_code,
                 gdsd.measure_type_code,
                 gdsd.notify_options_code,
                 gdsd.notification_text,
                 sysdate,
                 l_user_id,
                 sysdate,
                 l_user_id,
                 l_login_id,
                 1,
                 gdsd.start_time,
                 sysdate,
                 gdsd.locked_flag,
                 gdsd.most_recent_flag,
                 gdsd.associated_request_id,
                 gdsd.status_code,
                 gdsd.balances_rule_id
            FROM gcs_data_sub_dtls gdsd
           WHERE gdsd.associated_request_id = l_base_request_id
             AND gdsd.cal_period_id         = l_cal_period_id;
    ELSE

      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                       g_api || '.POPULATE_OGL_DATASUB_DTLS',
                       '<< No Translated Currencies found >>');
      END IF;

    END IF;

    COMMIT;

    SELECT gdsd.load_id BULK COLLECT
      INTO l_generated_load_list
      FROM gcs_data_sub_dtls gdsd
     WHERE gdsd.associated_request_id = l_base_request_id
       AND gdsd.cal_period_id = l_cal_period_id;

    IF l_generated_load_list.FIRST IS NOT NULL AND
       l_generated_load_list.LAST IS NOT NULL THEN

      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                       g_api || '.POPULATE_OGL_DATASUB_DTLS',
                       '<< Raising IA Event, Updating the status, XML WRiter program >>');
      END IF;

      FOR k IN l_generated_load_list.FIRST .. l_generated_load_list.LAST LOOP

        -- Raising the impact analysis and updating the data status should only be done if the request completed successfully

        IF (l_status = 'COMPLETED') THEN
          raise_impact_analysis_event(p_load_id   => l_generated_load_list(k),
                                      p_ledger_id => l_ledger_id);

          -- Bugfix 5676634: Submit request for data status update instead of API call

          --gcs_cons_monitor_pkg.update_data_status(p_load_id          => l_generated_load_list(k),
          --                                        p_cons_rel_id      => null,
          --                                        p_hierarchy_id     => null,
          --                                        p_transaction_type => null);
          l_request_id := fnd_request.submit_request(application => 'GCS',
                                                     program     => 'FCH_UPDATE_DATA_STATUS',
                                                     sub_request => FALSE,
                                                     argument1   => l_generated_load_list(k),
                                                     argument2   => NULL,
                                                     argument3   => NULL,
                                                     argument4   => NULL);

          l_request_id := fnd_request.submit_request(application => 'GCS',
                                                     program     => 'FCH_XML_WRITER',
                                                     sub_request => FALSE,
                                                     argument1   => 'DATASUBMISSION',
                                                     argument2   => NULL,
                                                     argument3   => NULL,
                                                     argument4   => l_generated_load_list(k));
        END IF;

      END LOOP;

    ELSE

      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                       g_api || '.POPULATE_OGL_DATASUB_DTLS',
                       '<< No generated loads found >>');
      END IF;

    END IF;

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.POPULATE_OGL_DATASUB_DTLS.end',
                     '<< Exit >>');
    END IF;
    RETURN 'SUCCESS';

  EXCEPTION
    WHEN NO_DATA_FOUND THEN

      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                       g_api || '.POPULATE_OGL_DATASUB_DTLS',
                       '<< No Data Found >>');
      END IF;

      RETURN 'ERROR';

    WHEN OTHERS THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                       g_api || '.POPULATE_OGL_DATASUB_DTLS',
                       SQLERRM);
      END IF;

      RETURN 'ERROR';
  END populate_ogl_datasub_dtls;

  --
  -- function
  --   handle_undo_event
  -- Purpose
  --   An API to handle the UNDO Event submitted via EPF.
  --   This API has subscription with the business event "oracle.apps.fem.ud.complete"
  -- Arguments
  --   p_subscription_guid - This subscription GUID is passed when the event is raised
  --   p_event             - wf_event_t param
  -- Notes
  -- Bug Fix : 5647099
  FUNCTION handle_undo_event(p_subscription_guid IN RAW,
                             p_event             IN OUT NOCOPY wf_event_t)
    RETURN VARCHAR2 IS
    l_parameter_list       wf_parameter_list_t;
    l_undo_request_id      NUMBER;
    l_dataset_code         NUMBER;
    l_cal_period_id        NUMBER;
    l_ledger_id            NUMBER;
    l_srcsys_code          NUMBER;
    l_status_code          VARCHAR2(30);
    l_data_type_code       VARCHAR2(30);
    l_actual_ds_code       VARCHAR2(30);
    -- Bugfix 5676634
    l_request_id           NUMBER;

    -- Bugfix 5664023 :Start
    --l_load_list DBMS_SQL.NUMBER_TABLE;

    TYPE load_rec_type IS RECORD(load_id NUMBER,
                                 most_recent_flag VARCHAR2(1));
    TYPE t_load_info IS TABLE OF load_rec_type;
    l_load_list t_load_info;
    -- Bugfix 5664023 :End

    -- Bug Fix: 5843592, Get the attribute id and version id of the CAL_PERIOD_END_DATE of calendar period

    l_period_end_date_attr        NUMBER := gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-CAL_PERIOD_END_DATE')
                                            .attribute_id;
    l_period_end_date_version     NUMBER := gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-CAL_PERIOD_END_DATE')
                                            .version_id;


  BEGIN

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.HANDLE_UNDO_EVENT.begin',
                     '<< Enter >>');
    END IF;

    l_parameter_list       := p_event.getParameterList();
    l_undo_request_id      := TO_NUMBER(WF_EVENT.getValueForParameter('UNDO_REQUEST_ID',
                                                                      l_parameter_list));
    l_dataset_code         := TO_NUMBER(WF_EVENT.getValueForParameter('DATASET_CODE',
                                                                      l_parameter_list));
    l_cal_period_id        := TO_NUMBER(WF_EVENT.getValueForParameter('CAL_PERIOD_ID',
                                                                      l_parameter_list));
    l_ledger_id            := TO_NUMBER(WF_EVENT.getValueForParameter('LEDGER_ID',
                                                                      l_parameter_list));
    l_status_code          := WF_EVENT.getValueForParameter('STATUS',
                                                            l_parameter_list);

    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.HANDLE_UNDO_EVENT',
                     '<< Parameters on event   : Start >>');
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.HANDLE_UNDO_EVENT',
                     'Undo Request Id          : ' || l_undo_request_id);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.HANDLE_UNDO_EVENT',
                     'Dataset Code             : ' || l_dataset_code);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.HANDLE_UNDO_EVENT',
                     'Cal Period Id            : ' || l_cal_period_id);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.HANDLE_UNDO_EVENT',
                     'Ledger Id                : ' || l_ledger_id);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.HANDLE_UNDO_EVENT',
                     'Source System Code       : ' || l_srcsys_code);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.HANDLE_UNDO_EVENT',
                     'Status Code              : ' || l_status_code);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                     g_api || '.HANDLE_UNDO_EVENT',
                     '<< Parameters on event   : End >>');
    END IF;

    IF (l_status_code = 'S') THEN

        -- first check whether there exists rows in gcs_data_type_codes_b with given dataset
        -- because if it is not then we do not care.

        BEGIN
          SELECT data_type_code
            INTO l_data_type_code
            FROM gcs_data_type_codes_b
           WHERE source_dataset_code = l_dataset_code
             AND rownum < 2;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             g_api || '.HANDLE_UNDO_EVENT',
                             '<< No Data Type exists with the provided data set code >>');
            END IF;
            RETURN 'SUCCESS';
        END;

        -- Check if the datasetcode is same as the source_dataset_code of ACTUAL/ADB
        -- then we need to UNDONE both the ACTUAL/ADB loads for the given ledger/calPeriod
        -- else UNDO only the loads with ledger/calPeriod/dataTypeCode

        BEGIN
          SELECT source_dataset_code
            INTO l_actual_ds_code
            FROM gcs_data_type_codes_b
           WHERE data_type_code = 'ACTUAL';

        -- Bugfix 5843592, Get the correct entity, depending upon the calendar period

         IF (l_actual_ds_code = l_dataset_code) THEN

              SELECT gdsd.load_id,
                     gdsd.most_recent_flag
                BULK COLLECT INTO l_load_list
                FROM gcs_entities_attr    gea,
                     gcs_data_sub_dtls    gdsd,
                     fem_cal_periods_attr fcpa
               WHERE gea.ledger_id          = l_ledger_id
                 AND gdsd.cal_period_id     = l_cal_period_id
                 AND gdsd.balance_type_code IN ('ACTUAL', 'ADB')
                 AND gdsd.balance_type_code = gea.data_type_code
                 AND gdsd.entity_id         = gea.entity_id
                 AND fcpa.cal_period_id     = gdsd.cal_period_id
                 AND fcpa.attribute_id      = l_period_end_date_attr
                 AND fcpa.version_id        = l_period_end_date_version
                 AND fcpa.date_assign_value BETWEEN gea.effective_start_date
	                                        AND NVL(gea.effective_end_date, fcpa.date_assign_value ) ;

          ELSE

              SELECT gdsd.load_id,
                     gdsd.most_recent_flag
                BULK COLLECT INTO l_load_list
                FROM gcs_entities_attr gea,
                     gcs_data_sub_dtls gdsd,
                     fem_cal_periods_attr fcpa
               WHERE gea.ledger_id          = l_ledger_id
                 AND gdsd.cal_period_id     = l_cal_period_id
                 AND gdsd.balance_type_code = l_data_type_code
                 AND gdsd.balance_type_code = gea.data_type_code
                 AND gdsd.entity_id         = gea.entity_id
                 AND fcpa.cal_period_id     = gdsd.cal_period_id
                 AND fcpa.attribute_id      = l_period_end_date_attr
                 AND fcpa.version_id        = l_period_end_date_version
                 AND fcpa.date_assign_value BETWEEN gea.effective_start_date
	                                        AND NVL(gea.effective_end_date, fcpa.date_assign_value ) ;


          END IF;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             g_api || '.HANDLE_UNDO_EVENT',
                             '<< Source_dataset_code for ACTUAL is NULL in gcs_data_type_codes_b >>');
            END IF;
            RETURN 'SUCCESS';
        END;


        IF l_load_list.FIRST IS NOT NULL AND l_load_list.LAST IS NOT NULL THEN

            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             g_api || '.HANDLE_UNDO_EVENT',
                             '<< Update gcs_data_sub_dtls status and >>');
            END IF;
            -- Bugfix 5664023 :Start
            FOR k IN l_load_list.FIRST .. l_load_list.LAST LOOP

                UPDATE gcs_data_sub_dtls
                   SET status_code = 'UNDONE'
                 WHERE load_id     = l_load_list(k).load_id;

              IF (l_load_list(k).most_recent_flag = 'Y') THEN
              -- Raising the impact analysis and updating the data status should be done.
                raise_impact_analysis_event(p_load_id   => l_load_list(k).load_id,
                                            p_ledger_id => l_ledger_id);

                -- Bugfix 5676634: Submit request for data status update instead of API call
                -- issuing a commit prior to request submission to ensure information is going
                --to be available to the concurrent program which will run in different context/session

                --gcs_cons_monitor_pkg.update_data_status(p_load_id          => l_load_list(k).load_id,
                --                                        p_cons_rel_id      => null,
                --                                        p_hierarchy_id     => null,
                --                                        p_transaction_type => null);
                COMMIT;
                l_request_id := fnd_request.submit_request(application => 'GCS',
                                                           program     => 'FCH_UPDATE_DATA_STATUS',
                                                           sub_request => FALSE,
                                                           argument1   => l_load_list(k).load_id,
                                                           argument2   => NULL,
                                                           argument3   => NULL,
                                                           argument4   => NULL);
              END IF;
            END LOOP;
            -- Bugfix 5664023 :End

        ELSE

          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                           g_api || '.HANDLE_UNDO_EVENT',
                           '<< No loads found >>');
          END IF;

        END IF;

        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                         g_api || '.HANDLE_UNDO_EVENT.end',
                         '<< Exit >>');
        END IF;
        RETURN 'SUCCESS';

    ELSE

          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                           g_api || '.HANDLE_UNDO_EVENT',
                           '<< UNDO event is not successful >>');
          END IF;
          RETURN 'SUCCESS';

    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN

      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                       g_api || '.HANDLE_UNDO_EVENT',
                       '<< No Data Found >>');
      END IF;

      RETURN 'ERROR';

    WHEN OTHERS THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                       g_api || '.HANDLE_UNDO_EVENT',
                       SQLERRM);
      END IF;

      RETURN 'ERROR';

  END handle_undo_event;
END gcs_datasub_wf_pkg;

/
