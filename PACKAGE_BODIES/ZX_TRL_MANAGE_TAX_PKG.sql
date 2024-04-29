--------------------------------------------------------
--  DDL for Package Body ZX_TRL_MANAGE_TAX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_TRL_MANAGE_TAX_PKG" AS
/* $Header: zxrilnrepsrvpvtb.pls 120.100.12010000.16 2010/06/01 09:57:39 ssohal ship $ */

  g_current_runtime_level           NUMBER;
  g_level_statement       CONSTANT  NUMBER  := FND_LOG.LEVEL_STATEMENT;
  g_level_procedure       CONSTANT  NUMBER  := FND_LOG.LEVEL_PROCEDURE;
  g_level_event           CONSTANT  NUMBER  := FND_LOG.LEVEL_EVENT;
  g_level_unexpected      CONSTANT  NUMBER  := FND_LOG.LEVEL_UNEXPECTED;
  g_level_error           CONSTANT  NUMBER  := FND_LOG.LEVEL_ERROR;

  NUMBER_DUMMY    CONSTANT NUMBER(15)     := -999999999999999;

  TYPE num_tbl_type     IS TABLE OF NUMBER        INDEX BY BINARY_INTEGER;
  TYPE date_tbl_type    IS TABLE OF DATE          INDEX BY BINARY_INTEGER;
  TYPE char_tbl_type    IS TABLE OF VARCHAR2(1)   INDEX BY BINARY_INTEGER;
  TYPE char30_tbl_type  IS TABLE OF VARCHAR2(30)  INDEX BY BINARY_INTEGER;
  TYPE char80_tbl_type  IS TABLE OF VARCHAR2(80)  INDEX BY BINARY_INTEGER;
  TYPE char150_tbl_type IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;
  TYPE char240_tbl_type IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;


  pg_summary_tax_line_id_tbl       num_tbl_type;
  pg_internal_org_id_tbl           num_tbl_type;
  pg_application_id_tbl            num_tbl_type;
  pg_entity_code_tbl               char30_tbl_type;
  pg_event_class_code_tbl          char30_tbl_type;
  pg_trx_id_tbl                    num_tbl_type;
  pg_trx_number_tbl                char150_tbl_type;
  pg_app_from_app_id_tbl           num_tbl_type;
  pg_app_from_evnt_cls_code_tbl    char30_tbl_type;
  pg_app_from_entity_code_tbl      char30_tbl_type;
  pg_app_from_trx_id_tbl           num_tbl_type;
  pg_adj_doc_app_id_tbl            num_tbl_type;
  pg_adj_doc_entity_code_tbl       char30_tbl_type;
  pg_adj_doc_evnt_cls_code_tbl     char30_tbl_type;
  pg_adj_doc_trx_id_tbl            num_tbl_type;
  pg_summary_tax_line_num_tbl      num_tbl_type;
  pg_content_owner_id_tbl          num_tbl_type;
  pg_tax_regime_code_tbl           char30_tbl_type;
  pg_tax_tbl                       char30_tbl_type;
  pg_tax_status_code_tbl           char30_tbl_type;
  pg_tax_rate_id_tbl               num_tbl_type;
  pg_tax_rate_code_tbl             char150_tbl_type;
  pg_tax_rate_tbl                  num_tbl_type;
  pg_tax_amt_tbl                   num_tbl_type;
  pg_tax_amt_tax_curr_tbl          num_tbl_type;
  pg_tax_amt_funcl_curr_tbl        num_tbl_type;
  pg_tax_jurisdiction_code_tbl     char30_tbl_type;
  pg_ttl_rec_tax_amt_tbl           num_tbl_type;
  pg_ttl_rec_tx_amt_fnc_crr_tbl    num_tbl_type;
  pg_ttl_nrec_tax_amt_tbl          num_tbl_type;
  pg_ttl_nrec_tx_amt_fnc_crr_tbl   num_tbl_type;
  pg_ledger_id_tbl                 num_tbl_type;
  pg_legal_entity_id_tbl           num_tbl_type;
  pg_establishment_id_tbl          num_tbl_type;
  pg_currency_convrsn_date_tbl     date_tbl_type;
  pg_currency_convrsn_type_tbl     char30_tbl_type;
  pg_currency_convrsn_rate_tbl     num_tbl_type;
  pg_summarization_tmplt_id_tbl    num_tbl_type;
  pg_taxable_basis_formula_tbl     char30_tbl_type;
  pg_tax_calculation_formula_tbl   char30_tbl_type;
  pg_historical_flag_tbl           char_tbl_type;
  pg_cancel_flag_tbl               char_tbl_type;
  pg_delete_flag_tbl               char_tbl_type;
  pg_tax_amt_included_flag_tbl     char_tbl_type;
  pg_compounding_tax_flag_tbl      char_tbl_type;
  pg_self_assessed_flag_tbl        char_tbl_type;
  pg_overridden_flag_tbl           char_tbl_type;
  pg_reporting_only_flag_tbl       char_tbl_type;
  pg_assoctd_child_frz_flag_tbl    char_tbl_type;
  pg_cpd_from_other_doc_flag_tbl   char_tbl_type;
  pg_manually_entered_flag_tbl     char_tbl_type;
  pg_last_manual_entry_tbl         char30_tbl_type;
  pg_record_type_code_tbl          char30_tbl_type;
  pg_tax_provider_id_tbl           num_tbl_type;
  pg_tax_only_line_flag_tbl        char_tbl_type;
  pg_created_by_tbl                num_tbl_type;
  pg_creation_date_tbl             date_tbl_type;
  pg_last_updated_by_tbl           num_tbl_type;
  pg_last_update_date_tbl          date_tbl_type;
  pg_last_update_login_tbl         num_tbl_type;
  pg_app_from_line_id_tbl           num_tbl_type;
  pg_app_to_app_id_tbl             num_tbl_type;
  pg_app_to_evnt_cls_code_tbl      char30_tbl_type;
  pg_app_to_entity_code_tbl        char30_tbl_type;
  pg_app_to_trx_id_tbl             num_tbl_type;
  pg_app_to_line_id_tbl            num_tbl_type;
  pg_tax_xmptn_id_tbl              num_tbl_type;
  pg_tax_rate_bf_xmptn_tbl         num_tbl_type;
  pg_tax_rate_name_bf_xmptn_tbl    char80_tbl_type;
  pg_xmpt_rate_modifier_tbl        num_tbl_type;
  pg_xmpt_certificate_number_tbl   char80_tbl_type;
  pg_xmpt_reason_tbl               char240_tbl_type;
  pg_xmpt_reason_code_tbl          char30_tbl_type;
  pg_tax_rate_bf_xeptn_tbl         num_tbl_type;
  pg_tax_rate_name_bf_xeptn_tbl    char80_tbl_type;
  pg_tax_xeptn_id_tbl              num_tbl_type;
  pg_xeptn_rate_tbl                num_tbl_type;
  pg_ttl_rec_tx_amt_tx_crr_tbl     num_tbl_type;
  pg_ttl_nrec_tx_amt_tx_crr_tbl    num_tbl_type;
  pg_mrc_tax_line_flag_tbl         char_tbl_type;
  pg_app_from_trx_level_type_tbl   char30_tbl_type;
  pg_adj_doc_trx_level_type_tbl    char30_tbl_type;
  pg_app_to_trx_level_type_tbl     char30_tbl_type;
  pg_trx_level_type_tbl            char30_tbl_type;
  pg_adjust_tax_amt_flag_tbl       char_tbl_type;
  pg_object_version_number_tbl     num_tbl_type;

  pg_count_detail_tax_line_tbl     num_tbl_type;
  pg_tax_line_id_tbl               num_tbl_type;
  pg_detail_tax_smry_line_id_tbl   num_tbl_type;

  tax_line_id_tbl                  num_tbl_type;
  tax_rate_id_tbl                  num_tbl_type;
  pg_trx_id_tab                    num_tbl_type;
  pg_trx_line_id_tab               num_tbl_type;
  pg_trx_level_type_tab            char30_tbl_type;

  pg_count_detail_cancel_tbl       num_tbl_type;

/* ===========================================================================*
 | PROCEDURE Create_Detail_Lines : Insert tax lines into ZX_LINES table.      |
 * ===========================================================================*/

  PROCEDURE  Create_Detail_Lines (
        p_event_class_rec   IN         ZX_API_PUB.EVENT_CLASS_REC_TYPE,
        x_return_status     OUT NOCOPY VARCHAR2
  ) IS

    l_row_count    NUMBER;
    l_error_buffer VARCHAR2(100);
    l_msg_context_info_rec         ZX_API_PUB.CONTEXT_INFO_REC_TYPE;


  BEGIN

    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    l_row_count := 0;
    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Create_Detail_Lines.BEGIN',
                     'ZX_TRL_MANAGE_TAX_PKG: Create_Detail_Lines (+)');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- bug#4893261- populate message structure
    --
    l_msg_context_info_rec.application_id :=
              p_event_class_rec.application_id;
    l_msg_context_info_rec.entity_code :=
              p_event_class_rec.entity_code;
    l_msg_context_info_rec.event_class_code :=
              p_event_class_rec.event_class_code;
    l_msg_context_info_rec.trx_id :=
              p_event_class_rec.trx_id;
    l_msg_context_info_rec.trx_line_id := NULL;
    l_msg_context_info_rec.trx_level_type := NULL;
    l_msg_context_info_rec.summary_tax_line_number := NULL;
    l_msg_context_info_rec.tax_line_id := NULL;
    l_msg_context_info_rec.trx_line_dist_id := NULL;

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
                          LEDGER_ID,
                          ESTABLISHMENT_ID,
                          LEGAL_ENTITY_ID,
                          LEGAL_ENTITY_TAX_REG_NUMBER,
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
                          APPLIED_TO_TRX_NUMBER,
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
                          COMPOUNDING_TAX_MISS_FLAG,
                          COMPOUNDING_DEP_TAX_FLAG,
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
                          LAST_UPDATE_LOGIN,
                          MULTIPLE_JURISDICTIONS_FLAG,
                          LEGAL_REPORTING_STATUS,
                          ACCOUNT_SOURCE_TAX_RATE_ID)
                   -- bug#7504604: remove the index hint
                   --SELECT /*+ INDEX(ZX_DETAIL_TAX_LINES_GT ZX_DETAIL_TAX_LINES_GT_U1) */
                   --
                SELECT
                       TAX_LINE_ID,
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
                       LEDGER_ID,
                       ESTABLISHMENT_ID,
                       LEGAL_ENTITY_ID,
                       LEGAL_ENTITY_TAX_REG_NUMBER,
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
                       APPLIED_TO_TRX_NUMBER,
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
                       CASE WHEN (TAXABLE_BASIS_FORMULA = 'PRORATED_TB'
                                 AND MANUALLY_ENTERED_FLAG = 'N')
                            THEN 'STANDARD_TB'
                            WHEN (TAXABLE_BASIS_FORMULA IS NULL
                                 AND MANUALLY_ENTERED_FLAG = 'N')
                            THEN 'STANDARD_TB'
                            WHEN (TAXABLE_BASIS_FORMULA = 'STANDARD_TB'
                                 AND MANUALLY_ENTERED_FLAG = 'Y')
                            THEN 'PRORATED_TB'
                            WHEN (TAXABLE_BASIS_FORMULA IS NULL
                                 AND MANUALLY_ENTERED_FLAG = 'Y')
                            THEN 'PRORATED_TB'
                            ELSE TAXABLE_BASIS_FORMULA
                       END TAXABLE_BASIS_FORMULA,
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
                       COMPOUNDING_TAX_MISS_FLAG,
                       COMPOUNDING_DEP_TAX_FLAG,
                       'N',            --SYNC_WITH_PRVDR_FLAG,  -- TSRM will look into GT for provider synchronization
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
                       1,      --OBJECT_VERSION_NUMBER,
                       CREATED_BY,
                       CREATION_DATE,
                       LAST_UPDATED_BY,
                       LAST_UPDATE_DATE,
                       LAST_UPDATE_LOGIN,
                       MULTIPLE_JURISDICTIONS_FLAG,
                       LEGAL_REPORTING_STATUS,
                       ACCOUNT_SOURCE_TAX_RATE_ID
                  FROM ZX_DETAIL_TAX_LINES_GT;

    l_row_count := SQL%ROWCOUNT;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Create_Detail_Lines',
                     'Rows Inserted : '||l_row_count);
    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Create_Detail_Lines.END',
                     'ZX_TRL_MANAGE_TAX_PKG.Create_Detail_Lines (-)');
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Create_Detail_Lines',
                       'Exception:' ||SQLCODE||';'||SQLERRM);

        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Create_Detail_Lines',
                       'Return Status = '||x_return_status);
      END IF;

    WHEN DUP_VAL_ON_INDEX THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR; -- bug 8568734
      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Create_Detail_Lines',
                       'Exception:' ||SQLCODE||';'||SQLERRM);

        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Create_Detail_Lines',
                       'Return Status = '||x_return_status);
      END IF;
      -- FND_MESSAGE.SET_NAME('ZX','ZX_TRL_RECORD_ALREADY_EXISTS');
      -- ZX_API_PUB.add_msg(l_msg_context_info_rec);

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      l_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Create_Detail_Lines',
                        l_error_buffer);
      END IF;

  END Create_Detail_Lines;

/*============================================================================*
 | PROCEDURE Summarization_For_Freeze_Event: Performs summarization and       |
 | records summary tax lines in tax repository . called during                |
 | Update_Freeze_Flag event                                                   |
 * ===========================================================================*/

  PROCEDURE Summarization_For_Freeze_Event
       (p_event_class_rec   IN         ZX_API_PUB.EVENT_CLASS_REC_TYPE,
        x_return_status     OUT NOCOPY VARCHAR2) IS

    l_error_buffer              VARCHAR2(100);
    l_use_null_summary_id_flag  VARCHAR2(1);
    l_summary_lines_count       NUMBER;
    l_row_count                 NUMBER;

  BEGIN

    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Summarization_For_Freeze_Event.BEGIN',
                     'ZX_TRL_MANAGE_TAX_PKG: Summarization_For_Freeze_Event (+)');
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Set summary_tax_line id to Null for unfrozen tax lines who share the same
    -- summary tax_line id as the one who has associated children frozen flag as 'Y'.
    --
    --  set SUMMARY_TAX_LINE_ID to NULL in ZX_LINES for
    --  those tax lines have Associated_Child_Frozen_Flag = 'N'
    --  belonged to the same summary line
    --

    -- Performance Bug 5908610 - Query has been modified
 /*    UPDATE ZX_LINES
        SET SUMMARY_TAX_LINE_ID = NULL
        WHERE SUMMARY_TAX_LINE_ID IN
        (SELECT summary_tax_line_id
         FROM ZX_LINES
         WHERE TAX_LINE_ID  IN (SELECT ZD.TAX_LINE_ID
                  FROM ZX_REC_NREC_DIST  ZD,
                       ZX_TAX_DIST_ID_GT ZGT
                  WHERE ZD.REC_NREC_TAX_DIST_ID   = ZGT.TAX_DIST_ID))
         AND Associated_Child_Frozen_Flag = 'N';

 */

   -- NEW query for the above

    UPDATE ZX_LINES
    SET SUMMARY_TAX_LINE_ID = NULL
    WHERE TAX_LINE_ID IN (SELECT ZD.TAX_LINE_ID
                      FROM ZX_REC_NREC_DIST ZD,
                           ZX_TAX_DIST_ID_GT ZGT
                      WHERE ZD.REC_NREC_TAX_DIST_ID = ZGT.TAX_DIST_ID)
     AND ASSOCIATED_CHILD_FROZEN_FLAG = 'N';
    --
    -- re-perform summarization for all  tax lines
    -- in the document, for tax lines that have
    -- Associated_Child_Frozen_Flag = 'N', generate a
    -- new summary_tax_line_id, for tax lines that
    -- have Associated_Child_Frozen_Flag = 'Y', keep
    -- the orignal summary_tax_line_id
    --

    create_summary_lines_upd_evnt(
      p_event_class_rec   => p_event_class_rec,
      x_return_status     => x_return_status );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_error >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_error,
               'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Summarization_For_Freeze_Event',
               'MRC Lines: Incorrect return_status after calling ' ||
               'ZX_TRL_MANAGE_TAX_PKG.create_summary_lines_upd_evnt()');
        FND_LOG.STRING(g_level_error,
               'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Summarization_For_Freeze_Event',
               'RETURN_STATUS = ' || x_return_status);
        FND_LOG.STRING(g_level_error,
               'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Summarization_For_Freeze_Event.END',
               'ZX_TRL_MANAGE_TAX_PKG.Summarization_For_Freeze_Event(-)');
      END IF;
      RETURN;
    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                    'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Summarization_For_Freeze_Event.END',
                    'ZX_TRL_MANAGE_TAX_PKG: Summarization_For_Freeze_Event (-)');
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Summarization_For_Freeze_Event',
                       'Unexpected error ...');
      END IF;

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      l_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Summarization_For_Freeze_Event',
                        l_error_buffer);
      END IF;
  END Summarization_For_Freeze_Event;

/*============================================================================*
 | PROCEDURE Delete_Detail_TaxLines: Deletes the transaction from ZX_LINES for|
 | given transaction details                                                  |
 *============================================================================*/

  PROCEDURE Delete_Detail_Lines
       (x_return_status   OUT    NOCOPY VARCHAR2,
        p_event_class_rec     IN        ZX_API_PUB.EVENT_CLASS_REC_TYPE) IS

    l_row_count    NUMBER;
    l_error_buffer VARCHAR2(100);

  BEGIN

    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    l_row_count := 0;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Delete_Detail_Lines.BEGIN',
                     'ZX_TRL_MANAGE_TAX_PKG: Delete_Detail_Lines (+)');
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- bug fix 5417887
    -- IF p_event_class_rec.tax_event_type_code = 'UPDATE' THEN
    IF ZX_GLOBAL_STRUCTURES_PKG.g_update_event_process_flag = 'Y' THEN

      /* -- rewrote for bug fix 5417887
      DELETE FROM ZX_LINES
        WHERE APPLICATION_ID  = p_event_class_rec.application_id
        AND  ENTITY_CODE      = p_event_class_rec.entity_code
        AND  EVENT_CLASS_CODE = p_event_class_rec.event_class_code
        AND  TRX_ID           = p_event_class_rec.trx_id
        AND  (DELETE_FLAG     = 'Y' OR
              (TRX_LINE_ID, trx_level_type) IN
              (SELECT TRX_LINE_ID, trx_level_type
                 FROM zx_lines_det_factors
                WHERE application_id = p_event_class_rec.application_id
                  AND entity_code      = p_event_class_rec.entity_code
                  AND event_class_code = p_event_class_rec.event_class_code
                  AND trx_id           = p_event_class_rec.trx_id
                  AND event_id         = p_event_class_rec.event_id
                  AND line_level_action NOT IN ('SYNCHRONIZE', 'NO_CHANGE')
               )
             ); */
      -- bug fix 5417887
      DELETE FROM ZX_LINES tax
        WHERE EXISTS (SELECT 1
                 FROM zx_lines_det_factors
                WHERE application_id = tax.application_id
                  AND entity_code      = tax.entity_code
                  AND event_class_code = tax.event_class_code
                  AND trx_id           = tax.trx_id
                  AND event_id         = p_event_class_rec.event_id
               )
          AND (tax.DELETE_FLAG     = 'Y' OR
              (tax.TRX_LINE_ID, tax.trx_level_type) IN
              (SELECT TRX_LINE_ID, trx_level_type
                 FROM zx_lines_det_factors
                WHERE application_id = tax.application_id
                  AND entity_code      = tax.entity_code
                  AND event_class_code = tax.event_class_code
                  AND trx_id           = tax.trx_id
                  AND event_id         = p_event_class_rec.event_id
                  AND line_level_action NOT IN ('SYNCHRONIZE', 'NO_CHANGE')
               )
             );

      l_row_count := SQL%ROWCOUNT;

    ELSIF p_event_class_rec.tax_event_type_code = 'OVERRIDE_TAX' THEN

      DELETE FROM zx_lines
       WHERE application_id   = p_event_class_rec.application_id
        AND  entity_code      = p_event_class_rec.entity_code
        AND  event_class_code = p_event_class_rec.event_class_code
        AND  trx_id           = p_event_class_rec.trx_id
        AND  (tax_line_id IN
              (SELECT /*+ INDEX(ZX_DETAIL_TAX_LINES_GT ZX_DETAIL_TAX_LINES_GT_U1) */
                      tax_line_id
                 FROM zx_detail_tax_lines_gt
                WHERE application_id   = p_event_class_rec.application_id
                  AND entity_code      = p_event_class_rec.entity_code
                  AND event_class_code = p_event_class_rec.event_class_code
                  AND trx_id           = p_event_class_rec.trx_id
              ) OR
              delete_flag = 'Y'
             );

      l_row_count := SQL%ROWCOUNT;

      IF p_event_class_rec.allow_offset_tax_calc_flag ='Y' THEN
        -- delete old offset tax lines
        --
        DELETE FROM zx_lines
         WHERE application_id   = p_event_class_rec.application_id
          AND  entity_code      = p_event_class_rec.entity_code
          AND  event_class_code = p_event_class_rec.event_class_code
          AND  trx_id           = p_event_class_rec.trx_id
          AND  offset_link_to_tax_line_id IN
               (SELECT /*+ INDEX(ZX_DETAIL_TAX_LINES_GT ZX_DETAIL_TAX_LINES_GT_U1) */
                       tax_line_id
                  FROM zx_detail_tax_lines_gt
                 WHERE application_id   = p_event_class_rec.application_id
                   AND entity_code      = p_event_class_rec.entity_code
                   AND event_class_code = p_event_class_rec.event_class_code
                   AND trx_id           = p_event_class_rec.trx_id
                   AND offset_flag = 'Y'
                   AND offset_link_to_tax_line_id IS NULL );

        l_row_count := SQL%ROWCOUNT + l_row_count;
      END IF;

      -- May need to be changes if  mrc_link_to_tax_line_id is added
      --
      -- Delete old MRC related detail tax lines
      --
      IF p_event_class_rec.enable_mrc_flag = 'Y' THEN
        DELETE FROM zx_lines zl
         WHERE application_id = p_event_class_rec.application_id
          AND  entity_code = p_event_class_rec.entity_code
          AND  event_class_code = p_event_class_rec.event_class_code
          AND  trx_id = p_event_class_rec.trx_id
          AND  mrc_tax_line_flag = 'Y'
          AND  (trx_line_id, trx_level_type, tax_line_number) IN
               (SELECT /*+ INDEX(ZX_DETAIL_TAX_LINES_GT ZX_DETAIL_TAX_LINES_GT_U1) */
                       trx_line_id, trx_level_type, tax_line_number
                  FROM zx_detail_tax_lines_gt
                 WHERE application_id = p_event_class_rec.application_id
                   AND entity_code = p_event_class_rec.entity_code
                   AND event_class_code = p_event_class_rec.event_class_code
                   AND trx_id = p_event_class_rec.trx_id
                   AND mrc_tax_line_flag = 'N');

        l_row_count := l_row_count + SQL%ROWCOUNT;

      END IF;
    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Delete_Detail_Lines.END',
                     'ZX_TRL_MANAGE_TAX_PKG: Delete_Detail_Lines (-)'||
                     l_row_count||' rows deleted');
    END IF;

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Delete_Detail_Lines',
                       'Unexpected error ...');
      END IF;

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      l_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Delete_Detail_Lines',
                        l_error_buffer);
      END IF;
  END Delete_Detail_Lines;

/* ===========================================================================*
 | PROCEDURE Delete_Summary_TaxLines: Deletes the transaction from            |
 | ZX_LINES_SUMMARY for a given transaction details                           |
 * ===========================================================================*/
  PROCEDURE Delete_Summary_Lines
       (x_return_status      OUT NOCOPY VARCHAR2,
        p_event_class_rec IN            ZX_API_PUB.EVENT_CLASS_REC_TYPE) IS

    l_row_count    NUMBER;
    l_error_buffer VARCHAR2(100);
    l_TRX_ID  number;
  BEGIN

    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    l_row_count := 0;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Delete_Summary_Lines.BEGIN',
                     'ZX_TRL_MANAGE_TAX_PKG: DELETE_SUMMARY_LINES (+)');
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- rewrote the following query for bug fix 5417887
    /*
    DELETE FROM ZX_LINES_SUMMARY
    WHERE APPLICATION_ID = p_event_class_rec.APPLICATION_ID
    AND ENTITY_CODE      = p_event_class_rec.ENTITY_CODE
    AND EVENT_CLASS_CODE = p_event_class_rec.EVENT_CLASS_CODE
    AND TRX_ID           = p_event_class_rec.TRX_ID;
    */

    DELETE FROM zx_lines_summary tax
    WHERE EXISTS (SELECT 1
                    FROM zx_lines_det_factors line
                   WHERE tax.application_id = line.application_id
                     AND tax.event_class_code = line.event_class_code
                     AND tax.entity_code = line.entity_code
                     AND tax.trx_id = line.trx_id
                     AND line.event_id = p_event_class_rec.event_id
                 );

    l_row_count := SQL%ROWCOUNT;

    /* bug#4374237
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
      FND_MESSAGE.SET_NAME('FND','ZX_TRL_ROWS_DELETED');
      FND_MESSAGE.SET_TOKEN('ROWS_DELETED',l_row_count);
      FND_MSG_PUB.Add;
    END IF;
    */

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Delete_Summary_Lines.END',
                     'ZX_TRL_MANAGE_TAX_PKG: DELETE_SUMMARY_LINES (-)'||
                     l_row_count||' rows deleted');
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Delete_Summary_Lines',
                       'Unexpected error ...');
      END IF;

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      l_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Delete_Summary_Lines',
                        l_error_buffer);
      END IF;
  END Delete_Summary_Lines;

/* ===========================================================================*
 | PROCEDURE Delete_Loose_Tax_Distributions: Deletes tax distributions from   |
 | ZX_REC_NREC_DIST for given tax line                                        |
 * ===========================================================================*/

  PROCEDURE Delete_Loose_Tax_Distributions
       (x_return_status      OUT NOCOPY VARCHAR2,
        p_event_class_rec IN            ZX_API_PUB.EVENT_CLASS_REC_TYPE) IS

    l_row_count      NUMBER;
    l_error_buffer   VARCHAR2(100);

  BEGIN

    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    l_row_count := 0;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
             'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Delete_Loose_Tax_Distributions.BEGIN',
             'ZX_TRL_MANAGE_TAX_PKG: Delete_Loose_Tax_Distributions (+)');
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- rewrote the following query for bug fix 5417887
    /*
    DELETE FROM ZX_REC_NREC_DIST
    WHERE APPLICATION_ID = p_event_class_rec.application_id
    AND ENTITY_CODE      = p_event_class_rec.entity_code
    AND EVENT_CLASS_CODE = p_event_class_rec.event_class_code
    AND TRX_ID           = p_event_class_rec.trx_id
    AND TAX_LINE_ID NOT IN
        (SELECT ZX_LINES.TAX_LINE_ID
           FROM ZX_LINES
          WHERE zx_lines.application_id = p_event_class_rec.application_id
            AND zx_lines.entity_code = p_event_class_rec.entity_code
            AND zx_lines.event_class_code = p_event_class_rec.event_class_code
            AND zx_lines.trx_id = p_event_class_rec.trx_id);
    */

    DELETE FROM ZX_REC_NREC_DIST dist
    WHERE EXISTS (
            SELECT 1
              FROM zx_lines_det_factors
            WHERE APPLICATION_ID   = dist.application_id
              AND ENTITY_CODE      = dist.entity_code
              AND EVENT_CLASS_CODE = dist.event_class_code
              AND TRX_ID           = dist.trx_id
              AND EVENT_ID         = p_event_class_rec.event_id )
    AND TAX_LINE_ID NOT IN
        (SELECT TAX_LINE_ID
           FROM ZX_LINES zx_lines
          WHERE zx_lines.application_id = dist.application_id
            AND zx_lines.entity_code = dist.entity_code
            AND zx_lines.event_class_code = dist.event_class_code
            AND zx_lines.trx_id = dist.trx_id);

    l_row_count := SQL%ROWCOUNT;


    /* bug#4374237
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
      FND_MESSAGE.SET_NAME('FND','ZX_TRL_ROWS_DELETED');
      FND_MESSAGE.SET_TOKEN('ROWS_DELETED',l_row_count);
      FND_MSG_PUB.Add;
    END IF;
    */

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
             'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Delete_Loose_Tax_Distributions.END',
             'ZX_TRL_MANAGE_TAX_PKG: Delete_Loose_Tax_Distributions (-)'||
                     l_row_count||' rows deleted');
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
               'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Delete_Loose_Tax_Distributions',
               'Unexpected error ...');
      END IF;

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      l_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
               'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Delete_Loose_Tax_Distributions',
                l_error_buffer);
      END IF;
  END Delete_Loose_Tax_Distributions;

/* ===========================================================================*
 | PROCEDURE Delete_Tax_Distributions: Deletes old tax distributions from     |
 | ZX_REC_NREC_DIST when new tax distributions are created in                 |
 | ZX_REC_NREC_DIST_GT                                                        |
 * ===========================================================================*/

PROCEDURE Delete_Tax_Distributions(
  x_return_status      OUT NOCOPY VARCHAR2,
  p_event_class_rec IN            ZX_API_PUB.EVENT_CLASS_REC_TYPE) IS

  l_row_count      NUMBER;
  l_error_buffer   VARCHAR2(100);

  BEGIN

    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    l_row_count := 0;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                    'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Delete_Tax_Distributions.BEGIN',
                    'ZX_TRL_MANAGE_TAX_PKG: DELETE_TAX_DISTRIBUTIONS (+)');
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    DELETE FROM zx_rec_nrec_dist
     WHERE application_id = p_event_class_rec.application_id
       AND entity_code = p_event_class_rec.entity_code
       AND event_class_code = p_event_class_rec.event_class_code
       AND trx_id = p_event_class_rec.trx_id
       AND NVL(freeze_flag, 'N') = 'N'
       AND NVL(reverse_flag, 'N') = 'N'
       AND tax_line_id IN
           (SELECT tax_line_id
              FROM zx_lines
             WHERE  trx_id = p_event_class_rec.trx_id
               AND  application_id = p_event_class_rec.application_id
               AND  entity_code = p_event_class_rec.entity_code
               AND  event_class_code = p_event_class_rec.event_class_code
               AND  reporting_only_flag = 'N'
               AND  process_for_recovery_flag = 'Y'
           );

    l_row_count := SQL%ROWCOUNT;

    /* bug#4374237
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
      FND_MESSAGE.SET_NAME('FND','ZX_TRL_ROWS_DELETED');
      FND_MESSAGE.SET_TOKEN('ROWS_DELETED',l_row_count);
      FND_MSG_PUB.Add;
    END IF;
    */

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                    'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Delete_Tax_Distributions.END',
                    'ZX_TRL_MANAGE_TAX_PKG: DELETE_TAX_DISTRIBUTIONS (-)'||
                       l_row_count||' rows deleted');
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                    'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Delete_Tax_Distributions',
                    'Unexpected error ...');
      END IF;

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    l_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Delete_Tax_Distributions',
                      l_error_buffer);
    END IF;
