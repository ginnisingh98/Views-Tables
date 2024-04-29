--------------------------------------------------------
--  DDL for Package AR_MO_CACHE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_MO_CACHE_UTILS" AUTHID CURRENT_USER AS
    /*$Header: ARMOCSHS.pls 120.12.12010000.4 2009/01/29 13:01:29 spdixit ship $ */
    /* Define a record type that encapsulates one row of operating
       unit attributes   */

   TYPE GlobalsRecord is record(

  /* ------------------------------------------------------------------
      Generic columns needed by all products
     ------------------------------------------------------------------ */
      set_of_books_id               gl_sets_of_books.set_of_books_id%TYPE,
      set_of_books_name             gl_sets_of_books.name%TYPE,
      chart_of_accounts_id          gl_sets_of_books.chart_of_accounts_id%TYPE,
      currency_code                 fnd_currencies.currency_code%TYPE,
      org_id                        ar_system_parameters.org_id%type,

   /* ----------------------------------------------------------------------
      <COLUMN>                      <system options.column name>%TYPE
      ---------------------------------------------------------------------- */
      accounting_method             ar_system_parameters.accounting_method%type,
      accrue_interest               ar_system_parameters.accrue_interest%type,
      unearned_discount             ar_system_parameters.unearned_discount%type,
      partial_discount_flag         ar_system_parameters.partial_discount_flag%type,
      print_remit_to                ar_system_parameters.print_remit_to%type,
      default_cb_due_date           ar_system_parameters.default_cb_due_date%type,
      auto_site_numbering           ar_system_parameters.auto_site_numbering%type,
      cash_basis_set_of_books_id    ar_system_parameters.cash_basis_set_of_books_id%type,
      code_combination_id_gain      ar_system_parameters.code_combination_id_gain%type,
      autocash_hierarchy_id         ar_system_parameters.autocash_hierarchy_id%type,
      run_gl_journal_import_flag    ar_system_parameters.run_gl_journal_import_flag%type,
      cer_split_amount              ar_system_parameters.cer_split_amount%type,
      cer_dso_days                  ar_system_parameters.cer_dso_days%type,

      posting_days_per_cycle        ar_system_parameters.posting_days_per_cycle%type,
      address_validation            ar_system_parameters.address_validation%type,
      calc_discount_on_lines_flag   ar_system_parameters.calc_discount_on_lines_flag%type,
      change_printed_invoice_flag   ar_system_parameters.change_printed_invoice_flag%type,
      code_combination_id_loss      ar_system_parameters.code_combination_id_loss%type,
      create_reciprocal_flag        ar_system_parameters.create_reciprocal_flag%type,
      default_country               ar_system_parameters.default_country%type,
      default_territory             ar_system_parameters.default_territory%type,

      generate_customer_number      ar_system_parameters.generate_customer_number%type,
      invoice_deletion_flag         ar_system_parameters.invoice_deletion_flag%type,
      location_structure_id         ar_system_parameters.location_structure_id%type,
      site_required_flag            ar_system_parameters.site_required_flag%type,
      tax_allow_compound_flag       ar_system_parameters.tax_allow_compound_flag%type,
      tax_header_level_flag         ar_system_parameters.tax_header_level_flag%type,
      tax_rounding_allow_override   ar_system_parameters.tax_rounding_allow_override%type,
      tax_invoice_print             ar_system_parameters.tax_invoice_print%type,
      tax_method                    ar_system_parameters.tax_method%type,

      tax_use_customer_exempt_flag  ar_system_parameters.tax_use_customer_exempt_flag%type,
      tax_use_cust_exc_rate_flag    ar_system_parameters.tax_use_cust_exc_rate_flag%type,
      tax_use_loc_exc_rate_flag     ar_system_parameters.tax_use_loc_exc_rate_flag%type,
      tax_use_product_exempt_flag   ar_system_parameters.tax_use_product_exempt_flag%type,
      tax_use_prod_exc_rate_flag    ar_system_parameters.tax_use_prod_exc_rate_flag%type,
      tax_use_site_exc_rate_flag    ar_system_parameters.tax_use_site_exc_rate_flag%type,
      ai_log_file_message_level     ar_system_parameters.ai_log_file_message_level%type,
      ai_max_memory_in_bytes        ar_system_parameters.ai_max_memory_in_bytes%type,

      ai_acct_flex_key_left_prompt  ar_system_parameters.ai_acct_flex_key_left_prompt%type,
      ai_mtl_items_key_left_prompt  ar_system_parameters.ai_mtl_items_key_left_prompt%type,
      ai_territory_key_left_prompt  ar_system_parameters.ai_territory_key_left_prompt%type,
      ai_purge_int_tables_flag      ar_system_parameters.ai_purge_interface_tables_flag%type,
      ai_activate_sql_trace_flag    ar_system_parameters.ai_activate_sql_trace_flag%type,
      default_grouping_rule_id      ar_system_parameters.default_grouping_rule_id%type,
      salesrep_required_flag        ar_system_parameters.salesrep_required_flag%type,

      auto_rec_invoices_per_commit  ar_system_parameters.auto_rec_invoices_per_commit%type,
      auto_rec_receipts_per_commit  ar_system_parameters.auto_rec_receipts_per_commit%type,
      pay_unrelated_invoices_flag   ar_system_parameters.pay_unrelated_invoices_flag%type,
      print_home_country_flag       ar_system_parameters.print_home_country_flag%type,
      location_tax_account          ar_system_parameters.location_tax_account%type,
      from_postal_code              ar_system_parameters.from_postal_code%type,
      to_postal_code                ar_system_parameters.to_postal_code%type,

      tax_registration_number       ar_system_parameters.tax_registration_number%type,
      populate_gl_segments_flag     ar_system_parameters.populate_gl_segments_flag%type,
      unallocated_revenue_ccid      ar_system_parameters.unallocated_revenue_ccid%type,
      period_set_name               gl_sets_of_books.period_set_name%type,

      base_precision                fnd_currencies.precision%type,
      base_EXTENDED_PRECISION       fnd_currencies.EXTENDED_PRECISION%type,
      base_MIN_ACCOUNTABLE_UNIT     fnd_currencies.MINIMUM_ACCOUNTABLE_UNIT%type,
      salescredit_name              ra_salesreps.name%type,
      yes_meaning                   ar_lookups.meaning%type,
      no_meaning                    ar_lookups.meaning%type,
      tax_exempt_flag_meaning       ar_lookups.meaning%type ,
      inclusive_tax_used            ar_system_parameters.inclusive_tax_used%type,
      tax_enforce_account_flag      ar_system_parameters.tax_enforce_account_flag%type,

      ta_installed_flag    	    ar_system_parameters.ta_installed_flag%type,
      br_enabled_flag               ar_system_parameters.bills_receivable_enabled_flag%type,

--new begin
      attribute_category            ar_system_parameters.attribute_category%type,
      attribute1                    ar_system_parameters.attribute1%type,
      attribute2                    ar_system_parameters.attribute2%type,
      attribute3                    ar_system_parameters.attribute3%type,
      attribute4                    ar_system_parameters.attribute4%type,
      attribute5                    ar_system_parameters.attribute5%type,
      attribute6                    ar_system_parameters.attribute6%type,
      attribute7                    ar_system_parameters.attribute7%type,
      attribute8                    ar_system_parameters.attribute8%type,
      attribute9                    ar_system_parameters.attribute9%type,
      attribute10                   ar_system_parameters.attribute10%type,
      attribute11                   ar_system_parameters.attribute11%type,
      attribute12                   ar_system_parameters.attribute12%type,
      attribute13                   ar_system_parameters.attribute13%type,
      attribute14                   ar_system_parameters.attribute14%type,
      attribute15                   ar_system_parameters.attribute15%type,

      created_by                    ar_system_parameters.created_by%type,
      creation_date                 ar_system_parameters.creation_date%type,
      last_updated_by               ar_system_parameters.last_updated_by%type,
      last_update_date              ar_system_parameters.last_update_date%type,
      last_update_login             ar_system_parameters.last_update_login%type,

      tax_code                      ar_system_parameters.tax_code%type,
      tax_currency_code             ar_system_parameters.tax_currency_code%type,
      tax_minimum_accountable_unit  ar_system_parameters.tax_minimum_accountable_unit%type,
      tax_precision                 ar_system_parameters.tax_precision%type,
      tax_rounding_rule             ar_system_parameters.tax_rounding_rule%type,
      tax_use_acc_exc_rate_flag     ar_system_parameters.tax_use_account_exc_rate_flag%type,
      tax_use_system_exc_rate_flag  ar_system_parameters.tax_use_system_exc_rate_flag%type,
      tax_hier_site_exc_rate        ar_system_parameters.tax_hier_site_exc_rate%type,
      tax_hier_cust_exc_rate        ar_system_parameters.tax_hier_cust_exc_rate%type,
      tax_hier_prod_exc_rate        ar_system_parameters.tax_hier_prod_exc_rate%type,
      tax_hier_account_exc_rate     ar_system_parameters.tax_hier_account_exc_rate%type,
      tax_hier_system_exc_rate      ar_system_parameters.tax_hier_system_exc_rate%type,
      tax_database_view_set         ar_system_parameters.tax_database_view_set%type,

      global_attribute1             ar_system_parameters.global_attribute1%type,
      global_attribute2             ar_system_parameters.global_attribute2%type,
      global_attribute3             ar_system_parameters.global_attribute3%type,
      global_attribute4             ar_system_parameters.global_attribute4%type,
      global_attribute5             ar_system_parameters.global_attribute5%type,
      global_attribute6             ar_system_parameters.global_attribute6%type,
      global_attribute7             ar_system_parameters.global_attribute7%type,
      global_attribute8             ar_system_parameters.global_attribute8%type,
      global_attribute9             ar_system_parameters.global_attribute9%type,
      global_attribute10            ar_system_parameters.global_attribute10%type,
      global_attribute11            ar_system_parameters.global_attribute11%type,
      global_attribute12            ar_system_parameters.global_attribute12%type,
      global_attribute13            ar_system_parameters.global_attribute13%type,
      global_attribute14            ar_system_parameters.global_attribute14%type,
      global_attribute15            ar_system_parameters.global_attribute15%type,
      global_attribute16            ar_system_parameters.global_attribute16%type,
      global_attribute17            ar_system_parameters.global_attribute17%type,
      global_attribute18            ar_system_parameters.global_attribute18%type,
      global_attribute19            ar_system_parameters.global_attribute19%type,
      global_attribute20            ar_system_parameters.global_attribute20%type,
      global_attribute_category     ar_system_parameters.global_attribute_category%type,

      rule_set_id                   ar_system_parameters.rule_set_id%type,
      code_combination_id_round     ar_system_parameters.code_combination_id_round%type,
      trx_header_level_rounding     ar_system_parameters.trx_header_level_rounding%type,
      trx_header_round_ccid         ar_system_parameters.trx_header_round_ccid%type,
      finchrg_receivables_trx_id    ar_system_parameters.finchrg_receivables_trx_id%type,
      sales_tax_geocode             ar_system_parameters.sales_tax_geocode%type,
      rev_transfer_clear_ccid       ar_system_parameters.rev_transfer_clear_ccid%type,
      sales_credit_pct_limit        ar_system_parameters.sales_credit_pct_limit%type,
      max_wrtoff_amount             ar_system_parameters.max_wrtoff_amount%type,
      irec_cc_receipt_method_id     ar_system_parameters.irec_cc_receipt_method_id%type,
      show_billing_number_flag      ar_system_parameters.show_billing_number_flag%type,
      cross_currency_rate_type      ar_system_parameters.cross_currency_rate_type%type,
      document_seq_gen_level        ar_system_parameters.document_seq_gen_level%type,
      calc_tax_on_credit_memo_flag  ar_system_parameters.calc_tax_on_credit_memo_flag%type,
      IREC_BA_RECEIPT_METHOD_ID     ar_system_parameters.IREC_BA_RECEIPT_METHOD_ID%type,
      tm_installed_flag		    VARCHAR2(1),
      tm_default_setup_flag         VARCHAR2(1),
      payment_threshold             ar_system_parameters.payment_threshold%type,
      standard_refund               ar_system_parameters.standard_refund%type,
      credit_classification1        ar_system_parameters.credit_classification1%type,
      credit_classification2        ar_system_parameters.credit_classification2%type,
      credit_classification3        ar_system_parameters.credit_classification3%type,
      unmtch_claim_creation_flag    ar_system_parameters.unmtch_claim_creation_flag%type,
      matched_claim_creation_flag   ar_system_parameters.matched_claim_creation_flag%type,
      matched_claim_excl_cm_flag    ar_system_parameters.matched_claim_excl_cm_flag%type,
      min_wrtoff_amount             ar_system_parameters.min_wrtoff_amount%type,
      min_refund_amount             ar_system_parameters.min_refund_amount%type,
      create_detailed_dist_flag     ar_system_parameters.create_detailed_dist_flag%type
--new end
    /*  End AR-specific fields  */ );

 /*  ----------------------------------------------------------------------------
     Define data types (nested tables) for storing columns of the widely used
     operating unit attributes:
     ---------------------------------------------------------------------------- */

                TYPE SetOfBooksIDTable
                         IS TABLE OF gl_sets_of_books.set_of_books_id%TYPE;
                TYPE SetOfBooksNameTable
                         IS TABLE OF gl_sets_of_books.name%TYPE;
                TYPE ChartOfAccountsIDTable
                         IS TABLE OF gl_sets_of_books.chart_of_accounts_id%TYPE;
                TYPE CurrencyCodeTable
                         IS TABLE OF fnd_currencies.currency_code%TYPE;

    /*-----------------------------------------------------------------------------------
      Begin AR-specific nested tables definitions
      -----------------------------------------------------------------------------------
           e.g. TYPE <<column1Table>> IS TABLE OF <<system options.column1>>%TYPE;
      ----------------------------------------------------------------------------------- */

		TYPE  accountingmethodTable
                        IS TABLE OF      ar_system_parameters.accounting_method%type;
		TYPE  accrueinterestTable
                        IS TABLE OF      ar_system_parameters.accrue_interest%type;
		TYPE  unearneddiscountTable
                        IS TABLE OF      ar_system_parameters.unearned_discount%type;
		TYPE  partialdiscountflagTable
                        IS TABLE OF       ar_system_parameters.partial_discount_flag%type;
		TYPE  printremittoTable
                        IS TABLE OF       ar_system_parameters.print_remit_to%type;
		TYPE  defaultcbduedateTable
                        IS TABLE OF       ar_system_parameters.default_cb_due_date%type;
		TYPE  autositenumberingTable
                        IS TABLE OF       ar_system_parameters.auto_site_numbering%type;
		TYPE  cashbasissetofbooksidTable
                        IS TABLE OF       ar_system_parameters.cash_basis_set_of_books_id%type;
		TYPE  codecombinationidgainTable
                        IS TABLE OF       ar_system_parameters.code_combination_id_gain%type;
		TYPE  autocashhierarchyidTable
                        IS TABLE OF       ar_system_parameters.autocash_hierarchy_id%type;
		TYPE  rungljournalimportflagTable
                        IS TABLE OF       ar_system_parameters.run_gl_journal_import_flag%type;
		TYPE  cersplitamountTable
                        IS TABLE OF       ar_system_parameters.cer_split_amount%type;
		TYPE  cerdsodaysTable IS TABLE OF       ar_system_parameters.cer_dso_days%type;
		TYPE  postingdayspercycleTable
                        IS TABLE OF       ar_system_parameters.posting_days_per_cycle%type;
		TYPE  addressvalidationTable
                        IS TABLE OF       ar_system_parameters.address_validation%type;
		TYPE  calcdiscountonlinesflagTable
                        IS TABLE OF       ar_system_parameters.calc_discount_on_lines_flag%type;
		TYPE  changeprintedinvoiceflagTable
                        IS TABLE OF       ar_system_parameters.change_printed_invoice_flag%type;
		TYPE  codecombinationidlossTable
                        IS TABLE OF       ar_system_parameters.code_combination_id_loss%type;
		TYPE  createreciprocalflagTable
                        IS TABLE OF       ar_system_parameters.create_reciprocal_flag%type;
		TYPE  defaultcountryTable
                        IS TABLE OF       ar_system_parameters.default_country%type;
		TYPE  defaultterritoryTable
                        IS TABLE OF       ar_system_parameters.default_territory%type;
		TYPE  generatecustomernumberTable
                        IS TABLE OF       ar_system_parameters.generate_customer_number%type;
		TYPE  invoicedeletionflagTable
                        IS TABLE OF       ar_system_parameters.invoice_deletion_flag%type;
		TYPE  locationstructureidTable
                        IS TABLE OF       ar_system_parameters.location_structure_id%type;
		TYPE  siterequiredflagTable
                        IS TABLE OF       ar_system_parameters.site_required_flag%type;
		TYPE  taxallowcompoundflagTable
                        IS TABLE OF       ar_system_parameters.tax_allow_compound_flag%type;
		TYPE  taxheaderlevelflagTable
                        IS TABLE OF       ar_system_parameters.tax_header_level_flag%type;
		TYPE  taxroundingallowoverrideTable
                        IS TABLE OF       ar_system_parameters.tax_rounding_allow_override%type;
		TYPE  taxinvoiceprintTable
                        IS TABLE OF       ar_system_parameters.tax_invoice_print%type;
		TYPE  taxmethodTable   IS TABLE OF       ar_system_parameters.tax_method%type;
		TYPE  taxusecustomerexemptflagTable
                        IS TABLE OF       ar_system_parameters.tax_use_customer_exempt_flag%type;
		TYPE  taxusecustexcrateflagTable
                        IS TABLE OF       ar_system_parameters.tax_use_cust_exc_rate_flag%type;
		TYPE  taxuselocexcrateflagTable
                        IS TABLE OF       ar_system_parameters.tax_use_loc_exc_rate_flag%type;
		TYPE  taxuseproductexemptflagTable
                        IS TABLE OF       ar_system_parameters.tax_use_product_exempt_flag%type;
		TYPE  taxuseprodexcrateflagTable
                        IS TABLE OF       ar_system_parameters.tax_use_prod_exc_rate_flag%type;
		TYPE  taxusesiteexcrateflagTable
                        IS TABLE OF       ar_system_parameters.tax_use_site_exc_rate_flag%type;
		TYPE  ailogfilemessagelevelTable
                        IS TABLE OF       ar_system_parameters.ai_log_file_message_level%type;
		TYPE  aimaxmemoryinbytesTable
                        IS TABLE OF       ar_system_parameters.ai_max_memory_in_bytes%type;
		TYPE  aiacctflexkeyleftpromptTable
                        IS TABLE OF       ar_system_parameters.ai_acct_flex_key_left_prompt%type;
		TYPE  aimtlitemskeyleftpromptTable
                        IS TABLE OF       ar_system_parameters.ai_mtl_items_key_left_prompt%type;
		TYPE  aiterritorykeyleftpromptTable
                        IS TABLE OF       ar_system_parameters.ai_territory_key_left_prompt%type;
		TYPE  aipurgeinttablesflagTable
                        IS TABLE OF       ar_system_parameters.ai_purge_interface_tables_flag%type;
		TYPE  aiactivatesqltraceflagTable
                        IS TABLE OF       ar_system_parameters.ai_activate_sql_trace_flag%type;
		TYPE  defaultgroupingruleidTable
                        IS TABLE OF       ar_system_parameters.default_grouping_rule_id%type;
		TYPE  salesreprequiredflagTable
                        IS TABLE OF       ar_system_parameters.salesrep_required_flag%type;
		TYPE  autorecinvoicespercommitTable
                        IS TABLE OF       ar_system_parameters.auto_rec_invoices_per_commit%type;
		TYPE  autorecreceiptspercommitTable
                        IS TABLE OF       ar_system_parameters.auto_rec_receipts_per_commit%type;
		TYPE  payunrelatedinvoicesflagTable
                        IS TABLE OF       ar_system_parameters.pay_unrelated_invoices_flag%type;
		TYPE  printhomecountryflagTable
                        IS TABLE OF       ar_system_parameters.print_home_country_flag%type;
		TYPE  locationtaxaccountTable
                        IS TABLE OF       ar_system_parameters.location_tax_account%type;
		TYPE  frompostalcodeTable
                        IS TABLE OF       ar_system_parameters.from_postal_code%type;
		TYPE  topostalcodeTable
                        IS TABLE OF       ar_system_parameters.to_postal_code%type;
		TYPE  taxregistrationnumberTable
                        IS TABLE OF       ar_system_parameters.tax_registration_number%type;
		TYPE  populateglsegmentsflagTable
                        IS TABLE OF       ar_system_parameters.populate_gl_segments_flag%type;
		TYPE  unallocatedrevenueccidTable
                        IS TABLE OF       ar_system_parameters.unallocated_revenue_ccid%type;
		TYPE  periodsetnameTable
                        IS TABLE OF       gl_sets_of_books.period_set_name%type;
		TYPE  baseprecisionTable
                        IS TABLE OF       fnd_currencies.precision%type;
		TYPE  baseEXTENDEDPRECISIONTable
                        IS TABLE OF       fnd_currencies.EXTENDED_PRECISION%type;
		TYPE  baseMINACCOUNTABLEUNITTable
                        IS TABLE OF       fnd_currencies.MINIMUM_ACCOUNTABLE_UNIT%type;
		TYPE  salescreditnameTable
                        IS TABLE OF       ra_salesreps.name%type;
		TYPE  yesmeaningTable
                        IS TABLE OF       ar_lookups.meaning%type;
		TYPE  nomeaningTable
                        IS TABLE OF       ar_lookups.meaning%type;
                TYPE  taxexemptflagmeaning
                        IS TABLE OF       ar_lookups.meaning%type ;
		TYPE  inclusivetaxusedTable
                        IS TABLE OF       ar_system_parameters.inclusive_tax_used%type;
		TYPE  taxenforceaccountflagTable
                        IS TABLE OF       ar_system_parameters.tax_enforce_account_flag%type;
 --begin new chnages

                TYPE  tainstalledflagTable
                        IS TABLE OF 	ar_system_parameters.ta_installed_flag%type;
                TYPE  brenabledflagTable
                         IS TABLE OF 	ar_system_parameters.bills_receivable_enabled_flag%type;
                TYPE  attributecategoryTable
                         IS TABLE OF 	ar_system_parameters.attribute_category%type;
                TYPE  attribute1Table
                         IS TABLE OF 	ar_system_parameters.attribute1%type;
                TYPE  attribute2Table
                         IS TABLE OF 	ar_system_parameters.attribute2%type;
                TYPE  attribute3Table
                         IS TABLE OF 	ar_system_parameters.attribute3%type;
                TYPE  attribute4Table
                         IS TABLE OF 	ar_system_parameters.attribute4%type;
                TYPE  attribute5Table
                         IS TABLE OF 	ar_system_parameters.attribute5%type;
                TYPE  attribute6Table
                        IS TABLE OF 	ar_system_parameters.attribute6%type;
                TYPE  attribute7Table
                         IS TABLE OF 	ar_system_parameters.attribute7%type;
                TYPE  attribute8Table
                         IS TABLE OF 	ar_system_parameters.attribute8%type;
                TYPE  attribute9Table
                         IS TABLE OF 	ar_system_parameters.attribute9%type;
                TYPE  attribute10Table
                         IS TABLE OF 	ar_system_parameters.attribute10%type;
                TYPE  attribute11Table
                         IS TABLE OF 	ar_system_parameters.attribute11%type;
                TYPE  attribute12Table
                         IS TABLE OF 	ar_system_parameters.attribute12%type;
                TYPE  attribute13Table
                         IS TABLE OF 	ar_system_parameters.attribute13%type;
                TYPE  attribute14Table
                         IS TABLE OF 	ar_system_parameters.attribute14%type;
                TYPE  attribute15Table
                         IS TABLE OF 	ar_system_parameters.attribute15%type;
                TYPE  createdbyTable
                        IS TABLE OF 	ar_system_parameters.created_by%type;
                TYPE  creationdateTable
                         IS TABLE OF 	ar_system_parameters.creation_date%type;
                TYPE  lastupdatedbyTable
                         IS TABLE OF 	ar_system_parameters.last_updated_by%type;
                TYPE  lastupdatedateTable
                         IS TABLE OF 	ar_system_parameters.last_update_date%type;
                TYPE  lastupdateloginTable
                         IS TABLE OF 	ar_system_parameters.last_update_login%type;
                TYPE  taxcodeTable
                         IS TABLE OF 	ar_system_parameters.tax_code%type;
                TYPE  taxcurrencycodeTable
                         IS TABLE OF 	ar_system_parameters.tax_currency_code%type;
                TYPE  taxminimumaccountableunitTable
                         IS TABLE OF 	ar_system_parameters.tax_minimum_accountable_unit%type;
                TYPE  taxprecisionTable
                         IS TABLE OF 	ar_system_parameters.tax_precision%type;
                TYPE  taxroundingruleTable
                         IS TABLE OF 	ar_system_parameters.tax_rounding_rule%type;
                TYPE  taxuseaccountexcrateflagTable
                          IS TABLE OF 	ar_system_parameters.tax_use_account_exc_rate_flag%type;
                TYPE  taxusesystemexcrateflagTable
                         IS TABLE OF 	ar_system_parameters.tax_use_system_exc_rate_flag%type;
                TYPE  taxhiersiteexcrateTable
                          IS TABLE OF 	ar_system_parameters.tax_hier_site_exc_rate%type;
                TYPE  taxhiercustexcrateTable
                          IS TABLE OF   ar_system_parameters.tax_hier_cust_exc_rate%type;
                TYPE  taxhierprodexcrateTable
                          IS TABLE OF 	ar_system_parameters.tax_hier_prod_exc_rate%type;
                TYPE  taxhieraccountexcrateTable
                           IS TABLE OF 	ar_system_parameters.tax_hier_account_exc_rate%type;
                TYPE  taxhiersystemexcrateTable
                           IS TABLE OF 	ar_system_parameters.tax_hier_system_exc_rate%type;
                TYPE  taxdatabaseviewsetTable
                           IS TABLE OF 	ar_system_parameters.tax_database_view_set%type;
                TYPE  globalattribute1Table
                           IS TABLE OF 	ar_system_parameters.global_attribute1%type;
                TYPE  globalattribute2Table
                            IS TABLE OF 	ar_system_parameters.global_attribute2%type;
                TYPE  globalattribute3Table
                           IS TABLE OF 	ar_system_parameters.global_attribute3%type;
                TYPE  globalattribute4Table
                           IS TABLE OF 	ar_system_parameters.global_attribute4%type;
                TYPE  globalattribute5Table
                           IS TABLE OF 	ar_system_parameters.global_attribute5%type;
                TYPE  globalattribute6Table
                           IS TABLE OF 	ar_system_parameters.global_attribute6%type;
                TYPE  globalattribute7Table
                           IS TABLE OF 	ar_system_parameters.global_attribute7%type;
                TYPE  globalattribute8Table
                           IS TABLE OF 	ar_system_parameters.global_attribute8%type;
                TYPE  globalattribute9Table
                           IS TABLE OF 	ar_system_parameters.global_attribute9%type;
                TYPE  globalattribute10Table
                           IS TABLE OF 	ar_system_parameters.global_attribute10%type;
                TYPE  globalattribute11Table
                           IS TABLE OF 	ar_system_parameters.global_attribute11%type;
                TYPE  globalattribute12Table
                           IS TABLE OF 	ar_system_parameters.global_attribute12%type;
                TYPE  globalattribute13Table
                           IS TABLE OF 	ar_system_parameters.global_attribute13%type;
                TYPE  globalattribute14Table
                           IS TABLE OF 	ar_system_parameters.global_attribute14%type;
                TYPE  globalattribute15Table
                           IS TABLE OF 	ar_system_parameters.global_attribute15%type;
                TYPE  globalattribute16Table
                           IS TABLE OF 	ar_system_parameters.global_attribute16%type;
                TYPE  globalattribute17Table
                           IS TABLE OF 	ar_system_parameters.global_attribute17%type;
                TYPE  globalattribute18Table
                           IS TABLE OF 	ar_system_parameters.global_attribute18%type;
                TYPE  globalattribute19Table
                           IS TABLE OF 	ar_system_parameters.global_attribute19%type;
                TYPE  globalattribute20Table
                           IS TABLE OF 	ar_system_parameters.global_attribute20%type;
                TYPE  globalattributecategoryTable
                           IS TABLE OF 	ar_system_parameters.global_attribute_category%type;
                TYPE  rulesetidTable
                          IS TABLE OF 	ar_system_parameters.rule_set_id%type;
                TYPE  codecombinationidroundTable
                           IS TABLE OF 	ar_system_parameters.code_combination_id_round%type;
                TYPE  trxheaderlevelroundingTable
                           IS TABLE OF 	ar_system_parameters.trx_header_level_rounding%type;
                TYPE  trxheaderroundccidTable
                           IS TABLE OF 	ar_system_parameters.trx_header_round_ccid%type;
                TYPE  finchrgreceivablestrxidTable
                           IS TABLE OF 	ar_system_parameters.finchrg_receivables_trx_id%type;
                TYPE  salestaxgeocodeTable
                           IS TABLE OF 	ar_system_parameters.sales_tax_geocode%type;
                TYPE  revtransferclearccidTable
                           IS TABLE OF 	ar_system_parameters.rev_transfer_clear_ccid%type;
                TYPE  salescreditpctlimitTable
                            IS TABLE OF 	ar_system_parameters.sales_credit_pct_limit%type;
                TYPE  maxwrtoffamountTable
                          IS TABLE OF 	ar_system_parameters.max_wrtoff_amount%type;
                TYPE  irecccreceiptmethodidTable
                           IS TABLE OF 	ar_system_parameters.irec_cc_receipt_method_id%type;
                TYPE  showbillingnumberflagTable
                           IS TABLE OF 	ar_system_parameters.show_billing_number_flag%type;
                TYPE  crosscurrencyratetypeTable
                          IS TABLE OF 	ar_system_parameters.cross_currency_rate_type%type;
                TYPE  documentseqgenlevelTable
                           IS TABLE OF 	ar_system_parameters.document_seq_gen_level%type;
                TYPE  calctaxoncreditmemoflagTable
                          IS TABLE OF 	ar_system_parameters.calc_tax_on_credit_memo_flag%type;
                TYPE  irecbareceiptmethodidTable
                          IS TABLE OF 	ar_system_parameters.IREC_BA_RECEIPT_METHOD_ID%type;
                TYPE  paymentthresholdTable
                          IS TABLE OF ar_system_parameters.payment_threshold%type;
                TYPE  standardrefundTable
                          IS TABLE OF ar_system_parameters.standard_refund%type;
                TYPE  creditclassification1Table
                          IS TABLE OF ar_system_parameters.credit_classification1%type;
                TYPE  creditclassification2Table
                          IS TABLE OF ar_system_parameters.credit_classification2%type;
                TYPE  creditclassification3Table
                          IS TABLE OF ar_system_parameters.credit_classification3%type;
                TYPE  unmtchclaimcreationflagTable
                          IS TABLE OF ar_system_parameters.unmtch_claim_creation_flag%type;
                TYPE  matchedclaimcreationflagTable
                          IS TABLE OF ar_system_parameters.matched_claim_creation_flag%type;
                TYPE  matchedclaimexclcmflagTable
                          IS TABLE OF ar_system_parameters.matched_claim_excl_cm_flag%type;
                TYPE  minwrtoffamountTable
                          IS TABLE OF ar_system_parameters.min_wrtoff_amount%type;
                TYPE  minrefundamountTable
                          IS TABLE OF ar_system_parameters.min_refund_amount%type;
                TYPE  tminstalledflagTable
                          IS TABLE OF 	VARCHAR2(1);
                TYPE  tmdefaultsetupflagTable
                          IS TABLE OF 	VARCHAR2(1);
                TYPE  createdetaileddistflagTable
                          IS TABLE OF ar_system_parameters.create_detailed_dist_flag%type;
