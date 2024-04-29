--------------------------------------------------------
--  DDL for Package Body AR_MO_GLOBAL_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_MO_GLOBAL_CACHE" as
/*$Header: ARMOGLCB.pls 120.11.12010000.3 2008/12/16 10:56:03 nproddut ship $ */
 PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

  /* ----------------------------------------------------------------------------
     This index-by table is used to store rows of operating unit
     attributes.
     ----------------------------------------------------------------------------- */

      TYPE GlobalsCache IS TABLE OF ar_mo_cache_utils.GlobalsRecord  INDEX BY BINARY_INTEGER;

   /* ---------------------------------------------------------------------------
      This private variable is used as the cache.
      ---------------------------------------------------------------------------  */
       g_cache GlobalsCache;

   /* ---------------------------------------------------------------------------
      This procedure retrieves operating unit attributes and
      stores them in the cache.
      ---------------------------------------------------------------------------  */

     PROCEDURE  populate(p_org_id IN NUMBER DEFAULT NULL) IS
        i    PLS_INTEGER;
        l_gt  ar_mo_cache_utils.GlobalsTable;

        l_count              PLS_INTEGER;
        l_default_org_id     NUMBER;
        l_default_ou_name    mo_glob_org_access_tmp.organization_name%type;      --Bug Fix 6814490

   BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('get_org_attributes: ' || 'ar_mo_global_cache.populate()+');
    END IF;

   IF p_org_id is not null and g_cache.exists(p_org_id) THEN
     RETURN;
   END IF;

   /* ---------------------------------------------------------------------------
        First, remove existing records (if any):
      ---------------------------------------------------------------------------  */
        g_cache.delete;

   /* ---------------------------------------------------------------------------
      Next, get the data from the server:
      ---------------------------------------------------------------------------  */

           ar_mo_cache_utils.retrieve_globals(l_gt,p_org_id);

   /* ---------------------------------------------------------------------------
       Finally, store the data in the cache:
      ---------------------------------------------------------------------------  */

    FOR i IN 1..l_gt.org_id_t.LAST LOOP
      g_cache(l_gt.org_id_t(i)).chart_of_accounts_id := l_gt.chart_of_accounts_id_t(i);
      g_cache(l_gt.org_id_t(i)).set_of_books_id      := l_gt.set_of_books_id_t(i);
      g_cache(l_gt.org_id_t(i)).set_of_books_name    := l_gt.set_of_books_name_t(i);
      g_cache(l_gt.org_id_t(i)).currency_code        := l_gt.currency_code_t(i);
      g_cache(l_gt.org_id_t(i)).org_id               := l_gt.org_id_t(i);

     /*-----------------------------------------------------------------------------
        Begin AR-specific assignments
       -----------------------------------------------------------------------------*/
      g_cache(l_gt.org_id_t(i)).accounting_method        := l_gt.accounting_method_t(i);
      g_cache(l_gt.org_id_t(i)).accrue_interest	         := l_gt.accrue_interest_t(i);
      g_cache(l_gt.org_id_t(i)).unearned_discount 	 := l_gt.unearned_discount_t(i);
      g_cache(l_gt.org_id_t(i)).partial_discount_flag  	 := l_gt.partial_discount_flag_t(i);
      g_cache(l_gt.org_id_t(i)).print_remit_to    	 := l_gt.print_remit_to_t(i);
      g_cache(l_gt.org_id_t(i)).default_cb_due_date  	 := l_gt.default_cb_due_date_t(i);
      g_cache(l_gt.org_id_t(i)).auto_site_numbering 	 := l_gt.auto_site_numbering_t(i);

      g_cache(l_gt.org_id_t(i)).cash_basis_set_of_books_id := l_gt.cash_basis_set_of_books_id_t(i);
      g_cache(l_gt.org_id_t(i)).code_combination_id_gain   := l_gt.code_combination_id_gain_t(i);
      g_cache(l_gt.org_id_t(i)).autocash_hierarchy_id      := l_gt.autocash_hierarchy_id_t(i);
      g_cache(l_gt.org_id_t(i)).run_gl_journal_import_flag := l_gt.run_gl_journal_import_flag_t(i);
      g_cache(l_gt.org_id_t(i)).cer_split_amount           := l_gt.cer_split_amount_t(i);
      g_cache(l_gt.org_id_t(i)).cer_dso_days 	           := l_gt.cer_dso_days_t(i);
      g_cache(l_gt.org_id_t(i)).posting_days_per_cycle     := l_gt.posting_days_per_cycle_t(i);
      g_cache(l_gt.org_id_t(i)).address_validation 	   := l_gt.address_validation_t(i);
      g_cache(l_gt.org_id_t(i)).calc_discount_on_lines_flag:= l_gt.calc_discount_on_lines_flag_t(i);
      g_cache(l_gt.org_id_t(i)).change_printed_invoice_flag:= l_gt.change_printed_invoice_flag_t(i);

      g_cache(l_gt.org_id_t(i)).code_combination_id_loss   := l_gt.code_combination_id_loss_t(i);
      g_cache(l_gt.org_id_t(i)).create_reciprocal_flag     := l_gt.create_reciprocal_flag_t(i);
      g_cache(l_gt.org_id_t(i)).default_country   	   := l_gt.default_country_t(i);
      g_cache(l_gt.org_id_t(i)).default_territory 	   := l_gt.default_territory_t(i);
      g_cache(l_gt.org_id_t(i)).generate_customer_number   := l_gt.generate_customer_number_t(i);
      g_cache(l_gt.org_id_t(i)).invoice_deletion_flag      := l_gt.invoice_deletion_flag_t(i);
      g_cache(l_gt.org_id_t(i)).location_structure_id      := l_gt.location_structure_id_t(i);
      g_cache(l_gt.org_id_t(i)).site_required_flag	   := l_gt.site_required_flag_t(i);
      g_cache(l_gt.org_id_t(i)).tax_allow_compound_flag    := l_gt.tax_allow_compound_flag_t(i);
      g_cache(l_gt.org_id_t(i)).tax_header_level_flag      := l_gt.tax_header_level_flag_t(i);

      g_cache(l_gt.org_id_t(i)).tax_rounding_allow_override  := l_gt.tax_rounding_allow_override_t(i);
      g_cache(l_gt.org_id_t(i)).tax_invoice_print            := l_gt.tax_invoice_print_t(i);
      g_cache(l_gt.org_id_t(i)).tax_method  	             := l_gt.tax_method_t(i);
      g_cache(l_gt.org_id_t(i)).tax_use_customer_exempt_flag := l_gt.tax_use_customer_exempt_flag_t(i);
      g_cache(l_gt.org_id_t(i)).tax_use_cust_exc_rate_flag   := l_gt.tax_use_cust_exc_rate_flag_t(i);
      g_cache(l_gt.org_id_t(i)).tax_use_loc_exc_rate_flag    := l_gt.tax_use_loc_exc_rate_flag_t(i);
      g_cache(l_gt.org_id_t(i)).tax_use_product_exempt_flag  := l_gt.tax_use_product_exempt_flag_t(i);
      g_cache(l_gt.org_id_t(i)).tax_use_prod_exc_rate_flag   := l_gt.tax_use_prod_exc_rate_flag_t(i);
      g_cache(l_gt.org_id_t(i)).tax_use_site_exc_rate_flag   := l_gt.tax_use_site_exc_rate_flag_t(i);
      g_cache(l_gt.org_id_t(i)).ai_log_file_message_level    := l_gt.ai_log_file_message_level_t(i);
      g_cache(l_gt.org_id_t(i)).ai_max_memory_in_bytes       := l_gt.ai_max_memory_in_bytes_t(i);
      g_cache(l_gt.org_id_t(i)).ai_acct_flex_key_left_prompt := l_gt.ai_acct_flex_key_left_prompt_t(i);
      g_cache(l_gt.org_id_t(i)).ai_mtl_items_key_left_prompt := l_gt.ai_mtl_items_key_left_prompt_t(i);
      g_cache(l_gt.org_id_t(i)).ai_territory_key_left_prompt := l_gt.ai_territory_key_left_prompt_t(i);
      g_cache(l_gt.org_id_t(i)).ai_purge_int_tables_flag     := l_gt.ai_purge_int_tables_flag_t(i);
      g_cache(l_gt.org_id_t(i)).ai_activate_sql_trace_flag   := l_gt.ai_activate_sql_trace_flag_t(i);
      g_cache(l_gt.org_id_t(i)).default_grouping_rule_id     := l_gt.default_grouping_rule_id_t(i);
      g_cache(l_gt.org_id_t(i)).salesrep_required_flag       := l_gt.salesrep_required_flag_t(i);
      g_cache(l_gt.org_id_t(i)).auto_rec_invoices_per_commit := l_gt.auto_rec_invoices_per_commit_t(i);
      g_cache(l_gt.org_id_t(i)).auto_rec_receipts_per_commit := l_gt.auto_rec_receipts_per_commit_t(i);
      g_cache(l_gt.org_id_t(i)).pay_unrelated_invoices_flag  := l_gt.pay_unrelated_invoices_flag_t(i);

      g_cache(l_gt.org_id_t(i)).print_home_country_flag  := l_gt.print_home_country_flag_t(i);
      g_cache(l_gt.org_id_t(i)).location_tax_account     := l_gt.location_tax_account_t(i);
      g_cache(l_gt.org_id_t(i)).from_postal_code  	 := l_gt.from_postal_code_t(i);
      g_cache(l_gt.org_id_t(i)).to_postal_code   	 := l_gt.to_postal_code_t(i);
      g_cache(l_gt.org_id_t(i)).tax_registration_number  := l_gt.tax_registration_number_t(i);
      g_cache(l_gt.org_id_t(i)).populate_gl_segments_flag:= l_gt.populate_gl_segments_flag_t(i);
      g_cache(l_gt.org_id_t(i)).unallocated_revenue_ccid := l_gt.unallocated_revenue_ccid_t(i);
      g_cache(l_gt.org_id_t(i)).period_set_name   	 := l_gt.period_set_name_t(i);
      g_cache(l_gt.org_id_t(i)).base_precision   	 := l_gt.base_precision_t(i);
      g_cache(l_gt.org_id_t(i)).base_EXTENDED_PRECISION  := l_gt.base_EXTENDED_PRECISION_t(i);
      g_cache(l_gt.org_id_t(i)).base_MIN_ACCOUNTABLE_UNIT:= l_gt.base_MIN_ACCOUNTABLE_UNIT_t(i);
      g_cache(l_gt.org_id_t(i)).salescredit_name         := l_gt.salescredit_name_t(i);
      g_cache(l_gt.org_id_t(i)).yes_meaning 	         := l_gt.yes_meaning_t(i);
      g_cache(l_gt.org_id_t(i)).no_meaning  	         := l_gt.no_meaning_t(i);
      g_cache(l_gt.org_id_t(i)).tax_exempt_flag_meaning  := l_gt.tax_exempt_flag_meaning_t(i);
      g_cache(l_gt.org_id_t(i)).inclusive_tax_used	 := l_gt.inclusive_tax_used_t(i);
      g_cache(l_gt.org_id_t(i)).tax_enforce_account_flag := l_gt.tax_enforce_account_flag_t(i);
      g_cache(l_gt.org_id_t(i)).ta_installed_flag 	 := l_gt.ta_installed_flag_t(i);
      g_cache(l_gt.org_id_t(i)).br_enabled_flag   	 := l_gt.br_enabled_flag_t(i);

