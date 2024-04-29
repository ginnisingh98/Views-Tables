--------------------------------------------------------
--  DDL for Package Body ZX_TRL_DETAIL_OVERRIDE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_TRL_DETAIL_OVERRIDE_PKG" AS
/* $Header: zxriovrdetlnpkgb.pls 120.62.12010000.18 2010/08/27 06:21:09 prigovin ship $ */

  g_current_runtime_level           NUMBER;
  g_level_statement       CONSTANT  NUMBER := FND_LOG.LEVEL_STATEMENT;
  g_level_procedure       CONSTANT  NUMBER := FND_LOG.LEVEL_PROCEDURE;
  g_level_event           CONSTANT  NUMBER := FND_LOG.LEVEL_EVENT;
  g_level_unexpected      CONSTANT  NUMBER := FND_LOG.LEVEL_UNEXPECTED;

 DATE_DUMMY   CONSTANT DATE           := TO_DATE('01-01-1951', 'DD-MM-YYYY');

  PROCEDURE Insert_Row
       (X_Rowid                      IN OUT NOCOPY VARCHAR2,
        p_tax_line_id                              NUMBER,
        p_internal_organization_id                 NUMBER,
        p_application_id                           NUMBER,
        p_entity_code                              VARCHAR2,
        p_event_class_code                         VARCHAR2,
        p_event_type_code                          VARCHAR2,
        p_trx_id                                   NUMBER,
        p_trx_line_id                              NUMBER,
        p_trx_level_type                           VARCHAR2,
        p_trx_line_number                          NUMBER,
        p_doc_event_status                         VARCHAR2,
        p_tax_event_class_code                     VARCHAR2,
        p_tax_event_type_code                      VARCHAR2,
        p_tax_line_number                          NUMBER,
        p_content_owner_id                         NUMBER,
        p_tax_regime_id                            NUMBER,
        p_tax_regime_code                          VARCHAR2,
        p_tax_id                                   NUMBER,
        p_tax                                      VARCHAR2,
        p_tax_status_id                            NUMBER,
        p_tax_status_code                          VARCHAR2,
        p_tax_rate_id                              NUMBER,
        p_tax_rate_code                            VARCHAR2,
        p_tax_rate                                 NUMBER,
        p_tax_rate_type                            VARCHAR2,
        p_tax_apportionment_line_num               NUMBER,--reduced in size tax_apportionment_line_number
        p_trx_id_level2                            NUMBER,
        p_trx_id_level3                            NUMBER,
        p_trx_id_level4                            NUMBER,
        p_trx_id_level5                            NUMBER,
        p_trx_id_level6                            NUMBER,
        p_trx_user_key_level1                      VARCHAR2,
        p_trx_user_key_level2                      VARCHAR2,
        p_trx_user_key_level3                      VARCHAR2,
        p_trx_user_key_level4                      VARCHAR2,
        p_trx_user_key_level5                      VARCHAR2,
        p_trx_user_key_level6                      VARCHAR2,
        p_mrc_tax_line_flag                        VARCHAR2,
        p_mrc_link_to_tax_line_id                  NUMBER,
        p_ledger_id                                NUMBER,
        p_establishment_id                         NUMBER,
        p_legal_entity_id                          NUMBER,
        p_hq_estb_reg_number                       VARCHAR2,
        p_hq_estb_party_tax_prof_id                NUMBER,
        p_currency_conversion_date                 DATE,
        p_currency_conversion_type                 VARCHAR2,
        p_currency_conversion_rate                 NUMBER,
        p_tax_curr_conversion_date                 DATE,--reduced in size tax_currency_conversion_date
        p_tax_curr_conversion_type                 VARCHAR2,--reduced in size p_tax_currency_conversion_type
        p_tax_curr_conversion_rate                 NUMBER,--reduced in size p_tax_currency_conversion_rate
        p_trx_currency_code                        VARCHAR2,
        p_reporting_currency_code                  VARCHAR2,
        p_minimum_accountable_unit                 NUMBER,
        p_precision                                NUMBER,
        p_trx_number                               VARCHAR2,
        p_trx_date                                 DATE,
        p_unit_price                               NUMBER,
        p_line_amt                                 NUMBER,
        p_trx_line_quantity                        NUMBER,
        p_tax_base_modifier_rate                   NUMBER,
        p_ref_doc_application_id                   NUMBER,
        p_ref_doc_entity_code                      VARCHAR2,
        p_ref_doc_event_class_code                 VARCHAR2,
        p_ref_doc_trx_id                           NUMBER,
        p_ref_doc_trx_level_type                   VARCHAR2,
        p_ref_doc_line_id                          NUMBER,
        p_ref_doc_line_quantity                    NUMBER,
        p_other_doc_line_amt                       NUMBER,
        p_other_doc_line_tax_amt                   NUMBER,
        p_other_doc_line_taxable_amt               NUMBER,
        p_unrounded_taxable_amt                    NUMBER,
        p_unrounded_tax_amt                        NUMBER,
        p_related_doc_application_id               NUMBER,
        p_related_doc_entity_code                  VARCHAR2,
        p_related_doc_evt_class_code               VARCHAR2,--reduced in size p_related_doc_event_class_code
        p_related_doc_trx_id                       NUMBER,
        p_related_doc_trx_level_type               VARCHAR2,
        p_related_doc_number                       VARCHAR2,
        p_related_doc_date                         DATE,
        p_applied_from_appl_id                     NUMBER,--reduced in size p_applied_from_application_id
        p_applied_from_evt_clss_code               VARCHAR2,--reduced in size p_applied_from_event_class_code
        p_applied_from_entity_code                 VARCHAR2,
        p_applied_from_trx_id                      NUMBER,
        p_applied_from_trx_level_type              VARCHAR2,
        p_applied_from_line_id                     NUMBER,
        p_applied_from_trx_number                  VARCHAR2,
        p_adjusted_doc_appln_id                    NUMBER,--reduced in size p_adjusted_doc_application_id
        p_adjusted_doc_entity_code                 VARCHAR2,
        p_adjusted_doc_evt_clss_code               VARCHAR2,--reduced in size p_adjusted_doc_event_class_code
        p_adjusted_doc_trx_id                      NUMBER,
        p_adjusted_doc_trx_level_type              VARCHAR2,
        p_adjusted_doc_line_id                     NUMBER,
        p_adjusted_doc_number                      VARCHAR2,
        p_adjusted_doc_date                        DATE,
        p_applied_to_application_id                NUMBER,
        p_applied_to_evt_class_code                VARCHAR2,--reduced in size p_applied_to_event_class_code
        p_applied_to_entity_code                   VARCHAR2,
        p_applied_to_trx_id                        NUMBER,
        p_applied_to_trx_level_type                VARCHAR2,
        p_applied_to_line_id                       NUMBER,
        p_summary_tax_line_id                      NUMBER,
        p_offset_link_to_tax_line_id               NUMBER,
        p_offset_flag                              VARCHAR2,
        p_process_for_recovery_flag                VARCHAR2,
        p_tax_jurisdiction_id                      NUMBER,
        p_tax_jurisdiction_code                    VARCHAR2,
        p_place_of_supply                          NUMBER,
        p_place_of_supply_type_code                VARCHAR2,
        p_place_of_supply_result_id                NUMBER,
        p_tax_date_rule_id                         NUMBER,
        p_tax_date                                 DATE,
        p_tax_determine_date                       DATE,
        p_tax_point_date                           DATE,
        p_trx_line_date                            DATE,
        p_tax_type_code                            VARCHAR2,
        p_tax_code                                 VARCHAR2,
        p_tax_registration_id                      NUMBER,
        p_tax_registration_number                  VARCHAR2,
        p_registration_party_type                  VARCHAR2,
        p_rounding_level_code                      VARCHAR2,
        p_rounding_rule_code                       VARCHAR2,
        p_rndg_lvl_party_tax_prof_id               NUMBER,--reduced in size p_rounding_lvl_party_tax_prof_id
        p_rounding_lvl_party_type                  VARCHAR2,
        p_compounding_tax_flag                     VARCHAR2,
        p_orig_tax_status_id                       NUMBER,
        p_orig_tax_status_code                     VARCHAR2,
        p_orig_tax_rate_id                         NUMBER,
        p_orig_tax_rate_code                       VARCHAR2,
        p_orig_tax_rate                            NUMBER,
        p_orig_tax_jurisdiction_id                 NUMBER,
        p_orig_tax_jurisdiction_code               VARCHAR2,
        p_orig_tax_amt_included_flag               VARCHAR2,
        p_orig_self_assessed_flag                  VARCHAR2,
        p_tax_currency_code                        VARCHAR2,
        p_tax_amt                                  NUMBER,
        p_tax_amt_tax_curr                         NUMBER,
        p_tax_amt_funcl_curr                       NUMBER,
        p_taxable_amt                              NUMBER,
        p_taxable_amt_tax_curr                     NUMBER,
        p_taxable_amt_funcl_curr                   NUMBER,
        p_orig_taxable_amt                         NUMBER,
        p_orig_taxable_amt_tax_curr                NUMBER,
        p_cal_tax_amt                              NUMBER,
        p_cal_tax_amt_tax_curr                     NUMBER,
        p_cal_tax_amt_funcl_curr                   NUMBER,
        p_orig_tax_amt                             NUMBER,
        p_orig_tax_amt_tax_curr                    NUMBER,
        p_rec_tax_amt                              NUMBER,
        p_rec_tax_amt_tax_curr                     NUMBER,
        p_rec_tax_amt_funcl_curr                   NUMBER,
        p_nrec_tax_amt                             NUMBER,
        p_nrec_tax_amt_tax_curr                    NUMBER,
        p_nrec_tax_amt_funcl_curr                  NUMBER,
        p_tax_exemption_id                         NUMBER,
        p_tax_rate_before_exemption                NUMBER,
        p_tax_rate_name_before_exempt              VARCHAR2,
        p_exempt_rate_modifier                     NUMBER,
        p_exempt_certificate_number                VARCHAR2,
        p_exempt_reason                            VARCHAR2,
        p_exempt_reason_code                       VARCHAR2,
        p_tax_exception_id                         NUMBER,
        p_tax_rate_before_exception                NUMBER,
        p_tax_rate_name_before_except              VARCHAR2,
        p_exception_rate                           NUMBER,
        p_tax_apportionment_flag                   VARCHAR2,
        p_historical_flag                          VARCHAR2,
        p_taxable_basis_formula                    VARCHAR2,
        p_tax_calculation_formula                  VARCHAR2,
        p_cancel_flag                              VARCHAR2,
        p_purge_flag                               VARCHAR2,
        p_delete_flag                              VARCHAR2,
        p_tax_amt_included_flag                    VARCHAR2,
        p_self_assessed_flag                       VARCHAR2,
        p_overridden_flag                          VARCHAR2,
        p_manually_entered_flag                    VARCHAR2,
        p_reporting_only_flag                      VARCHAR2,
        p_freeze_until_overriddn_flg               VARCHAR2,--reduced in size p_Freeze_Until_Overridden_Flag
        p_copied_from_other_doc_flag               VARCHAR2,
        p_recalc_required_flag                     VARCHAR2,
        p_settlement_flag                          VARCHAR2,
        p_item_dist_changed_flag                   VARCHAR2,
        p_assoc_children_frozen_flg                VARCHAR2,--reduced in size p_Associated_Child_Frozen_Flag
        p_tax_only_line_flag                       VARCHAR2,
        p_compounding_dep_tax_flag                 VARCHAR2,
        p_compounding_tax_miss_flag                VARCHAR2,
        p_sync_with_prvdr_flag                     VARCHAR2,
        p_last_manual_entry                        VARCHAR2,
        p_tax_provider_id                          NUMBER,
        p_record_type_code                         VARCHAR2,
        p_reporting_period_id                      NUMBER,
        p_legal_justification_text1                VARCHAR2,
        p_legal_justification_text2                VARCHAR2,
        p_legal_justification_text3                VARCHAR2,
        p_legal_message_appl_2                     NUMBER,
        p_legal_message_status                     NUMBER,
        p_legal_message_rate                       NUMBER,
        p_legal_message_basis                      NUMBER,
        p_legal_message_calc                       NUMBER,
        p_legal_message_threshold                  NUMBER,
        p_legal_message_pos                        NUMBER,
        p_legal_message_trn                        NUMBER,
        p_legal_message_exmpt                      NUMBER,
        p_legal_message_excpt                      NUMBER,
        p_tax_regime_template_id                   NUMBER,
        p_tax_applicability_result_id              NUMBER,--reduced in size p_tax_applicability_result_id
        p_direct_rate_result_id                    NUMBER,
        p_status_result_id                         NUMBER,
        p_rate_result_id                           NUMBER,
        p_basis_result_id                          NUMBER,
        p_thresh_result_id                         NUMBER,
        p_calc_result_id                           NUMBER,
        p_tax_reg_num_det_result_id                NUMBER,
        p_eval_exmpt_result_id                     NUMBER,
        p_eval_excpt_result_id                     NUMBER,
        p_enforced_from_nat_acct_flg               VARCHAR2,--reduced in size p_Enforce_From_Natural_Acct_Flag
        p_tax_hold_code                            NUMBER,
        p_tax_hold_released_code                   NUMBER,
        p_prd_total_tax_amt                        NUMBER,
        p_prd_total_tax_amt_tax_curr               NUMBER,
        p_prd_total_tax_amt_funcl_curr             NUMBER,
        p_trx_line_index                           VARCHAR2,
        p_offset_tax_rate_code                     VARCHAR2,
        p_proration_code                           VARCHAR2,
        p_other_doc_source                         VARCHAR2,
        p_internal_org_location_id                 NUMBER,
        p_line_assessable_value                    NUMBER,
        p_ctrl_total_line_tx_amt                   NUMBER,
        p_applied_to_trx_number                    VARCHAR2,
        p_attribute_category                       VARCHAR2,
        p_attribute1                               VARCHAR2,
        p_attribute2                               VARCHAR2,
        p_attribute3                               VARCHAR2,
        p_attribute4                               VARCHAR2,
        p_attribute5                               VARCHAR2,
        p_attribute6                               VARCHAR2,
        p_attribute7                               VARCHAR2,
        p_attribute8                               VARCHAR2,
        p_attribute9                               VARCHAR2,
        p_attribute10                              VARCHAR2,
        p_attribute11                              VARCHAR2,
        p_attribute12                              VARCHAR2,
        p_attribute13                              VARCHAR2,
        p_attribute14                              VARCHAR2,
        p_attribute15                              VARCHAR2,
        p_global_attribute_category                VARCHAR2,
        p_global_attribute1                        VARCHAR2,
        p_global_attribute2                        VARCHAR2,
        p_global_attribute3                        VARCHAR2,
        p_global_attribute4                        VARCHAR2,
        p_global_attribute5                        VARCHAR2,
        p_global_attribute6                        VARCHAR2,
        p_global_attribute7                        VARCHAR2,
        p_global_attribute8                        VARCHAR2,
        p_global_attribute9                        VARCHAR2,
        p_global_attribute10                       VARCHAR2,
        p_global_attribute11                       VARCHAR2,
        p_global_attribute12                       VARCHAR2,
        p_global_attribute13                       VARCHAR2,
        p_global_attribute14                       VARCHAR2,
        p_global_attribute15                       VARCHAR2,
        p_numeric1                                 NUMBER,
        p_numeric2                                 NUMBER,
        p_numeric3                                 NUMBER,
        p_numeric4                                 NUMBER,
        p_numeric5                                 NUMBER,
        p_numeric6                                 NUMBER,
        p_numeric7                                 NUMBER,
        p_numeric8                                 NUMBER,
        p_numeric9                                 NUMBER,
        p_numeric10                                NUMBER,
        p_char1                                    VARCHAR2,
        p_char2                                    VARCHAR2,
        p_char3                                    VARCHAR2,
        p_char4                                    VARCHAR2,
        p_char5                                    VARCHAR2,
        p_char6                                    VARCHAR2,
        p_char7                                    VARCHAR2,
        p_char8                                    VARCHAR2,
        p_char9                                    VARCHAR2,
        p_char10                                   VARCHAR2,
        p_date1                                    DATE,
        p_date2                                    DATE,
        p_date3                                    DATE,
        p_date4                                    DATE,
        p_date5                                    DATE,
        p_date6                                    DATE,
        p_date7                                    DATE,
        p_date8                                    DATE,
        p_date9                                    DATE,
        p_date10                                   DATE,
        P_interface_entity_code                    VARCHAR2,
        P_interface_tax_line_id                    NUMBER,
        P_taxing_juris_geography_id                NUMBER,
        P_adjusted_doc_tax_line_id                 NUMBER,
        P_object_version_number                    NUMBER,
        p_created_by                               NUMBER,
        p_creation_date                            DATE,
        p_last_updated_by                          NUMBER,
        p_last_update_date                         DATE,
        p_last_update_login                        NUMBER) IS

   l_return_status    VARCHAR2(1000);
    l_msg_count        NUMBER;
    l_msg_data         VARCHAR2(1000);
    l_tax_line_id      NUMBER;
    l_tax_reporting_flag     ZX_EVNT_CLS_MAPPINGS.tax_reporting_flag%TYPE;
    l_report_status_tracking ZX_LINES.legal_reporting_status%TYPE;
    l_offset_tax_rate_code VARCHAR2(100);
    l_offset_flag VARCHAR2(10);
    l_offset_tax_flag VARCHAR2(100);

    CURSOR C IS
      SELECT rowid
      FROM ZX_LINES
      WHERE TAX_LINE_ID = p_tax_line_id;

  BEGIN
    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_DETAIL_OVERRIDE_PKG.Insert_Row.BEGIN',
                     'ZX_TRL_DETAIL_OVERRIDE_PKG: Insert_Row (+)');
    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_DETAIL_OVERRIDE_PKG.Insert_Row',
                     'Inserting into ZX_LINES (+)');
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_DETAIL_OVERRIDE_PKG.Insert_Row',
                     'p_entity_code '||p_entity_code);
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_DETAIL_OVERRIDE_PKG.Insert_Row',
                     'p_tax_line_number '||to_char(p_tax_line_number));
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_DETAIL_OVERRIDE_PKG.Insert_Row',
                     'p_event_class_code '||p_event_class_code);
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_DETAIL_OVERRIDE_PKG.Insert_Row',
                     'p_application_id '||p_application_id);
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_DETAIL_OVERRIDE_PKG.Insert_Row',
                     'p_tax_id ' ||p_tax_id);
    END IF;

  BEGIN
	  select tax_reporting_flag into l_tax_reporting_flag
	  from zx_evnt_cls_mappings
	  where entity_code = p_entity_code
	  and   event_class_code = p_event_class_code
	  and   application_id   = p_application_id;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_DETAIL_OVERRIDE_PKG.Insert_Row',
                     'No data found while querying up zx_event_cls_mappings Please check seed data');
  END if;
  END;


  IF p_application_id = 200 THEN
   BEGIN
     select offset_tax_flag into l_offset_tax_flag
     from zx_taxes_b where
     tax_id = p_tax_id
     and p_tax_determine_date between effective_from and
nvl(effective_to,p_tax_determine_date);

     IF nvl(l_offset_tax_flag,'N') <> 'Y' THEN
      select offset_tax_rate_code, 'N'
     INTO l_offset_tax_rate_code, l_offset_flag
     from zx_rates_b
      where tax_rate_id = p_tax_rate_id
      and p_tax_determine_date between effective_from and