END Delete_Tax_Distributions;

/* ===========================================================================*
 | PROCEDURE Delete_Transaction: Deletes the tax lines in the repository      |
 * ===========================================================================*/
  PROCEDURE Delete_Transaction
       (x_return_status    OUT NOCOPY VARCHAR2,
        p_event_class_rec  IN         ZX_API_PUB.EVENT_CLASS_REC_TYPE) IS

    l_api_version CONSTANT NUMBER  := 1.0;
    l_api_name    CONSTANT VARCHAR2(30) := 'Delete_Transaction';
    l_row_count            NUMBER;
    l_error_buffer         VARCHAR2(100);

    l_msg_context_info_rec         ZX_API_PUB.CONTEXT_INFO_REC_TYPE;

    -- This cursor will check if any tax lines has frozen distributions
    CURSOR check_frozen_child IS
      SELECT TAX_LINE_ID
      FROM ZX_LINES
      WHERE APPLICATION_ID               = p_event_class_rec.APPLICATION_ID
      AND ENTITY_CODE                    = p_event_class_rec.ENTITY_CODE
      AND EVENT_CLASS_CODE               = p_event_class_rec.EVENT_CLASS_CODE
      AND TRX_ID                         = p_event_class_rec.TRX_ID
      AND Associated_Child_Frozen_Flag = 'Y';

    l_tax_line_id ZX_LINES.TAX_LINE_ID%TYPE;

  BEGIN

    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Delete_Transaction.BEGIN',
                     'ZX_TRL_MANAGE_TAX_PKG: DELETE_TRANSACTION (+)');
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT Delete_Transaction_Pvt;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    --
    -- bug#4893261- populate message structure
    --
    l_msg_context_info_rec.application_id :=
              p_event_class_rec.application_id;
    l_msg_context_info_rec.entity_code :=
              p_event_class_rec.entity_code;
    l_msg_context_info_rec.event_class_code :=
              p_event_class_rec.event_class_code;
    l_msg_context_info_rec.trx_id :=
              p_event_class_rec.trx_id;
    l_msg_context_info_rec.trx_line_id := NULL;
    l_msg_context_info_rec.trx_level_type := NULL;
    l_msg_context_info_rec.summary_tax_line_number := NULL;
    l_msg_context_info_rec.tax_line_id := NULL;
    l_msg_context_info_rec.trx_line_dist_id := NULL;

    -- Check if any lines are frozen for the transaction.
    -- If they are frozen then do not delete and raise error.
    OPEN check_frozen_child;
    FETCH check_frozen_child INTO l_tax_line_id;
      IF check_frozen_child%FOUND THEN
        CLOSE check_frozen_child;
        -- Frozen child exist hence we have to raise error and exit
        x_return_status := FND_API.G_RET_STS_ERROR;


        FND_MESSAGE.SET_NAME('ZX','ZX_CHILD_FROZEN');
        ZX_API_PUB.add_msg(l_msg_context_info_rec);
        RETURN;
      END IF;
    CLOSE check_frozen_child;

    DELETE FROM  ZX_LINES
    WHERE APPLICATION_ID          = p_event_class_rec.APPLICATION_ID
    AND   ENTITY_CODE             = p_event_class_rec.ENTITY_CODE
    AND   EVENT_CLASS_CODE        = p_event_class_rec.EVENT_CLASS_CODE
    AND   TRX_ID                  = p_event_class_rec.TRX_ID;

    IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Delete_Transaction',
                       'Number of rows deleted from zx_lines = '||l_row_count);
    END IF;

    IF p_event_class_rec.summarization_flag = 'Y' THEN
      -- Delete the summary lines

      DELETE FROM  ZX_LINES_SUMMARY
      WHERE APPLICATION_ID          = p_event_class_rec.APPLICATION_ID
      AND   ENTITY_CODE             = p_event_class_rec.ENTITY_CODE
      AND   EVENT_CLASS_CODE        = p_event_class_rec.EVENT_CLASS_CODE
      AND   TRX_ID                  = p_event_class_rec.TRX_ID;

      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Delete_Transaction',
                       'Number of rows deleted from zx_lines_summary = '||l_row_count);
      END IF;

    END IF;

    DELETE FROM ZX_REC_NREC_DIST
    WHERE APPLICATION_ID  = p_event_class_rec.APPLICATION_ID
    AND ENTITY_CODE       = p_event_class_rec.ENTITY_CODE
    AND EVENT_CLASS_CODE  = p_event_class_rec.EVENT_CLASS_CODE
    AND TRX_ID            = p_event_class_rec.TRX_ID;

    IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Delete_Transaction',
                       'Number of rows deleted from zx_rec_nrec_dist = '||l_row_count);
    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Delete_Transaction.END',
                     'ZX_TRL_MANAGE_TAX_PKG: DELETE_TRANSACTION (-)');
    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      -- x_return_status := FND_API.G_RET_STS_ERROR ;
      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Delete_Transaction',
                       'Exception:' ||SQLCODE||';'||SQLERRM);
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Delete_Transaction',
                       'Return Status = '||x_return_status);
      END IF;

      /* bug#4374237
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.SET_NAME('FND','ZX_TRL_ROWS_NOT_FOUND');
        FND_MSG_PUB.Add;
      END IF;
      */

    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Delete_Transaction',
                       'Exception:' ||SQLCODE||';'||SQLERRM);
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Delete_Transaction',
                       'Return Status = '||x_return_status);
      END IF;

      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Manage_TaxLines',
                       'Unexpected error ...');
      END IF;

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      l_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Delete_Transaction',
                        l_error_buffer);
      END IF;
  END Delete_Transaction;

/* ===========================================================================*
 | PROCEDURE Cancel_Transaction: Marks tax lines in the repository as Cancelled|
 * ===========================================================================*/

  PROCEDURE Cancel_Transaction
       (x_return_status      OUT NOCOPY VARCHAR2,
        p_event_class_rec    IN         ZX_API_PUB.EVENT_CLASS_REC_TYPE) IS

    l_row_count    NUMBER;
    l_error_buffer VARCHAR2(100);

    l_rec_nrec_tax_dist_id_tbl  num_tbl_type;
    l_tax_line_id_tbl           num_tbl_type;
    l_trx_line_dist_id_tbl      num_tbl_type;
    l_tax_dist_num_tbl          num_tbl_type;
    l_org_id_tbl                num_tbl_type;
    l_gl_date_tbl               date_tbl_type;

    l_old_tax_line_id       NUMBER;
    l_old_trx_line_dist_id  NUMBER;
    l_new_tax_dist_num      NUMBER;

    CURSOR  get_max_tax_dist_num_csr(
              c_tax_line_id    NUMBER,
              c_trx_line_dist_id  NUMBER) IS
     SELECT max(rec_nrec_tax_dist_number)
       FROM zx_rec_nrec_dist
      WHERE tax_line_id = c_tax_line_id
        AND trx_line_dist_id = c_trx_line_dist_id;

    CURSOR  get_frozen_tax_dists_csr IS
     SELECT rec_nrec_tax_dist_id,
            tax_line_id,
            trx_line_dist_id,
            rec_nrec_tax_dist_number,
            internal_organization_id,
            gl_date
       FROM zx_rec_nrec_dist
       WHERE freeze_flag      = 'Y'
         AND NVL(reverse_flag, 'N') = 'N'
         AND application_id   = p_event_class_rec.application_id
         AND entity_code      = p_event_class_rec.entity_code
         AND event_class_code = p_event_class_rec.event_class_code
         AND trx_id           = p_event_class_rec.trx_id
       ORDER BY tax_line_id, trx_line_dist_id, rec_nrec_tax_dist_number;

  BEGIN

    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Cancel_Transaction.BEGIN',
                     'ZX_TRL_MANAGE_TAX_PKG: Cancel_Transaction (+)');
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    UPDATE ZX_LINES
      SET Cancel_Flag       = 'Y'
      WHERE APPLICATION_ID = p_event_class_rec.APPLICATION_ID
      AND ENTITY_CODE      = p_event_class_rec.ENTITY_CODE
      AND EVENT_CLASS_CODE = p_event_class_rec.EVENT_CLASS_CODE
      AND TRX_ID           = p_event_class_rec.TRX_ID;

    --Add the success or failure message into the stack.

    l_row_count := SQL%ROWCOUNT;

    IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Cancel_Transaction',
                       'Number of rows updated in zx_lines = '||l_row_count);
    END IF;

    IF p_event_class_rec.summarization_flag = 'Y' THEN

      UPDATE  ZX_LINES_SUMMARY
        SET Cancel_Flag = 'Y'
        WHERE APPLICATION_ID        = p_event_class_rec.APPLICATION_ID
        AND   ENTITY_CODE           = p_event_class_rec.ENTITY_CODE
        AND   EVENT_CLASS_CODE      = p_event_class_rec.EVENT_CLASS_CODE
        AND   TRX_ID                = p_event_class_rec.TRX_ID;

      l_row_count := SQL%ROWCOUNT;

      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Cancel_Transaction',
                       'Number of rows updated in zx_lines_summary = '||l_row_count);
      END IF;

    END IF;

    OPEN  get_frozen_tax_dists_csr;
    FETCH get_frozen_tax_dists_csr BULK COLLECT INTO
           l_rec_nrec_tax_dist_id_tbl,
           l_tax_line_id_tbl,
           l_trx_line_dist_id_tbl,
           l_tax_dist_num_tbl,
           l_org_id_tbl,
           l_gl_date_tbl;
    CLOSE get_frozen_tax_dists_csr;

    l_old_tax_line_id := NUMBER_DUMMY;
    l_old_trx_line_dist_id := NUMBER_DUMMY;
    l_new_tax_dist_num := 0;

    IF l_rec_nrec_tax_dist_id_tbl.COUNT > 0 THEN

      FOR i IN NVL(l_rec_nrec_tax_dist_id_tbl.FIRST, 0) ..
               NVL(l_rec_nrec_tax_dist_id_tbl.LAST, -1)
      LOOP

        IF l_old_tax_line_id = l_tax_line_id_tbl(i) AND
           l_old_trx_line_dist_id = l_trx_line_dist_id_tbl(i) THEN
          l_new_tax_dist_num := l_new_tax_dist_num + 1;
        ELSE

          OPEN  get_max_tax_dist_num_csr(
                    l_tax_line_id_tbl(i),
                    l_trx_line_dist_id_tbl(i));
          FETCH get_max_tax_dist_num_csr INTO l_new_tax_dist_num;
          CLOSE get_max_tax_dist_num_csr;

          l_new_tax_dist_num := l_new_tax_dist_num + 1;

          l_old_tax_line_id := l_tax_line_id_tbl(i);
          l_old_trx_line_dist_id := l_trx_line_dist_id_tbl(i);

        END IF;

        l_tax_dist_num_tbl(i) := l_new_tax_dist_num;

        -- bug 6706941: populate gl_date for the reversed tax distribution
        --
        l_gl_date_tbl(i) := AP_UTILITIES_PKG.get_reversal_gl_date(
                                            p_date   => l_gl_date_tbl(i),
                                            p_org_id => l_org_id_tbl(i));

      END LOOP;

      FORALL i IN NVL(l_rec_nrec_tax_dist_id_tbl.FIRST, 0) ..
                   NVL(l_rec_nrec_tax_dist_id_tbl.LAST, -1)

        INSERT INTO ZX_REC_NREC_DIST(
                        REC_NREC_TAX_DIST_ID,
                        APPLICATION_ID,
                        ENTITY_CODE,
                        EVENT_CLASS_CODE,
                        EVENT_TYPE_CODE,
                        TRX_ID,
                        TRX_LEVEL_TYPE,
                        TRX_NUMBER,
                        TRX_LINE_ID,
                        TRX_LINE_NUMBER,
                        TAX_LINE_ID,
                        TAX_LINE_NUMBER,
                        TRX_LINE_DIST_ID,
                        ITEM_DIST_NUMBER,
                        REC_NREC_TAX_DIST_NUMBER,
                        REC_NREC_RATE,
                        RECOVERABLE_FLAG,
                        REC_NREC_TAX_AMT,
                        TAX_EVENT_CLASS_CODE,
                        TAX_EVENT_TYPE_CODE,
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
                        INCLUSIVE_FLAG,
                        RECOVERY_TYPE_ID,
                        RECOVERY_TYPE_CODE,
                        RECOVERY_RATE_ID,
                        RECOVERY_RATE_CODE,
                        REC_TYPE_RULE_FLAG,
                        NEW_REC_RATE_CODE_FLAG,
                        REVERSE_FLAG,
                        HISTORICAL_FLAG,
                        REVERSED_TAX_DIST_ID,
                        REC_NREC_TAX_AMT_TAX_CURR,
                        REC_NREC_TAX_AMT_FUNCL_CURR,
                        INTENDED_USE,
                        PROJECT_ID,
                        TASK_ID,
                        AWARD_ID,
                        EXPENDITURE_TYPE,
                        EXPENDITURE_ORGANIZATION_ID,
                        EXPENDITURE_ITEM_DATE,
                        REC_RATE_DET_RULE_FLAG,
                        LEDGER_ID,
                        SUMMARY_TAX_LINE_ID,
                        RECORD_TYPE_CODE,
                        CURRENCY_CONVERSION_DATE,
                        CURRENCY_CONVERSION_TYPE,
                        CURRENCY_CONVERSION_RATE,
                        TAX_CURRENCY_CONVERSION_DATE,
                        TAX_CURRENCY_CONVERSION_TYPE,
                        TAX_CURRENCY_CONVERSION_RATE,
                        TRX_CURRENCY_CODE,
                        TAX_CURRENCY_CODE,
                        TRX_LINE_DIST_QTY,
                        REF_DOC_TRX_LINE_DIST_QTY,
                        PRICE_DIFF,
                        QTY_DIFF,
                        PER_TRX_CURR_UNIT_NR_AMT,
                        REF_PER_TRX_CURR_UNIT_NR_AMT,
                        REF_DOC_CURR_CONV_RATE,
                        UNIT_PRICE,
                        REF_DOC_UNIT_PRICE,
                        PER_UNIT_NREC_TAX_AMT,
                        REF_DOC_PER_UNIT_NREC_TAX_AMT,
                        RATE_TAX_FACTOR,
                        TAX_APPORTIONMENT_FLAG,
                        TRX_LINE_DIST_AMT,
                        TRX_LINE_DIST_TAX_AMT,
                        ORIG_REC_NREC_RATE,
                        ORIG_REC_RATE_CODE,
                        ORIG_REC_NREC_TAX_AMT,
                        ORIG_REC_NREC_TAX_AMT_TAX_CURR,
                        ACCOUNT_CCID,
                        ACCOUNT_STRING,
                        UNROUNDED_REC_NREC_TAX_AMT,
                        APPLICABILITY_RESULT_ID,
                        REC_RATE_RESULT_ID,
                        BACKWARD_COMPATIBILITY_FLAG,
                        OVERRIDDEN_FLAG,
                        SELF_ASSESSED_FLAG,
                        FREEZE_FLAG,
                        POSTING_FLAG,
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
                        GLOBAL_ATTRIBUTE16,
                        GLOBAL_ATTRIBUTE17,
                        GLOBAL_ATTRIBUTE18,
                        GLOBAL_ATTRIBUTE19,
                        GLOBAL_ATTRIBUTE20,
                        GL_DATE,
                        REF_DOC_APPLICATION_ID,
                        REF_DOC_ENTITY_CODE,
                        REF_DOC_EVENT_CLASS_CODE,
                        REF_DOC_TRX_ID,
                        REF_DOC_LINE_ID,
                        REF_DOC_DIST_ID,
                        MINIMUM_ACCOUNTABLE_UNIT,
                        PRECISION,
                        ROUNDING_RULE_CODE,
                        TAXABLE_AMT,
                        TAXABLE_AMT_TAX_CURR,
                        TAXABLE_AMT_FUNCL_CURR,
                        TAX_ONLY_LINE_FLAG,
                        UNROUNDED_TAXABLE_AMT,
                        LEGAL_ENTITY_ID,
                        PRD_TAX_AMT,
                        PRD_TAX_AMT_TAX_CURR,
                        PRD_TAX_AMT_FUNCL_CURR,
                        PRD_TOTAL_TAX_AMT,
                        PRD_TOTAL_TAX_AMT_TAX_CURR,
                        PRD_TOTAL_TAX_AMT_FUNCL_CURR,
                        APPLIED_FROM_TAX_DIST_ID,
                        APPLIED_TO_DOC_CURR_CONV_RATE,
                        ADJUSTED_DOC_TAX_DIST_ID,
                        FUNC_CURR_ROUNDING_ADJUSTMENT,
                        TAX_APPORTIONMENT_LINE_NUMBER,
                        LAST_MANUAL_ENTRY,
                        REF_DOC_TAX_DIST_ID,
                        REF_DOC_TRX_LEVEL_TYPE,
                        MRC_TAX_DIST_FLAG,
                        MRC_LINK_TO_TAX_DIST_ID,
                        OBJECT_VERSION_NUMBER,
                        CREATED_BY,
                        CREATION_DATE,
                        LAST_UPDATED_BY,
                        LAST_UPDATE_DATE,
                        LAST_UPDATE_LOGIN,
                        INTERNAL_ORGANIZATION_ID,
                        DEF_REC_SETTLEMENT_OPTION_CODE,
                        TAX_JURISDICTION_ID,
                        ACCOUNT_SOURCE_TAX_RATE_ID)
             SELECT ZX_REC_NREC_DIST_S.NEXTVAL,
                    APPLICATION_ID,
                    ENTITY_CODE,
                    EVENT_CLASS_CODE,
                    EVENT_TYPE_CODE,
                    TRX_ID,
                    TRX_LEVEL_TYPE,
                    TRX_NUMBER,
                    TRX_LINE_ID,
                    TRX_LINE_NUMBER,
                    TAX_LINE_ID,
                    TAX_LINE_NUMBER,
                    TRX_LINE_DIST_ID,
                    ITEM_DIST_NUMBER,
                    l_tax_dist_num_tbl(i),            -- REC_NREC_TAX_DIST_NUMBER,
                    REC_NREC_RATE,
                    RECOVERABLE_FLAG,
                    - REC_NREC_TAX_AMT,
                    TAX_EVENT_CLASS_CODE,
                    TAX_EVENT_TYPE_CODE,
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
                    INCLUSIVE_FLAG,
                    RECOVERY_TYPE_ID,
                    RECOVERY_TYPE_CODE,
                    RECOVERY_RATE_ID,
                    RECOVERY_RATE_CODE,
                    REC_TYPE_RULE_FLAG,
                    NEW_REC_RATE_CODE_FLAG,
                    'Y',                              -- REVERSE_FLAG,
                    HISTORICAL_FLAG,
                    REC_NREC_TAX_DIST_ID,             -- REVERSED_TAX_DIST_ID,
                    - REC_NREC_TAX_AMT_TAX_CURR,
                    - REC_NREC_TAX_AMT_FUNCL_CURR,
                    INTENDED_USE,
                    PROJECT_ID,
                    TASK_ID,
                    AWARD_ID,
                    EXPENDITURE_TYPE,
                    EXPENDITURE_ORGANIZATION_ID,
                    EXPENDITURE_ITEM_DATE,
                    REC_RATE_DET_RULE_FLAG,
                    LEDGER_ID,
                    SUMMARY_TAX_LINE_ID,
                    RECORD_TYPE_CODE,
                    CURRENCY_CONVERSION_DATE,
                    CURRENCY_CONVERSION_TYPE,
                    CURRENCY_CONVERSION_RATE,
                    TAX_CURRENCY_CONVERSION_DATE,
                    TAX_CURRENCY_CONVERSION_TYPE,
                    TAX_CURRENCY_CONVERSION_RATE,
                    TRX_CURRENCY_CODE,
                    TAX_CURRENCY_CODE,
                    - TRX_LINE_DIST_QTY,
                    - REF_DOC_TRX_LINE_DIST_QTY,
                    PRICE_DIFF,
                    - QTY_DIFF,
                    - PER_TRX_CURR_UNIT_NR_AMT,
                    - REF_PER_TRX_CURR_UNIT_NR_AMT,
                    REF_DOC_CURR_CONV_RATE,
                    UNIT_PRICE,
                    REF_DOC_UNIT_PRICE,
                    - PER_UNIT_NREC_TAX_AMT,
                    - REF_DOC_PER_UNIT_NREC_TAX_AMT,
                    RATE_TAX_FACTOR,
                    TAX_APPORTIONMENT_FLAG,
                    - TRX_LINE_DIST_AMT,
                    - TRX_LINE_DIST_TAX_AMT,
                    NULL,                             -- ORIG_REC_NREC_RATE
                    NULL,                             -- ORIG_REC_RATE_CODE
                    NULL,                             -- ORIG_REC_NREC_TAX_AMT
                    NULL,                             -- ORIG_REC_NREC_TAX_AMT_TAX_CURR
                    ACCOUNT_CCID,
                    ACCOUNT_STRING,
                    - UNROUNDED_REC_NREC_TAX_AMT,
                    APPLICABILITY_RESULT_ID,
                    REC_RATE_RESULT_ID,
                    BACKWARD_COMPATIBILITY_FLAG,
                    'N',                              -- OVERRIDDEN_FLAG,
                    SELF_ASSESSED_FLAG,
                    'N',                              -- FREEZE_FLAG,
                    POSTING_FLAG,
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
                    GLOBAL_ATTRIBUTE16,
                    GLOBAL_ATTRIBUTE17,
                    GLOBAL_ATTRIBUTE18,
                    GLOBAL_ATTRIBUTE19,
                    GLOBAL_ATTRIBUTE20,
                    l_gl_date_tbl(i),                 -- GL_DATE,
                    REF_DOC_APPLICATION_ID,
                    REF_DOC_ENTITY_CODE,
                    REF_DOC_EVENT_CLASS_CODE,
                    REF_DOC_TRX_ID,
                    REF_DOC_LINE_ID,
                    REF_DOC_DIST_ID,
                    MINIMUM_ACCOUNTABLE_UNIT,
                    PRECISION,
                    ROUNDING_RULE_CODE,
                    - TAXABLE_AMT,
                    - TAXABLE_AMT_TAX_CURR,
                    - TAXABLE_AMT_FUNCL_CURR,
                    TAX_ONLY_LINE_FLAG,
                    - UNROUNDED_TAXABLE_AMT,
                    LEGAL_ENTITY_ID,
                    - PRD_TAX_AMT,
                    - PRD_TAX_AMT_TAX_CURR,
                    - PRD_TAX_AMT_FUNCL_CURR,
                    - PRD_TOTAL_TAX_AMT,
                    - PRD_TOTAL_TAX_AMT_TAX_CURR,
                    - PRD_TOTAL_TAX_AMT_FUNCL_CURR,
                    APPLIED_FROM_TAX_DIST_ID,
                    APPLIED_TO_DOC_CURR_CONV_RATE,
                    ADJUSTED_DOC_TAX_DIST_ID,
                    FUNC_CURR_ROUNDING_ADJUSTMENT,
                    TAX_APPORTIONMENT_LINE_NUMBER,
                    LAST_MANUAL_ENTRY,
                    REF_DOC_TAX_DIST_ID,
                    REF_DOC_TRX_LEVEL_TYPE,
                    MRC_TAX_DIST_FLAG,
                    MRC_LINK_TO_TAX_DIST_ID,
                    1,                                --OBJECT_VERSION_NUMBER,
                    FND_GLOBAL.USER_ID,               -- CREATED_BY,
                    SYSDATE,                          -- CREATION_DATE,
                    FND_GLOBAL.USER_ID,               -- LAST_UPDATED_BY,
                    SYSDATE,                          -- LAST_UPDATE_DATE,
                    FND_GLOBAL.LOGIN_ID,              -- LAST_UPDATE_LOGIN
                    INTERNAL_ORGANIZATION_ID,
                    DEF_REC_SETTLEMENT_OPTION_CODE,
                    TAX_JURISDICTION_ID,
                    ACCOUNT_SOURCE_TAX_RATE_ID
             FROM ZX_REC_NREC_DIST
             WHERE rec_nrec_tax_dist_id = l_rec_nrec_tax_dist_id_tbl(i);

      l_row_count := SQL%ROWCOUNT;

      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Cancel_Transaction',
                       'Number of rows updated in zx_rec_nrec_dist = '||l_row_count);
      END IF;

      FORALL i IN NVL(l_rec_nrec_tax_dist_id_tbl.FIRST, 0) ..
                  NVL(l_rec_nrec_tax_dist_id_tbl.LAST, -1)
        UPDATE zx_rec_nrec_dist
           SET reverse_flag = 'Y'
         WHERE rec_nrec_tax_dist_id = l_rec_nrec_tax_dist_id_tbl(i);

      l_row_count := SQL%ROWCOUNT;

      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Cancel_Transaction',
                       'Number of rows updated in zx_rec_nrec_dist = '||l_row_count);
      END IF;

    END IF;    -- _rec_nrec_tax_dist_id_tbl.COUNT > 0

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Cancel_Transaction.END',
                     'ZX_TRL_MANAGE_TAX_PKG: CANCEL_TRANSACTION (-)');
    END IF;

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Cancel_Transaction',
                       'Exception:' ||SQLCODE||';'||SQLERRM);
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Cancel_Transaction',
                       'Return Status = '||x_return_status);
      END IF;

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      l_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

      IF (g_level_unexpected >= g_current_runtime_level ) THEN

        FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Cancel_Transaction',
                        l_error_buffer);
      END IF;
  END Cancel_Transaction;

/* ===============================================================================*
 | PROCEDURE Purge_Transaction: Deletes tax lines in the repository (in Phase 1a)|
 * ===============================================================================*/

  PROCEDURE Purge_Transaction
       (x_return_status      OUT NOCOPY VARCHAR2,
        p_event_class_rec    IN         ZX_API_PUB.EVENT_CLASS_REC_TYPE) IS

    l_return_status   VARCHAR2(1);
    l_error_buffer    VARCHAR2(100);

  BEGIN

    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Purge_Transaction.BEGIN',
                     'ZX_TRL_MANAGE_TAX_PKG: PURGE_TRANSACTION (+)');
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    Delete_Transaction (x_return_status   => l_return_status,
                        p_event_class_rec => p_event_class_rec);

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Delete_Transaction',
                       'Return Status = '||l_return_status);
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Purge_Transaction',
                       'Return Status = '||l_return_status);
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Purge_Transaction.END',
                     'ZX_TRL_MANAGE_TAX_PKG: PURGE_TRANSACTION (-)');
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Purge_Transaction',
                       'Exception:' ||SQLCODE||';'||SQLERRM);
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Purge_Transaction',
                       'Return Status = '||x_return_status);
      END IF;

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      l_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Purge_Transaction',
                       'Return Status = '||x_return_status);
      END IF;

      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Purge_Transaction',
                        l_error_buffer);
      END IF;

  END Purge_Transaction;


/* ===========================================================================*
 | PROCEDURE Mark_Detail_Tax_Lines_Delete: Marks tax lines in the repository  |
 | as Deleted                                                                 |
 * ===========================================================================*/

  PROCEDURE Mark_Detail_Tax_Lines_Delete
       (x_return_status        OUT NOCOPY VARCHAR2,
        p_transaction_line_rec IN         ZX_API_PUB.TRANSACTION_LINE_REC_TYPE) IS

    l_row_count         NUMBER;
    l_freeze_dists_num  NUMBER;
    l_error_buffer      VARCHAR2(100);

    CURSOR check_dist IS
      SELECT count(*) frozen_rec
      FROM ZX_REC_NREC_DIST
      WHERE application_id = p_transaction_line_rec.application_id
      AND entity_code      = p_transaction_line_rec.entity_code
      AND event_class_code = p_transaction_line_rec.event_class_code
      AND trx_id           = p_transaction_line_rec.trx_id
      AND trx_line_id      = p_transaction_line_rec.trx_line_id
      AND trx_level_type   = p_transaction_line_rec.trx_level_type
      AND Freeze_Flag = 'Y';

  BEGIN

    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Mark_Detail_Tax_Lines_Delete.BEGIN',
                     'ZX_TRL_MANAGE_TAX_PKG: MARK_DETAIL_TAX_LINES_DELETE (+)');
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Check if any associated distributions are marked frozen.
    OPEN check_dist;
    Fetch check_dist INTO l_freeze_dists_num;
    CLOSE check_dist;

    IF l_freeze_dists_num > 0 THEN

      APP_EXCEPTION.Raise_Exception;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    UPDATE ZX_LINES
      SET Delete_Flag       = 'Y'
      WHERE APPLICATION_ID = p_transaction_line_rec.APPLICATION_ID
      AND ENTITY_CODE      = p_transaction_line_rec.ENTITY_CODE
      AND EVENT_CLASS_CODE = p_transaction_line_rec.EVENT_CLASS_CODE
      AND TRX_ID           = p_transaction_line_rec.TRX_ID
      AND TRX_LINE_ID      = p_transaction_line_rec.TRX_LINE_ID
      AND TRX_LEVEL_TYPE   = p_transaction_line_rec.TRX_LEVEL_TYPE;

    --Add the success or failure message into the stack.

    IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Mark_Detail_Tax_Lines_Delete',
                       'Number of rows updated in zx_lines = '||l_row_count);
    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Mark_Detail_Tax_Lines_Delete.END',
                     'ZX_TRL_MANAGE_TAX_PKG: MARK_DETAIL_TAX_LINES_DELETE (-)');
    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      -- x_return_status := FND_API.G_RET_STS_ERROR ;
      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Mark_Detail_Tax_Lines_Delete',
                       'Exception:' ||SQLCODE||';'||SQLERRM);

        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Mark_Detail_Tax_Lines_Delete',
                       'Return Status = '||x_return_status);
      END IF;

      /* bug#4374237
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.SET_NAME('FND','ZX_TRL_ROWS_NOT_FOUND');
        FND_MSG_PUB.Add;
      END IF;
      */

    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Mark_Detail_Tax_Lines_Delete',
                       'Exception:' ||SQLCODE||';'||SQLERRM);

        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Mark_Detail_Tax_Lines_Delete',
                       'Return Status = '||x_return_status);
      END IF;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Mark_Detail_Tax_Lines_Delete',
                       'Unexpected Error:' ||SQLCODE||';'||SQLERRM);
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Mark_Detail_Tax_Lines_Delete',
                       'Return Status = '||x_return_status);
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Mark_Detail_Tax_Lines_Delete',
                       'Unexpected error ...');
      END IF;

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      l_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Mark_Detail_Tax_Lines_Delete',
                       'Exception:Others:' ||SQLCODE||';'||SQLERRM);

        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Mark_Detail_Tax_Lines_Delete',
                       'Return Status = '||x_return_status);
      END IF;
  END Mark_Detail_Tax_Lines_Delete;

