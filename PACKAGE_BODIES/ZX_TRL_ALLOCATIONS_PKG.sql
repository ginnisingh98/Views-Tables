--------------------------------------------------------
--  DDL for Package Body ZX_TRL_ALLOCATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_TRL_ALLOCATIONS_PKG" AS
/* $Header: zxriallocatnpkgb.pls 120.23.12010000.6 2010/03/26 00:49:48 skorrapa ship $ */

  g_current_runtime_level NUMBER;
  g_level_statement       CONSTANT  NUMBER := FND_LOG.LEVEL_STATEMENT;
  g_level_procedure       CONSTANT  NUMBER := FND_LOG.LEVEL_PROCEDURE;
  g_level_event           CONSTANT  NUMBER := FND_LOG.LEVEL_EVENT;
  g_level_unexpected      CONSTANT  NUMBER := FND_LOG.LEVEL_UNEXPECTED;

  PROCEDURE Insert_Row
       (X_Rowid                    IN OUT NOCOPY VARCHAR2,
        p_summary_tax_line_id                    NUMBER,
        p_internal_organization_id               NUMBER,
        p_application_id                         NUMBER,
        p_entity_code                            VARCHAR2,
        p_event_class_code                       VARCHAR2,
        p_event_type_code                        VARCHAR2,
        p_trx_line_number                        NUMBER,--
        p_trx_id                                 NUMBER,
        p_trx_number                             VARCHAR2,--
        p_trx_line_id                            NUMBER,--
        p_trx_level_type                         VARCHAR2,
        p_line_amt                               NUMBER,--
        p_trx_line_date                          DATE,--
        p_tax_regime_code                        VARCHAR2,
        p_tax                                    VARCHAR2,
        p_tax_jurisdiction_code                  VARCHAR2,
        p_tax_status_code                        VARCHAR2,
        p_tax_rate_id                            NUMBER,
        p_tax_rate_code                          VARCHAR2,
        p_tax_rate                               NUMBER,
        p_tax_amt                                NUMBER,
        p_enabled_record                         VARCHAR2,
        p_manually_entered_flag                  VARCHAR2,
        p_content_owner_id                       NUMBER,
        p_record_type_code                       VARCHAR2,
        p_last_manual_entry                      VARCHAR2,
        p_trx_line_amt                           NUMBER,
        p_tax_amt_included_flag                  VARCHAR2,
        p_self_assessed_flag                     VARCHAR2,
        p_tax_only_line_flag                     VARCHAR2,
        p_created_by                             NUMBER,
        p_creation_date                          DATE,
        p_last_updated_by                        NUMBER,
        p_last_update_date                       DATE,
        p_last_update_login                      NUMBER) IS

    l_tax_line_id      NUMBER;
    l_tax_line_number  NUMBER;
    l_minimum_accountable_unit NUMBER;
    l_precision NUMBER;
    l_trx_currency_code VARCHAR2(20);

  BEGIN

    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_ALLOCATIONS_PKG.Insert_Row.BEGIN',
                     'Insert_Row (+)');
    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_ALLOCATIONS_PKG.Insert_Row',
                     'Insert into zx_lines for allocation of lines. (+)');
    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_ALLOCATIONS_PKG.Insert_Row',
                     'Is Record enabled: '|| p_enabled_record);

      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_ALLOCATIONS_PKG.Insert_Row',
                     'Summary Tax Line Id: '|| to_char(p_summary_tax_line_id));

      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_ALLOCATIONS_PKG.Insert_Row',
                     'Trx Id: '|| to_char(p_trx_id));
    END IF;

    IF p_enabled_record ='Y' THEN
      SELECT NVL(max(TAX_LINE_NUMBER),0)+1
      INTO l_tax_line_number
      FROM ZX_LINES
      WHERE APPLICATION_ID    = p_application_id
      AND EVENT_CLASS_CODE    = p_event_class_code
      AND ENTITY_CODE         = p_entity_code
      AND TRX_ID              = p_trx_id
      AND TRX_LINE_ID         = p_trx_line_id
      AND TRX_LEVEL_TYPE      = p_trx_level_type;

      SELECT zx_lines_s.nextval
      INTO l_tax_line_id
      FROM dual;

      SELECT distinct precision,minimum_accountable_unit,trx_currency_code
       INTO  l_precision, l_minimum_accountable_unit, l_trx_currency_code
      FROM zx_lines_det_factors zxd, zx_lines_summary zxs
      WHERE zxd.trx_id = zxs.trx_id
      AND zxs.summary_tax_line_id = p_summary_tax_line_id;


      ZX_TRL_DETAIL_OVERRIDE_PKG.Insert_row
       (x_rowid                          => X_Rowid,
        p_tax_line_id                    => l_tax_line_id,
        p_internal_organization_id       => p_internal_organization_id,
        p_application_id                 => p_application_id,
        p_entity_code                    => p_entity_code,
        p_event_class_code               => p_event_class_code,
        p_event_type_code                => NULL,
        p_trx_id                         => p_trx_id,
        p_trx_line_id                    => p_trx_line_id,
        p_trx_level_type                 => p_trx_level_type,
        p_trx_line_number                => p_trx_line_number,
        p_doc_event_status               => NULL,
        p_tax_event_class_code           => NULL,
        p_tax_event_type_code            => NULL,
        p_tax_line_number                => l_tax_line_number,
        p_content_owner_id               => p_content_owner_id,
        p_tax_regime_id                  => NULL,
        p_tax_regime_code                => p_tax_regime_code,
        p_tax_id                         => NULL,
        p_tax                            => p_tax,
        p_tax_status_id                  => NULL,
        p_tax_status_code                => p_tax_status_code,
        p_tax_rate_id                    => p_tax_rate_id,
        p_tax_rate_code                  => p_tax_rate_code,
        p_tax_rate                       => p_tax_rate,
        p_tax_rate_type                  => NULL,
        p_tax_apportionment_line_num     => NULL,
        p_trx_id_level2                  => NULL,
        p_trx_id_level3                  => NULL,
        p_trx_id_level4                  => NULL,
        p_trx_id_level5                  => NULL,
        p_trx_id_level6                  => NULL,
        p_trx_user_key_level1            => NULL,
        p_trx_user_key_level2            => NULL,
        p_trx_user_key_level3            => NULL,
        p_trx_user_key_level4            => NULL,
        p_trx_user_key_level5            => NULL,
        p_trx_user_key_level6            => NULL,
        p_mrc_tax_line_flag              => 'N',
        p_mrc_link_to_tax_line_id        => NULL,
        p_ledger_id                      => NULL,
        p_establishment_id               => NULL,
        p_legal_entity_id                => NULL,
        --p_legal_entity_tax_reg_number    => NULL,
        p_hq_estb_reg_number             => NULL,
        p_hq_estb_party_tax_prof_id      => NULL,
        p_currency_conversion_date       => NULL,
        p_currency_conversion_type       => NULL,
        p_currency_conversion_rate       => NULL,
        p_tax_curr_conversion_date       => NULL,
        p_tax_curr_conversion_type       => NULL,
        p_tax_curr_conversion_rate       => NULL,
        p_trx_currency_code              => l_trx_currency_code,
        p_reporting_currency_code        => NULL,
        p_minimum_accountable_unit       => l_minimum_accountable_unit,
        p_precision                      => l_precision,
        p_trx_number                     => p_trx_number,
        p_trx_date                       => NULL,
        p_unit_price                     => NULL,
        p_line_amt                       => p_trx_line_amt,
        p_trx_line_quantity              => NULL,
        p_tax_base_modifier_rate         => NULL,
        p_ref_doc_application_id         => NULL,
        p_ref_doc_entity_code            => NULL,
        p_ref_doc_event_class_code       => NULL,
        p_ref_doc_trx_id                 => NULL,
        p_ref_doc_trx_level_type         => NULL,
        p_ref_doc_line_id                => NULL,
        p_ref_doc_line_quantity          => NULL,
        p_other_doc_line_amt             => NULL,
        p_other_doc_line_tax_amt         => NULL,
        p_other_doc_line_taxable_amt     => NULL,
        p_unrounded_taxable_amt          => p_trx_line_amt,
        p_unrounded_tax_amt              => p_tax_amt,
        p_related_doc_application_id     => NULL,
        p_related_doc_entity_code        => NULL,
        p_related_doc_evt_class_code     => NULL,
        p_related_doc_trx_id             => NULL,
        p_related_doc_trx_level_type     => NULL,
        p_related_doc_number             => NULL,
        p_related_doc_date               => NULL,
        p_applied_from_appl_id           => NULL,
        p_applied_from_evt_clss_code     => NULL,
        p_applied_from_entity_code       => NULL,
        p_applied_from_trx_id            => NULL,
        p_applied_from_trx_level_type    => NULL,
        p_applied_from_line_id           => NULL,
        p_applied_from_trx_number        => NULL,
        p_adjusted_doc_appln_id          => NULL,
        p_adjusted_doc_entity_code       => NULL,
        p_adjusted_doc_evt_clss_code     => NULL,
        p_adjusted_doc_trx_id            => NULL,
        p_adjusted_doc_trx_level_type    => NULL,
        p_adjusted_doc_line_id           => NULL,
        p_adjusted_doc_number            => NULL,
        p_adjusted_doc_date              => NULL,
        p_applied_to_application_id      => NULL,
        p_applied_to_evt_class_code      => NULL,
        p_applied_to_entity_code         => NULL,
        p_applied_to_trx_id              => NULL,
        p_applied_to_trx_level_type      => NULL,
        p_applied_to_line_id             => NULL,
        p_summary_tax_line_id            => p_summary_tax_line_id,
        p_offset_link_to_tax_line_id     => NULL,
        p_offset_flag                    => 'N',
        p_process_for_recovery_flag      => 'N',
        p_tax_jurisdiction_id            => NULL,
        p_tax_jurisdiction_code          => p_tax_jurisdiction_code,
        p_place_of_supply                => NULL,
        p_place_of_supply_type_code      => NULL,
        p_place_of_supply_result_id      => NULL,
        p_tax_date_rule_id               => NULL,
        p_tax_date                       => NULL,
        p_tax_determine_date             => sysdate,
        p_tax_point_date                 => NULL,
        p_trx_line_date                  => p_trx_line_date,
        p_tax_type_code                  => NULL,
        p_tax_code                       => NULL,
        p_tax_registration_id            => NULL,
        p_tax_registration_number        => NULL,
        p_registration_party_type        => NULL,
        p_rounding_level_code            => 'HEADER',
        p_rounding_rule_code             => NULL,
        p_rndg_lvl_party_tax_prof_id     => NULL,
        p_rounding_lvl_party_type        => NULL,
        p_compounding_tax_flag           => 'N',
        p_orig_tax_status_id             => NULL,
        p_orig_tax_status_code           => NULL,
        p_orig_tax_rate_id               => NULL,
        p_orig_tax_rate_code             => NULL,
        p_orig_tax_rate                  => NULL,
        p_orig_tax_jurisdiction_id       => NULL,
        p_orig_tax_jurisdiction_code     => NULL,
        p_orig_tax_amt_included_flag     => 'N',
        p_orig_self_assessed_flag        => 'N',
        p_tax_currency_code              => NULL,
        p_tax_amt                        => p_tax_amt,
        p_tax_amt_tax_curr               => NULL,
        p_tax_amt_funcl_curr             => NULL,
        p_taxable_amt                    => NULL,
        p_taxable_amt_tax_curr           => NULL,
        p_taxable_amt_funcl_curr         => NULL,
        p_orig_taxable_amt               => NULL,
        p_orig_taxable_amt_tax_curr      => NULL,
        p_cal_tax_amt                    => NULL,
        p_cal_tax_amt_tax_curr           => NULL,
        p_cal_tax_amt_funcl_curr         => NULL,
        p_orig_tax_amt                   => NULL,
        p_orig_tax_amt_tax_curr          => NULL,
        p_rec_tax_amt                    => NULL,
        p_rec_tax_amt_tax_curr           => NULL,
        p_rec_tax_amt_funcl_curr         => NULL,
        p_nrec_tax_amt                   => NULL,
        p_nrec_tax_amt_tax_curr          => NULL,
        p_nrec_tax_amt_funcl_curr        => NULL,
        p_tax_exemption_id               => NULL,
        p_tax_rate_before_exemption      => NULL,
        p_tax_rate_name_before_exempt    => NULL,
        p_exempt_rate_modifier           => NULL,
        p_exempt_certificate_number      => NULL,
        p_exempt_reason                  => NULL,
        p_exempt_reason_code             => NULL,
        p_tax_exception_id               => NULL,
        p_tax_rate_before_exception      => NULL,
        p_tax_rate_name_before_except    => NULL,
        p_exception_rate                 => NULL,
        p_tax_apportionment_flag         => 'N',
        p_historical_flag                => 'N',
        p_taxable_basis_formula          => NULL,
        p_tax_calculation_formula        => NULL,
        p_cancel_flag                    => 'N',
        p_purge_flag                     => 'N',
        p_delete_flag                    => 'N',
        p_tax_amt_included_flag          => p_tax_amt_included_flag,
        p_self_assessed_flag             => p_self_assessed_flag,
        p_overridden_flag                => 'N',
        p_manually_entered_flag          => p_manually_entered_flag,
        p_reporting_only_flag            => 'N',
        p_freeze_until_overriddn_flg     => 'N',
        p_copied_from_other_doc_flag     => 'N',
        p_recalc_required_flag           => 'Y',
        p_settlement_flag                => 'N',
        p_item_dist_changed_flag         => 'N',
        p_assoc_children_frozen_flg      => 'N',
        p_tax_only_line_flag             => p_tax_only_line_flag,
        p_compounding_dep_tax_flag       => 'N',
        p_compounding_tax_miss_flag      => 'N',
        p_sync_with_prvdr_flag           => 'N',
        p_last_manual_entry              => p_last_manual_entry,
        p_tax_provider_id                => NULL,
        p_record_type_code               => p_record_type_code,
        p_reporting_period_id            => NULL,
        p_legal_justification_text1      => NULL,
        p_legal_justification_text2      => NULL,
        p_legal_justification_text3      => NULL,
        p_legal_message_appl_2           => NULL,
        p_legal_message_status           => NULL,
        p_legal_message_rate             => NULL,
        p_legal_message_basis            => NULL,
        p_legal_message_calc             => NULL,
        p_legal_message_threshold        => NULL,
        p_legal_message_pos              => NULL,
        p_legal_message_trn              => NULL,
        p_legal_message_exmpt            => NULL,
        p_legal_message_excpt            => NULL,
        p_tax_regime_template_id         => NULL,
        p_tax_applicability_result_id    => NULL,
        p_direct_rate_result_id          => NULL,
        p_status_result_id               => NULL,
        p_rate_result_id                 => NULL,
        p_basis_result_id                => NULL,
        p_thresh_result_id               => NULL,
        p_calc_result_id                 => NULL,
        p_tax_reg_num_det_result_id      => NULL,
        p_eval_exmpt_result_id           => NULL,
        p_eval_excpt_result_id           => NULL,
        p_enforced_from_nat_acct_flg     => 'N',
        p_tax_hold_code                  => NULL,
        p_tax_hold_released_code         => NULL,
        p_prd_total_tax_amt              => NULL,
        p_prd_total_tax_amt_tax_curr     => NULL,
        p_prd_total_tax_amt_funcl_curr   => NULL,
        p_trx_line_index                 => NULL,
        p_offset_tax_rate_code           => NULL,
        p_proration_code                 => NULL,
        p_other_doc_source               => NULL,
        p_internal_org_location_id       => NULL,
        p_line_assessable_value          => NULL,
        p_ctrl_total_line_tx_amt         => NULL,
        p_applied_to_trx_number          => NULL,
        p_attribute_category             => NULL,
        p_attribute1                     => NULL,
        p_attribute2                     => NULL,
        p_attribute3                     => NULL,
        p_attribute4                     => NULL,
        p_attribute5                     => NULL,
        p_attribute6                     => NULL,
        p_attribute7                     => NULL,
        p_attribute8                     => NULL,
        p_attribute9                     => NULL,
        p_attribute10                    => NULL,
        p_attribute11                    => NULL,
        p_attribute12                    => NULL,
        p_attribute13                    => NULL,
        p_attribute14                    => NULL,
        p_attribute15                    => NULL,
        p_global_attribute_category      => NULL,
        p_global_attribute1              => NULL,
        p_global_attribute2              => NULL,
        p_global_attribute3              => NULL,
        p_global_attribute4              => NULL,
        p_global_attribute5              => NULL,
        p_global_attribute6              => NULL,
        p_global_attribute7              => NULL,
        p_global_attribute8              => NULL,
        p_global_attribute9              => NULL,
        p_global_attribute10             => NULL,
        p_global_attribute11             => NULL,
        p_global_attribute12             => NULL,
        p_global_attribute13             => NULL,
        p_global_attribute14             => NULL,
        p_global_attribute15             => NULL,
        p_numeric1                       => NULL,
        p_numeric2                       => NULL,
        p_numeric3                       => NULL,
        p_numeric4                       => NULL,
        p_numeric5                       => NULL,
        p_numeric6                       => NULL,
        p_numeric7                       => NULL,
        p_numeric8                       => NULL,
        p_numeric9                       => NULL,
        p_numeric10                      => NULL,
        p_char1                          => NULL,
        p_char2                          => NULL,
        p_char3                          => NULL,
        p_char4                          => NULL,
        p_char5                          => NULL,
        p_char6                          => NULL,
        p_char7                          => NULL,
        p_char8                          => NULL,
        p_char9                          => NULL,
        p_char10                         => NULL,
        p_date1                          => NULL,
        p_date2                          => NULL,
        p_date3                          => NULL,
        p_date4                          => NULL,
        p_date5                          => NULL,
        p_date6                          => NULL,
        p_date7                          => NULL,
        p_date8                          => NULL,
        p_date9                          => NULL,
        p_date10                         => NULL,
        p_interface_entity_code          => NULL,
        p_interface_tax_line_id          => NULL,
        p_taxing_juris_geography_id      => NULL,
        p_adjusted_doc_tax_line_id       => NULL,
        p_object_version_number          => 1,
        p_created_by                     => fnd_global.user_id,
        p_creation_date                  => sysdate,
        p_last_updated_by                => fnd_global.user_id,
        p_last_update_date               => sysdate,
        p_last_update_login              => fnd_global.login_id);

    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_ALLOCATIONS_PKG.Insert_Row',
                     'Insert into zx_lines for allocation of lines. (-)');
    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_ALLOCATIONS_PKG.Insert_Row.END',
                     'Insert_Row (-)');
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;

  END Insert_Row;

  PROCEDURE Update_tax_amt
       (p_summary_tax_line_id                   NUMBER,
        p_application_id                        NUMBER,
        p_entity_code                           VARCHAR2,
        p_event_class_code                      VARCHAR2,
        p_trx_id                                NUMBER) IS

    l_total_tax_amt         NUMBER;
    l_detail_tax_amt        NUMBER;
    --l_tax_line_id           NUMBER;
    l_summary_tax_amt       NUMBER;
    l_total_trx_line_amt    NUMBER;
    l_unrounded_tax_amt     NUMBER;

  BEGIN

    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_ALLOCATIONS_PKG.Update_tax_amt.BEGIN',
                     'Update_tax_amt (+)');
    END IF;

    l_total_tax_amt          :=0;
    l_detail_tax_amt         :=0;
    l_summary_tax_amt        :=0;
    l_total_trx_line_amt     :=0;
    l_unrounded_tax_amt     :=0;


    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_ALLOCATIONS_PKG.Update_tax_amt',
                     'Update tax_amount in zx_lines for allocation of lines. (+)');
    END IF;

    SELECT TAX_AMT
    INTO l_summary_tax_amt
    FROM ZX_LINES_SUMMARY
    WHERE SUMMARY_TAX_LINE_ID = p_summary_tax_line_id;

	    IF (g_level_statement >= g_current_runtime_level ) THEN
	      FND_LOG.STRING(g_level_statement,
			     'ZX.PLSQL.ZX_TRL_ALLOCATIONS_PKG.Update_tax_amt',
			     'Summary tax amount '||to_char(l_summary_tax_amt));
	    END IF;
    SELECT SUM(LINE_AMT)
    INTO l_total_trx_line_amt
    FROM ZX_LINES
    WHERE SUMMARY_TAX_LINE_ID = p_summary_tax_line_id
    AND APPLICATION_ID        = p_application_id
    AND ENTITY_CODE           = p_entity_code
    AND EVENT_CLASS_CODE      = p_event_class_code
    AND TRX_ID                = p_trx_id;

	    IF (g_level_statement >= g_current_runtime_level ) THEN
	      FND_LOG.STRING(g_level_statement,
			     'ZX.PLSQL.ZX_TRL_ALLOCATIONS_PKG.Update_tax_amt',
			     'total trx line amount '||to_char(l_total_trx_line_amt));
	    END IF;

    SELECT SUM(unrounded_tax_amt)
    INTO l_unrounded_tax_amt
    FROM ZX_LINES
    WHERE SUMMARY_TAX_LINE_ID = p_summary_tax_line_id
    AND APPLICATION_ID        = p_application_id
    AND ENTITY_CODE           = p_entity_code
    AND EVENT_CLASS_CODE      = p_event_class_code
    AND TRX_ID                = p_trx_id;

	    IF (g_level_statement >= g_current_runtime_level ) THEN
	      FND_LOG.STRING(g_level_statement,
			     'ZX.PLSQL.ZX_TRL_ALLOCATIONS_PKG.Update_tax_amt',
			     'total trxline amt'||to_char(l_total_trx_line_amt)||' unrounded amt '||to_char(l_unrounded_tax_amt)||'summary tax amount '||to_char(l_summary_tax_amt));
	    END IF;
    IF l_total_trx_line_amt <> 0 THEN
      UPDATE ZX_LINES
      SET
        unrounded_tax_amt = ((unrounded_tax_amt * l_summary_tax_amt) / l_total_trx_line_amt)
	      WHERE SUMMARY_TAX_LINE_ID = p_summary_tax_line_id
	      AND APPLICATION_ID        = p_application_id
	      AND ENTITY_CODE           = p_entity_code
	      AND EVENT_CLASS_CODE      = p_event_class_code
	      AND TRX_ID                = p_trx_id;
	    END IF;


	    IF (g_level_procedure >= g_current_runtime_level ) THEN
	      FND_LOG.STRING(g_level_procedure,
			     'ZX.PLSQL.ZX_TRL_ALLOCATIONS_PKG.Update_tax_amt',
			     'Update tax_amount in zx_lines for allocation of lines. (-)');
	    END IF;

	    IF (g_level_procedure >= g_current_runtime_level ) THEN
	      FND_LOG.STRING(g_level_procedure,
			     'ZX.PLSQL.ZX_TRL_ALLOCATIONS_PKG.Update_tax_amt.END',
			     'Update_tax_amt (-)');
	    END IF;
	  END Update_tax_amt;

	  PROCEDURE Populate_Allocation
	       (p_statement                             VARCHAR2,
		p_trx_record                 OUT NOCOPY trx_record_tbl_type) IS

	    i    NUMBER;

	    TYPE EmpCurTyp IS REF CURSOR;
	    ALLOC          EmpCurTyp;

	  BEGIN

	    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

	    i := 0;

	    IF (g_level_procedure >= g_current_runtime_level ) THEN
	      FND_LOG.STRING(g_level_procedure,
			     'ZX.PLSQL.ZX_TRL_ALLOCATIONS_PKG.Populate_Allocation.BEGIN',
			     'Populate_Allocation (+)');
	    END IF;

	    OPEN ALLOC FOR p_statement;
	    LOOP
	      i := i + 1;
	      FETCH ALLOC INTO p_trx_record.p_trx_id(i),
			       p_trx_record.p_trx_line_id(i),
			       p_trx_record.p_trx_level_type(i),
			       p_trx_record.p_trx_number(i),
			       p_trx_record.p_trx_line_number(i),
			       p_trx_record.p_trx_line_description(i),
			       p_trx_record.p_line_amt(i),
			       p_trx_record.p_trx_line_date(i);

	      EXIT WHEN ALLOC%NOTFOUND;
	    END LOOP;

	    CLOSE ALLOC;

	    IF (g_level_procedure >= g_current_runtime_level ) THEN
	      FND_LOG.STRING(g_level_procedure,
			     'ZX.PLSQL.ZX_TRL_ALLOCATIONS_PKG.Populate_Allocation.END',
			     'Populate_Allocation (-)');
	    END IF;

	  EXCEPTION
	    WHEN NO_DATA_FOUND THEN
	      NULL;

	  END Populate_Allocation;

	  PROCEDURE Insert_All_Allocation
	       (X_Rowid                    IN OUT NOCOPY VARCHAR2,
		p_summary_tax_line_id                    NUMBER,
		p_internal_organization_id               NUMBER,
		p_application_id                         NUMBER,
		p_entity_code                            VARCHAR2,
		p_event_class_code                       VARCHAR2,
		p_tax_regime_code                        VARCHAR2,
		p_tax                                    VARCHAR2,
		p_tax_jurisdiction_code                  VARCHAR2,
		p_tax_status_code                        VARCHAR2,
		p_tax_rate_id                            NUMBER,
		p_tax_rate_code                          VARCHAR2,
		p_tax_rate                               NUMBER,
		p_tax_amt                                NUMBER,
		p_enabled_record                         VARCHAR2,
		p_summ_tax_only                          VARCHAR2,
		p_statement                              VARCHAR2,
		p_manually_entered_flag                  VARCHAR2,
		p_content_owner_id                       NUMBER,
		p_record_type_code                       VARCHAR2,
		p_last_manual_entry                      VARCHAR2,
		p_tax_amt_included_flag                  VARCHAR2,
		p_self_assessed_flag                     VARCHAR2,
		p_tax_only_line_flag                     VARCHAR2,
		p_created_by                             NUMBER,
		p_creation_date                          DATE,
		p_last_updated_by                        NUMBER,
		p_last_update_date                       DATE,
		p_last_update_login                      NUMBER,
		p_allocate_flag                   IN     VARCHAR2 DEFAULT 'N'
		) IS

	    l_tax_line_id          NUMBER;
	    l_trx_line_id          NUMBER;
	    l_tax_line_number      NUMBER;
	    l_tax_id               NUMBER;
	    v_trx_number           zx_lines.trx_number%TYPE;
	    v_trx_id               zx_lines.trx_id%TYPE;
	    v_trx_line_id          zx_lines.trx_line_id%TYPE;
	    v_trx_level_type       zx_lines.trx_level_type%TYPE;
	    v_trx_line_date        zx_lines.trx_line_date%TYPE;
	    v_trx_line_number      zx_lines.trx_line_number%TYPE;
	    v_trx_line_description zx_transaction_lines.trx_line_description%TYPE;
	    v_line_amt             zx_lines.line_amt%TYPE := 0;
	    l_taxable_amt          NUMBER;
            l_event_id             NUMBER;
            l_regime_id             NUMBER;
            l_status_id            NUMBER;
            l_tax_determine_date   DATE;
            l_trx_date   DATE;
            l_related_doc_date   DATE;
            l_adjusted_doc_date   DATE;

    TYPE EmpCurTyp IS REF CURSOR;
    ALLOC          EmpCurTyp;
    l_key          VARCHAR2(100);
    l_insert       BOOLEAN ;

  BEGIN

    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_ALLOCATIONS_PKG.Insert_All_Allocation.BEGIN',
                     'Insert_All_Allocation (+)');
    END IF;

    l_insert := TRUE;

    OPEN ALLOC FOR p_statement;
    LOOP

      FETCH ALLOC INTO v_trx_id,
                       v_trx_line_id,
                       v_trx_level_type,
                       v_trx_number,
                       v_trx_line_number,
                       v_trx_line_description,
                       v_line_amt,
                       v_trx_line_date;

      EXIT WHEN ALLOC%NOTFOUND;

       v_trx_level_type := NVL(v_trx_level_type, 'LINE');


      IF p_allocate_flag = 'Y' THEN
        l_key := to_char(p_summary_tax_line_id)||to_char(v_trx_id)||to_char(v_trx_line_id);
        IF (g_level_statement >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TRL_ALLOCATIONS_PKG.Insert_All_Allocation',
                     'key : ' || l_key) ;
        END IF;
        IF g_trx_allocate_tbl.exists(l_key) THEN
          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TRL_ALLOCATIONS_PKG.Insert_All_Allocation',
                     'allocate true : ') ;
          END IF;
          l_insert := TRUE;
        ELSE
          l_insert := FALSE;
        END IF;
      END IF;

      IF l_insert THEN

        SELECT NVL(MAX(TAX_LINE_NUMBER),0) + 1
        INTO l_tax_line_number
        FROM ZX_LINES
        WHERE APPLICATION_ID = p_application_id
        AND EVENT_CLASS_CODE = p_event_class_code
        AND ENTITY_CODE      = p_entity_code
        AND TRX_ID           = v_trx_id
        AND TRX_LINE_ID      = v_trx_line_id
        AND TRX_LEVEL_TYPE   = v_trx_level_type;

        IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_ALLOCATIONS_PKG.Insert_All_Allocation',
                     'line amt : ' || to_char(v_line_amt)) ;
        END IF;
        select tax_id
	INTO l_tax_id
	FROM ZX_SCO_TAXES
	WHERE TAX_REGIME_CODE = p_tax_regime_code
	AND TAX=p_tax;

        IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_ALLOCATIONS_PKG.Insert_All_Allocation',
                     'tax id : ' || to_char(l_tax_id)) ;
        END IF;

        select tax_regime_id
	INTO l_regime_id
	FROM zx_regimes_b
	WHERE TAX_REGIME_CODE = p_tax_regime_code;

        select tax_status_id INTO l_status_id
        FROM zx_sco_status
        WHERE tax_regime_code = p_tax_regime_code and tax = p_tax
        AND   tax_status_code = p_tax_status_code ;

        IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_ALLOCATIONS_PKG.Insert_All_Allocation',
                     'status id : ' || to_char(l_status_id)) ;
        END IF;

        SELECT zx_lines_s.nextval
        INTO l_tax_line_id
        FROM dual;

        IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_ALLOCATIONS_PKG.Insert_All_Allocation',
                     'line amt : ' || to_char(v_line_amt)) ;
        END IF;

        BEGIN
          SELECT distinct nvl(related_doc_date,nvl(provnl_tax_determination_date
                              ,nvl(adjusted_doc_date,trx_date))) ,
                 trx_date,
                 related_doc_date ,
                 adjusted_doc_date
          into l_tax_determine_date, l_trx_date ,l_related_doc_date, l_adjusted_doc_date
          FROM zx_lines_det_factors where trx_id = v_trx_id
          AND application_id = p_application_id
          AND entity_code = p_entity_code
          AND event_class_code = p_event_class_code
          AND rownum = 1;
       EXCEPTION
         WHEN others THEN NULL;
           IF (g_level_procedure >= g_current_runtime_level ) THEN
             FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_ALLOCATIONS_PKG.Insert_All_Allocation',
                     'exception : ' || sqlerrm);
          END IF;
       END ;

        ZX_TRL_DETAIL_OVERRIDE_PKG.Insert_row
         (x_rowid                          => X_Rowid,
          p_tax_line_id                    => l_tax_line_id,
          p_internal_organization_id       => p_internal_organization_id,
          p_application_id                 => p_application_id,
          p_entity_code                    => p_entity_code,
          p_event_class_code               => p_event_class_code,
          p_event_type_code                => NULL,
          p_trx_id                         => v_trx_id,
          p_trx_line_id                    => v_trx_line_id,
          p_trx_level_type                 => v_trx_level_type,
          p_trx_line_number                => v_trx_line_number,
          p_doc_event_status               => NULL,
          p_tax_event_class_code           => NULL,
          p_tax_event_type_code            => NULL,
          p_tax_line_number                => l_tax_line_number,
          p_content_owner_id               => p_content_owner_id,
          p_tax_regime_id                  => l_regime_id,
          p_tax_regime_code                => p_tax_regime_code,
          p_tax_id                         => l_tax_id,
          p_tax                            => p_tax,
          p_tax_status_id                  => l_status_id,
          p_tax_status_code                => p_tax_status_code,
          p_tax_rate_id                    => p_tax_rate_id,
          p_tax_rate_code                  => p_tax_rate_code,
          p_tax_rate                       => p_tax_rate,
          p_tax_rate_type                  => NULL,
          p_tax_apportionment_line_num     => NULL,
          p_trx_id_level2                  => NULL,
          p_trx_id_level3                  => NULL,
          p_trx_id_level4                  => NULL,
          p_trx_id_level5                  => NULL,
          p_trx_id_level6                  => NULL,
          p_trx_user_key_level1            => NULL,
          p_trx_user_key_level2            => NULL,
          p_trx_user_key_level3            => NULL,
          p_trx_user_key_level4            => NULL,
          p_trx_user_key_level5            => NULL,
          p_trx_user_key_level6            => NULL,
          p_mrc_tax_line_flag              => 'N',
          p_mrc_link_to_tax_line_id        => NULL,
          p_ledger_id                      => NULL,
          p_establishment_id               => NULL,
          p_legal_entity_id                => NULL,
          -- p_legal_entity_tax_reg_number    => NULL,
          p_hq_estb_reg_number             => NULL,
          p_hq_estb_party_tax_prof_id      => NULL,
          p_currency_conversion_date       => NULL,
          p_currency_conversion_type       => NULL,
          p_currency_conversion_rate       => NULL,
          p_tax_curr_conversion_date       => NULL,
          p_tax_curr_conversion_type       => NULL,
          p_tax_curr_conversion_rate       => NULL,
          p_trx_currency_code              => NULL,
          p_reporting_currency_code        => NULL,
          p_minimum_accountable_unit       => NULL,
          p_precision                      => NULL,
          p_trx_number                     => v_trx_number,
          p_trx_date                       => l_trx_date,
          p_unit_price                     => NULL,
          p_line_amt                       => v_line_amt,
          p_trx_line_quantity              => NULL,
          p_tax_base_modifier_rate         => NULL,
          p_ref_doc_application_id         => NULL,
          p_ref_doc_entity_code            => NULL,
          p_ref_doc_event_class_code       => NULL,
          p_ref_doc_trx_id                 => NULL,
          p_ref_doc_trx_level_type         => NULL,
          p_ref_doc_line_id                => NULL,
          p_ref_doc_line_quantity          => NULL,
          p_other_doc_line_amt             => NULL,
          p_other_doc_line_tax_amt         => NULL,
          p_other_doc_line_taxable_amt     => NULL,
          p_unrounded_taxable_amt          => v_line_amt,
          p_unrounded_tax_amt              => v_line_amt,
          p_related_doc_application_id     => NULL,
          p_related_doc_entity_code        => NULL,
          p_related_doc_evt_class_code     => NULL,
          p_related_doc_trx_id             => NULL,
          p_related_doc_trx_level_type     => NULL,
          p_related_doc_number             => NULL,
          p_related_doc_date               => l_related_doc_date,
          p_applied_from_appl_id           => NULL,
          p_applied_from_evt_clss_code     => NULL,
          p_applied_from_entity_code       => NULL,
          p_applied_from_trx_id            => NULL,
          p_applied_from_trx_level_type    => NULL,
          p_applied_from_line_id           => NULL,
          p_applied_from_trx_number        => NULL,
          p_adjusted_doc_appln_id          => NULL,
          p_adjusted_doc_entity_code       => NULL,
          p_adjusted_doc_evt_clss_code     => NULL,
          p_adjusted_doc_trx_id            => NULL,
          p_adjusted_doc_trx_level_type    => NULL,
          p_adjusted_doc_line_id           => NULL,
          p_adjusted_doc_number            => NULL,
          p_adjusted_doc_date              => l_adjusted_doc_date,
          p_applied_to_application_id      => NULL,
          p_applied_to_evt_class_code      => NULL,
          p_applied_to_entity_code         => NULL,
          p_applied_to_trx_id              => NULL,
          p_applied_to_trx_level_type      => NULL,
          p_applied_to_line_id             => NULL,
          p_summary_tax_line_id            => p_summary_tax_line_id,
          p_offset_link_to_tax_line_id     => NULL,
          p_offset_flag                    => 'N',
          p_process_for_recovery_flag      => 'N',
          p_tax_jurisdiction_id            => NULL,
          p_tax_jurisdiction_code          => p_tax_jurisdiction_code,
          p_place_of_supply                => NULL,
          p_place_of_supply_type_code      => NULL,
          p_place_of_supply_result_id      => NULL,
          p_tax_date_rule_id               => NULL,
          p_tax_date                       => l_tax_determine_date,
          p_tax_determine_date             => l_tax_determine_date,
          p_tax_point_date                 => l_tax_determine_date,
          p_trx_line_date                  => v_trx_line_date,
          p_tax_type_code                  => NULL,
          p_tax_code                       => NULL,
          p_tax_registration_id            => NULL,
          p_tax_registration_number        => NULL,
          p_registration_party_type        => NULL,
          p_rounding_level_code            => 'HEADER',
          p_rounding_rule_code             => NULL,
          p_rndg_lvl_party_tax_prof_id     => NULL,
          p_rounding_lvl_party_type        => NULL,
          p_compounding_tax_flag           => 'N',
          p_orig_tax_status_id             => NULL,
          p_orig_tax_status_code           => NULL,
          p_orig_tax_rate_id               => NULL,
          p_orig_tax_rate_code             => NULL,
          p_orig_tax_rate                  => NULL,
          p_orig_tax_jurisdiction_id       => NULL,
          p_orig_tax_jurisdiction_code     => NULL,
          p_orig_tax_amt_included_flag     => 'N',
          p_orig_self_assessed_flag        => 'N',
          p_tax_currency_code              => NULL,
          p_tax_amt                        => p_tax_amt,
          p_tax_amt_tax_curr               => NULL,
          p_tax_amt_funcl_curr             => NULL,
          p_taxable_amt                    => NULL,
          p_taxable_amt_tax_curr           => NULL,
          p_taxable_amt_funcl_curr         => NULL,
          p_orig_taxable_amt               => NULL,
          p_orig_taxable_amt_tax_curr      => NULL,
          p_cal_tax_amt                    => NULL,
          p_cal_tax_amt_tax_curr           => NULL,
          p_cal_tax_amt_funcl_curr         => NULL,
          p_orig_tax_amt                   => NULL,
          p_orig_tax_amt_tax_curr          => NULL,
          p_rec_tax_amt                    => NULL,
          p_rec_tax_amt_tax_curr           => NULL,
          p_rec_tax_amt_funcl_curr         => NULL,
          p_nrec_tax_amt                   => NULL,
          p_nrec_tax_amt_tax_curr          => NULL,
          p_nrec_tax_amt_funcl_curr        => NULL,
          p_tax_exemption_id               => NULL,
          p_tax_rate_before_exemption      => NULL,
          p_tax_rate_name_before_exempt    => NULL,
          p_exempt_rate_modifier           => NULL,
          p_exempt_certificate_number      => NULL,
          p_exempt_reason                  => NULL,
          p_exempt_reason_code             => NULL,
          p_tax_exception_id               => NULL,
          p_tax_rate_before_exception      => NULL,
          p_tax_rate_name_before_except    => NULL,
          p_exception_rate                 => NULL,
          p_tax_apportionment_flag         => 'N',
          p_historical_flag                => 'N',
          p_taxable_basis_formula          => NULL,
          p_tax_calculation_formula        => NULL,
          p_cancel_flag                    => 'N',
          p_purge_flag                     => 'N',
          p_delete_flag                    => 'N',
          p_tax_amt_included_flag          => p_tax_amt_included_flag,
          p_self_assessed_flag             => p_self_assessed_flag,
          p_overridden_flag                => 'N',
          p_manually_entered_flag          => p_manually_entered_flag,
          p_reporting_only_flag            => 'N',
          p_freeze_until_overriddn_flg     => 'N',
          p_copied_from_other_doc_flag     => 'N',
          p_recalc_required_flag           => 'Y',
          p_settlement_flag                => 'N',
          p_item_dist_changed_flag         => 'N',
          p_assoc_children_frozen_flg      => 'N',
          p_tax_only_line_flag             => p_tax_only_line_flag,
          p_compounding_dep_tax_flag       => 'N',
          p_compounding_tax_miss_flag      => 'N',
          p_sync_with_prvdr_flag           => 'N',
          p_last_manual_entry              => p_last_manual_entry,
          p_tax_provider_id                => NULL,
          p_record_type_code               => p_record_type_code,
          p_reporting_period_id            => NULL,
          p_legal_justification_text1      => NULL,
          p_legal_justification_text2      => NULL,
          p_legal_justification_text3      => NULL,
          p_legal_message_appl_2           => NULL,
          p_legal_message_status           => NULL,
          p_legal_message_rate             => NULL,
          p_legal_message_basis            => NULL,
          p_legal_message_calc             => NULL,
          p_legal_message_threshold        => NULL,
          p_legal_message_pos              => NULL,
          p_legal_message_trn              => NULL,
          p_legal_message_exmpt            => NULL,
          p_legal_message_excpt            => NULL,
          p_tax_regime_template_id         => NULL,
          p_tax_applicability_result_id    => NULL,
          p_direct_rate_result_id          => NULL,
          p_status_result_id               => NULL,
          p_rate_result_id                 => NULL,
          p_basis_result_id                => NULL,
          p_thresh_result_id               => NULL,
          p_calc_result_id                 => NULL,
          p_tax_reg_num_det_result_id      => NULL,
          p_eval_exmpt_result_id           => NULL,
          p_eval_excpt_result_id           => NULL,
          p_enforced_from_nat_acct_flg     => 'N',
          p_tax_hold_code                  => NULL,
          p_tax_hold_released_code         => NULL,
          p_prd_total_tax_amt              => NULL,
          p_prd_total_tax_amt_tax_curr     => NULL,
          p_prd_total_tax_amt_funcl_curr   => NULL,
          p_trx_line_index                 => NULL,
          p_offset_tax_rate_code           => NULL,
          p_proration_code                 => NULL,
          p_other_doc_source               => NULL,
          p_internal_org_location_id       => NULL,
          p_line_assessable_value          => NULL,
          p_ctrl_total_line_tx_amt         => NULL,
          p_applied_to_trx_number          => NULL,
          p_attribute_category             => NULL,
          p_attribute1                     => NULL,
          p_attribute2                     => NULL,
          p_attribute3                     => NULL,
          p_attribute4                     => NULL,
          p_attribute5                     => NULL,
          p_attribute6                     => NULL,
          p_attribute7                     => NULL,
          p_attribute8                     => NULL,
          p_attribute9                     => NULL,
          p_attribute10                    => NULL,
          p_attribute11                    => NULL,
          p_attribute12                    => NULL,
          p_attribute13                    => NULL,
          p_attribute14                    => NULL,
          p_attribute15                    => NULL,
          p_global_attribute_category      => NULL,
          p_global_attribute1              => NULL,
          p_global_attribute2              => NULL,
          p_global_attribute3              => NULL,
          p_global_attribute4              => NULL,
          p_global_attribute5              => NULL,
          p_global_attribute6              => NULL,
          p_global_attribute7              => NULL,
          p_global_attribute8              => NULL,
          p_global_attribute9              => NULL,
          p_global_attribute10             => NULL,
          p_global_attribute11             => NULL,
          p_global_attribute12             => NULL,
          p_global_attribute13             => NULL,
          p_global_attribute14             => NULL,
          p_global_attribute15             => NULL,
          p_numeric1                       => NULL,
          p_numeric2                       => NULL,
          p_numeric3                       => NULL,
          p_numeric4                       => NULL,
          p_numeric5                       => NULL,
          p_numeric6                       => NULL,
          p_numeric7                       => NULL,
          p_numeric8                       => NULL,
          p_numeric9                       => NULL,
          p_numeric10                      => NULL,
          p_char1                          => NULL,
          p_char2                          => NULL,
          p_char3                          => NULL,
          p_char4                          => NULL,
          p_char5                          => NULL,
          p_char6                          => NULL,
          p_char7                          => NULL,
          p_char8                          => NULL,
          p_char9                          => NULL,
          p_char10                         => NULL,
          p_date1                          => NULL,
          p_date2                          => NULL,
          p_date3                          => NULL,
          p_date4                          => NULL,
          p_date5                          => NULL,
          p_date6                          => NULL,
          p_date7                          => NULL,
          p_date8                          => NULL,
          p_date9                          => NULL,
          p_date10                         => NULL,
          p_interface_entity_code          => NULL,
          p_interface_tax_line_id          => NULL,
          p_taxing_juris_geography_id      => NULL,
          p_adjusted_doc_tax_line_id       => NULL,
          p_object_version_number          => 1,
          p_created_by                     => fnd_global.user_id,
          p_creation_date                  => sysdate,
          p_last_updated_by                => fnd_global.user_id,
          p_last_update_date               => sysdate,
          p_last_update_login              => fnd_global.login_id  );


        END IF;

      END LOOP;

    CLOSE ALLOC;

    ZX_TRL_ALLOCATIONS_PKG.Update_Tax_Amt
                               (p_summary_tax_line_id => p_summary_tax_line_id,
                                p_application_id      => p_application_id,
                                p_entity_code         => p_entity_code,
                                p_event_class_code    => p_event_class_code,
                                p_trx_id              => v_trx_id);



    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_ALLOCATIONS_PKG.  Insert_All_Allocation.END',
                     'Insert_All_Allocation (-)');
    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;

  END Insert_All_Allocation;

  PROCEDURE Insert_Tax_Line
       (p_summary_tax_line_id                    NUMBER,
        p_internal_organization_id               NUMBER,
        p_application_id                         NUMBER,
        p_entity_code                            VARCHAR2,
        p_event_class_code                       VARCHAR2,
        p_trx_id                                 NUMBER,
        p_trx_number                             VARCHAR2,
        p_tax_regime_code                        VARCHAR2,
        p_tax                                    VARCHAR2,
        p_tax_jurisdiction_code                  VARCHAR2,
        p_tax_status_code                        VARCHAR2,
        p_tax_rate_id                            NUMBER,
        p_tax_rate_code                          VARCHAR2,
        p_tax_rate                               NUMBER,
        p_tax_amt                                NUMBER,
        p_line_amt                               NUMBER,
        p_trx_line_date                          DATE,
        p_summ_tax_only                          VARCHAR2,
        p_manually_entered_flag                  VARCHAR2,
        p_last_manual_entry                      VARCHAR2,
        p_tax_amt_included_flag                  VARCHAR2,
        p_self_assessed_flag                     VARCHAR2,
        p_created_by                             NUMBER,
        p_creation_date                          DATE,
        p_last_updated_by                        NUMBER,
        p_last_update_date                       DATE,
        p_last_update_login                      NUMBER,
        p_event_type_code                      VARCHAR,
        p_legal_entity_id                       NUMBER,
        p_ledger_id                              NUMBER,
        p_trx_currency_code                     VARCHAR,
        p_currency_conversion_date              DATE,
        p_currency_conversion_rate              NUMBER,
        p_currency_conversion_type              VARCHAR2,
        p_content_owner_id                      NUMBER,
        p_trx_date                              DATE,
        p_minimum_accountable_unit              NUMBER,
        p_precision                             NUMBER,
        p_trx_line_gl_date                      DATE   ) IS

    l_tax_line_id          NUMBER;
    l_trx_line_id          NUMBER;
    l_trx_line_number      NUMBER;
    l_tax_line_number      NUMBER;
    l_tax_jurisdiction_id  NUMBER;
    l_tax_currency_code    VARCHAR2(100);
    l_tax_id      NUMBER;
    l_regime_id      NUMBER;
    l_status_id      NUMBER;

    v_trx_line_id          zx_lines.trx_line_id%TYPE;
    v_trx_line_number      zx_lines.trx_line_number%TYPE;

    l_tax_event_class_code zx_evnt_cls_mappings.tax_event_class_code%type;
    l_trx_number           zx_lines_det_factors.trx_number%type;
    l_legal_reporting_status zx_taxes_b.legal_reporting_status_def_val%type;
    l_tax_reporting_flag   zx_lines_det_factors.tax_reporting_flag%type;

    l_hq_estb_pty_tax_prof_id             ZX_LINES_DET_FACTORS.HQ_ESTB_PARTY_TAX_PROF_ID%TYPE;
    l_internal_org_loc_id                 ZX_LINES_DET_FACTORS.INTERNAL_ORG_LOCATION_ID%TYPE;
    l_event_class_mapping_id              ZX_EVNT_CLS_MAPPINGS.EVENT_CLASS_MAPPING_ID%TYPE;
    l_tax_type_code                       ZX_TAXES_B.TAX_TYPE_CODE%TYPE;
    l_rate_type_code                      ZX_RATES_B.RATE_TYPE_CODE%TYPE;
    l_default_taxation_country            ZX_LINES_DET_FACTORS.DEFAULT_TAXATION_COUNTRY%TYPE;
    l_rndg_ship_fr_pty_tx_prof_id         ZX_LINES_DET_FACTORS.RDNG_SHIP_FROM_PTY_TX_PROF_ID%TYPE;
    l_rndg_bill_fr_pty_tx_prof_id         ZX_LINES_DET_FACTORS.RDNG_BILL_FROM_PTY_TX_PROF_ID%TYPE;
    l_rndg_ship_fr_pty_tx_p_st_id         ZX_LINES_DET_FACTORS.RDNG_SHIP_FROM_PTY_TX_P_ST_ID%TYPE;
    l_rndg_bill_fr_pty_tx_p_st_id         ZX_LINES_DET_FACTORS.RDNG_BILL_FROM_PTY_TX_P_ST_ID%TYPE;
    l_ship_to_location_id                 ZX_LINES_DET_FACTORS.SHIP_TO_LOCATION_ID%TYPE;
    l_ship_from_location_id               ZX_LINES_DET_FACTORS.SHIP_FROM_LOCATION_ID%TYPE;
    l_bill_to_location_id                 ZX_LINES_DET_FACTORS.BILL_TO_LOCATION_ID%TYPE;
    l_bill_from_location_id               ZX_LINES_DET_FACTORS.BILL_FROM_LOCATION_ID%TYPE;
    l_ship_from_pty_tax_prof_id           ZX_LINES_DET_FACTORS.SHIP_FROM_PARTY_TAX_PROF_ID%TYPE;
    l_bill_from_pty_tax_prof_id           ZX_LINES_DET_FACTORS.BILL_FROM_PARTY_TAX_PROF_ID%TYPE;
    l_ship_from_site_tx_prof_id           ZX_LINES_DET_FACTORS.SHIP_FROM_SITE_TAX_PROF_ID%TYPE;
    l_bill_from_site_tx_prof_id           ZX_LINES_DET_FACTORS.BILL_FROM_SITE_TAX_PROF_ID%TYPE;
    l_ctrl_hdr_tx_appl_flag               ZX_LINES_DET_FACTORS.CTRL_HDR_TX_APPL_FLAG%TYPE;
    l_ship_third_pty_acct_site_id         ZX_LINES_DET_FACTORS.SHIP_THIRD_PTY_ACCT_SITE_ID%TYPE;
    l_bill_third_pty_acct_site_id         ZX_LINES_DET_FACTORS.BILL_THIRD_PTY_ACCT_SITE_ID%TYPE;
    l_ship_third_pty_acct_id              ZX_LINES_DET_FACTORS.SHIP_THIRD_PTY_ACCT_ID%TYPE;
    l_bill_third_pty_acct_id              ZX_LINES_DET_FACTORS.BILL_THIRD_PTY_ACCT_ID%TYPE;
    l_trx_currency_code                   ZX_LINES_DET_FACTORS.TRX_CURRENCY_CODE%TYPE;
    l_currency_conversion_date            ZX_LINES_DET_FACTORS.CURRENCY_CONVERSION_DATE%TYPE;
    l_currency_conversion_rate            ZX_LINES_DET_FACTORS.CURRENCY_CONVERSION_RATE%TYPE;
    l_currency_conversion_type            ZX_LINES_DET_FACTORS.CURRENCY_CONVERSION_TYPE%TYPE;


  BEGIN

    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_ALLOCATIONS_PKG.Insert_Tax_Line.BEGIN',
                     'Insert_Tax_Line (+)');
    END IF;

    l_tax_line_number :=1;

    IF p_summ_tax_only = 'Y' THEN

      SELECT nvl(min(trx_line_id),0),
             nvl(min(trx_line_number),0)
      INTO v_trx_line_number,
           v_trx_line_id
      FROM ZX_LINES
      WHERE TRX_ID         = p_trx_id
      AND APPLICATION_ID   = p_application_id
      AND EVENT_CLASS_CODE = p_event_class_code
      AND ENTITY_CODE      = p_entity_code;

      IF v_trx_line_number >= 0 THEN
        l_trx_line_id     := -1;
        l_trx_line_number := -1;

      ELSIF v_trx_line_number < 0 THEN
        l_trx_line_id     := v_trx_line_id - 1;
        l_trx_line_number := v_trx_line_number - 1;

      END IF;

      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TRL_ALLOCATIONS_PKG.Insert_All_Allocation',
                     'event type code ' || p_event_type_code) ;
        FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TRL_ALLOCATIONS_PKG.Insert_All_Allocation',
                     'legal entity id' || to_char(p_legal_entity_id)) ;
        FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TRL_ALLOCATIONS_PKG.Insert_All_Allocation',
                     'ledger id' || to_char(p_ledger_id)) ;
        FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TRL_ALLOCATIONS_PKG.Insert_All_Allocation',
                     'trx_currency_code ' || p_trx_currency_code) ;
        FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TRL_ALLOCATIONS_PKG.Insert_All_Allocation',
                     'content owner id ' || p_content_owner_id) ;
       END IF;

       BEGIN
          SELECT TAX_EVENT_CLASS_CODE, TAX_REPORTING_FLAG, EVENT_CLASS_MAPPING_ID
          INTO l_tax_event_class_code, l_tax_reporting_flag, l_event_class_mapping_id
          FROM ZX_EVNT_CLS_MAPPINGS
          WHERE application_id = p_application_id
          AND   entity_code = p_entity_code
          AND   event_class_Code = p_event_class_code;
       EXCEPTION
         WHEN OTHERS THEN
           l_tax_event_class_code := NULL;
           l_tax_reporting_flag := NULL;
           l_event_class_mapping_id := NULL;
       END;

       BEGIN

         select tax_id, tax_currency_code, tax_type_code,
         DECODE(NVL(l_tax_reporting_flag,'N'),'Y',
                legal_reporting_status_def_val,NULL)
	       INTO l_tax_id, l_tax_currency_code, l_tax_type_code, l_legal_reporting_status
	       FROM ZX_SCO_TAXES
	       WHERE TAX_REGIME_CODE = p_tax_regime_code
	       AND TAX=p_tax;

       EXCEPTION
         WHEN OTHERS THEN
            IF (g_level_unexpected >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_TRL_ALLOCATIONS_PKG.insert_tax_line',
                        sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
              FND_LOG.STRING(g_level_unexpected,
                         'ZX.PLSQL.ZX_TRL_ALLOCATIONS_PKG.insert_tax_line.END',
                         'ZX_TRL_ALLOCATIONS_PKG.insert_tax_line(-)');
           END IF;

           RETURN;

       END;
       IF (g_level_procedure >= g_current_runtime_level ) THEN
             FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_ALLOCATIONS_PKG.Insert_All_Allocation',
                     'tax id : ' || to_char(l_tax_id)) ;
       END IF;

       BEGIN

         select tax_regime_id
	       INTO l_regime_id
	       FROM zx_regimes_b
	       WHERE TAX_REGIME_CODE = p_tax_regime_code;

       EXCEPTION
         WHEN OTHERS THEN
            IF (g_level_unexpected >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_TRL_ALLOCATIONS_PKG.insert_tax_line',
                        sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
              FND_LOG.STRING(g_level_unexpected,
                         'ZX.PLSQL.ZX_TRL_ALLOCATIONS_PKG.insert_tax_line.END',
                         'ZX_TRL_ALLOCATIONS_PKG.insert_tax_line(-)');
           END IF;

           RETURN;

       END;

       BEGIN

         select tax_status_id
         INTO l_status_id
	       FROM zx_sco_status
	       WHERE tax_regime_code = p_tax_regime_code
         AND   tax = p_tax
         AND   tax_status_code = p_tax_status_code ;

       EXCEPTION
         WHEN OTHERS THEN
            IF (g_level_unexpected >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_TRL_ALLOCATIONS_PKG.insert_tax_line',
                        sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
              FND_LOG.STRING(g_level_unexpected,
                         'ZX.PLSQL.ZX_TRL_ALLOCATIONS_PKG.insert_tax_line.END',
                         'ZX_TRL_ALLOCATIONS_PKG.insert_tax_line(-)');
           END IF;

           RETURN;

       END;
       BEGIN
         SELECT tax_jurisdiction_id
         INTO l_tax_jurisdiction_id
         FROM zx_jurisdictions_b
         WHERE tax_regime_code = p_tax_regime_code
         AND tax = p_tax
         AND tax_jurisdiction_code = p_tax_jurisdiction_code;
       EXCEPTION
         WHEN OTHERS THEN
          l_tax_jurisdiction_id := NULL;
       END;

       BEGIN

         SELECT rate_type_code
         INTO l_rate_type_code
         FROM ZX_SCO_RATES
         WHERE tax_rate_id = p_tax_rate_id;

       EXCEPTION
         WHEN OTHERS THEN
            IF (g_level_unexpected >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_TRL_ALLOCATIONS_PKG.insert_tax_line',
                        sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
              FND_LOG.STRING(g_level_unexpected,
                         'ZX.PLSQL.ZX_TRL_ALLOCATIONS_PKG.insert_tax_line.END',
                         'ZX_TRL_ALLOCATIONS_PKG.insert_tax_line(-)');
           END IF;

           RETURN;

       END;

       SELECT zx_lines_s.nextval
       INTO l_tax_line_id
       FROM dual;

       IF (g_level_procedure >= g_current_runtime_level ) THEN
         FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_ALLOCATIONS_PKG.Insert_All_Allocation',
                     'status id : ' || to_char(l_status_id)) ;
       END IF;


       IF (g_level_procedure >= g_current_runtime_level ) THEN
         FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRL_ALLOCATIONS_PKG.Insert_All_Allocation.',
                       'Trx Line Id: '||to_char(l_trx_line_id));
       END IF;

       BEGIN
         SELECT TRX_NUMBER, NVL(P_TRX_CURRENCY_CODE, TRX_CURRENCY_CODE),
                NVL(P_CURRENCY_CONVERSION_DATE, CURRENCY_CONVERSION_DATE),
                NVL(P_CURRENCY_CONVERSION_RATE, CURRENCY_CONVERSION_RATE),
                NVL(P_CURRENCY_CONVERSION_TYPE, CURRENCY_CONVERSION_TYPE),
                HQ_ESTB_PARTY_TAX_PROF_ID, INTERNAL_ORG_LOCATION_ID,
                DEFAULT_TAXATION_COUNTRY, RDNG_SHIP_FROM_PTY_TX_PROF_ID,
                RDNG_BILL_FROM_PTY_TX_PROF_ID, RDNG_SHIP_FROM_PTY_TX_P_ST_ID,
                RDNG_BILL_FROM_PTY_TX_P_ST_ID, SHIP_TO_LOCATION_ID,
                SHIP_FROM_LOCATION_ID, BILL_TO_LOCATION_ID,
                BILL_FROM_LOCATION_ID, SHIP_FROM_PARTY_TAX_PROF_ID,
                BILL_FROM_PARTY_TAX_PROF_ID, SHIP_FROM_SITE_TAX_PROF_ID,
                BILL_FROM_SITE_TAX_PROF_ID, CTRL_HDR_TX_APPL_FLAG,
                SHIP_THIRD_PTY_ACCT_SITE_ID, BILL_THIRD_PTY_ACCT_SITE_ID,
                SHIP_THIRD_PTY_ACCT_ID, BILL_THIRD_PTY_ACCT_ID
         INTO l_trx_number,l_trx_currency_code,l_currency_conversion_date,
              l_currency_conversion_rate,l_currency_conversion_type,
              l_hq_estb_pty_tax_prof_id, l_internal_org_loc_id,
              l_default_taxation_country, l_rndg_ship_fr_pty_tx_prof_id,
              l_rndg_bill_fr_pty_tx_prof_id, l_rndg_ship_fr_pty_tx_p_st_id,
              l_rndg_bill_fr_pty_tx_p_st_id, l_ship_to_location_id,
              l_ship_from_location_id, l_bill_to_location_id,
              l_bill_from_location_id, l_ship_from_pty_tax_prof_id,
              l_bill_from_pty_tax_prof_id, l_ship_from_site_tx_prof_id,
              l_bill_from_site_tx_prof_id, l_ctrl_hdr_tx_appl_flag,
              l_ship_third_pty_acct_site_id, l_bill_third_pty_acct_site_id,
              l_ship_third_pty_acct_id, l_bill_third_pty_acct_id
         FROM ZX_LINES_DET_FACTORS
         WHERE APPLICATION_ID = P_APPLICATION_ID
         AND   ENTITY_CODE = P_ENTITY_CODE
         AND EVENT_CLASS_CODE = P_EVENT_CLASS_CODE
         AND TRX_ID = P_TRX_ID
         AND ROWNUM = 1;
       EXCEPTION
         WHEN OTHERS THEN
           l_trx_number := NULL;
           --Start Bug 8266185
           L_TRX_CURRENCY_CODE := P_TRX_CURRENCY_CODE;
           L_CURRENCY_CONVERSION_DATE := P_CURRENCY_CONVERSION_DATE;
           L_CURRENCY_CONVERSION_RATE := P_CURRENCY_CONVERSION_RATE;
           L_CURRENCY_CONVERSION_TYPE := P_CURRENCY_CONVERSION_TYPE;
           --End Bug 8266185
       END;


      INSERT INTO ZX_LINES (SUMMARY_TAX_LINE_ID,
                            INTERNAL_ORGANIZATION_ID,
                            APPLICATION_ID,
                            ENTITY_CODE,
                            EVENT_CLASS_CODE,
                            --EVENT_TYPE_CODE,
                            TRX_LINE_NUMBER,
                            TRX_ID,
                            TRX_NUMBER,
                            TRX_LINE_ID,
                            TRX_LEVEL_TYPE,
                            TAX_LINE_ID,
                            CONTENT_OWNER_ID,
                            TAX_LINE_NUMBER,
                            LINE_AMT,
                            TRX_LINE_DATE,
                            TRX_DATE,
                            MINIMUM_ACCOUNTABLE_UNIT,
                            PRECISION,
                            TAX_REGIME_CODE,
                            TAX_REGIME_ID,
                            TAX,
                            TAX_ID,
                            TAX_JURISDICTION_CODE,
                            TAX_STATUS_CODE,
                            TAX_STATUS_ID,
                            TAX_DETERMINE_DATE,
                            TAX_RATE_ID,
                            TAX_RATE_CODE,
                            TAX_RATE,
                            TAX_JURISDICTION_ID,
                            TAX_AMT,
                            TAX_CURRENCY_CODE,
                            OFFSET_FLAG,
                            PROCESS_FOR_RECOVERY_FLAG,
                            COMPOUNDING_TAX_FLAG,
                            ORIG_TAX_AMT_INCLUDED_FLAG,
                            ORIG_SELF_ASSESSED_FLAG,
                            TAX_APPORTIONMENT_FLAG,
                            HISTORICAL_FLAG,
                            CANCEL_FLAG,
                            PURGE_FLAG,
                            DELETE_FLAG,
                            TAX_AMT_INCLUDED_FLAG,
                            SELF_ASSESSED_FLAG,
                            OVERRIDDEN_FLAG,
                            MANUALLY_ENTERED_FLAG,
                            REPORTING_ONLY_FLAG,
                            FREEZE_UNTIL_OVERRIDDEN_FLAG,
                            COPIED_FROM_OTHER_DOC_FLAG,
                            RECALC_REQUIRED_FLAG,
                            SETTLEMENT_FLAG,
                            ITEM_DIST_CHANGED_FLAG,
                            ASSOCIATED_CHILD_FROZEN_FLAG,
                            TAX_ONLY_LINE_FLAG,
                            COMPOUNDING_DEP_TAX_FLAG,
                            ENFORCE_FROM_NATURAL_ACCT_FLAG,
                            MRC_TAX_LINE_FLAG,
                            LAST_MANUAL_ENTRY,
                            UNROUNDED_TAX_AMT,
                            UNROUNDED_TAXABLE_AMT,
                            RECORD_TYPE_CODE,
                            TAX_APPORTIONMENT_LINE_NUMBER,
                            ROUNDING_LEVEL_CODE,
                            OBJECT_VERSION_NUMBER,
                            --bug 7300367
                            TAX_EVENT_CLASS_CODE,
                            TAXABLE_BASIS_FORMULA,
                            TAX_CALCULATION_FORMULA,
                            COMPOUNDING_TAX_MISS_FLAG,
                            TRX_CURRENCY_CODE,
                            CURRENCY_CONVERSION_DATE,
                            CURRENCY_CONVERSION_RATE,
                            CURRENCY_CONVERSION_TYPE,
                            LEGAL_REPORTING_STATUS,
                            --bug 7300367
                            --bug 7369708
                            HQ_ESTB_PARTY_TAX_PROF_ID,
                            TAX_CURRENCY_CONVERSION_DATE,
                            UNIT_PRICE,
                            TRX_LINE_QUANTITY,
                            TAX_BASE_MODIFIER_RATE,
                            PLACE_OF_SUPPLY_TYPE_CODE,
                            TAX_DATE,
                            TAX_POINT_DATE,
                            TAX_TYPE_CODE,
                            --ROUNDING_LVL_PARTY_TAX_PROF_ID,
                            --ROUNDING_LVL_PARTY_TYPE,
                            INTERNAL_ORG_LOCATION_ID,
                            LINE_ASSESSABLE_VALUE,
                            TAX_RATE_TYPE,
                            --bug 7369708
                            CREATED_BY,
                            CREATION_DATE,
                            LAST_UPDATED_BY,
                            LAST_UPDATE_DATE,
                            LAST_UPDATE_LOGIN)
                    VALUES (p_summary_tax_line_id,
                            p_internal_organization_id,
                            p_application_id,
                            p_entity_code,
                            p_event_class_code,
                            --p_event_type_code,
                            l_trx_line_number,
                            p_trx_id,
                            p_trx_number,
                            l_trx_line_id,
                            'LINE',--p_trx_level_type,
                            l_tax_line_id,
                            p_content_owner_id,
                            l_tax_line_number,
                            p_line_amt,
                            p_trx_line_date,
                            p_trx_date,
                            p_minimum_accountable_unit,
                            p_precision,
                            p_tax_regime_code,
                            l_regime_id,
                            p_tax,
                            l_tax_id,
                            p_tax_jurisdiction_code,
                            p_tax_status_code,
                            l_status_id,
                            p_trx_date,
                            p_tax_rate_id,
                            p_tax_rate_code,
                            p_tax_rate,
                            l_tax_jurisdiction_id,
                            NULL, --p_tax_amt,
                            l_tax_currency_code,
                            'N',
                            'Y',
                            'N',
                            'N',
                            'N',
                            'N',
                            'N',
                            'N',
                            'N',
                            'N',
                            p_tax_amt_included_flag,
                            p_self_assessed_flag,
                            'N',
                            'Y',
                            'N',
                            'N',
                            'N',
                            'Y',
                            'N',
                            'N',
                            'N',
                            'Y',
                            'N',
                            'N',
                            'N',
                            'TAX_AMOUNT',
                            p_tax_amt,
                            (p_tax_amt/p_tax_rate) * 100,
                            'ETAX_CREATED',
                            1,
                            'HEADER',
                            1, -- object_version_number,
                            --bug 7300367
                            l_tax_event_class_code,
                            'STANDARD_TB',
                            'STANDARD_TC',
                            'N',
                            l_trx_currency_code,
                            l_CURRENCY_CONVERSION_DATE,
                            l_CURRENCY_CONVERSION_RATE,
                            l_CURRENCY_CONVERSION_TYPE,
                            l_legal_reporting_status,
                            --bug 7300367
                            --bug 7369708
                            l_hq_estb_pty_tax_prof_id,  --HQ_ESTB_PARTY_TAX_PROF_ID
                            l_CURRENCY_CONVERSION_DATE,  --TAX_CURRENCY_CONVERSION_DATE
                            P_LINE_AMT,  --UNIT_PRICE
                            1,         --TRX_LINE_QUANTITY
                            1,         --TAX_BASE_MODIFIER_RATE
                            'SHIP_TO',
                            p_trx_date, --TAX_DATE
                            p_trx_date, --TAX_POINT_DATE
                            l_tax_type_code,
                            --ROUNDING_LVL_PARTY_TAX_PROF_ID,
                            --ROUNDING_LVL_PARTY_TYPE,
                            l_internal_org_loc_id,       --INTERNAL_ORG_LOCATION_ID
                            P_LINE_AMT,   --LINE_ASSESSABLE_VALUE
                            l_rate_type_code,
                            --bug 7369708
                            fnd_global.user_id,
                            sysdate,
                            fnd_global.user_id,
                            sysdate,
                            fnd_global.login_id);

       INSERT INTO ZX_LINES_DET_FACTORS( INTERNAL_ORGANIZATION_ID,
                                         APPLICATION_ID,
                                         ENTITY_CODE,
                                         EVENT_CLASS_CODE,
                                         EVENT_TYPE_CODE,
                                         LINE_LEVEL_ACTION,
                                         TRX_ID,
                                         TRX_LINE_ID,
                                         TRX_LEVEL_TYPE,
                                         TRX_DATE,
                                         TRX_LINE_GL_DATE,
                                         LEGAL_ENTITY_ID,
                                         LINE_AMT,
                                         LINE_AMT_INCLUDES_TAX_FLAG,
                                         record_type_code,
                                         object_version_number,
                                         LEDGER_ID,
                                         FIRST_PTY_ORG_ID,
                                         TRX_CURRENCY_CODE,
                                         CURRENCY_CONVERSION_DATE,
                                         CURRENCY_CONVERSION_RATE,
                                         CURRENCY_CONVERSION_TYPE,
                                         tax_processing_completed_flag,
                                         --bug 7300367
                                         TAX_EVENT_CLASS_CODE,
                                         LINE_CLASS,
                                         TRX_LINE_TYPE,
                                         TRX_NUMBER,
                                         TRX_LINE_NUMBER,
                                         ASSESSABLE_VALUE,
                                         HISTORICAL_FLAG,
                                         MINIMUM_ACCOUNTABLE_UNIT,
                                         PRECISION,
                                         TAX_REPORTING_FLAG,
                                         --bug 7300367
                                         --bug 7369708
                                         EVENT_CLASS_MAPPING_ID,
                                         DEFAULT_TAXATION_COUNTRY,
                                         --DOC_SEQ_ID,
                                         --DOC_SEQ_NAME,
                                         --DOC_SEQ_VALUE,
                                         RDNG_SHIP_FROM_PTY_TX_PROF_ID,
                                         RDNG_BILL_FROM_PTY_TX_PROF_ID,
                                         RDNG_SHIP_FROM_PTY_TX_P_ST_ID,
                                         RDNG_BILL_FROM_PTY_TX_P_ST_ID,
                                         TRX_LINE_QUANTITY,
                                         HQ_ESTB_PARTY_TAX_PROF_ID,
                                         SHIP_TO_LOCATION_ID,
                                         SHIP_FROM_LOCATION_ID,
                                         BILL_TO_LOCATION_ID,
                                         BILL_FROM_LOCATION_ID,
                                         SHIP_FROM_PARTY_TAX_PROF_ID,
                                         BILL_FROM_PARTY_TAX_PROF_ID,
                                         SHIP_FROM_SITE_TAX_PROF_ID,
                                         BILL_FROM_SITE_TAX_PROF_ID,
                                         CTRL_HDR_TX_APPL_FLAG,
                                         TRX_LINE_DATE,
                                         INTERNAL_ORG_LOCATION_ID,
                                         UNIT_PRICE,
                                         SHIP_THIRD_PTY_ACCT_SITE_ID,
                                         BILL_THIRD_PTY_ACCT_SITE_ID,
                                         SHIP_THIRD_PTY_ACCT_ID,
                                         BILL_THIRD_PTY_ACCT_ID,
                                         TRX_LINE_CURRENCY_CODE,
                                         TRX_LINE_CURRENCY_CONV_RATE,
                                         TRX_LINE_CURRENCY_CONV_DATE,
                                         TRX_LINE_PRECISION,
                                         TRX_LINE_MAU,
                                         TRX_LINE_CURRENCY_CONV_TYPE,
                                         TOTAL_INC_TAX_AMT,
                                         CREATED_BY,
                                         CREATION_DATE,
                                         LAST_UPDATED_BY,
                                         LAST_UPDATE_DATE,
                                         LAST_UPDATE_LOGIN
                                         --bug 7369708
                                         )
                                         VALUES
                                         (
                                         p_internal_organization_id,
                                         p_APPLICATION_ID,
                                         P_ENTITY_CODE,
                                         P_EVENT_CLASS_CODE,
                                         p_event_type_code,
                                         'LINE_INFO_TAX_ONLY',
                                         p_TRX_ID,
                                         l_trx_line_id,
                                         'LINE',
                                         P_TRX_DATE,
                                         p_trx_line_gl_date,
                                         p_LEGAL_ENTITY_ID,
                                         p_tax_amt,
                                         p_tax_amt_included_flag,
                                         'ETAX_CREATED',
                                         1,
                                         p_LEDGER_ID,
                                         p_content_owner_id,
                                         l_trx_currency_code, -- should be changed to p_trx_currence_code
                                         l_CURRENCY_CONVERSION_DATE,
                                         l_CURRENCY_CONVERSION_RATE,
                                         l_CURRENCY_CONVERSION_TYPE,
                                         'Y',
                                         --bug 7300367
                                         l_tax_event_class_code,
                                         P_EVENT_CLASS_CODE,
                                         'ITEM',
                                         l_trx_number,
                                         l_trx_line_number,
                                         p_line_amt,
                                         'N',
                                         p_minimum_accountable_unit,
                                         p_precision,
                                         l_tax_reporting_flag,
                                         --bug 7300367
                                         --bug 7369708
                                         l_event_class_mapping_id,  --EVENT_CLASS_MAPPING_ID
                                         l_default_taxation_country, --DEFAULT_TAXATION_COUNTRY
                                         --DOC_SEQ_ID,
                                         --DOC_SEQ_NAME,
                                         --DOC_SEQ_VALUE,
                                         l_rndg_ship_fr_pty_tx_prof_id, --RDNG_SHIP_FROM_PTY_TX_PROF_ID
                                         l_rndg_bill_fr_pty_tx_prof_id, --RDNG_BILL_FROM_PTY_TX_PROF_ID
                                         l_rndg_ship_fr_pty_tx_p_st_id, --RDNG_SHIP_FROM_PTY_TX_P_ST_ID
                                         l_rndg_bill_fr_pty_tx_p_st_id, --RDNG_BILL_FROM_PTY_TX_P_ST_ID
                                         1,                        --TRX_LINE_QUANTITY
                                         l_hq_estb_pty_tax_prof_id,--HQ_ESTB_PARTY_TAX_PROF_ID
                                         l_ship_to_location_id,     --SHIP_TO_LOCATION_ID
                                         l_ship_from_location_id,   --SHIP_FROM_LOCATION_ID
                                         l_bill_to_location_id,     --BILL_TO_LOCATION_ID
                                         l_bill_from_location_id,   --BILL_FROM_LOCATION_ID
                                         l_ship_from_pty_tax_prof_id, --SHIP_FROM_PARTY_TAX_PROF_ID
                                         l_bill_from_pty_tax_prof_id, --BILL_FROM_PARTY_TAX_PROF_ID
                                         l_ship_from_site_tx_prof_id, --SHIP_FROM_SITE_TAX_PROF_ID
                                         l_bill_from_site_tx_prof_id, --BILL_FROM_SITE_TAX_PROF_ID
                                         l_ctrl_hdr_tx_appl_flag,     --CTRL_HDR_TX_APPL_FLAG
                                         p_trx_line_date,         --TRX_LINE_DATE
                                         l_internal_org_loc_id,    --INTERNAL_ORG_LOCATION_ID
                                         p_line_amt,              --UNIT_PRICE
                                         l_ship_third_pty_acct_site_id, --SHIP_THIRD_PTY_ACCT_SITE_ID
                                         l_bill_third_pty_acct_site_id, --BILL_THIRD_PTY_ACCT_SITE_ID
                                         l_ship_third_pty_acct_id,      --SHIP_THIRD_PTY_ACCT_ID
                                         l_bill_third_pty_acct_id,       --BILL_THIRD_PTY_ACCT_ID
                                         l_trx_currency_code,         --TRX_LINE_CURRENCY_CODE
                                         l_currency_conversion_rate,  --TRX_LINE_CURRENCY_CONV_RATE
                                         l_currency_conversion_date,  --TRX_LINE_CURRENCY_CONV_DATE
                                         p_precision,                 --TRX_LINE_PRECISION
                                         p_minimum_accountable_unit,  --TRX_LINE_MAU
                                         l_currency_conversion_type,  --TRX_LINE_CURRENCY_CONV_TYPE
                                         0,                          --TOTAL_INC_TAX_AMT
                                         fnd_global.user_id,         --CREATED_BY
                                         sysdate,                    --CREATION_DATE
                                         fnd_global.user_id,         --LAST_UPDATED_BY
                                         sysdate,                    --LAST_UPDATE_DATE
                                         fnd_global.login_id         --LAST_UPDATE_LOGIN
                                         --bug 7369708

                                         );




    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRL_ALLOCATIONS_PKG.Insert_Tax_Line.BEGIN',
                     'Insert_Tax_Line (-)');
    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;

  END Insert_Tax_Line;

  PROCEDURE Populate_alloc_tbl(p_key IN VARCHAR2) IS
  BEGIN
    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TRL_ALLOCATIONS_PKG.Insert_All_Allocation',
                     'key : ' || p_key) ;
    END IF;
    g_trx_allocate_tbl(p_key) := 'Y';
   EXCEPTION
    WHEN others THEN
     NULL;
   END;
END ZX_TRL_ALLOCATIONS_PKG;

/
