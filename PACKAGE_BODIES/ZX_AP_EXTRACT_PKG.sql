--------------------------------------------------------
--  DDL for Package Body ZX_AP_EXTRACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_AP_EXTRACT_PKG" AS
/* $Header: zxripextractpvtb.pls 120.44.12010000.18 2010/04/12 12:29:22 hchakrob ship $ */

PROCEDURE    assign_global_parameters(
               p_trl_global_variables_rec  IN ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE);

PROCEDURE    build_sql;

PROCEDURE    execute_sql_stmt;

PROCEDURE    filter_validated;

PROCEDURE    fetch_tax_info(
               p_statement  IN VARCHAR2);

PROCEDURE    init_gt_variables;

PROCEDURE    insert_tax_info;

  TYPE l_sql_statement_tabtype IS TABLE OF VARCHAR2(32600)
                                 INDEX BY BINARY_INTEGER;

  l_sql_statement_tbl  l_sql_statement_tabtype;


-- Declare Global Variables

  c_lines_per_insert      CONSTANT NUMBER :=  1000;
  g_sql_statement                  VARCHAR2(32000);
  g_sql_statement_no_tax           VARCHAR2(32000);
--g_column_list_trx_dist_lvl    VARCHAR2(32000);
--g_column_list_trx_line_lvl    VARCHAR2(32000);
  l_msg                            VARCHAR2(50);

-- Declare table type global variables

  gt_detail_tax_line_id          ZX_EXTRACT_PKG.detail_tax_line_id_tbl;
  gt_application_id              ZX_EXTRACT_PKG.application_id_tbl;
  gt_event_class_code            ZX_EXTRACT_PKG.event_class_code_tbl;
  gt_line_class                  ZX_EXTRACT_PKG.trx_line_class_tbl;
  GT_TRX_TYPE_DESCRIPTION        ZX_EXTRACT_PKG.TRX_TYPE_DESCRIPTION_TBL;
  gt_internal_organization_id    ZX_EXTRACT_PKG.internal_organization_id_tbl;
  gt_extract_rep_line_num        ZX_EXTRACT_PKG.extract_report_line_number_tbl;
  gt_ledger_id                   ZX_EXTRACT_PKG.ledger_id_tbl;
  gt_doc_event_status            ZX_EXTRACT_PKG.doc_event_status_tbl;
  gt_application_doc_status      ZX_EXTRACT_PKG.application_doc_status_tbl;
  gt_doc_seq_id                  ZX_EXTRACT_PKG.doc_seq_id_tbl;
  gt_doc_seq_name                ZX_EXTRACT_PKG.doc_seq_name_tbl;
  gt_doc_seq_value               ZX_EXTRACT_PKG.doc_seq_value_tbl;
  gt_establishment_id            ZX_EXTRACT_PKG.establishment_id_tbl;
  gt_batch_source_id             ZX_EXTRACT_PKG.batch_source_id_tbl;
  gt_currency_conversion_date    ZX_EXTRACT_PKG.currency_conversion_date_tbl;
  gt_currency_conversion_rate    ZX_EXTRACT_PKG.currency_conversion_rate_tbl;
  gt_currency_conversion_type    ZX_EXTRACT_PKG.currency_conversion_type_tbl;
  gt_minimum_accountable_unit    ZX_EXTRACT_PKG.minimum_accountable_unit_tbl;
  gt_precision                   ZX_EXTRACT_PKG.precision_tbl;
  gt_trx_communicated_date       ZX_EXTRACT_PKG.trx_communicated_date_tbl;
  gt_trx_currency_code           ZX_EXTRACT_PKG.trx_currency_code_tbl;
  gt_trx_id                      ZX_EXTRACT_PKG.trx_id_tbl;
  gt_trx_number                  ZX_EXTRACT_PKG.trx_number_tbl;
  gt_trx_date                    ZX_EXTRACT_PKG.trx_date_tbl;
  gt_trx_description             ZX_EXTRACT_PKG.trx_description_tbl;
  gt_trx_due_date                ZX_EXTRACT_PKG.trx_due_date_tbl;
  gt_trx_line_description        ZX_EXTRACT_PKG.trx_line_description_tbl;
  gt_trx_line_id                 ZX_EXTRACT_PKG.trx_line_id_tbl;
  gt_taxable_item_source_id      ZX_EXTRACT_PKG.taxable_item_source_id_tbl;
  gt_trx_line_number             ZX_EXTRACT_PKG.trx_line_number_tbl;
  gt_trx_line_quantity           ZX_EXTRACT_PKG.trx_line_quantity_tbl;
  gt_trx_line_amt                ZX_EXTRACT_PKG.trx_line_amt_tbl;
  gt_trx_line_type               ZX_EXTRACT_PKG.trx_line_type_tbl;
  gt_trx_shipping_date           ZX_EXTRACT_PKG.trx_shipping_date_tbl;
  gt_uom_code                    ZX_EXTRACT_PKG.uom_code_tbl;
  gt_related_doc_date            ZX_EXTRACT_PKG.related_doc_date_tbl;
  gt_related_doc_entity_code     ZX_EXTRACT_PKG.related_doc_entity_code_tbl;
  gt_related_doc_event_cls_code  ZX_EXTRACT_PKG.related_doc_event_cls_code_tbl;
  gt_related_doc_number          ZX_EXTRACT_PKG.related_doc_number_tbl;
  gt_related_doc_trx_id          ZX_EXTRACT_PKG.related_doc_trx_id_tbl;
  gt_applied_from_appl_id        ZX_EXTRACT_PKG.applied_from_appl_id_tbl;
  gt_applied_from_entity_code    ZX_EXTRACT_PKG.applied_from_entity_code_tbl;
  gt_applied_from_event_cls_code ZX_EXTRACT_PKG.applied_from_event_cls_cd_tbl;
  gt_applied_from_line_id        ZX_EXTRACT_PKG.applied_from_line_id_tbl;
  gt_applied_from_trx_id         ZX_EXTRACT_PKG.applied_from_trx_id_tbl;
  gt_applied_from_trx_number     ZX_EXTRACT_PKG.applied_from_trx_number_tbl;
  gt_applied_to_appl_id          ZX_EXTRACT_PKG.applied_to_application_id_tbl;
  gt_applied_to_entity_code      ZX_EXTRACT_PKG.applied_to_entity_code_tbl;
  gt_applied_to_event_cls_code   ZX_EXTRACT_PKG.applied_to_event_cls_code_tbl;
  gt_applied_to_trx_id           ZX_EXTRACT_PKG.applied_to_trx_id_tbl;
  gt_applied_to_trx_line_id      ZX_EXTRACT_PKG.applied_to_trx_line_id_tbl;
  gt_applied_to_trx_number       ZX_EXTRACT_PKG.applied_to_trx_number_tbl;
  gt_adjusted_doc_appl_id        ZX_EXTRACT_PKG.adjusted_doc_appl_id_tbl;
  gt_adjusted_doc_date           ZX_EXTRACT_PKG.adjusted_doc_date_tbl;
  gt_adjusted_doc_entity_code    ZX_EXTRACT_PKG.adjusted_doc_entity_code_tbl;
  gt_adjusted_doc_event_cls_code ZX_EXTRACT_PKG.adjusted_doc_event_cls_cd_tbl;
  GT_ADJUSTED_DOC_NUMBER         ZX_EXTRACT_PKG.ADJUSTED_DOC_NUMBER_TBL;
  gt_country_of_supply           ZX_EXTRACT_PKG.country_of_supply_tbl;
  gt_default_taxation_country    ZX_EXTRACT_PKG.default_taxation_country_tbl;
  gt_merchant_party_doc_num      ZX_EXTRACT_PKG.merchant_party_doc_num_tbl;
  gt_merchant_party_name         ZX_EXTRACT_PKG.merchant_party_name_tbl;
  gt_merchant_party_reference    ZX_EXTRACT_PKG.merchant_party_reference_tbl;
  gt_merchant_party_tax_reg_num  ZX_EXTRACT_PKG.merchant_party_tax_reg_num_tbl;
  gt_merchant_party_taxpayer_id  ZX_EXTRACT_PKG.merchant_party_taxpayer_id_tbl;
  gt_ref_doc_application_id      ZX_EXTRACT_PKG.ref_doc_application_id_tbl;
  gt_ref_doc_entity_code         ZX_EXTRACT_PKG.ref_doc_entity_code_tbl;
  gt_ref_doc_event_cls_code      ZX_EXTRACT_PKG.ref_doc_event_class_code_tbl;
  gt_ref_doc_line_id             ZX_EXTRACT_PKG.ref_doc_line_id_tbl;
  gt_ref_doc_line_quantity       ZX_EXTRACT_PKG.ref_doc_line_quantity_tbl;
  gt_ref_doc_trx_id              ZX_EXTRACT_PKG.ref_doc_trx_id_tbl;
  gt_start_expense_date          ZX_EXTRACT_PKG.start_expense_date_tbl;
  gt_assessable_value            ZX_EXTRACT_PKG.assessable_value_tbl;
  gt_document_sub_type           ZX_EXTRACT_PKG.document_sub_type_tbl;
  gt_line_intended_use           ZX_EXTRACT_PKG.line_intended_use_tbl;
  gt_product_category            ZX_EXTRACT_PKG.product_category_tbl;
  gt_product_description         ZX_EXTRACT_PKG.product_description_tbl;
  gt_prod_fisc_classification    ZX_EXTRACT_PKG.prod_fisc_classification_tbl;
  gt_product_id                  ZX_EXTRACT_PKG.product_id_tbl;
  gt_supplier_exchange_rate      ZX_EXTRACT_PKG.supplier_exchange_rate_tbl;
  gt_supplier_tax_invoice_date   ZX_EXTRACT_PKG.supplier_tax_invoice_date_tbl;
  gt_supplier_tax_invoice_num    ZX_EXTRACT_PKG.supplier_tax_invoice_num_tbl;
  gt_tax_invoice_date            ZX_EXTRACT_PKG.tax_invoice_date_tbl;
  gt_tax_invoice_number          ZX_EXTRACT_PKG.tax_invoice_number_tbl;
  gt_trx_business_category       ZX_EXTRACT_PKG.trx_business_category_tbl;
  gt_user_defined_fisc_class     ZX_EXTRACT_PKG.user_defined_fisc_class_tbl;
  gt_nrec_tax_amt_tax_curr       ZX_EXTRACT_PKG.nrec_tax_amt_tax_curr_tbl;
  gt_offset_tax_rate_code        ZX_EXTRACT_PKG.offset_tax_rate_code_tbl;
  gt_orig_rec_nrec_tax_amt       ZX_EXTRACT_PKG.orig_rec_nrec_tax_amt_tbl;
  gt_orig_tax_amt                ZX_EXTRACT_PKG.orig_tax_amt_tbl;
  gt_orig_tax_amt_tax_curr       ZX_EXTRACT_PKG.orig_tax_amt_tax_curr_tbl;
  gt_orig_taxable_amt            ZX_EXTRACT_PKG.orig_taxable_amt_tbl;
  gt_orig_taxable_amt_tax_curr   ZX_EXTRACT_PKG.orig_taxable_amt_tax_curr_tbl;
  gt_rec_tax_amt_tax_curr        ZX_EXTRACT_PKG.rec_tax_amt_tax_curr_tbl;
  gt_recovery_rate_code          ZX_EXTRACT_PKG.recovery_rate_code_tbl;
  gt_recovery_type_code          ZX_EXTRACT_PKG.recovery_type_code_tbl;
  gt_tax                         ZX_EXTRACT_PKG.tax_tbl;
  gt_tax_amt                     ZX_EXTRACT_PKG.tax_amt_tbl;
  gt_tax_amt_funcl_curr          ZX_EXTRACT_PKG.tax_amt_funcl_curr_tbl;
  gt_tax_amt_tax_curr            ZX_EXTRACT_PKG.tax_amt_tax_curr_tbl;
  gt_tax_apportionment_line_num  ZX_EXTRACT_PKG.tax_apportionment_line_num_tbl;
  gt_tax_currency_code           ZX_EXTRACT_PKG.tax_currency_code_tbl;
  gt_tax_date                    ZX_EXTRACT_PKG.tax_date_tbl;
  gt_tax_determine_date          ZX_EXTRACT_PKG.tax_determine_date_tbl;
  gt_tax_jurisdiction_code       ZX_EXTRACT_PKG.tax_jurisdiction_code_tbl;
  gt_tax_line_id                 ZX_EXTRACT_PKG.tax_line_id_tbl;
  gt_tax_line_number             ZX_EXTRACT_PKG.tax_line_number_tbl;
  gt_tax_line_user_attribute1    ZX_EXTRACT_PKG.tax_line_user_attribute1_tbl;
  gt_tax_line_user_attribute10   ZX_EXTRACT_PKG.tax_line_user_attribute10_tbl;
  gt_tax_line_user_attribute11   ZX_EXTRACT_PKG.tax_line_user_attribute11_tbl;
  gt_tax_line_user_attribute12   ZX_EXTRACT_PKG.tax_line_user_attribute12_tbl;
  gt_tax_line_user_attribute13   ZX_EXTRACT_PKG.tax_line_user_attribute13_tbl;
  gt_tax_line_user_attribute14   ZX_EXTRACT_PKG.tax_line_user_attribute14_tbl;
  gt_tax_line_user_attribute15   ZX_EXTRACT_PKG.tax_line_user_attribute15_tbl;
  gt_tax_line_user_attribute2    ZX_EXTRACT_PKG.tax_line_user_attribute2_tbl;
  gt_tax_line_user_attribute3    ZX_EXTRACT_PKG.tax_line_user_attribute3_tbl;
  gt_tax_line_user_attribute4    ZX_EXTRACT_PKG.tax_line_user_attribute4_tbl;
  gt_tax_line_user_attribute5    ZX_EXTRACT_PKG.tax_line_user_attribute5_tbl;
  gt_tax_line_user_attribute6    ZX_EXTRACT_PKG.tax_line_user_attribute6_tbl;
  gt_tax_line_user_attribute7    ZX_EXTRACT_PKG.tax_line_user_attribute7_tbl;
  gt_tax_line_user_attribute8    ZX_EXTRACT_PKG.tax_line_user_attribute8_tbl;
  gt_tax_line_user_attribute9    ZX_EXTRACT_PKG.tax_line_user_attribute9_tbl;
  gt_tax_line_user_category      ZX_EXTRACT_PKG.tax_line_user_category_tbl;
  gt_tax_rate                    ZX_EXTRACT_PKG.tax_rate_tbl;
  gt_tax_rate_code               ZX_EXTRACT_PKG.tax_rate_code_tbl;
  GT_TAX_RATE_CODE_NAME          ZX_EXTRACT_PKG.TAX_RATE_CODE_NAME_TBL;
  GT_TAX_RATE_VAT_TRX_TYPE_CODE  ZX_EXTRACT_PKG.TAX_RATE_VAT_TRX_TYPE_CODE_TBL;
  GT_TAX_TYPE_CODE               ZX_EXTRACT_PKG.TAX_TYPE_CODE_TBL;
  gt_tax_rate_id                 ZX_EXTRACT_PKG.tax_rate_id_tbl;
  gt_tax_recovery_rate           ZX_EXTRACT_PKG.tax_recovery_rate_tbl;
  gt_tax_regime_code             ZX_EXTRACT_PKG.tax_regime_code_tbl;
  gt_tax_status_code             ZX_EXTRACT_PKG.tax_status_code_tbl;
  gt_tax_status_id               ZX_EXTRACT_PKG.tax_status_id_tbl;
  gt_taxable_amt                 ZX_EXTRACT_PKG.taxable_amt_tbl;
  gt_taxable_amt_funcl_curr      ZX_EXTRACT_PKG.taxable_amt_funcl_curr_tbl;
  gt_billing_tp_name             ZX_EXTRACT_PKG.billing_tp_name_tbl;
  gt_billing_tp_number           ZX_EXTRACT_PKG.billing_tp_number_tbl;
-- Party ids --
  gt_shipping_tp_id              ZX_EXTRACT_PKG.shipping_tp_id_tbl;
  gt_billing_trading_partner_id  ZX_EXTRACT_PKG.billing_trading_partner_id_tbl;
  gt_billing_tp_site_id          ZX_EXTRACT_PKG.billing_tp_site_id_tbl;
  gt_shipping_tp_site_id         ZX_EXTRACT_PKG.shipping_tp_site_id_tbl;
  gt_billing_tp_address_id       ZX_EXTRACT_PKG.billing_tp_address_id_tbl;
  gt_shipping_tp_address_id      ZX_EXTRACT_PKG.shipping_tp_address_id_tbl;

  gt_bill_from_pty_tax_prof_id   ZX_EXTRACT_PKG.bill_from_pty_tax_prof_id_tbl;
  gt_bill_from_site_tax_prof_id  ZX_EXTRACT_PKG.bill_from_site_tax_prof_id_tbl;
  gt_billing_tp_taxpayer_id      ZX_EXTRACT_PKG.billing_tp_taxpayer_id_tbl;
  gt_ship_to_site_tax_prof_id    ZX_EXTRACT_PKG.ship_to_site_tax_prof_id_tbl;
  gt_ship_from_site_tax_prof_id  ZX_EXTRACT_PKG.ship_from_site_tax_prof_id_tbl;
  gt_ship_to_pty_tax_prof_id     ZX_EXTRACT_PKG.ship_to_party_tax_prof_id_tbl;
  gt_ship_from_pty_tax_prof_id   ZX_EXTRACT_PKG.ship_from_pty_tax_prof_id_tbl;
  gt_hq_estb_reg_number          ZX_EXTRACT_PKG.hq_estb_reg_number_tbl;
  gt_tax_line_registration_num   ZX_EXTRACT_PKG.tax_line_registration_num_tbl;
  gt_legal_entity_tax_reg_num    ZX_EXTRACT_PKG.legal_entity_tax_reg_num_tbl;
  gt_own_hq_pty_site_prof_id     ZX_EXTRACT_PKG.own_hq_party_site_prof_id_tbl;
  gt_own_hq_pty_tax_prof_id      ZX_EXTRACT_PKG.own_hq_party_tax_prof_id_tbl;
  gt_port_of_entry_code          ZX_EXTRACT_PKG.port_of_entry_code_tbl;
  gt_registration_party_type     ZX_EXTRACT_PKG.registration_party_type_tbl;
  gt_cancel_flag                 ZX_EXTRACT_PKG.cancel_flag_tbl;
  gt_historical_flag             ZX_EXTRACT_PKG.historical_flag_tbl;
  gt_mrc_tax_line_flag           ZX_EXTRACT_PKG.mrc_tax_line_flag_tbl;
  gt_offset_flag                 ZX_EXTRACT_PKG.offset_flag_tbl;
  gt_reporting_only_flag         ZX_EXTRACT_PKG.reporting_only_flag_tbl;
  gt_self_assessed_flag          ZX_EXTRACT_PKG.self_assessed_flag_tbl;
  gt_tax_amt_included_flag       ZX_EXTRACT_PKG.tax_amt_included_flag_tbl;
  gt_tax_only_flag               ZX_EXTRACT_PKG.tax_only_flag_tbl;
  gt_tax_recoverable_flag        ZX_EXTRACT_PKG.tax_recoverable_flag_tbl;
  gt_posted_flag                 ZX_EXTRACT_PKG.posted_flag_tbl;
  gt_reverse_flag                ZX_EXTRACT_PKG.reverse_flag_tbl;
  gt_entity_code                 ZX_EXTRACT_PKG.entity_code_tbl;
  gt_trx_level_type              ZX_EXTRACT_PKG.TRX_LEVEL_TYPE_TBL; --Bug 5393051
  gt_unit_price_tbl              ZX_EXTRACT_PKG.UNIT_PRICE_TBL; -- Bug 5439099
  gt_gl_date                     ZX_EXTRACT_PKG.gl_date_tbl; --Bug 5523095
  gt_tax_rate_code_description   ZX_EXTRACT_PKG.tax_rate_code_description_tbl;
  g_created_by                   number(15);
  g_creation_date                date;
  g_last_updated_by              number(15);
  g_last_update_date             date;
  g_last_update_login            number(15);
  g_program_application_id       number;
  g_program_id                   number;
  g_program_login_id             number;
  gt_actg_source_id              ZX_EXTRACT_PKG.actg_source_id_tbl;

-- declare global variables to assign global parameters

  g_reporting_level              VARCHAR2(30);
  g_reporting_context            VARCHAR2(30);
-- apai    g_legal_entity_level    VARCHAR2(30);
  g_legal_entity_id              NUMBER;
  g_summary_level                VARCHAR2(30);
  g_ledger_id                    NUMBER;
  g_register_type                VARCHAR2(30);
  g_product                      VARCHAR2(30);
  g_matrix_report                VARCHAR2(30);
  g_currency_code_low            VARCHAR2(30);
  g_currency_code_high           VARCHAR2(30);
  g_include_ap_std_trx_class     VARCHAR2(1);
  g_include_ap_dm_trx_class      VARCHAR2(1);
  g_include_ap_cm_trx_class      VARCHAR2(1);
  g_include_ap_prep_trx_class    VARCHAR2(1);
  g_include_ap_mix_trx_class     VARCHAR2(1);
  g_include_ap_exp_trx_class     VARCHAR2(1);
  g_include_ap_int_trx_class     VARCHAR2(1);
  g_include_ar_inv_trx_class     VARCHAR2(1);
  g_include_ar_appl_trx_class    VARCHAR2(1);
  g_include_ar_adj_trx_class     VARCHAR2(1);
  g_include_ar_misc_trx_class    VARCHAR2(1);
  g_include_ar_br_trx_class      VARCHAR2(1);
  g_include_gl_manual_lines      VARCHAR2(30);
  g_trx_number_low               VARCHAR2(30);
  g_trx_number_high              VARCHAR2(30);
  g_ar_trx_printing_status       VARCHAR2(30);
  g_ar_exemption_status          VARCHAR2(30);
  g_gl_date_low                  date;
  g_gl_date_high                 date;
  g_trx_date_low                 date;
  g_trx_date_high                date;
  g_trx_date_low_ln              date;
  g_trx_date_high_ln             date;
  g_gl_period_name_low           VARCHAR2(15);
  g_gl_period_name_high          VARCHAR2(15);
  g_trx_date_period_name_low     VARCHAR2(15);
  g_trx_date_period_name_high    VARCHAR2(15);
  g_tax_jurisdiction_code        VARCHAR2(30);
  g_first_party_tax_reg_num      VARCHAR2(30);
  g_tax_regime_code              VARCHAR2(30);
  g_tax                          VARCHAR2(30);
  g_tax_status_code              VARCHAR2(30);
  g_tax_rate_code_low            VARCHAR2(30);
  g_tax_rate_code_high           VARCHAR2(30);
  g_tax_type_code_low            VARCHAR2(30);
  g_tax_type_code_high           VARCHAR2(30);
  g_document_sub_type            VARCHAR2(30);
  g_trx_business_category        VARCHAR2(30);
  g_tax_invoice_date_low         VARCHAR2(30);
  g_tax_invoice_date_high        VARCHAR2(30);
  g_posting_status               VARCHAR2(30);
  g_extract_accted_tax_lines     VARCHAR2(30);
  g_include_accounting_segments  VARCHAR2(1);
  g_balancing_segment_low        VARCHAR2(30);
  g_balancing_segment_high       VARCHAR2(30);
  g_include_discounts            VARCHAR2(1);
  g_extract_starting_line_num    NUMBER;
  g_request_id                   NUMBER;
  g_report_name                  VARCHAR2(30);
  g_vat_transaction_type_code    VARCHAR2(30);
  g_include_fully_nr_tax_flag    VARCHAR2(30);
  g_municipal_tax_type_code_low  VARCHAR2(30);
  g_municipal_tax_type_code_high VARCHAR2(30);
  g_prov_tax_type_code_low       VARCHAR2(30);
  g_prov_tax_type_code_high      VARCHAR2(30);
  g_excise_tax_type_code_low     VARCHAR2(30);
  g_excise_tax_type_code_high    VARCHAR2(30);
  g_non_taxable_tax_type_code    VARCHAR2(30);
  g_per_tax_type_code_low        VARCHAR2(30);
  g_per_tax_type_code_high       VARCHAR2(30);
  g_fed_per_tax_type_code_low    VARCHAR2(30);
  g_fed_per_tax_type_code_high   VARCHAR2(30);
  g_vat_tax_type_code            VARCHAR2(30);
  g_excise_tax                   VARCHAR2(30);
  g_vat_additional_tax           VARCHAR2(30);
  g_vat_non_taxable_tax          VARCHAR2(30);
  g_vat_not_tax                  VARCHAR2(30);
  g_vat_perception_tax           VARCHAR2(30);
  g_vat_tax                      VARCHAR2(30);
  g_inc_self_wd_tax              VARCHAR2(30);
  g_excluding_trx_letter         VARCHAR2(30);
  g_trx_letter_low               VARCHAR2(30);
  g_trx_letter_high              VARCHAR2(30);
  g_include_referenced_source    VARCHAR2(30);
  g_party_name                   VARCHAR2(30);
  g_batch_name                   VARCHAR2(30);
  g_batch_date_low               DATE;
  g_batch_date_high              DATE;
  g_batch_source_id              VARCHAR2(30);
  g_adjusted_doc_from            VARCHAR2(30);
  g_adjusted_doc_to              VARCHAR2(30);
  g_standard_vat_tax_rate        VARCHAR2(30);
  g_municipal_tax                VARCHAR2(30);
  g_provincial_tax               VARCHAR2(30);
  g_tax_account_low              VARCHAR2(30);
  g_tax_account_high             VARCHAR2(30);
  g_exp_cert_date_from           DATE;
  g_exp_cert_date_to             DATE;
  g_exp_method                   VARCHAR2(30);
  g_print_company_info           VARCHAR2(30);
  g_reprint                      VARCHAR2(1);
  g_errbuf                       VARCHAR2(30);
  g_retcode                      NUMBER := 2;

  g_extract_line_num             NUMBER :=1;
  g_accounting_status            VARCHAR2(30);
  g_chart_of_accounts_id         NUMBER;
  g_gl_or_trx_date_filter        varchar(1); --Bug 5347188
  g_reported_status              VARCHAR2(30);

