--------------------------------------------------------
--  DDL for Package Body ZX_TDS_TAX_LINES_DETM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_TDS_TAX_LINES_DETM_PKG" as
/* $Header: zxditaxlndetpkgb.pls 120.91.12010000.10 2010/04/29 13:42:06 tsen ship $ */

-- private procedures
PROCEDURE create_offset_tax_lines(
                p_event_class_rec       IN     ZX_API_PUB.EVENT_CLASS_REC_TYPE,
                p_return_status            OUT NOCOPY  VARCHAR2,
                p_error_buffer             OUT NOCOPY  VARCHAR2 );

PROCEDURE populate_tax_line_numbers(
  -- p_event_class_rec  => p_event_class_rec,
  x_return_status      OUT NOCOPY  VARCHAR2,
  x_error_buffer       OUT NOCOPY  VARCHAR2
);

PROCEDURE process_reference_tax_lines(
  p_event_class_rec   IN          ZX_API_PUB.EVENT_CLASS_REC_TYPE,
  x_return_status     OUT NOCOPY  VARCHAR2,
  x_error_buffer      OUT NOCOPY  VARCHAR2
);

PROCEDURE process_copy_and_create (
  p_event_class_rec   IN          zx_api_pub.event_class_rec_type,
  x_return_status     OUT NOCOPY  VARCHAR2,
  x_error_buffer      OUT NOCOPY  VARCHAR2);

PROCEDURE adjust_overapplication(
  -- p_event_class_rec  => p_event_class_rec,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_error_buffer          OUT NOCOPY VARCHAR2);

PROCEDURE process_unchanged_trx_lines(
  p_event_class_rec   IN     ZX_API_PUB.EVENT_CLASS_REC_TYPE,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_error_buffer          OUT NOCOPY VARCHAR2);

PROCEDURE set_acct_source_tax_rate_id(
  p_event_class_rec   IN     ZX_API_PUB.EVENT_CLASS_REC_TYPE,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_error_buffer          OUT NOCOPY VARCHAR2);

g_current_runtime_level      NUMBER;
g_level_statement            CONSTANT  NUMBER   := FND_LOG.LEVEL_STATEMENT;
g_level_procedure            CONSTANT  NUMBER   := FND_LOG.LEVEL_PROCEDURE;
g_level_unexpected           CONSTANT  NUMBER   := FND_LOG.LEVEL_UNEXPECTED;

c_lines_per_fetch            CONSTANT  NUMBER   := 1000;
NUMBER_DUMMY                 CONSTANT NUMBER(15):= -999999999999999;
-----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  determine_tax_lines
--
--  DESCRIPTION
--  This procedure is the tail end wrap service for tax rounding, tax
--  columns population and offset tax lines determination

PROCEDURE determine_tax_lines(
           p_event_class_rec       IN     ZX_API_PUB.EVENT_CLASS_REC_TYPE,
           p_return_status         OUT NOCOPY VARCHAR2,
           p_error_buffer          OUT NOCOPY VARCHAR2
         )
IS

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.determine_tax_lines.BEGIN',
                   'ZX_TDS_TAX_LINES_DETM_PKG: determine_tax_lines(+)');
  END IF;

  --
  -- init error buffer and return status
  --
  p_return_status  := FND_API.G_RET_STS_SUCCESS;
  p_error_buffer   := NULL;

  -- Bug 3971006: copy manual tax line from source document for trx lines
  -- with line_level_action = 'COPY_AND_CREATE'
  --
  IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_process_copy_and_create_flg = 'Y'
  THEN

    process_copy_and_create(
               p_event_class_rec  => p_event_class_rec,
               x_return_status    => p_return_status,
               x_error_buffer     => p_error_buffer);

    IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF g_level_unexpected >= g_current_runtime_level THEN
        FND_LOG.STRING(g_level_unexpected,
               'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.tax_line_determination',
               'Incorrect return_status after calling process_copy_and_create()');
        FND_LOG.STRING(g_level_unexpected,
               'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.tax_line_determination',
               'RETURN_STATUS = ' || p_return_status);
        FND_LOG.STRING(g_level_unexpected,
               'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.tax_line_determination.END',
               'ZX_TDS_TAX_LINES_DETM_PKG.tax_line_determination(-)');
      END IF;
      RETURN;
    END IF;
  END IF;

  -- add call to local procedure process_reference_tax_lines()
  -- to process ref doc tax line for current trx.
  --
  IF ZX_TDS_CALC_SERVICES_PUB_PKG.g_reference_doc_exist_flg = 'Y' THEN
    process_reference_tax_lines(
                 p_event_class_rec	=> p_event_class_rec,
                 x_return_status	=> p_return_status,
                 x_error_buffer         => p_error_buffer);

    IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF g_level_unexpected >= g_current_runtime_level THEN
        FND_LOG.STRING(g_level_unexpected,
                 'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.tax_line_determination',
                 'Incorrect return_status after calling '||
                 'process_reference_tax_lines()');
        FND_LOG.STRING(g_level_unexpected,
                 'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.tax_line_determination',
                 'RETURN_STATUS = ' || p_return_status);
        FND_LOG.STRING(g_level_unexpected,
                 'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.tax_line_determination.END',
                 'ZX_TDS_TAX_LINES_DETM_PKG.tax_line_determination(-)');
      END IF;
      RETURN;
    END IF;
  END IF;

  -- Bug 4352593: comment out the call to MRC processing procedure
  --
  -- IF p_event_class_rec.enable_mrc_flag = 'Y' THEN
  --   -- Create detail tax lines in reporting currencies
  --   --
  --   ZX_TDS_MRC_PROCESSING_PKG.create_mrc_det_tax_lines(
  --              p_event_class_rec	=> p_event_class_rec,
  --              x_return_status	=> p_return_status);
  --
  --   IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
  --     IF g_level_unexpected >= g_current_runtime_level THEN
  --       FND_LOG.STRING(g_level_unexpected,
  --              'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.tax_line_determination',
  --              'Incorrect return_status after calling '||
  --              'ZX_TDS_MRC_PROCESSING_PKG.create_mrc_det_tax_lines()');
  --       FND_LOG.STRING(g_level_unexpected,
  --              'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.tax_line_determination',
  --              'RETURN_STATUS = ' || p_return_status);
  --       FND_LOG.STRING(g_level_unexpected,
  --              'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.tax_line_determination.END',
  --              'ZX_TDS_TAX_LINES_DETM_PKG.tax_line_determination(-)');
  --     END IF;
  --     RETURN;
  --   END IF;
  -- END IF;

  --
  -- perform_rounding for the whole document
  --
  ZX_TDS_TAX_ROUNDING_PKG.perform_rounding(
                      p_event_class_rec,
                      p_return_status,
                      p_error_buffer);

  IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RETURN;
  END IF;

  --
  -- Check and adjust overapplication for CM
  -- overapplication for adjustment taken care by AR before AR call eTax
  --
  -- Bug#7721270- we will not do over application for O2C
  -- let AR handles the over application
  --
  -- Bug#8502340 - we will handle overapplication for O2C
  -- also will ensure only completed documents are considered

  IF ZX_GLOBAL_STRUCTURES_PKG.g_credit_memo_exists_flg = 'Y' THEN
    -- bug fix 5417887, change populate tax_line_number to bulk process

    adjust_overapplication(
     -- p_event_class_rec  => p_event_class_rec,
     x_return_status    => p_return_status,
     x_error_buffer     => p_error_buffer);

    IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF g_level_unexpected >= g_current_runtime_level THEN
        FND_LOG.STRING(g_level_unexpected,
               'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.tax_line_determination',
               'Incorrect return_status after calling adjust_overapplication()');
        FND_LOG.STRING(g_level_unexpected,
               'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.tax_line_determination',
               'RETURN_STATUS = ' || p_return_status);
        FND_LOG.STRING(g_level_unexpected,
               'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.tax_line_determination.END',
               'ZX_TDS_TAX_LINES_DETM_PKG.tax_line_determination(-)');
      END IF;
      RETURN;
    END IF;
  END IF;

  --
  -- process tax tolerance for the whole document
  --
  IF p_event_class_rec.tax_event_type_code IN ('OVERRIDE_TAX' ,'UPDATE', 'CREATE') -- Bug 5684123
  THEN
    ZX_TDS_TAX_LINES_POPU_PKG.process_tax_tolerance(
                      p_event_class_rec,
                      p_return_status,
                      p_error_buffer);

    IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RETURN;
    END IF;
  END IF;

  -- Check the value of p_event_class_rec.allow_offset_tax_calc_flag to
  -- determine if it is necessary to create offset tax lines
  --
  IF p_event_class_rec.allow_offset_tax_calc_flag ='Y' THEN
    --
    -- now create offset tax lines
    --
    create_offset_tax_lines(
               p_event_class_rec,
               p_return_status,
               p_error_buffer);

    IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RETURN;
    END IF;
  END IF;

  -- set account_source_tax_rate_id
  --
  set_acct_source_tax_rate_id(
               p_event_class_rec,
               p_return_status,
               p_error_buffer);

  IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RETURN;
  END IF;

  --
  -- process cancel, provider generated and frozen
  -- tax lines  in zx_lines for update event,
  -- insert these tax lines into detail tax lines
  -- global temp table and mark them as cancel
  --

  --IF (p_event_class_rec.tax_event_type_code = 'UPDATE') THEN
     -- bug 3770874: call process_cancel_trx_lines conditionally

   --Bug 8736358
   IF (p_event_class_rec.tax_event_type_code = 'UPDATE' or NVL(ZX_TDS_CALC_SERVICES_PUB_PKG.g_ln_action_update_exist_flg, 'N') = 'Y')
   THEN

    IF NVL(ZX_TDS_CALC_SERVICES_PUB_PKG.g_ln_action_cancel_exist_flg, 'N') = 'Y'
    THEN

      -- process cancelled trx lines (line_level_action='CANCEL')

      ZX_TDS_TAX_LINES_POPU_PKG.process_cancel_trx_lines(
      		p_event_class_rec,
        	p_return_status,
        	p_error_buffer);

      IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RETURN;
      END IF;
    END IF;

    ZX_TDS_TAX_LINES_POPU_PKG.process_cancel_tax_lines(
        p_event_class_rec,
        p_return_status,
        p_error_buffer);

    IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RETURN;
    END IF;

    ZX_TDS_TAX_LINES_POPU_PKG.process_frozen_tax_lines(
        p_event_class_rec,
        p_return_status,
        p_error_buffer);

    IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RETURN;
    END IF;

    -- bug 3770874: call process_discard_tax_lines conditionally
    --
    IF NVL(ZX_TDS_CALC_SERVICES_PUB_PKG.g_ln_action_discard_exist_flg,'N') = 'Y'
    THEN
      --
      -- process discard tax lines
      --
      ZX_TDS_TAX_LINES_POPU_PKG.process_discard_tax_lines(
         p_event_class_rec,
         p_return_status,
         p_error_buffer);

      IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF g_level_unexpected >= g_current_runtime_level THEN
          FND_LOG.STRING(g_level_unexpected,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.tax_line_determination',
                   'Incorrect return_status after calling '||
                   'ZX_TDS_TAX_LINES_POPU_PKG.process_discard_tax_lines()');
          FND_LOG.STRING(g_level_unexpected,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.tax_line_determination',
                   'RETURN_STATUS = ' || p_return_status);
          FND_LOG.STRING(g_level_unexpected,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.tax_line_determination.END',
                   'ZX_TDS_TAX_LINES_DETM_PKG.tax_line_determination(-)');
        END IF;
        RETURN;
      END IF;

    END IF;
    --
    -- call TRL api here to handle 'SYNCHRONIZE' case
    --
  END IF;  -- p_event_class_rec.tax_event_type_code = 'UPDATE'

  -- bug fix 3391299, call populate tax_line_number() to populate the tax_line_number
  -- for all the tax_lines generated per trx_lines in current trx

  -- bug fix 5417887, change populate tax_line_number to bulk process

  IF NVL(p_event_class_rec.tax_event_type_code, 'X') <> 'OVERRIDE_TAX' THEN
  populate_tax_line_numbers(
    -- p_event_class_rec => p_event_class_rec,
    x_return_status   => p_return_status,
    x_error_buffer    => p_error_buffer
  );
  END IF;
  IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    IF g_level_unexpected >= g_current_runtime_level THEN
      FND_LOG.STRING(g_level_unexpected,
               'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.tax_line_determination',
               'Incorrect return_status after calling '||
               'populate_tax_line_numbers()');
      FND_LOG.STRING(g_level_unexpected,
               'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.tax_line_determination',
               'RETURN_STATUS = ' || p_return_status);
      FND_LOG.STRING(g_level_unexpected,
               'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.tax_line_determination.END',
               'ZX_TDS_TAX_LINES_DETM_PKG.tax_line_determination(-)');
    END IF;
    RETURN;
  END IF;

  -- for updte case of the quote calls, bring back the tax lines of the
  -- untouched trx lines whose item distributions are changed.

  -- bug fix 5417887
  --IF p_event_class_rec.tax_event_type_code = 'UPDATE'
  IF ZX_GLOBAL_STRUCTURES_PKG.g_update_event_process_flag = 'Y'
    AND p_event_class_rec.QUOTE_FLAG ='Y'
    AND ZX_TDS_CALC_SERVICES_PUB_PKG.g_ln_action_nochange_exist_flg = 'Y'
  THEN

    process_unchanged_trx_lines(
      p_event_class_rec,
      p_return_status,
      p_error_buffer);

    IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RETURN;
    END IF;

  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.determine_tax_lines.END',
                   'ZX_TDS_TAX_LINES_DETM_PKG: determine_tax_lines(-)'||p_return_status);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.determine_tax_lines',
                      p_error_buffer);
    END IF;

END determine_tax_lines;

-----------------------------------------------------------------------
--
--  PRIVATE  PROCEDURE
--  create_offset_tax_lines
--
--  DESCRIPTION
--  This procedure creates offset tax lines after rounding has been done
--
PROCEDURE create_offset_tax_lines(
                p_event_class_rec       IN     ZX_API_PUB.EVENT_CLASS_REC_TYPE,
                p_return_status            OUT NOCOPY  VARCHAR2,
                p_error_buffer             OUT NOCOPY  VARCHAR2 )
IS
  l_tax_line_rec                    ZX_DETAIL_TAX_LINES_GT%ROWTYPE;
  l_offset_tax_line_tbl             ZX_TDS_CALC_SERVICES_PUB_PKG.DETAIL_TAX_LINES_TBL_TYPE;
  i                                 BINARY_INTEGER;

  CURSOR get_tax_line_csr
  IS
    SELECT /*+ INDEX(ZX_DETAIL_TAX_LINES_GT ZX_DETAIL_TAX_LINES_GT_U1) */
       tax_line_id,
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
--       trx_sic_code,
--       fob_point,
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
       applied_from_trx_number,
       adjusted_doc_application_id,
       adjusted_doc_entity_code,
       adjusted_doc_event_class_code,
       adjusted_doc_trx_id,
       adjusted_doc_line_id,
       adjusted_doc_trx_level_type, -- bug 6776312
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
       reporting_only_flag,
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
       created_by,
       creation_date,
       last_updated_by,
       last_update_date,
       last_update_login,
       legal_justification_text1,
       legal_justification_text2,
       legal_justification_text3,
       reporting_currency_code,
       line_assessable_value,
       trx_line_index,
       offset_tax_rate_code,
       proration_code,
       other_doc_source,
       ctrl_total_line_tx_amt,
       tax_rate_type
   FROM ZX_DETAIL_TAX_LINES_GT gt1
  WHERE
     /* -- commented out for bug fix 5417887
        application_id   = p_event_class_rec.application_id
    AND entity_code      = p_event_class_rec.entity_code
    AND event_class_code = p_event_class_rec.event_class_code
    AND trx_id           = p_event_class_rec.trx_id
    AND */
    -- Offset_Flag      = 'Y'          -- 6634198
        offset_tax_rate_code IS NOT NULL
    AND tax_provider_id IS NULL
    AND offset_link_to_tax_line_id IS NULL
    AND NVL(tax_amt_included_flag, 'N') = 'N'
    AND NVL(self_assessed_flag, 'N') ='N'
    AND applied_from_trx_id IS NULL
    AND adjusted_doc_trx_id IS NULL
    AND NOT EXISTS
        (SELECT 1
           FROM zx_rates_b rates,
                zx_detail_tax_lines_gt gt2
          WHERE gt2.application_id   = gt1.application_id
            AND gt2.entity_code      = gt1.entity_code
            AND gt2.event_class_code = gt1.event_class_code
            AND gt2.trx_id           = gt1.trx_id
            AND gt2.trx_line_id      = gt1.trx_line_id
            AND gt2.trx_level_type   = gt1.trx_level_type
            AND gt2.tax_regime_code  = gt1.tax_regime_code
            AND rates.tax_rate_id    = gt1.tax_rate_id
            AND gt2.tax              = rates.offset_tax
         )
    AND NOT EXISTS
        (SELECT /*+ INDEX(zl ZX_LINES_U1) */
                1
           FROM zx_rates_b rates,
                zx_lines zl
          WHERE zl.application_id   = gt1.application_id
            AND zl.entity_code      = gt1.entity_code
            AND zl.event_class_code = gt1.event_class_code
            AND zl.trx_id           = gt1.trx_id
            AND zl.trx_line_id      = gt1.trx_line_id
            AND zl.trx_level_type   = gt1.trx_level_type
            AND zl.tax_regime_code  = gt1.tax_regime_code
            AND rates.tax_rate_id    = gt1.tax_rate_id
            AND zl.tax              = rates.offset_tax
            AND zl.cancel_flag      = 'Y'
            AND zl.tax_apportionment_line_number > 0
         )

ORDER BY trx_id, trx_line_id, Tax_line_id;

 CURSOR  get_tax_line_number_csr IS
   SELECT NVL(MAX(tax_line_number), 0) + 1
     FROM zx_lines
    WHERE application_id       = l_tax_line_rec.application_id
      AND event_class_code    = l_tax_line_rec.event_class_code
      AND entity_code         = l_tax_line_rec.entity_code
      AND trx_id              = l_tax_line_rec.trx_id
      AND trx_line_id         = l_tax_line_rec.trx_line_id
      AND trx_level_type      = l_tax_line_rec.trx_level_type;

   l_previous_trx_id NUMBER;
   l_previous_trx_line_id NUMBER;
   l_tax_line_number  NUMBER;

