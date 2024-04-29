--------------------------------------------------------
--  DDL for Package GCS_AGGREGATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_AGGREGATION_PKG" AUTHID CURRENT_USER AS
/* $Header: gcsaggrs.pls 120.2 2006/02/06 19:34:37 yingliu noship $ */
--
-- Package
--   gcs_aggregation_pkg
-- Purpose
--   Package procedures for the Aggregation Program
-- History
--   17-FEB-04	T Cheng		Created
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
  --   Aggregate
  -- Purpose
  --   Aggregate child entities data for a consolidation entity.
  -- Arguments
  --   p_run_detail_id		ID of the aggregation run
  --   p_hierarchy_id		ID of the hierarchy consolidation is run for
  --   p_relationship_id	ID of the relationship between the
  --				consolidation entity and its parent
  --   p_cons_entity_id		ID of the consolidation entity
  --   p_cal_period_id		ID of the period consolidation is run for
  --   p_period_end_date	The end date of the period
  --   p_balance_type_code	Balance type code
  --   p_stat_required		Y/N, whether processing is needed for STAT
  -- Example
  --   GCS_AGGREGATION_PKG.Aggregate(errbuf, retcode, 111,
  --                                 100, 1, 2, 200401, <date>, 'ACTUAL', 'N');
  -- Notes
  --
  PROCEDURE Aggregate(
    p_errbuf            OUT NOCOPY VARCHAR2,
    p_retcode           OUT NOCOPY VARCHAR2,
    p_run_detail_id     NUMBER,
    p_hierarchy_id      NUMBER,
    p_relationship_id   NUMBER,
    p_cons_entity_id    NUMBER,
    p_cal_period_id     NUMBER,
    p_period_end_date   DATE,
    p_balance_type_code VARCHAR2,
    p_stat_required     VARCHAR2,
    p_hier_dataset_code     NUMBER);

END GCS_AGGREGATION_PKG;

 

/