-- Declare global varibles for FND log messages

  g_current_runtime_level           NUMBER;
  g_level_statement       CONSTANT  NUMBER  := FND_LOG.LEVEL_STATEMENT;
  g_level_procedure       CONSTANT  NUMBER  := FND_LOG.LEVEL_PROCEDURE;
  g_level_event           CONSTANT  NUMBER  := FND_LOG.LEVEL_EVENT;
  g_level_unexpected      CONSTANT  NUMBER  := FND_LOG.LEVEL_UNEXPECTED;
  g_error_buffer                    VARCHAR2(100);


/*===========================================================================+
| PROCEDURE                                                                 |
|   INSERT_TAX_DATA                                                         |
|                                                                           |
| DESCRIPTION                                                               |
|    This procedure takes the input parameters from ZX_EXTRACT_PKG          |
|    and builds a dynamic SQL statement clauses based on the parameters,    |
|    supplies them as output parameters.                                    |
|                                                                           |
| SCOPE - Public                                                            |
|                                                                           |
| NOTES                                                                     |
|                                                                           |
| MODIFICATION HISTORY                                                      |
|       11-Jan-2005    Srinivasa Rao Korrapati      Created                 |
+===========================================================================*/


PROCEDURE insert_tax_data (
          p_trl_global_variables_rec   IN OUT NOCOPY ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE
          )
IS

BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  g_retcode := p_trl_global_variables_rec.retcode;
  IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.INSERT_TAX_DATA.BEGIN',
                                      'ZX_AP_EXTRACT_PKG: INSERT_TAX_DATA(+)');
  END IF;

  assign_global_parameters(
        p_trl_global_variables_rec => P_TRL_GLOBAL_VARIABLES_REC);

  IF g_retcode <> 2 THEN
     build_sql;
  END IF;

  IF ( g_level_statement>= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_AP_EXTRACT_PKG',
                    ' g_ret_code after build_sql : '||g_retcode );
  END IF;

  IF g_retcode <> 2 THEN
     execute_sql_stmt;
  END IF;

  IF ( g_level_statement>= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_AP_EXTRACT_PKG',
                    ' g_ret_code after execute_sql_stmt : '||g_retcode );
  END IF;

  IF g_retcode <> 2 THEN
     filter_validated;
  END IF;

  IF ( g_level_statement>= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_AP_EXTRACT_PKG',
                    ' g_ret_code after filter_validated : '||g_retcode );
  END IF;

  p_trl_global_variables_rec.retcode := g_retcode;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure,
                   'ZX.TRL.ZX_AP_EXTRACT_PKG.INSERT_TAX_DATA.END',
                   'ZX_AP_EXTRACT_PKG: INSERT_TAX_DATA(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','insert_tax_data- '|| g_error_buffer);
    FND_MSG_PUB.Add;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                      'ZX.TRL.ZX_AP_EXTRACT_PKG.insert_tax_data',
                      g_error_buffer);
    END IF;
    p_trl_global_variables_rec.retcode := 2;

END insert_tax_data;


/*===========================================================================+
| PROCEDURE                                                                 |
|   build_sql                                                               |
|                                                                           |
| DESCRIPTION                                                               |
|    This procedure builds dynamic SQL statement for AP tax data extract.   |
|                                                                           |
| SCOPE - Private                                                           |
|                                                                           |
| NOTES                                                                     |
|                                                                           |
| MODIFICATION HISTORY                                                      |
|   11-Jan-2005  Srinivasa Rao Korrapati      Created                       |
+===========================================================================*/


PROCEDURE BUILD_SQL IS

  L_REPORTING_CONTEXT_VAL        VARCHAR2(1000);
  L_SELECT_ACCOUNT_SEG           VARCHAR2(500);
  L_WHERE_REPORT_CONTEXT         VARCHAR2(500);
  L_WHERE_GL_DATE                VARCHAR2(200);
  L_WHERE_GL_DATE_NO_TAX         VARCHAR2(200);
  L_WHERE_GL_TRX_DATE            varchar2(1000);--Bug 5347188
  L_WHERE_GL_TRX_DATE_NO_TAX     varchar2(1000);
  --L_WHERE_GL_DATE_I              VARCHAR2(200);
  L_WHERE_TRX_DATE               VARCHAR2(500);
  L_WHERE_TRX_DATE_NO_TAX        VARCHAR2(500);
  L_WHERE_TAX_CODE               VARCHAR2(200);
  L_WHERE_CURRENCY_CODE          VARCHAR2(200);
  --L_WHERE_CURRENCY_CODE_DIST_I   VARCHAR2(200);
  --L_WHERE_CURRENCY_CODE_DIST_T   VARCHAR2(200);
  --L_WHERE_CURRENCY_CODE_I        VARCHAR2(200);
  --L_WHERE_CURRENCY_CODE_AX       VARCHAR2(200);
  --L_WHERE_CURRENCY_CODE_AXSUB    VARCHAR2(200);
  --L_WHERE_GBL_TAX_DATE           VARCHAR2(200);
  L_WHERE_TAX_CODE_VAT_TRX_TYPE  VARCHAR2(200);
  L_WHERE_TAX_CODE_TYPE          VARCHAR2(200);
  --L_WHERE_TP_NAME_AP             VARCHAR2(200);
  L_WHERE_LEDGER_ID              VARCHAR2(500);
  L_WHERE_LEDGER_ID_NO_TAX       VARCHAR2(500);
  L_BALANCING_SEGMENT            VARCHAR2(50);
  L_ACCOUNTING_SEGMENT           VARCHAR2(50);
  --L_WHERE_GL_FLEX                VARCHAR2(200);
  L_WHERE_TRX_CLASS              VARCHAR2(10000);
  L_WHERE_INCLUDE_FLAG           VARCHAR2(1);
  --L_THIRD_PARTY_REPORTING_LEVEL  VARCHAR2(25);
  --L_WHERE_AP_DIST_ATT1_IS_NULL   VARCHAR2(5000);
  --L_INIT_PARAM                   VARCHAR2(4);
  L_WHERE_REGISTER_TYPE          VARCHAR2(3000);
  L_WHERE_TRX_NUM                VARCHAR2(1000);
  --L_WHERE_ACCOUNT_SEG            VARCHAR2(1000);
  --L_TOTAL_LINES_SQL              VARCHAR2(32000);
  --L_TOTAL_LINES                  NUMBER;
  --L_ACCOUNTED_LINES_SQL          VARCHAR2(32000);
  --L_ACCOUNTED_LINES              NUMBER;
  --L_TOTAL                        NUMBER;
  --L_CURSOR                       NUMBER;
  --L_RETVAL                       NUMBER;
  --L_WHERE_TAX_CLASS              VARCHAR2(500);
  --L_WHERE_TAX_CLASS_GRP          VARCHAR2(2000);
  --L_TRX_DATE_LOW                 DATE;
  --L_TRX_DATE_HIGH                DATE;
  --L_WHERE_ATT3_NULL              VARCHAR2(500);
  --L_MSG                        VARCHAR2(50);
  --L_WHERE_POSTING_STATUS_DIST_T  VARCHAR2(500);
  --L_WHERE_POSTING_STATUS_DIST_I  VARCHAR2(500);
  --L_WHERE_SPECIAL_PL_HU_C        VARCHAR2(500);

  L_WHERE_TRX_LINE_CLASS         VARCHAR2(500);
  l_sql_statement                VARCHAR2(32000);
  l_sql_statement_no_tax         VARCHAR2(32000);
  --L_COLUMN_LIST_TRX_DIST_LVL     VARCHAR2(32000);
  --L_COLUMN_LIST_TRX_LINE_LVL     VARCHAR2(32000);

  L_ADD                          NUMBER;
  L_WHERE_BATCH_DATE             VARCHAR2(500);
  L_WHERE_BATCH_NAME             VARCHAR2(500);
  L_WHERE_PARTY_NAME              VARCHAR2(500);
  --L_WHERE_TRADING_PARTNER_ID     VARCHAR2(200);
  --
  -- MRC changes
  --

  L_WHERE_DOCUMENT_SUB_TYPE      VARCHAR2(500);
  L_WHERE_ADJUSTED_DOC_NUM      VARCHAR2(500);
  L_WHERE_ADJUSTED_DOC_NO_TAX      VARCHAR2(500);
  L_WHERE_TRX_BUSINESS_CATEGORY  VARCHAR2(500);
  L_WHERE_TAX_INVOICE_DATE       VARCHAR2(500);
  L_WHERE_TAX_REGIME_CODE        VARCHAR2(500);
  L_WHERE_TAX_REGIME_CODE_NO_TAX        VARCHAR2(500);
  L_WHERE_TAX_JURISDICTION_CODE  VARCHAR2(500);
  L_WHERE_TAX_JURIS_CODE_NO_TAX  VARCHAR2(500);
  L_WHERE_FIRST_PTY_TAX_REG_NUM VARCHAR2(500);
  L_WHERE_FIRST_PTY_NUM_NO_TAX VARCHAR2(500);
  L_WHERE_TAX                    VARCHAR2(500);
  L_WHERE_TAX_NO_TAX             VARCHAR2(500);
  L_WHERE_TAX_STATUS_CODE        VARCHAR2(500);
  L_WHERE_TAX_STATUS_CODE_NO_TAX    VARCHAR2(500);
  L_WHERE_TAX_RATE_CODE          VARCHAR2(500);
  L_WHERE_TAX_RATE_CODE_NO_TAX   VARCHAR2(500);
  L_WHERE_TAX_TYPE_CODE          VARCHAR2(500);
  L_WHERE_TAX_TYPE_CODE_NO_TAX   VARCHAR2(500);
  L_WHERE_VAT_TRANSACTION_TYPE   VARCHAR2(500);
  L_WHERE_LEGAL_ENTITY_ID        VARCHAR2(500);
  L_WHERE_LEGAL_ENTITY_ID_NO_TAX        VARCHAR2(500);

  L_WHERE_ACCOUNTING_STATUS    VARCHAR2(500);
  L_WHERE_REPORTED_STATUS        VARCHAR2(500);

  -- Variables used to change predicate return by FND multi org API

  l_fnd_mo_org_stg              VARCHAR2(2000);
  l_internal_org_stg              VARCHAR2(2000);
  l_string_len                  NUMBER;
  l_org_len                     NUMBER;
  l_get_org_id                  VARCHAR2(25);
  l_equal_pos                  NUMBER;

BEGIN

  IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.BUILD_SQL.BEGIN',
                                      'ZX_AP_EXTRACT_PKG: BUILD_SQL(+)');
  END IF;


  -- ===========================================================+
  --   Building Where Clauses:
  --   L_WHERE_REPORTING_CONTEXT :
  --   These where clauses will be used in the queries
  --   to restrict the data from multi-org tables to the appropriate
  --   reporting context .
  -- ==============================================================+

  L_REPORTING_CONTEXT_VAL := ' ' ||TO_CHAR(G_REPORTING_CONTEXT) || ' ' ;

  FND_MO_REPORTING_API.INITIALIZE(G_REPORTING_LEVEL,G_REPORTING_CONTEXT,'AUTO');

  l_fnd_mo_org_stg := FND_MO_REPORTING_API.GET_PREDICATE('ZX_DET',NULL,L_REPORTING_CONTEXT_VAL);
  IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.BUILD_SQL',
                                      'l_fnd_mo_org_stg = '||l_fnd_mo_org_stg);
  END IF;

