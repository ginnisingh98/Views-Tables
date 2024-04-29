--------------------------------------------------------
--  DDL for Package Body JG_ZZ_VAT_SELECTION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_ZZ_VAT_SELECTION_PKG" AS
/* $Header: jgzzvspb.pls 120.15.12010000.18 2010/05/19 07:09:33 spasupun ship $ */

-----------------------------------------
--Public Variable Declarations
-----------------------------------------

  l_version_info                        VARCHAR2(90) :=  NULL;
  C_LINES_PER_COMMIT                 CONSTANT NUMBER :=  1000;

  g_current_runtime_level CONSTANT  NUMBER  := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  g_level_statement       CONSTANT  NUMBER  := FND_LOG.LEVEL_STATEMENT;
  g_level_procedure       CONSTANT  NUMBER  := FND_LOG.LEVEL_PROCEDURE;
  g_level_event           CONSTANT  NUMBER  := FND_LOG.LEVEL_EVENT;
  g_level_unexpected      CONSTANT  NUMBER  := FND_LOG.LEVEL_UNEXPECTED;
  g_level_error		  CONSTANT  NUMBER  := FND_LOG.LEVEL_ERROR;
  g_level_exception       CONSTANT  NUMBER  := FND_LOG.LEVEL_EXCEPTION;
  g_error_buffer                    VARCHAR2(100);
  g_debug_flag           VARCHAR2(1);
  g_pkg_name	  CONSTANT VARCHAR2(30) := 'JG_ZZ_VAT_SELECTION_PKG';
  g_module_name   CONSTANT VARCHAR2(30) := 'JG.EMEA_VAT.SELECTION_PROCESS';


  g_created_by                          number(15);
  g_creation_date                       date;
  g_last_updated_by                     number(15);
  g_last_update_date                    date;
  g_last_update_login                   number(15);
  g_conc_request_id                     number(15);
  g_prog_appl_id                        number(15);
  g_conc_program_id                     number(15);
  g_conc_login_id                       number(15);

  g_rep_status_id_ap        jg_zz_vat_rep_status.reporting_status_id%type;
  g_rep_status_id_ar        jg_zz_vat_rep_status.reporting_status_id%type;
  g_rep_status_id_gl        jg_zz_vat_rep_status.reporting_status_id%type;
  g_selection_process_id    jg_zz_vat_rep_status.selection_process_id%type;

  -- Declare table type global variables
  gt_vat_transaction_id		JG_ZZ_VAT_SELECTION_PKG.vat_transaction_id_tbl;
  gt_reporting_status_id	JG_ZZ_VAT_SELECTION_PKG.reporting_status_id_tbl;
  gt_rep_entity_id		JG_ZZ_VAT_SELECTION_PKG.rep_entity_id_tbl;
  gt_rep_context_entity_name	JG_ZZ_VAT_SELECTION_PKG.rep_context_entity_name_tbl;
  gt_rep_context_entity_loc_id	JG_ZZ_VAT_SELECTION_PKG.rep_context_entity_loc_id_tbl;
  gt_taxpayer_id		JG_ZZ_VAT_SELECTION_PKG.taxpayer_id_tbl;
  gt_org_information2		JG_ZZ_VAT_SELECTION_PKG.org_information2_tbl;
  gt_legal_authority_name	JG_ZZ_VAT_SELECTION_PKG.legal_authority_name_tbl;
  gt_legal_auth_address_line2	JG_ZZ_VAT_SELECTION_PKG.legal_auth_address_line2_tbl;
  gt_legal_auth_address_line3	JG_ZZ_VAT_SELECTION_PKG.legal_auth_address_line3_tbl;
  gt_legal_auth_city		JG_ZZ_VAT_SELECTION_PKG.legal_auth_city_tbl;
  gt_legal_contact_party_name	JG_ZZ_VAT_SELECTION_PKG.legal_contact_party_name_tbl;
  gt_activity_code		JG_ZZ_VAT_SELECTION_PKG.activity_code_tbl;
  gt_ledger_id			JG_ZZ_VAT_SELECTION_PKG.ledger_id_tbl;
  gt_ledger_name		JG_ZZ_VAT_SELECTION_PKG.ledger_name_tbl;
  gt_chart_of_accounts_id	JG_ZZ_VAT_SELECTION_PKG.chart_of_accounts_id_tbl;
  gt_extract_source_ledger	JG_ZZ_VAT_SELECTION_PKG.extract_source_ledger_tbl;
  gt_establishment_id		JG_ZZ_VAT_SELECTION_PKG.establishment_id_tbl;
  gt_internal_organization_id	JG_ZZ_VAT_SELECTION_PKG.internal_organization_id_tbl;
  gt_application_id		JG_ZZ_VAT_SELECTION_PKG.application_id_tbl;
  gt_entity_code		JG_ZZ_VAT_SELECTION_PKG.entity_code_tbl;
  gt_event_class_code		JG_ZZ_VAT_SELECTION_PKG.event_class_code_tbl;
  gt_trx_id			JG_ZZ_VAT_SELECTION_PKG.trx_id_tbl;
  gt_trx_number			JG_ZZ_VAT_SELECTION_PKG.trx_number_tbl;
  gt_trx_description		JG_ZZ_VAT_SELECTION_PKG.trx_description_tbl;
  gt_trx_currency_code		JG_ZZ_VAT_SELECTION_PKG.trx_currency_code_tbl;
  gt_trx_type_id		JG_ZZ_VAT_SELECTION_PKG.trx_type_id_tbl;
  gt_trx_type_mng		JG_ZZ_VAT_SELECTION_PKG.trx_type_mng_tbl;
  gt_trx_line_id		JG_ZZ_VAT_SELECTION_PKG.trx_line_id_tbl;
  gt_trx_line_number		JG_ZZ_VAT_SELECTION_PKG.trx_line_number_tbl;
  gt_trx_line_description	JG_ZZ_VAT_SELECTION_PKG.trx_line_description_tbl;
  gt_trx_level_type		JG_ZZ_VAT_SELECTION_PKG.trx_level_type_tbl;
  gt_trx_line_type		JG_ZZ_VAT_SELECTION_PKG.trx_line_type_tbl;
  gt_trx_line_class		JG_ZZ_VAT_SELECTION_PKG.trx_line_class_tbl;
  gt_trx_class_mng		JG_ZZ_VAT_SELECTION_PKG.trx_class_mng_tbl;
  gt_trx_date			JG_ZZ_VAT_SELECTION_PKG.trx_date_tbl;
  gt_trx_due_date		JG_ZZ_VAT_SELECTION_PKG.trx_due_date_tbl;
  gt_trx_communicated_date	JG_ZZ_VAT_SELECTION_PKG.trx_communicated_date_tbl;
  gt_product_id			JG_ZZ_VAT_SELECTION_PKG.product_id_tbl;
  gt_functional_currency_code	JG_ZZ_VAT_SELECTION_PKG.functional_currency_code_tbl;
  gt_currency_conversion_type	JG_ZZ_VAT_SELECTION_PKG.currency_conversion_type_tbl;
  gt_currency_conversion_date	JG_ZZ_VAT_SELECTION_PKG.currency_conversion_date_tbl;
  gt_currency_conversion_rate	JG_ZZ_VAT_SELECTION_PKG.currency_conversion_rate_tbl;
  gt_territory_short_name	JG_ZZ_VAT_SELECTION_PKG.territory_short_name_tbl;
  gt_doc_seq_id			JG_ZZ_VAT_SELECTION_PKG.doc_seq_id_tbl;
  gt_doc_seq_name		JG_ZZ_VAT_SELECTION_PKG.doc_seq_name_tbl;
  gt_doc_seq_value		JG_ZZ_VAT_SELECTION_PKG.doc_seq_value_tbl;
  gt_trx_line_amt		JG_ZZ_VAT_SELECTION_PKG.trx_line_amt_tbl;
  gt_receipt_class_id		JG_ZZ_VAT_SELECTION_PKG.receipt_class_id_tbl;
  gt_applied_from_appl_id	JG_ZZ_VAT_SELECTION_PKG.applied_from_appl_id_tbl;
  gt_applied_from_entity_code	JG_ZZ_VAT_SELECTION_PKG.applied_from_entity_code_tbl;
  gt_applied_from_event_cls_cd	JG_ZZ_VAT_SELECTION_PKG.applied_from_event_cls_cd_tbl;
  gt_applied_from_trx_id	JG_ZZ_VAT_SELECTION_PKG.applied_from_trx_id_tbl;
  gt_applied_from_line_id	JG_ZZ_VAT_SELECTION_PKG.applied_from_line_id_tbl;
  gt_applied_from_trx_number	JG_ZZ_VAT_SELECTION_PKG.applied_from_trx_number_tbl;
  gt_adjusted_doc_appl_id	JG_ZZ_VAT_SELECTION_PKG.adjusted_doc_appl_id_tbl;
  gt_adjusted_doc_entity_code	JG_ZZ_VAT_SELECTION_PKG.adjusted_doc_entity_code_tbl;
  gt_adjusted_doc_event_cls_cd	JG_ZZ_VAT_SELECTION_PKG.adjusted_doc_event_cls_cd_tbl;
  gt_adjusted_doc_trx_id	JG_ZZ_VAT_SELECTION_PKG.adjusted_doc_trx_id_tbl;
  gt_adjusted_doc_number	JG_ZZ_VAT_SELECTION_PKG.adjusted_doc_number_tbl;
  gt_adjusted_doc_date		JG_ZZ_VAT_SELECTION_PKG.adjusted_doc_date_tbl;
  gt_applied_to_application_id	JG_ZZ_VAT_SELECTION_PKG.applied_to_application_id_tbl;
  gt_applied_to_entity_code	JG_ZZ_VAT_SELECTION_PKG.applied_to_entity_code_tbl;
  gt_applied_to_event_cls_code	JG_ZZ_VAT_SELECTION_PKG.applied_to_event_cls_code_tbl;
  gt_applied_to_trx_id		JG_ZZ_VAT_SELECTION_PKG.applied_to_trx_id_tbl;
  gt_applied_to_trx_line_id	JG_ZZ_VAT_SELECTION_PKG.applied_to_trx_line_id_tbl;
  gt_applied_to_trx_number	JG_ZZ_VAT_SELECTION_PKG.applied_to_trx_number_tbl;
  gt_ref_doc_application_id	JG_ZZ_VAT_SELECTION_PKG.ref_doc_application_id_tbl;
  gt_ref_doc_entity_code	JG_ZZ_VAT_SELECTION_PKG.ref_doc_entity_code_tbl;
  gt_ref_doc_event_class_code	JG_ZZ_VAT_SELECTION_PKG.ref_doc_event_class_code_tbl;
  gt_ref_doc_trx_id		JG_ZZ_VAT_SELECTION_PKG.ref_doc_trx_id_tbl;
  gt_ref_doc_line_id		JG_ZZ_VAT_SELECTION_PKG.ref_doc_line_id_tbl;
  gt_merchant_party_doc_num	JG_ZZ_VAT_SELECTION_PKG.merchant_party_doc_num_tbl;
  gt_merchant_party_name	JG_ZZ_VAT_SELECTION_PKG.merchant_party_name_tbl;
  gt_merchant_party_reference	JG_ZZ_VAT_SELECTION_PKG.merchant_party_reference_tbl;
  gt_merchant_party_tax_reg_num	JG_ZZ_VAT_SELECTION_PKG.merchant_party_tax_reg_num_tbl;
  gt_merchant_party_taxpayer_id	JG_ZZ_VAT_SELECTION_PKG.merchant_party_taxpayer_id_tbl;
  gt_start_expense_date		JG_ZZ_VAT_SELECTION_PKG.start_expense_date_tbl;
  gt_taxable_line_source_table	JG_ZZ_VAT_SELECTION_PKG.taxable_line_source_table_tbl;
  gt_tax_line_id		JG_ZZ_VAT_SELECTION_PKG.tax_line_id_tbl;
  gt_tax_line_number		JG_ZZ_VAT_SELECTION_PKG.tax_line_number_tbl;
  gt_tax_invoice_date		JG_ZZ_VAT_SELECTION_PKG.tax_invoice_date_tbl;
  gt_taxable_amt		JG_ZZ_VAT_SELECTION_PKG.taxable_amt_tbl;
  gt_taxable_amt_funcl_curr	JG_ZZ_VAT_SELECTION_PKG.taxable_amt_funcl_curr_tbl;
  gt_tax_amt			JG_ZZ_VAT_SELECTION_PKG.tax_amt_tbl;
  gt_tax_amt_funcl_curr		JG_ZZ_VAT_SELECTION_PKG.tax_amt_funcl_curr_tbl;
  gt_rec_tax_amt_tax_curr	JG_ZZ_VAT_SELECTION_PKG.rec_tax_amt_tax_curr_tbl;
  gt_nrec_tax_amt_tax_curr	JG_ZZ_VAT_SELECTION_PKG.nrec_tax_amt_tax_curr_tbl;
  gt_taxable_disc_amt		JG_ZZ_VAT_SELECTION_PKG.taxable_disc_amt_tbl;
  gt_taxable_disc_amt_fun_curr	JG_ZZ_VAT_SELECTION_PKG.taxable_disc_amt_fun_curr_tbl;
  gt_tax_disc_amt		JG_ZZ_VAT_SELECTION_PKG.tax_disc_amt_tbl;
  gt_tax_disc_amt_fun_curr	JG_ZZ_VAT_SELECTION_PKG.tax_disc_amt_fun_curr_tbl;
  gt_tax_rate_id		JG_ZZ_VAT_SELECTION_PKG.tax_rate_id_tbl;
  gt_tax_rate_code		JG_ZZ_VAT_SELECTION_PKG.tax_rate_code_tbl;
  gt_tax_rate			JG_ZZ_VAT_SELECTION_PKG.tax_rate_tbl;
  gt_tax_rate_code_name		JG_ZZ_VAT_SELECTION_PKG.tax_rate_code_name_tbl;
  gt_tax_rate_code_description	JG_ZZ_VAT_SELECTION_PKG.tax_rate_code_description_tbl;
  gt_tax_rate_vat_trx_type_code	JG_ZZ_VAT_SELECTION_PKG.tax_rate_vat_trx_type_code_tbl;
  gt_tax_rate_vat_trx_type_desc	JG_ZZ_VAT_SELECTION_PKG.tax_rate_vat_trx_type_desc_tbl;
  gt_tax_rate_vat_trx_type_mng	JG_ZZ_VAT_SELECTION_PKG.tax_rate_vat_trx_type_mng_tbl;
  gt_tax_rate_reg_type_code	JG_ZZ_VAT_SELECTION_PKG.tax_rate_reg_type_code_tbl;
  gt_tax_type_code		JG_ZZ_VAT_SELECTION_PKG.tax_type_code_tbl;
  gt_tax_type_mng		JG_ZZ_VAT_SELECTION_PKG.tax_type_mng_tbl;
  gt_tax_recovery_rate		JG_ZZ_VAT_SELECTION_PKG.tax_recovery_rate_tbl;
  gt_tax_regime_code		JG_ZZ_VAT_SELECTION_PKG.tax_regime_code_tbl;
  gt_tax			JG_ZZ_VAT_SELECTION_PKG.tax_tbl;
  gt_tax_jurisdiction_code	JG_ZZ_VAT_SELECTION_PKG.tax_jurisdiction_code_tbl;
  gt_tax_status_id		JG_ZZ_VAT_SELECTION_PKG.tax_status_id_tbl;
  gt_tax_status_code		JG_ZZ_VAT_SELECTION_PKG.tax_status_code_tbl;
  gt_tax_currency_code		JG_ZZ_VAT_SELECTION_PKG.tax_currency_code_tbl;
  gt_offset_tax_rate_code	JG_ZZ_VAT_SELECTION_PKG.offset_tax_rate_code_tbl;
  gt_billing_tp_name		JG_ZZ_VAT_SELECTION_PKG.billing_tp_name_tbl;
  gt_billing_tp_number		JG_ZZ_VAT_SELECTION_PKG.billing_tp_number_tbl;
  gt_billing_tp_tax_reg_num	JG_ZZ_VAT_SELECTION_PKG.billing_tp_tax_reg_num_tbl;
  gt_billing_tp_taxpayer_id	JG_ZZ_VAT_SELECTION_PKG.billing_tp_taxpayer_id_tbl;
  gt_billing_tp_party_number	JG_ZZ_VAT_SELECTION_PKG.billing_tp_party_number_tbl;
  gt_billing_tp_id		JG_ZZ_VAT_SELECTION_PKG.billing_tp_id_tbl;
  gt_billing_tp_tax_rep_flag	JG_ZZ_VAT_SELECTION_PKG.billing_tp_tax_rep_flag_tbl;
  gt_billing_tp_site_id		JG_ZZ_VAT_SELECTION_PKG.billing_tp_site_id_tbl;
  gt_billing_tp_address_id	JG_ZZ_VAT_SELECTION_PKG.billing_tp_address_id_tbl;
  gt_billing_tp_site_name	JG_ZZ_VAT_SELECTION_PKG.billing_tp_site_name_tbl;
  gt_billing_tp_site_tx_reg_num	JG_ZZ_VAT_SELECTION_PKG.billing_tp_site_tx_reg_num_tbl;
  gt_shipping_tp_name		JG_ZZ_VAT_SELECTION_PKG.shipping_tp_name_tbl;
  gt_shipping_tp_number		JG_ZZ_VAT_SELECTION_PKG.shipping_tp_number_tbl;
  gt_shipping_tp_tax_reg_num	JG_ZZ_VAT_SELECTION_PKG.shipping_tp_tax_reg_num_tbl;
  gt_shipping_tp_taxpayer_id	JG_ZZ_VAT_SELECTION_PKG.shipping_tp_taxpayer_id_tbl;
  gt_shipping_tp_id		JG_ZZ_VAT_SELECTION_PKG.shipping_tp_id_tbl;
  gt_shipping_tp_site_id	JG_ZZ_VAT_SELECTION_PKG.shipping_tp_site_id_tbl;
  gt_shipping_tp_address_id	JG_ZZ_VAT_SELECTION_PKG.shipping_tp_address_id_tbl;
  gt_shipping_tp_site_name	JG_ZZ_VAT_SELECTION_PKG.shipping_tp_site_name_tbl;
  gt_shipping_tp_site_tx_rg_num	JG_ZZ_VAT_SELECTION_PKG.shipping_tp_site_tx_rg_num_tbl;
  gt_banking_tp_name		JG_ZZ_VAT_SELECTION_PKG.banking_tp_name_tbl;
  gt_banking_tp_taxpayer_id	JG_ZZ_VAT_SELECTION_PKG.banking_tp_taxpayer_id_tbl;
  gt_bank_account_name		JG_ZZ_VAT_SELECTION_PKG.bank_account_name_tbl;
  gt_bank_account_num		JG_ZZ_VAT_SELECTION_PKG.bank_account_num_tbl;
  gt_bank_account_id		JG_ZZ_VAT_SELECTION_PKG.bank_account_id_tbl;
  gt_bank_branch_id		JG_ZZ_VAT_SELECTION_PKG.bank_branch_id_tbl;
  gt_legal_entity_tax_reg_num	JG_ZZ_VAT_SELECTION_PKG.legal_entity_tax_reg_num_tbl;
  gt_hq_estb_reg_number		JG_ZZ_VAT_SELECTION_PKG.hq_estb_reg_number_tbl;
  gt_tax_line_registration_num	JG_ZZ_VAT_SELECTION_PKG.tax_line_registration_num_tbl;
  gt_cancelled_date		JG_ZZ_VAT_SELECTION_PKG.cancelled_date_tbl;
  gt_cancel_flag		JG_ZZ_VAT_SELECTION_PKG.cancel_flag_tbl;
  gt_offset_flag		JG_ZZ_VAT_SELECTION_PKG.offset_flag_tbl;
  gt_posted_flag		JG_ZZ_VAT_SELECTION_PKG.posted_flag_tbl;
  gt_mrc_tax_line_flag		JG_ZZ_VAT_SELECTION_PKG.mrc_tax_line_flag_tbl;
  gt_reconciliation_flag	JG_ZZ_VAT_SELECTION_PKG.reconciliation_flag_tbl;
  gt_tax_recoverable_flag	JG_ZZ_VAT_SELECTION_PKG.tax_recoverable_flag_tbl;
  gt_reverse_flag		JG_ZZ_VAT_SELECTION_PKG.reverse_flag_tbl;
  gt_correction_flag		JG_ZZ_VAT_SELECTION_PKG.correction_flag_tbl;
  gt_ar_cash_receipt_rev_stat	JG_ZZ_VAT_SELECTION_PKG.ar_cash_receipt_rev_stat_tbl;
  gt_ar_cash_receipt_rev_date	JG_ZZ_VAT_SELECTION_PKG.ar_cash_receipt_rev_date_tbl;
  gt_payables_invoice_source	JG_ZZ_VAT_SELECTION_PKG.payables_invoice_source_tbl;
  gt_acctd_amount_dr		JG_ZZ_VAT_SELECTION_PKG.acctd_amount_dr_tbl;
  gt_acctd_amount_cr		JG_ZZ_VAT_SELECTION_PKG.acctd_amount_cr_tbl;
  gt_rec_application_status	JG_ZZ_VAT_SELECTION_PKG.rec_application_status_tbl;
  gt_vat_country_code		JG_ZZ_VAT_SELECTION_PKG.vat_country_code_tbl;
  gt_invoice_identifier		JG_ZZ_VAT_SELECTION_PKG.invoice_identifier_tbl;
  gt_account_class		JG_ZZ_VAT_SELECTION_PKG.account_class_tbl;
  gt_latest_rec_flag		JG_ZZ_VAT_SELECTION_PKG.latest_rec_flag_tbl;
  gt_jgzz_fiscal_code		JG_ZZ_VAT_SELECTION_PKG.jgzz_fiscal_code_tbl;
  gt_tax_reference		JG_ZZ_VAT_SELECTION_PKG.tax_reference_tbl;
  gt_pt_location		JG_ZZ_VAT_SELECTION_PKG.pt_location_tbl;
  gt_invoice_report_type	JG_ZZ_VAT_SELECTION_PKG.invoice_report_type_tbl;
  gt_es_correction_year		JG_ZZ_VAT_SELECTION_PKG.es_correction_year_tbl;
  gt_es_correction_period	JG_ZZ_VAT_SELECTION_PKG.es_correction_period_tbl;
  gt_triangulation		JG_ZZ_VAT_SELECTION_PKG.triangulation_tbl;
  gt_document_sub_type		JG_ZZ_VAT_SELECTION_PKG.document_sub_type_tbl;
  gt_assessable_value		JG_ZZ_VAT_SELECTION_PKG.assessable_value_tbl;
  gt_property_location		JG_ZZ_VAT_SELECTION_PKG.property_location_tbl;
  gt_chk_vat_amount_paid	JG_ZZ_VAT_SELECTION_PKG.chk_vat_amount_paid_tbl;
  gt_import_document_number	JG_ZZ_VAT_SELECTION_PKG.import_document_number_tbl;
  gt_import_document_date	JG_ZZ_VAT_SELECTION_PKG.import_document_date_tbl;
  gt_prl_no			JG_ZZ_VAT_SELECTION_PKG.prl_no_tbl;
  gt_property_rental		JG_ZZ_VAT_SELECTION_PKG.property_rental_tbl;
  gt_rates_reference		JG_ZZ_VAT_SELECTION_PKG.rates_reference_tbl;
  gt_stair_num			JG_ZZ_VAT_SELECTION_PKG.stair_num_tbl;
  gt_floor_num			JG_ZZ_VAT_SELECTION_PKG.floor_num_tbl;
  gt_door_num			JG_ZZ_VAT_SELECTION_PKG.door_num_tbl;
  gt_amount_applied		JG_ZZ_VAT_SELECTION_PKG.amount_applied_tbl;
  gt_actg_event_type_code 	JG_ZZ_VAT_SELECTION_PKG.actg_event_type_code_tbl;
  gt_actg_event_type_mng 	JG_ZZ_VAT_SELECTION_PKG.actg_event_type_mng_tbl;
  gt_actg_event_number 		JG_ZZ_VAT_SELECTION_PKG.actg_event_number_tbl;
  gt_actg_event_status_flag 	JG_ZZ_VAT_SELECTION_PKG.actg_event_status_flag_tbl;
  gt_actg_event_status_mng 	JG_ZZ_VAT_SELECTION_PKG.actg_event_status_mng_tbl;
  gt_actg_category_code 	JG_ZZ_VAT_SELECTION_PKG.actg_category_code_tbl;
  gt_actg_category_mng 		JG_ZZ_VAT_SELECTION_PKG.actg_category_mng_tbl;
  gt_accounting_date 		JG_ZZ_VAT_SELECTION_PKG.accounting_date_tbl;
  gt_gl_transfer_flag 		JG_ZZ_VAT_SELECTION_PKG.gl_transfer_flag_tbl;
  gt_actg_line_num  		JG_ZZ_VAT_SELECTION_PKG.actg_line_num_tbl;
  gt_actg_line_type_code 	JG_ZZ_VAT_SELECTION_PKG.actg_line_type_code_tbl;
  gt_actg_line_type_mng  	JG_ZZ_VAT_SELECTION_PKG.actg_line_type_mng_tbl;
  gt_actg_line_description 	JG_ZZ_VAT_SELECTION_PKG.actg_line_description_tbl;
  gt_actg_stat_amt 		JG_ZZ_VAT_SELECTION_PKG.actg_stat_amt_tbl;
  gt_actg_party_id 		JG_ZZ_VAT_SELECTION_PKG.actg_party_id_tbl;
  gt_actg_party_site_id 	JG_ZZ_VAT_SELECTION_PKG.actg_party_site_id_tbl;
  gt_actg_party_type 		JG_ZZ_VAT_SELECTION_PKG.actg_party_type_tbl;
  gt_actg_event_id 		JG_ZZ_VAT_SELECTION_PKG.actg_event_id_tbl;
  gt_actg_header_id 		JG_ZZ_VAT_SELECTION_PKG.actg_header_id_tbl;
  gt_actg_line_id 		JG_ZZ_VAT_SELECTION_PKG.actg_line_id_tbl;
  gt_actg_source_id 		JG_ZZ_VAT_SELECTION_PKG.actg_source_id_tbl;
  gt_actg_source_table 		JG_ZZ_VAT_SELECTION_PKG.actg_source_table_tbl;
  gt_actg_line_ccid 		JG_ZZ_VAT_SELECTION_PKG.actg_line_ccid_tbl;
  gt_account_flexfield 		JG_ZZ_VAT_SELECTION_PKG.account_flexfield_tbl;
  gt_account_description 	JG_ZZ_VAT_SELECTION_PKG.account_description_tbl;
  gt_period_name 		JG_ZZ_VAT_SELECTION_PKG.period_name_tbl;
  gt_trx_arap_balancing_seg 	JG_ZZ_VAT_SELECTION_PKG.trx_arap_balancing_seg_tbl;
  gt_trx_arap_natural_account 	JG_ZZ_VAT_SELECTION_PKG.trx_arap_natural_account_tbl;
  gt_trx_taxable_balancing_seg 	JG_ZZ_VAT_SELECTION_PKG.trx_taxable_balancing_seg_tbl;
  gt_trx_taxable_natural_acct 	JG_ZZ_VAT_SELECTION_PKG.trx_taxable_natural_acct_tbl;
  gt_trx_tax_balancing_seg 	JG_ZZ_VAT_SELECTION_PKG.trx_tax_balancing_seg_tbl;
  gt_trx_tax_natural_account 	JG_ZZ_VAT_SELECTION_PKG.trx_tax_natural_account_tbl;
  gt_created_by 		JG_ZZ_VAT_SELECTION_PKG.created_by_tbl;
  gt_creation_date 		JG_ZZ_VAT_SELECTION_PKG.creation_date_tbl;
  gt_last_updated_by 		JG_ZZ_VAT_SELECTION_PKG.last_updated_by_tbl;
  gt_last_update_date 		JG_ZZ_VAT_SELECTION_PKG.last_update_date_tbl;
  gt_last_update_login 		JG_ZZ_VAT_SELECTION_PKG.last_update_login_tbl;
  gt_request_id			JG_ZZ_VAT_SELECTION_PKG.request_id_tbl;
  gt_program_application_id 	JG_ZZ_VAT_SELECTION_PKG.program_application_id_tbl;
  gt_program_id 		JG_ZZ_VAT_SELECTION_PKG.program_id_tbl;
  gt_program_login_id 		JG_ZZ_VAT_SELECTION_PKG.program_login_id_tbl;
  gt_object_version_number 	JG_ZZ_VAT_SELECTION_PKG.object_version_number;
  gt_gl_date                    JG_ZZ_VAT_SELECTION_PKG.gl_date_tbl;
  gt_tax_origin                 JG_ZZ_VAT_SELECTION_PKG.tax_origin_tbl;
  gt_trx_ctrl_actg_flexfield    JG_ZZ_VAT_SELECTION_PKG.trx_control_actg_flexfield_tbl;
  gt_reporting_code             JG_ZZ_VAT_SELECTION_PKG.reporting_code_tbl;
  gt_def_rec_settlement_opt_code JG_ZZ_VAT_SELECTION_PKG.def_rec_settlement_op_code_tbl;
  gt_taxable_item_source_id            JG_ZZ_VAT_SELECTION_PKG.taxable_item_source_id_tbl;

