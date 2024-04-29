--------------------------------------------------------
--  DDL for Package ZX_TDS_UTILITIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_TDS_UTILITIES_PKG" AUTHID CURRENT_USER as
/* $Header: zxdiutilitiespus.pls 120.25.12010000.1 2008/07/28 13:31:18 appldev ship $ */

 /* ======================================================================*
  |  Structures for caching                                               |
  * ======================================================================*/

 -- Tax Cache
 TYPE zx_tax_info_cache_rec IS RECORD(
        tax_id                         zx_taxes_b.tax_id%TYPE,
        tax                            zx_taxes_b.tax%TYPE,
        tax_regime_code                zx_taxes_b.tax_regime_code%TYPE,
        tax_type_code                  zx_taxes_b.tax_type_code%TYPE,
        tax_precision                  zx_taxes_b.tax_precision%TYPE,
        minimum_accountable_unit       zx_taxes_b.minimum_accountable_unit%TYPE,
        Rounding_Rule_Code             zx_taxes_b.rounding_rule_code%TYPE,
        Tax_Status_Rule_Flag           zx_taxes_b.tax_status_rule_flag%TYPE,
        Tax_Rate_Rule_Flag             zx_taxes_b.tax_rate_rule_flag%TYPE,
        Place_Of_Supply_Rule_Flag      zx_taxes_b.place_of_supply_rule_flag%TYPE,
        Applicability_Rule_Flag        zx_taxes_b.applicability_rule_flag%TYPE,
        Tax_Calc_Rule_Flag             zx_taxes_b.tax_calc_rule_flag%TYPE,
        Taxable_Basis_Rule_Flag        zx_taxes_b.taxable_basis_rule_flag%TYPE,
        def_tax_calc_formula           zx_taxes_b.def_tax_calc_formula%TYPE,
        def_taxable_basis_formula      zx_taxes_b.def_taxable_basis_formula%TYPE,
        Reporting_Only_Flag            zx_taxes_b.Reporting_Only_Flag%TYPE,
        tax_currency_code              zx_taxes_b.tax_currency_code%TYPE,
        Def_Place_Of_Supply_Type_Code  zx_taxes_b.def_place_of_supply_type_code%TYPE,
        Def_Registr_Party_Type_Code    zx_taxes_b.def_registr_party_type_code%TYPE,
        Registration_Type_Rule_Flag    zx_taxes_b.registration_type_rule_flag%TYPE,
        Direct_Rate_Rule_Flag          zx_taxes_b.direct_rate_rule_flag%TYPE,
        Def_Inclusive_Tax_Flag         zx_taxes_b.def_inclusive_tax_flag%TYPE,
        effective_from                 zx_taxes_b.effective_from%TYPE,
        effective_to                   zx_taxes_b.effective_to%TYPE,
        compounding_precedence         zx_taxes_b.compounding_precedence%TYPE,
        Has_Other_Jurisdictions_Flag   zx_taxes_b.has_other_jurisdictions_flag%TYPE,
        Live_For_Processing_Flag       zx_taxes_b.live_for_processing_flag%TYPE,
        Regn_Num_Same_As_Le_Flag       zx_taxes_b.regn_num_same_as_le_flag%TYPE,
        applied_amt_handling_flag      zx_taxes_b.applied_amt_handling_flag%TYPE,
        exchange_rate_type             zx_taxes_b.exchange_rate_type%TYPE,
        applicable_by_default_flag     zx_taxes_b.applicable_by_default_flag%TYPE,
        record_type_code               zx_taxes_b.record_type_code%TYPE,
        tax_exmpt_cr_method_code       zx_taxes_b.tax_exmpt_cr_method_code%type,
        tax_exmpt_source_tax           zx_taxes_b.tax_exmpt_source_tax%TYPE,
        legal_reporting_status_def_val zx_taxes_b.legal_reporting_status_def_val%TYPE,
        def_rec_settlement_option_code zx_taxes_b.def_rec_settlement_option_code%TYPE,
        zone_geography_type	       zx_taxes_b.zone_geography_type%TYPE,
        override_geography_type        zx_taxes_b.override_geography_type%TYPE,
        allow_rounding_override_flag   zx_taxes_b.allow_rounding_override_flag%TYPE,
        tax_account_source_tax         zx_taxes_b.tax_account_source_tax%type
        );

 TYPE zx_tax_info_cache IS TABLE OF zx_tax_info_cache_rec
   INDEX by BINARY_INTEGER;

