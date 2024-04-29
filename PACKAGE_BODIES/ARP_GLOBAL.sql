--------------------------------------------------------
--  DDL for Package Body ARP_GLOBAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_GLOBAL" AS
/*$Header: ARCUGLBB.pls 120.6.12010000.2 2008/11/05 06:22:43 ankuagar ship $*/

   l_sob_test   gl_sets_of_books.set_of_books_id%type; --temp variable for error testing

   --
PROCEDURE INIT_GLOBAL(p_org_id number default null) IS
  l_gr                 ar_mo_cache_utils.GlobalsRecord;
  l_count              PLS_INTEGER;
  l_default_org_id     NUMBER;
  l_default_ou_name    mo_glob_org_access_tmp.organization_name%type;      --Bug Fix 6814490

BEGIN
   --
   arp_util.debug( 'arp_global.init_global()+' );
   --
   user_id := nvl(FND_GLOBAL.user_id,-1);
   created_by := nvl(FND_GLOBAL.user_id,-1);
   creation_date := SYSDATE;
   last_updated_by := nvl(FND_GLOBAL.user_id,-1);
   last_update_date := SYSDATE;
   last_update_login := nvl(FND_GLOBAL.conc_login_id,FND_GLOBAL.login_id);
   --
   IF ( FND_GLOBAL.conc_request_id = -1 ) OR
      ( FND_GLOBAL.conc_request_id IS NULL )
   THEN
      request_id := NULL;
   ELSE
      request_id := FND_GLOBAL.conc_request_id;
   END IF;
   --
   IF ( FND_GLOBAL.conc_program_id = -1 ) OR
      ( FND_GLOBAL.conc_program_id IS NULL )
   THEN
      program_id := NULL;
   ELSE
      program_id := FND_GLOBAL.conc_program_id;
   END IF;
   --
   IF ( FND_GLOBAL.prog_appl_id = -1 ) OR
      ( FND_GLOBAL.prog_appl_id IS NULL )
   THEN
      program_application_id := NULL;
   ELSE
      program_application_id := FND_GLOBAL.prog_appl_id;
   END IF;
   --
   IF ( program_id IS NULL )
   THEN
      program_update_date := NULL;
   ELSE
      program_update_date := SYSDATE;
   END IF;

     --Populate global variable sysparam
       /* --------------------------------------------------------------------------------
          If you pass p_org_id to INIT_GLOBAL it will the set the current org to p_org_id
          else it will get the default org_id based on mo_utils.get_default_ou output
         ---------------------------------------------------------------------------------  */

        IF p_org_id is NOT NULL then
          ar_mo_global_cache.set_current_org_id(p_org_id);
        ELSE
           IF  ARP_STANDARD.sysparm.org_id is NULL then
            mo_utils.get_default_ou(l_default_org_id,l_default_ou_name,l_count);
           ELSE
             l_default_org_id := ARP_STANDARD.sysparm.org_id;
           END IF;

           IF l_default_org_id is null then
            begin
             select min(org_id) into l_default_org_id from ar_system_parameters;
            end;
           end if;
        END IF;

       /* --------------------------------------------------------------------------------
          Get the cached attribute info for the org you pass p_org_id to INIT_GLOBAL into
          Local Variable l_gr
         ---------------------------------------------------------------------------------  */

        l_gr := ar_mo_global_cache.get_org_attributes(nvl(p_org_id,l_default_org_id));

       /* --------------------------------------------------------------------------------
          Begin populate all attribute of global variable, sysparm of ar_system_parameters%rowtype
          from Local Variable, l_gr,  retieved from cache for the passed org
         ---------------------------------------------------------------------------------  */

        ARP_GLOBAL.sysparam.org_id			:= l_gr.org_id;
        ARP_GLOBAL.sysparam.set_of_books_id		:= l_gr.set_of_books_id;
        ARP_GLOBAL.sysparam.accounting_method		:= l_gr.accounting_method;
        ARP_GLOBAL.sysparam.accrue_interest		:= l_gr.accrue_interest;
        ARP_GLOBAL.sysparam.unearned_discount		:= l_gr.unearned_discount;
        ARP_GLOBAL.sysparam.partial_discount_flag	:= l_gr.partial_discount_flag;
        ARP_GLOBAL.sysparam.print_remit_to		:= l_gr.print_remit_to;
        ARP_GLOBAL.sysparam.default_cb_due_date	:= l_gr.default_cb_due_date;
        ARP_GLOBAL.sysparam.auto_site_numbering	:= l_gr.auto_site_numbering;
        ARP_GLOBAL.sysparam.cash_basis_set_of_books_id	:= l_gr.cash_basis_set_of_books_id;
        ARP_GLOBAL.sysparam.code_combination_id_gain	:= l_gr.code_combination_id_gain;
        ARP_GLOBAL.sysparam.autocash_hierarchy_id	:= l_gr.autocash_hierarchy_id;
        ARP_GLOBAL.sysparam.run_gl_journal_import_flag	:= l_gr.run_gl_journal_import_flag;
        ARP_GLOBAL.sysparam.cer_split_amount		:= l_gr.cer_split_amount;
        ARP_GLOBAL.sysparam.cer_dso_days		:= l_gr.cer_dso_days;

        ARP_GLOBAL.sysparam.posting_days_per_cycle	:= l_gr.posting_days_per_cycle;
        ARP_GLOBAL.sysparam.address_validation		:= l_gr.address_validation;
        ARP_GLOBAL.sysparam.calc_discount_on_lines_flag:= l_gr.calc_discount_on_lines_flag;
        ARP_GLOBAL.sysparam.change_printed_invoice_flag:= l_gr.change_printed_invoice_flag;
        ARP_GLOBAL.sysparam.code_combination_id_loss	:= l_gr.code_combination_id_loss;
        ARP_GLOBAL.sysparam.create_reciprocal_flag	:= l_gr.create_reciprocal_flag;
        ARP_GLOBAL.sysparam.default_country		:= l_gr.default_country;
        ARP_GLOBAL.sysparam.default_territory		:= l_gr.default_territory;

        ARP_GLOBAL.sysparam.generate_customer_number	:= l_gr.generate_customer_number;
        ARP_GLOBAL.sysparam.invoice_deletion_flag	:= l_gr.invoice_deletion_flag;
        ARP_GLOBAL.sysparam.location_structure_id	:= l_gr.location_structure_id;
        ARP_GLOBAL.sysparam.site_required_flag		:= l_gr.site_required_flag;
        ARP_GLOBAL.sysparam.tax_allow_compound_flag	:= l_gr.tax_allow_compound_flag;
        ARP_GLOBAL.sysparam.tax_header_level_flag	:= l_gr.tax_header_level_flag;
        ARP_GLOBAL.sysparam.tax_rounding_allow_override:= l_gr.tax_rounding_allow_override;
        ARP_GLOBAL.sysparam.tax_invoice_print		:= l_gr.tax_invoice_print;
        ARP_GLOBAL.sysparam.tax_method			:= l_gr.tax_method;

        ARP_GLOBAL.sysparam.tax_use_customer_exempt_flag:= l_gr.tax_use_customer_exempt_flag;
        ARP_GLOBAL.sysparam.tax_use_cust_exc_rate_flag	:= l_gr.tax_use_cust_exc_rate_flag;
        ARP_GLOBAL.sysparam.tax_use_loc_exc_rate_flag	:= l_gr.tax_use_loc_exc_rate_flag;
        ARP_GLOBAL.sysparam.tax_use_product_exempt_flag:= l_gr.tax_use_product_exempt_flag;
        ARP_GLOBAL.sysparam.tax_use_prod_exc_rate_flag	:= l_gr.tax_use_prod_exc_rate_flag;
        ARP_GLOBAL.sysparam.tax_use_site_exc_rate_flag	:= l_gr.tax_use_site_exc_rate_flag;
        ARP_GLOBAL.sysparam.ai_log_file_message_level	:= l_gr.ai_log_file_message_level;
        ARP_GLOBAL.sysparam.ai_max_memory_in_bytes	:= l_gr.ai_max_memory_in_bytes;

        ARP_GLOBAL.sysparam.ai_acct_flex_key_left_prompt:= l_gr.ai_acct_flex_key_left_prompt;
        ARP_GLOBAL.sysparam.ai_mtl_items_key_left_prompt:= l_gr.ai_mtl_items_key_left_prompt;
        ARP_GLOBAL.sysparam.ai_territory_key_left_prompt:= l_gr.ai_territory_key_left_prompt;
        ARP_GLOBAL.sysparam.ai_purge_interface_tables_flag:= l_gr.ai_purge_int_tables_flag;
        ARP_GLOBAL.sysparam.ai_activate_sql_trace_flag	:= l_gr.ai_activate_sql_trace_flag;
        ARP_GLOBAL.sysparam.default_grouping_rule_id	:= l_gr.default_grouping_rule_id;
        ARP_GLOBAL.sysparam.salesrep_required_flag	:= l_gr.salesrep_required_flag;

        ARP_GLOBAL.sysparam.auto_rec_invoices_per_commit:= l_gr.auto_rec_invoices_per_commit;
        ARP_GLOBAL.sysparam.auto_rec_receipts_per_commit:= l_gr.auto_rec_receipts_per_commit;
        ARP_GLOBAL.sysparam.pay_unrelated_invoices_flag:= l_gr.pay_unrelated_invoices_flag;
        ARP_GLOBAL.sysparam.print_home_country_flag	:= l_gr.print_home_country_flag;
        ARP_GLOBAL.sysparam.location_tax_account	:= l_gr.location_tax_account;
        ARP_GLOBAL.sysparam.from_postal_code		:= l_gr.from_postal_code;
        ARP_GLOBAL.sysparam.to_postal_code		:= l_gr.to_postal_code;

        ARP_GLOBAL.sysparam.tax_registration_number	:= l_gr.tax_registration_number;
        ARP_GLOBAL.sysparam.populate_gl_segments_flag	:= l_gr.populate_gl_segments_flag;
        ARP_GLOBAL.sysparam.unallocated_revenue_ccid	:= l_gr.unallocated_revenue_ccid;

        ARP_GLOBAL.sysparam.inclusive_tax_used		:= l_gr.inclusive_tax_used;
        ARP_GLOBAL.sysparam.tax_enforce_account_flag	:= l_gr.tax_enforce_account_flag;

        ARP_GLOBAL.sysparam.ta_installed_flag		:= l_gr.ta_installed_flag;
        ARP_GLOBAL.sysparam.bills_receivable_enabled_flag:= l_gr.br_enabled_flag;

        ARP_GLOBAL.sysparam.attribute_category		:= l_gr.attribute_category;
        ARP_GLOBAL.sysparam.attribute1			:= l_gr.attribute1;
        ARP_GLOBAL.sysparam.attribute2			:= l_gr.attribute2;
        ARP_GLOBAL.sysparam.attribute3			:= l_gr.attribute3;
        ARP_GLOBAL.sysparam.attribute4			:= l_gr.attribute4;
        ARP_GLOBAL.sysparam.attribute5			:= l_gr.attribute5;
        ARP_GLOBAL.sysparam.attribute6			:= l_gr.attribute6;
        ARP_GLOBAL.sysparam.attribute7			:= l_gr.attribute7;
        ARP_GLOBAL.sysparam.attribute8			:= l_gr.attribute8;
        ARP_GLOBAL.sysparam.attribute9			:= l_gr.attribute9;
        ARP_GLOBAL.sysparam.attribute10		:= l_gr.attribute10;
        ARP_GLOBAL.sysparam.attribute11		:= l_gr.attribute11;
        ARP_GLOBAL.sysparam.attribute12		:= l_gr.attribute12;
        ARP_GLOBAL.sysparam.attribute13		:= l_gr.attribute13;
        ARP_GLOBAL.sysparam.attribute14		:= l_gr.attribute14;
        ARP_GLOBAL.sysparam.attribute15		:= l_gr.attribute15;

        ARP_GLOBAL.sysparam.created_by			:= l_gr.created_by;
        ARP_GLOBAL.sysparam.creation_date		:= l_gr.creation_date;
        ARP_GLOBAL.sysparam.last_updated_by		:= l_gr.last_updated_by;
        ARP_GLOBAL.sysparam.last_update_date		:= l_gr.last_update_date;
        ARP_GLOBAL.sysparam.last_update_login		:= l_gr.last_update_login;

        ARP_GLOBAL.sysparam.tax_code			:= l_gr.tax_code;
        ARP_GLOBAL.sysparam.tax_currency_code		:= l_gr.tax_currency_code;
        ARP_GLOBAL.sysparam.tax_minimum_accountable_unit:= l_gr.tax_minimum_accountable_unit;
        ARP_GLOBAL.sysparam.tax_precision		:= l_gr.tax_precision;
        ARP_GLOBAL.sysparam.tax_rounding_rule		:= l_gr.tax_rounding_rule;
        ARP_GLOBAL.sysparam.tax_use_account_exc_rate_flag:= l_gr.tax_use_acc_exc_rate_flag;
        ARP_GLOBAL.sysparam.tax_use_system_exc_rate_flag:= l_gr.tax_use_system_exc_rate_flag;
        ARP_GLOBAL.sysparam.tax_hier_site_exc_rate	:= l_gr.tax_hier_site_exc_rate;
        ARP_GLOBAL.sysparam.tax_hier_cust_exc_rate	:= l_gr.tax_hier_cust_exc_rate;
        ARP_GLOBAL.sysparam.tax_hier_prod_exc_rate	:= l_gr.tax_hier_prod_exc_rate;
        ARP_GLOBAL.sysparam.tax_hier_account_exc_rate	:= l_gr.tax_hier_account_exc_rate;
        ARP_GLOBAL.sysparam.tax_hier_system_exc_rate	:= l_gr.tax_hier_system_exc_rate;
        ARP_GLOBAL.sysparam.tax_database_view_set	:= l_gr.tax_database_view_set;

        ARP_GLOBAL.sysparam.global_attribute1		:= l_gr.global_attribute1;
        ARP_GLOBAL.sysparam.global_attribute2		:= l_gr.global_attribute2;
        ARP_GLOBAL.sysparam.global_attribute3		:= l_gr.global_attribute3;
        ARP_GLOBAL.sysparam.global_attribute4		:= l_gr.global_attribute4;
        ARP_GLOBAL.sysparam.global_attribute5		:= l_gr.global_attribute5;
        ARP_GLOBAL.sysparam.global_attribute6		:= l_gr.global_attribute6;
        ARP_GLOBAL.sysparam.global_attribute7		:= l_gr.global_attribute7;
        ARP_GLOBAL.sysparam.global_attribute8		:= l_gr.global_attribute8;
        ARP_GLOBAL.sysparam.global_attribute9		:= l_gr.global_attribute9;
        ARP_GLOBAL.sysparam.global_attribute10		:= l_gr.global_attribute10;
        ARP_GLOBAL.sysparam.global_attribute11		:= l_gr.global_attribute11;
        ARP_GLOBAL.sysparam.global_attribute12		:= l_gr.global_attribute12;
        ARP_GLOBAL.sysparam.global_attribute13		:= l_gr.global_attribute13;
        ARP_GLOBAL.sysparam.global_attribute14		:= l_gr.global_attribute14;
        ARP_GLOBAL.sysparam.global_attribute15		:= l_gr.global_attribute15;
        ARP_GLOBAL.sysparam.global_attribute16		:= l_gr.global_attribute16;
        ARP_GLOBAL.sysparam.global_attribute17		:= l_gr.global_attribute17;
        ARP_GLOBAL.sysparam.global_attribute18		:= l_gr.global_attribute18;
        ARP_GLOBAL.sysparam.global_attribute19		:= l_gr.global_attribute19;
        ARP_GLOBAL.sysparam.global_attribute20		:= l_gr.global_attribute20;
        ARP_GLOBAL.sysparam.global_attribute_category	:= l_gr.global_attribute_category;

        ARP_GLOBAL.sysparam.rule_set_id		:= l_gr.rule_set_id;
        ARP_GLOBAL.sysparam.code_combination_id_round	:= l_gr.code_combination_id_round;
        ARP_GLOBAL.sysparam.trx_header_level_rounding	:= l_gr.trx_header_level_rounding;
        ARP_GLOBAL.sysparam.trx_header_round_ccid	:= l_gr.trx_header_round_ccid;
        ARP_GLOBAL.sysparam.finchrg_receivables_trx_id	:= l_gr.finchrg_receivables_trx_id;
        ARP_GLOBAL.sysparam.sales_tax_geocode		:= l_gr.sales_tax_geocode;
        ARP_GLOBAL.sysparam.rev_transfer_clear_ccid	:= l_gr.rev_transfer_clear_ccid;
        ARP_GLOBAL.sysparam.sales_credit_pct_limit	:= l_gr.sales_credit_pct_limit;
        ARP_GLOBAL.sysparam.max_wrtoff_amount		:= l_gr.max_wrtoff_amount;
        ARP_GLOBAL.sysparam.irec_cc_receipt_method_id	:= l_gr.irec_cc_receipt_method_id;
        ARP_GLOBAL.sysparam.show_billing_number_flag	:= l_gr.show_billing_number_flag;
        ARP_GLOBAL.sysparam.cross_currency_rate_type	:= l_gr.cross_currency_rate_type;
        ARP_GLOBAL.sysparam.document_seq_gen_level	:= l_gr.document_seq_gen_level;
        ARP_GLOBAL.sysparam.calc_tax_on_credit_memo_flag:= l_gr.calc_tax_on_credit_memo_flag;
        ARP_GLOBAL.sysparam.calc_tax_on_credit_memo_flag:= l_gr.calc_tax_on_credit_memo_flag;
        ARP_GLOBAL.sysparam.IREC_BA_RECEIPT_METHOD_ID   := l_gr.IREC_BA_RECEIPT_METHOD_ID;
        ARP_GLOBAL.sysparam.payment_threshold           := l_gr.payment_threshold;
        ARP_GLOBAL.sysparam.standard_refund             := l_gr.standard_refund;
        ARP_GLOBAL.sysparam.credit_classification1      := l_gr.credit_classification1;
        ARP_GLOBAL.sysparam.credit_classification2      := l_gr.credit_classification2;
        ARP_GLOBAL.sysparam.credit_classification3      := l_gr.credit_classification3;
        ARP_GLOBAL.sysparam.unmtch_claim_creation_flag  := l_gr.unmtch_claim_creation_flag;
        ARP_GLOBAL.sysparam.matched_claim_creation_flag := l_gr.matched_claim_creation_flag;
        ARP_GLOBAL.sysparam.matched_claim_excl_cm_flag  := l_gr.matched_claim_excl_cm_flag;
        ARP_GLOBAL.sysparam.min_wrtoff_amount           := l_gr.min_wrtoff_amount;
        ARP_GLOBAL.sysparam.min_refund_amount           := l_gr.min_refund_amount;

        ARP_GLOBAL.set_of_books_id                      := l_gr.set_of_books_id;
	ARP_GLOBAL.chart_of_accounts_id                 := l_gr.chart_of_accounts_id;
        ARP_GLOBAL.functional_currency                  := l_gr.currency_code;
        ARP_GLOBAL.period_set_name                      := l_gr.period_set_name;
        ARP_GLOBAL.base_precision                       := l_gr.base_precision;
        ARP_GLOBAL.base_min_acc_unit                    := l_gr.base_MIN_ACCOUNTABLE_UNIT;

        -- Bug 3251839 - tm_installed_flag global is set to prevent repeated
        -- calls to ozf check_installed function; likewise tm_default_setup_flag
	tm_installed_flag 				:= l_gr.tm_installed_flag;
	tm_default_setup_flag 				:= l_gr.tm_default_setup_flag;

        arp_trx_global.init;

   --
   arp_util.debug( 'arp_global.init_global()-' );
   --

