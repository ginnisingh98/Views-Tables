--------------------------------------------------------
--  DDL for Package Body ZX_TDS_TAX_LINES_POPU_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_TDS_TAX_LINES_POPU_PKG" as
/* $Header: zxditaxlnpoppkgb.pls 120.68.12010000.14 2010/03/19 11:14:27 hchakrob ship $ */


g_current_runtime_level      NUMBER;
g_level_statement            CONSTANT  NUMBER   := FND_LOG.LEVEL_STATEMENT;
g_level_procedure            CONSTANT  NUMBER   := FND_LOG.LEVEL_PROCEDURE;
g_level_unexpected           CONSTANT  NUMBER   := FND_LOG.LEVEL_UNEXPECTED;

-----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  cp_tsrm_val_to_zx_lines
--
--  DESCRIPTION
--
--  This procedure is called after determine tax applicability process
--  It copies TSRM parameter values to TDS global detail tax line structures
--  It is one of the entry point to Populate Tax lines process
--
--  CALLED BY
--    ZX_TDS_APPLICABILITY_DETM_PKG
--

PROCEDURE cp_tsrm_val_to_zx_lines(
            p_trx_line_index      IN     BINARY_INTEGER,
            p_begin_index         IN     BINARY_INTEGER,
            p_end_index           IN     BINARY_INTEGER,
            p_return_status       OUT NOCOPY VARCHAR2,
            p_error_buffer        OUT NOCOPY VARCHAR2
         )
IS
  j          BINARY_INTEGER;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.cp_tsrm_val_to_zx_lines.BEGIN',
                   'ZX_TDS_TAX_LINES_POPU_PKG: cp_tsrm_val_to_zx_lines(+)');
  END IF;

  --
  -- init error buffer and return status
  --
  p_return_status  := FND_API.G_RET_STS_SUCCESS;
  p_error_buffer   := NULL;

  --
  -- check if begin_index and end_index have values
  --
  IF (p_begin_index IS NULL OR p_end_index IS NULL) THEN

    IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.cp_tsrm_val_to_zx_lines.END',
                   'ZX_TDS_TAX_LINES_POPU_PKG: cp_tsrm_val_to_zx_lines(-)'||'Begin index or End index is null');

    END IF;
    RETURN;
  END IF;

  --
  -- get the index to transaction line table
  --
  j := p_trx_line_index;

  FOR i IN p_begin_index ..p_end_index LOOP

--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).account_string :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.account_string(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).adjusted_doc_application_id :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_application_id(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).adjusted_doc_entity_code :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_entity_code(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).adjusted_doc_event_class_code :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_event_class_code(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).adjusted_doc_line_id :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_line_id(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).adjusted_doc_trx_level_type :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_trx_level_type(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).adjusted_doc_trx_id :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_trx_id(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).adjusted_doc_date :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_date(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).adjusted_doc_number :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_number(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).application_id :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.application_id(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).applied_from_application_id :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_application_id(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).applied_from_entity_code   :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_entity_code(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).applied_from_event_class_code :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_event_class_code(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).applied_from_line_id :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_line_id(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).applied_from_trx_level_type :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_trx_level_type(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).applied_from_trx_id :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_trx_id(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).applied_from_trx_number :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_trx_number;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).applied_to_application_id :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_to_application_id(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).applied_to_event_class_code :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_to_event_class_code(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).applied_to_entity_code :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_to_entity_code(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).applied_to_line_id :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_to_trx_line_id(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).applied_to_trx_level_type :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_to_trx_level_type(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).applied_to_trx_id   :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_to_trx_id(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).applied_to_trx_number :=
             ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_to_trx_number(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).line_assessable_value :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.assessable_value(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).Asset_Flag  :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.Asset_Flag(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).asset_number :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.asset_number(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).asset_accum_depreciation    :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.asset_accum_depreciation(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).asset_cost :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.asset_cost(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).asset_type :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.asset_type(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).banking_tp_taxpayer_id :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.banking_tp_taxpayer_id(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).batch_source_id :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.batch_source_id(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).batch_source_name :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.batch_source_name(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).bill_from_location_id :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.bill_from_location_id(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).bill_from_party_tax_prof_id :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.bill_from_party_tax_prof_id(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).bill_from_site_tax_prof_id :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.bill_from_site_tax_prof_id(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).bill_to_location_id  :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.bill_to_location_id(j);
--   ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).bill_to_party_tax_prof_id   :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.bill_to_party_tax_prof_id(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).bill_to_site_tax_prof_id    :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.bill_to_site_tax_prof_id(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).billing_tp_taxpayer_id  :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.billing_tp_taxpayer_id(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).Billing_Tp_Tax_Reporting_Flag :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.Billing_Tp_Tax_Reporting_Flag(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).billing_trading_partner_number :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.billing_trading_partner_number(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).billing_trading_partner_name :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.billing_trading_partner_name(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).cash_discount :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.cash_discount(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).char1   :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.char1(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).char2   :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.char2(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).char3   :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.char3(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).char4   :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.char4(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).char5   :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.char5(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).char6   :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.char6(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).char7   :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.char7(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).char8   :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.char8(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).char9   :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.char9(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).char10  :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.char10(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).account_ccid :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.account_ccid(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).currency_conversion_date :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.currency_conversion_date(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).currency_conversion_rate :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.currency_conversion_rate(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).currency_conversion_type :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.currency_conversion_type(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).date1      :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.date1(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).date2      :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.date2(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).date3       :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.date3(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).date4      :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.date4(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).date5        :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.date5(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).date6      :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.date6(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).date7      :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.date7(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).date8      :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.date8(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).date9      :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.date9(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).date10     :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.date10(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).default_taxation_country :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.default_taxation_country(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).doc_event_status :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.doc_event_status(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).doc_seq_id :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.doc_seq_id(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).doc_seq_name  :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.doc_seq_name(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).doc_seq_value :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.doc_seq_value(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).document_sub_type :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.document_sub_type(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).entity_code  :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.entity_code(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).establishment_id  :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.establishment_id(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).event_class_code  :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.event_class_code(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).event_type_code :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.event_type_code(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).exempt_certificate_number :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.exempt_certificate_number(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).fob_point   :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.fob_point(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_line_gl_date :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_gl_date(j);
    IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).Historical_Flag is NULL THEN
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).Historical_Flag :=
             ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.Historical_Flag(j);
    END IF;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).hq_estb_party_tax_prof_id :=
             ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.hq_estb_party_tax_prof_id(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).insurance_charge   :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.insurance_charge(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).line_intended_use  :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_intended_use(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).internal_organization_id :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.internal_organization_id(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).legal_entity_id :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.legal_entity_id(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).line_amt :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_amt(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).line_level_action :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).minimum_accountable_unit  :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.minimum_accountable_unit(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).numeric1    :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.numeric1(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).numeric2    :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.numeric2(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).numeric3    :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.numeric3(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).numeric4    :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.numeric4(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).numeric5    :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.numeric5(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).numeric6    :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.numeric6(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).numeric7    :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.numeric7(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).numeric8    :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.numeric8(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).numeric9    :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.numeric9(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).numeric10   :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.numeric10(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).other_charge :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.other_charge(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).own_hq_location_id :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.own_hq_location_id(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).own_hq_party_tax_prof_id  :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.own_hq_party_tax_prof_id(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).own_hq_site_tax_prof_id :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.own_hq_site_tax_prof_id(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).Line_Amt_Includes_Tax_Flag :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.Line_Amt_Includes_Tax_Flag(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).paying_location_id :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.paying_location_id(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).paying_party_tax_prof_id  :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.paying_party_tax_prof_id(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).paying_site_tax_prof_id :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.paying_site_tax_prof_id(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).poa_location_id :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.poa_location_id(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).poa_party_tax_prof_id :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.poa_party_tax_prof_id(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).poa_site_tax_prof_id  :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.poa_site_tax_prof_id(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).pod_party_tax_prof_id :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.pod_party_tax_prof_id(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).pod_site_tax_prof_id  :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.pod_site_tax_prof_id(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).poi_party_tax_prof_id :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.poi_party_tax_prof_id(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).poi_site_tax_prof_id  :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.poi_site_tax_prof_id(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).poc_location_id :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.poc_location_id(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).pod_location_id   :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.pod_location_id(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).poi_location_id :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.poi_location_id(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).poo_location_id  :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.poo_location_id(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).poo_party_tax_prof_id :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.poo_party_tax_prof_id(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).poo_site_tax_prof_id :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.poo_site_tax_prof_id(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).precision  :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.precision(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).product_code :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.product_code(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).product_description  :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.product_description(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).product_id :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.product_id(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).product_category :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.product_category(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).product_fisc_classification :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.product_fisc_classification(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).product_org_id :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.product_org_id(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).product_type :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.product_type(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).related_doc_application_id :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.related_doc_application_id(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).related_doc_entity_code :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.related_doc_entity_code(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).related_doc_event_class_code :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.related_doc_event_class_code(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).related_doc_trx_id :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.related_doc_trx_id(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).related_doc_number :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.related_doc_number(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).related_doc_date   :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.related_doc_date(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).ref_doc_line_quantity :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ref_doc_line_quantity(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).ref_doc_application_id :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ref_doc_application_id(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).ref_doc_entity_code :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ref_doc_entity_code(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).ref_doc_event_class_code :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ref_doc_event_class_code(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).ref_doc_line_id :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ref_doc_line_id(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).ref_doc_trx_level_type :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ref_doc_trx_level_type(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).ref_doc_trx_id  :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ref_doc_trx_id(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).ledger_id :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ledger_id(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).ship_from_location_id :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ship_from_location_id(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).ship_from_party_tax_prof_id :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ship_from_party_tax_prof_id(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).ship_from_site_tax_prof_id :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ship_from_site_tax_prof_id(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).ship_to_location_id :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ship_to_location_id(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).ship_to_party_tax_prof_id   :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ship_to_party_tax_prof_id(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).ship_to_site_tax_prof_id  :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ship_to_site_tax_prof_id(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).content_owner_id :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.first_pty_org_id(j); -- subscriber_id(j): bug fix 3462583
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).supplier_tax_invoice_number :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.supplier_tax_invoice_number(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).supplier_tax_invoice_date :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.supplier_tax_invoice_date(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).supplier_exchange_rate :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.supplier_exchange_rate(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_event_class_code  :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.tax_event_class_code(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_event_type_code  :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.tax_event_type_code(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_invoice_date :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.tax_invoice_date(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_invoice_number :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.tax_invoice_number(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).merchant_party_country :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.merchant_party_country(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).merchant_party_document_number :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.merchant_party_document_number(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).merchant_party_name  :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.merchant_party_name(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).merchant_party_reference :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.merchant_party_reference(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).merchant_party_tax_prof_id :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.merchant_party_tax_prof_id(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).merchant_party_tax_reg_number  :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.merchant_party_tax_reg_number(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).merchant_party_taxpayer_id :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.merchant_party_taxpayer_id(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).title_trans_party_tax_prof_id :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.title_trans_party_tax_prof_id(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).title_trans_site_tax_prof_id :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.title_trans_site_tax_prof_id(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).title_transfer_location_id  :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.title_transfer_location_id(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trading_discount :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trading_discount(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trading_hq_location_id :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trading_hq_location_id(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trading_hq_party_tax_prof_id :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trading_hq_party_tax_prof_id(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trading_hq_site_tax_prof_id :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trading_hq_site_tax_prof_id(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_number :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_number(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_currency_code :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_currency_code(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_date    :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_date(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_id      :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_id(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_id_level2 :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_id_level2(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_id_level3 :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_id_level3(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_id_level4 :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_id_level4(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_id_level5 :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_id_level5(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_id_level6 :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_id_level6(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_level_type :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_level_type(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_line_description :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_description(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_line_id :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_id(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_line_number :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_number(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_line_type :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_type(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).transfer_charge :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.transfer_charge(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).transportation_charge :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.transportation_charge(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_business_category :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_business_category(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_communicated_date :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_communicated_date(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_description :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_description(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_doc_revision :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_doc_revision(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_due_date  :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_due_date(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_line_date :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_date(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_line_quantity :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_quantity(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_receipt_date :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_receipt_date(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_shipping_date :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_shipping_date(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_sic_code  :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_sic_code(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_type_description  :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_type_description(j);
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).receivables_trx_type_id :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.receivables_trx_type_id(j);
/***********************
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_user_key_level1   :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_trx_user_key1(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_user_key_level2   :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_trx_user_key2(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_user_key_level3   :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_trx_user_key3(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_user_key_level4   :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_trx_user_key4(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_user_key_level5   :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_trx_user_key5(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_user_key_level6   :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_trx_user_key6(j);
*******************/
--    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_waybill_number    :=
--            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_waybill_number(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).unit_price :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.unit_price(j);
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).internal_org_location_id :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.internal_org_location_id(j);

    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).ctrl_total_line_tx_amt :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ctrl_total_line_tx_amt(j);

    -- bug fix 4630692
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_currency_code :=
            NVL(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_currency_code(j),
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_currency_code(j));

    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).currency_conversion_date :=
            NVL(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.currency_conversion_date(j),
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_currency_conv_date(j));

    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).currency_conversion_rate :=
            NVL(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.currency_conversion_rate(j),
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_currency_conv_rate(j));

    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).currency_conversion_type :=
            NVL(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.currency_conversion_type(j),
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_currency_conv_type(j));


  END LOOP;

  IF (g_level_statement >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.cp_tsrm_val_to_zx_lines.END',
                   'ZX_TDS_TAX_LINES_POPU_PKG: cp_tsrm_val_to_zx_lines(-)'||p_return_status);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.cp_tsrm_val_to_zx_lines',
                      p_error_buffer);
    END IF;

END cp_tsrm_val_to_zx_lines;

-----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  populate_tax_line
--
--  DESCRIPTION
--  This procedure is called before tax lines summarization  process
--  It is one of the entry point to populate Tax lines process
--
--  NOTE : currently not use

PROCEDURE populate_tax_line(
            p_event_class_rec     IN     ZX_API_PUB.EVENT_CLASS_REC_TYPE,
            p_tax_line_rec        IN OUT NOCOPY ZX_DETAIL_TAX_LINES_GT%ROWTYPE,
            p_return_status          OUT NOCOPY VARCHAR2,
            p_error_buffer           OUT NOCOPY VARCHAR2)
IS
BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.populate_tax_lines.BEGIN',
                   'ZX_TDS_TAX_LINES_POPU_PKG: populate_tax_lines(+)');
  END IF;

  p_return_status  := FND_API.G_RET_STS_SUCCESS;
  p_error_buffer   := NULL;


  /*
   * populate orig columns in override case only
   * and this should be done by UI
   *
   *IF ((p_event_class_rec.tax_event_type_code = 'CREATE'  AND
   *    p_tax_line_rec.Manually_Entered_Flag = 'N')          OR
   *   (p_event_class_rec.tax_event_type_code = 'UPDATE'  AND
   *   p_tax_line_rec.line_level_action = 'CREATE')            OR
   *  (p_event_class_rec.tax_event_type_code = 'OVERRIDE_TAX' AND
   *   p_tax_line_rec.Manually_Entered_Flag = 'Y') )  THEN
   * populate_orig_columns(p_tax_line_rec);
   * END IF;
   */

  p_tax_line_rec.line_assessable_value := p_tax_line_rec.taxable_amt;

  populate_mandatory_columns(p_tax_line_rec,
                             p_return_status,
                             p_error_buffer);

  IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RETURN;
  END IF;

  check_mandatory_columns(p_tax_line_rec,
                          p_return_status,
                          p_error_buffer);

  IF (g_level_statement >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.populate_tax_lines.END',
                   'ZX_TDS_TAX_LINES_POPU_PKG: populate_tax_lines(-)'||p_return_status);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.populate_tax_line',
                      p_error_buffer);
    END IF;

END populate_tax_line;

-----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  populate_orig_columns
--
--  DESCRIPTION
--  This procedure populates original columns for a tax line record
--
--  NOTE : currently not use

PROCEDURE populate_orig_columns(
            p_tax_line_rec IN OUT NOCOPY ZX_DETAIL_TAX_LINES_GT%ROWTYPE)

IS
BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.populate_orig_columns.BEGIN',
                   'ZX_TDS_TAX_LINES_POPU_PKG: populate_orig_columns(+)');
  END IF;

  IF p_tax_line_rec.orig_tax_status_id IS NULL THEN
    p_tax_line_rec.orig_tax_status_id := p_tax_line_rec.tax_status_id;
  END IF;
  IF p_tax_line_rec.orig_tax_status_code IS NULL THEN
    p_tax_line_rec.orig_tax_status_code := p_tax_line_rec.tax_status_code;
  END IF;
  IF p_tax_line_rec.orig_tax_rate_id IS NULL THEN
    p_tax_line_rec.orig_tax_rate_id := p_tax_line_rec.tax_rate_id;
  END IF;
  IF p_tax_line_rec.orig_tax_rate_code IS NULL THEN
    p_tax_line_rec.orig_tax_rate_code  := p_tax_line_rec.tax_rate_code;
  END IF;
  IF p_tax_line_rec.orig_tax_rate IS NULL THEN
    p_tax_line_rec.orig_tax_rate := p_tax_line_rec.tax_rate;
  END IF;
  IF p_tax_line_rec.orig_taxable_amt IS NULL THEN
    p_tax_line_rec.orig_taxable_amt := p_tax_line_rec.taxable_amt;
  END IF;
  IF p_tax_line_rec.orig_taxable_amt_tax_curr IS NULL THEN
    p_tax_line_rec.orig_taxable_amt_tax_curr :=
                               p_tax_line_rec.taxable_amt_tax_curr;
  END IF;
  IF p_tax_line_rec.orig_tax_amt IS NULL THEN
    p_tax_line_rec.orig_tax_amt := p_tax_line_rec.tax_amt;
  END IF;
  IF p_tax_line_rec.orig_tax_amt_tax_curr IS NULL THEN
    p_tax_line_rec.orig_tax_amt_tax_curr :=
                               p_tax_line_rec.tax_amt_tax_curr;
  END IF;


  IF (g_level_statement >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.populate_orig_columns.END',
                   'ZX_TDS_TAX_LINES_POPU_PKG: populate_orig_columns(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.populate_orig_columns',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
    END IF;

END populate_orig_columns;

-----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  populate_mandatory_columns
--
--  DESCRIPTION
--  This procedure populates mandatory columns such as tax line id, who
--  columns, etc for a tax line record
--
--  CALLED BY
--    ZX_TDS_OFFSET_TAX_DETM_PKG

PROCEDURE populate_mandatory_columns(
            p_tax_line_rec IN OUT NOCOPY ZX_DETAIL_TAX_LINES_GT%ROWTYPE,
            p_return_status          OUT NOCOPY VARCHAR2,
            p_error_buffer           OUT NOCOPY VARCHAR2)

IS

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.populate_mandatory_columns.BEGIN',
                   'ZX_TDS_TAX_LINES_POPU_PKG: populate_mandatory_columns(+)');
  END IF;

  p_return_status  := FND_API.G_RET_STS_SUCCESS;

  --
  -- populate tax_line_id if it is null
  --
  IF p_tax_line_rec.tax_line_id IS NULL THEN
    SELECT ZX_LINES_S.nextval
      INTO p_tax_line_rec.tax_line_id
      FROM dual;
  END IF;


/******************************************
 * move to set_detail_tax_line_def_val
 * in ZX_TDS_CALC_SERVICES_PUB_PKG now
 *
 *
 *
 * -- populate Record_Type_Code
 * IF p_tax_line_rec.Record_Type_Code IS NULL THEN
 *   p_tax_line_rec.Record_Type_Code     := 'ETAX_CREATED';
 * END IF;
 *
 * -- populate Historical_Flag
 * IF p_tax_line_rec.Historical_Flag IS NULL THEN
 *   p_tax_line_rec.Historical_Flag := 'N';
 * END IF;
**********************************************/

  -- populate who columns


  IF p_tax_line_rec.created_by IS NULL THEN
    p_tax_line_rec.created_by      := fnd_global.user_id;
  END IF;

  IF p_tax_line_rec.creation_date IS NULL THEN
    p_tax_line_rec.creation_date   := sysdate;
  END IF;

  p_tax_line_rec.last_updated_by   := fnd_global.user_id;
  p_tax_line_rec.last_update_login := fnd_global.login_id;
  p_tax_line_rec.last_update_date  := sysdate;

  IF (g_level_statement >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.populate_mandatory_columns.END',
                   'ZX_TDS_TAX_LINES_POPU_PKG: populate_mandatory_columns(-)'||p_return_status);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.populate_mandatory_columns',
                      p_error_buffer);
    END IF;

END populate_mandatory_columns;
-----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  check_mandatory_columns
--
--  DESCRIPTION
--  This procedure ensures all mandatory columns are not NULL for a
--  tax line record
--
--  CALLED BY
--    populate_tax_lines

PROCEDURE check_mandatory_columns(
            p_tax_line_rec        IN OUT NOCOPY ZX_DETAIL_TAX_LINES_GT%ROWTYPE,
            p_return_status          OUT NOCOPY VARCHAR2,
            p_error_buffer           OUT NOCOPY VARCHAR2)

IS
BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.check_mandatory_columns.BEGIN',
                   'ZX_TDS_TAX_LINES_POPU_PKG: check_mandatory_columns(+)');
  END IF;

  p_return_status  := FND_API.G_RET_STS_SUCCESS;

  --
  -- check mandatory columns for all tax lines
  --
  check_mandatory_columns_all(p_tax_line_rec,
                              p_return_status,
                              p_error_buffer);
  IF (p_return_status = FND_API.G_RET_STS_SUCCESS AND
      NVL(p_tax_line_rec.Manually_Entered_Flag,'N') = 'N') THEN
    check_non_manual_tax_line(p_tax_line_rec,
                              p_return_status,
                              p_error_buffer);
  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.check_mandatory_columns',
                   'p_return_status = ' || p_return_status);
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.check_mandatory_columns',
                   'p_error_buffer  = ' || p_error_buffer);
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.check_mandatory_columns.END',
                   'ZX_TDS_TAX_LINES_POPU_PKG: check_mandatory_columns(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.check_mandatory_columns',
                      p_error_buffer);
    END IF;

END check_mandatory_columns;
-----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  check_mandatory_columns_all
--
--  DESCRIPTION
--  This procedure ensures all mandatory columns belonged to a manual and
--  non manual tax line are not NULL for a tax line record
--
--  CALLED BY
--    check_mandatory_columns

PROCEDURE check_mandatory_columns_all(
            p_tax_line_rec        IN OUT NOCOPY ZX_DETAIL_TAX_LINES_GT%ROWTYPE,
            p_return_status          OUT NOCOPY VARCHAR2,
            p_error_buffer           OUT NOCOPY VARCHAR2)

IS
BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.check_mandatory_columns_all.BEGIN',
                   'ZX_TDS_TAX_LINES_POPU_PKG: check_mandatory_columns_all(+)');
  END IF;

  p_return_status  := FND_API.G_RET_STS_SUCCESS;

  IF p_tax_line_rec.application_id IS NULL THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := 'application_id can not be NULL';
  ELSIF p_tax_line_rec.entity_code IS NULL THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := 'entity_code can not be NULL';
  ELSIF p_tax_line_rec.event_class_code IS NULL THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := 'event_class_code can not be NULL';
  ELSIF p_tax_line_rec.event_type_code IS NULL THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := 'event_type_code can not be NULL';
  ELSIF p_tax_line_rec.trx_id IS NULL THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := 'trx_id can not be NULL';
  ELSIF p_tax_line_rec.trx_line_id IS NULL THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := 'trx_line_id can not be NULL';
  ELSIF p_tax_line_rec.trx_level_type IS NULL THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := 'trx_level_type can not be NULL';

--  Bug#4572001- content_owner_id can be NULL
--  ELSIF p_tax_line_rec.content_owner_id IS NULL THEN
--    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
--    p_error_buffer  := 'content_owner_id can not be NULL';

  ELSIF p_tax_line_rec.tax_regime_id IS NULL THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := 'tax_regime_id can not be NULL';
  ELSIF p_tax_line_rec.tax_regime_code IS NULL THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := 'tax_regime_code can not be NULL';
  ELSIF p_tax_line_rec.tax_id IS NULL THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := 'tax_id can not be NULL';
  ELSIF p_tax_line_rec.tax IS NULL THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := 'tax can not be NULL';
  ELSIF p_tax_line_rec.tax_status_id IS NULL THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := 'tax_status_id can not be NULL';
  ELSIF p_tax_line_rec.tax_status_code IS NULL THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := 'tax_status_code can not be NULL';
  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.check_mandatory_columns_all',
                   'p_return_status = ' || p_return_status);
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.check_mandatory_columns_all',
                   'p_error_buffer  = ' || p_error_buffer);
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.check_mandatory_columns_all.END',
                   'ZX_TDS_TAX_LINES_POPU_PKG: check_mandatory_columns_all(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.check_mandatory_columns_all',
                      p_error_buffer);
    END IF;

END check_mandatory_columns_all;

-----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  check_non_manual_tax_line
--
--  DESCRIPTION
--  This procedure ensures all mandatory columns belonged to a
--  non manually entered tax line are not NULL for a tax line record
--
--  CALLED BY
--    check_mandatory_columns


PROCEDURE check_non_manual_tax_line(
            p_tax_line_rec        IN OUT NOCOPY ZX_DETAIL_TAX_LINES_GT%ROWTYPE,
            p_return_status          OUT NOCOPY VARCHAR2,
            p_error_buffer           OUT NOCOPY VARCHAR2)

IS
BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.check_non_manual_tax_line.BEGIN',
                   'ZX_TDS_TAX_LINES_POPU_PKG: check_non_manual_tax_line(+)');
  END IF;

  p_return_status  := FND_API.G_RET_STS_SUCCESS;

  IF p_tax_line_rec.trx_date IS NULL THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := 'trx_date can not be NULL';
  --ELSIF p_tax_line_rec.trx_line_date IS NULL THEN
  --  p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  --  p_error_buffer  := 'trx_line_date can not be NULL';
  ELSIF p_tax_line_rec.ledger_id IS NULL THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := 'ledger_id can not be NULL';

/* comment out only for AP uptake testing purpose. Change to reversed later. chku
  ELSIF p_tax_line_rec.establishment_id IS NULL THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := 'establishment_id can not be NULL';
*/
  ELSIF p_tax_line_rec.legal_entity_id IS NULL THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := 'legal_entity_id can not be NULL';
  ELSIF p_tax_line_rec.tax_rate_id IS NULL THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := 'tax_rate_id can not be NULL';
  ELSIF p_tax_line_rec.tax_rate_code IS NULL THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := 'tax_rate_code  can not be NULL';
  ELSIF p_tax_line_rec.tax_rate IS NULL THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := 'tax_rate can not be NULL';

/* comment out only for AP uptake testing purpose. Change to reversed later. chku
  ELSIF p_tax_line_rec.tax_apportionment_line_number IS NULL THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := 'tax_apportionment_line_number can not be NULL';
*/
  ELSIF p_tax_line_rec.tax_date IS NULL THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := 'tax_date can not be NULL';
  ELSIF p_tax_line_rec.tax_determine_date IS NULL THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := 'tax_determine_date can not be NULL';
  ELSIF p_tax_line_rec.tax_point_date IS NULL THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := 'tax_point_date can not be NULL';

  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.check_non_manual_tax_line',
                   'p_return_status = ' || p_return_status);
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.check_non_manual_tax_line',
                   'p_error_buffer = '  || p_error_buffer);
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.check_non_manual_tax_line.END',
                   'ZX_TDS_TAX_LINES_POPU_PKG: check_non_manual_tax_line(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.check_non_manual_tax_line',
                      p_error_buffer);
    END IF;

END check_non_manual_tax_line;

-----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  pop_tax_line_for_trx_line
--
--  DESCRIPTION
--  This procedure is called after tax calculation is done for
--  all tax lines belonged to a transaction line. It populates
--  missing columns and ensures all mandatory columns are not
--  NULL for each tax line belonged to a transaction line.
--  It is one of the entry point to populate Tax lines process
--
--  CALLED BY
--    ZX_TDS_CALC_SERVICES_PUB_PKG


PROCEDURE pop_tax_line_for_trx_line(
            p_begin_index         IN     BINARY_INTEGER,
            p_end_index           IN     BINARY_INTEGER,
            p_return_status          OUT NOCOPY VARCHAR2,
            p_error_buffer           OUT NOCOPY VARCHAR2)
IS

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.pop_tax_line_for_trx_line.BEGIN',
                   'ZX_TDS_TAX_LINES_POPU_PKG: pop_tax_line_for_trx_line(+)');
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.pop_tax_line_for_trx_line',
                   'p_begin_index = ' || to_char(p_begin_index));
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.pop_tax_line_for_trx_line',
                   'p_end_index = ' || to_char(p_end_index));
  END IF;

  p_return_status  := FND_API.G_RET_STS_SUCCESS;
  p_error_buffer   := NULL;

  --
  -- check if begin_index and end_index have values
  --
  IF (p_begin_index IS NULL OR p_end_index IS NULL) THEN

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.pop_tax_line_for_trx_line',
                     'Begin index or End index is null' );
    END IF;

    RETURN;
  END IF;

  pop_mandatory_col_for_trx_line(
                             p_begin_index,
                             p_end_index,
                             p_return_status,
                             p_error_buffer);

  IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RETURN;
  END IF;

  chk_mandatory_col_for_trx_line(
                          p_begin_index,
                          p_end_index,
                          p_return_status,
                          p_error_buffer);

  IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RETURN;
  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.pop_tax_line_for_trx_lines',
                   'p_return_status = ' || p_return_status);
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.pop_tax_line_for_trx_lines',
                   'p_error_buffer  = ' || p_error_buffer);
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.pop_tax_line_for_trx_lines.END',
                   'ZX_TDS_TAX_LINES_POPU_PKG: pop_tax_line_for_trx_lines(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.pop_tax_line_for_trx_line',
                      p_error_buffer);
    END IF;

END pop_tax_line_for_trx_line;

-----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  pop_mandatory_col_for_trx_line
--
--  DESCRIPTION
--  This procedure populates mandatory columns such as tax line id, who
--  columns, etc for all tax lines belonged to a transaction line
--
--  CALLED BY
--    pop_tax_line_for_trx_lines

PROCEDURE pop_mandatory_col_for_trx_line(
            p_begin_index         IN     BINARY_INTEGER,
            p_end_index           IN     BINARY_INTEGER,
            p_return_status          OUT NOCOPY VARCHAR2,
            p_error_buffer           OUT NOCOPY VARCHAR2)
IS

  --bug8517610
  l_process_offset_flag   VARCHAR2(1);

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.pop_mandatory_col_for_trx_line.BEGIN',
                   'ZX_TDS_TAX_LINES_POPU_PKG: pop_mandatory_col_for_trx_line(+)');
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.pop_mandatory_col_for_trx_line',
                   'p_begin_index = ' || to_char(p_begin_index));
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.pop_mandatory_col_for_trx_line',
                   'p_end_index = ' || to_char(p_end_index));
  END IF;

  p_return_status  := FND_API.G_RET_STS_SUCCESS;

   --bug8517610
  l_process_offset_flag := 'N';

  --
  -- check if begin_index and end_index have values
  --
  IF (p_begin_index IS NULL OR p_end_index IS NULL) THEN

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.pop_mandatory_col_for_trx_line',
                     'Begin index or End index is null' );
    END IF;

    RETURN;
  END IF;

  FOR i IN p_begin_index ..p_end_index LOOP

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.pop_mandatory_col_for_trx_line',
                     'processing detail line index = ' || to_char(i));
    END IF;

    --
    -- populate tax_line_id if it is null
    --
    IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_line_id IS NULL THEN
      SELECT ZX_LINES_S.nextval
        INTO ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_line_id
        FROM dual;
    END IF;

