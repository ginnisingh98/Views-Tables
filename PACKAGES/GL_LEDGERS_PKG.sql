--------------------------------------------------------
--  DDL for Package GL_LEDGERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_LEDGERS_PKG" AUTHID CURRENT_USER AS
   /* $Header: glistlds.pls 120.37.12010000.4 2010/03/31 13:37:40 bsrikant ship $ */

-- **********************************************************************

   --
   -- Procedure
   --   complete_config
   -- Purpose
   --   Called from OA FWK ledger configuration page to submit concurrent program
   -- History
   --   June 26, 2003    Alan Wen   Copied from temporary pkg gl_ledger_pkg1
   -- Arguments
   --   X_CONFIG_ID configuration ID
   -- Example
   --
   -- Notes
   --

   FUNCTION complete_config(x_config_id NUMBER)
      RETURN VARCHAR2;
   --
   -- Procedure
   --   insert_row
   -- Purpose
   --   Called from OA FWK ledger page to create ledger
   -- History
   --   June 26, 2003    Alan Wen   Copied from temporary pkg gl_ledger_pkg1
   --   July 09, 2003    Alan Wen   Applied OA FWKstandard for handling PL/SQL errors
   --
   -- Arguments
   --
   -- Example
   --
   -- Notes
   --   This procedure overload the update_row in this package.
   --   After the Ledger Form is remvoed, the other one will be removed


   PROCEDURE insert_row(
      p_api_version                    IN              NUMBER := 1.0,
      p_init_msg_list                  IN              VARCHAR2
            := fnd_api.g_false,
      p_commit                         IN              VARCHAR2
            := fnd_api.g_false,
      p_validate_only                  IN              VARCHAR2
            := fnd_api.g_true,
      p_record_version_number          IN              NUMBER := NULL,
      x_return_status                  OUT NOCOPY      VARCHAR2,
      x_msg_count                      OUT NOCOPY      NUMBER,
      x_msg_data                       OUT NOCOPY      VARCHAR2,
      x_rowid                          IN OUT NOCOPY   VARCHAR2,
      x_ledger_id                                      NUMBER,
      x_name                                           VARCHAR2,
      x_short_name                                     VARCHAR2,
      x_chart_of_accounts_id                           NUMBER,
      x_currency_code                                  VARCHAR2,
      x_period_set_name                                VARCHAR2,
      x_accounted_period_type                          VARCHAR2,
      x_first_ledger_period_name                       VARCHAR2,
      x_ret_earn_code_combination_id                   NUMBER,
      x_suspense_allowed_flag                          VARCHAR2,
      x_suspense_ccid                                  NUMBER,
      x_allow_intercompany_post_flag                   VARCHAR2,
      x_enable_avgbal_flag                             VARCHAR2,
      x_enable_budgetary_control_f                     VARCHAR2,
      x_require_budget_journals_flag                   VARCHAR2,
      x_enable_je_approval_flag                        VARCHAR2,
      x_enable_automatic_tax_flag                      VARCHAR2,
      x_consolidation_ledger_flag                      VARCHAR2,
      x_translate_eod_flag                             VARCHAR2,
      x_translate_qatd_flag                            VARCHAR2,
      x_translate_yatd_flag                            VARCHAR2,
      x_automatically_created_flag                     VARCHAR2,
      x_track_rounding_imbalance_f                     VARCHAR2,
--      x_mrc_ledger_type_code                           VARCHAR2,
      x_le_ledger_type_code                            VARCHAR2,
      x_bal_seg_value_option_code                      VARCHAR2,
      x_mgt_seg_value_option_code                      VARCHAR2,
      x_last_update_date                               DATE,
      x_last_updated_by                                NUMBER,
      x_creation_date                                  DATE,
      x_created_by                                     NUMBER,
      x_last_update_login                              NUMBER,
      x_description                                    VARCHAR2,
      x_future_enterable_periods_lmt                   NUMBER,
      x_latest_opened_period_name                      VARCHAR2,
      x_latest_encumbrance_year                        NUMBER,
      x_cum_trans_ccid                                 NUMBER,
      x_res_encumb_ccid                                NUMBER,
      x_net_income_ccid                                NUMBER,
      x_balancing_segment                              VARCHAR2,
      x_rounding_ccid                                  NUMBER,
      x_transaction_calendar_id                        NUMBER,
      x_daily_translation_rate_type                    VARCHAR2,
      x_period_average_rate_type                       VARCHAR2,
      x_period_end_rate_type                           VARCHAR2,
      x_context                                        VARCHAR2,
      x_attribute1                                     VARCHAR2,
      x_attribute2                                     VARCHAR2,
      x_attribute3                                     VARCHAR2,
      x_attribute4                                     VARCHAR2,
      x_attribute5                                     VARCHAR2,
      x_attribute6                                     VARCHAR2,
      x_attribute7                                     VARCHAR2,
      x_attribute8                                     VARCHAR2,
      x_attribute9                                     VARCHAR2,
      x_attribute10                                    VARCHAR2,
      x_attribute11                                    VARCHAR2,
      x_attribute12                                    VARCHAR2,
      x_attribute13                                    VARCHAR2,
      x_attribute14                                    VARCHAR2,
      x_attribute15                                    VARCHAR2,
      x_set_manual_flag                                VARCHAR2,
      --x_child_ledger_access_code          VARCHAR2,
      x_ledger_category_code                           VARCHAR2,
      x_configuration_id                               NUMBER,
      x_sla_accounting_method_code                     VARCHAR2,
      x_sla_accounting_method_type                     VARCHAR2,
      x_sla_description_language                       VARCHAR2,
      x_sla_entered_cur_bal_sus_ccid                   NUMBER,
      x_sla_bal_by_ledger_curr_flag                    VARCHAR2,
      x_sla_ledger_cur_bal_sus_ccid                    NUMBER,
      x_alc_ledger_type_code                           VARCHAR2,
      x_criteria_set_id                                NUMBER,
      x_enable_secondary_track_flag                    VARCHAR2 DEFAULT 'N',
      x_enable_reval_ss_track_flag                     VARCHAR2 DEFAULT 'N',
      x_enable_reconciliation_flag                     VARCHAR2 DEFAULT 'N',
      x_sla_ledger_cash_basis_flag                     VARCHAR2 DEFAULT 'N',
      x_create_je_flag                                 VARCHAR2 DEFAULT 'Y',
      x_commitment_budget_flag                         VARCHAR2 DEFAULT NULL,
      x_net_closing_bal_flag                           VARCHAR2 DEFAULT 'N',
      x_auto_jrnl_rev_flag                             VARCHAR2 DEFAULT 'N');

