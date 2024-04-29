--------------------------------------------------------
--  DDL for Package GCS_AGGREGATION_DYNAMIC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_AGGREGATION_DYNAMIC_PKG" AUTHID CURRENT_USER AS
/* $Header: gcsaggds.pls 120.1 2005/10/30 05:16:58 appldev noship $ */
--
-- Package
--   gcs_aggregation_dynamic_pkg
-- Purpose
--   Package procedures for the Aggregation Dynamic Program
-- History
--   17-FEB-04	T Cheng		Created
-- Notes
--   The package body is created by gcs_aggregation_dyn_build_pkg.
--

  --
  -- PUBLIC FUNCTIONS
  --

  --
  -- Procedure
  --   retrieve_org_id
  -- Purpose
  --   For internal use in insert_full_entry_lines.
  -- Arguments
  --   p_entity_id          ID of entity
  -- Example
  --   * None *
  -- Notes
  --   FOR INTERNAL USE IN THIS PACKAGE ONLY unless a procedure for
  --   populating the internal structure is made available.
  --
  FUNCTION retrieve_org_id(p_entity_id NUMBER) RETURN NUMBER;

  --
  -- Procedure
  --   insert_full_entry_lines
  -- Purpose
  --   Create entry lines with the full consolidation amounts.
  -- Arguments
  --   p_entry_id           Entry Id for the consolidation entity's currency
  --   p_stat_entry_id      Entry Id for STAT
  --   p_cons_entity_id     ID of the consolidation entity
  --   p_hierarchy_id       ID of the hierarchy consolidation is run for
  --   p_relationship_id    ID of the relationship between the entity
  --                        and its parent
  --   p_cal_period_id      ID of the period consolidation is run for
  --   p_period_end_date    The end date of the period
  --   p_currency_code      Currency code of the consolidation entity
  --   p_balance_type_code  Balance type code
  --   p_dataset_code       Dataset of the information in the entry
  -- Example
  --   GCS_AGGREGATION_DYNAMIC_PKG.insert_full_entry_lines
  --     (1001, 1002, 2, 1000, 200312, <date>, 'USD', 10001);
  -- Notes
  --
  PROCEDURE insert_full_entry_lines(
    p_entry_id           NUMBER,
    p_stat_entry_id      NUMBER,
    p_cons_entity_id     NUMBER,
    p_hierarchy_id       NUMBER,
    p_relationship_id    NUMBER,
    p_cal_period_id      NUMBER,
    p_period_end_date    DATE,
    p_currency_code      VARCHAR2,
    p_balance_type_code  VARCHAR2,
    p_dataset_code       NUMBER);

END GCS_AGGREGATION_DYNAMIC_PKG;

 

/