/*************************************
*   -- populate assessable_value
*   ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).assessable_value :=
*      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).taxable_amt;
*
*    -- populate Record_Type_Code
*    IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).Record_Type_Code IS NULL THEN
*      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).Record_Type_Code :=
*                                                                'ETAX_CREATED';
*    END IF;
*
*    -- populate Historical_Flag
*    IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).Historical_Flag IS NULL THEN
*      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).Historical_Flag := 'N';
*    END IF;
*
***************************************/

    -- populate who columns

    IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).created_by IS NULL THEN
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).created_by :=
                                                             fnd_global.user_id;
    END IF;

    IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).creation_date IS NULL THEN
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).creation_date :=
                                                                       sysdate;
    END IF;

    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).last_updated_by :=
                                                            fnd_global.user_id;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).last_update_login :=
                                                            fnd_global.login_id;
    ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).last_update_date :=
                                                            sysdate;

    --bug8517610

    IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).offset_tax_rate_code IS NOT NULL
    AND ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).other_doc_source IS NOT NULL THEN
      l_process_offset_flag := 'Y';
    END IF;

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.pop_mandatory_col_for_trx_line',
                     'tax_line_id = ' ||
                      to_char(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_line_id));

    END IF;
  END LOOP;


  --bug8517610
  IF l_process_offset_flag = 'Y' THEN
    FOR i IN p_begin_index ..p_end_index LOOP
      IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).offset_tax_rate_code IS NOT NULL
      AND ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).other_doc_source IS NOT NULL THEN

        FOR j IN p_begin_index ..p_end_index LOOP
          IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(j).tax_rate_code =
	         ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).offset_tax_rate_code AND
	     NVL(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(j).tax_apportionment_line_number,1) =
	         NVL(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_apportionment_line_number,1) THEN
             ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(j).offset_link_to_tax_line_id :=
	         ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_line_id;
          END IF;
        END LOOP;
      END IF;
    END LOOP;
  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.pop_mandatory_col_for_trx_line',
                   'p_return_status = ' || p_return_status);
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.pop_mandatory_col_for_trx_line',
                   'p_error_buffer  = ' || p_error_buffer);
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.pop_mandatory_col_for_trx_line.END',
                   'ZX_TDS_TAX_LINES_POPU_PKG: pop_mandatory_col_for_trx_line(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.pop_mandatory_col_for_trx_line',
                      p_error_buffer);
    END IF;

END pop_mandatory_col_for_trx_line;
-----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  chk_mandatory_col_for_trx_line
--
--  DESCRIPTION
--  This procedure ensures all mandatory columns are not NULL
--  for each tax lines belonged to a transaction line
--
--  CALLED BY
--    pop_tax_line_for_trx_lines


PROCEDURE chk_mandatory_col_for_trx_line(
            p_begin_index         IN     BINARY_INTEGER,
            p_end_index           IN     BINARY_INTEGER,
            p_return_status          OUT NOCOPY VARCHAR2,
            p_error_buffer           OUT NOCOPY VARCHAR2)

IS
BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.chk_mandatory_col_for_trx_line.BEGIN',
                   'ZX_TDS_TAX_LINES_POPU_PKG: chk_mandatory_col_for_trx_line(+)');
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.chk_mandatory_col_for_trx_line',
                   'p_begin_index = ' || to_char(p_begin_index));
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.chk_mandatory_col_for_trx_line',
                   'p_end_index = ' || to_char(p_end_index));
  END IF;

  p_return_status  := FND_API.G_RET_STS_SUCCESS;

  --
  -- check if begin_index and end_index have values
  --
  IF (p_begin_index IS NULL OR p_end_index IS NULL) THEN

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.chk_mandatory_col_for_trx_line',
                     'Begin index or End index is null' );
    END IF;

    RETURN;
  END IF;

  --
  -- check mandatory columns for all tax lines
  --
  chk_mand_col_all_for_trx_line(
                              p_begin_index,
                              p_end_index,
                              p_return_status,
                              p_error_buffer);

  IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RETURN;
  END IF;

  --
  -- check mandatory columns applied to non
  -- manually entered tax lines only
  --
  chk_non_manual_line_f_trx_line(
                              p_begin_index,
                              p_end_index,
                              p_return_status,
                              p_error_buffer);
  IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RETURN;
  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.chk_mandatory_col_for_trx_line',
                   'p_return_status = ' || p_return_status);
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.chk_mandatory_col_for_trx_line',
                   'p_error_buffer  = ' || p_error_buffer);
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.chk_mandatory_col_for_trx_line.END',
                   'ZX_TDS_TAX_LINES_POPU_PKG: chk_mandatory_col_for_trx_line(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.chk_mandatory_col_for_trx_line',
                      p_error_buffer);
    END IF;

END chk_mandatory_col_for_trx_line;
-----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  chk_mand_col_all_for_trx_line
--
--  DESCRIPTION
--  This procedure ensures all mandatory columns of a manual or  non
--  manual tax line are not NULL  for each tax line belonged to
--  a transaction line
--
--  CALLED BY
--    chk_mandatory_col_for_trx_line

PROCEDURE chk_mand_col_all_for_trx_line(
            p_begin_index         IN     BINARY_INTEGER,
            p_end_index           IN     BINARY_INTEGER,
            p_return_status          OUT NOCOPY VARCHAR2,
            p_error_buffer           OUT NOCOPY VARCHAR2)
IS
BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.chk_mand_col_all_for_trx_line.BEGIN',
                   'ZX_TDS_TAX_LINES_POPU_PKG: chk_mand_col_all_for_trx_line(+)');
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.chk_mand_col_all_for_trx_line',
                   'p_begin_index = ' || to_char(p_begin_index));
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.chk_mand_col_all_for_trx_line',
                   'p_end_index = ' || to_char(p_end_index));
  END IF;

  p_return_status  := FND_API.G_RET_STS_SUCCESS;

  --
  -- check if begin_index and end_index have values
  --
  IF (p_begin_index IS NULL OR p_end_index IS NULL) THEN

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.chk_mand_col_all_for_trx_line',
                     'Begin index or End index is null' );
    END IF;

    RETURN;
  END IF;

  FOR i IN p_begin_index ..p_end_index LOOP

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.chk_mand_col_all_for_trx_line',
                     'processing detail line index = ' || to_char(i));
    END IF;

    IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).application_id IS NULL THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      p_error_buffer  := 'application_id can not be NULL';
    ELSIF  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).entity_code IS NULL THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      p_error_buffer  := 'entity_code can not be NULL';
    ELSIF  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).event_class_code IS NULL THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      p_error_buffer  := 'event_class_code can not be NULL';
    ELSIF  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).event_type_code IS NULL THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      p_error_buffer  := 'event_type_code can not be NULL';
    ELSIF  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_id IS NULL THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      p_error_buffer  := 'trx_id can not be NULL';
    ELSIF  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_line_id IS NULL THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      p_error_buffer  := 'trx_line_id can not be NULL';
    ELSIF  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_level_type IS NULL THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      p_error_buffer  := 'trx_level_type can not be NULL';
/*
    --  Bug#4572001- content_owner_id can be NULL
    ELSIF  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).content_owner_id IS NULL THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      p_error_buffer  := 'content_owner_id can not be NULL';
*/
    ELSIF  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_regime_id IS NULL THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      p_error_buffer  := 'tax_regime_id can not be NULL';
    ELSIF  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_regime_code IS NULL THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      p_error_buffer  := 'tax_regime_code can not be NULL';
    ELSIF  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_id IS NULL THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      p_error_buffer  := 'tax_id can not be NULL';
    ELSIF  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax IS NULL THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      p_error_buffer  := 'tax can not be NULL';
    ELSIF  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_status_id IS NULL THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      p_error_buffer  := 'tax_status_id can not be NULL';
    ELSIF  ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_status_code IS NULL THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      p_error_buffer  := 'tax_status_code can not be NULL';
    END IF;

    IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      EXIT;
    END IF;

  END LOOP;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.chk_mand_col_all_for_trx_line',
                   'p_return_status = ' || p_return_status);
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.chk_mand_col_all_for_trx_line',
                   'p_error_buffer  = ' || p_error_buffer);
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.chk_mand_col_all_for_trx_line.END',
                   'ZX_TDS_TAX_LINES_POPU_PKG: chk_mand_col_all_for_trx_line(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.chk_mand_col_all_for_trx_line',
                      p_error_buffer);
    END IF;

END chk_mand_col_all_for_trx_line;

-----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  chk_non_manual_line_f_trx_line
--
--  DESCRIPTION
--  This procedure ensures all mandatory columns of a non manually
--  entered tax line are not NULL  for each tax lines belonged to
--  a transaction line
--
--  CALLED BY
--    chk_mandatory_col_for_trx_line


PROCEDURE chk_non_manual_line_f_trx_line(
            p_begin_index         IN     BINARY_INTEGER,
            p_end_index           IN     BINARY_INTEGER,
            p_return_status          OUT NOCOPY VARCHAR2,
            p_error_buffer           OUT NOCOPY VARCHAR2)
IS
BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.chk_non_manual_line_f_trx_line.BEGIN',
                   'ZX_TDS_TAX_LINES_POPU_PKG: chk_non_manual_line_f_trx_line(+)');
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.chk_non_manual_line_f_trx_line',
                   'p_begin_index = ' || to_char(p_begin_index));
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.chk_non_manual_line_f_trx_line',
                   'p_end_index = ' || to_char(p_end_index));
  END IF;

  p_return_status  := FND_API.G_RET_STS_SUCCESS;

  --
  -- check if begin_index and end_index have values
  --
  IF (p_begin_index IS NULL OR p_end_index IS NULL) THEN

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.chk_non_manual_line_f_trx_line',
                     'Begin index or End index is null' );
    END IF;

    RETURN;
  END IF;

  FOR i IN p_begin_index ..p_end_index LOOP

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.chk_non_manual_line_f_trx_line',
                     'processing detail line index = ' || to_char(i));
    END IF;

    IF (NVL(ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).Manually_Entered_Flag,'N') = 'N') THEN

      IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_date IS NULL THEN
        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        p_error_buffer  := 'trx_date can not be NULL';
     -- ELSIF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).trx_line_date IS NULL THEN
      --  p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      --  p_error_buffer  := 'trx_line_date can not be NULL';
      ELSIF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).ledger_id IS NULL THEN
        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        p_error_buffer  := 'ledger_id can not be NULL';

/* comment out only for AP uptake testing purpose. Change to reversed later. chku
  ELSIF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).establishment_id IS NULL THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := 'establishment_id can not be NULL';
*/
      ELSIF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).legal_entity_id IS NULL THEN
        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        p_error_buffer  := 'legal_entity_id can not be NULL';
      ELSIF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_rate_id IS NULL THEN
        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        p_error_buffer  := 'tax_rate_id can not be NULL';
      ELSIF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_rate_code IS NULL THEN
        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        p_error_buffer  := 'tax_rate_code  can not be NULL';
      ELSIF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_rate IS NULL THEN
        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        p_error_buffer  := 'tax_rate can not be NULL';

/* comment out only for AP uptake testing purpose. Change to reversed later. chku
  ELSIF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_apportionment_line_number IS NULL THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := 'tax_apportionment_line_number can not be NULL';
*/
      ELSIF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_date IS NULL THEN
        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        p_error_buffer  := 'tax_date can not be NULL';
      ELSIF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_determine_date IS NULL THEN
        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        p_error_buffer  := 'tax_determine_date can not be NULL';
      ELSIF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).tax_point_date IS NULL THEN
        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        p_error_buffer  := 'tax_point_date can not be NULL';
      END IF;

      IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        EXIT;
      END IF;
    END IF;     -- non manual tax line
  END LOOP;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.chk_non_manual_line_f_trx_line',
                   'p_return_status = ' || p_return_status);
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.chk_non_manual_line_f_trx_line',
                   'p_error_buffer = '  || p_error_buffer);
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.chk_non_manual_line_f_trx_line.END',
                   'ZX_TDS_TAX_LINES_POPU_PKG: chk_non_manual_line_f_trx_line(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.chk_non_manual_line_f_trx_line',
                      p_error_buffer);
    END IF;

END chk_non_manual_line_f_trx_line;


-----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  process_cancel_tax_lines
--
--  DESCRIPTION
--  This procedure brings all canceled tax lines from zx_lines into
--  detail tax lines global temp table and marks them as cancel
--
--  CALLED BY
--   ZX_TDS_TAX_LINES_DETM_PKG

PROCEDURE process_cancel_tax_lines(
            p_event_class_rec   IN     ZX_API_PUB.EVENT_CLASS_REC_TYPE,
            p_return_status         OUT NOCOPY VARCHAR2,
            p_error_buffer          OUT NOCOPY VARCHAR2)

IS
BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.process_cancel_tax_lines.BEGIN',
                   'ZX_TDS_TAX_LINES_POPU_PKG: process_cancel_tax_lines(+)');
  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

