--------------------------------------------------------
--  DDL for Package ZX_TDS_TAX_ROUNDING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_TDS_TAX_ROUNDING_PKG" AUTHID CURRENT_USER as
/* $Header: zxdiroundtaxpkgs.pls 120.25.12010000.3 2009/10/12 18:46:37 tsen ship $ */


TYPE currency_conversion_rec IS RECORD
(
  min_acct_unit        ZX_TAXES_B.MINIMUM_ACCOUNTABLE_UNIT%TYPE,
  precision            ZX_TAXES_B.TAX_PRECISION%TYPE,
  conversion_rate      ZX_LINES.CURRENCY_CONVERSION_RATE%TYPE,
  derive_effective     FND_CURRENCIES.DERIVE_EFFECTIVE%TYPE,
  derive_type          FND_CURRENCIES.DERIVE_TYPE%TYPE,
  conversion_date      ZX_LINES.TAX_CURRENCY_CONVERSION_DATE%TYPE,
  currency_type        VARCHAR2(30)
);


TYPE currency_conversion_tbl IS TABLE OF currency_conversion_rec
     INDEX BY  VARCHAR2(15);

TYPE tax_curr_conversion_rate_tbl IS TABLE OF NUMBER
     INDEX BY BINARY_INTEGER;

TYPE hdr_grp_rec_type IS RECORD
(
  application_id                ZX_LINES.application_id%TYPE,
  event_class_code              ZX_LINES.event_class_code%TYPE,
  entity_code                   ZX_LINES.entity_code%TYPE,
  trx_id                        ZX_LINES.trx_id%TYPE,
  tax_regime_code               ZX_REGIMES_B.TAX_REGIME_CODE%TYPE,
  tax                           ZX_TAXES_B.tax%TYPE,
  tax_status_code               ZX_STATUS_B.TAX_STATUS_CODE%TYPE,
  tax_rate_code                 ZX_RATES_B.TAX_RATE_CODE%TYPE,
  tax_rate                      ZX_LINES.TAX_RATE%TYPE,
  tax_rate_id                   ZX_LINES.TAX_RATE_ID%TYPE,
  tax_jurisdiction_code         ZX_LINES.TAX_JURISDICTION_CODE%TYPE,
  taxable_basis_formula         ZX_FORMULA_B.FORMULA_CODE%TYPE,
  tax_calculation_formula       ZX_FORMULA_B.FORMULA_CODE%TYPE,
  tax_Amt_Included_Flag         ZX_LINES.TAX_AMT_INCLUDED_FLAG%TYPE,
  compounding_tax_flag          ZX_LINES.COMPOUNDING_TAX_FLAG%TYPE,
  historical_flag               ZX_LINES.HISTORICAL_FLAG%TYPE,
  self_assessed_flag            ZX_LINES.SELF_ASSESSED_FLAG%TYPE,
  overridden_flag               ZX_LINES.OVERRIDDEN_FLAG%TYPE,
  manually_entered_flag         ZX_LINES.MANUALLY_ENTERED_FLAG%TYPE,
  copied_from_other_doc_flag    ZX_LINES.COPIED_FROM_OTHER_DOC_FLAG%TYPE,
  associated_child_frozen_flag  ZX_LINES.ASSOCIATED_CHILD_FROZEN_FLAG%TYPE,
  tax_only_line_flag            ZX_LINES.TAX_ONLY_LINE_FLAG%TYPE,
  mrc_tax_line_flag             ZX_LINES.MRC_TAX_LINE_FLAG%TYPE,
  reporting_only_flag           ZX_LINES.REPORTING_ONLY_FLAG%TYPE,
  applied_from_application_id   ZX_LINES.APPLIED_FROM_APPLICATION_ID%TYPE,
  applied_from_event_class_code ZX_LINES.APPLIED_FROM_EVENT_CLASS_CODE%TYPE,
  applied_from_entity_code      ZX_LINES.APPLIED_FROM_ENTITY_CODE%TYPE,
  applied_from_trx_id           ZX_LINES.APPLIED_FROM_TRX_ID%TYPE,
  applied_from_line_id          ZX_LINES.APPLIED_FROM_LINE_ID%TYPE,
  adjusted_doc_application_id   ZX_LINES.ADJUSTED_DOC_APPLICATION_ID%TYPE,
  adjusted_doc_entity_code      ZX_LINES.ADJUSTED_DOC_ENTITY_CODE%TYPE,
  adjusted_doc_event_class_code ZX_LINES.ADJUSTED_DOC_EVENT_CLASS_CODE%TYPE,
  adjusted_doc_trx_id           ZX_LINES.ADJUSTED_DOC_TRX_ID%TYPE,
  applied_to_application_id     ZX_LINES.APPLIED_TO_APPLICATION_ID%TYPE,
  applied_to_event_class_code   ZX_LINES.APPLIED_TO_EVENT_CLASS_CODE%TYPE,
  applied_to_entity_code        ZX_LINES.APPLIED_TO_ENTITY_CODE%TYPE,
  applied_to_trx_id             ZX_LINES.APPLIED_TO_TRX_ID%TYPE,
  applied_to_line_id            ZX_LINES.APPLIED_TO_LINE_ID%TYPE,
  tax_exemption_id              ZX_LINES.TAX_EXEMPTION_ID%TYPE,
  tax_rate_before_exemption     ZX_LINES.TAX_RATE_BEFORE_EXEMPTION%TYPE,
  tax_rate_name_before_exemption ZX_LINES.TAX_RATE_NAME_BEFORE_EXEMPTION%TYPE,
  exempt_rate_modifier          ZX_LINES.EXEMPT_RATE_MODIFIER%TYPE,
  exempt_certificate_number     ZX_LINES.EXEMPT_CERTIFICATE_NUMBER%TYPE,
  exempt_reason                 ZX_LINES.EXEMPT_REASON%TYPE,
  exempt_reason_code            ZX_LINES.EXEMPT_REASON_CODE%TYPE,
  tax_exception_id              ZX_LINES.TAX_EXCEPTION_ID%TYPE,
  tax_rate_before_exception     ZX_LINES.TAX_RATE_BEFORE_EXCEPTION%TYPE,
  tax_rate_name_before_exception ZX_LINES.TAX_RATE_NAME_BEFORE_EXCEPTION%TYPE,
  exception_rate                ZX_LINES.EXCEPTION_RATE%TYPE,
  ledger_id                     ZX_LINES.LEDGER_ID%TYPE,
  legal_entity_id               ZX_LINES.LEGAL_ENTITY_ID%TYPE,
  establishment_id              ZX_LINES.ESTABLISHMENT_ID%TYPE,
  currency_conversion_date      ZX_LINES.CURRENCY_CONVERSION_DATE%TYPE,
  currency_conversion_type      ZX_LINES.CURRENCY_CONVERSION_TYPE%TYPE,
  currency_conversion_rate      ZX_LINES.CURRENCY_CONVERSION_RATE%TYPE,
  record_type_code              ZX_LINES.RECORD_TYPE_CODE%TYPE
);

