--------------------------------------------------------
--  DDL for Package Body AR_MO_CACHE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_MO_CACHE_UTILS" AS
/*$Header: ARMOCSHB.pls 120.17.12010000.4 2009/01/29 13:02:29 spdixit ship $ */
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

-- Bug 3251839 - tm_installed and tm_default_setup functions provide a
-- wrapper to the TM boolean functions that can be called in sql

FUNCTION tm_installed ( p_org_id  IN NUMBER DEFAULT NULL )
RETURN VARCHAR2 IS
BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
    arp_util.debug('ar_mo_cache_utils.tm_installed()');
  END IF;

  IF ozf_claim_install.check_installed ( p_org_id ) THEN
     RETURN 'Y';
  ELSE
     RETURN 'N';
  END IF;
EXCEPTION
  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
	arp_util.debug('EXCEPTION: problem calling ozf_claim_install.check_installed - ar_mo_cache_utils.tm_installed');
     END IF;
     APP_EXCEPTION.raise_exception;
END;

FUNCTION tm_default_setup ( p_org_id  IN NUMBER DEFAULT NULL )
RETURN VARCHAR2 IS
BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
    arp_util.debug('ar_mo_cache_utils.tm_default_setup()');
  END IF;

  IF ozf_claim_install.check_default_setup ( p_org_id ) THEN
     RETURN 'Y';
  ELSE
     RETURN 'N';
  END IF;
EXCEPTION
  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
	arp_util.debug('EXCEPTION: problem calling ozf_claim_install.check_default_setup - ar_mo_cache_utils.tm_default_setup');
     END IF;
     APP_EXCEPTION.raise_exception;
END;

 PROCEDURE retrieve_globals( p_globals OUT NOCOPY Globalstable,
                             p_org_id  IN NUMBER DEFAULT NULL)
IS
l_exp_flag varchar2(1);
l_sob_test  varchar2(1);
l_zx_test  varchar2(1);

/* Bug 5051539 */
cursor c_exception(c_org_id IN NUMBER) is
 SELECT *
 FROM ar_system_parameters sp
 WHERE sp.org_id = nvl(c_org_id , sp.org_id);