-- bug 8470599 forcing the driving table in select clause from zx_lines_det_factors
    INSERT INTO zx_detail_tax_lines_gt
    (      tax_line_id,
           internal_organization_id,
           application_id,
           entity_code,
           event_class_code,
           event_type_code,
           trx_id,
           trx_line_id,
           trx_level_type,
           trx_line_number,
           doc_event_status,
           -- line_event_status,
           tax_event_class_code,
           tax_event_type_code,
           tax_line_number,
           content_owner_id,
           tax_regime_id,
           tax_regime_code,
           tax_id,
           tax,
           tax_status_id,
           tax_status_code,
           tax_rate_id,
           tax_rate_code,
           tax_rate,
           tax_apportionment_line_number,
           trx_id_level2,
           trx_id_level3,
           trx_id_level4,
           trx_id_level5,
           trx_id_level6,
           trx_user_key_level1,
           trx_user_key_level2,
           trx_user_key_level3,
           trx_user_key_level4,
           trx_user_key_level5,
           trx_user_key_level6,
           mrc_tax_line_flag,
           ledger_id,
           establishment_id,
           legal_entity_id,
           legal_entity_tax_reg_number,
           hq_estb_reg_number,
           hq_estb_party_tax_prof_id,
           currency_conversion_date,
           currency_conversion_type,
           currency_conversion_rate,
           tax_currency_conversion_date,
           tax_currency_conversion_type,
           tax_currency_conversion_rate,
           trx_currency_code,
           minimum_accountable_unit,
           precision,
           trx_number,
           trx_date,
           unit_price,
           line_amt,
           trx_line_quantity,
           tax_base_modifier_rate,
           ref_doc_application_id,
           ref_doc_entity_code,
           ref_doc_event_class_code,
           ref_doc_trx_id,
           ref_doc_line_id,
           ref_doc_line_quantity,
           other_doc_line_amt,
           other_doc_line_tax_amt,
           other_doc_line_taxable_amt,
           unrounded_taxable_amt,
           unrounded_tax_amt,
           related_doc_application_id,
           related_doc_entity_code,
           related_doc_event_class_code,
           related_doc_trx_id,
           related_doc_number,
           related_doc_date,
           applied_from_application_id,
           applied_from_event_class_code,
           applied_from_entity_code,
           applied_from_trx_id,
           applied_from_line_id,
           applied_from_trx_level_type,
           applied_from_trx_number,
           adjusted_doc_application_id,
           adjusted_doc_entity_code,
           adjusted_doc_event_class_code,
           adjusted_doc_trx_id,
           adjusted_doc_line_id,
           adjusted_doc_trx_level_type,
           adjusted_doc_number,
           adjusted_doc_date,
           applied_to_application_id,
           applied_to_event_class_code,
           applied_to_entity_code,
           applied_to_trx_id,
           applied_to_line_id,
           applied_to_trx_number,
           summary_tax_line_id,
           offset_link_to_tax_line_id,
           offset_flag,
           process_for_recovery_flag,
           tax_jurisdiction_id,
           tax_jurisdiction_code,
           place_of_supply,
           place_of_supply_type_code,
           place_of_supply_result_id,
           tax_date_rule_id,
           tax_date,
           tax_determine_date,
           tax_point_date,
           trx_line_date,
           tax_type_code,
           tax_code,
           tax_registration_id,
           tax_registration_number,
           registration_party_type,
           rounding_level_code,
           rounding_rule_code,
           rounding_lvl_party_tax_prof_id,
           rounding_lvl_party_type,
           compounding_tax_flag,
           orig_tax_status_id,
           orig_tax_status_code,
           orig_tax_rate_id,
           orig_tax_rate_code,
           orig_tax_rate,
           orig_tax_jurisdiction_id,
           orig_tax_jurisdiction_code,
           orig_tax_amt_included_flag,
           orig_self_assessed_flag,
           tax_currency_code,
           tax_amt,
           tax_amt_tax_curr,
           tax_amt_funcl_curr,
           taxable_amt,
           taxable_amt_tax_curr,
           taxable_amt_funcl_curr,
           orig_taxable_amt,
           orig_taxable_amt_tax_curr,
           cal_tax_amt,
           cal_tax_amt_tax_curr,
           cal_tax_amt_funcl_curr,
           orig_tax_amt,
           orig_tax_amt_tax_curr,
           rec_tax_amt,
           rec_tax_amt_tax_curr,
           rec_tax_amt_funcl_curr,
           nrec_tax_amt,
           nrec_tax_amt_tax_curr,
           nrec_tax_amt_funcl_curr,
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
           tax_apportionment_flag,
           historical_flag,
           taxable_basis_formula,
           tax_calculation_formula,
           cancel_flag,
           purge_flag,
           delete_flag,
           tax_amt_included_flag,
           self_assessed_flag,
           overridden_flag,
           manually_entered_flag,
           freeze_until_overridden_flag,
           copied_from_other_doc_flag,
           recalc_required_flag,
           settlement_flag,
           item_dist_changed_flag,
           associated_child_frozen_flag,
           tax_only_line_flag,
           compounding_dep_tax_flag,
           last_manual_entry,
           tax_provider_id,
           record_type_code,
           reporting_period_id,
           legal_message_appl_2,
           legal_message_status,
           legal_message_rate,
           legal_message_basis,
           legal_message_calc,
           legal_message_threshold,
           legal_message_pos,
           legal_message_trn,
           legal_message_exmpt,
           legal_message_excpt,
           tax_regime_template_id,
           tax_applicability_result_id,
           direct_rate_result_id,
           status_result_id,
           rate_result_id,
           basis_result_id,
           thresh_result_id,
           calc_result_id,
           tax_reg_num_det_result_id,
           eval_exmpt_result_id,
           eval_excpt_result_id,
           enforce_from_natural_acct_flag,
           tax_hold_code,
           tax_hold_released_code,
           prd_total_tax_amt,
           prd_total_tax_amt_tax_curr,
           prd_total_tax_amt_funcl_curr,
           internal_org_location_id,
           attribute_category,
           attribute1,
           attribute2,
           attribute3,
           attribute4,
           attribute5,
           attribute6,
           attribute7,
           attribute8,
           attribute9,
           attribute10,
           attribute11,
           attribute12,
           attribute13,
           attribute14,
           attribute15,
           global_attribute_category,
           global_attribute1,
           global_attribute2,
           global_attribute3,
           global_attribute4,
           global_attribute5,
           global_attribute6,
           global_attribute7,
           global_attribute8,
           global_attribute9,
           global_attribute10,
           global_attribute11,
           global_attribute12,
           global_attribute13,
           global_attribute14,
           global_attribute15,
           numeric1,
           numeric2,
           numeric3,
           numeric4,
           numeric5,
           numeric6,
           numeric7,
           numeric8,
           numeric9,
           numeric10,
           char1,
           char2,
           char3,
           char4,
           char5,
           char6,
           char7,
           char8,
           char9,
           char10,
           date1,
           date2,
           date3,
           date4,
           date5,
           date6,
           date7,
           date8,
           date9,
           date10,
           tax_rate_type,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login,
           line_assessable_value,
           legal_justification_text1,
           legal_justification_text2,
           legal_justification_text3,
           reporting_currency_code,
           trx_line_index,
           offset_tax_rate_code,
           proration_code,
           other_doc_source,
           reporting_only_flag,
           ctrl_total_line_tx_amt,
           sync_with_prvdr_flag,
           interface_entity_code,
           interface_tax_line_id,
           taxing_juris_geography_id,
           adjusted_doc_tax_line_id,
           object_version_number,
           legal_reporting_status,
           account_source_tax_rate_id
    )
    (SELECT /*+ leading(G) index(l ZX_LINES_u1 ) */
           L.tax_line_id,
           L.internal_organization_id,
           L.application_id,
           L.entity_code,
           L.event_class_code,
           L.event_type_code,
           L.trx_id,
           L.trx_line_id,
           L.trx_level_type,
           L.trx_line_number,
           L.doc_event_status,
           -- L.line_event_status,
           L.tax_event_class_code,
           L.tax_event_type_code,
           L.tax_line_number,
           L.content_owner_id,
           L.tax_regime_id,
           L.tax_regime_code,
           L.tax_id,
           L.tax,
           L.tax_status_id,
           L.tax_status_code,
           L.tax_rate_id,
           L.tax_rate_code,
           L.tax_rate,
           L.tax_apportionment_line_number,
           L.trx_id_level2,
           L.trx_id_level3,
           L.trx_id_level4,
           L.trx_id_level5,
           L.trx_id_level6,
           L.trx_user_key_level1,
           L.trx_user_key_level2,
           L.trx_user_key_level3,
           L.trx_user_key_level4,
           L.trx_user_key_level5,
           L.trx_user_key_level6,
           L.mrc_tax_line_flag,
           G.ledger_id,
           G.establishment_id,
           G.legal_entity_id,
           L.legal_entity_tax_reg_number,
           L.hq_estb_reg_number,
           L.hq_estb_party_tax_prof_id,
           G.currency_conversion_date,
           G.currency_conversion_type,
           G.currency_conversion_rate,
           L.tax_currency_conversion_date,
           L.tax_currency_conversion_type,
           L.tax_currency_conversion_rate,
           L.trx_currency_code,
           L.minimum_accountable_unit,
           L.precision,
           G.trx_number,
           G.trx_date,
           L.unit_price,
           L.line_amt,
           L.trx_line_quantity,
           L.tax_base_modifier_rate,
           L.ref_doc_application_id,
           L.ref_doc_entity_code,
           L.ref_doc_event_class_code,
           L.ref_doc_trx_id,
           L.ref_doc_line_id,
           L.ref_doc_line_quantity,
           L.other_doc_line_amt,
           L.other_doc_line_tax_amt,
           L.other_doc_line_taxable_amt,
           0,
           0,                                     -- L.unrounded_tax_amt,
           L.related_doc_application_id,
           L.related_doc_entity_code,
           L.related_doc_event_class_code,
           L.related_doc_trx_id,
           L.related_doc_number,
           L.related_doc_date,
           L.applied_from_application_id,
           L.applied_from_event_class_code,
           L.applied_from_entity_code,
           L.applied_from_trx_id,
           L.applied_from_line_id,
           L.applied_from_trx_level_type,
           L.applied_from_trx_number,
           L.adjusted_doc_application_id,
           L.adjusted_doc_entity_code,
           L.adjusted_doc_event_class_code,
           L.adjusted_doc_trx_id,
           L.adjusted_doc_line_id,
           L.adjusted_doc_trx_level_type,
           L.adjusted_doc_number,
           L.adjusted_doc_date,
           L.applied_to_application_id,
           L.applied_to_event_class_code,
           L.applied_to_entity_code,
           L.applied_to_trx_id,
           L.applied_to_line_id,
           L.applied_to_trx_number,
           L.summary_tax_line_id,
           L.offset_link_to_tax_line_id,
           L.offset_flag,
           DECODE(L.historical_flag,'Y','Y',L.process_for_recovery_flag),
           L.tax_jurisdiction_id,
           L.tax_jurisdiction_code,
           L.place_of_supply,
           L.place_of_supply_type_code,
           L.place_of_supply_result_id,
           L.tax_date_rule_id,
           L.tax_date,
           L.tax_determine_date,
           L.tax_point_date,
           L.trx_line_date,
           L.tax_type_code,
           L.tax_code,
           L.tax_registration_id,
           L.tax_registration_number,
           L.registration_party_type,
           L.rounding_level_code,
           L.rounding_rule_code,
           L.rounding_lvl_party_tax_prof_id,
           L.rounding_lvl_party_type,
           L.compounding_tax_flag,
           L.orig_tax_status_id,
           L.orig_tax_status_code,
           L.orig_tax_rate_id,
           L.orig_tax_rate_code,
           L.orig_tax_rate,
           L.orig_tax_jurisdiction_id,
           L.orig_tax_jurisdiction_code,
           L.orig_tax_amt_included_flag,
           L.orig_self_assessed_flag,
           L.tax_currency_code,
           0,                                     -- L.tax_amt,
           0,                                     -- L.tax_amt_tax_curr,
           0,                                     -- L.tax_amt_funcl_curr,
           0,                                     -- L.taxable_amt
           0,                                     -- L.taxable_amt_tax_curr,
           0,                                     -- L.taxable_amt_funcl_curr,
           DECODE(L.orig_taxable_amt,NULL,L.taxable_amt,L.orig_taxable_amt),
--orig_taxable_amt
           DECODE(L.orig_taxable_amt_tax_curr,NULL,L.taxable_amt_tax_curr,L.orig_taxable_amt_tax_curr),
-- orig_taxable_amt_tax_curr
           0 ,                                     -- L.cal_tax_amt,
           0 ,                                     -- L.cal_tax_amt_tax_curr,
           0 ,                                     -- L.cal_tax_amt_funcl_curr,
           DECODE(L.orig_tax_amt,NULL,L.tax_amt,L.orig_tax_amt),
--L.orig_tax_amt
           DECODE(L.orig_tax_amt_tax_curr,NULL, L.tax_amt_tax_curr,
L.orig_tax_amt_tax_curr),                         -- L.orig_tax_amt_tax_curr
           0,                                     --L.rec_tax_amt,
           0,                                     --L.rec_tax_amt_tax_curr,
           0,                                     --L.rec_tax_amt_funcl_curr,
           0,                                  -- L.nrec_tax_amt,
           0,                                  --L.nrec_tax_amt_tax_curr,
           0,                                  -- L.nrec_tax_amt_funcl_curr,
           L.tax_exemption_id,
           L.tax_rate_before_exemption,
           L.tax_rate_name_before_exemption,
           L.exempt_rate_modifier,
           L.exempt_certificate_number,
           L.exempt_reason,
           L.exempt_reason_code,
           L.tax_exception_id,
           L.tax_rate_before_exception,
           L.tax_rate_name_before_exception,
           L.exception_rate,
           L.tax_apportionment_flag,
           L.historical_flag,
           L.taxable_basis_formula,
           L.tax_calculation_formula,
           L.cancel_flag,
           L.purge_flag,
           L.delete_flag,
           L.tax_amt_included_flag,
           L.self_assessed_flag,
           L.overridden_flag,
           L.manually_entered_flag,
           L.freeze_until_overridden_flag,
           L.copied_from_other_doc_flag,
           L.recalc_required_flag,
           L.settlement_flag,
           L.item_dist_changed_flag,
           L.associated_child_frozen_flag,
           L.tax_only_line_flag,
           L.compounding_dep_tax_flag,
           L.last_manual_entry,
           L.tax_provider_id,
           L.record_type_code,
           L.reporting_period_id,
           L.legal_message_appl_2,
           L.legal_message_status,
           L.legal_message_rate,
           L.legal_message_basis,
           L.legal_message_calc,
           L.legal_message_threshold,
           L.legal_message_pos,
           L.legal_message_trn,
           L.legal_message_exmpt,
           L.legal_message_excpt,
           L.tax_regime_template_id,
           L.tax_applicability_result_id,
           L.direct_rate_result_id,
           L.status_result_id,
           L.rate_result_id,
           L.basis_result_id,
           L.thresh_result_id,
           L.calc_result_id,
           L.tax_reg_num_det_result_id,
           L.eval_exmpt_result_id,
           L.eval_excpt_result_id,
           L.enforce_from_natural_acct_flag,
           NULL,                                  --L.tax_hold_code,
           NULL,                                  -- L.tax_hold_released_code,
           NULL,                                --L.prd_total_tax_amt,
           NULL,                                 --L.prd_total_tax_amt_tax_curr,
           NULL,                               --L.prd_total_tax_amt_funcl_curr,
           L.internal_org_location_id,
           L.attribute_category,
           L.attribute1,
           L.attribute2,
           L.attribute3,
           L.attribute4,
           L.attribute5,
           L.attribute6,
           L.attribute7,
           L.attribute8,
           L.attribute9,
           L.attribute10,
           L.attribute11,
           L.attribute12,
           L.attribute13,
           L.attribute14,
           L.attribute15,
           L.global_attribute_category,
           L.global_attribute1,
           L.global_attribute2,
           L.global_attribute3,
           L.global_attribute4,
           L.global_attribute5,
           L.global_attribute6,
           L.global_attribute7,
           L.global_attribute8,
           L.global_attribute9,
           L.global_attribute10,
           L.global_attribute11,
           L.global_attribute12,
           L.global_attribute13,
           L.global_attribute14,
           L.global_attribute15,
           L.numeric1,
           L.numeric2,
           L.numeric3,
           L.numeric4,
           L.numeric5,
           L.numeric6,
           L.numeric7,
           L.numeric8,
           L.numeric9,
           L.numeric10,
           L.char1,
           L.char2,
           L.char3,
           L.char4,
           L.char5,
           L.char6,
           L.char7,
           L.char8,
           L.char9,
           L.char10,
           L.date1,
           L.date2,
           L.date3,
           L.date4,
           L.date5,
           L.date6,
           L.date7,
           L.date8,
           L.date9,
           L.date10,
           L.tax_rate_type,
           L.created_by,
           L.creation_date,
           L.last_updated_by,
           L.last_update_date,
           L.last_update_login,
           L.line_assessable_value,
           L.legal_justification_text1,
           L.legal_justification_text2,
           L.legal_justification_text3,
           L.reporting_currency_code,
           NULL, --L.trx_line_index,
           L.offset_tax_rate_code,
           NULL, -- L.proration_code,
           NULL, --L.other_doc_source,
           L.reporting_only_flag,
           L.ctrl_total_line_tx_amt,
           L.sync_with_prvdr_flag,
           L.interface_entity_code,
           L.interface_tax_line_id,
           L.taxing_juris_geography_id,
           L.adjusted_doc_tax_line_id,
           1,
           L.legal_reporting_status,
           L.account_source_tax_rate_id
     FROM ZX_LINES L,
          zx_lines_det_factors G
    WHERE G.application_id = p_event_class_rec.application_id     AND
          G.entity_code = p_event_class_rec.entity_code           AND
          G.event_class_code = p_event_class_rec.event_class_code AND
  --        G.trx_id = p_event_class_rec.trx_id                     AND
          G.event_id = p_event_class_rec.event_id                 AND
          L.trx_id  = G.trx_id                                    AND
          L.trx_line_id  = G.trx_line_id                          AND
          L.trx_level_type  = G.trx_level_type                    AND
          L.event_class_code = G.event_class_code
      AND L.entity_code = G.entity_code
      AND L.application_id = G.application_id
--    AND L.subscriber_id = G.subscriber_id
      AND G.line_level_action NOT IN ('SYNCHRONIZE', 'CANCEL', 'NO_CHANGE','DISCARD')
      AND L.Cancel_Flag = 'Y'
--      AND (L.tax_provider_id IS NOT NULL OR L.Cancel_Flag = 'Y')
      AND NOT EXISTS
          (SELECT /*+ INDEX(gt ZX_DETAIL_TAX_LINES_GT_U1) */
                  1
             FROM zx_detail_tax_lines_gt gt
            WHERE gt.application_id = L.application_id
              AND gt.entity_code = L.entity_code
              AND gt.event_class_code = L.event_class_code
              AND gt.trx_id  = L.trx_id
              AND gt.trx_line_id  = L.trx_line_id
              AND gt.trx_level_type  = L.trx_level_type
              AND gt.tax_regime_code  = L.tax_regime_code
              AND gt.tax  = L.tax
              AND NVL(gt.tax_apportionment_line_number, -999999) =
                              NVL(L.tax_apportionment_line_number, -999999)
          )
    );

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                  'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.process_cancel_tax_lines',
                  'Number of Rows Inserted: ' || SQL%ROWCOUNT);
  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.process_cancel_tax_lines',
                   'p_return_status = ' || p_return_status);
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.process_cancel_tax_lines',
                   'p_error_buffer  = ' || p_error_buffer);
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.process_cancel_tax_lines.END',
                   'ZX_TDS_TAX_LINES_POPU_PKG: process_cancel_tax_lines(-)');
  END IF;

EXCEPTION
    WHEN OTHERS THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.process_cancel_tax_lines',
                        p_error_buffer);
      END IF;

END process_cancel_tax_lines;

-----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  process_frozen_tax_lines
--
--  DESCRIPTION
--  This procedure brings all frozen tax lines which found not
--  applicable into detail tax lines global temp table and
--  mark them as cancel
--
--  CALLED BY
--   ZX_TDS_TAX_LINES_DETM_PKG

PROCEDURE process_frozen_tax_lines(
            p_event_class_rec   IN     ZX_API_PUB.EVENT_CLASS_REC_TYPE,
            p_return_status         OUT NOCOPY VARCHAR2,
            p_error_buffer          OUT NOCOPY VARCHAR2)

IS
BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.process_frozen_tax_lines.BEGIN',
                   'ZX_TDS_TAX_LINES_POPU_PKG: process_frozen_tax_lines(+)');
  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  -- bug 6906427: 1. Add code to handle OVERRIDE_TAX
  --              2. Make changes for UPDATE
  --
  IF p_event_class_rec.tax_event_type_code = 'OVERRIDE_TAX' THEN

    -- Fetch back canceled tax lines with frozen tax distributions
    --