TYPE header_rounding_info_rec IS RECORD
(
  tax_line_id                ZX_LINES.TAX_LINE_ID%TYPE,
  tax_id                     ZX_LINES.TAX_ID%TYPE,
  Rounding_Rule_Code         ZX_TAXES_B.ROUNDING_RULE_CODE%TYPE,
  min_acct_unit              ZX_TAXES_B.MINIMUM_ACCOUNTABLE_UNIT%TYPE,
  precision                  ZX_TAXES_B.TAX_PRECISION%TYPE,
  sum_unrnd_tax_amt          NUMBER,
  sum_rnd_tax_amt            NUMBER,
  sum_rnd_tax_curr           NUMBER,
  sum_rnd_funcl_curr         NUMBER,
  max_unrnd_tax_amt          NUMBER,
  total_rec_in_grp           NUMBER,
  tax_curr_conv_rate         ZX_LINES.TAX_CURRENCY_CONVERSION_RATE%TYPE,
  currency_conversion_rate   ZX_LINES.CURRENCY_CONVERSION_RATE%TYPE,
  rnd_tax_amt                NUMBER,
  rnd_tax_amt_tax_curr        NUMBER,
  rnd_tax_amt_funcl_curr     NUMBER,
  rnd_taxable_amt_tax_curr   NUMBER,
  rnd_taxable_amt_funcl_curr NUMBER,
  tax_calculation_formula    ZX_LINES.TAX_CALCULATION_FORMULA%TYPE,
  ledger_id                  ZX_LINES.LEDGER_ID%TYPE,
  tax_rate                   ZX_LINES.TAX_RATE%TYPE,
  mrc_tax_line_flag          zx_lines.mrc_tax_line_flag%TYPE
);