/*    l_string_len := LENGTH(l_fnd_mo_org_stg);
    l_equal_pos := instr(l_fnd_mo_org_stg,'=');
  --  l_org_len := l_string_len - 19;
    l_get_org_id := substr(l_fnd_mo_org_stg,l_equal_pos,l_string_len);
    IF (g_level_procedure >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.BUILD_SQL',
                    'l_fnd_mo_org_stg = '||l_get_org_id||' Pos '||to_char(l_equal_pos)||' Len '||to_char(l_string_len));
    END IF; */
  l_internal_org_stg:= replace (l_fnd_mo_org_stg,'ORG_ID','INTERNAL_ORGANIZATION_ID');

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.BUILD_SQL',
                    'l_internal_org_stg = '||l_internal_org_stg);
  END IF;

  --L_WHERE_REPORT_CONTEXT := 'AND ZX_DET.INTERNAL_ORGANIZATION_ID '||l_get_org_id;

  IF G_REPORTING_LEVEL IN ('1000','3000') THEN
    L_WHERE_REPORT_CONTEXT := l_internal_org_stg;
  ELSE
    L_WHERE_REPORT_CONTEXT := 'AND NULL IS NULL';
  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.BUILD_SQL',
                    'L_WHERE_REPORT_CONTEXT = '||L_WHERE_REPORT_CONTEXT);
  END IF;

  -- New Parameter code
     /* Commented Bug 5347188 :
    IF  g_trx_date_low  IS NULL  AND
        g_trx_date_high IS  NULL
    THEN
       L_WHERE_TRX_DATE := ' AND decode(:g_trx_date_low,NULL,NULL) IS NULL AND DECODE(:g_trx_date_high,NULL,NULL) IS NULL ';
    ELSE
       L_WHERE_TRX_DATE := ' AND ZX_DET.TRX_DATE BETWEEN :g_trx_date_low and :g_trx_date_high ' ;
    END IF;*/

  --Bug 5347188 : To take care of all 4 conditions as in case of trx_date
  IF g_trx_date_low IS NOT NULL AND g_trx_date_high IS NOT NULL THEN
    L_WHERE_TRX_DATE := ' (ZX_DET.TRX_DATE BETWEEN :g_trx_date_low AND :g_trx_date_high)  AND (zx_line.TRX_DATE BETWEEN :g_trx_date_low_ln AND :g_trx_date_high_ln) ';
    L_WHERE_TRX_DATE_NO_TAX := ' (ZX_DET.TRX_DATE BETWEEN :g_trx_date_low AND :g_trx_date_high) AND (DECODE(:g_trx_date_low_ln, NULL,NULL) IS NULL AND DECODE(:g_trx_date_high_ln, NULL,NULL) IS NULL)';
  ELSIF g_trx_date_low IS NULL AND g_trx_date_high IS NULL THEN
    L_WHERE_TRX_DATE := ' (DECODE(:g_trx_date_low, NULL,NULL) IS NULL AND DECODE(:g_trx_date_high, NULL,NULL) IS NULL) AND (DECODE(:g_trx_date_low_ln, NULL,NULL) IS NULL AND DECODE(:g_trx_date_high_ln, NULL,NULL) IS NULL) ';
    L_WHERE_TRX_DATE_NO_TAX := ' (DECODE(:g_trx_date_low, NULL,NULL) IS NULL AND DECODE(:g_trx_date_high, NULL,NULL) IS NULL) AND (DECODE(:g_trx_date_low_ln, NULL,NULL) IS NULL AND DECODE(:g_trx_date_high_ln, NULL,NULL) IS NULL) ';
  ELSIF g_trx_date_low IS NOT NULL AND g_trx_date_high IS NULL THEN
    L_WHERE_TRX_DATE := ' (ZX_DET.TRX_DATE >= :g_trx_date_low AND DECODE(:g_trx_date_high, NULL,NULL) IS NULL) AND (ZX_LINE.TRX_DATE >= :g_trx_date_low_ln AND DECODE(:g_trx_date_high_ln, NULL,NULL) IS NULL) ';
    L_WHERE_TRX_DATE_NO_TAX := ' (ZX_DET.TRX_DATE >= :g_trx_date_low AND DECODE(:g_trx_date_high, NULL,NULL) IS NULL) AND (DECODE(:g_trx_date_low_ln, NULL,NULL) IS NULL AND DECODE(:g_trx_date_high_ln, NULL,NULL) IS NULL) ';
  ELSE
    L_WHERE_TRX_DATE := ' (DECODE(:g_trx_date_low, NULL,NULL) IS NULL  AND ZX_DET.TRX_DATE  <= :g_trx_date_high) AND (DECODE(:g_trx_date_low_ln, NULL,NULL) IS NULL  AND ZX_LINE.TRX_DATE  <= :g_trx_date_high_ln) ';
    L_WHERE_TRX_DATE_NO_TAX := ' (DECODE(:g_trx_date_low, NULL,NULL) IS NULL  AND ZX_DET.TRX_DATE  <= :g_trx_date_high) AND (DECODE(:g_trx_date_low_ln, NULL,NULL) IS NULL  AND ZX_LINE.TRX_DATE  <= :g_trx_date_high_ln) ';
  END IF;

  /* +===================================================================================================+
  --    The following where clauses will be built to select appropriate register type
  --    Tax Register would show all the invoices that have partially recoverable Taxes and
  --    Fully Recoverable Taxes.

  --    If  P_AP_INCLUDE_FULLY_NR_TAX_FLAG = 'Y' then the Tax Register would also include invoices which
  --    have Fully  Non-Recoverable Taxes.

  --    Non-Recoverable Tax Register shows all the invoices that have partially recoverable Taxes and
  --    Fully Non-Recoverable Taxes.
     +===================================================================================================+
  */
  IF g_register_type = 'TAX' THEN
    IF G_INCLUDE_FULLY_NR_TAX_FLAG = 'Y' THEN
      L_WHERE_REGISTER_TYPE := ' ';
    ELSE
      L_WHERE_REGISTER_TYPE :=' AND EXISTS (SELECT ''Fully  Recoverable''' ||
                                            ' FROM zx_rec_nrec_dist zx_dist1 ' ||
                                           ' WHERE zx_dist1.trx_id = zx_dist.trx_id ' ||
                                             ' AND zx_dist1.rec_nrec_tax_dist_id = zx_dist.rec_nrec_tax_dist_id ' ||
                                             ' AND zx_dist1.recoverable_flag = ''Y'' '||
                                             ' AND zx_dist1.tax_rate_id = zx_dist.tax_rate_id )';
    END IF;
  END IF;

  IF g_register_type = 'NON-RECOVERABLE' THEN
    L_WHERE_REGISTER_TYPE :=' AND EXISTS (SELECT ''Fully  Recoverable''' ||
                                          ' FROM zx_rec_nrec_dist zx_dist1 ' ||
                                         ' WHERE zx_dist1.trx_id = zx_dist.trx_id ' ||
                                           ' AND zx_dist1.rec_nrec_tax_dist_id = zx_dist.rec_nrec_tax_dist_id ' ||
                                           ' AND zx_dist1.recoverable_flag = ''N'' '||
                                           ' AND zx_dist1.tax_rate_id = zx_dist.tax_rate_id )';
  END IF;

  IF g_register_type = 'ALL' THEN
    L_WHERE_REGISTER_TYPE := ' ';
  END IF;

  /* Commented Bug 5347188 :
  IF g_gl_date_low IS NOT NULL AND g_gl_date_high IS NOT NULL THEN
    L_WHERE_GL_DATE := ' AND ZX_DIST.GL_DATE BETWEEN :g_gl_date_low AND :g_gl_date_high ';

  ELSE
    L_WHERE_GL_DATE := ' AND decode(:g_gl_date_low,NULL,NULL) IS NULL AND DECODE(:g_gl_date_high,NULL,NULL) IS NULL ';
  END IF; */

  --Bug 5347188 : To take care of all 4 conditions as in case of gl_date
  IF g_gl_date_low IS NOT NULL AND g_gl_date_high IS NOT NULL THEN
    L_WHERE_GL_DATE := ' ZX_DIST.GL_DATE BETWEEN :g_gl_date_low AND :g_gl_date_high ';
    L_WHERE_GL_DATE_NO_TAX := ' AP_DIST.ACCOUNTING_DATE BETWEEN :g_gl_date_low AND :g_gl_date_high ';
  ELSIF g_gl_date_low IS NULL AND g_gl_date_high IS NULL THEN
    L_WHERE_GL_DATE := ' DECODE(:g_gl_date_low, NULL,NULL) IS NULL AND DECODE(:g_gl_date_high, NULL,NULL) IS NULL ';
    L_WHERE_GL_DATE_NO_TAX := ' DECODE(:g_gl_date_low, NULL,NULL) IS NULL AND DECODE(:g_gl_date_high, NULL,NULL) IS NULL ';
  ELSIF g_gl_date_low IS NOT NULL AND g_gl_date_high IS NULL THEN
    L_WHERE_GL_DATE := ' ZX_DIST.GL_DATE >= :g_gl_date_low AND DECODE(:g_gl_date_high, NULL,NULL) IS NULL ';
    L_WHERE_GL_DATE_NO_TAX := ' AP_DIST.ACCOUNTING_DATE >= :g_gl_date_low AND DECODE(:g_gl_date_high, NULL,NULL) IS NULL ';
  ELSE
    L_WHERE_GL_DATE := ' DECODE(:g_gl_date_low, NULL,NULL) IS NULL  AND ZX_DIST.GL_DATE  <= :g_gl_date_high ';
    L_WHERE_GL_DATE_NO_TAX := ' DECODE(:g_gl_date_low, NULL,NULL) IS NULL  AND AP_DIST.ACCOUNTING_DATE  <= :g_gl_date_high ';
  END IF;

  --  IF g_document_sub_type IS NOT NULL THEN
  --    L_WHERE_DOCUMENT_SUB_TYPE := ' AND ZX_DET.DOCUMENT_SUB_TYPE = :g_document_sub_type ';
  --  ELSE
  --    L_WHERE_DOCUMENT_SUB_TYPE := ' AND DECODE(:g_document_sub_type,NULL,NULL) IS NULL ';
  --  END IF;

  -- Adjusted document predicate added for Taiwan

  IF g_adjusted_doc_from IS NOT NULL AND g_adjusted_doc_to IS NOT NULL THEN
    L_WHERE_ADJUSTED_DOC_NUM := ' AND ZX_LINE.ADJUSTED_DOC_NUMBER BETWEEN :g_adjusted_doc_from AND :g_adjusted_doc_to ';
    L_WHERE_ADJUSTED_DOC_NO_TAX := ' AND DECODE(:g_adjusted_doc_from,NULL,NULL) IS NULL '||
                                   ' AND DECODE(:g_adjusted_doc_to,NULL,NULL) IS NULL ';
  ELSE
    L_WHERE_ADJUSTED_DOC_NUM := ' AND DECODE(:g_adjusted_doc_from,NULL,NULL) IS NULL '||
                                ' AND DECODE(:g_adjusted_doc_to,NULL,NULL) IS NULL ';
    L_WHERE_ADJUSTED_DOC_NO_TAX := ' AND DECODE(:g_adjusted_doc_from,NULL,NULL) IS NULL '||
                                       ' AND DECODE(:g_adjusted_doc_to,NULL,NULL) IS NULL ';
  END IF;

  IF g_trx_business_category IS NOT NULL THEN
    L_WHERE_TRX_BUSINESS_CATEGORY := ' AND ZX_DET.TRX_BUSINESS_CATEGORY = :G_TRX_BUSINESS_CATEGORY ';
  ELSE
    L_WHERE_TRX_BUSINESS_CATEGORY := ' AND DECODE(:G_TRX_BUSINESS_CATEGORY,NULL,NULL) IS NULL ';
  END IF;

   /*Bug Fix 5119565 */
  IF g_tax_invoice_date_low IS NOT NULL AND g_tax_invoice_date_high IS NOT NULL THEN
    L_WHERE_TAX_INVOICE_DATE := ' AND ZX_DET.TAX_INVOICE_DATE BETWEEN :G_TAX_INVOICE_DATE_LOW AND :G_TAX_INVOICE_DATE_HIGH ';
  ELSIF g_tax_invoice_date_low IS NULL AND g_tax_invoice_date_high IS NULL THEN
    L_WHERE_TAX_INVOICE_DATE := ' AND DECODE(:G_TAX_INVOICE_DATE_LOW, NULL,NULL) IS NULL AND DECODE(:G_TAX_INVOICE_DATE_HIGH, NULL,NULL) IS NULL ';
  ELSIF G_TAX_INVOICE_DATE_LOW IS NOT NULL AND G_TAX_INVOICE_DATE_HIGH IS NULL THEN
    L_WHERE_TAX_INVOICE_DATE := ' AND ZX_DET.TAX_INVOICE_DATE >= :G_TAX_INVOICE_DATE_LOW AND DECODE(:G_TAX_INVOICE_DATE_HIGH, NULL,NULL) IS NULL ';
  ELSE
    L_WHERE_TAX_INVOICE_DATE := ' AND DECODE(:G_TAX_INVOICE_DATE_LOW, NULL,NULL) IS NULL  AND ZX_DET.TAX_INVOICE_DATE  <= :G_TAX_INVOICE_DATE_HIGH ';
  END IF;

  --Bug 5347188 : Create and OR predicate for gl_date and trx_date
  IF ( g_gl_or_trx_date_filter = 'Y' ) THEN
    L_WHERE_GL_TRX_DATE := ' AND ( ( '||L_WHERE_TRX_DATE||' ) OR ('||L_WHERE_GL_DATE||')) ';
    L_WHERE_GL_TRX_DATE_NO_TAX := ' AND ( ( '||L_WHERE_TRX_DATE_NO_TAX||' ) OR ('||L_WHERE_GL_DATE_NO_TAX||')) ';
    L_WHERE_TRX_DATE := ' ' ;
    L_WHERE_TRX_DATE_NO_TAX := ' ' ;
    L_WHERE_GL_DATE := ' ' ;
    L_WHERE_GL_DATE_NO_TAX := ' ' ;
  ELSE
    L_WHERE_TRX_DATE := ' AND '||L_WHERE_TRX_DATE;
    L_WHERE_TRX_DATE_NO_TAX := ' AND '||L_WHERE_TRX_DATE_NO_TAX;
    L_WHERE_GL_DATE := ' AND '||L_WHERE_GL_DATE;
    L_WHERE_GL_DATE_NO_TAX := ' AND '||L_WHERE_GL_DATE_NO_TAX;
    L_WHERE_GL_TRX_DATE := ' ';
    L_WHERE_GL_TRX_DATE_NO_TAX := ' ';
  END IF ;


  IF g_first_party_tax_reg_num IS NOT NULL THEN
    L_WHERE_FIRST_PTY_TAX_REG_NUM :=  ' AND zx_line.hq_estb_reg_number = :g_first_party_tax_reg_num ';
    L_WHERE_FIRST_PTY_NUM_NO_TAX :=   ' AND DECODE(:g_first_party_tax_reg_num,NULL,NULL) IS NULL ';
  ELSE
    L_WHERE_FIRST_PTY_TAX_REG_NUM :=  ' AND DECODE(:g_first_party_tax_reg_num,NULL,NULL) IS NULL ';
    L_WHERE_FIRST_PTY_NUM_NO_TAX :=   ' AND DECODE(:g_first_party_tax_reg_num,NULL,NULL) IS NULL ';
  END IF;

  IF g_tax_jurisdiction_code IS NOT NULL THEN
    L_WHERE_TAX_JURISDICTION_CODE := ' AND ZX_LINE.TAX_JURISDICTION_CODE = :g_tax_jurisdiction_code ';
    L_WHERE_TAX_JURIS_CODE_NO_TAX := ' AND DECODE(:g_tax_jurisdiction_code,NULL,NULL) IS NULL ';
  ELSE
    L_WHERE_TAX_JURISDICTION_CODE := ' AND DECODE(:g_tax_jurisdiction_code,NULL,NULL) IS NULL ';
    L_WHERE_TAX_JURIS_CODE_NO_TAX := ' AND DECODE(:g_tax_jurisdiction_code,NULL,NULL) IS NULL ';
  END IF;

  IF g_tax_regime_code IS NOT NULL THEN
    L_WHERE_TAX_REGIME_CODE := ' AND ZX_LINE.TAX_REGIME_CODE = :G_TAX_REGIME_CODE ';
    L_WHERE_TAX_REGIME_CODE_NO_TAX := ' AND DECODE(:G_TAX_REGIME_CODE,NULL,NULL) IS NULL ';
  ELSE
    L_WHERE_TAX_REGIME_CODE := ' AND DECODE(:G_TAX_REGIME_CODE,NULL,NULL) IS NULL ';
    L_WHERE_TAX_REGIME_CODE_NO_TAX := ' AND DECODE(:G_TAX_REGIME_CODE,NULL,NULL) IS NULL ';
  END IF;

  IF g_tax IS NOT NULL THEN
    L_WHERE_TAX := ' AND ZX_LINE.TAX = :G_TAX ';
    L_WHERE_TAX_NO_TAX := ' AND DECODE(:G_TAX,NULL,NULL) IS NULL ';
  ELSE
    L_WHERE_TAX := ' AND DECODE(:G_TAX,NULL,NULL) IS NULL ';
    L_WHERE_TAX_NO_TAX := ' AND DECODE(:G_TAX,NULL,NULL) IS NULL ';
  END IF;

  IF g_tax_status_code IS NOT NULL THEN
    L_WHERE_TAX_STATUS_CODE := ' AND ZX_LINE.TAX_STATUS_CODE = :G_TAX_STATUS_CODE ';
  ELSE
    L_WHERE_TAX_STATUS_CODE := ' AND DECODE(:G_TAX_STATUS_CODE,NULL,NULL) IS NULL ';
  END IF;
  L_WHERE_TAX_STATUS_CODE_NO_TAX := ' AND DECODE(:G_TAX_STATUS_CODE,NULL,NULL) IS NULL ';

  IF g_tax_rate_code_low IS NOT NULL AND g_tax_rate_code_high IS NOT NULL THEN
    L_WHERE_TAX_RATE_CODE := ' AND ZX_LINE.TAX_RATE_CODE BETWEEN :G_TAX_RATE_CODE_LOW AND :G_TAX_RATE_CODE_HIGH ';
  ELSE
    L_WHERE_TAX_RATE_CODE := ' AND DECODE(:G_TAX_RATE_CODE_LOW,NULL,NULL) IS NULL '||
                             ' AND DECODE(:G_TAX_RATE_CODE_HIGH,NULL,NULL) IS NULL ';
  END IF;
  L_WHERE_TAX_RATE_CODE_NO_TAX := ' AND DECODE(:G_TAX_RATE_CODE_LOW,NULL,NULL) IS NULL '||
                                  ' AND DECODE(:G_TAX_RATE_CODE_HIGH,NULL,NULL) IS NULL ';

  IF g_tax_type_code_low IS NOT NULL AND g_tax_type_code_high IS NOT NULL THEN
    L_WHERE_TAX_TYPE_CODE := ' AND ZX_TAX.TAX_TYPE_CODE BETWEEN :G_TAX_TYPE_CODE_LOW AND :G_TAX_TYPE_CODE_HIGH ';
  ELSE
    L_WHERE_TAX_TYPE_CODE := ' AND DECODE(:G_TAX_TYPE_CODE_LOW,NULL,NULL) IS NULL '||
                             ' AND DECODE(:G_TAX_TYPE_CODE_HIGH,NULL,NULL) IS NULL ';
  END IF;
  L_WHERE_TAX_TYPE_CODE_NO_TAX := ' AND DECODE(:G_TAX_TYPE_CODE_LOW,NULL,NULL) IS NULL '||
                                    ' AND DECODE(:G_TAX_TYPE_CODE_HIGH,NULL,NULL) IS NULL ';

  IF g_currency_code_low IS NOT NULL AND g_currency_code_high IS NOT NULL THEN
    L_WHERE_CURRENCY_CODE := ' AND ZX_DET.TRX_CURRENCY_CODE BETWEEN :G_CURRENCY_CODE_LOW AND :G_CURRENCY_CODE_HIGH ';
  ELSE
    L_WHERE_CURRENCY_CODE := ' AND DECODE(:G_CURRENCY_CODE_LOW,NULL,NULL) IS NULL '||
                             ' AND DECODE(:G_CURRENCY_CODE_HIGH,NULL,NULL) IS NULL ';
  END IF;

  /*
    IF G_POSTING_STATUS = 'POSTED' THEN
       L_WHERE_POSTING_STATUS_DIST_T := ' AND (DIST_T.POSTED_FLAG = ''Y'') ';
       L_WHERE_POSTING_STATUS_DIST_I := ' AND (DIST_I.POSTED_FLAG = ''Y'') ';
    ELSIF G_POSTING_STATUS = 'UNPOSTED' THEN
       L_WHERE_POSTING_STATUS_DIST_T := ' AND (DIST_T.POSTED_FLAG = ''N'') ';
       L_WHERE_POSTING_STATUS_DIST_I := ' AND (DIST_I.POSTED_FLAG = ''N'') ';
    ELSIF G_POSTING_STATUS = 'ALL' THEN
       L_WHERE_POSTING_STATUS_DIST_T := ' AND DIST_T.POSTED_FLAG in (''Y'',''N'') ';
       L_WHERE_POSTING_STATUS_DIST_I := ' AND DIST_I.POSTED_FLAG in ( ''Y'',''N'') ';
    END IF;
  */
  IF g_trx_number_low IS NOT NULL AND g_trx_number_high IS NOT NULL THEN
     L_WHERE_TRX_NUM := ' AND ZX_DET.TRX_NUMBER BETWEEN :G_TRX_NUMBER_LOW AND :G_TRX_NUMBER_HIGH ';
  ELSE
     L_WHERE_TRX_NUM := ' AND DECODE(:G_TRX_NUMBER_LOW,NULL,NULL) IS NULL AND DECODE(:G_TRX_NUMBER_HIGH,NULL,NULL) IS NULL ';
  END IF;

  IF ( g_include_ap_std_trx_class =  'Y'  OR  g_include_ap_dm_trx_class =   'Y' OR
       g_include_ap_cm_trx_class =   'Y'  OR  g_include_ap_prep_trx_class = 'Y' OR
       g_include_ap_mix_trx_class =  'Y'  OR  g_include_ap_exp_trx_class =  'Y' )

  THEN

    L_WHERE_TRX_CLASS := '';

    IF g_include_ap_std_trx_class = 'Y' THEN
      L_WHERE_TRX_CLASS := L_WHERE_TRX_CLASS || '''STANDARD INVOICES'' ,''PREPAY_APPLICATION'' ,''AMOUNT_MATCHED'' ,' ;
    END IF;

    IF g_include_ap_dm_trx_class = 'Y' THEN
      L_WHERE_TRX_CLASS := L_WHERE_TRX_CLASS || '''AP_DEBIT_MEMO'' ,';
    END IF;

    IF g_include_ap_cm_trx_class = 'Y' THEN
      L_WHERE_TRX_CLASS := L_WHERE_TRX_CLASS || '''AP_CREDIT_MEMO'' ,';
    END IF;

    IF g_include_ap_prep_trx_class = 'Y' THEN
      L_WHERE_TRX_CLASS := L_WHERE_TRX_CLASS || '''PREPAYMENT INVOICES'' ,';
    END IF;

    IF g_include_ap_mix_trx_class = 'Y' THEN
      L_WHERE_TRX_CLASS := L_WHERE_TRX_CLASS || '''MIXED'' ,';
    END IF;

    IF g_include_ap_exp_trx_class = 'Y' THEN
      L_WHERE_TRX_CLASS := L_WHERE_TRX_CLASS || '''EXPENSE REPORTS'' ,';
    END IF;

    L_WHERE_TRX_CLASS := ' AND ZX_DET.LINE_CLASS IN ( '||  RTRIM(L_WHERE_TRX_CLASS,' ,') || ')';

  ELSE
    L_WHERE_TRX_CLASS := 'AND 1 = 0 ';

  END IF;

  IF g_batch_date_low IS NOT NULL AND g_batch_date_high IS NOT NULL THEN
    L_WHERE_BATCH_DATE := ' AND BAT.BATCH_DATE BETWEEN :G_BATCH_DATE_LOW AND :G_BATCH_DATE_HIGH  ';
  ELSE
    L_WHERE_BATCH_DATE := ' AND DECODE(:G_BATCH_DATE_LOW,NULL,NULL) IS NULL AND DECODE(:G_BATCH_DATE_HIGH,NULL,NULL) IS NULL';
  END IF;

  IF g_batch_name IS NOT NULL THEN
    L_WHERE_BATCH_NAME := ' AND BAT.BATCH_NAME = :G_BATCH_NAME';
  ELSE
    L_WHERE_BATCH_NAME := ' AND DECODE(:G_BATCH_NAME,NULL,NULL) IS NULL ';
  END IF;

  IF g_party_name IS NOT NULL THEN
    L_WHERE_PARTY_NAME := ' AND NVL(ZX_DET.SHIP_THIRD_PTY_ACCT_ID, ZX_DET.BILL_THIRD_PTY_ACCT_ID) = to_number(:G_PARTY_NAME)';
  ELSE
    L_WHERE_PARTY_NAME := ' AND DECODE(:G_PARTY_NAME,NULL,NULL) IS NULL ';
  END IF;


  IF g_vat_transaction_type_code IS NOT NULL THEN
    L_WHERE_VAT_TRANSACTION_TYPE   := ' AND ZX_RATE.VAT_TRANSACTION_TYPE_CODE = :G_VAT_TRANSACTION_TYPE_CODE ';
  ELSE
    L_WHERE_VAT_TRANSACTION_TYPE  := ' AND DECODE(:G_VAT_TRANSACTION_TYPE_CODE,NULL,NULL) IS NULL ';
  END IF;


  IF g_reporting_level = '2000' THEN
    L_WHERE_LEGAL_ENTITY_ID := ' AND ZX_LINE.LEGAL_ENTITY_ID = :G_LEGAL_ENTITY_ID ';
    L_WHERE_LEGAL_ENTITY_ID_NO_TAX := ' AND ZX_DET.LEGAL_ENTITY_ID = :G_LEGAL_ENTITY_ID ';
  ELSE
    L_WHERE_LEGAL_ENTITY_ID := ' AND DECODE(:G_LEGAL_ENTITY_ID,NULL,NULL) IS NULL ';
    L_WHERE_LEGAL_ENTITY_ID_NO_TAX := ' AND DECODE(:G_LEGAL_ENTITY_ID,NULL,NULL) IS NULL ';
  END IF;

  IF g_ledger_id IS NOT NULL THEN
    L_WHERE_LEDGER_ID := ' AND ZX_LINE.LEDGER_ID = :G_LEDGER_ID ';
    L_WHERE_LEDGER_ID_NO_TAX := ' AND ZX_DET.LEDGER_ID = :G_LEDGER_ID ';
  ELSE
    L_WHERE_LEDGER_ID := ' AND DECODE(:G_LEDGER_ID,NULL,NULL) IS NULL ';
    L_WHERE_LEDGER_ID_NO_TAX := ' AND DECODE(:G_LEDGER_ID,NULL,NULL) IS NULL ';
  END IF;


  L_WHERE_ACCOUNTING_STATUS := '';
  IF g_accounting_status = 'ACCOUNTED' THEN
    L_WHERE_ACCOUNTING_STATUS := ' AND zx_dist.POSTING_FLAG = ''A''';
  ELSIF g_accounting_status = 'UNACCOUNTED' then
    L_WHERE_ACCOUNTING_STATUS := ' AND nvl(zx_dist.POSTING_FLAG,''N'') = ''N''';
  ELSIF g_accounting_status = 'BOTH' OR g_accounting_status IS NULL THEN
     /*    IF G_INCLUDE_ACCOUNTING_SEGMENTS = 'Y'  THEN
              l_balancing_segment := fa_rx_flex_pkg.flex_sql(
          p_application_id =>101,
          p_id_flex_code => 'GL#',
          p_id_flex_num => g_chart_of_accounts_id,
          p_table_alias => '',
          p_mode => 'SELECT',
          p_qualifier => 'GL_BALANCING');
              l_accounting_segment := fa_rx_flex_pkg.flex_sql(
          p_application_id =>101,
          p_id_flex_code => 'GL#',
          p_id_flex_num => g_chart_of_accounts_id,
          p_table_alias => '',
          p_mode => 'SELECT',
          p_qualifier => 'GL_ACCOUNT');
            END IF;
             */
      L_WHERE_ACCOUNTING_STATUS := ' AND NULL IS NULL ';
    END IF;


    IF G_REPORTED_STATUS IS NOT NULL THEN
      --     L_WHERE_REPORTED_STATUS  := ' AND ZX_LINES.LEGAL_REPORTING_STATUS = ''111111111111111''' ;
      --ELSIF G_REPORTED_STATUS = 'N'  THEN
      L_WHERE_REPORTED_STATUS  := ' AND ZX_LINE.LEGAL_REPORTING_STATUS = ''000000000000000''';
    ELSE
      L_WHERE_REPORTED_STATUS  := '';
    END IF;


  /*
     IF G_TRADING_PARTNER_ID IS NOT NULL THEN
        L_WHERE_TRADING_PARTNER_ID := ' AND TRX_H.VENDOR_ID = :G_TRADING_PARTNER_ID ';
     ELSE
        L_WHERE_TRADING_PARTNER_ID := ' AND DECODE(:G_TRADING_PARTNER_ID,NULL,NULL) IS NULL ';
     END IF;
  */

   IF g_summary_level = 'TRANSACTION' THEN

     IF (g_level_procedure >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.BUILD_SQL',
                       'SQL-1 For Invoice, Credit Memo, Debit Memo: Header Level');
     END IF;

     l_sql_statement :=
       'SELECT
        zx_det.application_id,
        zx_line.event_class_code ,
        zx_det.internal_organization_id,
        zx_det.doc_event_status,
        zx_det.application_doc_status,
        zx_det.line_class,
        zx_det.doc_seq_id ,
        zx_det.doc_seq_name ,
        zx_det.doc_seq_value,
        zx_det.establishment_id,
        zx_det.batch_source_id,
        zx_det.currency_conversion_date,
        zx_det.currency_conversion_rate,
        zx_det.currency_conversion_type,
        zx_det.minimum_accountable_unit,
        zx_det.precision,
        zx_det.trx_communicated_date ,
        zx_det.trx_currency_code,
        zx_line.trx_id   ,
        zx_det.trx_number ,
        zx_det.trx_date,
        zx_det.trx_description,
        zx_det.trx_type_description,
        zx_rate.description,
        zx_det.trx_due_date,
        to_char(null),--zx_det.trx_line_description,
        to_char(null),--zx_line.trx_line_id,
        to_char(null),--zx_line.trx_line_number,
        to_char(null),--zx_line.trx_line_quantity,
        sum(zx_line.line_amt),
        to_char(NULL),  --zx_det.trx_line_type,
        to_char(NULL), --zx_det.trx_shipping_date,
        to_char(NULL),  --zx_det.uom_code,
        to_char(NULL), --zx_det.related_doc_date,
        to_char(NULL), --zx_det.related_doc_entity_code,
        to_char(NULL), --zx_det.related_doc_event_class_code,
        to_char(NULL), --zx_det.related_doc_number,
        to_number(NULL),   --zx_det.related_doc_trx_id,
        to_number(NULL),   --zx_det.applied_from_application_id,
        to_char(NULL), --zx_line.applied_from_entity_code,
        to_char(NULL), --zx_line.applied_from_event_class_code,
        to_number(NULL),   --zx_det.applied_from_line_id,
        to_number(NULL),   --zx_line.applied_from_trx_id,
        to_char(NULL), --zx_line.applied_from_trx_number,
        to_number(NULL),   --zx_det.applied_to_application_id,
       to_char(NULL), -- zx_line.applied_to_entity_code,
        to_char(NULL), --zx_line.applied_to_event_class_code,
        to_number(NULL),   --zx_line.applied_to_trx_id,
        to_number(NULL),   --zx_det.applied_to_trx_line_id,
        to_char(NULL), --zx_det.applied_to_trx_number,
        to_number(NULL),   --zx_det.adjusted_doc_application_id,
        to_char(NULL), --zx_det.adjusted_doc_date,
        to_char(NULL), --zx_det.adjusted_doc_entity_code,
        to_char(NULL), --zx_det.adjusted_doc_event_class_code,
        to_char(NULL), --ZX_DET.ADJUSTED_DOC_NUMBER,
        --zx_det.country_of_supply,
        zx_det.default_taxation_country,
        TO_CHAR(NULL), --ZX_DET.MERCHANT_PARTY_DOCUMENT_NUMBER,
        TO_CHAR(NULL), --ZX_DET.MERCHANT_PARTY_NAME,
        TO_CHAR(NULL), --ZX_DET.MERCHANT_PARTY_REFERENCE,
        TO_CHAR(NULL), --ZX_DET.MERCHANT_PARTY_TAX_REG_NUMBER,
        TO_CHAR(NULL), --ZX_DET.MERCHANT_PARTY_TAXPAYER_ID,
        to_number(NULL),  --zx_det.ref_doc_application_id,
        to_char(NULL),  --zx_det.ref_doc_entity_code,
        to_char(NULL),  --zx_det.ref_doc_event_class_code,
        to_number(NULL),  --zx_det.ref_doc_line_id,
        to_number(NULL),  --zx_det.ref_doc_line_quantity,
        to_number(NULL),  --zx_det.ref_doc_trx_id,
        zx_det.start_expense_date,
        sum(zx_det.assessable_value),
        zx_det.document_sub_type,
        to_char(NULL),    --zx_det.line_intended_use,
        to_char(NULL),    --zx_det.product_category,
        to_char(NULL),    --zx_det.product_description,
        to_char(NULL),    --zx_det.product_fisc_classification,
        to_number(NULL),    --zx_det.product_id,
        zx_det.supplier_exchange_rate,
        zx_det.supplier_tax_invoice_date,
        zx_det.supplier_tax_invoice_number,
        zx_det.tax_invoice_date,
        zx_det.tax_invoice_number,
        zx_det.trx_business_category,
        zx_det.user_defined_fisc_class,
        sum(zx_dist.rec_nrec_tax_amt_tax_curr),
        zx_line.OFFSET_TAX_RATE_CODE,
        sum(zx_dist.orig_rec_nrec_tax_amt),
        sum(zx_line.orig_tax_amt),
        sum(zx_line.orig_tax_amt_tax_curr) ,
        sum(zx_line.orig_taxable_amt),
        sum(zx_line.orig_taxable_amt_tax_curr),
        sum(zx_dist.orig_rec_nrec_tax_amt_tax_curr),
        TO_CHAR(NULL), --ZX_DIST.RECOVERY_RATE_CODE,
        TO_CHAR(NULL), --ZX_DIST.RECOVERY_TYPE_CODE,
        zx_line.tax,
        sum(zx_dist.rec_nrec_tax_amt),
        sum(zx_dist.rec_nrec_tax_amt_funcl_curr),
        sum(zx_line.tax_amt_tax_curr),
        TO_NUMBER(NULL), --zx_line.tax_apportionment_line_number,
        zx_line.tax_currency_code,
        zx_line.tax_date,
        zx_line.tax_determine_date,
        zx_line.tax_jurisdiction_code,
        TO_NUMBER(NULL), --ZX_LINE.TAX_LINE_ID ,
        TO_NUMBER(NULL),  --ZX_LINE.TAX_LINE_NUMBER ,
        TO_CHAR(NULL), --ZX_LINE.TAX_LINE_USER_ATTRIBUTE1 ,
        TO_CHAR(NULL), --ZX_LINE.TAX_LINE_USER_ATTRIBUTE10,
        TO_CHAR(NULL), --ZX_LINE.TAX_LINE_USER_ATTRIBUTE11,
        TO_CHAR(NULL), --ZX_LINE.TAX_LINE_USER_ATTRIBUTE12,
        TO_CHAR(NULL), --ZX_LINE.TAX_LINE_USER_ATTRIBUTE13,
        TO_CHAR(NULL), --ZX_LINE.TAX_LINE_USER_ATTRIBUTE14,
        TO_CHAR(NULL), --ZX_LINE.TAX_LINE_USER_ATTRIBUTE15,
        TO_CHAR(NULL), --ZX_LINE.TAX_LINE_USER_ATTRIBUTE2,
        TO_CHAR(NULL), --ZX_LINE.TAX_LINE_USER_ATTRIBUTE3,
        TO_CHAR(NULL), --ZX_LINE.TAX_LINE_USER_ATTRIBUTE4,
        TO_CHAR(NULL), --ZX_LINE.TAX_LINE_USER_ATTRIBUTE5,
        TO_CHAR(NULL), --ZX_LINE.TAX_LINE_USER_ATTRIBUTE6,
        TO_CHAR(NULL), --ZX_LINE.TAX_LINE_USER_ATTRIBUTE7,
        TO_CHAR(NULL), --ZX_LINE.TAX_LINE_USER_ATTRIBUTE8,
        TO_CHAR(NULL), --ZX_LINE.TAX_LINE_USER_ATTRIBUTE9,
        TO_CHAR(NULL), --ZX_LINE.TAX_LINE_USER_CATEGORY,
        zx_rate.percentage_rate,
        zx_line.tax_rate_code,
        zx_line.tax_rate_id,
        TO_NUMBER(NULL),  --ZX_DIST.REC_NREC_RATE,
        zx_line.tax_regime_code,
        zx_line.tax_status_id,
        zx_line.tax_status_code,
        sum(zx_dist.taxable_amt),
        sum(zx_dist.taxable_amt_funcl_curr),
     --   zx_det.billing_trading_partner_name,
      --  zx_det.billing_trading_partner_number,
        zx_det.bill_from_party_tax_prof_id,
        zx_det.bill_from_site_tax_prof_id,
    --    zx_det.billing_tp_taxpayer_id,
        zx_det.ship_to_site_tax_prof_id,
        zx_det.ship_from_site_tax_prof_id,
        zx_det.ship_to_party_tax_prof_id,
        zx_det.ship_from_party_tax_prof_id,
        ZX_DET.SHIP_THIRD_PTY_ACCT_SITE_ID,
        ZX_DET.BILL_THIRD_PTY_ACCT_SITE_ID,
        ZX_DET.SHIP_TO_CUST_ACCT_SITE_USE_ID,
        ZX_DET.BILL_TO_CUST_ACCT_SITE_USE_ID,
        ZX_DET.SHIP_THIRD_PTY_ACCT_ID,
        ZX_DET.BILL_THIRD_PTY_ACCT_ID,
        zx_line.hq_estb_reg_number,
        zx_line.tax_registration_number,
        zx_line.legal_entity_tax_reg_number,
        zx_det.own_hq_site_tax_prof_id,
        zx_det.own_hq_party_tax_prof_id,
        zx_det.port_of_entry_code,
        zx_line.registration_party_type,
        zx_line.cancel_flag,
        zx_line.historical_flag,
        zx_line.mrc_tax_line_flag,
        zx_line.offset_flag,
        zx_line.reporting_only_flag,
        zx_dist.self_assessed_flag,
        zx_line.tax_amt_included_flag,
        zx_line.tax_only_line_flag,
        zx_dist.recoverable_flag,
        zx_dist.posting_flag,
        zx_dist.reverse_flag,
        zx_det.trx_id,
        to_number(NULL),
        zx_det.entity_code ,
        zx_det.ledger_id,
        ZX_RATE.VAT_TRANSACTION_TYPE_CODE,
        zx_tax.tax_type_code,
        ZX_RATE.TAX_RATE_NAME,
        zx_det.trx_level_type, -- Bug 5393051
        to_number(NULL),  --zx_det.unit_price ,     -- Bug 5439099
        zx_det.trx_line_gl_date --Bug 5523095
   FROM zx_lines zx_line,
        zx_lines_det_factors zx_det,
        zx_rec_nrec_dist zx_dist,
        zx_taxes_vl    zx_tax,
        zx_rates_vl    zx_rate
  WHERE zx_det.internal_organization_id = zx_line.internal_organization_id
    AND zx_det.application_id    = zx_line.application_id
    AND zx_det.application_id    = 200
    AND zx_det.entity_code       = zx_line.entity_code
    AND zx_det.event_class_code  = zx_line.event_class_code
    AND zx_det.trx_id            = zx_line.trx_id
    AND zx_det.trx_line_id            = zx_line.trx_line_id
