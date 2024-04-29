--------------------------------------------------------
--  DDL for Package AMS_DM_TARGETS_B_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_DM_TARGETS_B_PKG" AUTHID CURRENT_USER AS
/* $Header: amstdtgs.pls 115.4 2003/09/15 12:44:48 rosharma noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_DM_TARGETS_B_PKG
-- Purpose
--
-- History
-- 10-Apr-2002 nyostos  Created.
-- 06-Mar-2003 choang   Added x_custom_mode to load_row for bug 2819067.
--
-- NOTE
--
-- End of Comments
-- ===============================================================

PROCEDURE Insert_Row(
          px_target_id   IN OUT NOCOPY NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_active_flag    VARCHAR2,
          p_model_type    VARCHAR2,
          p_data_source_id    NUMBER,
          p_source_field_id    NUMBER,
          p_target_name    VARCHAR2,
          p_description    VARCHAR2,
          p_target_source_id    NUMBER );

PROCEDURE Update_Row(
          p_target_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_active_flag    VARCHAR2,
          p_model_type    VARCHAR2,
          p_data_source_id    NUMBER,
          p_source_field_id    NUMBER,
          p_target_name    VARCHAR2,
          p_description    VARCHAR2,
          p_target_source_id    NUMBER );

PROCEDURE Delete_Row(
          p_TARGET_ID  NUMBER);

PROCEDURE Lock_Row(
          p_target_id			NUMBER,
          p_last_update_date		DATE,
          p_last_updated_by		NUMBER,
          p_creation_date		DATE,
          p_created_by			NUMBER,
          p_last_update_login		NUMBER,
          p_object_version_number	NUMBER,
          p_active_flag			VARCHAR2,
          p_model_type			VARCHAR2,
          p_data_source_id		NUMBER,
          p_source_field_id		NUMBER,
          p_target_source_id            NUMBER );

PROCEDURE add_language;

PROCEDURE translate_row (
   x_target_id		IN NUMBER,
   x_target_name	IN VARCHAR2,
   x_description	IN VARCHAR2,
   x_owner		IN VARCHAR2
);

PROCEDURE load_row (
   x_target_id          IN NUMBER,
   x_active_flag        VARCHAR2,
   x_model_type         VARCHAR2,
   x_data_source_id     NUMBER,
   x_source_field_id    NUMBER,
   x_target_name        VARCHAR2,
   x_description        VARCHAR2,
   x_target_source_id   NUMBER,
   x_owner              IN VARCHAR2,
   x_custom_mode        IN VARCHAR2
);



END AMS_DM_TARGETS_B_PKG;

 

/