TYPE hdr_rounding_info_tbl IS TABLE OF header_rounding_info_rec
     INDEX BY BINARY_INTEGER;

TYPE header_rounding_curr_rec IS RECORD
(
  tax_line_id                ZX_LINES.TAX_LINE_ID%TYPE,
  sum_unrnd_tax_amt          NUMBER,
  sum_rnd_curr               NUMBER,
  max_unrnd_tax_amt          NUMBER,
  total_rec_in_grp           NUMBER,
  currency_conversion_rate   ZX_LINES.CURRENCY_CONVERSION_RATE%TYPE,
  rnd_tax_amt_curr           NUMBER,
  rnd_taxable_amt_curr       NUMBER,
  tax_calculation_formula    ZX_LINES.TAX_CALCULATION_FORMULA%TYPE,
  ledger_id                  ZX_LINES.LEDGER_ID%TYPE,
  tax_rate                   ZX_LINES.TAX_RATE%TYPE
);

TYPE hdr_rounding_curr_tbl IS TABLE OF header_rounding_curr_rec
     INDEX BY BINARY_INTEGER;

TYPE tax_line_id_tbl IS TABLE OF
  ZX_LINES.tax_line_id%TYPE
  INDEX BY BINARY_INTEGER;

TYPE manually_entered_flag_tbl IS TABLE OF
  ZX_LINES.Manually_Entered_Flag%TYPE
  INDEX BY BINARY_INTEGER;

TYPE tax_id_tbl IS TABLE OF
  ZX_LINES.tax_id%TYPE
  INDEX BY BINARY_INTEGER;

TYPE tax_regime_code_tbl IS TABLE OF
  ZX_LINES.tax_regime_code%TYPE
  INDEX BY BINARY_INTEGER;

TYPE tax_tbl IS TABLE OF
  ZX_LINES.tax%TYPE
  INDEX BY BINARY_INTEGER;

TYPE tax_status_code_tbl IS TABLE OF
  ZX_LINES.tax_status_code%TYPE
  INDEX BY BINARY_INTEGER;

TYPE tax_rate_code_tbl IS TABLE OF
  ZX_LINES.tax_rate_code%TYPE
  INDEX BY BINARY_INTEGER;

TYPE tax_rate_tbl IS TABLE OF
  ZX_LINES.tax_rate%TYPE
  INDEX BY BINARY_INTEGER;

TYPE tax_rate_id_tbl IS TABLE OF
  ZX_LINES.tax_rate_id%TYPE
  INDEX BY BINARY_INTEGER;

TYPE tax_jurisdiction_code_tbl IS TABLE OF
  ZX_LINES.tax_jurisdiction_code%TYPE
  INDEX BY BINARY_INTEGER;

TYPE taxable_basis_formula_tbl IS TABLE OF
  ZX_LINES.taxable_basis_formula%TYPE
  INDEX BY BINARY_INTEGER;

TYPE tax_calculation_formula_tbl IS TABLE OF
  ZX_LINES.tax_calculation_formula%TYPE
  INDEX BY BINARY_INTEGER;

TYPE tax_amt_included_flag_tbl IS TABLE OF
  ZX_LINES.Tax_Amt_Included_Flag%TYPE
  INDEX BY BINARY_INTEGER;

TYPE compounding_tax_flag_tbl IS TABLE OF
  ZX_LINES.compounding_tax_flag%TYPE
  INDEX BY BINARY_INTEGER;

TYPE  historical_flag_tbl IS TABLE OF
  ZX_LINES.historical_flag%TYPE
  INDEX BY BINARY_INTEGER;

TYPE  self_assessed_flag_tbl IS TABLE OF
  ZX_LINES.self_assessed_flag%TYPE
  INDEX BY BINARY_INTEGER;

