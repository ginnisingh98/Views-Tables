--------------------------------------------------------
--  DDL for Package GCS_PERIOD_INIT_DYNAMIC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_PERIOD_INIT_DYNAMIC_PKG" AUTHID CURRENT_USER AS
/* $Header: gcspinds.pls 120.2 2006/09/08 00:29:03 skamdar noship $ */
--
-- Package
--   gcs_period_init_dynamic_pkg
-- Purpose
--   Package procedures for the Period Initialization Dynamic Program
-- History
--   04-MAR-04	T Cheng		Created
-- Notes
--   The package body is created by gcs_period_init_dyn_build_pkg.
--

  --
  -- PUBLIC FUNCTIONS
  --

  --
  -- Procedure
  --   insert_entry_lines
  -- Purpose
  --   Create entry lines for the one-item next-period-initialization entry
  --   and the recurring rules-carry-forward entry if applicable.
  -- Arguments
  --   p_run_name            Name of the consolidation run
  --   p_hierarchy_id        ID of the hierarchy consolidation is run for
  --   p_entity_id           ID of the entity
  --   p_currency_code       Currency code of the entity
  --   p_bal_by_org          The balance by org flag of the hierarchy
  --   p_sec_track_col       The secondary tracking column of the hierarchy
  --   p_is_elim_entity      If it is an elimination entity (Y/N)
  --   p_cons_entity_id      Id of the consolidation entity
  --   p_re_template         The retained earnings dimension template
  --   p_cross_year_flag     Indicates if it is a cross-year processing
  --   p_category_code       The category code for the entries
  --   p_init_entry_id       Currency entry ID for next-period initialization
  --   p_init_xlate_entry_id Parent currency entry ID for next-period init.
  --   p_init_stat_entry_id  STAT entry ID for next-period initialization
  --   p_recur_entry_id      Currency entry ID for carry-forward
  --   p_recur_xlate_entry_id Parent currency entry ID for carry-forward
  --   p_recur_stat_entry_id STAT entry ID for carry-forward
  --   Bugfix 5449718: Added parameter for calendar period year
  --   p_cal_period_year     Year for Current Period Being Consolidated
  --   p_net_to_re_flag      Flag Stating If Category Nets to Retained Earnings
  -- Example
  --   GCS_PERIOD_INIT_DYNAMIC_PKG.insert_entry_lines
  --     ('Name', 1, 2, 3, 'USD', 'Y', null, 'N', 10, l_re_template,
  --      'N', 'INTERCOMPANY', 7777, 7778, 7779, null, null, null);
  -- Notes
  --
  PROCEDURE insert_entry_lines(
    p_run_name             VARCHAR2,
    p_hierarchy_id         NUMBER,
    p_entity_id            NUMBER,
    p_currency_code        VARCHAR2,
    p_bal_by_org           VARCHAR2,
    p_sec_track_col        VARCHAR2,
    p_is_elim_entity       VARCHAR2,
    p_cons_entity_id       NUMBER,
    p_re_template          GCS_TEMPLATES_PKG.TemplateRecord,
    p_cross_year_flag      VARCHAR2,
    p_category_code        VARCHAR2,
    p_init_entry_id        NUMBER,
    p_init_xlate_entry_id  NUMBER,
    p_init_stat_entry_id   NUMBER,
    p_recur_entry_id       NUMBER,
    p_recur_xlate_entry_id NUMBER,
    p_recur_stat_entry_id  NUMBER,
    p_cal_period_year      NUMBER,
    p_net_to_re_flag       VARCHAR2);

END GCS_PERIOD_INIT_DYNAMIC_PKG;

 

/
