--------------------------------------------------------
--  DDL for Package Body AMS_ACT_CONTACT_POINTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_ACT_CONTACT_POINTS_PKG" as
/* $Header: amstconb.pls 120.0 2005/05/31 17:56:32 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_ACT_CONTACT_POINTS_PKG
-- Purpose
--
-- History
--     20-may-2005    musman	  Added contact_point_value_id column for webadi collaboration script usage
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_ACT_CONTACT_POINTS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amstconb.pls';


----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createInsertBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Insert_Row(
          px_contact_point_id   IN OUT NOCOPY NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_arc_contact_used_by    VARCHAR2,
          p_act_contact_used_by_id    NUMBER,
          p_contact_point_type    VARCHAR2,
          p_contact_point_value    VARCHAR2,
          p_city    VARCHAR2,
          p_country    NUMBER,
          p_zipcode    VARCHAR2,
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
          p_attribute15    VARCHAR2
	  ,p_contact_point_value_id NUMBER
          )

 IS
   x_rowid    VARCHAR2(30);


BEGIN


   px_object_version_number := 1;


   INSERT INTO AMS_ACT_CONTACT_POINTS(
           contact_point_id,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           object_version_number,
           arc_contact_used_by,
           act_contact_used_by_id,
           contact_point_type,
           contact_point_value,
           city,
           country,
           zipcode,
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
	   attribute15,
	   contact_point_value_id
   ) VALUES (
           DECODE( px_contact_point_id, FND_API.g_miss_num, NULL, px_contact_point_id),
           DECODE( p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date),
           DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by),
           DECODE( p_creation_date, FND_API.g_miss_date, NULL, p_creation_date),
           DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by),
           DECODE( p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login),
           px_object_version_number, -- object version_number is always 1 when created
           DECODE( p_arc_contact_used_by, FND_API.g_miss_char, NULL, p_arc_contact_used_by),
           DECODE( p_act_contact_used_by_id, FND_API.g_miss_num, NULL, p_act_contact_used_by_id),
           DECODE( p_contact_point_type, FND_API.g_miss_char, NULL, p_contact_point_type),
           DECODE( p_contact_point_value, FND_API.g_miss_char, NULL, p_contact_point_value),
           DECODE( p_city, FND_API.g_miss_char, NULL, p_city),
           DECODE( p_country, FND_API.g_miss_num, NULL, p_country),
           DECODE( p_zipcode, FND_API.g_miss_char, NULL, p_zipcode),
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
           DECODE( p_attribute15, FND_API.g_miss_char, NULL, p_attribute15),
           DECODE( p_contact_point_value_id, FND_API.g_miss_num, NULL, p_contact_point_value_id));
END Insert_Row;


----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createUpdateBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Update_Row(
          p_contact_point_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_arc_contact_used_by    VARCHAR2,
          p_act_contact_used_by_id    NUMBER,
          p_contact_point_type    VARCHAR2,
          p_contact_point_value    VARCHAR2,
          p_city    VARCHAR2,
          p_country    NUMBER,
          p_zipcode    VARCHAR2,
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
          p_attribute15    VARCHAR2,
	  p_contact_point_value_id NUMBER)

 IS
 BEGIN


    Update AMS_ACT_CONTACT_POINTS
    SET
              contact_point_id = DECODE( p_contact_point_id, FND_API.g_miss_num, contact_point_id, p_contact_point_id),
              last_update_date = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
              last_updated_by = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
              last_update_login = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
              object_version_number = object_version_number + 1, -- always increment the object version Number by 1
              arc_contact_used_by = DECODE( p_arc_contact_used_by, FND_API.g_miss_char, arc_contact_used_by, p_arc_contact_used_by),
              act_contact_used_by_id = DECODE( p_act_contact_used_by_id, FND_API.g_miss_num, act_contact_used_by_id, p_act_contact_used_by_id),
              contact_point_type = DECODE( p_contact_point_type, FND_API.g_miss_char, contact_point_type, p_contact_point_type),
              contact_point_value = DECODE( p_contact_point_value, FND_API.g_miss_char, contact_point_value, p_contact_point_value),
              city = DECODE( p_city, FND_API.g_miss_char, city, p_city),
              country = DECODE( p_country, FND_API.g_miss_num, country, p_country),
              zipcode = DECODE( p_zipcode, FND_API.g_miss_char, zipcode, p_zipcode),
              attribute_category = DECODE( p_attribute_category, FND_API.g_miss_char, attribute_category, p_attribute_category),
              attribute1 = DECODE( p_attribute1, FND_API.g_miss_char, attribute1, p_attribute1),
              attribute2 = DECODE( p_attribute2, FND_API.g_miss_char, attribute2, p_attribute2),
              attribute3 = DECODE( p_attribute3, FND_API.g_miss_char, attribute3, p_attribute3),
              attribute4 = DECODE( p_attribute4, FND_API.g_miss_char, attribute4, p_attribute4),
              attribute5 = DECODE( p_attribute5, FND_API.g_miss_char, attribute5, p_attribute5),
              attribute6 = DECODE( p_attribute6, FND_API.g_miss_char, attribute6, p_attribute6),
              attribute7 = DECODE( p_attribute7, FND_API.g_miss_char, attribute7, p_attribute7),
              attribute8 = DECODE( p_attribute8, FND_API.g_miss_char, attribute8, p_attribute8),
              attribute9 = DECODE( p_attribute9, FND_API.g_miss_char, attribute9, p_attribute9),
              attribute10 = DECODE( p_attribute10, FND_API.g_miss_char, attribute10, p_attribute10),
              attribute11 = DECODE( p_attribute11, FND_API.g_miss_char, attribute11, p_attribute11),
              attribute12 = DECODE( p_attribute12, FND_API.g_miss_char, attribute12, p_attribute12),
              attribute13 = DECODE( p_attribute13, FND_API.g_miss_char, attribute13, p_attribute13),
              attribute14 = DECODE( p_attribute14, FND_API.g_miss_char, attribute14, p_attribute14),
              attribute15 = DECODE( p_attribute15, FND_API.g_miss_char, attribute15, p_attribute15),
	      contact_point_value_id = DECODE( p_contact_point_value_id, FND_API.g_miss_num, contact_point_value_id, p_contact_point_value_id)
   WHERE CONTACT_POINT_ID = p_CONTACT_POINT_ID
   AND   object_version_number = p_object_version_number;

   IF (SQL%NOTFOUND) THEN
RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
END Update_Row;


----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createDeleteBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Delete_Row(
    p_CONTACT_POINT_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM AMS_ACT_CONTACT_POINTS
    WHERE CONTACT_POINT_ID = p_CONTACT_POINT_ID;
   If (SQL%NOTFOUND) then
RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   End If;
 END Delete_Row ;



----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createLockBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Lock_Row( p_CONTACT_POINT_ID  NUMBER)

 IS
   CURSOR C IS
        SELECT *
         FROM AMS_ACT_CONTACT_POINTS
        WHERE CONTACT_POINT_ID =  p_CONTACT_POINT_ID
        FOR UPDATE of CONTACT_POINT_ID NOWAIT;
   Recinfo C%ROWTYPE;
 BEGIN
    OPEN c;
    FETCH c INTO Recinfo;
    If (c%NOTFOUND) then
        CLOSE c;
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
    CLOSE C;
END Lock_Row;

END AMS_ACT_CONTACT_POINTS_PKG;

/