BEGIN

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.create_offset_tax_lines.BEGIN',
                   'ZX_TDS_TAX_LINES_DETM_PKG: create_offset_tax_lines(+)');
  END IF;

  p_return_status  := FND_API.G_RET_STS_SUCCESS;

  --
  -- init index to offset tax lines structure
  --
  i := 0;

  --
  -- process detail tax lines from global temp table line by line
  --
  OPEN get_tax_line_csr;
  LOOP
    FETCH get_tax_line_csr INTO
       l_tax_line_rec.tax_line_id,
       l_tax_line_rec.internal_organization_id,
       l_tax_line_rec.application_id,
       l_tax_line_rec.entity_code,
       l_tax_line_rec.event_class_code,
       l_tax_line_rec.event_type_code,
       l_tax_line_rec.trx_id,
       l_tax_line_rec.trx_line_id,
       l_tax_line_rec.trx_level_type,
       l_tax_line_rec.trx_line_number,
       l_tax_line_rec.doc_event_status,
       l_tax_line_rec.tax_event_class_code,
       l_tax_line_rec.tax_event_type_code,
       l_tax_line_rec.tax_line_number,
       l_tax_line_rec.content_owner_id,
       l_tax_line_rec.tax_regime_id,
       l_tax_line_rec.tax_regime_code,
       l_tax_line_rec.tax_id,
       l_tax_line_rec.tax,
       l_tax_line_rec.tax_status_id,
       l_tax_line_rec.tax_status_code,
       l_tax_line_rec.tax_rate_id,
       l_tax_line_rec.tax_rate_code,
       l_tax_line_rec.tax_rate,
       l_tax_line_rec.tax_apportionment_line_number,
       l_tax_line_rec.trx_id_level2,
       l_tax_line_rec.trx_id_level3,
       l_tax_line_rec.trx_id_level4,
       l_tax_line_rec.trx_id_level5,
       l_tax_line_rec.trx_id_level6,
       l_tax_line_rec.trx_user_key_level1,
       l_tax_line_rec.trx_user_key_level2,
       l_tax_line_rec.trx_user_key_level3,
       l_tax_line_rec.trx_user_key_level4,
       l_tax_line_rec.trx_user_key_level5,
       l_tax_line_rec.trx_user_key_level6,
       l_tax_line_rec.mrc_tax_line_flag,
       l_tax_line_rec.ledger_id,
       l_tax_line_rec.establishment_id,
       l_tax_line_rec.legal_entity_id,
       l_tax_line_rec.legal_entity_tax_reg_number,
       l_tax_line_rec.hq_estb_reg_number,
       l_tax_line_rec.hq_estb_party_tax_prof_id,
       l_tax_line_rec.currency_conversion_date,
       l_tax_line_rec.currency_conversion_type,
       l_tax_line_rec.currency_conversion_rate,
       l_tax_line_rec.tax_currency_conversion_date,
       l_tax_line_rec.tax_currency_conversion_type,
       l_tax_line_rec.tax_currency_conversion_rate,
       l_tax_line_rec.trx_currency_code,
       l_tax_line_rec.minimum_accountable_unit,
       l_tax_line_rec.precision,
       l_tax_line_rec.trx_number,
       l_tax_line_rec.trx_date,
--       l_tax_line_rec.trx_sic_code,
--       l_tax_line_rec.fob_point,
       l_tax_line_rec.unit_price,
       l_tax_line_rec.line_amt,
       l_tax_line_rec.trx_line_quantity,
       l_tax_line_rec.tax_base_modifier_rate,
       l_tax_line_rec.ref_doc_application_id,
       l_tax_line_rec.ref_doc_entity_code,
       l_tax_line_rec.ref_doc_event_class_code,
       l_tax_line_rec.ref_doc_trx_id,
       l_tax_line_rec.ref_doc_line_id,
       l_tax_line_rec.ref_doc_line_quantity,
       l_tax_line_rec.other_doc_line_amt,
       l_tax_line_rec.other_doc_line_tax_amt,
       l_tax_line_rec.other_doc_line_taxable_amt,
       l_tax_line_rec.unrounded_taxable_amt,
       l_tax_line_rec.unrounded_tax_amt,
       l_tax_line_rec.related_doc_application_id,
       l_tax_line_rec.related_doc_entity_code,
       l_tax_line_rec.related_doc_event_class_code,
       l_tax_line_rec.related_doc_trx_id,
       l_tax_line_rec.related_doc_number,
       l_tax_line_rec.related_doc_date,
       l_tax_line_rec.applied_from_application_id,
       l_tax_line_rec.applied_from_event_class_code,
       l_tax_line_rec.applied_from_entity_code,
       l_tax_line_rec.applied_from_trx_id,
       l_tax_line_rec.applied_from_line_id,
       l_tax_line_rec.applied_from_trx_number,
       l_tax_line_rec.adjusted_doc_application_id,
       l_tax_line_rec.adjusted_doc_entity_code,
       l_tax_line_rec.adjusted_doc_event_class_code,
       l_tax_line_rec.adjusted_doc_trx_id,
       l_tax_line_rec.adjusted_doc_line_id,
       l_tax_line_rec.adjusted_doc_trx_level_type, -- bug 6776312
       l_tax_line_rec.adjusted_doc_number,
       l_tax_line_rec.adjusted_doc_date,
       l_tax_line_rec.applied_to_application_id,
       l_tax_line_rec.applied_to_event_class_code,
       l_tax_line_rec.applied_to_entity_code,
       l_tax_line_rec.applied_to_trx_id,
       l_tax_line_rec.applied_to_line_id,
       l_tax_line_rec.applied_to_trx_number,
       l_tax_line_rec.summary_tax_line_id,
       l_tax_line_rec.offset_link_to_tax_line_id,
       l_tax_line_rec.offset_flag,
       l_tax_line_rec.process_for_recovery_flag,
       l_tax_line_rec.tax_jurisdiction_id,
       l_tax_line_rec.tax_jurisdiction_code,
       l_tax_line_rec.place_of_supply,
       l_tax_line_rec.place_of_supply_type_code,
       l_tax_line_rec.place_of_supply_result_id,
       l_tax_line_rec.tax_date_rule_id,
       l_tax_line_rec.tax_date,
       l_tax_line_rec.tax_determine_date,
       l_tax_line_rec.tax_point_date,
       l_tax_line_rec.trx_line_date,
       l_tax_line_rec.tax_type_code,
       l_tax_line_rec.tax_code,
       l_tax_line_rec.tax_registration_id,
       l_tax_line_rec.tax_registration_number,
       l_tax_line_rec.registration_party_type,
       l_tax_line_rec.rounding_level_code,
       l_tax_line_rec.rounding_rule_code,
       l_tax_line_rec.rounding_lvl_party_tax_prof_id,
       l_tax_line_rec.rounding_lvl_party_type,
       l_tax_line_rec.compounding_tax_flag,
       l_tax_line_rec.orig_tax_status_id,
       l_tax_line_rec.orig_tax_status_code,
       l_tax_line_rec.orig_tax_rate_id,
       l_tax_line_rec.orig_tax_rate_code,
       l_tax_line_rec.orig_tax_rate,
       l_tax_line_rec.orig_tax_jurisdiction_id,
       l_tax_line_rec.orig_tax_jurisdiction_code,
       l_tax_line_rec.orig_tax_amt_included_flag,
       l_tax_line_rec.orig_self_assessed_flag,
       l_tax_line_rec.tax_currency_code,
       l_tax_line_rec.tax_amt,
       l_tax_line_rec.tax_amt_tax_curr,
       l_tax_line_rec.tax_amt_funcl_curr,
       l_tax_line_rec.taxable_amt,
       l_tax_line_rec.taxable_amt_tax_curr,
       l_tax_line_rec.taxable_amt_funcl_curr,
       l_tax_line_rec.orig_taxable_amt,
       l_tax_line_rec.orig_taxable_amt_tax_curr,
       l_tax_line_rec.cal_tax_amt,
       l_tax_line_rec.cal_tax_amt_tax_curr,
       l_tax_line_rec.cal_tax_amt_funcl_curr,
       l_tax_line_rec.orig_tax_amt,
       l_tax_line_rec.orig_tax_amt_tax_curr,
       l_tax_line_rec.rec_tax_amt,
       l_tax_line_rec.rec_tax_amt_tax_curr,
       l_tax_line_rec.rec_tax_amt_funcl_curr,
       l_tax_line_rec.nrec_tax_amt,
       l_tax_line_rec.nrec_tax_amt_tax_curr,
       l_tax_line_rec.nrec_tax_amt_funcl_curr,
       l_tax_line_rec.tax_exemption_id,
       l_tax_line_rec.tax_rate_before_exemption,
       l_tax_line_rec.tax_rate_name_before_exemption,
       l_tax_line_rec.exempt_rate_modifier,
       l_tax_line_rec.exempt_certificate_number,
       l_tax_line_rec.exempt_reason,
       l_tax_line_rec.exempt_reason_code,
       l_tax_line_rec.tax_exception_id,
       l_tax_line_rec.tax_rate_before_exception,
       l_tax_line_rec.tax_rate_name_before_exception,
       l_tax_line_rec.exception_rate,
       l_tax_line_rec.tax_apportionment_flag,
       l_tax_line_rec.historical_flag,
       l_tax_line_rec.taxable_basis_formula,
       l_tax_line_rec.tax_calculation_formula,
       l_tax_line_rec.cancel_flag,
       l_tax_line_rec.purge_flag,
       l_tax_line_rec.delete_flag,
       l_tax_line_rec.tax_amt_included_flag,
       l_tax_line_rec.self_assessed_flag,
       l_tax_line_rec.overridden_flag,
       l_tax_line_rec.manually_entered_flag,
       l_tax_line_rec.reporting_only_flag,
       l_tax_line_rec.freeze_until_overridden_flag,
       l_tax_line_rec.copied_from_other_doc_flag,
       l_tax_line_rec.recalc_required_flag,
       l_tax_line_rec.settlement_flag,
       l_tax_line_rec.item_dist_changed_flag,
       l_tax_line_rec.associated_child_frozen_flag,
       l_tax_line_rec.tax_only_line_flag,
       l_tax_line_rec.compounding_dep_tax_flag,
       l_tax_line_rec.last_manual_entry,
       l_tax_line_rec.tax_provider_id,
       l_tax_line_rec.record_type_code,
       l_tax_line_rec.reporting_period_id,
       l_tax_line_rec.legal_message_appl_2,
       l_tax_line_rec.legal_message_status,
       l_tax_line_rec.legal_message_rate,
       l_tax_line_rec.legal_message_basis,
       l_tax_line_rec.legal_message_calc,
       l_tax_line_rec.legal_message_threshold,
       l_tax_line_rec.legal_message_pos,
       l_tax_line_rec.legal_message_trn,
       l_tax_line_rec.legal_message_exmpt,
       l_tax_line_rec.legal_message_excpt,
       l_tax_line_rec.tax_regime_template_id,
       l_tax_line_rec.tax_applicability_result_id,
       l_tax_line_rec.direct_rate_result_id,
       l_tax_line_rec.status_result_id,
       l_tax_line_rec.rate_result_id,
       l_tax_line_rec.basis_result_id,
       l_tax_line_rec.thresh_result_id,
       l_tax_line_rec.calc_result_id,
       l_tax_line_rec.tax_reg_num_det_result_id,
       l_tax_line_rec.eval_exmpt_result_id,
       l_tax_line_rec.eval_excpt_result_id,
       l_tax_line_rec.enforce_from_natural_acct_flag,
       l_tax_line_rec.tax_hold_code,
       l_tax_line_rec.tax_hold_released_code,
       l_tax_line_rec.prd_total_tax_amt,
       l_tax_line_rec.prd_total_tax_amt_tax_curr,
       l_tax_line_rec.prd_total_tax_amt_funcl_curr,
       l_tax_line_rec.internal_org_location_id,
       l_tax_line_rec.attribute_category,
       l_tax_line_rec.attribute1,
       l_tax_line_rec.attribute2,
       l_tax_line_rec.attribute3,
       l_tax_line_rec.attribute4,
       l_tax_line_rec.attribute5,
       l_tax_line_rec.attribute6,
       l_tax_line_rec.attribute7,
       l_tax_line_rec.attribute8,
       l_tax_line_rec.attribute9,
       l_tax_line_rec.attribute10,
       l_tax_line_rec.attribute11,
       l_tax_line_rec.attribute12,
       l_tax_line_rec.attribute13,
       l_tax_line_rec.attribute14,
       l_tax_line_rec.attribute15,
       l_tax_line_rec.global_attribute_category,
       l_tax_line_rec.global_attribute1,
       l_tax_line_rec.global_attribute2,
       l_tax_line_rec.global_attribute3,
       l_tax_line_rec.global_attribute4,
       l_tax_line_rec.global_attribute5,
       l_tax_line_rec.global_attribute6,
       l_tax_line_rec.global_attribute7,
       l_tax_line_rec.global_attribute8,
       l_tax_line_rec.global_attribute9,
       l_tax_line_rec.global_attribute10,
       l_tax_line_rec.global_attribute11,
       l_tax_line_rec.global_attribute12,
       l_tax_line_rec.global_attribute13,
       l_tax_line_rec.global_attribute14,
       l_tax_line_rec.global_attribute15,
       l_tax_line_rec.numeric1,
       l_tax_line_rec.numeric2,
       l_tax_line_rec.numeric3,
       l_tax_line_rec.numeric4,
       l_tax_line_rec.numeric5,
       l_tax_line_rec.numeric6,
       l_tax_line_rec.numeric7,
       l_tax_line_rec.numeric8,
       l_tax_line_rec.numeric9,
       l_tax_line_rec.numeric10,
       l_tax_line_rec.char1,
       l_tax_line_rec.char2,
       l_tax_line_rec.char3,
       l_tax_line_rec.char4,
       l_tax_line_rec.char5,
       l_tax_line_rec.char6,
       l_tax_line_rec.char7,
       l_tax_line_rec.char8,
       l_tax_line_rec.char9,
       l_tax_line_rec.char10,
       l_tax_line_rec.date1,
       l_tax_line_rec.date2,
       l_tax_line_rec.date3,
       l_tax_line_rec.date4,
       l_tax_line_rec.date5,
       l_tax_line_rec.date6,
       l_tax_line_rec.date7,
       l_tax_line_rec.date8,
       l_tax_line_rec.date9,
       l_tax_line_rec.date10,
       l_tax_line_rec.created_by,
       l_tax_line_rec.creation_date,
       l_tax_line_rec.last_updated_by,
       l_tax_line_rec.last_update_date,
       l_tax_line_rec.last_update_login,
       l_tax_line_rec.legal_justification_text1,
       l_tax_line_rec.legal_justification_text2,
       l_tax_line_rec.legal_justification_text3,
       l_tax_line_rec.reporting_currency_code,
       l_tax_line_rec.line_assessable_value,
       l_tax_line_rec.trx_line_index,
       l_tax_line_rec.offset_tax_rate_code,
       l_tax_line_rec.proration_code,
       l_tax_line_rec.other_doc_source,
       l_tax_line_rec.ctrl_total_line_tx_amt,
       l_tax_line_rec.tax_rate_type;

    IF get_tax_line_csr%FOUND THEN
      BEGIN --bug6509867
        UPDATE zx_detail_tax_lines_gt
	SET offset_flag = 'N'
	WHERE offset_flag = 'Y'
	AND tax_provider_id IS NULL
        AND offset_link_to_tax_line_id IS NULL
	AND tax_line_id = l_tax_line_rec.tax_line_id;
      EXCEPTION
        WHEN OTHERS THEN
	  NULL;
      END;

    IF NVL(l_tax_line_rec.tax_event_type_code, 'A') = 'OVERRIDE_TAX'
    THEN

      IF nvl(l_previous_trx_id,-99) <> l_tax_line_rec.trx_id or
         nvl(l_previous_trx_line_id,-999) <> l_tax_line_rec.trx_line_id
          THEN

         l_previous_trx_id := l_tax_line_rec.trx_id;
         l_previous_trx_line_id := l_tax_line_rec.trx_line_id;

         OPEN  get_tax_line_number_csr;
         FETCH get_tax_line_number_csr INTO l_tax_line_number;
         CLOSE get_tax_line_number_csr;

      ELSE

         l_tax_line_number := l_tax_line_number + 1;

      END IF;

    l_tax_line_rec.tax_line_number := l_tax_line_number;

    END IF;


      ZX_TDS_OFFSET_TAX_DETM_PKG.process_offset_tax(
                                 l_tax_line_rec,
                                 p_event_class_rec,
                                 p_return_status,
                                 p_error_buffer);

      IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        EXIT;
      ELSE
        i := i + 1;
        l_offset_tax_line_tbl(i) := l_tax_line_rec;
      END IF;
    ELSE
      --
      -- no more record to process
      --
      CLOSE get_tax_line_csr;
      EXIT;
    END IF;    -- end of get_tax_line_csr%FOUND
  END LOOP;

  IF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    CLOSE get_tax_line_csr;
    RETURN;
  END IF;

  --
  -- insert offset tax lines to gt from pl/sql structure,
  --
  IF i > 0 THEN
    ZX_TDS_CALC_SERVICES_PUB_PKG.dump_detail_tax_lines_into_gt(
      l_offset_tax_line_tbl,
      p_return_status);
  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.create_offset_tax_lines.END',
                   'ZX_TDS_TAX_LINES_DETM_PKG: create_offset_tax_lines(-)'||p_return_status);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    IF get_tax_line_csr%ISOPEN THEN
      CLOSE get_tax_line_csr;
    END IF;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.create_offset_tax_lines',
                      p_error_buffer);
    END IF;

END create_offset_tax_lines;

-----------------------------------------------------------------------
--
--  PRIVATE  PROCEDURE
--  populate_tax_line_numbers
--
--  DESCRIPTION
--  populate tax_line_number for all the tax_lines generated
--  per trx_lines in current trx
--
--  HISTORY
--  Ling Zhang  26-Jul-04     Created for bug fix 3391299
--  Ling Zhang  17-Aug-06     Rewritten for bug fix 5417887

PROCEDURE populate_tax_line_numbers(
  -- p_event_class_rec    IN          ZX_API_PUB.EVENT_CLASS_REC_TYPE,
  x_return_status      OUT NOCOPY  VARCHAR2,
  x_error_buffer       OUT NOCOPY  VARCHAR2
) IS

CURSOR get_tax_lines_csr IS
       SELECT /*+ INDEX(ZX_DETAIL_TAX_LINES_GT ZX_DETAIL_TAX_LINES_GT_U1) */
              application_id,
              event_class_code,
              entity_code,
              trx_id,
              trx_line_id,
              trx_level_type,
              tax_line_id,
              tax_regime_code,
              tax,
              tax_apportionment_line_number
         FROM zx_detail_tax_lines_gt
        WHERE mrc_tax_line_flag = 'N'
     ORDER BY application_id,
              event_class_code,
              entity_code,
              trx_id,
              trx_line_id,
              trx_level_type,
              tax_line_id asc NULLs LAST;

  l_old_application_id   NUMBER;
  l_old_event_class_code VARCHAR2(30);
  l_old_entity_code      VARCHAR2(30);
  l_old_trx_id           NUMBER;
  l_old_trx_line_id      NUMBER;
  l_old_trx_level_type   VARCHAR2(30);
  l_tax_line_number      NUMBER;

  TYPE num_tab_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE var_30_tab_type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

  l_application_id_tab          num_tab_type;
  l_event_class_code_tab        var_30_tab_type;
  l_entity_code_tab             var_30_tab_type;
  l_trx_id_tab                  num_tab_type;
  l_trx_line_id_tab             num_tab_type;
  l_trx_level_type_tab          var_30_tab_type;
  l_tax_line_id_tab             num_tab_type;
  l_tax_regime_code_tab         var_30_tab_type;
  l_tax_tab                     var_30_tab_type;
  l_tax_apprtnmt_line_num_tab   num_tab_type;
  l_tax_line_number_tab         num_tab_type;