-- new begin

      g_cache(l_gt.org_id_t(i)).attribute_category:= l_gt.attribute_category_t(i);
      g_cache(l_gt.org_id_t(i)).attribute1	  := l_gt.attribute1_t(i);
      g_cache(l_gt.org_id_t(i)).attribute2	  := l_gt.attribute2_t(i);
      g_cache(l_gt.org_id_t(i)).attribute3	  := l_gt.attribute3_t(i);
      g_cache(l_gt.org_id_t(i)).attribute4	  := l_gt.attribute4_t(i);
      g_cache(l_gt.org_id_t(i)).attribute5	  := l_gt.attribute5_t(i);
      g_cache(l_gt.org_id_t(i)).attribute6	  := l_gt.attribute6_t(i);
      g_cache(l_gt.org_id_t(i)).attribute7	  := l_gt.attribute7_t(i);
      g_cache(l_gt.org_id_t(i)).attribute8	  := l_gt.attribute8_t(i);
      g_cache(l_gt.org_id_t(i)).attribute9	  := l_gt.attribute9_t(i);
      g_cache(l_gt.org_id_t(i)).attribute10	  := l_gt.attribute10_t(i);
      g_cache(l_gt.org_id_t(i)).attribute11	  := l_gt.attribute11_t(i);
      g_cache(l_gt.org_id_t(i)).attribute12	  := l_gt.attribute12_t(i);
      g_cache(l_gt.org_id_t(i)).attribute13	  := l_gt.attribute13_t(i);
      g_cache(l_gt.org_id_t(i)).attribute14	  := l_gt.attribute14_t(i);
      g_cache(l_gt.org_id_t(i)).attribute15	  := l_gt.attribute15_t(i);

      g_cache(l_gt.org_id_t(i)).created_by	  := l_gt.created_by_t(i);
      g_cache(l_gt.org_id_t(i)).creation_date	  := l_gt.creation_date_t(i);
      g_cache(l_gt.org_id_t(i)).last_updated_by	  := l_gt.last_updated_by_t(i);
      g_cache(l_gt.org_id_t(i)).last_update_date  := l_gt.last_update_date_t(i);
      g_cache(l_gt.org_id_t(i)).last_update_login := l_gt.last_update_login_t(i);

      g_cache(l_gt.org_id_t(i)).tax_code	            := l_gt.tax_code_t(i);
      g_cache(l_gt.org_id_t(i)).tax_currency_code           := l_gt.tax_currency_code_t(i);
      g_cache(l_gt.org_id_t(i)).tax_minimum_accountable_unit:= l_gt.tax_minimum_accountable_unit_t(i);
      g_cache(l_gt.org_id_t(i)).tax_precision	            := l_gt.tax_precision_t(i);
      g_cache(l_gt.org_id_t(i)).tax_rounding_rule           := l_gt.tax_rounding_rule_t(i);
      g_cache(l_gt.org_id_t(i)).tax_use_acc_exc_rate_flag   := l_gt.tax_use_acc_exc_rate_flag_t(i);
      g_cache(l_gt.org_id_t(i)).tax_use_system_exc_rate_flag:= l_gt.tax_use_system_exc_rate_flag_t(i);
      g_cache(l_gt.org_id_t(i)).tax_hier_site_exc_rate	    := l_gt.tax_hier_site_exc_rate_t(i);
      g_cache(l_gt.org_id_t(i)).tax_hier_cust_exc_rate	    := l_gt.tax_hier_cust_exc_rate_t(i);
      g_cache(l_gt.org_id_t(i)).tax_hier_prod_exc_rate	    := l_gt.tax_hier_prod_exc_rate_t(i);
      g_cache(l_gt.org_id_t(i)).tax_hier_account_exc_rate   := l_gt.tax_hier_account_exc_rate_t(i);
      g_cache(l_gt.org_id_t(i)).tax_hier_system_exc_rate    := l_gt.tax_hier_system_exc_rate_t(i);
      g_cache(l_gt.org_id_t(i)).tax_database_view_set	    := l_gt.tax_database_view_set_t(i);

      g_cache(l_gt.org_id_t(i)).global_attribute1	  := l_gt.global_attribute1_t(i);
      g_cache(l_gt.org_id_t(i)).global_attribute2	  := l_gt.global_attribute2_t(i);
      g_cache(l_gt.org_id_t(i)).global_attribute3	  := l_gt.global_attribute3_t(i);
      g_cache(l_gt.org_id_t(i)).global_attribute4	  := l_gt.global_attribute4_t(i);
      g_cache(l_gt.org_id_t(i)).global_attribute5	  := l_gt.global_attribute5_t(i);
      g_cache(l_gt.org_id_t(i)).global_attribute6	  := l_gt.global_attribute6_t(i);
      g_cache(l_gt.org_id_t(i)).global_attribute7	  := l_gt.global_attribute7_t(i);
      g_cache(l_gt.org_id_t(i)).global_attribute8	  := l_gt.global_attribute8_t(i);
      g_cache(l_gt.org_id_t(i)).global_attribute9	  := l_gt.global_attribute9_t(i);
      g_cache(l_gt.org_id_t(i)).global_attribute10	  := l_gt.global_attribute10_t(i);
      g_cache(l_gt.org_id_t(i)).global_attribute11	  := l_gt.global_attribute11_t(i);
      g_cache(l_gt.org_id_t(i)).global_attribute12	  := l_gt.global_attribute12_t(i);
      g_cache(l_gt.org_id_t(i)).global_attribute13	  := l_gt.global_attribute13_t(i);
      g_cache(l_gt.org_id_t(i)).global_attribute14	  := l_gt.global_attribute14_t(i);
      g_cache(l_gt.org_id_t(i)).global_attribute15	  := l_gt.global_attribute15_t(i);
      g_cache(l_gt.org_id_t(i)).global_attribute16	  := l_gt.global_attribute16_t(i);
      g_cache(l_gt.org_id_t(i)).global_attribute17	  := l_gt.global_attribute17_t(i);
      g_cache(l_gt.org_id_t(i)).global_attribute18	  := l_gt.global_attribute18_t(i);
      g_cache(l_gt.org_id_t(i)).global_attribute19	  := l_gt.global_attribute19_t(i);
      g_cache(l_gt.org_id_t(i)).global_attribute20	  := l_gt.global_attribute20_t(i);
      g_cache(l_gt.org_id_t(i)).global_attribute_category := l_gt.global_attribute_category_t(i);

      g_cache(l_gt.org_id_t(i)).rule_set_id	             := l_gt.rule_set_id_t(i);
      g_cache(l_gt.org_id_t(i)).code_combination_id_round    := l_gt.code_combination_id_round_t(i);
      g_cache(l_gt.org_id_t(i)).trx_header_level_rounding    := l_gt.trx_header_level_rounding_t(i);
      g_cache(l_gt.org_id_t(i)).trx_header_round_ccid	     := l_gt.trx_header_round_ccid_t(i);
      g_cache(l_gt.org_id_t(i)).finchrg_receivables_trx_id   := l_gt.finchrg_receivables_trx_id_t(i);
      g_cache(l_gt.org_id_t(i)).sales_tax_geocode	     := l_gt.sales_tax_geocode_t(i);
      g_cache(l_gt.org_id_t(i)).rev_transfer_clear_ccid	     := l_gt.rev_transfer_clear_ccid_t(i);
      g_cache(l_gt.org_id_t(i)).sales_credit_pct_limit	     := l_gt.sales_credit_pct_limit_t(i);
      g_cache(l_gt.org_id_t(i)).max_wrtoff_amount	     := l_gt.max_wrtoff_amount_t(i);
      g_cache(l_gt.org_id_t(i)).irec_cc_receipt_method_id    := l_gt.irec_cc_receipt_method_id_t(i);
      g_cache(l_gt.org_id_t(i)).show_billing_number_flag     := l_gt.show_billing_number_flag_t(i);
      g_cache(l_gt.org_id_t(i)).cross_currency_rate_type     := l_gt.cross_currency_rate_type_t(i);
      g_cache(l_gt.org_id_t(i)).document_seq_gen_level	     := l_gt.document_seq_gen_level_t(i);
      g_cache(l_gt.org_id_t(i)).calc_tax_on_credit_memo_flag := l_gt.calc_tax_on_credit_memo_flag_t(i);
      g_cache(l_gt.org_id_t(i)).irec_ba_receipt_method_id    := l_gt.irec_ba_receipt_method_id_t(i);
      g_cache(l_gt.org_id_t(i)).tm_installed_flag            := l_gt.tm_installed_flag_t(i);
      g_cache(l_gt.org_id_t(i)).tm_default_setup_flag        := l_gt.tm_default_setup_flag_t(i);
      g_cache(l_gt.org_id_t(i)).payment_threshold            := l_gt.payment_threshold_t(i);
      g_cache(l_gt.org_id_t(i)).standard_refund              := l_gt.standard_refund_t(i);
      g_cache(l_gt.org_id_t(i)).credit_classification1       := l_gt.credit_classification1_t(i);
      g_cache(l_gt.org_id_t(i)).credit_classification2       := l_gt.credit_classification2_t(i);
      g_cache(l_gt.org_id_t(i)).credit_classification3       := l_gt.credit_classification3_t(i);
      g_cache(l_gt.org_id_t(i)).unmtch_claim_creation_flag   := l_gt.unmtch_claim_creation_flag_t(i);
      g_cache(l_gt.org_id_t(i)).matched_claim_creation_flag  := l_gt.matched_claim_creation_flag_t(i);
      g_cache(l_gt.org_id_t(i)).matched_claim_excl_cm_flag   := l_gt.matched_claim_excl_cm_flag_t(i);
      g_cache(l_gt.org_id_t(i)).min_wrtoff_amount            := l_gt.min_wrtoff_amount_t(i);
      g_cache(l_gt.org_id_t(i)).min_refund_amount            := l_gt.min_refund_amount_t(i);
      g_cache(l_gt.org_id_t(i)).create_detailed_dist_flag    := l_gt.create_detailed_dist_flag_t(i);


