--------------------------------------------------------
--  DDL for Package GCS_TRANS_HRATES_DYNAMIC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_TRANS_HRATES_DYNAMIC_PKG" AUTHID CURRENT_USER AS
 /* $Header: gcsxldhratesps.pls 120.2 2007/06/28 12:28:07 vkosuri noship $ */
  --
  -- Procedure
  --   Roll_Forward_Historical_Rates
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
  --   GCS_TRANS_HRATES_DYNAMIC_PKG.Roll_Forward_Historical_Rates;
  -- Notes
  --
  PROCEDURE Roll_Forward_Historical_Rates
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
  --   Trans_HRates_First_Per
  -- Purpose
  --   Translate balances for historical rates for a period which is the first period ever
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
  --   GCS_TRANS_HRATES_DYNAMIC_PKG.Trans_HRates_First_Per;
  -- Notes
  --
  PROCEDURE Trans_HRates_First_Per
    (p_hier_dataset_code NUMBER,
     p_source_system_code NUMBER,
     p_ledger_id       NUMBER,
     p_cal_period_id   NUMBER,
     p_entity_id       NUMBER,
     p_hierarchy_id    NUMBER,
     p_from_ccy        VARCHAR2,
     p_to_ccy          VARCHAR2,
     p_eq_xlate_mode   VARCHAR2,
     p_is_xlate_mode   VARCHAR2,
     p_avg_rate        NUMBER,
     p_end_rate        NUMBER,
     p_group_by_flag   VARCHAR2,
     p_round_factor    NUMBER,
     p_hier_li_id      NUMBER);
  --
  -- Procedure
  --   Trans_HRates_Subseq_Per
  -- Purpose
  --   Translate balances for historical rates for a period which is not the first period ever
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
  --   GCS_TRANS_HRATES_DYNAMIC_PKG.Trans_Subseq_Period;
  -- Notes
  --
  PROCEDURE Trans_HRates_Subseq_Per
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

 END GCS_TRANS_HRATES_DYNAMIC_PKG;


/