BEGIN

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.populate_tax_line_numbers.BEGIN',
                   'ZX_TDS_TAX_LINES_DETM_PKG: populate_tax_line_numbers(+)');
  END IF;

  x_return_status  := FND_API.G_RET_STS_SUCCESS;

  l_old_application_id := -1;
  l_old_event_class_code := '@@@###$$$***';
  l_old_entity_code := '@@@###$$$***';
  l_old_trx_id := -1;
  l_old_trx_line_id := -1;
  l_old_trx_level_type := '@@@###$$$***';

  OPEN get_tax_lines_csr;
  LOOP
    FETCH get_tax_lines_csr BULK COLLECT INTO
      l_application_id_tab,
      l_event_class_code_tab,
      l_entity_code_tab,
      l_trx_id_tab,
      l_trx_line_id_tab,
      l_trx_level_type_tab,
      l_tax_line_id_tab,
      l_tax_regime_code_tab,
      l_tax_tab,
      l_tax_apprtnmt_line_num_tab
    LIMIT c_lines_per_fetch;

    FOR i in 1 .. l_trx_line_id_tab.COUNT LOOP

      IF l_old_application_id = l_application_id_tab(i) AND
         l_old_event_class_code = l_event_class_code_tab(i) AND
         l_old_entity_code = l_entity_code_tab(i) AND
         l_old_trx_id = l_trx_id_tab(i) AND
         l_old_trx_line_id = l_trx_line_id_tab(i) AND
         l_old_trx_level_type = l_trx_level_type_tab(i)
      THEN
        l_tax_line_number := l_tax_line_number + 1;
      ELSE
        -- when trx_line changes, reset the values
        l_old_application_id := l_application_id_tab(i);
        l_old_event_class_code := l_event_class_code_tab(i);
        l_old_entity_code := l_entity_code_tab(i);
        l_old_trx_id := l_trx_id_tab(i);
        l_old_trx_line_id := l_trx_line_id_tab(i);
        l_old_trx_level_type := l_trx_level_type_tab(i);
        l_tax_line_number := 1;
      END IF;

      l_tax_line_number_tab(i) := l_tax_line_number;

    END LOOP;

    FORALL i in 1 .. l_trx_line_id_tab.COUNT
      UPDATE /*+ INDEX(ZX_DETAIL_TAX_LINES_GT ZX_DETAIL_TAX_LINES_GT_U2) */
             zx_detail_tax_lines_gt
         SET tax_line_number = l_tax_line_number_tab(i)
       WHERE tax_line_id = l_tax_line_id_tab(i);

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.populate_tax_line_numbers',
                     'After update the tax line numbers to the non-mrc tax lines '||
                     'in the zx_detail_tax_lines_gt');
    END IF;

    --IF p_event_class_rec.enable_mrc_flag = 'Y' THEN
    --  FORALL i in 1 .. l_trx_line_id_tab.COUNT
    --    UPDATE /*+ INDEX(ZX_DETAIL_TAX_LINES_GT ZX_DETAIL_TAX_LINES_GT_U1) */
    --           zx_detail_tax_lines_gt
    --       SET tax_line_number = l_tax_line_number_tab(i)
    --     WHERE application_id    = l_application_id_tab(i)
    --       AND event_class_code  = l_event_class_code_tab(i)
    --       AND entity_code       = l_entity_code_tab(i)
    --       AND trx_id            = l_trx_id_tab(i)
    --       AND trx_line_id       = l_trx_line_id_tab(i)
    --       AND trx_level_type    = l_trx_level_type_tab(i)
    --       AND mrc_tax_line_flag = 'Y'
    --       AND tax_regime_code   = l_tax_regime_code_tab(i)
    --       AND tax               = l_tax_tab(i)
    --       AND tax_apportionment_line_number
    --           = l_tax_apprtnmt_line_num_tab(i);
    --
    --END IF;

    EXIT WHEN get_tax_lines_csr%NOTFOUND;
  END LOOP;
  CLOSE get_tax_lines_csr;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.populate_tax_line_numbers.END',
                   'ZX_TDS_TAX_LINES_DETM_PKG: populate_tax_line_numbers(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.populate_tax_line_numbers',
                      x_error_buffer);
    END IF;

END populate_tax_line_numbers;

-----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  process_reference_tax_lines
--
--  DESCRIPTION
--  This procedure brings all reference tax lines which found not
--  applicable into detail tax lines global temp table and reset
--  the unrounded amounts.
--
--  CALLED BY
--   ZX_TDS_TAX_LINES_DETM_PKG
--
--  HISTORY
--  Ling Zhang  Aug-06-2004     Created for bug fix 3391186
--

PROCEDURE process_reference_tax_lines(
            p_event_class_rec   IN     ZX_API_PUB.EVENT_CLASS_REC_TYPE,
            x_return_status         OUT NOCOPY VARCHAR2,
            x_error_buffer          OUT NOCOPY VARCHAR2)