TYPE overridden_flag_tbl IS TABLE OF
  ZX_LINES.overridden_flag%TYPE
  INDEX BY BINARY_INTEGER;

TYPE  cop_from_other_doc_flag_tbl IS TABLE OF
  ZX_LINES.copied_from_other_doc_flag%TYPE
  INDEX BY BINARY_INTEGER;

TYPE  assoc_child_frozen_flag_tbl IS TABLE OF
  ZX_LINES.associated_child_frozen_flag%TYPE
  INDEX BY BINARY_INTEGER;

TYPE  tax_only_line_flag_tbl IS TABLE OF
  ZX_LINES.tax_only_line_flag%TYPE
  INDEX BY BINARY_INTEGER;

TYPE  mrc_tax_line_flag_tbl IS TABLE OF
  ZX_LINES.mrc_tax_line_flag%TYPE
  INDEX BY BINARY_INTEGER;

TYPE  reporting_only_flag_tbl IS TABLE OF
  ZX_LINES.reporting_only_flag%TYPE
  INDEX BY BINARY_INTEGER;

TYPE  applied_from_applic_id_tbl IS TABLE OF
  ZX_LINES.applied_from_application_id%TYPE
  INDEX BY BINARY_INTEGER;

TYPE  applied_from_evnt_cls_cd_tbl IS TABLE OF
  ZX_LINES.applied_from_event_class_code%TYPE
  INDEX BY BINARY_INTEGER;

TYPE  applied_from_entity_code_tbl IS TABLE OF
  ZX_LINES.applied_from_entity_code%TYPE
  INDEX BY BINARY_INTEGER;

TYPE  applied_from_trx_id_tbl IS TABLE OF
  ZX_LINES.applied_from_trx_id%TYPE
  INDEX BY BINARY_INTEGER;

TYPE  applied_from_line_id_tbl IS TABLE OF
  ZX_LINES.applied_from_line_id%TYPE
  INDEX BY BINARY_INTEGER;

TYPE  adjusted_doc_applic_id_tbl IS TABLE OF
  ZX_LINES.adjusted_doc_application_id%TYPE
  INDEX BY BINARY_INTEGER;

TYPE  adjusted_doc_entity_code_tbl IS TABLE OF
  ZX_LINES.adjusted_doc_entity_code%TYPE
  INDEX BY BINARY_INTEGER;

TYPE  adjusted_doc_evnt_cls_cd_tbl IS TABLE OF
  ZX_LINES.adjusted_doc_event_class_code%TYPE
  INDEX BY BINARY_INTEGER;

TYPE  adjusted_doc_trx_id_tbl IS TABLE OF
  ZX_LINES.adjusted_doc_trx_id%TYPE
  INDEX BY BINARY_INTEGER;

TYPE  applied_to_applic_id_tbl IS TABLE OF
  ZX_LINES.applied_to_application_id%TYPE
  INDEX BY BINARY_INTEGER;

TYPE  applied_to_evnt_cls_cd_tbl IS TABLE OF
  ZX_LINES.applied_to_event_class_code%TYPE
  INDEX BY BINARY_INTEGER;

TYPE  applied_to_entity_code_tbl IS TABLE OF
  ZX_LINES.applied_to_entity_code%TYPE
  INDEX BY BINARY_INTEGER;

TYPE  applied_to_trx_id_tbl IS TABLE OF
  ZX_LINES.applied_to_trx_id%TYPE
  INDEX BY BINARY_INTEGER;

TYPE  applied_to_line_id_tbl IS TABLE OF
  ZX_LINES.applied_to_line_id%TYPE
  INDEX BY BINARY_INTEGER;

TYPE  tax_exemption_id_tbl IS TABLE OF
  ZX_LINES.tax_exemption_id%TYPE
  INDEX BY BINARY_INTEGER;

TYPE  rate_before_exemption_tbl IS TABLE OF
  ZX_LINES.tax_rate_before_exemption%TYPE
  INDEX BY BINARY_INTEGER;

TYPE  rate_name_before_exemption_tbl IS TABLE OF
  ZX_LINES.tax_rate_name_before_exemption%TYPE
  INDEX BY BINARY_INTEGER;