BEGIN
 IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('ar_mo_cache_utils.retrieve_globals()+');
 END IF;

    /* ---------------------------------------------------------------
       This statement fetches operating unit attributes from the
       database and stores them into nested tables using BULK  COLLECT
       ---------------------------------------------------------------    */
  IF mo_utils.get_multi_org_flag = 'Y' THEN
 /* --------------------------------
        For Multi org case
    ---------------------------------  */
   /* Bug 3836832 - dummy salesrep is retrieved directly from jtf_rs_salesreps
      instead of ra_salesreps view.  Lookup retrieval from ar_lookups
      replaced by calls to get_lookup function */

   /* Bug 4188835 - replaced numerous sp columns with some
      from zx_product_options */

   /* 4923225 - made zx_product_options an outer join */

   /* 5051539 - Added org_id filter to only retrieve for org_id if passed */

   select
          sp.org_id,
          sob.chart_of_accounts_id,
          sob.set_of_books_id,
          sob.name,
          fc.currency_code,
          sp.accounting_method,
          sp.accrue_interest,
          sp.unearned_discount,
          sp.partial_discount_flag,
          sp.print_remit_to,
          sp.default_cb_due_date,
          sp.auto_site_numbering,
          sp.cash_basis_set_of_books_id,
          sp.code_combination_id_gain,
          sp.autocash_hierarchy_id,
          sp.run_gl_journal_import_flag,
          sp.cer_split_amount,
          sp.cer_dso_days,
          sp.posting_days_per_cycle,
          sp.address_validation,
          sp.calc_discount_on_lines_flag,
          sp.change_printed_invoice_flag,
          sp.code_combination_id_loss,
          sp.create_reciprocal_flag,
          sp.default_country,
          sp.default_territory,
          sp.generate_customer_number,
          sp.invoice_deletion_flag,
          sp.location_structure_id,
          sp.site_required_flag,
          zxpo.tax_allow_compound_flag,
          sp.tax_header_level_flag, -- ?
          zxpo.allow_tax_rounding_ovrd_flag, --tax_rounding_allow_override,
          sp.tax_invoice_print,
          zxpo.tax_method_code,
          zxpo.tax_use_customer_exempt_flag,
          sp.tax_use_cust_exc_rate_flag, -- obsolete
          zxpo.tax_use_loc_exc_rate_flag,
          zxpo.tax_use_product_exempt_flag,
          sp.tax_use_prod_exc_rate_flag, -- obsolete
          sp.tax_use_site_exc_rate_flag, -- obsolete
          sp.ai_log_file_message_level,
          sp.ai_max_memory_in_bytes,
          sp.ai_acct_flex_key_left_prompt,
          sp.ai_mtl_items_key_left_prompt,
          sp.ai_territory_key_left_prompt,
          sp.ai_purge_interface_tables_flag,
          sp.ai_activate_sql_trace_flag,
          sp.default_grouping_rule_id,
          sp.salesrep_required_flag,
          sp.auto_rec_invoices_per_commit,
          sp.auto_rec_receipts_per_commit,
          sp.pay_unrelated_invoices_flag,
          sp.print_home_country_flag,
          sp.location_tax_account,
          sp.from_postal_code,
          sp.to_postal_code,
          sp.tax_registration_number,  -- zx_registrations
          sp.populate_gl_segments_flag,
          sp.unallocated_revenue_ccid,
          sob.period_set_name,
          fc.precision,
          fc.EXTENDED_PRECISION,
          fc.MINIMUM_ACCOUNTABLE_UNIT,
          rs.name,
	  arpt_sql_func_util.get_lookup_meaning( 'YES/NO', 'Y'),
	  arpt_sql_func_util.get_lookup_meaning( 'YES/NO', 'N'),
          arpt_sql_func_util.get_lookup_meaning( 'TAX_CONTROL_FLAG', 'S'),
          zxpo.inclusive_tax_used_flag,
          sp.tax_enforce_account_flag, -- zx_evnt_cls_options
          sp.ta_installed_flag,
          sp.bills_receivable_enabled_flag,
          sp.attribute_category,
          sp.attribute1,
          sp.attribute2,
          sp.attribute3,
          sp.attribute4,
          sp.attribute5,
          sp.attribute6,
          sp.attribute7,
          sp.attribute8,
          sp.attribute9,
          sp.attribute10,
          sp.attribute11,
          sp.attribute12,
          sp.attribute13,
          sp.attribute14,
          sp.attribute15,
          sp.created_by,
          sp.creation_date,
          sp.last_updated_by,
          sp.last_update_date,
          sp.last_update_login,
          zxpo.tax_classification_code,      --tax_code,
          sp.tax_currency_code,              --?
          zxpo.tax_minimum_accountable_unit,
          zxpo.tax_precision,
          zxpo.tax_rounding_rule,
          sp.tax_use_account_exc_rate_flag,  -- obsol. use def_option_hier 1-7
          sp.tax_use_system_exc_rate_flag,
          sp.tax_hier_site_exc_rate,
          sp.tax_hier_cust_exc_rate,
          sp.tax_hier_prod_exc_rate,
          sp.tax_hier_account_exc_rate,
          sp.tax_hier_system_exc_rate,       -- obsol. use def_option_hier 1-7
          sp.tax_database_view_set,          -- obsolete
          sp.global_attribute1,
          sp.global_attribute2,
          sp.global_attribute3,
          sp.global_attribute4,
          sp.global_attribute5,
          sp.global_attribute6,
          sp.global_attribute7,
          sp.global_attribute8,
          sp.global_attribute9,
          sp.global_attribute10,
          sp.global_attribute11,
          sp.global_attribute12,
          sp.global_attribute13,
          sp.global_attribute14,
          sp.global_attribute15,
          sp.global_attribute16,
          sp.global_attribute17,
          sp.global_attribute18,
          sp.global_attribute19,
          sp.global_attribute20,
          sp.global_attribute_category,
          sp.rule_set_id,
          sp.code_combination_id_round,
          sp.trx_header_level_rounding,
          sp.trx_header_round_ccid,
          sp.finchrg_receivables_trx_id,
          sp.sales_tax_geocode,
          sp.rev_transfer_clear_ccid,
          sp.sales_credit_pct_limit,
          sp.max_wrtoff_amount,
          sp.irec_cc_receipt_method_id,
          sp.show_billing_number_flag,
          sp.cross_currency_rate_type,
          sp.document_seq_gen_level,
          'Y', --sp.calc_tax_on_credit_memo_flag,
          sp.IREC_BA_RECEIPT_METHOD_ID,
          tm_installed (sp.org_id),
	  tm_default_setup (sp.org_id),
          sp.payment_threshold,
          sp.standard_refund,
          sp.credit_classification1,
          sp.credit_classification2,
          sp.credit_classification3,
          sp.unmtch_claim_creation_flag,
          sp.matched_claim_creation_flag,
          sp.matched_claim_excl_cm_flag,
          sp.min_wrtoff_amount,
          sp.min_refund_amount,
	  sp.create_detailed_dist_flag
   BULK  COLLECT
       INTO
          p_globals.org_id_t,
          p_globals.chart_of_accounts_id_t,
          p_globals.set_of_books_id_t,
          p_globals.set_of_books_name_t,
          p_globals.currency_code_t,
          p_globals.accounting_method_t,
          p_globals.accrue_interest_t,
          p_globals.unearned_discount_t,
          p_globals.partial_discount_flag_t,
          p_globals.print_remit_to_t,
          p_globals.default_cb_due_date_t,
          p_globals.auto_site_numbering_t,
          p_globals.cash_basis_set_of_books_id_t,
          p_globals.code_combination_id_gain_t,
          p_globals.autocash_hierarchy_id_t,
          p_globals.run_gl_journal_import_flag_t,
          p_globals.cer_split_amount_t,
          p_globals.cer_dso_days_t,
          p_globals.posting_days_per_cycle_t,
          p_globals.address_validation_t,
          p_globals.calc_discount_on_lines_flag_t,
          p_globals.change_printed_invoice_flag_t,
          p_globals.code_combination_id_loss_t,
          p_globals.create_reciprocal_flag_t,
          p_globals.default_country_t,
          p_globals.default_territory_t,
          p_globals.generate_customer_number_t,
          p_globals.invoice_deletion_flag_t,
          p_globals.location_structure_id_t,
          p_globals.site_required_flag_t,
          p_globals.tax_allow_compound_flag_t,
          p_globals.tax_header_level_flag_t,
          p_globals.tax_rounding_allow_override_t,
          p_globals.tax_invoice_print_t,
          p_globals.tax_method_t,
          p_globals.tax_use_customer_exempt_flag_t,
          p_globals.tax_use_cust_exc_rate_flag_t,
          p_globals.tax_use_loc_exc_rate_flag_t,
          p_globals.tax_use_product_exempt_flag_t,
          p_globals.tax_use_prod_exc_rate_flag_t,
          p_globals.tax_use_site_exc_rate_flag_t,
          p_globals.ai_log_file_message_level_t,
          p_globals.ai_max_memory_in_bytes_t,
          p_globals.ai_acct_flex_key_left_prompt_t,
          p_globals.ai_mtl_items_key_left_prompt_t,
          p_globals.ai_territory_key_left_prompt_t,
          p_globals.ai_purge_int_tables_flag_t,
          p_globals.ai_activate_sql_trace_flag_t,
          p_globals.default_grouping_rule_id_t,
          p_globals.salesrep_required_flag_t,
          p_globals.auto_rec_invoices_per_commit_t,
          p_globals.auto_rec_receipts_per_commit_t,
          p_globals.pay_unrelated_invoices_flag_t,
          p_globals.print_home_country_flag_t,
          p_globals.location_tax_account_t,
          p_globals.from_postal_code_t,
          p_globals.to_postal_code_t,
          p_globals.tax_registration_number_t,
          p_globals.populate_gl_segments_flag_t,
          p_globals.unallocated_revenue_ccid_t,
          p_globals.period_set_name_t,
          p_globals.base_precision_t,
          p_globals.base_extended_precision_t,
          p_globals.base_min_accountable_unit_t,
          p_globals.salescredit_name_t,
          p_globals.yes_meaning_t,
          p_globals.no_meaning_t,
          p_globals.tax_exempt_flag_meaning_t,
          p_globals.inclusive_tax_used_t,
          p_globals.tax_enforce_account_flag_t,
          p_globals.ta_installed_flag_t,
          p_globals.br_enabled_flag_t,
          p_globals.attribute_category_t,
          p_globals.attribute1_t,
          p_globals.attribute2_t,
          p_globals.attribute3_t,
          p_globals.attribute4_t,
          p_globals.attribute5_t,
          p_globals.attribute6_t,
          p_globals.attribute7_t,
          p_globals.attribute8_t,
          p_globals.attribute9_t,
          p_globals.attribute10_t,
          p_globals.attribute11_t,
          p_globals.attribute12_t,
          p_globals.attribute13_t,
          p_globals.attribute14_t,
          p_globals.attribute15_t,
          p_globals.created_by_t,
          p_globals.creation_date_t,
          p_globals.last_updated_by_t,
          p_globals.last_update_date_t,
          p_globals.last_update_login_t,
          p_globals.tax_code_t,
          p_globals.tax_currency_code_t,
          p_globals.tax_minimum_accountable_unit_t,
          p_globals.tax_precision_t,
          p_globals.tax_rounding_rule_t,
          p_globals.tax_use_acc_exc_rate_flag_t,
          p_globals.tax_use_system_exc_rate_flag_t,
          p_globals.tax_hier_site_exc_rate_t,
          p_globals.tax_hier_cust_exc_rate_t,
          p_globals.tax_hier_prod_exc_rate_t,
          p_globals.tax_hier_account_exc_rate_t,
          p_globals.tax_hier_system_exc_rate_t,
          p_globals.tax_database_view_set_t,
          p_globals.global_attribute1_t,
          p_globals.global_attribute2_t,
          p_globals.global_attribute3_t,
          p_globals.global_attribute4_t,
          p_globals.global_attribute5_t,
          p_globals.global_attribute6_t,
          p_globals.global_attribute7_t,
          p_globals.global_attribute8_t,
          p_globals.global_attribute9_t,
          p_globals.global_attribute10_t,
          p_globals.global_attribute11_t,
          p_globals.global_attribute12_t,
          p_globals.global_attribute13_t,
          p_globals.global_attribute14_t,
          p_globals.global_attribute15_t,
          p_globals.global_attribute16_t,
          p_globals.global_attribute17_t,
          p_globals.global_attribute18_t,
          p_globals.global_attribute19_t,
          p_globals.global_attribute20_t,
          p_globals.global_attribute_category_t,
          p_globals.rule_set_id_t,
          p_globals.code_combination_id_round_t,
          p_globals.trx_header_level_rounding_t,
          p_globals.trx_header_round_ccid_t,
          p_globals.finchrg_receivables_trx_id_t,
          p_globals.sales_tax_geocode_t,
          p_globals.rev_transfer_clear_ccid_t,
          p_globals.sales_credit_pct_limit_t,
          p_globals.max_wrtoff_amount_t,
          p_globals.irec_cc_receipt_method_id_t,
          p_globals.show_billing_number_flag_t,
          p_globals.cross_currency_rate_type_t,
          p_globals.document_seq_gen_level_t,
          p_globals.calc_tax_on_credit_memo_flag_t,
          p_globals.irec_ba_receipt_method_id_t,
	  p_globals.tm_installed_flag_t,
	  p_globals.tm_default_setup_flag_t,
          p_globals.payment_threshold_t,
          p_globals.standard_refund_t,
          p_globals.credit_classification1_t,
          p_globals.credit_classification2_t,
          p_globals.credit_classification3_t,
          p_globals.unmtch_claim_creation_flag_t,
          p_globals.matched_claim_creation_flag_t,
          p_globals.matched_claim_excl_cm_flag_t,
          p_globals.min_wrtoff_amount_t,
          p_globals.min_refund_amount_t,
	  p_globals.create_detailed_dist_flag_t
    from
          gl_sets_of_books sob,
          fnd_currencies fc,
          jtf_rs_salesreps rs,
          ar_system_parameters sp,
          zx_product_options zxpo
    where   sp.set_of_books_id = sob.set_of_books_id
    and     sob.currency_code  = fc.currency_code
    and     nvl(sp.org_id,-99) = nvl(rs.org_id,-99)
    and     sp.org_id = nvl(p_org_id, sp.org_id)/* Bug 5051539 */
    and     rs.salesrep_id     = -3
    and     zxpo.application_id (+) = 222
    and     zxpo.org_id (+) = sp.org_id;
  else
     /* --------------------------------
        For  non multi org case
        ---------------------------------  */
   select
          -3115,
          sob.chart_of_accounts_id,
          sob.set_of_books_id,
          sob.name,
          fc.currency_code,
          sp.accounting_method,
          sp.accrue_interest,
          sp.unearned_discount,
          sp.partial_discount_flag,
          sp.print_remit_to,
          sp.default_cb_due_date,
          sp.auto_site_numbering,
          sp.cash_basis_set_of_books_id,
          sp.code_combination_id_gain,
          sp.autocash_hierarchy_id,
          sp.run_gl_journal_import_flag,
          sp.cer_split_amount,
          sp.cer_dso_days,
          sp.posting_days_per_cycle,
          sp.address_validation,
          sp.calc_discount_on_lines_flag,
          sp.change_printed_invoice_flag,
          sp.code_combination_id_loss,
          sp.create_reciprocal_flag,
          sp.default_country,
          sp.default_territory,
          sp.generate_customer_number,
          sp.invoice_deletion_flag,
          sp.location_structure_id,
          sp.site_required_flag,
          zxpo.tax_allow_compound_flag,
          sp.tax_header_level_flag,          --zx_party_tax_profile, zx_evnt_cls_options
          zxpo.allow_tax_rounding_ovrd_flag, --tax_rounding_allow_override,
          sp.tax_invoice_print,
          zxpo.tax_method_code,
          zxpo.tax_use_customer_exempt_flag,
          sp.tax_use_cust_exc_rate_flag, -- obsolete
          zxpo.tax_use_loc_exc_rate_flag,
          zxpo.tax_use_product_exempt_flag,
          sp.tax_use_prod_exc_rate_flag, -- obsolete
          sp.tax_use_site_exc_rate_flag, -- obsolete
          sp.ai_log_file_message_level,
          sp.ai_max_memory_in_bytes,
          sp.ai_acct_flex_key_left_prompt,
          sp.ai_mtl_items_key_left_prompt,
          sp.ai_territory_key_left_prompt,
          sp.ai_purge_interface_tables_flag,
          sp.ai_activate_sql_trace_flag,
          sp.default_grouping_rule_id,
          sp.salesrep_required_flag,
          sp.auto_rec_invoices_per_commit,
          sp.auto_rec_receipts_per_commit,
          sp.pay_unrelated_invoices_flag,
          sp.print_home_country_flag,
          sp.location_tax_account,
          sp.from_postal_code,
          sp.to_postal_code,
          sp.tax_registration_number,  --zx_registrations
          sp.populate_gl_segments_flag,
          sp.unallocated_revenue_ccid,
          sob.period_set_name,
          fc.precision,
          fc.EXTENDED_PRECISION,
          fc.MINIMUM_ACCOUNTABLE_UNIT,
          rs.name,
	  arpt_sql_func_util.get_lookup_meaning( 'YES/NO', 'Y'),
	  arpt_sql_func_util.get_lookup_meaning( 'YES/NO', 'N'),
          arpt_sql_func_util.get_lookup_meaning( 'TAX_CONTROL_FLAG', 'S'),
          zxpo.inclusive_tax_used_flag,
          sp.tax_enforce_account_flag,  --zx_evnt_cls_options
          sp.ta_installed_flag,
          sp.bills_receivable_enabled_flag,
          sp.attribute_category,
          sp.attribute1,
          sp.attribute2,
          sp.attribute3,
          sp.attribute4,
          sp.attribute5,
          sp.attribute6,
          sp.attribute7,
          sp.attribute8,
          sp.attribute9,
          sp.attribute10,
          sp.attribute11,
          sp.attribute12,
          sp.attribute13,
          sp.attribute14,
          sp.attribute15,
          sp.created_by,
          sp.creation_date,
          sp.last_updated_by,
          sp.last_update_date,
          sp.last_update_login,
          zxpo.tax_classification_code,      --tax_code,
          sp.tax_currency_code,              --?
          zxpo.tax_minimum_accountable_unit,
          zxpo.tax_precision,
          zxpo.tax_rounding_rule,
          sp.tax_use_account_exc_rate_flag,  -- obsol. use def_option_hier 1-7
          sp.tax_use_system_exc_rate_flag,
          sp.tax_hier_site_exc_rate,
          sp.tax_hier_cust_exc_rate,
          sp.tax_hier_prod_exc_rate,
          sp.tax_hier_account_exc_rate,
          sp.tax_hier_system_exc_rate,       -- obsol. use def_option_hier 1-7
          sp.tax_database_view_set,          -- obsolete
          sp.global_attribute1,
          sp.global_attribute2,
          sp.global_attribute3,
          sp.global_attribute4,
          sp.global_attribute5,
          sp.global_attribute6,
          sp.global_attribute7,
          sp.global_attribute8,
          sp.global_attribute9,
          sp.global_attribute10,
          sp.global_attribute11,
          sp.global_attribute12,
          sp.global_attribute13,
          sp.global_attribute14,
          sp.global_attribute15,
          sp.global_attribute16,
          sp.global_attribute17,
          sp.global_attribute18,
          sp.global_attribute19,
          sp.global_attribute20,
          sp.global_attribute_category,
          sp.rule_set_id,
          sp.code_combination_id_round,
          sp.trx_header_level_rounding,
          sp.trx_header_round_ccid,
          sp.finchrg_receivables_trx_id,
          sp.sales_tax_geocode,
          sp.rev_transfer_clear_ccid,
          sp.sales_credit_pct_limit,
          sp.max_wrtoff_amount,
          sp.irec_cc_receipt_method_id,
          sp.show_billing_number_flag,
          sp.cross_currency_rate_type,
          sp.document_seq_gen_level,
          'Y', --sp.calc_tax_on_credit_memo_flag,
          sp.IREC_BA_RECEIPT_METHOD_ID,
	  tm_installed (sp.org_id),
	  tm_default_setup (sp.org_id),
          sp.payment_threshold,
          sp.standard_refund,
          sp.credit_classification1,
          sp.credit_classification2,
          sp.credit_classification3,
          sp.unmtch_claim_creation_flag,
          sp.matched_claim_creation_flag,
          sp.matched_claim_excl_cm_flag,
          sp.min_wrtoff_amount,
          sp.min_refund_amount,
	  sp.create_detailed_dist_flag
   BULK  COLLECT
       INTO
          p_globals.org_id_t,
          p_globals.chart_of_accounts_id_t,
          p_globals.set_of_books_id_t,
          p_globals.set_of_books_name_t,
          p_globals.currency_code_t,
          p_globals.accounting_method_t,
          p_globals.accrue_interest_t,
          p_globals.unearned_discount_t,
          p_globals.partial_discount_flag_t,
          p_globals.print_remit_to_t,
          p_globals.default_cb_due_date_t,
          p_globals.auto_site_numbering_t,
          p_globals.cash_basis_set_of_books_id_t,
          p_globals.code_combination_id_gain_t,
          p_globals.autocash_hierarchy_id_t,
          p_globals.run_gl_journal_import_flag_t,
          p_globals.cer_split_amount_t,
          p_globals.cer_dso_days_t,
          p_globals.posting_days_per_cycle_t,
          p_globals.address_validation_t,
          p_globals.calc_discount_on_lines_flag_t,
          p_globals.change_printed_invoice_flag_t,
          p_globals.code_combination_id_loss_t,
          p_globals.create_reciprocal_flag_t,
          p_globals.default_country_t,
          p_globals.default_territory_t,
          p_globals.generate_customer_number_t,
          p_globals.invoice_deletion_flag_t,
          p_globals.location_structure_id_t,
          p_globals.site_required_flag_t,
          p_globals.tax_allow_compound_flag_t,
          p_globals.tax_header_level_flag_t,
          p_globals.tax_rounding_allow_override_t,
          p_globals.tax_invoice_print_t,
          p_globals.tax_method_t,
          p_globals.tax_use_customer_exempt_flag_t,
          p_globals.tax_use_cust_exc_rate_flag_t,
          p_globals.tax_use_loc_exc_rate_flag_t,
          p_globals.tax_use_product_exempt_flag_t,
          p_globals.tax_use_prod_exc_rate_flag_t,
          p_globals.tax_use_site_exc_rate_flag_t,
          p_globals.ai_log_file_message_level_t,
          p_globals.ai_max_memory_in_bytes_t,
          p_globals.ai_acct_flex_key_left_prompt_t,
          p_globals.ai_mtl_items_key_left_prompt_t,
          p_globals.ai_territory_key_left_prompt_t,
          p_globals.ai_purge_int_tables_flag_t,
          p_globals.ai_activate_sql_trace_flag_t,
          p_globals.default_grouping_rule_id_t,
          p_globals.salesrep_required_flag_t,
          p_globals.auto_rec_invoices_per_commit_t,
          p_globals.auto_rec_receipts_per_commit_t,
          p_globals.pay_unrelated_invoices_flag_t,
          p_globals.print_home_country_flag_t,
          p_globals.location_tax_account_t,
          p_globals.from_postal_code_t,
          p_globals.to_postal_code_t,
          p_globals.tax_registration_number_t,
          p_globals.populate_gl_segments_flag_t,
          p_globals.unallocated_revenue_ccid_t,
          p_globals.period_set_name_t,
          p_globals.base_precision_t,
          p_globals.base_extended_precision_t,
          p_globals.base_min_accountable_unit_t,
          p_globals.salescredit_name_t,
          p_globals.yes_meaning_t,
          p_globals.no_meaning_t,
          p_globals.tax_exempt_flag_meaning_t,
          p_globals.inclusive_tax_used_t,
          p_globals.tax_enforce_account_flag_t,
          p_globals.ta_installed_flag_t,
          p_globals.br_enabled_flag_t,
          p_globals.attribute_category_t,
          p_globals.attribute1_t,
          p_globals.attribute2_t,
          p_globals.attribute3_t,
          p_globals.attribute4_t,
          p_globals.attribute5_t,
          p_globals.attribute6_t,
          p_globals.attribute7_t,
          p_globals.attribute8_t,
          p_globals.attribute9_t,
          p_globals.attribute10_t,
          p_globals.attribute11_t,
          p_globals.attribute12_t,
          p_globals.attribute13_t,
          p_globals.attribute14_t,
          p_globals.attribute15_t,
          p_globals.created_by_t,
          p_globals.creation_date_t,
          p_globals.last_updated_by_t,
          p_globals.last_update_date_t,
          p_globals.last_update_login_t,
          p_globals.tax_code_t,
          p_globals.tax_currency_code_t,
          p_globals.tax_minimum_accountable_unit_t,
          p_globals.tax_precision_t,
          p_globals.tax_rounding_rule_t,
          p_globals.tax_use_acc_exc_rate_flag_t,
          p_globals.tax_use_system_exc_rate_flag_t,
          p_globals.tax_hier_site_exc_rate_t,
          p_globals.tax_hier_cust_exc_rate_t,
          p_globals.tax_hier_prod_exc_rate_t,
          p_globals.tax_hier_account_exc_rate_t,
          p_globals.tax_hier_system_exc_rate_t,
          p_globals.tax_database_view_set_t,
          p_globals.global_attribute1_t,
          p_globals.global_attribute2_t,
          p_globals.global_attribute3_t,
          p_globals.global_attribute4_t,
          p_globals.global_attribute5_t,
          p_globals.global_attribute6_t,
          p_globals.global_attribute7_t,
          p_globals.global_attribute8_t,
          p_globals.global_attribute9_t,
          p_globals.global_attribute10_t,
          p_globals.global_attribute11_t,
          p_globals.global_attribute12_t,
          p_globals.global_attribute13_t,
          p_globals.global_attribute14_t,
          p_globals.global_attribute15_t,
          p_globals.global_attribute16_t,
          p_globals.global_attribute17_t,
          p_globals.global_attribute18_t,
          p_globals.global_attribute19_t,
          p_globals.global_attribute20_t,
          p_globals.global_attribute_category_t,
          p_globals.rule_set_id_t,
          p_globals.code_combination_id_round_t,
          p_globals.trx_header_level_rounding_t,
          p_globals.trx_header_round_ccid_t,
          p_globals.finchrg_receivables_trx_id_t,
          p_globals.sales_tax_geocode_t,
          p_globals.rev_transfer_clear_ccid_t,
          p_globals.sales_credit_pct_limit_t,
          p_globals.max_wrtoff_amount_t,
          p_globals.irec_cc_receipt_method_id_t,
          p_globals.show_billing_number_flag_t,
          p_globals.cross_currency_rate_type_t,
          p_globals.document_seq_gen_level_t,
          p_globals.calc_tax_on_credit_memo_flag_t,
          p_globals.irec_ba_receipt_method_id_t,
	  p_globals.tm_installed_flag_t,
	  p_globals.tm_default_setup_flag_t,
          p_globals.payment_threshold_t,
          p_globals.standard_refund_t,
          p_globals.credit_classification1_t,
          p_globals.credit_classification2_t,
          p_globals.credit_classification3_t,
          p_globals.unmtch_claim_creation_flag_t,
          p_globals.matched_claim_creation_flag_t,
          p_globals.matched_claim_excl_cm_flag_t,
          p_globals.min_wrtoff_amount_t,
          p_globals.min_refund_amount_t,
	  p_globals.create_detailed_dist_flag_t
    from
          gl_sets_of_books sob,
          fnd_currencies fc,
          jtf_rs_salesreps rs,
          ar_system_parameters sp,
          zx_product_options zxpo
    where   sp.set_of_books_id = sob.set_of_books_id
    and     sob.currency_code  = fc.currency_code
    and     nvl(sp.org_id,-99) = nvl(rs.org_id,-99)
    and     sp.org_id = nvl(p_org_id, sp.org_id) /* Bug 5051539 */
    and     rs.salesrep_id     = -3
    and     zxpo.application_id (+) = 222
    and     zxpo.org_id (+) = sp.org_id;
  end if;

 IF PG_DEBUG in ('Y', 'C') THEN
  arp_util.debug('ar_mo_cache_utils.retrieve_globals()-');
 END IF;

