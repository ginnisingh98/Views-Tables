--------------------------------------------------------
--  DDL for Package AR_INVOICE_DEFAULT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_INVOICE_DEFAULT_PVT" AUTHID CURRENT_USER AS
/* $Header: ARXVINDS.pls 120.3.12010000.2 2008/10/14 12:12:25 spdixit ship $ */

TYPE trx_system_parameters_rec_type IS RECORD  (
    set_of_books_id                 ar_system_parameters.set_of_books_id%type,
    accounting_method               ar_system_parameters.accounting_method%type,
    accrue_interest                 ar_system_parameters.accrue_interest%type,
    unearned_discount          	    ar_system_parameters.unearned_discount%type,
    partial_discount_flag     	    ar_system_parameters.partial_discount_flag%type,
    print_remit_to           	    ar_system_parameters.print_remit_to%type,
    default_cb_due_date     	    ar_system_parameters.default_cb_due_date%type,
    auto_site_numbering    	        ar_system_parameters.auto_site_numbering%type,
    cash_basis_set_of_books_id      ar_system_parameters.cash_basis_set_of_books_id%type,
    code_combination_id_gain        ar_system_parameters.code_combination_id_gain%type,
    autocash_hierarchy_id           ar_system_parameters.autocash_hierarchy_id%type,
    run_gl_journal_import_flag   	ar_system_parameters.run_gl_journal_import_flag%type,
    cer_split_amount            	ar_system_parameters.cer_split_amount%type,
    cer_dso_days               	    ar_system_parameters.cer_dso_days%type,
    posting_days_per_cycle    	    ar_system_parameters.posting_days_per_cycle%type,
    address_validation       	    ar_system_parameters.address_validation%type,
    calc_discount_on_lines_flag     ar_system_parameters.calc_discount_on_lines_flag%type,
    change_printed_invoice_flag	    ar_system_parameters.change_printed_invoice_flag%type,
    code_combination_id_loss     	ar_system_parameters.code_combination_id_loss%type,
    create_reciprocal_flag      	ar_system_parameters.create_reciprocal_flag%type,
    default_country            	    ar_system_parameters.default_country%type,
    default_territory         	    ar_system_parameters.default_territory%type,
    generate_customer_number 	    ar_system_parameters.generate_customer_number%type,
    invoice_deletion_flag   	    ar_system_parameters.invoice_deletion_flag%type,
    location_structure_id  	        ar_system_parameters.location_structure_id%type,
    site_required_flag    	        ar_system_parameters.site_required_flag%type,
    tax_allow_compound_flag         ar_system_parameters.tax_allow_compound_flag%type,
    tax_header_level_flag        	ar_system_parameters.tax_header_level_flag%type,
    tax_rounding_allow_override 	ar_system_parameters.tax_rounding_allow_override%type,
    tax_invoice_print          	    ar_system_parameters.tax_invoice_print%type,
    tax_method                	    ar_system_parameters.tax_method%type,
    tax_use_customer_exempt_flag    ar_system_parameters.tax_use_customer_exempt_flag%type,
    tax_use_cust_exc_rate_flag   	ar_system_parameters.tax_use_cust_exc_rate_flag%type,
    tax_use_loc_exc_rate_flag   	ar_system_parameters.tax_use_loc_exc_rate_flag%type,
    tax_use_product_exempt_flag	    ar_system_parameters.tax_use_product_exempt_flag%type,
    tax_use_prod_exc_rate_flag      ar_system_parameters.tax_use_prod_exc_rate_flag%type,
    tax_use_site_exc_rate_flag   	ar_system_parameters.tax_use_site_exc_rate_flag%type,
    ai_log_file_message_level   	ar_system_parameters.ai_log_file_message_level%type,
    ai_max_memory_in_bytes     	    ar_system_parameters.ai_max_memory_in_bytes%type,
    ai_acct_flex_key_left_prompt    ar_system_parameters.ai_acct_flex_key_left_prompt%type,
    ai_mtl_items_key_left_prompt 	ar_system_parameters.ai_mtl_items_key_left_prompt%type,
    ai_territory_key_left_prompt	ar_system_parameters.ai_territory_key_left_prompt%type,
    ai_purge_int_tables_flag        ar_system_parameters.ai_purge_interface_tables_flag%type,
    ai_activate_sql_trace_flag   	ar_system_parameters.ai_activate_sql_trace_flag%type,
    default_grouping_rule_id    	ar_system_parameters.default_grouping_rule_id%type,
    salesrep_required_flag     	    ar_system_parameters.salesrep_required_flag%type,
    auto_rec_invoices_per_commit    ar_system_parameters.auto_rec_invoices_per_commit%type,
    auto_rec_receipts_per_commit 	ar_system_parameters.auto_rec_receipts_per_commit%type,
    pay_unrelated_invoices_flag 	ar_system_parameters.pay_unrelated_invoices_flag%type,
    print_home_country_flag    	    ar_system_parameters.print_home_country_flag%type,
    location_tax_account      	    ar_system_parameters.location_tax_account%type,
    from_postal_code         	    ar_system_parameters.from_postal_code%type,
    to_postal_code          	    ar_system_parameters.to_postal_code%type,
    tax_registration_number	        ar_system_parameters.tax_registration_number%type,
    populate_gl_segments_flag       ar_system_parameters.populate_gl_segments_flag%type,
    unallocated_revenue_ccid     	ar_system_parameters.unallocated_revenue_ccid%type,
    base_currency_code         	    gl_sets_of_books.currency_code%type,
    chart_of_accounts_id       	    gl_sets_of_books.chart_of_accounts_id%type,
    period_set_name           	    gl_sets_of_books.period_set_name%type,
    set_of_books             	    gl_sets_of_books.short_name%type,
    base_precision          	    fnd_currencies.precision%type,
    base_EXTENDED_PRECISION	        fnd_currencies.EXTENDED_PRECISION%type,
    base_MIN_ACCOUNTABLE_UNIT  	    fnd_currencies.MINIMUM_ACCOUNTABLE_UNIT%type,
    salescredit_name            	ra_salesreps.name%type,
    yes_meaning                  	ar_lookups.meaning%type,
    no_meaning                      ar_lookups.meaning%type,
    org_id			                ar_system_parameters.org_id%type,
    inclusive_tax_used		        ar_system_parameters.inclusive_tax_used%type,
    tax_enforce_account_flag	    ar_system_parameters.tax_enforce_account_flag%type,
    ta_installed_flag               varchar2(1),
    br_enabled_flag	                ar_system_parameters.bills_receivable_enabled_flag%type,
    default_reference               ra_batch_sources.default_reference%type,
    ar_ra_batch_source_name         ra_batch_sources.name%type,
    ar_ra_batch_auto_num_flag       ra_batch_sources.auto_batch_numbering_flag%type,
    ar_multi_currency_flag          varchar2(1),
    ar_receipt_multi_currency_flag  varchar2(1),
    short_name                      gl_sets_of_books.short_name%type,
    precision                       fnd_currencies.precision%type,
    EXTENDED_PRECISION              fnd_currencies.extended_precision%type,
    MINIMUM_ACCOUNTABLE_UNIT        fnd_currencies.MINIMUM_ACCOUNTABLE_UNIT%type,
    DOCUMENT_SEQ_GEN_LEVEL           ar_system_parameters.DOCUMENT_SEQ_GEN_LEVEL%type,
    trx_header_level_rounding       ar_system_parameters.trx_header_level_rounding%type);