-- *********************************************************************

   --
   -- Procedure
   --   update_row
   -- Purpose
   --   Called from OA FWK ledger page to update ledger definition
   -- History
   --   June 26, 2003    Alan Wen   Copied from temporary pkg gl_ledger_pkg1
   --   July 09, 2003    Alan Wen   Applied OA FWKstandard for handling PL/SQL errors
   --
   -- Arguments
   --
   -- Example
   --
   -- Notes
   --   This procedure overload the update_row in this package.
   --   After the Ledger Form is remvoed, the other one will be removed

   PROCEDURE update_row(
      p_api_version                    IN              NUMBER := 1.0,
      p_init_msg_list                  IN              VARCHAR2
            := fnd_api.g_false,
      p_commit                         IN              VARCHAR2
            := fnd_api.g_false,
      p_validate_only                  IN              VARCHAR2
            := fnd_api.g_true,
      p_record_version_number          IN              NUMBER := NULL,
      x_return_status                  OUT NOCOPY      VARCHAR2,
      x_msg_count                      OUT NOCOPY      NUMBER,
      x_msg_data                       OUT NOCOPY      VARCHAR2,
      x_rowid                                          VARCHAR2,
      x_ledger_id                                      NUMBER,
      x_name                                           VARCHAR2,
      x_short_name                                     VARCHAR2,
      x_chart_of_accounts_id                           NUMBER,
      x_currency_code                                  VARCHAR2,
      x_period_set_name                                VARCHAR2,
      x_accounted_period_type                          VARCHAR2,
      x_first_ledger_period_name                       VARCHAR2,
      x_ret_earn_code_combination_id                   NUMBER,
      x_suspense_allowed_flag                          VARCHAR2,
      x_suspense_ccid                                  NUMBER,
      x_allow_intercompany_post_flag                   VARCHAR2,
      x_enable_avgbal_flag                             VARCHAR2,
      x_enable_budgetary_control_f                     VARCHAR2,
      x_require_budget_journals_flag                   VARCHAR2,
      x_enable_je_approval_flag                        VARCHAR2,
      x_enable_automatic_tax_flag                      VARCHAR2,
      x_consolidation_ledger_flag                      VARCHAR2,
      x_translate_eod_flag                             VARCHAR2,
      x_translate_qatd_flag                            VARCHAR2,
      x_translate_yatd_flag                            VARCHAR2,
      x_automatically_created_flag                     VARCHAR2,
      x_track_rounding_imbalance_f                     VARCHAR2,
--      x_mrc_ledger_type_code                           VARCHAR2,
      x_le_ledger_type_code                            VARCHAR2,
      x_bal_seg_value_option_code                      VARCHAR2,
      --      x_bal_seg_column_name               VARCHAR2,
      --      x_bal_seg_value_set_id              NUMBER,
      x_mgt_seg_value_option_code                      VARCHAR2,
      --      x_mgt_seg_column_name               VARCHAR2,
      --      x_mgt_seg_value_set_id              NUMBER,
      x_implicit_access_set_id                         NUMBER,
      x_last_update_date                               DATE,
      x_last_updated_by                                NUMBER,
      x_last_update_login                              NUMBER,
      x_description                                    VARCHAR2,
      x_future_enterable_periods_lmt                   NUMBER,
      x_latest_opened_period_name                      VARCHAR2,
      x_latest_encumbrance_year                        NUMBER,
      x_cum_trans_ccid                                 NUMBER,
      x_res_encumb_ccid                                NUMBER,
      x_net_income_ccid                                NUMBER,
      x_balancing_segment                              VARCHAR2,
      x_rounding_ccid                                  NUMBER,
      x_transaction_calendar_id                        NUMBER,
      x_daily_translation_rate_type                    VARCHAR2,
      x_period_average_rate_type                       VARCHAR2,
      x_period_end_rate_type                           VARCHAR2,
      x_context                                        VARCHAR2,
      x_attribute1                                     VARCHAR2,
      x_attribute2                                     VARCHAR2,
      x_attribute3                                     VARCHAR2,
      x_attribute4                                     VARCHAR2,
      x_attribute5                                     VARCHAR2,
      x_attribute6                                     VARCHAR2,
      x_attribute7                                     VARCHAR2,
      x_attribute8                                     VARCHAR2,
      x_attribute9                                     VARCHAR2,
      x_attribute10                                    VARCHAR2,
      x_attribute11                                    VARCHAR2,
      x_attribute12                                    VARCHAR2,
      x_attribute13                                    VARCHAR2,
      x_attribute14                                    VARCHAR2,
      x_attribute15                                    VARCHAR2,
      x_set_manual_flag                                VARCHAR2,
      --x_child_ledger_access_code          VARCHAR2,
      x_ledger_category_code                           VARCHAR2,
      x_configuration_id                               NUMBER,
      x_sla_accounting_method_code                     VARCHAR2,
      x_sla_accounting_method_type                     VARCHAR2,
      x_sla_description_language                       VARCHAR2,
      x_sla_entered_cur_bal_sus_ccid                   NUMBER,
      x_sla_bal_by_ledger_curr_flag                    VARCHAR2,
      x_sla_ledger_cur_bal_sus_ccid                    NUMBER,
      x_alc_ledger_type_code                           VARCHAR2,
      x_criteria_set_id                                NUMBER,
      x_enable_secondary_track_flag                    VARCHAR2 DEFAULT 'N',
      x_enable_reval_ss_track_flag                     VARCHAR2 DEFAULT 'N',
      x_enable_reconciliation_flag                     VARCHAR2 DEFAULT 'N',
      x_sla_ledger_cash_basis_flag                     VARCHAR2 DEFAULT 'N',
      x_create_je_flag                                 VARCHAR2 DEFAULT 'Y',
      x_commitment_budget_flag                         VARCHAR2 DEFAULT NULL,
      x_net_closing_bal_flag                           VARCHAR2 DEFAULT 'N',
      x_auto_jrnl_rev_flag                             VARCHAR2 DEFAULT 'N');
   --
   -- Procedure
   --   check_unique_name
   -- Purpose
   --   Ensure new ledger name is unique among ledgers, ledger sets, and
   --   access sets.
   -- History
   --   02/08/01    O Monnier      Created
   -- Arguments
   --   x_rowid    The ID of the row to be checked
   --   x_name     The category name to be checked
   -- Example
   --   GL_LEDGERS_PKG.check_unique_name( '12345', 'LEDGER 1' );
   -- Notes
   --
   PROCEDURE check_unique_name(x_rowid VARCHAR2, x_name VARCHAR2);
   --
   -- Procedure
   --   check_unique_short_name
   -- Purpose
   --   Ensure new ledger short name is unique among ledgers and ledger sets.
   -- History
   --   02/08/01    O Monnier      Created
   -- Arguments
   --   x_rowid          The ID of the row to be checked
   --   x_short_name     The short name to be checked
   -- Example
   --   GL_LEDGERS_PKG.check_unique_short_name( '12345', 'LEDGER 1' );
   -- Notes
   --
   PROCEDURE check_unique_short_name(x_rowid VARCHAR2, x_short_name VARCHAR2);
   --
   -- Procedure
   --   get_unique_id
   -- Purpose
   --   Gets a new sequence unique id for a new ledger.
   -- History
   --   02/08/01    O Monnier      Created from old sets of books package.
   -- Arguments
   --   none
   -- Example
   --   :ledger.ledger_id := GL_LEDGERS_PKG.get_unique_id;
   -- Notes
   --
   FUNCTION get_unique_id
      RETURN NUMBER;
   --
   -- Procedure
   --   is_coa_frozen
   -- Purpose
   --   Test if the Chart of Accounts selected is frozen.
   -- History
   --   02/08/01    O Monnier      Created
   -- Arguments
   --   X_Chart_Of_Accounts_Id          Key Flexfield Structure Num
   -- Example
   --   test := GL_LEDGERS_PKG.is_coa_frozen ( 101 );
   -- Notes
   --
   FUNCTION is_coa_frozen(x_chart_of_accounts_id NUMBER)
      RETURN BOOLEAN;
   --
   -- Procedure
   --   get_bal_mgt_seg_info
   -- Purpose
   --   Gets the balancing segment column name, value set id,
   --   the management segment column name, and value set id for the Chart of Accounts.
   -- History
   --   02/08/01    O Monnier      Created
   -- Arguments
   --   X_Bal_Seg_Column_Name           Retrieve the balancing segment column name
   --   X_Bal_Seg_Value_Set_Id          Retrieve the balancing segment value set id
   --   X_Mgt_Seg_Column_Name           Retrieve the balancing segment column name
   --   X_Mgt_Seg_Value_Set_Id          Retrieve the balancing segment value set id
   --   X_Chart_Of_Accounts_Id          Key Flexfield Structure Num
   -- Example
   --   GL_LEDGERS_PKG.get_bal_seg_info(X_Bal_Seg_Column_Name,
   --                                   X_Bal_Seg_Value_Set_Id,
   --                                   X_Mgt_Seg_Column_Name,
   --                                   X_Mgt_Seg_Value_Set_Id,
   --                                   1);
   -- Notes
   --
   PROCEDURE get_bal_mgt_seg_info(
      x_bal_seg_column_name    OUT NOCOPY   VARCHAR2,
      x_bal_seg_value_set_id   OUT NOCOPY   NUMBER,
      x_mgt_seg_column_name    OUT NOCOPY   VARCHAR2,
      x_mgt_seg_value_set_id   OUT NOCOPY   NUMBER,
      x_chart_of_accounts_id                NUMBER);

