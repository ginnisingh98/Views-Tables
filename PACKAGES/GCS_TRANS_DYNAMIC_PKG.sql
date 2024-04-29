--------------------------------------------------------
--  DDL for Package GCS_TRANS_DYNAMIC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_TRANS_DYNAMIC_PKG" AUTHID CURRENT_USER AS
 /* $Header: gcsxldps.pls 120.6 2007/06/28 12:28:50 vkosuri noship $ */

--
-- Package
--   gcs_trans_dynamic_pkg
-- Purpose
--   Dynamic package procedures for the Translation Program
-- History
--   08-JAN-04    M Ward        Created
--

  -- Bugfix 5725759: holds 'Y' if data loaded else 'N'
  re_data_loaded_flag    VARCHAR2(10);


  --
  -- Procedure
  --   Initialize_Data_Load_Status
  -- Purpose
  --   Initialize the data load status. The user may add both historical rates
  --   and retained earnings rates, but only submitted data for historical rates,
  --   so we need to keep track of for which line_item the user has done data submission.
  -- Arguments
  --   p_hier_dataset_code   The dataset code in FEM_BALANCES.
  --   p_cal_period_id       The current period's cal_period_id.
  --   p_source_system_code  GCS source system code.
  --   p_from_ccy            From currency code.
  --   p_ledger_id           The ledger in FEM_BALANCES.
  --   p_entity_id           Entity on which the translation is being performed.
  --   p_line_item_id        Line Item Id of retained earnings selected for the hierarchy.
  -- Example
  --   GCS_TRANS_DYNAMIC_PKG.Initialize_Data_Load_Status;
  -- Notes
  --
  PROCEDURE Initialize_Data_Load_Status (
                   p_hier_dataset_code  NUMBER,
                   p_cal_period_id      NUMBER,
                   p_source_system_code NUMBER,
                   p_from_ccy           VARCHAR2,
                   p_ledger_id          NUMBER,
                   p_entity_id          NUMBER,
                   p_line_item_id       NUMBER);

  --
  -- Procedure
  --   Roll_Forward_Rates
  -- Purpose
  --   Roll forward historical rates from prior periods.
  -- Arguments
  --   p_dataset_code       The dataset code in FEM_BALANCES.
  --   p_source_system_code GCS source system code.
  --   p_ledger_id          The ledger in FEM_BALANCES.
  --   p_cal_period_id      The current period's cal_period_id.
  --   p_prev_period_id     The previous period's cal_period_id.
  --   p_entity_id          Entity on which the translation is being performed.
  --   p_hierarchy_id       Hierarchy in which the entity resides.
  --   p_from_ccy           From currency code.
  --   p_to_ccy             To currency code.
  --   p_eq_xlate_mode      Equity translation mode (YTD or PTD).
  --   p_hier_li_id         Line Item Id of retained earnings selected for the hierarchy.
  -- Example
  --   GCS_TRANS_DYNAMIC_PKG.Roll_Forward_Historical_Rates;
  -- Notes
  --
  PROCEDURE Roll_Forward_Rates
    (p_hier_dataset_code  NUMBER,
     p_source_system_code NUMBER,
     p_ledger_id          NUMBER,
     p_cal_period_id      NUMBER,
     p_prev_period_id     NUMBER,
     p_entity_id          NUMBER,
     p_hierarchy_id       NUMBER,
     p_from_ccy           VARCHAR2,
     p_to_ccy             VARCHAR2,
     p_eq_xlate_mode      VARCHAR2,
     p_hier_li_id         NUMBER);

  --
  -- Procedure
  --   Translate_First_Ever_Period
  -- Purpose
  --   Translate balances for a period which is the first period ever
  --   to be translated.
  -- Arguments
  --   p_dataset_code    The dataset code of the translation source.
  --   p_source_system_code The source system code for GCS.
  --   p_ledger_id       The ledger of the translation source.
  --   p_cal_period_id   The period for translation.
  --   p_entity_id       Entity on which translation is being run.
  --   p_hierarchy_id    Hierarchy in which the entity resides.
  --   p_from_ccy        From currency code.
  --   p_to_ccy          To currency code.
  --   p_eq_xlate_mode   Equity translation mode (YTD or PTD).
  --   p_is_xlate_mode   Income statement translation mode (YTD or PTD).
  --   p_avg_rate        Period average rate for this period.
  --   p_end_rate        Period end rate for this period.
  --   p_group_by_flag   Whether a group by must be performed in the SQL
  --   p_round_factor    Minimum accountable unit or precision.
  --   p_hier_li_id      Line Item Id of retained earnings selected for the hierarchy.
  -- Example
  --   GCS_TRANS_DYNAMIC_PKG.Translate_First_Ever_Period;
  -- Notes
  --
  PROCEDURE Translate_First_Ever_Period
    (p_hier_dataset_code  NUMBER,
     p_source_system_code NUMBER,
     p_ledger_id          NUMBER,
     p_cal_period_id      NUMBER,
     p_entity_id          NUMBER,
     p_hierarchy_id       NUMBER,
     p_from_ccy           VARCHAR2,
     p_to_ccy             VARCHAR2,
     p_eq_xlate_mode      VARCHAR2,
     p_is_xlate_mode      VARCHAR2,
     p_avg_rate           NUMBER,
     p_end_rate           NUMBER,
     p_group_by_flag      VARCHAR2,
     p_round_factor       NUMBER,
     p_hier_li_id         NUMBER);

  --
  -- Procedure
  --   Translate_Subsequent_Period
  -- Purpose
  --   Translate balances for a period which is not the first period ever
  --   to be translated.
  -- Arguments
  --   p_dataset_code       The dataset for which translation is being run.
  --   p_cal_period_id      The period for translation.
  --   p_prev_period_id     The period just prior to this translation.
  --   p_entity_id          Entity on which translation is being run.
  --   p_hierarchy_id       Hierarchy in which the entity resides.
  --   p_ledger_id          The ledger for the translation.
  --   p_from_ccy           From currency code.
  --   p_to_ccy             To currency code.
  --   p_eq_xlate_mode      Equity translation mode (YTD or PTD).
  --   p_is_xlate_mode      Income statement translation mode (YTD or PTD).
  --   p_avg_rate           Period average rate for this period.
  --   p_end_rate           Period end rate for this period.
  --   p_group_by_flag      Whether a group by must be performed in the SQL
  --   p_round_factor       Minimum accountable unit or precision.
  --   p_source_system_code Source System Code for GCS.
  --   p_hier_li_id         Line Item Id of retained earnings selected for the hierarchy.
  -- Example
  --   GCS_TRANS_DYNAMIC_PKG.Translate_Subsequent_Period;
  -- Notes
  --
  PROCEDURE Translate_Subsequent_Period
    (p_hier_dataset_code  NUMBER,
     p_cal_period_id      NUMBER,
     p_prev_period_id     NUMBER,
     p_entity_id          NUMBER,
     p_hierarchy_id       NUMBER,
     p_ledger_id          NUMBER,
     p_from_ccy           VARCHAR2,
     p_to_ccy             VARCHAR2,
     p_eq_xlate_mode      VARCHAR2,
     p_is_xlate_mode      VARCHAR2,
     p_avg_rate           NUMBER,
     p_end_rate           NUMBER,
     p_group_by_flag      VARCHAR2,
     p_round_factor       NUMBER,
     p_source_system_code NUMBER,
     p_hier_li_id         NUMBER);

  --
  -- Procedure
  --   Create_New_Entry
  -- Purpose
  --   Create an entry in gcs_entry_headers and insert associated lines into
  --   the gcs_entry_lines table.
  -- Arguments
  --   p_new_entry_id	ID to use for the new entry.
  --   p_hierarchy_id	The entry's hierarchy.
  --   p_entity_id	The entry's entity.
  --   p_cal_period_id	The entry's period.
  --   p_balance_type_code	The balance type of the entry.
  --   p_to_ccy		Target currency code.
  -- Example
  --   GCS_TRANS_DYNAMIC_PKG.Create_New_Entry;
  -- Notes
  --
  PROCEDURE Create_New_Entry
    (p_new_entry_id	NUMBER,
     p_hierarchy_id	NUMBER,
     p_entity_id	NUMBER,
     p_cal_period_id	NUMBER,
     p_balance_type_code	VARCHAR2,
     p_to_ccy		VARCHAR2);

END GCS_TRANS_DYNAMIC_PKG;

/