-- bug 8470599 forcing the driving table in select clause from zx_lines_det_factors
    INSERT INTO zx_detail_tax_lines_gt
    (      tax_line_id,
           internal_organization_id,
           application_id,
           entity_code,
           event_class_code,
           event_type_code,
           trx_id,
           trx_line_id,
           trx_level_type,
           trx_line_number,
           doc_event_status,
           tax_event_class_code,
           tax_event_type_code,
           tax_line_number,
           content_owner_id,
           tax_regime_id,
           tax_regime_code,
           tax_id,
           tax,
           tax_status_id,
           tax_status_code,
           tax_rate_id,
           tax_rate_code,
           tax_rate,
           tax_apportionment_line_number,
           trx_id_level2,
           trx_id_level3,
           trx_id_level4,
           trx_id_level5,
           trx_id_level6,
           trx_user_key_level1,
           trx_user_key_level2,
           trx_user_key_level3,
           trx_user_key_level4,
           trx_user_key_level5,
           trx_user_key_level6,
           mrc_tax_line_flag,
           ledger_id,
           establishment_id,
           legal_entity_id,
           legal_entity_tax_reg_number,
           hq_estb_reg_number,
           hq_estb_party_tax_prof_id,
           currency_conversion_date,
           currency_conversion_type,
           currency_conversion_rate,
           tax_currency_conversion_date,
           tax_currency_conversion_type,
           tax_currency_conversion_rate,
           trx_currency_code,
           minimum_accountable_unit,
           precision,
           trx_number,
           trx_date,
           unit_price,
           line_amt,
           trx_line_quantity,
           tax_base_modifier_rate,
           ref_doc_application_id,
           ref_doc_entity_code,
           ref_doc_event_class_code,
           ref_doc_trx_id,
           ref_doc_line_id,
           ref_doc_line_quantity,
           other_doc_line_amt,
           other_doc_line_tax_amt,
           other_doc_line_taxable_amt,
           unrounded_taxable_amt,
           unrounded_tax_amt,
           related_doc_application_id,
           related_doc_entity_code,
           related_doc_event_class_code,
           related_doc_trx_id,
           related_doc_number,
           related_doc_date,
           applied_from_application_id,
           applied_from_event_class_code,
           applied_from_entity_code,
           applied_from_trx_id,
           applied_from_line_id,
           applied_from_trx_level_type,
           applied_from_trx_number,
           adjusted_doc_application_id,
           adjusted_doc_entity_code,
           adjusted_doc_event_class_code,
           adjusted_doc_trx_id,
           adjusted_doc_line_id,
           adjusted_doc_trx_level_type,
           adjusted_doc_number,
           adjusted_doc_date,
           applied_to_application_id,
           applied_to_event_class_code,
           applied_to_entity_code,
           applied_to_trx_id,
           applied_to_line_id,
           applied_to_trx_number,
           summary_tax_line_id,
           offset_link_to_tax_line_id,
           offset_flag,
           process_for_recovery_flag,
           tax_jurisdiction_id,
           tax_jurisdiction_code,
           place_of_supply,
           place_of_supply_type_code,
           place_of_supply_result_id,
           tax_date_rule_id,
           tax_date,
           tax_determine_date,
           tax_point_date,
           trx_line_date,
           tax_type_code,
           tax_code,
           tax_registration_id,
           tax_registration_number,
           registration_party_type,
           rounding_level_code,
           rounding_rule_code,
           rounding_lvl_party_tax_prof_id,
           rounding_lvl_party_type,
           compounding_tax_flag,
           orig_tax_status_id,
           orig_tax_status_code,
           orig_tax_rate_id,
           orig_tax_rate_code,
           orig_tax_rate,
           orig_tax_jurisdiction_id,
           orig_tax_jurisdiction_code,
           orig_tax_amt_included_flag,
           orig_self_assessed_flag,
           tax_currency_code,
           tax_amt,
           tax_amt_tax_curr,
           tax_amt_funcl_curr,
           taxable_amt,
           taxable_amt_tax_curr,
           taxable_amt_funcl_curr,
           orig_taxable_amt,
           orig_taxable_amt_tax_curr,
           cal_tax_amt,
           cal_tax_amt_tax_curr,
           cal_tax_amt_funcl_curr,
           orig_tax_amt,
           orig_tax_amt_tax_curr,
           rec_tax_amt,
           rec_tax_amt_tax_curr,
           rec_tax_amt_funcl_curr,
           nrec_tax_amt,
           nrec_tax_amt_tax_curr,
           nrec_tax_amt_funcl_curr,
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
           tax_apportionment_flag,
           historical_flag,
           taxable_basis_formula,
           tax_calculation_formula,
           cancel_flag,
           purge_flag,
           delete_flag,
           tax_amt_included_flag,
           self_assessed_flag,
           overridden_flag,
           manually_entered_flag,
           freeze_until_overridden_flag,
           copied_from_other_doc_flag,
           recalc_required_flag,
           settlement_flag,
           item_dist_changed_flag,
           associated_child_frozen_flag,
           tax_only_line_flag,
           compounding_dep_tax_flag,
           last_manual_entry,
           tax_provider_id,
           record_type_code,
           reporting_period_id,
           legal_message_appl_2,
           legal_message_status,
           legal_message_rate,
           legal_message_basis,
           legal_message_calc,
           legal_message_threshold,
           legal_message_pos,
           legal_message_trn,
           legal_message_exmpt,
           legal_message_excpt,
           tax_regime_template_id,
           tax_applicability_result_id,
           direct_rate_result_id,
           status_result_id,
           rate_result_id,
           basis_result_id,
           thresh_result_id,
           calc_result_id,
           tax_reg_num_det_result_id,
           eval_exmpt_result_id,
           eval_excpt_result_id,
           enforce_from_natural_acct_flag,
           tax_hold_code,
           tax_hold_released_code,
           prd_total_tax_amt,
           prd_total_tax_amt_tax_curr,
           prd_total_tax_amt_funcl_curr,
           internal_org_location_id,
           attribute_category,
           attribute1,
           attribute2,
           attribute3,
           attribute4,
           attribute5,
           attribute6,
           attribute7,
           attribute8,
           attribute9,
           attribute10,
           attribute11,
           attribute12,
           attribute13,
           attribute14,
           attribute15,
           global_attribute_category,
           global_attribute1,
           global_attribute2,
           global_attribute3,
           global_attribute4,
           global_attribute5,
           global_attribute6,
           global_attribute7,
           global_attribute8,
           global_attribute9,
           global_attribute10,
           global_attribute11,
           global_attribute12,
           global_attribute13,
           global_attribute14,
           global_attribute15,
           numeric1,
           numeric2,
           numeric3,
           numeric4,
           numeric5,
           numeric6,
           numeric7,
           numeric8,
           numeric9,
           numeric10,
           char1,
           char2,
           char3,
           char4,
           char5,
           char6,
           char7,
           char8,
           char9,
           char10,
           date1,
           date2,
           date3,
           date4,
           date5,
           date6,
           date7,
           date8,
           date9,
           date10,
           tax_rate_type,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login,
           line_assessable_value,
           legal_justification_text1,
           legal_justification_text2,
           legal_justification_text3,
           reporting_currency_code,
           trx_line_index,
           offset_tax_rate_code,
           proration_code,
           other_doc_source,
           reporting_only_flag,
           ctrl_total_line_tx_amt,
           sync_with_prvdr_flag,
           interface_entity_code,
           interface_tax_line_id,
           taxing_juris_geography_id,
           adjusted_doc_tax_line_id,
           object_version_number,
           legal_reporting_status,
           account_source_tax_rate_id
    )
   (SELECT /*+ leading(G) */
           L.tax_line_id,
           L.internal_organization_id,
           L.application_id,
           L.entity_code,
           L.event_class_code,
           L.event_type_code,
           L.trx_id,
           L.trx_line_id,
           L.trx_level_type,
           L.trx_line_number,
           L.doc_event_status,
           L.tax_event_class_code,
           L.tax_event_type_code,
           L.tax_line_number,
           L.content_owner_id,
           L.tax_regime_id,
           L.tax_regime_code,
           L.tax_id,
           L.tax,
           L.tax_status_id,
           L.tax_status_code,
           L.tax_rate_id,
           L.tax_rate_code,
           L.tax_rate,
           L.tax_apportionment_line_number,
           L.trx_id_level2,
           L.trx_id_level3,
           L.trx_id_level4,
           L.trx_id_level5,
           L.trx_id_level6,
           L.trx_user_key_level1,
           L.trx_user_key_level2,
           L.trx_user_key_level3,
           L.trx_user_key_level4,
           L.trx_user_key_level5,
           L.trx_user_key_level6,
           L.mrc_tax_line_flag,
           L.ledger_id,
           L.establishment_id,
           L.legal_entity_id,
           L.legal_entity_tax_reg_number,
           L.hq_estb_reg_number,
           L.hq_estb_party_tax_prof_id,
           L.currency_conversion_date,
           L.currency_conversion_type,
           L.currency_conversion_rate,
           L.tax_currency_conversion_date,
           L.tax_currency_conversion_type,
           L.tax_currency_conversion_rate,
           L.trx_currency_code,
           L.minimum_accountable_unit,
           L.precision,
           G.trx_number,
           L.trx_date,
           L.unit_price,
           L.line_amt,
           L.trx_line_quantity,
           L.tax_base_modifier_rate,
           L.ref_doc_application_id,
           L.ref_doc_entity_code,
           L.ref_doc_event_class_code,
           L.ref_doc_trx_id,
           L.ref_doc_line_id,
           L.ref_doc_line_quantity,
           L.other_doc_line_amt,
           L.other_doc_line_tax_amt,
           L.other_doc_line_taxable_amt,
           0,                                    -- L.unrounded_taxable_amt,
           0,                                    -- L.unrounded_tax_amt,
           L.related_doc_application_id,
           L.related_doc_entity_code,
           L.related_doc_event_class_code,
           L.related_doc_trx_id,
           L.related_doc_number,
           L.related_doc_date,
           L.applied_from_application_id,
           L.applied_from_event_class_code,
           L.applied_from_entity_code,
           L.applied_from_trx_id,
           L.applied_from_line_id,
           L.applied_from_trx_level_type,
           L.applied_from_trx_number,
           L.adjusted_doc_application_id,
           L.adjusted_doc_entity_code,
           L.adjusted_doc_event_class_code,
           L.adjusted_doc_trx_id,
           L.adjusted_doc_line_id,
           L.adjusted_doc_trx_level_type,
           L.adjusted_doc_number,
           L.adjusted_doc_date,
           L.applied_to_application_id,
           L.applied_to_event_class_code,
           L.applied_to_entity_code,
           L.applied_to_trx_id,
           L.applied_to_line_id,
           L.applied_to_trx_number,
           L.summary_tax_line_id,
           L.offset_link_to_tax_line_id,
           L.offset_flag,
           DECODE(L.Reporting_Only_Flag, 'N', 'Y', 'N'), -- L.Process_For_Recovery_Flag,
           L.tax_jurisdiction_id,
           L.tax_jurisdiction_code,
           L.place_of_supply,
           L.place_of_supply_type_code,
           L.place_of_supply_result_id,
           L.tax_date_rule_id,
           L.tax_date,
           L.tax_determine_date,
           L.tax_point_date,
           L.trx_line_date,
           L.tax_type_code,
           L.tax_code,
           L.tax_registration_id,
           L.tax_registration_number,
           L.registration_party_type,
           L.rounding_level_code,
           L.rounding_rule_code,
           L.rounding_lvl_party_tax_prof_id,
           L.rounding_lvl_party_type,
           L.compounding_tax_flag,
           L.orig_tax_status_id,
           L.orig_tax_status_code,
           L.orig_tax_rate_id,
           L.orig_tax_rate_code,
           L.orig_tax_rate,
           L.orig_tax_jurisdiction_id,
           L.orig_tax_jurisdiction_code,
           L.orig_tax_amt_included_flag,
           L.orig_self_assessed_flag,
           L.tax_currency_code,
           0,                                    -- L.tax_amt,
           0,                                    -- L.tax_amt_tax_curr,
           0,                                    -- L.tax_amt_funcl_curr,
           0,                                    -- L.taxable_amt,
           0,                                    -- L.taxable_amt_tax_curr,
           0,                                    -- L.taxable_amt_funcl_curr,
           DECODE(L.orig_taxable_amt, NULL,L.taxable_amt,
                  L.orig_taxable_amt),           -- L.orig_taxable_amt
           DECODE(L.orig_taxable_amt_tax_curr, NULL, L.taxable_amt_funcl_curr,
                  L.orig_taxable_amt_tax_curr),  -- L.orig_taxable_amt_tax_curr
           0,                                    -- L.cal_tax_amt,
           0,                                    -- L.cal_tax_amt_tax_curr,
           0,                                    -- L.cal_tax_amt_funcl_curr,
           DECODE(L.orig_tax_amt, NULL, L.tax_amt,
                  L.orig_tax_amt),               -- L.orig_tax_amt
           DECODE(L.orig_tax_amt_tax_curr, NULL, L.tax_amt,
                  L.orig_tax_amt_tax_curr),      -- L.orig_tax_amt_tax_curr
           0,                                    -- L.rec_tax_amt,
           0,                                    -- L.rec_tax_amt_tax_curr,
           0,                                    -- L.rec_tax_amt_funcl_curr,
           0,                                    -- L.nrec_tax_amt,
           0,                                    -- L.nrec_tax_amt_tax_curr,
           0,                                    -- L.nrec_tax_amt_funcl_curr,
           L.tax_exemption_id,
           L.tax_rate_before_exemption,
           L.tax_rate_name_before_exemption,
           L.exempt_rate_modifier,
           L.exempt_certificate_number,
           L.exempt_reason,
           L.exempt_reason_code,
           L.tax_exception_id,
           L.tax_rate_before_exception,
           L.tax_rate_name_before_exception,
           L.exception_rate,
           L.tax_apportionment_flag,
           L.historical_flag,
           L.taxable_basis_formula,
           L.tax_calculation_formula,
           'Y',                                   -- L.cancel_flag
           L.purge_flag,
           L.delete_flag,
           L.tax_amt_included_flag,
           L.self_assessed_flag,
           L.overridden_flag,
           L.manually_entered_flag,
           L.freeze_until_overridden_flag,
           L.copied_from_other_doc_flag,
           L.recalc_required_flag,
           L.settlement_flag,
           L.item_dist_changed_flag,
           L.associated_child_frozen_flag,
           L.tax_only_line_flag,
           L.compounding_dep_tax_flag,
           L.last_manual_entry,
           L.tax_provider_id,
           L.record_type_code,
           L.reporting_period_id,
           L.legal_message_appl_2,
           L.legal_message_status,
           L.legal_message_rate,
           L.legal_message_basis,
           L.legal_message_calc,
           L.legal_message_threshold,
           L.legal_message_pos,
           L.legal_message_trn,
           L.legal_message_exmpt,
           L.legal_message_excpt,
           L.tax_regime_template_id,
           L.tax_applicability_result_id,
           L.direct_rate_result_id,
           L.status_result_id,
           L.rate_result_id,
           L.basis_result_id,
           L.thresh_result_id,
           L.calc_result_id,
           L.tax_reg_num_det_result_id,
           L.eval_exmpt_result_id,
           L.eval_excpt_result_id,
           L.enforce_from_natural_acct_flag,
           L.tax_hold_code,
           L.tax_hold_released_code,
           NULL,                                 -- L.prd_total_tax_amt,
           NULL,                                 -- L.prd_total_tax_amt_tax_curr,
           NULL,                                 -- L.prd_total_tax_amt_funcl_curr,
           L.internal_org_location_id,
           L.attribute_category,
           L.attribute1,
           L.attribute2,
           L.attribute3,
           L.attribute4,
           L.attribute5,
           L.attribute6,
           L.attribute7,
           L.attribute8,
           L.attribute9,
           L.attribute10,
           L.attribute11,
           L.attribute12,
           L.attribute13,
           L.attribute14,
           L.attribute15,
           L.global_attribute_category,
           L.global_attribute1,
           L.global_attribute2,
           L.global_attribute3,
           L.global_attribute4,
           L.global_attribute5,
           L.global_attribute6,
           L.global_attribute7,
           L.global_attribute8,
           L.global_attribute9,
           L.global_attribute10,
           L.global_attribute11,
           L.global_attribute12,
           L.global_attribute13,
           L.global_attribute14,
           L.global_attribute15,
           L.numeric1,
           L.numeric2,
           L.numeric3,
           L.numeric4,
           L.numeric5,
           L.numeric6,
           L.numeric7,
           L.numeric8,
           L.numeric9,
           L.numeric10,
           L.char1,
           L.char2,
           L.char3,
           L.char4,
           L.char5,
           L.char6,
           L.char7,
           L.char8,
           L.char9,
           L.char10,
           L.date1,
           L.date2,
           L.date3,
           L.date4,
           L.date5,
           L.date6,
           L.date7,
           L.date8,
           L.date9,
           L.date10,
           L.tax_rate_type,
           L.created_by,
           L.creation_date,
           L.last_updated_by,
           L.last_update_date,
           L.last_update_login,
           L.line_assessable_value,
           L.legal_justification_text1,
           L.legal_justification_text2,
           L.legal_justification_text3,
           L.reporting_currency_code,
           NULL,                           -- L.trx_line_index
           NULL,                           -- L.offset_tax_rate_code
           NULL,                           -- L.proration_code
           NULL,                           -- L.other_doc_source
           L.reporting_only_flag,
           L.ctrl_total_line_tx_amt,
           DECODE(L.tax_provider_id, NULL, L.sync_with_prvdr_flag, 'Y'),
           L.interface_entity_code,
           L.interface_tax_line_id,
           L.taxing_juris_geography_id,
           L.adjusted_doc_tax_line_id,
           1,
           legal_reporting_status,
           L.account_source_tax_rate_id
    FROM  zx_lines L,
          zx_lines_det_factors G
    WHERE G.application_id = p_event_class_rec.application_id
      AND G.entity_code = p_event_class_rec.entity_code
      AND G.event_class_code = p_event_class_rec.event_class_code
      AND G.trx_id = p_event_class_rec.trx_id
      AND G.event_id = p_event_class_rec.event_id
      AND L.trx_id = G.trx_id
      AND L.trx_line_id = G.trx_line_id
      AND L.trx_level_type = G.trx_level_type
      AND L.event_class_code = G.event_class_code
      AND L.entity_code = G.entity_code
      AND L.application_id = G.application_id
      AND L.associated_child_frozen_flag = 'Y'
      AND L.cancel_flag = 'Y'
      AND L.tax_apportionment_line_number < 0
      AND NOT EXISTS ( SELECT 1
                         FROM  zx_detail_tax_lines_gt T
                         WHERE T.tax_line_id = L.tax_line_id
-- bug 8470599 these columns are redundant and are doing index range scan on ZX_DETAIL_TAX_LINES_GT_U1
--                           AND T.trx_id = L.trx_id
--                           AND T.trx_line_id = L.trx_line_id
--                           AND T.event_class_code = L.event_class_code
--                           AND T.entity_code = L.entity_code
--                           AND T.application_id = L.application_id
--                           AND T.trx_level_type = L.trx_level_type
                       )
      );

  ELSE

    -- bug 6906427: update tax line id if no grouping criteria change
    --
    --bug8517610

    UPDATE zx_detail_tax_lines_gt zlgt
       SET (tax_line_id, associated_child_frozen_flag, summary_tax_line_id,offset_link_to_tax_line_id) =
           ( SELECT /*+ INDEX(zl ZX_LINES_U1) */
                    tax_line_id, associated_child_frozen_flag, summary_tax_line_id,offset_link_to_tax_line_id
               FROM zx_lines zl
              WHERE zl.application_id = zlgt.application_id
                AND zl.entity_code = zlgt.entity_code
                AND zl.event_class_code = zlgt.event_class_code
                AND zl.trx_id = zlgt.trx_id
                and zl.trx_line_id = zlgt.trx_line_id
                AND zl.trx_level_type = zlgt.trx_level_type
                AND zl.internal_organization_id = zlgt.internal_organization_id
                AND NVL(zl.applied_from_trx_level_type, 'x') = NVL(zlgt.applied_from_trx_level_type, 'x')
                AND NVL(zl.adjusted_doc_trx_level_type, 'x') = NVL(zlgt.adjusted_doc_trx_level_type, 'x')
                AND NVL(zl.applied_from_application_id, 0) = NVL(zlgt.applied_from_application_id, 0)
                AND NVL(zl.applied_from_event_class_code, 'x') = NVL(zlgt.applied_from_event_class_code, 'x')
                AND NVL(zl.applied_from_entity_code, 'x') = NVL(zlgt.applied_from_entity_code, 'x')
                AND NVL(zl.applied_from_trx_id, 0) = NVL(zlgt.applied_from_trx_id, 0)
                AND NVL(zl.applied_from_line_id, 0) = NVL(zlgt.applied_from_line_id, 0)
                AND NVL(zl.adjusted_doc_application_id, 0) = NVL(zlgt.adjusted_doc_application_id, 0)
                AND NVL(zl.adjusted_doc_entity_code, 'x') = NVL(zlgt.adjusted_doc_entity_code, 'x')
                AND NVL(zl.adjusted_doc_event_class_code, 'x') = NVL(zlgt.adjusted_doc_event_class_code, 'x')
                AND NVL(zl.adjusted_doc_trx_id, 0) = NVL(zlgt.adjusted_doc_trx_id, 0)
                AND NVL(zl.tax_exemption_id, -999)  = NVL(zlgt.tax_exemption_id, -999)
                --AND NVL(zl.tax_rate_before_exemption, -999) = NVL(zlgt.tax_rate_before_exemption,  -999)
                --AND NVL(zl.tax_rate_name_before_exemption, 'x') = NVL(zlgt.tax_rate_name_before_exemption, 'x')
                --AND NVL(zl.exempt_rate_modifier, -999) = NVL(zlgt.exempt_rate_modifier, -999)
                AND NVL(zl.exempt_certificate_number, 'x') = NVL(zlgt.exempt_certificate_number, 'x')
                --AND NVL(zl.exempt_reason, 'x') = NVL(zlgt.exempt_reason, 'x')
                AND NVL(zl.exempt_reason_code, 'x') = NVL(zlgt.exempt_reason_code, 'x')
                AND NVL(zl.tax_exception_id,  -999) = NVL(zlgt.tax_exception_id, -999)
                --AND NVL(zl.tax_rate_before_exception, -999) = NVL(zlgt.tax_rate_before_exception,  -999)
                --AND NVL(zl.tax_rate_name_before_exception, 'x') = NVL(zlgt.tax_rate_name_before_exception, 'x')
                --AND NVL(zl.exception_rate, -999) = NVL(zlgt.exception_rate, -999)
                AND NVL(zl.content_owner_id, 0) = NVL(zlgt.content_owner_id, 0)
                AND zl.tax_regime_code = zlgt.tax_regime_code
                AND zl.tax = zlgt.tax
                AND NVL(zl.tax_status_code, 'x') = NVL(zlgt.tax_status_code, 'x')
                AND NVL(zl.tax_rate_id, 0) = NVL(zlgt.tax_rate_id, 0)
                AND NVL(zl.tax_rate_code, 'x') = NVL(zlgt.tax_rate_code, 'x')
                AND NVL(zl.tax_rate, -99) = NVL(zlgt.tax_rate, -99)
                AND NVL(zl.tax_jurisdiction_code, 'x') = NVL(zlgt.tax_jurisdiction_code, 'x')
                AND NVL(zl.ledger_id, 0) = NVL(zlgt.ledger_id, 0)
                AND NVL(zl.legal_entity_id, 0) = NVL(zlgt.legal_entity_id, 0)
                AND NVL(zl.establishment_id, 0) = NVL(zlgt.establishment_id, 0)
                AND NVL(TRUNC(zl.currency_conversion_date), SYSDATE) = NVL(TRUNC(zlgt.currency_conversion_date), SYSDATE)
                AND NVL(zl.currency_conversion_type,'x') = NVL(zlgt.currency_conversion_type,'x')
                AND NVL(zl.currency_conversion_rate, 1) = NVL(zlgt.currency_conversion_rate, 1)
                AND NVL(zl.taxable_basis_formula,'x') = NVL(zlgt.taxable_basis_formula,'x')
                AND NVL(zl.tax_calculation_formula,'x') = NVL(zlgt.tax_calculation_formula,'x')
                AND zl.tax_amt_included_flag = zlgt.tax_amt_included_flag
                AND zl.compounding_tax_flag = zlgt.compounding_tax_flag
                AND zl.self_assessed_flag = zlgt.self_assessed_flag
                AND zl.reporting_only_flag = zlgt.reporting_only_flag
                AND zl.copied_from_other_doc_flag = zlgt.copied_from_other_doc_flag
                AND NVL(zl.record_type_code,'x') = NVL(zlgt.record_type_code,'x')
                AND NVL(zl.tax_provider_id, 0) = NVL(zlgt.tax_provider_id, 0)
                AND zl.overridden_flag = zlgt.overridden_flag
                AND zl.manually_entered_flag =  zlgt.manually_entered_flag
                AND zl.tax_only_line_flag = zlgt.tax_only_line_flag
                AND zl.mrc_tax_line_flag = zlgt.mrc_tax_line_flag
                AND zl.historical_flag = zlgt.historical_flag
                AND NVL(zl.tax_apportionment_line_number, 1) = NVL(zlgt.tax_apportionment_line_number, 1)
                AND zl.tax_line_id <> zlgt.tax_line_id
                AND zl.cancel_flag <> 'Y'
                AND ROWNUM = 1
           )
     WHERE NVL(associated_child_frozen_flag, 'N') ='N'
       -- Bug 8348107
       AND (summary_tax_line_id IS NULL OR nvl(historical_flag,'N') = 'Y')
       AND NVL(tax_only_line_flag, 'N') = 'N'
       AND EXISTS (SELECT /*+ INDEX(zl ZX_LINES_U1) */
                          tax_line_id, associated_child_frozen_flag
                     FROM zx_lines zl
                    WHERE zl.application_id = zlgt.application_id
                      AND zl.entity_code = zlgt.entity_code
                      AND zl.event_class_code = zlgt.event_class_code
                      AND zl.trx_id = zlgt.trx_id
                      and zl.trx_line_id = zlgt.trx_line_id
                      AND zl.trx_level_type = zlgt.trx_level_type
                      AND zl.internal_organization_id = zlgt.internal_organization_id
                      AND NVL(zl.applied_from_trx_level_type, 'x') = NVL(zlgt.applied_from_trx_level_type, 'x')
                      AND NVL(zl.adjusted_doc_trx_level_type, 'x') = NVL(zlgt.adjusted_doc_trx_level_type, 'x')
                      AND NVL(zl.applied_from_application_id, 0) = NVL(zlgt.applied_from_application_id, 0)
                      AND NVL(zl.applied_from_event_class_code, 'x') = NVL(zlgt.applied_from_event_class_code, 'x')
                      AND NVL(zl.applied_from_entity_code, 'x') = NVL(zlgt.applied_from_entity_code, 'x')
                      AND NVL(zl.applied_from_trx_id, 0) = NVL(zlgt.applied_from_trx_id, 0)
                      AND NVL(zl.applied_from_line_id, 0) = NVL(zlgt.applied_from_line_id, 0)
                      AND NVL(zl.adjusted_doc_application_id, 0) = NVL(zlgt.adjusted_doc_application_id, 0)
                      AND NVL(zl.adjusted_doc_entity_code, 'x') = NVL(zlgt.adjusted_doc_entity_code, 'x')
                      AND NVL(zl.adjusted_doc_event_class_code, 'x') = NVL(zlgt.adjusted_doc_event_class_code, 'x')
                      AND NVL(zl.adjusted_doc_trx_id, 0) = NVL(zlgt.adjusted_doc_trx_id, 0)
                      AND NVL(zl.tax_exemption_id, -999)  = NVL(zlgt.tax_exemption_id, -999)
                --      AND NVL(zl.tax_rate_before_exemption, -999) = NVL(zlgt.tax_rate_before_exemption,  -999)
                --      AND NVL(zl.tax_rate_name_before_exemption, 'x') = NVL(zlgt.tax_rate_name_before_exemption, 'x')
                --      AND NVL(zl.exempt_rate_modifier, -999) = NVL(zlgt.exempt_rate_modifier, -999)
                      AND NVL(zl.exempt_certificate_number, 'x') = NVL(zlgt.exempt_certificate_number, 'x')
                --      AND NVL(zl.exempt_reason, 'x') = NVL(zlgt.exempt_reason, 'x')
                      AND NVL(zl.exempt_reason_code, 'x') = NVL(zlgt.exempt_reason_code, 'x')
                      AND NVL(zl.tax_exception_id,  -999) = NVL(zlgt.tax_exception_id, -999)
                --      AND NVL(zl.tax_rate_before_exception, -999) = NVL(zlgt.tax_rate_before_exception,  -999)
                --      AND NVL(zl.tax_rate_name_before_exception, 'x') = NVL(zlgt.tax_rate_name_before_exception, 'x')
                --      AND NVL(zl.exception_rate, -999) = NVL(zlgt.exception_rate, -999)
                      AND NVL(zl.content_owner_id, 0) = NVL(zlgt.content_owner_id, 0)
                      AND zl.tax_regime_code = zlgt.tax_regime_code
                      AND zl.tax = zlgt.tax
                      AND NVL(zl.tax_status_code, 'x') = NVL(zlgt.tax_status_code, 'x')
                      AND NVL(zl.tax_rate_id, 0) = NVL(zlgt.tax_rate_id, 0)
                      AND NVL(zl.tax_rate_code, 'x') = NVL(zlgt.tax_rate_code, 'x')
                      AND NVL(zl.tax_rate, -99) = NVL(zlgt.tax_rate, -99)
                      AND NVL(zl.tax_jurisdiction_code, 'x') = NVL(zlgt.tax_jurisdiction_code, 'x')
                      AND NVL(zl.ledger_id, 0) = NVL(zlgt.ledger_id, 0)
                      AND NVL(zl.legal_entity_id, 0) = NVL(zlgt.legal_entity_id, 0)
                      AND NVL(zl.establishment_id, 0) = NVL(zlgt.establishment_id, 0)
                      AND NVL(TRUNC(zl.currency_conversion_date), SYSDATE) = NVL(TRUNC(zlgt.currency_conversion_date), SYSDATE)
                      AND NVL(zl.currency_conversion_type,'x') = NVL(zlgt.currency_conversion_type,'x')
                      AND NVL(zl.currency_conversion_rate, 1) = NVL(zlgt.currency_conversion_rate, 1)
                      AND NVL(zl.taxable_basis_formula,'x') = NVL(zlgt.taxable_basis_formula,'x')
                      AND NVL(zl.tax_calculation_formula,'x') = NVL(zlgt.tax_calculation_formula,'x')
                      AND zl.tax_amt_included_flag = zlgt.tax_amt_included_flag
                      AND zl.compounding_tax_flag = zlgt.compounding_tax_flag
                      AND zl.self_assessed_flag = zlgt.self_assessed_flag
                      AND zl.reporting_only_flag = zlgt.reporting_only_flag
                      AND zl.copied_from_other_doc_flag = zlgt.copied_from_other_doc_flag
                      AND NVL(zl.record_type_code,'x') = NVL(zlgt.record_type_code,'x')
                      AND NVL(zl.tax_provider_id, 0) = NVL(zlgt.tax_provider_id, 0)
                      AND zl.overridden_flag = zlgt.overridden_flag
                      AND zl.manually_entered_flag =  zlgt.manually_entered_flag
                      AND zl.tax_only_line_flag = zlgt.tax_only_line_flag
                      AND zl.mrc_tax_line_flag = zlgt.mrc_tax_line_flag
                      AND zl.historical_flag = zlgt.historical_flag
                      AND NVL(zl.tax_apportionment_line_number, 1) = NVL(zlgt.tax_apportionment_line_number, 1)
                      AND zl.tax_line_id <> zlgt.tax_line_id
                      AND zl.cancel_flag <> 'Y'
                  );

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.process_frozen_tax_lines',
                     'Number of Rows Updated: ' || SQL%ROWCOUNT);
    END IF;

