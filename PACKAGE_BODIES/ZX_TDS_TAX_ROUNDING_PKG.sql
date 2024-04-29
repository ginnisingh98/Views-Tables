--------------------------------------------------------
--  DDL for Package Body ZX_TDS_TAX_ROUNDING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_TDS_TAX_ROUNDING_PKG" as
/* $Header: zxdiroundtaxpkgb.pls 120.79.12010000.14 2009/10/12 18:44:33 tsen ship $ */

/* ======================================================================*
  |  Global Variable                                                     |
  * =====================================================================*/

g_hdr_rounding_info_tbl     hdr_rounding_info_tbl;
g_hdr_rounding_curr_tbl     hdr_rounding_curr_tbl;

g_current_runtime_level     NUMBER;
g_level_statement           CONSTANT  NUMBER   := FND_LOG.LEVEL_STATEMENT;
g_level_procedure           CONSTANT  NUMBER   := FND_LOG.LEVEL_PROCEDURE;
g_level_error               CONSTANT  NUMBER   := FND_LOG.LEVEL_ERROR;
g_level_unexpected          CONSTANT  NUMBER   := FND_LOG.LEVEL_UNEXPECTED;


/* ======================================================================*
  |  Private Procedures                                                  |
  * =====================================================================*/

PROCEDURE get_currency_info(
                p_currency              IN      VARCHAR2,
                p_eff_date              IN       DATE,
                p_derive_effective         OUT NOCOPY  DATE,
                p_derive_type              OUT NOCOPY  VARCHAR2,
                p_conversion_rate          OUT NOCOPY  NUMBER,
                p_mau                      OUT NOCOPY  NUMBER,
                p_precision                OUT NOCOPY  NUMBER,
                p_currency_type            OUT NOCOPY  VARCHAR2,
                p_return_status            OUT NOCOPY  VARCHAR2,
                p_error_buffer             OUT NOCOPY  VARCHAR2 );

PROCEDURE  get_currency_info_for_rounding(
             p_currency_code     IN     ZX_LINES.TRX_CURRENCY_CODE%TYPE,
             p_conversion_date   IN     ZX_LINES.CURRENCY_CONVERSION_DATE%TYPE,
             p_return_status     OUT NOCOPY VARCHAR2,
             p_error_buffer      OUT NOCOPY VARCHAR2);

FUNCTION get_other_rate (
                p_from_currency       IN     VARCHAR2,
                p_to_currency         IN     VARCHAR2,
                p_conversion_date     IN     Date,
                p_tax_conversion_type IN     VARCHAR2,
                p_trx_conversion_type IN     VARCHAR2,
                p_return_status       OUT NOCOPY VARCHAR2,
                p_error_buffer        OUT NOCOPY VARCHAR2,
                p_trx_conversion_date IN DATE DEFAULT NULL) RETURN NUMBER; --Bug7183884

FUNCTION get_euro_code(p_return_status OUT NOCOPY VARCHAR2,
                       p_error_buffer  OUT NOCOPY VARCHAR2) RETURN VARCHAR2;

FUNCTION convert_amount (
                p_from_currency         IN  VARCHAR2,
                p_to_currency           IN  VARCHAR2,
                p_conversion_date       IN  DATE,
                p_tax_conversion_type   IN  VARCHAR2,
                p_trx_conversion_type   IN  VARCHAR2,
                p_amount                IN  NUMBER,
                p_rate_index            IN  BINARY_INTEGER,
                p_return_status         OUT NOCOPY VARCHAR2,
                p_error_buffer          OUT NOCOPY VARCHAR2,
                p_trx_conversion_date IN DATE DEFAULT NULL) RETURN NUMBER; --Bug7183884

FUNCTION get_rate_index(
                p_from_currency   IN     VARCHAR2,
                p_to_currency     IN     VARCHAR2,
                p_conversion_date IN     Date,
                p_conversion_type IN     VARCHAR2)
RETURN BINARY_INTEGER ;

PROCEDURE get_funcl_curr_info(
             p_ledger_id           IN             ZX_LINES.LEDGER_ID%TYPE,
             p_funcl_currency_code    OUT NOCOPY FND_CURRENCIES.CURRENCY_CODE%TYPE,
             p_funcl_min_acct_unit    OUT NOCOPY FND_CURRENCIES.MINIMUM_ACCOUNTABLE_UNIT%TYPE,
             p_funcl_precision        OUT NOCOPY FND_CURRENCIES.PRECISION%TYPE,

             p_return_status          OUT NOCOPY VARCHAR2,
             p_error_buffer           OUT NOCOPY VARCHAR2);

PROCEDURE Get_Supplier_Site(
              p_account_id           IN   ZX_REGISTRATIONS.ACCOUNT_ID%TYPE,
              p_account_site_id      IN   ZX_REGISTRATIONS.ACCOUNT_SITE_ID%TYPE,
              p_rounding_level_code  OUT NOCOPY  ZX_PARTY_TAX_PROFILE.ROUNDING_LEVEL_CODE%TYPE,
              p_rounding_rule_code   OUT NOCOPY  ZX_PARTY_TAX_PROFILE.ROUNDING_RULE_CODE%TYPE,

              p_return_status        OUT  NOCOPY VARCHAR2);

PROCEDURE  Get_Reg_Site_Uses (
              p_account_id            IN   ZX_REGISTRATIONS.ACCOUNT_ID%TYPE,
              p_account_site_id       IN   ZX_REGISTRATIONS.ACCOUNT_SITE_ID%TYPE,
              p_site_use_id           IN   HZ_CUST_SITE_USES_ALL.CUST_ACCT_SITE_ID%TYPE,
              p_rounding_level_code   OUT NOCOPY  ZX_PARTY_TAX_PROFILE.ROUNDING_LEVEL_CODE%TYPE,
              p_rounding_rule_code    OUT NOCOPY  ZX_PARTY_TAX_PROFILE.ROUNDING_RULE_CODE%TYPE,
              p_return_status         OUT NOCOPY  VARCHAR2);

PROCEDURE  Get_Registration_Accts(
             p_account_id             IN   ZX_REGISTRATIONS.ACCOUNT_ID%TYPE,
             p_rounding_level_code    OUT NOCOPY  ZX_PARTY_TAX_PROFILE.ROUNDING_LEVEL_CODE%TYPE,
             p_rounding_rule_code     OUT NOCOPY  ZX_PARTY_TAX_PROFILE.ROUNDING_RULE_CODE%TYPE,
             p_return_status          OUT NOCOPY  VARCHAR2 );

PROCEDURE  Get_Registration_Party(
             p_party_tax_profile_id   IN  ZX_PARTY_TAX_PROFILE.PARTY_TAX_PROFILE_ID%TYPE,
             p_rounding_level_code    OUT NOCOPY  ZX_PARTY_TAX_PROFILE.ROUNDING_LEVEL_CODE%TYPE,
             p_rounding_rule_code     OUT NOCOPY  ZX_PARTY_TAX_PROFILE.ROUNDING_RULE_CODE%TYPE,
             p_return_status          OUT NOCOPY  VARCHAR2 );


PROCEDURE get_rounding_level(

            p_parent_ptp_id          IN  zx_party_tax_profile.party_tax_profile_id%TYPE,
            p_site_ptp_id            IN  zx_party_tax_profile.party_tax_profile_id%TYPE,
            p_account_Type_Code      IN  zx_registrations.account_type_code%TYPE,
            p_account_id             IN  ZX_REGISTRATIONS.ACCOUNT_ID%TYPE,
            p_account_site_id        IN  ZX_REGISTRATIONS.ACCOUNT_SITE_ID%TYPE,
            p_site_use_id            IN  HZ_CUST_SITE_USES_ALL.SITE_USE_ID%TYPE,
            p_rounding_level_code    OUT NOCOPY  ZX_PARTY_TAX_PROFILE.ROUNDING_LEVEL_CODE%TYPE,
            p_rounding_rule_code     OUT NOCOPY  ZX_PARTY_TAX_PROFILE.ROUNDING_RULE_CODE%TYPE,
           p_return_status           OUT NOCOPY  VARCHAR2,
           p_error_buffer            OUT NOCOPY  VARCHAR2
         );

PROCEDURE det_rounding_level_basis(
            p_Party_Type_Code      IN     VARCHAR2,
            p_rounding_level_basis    OUT NOCOPY  VARCHAR2,
            p_return_status           OUT NOCOPY  VARCHAR2,
            p_error_buffer            OUT NOCOPY  VARCHAR2
           );

PROCEDURE determine_round_level_and_rule(
            p_Party_Type_Code      IN     VARCHAR2,
            p_event_class_rec      IN     ZX_API_PUB.EVENT_CLASS_REC_TYPE,
            p_tax_prof_id             OUT NOCOPY ZX_PARTY_TAX_PROFILE.PARTY_TAX_PROFILE_ID%TYPE,
            p_rounding_level_code     OUT NOCOPY  ZX_PARTY_TAX_PROFILE.ROUNDING_LEVEL_CODE%TYPE,
            p_rounding_rule_code      OUT NOCOPY  ZX_PARTY_TAX_PROFILE.ROUNDING_RULE_CODE%TYPE,
            p_return_status           OUT NOCOPY  VARCHAR2,
            p_error_buffer            OUT NOCOPY  VARCHAR2,
            p_ship_third_pty_acct_id        IN NUMBER,
            p_bill_third_pty_acct_id        IN NUMBER,
            p_ship_third_pty_acct_site_id   IN NUMBER,
            p_bill_third_pty_acct_site_id   IN NUMBER,
            p_ship_to_cust_acct_st_use_id   IN NUMBER,
            p_bill_to_cust_acct_st_use_id   IN NUMBER,
            p_tax_determine_date            IN DATE
           );

PROCEDURE determine_rounding_rule(
  p_trx_line_index     IN            BINARY_INTEGER,
  p_event_class_rec    IN            ZX_API_PUB.EVENT_CLASS_REC_TYPE,
  p_party_type_code    IN            VARCHAR2,
  p_tax_regime_code    IN            VARCHAR2,
  p_tax                IN            VARCHAR2,
  p_jurisdiction_code  IN            VARCHAR2,
  p_tax_determine_date IN            DATE,
  p_rounding_rule_code    OUT NOCOPY ZX_PARTY_TAX_PROFILE.ROUNDING_RULE_CODE%TYPE,
  p_return_status         OUT NOCOPY VARCHAR2,
  p_error_buffer          OUT NOCOPY VARCHAR2);

PROCEDURE get_rounding_info(
            p_tax_id                        IN ZX_TAXES_B.TAX_ID%TYPE,
            p_tax_currency_code             OUT NOCOPY ZX_LINES.TAX_CURRENCY_CODE%TYPE,
            p_tax_currency_conversion_date  IN OUT NOCOPY ZX_LINES.TAX_CURRENCY_CONVERSION_DATE%TYPE, --bug#6526550
            p_trx_currency_code             IN ZX_LINES.TRX_CURRENCY_CODE%TYPE,
            p_currency_conversion_date      IN ZX_LINES.CURRENCY_CONVERSION_DATE%TYPE,
            p_min_acct_unit                 IN OUT NOCOPY ZX_LINES.MINIMUM_ACCOUNTABLE_UNIT%TYPE,
            p_precision                     IN OUT NOCOPY ZX_LINES.PRECISION%TYPE,
            p_tax_min_acct_unit             OUT NOCOPY ZX_TAXES_B.MINIMUM_ACCOUNTABLE_UNIT%TYPE,
            p_tax_precision                 OUT NOCOPY ZX_TAXES_B.TAX_PRECISION%TYPE,
            p_tax_currency_conversion_type  OUT NOCOPY ZX_TAXES_B.EXCHANGE_RATE_TYPE%TYPE,
            p_return_status                 OUT NOCOPY VARCHAR2,
            p_error_buffer                  OUT NOCOPY VARCHAR2
         );

PROCEDURE round_line_level(
             p_tax_amt               IN OUT NOCOPY ZX_LINES.TAX_AMT%TYPE,
             p_taxable_amt              OUT NOCOPY ZX_LINES.TAXABLE_AMT%TYPE,
             p_prd_total_tax_amt     IN OUT NOCOPY ZX_LINES.PRD_TOTAL_TAX_AMT%TYPE,
             p_Rounding_Rule_Code    IN            ZX_LINES.Rounding_Rule_Code%TYPE,
             p_trx_min_acct_unit     IN OUT NOCOPY ZX_LINES.MINIMUM_ACCOUNTABLE_UNIT%TYPE,
             p_trx_precision         IN OUT NOCOPY ZX_LINES.PRECISION%TYPE,
             p_trx_currency_code     IN            ZX_LINES.TRX_CURRENCY_CODE%TYPE,
             p_application_id           IN            ZX_LINES.APPLICATION_ID%TYPE,
             p_internal_organization_id IN            ZX_LINES.INTERNAL_ORGANIZATION_ID%TYPE,
             p_event_class_mapping_id   IN            ZX_LINES_DET_FACTORS.EVENT_CLASS_MAPPING_ID%TYPE,
             p_unrounded_taxable_amt IN ZX_LINES.UNROUNDED_TAXABLE_AMT%TYPE,
             p_unrounded_tax_amt     IN ZX_LINES.UNROUNDED_TAX_AMT%TYPE,
             p_return_status            OUT NOCOPY VARCHAR2,
             p_error_buffer             OUT NOCOPY VARCHAR2
         );

PROCEDURE  init_header_group(
             p_hdr_grp_rec       OUT NOCOPY HDR_GRP_REC_TYPE,
             p_return_status     OUT NOCOPY VARCHAR2,
             p_error_buffer      OUT NOCOPY VARCHAR2
         );

PROCEDURE  determine_header_group(
             p_prev_hdr_grp_rec         IN            HDR_GRP_REC_TYPE,
             p_curr_hdr_grp_rec         IN            HDR_GRP_REC_TYPE,
             p_same_tax                    OUT NOCOPY VARCHAR2,
             p_return_status               OUT NOCOPY VARCHAR2,
             p_error_buffer                OUT NOCOPY VARCHAR2
         );

PROCEDURE  conv_rnd_tax_tax_curr(
             p_from_currency        IN     ZX_LINES.TRX_CURRENCY_CODE%TYPE,
             p_to_currency          IN     ZX_LINES.TAX_CURRENCY_CODE%TYPE,
             p_conversion_date      IN     ZX_LINES.TAX_CURRENCY_CONVERSION_DATE%TYPE,
             p_tax_conversion_type  IN     ZX_LINES.TAX_CURRENCY_CONVERSION_TYPE%TYPE,
             p_trx_conversion_type  IN     ZX_LINES.CURRENCY_CONVERSION_TYPE%TYPE,
             p_tax_curr_conv_rate   IN OUT NOCOPY ZX_LINES.TAX_CURRENCY_CONVERSION_RATE%TYPE,
             p_amt                  IN     ZX_LINES.TAX_AMT%TYPE,
             p_convert_round_amt        OUT NOCOPY ZX_LINES.TAX_AMT_TAX_CURR%TYPE,
             p_Rounding_Rule_Code        IN     ZX_TAXES_B.Rounding_Rule_Code%TYPE,
             p_tax_min_acct_unit    IN     ZX_TAXES_B.MINIMUM_ACCOUNTABLE_UNIT%TYPE,
             p_tax_precision        IN     ZX_TAXES_B.TAX_PRECISION%TYPE,
             p_return_status           OUT NOCOPY VARCHAR2,
             p_error_buffer            OUT NOCOPY VARCHAR2,
             p_trx_conversion_date  IN     ZX_LINES.CURRENCY_CONVERSION_DATE%TYPE DEFAULT NULL); --Bug7183884


PROCEDURE  conv_rnd_tax_funcl_curr(
             p_funcl_curr_conv_rate IN     ZX_LINES.CURRENCY_CONVERSION_RATE%TYPE,
             p_amt                  IN     ZX_LINES.TAX_AMT%TYPE,
             p_convert_round_amt        OUT NOCOPY ZX_LINES.TAX_AMT_TAX_CURR%TYPE,
             p_ledger_id            IN     ZX_LINES.LEDGER_ID%TYPE,
             p_return_status           OUT NOCOPY VARCHAR2,
             p_error_buffer            OUT NOCOPY VARCHAR2
         );


PROCEDURE  conv_rnd_taxable_tax_curr(
             p_from_currency        IN     ZX_LINES.TRX_CURRENCY_CODE%TYPE,
             p_to_currency          IN     ZX_LINES.TAX_CURRENCY_CODE%TYPE,
             p_conversion_date      IN     ZX_LINES.TAX_CURRENCY_CONVERSION_DATE%TYPE,
             p_tax_conversion_type  IN     ZX_LINES.TAX_CURRENCY_CONVERSION_TYPE%TYPE,
             p_trx_conversion_type  IN     ZX_LINES.CURRENCY_CONVERSION_TYPE%TYPE,
             p_tax_curr_conv_rate   IN OUT NOCOPY ZX_LINES.TAX_CURRENCY_CONVERSION_RATE%TYPE,
             p_amt                  IN     ZX_LINES.TAX_AMT%TYPE,
             p_convert_round_amt        OUT NOCOPY ZX_LINES.TAX_AMT_TAX_CURR%TYPE,
             p_Rounding_Rule_Code        IN     ZX_TAXES_B.Rounding_Rule_Code%TYPE,
             p_tax_min_acct_unit    IN     ZX_TAXES_B.MINIMUM_ACCOUNTABLE_UNIT%TYPE,
             p_tax_precision        IN     ZX_TAXES_B.TAX_PRECISION%TYPE,
             p_tax_calculation_formula IN         ZX_LINES.TAX_CALCULATION_FORMULA%TYPE,
             p_tax_rate                IN         ZX_LINES.TAX_RATE%TYPE,
             p_tax_rate_id             IN         ZX_RATES_B.TAX_RATE_ID%TYPE,
             p_rounded_amt_tax_curr IN     ZX_LINES.TAX_AMT_TAX_CURR%TYPE,
             p_return_status           OUT NOCOPY VARCHAR2,
             p_error_buffer            OUT NOCOPY VARCHAR2,
             p_trx_conversion_date  IN     ZX_LINES.CURRENCY_CONVERSION_DATE%TYPE DEFAULT NULL);--Bug7183884


PROCEDURE  conv_rnd_taxable_funcl_curr(
             p_funcl_curr_conv_rate IN     ZX_LINES.CURRENCY_CONVERSION_RATE%TYPE,
             p_amt                  IN     ZX_LINES.TAX_AMT%TYPE,
             p_convert_round_amt        OUT NOCOPY ZX_LINES.TAX_AMT_TAX_CURR%TYPE,
             p_ledger_id            IN     ZX_LINES.LEDGER_ID%TYPE,
             p_tax_calculation_formula IN     ZX_LINES.TAX_CALCULATION_FORMULA%TYPE,
             p_tax_rate             IN     ZX_LINES.TAX_RATE%TYPE,
             p_tax_rate_id          IN     ZX_RATES_B.TAX_RATE_ID%TYPE,
             p_rounded_amt_funcl_curr IN     ZX_LINES.TAX_AMT_FUNCL_CURR%TYPE,
             p_return_status           OUT NOCOPY VARCHAR2,
             p_error_buffer            OUT NOCOPY VARCHAR2
         );

PROCEDURE do_rounding(
           p_tax_id                        IN            ZX_TAXES_B.TAX_ID%TYPE,
           p_tax_rate_id                   IN            ZX_RATES_B.TAX_RATE_ID%TYPE,
           p_tax_amt                       IN OUT NOCOPY ZX_LINES.TAX_AMT%TYPE,
           p_taxable_amt                   IN OUT NOCOPY ZX_LINES.TAXABLE_AMT%TYPE,
           p_orig_tax_amt                  IN OUT NOCOPY ZX_LINES.TAX_AMT%TYPE,
           p_orig_taxable_amt              IN OUT NOCOPY ZX_LINES.TAXABLE_AMT%TYPE,
           p_orig_tax_amt_tax_curr         IN OUT NOCOPY ZX_LINES.TAX_AMT%TYPE,
           p_orig_taxable_amt_tax_curr     IN OUT NOCOPY ZX_LINES.TAXABLE_AMT%TYPE,
           p_cal_tax_amt                   IN OUT NOCOPY ZX_LINES.CAL_TAX_AMT%TYPE,
           p_tax_amt_tax_curr              IN OUT NOCOPY ZX_LINES.TAX_AMT_TAX_CURR%TYPE,
           p_taxable_amt_tax_curr             OUT NOCOPY ZX_LINES.TAXABLE_AMT_TAX_CURR%TYPE,
           p_cal_tax_amt_tax_curr             OUT NOCOPY ZX_LINES.CAL_TAX_AMT_TAX_CURR%TYPE,
           p_tax_amt_funcl_curr               OUT NOCOPY ZX_LINES.TAX_AMT_FUNCL_CURR%TYPE,
           p_taxable_amt_funcl_curr           OUT NOCOPY ZX_LINES.TAXABLE_AMT_FUNCL_CURR%TYPE,
           p_cal_tax_amt_funcl_curr           OUT NOCOPY ZX_LINES.CAL_TAX_AMT_FUNCL_CURR%TYPE,
           p_trx_currency_code             IN            ZX_LINES.TRX_CURRENCY_CODE%TYPE,
           p_tax_currency_code                OUT NOCOPY ZX_LINES.TAX_CURRENCY_CODE%TYPE,
           p_tax_currency_conversion_type  IN            ZX_LINES.TAX_CURRENCY_CONVERSION_TYPE%TYPE,
           p_tax_currency_conversion_rate  IN OUT NOCOPY ZX_LINES.TAX_CURRENCY_CONVERSION_RATE%TYPE,
           p_tax_currency_conversion_date  IN            ZX_LINES.TAX_CURRENCY_CONVERSION_DATE%TYPE,
           p_currency_conversion_type      IN            ZX_LINES.CURRENCY_CONVERSION_TYPE%TYPE,
           p_currency_conversion_rate      IN            ZX_LINES.CURRENCY_CONVERSION_RATE%TYPE,
           p_currency_conversion_date      IN            ZX_LINES.CURRENCY_CONVERSION_DATE%TYPE,
           p_Rounding_Rule_Code            IN            ZX_LINES.Rounding_Rule_Code%TYPE,
           p_ledger_id                     IN            ZX_LINES.LEDGER_ID%TYPE,
           p_min_acct_unit                 IN OUT NOCOPY ZX_LINES.MINIMUM_ACCOUNTABLE_UNIT%TYPE,
           p_precision                     IN OUT NOCOPY ZX_LINES.PRECISION%TYPE,
           p_application_id                IN            ZX_LINES.APPLICATION_ID%TYPE,
           p_internal_organization_id      IN            ZX_LINES.INTERNAL_ORGANIZATION_ID%TYPE,
           p_event_class_mapping_id        IN            ZX_LINES_DET_FACTORS.EVENT_CLASS_MAPPING_ID%TYPE,
           p_tax_calculation_formula       IN            ZX_LINES.TAX_CALCULATION_FORMULA%TYPE,
           p_tax_rate                      IN            ZX_LINES.TAX_RATE%TYPE,
           p_prd_total_tax_amt             IN OUT NOCOPY ZX_LINES.PRD_TOTAL_TAX_AMT%TYPE,
           p_prd_total_tax_amt_tax_curr       OUT NOCOPY ZX_LINES.PRD_TOTAL_TAX_AMT_TAX_CURR%TYPE,
           p_prd_total_tax_amt_funcl_curr     OUT NOCOPY ZX_LINES.PRD_TOTAL_TAX_AMT_FUNCL_CURR%TYPE,
           p_unrounded_taxable_amt         IN ZX_LINES.UNROUNDED_TAXABLE_AMT%TYPE,
           p_unrounded_tax_amt             IN ZX_LINES.UNROUNDED_TAX_AMT%TYPE,
           p_mrc_tax_line_flag             IN zx_lines.mrc_tax_line_flag%TYPE,
           p_tax_provider_id               IN zx_lines.tax_provider_id%TYPE,
           p_return_status                    OUT NOCOPY VARCHAR2,
           p_error_buffer                     OUT NOCOPY VARCHAR2
         );

PROCEDURE update_header_rounding_curr(
           p_tax_line_id              IN            ZX_LINES.TAX_LINE_ID%TYPE,
           p_unrounded_tax_amt        IN            ZX_LINES.UNROUNDED_TAX_AMT%TYPE,
           p_tax_amt_curr             IN            ZX_LINES.TAX_AMT_FUNCL_CURR%TYPE,
           p_taxable_amt_curr         IN            ZX_LINES.TAXABLE_AMT_FUNCL_CURR%TYPE,
           p_currency_conversion_rate IN            ZX_LINES.CURRENCY_CONVERSION_RATE%TYPE,
           p_prev_hdr_grp_rec         IN OUT NOCOPY HDR_GRP_REC_TYPE,
           p_curr_hdr_grp_rec         IN            HDR_GRP_REC_TYPE,
           p_same_tax                 IN            VARCHAR2,
           p_ledger_id                IN            ZX_LINES.LEDGER_ID%TYPE,
           p_return_status               OUT NOCOPY VARCHAR2,
           p_error_buffer                OUT NOCOPY VARCHAR2
         );

PROCEDURE update_header_rounding_info(
           p_tax_line_id              IN            ZX_LINES.TAX_LINE_ID%TYPE,
           p_tax_id                   IN            ZX_TAXES_B.TAX_ID%TYPE,
           p_Rounding_Rule_Code       IN            ZX_LINES.Rounding_Rule_Code%TYPE,
           p_min_acct_unit            IN            ZX_LINES.MINIMUM_ACCOUNTABLE_UNIT%TYPE,
           p_precision                IN            ZX_LINES.PRECISION%TYPE,
           p_unrounded_tax_amt        IN            ZX_LINES.UNROUNDED_TAX_AMT%TYPE,
           p_tax_amt                  IN            ZX_LINES.TAX_AMT%TYPE,
           p_tax_amt_tax_curr         IN            ZX_LINES.TAX_AMT_TAX_CURR%TYPE,
           p_tax_amt_funcl_curr       IN            ZX_LINES.TAX_AMT_FUNCL_CURR%TYPE,
           p_taxable_amt_tax_curr     IN            ZX_LINES.TAXABLE_AMT_TAX_CURR%TYPE,
           p_taxable_amt_funcl_curr   IN            ZX_LINES.TAXABLE_AMT_FUNCL_CURR%TYPE,
           p_tax_curr_conv_rate       IN            ZX_LINES.TAX_CURRENCY_CONVERSION_RATE%TYPE,
           p_currency_conversion_rate IN            ZX_LINES.CURRENCY_CONVERSION_RATE%TYPE,
           p_prev_hdr_grp_rec         IN OUT NOCOPY HDR_GRP_REC_TYPE,
           p_curr_hdr_grp_rec         IN            HDR_GRP_REC_TYPE,
           p_same_tax                 IN            VARCHAR2,
           p_sum_unrnd_tax_amt        IN            NUMBER,
           p_sum_rnd_tax_amt          IN            NUMBER,
           p_sum_rnd_tax_curr         IN            NUMBER,
           p_sum_rnd_funcl_curr       IN            NUMBER,
           p_ledger_id                IN            ZX_LINES.LEDGER_ID%TYPE,
           p_return_status               OUT NOCOPY VARCHAR2,
           p_error_buffer                OUT NOCOPY VARCHAR2
         );

PROCEDURE process_tax_line_create(
            p_sum_unrnd_tax_amt     OUT NOCOPY NUMBER,
            p_sum_rnd_tax_amt       OUT NOCOPY NUMBER,
            p_sum_rnd_tax_curr       OUT NOCOPY NUMBER,
            p_sum_rnd_funcl_curr    OUT NOCOPY NUMBER,
            p_return_status         OUT NOCOPY VARCHAR2,
            p_error_buffer          OUT NOCOPY VARCHAR2
         );

PROCEDURE process_tax_line_upd_override(
           p_curr_hdr_grp_rec        IN            HDR_GRP_REC_TYPE,
           p_sum_unrnd_tax_amt          OUT NOCOPY NUMBER,
           p_sum_rnd_tax_amt            OUT NOCOPY NUMBER,
           p_sum_rnd_tax_curr            OUT NOCOPY NUMBER,
           p_sum_rnd_funcl_curr         OUT NOCOPY NUMBER,
           p_event_class_rec         IN            ZX_API_PUB.EVENT_CLASS_REC_TYPE,
           p_return_status              OUT NOCOPY VARCHAR2,
           p_error_buffer               OUT NOCOPY VARCHAR2
         );

PROCEDURE handle_header_rounding_curr(
           p_tax_line_id              IN            ZX_LINES.TAX_LINE_ID%TYPE,
           p_unrounded_tax_amt        IN            ZX_LINES.UNROUNDED_TAX_AMT%TYPE,
           p_tax_amt_curr             IN            ZX_LINES.TAX_AMT_FUNCL_CURR%TYPE,
           p_taxable_amt_curr         IN            ZX_LINES.TAXABLE_AMT_FUNCL_CURR%TYPE,
           p_currency_conversion_rate IN            ZX_LINES.CURRENCY_CONVERSION_RATE%TYPE,
           p_prev_hdr_grp_rec         IN OUT NOCOPY HDR_GRP_REC_TYPE,
           p_curr_hdr_grp_rec         IN            HDR_GRP_REC_TYPE,
           p_ledger_id                IN            ZX_LINES.LEDGER_ID%TYPE,
           p_return_status               OUT NOCOPY VARCHAR2,
           p_error_buffer                OUT NOCOPY VARCHAR2
         );

PROCEDURE adjust_rounding_diff_curr(
            p_return_status                 OUT NOCOPY VARCHAR2,
            p_error_buffer                  OUT NOCOPY VARCHAR2
         );

PROCEDURE adjust_rounding_diff(
            p_return_status                 OUT NOCOPY VARCHAR2,
            p_error_buffer                  OUT NOCOPY VARCHAR2
         );

PROCEDURE  chk_mandatory_col_after_round(
             p_trx_currency_code    IN            ZX_LINES.TRX_CURRENCY_CODE%TYPE,
             p_tax_currency_code    IN            ZX_LINES.TAX_CURRENCY_CODE%TYPE,
             p_tax_amt              IN            ZX_LINES.TAX_AMT%TYPE,
             p_tax_amt_tax_curr     IN            ZX_LINES.TAX_AMT_TAX_CURR%TYPE,
             p_taxable_amt          IN            ZX_LINES.TAXABLE_AMT%TYPE,
             p_taxable_amt_tax_curr IN            ZX_LINES.TAXABLE_AMT_TAX_CURR%TYPE,
             p_mrc_tax_line_flag    IN            zx_lines.mrc_tax_line_flag%TYPE,
             p_rate_type_code       IN            ZX_RATES_B.RATE_TYPE_CODE%TYPE,
             p_return_status           OUT NOCOPY VARCHAR2,
             p_error_buffer            OUT NOCOPY VARCHAR2
         );

PROCEDURE  update_detail_tax_lines_gt(
             p_min_acct_unit_tbl                IN MIN_ACCT_UNIT_TBL,
             p_precision_tbl                    IN PRECISION_TBL,
             p_tax_currency_code_tbl            IN TAX_CURRENCY_CODE_TBL,
             p_tax_curr_conv_rate_tbl           IN TAX_CURR_CONV_RATE_TBL,
             p_tax_amt_tbl                      IN TAX_AMT_TBL,
             p_taxable_amt_tbl                  IN TAXABLE_AMT_TBL,
             p_tax_amt_tax_curr_tbl             IN TAX_AMT_TAX_CURR_TBL,
             p_taxable_amt_tax_curr_tbl         IN  TAXABLE_AMT_TAX_CURR_TBL,
             p_tax_amt_funcl_curr_tbl           IN TAX_AMT_FUNCL_CURR_TBL,
             p_taxable_amt_funcl_curr_tbl       IN TAXABLE_AMT_FUNCL_CURR_TBL,
             p_prd_total_tax_amt_tbl            IN PRD_TOTAL_TAX_AMT_TBL,
             p_prd_tot_tax_amt_tax_curr_tbl     IN PRD_TOTAL_TAX_AMT_TAX_CURR_TBL,
             p_prd_tot_tax_amt_fcl_curr_tbl     IN PRD_TOTAL_TAX_AMT_FCL_CURR_TBL,
             p_cal_tax_amt_funcl_curr_tbl       IN CAL_TAX_AMT_FUNCL_CURR_TBL,
             p_orig_tax_amt_tax_curr_tbl        IN TAX_AMT_TBL,
             p_orig_taxable_amt_tax_cur_tbl     IN TAXABLE_AMT_TBL,
             p_tax_line_id_tbl                  IN TAX_LINE_ID_TBL,
             p_return_status                    OUT NOCOPY VARCHAR2,
             p_error_buffer                     OUT NOCOPY VARCHAR2
         );

PROCEDURE  update_zx_lines(
                p_conversion_rate            IN            NUMBER,
                p_conversion_type            IN            VARCHAR2,
                p_conversion_date            IN            DATE,
                p_tax_amt_funcl_curr_tbl     IN            TAX_AMT_FUNCL_CURR_TBL,
                p_taxable_amt_funcl_curr_tbl IN            TAXABLE_AMT_FUNCL_CURR_TBL,
                p_cal_tax_amt_funcl_curr_tbl IN            CAL_TAX_AMT_FUNCL_CURR_TBL,
                p_tax_line_id_tbl            IN            TAX_LINE_ID_TBL,
                p_return_status                 OUT NOCOPY VARCHAR2,
                p_error_buffer                  OUT NOCOPY VARCHAR2
         );

PROCEDURE convert_and_round_for_curr(
            p_curr_conv_rate          IN            ZX_LINES.CURRENCY_CONVERSION_RATE%TYPE,
            p_rounded_tax_amt         IN            ZX_LINES.TAX_AMT%TYPE,
            p_rounded_taxable_amt     IN            ZX_LINES.TAXABLE_AMT%TYPE,
            p_unrounded_tax_amt       IN            ZX_LINES.TAX_AMT%TYPE,
            p_unrounded_taxable_amt   IN            ZX_LINES.TAXABLE_AMT%TYPE,
            p_conv_rnd_tax_amt_curr      OUT NOCOPY ZX_LINES.TAX_AMT_TAX_CURR%TYPE,
            p_conv_rnd_taxable_amt_curr  OUT NOCOPY ZX_LINES.TAXABLE_AMT_TAX_CURR%TYPE,
            p_ledger_id               IN            ZX_LINES.LEDGER_ID%TYPE,
            p_tax_calculation_formula IN            ZX_LINES.TAX_CALCULATION_FORMULA%TYPE,
            p_tax_rate                IN            ZX_LINES.TAX_RATE%TYPE,
            p_tax_rate_id             IN            ZX_RATES_B.TAX_RATE_ID%TYPE,
            p_return_status              OUT NOCOPY VARCHAR2,
            p_error_buffer               OUT NOCOPY VARCHAR2
         );

PROCEDURE convert_and_round_lin_lvl_curr(
           p_conversion_rate  IN            NUMBER,
           p_conversion_type  IN            VARCHAR2,
           p_conversion_date  IN            DATE,
           p_event_class_rec  IN            ZX_API_PUB.EVENT_CLASS_REC_TYPE,
           p_return_status       OUT NOCOPY VARCHAR2,
           p_error_buffer        OUT NOCOPY VARCHAR2
         );

PROCEDURE convert_and_round_hdr_lvl_curr(
           p_conversion_rate  IN            NUMBER,
           p_conversion_type  IN            VARCHAR2,
           p_conversion_date  IN            DATE,
           p_event_class_rec  IN            ZX_API_PUB.EVENT_CLASS_REC_TYPE,
           p_return_status       OUT NOCOPY VARCHAR2,
           p_error_buffer        OUT NOCOPY VARCHAR2
         );

PROCEDURE get_round_level_ptp_id(
            p_Party_Type_Code      IN     VARCHAR2,
            p_event_class_rec      IN     ZX_API_PUB.EVENT_CLASS_REC_TYPE,
            p_tax_prof_id             OUT NOCOPY ZX_PARTY_TAX_PROFILE.PARTY_TAX_PROFILE_ID%TYPE,
            p_return_status           OUT NOCOPY  VARCHAR2,
            p_error_buffer            OUT NOCOPY  VARCHAR2
           );

-----------------------------------------------------------------------

  -- PRIVATE FUNCTION convert_amount
  --
  --  DESCRIPTION
  --    Returns the amount converted from the from currency into the
  --    to currency for a given conversion date and conversion type.
  --    Conversion rate is then stored in the cache structure
  --
FUNCTION convert_amount (
                p_from_currency         IN  VARCHAR2,
                p_to_currency           IN  VARCHAR2,
                p_conversion_date       IN  DATE,
                p_tax_conversion_type   IN  VARCHAR2,
                p_trx_conversion_type   IN  VARCHAR2,
                p_amount                IN  NUMBER,
                p_rate_index            IN  BINARY_INTEGER,
                p_return_status         OUT NOCOPY  VARCHAR2,
                p_error_buffer          OUT NOCOPY  VARCHAR2,
                p_trx_conversion_date   IN  DATE DEFAULT NULL ) RETURN NUMBER IS --Bug7183884

    l_to_type                     VARCHAR2(30);
    l_from_type                   VARCHAR2(30);
    l_to_rate                     NUMBER;
    l_from_rate                   NUMBER;
    l_other_rate                  NUMBER;
    l_rate_index                  BINARY_INTEGER;
    l_converted_amount            NUMBER;
BEGIN

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.convert_amount.BEGIN',
                   'ZX_TDS_TAX_ROUNDING_PKG: convert_amount(+)');
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.convert_amount',
                   'p_from_currency = ' || p_from_currency||
                   'p_to_currency = ' || p_to_currency||
                   'p_conversion_date = ' ||
                    to_char(p_conversion_date, 'DD-MON-YY')||
                   'p_tax_conversion_type = ' || p_tax_conversion_type||
                   'p_trx_conversion_type = ' || p_trx_conversion_type);
  END IF;

  p_return_status :=  FND_API.G_RET_STS_SUCCESS;

   -- Check if both currencies are identical
   IF ( p_from_currency = p_to_currency ) THEN
      g_tax_curr_conv_rate_tbl(p_rate_index) :=  1;
      RETURN( p_amount );
   END IF;

   -- Get currency information from the from_currency

   -- Bug#6865855: check cache structure before access
   IF g_currency_tbl.EXISTS(p_from_currency) THEN
     l_from_type := g_currency_tbl(p_from_currency).currency_type;
     l_from_rate := g_currency_tbl(p_from_currency).conversion_rate;
   ELSE
     -- not exist in cache, need to populate it
     get_currency_info_for_rounding(
            p_from_currency,
            p_conversion_date,
            p_return_status,
            p_error_buffer);
     IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RETURN NULL;
     END IF;

     l_from_type := g_currency_tbl(p_from_currency).currency_type;
     l_from_rate := g_currency_tbl(p_from_currency).conversion_rate;
   END IF;

   -- Get currency information from the to_currency

   -- Bug#6865855: check cache structure before access
   IF g_currency_tbl.EXISTS(p_to_currency) THEN
     l_to_type := g_currency_tbl(p_to_currency).currency_type;
     l_to_rate := g_currency_tbl(p_to_currency).conversion_rate;
   ELSE
     -- not exist in cache, need to populate it
     get_currency_info_for_rounding(
            p_to_currency,
            p_conversion_date,
            p_return_status,
            p_error_buffer);
     IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RETURN NULL;
     END IF;

     l_to_type := g_currency_tbl(p_to_currency).currency_type;
     l_to_rate := g_currency_tbl(p_to_currency).conversion_rate;
   END IF;


   -- Calculate the conversion rate according to both currency types

   IF ( l_from_type = 'EMU' ) THEN
     IF ( l_to_type = 'EMU' ) THEN
       l_converted_amount := ( p_amount / l_from_rate ) * l_to_rate;
       g_tax_curr_conv_rate_tbl(p_rate_index) :=  l_to_rate/l_from_rate;

     ELSIF ( l_to_type = 'EURO' ) THEN
       l_converted_amount := p_amount / l_from_rate;
       g_tax_curr_conv_rate_tbl(p_rate_index) := 1/l_from_rate;

     ELSIF ( l_to_type = 'OTHER' ) THEN
       -- Find out conversion rate from EURO to p_to_currency
       IF g_euro_code IS NULL THEN
         g_euro_code := get_euro_code(p_return_status,
                                      p_error_buffer );
       END IF;
       IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RETURN NULL;
       END IF;

       l_other_rate := get_other_rate(
                         g_euro_code,
                         p_to_currency,
                         p_conversion_date,
                         p_tax_conversion_type,
                         p_trx_conversion_type,
                         p_return_status,
                         p_error_buffer,
                         p_trx_conversion_date); --Bug7183884

       IF p_return_status =  FND_API.G_RET_STS_SUCCESS THEN
         -- Get conversion amt by converting EMU -> EURO -> OTHER
         l_converted_amount := ( p_amount / l_from_rate ) * l_other_rate;
         g_tax_curr_conv_rate_tbl(p_rate_index) := l_other_rate /l_from_rate;
       END IF;
     END IF;

     ELSIF ( l_from_type = 'EURO' ) THEN
       IF ( l_to_type = 'EMU' ) THEN
         l_converted_amount := p_amount * l_to_rate;
         g_tax_curr_conv_rate_tbl(p_rate_index) := l_to_rate;

       ELSIF ( l_to_type = 'EURO' ) THEN
          -- We should never comes to this case as it should be
          -- caught when we check if both to and from currency
          -- is the same at the beginning of this function
          l_converted_amount := p_amount;
          g_tax_curr_conv_rate_tbl(p_rate_index) := 1;

       ELSIF ( l_to_type = 'OTHER' ) THEN
          l_other_rate := get_other_rate(
                            p_from_currency,
                            p_to_currency,
                            p_conversion_date,
                            p_tax_conversion_type,
                            p_trx_conversion_type,
                            p_return_status,
                            p_error_buffer,
                            p_trx_conversion_date);--Bug7183884
          IF p_return_status = FND_API.G_RET_STS_SUCCESS THEN
            l_converted_amount := p_amount * l_other_rate;
            g_tax_curr_conv_rate_tbl(p_rate_index) := l_other_rate;
          END IF;
        END IF;

     ELSIF ( l_from_type = 'OTHER' ) THEN
       IF ( l_to_type = 'EMU' ) THEN
         -- Find out conversion rate from x_from_currency to EURO
         IF g_euro_code IS NULL THEN
           g_euro_code  := get_euro_code(p_return_status,
                                         p_error_buffer );
         END IF;

         IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           RETURN NULL;
         END IF;
         l_other_rate := get_other_rate(
                           p_from_currency,
                           g_euro_code,
                           p_conversion_date,
                           p_tax_conversion_type,
                           p_trx_conversion_type,
                           p_return_status,
                           p_error_buffer,
                           p_trx_conversion_date);--Bug7183884


         IF p_return_status = FND_API.G_RET_STS_SUCCESS THEN
           -- Get conversion amt by converting OTHER -> EURO -> EMU
           l_converted_amount := ( p_amount * l_other_rate ) * l_to_rate;
           g_tax_curr_conv_rate_tbl(p_rate_index) := l_other_rate * l_to_rate;
         END IF;
       ELSIF ( l_to_type = 'EURO' ) THEN
          l_other_rate := get_other_rate(
                            p_from_currency,
                            p_to_currency,
                            p_conversion_date,
                            p_tax_conversion_type,
                            p_trx_conversion_type,
                            p_return_status,
                            p_error_buffer,
                            p_trx_conversion_date);--Bug7183884


          IF p_return_status = FND_API.G_RET_STS_SUCCESS THEN
            l_converted_amount := p_amount * l_other_rate;
            g_tax_curr_conv_rate_tbl(p_rate_index) :=  l_other_rate;
          END IF;
       ELSIF ( l_to_type = 'OTHER' ) THEN
          l_other_rate := get_other_rate(
                            p_from_currency,
                            p_to_currency,
                            p_conversion_date,
                            p_tax_conversion_type,
                            p_trx_conversion_type,
                            p_return_status,
                            p_error_buffer ,
                            p_trx_conversion_date);--Bug7183884


          IF p_return_status = FND_API.G_RET_STS_SUCCESS THEN
            l_converted_amount := p_amount * l_other_rate;
            g_tax_curr_conv_rate_tbl(p_rate_index) :=  l_other_rate;
          END IF;
        END IF;
     END IF;

     IF (g_level_statement >= g_current_runtime_level ) THEN

       FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.convert_amount.END',
                      'converted amount = '||l_converted_amount);
       FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.convert_amount.END',
                      'ZX_TDS_TAX_ROUNDING_PKG: convert_amount(-)'||p_return_status);
     END IF;

     RETURN l_converted_amount;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.convert_amount',
                      p_error_buffer);
    END IF;

END convert_amount;

----------------------------------------------------------------------------
-- PRIVATE FUNCTION
--  get_rate_index
--
--  DESCRIPTION
--    returns the hash table index from a currency conversion rate structure
--
FUNCTION get_rate_index(
                p_from_currency   IN     VARCHAR2,
                p_to_currency     IN     VARCHAR2,
                p_conversion_date IN     Date,
                p_conversion_type IN     VARCHAR2)
RETURN BINARY_INTEGER IS
  l_tbl_index      BINARY_INTEGER;

BEGIN

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.get_rate_index.BEGIN',
                   'ZX_TDS_TAX_ROUNDING_PKG: get_rate_index(+)');
  END IF;

  l_tbl_index := dbms_utility.get_hash_value(
                    p_from_currency||
                    p_to_currency||
                    to_char(p_conversion_date, 'DD-MON-YY') ||
                    p_conversion_type,
                    1,
                    8192);


  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.get_rate_index',
                   'rate index = ' || to_char(l_tbl_index));
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.get_rate_index.END',
                   'ZX_TDS_TAX_ROUNDING_PKG: get_rate_index(-)');
  END IF;

  RETURN l_tbl_index;

EXCEPTION
  WHEN OTHERS THEN

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.get_rate_index',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
    END IF;
    RAISE;
END get_rate_index;
----------------------------------------------------------------------------
--  PRIVATE PROCEDURE
--   get_currency_info
--
--  DESCRIPTION
--    Gets currency type and rounding information for a given currency.
--
--
PROCEDURE get_currency_info(
                p_currency              IN      VARCHAR2,
                p_eff_date              IN      DATE,
                p_derive_effective         OUT NOCOPY  DATE,
                p_derive_type              OUT NOCOPY  VARCHAR2,
                p_conversion_rate          OUT NOCOPY  NUMBER,
                p_mau                      OUT NOCOPY  NUMBER,
                p_precision                OUT NOCOPY  NUMBER,
                p_currency_type            OUT NOCOPY  VARCHAR2,
                p_return_status            OUT NOCOPY  VARCHAR2,
                p_error_buffer             OUT NOCOPY  VARCHAR2 ) IS

----added for Bug 7519288
cursor getCurrencyInfo(c_currency varchar2) is
 SELECT decode( derive_type,
                    'EURO', 'EURO',
                    'EMU', decode( sign( trunc(p_eff_date) -
                                         trunc(derive_effective)),
                                   -1, 'OTHER',
                                   'EMU'),
                    'OTHER' ),
            decode( derive_type, 'EURO', 1,
                                 'EMU', derive_factor,
                                 'OTHER', -1 ),
            derive_type,
            derive_effective,
            minimum_accountable_unit,
            precision
     FROM   FND_CURRENCIES
     WHERE  currency_code = c_currency;

BEGIN

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.get_currency_info.BEGIN',
                   'ZX_TDS_TAX_ROUNDING_PKG: get_currency_info(+)'||
                   'p_currency = ' || p_currency||
                   'p_eff_date = ' || to_char(p_eff_date, 'DD-MON-YY'));
  END IF;

  p_return_status :=  FND_API.G_RET_STS_SUCCESS;

     -- Get currency information from FND_CURRENCIES table
--Commented for Bug 7519288
/*     SELECT decode( derive_type,
                    'EURO', 'EURO',
                    'EMU', decode( sign( trunc(p_eff_date) -
                                         trunc(derive_effective)),
                                   -1, 'OTHER',
                                   'EMU'),
                    'OTHER' ),
            decode( derive_type, 'EURO', 1,
                                 'EMU', derive_factor,
                                 'OTHER', -1 ),
            derive_type,
            derive_effective,
            minimum_accountable_unit,
            precision
     INTO   p_currency_type,
            p_conversion_rate,
            p_derive_type,
            p_derive_effective,
            p_mau,
            p_precision
     FROM   FND_CURRENCIES
     WHERE  currency_code = p_currency;*/

   Open getCurrencyInfo(p_currency);
   Fetch getCurrencyInfo
     INTO   p_currency_type,
            p_conversion_rate,
            p_derive_type,
            p_derive_effective,
            p_mau,
            p_precision;

      if getCurrencyInfo%notfound then

         IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                         'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.get_currency_info',
                         'No currency info found for : ' ||p_currency);
         END IF;

       end if;

   Close getCurrencyInfo;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.get_currency_info',
                   'p_currency_type = ' || p_currency_type||
                   'p_derive_type = ' || p_derive_type||
                   'p_derive_effective = ' ||
                    to_char(p_derive_effective, 'DD-MON-YY')||
                   'p_conversion_rate = ' || to_char(p_conversion_rate)||
                   'p_mau = ' || to_char(p_mau)||
                   'p_precision = ' || to_char(p_precision));
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.get_currency_info.END',
                   'ZX_TDS_TAX_ROUNDING_PKG: get_currency_info(-)');
  END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       p_error_buffer  := 'Currency type and Currency rate not found in FND_CURRENCIES';
       IF (g_level_unexpected >= g_current_runtime_level ) THEN
         FND_LOG.STRING(g_level_unexpected,
                        'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.get_currency_info',
                         p_error_buffer);
       END IF;

    WHEN OTHERS THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.get_currency_info',
                        p_error_buffer);
      END IF;

END get_currency_info;
----------------------------------------------------------------------------
-- PRIVATE FUNCTION
--   get_other_rate
--
--  DESCRIPTION
--    Returns conversion rate between two currencies where both currencies
--    are not the EURO, or EMU currencies.
--
FUNCTION get_other_rate (
                p_from_currency       IN     VARCHAR2,
                p_to_currency         IN     VARCHAR2,
                p_conversion_date     IN     Date,
                p_tax_conversion_type IN     VARCHAR2,
                p_trx_conversion_type IN     VARCHAR2,
                p_return_status       OUT NOCOPY VARCHAR2,
                p_error_buffer        OUT NOCOPY VARCHAR2,
                p_trx_conversion_date IN  DATE DEFAULT NULL) RETURN NUMBER IS  --Bug7183884

   l_rate NUMBER;

  CURSOR get_rate_info_csr
    (c_from_currency     ZX_LINES.trx_currency_code%TYPE,
     c_to_currency       ZX_LINES.tax_currency_code%TYPE,
     c_conversion_date   ZX_LINES.currency_conversion_date%TYPE,
     c_conversion_type   ZX_LINES.currency_conversion_type%TYPE)
  IS
     SELECT     conversion_rate
     FROM       GL_DAILY_RATES
     WHERE      from_currency = c_from_currency
     AND        to_currency = c_to_currency
     AND        conversion_date = trunc(c_conversion_date)
     AND        conversion_type = c_conversion_type;
BEGIN

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.get_other_rate.BEGIN',
                   'ZX_TDS_TAX_ROUNDING_PKG: get_other_rate(+)'||
                   'p_from_currency = ' || p_from_currency||
                   'p_to_currency = ' || p_to_currency||
                   'p_conversion_date = ' ||
                      to_char(p_conversion_date, 'DD-MON-YY')||
                   'P_trx_conversion_date = '||
                      to_char(p_trx_conversion_date, 'DD-MON-YY')||
                   'p_tax_conversion_type = ' || p_tax_conversion_type||
                   'p_trx_conversion_type = ' || p_trx_conversion_type);
  END IF;

  p_return_status :=  FND_API.G_RET_STS_SUCCESS;
  l_rate := NULL;

  IF p_tax_conversion_type IS NOT NULL THEN
    --
    -- use tax exchange rate type 1st
    --
    OPEN get_rate_info_csr(
              p_from_currency,
              p_to_currency,
              p_conversion_date,
              p_tax_conversion_type);
    FETCH get_rate_info_csr INTO l_rate;
    IF get_rate_info_csr%NOTFOUND THEN
      IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
                         'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.get_other_rate',
                         'No rate found for tax  conversion type: ' ||
                         p_tax_conversion_type||
                         ' p_conversion_date = ' ||
                         to_char(p_conversion_date, 'DD-MON-YY'));
      END IF;
    END IF;

    CLOSE get_rate_info_csr;

  END IF; -- Tax Conversion Type ends

  IF l_rate IS NOT NULL THEN
    IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.get_other_rate.END',
                   'ZX_TDS_TAX_ROUNDING_PKG: get_other_rate(-)'||
                       'rate = ' || to_char(l_rate));
    END IF;
    RETURN (l_rate);
  END IF;

  --
  -- get here either tax_conversion_type is null or
  -- l_rate is still NULL, try to get rate based on
  -- trx_conversion_type
  --


  OPEN get_rate_info_csr(
              p_from_currency,
              p_to_currency,
              p_conversion_date,
              p_trx_conversion_type);
  FETCH get_rate_info_csr INTO l_rate;
    IF get_rate_info_csr%NOTFOUND THEN
      IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
                         'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.get_other_rate',
                         'No rate found for trx conversion type: ' ||
                         p_tax_conversion_type||
                         ' p_conversion_date = ' ||
                         to_char(p_conversion_date, 'DD-MON-YY'));
      END IF;
     END IF;

  CLOSE get_rate_info_csr;



  IF l_rate IS NOT NULL THEN
    IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.get_other_rate.END',
                   'ZX_TDS_TAX_ROUNDING_PKG: get_other_rate(-)'||
                       'rate = ' || to_char(l_rate));
    END IF;
    RETURN (l_rate);
  END IF;

  --Bug7183884

  IF p_trx_conversion_date IS NOT NULL THEN

     IF (g_level_statement >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_statement,
                    'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.get_other_rate',
                    'Getting Rate information based on Currency Converion Date '||
                    ' P_trx_conversion_date = '||
                              to_char(p_trx_conversion_date, 'DD-MON-YY'));
     END IF;

     IF p_tax_conversion_type IS NOT NULL THEN

        OPEN get_rate_info_csr(
                p_from_currency,
                p_to_currency,
                p_trx_conversion_date,
                p_tax_conversion_type);
       FETCH get_rate_info_csr INTO l_rate;

       IF get_rate_info_csr%NOTFOUND THEN
          IF (g_level_statement >= g_current_runtime_level ) THEN
             FND_LOG.STRING(g_level_statement,
                            'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.get_other_rate',
                             'No rate found for tax  conversion type: ' ||
                              p_tax_conversion_type||
                              ' P_trx_conversion_date = '||
                              to_char(p_trx_conversion_date, 'DD-MON-YY'));
         END IF;
       END IF;

       CLOSE get_rate_info_csr;
    END IF;

    IF l_rate IS NOT NULL THEN
      IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.get_other_rate.END',
                     'ZX_TDS_TAX_ROUNDING_PKG: get_other_rate(-)'||
                         'rate = ' || to_char(l_rate));
      END IF;
      RETURN (l_rate);
    END IF;

    OPEN get_rate_info_csr(
               p_from_currency,
               p_to_currency,
               p_trx_conversion_date,
               p_trx_conversion_type);
    FETCH get_rate_info_csr INTO l_rate;
    IF get_rate_info_csr%NOTFOUND THEN
       p_return_status := FND_API.G_RET_STS_ERROR;

       -- Conversion rate not found in GL_DAILY_RATES
       FND_MESSAGE.SET_NAME('ZX','ZX_ROUND_NO_EXCH_RATE');
       FND_MESSAGE.SET_TOKEN('FROM_CURRENCY', p_from_currency);
       FND_MESSAGE.SET_TOKEN('TO_CURRENCY', p_to_currency);
       FND_MESSAGE.SET_TOKEN('CURRENCY_CONV_DATE', p_conversion_date);
       FND_MESSAGE.SET_TOKEN('TRX_CURRENCY_CONV_DATE',p_trx_conversion_date);
       IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_id IS NOT NULL THEN
         ZX_API_PUB.add_msg(
           ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec);
       ELSE
         FND_MSG_PUB.Add;
       END IF;

       IF (g_level_error >= g_current_runtime_level ) THEN
         FND_LOG.STRING(g_level_error,
                        'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.get_other_rate',
                         p_error_buffer);
       END IF;

     END IF;

    CLOSE get_rate_info_csr;

  END IF;  --p_trx_conversion_date check ends


  IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.get_other_rate.END',
                   'ZX_TDS_TAX_ROUNDING_PKG: get_other_rate(-)'||
                       'rate = ' || to_char(l_rate));
  END IF;

  RETURN( l_rate );


  EXCEPTION
    WHEN OTHERS THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.get_other_rate',
                        p_error_buffer);
      END IF;

END get_other_rate;
--------------------------------------------------------------------
-- PRIVATE FUNCTION
--  get_euro_code
--
--  DESCRIPTION
--  This function returns the euro code
--
FUNCTION get_euro_code(p_return_status OUT NOCOPY VARCHAR2,
                       p_error_buffer  OUT NOCOPY VARCHAR2)
 RETURN VARCHAR2 IS
    euro_code   VARCHAR2(15);

BEGIN

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.get_euro_code.BEGIN',
                   'ZX_TDS_TAX_ROUNDING_PKG: get_euro_code(+)');
  END IF;

  p_return_status :=  FND_API.G_RET_STS_SUCCESS;

    -- Get currency code of the EURO currency
    SELECT      currency_code
    INTO        euro_code
    FROM        FND_CURRENCIES
    WHERE       derive_type = 'EURO';


  IF (g_level_statement >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.get_euro_code.END',
                   'ZX_TDS_TAX_ROUNDING_PKG: get_euro_code(-)'||' euro_code = ' || euro_code);
  END IF;

  RETURN( euro_code );

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
       p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       p_error_buffer  := 'EURO code not found in FND_CURRENCIES';
       FND_MESSAGE.SET_NAME('ZX','ZX_UNEXPECTED_ERROR');
       IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_id IS NOT NULL THEN
         ZX_API_PUB.add_msg(
          ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec);
       ELSE
         FND_MSG_PUB.Add;
       END IF;

       IF (g_level_unexpected >= g_current_runtime_level ) THEN
         FND_LOG.STRING(g_level_unexpected,
                        'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.get_euro_code',
                         p_error_buffer);
       END IF;

    WHEN OTHERS THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.get_euro_code',
                        p_error_buffer);
      END IF;

END get_euro_code;

-----------------------------------------------------------------------
--  PUBLIC FUNCTION
--  round_tax
--
--  DESCRIPTION
--  The function is used to round an amount according to the
--  rounding rules
--

FUNCTION round_tax(
           p_amount        IN     NUMBER,
           p_Rounding_Rule_Code IN     ZX_TAXES_B.Rounding_Rule_Code%TYPE,
           p_min_acct_unit IN     ZX_TAXES_B.MINIMUM_ACCOUNTABLE_UNIT%TYPE,
           p_precision     IN     ZX_TAXES_B.TAX_PRECISION%TYPE,
           p_return_status OUT NOCOPY VARCHAR2,
           p_error_buffer  OUT NOCOPY VARCHAR2
         )
RETURN NUMBER IS
  l_rounded_amt     NUMBER;
BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.round_tax.BEGIN',
                   'ZX_TDS_TAX_ROUNDING_PKG: round_tax(+)'||
                   'round rule = ' || p_Rounding_Rule_Code||
                   'p_min_acct_unit = ' || to_char(p_min_acct_unit)||
                   'p_precision = ' || to_char(p_precision));
  END IF;

  p_return_status :=  FND_API.G_RET_STS_SUCCESS;

  --
  -- check if all require info are available for rounding
  --
  IF (p_amount IS NULL OR
      (p_min_acct_unit IS NULL AND p_precision IS NULL)) THEN

    IF (g_level_statement >= g_current_runtime_level ) THEN

          FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.round_tax.END',
                   'ZX_TDS_TAX_ROUNDING_PKG: round_tax(-)'||
                   'Not enough info to perform rounding '||
                   'Amount, Rounding rule, Mau, or Precison is NULL');
    END IF;

    RETURN p_amount;
  END IF;
  --
  -- round UP
  --
  IF p_Rounding_Rule_Code = 'UP' THEN
    IF p_min_acct_unit is NOT NULL THEN
      -- Use Minimum Accountable Unit
      l_rounded_amt := SIGN(p_amount) *
            (CEIL(ABS(p_amount)/p_min_acct_unit) * p_min_acct_unit);
     ELSE
       -- Use precision
      IF (p_amount = TRUNC(p_amount, p_precision)) THEN
        l_rounded_amt := p_amount;
      ELSE
        l_rounded_amt := ROUND(p_amount+(SIGN(p_amount) *
                         (POWER(10,(p_precision * (-1)))/2)), p_precision);
       END IF;
     END IF;
   --
   -- round DOWN
   --
  ELSIF p_Rounding_Rule_Code = 'DOWN' THEN
    IF p_min_acct_unit is NOT NULL THEN
      -- Use Minimum Accountable Unit
      -- currently in AR:
      -- l_rounded_amt := TRUNC(p_amount/p_min_acct_unit) * p_min_acct_unit);
      -- currently in AP:
      l_rounded_amt := SIGN(p_amount)*
                    (FLOOR(ABS(p_amount)/p_min_acct_unit) * p_min_acct_unit);
    ELSE
      -- Use precision
      l_rounded_amt := TRUNC(p_amount, p_precision);
    END IF;
  --
  -- round NEAREST
  --
  ELSIF (p_Rounding_Rule_Code = 'NEAREST' OR
         p_Rounding_Rule_Code IS NULL) THEN
    IF p_min_acct_unit is NOT NULL THEN
      -- Use Minimum Accountable Unit
      l_rounded_amt := ROUND(p_amount/p_min_acct_unit) * p_min_acct_unit;
    ELSE
      -- Use precision
      l_rounded_amt := ROUND(p_amount, p_precision);
    END IF;
  ELSE
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := 'Unknown Rounding Rule Code';
  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.round_tax.END',
                   'ZX_TDS_TAX_ROUNDING_PKG: round_tax(-)'||p_return_status);
  END IF;

  RETURN l_rounded_amt;

EXCEPTION
  WHEN ZERO_DIVIDE THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := 'Minimum Accountable Unit can not be 0';
    FND_MESSAGE.SET_NAME('ZX','GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','round_tax- '|| p_error_buffer);
    FND_MSG_PUB.Add;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
         FND_LOG.STRING(g_level_unexpected,
                        'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.round_tax',
                         p_error_buffer);
    END IF;

    WHEN OTHERS THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.round_tax',
                        p_error_buffer);
      END IF;

END round_tax;
-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  det_rounding_level_basis
--
--  DESCRIPTION
--
--  This procedure determines the rounding level basis
--  based on the party type passed in
--
--

PROCEDURE det_rounding_level_basis(
            p_Party_Type_Code      IN     VARCHAR2,
            p_rounding_level_basis    OUT NOCOPY  VARCHAR2,
            p_return_status           OUT NOCOPY  VARCHAR2,
            p_error_buffer            OUT NOCOPY  VARCHAR2
           )
IS

BEGIN

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.det_rounding_level_basis.BEGIN',
                   'ZX_TDS_TAX_ROUNDING_PKG: det_rounding_level_basis(+)'||
                   'Party_Type_Code = ' || p_Party_Type_Code);
  END IF;

  p_return_status :=  FND_API.G_RET_STS_SUCCESS;

  --
  -- determine the rounding party type
  --
  IF p_Party_Type_Code IN ('SHIP_TO_PTY',
                      'SHIP_FROM_PTY',
                      'BILL_TO_PTY',
                      'BILL_FROM_PTY') THEN
    p_rounding_level_basis := 'PARTY';
  ELSIF p_Party_Type_Code IN ('SHIP_TO_PTY_SITE',
                         'SHIP_FROM_PTY_SITE',
                         'BILL_TO_PTY_SITE',
                         'BILL_FROM_PTY_SITE') THEN
    p_rounding_level_basis := 'SITE';
  ELSE
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := 'Invalid Rounding Level Hierarchy';

    IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.det_rounding_level_basis.END',
                   'ZX_TDS_TAX_ROUNDING_PKG: det_rounding_level_basis(-)'||
                   'p_return_status = ' || p_return_status||
                   'p_error_buffer  = ' || p_error_buffer);
    END IF;

    RETURN;
  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.det_rounding_level_basis.END',
                   'ZX_TDS_TAX_ROUNDING_PKG: det_rounding_level_basis(-)'||
                    'p_rounding_level_basis = ' || p_rounding_level_basis);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.det_rounding_level_basis',
                      p_error_buffer);
    END IF;

END det_rounding_level_basis;
-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  determine_round_level_and_rule
--
--  DESCRIPTION
--
--  This procedure determines the party_tax_profile_id used to get the
--  rounding level code and rounding rule code from zx_party_tax_profile
--
PROCEDURE determine_round_level_and_rule(
            p_Party_Type_Code               IN VARCHAR2,
            p_event_class_rec               IN ZX_API_PUB.EVENT_CLASS_REC_TYPE,
            p_tax_prof_id                   OUT NOCOPY  ZX_PARTY_TAX_PROFILE.PARTY_TAX_PROFILE_ID%TYPE,
            p_rounding_level_code           OUT NOCOPY  ZX_PARTY_TAX_PROFILE.ROUNDING_LEVEL_CODE%TYPE,
            p_rounding_rule_code            OUT NOCOPY  ZX_PARTY_TAX_PROFILE.ROUNDING_RULE_CODE%TYPE,
            p_return_status                 OUT NOCOPY  VARCHAR2,
            p_error_buffer                  OUT NOCOPY  VARCHAR2,
            p_ship_third_pty_acct_id        IN NUMBER,
            p_bill_third_pty_acct_id        IN NUMBER,
            p_ship_third_pty_acct_site_id   IN NUMBER,
            p_bill_third_pty_acct_site_id   IN NUMBER,
            p_ship_to_cust_acct_st_use_id   IN NUMBER,
            p_bill_to_cust_acct_st_use_id   IN NUMBER,
            p_tax_determine_date            IN DATE
           )
IS
  l_tax_prof_name                  VARCHAR(30);
  l_rounding_level_basis           VARCHAR(8);
  l_account_site_id        hz_cust_acct_sites_all.cust_acct_site_id%TYPE;
  l_site_use_id            hz_cust_site_uses_all.site_use_id%TYPE;
  l_account_id             hz_cust_accounts.cust_account_id%TYPE;
  l_parent_ptp_id          zx_party_tax_profile.party_tax_profile_id%TYPE;
  l_site_ptp_id            zx_party_tax_profile.party_tax_profile_id%TYPE;
  l_registration_rec       zx_tcm_control_pkg.zx_registration_info_rec;
  l_tax_service_type_code  zx_rules_b.service_type_code%TYPE;
  l_ret_record_level       VARCHAR2(30);


BEGIN

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.determine_round_level_and_rule.BEGIN',
                   'ZX_TDS_TAX_ROUNDING_PKG: determine_round_level_and_rule(+)');
  END IF;

  p_return_status :=  FND_API.G_RET_STS_SUCCESS;

  --
  -- determine the rounding party type
  --
  det_rounding_level_basis(
           p_Party_Type_Code,
           l_rounding_level_basis,
           p_return_status,
           p_error_buffer);

  IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RETURN;
  END IF;

  IF l_rounding_level_basis = 'PARTY' THEN
    l_tax_prof_name := 'RDNG' || '_'||p_Party_Type_Code ||'_'|| 'TX_PROF_ID';
  ELSE
    --
    -- party site
    --
    l_tax_prof_name := RTRIM(p_Party_Type_Code, 'SITE');
    l_tax_prof_name := 'RDNG' || '_' || l_tax_prof_name || 'TX_P_ST_ID';
  END IF;
  --
  -- get party/party_site tax_prof_id based on the name
  --
  IF l_tax_prof_name = 'RDNG_SHIP_TO_PTY_TX_PROF_ID' THEN
    p_tax_prof_id := p_event_class_rec.rdng_ship_to_pty_tx_prof_id;
    l_parent_ptp_id := p_tax_prof_id;
    l_site_ptp_id := NULL;
  ELSIF l_tax_prof_name = 'RDNG_SHIP_FROM_PTY_TX_PROF_ID' THEN
    p_tax_prof_id := p_event_class_rec.rdng_ship_from_pty_tx_prof_id;
    l_parent_ptp_id := p_tax_prof_id;
    l_site_ptp_id := NULL;
  ELSIF l_tax_prof_name = 'RDNG_BILL_TO_PTY_TX_PROF_ID' THEN
    p_tax_prof_id := p_event_class_rec.rdng_bill_to_pty_tx_prof_id;
    l_parent_ptp_id := p_tax_prof_id;
    l_site_ptp_id := NULL;
  ELSIF l_tax_prof_name = 'RDNG_BILL_FROM_PTY_TX_PROF_ID' THEN
    p_tax_prof_id := p_event_class_rec.rdng_bill_from_pty_tx_prof_id;
    l_parent_ptp_id := p_tax_prof_id;
    l_site_ptp_id := NULL;
  ELSIF l_tax_prof_name = 'RDNG_SHIP_TO_PTY_TX_P_ST_ID' THEN
    p_tax_prof_id := p_event_class_rec.rdng_ship_to_pty_tx_p_st_id;
    l_parent_ptp_id := p_event_class_rec.rdng_ship_to_pty_tx_prof_id;
    l_site_ptp_id := p_tax_prof_id;
  ELSIF l_tax_prof_name = 'RDNG_SHIP_FROM_PTY_TX_P_ST_ID' THEN
    p_tax_prof_id := p_event_class_rec.rdng_ship_from_pty_tx_p_st_id;
    l_parent_ptp_id := p_event_class_rec.rdng_ship_from_pty_tx_prof_id;
    l_site_ptp_id := p_tax_prof_id;
  ELSIF l_tax_prof_name = 'RDNG_BILL_TO_PTY_TX_P_ST_ID' THEN
    p_tax_prof_id := p_event_class_rec.rdng_bill_to_pty_tx_p_st_id;
    l_parent_ptp_id := p_event_class_rec.rdng_bill_to_pty_tx_prof_id;
    l_site_ptp_id := p_tax_prof_id;
  ELSIF l_tax_prof_name = 'RDNG_BILL_FROM_PTY_TX_P_ST_ID' THEN
    p_tax_prof_id := p_event_class_rec.rdng_bill_from_pty_tx_p_st_id;
    l_parent_ptp_id := p_event_class_rec.rdng_bill_from_pty_tx_prof_id;
    l_site_ptp_id := p_tax_prof_id;
  END IF;

-- Following line commented out for Bug 4939819 fix
--  IF p_tax_prof_id IS NOT NULL THEN

    IF SUBSTR(p_Party_Type_Code, 1, 4) = 'SHIP' THEN

      l_account_id := p_ship_third_pty_acct_id;
      l_account_site_id := p_ship_third_pty_acct_site_id;
      l_site_use_id := p_ship_to_cust_acct_st_use_id;

    ELSIF SUBSTR(p_Party_Type_Code, 1, 4) = 'BILL' THEN

      l_account_id := p_bill_third_pty_acct_id;
      l_account_site_id := p_bill_third_pty_acct_site_id;
      l_site_use_id := p_bill_to_cust_acct_st_use_id;

    ELSE
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      p_error_buffer  := 'Invalid Rounding Level Hierarchy';

      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.determine_round_level_and_rule',
                     'p_return_status = ' || p_return_status);
        FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.determine_round_level_and_rule',
                     'p_error_buffer  = ' || p_error_buffer);
      END IF;
      RETURN;
    END IF;

    --
    -- Bug#5501788- get rounding level and rule at document level
    --
    get_rounding_level(
           p_parent_ptp_id        => l_parent_ptp_id,
           p_site_ptp_id          => l_site_ptp_id,
           p_account_type_code    => p_event_class_rec.sup_cust_acct_type,
           p_account_id           => l_account_id,
           p_account_site_id      => l_account_site_id,
           p_site_use_id          => l_site_use_id,
           p_rounding_level_code  => p_rounding_level_code,
           p_rounding_rule_code   => p_rounding_rule_code,
           p_return_status        => p_return_status,
           p_error_buffer         => p_error_buffer
         );

    /*** Bug#5501788- do not need to call this any more
    -- Call TCM API to get the rounding level and rounding rule
    --
    ZX_TCM_CONTROL_PKG.get_tax_registration (
           p_parent_ptp_id        => l_parent_ptp_id,
           p_site_ptp_id          => l_site_ptp_id,
           p_account_type_code    => p_event_class_rec.sup_cust_acct_type,
           p_tax_determine_date   => p_tax_determine_date,
           p_tax                  => NULL,
           p_tax_regime_code      => NULL,
           p_jurisdiction_code    => NULL,
           p_account_id           => l_account_id,
           p_account_site_id      => l_account_site_id,
           p_site_use_id          => l_site_use_id,
           p_zx_registration_rec  => l_registration_rec,
           p_ret_record_level     => l_ret_record_level,
           p_return_status        => P_return_status);

    **********/

    IF p_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
               'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.determine_round_level_and_rule',
               'Incorrect return_status after calling ' ||
               'get_rounding_level()');

      END IF;
      p_rounding_level_code := NULL;
      p_rounding_rule_code := NULL;
      p_return_status := FND_API.G_RET_STS_SUCCESS;
    END IF;

    -- populate rounding_level_code and rounding_rule_code
    --
    -- Bug#5501788- rounding level code and rule should come from
    -- get_rounding_level procedure
    --p_rounding_level_code := l_registration_rec.rounding_level_code;

    --p_rounding_rule_code := l_registration_rec.rounding_rule_code;

-- Fix for Bug 4939819 - PTP setup is not mandatory. So, check for existence of
-- account_id also

--  ELSE
  IF (p_tax_prof_id IS NULL) and (l_account_id IS NULL) THEN
    -- p_tax_prof_id IS NULL, skip this rounding hierarchy
    --
    p_rounding_level_code := NULL;
    p_rounding_rule_code := NULL;

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.determine_round_level_and_rule',
                   'p_tax_prof_id IS NULL.');
    END IF;
  END IF;   -- p_tax_prof_id IS NOT NULL, OR ELSE

  IF (g_level_procedure >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.determine_round_level_and_rule.END',
                   'ZX_TDS_TAX_ROUNDING_PKG: determine_round_level_and_rule(-)'||
                   'p_rounding_level_code = ' || p_rounding_level_code||
                   'p_rounding_rule_code = ' || p_rounding_rule_code);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.determine_round_level_and_rule',
                      p_error_buffer);
    END IF;

END determine_round_level_and_rule;

-----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  determine_rounding_rule
--
--  DESCRIPTION
--
--  This procedure determines the party_tax_profile_id used to get the
--  rounding rule code from zx_party_tax_profile
--
--
PROCEDURE determine_rounding_rule(
  p_trx_line_index     IN            BINARY_INTEGER,
  p_event_class_rec    IN            ZX_API_PUB.EVENT_CLASS_REC_TYPE,
  p_party_type_code    IN            VARCHAR2,
  p_tax_regime_code    IN            VARCHAR2,
  p_tax                IN            VARCHAR2,
  p_jurisdiction_code  IN            VARCHAR2,
  p_tax_determine_date IN            DATE,
  p_rounding_rule_code    OUT NOCOPY ZX_PARTY_TAX_PROFILE.ROUNDING_RULE_CODE%TYPE,
  p_return_status         OUT NOCOPY VARCHAR2,
  p_error_buffer          OUT NOCOPY VARCHAR2) IS

  l_tax_prof_id          ZX_PARTY_TAX_PROFILE.PARTY_TAX_PROFILE_ID%TYPE;
  l_tax_prof_name        VARCHAR(30);
  l_rounding_level_basis VARCHAR(8);

  l_account_site_id        hz_cust_acct_sites_all.cust_acct_site_id%TYPE;
  l_site_use_id            hz_cust_site_uses_all.site_use_id%TYPE;
  l_account_id             hz_cust_accounts.cust_account_id%TYPE;
  l_parent_ptp_id          zx_party_tax_profile.party_tax_profile_id%TYPE;
  l_site_ptp_id            zx_party_tax_profile.party_tax_profile_id%TYPE;
  l_registration_rec       zx_tcm_control_pkg.zx_registration_info_rec;
  l_tax_service_type_code  zx_rules_b.service_type_code%TYPE;
  l_ret_record_level       VARCHAR2(30);

BEGIN

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.determine_rounding_rule.BEGIN',
                   'ZX_TDS_TAX_ROUNDING_PKG: determine_rounding_rule(+)');
  END IF;

  p_return_status :=  FND_API.G_RET_STS_SUCCESS;

  --
  -- determine the rounding party type
  --
  det_rounding_level_basis(
           p_party_type_code,
           l_rounding_level_basis,
           p_return_status,
           p_error_buffer);

  IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RETURN;
  END IF;

  IF l_rounding_level_basis = 'PARTY' THEN
    l_tax_prof_name := RTRIM(p_Party_Type_Code, '_PTY');
    l_tax_prof_name := l_tax_prof_name ||'_'|| 'PARTY_TAX_PROF_ID';
  ELSE
    --
    -- party site
    --
    l_tax_prof_name := RTRIM(p_Party_Type_Code, '_PTY_SITE');
    l_tax_prof_name := l_tax_prof_name || '_' || 'SITE_TAX_PROF_ID';
  END IF;

  -- get party/party_site tax_prof_id
  --

  IF l_tax_prof_name = 'SHIP_TO_PARTY_TAX_PROF_ID' THEN
    l_tax_prof_id :=
      ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ship_to_party_tax_prof_id(p_trx_line_index);
    l_parent_ptp_id := l_tax_prof_id;
    l_site_ptp_id := NULL;
  ELSIF l_tax_prof_name = 'SHIP_FROM_PARTY_TAX_PROF_ID' THEN
    l_tax_prof_id :=
      ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ship_from_party_tax_prof_id(p_trx_line_index);
    l_parent_ptp_id := l_tax_prof_id;
    l_site_ptp_id := NULL;
  ELSIF l_tax_prof_name = 'BILL_TO_PARTY_TAX_PROF_ID' THEN
    l_tax_prof_id :=
      ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.bill_to_party_tax_prof_id(p_trx_line_index);
    l_parent_ptp_id := l_tax_prof_id;
    l_site_ptp_id := NULL;
  ELSIF l_tax_prof_name = 'BILL_FROM_PARTY_TAX_PROF_ID' THEN
    l_tax_prof_id :=
      ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.bill_from_party_tax_prof_id(p_trx_line_index);
    l_parent_ptp_id := l_tax_prof_id;
    l_site_ptp_id := NULL;
  ELSIF l_tax_prof_name = 'SHIP_TO_SITE_TAX_PROF_ID' THEN
    l_tax_prof_id :=
      ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ship_to_site_tax_prof_id(p_trx_line_index);
    l_parent_ptp_id :=
      ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ship_to_party_tax_prof_id(p_trx_line_index);
    l_site_ptp_id := l_tax_prof_id;
  ELSIF l_tax_prof_name = 'SHIP_FROM_SITE_TAX_PROF_ID' THEN
    l_tax_prof_id :=
      ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ship_from_site_tax_prof_id(p_trx_line_index);
    l_parent_ptp_id :=
      ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ship_from_party_tax_prof_id(p_trx_line_index);
    l_site_ptp_id := l_tax_prof_id;
  ELSIF l_tax_prof_name = 'BILL_TO_SITE_TAX_PROF_ID' THEN
    l_tax_prof_id :=
      ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.bill_to_site_tax_prof_id(p_trx_line_index);
    l_parent_ptp_id :=
      ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.bill_to_party_tax_prof_id(p_trx_line_index);
    l_site_ptp_id := l_tax_prof_id;
  ELSIF l_tax_prof_name = 'BILL_FROM_SITE_TAX_PROF_ID' THEN
    l_tax_prof_id :=
      ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.bill_from_site_tax_prof_id(p_trx_line_index);
    l_parent_ptp_id :=
      ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.bill_from_party_tax_prof_id(p_trx_line_index);
    l_site_ptp_id := l_tax_prof_id;
  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.determine_rounding_rule',
                   'l_tax_prof_id = ' || to_char(l_tax_prof_id));
  END IF;

-- Following line commented out for Bug 4939819 fix
--  IF l_tax_prof_id IS NOT NULL THEN

  -- determine account, account_site, account_site_use information
  -- from transaction line
  --
  IF SUBSTR(p_Party_Type_Code, 1, 4) = 'SHIP' THEN

    l_account_id :=
      ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ship_third_pty_acct_id(p_trx_line_index);
    l_account_site_id :=
      ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ship_third_pty_acct_site_id(p_trx_line_index);
    l_site_use_id :=
      ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ship_to_cust_acct_site_use_id(p_trx_line_index);

  ELSIF SUBSTR(p_Party_Type_Code, 1, 4) = 'BILL' THEN

    l_account_id :=
      ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.bill_third_pty_acct_id(p_trx_line_index);
    l_account_site_id :=
      ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.bill_third_pty_acct_site_id(p_trx_line_index);
    l_site_use_id :=
      ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.bill_to_cust_acct_site_use_id(p_trx_line_index);

  ELSE
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := 'Invalid Rounding Level Hierarchy';

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.determine_rounding_rule',
                   'p_return_status = ' || p_return_status);
      FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.determine_rounding_rule',
                   'p_error_buffer  = ' || p_error_buffer);
    END IF;
    RETURN;
  END IF;

    -- Call TCM API to determine rounding rule
    --
    ZX_TCM_CONTROL_PKG.get_tax_registration (
           p_parent_ptp_id        => l_parent_ptp_id,
           p_site_ptp_id          => l_site_ptp_id,
           p_account_type_code    => p_event_class_rec.sup_cust_acct_type,
           p_tax_determine_date   => p_tax_determine_date,
           p_tax                  => p_tax,
           p_tax_regime_code      => p_tax_regime_code,
           p_jurisdiction_code    => p_jurisdiction_code,
           p_account_id           => l_account_id,
           p_account_site_id      => l_account_site_id,
           p_site_use_id          => l_site_use_id,
           p_zx_registration_rec  => l_registration_rec,
           p_ret_record_level     => l_ret_record_level,
           p_return_status        => P_return_status);

    IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_error >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_error,
               'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.determine_rounding_rule',
               'Incorrect return_status after calling ' ||
               'ZX_TCM_CONTROL_PKG.get_tax_registration()');
        FND_LOG.STRING(g_level_error,
               'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.determine_rounding_rule',
               'Continue processing ...');
      END IF;
      p_rounding_rule_code := NULL;
      p_return_status := FND_API.G_RET_STS_SUCCESS;
      RETURN;
    END IF;

    -- populate rounding_rule_code
    --
    p_rounding_rule_code := l_registration_rec.rounding_rule_code;

-- Fix for Bug 4939819 - PTP setup is not mandatory. So, check for existence of
-- account_id also
--  ELSE
  IF (l_tax_prof_id IS NULL) and (l_account_id IS NULL) THEN
    -- l_tax_prof_id IS NULL, skip this rounding hierarchy
    --
    p_rounding_rule_code := NULL;

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.determine_rounding_rule',
                   'l_tax_prof_id IS NULL.');
    END IF;
  END IF;   -- l_tax_prof_id IS NOT NULL, OR ELSE

  IF (g_level_procedure >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.determine_rounding_rule.END',
                   'ZX_TDS_TAX_ROUNDING_PKG: determine_rounding_rule(-)'||
                   'p_rounding_rule_code = ' || p_rounding_rule_code);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.determine_rounding_rule',
                      p_error_buffer);
    END IF;

END determine_rounding_rule;

-----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  get_rounding_rule
--
--  DESCRIPTION
--
--  This procedure gets the rounding rule through party hierachy
--
PROCEDURE get_rounding_rule(
  p_trx_line_index      IN             BINARY_INTEGER,
  p_event_class_rec     IN             ZX_API_PUB.EVENT_CLASS_REC_TYPE,
  p_tax_regime_code     IN             VARCHAR2,
  p_tax                 IN             VARCHAR2,
  p_jurisdiction_code   IN             VARCHAR2,
  p_tax_determine_date  IN             DATE,
  p_rounding_rule_code     OUT NOCOPY  ZX_PARTY_TAX_PROFILE.ROUNDING_RULE_CODE%TYPE,
  p_return_status          OUT NOCOPY  VARCHAR2,
  p_error_buffer           OUT NOCOPY  VARCHAR2) IS

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.get_rounding_rule.BEGIN',
                   'ZX_TDS_TAX_ROUNDING_PKG: get_rounding_rule(+)');
  END IF;

  p_return_status :=  FND_API.G_RET_STS_SUCCESS;

  IF p_event_class_rec.rounding_level_hier_1_code IS NOT NULL THEN

    determine_rounding_rule(
                             p_trx_line_index,
                             p_event_class_rec,
                             p_event_class_rec.rounding_level_hier_1_code,
                             p_tax_regime_code,
                             p_tax,
                             p_jurisdiction_code,
                             p_tax_determine_date,
                             p_rounding_rule_code,
                             p_return_status,
                             p_error_buffer);

    IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RETURN;
    ELSE
      IF p_rounding_rule_code IS NOT NULL THEN
        RETURN;
      END IF;
    END IF;
  END IF;

  IF p_event_class_rec.rounding_level_hier_2_code IS NOT NULL THEN

    determine_rounding_rule(
                             p_trx_line_index,
                             p_event_class_rec,
                             p_event_class_rec.rounding_level_hier_2_code,
                             p_tax_regime_code,
                             p_tax,
                             p_jurisdiction_code,
                             p_tax_determine_date,
                             p_rounding_rule_code,
                             p_return_status,
                             p_error_buffer);

    IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RETURN;
    ELSE
      IF p_rounding_rule_code IS NOT NULL THEN
        RETURN;
      END IF;
    END IF;
  END IF;

  IF p_event_class_rec.rounding_level_hier_3_code IS NOT NULL THEN

    determine_rounding_rule(
                             p_trx_line_index,
                             p_event_class_rec,
                             p_event_class_rec.rounding_level_hier_3_code,
                             p_tax_regime_code,
                             p_tax,
                             p_jurisdiction_code,
                             p_tax_determine_date,
                             p_rounding_rule_code,
                             p_return_status,
                             p_error_buffer);

    IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RETURN;
    ELSE
      IF p_rounding_rule_code IS NOT NULL THEN
        RETURN;
      END IF;
    END IF;
  END IF;

  IF p_event_class_rec.rounding_level_hier_4_code IS NOT NULL THEN

    determine_rounding_rule(
                             p_trx_line_index,
                             p_event_class_rec,
                             p_event_class_rec.rounding_level_hier_4_code,
                             p_tax_regime_code,
                             p_tax,
                             p_jurisdiction_code,
                             p_tax_determine_date,
                             p_rounding_rule_code,
                             p_return_status,
                             p_error_buffer);

    IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RETURN;
    ELSE
      IF p_rounding_rule_code IS NOT NULL THEN
        RETURN;
      END IF;
    END IF;
  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.get_rounding_rule.END',
                   'ZX_TDS_TAX_ROUNDING_PKG: get_rounding_rule(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.get_rounding_rule',
                      p_error_buffer);
    END IF;

END get_rounding_rule;

-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  get_round_level_ptp_id
--
--  DESCRIPTION
--
--  This procedure determines the party_tax_profile_id.
--
PROCEDURE get_round_level_ptp_id(
            p_Party_Type_Code      IN     VARCHAR2,
            p_event_class_rec      IN     ZX_API_PUB.EVENT_CLASS_REC_TYPE,
            p_tax_prof_id             OUT NOCOPY ZX_PARTY_TAX_PROFILE.PARTY_TAX_PROFILE_ID%TYPE,
            p_return_status           OUT NOCOPY  VARCHAR2,
            p_error_buffer            OUT NOCOPY  VARCHAR2
           )
IS
  l_tax_prof_name                  VARCHAR(30);
  l_rounding_level_basis           VARCHAR(8);

BEGIN

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.get_round_level_ptp_id.BEGIN',
                   'ZX_TDS_TAX_ROUNDING_PKG: get_round_level_ptp_id(+)');
  END IF;

  p_return_status :=  FND_API.G_RET_STS_SUCCESS;

  --
  -- determine the rounding party type
  --
  det_rounding_level_basis(
           p_Party_Type_Code,
           l_rounding_level_basis,
           p_return_status,
           p_error_buffer);

  IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RETURN;
  END IF;

  IF l_rounding_level_basis = 'PARTY' THEN
    l_tax_prof_name := 'RDNG' || '_'||p_Party_Type_Code ||'_'|| 'TX_PROF_ID';
  ELSE
    --
    -- party site
    --
    l_tax_prof_name := RTRIM(p_Party_Type_Code, 'SITE');
    l_tax_prof_name := 'RDNG' || '_' || l_tax_prof_name || 'TX_P_ST_ID';
  END IF;
  --
  -- get party/party_site tax_prof_id based on the name
  --
  IF l_tax_prof_name = 'RDNG_SHIP_TO_PTY_TX_PROF_ID' THEN
    p_tax_prof_id := p_event_class_rec.rdng_ship_to_pty_tx_prof_id;
  ELSIF l_tax_prof_name = 'RDNG_SHIP_FROM_PTY_TX_PROF_ID' THEN
    p_tax_prof_id := p_event_class_rec.rdng_ship_from_pty_tx_prof_id;
  ELSIF l_tax_prof_name = 'RDNG_BILL_TO_PTY_TX_PROF_ID' THEN
    p_tax_prof_id := p_event_class_rec.rdng_bill_to_pty_tx_prof_id;
  ELSIF l_tax_prof_name = 'RDNG_BILL_FROM_PTY_TX_PROF_ID' THEN
    p_tax_prof_id := p_event_class_rec.rdng_bill_from_pty_tx_prof_id;
  ELSIF l_tax_prof_name = 'RDNG_SHIP_TO_PTY_TX_P_ST_ID' THEN
    p_tax_prof_id := p_event_class_rec.rdng_ship_to_pty_tx_p_st_id;
  ELSIF l_tax_prof_name = 'RDNG_SHIP_FROM_PTY_TX_P_ST_ID' THEN
    p_tax_prof_id := p_event_class_rec.rdng_ship_from_pty_tx_p_st_id;
  ELSIF l_tax_prof_name = 'RDNG_BILL_TO_PTY_TX_P_ST_ID' THEN
    p_tax_prof_id := p_event_class_rec.rdng_bill_to_pty_tx_p_st_id;
  ELSIF l_tax_prof_name = 'RDNG_BILL_FROM_PTY_TX_P_ST_ID' THEN
    p_tax_prof_id := p_event_class_rec.rdng_bill_from_pty_tx_p_st_id;
  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.get_round_level_ptp_id.END',
                   'ZX_TDS_TAX_ROUNDING_PKG: get_round_level_ptp_id(-)'||
                   'p_tax_prof_id = ' || to_char(p_tax_prof_id));
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.get_round_level_ptp_id',
                      p_error_buffer);
    END IF;

END get_round_level_ptp_id;

-----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  get_rounding_level_and_rule
--
--  DESCRIPTION
--
--  This procedure determines the rounding level for a whole document
--  and the rounding_rule based on rounding party hierarchy
--

PROCEDURE get_rounding_level_and_rule(
           p_event_class_rec      IN      ZX_API_PUB.EVENT_CLASS_REC_TYPE,
           p_rounding_level_code     OUT NOCOPY  ZX_PARTY_TAX_PROFILE.ROUNDING_LEVEL_CODE%TYPE,
           p_rounding_rule_code      OUT NOCOPY  ZX_PARTY_TAX_PROFILE.ROUNDING_RULE_CODE%TYPE,
           p_rnd_lvl_party_tax_prof_id
                         OUT NOCOPY ZX_LINES.ROUNDING_LVL_PARTY_TAX_PROF_ID%TYPE,
           p_rounding_lvl_party_type OUT NOCOPY  ZX_LINES.ROUNDING_LVL_PARTY_TYPE%TYPE,
           p_return_status           OUT NOCOPY  VARCHAR2,
           p_error_buffer            OUT NOCOPY  VARCHAR2
         )
IS
  l_tax_prof_id           ZX_PARTY_TAX_PROFILE.PARTY_TAX_PROFILE_ID%TYPE;
  l_rounding_level_code   ZX_PARTY_TAX_PROFILE.ROUNDING_LEVEL_CODE%TYPE;
  l_rounding_rule_code    ZX_PARTY_TAX_PROFILE.ROUNDING_RULE_CODE%TYPE;
  l_rounding_level_found  BOOLEAN;
  l_rounding_rule_found   BOOLEAN;


    CURSOR  get_acct_site_info_csr IS
   SELECT /*+ INDEX ( HEADER ZX_TRX_HEADERS_GT_U1 ) INDEX ( TRXLINES ZX_TRANSACTION_LINES_GT_U1 ) */
          NVL(trxlines.ship_third_pty_acct_id,
              header.ship_third_pty_acct_id) ship_third_pty_acct_id,
          NVL(trxlines.bill_third_pty_acct_id,
              header.bill_third_pty_acct_id) bill_third_pty_acct_id,
          NVL(trxlines.ship_third_pty_acct_site_id,
              header.ship_third_pty_acct_site_id) ship_third_pty_acct_site_id,
          NVL(trxlines.bill_third_pty_acct_site_id,
              header.bill_third_pty_acct_site_id) bill_third_pty_acct_site_id,
          NVL(trxlines.ship_to_cust_acct_site_use_id,
              header.ship_to_cust_acct_site_use_id) ship_to_cust_acct_site_use_id,
          NVL(trxlines.bill_to_cust_acct_site_use_id,
              header.bill_to_cust_acct_site_use_id) bill_to_cust_acct_site_use_id,
          NVL(header.related_doc_date, NVL(header.provnl_tax_determination_date,
              NVL(trxlines.adjusted_doc_date,
                  NVL(trxlines.trx_line_date, header.trx_date)))) tax_determine_date
     FROM ZX_TRANSACTION_LINES_GT trxlines, ZX_TRX_HEADERS_GT header
    WHERE header.application_id = p_event_class_rec.application_id
      AND header.entity_code = p_event_class_rec.entity_code
      AND header.event_class_code = p_event_class_rec.event_class_code
      AND header.trx_id = p_event_class_rec.trx_id
      AND trxlines.application_id = header.application_id
      AND trxlines.entity_code = header.entity_code
      AND trxlines.event_class_code = header.event_class_code
      AND trxlines.trx_id = header.trx_id
      AND rownum = 1;

--Bug 5103375
    CURSOR get_lines_det_factors  IS
    select SHIP_THIRD_PTY_ACCT_ID,
           BILL_THIRD_PTY_ACCT_ID,
           SHIP_THIRD_PTY_ACCT_SITE_ID,
           BILL_THIRD_PTY_ACCT_SITE_ID,
           SHIP_TO_CUST_ACCT_SITE_USE_ID,
           BILL_TO_CUST_ACCT_SITE_USE_ID,
	   coalesce(related_doc_date,
	            provnl_tax_determination_date,
		    adjusted_doc_date,
		    trx_line_date,
		    trx_date) tax_determine_date
      FROM ZX_LINES_DET_FACTORS
     WHERE application_id = p_event_class_rec.application_id
	   AND entity_code = p_event_class_rec.entity_code
	   AND event_class_code = p_event_class_rec.event_class_code
	   AND trx_id = p_event_class_rec.trx_id
           AND ROWNUM = 1 ;

  l_ship_third_pty_acct_id              NUMBER;
  l_bill_third_pty_acct_id              NUMBER;
  l_ship_third_pty_acct_site_id         NUMBER;
  l_bill_third_pty_acct_site_id         NUMBER;
  l_ship_to_cust_acct_st_use_id         NUMBER;
  l_bill_to_cust_acct_st_use_id         NUMBER;
  l_tax_determine_date                  DATE;
  l_tax_date                            DATE;
  l_tax_point_date                      DATE;


BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.get_rounding_level_and_rule.BEGIN',
                   'ZX_TDS_TAX_ROUNDING_PKG: get_rounding_level_and_rule(+)');

  END IF;

  p_return_status :=  FND_API.G_RET_STS_SUCCESS;

  --
  -- check if trx_currency_code is available at header level
  -- if not, that means trx_currency_code can be different
  -- accross transaction lines, in this case, just set
  -- rounding level to 'LINE' and don't get rounding rule
  --

  IF p_event_class_rec.header_level_currency_flag IS NULL THEN
    p_rounding_level_code := 'LINE';
    p_rounding_rule_code := NULL;

    IF p_event_class_rec.rounding_level_hier_1_code IS NOT NULL THEN

      get_round_level_ptp_id(
          p_event_class_rec.rounding_level_hier_1_code,
          p_event_class_rec,
          l_tax_prof_id,
          p_return_status,
          p_error_buffer);

      IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RETURN;
      ELSE
        IF l_tax_prof_id IS NOT NULL THEN
          p_rnd_lvl_party_tax_prof_id := l_tax_prof_id;
          p_rounding_lvl_party_type := p_event_class_rec.rounding_level_hier_1_code;

          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.get_rounding_level_and_rule',
                 'from rounding_level_hier_1_code p_rnd_lvl_party_tax_prof_id: '||
                 p_rnd_lvl_party_tax_prof_id ||' p_rounding_lvl_party_type: '||
                 p_rounding_lvl_party_type );
          END IF;
          RETURN;
        END IF;
      END IF;
    END IF;

    IF p_event_class_rec.rounding_level_hier_2_code IS NOT NULL THEN


      get_round_level_ptp_id(
          p_event_class_rec.rounding_level_hier_2_code,
          p_event_class_rec,
          l_tax_prof_id,
          p_return_status,
          p_error_buffer);

      IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RETURN;
      ELSE
        IF l_tax_prof_id IS NOT NULL THEN
          p_rnd_lvl_party_tax_prof_id := l_tax_prof_id;
          p_rounding_lvl_party_type := p_event_class_rec.rounding_level_hier_2_code;

          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.get_rounding_level_and_rule',
                 'from rounding_level_hier_2_code p_rnd_lvl_party_tax_prof_id: '||
                 p_rnd_lvl_party_tax_prof_id ||' p_rounding_lvl_party_type: '||
                 p_rounding_lvl_party_type );
          END IF;
          RETURN;
        END IF;
      END IF;
    END IF;

    IF p_event_class_rec.rounding_level_hier_3_code IS NOT NULL THEN

      get_round_level_ptp_id(
          p_event_class_rec.rounding_level_hier_3_code,
          p_event_class_rec,
          l_tax_prof_id,
          p_return_status,
          p_error_buffer);

      IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RETURN;
      ELSE
        IF l_tax_prof_id IS NOT NULL THEN
          p_rnd_lvl_party_tax_prof_id := l_tax_prof_id;
          p_rounding_lvl_party_type := p_event_class_rec.rounding_level_hier_3_code;

          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.get_rounding_level_and_rule',
                 'from rounding_level_hier_3_code p_rnd_lvl_party_tax_prof_id: '||
                 p_rnd_lvl_party_tax_prof_id ||' p_rounding_lvl_party_type: '||
                 p_rounding_lvl_party_type );
          END IF;
          RETURN;
        END IF;
      END IF;
    END IF;

    IF p_event_class_rec.rounding_level_hier_4_code IS NOT NULL THEN

      get_round_level_ptp_id(
          p_event_class_rec.rounding_level_hier_4_code,
          p_event_class_rec,
          l_tax_prof_id,
          p_return_status,
          p_error_buffer);

      IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RETURN;
      ELSE
        IF l_tax_prof_id IS NOT NULL THEN
          p_rnd_lvl_party_tax_prof_id := l_tax_prof_id;
          p_rounding_lvl_party_type := p_event_class_rec.rounding_level_hier_4_code;

          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.get_rounding_level_and_rule',
                 'from rounding_level_hier_4_code p_rnd_lvl_party_tax_prof_id: '||
                 p_rnd_lvl_party_tax_prof_id ||' p_rounding_lvl_party_type: '||
                 p_rounding_lvl_party_type );
          END IF;
          RETURN;
        END IF;
      END IF;
    END IF;

  END IF;

  --
  -- trx_currency_code is the same accross transaction
  -- lines, get the rounding level and rule
  --

  l_rounding_level_code  := NULL;
  l_rounding_rule_code   := NULL;

  l_rounding_level_found := FALSE;
  l_rounding_rule_found  := FALSE;

    -- determine account, account_site, account_site_use information
    -- from first transaction line
    --
    IF ZX_API_PUB.G_DATA_TRANSFER_MODE = 'TAB' THEN
      OPEN  get_acct_site_info_csr;
      FETCH get_acct_site_info_csr INTO
             l_ship_third_pty_acct_id, l_bill_third_pty_acct_id,
             l_ship_third_pty_acct_site_id, l_bill_third_pty_acct_site_id,
             l_ship_to_cust_acct_st_use_id, l_bill_to_cust_acct_st_use_id,
             l_tax_determine_date;
      CLOSE get_acct_site_info_csr;
    ELSE

      IF ( ZX_API_PUB.G_DATA_TRANSFER_MODE = 'WIN' ) THEN  --Bug 5103375
         OPEN get_lines_det_factors;
	 FETCH get_lines_det_factors INTO
	     l_ship_third_pty_acct_id, l_bill_third_pty_acct_id,
             l_ship_third_pty_acct_site_id, l_bill_third_pty_acct_site_id,
             l_ship_to_cust_acct_st_use_id, l_bill_to_cust_acct_st_use_id,
             l_tax_determine_date;
	 CLOSE get_lines_det_factors ;

      ELSE --PLS --Bug 5103375

			      FOR i IN ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.application_id.FIRST ..
				       ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.application_id.LAST
			      LOOP

				IF p_event_class_rec.application_id =
				       ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.application_id(i) AND
				   p_event_class_rec.entity_code =
					  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.entity_code(i) AND
				   p_event_class_rec.event_class_code =
				     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.event_class_code(i) AND
				   p_event_class_rec.trx_id =
					       ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_id(i)
				THEN

				  l_ship_third_pty_acct_id :=
				    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ship_third_pty_acct_id(i);
				  l_bill_third_pty_acct_id :=
				    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.bill_third_pty_acct_id(i);
				  l_ship_third_pty_acct_site_id :=
				    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ship_third_pty_acct_site_id(i);
				  l_bill_third_pty_acct_site_id :=
				    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.bill_third_pty_acct_site_id(i);
				  l_ship_to_cust_acct_st_use_id :=
				    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ship_to_cust_acct_site_use_id(i);
				  l_bill_to_cust_acct_st_use_id :=
				    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.bill_to_cust_acct_site_use_id(i);

				  ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_date(
					i,
					l_tax_date,
					l_tax_determine_date,
					l_tax_point_date,
					p_return_status);

				  IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
				    IF (g_level_error >= g_current_runtime_level ) THEN
				      FND_LOG.STRING(g_level_error,
					     'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.get_rounding_level_and_rule',
					     'Incorrect return_status after calling ' ||
					     'ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_date()');
				      FND_LOG.STRING(g_level_error,
					     'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.get_rounding_level_and_rule',
					     'RETURN_STATUS = ' || p_return_status);
				      FND_LOG.STRING(g_level_error,
					     'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.get_rounding_level_and_rule.END',
					     'ZX_TDS_TAX_ROUNDING_PKG.get_rounding_level_and_rule(-)');
				    END IF;
				    RETURN;
				  END IF;

				  EXIT;
				END IF;
			      END LOOP;
	END IF ; -- PLSQL Version
    END IF;


  IF p_event_class_rec.rounding_level_hier_1_code IS NOT NULL THEN

    determine_round_level_and_rule(
                             p_event_class_rec.rounding_level_hier_1_code,
                             p_event_class_rec,
                             l_tax_prof_id,
                             l_rounding_level_code,
                             l_rounding_rule_code,
                             p_return_status,
                             p_error_buffer,
                             l_ship_third_pty_acct_id,
                             l_bill_third_pty_acct_id,
                             l_ship_third_pty_acct_site_id,
                             l_bill_third_pty_acct_site_id,
                             l_ship_to_cust_acct_st_use_id,
                             l_bill_to_cust_acct_st_use_id,
                             l_tax_determine_date );

    IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RETURN;
    ELSE
      IF l_rounding_level_code IS NOT NULL THEN
        p_rnd_lvl_party_tax_prof_id := l_tax_prof_id;
        p_rounding_lvl_party_type := p_event_class_rec.rounding_level_hier_1_code;
        p_rounding_level_code := l_rounding_level_code;
        l_rounding_level_found := TRUE;
      END IF;
      IF l_rounding_rule_code IS NOT NULL THEN
        p_rounding_rule_code := l_rounding_rule_code;
        l_rounding_rule_found := TRUE;
      END IF;
      IF l_rounding_level_found AND l_rounding_rule_found THEN
        RETURN;
      END IF;
    END IF;
  END IF;

  IF p_event_class_rec.rounding_level_hier_2_code IS NOT NULL THEN

    determine_round_level_and_rule(
                             p_event_class_rec.rounding_level_hier_2_code,
                             p_event_class_rec,
                             l_tax_prof_id,
                             l_rounding_level_code,
                             l_rounding_rule_code,
                             p_return_status,
                             p_error_buffer,
                             l_ship_third_pty_acct_id,
                             l_bill_third_pty_acct_id,
                             l_ship_third_pty_acct_site_id,
                             l_bill_third_pty_acct_site_id,
                             l_ship_to_cust_acct_st_use_id,
                             l_bill_to_cust_acct_st_use_id,
                             l_tax_determine_date );

    IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RETURN;
    ELSE
      IF (NOT l_rounding_level_found AND
          l_rounding_level_code IS NOT NULL) THEN
       p_rnd_lvl_party_tax_prof_id := l_tax_prof_id;
       p_rounding_lvl_party_type := p_event_class_rec.rounding_level_hier_2_code;
       p_rounding_level_code := l_rounding_level_code;
       l_rounding_level_found := TRUE;
      END IF;
      IF (NOT l_rounding_rule_found AND
          l_rounding_rule_code IS NOT NULL) THEN
        p_rounding_rule_code := l_rounding_rule_code;
        l_rounding_rule_found := TRUE;
      END IF;
      IF l_rounding_level_found AND l_rounding_rule_found THEN
        RETURN;
      END IF;
    END IF;
  END IF;

  IF p_event_class_rec.rounding_level_hier_3_code IS NOT NULL THEN

    determine_round_level_and_rule(
                             p_event_class_rec.rounding_level_hier_3_code,
                             p_event_class_rec,
                             l_tax_prof_id,
                             l_rounding_level_code,
                             l_rounding_rule_code,
                             p_return_status,
                             p_error_buffer,
                             l_ship_third_pty_acct_id,
                             l_bill_third_pty_acct_id,
                             l_ship_third_pty_acct_site_id,
                             l_bill_third_pty_acct_site_id,
                             l_ship_to_cust_acct_st_use_id,
                             l_bill_to_cust_acct_st_use_id,
                             l_tax_determine_date );

    IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RETURN;
    ELSE
      IF (NOT l_rounding_level_found  AND
          l_rounding_level_code IS NOT NULL) THEN
        p_rnd_lvl_party_tax_prof_id := l_tax_prof_id;
        p_rounding_lvl_party_type := p_event_class_rec.rounding_level_hier_3_code;
        p_rounding_level_code := l_rounding_level_code;
        l_rounding_level_found := TRUE;
      END IF;
      IF (NOT l_rounding_rule_found AND
          l_rounding_rule_code IS NOT NULL) THEN
        p_rounding_rule_code := l_rounding_rule_code;
        l_rounding_rule_found := TRUE;
      END IF;
      IF l_rounding_level_found AND l_rounding_rule_found THEN
        RETURN;
      END IF;
    END IF;
  END IF;

  IF p_event_class_rec.rounding_level_hier_4_code IS NOT NULL THEN

    determine_round_level_and_rule(
                             p_event_class_rec.rounding_level_hier_4_code,
                             p_event_class_rec,
                             l_tax_prof_id,
                             l_rounding_level_code,
                             l_rounding_rule_code,
                             p_return_status,
                             p_error_buffer,
                             l_ship_third_pty_acct_id,
                             l_bill_third_pty_acct_id,
                             l_ship_third_pty_acct_site_id,
                             l_bill_third_pty_acct_site_id,
                             l_ship_to_cust_acct_st_use_id,
                             l_bill_to_cust_acct_st_use_id,
                             l_tax_determine_date );

    IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RETURN;
    ELSE
      IF (NOT l_rounding_level_found AND
          l_rounding_level_code IS NOT NULL) THEN
        p_rnd_lvl_party_tax_prof_id := l_tax_prof_id;
        p_rounding_lvl_party_type := p_event_class_rec.rounding_level_hier_4_code;
        p_rounding_level_code := l_rounding_level_code;
        l_rounding_level_found := TRUE;
      END IF;
      IF (NOT l_rounding_rule_found AND
          l_rounding_rule_code IS NOT NULL) THEN
        p_rounding_rule_code := l_rounding_rule_code;
        l_rounding_rule_found := TRUE;
      END IF;
      IF l_rounding_level_found AND l_rounding_rule_found THEN
        RETURN;
      END IF;
    END IF;
  END IF;

  --
  -- get default rounding level from event class record
  --

  IF NOT l_rounding_level_found THEN
    p_rounding_level_code := p_event_class_rec.Default_Rounding_Level_Code;
    IF (g_level_procedure >= g_current_runtime_level ) THEN
    	FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.get_rounding_level_and_rule',
                   'get default rounding level from event class record '||p_rounding_level_code);
    END IF;
  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.get_rounding_level_and_rule.END',
                   'ZX_TDS_TAX_ROUNDING_PKG: get_rounding_level_and_rule(-)'||'rounding level code :'||p_rounding_level_code);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.get_rounding_level_and_rule',
                      p_error_buffer);
    END IF;

END get_rounding_level_and_rule;

-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  init_header_group
--
--  DESCRIPTION
--  This procedure initializes the values belonged to a group used by
--  header level rounding
--

PROCEDURE  init_header_group(
             p_hdr_grp_rec       OUT NOCOPY HDR_GRP_REC_TYPE,
             p_return_status     OUT NOCOPY VARCHAR2,
             p_error_buffer      OUT NOCOPY VARCHAR2
         )
IS

BEGIN

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.init_header_group.BEGIN',
                   'ZX_TDS_TAX_ROUNDING_PKG: init_header_group(+)');
  END IF;

  p_return_status  := FND_API.G_RET_STS_SUCCESS;

  p_hdr_grp_rec.tax_regime_code               := 'X';
  p_hdr_grp_rec.tax                           := 'X';
  p_hdr_grp_rec.tax_status_code               := 'X';
  p_hdr_grp_rec.tax_rate_code                 := 'X';
  p_hdr_grp_rec.tax_rate                      := -999;
  p_hdr_grp_rec.tax_rate_id                   := -999;
  p_hdr_grp_rec.tax_jurisdiction_code         := 'X';
  p_hdr_grp_rec.taxable_basis_formula         := 'X';
  p_hdr_grp_rec.tax_calculation_formula       := 'X';
  p_hdr_grp_rec.Tax_Amt_Included_Flag         := 'X';
  p_hdr_grp_rec.compounding_tax_flag          := 'X';
  p_hdr_grp_rec.historical_flag               := 'X';
  p_hdr_grp_rec.self_assessed_flag            := 'X';
  p_hdr_grp_rec.overridden_flag               := 'X';
  p_hdr_grp_rec.manually_entered_flag         := 'X';
  p_hdr_grp_rec.Copied_From_Other_Doc_Flag    := 'X';
  p_hdr_grp_rec.associated_child_frozen_flag  := 'X';
  p_hdr_grp_rec.tax_only_line_flag            := 'X';
  p_hdr_grp_rec.mrc_tax_line_flag             := 'X';
  p_hdr_grp_rec.reporting_only_flag           := 'X';
  p_hdr_grp_rec.applied_from_application_id   := -999;
  p_hdr_grp_rec.applied_from_event_class_code := 'X';
  p_hdr_grp_rec.applied_from_entity_code      := 'X';
  p_hdr_grp_rec.applied_from_trx_id           := -999;
  p_hdr_grp_rec.applied_from_line_id          := -999;
  p_hdr_grp_rec.adjusted_doc_application_id   := -999;
  p_hdr_grp_rec.adjusted_doc_entity_code      := 'X';
  p_hdr_grp_rec.adjusted_doc_event_class_code := 'X';
  p_hdr_grp_rec.adjusted_doc_trx_id           := -999;
  -- bug6773534 p_hdr_grp_rec.applied_to_application_id     := -999;
  -- bug6773534 p_hdr_grp_rec.applied_to_event_class_code   := 'X';
  -- bug6773534 p_hdr_grp_rec.applied_to_entity_code        := 'X';
  -- bug6773534 p_hdr_grp_rec.applied_to_trx_id             := -999;
  -- bug6773534 p_hdr_grp_rec.applied_to_line_id            := -999;
  p_hdr_grp_rec.tax_exemption_id              := -999;
  p_hdr_grp_rec.tax_rate_before_exemption     := -999;
  p_hdr_grp_rec.tax_rate_name_before_exemption := 'X';
  p_hdr_grp_rec.exempt_rate_modifier          := -999;
  p_hdr_grp_rec.exempt_certificate_number     := 'X';
  p_hdr_grp_rec.exempt_reason                 := 'X';
  p_hdr_grp_rec.exempt_reason_code            := 'X';
  p_hdr_grp_rec.tax_exception_id              := -999;
  p_hdr_grp_rec.tax_rate_before_exception     := -999;
  p_hdr_grp_rec.tax_rate_name_before_exception := 'X';
  p_hdr_grp_rec.exception_rate                := -999;
  p_hdr_grp_rec.ledger_id                     := -999;
  p_hdr_grp_rec.legal_entity_id               := -999;
  p_hdr_grp_rec.establishment_id              := -999;
  p_hdr_grp_rec.currency_conversion_date      := SYSDATE;
  p_hdr_grp_rec.currency_conversion_type      := 'X';
  p_hdr_grp_rec.currency_conversion_rate      := -999;
  p_hdr_grp_rec.record_type_code              := 'X';

  IF (g_level_procedure >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.init_header_group.END',
                   'ZX_TDS_TAX_ROUNDING_PKG: init_header_group(-)'||p_return_status);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.init_header_group ',
                      p_error_buffer);
    END IF;

END init_header_group;
-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  determine_header_group
--
--  DESCRIPTION
--  This procedure determines if the current grouping criterias belong to
--  the same header rounding group or not
--

PROCEDURE  determine_header_group(
             p_prev_hdr_grp_rec         IN            HDR_GRP_REC_TYPE,
             p_curr_hdr_grp_rec         IN            HDR_GRP_REC_TYPE,
             p_same_tax                    OUT NOCOPY VARCHAR2,
             p_return_status               OUT NOCOPY VARCHAR2,
             p_error_buffer                OUT NOCOPY VARCHAR2
         )
IS

BEGIN

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.determine_header_group.BEGIN',
                   'ZX_TDS_TAX_ROUNDING_PKG: determine_header_group(+)');
  END IF;

  p_return_status  := FND_API.G_RET_STS_SUCCESS;

  -- bug6773534: remove applied_to information from header grouping critera

  IF (NVL(p_prev_hdr_grp_rec.tax_regime_code, 'X')              <>
                     NVL(p_curr_hdr_grp_rec.tax_regime_code , 'X')OR
      NVL(p_prev_hdr_grp_rec.tax, 'X')                          <>
                     NVL(p_curr_hdr_grp_rec.tax, 'X') OR
      NVL(p_prev_hdr_grp_rec.tax_status_code, 'X')              <>
                     NVL(p_curr_hdr_grp_rec.tax_status_code, 'X') OR
      NVL(p_prev_hdr_grp_rec.tax_rate_code, 'X')                <>
                     NVL(p_curr_hdr_grp_rec.tax_rate_code, 'X') OR
      NVL(p_prev_hdr_grp_rec.tax_rate, -999)                     <>
                     NVL(p_curr_hdr_grp_rec.tax_rate, -999)  OR
      NVL(p_prev_hdr_grp_rec.tax_rate_id, -999)                     <>
                     NVL(p_curr_hdr_grp_rec.tax_rate_id, -999)  OR
      NVL(p_prev_hdr_grp_rec.tax_jurisdiction_code, 'X')                     <>
                     NVL(p_curr_hdr_grp_rec.tax_jurisdiction_code, 'X')  OR
      NVL(p_prev_hdr_grp_rec.taxable_basis_formula, 'X')        <>
                     NVL(p_curr_hdr_grp_rec.taxable_basis_formula, 'X')  OR
      NVL(p_prev_hdr_grp_rec.tax_calculation_formula, 'X')      <>
                     NVL(p_curr_hdr_grp_rec.tax_calculation_formula, 'X') OR
      NVL(p_prev_hdr_grp_rec.Tax_Amt_Included_Flag,'X')   <>
                     NVL(p_curr_hdr_grp_rec.Tax_Amt_Included_Flag,'X') OR
      NVL(p_prev_hdr_grp_rec.compounding_tax_flag,'X')    <>
                     NVL(p_curr_hdr_grp_rec.compounding_tax_flag,'X')  OR
      NVL(p_prev_hdr_grp_rec.historical_flag,'X')              <>
                     NVL(p_curr_hdr_grp_rec.historical_flag,'X')  OR
      NVL(p_prev_hdr_grp_rec.self_assessed_flag,'X')           <>
                     NVL(p_curr_hdr_grp_rec.self_assessed_flag,'X')  OR
   -- NVL(p_prev_hdr_grp_rec.overridden_flag,'X')              <>
   --                  NVL(p_curr_hdr_grp_rec.overridden_flag,'X')  OR
      NVL(p_prev_hdr_grp_rec.manually_entered_flag,'X')        <>
                     NVL(p_curr_hdr_grp_rec.manually_entered_flag,'X')  OR
      --NVL(p_prev_hdr_grp_rec.Copied_From_Other_Doc_Flag,'X')     <>
       --              NVL(p_curr_hdr_grp_rec.Copied_From_Other_Doc_Flag,'X')  OR
      --NVL(p_prev_hdr_grp_rec.associated_child_frozen_flag,'X') <>
      --               NVL(p_curr_hdr_grp_rec.associated_child_frozen_flag,'X')  OR
      NVL(p_prev_hdr_grp_rec.tax_only_line_flag,'X')        <>
                     NVL(p_curr_hdr_grp_rec.tax_only_line_flag,'X')   OR
      NVL(p_prev_hdr_grp_rec.mrc_tax_line_flag,'X')  <>
                     NVL(p_curr_hdr_grp_rec.mrc_tax_line_flag,'X') OR
      NVL(p_prev_hdr_grp_rec.reporting_only_flag,'X')  <>
                     NVL(p_curr_hdr_grp_rec.reporting_only_flag,'X')  OR
      NVL(p_prev_hdr_grp_rec.applied_from_application_id, -999)        <>
                     NVL(p_curr_hdr_grp_rec.applied_from_application_id, -999)    OR
      NVL(p_prev_hdr_grp_rec.applied_from_event_class_code, 'X')        <>
                     NVL(p_curr_hdr_grp_rec.applied_from_event_class_code, 'X')    OR
      NVL(p_prev_hdr_grp_rec.applied_from_entity_code, 'X')        <>
                     NVL(p_curr_hdr_grp_rec.applied_from_entity_code, 'X')    OR
      NVL(p_prev_hdr_grp_rec.applied_from_trx_id, -999)        <>
                     NVL(p_curr_hdr_grp_rec.applied_from_trx_id, -999)    OR
      NVL(p_prev_hdr_grp_rec.applied_from_line_id, -999)        <>
                     NVL(p_curr_hdr_grp_rec.applied_from_line_id, -999)    OR
      NVL(p_prev_hdr_grp_rec.adjusted_doc_application_id, -999)      <>
                     NVL(p_curr_hdr_grp_rec.adjusted_doc_application_id, -999)    OR
      NVL(p_prev_hdr_grp_rec.adjusted_doc_entity_code, 'X')      <>
                     NVL(p_curr_hdr_grp_rec.adjusted_doc_entity_code, 'X')    OR
      NVL(p_prev_hdr_grp_rec.adjusted_doc_event_class_code, 'X')      <>
                     NVL(p_curr_hdr_grp_rec.adjusted_doc_event_class_code, 'X')    OR
      NVL(p_prev_hdr_grp_rec.adjusted_doc_trx_id, -999)      <>
                     NVL(p_curr_hdr_grp_rec.adjusted_doc_trx_id, -999)    OR
      --  NVL(p_prev_hdr_grp_rec.applied_to_application_id, -999)      <>
      --  NVL(p_curr_hdr_grp_rec.applied_to_application_id, -999)    OR
      -- NVL(p_prev_hdr_grp_rec.applied_to_event_class_code, 'X')      <>
      --                NVL(p_curr_hdr_grp_rec.applied_to_event_class_code, 'X')    OR
      -- NVL(p_prev_hdr_grp_rec.applied_to_entity_code, 'X')      <>
      --                NVL(p_curr_hdr_grp_rec.applied_to_entity_code, 'X')    OR
      -- NVL(p_prev_hdr_grp_rec.applied_to_trx_id, -999)      <>
      --                NVL(p_curr_hdr_grp_rec.applied_to_trx_id, -999)    OR
      -- NVL(p_prev_hdr_grp_rec.applied_to_line_id, -999)      <>
      --                NVL(p_curr_hdr_grp_rec.applied_to_line_id, -999)    OR
      NVL(p_prev_hdr_grp_rec.tax_exemption_id, -999)      <>
                     NVL(p_curr_hdr_grp_rec.tax_exemption_id, -999)    OR
    --  NVL(p_prev_hdr_grp_rec.tax_rate_before_exemption, -999)      <>
    --                 NVL(p_curr_hdr_grp_rec.tax_rate_before_exemption, -999)    OR
    --  NVL(p_prev_hdr_grp_rec.tax_rate_name_before_exemption, 'X')      <>
   --                  NVL(p_curr_hdr_grp_rec.tax_rate_name_before_exemption, 'X')    OR
  --    NVL(p_prev_hdr_grp_rec.exempt_rate_modifier, -999)      <>
  --                   NVL(p_curr_hdr_grp_rec.exempt_rate_modifier, -999)    OR
      NVL(p_prev_hdr_grp_rec.exempt_certificate_number, 'X')      <>
                     NVL(p_curr_hdr_grp_rec.exempt_certificate_number, 'X')    OR
 --     NVL(p_prev_hdr_grp_rec.exempt_reason, 'X')      <>
 --                    NVL(p_curr_hdr_grp_rec.exempt_reason, 'X')    OR
      NVL(p_prev_hdr_grp_rec.exempt_reason_code, 'X')      <>
                     NVL(p_curr_hdr_grp_rec.exempt_reason_code, 'X')    OR
      NVL(p_prev_hdr_grp_rec.tax_exception_id, -999)      <>
                     NVL(p_curr_hdr_grp_rec.tax_exception_id, -999)    OR
 --   NVL(p_prev_hdr_grp_rec.tax_rate_before_exception, -999)      <>
 --                    NVL(p_curr_hdr_grp_rec.tax_rate_before_exception, -999)    OR
 --     NVL(p_prev_hdr_grp_rec.tax_rate_name_before_exception, 'X')      <>
 --                    NVL(p_curr_hdr_grp_rec.tax_rate_name_before_exception, 'X')    OR
 --     NVL(p_prev_hdr_grp_rec.exception_rate, -999) <>
 --                    NVL(p_curr_hdr_grp_rec.exception_rate, -999) OR
      NVL(p_prev_hdr_grp_rec.ledger_id, -999)   <>
                     NVL(p_curr_hdr_grp_rec.ledger_id, -999) OR
      NVL(p_prev_hdr_grp_rec.legal_entity_id, -999)   <>
                     NVL(p_curr_hdr_grp_rec.legal_entity_id, -999) OR
      NVL(p_prev_hdr_grp_rec.establishment_id, -999)   <>
                     NVL(p_curr_hdr_grp_rec.establishment_id, -999) OR
      TRUNC(NVL(p_prev_hdr_grp_rec.currency_conversion_date, SYSDATE ) ) <>
                     TRUNC(NVL(p_curr_hdr_grp_rec.currency_conversion_date, SYSDATE )) OR
      NVL(p_prev_hdr_grp_rec.currency_conversion_type, 'X')  <>
                     NVL(p_curr_hdr_grp_rec.currency_conversion_type, 'X')  OR
      NVL(p_prev_hdr_grp_rec.currency_conversion_rate, -999)   <>
                     NVL(p_curr_hdr_grp_rec.currency_conversion_rate, -999) OR
      NVL(p_prev_hdr_grp_rec.record_type_code,'X')   <>
                     NVL(p_curr_hdr_grp_rec.record_type_code,'X')
   )   THEN
    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.determine_header_group',
                     ' SAME tax N');
   END IF;
    p_same_tax := 'N';
  ELSE
    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.determine_header_group',
                     ' SAME tax Y');
   END IF;
    p_same_tax := 'Y';
  END IF;

  IF p_same_tax = 'N' THEN
    --
    -- this is a new header group
    --

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.determine_header_group',
                     ' New header rounding group '||
                     'tax_regime_code = ' || p_curr_hdr_grp_rec.tax_regime_code||
                     'tax = ' || p_curr_hdr_grp_rec.tax||
                     'tax_status_code = ' || p_curr_hdr_grp_rec.tax_status_code||
                     'tax_rate_code = ' || p_curr_hdr_grp_rec.tax_rate_code||
                     'tax_rate = ' || to_char(p_curr_hdr_grp_rec.tax_rate)||
                     'tax_rate_id = ' || to_char(p_curr_hdr_grp_rec.tax_rate_id)||
                     'tax_jurisdiction_code = ' ||
                     p_curr_hdr_grp_rec.tax_jurisdiction_code||
                     'taxable_basis_formula = ' ||
                     p_curr_hdr_grp_rec.taxable_basis_formula||
                     'tax_calculation_formula = ' ||
                     p_curr_hdr_grp_rec.tax_calculation_formula||
                     'Tax_Amt_Included_Flag = ' ||
                     p_curr_hdr_grp_rec.Tax_Amt_Included_Flag||
                     'compounding_tax_flag = ' ||
                     p_curr_hdr_grp_rec.compounding_tax_flag ||
                     'historical_flag = ' || p_curr_hdr_grp_rec.historical_flag ||
                     'self_assessed_flag = ' ||
                     p_curr_hdr_grp_rec.self_assessed_flag||
                     'overridden_flag = ' || p_curr_hdr_grp_rec.overridden_flag ||
                     'manually_entered_flag = ' ||
                     p_curr_hdr_grp_rec.manually_entered_flag ||
                     'Copied_From_Other_Doc_Flag = ' ||
                     p_curr_hdr_grp_rec.Copied_From_Other_Doc_Flag||
                     'associated_child_frozen_flag = ' ||
                      p_curr_hdr_grp_rec.associated_child_frozen_flag ||
                     'tax_only_line_flag = ' ||
                     p_curr_hdr_grp_rec.tax_only_line_flag||
                     'mrc_tax_line_flag = ' ||
                     p_curr_hdr_grp_rec.mrc_tax_line_flag||
                     'reporting_only_flag = ' ||
                     p_curr_hdr_grp_rec.reporting_only_flag||
                     'applied_from_application_id        = ' ||
                     to_char(p_curr_hdr_grp_rec.applied_from_application_id ) ||
                     'applied_from_event_class_code        = ' ||
                     p_curr_hdr_grp_rec.applied_from_event_class_code  ||
                     'applied_from_entity_code        = ' ||
                     p_curr_hdr_grp_rec.applied_from_entity_code  ||
                     'applied_from_trx_id        = ' ||
                     to_char(p_curr_hdr_grp_rec.applied_from_trx_id  ) ||
                     'applied_from_line_id = ' ||
                     to_char(p_curr_hdr_grp_rec.applied_from_line_id  ) ||
                     'adjusted_doc_application_id  = ' ||
                     to_char(p_curr_hdr_grp_rec.adjusted_doc_application_id )  ||
                     'adjusted_doc_entity_code  = ' ||
                     p_curr_hdr_grp_rec.adjusted_doc_entity_code   ||
                     'adjusted_doc_event_class_code      = ' ||
                     p_curr_hdr_grp_rec.adjusted_doc_event_class_code ||
                     'adjusted_doc_trx_id = ' ||
                     to_char(p_curr_hdr_grp_rec.adjusted_doc_trx_id   ) );

      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.determine_header_group',
                     'tax_exemption_id = ' ||
                     to_char(p_curr_hdr_grp_rec.tax_exemption_id ) ||
                     'tax_rate_before_exemption = ' ||
                     to_char(p_curr_hdr_grp_rec.tax_rate_before_exemption  )||
                     'tax_rate_name_before_exemption = ' ||
                     p_curr_hdr_grp_rec.tax_rate_name_before_exemption ||
                     'exempt_rate_modifier = ' ||
                     to_char(p_curr_hdr_grp_rec.exempt_rate_modifier ) ||
                     'exempt_certificate_number = ' ||
                     p_curr_hdr_grp_rec.exempt_certificate_number ||
                     'exempt_reason = ' ||
                     p_curr_hdr_grp_rec.exempt_reason ||
                     'exempt_reason_code = ' ||
                     p_curr_hdr_grp_rec.exempt_reason_code ||
                     'tax_exception_id = ' ||
                     to_char(p_curr_hdr_grp_rec.tax_exception_id    )||
                     'tax_rate_before_exception = ' ||
                     to_char(p_curr_hdr_grp_rec.tax_rate_before_exception    )||
                     'tax_rate_name_before_exception = ' ||
                     p_curr_hdr_grp_rec.tax_rate_name_before_exception||
                     'exception_rate = ' ||
                     to_char(p_curr_hdr_grp_rec.exception_rate)||
                     'ledger_id = ' ||
                     to_char(p_curr_hdr_grp_rec.ledger_id)||
                     'legal_entity_id = ' ||
                     to_char(p_curr_hdr_grp_rec.legal_entity_id)||
                     'establishment_id = ' ||
                     to_char(p_curr_hdr_grp_rec.establishment_id)||
                     'currency_conversion_date = ' ||
                     to_char(p_curr_hdr_grp_rec.currency_conversion_date, 'DD-MON-YY')||
                     'currency_conversion_type = ' ||
                     p_curr_hdr_grp_rec.currency_conversion_type||
                     'currency_conversion_rate = ' ||
                     to_char(p_curr_hdr_grp_rec.currency_conversion_rate)||
                     'record_type_code  = ' ||
                     p_curr_hdr_grp_rec.record_type_code );

    END IF;

  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.determine_header_group.END',
                   'ZX_TDS_TAX_ROUNDING_PKG: determine_header_group(-)'||
                   p_return_status);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.determine_header_group' ,
                      p_error_buffer);
    END IF;

END determine_header_group;
-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  get_currency_info_for_rounding
--
--  DESCRIPTION
--  This procedure gets all information about  a  given currency
--  to be used later for conversion and rounding
--

PROCEDURE  get_currency_info_for_rounding(
             p_currency_code     IN     ZX_LINES.TRX_CURRENCY_CODE%TYPE,
             p_conversion_date   IN     ZX_LINES.CURRENCY_CONVERSION_DATE%TYPE,
             p_return_status     OUT NOCOPY VARCHAR2,
             p_error_buffer      OUT NOCOPY VARCHAR2
         )
IS
  l_currency_type              VARCHAR2(30);
  l_derive_effective           DATE;
  l_derive_type                VARCHAR2(30);
  l_mau                        NUMBER;
  l_precision                  NUMBER;
  l_conversion_rate            NUMBER;

BEGIN

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.get_currency_info_for_rounding.BEGIN',
                   'ZX_TDS_TAX_ROUNDING_PKG: get_currency_info_for_rounding(+)'||
                   'p_currency_code = ' || p_currency_code);
  END IF;

  p_return_status :=  FND_API.G_RET_STS_SUCCESS;

  --
  -- first check if currency info can be obtained from the cache structure
  -- if not, call get_currency_info to get it
  --
  IF g_currency_tbl.EXISTS(p_currency_code) THEN
    IF (g_currency_tbl(p_currency_code).derive_type = 'EMU' AND
        (p_conversion_date <>
         g_currency_tbl(p_currency_code).conversion_date))  THEN
      l_derive_effective := g_currency_tbl(p_currency_code).derive_effective;
      g_currency_tbl(p_currency_code).conversion_date := p_conversion_date;
      IF ( trunc(p_conversion_date) < trunc(l_derive_effective))  THEN
        g_currency_tbl(p_currency_code).currency_type := 'OTHER';
      ELSE
        g_currency_tbl(p_currency_code).currency_type := 'EMU';
      END IF;
    END IF;
  ELSE
    get_currency_info(p_currency_code,
                      p_conversion_date,
                      l_derive_effective,
                      l_derive_type,
                      l_conversion_rate,
                      l_mau,
                      l_precision,
                      l_currency_type,
                      p_return_status,
                      p_error_buffer);
    IF p_return_status = FND_API.G_RET_STS_SUCCESS THEN
      g_currency_tbl(p_currency_code).min_acct_unit := l_mau;
      g_currency_tbl(p_currency_code).precision := l_precision;
      g_currency_tbl(p_currency_code).conversion_rate := l_conversion_rate;
      g_currency_tbl(p_currency_code).currency_type := l_currency_type;
      g_currency_tbl(p_currency_code).derive_effective := l_derive_effective;
      g_currency_tbl(p_currency_code).derive_type := l_derive_type;
      g_currency_tbl(p_currency_code).conversion_date := p_conversion_date;
    END IF;
  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.get_currency_info_for_rounding.END',
                   'ZX_TDS_TAX_ROUNDING_PKG: get_currency_info_for_rounding(-)'||p_return_status);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.get_currency_info_for_rounding',
                      p_error_buffer);
    END IF;

END get_currency_info_for_rounding;
-----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  convert_to_currency
--
--  DESCRIPTION
--  This procedure converts amount from from_currency to to_currency
--

PROCEDURE  convert_to_currency(
             p_from_currency        IN     ZX_LINES.TRX_CURRENCY_CODE%TYPE,
             p_to_currency          IN     ZX_LINES.TAX_CURRENCY_CODE%TYPE,
             p_conversion_date      IN     ZX_LINES.tax_currency_conversion_date%TYPE,
             p_tax_conversion_type  IN     ZX_LINES.TAX_CURRENCY_CONVERSION_TYPE%TYPE,
             p_trx_conversion_type  IN     ZX_LINES.CURRENCY_CONVERSION_TYPE%TYPE,
             p_to_curr_conv_rate    IN OUT NOCOPY ZX_LINES.TAX_CURRENCY_CONVERSION_RATE%TYPE,
             p_from_amt             IN     ZX_LINES.TAX_AMT%TYPE,
             p_to_amt                  OUT NOCOPY ZX_LINES.TAX_AMT_TAX_CURR%TYPE,
             p_return_status           OUT NOCOPY VARCHAR2,
             p_error_buffer            OUT NOCOPY VARCHAR2,
             p_trx_conversion_date  IN ZX_LINES.CURRENCY_CONVERSION_DATE%TYPE DEFAULT NULL) --Bug7183884
IS
  l_rate_index                      BINARY_INTEGER;
BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.convert_to_currency.BEGIN',
                   'ZX_TDS_TAX_ROUNDING_PKG: convert_to_currency(+)'||
                   'p_to_curr_conv_rate = ' || to_char(p_to_curr_conv_rate));
  END IF;

  p_return_status :=  FND_API.G_RET_STS_SUCCESS;

  --
  -- if currency conversion rate is available, use it, otherwise,
  -- check if it exists in cache, if not, call convert_amount to get
  -- the currency conversion rate
  --
  IF (p_to_curr_conv_rate IS NOT NULL ) THEN
   p_to_amt     := p_from_amt * p_to_curr_conv_rate;
  ELSE
    --
    -- conversion rate is not available
    -- check if conversion type is available
    --
    IF p_tax_conversion_type IS NULL THEN
      p_to_amt := NULL;

      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.convert_to_currency',
                   'ZX_TDS_TAX_ROUNDING_PKG: convert_to_currency(+)'||
                   ' both conversion type and rate are NULL ' );
      END IF;

      RETURN;
    END IF;

    l_rate_index := get_rate_index(p_from_currency,
                                   p_to_currency,
                                   p_conversion_date,
                                   p_tax_conversion_type);
    IF g_tax_curr_conv_rate_tbl.EXISTS(l_rate_index) THEN

      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.convert_to_currency',
                   'get rate from cache, at index = ' ||
                    to_char(l_rate_index));
      END IF;

      p_to_curr_conv_rate    := g_tax_curr_conv_rate_tbl(l_rate_index);
      p_to_amt               := p_from_amt * p_to_curr_conv_rate;
    ELSE
      p_to_amt := convert_amount(
                                p_from_currency,
                                p_to_currency,
                                p_conversion_date,
                                p_tax_conversion_type,
                                p_trx_conversion_type,
                                p_from_amt,
                                l_rate_index,
                                p_return_status,
                                p_error_buffer,
                                p_trx_conversion_date);--Bug7183884
      IF p_return_status = FND_API.G_RET_STS_SUCCESS THEN
        p_to_curr_conv_rate   := g_tax_curr_conv_rate_tbl(l_rate_index);
      END IF;
    END IF;
  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.convert_to_currency.END',
                   'ZX_TDS_TAX_ROUNDING_PKG: convert_to_currency(-)'||
                    'conversion rate = ' || to_char(p_to_curr_conv_rate)||
                    'p_return_status = ' || p_return_status);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.convert_to_currency',
                      p_error_buffer);
    END IF;

END convert_to_currency;
-----------------------------------------------------------------------
--  PUBLIC  FUNCTION
--  round_tax_funcl_curr
--
--  DESCRIPTION
--  This function gets the minimum accountable unit and precision of
--  a functional currency from fnd_currencies based on the ledger id,
--  then rounds the tax amount in functional currency using ROUND function

FUNCTION round_tax_funcl_curr(
             p_unround_amt   IN             ZX_LINES.TAX_AMT%TYPE,
             p_ledger_id     IN             ZX_LINES.LEDGER_ID%TYPE,
             p_return_status     OUT NOCOPY VARCHAR2,
             p_error_buffer      OUT NOCOPY VARCHAR2
         )  RETURN NUMBER
IS
  l_round_amt             ZX_LINES.TAX_AMT_TAX_CURR%TYPE;
  l_min_acct_unit         FND_CURRENCIES.MINIMUM_ACCOUNTABLE_UNIT%TYPE;
  l_precision             FND_CURRENCIES.PRECISION%TYPE;
  l_currency_code         FND_CURRENCIES.CURRENCY_CODE%TYPE;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.round_tax_funcl_curr.BEGIN',
                   'ZX_TDS_TAX_ROUNDING_PKG: round_tax_funcl_curr(+)'||
                   ' unround amount in functional currency = ' ||
                    to_char(p_unround_amt));

  END IF;

  p_return_status :=  FND_API.G_RET_STS_SUCCESS;

  --
  -- perform rounding for amount in  functional currency
  --

  get_funcl_curr_info(
                    p_ledger_id,
                    l_currency_code,
                    l_min_acct_unit,
                    l_precision,
                    p_return_status,
                    p_error_buffer );


  IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    --
    -- error getting min acct unit and precision
    -- return original unround amount to caller
    --
    RETURN p_unround_amt;
  END IF;

  --
  -- l_min_acct_unit will contain the precision if
  -- min acct unit of this functional currency is null
  --
  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.round_tax_funcl_curr',
                   'l_min_acct_unit = '  || to_char(l_min_acct_unit)||
                   ' l_precision = '  || to_char(l_precision) );
  END IF;

  l_round_amt := ROUND(p_unround_amt/l_min_acct_unit) * l_min_acct_unit;


  IF (g_level_procedure >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.round_tax_funcl_curr.END',
                   'ZX_TDS_TAX_ROUNDING_PKG: round_tax_funcl_curr(-)'||
                   'unround amount in functional currency = ' ||
                    to_char(p_unround_amt)||
                   'rounded amount in functional currency = ' ||
                    to_char(l_round_amt));
  END IF;


  RETURN l_round_amt;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.round_tax_funcl_curr',
                      p_error_buffer);
    END IF;

END round_tax_funcl_curr;
-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  conv_rnd_tax_tax_curr
--
--  DESCRIPTION
--  This procedure converts the tax amount in transaction currency to tax
--  currency and then round the converted amount
--

PROCEDURE  conv_rnd_tax_tax_curr(
             p_from_currency        IN     ZX_LINES.TRX_CURRENCY_CODE%TYPE,
             p_to_currency          IN     ZX_LINES.TAX_CURRENCY_CODE%TYPE,
             p_conversion_date      IN     ZX_LINES.TAX_CURRENCY_CONVERSION_DATE%TYPE,
             p_tax_conversion_type  IN     ZX_LINES.TAX_CURRENCY_CONVERSION_TYPE%TYPE,
             p_trx_conversion_type  IN     ZX_LINES.CURRENCY_CONVERSION_TYPE%TYPE,
             p_tax_curr_conv_rate   IN OUT NOCOPY ZX_LINES.TAX_CURRENCY_CONVERSION_RATE%TYPE,
             p_amt                  IN     ZX_LINES.TAX_AMT%TYPE,
             p_convert_round_amt        OUT NOCOPY ZX_LINES.TAX_AMT_TAX_CURR%TYPE,
             p_Rounding_Rule_Code        IN     ZX_TAXES_B.Rounding_Rule_Code%TYPE,
             p_tax_min_acct_unit    IN     ZX_TAXES_B.MINIMUM_ACCOUNTABLE_UNIT%TYPE,
             p_tax_precision        IN     ZX_TAXES_B.TAX_PRECISION%TYPE,
             p_return_status           OUT NOCOPY VARCHAR2,
             p_error_buffer            OUT NOCOPY VARCHAR2,
             p_trx_conversion_date  IN ZX_LINES.CURRENCY_CONVERSION_DATE%TYPE DEFAULT NULL)--Bug7183884
IS
  l_amt_tax_curr                 NUMBER;

BEGIN

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.conv_rnd_tax_tax_curr.BEGIN',
                   'ZX_TDS_TAX_ROUNDING_PKG: conv_rnd_tax_tax_curr(+)'||
                   'p_tax_curr_conv_rate = ' || to_char(p_tax_curr_conv_rate));

  END IF;

  p_return_status :=  FND_API.G_RET_STS_SUCCESS;

  --
  -- convert tax amt to tax currency
  --
  convert_to_currency(
                      p_from_currency,
                      p_to_currency,
                      p_conversion_date,
                      p_tax_conversion_type,
                      p_trx_conversion_type,
                      p_tax_curr_conv_rate,
                      p_amt,
                      l_amt_tax_curr,
                      p_return_status,
                      p_error_buffer,
                      p_trx_conversion_date);--Bug7183884

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.conv_rnd_tax_tax_curr',
                  'tax conversion rate = ' || to_char(p_tax_curr_conv_rate)||
                 'unround tax amt tax currency = ' || to_char(l_amt_tax_curr));
  END IF;

  IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RETURN;
  END IF;

  --
  -- round the converted amount
  --
  p_convert_round_amt := round_tax(l_amt_tax_curr,
                                   p_Rounding_Rule_Code,
                                   p_tax_min_acct_unit,
                                   p_tax_precision,
                                   p_return_status,
                                   p_error_buffer);

  IF (g_level_statement >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.conv_rnd_tax_tax_curr.END',
                   'ZX_TDS_TAX_ROUNDING_PKG: conv_rnd_tax_tax_curr(-)'||
                   'rounded amount = ' || to_char(p_convert_round_amt));
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.conv_rnd_tax_tax_curr',
                      p_error_buffer);
    END IF;

END conv_rnd_tax_tax_curr;

-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  conv_rnd_tax_funcl_curr
--
--  DESCRIPTION
--  This procedure converts the tax amount in transaction currency to
--  functional  currency and then round the converted amount
--

PROCEDURE  conv_rnd_tax_funcl_curr(
             p_funcl_curr_conv_rate IN     ZX_LINES.CURRENCY_CONVERSION_RATE%TYPE,
             p_amt                  IN     ZX_LINES.TAX_AMT%TYPE,
             p_convert_round_amt        OUT NOCOPY ZX_LINES.TAX_AMT_TAX_CURR%TYPE,
             p_ledger_id            IN     ZX_LINES.LEDGER_ID%TYPE,
             p_return_status           OUT NOCOPY VARCHAR2,
             p_error_buffer            OUT NOCOPY VARCHAR2
         )
IS
  l_amt_funcl_curr        NUMBER;
  l_min_acct_unit         FND_CURRENCIES.MINIMUM_ACCOUNTABLE_UNIT%TYPE;
  l_precision             FND_CURRENCIES.PRECISION%TYPE;

BEGIN
  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.conv_rnd_tax_funcl_curr.BEGIN',
                   'ZX_TDS_TAX_ROUNDING_PKG: conv_rnd_tax_funcl_curr(+)'||
                   'p_funcl_curr_conv_rate = ' || to_char(p_funcl_curr_conv_rate));

  END IF;

  p_return_status :=  FND_API.G_RET_STS_SUCCESS;

  l_amt_funcl_curr     :=  p_amt * p_funcl_curr_conv_rate;

  IF l_amt_funcl_curr IS NOT NULL THEN
    p_convert_round_amt := round_tax_funcl_curr(
               l_amt_funcl_curr,
               p_ledger_id,
               p_return_status,
               p_error_buffer);

     IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RETURN;
     END IF;

  ELSE
    --
    -- it is okay if functional currency conversion rate is not
    -- available, just set the functional currency amount to NULL
    --
    p_convert_round_amt := NULL;
  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.conv_rnd_tax_funcl_curr.END',
                   'ZX_TDS_TAX_ROUNDING_PKG: conv_rnd_tax_funcl_curr(-)'||'convert round amt: '||p_convert_round_amt);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.conv_rnd_tax_funcl_curr',
                      p_error_buffer);
    END IF;

END conv_rnd_tax_funcl_curr;
-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  conv_rnd_taxable_tax_curr
--
--  DESCRIPTION
--  This procedure converts the taxable amount in transaction currency to
--  tax currency and then round the converted amount
--

PROCEDURE  conv_rnd_taxable_tax_curr(
             p_from_currency        IN     ZX_LINES.TRX_CURRENCY_CODE%TYPE,
             p_to_currency          IN     ZX_LINES.TAX_CURRENCY_CODE%TYPE,
             p_conversion_date      IN     ZX_LINES.TAX_CURRENCY_CONVERSION_DATE%TYPE,
             p_tax_conversion_type  IN     ZX_LINES.TAX_CURRENCY_CONVERSION_TYPE%TYPE,
             p_trx_conversion_type  IN     ZX_LINES.CURRENCY_CONVERSION_TYPE%TYPE,
             p_tax_curr_conv_rate   IN OUT NOCOPY ZX_LINES.TAX_CURRENCY_CONVERSION_RATE%TYPE,
             p_amt                  IN     ZX_LINES.TAX_AMT%TYPE,
             p_convert_round_amt        OUT NOCOPY ZX_LINES.TAX_AMT_TAX_CURR%TYPE,
             p_Rounding_Rule_Code        IN     ZX_TAXES_B.Rounding_Rule_Code%TYPE,
             p_tax_min_acct_unit    IN     ZX_TAXES_B.MINIMUM_ACCOUNTABLE_UNIT%TYPE,
             p_tax_precision        IN     ZX_TAXES_B.TAX_PRECISION%TYPE,
             p_tax_calculation_formula IN         ZX_LINES.TAX_CALCULATION_FORMULA%TYPE,
             p_tax_rate                IN         ZX_LINES.TAX_RATE%TYPE,
             p_tax_rate_id             IN         ZX_RATES_B.TAX_RATE_ID%TYPE,
             p_rounded_amt_tax_curr IN     ZX_LINES.TAX_AMT_TAX_CURR%TYPE,
             p_return_status           OUT NOCOPY VARCHAR2,
             p_error_buffer            OUT NOCOPY VARCHAR2,
             p_trx_conversion_date  IN     ZX_LINES.CURRENCY_CONVERSION_DATE%TYPE DEFAULT NULL) --Bug7183884

IS
  l_amt_tax_curr                 NUMBER;
  l_rate_type_code               ZX_RATES_B.RATE_TYPE_CODE%TYPE;
  l_tax_rate_rec                  ZX_TDS_UTILITIES_PKG.ZX_RATE_INFO_REC_TYPE;

BEGIN

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.conv_rnd_taxable_tax_curr.BEGIN',
                   'ZX_TDS_TAX_ROUNDING_PKG: conv_rnd_taxable_tax_curr(+)'||
                   'p_tax_curr_conv_rate = ' || to_char(p_tax_curr_conv_rate));

  END IF;

  p_return_status :=  FND_API.G_RET_STS_SUCCESS;

  IF ZX_TDS_UTILITIES_PKG.g_tax_rate_info_tbl.EXISTS(p_tax_rate_id) THEN
     l_rate_type_code :=
        ZX_TDS_UTILITIES_PKG.g_tax_rate_info_tbl(p_tax_rate_id).rate_type_code;
  ELSE
    ZX_TDS_UTILITIES_PKG.get_tax_rate_info(
       p_tax_rate_id      => p_tax_rate_id,
       p_tax_rate_rec     => l_tax_rate_rec,
       p_return_status    => p_return_status,
       p_error_buffer     => p_error_buffer);

      IF p_return_status = FND_API.G_RET_STS_SUCCESS THEN
        l_rate_type_code := l_tax_rate_rec.rate_type_code;
      END IF;
  END IF;

  IF p_amt IS NOT NULL THEN
    convert_to_currency(
                      p_from_currency,
                      p_to_currency,
                      p_conversion_date,
                      p_tax_conversion_type,
                      p_trx_conversion_type,
                      p_tax_curr_conv_rate,
                      p_amt,
                      l_amt_tax_curr,
                      p_return_status,
                      p_error_buffer,
                      p_trx_conversion_date); --Bug7183884
    IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RETURN;
    END IF;
  ELSIF (p_tax_calculation_formula IS NULL AND p_tax_rate <> 0 ) THEN
    l_amt_tax_curr := (p_rounded_amt_tax_curr/p_tax_rate);

    IF l_rate_type_code = 'PERCENTAGE' THEN
      l_amt_tax_curr := l_amt_tax_curr * 100;
    ELSIF l_rate_type_code = 'QUANTITY' THEN
      l_amt_tax_curr := p_amt;
    END IF;
  END IF;

  --
  -- round the converted amount
  --
  p_convert_round_amt := round_tax(l_amt_tax_curr,
                                   p_Rounding_Rule_Code,
                                   p_tax_min_acct_unit,
                                   p_tax_precision,
                                   p_return_status,
                                   p_error_buffer);

  IF (g_level_statement >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.conv_rnd_taxable_tax_curr.END',
                   'ZX_TDS_TAX_ROUNDING_PKG: conv_rnd_taxable_tax_curr(-)'||
                   'rounded taxable amt tax currency = ' ||
                    to_char(p_convert_round_amt));
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.conv_rnd_taxable_tax_curr',
                      p_error_buffer);
    END IF;

END conv_rnd_taxable_tax_curr;

-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  conv_rnd_taxable_funcl_curr
--
--  DESCRIPTION
--  This procedure converts the taxable amount in transaction currency to
--  functional  currency and then round the converted amount
--

PROCEDURE  conv_rnd_taxable_funcl_curr(
             p_funcl_curr_conv_rate IN     ZX_LINES.CURRENCY_CONVERSION_RATE%TYPE,
             p_amt                  IN     ZX_LINES.TAX_AMT%TYPE,
             p_convert_round_amt        OUT NOCOPY ZX_LINES.TAX_AMT_TAX_CURR%TYPE,
             p_ledger_id            IN     ZX_LINES.LEDGER_ID%TYPE,
             p_tax_calculation_formula IN     ZX_LINES.TAX_CALCULATION_FORMULA%TYPE,
             p_tax_rate             IN     ZX_LINES.TAX_RATE%TYPE,
             p_tax_rate_id          IN     ZX_RATES_B.TAX_RATE_ID%TYPE,
             p_rounded_amt_funcl_curr IN     ZX_LINES.TAX_AMT_FUNCL_CURR%TYPE,
             p_return_status           OUT NOCOPY VARCHAR2,
             p_error_buffer            OUT NOCOPY VARCHAR2
         )
IS
  l_amt_funcl_curr                 NUMBER;
  l_rate_type_code                ZX_RATES_B.RATE_TYPE_CODE%TYPE;
  l_tax_rate_rec                  ZX_TDS_UTILITIES_PKG.ZX_RATE_INFO_REC_TYPE;

BEGIN
  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.conv_rnd_taxable_funcl_curr.BEGIN',
                   'ZX_TDS_TAX_ROUNDING_PKG: conv_rnd_taxable_funcl_curr(+)'||
                   'p_funcl_curr_conv_rate = ' || to_char(p_funcl_curr_conv_rate));

  END IF;

  p_return_status :=  FND_API.G_RET_STS_SUCCESS;

  IF ZX_TDS_UTILITIES_PKG.g_tax_rate_info_tbl.EXISTS(p_tax_rate_id) THEN
     l_rate_type_code :=
        ZX_TDS_UTILITIES_PKG.g_tax_rate_info_tbl(p_tax_rate_id).rate_type_code;
  ELSE
    ZX_TDS_UTILITIES_PKG.get_tax_rate_info(
       p_tax_rate_id      => p_tax_rate_id,
       p_tax_rate_rec     => l_tax_rate_rec,
       p_return_status    => p_return_status,
       p_error_buffer     => p_error_buffer);

      IF p_return_status = FND_API.G_RET_STS_SUCCESS THEN
        l_rate_type_code := l_tax_rate_rec.rate_type_code;
      END IF;
  END IF;

  IF p_amt IS NOT NULL THEN
    l_amt_funcl_curr   :=  p_amt * p_funcl_curr_conv_rate;
  ELSIF (p_tax_calculation_formula IS NULL AND p_tax_rate <> 0 ) THEN
      l_amt_funcl_curr := (p_rounded_amt_funcl_curr/p_tax_rate);

      IF l_rate_type_code = 'PERCENTAGE' THEN
        l_amt_funcl_curr := l_amt_funcl_curr * 100;
      ELSIF l_rate_type_code = 'QUANTITY' THEN
        l_amt_funcl_curr := p_amt;
      END IF;
  END IF;

  IF l_amt_funcl_curr IS NOT NULL THEN
    --
    -- perform rounding for amount in  functional currency
    --
    p_convert_round_amt := round_tax_funcl_curr(
               l_amt_funcl_curr,
               p_ledger_id,
               p_return_status,
               p_error_buffer);

     IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RETURN;
     END IF;

  ELSE
    --
    -- it is okay if functional currency conversion rate is not
    -- available, just set the functional currency amount to NULL
    --
    p_convert_round_amt := NULL;
  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.conv_rnd_taxable_funcl_curr.END',
                   'ZX_TDS_TAX_ROUNDING_PKG: conv_rnd_taxable_funcl_curr(-)'||
                   'rounded taxable amt tax currency = ' ||
                    to_char(p_convert_round_amt));
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.conv_rnd_taxable_funcl_curr',
                      p_error_buffer);
    END IF;

END conv_rnd_taxable_funcl_curr;
-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  round_line_level
--
--  DESCRIPTION
--  This procedure is used to round tax lines at line level
--

PROCEDURE round_line_level(
             p_tax_amt               IN OUT NOCOPY ZX_LINES.TAX_AMT%TYPE,
             p_taxable_amt              OUT NOCOPY ZX_LINES.TAXABLE_AMT%TYPE,
             p_prd_total_tax_amt     IN OUT NOCOPY ZX_LINES.PRD_TOTAL_TAX_AMT%TYPE,
             p_Rounding_Rule_Code    IN            ZX_LINES.Rounding_Rule_Code%TYPE,
             p_trx_min_acct_unit     IN OUT NOCOPY ZX_LINES.MINIMUM_ACCOUNTABLE_UNIT%TYPE,
             p_trx_precision         IN OUT NOCOPY ZX_LINES.PRECISION%TYPE,
             p_trx_currency_code     IN            ZX_LINES.TRX_CURRENCY_CODE%TYPE,
             p_application_id           IN            ZX_LINES.APPLICATION_ID%TYPE,
             p_internal_organization_id IN            ZX_LINES.INTERNAL_ORGANIZATION_ID%TYPE,
             p_event_class_mapping_id   IN            ZX_LINES_DET_FACTORS.EVENT_CLASS_MAPPING_ID%TYPE,
             p_unrounded_taxable_amt IN ZX_LINES.UNROUNDED_TAXABLE_AMT%TYPE,
             p_unrounded_tax_amt     IN ZX_LINES.UNROUNDED_TAX_AMT%TYPE,
             p_return_status            OUT NOCOPY VARCHAR2,
             p_error_buffer             OUT NOCOPY VARCHAR2
         )
IS

  l_zx_proudct_options_rec          ZX_GLOBAL_STRUCTURES_PKG.zx_product_options_rec_type;
  l_min_acct_unit                   ZX_LINES.MINIMUM_ACCOUNTABLE_UNIT%TYPE;
  l_precision                       ZX_LINES.PRECISION%TYPE;

BEGIN

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.round_line_level.BEGIN',
                   'ZX_TDS_TAX_ROUNDING_PKG: round_line_level(+)'||
                   'unround tax_amt = ' || to_char(p_unrounded_tax_amt)||
                   'unround taxable_amt = ' || to_char(p_unrounded_taxable_amt)||
                   'unround prd_total_tax_amt = ' || to_char(p_prd_total_tax_amt)||
                   'p_trx_precision = ' || to_char(p_trx_precision)||
                   'p_trx_min_acct_unit = ' || to_char(p_trx_min_acct_unit));
  END IF;

  p_return_status :=  FND_API.G_RET_STS_SUCCESS;

  -- Bug 8969799
  --
  -- perform rounding for taxable amount
  p_taxable_amt := round_tax(p_unrounded_taxable_amt,
                             p_Rounding_Rule_Code,
                             p_trx_min_acct_unit,
                             p_trx_precision,
                             p_return_status,
                             p_error_buffer);

  -- perform rounding for prorated total amount
  IF p_prd_total_tax_amt IS NOT NULL THEN
    p_prd_total_tax_amt := round_tax(
                             p_prd_total_tax_amt,
                             p_Rounding_Rule_Code,
                             p_trx_min_acct_unit,
                             p_trx_precision,
                             p_return_status,
                             p_error_buffer);
  END IF;

  -- Code for taking precision from application tax option
  --
  ZX_GLOBAL_STRUCTURES_PKG.get_product_options_info
                   (p_application_id         => p_application_id,
                    p_org_id                 => p_internal_organization_id,
                    p_event_class_mapping_id => p_event_class_mapping_id,
                    x_product_options_rec    => l_zx_proudct_options_rec,
                    x_return_status          => p_return_status);

  IF p_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.round_line_level',
                     'p_return_status = ' || p_return_status);
    END IF;
    RETURN;
  END IF;

  IF p_trx_currency_code = l_zx_proudct_options_rec.tax_currency_code THEN
    l_precision := l_zx_proudct_options_rec.tax_precision;
    l_min_acct_unit := l_zx_proudct_options_rec.tax_minimum_accountable_unit;

    p_trx_min_acct_unit := GREATEST(NVL(p_trx_min_acct_unit,l_min_acct_unit),
                                    NVL(l_min_acct_unit,p_trx_min_acct_unit));
    p_trx_precision := LEAST(NVL(p_trx_precision, l_precision),
                             NVL(l_precision,p_trx_precision));
  END IF;

  --
  -- perform rounding for tax amount
  --
  --
  IF p_tax_amt IS NULL THEN
    p_tax_amt := round_tax(p_unrounded_tax_amt,
                           p_Rounding_Rule_Code,
                           p_trx_min_acct_unit,
                           p_trx_precision,
                           p_return_status,
                           p_error_buffer);
  ELSE
    p_tax_amt := round_tax(p_tax_amt,
                           p_Rounding_Rule_Code,
                           p_trx_min_acct_unit,
                           p_trx_precision,
                           p_return_status,
                           p_error_buffer);
  END IF;

  IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RETURN;
  END IF;

  -- moved the rounding of taxable amount and prorated total amount
  -- before tax amount rounding to ensure that they are rounded
  -- using the trx currency mau and precision.
  -- tax will be rounded based on tax setup/trx currency setup.

  --
  -- update recalculate flag
  --
  -- p_tax_line_rec.Recalc_Required_Flag := 'N';

  -- perform rounding for taxable amount
  --p_taxable_amt := round_tax(p_unrounded_taxable_amt,
  --                           p_Rounding_Rule_Code,
  --                           p_trx_min_acct_unit,
  --                           p_trx_precision,
  --                           p_return_status,
  --                           p_error_buffer);

  -- perform rounding for prorated total amount
  --IF p_prd_total_tax_amt IS NOT NULL THEN
  --  p_prd_total_tax_amt := round_tax(
  --                           p_prd_total_tax_amt,
  --                           p_Rounding_Rule_Code,
  --                           p_trx_min_acct_unit,
  --                           p_trx_precision,
  --                           p_return_status,
  --                           p_error_buffer);

  --END IF;


  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.round_line_level.END',
                   'ZX_TDS_TAX_ROUNDING_PKG: round_line_level(-)'||
                   'rounded tax amt = ' ||
                    to_char(p_tax_amt)||
                   'rounded taxable_amt = ' ||
                    to_char(p_taxable_amt)||
                    'rounded prd_total_tax_amt = ' ||
                    to_char(p_prd_total_tax_amt));
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.round_line_level',
                      p_error_buffer);
    END IF;

END round_line_level;

------------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  handle_header_rounding_curr
--
--  DESCRIPTION
--  This procedure handles header level rounding for functional currency
--  or any other currency when the conversion rate is passed  from products
--  This procedure is incomplete due to handling of MRC is not clear now


PROCEDURE handle_header_rounding_curr(
           p_tax_line_id              IN            ZX_LINES.TAX_LINE_ID%TYPE,
           p_unrounded_tax_amt        IN            ZX_LINES.UNROUNDED_TAX_AMT%TYPE,
           p_tax_amt_curr             IN            ZX_LINES.TAX_AMT_FUNCL_CURR%TYPE,
           p_taxable_amt_curr         IN            ZX_LINES.TAXABLE_AMT_FUNCL_CURR%TYPE,
           p_currency_conversion_rate IN            ZX_LINES.CURRENCY_CONVERSION_RATE%TYPE,
           p_prev_hdr_grp_rec         IN OUT NOCOPY HDR_GRP_REC_TYPE,
           p_curr_hdr_grp_rec         IN            HDR_GRP_REC_TYPE,
           p_ledger_id                IN            ZX_LINES.LEDGER_ID%TYPE,
           p_return_status               OUT NOCOPY VARCHAR2,
           p_error_buffer                OUT NOCOPY VARCHAR2
         )
IS
  l_same_tax                        VARCHAR2(1);
BEGIN

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.handle_header_rounding_curr.BEGIN',
                   'ZX_TDS_TAX_ROUNDING_PKG: handle_header_rounding_curr(+)');
  END IF;

  --
  -- init return status
  --
  p_return_status  := FND_API.G_RET_STS_SUCCESS;

  --
  -- check whether it is in the same group of tax for
  -- header rounding level.  l_same_tax is used for header
  -- rounding level only
  --
  determine_header_group(p_prev_hdr_grp_rec,
                         p_curr_hdr_grp_rec,
                         l_same_tax,
                         p_return_status,
                         p_error_buffer);

  IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RETURN;
  END IF;

  --
  -- update  header rounding info to new values
  --
  update_header_rounding_curr(
                                p_tax_line_id,
                                p_unrounded_tax_amt,
                                p_tax_amt_curr,
                                p_taxable_amt_curr,
                                p_currency_conversion_rate,
                                p_prev_hdr_grp_rec,
                                p_curr_hdr_grp_rec,
                                l_same_tax,
                                p_ledger_id,
                                p_return_status,
                                p_error_buffer);

  IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RETURN;
  END IF;

   IF (g_level_statement >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.handle_header_rounding_curr.END',
                   'ZX_TDS_TAX_ROUNDING_PKG: handle_header_rounding_curr(-)'||p_return_status);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.handle_header_rounding_curr',
                      p_error_buffer);
    END IF;

END handle_header_rounding_curr;

-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  get_rounding_info
--
--  DESCRIPTION
--  This procedure gets rounding information for transaction currency
--  and tax currency

PROCEDURE get_rounding_info(
            p_tax_id                        IN ZX_TAXES_B.TAX_ID%TYPE,
            p_tax_currency_code             OUT NOCOPY ZX_LINES.TAX_CURRENCY_CODE%TYPE,
            p_tax_currency_conversion_date  IN OUT NOCOPY ZX_LINES.TAX_CURRENCY_CONVERSION_DATE%TYPE,
            p_trx_currency_code             IN ZX_LINES.TRX_CURRENCY_CODE%TYPE,
            p_currency_conversion_date      IN ZX_LINES.CURRENCY_CONVERSION_DATE%TYPE,
            p_min_acct_unit                 IN OUT NOCOPY ZX_LINES.MINIMUM_ACCOUNTABLE_UNIT%TYPE,
            p_precision                     IN OUT NOCOPY ZX_LINES.PRECISION%TYPE,
            p_tax_min_acct_unit             OUT NOCOPY ZX_TAXES_B.MINIMUM_ACCOUNTABLE_UNIT%TYPE,
            p_tax_precision                 OUT NOCOPY ZX_TAXES_B.TAX_PRECISION%TYPE,
            p_tax_currency_conversion_type  OUT NOCOPY ZX_TAXES_B.EXCHANGE_RATE_TYPE%TYPE,
            p_return_status                 OUT NOCOPY VARCHAR2,
            p_error_buffer                  OUT NOCOPY VARCHAR2
         )
IS
  l_tax_id                          ZX_TAXES_B.TAX_ID%TYPE;
  l_tax_rec                         ZX_TDS_UTILITIES_PKG.ZX_TAX_INFO_CACHE_REC;

BEGIN

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.get_rounding_info.BEGIN',
                   'ZX_TDS_TAX_ROUNDING_PKG: get_rounding_info(+)');
  END IF;

  p_return_status :=  FND_API.G_RET_STS_SUCCESS;

  l_tax_id            := p_tax_id;

  --
  -- Bug#5410271- populate cache structure if not exist
  --
  IF NOT ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl.EXISTS(p_tax_id) THEN
    ZX_TDS_UTILITIES_PKG.populate_tax_cache(
                       p_tax_id,
                       p_return_status,
                       p_error_buffer);

    IF p_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_TDS_RULE_BASE_DETM_PVT.rule_base_process',
                       'p_return_status = ' || p_return_status ||
                       ', p_error_buffer  = ' || p_error_buffer);
      END IF;
      RETURN;
    END IF;
  END IF;

  l_tax_rec                      := ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(l_tax_id);
  p_tax_precision                := l_tax_rec.tax_precision;
  p_tax_min_acct_unit            := l_tax_rec.minimum_accountable_unit;
  p_tax_currency_code            := l_tax_rec.tax_currency_code;
  p_tax_currency_conversion_type := l_tax_rec.exchange_rate_type;
  --bug#6526550
  IF p_tax_currency_conversion_date IS NULL AND p_currency_conversion_date IS NOT NULL THEN
    p_tax_currency_conversion_date := p_currency_conversion_date;
  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.get_rounding_info',
                   'perform rounding for tax_id = ' ||
                    to_char(l_tax_id)||
                   'tax precision     = ' || p_tax_precision||
                   'tax min_acct_unit = ' || p_tax_min_acct_unit||
                   'tax Rounding_Rule_Code = ' || l_tax_rec.rounding_rule_code||
                   'tax currency_code = ' || l_tax_rec.tax_currency_code||
		   'p_tax_currency_conversion_date = '||p_tax_currency_conversion_date); --bug#6526550
 END IF;

  --
  -- get tax currency info
  --
  get_currency_info_for_rounding(
            p_tax_currency_code,
            p_tax_currency_conversion_date,
            p_return_status,
            p_error_buffer);
  IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RETURN;
  END IF;

  --
  -- get tax precision and min acct unit if they are null
  --
  IF (p_tax_min_acct_unit IS NULL AND p_tax_precision IS NULL) THEN
     p_tax_min_acct_unit :=
            g_currency_tbl(p_tax_currency_code).min_acct_unit;
     p_tax_precision :=
            g_currency_tbl(p_tax_currency_code).precision;
  END IF;

  --
  -- get transaction  currency info
  --
  get_currency_info_for_rounding(
            p_trx_currency_code,
            p_currency_conversion_date,
            p_return_status,
            p_error_buffer);
  IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RETURN;
  END IF;

  --
  -- check if have min acct unit and precision for trx currency
  --
  IF (p_min_acct_unit IS NULL AND p_precision IS NULL) THEN
    p_min_acct_unit :=
         g_currency_tbl(p_trx_currency_code).min_acct_unit;
    p_precision :=
         g_currency_tbl(p_trx_currency_code).precision;
  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.get_rounding_info.END',
                   'ZX_TDS_TAX_ROUNDING_PKG: get_rounding_info(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.get_rounding_info',
                      p_error_buffer);
    END IF;

END get_rounding_info;
----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  adjust_rounding_diff_curr
--
--  DESCRIPTION
--  This procedure adjusts the rounding differences to the largest line
--  for tax amount and taxable amount  in functional/other currency,
--  for each group belonged to a document.
--  the adjustment is needed for HEADER level rounding only
--  This procedure is incomplete due to handling of MRC is not clear now

PROCEDURE adjust_rounding_diff_curr(
            p_return_status                 OUT NOCOPY VARCHAR2,
            p_error_buffer                  OUT NOCOPY VARCHAR2
         )
IS
  l_rnd_sum_unrnd_curr            NUMBER;
  i                               BINARY_INTEGER;
  l_count                         NUMBER;

  l_tax_line_id_tbl              TAX_LINE_ID_TBL;
  l_tax_amt_curr_tbl             TAX_AMT_FUNCL_CURR_TBL;
  l_taxable_amt_curr_tbl         TAXABLE_AMT_FUNCL_CURR_TBL;


BEGIN

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.adjust_rounding_diff_curr.BEGIN',
                   'ZX_TDS_TAX_ROUNDING_PKG: adjust_rounding_diff_curr(+)');
  END IF;

  p_return_status :=  FND_API.G_RET_STS_SUCCESS;

  l_count := g_hdr_rounding_curr_tbl.COUNT;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.adjust_rounding_diff_curr',
                   'number of rows to adjust  = ' || to_char(l_count));
  END IF;

  FOR  i IN 1 .. l_count LOOP

    IF  g_hdr_rounding_info_tbl(i).total_rec_in_grp > 1 THEN
      --
      -- do the adjustment if the total number of records in this
      -- group is more than 1, if it is the only record in the
      -- group no need to do any adjustment
      --
      --
      --  round and adjust the max line
      --

      l_rnd_sum_unrnd_curr := round(g_hdr_rounding_curr_tbl(i).sum_unrnd_tax_amt *
                                  g_hdr_rounding_curr_tbl(i).currency_conversion_rate,20);

      l_rnd_sum_unrnd_curr := round_tax_funcl_curr(
                                      l_rnd_sum_unrnd_curr,
                                      g_hdr_rounding_curr_tbl(i).ledger_id,
                                      p_return_status,
                                      p_error_buffer);

      IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RETURN;
      END IF;

      g_hdr_rounding_curr_tbl(i).rnd_tax_amt_curr :=
         g_hdr_rounding_curr_tbl(i).rnd_tax_amt_curr +
         (l_rnd_sum_unrnd_curr -
          g_hdr_rounding_curr_tbl(i).sum_rnd_curr);

      IF (g_hdr_rounding_curr_tbl(i).tax_calculation_formula IS NULL AND
          g_hdr_rounding_curr_tbl(i).tax_rate <> 0) THEN
        --
        -- need to adjust the taxable amount
        --
        g_hdr_rounding_curr_tbl(i).rnd_taxable_amt_curr :=
          round_tax_funcl_curr(
              (g_hdr_rounding_curr_tbl(i).rnd_tax_amt_curr/
               g_hdr_rounding_curr_tbl(i).tax_rate),
               g_hdr_rounding_info_tbl(i).ledger_id,
               p_return_status,
               p_error_buffer);
        IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RETURN;
        END IF;
      END IF;
    END IF;  -- total_rec_in_grp > 1
  END LOOP;

  --
  -- do bulk update
  --

  FOR i IN   1 .. l_count LOOP
    l_tax_amt_curr_tbl(i)     := g_hdr_rounding_curr_tbl(i).rnd_tax_amt_curr;
    l_taxable_amt_curr_tbl(i) := g_hdr_rounding_curr_tbl(i).rnd_taxable_amt_curr;
    l_tax_line_id_tbl(i)      := g_hdr_rounding_curr_tbl(i).tax_line_id;
  END LOOP;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.adjust_rounding_diff_curr',
                   'update the adjustments to the largest lines ....');
  END IF;

  FORALL i IN  1 .. l_count
    UPDATE  ZX_LINES
      SET tax_amt_funcl_curr = l_tax_amt_curr_tbl(i),
          taxable_amt_funcl_curr = l_taxable_amt_curr_tbl(i)
      WHERE tax_line_id = l_tax_line_id_tbl(i);

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.adjust_rounding_diff_curr.END',
                   'ZX_TDS_TAX_ROUNDING_PKG: adjust_rounding_diff_curr(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.adjust_rounding_diff_curr',
                      p_error_buffer);
    END IF;

END adjust_rounding_diff_curr;

----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  adjust_rounding_diff
--
--  DESCRIPTION
--  This procedure adjusts the rounding differences to the largest line
--  for tax amount in trx currency, tax/taxable amount in tax currency and
--  tax/taxable amount in functional currency for each group belonged to a document
--  the adjustment is needed for HEADER level rounding only
--

PROCEDURE adjust_rounding_diff(
            p_return_status                 OUT NOCOPY VARCHAR2,
            p_error_buffer                  OUT NOCOPY VARCHAR2
         )
IS
  l_rnd_sum_unrnd_tax_amt         NUMBER;
  l_rnd_sum_unrnd_tx_curr         NUMBER;
  l_rnd_sum_unrnd_funcl_curr      NUMBER;
  i                               BINARY_INTEGER;
  j                               BINARY_INTEGER;
  l_count                         NUMBER;
  l_tax_min_acct_unit             ZX_TAXES_B.MINIMUM_ACCOUNTABLE_UNIT%TYPE;
  l_tax_precision                 ZX_TAXES_B.TAX_PRECISION%TYPE;

  l_tax_line_id_tbl              TAX_LINE_ID_TBL;
  l_tax_amt_tbl                  TAX_AMT_TBL;
  l_tax_amt_tax_curr_tbl         TAX_AMT_TAX_CURR_TBL;
  l_taxable_amt_tax_curr_tbl     TAXABLE_AMT_TAX_CURR_TBL;
  l_tax_amt_funcl_curr_tbl       TAX_AMT_FUNCL_CURR_TBL;
  l_taxable_amt_funcl_curr_tbl   TAXABLE_AMT_FUNCL_CURR_TBL;


BEGIN

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.adjust_rounding_diff.BEGIN',
                   'ZX_TDS_TAX_ROUNDING_PKG: adjust_rounding_diff(+)');
  END IF;

  p_return_status :=  FND_API.G_RET_STS_SUCCESS;

  l_count := g_hdr_rounding_info_tbl.COUNT;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.adjust_rounding_diff',
                   'number of rows to adjust  = ' || to_char(l_count));
  END IF;

  FOR  i IN 1 .. l_count LOOP

    IF  g_hdr_rounding_info_tbl(i).total_rec_in_grp > 1 THEN
      --
      -- do the adjustment if the total number of records in this
      -- group is more than 1, if it is the only record in the
      -- group no need to do any adjustment
      --

      l_rnd_sum_unrnd_tax_amt := round(g_hdr_rounding_info_tbl(i).sum_unrnd_tax_amt,20);

      l_rnd_sum_unrnd_tax_amt := round_tax(
                                    l_rnd_sum_unrnd_tax_amt,
                                    g_hdr_rounding_info_tbl(i).Rounding_Rule_Code,
                                    g_hdr_rounding_info_tbl(i).min_acct_unit,
                                    g_hdr_rounding_info_tbl(i).precision,
                                    p_return_status,
                                    p_error_buffer);

      IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RETURN;
      END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.adjust_rounding_diff',
                   'Rounded Tax amt before ' ||to_char(g_hdr_rounding_info_tbl(i).rnd_tax_amt));
  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.adjust_rounding_diff',
                   'number of rows to adjust  = ' || to_char(l_count));
  END IF;
      --
      -- adjust tax amt
      --

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.adjust_rounding_diff',
                   'sum_rnd_tax_amt' ||to_char(g_hdr_rounding_info_tbl(i).sum_rnd_tax_amt));
  END IF;

      g_hdr_rounding_info_tbl(i).rnd_tax_amt :=
         g_hdr_rounding_info_tbl(i).rnd_tax_amt +
         (l_rnd_sum_unrnd_tax_amt - g_hdr_rounding_info_tbl(i).sum_rnd_tax_amt);

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.adjust_rounding_diff',
                   'Rounded Tax amt after ' ||to_char(g_hdr_rounding_info_tbl(i).rnd_tax_amt));
  END IF;

      IF g_hdr_rounding_info_tbl(i).mrc_tax_line_flag = 'N' THEN
        --
        -- adjust tax amt tax currency
        --
        l_rnd_sum_unrnd_tx_curr := round(g_hdr_rounding_info_tbl(i).sum_unrnd_tax_amt *
                                   g_hdr_rounding_info_tbl(i).tax_curr_conv_rate,20);
        j := g_hdr_rounding_info_tbl(i).tax_id;

        l_tax_precision := ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(j).tax_precision;
        l_tax_min_acct_unit := ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(j).minimum_accountable_unit;

        l_rnd_sum_unrnd_tx_curr := round_tax(
                                  l_rnd_sum_unrnd_tx_curr,
                                  g_hdr_rounding_info_tbl(i).Rounding_Rule_Code,
                                  l_tax_min_acct_unit,
                                  l_tax_precision,
                                  p_return_status,
                                  p_error_buffer);

        IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RETURN;
        END IF;

        g_hdr_rounding_info_tbl(i).rnd_tax_amt_tax_curr :=
           g_hdr_rounding_info_tbl(i).rnd_tax_amt_tax_curr +
           (l_rnd_sum_unrnd_tx_curr -
            g_hdr_rounding_info_tbl(i).sum_rnd_tax_curr);

        --
        -- adjust tax amt functional currency
          --
        IF g_hdr_rounding_info_tbl(i).currency_conversion_rate IS NOT NULL THEN
          l_rnd_sum_unrnd_funcl_curr := round(g_hdr_rounding_info_tbl(i).sum_unrnd_tax_amt *
                                        g_hdr_rounding_info_tbl(i).currency_conversion_rate,20);

          l_rnd_sum_unrnd_funcl_curr := round_tax_funcl_curr(
                                          l_rnd_sum_unrnd_funcl_curr,
                                          g_hdr_rounding_info_tbl(i).ledger_id,
                                          p_return_status,
                                          p_error_buffer);

          IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RETURN;
          END IF;

          g_hdr_rounding_info_tbl(i).rnd_tax_amt_funcl_curr :=
             g_hdr_rounding_info_tbl(i).rnd_tax_amt_funcl_curr +
             (l_rnd_sum_unrnd_funcl_curr -
              g_hdr_rounding_info_tbl(i).sum_rnd_funcl_curr);
        END IF;

        --
        -- adjust taxable amt in tax currency and functional currency
        -- leave taxable amt as is
        --

        IF (g_hdr_rounding_info_tbl(i).tax_calculation_formula IS NULL AND
            g_hdr_rounding_info_tbl(i).tax_rate <> 0) THEN
          --
          -- need to adjust the taxable amount for tax currency
          -- and functional currency
          --
          g_hdr_rounding_info_tbl(i).rnd_taxable_amt_tax_curr :=
            round_tax(
                  (g_hdr_rounding_info_tbl(i).rnd_tax_amt_tax_curr/
                   g_hdr_rounding_info_tbl(i).tax_rate),
                   g_hdr_rounding_info_tbl(i).Rounding_Rule_Code,
                   l_tax_min_acct_unit,
                   l_tax_precision,
                   p_return_status,
                   p_error_buffer);
          IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RETURN;
          END IF;

          g_hdr_rounding_info_tbl(i).rnd_taxable_amt_funcl_curr :=
            round_tax_funcl_curr(
                  (g_hdr_rounding_info_tbl(i).rnd_tax_amt_funcl_curr/
                   g_hdr_rounding_info_tbl(i).tax_rate),
                   g_hdr_rounding_info_tbl(i).ledger_id,
                   p_return_status,
                   p_error_buffer);

          IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RETURN;
          END IF;
        END IF;
      END IF;   -- g_hdr_rounding_info_tbl(i).mrc_tax_line_flag = 'Y'
    END IF; -- total_num_in_grp > 1
  END LOOP;

  --
  -- do bulk update
  --

  FOR i IN   1 .. l_count LOOP

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.adjust_rounding_diff',
                   'Tax line id' ||to_char(g_hdr_rounding_info_tbl(i).tax_line_id));
  END IF;

    l_tax_amt_tbl(i)                := g_hdr_rounding_info_tbl(i).rnd_tax_amt;
    l_tax_amt_tax_curr_tbl(i)       := g_hdr_rounding_info_tbl(i).rnd_tax_amt_tax_curr;
    l_tax_amt_funcl_curr_tbl(i)     := g_hdr_rounding_info_tbl(i).rnd_tax_amt_funcl_curr;
    l_taxable_amt_tax_curr_tbl(i)   := g_hdr_rounding_info_tbl(i).rnd_taxable_amt_tax_curr;
    l_taxable_amt_funcl_curr_tbl(i) := g_hdr_rounding_info_tbl(i).rnd_taxable_amt_funcl_curr;
    l_tax_line_id_tbl(i)            := g_hdr_rounding_info_tbl(i).tax_line_id;
  END LOOP;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.adjust_rounding_diff',
                   'update the adjustments to the largest lines ....');
  END IF;

  FORALL i IN  1 .. l_count
    UPDATE  /*+ INDEX(ZX_DETAIL_TAX_LINES_GT ZX_DETAIL_TAX_LINES_GT_U2) */
            ZX_DETAIL_TAX_LINES_GT
      SET   tax_amt                = l_tax_amt_tbl(i),
            tax_amt_tax_curr       = l_tax_amt_tax_curr_tbl(i),
            tax_amt_funcl_curr     = l_tax_amt_funcl_curr_tbl(i),
            taxable_amt_tax_curr   = l_taxable_amt_tax_curr_tbl(i),
            taxable_amt_funcl_curr = l_taxable_amt_funcl_curr_tbl(i)
      WHERE tax_line_id = l_tax_line_id_tbl(i);

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.adjust_rounding_diff.END',
                   'ZX_TDS_TAX_ROUNDING_PKG: adjust_rounding_diff(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.adjust_rounding_diff',
                      p_error_buffer);
    END IF;

END adjust_rounding_diff;
----------------------------------------------------------------
--  PRIVATE PROCEDURE
--  update_header_rounding_curr
--
--  DESCRIPTION
--  This procedure stores header rounding info for each group which will be
--  used later for rounding adjustments.
--  This procedure is incomplete due to handling of MRC is not clear now

PROCEDURE update_header_rounding_curr(
           p_tax_line_id              IN            ZX_LINES.TAX_LINE_ID%TYPE,
           p_unrounded_tax_amt        IN            ZX_LINES.UNROUNDED_TAX_AMT%TYPE,
           p_tax_amt_curr             IN            ZX_LINES.TAX_AMT_FUNCL_CURR%TYPE,
           p_taxable_amt_curr         IN            ZX_LINES.TAXABLE_AMT_FUNCL_CURR%TYPE,
           p_currency_conversion_rate IN            ZX_LINES.CURRENCY_CONVERSION_RATE%TYPE,
           p_prev_hdr_grp_rec         IN OUT NOCOPY HDR_GRP_REC_TYPE,
           p_curr_hdr_grp_rec         IN            HDR_GRP_REC_TYPE,
           p_same_tax                 IN            VARCHAR2,
           p_ledger_id                IN            ZX_LINES.LEDGER_ID%TYPE,
           p_return_status               OUT NOCOPY VARCHAR2,
           p_error_buffer                OUT NOCOPY VARCHAR2
         )
IS
  j               BINARY_INTEGER;
BEGIN

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.update_header_rounding_curr.BEGIN',
                   'ZX_TDS_TAX_ROUNDING_PKG: update_header_rounding_curr(+)');
  END IF;

  --
  -- init return status
  --
  p_return_status  := FND_API.G_RET_STS_SUCCESS;

  j := g_hdr_rounding_curr_tbl.COUNT;

  IF p_same_tax = 'N' THEN
    --
    -- update the previous header group with values of current
    -- header group information, in case p_same_tax is 'Y',
    -- p_prev_hdr_grp_rec would pass out the original IN values
    --
    p_prev_hdr_grp_rec := p_curr_hdr_grp_rec;

    --
    -- this is a new group
    --
    j := j  + 1;

    --
    -- store rounding info  for later use
    --
    g_hdr_rounding_curr_tbl(j).max_unrnd_tax_amt    := 0;
    g_hdr_rounding_curr_tbl(j).sum_unrnd_tax_amt    := 0;
    g_hdr_rounding_curr_tbl(j).sum_rnd_curr         := 0;
    g_hdr_rounding_curr_tbl(j).ledger_id            := p_ledger_id;
    g_hdr_rounding_curr_tbl(j).total_rec_in_grp     := 0;

  END IF;

  g_hdr_rounding_curr_tbl(j).sum_unrnd_tax_amt :=
       g_hdr_rounding_curr_tbl(j).sum_unrnd_tax_amt + p_unrounded_tax_amt;
  g_hdr_rounding_curr_tbl(j).sum_rnd_curr :=
       g_hdr_rounding_curr_tbl(j).sum_rnd_curr + p_tax_amt_curr;
  g_hdr_rounding_curr_tbl(j).total_rec_in_grp     :=
       g_hdr_rounding_curr_tbl(j).total_rec_in_grp + 1;

  IF g_hdr_rounding_curr_tbl(j).max_unrnd_tax_amt <= ABS(p_unrounded_tax_amt)  THEN
    g_hdr_rounding_curr_tbl(j).max_unrnd_tax_amt := ABS(p_unrounded_tax_amt);
    g_hdr_rounding_curr_tbl(j).tax_line_id := p_tax_line_id;
    g_hdr_rounding_curr_tbl(j).currency_conversion_rate := p_currency_conversion_rate;
    g_hdr_rounding_curr_tbl(j).rnd_tax_amt_curr := p_tax_amt_curr;
    g_hdr_rounding_curr_tbl(j).rnd_taxable_amt_curr := p_taxable_amt_curr;
    g_hdr_rounding_curr_tbl(j).tax_calculation_formula :=
                                 p_curr_hdr_grp_rec.tax_calculation_formula;
    g_hdr_rounding_curr_tbl(j).tax_rate := p_curr_hdr_grp_rec.tax_rate;

  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.update_header_rounding_curr.END',
                   'ZX_TDS_TAX_ROUNDING_PKG: update_header_rounding_curr(-)');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.update_header_rounding_curr',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
    END IF;

END update_header_rounding_curr;

----------------------------------------------------------------
--  PRIVATE PROCEDURE
--  update_header_rounding_info
--
--  DESCRIPTION
--  This procedure stores header rounding info for each group which will be
--  used later for rounding adjustments.

PROCEDURE update_header_rounding_info(
           p_tax_line_id              IN            ZX_LINES.TAX_LINE_ID%TYPE,
           p_tax_id                   IN            ZX_TAXES_B.TAX_ID%TYPE,
           p_Rounding_Rule_Code       IN            ZX_LINES.Rounding_Rule_Code%TYPE,
           p_min_acct_unit            IN            ZX_LINES.MINIMUM_ACCOUNTABLE_UNIT%TYPE,
           p_precision                IN            ZX_LINES.PRECISION%TYPE,
           p_unrounded_tax_amt        IN            ZX_LINES.UNROUNDED_TAX_AMT%TYPE,
           p_tax_amt                  IN            ZX_LINES.TAX_AMT%TYPE,
           p_tax_amt_tax_curr         IN            ZX_LINES.TAX_AMT_TAX_CURR%TYPE,
           p_tax_amt_funcl_curr       IN            ZX_LINES.TAX_AMT_FUNCL_CURR%TYPE,
           p_taxable_amt_tax_curr     IN            ZX_LINES.TAXABLE_AMT_TAX_CURR%TYPE,
           p_taxable_amt_funcl_curr   IN            ZX_LINES.TAXABLE_AMT_FUNCL_CURR%TYPE,
           p_tax_curr_conv_rate       IN            ZX_LINES.TAX_CURRENCY_CONVERSION_RATE%TYPE,
           p_currency_conversion_rate IN            ZX_LINES.CURRENCY_CONVERSION_RATE%TYPE,
           p_prev_hdr_grp_rec         IN OUT NOCOPY HDR_GRP_REC_TYPE,
           p_curr_hdr_grp_rec         IN            HDR_GRP_REC_TYPE,
           p_same_tax                 IN            VARCHAR2,
           p_sum_unrnd_tax_amt        IN            NUMBER,
           p_sum_rnd_tax_amt          IN            NUMBER,
           p_sum_rnd_tax_curr         IN            NUMBER,
           p_sum_rnd_funcl_curr       IN            NUMBER,
           p_ledger_id                IN            ZX_LINES.LEDGER_ID%TYPE,
           p_return_status               OUT NOCOPY VARCHAR2,
           p_error_buffer                OUT NOCOPY VARCHAR2
         )
IS
  j               BINARY_INTEGER;
BEGIN

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.update_header_rounding_info.BEGIN',
                   'ZX_TDS_TAX_ROUNDING_PKG: update_header_rounding_info(+)');
  END IF;

  --
  -- init  return status
  --
  p_return_status  := FND_API.G_RET_STS_SUCCESS;

  j := g_hdr_rounding_info_tbl.COUNT;

  --
  -- update header group info only if this is
  -- a new rounding group
  --
  IF p_same_tax = 'N' THEN
    --
    -- update the previous header group with values of current
    -- header group information, in case p_same_tax is 'Y',
    -- p_prev_hdr_grp_rec would pass out the original IN values
    --
    p_prev_hdr_grp_rec := p_curr_hdr_grp_rec;

    --
    -- this is a new group
    --
    j := j + 1;

    --
    -- store rounding info  for later use
    --
    g_hdr_rounding_info_tbl(j).Rounding_Rule_Code :=  p_Rounding_Rule_Code;
    g_hdr_rounding_info_tbl(j).min_acct_unit :=  p_min_acct_unit;
    g_hdr_rounding_info_tbl(j).precision     := p_precision;
    g_hdr_rounding_info_tbl(j).max_unrnd_tax_amt    := 0;
    g_hdr_rounding_info_tbl(j).sum_unrnd_tax_amt := p_sum_unrnd_tax_amt;
    g_hdr_rounding_info_tbl(j).sum_rnd_tax_amt := p_sum_rnd_tax_amt;
    g_hdr_rounding_info_tbl(j).sum_rnd_tax_curr := p_sum_rnd_tax_curr;
    g_hdr_rounding_info_tbl(j).sum_rnd_funcl_curr := p_sum_rnd_funcl_curr;
    g_hdr_rounding_info_tbl(j).ledger_id := p_ledger_id;
    g_hdr_rounding_info_tbl(j).total_rec_in_grp := 0;

  END IF;

  --
  -- sum of unround tax amounts in the group so far
  --
  g_hdr_rounding_info_tbl(j).sum_unrnd_tax_amt :=
       g_hdr_rounding_info_tbl(j).sum_unrnd_tax_amt + p_unrounded_tax_amt;
  --
  -- sum of rounded tax amounts in the group so far
  --
  g_hdr_rounding_info_tbl(j).sum_rnd_tax_amt :=
       g_hdr_rounding_info_tbl(j).sum_rnd_tax_amt + p_tax_amt;
  --
  -- sum of rounded tax amounts in tax currency in the group so far
  --
  g_hdr_rounding_info_tbl(j).sum_rnd_tax_curr :=
       g_hdr_rounding_info_tbl(j).sum_rnd_tax_curr + p_tax_amt_tax_curr;
  --
  -- sum of rounded tax amounts in functional currency in the group so far
  --
  g_hdr_rounding_info_tbl(j).sum_rnd_funcl_curr :=
       g_hdr_rounding_info_tbl(j).sum_rnd_funcl_curr + p_tax_amt_funcl_curr;
  --
  -- total number of records in the group so far
  --
  g_hdr_rounding_info_tbl(j).total_rec_in_grp :=
       g_hdr_rounding_info_tbl(j).total_rec_in_grp + 1;

  --
  -- store the rounding info for the tax line that has the largest
  -- absolute unround tax amount for using in adjustment later on
  --
  IF g_hdr_rounding_info_tbl(j).max_unrnd_tax_amt <= ABS(p_unrounded_tax_amt)  THEN
    g_hdr_rounding_info_tbl(j).max_unrnd_tax_amt := ABS(p_unrounded_tax_amt);
    g_hdr_rounding_info_tbl(j).tax_line_id := p_tax_line_id;
    g_hdr_rounding_info_tbl(j).tax_id      := p_tax_id;
    g_hdr_rounding_info_tbl(j).tax_curr_conv_rate := p_tax_curr_conv_rate;
    g_hdr_rounding_info_tbl(j).currency_conversion_rate := p_currency_conversion_rate;
    g_hdr_rounding_info_tbl(j).rnd_tax_amt := p_tax_amt;
    g_hdr_rounding_info_tbl(j).rnd_tax_amt_tax_curr := p_tax_amt_tax_curr;
    g_hdr_rounding_info_tbl(j).rnd_tax_amt_funcl_curr := p_tax_amt_funcl_curr;
    g_hdr_rounding_info_tbl(j).rnd_taxable_amt_tax_curr := p_taxable_amt_tax_curr;
    g_hdr_rounding_info_tbl(j).rnd_taxable_amt_funcl_curr := p_taxable_amt_funcl_curr;
    g_hdr_rounding_info_tbl(j).tax_calculation_formula :=
                                 p_curr_hdr_grp_rec.tax_calculation_formula;
    g_hdr_rounding_info_tbl(j).tax_rate := p_curr_hdr_grp_rec.tax_rate;
    g_hdr_rounding_info_tbl(j).mrc_tax_line_flag :=
                                      p_curr_hdr_grp_rec.mrc_tax_line_flag;

  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.update_header_rounding_info.END',
                   'ZX_TDS_TAX_ROUNDING_PKG: update_header_rounding_info(-)');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.update_header_rounding_info',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
    END IF;

END update_header_rounding_info;

-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  do_rounding
--
--  DESCRIPTION
--  This procedure gathers rounding information needed to round tax
--  in transaction currency and tax currency and then does LINE level
--  rounding for tax amount and taxable amount in transaction currency,
--  tax currency and functional currency.  Prorated amount is also
--  handled here
--

PROCEDURE do_rounding(
           p_tax_id                        IN            ZX_TAXES_B.TAX_ID%TYPE,
           p_tax_rate_id                   IN            ZX_RATES_B.TAX_RATE_ID%TYPE,
           p_tax_amt                       IN OUT NOCOPY ZX_LINES.TAX_AMT%TYPE,
           p_taxable_amt                   IN OUT NOCOPY ZX_LINES.TAXABLE_AMT%TYPE,
           p_orig_tax_amt                  IN OUT NOCOPY ZX_LINES.TAX_AMT%TYPE,
           p_orig_taxable_amt              IN OUT NOCOPY ZX_LINES.TAXABLE_AMT%TYPE,
           p_orig_tax_amt_tax_curr         IN OUT NOCOPY ZX_LINES.TAX_AMT%TYPE,
           p_orig_taxable_amt_tax_curr     IN OUT NOCOPY ZX_LINES.TAXABLE_AMT%TYPE,
           p_cal_tax_amt                   IN OUT NOCOPY ZX_LINES.CAL_TAX_AMT%TYPE,
           p_tax_amt_tax_curr              IN OUT NOCOPY ZX_LINES.TAX_AMT_TAX_CURR%TYPE,
           p_taxable_amt_tax_curr             OUT NOCOPY ZX_LINES.TAXABLE_AMT_TAX_CURR%TYPE,
           p_cal_tax_amt_tax_curr             OUT NOCOPY ZX_LINES.CAL_TAX_AMT_TAX_CURR%TYPE,
           p_tax_amt_funcl_curr               OUT NOCOPY ZX_LINES.TAX_AMT_FUNCL_CURR%TYPE,
           p_taxable_amt_funcl_curr           OUT NOCOPY ZX_LINES.TAXABLE_AMT_FUNCL_CURR%TYPE,
           p_cal_tax_amt_funcl_curr           OUT NOCOPY ZX_LINES.CAL_TAX_AMT_FUNCL_CURR%TYPE,
           p_trx_currency_code             IN            ZX_LINES.TRX_CURRENCY_CODE%TYPE,
           p_tax_currency_code                OUT NOCOPY ZX_LINES.TAX_CURRENCY_CODE%TYPE,
           p_tax_currency_conversion_type  IN            ZX_LINES.TAX_CURRENCY_CONVERSION_TYPE%TYPE,
           p_tax_currency_conversion_rate  IN OUT NOCOPY ZX_LINES.TAX_CURRENCY_CONVERSION_RATE%TYPE,
           p_tax_currency_conversion_date  IN            ZX_LINES.TAX_CURRENCY_CONVERSION_DATE%TYPE,
           p_currency_conversion_type      IN            ZX_LINES.CURRENCY_CONVERSION_TYPE%TYPE,
           p_currency_conversion_rate      IN            ZX_LINES.CURRENCY_CONVERSION_RATE%TYPE,
           p_currency_conversion_date      IN            ZX_LINES.CURRENCY_CONVERSION_DATE%TYPE,
           p_Rounding_Rule_Code            IN            ZX_LINES.Rounding_Rule_Code%TYPE,
           p_ledger_id                     IN            ZX_LINES.LEDGER_ID%TYPE,
           p_min_acct_unit                 IN OUT NOCOPY ZX_LINES.MINIMUM_ACCOUNTABLE_UNIT%TYPE,
           p_precision                     IN OUT NOCOPY ZX_LINES.PRECISION%TYPE,
           p_application_id                IN            ZX_LINES.APPLICATION_ID%TYPE,
           p_internal_organization_id      IN            ZX_LINES.INTERNAL_ORGANIZATION_ID%TYPE,
           p_event_class_mapping_id        IN            ZX_LINES_DET_FACTORS.EVENT_CLASS_MAPPING_ID%TYPE,
           p_tax_calculation_formula       IN            ZX_LINES.TAX_CALCULATION_FORMULA%TYPE,
           p_tax_rate                      IN            ZX_LINES.TAX_RATE%TYPE,
           p_prd_total_tax_amt             IN OUT NOCOPY ZX_LINES.prd_total_tax_amt%TYPE,
           p_prd_total_tax_amt_tax_curr       OUT NOCOPY ZX_LINES.prd_total_tax_amt_tax_curr%TYPE,
           p_prd_total_tax_amt_funcl_curr     OUT NOCOPY ZX_LINES.prd_total_tax_amt_funcl_curr%TYPE,
           p_unrounded_taxable_amt         IN ZX_LINES.UNROUNDED_TAXABLE_AMT%TYPE,
           p_unrounded_tax_amt             IN ZX_LINES.UNROUNDED_TAX_AMT%TYPE,
           p_mrc_tax_line_flag             IN zx_lines.mrc_tax_line_flag%TYPE,
           p_tax_provider_id               IN zx_lines.tax_provider_id%TYPE,
           p_return_status                    OUT NOCOPY VARCHAR2,
           p_error_buffer                     OUT NOCOPY VARCHAR2
         )
IS
  l_tax_min_acct_unit            ZX_TAXES_B.MINIMUM_ACCOUNTABLE_UNIT%TYPE;
  l_tax_precision                ZX_TAXES_B.TAX_PRECISION%TYPE;
  l_tax_currency_conversion_type ZX_TAXES_B.EXCHANGE_RATE_TYPE%TYPE;
  l_prd_total_tax_amt            ZX_LINES.prd_total_tax_amt%TYPE;
  l_currency_conversion_type     ZX_LINES.CURRENCY_CONVERSION_TYPE%TYPE;
  l_tax_currency_conversion_date ZX_LINES.TAX_CURRENCY_CONVERSION_DATE%TYPE; --bug#6526550
  l_trx_currency_conversion_date ZX_LINES.CURRENCY_CONVERSION_DATE%TYPE; --Bug7183884
  l_funcl_min_acct_unit          FND_CURRENCIES.MINIMUM_ACCOUNTABLE_UNIT%TYPE;
  l_funcl_precision              FND_CURRENCIES.PRECISION%TYPE;
  l_funcl_currency_code          FND_CURRENCIES.CURRENCY_CODE%TYPE;

BEGIN

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.do_rounding.BEGIN',
                   'ZX_TDS_TAX_ROUNDING_PKG: do_rounding(+)');
  END IF;

  --
  -- init return status
  --
  p_return_status  := FND_API.G_RET_STS_SUCCESS;
  --
  -- get unround  amt
  --
  l_prd_total_tax_amt := p_prd_total_tax_amt;
  l_tax_currency_conversion_date := p_tax_currency_conversion_date; --bug#6526550
  l_trx_currency_conversion_date := p_currency_conversion_date; --Bug7183884
   --
   -- get rounding info for non-mrc tax lines
   -- (rounding info is available for MRC tax lines)
   --
   IF p_mrc_tax_line_flag = 'N' THEN
     get_rounding_info(p_tax_id,
                       p_tax_currency_code,
                       --p_tax_currency_conversion_date, --bug#6526550
                       l_tax_currency_conversion_date, --bug#6526550
                       p_trx_currency_code,
                       p_currency_conversion_date,
                       p_min_acct_unit,
                       p_precision,
                       l_tax_min_acct_unit,
                       l_tax_precision,
                       l_tax_currency_conversion_type,
                       p_return_status,
                       p_error_buffer);

     IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RETURN;
     END IF;

     IF (g_level_statement >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_statement,
                      'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.do_rounding',
                      'l_tax_precision = ' || to_char(l_tax_precision)||
                      'l_tax_min_acct_unit = ' || to_char(l_tax_min_acct_unit) ||
                      ' tax curr conv type = ' || l_tax_currency_conversion_type ||
                      ' tax curr conv type passed in = ' ||
                       p_tax_currency_conversion_type||
		      'l_tax_currency_conversion_date = '||
		       l_tax_currency_conversion_date); --bug#6526550
     END IF;
   END IF;      -- p_mrc_tax_line_flag = 'N'



   -- Bug 7138306: Revert the changes in revision 120.64.12000000.14
   -- for bug 6969126. The passed-in p_min_acct_unit and p_precision
   -- should be used for trx currency instead of tax settings
   --
   -- perform Line level rounding for tax amount and taxable amount
   -- using Tax Level settings eventhough the amount is in trx currency.
   --
   round_line_level(p_tax_amt,
                    p_taxable_amt,
                    p_prd_total_tax_amt,
                    p_Rounding_Rule_Code,
                    p_min_acct_unit,
                    p_precision,
                    p_trx_currency_code,
                    p_application_id,
                    p_internal_organization_id,
                    p_event_class_mapping_id,
                    p_unrounded_taxable_amt,
                    p_unrounded_tax_amt,
                    p_return_status,
                    p_error_buffer);

  IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RETURN;
  END IF;

  --
  -- Bug#5506495- determine tax_currency_conversion_type
  -- if it is not available
  --
  -- if p_tax_currency_conversion_type is not available, get
  -- the exchange rate type from zx_taxes_b
  --
  l_tax_currency_conversion_type := NVL(p_tax_currency_conversion_type, l_tax_currency_conversion_type);

  IF l_tax_currency_conversion_type IS NULL THEN
    IF p_tax_currency_code = p_trx_currency_code THEN
      -- in this case, tax currency conversion type is
      -- irrelevant as conversion rate is 1
      l_currency_conversion_type     := p_currency_conversion_type;
      p_tax_currency_conversion_rate := 1;
    ELSE
      -- check if tax currency is the same as
      -- functional currency
      --
      get_funcl_curr_info(
                    p_ledger_id,
                    l_funcl_currency_code,
                    l_funcl_min_acct_unit,
                    l_funcl_precision,
                    p_return_status,
                    p_error_buffer );

      IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RETURN;
      END IF;

      IF p_tax_currency_code = l_funcl_currency_code THEN
        l_currency_conversion_type     := p_currency_conversion_type;
        p_tax_currency_conversion_rate := p_currency_conversion_rate;
      ELSE
        -- tax currency is not the same as functional currency
        -- set tax conversion type from zx_taxes_b which is
        -- NULL in this case
        l_currency_conversion_type     := NULL;
      END IF;
    END IF;
  ELSE
    -- tax currency conversion type is available either
    -- from passed in or in zx_taxes_b
    l_currency_conversion_type := l_tax_currency_conversion_type;
  END IF;

  -- bug 5636132 convert orig_tax_amt to orig_tax_amt_tax_curr
  -- convert orig_taxable_amt to orig_taxable_amt_tax_curr

  IF p_orig_tax_amt is NOT NULL AND p_orig_tax_amt_tax_curr is NULL THEN

  	  convert_to_currency(
             p_from_currency        =>  p_trx_currency_code,
             p_to_currency          =>  p_tax_currency_code,
             --p_conversion_date      =>  p_tax_currency_conversion_date, --bug#6526550
	     p_conversion_date      => l_tax_currency_conversion_date, --bug#6526550
             p_tax_conversion_type  =>  l_currency_conversion_type,
             p_trx_conversion_type  =>  NULL,
             p_to_curr_conv_rate    =>  p_tax_currency_conversion_rate,
             p_from_amt             =>  p_orig_tax_amt,
             p_to_amt               =>  p_orig_tax_amt_tax_curr,
             p_return_status        =>  p_return_status,
             p_error_buffer         =>  p_error_buffer,
             p_trx_conversion_date => l_trx_currency_conversion_date);--Bug7183884

    --Bug 7109899

    IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RETURN;
    END IF;


  END IF;

  IF p_orig_taxable_amt is NOT NULL AND p_orig_taxable_amt_tax_curr is NULL THEN

  	  convert_to_currency(
             p_from_currency        =>  p_trx_currency_code,
             p_to_currency          =>  p_tax_currency_code,
             --p_conversion_date      =>  l_tax_currency_conversion_date, --bug#6526550
	     p_conversion_date      =>  l_tax_currency_conversion_date, --bug#6526550
             p_tax_conversion_type  =>  l_currency_conversion_type,
             p_trx_conversion_type  =>  NULL,
             p_to_curr_conv_rate    =>  p_tax_currency_conversion_rate,
             p_from_amt             =>  p_orig_taxable_amt,
             p_to_amt               =>  p_orig_taxable_amt_tax_curr,
             p_return_status        =>  p_return_status,
             p_error_buffer         =>  p_error_buffer,
             p_trx_conversion_date => l_trx_currency_conversion_date); --Bug7183884

    -- Bug 7109899

    IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RETURN;
    END IF;


  END IF;

  --
  -- covert to tax currency and functional currency for non-mrc tax lines
  --
  IF p_mrc_tax_line_flag = 'N' THEN

    IF p_tax_amt = 0 THEN
      --
      -- if rounded tax amt is zero, set tax currency
      -- and functional currency of tax amount to zero
      --
      p_tax_amt_tax_curr       := 0;
      p_tax_amt_funcl_curr     := 0;
      p_cal_tax_amt_tax_curr   := 0;
      p_cal_tax_amt_funcl_curr := 0;
    ELSE

      -- bug fix 3551605, add the following if condition
      -- convert the round the tax_amount_tax_curr conditionally.
      IF p_tax_provider_id IS NULL
       OR (p_tax_provider_id IS NOT NULL AND p_tax_amt_tax_curr IS NULL) THEN
        --
        -- convert to tax amt tax currency based
        -- on unrounded tax amt
        --
        conv_rnd_tax_tax_curr(
                              p_trx_currency_code,
                              p_tax_currency_code,
                              --p_tax_currency_conversion_date, --bug#6526550
			      l_tax_currency_conversion_date, --bug#6526550
                              --p_tax_currency_conversion_type,
                              l_currency_conversion_type,
                              p_currency_conversion_type,
                              p_tax_currency_conversion_rate,
                              p_unrounded_tax_amt,
                              p_tax_amt_tax_curr,
                              p_Rounding_Rule_Code,
                              l_tax_min_acct_unit,
                              l_tax_precision,
                              p_return_status,
                              p_error_buffer,
                              l_trx_currency_conversion_date);--Bug7183884

        IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RETURN;
        END IF;
      END IF;

          -- round cal tax amt ???????????????
          -- convert to cal tax amt tax currency based
          -- on unrounded cal tax amt
          -- ???????????????????????????????

      --
      -- convert to tax amt functional currency based
      -- on unrounded tax amt
      --
      conv_rnd_tax_funcl_curr(
                            p_currency_conversion_rate,
                            p_unrounded_tax_amt,
                            p_tax_amt_funcl_curr,
                            p_ledger_id,
                            p_return_status,
                            p_error_buffer);


      IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RETURN;
      END IF;

      --
      -- convert to cal tax amt functional currency based
      -- on unrounded cal tax amt
      -- ????? not sure what to do with cal tax amt now
      --
      conv_rnd_tax_funcl_curr(
                            p_currency_conversion_rate,
                            p_cal_tax_amt,
                            p_cal_tax_amt_funcl_curr,
                            p_ledger_id,
                            p_return_status,
                            p_error_buffer);

      IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RETURN;
      END IF;
    END IF;

    IF p_taxable_amt = 0 THEN
      --
      -- if rounded taxable amt is zero, set tax currency
      -- and functional currency of taxable amount to zero
      --
      p_taxable_amt_tax_curr   := 0;
      p_taxable_amt_funcl_curr := 0;
    ELSE
      --
      -- convert to taxable amt tax currency based
      -- on unrounded taxable amt
      --
      conv_rnd_taxable_tax_curr(
                            p_trx_currency_code,
                            p_tax_currency_code,
                            --p_tax_currency_conversion_date, --bug#6526550
                            l_tax_currency_conversion_date, --bug#6526550
                            --p_tax_currency_conversion_type,
                            l_currency_conversion_type,
                            p_currency_conversion_type,
                            p_tax_currency_conversion_rate,
                            p_unrounded_taxable_amt,
                            p_taxable_amt_tax_curr,
                            p_Rounding_Rule_Code,
                            l_tax_min_acct_unit,
                            l_tax_precision,
                            p_tax_calculation_formula,
                            p_tax_rate,
                            p_tax_rate_id,
                            p_tax_amt_tax_curr,
                            p_return_status,
                            p_error_buffer,
                            l_trx_currency_conversion_date); --Bug7183884
      IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RETURN;
      END IF;

      --
      -- convert to taxable amt functional currency based
      -- on unrounded taxable amt
      --
      conv_rnd_taxable_funcl_curr(
                            p_currency_conversion_rate,
                            p_unrounded_taxable_amt,
                            p_taxable_amt_funcl_curr,
                            p_ledger_id,
                            p_tax_calculation_formula,
                            p_tax_rate,
                            p_tax_rate_id,
                            p_tax_amt_funcl_curr,
                            p_return_status,
                            p_error_buffer);
      IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RETURN;
      END IF;

    END IF;

    --
    -- perform rounding for prorated total tax amount if
    -- it is not null
    --
    IF p_prd_total_tax_amt IS NOT NULL THEN
      IF p_prd_total_tax_amt = 0 THEN
        --
        -- if rounded prorated tax amt is zero, set prorated tax
        -- currency and functional currency to zero
        --
        p_prd_total_tax_amt_tax_curr       := 0;
        p_prd_total_tax_amt_funcl_curr     := 0;
      ELSE
        --
        -- convert to tax currency based
        -- on unrounded prorated  amt
        --
        conv_rnd_tax_tax_curr(
                            p_trx_currency_code,
                            p_tax_currency_code,
                            --p_tax_currency_conversion_date, --bug#6526550
			    l_tax_currency_conversion_date, --bug#6526550
                            --p_tax_currency_conversion_type,
                            l_currency_conversion_type,
                            p_currency_conversion_type,
                            p_tax_currency_conversion_rate,
                            l_prd_total_tax_amt,
                            p_prd_total_tax_amt_tax_curr,
                            p_Rounding_Rule_Code,
                            l_tax_min_acct_unit,
                            l_tax_precision,
                            p_return_status,
                            p_error_buffer,
                            l_trx_currency_conversion_date);--Bug7183884
        IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RETURN;
        END IF;
        --
        -- convert to functional currency based
        -- on unrounded prorated  amt
        --
        conv_rnd_tax_funcl_curr(
                            p_currency_conversion_rate,
                            l_prd_total_tax_amt,
                            p_prd_total_tax_amt_funcl_curr,
                            p_ledger_id,
                            p_return_status,
                            p_error_buffer);
        IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RETURN;
        END IF;
      END IF;
    END IF;
  END IF;      -- p_mrc_tax_line_flag = 'N'

  IF (g_level_statement >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.do_rounding.END',
                   'ZX_TDS_TAX_ROUNDING_PKG: do_rounding(-)'||p_return_status);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.do_rounding',
                      p_error_buffer);
    END IF;

END do_rounding;

-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  process_tax_line_create
--
--  DESCRIPTION
--  This procedure  initializes sum of unrounded tax amounts,
--  sum of rounded tax amounts, sum of rounded tax amounts in
--  tax currency and sum of rounded tax amounts in functional
--  currency for  fresh created tax line

PROCEDURE process_tax_line_create(
            p_sum_unrnd_tax_amt     OUT NOCOPY NUMBER,
            p_sum_rnd_tax_amt       OUT NOCOPY NUMBER,
            p_sum_rnd_tax_curr       OUT NOCOPY NUMBER,
            p_sum_rnd_funcl_curr    OUT NOCOPY NUMBER,
            p_return_status         OUT NOCOPY VARCHAR2,
            p_error_buffer          OUT NOCOPY VARCHAR2
         )
IS

BEGIN

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.process_tax_line_create.BEGIN',
                   'ZX_TDS_TAX_ROUNDING_PKG: process_tax_line_create(+)');
  END IF;

  p_return_status  := FND_API.G_RET_STS_SUCCESS;

  --
  -- init sum  to 0 for fresh rounding
  --
  p_sum_unrnd_tax_amt   := 0;
  p_sum_rnd_tax_amt     := 0;
  p_sum_rnd_tax_curr    := 0;
  p_sum_rnd_funcl_curr  := 0;

  IF (g_level_statement >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.process_tax_line_create.END',
                   'ZX_TDS_TAX_ROUNDING_PKG: process_tax_line_create(-)'||p_return_status);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.process_tax_line_create',
                      p_error_buffer);
    END IF;

END process_tax_line_create;
----------------------------------------------------------------
--  PRIVATE PROCEDURE
--  process_tax_line_upd_override
--
--  DESCRIPTION
--  This procedure  initializes sum of unrounded tax amounts,
--  sum of rounded tax amounts, sum of rounded tax amounts in
--  tax currency and sum of rounded tax amounts in functional
--  currency for  tax line that has been updated or  overridden
--

PROCEDURE process_tax_line_upd_override(
           p_curr_hdr_grp_rec        IN            HDR_GRP_REC_TYPE,
           p_sum_unrnd_tax_amt          OUT NOCOPY NUMBER,
           p_sum_rnd_tax_amt            OUT NOCOPY NUMBER,
           p_sum_rnd_tax_curr           OUT NOCOPY NUMBER,
           p_sum_rnd_funcl_curr         OUT NOCOPY NUMBER,
           p_event_class_rec         IN            ZX_API_PUB.EVENT_CLASS_REC_TYPE,
           p_return_status              OUT NOCOPY VARCHAR2,
           p_error_buffer               OUT NOCOPY VARCHAR2
         )
IS
  l_trx_id                  ZX_LINES.TRX_ID%TYPE;
  l_application_id          ZX_LINES.APPLICATION_ID%TYPE;
  l_event_class_code        ZX_LINES.EVENT_CLASS_CODE%TYPE;
  l_entity_code             ZX_LINES.ENTITY_CODE%TYPE;

  CURSOR get_existing_sum_amt_csr
    (c_trx_id                        ZX_LINES.TRX_ID%TYPE,
     c_application_id                ZX_LINES.APPLICATION_ID%TYPE,
     c_event_class_code              ZX_LINES.EVENT_CLASS_CODE%TYPE,
     c_entity_code                   ZX_LINES.ENTITY_CODE%TYPE,
     c_tax_regime_code               ZX_REGIMES_B.TAX_REGIME_CODE%TYPE,
     c_tax                           ZX_TAXES_B.tax%TYPE,
     c_tax_status_code               ZX_STATUS_B.TAX_STATUS_CODE%TYPE,
     c_tax_rate_code                 ZX_RATES_B.TAX_RATE_CODE%TYPE,
     c_tax_rate                      ZX_LINES.TAX_RATE%TYPE,
     c_tax_rate_id                   ZX_LINES.TAX_RATE_ID%TYPE,
     c_tax_jurisdiction_code         ZX_LINES.TAX_JURISDICTION_CODE%TYPE,
     c_taxable_basis_formula         ZX_FORMULA_B.FORMULA_CODE%TYPE,
     c_tax_calculation_formula       ZX_FORMULA_B.FORMULA_CODE%TYPE,
     c_tax_amt_included_flag         ZX_LINES.TAX_AMT_INCLUDED_FLAG%TYPE,
     c_compounding_tax_flag          ZX_LINES.COMPOUNDING_TAX_FLAG%TYPE,
     c_historical_flag               ZX_LINES.HISTORICAL_FLAG%TYPE,
     c_self_assessed_flag            ZX_LINES.SELF_ASSESSED_FLAG%TYPE,
     c_overridden_flag               ZX_LINES.OVERRIDDEN_FLAG%TYPE,
     c_manually_entered_flag         ZX_LINES.MANUALLY_ENTERED_FLAG%TYPE,
     c_Copied_From_Other_Doc_Flag    ZX_LINES.COPIED_FROM_OTHER_DOC_FLAG%TYPE,
     c_associated_child_frozen_flag  ZX_LINES.ASSOCIATED_CHILD_FROZEN_FLAG%TYPE,
     c_tax_only_line_flag            ZX_LINES.TAX_ONLY_LINE_FLAG%TYPE,
     c_mrc_tax_line_flag             ZX_LINES.MRC_TAX_LINE_FLAG%TYPE,
     c_reporting_only_flag           ZX_LINES.REPORTING_ONLY_FLAG%TYPE,
     c_applied_from_application_id   ZX_LINES.APPLIED_FROM_APPLICATION_ID%TYPE,
     c_applied_from_evnt_cls_cd      ZX_LINES.APPLIED_FROM_EVENT_CLASS_CODE%TYPE,
     c_applied_from_entity_code      ZX_LINES.APPLIED_FROM_ENTITY_CODE%TYPE,
     c_applied_from_trx_id           ZX_LINES.APPLIED_FROM_TRX_ID%TYPE,
     c_applied_from_line_id          ZX_LINES.APPLIED_FROM_LINE_ID%TYPE,
     c_adjusted_doc_application_id   ZX_LINES.ADJUSTED_DOC_APPLICATION_ID%TYPE,
     c_adjusted_doc_entity_code      ZX_LINES.ADJUSTED_DOC_ENTITY_CODE%TYPE,
     c_adjusted_doc_evnt_cls_cd      ZX_LINES.ADJUSTED_DOC_EVENT_CLASS_CODE%TYPE,
     c_adjusted_doc_trx_id           ZX_LINES.ADJUSTED_DOC_TRX_ID%TYPE,
     --c_applied_to_application_id     ZX_LINES.APPLIED_TO_APPLICATION_ID%TYPE,
     --c_applied_to_evnt_cls_cd        ZX_LINES.APPLIED_TO_EVENT_CLASS_CODE%TYPE,
     --c_applied_to_entity_code        ZX_LINES.APPLIED_TO_ENTITY_CODE%TYPE,
     --c_applied_to_trx_id             ZX_LINES.APPLIED_TO_TRX_ID%TYPE,
     --c_applied_to_line_id            ZX_LINES.APPLIED_TO_LINE_ID%TYPE,
     c_tax_exemption_id              ZX_LINES.TAX_EXEMPTION_ID%TYPE,
     c_tax_rate_before_exemption     ZX_LINES.TAX_RATE_BEFORE_EXEMPTION%TYPE,
     c_rate_name_before_exemption    ZX_LINES.TAX_RATE_NAME_BEFORE_EXEMPTION%TYPE,
     c_exempt_rate_modifier          ZX_LINES.EXEMPT_RATE_MODIFIER%TYPE,
     c_exempt_certificate_number     ZX_LINES.EXEMPT_CERTIFICATE_NUMBER%TYPE,
     c_exempt_reason                 ZX_LINES.EXEMPT_REASON%TYPE,
     c_exempt_reason_code            ZX_LINES.EXEMPT_REASON_CODE%TYPE,
     c_tax_exception_id              ZX_LINES.TAX_EXCEPTION_ID%TYPE,
     c_tax_rate_before_exception     ZX_LINES.TAX_RATE_BEFORE_EXCEPTION%TYPE,
     c_rate_name_before_exception    ZX_LINES.TAX_RATE_NAME_BEFORE_EXCEPTION%TYPE,
     c_exception_rate                ZX_LINES.EXCEPTION_RATE%TYPE,
     c_ledger_id                     ZX_LINES.LEDGER_ID%TYPE,
     c_legal_entity_id               ZX_LINES.LEGAL_ENTITY_ID%TYPE,
     c_establishment_id              ZX_LINES.ESTABLISHMENT_ID%TYPE,
     c_currency_conversion_date      ZX_LINES.CURRENCY_CONVERSION_date%TYPE,
     c_currency_conversion_type      ZX_LINES.CURRENCY_CONVERSION_type%TYPE,
     c_currency_conversion_rate      ZX_LINES.CURRENCY_CONVERSION_rate%TYPE,
     c_record_type_code              ZX_LINES.RECORD_TYPE_CODE%TYPE)
  IS
    SELECT SUM(unrounded_tax_amt),
           SUM(tax_amt),
           SUM(tax_amt_tax_curr),
           SUM(tax_amt_funcl_curr)
      FROM ZX_LINES L
      WHERE L.trx_id                                   = c_trx_id AND
            L.application_id                           = c_application_id AND
            L.event_class_code                         = c_event_class_code AND
            L.entity_code                              = c_entity_code      AND
            L.tax_regime_code                          = c_tax_regime_code AND
            L.tax                                      = c_tax             AND
            NVL(L.tax_status_code, 'X')                = NVL(c_tax_status_code, 'X') AND
            NVL(L.tax_rate_code, 'X')                  = NVL(c_tax_rate_code, 'X')   AND
            NVL(L.tax_rate, -999)                      = NVL(c_tax_rate, -999)        AND
            NVL(L.tax_rate_id, -999)                   = NVL(c_tax_rate_id, -999)        AND
            NVL(L.tax_jurisdiction_code, 'X')          = NVL(c_tax_jurisdiction_code, 'X')  AND
            NVL(L.taxable_basis_formula, 'X')          = NVL(c_taxable_basis_formula, 'X') AND
            NVL(L.tax_calculation_formula, 'X')        = NVL(c_tax_calculation_formula, 'X')  AND
            L.Tax_Amt_Included_Flag                    = c_tax_amt_included_flag AND
            L.compounding_tax_flag                     = c_compounding_tax_flag  AND
            L.historical_flag                          = c_historical_flag  AND
            L.self_assessed_flag                       = c_self_assessed_flag  AND
            L.overridden_flag                          = c_overridden_flag  AND
            L.manually_entered_flag                    = c_manually_entered_flag  AND
            L.Copied_From_Other_Doc_Flag               = c_copied_from_other_doc_flag  AND
            L.associated_child_frozen_flag             = c_associated_child_frozen_flag  AND
            L.tax_only_line_flag                       = c_tax_only_line_flag  AND
            L.mrc_tax_line_flag                        = c_mrc_tax_line_flag  AND
            L.reporting_only_flag                      = c_reporting_only_flag  AND
            NVL(L.applied_from_application_id, -999)   = NVL(c_applied_from_application_id, -999)  AND
            NVL(L.applied_from_event_class_code, 'X')  = NVL(c_applied_from_evnt_cls_cd, 'X')  AND
            NVL(L.applied_from_entity_code, 'X')       = NVL(c_applied_from_entity_code, 'X')  AND
            NVL(L.applied_from_trx_id, -999)           = NVL(c_applied_from_trx_id, -999)  AND
            NVL(L.applied_from_line_id, -999)          = NVL(c_applied_from_line_id, -999)  AND
            NVL(L.adjusted_doc_application_id, -999)   = NVL(c_adjusted_doc_application_id, -999)  AND
            NVL(L.adjusted_doc_entity_code, 'X')       = NVL(c_adjusted_doc_entity_code, 'X')  AND
            NVL(L.adjusted_doc_event_class_code, 'X')  = NVL(c_adjusted_doc_evnt_cls_cd, 'X')  AND
            NVL(L.adjusted_doc_trx_id, -999)           = NVL(c_adjusted_doc_trx_id, -999)  AND
            -- NVL(L.applied_to_application_id, -999)     = NVL(c_applied_to_application_id, -999)  AND
            -- NVL(L.applied_to_event_class_code, 'X')    = NVL(c_applied_to_evnt_cls_cd, 'X')  AND
            -- NVL(L.applied_to_entity_code, 'X')         = NVL(c_applied_to_entity_code, 'X')  AND
            -- NVL(L.applied_to_trx_id, -999)             = NVL(c_applied_to_trx_id, -999)  AND
            -- NVL(L.applied_to_line_id, -999)            = NVL(c_applied_to_line_id, -999)  AND
            NVL(L.tax_exemption_id, -999)              = NVL(c_tax_exemption_id, -999)  AND
            NVL(L.tax_rate_before_exemption, -999)     = NVL(c_tax_rate_before_exemption, -999)  AND
            NVL(L.tax_rate_name_before_exemption, 'X') = NVL(c_rate_name_before_exemption, 'X')  AND
            NVL(L.exempt_rate_modifier, -999)          = NVL(c_exempt_rate_modifier, -999)  AND
            NVL(L.exempt_certificate_number, 'X')      = NVL(c_exempt_certificate_number, 'X')  AND
            NVL(L.exempt_reason, 'X')                  = NVL(c_exempt_reason, 'X')  AND
            NVL(L.exempt_reason_code, 'X')             = NVL(c_exempt_reason_code, 'X')  AND
            NVL(L.tax_exception_id, -999)              = NVL(c_tax_exception_id, -999)  AND
            NVL(L.tax_rate_before_exception, -999)     = NVL(c_tax_rate_before_exception, -999)  AND
            NVL(L.tax_rate_name_before_exception, 'X') = NVL(c_rate_name_before_exception, 'X')  AND
            NVL(L.exception_rate, -999)                = NVL(c_exception_rate, -999)  AND
            NVL(L.ledger_id, -999)                     = NVL(c_ledger_id, -999)  AND
            NVL(L.legal_entity_id, -999)               = NVL(c_legal_entity_id, -999)  AND
            NVL(L.establishment_id, -999)              = NVL(c_establishment_id, -999)  AND
      TRUNC(NVL(L.currency_conversion_date, SYSDATE))  = TRUNC(NVL(c_currency_conversion_date, SYSDATE))  AND
            NVL(L.currency_conversion_type, 'X')       = NVL(c_currency_conversion_type, 'X')  AND
            NVL(L.currency_conversion_rate, -999)      = NVL(c_currency_conversion_rate, -999)  AND
            L.record_type_code                         = c_record_type_code  AND
            L.offset_link_to_tax_line_id IS NULL   AND
            NOT EXISTS (SELECT /*+ INDEX(G ZX_DETAIL_TAX_LINES_GT_U2) */  1
                          FROM ZX_DETAIL_TAX_LINES_GT G
                         WHERE G.tax_line_id = L.tax_line_id);

BEGIN

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.process_tax_line_upd_override.BEGIN',
                   'ZX_TDS_TAX_ROUNDING_PKG: process_tax_line_upd_override(+)');
  END IF;

  p_return_status  := FND_API.G_RET_STS_SUCCESS;

  --
  -- this is new group of tax, need to get existing sum amounts
  --

  l_trx_id             := p_event_class_rec.trx_id;
  l_application_id     := p_event_class_rec.application_id;
  l_event_class_code   := p_event_class_rec.event_class_code;
  l_entity_code        := p_event_class_rec.entity_code;

  -- bug6773534: remove applied_to info from header grouping criteria

  OPEN get_existing_sum_amt_csr(
           l_trx_id,
           l_application_id,
           l_event_class_code,
           l_entity_code,
           p_curr_hdr_grp_rec.tax_regime_code,
           p_curr_hdr_grp_rec.tax,
           p_curr_hdr_grp_rec.tax_status_code,
           p_curr_hdr_grp_rec.tax_rate_code,
           p_curr_hdr_grp_rec.tax_rate,
           p_curr_hdr_grp_rec.tax_rate_id,
           p_curr_hdr_grp_rec.tax_jurisdiction_code,
           p_curr_hdr_grp_rec.taxable_basis_formula,
           p_curr_hdr_grp_rec.tax_calculation_formula,
           p_curr_hdr_grp_rec.Tax_Amt_Included_Flag,
           p_curr_hdr_grp_rec.compounding_tax_flag,
           p_curr_hdr_grp_rec.historical_flag,
           p_curr_hdr_grp_rec.self_assessed_flag,
           p_curr_hdr_grp_rec.overridden_flag,
           p_curr_hdr_grp_rec.manually_entered_flag,
           p_curr_hdr_grp_rec.Copied_From_Other_Doc_Flag,
           p_curr_hdr_grp_rec.associated_child_frozen_flag,
           p_curr_hdr_grp_rec.tax_only_line_flag,
           p_curr_hdr_grp_rec.mrc_tax_line_flag,
           p_curr_hdr_grp_rec.reporting_only_flag,
           p_curr_hdr_grp_rec.applied_from_application_id,
           p_curr_hdr_grp_rec.applied_from_event_class_code,
           p_curr_hdr_grp_rec.applied_from_entity_code,
           p_curr_hdr_grp_rec.applied_from_trx_id,
           p_curr_hdr_grp_rec.applied_from_line_id,
           p_curr_hdr_grp_rec.adjusted_doc_application_id,
           p_curr_hdr_grp_rec.adjusted_doc_entity_code,
           p_curr_hdr_grp_rec.adjusted_doc_event_class_code,
           p_curr_hdr_grp_rec.adjusted_doc_trx_id,
           --p_curr_hdr_grp_rec.applied_to_application_id,
           --p_curr_hdr_grp_rec.applied_to_event_class_code,
           --p_curr_hdr_grp_rec.applied_to_entity_code,
           --p_curr_hdr_grp_rec.applied_to_trx_id,
           --p_curr_hdr_grp_rec.applied_to_line_id,
           p_curr_hdr_grp_rec.tax_exemption_id,
           p_curr_hdr_grp_rec.tax_rate_before_exemption,
           p_curr_hdr_grp_rec.tax_rate_name_before_exemption,
           p_curr_hdr_grp_rec.exempt_rate_modifier,
           p_curr_hdr_grp_rec.exempt_certificate_number,
           p_curr_hdr_grp_rec.exempt_reason,
           p_curr_hdr_grp_rec.exempt_reason_code,
           p_curr_hdr_grp_rec.tax_exception_id,
           p_curr_hdr_grp_rec.tax_rate_before_exception,
           p_curr_hdr_grp_rec.tax_rate_name_before_exception,
           p_curr_hdr_grp_rec.exception_rate,
           p_curr_hdr_grp_rec.ledger_id,
           p_curr_hdr_grp_rec.legal_entity_id,
           p_curr_hdr_grp_rec.establishment_id,
           p_curr_hdr_grp_rec.currency_conversion_date,
           p_curr_hdr_grp_rec.currency_conversion_type,
           p_curr_hdr_grp_rec.currency_conversion_rate,
           p_curr_hdr_grp_rec.record_type_code);

  FETCH get_existing_sum_amt_csr
    INTO p_sum_unrnd_tax_amt,
         p_sum_rnd_tax_amt,
         p_sum_rnd_tax_curr,
         p_sum_rnd_funcl_curr;
  IF p_sum_unrnd_tax_amt IS NULL THEN
    -- this would be the case of those tax lines exist in zx_lines
    -- have been updated so these same tax lines would also exist
    -- in gt, causing no record returns
    p_sum_unrnd_tax_amt   := 0;
    p_sum_rnd_tax_amt     := 0;
    p_sum_rnd_tax_curr    := 0;
    p_sum_rnd_funcl_curr  := 0;
  END IF;
  CLOSE get_existing_sum_amt_csr;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.process_tax_line_upd_override',
                   'p_sum_unrnd_tax_amt = ' || to_char(p_sum_unrnd_tax_amt)||
                   'p_sum_rnd_tax_amt = ' || to_char(p_sum_rnd_tax_amt)||
                   'p_sum_rnd_tax_curr = ' || to_char(p_sum_rnd_tax_curr)||
                   'p_sum_rnd_funcl_curr= ' || to_char(p_sum_rnd_funcl_curr));

    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.process_tax_line_upd_override.END',
                   'ZX_TDS_TAX_ROUNDING_PKG: process_tax_line_upd_override(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.process_tax_line_upd_override',
                      p_error_buffer);
    END IF;

END process_tax_line_upd_override;

-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  chk_mandatory_col_after_round
--
--  DESCRIPTION
--  This procedure
--

PROCEDURE  chk_mandatory_col_after_round(
             p_trx_currency_code    IN            ZX_LINES.TRX_CURRENCY_CODE%TYPE,
             p_tax_currency_code    IN            ZX_LINES.TAX_CURRENCY_CODE%TYPE,
             p_tax_amt              IN            ZX_LINES.TAX_AMT%TYPE,
             p_tax_amt_tax_curr     IN            ZX_LINES.TAX_AMT_TAX_CURR%TYPE,
             p_taxable_amt          IN            ZX_LINES.TAXABLE_AMT%TYPE,
             p_taxable_amt_tax_curr IN            ZX_LINES.TAXABLE_AMT_TAX_CURR%TYPE,
             p_mrc_tax_line_flag    IN            zx_lines.mrc_tax_line_flag%TYPE,
             p_rate_type_code       IN            ZX_RATES_B.RATE_TYPE_CODE%TYPE,
             p_return_status           OUT NOCOPY VARCHAR2,
             p_error_buffer            OUT NOCOPY VARCHAR2
         )
IS
BEGIN
  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.chk_mandatory_col_after_round.BEGIN',
                   'ZX_TDS_TAX_ROUNDING_PKG: chk_mandatory_col_after_round(+)');
  END IF;

  p_return_status :=  FND_API.G_RET_STS_SUCCESS;

  IF p_tax_amt IS NULL THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := 'tax_amt can not be NULL';
  ELSIF p_taxable_amt IS NULL THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := 'taxable_amt can not be NULL';
  END IF;

  IF p_mrc_tax_line_flag = 'N' THEN
    IF p_trx_currency_code IS NULL THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      p_error_buffer  := 'trx_currency_code can not be NULL';
    ELSIF p_tax_currency_code IS NULL THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      p_error_buffer  := 'tax_currency_code can not be NULL';
    ELSIF p_tax_amt_tax_curr IS NULL THEN
      IF p_rate_type_code = 'QUANTITY' THEN
        --
        -- Bug#5506495- quantity based tax, raise error
        --
        p_return_status := FND_API.G_RET_STS_ERROR;

        FND_MESSAGE.SET_NAME('ZX','ZX_QTY_TAX_NO_EXCHG_RATE_TYPE');
        FND_MESSAGE.SET_TOKEN('TAX_CURRENCY', p_tax_currency_code);
        IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_id IS NOT NULL THEN
          ZX_API_PUB.add_msg(
            ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec);
        ELSE
          FND_MSG_PUB.Add;
        END IF;

        p_error_buffer  := 'tax_amt_tax_curr can not be NULL';
      END IF;
    ELSIF p_taxable_amt_tax_curr IS NULL THEN
      IF p_rate_type_code = 'QUANTITY' THEN
        --
        -- Bug#5506495- quantity based tax, raise error
        --
        p_return_status := FND_API.G_RET_STS_ERROR;

        FND_MESSAGE.SET_NAME('ZX','ZX_QTY_TAX_NO_EXCHG_RATE_TYPE');
        FND_MESSAGE.SET_TOKEN('TAX_CURRENCY', p_tax_currency_code);
        IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec.trx_id IS NOT NULL THEN
         ZX_API_PUB.add_msg(
           ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec);
        ELSE
          FND_MSG_PUB.Add;
        END IF;

        p_error_buffer  := 'taxable_amt_tax_curr can not be NULL';
      END IF;
    END IF;
  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.chk_mandatory_col_after_round.END',
                   'ZX_TDS_TAX_ROUNDING_PKG: chk_mandatory_col_after_round(-)'||
                   'return status: '||p_return_status||
                   ' error_buffer  = ' || p_error_buffer);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.chk_mandatory_col_after_round',
                      p_error_buffer);
    END IF;

END chk_mandatory_col_after_round;

-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  update_detail_tax_lines_gt
--
--  DESCRIPTION
--  This procedure
--

PROCEDURE  update_detail_tax_lines_gt(
             p_min_acct_unit_tbl                IN MIN_ACCT_UNIT_TBL,
             p_precision_tbl                    IN PRECISION_TBL,
             p_tax_currency_code_tbl            IN TAX_CURRENCY_CODE_TBL,
             p_tax_curr_conv_rate_tbl           IN TAX_CURR_CONV_RATE_TBL,
             p_tax_amt_tbl                      IN TAX_AMT_TBL,
             p_taxable_amt_tbl                  IN TAXABLE_AMT_TBL,
             p_tax_amt_tax_curr_tbl             IN TAX_AMT_TAX_CURR_TBL,
             p_taxable_amt_tax_curr_tbl         IN  TAXABLE_AMT_TAX_CURR_TBL,
             p_tax_amt_funcl_curr_tbl           IN TAX_AMT_FUNCL_CURR_TBL,
             p_taxable_amt_funcl_curr_tbl       IN TAXABLE_AMT_FUNCL_CURR_TBL,
             p_prd_total_tax_amt_tbl            IN PRD_TOTAL_TAX_AMT_TBL,
             p_prd_tot_tax_amt_tax_curr_tbl     IN PRD_TOTAL_TAX_AMT_TAX_CURR_TBL,
             p_prd_tot_tax_amt_fcl_curr_tbl     IN PRD_TOTAL_TAX_AMT_FCL_CURR_TBL,
             p_cal_tax_amt_funcl_curr_tbl       IN CAL_TAX_AMT_FUNCL_CURR_TBL,
             p_orig_tax_amt_tax_curr_tbl        IN TAX_AMT_TBL,
             p_orig_taxable_amt_tax_cur_tbl     IN TAXABLE_AMT_TBL,
             p_tax_line_id_tbl                  IN TAX_LINE_ID_TBL,
             p_return_status                    OUT NOCOPY VARCHAR2,
             p_error_buffer                     OUT NOCOPY VARCHAR2
         )
IS
  i                              BINARY_INTEGER;
  l_count                        NUMBER;
BEGIN
  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.update_detail_tax_lines_gt.BEGIN',
                   'ZX_TDS_TAX_ROUNDING_PKG: update_detail_tax_lines_gt(+)');
  END IF;

  p_return_status :=  FND_API.G_RET_STS_SUCCESS;

  l_count := p_tax_line_id_tbl.COUNT;

  FORALL  i IN 1 .. l_count

      -- Currently, TSRM validate provider's precision is equal or less
      -- than eTax, so there won't be any rounding difference to sync back.
      -- Once TSRM relax the validation, the sync flag may need to be set.

        UPDATE /*+ INDEX(ZX_DETAIL_TAX_LINES_GT ZX_DETAIL_TAX_LINES_GT_U2) */
                ZX_DETAIL_TAX_LINES_GT
          SET   Recalc_Required_Flag = 'N',
                minimum_accountable_unit = p_min_acct_unit_tbl(i),
                precision = p_precision_tbl(i),
                tax_currency_code = p_tax_currency_code_tbl(i),
                tax_currency_conversion_rate = p_tax_curr_conv_rate_tbl(i),
                tax_amt = p_tax_amt_tbl(i),
                taxable_amt = p_taxable_amt_tbl(i),
                tax_amt_tax_curr = p_tax_amt_tax_curr_tbl(i),
                taxable_amt_tax_curr = p_taxable_amt_tax_curr_tbl(i),
                tax_amt_funcl_curr = p_tax_amt_funcl_curr_tbl(i),
                taxable_amt_funcl_curr = p_taxable_amt_funcl_curr_tbl(i),
                prd_total_tax_amt  = p_prd_total_tax_amt_tbl(i),
                prd_total_tax_amt_tax_curr = p_prd_tot_tax_amt_tax_curr_tbl(i),
                prd_total_tax_amt_funcl_curr = p_prd_tot_tax_amt_fcl_curr_tbl(i),
                cal_tax_amt_funcl_curr = p_cal_tax_amt_funcl_curr_tbl(i),
                orig_tax_amt_tax_curr  = p_orig_tax_amt_tax_curr_tbl(i),
                orig_taxable_amt_tax_curr = p_orig_taxable_amt_tax_cur_tbl(i)
           WHERE  tax_line_id = p_tax_line_id_tbl(i);

  IF (g_level_statement >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.update_detail_tax_lines_gt.END',
                   'ZX_TDS_TAX_ROUNDING_PKG: update_detail_tax_lines_gt(-)'||
                   'p_return_status = ' || p_return_status);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.update_detail_tax_lines_gt',
                      p_error_buffer);
    END IF;

END update_detail_tax_lines_gt;
-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  update_zx_lines
--
--  DESCRIPTION
--  This procedure updates the values belonged to a group used by
--  header level rounding
--

PROCEDURE  update_zx_lines(
                p_conversion_rate            IN            NUMBER,
                p_conversion_type            IN            VARCHAR2,
                p_conversion_date            IN            DATE,
                p_tax_amt_funcl_curr_tbl     IN            TAX_AMT_FUNCL_CURR_TBL,
                p_taxable_amt_funcl_curr_tbl IN            TAXABLE_AMT_FUNCL_CURR_TBL,
                p_cal_tax_amt_funcl_curr_tbl IN            CAL_TAX_AMT_FUNCL_CURR_TBL,
                p_tax_line_id_tbl            IN            TAX_LINE_ID_TBL,
                p_return_status                 OUT NOCOPY VARCHAR2,
                p_error_buffer                  OUT NOCOPY VARCHAR2
)

IS

  l_count                NUMBER;
  l_mau                  NUMBER;
  l_rate_ratio           NUMBER;
  l_tax_amt_tax_curr     NUMBER;
  l_taxable_amt_tax_curr NUMBER;
  l_cal_tax_amt_tax_curr NUMBER;
  l_rounding_rule_code   ZX_TAXES_B.ROUNDING_RULE_CODE%TYPE;
BEGIN

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.update_zx_lines.BEGIN',
                   'ZX_TDS_TAX_ROUNDING_PKG: update_zx_lines(+)');
  END IF;

  p_return_status  := FND_API.G_RET_STS_SUCCESS;

  l_count := p_tax_line_id_tbl.COUNT;

  -- update zx_lines
  --
  FOR i IN 1 .. l_count LOOP
    select Decode(tax_currency_conversion_rate,0,2,currency_conversion_rate/tax_currency_conversion_rate),
           NVL(tax.minimum_accountable_unit, power(10, (-1 * tax.tax_precision))),
           tax_amt_tax_curr,
           taxable_amt_tax_curr,
           cal_tax_amt_tax_curr,
           zxl.rounding_rule_code
      into l_rate_ratio,
           l_mau,
           l_tax_amt_tax_curr,
           l_taxable_amt_tax_curr,
           l_cal_tax_amt_tax_curr,
           l_rounding_rule_code
      from zx_lines zxl,zx_taxes_b tax
     where zxl.tax_line_id = p_tax_line_id_tbl(i)
       and zxl.tax_id = tax.tax_id;

    IF l_rate_ratio = 1 AND l_mau IS NOT NULL THEN
      l_tax_amt_tax_curr     := round_tax(p_tax_amt_funcl_curr_tbl(i)
                                          ,l_rounding_rule_code
                                          ,l_mau,NULL
                                          ,p_return_status
                                          ,p_error_buffer
                                          );
      l_taxable_amt_tax_curr := round_tax(p_taxable_amt_funcl_curr_tbl(i)
                                          ,l_rounding_rule_code
                                          ,l_mau,NULL
                                          ,p_return_status
                                          ,p_error_buffer
                                          );
      l_cal_tax_amt_tax_curr := round_tax(p_cal_tax_amt_funcl_curr_tbl(i)
                                          ,l_rounding_rule_code
                                          ,l_mau,NULL
                                          ,p_return_status
                                          ,p_error_buffer
                                          );
    ELSIF l_rate_ratio = 1 THEN
      l_tax_amt_tax_curr     := p_tax_amt_funcl_curr_tbl(i);
      l_taxable_amt_tax_curr := p_taxable_amt_funcl_curr_tbl(i);
      l_cal_tax_amt_tax_curr := p_cal_tax_amt_funcl_curr_tbl(i);
    END IF;

    UPDATE ZX_LINES
      SET   currency_conversion_date = p_conversion_date,
            currency_conversion_type = p_conversion_type,
            currency_conversion_rate = p_conversion_rate,
            tax_amt_funcl_curr       = p_tax_amt_funcl_curr_tbl(i),
            taxable_amt_funcl_curr   = p_taxable_amt_funcl_curr_tbl(i),
            cal_tax_amt_funcl_curr   = p_cal_tax_amt_funcl_curr_tbl(i),
            tax_currency_conversion_date = Decode(l_rate_ratio,1,p_conversion_date,
                                                      tax_currency_conversion_date),
            tax_currency_conversion_type = Decode(l_rate_ratio,1,p_conversion_type,
                                                      tax_currency_conversion_type),
            tax_currency_conversion_rate = Decode(l_rate_ratio,1,p_conversion_rate,
                                                      tax_currency_conversion_rate),
            tax_amt_tax_curr       = l_tax_amt_tax_curr,
            taxable_amt_tax_curr   = l_taxable_amt_tax_curr,
            cal_tax_amt_tax_curr   = l_cal_tax_amt_tax_curr
    WHERE  tax_line_id = p_tax_line_id_tbl(i);
  END LOOP;
  IF (g_level_statement >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.update_zx_lines.END',
                   'ZX_TDS_TAX_ROUNDING_PKG: update_zx_lines(-)'||p_return_status);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.update_zx_lines',
                      p_error_buffer);
    END IF;
END update_zx_lines;
---------------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  perform_rounding
--
--  DESCRIPTION
--  This procedure is the entry point to tax rounding proccess
--  It performs  rounding for each tax line in the document
--  according to the rounding info specified
--
--  Rewritten by lxzhang for bug fix 5417887

PROCEDURE perform_rounding(
           p_event_class_rec  IN     ZX_API_PUB.EVENT_CLASS_REC_TYPE,
           p_return_status       OUT NOCOPY VARCHAR2,
           p_error_buffer        OUT NOCOPY VARCHAR2
         )
IS

  l_prev_hdr_grp_rec              HDR_GRP_REC_TYPE;
  l_curr_hdr_grp_rec              HDR_GRP_REC_TYPE;
  i                               BINARY_INTEGER;
  l_count                         NUMBER;
  l_same_tax                      VARCHAR2(1);
  l_sum_unrnd_tax_amt             NUMBER;
  l_sum_rnd_tax_amt               NUMBER;
  l_sum_rnd_tax_curr              NUMBER;
  l_sum_rnd_funcl_curr            NUMBER;
  l_tax_rate_rec                  ZX_TDS_UTILITIES_PKG.ZX_RATE_INFO_REC_TYPE;
  l_rate_type_code                ZX_RATES_B.RATE_TYPE_CODE%TYPE;

  l_tax_line_id_tbl               TAX_LINE_ID_TBL;
  l_internal_organization_id_tbl  INTERNAL_ORGANIZATION_ID_TBL;
  l_manually_entered_flag_tbl     MANUALLY_ENTERED_FLAG_TBL;
  l_tax_id_tbl                    TAX_ID_TBL;
  l_tax_regime_code_tbl           TAX_REGIME_CODE_TBL;
  l_tax_tbl                       TAX_TBL;
  l_tax_status_code_tbl           TAX_STATUS_CODE_TBL;
  l_tax_rate_code_tbl             TAX_RATE_CODE_TBL;
  l_tax_rate_tbl                  TAX_RATE_TBL;
  l_tax_rate_id_tbl               TAX_RATE_ID_TBL;
  l_tax_jurisdiction_code_tbl     TAX_JURISDICTION_CODE_TBL;
  l_taxable_basis_formula_tbl     TAXABLE_BASIS_FORMULA_TBL;
  l_tax_calculation_formula_tbl   TAX_CALCULATION_FORMULA_TBL;
  l_tax_amt_included_flag_tbl     TAX_AMT_INCLUDED_FLAG_TBL;
  l_compounding_tax_flag_tbl      COMPOUNDING_TAX_FLAG_TBL;
  l_historical_flag_tbl           HISTORICAL_FLAG_TBL;
  l_self_assessed_flag_tbl        SELF_ASSESSED_FLAG_TBL;
  l_overridden_flag_tbl           OVERRIDDEN_FLAG_TBL;
  l_Cop_From_Other_Doc_Flag_tbl   COP_FROM_OTHER_DOC_FLAG_TBL;
  l_assoc_child_frozen_flag_tbl   ASSOC_CHILD_FROZEN_FLAG_TBL;
  l_tax_only_line_flag_tbl        TAX_ONLY_LINE_FLAG_TBL;
  l_mrc_tax_line_flag_tbl         MRC_TAX_LINE_FLAG_TBL;
  l_reporting_only_flag_tbl       REPORTING_ONLY_FLAG_TBL;
  l_applied_from_applic_id_tbl    APPLIED_FROM_APPLIC_ID_TBL;
  l_applied_from_evnt_cls_cd_tbl  APPLIED_FROM_EVNT_CLS_CD_TBL;
  l_applied_from_entity_code_tbl  APPLIED_FROM_ENTITY_CODE_TBL;
  l_applied_from_trx_id_tbl       APPLIED_FROM_TRX_ID_TBL;
  l_applied_from_line_id_tbl      APPLIED_FROM_LINE_ID_TBL;
  l_adjusted_doc_applic_id_tbl    ADJUSTED_DOC_APPLIC_ID_TBL;
  l_adjusted_doc_entity_code_tbl  ADJUSTED_DOC_ENTITY_CODE_TBL;
  l_adjusted_doc_evnt_cls_cd_tbl  ADJUSTED_DOC_EVNT_CLS_CD_TBL;
  l_adjusted_doc_trx_id_tbl       ADJUSTED_DOC_TRX_ID_TBL;
  l_applied_to_applic_id_tbl      APPLIED_TO_APPLIC_ID_TBL;
  l_applied_to_evnt_cls_cd_tbl    APPLIED_TO_EVNT_CLS_CD_TBL;
  l_applied_to_entity_code_tbl    APPLIED_TO_ENTITY_CODE_TBL;
  l_applied_to_trx_id_tbl         APPLIED_TO_TRX_ID_TBL;
  l_applied_to_line_id_tbl        APPLIED_TO_LINE_ID_TBL;
  l_tax_exemption_id_tbl          TAX_EXEMPTION_ID_TBL;
  l_tax_rate_before_exempt_tbl    RATE_BEFORE_EXEMPTION_TBL;
  l_rate_name_before_exempt_tbl   RATE_NAME_BEFORE_EXEMPTION_TBL;
  l_exempt_rate_modifier_tbl      EXEMPT_RATE_MODIFIER_TBL;
  l_exempt_certificate_num_tbl    EXEMPT_CERTIFICATE_NUM_TBL;
  l_exempt_reason_tbl             EXEMPT_REASON_TBL;
  l_exempt_reason_code_tbl        EXEMPT_REASON_CODE_TBL;
  l_tax_exception_id_tbl          TAX_EXCEPTION_ID_TBL;
  l_tax_rate_before_except_tbl    RATE_BEFORE_EXCEPTION_TBL;
  l_rate_name_before_except_tbl   RATE_NAME_BEFORE_EXCEPTION_TBL;
  l_exception_rate_tbl            EXCEPTION_RATE_TBL;
  l_ledger_id_tbl                 LEDGER_ID_TBL;
  l_min_acct_unit_tbl             MIN_ACCT_UNIT_TBL;
  l_precision_tbl                 PRECISION_TBL;
  l_trx_currency_code_tbl         TRX_CURRENCY_CODE_TBL;
  l_tax_currency_code_tbl         TAX_CURRENCY_CODE_TBL;
  l_tax_curr_conv_date_tbl        TAX_CURR_CONV_DATE_TBL;
  l_tax_curr_conv_type_tbl        TAX_CURR_CONV_TYPE_TBL;
  l_tax_curr_conv_rate_tbl        TAX_CURR_CONV_RATE_TBL;
  l_tax_amt_tbl                   TAX_AMT_TBL;
  l_taxable_amt_tbl               TAXABLE_AMT_TBL;
  l_orig_tax_amt_tbl              TAX_AMT_TBL;
  l_orig_tax_amt_tax_curr_tbl     TAX_AMT_TBL;
  l_orig_taxable_amt_tbl          TAXABLE_AMT_TBL;
  l_orig_taxable_amt_tax_cur_tbl  TAXABLE_AMT_TBL;
  l_cal_tax_amt_tbl               CAL_TAX_AMT_TBL;
  l_tax_amt_tax_curr_tbl          TAX_AMT_TAX_CURR_TBL;
  l_taxable_amt_tax_curr_tbl      TAXABLE_AMT_TAX_CURR_TBL;
  l_cal_tax_amt_tax_curr_tbl      CAL_TAX_AMT_TAX_CURR_TBL;
  l_rounding_rule_tbl             ROUNDING_RULE_TBL;
  l_unrounded_taxable_amt_tbl     UNROUNDED_TAXABLE_AMT_TBL;
  l_unrounded_tax_amt_tbl         UNROUNDED_TAX_AMT_TBL;
  l_currency_conversion_type_tbl  CURRENCY_CONVERSION_TYPE_TBL;
  l_currency_conversion_rate_tbl  CURRENCY_CONVERSION_RATE_TBL;
  l_currency_conversion_date_tbl  CURRENCY_CONVERSION_DATE_TBL;
  l_tax_amt_funcl_curr_tbl        TAX_AMT_FUNCL_CURR_TBL;
  l_taxable_amt_funcl_curr_tbl    TAXABLE_AMT_FUNCL_CURR_TBL;
  l_cal_tax_amt_funcl_curr_tbl    CAL_TAX_AMT_FUNCL_CURR_TBL;
  l_prd_total_tax_amt_tbl         PRD_TOTAL_TAX_AMT_TBL;
  l_prd_tot_tax_amt_tax_curr_tbl  PRD_TOTAL_TAX_AMT_TAX_CURR_TBL;
  l_prd_tot_tax_amt_fcl_curr_tbl  PRD_TOTAL_TAX_AMT_FCL_CURR_TBL;
  l_legal_entity_id_tbl           LEGAL_ENTITY_ID_TBL;
  l_establishment_id_tbl          ESTABLISHMENT_ID_TBL;
  l_record_type_code_tbl          RECORD_TYPE_CODE_TBL;
  l_tax_provider_id_tbl           TAX_PROVIDER_ID_TBL;
  l_application_id_tbl            APPLICATION_ID_TBL;
  l_event_class_code_tbl          EVENT_CLASS_CODE_TBL;
  l_entity_code_tbl               ENTITY_CODE_TBL;
  l_trx_id_tbl                    TRX_ID_TBL;
  l_rounding_level_code_tbl       ROUNDING_LEVEL_CODE_TBL;

  l_trx_id			  ZX_LINES.TRX_ID%TYPE; --code changes
  l_application_id                ZX_LINES.APPLICATION_ID%TYPE;
  l_event_class_code              ZX_LINES.EVENT_CLASS_CODE%TYPE;
  l_entity_code                   ZX_LINES.ENTITY_CODE%TYPE;


  CURSOR get_trx_id_csr
  IS
  SELECT DISTINCT
         application_id,
         entity_code,
         event_class_code,
         trx_id
  FROM  ZX_DETAIL_TAX_LINES_GT
  WHERE offset_link_to_tax_line_id IS NULL;

  CURSOR get_round_info_csr
  ( c_trx_id                     ZX_LINES.TRX_ID%TYPE,
    c_application_id             ZX_LINES.APPLICATION_ID%TYPE,
    c_event_class_code           ZX_LINES.EVENT_CLASS_CODE%TYPE,
    c_entity_code                ZX_LINES.ENTITY_CODE%TYPE)
  IS
    SELECT /*+ dynamic_sampling(1) */
           tax_line_id,
           Manually_Entered_Flag,
           tax_id,
           tax_regime_code,
           tax,
           tax_status_code,
           tax_rate_code,
           tax_rate,
           tax_rate_id,
           tax_jurisdiction_code,
           taxable_basis_formula,
           tax_calculation_formula,
           Tax_Amt_Included_Flag,
           compounding_tax_flag,
           historical_flag,
           self_assessed_flag,
           overridden_flag,
           Copied_From_Other_Doc_Flag,
           associated_child_frozen_flag,
           tax_only_line_flag,
           mrc_tax_line_flag,
           reporting_only_flag,
           applied_from_application_id,
           applied_from_event_class_code,
           applied_from_entity_code,
           applied_from_trx_id,
           applied_from_line_id,
           adjusted_doc_application_id,
           adjusted_doc_entity_code,
           adjusted_doc_event_class_code,
           adjusted_doc_trx_id,
           -- applied_to_application_id,
           -- applied_to_event_class_code,
           -- applied_to_entity_code,
           -- applied_to_trx_id,
           -- applied_to_line_id,
           tax_exemption_id,
           tax_rate_before_exemption,
           tax_rate_name_before_exemption,
           exempt_rate_modifier,
           exempt_certificate_number,
           exempt_reason,
           exempt_reason_code,
           tax_exception_id,
           tax_rate_before_exception,
           tax_rate_name_before_exception,
           exception_rate,
           ledger_id,
           legal_entity_id,
           establishment_id,
           record_type_code,
           minimum_accountable_unit,
           precision,
           trx_currency_code,
           tax_currency_code,
           tax_currency_conversion_date,
           tax_currency_conversion_type,
           tax_currency_conversion_rate,
           tax_amt,
           taxable_amt,
           cal_tax_amt,
           tax_amt_tax_curr,
           taxable_amt_tax_curr,
           cal_tax_amt_tax_curr,
           prd_total_tax_amt,
           prd_total_tax_amt_tax_curr,
           prd_total_tax_amt_funcl_curr,
           Rounding_Rule_Code,
           unrounded_taxable_amt,
           unrounded_tax_amt,
           currency_conversion_type,
           currency_conversion_rate,
           currency_conversion_date,
           tax_amt_funcl_curr,
           taxable_amt_funcl_curr,
           cal_tax_amt_funcl_curr,
           tax_provider_id,
           application_id,
           internal_organization_id,
           event_class_code,
           entity_code,
           trx_id,
           rounding_level_code,
           orig_tax_amt,
           orig_taxable_amt,
           orig_tax_amt_tax_curr,
           orig_taxable_amt_tax_curr
     FROM  ZX_DETAIL_TAX_LINES_GT
    WHERE (offset_link_to_tax_line_id IS NULL
           OR
           (offset_link_to_tax_line_id IS NOT NULL AND
	    other_doc_source IN ('APPLIED_FROM', 'ADJUSTED'))) --bug8517610
      AND trx_id = c_trx_id
      AND application_id    = c_application_id
      AND event_class_code  = c_event_class_code
      AND entity_code       = c_entity_code
     ORDER BY
           ledger_id,
           application_id,
           event_class_code,
           entity_code,
           trx_id,
           tax_regime_code,
           tax,
           tax_status_code,
           tax_rate_code,
           tax_rate,
           tax_rate_id,
           tax_jurisdiction_code,
           taxable_basis_formula,
           tax_calculation_formula,
           Tax_Amt_Included_Flag,
           compounding_tax_flag,
           historical_flag,
           self_assessed_flag,
           overridden_flag,
           manually_entered_flag,
           Copied_From_Other_Doc_Flag,
           associated_child_frozen_flag,
           tax_only_line_flag,
           mrc_tax_line_flag,
           reporting_only_flag,
           applied_from_application_id,
           applied_from_event_class_code,
           applied_from_entity_code,
           applied_from_trx_id,
           applied_from_line_id,
           adjusted_doc_application_id,
           adjusted_doc_entity_code,
           adjusted_doc_event_class_code,
           adjusted_doc_trx_id,
           -- applied_to_application_id,
           -- applied_to_event_class_code,
           -- applied_to_entity_code,
           -- applied_to_trx_id,
           -- applied_to_line_id,
           tax_exemption_id,
           tax_rate_before_exemption,
           tax_rate_name_before_exemption,
           exempt_rate_modifier,
           exempt_certificate_number,
           exempt_reason,
           exempt_reason_code,
           tax_exception_id,
           tax_rate_before_exception,
           tax_rate_name_before_exception,
           exception_rate,
           legal_entity_id,
           establishment_id,
           TRUNC(currency_conversion_date),
           currency_conversion_type,
           currency_conversion_rate,
           record_type_code;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.perform_rounding.BEGIN',
                   'ZX_TDS_TAX_ROUNDING_PKG: perform_rounding(+)');
  END IF;

  --
  -- init error buffer and return status
  --
  p_return_status  := FND_API.G_RET_STS_SUCCESS;
  p_error_buffer   := NULL;

  OPEN get_trx_id_csr;
  LOOP
  FETCH get_trx_id_csr INTO
         l_application_id,
         l_entity_code,
         l_event_class_code,
         l_trx_id;
  EXIT WHEN get_trx_id_csr%NOTFOUND;
  --FND_LOG.STRING(g_level_procedure,'Current Trx ID:',l_trx_id);

  --
  -- init tax_currency_info_tbl
  --
--Bug 7483633
 /*g_currency_tbl.DELETE;
  g_tax_curr_conv_rate_tbl.DELETE;*/
  --
  -- init header group record
  --
  init_header_group(l_prev_hdr_grp_rec,
                    p_return_status,
                    p_error_buffer);

  IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RETURN;
  END IF;

  --
  -- init header rounding info table
  --
  g_hdr_rounding_info_tbl.DELETE;

  --
  -- get rounding info
  --

  OPEN get_round_info_csr(
        l_trx_id,
        l_application_id,
        l_event_class_code,
        l_entity_code);
  LOOP
    FETCH get_round_info_csr BULK COLLECT INTO
           l_tax_line_id_tbl,
           l_manually_entered_flag_tbl,
           l_tax_id_tbl,
           l_tax_regime_code_tbl,
           l_tax_tbl,
           l_tax_status_code_tbl,
           l_tax_rate_code_tbl,
           l_tax_rate_tbl,
           l_tax_rate_id_tbl,
           l_tax_jurisdiction_code_tbl,
           l_taxable_basis_formula_tbl,
           l_tax_calculation_formula_tbl,
           l_tax_amt_included_flag_tbl,
           l_compounding_tax_flag_tbl,
           l_historical_flag_tbl,
           l_self_assessed_flag_tbl,
           l_overridden_flag_tbl,
           l_Cop_From_Other_Doc_Flag_tbl,
           l_assoc_child_frozen_flag_tbl,
           l_tax_only_line_flag_tbl,
           l_mrc_tax_line_flag_tbl,
           l_reporting_only_flag_tbl,
           l_applied_from_applic_id_tbl,
           l_applied_from_evnt_cls_cd_tbl,
           l_applied_from_entity_code_tbl,
           l_applied_from_trx_id_tbl,
           l_applied_from_line_id_tbl,
           l_adjusted_doc_applic_id_tbl,
           l_adjusted_doc_entity_code_tbl,
           l_adjusted_doc_evnt_cls_cd_tbl,
           l_adjusted_doc_trx_id_tbl,
           --l_applied_to_applic_id_tbl,
           --l_applied_to_evnt_cls_cd_tbl,
           --l_applied_to_entity_code_tbl,
           --l_applied_to_trx_id_tbl,
           --l_applied_to_line_id_tbl,
           l_tax_exemption_id_tbl,
           l_tax_rate_before_exempt_tbl,
           l_rate_name_before_exempt_tbl,
           l_exempt_rate_modifier_tbl,
           l_exempt_certificate_num_tbl,
           l_exempt_reason_tbl,
           l_exempt_reason_code_tbl,
           l_tax_exception_id_tbl,
           l_tax_rate_before_except_tbl,
           l_rate_name_before_except_tbl,
           l_exception_rate_tbl,
           l_ledger_id_tbl,
           l_legal_entity_id_tbl,
           l_establishment_id_tbl,
           l_record_type_code_tbl,
           l_min_acct_unit_tbl,
           l_precision_tbl,
           l_trx_currency_code_tbl,
           l_tax_currency_code_tbl,
           l_tax_curr_conv_date_tbl,
           l_tax_curr_conv_type_tbl,
           l_tax_curr_conv_rate_tbl,
           l_tax_amt_tbl,
           l_taxable_amt_tbl,
           l_cal_tax_amt_tbl,
           l_tax_amt_tax_curr_tbl,
           l_taxable_amt_tax_curr_tbl,
           l_cal_tax_amt_tax_curr_tbl,
           l_prd_total_tax_amt_tbl,
           l_prd_tot_tax_amt_tax_curr_tbl,
           l_prd_tot_tax_amt_fcl_curr_tbl,
           l_rounding_rule_tbl,
           l_unrounded_taxable_amt_tbl,
           l_unrounded_tax_amt_tbl,
           l_currency_conversion_type_tbl,
           l_currency_conversion_rate_tbl,
           l_currency_conversion_date_tbl,
           l_tax_amt_funcl_curr_tbl,
           l_taxable_amt_funcl_curr_tbl,
           l_cal_tax_amt_funcl_curr_tbl,
           l_tax_provider_id_tbl,
           l_application_id_tbl,
           l_internal_organization_id_tbl,
           l_event_class_code_tbl,
           l_entity_code_tbl,
           l_trx_id_tbl,
           l_rounding_level_code_tbl,
           l_orig_tax_amt_tbl,
           l_orig_taxable_amt_tbl,
           l_orig_tax_amt_tax_curr_tbl,
           l_orig_taxable_amt_tax_cur_tbl
      LIMIT C_LINES_PER_COMMIT;

    FOR i IN 1.. NVL(l_tax_line_id_tbl.COUNT, 0) LOOP

      --
      -- perform rounding for each line using LINE level rounding
      --

      do_rounding(
             l_tax_id_tbl(i),
             l_tax_rate_id_tbl(i),
             l_tax_amt_tbl(i),
             l_taxable_amt_tbl(i),
             l_orig_tax_amt_tbl(i),
             l_orig_taxable_amt_tbl(i),
             l_orig_tax_amt_tax_curr_tbl(i),
             l_orig_taxable_amt_tax_cur_tbl(i),
             l_cal_tax_amt_tbl(i),
             l_tax_amt_tax_curr_tbl(i),
             l_taxable_amt_tax_curr_tbl(i),
             l_cal_tax_amt_tax_curr_tbl(i),
             l_tax_amt_funcl_curr_tbl(i),
             l_taxable_amt_funcl_curr_tbl(i),
             l_cal_tax_amt_funcl_curr_tbl(i),
             l_trx_currency_code_tbl(i),
             l_tax_currency_code_tbl(i),
             l_tax_curr_conv_type_tbl(i),
             l_tax_curr_conv_rate_tbl(i),
             l_tax_curr_conv_date_tbl(i),
             l_currency_conversion_type_tbl(i),
             l_currency_conversion_rate_tbl(i),
             l_currency_conversion_date_tbl(i),
             l_rounding_rule_tbl(i),
             l_ledger_id_tbl(i),
             l_min_acct_unit_tbl(i),
             l_precision_tbl(i),
             l_application_id_tbl(i),
             l_internal_organization_id_tbl(i),
             p_event_class_rec.event_class_mapping_id,
             l_tax_calculation_formula_tbl(i),
             l_tax_rate_tbl(i),
             l_prd_total_tax_amt_tbl(i),
             l_prd_tot_tax_amt_tax_curr_tbl(i),
             l_prd_tot_tax_amt_fcl_curr_tbl(i),
             l_unrounded_taxable_amt_tbl(i),
             l_unrounded_tax_amt_tbl(i),
             l_mrc_tax_line_flag_tbl(i),
             l_tax_provider_id_tbl(i),
             p_return_status,
             p_error_buffer);

      IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        EXIT;
      END IF;

      IF l_rounding_level_code_tbl(i) = 'HEADER' THEN

        --
        -- get header grouping criteria of the current record
        --
        l_curr_hdr_grp_rec.application_id             := l_application_id_tbl(i);
        l_curr_hdr_grp_rec.event_class_code           := l_event_class_code_tbl(i);
        l_curr_hdr_grp_rec.entity_code                := l_entity_code_tbl(i);
        l_curr_hdr_grp_rec.trx_id                     := l_trx_id_tbl(i);
        l_curr_hdr_grp_rec.tax_regime_code              :=
                               l_tax_regime_code_tbl(i);
        l_curr_hdr_grp_rec.tax                          := l_tax_tbl(i);
        l_curr_hdr_grp_rec.tax_status_code              := l_tax_status_code_tbl(i);
        l_curr_hdr_grp_rec.tax_rate_code                := l_tax_rate_code_tbl(i);
        l_curr_hdr_grp_rec.tax_rate                     := l_tax_rate_tbl(i);
        l_curr_hdr_grp_rec.tax_rate_id                  := l_tax_rate_id_tbl(i);
        l_curr_hdr_grp_rec.tax_jurisdiction_code        :=
                               l_tax_jurisdiction_code_tbl(i);
        l_curr_hdr_grp_rec.taxable_basis_formula        :=
                               l_taxable_basis_formula_tbl(i);
        l_curr_hdr_grp_rec.tax_calculation_formula      :=
                               l_tax_calculation_formula_tbl(i);
        l_curr_hdr_grp_rec.Tax_Amt_Included_Flag        :=
                               l_Tax_Amt_Included_Flag_tbl(i);
        l_curr_hdr_grp_rec.compounding_tax_flag         :=
                               l_compounding_tax_flag_tbl(i);
        l_curr_hdr_grp_rec.historical_flag              :=
                               l_historical_flag_tbl(i);
        l_curr_hdr_grp_rec.self_assessed_flag           :=
                               l_self_assessed_flag_tbl(i);
        l_curr_hdr_grp_rec.overridden_flag              :=
                               l_overridden_flag_tbl(i);
        l_curr_hdr_grp_rec.manually_entered_flag        :=
                               l_manually_entered_flag_tbl(i);
        l_curr_hdr_grp_rec.Copied_From_Other_Doc_Flag     :=
                               l_Cop_From_Other_Doc_Flag_tbl(i);
        l_curr_hdr_grp_rec.associated_child_frozen_flag :=
                               l_assoc_child_frozen_flag_tbl(i);
        l_curr_hdr_grp_rec.tax_only_line_flag           :=
                               l_tax_only_line_flag_tbl(i);
        l_curr_hdr_grp_rec.mrc_tax_line_flag   :=
                               l_mrc_tax_line_flag_tbl(i);
        l_curr_hdr_grp_rec.reporting_only_flag :=
                               l_reporting_only_flag_tbl(i);
        l_curr_hdr_grp_rec.applied_from_application_id  :=
                               l_applied_from_applic_id_tbl(i);
        l_curr_hdr_grp_rec.applied_from_event_class_code :=
                               l_applied_from_evnt_cls_cd_tbl(i);
        l_curr_hdr_grp_rec.applied_from_entity_code     :=
                               l_applied_from_entity_code_tbl(i);
        l_curr_hdr_grp_rec.applied_from_trx_id          :=
                               l_applied_from_trx_id_tbl(i);
        l_curr_hdr_grp_rec.applied_from_line_id          :=
                               l_applied_from_line_id_tbl(i);
        l_curr_hdr_grp_rec.adjusted_doc_application_id  :=
                               l_adjusted_doc_applic_id_tbl(i);
        l_curr_hdr_grp_rec.adjusted_doc_entity_code     :=
                               l_adjusted_doc_entity_code_tbl(i);
        l_curr_hdr_grp_rec.adjusted_doc_event_class_code :=
                               l_adjusted_doc_evnt_cls_cd_tbl(i);
        l_curr_hdr_grp_rec.adjusted_doc_trx_id          :=
                               l_adjusted_doc_trx_id_tbl(i);
        --l_curr_hdr_grp_rec.applied_to_application_id    :=
        --                       l_applied_to_applic_id_tbl(i);
        --l_curr_hdr_grp_rec.applied_to_event_class_code  :=
        --                       l_applied_to_evnt_cls_cd_tbl(i);
        --l_curr_hdr_grp_rec.applied_to_entity_code       :=
        --                       l_applied_to_entity_code_tbl(i);
        --l_curr_hdr_grp_rec.applied_to_trx_id            :=
        --                       l_applied_to_trx_id_tbl(i);
        --l_curr_hdr_grp_rec.applied_to_line_id            :=
        --                       l_applied_to_line_id_tbl(i);
        l_curr_hdr_grp_rec.tax_exemption_id             :=
                               l_tax_exemption_id_tbl(i);
        l_curr_hdr_grp_rec.tax_rate_before_exemption    :=
                               l_tax_rate_before_exempt_tbl(i);
        l_curr_hdr_grp_rec.tax_rate_name_before_exemption:=
                               l_rate_name_before_exempt_tbl(i);
        l_curr_hdr_grp_rec.exempt_rate_modifier         :=
                               l_exempt_rate_modifier_tbl(i);
        l_curr_hdr_grp_rec.exempt_certificate_number    :=
                               l_exempt_certificate_num_tbl(i);
        l_curr_hdr_grp_rec.exempt_reason                :=
                               l_exempt_reason_tbl(i);
        l_curr_hdr_grp_rec.exempt_reason_code           :=
                               l_exempt_reason_code_tbl(i);
        l_curr_hdr_grp_rec.tax_exception_id             :=
                               l_tax_exception_id_tbl(i);
        l_curr_hdr_grp_rec.tax_rate_before_exception               :=
                               l_tax_rate_before_except_tbl(i);
        l_curr_hdr_grp_rec.tax_rate_name_before_exception          :=
                               l_rate_name_before_except_tbl(i);
        l_curr_hdr_grp_rec.exception_rate      :=
                               l_exception_rate_tbl(i);
        l_curr_hdr_grp_rec.ledger_id         := l_ledger_id_tbl(i);
        l_curr_hdr_grp_rec.legal_entity_id   := l_legal_entity_id_tbl(i);
        l_curr_hdr_grp_rec.establishment_id  := l_establishment_id_tbl(i);
        l_curr_hdr_grp_rec.currency_conversion_date   :=
                               l_currency_conversion_date_tbl(i);
        l_curr_hdr_grp_rec.currency_conversion_type   :=
                               l_currency_conversion_type_tbl(i);
        l_curr_hdr_grp_rec.currency_conversion_rate   :=
                               l_currency_conversion_rate_tbl(i);
        l_curr_hdr_grp_rec.record_type_code    :=
                               l_record_type_code_tbl(i);

        --
        -- check whether it is in the same group of tax for
        -- header rounding level.  l_same_tax is used for header
        -- rounding level only
        --
        determine_header_group(l_prev_hdr_grp_rec,
                               l_curr_hdr_grp_rec,
                               l_same_tax,
                               p_return_status,
                               p_error_buffer);

        IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          EXIT;
        END IF;

        -- when not in the same rounding group
        IF l_same_tax = 'N' THEN
          --
          -- this is the new group of tax
          -- need to init the sum for this group
          --
          IF p_event_class_rec.tax_event_type_code = 'CREATE' THEN
            process_tax_line_create(
                 l_sum_unrnd_tax_amt,
                 l_sum_rnd_tax_amt,
                 l_sum_rnd_tax_curr,
                 l_sum_rnd_funcl_curr,
                 p_return_status,
                 p_error_buffer);
            IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              EXIT;
            END IF;
          ELSIF (p_event_class_rec.tax_event_type_code = 'UPDATE' OR
                 p_event_class_rec.tax_event_type_code = 'OVERRIDE_TAX') THEN
            process_tax_line_upd_override(
                    l_curr_hdr_grp_rec,
                    l_sum_unrnd_tax_amt,
                    l_sum_rnd_tax_amt,
                    l_sum_rnd_tax_curr,
                    l_sum_rnd_funcl_curr,
                    p_event_class_rec,
                    p_return_status,
                    p_error_buffer);
            IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              EXIT;
            END IF;
          END IF;

          -- following reset has been done in the update_header_rounding_info()
          -- reset the current rounding group to prev rounding group
          -- l_prev_hdr_grp_rec := l_curr_hdr_grp_rec;

        END IF;



        --
        -- update  header rounding info to new values if this
        -- is the new header rounding group
        --
        update_header_rounding_info(
                                      l_tax_line_id_tbl(i),
                                      l_tax_id_tbl(i),
                                      l_rounding_rule_tbl(i),
                                      l_min_acct_unit_tbl(i),
                                      l_precision_tbl(i),
                                      l_unrounded_tax_amt_tbl(i),
                                      l_tax_amt_tbl(i),
                                      l_tax_amt_tax_curr_tbl(i),
                                      l_tax_amt_funcl_curr_tbl(i),
                                      l_taxable_amt_tax_curr_tbl(i),
                                      l_taxable_amt_funcl_curr_tbl(i),
                                      l_tax_curr_conv_rate_tbl(i),
                                      l_currency_conversion_rate_tbl(i),
                                      l_prev_hdr_grp_rec,
                                      l_curr_hdr_grp_rec,
                                      l_same_tax,
                                      l_sum_unrnd_tax_amt,
                                      l_sum_rnd_tax_amt,
                                      l_sum_rnd_tax_curr,
                                      l_sum_rnd_funcl_curr,
                                      l_ledger_id_tbl(i),
                                      p_return_status,
                                      p_error_buffer);

        IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          EXIT;
        END IF;
      END IF;
      --
      -- be sure these columns  are not null for
      -- non manually entered tax line
      --
      IF l_manually_entered_flag_tbl(i)  = 'N' THEN
        IF (l_tax_amt_tax_curr_tbl(i) IS NULL OR
            l_taxable_amt_tax_curr_tbl(i) IS NULL ) THEN
          -- get l_rate_type_code

          IF ZX_TDS_UTILITIES_PKG.g_tax_rate_info_tbl.EXISTS(l_tax_rate_id_tbl(i)) THEN

            l_rate_type_code :=
               ZX_TDS_UTILITIES_PKG.g_tax_rate_info_tbl(l_tax_rate_id_tbl(i)).rate_type_code;
          ELSE
            ZX_TDS_UTILITIES_PKG.get_tax_rate_info(
               p_tax_rate_id      => l_tax_rate_id_tbl(i),
               p_tax_rate_rec     => l_tax_rate_rec,
               p_return_status    => p_return_status,
               p_error_buffer     => p_error_buffer);


            IF p_return_status = FND_API.G_RET_STS_SUCCESS THEN
              l_rate_type_code := l_tax_rate_rec.rate_type_code;
            END IF;
        END IF;

        --Bug 7109899
         IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          EXIT;
         END IF;
        END IF;

        chk_mandatory_col_after_round(
               l_trx_currency_code_tbl(i),
               l_tax_currency_code_tbl(i),
               l_tax_amt_tbl(i),
               l_tax_amt_tax_curr_tbl(i),
               l_taxable_amt_tbl(i),
               l_taxable_amt_tax_curr_tbl(i),
               l_mrc_tax_line_flag_tbl(i),
               l_rate_type_code,
               p_return_status,
               p_error_buffer);

        IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          EXIT;
        END IF;
      END IF;

    END LOOP;

    --Bug 7109899

   IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     RETURN;
   END IF;

    --
    -- bulk update the current rows processed
    -- before fetch the next set of rows
    --

    update_detail_tax_lines_gt(
       p_min_acct_unit_tbl              =>  l_min_acct_unit_tbl,
       p_precision_tbl                  =>  l_precision_tbl,
       p_tax_currency_code_tbl          =>  l_tax_currency_code_tbl,
       p_tax_curr_conv_rate_tbl         =>  l_tax_curr_conv_rate_tbl,
       p_tax_amt_tbl                    =>  l_tax_amt_tbl,
       p_taxable_amt_tbl                =>  l_taxable_amt_tbl,
       p_tax_amt_tax_curr_tbl           =>  l_tax_amt_tax_curr_tbl,
       p_taxable_amt_tax_curr_tbl       =>  l_taxable_amt_tax_curr_tbl,
       p_tax_amt_funcl_curr_tbl         =>  l_tax_amt_funcl_curr_tbl,
       p_taxable_amt_funcl_curr_tbl     =>  l_taxable_amt_funcl_curr_tbl,
       p_prd_total_tax_amt_tbl          =>  l_prd_total_tax_amt_tbl,
       p_prd_tot_tax_amt_tax_curr_tbl   =>  l_prd_tot_tax_amt_tax_curr_tbl,
       p_prd_tot_tax_amt_fcl_curr_tbl   =>  l_prd_tot_tax_amt_fcl_curr_tbl,
       p_cal_tax_amt_funcl_curr_tbl     =>  l_cal_tax_amt_funcl_curr_tbl,
       p_orig_tax_amt_tax_curr_tbl      =>  l_orig_tax_amt_tax_curr_tbl,
       p_orig_taxable_amt_tax_cur_tbl   =>  l_orig_taxable_amt_tax_cur_tbl,
       p_tax_line_id_tbl                =>  l_tax_line_id_tbl,
       p_return_status                  =>  p_return_status,
       p_error_buffer                   =>  p_error_buffer);

    IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      EXIT;
    END IF;

    EXIT WHEN  get_round_info_csr%NOTFOUND;

  END LOOP;

  CLOSE get_round_info_csr;
  IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RETURN;
  END IF;

  --
  -- now adjust the rounding differences if it is HEADER rounding level
  -- for tax amount in trx currency, tax currrency and functional
  -- currency
  --
  adjust_rounding_diff(
         p_return_status,
         p_error_buffer);
  IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RETURN;
  END IF;
  END LOOP;

  IF (g_level_procedure >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.perform_rounding.END',
                   'ZX_TDS_TAX_ROUNDING_PKG: perform_rounding(-)'||p_return_status);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.perform_rounding',
                      p_error_buffer);
    END IF;

END perform_rounding;

---------------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  convert_and_round_for_curr
--
--  DESCRIPTION
--  This procedure converts tax amount and taxable amount to the currency
--  specified and then performs line level rounding
--

PROCEDURE convert_and_round_for_curr(
            p_curr_conv_rate          IN            ZX_LINES.CURRENCY_CONVERSION_RATE%TYPE,
            p_rounded_tax_amt         IN            ZX_LINES.TAX_AMT%TYPE,
            p_rounded_taxable_amt     IN            ZX_LINES.TAXABLE_AMT%TYPE,
            p_unrounded_tax_amt       IN            ZX_LINES.TAX_AMT%TYPE,
            p_unrounded_taxable_amt   IN            ZX_LINES.TAXABLE_AMT%TYPE,
            p_conv_rnd_tax_amt_curr      OUT NOCOPY ZX_LINES.TAX_AMT_TAX_CURR%TYPE,
            p_conv_rnd_taxable_amt_curr  OUT NOCOPY ZX_LINES.TAXABLE_AMT_TAX_CURR%TYPE,
            p_ledger_id               IN            ZX_LINES.LEDGER_ID%TYPE,
            p_tax_calculation_formula IN            ZX_LINES.TAX_CALCULATION_FORMULA%TYPE,
            p_tax_rate                IN            ZX_LINES.TAX_RATE%TYPE,
            p_tax_rate_id             IN            ZX_RATES_B.TAX_RATE_ID%TYPE,
            p_return_status              OUT NOCOPY VARCHAR2,
            p_error_buffer               OUT NOCOPY VARCHAR2
         )
IS

BEGIN

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.convert_and_round_for_curr.BEGIN',
                   'ZX_TDS_TAX_ROUNDING_PKG: convert_and_round_for_curr(+)');
  END IF;

  --
  -- init return status
  --
  p_return_status  := FND_API.G_RET_STS_SUCCESS;

  -- convert and round for functional currency
  --
  IF p_rounded_tax_amt <> 0 THEN
    --
    -- if current rounded tax amt is zero, the tax amt in
    -- functional currency is set to zero already, no need
    -- to do anything in this case, otherwise, need to convert
    -- with the given rate and round
    --
    conv_rnd_tax_funcl_curr(
                        p_curr_conv_rate,
                        p_unrounded_tax_amt,
                        p_conv_rnd_tax_amt_curr,
                        p_ledger_id,
                        p_return_status,
                        p_error_buffer);
    IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RETURN;
    END IF;
  END IF;
  IF p_rounded_taxable_amt  <> 0 THEN
    --
    -- if current rounded taxable amt is zero, the taxable amt in
    -- functional currency is set to zero already, no need
    -- to do anything in this case, otherwise, need to convert
    -- with the given rate and round
    --
    conv_rnd_taxable_funcl_curr(
                        p_curr_conv_rate,
                        p_unrounded_taxable_amt,
                        p_conv_rnd_taxable_amt_curr,
                        p_ledger_id,
                        p_tax_calculation_formula,
                        p_tax_rate,
                        p_tax_rate_id,
                        p_conv_rnd_tax_amt_curr,
                        p_return_status,
                        p_error_buffer);
    IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RETURN;
    END IF;
  END IF;   -- end functional currency

  IF (g_level_procedure >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.convert_and_round_for_curr.END',
                   'ZX_TDS_TAX_ROUNDING_PKG: convert_and_round_for_curr(-)'||p_return_status);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.convert_and_round_for_curr',
                      p_error_buffer);
    END IF;
END convert_and_round_for_curr;

---------------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  convert_and_round_lin_lvl_curr
--
--  DESCRIPTION
--  This procedure performs line level rounding for tax amount and taxable
--  amount in functional currency or other currency when the
--  conversion rate is provided from product
--

PROCEDURE convert_and_round_lin_lvl_curr(
           p_conversion_rate  IN            NUMBER,
           p_conversion_type  IN            VARCHAR2,
           p_conversion_date  IN            DATE,
           p_event_class_rec  IN            ZX_API_PUB.EVENT_CLASS_REC_TYPE,
           p_return_status       OUT NOCOPY VARCHAR2,
           p_error_buffer        OUT NOCOPY VARCHAR2
         )
IS

  i                               BINARY_INTEGER;
  l_count                         NUMBER;

  l_tax_line_id_tbl               TAX_LINE_ID_TBL;
  l_tax_rate_tbl                  TAX_RATE_TBL;
  l_tax_rate_id_tbl               TAX_RATE_ID_TBL;
  l_tax_calculation_formula_tbl   TAX_CALCULATION_FORMULA_TBL;
  l_ledger_id_tbl                 LEDGER_ID_TBL;
  l_trx_currency_code_tbl         TRX_CURRENCY_CODE_TBL;
  l_rounding_level_tbl            ROUNDING_LEVEL_TBL;
  l_currency_conversion_rate_tbl  CURRENCY_CONVERSION_RATE_TBL;
  l_tax_amt_tbl                   TAX_AMT_TBL;
  l_taxable_amt_tbl               TAXABLE_AMT_TBL;
  l_cal_tax_amt_tbl               CAL_TAX_AMT_TBL;
  l_unrounded_taxable_amt_tbl     UNROUNDED_TAXABLE_AMT_TBL;
  l_unrounded_tax_amt_tbl         UNROUNDED_TAX_AMT_TBL;
  l_tax_amt_funcl_curr_tbl        TAX_AMT_FUNCL_CURR_TBL;
  l_taxable_amt_funcl_curr_tbl    TAXABLE_AMT_FUNCL_CURR_TBL;
  l_cal_tax_amt_funcl_curr_tbl    CAL_TAX_AMT_FUNCL_CURR_TBL;

  CURSOR get_round_line_level_curr_csr
    (c_trx_id                     ZX_LINES.TRX_ID%TYPE,
     c_application_id             ZX_LINES.APPLICATION_ID%TYPE,
     c_event_class_code           ZX_LINES.EVENT_CLASS_CODE%TYPE,
     c_entity_code                ZX_LINES.ENTITY_CODE%TYPE)
  IS
    SELECT tax_line_id,
           tax_rate,
           tax_rate_id,
           tax_calculation_formula,
           ledger_id,
           trx_currency_code,
           Rounding_Level_Code,
           currency_conversion_rate,
           tax_amt,
           taxable_amt,
           cal_tax_amt,
           unrounded_taxable_amt,
           unrounded_tax_amt,
           tax_amt_funcl_curr,
           taxable_amt_funcl_curr,
           cal_tax_amt_funcl_curr
     FROM  ZX_LINES
      WHERE trx_id            = c_trx_id           AND
            application_id    = c_application_id   AND
            event_class_code  = c_event_class_code AND
            entity_code       = c_entity_code      AND
            tax_provider_id IS NULL                AND
            offset_link_to_tax_line_id IS NULL     AND
            mrc_tax_line_flag = 'N';

BEGIN

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.convert_and_round_lin_lvl_curr.BEGIN',
                   'ZX_TDS_TAX_ROUNDING_PKG: convert_and_round_lin_lvl_curr(+)');
  END IF;

  --
  -- init return status
  --
  p_return_status  := FND_API.G_RET_STS_SUCCESS;

  --
  -- get amount columns and other rounding info
  --
  OPEN get_round_line_level_curr_csr(
                               p_event_class_rec.trx_id,
                               p_event_class_rec.application_id,
                               p_event_class_rec.event_class_code,
                               p_event_class_rec.entity_code);
  LOOP
    FETCH get_round_line_level_curr_csr BULK COLLECT INTO
           l_tax_line_id_tbl,
           l_tax_rate_tbl,
           l_tax_rate_id_tbl,
           l_tax_calculation_formula_tbl,
           l_ledger_id_tbl,
           l_trx_currency_code_tbl,
           l_rounding_level_tbl,
           l_currency_conversion_rate_tbl,
           l_tax_amt_tbl,
           l_taxable_amt_tbl,
           l_cal_tax_amt_tbl,
           l_unrounded_taxable_amt_tbl,
           l_unrounded_tax_amt_tbl,
           l_tax_amt_funcl_curr_tbl,
           l_taxable_amt_funcl_curr_tbl,
           l_cal_tax_amt_funcl_curr_tbl
      LIMIT C_LINES_PER_COMMIT;


    l_count := l_tax_line_id_tbl.COUNT;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.convert_and_round_lin_lvl_curr',
                       'number of rows fetched = ' || to_char(l_count));
    END IF;

    IF l_count > 0 THEN

      FOR i IN 1.. l_count LOOP

        --
        -- perform rounding for each line using LINE level rounding
        --

        convert_and_round_for_curr(
                       p_conversion_rate,
                       l_tax_amt_tbl(i),
                       l_taxable_amt_tbl(i),
                       l_unrounded_tax_amt_tbl(i),
                       l_unrounded_taxable_amt_tbl(i),
                       l_tax_amt_funcl_curr_tbl(i),
                       l_taxable_amt_funcl_curr_tbl(i),
                       l_ledger_id_tbl(i),
                       l_tax_calculation_formula_tbl(i),
                       l_tax_rate_tbl(i),
                       l_tax_rate_id_tbl(i),
                       p_return_status,
                       p_error_buffer);

        IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          EXIT;
        END IF;
      END LOOP;

      IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        EXIT;
      END IF;

      --
      -- bulk update the current rows processed
      -- before fetch the next set of rows
      --

      -- update zx_lines
      --
      update_zx_lines(
                 p_conversion_rate,
                 p_conversion_type,
                 p_conversion_date,
                 l_tax_amt_funcl_curr_tbl,
                 l_taxable_amt_funcl_curr_tbl,
                 l_cal_tax_amt_funcl_curr_tbl,
                 l_tax_line_id_tbl,
                 p_return_status,
                 p_error_buffer);

      IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        EXIT;
      END IF;

    ELSE
      --
      -- no more records to process
      --
      CLOSE get_round_line_level_curr_csr;
      EXIT;
    END IF;  -- end of count > 0
  END LOOP;

  IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    CLOSE get_round_line_level_curr_csr;
    RETURN;
  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.convert_and_round_lin_lvl_curr.END',
                   'ZX_TDS_TAX_ROUNDING_PKG: convert_and_round_lin_lvl_curr(-)'||p_return_status);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    IF get_round_line_level_curr_csr%ISOPEN THEN
      CLOSE get_round_line_level_curr_csr;
    END IF;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.convert_and_round_lin_lvl_curr',
                      p_error_buffer);
    END IF;

END convert_and_round_lin_lvl_curr;

---------------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  convert_and_round_hdr_lvl_curr
--
--  DESCRIPTION
--  This procedure performs header level rounding for tax amount and
--  taxable amount in functional currency or other currency when the
--  conversion rate is provided from product
--

PROCEDURE convert_and_round_hdr_lvl_curr(
           p_conversion_rate  IN            NUMBER,
           p_conversion_type  IN            VARCHAR2,
           p_conversion_date  IN            DATE,
           p_event_class_rec  IN            ZX_API_PUB.EVENT_CLASS_REC_TYPE,
           p_return_status       OUT NOCOPY VARCHAR2,
           p_error_buffer        OUT NOCOPY VARCHAR2
         )
IS

  l_prev_hdr_grp_rec              HDR_GRP_REC_TYPE;
  l_curr_hdr_grp_rec              HDR_GRP_REC_TYPE;
  i                               BINARY_INTEGER;
  l_count                         NUMBER;

  l_tax_line_id_tbl               TAX_LINE_ID_TBL;
  l_tax_regime_code_tbl           TAX_REGIME_CODE_TBL;
  l_tax_tbl                       TAX_TBL;
  l_tax_status_code_tbl           TAX_STATUS_CODE_TBL;
  l_tax_rate_code_tbl             TAX_RATE_CODE_TBL;
  l_tax_rate_tbl                  TAX_RATE_TBL;
  l_tax_rate_id_tbl               TAX_RATE_ID_TBL;
  l_tax_jurisdiction_code_tbl     TAX_JURISDICTION_CODE_TBL;
  l_taxable_basis_formula_tbl     TAXABLE_BASIS_FORMULA_TBL;
  l_tax_calculation_formula_tbl   TAX_CALCULATION_FORMULA_TBL;
  l_tax_amt_included_flag_tbl     TAX_AMT_INCLUDED_FLAG_TBL;
  l_compounding_tax_flag_tbl      COMPOUNDING_TAX_FLAG_TBL;
  l_historical_flag_tbl           HISTORICAL_FLAG_TBL;
  l_self_assessed_flag_tbl        SELF_ASSESSED_FLAG_TBL;
  l_overridden_flag_tbl           OVERRIDDEN_FLAG_TBL;
  l_Cop_From_Other_Doc_Flag_tbl   COP_FROM_OTHER_DOC_FLAG_TBL;
  l_assoc_child_frozen_flag_tbl   ASSOC_CHILD_FROZEN_FLAG_TBL;
  l_tax_only_line_flag_tbl        TAX_ONLY_LINE_FLAG_TBL;
  l_manually_entered_flag_tbl     MANUALLY_ENTERED_FLAG_TBL;
  l_mrc_tax_line_flag_tbl         MRC_TAX_LINE_FLAG_TBL;
  l_reporting_only_flag_tbl       REPORTING_ONLY_FLAG_TBL;
  l_applied_from_applic_id_tbl    APPLIED_FROM_APPLIC_ID_TBL;
  l_applied_from_evnt_cls_cd_tbl  APPLIED_FROM_EVNT_CLS_CD_TBL;
  l_applied_from_entity_code_tbl  APPLIED_FROM_ENTITY_CODE_TBL;
  l_applied_from_trx_id_tbl       APPLIED_FROM_TRX_ID_TBL;
  l_applied_from_line_id_tbl      APPLIED_FROM_LINE_ID_TBL;
  l_adjusted_doc_applic_id_tbl    ADJUSTED_DOC_APPLIC_ID_TBL;
  l_adjusted_doc_entity_code_tbl  ADJUSTED_DOC_ENTITY_CODE_TBL;
  l_adjusted_doc_evnt_cls_cd_tbl  ADJUSTED_DOC_EVNT_CLS_CD_TBL;
  l_adjusted_doc_trx_id_tbl       ADJUSTED_DOC_TRX_ID_TBL;
  l_applied_to_applic_id_tbl      APPLIED_TO_APPLIC_ID_TBL;
  l_applied_to_evnt_cls_cd_tbl    APPLIED_TO_EVNT_CLS_CD_TBL;
  l_applied_to_entity_code_tbl    APPLIED_TO_ENTITY_CODE_TBL;
  l_applied_to_trx_id_tbl         APPLIED_TO_TRX_ID_TBL;
  l_applied_to_line_id_tbl        APPLIED_TO_LINE_ID_TBL;
  l_tax_exemption_id_tbl          TAX_EXEMPTION_ID_TBL;
  l_tax_rate_before_exempt_tbl    RATE_BEFORE_EXEMPTION_TBL;
  l_rate_name_before_exempt_tbl   RATE_NAME_BEFORE_EXEMPTION_TBL;
  l_exempt_rate_modifier_tbl      EXEMPT_RATE_MODIFIER_TBL;
  l_exempt_certificate_num_tbl    EXEMPT_CERTIFICATE_NUM_TBL;
  l_exempt_reason_tbl             EXEMPT_REASON_TBL;
  l_exempt_reason_code_tbl        EXEMPT_REASON_CODE_TBL;
  l_tax_exception_id_tbl          TAX_EXCEPTION_ID_TBL;
  l_tax_rate_before_except_tbl    RATE_BEFORE_EXCEPTION_TBL;
  l_rate_name_before_except_tbl   RATE_NAME_BEFORE_EXCEPTION_TBL;
  l_exception_rate_tbl            EXCEPTION_RATE_TBL;
  l_ledger_id_tbl                 LEDGER_ID_TBL;
  l_legal_entity_id_tbl           LEGAL_ENTITY_ID_TBL;
  l_establishment_id_tbl          ESTABLISHMENT_ID_TBL;
  l_record_type_code_tbl          RECORD_TYPE_CODE_TBL;
  l_currency_conversion_type_tbl  CURRENCY_CONVERSION_TYPE_TBL;
  l_currency_conversion_rate_tbl  CURRENCY_CONVERSION_RATE_TBL;
  l_currency_conversion_date_tbl  CURRENCY_CONVERSION_DATE_TBL;
  l_trx_currency_code_tbl         TRX_CURRENCY_CODE_TBL;
  l_rounding_level_tbl            ROUNDING_LEVEL_TBL;
  l_tax_amt_tbl                   TAX_AMT_TBL;
  l_taxable_amt_tbl               TAXABLE_AMT_TBL;
  l_cal_tax_amt_tbl               CAL_TAX_AMT_TBL;
  l_unrounded_taxable_amt_tbl     UNROUNDED_TAXABLE_AMT_TBL;
  l_unrounded_tax_amt_tbl         UNROUNDED_TAX_AMT_TBL;
  l_tax_amt_funcl_curr_tbl        TAX_AMT_FUNCL_CURR_TBL;
  l_taxable_amt_funcl_curr_tbl    TAXABLE_AMT_FUNCL_CURR_TBL;
  l_cal_tax_amt_funcl_curr_tbl    CAL_TAX_AMT_FUNCL_CURR_TBL;

  CURSOR get_round_head_level_curr_csr
    (c_trx_id                     ZX_LINES.TRX_ID%TYPE,
     c_application_id             ZX_LINES.APPLICATION_ID%TYPE,
     c_event_class_code           ZX_LINES.EVENT_CLASS_CODE%TYPE,
     c_entity_code                ZX_LINES.ENTITY_CODE%TYPE)
  IS
    SELECT tax_line_id,
           tax_regime_code,
           tax,
           tax_status_code,
           tax_rate_code,
           tax_rate,
           tax_rate_id,
           tax_jurisdiction_code,
           taxable_basis_formula,
           tax_calculation_formula,
           Tax_Amt_Included_Flag,
           compounding_tax_flag,
           historical_flag,
           self_assessed_flag,
           overridden_flag,
           Copied_From_Other_Doc_Flag,
           associated_child_frozen_flag,
           tax_only_line_flag,
           manually_entered_flag,
           mrc_tax_line_flag,
           reporting_only_flag,
           applied_from_application_id,
           applied_from_event_class_code,
           applied_from_entity_code,
           applied_from_trx_id,
           applied_from_line_id,
           adjusted_doc_application_id,
           adjusted_doc_entity_code,
           adjusted_doc_event_class_code,
           adjusted_doc_trx_id,
           --applied_to_application_id,
           --applied_to_event_class_code,
           --applied_to_entity_code,
           --applied_to_trx_id,
           --applied_to_line_id,
           tax_exemption_id,
           tax_rate_before_exemption,
           tax_rate_name_before_exemption,
           exempt_rate_modifier,
           exempt_certificate_number,
           exempt_reason,
           exempt_reason_code,
           tax_exception_id,
           tax_rate_before_exception,
           tax_rate_name_before_exception,
           exception_rate,
           ledger_id,
           legal_entity_id,
           establishment_id,
           currency_conversion_date,
           currency_conversion_type,
           currency_conversion_rate,
           record_type_code,
           trx_currency_code,
           Rounding_Level_Code,
           tax_amt,
           taxable_amt,
           cal_tax_amt,
           unrounded_taxable_amt,
           unrounded_tax_amt,
           tax_amt_funcl_curr,
           taxable_amt_funcl_curr,
           cal_tax_amt_funcl_curr
     FROM  ZX_LINES
      WHERE trx_id            = c_trx_id           AND
            application_id    = c_application_id   AND
            event_class_code  = c_event_class_code AND
            entity_code       = c_entity_code      AND
            tax_provider_id IS NULL                AND
            offset_link_to_tax_line_id IS NULL     AND
            mrc_tax_line_flag = 'N'
     ORDER BY
           tax_regime_code,
           tax,
           tax_status_code,
           tax_rate_code,
           tax_rate,
           tax_rate_id,
           tax_jurisdiction_code,
           taxable_basis_formula,
           tax_calculation_formula,
           Tax_Amt_Included_Flag,
           compounding_tax_flag,
           historical_flag,
           self_assessed_flag,
           overridden_flag,
           manually_entered_flag,
           Copied_From_Other_Doc_Flag,
           associated_child_frozen_flag,
           tax_only_line_flag,
           mrc_tax_line_flag,
           reporting_only_flag,
           applied_from_application_id,
           applied_from_event_class_code,
           applied_from_entity_code,
           applied_from_trx_id,
           applied_from_line_id,
           adjusted_doc_application_id,
           adjusted_doc_entity_code,
           adjusted_doc_event_class_code,
           adjusted_doc_trx_id,
           --applied_to_application_id,
           --applied_to_event_class_code,
           --applied_to_entity_code,
           --applied_to_trx_id,
           --applied_to_line_id,
           tax_exemption_id,
           tax_rate_before_exemption,
           tax_rate_name_before_exemption,
           exempt_rate_modifier,
           exempt_certificate_number,
           exempt_reason,
           exempt_reason_code,
           tax_exception_id,
           tax_rate_before_exception,
           tax_rate_name_before_exception,
           exception_rate,
           ledger_id,
           legal_entity_id,
           establishment_id,
           TRUNC(currency_conversion_date),
           currency_conversion_type,
           currency_conversion_rate,
           record_type_code;


BEGIN

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.convert_and_round_hdr_lvl_curr.BEGIN',
                   'ZX_TDS_TAX_ROUNDING_PKG: convert_and_round_hdr_lvl_curr(+)');
  END IF;

  --
  -- init return status
  --
  p_return_status  := FND_API.G_RET_STS_SUCCESS;

  --
  -- init header group record
  --
  init_header_group(l_prev_hdr_grp_rec,
                    p_return_status,
                    p_error_buffer);

  IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RETURN;
  END IF;

  --
  -- init header rounding info table
  --
  g_hdr_rounding_curr_tbl.DELETE;

  --
  -- get amounts and rounding info
  --
  OPEN get_round_head_level_curr_csr(
                               p_event_class_rec.trx_id,
                               p_event_class_rec.application_id,
                               p_event_class_rec.event_class_code,
                               p_event_class_rec.entity_code);
  LOOP
    FETCH get_round_head_level_curr_csr BULK COLLECT INTO
           l_tax_line_id_tbl,
           l_tax_regime_code_tbl,
           l_tax_tbl,
           l_tax_status_code_tbl,
           l_tax_rate_code_tbl,
           l_tax_rate_tbl,
           l_tax_rate_id_tbl,
           l_tax_jurisdiction_code_tbl,
           l_taxable_basis_formula_tbl,
           l_tax_calculation_formula_tbl,
           l_tax_amt_included_flag_tbl,
           l_compounding_tax_flag_tbl,
           l_historical_flag_tbl,
           l_self_assessed_flag_tbl,
           l_overridden_flag_tbl,
           l_Cop_From_Other_Doc_Flag_tbl,
           l_assoc_child_frozen_flag_tbl,
           l_tax_only_line_flag_tbl,
           l_manually_entered_flag_tbl,
           l_mrc_tax_line_flag_tbl,
           l_reporting_only_flag_tbl,
           l_applied_from_applic_id_tbl,
           l_applied_from_evnt_cls_cd_tbl,
           l_applied_from_entity_code_tbl,
           l_applied_from_trx_id_tbl,
           l_applied_from_line_id_tbl,
           l_adjusted_doc_applic_id_tbl,
           l_adjusted_doc_entity_code_tbl,
           l_adjusted_doc_evnt_cls_cd_tbl,
           l_adjusted_doc_trx_id_tbl,
           --l_applied_to_applic_id_tbl,
           --l_applied_to_evnt_cls_cd_tbl,
           --l_applied_to_entity_code_tbl,
           --l_applied_to_trx_id_tbl,
           --l_applied_to_line_id_tbl,
           l_tax_exemption_id_tbl,
           l_tax_rate_before_exempt_tbl,
           l_rate_name_before_exempt_tbl,
           l_exempt_rate_modifier_tbl,
           l_exempt_certificate_num_tbl,
           l_exempt_reason_tbl,
           l_exempt_reason_code_tbl,
           l_tax_exception_id_tbl,
           l_tax_rate_before_except_tbl,
           l_rate_name_before_except_tbl,
           l_exception_rate_tbl,
           l_ledger_id_tbl,
           l_legal_entity_id_tbl,
           l_establishment_id_tbl,
           l_currency_conversion_date_tbl,
           l_currency_conversion_type_tbl,
           l_currency_conversion_rate_tbl,
           l_record_type_code_tbl,
           l_trx_currency_code_tbl,
           l_rounding_level_tbl,
           l_tax_amt_tbl,
           l_taxable_amt_tbl,
           l_cal_tax_amt_tbl,
           l_unrounded_taxable_amt_tbl,
           l_unrounded_tax_amt_tbl,
           l_tax_amt_funcl_curr_tbl,
           l_taxable_amt_funcl_curr_tbl,
           l_cal_tax_amt_funcl_curr_tbl
      LIMIT C_LINES_PER_COMMIT;

    l_count := l_tax_line_id_tbl.COUNT;

    IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.convert_and_round_hdr_lvl_curr',
                       'number of rows fetched = ' || to_char(l_count));
    END IF;

    IF l_count > 0 THEN

      FOR i IN 1.. l_count LOOP

        --
        -- perform rounding for each line using LINE level rounding

        convert_and_round_for_curr(
                       p_conversion_rate,
                       l_tax_amt_tbl(i),
                       l_taxable_amt_tbl(i),
                       l_unrounded_tax_amt_tbl(i),
                       l_unrounded_taxable_amt_tbl(i),
                       l_tax_amt_funcl_curr_tbl(i),
                       l_taxable_amt_funcl_curr_tbl(i),
                       l_ledger_id_tbl(i),
                       l_tax_calculation_formula_tbl(i),
                       l_tax_rate_tbl(i),
                       l_tax_rate_id_tbl(i),
                       p_return_status,
                       p_error_buffer);

        IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          EXIT;
        END IF;
        --
        -- get header grouping criteria of the current record
        --
        l_curr_hdr_grp_rec.tax_regime_code              :=
                               l_tax_regime_code_tbl(i);
        l_curr_hdr_grp_rec.tax                          := l_tax_tbl(i);
        l_curr_hdr_grp_rec.tax_status_code              := l_tax_status_code_tbl(i);
        l_curr_hdr_grp_rec.tax_rate_code                := l_tax_rate_code_tbl(i);
        l_curr_hdr_grp_rec.tax_rate                     := l_tax_rate_tbl(i);
        l_curr_hdr_grp_rec.tax_rate_id                  := l_tax_rate_id_tbl(i);
        l_curr_hdr_grp_rec.tax_jurisdiction_code        :=
                               l_tax_jurisdiction_code_tbl(i);
        l_curr_hdr_grp_rec.taxable_basis_formula        :=
                               l_taxable_basis_formula_tbl(i);
        l_curr_hdr_grp_rec.tax_calculation_formula      :=
                               l_tax_calculation_formula_tbl(i);
        l_curr_hdr_grp_rec.Tax_Amt_Included_Flag        :=
                               l_Tax_Amt_Included_Flag_tbl(i);
        l_curr_hdr_grp_rec.compounding_tax_flag         :=
                               l_compounding_tax_flag_tbl(i);
        l_curr_hdr_grp_rec.historical_flag              :=
                               l_historical_flag_tbl(i);
        l_curr_hdr_grp_rec.self_assessed_flag           :=
                               l_self_assessed_flag_tbl(i);
        l_curr_hdr_grp_rec.overridden_flag              :=
                               l_overridden_flag_tbl(i);
        l_curr_hdr_grp_rec.manually_entered_flag        :=
                               l_manually_entered_flag_tbl(i);
        l_curr_hdr_grp_rec.Copied_From_Other_Doc_Flag     :=
                               l_Cop_From_Other_Doc_Flag_tbl(i);
        l_curr_hdr_grp_rec.associated_child_frozen_flag :=
                               l_assoc_child_frozen_flag_tbl(i);
        l_curr_hdr_grp_rec.tax_only_line_flag           :=
                               l_tax_only_line_flag_tbl(i);
        l_curr_hdr_grp_rec.mrc_tax_line_flag   :=
                               l_mrc_tax_line_flag_tbl(i);
        l_curr_hdr_grp_rec.reporting_only_flag :=
                               l_reporting_only_flag_tbl(i);
        l_curr_hdr_grp_rec.applied_from_application_id  :=
                               l_applied_from_applic_id_tbl(i);
        l_curr_hdr_grp_rec.applied_from_event_class_code :=
                               l_applied_from_evnt_cls_cd_tbl(i);
        l_curr_hdr_grp_rec.applied_from_entity_code     :=
                               l_applied_from_entity_code_tbl(i);
        l_curr_hdr_grp_rec.applied_from_trx_id          :=
                               l_applied_from_trx_id_tbl(i);
        l_curr_hdr_grp_rec.applied_from_line_id          :=
                               l_applied_from_line_id_tbl(i);
        l_curr_hdr_grp_rec.adjusted_doc_application_id  :=
                               l_adjusted_doc_applic_id_tbl(i);
        l_curr_hdr_grp_rec.adjusted_doc_entity_code     :=
                               l_adjusted_doc_entity_code_tbl(i);
        l_curr_hdr_grp_rec.adjusted_doc_event_class_code :=
                               l_adjusted_doc_evnt_cls_cd_tbl(i);
        l_curr_hdr_grp_rec.adjusted_doc_trx_id          :=
                               l_adjusted_doc_trx_id_tbl(i);
        --l_curr_hdr_grp_rec.applied_to_application_id    :=
        --                       l_applied_to_applic_id_tbl(i);
        --l_curr_hdr_grp_rec.applied_to_event_class_code  :=
        --                       l_applied_to_evnt_cls_cd_tbl(i);
        --l_curr_hdr_grp_rec.applied_to_entity_code       :=
        --                       l_applied_to_entity_code_tbl(i);
        --l_curr_hdr_grp_rec.applied_to_trx_id            :=
        --                       l_applied_to_trx_id_tbl(i);
        --l_curr_hdr_grp_rec.applied_to_line_id            :=
        --                       l_applied_to_line_id_tbl(i);
        l_curr_hdr_grp_rec.tax_exemption_id             :=
                               l_tax_exemption_id_tbl(i);
        l_curr_hdr_grp_rec.tax_rate_before_exemption    :=
                               l_tax_rate_before_exempt_tbl(i);
        l_curr_hdr_grp_rec.tax_rate_name_before_exemption             :=
                               l_rate_name_before_exempt_tbl(i);
        l_curr_hdr_grp_rec.exempt_rate_modifier         :=
                               l_exempt_rate_modifier_tbl(i);
        l_curr_hdr_grp_rec.exempt_certificate_number    :=
                               l_exempt_certificate_num_tbl(i);
        l_curr_hdr_grp_rec.exempt_reason                :=
                               l_exempt_reason_tbl(i);
        l_curr_hdr_grp_rec.exempt_reason_code           :=
                               l_exempt_reason_code_tbl(i);
        l_curr_hdr_grp_rec.tax_exception_id             :=
                               l_tax_exception_id_tbl(i);
        l_curr_hdr_grp_rec.tax_rate_before_exception               :=
                               l_tax_rate_before_except_tbl(i);
        l_curr_hdr_grp_rec.tax_rate_name_before_exception          :=
                               l_rate_name_before_except_tbl(i);
        l_curr_hdr_grp_rec.exception_rate      :=
                               l_exception_rate_tbl(i);
        l_curr_hdr_grp_rec.ledger_id         := l_ledger_id_tbl(i);
        l_curr_hdr_grp_rec.legal_entity_id   := l_legal_entity_id_tbl(i);
        l_curr_hdr_grp_rec.establishment_id  := l_establishment_id_tbl(i);
        l_curr_hdr_grp_rec.currency_conversion_date   :=
                               l_currency_conversion_date_tbl(i);
        l_curr_hdr_grp_rec.currency_conversion_type   :=
                               l_currency_conversion_type_tbl(i);
        l_curr_hdr_grp_rec.currency_conversion_rate   :=
                               l_currency_conversion_rate_tbl(i);
        l_curr_hdr_grp_rec.record_type_code    :=
                               l_record_type_code_tbl(i);

        -- handle header rounding
        --
        handle_header_rounding_curr(
                                l_tax_line_id_tbl(i),
                                l_unrounded_tax_amt_tbl(i),
                                l_tax_amt_funcl_curr_tbl(i),
                                l_taxable_amt_funcl_curr_tbl(i),
                                l_currency_conversion_rate_tbl(i),
                                l_prev_hdr_grp_rec,
                                l_curr_hdr_grp_rec,
                                l_ledger_id_tbl(i),
                                p_return_status,
                                p_error_buffer);

        IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          EXIT;
        END IF;
      END LOOP;

      IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        EXIT;
      END IF;

      --
      -- bulk update the current rows processed
      -- before fetch the next set of rows
      --

      -- update zx_lines
      --
      update_zx_lines(
                 p_conversion_rate,
                 p_conversion_type,
                 p_conversion_date,
                 l_tax_amt_funcl_curr_tbl,
                 l_taxable_amt_funcl_curr_tbl,
                 l_cal_tax_amt_funcl_curr_tbl,
                 l_tax_line_id_tbl,
                 p_return_status,
                 p_error_buffer);

      IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        EXIT;
      END IF;

    ELSE
      --
      -- no more records to process
      --
      CLOSE get_round_head_level_curr_csr;
      EXIT;
    END IF;   -- end of count > 0
  END LOOP;

  IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    CLOSE get_round_head_level_curr_csr;
    RETURN;
  END IF;

  --
  -- now adjust the rounding differences if it is HEADER rounding level
  -- for tax amount in trx currency, tax currrency and functional
  -- currency
  --
  adjust_rounding_diff_curr
        (p_return_status,
         p_error_buffer);
  IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RETURN;
  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.convert_and_round_hdr_lvl_curr.END',
                   'ZX_TDS_TAX_ROUNDING_PKG: convert_and_round_hdr_lvl_curr(-)'||p_return_status);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    IF get_round_head_level_curr_csr%ISOPEN THEN
      CLOSE get_round_head_level_curr_csr;
    END IF;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.convert_and_round_hdr_lvl_curr',
                      p_error_buffer);
    END IF;

END convert_and_round_hdr_lvl_curr;
---------------------------------------------------------------------------
--
--  PUBLIC PROCEDURE
--  convert_and_round_curr
--
--  DESCRIPTION
--
--  This procedure is used to update the tax amount and taxable amount
--  in functional currency or other currency when the conversion rate
--  is provided
--  This procedure is incomplete due to some MRC issues are not
--  finalized at this time
--
PROCEDURE convert_and_round_curr(
                p_conversion_rate      IN OUT NOCOPY NUMBER,
                p_conversion_type      IN            VARCHAR2,
                p_conversion_date      IN            DATE,
                p_event_class_rec      IN            ZX_API_PUB.EVENT_CLASS_REC_TYPE,
                p_return_status           OUT NOCOPY VARCHAR2,
                p_error_buffer            OUT NOCOPY VARCHAR2
)
IS

BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.convert_and_round_curr.BEGIN',
                   'ZX_TDS_TAX_ROUNDING_PKG: convert_and_round_curr(+)');
  END IF;

  --
  -- init error buffer and return status
  --
  p_return_status  := FND_API.G_RET_STS_SUCCESS;
  p_error_buffer   := NULL;


  -- ???????? where to get rounding level if not from zx_lines ????????
  -- ???????? for now, assume get it from event class rec ????????
  --
  IF p_event_class_rec.Default_Rounding_Level_Code = 'HEADER' THEN
    convert_and_round_hdr_lvl_curr(
              p_conversion_rate,
              p_conversion_type,
              p_conversion_date,
              p_event_class_rec,
              p_return_status,
              p_error_buffer );

  ELSE
    convert_and_round_lin_lvl_curr(
              p_conversion_rate,
              p_conversion_type,
              p_conversion_date,
              p_event_class_rec,
              p_return_status,
              p_error_buffer );
  END IF;

  IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RETURN;
  END IF;

  -- *****************
  -- need to do the same for offset tax lines
  -- select only the offset tax lines from zx_lines and
  -- do similar thing as set_amt_columns in offset tax determination pkg
  -- will have separate procedure to do this when handling of
  -- MRC is clear
  -- ******************


  IF (g_level_procedure >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.convert_and_round_curr.END',
                   'ZX_TDS_TAX_ROUNDING_PKG: convert_and_round_curr(-)'||p_return_status);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.convert_and_round_curr',
                      p_error_buffer);
    END IF;

END convert_and_round_curr;

---------------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  round_tax_amt_entered
--
--  DESCRIPTION
--  This procedure is used by UI to round tax amount entered
--  by user on tax line or summary line.
--

PROCEDURE round_tax_amt_entered(
           p_tax_amt              IN OUT NOCOPY ZX_LINES.TAX_AMT%TYPE,
           p_tax_id               IN            ZX_TAXES_B.TAX_ID%TYPE,
           p_application_id       IN            ZX_LINES.APPLICATION_ID%TYPE,
           p_entity_code          IN            ZX_LINES.ENTITY_CODE%TYPE,
           p_event_class_code     IN            ZX_LINES.EVENT_CLASS_CODE%TYPE,
           p_trx_id               IN            ZX_LINES.TRX_ID%TYPE,
           p_return_status           OUT NOCOPY VARCHAR2,
           p_error_buffer            OUT NOCOPY VARCHAR2
         )
IS

  l_rounding_rule_code        ZX_TAXES_B.ROUNDING_RULE_CODE%TYPE;
  l_tax_rounding_rule_code    ZX_TAXES_B.ROUNDING_RULE_CODE%TYPE;
  l_trx_currency_code         ZX_LINES_DET_FACTORS.TRX_CURRENCY_CODE%TYPE;
  l_tax_min_acct_unit         ZX_TAXES_B.MINIMUM_ACCOUNTABLE_UNIT%TYPE;
  l_trx_min_acct_unit         ZX_LINES_DET_FACTORS.MINIMUM_ACCOUNTABLE_UNIT%TYPE;
  l_tax_precision             ZX_TAXES_B.TAX_PRECISION%TYPE;
  l_trx_precision             ZX_LINES_DET_FACTORS.PRECISION%TYPE;
  l_event_class_rec           ZX_API_PUB.EVENT_CLASS_REC_TYPE;
  l_unrounded_tax_amt         ZX_LINES.UNROUNDED_TAX_AMT%TYPE;
  l_rounding_level_code       ZX_PARTY_TAX_PROFILE.Rounding_Level_Code%TYPE;
  l_rnd_lvl_party_tax_prof_id ZX_LINES.ROUNDING_LVL_PARTY_TAX_PROF_ID%TYPE;
  l_rounding_lvl_party_type   ZX_LINES.ROUNDING_LVL_PARTY_TYPE%TYPE;



  CURSOR get_rnd_level_hier_csr
    (c_application_id       ZX_LINES.APPLICATION_ID%TYPE,
     c_entity_code          ZX_LINES.ENTITY_CODE%TYPE,
     c_event_class_code     ZX_LINES.EVENT_CLASS_CODE%TYPE)
  IS
     SELECT  default_rounding_level_code,
             rounding_level_hier_1_code,
             rounding_level_hier_2_code,
             rounding_level_hier_3_code,
             rounding_level_hier_4_code
       FROM  ZX_EVNT_CLS_MAPPINGS
       WHERE APPLICATION_ID   = c_application_id    AND
             ENTITY_CODE      = c_entity_code       AND
             EVENT_CLASS_CODE = c_event_class_code;

  -- bug#6798349
  -- add trx_currency_code, precision, minimum_accountable_unit
  -- to get trx currency info from zx_lines_det_factors

  CURSOR get_rnd_tx_prof_id_csr
    (c_application_id       ZX_LINES.APPLICATION_ID%TYPE,
     c_entity_code          ZX_LINES.ENTITY_CODE%TYPE,
     c_event_class_code     ZX_LINES.EVENT_CLASS_CODE%TYPE,
     c_trx_id               ZX_LINES.TRX_ID%TYPE)
  IS
     SELECT  rdng_ship_to_pty_tx_prof_id,
             rdng_ship_from_pty_tx_prof_id,
             rdng_bill_to_pty_tx_prof_id,
             rdng_bill_from_pty_tx_prof_id,
             rdng_ship_to_pty_tx_p_st_id,
             rdng_ship_from_pty_tx_p_st_id,
             rdng_bill_to_pty_tx_p_st_id,
             rdng_bill_from_pty_tx_p_st_id,
             trx_currency_code,
             precision,
             minimum_accountable_unit
       FROM  ZX_LINES_DET_FACTORS
       WHERE APPLICATION_ID   = c_application_id    AND
             ENTITY_CODE      = c_entity_code       AND
             EVENT_CLASS_CODE = c_event_class_code  AND
             TRX_ID           = c_trx_id;

  CURSOR get_rnd_info_from_tax_csr
    (c_tax_id       ZX_LINES.TAX_ID%TYPE)
  IS
    SELECT rounding_rule_code,
           minimum_accountable_unit,
           tax_precision
    FROM ZX_TAXES_B
    WHERE TAX_ID = c_tax_id;

  -- bug#6798349
  CURSOR get_precision_mau_csr
    (c_trx_currency_code       ZX_LINES_DET_FACTORS.TRX_CURRENCY_CODE%TYPE)
  IS
    SELECT minimum_accountable_unit,
           precision
    FROM FND_CURRENCIES
    WHERE currency_code = c_trx_currency_code;


BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.round_tax_amt_entered.BEGIN',
                   'ZX_TDS_TAX_ROUNDING_PKG: round_tax_amt_entered(+)');
  END IF;

  --
  -- init error buffer and return status
  --
  p_return_status  := FND_API.G_RET_STS_SUCCESS;
  p_error_buffer   := NULL;

  --
  --  get unrounded tax amt
  --
  l_unrounded_tax_amt := p_tax_amt;

  --
  -- populate event class record with rounding level
  -- hierachy info
  --
  OPEN get_rnd_level_hier_csr(
           p_application_id,
           p_entity_code,
           p_event_class_code);
  FETCH get_rnd_level_hier_csr INTO
           l_event_class_rec.default_rounding_level_code,
           l_event_class_rec.rounding_level_hier_1_code,
           l_event_class_rec.rounding_level_hier_2_code,
           l_event_class_rec.rounding_level_hier_3_code,
           l_event_class_rec.rounding_level_hier_4_code;
  CLOSE get_rnd_level_hier_csr;

  --
  -- populate event class record with rounding party/site
  -- tax profile id info
  --
  OPEN get_rnd_tx_prof_id_csr(
           p_application_id,
           p_entity_code,
           p_event_class_code,
           p_trx_id);
  FETCH get_rnd_tx_prof_id_csr INTO
           l_event_class_rec.rdng_ship_to_pty_tx_prof_id,
           l_event_class_rec.rdng_ship_from_pty_tx_prof_id,
           l_event_class_rec.rdng_bill_to_pty_tx_prof_id,
           l_event_class_rec.rdng_bill_from_pty_tx_prof_id,
           l_event_class_rec.rdng_ship_to_pty_tx_p_st_id,
           l_event_class_rec.rdng_ship_from_pty_tx_p_st_id,
           l_event_class_rec.rdng_bill_to_pty_tx_p_st_id,
           l_event_class_rec.rdng_bill_from_pty_tx_p_st_id,
           l_trx_currency_code,
           l_trx_precision,
           l_trx_min_acct_unit;
  CLOSE get_rnd_tx_prof_id_csr;


  --
  -- now calling get_rounding_level_and_rule procedure to
  -- get rounding level and rounding rule
  --
  get_rounding_level_and_rule(
           l_event_class_rec,
           l_rounding_level_code,
           l_rounding_rule_code,
           l_rnd_lvl_party_tax_prof_id,
           l_rounding_lvl_party_type,
           p_return_status,
           p_error_buffer);

  IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RETURN;
  END IF;

  -- get rounding info from zx_taxes_b
  OPEN get_rnd_info_from_tax_csr(p_tax_id);
      FETCH get_rnd_info_from_tax_csr  INTO
               l_tax_rounding_rule_code,
               l_tax_min_acct_unit,
               l_tax_precision;
      CLOSE get_rnd_info_from_tax_csr;

  --
  -- bug#6798349
  -- use transaction currency precsion, min account unit
  -- to round tax amount
  --
  IF (l_trx_precision IS NULL AND l_trx_min_acct_unit IS NULL) THEN
    -- get precision and MAU based on trx currency code
    IF l_trx_currency_code IS NOT NULL THEN
      OPEN get_precision_mau_csr(l_trx_currency_code);
        FETCH get_precision_mau_csr INTO
          l_trx_min_acct_unit,
          l_trx_precision;
      CLOSE get_precision_mau_csr;
    ELSE
      -- use the precision and mau from tax
      l_trx_min_acct_unit := l_tax_min_acct_unit;
      l_trx_precision     := l_tax_precision;
    END IF;
  END IF;

  --
  -- use rounding rule from zx_taxes only if
  -- rounding rule is not available from the party hierarchy
  --
  IF l_rounding_rule_code IS NULL THEN
    l_rounding_rule_code := l_tax_rounding_rule_code;
  END IF;

  --
  -- round the tax amount
  --
  p_tax_amt := ZX_TDS_TAX_ROUNDING_PKG.round_tax(
                            l_unrounded_tax_amt,
                            l_rounding_rule_code,
                            l_trx_min_acct_unit,
                            l_trx_precision,
                            p_return_status,
                            p_error_buffer);

  IF (g_level_procedure >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.round_tax_amt_entered.END',
                   'ZX_TDS_TAX_ROUNDING_PKG: round_tax_amt_entered(-)'||p_return_status);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    FND_MESSAGE.SET_NAME('ZX','ZX_UNEXPECTED_ERROR');
    FND_MSG_PUB.Add;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.round_tax_amt_entered',
                      p_error_buffer);
    END IF;

END round_tax_amt_entered;
-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  Get_Supplier_Site
--
--  DESCRIPTION
--
--  This procedure determines the rounding level for a whole document
--


PROCEDURE Get_Supplier_Site(
              p_account_id           IN   ZX_REGISTRATIONS.ACCOUNT_ID%TYPE,
              p_account_site_id      IN   ZX_REGISTRATIONS.ACCOUNT_SITE_ID%TYPE,
              p_rounding_level_code  OUT NOCOPY  ZX_PARTY_TAX_PROFILE.ROUNDING_LEVEL_CODE%TYPE,
              p_rounding_rule_code   OUT NOCOPY  ZX_PARTY_TAX_PROFILE.ROUNDING_RULE_CODE%TYPE,

              p_return_status        OUT  NOCOPY VARCHAR2)
IS

  CURSOR c_supplier_ptp (
     c_account_id          ZX_REGISTRATIONS.ACCOUNT_ID%TYPE,
     c_account_site_id     ZX_REGISTRATIONS.ACCOUNT_SITE_ID%TYPE)
  IS
  SELECT
          decode(povs.AP_Tax_Rounding_Rule,'U','UP','D','DOWN','N','NEAREST',NULL) tax_runding_rule
         ,decode(nvl(povs.Auto_Tax_Calc_Flag,'Y'),'N','N','Y') Auto_Tax_Calc_Flag
         ,povs.VAT_Code
	 ,povs.VAT_Registration_Num
         ,DECODE(povs.Auto_Tax_Calc_Flag,
               'L','LINE',
               'H','HEADER',
               'T','HEADER',
               NULL) tax_rounding_level
    FROM ap_supplier_sites_all  povs
    WHERE povs.vendor_id      = c_account_id
      AND povs.vendor_site_id = c_account_site_id;

  l_ap_tax_rounding_rule  VARCHAR2(10);
  l_auto_tax_calc_flag    ap_supplier_sites_all.auto_tax_calc_flag%TYPE;
  l_vat_code              ap_supplier_sites_all.vat_code%TYPE;
  l_vat_registration_num  ap_supplier_sites_all.vat_registration_num%TYPE;
  l_tax_rounding_level    VARCHAR2(10);

BEGIN
 IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.Get_Supplier_Site.BEGIN',
                   'ZX_TDS_TAX_ROUNDING_PKG: Get_Supplier_Site(+)');
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.Get_Supplier_Site',
                   'p_account_site_id : ' || TO_CHAR(p_account_site_id));
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.Get_Supplier_Site',
                   'p_account_id : ' || TO_CHAR(p_account_id));
  END IF;

  p_return_status       := FND_API.G_RET_STS_SUCCESS;
  p_rounding_level_code := NULL;
  p_rounding_rule_code  := NULL;


 IF ZX_GLOBAL_STRUCTURES_PKG.g_supp_site_info_tbl.exists(p_account_site_id) THEN

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,'ZX_TDS_TAX_ROUNDING_PKG.Get_Supplier_Site',
        'Vendor site record found in cache for vendor site id:'||to_char(p_account_site_id));
   END IF;

   p_rounding_rule_code :=  ZX_GLOBAL_STRUCTURES_PKG.g_supp_site_info_tbl(p_account_site_id).TAX_ROUNDING_RULE;
   P_rounding_level_code := ZX_GLOBAL_STRUCTURES_PKG.g_supp_site_info_tbl(p_account_site_id).TAX_ROUNDING_LEVEL;
   ZX_TDS_CALC_SERVICES_PUB_PKG.g_process_for_appl_flg := ZX_GLOBAL_STRUCTURES_PKG.g_supp_site_info_tbl(p_account_site_id).Auto_Tax_Calc_Flag;

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,'ZX_TDS_TAX_ROUNDING_PKG.Get_Supplier_Site',
        'ZX_TDS_CALC_SERVICES_PUB_PKG.g_process_for_appl_flg '|| ZX_TDS_CALC_SERVICES_PUB_PKG.g_process_for_appl_flg );
   END IF;

 ELSE

  OPEN c_supplier_ptp(
            p_account_id,
            p_account_site_id);
  FETCH c_supplier_ptp INTO
                    l_ap_tax_rounding_rule
                    ,l_auto_tax_calc_flag
                    ,l_vat_code
                    ,l_vat_registration_num
                    ,l_tax_rounding_level;

            p_rounding_level_code := l_tax_rounding_level;
            p_rounding_rule_code := l_ap_tax_rounding_rule;
  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,'ZX_TDS_TAX_ROUNDING_PKG.Get_Supplier_Site',
        'Auto tax calc flag '|| l_auto_tax_calc_flag);
  END IF;


        ZX_GLOBAL_STRUCTURES_PKG.g_supp_site_info_tbl(p_account_site_id).TAX_ROUNDING_RULE :=
              l_ap_tax_rounding_rule;
        ZX_GLOBAL_STRUCTURES_PKG.g_supp_site_info_tbl(p_account_site_id).Auto_Tax_Calc_Flag :=
              l_auto_tax_calc_flag;
        ZX_GLOBAL_STRUCTURES_PKG.g_supp_site_info_tbl(p_account_site_id).VAT_CODE := l_vat_code;
        ZX_GLOBAL_STRUCTURES_PKG.g_supp_site_info_tbl(p_account_site_id).TAX_ROUNDING_LEVEL :=
              l_tax_rounding_level;
        ZX_GLOBAL_STRUCTURES_PKG.g_supp_site_info_tbl(p_account_site_id).VAT_REGISTRATION_NUM :=
              l_vat_registration_num;
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_process_for_appl_flg := l_auto_tax_calc_flag;

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,'ZX_TDS_TAX_ROUNDING_PKG.Get_Supplier_Site',
        'ZX_TDS_CALC_SERVICES_PUB_PKG.g_process_for_appl_flg '|| ZX_TDS_CALC_SERVICES_PUB_PKG.g_process_for_appl_flg);
   END IF;


  CLOSE c_supplier_ptp;

 END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.Get_Supplier_Site.END',
                   'ZX_TDS_TAX_ROUNDING_PKG: Get_Supplier_Site(-)'||'rounding level code :'||p_rounding_level_code);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF c_supplier_ptp%isopen THEN
       CLOSE c_supplier_ptp;
    END IF;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.Get_Supplier_Site.END',
                   'Exception in ZX_TDS_TAX_ROUNDING_PKG.Get_Supplier_Site. '||SQLCODE||SQLERRM);
    END IF;

END Get_Supplier_Site;

-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  Get_Reg_Site_Uses
--
--  DESCRIPTION
--

PROCEDURE  Get_Reg_Site_Uses (
              p_account_id            IN   ZX_REGISTRATIONS.ACCOUNT_ID%TYPE,
              p_account_site_id       IN   ZX_REGISTRATIONS.ACCOUNT_SITE_ID%TYPE,
              p_site_use_id           IN   HZ_CUST_SITE_USES_ALL.CUST_ACCT_SITE_ID%TYPE,
              p_rounding_level_code   OUT NOCOPY  ZX_PARTY_TAX_PROFILE.ROUNDING_LEVEL_CODE%TYPE,
              p_rounding_rule_code    OUT NOCOPY  ZX_PARTY_TAX_PROFILE.ROUNDING_RULE_CODE%TYPE,
              p_return_status         OUT NOCOPY  VARCHAR2)
IS
  CURSOR c_site_uses (
    c_site_use_id          HZ_CUST_SITE_USES_ALL.CUST_ACCT_SITE_ID%TYPE,
    c_account_site_id      ZX_REGISTRATIONS.ACCOUNT_SITE_ID%TYPE,
    c_account_id           ZX_REGISTRATIONS.ACCOUNT_ID%TYPE)
  IS
  SELECT
       csu.Tax_Reference,
       nvl(csu.Tax_Code,caa.tax_code) tax_code,
       nvl(csu.Tax_Rounding_rule,caa.tax_rounding_rule) tax_rounding_rule,
       nvl(csu.tax_header_level_flag, caa.tax_header_level_flag) tax_header_level_flag,
       csu.Tax_Classification
    FROM hz_cust_site_uses_all csu
        ,hz_cust_acct_sites cas
        ,hz_cust_accounts caa
   WHERE csu.site_use_id       = c_site_use_id
     AND csu.cust_acct_site_id = c_account_site_id
     AND csu.cust_acct_site_id = cas.cust_acct_site_id
     AND cas.cust_account_id   = caa.cust_account_id
     AND caa.cust_account_id   = c_account_id;

  l_tax_rounding_rule      hz_cust_site_uses_all.Tax_Rounding_rule%TYPE;
  l_tax_header_level_flag  hz_cust_site_uses_all.tax_header_level_flag%TYPE;
  l_tax_code               hz_cust_site_uses_all.Tax_Code%TYPE;
  l_Tax_Classification     hz_cust_site_uses_all.Tax_Classification%TYPE;
  l_tax_reference          hz_cust_site_uses_all.Tax_Reference%TYPE;


BEGIN
  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.Get_Reg_Site_Uses.BEGIN',
                   'ZX_TDS_TAX_ROUNDING_PKG: Get_Reg_Site_Uses(+)');
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.Get_Reg_Site_Uses',
                   'p_account_site_id : ' || TO_CHAR(p_account_site_id));
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.Get_Reg_Site_Uses',
                   'p_account_id : ' || TO_CHAR(p_account_id));
   FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.Get_Reg_Site_Uses',
                   'p_site_use_id : ' || TO_CHAR(p_site_use_id));
  END IF;

  p_return_status       := FND_API.G_RET_STS_SUCCESS;
  p_rounding_level_code := NULL;
  p_rounding_rule_code  := NULL;

 IF  ZX_GLOBAL_STRUCTURES_PKG.g_cust_site_use_info_tbl.exists(p_site_use_id) then
          p_Rounding_Rule_Code:=
                           ZX_GLOBAL_STRUCTURES_PKG.g_cust_site_use_info_tbl(p_site_use_id).tax_rounding_rule;

          IF ZX_GLOBAL_STRUCTURES_PKG.g_cust_site_use_info_tbl(p_site_use_id).tax_header_level_flag = 'Y' THEN
              p_rounding_level_code := 'HEADER';
          ELSIF ZX_GLOBAL_STRUCTURES_PKG.g_cust_site_use_info_tbl(p_site_use_id).tax_header_level_flag = 'N' THEN
              p_rounding_level_code := 'LINE';
          END IF;

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_STATEMENT,'ZX_TDS_TAX_ROUNDING_PKG.Get_Reg_Site_Uses',
                             'Site Use information found in cache');
         END IF;
 ELSE
      OPEN c_site_uses (
           p_site_use_id,
           p_account_site_id,
           p_account_id);

      FETCH c_site_uses INTO
              l_tax_reference,
              l_tax_code,
              l_tax_rounding_rule,
              l_tax_header_level_flag,
              l_Tax_Classification;

      CLOSE c_site_uses;

      -- Populate the cache
      ZX_GLOBAL_STRUCTURES_PKG.g_cust_site_use_info_tbl(p_site_use_id).site_use_id := p_site_use_id;
      ZX_GLOBAL_STRUCTURES_PKG.g_cust_site_use_info_tbl(p_site_use_id).tax_rounding_rule:= l_tax_rounding_rule;
      ZX_GLOBAL_STRUCTURES_PKG.g_cust_site_use_info_tbl(p_site_use_id).tax_header_level_flag := l_tax_header_level_flag;
      ZX_GLOBAL_STRUCTURES_PKG.g_cust_site_use_info_tbl(p_site_use_id).tax_code := l_tax_code;
      ZX_GLOBAL_STRUCTURES_PKG.g_cust_site_use_info_tbl(p_site_use_id).Tax_Classification:= l_Tax_Classification;
      ZX_GLOBAL_STRUCTURES_PKG.g_cust_site_use_info_tbl(p_site_use_id).tax_reference := l_tax_reference;

      p_Rounding_Rule_Code:=  l_tax_rounding_rule;

      IF l_tax_header_level_flag = 'Y' THEN
           p_rounding_level_code := 'HEADER';
      ELSIF l_tax_header_level_flag = 'N' THEN
           p_rounding_level_code := 'LINE';
      END IF;


  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.Get_Reg_Site_Uses.END',
                   'ZX_TDS_TAX_ROUNDING_PKG: Get_Reg_Site_Uses(-)'||'rounding level code :'||p_rounding_level_code
                                                                  ||'rounding rule code: '||p_Rounding_Rule_Code);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF c_site_uses%isopen THEN
       CLOSE c_site_uses;
    END IF;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.Get_Reg_Site_Uses.END',
                   'Exception in ZX_TDS_TAX_ROUNDING_PKG.Get_Reg_Site_Uses('||SQLCODE||SQLERRM);
    END IF;
END Get_Reg_Site_Uses;

-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  Get_Registration_Accts
--
--  DESCRIPTION

PROCEDURE  Get_Registration_Accts(
             p_account_id             IN   ZX_REGISTRATIONS.ACCOUNT_ID%TYPE,
             p_rounding_level_code    OUT NOCOPY  ZX_PARTY_TAX_PROFILE.ROUNDING_LEVEL_CODE%TYPE,
             p_rounding_rule_code     OUT NOCOPY  ZX_PARTY_TAX_PROFILE.ROUNDING_RULE_CODE%TYPE,
             p_return_status          OUT NOCOPY  VARCHAR2 )

IS

  CURSOR c_customer_account (
    c_account_id    ZX_REGISTRATIONS.ACCOUNT_ID%TYPE)
  IS
  SELECT
    tax_code,
    tax_header_level_flag,
    tax_rounding_rule
  FROM  hz_cust_accounts
  WHERE cust_account_id = c_account_id;

  l_tax_code               hz_cust_site_uses_all.Tax_Code%TYPE;
  l_tax_header_level_flag  hz_cust_site_uses_all.tax_header_level_flag%TYPE;
  l_tax_rounding_rule      hz_cust_site_uses_all.Tax_Rounding_rule%TYPE;


BEGIN

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.Get_Registration_Accts.BEGIN',
                   'ZX_TDS_TAX_ROUNDING_PKG: Get_Registration_Accts(+)');
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.Get_Registration_Accts',
                   'p_account_id :  ' || TO_CHAR(p_account_id)) ;

  END IF;

  p_return_status       := FND_API.G_RET_STS_SUCCESS;
  p_rounding_level_code := NULL;
  p_rounding_rule_code  := NULL;

  IF ZX_GLOBAL_STRUCTURES_PKG.g_cust_acct_info_tbl.exists(p_account_id) THEN
               p_Rounding_Rule_Code:=
                     ZX_GLOBAL_STRUCTURES_PKG.g_cust_acct_info_tbl(p_account_id).tax_rounding_rule;

              IF ZX_GLOBAL_STRUCTURES_PKG.g_cust_acct_info_tbl(p_account_id).tax_header_level_flag = 'Y' THEN
                  p_rounding_level_code := 'HEADER';
              ELSIF ZX_GLOBAL_STRUCTURES_PKG.g_cust_acct_info_tbl(p_account_id).tax_header_level_flag = 'N' THEN
                  p_rounding_level_code := 'LINE';
              END IF;

              IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.STRING(G_LEVEL_STATEMENT,'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.Get_Registration_Accts',
                               'Cust Account information found in cache');
              END IF;
  ELSE
              OPEN c_customer_account (p_account_id);

              FETCH c_customer_account INTO
                l_tax_code,
                l_tax_header_level_flag,
                l_tax_rounding_rule;

              CLOSE c_customer_account;

              p_Rounding_Rule_Code:= l_tax_rounding_rule;

              IF l_tax_header_level_flag = 'Y' THEN
                  p_rounding_level_code := 'HEADER';
              ELSIF l_tax_header_level_flag = 'N' THEN
                  p_rounding_level_code := 'LINE';
              END IF;


              ZX_GLOBAL_STRUCTURES_PKG.g_cust_acct_info_tbl(p_account_id).CUST_ACCOUNT_ID := p_account_id;
              ZX_GLOBAL_STRUCTURES_PKG.g_cust_acct_info_tbl(p_account_id).TAX_CODE := l_tax_code;
              ZX_GLOBAL_STRUCTURES_PKG.g_cust_acct_info_tbl(p_account_id).TAX_ROUNDING_RULE := l_tax_rounding_rule;
              ZX_GLOBAL_STRUCTURES_PKG.g_cust_acct_info_tbl(p_account_id).TAX_HEADER_LEVEL_FLAG := l_tax_header_level_flag;

  END IF;


  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.Get_Registration_Accts.END',
                   'ZX_TDS_TAX_ROUNDING_PKG: Get_Registration_Accts(-)'||'rounding level code :'||p_rounding_level_code
                                                                       ||'rounding rule code: '||p_Rounding_Rule_Code);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF c_customer_account%ISOPEN THEN
       CLOSE c_customer_account;
    END IF;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.Get_Registration_Accts',
                   'Exception in ZX_TDS_TAX_ROUNDING_PKG.Get_Registration_Accts: '||SQLCODE||SQLERRM);
    END IF;
END Get_Registration_Accts;


-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  Get_Registration_Party
--
--  DESCRIPTION

PROCEDURE  Get_Registration_Party(
             p_party_tax_profile_id   IN  ZX_PARTY_TAX_PROFILE.PARTY_TAX_PROFILE_ID%TYPE,
             p_rounding_level_code    OUT NOCOPY  ZX_PARTY_TAX_PROFILE.ROUNDING_LEVEL_CODE%TYPE,
             p_rounding_rule_code     OUT NOCOPY  ZX_PARTY_TAX_PROFILE.ROUNDING_RULE_CODE%TYPE,
             p_return_status          OUT NOCOPY  VARCHAR2 )
IS

  l_tbl_index binary_integer;

BEGIN

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.Get_Registration_Party.BEGIN',
                   'ZX_TDS_TAX_ROUNDING_PKG: Get_Registration_Party(+)');
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.Get_Registration_Party',
                   'p_party_tax_profile_id :  ' || TO_CHAR(p_party_tax_profile_id)) ;
  END IF;

  p_return_status       := FND_API.G_RET_STS_SUCCESS;
  p_rounding_level_code := NULL;
  p_rounding_rule_code  := NULL;


 ZX_TCM_PTP_PKG.GET_PARTY_TAX_PROF_INFO(
     P_PARTY_TAX_PROFILE_ID => p_party_tax_profile_id,
     X_TBL_INDEX            => l_tbl_index,
     X_RETURN_STATUS  	    => p_return_status);

  IF L_TBL_INDEX is not null then
    p_rounding_level_code :=
        ZX_GLOBAL_STRUCTURES_PKG.G_PARTY_TAX_PROF_INFO_TBL(p_party_tax_profile_id).rounding_level_code;
    p_rounding_rule_code :=
        ZX_GLOBAL_STRUCTURES_PKG.G_PARTY_TAX_PROF_INFO_TBL(p_party_tax_profile_id).rounding_rule_code;
  ELSE

    IF (g_level_procedure >= g_current_runtime_level ) THEN
         FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.Get_Registration_Party',
                   'ZX_TDS_TAX_ROUNDING_PKG: The party tax profile id is not valid: '||p_party_tax_profile_id);
    END IF;

  END IF;


  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.Get_Registration_Party.END',
                   'ZX_TDS_TAX_ROUNDING_PKG: Get_Registration_Party(-)'||'rounding level code :'||p_rounding_level_code);
  END IF;

EXCEPTION

   WHEN OTHERS THEN
      IF (g_level_unexpected >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_unexpected,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.Get_Registration_Party',
                   'ZX_TDS_TAX_ROUNDING_PKG: Get_Registration_Party'||'Exception in ZX_TDS_TAX_ROUNDING_PKG.Get_Registration_Party '||
                                             SQLCODE||SQLERRM);
      END IF;

END Get_Registration_Party;
-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  get_rounding_level
--
--  DESCRIPTION
--
--  This procedure determines the rounding level for a whole document
--

PROCEDURE get_rounding_level(

            p_parent_ptp_id          IN  zx_party_tax_profile.party_tax_profile_id%TYPE,
            p_site_ptp_id            IN  zx_party_tax_profile.party_tax_profile_id%TYPE,
            p_account_Type_Code      IN  zx_registrations.account_type_code%TYPE,
            p_account_id             IN  ZX_REGISTRATIONS.ACCOUNT_ID%TYPE,
            p_account_site_id        IN  ZX_REGISTRATIONS.ACCOUNT_SITE_ID%TYPE,
            p_site_use_id            IN  HZ_CUST_SITE_USES_ALL.SITE_USE_ID%TYPE,
            p_rounding_level_code    OUT NOCOPY  ZX_PARTY_TAX_PROFILE.ROUNDING_LEVEL_CODE%TYPE,
            p_rounding_rule_code     OUT NOCOPY  ZX_PARTY_TAX_PROFILE.ROUNDING_RULE_CODE%TYPE,
           p_return_status           OUT NOCOPY  VARCHAR2,
           p_error_buffer            OUT NOCOPY  VARCHAR2
         )
IS
BEGIN

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.get_rounding_level.BEGIN',
                   'ZX_TDS_TAX_ROUNDING_PKG: get_rounding_level(+)');
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.get_rounding_level',
                   'p_parent_ptp_id :  ' || TO_CHAR(p_parent_ptp_id));
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.get_rounding_level',
                   'p_site_ptp_id : ' || TO_CHAR(p_site_ptp_id));
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.get_rounding_level',
                   'p_account_Type_Code : ' || p_account_Type_Code);
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.get_rounding_level',
                   'p_account_id : ' || TO_CHAR(p_account_id));
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.get_rounding_level',
                   'p_account_site_id : ' || TO_CHAR(p_account_site_id));
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.get_rounding_level',
                   'p_site_use_id : ' || TO_CHAR(p_site_use_id));

  END IF;

  p_return_status       := FND_API.G_RET_STS_SUCCESS;
  p_rounding_level_code := NULL;
  p_rounding_rule_code  := NULL;


  IF (p_account_id is not NULL) AND (p_account_site_id IS NOT NULL) THEN

    IF p_account_type_code = 'SUPPLIER' THEN
      -- Get supplier information from ap_suppliers-sites
      Get_Supplier_Site(
                   p_account_id
                   ,p_account_site_id
                   ,p_rounding_level_code
                   ,p_rounding_rule_code
                   ,p_return_status
                   );
      IF p_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
        RETURN;
      End IF;

    ELSIF p_account_type_code = 'CUSTOMER' THEN
      -- Check if account site use parameter is not null
      IF p_site_use_id IS NOT NULL THEN
        Get_Reg_Site_Uses(
                          p_account_id
                          ,p_account_site_id
                          ,p_site_use_id
                          ,p_rounding_level_code
                          ,p_rounding_rule_code
                          ,p_return_status
                          );
        IF p_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
          RETURN;
        END IF;

        -- Get registration account level
        IF p_rounding_level_code IS NULL THEN
          Get_Registration_Accts(
                                 p_account_id
                                 ,p_rounding_level_code
                                 ,p_rounding_rule_code
                                 ,p_return_status
                                 );
          IF p_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
            RETURN;
          END IF;

        END If;
      END IF;        --p_site_use_id is not null
    END IF;          --  p_account_type
  END IF;            -- p_account_id is not null

  IF p_rounding_level_code IS NULL THEN
    IF p_site_ptp_id IS NOT NULL THEN
      -- Get registration infomation from the site
      Get_Registration_Party(p_site_ptp_id
                             ,p_rounding_level_code
                             ,p_rounding_rule_code
                             ,p_return_status
                             );

      IF p_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
        RETURN;
      END IF;

      IF p_rounding_level_code IS NULL THEN
        -- get registration information from the parent
        Get_Registration_Party(p_parent_ptp_id
                               ,p_rounding_level_code
                               ,p_rounding_rule_code
                               ,p_return_status
                               );
      END IF;
   END IF;
  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.get_rounding_level.END',
                   'ZX_TDS_TAX_ROUNDING_PKG: get_rounding_level(-)'||'rounding level code :'||p_rounding_level_code);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.get_rounding_level',
                      p_error_buffer);
    END IF;

END get_rounding_level;


-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  get_funcl_curr_info
--
--  DESCRIPTION
--  This procedure gets the functional currency code, minimum
--  accountable unit and precision of a functional currency from
--  fnd_currencies based on the ledger id

PROCEDURE get_funcl_curr_info(
             p_ledger_id           IN             ZX_LINES.LEDGER_ID%TYPE,
             p_funcl_currency_code    OUT NOCOPY FND_CURRENCIES.CURRENCY_CODE%TYPE,
             p_funcl_min_acct_unit    OUT NOCOPY FND_CURRENCIES.MINIMUM_ACCOUNTABLE_UNIT%TYPE,
             p_funcl_precision        OUT NOCOPY FND_CURRENCIES.PRECISION%TYPE,

             p_return_status          OUT NOCOPY VARCHAR2,
             p_error_buffer           OUT NOCOPY VARCHAR2
         )
IS

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.get_funcl_curr_info.BEGIN',
                   'ZX_TDS_TAX_ROUNDING_PKG: get_funcl_curr_info(+)'||
                   ' p_ledger_id  = ' || to_char(p_ledger_id));

  END IF;

  p_return_status :=  FND_API.G_RET_STS_SUCCESS;

  --
  -- get  functional currency info
  --
  IF ZX_TDS_UTILITIES_PKG.g_currency_rec_tbl.EXISTS(p_ledger_id)  THEN
    --
    -- functional currency info can be obtained from the cache structure
    --
    p_funcl_currency_code := ZX_TDS_UTILITIES_PKG.g_currency_rec_tbl(p_ledger_id).currency_code;
    p_funcl_min_acct_unit := ZX_TDS_UTILITIES_PKG.g_currency_rec_tbl(p_ledger_id).minimum_accountable_unit;
    p_funcl_precision := ZX_TDS_UTILITIES_PKG.g_currency_rec_tbl(p_ledger_id).precision;
  ELSE
    --
    -- functional currency info does not exist in cache structure
    -- need to obtain from the database
    --
    ZX_TDS_UTILITIES_PKG.populate_currency_cache
                 (p_ledger_id,
                  p_return_status,
                  p_error_buffer );

    IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      --
      -- error getting min acct unit and precision
      -- return original unround amount to caller
      --
      RETURN;
    END IF;

   p_funcl_currency_code := ZX_TDS_UTILITIES_PKG.g_currency_rec_tbl(p_ledger_id).currency_code;
    p_funcl_min_acct_unit := ZX_TDS_UTILITIES_PKG.g_currency_rec_tbl(p_ledger_id).minimum_accountable_unit;
    p_funcl_precision     := ZX_TDS_UTILITIES_PKG.g_currency_rec_tbl(p_ledger_id).precision;

  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.get_funcl_curr_info.END',
                   'ZX_TDS_TAX_ROUNDING_PKG: get_funcl_curr_info(-)'||
                   ' functional currency = ' || p_funcl_currency_code ||
                   ' min acct unit = ' ||
                    to_char(p_funcl_min_acct_unit)||
                   ' precision = ' ||
                    to_char(p_funcl_precision));
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_TAX_ROUNDING_PKG.get_funcl_curr_info',
                      p_error_buffer);
    END IF;

END get_funcl_curr_info;
-----------------------------------------------------------------------

END  ZX_TDS_TAX_ROUNDING_PKG;

/