--    AND zx_det.application_id    = zx_dist.application_id
--    AND zx_det.entity_code       = zx_dist.entity_code
--    AND zx_det.event_class_code  = zx_dist.event_class_code
--    AND zx_det.event_type_code   = zx_dist.event_type_code
--    AND zx_det.trx_id            = zx_dist.trx_id
    AND zx_line.tax_line_id      = zx_dist.tax_line_id
    AND zx_det.tax_reporting_flag = ''Y''
    AND zx_line.tax_id        = zx_tax.tax_id
    AND zx_line.tax_rate_id     =  zx_rate.tax_rate_id '
    ||L_WHERE_GL_TRX_DATE||' '
    ||L_WHERE_TRX_DATE|| ' '
    ||L_WHERE_REGISTER_TYPE|| ' '
    ||L_WHERE_GL_DATE|| ' '
    ||L_WHERE_TRX_NUM|| ' '
    ||L_WHERE_VAT_TRANSACTION_TYPE|| ' '
    ||L_WHERE_TRX_BUSINESS_CATEGORY|| ' '
    ||L_WHERE_TAX_INVOICE_DATE|| ' '
    ||L_WHERE_TAX_JURISDICTION_CODE|| ' '
    ||L_WHERE_FIRST_PTY_TAX_REG_NUM|| ' '
    ||L_WHERE_TAX_REGIME_CODE|| ' '
    ||L_WHERE_TAX|| ' '
    ||L_WHERE_TAX_STATUS_CODE|| ' '
    ||L_WHERE_TAX_RATE_CODE|| ' '
    ||L_WHERE_TAX_TYPE_CODE|| ' '
    ||L_WHERE_CURRENCY_CODE|| ' '
    ||L_WHERE_PARTY_NAME|| ' '
    ||L_WHERE_TRX_CLASS|| ' '
    ||L_WHERE_LEGAL_ENTITY_ID|| ' '
    ||L_WHERE_LEDGER_ID|| ' '
    ||L_WHERE_REPORT_CONTEXT||' '
    ||L_WHERE_ACCOUNTING_STATUS||' '
    ||L_WHERE_REPORTED_STATUS||' '
    ||L_WHERE_ADJUSTED_DOC_NUM||' '
|| 'GROUP BY
        zx_det.application_id,
        zx_line.event_class_code ,
        zx_det.internal_organization_id,
        zx_det.doc_event_status,
        zx_det.application_doc_status,
        zx_det.line_class,
        zx_det.doc_seq_id,
        zx_det.doc_seq_name ,
        zx_det.doc_seq_value,
        zx_det.establishment_id,
        zx_det.batch_source_id,
        zx_det.currency_conversion_date,
        zx_det.currency_conversion_rate,
        zx_det.currency_conversion_type,
        zx_det.minimum_accountable_unit,
        zx_det.precision,
        zx_det.trx_communicated_date,
        zx_det.trx_currency_code,
        zx_line.trx_id,
        zx_det.trx_number,
        zx_det.trx_date,
        zx_det.trx_description,
        zx_det.trx_type_description,
        zx_rate.description,
        zx_det.trx_due_date,
        to_char(null),--zx_det.trx_line_description,
        to_char(null),--zx_line.trx_line_id,
        to_char(null),--zx_line.trx_line_number,
        to_char(null),--zx_line.trx_line_quantity,
        --zx_line.line_amt,
        --zx_det.trx_line_type,
        --zx_det.trx_shipping_date,
        --zx_det.uom_code,
        --zx_det.related_doc_date,
        --zx_det.related_doc_entity_code,
        --zx_det.related_doc_event_class_code,
        --zx_det.related_doc_number,
        --zx_det.related_doc_trx_id,
        --zx_det.applied_from_application_id,
        --zx_line.applied_from_entity_code,
        --zx_line.applied_from_event_class_code,
        --zx_det.applied_from_line_id,
        --zx_line.applied_from_trx_id,
        --zx_line.applied_from_trx_number,
        --zx_det.applied_to_application_id,
        --zx_line.applied_to_entity_code,
        --zx_line.applied_to_event_class_code,
        --zx_line.applied_to_trx_id,
        --zx_det.applied_to_trx_line_id,
        --zx_det.applied_to_trx_number,
        --zx_det.adjusted_doc_application_id,
        --zx_det.adjusted_doc_date,
        --zx_det.adjusted_doc_entity_code,
        --zx_det.adjusted_doc_event_class_code,
        --ZX_DET.ADJUSTED_DOC_NUMBER,
        --zx_det.country_of_supply,
        zx_det.default_taxation_country,
        --zx_det.ref_doc_application_id,
        --zx_det.ref_doc_entity_code,
        --zx_det.ref_doc_event_class_code,
        --zx_det.ref_doc_line_id,
        --zx_det.ref_doc_line_quantity,
        --zx_det.ref_doc_trx_id,
        zx_det.start_expense_date,
        --zx_det.assessable_value,
        zx_det.document_sub_type,
        --zx_det.line_intended_use,
        --zx_det.product_category,
        --zx_det.product_description,
        --zx_det.product_fisc_classification,
        --zx_det.product_id,
        zx_det.supplier_exchange_rate,
        zx_det.supplier_tax_invoice_date,
        zx_det.supplier_tax_invoice_number,
        zx_det.tax_invoice_date,
        zx_det.tax_invoice_number,
        zx_det.trx_business_category,
        zx_det.user_defined_fisc_class,
        zx_line.OFFSET_TAX_RATE_CODE,
        zx_line.tax,
        --zx_line.tax_apportionment_line_number,
        zx_line.tax_currency_code,
        zx_line.tax_date,
        zx_line.tax_determine_date,
        zx_line.tax_jurisdiction_code,
        zx_rate.percentage_rate,
        zx_line.tax_rate_code,
        zx_line.tax_rate_id,
        to_number(null),  --zx_dist.rec_nrec_rate,
        zx_line.tax_regime_code,
        zx_line.tax_status_id,
        zx_line.tax_status_code,
    --    zx_det.billing_trading_partner_name,
     --   zx_det.billing_trading_partner_number,
        zx_det.bill_from_party_tax_prof_id,
        zx_det.bill_from_site_tax_prof_id,
     --   zx_det.billing_tp_taxpayer_id,
        zx_det.ship_to_site_tax_prof_id,
        zx_det.ship_from_site_tax_prof_id,
        zx_det.ship_to_party_tax_prof_id,
        zx_det.ship_from_party_tax_prof_id ,
        ZX_DET.SHIP_THIRD_PTY_ACCT_SITE_ID,
        ZX_DET.BILL_THIRD_PTY_ACCT_SITE_ID,
        ZX_DET.SHIP_TO_CUST_ACCT_SITE_USE_ID,
        ZX_DET.BILL_TO_CUST_ACCT_SITE_USE_ID,
        ZX_DET.SHIP_THIRD_PTY_ACCT_ID,
        ZX_DET.BILL_THIRD_PTY_ACCT_ID,
        zx_line.hq_estb_reg_number,
        zx_line.tax_registration_number,
        zx_line.legal_entity_tax_reg_number,
        zx_det.own_hq_site_tax_prof_id,
        zx_det.own_hq_party_tax_prof_id,
        zx_det.port_of_entry_code,
        zx_line.registration_party_type,
        zx_line.cancel_flag,
        zx_line.historical_flag,
        zx_line.mrc_tax_line_flag,
        zx_line.offset_flag,
        zx_line.reporting_only_flag,
        zx_dist.self_assessed_flag,
        zx_line.tax_amt_included_flag,
        zx_line.tax_only_line_flag,
        zx_dist.recoverable_flag,
        zx_dist.posting_flag ,
        zx_dist.reverse_flag,
        zx_det.trx_id,
        zx_det.entity_code,
        zx_det.ledger_id,
        ZX_RATE.VAT_TRANSACTION_TYPE_CODE,
        --ZX_RATE.RATE_TYPE_CODE,
        zx_tax.tax_type_code,
        ZX_RATE.TAX_RATE_NAME,
  zx_det.trx_level_type,
  --zx_det.unit_price,
  zx_det.trx_line_gl_date';

    g_sql_statement := l_sql_statement ;

  ELSIF G_SUMMARY_LEVEL = 'TRANSACTION_DISTRIBUTION' THEN

     IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.BUILD_SQL',
                      'SQL-2 For Invoice, Credit Memo, Debit Memo: Distribution Level');
     END IF;
    -- bug 8250832 adding hint dynamically
    IF g_gl_date_low IS NOT NULL AND
       g_gl_date_high IS NOT NULL AND
       (g_gl_date_high - g_gl_date_low) < 45 THEN

      l_sql_statement := 'SELECT /*+ cardinality(ZX_DIST 100) use_nl(zx_line) use_nl(zx_tax.b) */ ';
    ELSE
      l_sql_statement := 'SELECT ';
    END IF;
    l_sql_statement := l_sql_statement ||
      ' zx_det.application_id,
        zx_line.event_class_code ,
        zx_det.internal_organization_id,
        zx_det.doc_event_status,
        zx_det.application_doc_status,
        zx_det.line_class,
        zx_det.doc_seq_id ,
        zx_det.doc_seq_name ,
        zx_det.doc_seq_value,
        zx_det.establishment_id,
        zx_det.batch_source_id,
        zx_det.currency_conversion_date,
        zx_det.currency_conversion_rate,
        zx_det.currency_conversion_type,
        zx_det.minimum_accountable_unit,
        zx_det.precision,
        zx_det.trx_communicated_date ,
        zx_det.trx_currency_code,
        zx_line.trx_id,
        zx_det.trx_number,
        zx_det.trx_date,
        zx_det.trx_description,
        zx_det.trx_type_description,
        zx_rate.description,
        zx_det.trx_due_date,
        zx_det.trx_line_description,
        zx_line.trx_line_id,
        zx_line.trx_line_number,
        zx_line.trx_line_quantity,
        zx_line.line_amt,
        zx_det.trx_line_type,
        zx_det.trx_shipping_date,
        zx_det.uom_code,
        zx_det.related_doc_date,
        zx_det.related_doc_entity_code,
        zx_det.related_doc_event_class_code,
        zx_det.related_doc_number,
        zx_det.related_doc_trx_id,
        zx_det.applied_from_application_id,
        zx_line.applied_from_entity_code,
        zx_line.applied_from_event_class_code,
        zx_det.applied_from_line_id,
        zx_line.applied_from_trx_id,
        zx_line.applied_from_trx_number,
        zx_det.applied_to_application_id,
        zx_line.applied_to_entity_code,
        zx_line.applied_to_event_class_code,
        zx_line.applied_to_trx_id,
        zx_det.applied_to_trx_line_id,
        zx_det.applied_to_trx_number,
        zx_det.adjusted_doc_application_id,
        zx_det.adjusted_doc_date,
        zx_det.adjusted_doc_entity_code,
        zx_det.adjusted_doc_event_class_code,
        zx_det.adjusted_doc_number,
        --zx_det.country_of_supply,
        zx_det.default_taxation_country,
        zx_det.merchant_party_document_number,
        zx_det.merchant_party_name,
        zx_det.merchant_party_reference,
        zx_det.merchant_party_tax_reg_number,
        zx_det.merchant_party_taxpayer_id,
        zx_det.ref_doc_application_id,
        zx_det.ref_doc_entity_code,
        zx_det.ref_doc_event_class_code,
        zx_det.ref_doc_line_id,
        zx_det.ref_doc_line_quantity,
        zx_det.ref_doc_trx_id,
        zx_det.start_expense_date,
        zx_det.assessable_value,
        zx_det.document_sub_type,
        zx_det.line_intended_use,
        zx_det.product_category,
        zx_det.product_description,
        zx_det.product_fisc_classification,
        zx_det.product_id,
        zx_det.supplier_exchange_rate,
        zx_det.supplier_tax_invoice_date,
        zx_det.supplier_tax_invoice_number,
        zx_det.tax_invoice_date,
        zx_det.tax_invoice_number,
        zx_det.trx_business_category,
        zx_det.user_defined_fisc_class,
        zx_dist.rec_nrec_tax_amt_tax_curr,
        zx_line.OFFSET_TAX_RATE_CODE,
        zx_dist.orig_rec_nrec_tax_amt,
        zx_line.orig_tax_amt,
        zx_line.orig_tax_amt_tax_curr ,
        zx_line.orig_taxable_amt,
        zx_line.orig_taxable_amt_tax_curr,
        zx_dist.orig_rec_nrec_tax_amt_tax_curr,
        zx_dist.recovery_rate_code,
        zx_dist.recovery_type_code,
        zx_line.tax,
        zx_dist.rec_nrec_tax_amt,
        zx_dist.rec_nrec_tax_amt_funcl_curr,
        zx_line.tax_amt_tax_curr,
        zx_line.tax_apportionment_line_number,
        zx_line.tax_currency_code,
        zx_line.tax_date,
        zx_line.tax_determine_date,
        zx_line.tax_jurisdiction_code,
        zx_line.tax_line_id,
        zx_line.tax_line_number ,
        TO_CHAR(NULL),  --ZX_LINE.TAX_LINE_USER_ATTRIBUTE1 ,
        TO_CHAR(NULL),  --ZX_LINE.TAX_LINE_USER_ATTRIBUTE10,
        TO_CHAR(NULL),  --ZX_LINE.TAX_LINE_USER_ATTRIBUTE11,
        TO_CHAR(NULL),  --ZX_LINE.TAX_LINE_USER_ATTRIBUTE12,
        TO_CHAR(NULL),  --ZX_LINE.TAX_LINE_USER_ATTRIBUTE13,
        TO_CHAR(NULL),  --ZX_LINE.TAX_LINE_USER_ATTRIBUTE14,
        TO_CHAR(NULL),  --ZX_LINE.TAX_LINE_USER_ATTRIBUTE15,
        TO_CHAR(NULL),  --ZX_LINE.TAX_LINE_USER_ATTRIBUTE2,
        TO_CHAR(NULL),  --ZX_LINE.TAX_LINE_USER_ATTRIBUTE3,
        TO_CHAR(NULL),  --ZX_LINE.TAX_LINE_USER_ATTRIBUTE4,
        TO_CHAR(NULL),  --ZX_LINE.TAX_LINE_USER_ATTRIBUTE5,
        TO_CHAR(NULL),  --ZX_LINE.TAX_LINE_USER_ATTRIBUTE6,
        TO_CHAR(NULL),  --ZX_LINE.TAX_LINE_USER_ATTRIBUTE7,
        TO_CHAR(NULL),  --ZX_LINE.TAX_LINE_USER_ATTRIBUTE8,
        TO_CHAR(NULL),  --ZX_LINE.TAX_LINE_USER_ATTRIBUTE9,
        TO_CHAR(NULL),  --ZX_LINE.TAX_LINE_USER_CATEGORY,
        zx_rate.percentage_rate,
        zx_line.tax_rate_code,
        zx_line.tax_rate_id,
        zx_dist.rec_nrec_rate,
        zx_line.tax_regime_code,
        zx_line.tax_status_id,
        zx_line.tax_status_code,
        zx_dist.taxable_amt,     --zx_line.taxable_amt,
        zx_dist.taxable_amt_funcl_curr, --zx_line.taxable_amt_funcl_curr,
--        zx_det.billing_trading_partner_name,
--        zx_det.billing_trading_partner_number,
        zx_det.bill_from_party_tax_prof_id,
        zx_det.bill_from_site_tax_prof_id,
--        zx_det.billing_tp_taxpayer_id,
        zx_det.ship_to_site_tax_prof_id,
        zx_det.ship_from_site_tax_prof_id,
        zx_det.ship_to_party_tax_prof_id  ,
        zx_det.ship_from_party_tax_prof_id ,
        zx_det.ship_third_pty_acct_site_id,
        zx_det.bill_third_pty_acct_site_id,
        zx_det.ship_to_cust_acct_site_use_id,
        zx_det.bill_to_cust_acct_site_use_id,
        zx_det.ship_third_pty_acct_id,
        zx_det.bill_third_pty_acct_id,
        zx_line.hq_estb_reg_number,
        zx_line.tax_registration_number,
        zx_line.legal_entity_tax_reg_number,
        zx_det.own_hq_site_tax_prof_id,
        zx_det.own_hq_party_tax_prof_id,
        zx_det.port_of_entry_code,
        zx_line.registration_party_type,
        DECODE(zx_dist.REVERSED_TAX_DIST_ID,NULL,''N'',''Y''), -- zx_line.cancel_flag,
        zx_line.historical_flag,
        zx_line.mrc_tax_line_flag,
        zx_line.offset_flag,
        zx_line.reporting_only_flag,
        zx_dist.self_assessed_flag,
        zx_line.tax_amt_included_flag,
        zx_line.tax_only_line_flag,
        zx_dist.recoverable_flag,
        zx_dist.posting_flag,
        zx_dist.reverse_flag,
        zx_dist.rec_nrec_tax_dist_id,
        zx_dist.trx_line_dist_id,
        zx_det.entity_code,
        zx_det.ledger_id,
        ZX_RATE.VAT_TRANSACTION_TYPE_CODE,
        zx_tax.tax_type_code,
        ZX_RATE.TAX_RATE_NAME,
        zx_det.trx_level_type,  --Bug 5393051
        zx_det.unit_price ,    -- Bug 5439099
        NVL(zx_dist.gl_date,zx_det.trx_line_gl_date) --Bug 5523095
   FROM zx_lines zx_line,
        zx_lines_det_factors zx_det,
        zx_rec_nrec_dist zx_dist,
        zx_taxes_vl    zx_tax,
        zx_rates_vl    zx_rate
  WHERE zx_det.internal_organization_id = zx_line.internal_organization_id
    AND zx_det.application_id    = zx_line.application_id
    AND zx_det.application_id    = 200
    AND zx_det.entity_code       = zx_line.entity_code
    AND zx_det.event_class_code  = zx_line.event_class_code
    AND zx_det.trx_id            = zx_line.trx_id
    AND zx_det.trx_line_id            = zx_line.trx_line_id --Bug 5443504
