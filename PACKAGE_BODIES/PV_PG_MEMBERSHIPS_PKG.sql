--------------------------------------------------------
--  DDL for Package Body PV_PG_MEMBERSHIPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_PG_MEMBERSHIPS_PKG" as
/* $Header: pvxtmemb.pls 120.1 2005/10/24 09:36:12 dgottlie noship $ */
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


G_PKG_NAME CONSTANT VARCHAR2(30):= 'PV_Pg_Memberships_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxtmemb.pls';




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
	  p_attribute15	VARCHAR2)

 IS
   x_rowid    VARCHAR2(30);


BEGIN


   px_object_version_number := nvl(px_object_version_number, 1);


   INSERT INTO pv_pg_memberships(
           membership_id,
           object_version_number,
           partner_id,
           program_id,
           start_date,
           original_end_date,
           actual_end_date,
           membership_status_code,
           status_reason_code,
           enrl_request_id,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login,
	   attribute1,
	   attribute2,
	   attribute3,
	   attribute4,
	   attribute5,
	   attribute6,
	   attribute7,
	   attribute8,
	   attribute9,
	   attribute10,
	   attribute11,
	   attribute12,
	   attribute13,
	   attribute14,
	   attribute15
   ) VALUES (
           DECODE( px_membership_id, FND_API.G_MISS_NUM, NULL, px_membership_id),
           DECODE( px_object_version_number, FND_API.G_MISS_NUM, 1, px_object_version_number),
           DECODE( p_partner_id, FND_API.G_MISS_NUM, NULL, p_partner_id),
           DECODE( p_program_id, FND_API.G_MISS_NUM, NULL, p_program_id),
           DECODE( p_start_date, FND_API.G_MISS_DATE, NULL, p_start_date),
           DECODE( p_original_end_date, FND_API.G_MISS_DATE, NULL, p_original_end_date),
           DECODE( p_actual_end_date, FND_API.G_MISS_DATE, NULL, p_actual_end_date),
           DECODE( p_membership_status_code, FND_API.g_miss_char, NULL, p_membership_status_code),
           DECODE( p_status_reason_code, FND_API.g_miss_char, NULL, p_status_reason_code),
           DECODE( p_enrl_request_id, FND_API.G_MISS_NUM, NULL, p_enrl_request_id),
           DECODE( p_created_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_created_by),
           DECODE( p_creation_date, FND_API.G_MISS_DATE, SYSDATE, p_creation_date),
           DECODE( p_last_updated_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_last_updated_by),
           DECODE( p_last_update_date, FND_API.G_MISS_DATE, SYSDATE, p_last_update_date),
           DECODE( p_last_update_login, FND_API.G_MISS_NUM, FND_GLOBAL.CONC_LOGIN_ID, p_last_update_login),
	   DECODE( p_attribute1, FND_API.G_MISS_CHAR, NULL, p_attribute1),
	   DECODE( p_attribute2, FND_API.G_MISS_CHAR, NULL, p_attribute2),
	   DECODE( p_attribute3, FND_API.G_MISS_CHAR, NULL, p_attribute3),
	   DECODE( p_attribute4, FND_API.G_MISS_CHAR, NULL, p_attribute4),
	   DECODE( p_attribute5, FND_API.G_MISS_CHAR, NULL, p_attribute5),
	   DECODE( p_attribute6, FND_API.G_MISS_CHAR, NULL, p_attribute6),
	   DECODE( p_attribute7, FND_API.G_MISS_CHAR, NULL, p_attribute7),
	   DECODE( p_attribute8, FND_API.G_MISS_CHAR, NULL, p_attribute8),
	   DECODE( p_attribute9, FND_API.G_MISS_CHAR, NULL, p_attribute9),
	   DECODE( p_attribute10, FND_API.G_MISS_CHAR, NULL, p_attribute10),
	   DECODE( p_attribute11, FND_API.G_MISS_CHAR, NULL, p_attribute11),
	   DECODE( p_attribute12, FND_API.G_MISS_CHAR, NULL, p_attribute12),
	   DECODE( p_attribute13, FND_API.G_MISS_CHAR, NULL, p_attribute13),
	   DECODE( p_attribute14, FND_API.G_MISS_CHAR, NULL, p_attribute14),
	   DECODE( p_attribute15, FND_API.G_MISS_CHAR, NULL, p_attribute15));

