--------------------------------------------------------
--  DDL for Package Body ZX_TRL_DISTRIBUTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_TRL_DISTRIBUTIONS_PKG" AS
/* $Header: zxridistribnpkgb.pls 120.40.12010000.1 2008/07/28 13:36:06 appldev ship $ */

  g_current_runtime_level NUMBER;
  g_level_statement       CONSTANT  NUMBER := FND_LOG.LEVEL_STATEMENT;
  g_level_procedure       CONSTANT  NUMBER := FND_LOG.LEVEL_PROCEDURE;
  g_level_event           CONSTANT  NUMBER := FND_LOG.LEVEL_EVENT;
  g_level_unexpected      CONSTANT  NUMBER := FND_LOG.LEVEL_UNEXPECTED;

  PROCEDURE Insert_Row
       (x_rowid                        IN OUT NOCOPY VARCHAR2,
        p_rec_nrec_tax_dist_id                       NUMBER,
        p_application_id                             NUMBER,
        p_entity_code                                VARCHAR2,
        p_event_class_code                           VARCHAR2,
        p_event_type_code                            VARCHAR2,
        p_trx_id                                     NUMBER,
        p_trx_number                                 VARCHAR2,
        p_trx_line_id                                NUMBER,
        p_trx_line_number                            NUMBER,
        p_tax_line_id                                NUMBER,
        p_tax_line_number                            NUMBER,
        p_trx_line_dist_id                           NUMBER,
        p_trx_level_type                             VARCHAR2,
        p_item_dist_number                           NUMBER,
        p_rec_nrec_tax_dist_number                   NUMBER,
        p_rec_nrec_rate                              NUMBER,
        p_recoverable_flag                           VARCHAR2,
        p_rec_nrec_tax_amt                           NUMBER,
        p_tax_event_class_code                       VARCHAR2,
        p_tax_event_type_code                        VARCHAR2,
        p_content_owner_id                           NUMBER,
        p_tax_regime_id                              NUMBER,
        p_tax_regime_code                            VARCHAR2,
        p_tax_id                                     NUMBER,
        p_tax                                        VARCHAR2,
        p_tax_status_id                              NUMBER,
        p_tax_status_code                            VARCHAR2,
        p_tax_rate_id                                NUMBER,
        p_tax_rate_code                              VARCHAR2,
        p_tax_rate                                   NUMBER,
        p_inclusive_flag                             VARCHAR2,
        p_recovery_type_id                           NUMBER,
        p_recovery_type_code                         VARCHAR2,
        p_recovery_rate_id                           NUMBER,
        p_recovery_rate_code                         VARCHAR2,
        p_rec_type_rule_flag                         VARCHAR2,
        p_new_rec_rate_code_flag                     VARCHAR2,
        p_reverse_flag                               VARCHAR2,
        p_historical_flag                            VARCHAR2,
        p_reversed_tax_dist_id                       NUMBER,
        p_rec_nrec_tax_amt_tax_curr                  NUMBER,
        p_rec_nrec_tax_amt_funcl_curr                NUMBER,
        p_intended_use                               VARCHAR2,
        p_project_id                                 NUMBER,
        p_task_id                                    NUMBER,
        p_award_id                                   NUMBER,
        p_expenditure_type                           VARCHAR2,
        p_expenditure_organization_id                NUMBER,
        p_expenditure_item_date                      DATE,
        p_rec_rate_det_rule_flag                     VARCHAR2,
        p_ledger_id                                  NUMBER,
        p_summary_tax_line_id                        NUMBER,
        p_record_type_code                           VARCHAR2,
        p_currency_conversion_date                   DATE,
        p_currency_conversion_type                   VARCHAR2,
        p_currency_conversion_rate                   NUMBER,
        p_tax_currency_conversion_date               DATE,
        p_tax_currency_conversion_type               VARCHAR2,
        p_tax_currency_conversion_rate               NUMBER,
        p_trx_currency_code                          VARCHAR2,
        p_tax_currency_code                          VARCHAR2,
        p_trx_line_dist_qty                          NUMBER,
        p_ref_doc_trx_line_dist_qty                  NUMBER,
        p_price_diff                                 NUMBER,
        p_qty_diff                                   NUMBER,
        p_per_trx_curr_unit_nr_amt                   NUMBER,
        p_ref_per_trx_curr_unit_nr_amt               NUMBER,
        p_ref_doc_curr_conv_rate                     NUMBER,
        p_unit_price                                 NUMBER,
        p_ref_doc_unit_price                         NUMBER,
        p_per_unit_nrec_tax_amt                      NUMBER,
        p_ref_doc_per_unit_nrec_tax_am               NUMBER,
        p_rate_tax_factor                            NUMBER,
        p_tax_apportionment_flag                     VARCHAR2,
        p_trx_line_dist_amt                          NUMBER,
        p_trx_line_dist_tax_amt                      NUMBER,
        p_orig_rec_nrec_rate                         NUMBER,
        p_orig_rec_rate_code                         VARCHAR2,
        p_orig_rec_nrec_tax_amt                      NUMBER,
        p_orig_rec_nrec_tax_amt_tax_cu               NUMBER,
        p_account_ccid                               NUMBER,
        p_account_string                             VARCHAR2,
        p_unrounded_rec_nrec_tax_amt                 NUMBER,
        p_applicability_result_id                    NUMBER,
        p_rec_rate_result_id                         NUMBER,
        p_backward_compatibility_flag                VARCHAR2,
        p_overridden_flag                            VARCHAR2,
        p_self_assessed_flag                         VARCHAR2,
        p_freeze_flag                                VARCHAR2,
        p_posting_flag                               VARCHAR2,
        p_gl_date                                    DATE,
        p_ref_doc_application_id                     NUMBER,
        p_ref_doc_entity_code                        VARCHAR2,
        p_ref_doc_event_class_code                   VARCHAR2,
        p_ref_doc_trx_id                             NUMBER,
        p_ref_doc_trx_level_type                     VARCHAR2,
        p_ref_doc_line_id                            NUMBER,
        p_ref_doc_dist_id                            NUMBER,
        p_minimum_accountable_unit                   NUMBER,
        p_precision                                  NUMBER,
        p_rounding_rule_code                         VARCHAR2,
        p_taxable_amt                                NUMBER,
        p_taxable_amt_tax_curr                       NUMBER,
        p_taxable_amt_funcl_curr                     NUMBER,
        p_tax_only_line_flag                         VARCHAR2,
        p_unrounded_taxable_amt                      NUMBER,
        p_legal_entity_id                            NUMBER,
        p_prd_tax_amt                                NUMBER,
        p_prd_tax_amt_tax_curr                       NUMBER,
        p_prd_tax_amt_funcl_curr                     NUMBER,
        p_prd_total_tax_amt                          NUMBER,
        p_prd_total_tax_amt_tax_curr                 NUMBER,
        p_prd_total_tax_amt_funcl_curr               NUMBER,
        p_applied_from_tax_dist_id                   NUMBER,
        p_appl_to_doc_curr_conv_rate                 NUMBER, --p_appl_to_doc_curr_conv_rate
        p_adjusted_doc_tax_dist_id                   NUMBER,
        p_func_curr_rounding_adjust                  NUMBER,
        p_tax_apportionment_line_num                 NUMBER,
        p_last_manual_entry                          VARCHAR2,
        p_ref_doc_tax_dist_id                        NUMBER,
        p_mrc_tax_dist_flag                          VARCHAR2,
        p_mrc_link_to_tax_dist_id                    NUMBER,
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
        p_orig_ap_chrg_dist_num                      NUMBER,
        p_orig_ap_chrg_dist_id                       NUMBER,
        p_orig_ap_tax_dist_num                       NUMBER,
        p_orig_ap_tax_dist_id                        NUMBER,
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
                     'ZX.PLSQL.ZX_TRL_DISTRIBUTIONS_PKG.Insert_Row.BEGIN',
                     'ZX_TRL_DISTRIBUTIONS_PKG: Insert_Row (+)');
    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_DISTRIBUTIONS_PKG.Insert_Row.END',
                     'ZX_TRL_DISTRIBUTIONS_PKG: Insert_Row (-)');
    END IF;

  END Insert_Row;

  PROCEDURE Lock_Row
       (x_rowid                        IN OUT NOCOPY VARCHAR2,
        p_rec_nrec_tax_dist_id                       NUMBER,
        p_application_id                             NUMBER,
        p_entity_code                                VARCHAR2,
        p_event_class_code                           VARCHAR2,
        p_event_type_code                            VARCHAR2,
        p_trx_id                                     NUMBER,
        p_trx_number                                 VARCHAR2,
        p_trx_line_id                                NUMBER,
        p_trx_line_number                            NUMBER,
        p_tax_line_id                                NUMBER,
        p_tax_line_number                            NUMBER,
        p_trx_line_dist_id                           NUMBER,
        p_trx_level_type                             VARCHAR2,
        p_item_dist_number                           NUMBER,
        p_rec_nrec_tax_dist_number                   NUMBER,
        p_rec_nrec_rate                              NUMBER,
        p_recoverable_flag                           VARCHAR2,
        p_rec_nrec_tax_amt                           NUMBER,
        p_tax_event_class_code                       VARCHAR2,
        p_tax_event_type_code                        VARCHAR2,
        p_content_owner_id                           NUMBER,
        p_tax_regime_id                              NUMBER,
        p_tax_regime_code                            VARCHAR2,
        p_tax_id                                     NUMBER,
        p_tax                                        VARCHAR2,
        p_tax_status_id                              NUMBER,
        p_tax_status_code                            VARCHAR2,
        p_tax_rate_id                                NUMBER,
        p_tax_rate_code                              VARCHAR2,
        p_tax_rate                                   NUMBER,
        p_inclusive_flag                             VARCHAR2,
        p_recovery_type_id                           NUMBER,
        p_recovery_type_code                         VARCHAR2,
        p_recovery_rate_id                           NUMBER,
        p_recovery_rate_code                         VARCHAR2,
        p_rec_type_rule_flag                         VARCHAR2,
        p_new_rec_rate_code_flag                     VARCHAR2,
        p_reverse_flag                               VARCHAR2,
        p_historical_flag                            VARCHAR2,
        p_reversed_tax_dist_id                       NUMBER,
        p_rec_nrec_tax_amt_tax_curr                  NUMBER,
        p_rec_nrec_tax_amt_funcl_curr                NUMBER,
        p_intended_use                               VARCHAR2,
        p_project_id                                 NUMBER,
        p_task_id                                    NUMBER,
        p_award_id                                   NUMBER,
        p_expenditure_type                           VARCHAR2,
        p_expenditure_organization_id                NUMBER,
        p_expenditure_item_date                      DATE,
        p_rec_rate_det_rule_flag                     VARCHAR2,
        p_ledger_id                                  NUMBER,
        p_summary_tax_line_id                        NUMBER,
        p_record_type_code                           VARCHAR2,
        p_currency_conversion_date                   DATE,
        p_currency_conversion_type                   VARCHAR2,
        p_currency_conversion_rate                   NUMBER,
        p_tax_currency_conversion_date               DATE,
        p_tax_currency_conversion_type               VARCHAR2,
        p_tax_currency_conversion_rate               NUMBER,
        p_trx_currency_code                          VARCHAR2,
        p_tax_currency_code                          VARCHAR2,
        p_trx_line_dist_qty                          NUMBER,
        p_ref_doc_trx_line_dist_qty                  NUMBER,
        p_price_diff                                 NUMBER,
        p_qty_diff                                   NUMBER,
        p_per_trx_curr_unit_nr_amt                   NUMBER,
        p_ref_per_trx_curr_unit_nr_amt               NUMBER,
        p_ref_doc_curr_conv_rate                     NUMBER,
        p_unit_price                                 NUMBER,
        p_ref_doc_unit_price                         NUMBER,
        p_per_unit_nrec_tax_amt                      NUMBER,
        p_ref_doc_per_unit_nrec_tax_am               NUMBER,
        p_rate_tax_factor                            NUMBER,
        p_tax_apportionment_flag                     VARCHAR2,
        p_trx_line_dist_amt                          NUMBER,
        p_trx_line_dist_tax_amt                      NUMBER,
        p_orig_rec_nrec_rate                         NUMBER,
        p_orig_rec_rate_code                         VARCHAR2,
        p_orig_rec_nrec_tax_amt                      NUMBER,
        p_orig_rec_nrec_tax_amt_tax_cu               NUMBER,
        p_account_ccid                               NUMBER,
        p_account_string                             VARCHAR2,
        p_unrounded_rec_nrec_tax_amt                 NUMBER,
        p_applicability_result_id                    NUMBER,
        p_rec_rate_result_id                         NUMBER,
        p_backward_compatibility_flag                VARCHAR2,
        p_overridden_flag                            VARCHAR2,
        p_self_assessed_flag                         VARCHAR2,
        p_freeze_flag                                VARCHAR2,
        p_posting_flag                               VARCHAR2,
        p_gl_date                                    DATE,
        p_ref_doc_application_id                     NUMBER,
        p_ref_doc_entity_code                        VARCHAR2,
        p_ref_doc_event_class_code                   VARCHAR2,
        p_ref_doc_trx_id                             NUMBER,
        p_ref_doc_trx_level_type                     VARCHAR2,
        p_ref_doc_line_id                            NUMBER,
        p_ref_doc_dist_id                            NUMBER,
        p_minimum_accountable_unit                   NUMBER,
        p_precision                                  NUMBER,
        p_rounding_rule_code                         VARCHAR2,
        p_taxable_amt                                NUMBER,
        p_taxable_amt_tax_curr                       NUMBER,
        p_taxable_amt_funcl_curr                     NUMBER,
        p_tax_only_line_flag                         VARCHAR2,
        p_unrounded_taxable_amt                      NUMBER,
        p_legal_entity_id                            NUMBER,
        p_prd_tax_amt                                NUMBER,
        p_prd_tax_amt_tax_curr                       NUMBER,
        p_prd_tax_amt_funcl_curr                     NUMBER,
        p_prd_total_tax_amt                          NUMBER,
        p_prd_total_tax_amt_tax_curr                 NUMBER,
        p_prd_total_tax_amt_funcl_curr               NUMBER,
        p_applied_from_tax_dist_id                   NUMBER,
        p_appl_to_doc_curr_conv_rate                 NUMBER, --p_appl_to_doc_curr_conv_rate
        p_adjusted_doc_tax_dist_id                   NUMBER,
        p_func_curr_rounding_adjust                  NUMBER,
        p_tax_apportionment_line_num                 NUMBER,
        p_last_manual_entry                          VARCHAR2,
        p_ref_doc_tax_dist_id                        NUMBER,
        p_mrc_tax_dist_flag                          VARCHAR2,
        p_mrc_link_to_tax_dist_id                    NUMBER,
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
        p_orig_ap_chrg_dist_num                      NUMBER,
        p_orig_ap_chrg_dist_id                       NUMBER,
        p_orig_ap_tax_dist_num                       NUMBER,
        p_orig_ap_tax_dist_id                        NUMBER,
        p_object_version_number                      NUMBER,
        p_created_by                                 NUMBER,
        p_creation_date                              DATE,
        p_last_updated_by                            NUMBER,
        p_last_update_date                           DATE,
        p_last_update_login                          NUMBER) IS

    CURSOR dist_csr IS
      SELECT REC_NREC_TAX_DIST_ID,
             APPLICATION_ID,
             ENTITY_CODE,
             EVENT_CLASS_CODE,
             EVENT_TYPE_CODE,
             TRX_ID,
             TRX_NUMBER,
             TRX_LINE_ID,
             TRX_LINE_NUMBER,
             TAX_LINE_ID,
             TAX_LINE_NUMBER,
             TRX_LINE_DIST_ID,
             TRX_LEVEL_TYPE,
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
             GL_DATE,
             REF_DOC_APPLICATION_ID,
             REF_DOC_ENTITY_CODE,
             REF_DOC_EVENT_CLASS_CODE,
             REF_DOC_TRX_ID,
             REF_DOC_LINE_ID,
             REF_DOC_DIST_ID,
             REF_DOC_TRX_LEVEL_TYPE,
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
             MRC_TAX_DIST_FLAG,
             MRC_LINK_TO_TAX_DIST_ID,
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
             ORIG_AP_CHRG_DIST_NUM,
             ORIG_AP_CHRG_DIST_ID,
             ORIG_AP_TAX_DIST_NUM,
             ORIG_AP_TAX_DIST_ID,
             OBJECT_VERSION_NUMBER,
             CREATED_BY,
             CREATION_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATE_LOGIN
        FROM ZX_REC_NREC_DIST
        WHERE REC_NREC_TAX_DIST_ID = p_rec_nrec_tax_dist_id;

    Recinfo dist_csr%ROWTYPE;

  BEGIN
    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_DISTRIBUTIONS_PKG.Lock_Row.BEGIN',
                     'ZX_TRL_DISTRIBUTIONS_PKG: Lock_Row (+)');
    END IF;

    OPEN dist_csr;
    FETCH dist_csr
    INTO Recinfo;

    IF (dist_csr%NOTFOUND) THEN
      CLOSE dist_csr;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    END IF;

    CLOSE dist_csr;

  IF ((Recinfo.REC_NREC_TAX_DIST_ID     = p_rec_nrec_tax_dist_id) AND
      (Recinfo.APPLICATION_ID           = p_application_id) AND
      (Recinfo.ENTITY_CODE              = p_entity_code) AND
      (Recinfo.EVENT_CLASS_CODE         = p_event_class_code) AND
      ((Recinfo.EVENT_TYPE_CODE = p_event_type_code) OR
       ((Recinfo.EVENT_TYPE_CODE IS NULL) AND
        (p_event_type_code IS NULL))) AND
      (Recinfo.TRX_ID                   = p_trx_id) AND
      ((Recinfo.TRX_NUMBER = p_trx_number) OR
       ((Recinfo.TRX_NUMBER IS NULL) AND
        (p_trx_number IS NULL))) AND
      (Recinfo.TRX_LINE_ID              = p_trx_line_id) AND
      ((Recinfo.TRX_LINE_NUMBER = p_trx_line_number) OR
       ((Recinfo.TRX_LINE_NUMBER IS NULL) AND
        (p_trx_line_number IS NULL))) AND
      (Recinfo.TAX_LINE_ID              = p_tax_line_id) AND
      (Recinfo.TAX_LINE_NUMBER          = p_tax_line_number) AND
      (Recinfo.TRX_LINE_DIST_ID         = p_trx_line_dist_id) AND
      (Recinfo.TRX_LEVEL_TYPE           = p_trx_level_type) AND
      ((Recinfo.ITEM_DIST_NUMBER = p_item_dist_number) OR
       ((Recinfo.ITEM_DIST_NUMBER IS NULL) AND
        (p_item_dist_number IS NULL))) AND
      (Recinfo.REC_NREC_TAX_DIST_NUMBER = p_rec_nrec_tax_dist_number) AND
      (Recinfo.REC_NREC_RATE            = p_rec_nrec_rate) AND
      (Recinfo.RECOVERABLE_FLAG         = p_recoverable_flag) AND
      (Recinfo.REC_NREC_TAX_AMT         = p_rec_nrec_tax_amt)  AND
      ((Recinfo.TAX_EVENT_CLASS_CODE = p_tax_event_class_code) OR
       ((Recinfo.TAX_EVENT_CLASS_CODE IS NULL) AND
        (p_tax_event_class_code IS NULL))) AND
      ((Recinfo.TAX_EVENT_TYPE_CODE = p_tax_event_type_code) OR
       ((Recinfo.TAX_EVENT_TYPE_CODE IS NULL) AND
        (p_tax_event_type_code IS NULL))) AND
      ((Recinfo.CONTENT_OWNER_ID = p_content_owner_id) OR
       ((Recinfo.CONTENT_OWNER_ID IS NULL) AND
        (p_content_owner_id IS NULL))) AND
      ((Recinfo.TAX_REGIME_ID = p_tax_regime_id) OR
       ((Recinfo.TAX_REGIME_ID IS NULL) AND
        (p_tax_regime_id IS NULL))) AND
      ((Recinfo.TAX_REGIME_CODE = p_tax_regime_code) OR
       ((Recinfo.TAX_REGIME_CODE IS NULL) AND
        (p_tax_regime_code IS NULL))) AND
      ((Recinfo.TAX_ID = p_tax_id) OR
       ((Recinfo.TAX_ID IS NULL) AND
        (p_tax_id IS NULL))) AND
      ((Recinfo.TAX = p_tax) OR
       ((Recinfo.TAX IS NULL) AND
        (p_tax IS NULL))) AND
      ((Recinfo.TAX_STATUS_ID = p_tax_status_id) OR
       ((Recinfo.TAX_STATUS_ID IS NULL) AND
        (p_tax_status_id IS NULL))) AND
      ((Recinfo.TAX_STATUS_CODE = p_tax_status_code) OR
       ((Recinfo.TAX_STATUS_CODE IS NULL) AND
        (p_tax_status_code IS NULL))) AND
      ((Recinfo.TAX_RATE_ID = p_tax_rate_id) OR
       ((Recinfo.TAX_RATE_ID IS NULL) AND
        (p_tax_rate_id  IS NULL))) AND
      ((Recinfo.TAX_RATE_CODE = p_tax_rate_code) OR
       ((Recinfo.TAX_RATE_CODE IS NULL) AND
        (p_tax_rate_code IS NULL))) AND
      ((Recinfo.TAX_RATE = p_tax_rate) OR
       ((Recinfo.TAX_RATE IS NULL) AND
        (p_tax_rate IS NULL))) AND
      ((Recinfo.INCLUSIVE_FLAG = p_inclusive_flag) OR
       ((Recinfo.INCLUSIVE_FLAG IS NULL) AND
        (p_inclusive_flag IS NULL))) AND
      ((Recinfo.RECOVERY_TYPE_ID = p_recovery_type_id) OR
       ((Recinfo.RECOVERY_TYPE_ID IS NULL) AND
        (p_recovery_type_id IS NULL))) AND
      ((Recinfo.RECOVERY_TYPE_CODE = p_recovery_type_code) OR
       ((Recinfo.RECOVERY_TYPE_CODE IS NULL) AND
        (p_recovery_type_code IS NULL))) AND
      ((Recinfo.RECOVERY_RATE_ID = p_recovery_rate_id) OR
       ((Recinfo.RECOVERY_RATE_ID IS NULL) AND
        (p_recovery_rate_id IS NULL))) AND
      ((Recinfo.RECOVERY_RATE_CODE = p_recovery_rate_code) OR
       ((Recinfo.RECOVERY_RATE_CODE IS NULL) AND
        (p_recovery_rate_code IS NULL))) AND
      ((Recinfo.REC_TYPE_RULE_FLAG = p_rec_type_rule_flag) OR
       ((Recinfo.REC_TYPE_RULE_FLAG IS NULL) AND
        (p_rec_type_rule_flag IS NULL))) AND
      ((Recinfo.NEW_REC_RATE_CODE_FLAG = p_new_rec_rate_code_flag) OR
       ((Recinfo.NEW_REC_RATE_CODE_FLAG IS NULL) AND
        (p_new_rec_rate_code_flag IS NULL))) AND
      ((Recinfo.REVERSE_FLAG = p_reverse_flag) OR
       ((Recinfo.REVERSE_FLAG IS NULL) AND
        (p_reverse_flag IS NULL))) AND
      ((Recinfo.HISTORICAL_FLAG = p_historical_flag) OR
       ((Recinfo.HISTORICAL_FLAG IS NULL) AND
        (p_historical_flag IS NULL))) AND
      ((Recinfo.REVERSED_TAX_DIST_ID = p_reversed_tax_dist_id) OR
       ((Recinfo.REVERSED_TAX_DIST_ID IS NULL) AND
        (p_reversed_tax_dist_id IS NULL))) AND
      ((Recinfo.REC_NREC_TAX_AMT_TAX_CURR = p_rec_nrec_tax_amt_tax_curr) OR
       ((Recinfo.REC_NREC_TAX_AMT_TAX_CURR IS NULL) AND
        (p_rec_nrec_tax_amt_tax_curr IS NULL))) AND
      ((Recinfo.REC_NREC_TAX_AMT_FUNCL_CURR = p_rec_nrec_tax_amt_funcl_curr) OR
       ((Recinfo.REC_NREC_TAX_AMT_FUNCL_CURR IS NULL) AND
        (p_rec_nrec_tax_amt_funcl_curr IS NULL))) AND
      ((Recinfo.INTENDED_USE = p_intended_use) OR
       ((Recinfo.INTENDED_USE IS NULL) AND
        (p_intended_use  IS NULL))) AND
      ((Recinfo.PROJECT_ID = p_project_id) OR
        ((Recinfo.PROJECT_ID IS NULL) AND
         (p_project_id	 IS NULL))) AND
      ((Recinfo.TASK_ID = p_task_id) OR
       ((Recinfo.TASK_ID IS NULL) AND
        (p_task_id IS NULL))) AND
      ((Recinfo.AWARD_ID = p_award_id) OR
       ((Recinfo.AWARD_ID IS NULL) AND
        (p_award_id IS NULL))) AND
      ((Recinfo.EXPENDITURE_TYPE = p_expenditure_type) OR
       ((Recinfo.EXPENDITURE_TYPE IS NULL) AND
        (p_expenditure_type IS NULL))) AND
      ((Recinfo.EXPENDITURE_ORGANIZATION_ID = p_expenditure_organization_id) OR
       ((Recinfo.EXPENDITURE_ORGANIZATION_ID IS NULL) AND
        (p_expenditure_organization_id IS NULL))) AND
      ((Recinfo.EXPENDITURE_ITEM_DATE = p_expenditure_item_date) OR
       ((Recinfo.EXPENDITURE_ITEM_DATE IS NULL) AND
        (p_expenditure_item_date IS NULL))) AND
      ((Recinfo.REC_RATE_DET_RULE_FLAG = p_rec_rate_det_rule_flag) OR
       ((Recinfo.REC_RATE_DET_RULE_FLAG IS NULL) AND
        (p_rec_rate_det_rule_flag IS NULL))) AND
      ((Recinfo.LEDGER_ID = p_ledger_id) OR
       ((Recinfo.LEDGER_ID IS NULL) AND
        (p_ledger_id  IS NULL))) AND
      ((Recinfo.SUMMARY_TAX_LINE_ID = p_summary_tax_line_id) OR
       ((Recinfo.SUMMARY_TAX_LINE_ID IS NULL) AND
        (p_summary_tax_line_id IS NULL))) AND
      ((Recinfo.RECORD_TYPE_CODE = p_record_type_code) OR
       ((Recinfo.RECORD_TYPE_CODE IS NULL) AND
        (p_record_type_code IS NULL))) AND
      ((Recinfo.CURRENCY_CONVERSION_DATE = p_currency_conversion_date) OR
       ((Recinfo.CURRENCY_CONVERSION_DATE IS NULL) AND
        (p_currency_conversion_date  IS NULL))) AND
      ((Recinfo.CURRENCY_CONVERSION_TYPE = p_currency_conversion_type) OR
       ((Recinfo.CURRENCY_CONVERSION_TYPE IS NULL) AND
        (p_currency_conversion_type  IS NULL))) AND
      ((Recinfo.CURRENCY_CONVERSION_RATE = p_currency_conversion_rate) OR
       ((Recinfo.CURRENCY_CONVERSION_RATE IS NULL) AND
        (p_currency_conversion_rate  IS NULL))) AND
      ((Recinfo.TAX_CURRENCY_CONVERSION_DATE = p_tax_currency_conversion_date) OR
       ((Recinfo.TAX_CURRENCY_CONVERSION_DATE IS NULL) AND
        (p_tax_currency_conversion_date  IS NULL))) AND
      ((Recinfo.TAX_CURRENCY_CONVERSION_TYPE = p_tax_currency_conversion_type) OR
       ((Recinfo.TAX_CURRENCY_CONVERSION_TYPE IS NULL) AND
        (p_tax_currency_conversion_type  IS NULL))) AND
      ((Recinfo.TAX_CURRENCY_CONVERSION_RATE = p_tax_currency_conversion_rate) OR
       ((Recinfo.TAX_CURRENCY_CONVERSION_RATE IS NULL) AND
        (p_tax_currency_conversion_rate  IS NULL))) AND
      ((Recinfo.TRX_CURRENCY_CODE = p_trx_currency_code) OR
       ((Recinfo.TRX_CURRENCY_CODE IS NULL) AND
        (p_trx_currency_code IS NULL))) AND
      ((Recinfo.TAX_CURRENCY_CODE = p_tax_currency_code) OR
       ((Recinfo.TAX_CURRENCY_CODE IS NULL) AND
        (p_tax_currency_code IS NULL))) AND
      ((Recinfo.TRX_LINE_DIST_QTY = p_TRX_LINE_DIST_QTY) OR
       ((Recinfo.TRX_LINE_DIST_QTY IS NULL) AND
        (p_TRX_LINE_DIST_QTY IS NULL))) AND
      ((Recinfo.REF_DOC_TRX_LINE_DIST_QTY = p_REF_DOC_TRX_LINE_DIST_QTY) OR
       ((Recinfo.REF_DOC_TRX_LINE_DIST_QTY IS NULL) AND
        (p_REF_DOC_TRX_LINE_DIST_QTY IS NULL))) AND
      ((Recinfo.PRICE_DIFF = p_PRICE_DIFF) OR
       ((Recinfo.PRICE_DIFF IS NULL) AND
        (p_PRICE_DIFF IS NULL))) AND
      ((Recinfo.QTY_DIFF = p_QTY_DIFF) OR
       ((Recinfo.QTY_DIFF IS NULL) AND
        (p_QTY_DIFF IS NULL))) AND
      ((Recinfo.PER_TRX_CURR_UNIT_NR_AMT = p_PER_TRX_CURR_UNIT_NR_AMT) OR
       ((Recinfo.PER_TRX_CURR_UNIT_NR_AMT IS NULL) AND
        (p_PER_TRX_CURR_UNIT_NR_AMT IS NULL))) AND
      ((Recinfo.REF_PER_TRX_CURR_UNIT_NR_AMT = p_REF_PER_TRX_CURR_UNIT_NR_AMT) OR
       ((Recinfo.REF_PER_TRX_CURR_UNIT_NR_AMT IS NULL) AND
        (p_REF_PER_TRX_CURR_UNIT_NR_AMT IS NULL))) AND
      ((Recinfo.REF_DOC_CURR_CONV_RATE = p_REF_DOC_CURR_CONV_RATE) OR
       ((Recinfo.REF_DOC_CURR_CONV_RATE IS NULL) AND
        (p_REF_DOC_CURR_CONV_RATE IS NULL))) AND
      ((Recinfo.UNIT_PRICE = p_UNIT_PRICE) OR
       ((Recinfo.UNIT_PRICE IS NULL) AND
        (p_UNIT_PRICE IS NULL))) AND
      ((Recinfo.REF_DOC_UNIT_PRICE = p_REF_DOC_UNIT_PRICE) OR
       ((Recinfo.REF_DOC_UNIT_PRICE IS NULL) AND
        (p_REF_DOC_UNIT_PRICE IS NULL))) AND
      ((Recinfo.PER_UNIT_NREC_TAX_AMT = p_PER_UNIT_NREC_TAX_AMT) OR
       ((Recinfo.PER_UNIT_NREC_TAX_AMT IS NULL) AND
        (p_PER_UNIT_NREC_TAX_AMT IS NULL))) AND
      ((Recinfo.REF_DOC_PER_UNIT_NREC_TAX_AMT = p_ref_doc_per_unit_nrec_tax_am) OR
       ((Recinfo.REF_DOC_PER_UNIT_NREC_TAX_AMT IS NULL) AND
        (p_ref_doc_per_unit_nrec_tax_am IS NULL))) AND
      ((Recinfo.RATE_TAX_FACTOR = p_RATE_TAX_FACTOR) OR
       ((Recinfo.RATE_TAX_FACTOR IS NULL) AND
        (p_RATE_TAX_FACTOR IS NULL))) AND
      ((Recinfo.TAX_APPORTIONMENT_FLAG = p_TAX_APPORTIONMENT_FLAG) OR
       ((Recinfo.TAX_APPORTIONMENT_FLAG IS NULL) AND
        (p_TAX_APPORTIONMENT_FLAG IS NULL))) AND
      ((Recinfo.TRX_LINE_DIST_AMT = p_trx_line_dist_amt) OR
       ((Recinfo.TRX_LINE_DIST_AMT IS NULL) AND
        (p_trx_line_dist_amt IS NULL))) AND
      ((Recinfo.TRX_LINE_DIST_TAX_AMT = p_trx_line_dist_tax_amt) OR
       ((Recinfo.TRX_LINE_DIST_TAX_AMT IS NULL) AND
        (p_trx_line_dist_tax_amt IS NULL))) AND
      ((Recinfo.ORIG_REC_NREC_RATE = p_orig_rec_nrec_rate) OR
       ((Recinfo.ORIG_REC_NREC_RATE IS NULL) AND
        (p_orig_rec_nrec_rate IS NULL))) AND
      ((Recinfo.ORIG_REC_RATE_CODE = p_orig_rec_rate_code) OR
       ((Recinfo.ORIG_REC_RATE_CODE IS NULL) AND
        (p_orig_rec_rate_code IS NULL))) AND
      ((Recinfo.ORIG_REC_NREC_TAX_AMT = p_orig_rec_nrec_tax_amt) OR
       ((Recinfo.ORIG_REC_NREC_TAX_AMT IS NULL) AND
        (p_orig_rec_nrec_tax_amt IS NULL))) AND
      ((Recinfo.ORIG_REC_NREC_TAX_AMT_TAX_CURR = p_orig_rec_nrec_tax_amt_tax_cu) OR
       ((Recinfo.ORIG_REC_NREC_TAX_AMT_TAX_CURR IS NULL) AND
        (p_orig_rec_nrec_tax_amt_tax_cu IS NULL))) AND
      ((Recinfo.ACCOUNT_CCID = p_ACCOUNT_CCID) OR
       ((Recinfo.ACCOUNT_CCID IS NULL) AND
        (p_account_ccid IS NULL))) AND
      ((Recinfo.ACCOUNT_STRING = p_account_string) OR
       ((Recinfo.ACCOUNT_STRING IS NULL) AND
        (p_account_string IS NULL))) AND
      ((Recinfo.UNROUNDED_REC_NREC_TAX_AMT = p_unrounded_rec_nrec_tax_amt) OR
       ((Recinfo.UNROUNDED_REC_NREC_TAX_AMT IS NULL) AND
        (p_unrounded_rec_nrec_tax_amt IS NULL))) AND
      ((Recinfo.APPLICABILITY_RESULT_ID = p_applicability_result_id) OR
       ((Recinfo.APPLICABILITY_RESULT_ID IS NULL) AND
        (p_applicability_result_id IS NULL))) AND
      ((Recinfo.REC_RATE_RESULT_ID = p_rec_rate_result_id) OR
       ((Recinfo.REC_RATE_RESULT_ID IS NULL) AND
        (p_rec_rate_result_id IS NULL))) AND
      ((Recinfo.BACKWARD_COMPATIBILITY_FLAG = p_backward_compatibility_flag) OR
       ((Recinfo.BACKWARD_COMPATIBILITY_FLAG IS NULL) AND
        (p_backward_compatibility_flag IS NULL))) AND
      ((Recinfo.OVERRIDDEN_FLAG = p_overridden_flag) OR
       ((Recinfo.OVERRIDDEN_FLAG IS NULL) AND
        (p_overridden_flag IS NULL))) AND
      ((Recinfo.SELF_ASSESSED_FLAG = p_self_assessed_flag) OR
       ((Recinfo.SELF_ASSESSED_FLAG IS NULL) AND
        (p_self_assessed_flag IS NULL))) AND
      ((Recinfo.FREEZE_FLAG = p_freeze_flag) OR
       ((Recinfo.FREEZE_FLAG IS NULL) AND
        (p_freeze_flag IS NULL))) AND
      ((Recinfo.POSTING_FLAG = p_posting_flag) OR
       ((Recinfo.POSTING_FLAG IS NULL) AND
        (p_posting_flag IS NULL))) AND
      ((Recinfo.GL_DATE = p_gl_date) OR
       ((Recinfo.GL_DATE IS NULL) AND
        (p_gl_date IS NULL))) AND
      ((Recinfo.REF_DOC_APPLICATION_ID = p_ref_doc_application_id) OR
       ((Recinfo.REF_DOC_APPLICATION_ID IS NULL) AND
        (p_ref_doc_application_id IS NULL))) AND
      ((Recinfo.REF_DOC_ENTITY_CODE = p_ref_doc_entity_code) OR
       ((Recinfo.REF_DOC_ENTITY_CODE IS NULL) AND
        (p_ref_doc_entity_code IS NULL))) AND
      ((Recinfo.REF_DOC_EVENT_CLASS_CODE = p_ref_doc_event_class_code) OR
       ((Recinfo.REF_DOC_EVENT_CLASS_CODE IS NULL) AND
        (p_ref_doc_event_class_code IS NULL))) AND
      ((Recinfo.REF_DOC_TRX_ID = p_ref_doc_trx_id) OR
       ((Recinfo.REF_DOC_TRX_ID IS NULL) AND
        (p_ref_doc_trx_id IS NULL))) AND
      ((Recinfo.REF_DOC_LINE_ID = p_ref_doc_line_id) OR
       ((Recinfo.REF_DOC_LINE_ID IS NULL) AND
        (p_ref_doc_line_id IS NULL))) AND
      ((Recinfo.REF_DOC_DIST_ID = p_ref_doc_dist_id) OR
       ((Recinfo.REF_DOC_DIST_ID IS NULL) AND
        (p_ref_doc_dist_id IS NULL))) AND
      ((Recinfo.REF_DOC_TRX_LEVEL_TYPE = p_ref_doc_trx_level_type) OR
       ((Recinfo.REF_DOC_TRX_LEVEL_TYPE IS NULL) AND
        (p_ref_doc_trx_level_type IS NULL))) AND
      ((Recinfo.MINIMUM_ACCOUNTABLE_UNIT = p_minimum_accountable_unit) OR
       ((Recinfo.MINIMUM_ACCOUNTABLE_UNIT IS NULL) AND
        (p_minimum_accountable_unit IS NULL))) AND
      ((Recinfo.PRECISION = p_precision) OR
       ((Recinfo.PRECISION IS NULL) AND
        (p_precision IS NULL))) AND
      ((Recinfo.ROUNDING_RULE_CODE = p_rounding_rule_code) OR
       ((Recinfo.ROUNDING_RULE_CODE IS NULL) AND
        (p_rounding_rule_code IS NULL))) AND
      ((Recinfo.TAXABLE_AMT = p_taxable_amt) OR
       ((Recinfo.TAXABLE_AMT IS NULL) AND
        (p_taxable_amt IS NULL))) AND
      ((Recinfo.TAXABLE_AMT_TAX_CURR = p_taxable_amt_tax_curr) OR
       ((Recinfo.TAXABLE_AMT_TAX_CURR IS NULL) AND
        (p_taxable_amt_tax_curr IS NULL))) AND
      ((Recinfo.TAXABLE_AMT_FUNCL_CURR = p_taxable_amt_funcl_curr) OR
       ((Recinfo.TAXABLE_AMT_FUNCL_CURR IS NULL) AND
        (p_taxable_amt_funcl_curr IS NULL))) AND
      ((Recinfo.TAX_ONLY_LINE_FLAG = p_tax_only_line_flag) OR
       ((Recinfo.TAX_ONLY_LINE_FLAG IS NULL) AND
        (p_tax_only_line_flag IS NULL))) AND
      ((Recinfo.UNROUNDED_TAXABLE_AMT = p_unrounded_taxable_amt) OR
       ((Recinfo.UNROUNDED_TAXABLE_AMT IS NULL) AND
        (p_unrounded_taxable_amt IS NULL))) AND
      ((Recinfo.LEGAL_ENTITY_ID = p_legal_entity_id) OR
       ((Recinfo.LEGAL_ENTITY_ID IS NULL) AND
        (p_legal_entity_id IS NULL))) AND
      ((Recinfo.PRD_TAX_AMT = p_prd_tax_amt) OR
       ((Recinfo.PRD_TAX_AMT IS NULL) AND
        (p_prd_tax_amt IS NULL))) AND
      ((Recinfo.PRD_TAX_AMT_TAX_CURR = p_prd_tax_amt_tax_curr) OR
       ((Recinfo.PRD_TAX_AMT_TAX_CURR IS NULL) AND
        (p_prd_tax_amt_tax_curr IS NULL))) AND
      ((Recinfo.PRD_TAX_AMT_FUNCL_CURR = p_prd_tax_amt_funcl_curr) OR
       ((Recinfo.PRD_TAX_AMT_FUNCL_CURR IS NULL) AND
        (p_prd_tax_amt_funcl_curr IS NULL))) AND
      ((Recinfo.PRD_TOTAL_TAX_AMT = p_prd_total_tax_amt) OR
       ((Recinfo.PRD_TOTAL_TAX_AMT IS NULL) AND
        (p_prd_total_tax_amt IS NULL))) AND
      ((Recinfo.PRD_TOTAL_TAX_AMT_TAX_CURR = p_prd_total_tax_amt_tax_curr) OR
       ((Recinfo.PRD_TOTAL_TAX_AMT_TAX_CURR IS NULL) AND
        (p_prd_total_tax_amt_tax_curr IS NULL))) AND
      ((Recinfo.PRD_TOTAL_TAX_AMT_FUNCL_CURR = p_prd_total_tax_amt_funcl_curr) OR
       ((Recinfo.PRD_TOTAL_TAX_AMT_FUNCL_CURR IS NULL) AND
        (p_prd_total_tax_amt_funcl_curr IS NULL))) AND
      ((Recinfo.APPLIED_FROM_TAX_DIST_ID = p_applied_from_tax_dist_id) OR
       ((Recinfo.APPLIED_FROM_TAX_DIST_ID IS NULL) AND
        (p_applied_from_tax_dist_id IS NULL))) AND
      ((Recinfo.APPLIED_TO_DOC_CURR_CONV_RATE = p_appl_to_doc_curr_conv_rate) OR
       ((Recinfo.APPLIED_TO_DOC_CURR_CONV_RATE IS NULL) AND
        (p_appl_to_doc_curr_conv_rate IS NULL))) AND
      ((Recinfo.ADJUSTED_DOC_TAX_DIST_ID = p_adjusted_doc_tax_dist_id) OR
       ((Recinfo.ADJUSTED_DOC_TAX_DIST_ID IS NULL) AND
        (p_adjusted_doc_tax_dist_id IS NULL))) AND
      ((Recinfo.FUNC_CURR_ROUNDING_ADJUSTMENT = p_func_curr_rounding_adjust) OR
       ((Recinfo.FUNC_CURR_ROUNDING_ADJUSTMENT IS NULL) AND
        (p_func_curr_rounding_adjust IS NULL))) AND
      ((Recinfo.TAX_APPORTIONMENT_LINE_NUMBER = p_tax_apportionment_line_num) OR
       ((Recinfo.TAX_APPORTIONMENT_LINE_NUMBER IS NULL) AND
        (p_tax_apportionment_line_num IS NULL))) AND
      ((Recinfo.LAST_MANUAL_ENTRY = p_last_manual_entry) OR
       ((Recinfo.LAST_MANUAL_ENTRY IS NULL) AND
        (p_last_manual_entry IS NULL))) AND
      ((Recinfo.REF_DOC_TAX_DIST_ID = p_REF_DOC_TAX_DIST_ID) OR
       ((Recinfo.REF_DOC_TAX_DIST_ID IS NULL) AND
        (p_REF_DOC_TAX_DIST_ID IS NULL))) AND
      ((Recinfo.MRC_TAX_DIST_FLAG = p_MRC_TAX_DIST_FLAG) OR
       ((Recinfo.MRC_TAX_DIST_FLAG IS NULL) AND
        (p_MRC_TAX_DIST_FLAG IS NULL))) AND
      ((Recinfo.MRC_LINK_TO_TAX_DIST_ID = p_MRC_LINK_TO_TAX_DIST_ID) OR
       ((Recinfo.MRC_LINK_TO_TAX_DIST_ID IS NULL) AND
        (p_MRC_LINK_TO_TAX_DIST_ID IS NULL))) AND
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
      ((Recinfo.GLOBAL_ATTRIBUTE_CATEGORY = p_GLOBAL_attribute_category) OR
       ((Recinfo.GLOBAL_ATTRIBUTE_CATEGORY IS NULL) AND
        (p_global_attribute_category IS NULL))) AND
      ((Recinfo.GLOBAL_ATTRIBUTE1 = p_global_attribute1) OR
       ((Recinfo.GLOBAL_ATTRIBUTE1 IS NULL) AND
        (p_global_attribute1  IS NULL))) AND
      ((Recinfo.GLOBAL_ATTRIBUTE2 = p_global_attribute2) OR
       ((Recinfo.GLOBAL_ATTRIBUTE2 IS NULL) AND
        (p_global_attribute2  IS NULL))) AND
      ((Recinfo.GLOBAL_ATTRIBUTE3 = p_global_attribute3) OR
       ((Recinfo.GLOBAL_ATTRIBUTE3 IS NULL) AND
        (p_global_attribute3  IS NULL))) AND
      ((Recinfo.GLOBAL_ATTRIBUTE4 = p_global_attribute4) OR
       ((Recinfo.GLOBAL_ATTRIBUTE4 IS NULL) AND
        (p_global_attribute4  IS NULL))) AND
      ((Recinfo.GLOBAL_ATTRIBUTE5 = p_global_attribute5) OR
       ((Recinfo.GLOBAL_ATTRIBUTE5 IS NULL) AND
        (p_global_attribute5  IS NULL))) AND
      ((Recinfo.GLOBAL_ATTRIBUTE6 = p_global_attribute6) OR
       ((Recinfo.GLOBAL_ATTRIBUTE6 IS NULL) AND
        (p_global_attribute6  IS NULL))) AND
      ((Recinfo.GLOBAL_ATTRIBUTE7 = p_global_attribute7) OR
       ((Recinfo.GLOBAL_ATTRIBUTE7 IS NULL) AND
        (p_global_attribute7  IS NULL))) AND
      ((Recinfo.GLOBAL_ATTRIBUTE8 = p_global_attribute8) OR
       ((Recinfo.GLOBAL_ATTRIBUTE8 IS NULL) AND
        (p_global_attribute8  IS NULL))) AND
      ((Recinfo.GLOBAL_ATTRIBUTE9 = p_global_attribute9) OR
       ((Recinfo.GLOBAL_ATTRIBUTE9 IS NULL) AND
        (p_global_attribute9  IS NULL))) AND
      ((Recinfo.GLOBAL_ATTRIBUTE10 = p_global_attribute10) OR
       ((Recinfo.GLOBAL_ATTRIBUTE10 IS NULL) AND
        (p_global_attribute10  IS NULL))) AND
      ((Recinfo.GLOBAL_ATTRIBUTE11 = p_global_attribute11) OR
       ((Recinfo.GLOBAL_ATTRIBUTE11 IS NULL) AND
        (p_global_attribute11  IS NULL))) AND
      ((Recinfo.GLOBAL_ATTRIBUTE12 = p_global_attribute12) OR
       ((Recinfo.GLOBAL_ATTRIBUTE12 IS NULL) AND
        (p_global_attribute12  IS NULL))) AND
      ((Recinfo.GLOBAL_ATTRIBUTE13 = p_global_attribute13) OR
       ((Recinfo.GLOBAL_ATTRIBUTE13 IS NULL) AND
        (p_global_attribute13  IS NULL))) AND
      ((Recinfo.GLOBAL_ATTRIBUTE14 = p_global_attribute14) OR
       ((Recinfo.GLOBAL_ATTRIBUTE14 IS NULL) AND
        (p_global_attribute14  IS NULL))) AND
      ((Recinfo.GLOBAL_ATTRIBUTE15 = p_global_attribute15) OR
       ((Recinfo.GLOBAL_ATTRIBUTE15 IS NULL) AND
        (p_global_attribute15  IS NULL))) AND
      ((Recinfo.GLOBAL_ATTRIBUTE16 = p_global_attribute16) OR
       ((Recinfo.GLOBAL_ATTRIBUTE16 IS NULL) AND
        (p_global_attribute16  IS NULL))) AND
      ((Recinfo.GLOBAL_ATTRIBUTE17 = p_global_attribute17) OR
       ((Recinfo.GLOBAL_ATTRIBUTE17 IS NULL) AND
        (p_global_attribute17  IS NULL))) AND
      ((Recinfo.GLOBAL_ATTRIBUTE18 = p_global_attribute18) OR
       ((Recinfo.GLOBAL_ATTRIBUTE18 IS NULL) AND
        (p_global_attribute18  IS NULL))) AND
      ((Recinfo.GLOBAL_ATTRIBUTE19 = p_global_attribute19) OR
       ((Recinfo.GLOBAL_ATTRIBUTE19 IS NULL) AND
        (p_global_attribute19  IS NULL))) AND
      ((Recinfo.GLOBAL_ATTRIBUTE20 = p_global_attribute20) OR
       ((Recinfo.GLOBAL_ATTRIBUTE20 IS NULL) AND
        (p_global_attribute20  IS NULL))) AND
      (Recinfo.ORIG_AP_CHRG_DIST_NUM= p_orig_ap_chrg_dist_num) AND
      (Recinfo.ORIG_AP_CHRG_DIST_ID= p_orig_ap_chrg_dist_id) AND
      (Recinfo.ORIG_AP_TAX_DIST_NUM= p_orig_ap_tax_dist_num) AND
      (Recinfo.ORIG_AP_TAX_DIST_ID= p_orig_ap_tax_dist_id) AND
      (Recinfo.OBJECT_VERSION_NUMBER = p_object_version_number) AND
      (Recinfo.CREATED_BY               = p_created_by) AND
      (Recinfo.CREATION_DATE            = p_creation_date) AND
      (Recinfo.LAST_UPDATED_BY          = p_last_updated_by) AND
      (Recinfo.LAST_UPDATE_DATE         = p_last_update_date) AND
      ((Recinfo.LAST_UPDATE_LOGIN = p_last_update_login) OR
       ((Recinfo.LAST_UPDATE_LOGIN IS NULL) AND
        (p_last_update_login IS NULL))) ) THEN
    RETURN;
  ELSE
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.Raise_Exception;
  END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_DISTRIBUTIONS_PKG.Lock_Row.END',
                     'ZX_TRL_DISTRIBUTIONS_PKG: Lock_Row (-)');
    END IF;
  END Lock_Row;

  PROCEDURE Update_Row
       (p_rec_nrec_tax_dist_id                       NUMBER,
        p_application_id                             NUMBER,
        p_entity_code                                VARCHAR2,
        p_event_class_code                           VARCHAR2,
        p_event_type_code                            VARCHAR2,
        p_trx_id                                     NUMBER,
        p_trx_number                                 VARCHAR2,
        p_trx_line_id                                NUMBER,
        p_trx_line_number                            NUMBER,
        p_tax_line_id                                NUMBER,
        p_tax_line_number                            NUMBER,
        p_trx_line_dist_id                           NUMBER,
        p_trx_level_type                             VARCHAR2,
        p_item_dist_number                           NUMBER,
        p_rec_nrec_tax_dist_number                   NUMBER,
        p_rec_nrec_rate                              NUMBER,
        p_recoverable_flag                           VARCHAR2,
        p_rec_nrec_tax_amt                           NUMBER,
        p_tax_event_class_code                       VARCHAR2,
        p_tax_event_type_code                        VARCHAR2,
        p_content_owner_id                           NUMBER,
        p_tax_regime_id                              NUMBER,
        p_tax_regime_code                            VARCHAR2,
        p_tax_id                                     NUMBER,
        p_tax                                        VARCHAR2,
        p_tax_status_id                              NUMBER,
        p_tax_status_code                            VARCHAR2,
        p_tax_rate_id                                NUMBER,
        p_tax_rate_code                              VARCHAR2,
        p_tax_rate                                   NUMBER,
        p_inclusive_flag                             VARCHAR2,
        p_recovery_type_id                           NUMBER,
        p_recovery_type_code                         VARCHAR2,
        p_recovery_rate_id                           NUMBER,
        p_recovery_rate_code                         VARCHAR2,
        p_rec_type_rule_flag                         VARCHAR2,
        p_new_rec_rate_code_flag                     VARCHAR2,
        p_reverse_flag                               VARCHAR2,
        p_historical_flag                            VARCHAR2,
        p_reversed_tax_dist_id                       NUMBER,
        p_rec_nrec_tax_amt_tax_curr                  NUMBER,
        p_rec_nrec_tax_amt_funcl_curr                NUMBER,
        p_intended_use                               VARCHAR2,
        p_project_id                                 NUMBER,
        p_task_id                                    NUMBER,
        p_award_id                                   NUMBER,
        p_expenditure_type                           VARCHAR2,
        p_expenditure_organization_id                NUMBER,
        p_expenditure_item_date                      DATE,
        p_rec_rate_det_rule_flag                     VARCHAR2,
        p_ledger_id                                  NUMBER,
        p_summary_tax_line_id                        NUMBER,
        p_record_type_code                           VARCHAR2,
        p_currency_conversion_date                   DATE,
        p_currency_conversion_type                   VARCHAR2,
        p_currency_conversion_rate                   NUMBER,
        p_tax_currency_conversion_date               DATE,
        p_tax_currency_conversion_type               VARCHAR2,
        p_tax_currency_conversion_rate               NUMBER,
        p_trx_currency_code                          VARCHAR2,
        p_tax_currency_code                          VARCHAR2,
        p_trx_line_dist_qty                          NUMBER,
        p_ref_doc_trx_line_dist_qty                  NUMBER,
        p_price_diff                                 NUMBER,
        p_qty_diff                                   NUMBER,
        p_per_trx_curr_unit_nr_amt                   NUMBER,
        p_ref_per_trx_curr_unit_nr_amt               NUMBER,
        p_ref_doc_curr_conv_rate                     NUMBER,
        p_unit_price                                 NUMBER,
        p_ref_doc_unit_price                         NUMBER,
        p_per_unit_nrec_tax_amt                      NUMBER,
        p_ref_doc_per_unit_nrec_tax_am               NUMBER, --p_ref_doc_per_unit_nrec_tax_amt
        p_rate_tax_factor                            NUMBER,
        p_tax_apportionment_flag                     VARCHAR2,
        p_trx_line_dist_amt                          NUMBER,
        p_trx_line_dist_tax_amt                      NUMBER,
        p_orig_rec_nrec_rate                         NUMBER,
        p_orig_rec_rate_code                         VARCHAR2,
        p_orig_rec_nrec_tax_amt                      NUMBER,
        p_orig_rec_nrec_tax_amt_tax_cu               NUMBER,
        p_account_ccid                               NUMBER,
        p_account_string                             VARCHAR2,
        p_unrounded_rec_nrec_tax_amt                 NUMBER,
        p_applicability_result_id                    NUMBER,
        p_rec_rate_result_id                         NUMBER,
        p_backward_compatibility_flag                VARCHAR2,
        p_overridden_flag                            VARCHAR2,
        p_self_assessed_flag                         VARCHAR2,
        p_freeze_flag                                VARCHAR2,
        p_posting_flag                               VARCHAR2,
        p_gl_date                                    DATE,
        p_ref_doc_application_id                     NUMBER,
        p_ref_doc_entity_code                        VARCHAR2,
        p_ref_doc_event_class_code                   VARCHAR2,
        p_ref_doc_trx_id                             NUMBER,
        p_ref_doc_trx_level_type                     VARCHAR2,
        p_ref_doc_line_id                            NUMBER,
        p_ref_doc_dist_id                            NUMBER,
        p_minimum_accountable_unit                   NUMBER,
        p_precision                                  NUMBER,
        p_rounding_rule_code                         VARCHAR2,
        p_taxable_amt                                NUMBER,
        p_taxable_amt_tax_curr                       NUMBER,
        p_taxable_amt_funcl_curr                     NUMBER,
        p_tax_only_line_flag                         VARCHAR2,
        p_unrounded_taxable_amt                      NUMBER,
        p_legal_entity_id                            NUMBER,
        p_prd_tax_amt                                NUMBER,
        p_prd_tax_amt_tax_curr                       NUMBER,
        p_prd_tax_amt_funcl_curr                     NUMBER,
        p_prd_total_tax_amt                          NUMBER,
        p_prd_total_tax_amt_tax_curr                 NUMBER,
        p_prd_total_tax_amt_funcl_curr               NUMBER,
        p_applied_from_tax_dist_id                   NUMBER,
        p_appl_to_doc_curr_conv_rate                 NUMBER, --p_appl_to_doc_curr_conv_rate
        p_adjusted_doc_tax_dist_id                   NUMBER,
        p_func_curr_rounding_adjust                  NUMBER,
        p_tax_apportionment_line_num                 NUMBER,
        p_last_manual_entry                          VARCHAR2,
        p_ref_doc_tax_dist_id                        NUMBER,
        p_mrc_tax_dist_flag                          VARCHAR2,
        p_mrc_link_to_tax_dist_id                    NUMBER,
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
        p_orig_ap_chrg_dist_num                      NUMBER,
        p_orig_ap_chrg_dist_id                       NUMBER,
        p_orig_ap_tax_dist_num                       NUMBER,
        p_orig_ap_tax_dist_id                        NUMBER,
        p_object_version_number                      NUMBER,
        p_last_updated_by                            NUMBER,
        p_last_update_date                           DATE,
        p_last_update_login                          NUMBER) IS

    l_unrounded_rec_nrec_tax_amt  NUMBER;
    l_rec_nrec_rate               NUMBER;
    l_return_status               VARCHAR2(1000);

  BEGIN
    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_DISTRIBUTIONS_PKG.Update_Row.BEGIN',
                     'ZX_TRL_DISTRIBUTIONS_PKG: Update_Row (+)');
    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_DISTRIBUTIONS_PKG.Update_Row',
                     'Update for reverse dist ZX_TAX_DIST_ID_GT (+)');
    END IF;

    IF p_reverse_flag = 'Y' THEN

      INSERT INTO ZX_TAX_DIST_ID_GT (TAX_DIST_ID) VALUES (p_rec_nrec_tax_dist_id);

    ELSE

      l_unrounded_rec_nrec_tax_amt := (p_trx_line_dist_tax_amt * p_rec_nrec_rate)/100;

      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_DISTRIBUTIONS_PKG.Update_Row',
                       'l_unrounded_rec_nrec_tax_amt :'||l_unrounded_rec_nrec_tax_amt);

        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_DISTRIBUTIONS_PKG.Update_Row',
                       'Update ZX_REC_NREC_DIST (+)');
      END IF;


    -- Bug 5985143. In Determine_recovery call, update_taxline_rec_nrec_amt updates process_for_recovery_flag to 'N'.
    -- When override_recovery is called by AP, rec / nrec amount were not getting updated.
    -- Because delete_tax_distributions expects the flag to be 'Y'. So the tax distribution is not deleted and re-created.
    -- To resolve this, we need to set process_for_recovery_flag to 'Y'.
    --  AP has moved their code for freeze_tax_distribution ONLY in validation


     UPDATE ZX_LINES
     SET process_for_recovery_flag='Y'
     WHERE  (trx_id, trx_line_id) IN (SELECT trx_id, trx_line_id FROM zx_rec_nrec_dist WHERE REC_NREC_TAX_DIST_ID = p_rec_nrec_tax_dist_id)
     AND application_id=p_application_id
     AND entity_code=p_entity_code
     AND event_class_code=p_event_class_code;


      UPDATE ZX_REC_NREC_DIST
        SET orig_rec_nrec_rate             = NVL(orig_rec_nrec_rate, rec_nrec_rate),
            orig_rec_rate_code             = NVL(orig_rec_rate_code, recovery_rate_code),
            orig_rec_nrec_tax_amt          = NVL(orig_rec_nrec_tax_amt, rec_nrec_tax_amt),
            orig_rec_nrec_tax_amt_tax_curr = NVL(orig_rec_nrec_tax_amt_tax_curr, rec_nrec_tax_amt_tax_curr),
            recovery_rate_code             = p_recovery_rate_code,
            rec_nrec_rate                  = p_rec_nrec_rate,
            unrounded_rec_nrec_tax_amt     = l_unrounded_rec_nrec_tax_amt,
            last_manual_entry              = p_last_manual_entry,
            object_version_number          = NVL(p_object_version_number, object_version_number + 1),
            last_updated_by                = fnd_global.user_id,
            last_update_date               = sysdate,
            last_update_login              = fnd_global.login_id
        WHERE REC_NREC_TAX_DIST_ID = p_rec_nrec_tax_dist_id;

      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_DISTRIBUTIONS_PKG.Update_Row',
                       'Update ZX_REC_NREC_DIST (-)');
      END IF;

      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_DISTRIBUTIONS_PKG.Update_Row',
                       'Update for Non recoverable ZX_REC_NREC_DIST (+)');
      END IF;

      l_rec_nrec_rate := 100 - p_rec_nrec_rate;

      l_unrounded_rec_nrec_tax_amt := (p_trx_line_dist_tax_amt * l_rec_nrec_rate)/100;

      UPDATE ZX_REC_NREC_DIST
        SET recovery_rate_code             = NULL,
            rec_nrec_rate                  = l_rec_nrec_rate,
            unrounded_rec_nrec_tax_amt     = l_unrounded_rec_nrec_tax_amt,
            orig_rec_nrec_rate             = NVL(orig_rec_nrec_rate, rec_nrec_rate),
            orig_rec_rate_code             = NVL(orig_rec_rate_code, recovery_rate_code),
            orig_rec_nrec_tax_amt          = NVL(orig_rec_nrec_tax_amt, rec_nrec_tax_amt),
            orig_rec_nrec_tax_amt_tax_curr = NVL(orig_rec_nrec_tax_amt_tax_curr, rec_nrec_tax_amt_tax_curr),
            last_manual_entry              = p_last_manual_entry,
            object_version_number          = NVL(p_object_version_number, object_version_number + 1),
            last_updated_by                = fnd_global.user_id,
            last_update_date               = sysdate,
            last_update_login              = fnd_global.login_id
        WHERE APPLICATION_ID = p_application_id
        AND ENTITY_CODE = p_entity_code
        AND EVENT_CLASS_CODE = p_event_class_code
        AND TRX_ID = p_trx_id
        AND TRX_LINE_ID = p_trx_line_id
        AND TAX_LINE_ID = p_tax_line_id
        AND TRX_LINE_DIST_ID = p_trx_line_dist_id
        AND TRX_LEVEL_TYPE = p_trx_level_type
        AND RECOVERABLE_FLAG = 'N'
        AND NVL(FREEZE_FLAG, 'N') = 'N'
        AND NVL(REVERSE_FLAG, 'N') = 'N';

      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_DISTRIBUTIONS_PKG.Update_Row',
                       'Update for Non recoverable ZX_REC_NREC_DIST (-)');
      END IF;

    END IF; -- reverse flag

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_DISTRIBUTIONS_PKG.Update_Row',
                     'Update for reverse dist ZX_TAX_DIST_ID_GT (-)');
    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_DISTRIBUTIONS_PKG.Update_Row.END',
                     'ZX_TRL_DISTRIBUTIONS_PKG.Update_Row (-)');
    END IF;

  END Update_Row;

  PROCEDURE Delete_Row
       (x_rowid                        IN OUT NOCOPY VARCHAR2,
        p_created_by                                 NUMBER,
        p_creation_date                              DATE,
        p_last_updated_by                            NUMBER,
        p_last_update_date                           DATE,
        p_last_update_login                          NUMBER) IS

  BEGIN
    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_DISTRIBUTIONS_PKG.Delete_Row.BEGIN',
                     'ZX_TRL_DISTRIBUTIONS_PKG: Delete_Row (+)');
    END IF;

    NULL;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_DISTRIBUTIONS_PKG.Delete_Row.END',
                     'ZX_TRL_DISTRIBUTIONS_PKG: Delete_Row (-)');
    END IF;
  END Delete_Row;

  PROCEDURE Override_Recovery
       (p_internal_organization_id                   NUMBER,
        p_application_id                             NUMBER,
        p_entity_code                                VARCHAR2,
        p_event_class_code                           VARCHAR2,
        p_event_type_code                            VARCHAR2,
        p_trx_id                                     NUMBER) IS

    l_return_status               VARCHAR2(1000);
    l_msg_count                   NUMBER;
    l_msg_data                    VARCHAR2(1000);
    l_transaction_rec_type        ZX_API_PUB.transaction_rec_type;

  BEGIN

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_DISTRIBUTIONS_PKG.Override_Recovery',
                     'Calling ZX_TRD_SERVICE_PUB_PKG.override_recovery (+)');
    END IF;

    l_transaction_rec_type.internal_organization_id := p_internal_organization_id;
    l_transaction_rec_type.application_id           := p_application_id;
    l_transaction_rec_type.entity_code              := p_entity_code;
    l_transaction_rec_type.event_class_code         := p_event_class_code;
    l_transaction_rec_type.event_type_code          := p_event_type_code;
    l_transaction_rec_type.trx_id                   := p_trx_id;

    ZX_API_PUB.OVERRIDE_RECOVERY (p_api_version      => 1.0,
                                  p_init_msg_list    => NULL,
                                  p_commit           => NULL,
                                  p_validation_level => NULL,
                                  x_return_status    => l_return_status,
                                  x_msg_count        => l_msg_count,
                                  x_msg_data         => l_msg_data,
                                  p_transaction_rec  => l_transaction_rec_type);

    IF (g_level_procedure >= g_current_runtime_level ) THEN

      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_DISTRIBUTIONS_PKG.Override_Recovery',
                     'Return Status = '  || l_return_status);

      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_DISTRIBUTIONS_PKG.Override_Recovery',
                     'Message Data = '  || l_msg_data);

    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_DISTRIBUTIONS_PKG.Override_Recovery',
                     'Calling ZX_TRD_SERVICE_PUB_PKG.override_recovery (-)');
    END IF;

  END Override_Recovery;

  PROCEDURE Reverse_Row IS

    l_rec_nrec_dist_tbl  ZX_TRD_SERVICES_PUB_PKG.rec_nrec_dist_tbl_type;
    l_tax_dist           NUMBER;
    l_return_status      VARCHAR2(1000);

  BEGIN
    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_DISTRIBUTIONS_PKG.Reverse_Row.BEGIN',
                     'ZX_TRL_DISTRIBUTIONS_PKG: Reverse_Row (+)');
    END IF;

    SELECT count(*)
    INTO l_tax_dist
    FROM ZX_TAX_DIST_ID_GT;

    IF l_tax_dist > 0 THEN
      BEGIN

        IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure,
                         'ZX.PLSQL.ZX_TRL_DISTRIBUTIONS_PKG.Reverse_Row',
                         'Call to zx_trd_service_pub_pkg.reverse_tax_dist (+)');
        END IF;

        ZX_TRD_SERVICES_PUB_PKG.REVERSE_TAX_DIST(l_rec_nrec_dist_tbl,
                                                 x_return_status => l_return_status);

        IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
          IF (g_level_unexpected >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_unexpected,
                           'ZX.PLSQL.ZX_TRL_DISTRIBUTIONS_PKG.Reverse_Row',
                           'Incorrect return_status after calling ' ||
                           'Insert into ZX_REC_NREC_DIST');
          END IF;

          RETURN;

        END IF;

        IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure,
                         'ZX.PLSQL.ZX_TRL_DISTRIBUTIONS_PKG.Reverse_Row',
                         'Call to zx_trd_service_pub_pkg.reverse_tax_dist (-)');
        END IF;

        IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure,
                         'ZX.PLSQL.ZX_TRL_DISTRIBUTIONS_PKG.Reverse_Row',
                         'Delete from ZX_REC_NREC_DIST (+)');
        END IF;

        DELETE FROM ZX_REC_NREC_DIST
          WHERE REC_NREC_TAX_DIST_ID IN (SELECT TAX_DIST_ID
                                         FROM ZX_TAX_DIST_ID_GT);

        IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure,
                         'ZX.PLSQL.ZX_TRL_DISTRIBUTIONS_PKG.Reverse_Row',
                         'Delete from ZX_REC_NREC_DIST (-)');
        END IF;

        IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure,
                         'ZX.PLSQL.ZX_TRL_DISTRIBUTIONS_PKG.Reverse_Row',
                         'Insert into ZX_REC_NREC_DIST (+)');
        END IF;

        FORALL i IN l_rec_nrec_dist_tbl.first..l_rec_nrec_dist_tbl.last

          INSERT INTO ZX_REC_NREC_DIST VALUES l_rec_nrec_dist_tbl(i);

        IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure,
                         'ZX.PLSQL.ZX_TRL_DISTRIBUTIONS_PKG.Reverse_Row',
                         'Insert into ZX_REC_NREC_DIST (-)');
        END IF;

        IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure,
                         'ZX.PLSQL.ZX_TRL_DISTRIBUTIONS_PKG.Reverse_Row.END',
                         'ZX_TRL_DISTRIBUTIONS_PKG: Reverse_Row (-)');
        END IF;
      END;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN

      FND_MESSAGE.SET_NAME('ZX','ZX_UNEXPECTED_ERROR');
      FND_MSG_PUB.Add;

      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_DISTRIBUTIONS_PKG.Reverse_Row',
                       'Exception:' ||SQLCODE||';'||SQLERRM);
      END IF;

  END Reverse_Row;

  PROCEDURE lock_rec_nrec_dist_for_doc
  			(p_application_id			IN NUMBER,
  			 p_entity_code        IN VARCHAR2,
  			 p_event_class_code   IN VARCHAR2,
  			 p_trx_id             IN NUMBER,
			   x_return_status      OUT NOCOPY VARCHAR2,
			   x_error_buffer       OUT NOCOPY VARCHAR2)  IS

		l_return_status          VARCHAR2(1000);

  /*Cursor to Lock the tax distributions for the entire document*/
  CURSOR lock_tax_dist_for_doc_csr(c_application_id NUMBER,
  			 c_event_class_code VARCHAR2,
  			 c_entity_code VARCHAR2,
  			 c_trx_id NUMBER) IS
      SELECT *
        FROM ZX_REC_NREC_DIST
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
		                 'ZX.PLSQL.ZX_TRL_SUMMARY_OVERRIDE_PKG.lock_rec_nrec_dist_for_doc.BEGIN',
		                 'ZX_TRL_SUMMARY_OVERRIDE_PKG: lock_rec_nrec_dist_for_doc (+)');
    END IF;

		OPEN lock_tax_dist_for_doc_csr(p_application_id,
																				p_event_class_code,
																				p_entity_code,
																				p_trx_id);
		CLOSE lock_tax_dist_for_doc_csr;

		IF (g_level_procedure >= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_procedure,
		                 'ZX.PLSQL.ZX_TRL_SUMMARY_OVERRIDE_PKG.lock_rec_nrec_dist_for_doc.END',
		                 'ZX_TRL_SUMMARY_OVERRIDE_PKG: lock_rec_nrec_dist_for_doc(-)');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

      FND_MESSAGE.SET_NAME('ZX','ZX_UNEXPECTED_ERROR');
      FND_MSG_PUB.Add;

      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
		                   'ZX.PLSQL.ZX_TRL_SUMMARY_OVERRIDE_PKG.lock_rec_nrec_dist_for_doc',
			           'Exception:' ||x_error_buffer);
      END IF;
  END lock_rec_nrec_dist_for_doc;


END ZX_TRL_DISTRIBUTIONS_PKG;

/
