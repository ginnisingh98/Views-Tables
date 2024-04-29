--------------------------------------------------------
--  DDL for Package Body AR_INVOICE_DEFAULT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_INVOICE_DEFAULT_PVT" AS
/* $Header: ARXVINDB.pls 120.7.12010000.2 2008/11/13 05:41:45 dgaurab ship $ */

pg_debug                VARCHAR2(1) := nvl(fnd_profile.value('AFLOG_ENABLED'),'N');

PROCEDURE Get_system_parameters (
    p_trx_system_parameters_rec     OUT NOCOPY trx_system_parameters_rec_type,
    x_errmsg			            OUT NOCOPY VARCHAR2,
    x_return_status		            OUT NOCOPY VARCHAR2) IS

BEGIN
    IF pg_debug = 'Y'
    THEN
        ar_invoice_utils.debug ('AR_INVOICE_DEFAULT_PVT.Get_system_parameters(+)' );
    END IF;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

    /* 5921925 - copy info from arp_global.sysparam rather than selecting
       from the db (again) */
    arp_global.init_global;

    trx_system_parameters_rec.set_of_books_id := arp_global.sysparam.set_of_books_id;
    trx_system_parameters_rec.accounting_method := arp_global.sysparam.accounting_method;
    trx_system_parameters_rec.accrue_interest :=  arp_global.sysparam.accrue_interest;
    trx_system_parameters_rec.unearned_discount := arp_global.sysparam.unearned_discount;
    trx_system_parameters_rec.partial_discount_flag := arp_global.sysparam.partial_discount_flag;
    trx_system_parameters_rec.print_remit_to := arp_global.sysparam.print_remit_to;
    trx_system_parameters_rec.default_cb_due_date := arp_global.sysparam.default_cb_due_date;
    trx_system_parameters_rec.auto_site_numbering := arp_global.sysparam.auto_site_numbering;
    trx_system_parameters_rec.cash_basis_set_of_books_id := arp_global.sysparam.cash_basis_set_of_books_id;
    trx_system_parameters_rec.code_combination_id_gain := arp_global.sysparam.code_combination_id_gain;
    trx_system_parameters_rec.autocash_hierarchy_id := arp_global.sysparam.autocash_hierarchy_id;
    trx_system_parameters_rec.run_gl_journal_import_flag := arp_global.sysparam.run_gl_journal_import_flag;
    trx_system_parameters_rec.cer_split_amount := arp_global.sysparam.cer_split_amount;
    trx_system_parameters_rec.cer_dso_days := arp_global.sysparam.cer_dso_days;
    trx_system_parameters_rec.posting_days_per_cycle := arp_global.sysparam.posting_days_per_cycle;
    trx_system_parameters_rec.address_validation := arp_global.sysparam.address_validation;
    trx_system_parameters_rec.calc_discount_on_lines_flag := arp_global.sysparam.calc_discount_on_lines_flag;
    trx_system_parameters_rec.change_printed_invoice_flag := arp_global.sysparam.change_printed_invoice_flag;
    trx_system_parameters_rec.code_combination_id_loss := arp_global.sysparam.code_combination_id_loss;
    trx_system_parameters_rec.create_reciprocal_flag := arp_global.sysparam.create_reciprocal_flag;
    trx_system_parameters_rec.default_country := arp_global.sysparam.default_country;
    trx_system_parameters_rec.default_territory := arp_global.sysparam.default_territory;
    trx_system_parameters_rec.generate_customer_number := arp_global.sysparam.generate_customer_number;
    trx_system_parameters_rec.invoice_deletion_flag := arp_global.sysparam.invoice_deletion_flag;
    trx_system_parameters_rec.location_structure_id := arp_global.sysparam.location_structure_id;
    trx_system_parameters_rec.site_required_flag := arp_global.sysparam.site_required_flag;
    trx_system_parameters_rec.tax_allow_compound_flag := arp_global.sysparam.tax_allow_compound_flag;
	trx_system_parameters_rec.tax_header_level_flag := arp_global.sysparam.tax_header_level_flag;
	trx_system_parameters_rec.tax_rounding_allow_override := arp_global.sysparam.tax_rounding_allow_override;
    trx_system_parameters_rec.tax_invoice_print := arp_global.sysparam.tax_invoice_print;
    trx_system_parameters_rec.tax_method := arp_global.sysparam.tax_method;
    trx_system_parameters_rec.tax_use_customer_exempt_flag := arp_global.sysparam.tax_use_customer_exempt_flag;
    trx_system_parameters_rec.tax_use_cust_exc_rate_flag := arp_global.sysparam.tax_use_cust_exc_rate_flag;
    trx_system_parameters_rec.tax_use_loc_exc_rate_flag := arp_global.sysparam.tax_use_loc_exc_rate_flag;
    trx_system_parameters_rec.tax_use_product_exempt_flag := arp_global.sysparam.tax_use_product_exempt_flag;
    trx_system_parameters_rec.tax_use_prod_exc_rate_flag := arp_global.sysparam.tax_use_prod_exc_rate_flag;
    trx_system_parameters_rec.tax_use_site_exc_rate_flag := arp_global.sysparam.tax_use_site_exc_rate_flag;
    trx_system_parameters_rec.ai_log_file_message_level := arp_global.sysparam.ai_log_file_message_level;
    trx_system_parameters_rec.ai_max_memory_in_bytes := arp_global.sysparam.ai_max_memory_in_bytes;
    trx_system_parameters_rec.ai_acct_flex_key_left_prompt := arp_global.sysparam.ai_acct_flex_key_left_prompt;
    trx_system_parameters_rec.ai_mtl_items_key_left_prompt := arp_global.sysparam.ai_mtl_items_key_left_prompt;
    trx_system_parameters_rec.ai_territory_key_left_prompt := arp_global.sysparam.ai_territory_key_left_prompt;
    trx_system_parameters_rec.ai_purge_int_tables_flag := arp_global.sysparam.ai_purge_interface_tables_flag;
    trx_system_parameters_rec.ai_activate_sql_trace_flag := arp_global.sysparam.ai_activate_sql_trace_flag;
    trx_system_parameters_rec.default_grouping_rule_id := arp_global.sysparam.default_grouping_rule_id;
    trx_system_parameters_rec.salesrep_required_flag := arp_global.sysparam.salesrep_required_flag;
    trx_system_parameters_rec.auto_rec_invoices_per_commit := arp_global.sysparam.auto_rec_invoices_per_commit;
    trx_system_parameters_rec.auto_rec_receipts_per_commit := arp_global.sysparam.auto_rec_receipts_per_commit;
    trx_system_parameters_rec.pay_unrelated_invoices_flag := arp_global.sysparam.pay_unrelated_invoices_flag;
    trx_system_parameters_rec.print_home_country_flag := arp_global.sysparam.print_home_country_flag;
    trx_system_parameters_rec.location_tax_account := arp_global.sysparam.location_tax_account;
    trx_system_parameters_rec.from_postal_code := arp_global.sysparam.from_postal_code;
    trx_system_parameters_rec.to_postal_code := arp_global.sysparam.to_postal_code;
    trx_system_parameters_rec.tax_registration_number := arp_global.sysparam.tax_registration_number;
    trx_system_parameters_rec.populate_gl_segments_flag := arp_global.sysparam.populate_gl_segments_flag;
    trx_system_parameters_rec.unallocated_revenue_ccid := arp_global.sysparam.unallocated_revenue_ccid;
    trx_system_parameters_rec.org_id := arp_global.sysparam.org_id;
    trx_system_parameters_rec.base_currency_code := arp_global.functional_currency;
    trx_system_parameters_rec.chart_of_accounts_id := arp_global.chart_of_accounts_id;
    trx_system_parameters_rec.period_set_name := arp_global.period_set_name;