EXCEPTION
   WHEN OTHERS THEN
   arp_util.debug( 'EXCEPTION: arp_global.init_global' );
   RAISE;
--

END INIT_GLOBAL;

/* Bug 3251839 - function added to make tm_installed_flag available to forms */
FUNCTION TM_INSTALLED RETURN VARCHAR2
IS
BEGIN
  RETURN tm_installed_flag;
END;

BEGIN

    /* Bug 1679088 : define new public procedure, this process can be
       called from other modules to run initialization whenever required */
    arp_standard.debug('Initialisation section ARP_GLOBAL.INIT_GLOBAL()');

/* Bug 4624926 API failing in R12-Starts*/
   IF mo_global.get_current_org_id is null then

    ARP_GLOBAL.INIT_GLOBAL;
   ELSE

     ARP_GLOBAL.INIT_GLOBAL(mo_global.get_current_org_id);
  END IF;
/* Bug 4624926 API failing in R12-Ends*/
   /*Bug 3678916*/

   IF fnd_global.conc_program_id IS NOT NULL
   THEN
     BEGIN

      SELECT concurrent_program_name
      INTO   conc_program_name
      FROM   fnd_concurrent_programs_vl
      WHERE  concurrent_program_id = fnd_global.conc_program_id
      AND  application_id = 222;

     EXCEPTION
       WHEN others THEN
        conc_program_name := 'NONE';
     END;
   END IF;

END ARP_GLOBAL;

/
