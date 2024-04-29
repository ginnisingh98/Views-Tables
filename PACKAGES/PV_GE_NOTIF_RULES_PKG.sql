--------------------------------------------------------
--  DDL for Package PV_GE_NOTIF_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_GE_NOTIF_RULES_PKG" AUTHID CURRENT_USER AS
/* $Header: pvxtgnrs.pls 115.3 2002/12/10 10:24:26 anubhavk ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_Ge_Notif_Rules_PKG
-- Purpose
--
-- History
--  15 Nov 2002  anubhavk created
--  19 Nov 2002 anubhavk  Updated - For NOCOPY by running nocopy.sh
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
          px_notif_rule_id   IN OUT NOCOPY NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_arc_notif_for_entity_code    VARCHAR2,
          p_notif_for_entity_id    NUMBER,
          p_wf_item_type_code    VARCHAR2,
          p_notif_type_code    VARCHAR2,
          p_active_flag    VARCHAR2,
          p_repeat_freq_unit    VARCHAR2,
          p_repeat_freq_value    NUMBER,
          p_send_notif_before_unit    VARCHAR2,
          p_send_notif_before_value    NUMBER,
          p_send_notif_after_unit    VARCHAR2,
          p_send_notif_after_value    NUMBER,
          p_repeat_until_unit    VARCHAR2,
          p_repeat_until_value    NUMBER,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          p_notif_name    VARCHAR2,
          p_notif_content    VARCHAR2,
          p_notif_desc    VARCHAR2
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
          p_notif_rule_id    NUMBER,
          p_object_version_number   IN NUMBER,
          p_arc_notif_for_entity_code    VARCHAR2,
          p_notif_for_entity_id    NUMBER,
          p_wf_item_type_code    VARCHAR2,
          p_notif_type_code    VARCHAR2,
          p_active_flag    VARCHAR2,
          p_repeat_freq_unit    VARCHAR2,
          p_repeat_freq_value    NUMBER,
          p_send_notif_before_unit    VARCHAR2,
          p_send_notif_before_value    NUMBER,
          p_send_notif_after_unit    VARCHAR2,
          p_send_notif_after_value    NUMBER,
          p_repeat_until_unit    VARCHAR2,
          p_repeat_until_value    NUMBER,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          p_notif_name    VARCHAR2,
          p_notif_content    VARCHAR2,
          p_notif_desc    VARCHAR2
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
    p_notif_rule_id  NUMBER,
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
    p_notif_rule_id  NUMBER,
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

END PV_Ge_Notif_Rules_PKG;

 

/
