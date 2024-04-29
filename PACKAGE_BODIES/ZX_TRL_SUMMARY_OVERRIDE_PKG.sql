--------------------------------------------------------
--  DDL for Package Body ZX_TRL_SUMMARY_OVERRIDE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_TRL_SUMMARY_OVERRIDE_PKG" AS
/* $Header: zxriovrsumlnpkgb.pls 120.53.12010000.20 2010/08/27 06:19:59 prigovin ship $ */

  g_current_runtime_level NUMBER;
  g_level_statement       CONSTANT  NUMBER := FND_LOG.LEVEL_STATEMENT;
  g_level_procedure       CONSTANT  NUMBER := FND_LOG.LEVEL_PROCEDURE;
  g_level_event           CONSTANT  NUMBER := FND_LOG.LEVEL_EVENT;
  g_level_unexpected      CONSTANT  NUMBER := FND_LOG.LEVEL_UNEXPECTED;

  DATE_DUMMY   CONSTANT DATE           := TO_DATE('01-01-1951', 'DD-MM-YYYY');

  PROCEDURE Insert_Row
       (x_rowid                        IN OUT NOCOPY VARCHAR2,
        p_summary_tax_line_id                        NUMBER,
        p_internal_organization_id                   NUMBER,
        p_application_id                             NUMBER,
        p_entity_code                                VARCHAR2,
        p_event_class_code                           VARCHAR2,
        p_trx_id                                     NUMBER,
        p_summary_tax_line_number                    NUMBER,
        p_trx_number                                 VARCHAR2,
        p_applied_from_application_id                NUMBER,
        p_applied_from_evt_class_code                VARCHAR2,--reduced size p_applied_from_event_class_code
        p_applied_from_entity_code                   VARCHAR2,
        p_applied_from_trx_id                        NUMBER,
        p_applied_from_trx_level_type                VARCHAR2,
        p_applied_from_line_id                       NUMBER,
        p_adjusted_doc_application_id                NUMBER,
        p_adjusted_doc_entity_code                   VARCHAR2,
        p_adjusted_doc_evt_class_code                VARCHAR2,--reduced size p_adjusted_doc_event_class_code
        p_adjusted_doc_trx_id                        NUMBER,
        p_adjusted_doc_trx_level_type                VARCHAR2,
        p_applied_to_application_id                  NUMBER,
        p_applied_to_event_class_code                VARCHAR2,
        p_applied_to_entity_code                     VARCHAR2,
        p_applied_to_trx_id                          NUMBER,
        p_applied_to_trx_level_type                  VARCHAR2,
        p_applied_to_line_id                         NUMBER,
        p_tax_exemption_id                           NUMBER,
        p_tax_rate_before_exemption                  NUMBER,
        p_tax_rate_name_before_exempt                VARCHAR2, --reduced size p_tax_rate_name_before_exemption
        p_exempt_rate_modifier                       NUMBER,
        p_exempt_certificate_number                  VARCHAR2,
        p_exempt_reason                              VARCHAR2,
        p_exempt_reason_code                         VARCHAR2,
        p_tax_rate_before_exception                  NUMBER,
        p_tax_rate_name_before_except                VARCHAR2, --reduced size p_tax_rate_name_before_exception
        p_tax_exception_id                           NUMBER,
        p_exception_rate                             NUMBER,
        p_content_owner_id                           NUMBER,
        p_tax_regime_code                            VARCHAR2,
        p_tax                                        VARCHAR2,
        p_tax_status_code                            VARCHAR2,
        p_tax_rate_id                                NUMBER,
        p_tax_rate_code                              VARCHAR2,
        p_tax_rate                                   NUMBER,
        p_tax_amt                                    NUMBER,
        p_tax_amt_tax_curr                           NUMBER,
        p_tax_amt_funcl_curr                         NUMBER,
        p_tax_jurisdiction_code                      VARCHAR2,
        p_total_rec_tax_amt                          NUMBER,
        p_total_rec_tax_amt_func_curr                NUMBER,--reduced size p_total_rec_tax_amt_funcl_curr
        p_total_rec_tax_amt_tax_curr                 NUMBER,
        p_total_nrec_tax_amt                         NUMBER,
        p_total_nrec_tax_amt_func_curr               NUMBER,--reduced size p_total_nrec_tax_amt_funcl_curr
        p_total_nrec_tax_amt_tax_curr                NUMBER,
        p_ledger_id                                  NUMBER,
        p_legal_entity_id                            NUMBER,
        p_establishment_id                           NUMBER,
        p_currency_conversion_date                   DATE,
        p_currency_conversion_type                   VARCHAR2,
        p_currency_conversion_rate                   NUMBER,
        p_summarization_template_id                  NUMBER,
        p_taxable_basis_formula                      VARCHAR2,
        p_tax_calculation_formula                    VARCHAR2,
        p_historical_flag                            VARCHAR2,
        p_cancel_flag                                VARCHAR2,
        p_delete_flag                                VARCHAR2,
        p_tax_amt_included_flag                      VARCHAR2,
        p_compounding_tax_flag                       VARCHAR2,
        p_self_assessed_flag                         VARCHAR2,
        p_overridden_flag                            VARCHAR2,
        p_reporting_only_flag                        VARCHAR2,
        p_assoc_child_frozen_flag                    VARCHAR2,--reduced size p_Associated_Child_Frozen_Flag
        p_copied_from_other_doc_flag                 VARCHAR2,
        p_manually_entered_flag                      VARCHAR2,
        p_mrc_tax_line_flag                          VARCHAR2,
        p_last_manual_entry                          VARCHAR2,
        p_record_type_code                           VARCHAR2,
        p_tax_provider_id                            NUMBER,
        p_tax_only_line_flag                         VARCHAR2,
        p_adjust_tax_amt_flag                        VARCHAR2,
        p_attribute_category                         VARCHAR2,
        p_attribute1                                 VARCHAR2,
        p_attribute2                                 VARCHAR2,
        p_attribute3                                 VARCHAR2,
        p_attribute4                                 VARCHAR2,
        p_attribute5                                 VARCHAR2,
        p_attribute6                                 VARCHAR2,
        p_attribute7                                 VARCHAR2,
        p_attribute8                                 VARCHAR2,
        p_attribute9                                 VARCHAR2,
        p_attribute10                                VARCHAR2,
        p_attribute11                                VARCHAR2,
        p_attribute12                                VARCHAR2,
        p_attribute13                                VARCHAR2,
        p_attribute14                                VARCHAR2,
        p_attribute15                                VARCHAR2,
        p_global_attribute_category                  VARCHAR2,
        p_global_attribute1                          VARCHAR2,
        p_global_attribute2                          VARCHAR2,
        p_global_attribute3                          VARCHAR2,
        p_global_attribute4                          VARCHAR2,
        p_global_attribute5                          VARCHAR2,
        p_global_attribute6                          VARCHAR2,
        p_global_attribute7                          VARCHAR2,
        p_global_attribute8                          VARCHAR2,
        p_global_attribute9                          VARCHAR2,
        p_global_attribute10                         VARCHAR2,
        p_global_attribute11                         VARCHAR2,
        p_global_attribute12                         VARCHAR2,
        p_global_attribute13                         VARCHAR2,
        p_global_attribute14                         VARCHAR2,
        p_global_attribute15                         VARCHAR2,
        p_global_attribute16                         VARCHAR2,
        p_global_attribute17                         VARCHAR2,
        p_global_attribute18                         VARCHAR2,
        p_global_attribute19                         VARCHAR2,
        p_global_attribute20                         VARCHAR2,
        p_object_version_number                      NUMBER,
        p_created_by                                 NUMBER,
        p_creation_date                              DATE,
        p_last_updated_by                            NUMBER,
        p_last_update_date                           DATE,
        p_last_update_login                          NUMBER) IS

    CURSOR C IS
      SELECT rowid
      FROM ZX_LINES_SUMMARY
      WHERE SUMMARY_TAX_LINE_ID = p_summary_tax_line_id;

  BEGIN
    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_SUMMARY_OVERRIDE_PKG.Insert_Row.BEGIN',
                     'ZX_TRL_SUMMARY_OVERRIDE_PKG: Insert_Row (+)');
    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_SUMMARY_OVERRIDE_PKG.Insert_Row',
                     'Insert into zx_lines_summary (+)');
    END IF;

    INSERT INTO ZX_LINES_SUMMARY (SUMMARY_TAX_LINE_ID,
                                  INTERNAL_ORGANIZATION_ID,
                                  APPLICATION_ID,
                                  ENTITY_CODE,
                                  EVENT_CLASS_CODE,
                                  TRX_ID,
                                  TRX_NUMBER,
                                  SUMMARY_TAX_LINE_NUMBER,
                                  APPLIED_FROM_APPLICATION_ID,
                                  APPLIED_FROM_EVENT_CLASS_CODE,
                                  APPLIED_FROM_ENTITY_CODE,
                                  APPLIED_FROM_TRX_ID,
                                  APPLIED_FROM_TRX_LEVEL_TYPE,
                                  APPLIED_FROM_LINE_ID,
                                  ADJUSTED_DOC_APPLICATION_ID,
                                  ADJUSTED_DOC_ENTITY_CODE,
                                  ADJUSTED_DOC_EVENT_CLASS_CODE,
                                  ADJUSTED_DOC_TRX_ID,
                                  ADJUSTED_DOC_TRX_LEVEL_TYPE,
                                  APPLIED_TO_APPLICATION_ID,
                                  APPLIED_TO_EVENT_CLASS_CODE,
                                  APPLIED_TO_ENTITY_CODE,
                                  APPLIED_TO_TRX_ID,
                                  APPLIED_TO_TRX_LEVEL_TYPE,
                                  APPLIED_TO_LINE_ID,
                                  TAX_EXEMPTION_ID,
                                  TAX_RATE_BEFORE_EXEMPTION,
                                  TAX_RATE_NAME_BEFORE_EXEMPTION,
                                  EXEMPT_RATE_MODIFIER,
                                  EXEMPT_CERTIFICATE_NUMBER,
                                  EXEMPT_REASON,
                                  EXEMPT_REASON_CODE,
                                  TAX_RATE_BEFORE_EXCEPTION,
                                  TAX_RATE_NAME_BEFORE_EXCEPTION,
                                  TAX_EXCEPTION_ID,
                                  EXCEPTION_RATE,
                                  CONTENT_OWNER_ID,
                                  TAX_REGIME_CODE,
                                  TAX,
                                  TAX_STATUS_CODE,
                                  TAX_RATE_ID,
                                  TAX_RATE_CODE,
                                  TAX_RATE,
                                  TAX_JURISDICTION_CODE,
                                  TAX_AMT,
                                  TAX_AMT_TAX_CURR,
                                  TAX_AMT_FUNCL_CURR,
                                  TOTAL_REC_TAX_AMT,
                                  TOTAL_REC_TAX_AMT_FUNCL_CURR,
                                  TOTAL_REC_TAX_AMT_TAX_CURR,
                                  TOTAL_NREC_TAX_AMT,
                                  TOTAL_NREC_TAX_AMT_FUNCL_CURR,
                                  TOTAL_NREC_TAX_AMT_TAX_CURR,
                                  LEDGER_ID,
                                  LEGAL_ENTITY_ID,
                                  ESTABLISHMENT_ID,
                                  CURRENCY_CONVERSION_DATE,
                                  CURRENCY_CONVERSION_TYPE,
                                  CURRENCY_CONVERSION_RATE,
                                  SUMMARIZATION_TEMPLATE_ID,
                                  TAXABLE_BASIS_FORMULA,
                                  TAX_CALCULATION_FORMULA,
                                  HISTORICAL_FLAG,
                                  CANCEL_FLAG,
                                  DELETE_FLAG,
                                  RECORD_TYPE_CODE,
                                  TAX_AMT_INCLUDED_FLAG,
                                  SELF_ASSESSED_FLAG,
                                  OVERRIDDEN_FLAG,
                                  COMPOUNDING_TAX_FLAG,
                                  TAX_PROVIDER_ID,
                                  MANUALLY_ENTERED_FLAG,
                                  TAX_ONLY_LINE_FLAG,
                                  ADJUST_TAX_AMT_FLAG,
                                  MRC_TAX_LINE_FLAG,
                                  REPORTING_ONLY_FLAG,
                                  ASSOCIATED_CHILD_FROZEN_FLAG,
                                  COPIED_FROM_OTHER_DOC_FLAG,
                                  LAST_MANUAL_ENTRY,
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
                                  OBJECT_VERSION_NUMBER,
                                  CREATED_BY,
                                  CREATION_DATE,
                                  LAST_UPDATED_BY,
                                  LAST_UPDATE_DATE,
                                  LAST_UPDATE_LOGIN)
                          VALUES (p_summary_tax_line_id,
                                  p_internal_organization_id,
                                  p_application_id,
                                  p_entity_code,
                                  p_event_class_code,
                                  p_trx_id,
                                  p_trx_number,
                                  p_summary_tax_line_number,
                                  p_applied_from_application_id,
                                  p_applied_from_evt_class_code,
                                  p_applied_from_entity_code,
                                  p_applied_from_trx_id,
                                  p_applied_from_trx_level_type,
                                  p_applied_from_line_id,
                                  p_adjusted_doc_application_id,
                                  p_adjusted_doc_entity_code,
                                  p_adjusted_doc_evt_class_code,
                                  p_adjusted_doc_trx_id,
                                  p_adjusted_doc_trx_level_type,
                                  p_applied_to_application_id,
                                  p_applied_to_event_class_code,
                                  p_applied_to_entity_code,
                                  p_applied_to_trx_id,
                                  p_applied_to_trx_level_type,
                                  p_applied_to_line_id,
                                  p_tax_exemption_id,
                                  p_tax_rate_before_exemption,
                                  p_tax_rate_name_before_exempt,
                                  p_exempt_rate_modifier,
                                  p_exempt_certificate_number,
                                  p_exempt_reason,
                                  p_exempt_reason_code,
                                  p_tax_rate_before_exception,
                                  p_tax_rate_name_before_except,
                                  p_tax_exception_id,
                                  p_exception_rate,
                                  p_content_owner_id,
                                  p_tax_regime_code,
                                  p_tax,
                                  p_tax_status_code,
                                  p_tax_rate_id,
                                  p_tax_rate_code,
                                  p_tax_rate,
                                  p_tax_jurisdiction_code,
                                  p_tax_amt,
                                  p_tax_amt_tax_curr,
                                  p_tax_amt_funcl_curr,
                                  p_total_rec_tax_amt,
                                  p_total_rec_tax_amt_func_curr,
                                  p_total_rec_tax_amt_tax_curr,
                                  p_total_nrec_tax_amt,
                                  p_total_nrec_tax_amt_func_curr,
                                  p_total_nrec_tax_amt_tax_curr,
                                  p_ledger_id,
                                  p_legal_entity_id,
                                  p_establishment_id,
                                  p_currency_conversion_date,
                                  p_currency_conversion_type,
                                  p_currency_conversion_rate,
                                  p_summarization_template_id,
                                  p_taxable_basis_formula,
                                  p_tax_calculation_formula,
                                  'N',                       -- historical_flag
                                  p_cancel_flag,
                                  p_delete_flag,
                                  p_record_type_code,
                                  p_tax_amt_included_flag,
                                  p_self_assessed_flag,
                                  p_overridden_flag,
                                  p_compounding_tax_flag,
                                  --p_tax_provider_id,
                                  NULL,
                                  p_manually_entered_flag,
                                  p_tax_only_line_flag,
                                  'Y',                       --p_adjust_tax_amt_flag,
                                  'N',                       -- mrc_tax_line_flag
                                  'N',                       -- reporting_only_flag
                                  'N',                       -- associated_child_frozen_flag
                                  'N',                       -- copied_from_other_doc_flag
                                  decode(p_cancel_flag,'N',p_last_manual_entry,'TAX_AMOUNT'),	--setting last_manual_entry flag on the basis of cancel_flag.
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
                                  1,    --p_object_version_number,
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
                     'ZX.PLSQL.ZX_TRL_SUMMARY_OVERRIDE_PKG.Insert_Row',
                     'Insert into zx_lines_summary (-)');

      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_SUMMARY_OVERRIDE_PKG.Insert_Row.END',
                     'ZX_TRL_SUMMARY_OVERRIDE_PKG: Insert_Row (-)');
    END IF;

  END Insert_Row;

  PROCEDURE Lock_Row
       (x_rowid                        IN OUT NOCOPY VARCHAR2,
        p_summary_tax_line_id                        NUMBER,
        p_internal_organization_id                   NUMBER,
        p_application_id                             NUMBER,
        p_entity_code                                VARCHAR2,
        p_event_class_code                           VARCHAR2,
        p_trx_id                                     NUMBER,
        p_summary_tax_line_number                    NUMBER,
        p_trx_number                                 VARCHAR2,
        p_applied_from_application_id                NUMBER,
        p_applied_from_evt_class_code                VARCHAR2,--reduced size p_applied_from_event_class_code
        p_applied_from_entity_code                   VARCHAR2,
        p_applied_from_trx_id                        NUMBER,
        p_applied_from_trx_level_type                VARCHAR2,
        p_applied_from_line_id                       NUMBER,
        p_adjusted_doc_application_id                NUMBER,
        p_adjusted_doc_entity_code                   VARCHAR2,
        p_adjusted_doc_evt_class_code                VARCHAR2,--reduced size p_adjusted_doc_event_class_code
        p_adjusted_doc_trx_id                        NUMBER,
        p_adjusted_doc_trx_level_type                VARCHAR2,
        p_applied_to_application_id                  NUMBER,
        p_applied_to_event_class_code                VARCHAR2,
        p_applied_to_entity_code                     VARCHAR2,
        p_applied_to_trx_id                          NUMBER,
        p_applied_to_trx_level_type                  VARCHAR2,
        p_applied_to_line_id                         NUMBER,
        p_tax_exemption_id                           NUMBER,
        p_tax_rate_before_exemption                  NUMBER,
        p_tax_rate_name_before_exempt                VARCHAR2, --reduced size p_tax_rate_name_before_exemption
        p_exempt_rate_modifier                       NUMBER,
        p_exempt_certificate_number                  VARCHAR2,
        p_exempt_reason                              VARCHAR2,
        p_exempt_reason_code                         VARCHAR2,
        p_tax_rate_before_exception                  NUMBER,
        p_tax_rate_name_before_except                VARCHAR2, --reduced size p_tax_rate_name_before_exception
        p_tax_exception_id                           NUMBER,
        p_exception_rate                             NUMBER,
        p_content_owner_id                           NUMBER,
        p_tax_regime_code                            VARCHAR2,
        p_tax                                        VARCHAR2,
        p_tax_status_code                            VARCHAR2,
        p_tax_rate_id                                NUMBER,
        p_tax_rate_code                              VARCHAR2,
        p_tax_rate                                   NUMBER,
        p_tax_amt                                    NUMBER,
        p_tax_amt_tax_curr                           NUMBER,
        p_tax_amt_funcl_curr                         NUMBER,
        p_tax_jurisdiction_code                      VARCHAR2,
        p_total_rec_tax_amt                          NUMBER,
        p_total_rec_tax_amt_func_curr                NUMBER,--reduced size p_total_rec_tax_amt_funcl_curr
        p_total_rec_tax_amt_tax_curr                 NUMBER,
        p_total_nrec_tax_amt                         NUMBER,
        p_total_nrec_tax_amt_func_curr               NUMBER,--reduced size p_total_nrec_tax_amt_funcl_curr
        p_total_nrec_tax_amt_tax_curr                NUMBER,
        p_ledger_id                                  NUMBER,
        p_legal_entity_id                            NUMBER,
        p_establishment_id                           NUMBER,
        p_currency_conversion_date                   DATE,
        p_currency_conversion_type                   VARCHAR2,
        p_currency_conversion_rate                   NUMBER,
        p_summarization_template_id                  NUMBER,
        p_taxable_basis_formula                      VARCHAR2,
        p_tax_calculation_formula                    VARCHAR2,
        p_historical_flag                            VARCHAR2,
        p_cancel_flag                                VARCHAR2,
        p_delete_flag                                VARCHAR2,
        p_tax_amt_included_flag                      VARCHAR2,
        p_compounding_tax_flag                       VARCHAR2,
        p_self_assessed_flag                         VARCHAR2,
        p_overridden_flag                            VARCHAR2,
        p_reporting_only_flag                        VARCHAR2,
        p_assoc_child_frozen_flag                    VARCHAR2,--reduced size p_Associated_Child_Frozen_Flag
        p_copied_from_other_doc_flag                 VARCHAR2,
        p_manually_entered_flag                      VARCHAR2,
        p_mrc_tax_line_flag                          VARCHAR2,
        p_last_manual_entry                          VARCHAR2,
        p_record_type_code                           VARCHAR2,
        p_tax_provider_id                            NUMBER,
        p_tax_only_line_flag                         VARCHAR2,
        p_adjust_tax_amt_flag                        VARCHAR2,
        p_attribute_category                         VARCHAR2,
        p_attribute1                                 VARCHAR2,
        p_attribute2                                 VARCHAR2,
        p_attribute3                                 VARCHAR2,
        p_attribute4                                 VARCHAR2,
        p_attribute5                                 VARCHAR2,
        p_attribute6                                 VARCHAR2,
        p_attribute7                                 VARCHAR2,
        p_attribute8                                 VARCHAR2,
        p_attribute9                                 VARCHAR2,
        p_attribute10                                VARCHAR2,
        p_attribute11                                VARCHAR2,
        p_attribute12                                VARCHAR2,
        p_attribute13                                VARCHAR2,
        p_attribute14                                VARCHAR2,
        p_attribute15                                VARCHAR2,
        p_global_attribute_category                  VARCHAR2,
        p_global_attribute1                          VARCHAR2,
        p_global_attribute2                          VARCHAR2,
        p_global_attribute3                          VARCHAR2,
        p_global_attribute4                          VARCHAR2,
        p_global_attribute5                          VARCHAR2,
        p_global_attribute6                          VARCHAR2,
        p_global_attribute7                          VARCHAR2,
        p_global_attribute8                          VARCHAR2,
        p_global_attribute9                          VARCHAR2,
        p_global_attribute10                         VARCHAR2,
        p_global_attribute11                         VARCHAR2,
        p_global_attribute12                         VARCHAR2,
        p_global_attribute13                         VARCHAR2,
        p_global_attribute14                         VARCHAR2,
        p_global_attribute15                         VARCHAR2,
        p_global_attribute16                         VARCHAR2,
        p_global_attribute17                         VARCHAR2,
        p_global_attribute18                         VARCHAR2,
        p_global_attribute19                         VARCHAR2,
        p_global_attribute20                         VARCHAR2,
        p_object_version_number                      NUMBER,
        p_created_by                                 NUMBER,
        p_creation_date                              DATE,
        p_last_updated_by                            NUMBER,
        p_last_update_date                           DATE,
        p_last_update_login                          NUMBER) IS

    CURSOR summary_lines_csr IS
      SELECT SUMMARY_TAX_LINE_ID,
             INTERNAL_ORGANIZATION_ID,
             APPLICATION_ID,
             ENTITY_CODE,
             EVENT_CLASS_CODE,
             TRX_ID,
             SUMMARY_TAX_LINE_NUMBER,
             TRX_NUMBER,
             APPLIED_FROM_APPLICATION_ID,
             APPLIED_FROM_EVENT_CLASS_CODE,
             APPLIED_FROM_ENTITY_CODE,
             APPLIED_FROM_TRX_ID,
             APPLIED_FROM_TRX_LEVEL_TYPE,
             APPLIED_FROM_LINE_ID,
             ADJUSTED_DOC_APPLICATION_ID,
             ADJUSTED_DOC_ENTITY_CODE,
             ADJUSTED_DOC_EVENT_CLASS_CODE,
             ADJUSTED_DOC_TRX_ID,
             ADJUSTED_DOC_TRX_LEVEL_TYPE,
             APPLIED_TO_APPLICATION_ID,
             APPLIED_TO_EVENT_CLASS_CODE,
             APPLIED_TO_ENTITY_CODE,
             APPLIED_TO_TRX_ID,
             APPLIED_TO_TRX_LEVEL_TYPE,
             APPLIED_TO_LINE_ID,
             TAX_EXEMPTION_ID,
             TAX_RATE_BEFORE_EXEMPTION,
             TAX_RATE_NAME_BEFORE_EXEMPTION,
             EXEMPT_RATE_MODIFIER,
             EXEMPT_CERTIFICATE_NUMBER,
             EXEMPT_REASON,
             EXEMPT_REASON_CODE	,
             TAX_RATE_BEFORE_EXCEPTION,
             TAX_RATE_NAME_BEFORE_EXCEPTION,
             TAX_EXCEPTION_ID,
             EXCEPTION_RATE,
             CONTENT_OWNER_ID,
             TAX_REGIME_CODE,
             TAX,
             TAX_STATUS_CODE,
             TAX_RATE_ID,
             TAX_RATE_CODE,
             TAX_RATE,
             TAX_AMT,
             TAX_AMT_TAX_CURR,
             TAX_AMT_FUNCL_CURR,
             TAX_JURISDICTION_CODE,
             TOTAL_REC_TAX_AMT,
             TOTAL_REC_TAX_AMT_FUNCL_CURR,
             TOTAL_REC_TAX_AMT_TAX_CURR,
             TOTAL_NREC_TAX_AMT,
             TOTAL_NREC_TAX_AMT_FUNCL_CURR,
             TOTAL_NREC_TAX_AMT_TAX_CURR,
             LEDGER_ID,
             LEGAL_ENTITY_ID,
             ESTABLISHMENT_ID,
             CURRENCY_CONVERSION_DATE,
             CURRENCY_CONVERSION_TYPE,
             CURRENCY_CONVERSION_RATE,
             SUMMARIZATION_TEMPLATE_ID,
             TAXABLE_BASIS_FORMULA,
             TAX_CALCULATION_FORMULA,
             HISTORICAL_FLAG,
             CANCEL_FLAG,
             DELETE_FLAG,
             TAX_AMT_INCLUDED_FLAG,
             COMPOUNDING_TAX_FLAG,
             SELF_ASSESSED_FLAG,
             OVERRIDDEN_FLAG,
             REPORTING_ONLY_FLAG,
             ASSOCIATED_CHILD_FROZEN_FLAG,
             COPIED_FROM_OTHER_DOC_FLAG,
             MANUALLY_ENTERED_FLAG,
             MRC_TAX_LINE_FLAG,
             LAST_MANUAL_ENTRY,
             RECORD_TYPE_CODE,
             TAX_PROVIDER_ID,
             TAX_ONLY_LINE_FLAG,
             ADJUST_TAX_AMT_FLAG,
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
             OBJECT_VERSION_NUMBER,
             CREATED_BY,
             CREATION_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATE_LOGIN
      FROM ZX_LINES_SUMMARY
      WHERE ROWID = X_Rowid;

    Recinfo summary_lines_csr%ROWTYPE;
		l_transaction_rec ZX_API_PUB.transaction_rec_type;
		l_return_status VARCHAR2(1000);
  BEGIN
    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_SUMMARY_OVERRIDE_PKG.Lock_Row.BEGIN',
                     'ZX_TRL_SUMMARY_OVERRIDE_PKG: Lock_Row (+)');
    END IF;

    OPEN summary_lines_csr;
    FETCH summary_lines_csr INTO Recinfo;

    IF (summary_lines_csr%NOTFOUND) THEN
      CLOSE summary_lines_csr;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    END IF;

    CLOSE summary_lines_csr;

    IF ((Recinfo.SUMMARY_TAX_LINE_ID      = p_summary_tax_line_id) AND
        (Recinfo.INTERNAL_ORGANIZATION_ID = p_internal_organization_id) AND
        (Recinfo.APPLICATION_ID           = p_application_id) AND
        (Recinfo.ENTITY_CODE 	          = p_entity_code) AND
        (Recinfo.EVENT_CLASS_CODE         = p_event_class_code) AND
        (Recinfo.TRX_ID                   = p_trx_id) AND
        (Recinfo.SUMMARY_TAX_LINE_NUMBER = p_summary_tax_line_number) AND
        ((Recinfo.TRX_NUMBER = p_TRX_NUMBER) OR
         ((Recinfo.TRX_NUMBER IS NULL) AND
          (p_TRX_NUMBER IS NULL))) AND
        ((Recinfo.APPLIED_FROM_APPLICATION_ID = p_APPLIED_FROM_APPLICATION_ID) OR
         ((Recinfo.APPLIED_FROM_APPLICATION_ID IS NULL) AND
          (p_APPLIED_FROM_APPLICATION_ID IS NULL))) AND
        ((Recinfo.APPLIED_FROM_EVENT_CLASS_CODE = p_APPLIED_FROM_EVT_CLASS_CODE) OR
         ((Recinfo.APPLIED_FROM_EVENT_CLASS_CODE IS NULL) AND
          (p_APPLIED_FROM_EVT_CLASS_CODE IS NULL))) AND
        ((Recinfo.APPLIED_FROM_ENTITY_CODE = p_APPLIED_FROM_ENTITY_CODE) OR
         ((Recinfo.APPLIED_FROM_ENTITY_CODE IS NULL) AND
          (p_APPLIED_FROM_ENTITY_CODE IS NULL))) AND
        ((Recinfo.APPLIED_FROM_TRX_ID = p_APPLIED_FROM_TRX_ID) OR
         ((Recinfo.APPLIED_FROM_TRX_ID IS NULL) AND
          (p_APPLIED_FROM_TRX_ID IS NULL))) AND
        ((Recinfo.APPLIED_FROM_TRX_LEVEL_TYPE = p_applied_from_trx_level_type) OR
         ((Recinfo.APPLIED_FROM_TRX_LEVEL_TYPE IS NULL) AND
          (p_applied_from_trx_level_type IS NULL))) AND
        ((Recinfo.APPLIED_FROM_LINE_ID = p_APPLIED_FROM_LINE_ID) OR
         ((Recinfo.APPLIED_FROM_LINE_ID IS NULL) AND
          (p_APPLIED_FROM_LINE_ID IS NULL))) AND
        ((Recinfo.ADJUSTED_DOC_APPLICATION_ID = p_ADJUSTED_DOC_APPLICATION_ID) OR
         ((Recinfo.ADJUSTED_DOC_APPLICATION_ID IS NULL) AND
          (p_ADJUSTED_DOC_APPLICATION_ID IS NULL))) AND
        ((Recinfo.ADJUSTED_DOC_ENTITY_CODE = p_ADJUSTED_DOC_ENTITY_CODE) OR
         ((Recinfo.ADJUSTED_DOC_ENTITY_CODE IS NULL) AND
          (p_ADJUSTED_DOC_ENTITY_CODE IS NULL))) AND
        ((Recinfo.ADJUSTED_DOC_EVENT_CLASS_CODE = p_ADJUSTED_DOC_EVT_CLASS_CODE) OR
         ((Recinfo.ADJUSTED_DOC_EVENT_CLASS_CODE IS NULL) AND
          (p_ADJUSTED_DOC_EVT_CLASS_CODE IS NULL))) AND
        ((Recinfo.ADJUSTED_DOC_TRX_ID = p_ADJUSTED_DOC_TRX_ID) OR
         ((Recinfo.ADJUSTED_DOC_TRX_ID IS NULL) AND
          (p_ADJUSTED_DOC_TRX_ID IS NULL))) AND
        ((Recinfo.ADJUSTED_DOC_TRX_LEVEL_TYPE = p_adjusted_doc_trx_level_type) OR
         ((Recinfo.ADJUSTED_DOC_TRX_LEVEL_TYPE IS NULL) AND
          (p_adjusted_doc_trx_level_type IS NULL))) AND
        ((Recinfo.APPLIED_TO_APPLICATION_ID = p_APPLIED_TO_APPLICATION_ID) OR
         ((Recinfo.APPLIED_TO_APPLICATION_ID IS NULL) AND
          (p_APPLIED_TO_APPLICATION_ID IS NULL))) AND
        ((Recinfo.APPLIED_TO_EVENT_CLASS_CODE = p_APPLIED_TO_EVENT_CLASS_CODE) OR
         ((Recinfo.APPLIED_TO_EVENT_CLASS_CODE IS NULL) AND
          (p_APPLIED_TO_EVENT_CLASS_CODE IS NULL))) AND
        ((Recinfo.APPLIED_TO_ENTITY_CODE = p_APPLIED_TO_ENTITY_CODE) OR
         ((Recinfo.APPLIED_TO_ENTITY_CODE IS NULL) AND
          (p_APPLIED_TO_ENTITY_CODE IS NULL))) AND
        ((Recinfo.APPLIED_TO_TRX_ID = p_APPLIED_TO_TRX_ID) OR
         ((Recinfo.APPLIED_TO_TRX_ID IS NULL) AND
          (p_APPLIED_TO_TRX_ID IS NULL))) AND
        ((Recinfo.APPLIED_TO_TRX_LEVEL_TYPE = p_APPLIED_TO_TRX_LEVEL_TYPE) OR
         ((Recinfo.APPLIED_TO_TRX_LEVEL_TYPE IS NULL) AND
          (p_APPLIED_TO_TRX_LEVEL_TYPE IS NULL))) AND
        ((Recinfo.APPLIED_TO_LINE_ID = p_APPLIED_TO_LINE_ID) OR
         ((Recinfo.APPLIED_TO_LINE_ID IS NULL) AND
          (p_APPLIED_TO_LINE_ID IS NULL))) AND
        ((Recinfo.TAX_EXEMPTION_ID = p_TAX_EXEMPTION_ID) OR
         ((Recinfo.TAX_EXEMPTION_ID IS NULL) AND
          (p_TAX_EXEMPTION_ID IS NULL))) AND
        ((Recinfo.TAX_RATE_BEFORE_EXEMPTION = p_TAX_RATE_BEFORE_EXEMPTION) OR
         ((Recinfo.TAX_RATE_BEFORE_EXEMPTION IS NULL) AND
          (p_TAX_RATE_BEFORE_EXEMPTION IS NULL))) AND
        ((Recinfo.TAX_RATE_NAME_BEFORE_EXEMPTION = p_tax_rate_name_before_exempt) OR
         ((Recinfo.TAX_RATE_NAME_BEFORE_EXEMPTION IS NULL) AND
          (p_tax_rate_name_before_exempt IS NULL))) AND
        ((Recinfo.EXEMPT_RATE_MODIFIER = p_EXEMPT_RATE_MODIFIER) OR
         ((Recinfo.EXEMPT_RATE_MODIFIER IS NULL) AND
          (p_EXEMPT_RATE_MODIFIER IS NULL))) AND
        ((Recinfo.EXEMPT_CERTIFICATE_NUMBER = p_EXEMPT_CERTIFICATE_NUMBER) OR
         ((Recinfo.EXEMPT_CERTIFICATE_NUMBER IS NULL) AND
          (p_EXEMPT_CERTIFICATE_NUMBER IS NULL))) AND
        ((Recinfo.EXEMPT_REASON = p_EXEMPT_REASON) OR
         ((Recinfo.EXEMPT_REASON IS NULL) AND
          (p_EXEMPT_REASON IS NULL))) AND
        ((Recinfo.EXEMPT_REASON_CODE = p_EXEMPT_REASON_CODE) OR
         ((Recinfo.EXEMPT_REASON_CODE IS NULL) AND
          (p_EXEMPT_REASON_CODE IS NULL))) AND
        ((Recinfo.TAX_RATE_BEFORE_EXCEPTION = p_TAX_RATE_BEFORE_EXCEPTION) OR
         ((Recinfo.TAX_RATE_BEFORE_EXCEPTION IS NULL) AND
          (p_TAX_RATE_BEFORE_EXCEPTION IS NULL))) AND
        ((Recinfo.TAX_RATE_NAME_BEFORE_EXCEPTION = p_tax_rate_name_before_except) OR
         ((Recinfo.TAX_RATE_NAME_BEFORE_EXCEPTION IS NULL) AND
          (p_tax_rate_name_before_except IS NULL))) AND
        ((Recinfo.TAX_EXCEPTION_ID = p_TAX_EXCEPTION_ID) OR
         ((Recinfo.TAX_EXCEPTION_ID IS NULL) AND
          (p_TAX_EXCEPTION_ID IS NULL))) AND
        ((Recinfo.EXCEPTION_RATE = p_EXCEPTION_RATE) OR
         ((Recinfo.EXCEPTION_RATE IS NULL) AND
          (p_EXCEPTION_RATE IS NULL))) AND
        ((Recinfo.CONTENT_OWNER_ID = p_CONTENT_OWNER_ID) OR
         ((Recinfo.CONTENT_OWNER_ID IS NULL) AND
          (p_CONTENT_OWNER_ID IS NULL))) AND
        ((Recinfo.TAX_REGIME_CODE = p_tax_regime_code) OR
         ((Recinfo.TAX_REGIME_CODE IS NULL) AND
          (p_tax_regime_code IS NULL))) AND
        ((Recinfo.TAX = p_tax ) OR
         ((Recinfo.TAX IS NULL) AND
          (p_tax  IS NULL))) AND
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
        ((Recinfo.TAX_AMT = p_tax_amt) OR
         ((Recinfo.TAX_AMT IS NULL) AND
          (p_tax_amt IS NULL))) AND
        ((Recinfo.TAX_AMT_TAX_CURR = p_TAX_AMT_TAX_CURR) OR
         ((Recinfo.TAX_AMT_TAX_CURR IS NULL) AND
          (p_TAX_AMT_TAX_CURR IS NULL))) AND
        ((Recinfo.TAX_AMT_FUNCL_CURR = p_TAX_AMT_FUNCL_CURR) OR
         ((Recinfo.TAX_AMT_FUNCL_CURR IS NULL) AND
          (p_TAX_AMT_FUNCL_CURR IS NULL))) AND
        ((Recinfo.TAX_JURISDICTION_CODE = p_tax_jurisdiction_code) OR
         ((Recinfo.TAX_JURISDICTION_CODE IS NULL) AND
          (p_tax_jurisdiction_code IS NULL))) AND
        ((Recinfo.TOTAL_REC_TAX_AMT = p_total_rec_tax_amt) OR
         ((Recinfo.TOTAL_REC_TAX_AMT IS NULL) AND
          (p_total_rec_tax_amt IS NULL))) AND
        ((Recinfo.TOTAL_REC_TAX_AMT_FUNCL_CURR = p_TOTAL_REC_TAX_AMT_FUNC_CURR) OR
         ((Recinfo.TOTAL_REC_TAX_AMT_FUNCL_CURR IS NULL) AND
          (p_TOTAL_REC_TAX_AMT_FUNC_CURR IS NULL))) AND
        ((Recinfo.TOTAL_REC_TAX_AMT_TAX_CURR = p_TOTAL_REC_TAX_AMT_TAX_CURR) OR
         ((Recinfo.TOTAL_REC_TAX_AMT_TAX_CURR IS NULL) AND
          (p_TOTAL_REC_TAX_AMT_TAX_CURR IS NULL))) AND
        ((Recinfo.TOTAL_NREC_TAX_AMT = p_total_nrec_tax_amt) OR
         ((Recinfo.TOTAL_NREC_TAX_AMT IS NULL) AND
          (p_total_nrec_tax_amt IS NULL))) AND
        ((Recinfo.TOTAL_NREC_TAX_AMT_FUNCL_CURR = p_TOTAL_NREC_TAX_AMT_FUNC_CURR) OR
         ((Recinfo.TOTAL_NREC_TAX_AMT_FUNCL_CURR IS NULL) AND
          (p_TOTAL_NREC_TAX_AMT_FUNC_CURR IS NULL))) AND
        ((Recinfo.TOTAL_NREC_TAX_AMT_TAX_CURR = p_TOTAL_NREC_TAX_AMT_TAX_CURR) OR
         ((Recinfo.TOTAL_NREC_TAX_AMT_TAX_CURR IS NULL) AND
          (p_TOTAL_NREC_TAX_AMT_TAX_CURR IS NULL))) AND
        ((Recinfo.LEDGER_ID = p_LEDGER_ID) OR
         ((Recinfo.LEDGER_ID IS NULL) AND
          (p_LEDGER_ID IS NULL))) AND
        ((Recinfo.LEGAL_ENTITY_ID = p_LEGAL_ENTITY_ID) OR
         ((Recinfo.LEGAL_ENTITY_ID IS NULL) AND
          (p_LEGAL_ENTITY_ID IS NULL))) AND
        ((Recinfo.ESTABLISHMENT_ID = p_ESTABLISHMENT_ID) OR
         ((Recinfo.ESTABLISHMENT_ID IS NULL) AND
          (p_ESTABLISHMENT_ID IS NULL))) AND
        ((Recinfo.CURRENCY_CONVERSION_DATE = p_CURRENCY_CONVERSION_DATE) OR
         ((Recinfo.CURRENCY_CONVERSION_DATE IS NULL) AND
          (p_CURRENCY_CONVERSION_DATE IS NULL))) AND
        ((Recinfo.CURRENCY_CONVERSION_TYPE = p_CURRENCY_CONVERSION_TYPE) OR
         ((Recinfo.CURRENCY_CONVERSION_TYPE IS NULL) AND
          (p_CURRENCY_CONVERSION_TYPE IS NULL))) AND
        ((Recinfo.CURRENCY_CONVERSION_RATE = p_CURRENCY_CONVERSION_RATE) OR
         ((Recinfo.CURRENCY_CONVERSION_RATE IS NULL) AND
          (p_CURRENCY_CONVERSION_RATE IS NULL))) AND
        ((Recinfo.SUMMARIZATION_TEMPLATE_ID = p_SUMMARIZATION_TEMPLATE_ID) OR
         ((Recinfo.SUMMARIZATION_TEMPLATE_ID IS NULL) AND
          (p_SUMMARIZATION_TEMPLATE_ID IS NULL))) AND
        ((Recinfo.TAXABLE_BASIS_FORMULA = p_TAXABLE_BASIS_FORMULA) OR
         ((Recinfo.TAXABLE_BASIS_FORMULA IS NULL) AND
          (p_TAXABLE_BASIS_FORMULA IS NULL))) AND
        ((Recinfo.TAX_CALCULATION_FORMULA = p_TAX_CALCULATION_FORMULA) OR
         ((Recinfo.TAX_CALCULATION_FORMULA IS NULL) AND
          (p_TAX_CALCULATION_FORMULA IS NULL))) AND
        (Recinfo.HISTORICAL_FLAG = NVL(p_Historical_Flag, 'N')) AND
        (Recinfo.CANCEL_FLAG = NVL(p_Cancel_Flag, 'N')) AND
        (Recinfo.DELETE_FLAG = NVL(p_Delete_Flag, 'N')) AND
        (Recinfo.TAX_AMT_INCLUDED_FLAG = NVL(p_Tax_Amt_Included_Flag, 'N')) AND
        (Recinfo.COMPOUNDING_TAX_FLAG = NVL(p_Compounding_Tax_Flag, 'N')) AND
        (Recinfo.SELF_ASSESSED_FLAG = NVL(p_Self_Assessed_Flag, 'N')) AND
        (Recinfo.OVERRIDDEN_FLAG = NVL(p_Overridden_Flag, 'N')) AND
        (Recinfo.REPORTING_ONLY_FLAG = NVL(p_Reporting_Only_Flag, 'N')) AND
        (Recinfo.ASSOCIATED_CHILD_FROZEN_FLAG = NVL(p_assoc_child_frozen_flag, 'N')) AND
        (Recinfo.COPIED_FROM_OTHER_DOC_FLAG = NVL(p_Copied_From_Other_Doc_Flag, 'N')) AND
        (Recinfo.MANUALLY_ENTERED_FLAG = NVL(p_Manually_Entered_Flag, 'N')) AND
        ((Recinfo.MRC_TAX_LINE_FLAG = p_MRC_TAX_LINE_FLAG) OR
         ((Recinfo.MRC_TAX_LINE_FLAG IS NULL) AND
          (p_MRC_TAX_LINE_FLAG IS NULL))) AND
        ((Recinfo.LAST_MANUAL_ENTRY = p_last_manual_entry) OR
         ((Recinfo.LAST_MANUAL_ENTRY IS NULL) AND
          (p_last_manual_entry IS NULL))) AND
        ((Recinfo.Record_Type_Code = p_Record_Type_Code) OR
         ((Recinfo.Record_Type_Code IS NULL) AND
          (p_Record_Type_Code IS NULL))) AND
        ((Recinfo.TAX_PROVIDER_ID = p_tax_provider_id) OR
         ((Recinfo.TAX_PROVIDER_ID IS NULL) AND
          (p_tax_provider_id IS NULL))) AND
        (NVL(Recinfo.Tax_Only_Line_Flag, 'N') = NVL(p_Tax_Only_Line_Flag, 'N')) AND
        (NVL(Recinfo.adjust_tax_amt_flag, 'N') = NVL(p_adjust_tax_amt_flag, 'N')) AND
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
        ((Recinfo.GLOBAL_ATTRIBUTE_CATEGORY = p_global_attribute_category) OR
         ((Recinfo.GLOBAL_ATTRIBUTE_CATEGORY IS NULL) AND
          (p_global_attribute_category IS NULL))) AND
        ((Recinfo.GLOBAL_ATTRIBUTE1 = p_global_attribute1) OR
         ((Recinfo.GLOBAL_ATTRIBUTE1 IS NULL) AND
          (p_global_attribute1 IS NULL))) AND
        ((Recinfo.GLOBAL_ATTRIBUTE2 = p_global_attribute2) OR
         ((Recinfo.GLOBAL_ATTRIBUTE2 IS NULL) AND
          (p_global_attribute2 IS NULL))) AND
        ((Recinfo.GLOBAL_ATTRIBUTE3 = p_global_attribute3) OR
         ((Recinfo.GLOBAL_ATTRIBUTE3 IS NULL) AND
          (p_global_attribute3 IS NULL))) AND
        ((Recinfo.GLOBAL_ATTRIBUTE4 = p_global_attribute4) OR
         ((Recinfo.GLOBAL_ATTRIBUTE4 IS NULL) AND
          (p_global_attribute4 IS NULL))) AND
        ((Recinfo.GLOBAL_ATTRIBUTE5 = p_global_attribute5) OR
         ((Recinfo.GLOBAL_ATTRIBUTE5 IS NULL) AND
          (p_global_attribute5 IS NULL))) AND
        ((Recinfo.GLOBAL_ATTRIBUTE6 = p_global_attribute6) OR
         ((Recinfo.GLOBAL_ATTRIBUTE6 IS NULL) AND
          (p_global_attribute6 IS NULL))) AND
        ((Recinfo.GLOBAL_ATTRIBUTE7 = p_global_attribute7) OR
         ((Recinfo.GLOBAL_ATTRIBUTE7 IS NULL) AND
          (p_global_attribute7 IS NULL))) AND
        ((Recinfo.GLOBAL_ATTRIBUTE8 = p_global_attribute8) OR
         ((Recinfo.GLOBAL_ATTRIBUTE8 IS NULL) AND
          (p_global_attribute8 IS NULL))) AND
        ((Recinfo.GLOBAL_ATTRIBUTE9 = p_global_attribute9) OR
         ((Recinfo.GLOBAL_ATTRIBUTE9 IS NULL) AND
          (p_global_attribute9 IS NULL))) AND
        ((Recinfo.GLOBAL_ATTRIBUTE10 = p_global_attribute10) OR
         ((Recinfo.GLOBAL_ATTRIBUTE10 IS NULL) AND
          (p_global_attribute10 IS NULL))) AND
        ((Recinfo.GLOBAL_ATTRIBUTE11 = p_global_attribute11) OR
         ((Recinfo.GLOBAL_ATTRIBUTE11 IS NULL) AND
          (p_global_attribute11 IS NULL))) AND
        ((Recinfo.GLOBAL_ATTRIBUTE12 = p_global_attribute12) OR
         ((Recinfo.GLOBAL_ATTRIBUTE12 IS NULL) AND
          (p_global_attribute12 IS NULL))) AND
        ((Recinfo.GLOBAL_ATTRIBUTE13 = p_global_attribute13) OR
         ((Recinfo.GLOBAL_ATTRIBUTE13 IS NULL) AND
          (p_global_attribute13 IS NULL))) AND
        ((Recinfo.GLOBAL_ATTRIBUTE14 = p_global_attribute14) OR
         ((Recinfo.GLOBAL_ATTRIBUTE14 IS NULL) AND
          (p_global_attribute14 IS NULL))) AND
        ((Recinfo.GLOBAL_ATTRIBUTE15 = p_global_attribute15) OR
         ((Recinfo.GLOBAL_ATTRIBUTE15 IS NULL) AND
          (p_global_attribute15 IS NULL))) AND
        ((Recinfo.GLOBAL_ATTRIBUTE16 = p_global_attribute16) OR
         ((Recinfo.GLOBAL_ATTRIBUTE16 IS NULL) AND
          (p_global_attribute16 IS NULL))) AND
        ((Recinfo.GLOBAL_ATTRIBUTE17 = p_global_attribute17) OR
         ((Recinfo.GLOBAL_ATTRIBUTE17 IS NULL) AND
          (p_global_attribute17 IS NULL))) AND
        ((Recinfo.GLOBAL_ATTRIBUTE18 = p_global_attribute18) OR
         ((Recinfo.GLOBAL_ATTRIBUTE18 IS NULL) AND
          (p_global_attribute18 IS NULL))) AND
        ((Recinfo.GLOBAL_ATTRIBUTE19 = p_global_attribute19) OR
         ((Recinfo.GLOBAL_ATTRIBUTE19 IS NULL) AND
          (p_global_attribute19 IS NULL))) AND
        ((Recinfo.GLOBAL_ATTRIBUTE20 = p_global_attribute20) OR
         ((Recinfo.GLOBAL_ATTRIBUTE20 IS NULL) AND
          (p_global_attribute20 IS NULL))) AND
        (Recinfo.OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER) AND
        (Recinfo.CREATED_BY = p_CREATED_BY) AND
        (Recinfo.CREATION_DATE = p_CREATION_DATE) AND
        (Recinfo.LAST_UPDATED_BY = p_LAST_UPDATED_BY) AND
        (Recinfo.LAST_UPDATE_DATE = p_LAST_UPDATE_DATE) AND
        ((Recinfo.LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN) OR
         ((Recinfo.LAST_UPDATE_LOGIN IS NULL) AND
          (p_LAST_UPDATE_LOGIN IS NULL))) ) THEN
			l_transaction_rec.APPLICATION_ID    :=  Recinfo.APPLICATION_ID;
			l_transaction_rec.ENTITY_CODE       :=  Recinfo.ENTITY_CODE;
			l_transaction_rec.EVENT_CLASS_CODE  :=  Recinfo.EVENT_CLASS_CODE;
			l_transaction_rec.TRX_ID            :=  Recinfo.TRX_ID;
			l_transaction_rec.INTERNAL_ORGANIZATION_ID  := Recinfo.INTERNAL_ORGANIZATION_ID;

			ZX_LINES_DET_FACTORS_PKG.lock_line_det_factors (
		  					l_transaction_rec,
							  l_return_status );

      RETURN;
    ELSE
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_SUMMARY_OVERRIDE_PKG.Lock_Row.END',
                     'ZX_TRL_SUMMARY_OVERRIDE_PKG: Lock_Row (-)');
    END IF;

  END Lock_Row;

  PROCEDURE oa_lock_row
    ( p_application_id NUMBER,
      p_entity_code    VARCHAR2,
      p_event_class_code VARCHAR2,
      p_trx_id NUMBER,
      p_internal_organization_id NUMBER)  IS
		l_transaction_rec ZX_API_PUB.transaction_rec_type;
                l_return_status VARCHAR2(100);
   BEGIN

			l_transaction_rec.APPLICATION_ID    :=  p_APPLICATION_ID;
			l_transaction_rec.ENTITY_CODE       :=  p_ENTITY_CODE;
			l_transaction_rec.EVENT_CLASS_CODE  :=  p_EVENT_CLASS_CODE;
			l_transaction_rec.TRX_ID            :=  p_TRX_ID;
			l_transaction_rec.INTERNAL_ORGANIZATION_ID  := p_INTERNAL_ORGANIZATION_ID;

			ZX_LINES_DET_FACTORS_PKG.lock_line_det_factors (
		  					l_transaction_rec,
							  l_return_status );

   END;


  PROCEDURE Update_Row
       (--x_rowid                        IN OUT NOCOPY VARCHAR2,
        p_summary_tax_line_id                        NUMBER,
        p_internal_organization_id                   NUMBER,
        p_application_id                             NUMBER,
        p_entity_code                                VARCHAR2,
        p_event_class_code                           VARCHAR2,
        p_trx_id                                     NUMBER,
        p_summary_tax_line_number                    NUMBER,
        p_trx_number                                 VARCHAR2,
        p_applied_from_application_id                NUMBER,
        p_applied_from_evt_class_code                VARCHAR2,--reduced size p_applied_from_event_class_code
        p_applied_from_entity_code                   VARCHAR2,
        p_applied_from_trx_id                        NUMBER,
        p_applied_from_trx_level_type                VARCHAR2,
        p_applied_from_line_id                       NUMBER,
        p_adjusted_doc_application_id                NUMBER,
        p_adjusted_doc_entity_code                   VARCHAR2,
        p_adjusted_doc_evt_class_code                VARCHAR2,--reduced size p_adjusted_doc_event_class_code
        p_adjusted_doc_trx_id                        NUMBER,
        p_adjusted_doc_trx_level_type                VARCHAR2,
        p_applied_to_application_id                  NUMBER,
        p_applied_to_event_class_code                VARCHAR2,
        p_applied_to_entity_code                     VARCHAR2,
        p_applied_to_trx_id                          NUMBER,
        p_applied_to_trx_level_type                  VARCHAR2,
        p_applied_to_line_id                         NUMBER,
        p_tax_exemption_id                           NUMBER,
        p_tax_rate_before_exemption                  NUMBER,
        p_tax_rate_name_before_exempt                VARCHAR2, --reduced size p_tax_rate_name_before_exemption
        p_exempt_rate_modifier                       NUMBER,
        p_exempt_certificate_number                  VARCHAR2,
        p_exempt_reason                              VARCHAR2,
        p_exempt_reason_code                         VARCHAR2,
        p_tax_rate_before_exception                  NUMBER,
        p_tax_rate_name_before_except                VARCHAR2, --reduced size p_tax_rate_name_before_exception
        p_tax_exception_id                           NUMBER,
        p_exception_rate                             NUMBER,
        p_content_owner_id                           NUMBER,
        p_tax_regime_code                            VARCHAR2,
        p_tax                                        VARCHAR2,
        p_tax_status_id                                  NUMBER,
        p_tax_status_code                            VARCHAR2,
        p_tax_rate_id                                NUMBER,
        p_tax_rate_code                              VARCHAR2,
        p_tax_rate                                   NUMBER,
        p_tax_amt                                    NUMBER,
        p_tax_amt_tax_curr                           NUMBER,
        p_tax_amt_funcl_curr                         NUMBER,
        p_tax_jurisdiction_code                      VARCHAR2,
        p_total_rec_tax_amt                          NUMBER,
        p_total_rec_tax_amt_func_curr                NUMBER,--reduced size p_total_rec_tax_amt_funcl_curr
        p_total_rec_tax_amt_tax_curr                 NUMBER,
        p_total_nrec_tax_amt                         NUMBER,
        p_total_nrec_tax_amt_func_curr               NUMBER,--reduced size p_total_nrec_tax_amt_funcl_curr
        p_total_nrec_tax_amt_tax_curr                NUMBER,
        p_ledger_id                                  NUMBER,
        p_legal_entity_id                            NUMBER,
        p_establishment_id                           NUMBER,
        p_currency_conversion_date                   DATE,
        p_currency_conversion_type                   VARCHAR2,
        p_currency_conversion_rate                   NUMBER,
        p_summarization_template_id                  NUMBER,
        p_taxable_basis_formula                      VARCHAR2,
        p_tax_calculation_formula                    VARCHAR2,
        p_historical_flag                            VARCHAR2,
        p_cancel_flag                                VARCHAR2,
        p_delete_flag                                VARCHAR2,
        p_tax_amt_included_flag                      VARCHAR2,
        p_compounding_tax_flag                       VARCHAR2,
        p_self_assessed_flag                         VARCHAR2,
        p_overridden_flag                            VARCHAR2,
        p_reporting_only_flag                        VARCHAR2,
        p_assoc_child_frozen_flag                    VARCHAR2,--reduced size p_Associated_Child_Frozen_Flag
        p_copied_from_other_doc_flag                 VARCHAR2,
        p_manually_entered_flag                      VARCHAR2,
        p_mrc_tax_line_flag                          VARCHAR2,
        p_last_manual_entry                          VARCHAR2,
        p_record_type_code                           VARCHAR2,
        p_tax_provider_id                            NUMBER,
        p_tax_only_line_flag                         VARCHAR2,
        p_adjust_tax_amt_flag                        VARCHAR2,
        --p_ctrl_ef_ov_cal_line_flag                   VARCHAR2,
        p_attribute_category                         VARCHAR2,
        p_attribute1                                 VARCHAR2,
        p_attribute2                                 VARCHAR2,
        p_attribute3                                 VARCHAR2,
        p_attribute4                                 VARCHAR2,
        p_attribute5                                 VARCHAR2,
        p_attribute6                                 VARCHAR2,
        p_attribute7                                 VARCHAR2,
        p_attribute8                                 VARCHAR2,
        p_attribute9                                 VARCHAR2,
        p_attribute10                                VARCHAR2,
        p_attribute11                                VARCHAR2,
        p_attribute12                                VARCHAR2,
        p_attribute13                                VARCHAR2,
        p_attribute14                                VARCHAR2,
        p_attribute15                                VARCHAR2,
        p_global_attribute_category                  VARCHAR2,
        p_global_attribute1                          VARCHAR2,
        p_global_attribute2                          VARCHAR2,
        p_global_attribute3                          VARCHAR2,
        p_global_attribute4                          VARCHAR2,
        p_global_attribute5                          VARCHAR2,
        p_global_attribute6                          VARCHAR2,
        p_global_attribute7                          VARCHAR2,
        p_global_attribute8                          VARCHAR2,
        p_global_attribute9                          VARCHAR2,
        p_global_attribute10                         VARCHAR2,
        p_global_attribute11                         VARCHAR2,
        p_global_attribute12                         VARCHAR2,
        p_global_attribute13                         VARCHAR2,
        p_global_attribute14                         VARCHAR2,
        p_global_attribute15                         VARCHAR2,
        p_global_attribute16                         VARCHAR2,
        p_global_attribute17                         VARCHAR2,
        p_global_attribute18                         VARCHAR2,
        p_global_attribute19                         VARCHAR2,
        p_global_attribute20                         VARCHAR2,
        p_object_version_number                      NUMBER,
        --p_created_by                                 NUMBER,
        --p_creation_date                              DATE,
        p_last_updated_by                            NUMBER,
        p_last_update_date                           DATE,
        p_last_update_login                          NUMBER) IS

    Cursor c_det ( p_application_id NUMBER,
                   p_entity_code VARCHAR2,
                   p_event_class_code VARCHAR2,
                   p_trx_id      NUMBER)
      is select trx_line_id, summary_tax_line_id from zx_lines
         where application_id = p_application_id
         and   entity_code = p_entity_code
         and   event_class_code = p_event_class_code
         and   trx_id = p_trx_id;

    Cursor c_line (p_application_id NUMBER,
                   p_entity_code VARCHAR2,
                   p_event_class_code VARCHAR2,
                   p_trx_id      NUMBER,
                   p_tax_line_id NUMBER)
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
                      tax_only_line_flag
                FROM zx_lines
                WHERE application_id = p_application_id
                AND   entity_code = p_entity_code
                AND   event_class_code = p_event_class_code
                AND   trx_id  = p_trx_id
                AND   tax_line_id = p_tax_line_id;

    Cursor c2(p_application_id       NUMBER,
              p_entity_code          VARCHAR2,
              p_event_class_code     VARCHAR2,
              p_trx_id               NUMBER,
              p_summary_tax_line_id  NUMBER) IS
    SELECT
       tax_line_id,
       internal_organization_id   ,
       application_id             ,
       entity_code                ,
       event_class_code           ,
        event_type_code            ,
       trx_id                     ,
        trx_line_id                ,
        trx_level_type             ,
        trx_line_number            ,
        doc_event_status           ,
        tax_event_class_code       ,
        tax_event_type_code        ,
        tax_line_number            ,
       content_owner_id           ,
       tax_regime_id              ,
       tax_regime_code            ,
       tax_id                     ,
       tax                        ,
       tax_status_id              ,
       tax_status_code            ,
       tax_rate_id                ,
       tax_rate_code              ,
       tax_rate                   ,
       tax_rate_type              ,
       tax_apportionment_line_number ,--reduced in size tax_apportionment_line_number
       trx_id_level2              ,
       trx_id_level3              ,
       trx_id_level4              ,
       trx_id_level5              ,
       trx_id_level6              ,
       trx_user_key_level1        ,
       trx_user_key_level2        ,
       trx_user_key_level3        ,
       trx_user_key_level4        ,
       trx_user_key_level5        ,
       trx_user_key_level6        ,
       mrc_tax_line_flag          ,
       mrc_link_to_tax_line_id    ,
       ledger_id                  ,
       establishment_id           ,
       legal_entity_id            ,
       hq_estb_reg_number         ,
       hq_estb_party_tax_prof_id  ,
       currency_conversion_date                ,
       currency_conversion_type                 ,
       currency_conversion_rate                ,
       tax_currency_conversion_date                ,--reduced in size tax_currency_conversion_date
       tax_currency_conversion_type                 ,--reduced in sizetax_currency_conversion_type
       tax_currency_conversion_rate                ,--reduced in sizetax_currency_conversion_rate
       trx_currency_code                        ,
       reporting_currency_code                  ,
       minimum_accountable_unit                ,
       precision                               ,
       trx_number                               ,
       trx_date                                ,
       unit_price                              ,
       line_amt                                ,
       trx_line_quantity                       ,
       tax_base_modifier_rate                  ,
       ref_doc_application_id                  ,
       ref_doc_entity_code                      ,
       ref_doc_event_class_code                 ,
       ref_doc_trx_id                          ,
       ref_doc_trx_level_type                   ,
       ref_doc_line_id                         ,
       ref_doc_line_quantity                   ,
       other_doc_line_amt                      ,
       other_doc_line_tax_amt                  ,
       other_doc_line_taxable_amt              ,
       unrounded_taxable_amt                   ,
       unrounded_tax_amt                       ,
       related_doc_application_id              ,
       related_doc_entity_code                  ,
       related_doc_event_class_code               ,--reduced in sizerelated_doc_event_class_code
       related_doc_trx_id                      ,
       related_doc_trx_level_type               ,
       related_doc_number                       ,
       related_doc_date                        ,
       applied_from_application_id                    ,--reduced in sizeapplied_from_application_id
       applied_from_event_class_code               ,--reduced in sizeapplied_from_event_class_code
       applied_from_entity_code                 ,
       applied_from_trx_id                     ,
       applied_from_trx_level_type              ,
       applied_from_line_id                    ,
       applied_from_trx_number                  ,
       adjusted_doc_application_id              ,  -- reduced in size adjusted_doc_application_id
       adjusted_doc_entity_code                 ,
       adjusted_doc_event_class_code            ,  -- reduced in size adjusted_doc_event_class_code
       adjusted_doc_trx_id                     ,
       adjusted_doc_trx_level_type              ,
       adjusted_doc_line_id                    ,
       adjusted_doc_number                      ,
       adjusted_doc_date                       ,
       applied_to_application_id               ,
       applied_to_event_class_code                ,--reduced in sizeapplied_to_event_class_code
       applied_to_entity_code                   ,
       applied_to_trx_id                       ,
       applied_to_trx_level_type                ,
       applied_to_line_id                      ,
       summary_tax_line_id                     ,
       offset_link_to_tax_line_id              ,
       offset_flag                              ,
       process_for_recovery_flag                ,
       tax_jurisdiction_id                     ,
       tax_jurisdiction_code                    ,
       place_of_supply                         ,
       place_of_supply_type_code                ,
       place_of_supply_result_id               ,
       tax_date_rule_id                        ,
       tax_date                                ,
       tax_determine_date                      ,
       tax_point_date                          ,
       trx_line_date                           ,
       tax_type_code                            ,
       tax_code                                 ,
       tax_registration_id                     ,
       tax_registration_number                  ,
       registration_party_type                  ,
       rounding_level_code                      ,
       rounding_rule_code                       ,
       rounding_lvl_party_tax_prof_id           ,  -- reduced in size rounding_lvl_party_tax_prof_id
       rounding_lvl_party_type                  ,
       compounding_tax_flag                     ,
       orig_tax_status_id                      ,
       orig_tax_status_code                     ,
       orig_tax_rate_id                        ,
       orig_tax_rate_code                       ,
       orig_tax_rate                           ,
       orig_tax_jurisdiction_id                ,
       orig_tax_jurisdiction_code               ,
       orig_tax_amt_included_flag               ,
       orig_self_assessed_flag                  ,
       tax_currency_code                        ,
       tax_amt                                 ,
       tax_amt_tax_curr                        ,
       tax_amt_funcl_curr                      ,
       taxable_amt                             ,
       taxable_amt_tax_curr                    ,
       taxable_amt_funcl_curr                  ,
       orig_taxable_amt                        ,
       orig_taxable_amt_tax_curr               ,
       cal_tax_amt                             ,
       cal_tax_amt_tax_curr                    ,
       cal_tax_amt_funcl_curr                  ,
       orig_tax_amt                            ,
       orig_tax_amt_tax_curr                   ,
       rec_tax_amt                             ,
       rec_tax_amt_tax_curr                    ,
       rec_tax_amt_funcl_curr                  ,
       nrec_tax_amt                            ,
       nrec_tax_amt_tax_curr                   ,
       nrec_tax_amt_funcl_curr                 ,
       tax_exemption_id                        ,
       tax_rate_before_exemption               ,
       tax_rate_name_before_exemption              ,
       exempt_rate_modifier                    ,
       exempt_certificate_number                ,
       exempt_reason                            ,
       exempt_reason_code                       ,
       tax_exception_id                        ,
       tax_rate_before_exception               ,
       tax_rate_name_before_exception              ,
       exception_rate                          ,
       tax_apportionment_flag                   ,
       historical_flag                          ,
       taxable_basis_formula                    ,
       tax_calculation_formula                  ,
       cancel_flag                              ,
       purge_flag                               ,
       delete_flag                              ,
       tax_amt_included_flag                    ,
       self_assessed_flag                       ,
       overridden_flag                          ,
       manually_entered_flag                    ,
       reporting_only_flag                      ,
       freeze_until_overridden_flag             ,  -- reduced in size Freeze_Until_Overridden_Flag
       copied_from_other_doc_flag               ,
       recalc_required_flag                     ,
       settlement_flag                          ,
       item_dist_changed_flag                   ,
       associated_child_frozen_flag             ,  -- reduced in size Associated_Child_Frozen_Flag
       tax_only_line_flag                       ,
       compounding_dep_tax_flag                 ,
       compounding_tax_miss_flag                ,
       sync_with_prvdr_flag                     ,
       last_manual_entry                        ,
       tax_provider_id                         ,
       record_type_code                         ,
       reporting_period_id                     ,
       legal_justification_text1                ,
       legal_justification_text2                ,
       legal_justification_text3                ,
       legal_message_appl_2                    ,
       legal_message_status                    ,
       legal_message_rate                      ,
       legal_message_basis                     ,
       legal_message_calc                      ,
       legal_message_threshold                 ,
       legal_message_pos                       ,
       legal_message_trn                       ,
       legal_message_exmpt                     ,
       legal_message_excpt                     ,
       tax_regime_template_id                  ,
       tax_applicability_result_id             ,--reduced in sizetax_applicability_result_id
       direct_rate_result_id                   ,
       status_result_id                        ,
       rate_result_id                          ,
       basis_result_id                         ,
       thresh_result_id                        ,
       calc_result_id                          ,
       tax_reg_num_det_result_id               ,
       eval_exmpt_result_id                    ,
       eval_excpt_result_id                    ,
       enforce_from_natural_acct_flag               ,--reduced in sizeEnforce_From_Natural_Acct_Flag
       tax_hold_code                           ,
       tax_hold_released_code                  ,
       prd_total_tax_amt                       ,
       prd_total_tax_amt_tax_curr              ,
       prd_total_tax_amt_funcl_curr            ,
       trx_line_index                           ,
       offset_tax_rate_code                     ,
       proration_code                           ,
       other_doc_source                         ,
       internal_org_location_id                ,
       line_assessable_value                   ,
       ctrl_total_line_tx_amt                  ,
       applied_to_trx_number                    ,
       attribute_category                       ,
       attribute1                               ,
       attribute2                               ,
       attribute3                               ,
       attribute4                               ,
       attribute5                               ,
       attribute6                               ,
       attribute7                               ,
       attribute8                               ,
       attribute9                               ,
       attribute10                              ,
       attribute11                              ,
       attribute12                              ,
       attribute13                              ,
       attribute14                              ,
       attribute15                              ,
       global_attribute_category                ,
       global_attribute1                        ,
       global_attribute2                        ,
       global_attribute3                        ,
       global_attribute4                        ,
       global_attribute5                        ,
       global_attribute6                        ,
       global_attribute7                        ,
       global_attribute8                        ,
       global_attribute9                        ,
       global_attribute10                       ,
       global_attribute11                       ,
       global_attribute12                       ,
       global_attribute13                       ,
       global_attribute14                       ,
       global_attribute15                       ,
       numeric1                                ,
       numeric2                                ,
       numeric3                                ,
       numeric4                                ,
       numeric5                                ,
       numeric6                                ,
       numeric7                                ,
       numeric8                                ,
       numeric9                                ,
       numeric10                               ,
       char1                                    ,
       char2                                    ,
       char3                                    ,
       char4                                    ,
       char5                                    ,
       char6                                    ,
       char7                                    ,
       char8                                    ,
       char9                                    ,
       char10                                   ,
       date1                                   ,
       date2                                   ,
       date3                                   ,
       date4                                   ,
       date5                                   ,
       date6                                   ,
       date7                                   ,
       date8                                   ,
       date9                                   ,
       date10                                  ,
       interface_entity_code                    ,
       interface_tax_line_id                   ,
       taxing_juris_geography_id               ,
       adjusted_doc_tax_line_id                ,
       object_version_number                   ,
       last_updated_by                         ,
       last_update_date                       ,
       last_update_login
  FROM zx_lines
 WHERE application_id = p_application_id
   AND entity_code = p_entity_code
   AND event_class_code = p_event_class_code
   AND trx_id = p_trx_id
   AND summary_tax_line_id = p_summary_tax_line_id
   AND nvl(cancel_flag,'N') <> 'Y'
   ORDER by associated_child_frozen_flag DESC NULLS LAST;

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
   AND    NVL(currency_conversion_rate, 1) = NVL(p_currency_conversion_rate, 1)
   AND    NVL(taxable_basis_formula, 'x') = NVL(p_taxable_basis_formula, 'x')
   AND    NVL(tax_calculation_formula, 'x') = NVL(p_tax_calculation_formula, 'x')
   AND    NVL(tax_amt_included_flag,'N') = NVL(p_tax_amt_included_flag,'N')
   AND    NVL(compounding_tax_flag,'N') = NVL(p_compounding_tax_flag,'N')
   AND    NVL(self_assessed_flag,'N') = NVL(p_self_assessed_flag,'N')
   AND    NVL(reporting_only_flag,'N') = NVL(p_reporting_only_flag,'N')
   -- AND NVL(copied_from_other_doc_flag,'N') = NVL(p_copied_from_other_doc_flag,'N')
   AND    NVL(record_type_code, 'x') = NVL(p_record_type_code, 'x')
   AND    NVL(tax_provider_id, -999) = NVL(p_tax_provider_id, -999)
   AND    NVL(historical_flag,'N') = NVL(p_historical_flag,'N')
   AND    NVL(delete_flag,'N') = NVL(p_delete_flag,'N')
   --     AND NVL(overridden_flag,'N') = NVL(p_overridden_flag,'N')
   AND    NVL(manually_entered_flag,'N') = NVL(p_manually_entered_flag,'N')
   AND    NVL(tax_exemption_id, -999) = NVL(p_tax_exemption_id, -999)
   -- AND NVL(tax_rate_before_exemption, -999) = NVL(p_tax_rate_before_exemption, -999)
   -- AND NVL(tax_rate_name_before_exemption, 'x') = NVL(p_tax_rate_name_before_exempt, 'x')
   -- AND NVL(exempt_rate_modifier, -999) = NVL(p_exempt_rate_modifier, -999)
   AND    NVL(exempt_certificate_number, 'x') = NVL(p_exempt_certificate_number, 'x')
   -- AND NVL(exempt_reason, 'x') = NVL(p_exempt_reason, 'x')
   AND    NVL(exempt_reason_code, 'x') = NVL(p_exempt_reason_code, 'x')
   -- AND NVL(tax_rate_before_exception, -999) = NVL(p_tax_rate_before_exception, -999)
   -- AND NVL(tax_rate_name_before_exception, 'x') = NVL(p_tax_rate_name_before_except, 'x')
   AND    NVL(tax_exception_id, -999) = NVL(p_tax_exception_id, -999)
   -- AND NVL(exception_rate, -999) = NVL(p_exception_rate, -999)
   AND    NVL(mrc_tax_line_flag,'N') = NVL(p_mrc_tax_line_flag,'N')
   AND    NVL(tax_only_line_flag,'N') = NVL(p_tax_only_line_flag,'N');

    recinfo c2%ROWTYPE;
    l_total_detail_tax_amt      NUMBER;
    l_total_detail_taxable_amt      NUMBER;
    l_num_det_lines             NUMBER;
    l_summary_tax_line_id       NUMBER;
    l_ctrl_ef_ov_cal_line_flag  VARCHAR2(1);
    Invalid_unrounded_amt       Exception;
    l_tax_line_id NUMBER;
    l_offset_tax_line_id NUMBER;
    l_offset_trx_line_id NUMBER;
    l_row_id      VARCHAR2(100);
    l_tax_apportionment_line_num  NUMBER;
    l_tax_line_number  NUMBER;
    l_value VARCHAR2(10) := 'N';

    l_summary_tax_amt                    NUMBER;
    l_overridden_flag                    VARCHAR2(1);

    l_existing_summary_tax_line_id       NUMBER;
    l_tax_rate                           NUMBER;
    l_had_frozen_dists                   BOOLEAN;
    l_num_canceled_detail_lines          NUMBER;
    l_allow_adhoc_tax_rate_flag          VARCHAR2(1);
    l_adj_for_adhoc_amt_code             VARCHAR2(30);

    l_orig_self_assessed_flag            VARCHAR2(1);
    l_orig_tax_amt_included_flag         VARCHAR2(1);
    l_allow_update_flag                  VARCHAR2(1);

  BEGIN

    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                    'ZX.PLSQL.ZX_TRL_SUMMARY_OVERRIDE_PKG.Update_Row.BEGIN',
                    'ZX_TRL_SUMMARY_OVERRIDE_PKG: Update_Row (+)'||p_self_assessed_flag);
    END IF;

    IF (g_level_statement >= g_current_runtime_level) THEN
      FND_LOG.STRING(g_level_statement,
                    'ZX.PLSQL.ZX_TRL_SUMMARY_OVERRIDE_PKG.Update_Row.BEGIN',
                    'Self assessed flag '||p_self_assessed_flag);
    END IF;

    BEGIN
      SELECT tax_amt, overridden_flag INTO l_summary_tax_amt, l_overridden_flag
        FROM zx_lines_summary
       WHERE summary_tax_line_id = p_summary_tax_line_id;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

    BEGIN
      SELECT sum(unrounded_tax_amt), SUM(unrounded_taxable_amt), COUNT(*)
        INTO l_total_detail_tax_amt, l_total_detail_taxable_amt, l_num_det_lines
        FROM zx_lines
       WHERE summary_tax_line_id = p_summary_tax_line_id
         AND application_id      = p_application_id
         AND entity_code         = p_entity_code
         AND event_class_code    = p_event_class_code
         AND trx_id              = p_trx_id
         AND NVL(cancel_flag, 'N') <> 'Y';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF (g_level_statement >= g_current_runtime_level) THEN
          FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_TRL_SUMMARY_OVERRIDE_PKG.Update_Row.BEGIN',
                      'No Lines to Update ');
          FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_TRL_SUMMARY_OVERRIDE_PKG.Update_Row.END',
                      'ZX_TRL_SUMMARY_OVERRIDE_PKG: Update_Row (-)');
        END IF;
        RETURN;
      WHEN OTHERS THEN
        NULL;
    END;

    -- bug#8264829- taxable_amt = 0, error if tax_amt <> 0
    IF (l_total_detail_taxable_amt = 0 AND
        p_tax_amt <> 0 ) THEN
      IF (g_level_statement >= g_current_runtime_level) THEN
           FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TRL_SUMMARY_OVERRIDE_PKG.Update_Row',
                     'error: taxable_amt = 0 but tax_amt <> 0');
      END IF;

      FND_MESSAGE.Set_Name ('ZX','ZX_TAX_AMT_UPDATE_NOT_ALLOWED');
      FND_MSG_PUB.ADD;
      RETURN;
    END IF;


    l_tax_rate := p_tax_rate;
    l_summary_tax_line_id := p_summary_tax_line_id;
    l_had_frozen_dists := FALSE;
    l_num_canceled_detail_lines := 0;
    l_allow_update_flag := 'N';

    IF p_last_manual_entry = 'TAX_AMOUNT' AND p_tax_amt <> l_summary_tax_amt AND
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
        IF l_total_detail_taxable_amt <> 0 THEN
         l_tax_rate := round(p_tax_amt/l_total_detail_taxable_amt*100, 6); -- Bug 8217841
        END IF;
      END IF;
    END IF;   -- p_last_manual_entry = 'TAX_AMOUNT' AND

    -- new changes
    FOR rec IN existing_summary_tax_line(l_tax_rate) LOOP
      IF rec.summary_tax_line_id = p_summary_tax_line_id THEN
        l_existing_summary_tax_line_id := NULL;
        EXIT;
      ELSE
        l_existing_summary_tax_line_id := rec.summary_tax_line_id;
      END IF;
    END LOOP;
   -- new changes end

    BEGIN
      SELECT CTRL_EFF_OVRD_CALC_LINES_FLAG
      INTO l_ctrl_ef_ov_cal_line_flag
      FROM ZX_EVNT_CLS_OPTIONS
      WHERE EVENT_CLASS_CODE = p_event_class_code
      AND APPLICATION_ID = p_application_id
      AND ENTITY_CODE = p_entity_code
      AND ENABLED_FLAG = 'Y'
      AND FIRST_PTY_ORG_ID = p_internal_organization_id
      AND EFFECTIVE_FROM <= sysdate
      AND (EFFECTIVE_TO >= sysdate OR
           EFFECTIVE_TO IS NULL);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        SELECT CTRL_EFF_OVRD_CALC_LINES_FLAG
        INTO l_ctrl_ef_ov_cal_line_flag
        FROM ZX_EVNT_CLS_MAPPINGS
        WHERE EVENT_CLASS_CODE = p_event_class_code
        AND APPLICATION_ID = p_application_id
        AND ENTITY_CODE = p_entity_code;

    END;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_SUMMARY_OVERRIDE_PKG.Update_Row',
                     'Update zx_lines_summary (+)');
    END IF;

    FOR rec IN  c2(p_application_id,
                   p_entity_code,
                   p_event_class_code,
                   p_trx_id,
                   p_summary_tax_line_id)
    LOOP

      IF (g_level_statement >= g_current_runtime_level) THEN
        FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_TRL_SUMMARY_OVERRIDE_PKG.Update_Row.BEGIN',
                      'tax only line flag ='||rec.tax_only_line_flag);
        FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_TRL_SUMMARY_OVERRIDE_PKG.Update_Row.BEGIN',
                      'tax only line flag ='||rec.associated_child_frozen_flag);
      END IF;

      IF rec.freeze_until_overridden_flag = 'Y' AND
         rec.overridden_flag = 'Y' AND
         rec.copied_from_other_doc_flag = 'Y' AND
         rec.ref_doc_application_id = 201 AND
         rec.other_doc_source = 'REFERENCE' AND
         rec.tax_amt = 0 AND
         rec.taxable_amt = 0 AND
         l_allow_update_flag = 'N' THEN
        l_allow_update_flag := 'N';
      ELSE
        l_allow_update_flag := 'Y';
      END IF;

      IF NVL(rec.tax_only_line_flag, 'N') = 'N' THEN
        IF(   rec.tax_status_code                                 <> p_tax_status_code
           OR rec.tax_rate_id                                     <> p_tax_rate_id
           OR rec.tax_rate_code                                   <> p_tax_rate_code
           OR rec.tax_rate                                        <> l_tax_rate
           OR NVL(rec.tax_jurisdiction_code, 'x')                 <> NVL(p_tax_jurisdiction_code, 'x')
           OR NVL(rec.ledger_id, -999)                            <> NVL(p_ledger_id, -999)
           OR NVL(rec.legal_entity_id, -999)                      <> NVL(p_legal_entity_id, -999)
           OR NVL(rec.establishment_id, -999)                     <> NVL(p_establishment_id, -999)
           OR NVL(TRUNC(rec.currency_conversion_date),DATE_DUMMY) <> NVL(TRUNC(p_currency_conversion_date), DATE_DUMMY)
           OR NVL(rec.currency_conversion_type, 'x')              <> NVL(p_currency_conversion_type,'x')
           OR NVL(rec.currency_conversion_rate, 1)                <> NVL(p_currency_conversion_rate, 1)
           OR NVL(rec.taxable_basis_formula,'x')                  <> NVL(p_taxable_basis_formula, 'x')
           OR NVL(rec.tax_calculation_formula, 'x')               <> NVL(p_tax_calculation_formula, 'x')
           OR NVL(rec.tax_amt_included_flag,'N')                  <> NVL(p_tax_amt_included_flag,'N')
           OR NVL(rec.compounding_tax_flag,'N')                   <> NVL(p_compounding_tax_flag,'N')
           OR NVL(rec.self_assessed_flag,'N')                     <> NVL(p_self_assessed_flag,'N')
           OR NVL(rec.reporting_only_flag,'N')                    <> NVL(p_reporting_only_flag,'N')
           -- OR NVL(rec.copied_from_other_doc_flag,'N')             <> NVL(p_copied_from_other_doc_flag,'N')
           OR NVL(rec.record_type_code,'x')                       <> NVL(p_record_type_code, 'x')
           OR NVL(rec.tax_provider_id, -999)                      <> NVL(p_tax_provider_id, -999)
           OR NVL(rec.historical_flag,'N')                        <> NVL(p_historical_flag,'N')
           OR NVL(rec.delete_flag,'N')                            <> NVL(p_delete_flag,'N')
           -- OR NVL(rec.overridden_flag,'N')                        <> NVL(p_overridden_flag,'N')
           OR NVL(rec.manually_entered_flag,'N')                  <> NVL(p_manually_entered_flag,'N')
           OR NVL(rec.tax_exemption_id, -999)                     <> NVL(p_tax_exemption_id, -999)
           -- OR NVL(rec.tax_rate_before_exemption, -999)            <> NVL(p_tax_rate_before_exemption, -999)
           -- OR NVL(rec.tax_rate_name_before_exemption, 'x')        <> NVL(p_tax_rate_name_before_exempt, 'x')
           -- OR NVL(rec.exempt_rate_modifier, -999)                 <> NVL(p_exempt_rate_modifier, -999)
           OR NVL(rec.exempt_certificate_number,'x')              <> NVL(p_exempt_certificate_number, 'x')
           -- OR NVL(rec.exempt_reason, 'x')                         <> NVL(p_exempt_reason, 'x')
           OR NVL(rec.exempt_reason_code,'x')                     <> NVL(p_exempt_reason_code, 'x')
           -- OR NVL(rec.tax_rate_before_exception, -999)            <> NVL(p_tax_rate_before_exception, -999)
           -- OR NVL(rec.tax_rate_name_before_exception, 'x')        <> NVL(p_tax_rate_name_before_except, 'x')
           OR NVL(rec.tax_exception_id, -999)                     <> NVL(p_tax_exception_id, -999)
           -- OR NVL(rec.exception_rate, -999)                       <> NVL(p_exception_rate, -999)
           OR NVL(rec.mrc_tax_line_flag,'N')                      <> NVL(p_mrc_tax_line_flag,'N')
           OR NVL(rec.tax_only_line_flag,'N')                     <> NVL(p_tax_only_line_flag,'N')
           -- OR (NVL(l_summary_tax_amt,-999999999)                  <> NVL(p_tax_amt,-999999999)
           -- AND NVL(l_overridden_flag,'N')='N')
          )
        THEN

          IF NVL(rec.associated_child_frozen_flag,'N') = 'Y' THEN

            SELECT zx_lines_s.NEXTVAL INTO l_tax_line_id FROM DUAL;

            -- new changes
            IF l_summary_tax_line_id = p_summary_tax_line_id THEN
              SELECT zx_lines_summary_s.NEXTVAL INTO l_summary_tax_line_id FROM DUAL;
            END IF;
            -- new changes

            SELECT max(abs(tax_apportionment_line_number))+1
            INTO l_tax_apportionment_line_num
            FROM zx_lines
            WHERE application_id = p_application_id
            AND entity_code = p_entity_code
            AND event_class_code = p_event_class_code
            AND trx_id = p_trx_id
            AND trx_line_id = rec.trx_line_id;

            SELECT nvl(max(tax_line_number),0)+1
            INTO l_tax_line_number
            FROM zx_lines
            WHERE application_id = p_application_id
            AND entity_code = p_entity_code
            AND event_class_code = p_event_class_code
            AND trx_id = p_trx_id
            AND trx_line_id = rec.trx_line_id
            AND trx_level_type = rec.trx_level_type;

            UPDATE ZX_LINES
            SET cancel_flag = 'Y',
                tax_apportionment_line_number = -1*l_tax_apportionment_line_num,
                tax_amt = 0,
                tax_amt_tax_curr = 0,
                tax_amt_funcl_curr = 0,
                unrounded_tax_amt = 0,
                process_for_recovery_flag = 'Y',
                legal_reporting_status = decode(legal_reporting_status, '111111111111111','000000000000000',legal_reporting_status)
            WHERE tax_line_id = rec.tax_line_id;

            IF (g_level_statement >= g_current_runtime_level) THEN
              FND_LOG.STRING(g_level_statement,
                             'ZX.PLSQL.ZX_TRL_SUMMARY_OVERRIDE_PKG.Update_Row.BEGIN',
                             'Tax line id updated'||to_char(rec.tax_line_id));
            END IF;

            BEGIN
              select tax_line_id into l_offset_tax_line_id
              FROM zx_lines
              where application_id = p_application_id
              and entity_code = p_entity_code
              and event_class_code = p_event_class_code
              and offset_link_to_tax_line_id = rec.tax_line_id;

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
               WHEN OTHERS THEN
                 NULL;
             END;

             IF (g_level_statement >= g_current_runtime_level) THEN
               FND_LOG.STRING(g_level_statement,
                              'ZX.PLSQL.ZX_TRL_SUMMARY_OVERRIDE_PKG.Update_Row.BEGIN',
                              'Tax line id updated'||to_char(l_offset_tax_line_id));
             END IF;

             IF (g_level_procedure >= g_current_runtime_level ) THEN
               FND_LOG.STRING(g_level_procedure,
                              'ZX.PLSQL.ZX_TRL_SUMMARY_OVERRIDE_PKG.Update_Row',
                              'tax apportionment line number '||l_tax_apportionment_line_num);
             END IF;

             IF (g_level_procedure >= g_current_runtime_level ) THEN
               FND_LOG.STRING(g_level_procedure,
                              'ZX.PLSQL.ZX_TRL_SUMMARY_OVERRIDE_PKG.Update_Row',
                              'historical_flag '|| p_historical_flag);
             END IF;

             l_had_frozen_dists := TRUE;
             IF rec.orig_self_assessed_flag IS NULL THEN
               IF p_self_assessed_flag = rec.self_assessed_flag THEN
                  l_orig_self_assessed_flag := NULL;
               ELSE
                  l_orig_self_assessed_flag := nvl(rec.self_assessed_flag,'N');
               END IF;
             ELSE
               l_orig_self_assessed_flag := rec.orig_self_assessed_flag;
             END IF;

             IF rec.orig_tax_amt_included_flag IS NULL THEN
               IF p_tax_amt_included_flag = rec.tax_amt_included_flag THEN
                  l_orig_tax_amt_included_flag := NULL;
               ELSE
                  l_orig_tax_amt_included_flag := nvl(rec.tax_amt_included_flag,'N');
               END IF;
             ELSE
               l_orig_tax_amt_included_flag := rec.orig_tax_amt_included_flag;
             END IF;

             zx_trl_detail_override_pkg.Insert_Row
                 (l_row_id                             ,
                  l_tax_line_id                        ,
                  p_internal_organization_id           ,
                  rec.application_id                   ,
                  rec.entity_code                      ,
                  rec.event_class_code                 ,
                  rec.event_type_code                  ,
                  rec.trx_id                           ,
                  rec.trx_line_id                      ,
                  rec.trx_level_type                   ,
                  rec.trx_line_number                  ,
                  rec.doc_event_status                 ,
                  rec.tax_event_class_code             ,
                  rec.tax_event_type_code              ,
                  l_tax_line_number                    ,
                  rec.content_owner_id                 ,
                  rec.tax_regime_id                    ,
                  rec.tax_regime_code                  ,
                  rec.tax_id                           ,
                  rec.tax                              ,
                  p_tax_status_id                      ,
                  p_tax_status_code                    ,
                  p_tax_rate_id                        ,
                  p_tax_rate_code                      ,
                  l_tax_rate                           ,  --tax_rate
                  rec.tax_rate_type                    ,
                  rec.tax_apportionment_line_number    ,  --reduced in size tax_apportionment_line_number
                  rec.trx_id_level2                    ,
                  rec.trx_id_level3                    ,
                  rec.trx_id_level4                    ,
                  rec.trx_id_level5                    ,
                  rec.trx_id_level6                    ,
                  rec.trx_user_key_level1              ,
                  rec.trx_user_key_level2              ,
                  rec.trx_user_key_level3              ,
                  rec.trx_user_key_level4              ,
                  rec.trx_user_key_level5              ,
                  rec.trx_user_key_level6              ,
                  rec.mrc_tax_line_flag                ,
                  rec.mrc_link_to_tax_line_id          ,
                  rec.ledger_id                        ,
                  rec.establishment_id                 ,
                  rec.legal_entity_id                  ,
                  rec.hq_estb_reg_number               ,
                  rec.hq_estb_party_tax_prof_id        ,
                  rec.currency_conversion_date         ,
                  rec.currency_conversion_type         ,
                  rec.currency_conversion_rate         ,
                  rec.tax_currency_conversion_date     ,  --reduced in size tax_currency_conversion_date
                  rec.tax_currency_conversion_type     ,  --reduced in size rec.tax_currency_conversion_type
                  rec.tax_currency_conversion_rate     ,  --reduced in size rec.tax_currency_conversion_rate
                  rec.trx_currency_code                ,
                  rec.reporting_currency_code          ,
                  rec.minimum_accountable_unit         ,
                  rec.precision                        ,
                  p_trx_number                         ,
                  rec.trx_date                         ,
                  rec.unit_price                       ,
                  rec.line_amt                         ,
                  rec.trx_line_quantity                ,
                  rec.tax_base_modifier_rate           ,
                  rec.ref_doc_application_id           ,
                  rec.ref_doc_entity_code              ,
                  rec.ref_doc_event_class_code         ,
                  rec.ref_doc_trx_id                   ,
                  rec.ref_doc_trx_level_type           ,
                  rec.ref_doc_line_id                  ,
                  rec.ref_doc_line_quantity            ,
                  rec.other_doc_line_amt               ,
                  rec.other_doc_line_tax_amt           ,
                  rec.other_doc_line_taxable_amt       ,
                  rec.unrounded_taxable_amt            ,
                  rec.unrounded_tax_amt                ,
                  rec.related_doc_application_id       ,
                  rec.related_doc_entity_code          ,
                  rec.related_doc_event_class_code     ,  --reduced in size rec.related_doc_event_class_code
                  rec.related_doc_trx_id               ,
                  rec.related_doc_trx_level_type       ,
                  rec.related_doc_number               ,
                  rec.related_doc_date                 ,
                  p_applied_from_application_id        ,  --reduced in size rec.applied_from_application_id
                  rec.applied_from_event_class_code    ,  --reduced in size rec.applied_from_event_class_code
                  p_applied_from_entity_code           ,
                  rec.applied_from_trx_id              ,
                  rec.applied_from_trx_level_type      ,
                  rec.applied_from_line_id             ,
                  rec.applied_from_trx_number          ,
                  rec.adjusted_doc_application_id      ,  --reduced in size rec.adjusted_doc_application_id
                  rec.adjusted_doc_entity_code         ,
                  rec.adjusted_doc_event_class_code    ,  --reduced in size rec.adjusted_doc_event_class_code
                  rec.adjusted_doc_trx_id              ,
                  rec.adjusted_doc_trx_level_type      ,
                  rec.adjusted_doc_line_id             ,
                  rec.adjusted_doc_number              ,
                  rec.adjusted_doc_date                ,
                  rec.applied_to_application_id        ,
                  rec.applied_to_event_class_code      ,  --reduced in size rec.applied_to_event_class_code
                  rec.applied_to_entity_code           ,
                  rec.applied_to_trx_id                ,
                  rec.applied_to_trx_level_type        ,
                  rec.applied_to_line_id               ,
                  l_summary_tax_line_id                ,  --summary_tax_line_id
                  rec.offset_link_to_tax_line_id       ,
                  rec.offset_flag                      ,
                  rec.process_for_recovery_flag        ,
                  rec.tax_jurisdiction_id              ,
                  p_tax_jurisdiction_code              ,
                  rec.place_of_supply                  ,
                  rec.place_of_supply_type_code        ,
                  rec.place_of_supply_result_id        ,
                  rec.tax_date_rule_id                 ,
                  rec.tax_date                         ,
                  rec.tax_determine_date               ,
                  rec.tax_point_date                   ,
                  rec.trx_line_date                    ,
                  rec.tax_type_code                    ,
                  rec.tax_code                         ,
                  rec.tax_registration_id              ,
                  rec.tax_registration_number          ,
                  rec.registration_party_type          ,
                  rec.rounding_level_code              ,
                  rec.rounding_rule_code               ,
                  rec.rounding_lvl_party_tax_prof_id   ,  --reduced in size rec.rounding_lvl_party_tax_prof_id
                  rec.rounding_lvl_party_type          ,
                  rec.compounding_tax_flag             ,
                  rec.orig_tax_status_id               ,
                  rec.orig_tax_status_code             ,
                  rec.orig_tax_rate_id                 ,
                  rec.orig_tax_rate_code               ,
                  rec.orig_tax_rate                    ,
                  rec.orig_tax_jurisdiction_id         ,
                  rec.orig_tax_jurisdiction_code       ,
                  l_orig_tax_amt_included_flag         ,
                  l_orig_self_assessed_flag            ,
                  rec.tax_currency_code                ,
                  rec.tax_amt                          ,
                  rec.tax_amt_tax_curr                 ,
                  rec.tax_amt_funcl_curr               ,
                  rec.taxable_amt                      ,
                  rec.taxable_amt_tax_curr             ,
                  rec.taxable_amt_funcl_curr           ,
                  rec.orig_taxable_amt                 ,
                  rec.orig_taxable_amt_tax_curr        ,
                  rec.cal_tax_amt                      ,
                  rec.cal_tax_amt_tax_curr             ,
                  rec.cal_tax_amt_funcl_curr           ,
                  rec.orig_tax_amt                     ,
                  rec.orig_tax_amt_tax_curr            ,
                  rec.rec_tax_amt                      ,
                  rec.rec_tax_amt_tax_curr             ,
                  rec.rec_tax_amt_funcl_curr           ,
                  rec.nrec_tax_amt                     ,
                  rec.nrec_tax_amt_tax_curr            ,
                  rec.nrec_tax_amt_funcl_curr          ,
                  rec.tax_exemption_id                 ,
                  rec.tax_rate_before_exemption        ,
                  rec.tax_rate_name_before_exemption   ,
                  rec.exempt_rate_modifier             ,
                  rec.exempt_certificate_number        ,
                  rec.exempt_reason                    ,
                  rec.exempt_reason_code               ,
                  rec.tax_exception_id                 ,
                  rec.tax_rate_before_exception        ,
                  rec.tax_rate_name_before_exception   ,
                  rec.exception_rate                   ,
                  rec.tax_apportionment_flag           ,
                  'N'                                  ,  --historical_flag -- Bug#8886272
                  p_taxable_basis_formula              ,
                  p_tax_calculation_formula            ,
                  nvl(rec.cancel_flag,'N')             ,
                  rec.purge_flag                       ,
                  rec.delete_flag                      ,
                  p_tax_amt_included_flag              ,
                  p_self_assessed_flag                 ,
                  'C'                                  ,
                  p_manually_entered_flag              ,
                  p_reporting_only_flag                ,
                  rec.freeze_until_overridden_flag     ,  --reduced in size rec.Freeze_Until_Overridden_Flag
                  rec.copied_from_other_doc_flag       ,
                  rec.recalc_required_flag             ,
                  rec.settlement_flag                  ,
                  rec.item_dist_changed_flag           ,
                  NULL                                 ,  --reduced in size rec.Associated_Child_Frozen_Flag
                  rec.tax_only_line_flag               ,
                  rec.compounding_tax_flag             ,
                  rec.compounding_tax_miss_flag        ,
                  rec.sync_with_prvdr_flag             ,
                  rec.last_manual_entry                ,
                  rec.tax_provider_id                  ,
                  p_record_type_code                   ,
                  rec.reporting_period_id              ,
                  rec.legal_justification_text1        ,
                  rec.legal_justification_text2        ,
                  rec.legal_justification_text3        ,
                  rec.legal_message_appl_2             ,
                  rec.legal_message_status             ,
                  rec.legal_message_rate               ,
                  rec.legal_message_basis              ,
                  rec.legal_message_calc               ,
                  rec.legal_message_threshold          ,
                  rec.legal_message_pos                ,
                  rec.legal_message_trn                ,
                  rec.legal_message_exmpt              ,
                  rec.legal_message_excpt              ,
                  rec.tax_regime_template_id           ,
                  rec.tax_applicability_result_id      ,  --reduced in size rec.tax_applicability_result_id
                  rec.direct_rate_result_id            ,
                  rec.status_result_id                 ,
                  rec.rate_result_id                   ,
                  rec.basis_result_id                  ,
                  rec.thresh_result_id                 ,
                  rec.calc_result_id                   ,
                  rec.tax_reg_num_det_result_id        ,
                  rec.eval_exmpt_result_id             ,
                  rec.eval_excpt_result_id             ,
                  rec.enforce_from_natural_acct_flag   ,  --reduced in size rec.Enforce_From_Natural_Acct_Flag
                  rec.tax_hold_code                    ,
                  rec.tax_hold_released_code           ,
                  rec.prd_total_tax_amt                ,
                  rec.prd_total_tax_amt_tax_curr       ,
                  rec.prd_total_tax_amt_funcl_curr     ,
                  rec.trx_line_index                   ,
                  rec.offset_tax_rate_code             ,
                  rec.proration_code                   ,
                  rec.other_doc_source                 ,
                  rec.internal_org_location_id         ,
                  rec.line_assessable_value            ,
                  rec.ctrl_total_line_tx_amt           ,
                  rec.applied_to_trx_number            ,
                  NULL                                 , -- Bug 7117340 -- DFF ER -- rec.attribute_category
                  NULL                                 , -- Bug 7117340 -- DFF ER -- rec.attribute1
                  NULL                                 , -- Bug 7117340 -- DFF ER -- rec.attribute2
                  NULL                                 , -- Bug 7117340 -- DFF ER -- rec.attribute3
                  NULL                                 , -- Bug 7117340 -- DFF ER -- rec.attribute4
                  NULL                                 , -- Bug 7117340 -- DFF ER -- rec.attribute5
                  NULL                                 , -- Bug 7117340 -- DFF ER -- rec.attribute6
                  NULL                                 , -- Bug 7117340 -- DFF ER -- rec.attribute7
                  NULL                                 , -- Bug 7117340 -- DFF ER -- rec.attribute8
                  NULL                                 , -- Bug 7117340 -- DFF ER -- rec.attribute9
                  NULL                                 , -- Bug 7117340 -- DFF ER -- rec.attribute10
                  NULL                                 , -- Bug 7117340 -- DFF ER -- rec.attribute11
                  NULL                                 , -- Bug 7117340 -- DFF ER -- rec.attribute12
                  NULL                                 , -- Bug 7117340 -- DFF ER -- rec.attribute13
                  NULL                                 , -- Bug 7117340 -- DFF ER -- rec.attribute14
                  NULL                                 , -- Bug 7117340 -- DFF ER -- rec.attribute15
                  rec.global_attribute_category        ,
                  rec.global_attribute1                ,
                  rec.global_attribute2                ,
                  rec.global_attribute3                ,
                  rec.global_attribute4                ,
                  rec.global_attribute5                ,
                  rec.global_attribute6                ,
                  rec.global_attribute7                ,
                  rec.global_attribute8                ,
                  rec.global_attribute9                ,
                  rec.global_attribute10               ,
                  rec.global_attribute11               ,
                  rec.global_attribute12               ,
                  rec.global_attribute13               ,
                  rec.global_attribute14               ,
                  rec.global_attribute15               ,
                  rec.numeric1                         ,
                  rec.numeric2                         ,
                  rec.numeric3                         ,
                  rec.numeric4                         ,
                  rec.numeric5                         ,
                  rec.numeric6                         ,
                  rec.numeric7                         ,
                  rec.numeric8                         ,
                  rec.numeric9                         ,
                  rec.numeric10                        ,
                  rec.char1                            ,
                  rec.char2                            ,
                  rec.char3                            ,
                  rec.char4                            ,
                  rec.char5                            ,
                  rec.char6                            ,
                  rec.char7                            ,
                  rec.char8                            ,
                  rec.char9                            ,
                  rec.char10                           ,
                  rec.date1                            ,
                  rec.date2                            ,
                  rec.date3                            ,
                  rec.date4                            ,
                  rec.date5                            ,
                  rec.date6                            ,
                  rec.date7                            ,
                  rec.date8                            ,
                  rec.date9                            ,
                  rec.date10                           ,
                  rec.interface_entity_code            ,
                  rec.interface_tax_line_id            ,
                  rec.taxing_juris_geography_id        ,
                  rec.adjusted_doc_tax_line_id         ,
                  rec.object_version_number            ,
                  rec.last_updated_by                  ,
                  rec.last_update_date                 ,
                  rec.last_updated_by                  ,
                  rec.last_update_date                 ,
                  rec.last_update_login);

          ELSE  -- associated_child_frozen_flag = 'N'

            -- new changes
            IF l_existing_summary_tax_line_id is NULL AND NOT(l_had_frozen_dists)
            THEN

              SELECT count(*) INTO l_num_canceled_detail_lines
                FROM zx_lines
               WHERE application_id      = p_application_id
                 AND entity_code         = p_entity_code
                 AND event_class_code    = p_event_class_code
                 AND trx_id              = p_trx_id
                 AND summary_tax_line_id = p_summary_tax_line_id
                 AND nvl(cancel_flag,'N')= 'Y';
            END IF;

            IF l_num_canceled_detail_lines > 0
               --  OR l_existing_summary_tax_line_id is NOT NULL
            THEN
              l_had_frozen_dists := TRUE;
              IF l_summary_tax_line_id = p_summary_tax_line_id THEN
                SELECT zx_lines_summary_s.NEXTVAL INTO l_summary_tax_line_id FROM DUAL;
              END IF;
            END IF;

            -- update detail tax line with the new summary tax line id
            --
            IF l_summary_tax_line_id <> p_summary_tax_line_id THEN
              BEGIN
                UPDATE ZX_LINES
                   SET summary_tax_line_id = l_summary_tax_line_id
                WHERE tax_line_id = rec.tax_line_id;
              EXCEPTION
                WHEN OTHERS THEN
                  NULL;
              END;
            END IF;
            -- new changes end

          END IF;    -- associated_child_frozen_flag
        END IF;      -- grouping columns
      END IF;        -- tax_only_line_flag
    END LOOP;

  IF l_allow_update_flag = 'Y' THEN
   IF l_existing_summary_tax_line_id is NULL THEN
     UPDATE ZX_LINES_SUMMARY
        SET TAX_STATUS_CODE       = p_tax_status_code,
            TAX_RATE_ID           = p_tax_rate_Id,
            SUMMARY_TAX_LINE_ID   = nvl(l_summary_tax_line_id,p_summary_tax_line_id) ,
            TAX_RATE_CODE         = p_tax_rate_code,
            TAX_RATE              = l_tax_rate,
            TAX_AMT               = p_tax_amt,
            TAX_JURISDICTION_CODE = p_tax_jurisdiction_code, -- Bug 8329584
            OVERRIDDEN_FLAG       = p_overridden_flag,
            LAST_MANUAL_ENTRY     = decode (nvl(p_cancel_flag,'N'), 'N', p_last_manual_entry, 'TAX_AMOUNT'),
            ADJUST_TAX_AMT_FLAG   = decode (nvl(p_cancel_flag,'N'), 'N', 'Y', ADJUST_TAX_AMT_FLAG),
            CANCEL_FLAG           = NVL(p_cancel_flag,'N'),
            TAX_AMT_INCLUDED_FLAG = p_tax_amt_included_flag,
            SELF_ASSESSED_FLAG    = p_self_assessed_flag,
            TAX_ONLY_LINE_FLAG    = p_tax_only_line_flag,
            OBJECT_VERSION_NUMBER = NVL(p_object_version_number, OBJECT_VERSION_NUMBER + 1),
            LAST_UPDATED_BY       = fnd_global.user_id,
            LAST_UPDATE_DATE      = sysdate,
            LAST_UPDATE_LOGIN     = fnd_global.login_id
      WHERE summary_tax_line_id = p_summary_tax_line_id;
    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                    'ZX.PLSQL.ZX_TRL_SUMMARY_OVERRIDE_PKG.Update_Row',
                     'cancel flag is '||p_cancel_flag);
    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_SUMMARY_OVERRIDE_PKG.Update_Row',
                     'tot detail tax amt'||to_char(l_total_detail_tax_amt));
    END IF;
    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_SUMMARY_OVERRIDE_PKG.Update_Row',
                     'tot detail taxable amt'||to_char(l_total_detail_taxable_amt));
    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_SUMMARY_OVERRIDE_PKG.Update_Row',
                     'before cancel flag = N');
    END IF;

    IF nvl(p_cancel_flag,'N') = 'N' THEN
     IF nvl(l_num_det_lines,0) = 1 THEN
      IF (g_level_statement >= g_current_runtime_level) THEN
        FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TRL_SUMMARY_OVERRIDE_PKG.Update_Row.BEGIN',
                     'no of det lines 1');
       END IF;
       UPDATE ZX_LINES
          SET UNROUNDED_TAX_AMT = p_tax_amt
        WHERE APPLICATION_ID = p_application_id
        AND ENTITY_CODE = p_entity_code
        AND EVENT_CLASS_CODE = p_event_class_code
        AND TRX_ID = p_trx_id
        AND SUMMARY_TAX_LINE_ID = l_summary_tax_line_id
        AND nvl(cancel_flag,'N') <> 'Y';
     ELSE
       IF nvl(l_total_detail_tax_amt,0) <> 0 THEN
         IF (g_level_statement >= g_current_runtime_level) THEN
           FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TRL_SUMMARY_OVERRIDE_PKG.Update_Row.BEGIN',
                     'tot det tax amt <> 0');
         END IF;
         UPDATE ZX_LINES
          SET UNROUNDED_TAX_AMT = decode(nvl(p_cancel_flag,'N'), 'N', ((unrounded_tax_amt * p_tax_amt)/l_total_detail_tax_amt), 0)
         WHERE APPLICATION_ID = p_application_id
         AND ENTITY_CODE = p_entity_code
         AND EVENT_CLASS_CODE = p_event_class_code
         AND TRX_ID = p_trx_id
         AND SUMMARY_TAX_LINE_ID = l_summary_tax_line_id
         AND nvl(cancel_flag,'N') <> 'Y';
       ELSIF nvl(l_total_detail_taxable_amt,0) <> 0 THEN
         IF (g_level_statement >= g_current_runtime_level) THEN
           FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TRL_SUMMARY_OVERRIDE_PKG.Update_Row.BEGIN',
                     'tot det taxable amt <> 0');
         END IF;
         UPDATE ZX_LINES
          SET UNROUNDED_TAX_AMT = decode(nvl(p_cancel_flag,'N'), 'N', ((unrounded_taxable_amt * p_tax_amt)/l_total_detail_taxable_amt), 0)
         WHERE APPLICATION_ID = p_application_id
         AND ENTITY_CODE = p_entity_code
         AND EVENT_CLASS_CODE = p_event_class_code
         AND TRX_ID = p_trx_id
         AND SUMMARY_TAX_LINE_ID = l_summary_tax_line_id
         AND nvl(cancel_flag,'N') <> 'Y';
       ELSE
         IF (g_level_statement >= g_current_runtime_level) THEN
           FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TRL_SUMMARY_OVERRIDE_PKG.Update_Row.BEGIN',
                     'exception');
         END IF;
         IF p_tax_amt <> 0 THEN
           --RAISE Invalid_unrounded_amt;
         -- Bug 7227477
         IF (g_level_statement >= g_current_runtime_level) THEN
           FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TRL_SUMMARY_OVERRIDE_PKG.Update_Row.BEGIN',
                     'exception -- Tax amount is Not Zero');
         END IF;

         FND_MESSAGE.Set_Name ('ZX','ZX_TAX_AMT_UPDATE_NOT_ALLOWED');
         FND_MSG_PUB.ADD;

         END IF;
       END IF;
     END IF;
    END IF;            -- cancel_flag ='N'

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_SUMMARY_OVERRIDE_PKG.Update_Row',
                     'before manually entered flag = N');
    END IF;
    --Recalculation flag for records in zx_lines
    -- manual entered tax line:
    IF nvl(p_manually_entered_flag,'N') = 'N' THEN
      -- this is system generated tax line :
      IF nvl(p_tax_amt_included_flag,'N') = 'Y' THEN
        IF l_ctrl_ef_ov_cal_line_flag = 'Y' THEN
          UPDATE ZX_LINES
            SET RECALC_REQUIRED_FLAG = 'Y'
            WHERE APPLICATION_ID = p_application_id
            AND ENTITY_CODE      = p_entity_code
            AND EVENT_CLASS_CODE = p_event_class_code
            AND TRX_ID           = p_trx_id
            AND SUMMARY_TAX_LINE_ID = l_summary_tax_line_id
            AND nvl(MANUALLY_ENTERED_FLAG,'N')     = 'N'
            AND nvl(CANCEL_FLAG,'N') = 'N';
        END IF;

      ELSE
        -- tax_amt_included_flag = 'N'
        IF nvl(p_compounding_tax_flag,'N') = 'Y' THEN
          UPDATE ZX_LINES
            SET RECALC_REQUIRED_FLAG = 'Y'
            WHERE APPLICATION_ID = p_application_id
            AND ENTITY_CODE      = p_entity_code
            AND EVENT_CLASS_CODE = p_event_class_code
            AND TRX_ID           = p_trx_id
            AND SUMMARY_TAX_LINE_ID = l_summary_tax_line_id
            AND nvl(COMPOUNDING_DEP_TAX_FLAG,'N') = 'Y'
            AND nvl(CANCEL_FLAG,'N') = 'N';
        END IF;
      END IF;
    END IF;

    UPDATE ZX_LINES
      SET ORIG_TAX_STATUS_ID        = nvl(ORIG_TAX_STATUS_ID, TAX_STATUS_ID),
          ORIG_TAX_STATUS_CODE      = nvl(ORIG_TAX_STATUS_CODE, TAX_STATUS_CODE),
          ORIG_TAX_RATE_ID          = nvl(ORIG_TAX_RATE_ID, TAX_RATE_ID),
          ORIG_TAX_RATE_CODE        = nvl(ORIG_TAX_RATE_CODE, TAX_RATE_CODE),
          ORIG_TAX_RATE             = nvl(ORIG_TAX_RATE, TAX_RATE),
          ORIG_TAXABLE_AMT          = nvl(ORIG_TAXABLE_AMT, TAXABLE_AMT),
          ORIG_TAXABLE_AMT_TAX_CURR = nvl(ORIG_TAXABLE_AMT_TAX_CURR, TAXABLE_AMT_TAX_CURR),
          ORIG_TAX_AMT              = nvl(ORIG_TAX_AMT, TAX_AMT),
          ORIG_TAX_AMT_TAX_CURR     = nvl(ORIG_TAX_AMT_TAX_CURR, TAX_AMT_TAX_CURR),
          SYNC_WITH_PRVDR_FLAG      = decode(p_tax_provider_id, NULL, 'N', 'Y'),
          TAX_STATUS_ID             = p_tax_status_id,
          TAX_STATUS_CODE           = p_tax_status_code,
          TAX_RATE_ID               = p_tax_rate_id,
          TAX_RATE_CODE             = p_tax_rate_code,
          TAX_RATE                  = l_tax_rate,
          --TAX_AMT                   = decode(nvl(p_cancel_flag,'N'), 'N', NULL, 0),
          TAX_AMT                   = decode(nvl(p_cancel_flag,'N'), 'N', NULL, 0),
          TAX_JURISDICTION_CODE = p_tax_jurisdiction_code, -- Bug 8329584
          RECALC_REQUIRED_FLAG      = decode(nvl(p_cancel_flag,'N'), 'N', 'Y', 'N'),
          OVERRIDDEN_FLAG           = decode(nvl(p_cancel_flag,'N'), 'N', p_overridden_flag, 'Y'),
          SELF_ASSESSED_FLAG        = p_self_assessed_flag,
          ORIG_SELF_ASSESSED_FLAG   = decode(ORIG_SELF_ASSESSED_FLAG,NULL,decode(p_self_assessed_flag,SELF_ASSESSED_FLAG,ORIG_SELF_ASSESSED_FLAG,SELF_ASSESSED_FLAG),ORIG_SELF_ASSESSED_FLAG),
          ORIG_TAX_AMT_INCLUDED_FLAG   = decode(ORIG_TAX_AMT_INCLUDED_FLAG,NULL,decode(p_tax_amt_included_flag,TAX_AMT_INCLUDED_FLAG,ORIG_TAX_AMT_INCLUDED_FLAG,TAX_AMT_INCLUDED_FLAG),ORIG_TAX_AMT_INCLUDED_FLAG),
          LAST_MANUAL_ENTRY         = decode(nvl(p_cancel_flag,'N'), 'N', p_last_manual_entry, 'TAX_AMOUNT'),
          CANCEL_FLAG               = nvl(p_cancel_flag,'N'),
          OBJECT_VERSION_NUMBER     = OBJECT_VERSION_NUMBER + 1,
          UNROUNDED_TAX_AMT         = decode(nvl(p_cancel_flag,'N'),'Y',0,UNROUNDED_TAX_AMT),
          PROCESS_FOR_RECOVERY_FLAG = decode(p_reporting_only_flag, 'N', 'Y', 'N'),
          SUMMARY_TAX_LINE_ID       = nvl(l_existing_summary_tax_line_id,l_summary_tax_line_id)  -- new changes
      WHERE APPLICATION_ID = p_application_id
      AND ENTITY_CODE      = p_entity_code
      AND EVENT_CLASS_CODE = p_event_class_code
      AND TRX_ID           = p_trx_id
      AND SUMMARY_TAX_LINE_ID = l_summary_tax_line_id
      AND nvl(cancel_flag,'N') <> 'Y';

    ELSE
      -- Tax Lines are created for variance purposes, no updates will be allowed.
      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_SUMMARY_OVERRIDE_PKG.Update_Row',
                     'Tax Lines are created for variance purposes, no updates will be allowed');
      END IF;
    END IF; --l_allow_update_flag = 'Y'

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_SUMMARY_OVERRIDE_PKG.Update_Row',
                     'Update zx_lines_summary (-)');
    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_SUMMARY_OVERRIDE_PKG.Update_Row.END',
                     'ZX_TRL_SUMMARY_OVERRIDE_PKG: Update_Row (-)');
    END IF;
  END Update_Row;

  PROCEDURE Delete_Row
       (x_rowid                        IN OUT NOCOPY VARCHAR2,
        p_summary_tax_line_id                        NUMBER,
        p_internal_organization_id                   NUMBER,
        p_application_id                             NUMBER,
        p_entity_code                                VARCHAR2,
        p_event_class_code                           VARCHAR2,
        p_trx_id                                     NUMBER,
        p_summary_tax_line_number                    NUMBER,
        p_trx_number                                 VARCHAR2,
        p_applied_from_application_id                NUMBER,
        p_applied_from_evt_class_code                VARCHAR2,--reduced size p_applied_from_event_class_code
        p_applied_from_entity_code                   VARCHAR2,
        p_applied_from_trx_id                        NUMBER,
        p_applied_from_trx_level_type                VARCHAR2,
        p_applied_from_line_id                       NUMBER,
        p_adjusted_doc_application_id                NUMBER,
        p_adjusted_doc_entity_code                   VARCHAR2,
        p_adjusted_doc_evt_class_code                VARCHAR2,--reduced size p_adjusted_doc_event_class_code
        p_adjusted_doc_trx_id                        NUMBER,
        p_adjusted_doc_trx_level_type                VARCHAR2,
        p_applied_to_application_id                  NUMBER,
        p_applied_to_event_class_code                VARCHAR2,
        p_applied_to_entity_code                     VARCHAR2,
        p_applied_to_trx_id                          NUMBER,
        p_applied_to_trx_level_type                  VARCHAR2,
        p_applied_to_line_id                         NUMBER,
        p_tax_exemption_id                           NUMBER,
        p_tax_rate_before_exemption                  NUMBER,
        p_tax_rate_name_before_exempt                VARCHAR2, --reduced size p_tax_rate_name_before_exemption
        p_exempt_rate_modifier                       NUMBER,
        p_exempt_certificate_number                  VARCHAR2,
        p_exempt_reason                              VARCHAR2,
        p_exempt_reason_code                         VARCHAR2,
        p_tax_rate_before_exception                  NUMBER,
        p_tax_rate_name_before_except                VARCHAR2, --reduced size p_tax_rate_name_before_exception
        p_tax_exception_id                           NUMBER,
        p_exception_rate                             NUMBER,
        p_content_owner_id                           NUMBER,
        p_tax_regime_code                            VARCHAR2,
        p_tax                                        VARCHAR2,
        p_tax_status_code                            VARCHAR2,
        p_tax_rate_id                                NUMBER,
        p_tax_rate_code                              VARCHAR2,
        p_tax_rate                                   NUMBER,
        p_tax_amt                                    NUMBER,
        p_tax_amt_tax_curr                           NUMBER,
        p_tax_amt_funcl_curr                         NUMBER,
        p_tax_jurisdiction_code                      VARCHAR2,
        p_total_rec_tax_amt                          NUMBER,
        p_total_rec_tax_amt_func_curr                NUMBER,--reduced size p_total_rec_tax_amt_funcl_curr
        p_total_rec_tax_amt_tax_curr                 NUMBER,
        p_total_nrec_tax_amt                         NUMBER,
        p_total_nrec_tax_amt_func_curr               NUMBER,--reduced size p_total_nrec_tax_amt_funcl_curr
        p_total_nrec_tax_amt_tax_curr                NUMBER,
        p_ledger_id                                  NUMBER,
        p_legal_entity_id                            NUMBER,
        p_establishment_id                           NUMBER,
        p_currency_conversion_date                   DATE,
        p_currency_conversion_type                   VARCHAR2,
        p_currency_conversion_rate                   NUMBER,
        p_summarization_template_id                  NUMBER,
        p_taxable_basis_formula                      VARCHAR2,
        p_tax_calculation_formula                    VARCHAR2,
        p_historical_flag                            VARCHAR2,
        p_cancel_flag                                VARCHAR2,
        p_delete_flag                                VARCHAR2,
        p_tax_amt_included_flag                      VARCHAR2,
        p_compounding_tax_flag                       VARCHAR2,
        p_self_assessed_flag                         VARCHAR2,
        p_overridden_flag                            VARCHAR2,
        p_reporting_only_flag                        VARCHAR2,
        p_assoc_child_frozen_flag                    VARCHAR2,--reduced size p_Associated_Child_Frozen_Flag
        p_copied_from_other_doc_flag                 VARCHAR2,
        p_manually_entered_flag                      VARCHAR2,
        p_mrc_tax_line_flag                          VARCHAR2,
        p_last_manual_entry                          VARCHAR2,
        p_record_type_code                           VARCHAR2,
        p_tax_provider_id                            NUMBER,
        p_tax_only_line_flag                         VARCHAR2,
        p_adjust_tax_amt_flag                        VARCHAR2,
        p_attribute_category                         VARCHAR2,
        p_attribute1                                 VARCHAR2,
        p_attribute2                                 VARCHAR2,
        p_attribute3                                 VARCHAR2,
        p_attribute4                                 VARCHAR2,
        p_attribute5                                 VARCHAR2,
        p_attribute6                                 VARCHAR2,
        p_attribute7                                 VARCHAR2,
        p_attribute8                                 VARCHAR2,
        p_attribute9                                 VARCHAR2,
        p_attribute10                                VARCHAR2,
        p_attribute11                                VARCHAR2,
        p_attribute12                                VARCHAR2,
        p_attribute13                                VARCHAR2,
        p_attribute14                                VARCHAR2,
        p_attribute15                                VARCHAR2,
        p_global_attribute_category                  VARCHAR2,
        p_global_attribute1                          VARCHAR2,
        p_global_attribute2                          VARCHAR2,
        p_global_attribute3                          VARCHAR2,
        p_global_attribute4                          VARCHAR2,
        p_global_attribute5                          VARCHAR2,
        p_global_attribute6                          VARCHAR2,
        p_global_attribute7                          VARCHAR2,
        p_global_attribute8                          VARCHAR2,
        p_global_attribute9                          VARCHAR2,
        p_global_attribute10                         VARCHAR2,
        p_global_attribute11                         VARCHAR2,
        p_global_attribute12                         VARCHAR2,
        p_global_attribute13                         VARCHAR2,
        p_global_attribute14                         VARCHAR2,
        p_global_attribute15                         VARCHAR2,
        p_global_attribute16                         VARCHAR2,
        p_global_attribute17                         VARCHAR2,
        p_global_attribute18                         VARCHAR2,
        p_global_attribute19                         VARCHAR2,
        p_global_attribute20                         VARCHAR2,
        p_object_version_number                      NUMBER,
        p_created_by                                 NUMBER,
        p_creation_date                              DATE,
        p_last_updated_by                            NUMBER,
        p_last_update_date                           DATE,
        p_last_update_login                          NUMBER) IS

  BEGIN
    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_SUMMARY_OVERRIDE_PKG.Delete_Row.BEGIN',
                     'ZX_TRL_SUMMARY_OVERRIDE_PKG: Delete_Row (+)');
    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_SUMMARY_OVERRIDE_PKG.Delete_Row',
                     'Update zx_lines_summary for DELETE (+)');
    END IF;

    UPDATE ZX_LINES_SUMMARY
      SET DELETE_FLAG = 'Y',
          OBJECT_VERSION_NUMBER = NVL(p_object_version_number, OBJECT_VERSION_NUMBER + 1)
      WHERE SUMMARY_TAX_LINE_ID = p_summary_tax_line_id;

    UPDATE ZX_LINES
      SET DELETE_FLAG = 'Y',
          SYNC_WITH_PRVDR_FLAG = DECODE(p_tax_provider_id,
                                        NULL, 'N', 'Y'),
          OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1
      WHERE APPLICATION_ID    = p_application_id
      AND ENTITY_CODE         = p_entity_code
      AND EVENT_CLASS_CODE    = p_event_class_code
      AND TRX_ID              = p_trx_id
      AND SUMMARY_TAX_LINE_ID = p_summary_tax_line_id;

    IF ( SQL%NOTFOUND ) THEN
      RAISE NO_DATA_FOUND;
    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_SUMMARY_OVERRIDE_PKG.Delete_Row',
                     'Update zx_lines_summary for DELETE (-)');
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_SUMMARY_OVERRIDE_PKG.Delete_Row.END',
                     'ZX_TRL_SUMMARY_OVERRIDE_PKG.Delete_Row (-)');
    END IF;

  END Delete_Row;

  PROCEDURE Override_Row
       (p_application_id                    NUMBER,
        p_entity_code                       VARCHAR2,
        p_event_class_code                  VARCHAR2,
        p_trx_id                            NUMBER,
        p_event_id                          NUMBER,
        p_summary_tax_line_id               NUMBER) IS

  BEGIN
    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_SUMMARY_OVERRIDE_PKG.Override_Row.BEGIN',
                     'ZX_TRL_SUMMARY_OVERRIDE_PKG: Override_Row (+)');

    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_SUMMARY_OVERRIDE_PKG.Override_Row',
                     'Update zx_lines_det_factors (+)');
    END IF;

    UPDATE ZX_LINES_DET_FACTORS
      SET EVENT_ID = p_event_id
      WHERE APPLICATION_ID = p_application_id
        AND ENTITY_CODE      = p_entity_code
        AND EVENT_CLASS_CODE = p_event_class_code
        AND TRX_ID           = p_trx_id
        AND (TRX_LINE_ID, TRX_LEVEL_TYPE)
           IN (SELECT TRX_LINE_ID, TRX_LEVEL_TYPE
                 FROM ZX_LINES
                 WHERE APPLICATION_ID    = p_application_id
                   AND ENTITY_CODE         = p_entity_code
                   AND EVENT_CLASS_CODE    = p_event_class_code
                   AND TRX_ID              = p_trx_id
                   AND SUMMARY_TAX_LINE_ID = p_summary_tax_line_id);

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_SUMMARY_OVERRIDE_PKG.Override_Row',
                     'Update zx_lines_det_factors (-)');
    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_SUMMARY_OVERRIDE_PKG.Override_Row.END',
                     'ZX_TRL_SUMMARY_OVERRIDE_PKG: Override_Row (-)');
    END IF;

    --commit;
  END Override_Row;

  PROCEDURE Check_Unique
       (p_internal_organization_id                   NUMBER,
        p_application_id                             NUMBER,
        p_entity_code                                VARCHAR2,
        p_event_class_code                           VARCHAR2,
        p_trx_id                                     NUMBER,
        p_tax_regime_code                            VARCHAR2,
        p_tax                                        VARCHAR2,
        p_tax_status_code                            VARCHAR2,
        p_tax_rate_code                              VARCHAR2) IS

    l_key_check NUMBER;
    debug_info             VARCHAR2(100);

  BEGIN

    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_SUMMARY_OVERRIDE_PKG.Check_Unique',
                     'Validation for logical primary key (+)');
    END IF;

    BEGIN

      --User would be prevented from entering a manual tax line with the same
      --tax if such a tax line already exists for the transaction line
      --Validation for logical primary key
      SELECT count(*)
      INTO l_key_check
      FROM ZX_LINES_SUMMARY LS
      WHERE APPLICATION_ID         = p_application_id
      AND ENTITY_CODE              = p_entity_code
      AND EVENT_CLASS_CODE         = p_event_class_code
      AND INTERNAL_ORGANIZATION_ID = p_internal_organization_id
      AND TRX_ID                   = p_trx_id
      AND TAX_REGIME_CODE          = p_tax_regime_code
      AND TAX                      = p_tax
      AND TAX_STATUS_CODE          = p_tax_status_code
      AND TAX_RATE_CODE            = p_tax_rate_code;

      IF l_key_check >= 1 THEN
        FND_MESSAGE.SET_TOKEN('Error:', 'CANNOT CREATE RECORD' );
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;

    END;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_SUMMARY_OVERRIDE_PKG.Check_Unique',
                     'Validation for logical primary key (-)');
    END IF;

  END Check_Unique;

  PROCEDURE lock_summ_tax_lines_for_doc
  			(p_application_id			IN NUMBER,
  			 p_entity_code        IN VARCHAR2,
  			 p_event_class_code   IN VARCHAR2,
  			 p_trx_id             IN NUMBER,
			   x_return_status      OUT NOCOPY VARCHAR2,
			   x_error_buffer       OUT NOCOPY VARCHAR2)  IS

		l_return_status          VARCHAR2(1000);

  /*Cursor to Lock the tax lines for the entire document*/
  CURSOR lock_sum_tax_lines_for_doc_csr(c_application_id NUMBER,
  			 c_event_class_code VARCHAR2,
  			 c_entity_code VARCHAR2,
  			 c_trx_id NUMBER) IS
      SELECT *
        FROM ZX_LINES_SUMMARY
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
		                 'ZX.PLSQL.ZX_TRL_SUMMARY_OVERRIDE_PKG.lock_summ_tax_lines_for_doc.BEGIN',
		                 'ZX_TRL_SUMMARY_OVERRIDE_PKG: lock_summ_tax_lines_for_doc (+)');
    END IF;

		OPEN lock_sum_tax_lines_for_doc_csr(p_application_id,
																				p_event_class_code,
																				p_entity_code,
																				p_trx_id);
		CLOSE lock_sum_tax_lines_for_doc_csr;

		IF (g_level_procedure >= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_procedure,
		                 'ZX.PLSQL.ZX_TRL_SUMMARY_OVERRIDE_PKG.lock_summ_tax_lines_for_doc.END',
		                 'ZX_TRL_SUMMARY_OVERRIDE_PKG: lock_summ_tax_lines_for_doc (-)');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

      FND_MESSAGE.SET_NAME('ZX','ZX_UNEXPECTED_ERROR');
      FND_MSG_PUB.Add;

      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_SUMMARY_OVERRIDE_PKG.lock_summ_tax_lines_for_doc',
                       'Exception:' ||x_error_buffer);
      END IF;
  END lock_summ_tax_lines_for_doc;



END ZX_TRL_SUMMARY_OVERRIDE_PKG;

/
