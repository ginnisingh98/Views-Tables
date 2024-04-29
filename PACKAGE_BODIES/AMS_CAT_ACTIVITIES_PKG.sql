--------------------------------------------------------
--  DDL for Package Body AMS_CAT_ACTIVITIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_CAT_ACTIVITIES_PKG" as
/* $Header: amstcacb.pls 115.4 2002/12/27 11:38:08 cgoyal ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_CAT_ACTIVITIES_PKG
-- Purpose
--
-- History
--       30-Jan-2001    abhola    Created
--       05-Nov-2001    musman    Commented out the reference to security_group_id
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_CAT_ACTIVITIES_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amstcacb.pls';


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
AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Insert_Row(
          px_cat_activity_id   IN OUT NOCOPY NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_category_id    NUMBER,
          p_activity_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          -- p_security_group_id    NUMBER,
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


   px_object_version_number := 1;


   INSERT INTO AMS_CAT_ACTIVITIES(
           cat_activity_id,
           object_version_number,
           category_id,
           activity_id,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           --security_group_id,
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
           DECODE( px_cat_activity_id, FND_API.g_miss_num, NULL, px_cat_activity_id),
           DECODE( px_object_version_number, FND_API.g_miss_num, NULL, px_object_version_number),
           DECODE( p_category_id, FND_API.g_miss_num, NULL, p_category_id),
           DECODE( p_activity_id, FND_API.g_miss_num, NULL, p_activity_id),
           DECODE( p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date),
           DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by),
           DECODE( p_creation_date, FND_API.g_miss_date, NULL, p_creation_date),
           DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by),
           DECODE( p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login),
           --DECODE( p_security_group_id, FND_API.g_miss_num, NULL, p_security_group_id),
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
          p_cat_activity_id    NUMBER,
          p_object_version_number    NUMBER,
          p_category_id    NUMBER,
          p_activity_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          --p_security_group_id    NUMBER,
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
    Update AMS_CAT_ACTIVITIES
    SET
              cat_activity_id = DECODE( p_cat_activity_id, FND_API.g_miss_num, cat_activity_id, p_cat_activity_id),
              object_version_number = DECODE( p_object_version_number, FND_API.g_miss_num, object_version_number, p_object_version_number),
              category_id = DECODE( p_category_id, FND_API.g_miss_num, category_id, p_category_id),
              activity_id = DECODE( p_activity_id, FND_API.g_miss_num, activity_id, p_activity_id),
              last_update_date = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
              last_updated_by = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
              creation_date = DECODE( p_creation_date, FND_API.g_miss_date, creation_date, p_creation_date),
              created_by = DECODE( p_created_by, FND_API.g_miss_num, created_by, p_created_by),
              last_update_login = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
              --security_group_id = DECODE( p_security_group_id, FND_API.g_miss_num, security_group_id, p_security_group_id),
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
              attribute15 = DECODE( p_attribute15, FND_API.g_miss_char, attribute15, p_attribute15)
   WHERE CAT_ACTIVITY_ID = p_CAT_ACTIVITY_ID
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
    p_CAT_ACTIVITY_ID  NUMBER,
    p_object_version_number NUMBER)
 IS
 BEGIN
   DELETE FROM AMS_CAT_ACTIVITIES
    WHERE CAT_ACTIVITY_ID = p_CAT_ACTIVITY_ID
	 AND object_version_number = p_object_version_number;
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
PROCEDURE Lock_Row(
          p_cat_activity_id    NUMBER,
          p_object_version_number    NUMBER,
          p_category_id    NUMBER,
          p_activity_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          --p_security_group_id    NUMBER,
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
   CURSOR C IS
        SELECT *
         FROM AMS_CAT_ACTIVITIES
        WHERE CAT_ACTIVITY_ID =  p_CAT_ACTIVITY_ID
        FOR UPDATE of CAT_ACTIVITY_ID NOWAIT;
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
    IF (
           (      Recinfo.cat_activity_id = p_cat_activity_id)
       AND (    ( Recinfo.object_version_number = p_object_version_number)
            OR (    ( Recinfo.object_version_number IS NULL )
                AND (  p_object_version_number IS NULL )))
       AND (    ( Recinfo.category_id = p_category_id)
            OR (    ( Recinfo.category_id IS NULL )
                AND (  p_category_id IS NULL )))
       AND (    ( Recinfo.activity_id = p_activity_id)
            OR (    ( Recinfo.activity_id IS NULL )
                AND (  p_activity_id IS NULL )))
       AND (    ( Recinfo.last_update_date = p_last_update_date)
            OR (    ( Recinfo.last_update_date IS NULL )
                AND (  p_last_update_date IS NULL )))
       AND (    ( Recinfo.last_updated_by = p_last_updated_by)
            OR (    ( Recinfo.last_updated_by IS NULL )
                AND (  p_last_updated_by IS NULL )))
       AND (    ( Recinfo.creation_date = p_creation_date)
            OR (    ( Recinfo.creation_date IS NULL )
                AND (  p_creation_date IS NULL )))
       AND (    ( Recinfo.created_by = p_created_by)
            OR (    ( Recinfo.created_by IS NULL )
                AND (  p_created_by IS NULL )))
       AND (    ( Recinfo.last_update_login = p_last_update_login)
            OR (    ( Recinfo.last_update_login IS NULL )
                AND (  p_last_update_login IS NULL )))
       /*
       --AND (    ( Recinfo.security_group_id = p_security_group_id)
       --     OR (    ( Recinfo.security_group_id IS NULL )
       --        AND (  p_security_group_id IS NULL )))
       */
       AND (    ( Recinfo.attribute_category = p_attribute_category)
            OR (    ( Recinfo.attribute_category IS NULL )
                AND (  p_attribute_category IS NULL )))
       AND (    ( Recinfo.attribute1 = p_attribute1)
            OR (    ( Recinfo.attribute1 IS NULL )
                AND (  p_attribute1 IS NULL )))
       AND (    ( Recinfo.attribute2 = p_attribute2)
            OR (    ( Recinfo.attribute2 IS NULL )
                AND (  p_attribute2 IS NULL )))
       AND (    ( Recinfo.attribute3 = p_attribute3)
            OR (    ( Recinfo.attribute3 IS NULL )
                AND (  p_attribute3 IS NULL )))
       AND (    ( Recinfo.attribute4 = p_attribute4)
            OR (    ( Recinfo.attribute4 IS NULL )
                AND (  p_attribute4 IS NULL )))
       AND (    ( Recinfo.attribute5 = p_attribute5)
            OR (    ( Recinfo.attribute5 IS NULL )
                AND (  p_attribute5 IS NULL )))
       AND (    ( Recinfo.attribute6 = p_attribute6)
            OR (    ( Recinfo.attribute6 IS NULL )
                AND (  p_attribute6 IS NULL )))
       AND (    ( Recinfo.attribute7 = p_attribute7)
            OR (    ( Recinfo.attribute7 IS NULL )
                AND (  p_attribute7 IS NULL )))
       AND (    ( Recinfo.attribute8 = p_attribute8)
            OR (    ( Recinfo.attribute8 IS NULL )
                AND (  p_attribute8 IS NULL )))
       AND (    ( Recinfo.attribute9 = p_attribute9)
            OR (    ( Recinfo.attribute9 IS NULL )
                AND (  p_attribute9 IS NULL )))
       AND (    ( Recinfo.attribute10 = p_attribute10)
            OR (    ( Recinfo.attribute10 IS NULL )
                AND (  p_attribute10 IS NULL )))
       AND (    ( Recinfo.attribute11 = p_attribute11)
            OR (    ( Recinfo.attribute11 IS NULL )
                AND (  p_attribute11 IS NULL )))
       AND (    ( Recinfo.attribute12 = p_attribute12)
            OR (    ( Recinfo.attribute12 IS NULL )
                AND (  p_attribute12 IS NULL )))
       AND (    ( Recinfo.attribute13 = p_attribute13)
            OR (    ( Recinfo.attribute13 IS NULL )
                AND (  p_attribute13 IS NULL )))
       AND (    ( Recinfo.attribute14 = p_attribute14)
            OR (    ( Recinfo.attribute14 IS NULL )
                AND (  p_attribute14 IS NULL )))
       AND (    ( Recinfo.attribute15 = p_attribute15)
            OR (    ( Recinfo.attribute15 IS NULL )
                AND (  p_attribute15 IS NULL )))
       ) THEN
       RETURN;
   ELSE
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
END Lock_Row;

END AMS_CAT_ACTIVITIES_PKG;

/