----------------------------------------
--Private Methods Declaration
----------------------------------------
--
 PROCEDURE initialize(
    P_GLOBAL_VARIABLES_REC      OUT NOCOPY JG_ZZ_VAT_SELECTION_PKG.GLOBAL_VARIABLES_REC_TYPE,
    P_REPORTING_LEVEL          IN JG_ZZ_VAT_REP_ENTITIES.entity_level_code%TYPE,
    P_LEDGER                   IN JG_ZZ_VAT_REP_ENTITIES.ledger_id%TYPE,
    P_BSV                      IN JG_ZZ_VAT_REP_ENTITIES.balancing_segment_value%TYPE,
    P_VAT_REPORTING_ENTITY_ID  IN JG_ZZ_VAT_REP_ENTITIES.vat_reporting_entity_id%TYPE,
    P_TAX_PERIOD               IN JG_ZZ_VAT_REP_STATUS.tax_calendar_period%TYPE,
    P_SOURCE                   IN JG_ZZ_VAT_REP_STATUS.source%TYPE,
    P_ACCTD_UNACCTD            IN VARCHAR2,
    P_DEBUG_FLAG               IN VARCHAR2,
    P_ERRBUF                   IN OUT NOCOPY VARCHAR2,
    P_RETCODE                  IN OUT NOCOPY VARCHAR2);

  PROCEDURE get_period_date_range (
   p_calendar_name             IN         GL_PERIODS.period_set_name%TYPE,
   p_period		       IN         GL_PERIODS.period_name%TYPE,
   p_global_variables_rec      IN OUT NOCOPY JG_ZZ_VAT_SELECTION_PKG.GLOBAL_VARIABLES_REC_TYPE,
   x_return_status             OUT NOCOPY VARCHAR2);

  PROCEDURE get_VAT_reporting_details (
   p_vat_reporting_entity_id   IN            JG_ZZ_VAT_REP_ENTITIES.vat_reporting_entity_id%TYPE,
   p_global_variables_rec      IN OUT NOCOPY JG_ZZ_VAT_SELECTION_PKG.GLOBAL_VARIABLES_REC_TYPE,
   x_return_status             OUT NOCOPY VARCHAR2);

  PROCEDURE call_TRL (
    P_GLOBAL_VARIABLES_REC     IN OUT NOCOPY JG_ZZ_VAT_SELECTION_PKG.GLOBAL_VARIABLES_REC_TYPE,
    x_request_id               IN NUMBER);

  PROCEDURE fetch_tax_data (
     P_GLOBAL_VARIABLES_REC     IN OUT NOCOPY JG_ZZ_VAT_SELECTION_PKG.GLOBAL_VARIABLES_REC_TYPE,
    x_request_id               IN NUMBER);

  PROCEDURE insert_tax_data ;

  PROCEDURE init_gt_variables;

  PROCEDURE control_intersecting_domains(
    p_global_variables_rec     IN OUT NOCOPY JG_ZZ_VAT_SELECTION_PKG.GLOBAL_VARIABLES_REC_TYPE,
    x_request_id               IN NUMBER,
    x_intersect_domain_err     OUT NOCOPY VARCHAR2);

  PROCEDURE purge_report_finalrep (
            xv_return_status   OUT NOCOPY VARCHAR2,
            xv_return_message  OUT NOCOPY VARCHAR2 );

  PROCEDURE log_file (
            filename      IN VARCHAR2,
            text_to_write IN  VARCHAR2 );

  PROCEDURE tax_date_maintenance_program (
            p_legal_entity_id  IN  JG_ZZ_VAT_REP_ENTITIES.legal_entity_id%TYPE,
            p_ledger_id        IN  JG_ZZ_VAT_REP_ENTITIES.ledger_id%TYPE,
            p_end_date         IN  GL_PERIODS.END_DATE%TYPE,
            p_source           IN  JG_ZZ_VAT_REP_STATUS.source%TYPE,
            p_debug_flag       IN  VARCHAR2,
            x_return_status    OUT NOCOPY VARCHAR2,
            x_errbuf           OUT NOCOPY VARCHAR2 );

  FUNCTION is_prev_period_open (
    P_GLOBAL_VARIABLES_REC     IN OUT NOCOPY JG_ZZ_VAT_SELECTION_PKG.GLOBAL_VARIABLES_REC_TYPE)
  RETURN BOOLEAN;


-----------------------------------------
--Public Methods
-----------------------------------------
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |   main()                                                                  |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure calls 						     |
 |     (1) JG_ZZ_VAT_REP_UTILITY.maintain_selection_entities to validate and |
 |         determine whether to create ACCOUNTING reporting entities or not. |
 |     (2) JG_ZZ_VAT_REP_UTILITY.validate_process_initiation to validate and |
 |         determine whether to proceed with selection or not.               |
 |     (2) Insert status information into jg_zz_vat_rep_status table.        |
 |     (3) Call TRL engine to fetch AR, AP, GL tax information.              |
 |     (4) Controls intersecting domains (transactions selected in current   |
 |         run intersects with a previous selection run(s).                  |
 |     (5) Insert TRL info into JG Tax Trx table                             |
 |     (6) JG_ZZ_VAT_REP_UTILITY.post_process_updates to perform post        |
 |         selection process processing.                                     |
 |                                                                           |
 | SCOPE - Public                                                            |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |  Date           Author          Description                               |
 |  ============  ==============  =================================          |
 |   23-Jan-2006   RBASKER               Initial  Version.                   |
 |   28-Mar-2006   RBASKER         Incorporated changes for XBuild4.         |
 |   28-Apr-2006   RBASKER         Bug: 5169118 - Fixed issues identified    |
 |                                 during Unit Testing.                      |
 |   04-Aug-2006   RJREDDY         Bug: 5372731 - Added procedure call to    |
 |                                 tax_date_maintenance_program              |
 |                                                                           |
 +===========================================================================*/

PROCEDURE main(  errbuf                         OUT NOCOPY VARCHAR2,
                 retcode                        OUT NOCOPY NUMBER,
		 p_reporting_level            IN JG_ZZ_VAT_REP_ENTITIES.entity_level_code%TYPE,
                 p_ledger                     IN JG_ZZ_VAT_REP_ENTITIES.ledger_id%TYPE ,
                 p_chart_of_account           IN NUMBER,
                 p_bsv                        IN JG_ZZ_VAT_REP_ENTITIES.balancing_segment_value%TYPE,
                 p_vat_reporting_entity_id    IN JG_ZZ_VAT_REP_ENTITIES.vat_reporting_entity_id%TYPE,
                 p_period                     IN JG_ZZ_VAT_REP_STATUS.tax_calendar_period%TYPE,
                 p_source                     IN JG_ZZ_VAT_REP_STATUS.source%TYPE,
                 p_acct_unacctd               IN VARCHAR2,
		 p_dummy                      IN VARCHAR2,
                 p_entity_identifier          IN VARCHAR2,
                 p_debug_flag                 IN VARCHAR2)
IS
    l_global_variables_rec    GLOBAL_VARIABLES_REC_TYPE;
    l_api_name                CONSTANT VARCHAR2(30) := 'MAIN';
    l_return_status	      VARCHAR2(1);
    l_return_message          VARCHAR2(1000);
    l_intersect_domain_err    VARCHAR2(1000);

    l_selection_process_id    JG_ZZ_VAT_REP_STATUS.selection_process_id%TYPE;
    l_selection_status_flag   JG_ZZ_VAT_REP_STATUS.selection_status_flag%TYPE;
    l_mapping_rep_entity_id   JG_ZZ_VAT_REP_STATUS.mapping_vat_rep_entity_id%TYPE;
    l_country                 xle_firstparty_information_v.country%TYPE;
    l_legal_entity_id         JG_ZZ_VAT_REP_ENTITIES.legal_entity_id%TYPE;
    l_ledger                  JG_ZZ_VAT_REP_ENTITIES.ledger_id%TYPE;

-- Bug 6835573
    l_last_reported_period JG_ZZ_VAT_REP_ENTITIES.last_reported_period%TYPE;
    l_is_mgr_trx_exist        NUMBER(15);



    CURSOR c_is_mgr_trx_exist(pn_vat_rep_entity_id number) IS
    SELECT JGTRD.trx_id
    FROM jg_zz_vat_trx_details JGTRD,
         jg_zz_vat_rep_status JGREPS,
         zx_lines ZX
    WHERE JGREPS.vat_reporting_entity_id = pn_vat_rep_entity_id
    AND JGREPS.reporting_status_id = JGTRD.reporting_status_id
    AND JGREPS.source = JGTRD.extract_source_ledger
    AND ZX.trx_id = JGTRD.trx_id
    AND JGTRD.created_by = 1
    AND ZX.record_type_code   = 'MIGRATED'
    AND ZX.application_id     = JGTRD.application_id
    AND ZX.entity_code        = JGTRD.entity_code
    AND ZX.event_class_code   = JGTRD.event_class_code
    AND rownum=1;
-- Bug 6835573

  l_is_upgrade_customer NUMBER := 0;
  CURSOR c_is_upgrade_customer IS
      SELECT 1
	  FROM zx_lines
	  WHERE record_type_code= 'MIGRATED'
	  AND rownum=1;

	 l_last_rep_period_start_date DATE;
	 l_last_rep_period_end_date DATE;

	 cursor last_reported_date_from_11i (pn_vat_rep_entity_id number) IS
	 select glp.start_date,glp.end_date,acct.last_reported_period
	 from  jg_zz_vat_rep_entities legal
		  ,jg_zz_vat_rep_entities acct
		  ,gl_periods             glp
	 where acct.entity_type_code = 'ACCOUNTING'
	 and acct.vat_reporting_entity_id = pn_vat_rep_entity_id
	 and acct.mapping_vat_rep_entity_id= legal.vat_reporting_entity_id
	 and glp.period_set_name   = legal.tax_calendar_name
	 and glp.period_name  =  acct.last_reported_period;


BEGIN

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',
					G_PKG_NAME||': '||l_api_name||'()+');
   END IF;

    IF p_debug_flag = 'Y' THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

--  Initialize the parameters:
    initialize(
	    p_global_variables_rec     => l_global_variables_rec,
	    p_reporting_level	       => p_reporting_level,
	    p_ledger		       => p_ledger,
	    p_bsv		       => p_bsv,
    	    p_vat_reporting_entity_id  => p_vat_reporting_entity_id,
    	    p_tax_period               => p_period,
    	    p_source                   => p_source,
    	    p_acctd_unacctd            => p_acct_unacctd,
    	    p_debug_flag               => p_debug_flag,
    	    p_errbuf                   => errbuf,
    	    p_retcode                  => retcode
	);



    l_mapping_rep_entity_id := l_global_variables_rec.vat_reporting_entity_id;

-- maintain_selection_entities:
  /*-------------------------------------------------------------------+
   | Call utility package to validate and determine whether to create |
   | ACCOUNTING reporting entities or not. This procedure calls:      |
   | (1) validate_entity_attributes - Validates the parameters passed |
   | based on the Reporting Level.                                    |
   | (2) get_accounting_entity - Checks if the passed accounting      |
   | entity exists in jg_zz_vat_rep_entities table.                   |
   | (3) create_accounting_entity - create a record for the accounting|
   | entity in the table if it does not exists and returns the vat    |
   | reporting entity identifier.		                      |
   +--------------------------------------------------------------------*/
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
	'JG_ZZ_VAT_REP_UTILITY.maintain_selection_entities'||'.BEGIN',
         G_PKG_NAME||': '||'JG_ZZ_VAT_REP_UTILITY.maintain_selection_entities'
			 ||'()+');
   END IF;


   JG_ZZ_VAT_REP_UTILITY.maintain_selection_entities(
      pv_entity_level_code     => l_global_variables_rec.reporting_entity_level,
      pn_vat_reporting_entity_id => l_global_variables_rec.vat_reporting_entity_id,
      pn_ledger_id               => l_global_variables_rec.ledger,
      pv_balancing_segment_value => l_global_variables_rec.bsv,
      xn_vat_reporting_entity_id => l_global_variables_rec.vat_reporting_entity_id,
      xv_return_status            => l_return_status,
      xv_return_message          => l_return_message
      );

    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
	'JG_ZZ_VAT_REP_UTILITY.maintain_selection_entities'||'.END',
         G_PKG_NAME||': '||'JG_ZZ_VAT_REP_UTILITY.maintain_selection_entities'||'()-'
           );
    END IF;


   -- Begin : Collect the information related to Last Reported Period in 11i. Bug 9381398

 	     IF l_global_variables_rec.reporting_entity_level IN ('LEDGER', 'BSV') THEN


 	           OPEN last_reported_date_from_11i(l_global_variables_rec.vat_reporting_entity_id);
 	                 FETCH last_reported_date_from_11i
 	                 INTO l_last_rep_period_start_date
 	                     ,l_last_rep_period_end_date
 	                     ,l_last_reported_period;
 	           CLOSE last_reported_date_from_11i;

 	            IF p_debug_flag = 'Y' THEN
 	                   fnd_file.put_line(fnd_file.log, 'l_last_rep_period_start_date :'||l_last_rep_period_start_date);
 	                   fnd_file.put_line(fnd_file.log, 'l_last_rep_period_end_date   :'||l_last_rep_period_end_date);
 	                   fnd_file.put_line(fnd_file.log, 'l_last_reported_period       :'||l_last_reported_period);
 	            END IF;

 	           l_global_variables_rec.LAST_REPORTED_PERIOD_FROM_11i := l_last_reported_period;
 	           l_global_variables_rec.LAST_REP_PERIOD_START_DATE := l_last_rep_period_start_date;
 	           l_global_variables_rec.LAST_REP_PERIOD_END_DATE := l_last_rep_period_end_date;

 	     END IF;

 	     -- End : Collect the information related to Last Reported Period in 11i. Bug 9381398

     if l_return_status in (  FND_API.G_RET_STS_UNEXP_ERROR,
                             FND_API.G_RET_STS_ERROR) then
        l_selection_status_flag := fnd_api.g_ret_sts_error;
        errbuf  := l_return_message;
        retcode := 2;
        RETURN;
    end if;
    COMMIT; --Bug:7759140 is for commiting the creation of accounting vat reporting entity.

 -- Bug 6835573

   OPEN c_is_upgrade_customer;
   FETCH c_is_upgrade_customer INTO l_is_upgrade_customer;
   CLOSE c_is_upgrade_customer;

   IF l_is_upgrade_customer = 1 THEN
   IF  l_global_variables_rec.reporting_entity_level = 'LEDGER' or
        l_global_variables_rec.reporting_entity_level = 'BSV' THEN

      IF l_last_reported_period IS NULL THEN

         OPEN c_is_mgr_trx_exist(l_global_variables_rec.vat_reporting_entity_id);
         FETCH c_is_mgr_trx_exist INTO l_is_mgr_trx_exist;
         CLOSE c_is_mgr_trx_exist;

         IF  l_is_mgr_trx_exist IS NULL THEN

	  FND_MESSAGE.SET_NAME('JG','JG_ZZ_VAT_PRE_REP_PROC_REQ');
          errbuf :=  FND_MESSAGE.GET;
          retcode := 2;

          RETURN;

         END IF;

       END IF;
     END IF;
	END IF;
 -- Bug 6835573