-- *********************************************************************
-- The following procedures are necessary to handle the base view form.

   PROCEDURE insert_row(
      x_rowid                          IN OUT NOCOPY   VARCHAR2,
      x_ledger_id                                      NUMBER,
      x_name                                           VARCHAR2,
      x_short_name                                     VARCHAR2,
      x_chart_of_accounts_id                           NUMBER,
      x_chart_of_accounts_name                         VARCHAR2,
      x_currency_code                                  VARCHAR2,
      x_period_set_name                                VARCHAR2,
      x_user_period_type                               VARCHAR2,
      x_accounted_period_type                          VARCHAR2,
      x_first_ledger_period_name                       VARCHAR2,
      x_ret_earn_code_combination_id                   NUMBER,
      x_suspense_allowed_flag                          VARCHAR2,
      x_suspense_ccid                                  NUMBER,
      x_allow_intercompany_post_flag                   VARCHAR2,
      x_enable_avgbal_flag                             VARCHAR2,
      x_enable_budgetary_control_f                     VARCHAR2,
      x_require_budget_journals_flag                   VARCHAR2,
      x_enable_je_approval_flag                        VARCHAR2,
      x_enable_automatic_tax_flag                      VARCHAR2,
      x_consolidation_ledger_flag                      VARCHAR2,
      x_translate_eod_flag                             VARCHAR2,
      x_translate_qatd_flag                            VARCHAR2,
      x_translate_yatd_flag                            VARCHAR2,
      x_automatically_created_flag                     VARCHAR2,
      x_track_rounding_imbalance_f                     VARCHAR2,
      x_alc_ledger_type_code                           VARCHAR2,
      x_le_ledger_type_code                            VARCHAR2,
      x_bal_seg_value_option_code                      VARCHAR2,
      x_bal_seg_column_name                            VARCHAR2,
      x_bal_seg_value_set_id                           NUMBER,
      x_mgt_seg_value_option_code                      VARCHAR2,
      x_mgt_seg_column_name                            VARCHAR2,
      x_mgt_seg_value_set_id                           NUMBER,
      x_last_update_date                               DATE,
      x_last_updated_by                                NUMBER,
      x_creation_date                                  DATE,
      x_created_by                                     NUMBER,
      x_last_update_login                              NUMBER,
      x_description                                    VARCHAR2,
      x_future_enterable_periods_lmt                   NUMBER,
      x_latest_opened_period_name                      VARCHAR2,
      x_latest_encumbrance_year                        NUMBER,
      x_cum_trans_ccid                                 NUMBER,
      x_res_encumb_ccid                                NUMBER,
      x_net_income_ccid                                NUMBER,
      x_balancing_segment                              VARCHAR2,
      x_rounding_ccid                                  NUMBER,
      x_transaction_calendar_id                        NUMBER,
      x_transaction_calendar_name                      VARCHAR2,
      x_daily_translation_rate_type                    VARCHAR2,
      x_daily_user_translation_type                    VARCHAR2,
      x_period_average_rate_type                       VARCHAR2,
      x_period_avg_user_rate_type                      VARCHAR2,
      x_period_end_rate_type                           VARCHAR2,
      x_period_end_user_rate_type                      VARCHAR2,
      x_context                                        VARCHAR2,
      x_attribute1                                     VARCHAR2,
      x_attribute2                                     VARCHAR2,
      x_attribute3                                     VARCHAR2,
      x_attribute4                                     VARCHAR2,
      x_attribute5                                     VARCHAR2,
      x_attribute6                                     VARCHAR2,
      x_attribute7                                     VARCHAR2,
      x_attribute8                                     VARCHAR2,
      x_attribute9                                     VARCHAR2,
      x_attribute10                                    VARCHAR2,
      x_attribute11                                    VARCHAR2,
      x_attribute12                                    VARCHAR2,
      x_attribute13                                    VARCHAR2,
      x_attribute14                                    VARCHAR2,
      x_attribute15                                    VARCHAR2,
      x_set_manual_flag                                VARCHAR2);

   PROCEDURE lock_row(
      x_rowid                          VARCHAR2,
      x_ledger_id                      NUMBER,
      x_name                           VARCHAR2,
      x_short_name                     VARCHAR2,
      x_chart_of_accounts_id           NUMBER,
      x_chart_of_accounts_name         VARCHAR2,
      x_currency_code                  VARCHAR2,
      x_period_set_name                VARCHAR2,
      x_user_period_type               VARCHAR2,
      x_accounted_period_type          VARCHAR2,
      x_first_ledger_period_name       VARCHAR2,
      x_ret_earn_code_combination_id   NUMBER,
      x_suspense_allowed_flag          VARCHAR2,
      x_suspense_ccid                  NUMBER,
      x_allow_intercompany_post_flag   VARCHAR2,
      x_enable_avgbal_flag             VARCHAR2,
      x_enable_budgetary_control_f     VARCHAR2,
      x_require_budget_journals_flag   VARCHAR2,
      x_enable_je_approval_flag        VARCHAR2,
      x_enable_automatic_tax_flag      VARCHAR2,
      x_consolidation_ledger_flag      VARCHAR2,
      x_translate_eod_flag             VARCHAR2,
      x_translate_qatd_flag            VARCHAR2,
      x_translate_yatd_flag            VARCHAR2,
      x_automatically_created_flag     VARCHAR2,
      x_track_rounding_imbalance_f     VARCHAR2,
      x_alc_ledger_type_code           VARCHAR2,
      x_le_ledger_type_code            VARCHAR2,
      x_bal_seg_value_option_code      VARCHAR2,
      x_bal_seg_column_name            VARCHAR2,
      x_bal_seg_value_set_id           NUMBER,
      x_mgt_seg_value_option_code      VARCHAR2,
      x_mgt_seg_column_name            VARCHAR2,
      x_mgt_seg_value_set_id           NUMBER,
      x_description                    VARCHAR2,
      x_future_enterable_periods_lmt   NUMBER,
      x_latest_opened_period_name      VARCHAR2,
      x_latest_encumbrance_year        NUMBER,
      x_cum_trans_ccid                 NUMBER,
      x_res_encumb_ccid                NUMBER,
      x_net_income_ccid                NUMBER,
      x_balancing_segment              VARCHAR2,
      x_rounding_ccid                  NUMBER,
      x_transaction_calendar_id        NUMBER,
      x_transaction_calendar_name      VARCHAR2,
      x_daily_translation_rate_type    VARCHAR2,
      x_daily_user_translation_type    VARCHAR2,
      x_period_average_rate_type       VARCHAR2,
      x_period_avg_user_rate_type      VARCHAR2,
      x_period_end_rate_type           VARCHAR2,
      x_period_end_user_rate_type      VARCHAR2,
      x_context                        VARCHAR2,
      x_attribute1                     VARCHAR2,
      x_attribute2                     VARCHAR2,
      x_attribute3                     VARCHAR2,
      x_attribute4                     VARCHAR2,
      x_attribute5                     VARCHAR2,
      x_attribute6                     VARCHAR2,
      x_attribute7                     VARCHAR2,
      x_attribute8                     VARCHAR2,
      x_attribute9                     VARCHAR2,
      x_attribute10                    VARCHAR2,
      x_attribute11                    VARCHAR2,
      x_attribute12                    VARCHAR2,
      x_attribute13                    VARCHAR2,
      x_attribute14                    VARCHAR2,
      x_attribute15                    VARCHAR2);

   PROCEDURE update_row(
      x_rowid                          VARCHAR2,
      x_ledger_id                      NUMBER,
      x_name                           VARCHAR2,
      x_short_name                     VARCHAR2,
      x_chart_of_accounts_id           NUMBER,
      x_chart_of_accounts_name         VARCHAR2,
      x_currency_code                  VARCHAR2,
      x_period_set_name                VARCHAR2,
      x_user_period_type               VARCHAR2,
      x_accounted_period_type          VARCHAR2,
      x_first_ledger_period_name       VARCHAR2,
      x_ret_earn_code_combination_id   NUMBER,
      x_suspense_allowed_flag          VARCHAR2,
      x_suspense_ccid                  NUMBER,
      x_allow_intercompany_post_flag   VARCHAR2,
      x_enable_avgbal_flag             VARCHAR2,
      x_enable_budgetary_control_f     VARCHAR2,
      x_require_budget_journals_flag   VARCHAR2,
      x_enable_je_approval_flag        VARCHAR2,
      x_enable_automatic_tax_flag      VARCHAR2,
      x_consolidation_ledger_flag      VARCHAR2,
      x_translate_eod_flag             VARCHAR2,
      x_translate_qatd_flag            VARCHAR2,
      x_translate_yatd_flag            VARCHAR2,
      x_automatically_created_flag     VARCHAR2,
      x_track_rounding_imbalance_f     VARCHAR2,
      x_alc_ledger_type_code           VARCHAR2,
      x_le_ledger_type_code            VARCHAR2,
      x_bal_seg_value_option_code      VARCHAR2,
      x_bal_seg_column_name            VARCHAR2,
      x_bal_seg_value_set_id           NUMBER,
      x_mgt_seg_value_option_code      VARCHAR2,
      x_mgt_seg_column_name            VARCHAR2,
      x_mgt_seg_value_set_id           NUMBER,
      x_implicit_access_set_id         NUMBER,
      x_last_update_date               DATE,
      x_last_updated_by                NUMBER,
      x_last_update_login              NUMBER,
      x_description                    VARCHAR2,
      x_future_enterable_periods_lmt   NUMBER,
      x_latest_opened_period_name      VARCHAR2,
      x_latest_encumbrance_year        NUMBER,
      x_cum_trans_ccid                 NUMBER,
      x_res_encumb_ccid                NUMBER,
      x_net_income_ccid                NUMBER,
      x_balancing_segment              VARCHAR2,
      x_rounding_ccid                  NUMBER,
      x_transaction_calendar_id        NUMBER,
      x_transaction_calendar_name      VARCHAR2,
      x_daily_translation_rate_type    VARCHAR2,
      x_daily_user_translation_type    VARCHAR2,
      x_period_average_rate_type       VARCHAR2,
      x_period_avg_user_rate_type      VARCHAR2,
      x_period_end_rate_type           VARCHAR2,
      x_period_end_user_rate_type      VARCHAR2,
      x_context                        VARCHAR2,
      x_attribute1                     VARCHAR2,
      x_attribute2                     VARCHAR2,
      x_attribute3                     VARCHAR2,
      x_attribute4                     VARCHAR2,
      x_attribute5                     VARCHAR2,
      x_attribute6                     VARCHAR2,
      x_attribute7                     VARCHAR2,
      x_attribute8                     VARCHAR2,
      x_attribute9                     VARCHAR2,
      x_attribute10                    VARCHAR2,
      x_attribute11                    VARCHAR2,
      x_attribute12                    VARCHAR2,
      x_attribute13                    VARCHAR2,
      x_attribute14                    VARCHAR2,
      x_attribute15                    VARCHAR2,
      x_set_manual_flag                VARCHAR2);