IS
  l_user_id             NUMBER;
  l_login_id            NUMBER;
  l_tax_regime_rec      zx_global_structures_pkg.tax_regime_rec_type;
  l_tax_rec             ZX_TDS_UTILITIES_PKG.zx_tax_info_cache_rec;
  l_tax_status_rec      ZX_TDS_UTILITIES_PKG.zx_status_info_rec;
  l_tax_rate_rec        ZX_TDS_UTILITIES_PKG.zx_rate_info_rec_type;
  l_tax_jurisdiction_rec ZX_TDS_UTILITIES_PKG.zx_jur_info_cache_rec_type;

  TYPE date_tab_type IS TABLE OF DATE INDEX BY BINARY_INTEGER;
  TYPE num_tab_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE var_30_tab_type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
  TYPE var_1_tab_type IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;
  TYPE var_rate_code_tab_type IS TABLE OF zx_detail_tax_lines_gt.tax_rate_code%TYPE
    INDEX BY BINARY_INTEGER;

  l_tax_line_id_tab             num_tab_type;
  l_tax_regime_code_tab         var_30_tab_type;
  l_tax_jurisdiction_code_tab   var_30_tab_type;
  l_tax_rate_code_tab           var_rate_code_tab_type;
  l_tax_tab                     var_30_tab_type;
  l_tax_status_code_tab         var_30_tab_type;
  l_tax_regime_id_tab           num_tab_type;
  l_tax_rate_id_tab             num_tab_type;
  l_tax_id_tab                  num_tab_type;
  l_tax_jur_id_tab              num_tab_type;
  l_tax_status_id_tab           num_tab_type;
  l_tax_determine_date_tab          date_tab_type;

  l_other_doc_source_tab        var_30_tab_type;
  l_unrounded_tax_amt_tab       num_tab_type;
  l_unrounded_taxable_amt_tab   num_tab_type;
  l_manually_entered_flag_tab   var_1_tab_type;

  l_tax_class                   zx_rates_b.tax_class%TYPE;

  CURSOR get_tax_info_csr IS
  SELECT /*+ INDEX(ZX_DETAIL_TAX_LINES_GT ZX_DETAIL_TAX_LINES_GT_U1) */
         tax_line_id,
         tax_regime_code,
         tax_jurisdiction_code,
         tax,
         tax_status_code,
         tax_rate_code,
         tax_determine_date,
         other_doc_source,
         unrounded_tax_amt,
         unrounded_taxable_amt,
         manually_entered_flag,
         tax_regime_id,
         tax_id,
         tax_jurisdiction_id,
         tax_status_id,
         tax_rate_id
    FROM zx_detail_tax_lines_gt
   WHERE ref_doc_application_id IS NOT NULL
     AND tax_event_type_code <> 'OVERRIDE_TAX'
     AND freeze_until_overridden_flag = 'Y';

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.process_reference_tax_lines.BEGIN',
                   'ZX_TDS_TAX_LINES_DETM_PKG: process_reference_tax_lines(+)');
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Bug#5417753- determine tax_class value
  IF p_event_class_rec.prod_family_grp_code = 'O2C' THEN
    l_tax_class := 'OUTPUT';
  ELSIF p_event_class_rec.prod_family_grp_code = 'P2P' THEN
    l_tax_class := 'INPUT';
  END IF;

  -- update the flags and other_doc_source for the applicable reference tax lines
  --
  IF NVL(p_event_class_rec.enforce_tax_from_ref_doc_flag, 'N') <> 'Y'
  THEN
    UPDATE
           zx_detail_tax_lines_gt  LGT
       SET LGT.copied_from_other_doc_flag = 'Y',
           LGT.other_doc_source           = 'REFERENCE'
           /* -- comment out the update of the amt until the necessary
           -- usage of following column is clearly identified.
           (LGT.other_doc_line_amt, LGT.other_doc_line_tax_amt, LGT.other_doc_line_taxable_amt ) =
             (SELECT L.line_amt,
                     L.tax_amt,
                     L.taxable_amt
                FROM zx_lines L
               WHERE L.application_id   = LGT.ref_doc_application_id
                 AND L.event_class_code = LGT.ref_doc_event_class_code
                 AND L.entity_code      = LGT.ref_doc_entity_code
                 AND L.trx_id           = LGT.ref_doc_trx_id
                 AND L.trx_line_id      = LGT.ref_doc_line_id
                 AND L.trx_level_type   = LGT.ref_doc_trx_level_type
                 AND L.tax_regime_code  = LGT.tax_regime_code
                 AND L.tax              = LGT.tax
                 And L.tax_apportionment_line_number = LGT.tax_apportionment_line_number
                 AND L.cancel_flag <> 'Y'
                 AND L.mrc_tax_line_flag = 'N' ) */
     WHERE ref_doc_application_id IS NOT NULL
       AND tax_event_type_code <> 'OVERRIDE_TAX'
       AND NVL(historical_flag, 'N') <> 'Y'
       AND EXISTS (SELECT /*+ INDEX(L ZX_LINES_U1 ) */ 'X'
                     FROM zx_lines L
                    WHERE L.application_id   = LGT.ref_doc_application_id
                      AND L.event_class_code = LGT.ref_doc_event_class_code
                      AND L.entity_code      = LGT.ref_doc_entity_code
                      AND L.trx_id           = LGT.ref_doc_trx_id
                      AND L.trx_line_id      = LGT.ref_doc_line_id
                      AND L.trx_level_type   = LGT.ref_doc_trx_level_type
                      AND L.tax_regime_code  = LGT.tax_regime_code
                      AND L.tax              = LGT.tax
                      AND NVL(L.tax_apportionment_line_number, -999999) = NVL(LGT.tax_apportionment_line_number, -999999)
                      AND L.cancel_flag <> 'Y'
                      AND L.mrc_tax_line_flag = 'N');
  END IF;

  l_user_id := fnd_global.user_id;
  l_login_id := fnd_global.login_id;
  -- retrieve the non-applicable reference tax lines for current trx
  -- for system generated lines, set tax amt and taxable amt to zero;
  -- for manually entered tax lines, prorate the tax amt
  INSERT INTO zx_detail_tax_lines_gt
  (      tax_line_id,
         internal_organization_id,
         internal_org_location_id,
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
         --trx_id_level6,
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
         trx_currency_code,
         minimum_accountable_unit,
         precision,
         trx_number,
         trx_date,
         unit_price,
         line_amt,
         trx_line_quantity,
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
         process_for_recovery_flag,
         tax_jurisdiction_id,
         tax_jurisdiction_code,
         place_of_supply,
         place_of_supply_type_code,
         place_of_supply_result_id,
         offset_flag,
         tax_date,
         tax_determine_date,
         tax_point_date,
         trx_line_date,
         tax_type_code,
         tax_code,
         tax_registration_number,
         registration_party_type,
         rounding_level_code,
         rounding_rule_code,
         rounding_lvl_party_tax_prof_id,
         rounding_lvl_party_type,
         historical_flag,
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
         tax_applicability_result_id,
         direct_rate_result_id,
         sync_with_prvdr_flag,
         other_doc_source,
         reporting_only_flag,
         line_assessable_value,
         tax_reg_num_det_result_id,
         record_type_code,
         tax_currency_code,
--         numeric1,
--         numeric2,
--         numeric3,
--         numeric4,
--         numeric5,
--         numeric6,
--         numeric7,
--         numeric8,
--         numeric9,
--         numeric10,
--         char1,
--         char2,
--         char3,
--         char4,
--         char5,
--         char6,
--         char7,
--         char8,
--         char9,
--         char10,
--         date1,
--         date2,
--         date3,
--         date4,
--         date5,
--         date6,
--         date7,
--         date8,
--         date9,
--         date10,
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
         applied_from_trx_number,
         adjusted_doc_application_id,
         adjusted_doc_entity_code,
         adjusted_doc_event_class_code,
         adjusted_doc_trx_id,
         adjusted_doc_line_id,
         adjusted_doc_number,
         adjusted_doc_date,
         applied_to_application_id,
         applied_to_event_class_code,
         applied_to_entity_code,
         applied_to_trx_id,
         applied_to_line_id,
         applied_to_trx_number,
         exempt_certificate_number,
--         summary_tax_line_id,
         offset_link_to_tax_line_id,
         tax_currency_conversion_date,
         tax_currency_conversion_type,
         tax_currency_conversion_rate,
         tax_base_modifier_rate,
         tax_date_rule_id,
         tax_registration_id,
         compounding_tax_flag,
--         tax_amt,
--         tax_amt_tax_curr,
--         tax_amt_funcl_curr,
--         taxable_amt,
--         taxable_amt_tax_curr,
--         taxable_amt_funcl_curr,
--         cal_tax_amt,
--         cal_tax_amt_tax_curr,
--         cal_tax_amt_funcl_curr,
--         rec_tax_amt,
--         rec_tax_amt_tax_curr,
--         rec_tax_amt_funcl_curr,
--         nrec_tax_amt,
--         nrec_tax_amt_tax_curr,
--         nrec_tax_amt_funcl_curr,
         tax_exemption_id,
         tax_rate_before_exemption,
         tax_rate_name_before_exemption,
         exempt_rate_modifier,
         exempt_reason,
         exempt_reason_code,
         tax_exception_id,
         tax_rate_before_exception,
         tax_rate_name_before_exception,
         exception_rate,
         taxable_basis_formula,
         tax_calculation_formula,
         tax_apportionment_flag,
         cancel_flag,
         purge_flag,
         delete_flag,
         enforce_from_natural_acct_flag,
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
         status_result_id,
         rate_result_id,
         basis_result_id,
         thresh_result_id,
         calc_result_id,
         eval_exmpt_result_id,
         eval_excpt_result_id,
--         tax_hold_code,
--         tax_hold_released_code,
--         prd_total_tax_amt,
--         prd_total_tax_amt_tax_curr,
--         prd_total_tax_amt_funcl_curr,
         tax_rate_type,
         legal_justification_text1,
         legal_justification_text2,
         legal_justification_text3,
         reporting_currency_code,
--         trx_line_index,
--         offset_tax_rate_code,
--         proration_code,
         ctrl_total_line_tx_amt,
         created_by,
         creation_date,
         last_updated_by,
         last_update_date,
         last_update_login,
         interface_entity_code,
         interface_tax_line_id,
         taxing_juris_geography_id,
         adjusted_doc_tax_line_id,
		 --Start of Bug 7383041
		 legal_reporting_status,
         --End of Bug 7383041
         object_version_number
  )
 (SELECT
       zx_lines_s.NEXTVAL,                  -- tax_line_id,
       G.internal_organization_id,
       G.internal_org_location_id,
       G.application_id,
       G.entity_code,
       G.event_class_code,
       G.event_type_code,
       G.trx_id,
       G.trx_line_id,
       G.trx_level_type,
       G.trx_line_number,
       G.doc_event_status,
       G.tax_event_class_code,
       G.tax_event_type_code,
       NUMBER_DUMMY,                                   -- L.tax_line_number,
       G.first_pty_org_id,                     -- content_owner_id,
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
       G.trx_id_level2,
       G.trx_id_level3,
       G.trx_id_level4,
       G.trx_id_level5,
       --G.trx_id_level6,
       L.mrc_tax_line_flag,
       G.ledger_id,
       G.establishment_id,
       G.legal_entity_id,
       L.legal_entity_tax_reg_number,
       L.hq_estb_reg_number,
       G.hq_estb_party_tax_prof_id,
       G.currency_conversion_date,
       G.currency_conversion_type,
       G.currency_conversion_rate,
       G.trx_currency_code,
       G.minimum_accountable_unit,
       G.precision,
       G.trx_number,
       G.trx_date,
       G.unit_price,
       G.line_amt,                                    -- line_amt
       G.trx_line_quantity,
       G.ref_doc_application_id,
       G.ref_doc_entity_code,
       G.ref_doc_event_class_code,
       G.ref_doc_trx_id,
       G.ref_doc_line_id,
       G.ref_doc_line_quantity,
       L.line_amt,                           -- other_doc_line_amt
       L.tax_amt,                            -- other_doc_line_tax_amt
       L.taxable_amt,                        -- other_doc_line_taxable_amt
       DECODE(l.manually_entered_flag,
              'N', 0,
              DECODE(L.line_amt,
                      NULL, L.unrounded_taxable_amt,
                      0, L.unrounded_taxable_amt,
                      L.unrounded_taxable_amt * ( G.line_amt / L.line_amt )) ),  -- unrounded_taxable_amt,
       DECODE(l.manually_entered_flag,
              'N', 0,
              DECODE(L.line_amt,
                     NULL, L.unrounded_tax_amt,
                     0, L.unrounded_tax_amt,
                     L.unrounded_tax_amt * ( G.line_amt / L.line_amt )) ),       -- unrounded_tax_amt,
       DECODE(L.Reporting_Only_Flag, 'N', 'Y', 'N'),
       L.tax_jurisdiction_id,
       L.tax_jurisdiction_code,
       L.place_of_supply,
       L.place_of_supply_type_code,
       L.place_of_supply_result_id,
       L.offset_flag,
       NVL(G.related_doc_date, NVL(G.provnl_tax_determination_date,
           NVL(G.adjusted_doc_date, NVL(G.trx_line_date, G.trx_date)))),   --tax_date,
       NVL(G.related_doc_date, NVL(G.provnl_tax_determination_date,
           NVL(G.adjusted_doc_date, NVL(G.trx_line_date, G.trx_date)))),   --tax_determine_date,
       NVL(G.related_doc_date, NVL(G.provnl_tax_determination_date,
           NVL(G.adjusted_doc_date, NVL(G.trx_line_date, G.trx_date)))),   --tax_point_date,
       G.trx_line_date,
       L.tax_type_code,
       L.tax_code,
       L.tax_registration_number,
       L.registration_party_type,
       L.rounding_level_code,
       L.rounding_rule_code,
       L.rounding_lvl_party_tax_prof_id,
       L.rounding_lvl_party_type,
       G.historical_flag,
       L.tax_amt_included_flag,
       L.self_assessed_flag,
       'Y',                                   -- L.overridden_flag,
       'Y',                                   -- L.manually_entered_flag,
       'Y',                                   -- L.freeze_until_overridden_flag,
       'Y',                                   -- L.copied_from_other_doc_flag,
       L.recalc_required_flag,
       L.settlement_flag,
       L.item_dist_changed_flag,
       L.associated_child_frozen_flag,
       L.tax_only_line_flag,
       L.compounding_dep_tax_flag,
       'TAX_AMOUNT',                         -- L.last_manual_entry,
       L.tax_provider_id,
       L.tax_applicability_result_id,
       L.direct_rate_result_id,
       DECODE(L.tax_provider_id, NULL, L.sync_with_prvdr_flag, 'Y'),   -- sync_with_prvdr_flag
       'REFERENCE',                                                    -- L.other_doc_source
       L.reporting_only_flag,
       G.assessable_value,                                             -- line_assessable_value,
       L.tax_reg_num_det_result_id,
       --Start of Bug 7384041
       --L.record_type_code,
       'USER_DEFINED',
       --End of Bug 7384041
       L.tax_currency_code,
--       G.numeric1,
--       G.numeric2,
--       G.numeric3,
--       G.numeric4,
--       G.numeric5,
--       G.numeric6,
--       G.numeric7,
--       G.numeric8,
--       G.numeric9,
--       G.numeric10,
--       G.char1,
--       G.char2,
--       G.char3,
--       G.char4,
--       G.char5,
--       G.char6,
--       G.char7,
--       G.char8,
--       G.char9,
--       G.char10,
--       G.date1,
--       G.date2,
--       G.date3,
--       G.date4,
--       G.date5,
--       G.date6,
--       G.date7,
--       G.date8,
--       G.date9,
--       G.date10,
       G.related_doc_application_id,
       G.related_doc_entity_code,
       G.related_doc_event_class_code,
       G.related_doc_trx_id,
       G.related_doc_number,
       G.related_doc_date,
       G.applied_from_application_id,
       G.applied_from_event_class_code,
       G.applied_from_entity_code,
       G.applied_from_trx_id,
       G.applied_from_line_id,
       L.applied_from_trx_number,
       G.adjusted_doc_application_id,
       G.adjusted_doc_entity_code,
       G.adjusted_doc_event_class_code,
       G.adjusted_doc_trx_id,
       G.adjusted_doc_line_id,
       G.adjusted_doc_number,
       G.adjusted_doc_date,
       G.applied_to_application_id,
       G.applied_to_event_class_code,
       G.applied_to_entity_code,
       G.applied_to_trx_id,
       G.applied_to_trx_line_id,
       G.applied_to_trx_number,
       G.exempt_certificate_number,
--       NULL,                                    -- L.summary_tax_line_id,
       NULL,                                    -- L.offset_link_to_tax_line_id,
       L.tax_currency_conversion_date,
       L.tax_currency_conversion_type,
       L.tax_currency_conversion_rate,
       L.tax_base_modifier_rate,
       L.tax_date_rule_id,
       L.tax_registration_id,
       L.compounding_tax_flag,
--       NULL,                                    -- L.tax_amt,
--       NULL,                                    -- L.tax_amt_tax_curr,
--       NULL,                                    -- L.tax_amt_funcl_curr,
--       NULL,                                    -- L.taxable_amt,
--       NULL,                                    -- L.taxable_amt_tax_curr,
--       NULL,                                    -- L.taxable_amt_funcl_curr,
--       NULL,                                    -- L.cal_tax_amt,
--       NULL,                                    -- L.cal_tax_amt_tax_curr,
--       NULL,                                    -- L.cal_tax_amt_funcl_curr,
--       NULL,                                    -- L.rec_tax_amt,
--       NULL,                                    -- L.rec_tax_amt_tax_curr,
--       NULL,                                    -- L.rec_tax_amt_funcl_curr,
--       NULL,                                    -- L.nrec_tax_amt,
--       NULL,                                    -- L.nrec_tax_amt_tax_curr,
--       NULL,                                    -- L.nrec_tax_amt_funcl_curr,
       L.tax_exemption_id,
       L.tax_rate_before_exemption,
       L.tax_rate_name_before_exemption,
       L.exempt_rate_modifier,
       L.exempt_reason,
       L.exempt_reason_code,
       L.tax_exception_id,
       L.tax_rate_before_exception,
       L.tax_rate_name_before_exception,
       L.exception_rate,
       L.taxable_basis_formula,
       L.tax_calculation_formula,
       L.tax_apportionment_flag,
       L.cancel_flag,
       L.purge_flag,
       L.delete_flag,
       L.enforce_from_natural_acct_flag,
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
       L.status_result_id,
       L.rate_result_id,
       L.basis_result_id,
       L.thresh_result_id,
       L.calc_result_id,
       L.eval_exmpt_result_id,
       L.eval_excpt_result_id,
--       NULL, --L.tax_hold_code,
--       NULL, --L.tax_hold_released_code,
--       NULL,                                 -- L.prd_total_tax_amt,
--       NULL,                                 -- L.prd_total_tax_amt_tax_curr,
--       NULL,                                 -- L.prd_total_tax_amt_funcl_curr,
       L.tax_rate_type,
       L.legal_justification_text1,
       L.legal_justification_text2,
       L.legal_justification_text3,
       L.reporting_currency_code,
--       NULL,                                 -- L.trx_line_index
--       NULL,                                 -- L.offset_tax_rate_code
--       NULL,                                 -- L.proration_code
       G.ctrl_total_line_tx_amt,
       l_user_id,                                                           -- created_by,
       sysdate,                                                             -- creation_date,
       l_user_id,                                                           -- last_updated_by
       sysdate,                                                             -- last_update_date,
       l_login_id,
       L.interface_entity_code,
       L.interface_tax_line_id,
       L.taxing_juris_geography_id,
       L.adjusted_doc_tax_line_id,
	   --Start of Bug 7383041
	   (select legal_reporting_status_def_val
       from zx_taxes_b
       where tax_id = L.tax_id) legal_reporting_status,
       --End of Bug 7383041
       1
   FROM  zx_lines L,
         zx_lines_det_factors G
   WHERE G.event_id = p_event_class_rec.event_id
     AND G.ref_doc_application_id IS NOT NULL
     AND (G.tax_event_type_code NOT IN ('OVERRIDE_TAX', 'UPDATE')
           OR (G.tax_event_type_code ='UPDATE' AND
               G.line_level_action NOT IN ('NO_CHANGE', 'CANCEL', 'DISCARD')
              )
         )
     -- AND NVL(G.historical_flag,'N') <> 'Y'
     AND L.application_id = G.ref_doc_application_id
     AND L.event_class_code = G.ref_doc_event_class_code
     AND L.entity_code = G.ref_doc_entity_code
     AND L.trx_id = G.ref_doc_trx_id
     AND L.trx_line_id = G.ref_doc_line_id
     AND L.trx_level_type = G.ref_doc_trx_level_type
     AND L.cancel_flag <> 'Y'
     AND L.offset_link_to_tax_line_id IS NULL
     AND L.mrc_tax_line_flag = 'N'
     AND NOT EXISTS ( SELECT /*+ INDEX(T ZX_DETAIL_TAX_LINES_GT_U1) */
                              'X'
                        FROM  zx_detail_tax_lines_gt T
                        WHERE T.application_id = G.application_id
                          AND T.entity_code = G.entity_code
                          AND T.event_class_code = G.event_class_code
                          AND T.trx_id = G.trx_id
                          AND T.trx_line_id = G.trx_line_id
                          AND T.trx_level_type = G.trx_level_type
                          AND T.tax = L.tax
                          AND T.tax_regime_code = L.tax_regime_code
                        --AND NVL(T.tax_apportionment_line_number, -999999) =
                         --  NVL(L.tax_apportionment_line_number, -999999)
                      )
  );

  -- retrieve the self assessed and canceled reference tax lines for current trx
  -- for system generated lines, set tax amt and taxable amt to zero;
  -- for manually entered tax lines, prorate the tax amt
  INSERT INTO zx_detail_tax_lines_gt
  (      tax_line_id,
         internal_organization_id,
         internal_org_location_id,
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
         --trx_id_level6,
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
         trx_currency_code,
         minimum_accountable_unit,
         precision,
         trx_number,
         trx_date,
         unit_price,
         line_amt,
         trx_line_quantity,
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
         process_for_recovery_flag,
         tax_jurisdiction_id,
         tax_jurisdiction_code,
         place_of_supply,
         place_of_supply_type_code,
         place_of_supply_result_id,
         offset_flag,
         tax_date,
         tax_determine_date,
         tax_point_date,
         trx_line_date,
         tax_type_code,
         tax_code,
         tax_registration_number,
         registration_party_type,
         rounding_level_code,
         rounding_rule_code,
         rounding_lvl_party_tax_prof_id,
         rounding_lvl_party_type,
         historical_flag,
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
         tax_applicability_result_id,
         direct_rate_result_id,
         sync_with_prvdr_flag,
         other_doc_source,
         reporting_only_flag,
         line_assessable_value,
         tax_reg_num_det_result_id,
         record_type_code,
         tax_currency_code,
--         numeric1,
--         numeric2,
--         numeric3,
--         numeric4,
--         numeric5,
--         numeric6,
--         numeric7,
--         numeric8,
--         numeric9,
--         numeric10,
--         char1,
--         char2,
--         char3,
--         char4,
--         char5,
--         char6,
--         char7,
--         char8,
--         char9,
--         char10,
--         date1,
--         date2,
--         date3,
--         date4,
--         date5,
--         date6,
--         date7,
--         date8,
--         date9,
--         date10,
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
         applied_from_trx_number,
         adjusted_doc_application_id,
         adjusted_doc_entity_code,
         adjusted_doc_event_class_code,
         adjusted_doc_trx_id,
         adjusted_doc_line_id,
         adjusted_doc_number,
         adjusted_doc_date,
         applied_to_application_id,
         applied_to_event_class_code,
         applied_to_entity_code,
         applied_to_trx_id,
         applied_to_line_id,
         applied_to_trx_number,
         exempt_certificate_number,
--         summary_tax_line_id,
         offset_link_to_tax_line_id,
         tax_currency_conversion_date,
         tax_currency_conversion_type,
         tax_currency_conversion_rate,
         tax_base_modifier_rate,
         tax_date_rule_id,
         tax_registration_id,
         compounding_tax_flag,
--         tax_amt,
--         tax_amt_tax_curr,
--         tax_amt_funcl_curr,
--         taxable_amt,
--         taxable_amt_tax_curr,
--         taxable_amt_funcl_curr,
--         cal_tax_amt,
--         cal_tax_amt_tax_curr,
--         cal_tax_amt_funcl_curr,
--         rec_tax_amt,
--         rec_tax_amt_tax_curr,
--         rec_tax_amt_funcl_curr,
--         nrec_tax_amt,
--         nrec_tax_amt_tax_curr,
--         nrec_tax_amt_funcl_curr,
         tax_exemption_id,
         tax_rate_before_exemption,
         tax_rate_name_before_exemption,
         exempt_rate_modifier,
         exempt_reason,
         exempt_reason_code,
         tax_exception_id,
         tax_rate_before_exception,
         tax_rate_name_before_exception,
         exception_rate,
         taxable_basis_formula,
         tax_calculation_formula,
         tax_apportionment_flag,
         cancel_flag,
         purge_flag,
         delete_flag,
         enforce_from_natural_acct_flag,
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
         status_result_id,
         rate_result_id,
         basis_result_id,
         thresh_result_id,
         calc_result_id,
         eval_exmpt_result_id,
         eval_excpt_result_id,
--         tax_hold_code,
--         tax_hold_released_code,
--         prd_total_tax_amt,
--         prd_total_tax_amt_tax_curr,
--         prd_total_tax_amt_funcl_curr,
         tax_rate_type,
         legal_justification_text1,
         legal_justification_text2,
         legal_justification_text3,
         reporting_currency_code,
--         trx_line_index,
--         offset_tax_rate_code,
--         proration_code,
         ctrl_total_line_tx_amt,
         created_by,
         creation_date,
         last_updated_by,
         last_update_date,
         last_update_login,
         interface_entity_code,
         interface_tax_line_id,
         taxing_juris_geography_id,
         adjusted_doc_tax_line_id,
		 --Start of Bug 7383041
		 legal_reporting_status,
         --End of Bug 7383041
         object_version_number
  )
 (SELECT
       zx_lines_s.NEXTVAL,                  -- tax_line_id,
       G.internal_organization_id,
       G.internal_org_location_id,
       G.application_id,
       G.entity_code,
       G.event_class_code,
       G.event_type_code,
       G.trx_id,
       G.trx_line_id,
       G.trx_level_type,
       G.trx_line_number,
       G.doc_event_status,
       G.tax_event_class_code,
       G.tax_event_type_code,
       NUMBER_DUMMY,                           -- L.tax_line_number,
       G.first_pty_org_id,                     -- content_owner_id,
       L.tax_regime_id,
       L.tax_regime_code,
       L.tax_id,
       L.tax,
       L.tax_status_id,
       L.tax_status_code,
       L.tax_rate_id,
       L.tax_rate_code,
       L.tax_rate,
       NVL(((SELECT max(ABS(tax_apportionment_line_number))
                    FROM zx_detail_tax_lines_gt gt1
                   WHERE gt1.application_id = G.application_id
                     AND gt1.entity_code = G.entity_code
                     AND gt1.event_class_code = G.event_class_code
                     AND gt1.trx_id = G.trx_id
                     AND gt1.trx_line_id = G.trx_line_id
                     AND gt1.trx_level_type = G.trx_level_type
                     AND gt1.tax_regime_code = L.tax_regime_code
                     AND gt1.tax = L.tax
                  ) + L.tax_apportionment_line_number
           ), L.tax_apportionment_line_number),       -- tax_apportionment_line_number
       G.trx_id_level2,
       G.trx_id_level3,
       G.trx_id_level4,
       G.trx_id_level5,
       --G.trx_id_level6,
       L.mrc_tax_line_flag,
       G.ledger_id,
       G.establishment_id,
       G.legal_entity_id,
       L.legal_entity_tax_reg_number,
       L.hq_estb_reg_number,
       G.hq_estb_party_tax_prof_id,
       G.currency_conversion_date,
       G.currency_conversion_type,
       G.currency_conversion_rate,
       G.trx_currency_code,
       G.minimum_accountable_unit,
       G.precision,
       G.trx_number,
       G.trx_date,
       G.unit_price,
       G.line_amt,                                    -- line_amt
       G.trx_line_quantity,
       G.ref_doc_application_id,
       G.ref_doc_entity_code,
       G.ref_doc_event_class_code,
       G.ref_doc_trx_id,
       G.ref_doc_line_id,
       G.ref_doc_line_quantity,
       L.line_amt,                           -- other_doc_line_amt
       L.tax_amt,                            -- other_doc_line_tax_amt
       L.taxable_amt,                        -- other_doc_line_taxable_amt
       DECODE(l.manually_entered_flag,
              'N', 0,
              DECODE(L.line_amt,
                      NULL, L.unrounded_taxable_amt,
                      0, L.unrounded_taxable_amt,
                      L.unrounded_taxable_amt * ( G.line_amt / L.line_amt )) ),  -- unrounded_taxable_amt,
       DECODE(l.manually_entered_flag,
              'N', 0,
              DECODE(L.line_amt,
                     NULL, L.unrounded_tax_amt,
                     0, L.unrounded_tax_amt,
                     L.unrounded_tax_amt * ( G.line_amt / L.line_amt )) ),       -- unrounded_tax_amt,
       DECODE(L.Reporting_Only_Flag, 'N', 'Y', 'N'),
       L.tax_jurisdiction_id,
       L.tax_jurisdiction_code,
       L.place_of_supply,
       L.place_of_supply_type_code,
       L.place_of_supply_result_id,
       L.offset_flag,
       NVL(G.related_doc_date, NVL(G.provnl_tax_determination_date,
           NVL(G.adjusted_doc_date, NVL(G.trx_line_date, G.trx_date)))),   --tax_date,
       NVL(G.related_doc_date, NVL(G.provnl_tax_determination_date,
           NVL(G.adjusted_doc_date, NVL(G.trx_line_date, G.trx_date)))),   --tax_determine_date,
       NVL(G.related_doc_date, NVL(G.provnl_tax_determination_date,
           NVL(G.adjusted_doc_date, NVL(G.trx_line_date, G.trx_date)))),   --tax_point_date,
       G.trx_line_date,
       L.tax_type_code,
       L.tax_code,
       L.tax_registration_number,
       L.registration_party_type,
       L.rounding_level_code,
       L.rounding_rule_code,
       L.rounding_lvl_party_tax_prof_id,
       L.rounding_lvl_party_type,
       G.historical_flag,
       L.tax_amt_included_flag,
       L.self_assessed_flag,
       'Y',                                   -- L.overridden_flag,
       'N',                                   -- L.manually_entered_flag,
       'Y',                                   -- L.freeze_until_overridden_flag,
       'Y',                                   -- L.copied_from_other_doc_flag,
       L.recalc_required_flag,
       L.settlement_flag,
       L.item_dist_changed_flag,
       L.associated_child_frozen_flag,
       L.tax_only_line_flag,
       L.compounding_dep_tax_flag,
       'TAX_AMOUNT',                         -- L.last_manual_entry,
       L.tax_provider_id,
       L.tax_applicability_result_id,
       L.direct_rate_result_id,
       DECODE(L.tax_provider_id, NULL, L.sync_with_prvdr_flag, 'Y'),   -- sync_with_prvdr_flag
       'REFERENCE',                                                    -- L.other_doc_source
       L.reporting_only_flag,
       G.assessable_value,                                             -- line_assessable_value,
       L.tax_reg_num_det_result_id,
       --Start of Bug 7384041
       --L.record_type_code,
       'ETAX_CREATED',
       --End of Bug 7384041
       L.tax_currency_code,
--       G.numeric1,
--       G.numeric2,
--       G.numeric3,
--       G.numeric4,
--       G.numeric5,
--       G.numeric6,
--       G.numeric7,
--       G.numeric8,
--       G.numeric9,
--       G.numeric10,
--       G.char1,
--       G.char2,
--       G.char3,
--       G.char4,
--       G.char5,
--       G.char6,
--       G.char7,
--       G.char8,
--       G.char9,
--       G.char10,
--       G.date1,
--       G.date2,
--       G.date3,
--       G.date4,
--       G.date5,
--       G.date6,
--       G.date7,
--       G.date8,
--       G.date9,
--       G.date10,
       G.related_doc_application_id,
       G.related_doc_entity_code,
       G.related_doc_event_class_code,
       G.related_doc_trx_id,
       G.related_doc_number,
       G.related_doc_date,
       G.applied_from_application_id,
       G.applied_from_event_class_code,
       G.applied_from_entity_code,
       G.applied_from_trx_id,
       G.applied_from_line_id,
       L.applied_from_trx_number,
       G.adjusted_doc_application_id,
       G.adjusted_doc_entity_code,
       G.adjusted_doc_event_class_code,
       G.adjusted_doc_trx_id,
       G.adjusted_doc_line_id,
       G.adjusted_doc_number,
       G.adjusted_doc_date,
       G.applied_to_application_id,
       G.applied_to_event_class_code,
       G.applied_to_entity_code,
       G.applied_to_trx_id,
       G.applied_to_trx_line_id,
       G.applied_to_trx_number,
       G.exempt_certificate_number,
       -- NULL,                                  -- L.summary_tax_line_id,
       NULL,                                    -- L.offset_link_to_tax_line_id,
       L.tax_currency_conversion_date,
       L.tax_currency_conversion_type,
       L.tax_currency_conversion_rate,
       L.tax_base_modifier_rate,
       L.tax_date_rule_id,
       L.tax_registration_id,
       L.compounding_tax_flag,
--       NULL,                                    -- L.tax_amt,
--       NULL,                                    -- L.tax_amt_tax_curr,
--       NULL,                                    -- L.tax_amt_funcl_curr,
--       NULL,                                    -- L.taxable_amt,
--       NULL,                                    -- L.taxable_amt_tax_curr,
--       NULL,                                    -- L.taxable_amt_funcl_curr,
--       NULL,                                    -- L.cal_tax_amt,
--       NULL,                                    -- L.cal_tax_amt_tax_curr,
--       NULL,                                    -- L.cal_tax_amt_funcl_curr,
--       NULL,                                    -- L.rec_tax_amt,
--       NULL,                                    -- L.rec_tax_amt_tax_curr,
--       NULL,                                    -- L.rec_tax_amt_funcl_curr,
--       NULL,                                    -- L.nrec_tax_amt,
--       NULL,                                    -- L.nrec_tax_amt_tax_curr,
--       NULL,                                    -- L.nrec_tax_amt_funcl_curr,
       L.tax_exemption_id,
       L.tax_rate_before_exemption,
       L.tax_rate_name_before_exemption,
       L.exempt_rate_modifier,
       L.exempt_reason,
       L.exempt_reason_code,
       L.tax_exception_id,
       L.tax_rate_before_exception,
       L.tax_rate_name_before_exception,
       L.exception_rate,
       L.taxable_basis_formula,
       L.tax_calculation_formula,
       L.tax_apportionment_flag,
       L.cancel_flag,
       L.purge_flag,
       L.delete_flag,
       L.enforce_from_natural_acct_flag,
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
       L.status_result_id,
       L.rate_result_id,
       L.basis_result_id,
       L.thresh_result_id,
       L.calc_result_id,
       L.eval_exmpt_result_id,
       L.eval_excpt_result_id,
--       NULL, --L.tax_hold_code,
--       NULL, --L.tax_hold_released_code,
--       NULL,                                 -- L.prd_total_tax_amt,
--       NULL,                                 -- L.prd_total_tax_amt_tax_curr,
--       NULL,                                 -- L.prd_total_tax_amt_funcl_curr,
       L.tax_rate_type,
       L.legal_justification_text1,
       L.legal_justification_text2,
       L.legal_justification_text3,
       L.reporting_currency_code,
--       NULL,                                 -- L.trx_line_index
--       NULL,                                 -- L.offset_tax_rate_code
--       NULL,                                 -- L.proration_code
       G.ctrl_total_line_tx_amt,
       l_user_id,                                                           -- created_by,
       sysdate,                                                             -- creation_date,
       l_user_id,                                                           -- last_updated_by
       sysdate,                                                             -- last_update_date,
       l_login_id,
       L.interface_entity_code,
       L.interface_tax_line_id,
       L.taxing_juris_geography_id,
       L.adjusted_doc_tax_line_id,
	   --Start of Bug 7383041
	   (select legal_reporting_status_def_val
       from zx_taxes_b
       where tax_id = L.tax_id) legal_reporting_status,
       --End of Bug 7383041
       1
   FROM  zx_lines L,
         zx_lines_det_factors G
   WHERE G.event_id = p_event_class_rec.event_id
     AND G.ref_doc_application_id IS NOT NULL
     AND (G.tax_event_type_code NOT IN ('OVERRIDE_TAX', 'UPDATE')
           OR (G.tax_event_type_code ='UPDATE' AND
               G.line_level_action NOT IN ('NO_CHANGE', 'CANCEL', 'DISCARD')
              )
         )
     -- AND NVL(G.historical_flag,'N') <> 'Y'
     AND L.application_id = G.ref_doc_application_id
     AND L.event_class_code = G.ref_doc_event_class_code
     AND L.entity_code = G.ref_doc_entity_code
     AND L.trx_id = G.ref_doc_trx_id
     AND L.trx_line_id = G.ref_doc_line_id
     AND L.trx_level_type = G.ref_doc_trx_level_type
     AND L.cancel_flag <> 'Y'
     AND L.offset_link_to_tax_line_id IS NULL
     AND L.mrc_tax_line_flag = 'N'
     AND NOT EXISTS ( SELECT /*+ INDEX(T ZX_DETAIL_TAX_LINES_GT_U1) */
                              'X'
                        FROM  zx_detail_tax_lines_gt T
                        WHERE T.application_id = G.application_id
                          AND T.entity_code = G.entity_code
                          AND T.event_class_code = G.event_class_code
                          AND T.trx_id = G.trx_id
                          AND T.trx_line_id = G.trx_line_id
                          AND T.trx_level_type = G.trx_level_type
                          AND T.tax = L.tax
                          AND T.tax_regime_code = L.tax_regime_code
                          AND NVL(T.self_assessed_flag, 'N') = 'N'
                          AND NVL(T.cancel_flag, 'N') = 'N'
                        --AND NVL(T.tax_apportionment_line_number, -999999) =
                         --  NVL(L.tax_apportionment_line_number, -999999)
                      )
  );

  OPEN get_tax_info_csr;
  LOOP

    FETCH get_tax_info_csr BULK COLLECT INTO
      l_tax_line_id_tab,
      l_tax_regime_code_tab,
      l_tax_jurisdiction_code_tab,
      l_tax_tab,
      l_tax_status_code_tab,
      l_tax_rate_code_tab,
      l_tax_determine_date_tab,
      l_other_doc_source_tab,
      l_unrounded_tax_amt_tab,
      l_unrounded_taxable_amt_tab,
      l_manually_entered_flag_tab,
      l_tax_regime_id_tab,
      l_tax_id_tab,
      l_tax_jur_id_tab,
      l_tax_status_id_tab,
      l_tax_rate_id_tab
    LIMIT c_lines_per_fetch;

    FOR i in 1 .. l_tax_line_id_tab.count LOOP

      -- bug 7008562: Per Harsh and Desh, do not do validation for PO taxes
      --              that are not applicable in current AP invoice
      --
      IF l_other_doc_source_tab(i)='REFERENCE' AND l_unrounded_tax_amt_tab(i)=0 AND
         l_unrounded_taxable_amt_tab(i)=0 AND l_manually_entered_flag_tab(i)='Y'
      THEN

        NULL;

      ELSE
        -- validate and populate tax_regime_id
        --
        ZX_TDS_UTILITIES_PKG.get_regime_cache_info(
      			l_tax_regime_code_tab(i),
      			l_tax_determine_date_tab(i),
      			l_tax_regime_rec,
      			x_return_status,
      			x_error_buffer);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
          IF (g_level_unexpected >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_unexpected,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.process_reference_tax_lines',
                   'Incorrect return_status after calling ' ||
                   'ZX_TDS_UTILITIES_PKG.get_regime_cache_info');
            FND_LOG.STRING(g_level_unexpected,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.process_reference_tax_lines',
                   'RETURN_STATUS = ' || x_return_status);
            FND_LOG.STRING(g_level_unexpected,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.process_reference_tax_lines.END',
                   'ZX_TDS_TAX_LINES_DETM_PKG.process_reference_tax_lines(-)');
          END IF;
          RETURN;
        END IF;

        l_tax_regime_id_tab(i) := l_tax_regime_rec.tax_regime_id;

        -- validate and populate tax_id
        --
        ZX_TDS_UTILITIES_PKG.get_tax_cache_info(
      			l_tax_regime_code_tab(i),
                          l_tax_tab(i),
      			l_tax_determine_date_tab(i),
      			l_tax_rec,
      			x_return_status,
      			x_error_buffer);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
          IF (g_level_unexpected >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_unexpected,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.process_reference_tax_lines',
                   'Incorrect return_status after calling ' ||
                   'ZX_TDS_UTILITIES_PKG.get_tax_cache_info');
            FND_LOG.STRING(g_level_unexpected,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.process_reference_tax_lines',
                   'RETURN_STATUS = ' || x_return_status);
            FND_LOG.STRING(g_level_unexpected,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.process_reference_tax_lines.END',
                   'ZX_TDS_TAX_LINES_DETM_PKG.process_reference_tax_lines(-)');
          END IF;
          RETURN;
        END IF;

        l_tax_id_tab(i) := l_tax_rec.tax_id;

        IF l_tax_jurisdiction_code_tab(i) IS NOT NULL THEN
          ZX_TDS_UTILITIES_PKG.get_jurisdiction_cache_info(
        			l_tax_regime_code_tab(i),
                          l_tax_tab(i),
                          l_tax_jurisdiction_code_tab(i),
        			l_tax_determine_date_tab(i),
        			l_tax_jurisdiction_rec,
        			x_return_status,
        			x_error_buffer);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
            IF (g_level_unexpected >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.process_reference_tax_lines',
                     'Incorrect return_status after calling ' ||
                     'ZX_TDS_UTILITIES_PKG.get_jurisdiction_cache_info');
              FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.process_reference_tax_lines',
                     'RETURN_STATUS = ' || x_return_status);
              FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.process_reference_tax_lines.END',
                     'ZX_TDS_TAX_LINES_DETM_PKG.process_reference_tax_lines(-)');
            END IF;
            RETURN;
          END IF;

          l_tax_jur_id_tab(i) := l_tax_jurisdiction_rec.tax_jurisdiction_id;
        ELSE

          l_tax_jur_id_tab(i) := NULL;
        END IF;

        ZX_TDS_UTILITIES_PKG.get_tax_status_cache_info(
                          l_tax_tab(i),
      			l_tax_regime_code_tab(i),
                          l_tax_status_code_tab(i),
      			l_tax_determine_date_tab(i),
      			l_tax_status_rec,
      			x_return_status,
      			x_error_buffer);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
          IF (g_level_unexpected >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_unexpected,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.process_reference_tax_lines',
                   'Incorrect return_status after calling ' ||
                   'ZX_TDS_UTILITIES_PKG.get_tax_status_cache_info');
            FND_LOG.STRING(g_level_unexpected,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.process_reference_tax_lines',
                   'RETURN_STATUS = ' || x_return_status);
            FND_LOG.STRING(g_level_unexpected,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.process_reference_tax_lines.END',
                   'ZX_TDS_TAX_LINES_DETM_PKG.process_reference_tax_lines(-)');
          END IF;
          RETURN;
        END IF;

        l_tax_status_id_tab(i) := l_tax_status_rec.tax_status_id;

        -- validate and populate tax_rate_id
        --
        ZX_TDS_UTILITIES_PKG.get_tax_rate_info(
      			l_tax_regime_code_tab(i),
                          l_tax_tab(i),
                          l_tax_jurisdiction_code_tab(i),
                          l_tax_status_code_tab(i),
                          l_tax_rate_code_tab(i),
      			l_tax_determine_date_tab(i),
                          l_tax_class,
      			l_tax_rate_rec,
      			x_return_status,
      			x_error_buffer);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
          IF (g_level_unexpected >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_unexpected,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.process_reference_tax_lines',
                   'Incorrect return_status after calling ' ||
                   'ZX_TDS_UTILITIES_PKG.get_tax_rate_info');
            FND_LOG.STRING(g_level_unexpected,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.process_reference_tax_lines',
                   'RETURN_STATUS = ' || x_return_status);
            FND_LOG.STRING(g_level_unexpected,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.process_reference_tax_lines.END',
                   'ZX_TDS_TAX_LINES_DETM_PKG.process_reference_tax_lines(-)');
          END IF;
          RETURN;
        END IF;

        l_tax_rate_id_tab(i) := l_tax_rate_rec.tax_rate_id;

      END IF;  -- bug 7008562
    END LOOP;

    FORALL i in 1 .. l_tax_line_id_tab.COUNT
      UPDATE /*+ INDEX(ZX_DETAIL_TAX_LINES_GT ZX_DETAIL_TAX_LINES_GT_U2) */
             zx_detail_tax_lines_gt
         SET tax_regime_id = l_tax_regime_id_tab(i),
             tax_id        = l_tax_id_tab(i),
             tax_jurisdiction_id = l_tax_jur_id_tab(i),
             tax_status_id = l_tax_status_id_tab(i),
             tax_rate_id   = l_tax_rate_id_tab(i)
       WHERE tax_line_id   = l_tax_line_id_tab(i);

    EXIT WHEN get_tax_info_csr%NOTFOUND;
  END LOOP;
  CLOSE get_tax_info_csr;

  IF (g_level_procedure >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.process_reference_tax_lines.END',
                   'ZX_TDS_TAX_LINES_DETM_PKG: process_reference_tax_lines(-)'||x_return_status);
  END IF;

EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.process_reference_tax_lines',
                        x_error_buffer);
      END IF;

END process_reference_tax_lines;

-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  process_copy_and_create
--
--  DESCRIPTION
--  This procedure copies all manual tax lines that do not exist
--  in the system-generated tax lines for the trx lines
--  with line_level_action = 'COPY_ANY_CREATE'
--
--  HISTORY
--  Hongjun Liu  Dec-18-2004     Created for Bug Fix 3971006
--  Ling  Zhang  Aug-08-2005     Bug Fix 4542315
--

PROCEDURE process_copy_and_create(
            p_event_class_rec   IN     ZX_API_PUB.EVENT_CLASS_REC_TYPE,
            x_return_status         OUT NOCOPY VARCHAR2,
            x_error_buffer          OUT NOCOPY VARCHAR2) IS

 l_user_id             NUMBER;
 l_login_id            NUMBER;
 l_tax_regime_rec      zx_global_structures_pkg.tax_regime_rec_type;
 l_tax_rec             ZX_TDS_UTILITIES_PKG.zx_tax_info_cache_rec;
 l_tax_status_rec      ZX_TDS_UTILITIES_PKG.zx_status_info_rec;
 l_tax_rate_rec        ZX_TDS_UTILITIES_PKG.zx_rate_info_rec_type;
 l_tax_jurisdiction_rec ZX_TDS_UTILITIES_PKG.zx_jur_info_cache_rec_type;

 l_tax_class          ZX_RATES_B.tax_class%TYPE;

 TYPE date_tab_type IS TABLE OF DATE INDEX BY BINARY_INTEGER;
 TYPE num_tab_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
 TYPE var_30_tab_type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
 TYPE var_rate_code_tab_type IS TABLE OF zx_detail_tax_lines_gt.tax_rate_code%TYPE
   INDEX BY BINARY_INTEGER;

 l_tax_line_id_tab             num_tab_type;
 --jur bug
 l_tax_jur_id_tab              num_tab_type;
 l_tax_regime_code_tab         var_30_tab_type;
 l_tax_rate_code_tab           var_rate_code_tab_type;
 l_tax_tab                     var_30_tab_type;
 l_tax_status_code_tab         var_30_tab_type;
 l_tax_jurisdiction_code_tab   var_30_tab_type;
 l_tax_regime_id_tab           num_tab_type;
 l_tax_rate_id_tab             num_tab_type;
 l_tax_id_tab                  num_tab_type;
 l_tax_status_id_tab           num_tab_type;
 l_tax_determine_date_tab      date_tab_type;

 CURSOR get_tax_info_csr IS
 SELECT /*+ ORDERED INDEX(ZX_DETAIL_TAX_LINES_GT ZX_DETAIL_TAX_LINES_GT_U1) */
        T.tax_line_id,
        T.tax_regime_code,
        T.tax_jurisdiction_code,
        T.tax,
        T.tax_status_code,
        T.tax_rate_code,
        T.tax_determine_date
   FROM zx_detail_tax_lines_gt T,
        zx_lines_det_factors G
  WHERE
    -- commented out for bug fix 5417887
    --    G.application_id = p_event_class_rec.application_id
    --AND G.event_class_code = p_event_class_rec.event_class_code
    --AND G.entity_code = p_event_class_rec.entity_code
    --AND G.trx_id = p_event_class_rec.trx_id
    --AND G.event_id = p_event_class_rec.event_id
    --AND
    G.line_level_action = 'COPY_AND_CREATE'
    AND T.application_id = G.application_id
    AND T.event_class_code = G.event_class_code
    AND T.entity_code = G.entity_code
    AND T.trx_id = G.trx_id
    AND T.trx_line_id = G.trx_line_id
    AND T.trx_level_type = G.trx_level_type
    AND T.manually_entered_flag = 'Y'
    AND T.tax_provider_id IS NULL;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
           'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.process_copy_and_create.BEGIN',
           'ZX_TDS_TAX_LINES_DETM_PKG: process_copy_and_create(+)');
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;


  l_user_id := fnd_global.user_id;
  l_login_id := fnd_global.login_id;

  -- Bug#5417753- determine tax_class value
  -- bug 5417887 - assume all trx in the batch carry the same product family group code

  IF p_event_class_rec.prod_family_grp_code = 'O2C' THEN
    l_tax_class := 'OUTPUT';
  ELSIF p_event_class_rec.prod_family_grp_code = 'P2P' THEN
    l_tax_class := 'INPUT';
  END IF;

  -- Copy the non-applicable manual tax lines from source
  -- documnet.
  --