-- validate_process_initiation:
   /*-------------------------------------------------------------------+
   | Call utility package to validate and determine whether to proceed |
   | with Selection Process or not. This procedure is responsible for: |
   | (1) Check if Selection is already processed for given combination.|
   | (2) Check if Final reporting has already happened, if yes then    |
   |     re-selection is not allowed.                                  |
   | (3) Before re-selection, purge allocation data and errors table by|
   |     calling allocation purge api.                                 |
   | (4) Before re-selection, purge the tax data pertaining to the     |
   |     previous run from jg_zz_vat_trx_details table by calling      |
   |     jg_zz_vat_selection_pkg.purge_tax_data.                       |
   | (5) Before re-selection, update the status information (nullify)  |
   |     of the selection process for the given combination by calling |
   |     JG_ZZ_VAT_REP_UTILITY.pre_process_update procedure.           |
   | (6) If Selection is not yet initiated for the given combination   |
   |     Validate if there is any gap in selection as per calendar     |
   | (7) Inserts status information of the Selection process into the  |
   |     jg_zz_vat_rep_status table.                                   |
   +--------------------------------------------------------------------*/
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
	'JG_ZZ_VAT_REP_UTILITY.validate_process_initiation'||'.BEGIN',
         G_PKG_NAME||': '||
	'JG_ZZ_VAT_REP_UTILITY.validate_process_initiation'||'()+');
   END IF;

   JG_ZZ_VAT_REP_UTILITY.validate_process_initiation(
      pn_vat_reporting_entity_id  => l_global_variables_rec.vat_reporting_entity_id,
      pv_tax_calendar_period      => l_global_variables_rec.tax_period,
      pv_source                   => l_global_variables_rec.source,
      pv_process_name             => 'SELECTION',
      xn_reporting_status_id_ap   => g_rep_status_id_ap,
      xn_reporting_status_id_ar   => g_rep_status_id_ar,
      xn_reporting_status_id_gl   => g_rep_status_id_gl,
      xv_return_status            => l_return_status,
      xv_return_message           => l_return_message
    );

    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
		'JG_ZZ_VAT_REP_UTILITY.validate_process_initiation'||'.END',
                 G_PKG_NAME||': ' ||
		'JG_ZZ_VAT_REP_UTILITY.validate_process_initiation'||'()-');
    END IF;

    if l_return_status in (  FND_API.G_RET_STS_UNEXP_ERROR,
			     FND_API.G_RET_STS_ERROR) then
       l_selection_status_flag := fnd_api.g_ret_sts_error;
       errbuf  := l_return_message;
       retcode := 2;
       RETURN;
    end if;

   -- Get Reporting configuration details
   get_VAT_reporting_details (
        p_vat_reporting_entity_id   => l_mapping_rep_entity_id,
        p_global_variables_rec      => l_global_variables_rec,
        x_return_status             => l_return_status);

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      l_selection_status_flag := fnd_api.g_ret_sts_error;
      errbuf := 'Unexpected error in get_VAT_reporting_details';
      retcode := 2;
      RETURN;
   ELSE
      -- Get Date Range
         get_period_date_range (
             p_calendar_name   => l_global_variables_rec.tax_calendar_name,
             p_period          => l_global_variables_rec.tax_period,
	     p_global_variables_rec     => l_global_variables_rec,
             x_return_status   => l_return_status);
   END IF;

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      l_selection_status_flag := fnd_api.g_ret_sts_error;
      errbuf := 'Unexpected error in get_period_date_range';
      retcode := 2;
	RETURN;
   ELSE

     -- use TRN/LE to determine the country for which SELECTION is executed.
     SELECT xle.country
      INTO  l_country
      FROM  xle_firstparty_information_v xle
      WHERE xle.legal_entity_id = l_global_variables_rec.legal_entity_id;


    /*-----------------------------------------------------------------------------------------------------+
    | For country Spain, the Driving date for Tax Reporting is a special case. Non Modelo and Modelo       |
    | reports are based on GL date and Transaction Date respectively. When we select the data for          |
    | 'Spain',we select the full data set for both modelo and non modelo reports and pass to the trl BOTH  |
    | the GL date and Trx/Inv date as filtering criteria/driving date. We request TRL with parameter       |
    | P_GL_OR_TRX_DATE_FILTER=> 'Y', to select all data that fall within GL date range and also UNION      |
    | all data within the TRX date range.                                                                  |
    +------------------------------------------------------------------------------------------------------*/

      IF l_country ='ES' THEN --spain
         l_global_variables_rec.gl_or_trx_date_filter := 'Y';
      ELSE
	l_global_variables_rec.gl_or_trx_date_filter := 'N';
      END IF;

     -- tax_date_maintenance_program:
   /*-------------------------------------------------------------------+
   | Call tax_date_maintenance_program for ECE countries (PL, HU, CZ)  |
   | to update the tax_invoice_date to payment clearing date for the   |
   | invoices which has not been finally reported.                     |
   | - This routine is called at the same reporting level as TRL is    |
   | called ie LE or LEDGER level.                                     |
   +--------------------------------------------------------------------*/

    IF (l_country = 'PL' or l_country =  'HU' or
       l_country = 'CZ') THEN

       -- Check the Reporting Entity Level.
       IF   l_global_variables_rec.REPORTING_ENTITY_LEVEL = 'LEDGER' or
            l_global_variables_rec.REPORTING_ENTITY_LEVEL = 'BSV' THEN
            l_ledger           :=  l_global_variables_rec.legal_entity_id;
            l_legal_entity_id  := NULL;
       ELSE
           l_legal_entity_id := l_global_variables_rec.legal_entity_id;
           l_ledger          := NULL;
      END IF;

       IF g_debug_flag = 'Y'  THEN
           fnd_file.put_line(fnd_file.log,
                'Following parameters are passed to Tax_Date_Maintenance_Program...' );
           fnd_file.put_line(fnd_file.log,
                'P_LEGAL_ENTITY_ID = '|| l_legal_entity_id);
           fnd_file.put_line(fnd_file.log,
                'P_LEDGER = '|| l_ledger);
           fnd_file.put_line(fnd_file.log,
                    ' P_END_DATE = '|| l_global_variables_rec.tax_invoice_date_high );
           fnd_file.put_line(fnd_file.log,
                  ' P_SOURCE  = ' || l_global_variables_rec.source );
           fnd_file.put_line(fnd_file.log,
                    ' P_DEBUG_FLAG = '|| p_debug_flag );
       END IF;

       tax_date_maintenance_program (
        p_legal_entity_id  => l_legal_entity_id,
        p_ledger_id        => l_ledger,
        p_end_date         => l_global_variables_rec.tax_invoice_date_high,
        p_source           => l_global_variables_rec.source,
        p_debug_flag       => p_debug_flag ,
        x_return_status    => l_return_status,
        x_errbuf           => l_return_message
        );

       if l_return_status in (  FND_API.G_RET_STS_UNEXP_ERROR,
                             FND_API.G_RET_STS_ERROR) then
          l_selection_status_flag := fnd_api.g_ret_sts_error;
          errbuf  := l_return_message;
          retcode := 2;
          RETURN;
      end if;
   END IF;

      -- Call TRL engine
      call_TRL(l_global_variables_rec,
        	    g_conc_request_id);
   END IF;

   IF l_global_variables_rec.retcode <> 2 THEN

      -- Call control_intersecting_domains
      control_intersecting_domains(
 		l_global_variables_rec,
                g_conc_request_id,
		l_intersect_domain_err);

      IF l_global_variables_rec.retcode <> 2 THEN

      -- Bulk fetch data from TRL interface table.
      -- And bulk insert into JG_ZZ_VAT_TRX_DETAILS.
         fetch_tax_data(l_global_variables_rec,
                      g_conc_request_id);
      ELSE
         l_selection_status_flag := fnd_api.g_ret_sts_error;
	 errbuf := l_intersect_domain_err;
         retcode := 2;
        RETURN;
      END IF;
   END IF;

    IF l_global_variables_rec.retcode <> 2 THEN

      -- For System Testing purpose will not purge data from TRL table when run
      -- in debug mode.
      IF nvl(p_debug_flag, 'N') = 'N' THEN
         -- Call TRL's purge api, to purge data from TRL interface table.
         ZX_EXTRACT_PKG.purge(g_conc_request_id);
      END IF;

       -- post_process_update
       -- Call the utility API to update selection_process columns of
       --  jg_zz_vat_rep_status table by passing proper values.
       IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
		'JG_ZZ_VAT_REP_UTILITY.post_process_update'||'.BEGIN',
                 G_PKG_NAME||': '||
		'JG_ZZ_VAT_REP_UTILITY.post_process_update'||'()+');
       END IF;

       l_selection_process_id := g_selection_process_id;
       if l_selection_status_flag  is null then
        l_selection_status_flag   := fnd_api.g_ret_sts_success;
       end if;


      JG_ZZ_VAT_REP_UTILITY.post_process_update(
        pn_vat_reporting_entity_id  => l_global_variables_rec.vat_reporting_entity_id,
        pv_tax_calendar_period      => l_global_variables_rec.tax_period,
        pv_source                   => l_global_variables_rec.source,
        pv_process_name             => 'SELECTION',
        pn_process_id               => l_selection_process_id,
        pv_process_flag             => l_selection_status_flag ,
        pv_enable_allocations_flag  => NULL,
        xv_return_status            => l_return_status,
        xv_return_message           => l_return_message
       );

        IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||
		'JG_ZZ_VAT_REP_UTILITY.post_process_update'||'.END',
                 G_PKG_NAME||': ' ||'JG_ZZ_VAT_REP_UTILITY.post_process_update'||'()-');
        END IF;

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
           errbuf := l_return_message;
           retcode := 2;
	   RETURN;
        END IF;

   ELSE
      errbuf := l_global_variables_rec.errbuf;
      retcode := l_global_variables_rec.retcode;
      RETURN;
   END IF;


  IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
                 ' RETURN_STATUS = ' || retcode);
   END IF;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',
		G_PKG_NAME||': ' ||l_api_name||'()-');
   END IF;

   IF p_debug_flag = 'Y' THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME||': ' ||l_api_name||'()-');
    END IF;

EXCEPTION
  WHEN OTHERS THEN
    g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

     IF p_debug_flag = 'Y' THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
     END IF;

    FND_MSG_PUB.Add;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_unexpected,
                      G_MODULE_NAME||l_api_name,
                      g_error_buffer);
    END IF;

    RETCODE := l_global_variables_rec.retcode;

END main;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |   purge_tax_data                                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure deletes the records from JG_ZZ_VAT_TRX_DETAILS          |
 |    for a given reporting_status_id                                        |
 |                                                                           |
 | SCOPE - Public                                                            |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |  Date           Author          Description                               |
 |  ============  ==============  =================================          |
 |   23-Jan-2006   RBASKER               Initial  Version.                   |
 |                                                                           |
 +===========================================================================*/

PROCEDURE PURGE_TAX_DATA (p_reporting_status_id in number,
			  x_return_status  OUT NOCOPY VARCHAR2)
IS
  l_api_name           CONSTANT VARCHAR2(30) := 'PURGE_TAX_DATA';
BEGIN
    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',
		G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

     IF g_debug_flag = 'Y' THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME||': '||l_api_name||'()+');
     END IF;

   /*Set the return status to Success */
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   delete from JG_ZZ_VAT_TRX_DETAILS
   where reporting_Status_id = p_reporting_status_id;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
                 ' RETURN_STATUS = ' || x_return_status);
   END IF;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',
		G_PKG_NAME||': ' ||l_api_name||'()-');
   END IF;

   IF g_debug_flag = 'Y' THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME||': ' ||l_api_name||'()-');
    END IF;

   EXCEPTION
     WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

       IF g_debug_flag = 'Y' THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
       END IF;

       IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
       END IF;
      RETURN;
END PURGE_TAX_DATA;


/*===========================================================================+
 | FUNCTION                                                                  |
 |   PURGE_TAX_DATA                                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function deletes the records from JG_ZZ_VAT_TRX_DETAILS,          |
 |    for a given reporting_status_id                                        |
 |                                                                           |
 | SCOPE - Public                                                            |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |  Date           Author          Description                               |
 |  ============  ==============  =================================          |
 |   23-Jan-2006   RBASKER               Initial  Version.                   |
 |                                                                           |
 +===========================================================================*/

FUNCTION PURGE_TAX_DATA(p_reporting_status_id in number) return number is
  num_rows_deleted number := 0;
  l_return_status NUMBER;
BEGIN


     select count(*) into num_rows_deleted
     from   jg_zz_vat_trx_details
     where  reporting_status_id = p_reporting_status_id;

     PURGE_TAX_DATA(p_reporting_status_id, l_return_status);

     return(num_rows_deleted);
END;

------------------------------------------------------------------------------
--    PRIVATE METHODS
------------------------------------------------------------------------------
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |   INITIALIZE                                                              |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure initializes the parameters for procedure                |
 |    JG_ZZ_VAT_SELECTION_PKG.Main, and writes the values of parameters      |
 |    passed in debug file.                                                  |
 |                                                                           |
 |    Called from JG_ZZ_VAT_SELECTION_PKG.Main                               |
 |                                                                           |
 | SCOPE - Private                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |  Date           Author          Description                               |
 |  ============  ==============  =================================          |
 |   23-Jan-2006   RBASKER               Initial  Version.                   |
 |   28-Mar-2006   RBASKER     Incorporated changes for XBuild4.             |
 |                                                                           |
 +===========================================================================*/

PROCEDURE initialize(
            P_GLOBAL_VARIABLES_REC     OUT NOCOPY JG_ZZ_VAT_SELECTION_PKG.GLOBAL_VARIABLES_REC_TYPE,
	    P_REPORTING_LEVEL	       IN JG_ZZ_VAT_REP_ENTITIES.entity_level_code%TYPE,
	    P_LEDGER		       IN JG_ZZ_VAT_REP_ENTITIES.ledger_id%TYPE,
	    P_BSV		       IN JG_ZZ_VAT_REP_ENTITIES.balancing_segment_value%TYPE,
            P_VAT_REPORTING_ENTITY_ID  IN JG_ZZ_VAT_REP_ENTITIES.vat_reporting_entity_id%TYPE,
            P_TAX_PERIOD               IN JG_ZZ_VAT_REP_STATUS.tax_calendar_period%TYPE,
	    P_SOURCE                   IN JG_ZZ_VAT_REP_STATUS.source%TYPE,
            P_ACCTD_UNACCTD            IN VARCHAR2,
	    P_DEBUG_FLAG               IN VARCHAR2,
  	    P_ERRBUF                   IN OUT NOCOPY VARCHAR2,
            P_RETCODE                  IN OUT NOCOPY VARCHAR2)
IS
l_api_name           CONSTANT VARCHAR2(30) := 'INITIALIZE';

  BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',
		     G_PKG_NAME||': '||l_api_name||'()+');
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
		  'P_REPORTING_LEVEL = ' || P_REPORTING_LEVEL);
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
		'P_LEDGER = ' || P_LEDGER);
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
		'P_BSV = '|| P_BSV);
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
                  ' P_VAT_REPORTING_ENTITY_ID = ' || P_VAT_REPORTING_ENTITY_ID);
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
		   ' P_TAX_PERIOD = ' || P_TAX_PERIOD);
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
		    ' P_SOURCE = '|| P_SOURCE);
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
		    ' P_ACCTD_UNACCTD = '|| P_ACCTD_UNACCTD);
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
		    ' P_DEBUG_FLAG = '|| P_DEBUG_FLAG);
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
		      'P_ERRBUF  =   '||P_ERRBUF);
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
		       'P_RETCODE  =   '||P_RETCODE);
   END IF;

    IF p_debug_flag = 'Y' THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

      -- FND_FILE.PUT_LINE(FND_FILE.LOG,'start ..');
        P_GLOBAL_VARIABLES_REC.REPORTING_ENTITY_LEVEL  :=  P_REPORTING_LEVEL;
	P_GLOBAL_VARIABLES_REC.LEDGER		       :=  P_LEDGER;
	P_GLOBAL_VARIABLES_REC.BSV		       :=  P_BSV;
	P_GLOBAL_VARIABLES_REC.VAT_REPORTING_ENTITY_ID :=  P_VAT_REPORTING_ENTITY_ID;
        P_GLOBAL_VARIABLES_REC.TAX_PERIOD              :=  P_TAX_PERIOD;
	P_GLOBAL_VARIABLES_REC.SOURCE                  :=  P_SOURCE;
	P_GLOBAL_VARIABLES_REC.ACCTD_UNACCTD           :=  P_ACCTD_UNACCTD;
	P_GLOBAL_VARIABLES_REC.DEBUG_FLAG              :=  P_DEBUG_FLAG;
	P_GLOBAL_VARIABLES_REC.ERRBUF                  :=  P_ERRBUF;
        P_GLOBAL_VARIABLES_REC.RETCODE                 :=  NVL(P_RETCODE,0);
        IF P_GLOBAL_VARIABLES_REC.REPORTING_ENTITY_LEVEL IN ('LEDGER', 'BSV') THEN
	   P_GLOBAL_VARIABLES_REC.MAPPING_VAT_REP_ENTITY_ID := P_VAT_REPORTING_ENTITY_ID;
	END IF;
        g_debug_flag  := P_DEBUG_FLAG;

    --  Populate the WHO columns :

        g_created_by        := nvl(fnd_profile.value('USER_ID'),1);
        g_creation_date     := sysdate;
        g_last_updated_by   := nvl(fnd_profile.value('USER_ID'),1);
        g_last_update_date  := sysdate;
        g_last_update_login := 1;
        g_conc_request_id   := nvl(fnd_profile.value('CONC_REQUEST_ID'),1);
	g_prog_appl_id      := nvl(fnd_profile.value('PROG_APPL_ID'),1);
	g_conc_program_id   := nvl(fnd_profile.value('CONC_PROGRAM_ID'),1);
	g_conc_login_id     := nvl(fnd_profile.value('CONC_LOGIN_ID'),1);

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',
					G_PKG_NAME||': ' ||l_api_name||'()-');
   END IF;

   IF p_debug_flag = 'Y' THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME||': ' ||l_api_name||'()-');
    END IF;

   EXCEPTION
     WHEN OTHERS THEN
       g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
       IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name, g_error_buffer);
       END IF;

       IF p_debug_flag = 'Y' THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
       END IF;
      P_GLOBAL_VARIABLES_REC.RETCODE := 2;

END initialize;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |   get_period_date_range                                                   |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure gets the start and end date for a given period of the   |
 |    tax calendar. This serves as the tax reporting date range low and high.|
 |                                                                           |
 |    Called from JG_ZZ_VAT_SELECTION_PKG.main                               |
 |                                                                           |
 | SCOPE - Private                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |  Date           Author          Description                               |
 |  ============  ==============  =================================          |
 |   23-Jan-2006   RBASKER               Initial  Version.                   |
 |                                                                           |
 +===========================================================================*/

PROCEDURE get_period_date_range (
  p_calendar_name             IN         GL_PERIODS.period_set_name%TYPE,
  p_period                    IN         GL_PERIODS.period_name%TYPE,
  p_global_variables_rec      IN OUT NOCOPY JG_ZZ_VAT_SELECTION_PKG.GLOBAL_VARIABLES_REC_TYPE,
  x_return_status             OUT NOCOPY VARCHAR2
) IS
  l_api_name           CONSTANT VARCHAR2(30) := 'GET_PERIOD_DATE_RANGE';

  BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',
		G_PKG_NAME||': '||l_api_name||'()+');
   END IF;

 /*Set the return status to Success */
   x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF g_debug_flag = 'Y' THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME||': '||l_api_name||'()+');
    END IF;


      SELECT start_date,
             end_date
      INTO p_global_variables_rec.tax_invoice_date_low,
	   p_global_variables_rec.tax_invoice_date_high
      FROM GL_PERIODS
         WHERE period_set_name   = p_calendar_name
           AND period_name      =  p_period;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
		'TAX INVOICE DATE LOW = ' ||
		to_char( p_global_variables_rec.tax_invoice_date_low) );
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
                'TAX INVOICE DATE HIGH = ' ||
		to_char( p_global_variables_rec.tax_invoice_date_high) );
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
                 ' RETURN_STATUS = ' || x_return_status);
   END IF;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',
		G_PKG_NAME||': ' ||l_api_name||'()-');
   END IF;

   IF g_debug_flag = 'Y' THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME||': ' ||l_api_name||'()-');
    END IF;

   EXCEPTION
     WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

       g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

     IF g_debug_flag = 'Y' THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
     END IF;

       IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
       END IF;
        p_global_variables_rec.retcode := 2;
      RETURN;
  END get_period_date_range;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |   get_VAT_reporting_details                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure gets VAT configuration details like Tax Registration    |
 |    Number(TRN), Legal Entity, Tax calendar, Tax Regime for a given 	     |
 |    VAT_REPORTING_ENTITY_ID.					             |
 |                                                                           |
 |    Called from JG_ZZ_VAT_SELECTION_PKG.main                               |
 |                                                                           |
 | SCOPE - Private                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |  Date           Author          Description                               |
 |  ============  ==============  =================================          |
 |   23-Jan-2006   RBASKER         Initial  Version.                         |
 |   28-Mar-2006   RBASKER         Incorporated changes for XBuild4.         |
 |   28-Apr-2006   RBASKER         Bug: 5169118 - Fixed issues identified    |
 |                                 during Unit Testing.                      |
 |                                                                           |
 +===========================================================================*/

PROCEDURE get_VAT_reporting_details (
  p_vat_reporting_entity_id   IN            JG_ZZ_VAT_REP_ENTITIES.vat_reporting_entity_id%TYPE,
  p_global_variables_rec      IN OUT NOCOPY JG_ZZ_VAT_SELECTION_PKG.GLOBAL_VARIABLES_REC_TYPE,
  x_return_status             OUT NOCOPY VARCHAR2
) IS
  l_api_name           CONSTANT VARCHAR2(30) := 'GET_VAT_REPORTING_DETAILS';

  BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
   END IF;

 /*Set the return status to Success */
   x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF g_debug_flag = 'Y' THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

      SELECT legal_entity_id,
             tax_regime_code,
	     tax_registration_number,
             tax_calendar_name,
             driving_date_code
      INTO p_global_variables_rec.legal_entity_id,
           p_global_variables_rec.tax_regime_code,
 	   p_global_variables_rec.tax_registration_number,
	   p_global_variables_rec.tax_calendar_name,
           p_global_variables_rec.driving_date_code
      FROM JG_ZZ_VAT_REP_ENTITIES
         WHERE nvl(mapping_vat_rep_entity_id,
                    vat_reporting_entity_id)  = p_vat_reporting_entity_id
            AND entity_type_code = 'LEGAL';

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
		'LEGAL ENTITY ID = ' || p_global_variables_rec.legal_entity_id);
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
		'TAX REGIME CODE = ' || p_global_variables_rec.tax_regime_code);
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
		'TAX REG NUM = '|| p_global_variables_rec.tax_registration_number);
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
		'TAX CALENDAR NAME = '|| p_global_variables_rec.tax_calendar_name);
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
                'DRIVING_DATE_CODE = '|| p_global_variables_rec.driving_date_code);
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
                 ' RETURN_STATUS = ' || x_return_status);
   END IF;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',
			G_PKG_NAME||': ' ||l_api_name||'()-');
   END IF;

   IF g_debug_flag = 'Y' THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME||': ' ||l_api_name||'()-');
    END IF;

   EXCEPTION
     WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

       g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

     IF g_debug_flag = 'Y' THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
     END IF;

       IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
       END IF;
	 p_global_variables_rec.retcode := 2;
      RETURN;
  END get_VAT_reporting_details;

/*===========================================================================+
 | FUNCTION                                                                  |
 |   is_prev_period_open                                                     |
 | DESCRIPTION                                                               |
 |    This function returns TRUE if multiple periods are kept open  ie final |
 |     reporting process is not yet done for the prev period(s).             |
 | SCOPE - Private                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |  Date           Author          Description                               |
 |  ============  ==============  =================================          |
 |   23-Jan-2006   RBASKER               Initial  Version.                   |
 |                                                                           |
 +===========================================================================*/
FUNCTION is_prev_period_open(
         P_GLOBAL_VARIABLES_REC IN OUT NOCOPY JG_ZZ_VAT_SELECTION_PKG.GLOBAL_VARIABLES_REC_TYPE)