-- bug 8470599 forcing the driving table in select clause from zx_lines_det_factors
    INSERT INTO zx_detail_tax_lines_gt
    (      tax_line_id,
           internal_organization_id,
           application_id,
           entity_code,
           event_class_code,
           event_type_code,
           trx_id,
           trx_line_id,
           trx_level_type,
           trx_line_number,
           doc_event_status,
           tax_event_class_code,
           tax_event_type_code,
           tax_line_number,
           content_owner_id,
           tax_regime_id,
           tax_regime_code,
           tax_id,
           tax,
           tax_status_id,
           tax_status_code,
           tax_rate_id,
           tax_rate_code,
           tax_rate,
           tax_apportionment_line_number,
           trx_id_level2,
           trx_id_level3,
           trx_id_level4,
           trx_id_level5,
           trx_id_level6,
           trx_user_key_level1,
           trx_user_key_level2,
           trx_user_key_level3,
           trx_user_key_level4,
           trx_user_key_level5,
           trx_user_key_level6,
           mrc_tax_line_flag,
           ledger_id,
           establishment_id,
           legal_entity_id,
           legal_entity_tax_reg_number,
           hq_estb_reg_number,
           hq_estb_party_tax_prof_id,
           currency_conversion_date,
           currency_conversion_type,
           currency_conversion_rate,
           tax_currency_conversion_date,
           tax_currency_conversion_type,
           tax_currency_conversion_rate,
           trx_currency_code,
           minimum_accountable_unit,
           precision,
           trx_number,
           trx_date,
           unit_price,
           line_amt,
           trx_line_quantity,
           tax_base_modifier_rate,
           ref_doc_application_id,
           ref_doc_entity_code,
           ref_doc_event_class_code,
           ref_doc_trx_id,
           ref_doc_line_id,
           ref_doc_line_quantity,
           other_doc_line_amt,
           other_doc_line_tax_amt,
           other_doc_line_taxable_amt,
           unrounded_taxable_amt,
           unrounded_tax_amt,
           related_doc_application_id,
           related_doc_entity_code,
           related_doc_event_class_code,
           related_doc_trx_id,
           related_doc_number,
           related_doc_date,
           applied_from_application_id,
           applied_from_event_class_code,
           applied_from_entity_code,
           applied_from_trx_id,
           applied_from_line_id,
           applied_from_trx_level_type,
           applied_from_trx_number,
           adjusted_doc_application_id,
           adjusted_doc_entity_code,
           adjusted_doc_event_class_code,
           adjusted_doc_trx_id,
           adjusted_doc_line_id,
           adjusted_doc_trx_level_type,
           adjusted_doc_number,
           adjusted_doc_date,
           applied_to_application_id,
           applied_to_event_class_code,
           applied_to_entity_code,
           applied_to_trx_id,
           applied_to_line_id,
           applied_to_trx_number,
           summary_tax_line_id,
           offset_link_to_tax_line_id,
           offset_flag,
           process_for_recovery_flag,
           tax_jurisdiction_id,
           tax_jurisdiction_code,
           place_of_supply,
           place_of_supply_type_code,
           place_of_supply_result_id,
           tax_date_rule_id,
           tax_date,
           tax_determine_date,
           tax_point_date,
           trx_line_date,
           tax_type_code,
           tax_code,
           tax_registration_id,
           tax_registration_number,
           registration_party_type,
           rounding_level_code,
           rounding_rule_code,
           rounding_lvl_party_tax_prof_id,
           rounding_lvl_party_type,
           compounding_tax_flag,
           orig_tax_status_id,
           orig_tax_status_code,
           orig_tax_rate_id,
           orig_tax_rate_code,
           orig_tax_rate,
           orig_tax_jurisdiction_id,
           orig_tax_jurisdiction_code,
           orig_tax_amt_included_flag,
           orig_self_assessed_flag,
           tax_currency_code,
           tax_amt,
           tax_amt_tax_curr,
           tax_amt_funcl_curr,
           taxable_amt,
           taxable_amt_tax_curr,
           taxable_amt_funcl_curr,
           orig_taxable_amt,
           orig_taxable_amt_tax_curr,
           cal_tax_amt,
           cal_tax_amt_tax_curr,
           cal_tax_amt_funcl_curr,
           orig_tax_amt,
           orig_tax_amt_tax_curr,
           rec_tax_amt,
           rec_tax_amt_tax_curr,
           rec_tax_amt_funcl_curr,
           nrec_tax_amt,
           nrec_tax_amt_tax_curr,
           nrec_tax_amt_funcl_curr,
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
           tax_apportionment_flag,
           historical_flag,
           taxable_basis_formula,
           tax_calculation_formula,
           cancel_flag,
           purge_flag,
           delete_flag,
           tax_amt_included_flag,
           self_assessed_flag,
           overridden_flag,
           manually_entered_flag,
           freeze_until_overridden_flag,
           copied_from_other_doc_flag,
           recalc_required_flag,
           settlement_flag,
           item_dist_changed_flag,
           associated_child_frozen_flag,
           tax_only_line_flag,
           compounding_dep_tax_flag,
           last_manual_entry,
           tax_provider_id,
           record_type_code,
           reporting_period_id,
           legal_message_appl_2,
           legal_message_status,
           legal_message_rate,
           legal_message_basis,
           legal_message_calc,
           legal_message_threshold,
           legal_message_pos,
           legal_message_trn,
           legal_message_exmpt,
           legal_message_excpt,
           tax_regime_template_id,
           tax_applicability_result_id,
           direct_rate_result_id,
           status_result_id,
           rate_result_id,
           basis_result_id,
           thresh_result_id,
           calc_result_id,
           tax_reg_num_det_result_id,
           eval_exmpt_result_id,
           eval_excpt_result_id,
           enforce_from_natural_acct_flag,
           tax_hold_code,
           tax_hold_released_code,
           prd_total_tax_amt,
           prd_total_tax_amt_tax_curr,
           prd_total_tax_amt_funcl_curr,
           internal_org_location_id,
           attribute_category,
           attribute1,
           attribute2,
           attribute3,
           attribute4,
           attribute5,
           attribute6,
           attribute7,
           attribute8,
           attribute9,
           attribute10,
           attribute11,
           attribute12,
           attribute13,
           attribute14,
           attribute15,
           global_attribute_category,
           global_attribute1,
           global_attribute2,
           global_attribute3,
           global_attribute4,
           global_attribute5,
           global_attribute6,
           global_attribute7,
           global_attribute8,
           global_attribute9,
           global_attribute10,
           global_attribute11,
           global_attribute12,
           global_attribute13,
           global_attribute14,
           global_attribute15,
           numeric1,
           numeric2,
           numeric3,
           numeric4,
           numeric5,
           numeric6,
           numeric7,
           numeric8,
           numeric9,
           numeric10,
           char1,
           char2,
           char3,
           char4,
           char5,
           char6,
           char7,
           char8,
           char9,
           char10,
           date1,
           date2,
           date3,
           date4,
           date5,
           date6,
           date7,
           date8,
           date9,
           date10,
           tax_rate_type,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login,
           line_assessable_value,
           legal_justification_text1,
           legal_justification_text2,
           legal_justification_text3,
           reporting_currency_code,
           trx_line_index,
           offset_tax_rate_code,
           proration_code,
           other_doc_source,
           reporting_only_flag,
           ctrl_total_line_tx_amt,
           sync_with_prvdr_flag,
           interface_entity_code,
           interface_tax_line_id,
           taxing_juris_geography_id,
           adjusted_doc_tax_line_id,
           object_version_number,
           legal_reporting_status,
           account_source_tax_rate_id
    )
   (SELECT /*+ leading(G) index(l ZX_LINES_u1 ) */
           L.tax_line_id,
           L.internal_organization_id,
           L.application_id,
           L.entity_code,
           L.event_class_code,
           L.event_type_code,
           L.trx_id,
           L.trx_line_id,
           L.trx_level_type,
           L.trx_line_number,
           L.doc_event_status,
           L.tax_event_class_code,
           L.tax_event_type_code,
           L.tax_line_number,
           L.content_owner_id,
           L.tax_regime_id,
           L.tax_regime_code,
           L.tax_id,
           L.tax,
           L.tax_status_id,
           L.tax_status_code,
           L.tax_rate_id,
           L.tax_rate_code,
           L.tax_rate,
           -- bug 6906427
           NVL(-((SELECT max(ABS(tax_apportionment_line_number))
                    FROM zx_detail_tax_lines_gt gt1
                   WHERE gt1.application_id = L.application_id
                     AND gt1.entity_code = L.entity_code
                     AND gt1.event_class_code = L.event_class_code
                     AND gt1.trx_id = L.trx_id
                     AND gt1.trx_line_id = L.trx_line_id
                     AND gt1.trx_level_type = L.trx_level_type
                     AND gt1.tax_regime_code = L.tax_regime_code
                     AND gt1.tax = L.tax
                  -- ) + 1                             -- Commented as a fix for Bug#7340317
                  ) + L.tax_apportionment_line_number  -- Added as a fix for Bug#7340317
                ),
               -L.tax_apportionment_line_number
              ),
           L.trx_id_level2,
           L.trx_id_level3,
           L.trx_id_level4,
           L.trx_id_level5,
           L.trx_id_level6,
           L.trx_user_key_level1,
           L.trx_user_key_level2,
           L.trx_user_key_level3,
           L.trx_user_key_level4,
           L.trx_user_key_level5,
           L.trx_user_key_level6,
           L.mrc_tax_line_flag,
           L.ledger_id,
           L.establishment_id,
           L.legal_entity_id,
           L.legal_entity_tax_reg_number,
           L.hq_estb_reg_number,
           L.hq_estb_party_tax_prof_id,
           L.currency_conversion_date,
           L.currency_conversion_type,
           L.currency_conversion_rate,
           L.tax_currency_conversion_date,
           L.tax_currency_conversion_type,
           L.tax_currency_conversion_rate,
           L.trx_currency_code,
           L.minimum_accountable_unit,
           L.precision,
           G.trx_number,
           L.trx_date,
           L.unit_price,
           L.line_amt,
           L.trx_line_quantity,
           L.tax_base_modifier_rate,
           L.ref_doc_application_id,
           L.ref_doc_entity_code,
           L.ref_doc_event_class_code,
           L.ref_doc_trx_id,
           L.ref_doc_line_id,
           L.ref_doc_line_quantity,
           L.other_doc_line_amt,
           L.other_doc_line_tax_amt,
           L.other_doc_line_taxable_amt,
           0,                                    -- L.unrounded_taxable_amt,
           0,                                    -- L.unrounded_tax_amt,
           L.related_doc_application_id,
           L.related_doc_entity_code,
           L.related_doc_event_class_code,
           L.related_doc_trx_id,
           L.related_doc_number,
           L.related_doc_date,
           L.applied_from_application_id,
           L.applied_from_event_class_code,
           L.applied_from_entity_code,
           L.applied_from_trx_id,
           L.applied_from_line_id,
           L.applied_from_trx_level_type,
           L.applied_from_trx_number,
           L.adjusted_doc_application_id,
           L.adjusted_doc_entity_code,
           L.adjusted_doc_event_class_code,
           L.adjusted_doc_trx_id,
           L.adjusted_doc_line_id,
           L.adjusted_doc_trx_level_type,
           L.adjusted_doc_number,
           L.adjusted_doc_date,
           L.applied_to_application_id,
           L.applied_to_event_class_code,
           L.applied_to_entity_code,
           L.applied_to_trx_id,
           L.applied_to_line_id,
           L.applied_to_trx_number,
           L.summary_tax_line_id,
           L.offset_link_to_tax_line_id,
           L.offset_flag,
           DECODE(L.Reporting_Only_Flag, 'N', 'Y', 'N'), -- L.Process_For_Recovery_Flag,
           L.tax_jurisdiction_id,
           L.tax_jurisdiction_code,
           L.place_of_supply,
           L.place_of_supply_type_code,
           L.place_of_supply_result_id,
           L.tax_date_rule_id,
           L.tax_date,
           L.tax_determine_date,
           L.tax_point_date,
           L.trx_line_date,
           L.tax_type_code,
           L.tax_code,
           L.tax_registration_id,
           L.tax_registration_number,
           L.registration_party_type,
           L.rounding_level_code,
           L.rounding_rule_code,
           L.rounding_lvl_party_tax_prof_id,
           L.rounding_lvl_party_type,
           L.compounding_tax_flag,
           L.orig_tax_status_id,
           L.orig_tax_status_code,
           L.orig_tax_rate_id,
           L.orig_tax_rate_code,
           L.orig_tax_rate,
           L.orig_tax_jurisdiction_id,
           L.orig_tax_jurisdiction_code,
           L.orig_tax_amt_included_flag,
           L.orig_self_assessed_flag,
           L.tax_currency_code,
           0,                                    -- L.tax_amt,
           0,                                    -- L.tax_amt_tax_curr,
           0,                                    -- L.tax_amt_funcl_curr,
           0,                                    -- L.taxable_amt,
           0,                                    -- L.taxable_amt_tax_curr,
           0,                                    -- L.taxable_amt_funcl_curr,
           DECODE(L.orig_taxable_amt, NULL,L.taxable_amt,
                  L.orig_taxable_amt),           -- L.orig_taxable_amt
           DECODE(L.orig_taxable_amt_tax_curr, NULL, L.taxable_amt_funcl_curr,
                  L.orig_taxable_amt_tax_curr),  -- L.orig_taxable_amt_tax_curr
           0,                                    -- L.cal_tax_amt,
           0,                                    -- L.cal_tax_amt_tax_curr,
           0,                                    -- L.cal_tax_amt_funcl_curr,
           DECODE(L.orig_tax_amt, NULL, L.tax_amt,
                  L.orig_tax_amt),               -- L.orig_tax_amt
           DECODE(L.orig_tax_amt_tax_curr, NULL, L.tax_amt,
                  L.orig_tax_amt_tax_curr),      -- L.orig_tax_amt_tax_curr
           0,                                    -- L.rec_tax_amt,
           0,                                    -- L.rec_tax_amt_tax_curr,
           0,                                    -- L.rec_tax_amt_funcl_curr,
           0,                                    -- L.nrec_tax_amt,
           0,                                    -- L.nrec_tax_amt_tax_curr,
           0,                                    -- L.nrec_tax_amt_funcl_curr,
           L.tax_exemption_id,
           L.tax_rate_before_exemption,
           L.tax_rate_name_before_exemption,
           L.exempt_rate_modifier,
           L.exempt_certificate_number,
           L.exempt_reason,
           L.exempt_reason_code,
           L.tax_exception_id,
           L.tax_rate_before_exception,
           L.tax_rate_name_before_exception,
           L.exception_rate,
           L.tax_apportionment_flag,
           L.historical_flag,
           L.taxable_basis_formula,
           L.tax_calculation_formula,
           'Y',                                   -- L.cancel_flag
           L.purge_flag,
           L.delete_flag,
           L.tax_amt_included_flag,
           L.self_assessed_flag,
           L.overridden_flag,
           L.manually_entered_flag,
           L.freeze_until_overridden_flag,
           L.copied_from_other_doc_flag,
           L.recalc_required_flag,
           L.settlement_flag,
           L.item_dist_changed_flag,
           L.associated_child_frozen_flag,
           L.tax_only_line_flag,
           L.compounding_dep_tax_flag,
           L.last_manual_entry,
           L.tax_provider_id,
           L.record_type_code,
           L.reporting_period_id,
           L.legal_message_appl_2,
           L.legal_message_status,
           L.legal_message_rate,
           L.legal_message_basis,
           L.legal_message_calc,
           L.legal_message_threshold,
           L.legal_message_pos,
           L.legal_message_trn,
           L.legal_message_exmpt,
           L.legal_message_excpt,
           L.tax_regime_template_id,
           L.tax_applicability_result_id,
           L.direct_rate_result_id,
           L.status_result_id,
           L.rate_result_id,
           L.basis_result_id,
           L.thresh_result_id,
           L.calc_result_id,
           L.tax_reg_num_det_result_id,
           L.eval_exmpt_result_id,
           L.eval_excpt_result_id,
           L.enforce_from_natural_acct_flag,
           L.tax_hold_code,
           L.tax_hold_released_code,
           NULL,                                 -- L.prd_total_tax_amt,
           NULL,                                 -- L.prd_total_tax_amt_tax_curr,
           NULL,                                 -- L.prd_total_tax_amt_funcl_curr,
           L.internal_org_location_id,
           L.attribute_category,
           L.attribute1,
           L.attribute2,
           L.attribute3,
           L.attribute4,
           L.attribute5,
           L.attribute6,
           L.attribute7,
           L.attribute8,
           L.attribute9,
           L.attribute10,
           L.attribute11,
           L.attribute12,
           L.attribute13,
           L.attribute14,
           L.attribute15,
           L.global_attribute_category,
           L.global_attribute1,
           L.global_attribute2,
           L.global_attribute3,
           L.global_attribute4,
           L.global_attribute5,
           L.global_attribute6,
           L.global_attribute7,
           L.global_attribute8,
           L.global_attribute9,
           L.global_attribute10,
           L.global_attribute11,
           L.global_attribute12,
           L.global_attribute13,
           L.global_attribute14,
           L.global_attribute15,
           L.numeric1,
           L.numeric2,
           L.numeric3,
           L.numeric4,
           L.numeric5,
           L.numeric6,
           L.numeric7,
           L.numeric8,
           L.numeric9,
           L.numeric10,
           L.char1,
           L.char2,
           L.char3,
           L.char4,
           L.char5,
           L.char6,
           L.char7,
           L.char8,
           L.char9,
           L.char10,
           L.date1,
           L.date2,
           L.date3,
           L.date4,
           L.date5,
           L.date6,
           L.date7,
           L.date8,
           L.date9,
           L.date10,
           L.tax_rate_type,
           L.created_by,
           L.creation_date,
           L.last_updated_by,
           L.last_update_date,
           L.last_update_login,
           L.line_assessable_value,
           L.legal_justification_text1,
           L.legal_justification_text2,
           L.legal_justification_text3,
           L.reporting_currency_code,
           NULL,                           -- L.trx_line_index
           NULL,                           -- L.offset_tax_rate_code
           NULL,                           -- L.proration_code
           NULL,                           -- L.other_doc_source
           L.reporting_only_flag,
           L.ctrl_total_line_tx_amt,
           DECODE(L.tax_provider_id, NULL, L.sync_with_prvdr_flag, 'Y'),
           L.interface_entity_code,
           L.interface_tax_line_id,
           L.taxing_juris_geography_id,
           L.adjusted_doc_tax_line_id,
           1,
           DECODE(L.legal_reporting_status, '111111111111111',
                  '000000000000000', L.legal_reporting_status),
           L.account_source_tax_rate_id
    FROM  zx_lines L,
          zx_lines_det_factors G
    WHERE G.application_id = p_event_class_rec.application_id
      AND G.entity_code = p_event_class_rec.entity_code
      AND G.event_class_code = p_event_class_rec.event_class_code
      --  AND G.trx_id = p_event_class_rec.trx_id
      AND G.event_id = p_event_class_rec.event_id
      AND L.trx_id = G.trx_id
      AND L.trx_line_id = G.trx_line_id
      AND L.trx_level_type = G.trx_level_type
      AND L.event_class_code = G.event_class_code
      AND L.entity_code = G.entity_code
      AND L.application_id = G.application_id
      AND L.associated_child_frozen_flag = 'Y'
      AND L.cancel_flag <> 'Y'
      -- bug 6906427
      AND G.line_level_action = 'UPDATE'
      AND NOT EXISTS ( SELECT 1
                         FROM  zx_detail_tax_lines_gt T
                         WHERE T.tax_line_id = L.tax_line_id
-- bug 8470599 these columns are redundant and are doing index range scan on ZX_DETAIL_TAX_LINES_GT_U1
--                           AND T.trx_id = L.trx_id
--                           AND T.trx_line_id = L.trx_line_id
--                           AND T.event_class_code = L.event_class_code
--                           AND T.entity_code = L.entity_code
--                           AND T.application_id = L.application_id
--                           AND T.trx_level_type = L.trx_level_type
                           --  AND T.tax = L.tax
                           --  AND T.tax_regime_code = L.tax_regime_code
                           --  AND T.tax_status_code = L.tax_status_code
                           --  AND T.tax_line_number = L.tax_line_number
                       )
      );

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.process_frozen_tax_lines',
                     'Number of Rows Inserted: ' || SQL%ROWCOUNT);
    END IF;

  END IF;   -- tax_event_type_code = OVERRIDE_TAX, or else

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.process_frozen_tax_lines',
                   'p_return_status = ' || p_return_status);
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.process_frozen_tax_lines',
                   'p_error_buffer  = ' || p_error_buffer);
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.process_frozen_tax_lines.END',
                   'ZX_TDS_TAX_LINES_POPU_PKG: process_frozen_tax_lines(-)');
  END IF;

