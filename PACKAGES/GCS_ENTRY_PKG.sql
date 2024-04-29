--------------------------------------------------------
--  DDL for Package GCS_ENTRY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_ENTRY_PKG" AUTHID CURRENT_USER AS
  /* $Header: gcsentrys.pls 120.7 2007/10/09 07:18:19 smatam ship $ */
  --
  -- Procedure
  --   upload_entry_headers
  -- Purpose
  --   An API to handle entry headers upload from Web ADI
  -- Arguments
  -- Notes
  --
  PROCEDURE upload_entry_headers(p_entry_id_char       IN OUT NOCOPY VARCHAR2,
                                 p_end_cal_period_id   IN VARCHAR2,
                                 p_hierarchy_id        IN NUMBER,
                                 p_entity_id           IN VARCHAR2,
                                 p_start_cal_period_id IN VARCHAR2,
                                 p_currency_code       IN VARCHAR2,
                                 p_process_code        IN VARCHAR2,
                                 p_description         IN VARCHAR2,
                                 p_entry_name          IN VARCHAR2,
                                 p_category_code       IN VARCHAR2,
                                 p_balance_type_code   IN VARCHAR2,
                                 p_writeback_needed    IN VARCHAR2,
                                 p_ledger_id           IN VARCHAR2,
                                 p_cal_period_name     IN VARCHAR2,
                                 p_conversion_type     IN VARCHAR2,
                                 p_hierarchy_grp_flag  IN VARCHAR2);

  --
  -- Procedure
  --   Manual_Entries_Import
  -- Purpose
  --   An API to import entry from Web ADI
  -- Arguments
  -- Notes
  --
  PROCEDURE manual_entries_import(p_entry_id_char       IN VARCHAR2,
                                  p_end_cal_period_id   IN VARCHAR2,
                                  p_hierarchy_id        IN NUMBER,
                                  p_entity_id_char      IN VARCHAR2,
                                  p_start_cal_period_id IN VARCHAR2,
                                  p_currency_code       IN VARCHAR2,
                                  p_process_code        IN VARCHAR2,
                                  p_description         IN VARCHAR2,
                                  p_entry_name          IN VARCHAR2,
                                  p_category_code       IN VARCHAR2,
                                  p_balance_type_code   IN VARCHAR2,
                                  p_writeback_needed    IN VARCHAR2,
                                  p_ledger_id           IN VARCHAR2,
                                  p_cal_period_name     IN VARCHAR2,
                                  p_conversion_type     IN VARCHAR2,
                                  p_new_entry_id        IN NUMBER,
                                  p_hierarchy_grp_flag  IN VARCHAR2);

  -- PROCEDURE
  --   create_entry_header
  -- Purpose
  --   An API to create an entry header row
  -- Arguments
  --   x_errbuf                Error Buffer
  --   x_retcode               Return Code; possible values are fnd_api.g_ret_sts_success, fnd_api.g_ret_sts_error, fnd_api.g_ret_sts_unexp_error
  --   p_entry_id              Entry Identifier; if NULL, will create from the sequence
  --   p_hierarchy_id          Hierarchy Identifier
  --   p_entity_id             Entity Identifier
  --   p_start_cal_period_id   Start Calender Period Identifier
  --   p_end_cal_period_id     End Calender Period Identifier
  --   p_entry_type_code       Entry Type Code
  --   p_balance_type_code     Balance Type Code
  --   p_currency_code         Currency Code
  --   p_process_code          Process Code
  --   p_category_code         Category Code
  --   p_xlate_flag            Translation Indicator; Only set to 'Y' when calling from translation package
  --   p_rule_id               Elimination Rule Identifier
  --   p_period_init_entry_flag Period Initialization Entry Flag
  -- Notes
  --
  PROCEDURE create_entry_header(x_errbuf                 OUT NOCOPY VARCHAR2,
                                x_retcode                OUT NOCOPY VARCHAR2,
                                p_entry_id               IN OUT NOCOPY NUMBER,
                                p_hierarchy_id           IN NUMBER,
                                p_entity_id              IN NUMBER,
                                p_start_cal_period_id    IN NUMBER,
                                p_end_cal_period_id      IN NUMBER,
                                p_entry_type_code        IN VARCHAR2,
                                p_balance_type_code      IN VARCHAR2,
                                p_currency_code          IN VARCHAR2,
                                p_process_code           IN VARCHAR2,
                                p_category_code          IN VARCHAR2,
                                p_xlate_flag             IN VARCHAR2 DEFAULT 'N',
                                p_rule_id                IN NUMBER DEFAULT NULL,
                                p_period_init_entry_flag IN VARCHAR2 DEFAULT 'N');
  PROCEDURE insert_entry_header(x_errbuf                 OUT NOCOPY VARCHAR2,
                                x_retcode                OUT NOCOPY VARCHAR2,
                                p_entry_id               IN NUMBER,
                                p_hierarchy_id           IN NUMBER,
                                p_entity_id              IN NUMBER,
                                p_year_to_apply_re       IN NUMBER,
                                p_start_cal_period_id    IN NUMBER,
                                p_end_cal_period_id      IN NUMBER,
                                p_entry_type_code        IN VARCHAR2,
                                p_balance_type_code      IN VARCHAR2,
                                p_currency_code          IN VARCHAR2,
                                p_process_code           IN VARCHAR2,
                                p_category_code          IN VARCHAR2,
                                p_entry_name             IN VARCHAR2,
                                p_description            IN VARCHAR2,
                                p_period_init_entry_flag IN VARCHAR2 DEFAULT 'N');

  --
  -- Procedure
  --   delete_entry
  -- Purpose
  --   An API to delete an entry from both gcs_entry_headers and gcs_entry_lines tables
  -- Arguments
  --   p_entry_id      Entry Identifier
  --   x_errbuf        Error Buffer
  --   x_retcode       Return Code
  -- Notes
  --
  PROCEDURE delete_entry(p_entry_id IN NUMBER,
                         x_errbuf   OUT NOCOPY VARCHAR2,
                         x_retcode  OUT NOCOPY VARCHAR2);

  --
  -- Procedure
  --   raise_disable_event
  -- Purpose
  --   An API to disable an entry and track impact analysis and notify
  -- Arguments
  --   p_entry_id      Entry Identifier
  --   p_cal_period_id Calendar Period Identifier
  -- Notes
  --   Bugfix 5613302
  PROCEDURE raise_disable_event(p_entry_id      IN NUMBER,
                                p_cal_period_id IN NUMBER);

END gcs_entry_pkg;


/
