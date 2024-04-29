--------------------------------------------------------
--  DDL for Package PQP_FLXDU_COLUMNS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_FLXDU_COLUMNS_PKG" AUTHID CURRENT_USER AS
/* $Header: pqpflxcol.pkh 120.0 2006/04/26 23:52:37 pbhure noship $ */

-- =============================================================================
-- This procedure loads data into pqp_flxdu_columns table
-- If data is already there then update else insert
-- =============================================================================
PROCEDURE load_row
          (x_flxdu_column_id          IN NUMBER
          ,x_flxdu_column_name        IN VARCHAR2
          ,x_flxdu_column_xml_tag     IN VARCHAR2
          ,x_flxdu_column_data_type   IN VARCHAR2
          ,x_flxdu_column_data_length IN VARCHAR2
          ,x_flxdu_seq_num            IN NUMBER
          ,x_flxdu_group_name         IN VARCHAR2
          ,x_entity_type              IN VARCHAR2
          ,x_required_flag            IN VARCHAR2
          ,x_display_flag             IN VARCHAR2
          ,x_description              IN VARCHAR2
          ,x_flxdu_column_xml_data    IN VARCHAR2
          ,x_object_version_number    IN NUMBER);

-- =============================================================================
-- This procedure inserts data into pqp_flxdu_columns table
-- =============================================================================
PROCEDURE insert_row
          (x_flxdu_column_id          IN NUMBER
          ,x_flxdu_column_name        IN VARCHAR2
          ,x_flxdu_column_xml_tag     IN VARCHAR2
          ,x_flxdu_column_data_type   IN VARCHAR2
          ,x_flxdu_column_data_length IN VARCHAR2
          ,x_flxdu_seq_num            IN NUMBER
          ,x_flxdu_group_name         IN VARCHAR2
          ,x_entity_type              IN VARCHAR2
          ,x_required_flag            IN VARCHAR2
          ,x_display_flag             IN VARCHAR2
          ,x_description              IN VARCHAR2
          ,x_flxdu_column_xml_data    IN VARCHAR2
          ,x_object_version_number    IN NUMBER
          ,x_created_by               IN NUMBER
          ,x_creation_date            IN DATE
          ,x_last_update_date         IN DATE
          ,x_last_updated_by          IN NUMBER
          ,x_last_update_login        IN NUMBER);

-- =============================================================================
-- This procedure updates data in pqp_flxdu_columns table
-- =============================================================================
PROCEDURE update_row
          (x_flxdu_column_id          IN NUMBER
          ,x_flxdu_column_name        IN VARCHAR2
          ,x_flxdu_column_xml_tag     IN VARCHAR2
          ,x_flxdu_column_data_type   IN VARCHAR2
          ,x_flxdu_column_data_length IN VARCHAR2
          ,x_flxdu_seq_num            IN NUMBER
          ,x_flxdu_group_name         IN VARCHAR2
          ,x_entity_type              IN VARCHAR2
          ,x_required_flag            IN VARCHAR2
          ,x_display_flag             IN VARCHAR2
          ,x_description              IN VARCHAR2
          ,x_flxdu_column_xml_data    IN VARCHAR2
          ,x_object_version_number    IN NUMBER
          ,x_created_by               IN NUMBER
          ,x_creation_date            IN DATE
          ,x_last_update_date         IN DATE
          ,x_last_updated_by          IN NUMBER
          ,x_last_update_login        IN NUMBER);

END pqp_flxdu_columns_pkg;

 

/