/*============================================================================*
 | PROCEDURE Create_Tax_Distributions: Inserts distribution lines into        |
 |                                     ZX_REC_NREC_DIST table.                |
 *============================================================================*/

  PROCEDURE Create_Tax_Distributions
       (x_return_status OUT NOCOPY VARCHAR2) IS

    l_error_buffer  VARCHAR2(100);

  BEGIN

    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Create_Tax_Distributions.BEGIN',
                     'ZX_TRL_MANAGE_TAX_PKG: Create_Tax_Distributions (+)');
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    INSERT INTO ZX_REC_NREC_DIST (REC_NREC_TAX_DIST_ID,
                                  APPLICATION_ID,
                                  ENTITY_CODE,
                                  EVENT_CLASS_CODE,
                                  EVENT_TYPE_CODE,
                                  TRX_ID,
                                  TRX_LEVEL_TYPE,
                                  TRX_NUMBER,
                                  TRX_LINE_ID,
                                  TRX_LINE_NUMBER,
                                  TAX_LINE_ID,
                                  TAX_LINE_NUMBER,
                                  TRX_LINE_DIST_ID,
                                  ITEM_DIST_NUMBER,
                                  REC_NREC_TAX_DIST_NUMBER,
                                  REC_NREC_RATE,
                                  RECOVERABLE_FLAG,
                                  REC_NREC_TAX_AMT,
                                  TAX_EVENT_CLASS_CODE,
                                  TAX_EVENT_TYPE_CODE,
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
                                  INCLUSIVE_FLAG,
                                  RECOVERY_TYPE_ID,
                                  RECOVERY_TYPE_CODE,
                                  RECOVERY_RATE_ID,
                                  RECOVERY_RATE_CODE,
                                  REC_TYPE_RULE_FLAG,
                                  NEW_REC_RATE_CODE_FLAG,
                                  REVERSE_FLAG,
                                  HISTORICAL_FLAG,
                                  REVERSED_TAX_DIST_ID,
                                  REC_NREC_TAX_AMT_TAX_CURR,
                                  REC_NREC_TAX_AMT_FUNCL_CURR,
                                  INTENDED_USE,
                                  PROJECT_ID,
                                  TASK_ID,
                                  AWARD_ID,
                                  EXPENDITURE_TYPE,
                                  EXPENDITURE_ORGANIZATION_ID,
                                  EXPENDITURE_ITEM_DATE,
                                  REC_RATE_DET_RULE_FLAG,
                                  LEDGER_ID,
                                  SUMMARY_TAX_LINE_ID,
                                  RECORD_TYPE_CODE,
                                  CURRENCY_CONVERSION_DATE,
                                  CURRENCY_CONVERSION_TYPE,
                                  CURRENCY_CONVERSION_RATE,
                                  TAX_CURRENCY_CONVERSION_DATE,
                                  TAX_CURRENCY_CONVERSION_TYPE,
                                  TAX_CURRENCY_CONVERSION_RATE,
                                  TRX_CURRENCY_CODE,
                                  TAX_CURRENCY_CODE,
                                  TRX_LINE_DIST_QTY,
                                  REF_DOC_TRX_LINE_DIST_QTY,
                                  PRICE_DIFF,
                                  QTY_DIFF,
                                  PER_TRX_CURR_UNIT_NR_AMT,
                                  REF_PER_TRX_CURR_UNIT_NR_AMT,
                                  REF_DOC_CURR_CONV_RATE,
                                  UNIT_PRICE,
                                  REF_DOC_UNIT_PRICE,
                                  PER_UNIT_NREC_TAX_AMT,
                                  REF_DOC_PER_UNIT_NREC_TAX_AMT,
                                  RATE_TAX_FACTOR,
                                  TAX_APPORTIONMENT_FLAG,
                                  TRX_LINE_DIST_AMT,
                                  TRX_LINE_DIST_TAX_AMT,
                                  ORIG_REC_NREC_RATE,
                                  ORIG_REC_RATE_CODE,
                                  ORIG_REC_NREC_TAX_AMT,
                                  ORIG_REC_NREC_TAX_AMT_TAX_CURR,
                                  ACCOUNT_CCID,
                                  ACCOUNT_STRING,
                                  UNROUNDED_REC_NREC_TAX_AMT,
                                  APPLICABILITY_RESULT_ID,
                                  REC_RATE_RESULT_ID,
                                  BACKWARD_COMPATIBILITY_FLAG,
                                  OVERRIDDEN_FLAG,
                                  SELF_ASSESSED_FLAG,
                                  FREEZE_FLAG,
                                  POSTING_FLAG,
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
                                  GLOBAL_ATTRIBUTE16,
                                  GLOBAL_ATTRIBUTE17,
                                  GLOBAL_ATTRIBUTE18,
                                  GLOBAL_ATTRIBUTE19,
                                  GLOBAL_ATTRIBUTE20,
                                  GL_DATE,
                                  REF_DOC_APPLICATION_ID,
                                  REF_DOC_ENTITY_CODE,
                                  REF_DOC_EVENT_CLASS_CODE,
                                  REF_DOC_TRX_ID,
                                  REF_DOC_LINE_ID,
                                  REF_DOC_DIST_ID,
                                  MINIMUM_ACCOUNTABLE_UNIT,
                                  PRECISION,
                                  ROUNDING_RULE_CODE,
                                  TAXABLE_AMT,
                                  TAXABLE_AMT_TAX_CURR,
                                  TAXABLE_AMT_FUNCL_CURR,
                                  TAX_ONLY_LINE_FLAG,
                                  UNROUNDED_TAXABLE_AMT,
                                  LEGAL_ENTITY_ID,
                                  PRD_TAX_AMT,
                                  PRD_TAX_AMT_TAX_CURR,
                                  PRD_TAX_AMT_FUNCL_CURR,
                                  PRD_TOTAL_TAX_AMT,
                                  PRD_TOTAL_TAX_AMT_TAX_CURR,
                                  PRD_TOTAL_TAX_AMT_FUNCL_CURR,
                                  APPLIED_FROM_TAX_DIST_ID,
                                  APPLIED_TO_DOC_CURR_CONV_RATE,
                                  ADJUSTED_DOC_TAX_DIST_ID,
                                  FUNC_CURR_ROUNDING_ADJUSTMENT,
                                  TAX_APPORTIONMENT_LINE_NUMBER,
                                  LAST_MANUAL_ENTRY,
                                  REF_DOC_TAX_DIST_ID,
                                  REF_DOC_TRX_LEVEL_TYPE,
                                  MRC_TAX_DIST_FLAG,
                                  MRC_LINK_TO_TAX_DIST_ID,
                                  OBJECT_VERSION_NUMBER,
                                  CREATED_BY,
                                  CREATION_DATE,
                                  LAST_UPDATED_BY,
                                  LAST_UPDATE_DATE,
                                  LAST_UPDATE_LOGIN,
                                  INTERNAL_ORGANIZATION_ID,
                                  DEF_REC_SETTLEMENT_OPTION_CODE,
                                  TAX_JURISDICTION_ID,
                                  ACCOUNT_SOURCE_TAX_RATE_ID)
                           SELECT REC_NREC_TAX_DIST_ID,
                                  APPLICATION_ID,
                                  ENTITY_CODE,
                                  EVENT_CLASS_CODE,
                                  EVENT_TYPE_CODE,
                                  TRX_ID,
                                  TRX_LEVEL_TYPE,
                                  TRX_NUMBER,
                                  TRX_LINE_ID,
                                  TRX_LINE_NUMBER,
                                  TAX_LINE_ID,
                                  TAX_LINE_NUMBER,
                                  TRX_LINE_DIST_ID,
                                  ITEM_DIST_NUMBER,
                                  REC_NREC_TAX_DIST_NUMBER,
                                  REC_NREC_RATE,
                                  RECOVERABLE_FLAG,
                                  REC_NREC_TAX_AMT,
                                  TAX_EVENT_CLASS_CODE,
                                  TAX_EVENT_TYPE_CODE,
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
                                  INCLUSIVE_FLAG,
                                  RECOVERY_TYPE_ID,
                                  RECOVERY_TYPE_CODE,
                                  RECOVERY_RATE_ID,
                                  RECOVERY_RATE_CODE,
                                  REC_TYPE_RULE_FLAG,
                                  NEW_REC_RATE_CODE_FLAG,
                                  REVERSE_FLAG,
                                  HISTORICAL_FLAG,
                                  REVERSED_TAX_DIST_ID,
                                  REC_NREC_TAX_AMT_TAX_CURR,
                                  REC_NREC_TAX_AMT_FUNCL_CURR,
                                  INTENDED_USE,
                                  PROJECT_ID,
                                  TASK_ID,
                                  AWARD_ID,
                                  EXPENDITURE_TYPE,
                                  EXPENDITURE_ORGANIZATION_ID,
                                  EXPENDITURE_ITEM_DATE,
                                  REC_RATE_DET_RULE_FLAG,
                                  LEDGER_ID,
                                  SUMMARY_TAX_LINE_ID,
                                  RECORD_TYPE_CODE,
                                  CURRENCY_CONVERSION_DATE,
                                  CURRENCY_CONVERSION_TYPE,
                                  CURRENCY_CONVERSION_RATE,
                                  TAX_CURRENCY_CONVERSION_DATE,
                                  TAX_CURRENCY_CONVERSION_TYPE,
                                  TAX_CURRENCY_CONVERSION_RATE,
                                  TRX_CURRENCY_CODE,
                                  TAX_CURRENCY_CODE,
                                  TRX_LINE_DIST_QTY,
                                  REF_DOC_TRX_LINE_DIST_QTY,
                                  PRICE_DIFF,
                                  QTY_DIFF,
                                  PER_TRX_CURR_UNIT_NR_AMT,
                                  REF_PER_TRX_CURR_UNIT_NR_AMT,
                                  REF_DOC_CURR_CONV_RATE,
                                  UNIT_PRICE,
                                  REF_DOC_UNIT_PRICE,
                                  PER_UNIT_NREC_TAX_AMT,
                                  REF_DOC_PER_UNIT_NREC_TAX_AMT,
                                  RATE_TAX_FACTOR,
                                  TAX_APPORTIONMENT_FLAG,
                                  TRX_LINE_DIST_AMT,
                                  TRX_LINE_DIST_TAX_AMT,
                                  ORIG_REC_NREC_RATE,
                                  ORIG_REC_RATE_CODE,
                                  ORIG_REC_NREC_TAX_AMT,
                                  ORIG_REC_NREC_TAX_AMT_TAX_CURR,
                                  ACCOUNT_CCID,
                                  ACCOUNT_STRING,
                                  UNROUNDED_REC_NREC_TAX_AMT,
                                  APPLICABILITY_RESULT_ID,
                                  REC_RATE_RESULT_ID,
                                  BACKWARD_COMPATIBILITY_FLAG,
                                  OVERRIDDEN_FLAG,
                                  SELF_ASSESSED_FLAG,
                                  DECODE(tax_only_line_flag, 'Y', 'Y', FREEZE_FLAG),
                                  POSTING_FLAG,
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
                                  GLOBAL_ATTRIBUTE16,
                                  GLOBAL_ATTRIBUTE17,
                                  GLOBAL_ATTRIBUTE18,
                                  GLOBAL_ATTRIBUTE19,
                                  GLOBAL_ATTRIBUTE20,
                                  GL_DATE,
                                  REF_DOC_APPLICATION_ID,
                                  REF_DOC_ENTITY_CODE,
                                  REF_DOC_EVENT_CLASS_CODE,
                                  REF_DOC_TRX_ID,
                                  REF_DOC_LINE_ID,
                                  REF_DOC_DIST_ID,
                                  MINIMUM_ACCOUNTABLE_UNIT,
                                  PRECISION,
                                  ROUNDING_RULE_CODE,
                                  TAXABLE_AMT,
                                  TAXABLE_AMT_TAX_CURR,
                                  TAXABLE_AMT_FUNCL_CURR,
                                  TAX_ONLY_LINE_FLAG,
                                  UNROUNDED_TAXABLE_AMT,
                                  LEGAL_ENTITY_ID,
                                  PRD_TAX_AMT,
                                  PRD_TAX_AMT_TAX_CURR,
                                  PRD_TAX_AMT_FUNCL_CURR,
                                  PRD_TOTAL_TAX_AMT,
                                  PRD_TOTAL_TAX_AMT_TAX_CURR,
                                  PRD_TOTAL_TAX_AMT_FUNCL_CURR,
                                  APPLIED_FROM_TAX_DIST_ID,
                                  APPLIED_TO_DOC_CURR_CONV_RATE,
                                  ADJUSTED_DOC_TAX_DIST_ID,
                                  FUNC_CURR_ROUNDING_ADJUSTMENT,
                                  TAX_APPORTIONMENT_LINE_NUMBER,
                                  LAST_MANUAL_ENTRY,
                                  REF_DOC_TAX_DIST_ID,
                                  REF_DOC_TRX_LEVEL_TYPE,
                                  MRC_TAX_DIST_FLAG,
                                  MRC_LINK_TO_TAX_DIST_ID,
                                  1,        --OBJECT_VERSION_NUMBER,
                                  CREATED_BY,
                                  CREATION_DATE,
                                  LAST_UPDATED_BY,
                                  LAST_UPDATE_DATE,
                                  LAST_UPDATE_LOGIN,
                                  INTERNAL_ORGANIZATION_ID,
                                  DEF_REC_SETTLEMENT_OPTION_CODE,
                                  TAX_JURISDICTION_ID,
                                  ACCOUNT_SOURCE_TAX_RATE_ID
                             FROM ZX_REC_NREC_DIST_GT;

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Create_Tax_Distributions',
                     'Number of Rows Inserted: '||SQL%ROWCOUNT);
    END IF;

    BEGIN
      UPDATE zx_lines
         SET associated_child_frozen_flag = 'Y'
       WHERE tax_line_id IN
             (SELECT tax_line_id
                FROM zx_rec_nrec_dist_gt
               WHERE tax_only_line_flag = 'Y'
             );
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Create_Tax_Distributions',
                     'Number of Tax Lines Updated: '||SQL%ROWCOUNT);
    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Create_Tax_Distributions.END',
                     'ZX_TRL_MANAGE_TAX_PKG: CREATE_TAX_DISTRIBUTIONS (-)');
    END IF;

  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Create_Tax_Distributions',
                       'Exception:' ||SQLCODE||';'||SQLERRM);

        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Create_Tax_Distributions',
                       'Return Status = '||x_return_status);
      END IF;
      -- bug#4893261- move to wrapper since do not
      -- have event_class_rec here to set message index
      --
      -- FND_MESSAGE.SET_NAME('ZX','ZX_TRL_RECORD_ALREADY_EXISTS');
      -- ZX_API_PUB.add_msg(l_msg_context_info_rec);


    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Create_Tax_Distributions',
                       'Exception:Others:' ||SQLCODE||';'||SQLERRM);

        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Create_Tax_Distributions',
                       'Return Status = '||x_return_status);
      END IF;
  END Create_Tax_Distributions;

/*============================================================================*
 | Delete_Dist_Marked_For_Delete: Deletes all the tax distributions from      |
 | ZX_REC_NREC_DIST that are associated with tax lines whose                  |
 | Process_For_Recovery_Flag is 'Y' or Item_Dist_Changed_Flag is 'Y'.           |
 *============================================================================*/

  PROCEDURE Delete_Dist_Marked_For_Delete
       (x_return_status    OUT NOCOPY VARCHAR2,
        p_event_class_rec  IN         ZX_API_PUB.EVENT_CLASS_REC_TYPE) IS

    l_api_name CONSTANT     VARCHAR2(30) := 'Delete_Dist_Marked_For_Delete';
    l_error_buffer          VARCHAR2(100);
    l_msg_context_info_rec  ZX_API_PUB.CONTEXT_INFO_REC_TYPE;

  BEGIN

    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Delete_Dist_Marked_For_Delete.BEGIN',
                     'ZX_TRL_MANAGE_TAX_PKG: DELETE_DIST_MARKED_FOR_DELETE (+)');
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- bug#4893261- populate message structure
    --
    l_msg_context_info_rec.application_id :=
              p_event_class_rec.application_id;
    l_msg_context_info_rec.entity_code :=
              p_event_class_rec.entity_code;
    l_msg_context_info_rec.event_class_code :=
              p_event_class_rec.event_class_code;
    l_msg_context_info_rec.trx_id := NULL;
    --        p_event_class_rec.trx_id;
    l_msg_context_info_rec.trx_line_id := NULL;
    l_msg_context_info_rec.trx_level_type := NULL;
    l_msg_context_info_rec.summary_tax_line_number := NULL;
    l_msg_context_info_rec.tax_line_id := NULL;
    l_msg_context_info_rec.trx_line_dist_id := NULL;

    IF p_event_class_rec.application_id is NULL OR
       p_event_class_rec.entity_code is NULL OR
       p_event_class_rec.event_class_code is NULL
   --  OR  p_event_class_rec.trx_id is NULL
    THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Delete_Dist_Marked_For_Delete',
                       'Return Status = '||x_return_status);
      END IF;

      --FND_MESSAGE.SET_NAME('ZX','ZX_TRL_NULL_VALUES');
      --ZX_API_PUB.add_msg(l_msg_context_info_rec);

    ELSE
      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Delete_Dist_Marked_For_Delete',
                       'Delete from ZX_REC_NREC_DIST (+)');

        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Delete_Dist_Marked_For_Delete',
                       'Application Id: '  ||p_event_class_rec.application_id);

        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Delete_Dist_Marked_For_Delete',
                       'Entity Code: '     ||p_event_class_rec.entity_code);

        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Delete_Dist_Marked_For_Delete',
                       'Event Class Code: '||p_event_class_rec.event_class_code);

     /*
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Delete_Dist_Marked_For_Delete',
                       'Trx Id: '          ||p_event_class_rec.trx_id);
     */
        END IF;


      DELETE FROM ZX_REC_NREC_DIST
      WHERE NVL(Reverse_Flag,'N') = 'N'
        AND TAX_LINE_ID IN (SELECT TAX_LINE_ID
                            FROM ZX_LINES L
                           WHERE APPLICATION_ID = p_event_class_rec.application_id
                             AND ENTITY_CODE      = p_event_class_rec.entity_code
                             AND EVENT_CLASS_CODE = p_event_class_rec.event_class_code
                             AND (Process_For_Recovery_Flag = 'Y' OR
                                  Item_Dist_Changed_Flag = 'Y')
                             AND EXISTS
                                (SELECT 1
                                     FROM zx_lines_det_factors
                                    WHERE APPLICATION_ID   = L.application_id
                                      AND ENTITY_CODE      = L.entity_code
                                      AND EVENT_CLASS_CODE = L.event_class_code
                                      AND TRX_ID           = L.trx_id
                                      AND TRX_LINE_ID      = L.trx_line_id
                                      AND TRX_LEVEL_TYPE   = L.trx_level_type
                                      AND EVENT_ID         = p_event_class_rec.event_id
                                 )
                           );

    END IF;

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Delete_Dist_Marked_For_Delete',
                     'Number of Rows Deleted ='||SQL%ROWCOUNT);
    END IF;

    -- bug6890360: synchronize tax_line_number for reversed tax dustributions,
    --  which are not fetched back for processing
    --
    BEGIN
      UPDATE zx_rec_nrec_dist zd
         SET tax_line_number =
             (SELECT tax_line_number
                FROM zx_lines
               WHERE tax_line_id = zd.tax_line_id
                 AND tax_line_number <> zd.tax_line_number
             )
      WHERE NVL(reverse_flag,'N') = 'Y'
        AND application_id = p_event_class_rec.application_id
        AND entity_code      = p_event_class_rec.entity_code
        AND event_class_code = p_event_class_rec.event_class_code
        AND (trx_id, trx_line_id, trx_level_type) IN
            (SELECT /*+ use_hash(ZX_LINES_DET_FACTORS) */ TRX_ID, TRX_LINE_ID, TRX_LEVEL_TYPE
               FROM zx_lines_det_factors
              WHERE application_id   = p_event_class_rec.application_id
                AND entity_code      = p_event_class_rec.entity_code
                AND event_class_code = p_event_class_rec.event_class_code
                AND event_id         = p_event_class_rec.event_id
             )
        AND EXISTS
            (SELECT tax_line_number
                FROM zx_lines
               WHERE tax_line_id = zd.tax_line_id
                 AND tax_line_number <> zd.tax_line_number
             );

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Delete_Dist_Marked_For_Delete',
                     'Number of Rows Updated ='||SQL%ROWCOUNT);
    END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
      WHEN OTHERS THEN
        NULL;
    END;


    BEGIN
      UPDATE zx_rec_nrec_dist zd
         SET summary_tax_line_id =
             (SELECT summary_tax_line_id
                FROM zx_rec_nrec_dist_gt gt
               WHERE gt.tax_line_id = zd.tax_line_id
                 AND gt.trx_line_dist_id = zd.trx_line_dist_id
                 AND ROWNUM = 1
             )
       WHERE reverse_flag = 'Y'
         AND tax_line_id IN
             (SELECT tax_line_id
                FROM zx_lines zl
               WHERE application_id   = p_event_class_rec.application_id
                 AND entity_code      = p_event_class_rec.entity_code
                 AND event_class_code = p_event_class_rec.event_class_code
                 AND (process_for_recovery_flag = 'Y' OR
                      item_dist_changed_flag = 'Y')
                 AND EXISTS
                    (SELECT 1
                       FROM zx_lines_det_factors
                      WHERE application_id   = zl.application_id
                        AND entity_code      = zl.entity_code
                        AND event_class_code = zl.event_class_code
                        AND trx_id           = zl.trx_id
                        AND trx_line_id      = zl.trx_line_id
                        AND trx_level_type   = zl.trx_level_type
                        AND event_id         = p_event_class_rec.event_id
                     )
              )
         AND EXISTS
             (SELECT summary_tax_line_id
                FROM zx_rec_nrec_dist_gt gt
               WHERE gt.tax_line_id = zd.tax_line_id
                 AND gt.trx_line_dist_id = zd.trx_line_dist_id
             );

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Delete_Dist_Marked_For_Delete',
                     'Number of Rows Updated ='||SQL%ROWCOUNT);
    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Delete_Dist_Marked_For_Delete.END',
                     'ZX_TRL_MANAGE_TAX_PKG: DELETE_DIST_MARKED_FOR_DELETE (-)');
    END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
      WHEN OTHERS THEN
        NULL;
    END;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Delete_Dist_Marked_For_Delete',
                       'Exception:Others:' ||SQLCODE||';'||SQLERRM);

        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Delete_Dist_Marked_For_Delete',
                       'Return Status = '||x_return_status);
      END IF;
  END Delete_Dist_Marked_For_Delete;

/*================================================================================*
 | Update_TaxLine_Rec_Nrec_Amt: Updates the total recoverable and non-recoverable |
 |                              tax amounts for each detail tax line and          |
 |                              summary tax line.                                 |
 *================================================================================*/

  PROCEDURE Update_TaxLine_Rec_Nrec_Amt
       (x_return_status     OUT NOCOPY VARCHAR2,
        p_event_class_rec   IN         ZX_API_PUB.EVENT_CLASS_REC_TYPE) IS

    l_error_buffer  VARCHAR2(100);

  BEGIN

    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Update_TaxLine_Rec_Nrec_Amt.BEGIN',
                     'ZX_TRL_MANAGE_TAX_PKG: Update_TaxLine_Rec_Nrec_Amt (+)');
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    select trx_id, trx_line_id, trx_level_type
    bulk collect into pg_trx_id_tab, pg_trx_line_id_tab ,pg_trx_level_type_tab
    from zx_lines_det_factors
    where  application_id = p_event_class_rec.application_id
    and    entity_code =  p_event_class_rec.entity_code
    and    event_class_code = p_event_class_rec.event_class_code
    and    event_id  = p_event_class_rec.event_id;

    FORALL i in nvl(pg_trx_id_tab.FIRST,0)..nvl(pg_trx_id_tab.LAST,-99)
      UPDATE ZX_LINES  L
        SET (rec_tax_amt,
             rec_tax_amt_tax_curr,
             rec_tax_amt_funcl_curr,
             nrec_tax_amt,
             nrec_tax_amt_tax_curr,
             nrec_tax_amt_funcl_curr,
             Process_For_Recovery_Flag,
             Item_Dist_Changed_Flag
            ) =
          (SELECT SUM(decode(Recoverable_Flag,'Y',rec_nrec_tax_amt)) rec_tax_amt,
                  SUM(decode(Recoverable_Flag,'Y',rec_nrec_tax_amt_tax_curr)) rec_tax_amt_tax_curr,
                  SUM(decode(Recoverable_Flag,'Y',rec_nrec_tax_amt_funcl_curr)) rec_tax_amt_funcl_curr,
                  SUM(decode(Recoverable_Flag,'N',rec_nrec_tax_amt)) nrec_tax_amt,
                  SUM(decode(Recoverable_Flag,'N',rec_nrec_tax_amt_tax_curr)) nrec_tax_amt_tax_curr,
                  SUM(decode(Recoverable_Flag,'N',rec_nrec_tax_amt_funcl_curr)) nrec_tax_amt_funcl_curr,
                  'N'  Process_For_Recovery_Flag,
                  'N'  Item_Dist_Changed_Flag
             FROM  ZX_REC_NREC_DIST  D
             WHERE D.tax_line_id      = L.tax_line_id
               AND D.application_id   = L.application_id
               AND D.entity_code      = L.entity_code
               AND D.event_class_code = L.event_class_code
               AND D.trx_id           = L.trx_id
               AND D.trx_line_id      = L.trx_line_id
               AND D.trx_level_type   = L.trx_level_type
          )
      WHERE application_id   = p_event_class_rec.application_id
        AND entity_code      = p_event_class_rec.entity_code
        AND event_class_code = p_event_class_rec.event_class_code
        /*AND exists
          ( select 1 from zx_lines_det_factors
            where  application_id = l.application_id
            and    entity_code =  l.entity_code
            and    event_class_code = l.event_class_code
            and    trx_id = l.trx_id
            and    trx_line_id = l.trx_line_id
            and    trx_level_type = l.trx_level_type
            and    event_id  = p_event_class_rec.event_id)
        */
       AND trx_id = pg_trx_id_tab(i)
       AND trx_line_id = pg_trx_line_id_tab(i)
       AND trx_level_type = pg_trx_level_type_tab(i);

    IF p_event_class_rec.summarization_flag = 'Y' THEN

      UPDATE ZX_LINES_SUMMARY  S
        SET (total_rec_tax_amt,
             total_nrec_tax_amt,
             total_rec_tax_amt_funcl_curr,
             total_nrec_tax_amt_funcl_curr,
             total_rec_tax_amt_tax_curr,
             total_nrec_tax_amt_tax_curr
            ) =
            (SELECT
                 SUM(rec_tax_amt) total_rec_tax_amt,
                 SUM(nrec_tax_amt) total_nrec_tax_amt,
                 SUM(rec_tax_amt_funcl_curr) total_rec_tax_amt_funcl_curr,
                 SUM(nrec_tax_amt_funcl_curr) total_nrec_tax_amt_funcl_curr,
                 SUM(rec_tax_amt_tax_curr) total_rec_tax_amt_tax_curr,
                 SUM(nrec_tax_amt_tax_curr) total_nrec_tax_amt_tax_curr
               FROM  ZX_LINES L
               WHERE L.summary_tax_line_id = S.summary_tax_line_id
                 AND L.application_id      = S.application_id
                 AND L.entity_code         = S.entity_code
                 AND L.event_class_code    = S.event_class_code
                 AND L.trx_id              = S.trx_id
            )
      WHERE application_id   = p_event_class_rec.application_id
        AND entity_code      = p_event_class_rec.entity_code
        AND event_class_code = p_event_class_rec.event_class_code
        AND exists
          ( select 1 from zx_lines_det_factors
            where  application_id = S.application_id
            and    entity_code =  S.entity_code
            and    event_class_code = S.event_class_code
            and    trx_id = S.trx_id
            and    event_id  = p_event_class_rec.event_id)
     --   AND trx_id           = p_event_class_rec.trx_id
     ;

    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Update_TaxLine_Rec_Nrec_Amt.END',
                     'ZX_TRL_MANAGE_TAX_PKG: UPDATE_TAXLINE_REC_NREC_AMT (-)');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Update_TaxLine_Rec_Nrec_Amt',
                       'Exception:Others:' ||SQLCODE||';'||SQLERRM);

        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Update_TaxLine_Rec_Nrec_Amt',
                       'Return Status = '||x_return_status);
      END IF;
  END Update_TaxLine_Rec_Nrec_Amt;

/*============================================================================*
 | Update_Freeze_Flag: Freezes distributions and updates ZX_LINES             |
 | Associated_Child_Frozen_Flag flag to indicate that the associated        |
 | children are frozen.                                                       |
 *============================================================================*/

  PROCEDURE Update_Freeze_Flag
       (x_return_status      OUT NOCOPY VARCHAR2,
        p_event_class_rec    IN         ZX_API_PUB.EVENT_CLASS_REC_TYPE) IS

    l_return_status             VARCHAR2(1);
    l_error_buffer              VARCHAR2(100);
    l_use_null_summary_id_flag  VARCHAR2(1);
    l_summary_lines_count       NUMBER;
    l_row_count                 NUMBER;

  BEGIN
    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Update_Freeze_Flag.BEGIN',
                     'ZX_TRL_MANAGE_TAX_PKG: Update_Freeze_Flag (+)');
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    /*UPDATE ZX_REC_NREC_DIST
      SET Freeze_Flag = 'Y',
          event_type_code = p_event_class_rec.event_type_code,
          tax_event_type_code = p_event_class_rec.tax_event_type_code
      WHERE REC_NREC_TAX_DIST_ID IN (SELECT TAX_DIST_ID
                                     FROM ZX_TAX_DIST_ID_GT);

     */
   -- Bug 6335649, In cases where Recovery is 100% Recoverable, in ZX_REC_NREC_DIST we have both REC and NONREC(0 amount)lines.
   --  When we call ZX_TRD_INTERNAL_SERVICES_PVT.calc_tax_dist for the second time computation,
   --  freeze_flag is checked for both the REC and NONREC lines, popualting the p_rec_nrec_tbl for them.
   -- But for the non rec lines, freeze flag is NULL.  Below code, updates the freeze flags of the REC/NONREC lines with 0 rec_nrec_rate

    UPDATE ZX_REC_NREC_DIST
      SET freeze_flag = 'Y',
        event_type_code = p_event_class_rec.event_type_code,
        tax_event_type_code = p_event_class_rec.tax_event_type_code
      WHERE tax_line_id IN (SELECT tax_line_id
                              FROM zx_rec_nrec_dist
                             WHERE rec_nrec_tax_dist_id IN
                                   (SELECT TAX_DIST_ID FROM ZX_TAX_DIST_ID_GT)
                               )
      AND application_id = p_event_class_rec.application_id;

    UPDATE ZX_LINES ZL
      SET Associated_Child_Frozen_Flag ='Y',
          event_type_code = p_event_class_rec.event_type_code,
          tax_event_type_code = p_event_class_rec.tax_event_type_code,
          doc_event_status = p_event_class_rec.doc_status_code
      WHERE TAX_LINE_ID IN (SELECT ZD.TAX_LINE_ID
                            FROM ZX_REC_NREC_DIST ZD ,
                                 ZX_TAX_DIST_ID_GT ZGT
                            WHERE ZD.REC_NREC_TAX_DIST_ID = ZGT.TAX_DIST_ID);

  -- Bug 6456915: Associated_child_frozen_flag has been removed from grouping columns for summary tax lines
  --No need to regenerate summary tax lines here