RETURN BOOLEAN IS

   l_api_name           CONSTANT VARCHAR2(30) := 'IS_MULTIPLE_PERIODS_OPEN';
   l_last_processed_date DATE;
   l_count NUMBER := 0;

BEGIN

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
   END IF;

    IF g_debug_flag = 'Y' THEN
		FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME||': '||l_api_name||'()+');
		FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_global_variables_rec.last_rep_period_start_date :'||p_global_variables_rec.last_rep_period_start_date);
		FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_global_variables_rec.tax_invoice_date_low       :'||p_global_variables_rec.tax_invoice_date_low);
    END IF;

   -- BEGIN Code to check if the period is prior to the last reported period in 11i. --9381398

 	      IF p_global_variables_rec.last_rep_period_start_date is not null  THEN
			IF  p_global_variables_rec.tax_invoice_date_low <= p_global_variables_rec.last_rep_period_start_date THEN
				RETURN TRUE;
			END IF;
 	      END IF;
   -- END Code to check if the period is prior the the last reported period in 11i. --9381398

	-- BEGIN Code to check if this is a very first reporting period.

	 select count(*) INTO l_count
	 from jg_zz_vat_rep_status
	 where vat_reporting_entity_id = p_global_variables_rec.vat_reporting_entity_id
	 and period_start_date < p_global_variables_rec.tax_invoice_date_low
	 and ( period_start_date > p_global_variables_rec.last_rep_period_start_date
		or p_global_variables_rec.last_rep_period_start_date is null) --9381398
	 and (source = p_global_variables_rec.SOURCE
		   OR p_global_variables_rec.SOURCE = 'ALL');

	 IF l_count = 0 THEN
	  RETURN FALSE;
	 END IF;

   -- END Code to check if this is a very first reporting period.

  --Find out the last final reported period
  l_last_processed_date :=   JG_ZZ_VAT_REP_UTILITY.get_last_processed_date(
        pn_vat_reporting_entity_id  => p_global_variables_rec.vat_reporting_entity_id,
        pv_source                   => p_global_variables_rec.source,
        pv_process_name             => 'FINAL REPORTING'
        );

   IF l_last_processed_date IS NOT NULL THEN
      IF l_last_processed_date + 1 = p_global_variables_rec.tax_invoice_date_low
	THEN
         RETURN FALSE;
      ELSE
	 RETURN TRUE;
     END IF;
   ELSE /* There is no processing record, this is the first run */
    -- RETURN FALSE;
       RETURN TRUE;
   END IF;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',
		G_PKG_NAME||': ' ||l_api_name||'()-');
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',
              'Last Processed Date : ' || to_char(l_last_processed_date));
   END IF;

   IF g_debug_flag = 'Y' THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME||': ' ||l_api_name||'()-');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
     g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

     IF g_debug_flag = 'Y' THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
     END IF;

     IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
      END IF;
      RETURN NULL;
END is_prev_period_open;

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
 |  Date           Author          Description                               |
 |  ============  ==============  =================================          |
 |   23-Jan-2006   RBASKER               Initial  Version.                   |
 |   28-Apr-2006   RBASKER         Bug: 5169118 - Fixed issues identified    |
 |                                 during Unit Testing.                      |
 |   18-Sep-2006   RBASKER        Bug 5509788 - Changes made to initialize   |
 |                                TAX_ORIGIN,TRX_CONTROL_ACCOUNT_FLEXFIELD,  |
 |                                GL_DATE                                    |
 +===========================================================================*/
PROCEDURE init_gt_variables
IS

l_api_name           CONSTANT VARCHAR2(30) := 'INIT_GT_VARIABLES';

BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',
                     G_PKG_NAME||': '||l_api_name||'()+');

   END IF;

    IF g_debug_flag = 'Y' THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

        gt_vat_transaction_id.delete;
	gt_reporting_status_id.delete;
	gt_rep_entity_id.delete;
	gt_rep_context_entity_name.delete;
	gt_rep_context_entity_loc_id.delete;
	gt_taxpayer_id.delete;
	gt_org_information2.delete;
	gt_legal_authority_name.delete;
	gt_legal_auth_address_line2.delete;
	gt_legal_auth_address_line3.delete;
	gt_legal_auth_city.delete;
	gt_legal_contact_party_name.delete;
	gt_activity_code.delete;
	gt_ledger_id.delete;
	gt_ledger_name.delete;
	gt_chart_of_accounts_id.delete;
	gt_extract_source_ledger.delete;
	gt_establishment_id.delete;
	gt_internal_organization_id.delete;
	gt_application_id.delete;
	gt_entity_code.delete;
	gt_event_class_code.delete;
	gt_trx_id.delete;
	gt_trx_number.delete;
	gt_trx_description.delete;
	gt_trx_currency_code.delete;
	gt_trx_type_id.delete;
	gt_trx_type_mng.delete;
	gt_trx_line_id.delete;
	gt_trx_line_number.delete;
	gt_trx_line_description.delete;
	gt_trx_level_type.delete;
	gt_trx_line_type.delete;
	gt_trx_line_class.delete;
	gt_trx_class_mng.delete;
	gt_trx_date.delete;
	gt_trx_due_date.delete;
	gt_trx_communicated_date.delete;
	gt_product_id.delete;
	gt_functional_currency_code.delete;
	gt_currency_conversion_type.delete;
	gt_currency_conversion_date.delete;
	gt_currency_conversion_rate.delete;
	gt_territory_short_name.delete;
	gt_doc_seq_id.delete;
	gt_doc_seq_name.delete;
	gt_doc_seq_value.delete;
	gt_trx_line_amt.delete;
	gt_receipt_class_id.delete;
	gt_applied_from_appl_id.delete;
	gt_applied_from_entity_code.delete;
	gt_applied_from_event_cls_cd.delete;
	gt_applied_from_trx_id.delete;
	gt_applied_from_line_id.delete;
	gt_applied_from_trx_number.delete;
	gt_adjusted_doc_appl_id.delete;
	gt_adjusted_doc_entity_code.delete;
	gt_adjusted_doc_event_cls_cd.delete;
	gt_adjusted_doc_trx_id.delete;
	gt_adjusted_doc_number.delete;
	gt_adjusted_doc_date.delete;
	gt_applied_to_application_id.delete;
	gt_applied_to_entity_code.delete;
	gt_applied_to_event_cls_code.delete;
	gt_applied_to_trx_id.delete;
	gt_applied_to_trx_line_id.delete;
	gt_applied_to_trx_number.delete;
	gt_ref_doc_application_id.delete;
	gt_ref_doc_entity_code.delete;
	gt_ref_doc_event_class_code.delete;
	gt_ref_doc_trx_id.delete;
	gt_ref_doc_line_id.delete;
	gt_merchant_party_doc_num.delete;
	gt_merchant_party_name.delete;
	gt_merchant_party_reference.delete;
	gt_merchant_party_tax_reg_num.delete;
	gt_merchant_party_taxpayer_id.delete;
	gt_start_expense_date.delete;
	gt_taxable_line_source_table.delete;
	gt_tax_line_id.delete;
	gt_tax_line_number.delete;
	gt_tax_invoice_date.delete;
	gt_taxable_amt.delete;
	gt_taxable_amt_funcl_curr.delete;
	gt_tax_amt.delete;
	gt_tax_amt_funcl_curr.delete;
	gt_rec_tax_amt_tax_curr.delete;
	gt_nrec_tax_amt_tax_curr.delete;
	gt_taxable_disc_amt.delete;
	gt_taxable_disc_amt_fun_curr.delete;
	gt_tax_disc_amt.delete;
	gt_tax_disc_amt_fun_curr.delete;
	gt_tax_rate_id.delete;
	gt_tax_rate_code.delete;
	gt_tax_rate.delete;
	gt_tax_rate_code_name.delete;
	gt_tax_rate_code_description.delete;
	gt_tax_rate_vat_trx_type_code.delete;
	gt_tax_rate_vat_trx_type_desc.delete;
	gt_tax_rate_vat_trx_type_mng.delete;
	gt_tax_rate_reg_type_code.delete;
	gt_tax_type_code.delete;
	gt_tax_type_mng.delete;
	gt_tax_recovery_rate.delete;
	gt_tax_regime_code.delete;
	gt_tax.delete;
	gt_tax_jurisdiction_code.delete;
	gt_tax_status_id.delete;
	gt_tax_status_code.delete;
	gt_tax_currency_code.delete;
	gt_offset_tax_rate_code.delete;
	gt_billing_tp_name.delete;
	gt_billing_tp_number.delete;
	gt_billing_tp_tax_reg_num.delete;
	gt_billing_tp_taxpayer_id.delete;
	gt_billing_tp_party_number.delete;
	gt_billing_tp_id.delete;
	gt_billing_tp_tax_rep_flag.delete;
	gt_billing_tp_site_id.delete;
	gt_billing_tp_address_id.delete;
	gt_billing_tp_site_name.delete;
	gt_billing_tp_site_tx_reg_num.delete;
	gt_shipping_tp_name.delete;
	gt_shipping_tp_number.delete;
	gt_shipping_tp_tax_reg_num.delete;
	gt_shipping_tp_taxpayer_id.delete;
	gt_shipping_tp_id.delete;
	gt_shipping_tp_site_id.delete;
	gt_shipping_tp_address_id.delete;
	gt_shipping_tp_site_name.delete;
	gt_shipping_tp_site_tx_rg_num.delete;
	gt_banking_tp_name.delete;
	gt_banking_tp_taxpayer_id.delete;
	gt_bank_account_name.delete;
	gt_bank_account_num.delete;
	gt_bank_account_id.delete;
	gt_bank_branch_id.delete;
	gt_legal_entity_tax_reg_num.delete;
	gt_hq_estb_reg_number.delete;
	gt_tax_line_registration_num.delete;
	gt_cancelled_date.delete;
	gt_cancel_flag.delete;
	gt_offset_flag.delete;
	gt_posted_flag.delete;
	gt_mrc_tax_line_flag.delete;
	gt_reconciliation_flag.delete;
	gt_tax_recoverable_flag.delete;
	gt_reverse_flag.delete;
	gt_correction_flag.delete;
	gt_ar_cash_receipt_rev_stat.delete;
	gt_ar_cash_receipt_rev_date.delete;
	gt_payables_invoice_source.delete;
	gt_acctd_amount_dr.delete;
	gt_acctd_amount_cr.delete;
	gt_rec_application_status.delete;
	gt_vat_country_code.delete;
	gt_invoice_identifier.delete;
	gt_account_class.delete;
	gt_latest_rec_flag.delete;
	gt_jgzz_fiscal_code.delete;
	gt_tax_reference.delete;
	gt_pt_location.delete;
	gt_invoice_report_type.delete;
	gt_es_correction_year.delete;
	gt_es_correction_period.delete;
	gt_triangulation.delete;
	gt_document_sub_type.delete;
	gt_assessable_value.delete;
	gt_property_location.delete;
	gt_chk_vat_amount_paid.delete;
	gt_import_document_number.delete;
	gt_import_document_date.delete;
	gt_prl_no.delete;
	gt_property_rental.delete;
	gt_rates_reference.delete;
	gt_stair_num.delete;
	gt_floor_num.delete;
	gt_door_num.delete;
	gt_amount_applied.delete;
	gt_actg_event_type_code.delete;
	gt_actg_event_type_mng.delete;
	gt_actg_event_number.delete;
	gt_actg_event_status_flag.delete;
	gt_actg_event_status_mng.delete;
	gt_actg_category_code.delete;
	gt_actg_category_mng.delete;
	gt_accounting_date.delete;
	gt_gl_transfer_flag.delete;
	gt_actg_line_num.delete;
	gt_actg_line_type_code.delete;
	gt_actg_line_type_mng.delete;
	gt_actg_line_description.delete;
	gt_actg_stat_amt.delete;
	gt_actg_party_id.delete;
	gt_actg_party_site_id.delete;
	gt_actg_party_type.delete;
	gt_actg_event_id.delete;
	gt_actg_header_id.delete;
	gt_actg_line_id.delete;
	gt_actg_source_id.delete;
	gt_actg_source_table.delete;
	gt_actg_line_ccid.delete;
	gt_account_flexfield.delete;
	gt_account_description.delete;
	gt_period_name.delete;
	gt_trx_arap_balancing_seg.delete;
	gt_trx_arap_natural_account.delete;
	gt_trx_taxable_balancing_seg.delete;
	gt_trx_taxable_natural_acct.delete;
	gt_trx_tax_balancing_seg.delete;
	gt_trx_tax_natural_account.delete;
	gt_created_by.delete;
	gt_creation_date.delete;
	gt_last_updated_by.delete;
	gt_last_update_date.delete;
	gt_last_update_login.delete;
	gt_request_id.delete;
	gt_program_application_id.delete;
	gt_program_id.delete;
	gt_program_login_id.delete;
	gt_object_version_number.delete;
        gt_gl_date.delete;
        gt_trx_ctrl_actg_flexfield.delete;
	gt_tax_origin.delete;
	gt_reporting_code.delete;
	gt_def_rec_settlement_opt_code.delete;
        gt_taxable_item_source_id.delete;


   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',
                                        G_PKG_NAME||': ' ||l_api_name||'()-');
   END IF;

   IF g_debug_flag = 'Y' THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME||': ' ||l_api_name||'()-');
   END IF;

EXCEPTION
     WHEN OTHERS THEN
        g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
       IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
       END IF;

      IF g_debug_flag = 'Y' THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
      END IF;
    --  l_GLOBAL_VARIABLES_REC.RETCODE := 2;

END init_gt_variables;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |   fetch_tax_data                                                         |
 | DESCRIPTION                                                               |
 |   This procedure fetches tax data from TRL interface tables using bulk    |
 |     collect and calls insert_tax_data to perform a bulk insert into       |
 |      jg_zz_vat_trx_details_table.                                         |
 | SCOPE - Private                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |  Date           Author          Description                               |
 |  ============  ==============  =================================          |
 |   23-Jan-2006   RBASKER         Initial  Version.                         |
 |   28-Mar-2006   RBASKER         Incorporated changes for XBuild4.         |
 |   28-Apr-2006   RBASKER         Bug: 5169118 - Fixed issues identified    |
 |                                 during Unit Testing.                      |
 |   28-May-2006   RBASKER         Bug: 5182167 - Fixed issues identified    |
 |                                 during Unit Testing. Also, modified GDF   |
 |                                 column mappings to reflect TRL changes.   |
 |   18-Sep-2006   RBASKER        Bug 5509788 - Changes made to fetch GL_DATE|
 |                                TAX_ORIGIN,TRX_CONTROL_ACCOUNT_FLEXFIELD   |
 |   22-Nov-2006   RBASKER        Bug 5673426 - Corrected the mapping        |
 |                                columns of ADJUSTED_DOC_XXXX columns in    |
 |                                fetch_tax_date and insert_tax_data proc    |
 |                                                                           |
 +===========================================================================*/

 PROCEDURE fetch_tax_data (
    P_GLOBAL_VARIABLES_REC   IN OUT NOCOPY JG_ZZ_VAT_SELECTION_PKG.GLOBAL_VARIABLES_REC_TYPE,
    x_request_id               IN NUMBER)
 IS

    TYPE trl_tax_data_curtype IS REF CURSOR;
    trl_tax_data_csr    trl_tax_data_curtype;
    i                    BINARY_INTEGER;
    l_api_name           CONSTANT VARCHAR2(30) := 'FETCH_TAX_DATA';
    l_correction_yes     CONSTANT VARCHAR2(1) := 'Y';
    l_correction_no     CONSTANT VARCHAR2(1) := 'N';
    l_tax_invoice_date_low DATE := P_GLOBAL_VARIABLES_REC.tax_invoice_date_low;
BEGIN

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',
                    G_PKG_NAME||': '||l_api_name||'()+');
   END IF;

    IF g_debug_flag = 'Y' THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

      OPEN trl_tax_data_csr FOR 'SELECT
CON.REP_ENTITY_ID			,
CON.REP_CONTEXT_ENTITY_NAME		,
CON.REP_CONTEXT_ENTITY_LOCATION_ID 	,
CON.TAXPAYER_ID				,
CON.ORG_INFORMATION2 			,
CON.LEGAL_AUTHORITY_NAME   		,
CON.LEGAL_AUTH_ADDRESS_LINE2         	,
CON.LEGAL_AUTH_ADDRESS_LINE3         	,
CON.LEGAL_AUTH_CITY                    	,
CON.LEGAL_CONTACT_PARTY_NAME                       	,
CON.ACTIVITY_CODE 	                                ,
DET.LEDGER_ID                                      	,
DET.LEDGER_NAME                                    	,
DET.CHART_OF_ACCOUNTS_ID                           	,
DET.EXTRACT_SOURCE_LEDGER                          	,
DET.ESTABLISHMENT_ID                               	,
DET.INTERNAL_ORGANIZATION_ID                       	,
DET.APPLICATION_ID                                 	,
DET.ENTITY_CODE                                         ,
DET.EVENT_CLASS_CODE                               	,
DET.TRX_ID                                         	,
DET.TRX_NUMBER                                     	,
DET.TRX_DESCRIPTION                                	,
DET.TRX_CURRENCY_CODE                              	,
DET.TRX_TYPE_ID                                    	,
DET.TRX_TYPE_MNG                                   	,
DET.TRX_LINE_ID                                    	,
DET.TRX_LINE_NUMBER                                	,
DET.TRX_LINE_DESCRIPTION                           	,
DET.TRX_LEVEL_TYPE                                 	,
DET.TRX_LINE_TYPE                                  	,
DET.TRX_LINE_CLASS                                 	,
DET.TRX_CLASS_MNG                                  	,
DET.TRX_DATE                                       	,
DET.TRX_DUE_DATE                                   	,
DET.TRX_COMMUNICATED_DATE                          	,
DET.PRODUCT_ID                                     	,
DET.FUNCTIONAL_CURRENCY_CODE                       	,
DET.CURRENCY_CONVERSION_TYPE                       	,
DET.CURRENCY_CONVERSION_DATE                       	,
DET.CURRENCY_CONVERSION_RATE                       	,
DET.TERRITORY_SHORT_NAME                           	,
DET.DOC_SEQ_ID                                     	,
DET.DOC_SEQ_NAME                                   	,
DET.DOC_SEQ_VALUE                                  	,
DET.TRX_LINE_AMT                                   	,
DET.RECEIPT_CLASS_ID  					,
DET.APPLIED_FROM_APPLICATION_ID                    	,
DET.APPLIED_FROM_ENTITY_CODE                       	,
DET.APPLIED_FROM_EVENT_CLASS_CODE                  	,
DET.APPLIED_FROM_TRX_ID                            	,
DET.APPLIED_FROM_LINE_ID                           	,
DET.APPLIED_FROM_TRX_NUMBER                        	,
DET.APPLIED_TO_APPLICATION_ID                      	,
DET.APPLIED_TO_ENTITY_CODE                         	,
DET.APPLIED_TO_EVENT_CLASS_CODE                    	,
DET.APPLIED_TO_TRX_ID                              	,
DET.APPLIED_TO_TRX_LINE_ID                         	,
DET.APPLIED_TO_TRX_NUMBER                          	,
DET.ADJUSTED_DOC_APPLICATION_ID                    	,
DET.ADJUSTED_DOC_ENTITY_CODE                       	,
DET.ADJUSTED_DOC_EVENT_CLASS_CODE                  	,
DET.ADJUSTED_DOC_TRX_ID                            	,
DET.ADJUSTED_DOC_NUMBER                            	,
DET.ADJUSTED_DOC_DATE                              	,
DET.REF_DOC_APPLICATION_ID                         	,
DET.REF_DOC_ENTITY_CODE                            	,
DET.REF_DOC_EVENT_CLASS_CODE                       	,
DET.REF_DOC_TRX_ID                                 	,
DET.REF_DOC_LINE_ID  					,
DET.MERCHANT_PARTY_DOCUMENT_NUMBER                 	,
DET.MERCHANT_PARTY_NAME                            	,
DET.MERCHANT_PARTY_REFERENCE                       	,
DET.MERCHANT_PARTY_TAX_REG_NUMBER                  	,
DET.MERCHANT_PARTY_TAXPAYER_ID                     	,
DET.START_EXPENSE_DATE                             	,
DET.TAXABLE_LINE_SOURCE_TABLE                      	,
DET.TAX_LINE_ID                                    	,
DET.TAX_LINE_NUMBER                                	,
DET.TAX_INVOICE_DATE                               	,
DET.TAXABLE_AMT                                    	,
DET.TAXABLE_AMT_FUNCL_CURR                         	,
DET.TAX_AMT                                        	,
DET.TAX_AMT_FUNCL_CURR                             	,
DET.REC_TAX_AMT_TAX_CURR                           	,
DET.NREC_TAX_AMT_TAX_CURR                      	        ,
DET.TAXABLE_DISC_AMT                               	,
DET.TAXABLE_DISC_AMT_FUNCL_CURR                    	,
DET.TAX_DISC_AMT                                   	,
DET.TAX_DISC_AMT_FUNCL_CURR                        	,
DET.TAX_RATE_ID                                    	,
DET.TAX_RATE_CODE                                  	,
DET.TAX_RATE                                       	,
DET.TAX_RATE_CODE_NAME                             	,
DET.TAX_RATE_CODE_DESCRIPTION                      	,
DET.TAX_RATE_VAT_TRX_TYPE_CODE                     	,
DET.TAX_RATE_VAT_TRX_TYPE_DESC                     	,
DET.TAX_RATE_CODE_VAT_TRX_TYPE_MNG                 	,
DET.TAX_RATE_REGISTER_TYPE_CODE                    	,
DET.TAX_TYPE_CODE                                  	,
DET.TAX_TYPE_MNG                                   	,
DET.TAX_RECOVERY_RATE                              	,
DET.TAX_REGIME_CODE                                	,
DET.TAX                                            	,
DET.TAX_JURISDICTION_CODE                          	,
DET.TAX_STATUS_ID                                  	,
DET.TAX_STATUS_CODE                                	,
DET.TAX_CURRENCY_CODE                              	,
DET.OFFSET_TAX_RATE_CODE                           	,
DET.BILLING_TP_NAME                                	,
DET.BILLING_TP_NUMBER                              	,
DET.BILLING_TP_TAX_REG_NUM                         	,
DET.BILLING_TP_TAXPAYER_ID                         	,
DET.BILLING_TP_PARTY_NUMBER                        	,
DET.BILLING_TRADING_PARTNER_ID                     	,
DET.BILLING_TP_TAX_REPORTING_FLAG                  	,
DET.BILLING_TP_SITE_ID                             	,
DET.BILLING_TP_ADDRESS_ID                          	,
DET.BILLING_TP_SITE_NAME                           	,
DET.BILLING_TP_SITE_TAX_REG_NUM                    	,
DET.SHIPPING_TP_NAME                               	,
DET.SHIPPING_TP_NUMBER                             	,
DET.SHIPPING_TP_TAX_REG_NUM                        	,
DET.SHIPPING_TP_TAXPAYER_ID                        	,
DET.SHIPPING_TRADING_PARTNER_ID                    	,
DET.SHIPPING_TP_SITE_ID                            	,
DET.SHIPPING_TP_ADDRESS_ID                         	,
DET.SHIPPING_TP_SITE_NAME                          	,
DET.SHIPPING_TP_SITE_TAX_REG_NUM                   	,
DET.BANKING_TP_NAME                                	,
DET.BANKING_TP_TAXPAYER_ID                         	,
DET.BANK_ACCOUNT_NAME                              	,
DET.BANK_ACCOUNT_NUM                               	,
DET.BANK_ACCOUNT_ID                                	,
DET.BANK_BRANCH_ID	,
DET.LEGAL_ENTITY_TAX_REG_NUMBER                    	,
DET.HQ_ESTB_REG_NUMBER                             	,
DET.TAX_LINE_REGISTRATION_NUMBER                   	,
DET.CANCELLED_DATE                                 	,
DET.CANCEL_FLAG                                    	,
DET.OFFSET_FLAG                                    	,
DET.POSTED_FLAG                                    	,
DET.MRC_TAX_LINE_FLAG                              	,
DET.RECONCILIATION_FLAG                            	,
DET.TAX_RECOVERABLE_FLAG                           	,
DET.REVERSE_FLAG                                   	,
DECODE (sign(:l_tax_invoice_date_low - DET.TAX_INVOICE_DATE)
             , -1,:correction_no
             , 0, :correction_no, :correction_yes) ,  /* Correction Flag */
