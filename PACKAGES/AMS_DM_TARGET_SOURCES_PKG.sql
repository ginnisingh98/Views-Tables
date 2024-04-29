--------------------------------------------------------
--  DDL for Package AMS_DM_TARGET_SOURCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_DM_TARGET_SOURCES_PKG" AUTHID CURRENT_USER AS
/* $Header: amstdtss.pls 115.2 2003/10/16 20:56:42 choang noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Dm_Target_Sources_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- This Api is generated with Latest version of
-- Rosetta, where g_miss indicates NULL and
-- NULL indicates missing value. Rosetta Version 1.55
-- End of Comments
-- ===============================================================




--  ========================================================
--
--  NAME
--  Insert_Row
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Insert_Row(
          px_target_source_id   IN OUT NOCOPY NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_target_id    NUMBER,
          p_data_source_id    NUMBER);





--  ========================================================
--
--  NAME
--  Update_Row
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Update_Row(
          p_target_source_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number   IN NUMBER,
          p_target_id    NUMBER,
          p_data_source_id    NUMBER);





--  ========================================================
--
--  NAME
--  Delete_Row
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Delete_Row(
    p_target_source_id  NUMBER,
    p_object_version_number  NUMBER);




--  ========================================================
--
--  NAME
--  Lock_Row
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Lock_Row(
    p_target_source_id  NUMBER,
    p_object_version_number  NUMBER);


--  ========================================================
--
--  NAME
--  load_row
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE load_row(
          x_target_source_id   NUMBER,
          x_target_id    NUMBER,
          x_data_source_id   NUMBER,
          x_owner        IN VARCHAR2,
          x_custom_mode  IN VARCHAR2);


END AMS_Dm_Target_Sources_PKG;

 

/