/*
    IF p_event_class_rec.summarization_flag = 'Y' THEN

      --
      --  delete all summary tax lines for this document
      --
      DELETE FROM ZX_LINES_SUMMARY
      WHERE APPLICATION_ID = p_event_class_rec.APPLICATION_ID
      AND ENTITY_CODE      = p_event_class_rec.ENTITY_CODE
      AND EVENT_CLASS_CODE = p_event_class_rec.EVENT_CLASS_CODE
      AND TRX_ID IN(SELECT ZD.trx_id
                      FROM ZX_REC_NREC_DIST ZD ,
                           ZX_TAX_DIST_ID_GT ZGT
                     WHERE ZD.REC_NREC_TAX_DIST_ID = ZGT.TAX_DIST_ID);

      IF p_event_class_rec.retain_summ_tax_line_id_flag  = 'Y' THEN
        --
        -- need to retain the current summary_tax_line_id
        --
        Summarization_For_Freeze_Event (
                  p_event_class_rec,
                  l_return_status);
      ELSE
        --
        -- create summary lines from zx_lines without
        -- retain the current summary_tax_line_id
        --
        create_summary_lines_upd_evnt(
          p_event_class_rec   => p_event_class_rec,
          x_return_status     => x_return_status );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF (g_level_error >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_error,
                   'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Update_Freeze_Flag',
                   'MRC Lines: Incorrect return_status after calling ' ||
                   'ZX_TRL_MANAGE_TAX_PKG.create_summary_lines_upd_evnt()');
            FND_LOG.STRING(g_level_error,
                   'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Update_Freeze_Flag',
                   'RETURN_STATUS = ' || x_return_status);
            FND_LOG.STRING(g_level_error,
                   'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Update_Freeze_Flag.END',
                   'ZX_TRL_MANAGE_TAX_PKG.Update_Freeze_Flag(-)');
          END IF;
          RETURN;
        END IF;

      END IF; -- p_event_class_rec.retain_summ_tax_line_id_flag  = 'Y'
    END IF;  -- p_event_class_rec.summarization_flag = 'Y'

 */
 -- End of bug 6456915

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Update_Freeze_Flag',
                       'Exception:' ||SQLCODE||';'||SQLERRM);

        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Update_Freeze_Flag',
                       'Return Status = '||l_return_status);
      END IF;

      RAISE FND_API.G_EXC_ERROR;

    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Update_Freeze_Flag',
                       'Exception:' ||SQLCODE||';'||SQLERRM);

        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Update_Freeze_Flag',
                       'Return Status = '||l_return_status);
      END IF;

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN

      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Update_Freeze_Flag.END',
                     'ZX_TRL_MANAGE_TAX_PKG: UPDATE_FREEZE_FLAG (-)');
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Update_Freeze_Flag',
                       'Exception:' ||SQLCODE||';'||SQLERRM);
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Update_Freeze_Flag',
                       'Return Status = '||x_return_status);
      END IF;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      FND_MESSAGE.SET_NAME('ZX','ZX_UNEXPECTED_ERROR');
      FND_MSG_PUB.Add;

      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Update_Freeze_Flag',
                       'Unexpected Error:' ||SQLCODE||';'||SQLERRM);
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Update_Freeze_Flag',
                       'Return Status = '||x_return_status);
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Update_Freeze_Flag',
                       'Unexpected error ...');
      END IF;

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Update_Freeze_Flag',
                       'Exception:Others:' ||SQLCODE||';'||SQLERRM);

        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Update_Freeze_Flag',
                       'Return Status = '||x_return_status);
      END IF;
  END Update_Freeze_Flag;

/*============================================================================*
 | Update_Item_Dist_Changed_Flag: This procedure updates tax lines (ZX_LINES) |
 | with changed status for given transaction line distributions.              |
 *============================================================================*/

  PROCEDURE Update_Item_Dist_Changed_Flag
       (x_return_status    OUT NOCOPY VARCHAR2,
        p_event_class_rec  IN         ZX_API_PUB.EVENT_CLASS_REC_TYPE) IS

    l_error_buffer  VARCHAR2(100);

  BEGIN

    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Update_Item_Dist_Changed_Flag.BEGIN',
                     'ZX_TRL_MANAGE_TAX_PKG: Update_Item_Dist_Changed_Flag (+)');
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    UPDATE ZX_LINES ZL
      SET Item_Dist_Changed_Flag  = 'Y'
      WHERE APPLICATION_ID = p_event_class_rec.application_id
      AND ENTITY_CODE      = p_event_class_rec.entity_code
      AND EVENT_CLASS_CODE = p_event_class_rec.event_class_code
      AND TRX_ID           = p_event_class_rec.trx_id
      AND EXISTS (SELECT /*+ INDEX(ZX_ITM_DISTRIBUTIONS_GT ZX_ITM_DISTRIBUTIONS_GT_U1
                                   ZX_ITM_DISTRIBUTIONS_GT_U1) */ 1
                  FROM ZX_ITM_DISTRIBUTIONS_GT ZD
                  WHERE ZL.APPLICATION_ID = ZD.APPLICATION_ID
                  AND ZL.ENTITY_CODE      = ZD.ENTITY_CODE
                  AND ZL.EVENT_CLASS_CODE = ZD.EVENT_CLASS_CODE
                  AND ZL.TRX_ID           = ZD.TRX_ID
                  AND ZL.TRX_LINE_ID      = ZD.TRX_LINE_ID
                  AND ZL.TRX_LEVEL_TYPE   = ZD.TRX_LEVEL_TYPE
                  AND ZD.DIST_LEVEL_ACTION  IN ('UPDATE','CREATE'));

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Update_Item_Dist_Changed_Flag.END',
                     'ZX_TRL_MANAGE_TAX_PKG: Update_Item_Dist_Changed_Flag (-)');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Update_Item_Dist_Changed_Flag',
                       'Exception:Others:' ||SQLCODE||';'||SQLERRM);

        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Update_Item_Dist_Changed_Flag',
                       'Return Status = '||x_return_status);
      END IF;
  END Update_Item_Dist_Changed_Flag;


/*============================================================================*
 | Discard_Tax_Only_Lines: The associated tax lines will be discarded         |
 |                                                                            |
 *============================================================================*/

  PROCEDURE discard_tax_only_lines
       (x_return_status      OUT NOCOPY VARCHAR2,
        p_event_class_rec IN            ZX_API_PUB.EVENT_CLASS_REC_TYPE) IS

    l_row_count     NUMBER;
    l_error_buffer  VARCHAR2(100);

    l_rec_nrec_tax_dist_id_tbl  num_tbl_type;
    l_tax_line_id_tbl    num_tbl_type;
    l_trx_line_dist_id_tbl  num_tbl_type;
    l_tax_dist_num_tbl    num_tbl_type;
    l_org_id_tbl                num_tbl_type;
    l_gl_date_tbl               date_tbl_type;

    l_old_tax_line_id    NUMBER;
    l_old_trx_line_dist_id      NUMBER;
    l_new_tax_dist_num    NUMBER;

    CURSOR  get_max_tax_dist_num_csr(
              c_tax_line_id    NUMBER,
              c_trx_line_dist_id  NUMBER) IS
     SELECT max(rec_nrec_tax_dist_number)
       FROM zx_rec_nrec_dist
      WHERE tax_line_id = c_tax_line_id
        AND trx_line_dist_id = c_trx_line_dist_id;

    CURSOR  get_tax_dists_csr IS
     SELECT rec_nrec_tax_dist_id,
            tax_line_id,
            trx_line_dist_id,
            rec_nrec_tax_dist_number,
            internal_organization_id,
            gl_date
       FROM zx_rec_nrec_dist zd
      WHERE zd.trx_id           = p_event_class_rec.trx_id
        AND zd.application_id   = p_event_class_rec.application_id
        AND zd.entity_code      = p_event_class_rec.entity_code
        AND zd.event_class_code = p_event_class_rec.event_class_code
        AND NVL(zd.reverse_flag, 'N')       = 'N'
        AND NVL(zd.tax_only_line_flag, 'N') = 'Y'
--      AND zd.freeze_flag                  = 'Y'
      ORDER BY tax_line_id, trx_line_dist_id, rec_nrec_tax_dist_number;


  BEGIN
    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Discard_Tax_Only_Lines.BEGIN',
                     'ZX_TRL_MANAGE_TAX_PKG: Discard_Tax_Only_Lines (+)');
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    UPDATE ZX_LINES
       SET ORIG_TAXABLE_AMT          = NVL(orig_taxable_amt, taxable_amt),
           ORIG_TAXABLE_AMT_TAX_CURR = NVL(orig_taxable_amt_tax_curr, taxable_amt_tax_curr),
           ORIG_TAX_AMT              = NVL(orig_tax_amt, tax_amt),
           ORIG_TAX_AMT_TAX_CURR     = NVL(orig_tax_amt_tax_curr, tax_amt_tax_curr),
           UNROUNDED_TAX_AMT         = 0,
           UNROUNDED_TAXABLE_AMT     = 0,
           TAX_AMT                   = 0,
           TAX_AMT_TAX_CURR          = 0,
           TAX_AMT_FUNCL_CURR        = 0,
           TAXABLE_AMT               = 0,
           TAXABLE_AMT_TAX_CURR      = 0,
           TAXABLE_AMT_FUNCL_CURR    = 0,
           CAL_TAX_AMT               = 0,
           CAL_TAX_AMT_TAX_CURR      = 0,
           CAL_TAX_AMT_FUNCL_CURR    = 0,
           REC_TAX_AMT               = 0,
           REC_TAX_AMT_TAX_CURR      = 0,
           REC_TAX_AMT_FUNCL_CURR    = 0,
           NREC_TAX_AMT              = 0,
           NREC_TAX_AMT_TAX_CURR     = 0,
           NREC_TAX_AMT_FUNCL_CURR   = 0,
           PROCESS_FOR_RECOVERY_FLAG = 'N',
           SYNC_WITH_PRVDR_FLAG      = DECODE(TAX_PROVIDER_ID, NULL, SYNC_WITH_PRVDR_FLAG, 'Y')
     WHERE APPLICATION_ID    = p_event_class_rec.application_id
       AND ENTITY_CODE       = p_event_class_rec.entity_code
       AND EVENT_CLASS_CODE  = p_event_class_rec.event_class_code
       AND TRX_ID            = p_event_class_rec.trx_id
       AND tax_only_line_flag = 'Y';

    l_row_count := SQL%ROWCOUNT;

    IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Discard_Tax_Only_Lines',
                       'Number of rows updated in zx_lines = '||l_row_count);
    END IF;

    IF p_event_class_rec.summarization_flag = 'Y' THEN

       UPDATE zx_lines_summary
         SET TAX_AMT = 0,
             TAX_AMT_TAX_CURR = 0,
             TAX_AMT_FUNCL_CURR = 0,
             TOTAL_REC_TAX_AMT = 0,
             TOTAL_REC_TAX_AMT_FUNCL_CURR = 0,
             TOTAL_NREC_TAX_AMT = 0,
             TOTAL_NREC_TAX_AMT_FUNCL_CURR = 0,
             TOTAL_REC_TAX_AMT_TAX_CURR = 0,
             TOTAL_NREC_TAX_AMT_TAX_CURR = 0
         WHERE APPLICATION_ID = p_event_class_rec.application_id
         AND ENTITY_CODE      = p_event_class_rec.entity_code
         AND EVENT_CLASS_CODE = p_event_class_rec.event_class_code
         AND TRX_ID           = p_event_class_rec.trx_id
         AND Tax_Only_Line_Flag = 'Y';

      l_row_count := SQL%ROWCOUNT;

      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Discard_Tax_Only_Lines',
                       'Number of rows updated in zx_lines_summary = '||l_row_count);
      END IF;

    END IF;


    -- Creates reverse distributions for frozen distribution lines
    --
    OPEN  get_tax_dists_csr;
    FETCH get_tax_dists_csr BULK COLLECT INTO
           l_rec_nrec_tax_dist_id_tbl,
           l_tax_line_id_tbl,
           l_trx_line_dist_id_tbl,
           l_tax_dist_num_tbl,
           l_org_id_tbl,
           l_gl_date_tbl;
    CLOSE get_tax_dists_csr;

    l_old_tax_line_id := NUMBER_DUMMY;
    l_old_trx_line_dist_id := NUMBER_DUMMY;
    l_new_tax_dist_num := 0;

    IF l_rec_nrec_tax_dist_id_tbl.COUNT > 0 THEN

      FOR i IN NVL(l_rec_nrec_tax_dist_id_tbl.FIRST, 0) ..
               NVL(l_rec_nrec_tax_dist_id_tbl.LAST, -1)
      LOOP

        IF l_old_tax_line_id = l_tax_line_id_tbl(i) AND
           l_old_trx_line_dist_id = l_trx_line_dist_id_tbl(i) THEN
          l_new_tax_dist_num := l_new_tax_dist_num + 1;
        ELSE

          OPEN  get_max_tax_dist_num_csr(
                    l_tax_line_id_tbl(i),
                    l_trx_line_dist_id_tbl(i));
          FETCH get_max_tax_dist_num_csr INTO l_new_tax_dist_num;
          CLOSE get_max_tax_dist_num_csr;

          l_new_tax_dist_num := l_new_tax_dist_num + 1;

          l_old_tax_line_id := l_tax_line_id_tbl(i);
          l_old_trx_line_dist_id := l_trx_line_dist_id_tbl(i);

        END IF;

        l_tax_dist_num_tbl(i) := l_new_tax_dist_num;

        -- bug 6706941: populate gl_date for the reversed tax distribution
        --
        l_gl_date_tbl(i) := AP_UTILITIES_PKG.get_reversal_gl_date(
                                            p_date   => l_gl_date_tbl(i),
                                            p_org_id => l_org_id_tbl(i));

      END LOOP;

      FORALL i IN l_rec_nrec_tax_dist_id_tbl.FIRST .. l_rec_nrec_tax_dist_id_tbl.LAST

        INSERT INTO ZX_REC_NREC_DIST(
                                  REC_NREC_TAX_DIST_ID,
                                  APPLICATION_ID,
                                  ENTITY_CODE,
                                  EVENT_CLASS_CODE,
                                  EVENT_TYPE_CODE,
                                  TRX_ID,
                                  TRX_LEVEL_TYPE,
                                  TRX_NUMBER,
                                  TRX_LINE_ID,
                                  TRX_LINE_NUMBER,
                                  TAX_LINE_ID,
                                  TAX_LINE_NUMBER,
                                  TRX_LINE_DIST_ID,
                                  ITEM_DIST_NUMBER,
                                  REC_NREC_TAX_DIST_NUMBER,
                                  REC_NREC_RATE,
                                  RECOVERABLE_FLAG,
                                  REC_NREC_TAX_AMT,
                                  TAX_EVENT_CLASS_CODE,
                                  TAX_EVENT_TYPE_CODE,
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
                                  INCLUSIVE_FLAG,
                                  RECOVERY_TYPE_ID,
                                  RECOVERY_TYPE_CODE,
                                  RECOVERY_RATE_ID,
                                  RECOVERY_RATE_CODE,
                                  REC_TYPE_RULE_FLAG,
                                  NEW_REC_RATE_CODE_FLAG,
                                  REVERSE_FLAG,
                                  HISTORICAL_FLAG,
                                  REVERSED_TAX_DIST_ID,
                                  REC_NREC_TAX_AMT_TAX_CURR,
                                  REC_NREC_TAX_AMT_FUNCL_CURR,
                                  INTENDED_USE,
                                  PROJECT_ID,
                                  TASK_ID,
                                  AWARD_ID,
                                  EXPENDITURE_TYPE,
                                  EXPENDITURE_ORGANIZATION_ID,
                                  EXPENDITURE_ITEM_DATE,
                                  REC_RATE_DET_RULE_FLAG,
                                  LEDGER_ID,
                                  SUMMARY_TAX_LINE_ID,
                                  RECORD_TYPE_CODE,
                                  CURRENCY_CONVERSION_DATE,
                                  CURRENCY_CONVERSION_TYPE,
                                  CURRENCY_CONVERSION_RATE,
                                  TAX_CURRENCY_CONVERSION_DATE,
                                  TAX_CURRENCY_CONVERSION_TYPE,
                                  TAX_CURRENCY_CONVERSION_RATE,
                                  TRX_CURRENCY_CODE,
                                  TAX_CURRENCY_CODE,
                                  TRX_LINE_DIST_QTY,
                                  REF_DOC_TRX_LINE_DIST_QTY,
                                  PRICE_DIFF,
                                  QTY_DIFF,
                                  PER_TRX_CURR_UNIT_NR_AMT,
                                  REF_PER_TRX_CURR_UNIT_NR_AMT,
                                  REF_DOC_CURR_CONV_RATE,
                                  UNIT_PRICE,
                                  REF_DOC_UNIT_PRICE,
                                  PER_UNIT_NREC_TAX_AMT,
                                  REF_DOC_PER_UNIT_NREC_TAX_AMT,
                                  RATE_TAX_FACTOR,
                                  TAX_APPORTIONMENT_FLAG,
                                  TRX_LINE_DIST_AMT,
                                  TRX_LINE_DIST_TAX_AMT,
                                  ORIG_REC_NREC_RATE,
                                  ORIG_REC_RATE_CODE,
                                  ORIG_REC_NREC_TAX_AMT,
                                  ORIG_REC_NREC_TAX_AMT_TAX_CURR,
                                  ACCOUNT_CCID,
                                  ACCOUNT_STRING,
                                  UNROUNDED_REC_NREC_TAX_AMT,
                                  APPLICABILITY_RESULT_ID,
                                  REC_RATE_RESULT_ID,
                                  BACKWARD_COMPATIBILITY_FLAG,
                                  OVERRIDDEN_FLAG,
                                  SELF_ASSESSED_FLAG,
                                  FREEZE_FLAG,
                                  POSTING_FLAG,
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
                                  GLOBAL_ATTRIBUTE16,
                                  GLOBAL_ATTRIBUTE17,
                                  GLOBAL_ATTRIBUTE18,
                                  GLOBAL_ATTRIBUTE19,
                                  GLOBAL_ATTRIBUTE20,
                                  GL_DATE,
                                  REF_DOC_APPLICATION_ID,
                                  REF_DOC_ENTITY_CODE,
                                  REF_DOC_EVENT_CLASS_CODE,
                                  REF_DOC_TRX_ID,
                                  REF_DOC_LINE_ID,
                                  REF_DOC_DIST_ID,
                                  MINIMUM_ACCOUNTABLE_UNIT,
                                  PRECISION,
                                  ROUNDING_RULE_CODE,
                                  TAXABLE_AMT,
                                  TAXABLE_AMT_TAX_CURR,
                                  TAXABLE_AMT_FUNCL_CURR,
                                  TAX_ONLY_LINE_FLAG,
                                  UNROUNDED_TAXABLE_AMT,
                                  LEGAL_ENTITY_ID,
                                  PRD_TAX_AMT,
                                  PRD_TAX_AMT_TAX_CURR,
                                  PRD_TAX_AMT_FUNCL_CURR,
                                  PRD_TOTAL_TAX_AMT,
                                  PRD_TOTAL_TAX_AMT_TAX_CURR,
                                  PRD_TOTAL_TAX_AMT_FUNCL_CURR,
                                  APPLIED_FROM_TAX_DIST_ID,
                                  APPLIED_TO_DOC_CURR_CONV_RATE,
                                  ADJUSTED_DOC_TAX_DIST_ID,
                                  FUNC_CURR_ROUNDING_ADJUSTMENT,
                                  TAX_APPORTIONMENT_LINE_NUMBER,
                                  LAST_MANUAL_ENTRY,
                                  REF_DOC_TAX_DIST_ID,
                                  REF_DOC_TRX_LEVEL_TYPE,
                                  MRC_TAX_DIST_FLAG,
                                  MRC_LINK_TO_TAX_DIST_ID,
                                  OBJECT_VERSION_NUMBER,
                                  CREATED_BY,
                                  CREATION_DATE,
                                  LAST_UPDATED_BY,
                                  LAST_UPDATE_DATE,
                                  LAST_UPDATE_LOGIN,
                                  INTERNAL_ORGANIZATION_ID,
                                  DEF_REC_SETTLEMENT_OPTION_CODE,
                                  TAX_JURISDICTION_ID,
                                  ACCOUNT_SOURCE_TAX_RATE_ID)
                           SELECT ZX_REC_NREC_DIST_S.NEXTVAL,       -- REC_NREC_TAX_DIST_ID,
                                  ZD.APPLICATION_ID,
                                  ZD.ENTITY_CODE,
                                  ZD.EVENT_CLASS_CODE,
                                  ZD.EVENT_TYPE_CODE,
                                  ZD.TRX_ID,
                                  ZD.TRX_LEVEL_TYPE,
                                  ZD.TRX_NUMBER,
                                  ZD.TRX_LINE_ID,
                                  ZD.TRX_LINE_NUMBER,
                                  ZD.TAX_LINE_ID,
                                  ZD.TAX_LINE_NUMBER,
                                  ZD.TRX_LINE_DIST_ID,
                                  ZD.ITEM_DIST_NUMBER,
                                  l_tax_dist_num_tbl(i),             -- ZD.REC_NREC_TAX_DIST_NUMBER,
                                  ZD.REC_NREC_RATE,
                                  ZD.RECOVERABLE_FLAG,
                                  -ZD.REC_NREC_TAX_AMT,
                                  ZD.TAX_EVENT_CLASS_CODE,
                                  ZD.TAX_EVENT_TYPE_CODE,
                                  ZD.CONTENT_OWNER_ID,
                                  ZD.TAX_REGIME_ID,
                                  ZD.TAX_REGIME_CODE,
                                  ZD.TAX_ID,
                                  ZD.TAX,
                                  ZD.TAX_STATUS_ID,
                                  ZD.TAX_STATUS_CODE,
                                  ZD.TAX_RATE_ID,
                                  ZD.TAX_RATE_CODE,
                                  ZD.TAX_RATE,
                                  ZD.INCLUSIVE_FLAG,
                                  ZD.RECOVERY_TYPE_ID,
                                  ZD.RECOVERY_TYPE_CODE,
                                  ZD.RECOVERY_RATE_ID,
                                  ZD.RECOVERY_RATE_CODE,
                                  ZD.REC_TYPE_RULE_FLAG,
                                  ZD.NEW_REC_RATE_CODE_FLAG,
                                  'Y',                              -- ZD.REVERSE_FLAG,
                                  ZD.HISTORICAL_FLAG,
                                  ZD.REC_NREC_TAX_DIST_ID,          -- ZD.REVERSED_TAX_DIST_ID,
                                  -ZD.REC_NREC_TAX_AMT_TAX_CURR,
                                  ZD.REC_NREC_TAX_AMT_FUNCL_CURR,
                                  ZD.INTENDED_USE,
                                  ZD.PROJECT_ID,
                                  ZD.TASK_ID,
                                  ZD.AWARD_ID,
                                  ZD.EXPENDITURE_TYPE,
                                  ZD.EXPENDITURE_ORGANIZATION_ID,
                                  ZD.EXPENDITURE_ITEM_DATE,
                                  ZD.REC_RATE_DET_RULE_FLAG,
                                  ZD.LEDGER_ID,
                                  ZD.SUMMARY_TAX_LINE_ID,
                                  ZD.RECORD_TYPE_CODE,
                                  ZD.CURRENCY_CONVERSION_DATE,
                                  ZD.CURRENCY_CONVERSION_TYPE,
                                  ZD.CURRENCY_CONVERSION_RATE,
                                  ZD.TAX_CURRENCY_CONVERSION_DATE,
                                  ZD.TAX_CURRENCY_CONVERSION_TYPE,
                                  ZD.TAX_CURRENCY_CONVERSION_RATE,
                                  ZD.TRX_CURRENCY_CODE,
                                  ZD.TAX_CURRENCY_CODE,
                                  ZD.TRX_LINE_DIST_QTY,
                                  ZD.REF_DOC_TRX_LINE_DIST_QTY,
                                  ZD.PRICE_DIFF,
                                  ZD.QTY_DIFF,
                                  ZD.PER_TRX_CURR_UNIT_NR_AMT,
                                  ZD.REF_PER_TRX_CURR_UNIT_NR_AMT,
                                  ZD.REF_DOC_CURR_CONV_RATE,
                                  ZD.UNIT_PRICE,
                                  ZD.REF_DOC_UNIT_PRICE,
                                  ZD.PER_UNIT_NREC_TAX_AMT,
                                  ZD.REF_DOC_PER_UNIT_NREC_TAX_AMT,
                                  ZD.RATE_TAX_FACTOR,
                                  ZD.TAX_APPORTIONMENT_FLAG,
                                  -ZD.TRX_LINE_DIST_AMT,
                                  -ZD.TRX_LINE_DIST_TAX_AMT,
                                  ZD.ORIG_REC_NREC_RATE,
                                  ZD.ORIG_REC_RATE_CODE,
                                  -ZD.ORIG_REC_NREC_TAX_AMT,
                                  -ZD.ORIG_REC_NREC_TAX_AMT_TAX_CURR,
                                  ZD.ACCOUNT_CCID,
                                  ZD.ACCOUNT_STRING,
                                  -ZD.UNROUNDED_REC_NREC_TAX_AMT,
                                  ZD.APPLICABILITY_RESULT_ID,
                                  ZD.REC_RATE_RESULT_ID,
                                  ZD.BACKWARD_COMPATIBILITY_FLAG,
                                  ZD.OVERRIDDEN_FLAG,
                                  ZD.SELF_ASSESSED_FLAG,
                                  'N',                              -- ZD.FREEZE_FLAG,
                                  ZD.POSTING_FLAG,
                                  ZD.ATTRIBUTE_CATEGORY,
                                  ZD.ATTRIBUTE1,
                                  ZD.ATTRIBUTE2,
                                  ZD.ATTRIBUTE3,
                                  ZD.ATTRIBUTE4,
                                  ZD.ATTRIBUTE5,
                                  ZD.ATTRIBUTE6,
                                  ZD.ATTRIBUTE7,
                                  ZD.ATTRIBUTE8,
                                  ZD.ATTRIBUTE9,
                                  ZD.ATTRIBUTE10,
                                  ZD.ATTRIBUTE11,
                                  ZD.ATTRIBUTE12,
                                  ZD.ATTRIBUTE13,
                                  ZD.ATTRIBUTE14,
                                  ZD.ATTRIBUTE15,
                                  ZD.GLOBAL_ATTRIBUTE_CATEGORY,
                                  ZD.GLOBAL_ATTRIBUTE1,
                                  ZD.GLOBAL_ATTRIBUTE2,
                                  ZD.GLOBAL_ATTRIBUTE3,
                                  ZD.GLOBAL_ATTRIBUTE4,
                                  ZD.GLOBAL_ATTRIBUTE5,
                                  ZD.GLOBAL_ATTRIBUTE6,
                                  ZD.GLOBAL_ATTRIBUTE7,
                                  ZD.GLOBAL_ATTRIBUTE8,
                                  ZD.GLOBAL_ATTRIBUTE9,
                                  ZD.GLOBAL_ATTRIBUTE10,
                                  ZD.GLOBAL_ATTRIBUTE11,
                                  ZD.GLOBAL_ATTRIBUTE12,
                                  ZD.GLOBAL_ATTRIBUTE13,
                                  ZD.GLOBAL_ATTRIBUTE14,
                                  ZD.GLOBAL_ATTRIBUTE15,
                                  ZD.GLOBAL_ATTRIBUTE16,
                                  ZD.GLOBAL_ATTRIBUTE17,
                                  ZD.GLOBAL_ATTRIBUTE18,
                                  ZD.GLOBAL_ATTRIBUTE19,
                                  ZD.GLOBAL_ATTRIBUTE20,
                                  l_gl_date_tbl(i),                 -- ZD.GL_DATE,
                                  ZD.REF_DOC_APPLICATION_ID,
                                  ZD.REF_DOC_ENTITY_CODE,
                                  ZD.REF_DOC_EVENT_CLASS_CODE,
                                  ZD.REF_DOC_TRX_ID,
                                  ZD.REF_DOC_LINE_ID,
                                  ZD.REF_DOC_DIST_ID,
                                  ZD.MINIMUM_ACCOUNTABLE_UNIT,
                                  ZD.PRECISION,
                                  ZD.ROUNDING_RULE_CODE,
                                  ZD.TAXABLE_AMT,
                                  ZD.TAXABLE_AMT_TAX_CURR,
                                  ZD.TAXABLE_AMT_FUNCL_CURR,
                                  ZD.TAX_ONLY_LINE_FLAG,
                                  ZD.UNROUNDED_TAXABLE_AMT,
                                  ZD.LEGAL_ENTITY_ID,
                                  ZD.PRD_TAX_AMT,
                                  ZD.PRD_TAX_AMT_TAX_CURR,
                                  ZD.PRD_TAX_AMT_FUNCL_CURR,
                                  ZD.PRD_TOTAL_TAX_AMT,
                                  ZD.PRD_TOTAL_TAX_AMT_TAX_CURR,
                                  ZD.PRD_TOTAL_TAX_AMT_FUNCL_CURR,
                                  ZD.APPLIED_FROM_TAX_DIST_ID,
                                  ZD.APPLIED_TO_DOC_CURR_CONV_RATE,
                                  ZD.ADJUSTED_DOC_TAX_DIST_ID,
                                  ZD.FUNC_CURR_ROUNDING_ADJUSTMENT,
                                  ZD.TAX_APPORTIONMENT_LINE_NUMBER,
                                  ZD.LAST_MANUAL_ENTRY,
                                  ZD.REF_DOC_TAX_DIST_ID,
                                  ZD.REF_DOC_TRX_LEVEL_TYPE,
                                  ZD.MRC_TAX_DIST_FLAG,
                                  ZD.MRC_LINK_TO_TAX_DIST_ID,
                                  1,                                   --ZD.OBJECT_VERSION_NUMBER,
                                  ZD.CREATED_BY,
                                  ZD.CREATION_DATE,
                                  ZD.LAST_UPDATED_BY,
                                  ZD.LAST_UPDATE_DATE,
                                  ZD.LAST_UPDATE_LOGIN,
                                  ZD.INTERNAL_ORGANIZATION_ID,
                                  ZD.DEF_REC_SETTLEMENT_OPTION_CODE,
                                  ZD.TAX_JURISDICTION_ID,
                                  ZD.ACCOUNT_SOURCE_TAX_RATE_ID
                          FROM ZX_REC_NREC_DIST ZD
                         WHERE rec_nrec_tax_dist_id = l_rec_nrec_tax_dist_id_tbl(i);

      l_row_count := SQL%ROWCOUNT;

      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Cancel_Transaction',
                       'Number of rows updated in zx_rec_nrec_dist = '||l_row_count);
      END IF;

      FORALL i IN NVL(l_rec_nrec_tax_dist_id_tbl.FIRST, 0) ..
                  NVL(l_rec_nrec_tax_dist_id_tbl.LAST, -1)
        UPDATE zx_rec_nrec_dist
           SET reverse_flag = 'Y'
         WHERE rec_nrec_tax_dist_id = l_rec_nrec_tax_dist_id_tbl(i);

      l_row_count := SQL%ROWCOUNT;

      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Cancel_Transaction',
                       'Number of rows updated in zx_rec_nrec_dist = '||l_row_count);
      END IF;

    END IF;    -- _rec_nrec_tax_dist_id_tbl.COUNT > 0

  /*
   *  IF (g_level_procedure >= g_current_runtime_level ) THEN
   *   FND_LOG.STRING(g_level_procedure,
   *                  'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Discard_Tax_Only_Lines',
   *                  'Update ZX_REC_NREC_DIST set reverse flag to Y (+)');
   * END IF;
   *
   * UPDATE ZX_REC_NREC_DIST
   *   SET Reverse_Flag = 'Y'
   *   WHERE APPLICATION_ID = p_event_class_rec.application_id
   *   AND ENTITY_CODE      = p_event_class_rec.entity_code
   *   AND EVENT_CLASS_CODE = p_event_class_rec.event_class_code
   *   AND TRX_ID           = p_event_class_rec.trx_id
   *   AND Freeze_Flag      = 'Y'
   *   AND NVL(Tax_Only_Line_Flag, 'N') = 'Y';
   *
   * IF (g_level_procedure >= g_current_runtime_level ) THEN
   *   FND_LOG.STRING(g_level_procedure,
   *                  'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Discard_Tax_Only_Lines',
   *                  'Update ZX_REC_NREC_DIST set reverse flag to Y (-)');
   * END IF;
   */

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Discard_Tax_Only_Lines.END',
                     'ZX_TRL_MANAGE_TAX_PKG: Discard_Tax_Only_Lines (-)');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Discard_Tax_Only_Lines',
                       'Exception:Others:' ||SQLCODE||';'||SQLERRM);

        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Discard_Tax_Only_Lines',
                       'Return Status = '||x_return_status);
      END IF;
  END Discard_Tax_Only_Lines;