-- Tax Status information cache
 TYPE zx_status_info_rec IS RECORD (
        tax                             zx_taxes_b.tax%TYPE,
        tax_regime_code                 zx_regimes_b.tax_regime_code%TYPE,
        tax_status_id                   zx_status_b.tax_status_id%TYPE,
        tax_status_code                 zx_status_b.tax_status_code%TYPE,
        tax_status_name                 zx_status_tl.tax_status_name%TYPE,
        effective_from                  zx_status_b.effective_from%TYPE,
        effective_to                    zx_status_b.effective_to%TYPE,
        Default_Status_Flag             zx_status_b.default_status_flag%TYPE,
        default_flg_effective_from      zx_status_b.default_flg_effective_from%TYPE,
        default_flg_effective_to        zx_status_b.default_flg_effective_to%TYPE,
--      default_tax_rate_name           zx_status_b.default_tax_rate_name%TYPE,
        Rule_Based_Rate_Flag            zx_status_b.rule_based_rate_flag%TYPE,
        Allow_Rate_Override_Flag        zx_status_b.allow_rate_override_flag%TYPE,
        Allow_Exemptions_Flag           zx_status_b.allow_exemptions_flag%TYPE,
        Allow_Exceptions_Flag           zx_status_b.allow_exceptions_flag%TYPE);

 TYPE zx_status_info_cache IS TABLE OF zx_status_info_rec
   INDEX BY BINARY_INTEGER;

 -- Currency Cache
 TYPE zx_currency_info_cache_rec IS RECORD(
        ledger_id                  gl_sets_of_books.set_of_books_id%TYPE,
        currency_code              fnd_currencies.currency_code%TYPE,
        minimum_accountable_unit   fnd_currencies.minimum_accountable_unit%TYPE,
        precision                  fnd_currencies.precision%TYPE);

 TYPE zx_currency_info_cache IS TABLE OF zx_currency_info_cache_rec
   INDEX by BINARY_INTEGER;

 -- Tax rate information
 -- tax_jurisdiction_id is added for rate detemination requirement for multiple
 -- jurisdictions case (bug 4534949)
 TYPE zx_rate_info_rec_type IS RECORD (
  tax_regime_code                zx_rates_b.tax_regime_code%TYPE,
  tax                            zx_rates_b.tax%TYPE,
  tax_status_code                zx_rates_b.tax_status_code%TYPE,
  tax_rate_code                  zx_rates_b.tax_rate_code%TYPE,
  tax_rate_id                    zx_rates_b.tax_rate_id%TYPE,
  effective_from                 zx_rates_b.effective_from%TYPE,
  effective_to                   zx_rates_b.effective_to%TYPE,
  rate_type_code                 zx_rates_b.rate_type_code%TYPE,
  percentage_rate                zx_rates_b.percentage_rate%TYPE,
  quantity_rate                  zx_rates_b.quantity_rate%TYPE,
  allow_adhoc_tax_rate_flag      zx_rates_b.allow_adhoc_tax_rate_flag%TYPE,
  uom_code                       zx_rates_b.uom_code%TYPE,
  tax_jurisdiction_code          zx_rates_b.tax_jurisdiction_code%TYPE,
  offset_tax                     zx_rates_b.offset_tax%TYPE,
  offset_status_code             zx_rates_b.offset_status_code%TYPE,
  offset_tax_rate_code           zx_rates_b.offset_tax_rate_code%TYPE,
  allow_exemptions_flag          zx_rates_b.allow_exemptions_flag%TYPE,
  allow_exceptions_flag          zx_rates_b.allow_exceptions_flag%TYPE,
  tax_jurisdiction_id            zx_jurisdictions_b.tax_jurisdiction_id%TYPE,
  def_rec_settlement_option_code zx_rates_b.def_rec_settlement_option_code%TYPE,
  taxable_basis_formula_code     zx_rates_b.taxable_basis_formula_code%TYPE,
  adj_for_adhoc_amt_code         zx_rates_b.adj_for_adhoc_amt_code%TYPE,
  inclusive_tax_flag             zx_rates_b.inclusive_tax_flag%TYPE,
  tax_class                      zx_rates_b.tax_class%TYPE
  );

 TYPE zx_rate_info_cache  IS TABLE OF zx_rate_info_rec_type
   INDEX BY BINARY_INTEGER;


 TYPE zx_jur_info_cache_rec_type IS RECORD(
    tax_jurisdiction_code zx_jurisdictions_b.tax_jurisdiction_code%type,
    tax_jurisdiction_id   zx_jurisdictions_b.tax_jurisdiction_id%type,
    effective_from        zx_jurisdictions_b.effective_from%type,
    effective_to          zx_jurisdictions_b.effective_to%type,
    tax_regime_code       zx_jurisdictions_b.tax_regime_code%type,
    tax                   zx_jurisdictions_b.tax%type
    );

 TYPE zx_jur_info_cache IS TABLE OF zx_jur_info_cache_rec_type
   INDEX BY BINARY_INTEGER;
/* ========================================================+==============*
  |  Global Structures                                                    |
  * ======================================================================*/

 g_tax_rec_tbl                  zx_tax_info_cache;
 g_tax_status_info_tbl          zx_status_info_cache;
 g_tax_rate_info_tbl		zx_rate_info_cache;
 g_currency_rec_tbl             zx_currency_info_cache;
 g_jur_info_tbl                 zx_jur_info_cache;
 g_tax_rate_info_ind_by_hash    zx_rate_info_cache;

