--------------------------------------------------------
--  DDL for Package GCS_DYN_FEM_POSTING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_DYN_FEM_POSTING_PKG" AUTHID CURRENT_USER AS
/* $Header: gcsdynfemps.pls 120.3 2006/02/07 01:43:23 yingliu noship $ */
--
-- Package
--   gcs_dyn_fem_posting_pkg
-- Purpose
--   Posting engine for GCS
-- History
--   12-OCT-03	R Goyal		Created

--

  --
  -- Function
  --   Gcs_Fem_Post
  -- Purpose
  --   Call the appropriate procedure based on whether the mode is 'Insert', 'Merge' or 'Delta'.
  --   This procedure is called from the Consolidation engine.
  -- Arguments
  --   errbuf:  Buffer to hold the error message
  --   retcode: Return code
  --   p_run_name : Consolidation run name
  --   p_hierarchy_id: Hierarchy id being processed
  --   p_balance_type_code : Actuals or Averages
  --   p_category_code: Category ( Data Prep, Translation, Intercompany, etc)
  --   p_cons_entity_id: Consolidation entity Id
  --   p_child_entity_id: Child entity Id
  --   p_cal_period_id: Period being consolidated
  --   p_undo: Undo mode - 'Y' for running in undo mode, default is 'N'
  --   p_run_detail_id: Run detail id for a consolidation run
  --   p_mode : 'I', "M' or 'D' for Insert, Merge or Delta
  --   p_entry_id : Entry_Id to be processed
  -- Example
  --
  -- Notes
  --

   PROCEDURE Gcs_Fem_Post (
                        errbuf       OUT NOCOPY VARCHAR2,
                        retcode      OUT NOCOPY VARCHAR2,
                        p_run_name              VARCHAR2,
   			p_hierarchy_id          NUMBER,
                        p_balance_type_code     VARCHAR2,
                        p_category_code         VARCHAR2,
			p_cons_entity_id        NUMBER,
                	p_child_entity_id       NUMBER DEFAULT NULL,
                        p_cal_period_id         NUMBER,
                	p_undo                  VARCHAR2 DEFAULT 'N',
                        p_xlate                 VARCHAR2,
                	p_run_detail_id         NUMBER DEFAULT NULL,
			p_mode			VARCHAR2,
                        p_entry_id              NUMBER DEFAULT NULL,
                        p_hier_dataset_code     NUMBER);


  --
  -- Procedure
  --   Gcs_Fem_Delete
  -- Purpose
  --   Delete rows from FEM_BALANCES
  -- Arguments
  --   errbuf           Error buffer
  --   retcode          Return code
  --   p_hierarchy_id : Hierarchy being processed
  --   p_balance_type_code : Actuals vs. Averages
  --   p_cal_period_id: Period being consolidated
  --   p_entity_type:   'E' for Elimimation and 'O' for Operating entity
  --   p_entity_id:     Entity being processed
  -- Example
  --
  -- Notes
  --

  PROCEDURE GCS_Fem_Delete(
			errbuf       OUT NOCOPY VARCHAR2,
			retcode      OUT NOCOPY VARCHAR2,
			p_hierarchy_id          NUMBER,
                        p_balance_type_code     VARCHAR2,
			p_cal_period_id         NUMBER,
                        p_entity_type           VARCHAR2,
                        p_entity_id             NUMBER,
                        p_hier_dataset_code     NUMBER);



END GCS_DYN_FEM_POSTING_PKG;

 

/