/*============================================================================*
 | Update_GL_Date: GL Date will be obtained for Tax Distributions             |
 |                                                                            |
 *============================================================================*/

  PROCEDURE Update_GL_Date
       (p_gl_date       IN            DATE,
        x_return_status    OUT NOCOPY VARCHAR2) IS

    l_error_buffer  VARCHAR2(100);

  BEGIN
    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Update_GL_Date.BEGIN',
                     'ZX_TRL_MANAGE_TAX_PKG: Update_GL_Date (+)');
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    UPDATE zx_rec_nrec_dist
      SET gl_date = p_gl_date,
          orig_gl_date = gl_date
    WHERE rec_nrec_tax_dist_id IN
         (SELECT tax_dist_id FROM zx_tax_dist_id_gt);

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Update_GL_Date.END',
                     'ZX_TRL_MANAGE_TAX_PKG: Update_GL_Date (-)');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Update_GL_Date',
                       'Exception:Others:' ||SQLCODE||';'||SQLERRM);

        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Update_GL_Date',
                       'Return Status = '||x_return_status);
      END IF;
  END Update_GL_Date;

/*============================================================================*
 | Update_Exchange_Rate: modify the tax amounts needed to be calculated in    |
 |                       functional currency using the exchange rate and      |
 |                       rounding needs to be done too                        |
 |                                                                            |
 *============================================================================*/

  PROCEDURE Update_Exchange_Rate
       (p_event_class_rec         IN            ZX_API_PUB.EVENT_CLASS_REC_TYPE,
        x_return_status              OUT NOCOPY VARCHAR2) IS

    l_error_buffer    VARCHAR2(100);

  BEGIN

    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Update_Exchange_Rate.BEGIN',
                     'ZX_TRL_MANAGE_TAX_PKG: Update_Exchange_Rate (+)');
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF p_event_class_rec.tax_recovery_flag = 'Y' THEN

      UPDATE ZX_LINES L
        SET (rec_tax_amt_funcl_curr,
             nrec_tax_amt_funcl_curr
            ) =
            (SELECT SUM(decode(Recoverable_Flag,
                               'Y',
                               rec_nrec_tax_amt_funcl_curr)
                       ) rec_tax_amt_funcl_curr,
                    SUM(decode(Recoverable_Flag,
                               'N',
                               rec_nrec_tax_amt_funcl_curr)
                       ) nrec_tax_amt_funcl_curr
               FROM  ZX_REC_NREC_DIST D
               WHERE L.tax_line_id      = D.tax_line_id
                 AND L.application_id   = D.application_id
                 AND L.entity_code      = D.entity_code
                 AND L.event_class_code = D.event_class_code
                 AND L.trx_id           = D.trx_id
            )
        WHERE application_id    = p_event_class_rec.application_id
          AND entity_code       = p_event_class_rec.entity_code
          AND event_class_code  = p_event_class_rec.event_class_code
          AND trx_id            = p_event_class_rec.trx_id
          AND mrc_tax_line_flag = 'N';

    END IF;

    IF p_event_class_rec.summarization_flag = 'Y' THEN

      UPDATE ZX_LINES_SUMMARY  S
        SET (tax_amt_funcl_curr,
             total_rec_tax_amt_funcl_curr,
             total_nrec_tax_amt_funcl_curr
            ) =
            (SELECT SUM(L.tax_amt_funcl_curr) tax_amt_funcl_curr,
                    SUM(rec_tax_amt_funcl_curr) total_rec_tax_amt_funcl_curr ,
                    SUM(nrec_tax_amt_funcl_curr) total_nrec_tax_amt_funcl_curr
               FROM  ZX_LINES L
               WHERE L.summary_tax_line_id = S.summary_tax_line_id
                 AND L.application_id      = S.application_id
                 AND L.entity_code         = S.entity_code
                 AND L.event_class_code    = S.event_class_code
                 AND L.trx_id              = S.trx_id
            )
          WHERE application_id    = p_event_class_rec.application_id
            AND entity_code       = p_event_class_rec.entity_code
            AND event_class_code  = p_event_class_rec.event_class_code
            AND trx_id            = p_event_class_rec.trx_id
            AND mrc_tax_line_flag = 'N';

    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Update_Exchange_Rate.END',
                     'ZX_TRL_MANAGE_TAX_PKG: Update_Exchange_Rate (-)');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Update_Exchange_Rate',
                       'Exception:Others:' ||SQLCODE||';'||SQLERRM);

        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.Update_Exchange_Rate',
                       'Return Status = '||x_return_status);
      END IF;
  END Update_Exchange_Rate;

/* ===========================================================================*
 | PROCEDURE update_exist_summary_line_id:                                    |
 |           Preserve old summary_tax_line_id in g_detail_tax_lines_gt for    |
 |           UPDATE case, if the same summarization criteria exists in        |
 |           zx_lines_summary                                                 |
 * ===========================================================================*/
  PROCEDURE  update_exist_summary_line_id(
    p_event_class_rec   IN         ZX_API_PUB.EVENT_CLASS_REC_TYPE,
    x_return_status     OUT NOCOPY  VARCHAR2) IS

    l_row_count NUMBER;
    l_error_buffer VARCHAR2(100);

  BEGIN

    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    l_row_count :=0 ;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                    'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.update_exist_summary_line_id.BEGIN',
                    'ZX_TRL_MANAGE_TAX_PKG: update_exist_summary_line_id (+)');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Before deleting summary tax lines, we need to preserve old
    -- summary_tax_line_id (for UPDATE case) if the same summarization
    -- criteria exist.
    --
    UPDATE zx_detail_tax_lines_gt zlgt
       SET summary_tax_line_id =
           ( SELECT summary_tax_line_id
               FROM zx_lines_summary summ
              -- bug fix 5417887
              --WHERE summ.application_id = p_event_class_rec.application_id
              --  AND summ.entity_code = p_event_class_rec.entity_code
              --  AND summ.event_class_code = p_event_class_rec.event_class_code
              --  AND summ.trx_id = p_event_class_rec.trx_id
              WHERE summ.application_id = zlgt.application_id
                AND summ.entity_code = zlgt.entity_code
                AND summ.event_class_code = zlgt.event_class_code
                AND summ.trx_id = zlgt.trx_id
           --     AND summ.tax_event_class_code = zlgt.tax_event_class_code
                AND summ.internal_organization_id = zlgt.internal_organization_id
--                AND NVL(summ.trx_number, 'x') = NVL(zlgt.trx_number, 'x')
                AND NVL(summ.applied_from_trx_level_type, 'x') = NVL(zlgt.applied_from_trx_level_type, 'x')
                AND NVL(summ.adjusted_doc_trx_level_type, 'x') = NVL(zlgt.adjusted_doc_trx_level_type, 'x')
                -- bug6773534  AND NVL(summ.applied_to_trx_level_type, 'x')   = NVL(zlgt.applied_to_trx_level_type, 'x')
                AND NVL(summ.applied_from_application_id, 0) = NVL(zlgt.applied_from_application_id, 0)
                AND NVL(summ.applied_from_event_class_code, 'x') = NVL(zlgt.applied_from_event_class_code, 'x')
                AND NVL(summ.applied_from_entity_code, 'x') = NVL(zlgt.applied_from_entity_code, 'x')
--                AND NVL(summ.applied_from_trx_number, 'x') = NVL(zlgt.applied_from_trx_number, 'x')
                AND NVL(summ.applied_from_trx_id, 0) = NVL(zlgt.applied_from_trx_id, 0)
                AND NVL(summ.applied_from_line_id, 0) = NVL(zlgt.applied_from_line_id, 0)
                AND NVL(summ.adjusted_doc_application_id, 0) = NVL(zlgt.adjusted_doc_application_id, 0)
                AND NVL(summ.adjusted_doc_entity_code, 'x') = NVL(zlgt.adjusted_doc_entity_code, 'x')
                AND NVL(summ.adjusted_doc_event_class_code, 'x') = NVL(zlgt.adjusted_doc_event_class_code, 'x')
                AND NVL(summ.adjusted_doc_trx_id, 0) = NVL(zlgt.adjusted_doc_trx_id, 0)
--                AND NVL(summ.adjusted_doc_number, 'x') = NVL(zlgt.adjusted_doc_number, 'x')
                -- bug6773534  AND NVL(summ.applied_to_application_id, -999) = NVL(zlgt.applied_to_application_id, -999)
                -- bug6773534  AND NVL(summ.applied_to_event_class_code, 'x')    = NVL(zlgt.applied_to_event_class_code,  'x')
                -- bug6773534  AND NVL(summ.applied_to_entity_code, 'x') = NVL(zlgt.applied_to_entity_code, 'x')
                -- bug6773534  AND NVL(summ.applied_to_trx_id, -999) = NVL(zlgt.applied_to_trx_id, -999)
                -- bug6773534  AND NVL(summ.applied_to_line_id, -999) = NVL(zlgt.applied_to_line_id, -999)
                AND NVL(summ.tax_exemption_id, -999)  = NVL(zlgt.tax_exemption_id, -999)
                --AND NVL(summ.tax_rate_before_exemption, -999) = NVL(zlgt.tax_rate_before_exemption,  -999)
                --AND NVL(summ.tax_rate_name_before_exemption, 'x') = NVL(zlgt.tax_rate_name_before_exemption, 'x')
                --AND NVL(summ.exempt_rate_modifier, -999) = NVL(zlgt.exempt_rate_modifier, -999)
                AND NVL(summ.exempt_certificate_number, 'x') = NVL(zlgt.exempt_certificate_number, 'x')
                --AND NVL(summ.exempt_reason, 'x') = NVL(zlgt.exempt_reason, 'x')
                AND NVL(summ.exempt_reason_code, 'x') = NVL(zlgt.exempt_reason_code, 'x')
                AND NVL(summ.tax_exception_id,  -999) = NVL(zlgt.tax_exception_id, -999)
                --AND NVL(summ.tax_rate_before_exception, -999) = NVL(zlgt.tax_rate_before_exception,  -999)
                --AND NVL(summ.tax_rate_name_before_exception, 'x') = NVL(zlgt.tax_rate_name_before_exception, 'x')
                --AND NVL(summ.exception_rate, -999) = NVL(zlgt.exception_rate, -999)
                AND NVL(summ.content_owner_id, 0) = NVL(zlgt.content_owner_id, 0)
--                AND NVL(summ.tax_regime_id, 0) = NVL(zlgt.tax_regime_id, 0)
                AND NVL(summ.tax_regime_code, 'x') = NVL(zlgt.tax_regime_code, 'x')
--                AND NVL(summ.tax_id, 0) = NVL(zlgt.tax_id, 0)
                AND NVL(summ.tax, 'x') = NVL(zlgt.tax, 'x')
--                AND NVL(summ.tax_status_id, 0) = NVL(zlgt.tax_status_id, 0)
                AND NVL(summ.tax_status_code, 'x') = NVL(zlgt.tax_status_code, 'x')
                AND NVL(summ.tax_rate_id, 0) = NVL(zlgt.tax_rate_id, 0)
                AND NVL(summ.tax_rate_code, 'x') = NVL(zlgt.tax_rate_code, 'x')
                AND NVL(summ.tax_rate, -99) = NVL(zlgt.tax_rate, -99)
--                AND NVL(summ.tax_jurisdiction_id, 0) = NVL(zlgt.tax_jurisdiction_id, 0)
                AND NVL(summ.tax_jurisdiction_code, 'x') = NVL(zlgt.tax_jurisdiction_code, 'x')
                AND NVL(summ.ledger_id, 0) = NVL(zlgt.ledger_id, 0)
                AND NVL(summ.legal_entity_id, 0) = NVL(zlgt.legal_entity_id, 0)
                AND NVL(summ.establishment_id, 0) = NVL(zlgt.establishment_id, 0)
                AND NVL(TRUNC(summ.currency_conversion_date), SYSDATE) = NVL(TRUNC(zlgt.currency_conversion_date), SYSDATE)
                AND NVL(summ.currency_conversion_type,'x') = NVL(zlgt.currency_conversion_type,'x')
                AND NVL(summ.currency_conversion_rate, 1) = NVL(zlgt.currency_conversion_rate, 1)
                AND NVL(summ.taxable_basis_formula,'x') = NVL(zlgt.taxable_basis_formula,'x')
                AND NVL(summ.tax_calculation_formula,'x') = NVL(zlgt.tax_calculation_formula,'x')
                AND summ.tax_amt_included_flag = zlgt.tax_amt_included_flag
                AND summ.compounding_tax_flag = zlgt.compounding_tax_flag
                AND summ.self_assessed_flag = zlgt.self_assessed_flag
                AND summ.reporting_only_flag = zlgt.reporting_only_flag
            -- commented for bug 6456915    AND summ.associated_child_frozen_flag = zlgt.associated_child_frozen_Flag
           --     AND summ.copied_from_other_doc_flag = zlgt.copied_from_other_doc_flag
                AND NVL(summ.record_type_code,'x') = NVL(zlgt.record_type_code,'x')
                AND NVL(summ.tax_provider_id, 0) = NVL(zlgt.tax_provider_id, 0)
              --  AND summ.overridden_flag = zlgt.overridden_flag
                AND summ.manually_entered_flag =  zlgt.manually_entered_flag
                AND summ.tax_only_line_flag = zlgt.tax_only_line_flag
                AND summ.mrc_tax_line_flag = zlgt.mrc_tax_line_flag
                AND summ.historical_flag = zlgt.historical_flag
                AND rownum =1
           )
     WHERE summary_tax_line_id IS NULL;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                    'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.update_exist_summary_line_id.END',
                    'ZX_TRL_MANAGE_TAX_PKG: update_exist_summary_line_id (-)');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      l_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.update_exist_summary_line_id(-)',
                        l_error_buffer);
      END IF;

  END update_exist_summary_line_id;

/* ===========================================================================*
 | PROCEDURE RELEASE_DOCUMENT_TAX_HOLD : public API to release the tax hold at|
 | the document level by updating TAX_HOLD_RELEASED_CODE in zx_lines based on |
 | the input release tax code table.                                          |
 | Bug Fix: 3339364 by lxzhang                                                |
 * ===========================================================================*/

  PROCEDURE release_document_tax_hold(
      x_return_status             OUT NOCOPY VARCHAR2,
      p_event_class_rec IN            ZX_API_PUB.EVENT_CLASS_REC_TYPE,
      p_tax_hold_released_code IN     ZX_API_PUB.VALIDATION_STATUS_TBL_TYPE
  ) IS
    l_error_buffer         VARCHAR2(100);

    l_tax_hold_release_value NUMBER;
    l_tax_hold_release_mask  NUMBER;

    l_upg_trx_info_rec       ZX_ON_FLY_TRX_UPGRADE_PKG.zx_upg_trx_info_rec_type;
    l_trx_migrated_b         BOOLEAN;
  BEGIN
    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.release_document_tax_hold.BEGIN',
                     'ZX_TRL_MANAGE_TAX_PKG: release_document_tax_hold (+)');
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_tax_hold_release_mask := 0;

    FOR i IN 1..nvl(p_tax_hold_released_code.COUNT, 0) LOOP
      l_tax_hold_release_value := ZX_TRD_SERVICES_PUB_PKG.get_tax_hold_rls_val_frm_code(
                                      p_tax_hold_released_code(i) );
      l_tax_hold_release_mask := l_tax_hold_release_mask + l_tax_hold_release_value;
    END LOOP;

    -- update the tax_hold_release_code
      UPDATE ZX_LINES
        SET TAX_HOLD_RELEASED_CODE = BITAND(TAX_HOLD_CODE, l_tax_hold_release_mask )
         WHERE TAX_LINE_ID in (
             SELECT TAX_LINE_ID
             FROM ZX_LINES
             WHERE APPLICATION_ID  = p_event_class_rec.APPLICATION_ID
             AND ENTITY_CODE       = p_event_class_rec.ENTITY_CODE
             AND EVENT_CLASS_CODE  = p_event_class_rec.EVENT_CLASS_CODE
             AND TRX_ID            = p_event_class_rec.TRX_ID );

    IF SQL%NOTFOUND THEN

      l_upg_trx_info_rec.application_id    := p_event_class_rec.application_id;
      l_upg_trx_info_rec.entity_code       := p_event_class_rec.entity_code;
      l_upg_trx_info_rec.event_class_code  := p_event_class_rec.event_class_code;
      l_upg_trx_info_rec.trx_id            := p_event_class_rec.trx_id;

      -- check if trx line exists in the det factors table. If not exist,
      -- do on-the-fly migration
      ZX_ON_FLY_TRX_UPGRADE_PKG.is_trx_migrated(
        p_upg_trx_info_rec  => l_upg_trx_info_rec,
        x_trx_migrated_b    => l_trx_migrated_b,
        x_return_status     => x_return_status );

      IF NOT l_trx_migrated_b THEN
        ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly(
          p_upg_trx_info_rec  => l_upg_trx_info_rec,
          x_return_status     => x_return_status
        );
      END IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.release_document_tax_hold',
                 'Incorrect return_status after calling ' ||
                 ' ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly');
          FND_LOG.STRING(g_level_statement,
                        'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.release_document_tax_hold',
                        'RETURN_STATUS = ' || x_return_status);
          FND_LOG.STRING(g_level_statement,
                        'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.release_document_tax_hold.END',
                        'ZX_TRL_MANAGE_TAX_PKG.release_document_tax_hold(-)');
        END IF;
        RETURN;
      END IF;

      -- update the tax_hold_release_code
      UPDATE ZX_LINES
        SET TAX_HOLD_RELEASED_CODE = BITAND(TAX_HOLD_CODE, l_tax_hold_release_mask )
         WHERE TAX_LINE_ID in (
             SELECT TAX_LINE_ID
             FROM ZX_LINES
             WHERE APPLICATION_ID  = p_event_class_rec.APPLICATION_ID
             AND ENTITY_CODE       = p_event_class_rec.ENTITY_CODE
             AND EVENT_CLASS_CODE  = p_event_class_rec.EVENT_CLASS_CODE
             AND TRX_ID            = p_event_class_rec.TRX_ID );

    END IF; -- IF SQL%NOTFOUND THEN

    IF (g_level_procedure >= g_current_runtime_level ) THEN

      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.release_document_tax_hold.END',
                     'ZX_TRL_MANAGE_TAX_PKG: release_document_tax_hold (-)'||x_return_status);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      l_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.release_document_tax_hold',
                        l_error_buffer);
      END IF;

  END RELEASE_DOCUMENT_TAX_HOLD;

------------------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  create_summary_lines_crt_evnt
--
--  DESCRIPTION
--  Private procedure to create zx_lines_summary from zx_detail_tax_lines_gt
--  for tax_event_type of 'CREATE' or for tax_event_type of 'UPDATE'/'OVERRIDE'
--  with retain_summ_tax_line_id_flag on event_class_rec of 'N'
------------------------------------------------------------------------------
-- Bug 6456915 - associated_child_frozen_flag has been removed from grouping columns for summary tax lines