--    trx_system_parameters_rec.short_name := arp_global.sysparam.short_name;
    trx_system_parameters_rec.precision := arp_global.base_precision;
--    trx_system_parameters_rec.EXTENDED_PRECISION := arp_global.sysparam.extended_precision;
    trx_system_parameters_rec.MINIMUM_ACCOUNTABLE_UNIT := arp_global.base_min_acc_unit;
--    trx_system_parameters_rec.yes_meaning := l_yes_meaning;
--    trx_system_parameters_rec.no_meaning := l_no_meaning;
    trx_system_parameters_rec.inclusive_tax_used := arp_global.sysparam.inclusive_tax_used;
    trx_system_parameters_rec.tax_enforce_account_flag := arp_global.sysparam.tax_enforce_account_flag;
    trx_system_parameters_rec.ta_installed_flag := arp_global.sysparam.ta_installed_flag;
    trx_system_parameters_rec.br_enabled_flag := arp_global.sysparam.bills_receivable_enabled_flag;
    trx_system_parameters_rec.DOCUMENT_SEQ_GEN_LEVEL := arp_global.sysparam.DOCUMENT_SEQ_GEN_LEVEL;
    trx_system_parameters_rec.trx_header_level_rounding := arp_global.sysparam.trx_header_level_rounding;

    p_trx_system_parameters_rec := trx_system_parameters_rec;
    IF pg_debug = 'Y'
    THEN
        ar_invoice_utils.debug ('AR_INVOICE_DEFAULT_PVT.Get_system_parameters(-)' );
    END IF;

    EXCEPTION
            WHEN OTHERS THEN
                x_errmsg := 'Error in AR_INVOICE_DEFAULT_PVT.Get_system_parameters '||sqlerrm;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                return;

