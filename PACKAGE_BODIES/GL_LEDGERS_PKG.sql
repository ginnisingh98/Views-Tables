--------------------------------------------------------
--  DDL for Package Body GL_LEDGERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_LEDGERS_PKG" AS
   /*  $Header: glistldb.pls 120.99.12010000.8 2010/06/08 06:06:22 bsrikant ship $  */
   g_pkg_name   CONSTANT VARCHAR2(30) := 'GL_LEDGERS_PKG';

   --
   -- PUBLIC FUNCTIONS
   --
   FUNCTION complete_config(
      x_config_id                         NUMBER)
      RETURN VARCHAR2 IS
      CURSOR c_ledgers IS
         SELECT DISTINCT ledger.chart_of_accounts_id       -- glcd.object_id,
                    FROM gl_ledger_config_details glcd, gl_ledgers ledger
                   WHERE glcd.configuration_id = x_config_id
                     AND glcd.setup_step_code = 'NONE'
                     AND ledger.ledger_id = glcd.object_id;

      CURSOR c_all_ledgers IS
         SELECT ledger_id,ledger_category_code
           FROM gl_ledgers
          WHERE configuration_id = x_config_id;

      CURSOR c_org_curr (p_ledger_id IN VARCHAR2)  IS
          SELECT haou.organization_id
               , haou.date_from
               ,haou.name
               ,haou.type
               ,haou.internal_external_flag
               ,haou.location_id
               ,hou.set_of_books_id
               ,null usable_flag
               ,hou.short_code
               ,hou.default_legal_context_id
               ,haou.object_version_number
          FROM  hr_operating_units hou,
                hr_all_organization_units haou
          WHERE set_of_books_id = p_ledger_id
            AND haou.organization_id = hou.organization_id;


      request_id                   NUMBER         := NULL;
      return_ids                   VARCHAR2(2000) := NULL;
      x_access_set_id              NUMBER(15);
      v_security_segment_code      VARCHAR2(1);
      v_secured_seg_value_set_id   NUMBER(15);
      x_ledger_id                  NUMBER(15);
      x_name                       VARCHAR2(30);
      x_chart_of_accounts_id       NUMBER(15, 0);
      x_period_set_name            VARCHAR2(15);
      x_accounted_period_type      VARCHAR2(15);
      x_description                VARCHAR2(240);
      x_update_prim_ledger_warning BOOLEAN;
      x_duplicate_org_warning      BOOLEAN;
      pri_ledger_id                VARCHAR2(150)     := NULL;

   BEGIN

      FOR v_ledgers IN c_all_ledgers LOOP

          IF v_ledgers.ledger_category_code  = 'PRIMARY' THEN
                pri_ledger_id := to_char(v_ledgers.ledger_id);

          END IF;

         SELECT ledger_id, NAME, chart_of_accounts_id, description,
                period_set_name, accounted_period_type,
                implicit_access_set_id
           INTO x_ledger_id, x_name, x_chart_of_accounts_id, x_description,
                x_period_set_name, x_accounted_period_type,
                x_access_set_id
           FROM gl_ledgers
          WHERE ledger_id = v_ledgers.ledger_id;

         IF (x_access_set_id IS NULL) THEN
            v_security_segment_code := 'F';
            v_secured_seg_value_set_id := NULL;

            BEGIN
               x_access_set_id :=
                  gl_access_sets_pkg.create_implicit_access_set
                     (x_name => x_name,
                      x_security_segment_code => v_security_segment_code,
                      x_chart_of_accounts_id => x_chart_of_accounts_id,
                      x_period_set_name => x_period_set_name,
                      x_accounted_period_type => x_accounted_period_type,
                      x_secured_seg_value_set_id => v_secured_seg_value_set_id,
                      x_default_ledger_id => x_ledger_id,
                      x_last_updated_by => fnd_global.user_id,
                      x_last_update_login => fnd_global.login_id,
                      x_creation_date => SYSDATE,
                      x_description => x_description);
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;

            IF x_access_set_id IS NOT NULL THEN
               UPDATE gl_ledgers
                  SET implicit_access_set_id = x_access_set_id
                WHERE ledger_id = x_ledger_id;
            END IF;
         END IF;
      END LOOP;

      /*
       * Update Operating unit's descriptive flexfiled org_information6 so
       * that operating unit can be selected for entering transaction against it
       */

     for v_orgs in c_org_curr (pri_ledger_id)
     loop
       hr_organization_api.update_operating_unit
       (
         p_organization_id       => v_orgs.organization_id
        ,p_effective_date        => v_orgs.date_from
        ,p_usable_flag                       => v_orgs.usable_flag
        ,p_object_version_number             => v_orgs.object_version_number
        ,p_update_prim_ledger_warning        => x_update_prim_ledger_warning
        ,p_duplicate_org_warning             => x_duplicate_org_warning
       );
      end loop;


      FOR v_ledgers IN c_ledgers LOOP
         request_id :=
            fnd_request.submit_request('SQLGL', 'GLSTFL', '', '', FALSE,
                             'VH', to_char(v_ledgers.chart_of_accounts_id),
                                       'N', CHR(0), '', '', '', '', '', '',
                                       '', '', '', '', '', '', '', '', '',
                                       '', '', '', '', '', '', '', '', '',
                                       '', '', '', '', '', '', '', '', '',
                                       '', '', '', '', '', '', '', '', '',
                                       '', '', '', '', '', '', '', '', '',
                                       '', '', '', '', '', '', '', '', '',
                                       '', '', '', '', '', '', '', '', '',
                                       '', '', '', '', '', '', '', '', '',
                                       '', '', '', '', '', '', '', '', '',
                                       '', '', '', '', '', '', '', '', '');

         IF (return_ids IS NULL) THEN
            return_ids := TO_CHAR(request_id);
         ELSE
            return_ids := return_ids || ', ' || TO_CHAR(request_id);
         END IF;
      END LOOP;

      RETURN(return_ids);
   END;

-- *********************************************************************
-- This insert_row is used by the OA Framework Ledger page
   PROCEDURE insert_row(
      p_api_version              IN       NUMBER := 1.0,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validate_only            IN       VARCHAR2 := fnd_api.g_true,
      p_record_version_number    IN       NUMBER := NULL,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      x_rowid                    IN OUT NOCOPY VARCHAR2,
      x_ledger_id                         NUMBER,
      x_name                              VARCHAR2,
      x_short_name                        VARCHAR2,
      x_chart_of_accounts_id              NUMBER,
      x_currency_code                     VARCHAR2,
      x_period_set_name                   VARCHAR2,
      x_accounted_period_type             VARCHAR2,
      x_first_ledger_period_name          VARCHAR2,
      x_ret_earn_code_combination_id      NUMBER,
      x_suspense_allowed_flag             VARCHAR2,
      x_suspense_ccid                     NUMBER,
      x_allow_intercompany_post_flag      VARCHAR2,
      x_enable_avgbal_flag                VARCHAR2,
      x_enable_budgetary_control_f        VARCHAR2,
      x_require_budget_journals_flag      VARCHAR2,
      x_enable_je_approval_flag           VARCHAR2,
      x_enable_automatic_tax_flag         VARCHAR2,
      x_consolidation_ledger_flag         VARCHAR2,
      x_translate_eod_flag                VARCHAR2,
      x_translate_qatd_flag               VARCHAR2,
      x_translate_yatd_flag               VARCHAR2,
      x_automatically_created_flag        VARCHAR2,
      x_track_rounding_imbalance_f        VARCHAR2,
      --x_mrc_ledger_type_code              VARCHAR2,
      x_le_ledger_type_code               VARCHAR2,
      x_bal_seg_value_option_code         VARCHAR2,
      x_mgt_seg_value_option_code         VARCHAR2,
      x_last_update_date                  DATE,
      x_last_updated_by                   NUMBER,
      x_creation_date                     DATE,
      x_created_by                        NUMBER,
      x_last_update_login                 NUMBER,
      x_description                       VARCHAR2,
      x_future_enterable_periods_lmt      NUMBER,
      x_latest_opened_period_name         VARCHAR2,
      x_latest_encumbrance_year           NUMBER,
      x_cum_trans_ccid                    NUMBER,
      x_res_encumb_ccid                   NUMBER,
      x_net_income_ccid                   NUMBER,
      x_balancing_segment                 VARCHAR2,
      x_rounding_ccid                     NUMBER,
      x_transaction_calendar_id           NUMBER,
      x_daily_translation_rate_type       VARCHAR2,
      x_period_average_rate_type          VARCHAR2,
      x_period_end_rate_type              VARCHAR2,
      x_context                           VARCHAR2,
      x_attribute1                        VARCHAR2,
      x_attribute2                        VARCHAR2,
      x_attribute3                        VARCHAR2,
      x_attribute4                        VARCHAR2,
      x_attribute5                        VARCHAR2,
      x_attribute6                        VARCHAR2,
      x_attribute7                        VARCHAR2,
      x_attribute8                        VARCHAR2,
      x_attribute9                        VARCHAR2,
      x_attribute10                       VARCHAR2,
      x_attribute11                       VARCHAR2,
      x_attribute12                       VARCHAR2,
      x_attribute13                       VARCHAR2,
      x_attribute14                       VARCHAR2,
      x_attribute15                       VARCHAR2,
      x_set_manual_flag                   VARCHAR2,
      --x_child_ledger_access_code          VARCHAR2,
      x_ledger_category_code              VARCHAR2,
      x_configuration_id                  NUMBER,
      x_sla_accounting_method_code        VARCHAR2,
      x_sla_accounting_method_type        VARCHAR2,
      x_sla_description_language          VARCHAR2,
      x_sla_entered_cur_bal_sus_ccid      NUMBER,
      x_sla_bal_by_ledger_curr_flag       VARCHAR2,
      x_sla_ledger_cur_bal_sus_ccid       NUMBER,
      x_alc_ledger_type_code              VARCHAR2,
      x_criteria_set_id                   NUMBER,
      x_enable_secondary_track_flag       VARCHAR2 DEFAULT 'N',
      x_enable_reval_ss_track_flag        VARCHAR2 DEFAULT 'N',
      x_enable_reconciliation_flag        VARCHAR2 DEFAULT 'N',
      x_sla_ledger_cash_basis_flag        VARCHAR2 DEFAULT 'N',
      x_create_je_flag                    VARCHAR2 DEFAULT 'Y',
      x_commitment_budget_flag            VARCHAR2 DEFAULT NULL,
      x_net_closing_bal_flag              VARCHAR2 DEFAULT 'N',
      x_auto_jrnl_rev_flag                VARCHAR2 DEFAULT 'N') IS
      CURSOR c IS
         SELECT ROWID
           FROM gl_ledgers
          WHERE NAME = x_name;

      l_api_version                NUMBER        := p_api_version;
      l_api_name          CONSTANT VARCHAR(30)   := 'insert_row';
      --x_access_set_id          NUMBER(15);
      --v_security_segment_code      VARCHAR2(1);
      --v_secured_seg_value_set_id   NUMBER(15);
      x_bal_seg_column_name        VARCHAR2(25);
      x_bal_seg_value_set_id       NUMBER(10, 0);
      x_mgt_seg_column_name        VARCHAR2(25);
      x_mgt_seg_value_set_id       NUMBER(10, 0);
      x_period_type                VARCHAR2(15);
      t_period_average_rate_type   VARCHAR2(30);
      t_period_end_rate_type       VARCHAR2(30);
      t_sla_description_language   VARCHAR2(15);
      t_criteria_set_id            NUMBER(15, 0);
      x_suspense_ccid_temp         NUMBER;
      v_CursorID                   INTEGER;
      v_Dummy                      INTEGER;
      v_CursorSQL                  VARCHAR2(300);
      v_balancing_segment          VARCHAR2(30);
      temp                         NUMBER;
      v_first_ledger_period_name   VARCHAR2(15);
      period_counter               NUMBER := 1;
      l_complete_flag              VARCHAR2(1);
      l_status_code                VARCHAR2(30);
      CURSOR first_ledger_period IS
        select period_name
        from gl_periods
        where period_set_name = x_period_set_name
        and period_type = x_accounted_period_type
        order by period_year, period_num;
      CURSOR get_config_status IS
        select completion_status_code
        from gl_ledger_configurations
        where configuration_id = x_configuration_id;
   BEGIN
      IF p_commit = fnd_api.g_true THEN
         SAVEPOINT complete_workorder;
      END IF;

      IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version,
                                         l_api_name, g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF fnd_api.to_boolean(p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

      x_return_status := fnd_api.g_ret_sts_success;

      -- Default the first period of the ledger to the second period in the calendar.
      OPEN first_ledger_period;
      LOOP
        FETCH first_ledger_period INTO v_first_ledger_period_name;
        IF (period_counter = 1 AND v_first_ledger_period_name IS NOT NULL) THEN
           EXIT;
        ELSIF(v_first_ledger_period_name IS NULL) THEN
           fnd_message.set_name('SQLGL', 'GL_LEDGER_ENABLE_STS_FLAG');
           app_exception.raise_exception;
        END IF;
        period_counter := period_counter + 1;
      END LOOP;
      CLOSE first_ledger_period;

      -- Validate secondary tracking flag - Ledger API checks.
      IF (x_enable_secondary_track_flag = 'Y') THEN
          IF (FND_FLEX_APIS.get_qualifier_segnum(101,'GL#',x_chart_of_accounts_id,'GL_SECONDARY_TRACKING',temp) = FALSE) THEN
             fnd_message.set_name('SQLGL', 'GL_API_LEDGER_CHK_SECD_SEG');
             app_exception.raise_exception;
          END IF;
          IF(x_enable_avgbal_flag = 'Y') THEN
             fnd_message.set_name('SQLGL', 'GL_LEDGER_ENABLE_STS_FLAG');
             app_exception.raise_exception;
          END IF;
      END IF;

      -- Validate secondary tracking for revaluation flag - Ledger API checks
      IF (x_enable_reval_ss_track_flag = 'Y') THEN
          IF (FND_FLEX_APIS.get_qualifier_segnum(101,'GL#',x_chart_of_accounts_id,'GL_SECONDARY_TRACKING',temp) = FALSE) THEN
             fnd_message.set_name('SQLGL', 'GL_API_LEDGER_CHK_SECD_SEG');
             app_exception.raise_exception;
          END IF;
      END IF;

      -- Create an implicit access set header for the corresponding new created
      -- ledger and retrieve its ID.
      -- The security segment code must be 'M' for Management Ledgers and
      -- 'F' for Legal and Upgrade Ledgers.
      -- The secured segment value set id should be X_Mgt_Seg_Value_Set_Id for
      -- Management Ledgers and null for Legal and Upgrade Ledgers.

      /* Now the Implicit access sets are ledger Implicit sets only modified
         Srini Pala*/
      --IF (X_Le_Ledger_Type_Code = 'M') THEN
      /*
      v_security_segment_code := 'F';
      v_secured_seg_value_set_id := NULL; -- X_Mgt_Seg_Value_Set_Id;
      x_access_set_id :=
            gl_access_sets_pkg.create_implicit_access_set(
               x_name => x_name,
               x_security_segment_code => v_security_segment_code,
               x_chart_of_accounts_id => x_chart_of_accounts_id,
               x_period_set_name => x_period_set_name,
               x_accounted_period_type => x_accounted_period_type,
               x_secured_seg_value_set_id => v_secured_seg_value_set_id,
               x_default_ledger_id => x_ledger_id,
               x_last_updated_by => x_last_updated_by,
               x_last_update_login => x_last_update_login,
               x_creation_date => x_creation_date,
               x_description => x_description); */

      -- get the balance segment infor and mgt segment infor
      gl_ledgers_pkg.get_bal_mgt_seg_info(x_bal_seg_column_name,
                                          x_bal_seg_value_set_id,
                                          x_mgt_seg_column_name,
                                          x_mgt_seg_value_set_id,
                                          x_chart_of_accounts_id);

      IF x_net_income_ccid IS NOT NULL THEN
         BEGIN
            v_CursorSQL :=
               'SELECT ' || x_bal_seg_column_name
               || ' FROM gl_code_combinations WHERE chart_of_accounts_id = :1 '
               || ' AND code_combination_id = :2 ';
            EXECUTE IMMEDIATE v_CursorSQL INTO v_balancing_segment
                    USING x_chart_of_accounts_id, x_net_income_ccid;

         EXCEPTION
            WHEN OTHERS THEN
               v_balancing_segment := x_balancing_segment;
         END;
      ELSE
         v_balancing_segment := x_balancing_segment;
      END IF;

----- temporary validation starts
    IF x_period_average_rate_type IS NOT NULL THEN
      BEGIN
         SELECT conversion_type
           INTO t_period_average_rate_type
           FROM gl_daily_conversion_types_v
          WHERE conversion_type <> 'User'
            AND conversion_type <> 'EMU FIXED'
            AND conversion_type = x_period_average_rate_type;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            --fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name,
            --                        'Invalid period_average_rate_type');
            fnd_message.set_name('SQLGL', 'GL_ASF_LGR_NEED_PAVE_RATETYPE');
            fnd_msg_pub.ADD;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
      END;
    END IF;

    IF x_period_end_rate_type IS NOT NULL THEN
      BEGIN
         SELECT conversion_type
           INTO t_period_end_rate_type
           FROM gl_daily_conversion_types_v
          WHERE conversion_type <> 'User'
            AND conversion_type <> 'EMU FIXED'
            AND conversion_type = x_period_end_rate_type;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            fnd_message.set_name('SQLGL', 'GL_ASF_LGR_NEED_PEND_RATETYPE');
            fnd_msg_pub.ADD;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
      END;
    END IF;

/*      IF x_sla_accounting_method_code IS NOT NULL THEN
         BEGIN
            SELECT language_code
              INTO t_sla_description_language
              FROM fnd_languages_vl
             WHERE (installed_flag = 'I' OR installed_flag = 'B')
               AND language_code = x_sla_description_language;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               fnd_message.set_name('SQLGL', 'GL_ASF_LGR_NEED_JE_DESC');
               fnd_msg_pub.ADD;
               x_return_status := fnd_api.g_ret_sts_unexp_error;
         END;
      END IF;*/

      IF x_criteria_set_id IS NOT NULL THEN
         BEGIN
            SELECT criteria_set_id
              INTO t_criteria_set_id
              FROM gl_autorev_criteria_sets
             WHERE criteria_set_id = x_criteria_set_id;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               fnd_message.set_name('SQLGL',
                                    'GL_ASF_LGR_JE_REVERSAL_INVALID');
               fnd_msg_pub.ADD;
               x_return_status := fnd_api.g_ret_sts_unexp_error;
         END;
      END IF;

      IF(x_ledger_category_code = 'ALC') THEN
        OPEN get_config_status;
        FETCH get_config_status INTO l_status_code;
        IF(get_config_status%FOUND AND l_status_code = 'CONFIRMED') THEN
           l_complete_flag := 'Y';
        ELSE
           l_complete_flag := 'N';
        END IF;
      ELSE
        l_complete_flag := 'N';
      END IF;