MERGE INTO zx_detail_tax_lines_gt  tax_line
  USING(
    SELECT /*+ index(L ZX_LINES_U1) */   -- Added the hint as part of 6596182
	   G.internal_organization_id,
           G.internal_org_location_id,
           G.application_id,
           G.entity_code,
           G.event_class_code,
           G.event_type_code,
           G.trx_id,
           G.trx_line_id,
           G.trx_level_type,
           G.trx_line_number,
           G.doc_event_status,
           G.tax_event_class_code,
           G.tax_event_type_code,
           G.first_pty_org_id                  content_owner_id,
           --L.tax_regime_id,
           L.tax_regime_code,
           --L.tax_id,
           L.tax,
           --L.tax_status_id,
           L.tax_status_code,
           --L.tax_rate_id,
           L.tax_rate_code,
           L.tax_rate,
           L.tax_apportionment_line_number,
           G.trx_id_level2,
           G.trx_id_level3,
           G.trx_id_level4,
           G.trx_id_level5,
           -- G.trx_id_level6,
           L.mrc_tax_line_flag,
           G.ledger_id,
           G.establishment_id,
           G.legal_entity_id,
           L.legal_entity_tax_reg_number,
           L.hq_estb_reg_number,
           G.hq_estb_party_tax_prof_id,
           G.currency_conversion_date,
           G.currency_conversion_type,
           G.currency_conversion_rate,
           G.trx_currency_code,
           G.minimum_accountable_unit,
           G.precision,
           G.trx_number,
           G.trx_date,
           G.unit_price,
           G.line_amt                                      line_amt,
           G.trx_line_quantity,
           G.ref_doc_application_id,
           G.ref_doc_entity_code,
           G.ref_doc_event_class_code,
           G.ref_doc_trx_id,
           G.ref_doc_line_id,
           G.ref_doc_line_quantity,
           L.line_amt                                      other_doc_line_amt,
           L.tax_amt                                       other_doc_line_tax_amt,
           L.taxable_amt                                   other_doc_line_taxable_amt,
           L.unrounded_taxable_amt,
           L.unrounded_tax_amt,
           DECODE(L.reporting_only_flag,
                  'N', 'Y', 'N')                           process_for_recovery_flag,
           L.tax_jurisdiction_id,
           L.tax_jurisdiction_code,
           L.place_of_supply,
           L.place_of_supply_type_code,
           L.place_of_supply_result_id,
           L.offset_flag,
           NVL(G.related_doc_date,
             NVL(G.provnl_tax_determination_date,
               NVL(G.adjusted_doc_date,
                 NVL(G.trx_line_date, G.trx_date))))       tax_date,
           NVL(G.related_doc_date,
             NVL(G.provnl_tax_determination_date,
               NVL(G.adjusted_doc_date,
               NVL(G.trx_line_date, G.trx_date))))         tax_determine_date,
           NVL(G.related_doc_date,
             NVL(G.provnl_tax_determination_date,
               NVL(G.adjusted_doc_date,
               NVL(G.trx_line_date, G.trx_date))))         tax_point_date,
           G.trx_line_date,
           L.tax_type_code,
           L.tax_code,
           L.tax_registration_number,
           L.registration_party_type,
           L.rounding_level_code,
           L.rounding_rule_code,
           L.rounding_lvl_party_tax_prof_id,
           L.rounding_lvl_party_type,
           G.historical_flag,
           L.tax_amt_included_flag,
           L.self_assessed_flag,
           L.overridden_flag,
           L.manually_entered_flag,
           L.recalc_required_flag,
           L.settlement_flag,
           L.item_dist_changed_flag,
           L.associated_child_frozen_flag,
           L.tax_only_line_flag,
           L.compounding_dep_tax_flag,
           L.tax_provider_id,
           L.tax_applicability_result_id,
           L.direct_rate_result_id,
           DECODE(L.tax_provider_id,
             NULL, L.sync_with_prvdr_flag, 'Y')            sync_with_prvdr_flag,
           L.reporting_only_flag,
           G.assessable_value                             line_assessable_value,
           L.tax_reg_num_det_result_id,
           L.record_type_code,
           L.tax_currency_code,
           G.numeric1,
           G.numeric2,
           G.numeric3,
           G.numeric4,
           G.numeric5,
           G.numeric6,
           G.numeric7,
           G.numeric8,
           G.numeric9,
           G.numeric10,
           G.char1,
           G.char2,
           G.char3,
           G.char4,
           G.char5,
           G.char6,
           G.char7,
           G.char8,
           G.char9,
           G.char10,
           G.date1,
           G.date2,
           G.date3,
           G.date4,
           G.date5,
           G.date6,
           G.date7,
           G.date8,
           G.date9,
           G.date10,
           G.related_doc_application_id,
           G.related_doc_entity_code,
           G.related_doc_event_class_code,
           G.related_doc_trx_id,
           G.related_doc_number,
           G.related_doc_date,
           G.applied_from_application_id,
           G.applied_from_event_class_code,
           G.applied_from_entity_code,
           G.applied_from_trx_id,
           G.applied_from_line_id,
           L.applied_from_trx_number,
           G.adjusted_doc_application_id,
           G.adjusted_doc_entity_code,
           G.adjusted_doc_event_class_code,
           G.adjusted_doc_trx_id,
           G.adjusted_doc_line_id,
           G.adjusted_doc_number,
           G.adjusted_doc_date,
           G.applied_to_application_id,
           G.applied_to_event_class_code,
           G.applied_to_entity_code,
           G.applied_to_trx_id,
           G.applied_to_trx_line_id,
           G.applied_to_trx_number,
           G.exempt_certificate_number,
           L.tax_currency_conversion_date,
           L.tax_currency_conversion_type,
           L.tax_currency_conversion_rate,
           L.tax_base_modifier_rate,
           L.tax_date_rule_id,
           L.tax_registration_id,
           L.compounding_tax_flag,
           L.tax_exemption_id,
           L.tax_rate_before_exemption,
           L.tax_rate_name_before_exemption,
           L.exempt_rate_modifier,
           L.exempt_reason,
           L.exempt_reason_code,
           L.tax_exception_id,
           L.tax_rate_before_exception,
           L.tax_rate_name_before_exception,
           L.exception_rate,
           L.taxable_basis_formula,
           L.tax_calculation_formula,
           L.tax_apportionment_flag,
           L.cancel_flag,
           L.purge_flag,
           L.delete_flag,
           L.enforce_from_natural_acct_flag,
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
           L.status_result_id,
           L.rate_result_id,
           L.basis_result_id,
           L.thresh_result_id,
           L.calc_result_id,
           L.eval_exmpt_result_id,
           L.eval_excpt_result_id,
           L.tax_rate_type,
           L.legal_justification_text1,
           L.legal_justification_text2,
           L.legal_justification_text3,
           L.reporting_currency_code,
           G.ctrl_total_line_tx_amt,
           L.interface_entity_code,
           L.interface_tax_line_id,
           L.taxing_juris_geography_id,
           L.adjusted_doc_tax_line_id,
           L.cal_tax_amt,
           L.cal_tax_amt_tax_curr,
           L.cal_tax_amt_funcl_curr
     FROM  zx_lines L,
           zx_lines_det_factors G
     WHERE
       -- commented out for bug fix 5417887
       --    G.application_id = p_event_class_rec.application_id
       --AND G.event_class_code = p_event_class_rec.event_class_code
       --AND G.entity_code = p_event_class_rec.entity_code
       --AND G.trx_id = p_event_class_rec.trx_id

           G.event_id = p_event_class_rec.event_id
       AND G.line_level_action = 'COPY_AND_CREATE'
       AND L.application_id = G.source_application_id
       AND L.event_class_code = G.source_event_class_code
       AND L.entity_code = G.source_entity_code
       AND L.trx_id = G.source_trx_id
       AND L.trx_line_id = G.source_line_id
       AND L.trx_level_type = G.source_trx_level_type
       AND L.cancel_flag <> 'Y'
       AND L.offset_link_to_tax_line_id IS NULL
       AND L.mrc_tax_line_flag = 'N'
       AND (  L.manually_entered_flag = 'Y'
           OR L.last_manual_entry is NOT NULL )
       AND L.tax_provider_id IS NULL
    ) temp
  ON(   tax_line.application_id    = temp.application_id
    AND tax_line.entity_code       = temp.entity_code
    AND tax_line.event_class_code  = temp.event_class_code
    AND tax_line.trx_id            = temp.trx_id
    AND tax_line.trx_line_id       = temp.trx_line_id
    AND tax_line.tax_regime_code   = temp.tax_regime_code
    AND tax_line.tax               = temp.tax
    AND NVL(tax_line.tax_apportionment_line_number, 1) =
        NVL(temp.tax_apportionment_line_number, 1)  )
WHEN MATCHED THEN
  UPDATE SET
    -- tax_line_id                    =  zx_lines_s.NEXTVAL,
    internal_organization_id          =  temp.internal_organization_id,
    internal_org_location_id          =  temp.internal_org_location_id,
--    application_id                    =  temp.application_id,
--    entity_code                       =  temp.entity_code,
--    event_class_code                  =  temp.event_class_code,
    event_type_code                   =  temp.event_type_code,
--    trx_id                            =  temp.trx_id,
--    trx_line_id                       =  temp.trx_line_id,
    trx_level_type                    =  temp.trx_level_type,
    trx_line_number                   =  temp.trx_line_number,
    doc_event_status                  =  temp.doc_event_status,
    tax_event_class_code              =  temp.tax_event_class_code,
    tax_event_type_code               =  temp.tax_event_type_code,
    tax_line_number                   =   NUMBER_DUMMY,
    content_owner_id                  =  temp.content_owner_id,
    --tax_regime_id                   =  --temp.tax_regime_id,
--    tax_regime_code                   =  temp.tax_regime_code,
    --tax_id                          =  --temp.tax_id,
--    tax                               =  temp.tax,
    --tax_status_id                   =  --temp.tax_status_id,
    tax_status_code                   =  temp.tax_status_code,
    --tax_rate_id                     =  --temp.tax_rate_id,
    tax_rate_code                     =  temp.tax_rate_code,
    tax_rate                          =  temp.tax_rate,
--    tax_apportionment_line_number     =  temp.tax_apportionment_line_number,
    trx_id_level2                     =  temp.trx_id_level2,
    trx_id_level3                     =  temp.trx_id_level3,
    trx_id_level4                     =  temp.trx_id_level4,
    trx_id_level5                     =  temp.trx_id_level5,
    --trx_id_level6                   =  -- temp.trx_id_level6,
    mrc_tax_line_flag                 =  temp.mrc_tax_line_flag,
    ledger_id                         =  temp.ledger_id,
    establishment_id                  =  temp.establishment_id,
    legal_entity_id                   =  temp.legal_entity_id,
    legal_entity_tax_reg_number       =  temp.legal_entity_tax_reg_number,
    hq_estb_reg_number                =  temp.hq_estb_reg_number,
    hq_estb_party_tax_prof_id         =  temp.hq_estb_party_tax_prof_id,
    currency_conversion_date          =  temp.currency_conversion_date,
    currency_conversion_type          =  temp.currency_conversion_type,
    currency_conversion_rate          =  temp.currency_conversion_rate,
    trx_currency_code                 =  temp.trx_currency_code,
    minimum_accountable_unit          =  temp.minimum_accountable_unit,
    precision                         =  temp.precision,
    trx_number                        =  temp.trx_number,
    trx_date                          =  temp.trx_date,
    unit_price                        =  temp.unit_price,
    line_amt                          =  temp.line_amt,
    trx_line_quantity                 =  temp.trx_line_quantity,
    ref_doc_application_id            =  temp.ref_doc_application_id,
    ref_doc_entity_code               =  temp.ref_doc_entity_code,
    ref_doc_event_class_code          =  temp.ref_doc_event_class_code,
    ref_doc_trx_id                    =  temp.ref_doc_trx_id,
    ref_doc_line_id                   =  temp.ref_doc_line_id,
    ref_doc_line_quantity             =  temp.ref_doc_line_quantity,
    other_doc_line_amt                =  temp.other_doc_line_amt,
    other_doc_line_tax_amt            =  temp.other_doc_line_tax_amt,
    other_doc_line_taxable_amt        =  temp.other_doc_line_taxable_amt,
    unrounded_taxable_amt             =  temp.unrounded_taxable_amt,
    unrounded_tax_amt                 =  temp.unrounded_tax_amt,
    process_for_recovery_flag         =  temp.process_for_recovery_flag,
    tax_jurisdiction_id               =  temp.tax_jurisdiction_id,
    tax_jurisdiction_code             =  temp.tax_jurisdiction_code,
    place_of_supply                   =  temp.place_of_supply,
    place_of_supply_type_code         =  temp.place_of_supply_type_code,
    place_of_supply_result_id         =  temp.place_of_supply_result_id,
    offset_flag                       =  temp.offset_flag,
    tax_date                          =  temp.tax_date,
    tax_determine_date                =  temp.tax_determine_date,
    tax_point_date                    =  temp.tax_point_date,
    trx_line_date                     =  temp.trx_line_date,
    tax_type_code                     =  temp.tax_type_code,
    tax_code                          =  temp.tax_code,
    tax_registration_number           =  temp.tax_registration_number,
    registration_party_type           =  temp.registration_party_type,
    rounding_level_code               =  temp.rounding_level_code,
    rounding_rule_code                =  temp.rounding_rule_code,
    rounding_lvl_party_tax_prof_id    =  temp.rounding_lvl_party_tax_prof_id,
    rounding_lvl_party_type           =  temp.rounding_lvl_party_type,
    historical_flag                   =  temp.historical_flag,
    tax_amt_included_flag             =  temp.tax_amt_included_flag,
    self_assessed_flag                =  temp.self_assessed_flag,
    overridden_flag                   =  temp.overridden_flag,
    manually_entered_flag             =  temp.manually_entered_flag,
    freeze_until_overridden_flag      =  'Y',                                   -- L.freeze_until_overridden_flag,
    copied_from_other_doc_flag        =  'Y',                                   -- L.copied_from_other_doc_flag,
    recalc_required_flag              =  temp.recalc_required_flag,
    settlement_flag                   =  temp.settlement_flag,
    item_dist_changed_flag            =  temp.item_dist_changed_flag,
    associated_child_frozen_flag      =  temp.associated_child_frozen_flag,
    tax_only_line_flag                =  temp.tax_only_line_flag,
    compounding_dep_tax_flag          =  temp.compounding_dep_tax_flag,
    last_manual_entry                 =  'TAX_AMOUNT',                           -- L.last_manual_entry,
    tax_provider_id                   =  temp.tax_provider_id,
    tax_applicability_result_id       =  temp.tax_applicability_result_id,
    direct_rate_result_id             =  temp.direct_rate_result_id,
    sync_with_prvdr_flag              =  temp.sync_with_prvdr_flag,
    other_doc_source                  =  'SOURCE',                               -- L.other_doc_source
    reporting_only_flag               =  temp.reporting_only_flag,
    line_assessable_value             =  temp.line_assessable_value,
    tax_reg_num_det_result_id         =  temp.tax_reg_num_det_result_id,
    record_type_code                  =  temp.record_type_code,
    tax_currency_code                 =  temp.tax_currency_code,
    numeric1                          =  temp.numeric1,
    numeric2                          =  temp.numeric2,
    numeric3                          =  temp.numeric3,
    numeric4                          =  temp.numeric4,
    numeric5                          =  temp.numeric5,
    numeric6                          =  temp.numeric6,
    numeric7                          =  temp.numeric7,
    numeric8                          =  temp.numeric8,
    numeric9                          =  temp.numeric9,
    numeric10                         =  temp.numeric10,
    char1                             =  temp.char1,
    char2                             =  temp.char2,
    char3                             =  temp.char3,
    char4                             =  temp.char4,
    char5                             =  temp.char5,
    char6                             =  temp.char6,
    char7                             =  temp.char7,
    char8                             =  temp.char8,
    char9                             =  temp.char9,
    char10                            =  temp.char10,
    date1                             =  temp.date1,
    date2                             =  temp.date2,
    date3                             =  temp.date3,
    date4                             =  temp.date4,
    date5                             =  temp.date5,
    date6                             =  temp.date6,
    date7                             =  temp.date7,
    date8                             =  temp.date8,
    date9                             =  temp.date9,
    date10                            =  temp.date10,
    related_doc_application_id        =  temp.related_doc_application_id,
    related_doc_entity_code           =  temp.related_doc_entity_code,
    related_doc_event_class_code      =  temp.related_doc_event_class_code,
    related_doc_trx_id                =  temp.related_doc_trx_id,
    related_doc_number                =  temp.related_doc_number,
    related_doc_date                  =  temp.related_doc_date,
    applied_from_application_id       =  temp.applied_from_application_id,
    applied_from_event_class_code     =  temp.applied_from_event_class_code,
    applied_from_entity_code          =  temp.applied_from_entity_code,
    applied_from_trx_id               =  temp.applied_from_trx_id,
    applied_from_line_id              =  temp.applied_from_line_id,
    applied_from_trx_number           =  temp.applied_from_trx_number,
    adjusted_doc_application_id       =  temp.adjusted_doc_application_id,
    adjusted_doc_entity_code          =  temp.adjusted_doc_entity_code,
    adjusted_doc_event_class_code     =  temp.adjusted_doc_event_class_code,
    adjusted_doc_trx_id               =  temp.adjusted_doc_trx_id,
    adjusted_doc_line_id              =  temp.adjusted_doc_line_id,
    adjusted_doc_number               =  temp.adjusted_doc_number,
    adjusted_doc_date                 =  temp.adjusted_doc_date,
    applied_to_application_id         =  temp.applied_to_application_id,
    applied_to_event_class_code       =  temp.applied_to_event_class_code,
    applied_to_entity_code            =  temp.applied_to_entity_code,
    applied_to_trx_id                 =  temp.applied_to_trx_id,
    applied_to_line_id                =  temp.applied_to_trx_line_id,
    applied_to_trx_number             =  temp.applied_to_trx_number,
    exempt_certificate_number         =  temp.exempt_certificate_number,
    summary_tax_line_id               =  NULL,                                    -- L.summary_tax_line_id,
    offset_link_to_tax_line_id        =  NULL,                                    -- L.offset_link_to_tax_line_id,
    tax_currency_conversion_date      =  temp.tax_currency_conversion_date,
    tax_currency_conversion_type      =  temp.tax_currency_conversion_type,
    tax_currency_conversion_rate      =  temp.tax_currency_conversion_rate,
    tax_base_modifier_rate            =  temp.tax_base_modifier_rate,
    tax_date_rule_id                  =  temp.tax_date_rule_id,
    tax_registration_id               =  temp.tax_registration_id,
    compounding_tax_flag              =  temp.compounding_tax_flag,
    tax_amt                           =  NULL,                                    -- L.tax_amt,
    tax_amt_tax_curr                  =  NULL,                                    -- L.tax_amt_tax_curr,
    tax_amt_funcl_curr                =  NULL,                                    -- L.tax_amt_funcl_curr,
    taxable_amt                       =  NULL,                                    -- L.taxable_amt,
    taxable_amt_tax_curr              =  NULL,                                    -- L.taxable_amt_tax_curr,
    taxable_amt_funcl_curr            =  NULL,                                    -- L.taxable_amt_funcl_curr,
    cal_tax_amt                       =  temp.cal_tax_amt,
    cal_tax_amt_tax_curr              =  NULL,                                    -- L.cal_tax_amt_tax_curr,
    cal_tax_amt_funcl_curr            =  NULL,                                    -- L.cal_tax_amt_funcl_curr,
    rec_tax_amt                       =  NULL,                                    -- L.rec_tax_amt,
    rec_tax_amt_tax_curr              =  NULL,                                    -- L.rec_tax_amt_tax_curr,
    rec_tax_amt_funcl_curr            =  NULL,                                    -- L.rec_tax_amt_funcl_curr,
    nrec_tax_amt                      =  NULL,                                    -- L.nrec_tax_amt,
    nrec_tax_amt_tax_curr             =  NULL,                                    -- L.nrec_tax_amt_tax_curr,
    nrec_tax_amt_funcl_curr           =  NULL,                                    -- L.nrec_tax_amt_funcl_curr,
    tax_exemption_id                  =  temp.tax_exemption_id,
    tax_rate_before_exemption         =  temp.tax_rate_before_exemption,
    tax_rate_name_before_exemption    =  temp.tax_rate_name_before_exemption,
    exempt_rate_modifier              =  temp.exempt_rate_modifier,
    exempt_reason                     =  temp.exempt_reason,
    exempt_reason_code                =  temp.exempt_reason_code,
    tax_exception_id                  =  temp.tax_exception_id,
    tax_rate_before_exception         =  temp.tax_rate_before_exception,
    tax_rate_name_before_exception    =  temp.tax_rate_name_before_exception,
    exception_rate                    =  temp.exception_rate,
    taxable_basis_formula             =  temp.taxable_basis_formula,
    tax_calculation_formula           =  temp.tax_calculation_formula,
    tax_apportionment_flag            =  temp.tax_apportionment_flag,
    cancel_flag                       =  temp.cancel_flag,
    purge_flag                        =  temp.purge_flag,
    delete_flag                       =  temp.delete_flag,
    enforce_from_natural_acct_flag    =  temp.enforce_from_natural_acct_flag,
    reporting_period_id               =  temp.reporting_period_id,
    legal_message_appl_2              =  temp.legal_message_appl_2,
    legal_message_status              =  temp.legal_message_status,
    legal_message_rate                =  temp.legal_message_rate,
    legal_message_basis               =  temp.legal_message_basis,
    legal_message_calc                =  temp.legal_message_calc,
    legal_message_threshold           =  temp.legal_message_threshold,
    legal_message_pos                 =  temp.legal_message_pos,
    legal_message_trn                 =  temp.legal_message_trn,
    legal_message_exmpt               =  temp.legal_message_exmpt,
    legal_message_excpt               =  temp.legal_message_excpt,
    tax_regime_template_id            =  temp.tax_regime_template_id,
    status_result_id                  =  temp.status_result_id,
    rate_result_id                    =  temp.rate_result_id,
    basis_result_id                   =  temp.basis_result_id,
    thresh_result_id                  =  temp.thresh_result_id,
    calc_result_id                    =  temp.calc_result_id,
    eval_exmpt_result_id              =  temp.eval_exmpt_result_id,
    eval_excpt_result_id              =  temp.eval_excpt_result_id,
    tax_hold_code                     =  NULL,                                 -- L.tax_hold_code,
    tax_hold_released_code            =  NULL,                                 -- L.tax_hold_released_code,
    prd_total_tax_amt                 =  NULL,                                 -- L.prd_total_tax_amt,
    prd_total_tax_amt_tax_curr        =  NULL,                                 -- L.prd_total_tax_amt_tax_curr,
    prd_total_tax_amt_funcl_curr      =  NULL,                                 -- L.prd_total_tax_amt_funcl_curr,
    tax_rate_type                     =  temp.tax_rate_type,
    legal_justification_text1         =  temp.legal_justification_text1,
    legal_justification_text2         =  temp.legal_justification_text2,
    legal_justification_text3         =  temp.legal_justification_text3,
    reporting_currency_code           =  temp.reporting_currency_code,
    trx_line_index                    =  NULL,                                 -- L.trx_line_index
    offset_tax_rate_code              =  NULL,                                 -- L.offset_tax_rate_code
    proration_code                    =  NULL,                                 -- L.proration_code
    ctrl_total_line_tx_amt            =  temp.ctrl_total_line_tx_amt,
    created_by                        =  l_user_id,                            -- created_by,
    creation_date                     =  sysdate,                              -- creation_date,
    last_updated_by                   =  l_user_id,                            -- last_updated_by
    last_update_date                  =  sysdate,                              -- last_update_date,
    last_update_login                 =  l_login_id,
    interface_entity_code             =  temp.interface_entity_code,
    interface_tax_line_id             =  temp.interface_tax_line_id,
    taxing_juris_geography_id         =  temp.taxing_juris_geography_id,
    adjusted_doc_tax_line_id          =  temp.adjusted_doc_tax_line_id,
    object_version_number             =  1