EXCEPTION
   when no_data_found then

 /* ---------------------------------------------
    Check row exists in ar_system_parameter
    ---------------------------------------------- */
  l_exp_flag := 'N';

  FOR REC in c_exception(p_org_id) LOOP

     l_exp_flag := 'Y';

    /* ---------------------------------------------
       Check row exists in gl sets of books
       ---------------------------------------------- */
     begin
       SELECT 'x' into l_sob_test
       from ar_system_parameters,
            gl_sets_of_books sob
       where sob.set_of_books_id = REC.set_of_books_id
             and org_id = REC.org_id;
     exception when no_data_found then
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug('EXCEPTION: NO_DATA_FOUND IN SET OF BOOKS -  ar_mo_cache_utils.retrieve_globals' );
       END IF;
       FND_MESSAGE.set_name('AR','AR_NO_ROW_IN_GL_SET_OF_BOOKS');
       APP_EXCEPTION.raise_exception;
       RAISE;
     end;
    /* ---------------------------------------------
       Check row exists in fnd_currencies
       ---------------------------------------------- */
     begin
       SELECT 'x' into l_sob_test
       FROM   ar_system_parameters sp, gl_sets_of_books sob, fnd_currencies c
       WHERE  sob.set_of_books_id = sp.set_of_books_id
              and sp.org_id =  REC.org_id
              and  sob.currency_code = c.currency_code;

     exception when no_data_found then
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_util.debug('EXCEPTION: NO_DATA_FOUND IN CURRENCIES - ar_mo_cache_utils.retrieve_globals' );
       END IF;
       FND_MESSAGE.set_name('AR','AR_NO_ROW_IN_FND_CURRENCIES');
       APP_EXCEPTION.raise_exception;
       RAISE; --end of WHEN NO DATA FOUND
     end;

     /* ---------------------------------------------------
        Check if row exists in zx_product_options
        --------------------------------------------------*/
    /* No longer require to check ZX_PRODUCT_OPTIONS in R12 */

   END LOOP;

   IF l_exp_flag ='N' THEN
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_util.debug('retrieve_globals: ' || 'EXCEPTION: NO_DATA_FOUND IN SYSTEM PARAMETERS
                            - ar_mo_cache_utils.retrieve_globals' );
         END IF;
         FND_MESSAGE.set_name('AR','AR_NO_ROW_IN_SYSTEM_PARAMETERS');
         APP_EXCEPTION.raise_exception;
         RAISE;
    END IF;


 END retrieve_globals;

 PROCEDURE set_org_context_in_api(p_org_id         IN OUT NOCOPY NUMBER,
                                  p_return_status  OUT    NOCOPY VARCHAR2)
 AS
 l_curr_org_id                  number;
 l_status                       VARCHAR2(1);
 l_default_org_id               number;
 BEGIN
     p_return_status := FND_API.G_RET_STS_SUCCESS;

     l_default_org_id := MO_UTILS.Get_Default_Org_ID;
     l_curr_org_id := mo_global.get_current_org_id;

     IF (p_org_id is null or
            p_org_id = FND_API.G_MISS_NUM) THEN
            If l_curr_org_id is not null then
              p_org_id := l_curr_org_id;
            else
              p_org_id := l_default_org_id;
            end if;
     END IF;

     l_status := MO_GLOBAL.check_valid_org(p_org_id);

     IF l_Status = 'N' THEN
           p_return_status := FND_API.G_RET_STS_ERROR;
     ELSE
        mo_global.set_policy_context('S',p_org_id);
           /*-------------------------------------------------+
            | Initialize SOB/org dependent variables          |
            +-------------------------------------------------*/
        arp_global.init_global(p_org_id);
        arp_standard.init_standard(p_org_id);
     END IF;

 EXCEPTION
   WHEN others THEN Raise;

 END set_org_context_in_api;

END ar_mo_cache_utils;

/