END;
PROCEDURE Get_profile_values(
        p_trx_profile_rec           OUT NOCOPY trx_profile_rec_type,
        x_errmsg                    OUT NOCOPY  VARCHAR2,
        x_return_status             OUT NOCOPY  VARCHAR2)  IS
    l_profile_value                 varchar2(240);
    l_result                        boolean;
    l_dummy                         varchar2(240);
    l_user_conversion_type	        VARCHAR2(30);
    l_user_profile_option_name      VARCHAR2(240);

BEGIN
       --- Get profile options
    IF pg_debug = 'Y'
    THEN
        ar_invoice_utils.debug ('AR_INVOICE_DEFAULT_PVT.Get_profile_values(+)' );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

       trx_profile_rec.ar_unique_seq_numbers :=  fnd_profile.value('UNIQUE:SEQ_NUMBERS');

       /* 4743228 - swap AR to ZX profiles for etax */
       trx_profile_rec.ar_allow_manual_tax_lines := fnd_profile.value('ZX_ALLOW_MANUAL_TAX_LINES');
       trx_profile_rec.ar_allow_tax_code_override := fnd_profile.value('ZX_ALLOW_TAX_CLASSIF_OVERRIDE');
       trx_profile_rec.ar_allow_trx_line_exemptions := fnd_profile.value('ZX_ALLOW_TRX_LINE_EXEMPTIONS');
       /* 4743228 - end */

       trx_profile_rec.ar_batch_source := fnd_profile.value('AR_BATCH_SOURCE');
       trx_profile_rec.ar_ra_batch_source := fnd_profile.value('AR_RA_BATCH_SOURCE');
       trx_profile_rec.ar_update_due_date := fnd_profile.value('AR_UPDATE_DUE_DATE');
       trx_profile_rec.ussgl_option := NVL(fnd_profile.value('USSGL_OPTION'),'N');
       trx_profile_rec.ar_allow_salescredit_update := fnd_profile.value('AR_ALLOW_SALESCREDIT_UPDATE');
       trx_profile_rec.so_organization_id := oe_profile.value('SO_ORGANIZATION_ID');
       trx_profile_rec.so_source_code :=  oe_profile.value('SO_SOURCE_CODE');
       trx_profile_rec.so_id_flex_code := oe_profile.value('SO_ID_FLEX_CODE');
       trx_profile_rec.ar_jg_create_bank_charges := NVL(fnd_profile.value('AR_JG_CREATE_BANK_CHARGES'),'N');


       fnd_profile.get('AR_DEFAULT_EXCHANGE_RATE_TYPE', l_profile_value);
       IF (l_profile_value IS NOT NULL) THEN
        BEGIN
           SELECT user_conversion_type
           INTO l_user_conversion_type
	       FROM GL_DAILY_CONVERSION_TYPES
	       WHERE conversion_type = l_profile_value;

	       SELECT user_profile_option_name
	       INTO l_user_profile_option_name
           FROM FND_PROFILE_OPTIONS_VL
           WHERE application_id = 222
           AND profile_option_name = 'AR_DEFAULT_EXCHANGE_RATE_TYPE';


        EXCEPTION
             WHEN NO_DATA_FOUND THEN
	           l_profile_value := NULL;
	           l_user_conversion_type := NULL;
	           l_user_profile_option_name := NULL;
         END;
       END IF;

       trx_profile_rec.default_exchange_rate_type := l_profile_value;
       trx_profile_rec.default_exchange_rate_type_dsp := l_user_conversion_type;
       trx_profile_rec.def_exchange_rate_type_profile :=  l_user_profile_option_name;

       l_result := fnd_installation.get_app_info('OE',
                                                 l_profile_value,
                                                 l_dummy,
                                                 l_dummy);

       trx_profile_rec.so_installed_flag := l_profile_value;


      -- IF (p_mode <> 'RECEIPTS')
      -- THEN
            IF    ( arp_auto_accounting.query_autoacc_def('REV', 'RA_SALESREPS') = TRUE )
            THEN
                trx_profile_rec.rev_based_on_srep_flag := 'Y';
            ELSE
                trx_profile_rec.rev_based_on_srep_flag := 'N';
            END IF;

            IF    ( arp_auto_accounting.query_autoacc_def('ALL', 'RA_SALESREPS') = TRUE )
            THEN
                trx_profile_rec.autoacc_based_on_srep_flag := 'Y';
            ELSE
                trx_profile_rec.autoacc_based_on_srep_flag := 'N';
            END IF;

            IF    (
                      arp_auto_accounting.query_autoacc_def('FREIGHT', 'RA_SALESREPS') = TRUE
                   OR arp_auto_accounting.query_autoacc_def('REC', 'RA_SALESREPS') = TRUE
                  )
            THEN
                trx_profile_rec.autoacc_based_on_primary_srep := 'Y';
            ELSE
                trx_profile_rec.autoacc_based_on_primary_srep := 'N';
            END IF;

            IF    ( arp_auto_accounting.query_autoacc_def('REV', 'AGREEMENT/CATEGORY') = TRUE )
            THEN
                trx_profile_rec.autoacc_based_on_agree_cat := 'Y';
            ELSE
                trx_profile_rec.autoacc_based_on_agree_cat := 'N';
            END IF;


            IF    ( arp_auto_accounting.query_autoacc_def('ALL', 'RA_CUST_TRX_TYPES') = TRUE )
            THEN
                trx_profile_rec.autoacc_based_on_type_flag := 'Y';
            ELSE
                trx_profile_rec.autoacc_based_on_type_flag := 'N';
            END IF;

            IF    ( arp_auto_accounting.query_autoacc_def('ALL', 'RA_STD_TRX_LINES') = TRUE )
            THEN
                trx_profile_rec.autoacc_based_on_item_flag := 'Y';
            ELSE
                trx_profile_rec.autoacc_based_on_item_flag := 'N';
            END IF;

            IF    ( arp_auto_accounting.query_autoacc_def('TAX', 'RA_TAXES') = TRUE )
            THEN
                trx_profile_rec.autoacc_based_on_tax_code := 'Y';
            ELSE
                trx_profile_rec.autoacc_based_on_tax_code := 'N';
            END IF;

	        IF  ( arp_auto_accounting.query_autoacc_def('ALL', 'RA_SITE_USES') = TRUE )
            THEN
                trx_profile_rec.autoacc_based_on_site_flag := 'Y';
            ELSE
                trx_profile_rec.autoacc_based_on_site_flag := 'N';
            END IF;



          p_trx_profile_rec := trx_profile_rec;
    IF pg_debug = 'Y'
    THEN
        ar_invoice_utils.debug ('AR_INVOICE_DEFAULT_PVT.Get_profile_values(-)' );
    END IF;
   EXCEPTION
	WHEN OTHERS
	THEN
                x_errmsg := 'Error in AR_INVOICE_DEFAULT_PVT.Get_profile_values '||sqlerrm;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		        return;