DET.AR_CASH_RECEIPT_REVERSE_STATUS                 	,
DET.AR_CASH_RECEIPT_REVERSE_DATE                   	,
EXT.ATTRIBUTE20 	                , /* Payables_Invoice_Source */
DET.ACCTD_AMOUNT_DR                  	,
DET.ACCTD_AMOUNT_CR                 	,
DET.REC_APPLICATION_STATUS        	,
EXT.ATTRIBUTE10	                        , /* vat country code in fsp */
DET.SUB_LEDGER_INVOICE_IDENTIFIER	, /* gl_je_lines.Invoice_identifier*/
DET.ACCOUNT_CLASS			,
DET.LATEST_REC_FLAG			,
NVL(DET.BILLING_TP_TAXPAYER_ID, DET.SHIPPING_TP_TAXPAYER_ID),/*jgzz_fiscal_code*/
NVL(DET.BILLING_TP_TAX_REG_NUM , DET.SHIPPING_TP_TAX_REG_NUM),/*tax_reference */
EXT.ATTRIBUTE1 	                        ,	/* PT_LOCATION */
EXT.ATTRIBUTE23				,	/* MODELO TYPE */
EXT.ATTRIBUTE11 			,	/* ES Correctio year */
EXT.ATTRIBUTE12 			,	/* ES Correctio period */
EXT.ATTRIBUTE13 			,	/* Triangulation */
DET.DOCUMENT_SUB_TYPE			,
DET.ASSESSABLE_VALUE                    ,
EXT.ATTRIBUTE9 				,	/* Property location */
EXT.ATTRIBUTE8 				,	/* Chk VAT Amount paid */
EXT.ATTRIBUTE21           		,	/* Import document Number */
fnd_Date.canonical_To_Date(EXT.ATTRIBUTE22) ,  /* Import document Date */
--EXT.ATTRIBUTE14 			,	/* prl no */ {PRL NO is used for tax class}
EXT.ATTRIBUTE24                         ,       /* Tax Class */
EXT.ATTRIBUTE15 			,	/*property_rental */
EXT.ATTRIBUTE16 			,	/*rates_reference */
EXT.ATTRIBUTE17 			,	/*stair_num*/
EXT.ATTRIBUTE18 			,	/*floor_num*/
EXT.ATTRIBUTE19 			,	/*door_num*/
DET.AMOUNT_APPLIED                                 	,
ACT.ACTG_EVENT_TYPE_CODE                           	,
ACT.ACTG_EVENT_TYPE_MNG                            	,
ACT.ACTG_EVENT_NUMBER                              	,
ACT.ACTG_EVENT_STATUS_FLAG                         	,
ACT.ACTG_EVENT_STATUS_MNG                          	,
ACT.ACTG_CATEGORY_CODE                             	,
ACT.ACTG_CATEGORY_MNG                              	,
ACT.ACCOUNTING_DATE                                	,
ACT.GL_TRANSFER_FLAG                               	,
ACT.ACTG_LINE_NUM                                  	,
ACT.ACTG_LINE_TYPE_CODE                            	,
ACT.ACTG_LINE_TYPE_MNG                             	,
ACT.ACTG_LINE_DESCRIPTION                          	,
ACT.ACTG_STAT_AMT                                  	,
ACT.ACTG_PARTY_ID                                  	,
ACT.ACTG_PARTY_SITE_ID                             	,
ACT.ACTG_PARTY_TYPE                                	,
ACT.ACTG_EVENT_ID                                  	,
ACT.ACTG_HEADER_ID                                 	,
NULL                                   	,
ACT.ACTG_SOURCE_ID                                 	,
ACT.ACTG_SOURCE_TABLE                              	,
ACT.ACTG_LINE_CCID                                 	,
ACT.ACCOUNT_FLEXFIELD                              	,
ACT.ACCOUNT_DESCRIPTION                            	,
ACT.PERIOD_NAME                                    	,
ACT.TRX_ARAP_BALANCING_SEGMENT                     	,
ACT.TRX_ARAP_NATURAL_ACCOUNT                       	,
ACT.TRX_TAXABLE_BALANCING_SEGMENT                  	,
ACT.TRX_TAXABLE_NATURAL_ACCOUNT                    	,
ACT.TRX_TAX_BALANCING_SEGMENT                      	,
ACT.TRX_TAX_NATURAL_ACCOUNT                             ,
DET.GL_DATE                                             ,
ACT.TRX_CONTROL_ACCOUNT_FLEXFIELD                       ,
EXT.ATTRIBUTE25                        /* tax_origin*/  ,
EXT.ATTRIBUTE26			      /* Reporting Code */,
DET.DEF_REC_SETTLEMENT_OPTION_CODE /* Deferred Settlement Code*/,
DET.TAXABLE_ITEM_SOURCE_ID          /*TAXABLE_ITEM_SOURCE_ID */
 FROM		ZX_REP_CONTEXT_T	CON,
		ZX_REP_TRX_DETAIL_T	DET,
		ZX_REP_TRX_JX_EXT_T	EXT,
		ZX_REP_ACTG_EXT_T	ACT
	WHERE	CON.REQUEST_ID = :request_id
	AND     DET.REQUEST_ID = CON.REQUEST_ID
	AND     DET.REP_CONTEXT_ID = CON.REP_CONTEXT_ID
	AND     EXT.DETAIL_TAX_LINE_ID(+) = DET.DETAIL_TAX_LINE_ID
	AND     ACT.DETAIL_TAX_LINE_ID(+) = DET.DETAIL_TAX_LINE_ID
        AND NOT EXISTS (SELECT 1
                        FROM JG_ZZ_VAT_TRX_DETAILS JZVTD
                        WHERE JZVTD.TRX_ID            = DET.TRX_ID
                        AND   JZVTD.APPLICATION_ID    = DET.APPLICATION_ID
		        AND   JZVTD.ENTITY_CODE       = DET.ENTITY_CODE
			AND   JZVTD.EVENT_CLASS_CODE  = DET.EVENT_CLASS_CODE
/************************************************************************
Bug 7379550 Start: Added the below 2 conditions also so that
VAT Selection Process is able to fetch data when 1 transaction
has multiple Tax Regime Code
*************************************************************************/
                        AND   JZVTD.TRX_LINE_ID       = DET.TRX_LINE_ID
                        AND  NVL(JZVTD.TAX_LINE_ID,-1)    = NVL(DET.TAX_LINE_ID,-1)
                        --AND   NVL(JZVTD.CANCEL_FLAG,-1) = NVL(DET.CANCEL_FLAG,-1))
			AND   JZVTD.ACTG_SOURCE_ID = ACT.ACTG_SOURCE_ID)'
/************************************************************************
Bug 7379550 End
*************************************************************************/
	 USING l_tax_invoice_date_low, l_correction_no, l_correction_no,
              l_correction_yes, x_request_id;

  init_gt_variables;

  LOOP
    FETCH trl_tax_data_csr BULK COLLECT INTO
        gt_rep_entity_id,
        gt_rep_context_entity_name,
        gt_rep_context_entity_loc_id,
        gt_taxpayer_id,
        gt_org_information2,
        gt_legal_authority_name,
        gt_legal_auth_address_line2,
        gt_legal_auth_address_line3,
        gt_legal_auth_city,
        gt_legal_contact_party_name,
        gt_activity_code,
        gt_ledger_id,
        gt_ledger_name,
        gt_chart_of_accounts_id,
        gt_extract_source_ledger,
        gt_establishment_id,
        gt_internal_organization_id,
        gt_application_id,
        gt_entity_code,
        gt_event_class_code,
        gt_trx_id,
        gt_trx_number,
        gt_trx_description,
        gt_trx_currency_code,
        gt_trx_type_id,
        gt_trx_type_mng,
        gt_trx_line_id,
        gt_trx_line_number,
        gt_trx_line_description,
        gt_trx_level_type,
        gt_trx_line_type,
        gt_trx_line_class,
        gt_trx_class_mng,
        gt_trx_date,
        gt_trx_due_date,
        gt_trx_communicated_date,
        gt_product_id,
        gt_functional_currency_code,
        gt_currency_conversion_type,
        gt_currency_conversion_date,
        gt_currency_conversion_rate,
        gt_territory_short_name,
        gt_doc_seq_id,
        gt_doc_seq_name,
        gt_doc_seq_value,
        gt_trx_line_amt,
        gt_receipt_class_id,
        gt_applied_from_appl_id,
        gt_applied_from_entity_code,
        gt_applied_from_event_cls_cd,
        gt_applied_from_trx_id,
        gt_applied_from_line_id,
        gt_applied_from_trx_number,
        gt_applied_to_application_id,
        gt_applied_to_entity_code,
        gt_applied_to_event_cls_code,
        gt_applied_to_trx_id,
        gt_applied_to_trx_line_id,
        gt_applied_to_trx_number,
        gt_adjusted_doc_appl_id,
        gt_adjusted_doc_entity_code,
        gt_adjusted_doc_event_cls_cd,
        gt_adjusted_doc_trx_id,
        gt_adjusted_doc_number,
        gt_adjusted_doc_date,
        gt_ref_doc_application_id,
        gt_ref_doc_entity_code,
        gt_ref_doc_event_class_code,
        gt_ref_doc_trx_id,
        gt_ref_doc_line_id,
        gt_merchant_party_doc_num,
        gt_merchant_party_name,
        gt_merchant_party_reference,
        gt_merchant_party_tax_reg_num,
        gt_merchant_party_taxpayer_id,
        gt_start_expense_date,
        gt_taxable_line_source_table,
        gt_tax_line_id,
        gt_tax_line_number,
        gt_tax_invoice_date,
        gt_taxable_amt,
        gt_taxable_amt_funcl_curr,
        gt_tax_amt,
        gt_tax_amt_funcl_curr,
        gt_rec_tax_amt_tax_curr,
        gt_nrec_tax_amt_tax_curr,
        gt_taxable_disc_amt,
        gt_taxable_disc_amt_fun_curr,
        gt_tax_disc_amt,
        gt_tax_disc_amt_fun_curr,
        gt_tax_rate_id,
        gt_tax_rate_code,
        gt_tax_rate,
        gt_tax_rate_code_name,
        gt_tax_rate_code_description,
        gt_tax_rate_vat_trx_type_code,
        gt_tax_rate_vat_trx_type_desc,
        gt_tax_rate_vat_trx_type_mng,
        gt_tax_rate_reg_type_code,
        gt_tax_type_code,
        gt_tax_type_mng,
        gt_tax_recovery_rate,
        gt_tax_regime_code,
        gt_tax,
        gt_tax_jurisdiction_code,
        gt_tax_status_id,
        gt_tax_status_code,
        gt_tax_currency_code,
        gt_offset_tax_rate_code,
        gt_billing_tp_name,
        gt_billing_tp_number,
        gt_billing_tp_tax_reg_num,
        gt_billing_tp_taxpayer_id,
        gt_billing_tp_party_number,
        gt_billing_tp_id,
        gt_billing_tp_tax_rep_flag,
        gt_billing_tp_site_id,
        gt_billing_tp_address_id,
        gt_billing_tp_site_name,
        gt_billing_tp_site_tx_reg_num,
        gt_shipping_tp_name,
        gt_shipping_tp_number,
        gt_shipping_tp_tax_reg_num,
        gt_shipping_tp_taxpayer_id,
        gt_shipping_tp_id,
        gt_shipping_tp_site_id,
        gt_shipping_tp_address_id,
        gt_shipping_tp_site_name,
        gt_shipping_tp_site_tx_rg_num,
        gt_banking_tp_name,
        gt_banking_tp_taxpayer_id,
        gt_bank_account_name,
        gt_bank_account_num,
        gt_bank_account_id,
        gt_bank_branch_id,
        gt_legal_entity_tax_reg_num,
        gt_hq_estb_reg_number,
        gt_tax_line_registration_num,
        gt_cancelled_date,
        gt_cancel_flag,
        gt_offset_flag,
        gt_posted_flag,
        gt_mrc_tax_line_flag,
        gt_reconciliation_flag,
        gt_tax_recoverable_flag,
        gt_reverse_flag,
        gt_correction_flag,
        gt_ar_cash_receipt_rev_stat,
        gt_ar_cash_receipt_rev_date,
        gt_payables_invoice_source,
        gt_acctd_amount_dr,
        gt_acctd_amount_cr,
        gt_rec_application_status,
        gt_vat_country_code,
        gt_invoice_identifier,
        gt_account_class,
        gt_latest_rec_flag,
        gt_jgzz_fiscal_code,
        gt_tax_reference,
        gt_pt_location,
        gt_invoice_report_type,
        gt_es_correction_year,
        gt_es_correction_period,
        gt_triangulation,
        gt_document_sub_type,
        gt_assessable_value,
        gt_property_location,
        gt_chk_vat_amount_paid,
        gt_import_document_number,
        gt_import_document_date,
        gt_prl_no,
        gt_property_rental,
        gt_rates_reference,
        gt_stair_num,
        gt_floor_num,
        gt_door_num,
        gt_amount_applied,
        gt_actg_event_type_code,
        gt_actg_event_type_mng,
        gt_actg_event_number,
        gt_actg_event_status_flag,
        gt_actg_event_status_mng,
        gt_actg_category_code,
        gt_actg_category_mng,
        gt_accounting_date,
        gt_gl_transfer_flag,
        gt_actg_line_num,
        gt_actg_line_type_code,
        gt_actg_line_type_mng,
        gt_actg_line_description,
        gt_actg_stat_amt,
        gt_actg_party_id,
        gt_actg_party_site_id,
        gt_actg_party_type,
        gt_actg_event_id,
        gt_actg_header_id,
        gt_actg_line_id,
        gt_actg_source_id,
        gt_actg_source_table,
        gt_actg_line_ccid,
        gt_account_flexfield,
        gt_account_description,
        gt_period_name,
        gt_trx_arap_balancing_seg,
        gt_trx_arap_natural_account,
        gt_trx_taxable_balancing_seg,
        gt_trx_taxable_natural_acct,
        gt_trx_tax_balancing_seg,
        gt_trx_tax_natural_account,
        gt_gl_date,
        gt_trx_ctrl_actg_flexfield,
        gt_tax_origin,
	gt_reporting_code,
	gt_def_rec_settlement_opt_code,
        gt_taxable_item_source_id
    LIMIT C_LINES_PER_COMMIT;

       insert_tax_data;
       COMMIT;
       init_gt_variables;
       EXIT WHEN trl_tax_data_csr%NOTFOUND;

  END LOOP;
	CLOSE trl_tax_data_csr;
   IF g_debug_flag = 'Y' THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME||': ' ||l_api_name||'()-');
    END IF;

 EXCEPTION
    WHEN OTHERS THEN
       g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

      IF g_debug_flag = 'Y' THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
      END IF;

      IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
       END IF;
        p_global_variables_rec.retcode := 2;
      RETURN;
END fetch_tax_data;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |   insert_tax_data                                                         |
 | DESCRIPTION                                                               |
 |    This procedure bulk inserts tax data into JG_ZZ_VAT_TRX_DETAILS table  |
 |                                                                           |
 | SCOPE - Private                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |  Date           Author          Description                               |
 |  ============  ==============  =================================          |
 |   23-Jan-2006   RBASKER               Initial  Version.                   |
 |   28-Apr-2006   RBASKER         Bug: 5169118 - Fixed issues identified    |
 |                                 during Unit Testing.                      |
 |   18-Sep-2006   RBASKER        Bug 5509788  Changes made to insert gl_date|
 |                                TAX_ORIGIN,TRX_CONTROL_ACCOUNT_FLEXFIELD   |
 |   22-Nov-2006   RBASKER        Bug 5673426 - Corrected the mapping        |
 |                                columns of ADJUSTED_DOC_XXXX columns in    |
 |                                fetch_tax_date and insert_tax_data proc    |
 |                                                                           |
 +===========================================================================*/

PROCEDURE insert_tax_data
IS
    l_count     NUMBER;
    l_api_name           CONSTANT VARCHAR2(30) := 'INSERT_TAX_DATA';