EXCEPTION
    WHEN OTHERS THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.process_frozen_tax_lines',
                        p_error_buffer);
      END IF;

END process_frozen_tax_lines;

-----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  process_discard_tax_lines
--
--  DESCRIPTION
--  This procedure brings all discarded tax lines from zx_lines into
--  detail tax lines global temp table
--
--  CALLED BY
--   ZX_TDS_TAX_LINES_DETM_PKG

PROCEDURE process_discard_tax_lines(
            p_event_class_rec   IN     ZX_API_PUB.EVENT_CLASS_REC_TYPE,
            p_return_status         OUT NOCOPY VARCHAR2,
            p_error_buffer          OUT NOCOPY VARCHAR2)

IS
BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.process_discard_tax_lines.BEGIN',
                   'ZX_TDS_TAX_LINES_POPU_PKG: process_discard_tax_lines(+)');
  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

-- bug 8470599 forcing the driving table in select clause from zx_lines_det_factors
    INSERT INTO zx_detail_tax_lines_gt
    (      tax_line_id,
           internal_organization_id,
           application_id,
           entity_code,
           event_class_code,
           event_type_code,
           trx_id,
           trx_line_id,
           trx_level_type,
           trx_line_number,
           doc_event_status,
           -- line_event_status,
           tax_event_class_code,
           tax_event_type_code,
           tax_line_number,
           content_owner_id,
           tax_regime_id,
           tax_regime_code,
           tax_id,
           tax,
           tax_status_id,
           tax_status_code,
           tax_rate_id,
           tax_rate_code,
           tax_rate,
           tax_apportionment_line_number,
           trx_id_level2,
           trx_id_level3,
           trx_id_level4,
           trx_id_level5,
           trx_id_level6,
           trx_user_key_level1,
           trx_user_key_level2,
           trx_user_key_level3,
           trx_user_key_level4,
           trx_user_key_level5,
           trx_user_key_level6,
           mrc_tax_line_flag,
           ledger_id,
           establishment_id,
           legal_entity_id,
           legal_entity_tax_reg_number,
           hq_estb_reg_number,
           hq_estb_party_tax_prof_id,
           currency_conversion_date,
           currency_conversion_type,
           currency_conversion_rate,
           tax_currency_conversion_date,
           tax_currency_conversion_type,
           tax_currency_conversion_rate,
           trx_currency_code,
           minimum_accountable_unit,
           precision,
           trx_number,
           trx_date,
           unit_price,
           line_amt,
           trx_line_quantity,
           tax_base_modifier_rate,
           ref_doc_application_id,
           ref_doc_entity_code,
           ref_doc_event_class_code,
           ref_doc_trx_id,
           ref_doc_line_id,
           ref_doc_line_quantity,
           other_doc_line_amt,
           other_doc_line_tax_amt,
           other_doc_line_taxable_amt,
           unrounded_taxable_amt,
           unrounded_tax_amt,
           related_doc_application_id,
           related_doc_entity_code,
           related_doc_event_class_code,
           related_doc_trx_id,
           related_doc_number,
           related_doc_date,
           applied_from_application_id,
           applied_from_event_class_code,
           applied_from_entity_code,
           applied_from_trx_id,
           applied_from_line_id,
           applied_from_trx_level_type,
           applied_from_trx_number,
           adjusted_doc_application_id,
           adjusted_doc_entity_code,
           adjusted_doc_event_class_code,
           adjusted_doc_trx_id,
           adjusted_doc_line_id,
           adjusted_doc_trx_level_type,
           adjusted_doc_number,
           adjusted_doc_date,
           applied_to_application_id,
           applied_to_event_class_code,
           applied_to_entity_code,
           applied_to_trx_id,
           applied_to_line_id,
           applied_to_trx_level_type,
           applied_to_trx_number,
           summary_tax_line_id,
           offset_link_to_tax_line_id,
           offset_flag,
           process_for_recovery_flag,
           tax_jurisdiction_id,
           tax_jurisdiction_code,
           place_of_supply,
           place_of_supply_type_code,
           place_of_supply_result_id,
           tax_date_rule_id,
           tax_date,
           tax_determine_date,
           tax_point_date,
           trx_line_date,
           tax_type_code,
           tax_code,
           tax_registration_id,
           tax_registration_number,
           registration_party_type,
           rounding_level_code,
           rounding_rule_code,
           rounding_lvl_party_tax_prof_id,
           rounding_lvl_party_type,
           compounding_tax_flag,
           orig_tax_status_id,
           orig_tax_status_code,
           orig_tax_rate_id,
           orig_tax_rate_code,
           orig_tax_rate,
           orig_tax_jurisdiction_id,
           orig_tax_jurisdiction_code,
           orig_tax_amt_included_flag,
           orig_self_assessed_flag,
           tax_currency_code,
           tax_amt,
           tax_amt_tax_curr,
           tax_amt_funcl_curr,
           taxable_amt,
           taxable_amt_tax_curr,
           taxable_amt_funcl_curr,
           orig_taxable_amt,
           orig_taxable_amt_tax_curr,
           cal_tax_amt,
           cal_tax_amt_tax_curr,
           cal_tax_amt_funcl_curr,
           orig_tax_amt,
           orig_tax_amt_tax_curr,
           rec_tax_amt,
           rec_tax_amt_tax_curr,
           rec_tax_amt_funcl_curr,
           nrec_tax_amt,
           nrec_tax_amt_tax_curr,
           nrec_tax_amt_funcl_curr,
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
           tax_apportionment_flag,
           historical_flag,
           taxable_basis_formula,
           tax_calculation_formula,
           cancel_flag,
           purge_flag,
           delete_flag,
           tax_amt_included_flag,
           self_assessed_flag,
           overridden_flag,
           manually_entered_flag,
           freeze_until_overridden_flag,
           copied_from_other_doc_flag,
           recalc_required_flag,
           settlement_flag,
           item_dist_changed_flag,
           associated_child_frozen_flag,
           tax_only_line_flag,
           compounding_dep_tax_flag,
           last_manual_entry,
           tax_provider_id,
           record_type_code,
           reporting_period_id,
           legal_message_appl_2,
           legal_message_status,
           legal_message_rate,
           legal_message_basis,
           legal_message_calc,
           legal_message_threshold,
           legal_message_pos,
           legal_message_trn,
           legal_message_exmpt,
           legal_message_excpt,
           tax_regime_template_id,
           tax_applicability_result_id,
           direct_rate_result_id,
           status_result_id,
           rate_result_id,
           basis_result_id,
           thresh_result_id,
           calc_result_id,
           tax_reg_num_det_result_id,
           eval_exmpt_result_id,
           eval_excpt_result_id,
           enforce_from_natural_acct_flag,
           tax_hold_code,
           tax_hold_released_code,
           prd_total_tax_amt,
           prd_total_tax_amt_tax_curr,
           prd_total_tax_amt_funcl_curr,
           internal_org_location_id,
           attribute_category,
           attribute1,
           attribute2,
           attribute3,
           attribute4,
           attribute5,
           attribute6,
           attribute7,
           attribute8,
           attribute9,
           attribute10,
           attribute11,
           attribute12,
           attribute13,
           attribute14,
           attribute15,
           global_attribute_category,
           global_attribute1,
           global_attribute2,
           global_attribute3,
           global_attribute4,
           global_attribute5,
           global_attribute6,
           global_attribute7,
           global_attribute8,
           global_attribute9,
           global_attribute10,
           global_attribute11,
           global_attribute12,
           global_attribute13,
           global_attribute14,
           global_attribute15,
           numeric1,
           numeric2,
           numeric3,
           numeric4,
           numeric5,
           numeric6,
           numeric7,
           numeric8,
           numeric9,
           numeric10,
           char1,
           char2,
           char3,
           char4,
           char5,
           char6,
           char7,
           char8,
           char9,
           char10,
           date1,
           date2,
           date3,
           date4,
           date5,
           date6,
           date7,
           date8,
           date9,
           date10,
           tax_rate_type,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login,
           line_assessable_value,
           legal_justification_text1,
           legal_justification_text2,
           legal_justification_text3,
           reporting_currency_code,
           trx_line_index,
           offset_tax_rate_code,
           proration_code,
           other_doc_source,
           reporting_only_flag,
           ctrl_total_line_tx_amt,
           sync_with_prvdr_flag,
           interface_entity_code,
           interface_tax_line_id,
           taxing_juris_geography_id,
           adjusted_doc_tax_line_id,
           object_version_number,
           legal_reporting_status,
           account_source_tax_rate_id
    )
   (SELECT /*+ leading(G) */
           L.tax_line_id,
           L.internal_organization_id,
           L.application_id,
           L.entity_code,
           L.event_class_code,
           L.event_type_code,
           L.trx_id,
           L.trx_line_id,
           L.trx_level_type,
           L.trx_line_number,
           L.doc_event_status,
           -- L.line_event_status,
           L.tax_event_class_code,
           L.tax_event_type_code,
           L.tax_line_number,
           L.content_owner_id,
           L.tax_regime_id,
           L.tax_regime_code,
           L.tax_id,
           L.tax,
           L.tax_status_id,
           L.tax_status_code,
           L.tax_rate_id,
           L.tax_rate_code,
           L.tax_rate,
           L.tax_apportionment_line_number,
           L.trx_id_level2,
           L.trx_id_level3,
           L.trx_id_level4,
           L.trx_id_level5,
           L.trx_id_level6,
           L.trx_user_key_level1,
           L.trx_user_key_level2,
           L.trx_user_key_level3,
           L.trx_user_key_level4,
           L.trx_user_key_level5,
           L.trx_user_key_level6,
           L.mrc_tax_line_flag,
           G.ledger_id,
           G.establishment_id,
           G.legal_entity_id,
           L.legal_entity_tax_reg_number,
           L.hq_estb_reg_number,
           L.hq_estb_party_tax_prof_id,
           G.currency_conversion_date,
           G.currency_conversion_type,
           G.currency_conversion_rate,
           L.tax_currency_conversion_date,
           L.tax_currency_conversion_type,
           L.tax_currency_conversion_rate,
           L.trx_currency_code,
           L.minimum_accountable_unit,
           L.precision,
           G.trx_number,
           G.trx_date,
           L.unit_price,
           L.line_amt,
           L.trx_line_quantity,
           L.tax_base_modifier_rate,
           L.ref_doc_application_id,
           L.ref_doc_entity_code,
           L.ref_doc_event_class_code,
           L.ref_doc_trx_id,
           L.ref_doc_line_id,
           L.ref_doc_line_quantity,
           L.other_doc_line_amt,
           L.other_doc_line_tax_amt,
           L.other_doc_line_taxable_amt,
           0,                                     -- L.unrounded_taxable_amt
           0,                                     -- L.unrounded_tax_amt
           L.related_doc_application_id,
           L.related_doc_entity_code,
           L.related_doc_event_class_code,
           L.related_doc_trx_id,
           L.related_doc_number,
           L.related_doc_date,
           L.applied_from_application_id,
           L.applied_from_event_class_code,
           L.applied_from_entity_code,
           L.applied_from_trx_id,
           L.applied_from_line_id,
           L.applied_from_trx_level_type,
           L.applied_from_trx_number,
           L.adjusted_doc_application_id,
           L.adjusted_doc_entity_code,
           L.adjusted_doc_event_class_code,
           L.adjusted_doc_trx_id,
           L.adjusted_doc_line_id,
           L.adjusted_doc_trx_level_type,
           L.adjusted_doc_number,
           L.adjusted_doc_date,
           L.applied_to_application_id,
           L.applied_to_event_class_code,
           L.applied_to_entity_code,
           L.applied_to_trx_id,
           L.applied_to_line_id,
           L.applied_to_trx_level_type,
           L.applied_to_trx_number,
           L.summary_tax_line_id,
           L.offset_link_to_tax_line_id,
           L.offset_flag,
           DECODE(L.historical_flag,'Y','Y','N'), -- L.Process_For_Recovery_Flag
           L.tax_jurisdiction_id,
           L.tax_jurisdiction_code,
           L.place_of_supply,
           L.place_of_supply_type_code,
           L.place_of_supply_result_id,
           L.tax_date_rule_id,
           L.tax_date,
           L.tax_determine_date,
           L.tax_point_date,
           L.trx_line_date,
           L.tax_type_code,
           L.tax_code,
           L.tax_registration_id,
           L.tax_registration_number,
           L.registration_party_type,
           L.rounding_level_code,
           L.rounding_rule_code,
           L.rounding_lvl_party_tax_prof_id,
           L.rounding_lvl_party_type,
           L.compounding_tax_flag,
           L.orig_tax_status_id,
           L.orig_tax_status_code,
           L.orig_tax_rate_id,
           L.orig_tax_rate_code,
           L.orig_tax_rate,
           L.orig_tax_jurisdiction_id,
           L.orig_tax_jurisdiction_code,
           L.orig_tax_amt_included_flag,
           L.orig_self_assessed_flag,
           L.tax_currency_code,
           0,                                     -- L.tax_amt
           0,                                     -- L.tax_amt_tax_curr
           0,                                     -- L.tax_amt_funcl_curr   ??
           0,                                     -- taxable_amt
           0,                                     -- taxable_amt_tax_curr
           0,                                     -- L.taxable_amt_funcl_curr   ??
           DECODE(L.orig_taxable_amt, NULL, L.taxable_amt,
                  L.orig_taxable_amt),            -- orig_taxable_amt
           DECODE(L.orig_taxable_amt_tax_curr, NULL, L.taxable_amt_tax_curr,
                  L.orig_taxable_amt_tax_curr),   -- orig_taxable_amt_tax_curr
           0,                                     -- L.cal_tax_amt
           0,                                     -- L.cal_tax_amt_tax_curr
           0,                                     -- L.cal_tax_amt_funcl_curr   ??
           DECODE(L.orig_tax_amt, NULL, L.tax_amt,
                  L.orig_tax_amt),                -- L.orig_tax_amt,
           DECODE(L.orig_tax_amt_tax_curr, NULL,  L.tax_amt_tax_curr,
                  L.orig_tax_amt_tax_curr),       -- L.orig_tax_amt_tax_curr
           0,                                     -- L.rec_tax_amt
           0,                                     -- L.rec_tax_amt_tax_curr
           0,                                     -- L.rec_tax_amt_funcl_curr        ??
           0,                                     -- L.nrec_tax_amt
           0,                                     -- L.nrec_tax_amt_tax_curr
           0,                                     -- L.nrec_tax_amt_funcl_curr       ??
           L.tax_exemption_id,
           L.tax_rate_before_exemption,
           L.tax_rate_name_before_exemption,
           L.exempt_rate_modifier,
           L.exempt_certificate_number,
           L.exempt_reason,
           L.exempt_reason_code,
           L.tax_exception_id,
           L.tax_rate_before_exception,
           L.tax_rate_name_before_exception,
           L.exception_rate,
           L.tax_apportionment_flag,
           L.historical_flag,
           L.taxable_basis_formula,
           L.tax_calculation_formula,
           'Y',                                   -- DECODE(L.historical_flag, 'Y', 'Y', L.cancel_flag),
           L.purge_flag,
           L.delete_flag,
           L.tax_amt_included_flag,
           L.self_assessed_flag,
           L.overridden_flag,
           L.manually_entered_flag,
           L.freeze_until_overridden_flag,
           L.copied_from_other_doc_flag,
           L.recalc_required_flag,
           L.settlement_flag,
           L.item_dist_changed_flag,
           L.associated_child_frozen_flag,
           L.tax_only_line_flag,
           L.compounding_dep_tax_flag,
           L.last_manual_entry,
           L.tax_provider_id,
           L.record_type_code,
           L.reporting_period_id,
           L.legal_message_appl_2,
           L.legal_message_status,
           L.legal_message_rate,
           L.legal_message_basis,
           L.legal_message_calc,
           L.legal_message_threshold,
           L.legal_message_pos,
           L.legal_message_trn,
           L.legal_message_exmpt,
           L.legal_message_excpt,
           L.tax_regime_template_id,
           L.tax_applicability_result_id,
           L.direct_rate_result_id,
           L.status_result_id,
           L.rate_result_id,
           L.basis_result_id,
           L.thresh_result_id,
           L.calc_result_id,
           L.tax_reg_num_det_result_id,
           L.eval_exmpt_result_id,
           L.eval_excpt_result_id,
           L.enforce_from_natural_acct_flag,
           NULL, --L.tax_hold_code,
           NULL, --L.tax_hold_released_code,
           NULL,                                  -- L.prd_total_tax_amt
           NULL,                                  -- L.prd_total_tax_amt_tax_curr
           NULL,                                  -- L.prd_total_tax_amt_funcl_curr
           L.internal_org_location_id,
           L.attribute_category,
           L.attribute1,
           L.attribute2,
           L.attribute3,
           L.attribute4,
           L.attribute5,
           L.attribute6,
           L.attribute7,
           L.attribute8,
           L.attribute9,
           L.attribute10,
           L.attribute11,
           L.attribute12,
           L.attribute13,
           L.attribute14,
           L.attribute15,
           L.global_attribute_category,
           L.global_attribute1,
           L.global_attribute2,
           L.global_attribute3,
           L.global_attribute4,
           L.global_attribute5,
           L.global_attribute6,
           L.global_attribute7,
           L.global_attribute8,
           L.global_attribute9,
           L.global_attribute10,
           L.global_attribute11,
           L.global_attribute12,
           L.global_attribute13,
           L.global_attribute14,
           L.global_attribute15,
           L.numeric1,
           L.numeric2,
           L.numeric3,
           L.numeric4,
           L.numeric5,
           L.numeric6,
           L.numeric7,
           L.numeric8,
           L.numeric9,
           L.numeric10,
           L.char1,
           L.char2,
           L.char3,
           L.char4,
           L.char5,
           L.char6,
           L.char7,
           L.char8,
           L.char9,
           L.char10,
           L.date1,
           L.date2,
           L.date3,
           L.date4,
           L.date5,
           L.date6,
           L.date7,
           L.date8,
           L.date9,
           L.date10,
           L.tax_rate_type,
           L.created_by,
           L.creation_date,
           L.last_updated_by,
           L.last_update_date,
           L.last_update_login,
           L.line_assessable_value,
           L.legal_justification_text1,
           L.legal_justification_text2,
           L.legal_justification_text3,
           L.reporting_currency_code,
           NULL,                           -- L.trx_line_index
           NULL,                           -- L.offset_tax_rate_code
           NULL,                           -- L.proration_code
           NULL,                           -- L.other_doc_source
           L.reporting_only_flag,
           L.ctrl_total_line_tx_amt,
           L.sync_with_prvdr_flag,
           L.interface_entity_code,
           L.interface_tax_line_id,
           L.taxing_juris_geography_id,
           L.adjusted_doc_tax_line_id,
           1,
           decode(L.legal_reporting_status,'111111111111111',
                  '000000000000000',L.legal_reporting_status),
           L.account_source_tax_rate_id
    FROM  ZX_LINES L,
          zx_lines_det_factors G
    WHERE G.application_id = p_event_class_rec.application_id      AND
          G.entity_code = p_event_class_rec.entity_code            AND
          G.event_class_code = p_event_class_rec.event_class_code  AND
          -- G.trx_id = p_event_class_rec.trx_id                   AND
          G.event_id = p_event_class_rec.event_id                  AND
          L.trx_id = G.trx_id                                      AND
          L.trx_line_id = G.trx_line_id                            AND
          L.trx_level_type = G.trx_level_type                      AND
          L.event_class_code = G.event_class_code                  AND
          -- L.event_type_code = G.event_type_code                 AND
          L.entity_code = G.entity_code                            AND
          L.application_id = G.application_id                      AND
          -- L.subscriber_id = G.subscriber_id                     AND
          G.line_level_action IN ('DISCARD', 'UNAPPLY_FROM')       AND
          L.tax_provider_id IS NULL
      AND NOT EXISTS
          (SELECT /*+ INDEX(gt ZX_DETAIL_TAX_LINES_GT_U1) */
                  1
             FROM zx_detail_tax_lines_gt gt
            WHERE gt.application_id = L.application_id
              AND gt.entity_code = L.entity_code
              AND gt.event_class_code = L.event_class_code
              AND gt.trx_id  = L.trx_id
              AND gt.trx_line_id  = L.trx_line_id
              AND gt.trx_level_type  = L.trx_level_type
              AND gt.tax_regime_code  = L.tax_regime_code
              AND gt.tax  = L.tax
              AND NVL(gt.tax_apportionment_line_number, -999999) =
                              NVL(L.tax_apportionment_line_number, -999999)
          )
   );

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.process_discard_tax_lines',
                   'p_return_status = ' || p_return_status);
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.process_discard_tax_lines',
                   'p_error_buffer  = ' || p_error_buffer);
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.process_discard_tax_lines.END',
                   'ZX_TDS_TAX_LINES_POPU_PKG: process_discard_tax_lines(-)');
  END IF;

