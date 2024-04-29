--------------------------------------------------------
--  DDL for Package Body AMS_SYSTEM_PRETTY_URL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_SYSTEM_PRETTY_URL_PKG" as
/* $Header: amstspub.pls 120.0 2005/07/01 03:56:31 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_SYSTEM_PRETTY_URL_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_SYSTEM_PRETTY_URL_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amstspub.pls';


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
          px_system_url_id   IN OUT NOCOPY NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_pretty_url_id    NUMBER,
          p_additional_url_param    VARCHAR2,
          p_system_url    VARCHAR2,
          p_ctd_id    NUMBER,
          p_track_url    VARCHAR2)

 IS
   x_rowid    VARCHAR2(30);


BEGIN


   px_object_version_number := 1;


   INSERT INTO AMS_SYSTEM_PRETTY_URL(
           system_url_id,
           creation_date,
           created_by,
           last_update_date,
           last_updated_by,
           last_update_login,
           object_version_number,
           pretty_url_id,
           additional_url_param,
           system_url,
           ctd_id,
           track_url
   ) VALUES (
           DECODE( px_system_url_id, FND_API.g_miss_num, NULL, px_system_url_id),
           DECODE( p_creation_date, FND_API.g_miss_date, NULL, p_creation_date),
           DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by),
           DECODE( p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date),
           DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by),
           DECODE( p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login),
           DECODE( px_object_version_number, FND_API.g_miss_num, NULL, px_object_version_number),
           DECODE( p_pretty_url_id, FND_API.g_miss_num, NULL, p_pretty_url_id),
           DECODE( p_additional_url_param, FND_API.g_miss_char, NULL, p_additional_url_param),
           DECODE( p_system_url, FND_API.g_miss_char, NULL, p_system_url),
           DECODE( p_ctd_id, FND_API.g_miss_num, NULL, p_ctd_id),
           DECODE( p_track_url, FND_API.g_miss_char, NULL, p_track_url));
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
          p_system_url_id    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_pretty_url_id    NUMBER,
          p_additional_url_param    VARCHAR2,
          p_system_url    VARCHAR2,
          p_ctd_id    NUMBER,
          p_track_url    VARCHAR2)

 IS
 BEGIN
    Update AMS_SYSTEM_PRETTY_URL
    SET
              system_url_id = DECODE( p_system_url_id, FND_API.g_miss_num, system_url_id, p_system_url_id),
              creation_date = DECODE( p_creation_date, FND_API.g_miss_date, creation_date, p_creation_date),
              created_by = DECODE( p_created_by, FND_API.g_miss_num, created_by, p_created_by),
              last_update_date = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
              last_updated_by = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
              last_update_login = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
              object_version_number = DECODE( p_object_version_number, FND_API.g_miss_num, object_version_number, p_object_version_number),
              pretty_url_id = DECODE( p_pretty_url_id, FND_API.g_miss_num, pretty_url_id, p_pretty_url_id),
              additional_url_param = DECODE( p_additional_url_param, FND_API.g_miss_char, additional_url_param, p_additional_url_param),
              system_url = DECODE( p_system_url, FND_API.g_miss_char, system_url, p_system_url),
              ctd_id = DECODE( p_ctd_id, FND_API.g_miss_num, ctd_id, p_ctd_id),
              track_url = DECODE( p_track_url, FND_API.g_miss_char, track_url, p_track_url)
   WHERE SYSTEM_URL_ID = p_SYSTEM_URL_ID
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
    p_SYSTEM_URL_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM AMS_SYSTEM_PRETTY_URL
    WHERE SYSTEM_URL_ID = p_SYSTEM_URL_ID;
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
          p_system_url_id    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_pretty_url_id    NUMBER,
          p_additional_url_param    VARCHAR2,
          p_system_url    VARCHAR2,
          p_ctd_id    NUMBER,
          p_track_url    VARCHAR2)

 IS
   CURSOR C IS
        SELECT *
         FROM AMS_SYSTEM_PRETTY_URL
        WHERE SYSTEM_URL_ID =  p_SYSTEM_URL_ID
        FOR UPDATE of SYSTEM_URL_ID NOWAIT;
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
           (      Recinfo.system_url_id = p_system_url_id)
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
       AND (    ( Recinfo.pretty_url_id = p_pretty_url_id)
            OR (    ( Recinfo.pretty_url_id IS NULL )
                AND (  p_pretty_url_id IS NULL )))
       AND (    ( Recinfo.additional_url_param = p_additional_url_param)
            OR (    ( Recinfo.additional_url_param IS NULL )
                AND (  p_additional_url_param IS NULL )))
       AND (    ( Recinfo.system_url = p_system_url)
            OR (    ( Recinfo.system_url IS NULL )
                AND (  p_system_url IS NULL )))
       AND (    ( Recinfo.ctd_id = p_ctd_id)
            OR (    ( Recinfo.ctd_id IS NULL )
                AND (  p_ctd_id IS NULL )))
       AND (    ( Recinfo.track_url = p_track_url)
            OR (    ( Recinfo.track_url IS NULL )
                AND (  p_track_url IS NULL )))
       ) THEN
       RETURN;
   ELSE
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
END Lock_Row;

END AMS_SYSTEM_PRETTY_URL_PKG;

/