BEGIN

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name ,
               G_PKG_NAME||': '||l_api_name||'(+)');
   END IF;

    IF g_debug_flag = 'Y' THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

   l_count  := GT_TRX_ID.COUNT;


   IF (g_level_procedure >= g_current_runtime_level ) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name ,
                                      ' Record Count = ' ||to_char(l_count));
   END IF;

   if g_selection_process_id is null then
      select JG_ZZ_VAT_REP_STATUS_S1.NEXTVAL
        into g_selection_process_id from dual;
   end if;


  FORALL i IN 1 .. l_count

  INSERT INTO JG_ZZ_VAT_TRX_DETAILS(
    VAT_TRANSACTION_ID                     	,
    REPORTING_STATUS_ID                    	,
    SELECTION_PROCESS_ID                   	,
    FINAL_REPORTING_ID                     	,
    REP_ENTITY_ID                                  	,
    REP_CONTEXT_ENTITY_NAME                        	,
    REP_CONTEXT_ENTITY_LOCATION_ID                 	,
    TAXPAYER_ID                                    	,
    ORG_INFORMATION2                               	,
    LEGAL_AUTHORITY_NAME                           	,
    LEGAL_AUTH_ADDRESS_LINE2                       	,
    LEGAL_AUTH_ADDRESS_LINE3                       	,
    LEGAL_AUTH_CITY                                	,
    LEGAL_CONTACT_PARTY_NAME                       	,
    ACTIVITY_CODE                                  	,
    LEDGER_ID                                      	,
    LEDGER_NAME                                    	,
    CHART_OF_ACCOUNTS_ID                           	,
    EXTRACT_SOURCE_LEDGER                          	,
    ESTABLISHMENT_ID                               	,
    INTERNAL_ORGANIZATION_ID                       	,
    APPLICATION_ID                                 	,
    ENTITY_CODE                                    	,
    EVENT_CLASS_CODE                               	,
    TRX_ID                                         	,
    TRX_NUMBER                                     	,
    TRX_DESCRIPTION                                	,
    TRX_CURRENCY_CODE                              	,
    TRX_TYPE_ID                                    	,
    TRX_TYPE_MNG                                   	,
    TRX_LINE_ID                                    	,
    TRX_LINE_NUMBER                                	,
    TRX_LINE_DESCRIPTION                           	,
    TRX_LEVEL_TYPE                                 	,
    TRX_LINE_TYPE                                  	,
    TRX_LINE_CLASS                                 	,
    TRX_CLASS_MNG                                  	,
    TRX_DATE                                       	,
    TRX_DUE_DATE                                   	,
    TRX_COMMUNICATED_DATE                          	,
    PRODUCT_ID                                     	,
    FUNCTIONAL_CURRENCY_CODE                       	,
    CURRENCY_CONVERSION_TYPE                       	,
    CURRENCY_CONVERSION_DATE                       	,
    CURRENCY_CONVERSION_RATE                       	,
    TERRITORY_SHORT_NAME                           	,
    DOC_SEQ_ID                                     	,
    DOC_SEQ_NAME                                   	,
    DOC_SEQ_VALUE                                  	,
    TRX_LINE_AMT                                   	,
    RECEIPT_CLASS_ID                               	,
    APPLIED_FROM_APPLICATION_ID                    	,
    APPLIED_FROM_ENTITY_CODE                       	,
    APPLIED_FROM_EVENT_CLASS_CODE                  	,
    APPLIED_FROM_TRX_ID                            	,
    APPLIED_FROM_LINE_ID                           	,
    APPLIED_FROM_TRX_NUMBER                        	,
    APPLIED_TO_APPLICATION_ID                      	,
    APPLIED_TO_ENTITY_CODE                         	,
    APPLIED_TO_EVENT_CLASS_CODE                    	,
    APPLIED_TO_TRX_ID                              	,
    APPLIED_TO_TRX_LINE_ID                         	,
    APPLIED_TO_TRX_NUMBER                          	,
    ADJUSTED_DOC_APPLICATION_ID                    	,
    ADJUSTED_DOC_ENTITY_CODE                       	,
    ADJUSTED_DOC_EVENT_CLASS_CODE                  	,
    ADJUSTED_DOC_TRX_ID                            	,
    ADJUSTED_DOC_NUMBER                            	,
    ADJUSTED_DOC_DATE                              	,
    REF_DOC_APPLICATION_ID                         	,
    REF_DOC_ENTITY_CODE                            	,
    REF_DOC_EVENT_CLASS_CODE                       	,
    REF_DOC_TRX_ID                                 	,
    REF_DOC_LINE_ID                                	,
    MERCHANT_PARTY_DOCUMENT_NUMBER                 	,
    MERCHANT_PARTY_NAME                            	,
    MERCHANT_PARTY_REFERENCE                       	,
    MERCHANT_PARTY_TAX_REG_NUMBER                  	,
    MERCHANT_PARTY_TAXPAYER_ID                     	,
    START_EXPENSE_DATE                             	,
    TAXABLE_LINE_SOURCE_TABLE                      	,
    TAX_LINE_ID                                    	,
    TAX_LINE_NUMBER                                	,
    TAX_INVOICE_DATE                               	,
    TAXABLE_AMT                                    	,
    TAXABLE_AMT_FUNCL_CURR                         	,
    TAX_AMT                                        	,
    TAX_AMT_FUNCL_CURR                             	,
    REC_TAX_AMT_TAX_CURR                           	,
    NREC_TAX_AMT_TAX_CURR                          	,
    TAXABLE_DISC_AMT                               	,
    TAXABLE_DISC_AMT_FUNCL_CURR                    	,
    TAX_DISC_AMT                                   	,
    TAX_DISC_AMT_FUNCL_CURR                        	,
    TAX_RATE_ID                                    	,
    TAX_RATE_CODE                                  	,
    TAX_RATE                                       	,
    TAX_RATE_CODE_NAME                             	,
    TAX_RATE_CODE_DESCRIPTION                      	,
    TAX_RATE_VAT_TRX_TYPE_CODE                     	,
    TAX_RATE_VAT_TRX_TYPE_DESC                     	,
    TAX_RATE_CODE_VAT_TRX_TYPE_MNG                 	,
    TAX_RATE_REGISTER_TYPE_CODE                    	,
    TAX_TYPE_CODE                                  	,
    TAX_TYPE_MNG                                   	,
    TAX_RECOVERY_RATE                              	,
    TAX_REGIME_CODE                                	,
    TAX                                            	,
    TAX_JURISDICTION_CODE                          	,
    TAX_STATUS_ID                                  	,
    TAX_STATUS_CODE                                	,
    TAX_CURRENCY_CODE                              	,
    OFFSET_TAX_RATE_CODE                           	,
    BILLING_TP_NAME                                	,
    BILLING_TP_NUMBER                              	,
    BILLING_TP_TAX_REG_NUM                         	,
    BILLING_TP_TAXPAYER_ID                         	,
    BILLING_TP_PARTY_NUMBER                        	,
    BILLING_TRADING_PARTNER_ID                     	,
    BILLING_TP_TAX_REPORTING_FLAG                  	,
    BILLING_TP_SITE_ID                             	,
    BILLING_TP_ADDRESS_ID                          	,
    BILLING_TP_SITE_NAME                           	,
    BILLING_TP_SITE_TAX_REG_NUM                    	,
    SHIPPING_TP_NAME                               	,
    SHIPPING_TP_NUMBER                             	,
    SHIPPING_TP_TAX_REG_NUM                        	,
    SHIPPING_TP_TAXPAYER_ID                        	,
    SHIPPING_TRADING_PARTNER_ID                    	,
    SHIPPING_TP_SITE_ID                            	,
    SHIPPING_TP_ADDRESS_ID                         	,
    SHIPPING_TP_SITE_NAME                          	,
    SHIPPING_TP_SITE_TAX_REG_NUM                   	,
    BANKING_TP_NAME                                	,
    BANKING_TP_TAXPAYER_ID                         	,
    BANK_ACCOUNT_NAME                              	,
    BANK_ACCOUNT_NUM                               	,
    BANK_ACCOUNT_ID                                	,
    BANK_BRANCH_ID                                 	,
    LEGAL_ENTITY_TAX_REG_NUMBER                    	,
    HQ_ESTB_REG_NUMBER                             	,
    TAX_LINE_REGISTRATION_NUMBER                   	,
    CANCELLED_DATE                                 	,
    CANCEL_FLAG                                    	,
    OFFSET_FLAG                                    	,
    POSTED_FLAG                                    	,
    MRC_TAX_LINE_FLAG                              	,
    RECONCILIATION_FLAG                            	,
    TAX_RECOVERABLE_FLAG                           	,
    REVERSE_FLAG                                   	,
    CORRECTION_FLAG                                	,
    AR_CASH_RECEIPT_REVERSE_STATUS                 	,
    AR_CASH_RECEIPT_REVERSE_DATE                   	,
    PAYABLES_INVOICE_SOURCE                        	,
    ACCTD_AMOUNT_DR                                	,
    ACCTD_AMOUNT_CR                                	,
    REC_APPLICATION_STATUS                         	,
    VAT_COUNTRY_CODE                               	,
    INVOICE_IDENTIFIER                             	,
    ACCOUNT_CLASS                                  	,
    LATEST_REC_FLAG                                	,
    JGZZ_FISCAL_CODE                               	,
    TAX_REFERENCE                                  	,
    PT_LOCATION                                    	,
    INVOICE_REPORT_TYPE                            	,
    ES_CORRECTION_YEAR                             	,
    ES_CORRECTION_PERIOD                           	,
    TRIANGULATION                                  	,
    DOCUMENT_SUB_TYPE                              	,
    ASSESSABLE_VALUE                               	,
    PROPERTY_LOCATION                              	,
    CHK_VAT_AMOUNT_PAID                            	,
    IMPORT_DOCUMENT_NUMBER                         	,
    IMPORT_DOCUMENT_DATE                           	,
    PRL_NO                                         	,
    PROPERTY_RENTAL                                	,
    RATES_REFERENCE                                	,
    STAIR_NUM                                      	,
    FLOOR_NUM                                      	,
    DOOR_NUM                                       	,
    AMOUNT_APPLIED                                 	,
    ACTG_EVENT_TYPE_CODE                           	,
    ACTG_EVENT_TYPE_MNG                            	,
    ACTG_EVENT_NUMBER                              	,
    ACTG_EVENT_STATUS_FLAG                         	,
    ACTG_EVENT_STATUS_MNG                          	,
    ACTG_CATEGORY_CODE                             	,
    ACTG_CATEGORY_MNG                              	,
    ACCOUNTING_DATE                                	,
    GL_TRANSFER_FLAG                               	,
    ACTG_LINE_NUM                                  	,
    ACTG_LINE_TYPE_CODE                            	,
    ACTG_LINE_TYPE_MNG                             	,
    ACTG_LINE_DESCRIPTION                          	,
    ACTG_STAT_AMT                                  	,
    ACTG_PARTY_ID                                  	,
    ACTG_PARTY_SITE_ID                             	,
    ACTG_PARTY_TYPE                                	,
    ACTG_EVENT_ID                                  	,
    ACTG_HEADER_ID                                 	,
    ACTG_LINE_ID                                   	,
    ACTG_SOURCE_ID                                 	,
    ACTG_SOURCE_TABLE                              	,
    ACTG_LINE_CCID                                 	,
    ACCOUNT_FLEXFIELD                              	,
    ACCOUNT_DESCRIPTION                            	,
    PERIOD_NAME                                    	,
    TRX_ARAP_BALANCING_SEGMENT                     	,
    TRX_ARAP_NATURAL_ACCOUNT                       	,
    TRX_TAXABLE_BALANCING_SEGMENT                  	,
    TRX_TAXABLE_NATURAL_ACCOUNT                    	,
    TRX_TAX_BALANCING_SEGMENT                      	,
    TRX_TAX_NATURAL_ACCOUNT                        	,
    CREATED_BY                       	,
    CREATION_DATE                          	,
    LAST_UPDATED_BY                     	,
    LAST_UPDATE_DATE                        	,
    LAST_UPDATE_LOGIN                              	,
    REQUEST_ID                                     	,
    PROGRAM_APPLICATION_ID                         	,
    PROGRAM_ID                                     	,
    PROGRAM_LOGIN_ID                               	,
    OBJECT_VERSION_NUMBER                  	,
    GL_DATE                                     ,
    TRX_CONTROL_ACCOUNT_FLEXFIELD               ,
    TAX_ORIGIN					,
    REPORTING_CODE                              ,
    DEF_REC_SETTLEMENT_OPTION_CODE              ,
    TAXABLE_ITEM_SOURCE_ID)
   VALUES (
        JG_ZZ_VAT_TRX_DETAILS_S.NEXTVAL,
	DECODE( gt_extract_source_ledger(i), 'AR', g_rep_status_id_ar,
				'AP', g_rep_status_id_ap,
				'GL', g_rep_status_id_gl),
        g_selection_process_id,
	NULL,
	gt_rep_entity_id(i),
        gt_rep_context_entity_name(i),
        gt_rep_context_entity_loc_id(i),
        gt_taxpayer_id(i),
        gt_org_information2(i),
        gt_legal_authority_name(i),
        gt_legal_auth_address_line2(i),
        gt_legal_auth_address_line3(i),
        gt_legal_auth_city(i),
        gt_legal_contact_party_name(i),
        gt_activity_code(i),
        gt_ledger_id(i),
        gt_ledger_name(i),
        gt_chart_of_accounts_id(i),
        gt_extract_source_ledger(i),
        gt_establishment_id(i),
        gt_internal_organization_id(i),
        gt_application_id(i),
        gt_entity_code(i),
        gt_event_class_code(i),
        gt_trx_id(i),
        gt_trx_number(i),
        gt_trx_description(i),
        gt_trx_currency_code(i),
 	gt_trx_type_id(i),
        gt_trx_type_mng(i),
        gt_trx_line_id(i),
        gt_trx_line_number(i),
        gt_trx_line_description(i),
        gt_trx_level_type(i),
        gt_trx_line_type(i),
        gt_trx_line_class(i),
        gt_trx_class_mng(i),
        gt_trx_date(i),
        gt_trx_due_date(i),
        gt_trx_communicated_date(i),
        gt_product_id(i),
        gt_functional_currency_code(i),
        gt_currency_conversion_type(i),
        gt_currency_conversion_date(i),
        gt_currency_conversion_rate(i),
        gt_territory_short_name(i),
        gt_doc_seq_id(i),
        gt_doc_seq_name(i),
        gt_doc_seq_value(i),
        gt_trx_line_amt(i),
        gt_receipt_class_id(i),
        gt_applied_from_appl_id(i),
        gt_applied_from_entity_code(i),
        gt_applied_from_event_cls_cd(i),
        gt_applied_from_trx_id(i),
        gt_applied_from_line_id(i),
        gt_applied_from_trx_number(i),
        gt_applied_to_application_id(i),
        gt_applied_to_entity_code(i),
        gt_applied_to_event_cls_code(i),
        gt_applied_to_trx_id(i),
        gt_applied_to_trx_line_id(i),
        gt_applied_to_trx_number(i),
        gt_adjusted_doc_appl_id(i),
        gt_adjusted_doc_entity_code(i),
        gt_adjusted_doc_event_cls_cd(i),
        gt_adjusted_doc_trx_id(i),
        gt_adjusted_doc_number(i),
        gt_adjusted_doc_date(i),
        gt_ref_doc_application_id(i),
        gt_ref_doc_entity_code(i),
        gt_ref_doc_event_class_code(i),
        gt_ref_doc_trx_id(i),
        gt_ref_doc_line_id(i),
        gt_merchant_party_doc_num(i),
        gt_merchant_party_name(i),
        gt_merchant_party_reference(i),
        gt_merchant_party_tax_reg_num(i),
 	gt_merchant_party_taxpayer_id(i),
        gt_start_expense_date(i),
        gt_taxable_line_source_table(i),
        gt_tax_line_id(i),
        gt_tax_line_number(i),
        gt_tax_invoice_date(i),
        gt_taxable_amt(i),
        gt_taxable_amt_funcl_curr(i),
        gt_tax_amt(i),
        gt_tax_amt_funcl_curr(i),
        gt_rec_tax_amt_tax_curr(i),
        gt_nrec_tax_amt_tax_curr(i),
        gt_taxable_disc_amt(i),
        gt_taxable_disc_amt_fun_curr(i),
        gt_tax_disc_amt(i),
        gt_tax_disc_amt_fun_curr(i),
        gt_tax_rate_id(i),
        gt_tax_rate_code(i),
        gt_tax_rate(i),
        gt_tax_rate_code_name(i),
        gt_tax_rate_code_description(i),
        gt_tax_rate_vat_trx_type_code(i),
        gt_tax_rate_vat_trx_type_desc(i),
        gt_tax_rate_vat_trx_type_mng(i),
        gt_tax_rate_reg_type_code(i),
        gt_tax_type_code(i),
        gt_tax_type_mng(i),
        gt_tax_recovery_rate(i),
        gt_tax_regime_code(i),
        gt_tax(i),
        gt_tax_jurisdiction_code(i),
        gt_tax_status_id(i),
        gt_tax_status_code(i),
        gt_tax_currency_code(i),
        gt_offset_tax_rate_code(i),
        gt_billing_tp_name(i),
        gt_billing_tp_number(i),
        gt_billing_tp_tax_reg_num(i),
        gt_billing_tp_taxpayer_id(i),
        gt_billing_tp_party_number(i),
        gt_billing_tp_id(i),
        gt_billing_tp_tax_rep_flag(i),
        gt_billing_tp_site_id(i),
        gt_billing_tp_address_id(i),
        gt_billing_tp_site_name(i),
        gt_billing_tp_site_tx_reg_num(i),
        gt_shipping_tp_name(i),
        gt_shipping_tp_number(i),
        gt_shipping_tp_tax_reg_num(i),
        gt_shipping_tp_taxpayer_id(i),
 	gt_shipping_tp_id(i),
        gt_shipping_tp_site_id(i),
        gt_shipping_tp_address_id(i),
        gt_shipping_tp_site_name(i),
        gt_shipping_tp_site_tx_rg_num(i),
        gt_banking_tp_name(i),
        gt_banking_tp_taxpayer_id(i),
        gt_bank_account_name(i),
        gt_bank_account_num(i),
        gt_bank_account_id(i),
        gt_bank_branch_id(i),
        gt_legal_entity_tax_reg_num(i),
        gt_hq_estb_reg_number(i),
        gt_tax_line_registration_num(i),
        gt_cancelled_date(i),
        gt_cancel_flag(i),
        gt_offset_flag(i),
        gt_posted_flag(i),
        gt_mrc_tax_line_flag(i),
        gt_reconciliation_flag(i),
        gt_tax_recoverable_flag(i),
        gt_reverse_flag(i),
        gt_correction_flag(i),
        gt_ar_cash_receipt_rev_stat(i),
        gt_ar_cash_receipt_rev_date(i),
        gt_payables_invoice_source(i),
        gt_acctd_amount_dr(i),
        gt_acctd_amount_cr(i),
        gt_rec_application_status(i),
        gt_vat_country_code(i),
        gt_invoice_identifier(i),
        gt_account_class(i),
        gt_latest_rec_flag(i),
        gt_jgzz_fiscal_code(i),
        gt_tax_reference(i),
        gt_pt_location(i),
        gt_invoice_report_type(i),
        gt_es_correction_year(i),
        gt_es_correction_period(i),
        gt_triangulation(i),
        gt_document_sub_type(i),
        gt_assessable_value(i),
        gt_property_location(i),
        gt_chk_vat_amount_paid(i),
        gt_import_document_number(i),
        gt_import_document_date(i),
        gt_prl_no(i),
        gt_property_rental(i),
        gt_rates_reference(i),
        gt_stair_num(i),
 	gt_floor_num(i),
        gt_door_num(i),
        gt_amount_applied(i),
        gt_actg_event_type_code(i),
        gt_actg_event_type_mng(i),
        gt_actg_event_number(i),
        gt_actg_event_status_flag(i),
        gt_actg_event_status_mng(i),
        gt_actg_category_code(i),
        gt_actg_category_mng(i),
        gt_accounting_date(i),
        gt_gl_transfer_flag(i),
        gt_actg_line_num(i),
        gt_actg_line_type_code(i),
        gt_actg_line_type_mng(i),
        gt_actg_line_description(i),
        gt_actg_stat_amt(i),
        gt_actg_party_id(i),
        gt_actg_party_site_id(i),
        gt_actg_party_type(i),
        gt_actg_event_id(i),
        gt_actg_header_id(i),
        gt_actg_line_id(i),
        gt_actg_source_id(i),
        gt_actg_source_table(i),
        gt_actg_line_ccid(i),
        gt_account_flexfield(i),
        gt_account_description(i),
        gt_period_name(i),
        gt_trx_arap_balancing_seg(i),
        gt_trx_arap_natural_account(i),
        gt_trx_taxable_balancing_seg(i),
        gt_trx_taxable_natural_acct(i),
        gt_trx_tax_balancing_seg(i),
        gt_trx_tax_natural_account(i),
	g_created_by ,
        g_creation_date ,
        g_last_updated_by,
        g_last_update_date,
        g_last_update_login,
        g_conc_request_id,
	g_prog_appl_id,
	g_conc_program_id,
	g_conc_login_id,
	1,
        gt_gl_date(i),
        gt_trx_ctrl_actg_flexfield(i),
        gt_tax_origin(i),
	DECODE(gt_offset_flag(i),'Y','OFFSET',
	       DECODE(gt_def_rec_settlement_opt_code(i),'DEFERRED','DEFERRED',
		      gt_reporting_code(i))),
	gt_def_rec_settlement_opt_code(i),
        gt_taxable_item_source_id(i));


     IF (g_level_procedure >= g_current_runtime_level ) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name ,
                       ' Record successfully inserted = ' ||to_char(l_count));
     END IF;

     IF g_debug_flag = 'Y' THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG,'Record successfully inserted = ' ||to_char(l_count));
       FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME||': ' ||l_api_name||'()-');
     END IF;

EXCEPTION
   WHEN OTHERS THEN
      --x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

      IF g_debug_flag = 'Y' THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
      END IF;

       IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
       END IF;
        --p_global_variables_rec.retcode := 2;
      RETURN;

END insert_tax_data;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |   CALL_TRL                                                                |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure calls the TRL engine for the given set of parameters.   |
 | 	 Argument Name           	Value to be passed		     |
 |       ----------------------   	------------------------	     |
 |       P_REPORTING_LEVEL               LEDGER or LEGAL ENTITY		     |
 |       P_REPORTING_CONTEXT             LEDGER_ID or LEGAL_ENTITY_ID	     |
 |       P_LEGAL_ENTITY_LEVEL            NULL -- LE Post Upg Changes         |
 |       P_LEGAL_ENTITY_ID               :P_LEGAL_ENTITY_ID		     |
 |       P_SUMMARY_LEVEL         	TRANSACTION DISTRIBUTION             |
 |       P_REGISTER_TYPE         	ALL                                  |
 |       P_PRODUCT               	:P_SOURCE			     |
 |       P_FIRST_PARTY_TAX_REG_NUM       : P_TAX_REGISTRATION_NUM            |
 |       P_TRX_DATE_LOW                  :L_TRX_DATE_LOW (Optional)          |
 |       P_TRX_DATE_HIGH                 :L_TRX_DATE_HIGH                    |
 |       P_GL_DATE_LOW                   :L_GL_DATE_LOW (Optional)           |
 |       P_GL_DATE_HIGH                  :L_GL_DATE_HIGH                     |
 |       P_TAX_INVOICE_DATE_LOW          :P_TAX_INVOICE_DATE_LOW (Optional)  |
 |       P_TAX_INVOICE_DATE_HIGH         :P_TAX_INVOICE_DATE_HIGH            |
 |       P_EXTRACT_ACCTED_TAX_LINES      NULL --xBuild3 changes              |
 |       P_ACCOUNTING_STATUS             :P_ACCTD_UNACCTD                    |
 |       P_INCLUDE_ACCOUNTING_SEGMENTS    Y                                  |
 |       P_LEGAL_REPORTING_STATUS        UNREPORTED ie 000000000000000       |
 |       P_REPORT_NAME                   JGVAT (To identify JE report call)  |
 |       P_ERRBUF                        :P_ERRBUF                           |
 |       P_RETCODE                       :P_RETCODE                          |
 |                                                                           |
 | Summary level : TRANSACTION DISTRIBUTION to have most granular information|
 | The report extracts should handle further grouping (if needed) based on   |
 | report specific requirements.					     |
 | Register Type : ALL. The extracts will filter based on TAX, INTERIM etc   |
 | based on report specific requirements.			             |
 | Report Name : Based on this parameter TRL engine conditionally calls JE   |
 | specific plug ins for additional processing like GDFs related.	     |
 |                                                                           |
 |    Called from JG_ZZ_VAT_SELECTION_PKG.Main                               |
 |                                                                           |
 | SCOPE - Private                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |  Date           Author          Description                               |
 |  ============  ==============  =================================          |
 |   23-Jan-2006   RBASKER               Initial  Version.                   |
 |   28-Mar-2006   RBASKER         Incorporated changes for XBuild4.         |
 |   28-Apr-2006   RBASKER         Bug: 5169118 - Fixed issues identified    |
 |                                 during Unit Testing.                      |
 |   01-Jun-2006   RBASKER         Bug: 5236973 - Call_TRL parameter is      |
 |  				   is fixed to pass include_acc_Seg parameter|
 |                                                                           |
 +===========================================================================*/

PROCEDURE call_TRL(
 p_global_variables_rec     IN OUT NOCOPY JG_ZZ_VAT_SELECTION_PKG.GLOBAL_VARIABLES_REC_TYPE,
 x_request_id 		    IN NUMBER
) IS

  l_api_name           CONSTANT VARCHAR2(30) := 'CALL_TRL';
  l_reporting_level		VARCHAR2(30);
  l_reporting_context           VARCHAR2(30);
  l_legal_entity_id             NUMBER;
  l_trn				VARCHAR2(30);
  l_accounting_status           VARCHAR2(30);
  l_tax_invoice_date_low 	DATE;
  l_include_acc_segments        VARCHAR2(1);
  l_tax_invoice_date_high       DATE;
  l_trx_date_low                DATE;
  l_trx_date_high               DATE;
  l_gl_date_low                 DATE;
  l_gl_date_high                DATE;
  l_country       	        xle_firstparty_information_v.country%TYPE;

--Bug6835573
  l_reported_status            VARCHAR2(20) := 'UNREPORTED';
  l_last_start_date            DATE;
  l_last_end_date              DATE;

  cursor last_report_date (pn_vat_rep_entity_id number) IS
  select glp.start_date
        ,glp.end_date
  from  jg_zz_vat_rep_entities legal
       ,jg_zz_vat_rep_entities acct
       ,gl_periods             glp
  where acct.entity_type_code='ACCOUNTING'
  and acct.vat_reporting_entity_id = pn_vat_rep_entity_id
  and acct.mapping_vat_rep_entity_id= legal.vat_reporting_entity_id
  and glp.period_set_name   = legal.tax_calendar_name
  and glp.period_name  =  acct.last_reported_period;
--Bug6835573

  BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',
					G_PKG_NAME||': '||l_api_name||'()+');
   END IF;

    IF g_debug_flag = 'Y' THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

  -- Check the Reporting Entity Level.
  IF  p_global_variables_rec.REPORTING_ENTITY_LEVEL = 'LEDGER' or
       p_global_variables_rec.REPORTING_ENTITY_LEVEL = 'BSV' THEN
      -- Ledger or BSV
     l_reporting_level   := '1000';
     l_reporting_context := p_global_variables_rec.LEDGER;
     l_legal_entity_id   := p_global_variables_rec.LEGAL_ENTITY_ID; -- Company_Name
     l_trn               := NULL;

--Bug6835573
     OPEN last_report_date(p_global_variables_rec.vat_reporting_entity_id);
     FETCH last_report_date INTO l_last_start_date,l_last_end_date;
     CLOSE last_report_date;

     FND_FILE.put_line(FND_FILE.log,'Last_Reported_Start_Date '|| l_last_start_date);
     IF p_global_variables_rec.TAX_INVOICE_DATE_HIGH <= l_last_end_date THEN
        l_reported_status := NULL;
     END IF;