nvl(effective_to,p_tax_determine_date);
     ELSE
      l_offset_flag := 'Y';
     END IF;


   EXCEPTIOn
    WHEN others THEN null;
   END;

  END IF;
  IF l_tax_reporting_flag = 'Y'
  THEN
   BEGIN
     select legal_reporting_status_def_val into l_report_status_tracking
     from zx_taxes_b where
     tax_id = p_tax_id;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_DETAIL_OVERRIDE_PKG.Insert_Row',
                     'No data found while querying up taxes using the tax id Possibly an invalid tax id is passed');
    END IF;
   END;
  END if;

    INSERT INTO ZX_LINES (TAX_LINE_ID,
                          INTERNAL_ORGANIZATION_ID,
                          APPLICATION_ID,
                          ENTITY_CODE,
                          EVENT_CLASS_CODE,
                          EVENT_TYPE_CODE,
                          TRX_ID,
                          TRX_LINE_ID,
                          TRX_LEVEL_TYPE,
                          TRX_LINE_NUMBER,
                          DOC_EVENT_STATUS,
                          TAX_EVENT_CLASS_CODE,
                          TAX_EVENT_TYPE_CODE,
                          TAX_LINE_NUMBER,
                          CONTENT_OWNER_ID,
                          TAX_REGIME_ID,
                          TAX_REGIME_CODE,
                          TAX_ID,
                          TAX,
                          TAX_STATUS_ID,
                          TAX_STATUS_CODE,
                          TAX_RATE_ID,
                          TAX_RATE_CODE,
                          TAX_RATE,
                          TAX_RATE_TYPE,
                          TAX_APPORTIONMENT_LINE_NUMBER,
                          TRX_ID_LEVEL2,
                          TRX_ID_LEVEL3,
                          TRX_ID_LEVEL4,
                          TRX_ID_LEVEL5,
                          TRX_ID_LEVEL6,
                          TRX_USER_KEY_LEVEL1,
                          TRX_USER_KEY_LEVEL2,
                          TRX_USER_KEY_LEVEL3,
                          TRX_USER_KEY_LEVEL4,
                          TRX_USER_KEY_LEVEL5,
                          TRX_USER_KEY_LEVEL6,
                          MRC_TAX_LINE_FLAG,
                          MRC_LINK_TO_TAX_LINE_ID,
                          LEDGER_ID,
                          ESTABLISHMENT_ID,
                          LEGAL_ENTITY_ID,
                          HQ_ESTB_REG_NUMBER,
                          HQ_ESTB_PARTY_TAX_PROF_ID,
                          CURRENCY_CONVERSION_DATE,
                          CURRENCY_CONVERSION_TYPE,
                          CURRENCY_CONVERSION_RATE,
                          TAX_CURRENCY_CONVERSION_DATE,
                          TAX_CURRENCY_CONVERSION_TYPE,
                          TAX_CURRENCY_CONVERSION_RATE,
                          TRX_CURRENCY_CODE,
                          REPORTING_CURRENCY_CODE,
                          MINIMUM_ACCOUNTABLE_UNIT,
                          PRECISION,
                          TRX_NUMBER,
                          TRX_DATE,
                          UNIT_PRICE,
                          LINE_AMT,
                          TRX_LINE_QUANTITY,
                          TAX_BASE_MODIFIER_RATE,
                          REF_DOC_APPLICATION_ID,
                          REF_DOC_ENTITY_CODE,
                          REF_DOC_EVENT_CLASS_CODE,
                          REF_DOC_TRX_ID,
                          REF_DOC_TRX_LEVEL_TYPE,
                          REF_DOC_LINE_ID,
                          REF_DOC_LINE_QUANTITY,
                          OTHER_DOC_LINE_AMT,
                          OTHER_DOC_LINE_TAX_AMT,
                          OTHER_DOC_LINE_TAXABLE_AMT,
                          UNROUNDED_TAXABLE_AMT,
                          UNROUNDED_TAX_AMT,
                          RELATED_DOC_APPLICATION_ID,
                          RELATED_DOC_ENTITY_CODE,
                          RELATED_DOC_EVENT_CLASS_CODE,
                          RELATED_DOC_TRX_ID,
                          RELATED_DOC_TRX_LEVEL_TYPE,
                          RELATED_DOC_NUMBER,
                          RELATED_DOC_DATE,
                          APPLIED_FROM_APPLICATION_ID,
                          APPLIED_FROM_EVENT_CLASS_CODE,
                          APPLIED_FROM_ENTITY_CODE,
                          APPLIED_FROM_TRX_ID,
                          APPLIED_FROM_TRX_LEVEL_TYPE,
                          APPLIED_FROM_LINE_ID,
                          APPLIED_FROM_TRX_NUMBER,
                          ADJUSTED_DOC_APPLICATION_ID,
                          ADJUSTED_DOC_ENTITY_CODE,
                          ADJUSTED_DOC_EVENT_CLASS_CODE,
                          ADJUSTED_DOC_TRX_ID,
                          ADJUSTED_DOC_TRX_LEVEL_TYPE,
                          ADJUSTED_DOC_LINE_ID,
                          ADJUSTED_DOC_NUMBER,
                          ADJUSTED_DOC_DATE,
                          APPLIED_TO_APPLICATION_ID,
                          APPLIED_TO_EVENT_CLASS_CODE,
                          APPLIED_TO_ENTITY_CODE,
                          APPLIED_TO_TRX_ID,
                          APPLIED_TO_TRX_LEVEL_TYPE,
                          APPLIED_TO_LINE_ID,
                          SUMMARY_TAX_LINE_ID,
                          OFFSET_LINK_TO_TAX_LINE_ID,
                          OFFSET_FLAG,
                          PROCESS_FOR_RECOVERY_FLAG,
                          TAX_JURISDICTION_ID,
                          TAX_JURISDICTION_CODE,
                          PLACE_OF_SUPPLY,
                          PLACE_OF_SUPPLY_TYPE_CODE,
                          PLACE_OF_SUPPLY_RESULT_ID,
                          TAX_DATE_RULE_ID,
                          TAX_DATE,
                          TAX_DETERMINE_DATE,
                          TAX_POINT_DATE,
                          TRX_LINE_DATE,
                          TAX_TYPE_CODE,
                          TAX_CODE,
                          TAX_REGISTRATION_ID,
                          TAX_REGISTRATION_NUMBER,
                          REGISTRATION_PARTY_TYPE,
                          ROUNDING_LEVEL_CODE,
                          ROUNDING_RULE_CODE,
                          ROUNDING_LVL_PARTY_TAX_PROF_ID,
                          ROUNDING_LVL_PARTY_TYPE,
                          COMPOUNDING_TAX_FLAG,
                          ORIG_TAX_STATUS_ID,
                          ORIG_TAX_STATUS_CODE,
                          ORIG_TAX_RATE_ID,
                          ORIG_TAX_RATE_CODE,
                          ORIG_TAX_RATE,
                          ORIG_TAX_JURISDICTION_ID,
                          ORIG_TAX_JURISDICTION_CODE,
                          ORIG_TAX_AMT_INCLUDED_FLAG,
                          ORIG_SELF_ASSESSED_FLAG,
                          TAX_CURRENCY_CODE,
                          TAX_AMT,
                          TAX_AMT_TAX_CURR,
                          TAX_AMT_FUNCL_CURR,
                          TAXABLE_AMT,
                          TAXABLE_AMT_TAX_CURR,
                          TAXABLE_AMT_FUNCL_CURR,
                          ORIG_TAXABLE_AMT,
                          ORIG_TAXABLE_AMT_TAX_CURR,
                          CAL_TAX_AMT,
                          CAL_TAX_AMT_TAX_CURR,
                          CAL_TAX_AMT_FUNCL_CURR,
                          ORIG_TAX_AMT,
                          ORIG_TAX_AMT_TAX_CURR,
                          REC_TAX_AMT,
                          REC_TAX_AMT_TAX_CURR,
                          REC_TAX_AMT_FUNCL_CURR,
                          NREC_TAX_AMT,
                          NREC_TAX_AMT_TAX_CURR,
                          NREC_TAX_AMT_FUNCL_CURR,
                          TAX_EXEMPTION_ID,
                          TAX_RATE_BEFORE_EXEMPTION,
                          TAX_RATE_NAME_BEFORE_EXEMPTION,
                          EXEMPT_RATE_MODIFIER,
                          EXEMPT_CERTIFICATE_NUMBER,
                          EXEMPT_REASON,
                          EXEMPT_REASON_CODE,
                          TAX_EXCEPTION_ID,
                          TAX_RATE_BEFORE_EXCEPTION,
                          TAX_RATE_NAME_BEFORE_EXCEPTION,
                          EXCEPTION_RATE,
                          TAX_APPORTIONMENT_FLAG,
                          HISTORICAL_FLAG,
                          TAXABLE_BASIS_FORMULA,
                          TAX_CALCULATION_FORMULA,
                          CANCEL_FLAG,
                          PURGE_FLAG,
                          DELETE_FLAG,
                          TAX_AMT_INCLUDED_FLAG,
                          SELF_ASSESSED_FLAG,
                          OVERRIDDEN_FLAG,
                          MANUALLY_ENTERED_FLAG,
                          REPORTING_ONLY_FLAG,
                          FREEZE_UNTIL_OVERRIDDEN_FLAG,
                          COPIED_FROM_OTHER_DOC_FLAG,
                          RECALC_REQUIRED_FLAG,
                          SETTLEMENT_FLAG,
                          ITEM_DIST_CHANGED_FLAG,
                          ASSOCIATED_CHILD_FROZEN_FLAG,
                          TAX_ONLY_LINE_FLAG,
                          COMPOUNDING_DEP_TAX_FLAG,
                          COMPOUNDING_TAX_MISS_FLAG,
                          SYNC_WITH_PRVDR_FLAG,
                          LAST_MANUAL_ENTRY,
                          TAX_PROVIDER_ID,
                          RECORD_TYPE_CODE,
                          REPORTING_PERIOD_ID,
                          LEGAL_JUSTIFICATION_TEXT1,
                          LEGAL_JUSTIFICATION_TEXT2,
                          LEGAL_JUSTIFICATION_TEXT3,
                          LEGAL_MESSAGE_APPL_2,
                          LEGAL_MESSAGE_STATUS,
                          LEGAL_MESSAGE_RATE,
                          LEGAL_MESSAGE_BASIS,
                          LEGAL_MESSAGE_CALC,
                          LEGAL_MESSAGE_THRESHOLD,
                          LEGAL_MESSAGE_POS,
                          LEGAL_MESSAGE_TRN,
                          LEGAL_MESSAGE_EXMPT,
                          LEGAL_MESSAGE_EXCPT,
                          TAX_REGIME_TEMPLATE_ID,
                          TAX_APPLICABILITY_RESULT_ID,
                          DIRECT_RATE_RESULT_ID,
                          STATUS_RESULT_ID,
                          RATE_RESULT_ID,
                          BASIS_RESULT_ID,
                          THRESH_RESULT_ID,
                          CALC_RESULT_ID,
                          TAX_REG_NUM_DET_RESULT_ID,
                          EVAL_EXMPT_RESULT_ID,
                          EVAL_EXCPT_RESULT_ID,
                          ENFORCE_FROM_NATURAL_ACCT_FLAG,
                          TAX_HOLD_CODE,
                          TAX_HOLD_RELEASED_CODE,
                          PRD_TOTAL_TAX_AMT,
                          PRD_TOTAL_TAX_AMT_TAX_CURR,
                          PRD_TOTAL_TAX_AMT_FUNCL_CURR,
                          TRX_LINE_INDEX,
                          OFFSET_TAX_RATE_CODE,
                          PRORATION_CODE,
                          OTHER_DOC_SOURCE,
                          INTERNAL_ORG_LOCATION_ID,
                          LINE_ASSESSABLE_VALUE,
                          CTRL_TOTAL_LINE_TX_AMT,
                          APPLIED_TO_TRX_NUMBER,
                          MULTIPLE_JURISDICTIONS_FLAG,
                          ATTRIBUTE_CATEGORY,
                          ATTRIBUTE1,
                          ATTRIBUTE2,
                          ATTRIBUTE3,
                          ATTRIBUTE4,
                          ATTRIBUTE5,
                          ATTRIBUTE6,
                          ATTRIBUTE7,
                          ATTRIBUTE8,
                          ATTRIBUTE9,
                          ATTRIBUTE10,
                          ATTRIBUTE11,
                          ATTRIBUTE12,
                          ATTRIBUTE13,
                          ATTRIBUTE14,
                          ATTRIBUTE15,
                          GLOBAL_ATTRIBUTE_CATEGORY,
                          GLOBAL_ATTRIBUTE1,
                          GLOBAL_ATTRIBUTE2,
                          GLOBAL_ATTRIBUTE3,
                          GLOBAL_ATTRIBUTE4,
                          GLOBAL_ATTRIBUTE5,
                          GLOBAL_ATTRIBUTE6,
                          GLOBAL_ATTRIBUTE7,
                          GLOBAL_ATTRIBUTE8,
                          GLOBAL_ATTRIBUTE9,
                          GLOBAL_ATTRIBUTE10,
                          GLOBAL_ATTRIBUTE11,
                          GLOBAL_ATTRIBUTE12,
                          GLOBAL_ATTRIBUTE13,
                          GLOBAL_ATTRIBUTE14,
                          GLOBAL_ATTRIBUTE15,
                          NUMERIC1,
                          NUMERIC2,
                          NUMERIC3,
                          NUMERIC4,
                          NUMERIC5,
                          NUMERIC6,
                          NUMERIC7,
                          NUMERIC8,
                          NUMERIC9,
                          NUMERIC10,
                          CHAR1,
                          CHAR2,
                          CHAR3,
                          CHAR4,
                          CHAR5,
                          CHAR6,
                          CHAR7,
                          CHAR8,
                          CHAR9,
                          CHAR10,
                          DATE1,
                          DATE2,
                          DATE3,
                          DATE4,
                          DATE5,
                          DATE6,
                          DATE7,
                          DATE8,
                          DATE9,
                          DATE10,
                          INTERFACE_ENTITY_CODE,
                          INTERFACE_TAX_LINE_ID,
                          TAXING_JURIS_GEOGRAPHY_ID,
                          ADJUSTED_DOC_TAX_LINE_ID,
			  LEGAL_REPORTING_STATUS,
                          OBJECT_VERSION_NUMBER,
                          CREATED_BY,
                          CREATION_DATE,
                          LAST_UPDATED_BY,
                          LAST_UPDATE_DATE,
                          LAST_UPDATE_LOGIN)
                  VALUES (p_tax_line_id,
                          p_internal_organization_id,
                          p_application_id,
                          p_entity_code,
                          p_event_class_code,
                          p_event_type_code,
                          p_trx_id,
                          p_trx_line_id,
                          p_trx_level_type,
                          p_trx_line_number,
                          p_doc_event_status,
                          p_tax_event_class_code,
                          p_tax_event_type_code,
                          p_tax_line_number,
                          p_content_owner_id,
                          p_tax_regime_id,
                          p_tax_regime_code,
                          p_tax_id,
                          p_tax,
                          p_tax_status_id,
                          p_tax_status_code,
                          p_tax_rate_id,
                          p_tax_rate_code,
                          p_tax_rate,
                          p_tax_rate_type,
                          NVL(p_tax_apportionment_line_num,1),
                          p_trx_id_level2,
                          p_trx_id_level3,
                          p_trx_id_level4,
                          p_trx_id_level5,
                          p_trx_id_level6,
                          p_trx_user_key_level1,
                          p_trx_user_key_level2,
                          p_trx_user_key_level3,
                          p_trx_user_key_level4,
                          p_trx_user_key_level5,
                          p_trx_user_key_level6,
                          NVL(p_mrc_tax_line_flag, 'N'),
                          p_mrc_link_to_tax_line_id,
                          p_ledger_id,
                          p_establishment_id,
                          p_legal_entity_id,
                          p_hq_estb_reg_number,
                          p_hq_estb_party_tax_prof_id,
                          p_currency_conversion_date,
                          p_currency_conversion_type,
                          p_currency_conversion_rate,
                          p_tax_curr_conversion_date,
                          p_tax_curr_conversion_type,
                          p_tax_curr_conversion_rate,
                          p_trx_currency_code,
                          p_reporting_currency_code,
                          p_minimum_accountable_unit,
                          p_precision,
                          p_trx_number,
                          p_trx_date,
                          p_unit_price,
                          p_line_amt,
                          p_trx_line_quantity,
                          p_tax_base_modifier_rate,
                          p_ref_doc_application_id,
                          p_ref_doc_entity_code,
                          p_ref_doc_event_class_code,
                          p_ref_doc_trx_id,
                          p_ref_doc_trx_level_type,
                          p_ref_doc_line_id,
                          p_ref_doc_line_quantity,
                          p_other_doc_line_amt,
                          p_other_doc_line_tax_amt,
                          p_other_doc_line_taxable_amt,
                          p_unrounded_taxable_amt,
                          p_unrounded_tax_amt,
                          p_related_doc_application_id,
                          p_related_doc_entity_code,
                          p_related_doc_evt_class_code,
                          p_related_doc_trx_id,
                          p_related_doc_trx_level_type,
                          p_related_doc_number,
                          p_related_doc_date,
                          p_applied_from_appl_id,
                          p_applied_from_evt_clss_code,
                          p_applied_from_entity_code,
                          p_applied_from_trx_id,
                          p_applied_from_trx_level_type,
                          p_applied_from_line_id,
                          p_applied_from_trx_number,
                          p_adjusted_doc_appln_id,
                          p_adjusted_doc_entity_code,
                          p_adjusted_doc_evt_clss_code,
                          p_adjusted_doc_trx_id,
                          p_adjusted_doc_trx_level_type,
                          p_adjusted_doc_line_id,
                          p_adjusted_doc_number,
                          p_adjusted_doc_date,
                          p_applied_to_application_id,
                          p_applied_to_evt_class_code,
                          p_applied_to_entity_code,
                          p_applied_to_trx_id,
                          p_applied_to_trx_level_type,
                          p_applied_to_line_id,
                          p_summary_tax_line_id,
                          p_offset_link_to_tax_line_id,
                          nvl(l_offset_flag,'N'), --p_offset_flag
                          'Y', --p_process_for_recovery_flag,
                          p_tax_jurisdiction_id,
                          p_tax_jurisdiction_code,
                          p_place_of_supply,
                          p_place_of_supply_type_code,
                          p_place_of_supply_result_id,
                          p_tax_date_rule_id,
                          p_tax_date,
                          p_tax_determine_date,
                          p_tax_point_date,
                          p_trx_line_date,
                          p_tax_type_code,
                          p_tax_code,
                          p_tax_registration_id,
                          p_tax_registration_number,
                          p_registration_party_type,
                          p_rounding_level_code,
                          p_rounding_rule_code,
                          p_rndg_lvl_party_tax_prof_id,
                          p_rounding_lvl_party_type,
                          DECODE(p_overridden_flag, 'C', NVL(p_compounding_tax_flag,'N'), 'N'),              --p_compounding_tax_flag
                          p_orig_tax_status_id,
                          p_orig_tax_status_code,
                          p_orig_tax_rate_id,
                          p_orig_tax_rate_code,
                          p_orig_tax_rate,
                          p_orig_tax_jurisdiction_id,
                          p_orig_tax_jurisdiction_code,
                          DECODE(p_overridden_flag, 'C', p_orig_tax_amt_included_flag, NULL),   --p_orig_tax_amt_included_flag,
                          DECODE(p_overridden_flag, 'C', p_orig_self_assessed_flag, NULL),      --p_orig_self_assessed_flag,
                          p_tax_currency_code,
                          p_tax_amt,
                          p_tax_amt_tax_curr,
                          p_tax_amt_funcl_curr,
                          p_taxable_amt,
                          p_taxable_amt_tax_curr,
                          p_taxable_amt_funcl_curr,
                          p_orig_taxable_amt,
                          p_orig_taxable_amt_tax_curr,
                          p_cal_tax_amt,
                          p_cal_tax_amt_tax_curr,
                          p_cal_tax_amt_funcl_curr,
                          decode(p_manually_entered_flag,'Y',decode(p_tax_amt_included_flag,'Y',p_line_amt*p_tax_rate/(100 + p_tax_rate),p_line_amt*p_tax_rate/100),p_orig_tax_amt),
                          p_orig_tax_amt_tax_curr,
                          p_rec_tax_amt,
                          p_rec_tax_amt_tax_curr,
                          p_rec_tax_amt_funcl_curr,
                          p_nrec_tax_amt,
                          p_nrec_tax_amt_tax_curr,
                          p_nrec_tax_amt_funcl_curr,
                          p_tax_exemption_id,
                          p_tax_rate_before_exemption,
                          p_tax_rate_before_exception,  --check the param
                          p_exempt_rate_modifier,
                          p_exempt_certificate_number,
                          p_exempt_reason,
                          p_exempt_reason_code,
                          p_tax_exception_id,
                          p_tax_rate_before_exception,
                          p_tax_rate_name_before_except,
                          p_exception_rate,
                          DECODE(p_overridden_flag, 'C', NVL(p_tax_apportionment_flag,'N'), 'N'),    --p_tax_apportionment_flag,
                          DECODE(p_overridden_flag, 'C', NVL(p_historical_flag,'N'), 'N'),           --p_historical_flag
                          p_taxable_basis_formula,
                          p_tax_calculation_formula,
                          DECODE(p_overridden_flag, 'C', NVL(p_cancel_flag, 'N'), 'N'),              --p_cancel_flag
                          DECODE(p_overridden_flag, 'C', NVL(p_purge_flag,'N'), 'N'),                --p_purge_flag
                          DECODE(p_overridden_flag, 'C', NVL(p_delete_flag,'N'), 'N'),               --p_delete_flag
                          p_tax_amt_included_flag,
                          p_self_assessed_flag,
                          DECODE(p_overridden_flag, 'C', 'Y', 'N'),                                  --p_overridden_flag
                          DECODE(p_overridden_flag, 'C', NVL(p_manually_entered_flag,'N'), 'Y'),     --p_manually_entered_flag,
                          DECODE(p_overridden_flag, 'C', NVL(p_reporting_only_flag,'N'), 'N'),       --p_reporting_only_flag
                          DECODE(p_overridden_flag, 'C', NVL(p_freeze_until_overriddn_flg,'N'), 'N'),--p_freeze_until_overriddn_flg
                          DECODE(p_overridden_flag, 'C', NVL(p_copied_from_other_doc_flag,'N'), 'N'),--p_copied_from_other_doc_flag
                    'Y',                                                                       --p_recalc_required_flag,
                          DECODE(p_overridden_flag, 'C', NVL(p_settlement_flag,'N'), 'N'),           --p_settlement_flag
                          DECODE(p_overridden_flag, 'C', NVL(p_item_dist_changed_flag,'N'),'N'),     --p_item_dist_changed_flag
                          'N', --p_assoc_children_frozen_flg
                          p_tax_only_line_flag,
                          DECODE(p_overridden_flag, 'C', NVL(p_compounding_tax_miss_flag, 'N'),'N'), --p_compounding_tax_miss_flag,
                          DECODE(p_overridden_flag, 'C', NVL(p_compounding_dep_tax_flag,'N'), 'N'),  --p_compounding_dep_tax_flag
                          decode(p_tax_provider_id, NULL, 'N', 'Y'),                                 --p_sync_with_prvdr_flag,
                          DECODE(p_overridden_flag, 'C', p_last_manual_entry, 'TAX_AMOUNT'),         --p_last_manual_entry,
                          --p_tax_provider_id,
                          NULL,
                          'ETAX_CREATED',
                          p_reporting_period_id,
                          p_legal_justification_text1,
                          p_legal_justification_text2,
                          p_legal_justification_text3,
                          p_legal_message_appl_2,
                          p_legal_message_status,
                          p_legal_message_rate,
                          p_legal_message_basis,
                          p_legal_message_calc,
                          p_legal_message_threshold,
                          p_legal_message_pos,
                          p_legal_message_trn,
                          p_legal_message_exmpt,
                          p_legal_message_excpt,
                          p_tax_regime_template_id,
                          p_tax_applicability_result_id,
                          p_direct_rate_result_id,
                          p_status_result_id,
                          p_rate_result_id,
                          p_basis_result_id,
                          p_thresh_result_id,
                          p_calc_result_id,
                          p_tax_reg_num_det_result_id,
                          p_eval_exmpt_result_id,
                          p_eval_excpt_result_id,
                          DECODE(p_overridden_flag, 'C', p_enforced_from_nat_acct_flg, 'N'), --p_enforced_from_nat_acct_flg
                          p_tax_hold_code,
                          p_tax_hold_released_code,
                          p_prd_total_tax_amt,
                          p_prd_total_tax_amt_tax_curr,
                          p_prd_total_tax_amt_funcl_curr,
                          p_trx_line_index,
                          l_offset_tax_rate_code,
                          p_proration_code,
                          p_other_doc_source,
                          p_internal_org_location_id,
                          p_line_assessable_value,
                          p_ctrl_total_line_tx_amt,
                          p_applied_to_trx_number,
                          'N',                                                               --p_multiple_jurisdictions_flag
                          p_attribute_category,
                          p_attribute1,
                          p_attribute2,
                          p_attribute3,
                          p_attribute4,
                          p_attribute5,
                          p_attribute6,
                          p_attribute7,
                          p_attribute8,
                          p_attribute9,
                          p_attribute10,
                          p_attribute11,
                          p_attribute12,
                          p_attribute13,
                          p_attribute14,
                          p_attribute15,
                          p_global_attribute_category,
                          p_global_attribute1,
                          p_global_attribute2,
                          p_global_attribute3,
                          p_global_attribute4,
                          p_global_attribute5,
                          p_global_attribute6,
                          p_global_attribute7,
                          p_global_attribute8,
                          p_global_attribute9,
                          p_global_attribute10,
                          p_global_attribute11,
                          p_global_attribute12,
                          p_global_attribute13,
                          p_global_attribute14,
                          p_global_attribute15,
                          p_numeric1,
                          p_numeric2,
                          p_numeric3,
                          p_numeric4,
                          p_numeric5,
                          p_numeric6,
                          p_numeric7,
                          p_numeric8,
                          p_numeric9,
                          p_numeric10,
                          p_char1,
                          p_char2,
                          p_char3,
                          p_char4,
                          p_char5,
                          p_char6,
                          p_char7,
                          p_char8,
                          p_char9,
                          p_char10,
                          p_date1,
                          p_date2,
                          p_date3,
                          p_date4,
                          p_date5,
                          p_date6,
                          p_date7,
                          p_date8,
                          p_date9,
                          p_date10,
                          p_interface_entity_code,
                          p_interface_tax_line_id,
                          p_taxing_juris_geography_id,
                          p_adjusted_doc_tax_line_id,
			  l_report_status_tracking,
                          1,  --p_object_version_number,
                          fnd_global.user_id,
                          sysdate,
                          fnd_global.user_id,
                          sysdate,
                          fnd_global.login_id);

    OPEN C;
    FETCH C INTO x_rowid;

    IF (C%NOTFOUND) THEN
      CLOSE C;
      RAISE NO_DATA_FOUND;
    END IF;

    CLOSE C;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_DETAIL_OVERRIDE_PKG.Insert_Row',
                     'Inserting into ZX_LINES (-)');
    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_DETAIL_OVERRIDE_PKG.Insert_Row.',
                     'ZX_TRL_DETAIL_OVERRIDE_PKG: Update ZX_LINES (+)');
    END IF;

    --Set recalculate_required_flag = 'Y' for all the tax lines for the same
    --trx line with compounding_tax_miss_flag = 'Y'.
    UPDATE ZX_LINES
      SET RECALC_REQUIRED_FLAG = p_recalc_required_flag
        WHERE APPLICATION_ID          = p_application_id
        AND ENTITY_CODE               = p_entity_code
        AND EVENT_CLASS_CODE          = p_event_class_code
        AND TRX_ID                    = p_trx_id
        AND TRX_LINE_ID               = p_trx_line_id
        AND TRX_LEVEL_TYPE            = p_trx_level_type
        AND COMPOUNDING_TAX_MISS_FLAG = 'Y';

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_DETAIL_OVERRIDE_PKG.Insert_Row.',
                     'ZX_TRL_DETAIL_OVERRIDE_PKG: Update ZX_LINES (-)');
    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_DETAIL_OVERRIDE_PKG.Insert_Row.END',
                     'ZX_TRL_DETAIL_OVERRIDE_PKG: Insert_Row (-)');
    END IF;

  END Insert_Row;

  PROCEDURE Lock_Row
       (X_Rowid                      IN OUT NOCOPY VARCHAR2,
        p_tax_line_id                              NUMBER,
        p_internal_organization_id                 NUMBER,
        p_application_id                           NUMBER,
        p_entity_code                              VARCHAR2,
        p_event_class_code                         VARCHAR2,
        p_event_type_code                          VARCHAR2,
        p_trx_id                                   NUMBER,
        p_trx_line_id                              NUMBER,
        p_trx_level_type                           VARCHAR2,
        p_trx_line_number                          NUMBER,
        p_doc_event_status                         VARCHAR2,
        p_tax_event_class_code                     VARCHAR2,
        p_tax_event_type_code                      VARCHAR2,
        p_tax_line_number                          NUMBER,
        p_content_owner_id                         NUMBER,
        p_tax_regime_id                            NUMBER,
        p_tax_regime_code                          VARCHAR2,
        p_tax_id                                   NUMBER,
        p_tax                                      VARCHAR2,
        p_tax_status_id                            NUMBER,
        p_tax_status_code                          VARCHAR2,
        p_tax_rate_id                              NUMBER,
        p_tax_rate_code                            VARCHAR2,
        p_tax_rate                                 NUMBER,
        p_tax_rate_type                            VARCHAR2,
        p_tax_apportionment_line_num               NUMBER,--reduced in size tax_apportionment_line_number
        p_trx_id_level2                            NUMBER,
        p_trx_id_level3                            NUMBER,
        p_trx_id_level4                            NUMBER,
        p_trx_id_level5                            NUMBER,
        p_trx_id_level6                            NUMBER,
        p_trx_user_key_level1                      VARCHAR2,
        p_trx_user_key_level2                      VARCHAR2,
        p_trx_user_key_level3                      VARCHAR2,
        p_trx_user_key_level4                      VARCHAR2,
        p_trx_user_key_level5                      VARCHAR2,
        p_trx_user_key_level6                      VARCHAR2,
        p_mrc_tax_line_flag                        VARCHAR2,
        p_mrc_link_to_tax_line_id                  NUMBER,
        p_ledger_id                                NUMBER,
        p_establishment_id                         NUMBER,
        p_legal_entity_id                          NUMBER,
        p_hq_estb_reg_number                       VARCHAR2,
        p_hq_estb_party_tax_prof_id                NUMBER,
        p_currency_conversion_date                 DATE,
        p_currency_conversion_type                 VARCHAR2,
        p_currency_conversion_rate                 NUMBER,
        p_tax_curr_conversion_date                 DATE,--reduced in size tax_currency_conversion_date
        p_tax_curr_conversion_type                 VARCHAR2,--reduced in size p_tax_currency_conversion_type
        p_tax_curr_conversion_rate                 NUMBER,--reduced in size p_tax_currency_conversion_rate
        p_trx_currency_code                        VARCHAR2,
        p_reporting_currency_code                  VARCHAR2,
        p_minimum_accountable_unit                 NUMBER,
        p_precision                                NUMBER,
        p_trx_number                               VARCHAR2,
        p_trx_date                                 DATE,
        p_unit_price                               NUMBER,
        p_line_amt                                 NUMBER,
        p_trx_line_quantity                        NUMBER,
        p_tax_base_modifier_rate                   NUMBER,
        p_ref_doc_application_id                   NUMBER,
        p_ref_doc_entity_code                      VARCHAR2,
        p_ref_doc_event_class_code                 VARCHAR2,
        p_ref_doc_trx_id                           NUMBER,
        p_ref_doc_trx_level_type                   VARCHAR2,
        p_ref_doc_line_id                          NUMBER,
        p_ref_doc_line_quantity                    NUMBER,
        p_other_doc_line_amt                       NUMBER,
        p_other_doc_line_tax_amt                   NUMBER,
        p_other_doc_line_taxable_amt               NUMBER,
        p_unrounded_taxable_amt                    NUMBER,
        p_unrounded_tax_amt                        NUMBER,
        p_related_doc_application_id               NUMBER,
        p_related_doc_entity_code                  VARCHAR2,
        p_related_doc_evt_class_code               VARCHAR2,--reduced in size p_related_doc_event_class_code
        p_related_doc_trx_id                       NUMBER,
        p_related_doc_trx_level_type               VARCHAR2,
        p_related_doc_number                       VARCHAR2,
        p_related_doc_date                         DATE,
        p_applied_from_appl_id                     NUMBER,--reduced in size p_applied_from_application_id
        p_applied_from_evt_clss_code               VARCHAR2,--reduced in size p_applied_from_event_class_code
        p_applied_from_entity_code                 VARCHAR2,
        p_applied_from_trx_id                      NUMBER,
        p_applied_from_trx_level_type              VARCHAR2,
        p_applied_from_line_id                     NUMBER,
        p_applied_from_trx_number                  VARCHAR2,
        p_adjusted_doc_appln_id                    NUMBER,--reduced in size p_adjusted_doc_application_id
        p_adjusted_doc_entity_code                 VARCHAR2,
        p_adjusted_doc_evt_clss_code               VARCHAR2,--reduced in size p_adjusted_doc_event_class_code
        p_adjusted_doc_trx_id                      NUMBER,
        p_adjusted_doc_trx_level_type              VARCHAR2,
        p_adjusted_doc_line_id                     NUMBER,
        p_adjusted_doc_number                      VARCHAR2,
        p_adjusted_doc_date                        DATE,
        p_applied_to_application_id                NUMBER,
        p_applied_to_evt_class_code                VARCHAR2,--reduced in size p_applied_to_event_class_code
        p_applied_to_entity_code                   VARCHAR2,
        p_applied_to_trx_id                        NUMBER,
        p_applied_to_trx_level_type                VARCHAR2,
        p_applied_to_line_id                       NUMBER,
        p_summary_tax_line_id                      NUMBER,
        p_offset_link_to_tax_line_id               NUMBER,
        p_offset_flag                              VARCHAR2,
        p_process_for_recovery_flag                VARCHAR2,
        p_tax_jurisdiction_id                      NUMBER,
        p_tax_jurisdiction_code                    VARCHAR2,
        p_place_of_supply                          NUMBER,
        p_place_of_supply_type_code                VARCHAR2,
        p_place_of_supply_result_id                NUMBER,
        p_tax_date_rule_id                         NUMBER,
        p_tax_date                                 DATE,
        p_tax_determine_date                       DATE,
        p_tax_point_date                           DATE,
        p_trx_line_date                            DATE,
        p_tax_type_code                            VARCHAR2,
        p_tax_code                                 VARCHAR2,
        p_tax_registration_id                      NUMBER,
        p_tax_registration_number                  VARCHAR2,
        p_registration_party_type                  VARCHAR2,
        p_rounding_level_code                      VARCHAR2,
        p_rounding_rule_code                       VARCHAR2,
        p_rndg_lvl_party_tax_prof_id               NUMBER,--reduced in size p_rounding_lvl_party_tax_prof_id
        p_rounding_lvl_party_type                  VARCHAR2,
        p_compounding_tax_flag                     VARCHAR2,
        p_orig_tax_status_id                       NUMBER,
        p_orig_tax_status_code                     VARCHAR2,
        p_orig_tax_rate_id                         NUMBER,
        p_orig_tax_rate_code                       VARCHAR2,
        p_orig_tax_rate                            NUMBER,
        p_orig_tax_jurisdiction_id                 NUMBER,
        p_orig_tax_jurisdiction_code               VARCHAR2,
        p_orig_tax_amt_included_flag               VARCHAR2,
        p_orig_self_assessed_flag                  VARCHAR2,
        p_tax_currency_code                        VARCHAR2,
        p_tax_amt                                  NUMBER,
        p_tax_amt_tax_curr                         NUMBER,
        p_tax_amt_funcl_curr                       NUMBER,
        p_taxable_amt                              NUMBER,
        p_taxable_amt_tax_curr                     NUMBER,
        p_taxable_amt_funcl_curr                   NUMBER,
        p_orig_taxable_amt                         NUMBER,
        p_orig_taxable_amt_tax_curr                NUMBER,
        p_cal_tax_amt                              NUMBER,
        p_cal_tax_amt_tax_curr                     NUMBER,
        p_cal_tax_amt_funcl_curr                   NUMBER,
        p_orig_tax_amt                             NUMBER,
        p_orig_tax_amt_tax_curr                    NUMBER,
        p_rec_tax_amt                              NUMBER,
        p_rec_tax_amt_tax_curr                     NUMBER,
        p_rec_tax_amt_funcl_curr                   NUMBER,
        p_nrec_tax_amt                             NUMBER,
        p_nrec_tax_amt_tax_curr                    NUMBER,
        p_nrec_tax_amt_funcl_curr                  NUMBER,
        p_tax_exemption_id                         NUMBER,
        p_tax_rate_before_exemption                NUMBER,
        p_tax_rate_name_before_exempt              VARCHAR2,
        p_exempt_rate_modifier                     NUMBER,
        p_exempt_certificate_number                VARCHAR2,
        p_exempt_reason                            VARCHAR2,
        p_exempt_reason_code                       VARCHAR2,
        p_tax_exception_id                         NUMBER,
        p_tax_rate_before_exception                NUMBER,
        p_tax_rate_name_before_except              VARCHAR2,
        p_exception_rate                           NUMBER,
        p_tax_apportionment_flag                   VARCHAR2,
        p_historical_flag                          VARCHAR2,
        p_taxable_basis_formula                    VARCHAR2,
        p_tax_calculation_formula                  VARCHAR2,
        p_cancel_flag                              VARCHAR2,
        p_purge_flag                               VARCHAR2,
        p_delete_flag                              VARCHAR2,
        p_tax_amt_included_flag                    VARCHAR2,
        p_self_assessed_flag                       VARCHAR2,
        p_overridden_flag                          VARCHAR2,
        p_manually_entered_flag                    VARCHAR2,
        p_reporting_only_flag                      VARCHAR2,
        p_freeze_until_overriddn_flg               VARCHAR2,--reduced in size p_Freeze_Until_Overridden_Flag
        p_copied_from_other_doc_flag               VARCHAR2,
        p_recalc_required_flag                     VARCHAR2,
        p_settlement_flag                          VARCHAR2,
        p_item_dist_changed_flag                   VARCHAR2,
        p_assoc_children_frozen_flg                VARCHAR2,--reduced in size p_Associated_Child_Frozen_Flag
        p_tax_only_line_flag                       VARCHAR2,
        p_compounding_dep_tax_flag                 VARCHAR2,
        p_compounding_tax_miss_flag                VARCHAR2,
        p_sync_with_prvdr_flag                     VARCHAR2,
        p_last_manual_entry                        VARCHAR2,
        p_tax_provider_id                          NUMBER,
        p_record_type_code                         VARCHAR2,
        p_reporting_period_id                      NUMBER,
        p_legal_justification_text1                VARCHAR2,
        p_legal_justification_text2                VARCHAR2,
        p_legal_justification_text3                VARCHAR2,
        p_legal_message_appl_2                     NUMBER,
        p_legal_message_status                     NUMBER,
        p_legal_message_rate                       NUMBER,
        p_legal_message_basis                      NUMBER,
        p_legal_message_calc                       NUMBER,
        p_legal_message_threshold                  NUMBER,
        p_legal_message_pos                        NUMBER,
        p_legal_message_trn                        NUMBER,
        p_legal_message_exmpt                      NUMBER,
        p_legal_message_excpt                      NUMBER,
        p_tax_regime_template_id                   NUMBER,
        p_tax_applicability_result_id              NUMBER,--reduced in size p_tax_applicability_result_id
        p_direct_rate_result_id                    NUMBER,
        p_status_result_id                         NUMBER,
        p_rate_result_id                           NUMBER,
        p_basis_result_id                          NUMBER,
        p_thresh_result_id                         NUMBER,
        p_calc_result_id                           NUMBER,
        p_tax_reg_num_det_result_id                NUMBER,
        p_eval_exmpt_result_id                     NUMBER,
        p_eval_excpt_result_id                     NUMBER,
        p_enforced_from_nat_acct_flg               VARCHAR2,--reduced in size p_Enforce_From_Natural_Acct_Flag
        p_tax_hold_code                            NUMBER,
        p_tax_hold_released_code                   NUMBER,
        p_prd_total_tax_amt                        NUMBER,
        p_prd_total_tax_amt_tax_curr               NUMBER,
        p_prd_total_tax_amt_funcl_curr             NUMBER,
        p_trx_line_index                           VARCHAR2,
        p_offset_tax_rate_code                     VARCHAR2,
        p_proration_code                           VARCHAR2,
        p_other_doc_source                         VARCHAR2,
        p_internal_org_location_id                 NUMBER,
        p_line_assessable_value                    NUMBER,
        p_ctrl_total_line_tx_amt                   NUMBER,
        p_applied_to_trx_number                    VARCHAR2,
        p_attribute_category                       VARCHAR2,
        p_attribute1                               VARCHAR2,
        p_attribute2                               VARCHAR2,
        p_attribute3                               VARCHAR2,
        p_attribute4                               VARCHAR2,
        p_attribute5                               VARCHAR2,
        p_attribute6                               VARCHAR2,
        p_attribute7                               VARCHAR2,
        p_attribute8                               VARCHAR2,
        p_attribute9                               VARCHAR2,
        p_attribute10                              VARCHAR2,
        p_attribute11                              VARCHAR2,
        p_attribute12                              VARCHAR2,
        p_attribute13                              VARCHAR2,
        p_attribute14                              VARCHAR2,
        p_attribute15                              VARCHAR2,
        p_global_attribute_category                VARCHAR2,
        p_global_attribute1                        VARCHAR2,
        p_global_attribute2                        VARCHAR2,
        p_global_attribute3                        VARCHAR2,
        p_global_attribute4                        VARCHAR2,
        p_global_attribute5                        VARCHAR2,
        p_global_attribute6                        VARCHAR2,
        p_global_attribute7                        VARCHAR2,
        p_global_attribute8                        VARCHAR2,
        p_global_attribute9                        VARCHAR2,
        p_global_attribute10                       VARCHAR2,
        p_global_attribute11                       VARCHAR2,
        p_global_attribute12                       VARCHAR2,
        p_global_attribute13                       VARCHAR2,
        p_global_attribute14                       VARCHAR2,
        p_global_attribute15                       VARCHAR2,
        p_numeric1                                 NUMBER,
        p_numeric2                                 NUMBER,
        p_numeric3                                 NUMBER,
        p_numeric4                                 NUMBER,
        p_numeric5                                 NUMBER,
        p_numeric6                                 NUMBER,
        p_numeric7                                 NUMBER,
        p_numeric8                                 NUMBER,
        p_numeric9                                 NUMBER,
        p_numeric10                                NUMBER,
        p_char1                                    VARCHAR2,
        p_char2                                    VARCHAR2,
        p_char3                                    VARCHAR2,
        p_char4                                    VARCHAR2,
        p_char5                                    VARCHAR2,
        p_char6                                    VARCHAR2,
        p_char7                                    VARCHAR2,
        p_char8                                    VARCHAR2,
        p_char9                                    VARCHAR2,
        p_char10                                   VARCHAR2,
        p_date1                                    DATE,
        p_date2                                    DATE,
        p_date3                                    DATE,
        p_date4                                    DATE,
        p_date5                                    DATE,
        p_date6                                    DATE,
        p_date7                                    DATE,
        p_date8                                    DATE,
        p_date9                                    DATE,
        p_date10                                   DATE,
        p_interface_entity_code                    VARCHAR2,
        p_interface_tax_line_id                    NUMBER,
        p_taxing_juris_geography_id                NUMBER,
        p_adjusted_doc_tax_line_id                 NUMBER,
        p_object_version_number                    NUMBER,
        p_created_by                               NUMBER,
        p_creation_date                            DATE,
        p_last_updated_by                          NUMBER,
        p_last_update_date                         DATE,
        p_last_update_login                        NUMBER) IS

    CURSOR lines_csr IS
      SELECT TAX_LINE_ID,
             INTERNAL_ORGANIZATION_ID,
             APPLICATION_ID,
             ENTITY_CODE,
             EVENT_CLASS_CODE,
             EVENT_TYPE_CODE,
             TRX_ID,
             TRX_LINE_ID,
             TRX_LEVEL_TYPE,
             TRX_LINE_NUMBER,
             DOC_EVENT_STATUS,
             TAX_EVENT_CLASS_CODE,
             TAX_EVENT_TYPE_CODE,
             TAX_LINE_NUMBER,
             CONTENT_OWNER_ID,
             TAX_REGIME_ID,
             TAX_REGIME_CODE,
             TAX_ID,
             TAX,
             TAX_STATUS_ID,
             TAX_STATUS_CODE,
             TAX_RATE_ID,
             TAX_RATE_CODE,
             TAX_RATE,
             TAX_RATE_TYPE,
             TAX_APPORTIONMENT_LINE_NUMBER,
             TRX_ID_LEVEL2,
             TRX_ID_LEVEL3,
             TRX_ID_LEVEL4,
             TRX_ID_LEVEL5,
             TRX_ID_LEVEL6,
             TRX_USER_KEY_LEVEL1,
             TRX_USER_KEY_LEVEL2,
             TRX_USER_KEY_LEVEL3,
             TRX_USER_KEY_LEVEL4,
             TRX_USER_KEY_LEVEL5,
             TRX_USER_KEY_LEVEL6,
             MRC_TAX_LINE_FLAG,
             MRC_LINK_TO_TAX_LINE_ID,
             LEDGER_ID,
             ESTABLISHMENT_ID,
             LEGAL_ENTITY_ID,
             HQ_ESTB_REG_NUMBER,
             HQ_ESTB_PARTY_TAX_PROF_ID,
             CURRENCY_CONVERSION_DATE,
             CURRENCY_CONVERSION_TYPE,
             CURRENCY_CONVERSION_RATE,
             TAX_CURRENCY_CONVERSION_DATE,
             TAX_CURRENCY_CONVERSION_TYPE,
             TAX_CURRENCY_CONVERSION_RATE,
             TRX_CURRENCY_CODE,
             MINIMUM_ACCOUNTABLE_UNIT,
             PRECISION,
             TRX_NUMBER,
             TRX_DATE,
             UNIT_PRICE,
             LINE_AMT,
             TRX_LINE_QUANTITY,
             TAX_BASE_MODIFIER_RATE,
             REF_DOC_APPLICATION_ID,
             REF_DOC_ENTITY_CODE,
             REF_DOC_EVENT_CLASS_CODE,
             REF_DOC_TRX_ID,
             REF_DOC_TRX_LEVEL_TYPE,
             REF_DOC_LINE_ID,
             REF_DOC_LINE_QUANTITY,
             OTHER_DOC_LINE_AMT,
             OTHER_DOC_LINE_TAX_AMT,
             OTHER_DOC_LINE_TAXABLE_AMT,
             UNROUNDED_TAXABLE_AMT,
             UNROUNDED_TAX_AMT,
             RELATED_DOC_APPLICATION_ID,
             RELATED_DOC_ENTITY_CODE,
             RELATED_DOC_EVENT_CLASS_CODE,
             RELATED_DOC_TRX_ID,
             RELATED_DOC_TRX_LEVEL_TYPE,
             RELATED_DOC_NUMBER,
             RELATED_DOC_DATE,
             APPLIED_FROM_APPLICATION_ID,
             APPLIED_FROM_EVENT_CLASS_CODE,
             APPLIED_FROM_ENTITY_CODE,
             APPLIED_FROM_TRX_ID,
             APPLIED_FROM_TRX_LEVEL_TYPE,
             APPLIED_FROM_LINE_ID,
             APPLIED_FROM_TRX_NUMBER,
             ADJUSTED_DOC_APPLICATION_ID,
             ADJUSTED_DOC_ENTITY_CODE,
             ADJUSTED_DOC_EVENT_CLASS_CODE,
             ADJUSTED_DOC_TRX_ID,
             ADJUSTED_DOC_TRX_LEVEL_TYPE,
             ADJUSTED_DOC_LINE_ID,
             ADJUSTED_DOC_NUMBER,
             ADJUSTED_DOC_DATE,
             APPLIED_TO_APPLICATION_ID,
             APPLIED_TO_EVENT_CLASS_CODE,
             APPLIED_TO_ENTITY_CODE,
             APPLIED_TO_TRX_ID,
             APPLIED_TO_TRX_LEVEL_TYPE,
             APPLIED_TO_LINE_ID,
             SUMMARY_TAX_LINE_ID,
             OFFSET_LINK_TO_TAX_LINE_ID,
             OFFSET_FLAG,
             PROCESS_FOR_RECOVERY_FLAG,
             TAX_JURISDICTION_ID,
             TAX_JURISDICTION_CODE,
             PLACE_OF_SUPPLY,
             PLACE_OF_SUPPLY_TYPE_CODE,
             PLACE_OF_SUPPLY_RESULT_ID,
             TAX_DATE_RULE_ID,
             TAX_DATE,
             TAX_DETERMINE_DATE,
             TAX_POINT_DATE,
             TRX_LINE_DATE,
             TAX_TYPE_CODE,
             TAX_CODE,
             TAX_REGISTRATION_ID,
             TAX_REGISTRATION_NUMBER,
             REGISTRATION_PARTY_TYPE,
             ROUNDING_LEVEL_CODE,
             ROUNDING_RULE_CODE,
             ROUNDING_LVL_PARTY_TAX_PROF_ID,
             ROUNDING_LVL_PARTY_TYPE,
             COMPOUNDING_TAX_FLAG,
             ORIG_TAX_STATUS_ID,
             ORIG_TAX_STATUS_CODE,
             ORIG_TAX_RATE_ID,
             ORIG_TAX_RATE_CODE,
             ORIG_TAX_RATE,
             ORIG_TAX_JURISDICTION_ID,
             ORIG_TAX_JURISDICTION_CODE,
             ORIG_TAX_AMT_INCLUDED_FLAG,
             ORIG_SELF_ASSESSED_FLAG,
             TAX_CURRENCY_CODE,
             TAX_AMT,
             TAX_AMT_TAX_CURR,
             TAX_AMT_FUNCL_CURR,
             TAXABLE_AMT,
             TAXABLE_AMT_TAX_CURR,
             TAXABLE_AMT_FUNCL_CURR,
             ORIG_TAXABLE_AMT,
             ORIG_TAXABLE_AMT_TAX_CURR,
             CAL_TAX_AMT,
             CAL_TAX_AMT_TAX_CURR,
             CAL_TAX_AMT_FUNCL_CURR,
             ORIG_TAX_AMT,
             ORIG_TAX_AMT_TAX_CURR,
             REC_TAX_AMT,
             REC_TAX_AMT_TAX_CURR,
             REC_TAX_AMT_FUNCL_CURR,
             NREC_TAX_AMT,
             NREC_TAX_AMT_TAX_CURR,
             NREC_TAX_AMT_FUNCL_CURR,
             TAX_EXEMPTION_ID,
             TAX_RATE_BEFORE_EXEMPTION,
             TAX_RATE_NAME_BEFORE_EXEMPTION,
             EXEMPT_RATE_MODIFIER,
             EXEMPT_CERTIFICATE_NUMBER,
             EXEMPT_REASON,
             EXEMPT_REASON_CODE,
             TAX_EXCEPTION_ID,
             TAX_RATE_BEFORE_EXCEPTION,
             TAX_RATE_NAME_BEFORE_EXCEPTION,
             EXCEPTION_RATE,
             TAX_APPORTIONMENT_FLAG,
             HISTORICAL_FLAG,
             TAXABLE_BASIS_FORMULA,
             TAX_CALCULATION_FORMULA,
             CANCEL_FLAG,
             PURGE_FLAG,
             DELETE_FLAG,
             TAX_AMT_INCLUDED_FLAG,
             SELF_ASSESSED_FLAG,
             OVERRIDDEN_FLAG,
             MANUALLY_ENTERED_FLAG,
             REPORTING_ONLY_FLAG,
             FREEZE_UNTIL_OVERRIDDEN_FLAG,
             COPIED_FROM_OTHER_DOC_FLAG,
             RECALC_REQUIRED_FLAG,
             SETTLEMENT_FLAG,
             ITEM_DIST_CHANGED_FLAG,
             ASSOCIATED_CHILD_FROZEN_FLAG,
             TAX_ONLY_LINE_FLAG,
             COMPOUNDING_DEP_TAX_FLAG,
             COMPOUNDING_TAX_MISS_FLAG,
             SYNC_WITH_PRVDR_FLAG,
             LAST_MANUAL_ENTRY,
             TAX_PROVIDER_ID,
             RECORD_TYPE_CODE,
             REPORTING_PERIOD_ID,
             LEGAL_JUSTIFICATION_TEXT1,
             LEGAL_JUSTIFICATION_TEXT2,
             LEGAL_JUSTIFICATION_TEXT3,
             LEGAL_MESSAGE_APPL_2,
             LEGAL_MESSAGE_STATUS,
             LEGAL_MESSAGE_RATE,
             LEGAL_MESSAGE_BASIS,
             LEGAL_MESSAGE_CALC,
             LEGAL_MESSAGE_THRESHOLD,
             LEGAL_MESSAGE_POS,
             LEGAL_MESSAGE_TRN,
             LEGAL_MESSAGE_EXMPT,
             LEGAL_MESSAGE_EXCPT,
             TAX_REGIME_TEMPLATE_ID,
             TAX_APPLICABILITY_RESULT_ID,
             DIRECT_RATE_RESULT_ID,
             STATUS_RESULT_ID,
             RATE_RESULT_ID,
             BASIS_RESULT_ID,
             THRESH_RESULT_ID,
             CALC_RESULT_ID,
             TAX_REG_NUM_DET_RESULT_ID,
             EVAL_EXMPT_RESULT_ID,
             EVAL_EXCPT_RESULT_ID,
             ENFORCE_FROM_NATURAL_ACCT_FLAG,
             TAX_HOLD_CODE,
             TAX_HOLD_RELEASED_CODE,
             PRD_TOTAL_TAX_AMT,
             PRD_TOTAL_TAX_AMT_TAX_CURR,
             PRD_TOTAL_TAX_AMT_FUNCL_CURR,
             TRX_LINE_INDEX,
             OFFSET_TAX_RATE_CODE,
             PRORATION_CODE,
             OTHER_DOC_SOURCE,
             INTERNAL_ORG_LOCATION_ID,
             LINE_ASSESSABLE_VALUE,
             CTRL_TOTAL_LINE_TX_AMT,
             APPLIED_TO_TRX_NUMBER,
             ATTRIBUTE_CATEGORY,
             ATTRIBUTE1,
             ATTRIBUTE2,
             ATTRIBUTE3,
             ATTRIBUTE4,
             ATTRIBUTE5,
             ATTRIBUTE6,
             ATTRIBUTE7,
             ATTRIBUTE8,
             ATTRIBUTE9,
             ATTRIBUTE10,
             ATTRIBUTE11,
             ATTRIBUTE12,
             ATTRIBUTE13,
             ATTRIBUTE14,
             ATTRIBUTE15,
             GLOBAL_ATTRIBUTE_CATEGORY,
             GLOBAL_ATTRIBUTE1,
             GLOBAL_ATTRIBUTE2,
             GLOBAL_ATTRIBUTE3,
             GLOBAL_ATTRIBUTE4,
             GLOBAL_ATTRIBUTE5,
             GLOBAL_ATTRIBUTE6,
             GLOBAL_ATTRIBUTE7,
             GLOBAL_ATTRIBUTE8,
             GLOBAL_ATTRIBUTE9,
             GLOBAL_ATTRIBUTE10,
             GLOBAL_ATTRIBUTE11,
             GLOBAL_ATTRIBUTE12,
             GLOBAL_ATTRIBUTE13,
             GLOBAL_ATTRIBUTE14,
             GLOBAL_ATTRIBUTE15,
             NUMERIC1,
             NUMERIC2,
             NUMERIC3,
             NUMERIC4,
             NUMERIC5,
             NUMERIC6,
             NUMERIC7,
             NUMERIC8,
             NUMERIC9,
             NUMERIC10,
             CHAR1,
             CHAR2,
             CHAR3,
             CHAR4,
             CHAR5,
             CHAR6,
             CHAR7,
             CHAR8,
             CHAR9,
             CHAR10,
             DATE1,
             DATE2,
             DATE3,
             DATE4,
             DATE5,
             DATE6,
             DATE7,
             DATE8,
             DATE9,
             DATE10,
             INTERFACE_ENTITY_CODE,
             INTERFACE_TAX_LINE_ID,
             TAXING_JURIS_GEOGRAPHY_ID,
             ADJUSTED_DOC_TAX_LINE_ID,
             OBJECT_VERSION_NUMBER,
             CREATED_BY,
             CREATION_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATE_LOGIN
    FROM ZX_LINES
    WHERE TAX_LINE_ID = p_tax_line_id;

    Recinfo lines_csr%ROWTYPE;

		l_transaction_rec ZX_API_PUB.transaction_rec_type;
		l_return_status  VARCHAR2(1000);

  BEGIN

    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_DETAIL_OVERRIDE_PKG.Lock_Row.BEGIN',
                     'ZX_TRL_DETAIL_OVERRIDE_PKG: Lock_Row (+)');
    END IF;

    OPEN lines_csr;
    FETCH lines_csr INTO Recinfo;

    IF (lines_csr%NOTFOUND) THEN
      CLOSE lines_csr;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    END IF;
    CLOSE lines_csr;

    IF ((Recinfo.TAX_LINE_ID = p_tax_line_id)  AND
        (Recinfo.INTERNAL_ORGANIZATION_ID = p_internal_organization_id) AND
        (Recinfo.APPLICATION_ID = p_application_id) AND
        (Recinfo.ENTITY_CODE = p_entity_code) AND
        (Recinfo.EVENT_CLASS_CODE = p_event_class_code) AND
        ((Recinfo.EVENT_TYPE_CODE = p_event_type_code) OR
         ((Recinfo.EVENT_TYPE_CODE IS NULL) AND
          (p_event_type_code IS NULL))) AND
        (Recinfo.TRX_ID = p_trx_id) AND
        (Recinfo.TRX_LINE_ID = p_trx_line_id) AND
        (Recinfo.TRX_LEVEL_TYPE = p_trx_level_type) AND
        ((Recinfo.TRX_LINE_NUMBER = p_TRX_LINE_NUMBER) OR
         ((Recinfo.TRX_LINE_NUMBER IS NULL) AND
          (p_TRX_LINE_NUMBER IS NULL))) AND
        ((Recinfo.DOC_EVENT_STATUS = p_doc_event_status) OR
         ((Recinfo.DOC_EVENT_STATUS IS NULL) AND
          (p_doc_event_status IS NULL))) AND
        ((Recinfo.TAX_EVENT_CLASS_CODE = p_TAX_EVENT_CLASS_CODE) OR
         ((Recinfo.TAX_EVENT_CLASS_CODE IS NULL) AND
          (p_TAX_EVENT_CLASS_CODE IS NULL))) AND
        ((Recinfo.TAX_EVENT_TYPE_CODE = p_TAX_EVENT_TYPE_CODE) OR
         ((Recinfo.TAX_EVENT_TYPE_CODE IS NULL) AND
          (p_TAX_EVENT_TYPE_CODE IS NULL))) AND
        (Recinfo.TAX_LINE_NUMBER = p_tax_line_number) AND
        ((Recinfo.CONTENT_OWNER_ID = p_CONTENT_OWNER_ID) OR
         ((Recinfo.CONTENT_OWNER_ID IS NULL) AND
          (p_CONTENT_OWNER_ID IS NULL))) AND
        ((Recinfo.TAX_REGIME_ID = p_tax_regime_id) OR
         ((Recinfo.TAX_REGIME_ID IS NULL) AND
          (p_tax_regime_id IS NULL))) AND
        ((Recinfo.TAX_REGIME_CODE = p_tax_regime_code) OR
         ((Recinfo.TAX_REGIME_CODE IS NULL) AND
          (p_tax_regime_code IS NULL))) AND
        ((Recinfo.TAX_ID = p_tax_id ) OR
         ((Recinfo.TAX_ID IS NULL) AND
          (p_tax_id  IS NULL))) AND
        ((Recinfo.TAX = p_tax ) OR
         ((Recinfo.TAX IS NULL) AND
          (p_tax IS NULL))) AND
        ((Recinfo.TAX_STATUS_ID = p_tax_status_id) OR
         ((Recinfo.TAX_STATUS_ID IS NULL) AND
          (p_tax_status_id IS NULL))) AND
        ((Recinfo.TAX_STATUS_CODE = p_tax_status_code) OR
         ((Recinfo.TAX_STATUS_CODE IS NULL) AND
          (p_tax_status_code IS NULL))) AND
        ((Recinfo.TAX_RATE_ID = p_tax_rate_id ) OR
         ((Recinfo.TAX_RATE_ID IS NULL) AND
          (p_tax_rate_id  IS NULL))) AND
        ((Recinfo.TAX_RATE_CODE = p_tax_rate_code) OR
         ((Recinfo.TAX_RATE_CODE IS NULL) AND
          (p_tax_rate_code IS NULL))) AND
        ((Recinfo.TAX_RATE = p_tax_rate) OR
         ((Recinfo.TAX_RATE IS NULL) AND
          (p_tax_rate IS NULL))) AND
        ((Recinfo.TAX_RATE_TYPE = p_tax_rate_type) OR
         ((Recinfo.TAX_RATE_TYPE IS NULL) AND
          (p_tax_rate_type IS NULL))) AND
        ((Recinfo.TAX_APPORTIONMENT_LINE_NUMBER = p_TAX_APPORTIONMENT_LINE_NUM) OR
         ((Recinfo.TAX_APPORTIONMENT_LINE_NUMBER IS NULL) AND
          (p_TAX_APPORTIONMENT_LINE_NUM IS NULL))) AND
        ((Recinfo.TRX_ID_LEVEL2 = p_TRX_ID_LEVEL2) OR
         ((Recinfo.TRX_ID_LEVEL2 IS NULL) AND
          (p_TRX_ID_LEVEL2 IS NULL))) AND
        ((Recinfo.TRX_ID_LEVEL3 = p_TRX_ID_LEVEL3) OR
         ((Recinfo.TRX_ID_LEVEL3 IS NULL) AND
          (p_TRX_ID_LEVEL3 IS NULL))) AND
        ((Recinfo.TRX_ID_LEVEL4 = p_TRX_ID_LEVEL4) OR
         ((Recinfo.TRX_ID_LEVEL4 IS NULL) AND
          (p_TRX_ID_LEVEL4 IS NULL))) AND
        ((Recinfo.TRX_ID_LEVEL5 = p_TRX_ID_LEVEL5) OR
         ((Recinfo.TRX_ID_LEVEL5 IS NULL) AND
          (p_TRX_ID_LEVEL5 IS NULL))) AND
        ((Recinfo.TRX_ID_LEVEL6 = p_TRX_ID_LEVEL6) OR
         ((Recinfo.TRX_ID_LEVEL6 IS NULL) AND
          (p_TRX_ID_LEVEL6 IS NULL))) AND
        ((Recinfo.TRX_USER_KEY_LEVEL1 = p_TRX_USER_KEY_LEVEL1) OR
         ((Recinfo.TRX_USER_KEY_LEVEL1 IS NULL) AND
          (p_TRX_USER_KEY_LEVEL1 IS NULL))) AND
        ((Recinfo.TRX_USER_KEY_LEVEL2 = p_TRX_USER_KEY_LEVEL2) OR
         ((Recinfo.TRX_USER_KEY_LEVEL2 IS NULL) AND
          (p_TRX_USER_KEY_LEVEL2 IS NULL))) AND
        ((Recinfo.TRX_USER_KEY_LEVEL3 = p_TRX_USER_KEY_LEVEL3) OR
         ((Recinfo.TRX_USER_KEY_LEVEL3 IS NULL) AND
          (p_TRX_USER_KEY_LEVEL3 IS NULL))) AND
        ((Recinfo.TRX_USER_KEY_LEVEL4 = p_TRX_USER_KEY_LEVEL4) OR
         ((Recinfo.TRX_USER_KEY_LEVEL4 IS NULL) AND
          (p_TRX_USER_KEY_LEVEL4 IS NULL))) AND
        ((Recinfo.TRX_USER_KEY_LEVEL5 = p_TRX_USER_KEY_LEVEL5) OR
         ((Recinfo.TRX_USER_KEY_LEVEL5 IS NULL) AND
          (p_TRX_USER_KEY_LEVEL5 IS NULL))) AND
        ((Recinfo.TRX_USER_KEY_LEVEL6 = p_TRX_USER_KEY_LEVEL6) OR
         ((Recinfo.TRX_USER_KEY_LEVEL6 IS NULL) AND
          (p_TRX_USER_KEY_LEVEL6 IS NULL))) AND
        ((Recinfo.MRC_TAX_LINE_FLAG = p_MRC_TAX_LINE_FLAG) OR
         ((Recinfo.MRC_TAX_LINE_FLAG IS NULL) AND
          (p_MRC_TAX_LINE_FLAG IS NULL))) AND
        ((Recinfo.MRC_LINK_TO_TAX_LINE_ID = p_MRC_LINK_TO_TAX_LINE_ID) OR
         ((Recinfo.MRC_LINK_TO_TAX_LINE_ID IS NULL) AND
          (p_MRC_LINK_TO_TAX_LINE_ID IS NULL))) AND
        ((Recinfo.LEDGER_ID = p_LEDGER_ID) OR
         ((Recinfo.LEDGER_ID IS NULL) AND
          (p_LEDGER_ID IS NULL))) AND
        ((Recinfo.ESTABLISHMENT_ID = p_ESTABLISHMENT_ID) OR
         ((Recinfo.ESTABLISHMENT_ID IS NULL) AND
          (p_ESTABLISHMENT_ID IS NULL))) AND
        ((Recinfo.LEGAL_ENTITY_ID = p_LEGAL_ENTITY_ID) OR
         ((Recinfo.LEGAL_ENTITY_ID IS NULL) AND
          (p_LEGAL_ENTITY_ID IS NULL))) AND
        ((Recinfo.HQ_ESTB_REG_NUMBER = p_HQ_ESTB_REG_NUMBER) OR
         ((Recinfo.HQ_ESTB_REG_NUMBER IS NULL) AND
          (p_HQ_ESTB_REG_NUMBER IS NULL))) AND
        ((Recinfo.HQ_ESTB_PARTY_TAX_PROF_ID = p_HQ_ESTB_PARTY_TAX_PROF_ID) OR
         ((Recinfo.HQ_ESTB_PARTY_TAX_PROF_ID IS NULL) AND
          (p_HQ_ESTB_PARTY_TAX_PROF_ID IS NULL))) AND
        ((Recinfo.CURRENCY_CONVERSION_DATE = p_CURRENCY_CONVERSION_DATE) OR
         ((Recinfo.CURRENCY_CONVERSION_DATE IS NULL) AND
          (p_CURRENCY_CONVERSION_DATE IS NULL))) AND
        ((Recinfo.CURRENCY_CONVERSION_TYPE = p_CURRENCY_CONVERSION_TYPE) OR
         ((Recinfo.CURRENCY_CONVERSION_TYPE IS NULL) AND
          (p_CURRENCY_CONVERSION_TYPE IS NULL))) AND
        ((Recinfo.CURRENCY_CONVERSION_RATE = p_CURRENCY_CONVERSION_RATE) OR
         ((Recinfo.CURRENCY_CONVERSION_RATE IS NULL) AND
          (p_CURRENCY_CONVERSION_RATE IS NULL))) AND
        ((Recinfo.TAX_CURRENCY_CONVERSION_DATE = p_TAX_CURR_CONVERSION_DATE) OR
         ((Recinfo.TAX_CURRENCY_CONVERSION_DATE IS NULL) AND
          (p_TAX_CURR_CONVERSION_DATE IS NULL))) AND
        ((Recinfo.TAX_CURRENCY_CONVERSION_TYPE = p_TAX_CURR_CONVERSION_TYPE) OR
         ((Recinfo.TAX_CURRENCY_CONVERSION_TYPE IS NULL) AND
          (p_TAX_CURR_CONVERSION_TYPE IS NULL))) AND
        ((Recinfo.TAX_CURRENCY_CONVERSION_RATE = p_TAX_CURR_CONVERSION_RATE) OR
         ((Recinfo.TAX_CURRENCY_CONVERSION_RATE IS NULL) AND
          (p_TAX_CURR_CONVERSION_RATE IS NULL))) AND
        ((Recinfo.TRX_CURRENCY_CODE = p_TRX_CURRENCY_CODE) OR
         ((Recinfo.TRX_CURRENCY_CODE IS NULL) AND
          (p_TRX_CURRENCY_CODE IS NULL))) AND
        ((Recinfo.MINIMUM_ACCOUNTABLE_UNIT = p_MINIMUM_ACCOUNTABLE_UNIT) OR
         ((Recinfo.MINIMUM_ACCOUNTABLE_UNIT IS NULL) AND
          (p_MINIMUM_ACCOUNTABLE_UNIT IS NULL))) AND
        ((Recinfo.PRECISION = p_PRECISION) OR
         ((Recinfo.PRECISION IS NULL) AND
          (p_PRECISION IS NULL))) AND
        ((Recinfo.TRX_NUMBER = p_trx_number) OR
         ((Recinfo.TRX_NUMBER IS NULL) AND
          (p_trx_number IS NULL))) AND
        ((Recinfo.TRX_DATE = p_TRX_DATE) OR
         ((Recinfo.TRX_DATE IS NULL) AND
          (p_TRX_DATE IS NULL))) AND
        ((Recinfo.UNIT_PRICE = p_UNIT_PRICE) OR
         ((Recinfo.UNIT_PRICE IS NULL) AND
          (p_UNIT_PRICE IS NULL))) AND
        ((Recinfo.LINE_AMT = p_LINE_AMT) OR
         ((Recinfo.LINE_AMT IS NULL) AND
          (p_LINE_AMT IS NULL))) AND
        ((Recinfo.TRX_LINE_QUANTITY = p_TRX_LINE_QUANTITY) OR
         ((Recinfo.TRX_LINE_QUANTITY IS NULL) AND
          (p_TRX_LINE_QUANTITY IS NULL))) AND
        ((Recinfo.TAX_BASE_MODIFIER_RATE = p_TAX_BASE_MODIFIER_RATE) OR
         ((Recinfo.TAX_BASE_MODIFIER_RATE IS NULL) AND
          (p_TAX_BASE_MODIFIER_RATE IS NULL))) AND
        ((Recinfo.REF_DOC_APPLICATION_ID = p_REF_DOC_APPLICATION_ID) OR
         ((Recinfo.REF_DOC_APPLICATION_ID IS NULL) AND
          (p_REF_DOC_APPLICATION_ID IS NULL))) AND
        ((Recinfo.REF_DOC_ENTITY_CODE = p_REF_DOC_ENTITY_CODE) OR
         ((Recinfo.REF_DOC_ENTITY_CODE IS NULL) AND
          (p_REF_DOC_ENTITY_CODE IS NULL))) AND
        ((Recinfo.REF_DOC_EVENT_CLASS_CODE = p_REF_DOC_EVENT_CLASS_CODE) OR
         ((Recinfo.REF_DOC_EVENT_CLASS_CODE IS NULL) AND
          (p_REF_DOC_EVENT_CLASS_CODE IS NULL))) AND
        ((Recinfo.REF_DOC_TRX_ID = p_REF_DOC_TRX_ID) OR
         ((Recinfo.REF_DOC_TRX_ID IS NULL) AND
          (p_REF_DOC_TRX_ID IS NULL))) AND
        ((Recinfo.REF_DOC_TRX_LEVEL_TYPE = p_REF_DOC_TRX_LEVEL_TYPE) OR
         ((Recinfo.REF_DOC_TRX_LEVEL_TYPE IS NULL) AND
          (p_REF_DOC_TRX_LEVEL_TYPE IS NULL))) AND
        ((Recinfo.REF_DOC_LINE_ID = p_REF_DOC_LINE_ID) OR
         ((Recinfo.REF_DOC_LINE_ID IS NULL) AND
          (p_REF_DOC_LINE_ID IS NULL))) AND
        ((Recinfo.REF_DOC_LINE_QUANTITY = p_REF_DOC_LINE_QUANTITY) OR
         ((Recinfo.REF_DOC_LINE_QUANTITY IS NULL) AND
          (p_REF_DOC_LINE_QUANTITY IS NULL))) AND
        ((Recinfo.OTHER_DOC_LINE_AMT = p_OTHER_DOC_LINE_AMT) OR
         ((Recinfo.OTHER_DOC_LINE_AMT IS NULL) AND
          (p_OTHER_DOC_LINE_AMT IS NULL))) AND
        ((Recinfo.OTHER_DOC_LINE_TAX_AMT = p_OTHER_DOC_LINE_TAX_AMT) OR
         ((Recinfo.OTHER_DOC_LINE_TAX_AMT IS NULL) AND
          (p_OTHER_DOC_LINE_TAX_AMT IS NULL))) AND
        ((Recinfo.OTHER_DOC_LINE_TAXABLE_AMT = p_OTHER_DOC_LINE_TAXABLE_AMT) OR
         ((Recinfo.OTHER_DOC_LINE_TAXABLE_AMT IS NULL) AND
          (p_OTHER_DOC_LINE_TAXABLE_AMT IS NULL))) AND
        ((Recinfo.UNROUNDED_TAXABLE_AMT = p_UNROUNDED_TAXABLE_AMT) OR
         ((Recinfo.UNROUNDED_TAXABLE_AMT IS NULL) AND
          (p_UNROUNDED_TAXABLE_AMT IS NULL))) AND
        ((Recinfo.UNROUNDED_TAX_AMT = p_unrounded_tax_amt) OR
         ((Recinfo.UNROUNDED_TAX_AMT IS NULL) AND
          (p_unrounded_tax_amt IS NULL))) AND
        ((Recinfo.RELATED_DOC_APPLICATION_ID = p_RELATED_DOC_APPLICATION_ID) OR
         ((Recinfo.RELATED_DOC_APPLICATION_ID IS NULL) AND
          (p_RELATED_DOC_APPLICATION_ID IS NULL))) AND
        ((Recinfo.RELATED_DOC_ENTITY_CODE = p_RELATED_DOC_ENTITY_CODE) OR
         ((Recinfo.RELATED_DOC_ENTITY_CODE IS NULL) AND
          (p_RELATED_DOC_ENTITY_CODE IS NULL))) AND
        ((Recinfo.RELATED_DOC_EVENT_CLASS_CODE = p_RELATED_DOC_EVT_CLASS_CODE) OR
         ((Recinfo.RELATED_DOC_EVENT_CLASS_CODE IS NULL) AND
          (p_RELATED_DOC_EVT_CLASS_CODE IS NULL))) AND
        ((Recinfo.RELATED_DOC_TRX_ID = p_RELATED_DOC_TRX_ID) OR
         ((Recinfo.RELATED_DOC_TRX_ID IS NULL) AND
          (p_RELATED_DOC_TRX_ID IS NULL))) AND
        ((Recinfo.RELATED_DOC_TRX_LEVEL_TYPE = p_RELATED_DOC_TRX_LEVEL_TYPE) OR
         ((Recinfo.RELATED_DOC_TRX_LEVEL_TYPE IS NULL) AND
          (p_RELATED_DOC_TRX_LEVEL_TYPE IS NULL))) AND
        ((Recinfo.RELATED_DOC_NUMBER = p_RELATED_DOC_NUMBER) OR
         ((Recinfo.RELATED_DOC_NUMBER IS NULL) AND
          (p_RELATED_DOC_NUMBER IS NULL))) AND
        ((Recinfo.RELATED_DOC_DATE = p_RELATED_DOC_DATE) OR
         ((Recinfo.RELATED_DOC_DATE IS NULL) AND
          (p_RELATED_DOC_DATE IS NULL))) AND
        ((Recinfo.APPLIED_FROM_APPLICATION_ID = p_APPLIED_FROM_APPL_ID) OR
         ((Recinfo.APPLIED_FROM_APPLICATION_ID IS NULL) AND
          (p_APPLIED_FROM_APPL_ID IS NULL))) AND
        ((Recinfo.APPLIED_FROM_EVENT_CLASS_CODE = p_APPLIED_FROM_EVT_CLSS_CODE) OR
         ((Recinfo.APPLIED_FROM_EVENT_CLASS_CODE IS NULL) AND
          (p_APPLIED_FROM_EVT_CLSS_CODE IS NULL))) AND
        ((Recinfo.APPLIED_FROM_ENTITY_CODE = p_APPLIED_FROM_ENTITY_CODE) OR
         ((Recinfo.APPLIED_FROM_ENTITY_CODE IS NULL) AND
          (p_APPLIED_FROM_ENTITY_CODE IS NULL))) AND
        ((Recinfo.APPLIED_FROM_TRX_ID = p_APPLIED_FROM_TRX_ID) OR
         ((Recinfo.APPLIED_FROM_TRX_ID IS NULL) AND
          (p_APPLIED_FROM_TRX_ID IS NULL))) AND
        ((Recinfo.APPLIED_FROM_TRX_LEVEL_TYPE = p_APPLIED_FROM_TRX_LEVEL_TYPE) OR
         ((Recinfo.APPLIED_FROM_TRX_LEVEL_TYPE IS NULL) AND
          (p_APPLIED_FROM_TRX_LEVEL_TYPE IS NULL))) AND
        ((Recinfo.APPLIED_FROM_LINE_ID = p_APPLIED_FROM_LINE_ID) OR
         ((Recinfo.APPLIED_FROM_LINE_ID IS NULL) AND
          (p_APPLIED_FROM_LINE_ID IS NULL))) AND
        ((Recinfo.APPLIED_FROM_TRX_NUMBER = p_APPLIED_FROM_TRX_NUMBER) OR
         ((Recinfo.APPLIED_FROM_TRX_NUMBER IS NULL) AND
          (p_APPLIED_FROM_TRX_NUMBER IS NULL))) AND
        ((Recinfo.ADJUSTED_DOC_APPLICATION_ID = P_ADJUSTED_DOC_APPLN_ID) OR
         ((Recinfo.ADJUSTED_DOC_APPLICATION_ID IS NULL) AND
          (P_ADJUSTED_DOC_APPLN_ID IS NULL))) AND
        ((Recinfo.ADJUSTED_DOC_ENTITY_CODE = p_ADJUSTED_DOC_ENTITY_CODE) OR
         ((Recinfo.ADJUSTED_DOC_ENTITY_CODE IS NULL) AND
          (p_ADJUSTED_DOC_ENTITY_CODE IS NULL))) AND
        ((Recinfo.ADJUSTED_DOC_EVENT_CLASS_CODE = P_ADJUSTED_DOC_EVT_CLSS_CODE) OR
         ((Recinfo.ADJUSTED_DOC_EVENT_CLASS_CODE IS NULL) AND
          (P_ADJUSTED_DOC_EVT_CLSS_CODE IS NULL))) AND
        ((Recinfo.ADJUSTED_DOC_TRX_ID = p_ADJUSTED_DOC_TRX_ID) OR
         ((Recinfo.ADJUSTED_DOC_TRX_ID IS NULL) AND
          (p_ADJUSTED_DOC_TRX_ID IS NULL))) AND
        ((Recinfo.ADJUSTED_DOC_TRX_LEVEL_TYPE = p_ADJUSTED_DOC_TRX_LEVEL_TYPE) OR
         ((Recinfo.ADJUSTED_DOC_TRX_LEVEL_TYPE IS NULL) AND
          (p_ADJUSTED_DOC_TRX_LEVEL_TYPE IS NULL))) AND
        ((Recinfo.ADJUSTED_DOC_LINE_ID = p_ADJUSTED_DOC_LINE_ID) OR
         ((Recinfo.ADJUSTED_DOC_LINE_ID IS NULL) AND
          (p_ADJUSTED_DOC_LINE_ID IS NULL))) AND
        ((Recinfo.ADJUSTED_DOC_NUMBER = p_ADJUSTED_DOC_NUMBER) OR
         ((Recinfo.ADJUSTED_DOC_NUMBER IS NULL) AND
          (p_ADJUSTED_DOC_NUMBER IS NULL))) AND
        ((Recinfo.ADJUSTED_DOC_DATE = p_ADJUSTED_DOC_DATE) OR
         ((Recinfo.ADJUSTED_DOC_DATE IS NULL) AND
          (p_ADJUSTED_DOC_DATE IS NULL))) AND
        ((Recinfo.APPLIED_TO_APPLICATION_ID = p_APPLIED_TO_APPLICATION_ID) OR
         ((Recinfo.APPLIED_TO_APPLICATION_ID IS NULL) AND
          (p_APPLIED_TO_APPLICATION_ID IS NULL))) AND
        ((Recinfo.APPLIED_TO_EVENT_CLASS_CODE = P_APPLIED_TO_EVT_CLASS_CODE) OR
         ((Recinfo.APPLIED_TO_EVENT_CLASS_CODE IS NULL) AND
          (P_APPLIED_TO_EVT_CLASS_CODE IS NULL))) AND
        ((Recinfo.APPLIED_TO_ENTITY_CODE = p_APPLIED_TO_ENTITY_CODE) OR
         ((Recinfo.APPLIED_TO_ENTITY_CODE IS NULL) AND
          (p_APPLIED_TO_ENTITY_CODE IS NULL))) AND
        ((Recinfo.APPLIED_TO_TRX_ID = p_APPLIED_TO_TRX_ID) OR
         ((Recinfo.APPLIED_TO_TRX_ID IS NULL) AND
          (p_APPLIED_TO_TRX_ID IS NULL))) AND
        ((Recinfo.APPLIED_TO_TRX_LEVEL_TYPE = p_APPLIED_TO_TRX_LEVEL_TYPE) OR
         ((Recinfo.APPLIED_TO_TRX_LEVEL_TYPE IS NULL) AND
          (p_APPLIED_TO_TRX_LEVEL_TYPE IS NULL))) AND
        ((Recinfo.APPLIED_TO_LINE_ID = p_applied_to_line_id) OR
         ((Recinfo.APPLIED_TO_LINE_ID IS NULL) AND
          (p_applied_to_line_id IS NULL))) AND
        ((Recinfo.SUMMARY_TAX_LINE_ID = p_SUMMARY_TAX_LINE_ID) OR
         ((Recinfo.SUMMARY_TAX_LINE_ID IS NULL) AND
          (p_SUMMARY_TAX_LINE_ID IS NULL))) AND
        ((Recinfo.OFFSET_LINK_TO_TAX_LINE_ID = p_OFFSET_LINK_TO_TAX_LINE_ID) OR
         ((Recinfo.OFFSET_LINK_TO_TAX_LINE_ID IS NULL) AND
          (p_OFFSET_LINK_TO_TAX_LINE_ID IS NULL))) AND
        (nvl(Recinfo.OFFSET_FLAG,'N') = NVL(p_offset_flag, 'N')) AND
        (nvl(Recinfo.PROCESS_FOR_RECOVERY_FLAG,'N') = NVL(p_process_for_recovery_flag, 'N')) AND
        ((Recinfo.TAX_JURISDICTION_ID = p_tax_jurisdiction_id) OR
         ((Recinfo.TAX_JURISDICTION_ID IS NULL) AND
          (p_tax_jurisdiction_id IS NULL))) AND
        ((Recinfo.TAX_JURISDICTION_CODE = p_tax_jurisdiction_code) OR
         ((Recinfo.TAX_JURISDICTION_CODE IS NULL) AND
          (p_tax_jurisdiction_code IS NULL))) AND
        ((Recinfo.PLACE_OF_SUPPLY = p_PLACE_OF_SUPPLY) OR
         ((Recinfo.PLACE_OF_SUPPLY IS NULL) AND
          (p_PLACE_OF_SUPPLY IS NULL))) AND
        ((Recinfo.PLACE_OF_SUPPLY_TYPE_CODE = p_Place_Of_Supply_Type_Code) OR
         ((Recinfo.PLACE_OF_SUPPLY_TYPE_CODE IS NULL) AND
          (p_place_of_supply_type_code IS NULL))) AND
        ((Recinfo.PLACE_OF_SUPPLY_RESULT_ID = p_PLACE_OF_SUPPLY_RESULT_ID) OR
         ((Recinfo.PLACE_OF_SUPPLY_RESULT_ID IS NULL) AND
          (p_place_of_supply_result_id IS NULL))) AND
        ((Recinfo.TAX_DATE_RULE_ID = p_TAX_DATE_RULE_ID) OR
         ((Recinfo.TAX_DATE_RULE_ID IS NULL) AND
          (p_TAX_DATE_RULE_ID IS NULL))) AND
        ((Recinfo.TAX_DATE = p_TAX_DATE) OR
         ((Recinfo.TAX_DATE IS NULL) AND
          (p_TAX_DATE IS NULL)))  AND
        ((Recinfo.TAX_DETERMINE_DATE = p_tax_determine_date) OR
         ((Recinfo.TAX_DETERMINE_DATE IS NULL) AND
          (p_tax_determine_date IS NULL))) AND
        ((Recinfo.TAX_POINT_DATE = p_TAX_POINT_DATE) OR
         ((Recinfo.TAX_POINT_DATE IS NULL) AND
          (p_TAX_POINT_DATE IS NULL))) AND
        ((Recinfo.TRX_LINE_DATE = p_TRX_LINE_DATE) OR
         ((Recinfo.TRX_LINE_DATE IS NULL) AND
          (p_TRX_LINE_DATE IS NULL))) AND
        ((Recinfo.TAX_TYPE_CODE = p_TAX_TYPE_CODE) OR
         ((Recinfo.TAX_TYPE_CODE IS NULL) AND
          (p_TAX_TYPE_CODE IS NULL))) AND
        ((Recinfo.TAX_CODE = p_TAX_CODE) OR
         ((Recinfo.TAX_CODE IS NULL) AND
          (p_TAX_CODE IS NULL)))  AND
        ((Recinfo.TAX_REGISTRATION_ID = p_tax_registration_id) OR
         ((Recinfo.TAX_REGISTRATION_ID IS NULL) AND
          (p_tax_registration_id IS NULL))) AND
        ((Recinfo.TAX_REGISTRATION_NUMBER = p_tax_registration_number) OR
         ((Recinfo.TAX_REGISTRATION_NUMBER IS NULL) AND
          (p_tax_registration_number IS NULL))) AND
        ((Recinfo.REGISTRATION_PARTY_TYPE = p_REGISTRATION_PARTY_TYPE) OR
         ((Recinfo.REGISTRATION_PARTY_TYPE IS NULL) AND
          (p_REGISTRATION_PARTY_TYPE IS NULL))) AND
        ((Recinfo.ROUNDING_LEVEL_CODE = p_Rounding_Level_Code) OR
         ((Recinfo.ROUNDING_LEVEL_CODE IS NULL) AND
          (p_Rounding_Level_Code IS NULL))) AND
        ((Recinfo.ROUNDING_RULE_CODE = p_Rounding_Rule_Code) OR
         ((Recinfo.ROUNDING_RULE_CODE IS NULL) AND
          (p_Rounding_Rule_Code IS NULL))) AND
        ((Recinfo.ROUNDING_LVL_PARTY_TAX_PROF_ID = P_RNDG_LVL_PARTY_TAX_PROF_ID) OR
         ((Recinfo.ROUNDING_LVL_PARTY_TAX_PROF_ID IS NULL) AND
          (P_RNDG_LVL_PARTY_TAX_PROF_ID IS NULL))) AND
        ((Recinfo.ROUNDING_LVL_PARTY_TYPE = p_ROUNDING_LVL_PARTY_TYPE) OR
         ((Recinfo.ROUNDING_LVL_PARTY_TYPE IS NULL) AND
          (p_ROUNDING_LVL_PARTY_TYPE IS NULL))) AND
        (nvl(Recinfo.COMPOUNDING_TAX_FLAG,'N') = NVL(p_Compounding_Tax_Flag, 'N')) AND
        ((Recinfo.ORIG_TAX_STATUS_ID = p_orig_tax_status_id) OR
         ((Recinfo.ORIG_TAX_STATUS_ID IS NULL) AND
          (p_orig_tax_status_id IS NULL))) AND
        ((Recinfo.ORIG_TAX_STATUS_CODE = p_orig_tax_status_code) OR
         ((Recinfo.ORIG_TAX_STATUS_CODE IS NULL) AND
          (p_orig_tax_status_code IS NULL))) AND
        ((Recinfo.ORIG_TAX_RATE_ID = p_orig_tax_rate_id) OR
         ((Recinfo.ORIG_TAX_RATE_ID IS NULL) AND
          (p_orig_tax_rate_id  IS NULL))) AND
        ((Recinfo.ORIG_TAX_RATE_CODE = p_orig_tax_rate_code) OR
         ((Recinfo.ORIG_TAX_RATE_CODE IS NULL) AND
          (p_orig_tax_rate_code  IS NULL)))  AND
        ((Recinfo.ORIG_TAX_RATE = p_orig_tax_rate) OR
         ((Recinfo.ORIG_TAX_RATE IS NULL) AND
          (p_orig_tax_rate IS NULL))) AND
        ((Recinfo.ORIG_TAX_JURISDICTION_ID = p_orig_tax_jurisdiction_id) OR
         ((Recinfo.ORIG_TAX_JURISDICTION_ID IS NULL) AND
          (p_orig_tax_jurisdiction_id IS NULL))) AND
        ((Recinfo.ORIG_TAX_JURISDICTION_CODE = p_orig_tax_jurisdiction_code) OR
         ((Recinfo.ORIG_TAX_JURISDICTION_CODE IS NULL) AND
          (p_orig_tax_jurisdiction_code IS NULL))) AND
        ((Recinfo.ORIG_TAX_AMT_INCLUDED_FLAG = p_orig_tax_amt_included_flag) OR
         ((Recinfo.ORIG_TAX_AMT_INCLUDED_FLAG IS NULL) AND
          (p_orig_tax_amt_included_flag IS NULL))) AND
        ((Recinfo.ORIG_SELF_ASSESSED_FLAG = p_orig_self_assessed_flag) OR
         ((Recinfo.ORIG_SELF_ASSESSED_FLAG IS NULL) AND
          (p_orig_self_assessed_flag IS NULL))) AND
        ((Recinfo.TAX_CURRENCY_CODE = p_TAX_CURRENCY_CODE) OR
         ((Recinfo.TAX_CURRENCY_CODE IS NULL) AND
          (p_TAX_CURRENCY_CODE IS NULL))) AND
        ((Recinfo.TAX_AMT = p_tax_amt) OR
         ((Recinfo.TAX_AMT IS NULL) AND
          (p_tax_amt IS NULL))) AND
        ((Recinfo.TAX_AMT_TAX_CURR = p_TAX_AMT_TAX_CURR) OR
         ((Recinfo.TAX_AMT_TAX_CURR IS NULL) AND
          (p_TAX_AMT_TAX_CURR IS NULL))) AND
        ((Recinfo.TAX_AMT_FUNCL_CURR = p_TAX_AMT_FUNCL_CURR) OR
         ((Recinfo.TAX_AMT_FUNCL_CURR IS NULL) AND
          (p_TAX_AMT_FUNCL_CURR IS NULL)))  AND   -- 99
        ((Recinfo.TAXABLE_AMT = p_taxable_amt) OR
         ((Recinfo.TAXABLE_AMT IS NULL) AND
          (p_taxable_amt IS NULL))) AND
        ((Recinfo.TAXABLE_AMT_TAX_CURR = p_TAXABLE_AMT_TAX_CURR) OR
         ((Recinfo.TAXABLE_AMT_TAX_CURR IS NULL) AND
          (p_TAXABLE_AMT_TAX_CURR IS NULL))) AND
        ((Recinfo.TAXABLE_AMT_FUNCL_CURR = p_TAXABLE_AMT_FUNCL_CURR) OR
         ((Recinfo.TAXABLE_AMT_FUNCL_CURR IS NULL) AND
          (p_TAXABLE_AMT_FUNCL_CURR IS NULL))) AND
        ((Recinfo.ORIG_TAXABLE_AMT = p_orig_taxable_amt) OR
         ((Recinfo.ORIG_TAXABLE_AMT IS NULL) AND
          (p_orig_taxable_amt IS NULL))) AND
        ((Recinfo.ORIG_TAXABLE_AMT_TAX_CURR = p_ORIG_TAXABLE_AMT_TAX_CURR) OR
         ((Recinfo.ORIG_TAXABLE_AMT_TAX_CURR IS NULL) AND
          (p_ORIG_TAXABLE_AMT_TAX_CURR IS NULL))) AND
        ((Recinfo.CAL_TAX_AMT = p_CAL_TAX_AMT) OR
         ((Recinfo.CAL_TAX_AMT IS NULL) AND
          (p_CAL_TAX_AMT IS NULL))) AND
        ((Recinfo.CAL_TAX_AMT_TAX_CURR = p_CAL_TAX_AMT_TAX_CURR) OR
         ((Recinfo.CAL_TAX_AMT_TAX_CURR IS NULL) AND
          (p_CAL_TAX_AMT_TAX_CURR IS NULL))) AND
        ((Recinfo.CAL_TAX_AMT_FUNCL_CURR = p_CAL_TAX_AMT_FUNCL_CURR) OR
         ((Recinfo.CAL_TAX_AMT_FUNCL_CURR IS NULL) AND
          (p_CAL_TAX_AMT_FUNCL_CURR IS NULL))) AND
        ((Recinfo.ORIG_TAX_AMT = p_ORIG_TAX_AMT) OR
         ((Recinfo.ORIG_TAX_AMT IS NULL) AND
          (p_ORIG_TAX_AMT IS NULL))) AND
        ((Recinfo.ORIG_TAX_AMT_TAX_CURR = p_ORIG_TAX_AMT_TAX_CURR) OR
         ((Recinfo.ORIG_TAX_AMT_TAX_CURR IS NULL) AND
          (p_ORIG_TAX_AMT_TAX_CURR IS NULL))) AND
        ((Recinfo.REC_TAX_AMT = p_rec_tax_amt) OR
         ((Recinfo.REC_TAX_AMT IS NULL) AND
          (p_rec_tax_amt IS NULL))) AND
        ((Recinfo.REC_TAX_AMT_TAX_CURR = p_REC_TAX_AMT_TAX_CURR) OR
         ((Recinfo.REC_TAX_AMT_TAX_CURR IS NULL) AND
          (p_REC_TAX_AMT_TAX_CURR IS NULL))) AND
        ((Recinfo.REC_TAX_AMT_FUNCL_CURR = p_REC_TAX_AMT_FUNCL_CURR) OR
         ((Recinfo.REC_TAX_AMT_FUNCL_CURR IS NULL) AND
          (p_REC_TAX_AMT_FUNCL_CURR IS NULL))) AND
        ((Recinfo.NREC_TAX_AMT = p_nrec_tax_amt) OR
         ((Recinfo.NREC_TAX_AMT IS NULL) AND
          (p_nrec_tax_amt IS NULL))) AND
        ((Recinfo.NREC_TAX_AMT_TAX_CURR = p_NREC_TAX_AMT_TAX_CURR) OR
         ((Recinfo.NREC_TAX_AMT_TAX_CURR IS NULL) AND
          (p_NREC_TAX_AMT_TAX_CURR IS NULL))) AND
        ((Recinfo.NREC_TAX_AMT_FUNCL_CURR = p_NREC_TAX_AMT_FUNCL_CURR) OR
         ((Recinfo.NREC_TAX_AMT_FUNCL_CURR IS NULL) AND
          (p_NREC_TAX_AMT_FUNCL_CURR IS NULL)))  AND  --99
        ((Recinfo.TAX_EXEMPTION_ID = p_tax_exemption_id) OR
         ((Recinfo.TAX_EXEMPTION_ID IS NULL) AND
          (p_tax_exemption_id IS NULL))) AND
        ((Recinfo.TAX_RATE_BEFORE_EXEMPTION = p_tax_rate_before_exemption ) OR
         ((Recinfo.TAX_RATE_BEFORE_EXEMPTION IS NULL) AND
          (p_tax_rate_before_exemption IS NULL))) AND
        ((Recinfo.TAX_RATE_NAME_BEFORE_EXEMPTION = p_tax_rate_name_before_exempt) OR
         ((Recinfo.TAX_RATE_NAME_BEFORE_EXEMPTION IS NULL) AND
          (p_tax_rate_name_before_exempt IS NULL))) AND
        ((Recinfo.EXEMPT_RATE_MODIFIER = p_exempt_rate_modifier) OR
         ((Recinfo.EXEMPT_RATE_MODIFIER IS NULL) AND
          (p_exempt_rate_modifier IS NULL))) AND
        ((Recinfo.EXEMPT_CERTIFICATE_NUMBER = p_exempt_certificate_number) OR
         ((Recinfo.EXEMPT_CERTIFICATE_NUMBER IS NULL) AND
          (p_exempt_certificate_number IS NULL))) AND
        ((Recinfo.EXEMPT_REASON = p_exempt_reason) OR
         ((Recinfo.EXEMPT_REASON IS NULL) AND
          (p_exempt_reason IS NULL))) AND
        ((Recinfo.EXEMPT_REASON_CODE = p_exempt_reason_code) OR
         ((Recinfo.EXEMPT_REASON_CODE IS NULL) AND
          (p_exempt_reason_code IS NULL))) AND
        ((Recinfo.TAX_EXCEPTION_ID = p_tax_exception_id) OR
         ((Recinfo.TAX_EXCEPTION_ID IS NULL) AND
          (p_tax_exception_id IS NULL))) AND
        ((Recinfo.TAX_RATE_BEFORE_EXCEPTION = p_tax_rate_before_exception) OR
         ((Recinfo.TAX_RATE_BEFORE_EXCEPTION IS NULL) AND
          (p_tax_rate_before_exception IS NULL))) AND
        ((Recinfo.TAX_RATE_NAME_BEFORE_EXCEPTION = p_tax_rate_name_before_except) OR
         ((Recinfo.TAX_RATE_NAME_BEFORE_EXCEPTION IS NULL) AND
          (p_tax_rate_name_before_except IS NULL))) AND
        ((Recinfo.EXCEPTION_RATE = p_exception_rate) OR
         ((Recinfo.EXCEPTION_RATE IS NULL) AND
          (p_exception_rate IS NULL))) AND
        ((Recinfo.TAX_APPORTIONMENT_FLAG = p_tax_apportionment_flag) OR
         ((Recinfo.TAX_APPORTIONMENT_FLAG IS NULL) AND
          (p_tax_apportionment_flag IS NULL))) AND
        (nvl(Recinfo.HISTORICAL_FLAG,'N') = NVL(p_historical_flag, 'N')) AND
        ((Recinfo.TAXABLE_BASIS_FORMULA = p_taxable_basis_formula) OR
         ((Recinfo.TAXABLE_BASIS_FORMULA IS NULL) AND
          (p_taxable_basis_formula IS NULL))) AND
        ((Recinfo.TAX_CALCULATION_FORMULA = p_tax_calculation_formula) OR
         ((Recinfo.TAX_CALCULATION_FORMULA IS NULL) AND
          (p_tax_calculation_formula IS NULL))) AND
        (nvl(Recinfo.CANCEL_FLAG,'N') = NVL(p_cancel_flag, 'N')) AND
        (nvl(Recinfo.PURGE_FLAG,'N') = NVL(p_Purge_Flag, 'N')) AND
        (nvl(Recinfo.DELETE_FLAG,'N') = NVL(p_delete_flag, 'N')) AND
        (nvl(Recinfo.TAX_AMT_INCLUDED_FLAG,'N') = NVL(p_tax_amt_included_flag, 'N')) AND
        (nvl(Recinfo.SELF_ASSESSED_FLAG,'N') = NVL(p_self_assessed_flag, 'N')) AND
        (nvl(Recinfo.OVERRIDDEN_FLAG,'N') = NVL(p_overridden_flag, 'N')) AND
        (nvl(Recinfo.MANUALLY_ENTERED_FLAG,'N') = NVL(p_manually_entered_flag, 'N')) AND
        (nvl(Recinfo.REPORTING_ONLY_FLAG,'N') = NVL(p_reporting_only_flag, 'N')) AND
        (nvl(Recinfo.FREEZE_UNTIL_OVERRIDDEN_FLAG,'N') = NVL(p_freeze_until_overriddn_flg, 'N')) AND
        (nvl(Recinfo.COPIED_FROM_OTHER_DOC_FLAG,'N') = NVL(p_copied_from_other_doc_flag, 'N')) AND
        (nvl(Recinfo.RECALC_REQUIRED_FLAG,'N') = NVL(p_recalc_required_flag, 'N')) AND
        ((Recinfo.SETTLEMENT_FLAG = p_settlement_flag) OR
         ((Recinfo.SETTLEMENT_FLAG IS NULL) AND
          (p_settlement_flag IS NULL)))  AND --99
        (nvl(Recinfo.ITEM_DIST_CHANGED_FLAG,'N') = NVL(p_item_dist_changed_flag, 'N')) AND
        (nvl(Recinfo.ASSOCIATED_CHILD_FROZEN_FLAG,'N') = NVL(p_assoc_children_frozen_flg, 'N'))  AND
        (nvl(Recinfo.TAX_ONLY_LINE_FLAG,'N') = NVL(p_tax_only_line_flag, 'N'))   AND
        (nvl(Recinfo.COMPOUNDING_DEP_TAX_FLAG,'N') = NVL(p_compounding_dep_tax_flag, 'N')) AND
        (nvl(Recinfo.COMPOUNDING_TAX_MISS_FLAG,'N') = NVL(p_compounding_tax_miss_flag, 'N'))  AND
        ((Recinfo.SYNC_WITH_PRVDR_FLAG = p_sync_with_prvdr_flag) OR
         ((Recinfo.SYNC_WITH_PRVDR_FLAG IS NULL) AND
          (p_sync_with_prvdr_flag IS NULL)))   AND  --99
        ((Recinfo.LAST_MANUAL_ENTRY = p_last_manual_entry) OR
         ((Recinfo.LAST_MANUAL_ENTRY IS NULL) AND
          (p_last_manual_entry IS NULL))) AND
        ((Recinfo.TAX_PROVIDER_ID = p_tax_provider_id) OR
         ((Recinfo.TAX_PROVIDER_ID IS NULL) AND
          (p_tax_provider_id IS NULL)))  AND  --99
        ((Recinfo.record_type_code = p_record_type_code) OR
         ((Recinfo.record_type_code IS NULL) AND
          (p_record_type_code IS NULL))) AND
        ((Recinfo.REPORTING_PERIOD_ID = p_REPORTING_PERIOD_ID) OR
         ((Recinfo.REPORTING_PERIOD_ID IS NULL) AND
          (p_REPORTING_PERIOD_ID IS NULL))) AND
        ((Recinfo.LEGAL_JUSTIFICATION_TEXT1 = p_LEGAL_JUSTIFICATION_TEXT1) OR
         ((Recinfo.LEGAL_JUSTIFICATION_TEXT1 IS NULL) AND
          (p_LEGAL_JUSTIFICATION_TEXT1 IS NULL))) AND
        ((Recinfo.LEGAL_JUSTIFICATION_TEXT2 = p_LEGAL_JUSTIFICATION_TEXT2) OR
         ((Recinfo.LEGAL_JUSTIFICATION_TEXT2 IS NULL) AND
          (p_LEGAL_JUSTIFICATION_TEXT2 IS NULL))) AND
        ((Recinfo.LEGAL_JUSTIFICATION_TEXT3 = p_LEGAL_JUSTIFICATION_TEXT3) OR
         ((Recinfo.LEGAL_JUSTIFICATION_TEXT3 IS NULL) AND
          (p_LEGAL_JUSTIFICATION_TEXT3 IS NULL))) AND
        ((Recinfo.LEGAL_MESSAGE_APPL_2 = p_LEGAL_MESSAGE_APPL_2) OR
         ((Recinfo.LEGAL_MESSAGE_APPL_2 IS NULL) AND
          (p_LEGAL_MESSAGE_APPL_2 IS NULL))) AND
        ((Recinfo.LEGAL_MESSAGE_STATUS = p_legal_message_status) OR
         ((Recinfo.LEGAL_MESSAGE_STATUS IS NULL) AND
          (p_legal_message_status IS NULL))) AND
        ((Recinfo.LEGAL_MESSAGE_RATE = p_legal_message_rate) OR
         ((Recinfo.LEGAL_MESSAGE_RATE IS NULL) AND
          (p_legal_message_rate IS NULL))) AND
        ((Recinfo.LEGAL_MESSAGE_BASIS = p_legal_message_basis) OR
         ((Recinfo.LEGAL_MESSAGE_BASIS IS NULL) AND
          (p_legal_message_basis IS NULL))) AND
        ((Recinfo.LEGAL_MESSAGE_CALC = p_LEGAL_MESSAGE_CALC) OR
         ((Recinfo.LEGAL_MESSAGE_CALC IS NULL) AND
          (p_LEGAL_MESSAGE_CALC IS NULL))) AND
        ((Recinfo.LEGAL_MESSAGE_THRESHOLD = p_LEGAL_MESSAGE_THRESHOLD) OR
         ((Recinfo.LEGAL_MESSAGE_THRESHOLD IS NULL) AND
          (p_LEGAL_MESSAGE_THRESHOLD IS NULL))) AND
        ((Recinfo.LEGAL_MESSAGE_POS = p_LEGAL_MESSAGE_POS) OR
         ((Recinfo.LEGAL_MESSAGE_POS IS NULL) AND
          (p_LEGAL_MESSAGE_POS IS NULL))) AND
        ((Recinfo.LEGAL_MESSAGE_TRN = p_LEGAL_MESSAGE_TRN) OR
         ((Recinfo.LEGAL_MESSAGE_TRN IS NULL) AND
          (p_LEGAL_MESSAGE_TRN IS NULL))) AND
        ((Recinfo.LEGAL_MESSAGE_EXMPT = p_LEGAL_MESSAGE_EXMPT) OR
         ((Recinfo.LEGAL_MESSAGE_EXMPT IS NULL) AND
          (p_LEGAL_MESSAGE_EXMPT IS NULL))) AND
        ((Recinfo.LEGAL_MESSAGE_EXCPT = p_LEGAL_MESSAGE_EXCPT) OR
         ((Recinfo.LEGAL_MESSAGE_EXCPT IS NULL) AND
          (p_LEGAL_MESSAGE_EXCPT IS NULL))) AND
        ((Recinfo.TAX_REGIME_TEMPLATE_ID = p_TAX_REGIME_TEMPLATE_ID) OR
         ((Recinfo.TAX_REGIME_TEMPLATE_ID IS NULL) AND
          (p_TAX_REGIME_TEMPLATE_ID IS NULL))) AND
        ((Recinfo.TAX_APPLICABILITY_RESULT_ID = P_TAX_APPLICABILITY_RESULT_ID) OR
         ((Recinfo.TAX_APPLICABILITY_RESULT_ID IS NULL) AND
          (P_TAX_APPLICABILITY_RESULT_ID IS NULL))) AND
        ((Recinfo.DIRECT_RATE_RESULT_ID = p_DIRECT_RATE_RESULT_ID) OR
         ((Recinfo.DIRECT_RATE_RESULT_ID IS NULL) AND
          (p_DIRECT_RATE_RESULT_ID IS NULL))) AND
        ((Recinfo.STATUS_RESULT_ID = p_STATUS_RESULT_ID) OR
         ((Recinfo.STATUS_RESULT_ID IS NULL) AND
          (p_STATUS_RESULT_ID IS NULL))) AND
        ((Recinfo.RATE_RESULT_ID = p_RATE_RESULT_ID) OR
         ((Recinfo.RATE_RESULT_ID IS NULL) AND
          (p_RATE_RESULT_ID IS NULL))) AND
        ((Recinfo.BASIS_RESULT_ID = p_BASIS_RESULT_ID) OR
         ((Recinfo.BASIS_RESULT_ID IS NULL) AND
          (p_BASIS_RESULT_ID IS NULL))) AND
        ((Recinfo.THRESH_RESULT_ID = p_THRESH_RESULT_ID) OR
         ((Recinfo.THRESH_RESULT_ID IS NULL) AND
          (p_THRESH_RESULT_ID IS NULL))) AND
        ((Recinfo.CALC_RESULT_ID = p_CALC_RESULT_ID) OR
         ((Recinfo.CALC_RESULT_ID IS NULL) AND
          (p_CALC_RESULT_ID IS NULL))) AND
        ((Recinfo.TAX_REG_NUM_DET_RESULT_ID = p_TAX_REG_NUM_DET_RESULT_ID) OR
         ((Recinfo.TAX_REG_NUM_DET_RESULT_ID IS NULL) AND
          (p_TAX_REG_NUM_DET_RESULT_ID IS NULL))) AND
        ((Recinfo.EVAL_EXMPT_RESULT_ID = p_EVAL_EXMPT_RESULT_ID) OR
         ((Recinfo.EVAL_EXMPT_RESULT_ID IS NULL) AND
          (p_EVAL_EXMPT_RESULT_ID IS NULL))) AND
        ((Recinfo.EVAL_EXCPT_RESULT_ID = p_EVAL_EXCPT_RESULT_ID) OR
         ((Recinfo.EVAL_EXCPT_RESULT_ID IS NULL) AND
          (p_EVAL_EXCPT_RESULT_ID IS NULL))) AND
        (nvl(Recinfo.Enforce_From_Natural_Acct_Flag,'N') = NVL(p_enforced_from_nat_acct_flg, 'N')) AND
        ((Recinfo.TAX_HOLD_CODE = p_TAX_HOLD_CODE) OR
         ((Recinfo.TAX_HOLD_CODE IS NULL) AND
          (p_tax_hold_code IS NULL))) AND
        ((Recinfo.TAX_HOLD_RELEASED_CODE = p_tax_hold_released_code) OR
         ((Recinfo.TAX_HOLD_RELEASED_CODE IS NULL) AND
          (p_tax_hold_released_code IS NULL))) AND
        ((Recinfo.PRD_TOTAL_TAX_AMT = p_prd_total_tax_amt) OR
         ((Recinfo.PRD_TOTAL_TAX_AMT IS NULL) AND
          (p_prd_total_tax_amt IS NULL))) AND
        ((Recinfo.PRD_TOTAL_TAX_AMT_TAX_CURR = p_prd_total_tax_amt_tax_curr) OR
         ((Recinfo.PRD_TOTAL_TAX_AMT_TAX_CURR IS NULL) AND
          (p_prd_total_tax_amt_tax_curr IS NULL))) AND
        ((Recinfo.PRD_TOTAL_TAX_AMT_FUNCL_CURR = p_prd_total_tax_amt_funcl_curr) OR
         ((Recinfo.PRD_TOTAL_TAX_AMT_FUNCL_CURR IS NULL) AND
          (p_prd_total_tax_amt_funcl_curr IS NULL))) AND
        ((Recinfo.TRX_LINE_INDEX = p_TRX_LINE_INDEX) OR
         ((Recinfo.TRX_LINE_INDEX IS NULL) AND
          (p_TRX_LINE_INDEX IS NULL))) AND
        ((Recinfo.OFFSET_TAX_RATE_CODE = p_OFFSET_TAX_RATE_CODE) OR
         ((Recinfo.OFFSET_TAX_RATE_CODE IS NULL) AND
          (p_OFFSET_TAX_RATE_CODE IS NULL))) AND
        ((Recinfo.PRORATION_CODE = p_PRORATION_CODE) OR
         ((Recinfo.PRORATION_CODE IS NULL) AND
          (p_PRORATION_CODE IS NULL))) AND
        ((Recinfo.OTHER_DOC_SOURCE = p_OTHER_DOC_SOURCE) OR
         ((Recinfo.OTHER_DOC_SOURCE IS NULL) AND
          (p_OTHER_DOC_SOURCE IS NULL))) AND
        ((Recinfo.INTERNAL_ORG_LOCATION_ID = p_INTERNAL_ORG_LOCATION_ID) OR
         ((Recinfo.INTERNAL_ORG_LOCATION_ID IS NULL) AND
          (p_INTERNAL_ORG_LOCATION_ID IS NULL))) AND
        ((Recinfo.LINE_ASSESSABLE_VALUE = p_LINE_ASSESSABLE_VALUE) OR
         ((Recinfo.LINE_ASSESSABLE_VALUE IS NULL) AND
          (p_LINE_ASSESSABLE_VALUE IS NULL))) AND
        ((Recinfo.CTRL_TOTAL_LINE_TX_AMT = p_ctrl_total_line_tx_amt) OR
         ((Recinfo.CTRL_TOTAL_LINE_TX_AMT IS NULL) AND
          (p_ctrl_total_line_tx_amt IS NULL))) AND
        ((Recinfo.APPLIED_TO_TRX_NUMBER = p_applied_to_trx_number) OR
         ((Recinfo.APPLIED_TO_TRX_NUMBER IS NULL) AND
          (p_applied_to_trx_number IS NULL))) AND
        ((Recinfo.ATTRIBUTE_CATEGORY = p_attribute_category) OR
         ((Recinfo.ATTRIBUTE_CATEGORY IS NULL) AND
          (p_attribute_category IS NULL))) AND
        ((Recinfo.ATTRIBUTE1 = p_attribute1) OR
         ((Recinfo.ATTRIBUTE1 IS NULL) AND
          (p_attribute1 IS NULL))) AND
        ((Recinfo.ATTRIBUTE2 = p_attribute2) OR
         ((Recinfo.ATTRIBUTE2 IS NULL) AND
          (p_attribute2 IS NULL))) AND
        ((Recinfo.ATTRIBUTE3 = p_attribute3) OR
         ((Recinfo.ATTRIBUTE3 IS NULL) AND
          (p_attribute3 IS NULL))) AND
        ((Recinfo.ATTRIBUTE4 = p_attribute4) OR
         ((Recinfo.ATTRIBUTE4 IS NULL) AND
          (p_attribute4 IS NULL))) AND
        ((Recinfo.ATTRIBUTE5 = p_attribute5) OR
         ((Recinfo.ATTRIBUTE5 IS NULL) AND
          (p_attribute5 IS NULL))) AND
        ((Recinfo.ATTRIBUTE6 = p_attribute6) OR
         ((Recinfo.ATTRIBUTE6 IS NULL) AND
          (p_attribute6 IS NULL))) AND
        ((Recinfo.ATTRIBUTE7 = p_attribute7) OR
         ((Recinfo.ATTRIBUTE7 IS NULL) AND
          (p_attribute7 IS NULL))) AND
        ((Recinfo.ATTRIBUTE8 = p_attribute8) OR
         ((Recinfo.ATTRIBUTE8 IS NULL) AND
          (p_attribute8 IS NULL))) AND
        ((Recinfo.ATTRIBUTE9 = p_attribute9) OR
         ((Recinfo.ATTRIBUTE9 IS NULL) AND
          (p_attribute9 IS NULL))) AND
        ((Recinfo.ATTRIBUTE10 = p_attribute10) OR
         ((Recinfo.ATTRIBUTE10 IS NULL) AND
          (p_attribute10 IS NULL))) AND
        ((Recinfo.ATTRIBUTE11 = p_attribute11) OR
         ((Recinfo.ATTRIBUTE11 IS NULL) AND
          (p_attribute11 IS NULL))) AND
        ((Recinfo.ATTRIBUTE12 = p_attribute12) OR
         ((Recinfo.ATTRIBUTE12 IS NULL) AND
          (p_attribute12 IS NULL))) AND
        ((Recinfo.ATTRIBUTE13 = p_attribute13) OR
         ((Recinfo.ATTRIBUTE13 IS NULL) AND
          (p_attribute13 IS NULL))) AND
        ((Recinfo.ATTRIBUTE14 = p_attribute14) OR
         ((Recinfo.ATTRIBUTE14 IS NULL) AND
          (p_attribute14 IS NULL))) AND
        ((Recinfo.ATTRIBUTE15 = p_attribute15) OR
         ((Recinfo.ATTRIBUTE15 IS NULL) AND
          (p_attribute15 IS NULL))) AND
        ((Recinfo.GLOBAL_ATTRIBUTE_CATEGORY = p_GLOBAL_ATTRIBUTE_category) OR
         ((Recinfo.GLOBAL_ATTRIBUTE_CATEGORY IS NULL) AND
          (p_GLOBAL_ATTRIBUTE_category IS NULL))) AND
        ((Recinfo.GLOBAL_ATTRIBUTE1 = p_GLOBAL_ATTRIBUTE1) OR
         ((Recinfo.GLOBAL_ATTRIBUTE1 IS NULL) AND
          (p_GLOBAL_ATTRIBUTE1 IS NULL))) AND
        ((Recinfo.GLOBAL_ATTRIBUTE2 = p_GLOBAL_ATTRIBUTE2) OR
         ((Recinfo.GLOBAL_ATTRIBUTE2 IS NULL) AND
          (p_GLOBAL_ATTRIBUTE2 IS NULL))) AND
        ((Recinfo.GLOBAL_ATTRIBUTE3 = p_GLOBAL_ATTRIBUTE3) OR
         ((Recinfo.GLOBAL_ATTRIBUTE3 IS NULL) AND
          (p_GLOBAL_ATTRIBUTE3 IS NULL))) AND
        ((Recinfo.GLOBAL_ATTRIBUTE4 = p_GLOBAL_ATTRIBUTE4) OR
         ((Recinfo.GLOBAL_ATTRIBUTE4 IS NULL) AND
          (p_GLOBAL_ATTRIBUTE4 IS NULL))) AND
        ((Recinfo.GLOBAL_ATTRIBUTE5 = p_GLOBAL_ATTRIBUTE5) OR
         ((Recinfo.GLOBAL_ATTRIBUTE5 IS NULL) AND
          (p_GLOBAL_ATTRIBUTE5 IS NULL))) AND
        ((Recinfo.GLOBAL_ATTRIBUTE6 = p_GLOBAL_ATTRIBUTE6) OR
         ((Recinfo.GLOBAL_ATTRIBUTE6 IS NULL) AND
          (p_GLOBAL_ATTRIBUTE6 IS NULL))) AND
        ((Recinfo.GLOBAL_ATTRIBUTE7 = p_GLOBAL_ATTRIBUTE7) OR
         ((Recinfo.GLOBAL_ATTRIBUTE7 IS NULL) AND
          (p_GLOBAL_ATTRIBUTE7 IS NULL))) AND
        ((Recinfo.GLOBAL_ATTRIBUTE8 = p_GLOBAL_ATTRIBUTE8) OR
         ((Recinfo.GLOBAL_ATTRIBUTE8 IS NULL) AND
          (p_GLOBAL_ATTRIBUTE8 IS NULL))) AND
        ((Recinfo.GLOBAL_ATTRIBUTE9 = p_GLOBAL_ATTRIBUTE9) OR
         ((Recinfo.GLOBAL_ATTRIBUTE9 IS NULL) AND
          (p_GLOBAL_ATTRIBUTE9 IS NULL))) AND
        ((Recinfo.GLOBAL_ATTRIBUTE10 = p_GLOBAL_ATTRIBUTE10) OR
         ((Recinfo.GLOBAL_ATTRIBUTE10 IS NULL) AND
          (p_GLOBAL_ATTRIBUTE10 IS NULL))) AND
        ((Recinfo.GLOBAL_ATTRIBUTE11 = p_GLOBAL_ATTRIBUTE11) OR
         ((Recinfo.GLOBAL_ATTRIBUTE11 IS NULL) AND
          (p_GLOBAL_ATTRIBUTE11 IS NULL))) AND
        ((Recinfo.GLOBAL_ATTRIBUTE12 = p_GLOBAL_ATTRIBUTE12) OR
         ((Recinfo.GLOBAL_ATTRIBUTE12 IS NULL) AND
          (p_GLOBAL_ATTRIBUTE12 IS NULL))) AND
        ((Recinfo.GLOBAL_ATTRIBUTE13 = p_GLOBAL_ATTRIBUTE13) OR
         ((Recinfo.GLOBAL_ATTRIBUTE13 IS NULL) AND
          (p_GLOBAL_ATTRIBUTE13 IS NULL))) AND
        ((Recinfo.GLOBAL_ATTRIBUTE14 = p_GLOBAL_ATTRIBUTE14) OR
         ((Recinfo.GLOBAL_ATTRIBUTE14 IS NULL) AND
          (p_GLOBAL_ATTRIBUTE14 IS NULL))) AND
        ((Recinfo.GLOBAL_ATTRIBUTE15 = p_GLOBAL_ATTRIBUTE15) OR
         ((Recinfo.GLOBAL_ATTRIBUTE15 IS NULL) AND
          (p_GLOBAL_ATTRIBUTE15 IS NULL))) AND
        ((Recinfo.NUMERIC1 = p_NUMERIC1) OR
         ((Recinfo.NUMERIC1 IS NULL) AND
          (p_NUMERIC1 IS NULL))) AND
        ((Recinfo.NUMERIC2 = p_NUMERIC2) OR
         ((Recinfo.NUMERIC2 IS NULL) AND
          (p_NUMERIC2 IS NULL))) AND
        ((Recinfo.NUMERIC3 = p_NUMERIC3) OR
         ((Recinfo.NUMERIC3 IS NULL) AND
          (p_NUMERIC3 IS NULL))) AND
        ((Recinfo.NUMERIC4 = p_NUMERIC4) OR
         ((Recinfo.NUMERIC4 IS NULL) AND
          (p_NUMERIC4 IS NULL))) AND
        ((Recinfo.NUMERIC5 = p_NUMERIC5) OR
         ((Recinfo.NUMERIC5 IS NULL) AND
          (p_NUMERIC5 IS NULL))) AND
        ((Recinfo.NUMERIC6 = p_NUMERIC6) OR
         ((Recinfo.NUMERIC6 IS NULL) AND
          (p_NUMERIC6 IS NULL))) AND
        ((Recinfo.NUMERIC7 = p_NUMERIC7) OR
         ((Recinfo.NUMERIC7 IS NULL) AND
          (p_NUMERIC7 IS NULL))) AND
        ((Recinfo.NUMERIC8 = p_NUMERIC8) OR
         ((Recinfo.NUMERIC8 IS NULL) AND
          (p_NUMERIC8 IS NULL))) AND
        ((Recinfo.NUMERIC9 = p_NUMERIC9) OR
         ((Recinfo.NUMERIC9 IS NULL) AND
          (p_NUMERIC9 IS NULL))) AND
        ((Recinfo.NUMERIC10 = p_NUMERIC10) OR
         ((Recinfo.NUMERIC10 IS NULL) AND
          (p_NUMERIC10 IS NULL))) AND
        ((Recinfo.CHAR1 = p_CHAR1) OR
         ((Recinfo.CHAR1 IS NULL) AND
          (p_CHAR1 IS NULL))) AND
        ((Recinfo.CHAR2 = p_CHAR2) OR
         ((Recinfo.CHAR2 IS NULL) AND
          (p_CHAR2 IS NULL))) AND
        ((Recinfo.CHAR3 = p_CHAR3) OR
         ((Recinfo.CHAR3 IS NULL) AND
          (p_CHAR3 IS NULL))) AND
        ((Recinfo.CHAR4 = p_CHAR4) OR
         ((Recinfo.CHAR4 IS NULL) AND
          (p_CHAR4 IS NULL))) AND
        ((Recinfo.CHAR5 = p_CHAR5) OR
         ((Recinfo.CHAR5 IS NULL) AND
          (p_CHAR5 IS NULL))) AND
        ((Recinfo.CHAR6 = p_CHAR6) OR
         ((Recinfo.CHAR6 IS NULL) AND
          (p_CHAR6 IS NULL))) AND
        ((Recinfo.CHAR7 = p_CHAR7) OR
         ((Recinfo.CHAR7 IS NULL) AND
          (p_CHAR7 IS NULL))) AND
        ((Recinfo.CHAR8 = p_CHAR8) OR
         ((Recinfo.CHAR8 IS NULL) AND
          (p_CHAR8 IS NULL))) AND
        ((Recinfo.CHAR9 = p_CHAR9) OR
         ((Recinfo.CHAR9 IS NULL) AND
          (p_CHAR9 IS NULL))) AND
        ((Recinfo.CHAR10 = p_CHAR10) OR
         ((Recinfo.CHAR10 IS NULL) AND
          (p_CHAR10 IS NULL))) AND
        ((Recinfo.DATE1 = p_DATE1) OR
         ((Recinfo.DATE1 IS NULL) AND
          (p_DATE1 IS NULL))) AND
        ((Recinfo.DATE2 = p_DATE2) OR
         ((Recinfo.DATE2 IS NULL) AND
          (p_DATE2 IS NULL))) AND
        ((Recinfo.DATE3 = p_DATE3) OR
         ((Recinfo.DATE3 IS NULL) AND
          (p_DATE3 IS NULL))) AND
        ((Recinfo.DATE4 = p_DATE4) OR
         ((Recinfo.DATE4 IS NULL) AND
          (p_DATE4 IS NULL))) AND
        ((Recinfo.DATE5 = p_DATE5) OR
         ((Recinfo.DATE5 IS NULL) AND
          (p_DATE5 IS NULL))) AND
        ((Recinfo.DATE6 = p_DATE6) OR
         ((Recinfo.DATE6 IS NULL) AND
          (p_DATE6 IS NULL))) AND
        ((Recinfo.DATE7 = p_DATE7) OR
         ((Recinfo.DATE7 IS NULL) AND
          (p_DATE7 IS NULL))) AND
        ((Recinfo.DATE8 = p_DATE8) OR
         ((Recinfo.DATE8 IS NULL) AND
          (p_DATE8 IS NULL))) AND
        ((Recinfo.DATE9 = p_DATE9) OR
         ((Recinfo.DATE9 IS NULL) AND
          (p_DATE9 IS NULL))) AND
        ((Recinfo.DATE10 = p_DATE10) OR
         ((Recinfo.DATE10 IS NULL) AND
          (p_DATE10 IS NULL))) AND

        ((Recinfo.INTERFACE_ENTITY_CODE = p_interface_entity_code ) OR
         ((Recinfo.INTERFACE_ENTITY_CODE IS NULL) AND
          (p_interface_entity_code IS NULL)))  AND
        ((Recinfo.INTERFACE_TAX_LINE_ID =  p_interface_tax_line_id) OR
         ((Recinfo.INTERFACE_TAX_LINE_ID IS NULL) AND
          (p_interface_tax_line_id IS NULL)))  AND
        ((Recinfo.TAXING_JURIS_GEOGRAPHY_ID = p_taxing_juris_geography_id) OR
         ((Recinfo.TAXING_JURIS_GEOGRAPHY_ID IS NULL) AND
          (p_taxing_juris_geography_id IS NULL)))  AND
        ((Recinfo.ADJUSTED_DOC_TAX_LINE_ID = p_adjusted_doc_tax_line_id) OR
         ((Recinfo.ADJUSTED_DOC_TAX_LINE_ID IS NULL) AND
          (p_adjusted_doc_tax_line_id IS NULL))) AND
        (Recinfo.OBJECT_VERSION_NUMBER = p_object_version_number)   AND
        (Recinfo.CREATED_BY = p_CREATED_BY) AND
        (Recinfo.CREATION_DATE = p_CREATION_DATE) AND
        (Recinfo.LAST_UPDATED_BY = p_last_updated_by) AND
        (Recinfo.LAST_UPDATE_DATE = p_last_update_date) AND
        ((Recinfo.LAST_UPDATE_LOGIN = p_last_update_login) OR
         ((Recinfo.LAST_UPDATE_LOGIN IS NULL) AND
          (p_last_update_login IS NULL))) ) THEN

			l_transaction_rec.APPLICATION_ID    :=  Recinfo.APPLICATION_ID;
			l_transaction_rec.ENTITY_CODE       :=  Recinfo.ENTITY_CODE;
			l_transaction_rec.EVENT_CLASS_CODE  :=  Recinfo.EVENT_CLASS_CODE;
			l_transaction_rec.EVENT_TYPE_CODE   :=  Recinfo.EVENT_TYPE_CODE;
			l_transaction_rec.TRX_ID            :=  Recinfo.TRX_ID;
			l_transaction_rec.INTERNAL_ORGANIZATION_ID  := Recinfo.INTERNAL_ORGANIZATION_ID;
			--l_transaction_rec.TAX_EVENT_CLASS_CODE      := Recinfo.TAX_EVENT_CLASS_CODE ;
			--l_transaction_rec.TAX_EVENT_TYPE_CODE       := Recinfo.TAX_EVENT_TYPE_CODE;
			--l_transaction_rec.DOC_EVENT_STATUS               :=  Recinfo.DOC_EVENT_STATUS ;

			ZX_LINES_DET_FACTORS_PKG.lock_line_det_factors (
		  					l_transaction_rec,
							  l_return_status      );
      RETURN;
    ELSE
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_DETAIL_OVERRIDE_PKG.Lock_Row.END',
                     'ZX_TRL_DETAIL_OVERRIDE_PKG: Lock_Row (-)');
    END IF;

  END Lock_Row;

  PROCEDURE Update_Row
       (--X_Rowid                      IN OUT NOCOPY VARCHAR2,
        p_tax_line_id                              NUMBER,
        p_internal_organization_id                 NUMBER,
        p_application_id                           NUMBER,
        p_entity_code                              VARCHAR2,
        p_event_class_code                         VARCHAR2,
        p_event_type_code                          VARCHAR2,
        p_trx_id                                   NUMBER,
        p_trx_line_id                              NUMBER,
        p_trx_level_type                           VARCHAR2,
        p_trx_line_number                          NUMBER,
        p_doc_event_status                         VARCHAR2,
        p_tax_event_class_code                     VARCHAR2,
        p_tax_event_type_code                      VARCHAR2,
        p_tax_line_number                          NUMBER,
        p_content_owner_id                         NUMBER,
        p_tax_regime_id                            NUMBER,
        p_tax_regime_code                          VARCHAR2,
        p_tax_id                                   NUMBER,
        p_tax                                      VARCHAR2,
        p_tax_status_id                            NUMBER,
        p_tax_status_code                          VARCHAR2,
        p_tax_rate_id                              NUMBER,
        p_tax_rate_code                            VARCHAR2,
        p_tax_rate                                 NUMBER,
        p_tax_rate_type                            VARCHAR2,
        p_tax_apportionment_line_num               NUMBER,--reduced in size tax_apportionment_line_number
        p_trx_id_level2                            NUMBER,
        p_trx_id_level3                            NUMBER,
        p_trx_id_level4                            NUMBER,
        p_trx_id_level5                            NUMBER,
        p_trx_id_level6                            NUMBER,
        p_trx_user_key_level1                      VARCHAR2,
        p_trx_user_key_level2                      VARCHAR2,
        p_trx_user_key_level3                      VARCHAR2,
        p_trx_user_key_level4                      VARCHAR2,
        p_trx_user_key_level5                      VARCHAR2,
        p_trx_user_key_level6                      VARCHAR2,
        p_mrc_tax_line_flag                        VARCHAR2,
        p_mrc_link_to_tax_line_id                  NUMBER,
        p_ledger_id                                NUMBER,
        p_establishment_id                         NUMBER,
        p_legal_entity_id                          NUMBER,
        p_hq_estb_reg_number                       VARCHAR2,
        p_hq_estb_party_tax_prof_id                NUMBER,
        p_currency_conversion_date                 DATE,
        p_currency_conversion_type                 VARCHAR2,
        p_currency_conversion_rate                 NUMBER,
        p_tax_curr_conversion_date                 DATE,--reduced in size tax_currency_conversion_date
        p_tax_curr_conversion_type                 VARCHAR2,--reduced in size p_tax_currency_conversion_type
        p_tax_curr_conversion_rate                 NUMBER,--reduced in size p_tax_currency_conversion_rate
        p_trx_currency_code                        VARCHAR2,
        p_reporting_currency_code                  VARCHAR2,
        p_minimum_accountable_unit                 NUMBER,
        p_precision                                NUMBER,
        p_trx_number                               VARCHAR2,
        p_trx_date                                 DATE,
        p_unit_price                               NUMBER,
        p_line_amt                                 NUMBER,
        p_trx_line_quantity                        NUMBER,
        p_tax_base_modifier_rate                   NUMBER,
        p_ref_doc_application_id                   NUMBER,
        p_ref_doc_entity_code                      VARCHAR2,
        p_ref_doc_event_class_code                 VARCHAR2,
        p_ref_doc_trx_id                           NUMBER,
        p_ref_doc_trx_level_type                   VARCHAR2,
        p_ref_doc_line_id                          NUMBER,
        p_ref_doc_line_quantity                    NUMBER,
        p_other_doc_line_amt                       NUMBER,
        p_other_doc_line_tax_amt                   NUMBER,
        p_other_doc_line_taxable_amt               NUMBER,
        p_unrounded_taxable_amt                    NUMBER,
        p_unrounded_tax_amt                        NUMBER,
        p_related_doc_application_id               NUMBER,
        p_related_doc_entity_code                  VARCHAR2,
        p_related_doc_evt_class_code               VARCHAR2,--reduced in size p_related_doc_event_class_code
        p_related_doc_trx_id                       NUMBER,
        p_related_doc_trx_level_type               VARCHAR2,
        p_related_doc_number                       VARCHAR2,
        p_related_doc_date                         DATE,
        p_applied_from_appl_id                     NUMBER,--reduced in size p_applied_from_application_id
        p_applied_from_evt_clss_code               VARCHAR2,--reduced in size p_applied_from_event_class_code
        p_applied_from_entity_code                 VARCHAR2,
        p_applied_from_trx_id                      NUMBER,
        p_applied_from_trx_level_type              VARCHAR2,
        p_applied_from_line_id                     NUMBER,
        p_applied_from_trx_number                  VARCHAR2,
        p_adjusted_doc_appln_id                    NUMBER,--reduced in size p_adjusted_doc_application_id
        p_adjusted_doc_entity_code                 VARCHAR2,
        p_adjusted_doc_evt_clss_code               VARCHAR2,--reduced in size p_adjusted_doc_event_class_code
        p_adjusted_doc_trx_id                      NUMBER,
        p_adjusted_doc_trx_level_type              VARCHAR2,
        p_adjusted_doc_line_id                     NUMBER,
        p_adjusted_doc_number                      VARCHAR2,
        p_adjusted_doc_date                        DATE,
        p_applied_to_application_id                NUMBER,
        p_applied_to_evt_class_code                VARCHAR2,--reduced in size p_applied_to_event_class_code
        p_applied_to_entity_code                   VARCHAR2,
        p_applied_to_trx_id                        NUMBER,
        p_applied_to_trx_level_type                VARCHAR2,
        p_applied_to_line_id                       NUMBER,
        p_summary_tax_line_id                      NUMBER,
        p_offset_link_to_tax_line_id               NUMBER,
        p_offset_flag                              VARCHAR2,
        p_process_for_recovery_flag                VARCHAR2,
        p_tax_jurisdiction_id                      NUMBER,
        p_tax_jurisdiction_code                    VARCHAR2,
        p_place_of_supply                          NUMBER,
        p_place_of_supply_type_code                VARCHAR2,
        p_place_of_supply_result_id                NUMBER,
        p_tax_date_rule_id                         NUMBER,
        p_tax_date                                 DATE,
        p_tax_determine_date                       DATE,
        p_tax_point_date                           DATE,
        p_trx_line_date                            DATE,
        p_tax_type_code                            VARCHAR2,
        p_tax_code                                 VARCHAR2,
        p_tax_registration_id                      NUMBER,
        p_tax_registration_number                  VARCHAR2,
        p_registration_party_type                  VARCHAR2,
        p_rounding_level_code                      VARCHAR2,
        p_rounding_rule_code                       VARCHAR2,
        p_rndg_lvl_party_tax_prof_id               NUMBER,--reduced in size p_rounding_lvl_party_tax_prof_id
        p_rounding_lvl_party_type                  VARCHAR2,
        p_compounding_tax_flag                     VARCHAR2,
        p_orig_tax_status_id                       NUMBER,
        p_orig_tax_status_code                     VARCHAR2,
        p_orig_tax_rate_id                         NUMBER,
        p_orig_tax_rate_code                       VARCHAR2,
        p_orig_tax_rate                            NUMBER,
        p_orig_tax_jurisdiction_id                 NUMBER,
        p_orig_tax_jurisdiction_code               VARCHAR2,
        p_orig_tax_amt_included_flag               VARCHAR2,
        p_orig_self_assessed_flag                  VARCHAR2,
        p_tax_currency_code                        VARCHAR2,
        p_tax_amt                                  NUMBER,
        p_tax_amt_tax_curr                         NUMBER,
        p_tax_amt_funcl_curr                       NUMBER,
        p_taxable_amt                              NUMBER,
        p_taxable_amt_tax_curr                     NUMBER,
        p_taxable_amt_funcl_curr                   NUMBER,
        p_orig_taxable_amt                         NUMBER,
        p_orig_taxable_amt_tax_curr                NUMBER,
        p_cal_tax_amt                              NUMBER,
        p_cal_tax_amt_tax_curr                     NUMBER,
        p_cal_tax_amt_funcl_curr                   NUMBER,
        p_orig_tax_amt                             NUMBER,
        p_orig_tax_amt_tax_curr                    NUMBER,
        p_rec_tax_amt                              NUMBER,
        p_rec_tax_amt_tax_curr                     NUMBER,
        p_rec_tax_amt_funcl_curr                   NUMBER,
        p_nrec_tax_amt                             NUMBER,
        p_nrec_tax_amt_tax_curr                    NUMBER,
        p_nrec_tax_amt_funcl_curr                  NUMBER,
        p_tax_exemption_id                         NUMBER,
        p_tax_rate_before_exemption                NUMBER,
        p_tax_rate_name_before_exempt              VARCHAR2,
        p_exempt_rate_modifier                     NUMBER,
        p_exempt_certificate_number                VARCHAR2,
        p_exempt_reason                            VARCHAR2,
        p_exempt_reason_code                       VARCHAR2,
        p_tax_exception_id                         NUMBER,
        p_tax_rate_before_exception                NUMBER,
        p_tax_rate_name_before_except              VARCHAR2,
        p_exception_rate                           NUMBER,
        p_tax_apportionment_flag                   VARCHAR2,
        p_historical_flag                          VARCHAR2,
        p_taxable_basis_formula                    VARCHAR2,
        p_tax_calculation_formula                  VARCHAR2,
        p_cancel_flag                              VARCHAR2,
        p_purge_flag                               VARCHAR2,
        p_delete_flag                              VARCHAR2,
        p_tax_amt_included_flag                    VARCHAR2,
        p_self_assessed_flag                       VARCHAR2,
        p_overridden_flag                          VARCHAR2,
        p_manually_entered_flag                    VARCHAR2,
        p_reporting_only_flag                      VARCHAR2,
        p_freeze_until_overriddn_flg               VARCHAR2,--reduced in size p_Freeze_Until_Overridden_Flag
        p_copied_from_other_doc_flag               VARCHAR2,
        p_recalc_required_flag                     VARCHAR2,
        p_settlement_flag                          VARCHAR2,
        p_item_dist_changed_flag                   VARCHAR2,
        p_assoc_children_frozen_flg                VARCHAR2,--reduced in size p_Associated_Child_Frozen_Flag
        p_tax_only_line_flag                       VARCHAR2,
        p_compounding_dep_tax_flag                 VARCHAR2,
        p_compounding_tax_miss_flag                VARCHAR2,
        p_sync_with_prvdr_flag                     VARCHAR2,
        p_last_manual_entry                        VARCHAR2,
        p_tax_provider_id                          NUMBER,
        p_record_type_code                         VARCHAR2,
        p_reporting_period_id                      NUMBER,
        p_legal_justification_text1                VARCHAR2,
        p_legal_justification_text2                VARCHAR2,
        p_legal_justification_text3                VARCHAR2,
        p_legal_message_appl_2                     NUMBER,
        p_legal_message_status                     NUMBER,
        p_legal_message_rate                       NUMBER,
        p_legal_message_basis                      NUMBER,
        p_legal_message_calc                       NUMBER,
        p_legal_message_threshold                  NUMBER,
        p_legal_message_pos                        NUMBER,
        p_legal_message_trn                        NUMBER,
        p_legal_message_exmpt                      NUMBER,
        p_legal_message_excpt                      NUMBER,
        p_tax_regime_template_id                   NUMBER,
        p_tax_applicability_result_id              NUMBER,--reduced in size p_tax_applicability_result_id
        p_direct_rate_result_id                    NUMBER,
        p_status_result_id                         NUMBER,
        p_rate_result_id                           NUMBER,
        p_basis_result_id                          NUMBER,
        p_thresh_result_id                         NUMBER,
        p_calc_result_id                           NUMBER,
        p_tax_reg_num_det_result_id                NUMBER,
        p_eval_exmpt_result_id                     NUMBER,
        p_eval_excpt_result_id                     NUMBER,
        p_enforced_from_nat_acct_flg               VARCHAR2,--reduced in size p_Enforce_From_Natural_Acct_Flag
        p_tax_hold_code                            NUMBER,
        p_tax_hold_released_code                   NUMBER,
        p_prd_total_tax_amt                        NUMBER,
        p_prd_total_tax_amt_tax_curr               NUMBER,
        p_prd_total_tax_amt_funcl_curr             NUMBER,
        p_trx_line_index                           VARCHAR2,
        p_offset_tax_rate_code                     VARCHAR2,
        p_proration_code                           VARCHAR2,
        p_other_doc_source                         VARCHAR2,
        p_internal_org_location_id                 NUMBER,
        p_line_assessable_value                    NUMBER,
        p_ctrl_total_line_tx_amt                   NUMBER,
        p_applied_to_trx_number                    VARCHAR2,
        p_attribute_category                       VARCHAR2,
        p_attribute1                               VARCHAR2,
        p_attribute2                               VARCHAR2,
        p_attribute3                               VARCHAR2,
        p_attribute4                               VARCHAR2,
        p_attribute5                               VARCHAR2,
        p_attribute6                               VARCHAR2,
        p_attribute7                               VARCHAR2,
        p_attribute8                               VARCHAR2,
        p_attribute9                               VARCHAR2,
        p_attribute10                              VARCHAR2,
        p_attribute11                              VARCHAR2,
        p_attribute12                              VARCHAR2,
        p_attribute13                              VARCHAR2,
        p_attribute14                              VARCHAR2,
        p_attribute15                              VARCHAR2,
        p_global_attribute_category                VARCHAR2,
        p_global_attribute1                        VARCHAR2,
        p_global_attribute2                        VARCHAR2,
        p_global_attribute3                        VARCHAR2,
        p_global_attribute4                        VARCHAR2,
        p_global_attribute5                        VARCHAR2,
        p_global_attribute6                        VARCHAR2,
        p_global_attribute7                        VARCHAR2,
        p_global_attribute8                        VARCHAR2,
        p_global_attribute9                        VARCHAR2,
        p_global_attribute10                       VARCHAR2,
        p_global_attribute11                       VARCHAR2,
        p_global_attribute12                       VARCHAR2,
        p_global_attribute13                       VARCHAR2,
        p_global_attribute14                       VARCHAR2,
        p_global_attribute15                       VARCHAR2,
        p_numeric1                                 NUMBER,
        p_numeric2                                 NUMBER,
        p_numeric3                                 NUMBER,
        p_numeric4                                 NUMBER,
        p_numeric5                                 NUMBER,
        p_numeric6                                 NUMBER,
        p_numeric7                                 NUMBER,
        p_numeric8                                 NUMBER,
        p_numeric9                                 NUMBER,
        p_numeric10                                NUMBER,
        p_char1                                    VARCHAR2,
        p_char2                                    VARCHAR2,
        p_char3                                    VARCHAR2,
        p_char4                                    VARCHAR2,
        p_char5                                    VARCHAR2,
        p_char6                                    VARCHAR2,
        p_char7                                    VARCHAR2,
        p_char8                                    VARCHAR2,
        p_char9                                    VARCHAR2,
        p_char10                                   VARCHAR2,
        p_date1                                    DATE,
        p_date2                                    DATE,
        p_date3                                    DATE,
        p_date4                                    DATE,
        p_date5                                    DATE,
        p_date6                                    DATE,
        p_date7                                    DATE,
        p_date8                                    DATE,
        p_date9                                    DATE,
        p_date10                                   DATE,
        p_interface_entity_code                    VARCHAR2,
        p_interface_tax_line_id                    NUMBER,
        p_taxing_juris_geography_id                NUMBER,
        p_adjusted_doc_tax_line_id                 NUMBER,
        p_object_version_number                    NUMBER,
        --p_created_by                               NUMBER,
        --p_creation_date                            DATE,
        p_last_updated_by                          NUMBER,
        p_last_update_date                         DATE,
        p_last_update_login                        NUMBER) IS

    Cursor c_line (p_appln_id NUMBER,
                   p_entity_cd VARCHAR2,
                   p_event_cls_cd VARCHAR2,
                   p_transaction_id      NUMBER,
                   p_trx_ln_id NUMBER,
                   p_trx_lev_type VARCHAR2,
                   p_tax_ln_id NUMBER)
                   IS SELECT
                      tax_status_code,
                      tax_rate_id,
                      tax_rate_code,
                      tax_rate,
                      tax_jurisdiction_code,
                      ledger_id,
                      legal_entity_id,
                      establishment_id,
                      TRUNC(currency_conversion_date) currency_conversion_date,
                      currency_conversion_type,
                      currency_conversion_rate,
                      taxable_basis_formula,
                      tax_calculation_formula,
                      tax_amt_included_flag,
                      compounding_tax_flag,
                      self_assessed_flag,
                      reporting_only_flag,
                      copied_from_other_doc_flag,
                      record_type_code,
                      tax_provider_id,
                      historical_flag,
                      delete_flag,
                      overridden_flag,
                      manually_entered_flag,
                      tax_exemption_id,
                      tax_rate_before_exemption,
                      tax_rate_name_before_exemption,
                      exempt_rate_modifier,
                      exempt_certificate_number,
                      exempt_reason,
                      exempt_reason_code,
                      tax_rate_before_exception,
                      tax_rate_name_before_exception,
                      tax_exception_id,
                      exception_rate,
                      mrc_tax_line_flag,
                      tax_only_line_flag,
                      tax_apportionment_line_number,
                      tax_amt
                FROM zx_lines
                WHERE application_id = p_appln_id
                AND   entity_code = p_entity_cd
                AND   event_class_code = p_event_cls_cd
                AND   trx_id  = p_transaction_id
                AND   trx_line_id = p_trx_ln_id
                AND   trx_level_type = p_trx_lev_type
                AND   tax_line_id = p_tax_ln_id;

    CURSOR existing_summary_tax_line(l_tax_rate NUMBER) IS
    SELECT summary_tax_line_id
    FROM   zx_lines_summary
    WHERE  application_id = p_application_id
    AND    entity_code = p_entity_code
    AND    event_class_code = p_event_class_code
    AND    trx_id = p_trx_id
    AND    tax_status_code = p_tax_status_code
    AND    tax_rate_id = p_tax_rate_id
    AND    tax_rate_code = p_tax_rate_code
    AND    tax_rate = l_tax_rate
    AND    NVL(tax_jurisdiction_code, 'x') = NVL(p_tax_jurisdiction_code, 'x')
    AND    NVL(ledger_id, -999) = NVL(p_ledger_id, -999)
    AND    NVL(legal_entity_id, -999) = NVL(p_legal_entity_id, -999)
    AND    NVL(establishment_id, -999) = NVL(p_establishment_id, -999)
    AND    NVL(TRUNC(currency_conversion_date), DATE_DUMMY) = NVL(TRUNC(p_currency_conversion_date), DATE_DUMMY)
    AND    NVL(currency_conversion_type, 'x') = NVL(p_currency_conversion_type, 'x')
    AND    NVL(currency_conversion_rate, 1) = NVL(p_currency_conversion_rate,1)
    AND    NVL(taxable_basis_formula, 'x') = NVL(p_taxable_basis_formula, 'x')
    AND    NVL(tax_calculation_formula, 'x') = NVL(p_tax_calculation_formula,'x')
    AND    NVL(tax_amt_included_flag,'N') = NVL(p_tax_amt_included_flag,'N')
    AND    NVL(compounding_tax_flag,'N') = NVL(p_compounding_tax_flag,'N')
    AND    NVL(self_assessed_flag,'N') = NVL(p_self_assessed_flag,'N')
    AND    NVL(reporting_only_flag,'N') = NVL(p_reporting_only_flag,'N')
    -- AND NVL(copied_from_other_doc_flag,'N') = NVL(p_copied_from_other_doc_flag,'N')
    AND    NVL(record_type_code, 'x') = NVL(p_record_type_code, 'x')
    AND    NVL(tax_provider_id, -999) = NVL(p_tax_provider_id, -999)
    AND    NVL(historical_flag,'N') = NVL(p_historical_flag,'N')
    AND    NVL(delete_flag,'N') = NVL(p_delete_flag,'N')
    -- AND NVL(overridden_flag,'N') = NVL(p_overridden_flag,'N')
    AND    NVL(manually_entered_flag,'N') = NVL(p_manually_entered_flag,'N')
    AND    NVL(tax_exemption_id, -999) = NVL(p_tax_exemption_id, -999)
    -- AND NVL(tax_rate_before_exemption, -999) = NVL(p_tax_rate_before_exemption, -999)
    -- AND NVL(tax_rate_name_before_exemption, 'x') = NVL(p_tax_rate_name_before_exempt, 'x')
    -- AND NVL(exempt_rate_modifier, -999) = NVL(p_exempt_rate_modifier, -999)
    AND    NVL(exempt_certificate_number, 'x') = NVL(p_exempt_certificate_number, 'x')
    --AND  NVL(exempt_reason, 'x') = NVL(p_exempt_reason, 'x')
    AND    NVL(exempt_reason_code, 'x') = NVL(p_exempt_reason_code, 'x')
    -- AND NVL(tax_rate_before_exception, -999) = NVL(p_tax_rate_before_exception, -999)
    -- AND NVL(tax_rate_name_before_exception, 'x') = NVL(p_tax_rate_name_before_except, 'x')
    AND    NVL(tax_exception_id, -999) = NVL(p_tax_exception_id, -999)
    -- AND NVL(exception_rate, -999) = NVL(p_exception_rate, -999)
    AND    NVL(mrc_tax_line_flag,'N') = NVL(p_mrc_tax_line_flag,'N')
    AND    NVL(tax_only_line_flag,'N') = NVL(p_tax_only_line_flag,'N');

    l_tax_status_code              VARCHAR2(30);
    l_tax_rate                     NUMBER;
    l_tax_amt                      NUMBER;
    l_orig_tax_status_code         VARCHAR2(30);
    l_orig_tax_rate                NUMBER;
    l_orig_tax_amt                 NUMBER;
    l_orig_tax_jurisdiction_id     NUMBER;
    l_orig_tax_jurisdiction_code   NUMBER;
    l_self_assessed_flag           NUMBER;
    l_orig_self_assessed_flag      NUMBER;
    l_tax_amt_included_flag        NUMBER;
    l_orig_tax_amt_included_flag   NUMBER;
    l_return_status                VARCHAR2(1000);
    l_msg_count                    NUMBER;
    l_msg_data                     VARCHAR2(1000);
    l_new_tax_amt_included_flag    VARCHAR2(1);
    l_compounding_tax_flag         VARCHAR2(1);
    l_overridden_flag              VARCHAR2(1);
    l_process_for_recovery_flag    VARCHAR2(1);
    l_ctrl_ef_ov_cal_line_flag     VARCHAR2(1);
    l_tax_apportionment_line_num   NUMBER;
    l_tax_line_id                  NUMBER;
    l_offset_tax_line_id           NUMBER;
    l_offset_trx_line_id           NUMBER;
    l_tax_line_number              NUMBER;
    l_row_id                       VARCHAR2(100);
    l_same_line                    Boolean;
    l_existing_summary_tax_line_id          NUMBER;
    l_detail_tax_amt               NUMBER;
    l_allow_adhoc_tax_rate_flag    VARCHAR2(100);
    l_adj_for_adhoc_amt_code       VARCHAR2(100);
    l_tax_amt_incl_changed         varchar2(1);



  BEGIN

    l_same_line := TRUE;
    l_tax_amt_incl_changed := NVL(p_tax_amt_included_flag,'N');
    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_DETAIL_OVERRIDE_PKG.Update_Row.BEGIN',
                     'ZX_TRL_DETAIL_OVERRIDE_PKG: Update_Row (+)');
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_DETAIL_OVERRIDE_PKG.Insert_Row',
                     'p_application_id: '||p_application_id);
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_DETAIL_OVERRIDE_PKG.Insert_Row',
                     'p_entity_code: '||p_entity_code);
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_DETAIL_OVERRIDE_PKG.Insert_Row',
                     'p_event_class_code: '||p_event_class_code);
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_DETAIL_OVERRIDE_PKG.Update_Row',
                     'p_trx_id: '||to_char(p_trx_id));
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_DETAIL_OVERRIDE_PKG.Update_Row',
                     'p_trx_line_id: '||to_char(p_trx_line_id));
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_DETAIL_OVERRIDE_PKG.Insert_Row',
                     'p_trx_level_type: '||p_trx_level_type);
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_DETAIL_OVERRIDE_PKG.Insert_Row',
                     'p_tax_line_id: '||p_tax_line_id);
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_DETAIL_OVERRIDE_PKG.Update_Row',
                     'l_tax_amt_incl_changed: '||to_char(l_tax_amt_incl_changed));
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_DETAIL_OVERRIDE_PKG.Update_Row',
                     'p_compounding_tax_flag: '||p_compounding_tax_flag);
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_DETAIL_OVERRIDE_PKG.Update_Row',
                     'p_tax_amt_included_flag: '||p_tax_amt_included_flag);
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_DETAIL_OVERRIDE_PKG.Update_Row',
                     'p_recalc_required_flag: '||p_recalc_required_flag);
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_DETAIL_OVERRIDE_PKG.Update_Row',
                     'p_process_for_recovery_flag: '||p_process_for_recovery_flag);
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_DETAIL_OVERRIDE_PKG.Update_Row',
                     'p_assoc_children_frozen_flg: '||p_assoc_children_frozen_flg);
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_DETAIL_OVERRIDE_PKG.Insert_Row',
                     'p_tax_only_line_flag: '||p_tax_only_line_flag);
    END IF;

    l_tax_rate := p_tax_rate;

    BEGIN
      SELECT tax_amt
      INTO l_detail_tax_amt
      FROM zx_lines
      WHERE tax_line_id =  p_tax_line_id;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

    IF p_last_manual_entry = 'TAX_AMOUNT' AND
       p_tax_amt <> l_detail_tax_amt AND
       NVL(p_cancel_flag, 'N') <> 'Y'
    THEN
      BEGIN
        SELECT allow_adhoc_tax_rate_flag, adj_for_adhoc_amt_code
        INTO l_allow_adhoc_tax_rate_flag, l_adj_for_adhoc_amt_code
        FROM zx_rates_b
        WHERE tax_rate_id = p_tax_rate_id;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;

      IF NVL(l_allow_adhoc_tax_rate_flag,'N') = 'Y' AND
         l_adj_for_adhoc_amt_code = 'TAX_RATE'
      THEN
        IF p_taxable_amt <> 0 THEN
          l_tax_rate := round(p_tax_amt/p_taxable_amt*100, 6);   -- Bug 8217841
        END IF;
      END IF;

    END IF;

    -- new changes
    FOR rec IN existing_summary_tax_line(l_tax_rate) LOOP
     IF rec.summary_tax_line_id = p_summary_tax_line_id THEN
       l_existing_summary_tax_line_id := NULL;
       EXIT;
     ELSE
       l_existing_summary_tax_line_id := rec.summary_tax_line_id;
     END IF;
    END LOOP;

    -- new changes
    l_new_tax_amt_included_flag  := NVL(p_tax_amt_included_flag, 'N');
    l_compounding_tax_flag       := NVL(p_compounding_tax_flag, 'N');
    l_overridden_flag            := p_overridden_flag;
    l_process_for_recovery_flag  := NVL(p_process_for_recovery_flag, 'N');

    IF nvl(p_tax_only_line_flag,'N') = 'N' THEN
      IF nvl(p_assoc_children_frozen_flg,'N') = 'Y' THEN
        FOR rec IN c_line (p_application_id,
                           p_entity_code,
                           p_event_class_code,
                           p_trx_id,
                           p_trx_line_id,
                           p_trx_level_type,
                           p_tax_line_id)
        LOOP
         IF NVL(rec.tax_amt_included_flag,'N') <> NVL(p_tax_amt_included_flag,'N') THEN
            l_tax_amt_incl_changed := 'Y';
         END IF;

         IF ( rec.tax_status_code <> p_tax_status_code
           OR rec.tax_rate_id  <> p_tax_rate_id
           OR rec.tax_rate_code <> p_tax_rate_code
           OR rec.tax_rate <> l_tax_rate
           OR NVL(rec.tax_jurisdiction_code, 'x') <> NVL(p_tax_jurisdiction_code, 'x')
           OR NVL(rec.ledger_id, -999) <> NVL(p_ledger_id, -999)
           OR NVL(rec.legal_entity_id, -999) <> NVL(p_legal_entity_id, -999)
           OR NVL(rec.establishment_id, -999) <> NVL(p_establishment_id, -999)
           OR NVL(TRUNC(rec.currency_conversion_date),DATE_DUMMY) <> NVL(TRUNC(p_currency_conversion_date), DATE_DUMMY)
           OR NVL(rec.currency_conversion_type, 'x')  <> NVL(p_currency_conversion_type,'x')
           OR NVL(rec.currency_conversion_rate, 1) <> NVL(p_currency_conversion_rate, 1)
           OR NVL(rec.taxable_basis_formula,'x') <> NVL(p_taxable_basis_formula, 'x')
           OR NVL(rec.tax_calculation_formula, 'x') <> NVL(p_tax_calculation_formula, 'x')
           OR NVL(rec.tax_amt_included_flag,'N') <> NVL(p_tax_amt_included_flag,'N')
           OR NVL(rec.compounding_tax_flag,'N') <> NVL(p_compounding_tax_flag,'N')
           OR NVL(rec.self_assessed_flag,'N') <> NVL(p_self_assessed_flag,'N')
           OR NVL(rec.reporting_only_flag,'N') <> NVL(p_reporting_only_flag,'N')
        -- OR NVL(rec.copied_from_other_doc_flag,'N') <> NVL(p_copied_from_other_doc_flag,'N')
           OR NVL(rec.record_type_code,'x') <> NVL(p_record_type_code, 'x')
           OR NVL(rec.tax_provider_id, -999)  <> NVL(p_tax_provider_id, -999)
           OR NVL(rec.historical_flag,'N') <> NVL(p_historical_flag,'N')
           OR NVL(rec.delete_flag,'N') <> NVL(p_delete_flag,'N')
        -- OR NVL(rec.overridden_flag,'N') <> NVL(p_overridden_flag,'N')
           OR NVL(rec.manually_entered_flag,'N') <> NVL(p_manually_entered_flag,'N')
           OR NVL(rec.tax_exemption_id, -999) <> NVL(p_tax_exemption_id, -999)
        -- OR NVL(rec.tax_rate_before_exemption, -999) <> NVL(p_tax_rate_before_exemption, -999)
        -- OR NVL(rec.tax_rate_name_before_exemption, 'x') <> NVL(p_tax_rate_name_before_exempt, 'x')
        -- OR NVL(rec.exempt_rate_modifier, -999) <> NVL(p_exempt_rate_modifier, -999)
           OR NVL(rec.exempt_certificate_number,'x') <> NVL(p_exempt_certificate_number, 'x')
        -- OR NVL(rec.exempt_reason, 'x') <> NVL(p_exempt_reason, 'x')
           OR NVL(rec.exempt_reason_code,'x') <> NVL(p_exempt_reason_code, 'x')
        -- OR NVL(rec.tax_rate_before_exception, -999) <> NVL(p_tax_rate_before_exception, -999)
        -- OR NVL(rec.tax_rate_name_before_exception, 'x') <> NVL(p_tax_rate_name_before_except, 'x')
           OR NVL(rec.tax_exception_id, -999) <> NVL(p_tax_exception_id, -999)
        -- OR NVL(rec.exception_rate, -999) <> NVL(p_exception_rate, -999)
           OR NVL(rec.mrc_tax_line_flag,'N')  <> NVL(p_mrc_tax_line_flag,'N')
           OR NVL(rec.tax_only_line_flag,'N')  <> NVL(p_tax_only_line_flag,'N')
        -- OR (NVL(l_detail_tax_amt,-999999999)  <> NVL(p_tax_amt,-999999999)
        -- AND NVL(l_overridden_flag,'N')='N')
          )
          THEN

            IF (g_level_procedure >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_DETAIL_OVERRIDE_PKG.Update_Row',
                     'Inside summary tax line criteria changed');
            END IF;

            SELECT zx_lines_s.nextval into l_tax_line_id
            FROM dual;

            SELECT MAX(ABS(tax_apportionment_line_number)) + 1
            INTO l_tax_apportionment_line_num
            FROM zx_lines
            WHERE application_id = p_application_id
            AND entity_code = p_entity_code
            AND event_class_code = p_event_class_code
            AND trx_id = p_trx_id
            AND trx_line_id = p_trx_line_id;

            SELECT NVL(MAX(tax_line_number),0) + 1
            INTO l_tax_line_number
            FROM zx_lines
            WHERE application_id = p_application_id
            AND entity_code = p_entity_code
            AND event_class_code = p_event_class_code
            AND trx_id = p_trx_id
            AND trx_line_id = p_trx_line_id
            AND trx_level_type = p_trx_level_type;

            UPDATE ZX_LINES
            SET cancel_flag = 'Y',
                tax_amt = 0,
                tax_apportionment_line_number = -1*l_tax_apportionment_line_num,
                unrounded_tax_amt = 0,
                tax_amt_tax_curr = 0,
                tax_amt_funcl_curr = 0,
                process_for_recovery_flag = 'Y',
                legal_reporting_status = decode(legal_reporting_status, '111111111111111','000000000000000',legal_reporting_status)
            WHERE tax_line_id = p_tax_line_id;

            BEGIN
              select tax_line_id into l_offset_tax_line_id
              FROM zx_lines
              where application_id = p_application_id
              and entity_code = p_entity_code
              and event_class_code = p_event_class_code
              and offset_link_to_tax_line_id = p_tax_line_id
              and trx_id = p_trx_id --Bug 8920640
              and trx_level_type = p_trx_level_type;


              SELECT trx_line_id into l_offset_trx_line_id
              FROM zx_lines
              WHERE tax_line_id = l_offset_tax_line_id;

              SELECT MAX(ABS(tax_apportionment_line_number)) + 1
              INTO l_tax_apportionment_line_num
              FROM zx_lines
              WHERE application_id = p_application_id
              AND entity_code = p_entity_code
              AND event_class_code = p_event_class_code
              AND trx_id = p_trx_id
              AND trx_line_id = l_offset_trx_line_id;

              UPDATE ZX_LINES
              SET cancel_flag = 'Y',
                  tax_amt = 0,
                  tax_apportionment_line_number = -1*l_tax_apportionment_line_num,
                  unrounded_tax_amt = 0,
                  tax_amt_tax_curr = 0,
                  tax_amt_funcl_curr = 0,
                  process_for_recovery_flag = 'Y',
                  legal_reporting_status = decode(legal_reporting_status, '111111111111111','000000000000000',legal_reporting_status)
              WHERE tax_line_id = l_offset_tax_line_id;

            EXCEPTION
              WHEN others then
                NULL;
            END;

            l_same_line := FALSE;

            Insert_Row
            (l_row_id                      ,
             l_tax_line_id                ,
             p_internal_organization_id   ,
             p_application_id             ,
             p_entity_code                ,
             p_event_class_code           ,
             p_event_type_code            ,
             p_trx_id                     ,
             p_trx_line_id                ,
             p_trx_level_type             ,
             p_trx_line_number            ,
             p_doc_event_status           ,
             p_tax_event_class_code       ,
             p_tax_event_type_code        ,
             l_tax_line_number            ,
             p_content_owner_id           ,
             p_tax_regime_id              ,
             p_tax_regime_code            ,
             p_tax_id                     ,
             p_tax                        ,
             p_tax_status_id              ,
             p_tax_status_code            ,
             p_tax_rate_id                ,
             p_tax_rate_code              ,
             p_tax_rate                   ,
             p_tax_rate_type              ,
             rec.tax_apportionment_line_number ,--reduced in size tax_apportionment_line_number
             p_trx_id_level2              ,
             p_trx_id_level3              ,
             p_trx_id_level4              ,
             p_trx_id_level5              ,
             p_trx_id_level6              ,
             p_trx_user_key_level1        ,
             p_trx_user_key_level2        ,
             p_trx_user_key_level3        ,
             p_trx_user_key_level4        ,
             p_trx_user_key_level5        ,
             p_trx_user_key_level6        ,
             p_mrc_tax_line_flag          ,
             p_mrc_link_to_tax_line_id    ,
             p_ledger_id                  ,
             p_establishment_id           ,
             p_legal_entity_id            ,
             p_hq_estb_reg_number         ,
             p_hq_estb_party_tax_prof_id  ,
             p_currency_conversion_date                ,
             p_currency_conversion_type                 ,
             p_currency_conversion_rate                ,
             p_tax_curr_conversion_date                ,--reduced in size tax_currency_conversion_date
             p_tax_curr_conversion_type                 ,--reduced in size p_tax_currency_conversion_type
             p_tax_curr_conversion_rate                ,--reduced in size p_tax_currency_conversion_rate
             p_trx_currency_code                        ,
             p_reporting_currency_code                  ,
             p_minimum_accountable_unit                ,
             p_precision                               ,
             p_trx_number                               ,
             p_trx_date                                ,
             p_unit_price                              ,
             p_line_amt                                ,
             p_trx_line_quantity                       ,
             p_tax_base_modifier_rate                  ,
             p_ref_doc_application_id                  ,
             p_ref_doc_entity_code                      ,
             p_ref_doc_event_class_code                 ,
             p_ref_doc_trx_id                          ,
             p_ref_doc_trx_level_type                   ,
             p_ref_doc_line_id                         ,
             p_ref_doc_line_quantity                   ,
             p_other_doc_line_amt                      ,
             p_other_doc_line_tax_amt                  ,
             p_other_doc_line_taxable_amt              ,
             p_unrounded_taxable_amt                   ,
             p_unrounded_tax_amt                       ,
             p_related_doc_application_id              ,
             p_related_doc_entity_code                  ,
             p_related_doc_evt_class_code               ,--reduced in size p_related_doc_event_class_code
             p_related_doc_trx_id                      ,
             p_related_doc_trx_level_type               ,
             p_related_doc_number                       ,
             p_related_doc_date                        ,
             p_applied_from_appl_id                    ,--reduced in size p_applied_from_application_id
             p_applied_from_evt_clss_code               ,--reduced in size p_applied_from_event_class_code
             p_applied_from_entity_code                 ,
             p_applied_from_trx_id                     ,
             p_applied_from_trx_level_type              ,
             p_applied_from_line_id                    ,
             p_applied_from_trx_number                  ,
             p_adjusted_doc_appln_id                   ,--reduced in size p_adjusted_doc_application_id
             p_adjusted_doc_entity_code                 ,
             p_adjusted_doc_evt_clss_code               ,--reduced in size p_adjusted_doc_event_class_code
             p_adjusted_doc_trx_id                     ,
             p_adjusted_doc_trx_level_type              ,
             p_adjusted_doc_line_id                    ,
             p_adjusted_doc_number                      ,
             p_adjusted_doc_date                       ,
             p_applied_to_application_id               ,
             p_applied_to_evt_class_code                ,--reduced in size p_applied_to_event_class_code
             p_applied_to_entity_code                   ,
             p_applied_to_trx_id                       ,
             p_applied_to_trx_level_type                ,
             p_applied_to_line_id                      ,
             l_existing_summary_tax_line_id                     ,
             p_offset_link_to_tax_line_id              ,
             p_offset_flag                              ,
             p_process_for_recovery_flag                ,
             p_tax_jurisdiction_id                     ,
             p_tax_jurisdiction_code                    ,
             p_place_of_supply                         ,
             p_place_of_supply_type_code                ,
             p_place_of_supply_result_id               ,
             p_tax_date_rule_id                        ,
             p_tax_date                                ,
             p_tax_determine_date                      ,
             p_tax_point_date                          ,
             p_trx_line_date                           ,
             p_tax_type_code                            ,
             p_tax_code                                 ,
             p_tax_registration_id                     ,
             p_tax_registration_number                  ,
             p_registration_party_type                  ,
             p_rounding_level_code                      ,
             p_rounding_rule_code                       ,
             p_rndg_lvl_party_tax_prof_id              ,--reduced in size p_rounding_lvl_party_tax_prof_id
             p_rounding_lvl_party_type                  ,
             p_compounding_tax_flag                     ,
             p_orig_tax_status_id                      ,
             p_orig_tax_status_code                     ,
             p_orig_tax_rate_id                        ,
             p_orig_tax_rate_code                       ,
             p_orig_tax_rate                           ,
             p_orig_tax_jurisdiction_id                ,
             p_orig_tax_jurisdiction_code               ,
             p_orig_tax_amt_included_flag               ,
             p_orig_self_assessed_flag                  ,
             p_tax_currency_code                        ,
             p_tax_amt                                 ,
             p_tax_amt_tax_curr                        ,
             p_tax_amt_funcl_curr                      ,
             p_taxable_amt                             ,
             p_taxable_amt_tax_curr                    ,
             p_taxable_amt_funcl_curr                  ,
             p_orig_taxable_amt                        ,
             p_orig_taxable_amt_tax_curr               ,
             p_cal_tax_amt                             ,
             p_cal_tax_amt_tax_curr                    ,
             p_cal_tax_amt_funcl_curr                  ,
             p_orig_tax_amt                            ,
             p_orig_tax_amt_tax_curr                   ,
             p_rec_tax_amt                             ,
             p_rec_tax_amt_tax_curr                    ,
             p_rec_tax_amt_funcl_curr                  ,
             p_nrec_tax_amt                            ,
             p_nrec_tax_amt_tax_curr                   ,
             p_nrec_tax_amt_funcl_curr                 ,
             p_tax_exemption_id                        ,
             p_tax_rate_before_exemption               ,
             p_tax_rate_name_before_exempt              ,
             p_exempt_rate_modifier                    ,
             p_exempt_certificate_number                ,
             p_exempt_reason                            ,
             p_exempt_reason_code                       ,
             p_tax_exception_id                        ,
             p_tax_rate_before_exception               ,
             p_tax_rate_name_before_except              ,
             p_exception_rate                          ,
             p_tax_apportionment_flag                   ,
             p_historical_flag                          ,
             p_taxable_basis_formula                    ,
             p_tax_calculation_formula                  ,
             p_cancel_flag                              ,
             p_purge_flag                               ,
             p_delete_flag                              ,
             p_tax_amt_included_flag                    ,
             p_self_assessed_flag                       ,
             'C'                                        ,--p_overridden_flag,
             p_manually_entered_flag                    ,
             p_reporting_only_flag                      ,
             p_freeze_until_overriddn_flg               ,--reduced in size p_Freeze_Until_Overridden_Flag
             p_copied_from_other_doc_flag               ,
             p_recalc_required_flag                     ,
             p_settlement_flag                          ,
             p_item_dist_changed_flag                   ,
             NULL                                       ,--reduced in size p_Associated_Child_Frozen_Flag
             p_tax_only_line_flag                       ,
             p_compounding_dep_tax_flag                 ,
             p_compounding_tax_miss_flag                ,
             p_sync_with_prvdr_flag                     ,
             p_last_manual_entry                        ,
             p_tax_provider_id                         ,
             p_record_type_code                         ,
             p_reporting_period_id                     ,
             p_legal_justification_text1                ,
             p_legal_justification_text2                ,
             p_legal_justification_text3                ,
             p_legal_message_appl_2                    ,
             p_legal_message_status                    ,
             p_legal_message_rate                      ,
             p_legal_message_basis                     ,
             p_legal_message_calc                      ,
             p_legal_message_threshold                 ,
             p_legal_message_pos                       ,
             p_legal_message_trn                       ,
             p_legal_message_exmpt                     ,
             p_legal_message_excpt                     ,
             p_tax_regime_template_id                  ,
             p_tax_applicability_result_id             ,--reduced in size p_tax_applicability_result_id
             p_direct_rate_result_id                   ,
             p_status_result_id                        ,
             p_rate_result_id                          ,
             p_basis_result_id                         ,
             p_thresh_result_id                        ,
             p_calc_result_id                          ,
             p_tax_reg_num_det_result_id               ,
             p_eval_exmpt_result_id                    ,
             p_eval_excpt_result_id                    ,
             p_enforced_from_nat_acct_flg               ,--reduced in size p_Enforce_From_Natural_Acct_Flag
             p_tax_hold_code                           ,
             p_tax_hold_released_code                  ,
             p_prd_total_tax_amt                       ,
             p_prd_total_tax_amt_tax_curr              ,
             p_prd_total_tax_amt_funcl_curr            ,
             p_trx_line_index                           ,
             p_offset_tax_rate_code                     ,
             p_proration_code                           ,
             p_other_doc_source                         ,
             p_internal_org_location_id                ,
             p_line_assessable_value                   ,
             p_ctrl_total_line_tx_amt                  ,
             p_applied_to_trx_number                    ,
             NULL                                       , -- Bug 7117340 -- DFF ER -- p_attribute_category
             NULL                                       , -- Bug 7117340 -- DFF ER -- p_attribute1
             NULL                                       , -- Bug 7117340 -- DFF ER -- p_attribute2
             NULL                                       , -- Bug 7117340 -- DFF ER -- p_attribute3
             NULL                                       , -- Bug 7117340 -- DFF ER -- p_attribute4
             NULL                                       , -- Bug 7117340 -- DFF ER -- p_attribute5
             NULL                                       , -- Bug 7117340 -- DFF ER -- p_attribute6
             NULL                                       , -- Bug 7117340 -- DFF ER -- p_attribute7
             NULL                                       , -- Bug 7117340 -- DFF ER -- p_attribute8
             NULL                                       , -- Bug 7117340 -- DFF ER -- p_attribute9
             NULL                                       , -- Bug 7117340 -- DFF ER -- p_attribute10
             NULL                                       , -- Bug 7117340 -- DFF ER -- p_attribute11
             NULL                                       , -- Bug 7117340 -- DFF ER -- p_attribute12
             NULL                                       , -- Bug 7117340 -- DFF ER -- p_attribute13
             NULL                                       , -- Bug 7117340 -- DFF ER -- p_attribute14
             NULL                                       , -- Bug 7117340 -- DFF ER -- p_attribute15
             p_global_attribute_category                ,
             p_global_attribute1                        ,
             p_global_attribute2                        ,
             p_global_attribute3                        ,
             p_global_attribute4                        ,
             p_global_attribute5                        ,
             p_global_attribute6                        ,
             p_global_attribute7                        ,
             p_global_attribute8                        ,
             p_global_attribute9                        ,
             p_global_attribute10                       ,
             p_global_attribute11                       ,
             p_global_attribute12                       ,
             p_global_attribute13                       ,
             p_global_attribute14                       ,
             p_global_attribute15                       ,
             p_numeric1                                ,
             p_numeric2                                ,
             p_numeric3                                ,
             p_numeric4                                ,
             p_numeric5                                ,
             p_numeric6                                ,
             p_numeric7                                ,
             p_numeric8                                ,
             p_numeric9                                ,
             p_numeric10                               ,
             p_char1                                    ,
             p_char2                                    ,
             p_char3                                    ,
             p_char4                                    ,
             p_char5                                    ,
             p_char6                                    ,
             p_char7                                    ,
             p_char8                                    ,
             p_char9                                    ,
             p_char10                                   ,
             p_date1                                   ,
             p_date2                                   ,
             p_date3                                   ,
             p_date4                                   ,
             p_date5                                   ,
             p_date6                                   ,
             p_date7                                   ,
             p_date8                                   ,
             p_date9                                   ,
             p_date10                                  ,
             P_interface_entity_code                    ,
             P_interface_tax_line_id                   ,
             P_taxing_juris_geography_id               ,
             P_adjusted_doc_tax_line_id                ,
             P_object_version_number                   ,
             p_last_updated_by                         ,
             p_last_update_date                        ,
             p_last_updated_by                         ,
             p_last_update_date                       ,
             p_last_update_login       );

          END IF; --summary critera changed
        END LOOP; --c_line
      END IF; --asoociated_child_frozen_flag = 'Y'
    END IF; --tax_only_line_flag = 'N'


    IF p_freeze_until_overriddn_flg = 'Y' AND
       p_overridden_flag = 'Y' AND
       p_copied_from_other_doc_flag = 'Y' AND
       p_tax_amt = 0 AND
       p_taxable_amt = 0 AND
       p_other_doc_source = 'REFERENCE' THEN
      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_DETAIL_OVERRIDE_PKG.Update_Row',
                     'Tax Lines are created for variance purposes, no updates will be allowed');
      END IF;
      -- Tax Lines are created for variance purposes, no updates will be allowed.
    ELSE
      IF l_same_line THEN
        SELECT CASE WHEN p_tax_amt_included_flag <> tax_amt_included_flag
               THEN 'Y'
               ELSE 'N' END
        INTO l_tax_amt_incl_changed
        FROM ZX_LINES
        WHERE TAX_LINE_ID = p_tax_line_id;

        UPDATE ZX_LINES
        SET TAX_REGIME_ID                = p_tax_regime_id,
            TAX_REGIME_CODE              = p_tax_regime_code,
            TAX_ID                       = p_tax_id,
            TAX                          = p_tax,
            TAX_STATUS_ID                = p_tax_status_id,
            TAX_STATUS_CODE              = p_tax_status_code,
            TAX_RATE_ID                  = p_tax_rate_id,
            TAX_RATE_CODE                = p_tax_rate_code,
            TAX_RATE                     = p_tax_rate,
            TAX_RATE_TYPE                = p_tax_rate_type,   -- Added as a fix of Bug#5980153
            TAX_AMT                      = decode(p_cancel_flag, 'Y', 0, p_tax_amt),
            UNROUNDED_TAX_AMT	           = DECODE(p_cancel_flag,'Y',0,p_unrounded_tax_amt),
            ORIG_TAX_STATUS_ID           = nvl(ORIG_TAX_STATUS_ID, p_orig_TAX_STATUS_ID),
            ORIG_TAX_STATUS_CODE         = nvl(ORIG_TAX_STATUS_CODE, p_orig_TAX_STATUS_CODE),
            --ORIG_TAX_STATUS_ID         = p_orig_tax_status_id,
            --ORIG_TAX_STATUS_CODE       = p_orig_tax_status_code,
            ORIG_TAX_RATE_ID             = nvl(ORIG_TAX_RATE_ID, p_orig_TAX_RATE_ID),
            ORIG_TAX_RATE_CODE           = nvl(ORIG_TAX_RATE_CODE, p_orig_TAX_RATE_CODE),
            ORIG_TAX_RATE                = nvl(ORIG_TAX_RATE, p_orig_TAX_RATE),
            --ORIG_TAX_RATE_ID           = p_orig_tax_rate_id,
            --ORIG_TAX_RATE_CODE         = p_orig_tax_rate_code,
            --ORIG_TAX_RATE              = p_orig_tax_rate,
            ORIG_TAX_AMT                 = nvl(ORIG_TAX_AMT, p_orig_TAX_AMT),
            --ORIG_TAX_AMT               = p_orig_tax_amt,
            ORIG_TAXABLE_AMT             = nvl(ORIG_TAXABLE_AMT, p_orig_TAXABLE_AMT),
            -- bug 5636132
            ORIG_TAX_AMT_TAX_CURR        = nvl(ORIG_TAX_AMT_TAX_CURR, TAX_AMT_TAX_CURR),
            ORIG_TAXABLE_AMT_TAX_CURR    = nvl(ORIG_TAXABLE_AMT_TAX_CURR, TAXABLE_AMT_TAX_CURR),
            /*Bug 8329584*/
            TAX_JURISDICTION_CODE        = p_TAX_JURISDICTION_CODE,
            /*Bug 8329584*/
            ORIG_TAX_JURISDICTION_ID     = nvl(ORIG_TAX_JURISDICTION_ID, p_orig_TAX_JURISDICTION_ID),
            ORIG_TAX_JURISDICTION_CODE   = nvl(ORIG_TAX_JURISDICTION_CODE, p_orig_TAX_JURISDICTION_CODE),
            --ORIG_TAX_JURISDICTION_ID   = p_orig_tax_jurisdiction_id,
            --ORIG_TAX_JURISDICTION_CODE = p_orig_tax_jurisdiction_code,
            ORIG_TAX_AMT_INCLUDED_FLAG   = decode(ORIG_TAX_AMT_INCLUDED_FLAG,NULL,decode(p_tax_amt_included_flag,TAX_AMT_INCLUDED_FLAG,ORIG_TAX_AMT_INCLUDED_FLAG,TAX_AMT_INCLUDED_FLAG),ORIG_TAX_AMT_INCLUDED_FLAG),
            ORIG_SELF_ASSESSED_FLAG      = decode(ORIG_SELF_ASSESSED_FLAG,NULL,decode(p_self_assessed_flag,SELF_ASSESSED_FLAG,ORIG_SELF_ASSESSED_FLAG,SELF_ASSESSED_FLAG),ORIG_SELF_ASSESSED_FLAG),
            SELF_ASSESSED_FLAG           = p_self_assessed_flag,
            TAX_AMT_INCLUDED_FLAG        = l_new_tax_amt_included_flag,
            LAST_MANUAL_ENTRY            = p_last_manual_entry,
            COMPOUNDING_TAX_FLAG         = l_compounding_tax_flag,
            OVERRIDDEN_FLAG              = 'Y',
            RECALC_REQUIRED_FLAG         = decode(p_cancel_flag, 'N', 'Y', 'N'),
            PROCESS_FOR_RECOVERY_FLAG    = decode(p_reporting_only_flag , 'N', 'Y', l_process_for_recovery_flag),
            FREEZE_UNTIL_OVERRIDDEN_FLAG = decode(p_copied_from_other_doc_flag, 'Y', 'N', p_freeze_until_overriddn_flg),
            CANCEL_FLAG                  = p_cancel_flag,
            LEGAL_REPORTING_STATUS       = DECODE(p_cancel_flag, 'Y',
                                                  DECODE(LEGAL_REPORTING_STATUS, '111111111111111',
                                                         '000000000000000',
                                                         LEGAL_REPORTING_STATUS),
                                                  LEGAL_REPORTING_STATUS),
            SYNC_WITH_PRVDR_FLAG         = decode(p_tax_provider_id, NULL, 'N', p_sync_with_prvdr_flag),
            TAX_HOLD_CODE                = p_tax_hold_code,
            TAX_HOLD_RELEASED_CODE       = p_tax_hold_released_code,
            OBJECT_VERSION_NUMBER        = NVL(p_object_version_number, OBJECT_VERSION_NUMBER + 1),
            LAST_UPDATED_BY              = fnd_global.user_id,
            LAST_UPDATE_DATE             = sysdate,
            LAST_UPDATE_LOGIN            = fnd_global.login_id,
            SUMMARY_TAX_LINE_ID          = NVL(l_existing_summary_tax_line_id,SUMMARY_TAX_LINE_ID),
            --EU VAT changes
            LEGAL_MESSAGE_STATUS         = p_legal_message_status,
            LEGAL_MESSAGE_RATE           = p_legal_message_rate,
            LEGAL_MESSAGE_CALC           = p_legal_message_calc,
            LEGAL_MESSAGE_BASIS          = p_legal_message_basis,
            LEGAL_MESSAGE_POS            = p_legal_message_pos,
            STATUS_RESULT_ID             = p_status_result_id,
            RATE_RESULT_ID               = p_rate_result_id,
            DIRECT_RATE_RESULT_ID        = p_direct_rate_result_id,
            CALC_RESULT_ID               = p_calc_result_id,
            BASIS_RESULT_ID              = p_basis_result_id,
            PLACE_OF_SUPPLY_RESULT_ID    = p_place_of_supply_result_id
            -- End EU VAT changes
        WHERE TAX_LINE_ID = p_tax_line_id;
      END IF; --IF l_same_line THEN
    END IF;   --IF p_freeze_until_overriddn_flg = 'Y'

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_DETAIL_OVERRIDE_PKG.Update_Row',
                     'Update recalc_required_flag in zx_lines');
    END IF;

    BEGIN
      SELECT CTRL_EFF_OVRD_CALC_LINES_FLAG
      INTO l_ctrl_ef_ov_cal_line_flag
      FROM ZX_EVNT_CLS_OPTIONS
      WHERE EVENT_CLASS_CODE = p_event_class_code
      AND APPLICATION_ID = p_application_id
      AND ENTITY_CODE = p_entity_code
      AND ENABLED_FLAG = 'Y'
      AND FIRST_PTY_ORG_ID = p_content_owner_id
      AND p_tax_date >= effective_from
      AND (p_tax_date <= effective_to OR EFFECTIVE_TO IS NULL);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        SELECT CTRL_EFF_OVRD_CALC_LINES_FLAG
        INTO l_ctrl_ef_ov_cal_line_flag
        FROM ZX_EVNT_CLS_MAPPINGS
        WHERE EVENT_CLASS_CODE = p_event_class_code
        AND APPLICATION_ID = p_application_id
        AND ENTITY_CODE = p_entity_code;

    END;

    -- manual entered tax line:
    IF p_manually_entered_flag = 'N' THEN
      -- this is system generated tax line :
      IF l_tax_amt_incl_changed = 'Y' THEN
        IF l_ctrl_ef_ov_cal_line_flag = 'Y' THEN
          UPDATE ZX_LINES
            SET RECALC_REQUIRED_FLAG = 'Y'
            WHERE APPLICATION_ID      = p_application_id
            AND ENTITY_CODE           = p_entity_code
            AND EVENT_CLASS_CODE      = p_event_class_code
            AND TRX_ID                = p_trx_id
            AND TRX_LINE_ID           = p_trx_line_id  -- add this line
            AND TRX_LEVEL_TYPE        = p_trx_level_type
            AND MANUALLY_ENTERED_FLAG = 'N'
            AND CANCEL_FLAG           = 'N';
        END IF;

      ELSE
        -- tax_amt_included_flag = 'N'
        IF p_compounding_tax_flag = 'Y' THEN
          UPDATE ZX_LINES
            SET RECALC_REQUIRED_FLAG = 'Y'
            WHERE APPLICATION_ID         = p_application_id
            AND ENTITY_CODE              = p_entity_code
            AND EVENT_CLASS_CODE         = p_event_class_code
            AND TRX_LINE_ID              = p_trx_line_id  -- add this line
            AND TRX_LEVEL_TYPE           = p_trx_level_type
            AND TRX_ID                   = p_trx_id
            AND COMPOUNDING_DEP_TAX_FLAG = 'Y'
            AND CANCEL_FLAG              = 'N';
        END IF;
      END IF;
    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_DETAIL_OVERRIDE_PKG.Update_Row.END',
                     'ZX_TRL_DETAIL_OVERRIDE_PKG: Update_Row (-)');
    END IF;

  END Update_Row;

  PROCEDURE Delete_Row
       (X_Rowid                      IN OUT NOCOPY VARCHAR2,
        p_tax_line_id                              NUMBER,
        p_internal_organization_id                 NUMBER,
        p_application_id                           NUMBER,
        p_entity_code                              VARCHAR2,
        p_event_class_code                         VARCHAR2,
        p_event_type_code                          VARCHAR2,
        p_trx_id                                   NUMBER,
        p_trx_line_id                              NUMBER,
        p_trx_level_type                           VARCHAR2,
        p_trx_line_number                          NUMBER,
        p_doc_event_status                         VARCHAR2,
        p_tax_event_class_code                     VARCHAR2,
        p_tax_event_type_code                      VARCHAR2,
        p_tax_line_number                          NUMBER,
        p_content_owner_id                         NUMBER,
        p_tax_regime_id                            NUMBER,
        p_tax_regime_code                          VARCHAR2,
        p_tax_id                                   NUMBER,
        p_tax                                      VARCHAR2,
        p_tax_status_id                            NUMBER,
        p_tax_status_code                          VARCHAR2,
        p_tax_rate_id                              NUMBER,
        p_tax_rate_code                            VARCHAR2,
        p_tax_rate                                 NUMBER,
        p_tax_rate_type                            VARCHAR2,
        p_tax_apportionment_line_num               NUMBER,--reduced in size tax_apportionment_line_number
        p_trx_id_level2                            NUMBER,
        p_trx_id_level3                            NUMBER,
        p_trx_id_level4                            NUMBER,
        p_trx_id_level5                            NUMBER,
        p_trx_id_level6                            NUMBER,
        p_trx_user_key_level1                      VARCHAR2,
        p_trx_user_key_level2                      VARCHAR2,
        p_trx_user_key_level3                      VARCHAR2,
        p_trx_user_key_level4                      VARCHAR2,
        p_trx_user_key_level5                      VARCHAR2,
        p_trx_user_key_level6                      VARCHAR2,
        p_mrc_tax_line_flag                        VARCHAR2,
        p_mrc_link_to_tax_line_id                  NUMBER,
        p_ledger_id                                NUMBER,
        p_establishment_id                         NUMBER,
        p_legal_entity_id                          NUMBER,
        p_hq_estb_reg_number                       VARCHAR2,
        p_hq_estb_party_tax_prof_id                NUMBER,
        p_currency_conversion_date                 DATE,
        p_currency_conversion_type                 VARCHAR2,
        p_currency_conversion_rate                 NUMBER,
        p_tax_curr_conversion_date                 DATE,--reduced in size tax_currency_conversion_date
        p_tax_curr_conversion_type                 VARCHAR2,--reduced in size p_tax_currency_conversion_type
        p_tax_curr_conversion_rate                 NUMBER,--reduced in size p_tax_currency_conversion_rate
        p_trx_currency_code                        VARCHAR2,
        p_reporting_currency_code                  VARCHAR2,
        p_minimum_accountable_unit                 NUMBER,
        p_precision                                NUMBER,
        p_trx_number                               VARCHAR2,
        p_trx_date                                 DATE,
        p_unit_price                               NUMBER,
        p_line_amt                                 NUMBER,
        p_trx_line_quantity                        NUMBER,
        p_tax_base_modifier_rate                   NUMBER,
        p_ref_doc_application_id                   NUMBER,
        p_ref_doc_entity_code                      VARCHAR2,
        p_ref_doc_event_class_code                 VARCHAR2,
        p_ref_doc_trx_id                           NUMBER,
        p_ref_doc_trx_level_type                   VARCHAR2,
        p_ref_doc_line_id                          NUMBER,
        p_ref_doc_line_quantity                    NUMBER,
        p_other_doc_line_amt                       NUMBER,
        p_other_doc_line_tax_amt                   NUMBER,
        p_other_doc_line_taxable_amt               NUMBER,
        p_unrounded_taxable_amt                    NUMBER,
        p_unrounded_tax_amt                        NUMBER,
        p_related_doc_application_id               NUMBER,
        p_related_doc_entity_code                  VARCHAR2,
        p_related_doc_evt_class_code               VARCHAR2,--reduced in size p_related_doc_event_class_code
        p_related_doc_trx_id                       NUMBER,
        p_related_doc_trx_level_type               VARCHAR2,
        p_related_doc_number                       VARCHAR2,
        p_related_doc_date                         DATE,
        p_applied_from_appl_id                     NUMBER,--reduced in size p_applied_from_application_id
        p_applied_from_evt_clss_code               VARCHAR2,--reduced in size p_applied_from_event_class_code
        p_applied_from_entity_code                 VARCHAR2,
        p_applied_from_trx_id                      NUMBER,
        p_applied_from_trx_level_type              VARCHAR2,
        p_applied_from_line_id                     NUMBER,
        p_applied_from_trx_number                  VARCHAR2,
        p_adjusted_doc_appln_id                    NUMBER,--reduced in size p_adjusted_doc_application_id
        p_adjusted_doc_entity_code                 VARCHAR2,
        p_adjusted_doc_evt_clss_code               VARCHAR2,--reduced in size p_adjusted_doc_event_class_code
        p_adjusted_doc_trx_id                      NUMBER,
        p_adjusted_doc_trx_level_type              VARCHAR2,
        p_adjusted_doc_line_id                     NUMBER,
        p_adjusted_doc_number                      VARCHAR2,
        p_adjusted_doc_date                        DATE,
        p_applied_to_application_id                NUMBER,
        p_applied_to_evt_class_code                VARCHAR2,--reduced in size p_applied_to_event_class_code
        p_applied_to_entity_code                   VARCHAR2,
        p_applied_to_trx_id                        NUMBER,
        p_applied_to_trx_level_type                VARCHAR2,
        p_applied_to_line_id                       NUMBER,
        p_summary_tax_line_id                      NUMBER,
        p_offset_link_to_tax_line_id               NUMBER,
        p_offset_flag                              VARCHAR2,
        p_process_for_recovery_flag                VARCHAR2,
        p_tax_jurisdiction_id                      NUMBER,
        p_tax_jurisdiction_code                    VARCHAR2,
        p_place_of_supply                          NUMBER,
        p_place_of_supply_type_code                VARCHAR2,
        p_place_of_supply_result_id                NUMBER,
        p_tax_date_rule_id                         NUMBER,
        p_tax_date                                 DATE,
        p_tax_determine_date                       DATE,
        p_tax_point_date                           DATE,
        p_trx_line_date                            DATE,
        p_tax_type_code                            VARCHAR2,
        p_tax_code                                 VARCHAR2,
        p_tax_registration_id                      NUMBER,
        p_tax_registration_number                  VARCHAR2,
        p_registration_party_type                  VARCHAR2,
        p_rounding_level_code                      VARCHAR2,
        p_rounding_rule_code                       VARCHAR2,
        p_rndg_lvl_party_tax_prof_id               NUMBER,--reduced in size p_rounding_lvl_party_tax_prof_id
        p_rounding_lvl_party_type                  VARCHAR2,
        p_compounding_tax_flag                     VARCHAR2,
        p_orig_tax_status_id                       NUMBER,
        p_orig_tax_status_code                     VARCHAR2,
        p_orig_tax_rate_id                         NUMBER,
        p_orig_tax_rate_code                       VARCHAR2,
        p_orig_tax_rate                            NUMBER,
        p_orig_tax_jurisdiction_id                 NUMBER,
        p_orig_tax_jurisdiction_code               VARCHAR2,
        p_orig_tax_amt_included_flag               VARCHAR2,
        p_orig_self_assessed_flag                  VARCHAR2,
        p_tax_currency_code                        VARCHAR2,
        p_tax_amt                                  NUMBER,
        p_tax_amt_tax_curr                         NUMBER,
        p_tax_amt_funcl_curr                       NUMBER,
        p_taxable_amt                              NUMBER,
        p_taxable_amt_tax_curr                     NUMBER,
        p_taxable_amt_funcl_curr                   NUMBER,
        p_orig_taxable_amt                         NUMBER,
        p_orig_taxable_amt_tax_curr                NUMBER,
        p_cal_tax_amt                              NUMBER,
        p_cal_tax_amt_tax_curr                     NUMBER,
        p_cal_tax_amt_funcl_curr                   NUMBER,
        p_orig_tax_amt                             NUMBER,
        p_orig_tax_amt_tax_curr                    NUMBER,
        p_rec_tax_amt                              NUMBER,
        p_rec_tax_amt_tax_curr                     NUMBER,
        p_rec_tax_amt_funcl_curr                   NUMBER,
        p_nrec_tax_amt                             NUMBER,
        p_nrec_tax_amt_tax_curr                    NUMBER,
        p_nrec_tax_amt_funcl_curr                  NUMBER,
        p_tax_exemption_id                         NUMBER,
        p_tax_rate_before_exemption                NUMBER,
        p_tax_rate_name_before_exempt              VARCHAR2,
        p_exempt_rate_modifier                     NUMBER,
        p_exempt_certificate_number                VARCHAR2,
        p_exempt_reason                            VARCHAR2,
        p_exempt_reason_code                       VARCHAR2,
        p_tax_exception_id                         NUMBER,
        p_tax_rate_before_exception                NUMBER,
        p_tax_rate_name_before_except              VARCHAR2,
        p_exception_rate                           NUMBER,
        p_tax_apportionment_flag                   VARCHAR2,
        p_historical_flag                          VARCHAR2,
        p_taxable_basis_formula                    VARCHAR2,
        p_tax_calculation_formula                  VARCHAR2,
        p_cancel_flag                              VARCHAR2,
        p_purge_flag                               VARCHAR2,
        p_delete_flag                              VARCHAR2,
        p_tax_amt_included_flag                    VARCHAR2,
        p_self_assessed_flag                       VARCHAR2,
        p_overridden_flag                          VARCHAR2,
        p_manually_entered_flag                    VARCHAR2,
        p_reporting_only_flag                      VARCHAR2,
        p_freeze_until_overriddn_flg               VARCHAR2,--reduced in size p_Freeze_Until_Overridden_Flag
        p_copied_from_other_doc_flag               VARCHAR2,
        p_recalc_required_flag                     VARCHAR2,
        p_settlement_flag                          VARCHAR2,
        p_item_dist_changed_flag                   VARCHAR2,
        p_assoc_children_frozen_flg                VARCHAR2,--reduced in size p_Associated_Child_Frozen_Flag
        p_tax_only_line_flag                       VARCHAR2,
        p_compounding_dep_tax_flag                 VARCHAR2,
        p_compounding_tax_miss_flag                VARCHAR2,
        p_sync_with_prvdr_flag                     VARCHAR2,
        p_last_manual_entry                        VARCHAR2,
        p_tax_provider_id                          NUMBER,
        p_record_type_code                         VARCHAR2,
        p_reporting_period_id                      NUMBER,
        p_legal_justification_text1                VARCHAR2,
        p_legal_justification_text2                VARCHAR2,
        p_legal_justification_text3                VARCHAR2,
        p_legal_message_appl_2                     NUMBER,
        p_legal_message_status                     NUMBER,
        p_legal_message_rate                       NUMBER,
        p_legal_message_basis                      NUMBER,
        p_legal_message_calc                       NUMBER,
        p_legal_message_threshold                  NUMBER,
        p_legal_message_pos                        NUMBER,
        p_legal_message_trn                        NUMBER,
        p_legal_message_exmpt                      NUMBER,
        p_legal_message_excpt                      NUMBER,
        p_tax_regime_template_id                   NUMBER,
        p_tax_applicability_result_id              NUMBER,--reduced in size p_tax_applicability_result_id
        p_direct_rate_result_id                    NUMBER,
        p_status_result_id                         NUMBER,
        p_rate_result_id                           NUMBER,
        p_basis_result_id                          NUMBER,
        p_thresh_result_id                         NUMBER,
        p_calc_result_id                           NUMBER,
        p_tax_reg_num_det_result_id                NUMBER,
        p_eval_exmpt_result_id                     NUMBER,
        p_eval_excpt_result_id                     NUMBER,
        p_enforced_from_nat_acct_flg               VARCHAR2,--reduced in size p_Enforce_From_Natural_Acct_Flag
        p_tax_hold_code                            NUMBER,
        p_tax_hold_released_code                   NUMBER,
        p_prd_total_tax_amt                        NUMBER,
        p_prd_total_tax_amt_tax_curr               NUMBER,
        p_prd_total_tax_amt_funcl_curr             NUMBER,
        p_trx_line_index                           VARCHAR2,
        p_offset_tax_rate_code                     VARCHAR2,
        p_proration_code                           VARCHAR2,
        p_other_doc_source                         VARCHAR2,
        p_internal_org_location_id                 NUMBER,
        p_line_assessable_value                    NUMBER,
        p_ctrl_total_line_tx_amt                   NUMBER,
        p_applied_to_trx_number                    VARCHAR2,
        p_attribute_category                       VARCHAR2,
        p_attribute1                               VARCHAR2,
        p_attribute2                               VARCHAR2,
        p_attribute3                               VARCHAR2,
        p_attribute4                               VARCHAR2,
        p_attribute5                               VARCHAR2,
        p_attribute6                               VARCHAR2,
        p_attribute7                               VARCHAR2,
        p_attribute8                               VARCHAR2,
        p_attribute9                               VARCHAR2,
        p_attribute10                              VARCHAR2,
        p_attribute11                              VARCHAR2,
        p_attribute12                              VARCHAR2,
        p_attribute13                              VARCHAR2,
        p_attribute14                              VARCHAR2,
        p_attribute15                              VARCHAR2,
        p_global_attribute_category                VARCHAR2,
        p_global_attribute1                        VARCHAR2,
        p_global_attribute2                        VARCHAR2,
        p_global_attribute3                        VARCHAR2,
        p_global_attribute4                        VARCHAR2,
        p_global_attribute5                        VARCHAR2,
        p_global_attribute6                        VARCHAR2,
        p_global_attribute7                        VARCHAR2,
        p_global_attribute8                        VARCHAR2,
        p_global_attribute9                        VARCHAR2,
        p_global_attribute10                       VARCHAR2,
        p_global_attribute11                       VARCHAR2,
        p_global_attribute12                       VARCHAR2,
        p_global_attribute13                       VARCHAR2,
        p_global_attribute14                       VARCHAR2,
        p_global_attribute15                       VARCHAR2,
        p_numeric1                                 NUMBER,
        p_numeric2                                 NUMBER,
        p_numeric3                                 NUMBER,
        p_numeric4                                 NUMBER,
        p_numeric5                                 NUMBER,
        p_numeric6                                 NUMBER,
        p_numeric7                                 NUMBER,
        p_numeric8                                 NUMBER,
        p_numeric9                                 NUMBER,
        p_numeric10                                NUMBER,
        p_char1                                    VARCHAR2,
        p_char2                                    VARCHAR2,
        p_char3                                    VARCHAR2,
        p_char4                                    VARCHAR2,
        p_char5                                    VARCHAR2,
        p_char6                                    VARCHAR2,
        p_char7                                    VARCHAR2,
        p_char8                                    VARCHAR2,
        p_char9                                    VARCHAR2,
        p_char10                                   VARCHAR2,
        p_date1                                    DATE,
        p_date2                                    DATE,
        p_date3                                    DATE,
        p_date4                                    DATE,
        p_date5                                    DATE,
        p_date6                                    DATE,
        p_date7                                    DATE,
        p_date8                                    DATE,
        p_date9                                    DATE,
        p_date10                                   DATE,
        p_interface_entity_code                    VARCHAR2,
        p_interface_tax_line_id                    NUMBER,
        p_taxing_juris_geography_id                NUMBER,
        p_adjusted_doc_tax_line_id                 NUMBER,
        p_object_version_number                    NUMBER,
        p_created_by                               NUMBER,
        p_creation_date                            DATE,
        p_last_updated_by                          NUMBER,
        p_last_update_date                         DATE,
        p_last_update_login                        NUMBER) IS

    l_return_status VARCHAR2(1000);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(1000);

  BEGIN

    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_DETAIL_OVERRIDE_PKG.Delete_Row.BEGIN',
                     'ZX_TRL_DETAIL_OVERRIDE_PKG: Delete_Row (+)');
    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_DETAIL_OVERRIDE_PKG.Delete_Row',
                     'Update zx_lines for delete and cancel flag (+)');
    END IF;

    UPDATE ZX_LINES
      SET DELETE_FLAG = 'Y',
          SYNC_WITH_PRVDR_FLAG = DECODE(p_tax_provider_id,
                                        NULL, 'N', 'Y'),
          OBJECT_VERSION_NUMBER = NVL(p_object_version_number, OBJECT_VERSION_NUMBER + 1)
      WHERE TAX_LINE_ID = p_tax_line_id;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_DETAIL_OVERRIDE_PKG.Delete_Row',
                     'Update zx_lines for delete and cancel flag (-)');
    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_DETAIL_OVERRIDE_PKG.Delete_Row.END',
                     'ZX_TRL_DETAIL_OVERRIDE_PKG: Delete_Row (-)');
    END IF;
  END Delete_Row;

  PROCEDURE Override_Row
       (p_application_id                           NUMBER,
        p_entity_code                              VARCHAR2,
        p_event_class_code                         VARCHAR2,
        p_trx_id                                   NUMBER,
        p_trx_line_id                              NUMBER,
        p_trx_level_type                           VARCHAR2,
        p_event_id                                 NUMBER) IS

  l_transaction_rec      ZX_API_PUB.transaction_rec_type;
  l_return_status        VARCHAR2(80);

  BEGIN

    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_DETAIL_OVERRIDE_PKG.Override_Row.BEGIN',
                     'ZX_TRL_DETAIL_OVERRIDE_PKG: Override_Row(+)');
    END IF;

    --
    -- obtain lock before update ZX_LINES_DET_FACTORS
    --
    l_transaction_rec.application_id   := p_application_id;
    l_transaction_rec.entity_code      := p_entity_code;
    l_transaction_rec.event_class_code := p_event_class_code;
    l_transaction_rec.trx_id           := p_trx_id;

    ZX_LINES_DET_FACTORS_PKG.lock_line_det_factors(
            l_transaction_rec,
            l_return_status );

    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
      UPDATE ZX_LINES_DET_FACTORS
        SET EVENT_ID = p_event_id
        WHERE APPLICATION_ID = p_application_id
        AND ENTITY_CODE      = p_entity_code
        AND EVENT_CLASS_CODE = p_event_class_code
        AND TRX_ID           = p_trx_id
        AND TRX_LEVEL_TYPE   = p_trx_level_type
        AND TRX_LINE_ID      = p_trx_line_id;
    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_DETAIL_OVERRIDE_PKG.Override_Row.END',
                     'ZX_TRL_DETAIL_OVERRIDE_PKG: Override_Row (-)');
    END IF;

  END Override_Row;

  PROCEDURE lock_dtl_tax_lines_for_doc
  			(p_application_id			IN NUMBER,
  			 p_entity_code        IN VARCHAR2,
  			 p_event_class_code   IN VARCHAR2,
  			 p_trx_id             IN NUMBER,
			   x_return_status      OUT NOCOPY VARCHAR2,
			   x_error_buffer       OUT NOCOPY VARCHAR2)  IS

		l_return_status          VARCHAR2(1000);

  /*Cursor to Lock the tax lines for the entire document*/
  CURSOR lock_dtl_tax_lines_for_doc_csr(c_application_id NUMBER,
  			 c_event_class_code VARCHAR2,
  			 c_entity_code VARCHAR2,
  			 c_trx_id NUMBER) IS
      SELECT *
        FROM ZX_LINES
       WHERE application_id = c_application_id
         AND entity_code    = c_entity_code
         AND event_class_code = c_event_class_code
    	   AND trx_id = c_trx_id
      FOR UPDATE NOWAIT;

  BEGIN
		x_return_status := FND_API.G_RET_STS_SUCCESS;

		g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

		IF (g_level_procedure >= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_procedure,
		                 'ZX.PLSQL.ZX_TRL_DETAIL_OVERRIDE_PKG.lock_dtl_tax_lines_for_doc.BEGIN',
		                 'ZX_TRL_DETAIL_OVERRIDE_PKG: lock_dtl_tax_lines_for_doc (+)');
    END IF;

		OPEN lock_dtl_tax_lines_for_doc_csr(p_application_id,
																				p_event_class_code,
																				p_entity_code,
																				p_trx_id);
		CLOSE lock_dtl_tax_lines_for_doc_csr;

		IF (g_level_procedure >= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_procedure,
		                 'ZX.PLSQL.ZX_TRL_DETAIL_OVERRIDE_PKG.lock_dtl_tax_lines_for_doc.END',
		                 'ZX_TRL_DETAIL_OVERRIDE_PKG: lock_dtl_tax_lines_for_doc (-)');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

      FND_MESSAGE.SET_NAME('ZX','ZX_UNEXPECTED_ERROR');
      FND_MSG_PUB.Add;

      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_DETAIL_OVERRIDE_PKG.lock_dtl_tax_lines_for_doc',
                       'Exception:' ||x_error_buffer);
      END IF;
  END lock_dtl_tax_lines_for_doc;


END ZX_TRL_DETAIL_OVERRIDE_PKG;

/