trx_system_parameters_rec           trx_system_parameters_rec_type;

TYPE trx_profile_rec_type IS RECORD  (
       ar_br_batch_source               VARCHAR2(255),
       AR_BR_WO_RECOURSE                VARCHAR2(255),
       AR_MASK_BANK_ACCOUNT_NUMBERS     VARCHAR2(255),
       ar_unique_seq_numbers            VARCHAR2(255),
       ar_adj_credit_unconfirmed_inv    VARCHAR2(255),
       ar_allow_manual_tax_lines        VARCHAR2(255),
       ar_allow_tax_update              VARCHAR2(255),
       ar_allow_tax_code_override       VARCHAR2(255),
       ar_allow_trx_line_exemptions     VARCHAR2(255),
       ar_batch_source                  VARCHAR2(255),
       ar_change_cust_name              VARCHAR2(255),
       ar_change_cust_on_trx            VARCHAR2(255),
       ar_override_adj_activity_acct    VARCHAR2(255),
       ar_powercash_allow_actions       VARCHAR2(255),
       ar_ra_batch_source               VARCHAR2(255),
       ar_update_due_date               VARCHAR2(255),
       ar_use_inv_acct_for_cm_flag      VARCHAR2(255),
       ussgl_option                     VARCHAR2(255),
       display_inverse_rate             VARCHAR2(255),
       ar_allow_salescredit_update      VARCHAR2(255),
       so_organization_id               VARCHAR2(255),
       so_source_code                   VARCHAR2(255),
       so_id_flex_code                  VARCHAR2(255),
       ar_jg_create_bank_charges        VARCHAR2(255),
       ar_incl_receipts_at_risk         VARCHAR2(255),
       default_exchange_rate_type       VARCHAR2(255),
       default_exchange_rate_type_dsp   VARCHAR2(255),
       def_exchange_rate_type_profile   VARCHAR2(255),
       so_installed_flag                VARCHAR2(255),
       rev_based_on_srep_flag           VARCHAR2(1),
       autoacc_based_on_srep_flag       VARCHAR2(1),
       autoacc_based_on_primary_srep    VARCHAR2(1),
       autoacc_based_on_agree_cat       VARCHAR2(1),
       autoacc_based_on_type_flag       VARCHAR2(1),
       autoacc_based_on_item_flag       VARCHAR2(1),
       autoacc_based_on_tax_code        VARCHAR2(1),
       autoacc_based_on_site_flag       VARCHAR2(1));

trx_profile_rec                         trx_profile_rec_type;




PROCEDURE Get_system_parameters(
	p_trx_system_parameters_rec    OUT NOCOPY trx_system_parameters_rec_type,
	x_errmsg                    OUT NOCOPY  VARCHAR2,
	x_return_status             OUT NOCOPY  VARCHAR2);

PROCEDURE Get_profile_values(
	p_trx_profile_rec     OUT NOCOPY trx_profile_rec_type,
	x_errmsg                    OUT NOCOPY  VARCHAR2,
	x_return_status             OUT NOCOPY  VARCHAR2);

PROCEDURE Default_gl_date;


END;

/
