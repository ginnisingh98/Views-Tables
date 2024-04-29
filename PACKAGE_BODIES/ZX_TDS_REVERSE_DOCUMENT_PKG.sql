--------------------------------------------------------
--  DDL for Package Body ZX_TDS_REVERSE_DOCUMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_TDS_REVERSE_DOCUMENT_PKG" AS
 /* $Header: zxdirevdocmtpkgb.pls 120.27.12010000.2 2008/11/18 05:59:25 srajapar ship $ */

 TYPE tax_line_id_tp IS TABLE OF zx_lines.tax_line_id%TYPE INDEX BY BINARY_INTEGER;

 FUNCTION get_tbl_index (
 l_number_tbl      IN            tax_line_id_tp,
 l_number_value    IN            zx_lines.tax_line_id%TYPE,
 x_return_status      OUT NOCOPY VARCHAR2 ) RETURN NUMBER;

 g_current_runtime_level              NUMBER;
 g_level_statement          CONSTANT  NUMBER   := FND_LOG.LEVEL_STATEMENT;
 g_level_procedure          CONSTANT  NUMBER   := FND_LOG.LEVEL_PROCEDURE;
 g_level_event              CONSTANT  NUMBER   := FND_LOG.LEVEL_EVENT;
 g_level_unexpected         CONSTANT  NUMBER   := FND_LOG.LEVEL_UNEXPECTED;

/* ======================================================================*
 | PROCEDURE  reverse_document                                           |
 | This published service creates an exact mirror image of the tax lines |
 | of the reversed event class, for the current (reversing) event calss. |
 | It creates a Detail tax line mirroring the reversing detail tax line  |
 | (Reverse the amount related columns and copy the other details).      |
 * ======================================================================*/

PROCEDURE reverse_document (
 p_event_class_rec IN            ZX_API_PUB.EVENT_CLASS_REC_TYPE,
 x_return_status      OUT NOCOPY VARCHAR2 )