TYPE  exempt_rate_modifier_tbl IS TABLE OF
  ZX_LINES.exempt_rate_modifier%TYPE
  INDEX BY BINARY_INTEGER;

TYPE  exempt_certificate_num_tbl IS TABLE OF
  ZX_LINES.exempt_certificate_number%TYPE
  INDEX BY BINARY_INTEGER;

TYPE  exempt_reason_tbl IS TABLE OF
  ZX_LINES.exempt_reason%TYPE
  INDEX BY BINARY_INTEGER;

TYPE  exempt_reason_code_tbl IS TABLE OF
  ZX_LINES.exempt_reason_code%TYPE
  INDEX BY BINARY_INTEGER;

TYPE  tax_exception_id_tbl IS TABLE OF
  ZX_LINES.tax_exception_id%TYPE
  INDEX BY BINARY_INTEGER;

TYPE  rate_before_exception_tbl IS TABLE OF
  ZX_LINES.tax_rate_before_exception%TYPE
  INDEX BY BINARY_INTEGER;

TYPE  rate_name_before_exception_tbl IS TABLE OF
  ZX_LINES.tax_rate_name_before_exception%TYPE
  INDEX BY BINARY_INTEGER;

TYPE  exception_rate_tbl IS TABLE OF
  ZX_LINES.exception_rate%TYPE
  INDEX BY BINARY_INTEGER;

TYPE min_acct_unit_tbl IS TABLE OF
  ZX_LINES.minimum_accountable_unit%TYPE
  INDEX BY BINARY_INTEGER;

TYPE precision_tbl IS TABLE OF
  ZX_LINES.precision%TYPE
  INDEX BY BINARY_INTEGER;

TYPE trx_currency_code_tbl IS TABLE OF
  ZX_LINES.trx_currency_code%TYPE
  INDEX BY BINARY_INTEGER;

TYPE tax_currency_code_tbl IS TABLE OF
  ZX_LINES.tax_currency_code%TYPE
  INDEX BY BINARY_INTEGER;

TYPE tax_curr_conv_date_tbl IS TABLE OF
  ZX_LINES.tax_currency_conversion_date%TYPE
  INDEX BY BINARY_INTEGER;

TYPE tax_curr_conv_type_tbl IS TABLE OF
  ZX_LINES.tax_currency_conversion_type%TYPE
  INDEX BY BINARY_INTEGER;

TYPE tax_curr_conv_rate_tbl IS TABLE OF
  ZX_LINES.tax_currency_conversion_rate%TYPE
  INDEX BY BINARY_INTEGER;

TYPE tax_amt_tbl IS TABLE OF
  ZX_LINES.tax_amt%TYPE
  INDEX BY BINARY_INTEGER;

TYPE taxable_amt_tbl IS TABLE OF
  ZX_LINES.taxable_amt%TYPE
  INDEX BY BINARY_INTEGER;

TYPE cal_tax_amt_tbl IS TABLE OF
  ZX_LINES.cal_tax_amt%TYPE
  INDEX BY BINARY_INTEGER;

TYPE tax_amt_tax_curr_tbl IS TABLE OF
  ZX_LINES.tax_amt_tax_curr%TYPE
  INDEX BY BINARY_INTEGER;

TYPE taxable_amt_tax_curr_tbl IS TABLE OF
  ZX_LINES.taxable_amt_tax_curr%TYPE
  INDEX BY BINARY_INTEGER;

TYPE cal_tax_amt_tax_curr_tbl IS TABLE OF
  ZX_LINES.cal_tax_amt_tax_curr%TYPE
  INDEX BY BINARY_INTEGER;

TYPE rounding_rule_tbl IS TABLE OF
  ZX_LINES.Rounding_Rule_Code%TYPE
  INDEX BY BINARY_INTEGER;

TYPE unrounded_taxable_amt_tbl IS TABLE OF
  ZX_LINES.unrounded_taxable_amt%TYPE
  INDEX BY BINARY_INTEGER;

TYPE unrounded_tax_amt_tbl IS TABLE OF
  ZX_LINES.unrounded_tax_amt%TYPE
  INDEX BY BINARY_INTEGER;