--    AND zx_det.application_id    = zx_dist.application_id
--    AND zx_det.entity_code       = zx_dist.entity_code
--    AND zx_det.event_class_code  = zx_dist.event_class_code
--    AND zx_det.event_type_code   = zx_dist.event_type_code
--    AND zx_det.trx_id            = zx_dist.trx_id
    AND zx_line.tax_line_id      = zx_dist.tax_line_id
    AND zx_det.tax_reporting_flag = ''Y''
    AND zx_line.tax_id          = zx_tax.tax_id
    AND zx_line.tax_rate_id     =  zx_rate.tax_rate_id'
    ||L_WHERE_GL_TRX_DATE||' '
    ||L_WHERE_TRX_DATE|| ' '
    ||L_WHERE_REGISTER_TYPE|| ' '
    ||L_WHERE_GL_DATE|| ' '
    ||L_WHERE_TRX_NUM|| ' '
    ||L_WHERE_VAT_TRANSACTION_TYPE|| ' '
    ||L_WHERE_TRX_BUSINESS_CATEGORY|| ' '
    ||L_WHERE_TAX_INVOICE_DATE|| ' '
    ||L_WHERE_TAX_JURISDICTION_CODE|| ' '
    ||L_WHERE_FIRST_PTY_TAX_REG_NUM|| ' '
    ||L_WHERE_TAX_REGIME_CODE|| ' '
    ||L_WHERE_TAX|| ' '
    ||L_WHERE_TAX_STATUS_CODE|| ' '
    ||L_WHERE_TAX_RATE_CODE|| ' '
    ||L_WHERE_TAX_TYPE_CODE|| ' '
    ||L_WHERE_CURRENCY_CODE|| ' '
    ||L_WHERE_PARTY_NAME|| ' '
    ||L_WHERE_TRX_CLASS|| ' '
    ||L_WHERE_LEGAL_ENTITY_ID|| ' '
    ||L_WHERE_LEDGER_ID|| ' '
    ||L_WHERE_REPORT_CONTEXT||' '
    ||L_WHERE_ACCOUNTING_STATUS||' '
    ||L_WHERE_REPORTED_STATUS||' '
    ||L_WHERE_ADJUSTED_DOC_NUM||' ';

    g_sql_statement := l_sql_statement ;

    IF g_report_name ='ZXXTATAT' THEN
      IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.BUILD_SQL',
                        'SQL-2-1 For Invoice, Credit Memo, Debit Memo: Distribution Level');
      END IF;
    l_sql_statement_no_tax := 'SELECT DISTINCT ' ||
      ' zx_det.application_id,
        zx_det.event_class_code, -- zx_line.event_class_code ,
        zx_det.internal_organization_id,
        zx_det.doc_event_status,
        zx_det.application_doc_status,
        zx_det.line_class,
        zx_det.doc_seq_id ,
        zx_det.doc_seq_name ,
        zx_det.doc_seq_value,
        zx_det.establishment_id,
        zx_det.batch_source_id,
        zx_det.currency_conversion_date,
        zx_det.currency_conversion_rate,
        zx_det.currency_conversion_type,
        zx_det.minimum_accountable_unit,
        zx_det.precision,
        zx_det.trx_communicated_date ,
        zx_det.trx_currency_code,
        zx_det.trx_id, -- zx_line.trx_id,
        zx_det.trx_number,
        zx_det.trx_date,
        zx_det.trx_description,
        zx_det.trx_type_description,
        zx_rate.description,
        zx_det.trx_due_date,
        zx_det.trx_line_description,
        zx_det.trx_line_id, -- zx_line.trx_line_id,
        ap_dist.invoice_line_number, -- zx_line.trx_line_number,
        to_char(NULL), -- zx_line.trx_line_quantity,
        ap_dist.amount, --zx_line.line_amt,
        zx_det.trx_line_type,
        zx_det.trx_shipping_date,
        zx_det.uom_code,
        zx_det.related_doc_date,
        zx_det.related_doc_entity_code,
        zx_det.related_doc_event_class_code,
        zx_det.related_doc_number,
        zx_det.related_doc_trx_id,
        zx_det.applied_from_application_id,
        zx_det.applied_from_entity_code,
        zx_det.applied_from_event_class_code,
        zx_det.applied_from_line_id,
        zx_det.applied_from_trx_id, -- zx_line.applied_from_trx_id,
        zx_det.applied_from_trx_number,  -- zx_line.applied_from_trx_number,
        zx_det.applied_to_application_id,
        zx_det.applied_to_entity_code, -- zx_line.applied_to_entity_code,
        zx_det.applied_to_event_class_code,
        zx_det.applied_to_trx_id,
        zx_det.applied_to_trx_line_id,
        zx_det.applied_to_trx_number,
        zx_det.adjusted_doc_application_id,
        zx_det.adjusted_doc_date,
        zx_det.adjusted_doc_entity_code,
        zx_det.adjusted_doc_event_class_code,
        zx_det.adjusted_doc_number,
        zx_det.default_taxation_country,
        zx_det.merchant_party_document_number,
        zx_det.merchant_party_name,
        zx_det.merchant_party_reference,
        zx_det.merchant_party_tax_reg_number,
        zx_det.merchant_party_taxpayer_id,
        zx_det.ref_doc_application_id,
        zx_det.ref_doc_entity_code,
        zx_det.ref_doc_event_class_code,
        zx_det.ref_doc_line_id,
        zx_det.ref_doc_line_quantity,
        zx_det.ref_doc_trx_id,
        zx_det.start_expense_date,
        zx_det.assessable_value,
        zx_det.document_sub_type,
        zx_det.line_intended_use,
        zx_det.product_category,
        zx_det.product_description,
        zx_det.product_fisc_classification,
        zx_det.product_id,
        zx_det.supplier_exchange_rate,
        zx_det.supplier_tax_invoice_date,
        zx_det.supplier_tax_invoice_number,
        zx_det.tax_invoice_date,
        zx_det.tax_invoice_number,
        zx_det.trx_business_category,
        zx_det.user_defined_fisc_class,
        to_number(null), -- zx_dist.rec_nrec_tax_amt_tax_curr,
        to_char(null), -- zx_line.OFFSET_TAX_RATE_CODE,
        to_number(null), -- zx_dist.orig_rec_nrec_tax_amt,
        to_number(null),-- zx_line.orig_tax_amt,
        to_number(null), -- zx_line.orig_tax_amt_tax_curr ,
        to_number(null), -- zx_line.orig_taxable_amt,
        to_number(null), -- zx_line.orig_taxable_amt_tax_curr,
        to_number(null), -- zx_dist.orig_rec_nrec_tax_amt_tax_curr,
        to_char(null), -- zx_dist.recovery_rate_code,
        to_char(null), -- zx_dist.recovery_type_code,
        to_char(null),-- zx_line.tax,
        to_number(null),-- zx_dist.rec_nrec_tax_amt,
        to_number(null),-- zx_dist.rec_nrec_tax_amt_funcl_curr,
        to_number(null),-- zx_line.tax_amt_tax_curr,
        to_number(null), -- zx_line.tax_apportionment_line_number,
        to_char(null), -- zx_line.tax_currency_code,
        to_char(null), --zx_line.tax_date,
        to_char(null), -- zx_line.tax_determine_date,
        to_char(null),-- zx_line.tax_jurisdiction_code,
        to_number(null),-- zx_line.tax_line_id,
        to_number(null),-- zx_line.tax_line_number ,
        TO_CHAR(NULL),  --ZX_LINE.TAX_LINE_USER_ATTRIBUTE1 ,
        TO_CHAR(NULL),  --ZX_LINE.TAX_LINE_USER_ATTRIBUTE10,
        TO_CHAR(NULL),  --ZX_LINE.TAX_LINE_USER_ATTRIBUTE11,
        TO_CHAR(NULL),  --ZX_LINE.TAX_LINE_USER_ATTRIBUTE12,
        TO_CHAR(NULL),  --ZX_LINE.TAX_LINE_USER_ATTRIBUTE13,
        TO_CHAR(NULL),  --ZX_LINE.TAX_LINE_USER_ATTRIBUTE14,
        TO_CHAR(NULL),  --ZX_LINE.TAX_LINE_USER_ATTRIBUTE15,
        TO_CHAR(NULL),  --ZX_LINE.TAX_LINE_USER_ATTRIBUTE2,
        TO_CHAR(NULL),  --ZX_LINE.TAX_LINE_USER_ATTRIBUTE3,
        TO_CHAR(NULL),  --ZX_LINE.TAX_LINE_USER_ATTRIBUTE4,
        TO_CHAR(NULL),  --ZX_LINE.TAX_LINE_USER_ATTRIBUTE5,
        TO_CHAR(NULL),  --ZX_LINE.TAX_LINE_USER_ATTRIBUTE6,
        TO_CHAR(NULL),  --ZX_LINE.TAX_LINE_USER_ATTRIBUTE7,
        TO_CHAR(NULL),  --ZX_LINE.TAX_LINE_USER_ATTRIBUTE8,
        TO_CHAR(NULL),  --ZX_LINE.TAX_LINE_USER_ATTRIBUTE9,
        TO_CHAR(NULL),  --ZX_LINE.TAX_LINE_USER_CATEGORY,
        zx_rate.percentage_rate,
        zx_rate.tax_rate_code,
        ap_dist.tax_code_id, -- zx_line.tax_rate_id,
        to_number(null), --zx_dist.rec_nrec_rate,
        to_char(null), --zx_line.tax_regime_code,
        to_number(null), -- zx_line.tax_status_id,
        to_char(null), -- zx_line.tax_status_code,
        ap_dist.amount, -- zx_dist.taxable_amt,
        nvl(ap_dist.base_amount,ap_dist.amount), --zx_dist.taxable_amt_funcl_curr,
        zx_det.bill_from_party_tax_prof_id,
        zx_det.bill_from_site_tax_prof_id,
        zx_det.ship_to_site_tax_prof_id,
        zx_det.ship_from_site_tax_prof_id,
        zx_det.ship_to_party_tax_prof_id  ,
        zx_det.ship_from_party_tax_prof_id ,
        zx_det.ship_third_pty_acct_site_id,
        zx_det.bill_third_pty_acct_site_id,
        zx_det.ship_to_cust_acct_site_use_id,
        zx_det.bill_to_cust_acct_site_use_id,
        zx_det.ship_third_pty_acct_id,
        zx_det.bill_third_pty_acct_id,
        to_number(null), --zx_line.hq_estb_reg_number,
        to_number(null), --zx_line.tax_registration_number,
        to_number(null), --zx_line.legal_entity_tax_reg_number,
        zx_det.own_hq_site_tax_prof_id,
        zx_det.own_hq_party_tax_prof_id,
        zx_det.port_of_entry_code,
        to_char(null), --zx_line.registration_party_type,
        to_char(null), -- DECODE(zx_dist.REVERSED_TAX_DIST_ID,NULL,''N'',''Y''),
        zx_det.historical_flag, --zx_line.historical_flag,
        to_char(null), --zx_line.mrc_tax_line_flag,
        to_char(null), --zx_line.offset_flag,
        to_char(null), --zx_line.reporting_only_flag,
        to_char(null),--zx_dist.self_assessed_flag,
        to_char(null),--zx_line.tax_amt_included_flag,
        to_char(null),--zx_line.tax_only_line_flag,
        to_char(null),--zx_dist.recoverable_flag,
        nvl(ap_dist.posted_flag,''N''), -- zx_dist.posting_flag,
        ap_dist.reversal_flag, -- zx_dist.reverse_flag,
        ap_dist.detail_tax_dist_id, -- zx_dist.rec_nrec_tax_dist_id,
        ap_dist.invoice_distribution_id, -- zx_dist.trx_line_dist_id,
        zx_det.entity_code,
        zx_det.ledger_id,
        ZX_RATE.VAT_TRANSACTION_TYPE_CODE,
        to_char(null), --zx_tax.tax_type_code,
        ZX_RATE.TAX_RATE_NAME,
        zx_det.trx_level_type,
        zx_det.unit_price ,
        nvl(ap_dist.accounting_date,zx_det.trx_line_gl_date)
   FROM zx_lines_det_factors zx_det,
        ap_invoice_distributions_all ap_dist,
        zx_rates_vl    zx_rate
  WHERE zx_det.application_id  = 200
    AND zx_det.entity_code = ''AP_INVOICES''
    AND zx_det.event_class_code = ''STANDARD INVOICES''
    AND zx_det.internal_organization_id = ap_dist.org_id
    AND zx_det.trx_id = ap_dist.invoice_id
    AND ap_dist.invoice_line_number = zx_det.trx_line_id
    AND ap_dist.line_type_lookup_code = ''ITEM''
    AND zx_det.tax_reporting_flag = ''Y''
    AND zx_det.historical_flag = ''Y''
    AND nvl(ap_dist.posted_flag,''N'') = ''Y''
    AND nvl(zx_rate.source_id,zx_rate.tax_rate_id)= ap_dist.tax_code_id
    AND NOT EXISTS
        (SELECT 1
           FROM zx_lines tax
          WHERE tax.trx_id = zx_det.trx_id
           AND tax.application_id = 200
           AND zx_det.internal_organization_id = tax.internal_organization_id
           AND  zx_det.trx_line_id = tax.trx_line_id
           AND zx_det.application_id    = tax.application_id
           AND zx_det.entity_code = tax.entity_code
           AND zx_det.event_class_code = tax.event_class_code
           AND zx_det.trx_level_type  = tax.trx_level_type)'
    ||L_WHERE_GL_TRX_DATE_NO_TAX||' '
    ||L_WHERE_TRX_DATE_NO_TAX|| ' '
    ||L_WHERE_REGISTER_TYPE|| ' '
    ||L_WHERE_GL_DATE_NO_TAX|| ' '
    ||L_WHERE_TRX_NUM|| ' '
    ||L_WHERE_VAT_TRANSACTION_TYPE|| ' '
    ||L_WHERE_TRX_BUSINESS_CATEGORY|| ' '
    ||L_WHERE_TAX_INVOICE_DATE|| ' '
    ||L_WHERE_TAX_JURIS_CODE_NO_TAX|| ' '
    ||L_WHERE_FIRST_PTY_NUM_NO_TAX|| ' '
    ||L_WHERE_TAX_REGIME_CODE_NO_TAX|| ' '
    ||L_WHERE_TAX_NO_TAX|| ' '
    ||L_WHERE_TAX_STATUS_CODE_NO_TAX|| ' '
    ||L_WHERE_TAX_RATE_CODE_NO_TAX|| ' '
    ||L_WHERE_TAX_TYPE_CODE_NO_TAX|| ' '
    ||L_WHERE_CURRENCY_CODE|| ' '
    ||L_WHERE_PARTY_NAME|| ' '
    ||L_WHERE_TRX_CLASS|| ' '
    ||L_WHERE_LEGAL_ENTITY_ID_NO_TAX|| ' '
    ||L_WHERE_LEDGER_ID_NO_TAX|| ' '
    ||L_WHERE_REPORT_CONTEXT||' '
   -- ||L_WHERE_ACCOUNTING_STATUS||' '
   -- ||L_WHERE_REPORTED_STATUS||' '
    ||L_WHERE_ADJUSTED_DOC_NO_TAX||' ';

    g_sql_statement_no_tax := l_sql_statement_no_tax;
   END IF; --End g_report_name = 'ZXXTATAT'
  END IF; -- End G_SUMMARY_LEVEL = 'TRANSACTION_DISTRIBUTION'

  IF G_SUMMARY_LEVEL = 'TRANSACTION_LINE' THEN

      IF (g_level_procedure >= g_current_runtime_level ) THEN
         FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.BUILD_SQL',
                      'SQL-3 For Invoice, Credit Memo, Debit Memo: Line Level');
      END IF;
    -- bug 8250832 adding hint dynamically
    IF g_gl_date_low IS NOT NULL AND
       g_gl_date_high IS NOT NULL AND
       (g_gl_date_high - g_gl_date_low) < 45 THEN
      l_sql_statement := 'SELECT /*+ cardinality(ZX_DIST 100) use_nl(zx_line) use_nl(zx_tax.b) */ ';
    ELSE
      l_sql_statement := 'SELECT ';
    END IF;
    l_sql_statement := l_sql_statement ||
      ' zx_det.application_id,
        zx_line.event_class_code,
        zx_det.internal_organization_id,
        zx_det.doc_event_status,
        zx_det.application_doc_status,
        zx_det.line_class,
        zx_det.doc_seq_id,
        zx_det.doc_seq_name,
        zx_det.doc_seq_value,
        zx_det.establishment_id,
        zx_det.batch_source_id,
        zx_det.currency_conversion_date,
        zx_det.currency_conversion_rate,
        zx_det.currency_conversion_type,
        zx_det.minimum_accountable_unit,
        zx_det.precision,
        zx_det.trx_communicated_date,
        zx_det.trx_currency_code,
        zx_line.trx_id,
        zx_det.trx_number,
        zx_det.trx_date,
        zx_det.trx_description,
        zx_det.trx_type_description,
        zx_rate.description,
        zx_det.trx_due_date,
        zx_det.trx_line_description,
        zx_line.trx_line_id,
        zx_line.trx_line_number,
        zx_line.trx_line_quantity,
        sum(zx_line.line_amt),
        zx_det.trx_line_type,
        zx_det.trx_shipping_date,
        zx_det.uom_code,
        zx_det.related_doc_date,
        zx_det.related_doc_entity_code,
        zx_det.related_doc_event_class_code,
        zx_det.related_doc_number,
        zx_det.related_doc_trx_id,
        zx_det.applied_from_application_id,
        zx_line.applied_from_entity_code,
        zx_line.applied_from_event_class_code,
        zx_det.applied_from_line_id,
        zx_line.applied_from_trx_id,
        zx_line.applied_from_trx_number,
        zx_det.applied_to_application_id,
        zx_line.applied_to_entity_code,
        zx_line.applied_to_event_class_code,
        zx_line.applied_to_trx_id,
        zx_det.applied_to_trx_line_id,
        zx_det.applied_to_trx_number,
        zx_det.adjusted_doc_application_id,
        zx_det.adjusted_doc_date,
        zx_det.adjusted_doc_entity_code,
        zx_det.adjusted_doc_event_class_code,
       ZX_DET.ADJUSTED_DOC_NUMBER,
        --zx_det.country_of_supply,
        zx_det.default_taxation_country,
        zx_det.merchant_party_document_number,
        zx_det.merchant_party_name,
        zx_det.merchant_party_reference,
        zx_det.merchant_party_tax_reg_number,
        zx_det.merchant_party_taxpayer_id,
        zx_det.ref_doc_application_id,
        zx_det.ref_doc_entity_code,
        zx_det.ref_doc_event_class_code,
        zx_det.ref_doc_line_id,
        zx_det.ref_doc_line_quantity,
        zx_det.ref_doc_trx_id,
        zx_det.start_expense_date,
        zx_det.assessable_value,
        zx_det.document_sub_type,
        zx_det.line_intended_use,
        zx_det.product_category,
        zx_det.product_description,
        zx_det.product_fisc_classification,
        zx_det.product_id,
        zx_det.supplier_exchange_rate,
        zx_det.supplier_tax_invoice_date,
        zx_det.supplier_tax_invoice_number,
        zx_det.tax_invoice_date,
        zx_det.tax_invoice_number,
        zx_det.trx_business_category,
        zx_det.user_defined_fisc_class,
        sum(zx_dist.rec_nrec_tax_amt_tax_curr),
        zx_line.OFFSET_TAX_RATE_CODE,
        sum(zx_dist.orig_rec_nrec_tax_amt),
        sum(zx_line.orig_tax_amt),
        sum(zx_line.orig_tax_amt_tax_curr),
        sum(zx_line.orig_taxable_amt),
        sum(zx_line.orig_taxable_amt_tax_curr),
        sum(zx_dist.orig_rec_nrec_tax_amt_tax_curr),
        zx_dist.recovery_rate_code,
        zx_dist.recovery_type_code,
        zx_line.tax,
        sum(zx_dist.rec_nrec_tax_amt),
        sum(zx_dist.rec_nrec_tax_amt_funcl_curr),
        sum(zx_line.tax_amt_tax_curr),
        zx_line.tax_apportionment_line_number,
        zx_line.tax_currency_code,
        zx_line.tax_date,
        zx_line.tax_determine_date,
        zx_line.tax_jurisdiction_code,
        to_char(null),--zx_line.tax_line_id ,
        to_char(null),--zx_line.tax_line_number ,
        zx_line.attribute1 ,
        zx_line.attribute2 ,
        zx_line.attribute3 ,
        zx_line.attribute4 ,
        zx_line.attribute5 ,
        zx_line.attribute6 ,
        zx_line.attribute7 ,
        zx_line.attribute8 ,
        zx_line.attribute9 ,
        zx_line.attribute10,
        zx_line.attribute11,
        zx_line.attribute12,
        zx_line.attribute13,
        zx_line.attribute14,
        zx_line.attribute15,
        zx_line.attribute_category ,
        zx_rate.percentage_rate,
        zx_line.tax_rate_code,
        zx_line.tax_rate_id,
        zx_dist.rec_nrec_rate,
        zx_line.tax_regime_code,
        zx_line.tax_status_id,
        zx_line.tax_status_code,
        sum(zx_dist.taxable_amt),
        sum(zx_dist.taxable_amt_funcl_curr) ,
      --  zx_det.billing_trading_partner_name,
      --  zx_det.billing_trading_partner_number,
        zx_det.bill_from_party_tax_prof_id,
        zx_det.bill_from_site_tax_prof_id,
   --     zx_det.billing_tp_taxpayer_id,
        zx_det.ship_to_site_tax_prof_id,
        zx_det.ship_from_site_tax_prof_id,
        zx_det.ship_to_party_tax_prof_id  ,
        zx_det.ship_from_party_tax_prof_id ,
        ZX_DET.SHIP_THIRD_PTY_ACCT_SITE_ID,
        ZX_DET.BILL_THIRD_PTY_ACCT_SITE_ID,
        ZX_DET.SHIP_TO_CUST_ACCT_SITE_USE_ID,
        ZX_DET.BILL_TO_CUST_ACCT_SITE_USE_ID,
        ZX_DET.SHIP_THIRD_PTY_ACCT_ID,
        ZX_DET.BILL_THIRD_PTY_ACCT_ID,
        zx_line.hq_estb_reg_number ,
        zx_line.tax_registration_number,
        zx_line.legal_entity_tax_reg_number,
        zx_det.own_hq_site_tax_prof_id,
        zx_det.own_hq_party_tax_prof_id,
        zx_det.port_of_entry_code,
        zx_line.registration_party_type,
        zx_line.cancel_flag,
        zx_line.historical_flag,
        zx_line.mrc_tax_line_flag,
        zx_line.offset_flag,
        zx_line.reporting_only_flag,
        zx_dist.self_assessed_flag,
        zx_line.tax_amt_included_flag,
        zx_line.tax_only_line_flag,
        zx_dist.recoverable_flag,
        zx_dist.posting_flag,
        zx_dist.reverse_flag,
        zx_line.trx_line_id,
        to_number(NULL),
        zx_det.entity_code,
        zx_det.ledger_id,
        ZX_RATE.VAT_TRANSACTION_TYPE_CODE,
        zx_tax.tax_type_code,
        ZX_RATE.TAX_RATE_NAME,
        zx_det.trx_level_type,  -- Bug 5393051
        zx_det.unit_price ,     -- Bug 5439099
        zx_det.trx_line_gl_date -- Bug 5523095
   FROM zx_lines zx_line,
        zx_lines_det_factors zx_det,
        zx_rec_nrec_dist zx_dist,
        zx_taxes_vl    zx_tax,
        zx_rates_vl    zx_rate
  WHERE zx_det.internal_organization_id = zx_line.internal_organization_id
    AND zx_det.application_id    = zx_line.application_id
    AND zx_det.application_id    = 200
    AND zx_det.entity_code       = zx_line.entity_code
    AND zx_det.event_class_code  = zx_line.event_class_code
    AND zx_det.trx_id            = zx_line.trx_id
    AND zx_det.trx_line_id            = zx_line.trx_line_id --Bug 5443504