-- *********************************************************************

   --
   -- Procedure
   --   select_row
   -- Purpose
   --   select a row
   -- History
   --   02/08/01    O Monnier      Created from old sets of books package.
   -- Arguments
   --   recinfo    record information
   -- Example
   --   select_row(recinfo);
   -- Notes
   --
   PROCEDURE select_row(recinfo IN OUT NOCOPY gl_ledgers%ROWTYPE);
   --
   -- Procedure
   --   select_column
   -- Purpose
   --   get ledger_name from a row for populating non-database fields
   --
   -- History
   --   02/08/01    O Monnier      Created from old sets of books package.
   -- Arguments
   --   ledger_id          ledger id
   --   name               ledger name
   -- Example
   --   select_column(:block.ledger_id,:block.ledger_name);
   -- Notes
   --
   PROCEDURE select_columns(x_ledger_id NUMBER, x_name IN OUT NOCOPY VARCHAR2);
   -- Procedure
   --  update_gl_system_usages
   -- Purpose
   --  update the average_balances_flag to 'Y' if average balance processing
   --  is enabled for at least one ledger.
   -- History
   --  02/08/01    O Monnier      Created from old sets of books package.
   -- Arguments
   --  cons_lgr_flag      Consolidation Ledger Flag
   PROCEDURE update_gl_system_usages(cons_lgr_flag VARCHAR2);
   -- Procedure
   --  insert_gl_net_income_accounts
   -- Purpose
   --  insert into gl_net_income_accounts table
   -- History
   --  02/08/01    O Monnier      Created from old sets of books package.
   -- Arguments
   --
   PROCEDURE insert_gl_net_income_accounts(
      x_ledger_id                NUMBER,
      x_balancing_segment        VARCHAR2,
      x_net_income_ccid          NUMBER,
      x_creation_date            DATE,
      x_created_by               NUMBER,
      x_last_update_date         DATE,
      x_last_updated_by          NUMBER,
      x_last_update_login        NUMBER,
      x_request_id               NUMBER,
      x_program_application_id   NUMBER,
      x_program_id               NUMBER,
      x_program_update_date      DATE);
   -- Procedure
   --  led_update_other_tables
   -- Purpose
   --  update the other tables related to the ledger.
   -- History
   --  02/08/01    O Monnier      Created from old sets of books package.
   -- Arguments
   --
   PROCEDURE led_update_other_tables(
      x_ledger_id          NUMBER,
      x_last_update_date   DATE,
      x_last_updated_by    NUMBER,
      x_suspense_ccid      NUMBER);
   -- Procedure
   --  Check_Avg_Translation
   -- Purpose
   --  check the translation status for average balances.
   -- History
   --  02/08/01    O Monnier      Created from old sets of books package.
   -- Arguments
   --
   FUNCTION check_avg_translation(x_ledger_id NUMBER)
      RETURN BOOLEAN;
   -- Procedure
   --  enable_manual_je_approval
   -- Purpose
   --  Update the journal_approval_flag to 'Y' for 'Manual' source.
   -- History
   --  02/08/01    O Monnier      Created from old sets of books package.
   -- Arguments
   --  none
   PROCEDURE enable_manual_je_approval;

