--------------------------------------------------------
--  DDL for Package PV_GE_PTNR_RESPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_GE_PTNR_RESPS_PKG" AUTHID CURRENT_USER AS
/* $Header: pvxtgprs.pls 115.2 2003/11/18 22:51:22 ktsao noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_Ge_Ptnr_Resps_PKG
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
        px_ptnr_resp_id   IN OUT NOCOPY NUMBER,
        p_partner_id    NUMBER,
        p_user_role_code    VARCHAR2,
        p_program_id    NUMBER,
        p_responsibility_id    NUMBER,
        p_source_resp_map_rule_id    NUMBER,
        p_resp_type_code VARCHAR2,
        px_object_version_number   IN OUT NOCOPY NUMBER,
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
        p_ptnr_resp_id    NUMBER,
        p_partner_id    NUMBER,
        p_user_role_code    VARCHAR2,
        p_program_id    NUMBER,
        p_responsibility_id    NUMBER,
        p_source_resp_map_rule_id    NUMBER,
        p_resp_type_code VARCHAR2,
        p_object_version_number   IN NUMBER,
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
  p_ptnr_resp_id  NUMBER,
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
  p_ptnr_resp_id  NUMBER,
  p_object_version_number  NUMBER);


END PV_Ge_Ptnr_Resps_PKG;

 

/
