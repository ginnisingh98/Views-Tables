--------------------------------------------------------
--  DDL for Package GCS_DATA_TYPE_CODES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_DATA_TYPE_CODES_PKG" AUTHID CURRENT_USER AS
  /* $Header: gcsdatatypess.pls 120.2 2006/04/18 11:35:34 vkosuri noship $ */
  TYPE r_datatype_info IS RECORD(
    data_type_id           NUMBER(15),
    data_type_code         VARCHAR2(30),
    enforce_balancing_flag VARCHAR2(1),
    apply_elim_rules_flag  VARCHAR2(1),
    apply_cons_rules_flag  VARCHAR2(1),
    source_dataset_code    NUMBER(15));

  TYPE t_datatype_info IS TABLE OF r_datatype_info;

  g_datatype_info t_datatype_info;

  --
  -- Procedure
  --   Insert_Row
  -- Purpose
  --   Inserts a row into the gcs_data_type_codes_b table.
  -- Arguments
  --   row_id
  --   data_type_id
  --   data_type_code
  --   enforce_balancing_flag
  --   apply_elim_rules_flag
  --   apply_cons_rules_flag
  --   source_dataset_code
  --   data_type_name
  --   description
  --   creation_date
  --   created_by
  --   last_update_date
  --   last_updated_by
  --   last_update_login
  --   object_version_number
  -- Example
  --   GCS_DATA_TYPE_CODES_PKG.Insert_Row(...);
  -- Notes
  --

 PROCEDURE Insert_Row(row_id                 IN OUT NOCOPY VARCHAR2,
                       data_type_id           NUMBER,
                       data_type_code         VARCHAR2,
                       enforce_balancing_flag VARCHAR2,
                       apply_elim_rules_flag  VARCHAR2,
                       apply_cons_rules_flag  VARCHAR2,
                       source_dataset_code    NUMBER,
                       data_type_name         VARCHAR2,
                       description            VARCHAR2,
                       creation_date          DATE,
                       created_by             NUMBER,
                       last_update_date       DATE,
                       last_updated_by        NUMBER,
                       last_update_login      NUMBER,
                       object_version_number  NUMBER);

  --
  -- Procedure
  --   Update_Row
  -- Purpose
  --   Updates a row in the gcs_data_type_codes_b table.
  -- Arguments
  --   row_id
  --   data_type_code
  --   enforce_balancing_flag
  --   apply_elim_rules_flag
  --   apply_cons_rules_flag
  --   source_dataset_code
  --   data_type_name
  --   description
  --   creation_date
  --   created_by
  --   last_update_date
  --   last_updated_by
  --   last_update_login
  --   object_version_number
  -- Example
  --   GCS_DATA_TYPE_CODES_PKG.Update_Row(...);
  -- Notes
  --
  PROCEDURE Update_Row(row_id                 IN OUT NOCOPY VARCHAR2,
                       data_type_id           NUMBER,
                       data_type_code         VARCHAR2,
                       enforce_balancing_flag VARCHAR2,
                       apply_elim_rules_flag  VARCHAR2,
                       apply_cons_rules_flag  VARCHAR2,
                       source_dataset_code    NUMBER,
                       data_type_name         VARCHAR2,
                       description            VARCHAR2,
                       creation_date          DATE,
                       created_by             NUMBER,
                       last_update_date       DATE,
                       last_updated_by        NUMBER,
                       last_update_login      NUMBER,
                       object_version_number  NUMBER);

  --
  -- Procedure
  --   Load_Row
  -- Purpose
  --   Loads a row into the gcs_data_type_codes_b table.
  -- Arguments
  --   data_type_code
  --   owner
  --   last_update_date
  --   enforce_balancing_flag
  --   apply_elim_rules_flag
  --   apply_cons_rules_flag
  --   source_dataset_code
  --   object_version_number
  --   data_type_name
  --   description

  -- Example
  --   GCS_DATA_TYPE_CODES_PKG.Load_Row(...);
  -- Notes
  --

  -- Bugfix 5155519  : source_dataset_display_code instead of source_dataset_code in the signature.

  PROCEDURE Load_Row(data_type_id           NUMBER,
                     owner                  VARCHAR2,
                     last_update_date       VARCHAR2,
                     custom_mode            VARCHAR2,
		                 data_type_code         VARCHAR2,
                     enforce_balancing_flag VARCHAR2,
                     apply_elim_rules_flag  VARCHAR2,
                     apply_cons_rules_flag  VARCHAR2,
                     source_dataset_display_code   VARCHAR2,
                     object_version_number  NUMBER,
                     data_type_name         VARCHAR2,
                     description            VARCHAR2);

  --
  -- Procedure
  --   Translate_Row
  -- Purpose
  --   Updates translated infromation for a row in the
  --   gcs_data_type_codes_tl table.
  -- Arguments
  --   data_type_code
  --   owner
  --   last_update_date
  --   data_type_name
  --   description
  -- Example
  --   GCS_DATA_TYPE_CODES_PKG.Translate_Row(...);
  -- Notes
  --
  PROCEDURE Translate_Row(data_type_id     NUMBER,
                          owner            VARCHAR2,
                          last_update_date VARCHAR2,
                          custom_mode      VARCHAR2,
                          data_type_name   VARCHAR2,
                          description      VARCHAR2);

  -- Procedure
  --   ADD_LANGUAGE
  -- Arguments

  -- Example
  --   GCS_DATA_TYPE_CODES_PKG.ADD_LANGUAGE();
  -- Notes
  --

  PROCEDURE ADD_LANGUAGE;

END GCS_DATA_TYPE_CODES_PKG;

 

/