--Bug6835573

  ELSE
     -- LE and TRN
     l_reporting_level := '2000';
     l_reporting_context := p_global_variables_rec.LEGAL_ENTITY_ID;
     l_legal_entity_id := NULL; -- Company_Name
     l_trn := p_global_variables_rec.TAX_REGISTRATION_NUMBER;
  END IF;

  IF p_global_variables_rec.ACCTD_UNACCTD = 'UNACCOUNTED' THEN
     l_accounting_status := p_global_variables_rec.ACCTD_UNACCTD ;
  ELSE
     l_accounting_status    := p_global_variables_rec.ACCTD_UNACCTD ;
     l_include_acc_segments := 'Y';
  END IF;

  /*=========================================================================+
   | Based on driving date for VAT Reporting Entity call TRL with different  |
   | set date range parameters.                                              |
   +==========================================================================*/
      IF substr(p_global_variables_rec.DRIVING_DATE_CODE,
              instr(p_global_variables_rec.DRIVING_DATE_CODE,'GL',1,1),2) = 'GL' THEN
         l_gl_date_low  :=   p_global_variables_rec.TAX_INVOICE_DATE_LOW;
         l_gl_date_high :=   p_global_variables_rec.TAX_INVOICE_DATE_HIGH;
      END IF;

      IF substr(p_global_variables_rec.DRIVING_DATE_CODE,
              instr(p_global_variables_rec.DRIVING_DATE_CODE,'TRX',1,1),3) = 'TRX' THEN
         l_trx_date_low  :=   p_global_variables_rec.TAX_INVOICE_DATE_LOW;
         l_trx_date_high :=   p_global_variables_rec.TAX_INVOICE_DATE_HIGH;
      END IF;

      IF substr(p_global_variables_rec.DRIVING_DATE_CODE,
              instr(p_global_variables_rec.DRIVING_DATE_CODE,'TID',1,1),3) = 'TID' THEN
         l_tax_invoice_date_low  :=   p_global_variables_rec.TAX_INVOICE_DATE_LOW;
         l_tax_invoice_date_high :=   p_global_variables_rec.TAX_INVOICE_DATE_HIGH;
      END IF;


   /*=========================================================================+
   | Corrections Approach: Correction transactions will be considered only    |
   | when no previous OPEN period exists. (OPEN =>  Prev period is not FINAL  |
   | reported yet).					                      |
   | Start date should be passed as null if corrected transactions need to be |
   | considered. Otherwise, TRL would always return unreported transactions in|
   | in the given date range.						      |
   +==========================================================================*/
  IF NOT is_prev_period_open (p_global_variables_rec) THEN
     -- Correction transactions not to be considered.
     -- l_tax_invoice_date_low := p_global_variables_rec.TAX_INVOICE_DATE_LOW;
     -- ELSE
    l_gl_date_low          := NULL;
    l_trx_date_low         := NULL;
    l_tax_invoice_date_low := NULL;

  END IF;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN

     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
                  'P_REPORTING_LEVEL = ' || l_reporting_level );
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
                'P_REPORTING_CONTEXT  = ' || l_reporting_context );
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
                'P_LEGAL_ENTITY_ID = '|| l_legal_entity_id);
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
                  ' P_PRODUCT  = ' || p_global_variables_rec.SOURCE );
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
                   ' P_FIRST_PARTY_TAX_REG_NUM = ' || l_trn );
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
                   ' P_FIRST_PARTY_TAX_REG_NUM = ' || l_trn );
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
                    ' P_TRX_DATE_LOW = '|| l_trx_date_low );
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
                    ' P_TRX_DATE_HIGH = '|| l_trx_date_high );
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
                    ' P_GL_DATE_LOW = '|| l_gl_date_low );
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
                    ' P_GL_DATE_HIGH = '|| l_gl_date_high );
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
                    ' P_TAX_INVOICE_DATE_LOW = '|| l_tax_invoice_date_low );
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
                    ' P_TAX_INVOICE_DATE_HIGH = '|| l_tax_invoice_date_high );
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
                    ' P_ACCOUNTING_STATUS = '|| l_accounting_status );
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
                    ' P_INCLUDE_ACCOUNTING_SEGMENTS = '|| l_include_acc_segments );
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
                    ' P_TAX_REGIME_CODE = '||  p_global_variables_rec.TAX_REGIME_CODE);
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
                    ' P_REPORTED_STATUS = '||  l_reported_status); --Bug6835573


   END IF;

   IF g_debug_flag = 'Y'  THEN

    fnd_file.put_line(fnd_file.log,
                'Following parameters are passed to TRL...' );
     fnd_file.put_line(fnd_file.log,
                'P_REPORTING_LEVEL = ' || l_reporting_level );
     fnd_file.put_line(fnd_file.log,
                'P_REPORTING_CONTEXT  = ' || l_reporting_context );
     fnd_file.put_line(fnd_file.log,
                'P_LEGAL_ENTITY_ID = '|| l_legal_entity_id);
     fnd_file.put_line(fnd_file.log,
                  ' P_PRODUCT  = ' || p_global_variables_rec.SOURCE );
     fnd_file.put_line(fnd_file.log,
                   ' P_FIRST_PARTY_TAX_REG_NUM = ' || l_trn );
      fnd_file.put_line(fnd_file.log,
                    ' P_TRX_DATE_LOW = '|| l_trx_date_low );
     fnd_file.put_line(fnd_file.log,
                    ' P_TRX_DATE_HIGH = '|| l_trx_date_high);
     fnd_file.put_line(fnd_file.log,
                    ' P_GL_DATE_LOW = '|| l_gl_date_low );
     fnd_file.put_line(fnd_file.log,
                    ' P_GL_DATE_HIGH = '|| l_gl_date_high);
     fnd_file.put_line(fnd_file.log,
                    ' P_TAX_INVOICE_DATE_LOW = '|| l_tax_invoice_date_low );
     fnd_file.put_line(fnd_file.log,
                    ' P_TAX_INVOICE_DATE_HIGH = '|| l_tax_invoice_date_high);
     fnd_file.put_line(fnd_file.log,
                    ' P_ACCOUNTING_STATUS = '|| l_accounting_status );
     fnd_file.put_line(fnd_file.log,
                    ' P_INCLUDE_ACCOUNTING_SEGMENTS = '|| l_include_acc_segments );
     fnd_file.put_line(fnd_file.log,
                    ' P_TAX_REGIME_CODE = '||  p_global_variables_rec.TAX_REGIME_CODE);
     fnd_file.put_line(fnd_file.log,
			'P_GL_OR_TRX_DATE_FILTER = '||p_global_variables_rec.gl_or_trx_date_filter);
     fnd_file.put_line(fnd_file.log,
			'P_REPORTED_STATUS = '||l_reported_status);

   END IF;


	zx_extract_pkg.populate_tax_data
	(
	  P_REPORTING_LEVEL           => l_reporting_level,
	  P_REPORTING_CONTEXT         => l_reporting_context,
	  P_LEGAL_ENTITY_ID           => l_legal_entity_id ,
	  P_SUMMARY_LEVEL             => 'TRANSACTION_DISTRIBUTION',
	  P_REGISTER_TYPE             => 'ALL',
	  P_PRODUCT                   => p_global_variables_rec.SOURCE ,
	  P_MATRIX_REPORT             => 'N',
          P_INCLUDE_AP_STD_TRX_CLASS  => 'Y',
          P_INCLUDE_AP_DM_TRX_CLASS   => 'Y',
          P_INCLUDE_AP_CM_TRX_CLASS   => 'Y',
          P_INCLUDE_AP_PREP_TRX_CLASS => 'Y',
          P_INCLUDE_AP_MIX_TRX_CLASS  => 'Y',
          P_INCLUDE_AP_EXP_TRX_CLASS  => 'Y',
          P_INCLUDE_AP_INT_TRX_CLASS  => 'Y',
          P_INCLUDE_AR_INV_TRX_CLASS  => 'Y',
          P_INCLUDE_AR_APPL_TRX_CLASS => 'Y',
          P_INCLUDE_AR_ADJ_TRX_CLASS  => 'Y',
          P_INCLUDE_AR_MISC_TRX_CLASS => 'Y',
          P_INCLUDE_AR_BR_TRX_CLASS   => 'Y',
          P_INCLUDE_GL_MANUAL_LINES   => 'Y',
	  P_FIRST_PARTY_TAX_REG_NUM   => l_trn ,
          P_TRX_DATE_LOW              => l_trx_date_low,
          P_TRX_DATE_HIGH             => l_trx_date_high,
          P_GL_DATE_LOW               => l_gl_date_low,
          P_GL_DATE_HIGH              => l_gl_date_high,
          P_TAX_INVOICE_DATE_LOW      => l_tax_invoice_date_low ,
          P_TAX_INVOICE_DATE_HIGH     => l_tax_invoice_date_high ,
	  P_TAX_REGIME_CODE           => p_global_variables_rec.TAX_REGIME_CODE,
	  P_POSTING_STATUS	       => NULL  ,
          P_REPORTED_STATUS             => l_reported_status,  --Bug6835573
          P_ACCOUNTING_STATUS           => l_accounting_status,
	  P_INCLUDE_ACCOUNTING_SEGMENTS => l_include_acc_segments,
          P_REPORT_NAME                 => 'JGVAT' ,
	  P_REQUEST_ID                  => x_request_id      ,
	  P_ERRBUF                      => p_global_variables_rec.ERRBUF,
	  P_RETCODE                     => p_global_variables_rec.RETCODE,
	  P_GL_OR_TRX_DATE_FILTER       => p_global_variables_rec.gl_or_trx_date_filter);

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
                 ' RETURN_STATUS = ' || p_global_variables_rec.RETCODE);
   END IF;

   -- Filtering based on Balancing Segment Value.
   IF  p_global_variables_rec.REPORTING_ENTITY_LEVEL = 'BSV' THEN

      DELETE from ZX_REP_TRX_JX_EXT_T EXT
      WHERE EXT.request_id = x_request_id
        AND NOT EXISTS
             (SELECT 1
              FROM    ZX_REP_ACTG_EXT_T       ACT,
		      ZX_REP_TRX_DETAIL_T     DET
	       WHERE DET.request_id = x_request_id
	        AND  EXT.detail_tax_line_id = DET.detail_tax_line_id
                AND  ACT.detail_tax_line_id = DET.detail_tax_line_id
                AND  ACT.trx_arap_balancing_segment = p_global_variables_rec.BSV
                  );

       DELETE from ZX_REP_TRX_DETAIL_T DET
       WHERE DET.request_id = x_request_id
         AND NOT EXISTS
          (SELECT 1
             FROM   ZX_REP_ACTG_EXT_T     ACT
             WHERE  DET.request_id =  x_request_id
               AND   ACT.detail_tax_line_id = DET.detail_tax_line_id
               AND   ACT.trx_arap_balancing_segment = p_global_variables_rec.BSV
               );

        DELETE from ZX_REP_ACTG_EXT_T       ACT
        WHERE   ACT.request_id = x_request_id
          AND   ACT.trx_arap_balancing_segment <> p_global_variables_rec.BSV;

      IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
                 ' Records filtered based on bsv');
      END IF;


   END IF;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',
		G_PKG_NAME||': ' ||l_api_name||'()-');
   END IF;

    IF g_debug_flag = 'Y' THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME||': ' ||l_api_name||'()-');
    END IF;

   EXCEPTION
     WHEN OTHERS THEN
      -- x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

      IF g_debug_flag = 'Y' THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
      END IF;

       IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
       END IF;
      RETURN;
  END call_TRL;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |   control_intersecting_domains                                            |
 | DESCRIPTION                                                               |
 |    This procedure checks whether the current selection run results in     |
 |    intersecting data with a previous selection run(s). If exists, the     |
 |    intersecting data is populated into the jg_zz_vat_trx_gt table.        |
 |    If the intersecting data is a transaction that has been final reported |
 |    we error the Selection process.                                        |
 |    For records that have not been final reported - we allow the subsequent|
 |    run to replace the data.                                               |
 |                                                                           |
 | SCOPE - Private                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |  Date           Author          Description                               |
 |  ============  ==============  =================================          |
 |   29-Mar-2006   RBASKER               Initial  Version.                   |
 |   28-Jun-2006   RBASKER         For GL transactions internal_org_id will  |
 |  			           be NULL, so added NVL logic.              |
 |   03-AUG-2006   RJREDDY         Added x_intersect_domain_err parameter    |
 |                                 for holding the error message             |
 |                                                                           |
 +===========================================================================*/
 PROCEDURE control_intersecting_domains(
 p_global_variables_rec     IN OUT NOCOPY JG_ZZ_VAT_SELECTION_PKG.GLOBAL_VARIABLES_REC_TYPE,
 x_request_id               IN NUMBER,
 x_intersect_domain_err     OUT NOCOPY VARCHAR2
 ) IS

  l_api_name           CONSTANT VARCHAR2(30) := 'CONTROL_INTERSECTING_DOMAINS';
  l_count	       NUMBER;
  l_return_status           VARCHAR2(1);
  l_return_message          VARCHAR2(2000);

 BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',
		G_PKG_NAME||': '||l_api_name||'()+');
   END IF;

    IF g_debug_flag = 'Y' THEN
     FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME||': '||l_api_name||'()+');
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_global_variables_rec.last_rep_period_start_date :'||p_global_variables_rec.last_rep_period_start_date);
 	 FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_global_variables_rec.tax_invoice_date_low       :'||p_global_variables_rec.tax_invoice_date_low);
    END IF;

   -- populate temp table with the intersecting data.
    IF p_global_variables_rec.tax_invoice_date_high > p_global_variables_rec.LAST_REP_PERIOD_END_DATE THEN

 	    -- Period above than last reported period.
 	    INSERT INTO JG_ZZ_VAT_TRX_GT
 	    (JG_INFO_N2,
 	     JG_INFO_N3,
 	     JG_INFO_V2,
 	     JG_INFO_V3,
 	     JG_INFO_N4,
 	     JG_INFO_N5,
 	     JG_INFO_N6,
 	     JG_INFO_N1,
 	     JG_INFO_V4,
 	     JG_INFO_D1,
 	     JG_INFO_N7,
 	     JG_INFO_N9,
 	     JG_INFO_N8,
 	     JG_INFO_V1)
 	   SELECT  jgvt.internal_organization_id,
 	         jgvt.application_id ,
 	         jgvt.entity_code,
 	         jgvt.event_class_code,
 	         jgvt.trx_id,
 	         jgvt.trx_line_id,
 	         jgvt.tax_line_id ,
 	         jgvt.vat_transaction_id,
 	         jgvt.trx_number,
 	         jgvt.tax_invoice_date,
 	         jgvt.reporting_status_id ,
 	         jgvt.final_reporting_id,
 	         jgrs.vat_reporting_entity_id,
 	         jgre.entity_identifier
 	  FROM           JG_ZZ_VAT_TRX_DETAILS   JGVT,
 	                 JG_ZZ_VAT_REP_STATUS JGRS,
 	                 JG_ZZ_VAT_REP_ENTITIES JGRE
 	  WHERE  JGVT.reporting_status_id = JGRS.reporting_status_id
 	  AND    JGRS.vat_reporting_entity_id = JGRE.vat_reporting_entity_id
 	  AND    (JGRS.period_end_date > p_global_variables_rec.LAST_REP_PERIOD_END_DATE
 	          OR p_global_variables_rec.LAST_REP_PERIOD_END_DATE IS NULL)
 	  AND   (nvl(JGVT.internal_organization_id,-99),
 	        JGVT.application_id ,
 	        JGVT.entity_code,
 	        JGVT.event_class_code,
 	        JGVT.trx_id,
 	        JGVT.trx_line_id,
 	        JGVT.tax_line_id) IN  (SELECT nvl(DET.internal_organization_id,99),
 	                                 DET.application_id ,
 	                                 DET.entity_code,
 	                                 DET.event_class_code,
 	                                 DET.trx_id,
 	                                 DET.trx_line_id,
 	                                 DET.tax_line_id
 	                         FROM
 	                                 ZX_REP_CONTEXT_T        CON,
 	                                 ZX_REP_TRX_DETAIL_T     DET
 	                         WHERE   CON.request_id = x_request_id
 	                            AND DET.request_id = CON.request_id
 	                           AND DET.rep_context_id = CON.rep_context_id
 	                                 );
 	    ELSE
 	    -- Period before or equal to  last reported period.
   INSERT INTO JG_ZZ_VAT_TRX_GT
   (JG_INFO_N2,
    JG_INFO_N3,
    JG_INFO_V2,
    JG_INFO_V3,
    JG_INFO_N4,
    JG_INFO_N5,
    JG_INFO_N6,
    JG_INFO_N1,
    JG_INFO_V4,
    JG_INFO_D1,
    JG_INFO_N7,
    JG_INFO_N9,
    JG_INFO_N8,
    JG_INFO_V1)
  SELECT  jgvt.internal_organization_id,
        jgvt.application_id ,
        jgvt.entity_code,
        jgvt.event_class_code,
        jgvt.trx_id,
        jgvt.trx_line_id,
        jgvt.tax_line_id ,
        jgvt.vat_transaction_id,
        jgvt.trx_number,
        jgvt.tax_invoice_date,
        jgvt.reporting_status_id ,
        jgvt.final_reporting_id,
        jgrs.vat_reporting_entity_id,
        jgre.entity_identifier
 FROM           JG_ZZ_VAT_TRX_DETAILS   JGVT,
                JG_ZZ_VAT_REP_STATUS JGRS,
                JG_ZZ_VAT_REP_ENTITIES JGRE
 WHERE  JGVT.reporting_status_id = JGRS.reporting_status_id
 AND    JGRS.vat_reporting_entity_id = JGRE.vat_reporting_entity_id
 AND   (nvl(JGVT.internal_organization_id,-99),
       JGVT.application_id ,
       JGVT.entity_code,
       JGVT.event_class_code,
       JGVT.trx_id,
       JGVT.trx_line_id,
       JGVT.tax_line_id) IN  (SELECT nvl(DET.internal_organization_id,99),
       				DET.application_id ,
       				DET.entity_code,
       				DET.event_class_code,
       				DET.trx_id,
       				DET.trx_line_id,
       				DET.tax_line_id
			FROM
               			ZX_REP_CONTEXT_T        CON,
               			ZX_REP_TRX_DETAIL_T     DET
       			WHERE   CON.request_id = x_request_id
			   AND DET.request_id = CON.request_id
			  AND DET.rep_context_id = CON.rep_context_id
       		                );

   END IF;

   SELECT count(*) INTO l_count FROM JG_ZZ_VAT_TRX_GT;

   -- purge_report_finalrep
   IF l_count > 0 THEN
	purge_report_finalrep(
	 xv_return_status           => l_return_status,
         xv_return_message          => l_return_message
        );
   END IF;

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
         x_intersect_domain_err := l_return_message;
         p_global_variables_rec.retcode := 2;
         RETURN;
     END IF;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
                 ' RETURN_STATUS = ' || p_global_variables_rec.RETCODE);
   END IF;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END'
		,G_PKG_NAME||': ' ||l_api_name||'()-');
   END IF;

   IF g_debug_flag = 'Y' THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME||': ' ||l_api_name||'()-');
    END IF;

   EXCEPTION
     WHEN OTHERS THEN
      -- x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

       IF g_debug_flag = 'Y' THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
       END IF;

       IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
       END IF;
	 p_global_variables_rec.retcode := 2;
      RETURN;
END control_intersecting_domains;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |   purge_report_finalrep()                                                 |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure                                                         |
 |     (1) Checks whether records are finally reported in GTT.               |
 |     (2) Fetches the transaction details which are finally reported.       |
 |     (3) If atleast one transaction is finally reported, then Print and    |
 |         and exit.                                                         |
 |     (4) None of the transactions in GTT are finally reported =>           |
 |         Delete from box_allocs, box_errors, trx_details                   |
 |                                                                           |
 | SCOPE - Private                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |  Date           Author          Description                               |
 |  ============  ==============  =================================          |
 |   29-Mar-2006   RPOKKULA               Initial  Version.                  |
 |   28-Jun-2006   RBASKER        Changed forall loop for bulk operation.    |
 |   04-Aug-2006   RJREDDY        Added code for getting the location for    |
 |                                the log file, into lv_utl_location variable|
 |                                                                           |
 +===========================================================================*/

PROCEDURE purge_report_finalrep (
            xv_return_status   out   nocopy      varchar2,
            xv_return_message  out   nocopy      varchar2
            )
IS

    l_api_name                CONSTANT VARCHAR2(30) := 'PURGE_REPORT_FINALREP';
    l_return_status           VARCHAR2(1);
    l_return_message          VARCHAR2(2000);
    l_msg_count               NUMBER;
    l_msg		      VARCHAR2(2000);

    /*
    || Fetches the number of records which are finally reported from GTT
    */
    CURSOR c_finalrep_exist IS
    SELECT count(1)
    FROM   jg_zz_vat_trx_gt
    WHERE   jg_info_n9 is not null ; /*  final_reporting_id    */

    /*
    || Fetches the invoice details which are finally reported
    */
    CURSOR c_get_finalrep  IS
    SELECT  jg_info_v1 ,           /*  reporting_identifier       */
        jg_info_n1 ,           /*  vat_transaction_id         */
        jg_info_n2 ,           /*  internal_organization_id   */
        jg_info_n3 ,           /*  application_id             */
        jg_info_v2 ,           /*  entity_code                */
        jg_info_v3 ,           /*  event_class_code           */
        jg_info_n4 ,           /*  trx_id                     */
        jg_info_n5 ,           /*  trx_line_id                */
        jg_info_n6 ,           /*  tax_line_id                */
        jg_info_v4 ,           /*  trx_number                 */
        jg_info_d1 ,           /*  tax_invoice_date           */
        jg_info_n7 ,           /*  reporting_status_id        */
        jg_info_n8 ,           /*  vat_reporting_entity_id    */
        jg_info_n9             /*  final_reporting_id         */
   FROM jg_zz_vat_trx_gt
   WHERE jg_info_n9 is not null;  /*  final_reporting_id       */


   CURSOR c_get_finalrep_trx_for_upd  IS
    SELECT
        p.jg_info_n3 ,           /*  application_id             */
        p.jg_info_v2 ,           /*  entity_code                */
        p.jg_info_v3 ,           /*  event_class_code           */
        p.jg_info_n4 ,           /*  trx_id                     */
        p.jg_info_n5 ,           /*  trx_line_id                */
        p.jg_info_n2 ,           /*  internal_organization_id   */
        p.jg_info_n6             /*  tax_line_id                */
   FROM jg_zz_vat_trx_gt p
   WHERE p.jg_info_n9 is not null  /*  final_reporting_id         */
    AND  p.jg_info_n6  not in ( select tax_line_id
                                from zx_lines
                                where cancel_flag = 'Y'
                                and trx_id = p.jg_info_n4
                                and tax_line_id = p.jg_info_n6 );

   CURSOR c_vat_transaction_id IS
   SELECT jg_info_n1              /*  vat_transaction_id         */
   FROM jg_zz_vat_trx_gt
   WHERE jg_info_n9 is null;      /*  final_reporting_id         */

   CURSOR c_get_outfile IS
   select 'jg_zz_vat' || to_char(sysdate,'ddmmyyyy_hhmiss') from dual ;

   TYPE IdTab IS TABLE OF jg_zz_vat_trx_gt.jg_info_n1%TYPE;
   IdList      IdTab ;

   l_count             NUMBER DEFAULT 0 ;
   lv_filename         VARCHAR2(30);

   lv_utl_location     VARCHAR2(1000)      ;
   l_trx_count         NUMBER;

   ltn_application_id                  zx_extract_pkg.application_id_tbl;
   ltv_entity_code                     zx_extract_pkg.entity_code_tbl;
   ltv_event_class_code                zx_extract_pkg.event_class_code_tbl;
   ltn_trx_id                          zx_extract_pkg.trx_id_tbl;
   ltn_trx_line_id                     zx_extract_pkg.trx_line_id_tbl;
   ltn_internal_organization_id        zx_extract_pkg.internal_organization_id_tbl;
   ltn_tax_line_id                     zx_extract_pkg.tax_line_id_tbl;

     BEGIN

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',
                                        G_PKG_NAME||': '||l_api_name||'()+');
   END IF;

    IF g_debug_flag = 'Y' THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

   OPEN  c_finalrep_exist  ;
   FETCH c_finalrep_exist INTO l_count ;
   CLOSE c_finalrep_exist ;

   IF l_count > 0 then
   /* If atleast one transaction is finally reported, then Print and exit */


      OPEN  c_get_outfile ;
      FETCH c_get_outfile into lv_filename ;
      CLOSE c_get_outfile ;

      -- Get the Location for the Log file
      SELECT decode(substr(value,1,instr(value,',') -1),
             null ,value ,
             substr (value,1,instr(value,',') -1))  INTO  lv_utl_location
      FROM   v$parameter
      WHERE  name = 'utl_file_dir';


      log_file (lv_filename , '============================================================================================================================================================================================================================');
