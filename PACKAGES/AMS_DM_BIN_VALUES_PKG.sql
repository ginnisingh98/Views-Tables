--------------------------------------------------------
--  DDL for Package AMS_DM_BIN_VALUES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_DM_BIN_VALUES_PKG" AUTHID CURRENT_USER AS
/* $Header: amstdbvs.pls 115.3 2002/12/09 11:03:22 choang noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_DM_BIN_VALUES_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================

PROCEDURE Insert_Row(
          px_bin_value_id   IN OUT NOCOPY NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_source_field_id    NUMBER,
          p_bucket    NUMBER,
          p_bin_value    VARCHAR2,
          p_start_value    NUMBER,
          p_end_value    NUMBER);

PROCEDURE Update_Row(
          p_bin_value_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_source_field_id    NUMBER,
          p_bucket    NUMBER,
          p_bin_value    VARCHAR2,
          p_start_value    NUMBER,
          p_end_value    NUMBER);

PROCEDURE Delete_Row(
    p_BIN_VALUE_ID  NUMBER);
PROCEDURE Lock_Row(
          p_bin_value_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_source_field_id    NUMBER,
          p_bucket    NUMBER,
          p_bin_value    VARCHAR2,
          p_start_value    NUMBER,
          p_end_value    NUMBER);

END AMS_DM_BIN_VALUES_PKG;

 

/