--new end

    /* --------------------------------------------------------------------------
        End AR-specific assignments
       --------------------------------------------------------------------------- */
     END LOOP;

    /* --------------------------------------------------------------------------
          First, get the default org_id from MO: Default Operating Unit
          and populate g_current_org_id
       --------------------------------------------------------------------------- */

       mo_utils.get_default_ou(l_default_org_id,l_default_ou_name,l_count);
       ar_mo_global_cache.set_current_org_id(l_default_org_id);

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('get_org_attributes: ' || 'ar_mo_global_cache.populate()-');
   END IF;

   END populate;

    /* --------------------------------------------------------------------------
       This function returns one row of cached data.
       --------------------------------------------------------------------------- */

        FUNCTION get_org_attributes(p_org_id  NUMBER)
                RETURN ar_mo_cache_utils.GlobalsRecord is
        l_exp_flag   varchar2(1);
       BEGIN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug('ar_mo_global_cache.get_org_attributes()');
            END IF;
       --Bug 4517382 : On demand caching of OU information.
          IF NOT(g_cache.exists(p_org_id))  THEN
             ar_mo_global_cache.populate(p_org_id);
          END IF;

            RETURN g_cache(p_org_id);
       EXCEPTION
            WHEN no_data_found THEN
                 -- Through an exception, org id attribute that you
                 -- are trying to retrieve is not cached ever
            /* ---------------------------------------------
               Check row exists in ar_system_parameter
               ---------------------------------------------- */
               begin
                  SELECT 'x' into l_exp_flag
                  from ar_system_parameters
                  where org_id = p_org_id;
               exception
                   WHEN NO_DATA_FOUND THEN
                     IF PG_DEBUG in ('Y', 'C') THEN
                        arp_util.debug('get_org_attributes: ' || 'EXCEPTION: NO_DATA_FOUND IN SYSTEM PARAMETERS
                                      - ar_mo_global_cache.get_org_attributes' );
                     END IF;
                     FND_MESSAGE.set_name('AR','AR_NO_ROW_IN_SYSTEM_PARAMETERS');
                     APP_EXCEPTION.raise_exception;
                     RAISE;
               end;
            /* ---------------------------------------------
               Check row exists in gl sets of books
               ---------------------------------------------- */
               begin
                   SELECT 'x' into l_exp_flag
                   from ar_system_parameters sp,
                        gl_sets_of_books sob
                   where sob.set_of_books_id = sp.set_of_books_id
                         and sp.org_id = p_org_id;
               exception
                  when no_data_found then
                      IF PG_DEBUG in ('Y', 'C') THEN
                         arp_util.debug('get_org_attributes: ' || 'EXCEPTION: NO_DATA_FOUND IN SET OF BOOKS
                                       -  ar_mo_global_cache.get_org_attributes' );
                      END IF;
                      FND_MESSAGE.set_name('AR','AR_NO_ROW_IN_GL_SET_OF_BOOKS');
                      APP_EXCEPTION.raise_exception;
                      RAISE;
               end;
             /* ---------------------------------------------
                Check row exists in fnd_currencies
                ---------------------------------------------- */
               begin
                      SELECT 'x' into l_exp_flag
                      FROM   ar_system_parameters sp,
                             gl_sets_of_books sob,
                             fnd_currencies c
                      WHERE  sob.set_of_books_id = sp.set_of_books_id
                             and sp.org_id =  p_org_id
                             and  sob.currency_code = c.currency_code;
               exception
                    when no_data_found then
                         IF PG_DEBUG in ('Y', 'C') THEN
                            arp_util.debug('get_org_attributes: ' || 'EXCEPTION: NO_DATA_FOUND IN CURRENCIES
                                         - ar_mo_global_cache.get_org_attributes' );
                         END IF;
                         FND_MESSAGE.set_name('AR','AR_NO_ROW_IN_FND_CURRENCIES');
                         APP_EXCEPTION.raise_exception;
                         RAISE;
               end;
             WHEN value_error THEN
                  RETURN null;
       END get_org_attributes;

    /* --------------------------------------------------------------------------
       This function returns current context org_id .
       --------------------------------------------------------------------------- */

       FUNCTION get_current_org_id
                RETURN number is
       BEGIN
            arp_util.debug('ar_mo_global_cache.get_current_org_id()');
            RETURN ar_mo_global_cache.g_current_org_id ;
       END get_current_org_id;


    /* --------------------------------------------------------------------------
       This procedure set the current org_id
       --------------------------------------------------------------------------- */

        PROCEDURE set_current_org_id(p_org_id number) is
        BEGIN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug('ar_mo_global_cache.set_current_org_id()');
            END IF;
            ar_mo_global_cache.g_current_org_id  :=p_org_id;
        END set_current_org_id;

END ar_mo_global_cache;

/