END;



procedure ar_common_init( p_code_combination_id_gain in number ) is
l_ar_receipt_multi_curr_flag    varchar2(1);
begin
       IF (p_code_combination_id_gain IS NULL) THEN
         trx_system_parameters_rec.ar_multi_currency_flag := 'N';
         trx_system_parameters_rec.ar_receipt_multi_currency_flag := 'N';
       ELSE
         trx_system_parameters_rec.ar_multi_currency_flag := 'Y';
         trx_system_parameters_rec.ar_receipt_multi_currency_flag := 'Y';
       END IF;
end ar_common_init;





PROCEDURE Default_gl_date IS

l_error_message        VARCHAR2(128);
l_defaulting_rule_used VARCHAR2(50);
l_default_gl_date      DATE;

/* 5921925 - Added post_to_gl logic so headers are skipped
    if they are not supposed to post to gl */
CURSOR ar_invoice_gt_c IS
    SELECT nvl(hdr.trx_date, sysdate) trx_date, hdr.set_of_books_id,
           hdr.trx_header_id
    FROM ar_trx_header_gt  hdr,
         ra_cust_trx_types tt
    WHERE gl_date IS NULL
    AND   hdr.cust_trx_type_id = tt.cust_trx_type_id
    AND   NVL(tt.post_to_gl,'N') = 'Y';