-- *********************************************************************
-- The following 3 procedures are necessary to handle the Ledger Sets form.
-- Will be removed after the form is removed.

   PROCEDURE insert_set(
      x_rowid                   IN OUT NOCOPY   VARCHAR2,
      x_access_set_id           IN OUT NOCOPY   NUMBER,
      x_ledger_id                               NUMBER,
      x_name                                    VARCHAR2,
      x_short_name                              VARCHAR2,
      x_chart_of_accounts_id                    NUMBER,
      x_period_set_name                         VARCHAR2,
      x_accounted_period_type                   VARCHAR2,
      x_default_ledger_id                       NUMBER,
      x_last_update_date                        DATE,
      x_last_updated_by                         NUMBER,
      x_creation_date                           DATE,
      x_created_by                              NUMBER,
      x_last_update_login                       NUMBER,
      x_description                             VARCHAR2,
      x_context                                 VARCHAR2,
      x_attribute1                              VARCHAR2,
      x_attribute2                              VARCHAR2,
      x_attribute3                              VARCHAR2,
      x_attribute4                              VARCHAR2,
      x_attribute5                              VARCHAR2,
      x_attribute6                              VARCHAR2,
      x_attribute7                              VARCHAR2,
      x_attribute8                              VARCHAR2,
      x_attribute9                              VARCHAR2,
      x_attribute10                             VARCHAR2,
      x_attribute11                             VARCHAR2,
      x_attribute12                             VARCHAR2,
      x_attribute13                             VARCHAR2,
      x_attribute14                             VARCHAR2,
      x_attribute15                             VARCHAR2);

   PROCEDURE lock_set(
      x_rowid                   VARCHAR2,
      x_ledger_id               NUMBER,
      x_name                    VARCHAR2,
      x_short_name              VARCHAR2,
      x_chart_of_accounts_id    NUMBER,
      x_period_set_name         VARCHAR2,
      x_accounted_period_type   VARCHAR2,
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
      x_attribute15             VARCHAR2);

   PROCEDURE update_set(
      x_rowid                   VARCHAR2,
      x_access_set_id           NUMBER,
      x_ledger_id               NUMBER,
      x_name                    VARCHAR2,
      x_short_name              VARCHAR2,
      x_chart_of_accounts_id    NUMBER,
      x_period_set_name         VARCHAR2,
      x_accounted_period_type   VARCHAR2,
      x_default_ledger_id       NUMBER,
      x_last_update_date        DATE,
      x_last_updated_by         NUMBER,
      x_last_update_login       NUMBER,
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
      x_attribute15             VARCHAR2);

