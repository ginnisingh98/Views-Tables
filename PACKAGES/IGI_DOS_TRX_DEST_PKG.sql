--------------------------------------------------------
--  DDL for Package IGI_DOS_TRX_DEST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_DOS_TRX_DEST_PKG" AUTHID CURRENT_USER AS
/* $Header: igidosrs.pls 120.6.12000000.2 2007/06/14 05:13:46 pshivara ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_sob_id                            IN     NUMBER,
    x_trx_id                            IN     NUMBER,
    x_dest_trx_id                       IN OUT NOCOPY NUMBER,
    x_source_trx_id                     IN     NUMBER,
    x_source_id                         IN     NUMBER,
    x_destination_id                    IN     NUMBER,
    x_code_combination_id               IN     NUMBER,
    x_profile_code                      IN     VARCHAR2,
    x_budget_name                       IN     VARCHAR2,
    x_budget_entity_id                  IN     NUMBER,
    x_budget_amount                     IN     NUMBER,
    x_funds_available                   IN     NUMBER,
    x_new_balance                       IN     NUMBER,
    x_currency_code                     IN     VARCHAR2,
    x_visible_segments                  IN     VARCHAR2,
    x_actual_segments                   IN     VARCHAR2,
    x_m_budget_amount                 IN     NUMBER,
    x_m_budget_amt_exch_rate          IN     NUMBER,
    x_m_budget_amt_exch_rate_type     IN     VARCHAR2,
    x_m_budget_amt_exch_date          IN     DATE,
    x_m_budget_amt_exch_status        IN     VARCHAR2,
    x_m_funds_avail                   IN     NUMBER,
    x_m_funds_avail_exch_rate         IN     NUMBER,
    x_m_funds_avail_exch_rate_type    IN     VARCHAR2,
    x_m_funds_avail_exch_date         IN     DATE,
    x_m_funds_avail_exch_status       IN     VARCHAR2,
    x_m_new_balance                   IN     NUMBER,
    x_m_new_balance_exch_rate         IN     NUMBER,
    x_m_new_balance_exch_rate_type    IN     VARCHAR2,
    x_m_new_balance_exch_date         IN     DATE,
    x_m_new_balance_exch_status       IN     VARCHAR2,
    x_dossier_id                        IN     NUMBER,
    x_budget_version_id                 IN     NUMBER,
    x_period_name                       IN     VARCHAR2,
    x_percentage                        IN     NUMBER,
    x_status                            IN     VARCHAR2,
    x_group_id                          IN     NUMBER,
    x_quarter_num                       IN     NUMBER,
    x_period_year                       IN     NUMBER,
    x_period_num                        IN     NUMBER,
    x_line_num                          IN     NUMBER,
    x_segment1                          IN     VARCHAR2,
    x_segment2                          IN     VARCHAR2,
    x_segment3                          IN     VARCHAR2,
    x_segment4                          IN     VARCHAR2,
    x_segment5                          IN     VARCHAR2,
    x_segment6                          IN     VARCHAR2,
    x_segment7                          IN     VARCHAR2,
    x_segment8                          IN     VARCHAR2,
    x_segment9                          IN     VARCHAR2,
    x_segment10                         IN     VARCHAR2,
    x_segment11                         IN     VARCHAR2,
    x_segment12                         IN     VARCHAR2,
    x_segment13                         IN     VARCHAR2,
    x_segment14                         IN     VARCHAR2,
    x_segment15                         IN     VARCHAR2,
    x_segment16                         IN     VARCHAR2,
    x_segment17                         IN     VARCHAR2,
    x_segment18                         IN     VARCHAR2,
    x_segment19                         IN     VARCHAR2,
    x_segment20                         IN     VARCHAR2,
    x_segment21                         IN     VARCHAR2,
    x_segment22                         IN     VARCHAR2,
    x_segment23                         IN     VARCHAR2,
    x_segment24                         IN     VARCHAR2,
    x_segment25                         IN     VARCHAR2,
    x_segment26                         IN     VARCHAR2,
    x_segment27                         IN     VARCHAR2,
    x_segment28                         IN     VARCHAR2,
    x_segment29                         IN     VARCHAR2,
    x_segment30                         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_sob_id                            IN     NUMBER,
    x_trx_id                            IN     NUMBER,
    x_dest_trx_id                       IN     NUMBER,
    x_source_trx_id                     IN     NUMBER,
    x_source_id                         IN     NUMBER,
    x_destination_id                    IN     NUMBER,
    x_code_combination_id               IN     NUMBER,
    x_profile_code                      IN     VARCHAR2,
    x_budget_name                       IN     VARCHAR2,
    x_budget_entity_id                  IN     NUMBER,
    x_budget_amount                     IN     NUMBER,
    x_funds_available                   IN     NUMBER,
    x_new_balance                       IN     NUMBER,
    x_currency_code                     IN     VARCHAR2,
    x_visible_segments                  IN     VARCHAR2,
    x_actual_segments                   IN     VARCHAR2,
    x_m_budget_amount                 IN     NUMBER,
    x_m_budget_amt_exch_rate          IN     NUMBER,
    x_m_budget_amt_exch_rate_type     IN     VARCHAR2,
    x_m_budget_amt_exch_date          IN     DATE,
    x_m_budget_amt_exch_status        IN     VARCHAR2,
    x_m_funds_avail                   IN     NUMBER,
    x_m_funds_avail_exch_rate         IN     NUMBER,
    x_m_funds_avail_exch_rate_type    IN     VARCHAR2,
    x_m_funds_avail_exch_date         IN     DATE,
    x_m_funds_avail_exch_status       IN     VARCHAR2,
    x_m_new_balance                   IN     NUMBER,
    x_m_new_balance_exch_rate         IN     NUMBER,
    x_m_new_balance_exch_rate_type    IN     VARCHAR2,
    x_m_new_balance_exch_date         IN     DATE,
    x_m_new_balance_exch_status       IN     VARCHAR2,
    x_dossier_id                        IN     NUMBER,
    x_budget_version_id                 IN     NUMBER,
    x_period_name                       IN     VARCHAR2,
    x_percentage                        IN     NUMBER,
    x_status                            IN     VARCHAR2,
    x_group_id                          IN     NUMBER,
    x_quarter_num                       IN     NUMBER,
    x_period_year                       IN     NUMBER,
    x_period_num                        IN     NUMBER,
    x_line_num                          IN     NUMBER,
    x_segment1                          IN     VARCHAR2,
    x_segment2                          IN     VARCHAR2,
    x_segment3                          IN     VARCHAR2,
    x_segment4                          IN     VARCHAR2,
    x_segment5                          IN     VARCHAR2,
    x_segment6                          IN     VARCHAR2,
    x_segment7                          IN     VARCHAR2,
    x_segment8                          IN     VARCHAR2,
    x_segment9                          IN     VARCHAR2,
    x_segment10                         IN     VARCHAR2,
    x_segment11                         IN     VARCHAR2,
    x_segment12                         IN     VARCHAR2,
    x_segment13                         IN     VARCHAR2,
    x_segment14                         IN     VARCHAR2,
    x_segment15                         IN     VARCHAR2,
    x_segment16                         IN     VARCHAR2,
    x_segment17                         IN     VARCHAR2,
    x_segment18                         IN     VARCHAR2,
    x_segment19                         IN     VARCHAR2,
    x_segment20                         IN     VARCHAR2,
    x_segment21                         IN     VARCHAR2,
    x_segment22                         IN     VARCHAR2,
    x_segment23                         IN     VARCHAR2,
    x_segment24                         IN     VARCHAR2,
    x_segment25                         IN     VARCHAR2,
    x_segment26                         IN     VARCHAR2,
    x_segment27                         IN     VARCHAR2,
    x_segment28                         IN     VARCHAR2,
    x_segment29                         IN     VARCHAR2,
    x_segment30                         IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_sob_id                            IN     NUMBER,
    x_trx_id                            IN     NUMBER,
    x_dest_trx_id                       IN     NUMBER,
    x_source_trx_id                     IN     NUMBER,
    x_source_id                         IN     NUMBER,
    x_destination_id                    IN     NUMBER,
    x_code_combination_id               IN     NUMBER,
    x_profile_code                      IN     VARCHAR2,
    x_budget_name                       IN     VARCHAR2,
    x_budget_entity_id                  IN     NUMBER,
    x_budget_amount                     IN     NUMBER,
    x_funds_available                   IN     NUMBER,
    x_new_balance                       IN     NUMBER,
    x_currency_code                     IN     VARCHAR2,
    x_visible_segments                  IN     VARCHAR2,
    x_actual_segments                   IN     VARCHAR2,
    x_m_budget_amount                 IN     NUMBER,
    x_m_budget_amt_exch_rate          IN     NUMBER,
    x_m_budget_amt_exch_rate_type     IN     VARCHAR2,
    x_m_budget_amt_exch_date          IN     DATE,
    x_m_budget_amt_exch_status        IN     VARCHAR2,
    x_m_funds_avail                   IN     NUMBER,
    x_m_funds_avail_exch_rate         IN     NUMBER,
    x_m_funds_avail_exch_rate_type    IN     VARCHAR2,
    x_m_funds_avail_exch_date         IN     DATE,
    x_m_funds_avail_exch_status       IN     VARCHAR2,
    x_m_new_balance                   IN     NUMBER,
    x_m_new_balance_exch_rate         IN     NUMBER,
    x_m_new_balance_exch_rate_type    IN     VARCHAR2,
    x_m_new_balance_exch_date         IN     DATE,
    x_m_new_balance_exch_status       IN     VARCHAR2,
    x_dossier_id                        IN     NUMBER,
    x_budget_version_id                 IN     NUMBER,
    x_period_name                       IN     VARCHAR2,
    x_percentage                        IN     NUMBER,
    x_status                            IN     VARCHAR2,
    x_group_id                          IN     NUMBER,
    x_quarter_num                       IN     NUMBER,
    x_period_year                       IN     NUMBER,
    x_period_num                        IN     NUMBER,
    x_line_num                          IN     NUMBER,
    x_segment1                          IN     VARCHAR2,
    x_segment2                          IN     VARCHAR2,
    x_segment3                          IN     VARCHAR2,
    x_segment4                          IN     VARCHAR2,
    x_segment5                          IN     VARCHAR2,
    x_segment6                          IN     VARCHAR2,
    x_segment7                          IN     VARCHAR2,
    x_segment8                          IN     VARCHAR2,
    x_segment9                          IN     VARCHAR2,
    x_segment10                         IN     VARCHAR2,
    x_segment11                         IN     VARCHAR2,
    x_segment12                         IN     VARCHAR2,
    x_segment13                         IN     VARCHAR2,
    x_segment14                         IN     VARCHAR2,
    x_segment15                         IN     VARCHAR2,
    x_segment16                         IN     VARCHAR2,
    x_segment17                         IN     VARCHAR2,
    x_segment18                         IN     VARCHAR2,
    x_segment19                         IN     VARCHAR2,
    x_segment20                         IN     VARCHAR2,
    x_segment21                         IN     VARCHAR2,
    x_segment22                         IN     VARCHAR2,
    x_segment23                         IN     VARCHAR2,
    x_segment24                         IN     VARCHAR2,
    x_segment25                         IN     VARCHAR2,
    x_segment26                         IN     VARCHAR2,
    x_segment27                         IN     VARCHAR2,
    x_segment28                         IN     VARCHAR2,
    x_segment29                         IN     VARCHAR2,
    x_segment30                         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_sob_id                            IN     NUMBER,
    x_trx_id                            IN     NUMBER,
    x_dest_trx_id                       IN OUT NOCOPY NUMBER,
    x_source_trx_id                     IN     NUMBER,
    x_source_id                         IN     NUMBER,
    x_destination_id                    IN     NUMBER,
    x_code_combination_id               IN     NUMBER,
    x_profile_code                      IN     VARCHAR2,
    x_budget_name                       IN     VARCHAR2,
    x_budget_entity_id                  IN     NUMBER,
    x_budget_amount                     IN     NUMBER,
    x_funds_available                   IN     NUMBER,
    x_new_balance                       IN     NUMBER,
    x_currency_code                     IN     VARCHAR2,
    x_visible_segments                  IN     VARCHAR2,
    x_actual_segments                   IN     VARCHAR2,
    x_m_budget_amount                 IN     NUMBER,
    x_m_budget_amt_exch_rate          IN     NUMBER,
    x_m_budget_amt_exch_rate_type     IN     VARCHAR2,
    x_m_budget_amt_exch_date          IN     DATE,
    x_m_budget_amt_exch_status        IN     VARCHAR2,
    x_m_funds_avail                   IN     NUMBER,
    x_m_funds_avail_exch_rate         IN     NUMBER,
    x_m_funds_avail_exch_rate_type    IN     VARCHAR2,
    x_m_funds_avail_exch_date         IN     DATE,
    x_m_funds_avail_exch_status       IN     VARCHAR2,
    x_m_new_balance                   IN     NUMBER,
    x_m_new_balance_exch_rate         IN     NUMBER,
    x_m_new_balance_exch_rate_type    IN     VARCHAR2,
    x_m_new_balance_exch_date         IN     DATE,
    x_m_new_balance_exch_status       IN     VARCHAR2,
    x_dossier_id                        IN     NUMBER,
    x_budget_version_id                 IN     NUMBER,
    x_period_name                       IN     VARCHAR2,
    x_percentage                        IN     NUMBER,
    x_status                            IN     VARCHAR2,
    x_group_id                          IN     NUMBER,
    x_quarter_num                       IN     NUMBER,
    x_period_year                       IN     NUMBER,
    x_period_num                        IN     NUMBER,
    x_line_num                          IN     NUMBER,
    x_segment1                          IN     VARCHAR2,
    x_segment2                          IN     VARCHAR2,
    x_segment3                          IN     VARCHAR2,
    x_segment4                          IN     VARCHAR2,
    x_segment5                          IN     VARCHAR2,
    x_segment6                          IN     VARCHAR2,
    x_segment7                          IN     VARCHAR2,
    x_segment8                          IN     VARCHAR2,
    x_segment9                          IN     VARCHAR2,
    x_segment10                         IN     VARCHAR2,
    x_segment11                         IN     VARCHAR2,
    x_segment12                         IN     VARCHAR2,
    x_segment13                         IN     VARCHAR2,
    x_segment14                         IN     VARCHAR2,
    x_segment15                         IN     VARCHAR2,
    x_segment16                         IN     VARCHAR2,
    x_segment17                         IN     VARCHAR2,
    x_segment18                         IN     VARCHAR2,
    x_segment19                         IN     VARCHAR2,
    x_segment20                         IN     VARCHAR2,
    x_segment21                         IN     VARCHAR2,
    x_segment22                         IN     VARCHAR2,
    x_segment23                         IN     VARCHAR2,
    x_segment24                         IN     VARCHAR2,
    x_segment25                         IN     VARCHAR2,
    x_segment26                         IN     VARCHAR2,
    x_segment27                         IN     VARCHAR2,
    x_segment28                         IN     VARCHAR2,
    x_segment29                         IN     VARCHAR2,
    x_segment30                         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_dest_trx_id                       IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igi_dos_trx_sources (
    x_source_trx_id                     IN     NUMBER
  );

  PROCEDURE get_fk_igi_dos_trx_headers (
    x_trx_id                            IN     NUMBER
  );

  PROCEDURE get_fk_igi_dos_doc_types (
    x_dossier_id                        IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_sob_id                            IN     NUMBER,
    x_trx_id                            IN     NUMBER,
    x_dest_trx_id                       IN     NUMBER,
    x_source_trx_id                     IN     NUMBER,
    x_source_id                         IN     NUMBER,
    x_destination_id                    IN     NUMBER,
    x_code_combination_id               IN     NUMBER,
    x_profile_code                      IN     VARCHAR2,
    x_budget_name                       IN     VARCHAR2,
    x_budget_entity_id                  IN     NUMBER,
    x_budget_amount                     IN     NUMBER,
    x_funds_available                   IN     NUMBER,
    x_new_balance                       IN     NUMBER,
    x_currency_code                     IN     VARCHAR2,
    x_visible_segments                  IN     VARCHAR2,
    x_actual_segments                   IN     VARCHAR2,
    x_m_budget_amount                 IN     NUMBER,
    x_m_budget_amt_exch_rate          IN     NUMBER,
    x_m_budget_amt_exch_rate_type     IN     VARCHAR2,
    x_m_budget_amt_exch_date          IN     DATE,
    x_m_budget_amt_exch_status        IN     VARCHAR2,
    x_m_funds_avail                   IN     NUMBER,
    x_m_funds_avail_exch_rate         IN     NUMBER,
    x_m_funds_avail_exch_rate_type    IN     VARCHAR2,
    x_m_funds_avail_exch_date         IN     DATE,
    x_m_funds_avail_exch_status       IN     VARCHAR2,
    x_m_new_balance                   IN     NUMBER,
    x_m_new_balance_exch_rate         IN     NUMBER,
    x_m_new_balance_exch_rate_type    IN     VARCHAR2,
    x_m_new_balance_exch_date         IN     DATE,
    x_m_new_balance_exch_status       IN     VARCHAR2,
    x_dossier_id                        IN     NUMBER,
    x_budget_version_id                 IN     NUMBER,
    x_period_name                       IN     VARCHAR2,
    x_percentage                        IN     NUMBER,
    x_status                            IN     VARCHAR2,
    x_group_id                          IN     NUMBER,
    x_quarter_num                       IN     NUMBER,
    x_period_year                       IN     NUMBER,
    x_period_num                        IN     NUMBER,
    x_line_num                          IN     NUMBER,
    x_segment1                          IN     VARCHAR2,
    x_segment2                          IN     VARCHAR2,
    x_segment3                          IN     VARCHAR2,
    x_segment4                          IN     VARCHAR2,
    x_segment5                          IN     VARCHAR2,
    x_segment6                          IN     VARCHAR2,
    x_segment7                          IN     VARCHAR2,
    x_segment8                          IN     VARCHAR2,
    x_segment9                          IN     VARCHAR2,
    x_segment10                         IN     VARCHAR2,
    x_segment11                         IN     VARCHAR2,
    x_segment12                         IN     VARCHAR2,
    x_segment13                         IN     VARCHAR2,
    x_segment14                         IN     VARCHAR2,
    x_segment15                         IN     VARCHAR2,
    x_segment16                         IN     VARCHAR2,
    x_segment17                         IN     VARCHAR2,
    x_segment18                         IN     VARCHAR2,
    x_segment19                         IN     VARCHAR2,
    x_segment20                         IN     VARCHAR2,
    x_segment21                         IN     VARCHAR2,
    x_segment22                         IN     VARCHAR2,
    x_segment23                         IN     VARCHAR2,
    x_segment24                         IN     VARCHAR2,
    x_segment25                         IN     VARCHAR2,
    x_segment26                         IN     VARCHAR2,
    x_segment27                         IN     VARCHAR2,
    x_segment28                         IN     VARCHAR2,
    x_segment29                         IN     VARCHAR2,
    x_segment30                         IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  );

END igi_dos_trx_dest_pkg;

 

/