--    AND zx_det.application_id    = zx_dist.application_id
--    AND zx_det.entity_code       = zx_dist.entity_code
--    AND zx_det.event_class_code  = zx_dist.event_class_code
--    AND zx_det.event_type_code   = zx_dist.event_type_code
--    AND zx_det.trx_id            = zx_dist.trx_id
    AND zx_line.tax_line_id      = zx_dist.tax_line_id
    AND zx_line.tax_id          = zx_tax.tax_id
    AND zx_line.tax_rate_id     =  zx_rate.tax_rate_id
    AND zx_det.tax_reporting_flag = ''Y'' '
    ||L_WHERE_GL_TRX_DATE||' '
    ||L_WHERE_TRX_DATE|| ' '
    ||L_WHERE_REGISTER_TYPE|| ' '
    ||L_WHERE_GL_DATE|| ' '
    ||L_WHERE_TRX_NUM|| ' '
    ||L_WHERE_VAT_TRANSACTION_TYPE|| ' '
    ||L_WHERE_TRX_BUSINESS_CATEGORY|| ' '
    ||L_WHERE_TAX_INVOICE_DATE|| ' '
   ||L_WHERE_TAX_JURISDICTION_CODE|| ' '
    ||L_WHERE_FIRST_PTY_TAX_REG_NUM|| ' '
    ||L_WHERE_TAX_REGIME_CODE|| ' '
    ||L_WHERE_TAX|| ' '
    ||L_WHERE_TAX_STATUS_CODE|| ' '
    ||L_WHERE_TAX_RATE_CODE|| ' '
    ||L_WHERE_TAX_TYPE_CODE|| ' '
    ||L_WHERE_CURRENCY_CODE|| ' '
    ||L_WHERE_PARTY_NAME|| ' '
    ||L_WHERE_TRX_CLASS|| ' '
    ||L_WHERE_LEGAL_ENTITY_ID|| ' '
    ||L_WHERE_LEDGER_ID|| ' '
    ||L_WHERE_REPORT_CONTEXT||' '
    ||L_WHERE_ACCOUNTING_STATUS||' '
    ||L_WHERE_REPORTED_STATUS||' '
    ||L_WHERE_ADJUSTED_DOC_NUM||' '
    ||'GROUP BY
        zx_det.application_id,
        zx_line.event_class_code ,
        zx_det.internal_organization_id,
        zx_det.doc_event_status,
        zx_det.application_doc_status,
        zx_det.line_class,
        zx_det.doc_seq_id ,
        zx_det.doc_seq_name ,
        zx_det.doc_seq_value,
        zx_det.establishment_id,
        zx_det.batch_source_id,
        zx_det.currency_conversion_date,
        zx_det.currency_conversion_rate,
        zx_det.currency_conversion_type,
        zx_det.minimum_accountable_unit,
        zx_det.precision,
        zx_det.trx_communicated_date ,
        zx_det.trx_currency_code,
        zx_line.trx_id   ,
        zx_det.trx_number ,
        zx_det.trx_date,
        zx_det.trx_description,
        zx_det.trx_type_description,
  zx_rate.description,
        zx_det.trx_due_date,
        zx_det.trx_line_description,
        zx_line.trx_line_id,
        zx_line.trx_line_number,
        zx_line.trx_line_quantity,
        --zx_line.line_amt,
        zx_det.trx_line_type,
        zx_det.trx_shipping_date,
        zx_det.uom_code,
        zx_det.related_doc_date,
        zx_det.related_doc_entity_code,
        zx_det.related_doc_event_class_code,
        zx_det.related_doc_number,
        zx_det.related_doc_trx_id,
        zx_det.applied_from_application_id,
        zx_line.applied_from_entity_code,
        zx_line.applied_from_event_class_code,
        zx_det.applied_from_line_id,
        zx_line.applied_from_trx_id,
        zx_line.applied_from_trx_number,
        zx_det.applied_to_application_id,
        zx_line.applied_to_entity_code,
        zx_line.applied_to_event_class_code,
        zx_line.applied_to_trx_id,
        zx_det.applied_to_trx_line_id,
        zx_det.applied_to_trx_number,
        zx_det.adjusted_doc_application_id,
        zx_det.adjusted_doc_date,
        zx_det.adjusted_doc_entity_code,
        zx_det.adjusted_doc_event_class_code,
       ZX_DET.ADJUSTED_DOC_NUMBER,
        --zx_det.country_of_supply,
        zx_det.default_taxation_country,
--        zx_det.default_taxation_country, --Bug 5374021
        zx_det.merchant_party_document_number,
        zx_det.merchant_party_name,
        zx_det.merchant_party_reference,
        zx_det.merchant_party_tax_reg_number,
        zx_det.merchant_party_taxpayer_id,
        zx_det.ref_doc_application_id,
        zx_det.ref_doc_entity_code,
        zx_det.ref_doc_event_class_code,
        zx_det.ref_doc_line_id,
        zx_det.ref_doc_line_quantity,
        zx_det.ref_doc_trx_id,
        zx_det.start_expense_date,
        zx_det.assessable_value,
        zx_det.document_sub_type,
        zx_det.line_intended_use,
        zx_det.product_category,
        zx_det.product_description,
        zx_det.product_fisc_classification,
        zx_det.product_id,
        zx_det.supplier_exchange_rate,
        zx_det.supplier_tax_invoice_date,
        zx_det.supplier_tax_invoice_number,
        zx_det.tax_invoice_date,
        zx_det.tax_invoice_number,
        zx_det.trx_business_category,
        zx_det.user_defined_fisc_class,
        --zx_dist.rec_nrec_tax_amt_tax_curr,
        zx_line.OFFSET_TAX_RATE_CODE,
        --zx_dist.orig_rec_nrec_tax_amt,
        --zx_line.orig_tax_amt,
        --zx_line.orig_tax_amt_tax_curr ,
        --zx_line.orig_taxable_amt,
        --zx_line.orig_taxable_amt_tax_curr,
        --zx_dist.orig_rec_nrec_tax_amt_tax_curr,
        zx_dist.recovery_rate_code,
        zx_dist.recovery_type_code,
        zx_line.tax,
        --zx_dist.rec_nrec_tax_amt,
        --zx_dist.rec_nrec_tax_amt_funcl_curr,
        --zx_line.tax_amt_tax_curr,
        zx_line.tax_apportionment_line_number,
        zx_line.tax_currency_code,
        zx_line.tax_date,
        zx_line.tax_determine_date,
        zx_line.tax_jurisdiction_code,
        to_char(null),--zx_line.tax_line_id ,
        to_char(null),--zx_line.tax_line_number ,
        zx_line.attribute1 ,
        zx_line.attribute2 ,
        zx_line.attribute3 ,
        zx_line.attribute4 ,
        zx_line.attribute5 ,
        zx_line.attribute6 ,
        zx_line.attribute7 ,
        zx_line.attribute8 ,
        zx_line.attribute9 ,
        zx_line.attribute10,
        zx_line.attribute11,
        zx_line.attribute12,
        zx_line.attribute13,
        zx_line.attribute14,
        zx_line.attribute15,
        zx_line.attribute_category ,
        zx_rate.percentage_rate,
        zx_line.tax_rate_code,
        zx_line.tax_rate_id,
        zx_dist.rec_nrec_rate,
        zx_line.tax_regime_code,
        zx_line.tax_status_id,
        zx_line.tax_status_code,
        --zx_line.taxable_amt,
        --zx_line.taxable_amt_funcl_curr ,
   --     zx_det.billing_trading_partner_name,
    --    zx_det.billing_trading_partner_number,
        zx_det.bill_from_party_tax_prof_id,
        zx_det.bill_from_site_tax_prof_id,
      --  zx_det.billing_tp_taxpayer_id,
        zx_det.ship_to_site_tax_prof_id,
        zx_det.ship_from_site_tax_prof_id,
        zx_det.ship_to_party_tax_prof_id,
        zx_det.ship_from_party_tax_prof_id,
        ZX_DET.SHIP_THIRD_PTY_ACCT_SITE_ID, --Bug 5374021
        ZX_DET.BILL_THIRD_PTY_ACCT_SITE_ID, --Bug 5374021
        ZX_DET.SHIP_TO_CUST_ACCT_SITE_USE_ID, --Bug 5374021
        ZX_DET.BILL_TO_CUST_ACCT_SITE_USE_ID, --Bug 5374021
        ZX_DET.SHIP_THIRD_PTY_ACCT_ID, --Bug 5374021
        ZX_DET.BILL_THIRD_PTY_ACCT_ID,--Bug 5374021
        zx_line.hq_estb_reg_number,
        zx_line.tax_registration_number,
        zx_line.legal_entity_tax_reg_number,
        zx_det.own_hq_site_tax_prof_id,
        zx_det.own_hq_party_tax_prof_id,
        zx_det.port_of_entry_code,
        zx_line.registration_party_type,
        zx_line.cancel_flag,
        zx_line.historical_flag,
        zx_line.mrc_tax_line_flag,
        zx_line.offset_flag,
        zx_line.reporting_only_flag,
        zx_dist.self_assessed_flag,
        zx_line.tax_amt_included_flag,
        zx_line.tax_only_line_flag,
        zx_dist.recoverable_flag,
        zx_dist.posting_flag,
        zx_dist.reverse_flag,
  zx_line.trx_line_id , --Bug 5374021
  zx_det.entity_code,
        zx_det.ledger_id,
        ZX_RATE.VAT_TRANSACTION_TYPE_CODE,
        --ZX_RATE.RATE_TYPE_CODE,
        zx_tax.tax_type_code,
        ZX_RATE.TAX_RATE_NAME,
  zx_det.trx_level_type ,
  zx_det.unit_price,
  zx_det.trx_line_gl_date';
  --Bug 5523095

    g_sql_statement := l_sql_statement ;

    END IF;  -- summary level

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.BUILD_SQL.END',
                                      'ZX_AP_EXTRACT_PKG: BUILD_SQL(-)');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
         g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
         FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
         FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','build_sql- '|| g_error_buffer);
         FND_MSG_PUB.Add;
         IF (g_level_unexpected >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_unexpected,
                          'ZX.TRL.ZX_AP_EXTRACT_PKG.build_sql',
                           g_error_buffer);
         END IF;
          g_retcode := 2;

END build_sql;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |   execute_sql_stmt                                                       |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure executes the Dynamic SQL statement built by             |
 |    the procedure BUILD_SQL.                                               |
 |                                                                           |
 |    Called from INSERT_TAX_DATA                                            |
 |                                                                           |
 | SCOPE - Private                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |       11-Jan-2005    Srinivasa Rao Korrapati     Created                  |
 +===========================================================================*/

PROCEDURE execute_sql_stmt IS

   l_sql1          VARCHAR2(3500);
   l_sql2          VARCHAR2(3500);
   l_sql3          VARCHAR2(3500);
   l_sql4          VARCHAR2(3500);
   l_sql5          VARCHAR2(3500);
   l_sql6          VARCHAR2(3500);
   l_sql7          VARCHAR2(3500);
   l_sql8          VARCHAR2(3500);

   l_sql1_no_tax   VARCHAR2(3500);
   l_sql2_no_tax   VARCHAR2(3500);
   l_sql3_no_tax   VARCHAR2(3500);
   l_sql4_no_tax   VARCHAR2(3500);
   l_sql5_no_tax   VARCHAR2(3500);
   l_sql6_no_tax   VARCHAR2(3500);
   l_sql7_no_tax   VARCHAR2(3500);
   l_sql8_no_tax   VARCHAR2(3500);

BEGIN

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.EXECUTE_SQL_STMT.BEGIN',
                                      'ZX_AP_EXTRACT_PKG: EXECUTE_SQL_STMT(+)');
    END IF;


 --  l_sql_statement_tbl(1) := G_COLUMN_LIST_TRX_HDR_LVL;  --AP Transaction level
 --  l_sql_statement_tbl(2) := G_COLUMN_LIST_TRX_DIST_LVL; --AP Distribution level
 --  l_sql_statement_tbl(3) := G_COLUMN_LIST_TRX_LINE_LVL; --AP Line level

  IF (g_level_procedure >= g_current_runtime_level ) THEN
     --Added as part of testing ( for showing all the bind vars values )
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.EXECUTE_SQL_STMT SQL',
     ' Displaying all the Global Bind Variable Values used for the Dynamic SQL Stmt ' );
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.EXECUTE_SQL_STMT SQL',
     'g_report_name  : '||g_report_name);
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.EXECUTE_SQL_STMT SQL',
     'g_gl_date_low  : '||g_gl_date_low);
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.EXECUTE_SQL_STMT SQL',
     'g_gl_date_high  : '||g_gl_date_high);
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.EXECUTE_SQL_STMT SQL',
     'G_LEDGER_ID  : '||G_LEDGER_ID);
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.EXECUTE_SQL_STMT SQL',
     'g_trx_date_low  : '||g_trx_date_low);
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.EXECUTE_SQL_STMT SQL',
     'g_trx_date_high  : '||g_trx_date_high);
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.EXECUTE_SQL_STMT SQL',
     'g_trx_number_low  : '||g_trx_number_low);
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.EXECUTE_SQL_STMT SQL',
     'g_trx_number_high  : '||g_trx_number_high);
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.EXECUTE_SQL_STMT SQL',
     'g_vat_transaction_type_code  : '||g_vat_transaction_type_code);
      --    FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.FETCH_AR_TRX_INFO SQL',
    -- 'g_document_sub_type  : '||g_document_sub_type);
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.EXECUTE_SQL_STMT SQL',
     'g_trx_business_category  : '||g_trx_business_category);
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.EXECUTE_SQL_STMT SQL',
     'g_tax_invoice_date_low  : '||g_tax_invoice_date_low);
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.EXECUTE_SQL_STMT SQL',
     'g_tax_invoice_date_high  : '||g_tax_invoice_date_high);
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.EXECUTE_SQL_STMT SQL',
     'g_tax_jurisdiction_code  : '||g_tax_jurisdiction_code);
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.EXECUTE_SQL_STMT SQL',
     'g_first_party_tax_reg_num  : '||g_first_party_tax_reg_num);
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.EXECUTE_SQL_STMT SQL',
     'g_tax_regime_code  : '||g_tax_regime_code);
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.EXECUTE_SQL_STMT SQL',
     'g_tax  : '||g_tax);
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.EXECUTE_SQL_STMT SQL',
     'g_tax_status_code  : '||g_tax_status_code);
               FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.EXECUTE_SQL_STMT SQL',
     'g_tax_rate_code_low  : '||g_tax_rate_code_low);
               FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.EXECUTE_SQL_STMT SQL',
     'g_tax_rate_code_high  : '||g_tax_rate_code_high);
               FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.EXECUTE_SQL_STMT SQL',
     'g_tax_type_code_low  : '||g_tax_type_code_low);
         FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.EXECUTE_SQL_STMT SQL',
     'g_tax_type_code_high  : '||g_tax_type_code_high);
                    FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.EXECUTE_SQL_STMT SQL',
     'g_currency_code_low  : '||g_currency_code_low);
                    FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.EXECUTE_SQL_STMT SQL',
     'g_currency_code_high  : '||g_currency_code_high);
                    FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.EXECUTE_SQL_STMT SQL',
     'g_legal_entity_id  : '||g_legal_entity_id);
                    FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.EXECUTE_SQL_STMT SQL',
     'g_ledger_id  : '||g_ledger_id);

     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.EXECUTE_SQL_STMT SQL', 'Dynamic sql statement  : '||g_summary_level);
      l_sql1 := substr(g_sql_statement,1,3000);
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.EXECUTE_SQL_STMT SQL', 'g_sql_statement  : '||l_sql1);
      l_sql2 := substr(g_sql_statement,3001,3000);
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.EXECUTE_SQL_STMT SQL', 'g_sql_statement  : '||l_sql2);
      l_sql3 := substr(g_sql_statement,6001,3000);
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.EXECUTE_SQL_STMT SQL', 'g_sql_statement  : '||l_sql3);
      l_sql4 := substr(g_sql_statement,9001,3000);
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.EXECUTE_SQL_STMT SQL', 'g_sql_statement  : '||l_sql4);
      l_sql5 := substr(g_sql_statement,12001,3000);
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.EXECUTE_SQL_STMT SQL', 'g_sql_statement  : '||l_sql5);
      l_sql6 := substr(g_sql_statement,15001,3000);
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.EXECUTE_SQL_STMT SQL', 'g_sql_statement  : '||l_sql6);
      l_sql7 := substr(g_sql_statement,18001,3000);
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.EXECUTE_SQL_STMT SQL', 'g_sql_statement  : '||l_sql7);
      l_sql8 := substr(g_sql_statement,21001,3000);
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.EXECUTE_SQL_STMT SQL', 'g_sql_statement  : '||l_sql8);

     l_sql1_no_tax := substr(g_sql_statement_no_tax,1,3000);
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.EXECUTE_SQL_STMT SQL', 'g_sql_statement_no_tax  : '||l_sql1_no_tax);
      l_sql2_no_tax := substr(g_sql_statement_no_tax,3001,3000);
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.EXECUTE_SQL_STMT SQL', 'g_sql_statement_no_tax  : '||l_sql2_no_tax);
      l_sql3_no_tax := substr(g_sql_statement_no_tax,6001,3000);
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.EXECUTE_SQL_STMT SQL', 'g_sql_statement_no_tax  : '||l_sql3_no_tax);
      l_sql4_no_tax := substr(g_sql_statement_no_tax,9001,3000);
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.EXECUTE_SQL_STMT SQL', 'g_sql_statement_no_tax  : '||l_sql4_no_tax);
      l_sql5_no_tax := substr(g_sql_statement_no_tax,12001,3000);
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.EXECUTE_SQL_STMT SQL', 'g_sql_statement_no_tax  : '||l_sql5_no_tax);
      l_sql6_no_tax := substr(g_sql_statement_no_tax,15001,3000);
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.EXECUTE_SQL_STMT SQL', 'g_sql_statement_no_tax  : '||l_sql6_no_tax);
      l_sql7_no_tax := substr(g_sql_statement_no_tax,18001,3000);
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.EXECUTE_SQL_STMT SQL', 'g_sql_statement_no_tax  : '||l_sql7_no_tax);
      l_sql8_no_tax := substr(g_sql_statement_no_tax,21001,3000);
     FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.EXECUTE_SQL_STMT SQL', 'g_sql_statement_no_tax  : '||l_sql8_no_tax);
  END IF;



        fetch_tax_info(g_sql_statement);
        IF g_report_name = 'ZXXTATAT' THEN
           IF (g_level_procedure >= g_current_runtime_level ) THEN
               FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.EXECUTE_SQL_STMT SQL',
                                      'Calling fetch_tax_info explicitly for TAT report');
           END IF;
           fetch_tax_info(g_sql_statement_no_tax);
        END IF;

/*   FOR i IN 1..l_sql_statement_tbl.COUNT LOOP
     IF l_sql_statement_tbl(i) IS NOT NULL THEN
        FETCH_TAX_INFO(l_sql_statement_tbl(i));
     END IF;
     COMMIT;
   END LOOP; */

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.execute_sql_stmt.END',
                                      'ZX_AP_EXTRACT_PKG: execute_sql_stmt(-)');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
         g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
         FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
         FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','execute_sql_stmt- '|| g_error_buffer);
         FND_MSG_PUB.Add;
         IF (g_level_unexpected >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_unexpected,
                          'ZX.TRL.ZX_AP_EXTRACT_PKG.execute_sql_stmt',
                           g_error_buffer);
         END IF;
          g_retcode := 2;

END execute_sql_stmt;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |   fetch_tax_info                                                          |
 | DESCRIPTION                                                               |
 |   This procedure executes dyanamic sql statement using bind variables     |
 |                                                                           |
 | SCOPE - Private                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |       11-Jan-2005    Srinivasa Rao Korrapati       Created                |
 |                                                                           |
 +===========================================================================*/
PROCEDURE fetch_tax_info (
          p_statement     IN VARCHAR2)
IS

    TYPE zx_rep_detail_curtype IS REF CURSOR;
    zx_rep_detail_csr    zx_rep_detail_curtype;
    i                    BINARY_INTEGER;

