--------------------------------------------------------
--  DDL for Package Body AMS_CAL_CRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_CAL_CRT_PKG" as
/* $Header: amstcctb.pls 115.4 2003/03/08 14:18:25 cgoyal noship $ */
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


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_Cal_Crt_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amstcctb.pls';




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
AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

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
          px_object_version_number   IN OUT NOCOPY NUMBER)

 IS
   x_rowid    VARCHAR2(30);


BEGIN


   px_object_version_number := nvl(px_object_version_number, 1);


   INSERT INTO ams_calendar_criteria(
           criteria_id,
           object_type_code,
           custom_setup_id,
           activity_type_code,
           activity_id,
           status_id,
           priority_id,
           object_id,
           criteria_start_date,
           criteria_end_date,
           criteria_deleted,
           criteria_enabled,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           object_version_number
   ) VALUES (
           DECODE( px_criteria_id, FND_API.G_MISS_NUM, NULL, px_criteria_id),
           DECODE( p_object_type_code, FND_API.g_miss_char, NULL, p_object_type_code),
           DECODE( p_custom_setup_id, FND_API.G_MISS_NUM, NULL, p_custom_setup_id),
           DECODE( p_activity_type_code, FND_API.g_miss_char, NULL, p_activity_type_code),
           DECODE( p_activity_id, FND_API.G_MISS_NUM, NULL, p_activity_id),
           DECODE( p_status_id, FND_API.G_MISS_NUM, NULL, p_status_id),
           DECODE( p_priority_id, FND_API.g_miss_char, NULL, p_priority_id),
           DECODE( p_object_id, FND_API.G_MISS_NUM, NULL, p_object_id),
           DECODE( p_criteria_start_date, FND_API.G_MISS_DATE, NULL, p_criteria_start_date),
           DECODE( p_criteria_end_date, FND_API.G_MISS_DATE, NULL, p_criteria_end_date),
           'N',
           'Y',
           DECODE( p_last_update_date, FND_API.G_MISS_DATE, SYSDATE, p_last_update_date),
           DECODE( p_last_updated_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_last_updated_by),
           DECODE( p_creation_date, FND_API.G_MISS_DATE, SYSDATE, p_creation_date),
           DECODE( p_created_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_created_by),
           DECODE( p_last_update_login, FND_API.G_MISS_NUM, FND_GLOBAL.CONC_LOGIN_ID, p_last_update_login),
           DECODE( px_object_version_number, FND_API.G_MISS_NUM, 1, px_object_version_number));

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
          p_object_version_number   IN NUMBER)

 IS
 BEGIN
    Update ams_calendar_criteria
    SET
              criteria_id = DECODE( p_criteria_id, null, criteria_id, FND_API.G_MISS_NUM, null, p_criteria_id),
              object_type_code = DECODE( p_object_type_code, null, object_type_code, FND_API.g_miss_char, null, p_object_type_code),
              custom_setup_id = DECODE( p_custom_setup_id, null, custom_setup_id, FND_API.G_MISS_NUM, null, p_custom_setup_id),
              activity_type_code = DECODE( p_activity_type_code, null, activity_type_code, FND_API.g_miss_char, null, p_activity_type_code),
              activity_id = DECODE( p_activity_id, null, activity_id, FND_API.G_MISS_NUM, null, p_activity_id),
              status_id = DECODE( p_status_id, null, status_id, FND_API.G_MISS_NUM, null, p_status_id),
              priority_id = DECODE( p_priority_id, null, priority_id, FND_API.g_miss_char, null, p_priority_id),
              object_id = DECODE( p_object_id, null, object_id, FND_API.G_MISS_NUM, null, p_object_id),
              criteria_start_date = DECODE( p_criteria_start_date, null, criteria_start_date, FND_API.G_MISS_DATE, null, p_criteria_start_date),
              criteria_end_date = DECODE( p_criteria_end_date, null, criteria_end_date, FND_API.G_MISS_DATE, null, p_criteria_end_date),
              criteria_deleted = DECODE( p_criteria_deleted, null, criteria_deleted, FND_API.g_miss_char, null, p_criteria_deleted),
              criteria_enabled = DECODE( p_criteria_enabled, null, criteria_enabled, FND_API.g_miss_char, null, p_criteria_enabled),
              last_update_date = DECODE( p_last_update_date, null, last_update_date, FND_API.G_MISS_DATE, null, p_last_update_date),
              last_updated_by = DECODE( p_last_updated_by, null, last_updated_by, FND_API.G_MISS_NUM, null, p_last_updated_by),
              last_update_login = DECODE( p_last_update_login, null, last_update_login, FND_API.G_MISS_NUM, null, p_last_update_login),
            object_version_number = nvl(p_object_version_number,0) + 1
   WHERE criteria_id = p_criteria_id
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
    p_criteria_id  NUMBER,
    p_object_version_number  NUMBER)
 IS
 BEGIN
   DELETE FROM ams_calendar_criteria
    WHERE criteria_id = p_criteria_id
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
    p_criteria_id  NUMBER,
    p_object_version_number  NUMBER)
 IS
   CURSOR C IS
        SELECT *
         FROM ams_calendar_criteria
        WHERE criteria_id =  p_criteria_id
        AND object_version_number = p_object_version_number
        FOR UPDATE OF criteria_id NOWAIT;
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

END AMS_Cal_Crt_PKG;

/