-- *********************************************************************
-- The following procedures are necessary to handle the default ledger
-- for a ledger set.

   FUNCTION maintain_def_ledger_assign(
      x_ledger_set_id     NUMBER,
      x_default_ledger_id NUMBER) RETURN BOOLEAN;

-- *********************************************************************
-- Procedure
--  Get_CCID
-- Purpose
--  Create or retrieve the code combination given the concatenated segments.
--  Called by iSpeed API.
-- History
--  11-MAY-04  C Ma       Copied from 11i.
-- Arguments
--
PROCEDURE Get_CCID(Y_Chart_Of_Accounts_Id    NUMBER,
                   Y_Concat_Segments         VARCHAR2,
                   Y_Account_Code            VARCHAR2,
                   Y_Average_Balances_Flag   VARCHAR2,
                   Y_User_Id                 NUMBER,
                   Y_Resp_Id                 NUMBER,
                   Y_Resp_Appl_Id            NUMBER,
                   Y_CCID                OUT NOCOPY NUMBER
                   );

-- *********************************************************************
-- The following 2 procedures are for the Ledger Set iSetup API.

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
      x_attribute15             VARCHAR2);

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
      x_attribute15             VARCHAR2);

 -- *********************************************************************
   --
   -- Procedure
   --   remove_lgr_bsv_for_le
   -- Purpose
   --   remove ledger bsv if a le with bsv has been deleted.
   -- History
   --   01/13/06        Jen Wu        Created
   -- Arguments
   --   x_le_id         legal entity id
   -- Example
   --   GL_LEDGERS_PKG.remove_lgr_bsv_for_le(1);
   -- Notes
   --

   PROCEDURE remove_lgr_bsv_for_le(x_le_id NUMBER);
 -- *********************************************************************
   --
   -- Procedure
   --   process_le_bsv_assign
   -- Purpose
   --   Propogate the legal entity BSV assignments to ledgers.
   -- History
   --   21/01/05    C Ma              Created
   -- Arguments
   --   x_le_id         legal entity id
   -- Example
   --   GL_LEDGERS_PKG.process_le_bsv_assign(1, 1, '01','I',null,null);
   -- Notes
   --
   PROCEDURE process_le_bsv_assign(x_le_id NUMBER,
                                   x_value_set_id NUMBER,
                                   x_bsv_value VARCHAR2,
                                   x_operation VARCHAR2,
                                   x_start_date DATE DEFAULT null,
                                   x_end_date DATE   DEFAULT null);

