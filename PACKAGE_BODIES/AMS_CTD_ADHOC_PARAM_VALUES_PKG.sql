--------------------------------------------------------
--  DDL for Package Body AMS_CTD_ADHOC_PARAM_VALUES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_CTD_ADHOC_PARAM_VALUES_PKG" as
/* $Header: amstapvb.pls 120.0 2005/07/01 03:53:15 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_CTD_ADHOC_PARAM_VALUES_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_CTD_ADHOC_PARAM_VALUES_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amstapvb.pls';


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
          px_adhoc_param_id   IN OUT NOCOPY NUMBER,
          p_adhoc_param_code    VARCHAR2,
          p_adhoc_param_value    VARCHAR2,
          p_ctd_id    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_security_group_id    NUMBER)

 IS
   x_rowid    VARCHAR2(30);


BEGIN


   px_object_version_number := 1;


   INSERT INTO AMS_CTD_ADHOC_PARAM_VALUES(
           adhoc_param_id,
           adhoc_param_code,
           adhoc_param_value,
           ctd_id,
           object_version_number,
           last_update_date,
           last_updated_by,
           last_update_login,
           creation_date,
           created_by,
           security_group_id
   ) VALUES (
           DECODE( px_adhoc_param_id, FND_API.g_miss_num, NULL, px_adhoc_param_id),
           DECODE( p_adhoc_param_code, FND_API.g_miss_char, NULL, p_adhoc_param_code),
           DECODE( p_adhoc_param_value, FND_API.g_miss_char, NULL, p_adhoc_param_value),
           DECODE( p_ctd_id, FND_API.g_miss_num, NULL, p_ctd_id),
           DECODE( px_object_version_number, FND_API.g_miss_num, NULL, px_object_version_number),
           DECODE( p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date),
           DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by),
           DECODE( p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login),
           DECODE( p_creation_date, FND_API.g_miss_date, NULL, p_creation_date),
           DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by),
           DECODE( p_security_group_id, FND_API.g_miss_num, NULL, p_security_group_id));
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
          p_adhoc_param_id    NUMBER,
          p_adhoc_param_code    VARCHAR2,
          p_adhoc_param_value    VARCHAR2,
          p_ctd_id    NUMBER,
          p_object_version_number    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_security_group_id    NUMBER)

 IS
 BEGIN
    Update AMS_CTD_ADHOC_PARAM_VALUES
    SET
              adhoc_param_id = DECODE( p_adhoc_param_id, FND_API.g_miss_num, adhoc_param_id, p_adhoc_param_id),
              adhoc_param_code = DECODE( p_adhoc_param_code, FND_API.g_miss_char, adhoc_param_code, p_adhoc_param_code),
              adhoc_param_value = DECODE( p_adhoc_param_value, FND_API.g_miss_char, adhoc_param_value, p_adhoc_param_value),
              ctd_id = DECODE( p_ctd_id, FND_API.g_miss_num, ctd_id, p_ctd_id),
              object_version_number = DECODE( p_object_version_number, FND_API.g_miss_num, object_version_number, p_object_version_number),
              last_update_date = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
              last_updated_by = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
              last_update_login = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
              creation_date = DECODE( p_creation_date, FND_API.g_miss_date, creation_date, p_creation_date),
              created_by = DECODE( p_created_by, FND_API.g_miss_num, created_by, p_created_by),
              security_group_id = DECODE( p_security_group_id, FND_API.g_miss_num, security_group_id, p_security_group_id)
   WHERE ADHOC_PARAM_ID = p_ADHOC_PARAM_ID
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
    p_ADHOC_PARAM_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM AMS_CTD_ADHOC_PARAM_VALUES
    WHERE ADHOC_PARAM_ID = p_ADHOC_PARAM_ID;
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
          p_adhoc_param_id    NUMBER,
          p_adhoc_param_code    VARCHAR2,
          p_adhoc_param_value    VARCHAR2,
          p_ctd_id    NUMBER,
          p_object_version_number    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_security_group_id    NUMBER)

 IS
   CURSOR C IS
        SELECT *
         FROM AMS_CTD_ADHOC_PARAM_VALUES
        WHERE ADHOC_PARAM_ID =  p_ADHOC_PARAM_ID
        FOR UPDATE of ADHOC_PARAM_ID NOWAIT;
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
           (      Recinfo.adhoc_param_id = p_adhoc_param_id)
       AND (    ( Recinfo.adhoc_param_code = p_adhoc_param_code)
            OR (    ( Recinfo.adhoc_param_code IS NULL )
                AND (  p_adhoc_param_code IS NULL )))
       AND (    ( Recinfo.adhoc_param_value = p_adhoc_param_value)
            OR (    ( Recinfo.adhoc_param_value IS NULL )
                AND (  p_adhoc_param_value IS NULL )))
       AND (    ( Recinfo.ctd_id = p_ctd_id)
            OR (    ( Recinfo.ctd_id IS NULL )
                AND (  p_ctd_id IS NULL )))
       AND (    ( Recinfo.object_version_number = p_object_version_number)
            OR (    ( Recinfo.object_version_number IS NULL )
                AND (  p_object_version_number IS NULL )))
       AND (    ( Recinfo.last_update_date = p_last_update_date)
            OR (    ( Recinfo.last_update_date IS NULL )
                AND (  p_last_update_date IS NULL )))
       AND (    ( Recinfo.last_updated_by = p_last_updated_by)
            OR (    ( Recinfo.last_updated_by IS NULL )
                AND (  p_last_updated_by IS NULL )))
       AND (    ( Recinfo.last_update_login = p_last_update_login)
            OR (    ( Recinfo.last_update_login IS NULL )
                AND (  p_last_update_login IS NULL )))
       AND (    ( Recinfo.creation_date = p_creation_date)
            OR (    ( Recinfo.creation_date IS NULL )
                AND (  p_creation_date IS NULL )))
       AND (    ( Recinfo.created_by = p_created_by)
            OR (    ( Recinfo.created_by IS NULL )
                AND (  p_created_by IS NULL )))
       AND (    ( Recinfo.security_group_id = p_security_group_id)
            OR (    ( Recinfo.security_group_id IS NULL )
                AND (  p_security_group_id IS NULL )))
       ) THEN
       RETURN;
   ELSE
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
END Lock_Row;

END AMS_CTD_ADHOC_PARAM_VALUES_PKG;

/