WHEN NOT MATCHED THEN
  INSERT ( tax_line_id,
         internal_organization_id,
         internal_org_location_id,
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
         --tax_regime_id,
         tax_regime_code,
         --tax_id,
         tax,
         --tax_status_id,
         tax_status_code,
         --tax_rate_id,
         tax_rate_code,
         tax_rate,
         tax_apportionment_line_number,
         trx_id_level2,
         trx_id_level3,
         trx_id_level4,
         trx_id_level5,
         --trx_id_level6,
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
         trx_currency_code,
         minimum_accountable_unit,
         precision,
         trx_number,
         trx_date,
         unit_price,
         line_amt,
         trx_line_quantity,
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
         process_for_recovery_flag,
         tax_jurisdiction_id,
         tax_jurisdiction_code,
         place_of_supply,
         place_of_supply_type_code,
         place_of_supply_result_id,
         offset_flag,
         tax_date,
         tax_determine_date,
         tax_point_date,
         trx_line_date,
         tax_type_code,
         tax_code,
         tax_registration_number,
         registration_party_type,
         rounding_level_code,
         rounding_rule_code,
         rounding_lvl_party_tax_prof_id,
         rounding_lvl_party_type,
         historical_flag,
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
         tax_applicability_result_id,
         direct_rate_result_id,
         sync_with_prvdr_flag,
         other_doc_source,
         reporting_only_flag,
         line_assessable_value,
         tax_reg_num_det_result_id,
         record_type_code,
         tax_currency_code,
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
         applied_from_trx_number,
         adjusted_doc_application_id,
         adjusted_doc_entity_code,
         adjusted_doc_event_class_code,
         adjusted_doc_trx_id,
         adjusted_doc_line_id,
         adjusted_doc_number,
         adjusted_doc_date,
         applied_to_application_id,
         applied_to_event_class_code,
         applied_to_entity_code,
         applied_to_trx_id,
         applied_to_line_id,
         applied_to_trx_number,
         exempt_certificate_number,
         summary_tax_line_id,
         offset_link_to_tax_line_id,
         tax_currency_conversion_date,
         tax_currency_conversion_type,
         tax_currency_conversion_rate,
         tax_base_modifier_rate,
         tax_date_rule_id,
         tax_registration_id,
         compounding_tax_flag,
         tax_amt,
         tax_amt_tax_curr,
         tax_amt_funcl_curr,
         taxable_amt,
         taxable_amt_tax_curr,
         taxable_amt_funcl_curr,
         cal_tax_amt,
         cal_tax_amt_tax_curr,
         cal_tax_amt_funcl_curr,
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
         exempt_reason,
         exempt_reason_code,
         tax_exception_id,
         tax_rate_before_exception,
         tax_rate_name_before_exception,
         exception_rate,
         taxable_basis_formula,
         tax_calculation_formula,
         tax_apportionment_flag,
         cancel_flag,
         purge_flag,
         delete_flag,
         enforce_from_natural_acct_flag,
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
         status_result_id,
         rate_result_id,
         basis_result_id,
         thresh_result_id,
         calc_result_id,
         eval_exmpt_result_id,
         eval_excpt_result_id,
         tax_hold_code,
         tax_hold_released_code,
         prd_total_tax_amt,
         prd_total_tax_amt_tax_curr,
         prd_total_tax_amt_funcl_curr,
         tax_rate_type,
         legal_justification_text1,
         legal_justification_text2,
         legal_justification_text3,
         reporting_currency_code,
         trx_line_index,
         offset_tax_rate_code,
         proration_code,
         ctrl_total_line_tx_amt,
         created_by,
         creation_date,
         last_updated_by,
         last_update_date,
         last_update_login,
         interface_entity_code,
         interface_tax_line_id,
         taxing_juris_geography_id,
         adjusted_doc_tax_line_id,
         object_version_number
         )
  VALUES(
         zx_lines_s.NEXTVAL,                     -- tax_line_id,
         temp.internal_organization_id,
         temp.internal_org_location_id,
         temp.application_id,
         temp.entity_code,
         temp.event_class_code,
         temp.event_type_code,
         temp.trx_id,
         temp.trx_line_id,
         temp.trx_level_type,
         temp.trx_line_number,
         temp.doc_event_status,
         temp.tax_event_class_code,
         temp.tax_event_type_code,
         NUMBER_DUMMY,                                   --  L.tax_line_number,
         temp.content_owner_id,
         --temp.tax_regime_id,
         temp.tax_regime_code,
         --temp.tax_id,
         temp.tax,
         --temp.tax_status_id,
         temp.tax_status_code,
         --temp.tax_rate_id,
         temp.tax_rate_code,
         temp.tax_rate,
         temp.tax_apportionment_line_number,
         temp.trx_id_level2,
         temp.trx_id_level3,
         temp.trx_id_level4,
         temp.trx_id_level5,
         -- temp.trx_id_level6,
         temp.mrc_tax_line_flag,
         temp.ledger_id,
         temp.establishment_id,
         temp.legal_entity_id,
         temp.legal_entity_tax_reg_number,
         temp.hq_estb_reg_number,
         temp.hq_estb_party_tax_prof_id,
         temp.currency_conversion_date,
         temp.currency_conversion_type,
         temp.currency_conversion_rate,
         temp.trx_currency_code,
         temp.minimum_accountable_unit,
         temp.precision,
         temp.trx_number,
         temp.trx_date,
         temp.unit_price,
         temp.line_amt,
         temp.trx_line_quantity,
         temp.ref_doc_application_id,
         temp.ref_doc_entity_code,
         temp.ref_doc_event_class_code,
         temp.ref_doc_trx_id,
         temp.ref_doc_line_id,
         temp.ref_doc_line_quantity,
         temp.other_doc_line_amt,
         temp.other_doc_line_tax_amt,
         temp.other_doc_line_taxable_amt,
         temp.unrounded_taxable_amt,
         temp.unrounded_tax_amt,
         temp.process_for_recovery_flag,
         temp.tax_jurisdiction_id,
         temp.tax_jurisdiction_code,
         temp.place_of_supply,
         temp.place_of_supply_type_code,
         temp.place_of_supply_result_id,
         temp.offset_flag,
         temp.tax_date,
         temp.tax_determine_date,
         temp.tax_point_date,
         temp.trx_line_date,
         temp.tax_type_code,
         temp.tax_code,
         temp.tax_registration_number,
         temp.registration_party_type,
         temp.rounding_level_code,
         temp.rounding_rule_code,
         temp.rounding_lvl_party_tax_prof_id,
         temp.rounding_lvl_party_type,
         temp.historical_flag,
         temp.tax_amt_included_flag,
         temp.self_assessed_flag,
         temp.overridden_flag,
         temp.manually_entered_flag,
         'Y',                                   -- L.freeze_until_overridden_flag,
         'Y',                                   -- L.copied_from_other_doc_flag,
         temp.recalc_required_flag,
         temp.settlement_flag,
         temp.item_dist_changed_flag,
         temp.associated_child_frozen_flag,
         temp.tax_only_line_flag,
         temp.compounding_dep_tax_flag,
         'TAX_AMOUNT',                         -- L.last_manual_entry,
         temp.tax_provider_id,
         temp.tax_applicability_result_id,
         temp.direct_rate_result_id,
         temp.sync_with_prvdr_flag,
         'SOURCE',                                                     -- L.other_doc_source
         temp.reporting_only_flag,
         temp.line_assessable_value,
         temp.tax_reg_num_det_result_id,
         temp.record_type_code,
         temp.tax_currency_code,
         temp.numeric1,
         temp.numeric2,
         temp.numeric3,
         temp.numeric4,
         temp.numeric5,
         temp.numeric6,
         temp.numeric7,
         temp.numeric8,
         temp.numeric9,
         temp.numeric10,
         temp.char1,
         temp.char2,
         temp.char3,
         temp.char4,
         temp.char5,
         temp.char6,
         temp.char7,
         temp.char8,
         temp.char9,
         temp.char10,
         temp.date1,
         temp.date2,
         temp.date3,
         temp.date4,
         temp.date5,
         temp.date6,
         temp.date7,
         temp.date8,
         temp.date9,
         temp.date10,
         temp.related_doc_application_id,
         temp.related_doc_entity_code,
         temp.related_doc_event_class_code,
         temp.related_doc_trx_id,
         temp.related_doc_number,
         temp.related_doc_date,
         temp.applied_from_application_id,
         temp.applied_from_event_class_code,
         temp.applied_from_entity_code,
         temp.applied_from_trx_id,
         temp.applied_from_line_id,
         temp.applied_from_trx_number,
         temp.adjusted_doc_application_id,
         temp.adjusted_doc_entity_code,
         temp.adjusted_doc_event_class_code,
         temp.adjusted_doc_trx_id,
         temp.adjusted_doc_line_id,
         temp.adjusted_doc_number,
         temp.adjusted_doc_date,
         temp.applied_to_application_id,
         temp.applied_to_event_class_code,
         temp.applied_to_entity_code,
         temp.applied_to_trx_id,
         temp.applied_to_trx_line_id,
         temp.applied_to_trx_number,
         temp.exempt_certificate_number,
         NULL,                                    -- L.summary_tax_line_id,
         NULL,                                    -- L.offset_link_to_tax_line_id,
         temp.tax_currency_conversion_date,
         temp.tax_currency_conversion_type,
         temp.tax_currency_conversion_rate,
         temp.tax_base_modifier_rate,
         temp.tax_date_rule_id,
         temp.tax_registration_id,
         temp.compounding_tax_flag,
         NULL,                                    -- L.tax_amt,
         NULL,                                    -- L.tax_amt_tax_curr,
         NULL,                                    -- L.tax_amt_funcl_curr,
         NULL,                                    -- L.taxable_amt,
         NULL,                                    -- L.taxable_amt_tax_curr,
         NULL,                                    -- L.taxable_amt_funcl_curr,
         temp.cal_tax_amt,
         NULL,                                    -- L.cal_tax_amt_tax_curr,
         NULL,                                    -- L.cal_tax_amt_funcl_curr,
         NULL,                                    -- L.rec_tax_amt,
         NULL,                                    -- L.rec_tax_amt_tax_curr,
         NULL,                                    -- L.rec_tax_amt_funcl_curr,
         NULL,                                    -- L.nrec_tax_amt,
         NULL,                                    -- L.nrec_tax_amt_tax_curr,
         NULL,                                    -- L.nrec_tax_amt_funcl_curr,
         temp.tax_exemption_id,
         temp.tax_rate_before_exemption,
         temp.tax_rate_name_before_exemption,
         temp.exempt_rate_modifier,
         temp.exempt_reason,
         temp.exempt_reason_code,
         temp.tax_exception_id,
         temp.tax_rate_before_exception,
         temp.tax_rate_name_before_exception,
         temp.exception_rate,
         temp.taxable_basis_formula,
         temp.tax_calculation_formula,
         temp.tax_apportionment_flag,
         temp.cancel_flag,
         temp.purge_flag,
         temp.delete_flag,
         temp.enforce_from_natural_acct_flag,
         temp.reporting_period_id,
         temp.legal_message_appl_2,
         temp.legal_message_status,
         temp.legal_message_rate,
         temp.legal_message_basis,
         temp.legal_message_calc,
         temp.legal_message_threshold,
         temp.legal_message_pos,
         temp.legal_message_trn,
         temp.legal_message_exmpt,
         temp.legal_message_excpt,
         temp.tax_regime_template_id,
         temp.status_result_id,
         temp.rate_result_id,
         temp.basis_result_id,
         temp.thresh_result_id,
         temp.calc_result_id,
         temp.eval_exmpt_result_id,
         temp.eval_excpt_result_id,
         NULL,                                 -- L.tax_hold_code,
         NULL,                                 -- L.tax_hold_released_code,
         NULL,                                 -- L.prd_total_tax_amt,
         NULL,                                 -- L.prd_total_tax_amt_tax_curr,
         NULL,                                 -- L.prd_total_tax_amt_funcl_curr,
         temp.tax_rate_type,
         temp.legal_justification_text1,
         temp.legal_justification_text2,
         temp.legal_justification_text3,
         temp.reporting_currency_code,
         NULL,                                 -- L.trx_line_index
         NULL,                                 -- L.offset_tax_rate_code
         NULL,                                 -- L.proration_code
         temp.ctrl_total_line_tx_amt,
         l_user_id,                            -- created_by,
         sysdate,                              -- creation_date,
         l_user_id,                            -- last_updated_by
         sysdate,                              -- last_update_date,
         l_login_id,
         temp.interface_entity_code,
         temp.interface_tax_line_id,
         temp.taxing_juris_geography_id,
         temp.adjusted_doc_tax_line_id,
         1 );

  OPEN get_tax_info_csr;
  LOOP

    FETCH get_tax_info_csr BULK COLLECT INTO
      l_tax_line_id_tab,
      l_tax_regime_code_tab,
      l_tax_jurisdiction_code_tab,
      l_tax_tab,
      l_tax_status_code_tab,
      l_tax_rate_code_tab,
      l_tax_determine_date_tab
    LIMIT c_lines_per_fetch;

    FOR i in 1 .. l_tax_line_id_tab.count LOOP

      -- validate and populate tax_regime_id
      --
      ZX_TDS_UTILITIES_PKG.get_regime_cache_info(
    			l_tax_regime_code_tab(i),
    			l_tax_determine_date_tab(i),
    			l_tax_regime_rec,
    			x_return_status,
    			x_error_buffer);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
        IF (g_level_unexpected >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_unexpected,
                 'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.process_copy_and_create',
                 'Incorrect return_status after calling ' ||
                 'ZX_TDS_UTILITIES_PKG.get_regime_cache_info');
          FND_LOG.STRING(g_level_unexpected,
                 'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.process_copy_and_create',
                 'RETURN_STATUS = ' || x_return_status);
          FND_LOG.STRING(g_level_unexpected,
                 'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.process_copy_and_create.END',
                 'ZX_TDS_TAX_LINES_DETM_PKG.process_copy_and_create(-)');
        END IF;
        RETURN;
      END IF;

      l_tax_regime_id_tab(i) := l_tax_regime_rec.tax_regime_id;

      -- validate and populate tax_id
      --
      ZX_TDS_UTILITIES_PKG.get_tax_cache_info(
    			l_tax_regime_code_tab(i),
                        l_tax_tab(i),
    			l_tax_determine_date_tab(i),
    			l_tax_rec,
    			x_return_status,
    			x_error_buffer);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
        IF (g_level_unexpected >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_unexpected,
                 'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.process_copy_and_create',
                 'Incorrect return_status after calling ' ||
                 'ZX_TDS_UTILITIES_PKG.get_tax_cache_info');
          FND_LOG.STRING(g_level_unexpected,
                 'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.process_copy_and_create',
                 'RETURN_STATUS = ' || x_return_status);
          FND_LOG.STRING(g_level_unexpected,
                 'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.process_copy_and_create.END',
                 'ZX_TDS_TAX_LINES_DETM_PKG.process_copy_and_create(-)');
        END IF;
        RETURN;
      END IF;

      l_tax_id_tab(i) := l_tax_rec.tax_id;

      IF l_tax_jurisdiction_code_tab(i) IS NOT NULL THEN
        ZX_TDS_UTILITIES_PKG.get_jurisdiction_cache_info(
    	  		l_tax_regime_code_tab(i),
                        l_tax_tab(i),
                        l_tax_jurisdiction_code_tab(i),
    	  		l_tax_determine_date_tab(i),
    	  		l_tax_jurisdiction_rec,
    	  		x_return_status,
    	  		x_error_buffer);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
          IF (g_level_unexpected >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_unexpected,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.process_copy_and_create',
                   'Incorrect return_status after calling ' ||
                   'ZX_TDS_UTILITIES_PKG.get_jurisdiction_cache_info');
            FND_LOG.STRING(g_level_unexpected,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.process_copy_and_create',
                   'RETURN_STATUS = ' || x_return_status);
            FND_LOG.STRING(g_level_unexpected,
                   'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.process_copy_and_create.END',
                   'ZX_TDS_TAX_LINES_DETM_PKG.process_copy_and_create(-)');
          END IF;
          RETURN;
        END IF;

        l_tax_jur_id_tab(i) := l_tax_jurisdiction_rec.tax_jurisdiction_id;

      ELSE

        l_tax_jur_id_tab(i) := NULL;
      END IF;

      -- validate and populate tax_status_id
      --
      ZX_TDS_UTILITIES_PKG.get_tax_status_cache_info(
                        l_tax_tab(i),
    			l_tax_regime_code_tab(i),
                        l_tax_status_code_tab(i),
    			l_tax_determine_date_tab(i),
    			l_tax_status_rec,
    			x_return_status,
    			x_error_buffer);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
        IF (g_level_unexpected >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_unexpected,
                 'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.process_copy_and_create',
                 'Incorrect return_status after calling ' ||
                 'ZX_TDS_UTILITIES_PKG.get_tax_status_cache_info');
          FND_LOG.STRING(g_level_unexpected,
                 'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.process_copy_and_create',
                 'RETURN_STATUS = ' || x_return_status);
          FND_LOG.STRING(g_level_unexpected,
                 'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.process_copy_and_create.END',
                 'ZX_TDS_TAX_LINES_DETM_PKG.process_copy_and_create(-)');
        END IF;
        RETURN;
      END IF;

      l_tax_status_id_tab(i) := l_tax_status_rec.tax_status_id;

      -- validate and populate tax_rate_id
      --
      ZX_TDS_UTILITIES_PKG.get_tax_rate_info(
    			l_tax_regime_code_tab(i),
                        l_tax_tab(i),
                        l_tax_jurisdiction_code_tab(i),
                        l_tax_status_code_tab(i),
                        l_tax_rate_code_tab(i),
    			l_tax_determine_date_tab(i),
                        l_tax_class,
    			l_tax_rate_rec,
    			x_return_status,
    			x_error_buffer);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
        IF (g_level_unexpected >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_unexpected,
                 'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.process_copy_and_create',
                 'Incorrect return_status after calling ' ||
                 'ZX_TDS_UTILITIES_PKG.get_tax_rate_info');
          FND_LOG.STRING(g_level_unexpected,
                 'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.process_copy_and_create',
                 'RETURN_STATUS = ' || x_return_status);
          FND_LOG.STRING(g_level_unexpected,
                 'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.process_copy_and_create.END',
                 'ZX_TDS_TAX_LINES_DETM_PKG.process_copy_and_create(-)');
        END IF;
        RETURN;
      END IF;

      l_tax_rate_id_tab(i) := l_tax_rate_rec.tax_rate_id;

    END LOOP;

    FORALL i in 1 .. l_tax_line_id_tab.COUNT
      UPDATE /*+ INDEX(ZX_DETAIL_TAX_LINES_GT ZX_DETAIL_TAX_LINES_GT_U2) */
             zx_detail_tax_lines_gt
         SET tax_regime_id = l_tax_regime_id_tab(i),
             tax_id        = l_tax_id_tab(i),
             tax_jurisdiction_id = l_tax_jur_id_tab(i),
             tax_status_id = l_tax_status_id_tab(i),
             tax_rate_id   = l_tax_rate_id_tab(i)
       WHERE tax_line_id   = l_tax_line_id_tab(i);

    EXIT WHEN get_tax_info_csr%NOTFOUND;
  END LOOP;
  CLOSE get_tax_info_csr;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                  'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.process_copy_and_create',
                  'p_return_status = ' || x_return_status);
    FND_LOG.STRING(g_level_procedure,
                  'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.process_copy_and_create',
                  'p_error_buffer  = ' || x_error_buffer);
    FND_LOG.STRING(g_level_procedure,
                  'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.process_copy_and_create.END',
                  'ZX_TDS_TAX_LINES_DETM_PKG: process_copy_and_create(-)');
  END IF;

 EXCEPTION
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
     IF (g_level_unexpected >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_unexpected,
              'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.process_copy_and_create',
               x_error_buffer);
     END IF;

