--------------------------------------------------------
--  DDL for Package AMS_DM_TARGET_VALUES_B_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_DM_TARGET_VALUES_B_PKG" AUTHID CURRENT_USER AS
/* $Header: amstdtvs.pls 115.5 2003/03/07 03:54:26 choang noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_DM_TARGET_VALUES_B_PKG
-- Purpose
--
-- History
-- 08-Oct-2002 nyostos  Added value_condition column
-- 16-Oct-2002 choang   Added target_operator and range_value, replacing value_condition
-- 06-Mar-2003 choang   Added x_custom_mode to load_row for bug 2819067.
--
-- NOTE
--
-- End of Comments
-- ===============================================================

PROCEDURE Insert_Row(
         px_target_value_id         IN OUT NOCOPY NUMBER,
         p_last_update_date         DATE,
         p_last_updated_by          NUMBER,
         p_creation_date            DATE,
         p_created_by               NUMBER,
         p_last_update_login        NUMBER,
         px_object_version_number   IN OUT NOCOPY NUMBER,
         p_target_id                NUMBER,
         p_target_value             VARCHAR2,
         p_target_operator          IN VARCHAR2,
         p_range_value              IN VARCHAR2,
         p_description              VARCHAR2);

PROCEDURE Update_Row(
         p_target_value_id          NUMBER,
         p_last_update_date         DATE,
         p_last_updated_by          NUMBER,
         p_last_update_login        NUMBER,
         p_object_version_number    NUMBER,
         p_target_id                NUMBER,
         p_target_value             VARCHAR2,
         p_target_operator          IN VARCHAR2,
         p_range_value              IN VARCHAR2,
         p_description              VARCHAR2);

PROCEDURE Delete_Row(
         p_TARGET_VALUE_ID  NUMBER);

PROCEDURE Lock_Row(
         p_target_value_id          NUMBER,
         p_last_update_date         DATE,
         p_last_updated_by          NUMBER,
         p_creation_date            DATE,
         p_created_by               NUMBER,
         p_last_update_login        NUMBER,
         p_object_version_number    NUMBER,
         p_target_id                NUMBER,
         p_target_value             VARCHAR2);

PROCEDURE add_language;

PROCEDURE translate_row (
         x_target_value_id IN NUMBER,
         x_description  IN VARCHAR2,
         x_owner     IN VARCHAR2
);

PROCEDURE load_row (
         x_target_value_id IN NUMBER,
         x_target_id       IN NUMBER,
         x_target_value    VARCHAR2,
         x_target_operator IN VARCHAR2,
         x_range_value     IN VARCHAR2,
         x_description     VARCHAR2,
         x_owner           IN VARCHAR2,
         x_custom_mode     IN VARCHAR2
);


END AMS_DM_TARGET_VALUES_B_PKG;

 

/
