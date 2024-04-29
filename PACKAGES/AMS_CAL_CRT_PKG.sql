--------------------------------------------------------
--  DDL for Package AMS_CAL_CRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_CAL_CRT_PKG" AUTHID CURRENT_USER AS
/* $Header: amstccts.pls 115.3 2003/03/08 14:18:12 cgoyal noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Cal_Crt_PKG
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
          px_criteria_id   IN OUT NOCOPY NUMBER,
          p_object_type_code    VARCHAR2,
          p_custom_setup_id    NUMBER,
          p_activity_type_code    VARCHAR2,
          p_activity_id    NUMBER,
          p_status_id    NUMBER,
          p_priority_id    VARCHAR2,
          p_object_id    NUMBER,
          p_criteria_start_date    DATE,
          p_criteria_end_date    DATE,
          p_criteria_deleted    VARCHAR2,
          p_criteria_enabled    VARCHAR2,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER);





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
          p_criteria_id    NUMBER,
          p_object_type_code    VARCHAR2,
          p_custom_setup_id    NUMBER,
          p_activity_type_code    VARCHAR2,
          p_activity_id    NUMBER,
          p_status_id    NUMBER,
          p_priority_id    VARCHAR2,
          p_object_id    NUMBER,
          p_criteria_start_date    DATE,
          p_criteria_end_date    DATE,
          p_criteria_deleted    VARCHAR2,
          p_criteria_enabled    VARCHAR2,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number   IN NUMBER);





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
    p_criteria_id  NUMBER,
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
    p_criteria_id  NUMBER,
    p_object_version_number  NUMBER);

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           add_language
--   Type
--           Private
--   History
--
--   NOTE
--
-- End of Comments
-- ===============================================================

END AMS_Cal_Crt_PKG;

 

/