BEGIN

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.fetch_tax_info.BEGIN',
                                          'ZX_AP_EXTRACT_PKG: fetch_tax_info(+)');
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.fetch_tax_info',
                                          'Open cursor');
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.fetch_tax_info',
                                          'Gl Date Low/High'||to_char(g_gl_date_low)||' '
                                         ||to_char(g_gl_date_high));
    END IF;

     OPEN zx_rep_detail_csr FOR p_statement
    USING g_trx_date_low,
          g_trx_date_high,
          g_trx_date_low_ln,
          g_trx_date_high_ln,
          --      g_register_type,
          g_gl_date_low,
          g_gl_date_high,
          g_trx_number_low,
          g_trx_number_high,
          g_vat_transaction_type_code,
          --g_document_sub_type,
          g_trx_business_category,
          g_tax_invoice_date_low ,
          g_tax_invoice_date_high,
          g_tax_jurisdiction_code,
          g_first_party_tax_reg_num,
          g_tax_regime_code,
          g_tax,
          g_tax_status_code,
          g_tax_rate_code_low,
          g_tax_rate_code_high,
          g_tax_type_code_low,
          g_tax_type_code_high,
          g_currency_code_low,
          g_currency_code_high,
          -- g_batch_date_low ,
          -- g_batch_date_high,
          g_party_name,
          --g_batch_name,
          g_legal_entity_id ,
          g_ledger_id,
          g_adjusted_doc_from,
          g_adjusted_doc_to;
          -- g_trading_partner_id;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.FETCH_TAX_INFO',
                                      'After USING Clause Call :');
    END IF;

    i := 1;

    init_gt_variables;
    g_created_by        := fnd_global.user_id;
    g_creation_date     := sysdate;
    g_last_updated_by   := fnd_global.user_id;
    g_last_update_login := fnd_global.login_id;
    g_last_update_date  := sysdate;

  -- insert when fetch up to 1000 rows

    LOOP
    FETCH zx_rep_detail_csr INTO
        gt_application_id(i),
        gt_event_class_code(i),
        gt_internal_organization_id(i),
        gt_doc_event_status(i),
        gt_application_doc_status(i),
        gt_line_class(i),
        gt_doc_seq_id(i),
        gt_doc_seq_name(i),
        gt_doc_seq_value(i),
        gt_establishment_id(i),
        gt_batch_source_id(i),
        gt_currency_conversion_date(i),
        gt_currency_conversion_rate(i),
        gt_currency_conversion_type(i),
        gt_minimum_accountable_unit(i),
        gt_precision(i),
        gt_trx_communicated_date(i),
        gt_trx_currency_code(i),
        gt_trx_id(i),
        gt_trx_number(i),
        gt_trx_date(i),
        gt_trx_description(i),
        gt_trx_type_description(i),
        gt_tax_rate_code_description(i),
        gt_trx_due_date(i),
        gt_trx_line_description(i),
        gt_trx_line_id(i),
        gt_trx_line_number(i),
        gt_trx_line_quantity(i),
        gt_trx_line_amt(i),
        gt_trx_line_type(i),
        gt_trx_shipping_date(i),
        gt_uom_code(i),
        gt_related_doc_date(i),
        gt_related_doc_entity_code(i),
        gt_related_doc_event_cls_code(i),
        gt_related_doc_number(i),
        gt_related_doc_trx_id(i),
        gt_applied_from_appl_id(i),
        gt_applied_from_entity_code(i),
        gt_applied_from_event_cls_code(i),
        gt_applied_from_line_id(i),
        gt_applied_from_trx_id(i),
        gt_applied_from_trx_number(i),
        gt_applied_to_appl_id(i),
        gt_applied_to_entity_code(i),
        gt_applied_to_event_cls_code(i),
        gt_applied_to_trx_id(i),
        gt_applied_to_trx_line_id(i),
        gt_applied_to_trx_number(i),
        gt_adjusted_doc_appl_id(i),
        gt_adjusted_doc_date(i),
        gt_adjusted_doc_entity_code(i),
        gt_adjusted_doc_event_cls_code(i),
        GT_ADJUSTED_DOC_NUMBER(i),
      --  gt_country_of_supply(i),
        gt_default_taxation_country(i),
        gt_merchant_party_doc_num(i),
        gt_merchant_party_name(i),
        gt_merchant_party_reference(i),
        gt_merchant_party_tax_reg_num(i),
        gt_merchant_party_taxpayer_id(i),
        gt_ref_doc_application_id(i),
        gt_ref_doc_entity_code(i),
        gt_ref_doc_event_cls_code(i),
        gt_ref_doc_line_id(i),
        gt_ref_doc_line_quantity(i),
        gt_ref_doc_trx_id(i),
        gt_start_expense_date(i),
        gt_assessable_value(i),
        gt_document_sub_type(i),
        gt_line_intended_use(i),
        gt_product_category(i),
        gt_product_description(i),
        gt_prod_fisc_classification(i),
        gt_product_id(i),
        gt_supplier_exchange_rate(i),
        gt_supplier_tax_invoice_date(i),
        gt_supplier_tax_invoice_num(i),
        gt_tax_invoice_date(i),
        gt_tax_invoice_number(i),
        gt_trx_business_category(i),
        gt_user_defined_fisc_class(i),
        gt_nrec_tax_amt_tax_curr(i),
        gt_offset_tax_rate_code(i),
        gt_orig_rec_nrec_tax_amt(i),
        gt_orig_tax_amt(i),
        gt_orig_tax_amt_tax_curr(i),
        gt_orig_taxable_amt(i),
        gt_orig_taxable_amt_tax_curr(i),
        gt_rec_tax_amt_tax_curr(i),
        gt_recovery_rate_code(i),
        gt_recovery_type_code(i),
        gt_tax(i),
        gt_tax_amt(i),
        gt_tax_amt_funcl_curr(i),
        gt_tax_amt_tax_curr(i),
        gt_tax_apportionment_line_num(i),
        gt_tax_currency_code(i),
        gt_tax_date(i),
        gt_tax_determine_date(i),
        gt_tax_jurisdiction_code(i),
        gt_tax_line_id(i),
        gt_tax_line_number(i),
        gt_tax_line_user_attribute1(i),
        gt_tax_line_user_attribute2(i),
        gt_tax_line_user_attribute3(i),
        gt_tax_line_user_attribute4(i),
        gt_tax_line_user_attribute5(i),
        gt_tax_line_user_attribute6(i),
        gt_tax_line_user_attribute7(i),
        gt_tax_line_user_attribute8(i),
        gt_tax_line_user_attribute9(i),
        gt_tax_line_user_attribute10(i),
        gt_tax_line_user_attribute11(i),
        gt_tax_line_user_attribute12(i),
        gt_tax_line_user_attribute13(i),
        gt_tax_line_user_attribute14(i),
        gt_tax_line_user_attribute15(i),
        gt_tax_line_user_category(i),
        gt_tax_rate(i),
        gt_tax_rate_code(i),
        gt_tax_rate_id(i),
        gt_tax_recovery_rate(i),
        gt_tax_regime_code(i),
        gt_tax_status_id(i),
        gt_tax_status_code(i),
        gt_taxable_amt(i),
        gt_taxable_amt_funcl_curr(i),
     -- gt_billing_tp_name(i),
     -- gt_billing_tp_number(i),
        gt_bill_from_pty_tax_prof_id(i),
        gt_bill_from_site_tax_prof_id(i),
      --gt_billing_tp_taxpayer_id(i),
        gt_ship_to_site_tax_prof_id(i),
        gt_ship_from_site_tax_prof_id(i),
        gt_ship_to_pty_tax_prof_id(i),
        gt_ship_from_pty_tax_prof_id(i),
        GT_SHIPPING_TP_ADDRESS_ID(i),
        GT_BILLING_TP_ADDRESS_ID(i),
        GT_SHIPPING_TP_SITE_ID(i),
        GT_BILLING_TP_SITE_ID(i),
        GT_SHIPPING_TP_ID(i),
        GT_BILLING_TRADING_PARTNER_ID(i),
        gt_hq_estb_reg_number(i),
        gt_tax_line_registration_num(i),
        gt_legal_entity_tax_reg_num(i),
        gt_own_hq_pty_site_prof_id(i),
        gt_own_hq_pty_tax_prof_id(i),
        gt_port_of_entry_code(i),
        gt_registration_party_type(i),
        gt_cancel_flag(i),
        gt_historical_flag(i),
        gt_mrc_tax_line_flag(i),
        gt_offset_flag(i),
        gt_reporting_only_flag(i),
        gt_self_assessed_flag(i),
        gt_tax_amt_included_flag(i),
        gt_tax_only_flag(i),
        gt_tax_recoverable_flag(i),
        gt_posted_flag(i),
        gt_reverse_flag(i),
        gt_actg_source_id(i),
        gt_taxable_item_source_id(i),
        gt_entity_code(i),
        gt_ledger_id(i),
        GT_TAX_RATE_VAT_TRX_TYPE_CODE(i),
        GT_TAX_TYPE_CODE(i),
        GT_TAX_RATE_CODE_NAME(i),
  gt_trx_level_type(i),--Bug 5393051
  gt_unit_price_tbl(i), -- Bug 5439099
  gt_gl_date(i); --Bug 5523095

       /* IF (g_level_procedure >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.fetch_tax_info',
                                      'Before insert Call  :' ||to_char(GT_TRX_ID.count));
        END IF;
    */
        IF zx_rep_detail_csr%FOUND THEN
           IF (g_level_procedure >= g_current_runtime_level ) THEN
               FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.fetch_tax_info',
                                      'zx_rep_detail_csr Found :' );
           END IF;

 -- populate EXTRACT_REPORT_LINE_NUMBER

          gt_extract_rep_line_num(i) := g_extract_line_num;
          g_extract_line_num := g_extract_line_num + 1;

          IF (i >= c_lines_per_insert) THEN
             insert_tax_info;
             --COMMIT; Bug 8262631

             IF (g_level_procedure >= g_current_runtime_level ) THEN
                 FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.FETCH_TAX_INFO',
                                      'After insert_tax_info Call :' );
             END IF;
             i := 1;
             init_gt_variables;
          ELSE
             i := i + 1;
          END IF;
        ELSE
          IF (g_level_procedure >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.FETCH_TAX_INFO',
                                      'Before INSERT_TAX_INFO 2 Call :' );
          END IF;

      -- total rows fetched less than 1000
      -- insert the rest of rows

          insert_tax_info;
          --COMMIT; Bug 8262631

          IF (g_level_procedure >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.FETCH_TAX_INFO',
                                      'After INSERT_TAX_INFO 2 :' );
          END IF;

          CLOSE zx_rep_detail_csr;
          EXIT;
        END IF;
    END LOOP;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.fetch_tax_info.END',
                                      'ZX_AP_EXTRACT_PKG: fetch_tax_info(-)');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
         g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
         FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
         FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','populate_tax_data- '|| g_error_buffer);
         FND_MSG_PUB.Add;
         IF (g_level_unexpected >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_unexpected,
                          'ZX.TRL.ZX_AP_EXTRACT_PKG.fetch_tax_info',
                           g_error_buffer);
         END IF;

         g_retcode := 2;

END fetch_tax_info;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |   INIT_GT_VARIABLES                                                       |
 | DESCRIPTION                                                               |
 |    This proceure initializes all global variables                         |
 |                                                                           |
 | SCOPE - Private                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |       11-Jan-2005    Srinivasa Rao Korrapati       Created                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE init_gt_variables
IS

BEGIN

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.init_gt_variables.BEGIN',
                                      'ZX_AP_EXTRACT_PKG: init_gt_variables(+)');
    END IF;

        gt_extract_rep_line_num.delete;
        gt_application_id.delete;
        gt_event_class_code.delete;
        gt_internal_organization_id.delete;
        gt_doc_event_status.delete;
        gt_application_doc_status.delete;
        gt_line_class.delete;
        gt_doc_seq_id.delete;
        gt_doc_seq_name.delete;
        gt_doc_seq_value.delete;
        gt_establishment_id.delete;
        gt_batch_source_id.delete;
        gt_currency_conversion_date.delete;
        gt_currency_conversion_rate.delete;
        gt_currency_conversion_type.delete;
        gt_minimum_accountable_unit.delete;
        gt_precision.delete;
        gt_trx_communicated_date.delete;
        gt_trx_currency_code.delete;
        gt_trx_id.delete;
        gt_trx_number.delete;
        gt_trx_date.delete;
        gt_trx_description.delete;
        gt_trx_type_description.delete;
        gt_trx_due_date.delete;
        gt_trx_line_description.delete;
        gt_trx_line_id.delete;
        gt_trx_line_number.delete;
        gt_trx_line_quantity.delete;
        gt_trx_line_amt.delete;
        gt_trx_line_type.delete;
        gt_trx_shipping_date.delete;
        gt_uom_code.delete;
        gt_related_doc_date.delete;
        gt_related_doc_entity_code.delete;
        gt_related_doc_event_cls_code.delete;
        gt_related_doc_number.delete;
        gt_related_doc_trx_id.delete;
        gt_applied_from_appl_id.delete;
        gt_applied_from_entity_code.delete;
        gt_applied_from_event_cls_code.delete;
        gt_applied_from_line_id.delete;
        gt_applied_from_trx_id.delete;
        gt_applied_from_trx_number.delete;
        gt_applied_to_appl_id.delete;
        gt_applied_to_entity_code.delete;
        gt_applied_to_event_cls_code.delete;
        gt_applied_to_trx_id.delete;
        gt_applied_to_trx_line_id.delete;
        gt_applied_to_trx_number.delete;
        gt_adjusted_doc_appl_id.delete;
        gt_adjusted_doc_date.delete;
        gt_adjusted_doc_entity_code.delete;
        gt_adjusted_doc_event_cls_code.delete;
        GT_ADJUSTED_DOC_NUMBER.delete;
      --  gt_country_of_supply.delete;
        gt_default_taxation_country.delete;
        gt_merchant_party_doc_num.delete;
        gt_merchant_party_name.delete;
        gt_merchant_party_reference.delete;
        gt_merchant_party_tax_reg_num.delete;
        gt_merchant_party_taxpayer_id.delete;
        gt_ref_doc_application_id.delete;
        gt_ref_doc_entity_code.delete;
        gt_ref_doc_event_cls_code.delete;
        gt_ref_doc_line_id.delete;
        gt_ref_doc_line_quantity.delete;
        gt_ref_doc_trx_id.delete;
        gt_start_expense_date.delete;
        gt_assessable_value.delete;
        gt_document_sub_type.delete;
        gt_line_intended_use.delete;
        gt_product_category.delete;
        gt_product_description.delete;
        gt_prod_fisc_classification.delete;
        gt_product_id.delete;
        gt_supplier_exchange_rate.delete;
        gt_supplier_tax_invoice_date.delete;
        gt_supplier_tax_invoice_num.delete;
        gt_tax_invoice_date.delete;
        gt_tax_invoice_number.delete;
        gt_trx_business_category.delete;
        gt_user_defined_fisc_class.delete;
        gt_nrec_tax_amt_tax_curr.delete;
        gt_offset_tax_rate_code.delete;
        gt_orig_rec_nrec_tax_amt.delete;
        gt_orig_tax_amt.delete;
        gt_orig_tax_amt_tax_curr.delete;
        gt_orig_taxable_amt.delete;
        gt_orig_taxable_amt_tax_curr.delete;
        gt_rec_tax_amt_tax_curr.delete;
        gt_recovery_rate_code.delete;
        gt_recovery_type_code.delete;
        gt_tax.delete;
        gt_tax_amt.delete;
        gt_tax_amt_funcl_curr.delete;
        gt_tax_amt_tax_curr.delete;
        gt_tax_apportionment_line_num.delete;
        gt_tax_currency_code.delete;
        gt_tax_date.delete;
        gt_tax_determine_date.delete;
        gt_tax_jurisdiction_code.delete;
        gt_tax_line_id.delete;
        gt_tax_line_number.delete;
        gt_tax_line_user_attribute1.delete;
        gt_tax_line_user_attribute2.delete;
        gt_tax_line_user_attribute3.delete;
        gt_tax_line_user_attribute4.delete;
        gt_tax_line_user_attribute5.delete;
        gt_tax_line_user_attribute6.delete;
        gt_tax_line_user_attribute7.delete;
        gt_tax_line_user_attribute8.delete;
        gt_tax_line_user_attribute9.delete;
        gt_tax_line_user_attribute10.delete;
        gt_tax_line_user_attribute11.delete;
        gt_tax_line_user_attribute12.delete;
        gt_tax_line_user_attribute13.delete;
        gt_tax_line_user_attribute14.delete;
        gt_tax_line_user_attribute15.delete;
        gt_tax_line_user_category.delete;
        gt_tax_rate.delete;
        gt_tax_rate_code.delete;
        gt_tax_rate_id.delete;
        gt_tax_recovery_rate.delete;
        gt_tax_regime_code.delete;
        gt_tax_status_id.delete;
        gt_tax_status_code.delete;
        gt_taxable_amt.delete;
        gt_taxable_amt_funcl_curr.delete;
--        gt_billing_tp_name.delete;
 --       gt_billing_tp_number.delete;
        gt_bill_from_pty_tax_prof_id.delete;
        gt_bill_from_site_tax_prof_id.delete;
--        gt_billing_tp_taxpayer_id.delete;
        gt_ship_to_site_tax_prof_id.delete;
        gt_ship_from_site_tax_prof_id.delete;
        gt_ship_to_pty_tax_prof_id.delete;
        gt_ship_from_pty_tax_prof_id.delete;
    GT_SHIPPING_TP_ADDRESS_ID.delete;
    GT_BILLING_TP_ADDRESS_ID.delete;
    GT_SHIPPING_TP_SITE_ID.delete;
    GT_BILLING_TP_SITE_ID.delete;
    GT_SHIPPING_TP_ID.delete;
    GT_BILLING_TRADING_PARTNER_ID.delete;
        gt_hq_estb_reg_number.delete;
        gt_tax_line_registration_num.delete;
        gt_legal_entity_tax_reg_num.delete;
        gt_own_hq_pty_site_prof_id.delete;
        gt_own_hq_pty_tax_prof_id.delete;
        gt_port_of_entry_code.delete;
        gt_registration_party_type.delete;
        gt_cancel_flag.delete;
        gt_historical_flag.delete;
        gt_mrc_tax_line_flag.delete;
        gt_offset_flag.delete;
        gt_reporting_only_flag.delete;
        gt_self_assessed_flag.delete;
        gt_tax_amt_included_flag.delete;
        gt_tax_only_flag.delete;
        gt_tax_recoverable_flag.delete;
        gt_posted_flag.delete;
        gt_reverse_flag.delete;
        gt_actg_source_id.delete;
        gt_entity_code.delete;
        gt_ledger_id.delete;
        GT_TAXABLE_ITEM_SOURCE_ID.DELETE;
        GT_TAX_RATE_VAT_TRX_TYPE_CODE.DELETE;
        GT_TAX_TYPE_CODE.DELETE;
        GT_TAX_RATE_CODE_NAME.DELETE;
  gt_tax_rate_code_description.delete;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.init_gt_variables.END',
                                      'ZX_AP_EXTRACT_PKG: init_gt_variables(-)');
    END IF;

END init_gt_variables;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |   insert_tax_info                                                         |
 | DESCRIPTION                                                               |
 |    This procedure inserts payables tax data into ZX_REP_TRX_DETAIL_T table|
 |                                                                           |
 | SCOPE - Private                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |       11-Jan-2005    Srinivasa Rao Korrapati      Created                 |
 |                                                                           |
 +===========================================================================*/
PROCEDURE insert_tax_info
IS
    l_count     NUMBER;