EXCEPTION
    WHEN OTHERS THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.process_discard_tax_lines',
                        p_error_buffer);
      END IF;

END process_discard_tax_lines;

-----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  process_cancel_trx_lines
--
--  DESCRIPTION
--  This procedure processes cancelled trx lines (line_level_action='CANCEL')
--   It brings all tax lines from zx_lines into detail tax lines global temp table
--   and mark them as cancelled
--
--  CALLED BY
--   ZX_TDS_TAX_LINES_DETM_PKG

PROCEDURE process_cancel_trx_lines(
            p_event_class_rec   IN     ZX_API_PUB.EVENT_CLASS_REC_TYPE,
            p_return_status         OUT NOCOPY VARCHAR2,
            p_error_buffer          OUT NOCOPY VARCHAR2)

IS
BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.process_cancel_trx_lines.BEGIN',
                   'ZX_TDS_TAX_LINES_POPU_PKG: process_cancel_trx_lines(+)');
  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

-- bug 8470599 forcing the driving table in select clause from zx_lines_det_factors
    INSERT INTO zx_detail_tax_lines_gt
    (      tax_line_id,
           internal_organization_id,
           application_id,
           entity_code,
           event_class_code,
           event_type_code,
           trx_id,
           trx_line_id,
           trx_level_type,
           trx_line_number,
           doc_event_status,
           tax_event_class_code,
           tax_event_type_code,
           tax_line_number,
           content_owner_id,
           tax_regime_id,
           tax_regime_code,
           tax_id,
           tax,
           tax_status_id,
           tax_status_code,
           tax_rate_id,
           tax_rate_code,
           tax_rate,
           tax_apportionment_line_number,
           trx_id_level2,
           trx_id_level3,
           trx_id_level4,
           trx_id_level5,
           trx_id_level6,
           trx_user_key_level1,
           trx_user_key_level2,
           trx_user_key_level3,
           trx_user_key_level4,
           trx_user_key_level5,
           trx_user_key_level6,
           mrc_tax_line_flag,
           ledger_id,
           establishment_id,
           legal_entity_id,
           legal_entity_tax_reg_number,
           hq_estb_reg_number,
           hq_estb_party_tax_prof_id,
           currency_conversion_date,
           currency_conversion_type,
           currency_conversion_rate,
           tax_currency_conversion_date,
           tax_currency_conversion_type,
           tax_currency_conversion_rate,
           trx_currency_code,
           minimum_accountable_unit,
           precision,
           trx_number,
           trx_date,
           unit_price,
           line_amt,
           trx_line_quantity,
           tax_base_modifier_rate,
           ref_doc_application_id,
           ref_doc_entity_code,
           ref_doc_event_class_code,
           ref_doc_trx_id,
           ref_doc_line_id,
           ref_doc_line_quantity,
           other_doc_line_amt,
           other_doc_line_tax_amt,
           other_doc_line_taxable_amt,
           unrounded_taxable_amt,
           unrounded_tax_amt,
           related_doc_application_id,
           related_doc_entity_code,
           related_doc_event_class_code,
           related_doc_trx_id,
           related_doc_number,
           related_doc_date,
           applied_from_application_id,
           applied_from_event_class_code,
           applied_from_entity_code,
           applied_from_trx_id,
           applied_from_line_id,
           applied_from_trx_level_type,
           applied_from_trx_number,
           adjusted_doc_application_id,
           adjusted_doc_entity_code,
           adjusted_doc_event_class_code,
           adjusted_doc_trx_id,
           adjusted_doc_line_id,
           adjusted_doc_trx_level_type,
           adjusted_doc_number,
           adjusted_doc_date,
           applied_to_application_id,
           applied_to_event_class_code,
           applied_to_entity_code,
           applied_to_trx_id,
           applied_to_line_id,
           applied_to_trx_number,
           summary_tax_line_id,
           offset_link_to_tax_line_id,
           offset_flag,
           process_for_recovery_flag,
           tax_jurisdiction_id,
           tax_jurisdiction_code,
           place_of_supply,
           place_of_supply_type_code,
           place_of_supply_result_id,
           tax_date_rule_id,
           tax_date,
           tax_determine_date,
           tax_point_date,
           trx_line_date,
           tax_type_code,
           tax_code,
           tax_registration_id,
           tax_registration_number,
           registration_party_type,
           rounding_level_code,
           rounding_rule_code,
           rounding_lvl_party_tax_prof_id,
           rounding_lvl_party_type,
           compounding_tax_flag,
           orig_tax_status_id,
           orig_tax_status_code,
           orig_tax_rate_id,
           orig_tax_rate_code,
           orig_tax_rate,
           orig_tax_jurisdiction_id,
           orig_tax_jurisdiction_code,
           orig_tax_amt_included_flag,
           orig_self_assessed_flag,
           tax_currency_code,
           tax_amt,
           tax_amt_tax_curr,
           tax_amt_funcl_curr,
           taxable_amt,
           taxable_amt_tax_curr,
           taxable_amt_funcl_curr,
           orig_taxable_amt,
           orig_taxable_amt_tax_curr,
           cal_tax_amt,
           cal_tax_amt_tax_curr,
           cal_tax_amt_funcl_curr,
           orig_tax_amt,
           orig_tax_amt_tax_curr,
           rec_tax_amt,
           rec_tax_amt_tax_curr,
           rec_tax_amt_funcl_curr,
           nrec_tax_amt,
           nrec_tax_amt_tax_curr,
           nrec_tax_amt_funcl_curr,
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
           tax_apportionment_flag,
           historical_flag,
           taxable_basis_formula,
           tax_calculation_formula,
           cancel_flag,
           purge_flag,
           delete_flag,
           tax_amt_included_flag,
           self_assessed_flag,
           overridden_flag,
           manually_entered_flag,
           freeze_until_overridden_flag,
           copied_from_other_doc_flag,
           recalc_required_flag,
           settlement_flag,
           item_dist_changed_flag,
           associated_child_frozen_flag,
           tax_only_line_flag,
           compounding_dep_tax_flag,
           last_manual_entry,
           tax_provider_id,
           record_type_code,
           reporting_period_id,
           legal_message_appl_2,
           legal_message_status,
           legal_message_rate,
           legal_message_basis,
           legal_message_calc,
           legal_message_threshold,
           legal_message_pos,
           legal_message_trn,
           legal_message_exmpt,
           legal_message_excpt,
           tax_regime_template_id,
           tax_applicability_result_id,
           direct_rate_result_id,
           status_result_id,
           rate_result_id,
           basis_result_id,
           thresh_result_id,
           calc_result_id,
           tax_reg_num_det_result_id,
           eval_exmpt_result_id,
           eval_excpt_result_id,
           enforce_from_natural_acct_flag,
           tax_hold_code,
           tax_hold_released_code,
           prd_total_tax_amt,
           prd_total_tax_amt_tax_curr,
           prd_total_tax_amt_funcl_curr,
           internal_org_location_id,
           attribute_category,
           attribute1,
           attribute2,
           attribute3,
           attribute4,
           attribute5,
           attribute6,
           attribute7,
           attribute8,
           attribute9,
           attribute10,
           attribute11,
           attribute12,
           attribute13,
           attribute14,
           attribute15,
           global_attribute_category,
           global_attribute1,
           global_attribute2,
           global_attribute3,
           global_attribute4,
           global_attribute5,
           global_attribute6,
           global_attribute7,
           global_attribute8,
           global_attribute9,
           global_attribute10,
           global_attribute11,
           global_attribute12,
           global_attribute13,
           global_attribute14,
           global_attribute15,
           numeric1,
           numeric2,
           numeric3,
           numeric4,
           numeric5,
           numeric6,
           numeric7,
           numeric8,
           numeric9,
           numeric10,
           char1,
           char2,
           char3,
           char4,
           char5,
           char6,
           char7,
           char8,
           char9,
           char10,
           date1,
           date2,
           date3,
           date4,
           date5,
           date6,
           date7,
           date8,
           date9,
           date10,
           tax_rate_type,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login,
           line_assessable_value,
           legal_justification_text1,
           legal_justification_text2,
           legal_justification_text3,
           reporting_currency_code,
           trx_line_index,
           offset_tax_rate_code,
           proration_code,
           other_doc_source,
           reporting_only_flag,
           ctrl_total_line_tx_amt,
           sync_with_prvdr_flag,
           interface_entity_code,
           interface_tax_line_id,
           taxing_juris_geography_id,
           adjusted_doc_tax_line_id,
           object_version_number,
           legal_reporting_status,
           account_source_tax_rate_id
    )
   (SELECT /*+ leading(G) */
           L.tax_line_id,
           L.internal_organization_id,
           L.application_id,
           L.entity_code,
           L.event_class_code,
           L.event_type_code,
           L.trx_id,
           L.trx_line_id,
           L.trx_level_type,
           L.trx_line_number,
           L.doc_event_status,
           L.tax_event_class_code,
           L.tax_event_type_code,
           L.tax_line_number,
           L.content_owner_id,
           L.tax_regime_id,
           L.tax_regime_code,
           L.tax_id,
           L.tax,
           L.tax_status_id,
           L.tax_status_code,
           L.tax_rate_id,
           L.tax_rate_code,
           L.tax_rate,
           L.tax_apportionment_line_number,
           L.trx_id_level2,
           L.trx_id_level3,
           L.trx_id_level4,
           L.trx_id_level5,
           L.trx_id_level6,
           L.trx_user_key_level1,
           L.trx_user_key_level2,
           L.trx_user_key_level3,
           L.trx_user_key_level4,
           L.trx_user_key_level5,
           L.trx_user_key_level6,
           L.mrc_tax_line_flag,
           L.ledger_id,
           L.establishment_id,
           L.legal_entity_id,
           L.legal_entity_tax_reg_number,
           L.hq_estb_reg_number,
           L.hq_estb_party_tax_prof_id,
           L.currency_conversion_date,
           L.currency_conversion_type,
           L.currency_conversion_rate,
           L.tax_currency_conversion_date,
           L.tax_currency_conversion_type,
           L.tax_currency_conversion_rate,
           L.trx_currency_code,
           L.minimum_accountable_unit,
           L.precision,
           G.trx_number,
           L.trx_date,
           L.unit_price,
           L.line_amt,
           L.trx_line_quantity,
           L.tax_base_modifier_rate,
           L.ref_doc_application_id,
           L.ref_doc_entity_code,
           L.ref_doc_event_class_code,
           L.ref_doc_trx_id,
           L.ref_doc_line_id,
           L.ref_doc_line_quantity,
           L.other_doc_line_amt,
           L.other_doc_line_tax_amt,
           L.other_doc_line_taxable_amt,
           L.unrounded_taxable_amt,
           0,                                     -- L.unrounded_tax_amt,
           L.related_doc_application_id,
           L.related_doc_entity_code,
           L.related_doc_event_class_code,
           L.related_doc_trx_id,
           L.related_doc_number,
           L.related_doc_date,
           L.applied_from_application_id,
           L.applied_from_event_class_code,
           L.applied_from_entity_code,
           L.applied_from_trx_id,
           L.applied_from_line_id,
           L.applied_from_trx_level_type,
           L.applied_from_trx_number,
           L.adjusted_doc_application_id,
           L.adjusted_doc_entity_code,
           L.adjusted_doc_event_class_code,
           L.adjusted_doc_trx_id,
           L.adjusted_doc_line_id,
           L.adjusted_doc_trx_level_type,
           L.adjusted_doc_number,
           L.adjusted_doc_date,
           L.applied_to_application_id,
           L.applied_to_event_class_code,
           L.applied_to_entity_code,
           L.applied_to_trx_id,
           L.applied_to_line_id,
           L.applied_to_trx_number,
           L.summary_tax_line_id,
           L.offset_link_to_tax_line_id,
           L.offset_flag,
           DECODE(L.reporting_only_flag, 'N', 'Y', 'N'), -- L.process_for_recovery_flag,
           L.tax_jurisdiction_id,
           L.tax_jurisdiction_code,
           L.place_of_supply,
           L.place_of_supply_type_code,
           L.place_of_supply_result_id,
           L.tax_date_rule_id,
           L.tax_date,
           L.tax_determine_date,
           L.tax_point_date,
           L.trx_line_date,
           L.tax_type_code,
           L.tax_code,
           L.tax_registration_id,
           L.tax_registration_number,
           L.registration_party_type,
           L.rounding_level_code,
           L.rounding_rule_code,
           L.rounding_lvl_party_tax_prof_id,
           L.rounding_lvl_party_type,
           L.compounding_tax_flag,
           L.orig_tax_status_id,
           L.orig_tax_status_code,
           L.orig_tax_rate_id,
           L.orig_tax_rate_code,
           L.orig_tax_rate,
           L.orig_tax_jurisdiction_id,
           L.orig_tax_jurisdiction_code,
           L.orig_tax_amt_included_flag,
           L.orig_self_assessed_flag,
           L.tax_currency_code,
           0,                                    -- L.tax_amt,
           0,                                    -- L.tax_amt_tax_curr,
           0,                                    -- L.tax_amt_funcl_curr,
           taxable_amt,
           taxable_amt_tax_curr,
           L.taxable_amt_funcl_curr,
           L.orig_taxable_amt,
           L.orig_taxable_amt_tax_curr,
           L.cal_tax_amt,
           L.cal_tax_amt_tax_curr,
           L.cal_tax_amt_funcl_curr,
           L.orig_tax_amt,
           L.orig_tax_amt_tax_curr,
           L.rec_tax_amt,
           L.rec_tax_amt_tax_curr,
           L.rec_tax_amt_funcl_curr,
           L.nrec_tax_amt,
           L.nrec_tax_amt_tax_curr,
           L.nrec_tax_amt_funcl_curr,
           L.tax_exemption_id,
           L.tax_rate_before_exemption,
           L.tax_rate_name_before_exemption,
           L.exempt_rate_modifier,
           L.exempt_certificate_number,
           L.exempt_reason,
           L.exempt_reason_code,
           L.tax_exception_id,
           L.tax_rate_before_exception,
           L.tax_rate_name_before_exception,
           L.exception_rate,
           L.tax_apportionment_flag,
           L.historical_flag,
           L.taxable_basis_formula,
           L.tax_calculation_formula,
           'Y',                                  -- L.cancel_flag,
           L.purge_flag,
           L.delete_flag,
           L.tax_amt_included_flag,
           L.self_assessed_flag,
           L.overridden_flag,
           L.manually_entered_flag,
           L.freeze_until_overridden_flag,
           L.copied_from_other_doc_flag,
           L.recalc_required_flag,
           L.settlement_flag,
           L.item_dist_changed_flag,
           L.associated_child_frozen_flag,
           L.tax_only_line_flag,
           L.compounding_dep_tax_flag,
           L.last_manual_entry,
           L.tax_provider_id,
           L.record_type_code,
           L.reporting_period_id,
           L.legal_message_appl_2,
           L.legal_message_status,
           L.legal_message_rate,
           L.legal_message_basis,
           L.legal_message_calc,
           L.legal_message_threshold,
           L.legal_message_pos,
           L.legal_message_trn,
           L.legal_message_exmpt,
           L.legal_message_excpt,
           L.tax_regime_template_id,
           L.tax_applicability_result_id,
           L.direct_rate_result_id,
           L.status_result_id,
           L.rate_result_id,
           L.basis_result_id,
           L.thresh_result_id,
           L.calc_result_id,
           L.tax_reg_num_det_result_id,
           L.eval_exmpt_result_id,
           L.eval_excpt_result_id,
           L.enforce_from_natural_acct_flag,
           L.tax_hold_code,
           L.tax_hold_released_code,
           L.prd_total_tax_amt,
           L.prd_total_tax_amt_tax_curr,
           L.prd_total_tax_amt_funcl_curr,
           L.internal_org_location_id,
           L.attribute_category,
           L.attribute1,
           L.attribute2,
           L.attribute3,
           L.attribute4,
           L.attribute5,
           L.attribute6,
           L.attribute7,
           L.attribute8,
           L.attribute9,
           L.attribute10,
           L.attribute11,
           L.attribute12,
           L.attribute13,
           L.attribute14,
           L.attribute15,
           L.global_attribute_category,
           L.global_attribute1,
           L.global_attribute2,
           L.global_attribute3,
           L.global_attribute4,
           L.global_attribute5,
           L.global_attribute6,
           L.global_attribute7,
           L.global_attribute8,
           L.global_attribute9,
           L.global_attribute10,
           L.global_attribute11,
           L.global_attribute12,
           L.global_attribute13,
           L.global_attribute14,
           L.global_attribute15,
           L.numeric1,
           L.numeric2,
           L.numeric3,
           L.numeric4,
           L.numeric5,
           L.numeric6,
           L.numeric7,
           L.numeric8,
           L.numeric9,
           L.numeric10,
           L.char1,
           L.char2,
           L.char3,
           L.char4,
           L.char5,
           L.char6,
           L.char7,
           L.char8,
           L.char9,
           L.char10,
           L.date1,
           L.date2,
           L.date3,
           L.date4,
           L.date5,
           L.date6,
           L.date7,
           L.date8,
           L.date9,
           L.date10,
           L.tax_rate_type,
           L.created_by,
           L.creation_date,
           L.last_updated_by,
           L.last_update_date,
           L.last_update_login,
           L.line_assessable_value,
           L.legal_justification_text1,
           L.legal_justification_text2,
           L.legal_justification_text3,
           L.reporting_currency_code,
           L.trx_line_index,
           L.offset_tax_rate_code,
           L.proration_code,
           L.other_doc_source,
           L.reporting_only_flag,
           L.ctrl_total_line_tx_amt,
           L.sync_with_prvdr_flag,
           L.interface_entity_code,
           L.interface_tax_line_id,
           L.taxing_juris_geography_id,
           L.adjusted_doc_tax_line_id,
           1,
           decode(L.legal_reporting_status, '111111111111111',
                  '000000000000000', L.legal_reporting_status),
           L.account_source_tax_rate_id
    FROM  ZX_LINES L,
          zx_lines_det_factors G
    WHERE G.application_id = p_event_class_rec.application_id      AND
          G.entity_code = p_event_class_rec.entity_code            AND
          G.event_class_code = p_event_class_rec.event_class_code  AND
 --          G.trx_id = p_event_class_rec.trx_id                      AND
          G.event_id = p_event_class_rec.event_id                  AND
          L.trx_id = G.trx_id                                      AND
          L.trx_line_id = G.trx_line_id                            AND
          L.trx_level_type = G.trx_level_type                      AND
          L.event_class_code = G.event_class_code  AND
          -- L.event_type_code = G.event_type_code AND
          L.entity_code = G.entity_code            AND
          L.application_id = G.application_id      AND
          -- L.subscriber_id = G.subscriber_id     AND
          G.line_level_action =  'CANCEL'          AND
          L.tax_provider_id IS NULL

   );

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.process_cancel_trx_lines',
                   'p_return_status = ' || p_return_status);
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.process_cancel_trx_lines',
                   'p_error_buffer  = ' || p_error_buffer);
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.process_cancel_trx_lines.END',
                   'ZX_TDS_TAX_LINES_POPU_PKG: process_cancel_trx_lines(-)');
  END IF;

