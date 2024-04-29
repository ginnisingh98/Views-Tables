--------------------------------------------------------
--  DDL for Package Body AP_MO_CACHE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_MO_CACHE_UTILS" AS
/* $Header: apmocshb.pls 120.10.12010000.4 2009/01/09 15:04:20 kpasikan ship $ */

  --
  -- This procedure retrieves operating unit attributes from the
  -- database and stores them into the specified data structure.
  --
  PROCEDURE retrieve_globals(p_globals OUT NOCOPY GlobalsTable )
  IS
    current_calling_sequence          VARCHAR2(2000);
    debug_info                        VARCHAR2(100);
    i                                 PLS_INTEGER;
    l_default_org_id                  NUMBER;
    l_default_ou_name                 VARCHAR2(240);
    l_ou_count                        NUMBER;
  BEGIN
    -- Update the calling sequence
    --
    current_calling_sequence :=
            'AP_MO_CACHE_UTILS.Retrieves_Globals';



    --
    -- This statement fetches operating unit attributes from the
    -- database and stores them into nested tables using BULK
    -- COLLECT
    --
      SELECT asp.org_id,
             gl.chart_of_accounts_id,
             gl.set_of_books_id,
             gl.name,
             gl.short_name,
             DECODE(gl.enable_budgetary_control_flag,'Y','Y','N'),
             fnd.currency_code,
             asp.base_currency_code,
             DECODE (asp.multi_currency_flag, 'N', 'N', 'Y'),
             asp.payment_currency_code,
             DECODE (asp.confirm_date_as_inv_num_flag, 'Y', 'Y', 'N'),
             asp.accts_pay_code_combination_id,
             asp.allow_flex_override_flag,
             asp.allow_final_match_flag,
             asp.allow_dist_match_flag,
             asp.gl_date_from_receipt_flag,
             asp.income_tax_region_flag,
             asp.income_tax_region,
             asp.auto_create_freight_flag,
             asp.freight_code_combination_id,
             asp.disc_is_inv_less_tax_flag,
             asp.discount_distribution_method,
             asp.inv_doc_category_override,
             nvl(asp.approvals_option,'BATCH'),
             asp.combined_filing_flag,
             nvl(asp.allow_awt_flag,'N'),
             asp.create_awt_dists_type,
             asp.allow_awt_override,
             asp.awt_include_tax_amt,
             nvl(asp.awt_include_discount_amt, 'N'),
             asp.allow_paid_invoice_adjust,
             asp.add_days_settlement_date,
             asp.prepayment_terms_id,
             apt.name,
             asp.prepay_code_combination_id,
             asp.future_dated_pmt_acct_source,
             asp.calc_user_xrate,
             asp.make_rate_mandatory_flag,
             asp.default_exchange_rate_type,
             asp.post_dated_payments_flag,
             asp.update_pay_site_flag,
             asp.online_print_flag,
             asp.replace_check_flag,
             asp.auto_calculate_interest_flag,
             asp.interest_tolerance_amount,
             asp.interest_accts_pay_ccid,
             nvl(asp.use_bank_charge_flag, 'N'),  /* bug 5007989 */
             nvl(asp.allow_supplier_bank_override, 'N'),
             nvl(asp.pay_doc_category_override, 'N'),
             asp.days_between_check_cycles,
             asp.approval_workflow_flag,
             asp.allow_force_approval_flag,
             asp.validate_before_approval_flag,
             asp.global_attribute_category,
             asp.global_attribute1,
             asp.global_attribute2,
             asp.global_attribute3,
             asp.global_attribute4,
             asp.global_attribute5,
             asp.global_attribute6,
             asp.global_attribute7,
             asp.global_attribute8,
             asp.global_attribute9,
             asp.global_attribute10,
             asp.global_attribute11,
             asp.global_attribute12,
             asp.global_attribute13,
             asp.global_attribute14,
             asp.global_attribute15,
             asp.global_attribute16,
             asp.global_attribute17,
             asp.global_attribute18,
             asp.global_attribute19,
             asp.global_attribute20,
             fsp.purch_encumbrance_flag,
             fsp.inventory_organization_id,
             fsp.vat_country_code,
             asp.ce_bank_acct_use_id,
             aba.bank_account_name,
             aba.zero_amount_allowed,
             aba.max_outlay,
             aba.max_check_amount,
             aba.min_check_amount,
             aba.currency_code,
             aba.multi_currency_allowed_flag,
             gdct.user_conversion_type,
	     asp.auto_calculate_interest_flag,
	     asp.approval_timing,  --Bug4299234
             fsp.misc_charge_ccid,  --bug4936051
	     --Third Party Payments
	     asp.allow_inv_third_party_ovrd,
	     asp.allow_pymt_third_party_ovrd
      BULK COLLECT
      INTO   p_globals.org_id_t,
             p_globals.chart_of_accounts_id_t,
             p_globals.set_of_books_id_t,
             p_globals.set_of_books_name_t,
             p_globals.set_of_books_short_name_t,
             p_globals.enable_budget_control_flag_t,
             p_globals.currency_code_t,
             p_globals.sp_base_currency_code_t,
             p_globals.sp_multi_currency_flag_t,
             p_globals.sp_payment_currency_code_t,
             p_globals.sp_confirm_date_inv_num_flag_t,
             p_globals.sp_accts_pay_cc_id_t,
             p_globals.sp_allow_flex_override_flag_t,
             p_globals.sp_allow_final_match_flag_t,
             p_globals.sp_allow_dist_match_flag_t,
             p_globals.sp_gl_date_from_receipt_flag_t,
             p_globals.sp_income_tax_region_flag_t,
             p_globals.sp_income_tax_region_t,
             p_globals.sp_auto_create_freight_flag_t,
             p_globals.sp_default_freight_cc_id_t,
             p_globals.sp_disc_is_inv_less_tax_flag_t,
             p_globals.sp_discount_dist_method_t,
             p_globals.sp_inv_doc_category_override_t,
             p_globals.sp_approvals_option_t,
             p_globals.sp_combined_filing_flag_t,
             p_globals.sp_allow_awt_flag_t,
             p_globals.sp_create_awt_dists_type_t,
             p_globals.sp_allow_awt_override_t,
             p_globals.sp_awt_include_tax_amt_t,
             p_globals.sp_awt_include_discount_amt_t,
             p_globals.sp_allow_paid_invoice_adjust_t,
             p_globals.sp_add_days_settlement_date_t,
             p_globals.sp_prepayment_terms_id_t,
             p_globals.sp_ap_prepayment_term_name_t,
             p_globals.sp_prepay_cc_id_t,
             p_globals.sp_future_dated_pmt_acct_s_t,
             p_globals.sp_calc_user_xrate_t,
             p_globals.sp_make_rate_mandatory_flag_t,
             p_globals.sp_def_exchange_rate_type_t,
             p_globals.sp_post_dated_payments_flag_t,
             p_globals.sp_update_pay_site_flag_t,
             p_globals.sp_online_print_flag_t,
             p_globals.sp_replace_check_flag_t,
             p_globals.sp_auto_calc_interest_flag_t,
             p_globals.sp_interest_tolerance_amount_t,
             p_globals.sp_interest_accts_pay_ccid_t,
             p_globals.sp_use_bank_charge_flag_t,  /* bug 5007989 */
             p_globals.sp_allow_supp_bank_override_t,
             p_globals.sp_pay_doc_category_override_t,
             p_globals.sp_days_between_check_cycles_t,
             p_globals.sp_approval_workflow_flag_t,
             p_globals.sp_allow_force_approval_flag_t,
             p_globals.sp_validate_before_approval_t,
             p_globals.sp_global_attribute_category_t,
             p_globals.sp_global_attribute1_t,
             p_globals.sp_global_attribute2_t,
             p_globals.sp_global_attribute3_t,
             p_globals.sp_global_attribute4_t,
             p_globals.sp_global_attribute5_t,
             p_globals.sp_global_attribute6_t,
             p_globals.sp_global_attribute7_t,
             p_globals.sp_global_attribute8_t,
             p_globals.sp_global_attribute9_t,
             p_globals.sp_global_attribute10_t,
             p_globals.sp_global_attribute11_t,
             p_globals.sp_global_attribute12_t,
             p_globals.sp_global_attribute13_t,
             p_globals.sp_global_attribute14_t,
             p_globals.sp_global_attribute15_t,
             p_globals.sp_global_attribute16_t,
             p_globals.sp_global_attribute17_t,
             p_globals.sp_global_attribute18_t,
             p_globals.sp_global_attribute19_t,
             p_globals.sp_global_attribute20_t,
             p_globals.fsp_purch_encumbrance_flag_t,
             p_globals.fsp_inventory_org_id_t,
             p_globals.fsp_vat_country_code_t,
             p_globals.sp_aba_bank_account_id_t,
             p_globals.sp_aba_bank_account_name_t,
             p_globals.sp_aba_zero_amounts_allowed_t,
             p_globals.sp_aba_max_outlay_t,
             p_globals.sp_aba_max_check_amount_t,
             p_globals.sp_aba_min_check_amount_t,
             p_globals.sp_aba_currency_code_t,
             p_globals.sp_aba_multi_currency_flag_t,
             p_globals.sp_gdct_user_conversion_type_t,
	     p_globals.sp_allow_interest_invoices_t,
	     p_globals.sp_approval_timing_t,  --Bug4299234
             p_globals.fsp_misc_charge_ccid_t, --Bug4936051
	     --Third Party Payments
	     p_globals.sp_allow_inv_thrd_prty_ovrd_t,
	     p_globals.sp_allow_pymt_thrd_prty_ovrd_t
        FROM gl_sets_of_books gl,
             fnd_currencies fnd,
             ap_system_parameters asp,
             ce_bank_accounts aba,
             ce_bank_acct_uses_all cbau,
             gl_daily_conversion_types gdct,
             financials_system_parameters fsp,
             ap_terms  apt
       WHERE gl.set_of_books_id = asp.set_of_books_id
             AND gl.currency_Code = fnd.currency_code
             AND asp.org_id = fsp.org_id
             AND asp.ce_bank_acct_use_id = cbau.bank_acct_use_id(+)
             AND cbau.bank_account_id = aba.bank_account_id (+)
             AND asp.default_exchange_rate_type = gdct.conversion_type(+)
             AND sysdate < nvl(aba.end_date(+),sysdate) --7673935, reverting 6870310
             -- AND asp.terms_id = apt.term_id(+);
             -- Fix for bug 2416598 commented above line and wrote below one
             AND asp.prepayment_terms_id = apt.term_id(+);


    IF p_globals.org_id_t.COUNT > 0 THEN
      FOR i IN 1..p_globals.org_id_t.LAST LOOP

        IF gl_mc_inquiry_pkg.mrc_enabled(200,
                                 p_globals.set_of_books_id_t(i),
                                 p_globals.org_id_t(i)) THEN

          p_globals.mrc_enabled_t(i) := 'Y';

        ELSE

          p_globals.mrc_enabled_t(i) := 'N';

        END IF;

      END LOOP;

    END IF;


  EXCEPTION
    --
    -- You should raise exception here instead of returning NULL if
    -- caching is critical to your application. For example,
    -- the system options setup may be incomplete or not done,
    -- in which case, the user should close the transaction form,
    -- complete the required setup first.
    --
    WHEN no_data_found THEN
      Mo_Utils.Get_Default_Ou(p_default_org_id  => l_default_org_id
                             ,p_default_ou_name => l_default_ou_name
                             ,p_ou_count        => l_ou_count);
      If (l_ou_count = 0) Then
        FND_MESSAGE.set_name('SQLAP', 'MO_ORG_ACCESS_NO_DATA_FOUND');
        APP_EXCEPTION.raise_exception;
      Else
        FND_MESSAGE.set_name('SQLAP', 'AP_OPTIONS_NOT_YET_DEFINED');
        APP_EXCEPTION.raise_exception;
      End If;
  END retrieve_globals;
END ap_mo_cache_utils;

/
