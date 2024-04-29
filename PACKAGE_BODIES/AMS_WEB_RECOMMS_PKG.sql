--------------------------------------------------------
--  DDL for Package Body AMS_WEB_RECOMMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_WEB_RECOMMS_PKG" as
/* $Header: amstwreb.pls 120.1 2005/06/27 05:40:48 appldev ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Web_Recomms_PKG
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


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_Web_Recomms_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amstwreb.pls';




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
          px_web_recomm_id   IN OUT NOCOPY NUMBER,
          p_web_tracking_id    NUMBER,
          p_recomm_object_id    NUMBER,
          p_recomm_type    VARCHAR2,
          p_rule_id    NUMBER,
          p_offer_id    NUMBER,
          p_offer_src_code    VARCHAR2,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_attribute_category    VARCHAR2,
          p_attribute1    VARCHAR2,
          p_attribute2    VARCHAR2,
          p_attribute3    VARCHAR2,
          p_attribute4    VARCHAR2,
          p_attribute5    VARCHAR2,
          p_attribute6    VARCHAR2,
          p_attribute7    VARCHAR2,
          p_attribute8    VARCHAR2,
          p_attribute9    VARCHAR2,
          p_attribute10    VARCHAR2,
          p_attribute11    VARCHAR2,
          p_attribute12    VARCHAR2,
          p_attribute13    VARCHAR2,
          p_attribute14    VARCHAR2,
          p_attribute15    VARCHAR2)

 IS
   x_rowid    VARCHAR2(30);


BEGIN


   px_object_version_number := nvl(px_object_version_number, 1);


   INSERT INTO ams_web_recomms(
           web_recomm_id,
           web_tracking_id,
           recomm_object_id,
           recomm_type,
           rule_id,
           offer_id,
           offer_src_code,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           object_version_number,
           attribute_category,
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
           DECODE( px_web_recomm_id, FND_API.G_MISS_NUM, NULL, px_web_recomm_id),
           DECODE( p_web_tracking_id, FND_API.G_MISS_NUM, NULL, p_web_tracking_id),
           DECODE( p_recomm_object_id, FND_API.G_MISS_NUM, NULL, p_recomm_object_id),
           DECODE( p_recomm_type, FND_API.g_miss_char, NULL, p_recomm_type),
           DECODE( p_rule_id, FND_API.G_MISS_NUM, NULL, p_rule_id),
           DECODE( p_offer_id, FND_API.G_MISS_NUM, NULL, p_offer_id),
           DECODE( p_offer_src_code, FND_API.g_miss_char, NULL, p_offer_src_code),
           DECODE( p_last_update_date, FND_API.G_MISS_DATE, SYSDATE, p_last_update_date),
           DECODE( p_last_updated_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_last_updated_by),
           DECODE( p_creation_date, FND_API.G_MISS_DATE, SYSDATE, p_creation_date),
           DECODE( p_created_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_created_by),
           DECODE( p_last_update_login, FND_API.G_MISS_NUM, FND_GLOBAL.CONC_LOGIN_ID, p_last_update_login),
           DECODE( px_object_version_number, FND_API.G_MISS_NUM, 1, px_object_version_number),
           DECODE( p_attribute_category, FND_API.g_miss_char, NULL, p_attribute_category),
           DECODE( p_attribute1, FND_API.g_miss_char, NULL, p_attribute1),
           DECODE( p_attribute2, FND_API.g_miss_char, NULL, p_attribute2),
           DECODE( p_attribute3, FND_API.g_miss_char, NULL, p_attribute3),
           DECODE( p_attribute4, FND_API.g_miss_char, NULL, p_attribute4),
           DECODE( p_attribute5, FND_API.g_miss_char, NULL, p_attribute5),
           DECODE( p_attribute6, FND_API.g_miss_char, NULL, p_attribute6),
           DECODE( p_attribute7, FND_API.g_miss_char, NULL, p_attribute7),
           DECODE( p_attribute8, FND_API.g_miss_char, NULL, p_attribute8),
           DECODE( p_attribute9, FND_API.g_miss_char, NULL, p_attribute9),
           DECODE( p_attribute10, FND_API.g_miss_char, NULL, p_attribute10),
           DECODE( p_attribute11, FND_API.g_miss_char, NULL, p_attribute11),
           DECODE( p_attribute12, FND_API.g_miss_char, NULL, p_attribute12),
           DECODE( p_attribute13, FND_API.g_miss_char, NULL, p_attribute13),
           DECODE( p_attribute14, FND_API.g_miss_char, NULL, p_attribute14),
           DECODE( p_attribute15, FND_API.g_miss_char, NULL, p_attribute15));

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
          p_web_recomm_id    NUMBER,
          p_web_tracking_id    NUMBER,
          p_recomm_object_id    NUMBER,
          p_recomm_type    VARCHAR2,
          p_rule_id    NUMBER,
          p_offer_id    NUMBER,
          p_offer_src_code    VARCHAR2,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number   IN NUMBER,
          p_attribute_category    VARCHAR2,
          p_attribute1    VARCHAR2,
          p_attribute2    VARCHAR2,
          p_attribute3    VARCHAR2,
          p_attribute4    VARCHAR2,
          p_attribute5    VARCHAR2,
          p_attribute6    VARCHAR2,
          p_attribute7    VARCHAR2,
          p_attribute8    VARCHAR2,
          p_attribute9    VARCHAR2,
          p_attribute10    VARCHAR2,
          p_attribute11    VARCHAR2,
          p_attribute12    VARCHAR2,
          p_attribute13    VARCHAR2,
          p_attribute14    VARCHAR2,
          p_attribute15    VARCHAR2)

 IS
 BEGIN
    Update ams_web_recomms
    SET
              web_recomm_id = DECODE( p_web_recomm_id, null, web_recomm_id, FND_API.G_MISS_NUM, null, p_web_recomm_id),
              web_tracking_id = DECODE( p_web_tracking_id, null, web_tracking_id, FND_API.G_MISS_NUM, null, p_web_tracking_id),
              recomm_object_id = DECODE( p_recomm_object_id, null, recomm_object_id, FND_API.G_MISS_NUM, null, p_recomm_object_id),
              recomm_type = DECODE( p_recomm_type, null, recomm_type, FND_API.g_miss_char, null, p_recomm_type),
              rule_id = DECODE( p_rule_id, null, rule_id, FND_API.G_MISS_NUM, null, p_rule_id),
              offer_id = DECODE( p_offer_id, null, offer_id, FND_API.G_MISS_NUM, null, p_offer_id),
              offer_src_code = DECODE( p_offer_src_code, null, offer_src_code, FND_API.g_miss_char, null, p_offer_src_code),
              last_update_date = DECODE( p_last_update_date, null, last_update_date, FND_API.G_MISS_DATE, null, p_last_update_date),
              last_updated_by = DECODE( p_last_updated_by, null, last_updated_by, FND_API.G_MISS_NUM, null, p_last_updated_by),
              last_update_login = DECODE( p_last_update_login, null, last_update_login, FND_API.G_MISS_NUM, null, p_last_update_login),
            object_version_number = nvl(p_object_version_number,0) + 1 ,
              attribute_category = DECODE( p_attribute_category, null, attribute_category, FND_API.g_miss_char, null, p_attribute_category),
              attribute1 = DECODE( p_attribute1, null, attribute1, FND_API.g_miss_char, null, p_attribute1),
              attribute2 = DECODE( p_attribute2, null, attribute2, FND_API.g_miss_char, null, p_attribute2),
              attribute3 = DECODE( p_attribute3, null, attribute3, FND_API.g_miss_char, null, p_attribute3),
              attribute4 = DECODE( p_attribute4, null, attribute4, FND_API.g_miss_char, null, p_attribute4),
              attribute5 = DECODE( p_attribute5, null, attribute5, FND_API.g_miss_char, null, p_attribute5),
              attribute6 = DECODE( p_attribute6, null, attribute6, FND_API.g_miss_char, null, p_attribute6),
              attribute7 = DECODE( p_attribute7, null, attribute7, FND_API.g_miss_char, null, p_attribute7),
              attribute8 = DECODE( p_attribute8, null, attribute8, FND_API.g_miss_char, null, p_attribute8),
              attribute9 = DECODE( p_attribute9, null, attribute9, FND_API.g_miss_char, null, p_attribute9),
              attribute10 = DECODE( p_attribute10, null, attribute10, FND_API.g_miss_char, null, p_attribute10),
              attribute11 = DECODE( p_attribute11, null, attribute11, FND_API.g_miss_char, null, p_attribute11),
              attribute12 = DECODE( p_attribute12, null, attribute12, FND_API.g_miss_char, null, p_attribute12),
              attribute13 = DECODE( p_attribute13, null, attribute13, FND_API.g_miss_char, null, p_attribute13),
              attribute14 = DECODE( p_attribute14, null, attribute14, FND_API.g_miss_char, null, p_attribute14),
              attribute15 = DECODE( p_attribute15, null, attribute15, FND_API.g_miss_char, null, p_attribute15)
   WHERE web_recomm_id = p_web_recomm_id
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
    p_web_recomm_id  NUMBER,
    p_object_version_number  NUMBER)
 IS
 BEGIN
   DELETE FROM ams_web_recomms
    WHERE web_recomm_id = p_web_recomm_id
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
    p_web_recomm_id  NUMBER,
    p_object_version_number  NUMBER)
 IS
   CURSOR C IS
        SELECT *
         FROM ams_web_recomms
        WHERE web_recomm_id =  p_web_recomm_id
        AND object_version_number = p_object_version_number
        FOR UPDATE OF web_recomm_id NOWAIT;
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



END AMS_Web_Recomms_PKG;

/
