--------------------------------------------------------
--  DDL for Package PV_PG_MEMBERSHIPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_PG_MEMBERSHIPS_PKG" AUTHID CURRENT_USER AS
/* $Header: pvxtmems.pls 120.1 2005/10/24 09:35:47 dgottlie noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_Pg_Memberships_PKG
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
          px_membership_id   IN OUT NOCOPY NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_partner_id    NUMBER,
          p_program_id    NUMBER,
          p_start_date    DATE,
          p_original_end_date    DATE,
          p_actual_end_date    DATE,
          p_membership_status_code    VARCHAR2,
          p_status_reason_code    VARCHAR2,
          p_enrl_request_id    NUMBER,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
	  p_attribute1	VARCHAR2,
	  p_attribute2	VARCHAR2,
	  p_attribute3	VARCHAR2,
	  p_attribute4	VARCHAR2,
	  p_attribute5	VARCHAR2,
	  p_attribute6	VARCHAR2,
	  p_attribute7	VARCHAR2,
	  p_attribute8	VARCHAR2,
	  p_attribute9	VARCHAR2,
	  p_attribute10	VARCHAR2,
	  p_attribute11	VARCHAR2,
	  p_attribute12	VARCHAR2,
	  p_attribute13	VARCHAR2,
	  p_attribute14	VARCHAR2,
	  p_attribute15	VARCHAR2);





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
          p_membership_id    NUMBER,
          p_object_version_number   IN NUMBER,
          p_partner_id    NUMBER,
          p_program_id    NUMBER,
          p_start_date    DATE,
          p_original_end_date    DATE,
          p_actual_end_date    DATE,
          p_membership_status_code    VARCHAR2,
          p_status_reason_code    VARCHAR2,
          p_enrl_request_id    NUMBER,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
	  p_attribute1	VARCHAR2,
	  p_attribute2	VARCHAR2,
	  p_attribute3	VARCHAR2,
	  p_attribute4	VARCHAR2,
	  p_attribute5	VARCHAR2,
	  p_attribute6	VARCHAR2,
	  p_attribute7	VARCHAR2,
	  p_attribute8	VARCHAR2,
	  p_attribute9	VARCHAR2,
	  p_attribute10	VARCHAR2,
	  p_attribute11	VARCHAR2,
	  p_attribute12	VARCHAR2,
	  p_attribute13	VARCHAR2,
	  p_attribute14	VARCHAR2,
	  p_attribute15	VARCHAR2);





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
    p_membership_id  NUMBER,
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
    p_membership_id  NUMBER,
    p_object_version_number  NUMBER);


END PV_Pg_Memberships_PKG;

 

/
