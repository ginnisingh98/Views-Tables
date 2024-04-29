--------------------------------------------------------
--  DDL for Package Body AMS_PRETTY_URL_ASSOC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_PRETTY_URL_ASSOC_PKG" as
/* $Header: amstpuab.pls 120.0 2005/07/01 03:56:27 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_PRETTY_URL_ASSOC_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_PRETTY_URL_ASSOC_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amstpuab.pls';


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
          px_assoc_id   IN OUT NOCOPY NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_system_url_id    NUMBER,
          p_used_by_obj_type    VARCHAR2,
          p_used_by_obj_id    NUMBER)

 IS
   x_rowid    VARCHAR2(30);


BEGIN


   px_object_version_number := 1;


   INSERT INTO AMS_PRETTY_URL_ASSOC(
           assoc_id,
           creation_date,
           created_by,
           last_update_date,
           last_updated_by,
           last_update_login,
           object_version_number,
           system_url_id,
           used_by_obj_type,
           used_by_obj_id
   ) VALUES (
           DECODE( px_assoc_id, FND_API.g_miss_num, NULL, px_assoc_id),
           DECODE( p_creation_date, FND_API.g_miss_date, NULL, p_creation_date),
           DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by),
           DECODE( p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date),
           DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by),
           DECODE( p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login),
           DECODE( px_object_version_number, FND_API.g_miss_num, NULL, px_object_version_number),
           DECODE( p_system_url_id, FND_API.g_miss_num, NULL, p_system_url_id),
           DECODE( p_used_by_obj_type, FND_API.g_miss_char, NULL, p_used_by_obj_type),
           DECODE( p_used_by_obj_id, FND_API.g_miss_num, NULL, p_used_by_obj_id));
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
          p_assoc_id    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_system_url_id    NUMBER,
          p_used_by_obj_type    VARCHAR2,
          p_used_by_obj_id    NUMBER)

 IS
 BEGIN
    Update AMS_PRETTY_URL_ASSOC
    SET
              assoc_id = DECODE( p_assoc_id, FND_API.g_miss_num, assoc_id, p_assoc_id),
              creation_date = DECODE( p_creation_date, FND_API.g_miss_date, creation_date, p_creation_date),
              created_by = DECODE( p_created_by, FND_API.g_miss_num, created_by, p_created_by),
              last_update_date = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
              last_updated_by = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
              last_update_login = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
              object_version_number = DECODE( p_object_version_number, FND_API.g_miss_num, object_version_number, p_object_version_number),
              system_url_id = DECODE( p_system_url_id, FND_API.g_miss_num, system_url_id, p_system_url_id),
              used_by_obj_type = DECODE( p_used_by_obj_type, FND_API.g_miss_char, used_by_obj_type, p_used_by_obj_type),
              used_by_obj_id = DECODE( p_used_by_obj_id, FND_API.g_miss_num, used_by_obj_id, p_used_by_obj_id)
   WHERE ASSOC_ID = p_ASSOC_ID
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
    p_ASSOC_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM AMS_PRETTY_URL_ASSOC
    WHERE ASSOC_ID = p_ASSOC_ID;
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
          p_assoc_id    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_system_url_id    NUMBER,
          p_used_by_obj_type    VARCHAR2,
          p_used_by_obj_id    NUMBER)

 IS
   CURSOR C IS
        SELECT *
         FROM AMS_PRETTY_URL_ASSOC
        WHERE ASSOC_ID =  p_ASSOC_ID
        FOR UPDATE of ASSOC_ID NOWAIT;
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
           (      Recinfo.assoc_id = p_assoc_id)
       AND (    ( Recinfo.creation_date = p_creation_date)
            OR (    ( Recinfo.creation_date IS NULL )
                AND (  p_creation_date IS NULL )))
       AND (    ( Recinfo.created_by = p_created_by)
            OR (    ( Recinfo.created_by IS NULL )
                AND (  p_created_by IS NULL )))
       AND (    ( Recinfo.last_update_date = p_last_update_date)
            OR (    ( Recinfo.last_update_date IS NULL )
                AND (  p_last_update_date IS NULL )))
       AND (    ( Recinfo.last_updated_by = p_last_updated_by)
            OR (    ( Recinfo.last_updated_by IS NULL )
                AND (  p_last_updated_by IS NULL )))
       AND (    ( Recinfo.last_update_login = p_last_update_login)
            OR (    ( Recinfo.last_update_login IS NULL )
                AND (  p_last_update_login IS NULL )))
       AND (    ( Recinfo.object_version_number = p_object_version_number)
            OR (    ( Recinfo.object_version_number IS NULL )
                AND (  p_object_version_number IS NULL )))
       AND (    ( Recinfo.system_url_id = p_system_url_id)
            OR (    ( Recinfo.system_url_id IS NULL )
                AND (  p_system_url_id IS NULL )))
       AND (    ( Recinfo.used_by_obj_type = p_used_by_obj_type)
            OR (    ( Recinfo.used_by_obj_type IS NULL )
                AND (  p_used_by_obj_type IS NULL )))
       AND (    ( Recinfo.used_by_obj_id = p_used_by_obj_id)
            OR (    ( Recinfo.used_by_obj_id IS NULL )
                AND (  p_used_by_obj_id IS NULL )))
       ) THEN
       RETURN;
   ELSE
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
END Lock_Row;

END AMS_PRETTY_URL_ASSOC_PKG;

/
