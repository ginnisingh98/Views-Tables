--------------------------------------------------------
--  DDL for Package GCS_WEBADI_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_WEBADI_PKG" AUTHID CURRENT_USER AS
/* $Header: gcswebadis.pls 120.4 2007/09/03 07:41:08 vkosuri noship $ */
   -- Records, Associative Arrays, and Variables to store dimension information
   TYPE r_dimension_info IS RECORD
    				(dimension_varchar_label		VARCHAR2(30),
     				 b_table_name		VARCHAR2(30),
     				 b_t_table_name		VARCHAR2(30),
     				 tl_t_table_name	VARCHAR2(30),
     				 attr_t_table_name	VARCHAR2(30),
     				 hier_t_table_name	VARCHAR2(30),
     				 display_code	        VARCHAR2(30),
     				 name	                VARCHAR2(30),
     				 dimension_id		fem_dimensions_b.dimension_id%TYPE,
     				 obj_defn_id		NUMBER(15));

   TYPE t_dimension_info IS TABLE OF r_dimension_info INDEX BY VARCHAR2(30);

   g_dimension_info t_dimension_info;

   --
   -- Procedure
   --   datasub_upload
   -- Purpose
   --   An API to upload Data Submission header info from Web ADI
   -- Arguments
   -- Notes
   --
   -- Bug Fix   : 5690166 , Added p_load_id
   PROCEDURE datasub_upload (
      p_load_id                 IN   NUMBER,
      p_load_name               IN   VARCHAR2,
      p_entity_name             IN   VARCHAR2,
      p_period                  IN   VARCHAR2,
      p_balance_type            IN   VARCHAR2,
      p_load_method             IN   VARCHAR2,
      p_currency_type           IN   VARCHAR2,
      p_currency_code           IN   VARCHAR2,
      p_amount_type             IN   VARCHAR2,
      p_measure_type            IN   VARCHAR2,
      p_rule_set                IN   VARCHAR2
   );

   --
   -- Procedure
   --   HRATE_Import
   -- Purpose
   --   An API to import historical rates from Web ADI
   -- Arguments
   -- Notes
   --
   PROCEDURE hrate_import (
      p_hierarchy_id       IN   NUMBER,
      p_entity_id          IN   NUMBER,
      p_cal_period_id      IN   NUMBER
   );

   --
   -- Procedure
   --   Dim_Member_Import
   -- Purpose
   --   An API to import dimension members from Web ADI
   -- Arguments
   -- Notes
   --
   PROCEDURE dim_member_import (
      x_errbuf                       OUT NOCOPY   VARCHAR2,
      x_retcode                      OUT NOCOPY   VARCHAR2,
      p_sequence_num                 IN           NUMBER,
      p_dimension_varchar_label      IN           VARCHAR2
   );

   --
   -- Procedure
   --   dim_hier_upload
   -- Purpose
   --   An API to upload dimension hierarchies header info from Web ADI
   -- Arguments
   -- Notes
   --
   PROCEDURE dim_hier_upload (
      p_dimension_varchar_label         IN   VARCHAR2,
      p_hierarchy_name                  IN   VARCHAR2,
      p_version_name                    IN   VARCHAR2,
      p_version_start_date              IN   VARCHAR2,
      p_version_end_date                IN   VARCHAR2,
      p_analysis_flag                   IN   VARCHAR2,
      p_mvs_flag                        IN   VARCHAR2
   );

   --
   -- Procedure
   --   DIM_HIER_IMPORT
   -- Purpose
   --   An API to import dimension hierarchies from Web ADI
   -- Arguments
   -- Notes
   --
   PROCEDURE dim_hier_import (
      x_errbuf                  OUT NOCOPY      VARCHAR2,
      x_retcode                 OUT NOCOPY      VARCHAR2,
      p_sequence_num            IN              NUMBER,
      p_dimension_varchar_label IN              VARCHAR2,
      p_hierarchy_name          IN              VARCHAR2,
      p_version_name            IN              VARCHAR2,
      p_version_start_dt        IN              VARCHAR2,
      p_version_end_dt          IN              VARCHAR2,
      p_analysis_flag           IN              VARCHAR2,
      p_parent_vs_display_code  IN              VARCHAR2,
      p_mvs_flag                IN              VARCHAR2
   );

   --
   -- Procedure
   --   handle_interco_map_flag
   -- Purpose
   --   An API to set the value for the GCS_SYSTEM_OPTIONS.INTERCO_MAP_ENABLED_FLAG
   -- Arguments
   -- Notes
   --
   PROCEDURE handle_interco_map_flag;

   --
   -- FUNCTION
   --   Execute_Event
   -- Purpose
   --   Execute GCS Manual Entries Dimension Config Event
   --   Update visible dimensions in the entries spreadsheet upon user changes
   -- Arguments
   --    p_subscription_guid
   --    p_event
   -- Notes
   --
   FUNCTION execute_event (
      p_subscription_guid   IN              RAW,
      p_event               IN OUT NOCOPY   wf_event_t
   )
      RETURN VARCHAR2;
END gcs_webadi_pkg;


/