IS

 CURSOR get_sum_tax_line_id_tbl_csr IS
  SELECT summary_tax_line_id,
         zx_lines_summary_s.NEXTVAL,
         reversing_appln_id,
         reversing_entity_code,
         reversing_evnt_cls_code,
         reversing_trx_id,
         trx_number
    FROM
        (SELECT /*+ ORDERED INDEX(hdrgt ZX_REV_TRX_HEADERS_GT_U1)
                    INDEX(lngt ZX_REVERSE_TRX_LINES_GT_U1) */
                DISTINCT
                summ.summary_tax_line_id,
                lngt.reversing_appln_id,
                lngt.reversing_entity_code,
                lngt.reversing_evnt_cls_code,
                lngt.reversing_trx_id,
                hdrgt.trx_number
           FROM zx_rev_trx_headers_gt hdrgt,
                zx_reverse_trx_lines_gt lngt,
                zx_lines_summary summ
          WHERE hdrgt.reversing_appln_id = p_event_class_rec.application_id
            AND hdrgt.reversing_entity_code = p_event_class_rec.entity_code
            AND hdrgt.reversing_evnt_cls_code = p_event_class_rec.event_class_code
            AND hdrgt.reversing_trx_id = p_event_class_rec.trx_id
            AND lngt.reversing_trx_id  = hdrgt.reversing_trx_id
            AND lngt.reversing_appln_id = hdrgt.reversing_appln_id
            AND lngt.reversing_entity_code = hdrgt.reversing_entity_code
            AND lngt.reversing_evnt_cls_code = hdrgt.reversing_evnt_cls_code
            AND summ.trx_id = lngt.reversed_trx_id
            AND summ.application_id = lngt.reversed_appln_id
            AND summ.entity_code = lngt.reversed_entity_code
            AND summ.event_class_code = lngt.reversed_evnt_cls_code
            AND EXISTS
                (SELECT /*+ no_unnest */ 1
                   FROM ZX_LINES line
                  WHERE line.summary_tax_line_id = summ.summary_tax_line_id
                    AND line.trx_id = summ.trx_id
                    AND line.application_id = summ.application_id
                    AND line.entity_code = summ.entity_code
                    AND line.event_class_code = summ.event_class_code
                )
        );

 CURSOR get_rev_tax_lines_info_csr IS
        SELECT /*+ ORDERED INDEX(hdrgt ZX_REV_TRX_HEADERS_GT_U1)
                   INDEX(lngt ZX_REVERSE_TRX_LINES_GT_U1) */
               zl.tax_line_id,                      -- from zx_lines
               zx_lines_s.NEXTVAL,                  -- from Sequence
               zl.offset_link_to_tax_line_id,       -- from zx_lines
               zl.summary_tax_line_id,              -- from zx_lines
               lngt.reversing_appln_id,             -- from line gt
               lngt.reversing_entity_code,          -- from line gt
               lngt.reversing_evnt_cls_code,        -- from line gt
               lngt.reversing_trx_id,               -- from line gt
               lngt.reversing_trx_line_id,          -- from line gt
               lngt.reversing_trx_level_type,       -- from line gt
               hdrgt.trx_number                     -- from header gt
         FROM  zx_rev_trx_headers_gt hdrgt,
               zx_reverse_trx_lines_gt lngt,
               zx_lines zl
         WHERE hdrgt.reversing_appln_id = p_event_class_rec.application_id
           AND hdrgt.reversing_entity_code = p_event_class_rec.entity_code
           AND hdrgt.reversing_evnt_cls_code = p_event_class_rec.event_class_code
           AND hdrgt.reversing_trx_id = p_event_class_rec.trx_id
           AND lngt.reversing_trx_id  = hdrgt.reversing_trx_id
           AND lngt.reversing_appln_id = hdrgt.reversing_appln_id
           AND lngt.reversing_entity_code = hdrgt.reversing_entity_code
           AND lngt.reversing_evnt_cls_code = hdrgt.reversing_evnt_cls_code
           AND zl.trx_id  = lngt.reversed_trx_id
           AND zl.application_id = lngt.reversed_appln_id
           AND zl.entity_code = lngt.reversed_entity_code
           AND zl.event_class_code = lngt.reversed_evnt_cls_code
           AND zl.trx_line_id = lngt.reversed_trx_line_id
           AND zl.trx_level_type = lngt.reversed_trx_level_type;


 TYPE reversing_appln_id_tp         IS TABLE OF zx_reverse_trx_lines_gt.reversing_appln_id%TYPE INDEX BY BINARY_INTEGER;
 TYPE reversing_entity_code_tp      IS TABLE OF zx_reverse_trx_lines_gt.reversing_entity_code%TYPE INDEX BY BINARY_INTEGER;
 TYPE reversing_evnt_cls_code_tp    IS TABLE OF zx_reverse_trx_lines_gt.reversing_evnt_cls_code%TYPE INDEX BY BINARY_INTEGER;
 TYPE reversing_trx_id_tp           IS TABLE OF zx_reverse_trx_lines_gt.reversing_trx_id%TYPE INDEX BY BINARY_INTEGER;
 TYPE reversing_trx_line_id_tp      IS TABLE OF zx_reverse_trx_lines_gt.reversing_trx_line_id%TYPE INDEX BY BINARY_INTEGER;
 TYPE reversing_trx_level_type_tp   IS TABLE OF zx_reverse_trx_lines_gt.reversing_trx_level_type%TYPE INDEX BY BINARY_INTEGER;
 TYPE trx_number_tp                 IS TABLE OF zx_rev_trx_headers_gt.trx_number%TYPE INDEX BY BINARY_INTEGER;

 l_reversed_tax_line_id_tb          tax_line_id_tp;
 l_reversing_tax_line_id_tb         tax_line_id_tp;
 l_offset_link_to_tx_line_id_tb     tax_line_id_tp;
 l_summary_tax_line_id_tb           tax_line_id_tp;

 l_reversing_appln_id_tb            reversing_appln_id_tp;
 l_reversing_entity_code_tb         reversing_entity_code_tp;
 l_reversing_evnt_cls_code_tb       reversing_evnt_cls_code_tp;
 l_reversing_trx_id_tb              reversing_trx_id_tp;
 l_reversing_trx_line_id_tb         reversing_trx_line_id_tp;
 l_reversing_trx_level_type_tb      reversing_trx_level_type_tp;

 l_trx_number_tb                    trx_number_tp;

 l_index                NUMBER;

 -- for reversing summary tax lines
 --
 l_reversed_sum_tax_line_id_tb      tax_line_id_tp;
 l_reversing_sum_tax_line_id_tb     tax_line_id_tp;

BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_REVERSE_DOCUMENT_PKG.reverse_document.BEGIN',
                   'ZX_TDS_REVERSE_DOCUMENT_PKG.reverse_document(+)');
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- reverse summary tax lines
  -- 1. get all summary_tax_line_ids that need to be reversed,
  --    meanwhile, create summary_tax_line_ids for the reversed
  --    summary tax lines with sequence zx_lines_summary_s
  -- 2. reverse summary tax lines in zx_lines_summary
  --

  IF p_event_class_rec.summarization_flag = 'Y' THEN

    OPEN get_sum_tax_line_id_tbl_csr;

    FETCH get_sum_tax_line_id_tbl_csr BULK COLLECT INTO
     l_reversed_sum_tax_line_id_tb,
     l_reversing_sum_tax_line_id_tb,
     l_reversing_appln_id_tb,
     l_reversing_entity_code_tb,
     l_reversing_evnt_cls_code_tb,
     l_reversing_trx_id_tb,
     l_trx_number_tb;

    CLOSE get_sum_tax_line_id_tbl_csr;

    -- create reversed summary tax lines in zx_lines_summary
    --
    FORALL i IN NVL(l_reversed_sum_tax_line_id_tb.FIRST, 0) ..
                NVL(l_reversed_sum_tax_line_id_tb.LAST, -1)
      INSERT INTO zx_lines_summary
        ( summary_tax_line_id,
          internal_organization_id,
          application_id,
          entity_code,
          event_class_code,
          trx_id,
          trx_number,
          applied_from_application_id,
          applied_from_event_class_code,
          applied_from_entity_code,
          applied_from_trx_id,
          adjusted_doc_application_id,
          adjusted_doc_entity_code,
          adjusted_doc_event_class_code,
          adjusted_doc_trx_id,
          summary_tax_line_number,
          tax_regime_code,
          tax,
          tax_status_code,
          tax_rate_id,
          tax_rate_code,
          tax_rate,
          tax_amt,
          tax_amt_tax_curr,
          tax_amt_funcl_curr,
          tax_jurisdiction_code,
          total_rec_tax_amt,
          total_rec_tax_amt_funcl_curr,
          total_rec_tax_amt_tax_curr,
          total_nrec_tax_amt,
          total_nrec_tax_amt_funcl_curr,
          total_nrec_tax_amt_tax_curr,
          ledger_id,
          legal_entity_id,
          establishment_id,
          currency_conversion_date,
          currency_conversion_type,
          currency_conversion_rate,
          summarization_template_id,
          taxable_basis_formula,
          tax_calculation_formula,
          Historical_Flag,
          Cancel_Flag,
          Delete_Flag,
          Tax_Amt_Included_Flag,
          Compounding_Tax_Flag,
          Self_Assessed_Flag,
          Overridden_Flag,
          Reporting_Only_Flag,
          Associated_Child_Frozen_Flag,
          Copied_From_Other_Doc_Flag,
          Manually_Entered_Flag,
          last_manual_entry,
          Record_Type_Code,
          tax_provider_id,
          Tax_Only_Line_Flag,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login,
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
          applied_from_line_id,
          applied_to_application_id,
          applied_to_event_class_code,
          applied_to_entity_code,
          applied_to_trx_id,
          applied_to_line_id,
          tax_exemption_id,
          tax_rate_before_exemption,
          tax_rate_name_before_exemption,
          exempt_rate_modifier,
          exempt_certificate_number,
          exempt_reason,
          exempt_reason_code,
          tax_rate_before_exception,
          tax_rate_name_before_exception,
          tax_exception_id,
          exception_rate,
          mrc_tax_line_flag,
          content_owner_id,
          object_version_number
        )
        SELECT
          l_reversing_sum_tax_line_id_tb(i), -- new summary_tax_line_id
          internal_organization_id,
          l_reversing_appln_id_tb(i),        -- from rev line gt for application_id
          l_reversing_entity_code_tb(i),     -- from rev line gt for entity_code
          l_reversing_evnt_cls_code_tb(i),   -- from rev line gt for event_class_code
          l_reversing_trx_id_tb(i),          -- from rev line gt for trx_id
          l_trx_number_tb(i),                -- from rev header gt for trx_number,
          applied_from_application_id,
          applied_from_event_class_code,
          applied_from_entity_code,
          applied_from_trx_id,
          adjusted_doc_application_id,
          adjusted_doc_entity_code,
          adjusted_doc_event_class_code,
          adjusted_doc_trx_id,
          summary_tax_line_number,
          tax_regime_code,
          tax,
          tax_status_code,
          tax_rate_id,
          tax_rate_code,
          tax_rate,
          -tax_amt,                         -- reversed the amount
          -tax_amt_tax_curr,                -- reversed the amount
          -tax_amt_funcl_curr,              -- reversed the amount
          tax_jurisdiction_code,
          -total_rec_tax_amt,               -- reversed the amount
          -total_rec_tax_amt_funcl_curr,    -- reversed the amount
          -total_rec_tax_amt_tax_curr,      -- reversed the amount
          -total_nrec_tax_amt,              -- reversed the amount
          -total_nrec_tax_amt_funcl_curr,   -- reversed the amount
          -total_nrec_tax_amt_tax_curr,     -- reversed the amount
          ledger_id,
          legal_entity_id,
          establishment_id,
          currency_conversion_date,
          currency_conversion_type,
          currency_conversion_rate,
          summarization_template_id,
          taxable_basis_formula,
          tax_calculation_formula,
          Historical_Flag,
          Cancel_Flag,
          Delete_Flag,
          Tax_Amt_Included_Flag,
          Compounding_Tax_Flag,
          Self_Assessed_Flag,
          Overridden_Flag,
          Reporting_Only_Flag,
          Associated_Child_Frozen_Flag,
          Copied_From_Other_Doc_Flag,
          Manually_Entered_Flag,
          last_manual_entry,
          Record_Type_Code,
          tax_provider_id,
          Tax_Only_Line_Flag,
          fnd_global.user_id,               -- created_by,
          sysdate,                          -- creation_date,
          fnd_global.user_id,               -- last_updated_by,
          sysdate,                          -- last_update_date,
          fnd_global.login_id,              -- last_update_login,
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
          applied_from_line_id,
          applied_to_application_id,
          applied_to_event_class_code,
          applied_to_entity_code,
          applied_to_trx_id,
          applied_to_line_id,
          tax_exemption_id,
          tax_rate_before_exemption,
          tax_rate_name_before_exemption,
          exempt_rate_modifier,
          exempt_certificate_number,
          exempt_reason,
          exempt_reason_code,
          tax_rate_before_exception,
          tax_rate_name_before_exception,
          tax_exception_id,
          exception_rate,
          mrc_tax_line_flag,
          content_owner_id,
          1
    FROM  zx_lines_summary
   WHERE  summary_tax_line_id = l_reversed_sum_tax_line_id_tb(i);

  -- initialize the following data structures because they will be reused in
  -- reversing detail tax lines
  --
    l_reversing_trx_id_tb.DELETE;
    l_reversing_appln_id_tb.DELETE;
    l_reversing_entity_code_tb.DELETE;
    l_reversing_evnt_cls_code_tb.DELETE;
    l_reversing_trx_level_type_tb.DELETE;
    l_trx_number_tb.DELETE;

  END IF;   --  of summarization_flag = 'Y'

  -- For detail tax lines in reversed document:
  -- 1. tax_line_id has new value form sequence zx_lines_s, stored in
  --    l_reversed_tax_line_id_tb.
  -- 2. All the amount related columns have values reversed from
  --    the reversing document.
  -- 3. Some columns(16) have new values from zx_rev_trx_headers_gt.
  -- 4. Some columns(11) have new values from zx_reverse_trx_lines_gt.
  -- 5. WHO columns(5) have new values with current user and sysdate.
  -- 6. if a tax line has a offset_link_to_tax_line_id, the new value of this
  --     column will point to the new reversed detail tax line.
  -- 7. if a tax line has a summary_tax_line_id, the new value of this
  --     column will point to the new reversed summary tax line.
  -- 8. All the other columns have values copied from the reversing document.
  --
  OPEN get_rev_tax_lines_info_csr;

  FETCH get_rev_tax_lines_info_csr BULK COLLECT INTO
    l_reversed_tax_line_id_tb,
    l_reversing_tax_line_id_tb,
    l_offset_link_to_tx_line_id_tb,
    l_summary_tax_line_id_tb,
    l_reversing_appln_id_tb,
    l_reversing_entity_code_tb,
    l_reversing_evnt_cls_code_tb,
    l_reversing_trx_id_tb,
    l_reversing_trx_line_id_tb,
    l_reversing_trx_level_type_tb,
    l_trx_number_tb;

  CLOSE get_rev_tax_lines_info_csr;

  -- Update offset_link_to_tax_line_id of a tax line if it is not NULL:
  -- 1. get l_index of tax_line_id from l_reversing_tax_line_id_tb with
  --    l_offset_link_to_tx_line_id_tb(i).
  -- 2. get the reversed tax line id from l_reversed_tax_line_id_tb with this
  --    l_index
  -- 3. update l_offset_link_to_tx_line_id_tb(i) in the reversed tax line with
  --    l_reversed_tax_line_id_tb(l_index).
  --
  FOR i IN NVL(l_offset_link_to_tx_line_id_tb.FIRST, 0) ..
           NVL(l_offset_link_to_tx_line_id_tb.LAST, -1)
  LOOP
    IF l_offset_link_to_tx_line_id_tb(i) IS NOT NULL THEN
       l_index := get_tbl_index(
                           l_reversed_tax_line_id_tb,
                           l_offset_link_to_tx_line_id_tb(i),
                           x_return_status );
       IF l_index IS NOT NULL THEN
         l_offset_link_to_tx_line_id_tb(i) := l_reversing_tax_line_id_tb(l_index);
       END IF;
    END IF;
  END LOOP;

  -- Update summary_tax_line_id a tax line if it is not NULL:
  -- 1. get l_index of summary_tax_line_id from l_reversing_sum_tax_line_id_tb
  --    with l_summary_tax_line_id_tb(i).
  -- 2. get the reversed summary tax line id from l_reversed_sum_tax_line_id_tb
  --    with this l_index.
  -- 3. update l_summary_tax_line_id_tb(i) in the reversed tax line with
  --    l_reversed_sum_tax_line_id_tb(l_index).
  --
  IF p_event_class_rec.summarization_flag = 'Y' THEN
    FOR i IN NVL(l_summary_tax_line_id_tb.FIRST, 0) ..
             NVL(l_summary_tax_line_id_tb.LAST, -1)
    LOOP
      IF l_summary_tax_line_id_tb(i) IS NOT NULL THEN
         l_index := get_tbl_index(
                             l_reversed_sum_tax_line_id_tb,
                             l_summary_tax_line_id_tb(i),
                             x_return_status );
         IF l_index IS NOT NULL THEN
           l_summary_tax_line_id_tb(i) := l_reversing_sum_tax_line_id_tb(l_index);
        END IF;
      END IF;
    END LOOP;
  END IF;

  -- create reversed detail tax lines in zx_lines
  --
  FORALL i IN NVL(l_reversing_tax_line_id_tb.FIRST, 0) ..
              NVL(l_reversing_tax_line_id_tb.LAST, -1)
    INSERT INTO zx_lines (
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
           tax_rate_type,
           interface_entity_code,
           interface_tax_line_id,
           taxing_juris_geography_id,
           adjusted_doc_tax_line_id,
           object_version_number,
           reversed_tax_line_id,
           account_source_tax_rate_id
           )
    SELECT
           l_reversing_tax_line_id_tb(i),     -- tax_line_id,
           zl.internal_organization_id,
           l_reversing_appln_id_tb(i),        -- from line gt for application_id
           l_reversing_entity_code_tb(i),     -- from line gt for entity_code
           l_reversing_evnt_cls_code_tb(i),   -- from line gt for event_class_code
           zl.event_type_code,
           l_reversing_trx_id_tb(i),          -- from line gt for trx_id,
           l_reversing_trx_line_id_tb(i),     -- from line gt for trx_line_id,
           l_reversing_trx_level_type_tb(i),  -- from line gt for trx_level_type,
           zl.trx_line_number,
           zl.doc_event_status,
           zl.tax_event_class_code,
           zl.tax_event_type_code,
           zl.tax_line_number,
           zl.content_owner_id,
           zl.tax_regime_id,
           zl.tax_regime_code,
           zl.tax_id,
           zl.tax,
           zl.tax_status_id,
           zl.tax_status_code,
           zl.tax_rate_id,
           zl.tax_rate_code,
           zl.tax_rate,
           zl.tax_apportionment_line_number,
           zl.trx_id_level2,
           zl.trx_id_level3,
           zl.trx_id_level4,
           zl.trx_id_level5,
           zl.trx_id_level6,
           zl.trx_user_key_level1,
           zl.trx_user_key_level2,
           zl.trx_user_key_level3,
           zl.trx_user_key_level4,
           zl.trx_user_key_level5,
           zl.trx_user_key_level6,
           zl.mrc_tax_line_flag,
           zl.ledger_id,
           zl.establishment_id,
           zl.legal_entity_id,
           zl.legal_entity_tax_reg_number,
           zl.hq_estb_reg_number,
           zl.hq_estb_party_tax_prof_id,
           zl.currency_conversion_date,
           zl.currency_conversion_type,
           zl.currency_conversion_rate,
           zl.tax_currency_conversion_date,
           zl.tax_currency_conversion_type,
           zl.tax_currency_conversion_rate,
           zl.trx_currency_code,
           zl.minimum_accountable_unit,
           zl.precision,
           l_trx_number_tb(i),                -- from header gt for trx_number,
           zl.trx_date,
           zl.unit_price,
           -zl.line_amt,                      -- reversed the amount
           zl.trx_line_quantity,
           zl.tax_base_modifier_rate,
           zl.ref_doc_application_id,
           zl.ref_doc_entity_code,
           zl.ref_doc_event_class_code,
           zl.ref_doc_trx_id,
           zl.ref_doc_line_id,
           zl.ref_doc_line_quantity,
           -zl.other_doc_line_amt,            -- reverse the amount
           -zl.other_doc_line_tax_amt,        -- reverse the amount
           -zl.other_doc_line_taxable_amt,    -- reverse the amount
           -zl.unrounded_taxable_amt,         -- reverse the amount
           -zl.unrounded_tax_amt,             -- reverse the amount
           zl.related_doc_application_id,
           zl.related_doc_entity_code,
           zl.related_doc_event_class_code,
           zl.related_doc_trx_id,
           zl.related_doc_number,
           zl.related_doc_date,
           zl.applied_from_application_id,
           zl.applied_from_event_class_code,
           zl.applied_from_entity_code,
           zl.applied_from_trx_id,
           zl.applied_from_line_id,
           zl.applied_from_trx_number,
           zl.adjusted_doc_application_id,
           zl.adjusted_doc_entity_code,
           zl.adjusted_doc_event_class_code,
           zl.adjusted_doc_trx_id,
           zl.adjusted_doc_line_id,
           zl.adjusted_doc_number,
           zl.adjusted_doc_date,
           zl.applied_to_application_id,
           zl.applied_to_event_class_code,
           zl.applied_to_entity_code,
           zl.applied_to_trx_id,
           zl.applied_to_line_id,
           zl.applied_to_trx_number,
           l_summary_tax_line_id_tb(i),       -- zl.summary_tax_line_id,
           l_offset_link_to_tx_line_id_tb(i), -- zl.offset_link_to_tax_line_id,
           zl.offset_flag,
           zl.process_for_recovery_flag,
           zl.tax_jurisdiction_id,
           zl.tax_jurisdiction_code,
           zl.place_of_supply,
           zl.place_of_supply_type_code,
           zl.place_of_supply_result_id,
           zl.tax_date_rule_id,
           zl.tax_date,
           zl.tax_determine_date,
           zl.tax_point_date,
           zl.trx_line_date,
           zl.tax_type_code,
           zl.tax_code,
           zl.tax_registration_id,
           zl.tax_registration_number,
           zl.registration_party_type,
           zl.rounding_level_code,
           zl.rounding_rule_code,
           zl.rounding_lvl_party_tax_prof_id,
           zl.rounding_lvl_party_type,
           zl.compounding_tax_flag,
           zl.orig_tax_status_id,
           zl.orig_tax_status_code,
           zl.orig_tax_rate_id,
           zl.orig_tax_rate_code,
           zl.orig_tax_rate,
           zl.orig_tax_jurisdiction_id,
           zl.orig_tax_jurisdiction_code,
           zl.orig_tax_amt_included_flag,
           zl.orig_self_assessed_flag,
           zl.tax_currency_code,
           -zl.tax_amt,                       -- reverse the amount
           -zl.tax_amt_tax_curr,              -- reverse the amount
           -zl.tax_amt_funcl_curr,            -- reverse the amount
           -zl.taxable_amt,                   -- reverse the amount
           -zl.taxable_amt_tax_curr,          -- reverse the amount
           -zl.taxable_amt_funcl_curr,        -- reverse the amount
           -zl.orig_taxable_amt,              -- reverse the amount
           -zl.orig_taxable_amt_tax_curr,     -- reverse the amount
           -zl.cal_tax_amt,                   -- reverse the amount
           -zl.cal_tax_amt_tax_curr,          -- reverse the amount
           -zl.cal_tax_amt_funcl_curr,        -- reverse the amount
           -zl.orig_tax_amt,                  -- reverse the amount
           -zl.orig_tax_amt_tax_curr,         -- reverse the amount
           -zl.rec_tax_amt,                   -- reverse the amount
           -zl.rec_tax_amt_tax_curr,          -- reverse the amount
           -zl.rec_tax_amt_funcl_curr,        -- reverse the amount
           -zl.nrec_tax_amt,                  -- reverse the amount
           -zl.nrec_tax_amt_tax_curr,         -- reverse the amount
           -zl.nrec_tax_amt_funcl_curr,       -- reverse the amount
           zl.tax_exemption_id,
           zl.tax_rate_before_exemption,
           zl.tax_rate_name_before_exemption,
           zl.exempt_rate_modifier,
           zl.exempt_certificate_number,
           zl.exempt_reason,
           zl.exempt_reason_code,
           zl.tax_exception_id,
           zl.tax_rate_before_exception,
           zl.tax_rate_name_before_exception,
           zl.exception_rate,
           zl.tax_apportionment_flag,
           zl.historical_flag,
           zl.taxable_basis_formula,
           zl.tax_calculation_formula,
           zl.cancel_flag,
           zl.purge_flag,
           zl.delete_flag,
           zl.tax_amt_included_flag,
           zl.self_assessed_flag,
           zl.overridden_flag,
           zl.manually_entered_flag,
           zl.freeze_until_overridden_flag,
           zl.copied_from_other_doc_flag,
           zl.recalc_required_flag,
           zl.settlement_flag,
           zl.item_dist_changed_flag,
           zl.associated_child_frozen_flag,
           zl.tax_only_line_flag,
           zl.compounding_dep_tax_flag,
           zl.last_manual_entry,
           zl.tax_provider_id,
           zl.record_type_code,
           zl.reporting_period_id,
           zl.legal_message_appl_2,
           zl.legal_message_status,
           zl.legal_message_rate,
           zl.legal_message_basis,
           zl.legal_message_calc,
           zl.legal_message_threshold,
           zl.legal_message_pos,
           zl.legal_message_trn,
           zl.legal_message_exmpt,
           zl.legal_message_excpt,
           zl.tax_regime_template_id,
           zl.tax_applicability_result_id,
           zl.direct_rate_result_id,
           zl.status_result_id,
           zl.rate_result_id,
           zl.basis_result_id,
           zl.thresh_result_id,
           zl.calc_result_id,
           zl.tax_reg_num_det_result_id,
           zl.eval_exmpt_result_id,
           zl.eval_excpt_result_id,
           zl.enforce_from_natural_acct_flag,
           zl.tax_hold_code,
           zl.tax_hold_released_code,
           -zl.prd_total_tax_amt,             -- reverse the amount
           -zl.prd_total_tax_amt_tax_curr,    -- reverse the amount
           -zl.prd_total_tax_amt_funcl_curr,  -- reverse the amount
           zl.internal_org_location_id,
           zl.attribute_category,
           zl.attribute1,
           zl.attribute2,
           zl.attribute3,
           zl.attribute4,
           zl.attribute5,
           zl.attribute6,
           zl.attribute7,
           zl.attribute8,
           zl.attribute9,
           zl.attribute10,
           zl.attribute11,
           zl.attribute12,
           zl.attribute13,
           zl.attribute14,
           zl.attribute15,
           zl.global_attribute_category,
           zl.global_attribute1,
           zl.global_attribute2,
           zl.global_attribute3,
           zl.global_attribute4,
           zl.global_attribute5,
           zl.global_attribute6,
           zl.global_attribute7,
           zl.global_attribute8,
           zl.global_attribute9,
           zl.global_attribute10,
           zl.global_attribute11,
           zl.global_attribute12,
           zl.global_attribute13,
           zl.global_attribute14,
           zl.global_attribute15,
           zl.numeric1,
           zl.numeric2,
           zl.numeric3,
           zl.numeric4,
           zl.numeric5,
           zl.numeric6,
           zl.numeric7,
           zl.numeric8,
           zl.numeric9,
           zl.numeric10,
           zl.char1,
           zl.char2,
           zl.char3,
           zl.char4,
           zl.char5,
           zl.char6,
           zl.char7,
           zl.char8,
           zl.char9,
           zl.char10,
           zl.date1,
           zl.date2,
           zl.date3,
           zl.date4,
           zl.date5,
           zl.date6,
           zl.date7,
           zl.date8,
           zl.date9,
           zl.date10,
           fnd_global.user_id,                -- created_by
           sysdate,                           -- creation_date
           fnd_global.user_id,                -- last_updated_by
           sysdate,                           -- last_update_date
           fnd_global.login_id,               -- last_update_login
           zl.line_assessable_value,
           zl.legal_justification_text1,
           zl.legal_justification_text2,
           zl.legal_justification_text3,
           zl.reporting_currency_code,
           zl.trx_line_index,
           zl.offset_tax_rate_code,
           zl.proration_code,
           zl.other_doc_source,
           zl.reporting_only_flag,
           zl.ctrl_total_line_tx_amt,
           zl.tax_rate_type,
           zl.interface_entity_code,
           zl.interface_tax_line_id,
           zl.taxing_juris_geography_id,
           zl.adjusted_doc_tax_line_id,
           1,
           zl.tax_line_id,                    -- reversed_tax_line_id
           zl.account_source_tax_rate_id
      FROM zx_lines zl
     WHERE tax_line_id = l_reversed_tax_line_id_tb(i);

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_REVERSE_DOCUMENT_PKG.reverse_document',
                   'RETURN_STATUS = ' || x_return_status);
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_REVERSE_DOCUMENT_PKG.reverse_document.END',
                   'ZX_TDS_REVERSE_DOCUMENT_PKG.reverse_document(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_REVERSE_DOCUMENT_PKG.reverse_document',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TDS_REVERSE_DOCUMENT_PKG.reverse_document',
                     'reverse_document(-)');
    END IF;