--end new changes

    /* ---------------------------------------------------------------
       End AR-specific nested tables definitions
       --------------------------------------------------------------- */

    /* ---------------------------------------------------------------
       Define a nested table for storing the operating unit IDs:
       ---------------------------------------------------------------  */

       TYPE OrgIDTable
                   IS TABLE OF hr_organization_information.organization_id%TYPE;

    /*  ---------------------------------------------------------------
        Define a record type that encapsulates multiple rows of
        operating unit attributes:
        ---------------------------------------------------------------  */


       TYPE GlobalsTable is record
                 (org_id_t                                OrgIDTable,
                  set_of_books_id_t                       SetOfBooksIDTable,
                  set_of_books_name_t                     SetOfBooksNameTable,
                  chart_of_accounts_id_t                  ChartOfAccountsIDTable,
                  currency_code_t                         CurrencyCodeTable,
            /* -----------------------------------------------------------------
                Begin AR-specific fields
                Additional fields   e.g.
                 <<column1_t>>                     <<column1Table>>
               -----------------------------------------------------------------   */
		  accounting_method_t			  accountingmethodTable,
		  accrue_interest_t			  accrueinterestTable,
		  unearned_discount_t			  unearneddiscountTable,
		  partial_discount_flag_t        	  partialdiscountflagTable,
		  print_remit_to_t        		  printremittoTable,
		  default_cb_due_date_t			  defaultcbduedateTable,
		  auto_site_numbering_t 		  autositenumberingTable ,
		  cash_basis_set_of_books_id_t 		  cashbasissetofbooksidTable ,
		  code_combination_id_gain_t		  codecombinationidgainTable,
		  autocash_hierarchy_id_t 		  autocashhierarchyidTable ,
		  run_gl_journal_import_flag_t		  rungljournalimportflagTable,
		  cer_split_amount_t     		  cersplitamountTable,
		  cer_dso_days_t 			  cerdsodaysTable ,
		  posting_days_per_cycle_t		  postingdayspercycleTable,
		  address_validation_t  		  addressvalidationTable,
		  calc_discount_on_lines_flag_t 	  calcdiscountonlinesflagTable ,
		  change_printed_invoice_flag_t		  changeprintedinvoiceflagTable,
		  code_combination_id_loss_t 		  codecombinationidlossTable,
		  create_reciprocal_flag_t		  createreciprocalflagTable,
		  default_country_t   			  defaultcountryTable,
		  default_territory_t 			  defaultterritoryTable,
		  generate_customer_number_t		  generatecustomernumberTable,
		  invoice_deletion_flag_t 		  invoicedeletionflagTable ,
		  location_structure_id_t		  locationstructureidTable,
		  site_required_flag_t			  siterequiredflagTable,
		  tax_allow_compound_flag_t 		  taxallowcompoundflagTable,
		  tax_header_level_flag_t 		  taxheaderlevelflagTable,
		  tax_rounding_allow_override_t 	  taxroundingallowoverrideTable ,
		  tax_invoice_print_t 			  taxinvoiceprintTable,
		  tax_method_t  			  taxmethodTable,
		  tax_use_customer_exempt_flag_t	  taxusecustomerexemptflagTable,
		  tax_use_cust_exc_rate_flag_t 		  taxusecustexcrateflagTable,
		  tax_use_loc_exc_rate_flag_t 		  taxuselocexcrateflagTable,
		  tax_use_product_exempt_flag_t   	  taxuseproductexemptflagTable,
		  tax_use_prod_exc_rate_flag_t		  taxuseprodexcrateflagTable,
		  tax_use_site_exc_rate_flag_t  	  taxusesiteexcrateflagTable,
		  ai_log_file_message_level_t 		  ailogfilemessagelevelTable,
		  ai_max_memory_in_bytes_t		  aimaxmemoryinbytesTable,
		  ai_acct_flex_key_left_prompt_t 	  aiacctflexkeyleftpromptTable,
		  ai_mtl_items_key_left_prompt_t  	  aimtlitemskeyleftpromptTable,
		  ai_territory_key_left_prompt_t 	  aiterritorykeyleftpromptTable,
		  ai_purge_int_tables_flag_t 		  aipurgeinttablesflagTable,
		  ai_activate_sql_trace_flag_t   	  aiactivatesqltraceflagTable,
		  default_grouping_rule_id_t  		  defaultgroupingruleidTable,
		  salesrep_required_flag_t     		  salesreprequiredflagTable,
		  auto_rec_invoices_per_commit_t 	  autorecinvoicespercommitTable ,
		  auto_rec_receipts_per_commit_t  	  autorecreceiptspercommitTable,
		  pay_unrelated_invoices_flag_t 	  payunrelatedinvoicesflagTable,
		  print_home_country_flag_t   		  printhomecountryflagTable,
		  location_tax_account_t    		  locationtaxaccountTable,
		  from_postal_code_t   			  frompostalcodeTable,
		  to_postal_code_t   			  topostalcodeTable,
		  tax_registration_number_t   		  taxregistrationnumberTable,
		  populate_gl_segments_flag_t 		  populateglsegmentsflagTable,
		  unallocated_revenue_ccid_t  		  unallocatedrevenueccidTable,
		  period_set_name_t     		  periodsetnameTable ,
		  base_precision_t   			  baseprecisionTable,
		  base_EXTENDED_PRECISION_t   		  baseEXTENDEDPRECISIONTable,
		  base_MIN_ACCOUNTABLE_UNIT_t  		  baseMINACCOUNTABLEUNITTable,
		  salescredit_name_t 			  salescreditnameTable,
		  yes_meaning_t     			  yesmeaningTable,
		  no_meaning_t       			  nomeaningTable,
                  tax_exempt_flag_meaning_t               taxexemptflagmeaning,
		  inclusive_tax_used_t    		  inclusivetaxusedTable,
		  tax_enforce_account_flag_t  		  taxenforceaccountflagTable,
--new changes begin
                   ta_installed_flag_t	                  tainstalledflagTable,
                   br_enabled_flag_t                      brenabledflagTable,

                   attribute_category_t	       		attributecategoryTable,
                   attribute1_t                		attribute1Table,
                   attribute2_t                		attribute2Table,
                   attribute3_t	               		attribute3Table,
                   attribute4_t                		attribute4Table,
                   attribute5_t                		attribute5Table,
                   attribute6_t                		attribute6Table,
                   attribute7_t               	 	attribute7Table,
                   attribute8_t                		attribute8Table,
                   attribute9_t                		attribute9Table,
                   attribute10_t               	 	attribute10Table,
                   attribute11_t                	attribute11Table,
                   attribute12_t                	attribute12Table,
                   attribute13_t                	attribute13Table,
                   attribute14_t                	attribute14Table,
                   attribute15_t	                attribute15Table,

                   created_by_t	               		createdbyTable,
                   creation_date_t                	creationdateTable,
                   last_updated_by_t                	lastupdatedbyTable,
                   last_update_date_t	                lastupdatedateTable,
                   last_update_login_t                	lastupdateloginTable,

                   tax_code_t                         	taxcodeTable,
                   tax_currency_code_t                	taxcurrencycodeTable,
                   tax_minimum_accountable_unit_t	taxminimumaccountableunitTable,
                   tax_precision_t			taxprecisionTable,
                   tax_rounding_rule_t			taxroundingruleTable,
                   tax_use_acc_exc_rate_flag_t	        taxuseaccountexcrateflagTable,
                   tax_use_system_exc_rate_flag_t	taxusesystemexcrateflagTable,
                   tax_hier_site_exc_rate_t		taxhiersiteexcrateTable,
                   tax_hier_cust_exc_rate_t		taxhiercustexcrateTable,
                   tax_hier_prod_exc_rate_t		taxhierprodexcrateTable,
                   tax_hier_account_exc_rate_t		taxhieraccountexcrateTable,
                   tax_hier_system_exc_rate_t		taxhiersystemexcrateTable,
                   tax_database_view_set_t		taxdatabaseviewsetTable,

                   global_attribute1_t			globalattribute1Table,
                   global_attribute2_t			globalattribute2Table,
                   global_attribute3_t			globalattribute3Table,
                   global_attribute4_t			globalattribute4Table,
                   global_attribute5_t			globalattribute5Table,
                   global_attribute6_t			globalattribute6Table,
                   global_attribute7_t			globalattribute7Table,
                   global_attribute8_t			globalattribute8Table,
                   global_attribute9_t			globalattribute9Table,
                   global_attribute10_t			globalattribute10Table,
                   global_attribute11_t			globalattribute11Table,
                   global_attribute12_t			globalattribute12Table,
                   global_attribute13_t			globalattribute13Table,
                   global_attribute14_t			globalattribute14Table,
                   global_attribute15_t			globalattribute15Table,
                   global_attribute16_t			globalattribute16Table,
                   global_attribute17_t			globalattribute17Table,
                   global_attribute18_t			globalattribute18Table,
                   global_attribute19_t			globalattribute19Table,
                   global_attribute20_t			globalattribute20Table,
                   global_attribute_category_t		globalattributecategoryTable,

                   rule_set_id_t			rulesetidTable,
                   code_combination_id_round_t		codecombinationidroundTable,
                   trx_header_level_rounding_t		trxheaderlevelroundingTable,
                   trx_header_round_ccid_t		trxheaderroundccidTable,
                   finchrg_receivables_trx_id_t		finchrgreceivablestrxidTable,
                   sales_tax_geocode_t			salestaxgeocodeTable,
                   rev_transfer_clear_ccid_t		revtransferclearccidTable,
                   sales_credit_pct_limit_t		salescreditpctlimitTable,
                   max_wrtoff_amount_t			maxwrtoffamountTable,
                   irec_cc_receipt_method_id_t		irecccreceiptmethodidTable,
                   show_billing_number_flag_t		showbillingnumberflagTable,
                   cross_currency_rate_type_t		crosscurrencyratetypeTable,
                   document_seq_gen_level_t		documentseqgenlevelTable,
                   calc_tax_on_credit_memo_flag_t	calctaxoncreditmemoflagTable,
                   irec_ba_receipt_method_id_t          irecbareceiptmethodidTable,
                   tm_installed_flag_t                  tminstalledflagTable,
                   tm_default_setup_flag_t              tmdefaultsetupflagTable,
                   payment_threshold_t                  paymentthresholdTable,
                   standard_refund_t                    standardrefundTable,
                   credit_classification1_t             creditclassification1Table,
                   credit_classification2_t             creditclassification2Table,
                   credit_classification3_t             creditclassification3Table,
                   unmtch_claim_creation_flag_t         unmtchclaimcreationflagTable,
                   matched_claim_creation_flag_t        matchedclaimcreationflagTable,
                   matched_claim_excl_cm_flag_t         matchedclaimexclcmflagTable,
                   min_wrtoff_amount_t                  minwrtoffamountTable,
                   min_refund_amount_t                  minrefundamountTable,
                   create_detailed_dist_flag_t		createdetaileddistflagTable
--new changes end
           /* -------------------------------------
              End AR-specific fields
              ------------------------------------  */       );

     /* ---------------------------------------------------------------------
        This procedure retrieves operating unit attributes from the database
        and stores them into the specified data structure.
        ----------------------------------------------------------------------     */

       PROCEDURE retrieve_globals( p_globals OUT NOCOPY Globalstable,
                                   p_org_id  IN NUMBER DEFAULT NULL);

       -- Bug 3251839 - tm_installed and tm_default_setup functions provide a
       -- wrapper to the TM boolean functions that can be called in sql

       FUNCTION tm_installed (p_org_id IN NUMBER DEFAULT NULL)
       RETURN VARCHAR2;

       FUNCTION tm_default_setup (p_org_id IN NUMBER DEFAULT NULL)
       RETURN VARCHAR2;

       PROCEDURE set_org_context_in_api(p_org_id         IN OUT NOCOPY NUMBER,
                                        p_return_status  OUT    NOCOPY VARCHAR2);

END ar_mo_cache_utils;

/