BEGIN
  IF pg_debug = 'Y'
  THEN
        ar_invoice_utils.debug ('AR_INVOICE_DEFAULT_PVT.Default_gl_date(+)' );
  END IF;
  FOR ar_invoice_gt_rec IN ar_invoice_gt_c
  LOOP
     IF (arp_util.validate_and_default_gl_date(
                ar_invoice_gt_rec.trx_date,
                NULL,
                NULL,
                NULL,
                NULL,
                ar_invoice_gt_rec.trx_date,
                NULL,
                NULL,
                'N',
                NULL,
                ar_invoice_gt_rec.set_of_books_id,
                222,
                l_default_gl_date,
                l_defaulting_rule_used,
                l_error_message) = TRUE)
     THEN
      IF pg_debug = 'Y'
      THEN
        ar_invoice_utils.debug ('Default GL Date ' || l_default_gl_date);
      END IF;

      UPDATE ar_trx_header_gt
        SET  gl_date = l_default_gl_date
      WHERE trx_header_id = ar_invoice_gt_rec.trx_header_id;

      UPDATE ar_trx_dist_gt
        SET gl_date = l_default_gl_date
      WHERE trx_header_id = ar_invoice_gt_rec.trx_header_id
        AND  gl_date is null;

     END IF;
  END LOOP;
  IF pg_debug = 'Y'
  THEN
        ar_invoice_utils.debug ('AR_INVOICE_DEFAULT_PVT.Default_gl_date(-)' );
  END IF;
END default_gl_date;

END;

/