PROCEDURE create_summary_lines_crt_evnt(
  p_event_class_rec   IN          ZX_API_PUB.EVENT_CLASS_REC_TYPE,
  x_return_status     OUT NOCOPY  VARCHAR2
) IS

  l_error_buffer            VARCHAR2(100);
  l_index                   NUMBER;
  l_curr_ledger_id          NUMBER;
  l_summary_tax_line_number NUMBER;

  l_curr_trx_id             NUMBER;
  l_curr_entity_code        zx_evnt_cls_mappings.entity_code%TYPE;
  l_curr_event_class_code   zx_evnt_cls_mappings.event_class_code%TYPE;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
           'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.create_summary_lines_crt_evnt.BEGIN',
           'ZX_TRL_MANAGE_TAX_PKG: create_summary_lines_crt_evnt (+)');
  END IF;

  --  Initialize API return status to success
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- get the summary_tax_line_id to be used and the COUNT of tax line FOR each summary_tax_line_id
  -- get all the column value used to create the summary tax lines.

  SELECT
         application_id,
         entity_code,
         event_class_code,
         trx_id,
         internal_organization_id,
         zx_lines_summary_s.NEXTVAL,
         count_detail_tax_line,
         count_detail_cancel_flag,
         trx_number,
         applied_from_application_id,
         applied_from_event_class_code,
         applied_from_entity_code,
         -- applied_from_trx_number,
         applied_from_trx_id,
         applied_from_trx_level_type,
         applied_from_line_id,
         adjusted_doc_application_id,
         adjusted_doc_entity_code,
         adjusted_doc_event_class_code,
         adjusted_doc_trx_id,
         adjusted_doc_trx_level_type,
         -- adjusted_doc_number,
         --ROWNUM,                      -- summary_tax_line_number
         content_owner_id,
         -- tax_regime_id,
         tax_regime_code,
         -- tax_id,
         tax,
         -- tax_status_id,
         tax_status_code,
         tax_rate_id,
         tax_rate_code,
         tax_rate,
         -- tax_jurisdiction_id,
         tax_jurisdiction_code,
         ledger_id,
         legal_entity_id,
         establishment_id,
         currency_conversion_date,
         currency_conversion_type,
         currency_conversion_rate,
         taxable_basis_formula,
         tax_calculation_formula,
         tax_amt_included_flag,
         compounding_tax_flag,
         self_assessed_flag,
         reporting_only_flag,
         -- associated_child_frozen_flag,
  --       copied_from_other_doc_flag,
         record_type_code,
         tax_provider_id,
         historical_flag,
         tax_amt,
         tax_amt_tax_curr,
         tax_amt_funcl_curr,
         -- orig_tax_amt,
         total_rec_tax_amt,
         total_rec_tax_amt_funcl_curr,
         total_rec_tax_amt_tax_curr,
         total_nrec_tax_amt,
         total_nrec_tax_amt_funcl_curr,
         total_nrec_tax_amt_tax_curr,
         -- cancel_flag,
         -- purge_flag,
         delete_flag,
         --overridden_flag,
         manually_entered_flag,
         -- bug6773534 applied_to_application_id,
         -- bug6773534 applied_to_event_class_code,
         -- bug6773534 applied_to_entity_code,
         -- bug6773534 applied_to_trx_id,
         -- bug6773534 applied_to_trx_level_type,
         -- bug6773534 applied_to_line_id,
         tax_exemption_id,
         --tax_rate_before_exemption,
         --tax_rate_name_before_exemption,
         --exempt_rate_modifier,
         exempt_certificate_number,
         --exempt_reason,
         exempt_reason_code,
         --tax_rate_before_exception,
         --tax_rate_name_before_exception,
         tax_exception_id,
         --exception_rate,
         mrc_tax_line_flag,
         tax_only_line_flag
  BULK COLLECT INTO
         pg_application_id_tbl,
         pg_entity_code_tbl,
         pg_event_class_code_tbl,
         pg_trx_id_tbl,
         pg_internal_org_id_tbl,
         pg_summary_tax_line_id_tbl,
         pg_count_detail_tax_line_tbl,
         pg_count_detail_cancel_tbl,
         pg_trx_number_tbl,
         pg_app_from_app_id_tbl,
         pg_app_from_evnt_cls_code_tbl,
         pg_app_from_entity_code_tbl,
         pg_app_from_trx_id_tbl,
         pg_app_from_trx_level_type_tbl,
         pg_app_from_line_id_tbl,
         pg_adj_doc_app_id_tbl,
         pg_adj_doc_entity_code_tbl,
         pg_adj_doc_evnt_cls_code_tbl,
         pg_adj_doc_trx_id_tbl,
         pg_adj_doc_trx_level_type_tbl,
         --pg_summary_tax_line_num_tbl,
         pg_content_owner_id_tbl,
         pg_tax_regime_code_tbl,
         pg_tax_tbl,
         pg_tax_status_code_tbl,
         pg_tax_rate_id_tbl,
         pg_tax_rate_code_tbl,
         pg_tax_rate_tbl,
         pg_tax_jurisdiction_code_tbl,
         pg_ledger_id_tbl,
         pg_legal_entity_id_tbl,
         pg_establishment_id_tbl,
         pg_currency_convrsn_date_tbl,
         pg_currency_convrsn_type_tbl,
         pg_currency_convrsn_rate_tbl,
         pg_taxable_basis_formula_tbl,
         pg_tax_calculation_formula_tbl,
         pg_tax_amt_included_flag_tbl,
         pg_compounding_tax_flag_tbl,
         pg_self_assessed_flag_tbl,
         pg_reporting_only_flag_tbl,
         -- pg_assoctd_child_frz_flag_tbl,
   --      pg_cpd_from_other_doc_flag_tbl,
         pg_record_type_code_tbl,
         pg_tax_provider_id_tbl,
         pg_historical_flag_tbl,
         pg_tax_amt_tbl,
         pg_tax_amt_tax_curr_tbl,
         pg_tax_amt_funcl_curr_tbl,
         pg_ttl_rec_tax_amt_tbl,
         pg_ttl_rec_tx_amt_fnc_crr_tbl,
         pg_ttl_rec_tx_amt_tx_crr_tbl,
         pg_ttl_nrec_tax_amt_tbl,
         pg_ttl_nrec_tx_amt_fnc_crr_tbl,
         pg_ttl_nrec_tx_amt_tx_crr_tbl,
         -- pg_cancel_flag_tbl,
         pg_delete_flag_tbl,
         --pg_overridden_flag_tbl,
         pg_manually_entered_flag_tbl,
         -- bug6773534 pg_app_to_app_id_tbl,
         -- bug6773534 pg_app_to_evnt_cls_code_tbl,
         -- bug6773534 pg_app_to_entity_code_tbl,
         -- bug6773534 pg_app_to_trx_id_tbl,
         -- bug6773534 pg_app_to_trx_level_type_tbl,
         -- bug6773534 pg_app_to_line_id_tbl,
         pg_tax_xmptn_id_tbl,
         --pg_tax_rate_bf_xmptn_tbl,
         --pg_tax_rate_name_bf_xmptn_tbl,
         --pg_xmpt_rate_modifier_tbl,
         pg_xmpt_certificate_number_tbl,
         --pg_xmpt_reason_tbl,
         pg_xmpt_reason_code_tbl,
         --pg_tax_rate_bf_xeptn_tbl,
         --pg_tax_rate_name_bf_xeptn_tbl,
         pg_tax_xeptn_id_tbl,
         --pg_xeptn_rate_tbl,
         pg_mrc_tax_line_flag_tbl,
         pg_tax_only_line_flag_tbl
    -- bug#7581211: remove the index hint
    -- FROM (SELECT /*+ INDEX(ZX_DETAIL_TAX_LINES_GT ZX_DETAIL_TAX_LINES_GT_U1)*/
    FROM (SELECT
            application_id,
            entity_code,
            event_class_code,
            trx_id,
            internal_organization_id,
            COUNT(*)  count_detail_tax_line,  -- How many detail tax lines grouped for each summary tax line.
            SUM(DECODE(cancel_flag, 'Y', 1, 0)) count_detail_cancel_flag,
            trx_number,
            applied_from_application_id,
            applied_from_event_class_code,
            applied_from_entity_code,
            -- applied_from_trx_number,
            applied_from_trx_id,
            applied_from_trx_level_type,
            applied_from_line_id,
            adjusted_doc_application_id,
            adjusted_doc_entity_code,
            adjusted_doc_event_class_code,
            adjusted_doc_trx_id,
            adjusted_doc_trx_level_type,
            -- adjusted_doc_number,
            content_owner_id,
            -- tax_regime_id,
            tax_regime_code,
            -- tax_id,
            tax,
            -- tax_status_id,
            tax_status_code,
            tax_rate_id,
            tax_rate_code,
            tax_rate,
            -- tax_jurisdiction_id,
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
            -- associated_child_frozen_flag,
  --          copied_from_other_doc_flag,
            record_type_code,
            tax_provider_id,
            historical_flag,
            SUM(tax_amt) tax_amt,
            SUM(tax_amt_tax_curr) tax_amt_tax_curr,
            SUM(tax_amt_funcl_curr) tax_amt_funcl_curr,
            SUM(orig_tax_amt) orig_tax_amt,
            SUM(rec_tax_amt) total_rec_tax_amt,
            SUM(rec_tax_amt_funcl_curr) total_rec_tax_amt_funcl_curr,
            SUM(rec_tax_amt_tax_curr) total_rec_tax_amt_tax_curr,
            SUM(nrec_tax_amt) total_nrec_tax_amt,
            SUM(nrec_tax_amt_funcl_curr) total_nrec_tax_amt_funcl_curr,
            SUM(nrec_tax_amt_tax_curr) total_nrec_tax_amt_tax_curr,
            -- cancel_flag,
            -- purge_flag,
            delete_flag,
            --overridden_flag,
            manually_entered_flag,
            -- bug6773534 applied_to_application_id,
            -- bug6773534 applied_to_event_class_code,
            -- bug6773534 applied_to_entity_code,
            -- bug6773534 applied_to_trx_id,
            -- bug6773534 applied_to_trx_level_type,
            -- bug6773534 applied_to_line_id,
            tax_exemption_id,
            --tax_rate_before_exemption,
            --tax_rate_name_before_exemption,
            --exempt_rate_modifier,
            exempt_certificate_number,
            --exempt_reason,
            exempt_reason_code,
            --tax_rate_before_exception,
            --tax_rate_name_before_exception,
            tax_exception_id,
            --exception_rate,
            mrc_tax_line_flag,
            tax_only_line_flag
       FROM zx_detail_tax_lines_gt
-- commented out for bug fix 5417887
--      WHERE application_id  = p_event_class_rec.application_id
--        AND entity_code       = p_event_class_rec.entity_code
--        AND event_class_code  = p_event_class_rec.event_class_code
--        AND trx_id            = p_event_class_rec.trx_id
        GROUP BY application_id,
                 entity_code,
                 event_class_code,
                 trx_id,
                 internal_organization_id,
                 trx_number,
                 applied_from_application_id,
                 applied_from_event_class_code,
                 applied_from_entity_code,
                 applied_from_trx_id,
                 applied_from_trx_level_type,
                 applied_from_line_id,
                 adjusted_doc_application_id,
                 adjusted_doc_entity_code,
                 adjusted_doc_event_class_code,
                 adjusted_doc_trx_id,
                 adjusted_doc_trx_level_type,
                 content_owner_id,
                 tax_regime_code,
                 tax,
                 tax_status_code,
                 tax_rate_id,
                 tax_rate_code,
                 tax_rate,
                 tax_jurisdiction_code,
                 ledger_id,
                 legal_entity_id,
                 establishment_id,
                 TRUNC(currency_conversion_date),
                 currency_conversion_type,
                 currency_conversion_rate,
                 taxable_basis_formula,
                 tax_calculation_formula,
                 tax_amt_included_flag,
                 compounding_tax_flag,
                 self_assessed_flag,
                 reporting_only_flag,
                 -- associated_child_frozen_flag,
   --            copied_from_other_doc_flag,
                 record_type_code,
                 tax_provider_id,
                 historical_flag,
                 -- cancel_flag,
                 delete_flag,
                 --overridden_flag,
                 manually_entered_flag,
                 -- bug6773534 applied_to_application_id,
                 -- bug6773534 applied_to_event_class_code,
                 -- bug6773534 applied_to_entity_code,
                 -- bug6773534 applied_to_trx_id,
                 -- bug6773534 applied_to_trx_level_type,
                 -- bug6773534 applied_to_line_id,
                 tax_exemption_id,
                 --tax_rate_before_exemption,
                 --tax_rate_name_before_exemption,
                 --exempt_rate_modifier,
                 exempt_certificate_number,
                 --exempt_reason,
                 exempt_reason_code,
                 --tax_rate_before_exception,
                 --tax_rate_name_before_exception,
                 tax_exception_id,
                 --exception_rate,
                 mrc_tax_line_flag,
                 tax_only_line_flag
        ORDER BY application_id,
                 entity_code,
                 event_class_code,
                 trx_id,
                 trx_number,
                 mrc_tax_line_flag,
                 ledger_id,
                 applied_from_application_id,
                 applied_from_event_class_code,
                 applied_from_entity_code,
                 applied_from_trx_id,
                 applied_from_trx_level_type,
                 applied_from_line_id,
                 adjusted_doc_application_id,
                 adjusted_doc_entity_code,
                 adjusted_doc_event_class_code,
                 adjusted_doc_trx_id,
                 adjusted_doc_trx_level_type,
                 content_owner_id,
                 tax_regime_code,
                 tax,
                 tax_status_code,
                 tax_rate_id,
                 tax_rate_code,
                 tax_rate,
                 tax_jurisdiction_code,
                 legal_entity_id,
                 establishment_id,
              --   TRUNC(currency_conversion_date),
              --   currency_conversion_type,
              --   currency_conversion_rate,
                 taxable_basis_formula,
                 tax_calculation_formula,
                 tax_amt_included_flag,
                 compounding_tax_flag,
                 self_assessed_flag,
                 reporting_only_flag,
                 -- associated_child_frozen_flag,
      --         copied_from_other_doc_flag,
                 record_type_code,
                 tax_provider_id,
                 historical_flag,
                 -- cancel_flag,
                 delete_flag,
                 --overridden_flag,
                 manually_entered_flag,
                 -- bug6773534 applied_to_application_id,
                 -- bug6773534 applied_to_event_class_code,
                 -- bug6773534 applied_to_entity_code,
                 -- bug6773534 applied_to_trx_id,
                 -- bug6773534 applied_to_trx_level_type,
                 -- bug6773534 applied_to_line_id,
                 tax_exemption_id,
                 --tax_rate_before_exemption,
                 --tax_rate_name_before_exemption,
                 --exempt_rate_modifier,
                 exempt_certificate_number,
                 --exempt_reason,
                 exempt_reason_code,
                 --tax_rate_before_exception,
                 --tax_rate_name_before_exception,
                 tax_exception_id,
                 --exception_rate,
                 tax_only_line_flag );

  -- get the tax line id IN the same order of the summary tax line as IN the first query.
  SELECT /*+ INDEX(ZX_DETAIL_TAX_LINES_GT ZX_DETAIL_TAX_LINES_GT_U1) */
         tax_line_id  BULK COLLECT INTO  pg_tax_line_id_tbl
    FROM zx_detail_tax_lines_gt
 -- commented out for bug fix 5417887
 --   WHERE application_id  = p_event_class_rec.application_id
 --   AND entity_code       = p_event_class_rec.entity_code
 --   AND event_class_code  = p_event_class_rec.event_class_code
 --   AND trx_id            = p_event_class_rec.trx_id
    ORDER BY application_id,
             entity_code,
             event_class_code,
             trx_id,
             trx_number,
             mrc_tax_line_flag,
             ledger_id,
             applied_from_application_id,
             applied_from_event_class_code,
             applied_from_entity_code,
             applied_from_trx_id,
             applied_from_trx_level_type,
             applied_from_line_id,
             adjusted_doc_application_id,
             adjusted_doc_entity_code,
             adjusted_doc_event_class_code,
             adjusted_doc_trx_id,
             adjusted_doc_trx_level_type,
             content_owner_id,
             tax_regime_code,
             tax,
             tax_status_code,
             tax_rate_id,
             tax_rate_code,
             tax_rate,
             tax_jurisdiction_code,
             legal_entity_id,
             establishment_id,
          --   TRUNC(currency_conversion_date),
          --   currency_conversion_type,
          --   currency_conversion_rate,
             taxable_basis_formula,
             tax_calculation_formula,
             tax_amt_included_flag,
             compounding_tax_flag,
             self_assessed_flag,
             reporting_only_flag,
             -- associated_child_frozen_flag,
      --   copied_from_other_doc_flag,
             record_type_code,
             tax_provider_id,
             historical_flag,
             -- cancel_flag,
             delete_flag,
             --overridden_flag,
             manually_entered_flag,
             -- bug6773534 applied_to_application_id,
             -- bug6773534 applied_to_event_class_code,
             -- bug6773534 applied_to_entity_code,
             -- bug6773534 applied_to_trx_id,
             -- bug6773534 applied_to_trx_level_type,
             -- bug6773534 applied_to_line_id,
             tax_exemption_id,
             --tax_rate_before_exemption,
             --tax_rate_name_before_exemption,
             --exempt_rate_modifier,
             exempt_certificate_number,
             --exempt_reason,
             exempt_reason_code,
             --tax_rate_before_exception,
             --tax_rate_name_before_exception,
             tax_exception_id,
             --exception_rate,
             tax_only_line_flag ;

  l_index := 1;
  l_curr_ledger_id := -1;
  l_summary_tax_line_number := -1;

  l_curr_trx_id := -1;
  l_curr_entity_code := '@#$%^&*';
  l_curr_event_class_code := '@#$%^&*';

  FOR i IN 1.. pg_summary_tax_line_id_tbl.COUNT LOOP


    -- the following code is not needed as we are not creating MRC tax lines in eBTax repository
    -- due to the order by clause, it guranteed that the none_mrc line will
    -- come first, then followed by the mrc tax lines.
    --IF l_curr_ledger_id = -1 OR l_curr_ledger_id <> pg_ledger_id_tbl(i) THEN
    --  l_curr_ledger_id := pg_ledger_id_tbl(i);
    --END IF;

    -- populate the summary_tax_line_number
    -- Reset the summary tax line number whenever the entity_code, Event Class Code
    -- or Trx id changes

    IF (l_curr_entity_code = '@#$%^&*' and  l_curr_event_class_code = '@#$%^&*' and l_curr_trx_id = -1)
      or l_curr_event_class_code <> pg_event_class_code_tbl(i)
      or l_curr_trx_id <> pg_trx_id_tbl(i)
      or l_curr_entity_code <> pg_entity_code_tbl(i)
    THEN
      l_curr_event_class_code := pg_event_class_code_tbl(i);
      l_curr_trx_id := pg_trx_id_tbl(i);
      l_curr_entity_code := pg_entity_code_tbl(i);

      l_summary_tax_line_number := 1;
    ELSE
      l_summary_tax_line_number := l_summary_tax_line_number + 1;
    END IF;

    pg_summary_tax_line_num_tbl(i) := l_summary_tax_line_number;

    -- populate the summary_tax_line_id to the corresponding detail_tax_line_id
    FOR j IN 1.. pg_count_detail_tax_line_tbl(i) LOOP
      pg_detail_tax_smry_line_id_tbl(l_index) := pg_summary_tax_line_id_tbl(i);
      l_index := l_index+1;
    END LOOP;

    IF pg_count_detail_cancel_tbl(i) = pg_count_detail_tax_line_tbl(i) THEN
      pg_cancel_flag_tbl(i) := 'Y';
    ELSE
      pg_cancel_flag_tbl(i) := NULL;
    END IF;

  END LOOP;

  -- update the summary_tax_line_id column in the detail tax line table
  FORALL i IN 1.. pg_tax_line_id_tbl.COUNT
    UPDATE /*+ INDEX(ZX_DETAIL_TAX_LINES_GT ZX_DETAIL_TAX_LINES_GT_U2) */
           zx_detail_tax_lines_gt
       SET summary_tax_line_id = pg_detail_tax_smry_line_id_tbl(i)
     WHERE tax_line_id = pg_tax_line_id_tbl(i);

  -- insert the newly created summary tax lines
  FORALL i IN 1..pg_summary_tax_line_id_tbl.COUNT
    INSERT INTO zx_lines_summary(
                  summary_tax_line_id,
                  object_version_number,
                  created_by,
                  creation_date,
                  last_updated_by,
                  last_update_date,
                  last_update_login,
                  internal_organization_id,
                  application_id,
                  entity_code,
                  event_class_code,
                  -- tax_event_class_code,
                  trx_id,
                  trx_number,
                  applied_from_application_id,
                  applied_from_event_class_code,
                  applied_from_entity_code,
                  -- applied_from_trx_number,
                  applied_from_trx_id,
                  applied_from_trx_level_type,
                  applied_from_line_id,
                  adjusted_doc_application_id,
                  adjusted_doc_entity_code,
                  adjusted_doc_event_class_code,
                  adjusted_doc_trx_id,
                  adjusted_doc_trx_level_type,
                  -- adjusted_doc_number,
                  summary_tax_line_number,
                  content_owner_id,
                  -- tax_regime_id,
                  tax_regime_code,
                  -- tax_id,
                  tax,
                  -- tax_status_id,
                  tax_status_code,
                  tax_rate_id,
                  tax_rate_code,
                  tax_rate,
                  -- tax_jurisdiction_id,
                  tax_jurisdiction_code,
                  ledger_id,
                  legal_entity_id,
                  establishment_id,
                  currency_conversion_date,
                  currency_conversion_type,
                  currency_conversion_rate,
                  taxable_basis_formula,
                  tax_calculation_formula,
                  tax_amt_included_flag,
                  compounding_tax_flag,
                  self_assessed_flag,
                  reporting_only_flag,
                  -- associated_child_frozen_flag,
        --      copied_from_other_doc_flag,
                  record_type_code,
                  tax_provider_id,
                  historical_flag,
                  tax_amt,
                  tax_amt_tax_curr,
                  tax_amt_funcl_curr,
                  -- orig_tax_amt,
                  total_rec_tax_amt,
                  total_rec_tax_amt_funcl_curr,
                  total_rec_tax_amt_tax_curr,
                  total_nrec_tax_amt,
                  total_nrec_tax_amt_funcl_curr,
                  total_nrec_tax_amt_tax_curr,
                  cancel_flag,
                  -- purge_flag,
                  delete_flag,
             --     overridden_flag,
                  manually_entered_flag,
                  -- bug6773534 applied_to_application_id,
                  -- bug6773534 applied_to_event_class_code,
                  -- bug6773534 applied_to_entity_code,
                  -- bug6773534 applied_to_trx_id,
                  -- bug6773534 applied_to_trx_level_type,
                  -- bug6773534 applied_to_line_id,
                  tax_exemption_id,
              --    tax_rate_before_exemption,
              --    tax_rate_name_before_exemption,
              --    exempt_rate_modifier,
                  exempt_certificate_number,
              --    exempt_reason,
                  exempt_reason_code,
               --   tax_rate_before_exception,
              --    tax_rate_name_before_exception,
                  tax_exception_id,
               --   exception_rate,
                  mrc_tax_line_flag,
                  tax_only_line_flag )
         VALUES (
                  pg_summary_tax_line_id_tbl(i),
                  1,        -- object_version_number
                  FND_GLOBAL.user_id,
                  SYSDATE,
                  FND_GLOBAL.user_id,
                  SYSDATE,
                  FND_GLOBAL.user_id,
                  pg_internal_org_id_tbl(i),
                  pg_application_id_tbl(i),
                  pg_entity_code_tbl(i),
                  pg_event_class_code_tbl(i),
                  -- tax_event_class_code,
                  pg_trx_id_tbl(i),
                  pg_trx_number_tbl(i),
                  pg_app_from_app_id_tbl(i),
                  pg_app_from_evnt_cls_code_tbl(i),
                  pg_app_from_entity_code_tbl(i),
                  pg_app_from_trx_id_tbl(i),
                  pg_app_from_trx_level_type_tbl(i),
                  pg_app_from_line_id_tbl(i),
                  pg_adj_doc_app_id_tbl(i),
                  pg_adj_doc_entity_code_tbl(i),
                  pg_adj_doc_evnt_cls_code_tbl(i),
                  pg_adj_doc_trx_id_tbl(i),
                  pg_adj_doc_trx_level_type_tbl(i),
                  pg_summary_tax_line_num_tbl(i),
                  pg_content_owner_id_tbl(i),
                  pg_tax_regime_code_tbl(i),
                  pg_tax_tbl(i),
                  pg_tax_status_code_tbl(i),
                  pg_tax_rate_id_tbl(i),
                  pg_tax_rate_code_tbl(i),
                  pg_tax_rate_tbl(i),
                  pg_tax_jurisdiction_code_tbl(i),
                  pg_ledger_id_tbl(i),
                  pg_legal_entity_id_tbl(i),
                  pg_establishment_id_tbl(i),
                  pg_currency_convrsn_date_tbl(i),
                  pg_currency_convrsn_type_tbl(i),
                  pg_currency_convrsn_rate_tbl(i),
                  pg_taxable_basis_formula_tbl(i),
                  pg_tax_calculation_formula_tbl(i),
                  pg_tax_amt_included_flag_tbl(i),
                  pg_compounding_tax_flag_tbl(i),
                  pg_self_assessed_flag_tbl(i),
                  pg_reporting_only_flag_tbl(i),
                  -- pg_assoctd_child_frz_flag_tbl(i),
         --     pg_cpd_from_other_doc_flag_tbl(i),
                  pg_record_type_code_tbl(i),
                  pg_tax_provider_id_tbl(i),
                  pg_historical_flag_tbl(i),
                  pg_tax_amt_tbl(i),
                  pg_tax_amt_tax_curr_tbl(i),
                  pg_tax_amt_funcl_curr_tbl(i),
                  pg_ttl_rec_tax_amt_tbl(i),
                  pg_ttl_rec_tx_amt_fnc_crr_tbl(i),
                  pg_ttl_rec_tx_amt_tx_crr_tbl(i),
                  pg_ttl_nrec_tax_amt_tbl(i),
                  pg_ttl_nrec_tx_amt_fnc_crr_tbl(i),
                  pg_ttl_nrec_tx_amt_tx_crr_tbl(i),
                  pg_cancel_flag_tbl(i),
                  pg_delete_flag_tbl(i),
               --   pg_overridden_flag_tbl(i),
                  pg_manually_entered_flag_tbl(i),
                  -- bug6773534 pg_app_to_app_id_tbl(i),
                  -- bug6773534 pg_app_to_evnt_cls_code_tbl(i),
                  -- bug6773534 pg_app_to_entity_code_tbl(i),
                  -- bug6773534 pg_app_to_trx_id_tbl(i),
                  -- bug6773534 pg_app_to_trx_level_type_tbl(i),
                  -- bug6773534 pg_app_to_line_id_tbl(i),
                  pg_tax_xmptn_id_tbl(i),
               --   pg_tax_rate_bf_xmptn_tbl(i),
               --   pg_tax_rate_name_bf_xmptn_tbl(i),
               --   pg_xmpt_rate_modifier_tbl(i),
                  pg_xmpt_certificate_number_tbl(i),
                --  pg_xmpt_reason_tbl(i),
                  pg_xmpt_reason_code_tbl(i),
                --  pg_tax_rate_bf_xeptn_tbl(i),
                --  pg_tax_rate_name_bf_xeptn_tbl(i),
                  pg_tax_xeptn_id_tbl(i),
               --   pg_xeptn_rate_tbl(i),
                  pg_mrc_tax_line_flag_tbl(i),
                  pg_tax_only_line_flag_tbl(i)
                );

  IF (g_level_statement >= g_current_runtime_level ) THEN

        FND_LOG.STRING(g_level_statement,
               'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.create_summary_lines_crt_evnt',
               'Number of Rows Inserted in zx_lines_summary = ' || to_char(SQL%ROWCOUNT));
  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_procedure,
           'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.create_summary_lines_crt_evnt.END',
           'ZX_TRL_MANAGE_TAX_PKG: create_summary_lines_crt_evnt (-)'||x_return_status);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    l_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
             'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.create_summary_lines_crt_evnt',
              l_error_buffer);
    END IF;

END create_summary_lines_crt_evnt;

------------------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  create_summary_lines_upd_evnt
--
--  DESCRIPTION
--  Private procedure to create zx_lines_summary from zx_detail_tax_lines_gt
--  for tax_event_type of 'UPDATE' or 'OVERRIDE' with
--  retain_summ_tax_line_id_flag on event_class_rec of 'Y'
------------------------------------------------------------------------------
-- Bug 6456915 - associated_child_frozen_flag has been removed from grouping columns for summary tax lines
PROCEDURE create_summary_lines_upd_evnt(
  p_event_class_rec   IN          ZX_API_PUB.EVENT_CLASS_REC_TYPE,
  x_return_status     OUT NOCOPY  VARCHAR2
) IS

  l_error_buffer            VARCHAR2(100);
  l_index                   NUMBER;
  l_curr_ledger_id          NUMBER;
  l_summary_tax_line_number NUMBER;

  l_curr_trx_id             NUMBER;
  l_curr_entity_code        zx_evnt_cls_mappings.entity_code%TYPE;
  l_curr_event_class_code   zx_evnt_cls_mappings.event_class_code%TYPE;
  l_tax_rate_id             NUMBER;
  l_taxable_basis_formula   VARCHAR2(100);

  -- Following variables added for Error Handling Fix Bug#9765007
  l_err_idx                 BINARY_INTEGER;
  l_err_count               NUMBER;
  l_err_trx_id              NUMBER;
  l_context_info_rec        ZX_API_PUB.context_info_rec_type;

  summary_error             EXCEPTION;
  PRAGMA exception_init(summary_error, -24381);

BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
           'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.create_summary_lines_upd_evnt.BEGIN',
           'ZX_TRL_MANAGE_TAX_PKG: create_summary_lines_upd_evnt (+)');
  END IF;

  --  Initialize API return status to success
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS;

   SELECT tax_line_id, tax_rate_id bulk collect into
          tax_line_id_tbl, tax_rate_id_tbl
     FROM zx_lines tax
    WHERE
       -- bug fix 5417887
       -- application_id        = p_event_class_rec.application_id
       -- AND entity_code       = p_event_class_rec.entity_code
       -- AND event_class_code  = p_event_class_rec.event_class_code
       -- AND trx_id            = p_event_class_rec.trx_id
   EXISTS (SELECT 1
             FROM zx_lines_det_factors line
            WHERE tax.application_id = line.application_id
              AND tax.event_class_code = line.event_class_code
              AND tax.entity_code = line.entity_code
              AND tax.trx_id = line.trx_id
              AND line.event_id = p_event_class_rec.event_id)
      AND taxable_basis_formula is NULL ;

  l_tax_rate_id := 0;

  FOR i IN 1..tax_line_id_tbl.COUNT LOOP
    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
           'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.create_summary_lines_upd_evnt.BEGIN',
           'Tax line id for null taxable bsis formula'||to_char(tax_line_id_tbl(i)));
    END IF;

    IF l_tax_rate_id <> tax_rate_id_tbl(i) THEN
      l_tax_rate_id := tax_rate_id_tbl(i);
      BEGIN
        SELECT decode(adj_for_adhoc_amt_code,
                      'TAXABLE_BASIS','PRORATED_TB',
                      'STANDARD_TB')
          INTO l_taxable_basis_formula
          FROM zx_rates_b
         WHERE tax_rate_id = l_tax_rate_id;

      EXCEPTION
        WHEN OTHERS THEN
        NULL;
      END;
    END IF;

    UPDATE zx_lines
       SET taxable_basis_formula = l_taxable_basis_formula
     WHERE tax_line_id = tax_line_id_tbl(i);

  END LOOP;

  IF p_event_class_rec.retain_summ_tax_line_id_flag = 'Y' THEN
    -- in this case, the summary_tax_line_id on some detail lines are existed and should retain the summary tax line id
    SELECT   application_id,
             entity_code,
             event_class_code,
             trx_id,
             internal_organization_id,
             NVL(summary_tax_line_id,
                 zx_lines_summary_s.NEXTVAL )  summary_tax_line_id,
             count_detail_tax_line,
             count_detail_cancel_flag,
             trx_number,
             applied_from_application_id,
             applied_from_event_class_code,
             applied_from_entity_code,
             applied_from_trx_id,
             applied_from_trx_level_type,
             applied_from_line_id,
             adjusted_doc_application_id,
             adjusted_doc_entity_code,
             adjusted_doc_event_class_code,
             adjusted_doc_trx_id,
             adjusted_doc_trx_level_type,
             -- ROWNUM,                -- summary_tax_line_number
             content_owner_id,
             tax_regime_code,
             tax,
             tax_status_code,
             tax_rate_id,
             tax_rate_code,
             tax_rate,
             tax_jurisdiction_code,
             ledger_id,
             legal_entity_id,
             establishment_id,
             currency_conversion_date,
             currency_conversion_type,
             currency_conversion_rate,
             taxable_basis_formula,
             tax_calculation_formula,
             tax_amt_included_flag,
             compounding_tax_flag,
             self_assessed_flag,
             reporting_only_flag,
             -- associated_child_frozen_flag,
             -- copied_from_other_doc_flag,
             record_type_code,
             tax_provider_id,
             historical_flag,
             tax_amt,
             tax_amt_tax_curr,
             tax_amt_funcl_curr,
             total_rec_tax_amt,
             total_rec_tax_amt_funcl_curr,
             total_rec_tax_amt_tax_curr,
             total_nrec_tax_amt,
             total_nrec_tax_amt_funcl_curr,
             total_nrec_tax_amt_tax_curr,
             -- cancel_flag,
             'N'  delete_flag,
             -- overridden_flag,
             manually_entered_flag,
             -- bug6773534 applied_to_application_id,
             -- bug6773534 applied_to_event_class_code,
             -- bug6773534 applied_to_entity_code,
             -- bug6773534 applied_to_trx_id,
             -- bug6773534 applied_to_trx_level_type,
             -- bug6773534 applied_to_line_id,
             tax_exemption_id,
             -- tax_rate_before_exemption,
             -- tax_rate_name_before_exemption,
             -- exempt_rate_modifier,
             exempt_certificate_number,
             -- exempt_reason,
             exempt_reason_code,
             -- tax_rate_before_exception,
             -- tax_rate_name_before_exception,
             tax_exception_id,
             -- exception_rate,
             mrc_tax_line_flag,
             tax_only_line_flag
      BULK COLLECT INTO
             pg_application_id_tbl,
             pg_entity_code_tbl,
             pg_event_class_code_tbl,
             pg_trx_id_tbl,
             pg_internal_org_id_tbl,
             pg_summary_tax_line_id_tbl,
             pg_count_detail_tax_line_tbl,
             pg_count_detail_cancel_tbl,
             pg_trx_number_tbl,
             pg_app_from_app_id_tbl,
             pg_app_from_evnt_cls_code_tbl,
             pg_app_from_entity_code_tbl,
             pg_app_from_trx_id_tbl,
             pg_app_from_trx_level_type_tbl,
             pg_app_from_line_id_tbl,
             pg_adj_doc_app_id_tbl,
             pg_adj_doc_entity_code_tbl,
             pg_adj_doc_evnt_cls_code_tbl,
             pg_adj_doc_trx_id_tbl,
             pg_adj_doc_trx_level_type_tbl,
             -- pg_summary_tax_line_num_tbl,
             pg_content_owner_id_tbl,
             pg_tax_regime_code_tbl,
             pg_tax_tbl,
             pg_tax_status_code_tbl,
             pg_tax_rate_id_tbl,
             pg_tax_rate_code_tbl,
             pg_tax_rate_tbl,
             pg_tax_jurisdiction_code_tbl,
             pg_ledger_id_tbl,
             pg_legal_entity_id_tbl,
             pg_establishment_id_tbl,
             pg_currency_convrsn_date_tbl,
             pg_currency_convrsn_type_tbl,
             pg_currency_convrsn_rate_tbl,
             pg_taxable_basis_formula_tbl,
             pg_tax_calculation_formula_tbl,
             pg_tax_amt_included_flag_tbl,
             pg_compounding_tax_flag_tbl,
             pg_self_assessed_flag_tbl,
             pg_reporting_only_flag_tbl,
             -- pg_assoctd_child_frz_flag_tbl,
             -- pg_cpd_from_other_doc_flag_tbl,
             pg_record_type_code_tbl,
             pg_tax_provider_id_tbl,
             pg_historical_flag_tbl,
             pg_tax_amt_tbl,
             pg_tax_amt_tax_curr_tbl,
             pg_tax_amt_funcl_curr_tbl,
             pg_ttl_rec_tax_amt_tbl,
             pg_ttl_rec_tx_amt_fnc_crr_tbl,
             pg_ttl_rec_tx_amt_tx_crr_tbl,
             pg_ttl_nrec_tax_amt_tbl,
             pg_ttl_nrec_tx_amt_fnc_crr_tbl,
             pg_ttl_nrec_tx_amt_tx_crr_tbl,
             -- pg_cancel_flag_tbl,
             pg_delete_flag_tbl,
             -- pg_overridden_flag_tbl,
             pg_manually_entered_flag_tbl,
             -- bug6773534 pg_app_to_app_id_tbl,
             -- bug6773534 pg_app_to_evnt_cls_code_tbl,
             -- bug6773534 pg_app_to_entity_code_tbl,
             -- bug6773534 pg_app_to_trx_id_tbl,
             -- bug6773534 pg_app_to_trx_level_type_tbl,
             -- bug6773534 pg_app_to_line_id_tbl,
             pg_tax_xmptn_id_tbl,
             -- pg_tax_rate_bf_xmptn_tbl,
             -- pg_tax_rate_name_bf_xmptn_tbl,
             -- pg_xmpt_rate_modifier_tbl,
             pg_xmpt_certificate_number_tbl,
             -- pg_xmpt_reason_tbl,
             pg_xmpt_reason_code_tbl,
             -- pg_tax_rate_bf_xeptn_tbl,
             -- pg_tax_rate_name_bf_xeptn_tbl,
             pg_tax_xeptn_id_tbl,
             -- pg_xeptn_rate_tbl,
             pg_mrc_tax_line_flag_tbl,
             pg_tax_only_line_flag_tbl
      FROM ( SELECT application_id,
                    entity_code,
                    event_class_code,
                    trx_id,
                    internal_organization_id,
                    summary_tax_line_id,
                    COUNT(*)    count_detail_tax_line,
                    SUM(DECODE(cancel_flag, 'Y', 1, 0)) count_detail_cancel_flag,
                    trx_number,
                    applied_from_application_id,
                    applied_from_event_class_code,
                    applied_from_entity_code,
                    applied_from_trx_id,
                    applied_from_trx_level_type,
                    applied_from_line_id,
                    adjusted_doc_application_id,
                    adjusted_doc_entity_code,
                    adjusted_doc_event_class_code,
                    adjusted_doc_trx_id,
                    adjusted_doc_trx_level_type,
                    content_owner_id,
                    tax_regime_code,
                    tax,
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
                    -- associated_child_frozen_flag,
                    -- copied_from_other_doc_flag,
                    record_type_code,
                    tax_provider_id,
                    historical_flag,
                    SUM(tax_amt) tax_amt,
                    SUM(tax_amt_tax_curr) tax_amt_tax_curr,
                    SUM(tax_amt_funcl_curr) tax_amt_funcl_curr,
                    SUM(orig_tax_amt) orig_tax_amt,
                    SUM(rec_tax_amt) total_rec_tax_amt,
                    SUM(rec_tax_amt_funcl_curr) total_rec_tax_amt_funcl_curr,
                    SUM(rec_tax_amt_tax_curr) total_rec_tax_amt_tax_curr,
                    SUM(nrec_tax_amt) total_nrec_tax_amt,
                    SUM(nrec_tax_amt_funcl_curr) total_nrec_tax_amt_funcl_curr,
                    SUM(nrec_tax_amt_tax_curr) total_nrec_tax_amt_tax_curr,
                    -- cancel_flag,
                    -- overridden_flag,
                    manually_entered_flag,
                    -- bug6773534 applied_to_application_id,
                    -- bug6773534 applied_to_event_class_code,
                    -- bug6773534 applied_to_entity_code,
                    -- bug6773534 applied_to_trx_id,
                    -- bug6773534 applied_to_trx_level_type,
                    -- bug6773534 applied_to_line_id,
                    tax_exemption_id,
                    -- tax_rate_before_exemption,
                    -- tax_rate_name_before_exemption,
                    -- exempt_rate_modifier,
                    exempt_certificate_number,
                    -- exempt_reason,
                    exempt_reason_code,
                    -- tax_rate_before_exception,
                    -- tax_rate_name_before_exception,
                    tax_exception_id,
                    -- exception_rate,
                    mrc_tax_line_flag,
                    tax_only_line_flag
               FROM ZX_LINES tax
              WHERE -- bug fix 5417887
                    -- application_id        = p_event_class_rec.application_id
                    -- AND entity_code       = p_event_class_rec.entity_code
                    -- AND event_class_code  = p_event_class_rec.event_class_code
                    -- AND trx_id            = p_event_class_rec.trx_id
             EXISTS (SELECT 1
                       FROM zx_lines_det_factors line
                      WHERE tax.application_id = line.application_id
                        AND tax.event_class_code = line.event_class_code
                        AND tax.entity_code = line.entity_code
                        AND tax.trx_id = line.trx_id
                        AND line.event_id = p_event_class_rec.event_id)
              GROUP BY  application_id,
                        event_class_code,
                        entity_code,
                        trx_id,
                        internal_organization_id,
                        trx_number,
                        summary_tax_line_id,
                        applied_from_application_id,
                        applied_from_event_class_code,
                        applied_from_entity_code,
                        applied_from_trx_id,
                        applied_from_trx_level_type,
                        applied_from_line_id,
                        adjusted_doc_application_id,
                        adjusted_doc_entity_code,
                        adjusted_doc_event_class_code,
                        adjusted_doc_trx_id,
                        adjusted_doc_trx_level_type,
                        content_owner_id,
                        tax_regime_code,
                        tax,
                        tax_status_code,
                        tax_rate_id,
                        tax_rate_code,
                        tax_rate,
                        tax_jurisdiction_code,
                        ledger_id,
                        legal_entity_id,
                        establishment_id,
                        TRUNC(currency_conversion_date),
                        currency_conversion_type,
                        currency_conversion_rate,
                        taxable_basis_formula,
                        tax_calculation_formula,
                        tax_amt_included_flag,
                        compounding_tax_flag,
                        self_assessed_flag,
                        reporting_only_flag,
                        -- associated_child_frozen_flag,
                        -- copied_from_other_doc_flag,
                        record_type_code,
                        tax_provider_id,
                        historical_flag,
                        -- cancel_flag,
                        -- overridden_flag,
                        manually_entered_flag,
                        -- bug6773534 applied_to_application_id,
                        -- bug6773534 applied_to_event_class_code,
                        -- bug6773534 applied_to_entity_code,
                        -- bug6773534 applied_to_trx_id,
                        -- bug6773534 applied_to_trx_level_type,
                        -- bug6773534 applied_to_line_id,
                        tax_exemption_id,
                        -- tax_rate_before_exemption,
                        -- tax_rate_name_before_exemption,
                        -- exempt_rate_modifier,
                        exempt_certificate_number,
                        -- exempt_reason,
                        exempt_reason_code,
                        -- tax_rate_before_exception,
                        -- tax_rate_name_before_exception,
                        tax_exception_id,
                        -- exception_rate,
                        mrc_tax_line_flag,
                        tax_only_line_flag
               ORDER BY application_id,
                        event_class_code,
                        entity_code,
                        trx_id,
                        trx_number,
                        mrc_tax_line_flag,
                        ledger_id,
                        summary_tax_line_id,
                        applied_from_application_id,
                        applied_from_event_class_code,
                        applied_from_entity_code,
                        applied_from_trx_id,
                        applied_from_trx_level_type,
                        applied_from_line_id,
                        adjusted_doc_application_id,
                        adjusted_doc_entity_code,
                        adjusted_doc_event_class_code,
                        adjusted_doc_trx_id,
                        adjusted_doc_trx_level_type,
                        content_owner_id,
                        tax_regime_code,
                        tax,
                        tax_status_code,
                        tax_rate_id,
                        tax_rate_code,
                        tax_rate,
                        tax_jurisdiction_code,
                        legal_entity_id,
                        establishment_id,
                        -- TRUNC(currency_conversion_date),
                        -- currency_conversion_type,
                        -- currency_conversion_rate,
                        taxable_basis_formula,
                        tax_calculation_formula,
                        tax_amt_included_flag,
                        compounding_tax_flag,
                        self_assessed_flag,
                        reporting_only_flag,
                        -- associated_child_frozen_flag,
                        -- copied_from_other_doc_flag,
                        record_type_code,
                        tax_provider_id,
                        historical_flag,
                        -- cancel_flag,
                        -- overridden_flag,
                        manually_entered_flag,
                        -- bug6773534 applied_to_application_id,
                        -- bug6773534 applied_to_event_class_code,
                        -- bug6773534 applied_to_entity_code,
                        -- bug6773534 applied_to_trx_id,
                        -- bug6773534 applied_to_trx_level_type,
                        -- bug6773534 applied_to_line_id,
                        tax_exemption_id,
                        -- tax_rate_before_exemption,
                        -- tax_rate_name_before_exemption,
                        -- exempt_rate_modifier,
                        exempt_certificate_number,
                        -- exempt_reason,
                        exempt_reason_code,
                        -- tax_rate_before_exception,
                        -- tax_rate_name_before_exception,
                        tax_exception_id,
                        -- exception_rate,
                        tax_only_line_flag );

    -- get the tax line id in the same order of the summary tax line as in the first query.
    SELECT tax_line_id  BULK COLLECT INTO  pg_tax_line_id_tbl
      FROM zx_lines tax
      -- bug fix 5417887
      -- WHERE application_id  = p_event_class_rec.application_id
      -- AND entity_code       = p_event_class_rec.entity_code
      -- AND event_class_code  = p_event_class_rec.event_class_code
      -- AND trx_id            = p_event_class_rec.trx_id
     WHERE EXISTS (
              SELECT 1
                FROM zx_lines_det_factors line
               WHERE tax.application_id = line.application_id
                 AND tax.event_class_code = line.event_class_code
                 AND tax.entity_code = line.entity_code
                 AND tax.trx_id = line.trx_id
                 AND line.event_id = p_event_class_rec.event_id)
      ORDER BY application_id,
               event_class_code,
               entity_code,
               trx_id,
               trx_number,
               mrc_tax_line_flag,
               ledger_id,
               summary_tax_line_id,
               applied_from_application_id,
               applied_from_event_class_code,
               applied_from_entity_code,
               applied_from_trx_id,
               applied_from_trx_level_type,
               applied_from_line_id,
               adjusted_doc_application_id,
               adjusted_doc_entity_code,
               adjusted_doc_event_class_code,
               adjusted_doc_trx_id,
               adjusted_doc_trx_level_type,
               content_owner_id,
               tax_regime_code,
               tax,
               tax_status_code,
               tax_rate_id,
               tax_rate_code,
               tax_rate,
               tax_jurisdiction_code,
               legal_entity_id,
               establishment_id,
               -- TRUNC(currency_conversion_date),
               -- currency_conversion_type,
               -- currency_conversion_rate,
               taxable_basis_formula,
               tax_calculation_formula,
               tax_amt_included_flag,
               compounding_tax_flag,
               self_assessed_flag,
               reporting_only_flag,
               -- associated_child_frozen_flag,
               --  copied_from_other_doc_flag,
               record_type_code,
               tax_provider_id,
               historical_flag,
               -- cancel_flag,
               -- overridden_flag,
               manually_entered_flag,
               -- bug6773534 applied_to_application_id,
               -- bug6773534 applied_to_event_class_code,
               -- bug6773534 applied_to_entity_code,
               -- bug6773534 applied_to_trx_id,
               -- bug6773534 applied_to_trx_level_type,
               -- bug6773534 applied_to_line_id,
               tax_exemption_id,
               -- tax_rate_before_exemption,
               -- tax_rate_name_before_exemption,
               -- exempt_rate_modifier,
               exempt_certificate_number,
               -- exempt_reason,
               exempt_reason_code,
               -- tax_rate_before_exception,
               -- tax_rate_name_before_exception,
               tax_exception_id,
               -- exception_rate,
               tax_only_line_flag ;

  ELSE -- p_event_class_rec.retain_summ_tax_line_id_flag = 'N'
    --
    -- no need to retain the current summary_tax_line_id
    -- just generate a new id
    --
    SELECT  application_id,
            entity_code,
            event_class_code,
            trx_id,
            internal_organization_id,
            zx_lines_summary_s.NEXTVAL,
            count_detail_tax_line,
            count_detail_cancel_flag,
            trx_number,
            applied_from_application_id,
            applied_from_event_class_code,
            applied_from_entity_code,
            applied_from_trx_id,
            applied_from_trx_level_type,
            applied_from_line_id,
            adjusted_doc_application_id,
            adjusted_doc_entity_code,
            adjusted_doc_event_class_code,
            adjusted_doc_trx_id,
            adjusted_doc_trx_level_type,
            -- ROWNUM,                      -- summary_tax_line_number
            content_owner_id,
            tax_regime_code,
            tax,
            tax_status_code,
            tax_rate_id,
            tax_rate_code,
            tax_rate,
            tax_jurisdiction_code,
            ledger_id,
            legal_entity_id,
            establishment_id,
            currency_conversion_date,
            currency_conversion_type,
            currency_conversion_rate,
            taxable_basis_formula,
            tax_calculation_formula,
            tax_amt_included_flag,
            compounding_tax_flag,
            self_assessed_flag,
            reporting_only_flag,
            -- associated_child_frozen_flag,
            -- copied_from_other_doc_flag,
            record_type_code,
            tax_provider_id,
            historical_flag,
            tax_amt,
            tax_amt_tax_curr,
            tax_amt_funcl_curr,
            total_rec_tax_amt,
            total_rec_tax_amt_funcl_curr,
            total_rec_tax_amt_tax_curr,
            total_nrec_tax_amt,
            total_nrec_tax_amt_funcl_curr,
            total_nrec_tax_amt_tax_curr,
            -- cancel_flag,
            delete_flag,
            -- overridden_flag,
            manually_entered_flag,
            -- bug6773534 applied_to_application_id,
            -- bug6773534 applied_to_event_class_code,
            -- bug6773534 applied_to_entity_code,
            -- bug6773534 applied_to_trx_id,
            -- bug6773534 applied_to_trx_level_type,
            -- bug6773534 applied_to_line_id,
            tax_exemption_id,
            -- tax_rate_before_exemption,
            -- tax_rate_name_before_exemption,
            -- exempt_rate_modifier,
            exempt_certificate_number,
            -- exempt_reason,
            exempt_reason_code,
            -- tax_rate_before_exception,
            -- tax_rate_name_before_exception,
            tax_exception_id,
            -- exception_rate,
            mrc_tax_line_flag,
            tax_only_line_flag
     BULK COLLECT INTO
            pg_application_id_tbl,
            pg_entity_code_tbl,
            pg_event_class_code_tbl,
            pg_trx_id_tbl,
            pg_internal_org_id_tbl,
            pg_summary_tax_line_id_tbl,
            pg_count_detail_tax_line_tbl,
            pg_count_detail_cancel_tbl,
            pg_trx_number_tbl,
            pg_app_from_app_id_tbl,
            pg_app_from_evnt_cls_code_tbl,
            pg_app_from_entity_code_tbl,
            pg_app_from_trx_id_tbl,
            pg_app_from_trx_level_type_tbl,
            pg_app_from_line_id_tbl,
            pg_adj_doc_app_id_tbl,
            pg_adj_doc_entity_code_tbl,
            pg_adj_doc_evnt_cls_code_tbl,
            pg_adj_doc_trx_id_tbl,
            pg_adj_doc_trx_level_type_tbl,
            -- pg_summary_tax_line_num_tbl,
            pg_content_owner_id_tbl,
            pg_tax_regime_code_tbl,
            pg_tax_tbl,
            pg_tax_status_code_tbl,
            pg_tax_rate_id_tbl,
            pg_tax_rate_code_tbl,
            pg_tax_rate_tbl,
            pg_tax_jurisdiction_code_tbl,
            pg_ledger_id_tbl,
            pg_legal_entity_id_tbl,
            pg_establishment_id_tbl,
            pg_currency_convrsn_date_tbl,
            pg_currency_convrsn_type_tbl,
            pg_currency_convrsn_rate_tbl,
            pg_taxable_basis_formula_tbl,
            pg_tax_calculation_formula_tbl,
            pg_tax_amt_included_flag_tbl,
            pg_compounding_tax_flag_tbl,
            pg_self_assessed_flag_tbl,
            pg_reporting_only_flag_tbl,
            -- pg_assoctd_child_frz_flag_tbl,
            -- pg_cpd_from_other_doc_flag_tbl,
            pg_record_type_code_tbl,
            pg_tax_provider_id_tbl,
            pg_historical_flag_tbl,
            pg_tax_amt_tbl,
            pg_tax_amt_tax_curr_tbl,
            pg_tax_amt_funcl_curr_tbl,
            pg_ttl_rec_tax_amt_tbl,
            pg_ttl_rec_tx_amt_fnc_crr_tbl,
            pg_ttl_rec_tx_amt_tx_crr_tbl,
            pg_ttl_nrec_tax_amt_tbl,
            pg_ttl_nrec_tx_amt_fnc_crr_tbl,
            pg_ttl_nrec_tx_amt_tx_crr_tbl,
            -- pg_cancel_flag_tbl,
            pg_delete_flag_tbl,
            -- pg_overridden_flag_tbl,
            pg_manually_entered_flag_tbl,
            -- bug6773534 pg_app_to_app_id_tbl,
            -- bug6773534 pg_app_to_evnt_cls_code_tbl,
            -- bug6773534 pg_app_to_entity_code_tbl,
            -- bug6773534 pg_app_to_trx_id_tbl,
            -- bug6773534 pg_app_to_trx_level_type_tbl,
            -- bug6773534 pg_app_to_line_id_tbl,
            pg_tax_xmptn_id_tbl,
            -- pg_tax_rate_bf_xmptn_tbl,
            -- pg_tax_rate_name_bf_xmptn_tbl,
            -- pg_xmpt_rate_modifier_tbl,
            pg_xmpt_certificate_number_tbl,
            -- pg_xmpt_reason_tbl,
            pg_xmpt_reason_code_tbl,
            -- pg_tax_rate_bf_xeptn_tbl,
            -- pg_tax_rate_name_bf_xeptn_tbl,
            pg_tax_xeptn_id_tbl,
            -- pg_xeptn_rate_tbl,
            pg_mrc_tax_line_flag_tbl,
            pg_tax_only_line_flag_tbl
      FROM ( SELECT application_id,
                    event_class_code,
                    entity_code,
                    trx_id,
                    internal_organization_id,
                    COUNT(*)  count_detail_tax_line,
                    SUM(DECODE(cancel_flag, 'Y', 1, 0)) count_detail_cancel_flag,
                    trx_number,
                    applied_from_application_id,
                    applied_from_event_class_code,
                    applied_from_entity_code,
                    applied_from_trx_id,
                    applied_from_trx_level_type,
                    applied_from_line_id,
                    adjusted_doc_application_id,
                    adjusted_doc_entity_code,
                    adjusted_doc_event_class_code,
                    adjusted_doc_trx_id,
                    adjusted_doc_trx_level_type,
                    content_owner_id,
                    tax_regime_code,
                    tax,
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
                    -- associated_child_frozen_flag,
                    -- copied_from_other_doc_flag,
                    record_type_code,
                    tax_provider_id,
                    historical_flag,
                    SUM(tax_amt) tax_amt,
                    SUM(tax_amt_tax_curr) tax_amt_tax_curr,
                    SUM(tax_amt_funcl_curr) tax_amt_funcl_curr,
                    SUM(orig_tax_amt) orig_tax_amt,
                    SUM(rec_tax_amt) total_rec_tax_amt,
                    SUM(rec_tax_amt_funcl_curr) total_rec_tax_amt_funcl_curr,
                    SUM(rec_tax_amt_tax_curr) total_rec_tax_amt_tax_curr,
                    SUM(nrec_tax_amt) total_nrec_tax_amt,
                    SUM(nrec_tax_amt_funcl_curr) total_nrec_tax_amt_funcl_curr,
                    SUM(nrec_tax_amt_tax_curr) total_nrec_tax_amt_tax_curr,
                    -- cancel_flag,
                    delete_flag,
                    -- overridden_flag,
                    manually_entered_flag,
                    -- bug6773534 applied_to_application_id,
                    -- bug6773534 applied_to_event_class_code,
                    -- bug6773534 applied_to_entity_code,
                    -- bug6773534 applied_to_trx_id,
                    -- bug6773534 applied_to_trx_level_type,
                    -- bug6773534 applied_to_line_id,
                    tax_exemption_id,
                    -- tax_rate_before_exemption,
                    -- tax_rate_name_before_exemption,
                    -- exempt_rate_modifier,
                    exempt_certificate_number,
                    -- exempt_reason,
                    exempt_reason_code,
                    -- tax_rate_before_exception,
                    -- tax_rate_name_before_exception,
                    tax_exception_id,
                    -- exception_rate,
                    mrc_tax_line_flag,
                    tax_only_line_flag
               FROM ZX_LINES tax
               -- bug fix 5417887
               -- WHERE application_id  = p_event_class_rec.application_id
               -- AND entity_code       = p_event_class_rec.entity_code
               -- AND event_class_code  = p_event_class_rec.event_class_code
               -- AND trx_id            = p_event_class_rec.trx_id
              WHERE EXISTS (
                      SELECT 1
                        FROM zx_lines_det_factors line
                       WHERE tax.application_id = line.application_id
                         AND tax.event_class_code = line.event_class_code
                         AND tax.entity_code = line.entity_code
                         AND tax.trx_id = line.trx_id
                         AND line.event_id = p_event_class_rec.event_id)
              GROUP BY  application_id,
                        event_class_code,
                        entity_code,
                        trx_id,
                        internal_organization_id,
                        trx_number,
                        applied_from_application_id,
                        applied_from_event_class_code,
                        applied_from_entity_code,
                        applied_from_trx_id,
                        applied_from_trx_level_type,
                        applied_from_line_id,
                        adjusted_doc_application_id,
                        adjusted_doc_entity_code,
                        adjusted_doc_event_class_code,
                        adjusted_doc_trx_id,
                        adjusted_doc_trx_level_type,
                        content_owner_id,
                        tax_regime_code,
                        tax,
                        tax_status_code,
                        tax_rate_id,
                        tax_rate_code,
                        tax_rate,
                        tax_jurisdiction_code,
                        ledger_id,
                        legal_entity_id,
                        establishment_id,
                        TRUNC(currency_conversion_date),
                        currency_conversion_type,
                        currency_conversion_rate,
                        taxable_basis_formula,
                        tax_calculation_formula,
                        tax_amt_included_flag,
                        compounding_tax_flag,
                        self_assessed_flag,
                        reporting_only_flag,
                        -- associated_child_frozen_flag,
                        -- copied_from_other_doc_flag,
                        record_type_code,
                        tax_provider_id,
                        historical_flag,
                        -- cancel_flag,
                        delete_flag,
                        -- overridden_flag,
                        manually_entered_flag,
                        -- bug6773534 applied_to_application_id,
                        -- bug6773534 applied_to_event_class_code,
                        -- bug6773534 applied_to_entity_code,
                        -- bug6773534 applied_to_trx_id,
                        -- bug6773534 applied_to_trx_level_type,
                        -- bug6773534 applied_to_line_id,
                        tax_exemption_id,
                        -- tax_rate_before_exemption,
                        -- tax_rate_name_before_exemption,
                        -- exempt_rate_modifier,
                        exempt_certificate_number,
                        -- exempt_reason,
                        exempt_reason_code,
                        -- tax_rate_before_exception,
                        -- tax_rate_name_before_exception,
                        tax_exception_id,
                        -- exception_rate,
                        mrc_tax_line_flag,
                        tax_only_line_flag
               ORDER BY application_id,
                        event_class_code,
                        entity_code,
                        trx_id,
                        trx_number,
                        mrc_tax_line_flag,
                        ledger_id,
                        applied_from_application_id,
                        applied_from_event_class_code,
                        applied_from_entity_code,
                        applied_from_trx_id,
                        applied_from_trx_level_type,
                        applied_from_line_id,
                        adjusted_doc_application_id,
                        adjusted_doc_entity_code,
                        adjusted_doc_event_class_code,
                        adjusted_doc_trx_id,
                        adjusted_doc_trx_level_type,
                        content_owner_id,
                        tax_regime_code,
                        tax,
                        tax_status_code,
                        tax_rate_id,
                        tax_rate_code,
                        tax_rate,
                        tax_jurisdiction_code,
                        legal_entity_id,
                        establishment_id,
                        -- TRUNC(currency_conversion_date),
                        -- currency_conversion_type,
                        -- currency_conversion_rate,
                        taxable_basis_formula,
                        tax_calculation_formula,
                        tax_amt_included_flag,
                        compounding_tax_flag,
                        self_assessed_flag,
                        reporting_only_flag,
                        -- associated_child_frozen_flag,
                        -- copied_from_other_doc_flag,
                        record_type_code,
                        tax_provider_id,
                        historical_flag,
                        -- cancel_flag,
                        delete_flag,
                        -- overridden_flag,
                        manually_entered_flag,
                        -- bug6773534 applied_to_application_id,
                        -- bug6773534 applied_to_event_class_code,
                        -- bug6773534 applied_to_entity_code,
                        -- bug6773534 applied_to_trx_id,
                        -- bug6773534 applied_to_trx_level_type,
                        -- bug6773534 applied_to_line_id,
                        tax_exemption_id,
                        -- tax_rate_before_exemption,
                        -- tax_rate_name_before_exemption,
                        -- exempt_rate_modifier,
                        exempt_certificate_number,
                        -- exempt_reason,
                        exempt_reason_code,
                        -- tax_rate_before_exception,
                        -- tax_rate_name_before_exception,
                        tax_exception_id,
                        -- exception_rate,
                        tax_only_line_flag );

    -- get the tax line id IN the same order of the summary tax line as IN the first query.
    SELECT tax_line_id  BULK COLLECT INTO  pg_tax_line_id_tbl
      FROM zx_lines tax
      -- bug fix 5417887
      -- WHERE application_id  = p_event_class_rec.application_id
      -- AND entity_code       = p_event_class_rec.entity_code
      -- AND event_class_code  = p_event_class_rec.event_class_code
      -- AND trx_id            = p_event_class_rec.trx_id
      WHERE EXISTS (
              SELECT 1
                FROM zx_lines_det_factors line
               WHERE tax.application_id = line.application_id
                 AND tax.event_class_code = line.event_class_code
                 AND tax.entity_code = line.entity_code
                 AND tax.trx_id = line.trx_id
                 AND line.event_id = p_event_class_rec.event_id)
      ORDER BY application_id,
               event_class_code,
               entity_code,
               trx_id,
               trx_number,
               mrc_tax_line_flag,
               ledger_id,
               applied_from_application_id,
               applied_from_event_class_code,
               applied_from_entity_code,
               applied_from_trx_id,
               applied_from_trx_level_type,
               applied_from_line_id,
               adjusted_doc_application_id,
               adjusted_doc_entity_code,
               adjusted_doc_event_class_code,
               adjusted_doc_trx_id,
               adjusted_doc_trx_level_type,
               content_owner_id,
               tax_regime_code,
               tax,
               tax_status_code,
               tax_rate_id,
               tax_rate_code,
               tax_rate,
               tax_jurisdiction_code,
               legal_entity_id,
               establishment_id,
               -- TRUNC(currency_conversion_date),
               -- currency_conversion_type,
               -- currency_conversion_rate,
               taxable_basis_formula,
               tax_calculation_formula,
               tax_amt_included_flag,
               compounding_tax_flag,
               self_assessed_flag,
               reporting_only_flag,
               -- associated_child_frozen_flag,
               -- copied_from_other_doc_flag,
               record_type_code,
               tax_provider_id,
               historical_flag,
               -- cancel_flag,
               delete_flag,
               -- overridden_flag,
               manually_entered_flag,
               -- bug6773534 applied_to_application_id,
               -- bug6773534 applied_to_event_class_code,
               -- bug6773534 applied_to_entity_code,
               -- bug6773534 applied_to_trx_id,
               -- bug6773534 applied_to_trx_level_type,
               -- bug6773534 applied_to_line_id,
               tax_exemption_id,
               -- tax_rate_before_exemption,
               -- tax_rate_name_before_exemption,
               -- exempt_rate_modifier,
               exempt_certificate_number,
               -- exempt_reason,
               exempt_reason_code,
               -- tax_rate_before_exception,
               -- tax_rate_name_before_exception,
               tax_exception_id,
               -- exception_rate,
               tax_only_line_flag ;


  END IF; -- p_event_class_rec.retain_summ_tax_line_id_flag = 'Y'

  l_index := 1;
  l_curr_ledger_id := -1;
  l_summary_tax_line_number := -1;

  l_curr_trx_id := -1;
  l_curr_entity_code := '@#$%^&*';
  l_curr_event_class_code := '@#$%^&*';


  FOR i IN 1.. pg_summary_tax_line_id_tbl.COUNT LOOP

    -- the following code is not needed as we are not creating MRC tax lines in eBTax repository
    -- due to the order by clause, it guranteed that the none_mrc line will
    -- come first, then followed by the mrc tax lines.
    -- IF l_curr_ledger_id = -1 OR l_curr_ledger_id <> pg_ledger_id_tbl(i) THEN
    --   l_curr_ledger_id := pg_ledger_id_tbl(i);
    -- END IF;

    -- populate the summary_tax_line_number
    -- Reset the summary tax line number whenever the entity_code, Event Class Code
    -- or Trx id changes

    IF (l_curr_entity_code = '@#$%^&*' and  l_curr_event_class_code = '@#$%^&*' and l_curr_trx_id = -1)
      or l_curr_event_class_code <> pg_event_class_code_tbl(i)
      or l_curr_trx_id <> pg_trx_id_tbl(i)
      or l_curr_entity_code <> pg_entity_code_tbl(i)
    THEN
      l_curr_event_class_code := pg_event_class_code_tbl(i);
      l_curr_trx_id := pg_trx_id_tbl(i);
      l_curr_entity_code := pg_entity_code_tbl(i);

      l_summary_tax_line_number := 1;
    ELSE
      l_summary_tax_line_number := l_summary_tax_line_number + 1;
    END IF;

    pg_summary_tax_line_num_tbl(i) := l_summary_tax_line_number;

    -- populate the summary_tax_line_id to the corresponding detail_tax_line_id
    FOR j IN 1.. pg_count_detail_tax_line_tbl(i) LOOP
      pg_detail_tax_smry_line_id_tbl(l_index) := pg_summary_tax_line_id_tbl(i);
      l_index := l_index+1;
    END LOOP;

    IF pg_count_detail_cancel_tbl(i) = pg_count_detail_tax_line_tbl(i) THEN
      pg_cancel_flag_tbl(i) := 'Y';
    ELSE
      pg_cancel_flag_tbl(i) := NULL;
    END IF;

  END LOOP;

  -- update the summary_tax_line_id column in the detail tax line table
  FORALL i IN 1.. pg_tax_line_id_tbl.COUNT
    UPDATE zx_lines
       SET summary_tax_line_id = pg_detail_tax_smry_line_id_tbl(i)
     WHERE tax_line_id = pg_tax_line_id_tbl(i);

  -- insert the summary tax lines in the zx_lines_summary table.
  FORALL i IN 1..pg_summary_tax_line_id_tbl.COUNT SAVE EXCEPTIONS
    INSERT INTO zx_lines_summary(
                  summary_tax_line_id,
                  object_version_number,
                  created_by,
                  creation_date,
                  last_updated_by,
                  last_update_date,
                  last_update_login,
                  internal_organization_id,
                  application_id,
                  entity_code,
                  event_class_code,
                  -- tax_event_class_code,
                  trx_id,
                  trx_number,
                  applied_from_application_id,
                  applied_from_event_class_code,
                  applied_from_entity_code,
                  -- applied_from_trx_number,
                  applied_from_trx_id,
                  applied_from_trx_level_type,
                  applied_from_line_id,
                  adjusted_doc_application_id,
                  adjusted_doc_entity_code,
                  adjusted_doc_event_class_code,
                  adjusted_doc_trx_id,
                  adjusted_doc_trx_level_type,
                  -- adjusted_doc_number,
                  summary_tax_line_number,
                  content_owner_id,
                  -- tax_regime_id,
                  tax_regime_code,
                  -- tax_id,
                  tax,
                  -- tax_status_id,
                  tax_status_code,
                  tax_rate_id,
                  tax_rate_code,
                  tax_rate,
                  -- tax_jurisdiction_id,
                  tax_jurisdiction_code,
                  ledger_id,
                  legal_entity_id,
                  establishment_id,
                  currency_conversion_date,
                  currency_conversion_type,
                  currency_conversion_rate,
                  taxable_basis_formula,
                  tax_calculation_formula,
                  tax_amt_included_flag,
                  compounding_tax_flag,
                  self_assessed_flag,
                  reporting_only_flag,
                  -- associated_child_frozen_flag,
                  -- copied_from_other_doc_flag,
                  record_type_code,
                  tax_provider_id,
                  historical_flag,
                  tax_amt,
                  tax_amt_tax_curr,
                  tax_amt_funcl_curr,
                  -- orig_tax_amt,
                  total_rec_tax_amt,
                  total_rec_tax_amt_funcl_curr,
                  total_rec_tax_amt_tax_curr,
                  total_nrec_tax_amt,
                  total_nrec_tax_amt_funcl_curr,
                  total_nrec_tax_amt_tax_curr,
                  cancel_flag,
                  -- purge_flag,
                  delete_flag,
                  -- overridden_flag,
                  manually_entered_flag,
                  -- bug6773534 applied_to_application_id,
                  -- bug6773534 applied_to_event_class_code,
                  -- bug6773534 applied_to_entity_code,
                  -- bug6773534 applied_to_trx_id,
                  -- bug6773534 applied_to_trx_level_type,
                  -- bug6773534 applied_to_line_id,
                  tax_exemption_id,
                  -- tax_rate_before_exemption,
                  -- tax_rate_name_before_exemption,
                  -- exempt_rate_modifier,
                  exempt_certificate_number,
                  -- exempt_reason,
                  exempt_reason_code,
                  -- tax_rate_before_exception,
                  -- tax_rate_name_before_exception,
                  tax_exception_id,
                  -- exception_rate,
                  mrc_tax_line_flag,
                  tax_only_line_flag )
         VALUES (
                  pg_summary_tax_line_id_tbl(i),
                  1,        -- object_version_number
                  FND_GLOBAL.user_id,
                  SYSDATE,
                  FND_GLOBAL.user_id,
                  SYSDATE,
                  FND_GLOBAL.user_id,
                  pg_internal_org_id_tbl(i),
                  pg_application_id_tbl(i),
                  pg_entity_code_tbl(i),
                  pg_event_class_code_tbl(i),
                  -- tax_event_class_code,
                  pg_trx_id_tbl(i),
                  pg_trx_number_tbl(i),
                  pg_app_from_app_id_tbl(i),
                  pg_app_from_evnt_cls_code_tbl(i),
                  pg_app_from_entity_code_tbl(i),
                  pg_app_from_trx_id_tbl(i),
                  pg_app_from_trx_level_type_tbl(i),
                  pg_app_from_line_id_tbl(i),
                  pg_adj_doc_app_id_tbl(i),
                  pg_adj_doc_entity_code_tbl(i),
                  pg_adj_doc_evnt_cls_code_tbl(i),
                  pg_adj_doc_trx_id_tbl(i),
                  pg_adj_doc_trx_level_type_tbl(i),
                  pg_summary_tax_line_num_tbl(i),
                  pg_content_owner_id_tbl(i),
                  pg_tax_regime_code_tbl(i),
                  pg_tax_tbl(i),
                  pg_tax_status_code_tbl(i),
                  pg_tax_rate_id_tbl(i),
                  pg_tax_rate_code_tbl(i),
                  pg_tax_rate_tbl(i),
                  pg_tax_jurisdiction_code_tbl(i),
                  pg_ledger_id_tbl(i),
                  pg_legal_entity_id_tbl(i),
                  pg_establishment_id_tbl(i),
                  pg_currency_convrsn_date_tbl(i),
                  pg_currency_convrsn_type_tbl(i),
                  pg_currency_convrsn_rate_tbl(i),
                  pg_taxable_basis_formula_tbl(i),
                  pg_tax_calculation_formula_tbl(i),
                  pg_tax_amt_included_flag_tbl(i),
                  pg_compounding_tax_flag_tbl(i),
                  pg_self_assessed_flag_tbl(i),
                  pg_reporting_only_flag_tbl(i),
                  -- pg_assoctd_child_frz_flag_tbl(i),
                  -- pg_cpd_from_other_doc_flag_tbl(i),
                  pg_record_type_code_tbl(i),
                  pg_tax_provider_id_tbl(i),
                  pg_historical_flag_tbl(i),
                  pg_tax_amt_tbl(i),
                  pg_tax_amt_tax_curr_tbl(i),
                  pg_tax_amt_funcl_curr_tbl(i),
                  pg_ttl_rec_tax_amt_tbl(i),
                  pg_ttl_rec_tx_amt_fnc_crr_tbl(i),
                  pg_ttl_rec_tx_amt_tx_crr_tbl(i),
                  pg_ttl_nrec_tax_amt_tbl(i),
                  pg_ttl_nrec_tx_amt_fnc_crr_tbl(i),
                  pg_ttl_nrec_tx_amt_tx_crr_tbl(i),
                  pg_cancel_flag_tbl(i),
                  pg_delete_flag_tbl(i),
                  -- pg_overridden_flag_tbl(i),
                  pg_manually_entered_flag_tbl(i),
                  -- bug6773534 pg_app_to_app_id_tbl(i),
                  -- bug6773534 pg_app_to_evnt_cls_code_tbl(i),
                  -- bug6773534 pg_app_to_entity_code_tbl(i),
                  -- bug6773534 pg_app_to_trx_id_tbl(i),
                  -- bug6773534 pg_app_to_trx_level_type_tbl(i),
                  -- bug6773534 pg_app_to_line_id_tbl(i),
                  pg_tax_xmptn_id_tbl(i),
                  -- pg_tax_rate_bf_xmptn_tbl(i),
                  -- pg_tax_rate_name_bf_xmptn_tbl(i),
                  -- pg_xmpt_rate_modifier_tbl(i),
                  pg_xmpt_certificate_number_tbl(i),
                  -- pg_xmpt_reason_tbl(i),
                  pg_xmpt_reason_code_tbl(i),
                  -- pg_tax_rate_bf_xeptn_tbl(i),
                  -- pg_tax_rate_name_bf_xeptn_tbl(i),
                  pg_tax_xeptn_id_tbl(i),
                  -- pg_xeptn_rate_tbl(i),
                  pg_mrc_tax_line_flag_tbl(i),
                  pg_tax_only_line_flag_tbl(i)
                );

  IF (g_level_statement >= g_current_runtime_level ) THEN

        FND_LOG.STRING(g_level_statement,
               'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.create_summary_lines_upd_evnt',
               'Number of Rows Inserted in zx_lines_summary for update = ' || to_char(SQL%ROWCOUNT));
  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_procedure,
           'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.create_summary_lines_upd_evnt.END',
           'ZX_TRL_MANAGE_TAX_PKG: create_summary_lines_upd_evnt (-)'||x_return_status);
  END IF;

