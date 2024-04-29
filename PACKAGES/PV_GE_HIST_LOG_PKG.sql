--------------------------------------------------------
--  DDL for Package PV_GE_HIST_LOG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_GE_HIST_LOG_PKG" AUTHID CURRENT_USER AS
/* $Header: pvxtghls.pls 115.4 2003/08/08 23:50:52 ktsao ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_Ge_Hist_Log_PKG
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
        px_entity_history_log_id   IN OUT NOCOPY NUMBER,
        px_object_version_number   IN OUT NOCOPY NUMBER,
        p_arc_history_for_entity_code    VARCHAR2,
        p_history_for_entity_id    NUMBER,
        p_message_code    VARCHAR2,
        p_history_category_code    VARCHAR2,
        p_created_by    NUMBER,
        p_creation_date    DATE,
        p_last_updated_by    NUMBER,
        p_last_update_date    DATE,
        p_last_update_login    NUMBER,
        p_partner_id    NUMBER,
        p_access_level_flag    VARCHAR2,
        p_interaction_level    NUMBER,
        p_COMMENTS    VARCHAR2
);





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
        p_entity_history_log_id    NUMBER,
        p_object_version_number   IN NUMBER,
        p_arc_history_for_entity_code    VARCHAR2,
        p_history_for_entity_id    NUMBER,
        p_message_code    VARCHAR2,
        p_history_category_code    VARCHAR2,
        p_last_updated_by    NUMBER,
        p_last_update_date    DATE,
        p_last_update_login    NUMBER,
        p_partner_id    NUMBER,
        p_access_level_flag    VARCHAR2,
        p_interaction_level    NUMBER,
        p_COMMENTS    VARCHAR2
);





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
  p_entity_history_log_id  NUMBER,
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
  p_entity_history_log_id  NUMBER,
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

PROCEDURE Add_Language;

END PV_Ge_Hist_Log_PKG;

 

/