END process_copy_and_create;

-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  adjust_overapplication
--
--  DESCRIPTION
--
--  HISTORY
--  Ling Zhang  Feb-23-2005     Created for Bug Fix 4151574
--

PROCEDURE adjust_overapplication(
            -- p_event_class_rec   IN     ZX_API_PUB.EVENT_CLASS_REC_TYPE,
            x_return_status         OUT NOCOPY VARCHAR2,
            x_error_buffer          OUT NOCOPY VARCHAR2)
IS
  CURSOR get_tax_amts IS
    SELECT  det.unrounded_tax_amt
           ,det.tax_amt_tax_curr
	   ,det.tax_amt_funcl_curr
           ,det.manually_entered_flag
           ,det.copied_from_other_doc_flag
	   ,v.tax_amt
	   ,v.line_amt
	   ,v.remain_amt
	   ,v.remain_unrounded_amt
	   ,v.remain_amt_tax_curr
	   ,v.remain_amt_funcl_curr
	   ,v.reporting_currency_code
           ,v.tax_line_id
	   ,v.remain_line_amt
	   ,v.orig_tax_amt
	   ,v.orig_line_amt
    FROM zx_detail_tax_lines_gt det
        ,(SELECT /*+ INDEX(tax ZX_DETAIL_TAX_LINES_GT_U1) */
            tax.tax_amt tax_amt
           ,tax.line_amt line_amt
           ,org_tax.tax_amt + NVL(SUM(cm_tax.tax_amt), 0) remain_amt
           ,org_tax.unrounded_tax_amt + NVL(SUM(cm_tax.unrounded_tax_amt), 0) remain_unrounded_amt
           ,org_tax.tax_amt_tax_curr + NVL(SUM(cm_tax.tax_amt_tax_curr), 0) remain_amt_tax_curr
           ,org_tax.tax_amt_funcl_curr + NVL(SUM(cm_tax.tax_amt_funcl_curr), 0) remain_amt_funcl_curr
           ,org_tax.reporting_currency_code
           ,tax.tax_line_id
           ,org_tax.line_amt + NVL(SUM(cm_tax.line_amt), 0) remain_line_amt
           ,org_tax.tax_amt orig_tax_amt
           ,org_tax.line_amt orig_line_amt
     FROM zx_lines org_tax,
          zx_lines cm_tax,
          zx_detail_tax_lines_gt tax
    WHERE
      -- commented out for bug fix 5417887
      --    tax.application_id   = p_event_class_rec.application_id
      --AND tax.entity_code      = p_event_class_rec.entity_code
      --AND tax.event_class_code = p_event_class_rec.event_class_code
      --AND tax.trx_id           = p_event_class_rec.trx_id

          tax.event_class_code = 'CREDIT_MEMO'  -- added for bug fix 5417887
      AND org_tax.tax_line_id = tax.adjusted_doc_tax_line_id
      AND cm_tax.adjusted_doc_tax_line_id(+) = tax.adjusted_doc_tax_line_id
      AND cm_tax.application_id(+) = tax.application_id
      AND cm_tax.trx_id(+) <> tax.trx_id
      -- filter out the tax lines for the current credit memo
      -- can't just use the tax_line_id equal condition, since for update
      -- case, the credt memo tax lines will be deleted and recreated,
      -- hence the tax_line_id will change.
      /*  AND NOT (tax.application_id = cm_tax.application_id
               AND tax.entity_code = cm_tax.entity_code
               AND tax.event_class_code = cm_tax.event_class_code
               AND tax.trx_id = cm_tax.trx_id
               --AND tax.trx_level_type = cm_tax.trx_level_type
               --AND tax.trx_line_id = cm_tax.trx_line_id
               --AND tax.tax_regime_code = cm_tax.tax_regime_code
               --AND tax.tax = cm_tax.tax
               --AND tax.tax_apportionment_line_number = cm.tax_apportionment_line_number
               )
       */
      AND org_tax.Cancel_Flag <> 'Y'
      AND cm_tax.Cancel_Flag(+) <> 'Y'
      /* AND ( ( cm_tax.mrc_tax_line_flag = 'N'
          AND org_tax.mrc_tax_line_flag = 'N'
          AND tax.mrc_tax_line_flag = 'N')
        OR ( org_tax.reporting_currency_code = tax.reporting_currency_code
          AND tax.reporting_currency_code = cm_tax.reporting_currency_code))
       */
      GROUP BY org_tax.reporting_currency_code
               ,tax.tax_line_id
               ,tax.tax_amt
               ,tax.line_amt
               ,tax.unrounded_tax_amt
               ,org_tax.tax_amt
               ,org_tax.line_amt
               ,org_tax.unrounded_tax_amt
               ,org_tax.tax_amt_tax_curr
               ,org_tax.tax_amt_funcl_curr) v
    WHERE det.tax_line_id = v.tax_line_id;


 TYPE num_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
 TYPE var_tbl_type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
 TYPE var1_tbl_type IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;

 l_unrounded_tax_amt_tbl     num_tbl_type;
 l_tax_amt_tax_curr_tbl      num_tbl_type;
 l_tax_amt_funcl_curr_tbl    num_tbl_type;
 l_manually_entered_flag_tbl var1_tbl_type;
 l_cpd_frm_other_doc_flg_tbl var1_tbl_type;

 l_tax_amt_tbl               num_tbl_type;
 l_remain_amt_tbl            num_tbl_type;
 l_remain_unrounded_amt_tbl  num_tbl_type;
 l_remain_amt_tax_curr_tbl   num_tbl_type;
 l_remain_amt_funcl_curr_tbl num_tbl_type;
 l_rpt_currency_code_tbl     var_tbl_type;
 l_tax_line_id_tbl           num_tbl_type;
 l_line_amt_tbl               num_tbl_type;
 l_remain_line_amt_tbl        num_tbl_type;

 l_sign_tax_amt              NUMBER; -- mark the sign of the cm tax amt

 -- bug 6919608
 l_orig_tax_amt_tbl          num_tbl_type;
 l_orig_line_amt_tbl         num_tbl_type;

BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
           'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.adjust_overapplication.BEGIN',
           'ZX_TDS_TAX_LINES_DETM_PKG: adjust_overapplication(+)');
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- if it is a historical trx, do nothing
  --IF p_event_class_rec.CTRL_TOTAL_HDR_TX_AMT  IS NOT NULL
  -- OR p_event_class_rec.CTRL_TOTAL_LINE_TX_AMT_FLG = 'Y'
  --THEN
  --  IF (g_level_statement >= g_current_runtime_level ) THEN
  --
  --    FND_LOG.STRING(g_level_statement,
  --           'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.adjust_overapplication.END',
  --           'ZX_TDS_TAX_LINES_DETM_PKG: adjust_overapplication(-)'||' do not check for historical trx');
  --  END IF;
  --  RETURN;
  --END IF;

  OPEN get_tax_amts;
  FETCH get_tax_amts BULK COLLECT INTO
       l_unrounded_tax_amt_tbl
      ,l_tax_amt_tax_curr_tbl
      ,l_tax_amt_funcl_curr_tbl
      ,l_manually_entered_flag_tbl
      ,l_cpd_frm_other_doc_flg_tbl
      ,l_tax_amt_tbl
      ,l_line_amt_tbl
      ,l_remain_amt_tbl
      ,l_remain_unrounded_amt_tbl
      ,l_remain_amt_tax_curr_tbl
      ,l_remain_amt_funcl_curr_tbl
      ,l_rpt_currency_code_tbl
      ,l_tax_line_id_tbl
      ,l_remain_line_amt_tbl
      ,l_orig_tax_amt_tbl
      ,l_orig_line_amt_tbl;
  CLOSE get_tax_amts;


  -- bug 6919608
  --
  FOR i IN NVL(l_tax_amt_tbl.FIRST, 0) .. NVL(l_tax_amt_tbl.LAST, -1) LOOP
    IF l_orig_tax_amt_tbl(i) > 0 THEN
       IF l_remain_amt_tbl(i)  < 0 THEN
         l_remain_amt_tbl(i) := 0;
       END IF;
     ELSE
       IF l_remain_amt_tbl(i) > 0 THEN
         l_remain_amt_tbl(i) := 0;
       END IF;
     END IF;

     IF l_orig_line_amt_tbl(i) > 0 THEN
       IF l_remain_line_amt_tbl(i)  < 0 THEN
         l_remain_line_amt_tbl(i) := 0;
         l_remain_amt_tbl(i) := 0;
       END IF;
     ELSE
       IF l_remain_line_amt_tbl(i) > 0 THEN
         l_remain_line_amt_tbl(i) := 0;
         l_remain_amt_tbl(i) := 0;
       END IF;
    END IF;
    IF l_manually_entered_flag_tbl(i) = 'Y' AND l_cpd_frm_other_doc_flg_tbl(i) = 'N' THEN
      IF ABS(l_remain_amt_tbl(i)) > ABS(l_tax_amt_tbl(i)) THEN
        l_remain_amt_tbl(i) := l_tax_amt_tbl(i);
        l_remain_unrounded_amt_tbl(i) := l_unrounded_tax_amt_tbl(i);
        l_remain_amt_tax_curr_tbl(i) := l_tax_amt_tax_curr_tbl(i);
	l_remain_amt_funcl_curr_tbl(i) := l_tax_amt_funcl_curr_tbl(i);
      END IF;
    END IF;
  END LOOP;

  FORALL i IN NVL(l_tax_amt_tbl.FIRST, 0) .. NVL(l_tax_amt_tbl.LAST, -1)
      UPDATE /*+ INDEX(ZX_DETAIL_TAX_LINES_GT ZX_DETAIL_TAX_LINES_GT_U2) */
              zx_detail_tax_lines_gt
         SET           tax_amt = sign(l_tax_amt_tbl(i))*ABS(l_remain_amt_tbl(i)),
             unrounded_tax_amt = sign(l_tax_amt_tbl(i))*ABS(l_remain_unrounded_amt_tbl(i)),
              tax_amt_tax_curr = sign(l_tax_amt_tbl(i))*ABS(l_remain_amt_tax_curr_tbl(i)),
            tax_amt_funcl_curr = sign(l_tax_amt_tbl(i))*ABS(l_remain_amt_funcl_curr_tbl(i))
         WHERE (ABS(l_line_amt_tbl(i)) >= ABS(l_remain_line_amt_tbl(i)) OR
                ABS(l_tax_amt_tbl(i)) > ABS(l_remain_amt_tbl(i))
                )
           AND tax_line_id  = l_tax_line_id_tbl(i)
           AND NVL(reporting_currency_code, -99) = NVL(l_rpt_currency_code_tbl(i), -99);

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
           'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.adjust_overapplication.END',
           'ZX_TDS_TAX_LINES_DETM_PKG: adjust_overapplication(-)');
  END IF;

 EXCEPTION
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

     IF (g_level_unexpected >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_unexpected,
              'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.adjust_overapplication',
               x_error_buffer);
     END IF;

END adjust_overapplication;

-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  process_unchanged_trx_lines
--
--  DESCRIPTION
--
--  HISTORY
--  Ling Zhang  Apr-20-2005     Created for Bug Fix 4313177
--

PROCEDURE process_unchanged_trx_lines(
  p_event_class_rec   IN     ZX_API_PUB.EVENT_CLASS_REC_TYPE,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_error_buffer          OUT NOCOPY VARCHAR2)
IS

 l_detail_tax_lines_tbl		ZX_TDS_CALC_SERVICES_PUB_PKG.detail_tax_lines_tbl_type;
 l_tax_index                    NUMBER;

 -- this procedure is added for PO eBTax uptake. PO calls eBtax only in GT mode,
 -- so use zx_transaction_lines_gt in stead of zx_lines_det_factors to retrieve
 -- the tax lines for unchanged the trx lines.

 CURSOR c_tx_ln_for_unchanged_trx_ln IS
   SELECT L.*
   FROM zx_lines L,
        zx_transaction_lines_gt G
   WHERE /* -- commented out for bug fix 5417887
         G.application_id = p_event_class_rec.application_id
     AND G.event_class_code = p_event_class_rec.event_class_code
     AND G.entity_code = p_event_class_rec.entity_code
     AND G.trx_id = p_event_class_rec.trx_id
     AND */
     G.line_level_action = 'NO_CHANGE'
     AND L.application_id = G.application_id
     AND L.event_class_code = G.event_class_code
     AND L.entity_code = G.entity_code
     AND L.trx_id = G.trx_id
     AND L.trx_line_id = G.trx_line_id
     AND L.trx_level_type = G.trx_level_type
     AND L.cancel_flag <> 'Y';

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
           'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.process_unchanged_trx_lines.BEGIN',
           'ZX_TDS_TAX_LINES_DETM_PKG: process_unchanged_trx_lines(+)');
  END IF;

  l_tax_index := 1;
  FOR tax_rec IN c_tx_ln_for_unchanged_trx_ln LOOP

    l_detail_tax_lines_tbl(l_tax_index) := tax_rec;

    IF tax_rec.reporting_only_flag = 'N' THEN
      l_detail_tax_lines_tbl(l_tax_index).process_for_recovery_flag := 'Y';
    ELSE
      l_detail_tax_lines_tbl(l_tax_index).process_for_recovery_flag := 'N';
    END IF;

    l_tax_index := l_tax_index + 1;

  END LOOP;

  FORALL l_tax_ln_index IN l_detail_tax_lines_tbl.FIRST ..
                             l_detail_tax_lines_tbl.LAST

    INSERT INTO zx_detail_tax_lines_gt
      VALUES l_detail_tax_lines_tbl(l_tax_ln_index);


  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
           'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.process_unchanged_trx_lines.BEGIN',
           'ZX_TDS_TAX_LINES_DETM_PKG: process_unchanged_trx_lines(-)');
  END IF;

 EXCEPTION
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

     IF (g_level_unexpected >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_unexpected,
              'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.process_unchanged_trx_lines',
               x_error_buffer);
     END IF;

END process_unchanged_trx_lines;

-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  set_acct_source_tax_rate_id
--
--  DESCRIPTION
--
--  HISTORY
--  Hongjun Liu  Sept-07-2006     Created for Bug Fix 5508356
--
--  DESCRIPTION
--  This procedure is added for bug fix 5508356 for the setting of
--  account_source_tax_rate_id, which should be set based on the
--  tax_rate_id of from the TAX_ACCOUNT_SOURCE_TAX, which belongs
--  to the same transaction line
--

PROCEDURE set_acct_source_tax_rate_id(
  p_event_class_rec   IN     ZX_API_PUB.EVENT_CLASS_REC_TYPE,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_error_buffer          OUT NOCOPY VARCHAR2) IS

 l_row_count   NUMBER;

 BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
           'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.set_acct_source_tax_rate_id.BEGIN',
           'ZX_TDS_TAX_LINES_DETM_PKG: set_acct_source_tax_rate_id(+)');
  END IF;

  UPDATE zx_detail_tax_lines_gt gt1
     SET account_source_tax_rate_id =
       NVL((SELECT gt2.tax_rate_id
            FROM zx_taxes_b ztb,
                 zx_detail_tax_lines_gt gt2
           WHERE ztb.tax_id = gt1.tax_id
             AND gt2.application_id = gt1.application_id
             AND gt2.entity_code = gt1.entity_code
             AND gt2.event_class_code = gt1.event_class_code
             AND gt2.trx_id = gt1.trx_id
             AND gt2.trx_line_id = gt1.trx_line_id
             AND gt2.trx_level_type = gt1.trx_level_type
             AND gt2.tax_regime_code = ztb.tax_regime_code
             AND gt2.tax = ztb.tax_account_source_tax
             AND rownum=1),account_source_tax_rate_id);
  -- WHERE adjusted_doc_application_id IS NULL;

  l_row_count := SQL%ROWCOUNT;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                  'ZX.PLSQL.ZX_TRL_MANAGE_TAX_PKG.set_acct_source_tax_rate_id',
                  ' number of rows inserted = ' || l_row_count);
  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
           'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.set_acct_source_tax_rate_id.END',
           'ZX_TDS_TAX_LINES_DETM_PKG: set_acct_source_tax_rate_id(-)');
  END IF;

 EXCEPTION
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

     IF (g_level_unexpected >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_unexpected,
              'ZX.PLSQL.ZX_TDS_TAX_LINES_DETM_PKG.set_acct_source_tax_rate_id',
               x_error_buffer);
     END IF;

END set_acct_source_tax_rate_id;

END  ZX_TDS_TAX_LINES_DETM_PKG;

/
