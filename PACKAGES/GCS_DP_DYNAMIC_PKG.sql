--------------------------------------------------------
--  DDL for Package GCS_DP_DYNAMIC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_DP_DYNAMIC_PKG" AUTHID CURRENT_USER AS
/* $Header: gcsdpdyns.pls 120.2 2006/02/04 02:02:33 yingliu noship $ */
--
-- Package
--   GCS_DP_DYNAMIC_PKG
-- Purpose
--   Package procedures for the Data Preparation Engine Program
-- History
--   08-Dec-03 Ying Liu    Created
--
  -- Definition of Global Data Types and Variables
      gcs_dp_proc_data_error EXCEPTION;

   --
   -- Procedure
   --   PROCESS_DATA
   -- Purpose
   --   This procedure will process all the data collected by the dynamic sql statement and insert the data into GCS_ENTRY_LINES/HEADERS
   -- Notes
   --
   PROCEDURE process_data (
      p_source_currency_code      IN              VARCHAR2,
      p_target_cal_period_id      IN              NUMBER,
      p_max_period                IN              NUMBER,
      p_currency_type_code        IN              VARCHAR2,
      p_hierarchy_id              IN              NUMBER,
      p_entity_id                 IN              NUMBER,
      p_source_ledger_id          IN              NUMBER,
      p_year_end_values_match     IN              VARCHAR2,
      p_cal_period_record         IN              gcs_utility_pkg.r_cal_period_info,
      p_balance_type_code         IN              VARCHAR2,
      p_owner_percentage          IN              NUMBER,
      p_run_detail_id             IN              NUMBER,
      p_source_dataset_code       IN              NUMBER,
      errbuf                      OUT NOCOPY      VARCHAR2,
      retcode                     OUT NOCOPY      VARCHAR2
   );

   --
   -- Procedure
   --   process_inc_data
   -- Purpose
   --   This procedure will process incremental data
   -- Notes
   --
   PROCEDURE process_inc_data (
      p_source_currency_code      IN              VARCHAR2,
      p_target_cal_period_id      IN              NUMBER,
      p_currency_type_code        IN              VARCHAR2,
      p_hierarchy_id              IN              NUMBER,
      p_entity_id                 IN              NUMBER,
      p_source_ledger_id          IN              NUMBER,
      p_balance_type_code         IN              VARCHAR2,
      p_owner_percentage          IN              NUMBER,
      p_run_name                  IN              VARCHAR2,
      p_source_dataset_code       IN              NUMBER,
      x_entry_id                  OUT NOCOPY      NUMBER,
      x_stat_entry_id             OUT NOCOPY      NUMBER,
      x_prop_entry_id             OUT NOCOPY      NUMBER,
      x_stat_prop_entry_id        OUT NOCOPY      NUMBER,
      errbuf                      OUT NOCOPY      VARCHAR2,
      retcode                     OUT NOCOPY      VARCHAR2
   );
END gcs_dp_dynamic_pkg;


 

/
