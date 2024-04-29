--------------------------------------------------------
--  DDL for Package GCS_DATA_PREP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_DATA_PREP_PKG" AUTHID CURRENT_USER AS
/* $Header: gcsdps.pls 120.2 2006/02/04 02:02:44 yingliu noship $ */
--
-- Package
--   GCS_DATA_PREP_PKG
-- Purpose
--   Package procedures for the Data Preparation Program
-- History
--   08-Dec-03 Ying Liu    Created
--

   --
   -- Procedure
   --   GCS_MAIN_DATA_PREP
   -- Purpose
   --    This procedure will be called via the SRS submission performed by the Consolidation Engine. It will then call the appropriate routines to complete the data preparation process.
   -- Arguments
   --    x_errbuf    Error Buffer used for SRS
   --    x_retcode      Return Code used for SRS
   --    p_hierarchy_id     Consolidation Hierarchy Identifier
   --    p_entity_id     Internal/External Entity Identifier
   --    p_target_cal_period_id      Target Calendar Period Identifier
   --    p_execution_mode      'FULL', 'INCREMENTAL' Load
   --    p_stat_entry_id    Entry Identifier for lines with Currency Code STAT
   --    p_entry_id    Entry Identifier for other lines
   --    p_proportional_entry_id    Entry Identifier for proportional consolidation lines
   --                   if = -1, full consolidation
   --    p_cons_rel_id Consolidation Relationships Identifier
   --                   Used for proportional consolidation
   --                   if = -1, full consolidation
   --    p_balance_type_code Balance Type Code: ACTUAL or ADB
   -- Notes
   --
   PROCEDURE gcs_main_data_prep (
      x_errbuf                  OUT NOCOPY      VARCHAR2,
      x_retcode                 OUT NOCOPY      VARCHAR2,
      p_hierarchy_id            IN              NUMBER,
      p_entity_id               IN              NUMBER,
      p_target_cal_period_id    IN              NUMBER,
      p_run_detail_id           IN              NUMBER,
      p_cons_rel_id             IN              NUMBER,
      p_balance_type_code       IN              VARCHAR2,
      p_source_dataset_code     IN              NUMBER
   );

   --
   -- Procedure
   --   gcs_incremental_data_prep
   -- Purpose
   --    This procedure will be called via the SRS submission performed by the Consolidation Engine. It will then call the appropriate routines to complete the data preparation process.
   -- Arguments
   --    x_errbuf    Error Buffer used for SRS
   --    x_retcode      Return Code used for SRS
   --    p_ledger_id     Ledger Identifier
   --    p_currency_code     Currency Code
   --    p_target_cal_period_id      Target Calendar Period Identifier
   --    p_object_id      Object Identifier
   --    p_dataset_code    Dataset Code
   --    p_request_id    Request Identifier
   -- Notes
   --
   PROCEDURE gcs_incremental_data_prep (
      x_errbuf                 OUT NOCOPY      VARCHAR2,
      x_retcode                OUT NOCOPY      VARCHAR2,
      x_entry_id               OUT NOCOPY      NUMBER,
      x_stat_entry_id          OUT NOCOPY      NUMBER,
      x_prop_entry_id          OUT NOCOPY      NUMBER,
      x_stat_prop_entry_id     OUT NOCOPY      NUMBER,
      p_source_cal_period_id   IN              NUMBER,
      p_balance_type_code      IN              VARCHAR2,
      p_ledger_id              IN              NUMBER,
      p_currency_code          IN              VARCHAR2,
      p_source_dataset_code    IN              NUMBER,
      p_run_name               IN              VARCHAR2,
      p_cons_relationship_id   IN              NUMBER,
      p_currency_type_code     IN              VARCHAR2
   );

   -- PROCEDURE
   --   CREATE_PROCESS
   -- Purpose
   --   Create PROCESS_DATA procedure using ad_ddl. Returns
   -- Arguments
   --    x_retcode
   --    x_errbuf
   --
   PROCEDURE create_process (
	x_errbuf	OUT NOCOPY	VARCHAR2,
	x_retcode	OUT NOCOPY	VARCHAR2
   );

END gcs_data_prep_pkg;


 

/
