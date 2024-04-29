--------------------------------------------------------
--  DDL for Package GCS_CONS_MONITOR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_CONS_MONITOR_PKG" AUTHID CURRENT_USER AS
/* $Header: gcscms.pls 120.3 2007/12/14 04:58:46 cdesouza noship $ */

  --
  -- Procedure
  --   lock_results
  -- Purpose
  --   lock/unlock consolidation results
  --   called from consolidation monitor UI
  -- Arguments
  --   p_runname        	Consolidation run identifier
  --   p_entity_id        	Consolidation entity identifier
  --   p_lock_flag		Y for lock and N for unlock
  --
   PROCEDURE lock_results (
      p_runname   IN              VARCHAR2,
      p_entity_id IN              NUMBER,
      p_lock_flag IN               VARCHAR2,
      x_errbuf     OUT NOCOPY      VARCHAR2,
      x_retcode    OUT NOCOPY      VARCHAR2
   );

  --
  -- Procedure
  --   update_data_status
  -- Purpose
  --   Update the gcs_cons_data_status when a new hierarchy is created,
  --   or an entity is added/deleted, or new data submitted
  -- Arguments
  --   p_load_id        	Data submission identifier
  --   p_cons_rel_id        	Consolidation relationship identifier
  --   p_hierarchy_id		Hierarchy for which the logic must be performed
  --   p_transaction_type	NEW, ACQ, or DIS
  --
   PROCEDURE update_data_status (
      p_load_id                 IN NUMBER 	DEFAULT NULL,
      p_cons_rel_id             IN NUMBER 	DEFAULT NULL,
      p_hierarchy_id            IN NUMBER 	DEFAULT NULL,
      p_transaction_type        IN VARCHAR2 	DEFAULT NULL
);

  --
  -- Procedure
  --   hierarchy_init
  -- Purpose
  --   Update the gcs_cons_data_status when a new hierarchy is created
  -- Arguments
  --   p_hierarchy_id		Hierarchy for which the logic must be performed
  --
   PROCEDURE hierarchy_init (
      x_errbuf    OUT NOCOPY      VARCHAR2,
      x_retcode   OUT NOCOPY      VARCHAR2,
      p_hierarchy_id              NUMBER
);

  --
  -- Procedure
  --   submit_update_data_status
  -- Purpose
  --   Submits update gcs_cons_data_status when a new hierarchy is created,
  --   or an entity is added/deleted, or new data submitted
  -- Arguments
  --   p_load_id        	Data submission identifier
  --   p_cons_rel_id      Consolidation relationship identifier
  --   p_hierarchy_id		  Hierarchy for which the logic must be performed
  --   p_transaction_type	NEW, ACQ, or DIS
  --
  PROCEDURE submit_update_data_status(x_errbuf           OUT NOCOPY   VARCHAR2,
                                      x_retcode          OUT NOCOPY   VARCHAR2,
                                      p_load_id          IN  NUMBER   DEFAULT  NULL,
                                      p_cons_rel_id      IN  NUMBER   DEFAULT  NULL,
                                      p_hierarchy_id     IN  NUMBER   DEFAULT  NULL,
                                      p_transaction_type IN  VARCHAR2 DEFAULT  NULL
);

END GCS_CONS_MONITOR_PKG;


/
