--------------------------------------------------------
--  DDL for Package AP_MO_CACHE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_MO_CACHE_UTILS" AUTHID CURRENT_USER AS
/* $Header: apmocshs.pls 120.12.12010000.2 2008/11/11 13:04:06 dcshanmu ship $ */

  --
  -- Define a record type that encapsulates one row of operating
  -- unit attribute
  --
  TYPE GlobalsRecord IS RECORD (
  --
  -- Generic columns needed by all products
  --
  org_id                         hr_organization_information.organization_id%TYPE,
  set_of_books_id                gl_sets_of_books.set_of_books_id%TYPE,
  set_of_books_name              gl_sets_of_books.name%TYPE,
  set_of_books_short_name        gl_sets_of_books.short_name%TYPE,
  chart_of_accounts_id           gl_sets_of_books.chart_of_accounts_id%TYPE,
  enable_budget_control_flag     gl_sets_of_books.enable_budgetary_control_flag%TYPE,
  currency                       fnd_currencies.currency_code%TYPE,
  --
  -- << Begin AP-specific fields >>
  --
  sp_base_currency_code             ap_system_parameters.base_currency_code%TYPE,
  sp_multi_currency_flag            ap_system_parameters.multi_currency_flag%TYPE,
  --Bug :2809214 MOAC - Supplier Attribute Change Project
  --sp_invoice_currency_code         ap_product_setup.invoice_currency_code%TYPE,
  sp_payment_currency_code          ap_system_parameters.payment_currency_code%TYPE,
  sp_confirm_date_inv_num_flag      ap_system_parameters.confirm_date_as_inv_num_flag%TYPE,
  sp_accts_pay_cc_id                ap_system_parameters.accts_pay_code_combination_id%TYPE,
  sp_allow_flex_override_flag       ap_system_parameters.allow_flex_override_flag%TYPE,
  sp_allow_final_match_flag         ap_system_parameters.allow_final_match_flag%TYPE,
  sp_allow_dist_match_flag          ap_system_parameters.allow_dist_match_flag%TYPE,
  sp_gl_date_from_receipt_flag      ap_system_parameters.gl_date_from_receipt_flag%TYPE,
  sp_income_tax_region_flag         ap_system_parameters.income_tax_region_flag%TYPE,
  sp_income_tax_region              ap_system_parameters.income_tax_region%TYPE,
  sp_auto_create_freight_flag       ap_system_parameters.auto_create_freight_flag%TYPE,
  sp_default_freight_cc_id          ap_system_parameters.freight_code_combination_id%TYPE,
  sp_disc_is_inv_less_tax_flag      ap_system_parameters.disc_is_inv_less_tax_flag%TYPE,
  sp_discount_dist_method           ap_system_parameters.discount_distribution_method%TYPE,
  sp_inv_doc_category_override      ap_system_parameters.inv_doc_category_override%TYPE,
  sp_approvals_option               ap_system_parameters.approvals_option%TYPE,
  sp_combined_filing_flag           ap_system_parameters.combined_filing_flag%TYPE,
  sp_allow_awt_flag                 ap_system_parameters.allow_awt_flag%TYPE,
  sp_create_awt_dists_type          ap_system_parameters.create_awt_dists_type%TYPE,
  sp_allow_awt_override             ap_system_parameters.allow_awt_override%TYPE,
  sp_awt_include_tax_amt            ap_system_parameters.awt_include_tax_amt%TYPE,
  sp_awt_include_discount_amt       ap_system_parameters.awt_include_discount_amt%TYPE,
  sp_allow_paid_invoice_adjust      ap_system_parameters.allow_paid_invoice_adjust%TYPE,
  sp_add_days_settlement_date       ap_system_parameters.add_days_settlement_date%TYPE,
  sp_prepayment_terms_id            ap_system_parameters.prepayment_terms_id%TYPE,
  sp_ap_prepayment_term_name        ap_terms.name%TYPE,
  sp_prepay_cc_id                   ap_system_parameters.prepay_code_combination_id%TYPE,
 sp_future_dated_pmt_acct_s        ap_system_parameters.future_dated_pmt_acct_source%TYPE,
  sp_calc_user_xrate                ap_system_parameters.calc_user_xrate%TYPE,
  sp_make_rate_mandatory_flag       ap_system_parameters.make_rate_mandatory_flag%TYPE,
  sp_def_exchange_rate_type         ap_system_parameters.default_exchange_rate_type%TYPE,
  sp_post_dated_payments_flag       ap_system_parameters.post_dated_payments_flag%TYPE,
  sp_update_pay_site_flag           ap_system_parameters.update_pay_site_flag%TYPE,
  sp_online_print_flag              ap_system_parameters.online_print_flag%TYPE,
  sp_replace_check_flag             ap_system_parameters.replace_check_flag%TYPE,
  sp_auto_calc_interest_flag        ap_product_setup.auto_calculate_interest_flag%TYPE,
  sp_interest_tolerance_amount      ap_system_parameters.interest_tolerance_amount%TYPE,
  sp_interest_accts_pay_ccid        ap_system_parameters.interest_accts_pay_ccid%TYPE,
  --Bug :2809214 MOAC - Supplier Attribute Change Project
  --5007989, uncommented line below
  sp_use_bank_charge_flag           ap_system_parameters.use_bank_charge_flag%TYPE,
  sp_allow_supp_bank_override       ap_system_parameters.allow_supplier_bank_override%TYPE,
  sp_pay_doc_category_override      ap_system_parameters.pay_doc_category_override%TYPE,
  sp_days_between_check_cycles      ap_system_parameters.days_between_check_cycles%TYPE,
  sp_approval_workflow_flag         ap_system_parameters.approval_workflow_flag%TYPE,
  sp_allow_force_approval_flag      ap_system_parameters.allow_force_approval_flag%TYPE,
  sp_validate_before_approval       ap_system_parameters.validate_before_approval_flag%TYPE,
  sp_global_attribute_category      ap_system_parameters.global_attribute_category%TYPE,
  sp_global_attribute1              ap_system_parameters.global_attribute1%TYPE,
  sp_global_attribute2              ap_system_parameters.global_attribute2%TYPE,
  sp_global_attribute3              ap_system_parameters.global_attribute3%TYPE,
  sp_global_attribute4              ap_system_parameters.global_attribute4%TYPE,
  sp_global_attribute5              ap_system_parameters.global_attribute5%TYPE,
  sp_global_attribute6              ap_system_parameters.global_attribute6%TYPE,
  sp_global_attribute7              ap_system_parameters.global_attribute7%TYPE,
  sp_global_attribute8              ap_system_parameters.global_attribute8%TYPE,
  sp_global_attribute9              ap_system_parameters.global_attribute9%TYPE,
  sp_global_attribute10             ap_system_parameters.global_attribute10%TYPE,
  sp_global_attribute11             ap_system_parameters.global_attribute11%TYPE,
  sp_global_attribute12             ap_system_parameters.global_attribute12%TYPE,
  sp_global_attribute13             ap_system_parameters.global_attribute13%TYPE,
  sp_global_attribute14             ap_system_parameters.global_attribute14%TYPE,
  sp_global_attribute15             ap_system_parameters.global_attribute15%TYPE,
  sp_global_attribute16             ap_system_parameters.global_attribute16%TYPE,
  sp_global_attribute17             ap_system_parameters.global_attribute17%TYPE,
  sp_global_attribute18             ap_system_parameters.global_attribute18%TYPE,
  sp_global_attribute19             ap_system_parameters.global_attribute19%TYPE,
  sp_global_attribute20             ap_system_parameters.global_attribute20%TYPE,
  fsp_purch_encumbrance_flag        financials_system_parameters.purch_encumbrance_flag%TYPE,
  fsp_inventory_org_id              financials_system_parameters.inventory_organization_id%TYPE,
  --Bug :2809214 MOAC - Supplier Attribute Change Project
  --fsp_match_option                  ap_product_setup.match_option%TYPE,
  fsp_vat_country_code              financials_system_parameters.vat_country_code%TYPE,
  sp_aba_bank_account_id            ap_system_parameters.ce_bank_acct_use_id%TYPE,
  sp_aba_bank_account_name          ce_bank_accounts.bank_account_name%TYPE,
  sp_aba_zero_amounts_allowed       ce_bank_accounts.zero_amount_allowed%TYPE,
  sp_aba_max_outlay                 ce_bank_accounts.max_outlay%TYPE,
  sp_aba_max_check_amount           ce_bank_accounts.max_check_amount%TYPE,
  sp_aba_min_check_amount           ce_bank_accounts.min_check_amount%TYPE,
  sp_aba_currency_code              ce_bank_accounts.currency_code%TYPE,
  sp_aba_multi_currency_flag        ce_bank_accounts.multi_currency_allowed_flag%TYPE,
  sp_gdct_user_conversion_type      gl_daily_conversion_types.user_conversion_type%TYPE,
  mrc_enabled                       Varchar2(1) ,
  sp_allow_interest_invoices        ap_system_parameters.auto_calculate_interest_flag%TYPE,
  sp_approval_timing                ap_system_parameters.approval_timing%TYPE,  --Bug4299234
  fsp_misc_charge_ccid              financials_system_params_all.misc_charge_ccid%TYPE, --bugfix:4936051
  --Third Party Payments
  sp_allow_inv_third_party_ovrd	ap_system_parameters.allow_inv_third_party_ovrd%TYPE,
  sp_allow_pymt_third_party_ovrd	ap_system_parameters.allow_pymt_third_party_ovrd%TYPE
  --
  -- << End AP-specific fields >>
  --
  );

  --
  -- Define data types (nested tables) for storing columns of
  -- the widely used operating unit attributes:
  -- Define a nested table type for storing the org_ids. This is
  -- mandatory
  --
  TYPE OrgIDTable                 IS TABLE OF hr_organization_information.organization_id%TYPE;
  -- Other nested table definitions. They should correspond to
  -- the fields of the record defined above.
  TYPE SetOfBooksIDTable          IS TABLE OF gl_sets_of_books.set_of_books_id%TYPE;
  TYPE SetOfBooksNameTable        IS TABLE OF gl_sets_of_books.name%TYPE;
  TYPE SetOfBooksShortNameTable   IS TABLE OF gl_sets_of_books.short_name%TYPE;
  TYPE ChartOfAccountsIDTable     IS TABLE OF gl_sets_of_books.chart_of_accounts_id%TYPE;
  TYPE EnableBudgetaryFlagTable   IS TABLE OF gl_sets_of_books.enable_budgetary_control_flag%TYPE;
  TYPE CurrencyCodeTable          IS TABLE OF fnd_currencies.currency_code%TYPE;
  --
  -- << Begin AP-specific nested tables definitions >>
  --
  TYPE BaseCurrencyCodeTable      IS TABLE OF ap_system_parameters.base_currency_code%TYPE;
  TYPE MultiCurrencyFlagTable     IS TABLE OF ap_system_parameters.multi_currency_flag%TYPE;
  TYPE PaymentCurrencyCodeTable   IS TABLE OF ap_system_parameters.payment_currency_code%TYPE;
  TYPE ConfirmDateAsInvNumFlagTable  IS TABLE OF ap_system_parameters.confirm_date_as_inv_num_flag%TYPE;
  TYPE AcctspaycodecombinationidTable IS TABLE OF ap_system_parameters.accts_pay_code_combination_id%TYPE;
  TYPE allowflexoverrideflagTable IS TABLE OF ap_system_parameters.allow_flex_override_flag%TYPE;
  TYPE allowfinalmatchflagTable   IS TABLE OF ap_system_parameters.allow_final_match_flag%TYPE;
  TYPE allowdistmatchflagTable    IS TABLE OF ap_system_parameters.allow_dist_match_flag%TYPE;
  TYPE gldatefromreceiptflagTable IS TABLE OF ap_system_parameters.gl_date_from_receipt_flag%TYPE;
  TYPE incometaxregionflagTable   IS TABLE OF ap_system_parameters.income_tax_region_flag%TYPE;
  TYPE incometaxregionTable       IS TABLE OF ap_system_parameters.income_tax_region%TYPE;
  TYPE autocreatefreightflagTable IS TABLE OF ap_system_parameters.auto_create_freight_flag%TYPE;
  TYPE freightcodecombinationidTable IS TABLE OF ap_system_parameters.freight_code_combination_id%TYPE;
  TYPE discisinvlesstaxflagTable  IS TABLE OF ap_system_parameters.disc_is_inv_less_tax_flag%TYPE;
  TYPE discountdistmethodTable IS TABLE OF ap_system_parameters.discount_distribution_method%TYPE;
  TYPE invdoccategoryoverrideTable IS TABLE OF ap_system_parameters.inv_doc_category_override%TYPE;
  TYPE approvalsoptionTable       IS TABLE OF ap_system_parameters.approvals_option%TYPE;
  TYPE combinedfilingflagTable    IS TABLE OF ap_system_parameters.combined_filing_flag%TYPE;
  TYPE allowawtflagTable          IS TABLE OF ap_system_parameters.allow_awt_flag%TYPE;
  TYPE createawtdiststypeTable    IS TABLE OF ap_system_parameters.create_awt_dists_type%TYPE;
  TYPE allowawtoverrideTable      IS TABLE OF ap_system_parameters.allow_awt_override%TYPE;
  TYPE awtincludetaxamtTable      IS TABLE OF ap_system_parameters.awt_include_tax_amt%TYPE;
  TYPE awtincludediscountamtTable IS TABLE OF ap_system_parameters.awt_include_discount_amt%TYPE;
  TYPE allowpaidinvoiceadjustTable IS TABLE OF ap_system_parameters.allow_paid_invoice_adjust%TYPE;
  TYPE adddayssettlementdateTable IS TABLE OF ap_system_parameters.add_days_settlement_date%TYPE;
  TYPE prepaymenttermsidTable     IS TABLE OF ap_system_parameters.prepayment_terms_id%TYPE;
  TYPE prepaymenttermnameTable    IS TABLE OF ap_terms.name%TYPE;
  TYPE prepaycodecombinationidTable IS TABLE OF ap_system_parameters.prepay_code_combination_id%TYPE;
  TYPE futuredatedpmtacctsourceTable IS TABLE OF ap_system_parameters.future_dated_pmt_acct_source%TYPE;
  TYPE calcuserxrateTable         IS TABLE OF ap_system_parameters.calc_user_xrate%TYPE;
  TYPE makeratemandatoryflagTable IS TABLE OF ap_system_parameters.make_rate_mandatory_flag%TYPE;
  TYPE defaultexchangeratetypeTable IS TABLE OF ap_system_parameters.default_exchange_rate_type%TYPE;
  TYPE postdatedpaymentsflagTable IS TABLE OF ap_system_parameters.post_dated_payments_flag%TYPE;
  TYPE updatepaysiteflagTable     IS TABLE OF ap_system_parameters.update_pay_site_flag%TYPE;
  TYPE onlineprintflagTable       IS TABLE OF ap_system_parameters.online_print_flag%TYPE;
  TYPE replacecheckflagTable      IS TABLE OF ap_system_parameters.replace_check_flag%TYPE;
  TYPE autocalculateinterestflagTable IS TABLE OF ap_product_setup.auto_calculate_interest_flag%TYPE;
  TYPE interesttoleranceamountTable IS TABLE OF ap_system_parameters.interest_tolerance_amount%TYPE;
  TYPE interestacctspayccidTable  IS TABLE OF ap_system_parameters.interest_accts_pay_ccid%TYPE;
  /* bug 5007989 */
  TYPE usebankchargeflagTable     IS TABLE OF ap_system_parameters.use_bank_charge_flag%TYPE;
  TYPE allowsupplierbankoverrideTable IS TABLE OF ap_system_parameters.allow_supplier_bank_override%TYPE;
  TYPE paydoccategoryoverrideTable IS TABLE OF ap_system_parameters.pay_doc_category_override%TYPE;
  TYPE daysbetweencheckcyclesTable IS TABLE OF ap_system_parameters.days_between_check_cycles%TYPE;
  TYPE approvalworkflowflagTable  IS TABLE OF ap_system_parameters.approval_workflow_flag%TYPE;
  TYPE allowforceapprovalflagTable IS Table OF ap_system_parameters.allow_force_approval_flag%TYPE;
  TYPE validatebeforeapprovalTable IS Table OF ap_system_parameters.validate_before_approval_flag%TYPE;
  TYPE globalattributecategoryTable IS TABLE OF ap_system_parameters.global_attribute_category%TYPE;
  TYPE globalattribute1Table      IS TABLE OF ap_system_parameters.global_attribute1%TYPE;
  TYPE purchencumbranceflagTable  IS TABLE OF financials_system_parameters.purch_encumbrance_flag%TYPE;
  TYPE inventoryorganizationidTable IS TABLE OF financials_system_parameters.inventory_organization_id%TYPE;
  TYPE vatcountrycodeTable        IS TABLE OF financials_system_parameters.vat_country_code%TYPE;
  TYPE bankaccountidTable         IS TABLE OF ap_system_parameters.ce_bank_acct_use_id%TYPE;
  TYPE bankaccountnameTable       IS TABLE OF ce_bank_accounts.bank_account_name%TYPE;
  TYPE zeroamountsallowedTable    IS TABLE OF ce_bank_accounts.zero_amount_allowed%TYPE;
  TYPE maxoutlayTable             IS TABLE OF ce_bank_accounts.max_outlay%TYPE;
  TYPE maxcheckamountTable        IS TABLE OF ce_bank_accounts.max_check_amount%TYPE;
  TYPE mincheckamountTable        IS TABLE OF ce_bank_accounts.min_check_amount%TYPE;
  TYPE bankcurrencycodeTable      IS TABLE OF ce_bank_accounts.currency_code%TYPE;
  TYPE bankmulticurrencyflagTable IS TABLE OF ce_bank_accounts.multi_currency_allowed_flag%TYPE;
  TYPE userconversiontypeTable    IS TABLE OF gl_daily_conversion_types.user_conversion_type%TYPE;
  TYPE mrcenabledtypeTable        IS TABLE OF Varchar2(1) INDEX BY BINARY_INTEGER;
  TYPE AllowInterestInvoicesTable IS TABLE OF ap_system_parameters.auto_calculate_interest_flag%TYPE;
  TYPE approval_timingTable       IS TABLE OF ap_system_parameters.approval_timing%TYPE;  --Bug4299234
  TYPE MiscChargeCcidTable        IS TABLE OF financials_system_parameters.misc_charge_ccid%TYPE; --Bug4936051
  --Third Party Payments
  TYPE allowInvThirdPartyOvrdTable IS TABLE OF ap_system_parameters.allow_inv_third_party_ovrd%TYPE;
  TYPE allowPymtThirdPartyOvrdTable IS TABLE OF ap_system_parameters.allow_pymt_third_party_ovrd%TYPE;
  -- << End AP-specific nested tables definitions >>
  --
  -- Define a record type that encapsulates multiple rows of
  -- operating unit attributes:
  --
  TYPE GlobalsTable IS RECORD(
    org_id_t                            OrgIDTable,
    set_of_books_id_t                   SetOfBooksIDTable,
    set_of_books_name_t                 SetOfBooksNameTable,
    set_of_books_short_name_t           SetOfBooksShortNameTable,
    chart_of_accounts_id_t              ChartOfAccountsIDTable,
    enable_budget_control_flag_t        EnableBudgetaryFlagTable,
    currency_code_t                     CurrencyCodeTable,
    --
    -- << Begin AP-specific fields >>
    --
    sp_base_currency_code_t             BaseCurrencyCodeTable,
    sp_multi_currency_flag_t            MultiCurrencyFlagTable,
    sp_payment_currency_code_t          PaymentCurrencyCodeTable,
    sp_confirm_date_inv_num_flag_t      ConfirmDateAsInvNumFlagTable,
    sp_accts_pay_cc_id_t                AcctspaycodecombinationidTable,
    sp_allow_flex_override_flag_t       allowflexoverrideflagTable,
    sp_allow_final_match_flag_t         allowfinalmatchflagTable,
    sp_allow_dist_match_flag_t          allowdistmatchflagTable,
    sp_gl_date_from_receipt_flag_t      gldatefromreceiptflagTable,
    sp_income_tax_region_flag_t         incometaxregionflagTable,
    sp_income_tax_region_t              incometaxregionTable,
    sp_auto_create_freight_flag_t       autocreatefreightflagTable,
    sp_default_freight_cc_id_t          freightcodecombinationidTable,
    sp_disc_is_inv_less_tax_flag_t      discisinvlesstaxflagTable,
    sp_discount_dist_method_t           discountdistmethodTable,
    sp_inv_doc_category_override_t      invdoccategoryoverrideTable,
    sp_approvals_option_t              approvalsoptionTable,
    sp_combined_filing_flag_t           combinedfilingflagTable,
    sp_allow_awt_flag_t                 allowawtflagTable,
    sp_create_awt_dists_type_t          createawtdiststypeTable,
    sp_allow_awt_override_t             allowawtoverrideTable,
    sp_awt_include_tax_amt_t            awtincludetaxamtTable,
    sp_awt_include_discount_amt_t       awtincludediscountamtTable,
    sp_allow_paid_invoice_adjust_t      allowpaidinvoiceadjustTable,
    sp_add_days_settlement_date_t       adddayssettlementdateTable,
    sp_prepayment_terms_id_t            prepaymenttermsidTable,
    sp_ap_prepayment_term_name_t        prepaymenttermnameTable,
    sp_prepay_cc_id_t                   prepaycodecombinationidTable,
    sp_future_dated_pmt_acct_s_t        futuredatedpmtacctsourceTable,
    sp_calc_user_xrate_t                calcuserxrateTable,
    sp_make_rate_mandatory_flag_t       makeratemandatoryflagTable,
    sp_def_exchange_rate_type_t         defaultexchangeratetypeTable,
    sp_post_dated_payments_flag_t       postdatedpaymentsflagTable,
    sp_update_pay_site_flag_t           updatepaysiteflagTable,
    sp_online_print_flag_t              onlineprintflagTable,
    sp_replace_check_flag_t             replacecheckflagTable,
    sp_auto_calc_interest_flag_t       autocalculateinterestflagTable,
    sp_interest_tolerance_amount_t      interesttoleranceamountTable,
    sp_interest_accts_pay_ccid_t        interestacctspayccidTable,
    sp_use_bank_charge_flag_t           usebankchargeflagTable, /* bug 5007989 */
    sp_allow_supp_bank_override_t       allowsupplierbankoverrideTable,
    sp_pay_doc_category_override_t      paydoccategoryoverrideTable,
    sp_days_between_check_cycles_t      daysbetweencheckcyclesTable,
    sp_approval_workflow_flag_t         approvalworkflowflagTable,
    sp_allow_force_approval_flag_t      allowforceapprovalflagTable,
    sp_validate_before_approval_t       validatebeforeapprovalTable,
    sp_global_attribute_category_t      globalattributecategoryTable,
    sp_global_attribute1_t              globalattribute1Table,
    sp_global_attribute2_t              globalattribute1Table,
    sp_global_attribute3_t              globalattribute1Table,
    sp_global_attribute4_t              globalattribute1Table,
    sp_global_attribute5_t              globalattribute1Table,
    sp_global_attribute6_t              globalattribute1Table,
    sp_global_attribute7_t              globalattribute1Table,
    sp_global_attribute8_t              globalattribute1Table,
    sp_global_attribute9_t              globalattribute1Table,
    sp_global_attribute10_t             globalattribute1Table,
    sp_global_attribute11_t             globalattribute1Table,
    sp_global_attribute12_t             globalattribute1Table,
    sp_global_attribute13_t             globalattribute1Table,
    sp_global_attribute14_t             globalattribute1Table,
    sp_global_attribute15_t             globalattribute1Table,
    sp_global_attribute16_t             globalattribute1Table,
    sp_global_attribute17_t             globalattribute1Table,
    sp_global_attribute18_t             globalattribute1Table,
    sp_global_attribute19_t             globalattribute1Table,
    sp_global_attribute20_t             globalattribute1Table,
    fsp_purch_encumbrance_flag_t        purchencumbranceflagTable,
    fsp_inventory_org_id_t              inventoryorganizationidTable,
    fsp_vat_country_code_t              vatcountrycodeTable,
    sp_aba_bank_account_id_t            bankaccountidTable,
    sp_aba_bank_account_name_t          bankaccountnameTable,
    sp_aba_zero_amounts_allowed_t       zeroamountsallowedTable,
    sp_aba_max_outlay_t                 maxoutlayTable,
    sp_aba_max_check_amount_t           maxcheckamountTable,
    sp_aba_min_check_amount_t           mincheckamountTable,
    sp_aba_currency_code_t              bankcurrencycodeTable,
    sp_aba_multi_currency_flag_t        bankmulticurrencyflagTable,
    sp_gdct_user_conversion_type_t      userconversiontypeTable,
    mrc_enabled_t                       mrcenabledtypeTable  ,
    sp_allow_interest_invoices_t        allowinterestinvoicesTable,
    sp_approval_timing_t                approval_timingTable,  --Bug4299234
    fsp_misc_charge_ccid_t              miscchargeccidTable,    --Bug4936051
    --Third Party Payments
    sp_allow_inv_thrd_prty_ovrd_t	 allowInvThirdPartyOvrdTable,
    sp_allow_pymt_thrd_prty_ovrd_t allowPymtThirdPartyOvrdTable
    -- << End AP-specific fields >>
     );


    --
    -- This procedure retrieves operating unit attributes from the
    -- database and stores them into the specified data structure.
    --
    PROCEDURE retrieve_globals(p_globals OUT NOCOPY GlobalsTable);

END ap_mo_cache_utils;

/