TYPE currency_conversion_type_tbl IS TABLE OF
  ZX_LINES.currency_conversion_type%TYPE
  INDEX BY BINARY_INTEGER;

TYPE currency_conversion_rate_tbl IS TABLE OF
  ZX_LINES.currency_conversion_rate%TYPE
  INDEX BY BINARY_INTEGER;

TYPE currency_conversion_date_tbl IS TABLE OF
  ZX_LINES.currency_conversion_date%TYPE
  INDEX BY BINARY_INTEGER;

TYPE tax_amt_funcl_curr_tbl IS TABLE OF
  ZX_LINES.tax_amt_funcl_curr%TYPE
  INDEX BY BINARY_INTEGER;

TYPE taxable_amt_funcl_curr_tbl IS TABLE OF
  ZX_LINES.taxable_amt_funcl_curr%TYPE
  INDEX BY BINARY_INTEGER;

TYPE cal_tax_amt_funcl_curr_tbl IS TABLE OF
  ZX_LINES.cal_tax_amt_funcl_curr%TYPE
  INDEX BY BINARY_INTEGER;

TYPE rounding_level_tbl IS TABLE OF
  ZX_LINES.Rounding_Level_Code%TYPE
  INDEX BY BINARY_INTEGER;

TYPE ledger_id_tbl IS TABLE OF
  ZX_LINES.ledger_id%TYPE
  INDEX BY BINARY_INTEGER;

TYPE prd_total_tax_amt_tbl IS TABLE OF
  ZX_LINES.prd_total_tax_amt%TYPE
  INDEX BY BINARY_INTEGER;

TYPE prd_total_tax_amt_tax_curr_tbl IS TABLE OF
  ZX_LINES.prd_total_tax_amt_tax_curr%TYPE
  INDEX BY BINARY_INTEGER;

TYPE prd_total_tax_amt_fcl_curr_tbl IS TABLE OF
  ZX_LINES.prd_total_tax_amt_funcl_curr%TYPE
  INDEX BY BINARY_INTEGER;

TYPE legal_entity_id_tbl IS TABLE OF
  ZX_LINES.legal_entity_id%TYPE
  INDEX BY BINARY_INTEGER;

TYPE establishment_id_tbl IS TABLE OF
  ZX_LINES.establishment_id%TYPE
  INDEX BY BINARY_INTEGER;

TYPE record_type_code_tbl IS TABLE OF
  ZX_LINES.record_type_code%TYPE
  INDEX BY BINARY_INTEGER;

TYPE tax_provider_id_tbl IS TABLE OF
  ZX_LINES.tax_provider_id%TYPE
  INDEX BY BINARY_INTEGER;

TYPE application_id_tbl IS TABLE OF
  ZX_LINES.application_id%TYPE
  INDEX BY BINARY_INTEGER;

TYPE INTERNAL_ORGANIZATION_ID_TBL IS TABLE OF
  ZX_LINES.internal_organization_id%TYPE
  INDEX BY BINARY_INTEGER;

TYPE event_class_code_tbl IS TABLE OF
  ZX_LINES.event_class_code%TYPE
  INDEX BY BINARY_INTEGER;

TYPE entity_code_tbl IS TABLE OF
  ZX_LINES.entity_code%TYPE
  INDEX BY BINARY_INTEGER;

TYPE trx_id_tbl IS TABLE OF
  ZX_LINES.trx_id%TYPE
  INDEX BY BINARY_INTEGER;

TYPE rounding_level_code_tbl IS TABLE OF
  ZX_LINES.rounding_level_code%TYPE
  INDEX BY BINARY_INTEGER;

g_currency_tbl              currency_conversion_tbl;
g_tax_curr_conv_rate_tbl    tax_curr_conversion_rate_tbl;
g_euro_code                 FND_CURRENCIES.CURRENCY_CODE%TYPE;

c_lines_per_commit CONSTANT NUMBER := ZX_TDS_CALC_SERVICES_PUB_PKG.G_LINES_PER_COMMIT;