/* ======================================================================*
  |  Public Procedures                                                   |
  * =====================================================================*/

FUNCTION get_tax_status_index(
            p_tax               IN         ZX_TAXES_B.TAX%TYPE,
            p_tax_regime_code   IN         ZX_REGIMES_B.TAX_REGIME_CODE%TYPE,
            p_tax_status_code   IN         ZX_STATUS_B.TAX_STATUS_CODE%TYPE)
RETURN BINARY_INTEGER;

PROCEDURE get_regime_cache_info (
  p_tax_regime_code	IN  	    zx_regimes_b.tax_regime_code%TYPE,
  p_tax_determine_date	IN  	    DATE,
  p_tax_regime_rec   	OUT NOCOPY  zx_global_structures_pkg.tax_regime_rec_type,
  p_return_status      	OUT NOCOPY  VARCHAR2,
  p_error_buffer        OUT NOCOPY  VARCHAR2);

PROCEDURE get_jurisdiction_cache_info (
  p_tax_regime_code	IN  	    zx_regimes_b.tax_regime_code%TYPE,
  p_tax                 IN          zx_taxes_b.tax%TYPE,
  p_tax_jurisdiction_code IN        zx_jurisdictions_b.tax_jurisdiction_code%TYPE,
  p_tax_determine_date	IN  	    DATE,
  x_jurisdiction_rec   	OUT NOCOPY  zx_jur_info_cache_rec_type,
  p_return_status      	OUT NOCOPY  VARCHAR2,
  p_error_buffer        OUT NOCOPY  VARCHAR2);

PROCEDURE get_tax_cache_info (
  p_tax_regime_code	IN  	    zx_regimes_b.tax_regime_code%TYPE,
  p_tax                 IN          zx_taxes_b.tax%TYPE,
  p_tax_determine_date	IN  	    DATE,
  x_tax_rec            	OUT NOCOPY  zx_tax_info_cache_rec,
  p_return_status      	OUT NOCOPY  VARCHAR2,
  p_error_buffer        OUT NOCOPY  VARCHAR2);

PROCEDURE  get_tax_status_cache_info(
             p_tax                 IN     ZX_TAXES_B.TAX%TYPE,
             p_tax_regime_code     IN     ZX_REGIMES_B.TAX_REGIME_CODE%TYPE,
             p_tax_status_code     IN     ZX_STATUS_B.TAX_STATUS_CODE%TYPE,
             p_tax_determine_date  IN     ZX_LINES.TAX_DETERMINE_DATE%TYPE,
             p_status_rec             OUT NOCOPY ZX_STATUS_INFO_REC,
             p_return_status          OUT NOCOPY VARCHAR2,
             p_error_buffer           OUT NOCOPY VARCHAR2);

PROCEDURE populate_tax_cache (
 p_tax_id                IN           NUMBER,
 p_return_status         OUT NOCOPY   VARCHAR2,
 p_error_buffer          OUT NOCOPY   VARCHAR2);

PROCEDURE populate_currency_cache (
 p_ledger_id              IN          gl_sets_of_books.set_of_books_id%TYPE,
 p_return_status          OUT NOCOPY  VARCHAR2,
 p_error_buffer           OUT NOCOPY  VARCHAR2);

PROCEDURE  get_tax_rate_info (
 p_tax_regime_code	  IN	      VARCHAR2,
 p_tax                    IN          VARCHAR2,
 p_tax_jurisdiction_code  IN          zx_jurisdictions_b.tax_jurisdiction_code%TYPE,
 p_tax_status_code        IN          VARCHAR2,
 p_tax_rate_code          IN          VARCHAR2,
 p_tax_determine_date     IN          DATE,
 p_tax_class              IN          VARCHAR2,
 p_tax_rate_rec           OUT NOCOPY  zx_rate_info_rec_type,
 p_return_status          OUT NOCOPY  VARCHAR2,
 p_error_buffer           OUT NOCOPY  VARCHAR2);

FUNCTION get_tax_index (
 p_tax_regime_code        IN  	      zx_regimes_b.tax_regime_code%TYPE,
 p_tax                    IN          zx_taxes_b.tax%TYPE,
 p_trx_line_id            IN          NUMBER,
 p_trx_level_type         IN          VARCHAR2,
 p_begin_index            IN          BINARY_INTEGER,
 p_end_index              IN          BINARY_INTEGER,
 x_return_status          OUT NOCOPY  VARCHAR2)  RETURN NUMBER;

PROCEDURE  get_tax_rate_info (
 p_tax_rate_id            IN          NUMBER,
 p_tax_rate_rec           OUT NOCOPY  zx_rate_info_rec_type,
 p_return_status          OUT NOCOPY  VARCHAR2,
 p_error_buffer           OUT NOCOPY  VARCHAR2);

END ZX_TDS_UTILITIES_PKG;

/