BEGIN

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.insert_tax_info.BEGIN',
                                      'ZX_AP_EXTRACT_PKG: insert_tax_info(+)');
    END IF;

    l_count  := GT_TRX_ID.COUNT;


    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.insert_tax_info',
                                      ' Record Count = ' ||to_char(GT_TRX_ID.COUNT));
    END IF;

    FORALL i IN 1 .. l_count
    INSERT INTO ZX_REP_TRX_DETAIL_T(
        DETAIL_TAX_LINE_ID,
        APPLICATION_ID,
        EXTRACT_REPORT_LINE_NUMBER,
        EVENT_CLASS_CODE,
        INTERNAL_ORGANIZATION_ID,
        DOC_EVENT_STATUS,
        APPLICATION_DOC_STATUS,
        TRX_LINE_CLASS,
        DOC_SEQ_ID,
        DOC_SEQ_NAME,
        DOC_SEQ_VALUE,
        ESTABLISHMENT_ID,
        TRX_BATCH_SOURCE_ID,
        CURRENCY_CONVERSION_DATE,
        CURRENCY_CONVERSION_RATE,
        CURRENCY_CONVERSION_TYPE,
        MINIMUM_ACCOUNTABLE_UNIT,
        PRECISION,
        TRX_COMMUNICATED_DATE ,
        TRX_CURRENCY_CODE,
        TRX_ID,
        TRX_NUMBER,
        TRX_DATE,
        TRX_DESCRIPTION,
        TRX_TYPE_DESCRIPTION,
        TRX_TYPE_MNG,
  TAX_RATE_CODE_DESCRIPTION,
        TRX_DUE_DATE,
        TRX_LINE_DESCRIPTION,
        TRX_LINE_ID,
        TRX_LINE_NUMBER,
        TRX_LINE_QUANTITY,
        TRX_LINE_AMT,
        TRX_LINE_TYPE,
        TRX_SHIPPING_DATE,
        UOM_CODE,
        RELATED_DOC_DATE,
        RELATED_DOC_ENTITY_CODE,
        RELATED_DOC_EVENT_CLASS_CODE,
        RELATED_DOC_NUMBER,
        RELATED_DOC_TRX_ID,
        APPLIED_FROM_APPLICATION_ID,
        APPLIED_FROM_ENTITY_CODE,
        APPLIED_FROM_EVENT_CLASS_CODE,
        APPLIED_FROM_LINE_ID,
        APPLIED_FROM_TRX_ID,
        APPLIED_FROM_TRX_NUMBER,
        APPLIED_TO_APPLICATION_ID,
        APPLIED_TO_ENTITY_CODE,
        APPLIED_TO_EVENT_CLASS_CODE,
        APPLIED_TO_TRX_ID,
        APPLIED_TO_TRX_LINE_ID,
        APPLIED_TO_TRX_NUMBER       ,
        ADJUSTED_DOC_APPLICATION_ID,
        ADJUSTED_DOC_DATE,
        ADJUSTED_DOC_ENTITY_CODE,    --ok
        ADJUSTED_DOC_EVENT_CLASS_CODE,
        ADJUSTED_DOC_NUMBER ,
       -- COUNTRY_OF_SUPPLY,
        DEFAULT_TAXATION_COUNTRY,
        MERCHANT_PARTY_DOCUMENT_NUMBER,
        MERCHANT_PARTY_NAME,
        MERCHANT_PARTY_REFERENCE,
        MERCHANT_PARTY_TAX_REG_NUMBER,
        MERCHANT_PARTY_TAXPAYER_ID,
        REF_DOC_APPLICATION_ID,
        REF_DOC_ENTITY_CODE,
        REF_DOC_EVENT_CLASS_CODE,
        REF_DOC_LINE_ID,
        REF_DOC_LINE_QUANTITY,
        REF_DOC_TRX_ID,     --ok
        START_EXPENSE_DATE,
        ASSESSABLE_VALUE,
        DOCUMENT_SUB_TYPE,
        LINE_INTENDED_USE,
        PRODUCT_CATEGORY,
        PRODUCT_DESCRIPTION,
        PRODUCT_FISC_CLASSIFICATION,
        PRODUCT_ID,
        SUPPLIER_EXCHANGE_RATE,
        SUPPLIER_TAX_INVOICE_DATE,
        SUPPLIER_TAX_INVOICE_NUMBER,
        TAX_INVOICE_DATE,
        TAX_INVOICE_NUMBER,
        TRX_BUSINESS_CATEGORY,
        USER_DEFINED_FISC_CLASS,
        NREC_TAX_AMT_TAX_CURR,
        OFFSET_TAX_RATE_CODE,
        ORIG_REC_NREC_TAX_AMT,
        ORIG_TAX_AMT,
        ORIG_TAX_AMT_TAX_CURR ,
        ORIG_TAXABLE_AMT,
        ORIG_TAXABLE_AMT_TAX_CURR,
        REC_TAX_AMT_TAX_CURR,
        RECOVERY_RATE_CODE,
        RECOVERY_TYPE_CODE,   --ok
        TAX,
        TAX_AMT,
        TAX_AMT_FUNCL_CURR,
        TAX_AMT_TAX_CURR ,
        TAX_APPORTIONMENT_LINE_NUMBER,
        TAX_CURRENCY_CODE,
        TAX_DATE,
        TAX_DETERMINE_DATE,
        TAX_JURISDICTION_CODE,
        TAX_LINE_ID,
        TAX_LINE_NUMBER,
        TAX_LINE_USER_ATTRIBUTE1,
        TAX_LINE_USER_ATTRIBUTE2,
        TAX_LINE_USER_ATTRIBUTE3,
        TAX_LINE_USER_ATTRIBUTE4,
        TAX_LINE_USER_ATTRIBUTE5,
        TAX_LINE_USER_ATTRIBUTE6,
        TAX_LINE_USER_ATTRIBUTE7,
        TAX_LINE_USER_ATTRIBUTE8 ,
        TAX_LINE_USER_ATTRIBUTE9 ,
        TAX_LINE_USER_ATTRIBUTE10 ,
        TAX_LINE_USER_ATTRIBUTE11 ,
        TAX_LINE_USER_ATTRIBUTE12 ,
        TAX_LINE_USER_ATTRIBUTE13 ,
        TAX_LINE_USER_ATTRIBUTE14 ,
        TAX_LINE_USER_ATTRIBUTE15 ,
        TAX_LINE_USER_CATEGORY   ,     --ok
        TAX_RATE,
        TAX_RATE_CODE,
        TAX_RATE_ID  ,
        TAX_RECOVERY_RATE,
        TAX_REGIME_CODE,
        TAX_STATUS_ID,
        TAX_STATUS_CODE,
        TAXABLE_AMT,
        TAXABLE_AMT_FUNCL_CURR ,
       -- BILLING_TP_NAME,
       -- BILLING_TP_NUMBER,
        BILL_FROM_PARTY_TAX_PROF_ID,
        BILL_FROM_SITE_TAX_PROF_ID,
        --BILLING_TP_TAXPAYER_ID,
        SHIP_TO_SITE_TAX_PROF_ID  ,
        SHIP_FROM_SITE_TAX_PROF_ID,
        SHIP_TO_PARTY_TAX_PROF_ID  ,
        SHIP_FROM_PARTY_TAX_PROF_ID  ,
        SHIPPING_TP_ADDRESS_ID,    --SHIP_THIRD_PTY_ACCT_SITE_ID
        BILLING_TP_ADDRESS_ID,     --bill_third_pty_acct_site_id
        SHIPPING_TP_SITE_ID,       --ship_to_cust_acct_site_use_id
        BILLING_TP_SITE_ID,        --bill_to_cust_acct_site_use_id
        SHIPPING_TRADING_PARTNER_ID, --ship_third_pty_acct_id
        BILLING_TRADING_PARTNER_ID,  -- bill_third_pty_acct_id
        HQ_ESTB_REG_NUMBER ,
        TAX_LINE_REGISTRATION_NUMBER,
        LEGAL_ENTITY_TAX_REG_NUMBER,
        OWN_HQ_PARTY_SITE_PROF_ID,
        OWN_HQ_PARTY_TAX_PROF_ID,
        PORT_OF_ENTRY_CODE,
        REGISTRATION_PARTY_TYPE,
        CANCEL_FLAG,
        HISTORICAL_FLAG,
        MRC_TAX_LINE_FLAG,
        OFFSET_FLAG,
        REPORTING_ONLY_FLAG,
        SELF_ASSESSED_FLAG,
        TAX_AMT_INCLUDED_FLAG,
        TAX_ONLY_FLAG,
        TAX_RECOVERABLE_FLAG,
        CREATED_BY ,
        CREATION_DATE ,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,
        REQUEST_ID,
        EXTRACT_SOURCE_LEDGER,
        POSTED_FLAG,
        REVERSE_FLAG,
        ACTG_SOURCE_ID,
        TAXABLE_ITEM_SOURCE_ID,
  ENTITY_CODE,
        LEDGER_ID,
        TAX_RATE_VAT_TRX_TYPE_CODE,
        TAX_TYPE_CODE,
        TAX_RATE_CODE_NAME,
  trx_level_type, --Bug 5393051
  unit_price,
  gl_date) --Bug 5523095
    VALUES(
        ZX_REP_TRX_DETAIL_T_S.NEXTVAL,
        gt_application_id(i),
        gt_extract_rep_line_num(i),
        gt_event_class_code(i),
        gt_internal_organization_id(i),
        gt_doc_event_status(i),
        gt_application_doc_status(i),
        gt_line_class(i),
        gt_doc_seq_id(i),
        gt_doc_seq_name(i),
        gt_doc_seq_value(i),
        gt_establishment_id(i),
        gt_batch_source_id(i),
        gt_currency_conversion_date(i),
        gt_currency_conversion_rate(i),
        gt_currency_conversion_type(i),
        gt_minimum_accountable_unit(i),
        gt_precision(i),
        gt_trx_communicated_date(i),
        gt_trx_currency_code(i),
        gt_trx_id(i),
        gt_trx_number(i),
        gt_trx_date(i),
        gt_trx_description(i),
        gt_trx_type_description(i),
        gt_trx_type_description(i),
  gt_tax_rate_code_description(i),
        gt_trx_due_date(i),
        gt_trx_line_description(i),
        gt_trx_line_id(i),
        gt_trx_line_number(i),
        gt_trx_line_quantity(i),
        gt_trx_line_amt(i),
        gt_trx_line_type(i),
        gt_trx_shipping_date(i),
        gt_uom_code(i),
        gt_related_doc_date(i),
        gt_related_doc_entity_code(i),
        gt_related_doc_event_cls_code(i),
        gt_related_doc_number(i),
        gt_related_doc_trx_id(i),
        gt_applied_from_appl_id(i),
        gt_applied_from_entity_code(i),
        gt_applied_from_event_cls_code(i),
        gt_applied_from_line_id(i),
        gt_applied_from_trx_id(i),
        gt_applied_from_trx_number(i),
        gt_applied_to_appl_id(i),
        gt_applied_to_entity_code(i),
        gt_applied_to_event_cls_code(i),
        gt_applied_to_trx_id(i),
        gt_applied_to_trx_line_id(i),
        gt_applied_to_trx_number(i),
        gt_adjusted_doc_appl_id(i),
        gt_adjusted_doc_date(i),
        gt_adjusted_doc_entity_code(i),
        gt_adjusted_doc_event_cls_code(i),
        GT_ADJUSTED_DOC_NUMBER(i),
      --  gt_country_of_supply(i),
        gt_default_taxation_country(i),
        gt_merchant_party_doc_num(i),
        gt_merchant_party_name(i),
        gt_merchant_party_reference(i),
        gt_merchant_party_tax_reg_num(i),
        gt_merchant_party_taxpayer_id(i),
        gt_ref_doc_application_id(i),
        gt_ref_doc_entity_code(i),
        gt_ref_doc_event_cls_code(i),
        gt_ref_doc_line_id(i),
        gt_ref_doc_line_quantity(i),
        gt_ref_doc_trx_id(i),
        gt_start_expense_date(i),
        gt_assessable_value(i),
        gt_document_sub_type(i),
        gt_line_intended_use(i),
        gt_product_category(i),
        gt_product_description(i),
        gt_prod_fisc_classification(i),
        gt_product_id(i),
        gt_supplier_exchange_rate(i),
        gt_supplier_tax_invoice_date(i),
        gt_supplier_tax_invoice_num(i),
        gt_tax_invoice_date(i),
        gt_tax_invoice_number(i),
        gt_trx_business_category(i),
        gt_user_defined_fisc_class(i),
        gt_nrec_tax_amt_tax_curr(i),
        gt_offset_tax_rate_code(i),
        gt_orig_rec_nrec_tax_amt(i),
        gt_orig_tax_amt(i),
        gt_orig_tax_amt_tax_curr(i),
        gt_orig_taxable_amt(i),
        gt_orig_taxable_amt_tax_curr(i),
        gt_rec_tax_amt_tax_curr(i),
        gt_recovery_rate_code(i),
        gt_recovery_type_code(i),
        gt_tax(i),
        gt_tax_amt(i),
        gt_tax_amt_funcl_curr(i),
        gt_tax_amt_tax_curr(i),
        gt_tax_apportionment_line_num(i),
        gt_tax_currency_code(i),
        gt_tax_date(i),
        gt_tax_determine_date(i),
        gt_tax_jurisdiction_code(i),
        gt_tax_line_id(i),
        gt_tax_line_number(i),
        gt_tax_line_user_attribute1(i),
        gt_tax_line_user_attribute2(i),
        gt_tax_line_user_attribute3(i),
        gt_tax_line_user_attribute4(i),
        gt_tax_line_user_attribute5(i),
        gt_tax_line_user_attribute6(i),
        gt_tax_line_user_attribute7(i),
        gt_tax_line_user_attribute8(i),
        gt_tax_line_user_attribute9(i),
        gt_tax_line_user_attribute10(i),
        gt_tax_line_user_attribute11(i),
        gt_tax_line_user_attribute12(i),
        gt_tax_line_user_attribute13(i),
        gt_tax_line_user_attribute14(i),
        gt_tax_line_user_attribute15(i),
        gt_tax_line_user_category(i),
        gt_tax_rate(i),
        gt_tax_rate_code(i),
        gt_tax_rate_id(i),
        gt_tax_recovery_rate(i),
        gt_tax_regime_code(i),
        gt_tax_status_id(i),
        gt_tax_status_code(i),
        gt_taxable_amt(i),
        gt_taxable_amt_funcl_curr(i),
       -- gt_billing_tp_name(i),
       -- gt_billing_tp_number(i),
        gt_bill_from_pty_tax_prof_id(i),
        gt_bill_from_site_tax_prof_id(i),
       -- gt_billing_tp_taxpayer_id(i),
        gt_ship_to_site_tax_prof_id(i) ,
        gt_ship_from_site_tax_prof_id(i),
        gt_ship_to_pty_tax_prof_id(i),
        gt_ship_from_pty_tax_prof_id(i),
        GT_SHIPPING_TP_ADDRESS_ID(i),
        GT_BILLING_TP_ADDRESS_ID(i),
        GT_SHIPPING_TP_SITE_ID(i),
        GT_BILLING_TP_SITE_ID(i),
        GT_SHIPPING_TP_ID(i),
        GT_BILLING_TRADING_PARTNER_ID(i),
        gt_hq_estb_reg_number(i),
        gt_tax_line_registration_num(i),
        gt_legal_entity_tax_reg_num(i),
        gt_own_hq_pty_site_prof_id(i),
        gt_own_hq_pty_tax_prof_id(i),
        gt_port_of_entry_code(i),
        gt_registration_party_type(i),
        gt_cancel_flag(i),
        gt_historical_flag(i),
        gt_mrc_tax_line_flag(i),
        gt_offset_flag(i),
        gt_reporting_only_flag(i),
        gt_self_assessed_flag(i),
        gt_tax_amt_included_flag(i),
        gt_tax_only_flag(i),
        gt_tax_recoverable_flag(i),
        g_created_by ,
        g_creation_date ,
        g_last_updated_by,
        g_last_update_date,
        g_last_update_login,
        g_request_id,
        'AP',
        gt_posted_flag(i),
        gt_reverse_flag(i),
        gt_actg_source_id(i),
        gt_taxable_item_source_id(i),
  gt_entity_code(i),
        gt_ledger_id(i),
        GT_TAX_RATE_VAT_TRX_TYPE_CODE(i),
        GT_TAX_TYPE_CODE(i),
        GT_TAX_RATE_CODE_NAME(i),
  gt_trx_level_type(i),  --Bug 5393051
  gt_unit_price_tbl(i),   -- Bug 5439099
  gt_gl_date(i) --Bug 5523095
  )
        RETURNING detail_tax_line_id bulk collect into GT_DETAIL_TAX_LINE_ID ;

     IF (g_level_procedure >= g_current_runtime_level ) THEN
         FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.insert_tax_info',
                      'Number of Tax Lines successfully inserted = '||TO_CHAR(l_count));

        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.INSERT_TAX_INFO.END',
                                      'ZX_AP_EXTRACT_PKG: INIT_GT_VARIABLES(-)');
     END IF;

EXCEPTION
   WHEN OTHERS THEN
        g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
        FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
        FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','populate_tax_data- '|| g_error_buffer);
        FND_MSG_PUB.Add;
        IF (g_level_unexpected >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_unexpected,
                          'ZX.TRL.ZX_AP_EXTRACT_PKG.INSERT_TAX_INFO',
                           g_error_buffer);
        END IF;

         g_retcode := 2;

END insert_tax_info;


/*===========================================================================+
 | FUNCTION                                                                  |
 |   assign_global_parameters                                              |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Assign the global variable to the the output parameters.               |
 |    This procedure is used by AP procedures to get the global              |
 |    variable values from Main package.                                     |
 |                                                                           |
 | SCOPE - Public                                                            |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |       11-Jan-2005    Srinivasa Rao Korrapati       Created                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE assign_global_parameters (
          p_trl_global_variables_rec IN ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE)
IS

BEGIN

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.assign_global_parameTERS.BEGIN',
                                      'ZX_AP_EXTRACT_PKG: assign_global_parametERS(+)');
    END IF;

    g_reporting_level    :=  p_trl_global_variables_rec.reporting_level;
    g_reporting_context    :=  p_trl_global_variables_rec.reporting_context;
-- apai    g_legal_entity_level  :=  p_trl_global_variables_rec.legal_entity_level;
    g_legal_entity_id    :=  p_trl_global_variables_rec.legal_entity_id;
    g_summary_level    :=  p_trl_global_variables_rec.summary_level;
    g_ledger_id      :=  p_trl_global_variables_rec.ledger_id;
    g_register_type    :=  p_trl_global_variables_rec.register_type;
    g_product      :=  p_trl_global_variables_rec.product;
    g_matrix_report    :=  p_trl_global_variables_rec.matrix_report;
    g_currency_code_low    :=  p_trl_global_variables_rec.currency_code_low;
    g_currency_code_high  :=  p_trl_global_variables_rec.currency_code_high;
    g_include_ap_std_trx_class  :=  p_trl_global_variables_rec.include_ap_std_trx_class;
    g_include_ap_dm_trx_class  :=  p_trl_global_variables_rec.include_ap_dm_trx_class;
    g_include_ap_cm_trx_class  :=  p_trl_global_variables_rec.include_ap_cm_trx_class;
    g_include_ap_prep_trx_class  :=  p_trl_global_variables_rec.include_ap_prep_trx_class;
    g_include_ap_mix_trx_class  :=  p_trl_global_variables_rec.include_ap_mix_trx_class;
    g_include_ap_exp_trx_class  :=  p_trl_global_variables_rec.include_ap_exp_trx_class;
    g_include_ap_int_trx_class  :=  p_trl_global_variables_rec.include_ap_int_trx_class;
    g_trx_number_low    :=  p_trl_global_variables_rec.trx_number_low;
    g_trx_number_high    :=  p_trl_global_variables_rec.trx_number_high;
    g_ar_trx_printing_status  :=  p_trl_global_variables_rec.ar_trx_printing_status;
    g_ar_exemption_status  :=  p_trl_global_variables_rec.ar_exemption_status;
    g_gl_date_low    :=  p_trl_global_variables_rec.gl_date_low;
    g_gl_date_high    :=  p_trl_global_variables_rec.gl_date_high;
    g_trx_date_low    :=  p_trl_global_variables_rec.trx_date_low;
    g_trx_date_high    :=  p_trl_global_variables_rec.trx_date_high;
    g_trx_date_low_ln    :=  p_trl_global_variables_rec.trx_date_low;
    g_trx_date_high_ln    :=  p_trl_global_variables_rec.trx_date_high;
    g_gl_period_name_low  :=  p_trl_global_variables_rec.gl_period_name_low;
    g_gl_period_name_high  :=  p_trl_global_variables_rec.gl_period_name_high;
    g_trx_date_period_name_low  :=  p_trl_global_variables_rec.trx_date_period_name_low;
    g_trx_date_period_name_high  :=  p_trl_global_variables_rec.trx_date_period_name_high;
    g_tax_jurisdiction_code     :=      p_trl_global_variables_rec.tax_jurisdiction_code;
    g_first_party_tax_reg_num   :=      p_trl_global_variables_rec.first_party_tax_reg_num;
    g_tax_regime_code    :=  p_trl_global_variables_rec.tax_regime_code;
    g_tax      :=  p_trl_global_variables_rec.tax;
    g_tax_status_code    :=  p_trl_global_variables_rec.tax_status_code;
    g_tax_rate_code_low    :=  p_trl_global_variables_rec.tax_rate_code_low;
    g_tax_rate_code_high  :=  p_trl_global_variables_rec.tax_rate_code_high;
    g_tax_type_code_low    :=  p_trl_global_variables_rec.tax_type_code_low;
    g_tax_type_code_high  :=  p_trl_global_variables_rec.tax_type_code_high;
    g_document_sub_type    :=  p_trl_global_variables_rec.document_sub_type;
    g_trx_business_category  :=  p_trl_global_variables_rec.trx_business_category;
    g_tax_invoice_date_low  :=  p_trl_global_variables_rec.tax_invoice_date_low;
    g_tax_invoice_date_high  :=  p_trl_global_variables_rec.tax_invoice_date_high;
    g_posting_status    :=  p_trl_global_variables_rec.posting_status;
    g_extract_accted_tax_lines  :=  p_trl_global_variables_rec.extract_accted_tax_lines;
    g_include_accounting_segments  :=  p_trl_global_variables_rec.include_accounting_segments;
    g_balancing_segment_low  :=  p_trl_global_variables_rec.balancing_segment_low;
    g_balancing_segment_high  :=  p_trl_global_variables_rec.balancing_segment_high;
    g_include_discounts    :=  p_trl_global_variables_rec.include_discounts;
    g_extract_starting_line_num  :=  p_trl_global_variables_rec.extract_starting_line_num;
    g_request_id    :=  p_trl_global_variables_rec.request_id;
    g_report_name    :=  p_trl_global_variables_rec.report_name;
    g_vat_transaction_type_code  :=  p_trl_global_variables_rec.vat_transaction_type_code;
    g_include_fully_nr_tax_flag  :=  p_trl_global_variables_rec.include_fully_nr_tax_flag;
    g_municipal_tax_type_code_low  :=  p_trl_global_variables_rec.municipal_tax_type_code_low;
    g_municipal_tax_type_code_high  :=  p_trl_global_variables_rec.municipal_tax_type_code_high;
    g_prov_tax_type_code_low  :=  p_trl_global_variables_rec.prov_tax_type_code_low;
    g_prov_tax_type_code_high  :=  p_trl_global_variables_rec.prov_tax_type_code_high;
    g_excise_tax_type_code_low  :=  p_trl_global_variables_rec.excise_tax_type_code_low;
    g_excise_tax_type_code_high  :=  p_trl_global_variables_rec.excise_tax_type_code_high;
    g_non_taxable_tax_type_code  :=  p_trl_global_variables_rec.non_taxable_tax_type_code;
    g_per_tax_type_code_low  :=  p_trl_global_variables_rec.per_tax_type_code_low;
    g_per_tax_type_code_high  :=  p_trl_global_variables_rec.per_tax_type_code_high;
    g_fed_per_tax_type_code_low  :=  p_trl_global_variables_rec.fed_per_tax_type_code_low;
    g_fed_per_tax_type_code_high :=  p_trl_global_variables_rec.fed_per_tax_type_code_high;
    g_vat_tax_type_code    :=  p_trl_global_variables_rec.vat_tax_type_code;
    g_excise_tax    :=  p_trl_global_variables_rec.excise_tax;
    g_vat_additional_tax  :=  p_trl_global_variables_rec.vat_additional_tax;
    g_vat_non_taxable_tax  :=  p_trl_global_variables_rec.vat_non_taxable_tax;
    g_vat_not_tax    :=  p_trl_global_variables_rec.vat_not_tax;
    g_vat_perception_tax  :=  p_trl_global_variables_rec.vat_perception_tax;
    g_vat_tax      :=  p_trl_global_variables_rec.vat_tax;
    g_inc_self_wd_tax    :=  p_trl_global_variables_rec.inc_self_wd_tax;
    g_excluding_trx_letter  :=  p_trl_global_variables_rec.excluding_trx_letter;
    g_trx_letter_low    :=  p_trl_global_variables_rec.trx_letter_low;
    g_trx_letter_high    :=  p_trl_global_variables_rec.trx_letter_high;
    g_include_referenced_source  :=  p_trl_global_variables_rec.include_referenced_source;
    g_party_name    :=  p_trl_global_variables_rec.party_name;
    g_adjusted_doc_from         := p_trl_global_variables_rec.adjusted_doc_from;
    g_adjusted_doc_to         := p_trl_global_variables_rec.adjusted_doc_to;
    g_batch_name    :=  p_trl_global_variables_rec.batch_name;
    g_batch_date_low    :=  p_trl_global_variables_rec.batch_date_low;
    g_batch_date_high    :=  p_trl_global_variables_rec.batch_date_high;
    g_batch_source_id    :=  p_trl_global_variables_rec.batch_source_id;
    g_adjusted_doc_from    :=  p_trl_global_variables_rec.adjusted_doc_from;
    g_adjusted_doc_to    :=  p_trl_global_variables_rec.adjusted_doc_to;
    g_standard_vat_tax_rate  :=  p_trl_global_variables_rec.standard_vat_tax_rate;
    g_municipal_tax    :=  p_trl_global_variables_rec.municipal_tax;
    g_provincial_tax    :=  p_trl_global_variables_rec.provincial_tax;
    g_tax_account_low    :=  p_trl_global_variables_rec.tax_account_low;
    g_tax_account_high    :=  p_trl_global_variables_rec.tax_account_high;
    g_exp_cert_date_from  :=  p_trl_global_variables_rec.exp_cert_date_from;
    g_exp_cert_date_to    :=  p_trl_global_variables_rec.exp_cert_date_to;
    g_exp_method    :=  p_trl_global_variables_rec.exp_method;
    g_print_company_info  :=  p_trl_global_variables_rec.print_company_info;
    g_reprint      :=  p_trl_global_variables_rec.reprint;
    g_errbuf      :=  p_trl_global_variables_rec.errbuf;
    g_retcode      :=  p_trl_global_variables_rec.retcode;
    g_accounting_status    :=   p_trl_global_variables_rec.accounting_status;
    g_chart_of_accounts_id    :=   p_trl_global_variables_rec.chart_of_accounts_id;
    g_reported_status    :=   p_trl_global_variables_rec.reported_status;
    g_gl_or_trx_date_filter := p_trl_global_variables_rec.GL_OR_TRX_DATE_FILTER ; --Bug 5396444



    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.assign_global_parameters.END',
                                      'ZX_AP_EXTRACT_PKG: assign_global_parameters(-)');
    END IF;

END assign_global_parameters;

/*===========================================================================+
| PROCEDURE                                                                 |
|   filter_validated                                                        |
|                                                                           |
| DESCRIPTION                                                               |
|    This procedure deletes unwanted records from AP tax data extract.      |
|                                                                           |
| SCOPE - Private                                                           |
|                                                                           |
| NOTES                                                                     |
|                                                                           |
| MODIFICATION HISTORY                                                      |
|   11-Jan-2005  Srinivasa Rao Korrapati      Created                       |
+===========================================================================*/


PROCEDURE FILTER_VALIDATED IS

BEGIN

    IF (g_level_procedure >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.FILTER_VALIDATED.BEGIN',
                                        'ZX_AP_EXTRACT_PKG: FILTER_VALIDATED(+)');
    END IF;

    IF g_accounting_status <> 'ACCOUNTED' THEN

      --This statment will delete invoices having below status:
      --1.Never Validated.
      --2.Un Validated.
      --3.Needs Revalidation and don't have any hold.
      --4.Needs Revalidation and have atleast one un-released accounting not allowed hold.

      DELETE
      FROM ZX_REP_TRX_DETAIL_T DTL
      WHERE REQUEST_ID = g_request_id
      AND DTL.EXTRACT_SOURCE_LEDGER = 'AP'
      AND EXISTS
          (SELECT /*+ no_unnest */ 1
           FROM AP_INVOICES_ALL AI
           WHERE AI.INVOICE_ID = DTL.TRX_ID
           AND DECODE(AP_INVOICES_PKG.GET_APPROVAL_STATUS(AI.INVOICE_ID,AI.INVOICE_AMOUNT,AI.PAYMENT_STATUS_FLAG,AI.INVOICE_TYPE_LOOKUP_CODE),
                      'NEVER APPROVED','Y',
                      'UNAPPROVED','Y',
                      'NEEDS REAPPROVAL',DECODE((SELECT COUNT(*)
                       FROM  DUAL
                       WHERE NOT EXISTS (SELECT 1
                             FROM  AP_HOLDS AH
                             WHERE AI.INVOICE_ID = AH.INVOICE_ID)
                       OR
                       EXISTS
                          (SELECT 1
                           FROM  AP_HOLDS AH1, AP_HOLD_CODES AHC
                     WHERE AH1.RELEASE_LOOKUP_CODE IS NULL
                     AND   AI.INVOICE_ID = AH1.INVOICE_ID
                     AND   AH1.HOLD_LOOKUP_CODE = AHC.HOLD_LOOKUP_CODE
                     AND   NVL(AHC.POSTABLE_FLAG,'N') = 'N')),
                  0,'N',
                  'Y'),
      'N') = 'Y');
    END IF;

    IF ( g_level_statement>= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_AP_EXTRACT_PKG',
                      ' Deleted Count : Filter_Validated : '||to_char(sql%ROWCOUNT) ); --Bug 5347188
    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.ZX_AP_EXTRACT_PKG.FILTER_VALIDATED.BEGIN',
                                      'ZX_AP_EXTRACT_PKG: FILTER_VALIDATED(-)');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
         g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
         FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
         FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','filter_validated- '|| g_error_buffer);
         FND_MSG_PUB.Add;
         IF (g_level_unexpected >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_unexpected,
                          'ZX.TRL.ZX_AP_EXTRACT_PKG.filter_validated',
                           g_error_buffer);
         END IF;
          g_retcode := 2;

END filter_validated;

END ZX_AP_EXTRACT_PKG;

/