log_file(lv_filename,'REPORTING_IDENTIFIER VAT_TRANSACTION_ID ORGANIZATION_ID APPLICATION_ID    ENTITY_CODE EVENT_CLASS_CODE         TRX_ID   TRX_LINE_ID  TAX_LINE_ID TRX_NUMBER TAX_INVOICE_DATE REPORTING_STATUS_ID VAT_REP_ENTITY_ID FINAL_REPORTING_ID');
      log_file (lv_filename , '============================================================================================================================================================================================================================');

    FOR c_rec in c_get_finalrep
     LOOP

     log_file (lv_filename , lpad(c_rec.JG_INFO_V1,20)  ||
                             lpad(c_rec.JG_INFO_N1,19) ||
                             lpad(c_rec.JG_INFO_N2,16) ||
                             lpad(c_rec.JG_INFO_N3,15) ||
                             lpad(c_rec.JG_INFO_V2,15) ||
                             lpad(c_rec.JG_INFO_V3,17) ||
                             lpad(c_rec.JG_INFO_N4,15) ||
                             lpad(c_rec.JG_INFO_N5,14) ||
                             lpad(c_rec.JG_INFO_N6,13) ||
                             lpad(c_rec.JG_INFO_V4,11) ||
                             lpad(c_rec.JG_INFO_D1,17) ||
                             lpad(c_rec.JG_INFO_N7,20) ||
                             lpad(c_rec.JG_INFO_N8,18) ||
                             lpad(c_rec.JG_INFO_N9,19)
              );

      END LOOP ;

     log_file (lv_filename , '=============================================================================================================================================================================================================================');

    l_msg := l_count || ' Transactions are Finally Reported' ;

      IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     	 FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name, l_msg);
      END IF;

    FND_MESSAGE.SET_NAME('JG','JG_ZZ_VAT_TRX_OVERLAPPING');
    FND_MESSAGE.SET_TOKEN('LOG_FILE',     lv_filename );
    FND_MESSAGE.SET_TOKEN('LOG_LOCATION', lv_utl_location );
    xv_return_message := FND_MESSAGE.GET;
    -- xv_return_status  := fnd_api.g_ret_sts_error;

   IF g_debug_flag = 'Y' THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG,xv_return_message);
   END IF;

    OPEN  c_get_finalrep_trx_for_upd;

    FETCH c_get_finalrep_trx_for_upd BULK COLLECT INTO
      ltn_application_id               ,
      ltv_entity_code                  ,
      ltv_event_class_code             ,
      ltn_trx_id                       ,
      ltn_trx_line_id                  ,
      ltn_internal_organization_id     ,
      ltn_tax_line_id                  ;

    CLOSE c_get_finalrep_trx_for_upd;

     /* Call the eBtax API to update transactions in eBtax as finally reported */
    zx_extract_pkg.zx_upd_legal_reporting_status
    (
      p_api_version                  => jg_zz_vat_rep_final_reporting.gn_api_version             ,
      p_init_msg_list                => fnd_api.g_false                                          ,
      p_commit                       => fnd_api.g_false                                          ,
      p_validation_level             => null                                                     ,
      p_application_id_tbl           => ltn_application_id                                       ,
      p_entity_code_tbl              => ltv_entity_code                                          ,
      p_event_class_code_tbl         => ltv_event_class_code                                     ,
      p_trx_id_tbl                   => ltn_trx_id                                               ,
      p_trx_line_id_tbl              => ltn_trx_line_id                                          ,
      p_internal_organization_id_tbl => ltn_internal_organization_id                             ,
      p_tax_line_id_tbl              => ltn_tax_line_id                                          ,
      p_legal_reporting_status_val   => jg_zz_vat_rep_final_reporting.gv_legal_reporting_status  ,
      x_return_status                => l_return_status                                         ,
      x_msg_count                    => l_msg_count                                             ,
      x_msg_data                     => l_return_message
    );

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
       xv_return_status := l_return_status;
       xv_return_message := l_return_message;
       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Unexpected error occurred in the
        procedure zx_extract_pkg.zx_upd_legal_reporting_status :'||l_return_message);
    END IF;

   END IF; --IF l_count > 0 then

   /* None of the transactions in GTT are finally reported
     => Delete from box_allocs, box_errors, trx_details */

  IF g_debug_flag = 'Y' THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG, 'None of the transactions in GTT are finally reported');
  END IF;


  OPEN c_vat_transaction_id ;
  FETCH c_vat_transaction_id BULK COLLECT INTO IdList ;
  CLOSE c_vat_transaction_id ;

  l_trx_count := IdList.COUNT;

    IF l_trx_count > 0 THEN

    FORALL i in 1..l_trx_count
        delete from jg_zz_vat_box_allocs
        where vat_transaction_id = IdList(i) ;

    FORALL i in 1..l_trx_count
        delete from jg_zz_vat_box_errors
        where vat_transaction_id = IdList(i) ;

    FORALL i in 1..l_trx_count
        delete from jg_zz_vat_trx_details
        where vat_transaction_id = IdList(i) ;

    END IF ; --IF l_trx_count > 0 THEN

    xv_return_status  := fnd_api.g_ret_sts_success;
    xv_return_message := 'None of the transactions are finally reported';
      IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name, xv_return_message);
      END IF;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',
                G_PKG_NAME||': ' || l_api_name||'()-');
    END IF;

   IF g_debug_flag = 'Y' THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME||': ' ||l_api_name||'()-');
   END IF;


EXCEPTION
  WHEN OTHERS THEN
    xv_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;
    xv_return_message := 'Unexpected error occurred in the
        procedure PURGE_REPORT_FINALREP:' || SQLCODE || ' ' ||
        SUBSTR(SQLERRM,1,80) ;
    IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
    END IF;
     g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

     IF g_debug_flag = 'Y' THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
     END IF;

END purge_report_finalrep ;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |   log_file()                                                              |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure produces a log file that contains the details of those  |
 |    transactions that are final reported in previous selection runs.       |
 |                                                                           |
 | SCOPE - Private                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |  Date           Author          Description                               |
 |  ============  ==============  =================================          |
 |   29-Mar-2006   RPOKKULA               Initial  Version.                  |
 |                                                                           |
 +===========================================================================*/

PROCEDURE log_file (
            filename      IN VARCHAR2,
            text_to_write IN  VARCHAR2 )
IS

  l_api_name       CONSTANT VARCHAR2(30) := 'LOG_FILE';
  lv_utl_location  VARCHAR2(1000);
  v_myfilehandle   UTL_FILE.FILE_TYPE;

BEGIN

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',
                                        G_PKG_NAME||': '||l_api_name||'()+');
   END IF;


  SELECT decode(substr (value,1,instr(value,',') -1) ,
                 null ,value ,
                 substr (value,1,instr(value,',') -1))  INTO  lv_utl_location
  FROM   v$parameter
  WHERE  name = 'utl_file_dir';

  v_myfilehandle := utl_file.fopen(lv_utl_location,filename,'A');
  utl_file.put_line(v_myfilehandle,text_to_write);
  utl_file.fclose(v_myfilehandle);

    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',
                G_PKG_NAME||': ' || l_api_name||'()-');
    END IF;

    IF g_debug_flag = 'Y' THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME||': ' ||l_api_name||'()-');
    END IF;


EXCEPTION
  WHEN OTHERS THEN
     IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
     END IF;
     g_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

     IF g_debug_flag = 'Y' THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
     END IF;
     RETURN;
END log_file ;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |   tax_date_maintenance_program()                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure is called for ECE countries, to update the              |
 |    tax_invoice_date to payment clearing date for the invoices which has   |
 |    not been printed on a final register.                                  |
 |    Note: In R11i, this routine was called with ECE VAT registers to       |
 |    update Tax Date (GDF - GA1 column).                                    |
 |                                                                           |
 | SCOPE - Private                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |  Date           Author          Description                               |
 |  ============  ==============  =================================          |
 |   31-Jul-2006   RJREDDY                Initial  Version.                  |
 |   14-Sep-2006   RBASKER        Bug 5517700 - Added two more statuses      |
 |                                to support unaccounted status              |
 |                                                                           |
 +===========================================================================*/
 PROCEDURE tax_date_maintenance_program
           ( p_legal_entity_id  IN  JG_ZZ_VAT_REP_ENTITIES.legal_entity_id%TYPE,
             p_ledger_id        IN  JG_ZZ_VAT_REP_ENTITIES.ledger_id%TYPE,
             p_end_date         IN  GL_PERIODS.end_date%TYPE,
             p_source           IN  JG_ZZ_VAT_REP_STATUS.source%TYPE,
             p_debug_flag       IN  VARCHAR2,
             x_return_status    OUT NOCOPY VARCHAR2,
             x_errbuf           OUT NOCOPY VARCHAR2
            )
IS
  l_api_name         CONSTANT VARCHAR2(30) := 'TAX_DATE_MAINTENANCE_PROGRAM';
  l_prim_acct_method VARCHAR2(15);
  l_num              NUMBER := 0;
  l_ledger_id        GL_LEDGER_LE_V.ledger_id%TYPE;

-- Cursor to fecth all the invoices (Prepayments, Small Business Supplier
-- Invoices ) for which the tax date is not present and not
-- finally reported
  CURSOR c_inv_null_tax_date
  IS
  SELECT inv.invoice_id,
         inv.invoice_num,
         inv.set_of_books_id,
         inv.tax_invoice_recording_date,
         inv.invoice_type_lookup_code,
         checks.cleared_date,
         pv.small_business_flag
  FROM   ap_invoices_all  inv
        ,ap_checks_all   checks
        ,ap_invoice_payments_all  pay
        ,po_vendors  pv
	,zx_lines_det_factors zdf
  WHERE inv.set_of_books_id  =  DECODE(p_legal_entity_id, NULL, p_ledger_id,
                                                        inv.set_of_books_id)
  AND   inv.legal_entity_id  =  DECODE(p_ledger_id, NULL, p_legal_entity_id,
                                                        inv.legal_entity_id)
  AND   pay.set_of_books_id = inv.set_of_books_id
  AND   checks.legal_entity_id = inv.legal_entity_id
  AND   inv.invoice_id  =  pay.invoice_id
  AND   inv.vendor_id  =  pv.vendor_id
  AND   zdf.application_id  =  200
  AND   zdf.trx_id  =  inv.invoice_id
  AND   checks.check_id  =  pay.check_id
  AND   trunc(checks.cleared_date)  <  trunc(p_end_date)
  AND   checks.status_lookup_code IN ('CLEARED', 'RECONCILED',
               'CLEARED BUT UNACCOUNTED', 'RECONCILED UNACCOUNTED')
  AND   NOT EXISTS ( SELECT 1
                     FROM  jg_zz_vat_trx_details vtd
                     WHERE vtd.application_id  =  200
                     AND vtd.trx_id  =  inv.invoice_id
                     AND vtd.entity_code  =  zdf.entity_code
                     AND vtd.event_class_code  =  zdf.event_class_code
                     AND vtd.final_reporting_id IS NOT NULL
                );

  -- Get the primary Accounting method for payables
  CURSOR c_primary_acct_method (l_ledger_id  gl_ledgers.ledger_id%TYPE) IS
   SELECT accounting_method_option
   FROM ap_system_parameters_all
   WHERE set_of_books_id = l_ledger_id;

  -- Get the Receivables Invoices
    CURSOR c_cust_trx
    IS
                SELECT  trx.customer_trx_id,
                        MAX(rpt.apply_date) apply_date,
                        zdf.tax_invoice_date,
                        zdf.entity_code,
                        zdf.event_class_code
                FROM    ra_customer_trx_all              trx,
                        ar_receivable_applications_all   rpt,
                        zx_lines_det_factors             zdf
                WHERE trx.customer_trx_id  =  rpt.applied_customer_trx_id
                AND zdf.application_id  =  222
                AND zdf.trx_id  =  trx.customer_trx_id
                AND trx.set_of_books_id  =  DECODE(p_legal_entity_id, NULL,
                                           p_ledger_id,trx.set_of_books_id)
                AND trx.legal_entity_id  =  DECODE(p_ledger_id, NULL,
                                          p_legal_entity_id,trx.legal_entity_id)
                AND rpt.set_of_books_id  =  trx.set_of_books_id
                AND rpt.status  =  'APP'
                AND trx.STATUS_TRX  =  'CL'
                AND amount_applied  >=  0
                AND trunc(rpt.apply_date)  <=  trunc(p_end_date)
                AND rpt.apply_date  <  zdf.tax_invoice_date
                AND NOT EXISTS (SELECT  1
                                FROM jg_zz_vat_trx_details
                                WHERE application_id  =  222
                                AND trx_id  =  trx.customer_trx_id
                                AND entity_code  =  zdf.entity_code
                                AND event_class_code  =  zdf.event_class_code
                                AND final_reporting_id IS NOT NULL
                                )
                GROUP BY trx.customer_trx_id,
                        zdf.tax_invoice_date,
                        zdf.entity_code,
                        zdf.event_class_code;

BEGIN

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',
                G_PKG_NAME||': '||l_api_name||'()+');
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
               'P_LEGAL_ENTITY_ID = '|| p_legal_entity_id);
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
               'P_LEDGER_ID = '|| p_ledger_id);
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
               'P_END_DATE = '|| p_end_date);
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
               ' P_SOURCE  = ' || p_source);
   END IF;

   IF g_debug_flag = 'Y' THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME||': '||l_api_name||'()+');
   END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_errbuf := NULL;

  IF p_legal_entity_id IS NOT NULL THEN
        SELECT ledger_id
        INTO l_ledger_id
        FROM gl_ledger_le_v
        WHERE legal_entity_id = p_legal_entity_id
        AND LEDGER_CATEGORY_CODE = 'PRIMARY';
  ELSE
        l_ledger_id := p_ledger_id;
  END IF;


 -- Check whether Tax Date Maintenance Program for AP needs to be executed
  IF (p_source = 'AP' OR p_source = 'ALL') THEN

     /*===== Start of Payables Tax Date Maintenance Program ==============*/
     BEGIN

        IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
             'At the Beginning of Payables Tax Date Maintenance Program');
        END IF;

        OPEN  c_primary_acct_method (l_ledger_id);
        FETCH c_primary_acct_method INTO l_prim_acct_method;
        CLOSE c_primary_acct_method;

   FOR c_inv_null_tax_date_rec IN  c_inv_null_tax_date
        LOOP
          -- Check the accouting method
          -- If accounting method is 'Cash' then
          -- update Tax Date to the payment clearing date

          IF l_prim_acct_method = 'Cash'
             OR ((c_inv_null_tax_date_rec.invoice_type_lookup_code = 'PREPAYMENT')
             OR (c_inv_null_tax_date_rec.small_business_flag = 'Y')) THEN

                IF  c_inv_null_tax_date_rec.cleared_date < p_end_date THEN
                    UPDATE  ap_invoices_all
                    SET tax_invoice_recording_date = c_inv_null_tax_date_rec.cleared_date
                    WHERE invoice_id = c_inv_null_tax_date_rec.invoice_id
                    AND set_of_books_id = c_inv_null_tax_date_rec.set_of_books_id;

                    UPDATE  zx_lines_det_factors
                    SET tax_invoice_date = c_inv_null_tax_date_rec.cleared_date
                    WHERE application_id = 200
                    AND trx_id = c_inv_null_tax_date_rec.invoice_id
                    AND entity_code = 'AP_INVOICES'
                    AND ledger_id = c_inv_null_tax_date_rec.set_of_books_id;

                   -- Print the Invoices for which the tax date is getting
                   -- updated in the log file
                   IF l_num = 0 AND ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
                         'The tax date has been changed to cleared date for the
                          following invoices');
                         l_num := 1;
                   END IF;

                   IF l_num = 1 AND ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
                      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
                      'Invoice num :' || c_inv_null_tax_date_rec.invoice_num ||
                    --  '  ' ||'Original Tax Date :'|| to_char(c_inv_null_tax_date_rec.tax_invoice_recording_date, 'DD-MON-YYYY')
                    --||'  '|| 'Changed Tax Date :' || to_char(c_inv_null_tax_date_rec.cleared_date, 'DD-MON-YYYY'));
                     '  ' || 'Actual Tax Date :'|| c_inv_null_tax_date_rec.tax_invoice_recording_date
                     ||'  '|| 'Updated Tax Date :' || c_inv_null_tax_date_rec.cleared_date);
                   END IF;

                END IF;

          END IF;

        END LOOP;
  EXCEPTION
        WHEN OTHERS THEN

                IF c_inv_null_tax_date%ISOPEN THEN
                        CLOSE c_inv_null_tax_date ;
                END IF;

                IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,
                   'Unable to update the Tax_Invoice_Date in
                     PAYABLES_MAINTENANCE PROGRAM' || ' error_msg = '
                     || sqlcode || ':' || SUBSTR(SQLERRM, 1, 80));
                END IF;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                x_errbuf := sqlcode || ':' || SUBSTR(SQLERRM, 1, 80);
                return;

  END;   -- Payables_Maintenance_Prog

 END IF;


 IF (p_source = 'AR' OR p_source = 'ALL') THEN

     /*=========== Start of Receivables Tax Date Maintenance Program =========*/
     BEGIN

        l_num := 0;
        IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
                'Begining of the Receivables Tax date manintenance program');
                l_num := 1;
        END IF;

        FOR c_cust_trx_rec  IN  c_cust_trx
        LOOP
                -- Write the information into log file
                IF l_num = 1 AND (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_LOG.STRING ( G_LEVEL_EXCEPTION, G_MODULE_NAME || l_api_name,
                   ' Trx Id            '      || c_cust_trx_rec.customer_trx_id ||
                   ' Actual tax date     '    || c_cust_trx_rec.tax_invoice_date ||
                   ' Updated tax date    '    || c_cust_trx_rec.apply_date );
                END IF;

                -- Update the zx_lies_det_factors table
                BEGIN
                        UPDATE  zx_lines_det_factors
                        SET tax_invoice_date =  c_cust_trx_rec.apply_date
                        WHERE application_id = 222
                        AND trx_id = c_cust_trx_rec.customer_trx_id
                        AND entity_code = c_cust_trx_rec.entity_code
                        AND event_class_code = c_cust_trx_rec.event_class_code;
                EXCEPTION
                WHEN OTHERS THEN
                  IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                     FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,
                   'Error in updating Tax_Invoice_Date ' || ' error_msg = '
                     || sqlcode || ':' || SUBSTR(SQLERRM, 1, 80));
                  END IF;
                     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                     x_errbuf := sqlcode || ':' || SUBSTR(SQLERRM, 1, 80);
                END;

        END LOOP;
        IF l_num = 1 AND (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING ( G_LEVEL_EXCEPTION, G_MODULE_NAME || l_api_name, 'End of RECEIVABLES_MAINTENANCE PROGRAM' );
        END IF;
     EXCEPTION
        WHEN OTHERS THEN
             IF c_cust_trx%ISOPEN THEN
                CLOSE c_cust_trx ;
             END IF;
             IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,
                   'Unable to update the Tax_Invoice_Date in
                    RECEIVABLES_MAINTENANCE PROGRAM' || ' error_msg = '
                     || sqlcode || ':' || SUBSTR(SQLERRM, 1, 80));
             END IF;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                x_errbuf := sqlcode || ':' || SUBSTR(SQLERRM, 1, 80);
     END;   -- Receivables_maintenance_prog

  END IF;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',
                G_PKG_NAME||': ' ||l_api_name||'()-');
   END IF;

   IF g_debug_flag = 'Y' THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG, G_PKG_NAME||': ' ||l_api_name||'()-');
   END IF;

  EXCEPTION
     WHEN OTHERS THEN
          IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,
            'Unable to update the Tax_Invoice_Date in TAX DATE MAINTENANCE PROGRAM'
            || ' error_msg = ' || sqlcode || ':' || SUBSTR(SQLERRM, 1, 80) );
          END IF;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            x_errbuf := sqlcode || ':' || SUBSTR(SQLERRM, 1, 80);
 END tax_date_maintenance_program;



/*=========================================================================+
 | PACKAGE Constructor                                                     |
 |                                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |    The constructor initializes the global variables and displays the    |
 |    version of the package in the debug file                             |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |  Date           Author          Description                             |
 |  ============  ==============  =================================        |
 |   23-Jan-2006   RBASKER               Initial  Version.                 |
 |                                                                         |
 +=========================================================================*/

BEGIN
--  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

          select text into l_version_info from user_source
          where  name = 'JG_ZZ_VAT_SELECTION_PKG'
          and    text like '%Header:%'
          and    type = 'PACKAGE BODY'
          and    line < 10;

         IF (g_level_procedure >= g_current_runtime_level ) THEN
             FND_LOG.STRING(g_level_procedure, g_module_name||' version info :',
                                  l_version_info);
             FND_LOG.STRING(g_level_procedure, g_module_name|| ' version info :',
                                  'g_current_runtime_level :'||to_char(g_current_runtime_level));
             FND_LOG.STRING(g_level_procedure,  g_module_name|| ' version info :',
                                  'g_level_procedure :'||to_char(g_level_procedure));
             FND_LOG.STRING(g_level_procedure,  g_module_name|| ' version info :',
                                  'g_level_procedure :'||to_char(g_level_statement));
         END IF;
END JG_ZZ_VAT_SELECTION_PKG;

/
