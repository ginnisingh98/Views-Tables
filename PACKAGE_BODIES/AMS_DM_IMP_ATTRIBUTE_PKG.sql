--------------------------------------------------------
--  DDL for Package Body AMS_DM_IMP_ATTRIBUTE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_DM_IMP_ATTRIBUTE_PKG" as
/* $Header: amstdiab.pls 115.2 2002/12/09 11:05:02 choang noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Dm_Imp_Attribute_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_Dm_Imp_Attribute_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amstdiab.pls';




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
          px_Dm_Imp_Attribute_id   IN OUT NOCOPY NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_model_id    NUMBER,
          p_source_field_id    NUMBER,
          p_rank    NUMBER,
          p_value    NUMBER)
 IS
   x_rowid    VARCHAR2(30);


BEGIN


   px_object_version_number := nvl(px_object_version_number, 1);


   INSERT INTO ams_dm_imp_attributes(
           imp_attribute_id,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           object_version_number,
           model_id,
           source_field_id,
           rank,
           value
   ) VALUES (
           DECODE( px_Dm_Imp_Attribute_id, FND_API.G_MISS_NUM, NULL, px_Dm_Imp_Attribute_id),
           DECODE( p_last_update_date, FND_API.G_MISS_DATE, SYSDATE, p_last_update_date),
           DECODE( p_last_updated_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_last_updated_by),
           DECODE( p_creation_date, FND_API.G_MISS_DATE, SYSDATE, p_creation_date),
           DECODE( p_created_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_created_by),
           DECODE( p_last_update_login, FND_API.G_MISS_NUM, FND_GLOBAL.CONC_LOGIN_ID, p_last_update_login),
           DECODE( px_object_version_number, FND_API.G_MISS_NUM, 1, px_object_version_number),
           DECODE( p_model_id, FND_API.G_MISS_NUM, NULL, p_model_id),
           DECODE( p_source_field_id, FND_API.G_MISS_NUM, NULL, p_source_field_id),
           DECODE( p_rank, FND_API.G_MISS_NUM, NULL, p_rank),
           DECODE( p_value, FND_API.G_MISS_NUM, NULL, p_value));

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
          p_Dm_Imp_Attribute_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_model_id    NUMBER,
          p_source_field_id    NUMBER,
          p_rank    NUMBER,
          p_value    NUMBER
)
IS
BEGIN
    Update ams_dm_imp_attributes
    SET
              imp_attribute_id = DECODE( p_Dm_Imp_Attribute_id, null, imp_attribute_id, FND_API.G_MISS_NUM, null, p_Dm_Imp_Attribute_id),
              last_update_date = DECODE( p_last_update_date, null, last_update_date, FND_API.G_MISS_DATE, null, p_last_update_date),
              last_updated_by = DECODE( p_last_updated_by, null, last_updated_by, FND_API.G_MISS_NUM, null, p_last_updated_by),
              last_update_login = DECODE( p_last_update_login, null, last_update_login, FND_API.G_MISS_NUM, null, p_last_update_login),
              object_version_number = object_version_number + 1,
              model_id = DECODE( p_model_id, null, model_id, FND_API.G_MISS_NUM, null, p_model_id),
              source_field_id = DECODE( p_source_field_id, null, source_field_id, FND_API.G_MISS_NUM, null, p_source_field_id),
              rank = DECODE( p_rank, null, rank, FND_API.G_MISS_NUM, null, p_rank),
              value = DECODE( p_value, null, value, FND_API.G_MISS_NUM, null, p_value)
   WHERE imp_attribute_id = p_Dm_Imp_Attribute_id
   AND   object_version_number = px_object_version_number;


   IF (SQL%NOTFOUND) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   px_object_version_number := nvl(px_object_version_number,0) + 1;

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
    p_Dm_Imp_Attribute_id  NUMBER,
    p_object_version_number  NUMBER)
 IS
 BEGIN
   DELETE FROM ams_dm_imp_attributes
    WHERE imp_attribute_id = p_Dm_Imp_Attribute_id
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
    p_Dm_Imp_Attribute_id  NUMBER)
 IS
   CURSOR C IS
        SELECT *
         FROM ams_dm_imp_attributes
        WHERE imp_attribute_id =  p_Dm_Imp_Attribute_id
        FOR UPDATE OF imp_attribute_id NOWAIT;
   Recinfo C%ROWTYPE;
 BEGIN
    OPEN c;
    FETCH c INTO Recinfo;
    IF (c%NOTFOUND) THEN
        CLOSE c;
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
    CLOSE C;
END Lock_Row;

END AMS_Dm_Imp_Attribute_PKG;

/