FUNCTION round_tax(
           p_amount        IN     NUMBER,
           p_Rounding_Rule_Code IN     ZX_TAXES_B.Rounding_Rule_Code%TYPE,
           p_min_acct_unit IN     ZX_TAXES_B.MINIMUM_ACCOUNTABLE_UNIT%TYPE,
           p_precision     IN     ZX_TAXES_B.TAX_PRECISION%TYPE,
           p_return_status OUT NOCOPY VARCHAR2,
           p_error_buffer  OUT NOCOPY VARCHAR2
         ) RETURN NUMBER;

FUNCTION round_tax_funcl_curr(
             p_unround_amt   IN             ZX_LINES.TAX_AMT%TYPE,
             p_ledger_id     IN             ZX_LINES.LEDGER_ID%TYPE,
             p_return_status     OUT NOCOPY VARCHAR2,
             p_error_buffer      OUT NOCOPY VARCHAR2
         ) RETURN NUMBER;

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
             p_trx_conversion_date  IN     ZX_LINES.CURRENCY_CONVERSION_DATE%TYPE DEFAULT NULL);      --Bug7183884

PROCEDURE get_rounding_level_and_rule(
           p_event_class_rec      IN      ZX_API_PUB.EVENT_CLASS_REC_TYPE,
           p_rounding_level_code     OUT NOCOPY  ZX_PARTY_TAX_PROFILE.ROUNDING_LEVEL_CODE%TYPE,
           p_rounding_rule_code      OUT NOCOPY  ZX_PARTY_TAX_PROFILE.ROUNDING_RULE_CODE%TYPE,
           p_rnd_lvl_party_tax_prof_id
                         OUT NOCOPY ZX_LINES.ROUNDING_LVL_PARTY_TAX_PROF_ID%TYPE,
           p_rounding_lvl_party_type OUT NOCOPY  ZX_LINES.ROUNDING_LVL_PARTY_TYPE%TYPE,
           p_return_status           OUT NOCOPY  VARCHAR2,
           p_error_buffer            OUT NOCOPY  VARCHAR2
         );

PROCEDURE get_rounding_rule(
  p_trx_line_index      IN             BINARY_INTEGER,
  p_event_class_rec     IN             ZX_API_PUB.EVENT_CLASS_REC_TYPE,
  p_tax_regime_code     IN             VARCHAR2,
  p_tax                 IN             VARCHAR2,
  p_jurisdiction_code   IN             VARCHAR2,
  p_tax_determine_date  IN             DATE,
  p_rounding_rule_code     OUT NOCOPY  ZX_PARTY_TAX_PROFILE.ROUNDING_RULE_CODE%TYPE,
  p_return_status          OUT NOCOPY  VARCHAR2,
  p_error_buffer           OUT NOCOPY  VARCHAR2);

PROCEDURE perform_rounding(
           p_event_class_rec      IN      ZX_API_PUB.EVENT_CLASS_REC_TYPE,
           p_return_status                 OUT NOCOPY VARCHAR2,
           p_error_buffer                  OUT NOCOPY VARCHAR2
         );


PROCEDURE convert_and_round_curr(
                p_conversion_rate      IN OUT NOCOPY NUMBER,
                p_conversion_type      IN            VARCHAR2,
                p_conversion_date      IN            DATE,
                p_event_class_rec      IN      ZX_API_PUB.EVENT_CLASS_REC_TYPE,
                p_return_status            OUT NOCOPY  VARCHAR2,
                p_error_buffer             OUT NOCOPY  VARCHAR2
        );

PROCEDURE round_tax_amt_entered(
           p_tax_amt              IN OUT NOCOPY ZX_LINES.TAX_AMT%TYPE,
           p_tax_id               IN            ZX_TAXES_B.TAX_ID%TYPE,
           p_application_id       IN            ZX_LINES.APPLICATION_ID%TYPE,
           p_entity_code          IN            ZX_LINES.ENTITY_CODE%TYPE,
           p_event_class_code     IN            ZX_LINES.EVENT_CLASS_CODE%TYPE,
           p_trx_id               IN            ZX_LINES.TRX_ID%TYPE,
           p_return_status           OUT NOCOPY VARCHAR2,
           p_error_buffer            OUT NOCOPY VARCHAR2
         );

end ZX_TDS_TAX_ROUNDING_PKG;

/
