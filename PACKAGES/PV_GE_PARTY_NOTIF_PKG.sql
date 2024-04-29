--------------------------------------------------------
--  DDL for Package PV_GE_PARTY_NOTIF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_GE_PARTY_NOTIF_PKG" AUTHID CURRENT_USER AS
/* $Header: pvxtgpns.pls 115.3 2002/12/10 10:42:10 rdsharma ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_Ge_Party_Notif_PKG
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
          px_party_notification_id   IN OUT NOCOPY NUMBER,
          p_notification_id    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_partner_id    NUMBER,
          p_recipient_user_id    NUMBER,
          p_notif_for_entity_id    NUMBER,
          p_arc_notif_for_entity_code    VARCHAR2,
          p_notif_type_code    VARCHAR2,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER);





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
          p_party_notification_id    NUMBER,
          p_notification_id    NUMBER,
          p_object_version_number   IN NUMBER,
          p_partner_id    NUMBER,
          p_recipient_user_id    NUMBER,
          p_notif_for_entity_id    NUMBER,
          p_arc_notif_for_entity_code    VARCHAR2,
          p_notif_type_code    VARCHAR2,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER);





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
    p_party_notification_id  NUMBER,
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
    p_party_notification_id  NUMBER,
    p_object_version_number  NUMBER);


END PV_Ge_Party_Notif_PKG;

 

/