EXCEPTION
    WHEN OTHERS THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.process_cancel_trx_lines',
                        p_error_buffer);
      END IF;

END process_cancel_trx_lines;

-----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  process_tax_tolerance
--
--  DESCRIPTION
--  This procedure determines tax hold code and tax hold released code for
--  each tax line that tax amount tax currency has been overridden by
--  the users
--
--  CALLED BY
--   ZX_TDS_TAX_LINES_DETM_PKG

PROCEDURE process_tax_tolerance(
            p_event_class_rec     IN ZX_API_PUB.EVENT_CLASS_REC_TYPE,
            p_return_status      OUT NOCOPY VARCHAR2,
            p_error_buffer       OUT NOCOPY VARCHAR2)

IS
  l_tax_low_boundary           NUMBER;
  l_tax_high_boundary          NUMBER;
  l_count                      NUMBER;
  l_tax_id                     ZX_TAXES_B.TAX_ID%TYPE;
  l_tax_precision              ZX_TAXES_B.TAX_PRECISION%TYPE;
  l_tax_min_acct_unit          ZX_TAXES_B.MINIMUM_ACCOUNTABLE_UNIT%TYPE;
  l_tax_line_id_tbl            ZX_TDS_TAX_ROUNDING_PKG.TAX_ID_TBL;
  l_tax_amt_tax_curr_tbl       ZX_TDS_TAX_ROUNDING_PKG.TAX_AMT_TAX_CURR_TBL;
  l_tax_id_tbl                 ZX_TDS_TAX_ROUNDING_PKG.TAX_ID_TBL;
  l_rounding_rule_tbl          ZX_TDS_TAX_ROUNDING_PKG.ROUNDING_RULE_TBL;
  l_tax_hold_released_code_tbl TAX_HOLD_RELEASED_CODE_TBL;
  l_tax_hold_code_tbl          TAX_HOLD_CODE_TBL;
  l_orig_tax_amt_tax_curr_tbl  ORIG_TAX_AMT_TAX_CURR_TBL;

  CURSOR get_tax_tolerance_csr
  IS
  SELECT /*+ INDEX(ZX_DETAIL_TAX_LINES_GT ZX_DETAIL_TAX_LINES_GT_U1) */
         tax_line_id,
         orig_tax_amt_tax_curr,
         tax_amt_tax_curr,
         tax_id,
         tax_hold_released_code,
         Rounding_Rule_Code
    FROM  ZX_DETAIL_TAX_LINES_GT
    WHERE application_id      = p_event_class_rec.application_id
      AND entity_code         = p_event_class_rec.entity_code
      AND event_class_code    = p_event_class_rec.event_class_code
      AND trx_id              = p_event_class_rec.trx_id
      AND tax_event_type_code = 'OVERRIDE_TAX'
      AND offset_link_to_tax_line_id IS NULL
      AND orig_tax_amt_tax_curr IS NOT NULL
      AND mrc_tax_line_flag = 'N';

-- Start Bugfix: 5617541

  CURSOR get_tax_tol_ctrl_hdr_amt_csr
  IS
  SELECT /*+ INDEX(tax_line ZX_DETAIL_TAX_LINES_GT_U1) */
         tax_line.tax_line_id,
         tax_line.orig_tax_amt_tax_curr,
         tax_line.tax_amt_tax_curr,
         tax_line.tax_id,
         tax_line.tax_hold_released_code,
         tax_line.Rounding_Rule_Code
    FROM  ZX_DETAIL_TAX_LINES_GT tax_line,
       zx_lines_det_factors  trx_line
    WHERE tax_line.application_id      = p_event_class_rec.application_id
      AND tax_line.entity_code         = p_event_class_rec.entity_code
      AND tax_line.event_class_code    = p_event_class_rec.event_class_code
      AND tax_line.trx_id              = p_event_class_rec.trx_id
      AND tax_line.application_id      = trx_line.application_id
      AND tax_line.event_class_code    = trx_line.event_class_code
      AND tax_line.entity_code         = trx_line.entity_code
      AND tax_line.trx_id              = trx_line.trx_id
      AND tax_line.trx_line_id         = trx_line.trx_line_id
      AND tax_line.trx_level_type      = trx_line.trx_level_type
      AND trx_line.ctrl_total_hdr_tx_amt IS NOT NULL
      AND tax_line.offset_link_to_tax_line_id IS NULL
      AND tax_line.orig_tax_amt IS NOT NULL
      AND tax_line.mrc_tax_line_flag = 'N';

  CURSOR get_tax_tol_ctrl_line_amt_csr
  IS
  SELECT /*+ INDEX(ZX_DETAIL_TAX_LINES_GT ZX_DETAIL_TAX_LINES_GT_U1) */
         tax_line_id,
         orig_tax_amt_tax_curr,
         tax_amt_tax_curr,
         tax_id,
         tax_hold_released_code,
         Rounding_Rule_Code
    FROM  ZX_DETAIL_TAX_LINES_GT
    WHERE application_id      = p_event_class_rec.application_id
      AND entity_code         = p_event_class_rec.entity_code
      AND event_class_code    = p_event_class_rec.event_class_code
      AND trx_id              = p_event_class_rec.trx_id
      AND ctrl_total_line_tx_amt IS NOT NULL
      AND offset_link_to_tax_line_id IS NULL
      AND orig_tax_amt IS NOT NULL
      AND mrc_tax_line_flag = 'N';

-- End Bugfix: 5617541

  -- bug 5684123
  CURSOR get_tax_tolerance_upd_csr
  IS
  SELECT /*+ INDEX(gt ZX_DETAIL_TAX_LINES_GT_U1) */
          tax_line_id,
          orig_tax_amt_tax_curr,
          tax_amt_tax_curr,
          tax_id,
          tax_hold_released_code,
          Rounding_Rule_Code
    FROM  zx_detail_tax_lines_gt gt
    WHERE gt.application_id = p_event_class_rec.application_id
      AND gt.entity_code = p_event_class_rec.entity_code
      AND gt.event_class_code = p_event_class_rec.event_class_code
      AND (gt.tax_event_type_code = 'UPDATE' AND
            gt.last_manual_entry IS NOT NULL AND
            NVL(gt.manually_entered_flag, 'N') <> 'Y'
           )
      AND gt.offset_link_to_tax_line_id IS NULL
      AND gt.orig_tax_amt_tax_curr IS NOT NULL
      AND gt.mrc_tax_line_flag = 'N'
      AND EXISTS
          (SELECT 1
             FROM zx_lines_det_factors line
            WHERE line.application_id = p_event_class_rec.application_id
              AND line.entity_code = p_event_class_rec.entity_code
              AND line.event_class_code = p_event_class_rec.event_class_code
              AND line.event_id = p_event_class_rec.event_id
              AND line.trx_id = gt.trx_id
              AND line.trx_line_id = gt.trx_line_id
              AND line.trx_level_type = gt.trx_level_type

          );

  -- bug 6634198
  --
  CURSOR get_tax_tolerance_import_csr
  IS
  SELECT /*+ INDEX(gt ZX_DETAIL_TAX_LINES_GT_U1) */
          tax_line_id,
          orig_tax_amt_tax_curr,
          tax_amt_tax_curr,
          tax_id,
          tax_hold_released_code,
          Rounding_Rule_Code
    FROM  zx_detail_tax_lines_gt gt
    WHERE gt.application_id = p_event_class_rec.application_id
      AND gt.entity_code = p_event_class_rec.entity_code
      AND gt.event_class_code = p_event_class_rec.event_class_code
      AND (gt.tax_event_type_code = 'CREATE' AND
            gt.last_manual_entry = 'TAX_AMOUNT' AND
            NVL(gt.manually_entered_flag, 'N') = 'Y'
           )
      AND gt.offset_link_to_tax_line_id IS NULL
      AND gt.orig_tax_amt_tax_curr IS NOT NULL
      AND gt.mrc_tax_line_flag = 'N'
      AND EXISTS
          (SELECT 1
             FROM zx_transaction_lines_gt lines_gt
            WHERE lines_gt.application_id = p_event_class_rec.application_id
              AND lines_gt.entity_code = p_event_class_rec.entity_code
              AND lines_gt.event_class_code = p_event_class_rec.event_class_code
              AND lines_gt.trx_id = gt.trx_id
              AND lines_gt.trx_line_id = gt.trx_line_id
              AND lines_gt.trx_level_type = gt.trx_level_type
              AND lines_gt.line_level_action IN ('CREATE_WITH_TAX', 'LINE_INFO_TAX_ONLY')
          );

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.process_tax_tolerance.BEGIN',
                   'ZX_TDS_TAX_LINES_POPU_PKG: process_tax_tolerance(+)');
  END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

 -- Start Bugfix: 5617541
 -- bug 5684123
 IF p_event_class_rec.tax_event_type_code = 'OVERRIDE_TAX'
 THEN
   OPEN get_tax_tolerance_csr;
 ELSIF ZX_TDS_CALC_SERVICES_PUB_PKG.g_ctrl_total_line_tx_amt_flg = 'Y'
 THEN
   OPEN get_tax_tol_ctrl_line_amt_csr;
 ELSIF ZX_TDS_CALC_SERVICES_PUB_PKG.g_ctrl_total_hdr_tx_amt_flg = 'Y'
 THEN
   OPEN get_tax_tol_ctrl_hdr_amt_csr;
 ELSIF p_event_class_rec.tax_event_type_code = 'UPDATE'
 THEN
   OPEN get_tax_tolerance_upd_csr;
 ELSIF p_event_class_rec.tax_event_type_code = 'CREATE'
 THEN
   OPEN get_tax_tolerance_import_csr;
 END IF;

 LOOP
  IF p_event_class_rec.tax_event_type_code = 'OVERRIDE_TAX' THEN
    FETCH get_tax_tolerance_csr BULK COLLECT INTO
      l_tax_line_id_tbl,
      l_orig_tax_amt_tax_curr_tbl,
      l_tax_amt_tax_curr_tbl,
      l_tax_id_tbl,
      l_tax_hold_released_code_tbl,
      l_rounding_rule_tbl
    LIMIT C_LINES_PER_COMMIT;
  ELSE
      IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_ctrl_total_line_tx_amt_flg = 'Y' THEN
          FETCH get_tax_tol_ctrl_line_amt_csr BULK COLLECT INTO
            l_tax_line_id_tbl,
            l_orig_tax_amt_tax_curr_tbl,
            l_tax_amt_tax_curr_tbl,
            l_tax_id_tbl,
            l_tax_hold_released_code_tbl,
            l_rounding_rule_tbl
          LIMIT C_LINES_PER_COMMIT;
      ELSIF ZX_TDS_CALC_SERVICES_PUB_PKG.g_ctrl_total_hdr_tx_amt_flg = 'Y' THEN
          FETCH get_tax_tol_ctrl_hdr_amt_csr BULK COLLECT INTO
            l_tax_line_id_tbl,
            l_orig_tax_amt_tax_curr_tbl,
            l_tax_amt_tax_curr_tbl,
            l_tax_id_tbl,
            l_tax_hold_released_code_tbl,
            l_rounding_rule_tbl
          LIMIT C_LINES_PER_COMMIT;
      ELSIF p_event_class_rec.tax_event_type_code = 'UPDATE' THEN
        FETCH get_tax_tolerance_upd_csr BULK COLLECT INTO
          l_tax_line_id_tbl,
          l_orig_tax_amt_tax_curr_tbl,
          l_tax_amt_tax_curr_tbl,
          l_tax_id_tbl,
          l_tax_hold_released_code_tbl,
          l_rounding_rule_tbl
        LIMIT C_LINES_PER_COMMIT;
      ELSIF p_event_class_rec.tax_event_type_code = 'CREATE' THEN
        FETCH get_tax_tolerance_import_csr BULK COLLECT INTO
          l_tax_line_id_tbl,
          l_orig_tax_amt_tax_curr_tbl,
          l_tax_amt_tax_curr_tbl,
          l_tax_id_tbl,
          l_tax_hold_released_code_tbl,
          l_rounding_rule_tbl
        LIMIT C_LINES_PER_COMMIT;
      END IF;
  END IF;

  -- End Bugfix: 5617541


    l_count := l_orig_tax_amt_tax_curr_tbl.COUNT;

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.process_tax_tolerance',
                       'number of rows fetched = ' || to_char(l_count));
    END IF;

    IF l_count > 0 THEN

      FOR i IN 1.. l_count LOOP

        --
        -- determine tax hold code
        --
        l_tax_hold_code_tbl(i) := NULL;
        l_tax_id := l_tax_id_tbl(i);
        l_tax_precision := ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(l_tax_id).tax_precision;
        l_tax_min_acct_unit := ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl(l_tax_id).minimum_accountable_unit;

        --
        -- check tax tolerance
        --
        IF p_event_class_rec.tax_tolerance IS NOT NULL THEN
          l_tax_low_boundary:= ZX_TDS_TAX_ROUNDING_PKG.ROUND_TAX(
             (1 - p_event_class_rec.tax_tolerance / 100) * l_orig_tax_amt_tax_curr_tbl(i),
              l_rounding_rule_tbl(i),
              l_tax_min_acct_unit,
              l_tax_precision,
              p_return_status,
              p_error_buffer);

          IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            EXIT;
          END IF;

          l_tax_high_boundary:= ZX_TDS_TAX_ROUNDING_PKG.ROUND_TAX(
             (1 + p_event_class_rec.tax_tolerance / 100) * l_orig_tax_amt_tax_curr_tbl(i),
              l_rounding_rule_tbl(i),
              l_tax_min_acct_unit,
              l_tax_precision,
              p_return_status,
              p_error_buffer);
          IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            EXIT;
          END IF;

          IF (ABS(l_tax_amt_tax_curr_tbl(i)) < ABS(l_tax_low_boundary)  OR
              ABS(l_tax_amt_tax_curr_tbl(i)) > ABS(l_tax_high_boundary)) THEN
            l_tax_hold_code_tbl(i) := ZX_TDS_CALC_SERVICES_PUB_PKG.g_tax_variance_hold_val;
          END IF;

        END IF;

        --
        -- check tax tolerance amount range
        --
        -- bug fix 3495260
        IF p_event_class_rec.tax_tol_amt_range IS NOT NULL THEN
          IF ABS( l_tax_amt_tax_curr_tbl(i) -
                  l_orig_tax_amt_tax_curr_tbl(i)) >
             p_event_class_rec.tax_tol_amt_range THEN
            IF l_tax_hold_code_tbl(i)  IS NULL THEN
              l_tax_hold_code_tbl(i)  := ZX_TDS_CALC_SERVICES_PUB_PKG.g_tax_amt_range_hold_val;
            ELSE
              l_tax_hold_code_tbl(i)  := ZX_TDS_CALC_SERVICES_PUB_PKG.g_tax_variance_hold_val
                                       + ZX_TDS_CALC_SERVICES_PUB_PKG.g_tax_amt_range_hold_val;
            END IF;
          END IF; -- abs
        END IF;   --tax_tol_amt_range

        --
        -- determine tax hold released code
        --
        -- bug fix 3495260
        l_tax_hold_released_code_tbl(i) := BITAND( nvl(l_tax_hold_code_tbl(i), 0),
                                               nvl(l_tax_hold_released_code_tbl(i), 0) ) ;

      END LOOP;       -- end FOR LOOP

      IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        EXIT;
      END IF;

      --
      -- bulk update the current rows processed
      -- before fetch the next set of rows
      --
      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                       'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.process_tax_tolerance',
                       'update ZX_DETAIL_TAX_LINES_GT with tax hold info');
      END IF;

      FORALL  i IN 1 .. l_count
        UPDATE /*+ INDEX(ZX_DETAIL_TAX_LINES_GT ZX_DETAIL_TAX_LINES_GT_U2) */
              ZX_DETAIL_TAX_LINES_GT
          SET tax_hold_code = nvl(l_tax_hold_code_tbl(i), 0),
              tax_hold_released_code = nvl(l_tax_hold_released_code_tbl(i), 0)
          WHERE tax_line_id = l_tax_line_id_tbl(i);

    ELSE
      --
      -- no more records to process
      --
      -- Start Bugfix: 5617541
      IF p_event_class_rec.tax_event_type_code = 'OVERRIDE_TAX' THEN
        CLOSE get_tax_tolerance_csr;
      ELSIF ZX_TDS_CALC_SERVICES_PUB_PKG.g_ctrl_total_line_tx_amt_flg = 'Y' THEN
        CLOSE get_tax_tol_ctrl_line_amt_csr;
      ELSIF ZX_TDS_CALC_SERVICES_PUB_PKG.g_ctrl_total_hdr_tx_amt_flg = 'Y' THEN
        CLOSE get_tax_tol_ctrl_hdr_amt_csr;
      ELSIF p_event_class_rec.tax_event_type_code = 'UPDATE' THEN
        CLOSE get_tax_tolerance_upd_csr;
      ELSIF p_event_class_rec.tax_event_type_code = 'CREATE' THEN
        CLOSE get_tax_tolerance_import_csr;
        END IF;
      -- End Bugfix: 5617541
      EXIT;
    END IF;
  END LOOP;

  IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    -- Start Bugfix: 5617541
    IF p_event_class_rec.tax_event_type_code = 'OVERRIDE_TAX' THEN
      CLOSE get_tax_tolerance_csr;
    ELSIF ZX_TDS_CALC_SERVICES_PUB_PKG.g_ctrl_total_line_tx_amt_flg = 'Y' THEN
      CLOSE get_tax_tol_ctrl_line_amt_csr;
    ELSIF ZX_TDS_CALC_SERVICES_PUB_PKG.g_ctrl_total_hdr_tx_amt_flg = 'Y' THEN
      CLOSE get_tax_tol_ctrl_hdr_amt_csr;
    ELSIF p_event_class_rec.tax_event_type_code = 'UPDATE' THEN
      CLOSE get_tax_tolerance_upd_csr;
    ELSIF p_event_class_rec.tax_event_type_code = 'CREATE' THEN
      CLOSE get_tax_tolerance_import_csr;
    END IF;
    -- End Bugfix: 5617541
    RETURN;
  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.process_tax_tolerance',
                   'p_return_status = ' || p_return_status);
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.process_tax_tolerance',
                   'p_error_buffer  = ' || p_error_buffer);
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.process_tax_tolerance.END',
                   'ZX_TDS_TAX_LINES_POPU_PKG: process_tax_tolerance(-)');
  END IF;

EXCEPTION
    WHEN OTHERS THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.process_tax_tolerance',
                        p_error_buffer);
      END IF;

END process_tax_tolerance;

-----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  populate_recovery_flg
--
--  DESCRIPTION
--  This procedure populates Process_For_Recovery_Flag based on
--  tax_recovery_flag in event class record,  and
--  Reporting_Only_Flag of a tax line
--

PROCEDURE populate_recovery_flg(
            p_begin_index      IN     BINARY_INTEGER,
            p_end_index        IN     BINARY_INTEGER,
            p_event_class_rec  IN     ZX_API_PUB.EVENT_CLASS_REC_TYPE,
            p_return_status       OUT NOCOPY VARCHAR2,
            p_error_buffer        OUT NOCOPY VARCHAR2)

IS

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.populate_recovery_flg.BEGIN',
                   'ZX_TDS_TAX_LINES_POPU_PKG: populate_recovery_flg(+)');
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.populate_recovery_flg',
                   'begin_index = ' || to_char(p_begin_index) || ' end_index= '
                   || to_char(p_end_index));
  END IF;

  p_return_status  := FND_API.G_RET_STS_SUCCESS;

  --
  -- check if begin_index and end_index have values
  --
  IF (p_begin_index IS NULL OR p_end_index IS NULL) THEN

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.populate_recovery_flg',
                     'Begin index or End index is null' );
    END IF;

    RETURN;
  END IF;

  -- If the value of p_event_class_rec.tax_recovery_flag is 'N',
  -- populate process_for_recovery_flag to 'N'. If it is 'Y', check
  -- reporting_only_flag to set tax_recovery_flag
  --
  IF NVL(p_event_class_rec.tax_recovery_flag, 'N') = 'N' THEN
    FOR i IN p_begin_index ..p_end_index LOOP
      ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).process_for_recovery_flag := 'N';
    END LOOP;
  ELSE
    FOR i IN p_begin_index ..p_end_index LOOP
      IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).reporting_only_flag = 'Y' THEN  -- bugfix 5399549
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).process_for_recovery_flag := 'N';
      ELSE
        ZX_TDS_CALC_SERVICES_PUB_PKG.g_detail_tax_lines_tbl(i).process_for_recovery_flag := 'Y';
      END IF;

    END LOOP;
  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.populate_recovery_flg.END',
                   'ZX_TDS_TAX_LINES_POPU_PKG: populate_recovery_flg(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_TAX_LINES_POPU_PKG.populate_recovery_flg',
                      p_error_buffer);
    END IF;

END populate_recovery_flg;

END  ZX_TDS_TAX_LINES_POPU_PKG;

/