-- *********************************************************************
   --
   -- Procedure
   --   get_bsv_desc
   -- Purpose
   --   Get the segment value description.
   -- History
   --   04/06/05    C Ma              Created
   -- Arguments
   --   x_flex_value_set_id
   --   x_bal_seg_value
   -- Example
   --   GL_LEDGERS_PKG.get_bsv_desc(1002472, '01');
   -- Notes
   --
   FUNCTION get_bsv_desc( x_object_type         VARCHAR2,
                          x_object_id           NUMBER,
                          x_bal_seg_value       VARCHAR2)
   RETURN VARCHAR2;

-- *********************************************************************
   --
   -- Procedure
   --   check_calendar_gap
   -- Purpose
   --   Check whether there is a gap in the calendar periods. This is copied
   --   over from check_for_gap procedure in gl_period_statuses_pkg. This one
   --   is only called from the Accounting Setup Manager in OA.
   -- History
   --   04/28/05    C Ma              Created
   -- Arguments
   --   x_period_set_name
   --   x_period_type
   -- Example
   --   GL_LEDGERS_PKG.check_calendar_gap('Accounting', 'Month',
   --                           x_gap_flag, x_start_date, x_end_date);
   -- Notes
   --
  PROCEDURE check_calendar_gap (
        x_period_set_name       IN              VARCHAR2,
        x_period_type           IN              VARCHAR2,
        x_gap_flag              OUT NOCOPY      VARCHAR2,
        x_start_date            OUT NOCOPY      DATE,
        x_end_date              OUT NOCOPY      DATE);

