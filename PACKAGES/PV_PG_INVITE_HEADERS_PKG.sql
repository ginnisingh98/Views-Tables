--------------------------------------------------------
--  DDL for Package PV_PG_INVITE_HEADERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_PG_INVITE_HEADERS_PKG" AUTHID CURRENT_USER AS
/* $Header: pvxtpihs.pls 120.1 2005/08/29 14:18:16 appldev ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          Pv_Pg_Invite_Headers_PKG
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
          px_invite_header_id   IN OUT NOCOPY NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_qp_list_header_id    VARCHAR2,
          p_invite_type_code    VARCHAR2,
          p_invite_for_program_id    NUMBER,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          p_partner_id    NUMBER,
          p_invite_end_date    DATE,
          p_order_header_id    NUMBER,
          p_invited_by_partner_id    NUMBER,
          p_EMAIL_CONTENT    VARCHAR2,
	  p_trxn_extension_id NUMBER
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
          p_invite_header_id    NUMBER,
          p_object_version_number   IN NUMBER,
          p_qp_list_header_id    VARCHAR2,
          p_invite_type_code    VARCHAR2,
          p_invite_for_program_id    NUMBER,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          p_partner_id    NUMBER,
          p_invite_end_date    DATE,
          p_order_header_id    NUMBER,
          p_invited_by_partner_id    NUMBER,
          p_EMAIL_CONTENT    VARCHAR2,
	  p_trxn_extension_id NUMBER
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
    p_invite_header_id  NUMBER,
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
    p_invite_header_id  NUMBER,
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

END Pv_Pg_Invite_Headers_PKG;

 

/