----- temporary validation ends
      INSERT INTO gl_ledgers
                  (ledger_id, NAME, short_name, chart_of_accounts_id,
                   currency_code, period_set_name,
                   accounted_period_type, first_ledger_period_name,
                   ret_earn_code_combination_id, suspense_allowed_flag,
                   allow_intercompany_post_flag,
                   enable_average_balances_flag,
                   enable_budgetary_control_flag,
                   require_budget_journals_flag, enable_je_approval_flag,
                   enable_automatic_tax_flag, consolidation_ledger_flag,
                   translate_eod_flag, translate_qatd_flag,
                   translate_yatd_flag, automatically_created_flag,
                   track_rounding_imbalance_flag,-- mrc_ledger_type_code,
                   object_type_code, le_ledger_type_code,
                   bal_seg_value_option_code, bal_seg_column_name,
                   bal_seg_value_set_id, mgt_seg_value_option_code,
                   mgt_seg_column_name, mgt_seg_value_set_id,
                   implicit_access_set_id, last_update_date, last_updated_by,
                   creation_date, created_by, last_update_login,
                   description, future_enterable_periods_limit,
                   ledger_attributes, latest_opened_period_name,
                   latest_encumbrance_year, cum_trans_code_combination_id,
                   res_encumb_code_combination_id,
                   net_income_code_combination_id,
                   rounding_code_combination_id, transaction_calendar_id,
                   daily_translation_rate_type, period_average_rate_type,
                   period_end_rate_type, CONTEXT, attribute1,
                   attribute2, attribute3, attribute4, attribute5,
                   attribute6, attribute7, attribute8, attribute9,
                   attribute10, attribute11, attribute12,
                   attribute13, attribute14, attribute15,
                   --child_ledger_access_code,
                   ledger_category_code, configuration_id,
                   sla_accounting_method_code,
                   sla_accounting_method_type, sla_description_language,
                   sla_entered_cur_bal_sus_ccid,
                   sla_bal_by_ledger_curr_flag,
                   sla_ledger_cur_bal_sus_ccid, alc_ledger_type_code,
                   criteria_set_id,enable_secondary_track_flag,
                   enable_reval_ss_track_flag, enable_reconciliation_flag,
                   sla_ledger_cash_basis_flag, create_je_flag, complete_flag,commitment_budget_flag,net_closing_bal_flag,automate_sec_jrnl_rev_flag)
           VALUES (x_ledger_id, x_name, x_short_name, x_chart_of_accounts_id,
                   x_currency_code, x_period_set_name,
                   x_accounted_period_type, decode(x_ledger_category_code,'ALC',
                   x_first_ledger_period_name,v_first_ledger_period_name),
                   x_ret_earn_code_combination_id, x_suspense_allowed_flag,
                   x_allow_intercompany_post_flag,
                   x_enable_avgbal_flag,
                   x_enable_budgetary_control_f,
                   x_require_budget_journals_flag, x_enable_je_approval_flag,
                   x_enable_automatic_tax_flag, x_consolidation_ledger_flag,
                   x_translate_eod_flag, x_translate_qatd_flag,
                   x_translate_yatd_flag, x_automatically_created_flag,
                   x_track_rounding_imbalance_f, --x_mrc_ledger_type_code,
                   'L', x_le_ledger_type_code,
                   x_bal_seg_value_option_code, x_bal_seg_column_name,
                   x_bal_seg_value_set_id, x_mgt_seg_value_option_code,
                   x_mgt_seg_column_name, x_mgt_seg_value_set_id,
                   NULL, x_last_update_date, x_last_updated_by,
                   x_creation_date, x_created_by, x_last_update_login,
                   x_description, x_future_enterable_periods_lmt,
                   'L',
                       -- 'Y' || fnd_global.newline || 'Y' || fnd_global.newline || 'L',
                       x_latest_opened_period_name,
                   x_latest_encumbrance_year, x_cum_trans_ccid,
                   x_res_encumb_ccid,
                   x_net_income_ccid,
                   x_rounding_ccid, x_transaction_calendar_id,
                   x_daily_translation_rate_type, x_period_average_rate_type,
                   x_period_end_rate_type, x_context, x_attribute1,
                   x_attribute2, x_attribute3, x_attribute4, x_attribute5,
                   x_attribute6, x_attribute7, x_attribute8, x_attribute9,
                   x_attribute10, x_attribute11, x_attribute12,
                   x_attribute13, x_attribute14, x_attribute15,
                   --x_child_ledger_access_code,
                   x_ledger_category_code, x_configuration_id,
                   x_sla_accounting_method_code,
                   x_sla_accounting_method_type, x_sla_description_language,
                   x_sla_entered_cur_bal_sus_ccid,
                   x_sla_bal_by_ledger_curr_flag,
                   x_sla_ledger_cur_bal_sus_ccid, x_alc_ledger_type_code,
                   x_criteria_set_id, x_enable_secondary_track_flag,
                   x_enable_reval_ss_track_flag, x_enable_reconciliation_flag,
                   x_sla_ledger_cash_basis_flag, x_create_je_flag, l_complete_flag,x_commitment_budget_flag,x_net_closing_bal_flag,x_auto_jrnl_rev_flag);

      OPEN c;

      FETCH c
       INTO x_rowid;

      IF (c%NOTFOUND) THEN
         CLOSE c;

         --RAISE NO_DATA_FOUND;
         --The following new style is used for transferring error message back to OA FWK page
         fnd_msg_pub.ADD;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
      END IF;

      CLOSE c;

      -- Insert rows into gl_concurrency_control table for the
      -- corresponding new created ledger.
      -- Should be GL_CONC_CONTROL_PKG.insert_conc_ledger(
      gl_conc_control_pkg.insert_conc_ledger(x_ledger_id, x_last_update_date,
                                             x_last_updated_by,
                                             x_creation_date, x_created_by,
                                             x_last_update_login);

      -- Insert rows into gl_period_statuses table for the
      -- corresponding new created ledger.
      BEGIN
         gl_period_statuses_pkg.insert_led_ps(x_ledger_id, x_period_set_name,
                                              x_accounted_period_type,
                                              x_last_update_date,
                                              x_last_updated_by,
                                              x_last_update_login,
                                              x_creation_date, x_created_by);
      EXCEPTION
         WHEN OTHERS THEN
            fnd_msg_pub.ADD;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            IF sqlerrm is not null
            then
              fnd_message.set_name('SQLGL', 'DB-ERROR');
              fnd_message.set_token  ('Message ', sqlerrm);
              fnd_msg_pub.add;
            END IF;
      END;

      -- Insert rows into gl_autoreverse_options table for the
      -- new ledger
      -- gl_autoreverse_options_pkg.insert_ledger_reversal_cat(
      --   x_ledger_id, x_created_by, x_last_updated_by, x_last_update_login);
      -- Need comments this out as Srini requested for Sep 30 code freeze

      -- Insert rows into gl_suspense_accounts table for the
      -- corresponding new created ledger.
      BEGIN
         SELECT code_combination_id
           INTO x_suspense_ccid_temp
           FROM gl_code_combinations
          WHERE code_combination_id = x_suspense_ccid;
      EXCEPTION
         WHEN OTHERS THEN
            x_suspense_ccid_temp := NULL;
      END;

      IF (    (x_suspense_allowed_flag = 'Y')
          AND (x_suspense_ccid_temp IS NOT NULL)) THEN
         -- bug fix 2826511
         gl_suspense_accounts_pkg.insert_ledger_suspense
                                                       (x_ledger_id,
                                                        x_suspense_ccid_temp,
                                                        x_last_update_date,
                                                        x_last_updated_by);
      END IF;

      -- Insert rows into gl_ledger_legal_entities table for the
      -- corresponding new created ledger.

      -- Removed LOGIC, SAGAR TAROON KAMDAR

      -- Check whether journal_approval_flag is to be set to Y for
      -- the Manual source.
      IF (x_set_manual_flag = 'Y') THEN
         gl_ledgers_pkg.enable_manual_je_approval;
      END IF;

      IF (x_enable_avgbal_flag = 'Y') THEN
         gl_ledgers_pkg.update_gl_system_usages(x_consolidation_ledger_flag);
         gl_ledgers_pkg.insert_gl_net_income_accounts(x_ledger_id,
                                                      v_balancing_segment,

                                                      --x_balancing_segment,
                                                      x_net_income_ccid,
                                                      x_creation_date,
                                                      x_created_by,
                                                      x_last_update_date,
                                                      x_last_updated_by,
                                                      x_last_update_login,
                                                      '', '', '', '');
      END IF;

      x_msg_count := fnd_msg_pub.count_msg;
      x_msg_data := fnd_message.get;

      IF x_msg_count > 0 THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_error;
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error THEN
         IF p_commit = fnd_api.g_true THEN
            ROLLBACK TO complete_workorder;
         END IF;

         fnd_msg_pub.add_exc_msg(p_pkg_name => g_pkg_name,
                                 p_procedure_name => l_api_name);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
      WHEN fnd_api.g_exc_error THEN
         IF p_commit = fnd_api.g_true THEN
            ROLLBACK TO complete_workorder;
         END IF;

         fnd_msg_pub.add_exc_msg(p_pkg_name => g_pkg_name,
                                 p_procedure_name => l_api_name);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
      WHEN OTHERS THEN
         IF p_commit = fnd_api.g_true THEN
            ROLLBACK TO complete_workorder;
         END IF;

         fnd_msg_pub.add_exc_msg(p_pkg_name => g_pkg_name,
                                 p_procedure_name => l_api_name);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
   END insert_row;

-- **********************************************************************
-- This update_row is used by the OA Framework Ledger page
   PROCEDURE update_row(
      p_api_version              IN       NUMBER := 1.0,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validate_only            IN       VARCHAR2 := fnd_api.g_true,
      p_record_version_number    IN       NUMBER := NULL,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      x_rowid                             VARCHAR2,
      x_ledger_id                         NUMBER,
      x_name                              VARCHAR2,
      x_short_name                        VARCHAR2,
      x_chart_of_accounts_id              NUMBER,
      x_currency_code                     VARCHAR2,
      x_period_set_name                   VARCHAR2,
      x_accounted_period_type             VARCHAR2,
      x_first_ledger_period_name          VARCHAR2,
      x_ret_earn_code_combination_id      NUMBER,
      x_suspense_allowed_flag             VARCHAR2,
      x_suspense_ccid                     NUMBER,
      x_allow_intercompany_post_flag      VARCHAR2,
      x_enable_avgbal_flag                VARCHAR2,
      x_enable_budgetary_control_f        VARCHAR2,
      x_require_budget_journals_flag      VARCHAR2,
      x_enable_je_approval_flag           VARCHAR2,
      x_enable_automatic_tax_flag         VARCHAR2,
      x_consolidation_ledger_flag         VARCHAR2,
      x_translate_eod_flag                VARCHAR2,
      x_translate_qatd_flag               VARCHAR2,
      x_translate_yatd_flag               VARCHAR2,
      x_automatically_created_flag        VARCHAR2,
      x_track_rounding_imbalance_f        VARCHAR2,
      --x_mrc_ledger_type_code              VARCHAR2,
      x_le_ledger_type_code               VARCHAR2,
      x_bal_seg_value_option_code         VARCHAR2,
      x_mgt_seg_value_option_code         VARCHAR2,
      x_implicit_access_set_id            NUMBER,
      x_last_update_date                  DATE,
      x_last_updated_by                   NUMBER,
      x_last_update_login                 NUMBER,
      x_description                       VARCHAR2,
      x_future_enterable_periods_lmt      NUMBER,
      x_latest_opened_period_name         VARCHAR2,
      x_latest_encumbrance_year           NUMBER,
      x_cum_trans_ccid                    NUMBER,
      x_res_encumb_ccid                   NUMBER,
      x_net_income_ccid                   NUMBER,
      x_balancing_segment                 VARCHAR2,
      x_rounding_ccid                     NUMBER,
      x_transaction_calendar_id           NUMBER,
      x_daily_translation_rate_type       VARCHAR2,
      x_period_average_rate_type          VARCHAR2,
      x_period_end_rate_type              VARCHAR2,
      x_context                           VARCHAR2,
      x_attribute1                        VARCHAR2,
      x_attribute2                        VARCHAR2,
      x_attribute3                        VARCHAR2,
      x_attribute4                        VARCHAR2,
      x_attribute5                        VARCHAR2,
      x_attribute6                        VARCHAR2,
      x_attribute7                        VARCHAR2,
      x_attribute8                        VARCHAR2,
      x_attribute9                        VARCHAR2,
      x_attribute10                       VARCHAR2,
      x_attribute11                       VARCHAR2,
      x_attribute12                       VARCHAR2,
      x_attribute13                       VARCHAR2,
      x_attribute14                       VARCHAR2,
      x_attribute15                       VARCHAR2,
      x_set_manual_flag                   VARCHAR2,
      --x_child_ledger_access_code          VARCHAR2,
      x_ledger_category_code              VARCHAR2,
      x_configuration_id                  NUMBER,
      x_sla_accounting_method_code        VARCHAR2,
      x_sla_accounting_method_type        VARCHAR2,
      x_sla_description_language          VARCHAR2,
      x_sla_entered_cur_bal_sus_ccid      NUMBER,
      x_sla_bal_by_ledger_curr_flag       VARCHAR2,
      x_sla_ledger_cur_bal_sus_ccid       NUMBER,
      x_alc_ledger_type_code              VARCHAR2,
      x_criteria_set_id                   NUMBER,
      x_enable_secondary_track_flag       VARCHAR2 DEFAULT 'N',
      x_enable_reval_ss_track_flag        VARCHAR2 DEFAULT 'N',
      x_enable_reconciliation_flag        VARCHAR2 DEFAULT 'N',
      x_sla_ledger_cash_basis_flag        VARCHAR2 DEFAULT 'N',
      x_create_je_flag                    VARCHAR2 DEFAULT 'Y',
      x_commitment_budget_flag            VARCHAR2 DEFAULT NULL,
      x_net_closing_bal_flag              VARCHAR2 DEFAULT 'N',
      x_auto_jrnl_rev_flag                VARCHAR2 DEFAULT 'N') IS
      l_api_version                    NUMBER        := p_api_version;
      l_api_name              CONSTANT VARCHAR(30)   := 'update_row';
      x_access_set_id                  NUMBER(15);
      v_security_segment_code          VARCHAR2(1);
      v_secured_seg_value_set_id       NUMBER(15);
      x_bal_seg_column_name            VARCHAR2(25);
      x_bal_seg_value_set_id           NUMBER(10, 0);
      x_mgt_seg_column_name            VARCHAR2(25);
      x_mgt_seg_value_set_id           NUMBER(10, 0);
      x_period_type                    VARCHAR2(15);
      x_current_bsv_option_code        VARCHAR2(30);
      x_current_sla_actg_method_code   VARCHAR2(30);
      x_current_sla_actg_method_type   VARCHAR2(30);
      x_current_name                   VARCHAR2(30);
      x_current_short_name             VARCHAR2(20);
      x_current_allow_intercom_flag    VARCHAR2(1);
      x_cum_trans_ccid_temp            NUMBER;
      x_res_encumb_ccid_temp           NUMBER;
      x_net_income_ccid_temp           NUMBER;
      x_rounding_ccid_temp             NUMBER;
      x_suspense_ccid_temp             NUMBER;
      p_sla_accounting_method_code     VARCHAR2(30)  := NULL;
      p_sla_accounting_method_type     VARCHAR2(1)   := NULL;
      p_sla_description_language       VARCHAR2(15)  := NULL;
      p_sla_entered_cur_bal_sus_ccid   NUMBER(15, 0) := NULL;
      p_sla_sequencing_flag            VARCHAR2(1)   := NULL;
      p_sla_bal_by_ledger_curr_flag    VARCHAR2(1)   := NULL;
      p_sla_ledger_cur_bal_sus_ccid    NUMBER(15, 0) := NULL;
      x_acctg_environment_code         VARCHAR2(30);
      t_period_average_rate_type       VARCHAR2(30);
      t_period_end_rate_type           VARCHAR2(30);
      t_sla_description_language       VARCHAR2(15);
      t_criteria_set_id                NUMBER(15, 0);
      v_balancing_segment          VARCHAR2(30);
      v_CursorID                   INTEGER;
      v_Dummy                      INTEGER;
      v_CursorSQL                  VARCHAR2(300);
      x_completion_status          VARCHAR2(30);

      CURSOR c_primary_ledgers IS
         SELECT DISTINCT object_id
                    FROM gl_ledger_config_details
                   WHERE object_type_code = 'PRIMARY'
                     AND setup_step_code = 'NONE'
                     AND configuration_id IN(
                            SELECT configuration_id
                              FROM gl_ledger_config_details
                             WHERE object_type_code = 'SECONDARY'
                               AND setup_step_code = 'NONE'
                               AND object_id = x_ledger_id);

      -- Added by LPOON on 11/20/03: Used to loop for each ALC to default GL
      -- suspense CCID from the source
      -- Modified by LPOON on 11/21/03: Join with GL_LEDGERS table to make
      -- sure the ALC ledger which has been created already
      CURSOR c_alc_ledgers IS
         SELECT DISTINCT rs.target_ledger_id
                    FROM gl_ledger_relationships rs, gl_ledgers lg
                   WHERE rs.source_ledger_id = x_ledger_id
                     AND rs.application_id = 101
                     AND rs.target_ledger_category_code = 'ALC'
                     AND rs.relationship_type_code in ('JOURNAL', 'SUBLEDGER')
                     AND lg.ledger_id = rs.target_ledger_id;
      CURSOR c IS
         SELECT        *
                  FROM gl_ledgers
                 WHERE ledger_id = x_ledger_id;

      recinfo   c%ROWTYPE;
      l_ret_changed                     VARCHAR2(1)     :='N';
      l_suspense_changed                VARCHAR2(1)     :='N';
      l_intercom_changed                VARCHAR2(1)     :='N';
      l_cta_changed                     VARCHAR2(1)     :='N';
      l_reserv_encum_changed            VARCHAR2(1)     :='N';
      l_autotax_changed                 VARCHAR2(1)     :='N';
      l_trans_eod_changed               VARCHAR2(1)     :='N';
      l_trans_qatd_changed              VARCHAR2(1)     :='N';
      l_trans_yatd_changed              VARCHAR2(1)     :='N';
      l_period_avg_rt_changed           VARCHAR2(1)     :='N';
      l_period_end_rt_changed           VARCHAR2(1)     :='N';
      temp                        NUMBER;
   BEGIN
      IF p_commit = fnd_api.g_true THEN
         SAVEPOINT complete_workorder;
      END IF;

      IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version,
                                         l_api_name, g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF fnd_api.to_boolean(p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

      x_return_status := fnd_api.g_ret_sts_success;

      -- Ledger API checks
      OPEN c;
      FETCH c
       INTO recinfo;

      IF (c%NOTFOUND) THEN
         CLOSE c;

         RAISE NO_DATA_FOUND;
      END IF;

      CLOSE c;

      IF (recinfo.ret_earn_code_combination_id <> x_ret_earn_code_combination_id) THEN
        l_ret_changed := 'Y';
      END IF;
      IF (recinfo.suspense_allowed_flag <> x_suspense_allowed_flag) THEN
        l_suspense_changed := 'Y';
      END IF;
      IF (recinfo.allow_intercompany_post_flag <> x_allow_intercompany_post_flag) THEN
        l_intercom_changed := 'Y';
      END IF;
      IF (recinfo.cum_trans_code_combination_id <> x_cum_trans_ccid) THEN
        l_cta_changed := 'Y';
      END IF;
      IF (recinfo.res_encumb_code_combination_id <> x_res_encumb_ccid) THEN
        l_reserv_encum_changed := 'Y';
      END IF;
      IF (recinfo.enable_automatic_tax_flag <> x_enable_automatic_tax_flag) THEN
        l_autotax_changed := 'Y';
      END IF;
      IF (recinfo.translate_eod_flag <> x_translate_eod_flag) THEN
        l_trans_eod_changed := 'Y';
      END IF;
      IF (recinfo.translate_qatd_flag <> x_translate_qatd_flag) THEN
        l_trans_qatd_changed := 'Y';
      END IF;
      IF (recinfo.translate_yatd_flag <> x_translate_yatd_flag) THEN
        l_trans_yatd_changed := 'Y';
      END IF;
      IF (recinfo.period_average_rate_type <> x_period_average_rate_type) THEN
        l_period_avg_rt_changed := 'Y';
      END IF;
      IF (recinfo.period_end_rate_type <> x_period_end_rate_type) THEN
        l_period_end_rt_changed := 'Y';
      END IF;

      IF(x_ledger_category_code IN('PRIMARY','SECONDARY')
         AND recinfo.ret_earn_code_combination_id = -1
         AND recinfo.sla_accounting_method_code IS NOT NULL) THEN
        IF(x_ledger_category_code = 'PRIMARY')THEN
            xla_acct_setup_pub_pkg.setup_ledger_options
                                             (x_ledger_id,
                                              x_ledger_id);
        ELSE
            FOR v_primary_ledgers IN c_primary_ledgers LOOP
               xla_acct_setup_pub_pkg.setup_ledger_options
                                             (v_primary_ledgers.object_id,
                                              x_ledger_id);
            END LOOP;
        END IF;
      END IF;

      --  Updating budgetary control flag from Y to N
      IF ((recinfo.enable_budgetary_control_flag = 'Y') AND (x_enable_budgetary_control_f = 'N')) THEN
          IF (GL_SUMMARY_TEMPLATES_PKG.is_funds_check_not_none(x_ledger_Id)) THEN
             fnd_message.set_name('SQLGL', 'GL_DISABLE_BUDGETARY_CONTROL');
             app_exception.raise_exception;
          END IF;
          IF (GL_BUD_ASSIGN_RANGE_PKG.is_funds_check_not_none(x_ledger_Id)) THEN
             fnd_message.set_name('SQLGL', 'GL_DISABLE_BUDGETARY_CONTROL');
             app_exception.raise_exception;
          END IF;
      END IF;

      --  Updating budget journals flag from N to Y
      IF ((recinfo.require_budget_journals_flag = 'N') AND (x_require_budget_journals_flag = 'Y')) THEN
         IF (GL_BUDGETS_PKG.is_budget_journals_not_req(x_ledger_Id)) THEN
             fnd_message.set_name('SQLGL', 'GL_FAIL_REQUIRE_BUDGET_JOURNAL');
             app_exception.raise_exception;
         END IF;
      END IF;

      -- Updating average balances translation options
      IF ((recinfo.translate_eod_flag <> x_translate_eod_flag) OR
         (recinfo.translate_qatd_flag <> x_translate_qatd_flag) OR
         (recinfo.translate_yatd_flag <> x_translate_yatd_flag)) THEN
          IF (GL_LEDGERS_PKG.Check_Avg_Translation(x_ledger_Id)) THEN
             fnd_message.set_name('SQLGL', 'GL_LEDGER_TRANSLATION_FLAGS');
             app_exception.raise_exception;
          END IF;
      END IF;

      -- Updating MRC ledger type code from N to R or P
--      IF ((old_mrc_ledger_type_code <> 'N') AND (x_mrc_ledger_type_code <> old_mrc_ledger_type_code)) THEN
--         fnd_message.set_name('SQLGL', 'GL_API_LEDGER_MRC_SOB_NOT_UPDATE');
 --        app_exception.raise_exception;
 --     END IF;

      IF (recinfo.enable_reval_ss_track_flag = 'N' AND x_enable_reval_ss_track_flag = 'Y') THEN
          IF (FND_FLEX_APIS.get_qualifier_segnum(101,'GL#',x_chart_of_accounts_id,'GL_SECONDARY_TRACKING',temp) = FALSE) THEN
             fnd_message.set_name('SQLGL', 'GL_API_LEDGER_CHK_SECD_SEG');
             app_exception.raise_exception;
          END IF;
      END IF;
      -- end of Ledger API checks.

----- temporary validation starts
     IF x_period_average_rate_type IS NOT NULL THEN
        BEGIN
           SELECT conversion_type
             INTO t_period_average_rate_type
             FROM gl_daily_conversion_types_v
            WHERE conversion_type <> 'User'
              AND conversion_type <> 'EMU FIXED'
              AND conversion_type = x_period_average_rate_type;
        EXCEPTION
           WHEN NO_DATA_FOUND THEN
              fnd_message.set_name('SQLGL', 'GL_ASF_LGR_NEED_PAVE_RATETYPE');
              fnd_msg_pub.ADD;
              x_return_status := fnd_api.g_ret_sts_unexp_error;
        END;
     END IF;

     IF x_period_end_rate_type IS NOT NULL THEN
        BEGIN
           SELECT conversion_type
             INTO t_period_end_rate_type
             FROM gl_daily_conversion_types_v
            WHERE conversion_type <> 'User'
              AND conversion_type <> 'EMU FIXED'
              AND conversion_type = x_period_end_rate_type;
        EXCEPTION
           WHEN NO_DATA_FOUND THEN
              fnd_message.set_name('SQLGL', 'GL_ASF_LGR_NEED_PEND_RATETYPE');
              fnd_msg_pub.ADD;
              x_return_status := fnd_api.g_ret_sts_unexp_error;
        END;
      END IF;

      IF x_sla_accounting_method_code IS NOT NULL THEN
         BEGIN
            SELECT language_code
              INTO t_sla_description_language
              FROM fnd_languages_vl
             WHERE (installed_flag = 'I' OR installed_flag = 'B')
               AND language_code = x_sla_description_language;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               fnd_message.set_name('SQLGL', 'GL_ASF_LGR_NEED_JE_DESC');
               fnd_msg_pub.ADD;
               x_return_status := fnd_api.g_ret_sts_unexp_error;
         END;
      END IF;

      IF x_criteria_set_id IS NOT NULL THEN
         BEGIN
            SELECT criteria_set_id
              INTO t_criteria_set_id
              FROM gl_autorev_criteria_sets
             WHERE criteria_set_id = x_criteria_set_id;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               fnd_message.set_name('SQLGL',
                                    'GL_ASF_LGR_JE_REVERSAL_INVALID');
               fnd_msg_pub.ADD;
               x_return_status := fnd_api.g_ret_sts_unexp_error;
         END;
      END IF;

      ----- temporary validation ends
      SELECT NAME, short_name
        INTO x_current_name, x_current_short_name
        FROM gl_ledgers
       WHERE ledger_id = x_ledger_id;

      IF (x_current_name <> x_name) THEN
         -- Added where clauses to exclude ALC balance level relationships
         UPDATE gl_ledger_relationships
            SET target_ledger_name = x_name
          WHERE target_ledger_id = x_ledger_id
            AND (   target_ledger_category_code <> 'ALC'
                 OR (    target_ledger_category_code = 'ALC'
                     AND relationship_type_code <> 'BALANCE'));
      END IF;

      IF (x_current_short_name <> x_short_name) THEN
         -- Added where clauses to exclude ALC balance level relationships
         UPDATE gl_ledger_relationships
            SET target_ledger_short_name = x_short_name
          WHERE target_ledger_id = x_ledger_id
            AND (   target_ledger_category_code <> 'ALC'
                 OR (    target_ledger_category_code = 'ALC'
                     AND relationship_type_code <> 'BALANCE'));
      END IF;

      -- the following logic will be moved to a API package for table GL_LEDGER_CONFIG_details
      IF (   (x_ledger_category_code = 'PRIMARY')
          OR (x_ledger_category_code = 'SECONDARY')) THEN
         IF (x_current_name <> x_name) THEN
            UPDATE gl_ledger_config_details
               SET object_name = x_name
             WHERE configuration_id = x_configuration_id
               AND object_id = x_ledger_id
               AND object_type_code = x_ledger_category_code;
         END IF;

         SELECT bal_seg_value_option_code, sla_accounting_method_code,
                sla_accounting_method_type, allow_intercompany_post_flag
           INTO x_current_bsv_option_code, x_current_sla_actg_method_code,
                x_current_sla_actg_method_type, x_current_allow_intercom_flag
           FROM gl_ledgers
          WHERE ledger_id = x_ledger_id;

/*         IF (x_current_bsv_option_code <> x_bal_seg_value_option_code) THEN
            INSERT INTO gl_ledger_config_details
                        (configuration_id, object_type_code,
                         object_id, object_name, setup_step_code,
                         next_action_code, status_code, created_by,
                         last_update_login, last_update_date,
                         last_updated_by, creation_date)
                 VALUES (x_configuration_id, x_ledger_category_code,
                         x_ledger_id, x_name, 'BSV_ASSIGNMENTS',
                         'ASSIGN_BSV', 'NOT_STARTED', x_last_update_login,
                         x_last_update_login, x_last_update_date,
                         x_last_updated_by, x_last_update_date);
            UPDATE gl_ledgers
               SET bal_seg_value_option_code = x_bal_seg_value_option_code
             WHERE ledger_id IN(
                      SELECT DISTINCT target_ledger_id
                                 FROM gl_ledger_relationships
                                WHERE source_ledger_id = x_ledger_id
                                  AND target_ledger_category_code = 'ALC');
         END IF;*/

         IF (   (    (x_current_sla_actg_method_code IS NULL)
                 AND (x_sla_accounting_method_code IS NOT NULL))
             OR (    (x_current_sla_actg_method_type IS NULL)
                 AND (x_sla_accounting_method_type IS NOT NULL))) THEN
            INSERT INTO gl_ledger_config_details
                        (configuration_id, object_type_code,
                         object_id, object_name, setup_step_code,
                         next_action_code, status_code,
                         created_by, last_update_login,
                         last_update_date, last_updated_by,
                         creation_date)
                 VALUES (x_configuration_id, x_ledger_category_code,
                         x_ledger_id, x_name, 'SLAM_SETUP',
                         'REVIEW_DEFAULTS', 'CONFIRMED',
                         x_last_update_login, x_last_update_login,
                         x_last_update_date, x_last_updated_by,
                         x_last_update_date);

            p_sla_accounting_method_code := x_sla_accounting_method_code;
            p_sla_accounting_method_type := x_sla_accounting_method_type;
            p_sla_description_language := x_sla_description_language;
            p_sla_entered_cur_bal_sus_ccid := x_sla_entered_cur_bal_sus_ccid;
            p_sla_bal_by_ledger_curr_flag := x_sla_bal_by_ledger_curr_flag;
            p_sla_ledger_cur_bal_sus_ccid := x_sla_ledger_cur_bal_sus_ccid;
         --bug 3248289, calling xla api
         /* move to after update ledger
         IF (x_ledger_category_code = 'PRIMARY') THEN
            xla_acct_setup_pub_pkg.setup_ledger_options(x_ledger_id,
                                                        x_ledger_id);
         ELSIF(x_ledger_category_code = 'SECONDARY') THEN
            FOR v_primary_ledgers IN c_primary_ledgers LOOP
               xla_acct_setup_pub_pkg.setup_ledger_options
                                             (v_primary_ledgers.object_id,
                                              x_ledger_id);
            END LOOP;
         END IF;
         */
         ELSIF(   (    (x_current_sla_actg_method_code IS NOT NULL)
                   AND (x_sla_accounting_method_code IS NULL))
               OR (    (x_current_sla_actg_method_type IS NOT NULL)
                   AND (x_sla_accounting_method_type IS NULL))) THEN
            DELETE FROM gl_ledger_config_details
                  WHERE configuration_id = x_configuration_id
                    AND object_type_code = x_ledger_category_code
                    AND object_id = x_ledger_id
                    AND object_name = x_name
                    AND setup_step_code = 'SLAM_SETUP';

            p_sla_sequencing_flag := 'N';          -- remove this flag to null
         ELSIF(   (x_current_sla_actg_method_code <>
                                                  x_sla_accounting_method_code)
               OR (x_current_sla_actg_method_type <>
                                                  x_sla_accounting_method_type)) THEN
            UPDATE gl_ledger_config_details
               SET next_action_code = 'REVIEW_DEFAULTS',
                   status_code = 'CONFIRMED',
                   last_update_login = x_last_update_login,
                   last_update_date = x_last_update_date,
                   last_updated_by = x_last_updated_by
             WHERE configuration_id = x_configuration_id
               AND object_type_code = x_ledger_category_code
               AND object_id = x_ledger_id
               AND object_name = x_name
               AND setup_step_code = 'SLAM_SETUP';

            p_sla_accounting_method_code := x_sla_accounting_method_code;
            p_sla_accounting_method_type := x_sla_accounting_method_type;
            p_sla_description_language := x_sla_description_language;
            p_sla_entered_cur_bal_sus_ccid := x_sla_entered_cur_bal_sus_ccid;
            p_sla_bal_by_ledger_curr_flag := x_sla_bal_by_ledger_curr_flag;
            p_sla_ledger_cur_bal_sus_ccid := x_sla_ledger_cur_bal_sus_ccid;
         ELSE
            p_sla_accounting_method_code := x_sla_accounting_method_code;
            p_sla_accounting_method_type := x_sla_accounting_method_type;
            p_sla_description_language := x_sla_description_language;
            p_sla_entered_cur_bal_sus_ccid := x_sla_entered_cur_bal_sus_ccid;
            p_sla_bal_by_ledger_curr_flag := x_sla_bal_by_ledger_curr_flag;
            p_sla_ledger_cur_bal_sus_ccid := x_sla_ledger_cur_bal_sus_ccid;
         END IF;

-- Move this to a single update SQL for all attributes
-- required to be sychronized for ALC ledgers
/*         UPDATE gl_ledgers
            SET future_enterable_periods_limit =
                                                x_future_enterable_periods_lmt
          WHERE ledger_id IN(
                   SELECT DISTINCT target_ledger_id
                              FROM gl_ledger_relationships
                             WHERE source_ledger_id = x_ledger_id
                               --AND target_ledger_id <> source_ledger_id
                               AND target_ledger_category_code = 'ALC'); */
         IF (    (x_current_allow_intercom_flag = 'N')
             AND (x_allow_intercompany_post_flag = 'Y')) THEN
            --SELECT acctg_environment_code
            --  INTO x_acctg_environment_code
            --  FROM gl_ledger_configurations
            -- WHERE configuration_id = x_configuration_id;
            -- bug fix 3175231 insert the CE row in config details
            --IF (    (x_acctg_environment_code = 'EXCLUSIVE')
            --    OR (     (x_acctg_environment_code = 'SHARED')
            --        AND (x_bal_seg_value_option_code = 'I') ) ) THEN
            INSERT INTO gl_ledger_config_details
                        (configuration_id, object_type_code,
                         object_id, object_name, setup_step_code,
                         next_action_code, status_code, created_by,
                         last_update_login, last_update_date,
                         last_updated_by, creation_date)
                 VALUES (x_configuration_id, x_ledger_category_code,
                         x_ledger_id, x_name, 'INTRA_BAL',
                         'DEFINE_RULES', 'NOT_STARTED', x_last_update_login,
                         x_last_update_login, x_last_update_date,
                         x_last_updated_by, x_last_update_date);
         --END IF;
         ELSIF(    (x_current_allow_intercom_flag = 'Y')
               AND (x_allow_intercompany_post_flag = 'N')) THEN
            DELETE      gl_ledger_config_details
                  WHERE configuration_id = x_configuration_id
                    AND object_id = x_ledger_id
                    AND setup_step_code = 'INTRA_BAL';
         END IF;
      ELSE
         p_sla_accounting_method_code := x_sla_accounting_method_code;
         p_sla_accounting_method_type := x_sla_accounting_method_type;

         IF (x_sla_accounting_method_code IS NULL) THEN
            p_sla_description_language := NULL;
            p_sla_entered_cur_bal_sus_ccid := NULL;
            p_sla_bal_by_ledger_curr_flag := NULL;
            p_sla_ledger_cur_bal_sus_ccid := NULL;
         ELSE
            p_sla_description_language := x_sla_description_language;
            p_sla_entered_cur_bal_sus_ccid := x_sla_entered_cur_bal_sus_ccid;
            p_sla_bal_by_ledger_curr_flag := x_sla_bal_by_ledger_curr_flag;
            p_sla_ledger_cur_bal_sus_ccid := x_sla_ledger_cur_bal_sus_ccid;
         END IF;
      END IF;

      -- The following code is for bug 2826511, there are OA FWK issues with Key Flexfield
      -- After the OA FWK fully support Key Flexfield (i.e., generate CCID correctly)
      -- We will remove the following code
      -- Start the temporary Code
      BEGIN
         SELECT code_combination_id
           INTO x_cum_trans_ccid_temp
           FROM gl_code_combinations
          WHERE code_combination_id = x_cum_trans_ccid;
      EXCEPTION
         WHEN OTHERS THEN
            x_cum_trans_ccid_temp := NULL;
      END;

      BEGIN
         SELECT code_combination_id
           INTO x_res_encumb_ccid_temp
           FROM gl_code_combinations
          WHERE code_combination_id = x_res_encumb_ccid;
      EXCEPTION
         WHEN OTHERS THEN
            x_res_encumb_ccid_temp := NULL;
      END;

      BEGIN
         SELECT code_combination_id
           INTO x_net_income_ccid_temp
           FROM gl_code_combinations
          WHERE code_combination_id = x_net_income_ccid;
      EXCEPTION
         WHEN OTHERS THEN
            x_net_income_ccid_temp := NULL;
      END;

      BEGIN
         SELECT code_combination_id
           INTO x_rounding_ccid_temp
           FROM gl_code_combinations
          WHERE code_combination_id = x_rounding_ccid;
      EXCEPTION
         WHEN OTHERS THEN
            x_rounding_ccid_temp := NULL;
      END;

      --- End the temporary Code

      --- There are some columns are not updateable as business rule.
      --- Enhancement: I try to comments them out in following update to avoid
      --- potential mistake.
      UPDATE gl_ledgers
         SET                                        --ledger_id = x_ledger_id,
            NAME = x_name,
            short_name = x_short_name,
            --chart_of_accounts_id = x_chart_of_accounts_id,
            --currency_code = x_currency_code,
            --period_set_name = x_period_set_name,
            --accounted_period_type = x_period_type,
            first_ledger_period_name = x_first_ledger_period_name,
            ret_earn_code_combination_id = x_ret_earn_code_combination_id,
            suspense_allowed_flag = x_suspense_allowed_flag,
            allow_intercompany_post_flag = x_allow_intercompany_post_flag,
            enable_average_balances_flag = x_enable_avgbal_flag,
            enable_budgetary_control_flag = x_enable_budgetary_control_f,
            require_budget_journals_flag = x_require_budget_journals_flag,
            enable_je_approval_flag = x_enable_je_approval_flag,
            enable_automatic_tax_flag = x_enable_automatic_tax_flag,
            consolidation_ledger_flag = x_consolidation_ledger_flag,
            translate_eod_flag = x_translate_eod_flag,
            translate_qatd_flag = x_translate_qatd_flag,
            translate_yatd_flag = x_translate_yatd_flag,
            automatically_created_flag = x_automatically_created_flag,
            track_rounding_imbalance_flag = x_track_rounding_imbalance_f,
         --   mrc_ledger_type_code = x_mrc_ledger_type_code,
            le_ledger_type_code = x_le_ledger_type_code,
            bal_seg_value_option_code = x_bal_seg_value_option_code,
            --bal_seg_column_name = x_bal_seg_column_name,
            --bal_seg_value_set_id = x_bal_seg_value_set_id,
            mgt_seg_value_option_code = x_mgt_seg_value_option_code,
            --mgt_seg_column_name = x_mgt_seg_column_name,
            --mgt_seg_value_set_id = x_mgt_seg_value_set_id,
            last_update_date = x_last_update_date,
            last_updated_by = x_last_updated_by,
            last_update_login = x_last_update_login,
            description = x_description,
            future_enterable_periods_limit = x_future_enterable_periods_lmt,
            latest_opened_period_name = x_latest_opened_period_name,
            --latest_encumbrance_year = x_latest_encumbrance_year,
            cum_trans_code_combination_id = x_cum_trans_ccid_temp,
            res_encumb_code_combination_id = x_res_encumb_ccid_temp,
            net_income_code_combination_id = x_net_income_ccid_temp,
            rounding_code_combination_id = x_rounding_ccid_temp,
            transaction_calendar_id = x_transaction_calendar_id,
            daily_translation_rate_type = x_daily_translation_rate_type,
            period_average_rate_type = x_period_average_rate_type,
            period_end_rate_type = x_period_end_rate_type,
            CONTEXT = x_context,
            attribute1 = x_attribute1,
            attribute2 = x_attribute2,
            attribute3 = x_attribute3,
            attribute4 = x_attribute4,
            attribute5 = x_attribute5,
            attribute6 = x_attribute6,
            attribute7 = x_attribute7,
            attribute8 = x_attribute8,
            attribute9 = x_attribute9,
            attribute10 = x_attribute10,
            attribute11 = x_attribute11,
            attribute12 = x_attribute12,
            attribute13 = x_attribute13,
            attribute14 = x_attribute14,
            attribute15 = x_attribute15,
            --child_ledger_access_code = x_child_ledger_access_code,
            ledger_category_code = x_ledger_category_code,
            configuration_id = x_configuration_id,
            --association_level_code = x_association_level_code,
            sla_accounting_method_code = p_sla_accounting_method_code,
            sla_accounting_method_type = p_sla_accounting_method_type,
            sla_description_language = p_sla_description_language,
            sla_entered_cur_bal_sus_ccid = p_sla_entered_cur_bal_sus_ccid,
            sla_bal_by_ledger_curr_flag = p_sla_bal_by_ledger_curr_flag,
            sla_ledger_cur_bal_sus_ccid = p_sla_ledger_cur_bal_sus_ccid,
            sla_sequencing_flag =
                 DECODE(p_sla_sequencing_flag,
                        'N', NULL,
                        sla_sequencing_flag),
            alc_ledger_type_code = x_alc_ledger_type_code,
            criteria_set_id = x_criteria_set_id,
            enable_secondary_track_flag = x_enable_secondary_track_flag,
            enable_reval_ss_track_flag = x_enable_reval_ss_track_flag,
            enable_reconciliation_flag = x_enable_reconciliation_flag,
            sla_ledger_cash_basis_flag = x_sla_ledger_cash_basis_flag,
            create_je_flag = x_create_je_flag,
            commitment_budget_flag = x_commitment_budget_flag,
            net_closing_bal_flag   =x_net_closing_bal_flag,
	    automate_sec_jrnl_rev_flag = x_auto_jrnl_rev_flag
       WHERE ledger_id = x_ledger_id;

      -- Bug fix 3265048: Move this check before updating ALC ledgers
      IF (SQL%NOTFOUND) THEN
         --RAISE NO_DATA_FOUND;
         fnd_msg_pub.ADD;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
      END IF;

      IF (   (    (x_current_sla_actg_method_code IS NULL)
              AND (x_sla_accounting_method_code IS NOT NULL))
          OR (    (x_current_sla_actg_method_type IS NULL)
              AND (x_sla_accounting_method_type IS NOT NULL))) THEN
         --bug 3248289, calling xla api
         IF (x_ledger_category_code = 'PRIMARY') THEN
            xla_acct_setup_pub_pkg.setup_ledger_options(x_ledger_id,
                                                        x_ledger_id);
         ELSIF(x_ledger_category_code = 'SECONDARY') THEN
            FOR v_primary_ledgers IN c_primary_ledgers LOOP
               xla_acct_setup_pub_pkg.setup_ledger_options
                                                (v_primary_ledgers.object_id,
                                                 x_ledger_id);
            END LOOP;
         END IF;
      END IF;

      BEGIN
         SELECT completion_status_code
           INTO x_completion_status
           FROM gl_ledger_configurations
          WHERE configuration_id = x_configuration_id;
      EXCEPTION
      WHEN OTHERS THEN
          x_completion_status := NULL;
      END;

      -- Propagate the setup changes to its ALC ledgers if it is a ALC source
      IF (x_alc_ledger_type_code = 'SOURCE') THEN
         UPDATE gl_ledgers alclg
            SET (future_enterable_periods_limit, suspense_allowed_flag,
                 allow_intercompany_post_flag, bal_seg_value_option_code,
                 mgt_seg_value_option_code, sla_accounting_method_code,
                 sla_accounting_method_type, sla_description_language,
                 sla_bal_by_ledger_curr_flag, sla_sequencing_flag,
                 sla_entered_cur_bal_sus_ccid, sla_ledger_cur_bal_sus_ccid,
                 last_update_date, last_updated_by, last_update_login,
                 first_ledger_period_name, ret_earn_code_combination_id,
                 track_rounding_imbalance_flag, enable_average_balances_flag,
                 cum_trans_code_combination_id, res_encumb_code_combination_id,
                 net_income_code_combination_id, rounding_code_combination_id,
                 enable_automatic_tax_flag, consolidation_ledger_flag,
                 translate_eod_flag, translate_qatd_flag, translate_yatd_flag,
                 transaction_calendar_id, daily_translation_rate_type,
                 criteria_set_id, period_average_rate_type,
                 period_end_rate_type, enable_secondary_track_flag,
                 enable_reval_ss_track_flag, enable_reconciliation_flag,
                 sla_ledger_cash_basis_flag, context, attribute1,
                 attribute2, attribute3, attribute4, attribute5,
                 attribute6, attribute7, attribute8, attribute9,
                 attribute10, attribute11, attribute12, attribute13,
                 attribute14, attribute15) =
                   (SELECT srclg.future_enterable_periods_limit,
                           decode(l_suspense_changed, 'Y',
                                  srclg.suspense_allowed_flag,
                                  alclg.suspense_allowed_flag),
                           DECODE(l_intercom_changed, 'Y',
                                  srclg.allow_intercompany_post_flag,
                                  alclg.allow_intercompany_post_flag),
                           srclg.bal_seg_value_option_code,
                           srclg.mgt_seg_value_option_code,
                           srclg.sla_accounting_method_code,
                           srclg.sla_accounting_method_type,
                           srclg.sla_description_language,
                           srclg.sla_bal_by_ledger_curr_flag,
                           srclg.sla_sequencing_flag,

                           -- SLA sus CCIDs of ALC must be same as its source's
                           srclg.sla_entered_cur_bal_sus_ccid,
                           srclg.sla_ledger_cur_bal_sus_ccid,
                           srclg.last_update_date, srclg.last_updated_by,
                           srclg.last_update_login,
                           decode(srclg.complete_flag, 'Y',
                              alclg.first_ledger_period_name,
                              srclg.first_ledger_period_name),
                           decode(l_ret_changed, 'Y',
                                  srclg.ret_earn_code_combination_id,
                                  alclg.ret_earn_code_combination_id),
                           decode(srclg.track_rounding_imbalance_flag,'Y',
                                  'Y', alclg.track_rounding_imbalance_flag),
                           decode(srclg.complete_flag, 'Y',
                                  alclg.enable_average_balances_flag,
                                  srclg.enable_average_balances_flag),
                           decode(l_cta_changed, 'Y',
                                  srclg.cum_trans_code_combination_id,
                                  alclg.cum_trans_code_combination_id),
                           decode(l_reserv_encum_changed, 'Y',
                                  srclg.res_encumb_code_combination_id,
                                  alclg.res_encumb_code_combination_id),
                           decode(srclg.complete_flag, 'Y',
                                  alclg.net_income_code_combination_id,
                                  srclg.net_income_code_combination_id),
                           decode(alclg.rounding_code_combination_id, null,
                                  srclg.rounding_code_combination_id, -1,
                                  srclg.rounding_code_combination_id,
                                  alclg.rounding_code_combination_id),
                           decode(l_autotax_changed, 'Y',
                                  srclg.enable_automatic_tax_flag,
                                  alclg.enable_automatic_tax_flag),
                           decode(srclg.complete_flag, 'Y',
                                  alclg.consolidation_ledger_flag,
                                  srclg.consolidation_ledger_flag),
                           decode(l_trans_eod_changed, 'Y',
                                   srclg.translate_eod_flag,
                                   alclg.translate_eod_flag),
                           decode(l_trans_qatd_changed, 'Y',
                                   srclg.translate_qatd_flag,
                                   alclg.translate_qatd_flag),
                           decode(l_trans_yatd_changed, 'Y',
                                   srclg.translate_yatd_flag,
                                   alclg.translate_yatd_flag),
                           decode(srclg.complete_flag, 'Y',
                                   alclg.transaction_calendar_id,
                                   srclg.transaction_calendar_id),
                           decode(srclg.complete_flag, 'Y',
                                   alclg.daily_translation_rate_type,
                                   srclg.daily_translation_rate_type),
                           srclg.criteria_set_id,
                           decode(l_period_avg_rt_changed, 'Y',
                                   srclg.period_average_rate_type,
                                   alclg.period_average_rate_type),
                           decode(l_period_end_rt_changed, 'Y',
                                   srclg.period_end_rate_type,
                                   alclg.period_end_rate_type),
                           decode(srclg.complete_flag, 'Y',
                                alclg.enable_secondary_track_flag,
                                srclg.enable_secondary_track_flag),
                           decode(srclg.complete_flag, 'Y',
                                alclg.enable_reval_ss_track_flag,
                                srclg.enable_reval_ss_track_flag),
                           srclg.enable_reconciliation_flag,
                           srclg.sla_ledger_cash_basis_flag,
                           srclg.context,
                           srclg.attribute1,
                           srclg.attribute2,
                           srclg.attribute3,
                           srclg.attribute4,
                           srclg.attribute5,
                           srclg.attribute6,
                           srclg.attribute7,
                           srclg.attribute8,
                           srclg.attribute9,
                           srclg.attribute10,
                           srclg.attribute11,
                           srclg.attribute12,
                           srclg.attribute13,
                           srclg.attribute14,
                           srclg.attribute15
                      FROM gl_ledgers srclg
                     WHERE ledger_id = x_ledger_id)
          WHERE ledger_id IN(
                   SELECT target_ledger_id
                     FROM gl_ledger_relationships
                    WHERE source_ledger_id = x_ledger_id
                      AND target_ledger_category_code = 'ALC'
                      AND relationship_type_code IN('SUBLEDGER', 'JOURNAL'));
      END IF;                         -- IF (x_alc_ledger_type_coe = 'SOURCE')

      -- Update the implicit access set name for the ledger
      IF (x_implicit_access_set_id IS NOT NULL) THEN
         gl_access_sets_pkg.update_implicit_access_set
                                (x_access_set_id => x_implicit_access_set_id,
                                 x_name => x_name,
                                 x_last_update_date => x_last_update_date,
                                 x_last_updated_by => x_last_updated_by,
                                 x_last_update_login => x_last_update_login);
      END IF;

      IF(x_ledger_category_code = 'PRIMARY') THEN
        update gl_ledger_configurations
        set name = x_name
        where configuration_id =
           (select configuration_id
            from gl_ledger_config_details
            where object_id = x_ledger_id
            and object_type_code = 'PRIMARY'
            and setup_step_code = 'NONE');
      END IF;

      -- Check whether journal_approval_flag is to be set to Y for
      -- the Manual source.
      IF (x_set_manual_flag = 'Y') THEN
         gl_ledgers_pkg.enable_manual_je_approval;
      END IF;

      -- Update gl_system_usage and insert the net income account
      IF (recinfo.enable_average_balances_flag = 'N' AND x_enable_avgbal_flag = 'Y') THEN
      -- get the balance segment infor and mgt segment infor
          gl_ledgers_pkg.get_bal_mgt_seg_info(x_bal_seg_column_name,
                                          x_bal_seg_value_set_id,
                                          x_mgt_seg_column_name,
                                          x_mgt_seg_value_set_id,
                                          x_chart_of_accounts_id);

          IF x_net_income_ccid IS NOT NULL THEN
          BEGIN
            v_CursorSQL :=
               'SELECT ' || x_bal_seg_column_name
               || ' FROM gl_code_combinations WHERE chart_of_accounts_id = :1 '
               || ' AND code_combination_id = :2 ';
            EXECUTE IMMEDIATE v_CursorSQL INTO v_balancing_segment
                    USING x_chart_of_accounts_id, x_net_income_ccid;
          EXCEPTION
            WHEN OTHERS THEN
               v_balancing_segment := x_balancing_segment;
          END;
          ELSE
            v_balancing_segment := x_balancing_segment;
          END IF;

         gl_ledgers_pkg.update_gl_system_usages(x_consolidation_ledger_flag);
         gl_ledgers_pkg.insert_gl_net_income_accounts(x_ledger_id,
                                                      v_balancing_segment,
                                                      --x_balancing_segment,
                                                      x_net_income_ccid,
                                                      x_last_update_date,
                                                      x_last_updated_by,
                                                      x_last_update_date,
                                                      x_last_updated_by,
                                                      x_last_update_login,
                                                      '', '', '', '');
      END IF;


      -- Added by LPOON on 11/20/03: only insert suspense CCID when the suspense
      -- flag is turned on in order to avoid inserting invalid suspense CCID
      BEGIN
         SELECT code_combination_id
           INTO x_suspense_ccid_temp
           FROM gl_code_combinations
          WHERE code_combination_id = x_suspense_ccid;
      EXCEPTION
         WHEN OTHERS THEN
            x_suspense_ccid_temp := NULL;
      END;

--      IF (    (x_suspense_allowed_flag = 'Y')
--          AND (x_suspense_ccid_temp IS NOT NULL)) THEN
         -- Update suspense account for this ledger
         -- bug fix 2826511
         gl_ledgers_pkg.led_update_other_tables(x_ledger_id,
                                                x_last_update_date,
                                                x_last_updated_by,
                                                x_suspense_ccid_temp);

         -- Check each ALC ledger of this ledger and if it doesn't have existing
         -- suspense account, default it same as source's
         FOR v_alc IN c_alc_ledgers LOOP
--            IF (    NOT gl_suspense_accounts_pkg.is_ledger_suspense_exist(v_alc.ledger_id)
--                AND x_suspense_ccid_temp IS NOT NULL) THEN
                 gl_ledgers_pkg.led_update_other_tables(v_alc.target_ledger_id,
                                                x_last_update_date,
                                                x_last_updated_by,
                                                x_suspense_ccid_temp);
--               gl_suspense_accounts_pkg.insert_ledger_suspense
--                                                       (v_alc.target_ledger_id,
--                                                        x_suspense_ccid_temp,
--                                                        x_last_update_date,
--                                                        x_last_updated_by);
--            END IF;  -- IF (NOT gl_suspense_accounts_pkg.is_ledger_suspense...
         END LOOP;                               -- FOR v_alc IN c_alc_ledgers
  --    END IF;

      x_msg_count := fnd_msg_pub.count_msg;

      IF x_msg_count > 0 THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         RAISE fnd_api.g_exc_error;
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error THEN
         IF p_commit = fnd_api.g_true THEN
            ROLLBACK TO complete_workorder;
         END IF;

         fnd_msg_pub.add_exc_msg(p_pkg_name => g_pkg_name,
                                 p_procedure_name => l_api_name);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
      WHEN fnd_api.g_exc_error THEN
         IF p_commit = fnd_api.g_true THEN
            ROLLBACK TO complete_workorder;
         END IF;

         fnd_msg_pub.add_exc_msg(p_pkg_name => g_pkg_name,
                                 p_procedure_name => l_api_name);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
      WHEN OTHERS THEN
         IF p_commit = fnd_api.g_true THEN
            ROLLBACK TO complete_workorder;
         END IF;

         fnd_msg_pub.add_exc_msg(p_pkg_name => g_pkg_name,
                                 p_procedure_name => l_api_name);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
   END update_row;

-- **********************************************************************
   PROCEDURE check_unique_name(
      x_rowid                             VARCHAR2,
      x_name                              VARCHAR2) IS
      CURSOR c_dup IS
         SELECT 'Duplicate'
           FROM gl_ledgers l
          WHERE l.NAME = x_name AND(x_rowid IS NULL OR l.ROWID <> x_rowid);

      CURSOR c_dup2 IS
         SELECT 'Duplicate'
           FROM gl_access_sets a
          WHERE a.NAME = x_name AND a.automatically_created_flag <> 'Y';

      dummy   VARCHAR2(100);
   BEGIN
      OPEN c_dup;

      FETCH c_dup
       INTO dummy;

      IF c_dup%FOUND THEN
         CLOSE c_dup;

         fnd_message.set_name('SQLGL', 'GL_LEDGER_DUPLICATE_LEDGER');
         app_exception.raise_exception;
      END IF;

      CLOSE c_dup;

      OPEN c_dup2;

      FETCH c_dup2
       INTO dummy;

      IF c_dup2%FOUND THEN
         CLOSE c_dup2;

         fnd_message.set_name('SQLGL', 'GL_LEDGER_DUPLICATE_LEDGER');
         app_exception.raise_exception;
      END IF;

      CLOSE c_dup2;
   EXCEPTION
      WHEN app_exceptions.application_exception THEN
         RAISE;
      WHEN OTHERS THEN
         fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
         fnd_message.set_token('PROCEDURE',
                               'GL_LEDGERS_PKG.check_unique_name');
         RAISE;
   END check_unique_name;

-- **********************************************************************
   PROCEDURE check_unique_short_name(
      x_rowid                             VARCHAR2,
      x_short_name                        VARCHAR2) IS
      CURSOR c_dup IS
         SELECT 'Duplicate'
           FROM gl_ledgers l
          WHERE l.short_name = x_short_name
            AND (x_rowid IS NULL OR l.ROWID <> x_rowid);

      dummy   VARCHAR2(100);
   BEGIN
      OPEN c_dup;

      FETCH c_dup
       INTO dummy;

      IF c_dup%FOUND THEN
         CLOSE c_dup;

         fnd_message.set_name('SQLGL', 'GL_LEDGER_DUPLICATE_SHORT_NAME');
         app_exception.raise_exception;
      END IF;

      CLOSE c_dup;
   EXCEPTION
      WHEN app_exceptions.application_exception THEN
         RAISE;
      WHEN OTHERS THEN
         fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
         fnd_message.set_token('PROCEDURE',
                               'GL_LEDGERS_PKG.check_unique_short_name');
         RAISE;
   END check_unique_short_name;

-- **********************************************************************
   FUNCTION get_unique_id
      RETURN NUMBER IS
      CURSOR c_getid IS
         SELECT gl_ledgers_s.NEXTVAL
           FROM DUAL;

      ID   NUMBER;
   BEGIN
      OPEN c_getid;

      FETCH c_getid
       INTO ID;

      IF c_getid%FOUND THEN
         CLOSE c_getid;

         RETURN(ID);
      ELSE
         CLOSE c_getid;

         fnd_message.set_name('SQLGL', 'GL_ERROR_GETTING_UNIQUE_ID');
         fnd_message.set_token('SEQUENCE', 'GL_LEDGERS_S');
         app_exception.raise_exception;
      END IF;
   EXCEPTION
      WHEN app_exceptions.application_exception THEN
         RAISE;
      WHEN OTHERS THEN
         fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
         fnd_message.set_token('PROCEDURE', 'GL_LEDGERS_PKG.get_unique_id');
         RAISE;
   END get_unique_id;

-- **********************************************************************
   FUNCTION is_coa_frozen(
      x_chart_of_accounts_id              NUMBER)
      RETURN BOOLEAN IS
      CURSOR c_is_coa_frozen IS
         SELECT 'X'
           FROM fnd_id_flex_structures s
          WHERE s.application_id = 101
            AND s.id_flex_code = 'GL#'
            AND s.id_flex_num = x_chart_of_accounts_id
            AND s.freeze_flex_definition_flag = 'Y';

      dummy   VARCHAR2(1);
   BEGIN
      OPEN c_is_coa_frozen;

      FETCH c_is_coa_frozen
       INTO dummy;

      IF c_is_coa_frozen%FOUND THEN
         CLOSE c_is_coa_frozen;

         RETURN TRUE;
      END IF;

      CLOSE c_is_coa_frozen;

      RETURN FALSE;
   EXCEPTION
      WHEN app_exceptions.application_exception THEN
         RAISE;
      WHEN OTHERS THEN
         fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
         fnd_message.set_token('PROCEDURE', 'GL_LEDGERS_PKG.is_coa_frozen');
         RAISE;
   END is_coa_frozen;

-- **********************************************************************
   PROCEDURE get_bal_mgt_seg_info(
      x_bal_seg_column_name      OUT NOCOPY VARCHAR2,
      x_bal_seg_value_set_id     OUT NOCOPY NUMBER,
      x_mgt_seg_column_name      OUT NOCOPY VARCHAR2,
      x_mgt_seg_value_set_id     OUT NOCOPY NUMBER,
      x_chart_of_accounts_id              NUMBER) IS
      CURSOR c_get_bal_seg_column_name IS
         SELECT s.application_column_name, s.flex_value_set_id
           FROM fnd_id_flex_segments s, fnd_segment_attribute_values v
          WHERE s.application_id = v.application_id
            AND s.id_flex_code = v.id_flex_code
            AND s.id_flex_num = v.id_flex_num
            AND s.application_column_name = v.application_column_name
            AND v.application_id = 101
            AND v.id_flex_code = 'GL#'
            AND v.id_flex_num = x_chart_of_accounts_id
            AND v.segment_attribute_type = 'GL_BALANCING'
            AND v.attribute_value = 'Y';

      CURSOR c_get_mgt_seg_column_name IS
         SELECT s.application_column_name, s.flex_value_set_id
           FROM fnd_id_flex_segments s, fnd_segment_attribute_values v
          WHERE s.application_id = v.application_id
            AND s.id_flex_code = v.id_flex_code
            AND s.id_flex_num = v.id_flex_num
            AND s.application_column_name = v.application_column_name
            AND v.application_id = 101
            AND v.id_flex_code = 'GL#'
            AND v.id_flex_num = x_chart_of_accounts_id
            AND v.segment_attribute_type = 'GL_MANAGEMENT'
            AND v.attribute_value = 'Y';
   BEGIN
      OPEN c_get_bal_seg_column_name;

      FETCH c_get_bal_seg_column_name
       INTO x_bal_seg_column_name, x_bal_seg_value_set_id;

      IF c_get_bal_seg_column_name%FOUND THEN
         CLOSE c_get_bal_seg_column_name;
      ELSE
         CLOSE c_get_bal_seg_column_name;

         x_bal_seg_column_name := NULL;
         x_bal_seg_value_set_id := NULL;
         fnd_message.set_name('SQLGL', 'GL_LEDGER_ERR_GETTING_BAL_SEG');
         app_exception.raise_exception;
      END IF;

      OPEN c_get_mgt_seg_column_name;

      FETCH c_get_mgt_seg_column_name
       INTO x_mgt_seg_column_name, x_mgt_seg_value_set_id;

      IF c_get_mgt_seg_column_name%FOUND THEN
         CLOSE c_get_mgt_seg_column_name;
      ELSE
         CLOSE c_get_mgt_seg_column_name;

         x_mgt_seg_column_name := NULL;
         x_mgt_seg_value_set_id := NULL;
         fnd_message.set_name('SQLGL', 'GL_LEDGER_ERR_GETTING_MGT_SEG');
      -- Now the management segment value is an optional segment
      -- commneted by Srini Pala.
      --app_exception.raise_exception;
      END IF;
   EXCEPTION
      WHEN app_exceptions.application_exception THEN
         RAISE;
      WHEN OTHERS THEN
         fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
         fnd_message.set_token('PROCEDURE',
                               'GL_LEDGERS_PKG.get_bal_mgt_seg_info');
         RAISE;
   END get_bal_mgt_seg_info;

-- **********************************************************************
-- This Insert_Row is used by the Ledger Form; Will be removed after the
-- form is removed.
   PROCEDURE insert_row(
      x_rowid                    IN OUT NOCOPY VARCHAR2,
      x_ledger_id                         NUMBER,
      x_name                              VARCHAR2,
      x_short_name                        VARCHAR2,
      x_chart_of_accounts_id              NUMBER,
      x_chart_of_accounts_name            VARCHAR2,
      x_currency_code                     VARCHAR2,
      x_period_set_name                   VARCHAR2,
      x_user_period_type                  VARCHAR2,
      x_accounted_period_type             VARCHAR2,
      x_first_ledger_period_name          VARCHAR2,
      x_ret_earn_code_combination_id      NUMBER,
      x_suspense_allowed_flag             VARCHAR2,
      x_suspense_ccid                     NUMBER,
      x_allow_intercompany_post_flag      VARCHAR2,
      x_enable_avgbal_flag                VARCHAR2,
      x_enable_budgetary_control_f        VARCHAR2,
      x_require_budget_journals_flag      VARCHAR2,
      x_enable_je_approval_flag           VARCHAR2,
      x_enable_automatic_tax_flag         VARCHAR2,
      x_consolidation_ledger_flag         VARCHAR2,
      x_translate_eod_flag                VARCHAR2,
      x_translate_qatd_flag               VARCHAR2,
      x_translate_yatd_flag               VARCHAR2,
      x_automatically_created_flag        VARCHAR2,
      x_track_rounding_imbalance_f        VARCHAR2,
      x_alc_ledger_type_code              VARCHAR2,
      x_le_ledger_type_code               VARCHAR2,
      x_bal_seg_value_option_code         VARCHAR2,
      x_bal_seg_column_name               VARCHAR2,
      x_bal_seg_value_set_id              NUMBER,
      x_mgt_seg_value_option_code         VARCHAR2,
      x_mgt_seg_column_name               VARCHAR2,
      x_mgt_seg_value_set_id              NUMBER,
      x_last_update_date                  DATE,
      x_last_updated_by                   NUMBER,
      x_creation_date                     DATE,
      x_created_by                        NUMBER,
      x_last_update_login                 NUMBER,
      x_description                       VARCHAR2,
      x_future_enterable_periods_lmt      NUMBER,
      x_latest_opened_period_name         VARCHAR2,
      x_latest_encumbrance_year           NUMBER,
      x_cum_trans_ccid                    NUMBER,
      x_res_encumb_ccid                   NUMBER,
      x_net_income_ccid                   NUMBER,
      x_balancing_segment                 VARCHAR2,
      x_rounding_ccid                     NUMBER,
      x_transaction_calendar_id           NUMBER,
      x_transaction_calendar_name         VARCHAR2,
      x_daily_translation_rate_type       VARCHAR2,
      x_daily_user_translation_type       VARCHAR2,
      x_period_average_rate_type          VARCHAR2,
      x_period_avg_user_rate_type         VARCHAR2,
      x_period_end_rate_type              VARCHAR2,
      x_period_end_user_rate_type         VARCHAR2,
      x_context                           VARCHAR2,
      x_attribute1                        VARCHAR2,
      x_attribute2                        VARCHAR2,
      x_attribute3                        VARCHAR2,
      x_attribute4                        VARCHAR2,
      x_attribute5                        VARCHAR2,
      x_attribute6                        VARCHAR2,
      x_attribute7                        VARCHAR2,
      x_attribute8                        VARCHAR2,
      x_attribute9                        VARCHAR2,
      x_attribute10                       VARCHAR2,
      x_attribute11                       VARCHAR2,
      x_attribute12                       VARCHAR2,
      x_attribute13                       VARCHAR2,
      x_attribute14                       VARCHAR2,
      x_attribute15                       VARCHAR2,
      x_set_manual_flag                   VARCHAR2) IS
      CURSOR c IS
         SELECT ROWID
           FROM gl_ledgers
          WHERE NAME = x_name;

      x_access_set_id              NUMBER(15);
      v_security_segment_code      VARCHAR2(1);
      v_secured_seg_value_set_id   NUMBER(15);
   BEGIN
      -- Create an implicit access set header for the corresponding new created
      -- ledger and retrieve its ID.
      -- The security segment code must be 'M' for Management Ledgers and
      -- 'F' for Legal and Upgrade Ledgers.
      -- The secured segment value set id should be X_Mgt_Seg_Value_Set_Id for
      -- Management Ledgers and null for Legal and Upgrade Ledgers.

      /* Now the Implicit access sets are ledger Implicit sets only modified
         Srini Pala*/
      --IF (X_Le_Ledger_Type_Code = 'M') THEN
      v_security_segment_code := 'F';
      v_secured_seg_value_set_id := NULL;          -- X_Mgt_Seg_Value_Set_Id;
      x_access_set_id :=
         gl_access_sets_pkg.create_implicit_access_set
                   (x_name => x_name,
                    x_security_segment_code => v_security_segment_code,
                    x_chart_of_accounts_id => x_chart_of_accounts_id,
                    x_period_set_name => x_period_set_name,
                    x_accounted_period_type => x_accounted_period_type,
                    x_secured_seg_value_set_id => v_secured_seg_value_set_id,
                    x_default_ledger_id => x_ledger_id,
                    x_last_updated_by => x_last_updated_by,
                    x_last_update_login => x_last_update_login,
                    x_creation_date => x_creation_date,
                    x_description => x_description);

      INSERT INTO gl_ledgers
                  (ledger_id, NAME, short_name,
                   chart_of_accounts_id, currency_code,
                   period_set_name, accounted_period_type,
                   first_ledger_period_name,
                   ret_earn_code_combination_id, suspense_allowed_flag,
                   allow_intercompany_post_flag,
                   enable_average_balances_flag,
                   enable_budgetary_control_flag,
                   require_budget_journals_flag,
                   enable_je_approval_flag, enable_automatic_tax_flag,
                   consolidation_ledger_flag, translate_eod_flag,
                   translate_qatd_flag, translate_yatd_flag,
                   automatically_created_flag,
                   track_rounding_imbalance_flag, alc_ledger_type_code,
                   ledger_category_code, object_type_code,
                   le_ledger_type_code, bal_seg_value_option_code,
                   bal_seg_column_name, bal_seg_value_set_id,
                   mgt_seg_value_option_code, mgt_seg_column_name,
                   mgt_seg_value_set_id, implicit_access_set_id,
                   last_update_date, last_updated_by, creation_date,
                   created_by, last_update_login, description,
                   future_enterable_periods_limit, ledger_attributes,
                   latest_opened_period_name, latest_encumbrance_year,
                   cum_trans_code_combination_id,
                   res_encumb_code_combination_id,
                   net_income_code_combination_id,
                   rounding_code_combination_id, transaction_calendar_id,
                   daily_translation_rate_type,
                   period_average_rate_type, period_end_rate_type,
                   CONTEXT, attribute1, attribute2, attribute3,
                   attribute4, attribute5, attribute6, attribute7,
                   attribute8, attribute9, attribute10, attribute11,
                   attribute12, attribute13, attribute14, attribute15
                   ,net_closing_bal_flag,automate_sec_jrnl_rev_flag)--Added the net closing bal flag for bug 8612291
           VALUES (x_ledger_id, x_name, x_short_name,
                   x_chart_of_accounts_id, x_currency_code,
                   x_period_set_name, x_accounted_period_type,
                   x_first_ledger_period_name,
                   x_ret_earn_code_combination_id, x_suspense_allowed_flag,
                   x_allow_intercompany_post_flag,
                   x_enable_avgbal_flag,
                   x_enable_budgetary_control_f,
                   x_require_budget_journals_flag,
                   x_enable_je_approval_flag, x_enable_automatic_tax_flag,
                   x_consolidation_ledger_flag, x_translate_eod_flag,
                   x_translate_qatd_flag, x_translate_yatd_flag,
                   x_automatically_created_flag,
                   x_track_rounding_imbalance_f, x_alc_ledger_type_code,
                   'NONE', 'L',
                   x_le_ledger_type_code, x_bal_seg_value_option_code,
                   x_bal_seg_column_name, x_bal_seg_value_set_id,
                   x_mgt_seg_value_option_code, x_mgt_seg_column_name,
                   x_mgt_seg_value_set_id, x_access_set_id,
                   x_last_update_date, x_last_updated_by, x_creation_date,
                   x_created_by, x_last_update_login, x_description,
                   x_future_enterable_periods_lmt, 'L',
                   x_latest_opened_period_name, x_latest_encumbrance_year,
                   x_cum_trans_ccid,
                   x_res_encumb_ccid,
                   x_net_income_ccid,
                   x_rounding_ccid, x_transaction_calendar_id,
                   x_daily_translation_rate_type,
                   x_period_average_rate_type, x_period_end_rate_type,
                   x_context, x_attribute1, x_attribute2, x_attribute3,
                   x_attribute4, x_attribute5, x_attribute6, x_attribute7,
                   x_attribute8, x_attribute9, x_attribute10, x_attribute11,
                   x_attribute12, x_attribute13, x_attribute14, x_attribute15,
                   'N','N');--Added the default value for net closing bal flag for bug 8612291

      OPEN c;

      FETCH c
       INTO x_rowid;

      IF (c%NOTFOUND) THEN
         CLOSE c;

         RAISE NO_DATA_FOUND;
      END IF;

      CLOSE c;

      -- Insert rows into gl_concurrency_control table for the
      -- corresponding new created ledger.
      -- Should be GL_CONC_CONTROL_PKG.insert_conc_ledger(
      gl_conc_control_pkg.insert_conc_ledger(x_ledger_id, x_last_update_date,
                                             x_last_updated_by,
                                             x_creation_date, x_created_by,
                                             x_last_update_login);
      -- Insert rows into gl_period_statuses table for the
      -- corresponding new created ledger.
      gl_period_statuses_pkg.insert_led_ps(x_ledger_id, x_period_set_name,
                                           x_accounted_period_type,
                                           x_last_update_date,
                                           x_last_updated_by,
                                           x_last_update_login,
                                           x_creation_date, x_created_by);

      -- Insert rows into gl_autoreverse_options table for the
      -- new ledger
      -- gl_autoreverse_options_pkg.insert_ledger_reversal_cat(
      --   x_ledger_id, x_created_by, x_last_updated_by, x_last_update_login);

      -- Insert rows into gl_suspense_accounts table for the
      -- corresponding new created ledger.
      IF (x_suspense_ccid IS NOT NULL) THEN
         gl_suspense_accounts_pkg.insert_ledger_suspense(x_ledger_id,
                                                         x_suspense_ccid,
                                                         x_last_update_date,
                                                         x_last_updated_by);
      END IF;

      -- Check whether journal_approval_flag is to be set to Y for
      -- the Manual source.
      IF (x_set_manual_flag = 'Y') THEN
         gl_ledgers_pkg.enable_manual_je_approval;
      END IF;

      IF (x_enable_avgbal_flag = 'Y') THEN
         gl_ledgers_pkg.update_gl_system_usages(x_consolidation_ledger_flag);
         gl_ledgers_pkg.insert_gl_net_income_accounts(x_ledger_id,
                                                      x_balancing_segment,
                                                      x_net_income_ccid,
                                                      x_creation_date,
                                                      x_created_by,
                                                      x_last_update_date,
                                                      x_last_updated_by,
                                                      x_last_update_login,
                                                      '', '', '', '');
      END IF;
   END insert_row;

-- **********************************************************************
   PROCEDURE lock_row(
      x_rowid                             VARCHAR2,
      x_ledger_id                         NUMBER,
      x_name                              VARCHAR2,
      x_short_name                        VARCHAR2,
      x_chart_of_accounts_id              NUMBER,
      x_chart_of_accounts_name            VARCHAR2,
      x_currency_code                     VARCHAR2,
      x_period_set_name                   VARCHAR2,
      x_user_period_type                  VARCHAR2,
      x_accounted_period_type             VARCHAR2,
      x_first_ledger_period_name          VARCHAR2,
      x_ret_earn_code_combination_id      NUMBER,
      x_suspense_allowed_flag             VARCHAR2,
      x_suspense_ccid                     NUMBER,
      x_allow_intercompany_post_flag      VARCHAR2,
      x_enable_avgbal_flag                VARCHAR2,
      x_enable_budgetary_control_f        VARCHAR2,
      x_require_budget_journals_flag      VARCHAR2,
      x_enable_je_approval_flag           VARCHAR2,
      x_enable_automatic_tax_flag         VARCHAR2,
      x_consolidation_ledger_flag         VARCHAR2,
      x_translate_eod_flag                VARCHAR2,
      x_translate_qatd_flag               VARCHAR2,
      x_translate_yatd_flag               VARCHAR2,
      x_automatically_created_flag        VARCHAR2,
      x_track_rounding_imbalance_f        VARCHAR2,
      x_alc_ledger_type_code              VARCHAR2,
      x_le_ledger_type_code               VARCHAR2,
      x_bal_seg_value_option_code         VARCHAR2,
      x_bal_seg_column_name               VARCHAR2,
      x_bal_seg_value_set_id              NUMBER,
      x_mgt_seg_value_option_code         VARCHAR2,
      x_mgt_seg_column_name               VARCHAR2,
      x_mgt_seg_value_set_id              NUMBER,
      x_description                       VARCHAR2,
      x_future_enterable_periods_lmt      NUMBER,
      x_latest_opened_period_name         VARCHAR2,
      x_latest_encumbrance_year           NUMBER,
      x_cum_trans_ccid                    NUMBER,
      x_res_encumb_ccid                   NUMBER,
      x_net_income_ccid                   NUMBER,
      x_balancing_segment                 VARCHAR2,
      x_rounding_ccid                     NUMBER,
      x_transaction_calendar_id           NUMBER,
      x_transaction_calendar_name         VARCHAR2,
      x_daily_translation_rate_type       VARCHAR2,
      x_daily_user_translation_type       VARCHAR2,
      x_period_average_rate_type          VARCHAR2,
      x_period_avg_user_rate_type         VARCHAR2,
      x_period_end_rate_type              VARCHAR2,
      x_period_end_user_rate_type         VARCHAR2,
      x_context                           VARCHAR2,
      x_attribute1                        VARCHAR2,
      x_attribute2                        VARCHAR2,
      x_attribute3                        VARCHAR2,
      x_attribute4                        VARCHAR2,
      x_attribute5                        VARCHAR2,
      x_attribute6                        VARCHAR2,
      x_attribute7                        VARCHAR2,
      x_attribute8                        VARCHAR2,
      x_attribute9                        VARCHAR2,
      x_attribute10                       VARCHAR2,
      x_attribute11                       VARCHAR2,
      x_attribute12                       VARCHAR2,
      x_attribute13                       VARCHAR2,
      x_attribute14                       VARCHAR2,
      x_attribute15                       VARCHAR2) IS
      CURSOR c IS
         SELECT        *
                  FROM gl_ledgers
                 WHERE ROWID = x_rowid
         FOR UPDATE OF NAME NOWAIT;

      recinfo   c%ROWTYPE;
   BEGIN
      OPEN c;

      FETCH c
       INTO recinfo;

      IF (c%NOTFOUND) THEN
         CLOSE c;

         RAISE NO_DATA_FOUND;
      END IF;

      CLOSE c;

      IF (    (   (recinfo.ledger_id = x_ledger_id)
               OR ((recinfo.ledger_id IS NULL) AND(x_ledger_id IS NULL)))
          AND (   (recinfo.NAME = x_name)
               OR ((recinfo.NAME IS NULL) AND(x_name IS NULL)))
          AND (   (recinfo.short_name = x_short_name)
               OR ((recinfo.short_name IS NULL) AND(x_short_name IS NULL)))
          AND (   (recinfo.chart_of_accounts_id = x_chart_of_accounts_id)
               OR (    (recinfo.chart_of_accounts_id IS NULL)
                   AND (x_chart_of_accounts_id IS NULL)))
          AND (   (recinfo.currency_code = x_currency_code)
               OR (    (recinfo.currency_code IS NULL)
                   AND (x_currency_code IS NULL)))
          AND (   (recinfo.period_set_name = x_period_set_name)
               OR (    (recinfo.period_set_name IS NULL)
                   AND (x_period_set_name IS NULL)))
          AND (   (recinfo.accounted_period_type = x_accounted_period_type)
               OR (    (recinfo.accounted_period_type IS NULL)
                   AND (x_accounted_period_type IS NULL)))
          AND (   (recinfo.first_ledger_period_name =
                                                    x_first_ledger_period_name)
               OR (    (recinfo.first_ledger_period_name IS NULL)
                   AND (x_first_ledger_period_name IS NULL)))
          AND (   (recinfo.ret_earn_code_combination_id =
                                                x_ret_earn_code_combination_id)
               OR (    (recinfo.ret_earn_code_combination_id IS NULL)
                   AND (x_ret_earn_code_combination_id IS NULL)))
          AND (   (recinfo.suspense_allowed_flag = x_suspense_allowed_flag)
               OR (    (recinfo.suspense_allowed_flag IS NULL)
                   AND (x_suspense_allowed_flag IS NULL)))
          AND (   (recinfo.allow_intercompany_post_flag =
                                                x_allow_intercompany_post_flag)
               OR (    (recinfo.allow_intercompany_post_flag IS NULL)
                   AND (x_allow_intercompany_post_flag IS NULL)))
          AND (   (recinfo.enable_average_balances_flag = x_enable_avgbal_flag)
               OR (    (recinfo.enable_average_balances_flag IS NULL)
                   AND (x_enable_avgbal_flag IS NULL)))
          AND (   (recinfo.enable_budgetary_control_flag =
                                                  x_enable_budgetary_control_f)
               OR (    (recinfo.enable_budgetary_control_flag IS NULL)
                   AND (x_enable_budgetary_control_f IS NULL)))
          AND (   (recinfo.require_budget_journals_flag =
                                                x_require_budget_journals_flag)
               OR (    (recinfo.require_budget_journals_flag IS NULL)
                   AND (x_require_budget_journals_flag IS NULL)))
          AND (   (recinfo.enable_je_approval_flag = x_enable_je_approval_flag)
               OR (    (recinfo.enable_je_approval_flag IS NULL)
                   AND (x_enable_je_approval_flag IS NULL)))
          AND (   (recinfo.enable_automatic_tax_flag =
                                                   x_enable_automatic_tax_flag)
               OR (    (recinfo.enable_automatic_tax_flag IS NULL)
                   AND (x_enable_automatic_tax_flag IS NULL)))
          AND (   (recinfo.consolidation_ledger_flag =
                                                   x_consolidation_ledger_flag)
               OR (    (recinfo.consolidation_ledger_flag IS NULL)
                   AND (x_consolidation_ledger_flag IS NULL)))
          AND (   (recinfo.translate_eod_flag = x_translate_eod_flag)
               OR (    (recinfo.translate_eod_flag IS NULL)
                   AND (x_translate_eod_flag IS NULL)))
          AND (   (recinfo.translate_qatd_flag = x_translate_qatd_flag)
               OR (    (recinfo.translate_qatd_flag IS NULL)
                   AND (x_translate_qatd_flag IS NULL)))
          AND (   (recinfo.translate_yatd_flag = x_translate_yatd_flag)
               OR (    (recinfo.translate_yatd_flag IS NULL)
                   AND (x_translate_yatd_flag IS NULL)))
          AND (   (recinfo.automatically_created_flag =
                                                  x_automatically_created_flag)
               OR (    (recinfo.automatically_created_flag IS NULL)
                   AND (x_automatically_created_flag IS NULL)))
          AND (   (recinfo.track_rounding_imbalance_flag =
                                                  x_track_rounding_imbalance_f)
               OR (    (recinfo.track_rounding_imbalance_flag IS NULL)
                   AND (x_track_rounding_imbalance_f IS NULL)))
          AND (   (recinfo.alc_ledger_type_code = x_alc_ledger_type_code)
               OR (    (recinfo.alc_ledger_type_code IS NULL)
                   AND (x_alc_ledger_type_code IS NULL)))
          AND (   (recinfo.le_ledger_type_code = x_le_ledger_type_code)
               OR (    (recinfo.le_ledger_type_code IS NULL)
                   AND (x_le_ledger_type_code IS NULL)))
          AND (   (recinfo.bal_seg_value_option_code =
                                                   x_bal_seg_value_option_code)
               OR (    (recinfo.bal_seg_value_option_code IS NULL)
                   AND (x_bal_seg_value_option_code IS NULL)))
          AND (   (recinfo.bal_seg_column_name = x_bal_seg_column_name)
               OR (    (recinfo.bal_seg_column_name IS NULL)
                   AND (x_bal_seg_column_name IS NULL)))
          AND (   (recinfo.bal_seg_value_set_id = x_bal_seg_value_set_id)
               OR (    (recinfo.bal_seg_value_set_id IS NULL)
                   AND (x_bal_seg_value_set_id IS NULL)))
          AND (   (recinfo.mgt_seg_value_option_code =
                                                   x_mgt_seg_value_option_code)
               OR (    (recinfo.mgt_seg_value_option_code IS NULL)
                   AND (x_mgt_seg_value_option_code IS NULL)))
          AND (   (recinfo.mgt_seg_column_name = x_mgt_seg_column_name)
               OR (    (recinfo.mgt_seg_column_name IS NULL)
                   AND (x_mgt_seg_column_name IS NULL)))
          AND (   (recinfo.mgt_seg_value_set_id = x_mgt_seg_value_set_id)
               OR (    (recinfo.mgt_seg_value_set_id IS NULL)
                   AND (x_mgt_seg_value_set_id IS NULL)))
          AND (   (recinfo.description = x_description)
               OR ((recinfo.description IS NULL) AND(x_description IS NULL)))
          AND (   (recinfo.future_enterable_periods_limit =
                                                x_future_enterable_periods_lmt)
               OR (    (recinfo.future_enterable_periods_limit IS NULL)
                   AND (x_future_enterable_periods_lmt IS NULL)))
          AND (   (recinfo.latest_opened_period_name =
                                                   x_latest_opened_period_name)
               OR (    (recinfo.latest_opened_period_name IS NULL)
                   AND (x_latest_opened_period_name IS NULL)))
          AND (   (recinfo.latest_encumbrance_year = x_latest_encumbrance_year)
               OR (    (recinfo.latest_encumbrance_year IS NULL)
                   AND (x_latest_encumbrance_year IS NULL)))
          AND (   (recinfo.cum_trans_code_combination_id = x_cum_trans_ccid)
               OR (    (recinfo.cum_trans_code_combination_id IS NULL)
                   AND (x_cum_trans_ccid IS NULL)))
          AND (   (recinfo.res_encumb_code_combination_id = x_res_encumb_ccid)
               OR (    (recinfo.res_encumb_code_combination_id IS NULL)
                   AND (x_res_encumb_ccid IS NULL)))
          AND (   (recinfo.net_income_code_combination_id = x_net_income_ccid)
               OR (    (recinfo.net_income_code_combination_id IS NULL)
                   AND (x_net_income_ccid IS NULL)))
          AND (   (recinfo.rounding_code_combination_id = x_rounding_ccid)
               OR (    (recinfo.rounding_code_combination_id IS NULL)
                   AND (x_rounding_ccid IS NULL)))
          AND (   (recinfo.transaction_calendar_id = x_transaction_calendar_id)
               OR (    (recinfo.transaction_calendar_id IS NULL)
                   AND (x_transaction_calendar_id IS NULL)))
          AND (   (recinfo.daily_translation_rate_type =
                                                 x_daily_translation_rate_type)
               OR (    (recinfo.daily_translation_rate_type IS NULL)
                   AND (x_daily_translation_rate_type IS NULL)))
          AND (   (recinfo.period_average_rate_type =
                                                    x_period_average_rate_type)
               OR (    (recinfo.period_average_rate_type IS NULL)
                   AND (x_period_average_rate_type IS NULL)))
          AND (   (recinfo.period_end_rate_type = x_period_end_rate_type)
               OR (    (recinfo.period_end_rate_type IS NULL)
                   AND (x_period_end_rate_type IS NULL)))
          AND (   (recinfo.CONTEXT = x_context)
               OR ((recinfo.CONTEXT IS NULL) AND(x_context IS NULL)))
          AND (   (recinfo.attribute1 = x_attribute1)
               OR ((recinfo.attribute1 IS NULL) AND(x_attribute1 IS NULL)))
          AND (   (recinfo.attribute2 = x_attribute2)
               OR ((recinfo.attribute2 IS NULL) AND(x_attribute2 IS NULL)))
          AND (   (recinfo.attribute3 = x_attribute3)
               OR ((recinfo.attribute3 IS NULL) AND(x_attribute3 IS NULL)))
          AND (   (recinfo.attribute4 = x_attribute4)
               OR ((recinfo.attribute4 IS NULL) AND(x_attribute4 IS NULL)))
          AND (   (recinfo.attribute5 = x_attribute5)
               OR ((recinfo.attribute5 IS NULL) AND(x_attribute5 IS NULL)))
          AND (   (recinfo.attribute6 = x_attribute6)
               OR ((recinfo.attribute6 IS NULL) AND(x_attribute6 IS NULL)))
          AND (   (recinfo.attribute7 = x_attribute7)
               OR ((recinfo.attribute7 IS NULL) AND(x_attribute7 IS NULL)))
          AND (   (recinfo.attribute8 = x_attribute8)
               OR ((recinfo.attribute8 IS NULL) AND(x_attribute8 IS NULL)))
          AND (   (recinfo.attribute9 = x_attribute9)
               OR ((recinfo.attribute9 IS NULL) AND(x_attribute9 IS NULL)))
          AND (   (recinfo.attribute10 = x_attribute10)
               OR ((recinfo.attribute10 IS NULL) AND(x_attribute10 IS NULL)))
          AND (   (recinfo.attribute11 = x_attribute11)
               OR ((recinfo.attribute11 IS NULL) AND(x_attribute11 IS NULL)))
          AND (   (recinfo.attribute12 = x_attribute12)
               OR ((recinfo.attribute12 IS NULL) AND(x_attribute12 IS NULL)))
          AND (   (recinfo.attribute13 = x_attribute13)
               OR ((recinfo.attribute13 IS NULL) AND(x_attribute13 IS NULL)))
          AND (   (recinfo.attribute14 = x_attribute14)
               OR ((recinfo.attribute14 IS NULL) AND(x_attribute14 IS NULL)))
          AND (   (recinfo.attribute15 = x_attribute15)
               OR ((recinfo.attribute15 IS NULL) AND(x_attribute15 IS NULL)))) THEN
         RETURN;
      ELSE
         fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
         app_exception.raise_exception;
      END IF;
   END lock_row;

-- **********************************************************************
-- This Update_Row is used by the Ledger Form; Will be removed after the
-- form is removed.
   PROCEDURE update_row(
      x_rowid                             VARCHAR2,
      x_ledger_id                         NUMBER,
      x_name                              VARCHAR2,
      x_short_name                        VARCHAR2,
      x_chart_of_accounts_id              NUMBER,
      x_chart_of_accounts_name            VARCHAR2,
      x_currency_code                     VARCHAR2,
      x_period_set_name                   VARCHAR2,
      x_user_period_type                  VARCHAR2,
      x_accounted_period_type             VARCHAR2,
      x_first_ledger_period_name          VARCHAR2,
      x_ret_earn_code_combination_id      NUMBER,
      x_suspense_allowed_flag             VARCHAR2,
      x_suspense_ccid                     NUMBER,
      x_allow_intercompany_post_flag      VARCHAR2,
      x_enable_avgbal_flag                VARCHAR2,
      x_enable_budgetary_control_f        VARCHAR2,
      x_require_budget_journals_flag      VARCHAR2,
      x_enable_je_approval_flag           VARCHAR2,
      x_enable_automatic_tax_flag         VARCHAR2,
      x_consolidation_ledger_flag         VARCHAR2,
      x_translate_eod_flag                VARCHAR2,
      x_translate_qatd_flag               VARCHAR2,
      x_translate_yatd_flag               VARCHAR2,
      x_automatically_created_flag        VARCHAR2,
      x_track_rounding_imbalance_f        VARCHAR2,
      x_alc_ledger_type_code              VARCHAR2,
      x_le_ledger_type_code               VARCHAR2,
      x_bal_seg_value_option_code         VARCHAR2,
      x_bal_seg_column_name               VARCHAR2,
      x_bal_seg_value_set_id              NUMBER,
      x_mgt_seg_value_option_code         VARCHAR2,
      x_mgt_seg_column_name               VARCHAR2,
      x_mgt_seg_value_set_id              NUMBER,
      x_implicit_access_set_id            NUMBER,
      x_last_update_date                  DATE,
      x_last_updated_by                   NUMBER,
      x_last_update_login                 NUMBER,
      x_description                       VARCHAR2,
      x_future_enterable_periods_lmt      NUMBER,
      x_latest_opened_period_name         VARCHAR2,
      x_latest_encumbrance_year           NUMBER,
      x_cum_trans_ccid                    NUMBER,
      x_res_encumb_ccid                   NUMBER,
      x_net_income_ccid                   NUMBER,
      x_balancing_segment                 VARCHAR2,
      x_rounding_ccid                     NUMBER,
      x_transaction_calendar_id           NUMBER,
      x_transaction_calendar_name         VARCHAR2,
      x_daily_translation_rate_type       VARCHAR2,
      x_daily_user_translation_type       VARCHAR2,
      x_period_average_rate_type          VARCHAR2,
      x_period_avg_user_rate_type         VARCHAR2,
      x_period_end_rate_type              VARCHAR2,
      x_period_end_user_rate_type         VARCHAR2,
      x_context                           VARCHAR2,
      x_attribute1                        VARCHAR2,
      x_attribute2                        VARCHAR2,
      x_attribute3                        VARCHAR2,
      x_attribute4                        VARCHAR2,
      x_attribute5                        VARCHAR2,
      x_attribute6                        VARCHAR2,
      x_attribute7                        VARCHAR2,
      x_attribute8                        VARCHAR2,
      x_attribute9                        VARCHAR2,
      x_attribute10                       VARCHAR2,
      x_attribute11                       VARCHAR2,
      x_attribute12                       VARCHAR2,
      x_attribute13                       VARCHAR2,
      x_attribute14                       VARCHAR2,
      x_attribute15                       VARCHAR2,
      x_set_manual_flag                   VARCHAR2) IS
   BEGIN
      UPDATE gl_ledgers
         SET ledger_id = x_ledger_id,
             NAME = x_name,
             short_name = x_short_name,
             chart_of_accounts_id = x_chart_of_accounts_id,
             currency_code = x_currency_code,
             period_set_name = x_period_set_name,
             accounted_period_type = x_accounted_period_type,
             first_ledger_period_name = x_first_ledger_period_name,
             ret_earn_code_combination_id = x_ret_earn_code_combination_id,
             suspense_allowed_flag = x_suspense_allowed_flag,
             allow_intercompany_post_flag = x_allow_intercompany_post_flag,
             enable_average_balances_flag = x_enable_avgbal_flag,
             enable_budgetary_control_flag = x_enable_budgetary_control_f,
             require_budget_journals_flag = x_require_budget_journals_flag,
             enable_je_approval_flag = x_enable_je_approval_flag,
             enable_automatic_tax_flag = x_enable_automatic_tax_flag,
             consolidation_ledger_flag = x_consolidation_ledger_flag,
             translate_eod_flag = x_translate_eod_flag,
             translate_qatd_flag = x_translate_qatd_flag,
             translate_yatd_flag = x_translate_yatd_flag,
             automatically_created_flag = x_automatically_created_flag,
             track_rounding_imbalance_flag = x_track_rounding_imbalance_f,
             alc_ledger_type_code = x_alc_ledger_type_code,
             le_ledger_type_code = x_le_ledger_type_code,
             bal_seg_value_option_code = x_bal_seg_value_option_code,
             bal_seg_column_name = x_bal_seg_column_name,
             bal_seg_value_set_id = x_bal_seg_value_set_id,
             mgt_seg_value_option_code = x_mgt_seg_value_option_code,
             mgt_seg_column_name = x_mgt_seg_column_name,
             mgt_seg_value_set_id = x_mgt_seg_value_set_id,
             last_update_date = x_last_update_date,
             last_updated_by = x_last_updated_by,
             last_update_login = x_last_update_login,
             description = x_description,
             future_enterable_periods_limit = x_future_enterable_periods_lmt,
             latest_opened_period_name = x_latest_opened_period_name,
             latest_encumbrance_year = x_latest_encumbrance_year,
             cum_trans_code_combination_id = x_cum_trans_ccid,
             res_encumb_code_combination_id = x_res_encumb_ccid,
             net_income_code_combination_id = x_net_income_ccid,
             rounding_code_combination_id = x_rounding_ccid,
             transaction_calendar_id = x_transaction_calendar_id,
             daily_translation_rate_type = x_daily_translation_rate_type,
             period_average_rate_type = x_period_average_rate_type,
             period_end_rate_type = x_period_end_rate_type,
             CONTEXT = x_context,
             attribute1 = x_attribute1,
             attribute2 = x_attribute2,
             attribute3 = x_attribute3,
             attribute4 = x_attribute4,
             attribute5 = x_attribute5,
             attribute6 = x_attribute6,
             attribute7 = x_attribute7,
             attribute8 = x_attribute8,
             attribute9 = x_attribute9,
             attribute10 = x_attribute10,
             attribute11 = x_attribute11,
             attribute12 = x_attribute12,
             attribute13 = x_attribute13,
             attribute14 = x_attribute14,
             attribute15 = x_attribute15
       WHERE ROWID = x_rowid;

      IF (SQL%NOTFOUND) THEN
         RAISE NO_DATA_FOUND;
      END IF;

      -- Update the implicit access set name for the ledger
      gl_access_sets_pkg.update_implicit_access_set
                                 (x_access_set_id => x_implicit_access_set_id,
                                  x_name => x_name,
                                  x_last_update_date => x_last_update_date,
                                  x_last_updated_by => x_last_updated_by,
                                  x_last_update_login => x_last_update_login);

      -- Check whether journal_approval_flag is to be set to Y for
      -- the Manual source.
      IF (x_set_manual_flag = 'Y') THEN
         gl_ledgers_pkg.enable_manual_je_approval;
      END IF;

      gl_ledgers_pkg.led_update_other_tables(x_ledger_id, x_last_update_date,
                                             x_last_updated_by,
                                             x_suspense_ccid);
   END update_row;

-- **********************************************************************
   PROCEDURE select_row(
      recinfo                    IN OUT NOCOPY gl_ledgers%ROWTYPE) IS
   BEGIN
      SELECT *
        INTO recinfo
        FROM gl_ledgers
       WHERE ledger_id = recinfo.ledger_id;
   END select_row;

-- **********************************************************************
   PROCEDURE select_columns(
      x_ledger_id                         NUMBER,
      x_name                     IN OUT NOCOPY VARCHAR2) IS
      recinfo   gl_ledgers%ROWTYPE;
   BEGIN
      recinfo.ledger_id := x_ledger_id;
      select_row(recinfo);
      x_name := recinfo.NAME;
   END select_columns;

-- **********************************************************************
   PROCEDURE update_gl_system_usages(
      cons_lgr_flag                       VARCHAR2) IS
   BEGIN
      UPDATE gl_system_usages
         SET average_balances_flag = 'Y',
             consolidation_ledger_flag =
                    DECODE(cons_lgr_flag,
                           'Y', 'Y',
                           consolidation_ledger_flag)
       WHERE EXISTS(
                SELECT '1'
                  FROM gl_system_usages
                 WHERE average_balances_flag = 'N'
                    OR (    (cons_lgr_flag = 'Y')
                        AND consolidation_ledger_flag = 'N'));
   END update_gl_system_usages;

-- **********************************************************************
   PROCEDURE insert_gl_net_income_accounts(
      x_ledger_id                         NUMBER,
      x_balancing_segment                 VARCHAR2,
      x_net_income_ccid                   NUMBER,
      x_creation_date                     DATE,
      x_created_by                        NUMBER,
      x_last_update_date                  DATE,
      x_last_updated_by                   NUMBER,
      x_last_update_login                 NUMBER,
      x_request_id                        NUMBER,
      x_program_application_id            NUMBER,
      x_program_id                        NUMBER,
      x_program_update_date               DATE) IS
   BEGIN
      INSERT INTO gl_net_income_accounts
                  (ledger_id, bal_seg_value, code_combination_id,
                   creation_date, created_by, last_update_date,
                   last_updated_by, last_update_login, request_id,
                   program_application_id, program_id,
                   program_update_date)
           VALUES (x_ledger_id, x_balancing_segment, x_net_income_ccid,
                   x_creation_date, x_created_by, x_last_update_date,
                   x_last_updated_by, x_last_update_login, x_request_id,
                   x_program_application_id, x_program_id,
                   x_program_update_date);
   END insert_gl_net_income_accounts;

-- **********************************************************************
   PROCEDURE led_update_other_tables(
      x_ledger_id                         NUMBER,
      x_last_update_date                  DATE,
      x_last_updated_by                   NUMBER,
      x_suspense_ccid                     NUMBER) IS
      FOUND   BOOLEAN;
   BEGIN
      -- Update the existing rows in gl_suspense_accounts table for
      -- the corresponding ledger.  If they are not exist create
      -- the new default suspense accounts  into gl_suspense_accounts
      -- for the corresponding ledger.
      FOUND := gl_suspense_accounts_pkg.is_ledger_suspense_exist(x_ledger_id);

      IF (FOUND) THEN
         -- Update rows in gl_suspense_accounts table for the
         -- corresponding ledger.
         -- This statement is executed no matter X_suspense_CCID
         -- is NULL or not, since the function checks for NULL and
         -- delete the appropriate lines when CCID is NULL.
         gl_suspense_accounts_pkg.update_ledger_suspense(x_ledger_id,
                                                         x_suspense_ccid,
                                                         x_last_update_date,
                                                         x_last_updated_by);
      ELSE
         -- Create rows in gl_suspense_accounts table for the
         -- corresponding new created ledger.
         IF (x_suspense_ccid IS NOT NULL) THEN
            gl_suspense_accounts_pkg.insert_ledger_suspense
                                                         (x_ledger_id,
                                                          x_suspense_ccid,
                                                          x_last_update_date,
                                                          x_last_updated_by);
         END IF;
      END IF;
   END led_update_other_tables;

-- **********************************************************************
   FUNCTION check_avg_translation(
      x_ledger_id                         NUMBER)
      RETURN BOOLEAN IS
      CURSOR check_avg_translation IS
         SELECT 'avg translated'
           FROM DUAL
          WHERE EXISTS(
                   SELECT 'X'
                     FROM gl_translation_tracking
                    WHERE ledger_id = x_ledger_id
                      AND average_translation_flag = 'Y'
                      AND earliest_ever_period_name <>
                                                    earliest_never_period_name);

      dummy   VARCHAR2(100);
   BEGIN
      OPEN check_avg_translation;

      FETCH check_avg_translation
       INTO dummy;

      IF check_avg_translation%FOUND THEN
         CLOSE check_avg_translation;

         RETURN(TRUE);
      ELSE
         CLOSE check_avg_translation;

         RETURN(FALSE);
      END IF;
   END check_avg_translation;

-- **********************************************************************
   PROCEDURE enable_manual_je_approval IS
   BEGIN
      -- Set the journal_approval_flag column for Manual source.
      UPDATE gl_je_sources
         SET journal_approval_flag = 'Y'
       WHERE je_source_name = 'Manual';
   END enable_manual_je_approval;

-- **********************************************************************
   PROCEDURE insert_set(
      x_rowid                    IN OUT NOCOPY VARCHAR2,
      x_access_set_id            IN OUT NOCOPY NUMBER,
      x_ledger_id                         NUMBER,
      x_name                              VARCHAR2,
      x_short_name                        VARCHAR2,
      x_chart_of_accounts_id              NUMBER,
      x_period_set_name                   VARCHAR2,
      x_accounted_period_type             VARCHAR2,
      x_default_ledger_id                 NUMBER,
      x_last_update_date                  DATE,
      x_last_updated_by                   NUMBER,
      x_creation_date                     DATE,
      x_created_by                        NUMBER,
      x_last_update_login                 NUMBER,
      x_description                       VARCHAR2,
      x_context                           VARCHAR2,
      x_attribute1                        VARCHAR2,
      x_attribute2                        VARCHAR2,
      x_attribute3                        VARCHAR2,
      x_attribute4                        VARCHAR2,
      x_attribute5                        VARCHAR2,
      x_attribute6                        VARCHAR2,
      x_attribute7                        VARCHAR2,
      x_attribute8                        VARCHAR2,
      x_attribute9                        VARCHAR2,
      x_attribute10                       VARCHAR2,
      x_attribute11                       VARCHAR2,
      x_attribute12                       VARCHAR2,
      x_attribute13                       VARCHAR2,
      x_attribute14                       VARCHAR2,
      x_attribute15                       VARCHAR2) IS
      l_bal_seg_column_name    VARCHAR2(25);
      l_mgt_seg_column_name    VARCHAR2(25);
      l_bal_seg_value_set_id   NUMBER(10);
      l_mgt_seg_value_set_id   NUMBER(10);
      l_chart_of_accounts_id   NUMBER(15);

      CURSOR c IS
         SELECT ROWID
           FROM gl_ledgers
          WHERE NAME = x_name;
   BEGIN
      l_chart_of_accounts_id := x_chart_of_accounts_id;
      gl_ledgers_pkg.get_bal_mgt_seg_info(l_bal_seg_column_name,
                                          l_bal_seg_value_set_id,
                                          l_mgt_seg_column_name,
                                          l_mgt_seg_value_set_id,
                                          l_chart_of_accounts_id);
      -- Create an implicit access set header
      x_access_set_id :=
         gl_access_sets_pkg.create_implicit_access_set
                         (x_name => x_name, x_security_segment_code => 'F',
                          x_chart_of_accounts_id => x_chart_of_accounts_id,
                          x_period_set_name => x_period_set_name,
                          x_accounted_period_type => x_accounted_period_type,
                          x_default_ledger_id => x_default_ledger_id,
                          x_secured_seg_value_set_id => NULL,
                          x_last_updated_by => x_last_updated_by,
                          x_last_update_login => x_last_update_login,
                          x_creation_date => x_creation_date,
                          x_description => x_description);

      INSERT INTO gl_ledgers
                  (ledger_id, NAME, short_name,
                   chart_of_accounts_id, currency_code, period_set_name,
                   accounted_period_type, first_ledger_period_name,
                   ret_earn_code_combination_id, suspense_allowed_flag,
                   allow_intercompany_post_flag,
                   track_rounding_imbalance_flag,
                   enable_average_balances_flag,
                   enable_budgetary_control_flag,
                   require_budget_journals_flag, enable_je_approval_flag,
                   enable_automatic_tax_flag, consolidation_ledger_flag,
                   translate_eod_flag, translate_qatd_flag,
                   translate_yatd_flag, automatically_created_flag,
                   alc_ledger_type_code, ledger_category_code,
                   object_type_code, le_ledger_type_code,
                   bal_seg_value_option_code, bal_seg_column_name,
                   mgt_seg_value_option_code, mgt_seg_column_name,
                   bal_seg_value_set_id, mgt_seg_value_set_id,
                   implicit_access_set_id, future_enterable_periods_limit,
                   ledger_attributes, enable_reconciliation_flag,
                   last_update_date, last_updated_by,
                   creation_date, created_by, last_update_login,
                   description, CONTEXT, attribute1, attribute2,
                   attribute3, attribute4, attribute5, attribute6,
                   attribute7, attribute8, attribute9, attribute10,
                   attribute11, attribute12, attribute13,
                   attribute14, attribute15, create_je_flag,net_closing_bal_flag,automate_sec_jrnl_rev_flag)--Added the net closing bal flag for bug 8612291
           VALUES (x_ledger_id, x_name, x_short_name,
                   x_chart_of_accounts_id, 'X',               -- currency_code
                                               x_period_set_name,
                   x_accounted_period_type, 'X',   -- first_ledger_period_name
                   -1,                         -- ret_earn_code_combination_id
                      'N',                            -- suspense_allowed_flag
                   'N',                        -- allow_intercompany_post_flag
                   'N',                       -- track_rounding_imbalance_flag
                   'N',                        -- enable_average_balances_flag
                   'N',                       -- enable_budgetary_control_flag
                   'N',                        -- require_budget_journals_flag
                       'N',                         -- enable_je_approval_flag
                   'N',                           -- enable_automatic_tax_flag
                       'N',                       -- consolidation_ledger_flag
                   'N',                                  -- translate_eod_flag
                       'N',                             -- translate_qatd_flag
                   'N',                                 -- translate_yatd_flag
                       'N',                      -- automatically_created_flag
                   'NONE',                             -- alc_ledger_type_code
                          'NONE',                      -- ledger_category_code
                   'S',                                    -- object_type_code
                       'U',                             -- le_ledger_type_code
                   'I',                           -- bal_seg_value_option_code
                       l_bal_seg_column_name,
                   'I',                           -- mgt_seg_value_option_code
                       l_mgt_seg_column_name,
                   l_bal_seg_value_set_id, l_mgt_seg_value_set_id,
                   x_access_set_id, 0,       -- future_enterable_periods_limit
                   'S', 'N',  -- ledger_attributes, enable_reconciliation_flag
                   x_last_update_date, x_last_updated_by,
                   x_creation_date, x_created_by, x_last_update_login,
                   x_description, x_context, x_attribute1, x_attribute2,
                   x_attribute3, x_attribute4, x_attribute5, x_attribute6,
                   x_attribute7, x_attribute8, x_attribute9, x_attribute10,
                   x_attribute11, x_attribute12, x_attribute13,
                   x_attribute14, x_attribute15,
                   'N',-- create_je_flag
                   'N','N');  --Added the default value net closing bal flag for bug 8612291

      OPEN c;

      FETCH c
       INTO x_rowid;

      IF (c%NOTFOUND) THEN
         CLOSE c;

         RAISE NO_DATA_FOUND;
      END IF;

      CLOSE c;
   END insert_set;

-- **********************************************************************
   PROCEDURE lock_set(
      x_rowid                             VARCHAR2,
      x_ledger_id                         NUMBER,
      x_name                              VARCHAR2,
      x_short_name                        VARCHAR2,
      x_chart_of_accounts_id              NUMBER,
      x_period_set_name                   VARCHAR2,
      x_accounted_period_type             VARCHAR2,
      x_description                       VARCHAR2,
      x_context                           VARCHAR2,
      x_attribute1                        VARCHAR2,
      x_attribute2                        VARCHAR2,
      x_attribute3                        VARCHAR2,
      x_attribute4                        VARCHAR2,
      x_attribute5                        VARCHAR2,
      x_attribute6                        VARCHAR2,
      x_attribute7                        VARCHAR2,
      x_attribute8                        VARCHAR2,
      x_attribute9                        VARCHAR2,
      x_attribute10                       VARCHAR2,
      x_attribute11                       VARCHAR2,
      x_attribute12                       VARCHAR2,
      x_attribute13                       VARCHAR2,
      x_attribute14                       VARCHAR2,
      x_attribute15                       VARCHAR2) IS
      CURSOR c IS
         SELECT        *
                  FROM gl_ledgers
                 WHERE ROWID = x_rowid
         FOR UPDATE OF NAME NOWAIT;

      recinfo   c%ROWTYPE;
   BEGIN
      OPEN c;

      FETCH c
       INTO recinfo;

      IF (c%NOTFOUND) THEN
         CLOSE c;

         RAISE NO_DATA_FOUND;
      END IF;

      CLOSE c;

      IF (    (   (recinfo.ledger_id = x_ledger_id)
               OR ((recinfo.ledger_id IS NULL) AND(x_ledger_id IS NULL)))
          AND (   (recinfo.NAME = x_name)
               OR ((recinfo.NAME IS NULL) AND(x_name IS NULL)))
          AND (   (recinfo.short_name = x_short_name)
               OR ((recinfo.short_name IS NULL) AND(x_short_name IS NULL)))
          AND (   (recinfo.chart_of_accounts_id = x_chart_of_accounts_id)
               OR (    (recinfo.chart_of_accounts_id IS NULL)
                   AND (x_chart_of_accounts_id IS NULL)))
          AND (   (recinfo.period_set_name = x_period_set_name)
               OR (    (recinfo.period_set_name IS NULL)
                   AND (x_period_set_name IS NULL)))
          AND (   (recinfo.accounted_period_type = x_accounted_period_type)
               OR (    (recinfo.accounted_period_type IS NULL)
                   AND (x_accounted_period_type IS NULL)))
          AND (   (recinfo.description = x_description)
               OR ((recinfo.description IS NULL) AND(x_description IS NULL)))
          AND (   (recinfo.CONTEXT = x_context)
               OR ((recinfo.CONTEXT IS NULL) AND(x_context IS NULL)))
          AND (   (recinfo.attribute1 = x_attribute1)
               OR ((recinfo.attribute1 IS NULL) AND(x_attribute1 IS NULL)))
          AND (   (recinfo.attribute2 = x_attribute2)
               OR ((recinfo.attribute2 IS NULL) AND(x_attribute2 IS NULL)))
          AND (   (recinfo.attribute3 = x_attribute3)
               OR ((recinfo.attribute3 IS NULL) AND(x_attribute3 IS NULL)))
          AND (   (recinfo.attribute4 = x_attribute4)
               OR ((recinfo.attribute4 IS NULL) AND(x_attribute4 IS NULL)))
          AND (   (recinfo.attribute5 = x_attribute5)
               OR ((recinfo.attribute5 IS NULL) AND(x_attribute5 IS NULL)))
          AND (   (recinfo.attribute6 = x_attribute6)
               OR ((recinfo.attribute6 IS NULL) AND(x_attribute6 IS NULL)))
          AND (   (recinfo.attribute7 = x_attribute7)
               OR ((recinfo.attribute7 IS NULL) AND(x_attribute7 IS NULL)))
          AND (   (recinfo.attribute8 = x_attribute8)
               OR ((recinfo.attribute8 IS NULL) AND(x_attribute8 IS NULL)))
          AND (   (recinfo.attribute9 = x_attribute9)
               OR ((recinfo.attribute9 IS NULL) AND(x_attribute9 IS NULL)))
          AND (   (recinfo.attribute10 = x_attribute10)
               OR ((recinfo.attribute10 IS NULL) AND(x_attribute10 IS NULL)))
          AND (   (recinfo.attribute11 = x_attribute11)
               OR ((recinfo.attribute11 IS NULL) AND(x_attribute11 IS NULL)))
          AND (   (recinfo.attribute12 = x_attribute12)
               OR ((recinfo.attribute12 IS NULL) AND(x_attribute12 IS NULL)))
          AND (   (recinfo.attribute13 = x_attribute13)
               OR ((recinfo.attribute13 IS NULL) AND(x_attribute13 IS NULL)))
          AND (   (recinfo.attribute14 = x_attribute14)
               OR ((recinfo.attribute14 IS NULL) AND(x_attribute14 IS NULL)))
          AND (   (recinfo.attribute15 = x_attribute15)
               OR ((recinfo.attribute15 IS NULL) AND(x_attribute15 IS NULL)))) THEN
         RETURN;
      ELSE
         fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
         app_exception.raise_exception;
      END IF;
   END lock_set;

-- **********************************************************************
   PROCEDURE update_set(
      x_rowid                             VARCHAR2,
      x_access_set_id                     NUMBER,
      x_ledger_id                         NUMBER,
      x_name                              VARCHAR2,
      x_short_name                        VARCHAR2,
      x_chart_of_accounts_id              NUMBER,
      x_period_set_name                   VARCHAR2,
      x_accounted_period_type             VARCHAR2,
      x_default_ledger_id                 NUMBER,
      x_last_update_date                  DATE,
      x_last_updated_by                   NUMBER,
      x_last_update_login                 NUMBER,
      x_description                       VARCHAR2,
      x_context                           VARCHAR2,
      x_attribute1                        VARCHAR2,
      x_attribute2                        VARCHAR2,
      x_attribute3                        VARCHAR2,
      x_attribute4                        VARCHAR2,
      x_attribute5                        VARCHAR2,
      x_attribute6                        VARCHAR2,
      x_attribute7                        VARCHAR2,
      x_attribute8                        VARCHAR2,
      x_attribute9                        VARCHAR2,
      x_attribute10                       VARCHAR2,
      x_attribute11                       VARCHAR2,
      x_attribute12                       VARCHAR2,
      x_attribute13                       VARCHAR2,
      x_attribute14                       VARCHAR2,
      x_attribute15                       VARCHAR2) IS
   BEGIN
      UPDATE gl_ledgers
         SET ledger_id = x_ledger_id,
             NAME = x_name,
             short_name = x_short_name,
             chart_of_accounts_id = x_chart_of_accounts_id,
             period_set_name = x_period_set_name,
             accounted_period_type = x_accounted_period_type,
             last_update_date = x_last_update_date,
             last_updated_by = x_last_updated_by,
             last_update_login = x_last_update_login,
             description = x_description,
             CONTEXT = x_context,
             attribute1 = x_attribute1,
             attribute2 = x_attribute2,
             attribute3 = x_attribute3,
             attribute4 = x_attribute4,
             attribute5 = x_attribute5,
             attribute6 = x_attribute6,
             attribute7 = x_attribute7,
             attribute8 = x_attribute8,
             attribute9 = x_attribute9,
             attribute10 = x_attribute10,
             attribute11 = x_attribute11,
             attribute12 = x_attribute12,
             attribute13 = x_attribute13,
             attribute14 = x_attribute14,
             attribute15 = x_attribute15
       WHERE ROWID = x_rowid;

      IF (SQL%NOTFOUND) THEN
         RAISE NO_DATA_FOUND;
      END IF;

      -- Update the implicit access set name for the ledger
      gl_access_sets_pkg.update_implicit_access_set
                                   (x_access_set_id => x_access_set_id,
                                    x_name => x_name,
                                    x_last_update_date => x_last_update_date,
                                    x_last_updated_by => x_last_updated_by,
                                    x_last_update_login => x_last_update_login);

      -- Only when updating ledger sets could the default ledger be changed.
      UPDATE gl_access_sets
         SET default_ledger_id = x_default_ledger_id
       WHERE access_set_id = x_access_set_id;
   END update_set;

-- **********************************************************************
   FUNCTION maintain_def_ledger_assign(
      x_ledger_set_id     NUMBER,
      x_default_ledger_id NUMBER) RETURN BOOLEAN IS

      CURSOR c_default_ledger_assign IS
         SELECT 1
         FROM   GL_LEDGER_SET_NORM_ASSIGN
         WHERE  ledger_set_id = x_ledger_set_id
         AND    ledger_id     = x_default_ledger_id
         AND    (status_code  <> 'D' OR status_code IS NULL)
         AND    rownum < 2;

      dumnum  NUMBER;
      rowid   VARCHAR2(30);

      updated_by    NUMBER;
      update_login  NUMBER;
      update_date   DATE;
   BEGIN
      OPEN c_default_ledger_assign;
      FETCH c_default_ledger_assign INTO dumnum;
      IF c_default_ledger_assign%FOUND THEN
         CLOSE c_default_ledger_assign;
         RETURN FALSE;
      END IF;
      CLOSE c_default_ledger_assign;

      -- Insert default ledger assignment
      SELECT last_updated_by, last_update_login, last_update_date
      INTO   updated_by, update_login, update_date
      FROM   GL_LEDGERS
      WHERE  ledger_id = x_ledger_set_id;

      GL_LEDGER_SET_NORM_ASSIGN_PKG.Insert_Row(
         rowid,
         x_ledger_set_id,
         x_default_ledger_id,
         'L',          -- object_type_code
         update_date,  -- last_update_date
         updated_by,   -- last_updated_by
         update_date,  -- creation_date
         updated_by,   -- created_by
         update_login, -- last_update_login
         NULL,         -- start_date
         NULL,         -- end_date
         NULL,         -- context
         NULL,         -- attribute1
         NULL,         -- attribute2
         NULL,         -- attribute3
         NULL,         -- attribute4
         NULL,         -- attribute5
         NULL,         -- attribute6
         NULL,         -- attribute7
         NULL,         -- attribute8
         NULL,         -- attribute9
         NULL,         -- attribute10
         NULL,         -- attribute11
         NULL,         -- attribute12
         NULL,         -- attribute13
         NULL,         -- attribute14
         NULL,         -- attribute15
         NULL);        -- request_id

      RETURN TRUE;
   END maintain_def_ledger_assign;

-- *********************************************************************
PROCEDURE Get_CCID(Y_Chart_Of_Accounts_Id    NUMBER,
                  Y_Concat_Segments         VARCHAR2,
                  Y_Account_Code            VARCHAR2,
                  Y_Average_Balances_Flag   VARCHAR2,
                  Y_User_Id                 NUMBER,
                  Y_Resp_Id                 NUMBER,
                  Y_Resp_Appl_Id            NUMBER,
                  Y_CCID                OUT NOCOPY NUMBER) IS

  return_value    BOOLEAN;
  rule            VARCHAR2(1000);
  get_column      VARCHAR2(30);
  where_clause    VARCHAR2(30);
  message_name    VARCHAR2(30);

BEGIN
   get_column := NULL;
   where_clause := 'SUMMARY_FLAG<>''Y''';
   message_name :=
   gl_public_sector.get_message_name('GL_RETAINED_EARNINGS_TITLE','SQLGL',NULL);


   IF (Y_Account_Code = 'RET_EARN') THEN
      rule := '\nSUMMARY_FLAG\nI\n' ||
              'APPL=SQLGL;NAME=GL_NO_PARENT_SEGMENT_ALLOWED\nN\0' ||
              'GL_GLOBAL\nDETAIL_POSTING_ALLOWED' ||
              '\nI\n' ||
              'APPL=SQLGL;NAME=GL_JE_POSTING_NOT_ALLOWED\nY\0' ||
              'GL_ACCOUNT\nGL_ACCOUNT_TYPE' ||
              '\nE\n' ||
              'APPL=SQLGL;NAME=' || message_name || '\nE\0' ||
              'GL_ACCOUNT\nGL_ACCOUNT_TYPE' ||
              '\nE\n' ||
              'APPL=SQLGL;NAME=' || message_name || '\nR';

   ELSIF (Y_Account_Code in('SUSPENSE','SLA_ENT_SUS','SLA_LDG_SUS')) THEN
      rule := '\nSUMMARY_FLAG\nI\n' ||
              'APPL=SQLGL;NAME=GL_NO_PARENT_SEGMENT_ALLOWED\nN\0' ||
              'GL_GLOBAL\nDETAIL_POSTING_ALLOWED' ||
              '\nI\n' ||
              'APPL=SQLGL;NAME=GL_JE_POSTING_NOT_ALLOWED\nY';

   ELSIF (Y_Account_Code = 'ROUNDING') THEN
      rule := '\nSUMMARY_FLAG\nI\n' ||
              'APPL=SQLGL;NAME=GL_NO_PARENT_SEGMENT_ALLOWED\nN\0' ||
              'GL_GLOBAL\nDETAIL_POSTING_ALLOWED' ||
              '\nI\n' ||
              'APPL=SQLGL;NAME=GL_JE_POSTING_NOT_ALLOWED\nY';

   ELSIF (Y_Account_Code = 'RES_ENCUMB') THEN
      rule := '\nSUMMARY_FLAG\nI\n' ||
              'APPL=SQLGL;NAME=GL_NO_PARENT_SEGMENT_ALLOWED\nN\0' ||
              'GL_GLOBAL\nDETAIL_POSTING_ALLOWED' ||
              '\nI\n' ||
              'APPL=SQLGL;NAME=GL_JE_POSTING_NOT_ALLOWED\nY';

   ELSIF (Y_Account_Code = 'CUM_TRANS') THEN
      IF (Y_Average_Balances_Flag = 'Y') THEN
         rule := '\nSUMMARY_FLAG\nI\n' ||
                 'APPL=SQLGL;NAME=GL_NO_PARENT_SEGMENT_ALLOWED\nN\0' ||
                 'GL_GLOBAL\nDETAIL_POSTING_ALLOWED' ||
                 '\nI\n' ||
                 'APPL=SQLGL;NAME=GL_JE_POSTING_NOT_ALLOWED\nY\0' ||
                 'GL_ACCOUNT\nGL_ACCOUNT_TYPE' ||
                 '\nE\n' ||
                 'APPL=SQLGL;NAME=GL_SOB_TRANSLATION_ACCOUNT\nE\0' ||
                 'GL_ACCOUNT\nGL_ACCOUNT_TYPE' ||
                 '\nE\n' ||
                 'APPL=SQLGL;NAME=GL_SOB_TRANSLATION_ACCOUNT\nR';
      ELSE
         rule := '\nSUMMARY_FLAG\nI\n' ||
                 'APPL=SQLGL;NAME=GL_NO_PARENT_SEGMENT_ALLOWED\nN\0' ||
                 'GL_GLOBAL\nDETAIL_POSTING_ALLOWED' ||
                 '\nI\n' ||
                 'APPL=SQLGL;NAME=GL_JE_POSTING_NOT_ALLOWED\nY';
      END IF;

   ELSIF (Y_Account_Code = 'NET_INCOME') THEN
      rule := '\nSUMMARY_FLAG\nI\n' ||
              'APPL=SQLGL;NAME=GL_NO_PARENT_SEGMENT_ALLOWED\nN\0' ||
              'GL_ACCOUNT\nGL_ACCOUNT_TYPE' ||
              '\nE\n' ||
              'APPL=SQLGL;NAME=GL_SOB_REVENUE_EXPENSE\nE\0' ||
              'GL_ACCOUNT\nGL_ACCOUNT_TYPE' ||
              '\nE\n' ||
              'APPL=SQLGL;NAME=GL_SOB_REVENUE_EXPENSE\nR';
      get_column := 'DETAIL_POSTING_ALLOWED_FLAG';

   END IF;

   return_value := fnd_flex_keyval.validate_segs('CREATE_COMBINATION','SQLGL',
                      'GL#', Y_Chart_Of_Accounts_Id, Y_Concat_Segments,
                      'V', sysdate, 'ALL', NULL, rule, where_clause,
                      get_column, FALSE, FALSE,
                      Y_Resp_Appl_Id, Y_Resp_Id, Y_User_Id, NULL, NULL, NULL);

   IF (return_value) THEN
      IF (Y_Account_Code = 'NET_INCOME') THEN
         IF (fnd_flex_keyval.column_value(1) <> 'N') THEN
            fnd_message.set_name('SQLGL', 'GL_NET_INCOME_COMBINATION');
            app_exception.raise_exception;
         ELSIF (fnd_flex_keyval.qualifier_value('DETAIL_POSTING_ALLOWED', 'D') <> 'N') THEN
            fnd_message.set_name('SQLGL', 'GL_NET_INCOME_SEGMENTS');
            app_exception.raise_exception;
         END IF;
      END IF;
      Y_CCID := fnd_flex_keyval.combination_id;
   ELSE
      Y_CCID := 0;
   END IF;

EXCEPTION
  WHEN OTHERS THEN
    fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
    fnd_message.set_token('PROCEDURE', 'GL_LEDGERS_PKG.Get_CCID');
    RAISE;
END Get_CCID;

-- *********************************************************************
   PROCEDURE insert_set(
      x_ledger_id               NUMBER,
      x_name                    VARCHAR2,
      x_short_name              VARCHAR2,
      x_chart_of_accounts_id    NUMBER,
      x_period_set_name         VARCHAR2,
      x_accounted_period_type   VARCHAR2,
      x_default_ledger_id       NUMBER,
      x_date                    DATE,
      x_user_id                 NUMBER,
      x_login_id                NUMBER,
      x_description             VARCHAR2,
      x_context                 VARCHAR2,
      x_attribute1              VARCHAR2,
      x_attribute2              VARCHAR2,
      x_attribute3              VARCHAR2,
      x_attribute4              VARCHAR2,
      x_attribute5              VARCHAR2,
      x_attribute6              VARCHAR2,
      x_attribute7              VARCHAR2,
      x_attribute8              VARCHAR2,
      x_attribute9              VARCHAR2,
      x_attribute10             VARCHAR2,
      x_attribute11             VARCHAR2,
      x_attribute12             VARCHAR2,
      x_attribute13             VARCHAR2,
      x_attribute14             VARCHAR2,
      x_attribute15             VARCHAR2) IS
      l_bal_seg_column_name   VARCHAR2(25);
      l_mgt_seg_column_name   VARCHAR2(25);
      l_bal_seg_value_set_id  NUMBER(10);
      l_mgt_seg_value_set_id  NUMBER(10);
      l_chart_of_accounts_id  NUMBER(15);
      l_access_set_id         NUMBER(15);
   BEGIN
      l_chart_of_accounts_id := x_chart_of_accounts_id;
      gl_ledgers_pkg.get_bal_mgt_seg_info(l_bal_seg_column_name,
                                          l_bal_seg_value_set_id,
                                          l_mgt_seg_column_name,
                                          l_mgt_seg_value_set_id,
                                          l_chart_of_accounts_id);

      -- Create an implicit access set header
      l_access_set_id := GL_ACCESS_SETS_PKG.create_implicit_access_set
                          (x_name                  => x_name,
                           x_security_segment_code => 'F',
                           x_chart_of_accounts_id  => x_chart_of_accounts_id,
                           x_period_set_name       => x_period_set_name,
                           x_accounted_period_type => x_accounted_period_type,
                           x_default_ledger_id     => x_default_ledger_id,
                           x_secured_seg_value_set_id => NULL,
                           x_last_updated_by       => x_user_id,
                           x_last_update_login     => x_login_id,
                           x_creation_date         => x_date,
                           x_description           => x_description);

      INSERT INTO GL_LEDGERS
         (ledger_id, name, short_name, chart_of_accounts_id, currency_code,
          period_set_name, accounted_period_type, first_ledger_period_name,
          ret_earn_code_combination_id, suspense_allowed_flag,
          allow_intercompany_post_flag, track_rounding_imbalance_flag,
          enable_average_balances_flag, enable_budgetary_control_flag,
          require_budget_journals_flag, enable_je_approval_flag,
          enable_automatic_tax_flag, consolidation_ledger_flag,
          translate_eod_flag, translate_qatd_flag,
          translate_yatd_flag, automatically_created_flag,
          alc_ledger_type_code, ledger_category_code,
          object_type_code, le_ledger_type_code,
          bal_seg_value_option_code, bal_seg_column_name,
          mgt_seg_value_option_code, mgt_seg_column_name,
          bal_seg_value_set_id, mgt_seg_value_set_id,
          implicit_access_set_id, future_enterable_periods_limit,
          ledger_attributes, enable_reconciliation_flag,
          last_update_date, last_updated_by, last_update_login,
          creation_date, created_by, description,
          context, attribute1, attribute2, attribute3,
          attribute4, attribute5, attribute6, attribute7,
          attribute8, attribute9, attribute10, attribute11,
          attribute12, attribute13, attribute14, attribute15,
          create_je_flag,net_closing_bal_flag,automate_sec_jrnl_rev_flag)--Added the net closing bal flag for bug 8612291
      VALUES
         (x_ledger_id, x_name, x_short_name, x_chart_of_accounts_id, 'X',
          x_period_set_name, x_accounted_period_type, 'X',
          -1, 'N', -- ret_earn_code_combination_id, suspense_allowed_flag
          'N','N', -- allow_intercompany_post_flag, track_rounding_imbalance_flag
          'N','N', -- enable_average_balances_flag, enable_budgetary_control_flag
          'N','N', -- require_budget_journals_flag, enable_je_approval_flag
          'N','N', -- enable_automatic_tax_flag, consolidation_ledger_flag
          'N','N', -- translate_eod_flag, translate_qatd_flag
          'N','N', -- translate_yatd_flag, automatically_created_flag
          'NONE','NONE', -- alc_ledger_type_code, ledger_category_code
          'S','U', -- object_type_code, le_ledger_type_code
          'I',     -- bal_seg_value_option_code
          l_bal_seg_column_name,
          'I',     -- mgt_seg_value_option_code
          l_mgt_seg_column_name,
          l_bal_seg_value_set_id, l_mgt_seg_value_set_id,
          l_access_set_id, 0, -- future_enterable_periods_limit
          'S', 'N', -- ledger_attributes, enable_reconciliation_flag
          x_date, x_user_id, x_login_id,
          x_date, x_user_id, x_description,
          x_context, x_attribute1, x_attribute2, x_attribute3,
          x_attribute4, x_attribute5, x_attribute6, x_attribute7,
          x_attribute8, x_attribute9, x_attribute10, x_attribute11,
          x_attribute12, x_attribute13, x_attribute14, x_attribute15,
          'N', -- enable_reconciliation_flag, create_je_flag
          'N','N');--Added the net closing bal flag for bug 8612291
   END insert_set;

-- *********************************************************************
   PROCEDURE update_set(
      x_ledger_id               NUMBER,
      x_name                    VARCHAR2,
      x_short_name              VARCHAR2,
      x_chart_of_accounts_id    NUMBER,
      x_period_set_name         VARCHAR2,
      x_accounted_period_type   VARCHAR2,
      x_default_ledger_id       NUMBER,
      x_date                    DATE,
      x_user_id                 NUMBER,
      x_login_id                NUMBER,
      x_description             VARCHAR2,
      x_context                 VARCHAR2,
      x_attribute1              VARCHAR2,
      x_attribute2              VARCHAR2,
      x_attribute3              VARCHAR2,
      x_attribute4              VARCHAR2,
      x_attribute5              VARCHAR2,
      x_attribute6              VARCHAR2,
      x_attribute7              VARCHAR2,
      x_attribute8              VARCHAR2,
      x_attribute9              VARCHAR2,
      x_attribute10             VARCHAR2,
      x_attribute11             VARCHAR2,
      x_attribute12             VARCHAR2,
      x_attribute13             VARCHAR2,
      x_attribute14             VARCHAR2,
      x_attribute15             VARCHAR2) IS
      l_access_set_id   NUMBER(15);
   BEGIN
      UPDATE GL_LEDGERS
      SET    name                  = x_name,
             short_name            = x_short_name,
             chart_of_accounts_id  = x_chart_of_accounts_id,
             period_set_name       = x_period_set_name,
             accounted_period_type = x_accounted_period_type,
             last_update_date      = x_date,
             last_updated_by       = x_user_id,
             last_update_login     = x_login_id,
             description           = x_description,
             context               = x_context,
             attribute1            = x_attribute1,
             attribute2            = x_attribute2,
             attribute3            = x_attribute3,
             attribute4            = x_attribute4,
             attribute5            = x_attribute5,
             attribute6            = x_attribute6,
             attribute7            = x_attribute7,
             attribute8            = x_attribute8,
             attribute9            = x_attribute9,
             attribute10           = x_attribute10,
             attribute11           = x_attribute11,
             attribute12           = x_attribute12,
             attribute13           = x_attribute13,
             attribute14           = x_attribute14,
             attribute15           = x_attribute15
      WHERE  ledger_id = x_ledger_id
      RETURNING implicit_access_set_id INTO l_access_set_id;

      -- Make sure we have the implicit access set id
      IF (SQL%NOTFOUND) THEN
         RAISE NO_DATA_FOUND;
      END IF;

      -- Update the implicit access set name to the same as the ledger set
      GL_ACCESS_SETS_PKG.update_implicit_access_set
                                  (x_access_set_id     => l_access_set_id,
                                   x_name              => x_name,
                                   x_last_update_date  => x_date,
                                   x_last_updated_by   => x_user_id,
                                   x_last_update_login => x_login_id);

      -- Only when updating ledger sets could the default ledger be changed
      UPDATE GL_ACCESS_SETS
      SET    default_ledger_id = x_default_ledger_id
      WHERE  access_set_id = l_access_set_id;
   END update_set;

-- ********************************************************************
  PROCEDURE remove_lgr_bsv_for_le(x_le_id NUMBER) IS

  CURSOR PLSLLEDGER IS
  select distinct cg1.object_id ledger_id,cg1.object_type_code
  from gl_ledger_config_details cg1, gl_ledger_config_details cg2
  where cg2.object_id = x_le_id
  and cg1.configuration_id = cg2.configuration_id
  and cg1.object_type_code in ('PRIMARY','SECONDARY');

  BSVCount NUMBER := 0;

   BEGIN

-- Bug 8265487 Added code to delete corresponding data from
-- GL_LEGAL_ENTITIES_BSVS and update GL_LEDGERS
-- accordingly for BAL_SEG_VALUE_OPTION_CODE

       delete from gl_legal_entities_bsvs
       where legal_entity_id = x_le_id;

       delete from gl_ledger_norm_seg_vals
       where  legal_entity_id = x_le_id
       and    segment_type_code = 'B'
       and    segment_value_type_code = 'S';

--     We need to take care of BAL_SEG_VALUE_OPTION_CODE in GL_LEDGERS

       for PLSL in PLSLLEDGER
       loop

	       BSVCount := 0;
	       select count(*) into BSVCount from
	       gl_ledger_norm_seg_vals where ledger_id = PLSL.ledger_id;

	       if BSVCount = 0 then
	       update gl_ledgers
	       set bal_seg_value_option_code = 'A'
	       where ledger_id = PLSL.ledger_id;

	       update gl_ledgers
	       set bal_seg_value_option_code = 'A'
               where ledger_id in
               (
                 select distinct target_ledger_id from gl_ledger_relationships
                 where  source_ledger_id = PLSL.ledger_id
                 and target_ledger_category_code = 'ALC'
                 and relationship_type_code not in('NONE','BALANCE')
	       );
	       end if;
       end loop;


    END remove_lgr_bsv_for_le;

-- *********************************************************************
  PROCEDURE process_le_bsv_assign(x_le_id NUMBER,
                                   x_value_set_id NUMBER,
                                   x_bsv_value VARCHAR2,
                                   x_operation VARCHAR2,
                                   x_start_date DATE DEFAULT null,
                                   x_end_date DATE DEFAULT null) IS
     l_rowid VARCHAR2(30);
     l_ledger_id NUMBER;
     l_config_id NUMBER;
     l_record_id NUMBER;
     l_completion_status VARCHAR2(30);
     l_has_le_bsv VARCHAR2(30);
     CURSOR get_ledger_id IS
        select l.ledger_id, cd2.configuration_id
        from gl_ledgers l, gl_le_value_sets lv,
             gl_ledger_config_details cd1, gl_ledger_config_details cd2
        where lv.legal_entity_id = x_le_id
        and lv.flex_value_set_id = x_value_set_id
        and cd1.object_id = lv.legal_entity_id
        and cd1.object_type_code = 'LEGAL_ENTITY'
        and cd1.setup_step_code = 'NONE'
        and cd2.configuration_id = cd1.configuration_id
        and cd2.object_type_code in ('PRIMARY', 'SECONDARY')
        and cd2.setup_step_code = 'NONE'
        and l.bal_seg_value_set_id = lv.flex_value_set_id
        and l.ledger_id = cd2.object_id;
     CURSOR get_record_id(c_ledger_id NUMBER) IS
        select rowid
        from gl_ledger_norm_seg_vals
        where ledger_id = c_ledger_id
        and segment_type_code = 'B'
        and segment_value = x_bsv_value
        and segment_value_type_code = 'S'
        FOR UPDATE NOWAIT;
     CURSOR get_le_BSV (c_ledger_id NUMBER)IS
       SELECT 'has_le_bsv'
       FROM   GL_LEDGER_NORM_SEG_VALS
       WHERE  ledger_id = c_ledger_id
       AND    legal_entity_id IS NOT NULL
       AND    segment_type_code = 'B'
       AND    segment_value_type_code = 'S'
       AND    rownum<2;
     CURSOR get_complete_status IS
        select completion_status_code
        from gl_ledger_configurations
        where configuration_id =
                (select configuration_id
                 from gl_ledger_config_details
                 where object_id = x_le_id
                 and object_type_code = 'LEGAL_ENTITY');
   BEGIN
     OPEN get_complete_status;
     FETCH get_complete_status INTO l_completion_status;

     OPEN get_ledger_id;
     LOOP
     FETCH get_ledger_id INTO l_ledger_id, l_config_id;
     EXIT WHEN get_ledger_id%NOTFOUND;
        OPEN get_record_id(l_ledger_id);
        FETCH get_record_id INTO l_rowid;
        IF(get_record_id%NOTFOUND AND x_operation = 'I') THEN
            GL_LEDGER_NORM_SEG_VALS_PKG.Insert_Row(
              X_Rowid                   => l_rowid,
              X_Ledger_Id               => l_ledger_id,
              X_Segment_Type_Code       => 'B',
              X_Segment_Value           =>  x_bsv_value,
              X_Segment_Value_Type_Code => 'S',
              X_Record_Id               => GL_LEDGER_NORM_SEG_VALS_PKG.Get_Record_Id,
              X_Last_Update_Date        => sysdate,
              X_Last_Updated_By         => fnd_global.user_id,
              X_Creation_Date           => sysdate,
              X_Created_By              => fnd_global.user_id,
              X_Last_Update_Login       => fnd_global.login_id,
              X_Start_Date              => x_start_date,
              X_End_Date                => x_end_date,
              X_Context                 => null,
              X_Attribute1              => null,
              X_Attribute2              => null,
              X_Attribute3              => null,
              X_Attribute4              => null,
              X_Attribute5              => null,
              X_Attribute6              => null,
              X_Attribute7              => null,
              X_Attribute8              => null,
              X_Attribute9              => null,
              X_Attribute10             => null,
              X_Attribute11             => null,
              X_Attribute12             => null,
              X_Attribute13             => null,
              X_Attribute14             => null,
              X_Attribute15             => null,
              X_Request_Id              => null);
            update gl_ledger_norm_seg_vals
            set legal_entity_id = x_le_id,
                last_update_date = sysdate,
                last_updated_by = fnd_global.user_id,
                last_update_login = fnd_global.login_id
            where ledger_id = l_ledger_id
            and segment_type_code = 'B'
            and segment_value = x_bsv_value
            and segment_value_type_code = 'S';
            insert into  gl_ledger_config_details
              (configuration_id,
               object_type_code,
               object_id,
               object_name,
               setup_step_code,
               next_action_code,
               status_code,
               created_by,
               last_update_login,
               last_update_date,
               last_updated_by,
               creation_date)
             select
               configuration_id,
               object_type_code,
               object_id,
               object_name,
               'INTER_ASSG',
               'ASSIGN_ACCTS',
               'NOT_STARTED',
               fnd_global.user_id,
               fnd_global.login_id,
               sysdate,
               fnd_global.user_id,
               sysdate
              from gl_ledger_config_details
              where object_id = l_ledger_id
              and object_type_code <> 'LEGAL_ENTITY'
              and setup_step_code = 'NONE'
              and configuration_id = l_config_id
              and NOT EXISTS(select 1
                            from gl_ledger_config_details
                            where object_id = l_ledger_id
                            and object_type_code <> 'LEGAL_ENTITY'
                            and setup_step_code = 'INTER_ASSG');
            update gl_ledgers
            set bal_seg_value_option_code = 'I'
            where ledger_id = l_ledger_id
            and bal_seg_value_option_code = 'A';
            update gl_ledgers
            set bal_seg_value_option_code = 'I'
            where ledger_id in
            (select target_ledger_id
             from gl_ledger_relationships
             where source_ledger_id = l_ledger_id
             and   target_ledger_category_code = 'ALC'
             and   relationship_type_code in ('JOURNAL','SUBLEDGER') )
            and bal_seg_value_option_code = 'A';
        ELSIF(x_operation = 'D') THEN
            IF(l_completion_status <> 'CONFIRMED') THEN
                delete from gl_ledger_norm_seg_vals
                where rowid = l_rowid;
                OPEN get_le_BSV(l_ledger_id);
                FETCH get_le_BSV
                INTO l_has_le_bsv;

                IF (get_le_BSV%NOTFOUND) THEN
                  delete gl_ledger_norm_seg_vals
                  where  ledger_id = l_ledger_id
                  and    segment_type_code = 'B'
                  and    segment_value_type_code = 'S';

                  update gl_ledgers
                  set    bal_seg_value_option_code = 'A'
                  where  ledger_id = l_ledger_id
                  and    bal_seg_value_option_code = 'I';

                  update gl_ledgers
                  set    bal_seg_value_option_code = 'A'
                  where  ledger_id in
                 (select target_ledger_id
                  from gl_ledger_relationships
                  where source_ledger_id = l_ledger_id
                  and   target_ledger_category_code = 'ALC'
                  and   relationship_type_code in ('JOURNAL','SUBLEDGER') )
                  and   bal_seg_value_option_code = 'I';
                END IF;
                CLOSE get_le_BSV;
            ELSE
                GL_LEDGER_NORM_SEG_VALS_PKG.Delete_Row(
                    X_Rowid   => l_rowid);
            END IF;
        ELSIF(x_operation = 'U')THEN
            IF(l_completion_status <> 'CONFIRMED') THEN
                update gl_ledger_norm_seg_vals
                set start_date = x_start_date,
                    end_date = x_end_date,
                    last_update_date = sysdate,
                    last_updated_by = fnd_global.user_id,
                    last_update_login = fnd_global.login_id
                where rowid = l_rowid;
            ELSE
                update gl_ledger_norm_seg_vals
                set start_date = x_start_date,
                    end_date = x_end_date,
                    status_code = decode(status_code, 'I', 'I', 'U'),
                    last_update_date = sysdate,
                    last_updated_by = fnd_global.user_id,
                    last_update_login = fnd_global.login_id
                where rowid = l_rowid;
            END IF;
        END IF;
        CLOSE get_record_id;
     END LOOP;
     CLOSE get_ledger_id;
   END process_le_bsv_assign;

-- *********************************************************************
   FUNCTION get_bsv_desc(x_object_type          VARCHAR2,
                         x_object_id            NUMBER,
                         x_bal_seg_value        VARCHAR2)
   RETURN VARCHAR2 IS
   l_table_name         VARCHAR2(30);
   l_value_col_name     VARCHAR2(30);
   l_meaning_col_name   VARCHAR2(30);
   l_enabled_col_name   VARCHAR2(30);
   l_start_date_col_name        VARCHAR2(30);
   l_end_date_col_name          VARCHAR2(30);
   l_where_clause       VARCHAR2(5000);
   sql_stmt             VARCHAR2(10000);
   l_bal_value_desc     VARCHAR2(240);
   l_flex_value_set_id  NUMBER(30);
   CURSOR tabval_value_set(c_flex_value_set_id NUMBER) IS
        select application_table_name, value_column_name,
        nvl(meaning_column_name, 'null'), enabled_column_name,
        start_date_column_name, end_date_column_name,
        additional_where_clause
        from fnd_flex_validation_tables
        where flex_value_set_id = c_flex_value_set_id;
   CURSOR ledger_bsv_value_set(c_ledger_id NUMBER) IS
        select BAL_SEG_VALUE_SET_ID
        from gl_ledgers
        where ledger_id = c_ledger_id;
   BEGIN
        IF(x_object_type = 'LGR') THEN
                OPEN ledger_bsv_value_set(x_object_id);
                FETCH ledger_bsv_value_set INTO l_flex_value_set_id;
                CLOSE ledger_bsv_value_set;
        ELSIF(x_object_type = 'LE') THEN
                l_flex_value_set_id := x_object_id;
        END IF;

        OPEN tabval_value_set(l_flex_value_set_id);
        FETCH tabval_value_set INTO l_table_name, l_value_col_name,
                        l_meaning_col_name, l_enabled_col_name,
                        l_start_date_col_name, l_end_date_col_name,
                        l_where_clause;
        IF(tabval_value_set%NOTFOUND)THEN
                return null;
        END IF;
        IF(lower(substr(l_where_clause, 1, 5)) = 'where')THEN
             l_where_clause := substr(l_where_clause, 6);
        END IF;
        sql_stmt := null;
        sql_stmt := 'select '||l_meaning_col_name||' from '||l_table_name||
                    ' where '||l_value_col_name||
                    ' = :1 and '||l_enabled_col_name||' =''Y'''
                    ||' and nvl('||l_start_date_col_name||',sysdate)<=sysdate'
                    ||' and nvl('||l_end_date_col_name||',sysdate)>=sysdate';
        IF(l_where_clause IS NOT null) THEN
             sql_stmt := sql_stmt||' and '||substrb(l_where_clause,instrb(l_where_clause, ' ')+1);
        END IF;
        EXECUTE IMMEDIATE sql_stmt INTO l_bal_value_desc USING x_bal_seg_value;
        RETURN l_bal_value_desc;
   END get_bsv_desc;

-- *********************************************************************
  PROCEDURE check_calendar_gap (
        x_period_set_name       IN              VARCHAR2,
        x_period_type           IN              VARCHAR2,
        x_gap_flag              OUT NOCOPY      VARCHAR2,
        x_start_date            OUT NOCOPY      DATE,
        x_end_date              OUT NOCOPY      DATE) IS
    not_assigned CONSTANT VARCHAR2(15) := 'NOT ASSIGNED';

    gap_date   DATE;
    start_date DATE;
    end_date   DATE;
    beginning  DATE;
    ending     DATE;

    CURSOR period_set IS
      SELECT min(start_date) begins, max(end_date) ends
      FROM gl_periods
      WHERE period_set_name = x_period_set_name
      AND   period_type     = x_period_type;

    CURSOR gap_exists IS
      SELECT accounting_date
      FROM gl_date_period_map
      WHERE period_name     = not_assigned
      AND   period_set_name = x_period_set_name
      AND   period_type     = x_period_type
      AND   accounting_date BETWEEN beginning AND ending;

    CURSOR gap_start IS
      SELECT max(accounting_date)
      FROM gl_date_period_map
      WHERE period_name    <> not_assigned
      AND   period_set_name = x_period_set_name
      AND   period_type     = x_period_type
      AND   accounting_date < gap_date;

    CURSOR gap_end IS
      SELECT min(accounting_date)
      FROM gl_date_period_map
      WHERE period_name    <> not_assigned
      AND   period_set_name = x_period_set_name
      AND   period_type     = x_period_type
      AND   accounting_date > gap_date;

  BEGIN
    -- Open the gap_exists cursor and see if we get anything
    OPEN period_set;
    FETCH period_set INTO beginning, ending;
    CLOSE period_set;
    OPEN gap_exists;
    FETCH gap_exists INTO gap_date;
    IF gap_exists%NOTFOUND THEN
      CLOSE gap_exists;
      x_gap_flag := 'N';
    ELSE
      CLOSE gap_exists;
      x_gap_flag := 'Y';
      -- Get the spanning dates
      OPEN gap_start;
      FETCH gap_start INTO start_date;
      CLOSE gap_start;
      OPEN gap_end;
      FETCH gap_end INTO end_date;
      CLOSE gap_end;
      x_start_date := nvl(start_date, beginning);
      x_end_date := nvl(end_date, ending);
      -- Tell the user
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'gl_period_statuses_pkg.check_for_gap');
      RAISE;
  END check_calendar_gap;

-- *********************************************************************

  PROCEDURE check_duplicate_ledger (
        x_object_name           IN              VARCHAR2,
        x_object_id             IN              NUMBER,
        x_dupl_flag             OUT NOCOPY      VARCHAR2) IS
  CURSOR get_duplicate IS
        select 'Duplicate'
        from   GL_LEDGERS LEDGERS
        where  LEDGERS.NAME = x_object_name
        and    LEDGERS.LEDGER_ID <> x_object_id
        UNION
        select 'Duplicate'
        from   GL_ACCESS_SETS ACCESS_SETS
        where  ACCESS_SETS.NAME = x_object_name
        and    ACCESS_SETS.AUTOMATICALLY_CREATED_FLAG <> 'Y'
        UNION
        select 'Duplicate'
        from GL_LEDGER_RELATIONSHIPS
        where target_ledger_category_code = 'ALC'
        and relationship_type_code = 'BALANCE'
        and target_ledger_name = x_object_name;
  test  VARCHAR2(20);
  BEGIN
        OPEN get_duplicate;
        FETCH get_duplicate INTO test;
        IF(get_duplicate%NOTFOUND) THEN
                x_dupl_flag := 'N';
        ELSE
                x_dupl_flag := 'Y';
        END IF;
  END check_duplicate_ledger;

  PROCEDURE check_dupl_ldg_shortname(
        x_ledger_short_name     IN              VARCHAR2,
        x_ledger_id             IN              NUMBER,
        x_dupl_flag             OUT NOCOPY      VARCHAR2) IS
  CURSOR get_duplicate IS
        select 'Duplicate'
        from   GL_LEDGERS GL_LEDGERS
        where  GL_LEDGERS.SHORT_NAME = x_ledger_short_name
        and    GL_LEDGERS.LEDGER_ID  <> x_ledger_id
        UNION
        select 'Duplicate'
        from GL_LEDGER_RELATIONSHIPS
        where target_ledger_category_code = 'ALC'
        and relationship_type_code = 'BALANCE'
        and target_ledger_short_name = x_ledger_short_name;
  test  VARCHAR2(20);
  BEGIN
        OPEN get_duplicate;
        FETCH get_duplicate INTO test;
        IF(get_duplicate%NOTFOUND) THEN
                x_dupl_flag := 'N';
        ELSE
                x_dupl_flag := 'Y';
        END IF;
  END check_dupl_ldg_shortname;

  PROCEDURE check_dupl_tgr_name (
        x_target_ledger_name    IN              VARCHAR2,
        x_relationship_id       IN              NUMBER,
        x_ledger_id             IN              NUMBER,
        x_dupl_flag             OUT NOCOPY      VARCHAR2) IS
  CURSOR get_duplicate IS
        SELECT 'Duplicate'
        FROM   gl_ledger_relationships
        WHERE  application_id = 101
          AND  target_ledger_name = x_target_ledger_name
          AND  relationship_type_code <> 'NONE'
          AND  relationship_id <> x_relationship_id
          AND  target_ledger_id <> x_ledger_id
        UNION
          SELECT name
          FROM   GL_LEDGERS
          WHERE  name            = x_target_ledger_name
          AND    ledger_id       <> NVL(x_ledger_id,-1)
        UNION
          SELECT 'Duplicate'
          FROM   GL_ACCESS_SETS a
          WHERE  a.name = x_target_ledger_name
          AND    a.automatically_created_flag <> 'Y';
  test  VARCHAR2(20);
  BEGIN
        OPEN get_duplicate;
        FETCH get_duplicate INTO test;
        IF(get_duplicate%NOTFOUND) THEN
                x_dupl_flag := 'N';
        ELSE
                x_dupl_flag := 'Y';
        END IF;
  END check_dupl_tgr_name;

  PROCEDURE check_dupl_tgr_shortname(
        x_ledger_short_name     IN              VARCHAR2,
        x_relationship_id       IN              NUMBER,
        x_ledger_id             IN              NUMBER,
        x_dupl_flag             OUT NOCOPY      VARCHAR2) IS
  CURSOR get_duplicate IS
        SELECT 'Duplicate'
        FROM   gl_ledger_relationships
        WHERE  application_id = 101
          AND  target_ledger_short_name = x_ledger_short_name
          AND  relationship_type_code <> 'NONE'
          AND  relationship_id <> x_relationship_id
          AND  target_ledger_id <> x_ledger_id
        UNION
          SELECT short_name
            FROM gl_ledgers
           WHERE short_name = x_ledger_short_name
             AND ledger_id <> NVL(x_ledger_id,-1);
  test  VARCHAR2(20);
  BEGIN
        OPEN get_duplicate;
        FETCH get_duplicate INTO test;
        IF(get_duplicate%NOTFOUND) THEN
                x_dupl_flag := 'N';
        ELSE
                x_dupl_flag := 'Y';
        END IF;
  END check_dupl_tgr_shortname;

  PROCEDURE set_status_complete(x_object_type   VARCHAR2,
                                x_object_id IN NUMBER) IS
  BEGIN
        IF(x_object_type = 'CONFIGURATION') THEN
                update gl_ledger_configurations
                set completion_status_code = 'CONFIRMED'
                where configuration_id = x_object_id;

                update gl_ledgers
                set complete_flag = 'Y'
                where configuration_id = x_object_id
                and ledger_category_code in ('PRIMARY', 'SECONDARY', 'ALC');
        ELSIF(x_object_type = 'LEDGER') THEN
                update gl_ledgers
                set complete_flag = 'Y'
                where ledger_id = x_object_id;
        END IF;
  END set_status_complete;

  PROCEDURE check_translation_performed(
        x_ledger_id                         NUMBER,
        x_run_flag      OUT NOCOPY      VARCHAR2) IS
   CURSOR check_translation IS
         SELECT 'translated'
         FROM DUAL
         WHERE EXISTS(
                SELECT 'X'
                FROM gl_translation_tracking
                WHERE ledger_id = x_ledger_id
                AND actual_flag = 'A'
                AND ((earliest_ever_period_year*10000)+earliest_ever_period_num) <
                    ((earliest_never_period_year*10000)+earliest_never_period_num));
      dummy   VARCHAR2(100);
   BEGIN
      OPEN check_translation;

      FETCH check_translation
       INTO dummy;

      IF check_translation%FOUND THEN
         CLOSE check_translation;
         x_run_flag :='Y';
      ELSE
         CLOSE check_translation;
         x_run_flag :='N';
      END IF;
   END check_translation_performed;

   PROCEDURE check_calendar_35max_days(x_ledger_id IN           NUMBER,
                                x_35day_flag    OUT NOCOPY      VARCHAR2) IS
     CURSOR check_calendar IS
        SELECT  max(pr.end_date - pr.start_date)+1
        FROM    GL_PERIODS pr, GL_PERIOD_TYPES pty
        WHERE   pr.period_type = pty.period_type
        AND    ((pr.period_set_name, pr.period_type)
               IN (SELECT period_set_name, accounted_period_type
                   FROM   gl_ledgers where ledger_id = x_ledger_id))
        GROUP BY pr.period_set_name, pty.user_period_type, pty.period_type
        HAVING (max(pr.end_date - pr.start_date)+1) >=35;

     dummy   VARCHAR2(100);
   BEGIN
      OPEN check_calendar;

      FETCH check_calendar
       INTO dummy;

      IF check_calendar%FOUND THEN
         CLOSE check_calendar;
         x_35day_flag :='Y';
      ELSE
         CLOSE check_calendar;
         x_35day_flag :='N';
      END IF;
   END check_calendar_35max_days;

  PROCEDURE check_desc_flex_setup(x_desc_flex_name IN VARCHAR2,
                                x_setup_flag    OUT NOCOPY      VARCHAR2) IS
  BEGIN
         IF (FND_FLEX_APIS.is_descr_setup(101,x_desc_flex_name)= FALSE) THEN
                x_setup_flag := 'N';
         ELSE
                x_setup_flag := 'Y';
         END IF;
  END check_desc_flex_setup;

  PROCEDURE remove_ou_setup(x_config_id IN NUMBER) IS
        CURSOR le_assigned IS
          SELECT object_id
          FROM gl_ledger_config_details
          WHERE configuration_id = x_config_id
          AND object_type_code = 'LEGAL_ENTITY';
        test    NUMBER;
  BEGIN
        OPEN le_assigned;
        FETCH le_assigned INTO test;
        IF(le_assigned%NOTFOUND) THEN
           delete from gl_ledger_config_details
           where configuration_id = x_config_id
           and object_type_code = 'PRIMARY'
           and setup_step_code = 'OU_SETUP';
        END IF;
  END remove_ou_setup;

  -- *********************************************************************
  FUNCTION get_short_name ( x_primary_ledger_short_name VARCHAR2,
			  x_suffix_length number)
						RETURN VARCHAR2 IS

	l_short_name VARCHAR2(100) := NULL;
	l_prefix_length NUMBER := 20 - x_suffix_length;

  BEGIN

  IF ((lengthb(x_primary_ledger_short_name) + x_suffix_length) >20) THEN

	FOR i IN REVERSE 1..l_prefix_length
	LOOP
		l_short_name := substr(x_primary_ledger_short_name,0,i);

		IF (lengthb(l_short_name) <= l_prefix_length) THEN

			return l_short_name;

		END IF;

	END LOOP;

   ELSE
        return x_primary_ledger_short_name;
   END IF;

  END get_short_name ;
-- ***********************************************************************
END gl_ledgers_pkg;

/