EXCEPTION
  -- Following exception added for Error Handling Fix Bug#9765007
  WHEN summary_error THEN
    -- get error count
    l_err_count := SQL%BULK_EXCEPTIONS.COUNT;

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
             'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.create_summary_lines_upd_evnt',
             TO_CHAR(l_err_count)||' Error(s) occured while creating Summary Tax Line(s).');
    END IF;

    -- Add error message to error_tbl along with the invoice_id
    l_err_trx_id := -99;
    FOR i IN 1 .. l_err_count LOOP
      l_err_idx := SQL%BULK_EXCEPTIONS(i).ERROR_INDEX;
      IF l_err_trx_id <> pg_trx_id_tbl(l_err_idx) THEN
        l_context_info_rec.application_id          := pg_application_id_tbl(l_err_idx);
        l_context_info_rec.entity_code             := pg_entity_code_tbl(l_err_idx);
        l_context_info_rec.event_class_code        := pg_event_class_code_tbl(l_err_idx);
        l_context_info_rec.trx_id                  := pg_trx_id_tbl(l_err_idx);
        l_context_info_rec.trx_line_id             := TO_NUMBER(NULL);
        l_context_info_rec.trx_level_type          := TO_CHAR(NULL);
        l_context_info_rec.summary_tax_line_number := TO_NUMBER(NULL);
        l_context_info_rec.tax_line_id             := TO_NUMBER(NULL);
        l_context_info_rec.trx_line_dist_id        := TO_NUMBER(NULL);

        FND_MESSAGE.SET_NAME('ZX','ZX_SUMMARY_CONSTRAINT_VIOLATED');
        ZX_API_PUB.Add_Msg(l_context_info_rec);

        l_err_trx_id := pg_trx_id_tbl(l_err_idx);
      END IF;
    END LOOP;

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    l_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
             'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.create_summary_lines_upd_evnt',
              l_error_buffer);
    END IF;

END create_summary_lines_upd_evnt;

------------------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  create_summary_lines_del_evnt
--
--  DESCRIPTION
--  Public procedure to recreate summary tax lines from zx_lines after detleting
--  the detail tax lines based on the passed-in transaction line information
--
--  NOTE
--  1. At present, we always regard the retain_summ_tax_line_id_flag as 'Y' due
--  to coding consideration. If later function requirement identified for not
--  retain the summary tax line id, then need to update the new summary
--  tax line id back to zx_lines.
--
--  2. This API only used for deleting trx lines event, so that are cases that
--  some summary tax lines for this trx is no need to recreate. The current
--  approach is to delete all th original summary tax lines and recreate.
--  Assumption is that before this API is called, all the summary tax lines
--  for this trx are deleted.
------------------------------------------------------------------------------
-- Bug 6456915 - associated_child_frozen_flag has been removed from grouping columns for summary tax lines

PROCEDURE create_summary_lines_del_evnt(
  p_application_id                IN          NUMBER,
  p_entity_code                   IN          VARCHAR2,
  p_event_class_code              IN          VARCHAR2,
  p_trx_id                        IN          NUMBER,
  p_trx_line_id                   IN          NUMBER,
  p_trx_level_type                IN          VARCHAR2,
  p_retain_summ_tax_line_id_flag  IN          VARCHAR2,
  x_return_status                 OUT NOCOPY  VARCHAR2
) IS

  l_error_buffer      VARCHAR2(100);
  l_row_count    NUMBER;
  l_curr_ledger_id          NUMBER;
  l_summary_tax_line_number NUMBER;

BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
      'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.create_summary_lines_del_evnt.BEGIN',
      'ZX_TRL_MANAGE_TAX_PKG: create_summary_lines_del_evnt (+)');
  END IF;

  --  Initialize API return status to success
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- At present, we always regard the retain_summ_tax_line_id_flag as 'Y' due
  -- to coding consideration. If later function requirement identified for not
  -- retain the summary tax line id, then need to update the new summary
  -- tax line id back to zx_lines.

  SELECT NVL(summary_tax_line_id,
             zx_lines_summary_s.NEXTVAL )  summary_tax_line_id,
         count_detail_tax_line,
         count_detail_cancel_flag,
         trx_number,
         applied_from_application_id,
         applied_from_event_class_code,
         applied_from_entity_code,
         applied_from_trx_id,
         applied_from_trx_level_type,
         applied_from_line_id,
         adjusted_doc_application_id,
         adjusted_doc_entity_code,
         adjusted_doc_event_class_code,
         adjusted_doc_trx_id,
         adjusted_doc_trx_level_type,
         -- ROWNUM,                -- summary_tax_line_number
         content_owner_id,
         tax_regime_code,
         tax,
         tax_status_code,
         tax_rate_id,
         tax_rate_code,
         tax_rate,
         tax_jurisdiction_code,
         ledger_id,
         legal_entity_id,
         establishment_id,
         currency_conversion_date,
         currency_conversion_type,
         currency_conversion_rate,
         taxable_basis_formula,
         tax_calculation_formula,
         tax_amt_included_flag,
         compounding_tax_flag,
         self_assessed_flag,
         reporting_only_flag,
         -- associated_child_frozen_flag,
    --     copied_from_other_doc_flag,
         record_type_code,
         tax_provider_id,
         historical_flag,
         tax_amt,
         tax_amt_tax_curr,
         tax_amt_funcl_curr,
         total_rec_tax_amt,
         total_rec_tax_amt_funcl_curr,
         total_rec_tax_amt_tax_curr,
         total_nrec_tax_amt,
         total_nrec_tax_amt_funcl_curr,
         total_nrec_tax_amt_tax_curr,
         -- cancel_flag,
         'N'  delete_flag,
      --   overridden_flag,
         manually_entered_flag,
         -- bug6773534 applied_to_application_id,
         -- bug6773534 applied_to_event_class_code,
         -- bug6773534 applied_to_entity_code,
         -- bug6773534 applied_to_trx_id,
         -- bug6773534 applied_to_trx_level_type,
         -- bug6773534 applied_to_line_id,
         tax_exemption_id,
     --    tax_rate_before_exemption,
    --     tax_rate_name_before_exemption,
    --     exempt_rate_modifier,
         exempt_certificate_number,
   --      exempt_reason,
         exempt_reason_code,
   --      tax_rate_before_exception,
   --      tax_rate_name_before_exception,
         tax_exception_id,
   --      exception_rate,
         mrc_tax_line_flag,
         tax_only_line_flag
    BULK COLLECT INTO
         pg_summary_tax_line_id_tbl,
         pg_count_detail_tax_line_tbl,
         pg_count_detail_cancel_tbl,
         pg_trx_number_tbl,
         pg_app_from_app_id_tbl,
         pg_app_from_evnt_cls_code_tbl,
         pg_app_from_entity_code_tbl,
         pg_app_from_trx_id_tbl,
         pg_app_from_trx_level_type_tbl,
         pg_app_from_line_id_tbl,
         pg_adj_doc_app_id_tbl,
         pg_adj_doc_entity_code_tbl,
         pg_adj_doc_evnt_cls_code_tbl,
         pg_adj_doc_trx_id_tbl,
         pg_adj_doc_trx_level_type_tbl,
         --pg_summary_tax_line_num_tbl,
         pg_content_owner_id_tbl,
         pg_tax_regime_code_tbl,
         pg_tax_tbl,
         pg_tax_status_code_tbl,
         pg_tax_rate_id_tbl,
         pg_tax_rate_code_tbl,
         pg_tax_rate_tbl,
         pg_tax_jurisdiction_code_tbl,
         pg_ledger_id_tbl,
         pg_legal_entity_id_tbl,
         pg_establishment_id_tbl,
         pg_currency_convrsn_date_tbl,
         pg_currency_convrsn_type_tbl,
         pg_currency_convrsn_rate_tbl,
         pg_taxable_basis_formula_tbl,
         pg_tax_calculation_formula_tbl,
         pg_tax_amt_included_flag_tbl,
         pg_compounding_tax_flag_tbl,
         pg_self_assessed_flag_tbl,
         pg_reporting_only_flag_tbl,
         -- pg_assoctd_child_frz_flag_tbl,
   --      pg_cpd_from_other_doc_flag_tbl,
         pg_record_type_code_tbl,
         pg_tax_provider_id_tbl,
         pg_historical_flag_tbl,
         pg_tax_amt_tbl,
         pg_tax_amt_tax_curr_tbl,
         pg_tax_amt_funcl_curr_tbl,
         pg_ttl_rec_tax_amt_tbl,
         pg_ttl_rec_tx_amt_fnc_crr_tbl,
         pg_ttl_rec_tx_amt_tx_crr_tbl,
         pg_ttl_nrec_tax_amt_tbl,
         pg_ttl_nrec_tx_amt_fnc_crr_tbl,
         pg_ttl_nrec_tx_amt_tx_crr_tbl,
         -- pg_cancel_flag_tbl,
         pg_delete_flag_tbl,
   --      pg_overridden_flag_tbl,
         pg_manually_entered_flag_tbl,
         -- bug6773534 pg_app_to_app_id_tbl,
         -- bug6773534 pg_app_to_evnt_cls_code_tbl,
         -- bug6773534 pg_app_to_entity_code_tbl,
         -- bug6773534 pg_app_to_trx_id_tbl,
         -- bug6773534 pg_app_to_trx_level_type_tbl,
         -- bug6773534 pg_app_to_line_id_tbl,
         pg_tax_xmptn_id_tbl,
    --     pg_tax_rate_bf_xmptn_tbl,
    --     pg_tax_rate_name_bf_xmptn_tbl,
    --     pg_xmpt_rate_modifier_tbl,
         pg_xmpt_certificate_number_tbl,
    --     pg_xmpt_reason_tbl,
         pg_xmpt_reason_code_tbl,
    --     pg_tax_rate_bf_xeptn_tbl,
    --     pg_tax_rate_name_bf_xeptn_tbl,
         pg_tax_xeptn_id_tbl,
    --     pg_xeptn_rate_tbl,
         pg_mrc_tax_line_flag_tbl,
         pg_tax_only_line_flag_tbl
      FROM ( SELECT summary_tax_line_id,
                    COUNT(*) count_detail_tax_line,
                    SUM(DECODE(cancel_flag, 'Y', 1, 0)) count_detail_cancel_flag,
                    trx_number,
                    applied_from_application_id,
                    applied_from_event_class_code,
                    applied_from_entity_code,
                    applied_from_trx_id,
                    applied_from_trx_level_type,
                    applied_from_line_id,
                    adjusted_doc_application_id,
                    adjusted_doc_entity_code,
                    adjusted_doc_event_class_code,
                    adjusted_doc_trx_id,
                    adjusted_doc_trx_level_type,
                    content_owner_id,
                    tax_regime_code,
                    tax,
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
        --            associated_child_frozen_flag,
    --                copied_from_other_doc_flag,
                    record_type_code,
                    tax_provider_id,
                    historical_flag,
                    SUM(tax_amt) tax_amt,
                    SUM(tax_amt_tax_curr) tax_amt_tax_curr,
                    SUM(tax_amt_funcl_curr) tax_amt_funcl_curr,
                    SUM(orig_tax_amt) orig_tax_amt,
                    SUM(rec_tax_amt) total_rec_tax_amt,
                    SUM(rec_tax_amt_funcl_curr) total_rec_tax_amt_funcl_curr,
                    SUM(rec_tax_amt_tax_curr) total_rec_tax_amt_tax_curr,
                    SUM(nrec_tax_amt) total_nrec_tax_amt,
                    SUM(nrec_tax_amt_funcl_curr) total_nrec_tax_amt_funcl_curr,
                    SUM(nrec_tax_amt_tax_curr) total_nrec_tax_amt_tax_curr,
                    -- cancel_flag,
     --               overridden_flag,
                    manually_entered_flag,
                    -- bug6773534 applied_to_application_id,
                    -- bug6773534 applied_to_event_class_code,
                    -- bug6773534 applied_to_entity_code,
                    -- bug6773534 applied_to_trx_id,
                    -- bug6773534 applied_to_trx_level_type,
                    -- bug6773534 applied_to_line_id,
                    tax_exemption_id,
      --              tax_rate_before_exemption,
      --              tax_rate_name_before_exemption,
      --              exempt_rate_modifier,
                    exempt_certificate_number,
      --              exempt_reason,
                    exempt_reason_code,
      --              tax_rate_before_exception,
      --              tax_rate_name_before_exception,
                    tax_exception_id,
      --              exception_rate,
                    mrc_tax_line_flag,
                    tax_only_line_flag
               FROM ZX_LINES
              WHERE application_id    = p_application_id
                AND entity_code       = p_entity_code
                AND event_class_code  = p_event_class_code
                AND trx_id            = p_trx_id
              GROUP BY  trx_id,
                        trx_number,
                        summary_tax_line_id,
                        applied_from_application_id,
                        applied_from_event_class_code,
                        applied_from_entity_code,
                        applied_from_trx_id,
                        applied_from_trx_level_type,
                        applied_from_line_id,
                        adjusted_doc_application_id,
                        adjusted_doc_entity_code,
                        adjusted_doc_event_class_code,
                        adjusted_doc_trx_id,
                        adjusted_doc_trx_level_type,
                        content_owner_id,
                        tax_regime_code,
                        tax,
                        tax_status_code,
                        tax_rate_id,
                        tax_rate_code,
                        tax_rate,
                        tax_jurisdiction_code,
                        ledger_id,
                        legal_entity_id,
                        establishment_id,
                        TRUNC(currency_conversion_date),
                        currency_conversion_type,
                        currency_conversion_rate,
                        taxable_basis_formula,
                        tax_calculation_formula,
                        tax_amt_included_flag,
                        compounding_tax_flag,
                        self_assessed_flag,
                        reporting_only_flag,
                        -- associated_child_frozen_flag,
     --                   copied_from_other_doc_flag,
                        record_type_code,
                        tax_provider_id,
                        historical_flag,
                        -- cancel_flag,
       --                 overridden_flag,
                        manually_entered_flag,
                        -- bug6773534 applied_to_application_id,
                        -- bug6773534 applied_to_event_class_code,
                        -- bug6773534 applied_to_entity_code,
                        -- bug6773534 applied_to_trx_id,
                        -- bug6773534 applied_to_trx_level_type,
                        -- bug6773534 applied_to_line_id,
                        tax_exemption_id,
        --                tax_rate_before_exemption,
        --                tax_rate_name_before_exemption,
        --                exempt_rate_modifier,
                        exempt_certificate_number,
        --                exempt_reason,
                        exempt_reason_code,
        --                tax_rate_before_exception,
        --                tax_rate_name_before_exception,
                        tax_exception_id,
        --                exception_rate,
                        mrc_tax_line_flag,
                        tax_only_line_flag
               ORDER BY trx_id,
                        trx_number,
                        mrc_tax_line_flag,
                        ledger_id,
                        summary_tax_line_id,
                        applied_from_application_id,
                        applied_from_event_class_code,
                        applied_from_entity_code,
                        applied_from_trx_id,
                        applied_from_trx_level_type,
                        applied_from_line_id,
                        adjusted_doc_application_id,
                        adjusted_doc_entity_code,
                        adjusted_doc_event_class_code,
                        adjusted_doc_trx_id,
                        adjusted_doc_trx_level_type,
                        content_owner_id,
                        tax_regime_code,
                        tax,
                        tax_status_code,
                        tax_rate_id,
                        tax_rate_code,
                        tax_rate,
                        tax_jurisdiction_code,
                        legal_entity_id,
                        establishment_id,
                     --   TRUNC(currency_conversion_date),
                     --   currency_conversion_type,
                     --   currency_conversion_rate,
                        taxable_basis_formula,
                        tax_calculation_formula,
                        tax_amt_included_flag,
                        compounding_tax_flag,
                        self_assessed_flag,
                        reporting_only_flag,
                        -- associated_child_frozen_flag,
      --                  copied_from_other_doc_flag,
                        record_type_code,
                        tax_provider_id,
                        historical_flag,
                        -- cancel_flag,
              --          overridden_flag,
                        manually_entered_flag,
                        -- bug6773534 applied_to_application_id,
                        -- bug6773534 applied_to_event_class_code,
                        -- bug6773534 applied_to_entity_code,
                        -- bug6773534 applied_to_trx_id,
                        -- bug6773534 applied_to_trx_level_type,
                        -- bug6773534 applied_to_line_id,
                        tax_exemption_id,
               --         tax_rate_before_exemption,
               --         tax_rate_name_before_exemption,
               --         exempt_rate_modifier,
                        exempt_certificate_number,
               --         exempt_reason,
                        exempt_reason_code,
               --         tax_rate_before_exception,
               --         tax_rate_name_before_exception,
                        tax_exception_id,
               --         exception_rate,
                        tax_only_line_flag );


  l_curr_ledger_id := -1;
  l_summary_tax_line_number := -1;
  FOR i IN 1.. pg_summary_tax_line_id_tbl.COUNT LOOP

    -- populate the summary_tax_line_number
    -- due to the order by clause, it guranteed that the none_mrc line will
    -- come first, then followed by the mrc tax lines.
    IF l_curr_ledger_id = -1 OR l_curr_ledger_id <> pg_ledger_id_tbl(i) THEN
      l_curr_ledger_id := pg_ledger_id_tbl(i);
      l_summary_tax_line_number := 1;
    ELSE
      l_summary_tax_line_number := l_summary_tax_line_number + 1;
    END IF;
    pg_summary_tax_line_num_tbl(i) := l_summary_tax_line_number;

    IF pg_count_detail_cancel_tbl(i) = pg_count_detail_tax_line_tbl(i) THEN
      pg_cancel_flag_tbl(i) := 'Y';
    ELSE
      pg_cancel_flag_tbl(i) := NULL;
    END IF;

  END LOOP;


  FORALL i IN 1..pg_summary_tax_line_id_tbl.COUNT
  INSERT INTO zx_lines_summary
            ( summary_tax_line_id,
              object_version_number,
              created_by,
              creation_date,
              last_updated_by,
              last_update_date,
              last_update_login,
              internal_organization_id,
              application_id,
              entity_code,
              event_class_code,
              trx_id,
              trx_number,
              applied_from_application_id,
              applied_from_event_class_code,
              applied_from_entity_code,
              applied_from_trx_id,
              applied_from_trx_level_type,
              applied_from_line_id,
              adjusted_doc_application_id,
              adjusted_doc_entity_code,
              adjusted_doc_event_class_code,
              adjusted_doc_trx_id,
              adjusted_doc_trx_level_type,
              summary_tax_line_number,
              content_owner_id,
              tax_regime_code,
              tax,
              tax_status_code,
              tax_rate_id,
              tax_rate_code,
              tax_rate,
              tax_jurisdiction_code,
              ledger_id,
              legal_entity_id,
              establishment_id,
              currency_conversion_date,
              currency_conversion_type,
              currency_conversion_rate,
              taxable_basis_formula,
              tax_calculation_formula,
              tax_amt_included_flag,
              compounding_tax_flag,
              self_assessed_flag,
              reporting_only_flag,
              -- associated_child_frozen_flag,
    --     copied_from_other_doc_flag,
              record_type_code,
              tax_provider_id,
              historical_flag,
              tax_amt,
              tax_amt_tax_curr,
              tax_amt_funcl_curr,
              total_rec_tax_amt,
              total_rec_tax_amt_funcl_curr,
              total_rec_tax_amt_tax_curr,
              total_nrec_tax_amt,
              total_nrec_tax_amt_funcl_curr,
              total_nrec_tax_amt_tax_curr,
              cancel_flag,
              delete_flag,
        --      overridden_flag,
              manually_entered_flag,
              -- bug6773534 applied_to_application_id,
              -- bug6773534 applied_to_event_class_code,
              -- bug6773534 applied_to_entity_code,
              -- bug6773534 applied_to_trx_id,
              -- bug6773534 applied_to_trx_level_type,
              -- bug6773534 applied_to_line_id,
              tax_exemption_id,
         --     tax_rate_before_exemption,
         --     tax_rate_name_before_exemption,
         --     exempt_rate_modifier,
              exempt_certificate_number,
         --     exempt_reason,
              exempt_reason_code,
         --     tax_rate_before_exception,
         --     tax_rate_name_before_exception,
              tax_exception_id,
         --     exception_rate,
              mrc_tax_line_flag,
              tax_only_line_flag
            ) VALUES(
       pg_summary_tax_line_id_tbl(i),
       1,        -- object_version_number
       FND_GLOBAL.user_id,
       SYSDATE,
       FND_GLOBAL.user_id,
       SYSDATE,
       FND_GLOBAL.user_id,
       pg_internal_org_id_tbl(i),
       pg_application_id_tbl(i),
       pg_entity_code_tbl(i),
       pg_event_class_code_tbl(i),
       pg_trx_id_tbl(i),
       pg_trx_number_tbl(i),
       pg_app_from_app_id_tbl(i),
       pg_app_from_evnt_cls_code_tbl(i),
       pg_app_from_entity_code_tbl(i),
       pg_app_from_trx_id_tbl(i),
       pg_app_from_trx_level_type_tbl(i),
       pg_app_from_line_id_tbl(i),
       pg_adj_doc_app_id_tbl(i),
       pg_adj_doc_entity_code_tbl(i),
       pg_adj_doc_evnt_cls_code_tbl(i),
       pg_adj_doc_trx_id_tbl(i),
       pg_adj_doc_trx_level_type_tbl(i),
       pg_summary_tax_line_num_tbl(i),
       pg_content_owner_id_tbl(i),
       pg_tax_regime_code_tbl(i),
       pg_tax_tbl(i),
       pg_tax_status_code_tbl(i),
       pg_tax_rate_id_tbl(i),
       pg_tax_rate_code_tbl(i),
       pg_tax_rate_tbl(i),
       pg_tax_jurisdiction_code_tbl(i),
       pg_ledger_id_tbl(i),
       pg_legal_entity_id_tbl(i),
       pg_establishment_id_tbl(i),
       pg_currency_convrsn_date_tbl(i),
       pg_currency_convrsn_type_tbl(i),
       pg_currency_convrsn_rate_tbl(i),
       pg_taxable_basis_formula_tbl(i),
       pg_tax_calculation_formula_tbl(i),
       pg_tax_amt_included_flag_tbl(i),
       pg_compounding_tax_flag_tbl(i),
       pg_self_assessed_flag_tbl(i),
       pg_reporting_only_flag_tbl(i),
       -- pg_assoctd_child_frz_flag_tbl(i),
 -- pg_cpd_from_other_doc_flag_tbl(i),
       pg_record_type_code_tbl(i),
       pg_tax_provider_id_tbl(i),
       pg_historical_flag_tbl(i),
       pg_tax_amt_tbl(i),
       pg_tax_amt_tax_curr_tbl(i),
       pg_tax_amt_funcl_curr_tbl(i),
       pg_ttl_rec_tax_amt_tbl(i),
       pg_ttl_rec_tx_amt_fnc_crr_tbl(i),
       pg_ttl_rec_tx_amt_tx_crr_tbl(i),
       pg_ttl_nrec_tax_amt_tbl(i),
       pg_ttl_nrec_tx_amt_fnc_crr_tbl(i),
       pg_ttl_nrec_tx_amt_tx_crr_tbl(i),
       pg_cancel_flag_tbl(i),
       pg_delete_flag_tbl(i),
    --   pg_overridden_flag_tbl(i),
       pg_manually_entered_flag_tbl(i),
       -- bug6773534 pg_app_to_app_id_tbl(i),
       -- bug6773534 pg_app_to_evnt_cls_code_tbl(i),
       -- bug6773534 pg_app_to_entity_code_tbl(i),
       -- bug6773534 pg_app_to_trx_id_tbl(i),
       -- bug6773534 pg_app_to_trx_level_type_tbl(i),
       -- bug6773534 pg_app_to_line_id_tbl(i),
       pg_tax_xmptn_id_tbl(i),
    --   pg_tax_rate_bf_xmptn_tbl(i),
    --   pg_tax_rate_name_bf_xmptn_tbl(i),
    --   pg_xmpt_rate_modifier_tbl(i),
       pg_xmpt_certificate_number_tbl(i),
    --   pg_xmpt_reason_tbl(i),
       pg_xmpt_reason_code_tbl(i),
    --   pg_tax_rate_bf_xeptn_tbl(i),
    --   pg_tax_rate_name_bf_xeptn_tbl(i),
       pg_tax_xeptn_id_tbl(i),
    --   pg_xeptn_rate_tbl(i),
       pg_mrc_tax_line_flag_tbl(i),
       pg_tax_only_line_flag_tbl(i) );

  IF (g_level_statement >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_statement,
      'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.create_summary_lines_del_evnt',
      'NON-MRC Lines: Number of Rows Inserted into zx_lines_summary retain summary tax line id: '||to_char(SQL%ROWCOUNT));
  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.create_summary_lines_del_evnt.END',
                   'ZX_TRL_MANAGE_TAX_PKG: create_summary_lines_del_evnt (-)'||x_return_status);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    l_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.create_summary_lines_del_evnt',
                      l_error_buffer);
    END IF;

END create_summary_lines_del_evnt;


-------------------------------------------------------------------------------
--
--   Package constructor
--
-------------------------------------------------------------------------------

END ZX_TRL_MANAGE_TAX_PKG;

/
