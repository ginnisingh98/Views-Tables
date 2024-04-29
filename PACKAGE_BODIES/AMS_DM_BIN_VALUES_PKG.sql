--------------------------------------------------------
--  DDL for Package Body AMS_DM_BIN_VALUES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_DM_BIN_VALUES_PKG" as
/* $Header: amstdbvb.pls 115.3 2002/12/09 11:03:20 choang noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_DM_BIN_VALUES_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_DM_BIN_VALUES_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amstdbvb.pls';


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
          px_bin_value_id   IN OUT NOCOPY NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_source_field_id    NUMBER,
          p_bucket    NUMBER,
          p_bin_value    VARCHAR2,
          p_start_value    NUMBER,
          p_end_value    NUMBER)

 IS
   x_rowid    VARCHAR2(30);


BEGIN


   px_object_version_number := 1;


   INSERT INTO AMS_DM_BIN_VALUES(
           bin_value_id,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           object_version_number,
           source_field_id,
           bucket,
           bin_value,
           start_value,
           end_value
   ) VALUES (
           DECODE( px_bin_value_id, FND_API.g_miss_num, NULL, px_bin_value_id),
           DECODE( p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date),
           DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by),
           DECODE( p_creation_date, FND_API.g_miss_date, NULL, p_creation_date),
           DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by),
           DECODE( p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login),
           DECODE( px_object_version_number, FND_API.g_miss_num, NULL, px_object_version_number),
           DECODE( p_source_field_id, FND_API.g_miss_num, NULL, p_source_field_id),
           DECODE( p_bucket, FND_API.g_miss_num, NULL, p_bucket),
           DECODE( p_bin_value, FND_API.g_miss_char, NULL, p_bin_value),
           DECODE( p_start_value, FND_API.g_miss_num, NULL, p_start_value),
           DECODE( p_end_value, FND_API.g_miss_num, NULL, p_end_value));
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
          p_bin_value_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_source_field_id    NUMBER,
          p_bucket    NUMBER,
          p_bin_value    VARCHAR2,
          p_start_value    NUMBER,
          p_end_value    NUMBER)

 IS
 BEGIN
    Update AMS_DM_BIN_VALUES
    SET
              bin_value_id = DECODE( p_bin_value_id, FND_API.g_miss_num, bin_value_id, p_bin_value_id),
              last_update_date = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
              last_updated_by = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
              creation_date = DECODE( p_creation_date, FND_API.g_miss_date, creation_date, p_creation_date),
              created_by = DECODE( p_created_by, FND_API.g_miss_num, created_by, p_created_by),
              last_update_login = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
              object_version_number = DECODE( p_object_version_number, FND_API.g_miss_num, object_version_number, p_object_version_number),
              source_field_id = DECODE( p_source_field_id, FND_API.g_miss_num, source_field_id, p_source_field_id),
              bucket = DECODE( p_bucket, FND_API.g_miss_num, bucket, p_bucket),
              bin_value = DECODE( p_bin_value, FND_API.g_miss_char, bin_value, p_bin_value),
              start_value = DECODE( p_start_value, FND_API.g_miss_num, start_value, p_start_value),
              end_value = DECODE( p_end_value, FND_API.g_miss_num, end_value, p_end_value)
   WHERE BIN_VALUE_ID = p_BIN_VALUE_ID
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
    p_BIN_VALUE_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM AMS_DM_BIN_VALUES
    WHERE BIN_VALUE_ID = p_BIN_VALUE_ID;
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
          p_bin_value_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_source_field_id    NUMBER,
          p_bucket    NUMBER,
          p_bin_value    VARCHAR2,
          p_start_value    NUMBER,
          p_end_value    NUMBER)

 IS
   CURSOR C IS
        SELECT *
         FROM AMS_DM_BIN_VALUES
        WHERE BIN_VALUE_ID =  p_BIN_VALUE_ID
        FOR UPDATE of BIN_VALUE_ID NOWAIT;
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
           (      Recinfo.bin_value_id = p_bin_value_id)
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
       AND (    ( Recinfo.object_version_number = p_object_version_number)
            OR (    ( Recinfo.object_version_number IS NULL )
                AND (  p_object_version_number IS NULL )))
       AND (    ( Recinfo.source_field_id = p_source_field_id)
            OR (    ( Recinfo.source_field_id IS NULL )
                AND (  p_source_field_id IS NULL )))
       AND (    ( Recinfo.bucket = p_bucket)
            OR (    ( Recinfo.bucket IS NULL )
                AND (  p_bucket IS NULL )))
       AND (    ( Recinfo.bin_value = p_bin_value)
            OR (    ( Recinfo.bin_value IS NULL )
                AND (  p_bin_value IS NULL )))
       AND (    ( Recinfo.start_value = p_start_value)
            OR (    ( Recinfo.start_value IS NULL )
                AND (  p_start_value IS NULL )))
       AND (    ( Recinfo.end_value = p_end_value)
            OR (    ( Recinfo.end_value IS NULL )
                AND (  p_end_value IS NULL )))
       ) THEN
       RETURN;
   ELSE
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
END Lock_Row;

END AMS_DM_BIN_VALUES_PKG;

/
