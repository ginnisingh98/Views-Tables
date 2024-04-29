--------------------------------------------------------
--  DDL for Package GCS_CONS_IMPACT_ANALYSIS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_CONS_IMPACT_ANALYSIS_PKG" AUTHID CURRENT_USER as
  /* $Header: gcs_cons_impacts.pls 120.3 2007/10/09 07:15:12 smatam ship $ */

  --
  -- Procedure
  --   hierarchy_altered()
  -- Purpose
  --   Tracks any changes made to the date effective relationship attributes
  -- Arguments
  --   p_pre_cons_relationship_id Original Relationship
  --   p_post_cons_relationship_id  New Relationship
  --   p_trx_type_code      A&D Transaction Type (NONE if Not Applicable)
  --   p_trx_date_day     Day of Transaction
  --   p_trx_date_month     Month of Transaction
  --   p_trx_date_year      Year of Transaction
  --   p_hidden_flag      Dictates wether or not to show the transaction
  --   p_intermediate_trtmnt_id   Intermediate Treatment
  --   p_intermediate_pct_owned   Intermediate Pct Ownership
  -- Notes
  --
  FUNCTION hierarchy_altered(p_pre_cons_relationship_id  IN NUMBER,
                             p_post_cons_relationship_id IN NUMBER,
                             p_trx_type_code             IN VARCHAR2,
                             p_trx_date_day              IN NUMBER,
                             p_trx_date_month            IN NUMBER,
                             p_trx_date_year             IN NUMBER,
                             p_hidden_flag               IN VARCHAR2,
                             p_intermediate_trtmnt_id    IN NUMBER,
                             p_intermediate_pct_owned    IN NUMBER)
    RETURN VARCHAR2;
  --
  -- Procedure
  --   pristine_data_altered()
  -- Purpose
  --   Tracks any loads performed by data submission
  -- Arguments
  --   p_subscription_guid    Standard Business Event Parameter
  --   p_event        Standard Business Event Parameter
  -- Notes
  --   Not yet implemented, since FEM has not published a business event

  FUNCTION data_sub_load_executed(p_subscription_guid in raw,
                                  p_event             in out nocopy wf_event_t)
    RETURN VARCHAR2;
  --
  -- Procedure
  --   acqdisp_altered()
  -- Purpose
  --   Tracks any changes to A&D Transactions
  -- Arguments
  --   p_subscription_guid              Standard Business Event Parameter
  --   p_event                          Standard Business Event Parameter
  -- Notes

  FUNCTION acqdisp_altered(p_subscription_guid in raw,
                           p_event             in out nocopy wf_event_t)
    RETURN VARCHAR2;

  --
  -- Procedure
  --   adjustment_altered()
  -- Purpose
  --   Tracks any changes to adjustments
  -- Arguments
  --   p_subscription_guid              Standard Business Event Parameter
  --   p_event                          Standard Business Event Parameter
  -- Notes

  FUNCTION adjustment_altered(p_subscription_guid in raw,
                              p_event             in out nocopy wf_event_t)
    RETURN VARCHAR2;
  --
  -- Procedure
  --   daily_rates_altered()
  -- Purpose
  --   Tracks any changes to rates Period End/Average Rates
  -- Arguments
  --   p_subscription_guid              Standard Business Event Parameter
  --   p_event                          Standard Business Event Parameter
  -- Notes

  FUNCTION daily_rates_altered(p_subscription_guid in raw,
                               p_event             in out nocopy wf_event_t)
    RETURN VARCHAR2;

  --
  -- Procedure
  --   historical_rates_altered()
  -- Purpose
  --   Tracks any changes to rates Period End/Average Rates
  -- Arguments
  --   p_subscription_guid              Standard Business Event Parameter
  --   p_event                          Standard Business Event Parameter
  -- Notes

  FUNCTION historical_rates_altered(p_subscription_guid in raw,
                                    p_event             in out nocopy wf_event_t)
    RETURN VARCHAR2;

  --
  -- Procedure
  --   consolidation_completed()
  -- Purpose
  --   Tracks if a prior period has been reconsolidated, or a sub has been reconsolidation
  -- Arguments
  --   p_run_name     Process Identifier
  --   p_run_entity_id      Run Entity
  --   p_cal_period_id      Calendar Period
  --   p_cal_period_end_date    End Date of Calendar Period
  --   p_hierarchy_id     Hierarchy Identifier
  --   p_balance_type_code    Balance Type
  -- Notes

  PROCEDURE consolidation_completed(p_run_name            IN VARCHAR2,
                                    p_run_entity_id       IN NUMBER,
                                    p_cal_period_id       IN NUMBER,
                                    p_cal_period_end_date IN DATE,
                                    p_hierarchy_id        IN NUMBER,
                                    p_balance_type_code   IN VARCHAR2);

  --
  -- Procedure
  --   value_set_map_updated()
  -- Purpose
  --   Tracks if a value set map has been updated post consolidation
  -- Arguments
  --   p_dimension_id     Dimension Identifier
  --   p_object_id      Object Identifier
  --   p_object_definition_id   Object Definition Identifier
  --   p_eff_start_date     Effective Start Date
  --   p_eff_end_date     Effective End Date
  -- Notes

  PROCEDURE value_set_map_updated(p_dimension_id        IN NUMBER,
                                  p_eff_start_date      IN DATE,
                                  p_eff_end_date        IN DATE,
                                  p_consolidation_vs_id IN NUMBER);
  --
  -- Function
  --   adjustment_disabled()
  -- Purpose
  --   Tracks disabling adjustments
  -- Arguments
  --   p_subscription_guid              Standard Business Event Parameter
  --   p_event                          Standard Business Event Parameter
  -- Notes
  --   Bugfix 5613302

  FUNCTION adjustment_disabled(p_subscription_guid in raw,
                               p_event             in out nocopy wf_event_t)
    RETURN VARCHAR2;

END GCS_CONS_IMPACT_ANALYSIS_PKG;


/