-- *********************************************************************
   --
   -- Procedure
   --   check_duplicate_ledger
   -- Purpose
   --   Check whether there is a gap in the calendar periods. This is copied
   --   over from check_for_gap procedure in gl_period_statuses_pkg. This one
   --   is only called from the Accounting Setup Manager in OA.
   -- History
   --   04/28/05    C Ma              Created
   -- Arguments
   --   x_period_set_name
   --   x_period_type
   -- Example
   --   GL_LEDGERS_PKG.check_duplicate_ledger('Accounting', 1,
   --                           x_dupl_flag);
   -- Notes
   --
  PROCEDURE check_duplicate_ledger (
        x_object_name           IN              VARCHAR2,
        x_object_id             IN              NUMBER,
        x_dupl_flag             OUT NOCOPY      VARCHAR2);

  PROCEDURE check_dupl_ldg_shortname(
        x_ledger_short_name     IN              VARCHAR2,
        x_ledger_id             IN              NUMBER,
        x_dupl_flag             OUT NOCOPY      VARCHAR2);

  PROCEDURE check_dupl_tgr_name (
        x_target_ledger_name    IN              VARCHAR2,
        x_relationship_id       IN              NUMBER,
        x_ledger_id             IN              NUMBER,
        x_dupl_flag             OUT NOCOPY      VARCHAR2);

  PROCEDURE check_dupl_tgr_shortname(
        x_ledger_short_name     IN              VARCHAR2,
        x_relationship_id       IN              NUMBER,
        x_ledger_id             IN              NUMBER,
        x_dupl_flag             OUT NOCOPY      VARCHAR2);

  PROCEDURE set_status_complete(x_object_type   VARCHAR2,
                                x_object_id IN NUMBER);


  PROCEDURE check_translation_performed(x_ledger_id IN          NUMBER,
                                x_run_flag      OUT NOCOPY      VARCHAR2);

  PROCEDURE check_calendar_35max_days(x_ledger_id IN            NUMBER,
                                x_35day_flag OUT NOCOPY VARCHAR2);

  PROCEDURE check_desc_flex_setup(x_desc_flex_name IN VARCHAR2,
                                x_setup_flag OUT NOCOPY VARCHAR2);
  PROCEDURE remove_ou_setup(x_config_id IN NUMBER);
-- *********************************************************************

  FUNCTION get_short_name ( x_primary_ledger_short_name VARCHAR2,
			  x_suffix_length number)
						RETURN VARCHAR2;
-- *********************************************************************
END gl_ledgers_pkg;

/
