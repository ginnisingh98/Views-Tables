--------------------------------------------------------
--  DDL for Package GCS_PERIOD_INIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_PERIOD_INIT_PKG" AUTHID CURRENT_USER AS
/* $Header: gcspinis.pls 120.1 2005/10/30 05:16:25 appldev noship $ */
--
-- Package
--   gcs_period_init_pkg
-- Purpose
--   Package procedures for the Period Initialization Program
-- History
--   04-MAR-04	T Cheng		Created
--

  --
  -- PUBLIC GLOBAL VARIABLES
  --

  -- Holds fnd_global.user_id and login_id
  g_fnd_user_id		NUMBER;
  g_fnd_login_id	NUMBER;

  --
  -- PUBLIC FUNCTIONS
  --

  --
  -- Procedure
  --   Create_Period_Init_Entries
  -- Purpose
  --   Create the one-time entry for next period initialization, and if
  --   necessary, the recurring entry for the next year.
  --   If p_category_code is not null, then create entries only for this
  --   category. Otherwise create entries for all categories necessary..
  -- Arguments
  --   p_run_name		Name of the consolidation run
  --   p_hierarchy_id		ID of the hierarchy consolidation is run for
  --   p_relationship_id	ID of the relationship between the entity
  --   				and its parent
  --   p_entity_id		ID of the entity being processed
  --   p_cons_entity_id		ID of the consolidation entity
  --   p_translation_required	If translation entries are needed
  --   p_cal_period_id		ID of the period consolidation is run for
  --   p_balance_type_code	Balance type code
  --   p_category_code		Category code to process, use NULL for all
  -- Example
  --   GCS_PERIOD_INIT_PKG.Create_Period_Init_Entries(errbuf, retcode,
  --               'Name', 1, 2, 3, 10, 'N', 200401, 'ACTUAL', 'INTERCOMPANY');
  -- Notes
  --
  PROCEDURE Create_Period_Init_Entries(
    p_errbuf               OUT NOCOPY VARCHAR2,
    p_retcode              OUT NOCOPY VARCHAR2,
    p_run_name             VARCHAR2,
    p_hierarchy_id         NUMBER,
    p_relationship_id      NUMBER,
    p_entity_id            NUMBER,
    p_cons_entity_id       NUMBER,
    p_translation_required VARCHAR2,
    p_cal_period_id        NUMBER,
    p_balance_type_code    VARCHAR2,
    p_category_code        VARCHAR2 DEFAULT NULL);

END GCS_PERIOD_INIT_PKG;

 

/