END Insert_Row;




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
	  p_attribute15	VARCHAR2)

 IS
 BEGIN
    Update pv_pg_memberships
    SET
              membership_id = DECODE( p_membership_id, null, membership_id, FND_API.G_MISS_NUM, null, p_membership_id),
            object_version_number = nvl(p_object_version_number,0) + 1 ,
              partner_id = DECODE( p_partner_id, null, partner_id, FND_API.G_MISS_NUM, null, p_partner_id),
              program_id = DECODE( p_program_id, null, program_id, FND_API.G_MISS_NUM, null, p_program_id),
              start_date = DECODE( p_start_date, null, start_date, FND_API.G_MISS_DATE, null, p_start_date),
              original_end_date = DECODE( p_original_end_date, null, original_end_date, FND_API.G_MISS_DATE, null, p_original_end_date),
              actual_end_date = DECODE( p_actual_end_date, null, actual_end_date, FND_API.G_MISS_DATE, null, p_actual_end_date),
              membership_status_code = DECODE( p_membership_status_code, null, membership_status_code, FND_API.g_miss_char, null, p_membership_status_code),
              status_reason_code = DECODE( p_status_reason_code, null, status_reason_code, FND_API.g_miss_char, null, p_status_reason_code),
              enrl_request_id = DECODE( p_enrl_request_id, null, enrl_request_id, FND_API.G_MISS_NUM, null, p_enrl_request_id),
              last_updated_by = DECODE( p_last_updated_by, null, last_updated_by, FND_API.G_MISS_NUM, null, p_last_updated_by),
              last_update_date = DECODE( p_last_update_date, null, last_update_date, FND_API.G_MISS_DATE, null, p_last_update_date),
              last_update_login = DECODE( p_last_update_login, null, last_update_login, FND_API.G_MISS_NUM, null, p_last_update_login),
	      attribute1 = DECODE( p_attribute1, null, attribute1, FND_API.G_MISS_NUM, null, p_attribute1),
	      attribute2 = DECODE( p_attribute2, null, attribute2, FND_API.G_MISS_NUM, null, p_attribute2),
	      attribute3 = DECODE( p_attribute3, null, attribute3, FND_API.G_MISS_NUM, null, p_attribute3),
	      attribute4 = DECODE( p_attribute4, null, attribute4, FND_API.G_MISS_NUM, null, p_attribute4),
	      attribute5 = DECODE( p_attribute5, null, attribute5, FND_API.G_MISS_NUM, null, p_attribute5),
	      attribute6 = DECODE( p_attribute6, null, attribute6, FND_API.G_MISS_NUM, null, p_attribute6),
	      attribute7 = DECODE( p_attribute7, null, attribute7, FND_API.G_MISS_NUM, null, p_attribute7),
	      attribute8 = DECODE( p_attribute8, null, attribute8, FND_API.G_MISS_NUM, null, p_attribute8),
	      attribute9 = DECODE( p_attribute9, null, attribute9, FND_API.G_MISS_NUM, null, p_attribute9),
	      attribute10 = DECODE( p_attribute10, null, attribute10, FND_API.G_MISS_NUM, null, p_attribute10),
	      attribute11 = DECODE( p_attribute11, null, attribute11, FND_API.G_MISS_NUM, null, p_attribute11),
	      attribute12 = DECODE( p_attribute12, null, attribute12, FND_API.G_MISS_NUM, null, p_attribute12),
	      attribute13 = DECODE( p_attribute13, null, attribute13, FND_API.G_MISS_NUM, null, p_attribute13),
	      attribute14 = DECODE( p_attribute14, null, attribute14, FND_API.G_MISS_NUM, null, p_attribute14),
	      attribute15 = DECODE( p_attribute15, null, attribute15, FND_API.G_MISS_NUM, null, p_attribute15)
   WHERE membership_id = p_membership_id
   AND   object_version_number = p_object_version_number;


   IF (SQL%NOTFOUND) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


END Update_Row;




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
    p_object_version_number  NUMBER)
 IS
 BEGIN
   DELETE FROM pv_pg_memberships
    WHERE membership_id = p_membership_id
    AND object_version_number = p_object_version_number;
   If (SQL%NOTFOUND) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   End If;
 END Delete_Row ;





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
    p_object_version_number  NUMBER)
 IS
   CURSOR C IS
        SELECT *
         FROM pv_pg_memberships
        WHERE membership_id =  p_membership_id
        AND object_version_number = p_object_version_number
        FOR UPDATE OF membership_id NOWAIT;
   Recinfo C%ROWTYPE;
 BEGIN

   OPEN c;
   FETCH c INTO Recinfo;
   IF (c%NOTFOUND) THEN
      CLOSE c;
      AMS_Utility_PVT.error_message ('AMS_API_RECORD_NOT_FOUND');
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c;
END Lock_Row;



END PV_Pg_Memberships_PKG;

/
