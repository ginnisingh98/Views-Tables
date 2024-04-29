--------------------------------------------------------
--  DDL for Package PN_MO_CACHE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_MO_CACHE_UTILS" AUTHID CURRENT_USER AS
/* $Header: PNMOCSHS.pls 120.7 2007/09/11 16:25:04 rthumma ship $ */

  --
  -- Define a record type that encapsulates one row of operating
  -- unit attributes
  --

  g_MOAC_enabled BOOLEAN := TRUE;

  TYPE GlobalsRecord IS RECORD (

  set_of_books_name              gl_sets_of_books.name%TYPE,
  chart_of_accounts_id           gl_sets_of_books.chart_of_accounts_id%TYPE,
  legal_entity_name              hr_legal_entities.name%TYPE,
  functional_currency_code       fnd_currencies.currency_code%TYPE,
  set_of_books_id                pn_system_setup_options.set_of_books_id%TYPE,
  accounting_option              pn_system_setup_options.accounting_option%TYPE,
  default_currency_conv_type     pn_system_setup_options.default_currency_conv_type%TYPE,
  space_assign_sysdate_optn      pn_system_setup_options.space_assign_sysdate_optn%TYPE,
  multiple_tenancy_lease         pn_system_setup_options.multiple_tenancy_lease%TYPE,
  auto_comp_num_gen              pn_system_setup_options.auto_comp_num_gen%TYPE,
  auto_index_num_gen             pn_system_setup_options.auto_index_num_gen%TYPE,
  auto_lease_num_gen             pn_system_setup_options.auto_lease_num_gen%TYPE,
  auto_space_distribution        pn_system_setup_options.auto_space_distribution%TYPE,
  auto_var_rent_num_gen          pn_system_setup_options.auto_var_rent_num_gen%TYPE,
  auto_rec_agr_num_flag          pn_system_setup_options.auto_rec_agr_num_flag%TYPE,
  auto_rec_exp_num_flag          pn_system_setup_options.auto_rec_exp_num_flag%TYPE,
  auto_rec_arcl_num_flag         pn_system_setup_options.auto_rec_arcl_num_flag%TYPE,
  auto_rec_expcl_num_flag        pn_system_setup_options.auto_rec_expcl_num_flag%TYPE,
  cons_rec_agrterms_flag         pn_system_setup_options.cons_rec_agrterms_flag%TYPE,
  location_code_separator        pn_system_setup_options.location_code_separator%TYPE,
  default_locn_area_flag         pn_system_setup_options.default_locn_area_flag%TYPE,
  grouping_rule_id               pn_system_setup_options.grouping_rule_id%TYPE,
  gl_transfer_mode               pn_system_setup_options.gl_transfer_mode%TYPE,
  submit_journal_import_flag     pn_system_setup_options.submit_journal_import_flag%TYPE,
  legacy_data_cutoff_date        pn_system_setup_options.legacy_data_cutoff_date%TYPE,
  default_user_view_code         pn_system_setup_options.default_user_view_code%TYPE,
  extend_indexrent_term_flag     pn_system_setup_options.extend_indexrent_term_flag%TYPE,
  sysdate_for_adj_flag           pn_system_setup_options.sysdate_for_adj_flag%TYPE,
  sysdate_as_trx_date_flag       pn_system_setup_options.sysdate_as_trx_date_flag%TYPE,
  renorm_adj_acc_all_draft_flag  pn_system_setup_options.renorm_adj_acc_all_draft_flag%TYPE,
  consolidate_adj_items_flag     pn_system_setup_options.consolidate_adj_items_flag%TYPE,
  calc_annualized_basis_code     pn_system_setup_options.calc_annualized_basis_code%TYPE,
  allow_tenancy_overlap_flag     pn_system_setup_options.allow_tenancy_overlap_flag%TYPE,
  recalc_ir_on_acc_chg_flag      pn_system_setup_options.recalc_ir_on_acc_chg_flag%TYPE,
  smallest_term_amount           pn_system_setup_options.smallest_term_amount%TYPE,--#@#Bug4291907
  incl_terms_by_default_flag     pn_system_setup_options.incl_terms_by_default_flag%TYPE
  );

  TYPE OrgIDTable                   IS TABLE OF hr_organization_information.organization_id %TYPE;
  TYPE SetOfBooksNameTable          IS TABLE OF gl_sets_of_books.name%TYPE;
  TYPE ChartOfAccountsIDTable       IS TABLE OF gl_sets_of_books.chart_of_accounts_id%TYPE;
  TYPE LegalEntityNameTable         IS TABLE OF hr_legal_entities.name%TYPE;
  TYPE FunctionalCurrencyCodeTable  IS TABLE OF fnd_currencies.currency_code%TYPE;
  TYPE SetOfBooksIDTable            IS TABLE OF pn_system_setup_options.set_of_books_id%TYPE;
  TYPE AccountingOptionTable        IS TABLE OF pn_system_setup_options.accounting_option%TYPE;
  TYPE DefaultCurrencyConvTypeTable IS TABLE OF pn_system_setup_options.default_currency_conv_type%TYPE;
  TYPE SpaceAssignSysdateOptnTable  IS TABLE OF pn_system_setup_options.space_assign_sysdate_optn%TYPE;
  TYPE MultipleTenancyLeaseTable    IS TABLE OF pn_system_setup_options.multiple_tenancy_lease%TYPE;
  TYPE AutoSpaceDistributionTable   IS TABLE OF pn_system_setup_options.auto_space_distribution%TYPE;
  TYPE AutoCompNumGenTable          IS TABLE OF pn_system_setup_options.auto_comp_num_gen%TYPE;
  TYPE AutoIndexNumGenTable         IS TABLE OF pn_system_setup_options.auto_index_num_gen%TYPE;
  TYPE AutoLeaseNumGenTable         IS TABLE OF pn_system_setup_options.auto_lease_num_gen%TYPE;
  TYPE AutoVarRentNumGenTable       IS TABLE OF pn_system_setup_options.auto_var_rent_num_gen%TYPE;
  TYPE AutoRecAgrNumFlag            IS TABLE OF pn_system_setup_options.auto_rec_agr_num_flag%TYPE;
  TYPE AutoRecExpNumFlag            IS TABLE OF pn_system_setup_options.auto_rec_exp_num_flag%TYPE;
  TYPE AutoRecArclNumFlag           IS TABLE OF pn_system_setup_options.auto_rec_arcl_num_flag%TYPE;
  TYPE AutoRecExpclNumFlag          IS TABLE OF pn_system_setup_options.auto_rec_expcl_num_flag%TYPE;
  TYPE ConsRecAgrtermsFlag          IS TABLE OF pn_system_setup_options.cons_rec_agrterms_flag%TYPE;
  TYPE LocationCodeSeparator        IS TABLE OF pn_system_setup_options.location_code_separator%TYPE;
  TYPE DefaultLocnAreaFlag          IS TABLE OF pn_system_setup_options.default_locn_area_flag%TYPE;
  TYPE GroupingRuleId               IS TABLE OF pn_system_setup_options.grouping_rule_id%TYPE;
  TYPE GlTransferMode               IS TABLE OF pn_system_setup_options.gl_transfer_mode%TYPE;
  TYPE SubmitJournalImportFlag      IS TABLE OF pn_system_setup_options.submit_journal_import_flag%TYPE;
  TYPE LegacyDataCutOffDate         IS TABLE OF pn_system_setup_options.legacy_data_cutoff_date%TYPE;
  TYPE DefaultUserViewCode          IS TABLE OF pn_system_setup_options.default_user_view_code%TYPE;
  TYPE ExtendIndexrentTermFlag      IS TABLE OF pn_system_setup_options.extend_indexrent_term_flag%TYPE;
  TYPE SysdateForAdjFlag            IS TABLE OF pn_system_setup_options.sysdate_for_adj_flag%TYPE;
  TYPE SysdateAsTrxDateFlag         IS TABLE OF pn_system_setup_options.sysdate_as_trx_date_flag%TYPE;
  TYPE RenormAdjAccAllDraftFlag     IS TABLE OF pn_system_setup_options.renorm_adj_acc_all_draft_flag%TYPE;
  TYPE ConsolidateAdjItemsFlag      IS TABLE OF pn_system_setup_options.consolidate_adj_items_flag%TYPE;
  TYPE CalcAnnualizedBasisCode      IS TABLE OF pn_system_setup_options.calc_annualized_basis_code%TYPE;
  TYPE AllowTenancyOverlapFlag      IS TABLE OF pn_system_setup_options.allow_tenancy_overlap_flag%TYPE;
  TYPE RecalcIrOnAccChgFlag         IS TABLE of pn_system_setup_options.recalc_ir_on_acc_chg_flag%TYPE;
  TYPE SmallestTermAmount           IS TABLE of pn_system_setup_options.Smallest_Term_Amount%TYPE; --#@#Bug4291907
  TYPE InclTermsByDefaultFlag       IS TABLE of pn_system_setup_options.incl_terms_by_default_flag%TYPE;

  -- Define a record type that encapsulates multiple rows of
  -- operating unit attributes:
  --

  TYPE GlobalsTable IS RECORD(
    org_id_t                         OrgIDTable,
    set_of_books_name_t              SetOfBooksNameTable,
    chart_of_accounts_id_t           ChartOfAccountsIDTable,
    legal_entity_name_t              LegalEntityNameTable,
    functional_currency_code_t       FunctionalCurrencyCodeTable,
    set_of_books_id_t                SetOfBooksIDTable,
    accounting_option_t              AccountingOptionTable,
    default_currency_conv_type_t     DefaultCurrencyConvTypeTable,
    space_assign_sysdate_optn_t      SpaceAssignSysdateOptnTable,
    multiple_tenancy_lease_t         MultipleTenancyLeaseTable,
    auto_comp_num_gen_t              AutoCompNumGenTable,
    auto_index_num_gen_t             AutoIndexNumGenTable,
    auto_lease_num_gen_t             AutoLeaseNumGenTable,
    auto_space_distribution_t        AutoSpaceDistributionTable,
    auto_var_rent_num_gen_t          AutoVarRentNumGenTable,
    auto_rec_agr_num_flag_t          AutoRecAgrNumFlag,
    auto_rec_exp_num_flag_t          AutoRecExpNumFlag,
    auto_rec_arcl_num_flag_t         AutoRecArclNumFlag,
    auto_rec_expcl_num_flag_t        AutoRecExpclNumFlag,
    cons_rec_agrterms_flag_t         ConsRecAgrtermsFlag,
    location_code_separator_t        LocationCodeSeparator,
    default_locn_area_flag_t         DefaultLocnAreaFlag,
    grouping_rule_id_t               GroupingRuleId,
    gl_transfer_mode_t               GlTransferMode,
    submit_journal_import_flag_t     SubmitJournalImportFlag,
    legacy_data_cutoff_date_t        LegacyDataCutOffDate,
    default_user_view_code_t         DefaultUserViewCode,
    extend_indexrent_term_flag_t     ExtendIndexrentTermFlag,
    sysdate_for_adj_flag_t           SysdateForAdjFlag,
    sysdate_as_trx_date_flag_t       SysdateAsTrxDateFlag,
    renorm_acc_all_draft_flag_t      RenormAdjAccAllDraftFlag,
    consolidate_adj_items_flag_t     ConsolidateAdjItemsFlag,
    calc_annualized_basis_code_t     CalcAnnualizedBasisCode,
    allow_tenancy_overlap_flag_t     AllowTenancyOverlapFlag,
    recalc_ir_on_acc_chg_flag_t      RecalcIrOnAccChgFlag,
    smallest_term_amount_t           SmallestTermAmount,
    incl_terms_by_default_flag_t     InclTermsByDefaultFlag
   );

    --
    -- This procedure retrieves operating unit attributes from the
    -- database and stores them into the specified data structure
    --

  PROCEDURE retrieve_globals(p_globals OUT NOCOPY GlobalsTable);

  FUNCTION get_profile_value (p_profile_name IN VARCHAR2,
                              p_org_id IN NUMBER DEFAULT NULL) RETURN VARCHAR2;

  FUNCTION check_access (p_org_id NUMBER) RETURN VARCHAR2;

  FUNCTION check_valid_org (p_org_id NUMBER) RETURN VARCHAR2;

  FUNCTION get_multi_org_flag RETURN VARCHAR2;

  FUNCTION is_MOAC_enabled RETURN BOOLEAN;

  FUNCTION is_MOAC_enabled_char RETURN VARCHAR2;

  PROCEDURE mo_global_init(p_appl_short_name IN VARCHAR2);

  PROCEDURE fnd_req_set_org_id(p_org_id IN NUMBER);

  FUNCTION get_current_org_id RETURN NUMBER;

END pn_mo_cache_utils;

/