END reverse_document;

/* ======================================================================*
 | PROCEDURE  get_tbl_index                                              |
 | This function return the table index if a value l_number_value exists |
 | in the plsql data structure l_number_tbl. It returns NULL if          |
 | l_number_value does not esist in l_number_tbl                         |
 * ======================================================================*/
 FUNCTION get_tbl_index (
 l_number_tbl   IN         tax_line_id_tp,
 l_number_value   IN         zx_lines.tax_line_id%TYPE,
 x_return_status        OUT NOCOPY VARCHAR2
 ) RETURN NUMBER IS

 l_return_index NUMBER;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_REVERSE_DOCUMENT_PKG.get_tbl_index.BEGIN',
                   'ZX_TDS_REVERSE_DOCUMENT_PKG.get_tbl_index(+)');
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

   l_return_index := NULL;

   FOR i IN NVL(l_number_tbl.FIRST, 0) .. NVL(l_number_tbl.LAST, -1) LOOP
     IF l_number_value = l_number_tbl(i) THEN
       l_return_index := i;
       EXIT;
     END IF;
   END LOOP;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_REVERSE_DOCUMENT_PKG.get_tbl_index',
                   'RETURN_STATUS = ' || x_return_status);
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TDS_REVERSE_DOCUMENT_PKG.get_tbl_index.END',
                   'ZX_TDS_REVERSE_DOCUMENT_PKG.get_tbl_index(-)');
  END IF;

  RETURN l_return_index;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_TDS_REVERSE_DOCUMENT_PKG.get_tbl_index',
                     sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_TDS_REVERSE_DOCUMENT_PKG.get_tbl_index',
                    'get_tbl_index(-)');
    END IF;
END get_tbl_index;

END ZX_TDS_REVERSE_DOCUMENT_PKG;


/
