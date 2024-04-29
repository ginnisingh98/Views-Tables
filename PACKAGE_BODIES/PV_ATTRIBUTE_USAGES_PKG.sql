--------------------------------------------------------
--  DDL for Package Body PV_ATTRIBUTE_USAGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_ATTRIBUTE_USAGES_PKG" as
 /* $Header: pvxtatub.pls 115.3 2002/12/10 19:38:47 amaram ship $ */
 -- ===============================================================
 -- Start of Comments
 -- Package name
 --          PV_ATTRIBUTE_USAGES_PKG
 -- Purpose
 --
 -- History
 --
 -- NOTE
 --
 -- End of Comments
 -- ===============================================================


 G_PKG_NAME CONSTANT VARCHAR2(30):= 'PV_ATTRIBUTE_USAGES_PKG';
 G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxtatub.pls';


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
           px_attribute_usage_id   IN OUT  NOCOPY NUMBER,
           p_last_update_date    DATE,
           p_last_updated_by    NUMBER,
           p_creation_date    DATE,
           p_created_by    NUMBER,
           p_last_update_login    NUMBER,
           p_request_id    NUMBER,
           p_program_application_id    NUMBER,
           p_program_id    NUMBER,
           p_program_update_date    DATE,
           px_object_version_number   IN OUT  NOCOPY NUMBER,
           p_attribute_usage_type    VARCHAR2,
           p_attribute_usage_code    VARCHAR2,
           p_attribute_id    NUMBER,
           p_enabled_flag    VARCHAR2
           --p_security_group_id    NUMBER
           )

  IS
    x_rowid    VARCHAR2(30);


 BEGIN


    px_object_version_number := 1;


    INSERT INTO PV_ATTRIBUTE_USAGES(
            attribute_usage_id,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login,
            request_id,
            program_application_id,
            program_id,
            program_update_date,
            object_version_number,
            attribute_usage_type,
            attribute_usage_code,
            attribute_id,
            enabled_flag
            --security_group_id
    ) VALUES (
            DECODE( px_attribute_usage_id, FND_API.g_miss_num, NULL, px_attribute_usage_id),
            DECODE( p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date),
            DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by),
            DECODE( p_creation_date, FND_API.g_miss_date, NULL, p_creation_date),
            DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by),
            DECODE( p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login),
            DECODE( p_request_id, FND_API.g_miss_num, NULL, p_request_id),
            DECODE( p_program_application_id, FND_API.g_miss_num, NULL, p_program_application_id),
            DECODE( p_program_id, FND_API.g_miss_num, NULL, p_program_id),
            DECODE( p_program_update_date, FND_API.g_miss_date, NULL, p_program_update_date),
            DECODE( px_object_version_number, FND_API.g_miss_num, NULL, px_object_version_number),
            DECODE( p_attribute_usage_type, FND_API.g_miss_char, NULL, p_attribute_usage_type),
            DECODE( p_attribute_usage_code, FND_API.g_miss_char, NULL, p_attribute_usage_code),
            DECODE( p_attribute_id, FND_API.g_miss_num, NULL, p_attribute_id),
            DECODE( p_enabled_flag, FND_API.g_miss_char, NULL, p_enabled_flag)
            --DECODE( p_security_group_id, FND_API.g_miss_num, NULL, p_security_group_id)
            );
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
           p_attribute_usage_id    NUMBER,
           p_last_update_date    DATE,
           p_last_updated_by    NUMBER,
           p_creation_date    DATE := FND_API.g_miss_date ,
           p_created_by    NUMBER := FND_API.g_miss_num ,
           p_last_update_login    NUMBER,
           p_request_id    NUMBER,
           p_program_application_id    NUMBER,
           p_program_id    NUMBER,
           p_program_update_date    DATE,
           p_object_version_number    NUMBER,
           p_attribute_usage_type    VARCHAR2,
           p_attribute_usage_code    VARCHAR2,
           p_attribute_id    NUMBER,
           p_enabled_flag    VARCHAR2
           --p_security_group_id    NUMBER
           )

  IS
  BEGIN
     Update PV_ATTRIBUTE_USAGES
     SET
               attribute_usage_id = DECODE( p_attribute_usage_id, FND_API.g_miss_num, attribute_usage_id, p_attribute_usage_id),
               last_update_date = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
               last_updated_by = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
               --creation_date = DECODE( p_creation_date, FND_API.g_miss_date, creation_date, p_creation_date),
               --created_by = DECODE( p_created_by, FND_API.g_miss_num, created_by, p_created_by),
               last_update_login = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
               request_id = DECODE( p_request_id, FND_API.g_miss_num, request_id, p_request_id),
               program_application_id = DECODE( p_program_application_id, FND_API.g_miss_num, program_application_id, p_program_application_id),
               program_id = DECODE( p_program_id, FND_API.g_miss_num, program_id, p_program_id),
               program_update_date = DECODE( p_program_update_date, FND_API.g_miss_date, program_update_date, p_program_update_date),
               object_version_number = DECODE( p_object_version_number, FND_API.g_miss_num, object_version_number, p_object_version_number+1),
               attribute_usage_type = DECODE( p_attribute_usage_type, FND_API.g_miss_char, attribute_usage_type, p_attribute_usage_type),
               attribute_usage_code = DECODE( p_attribute_usage_code, FND_API.g_miss_char, attribute_usage_code, p_attribute_usage_code),
               attribute_id = DECODE( p_attribute_id, FND_API.g_miss_num, attribute_id, p_attribute_id),
               enabled_flag = DECODE( p_enabled_flag, FND_API.g_miss_char, enabled_flag, p_enabled_flag)
               --security_group_id = DECODE( p_security_group_id, FND_API.g_miss_num, security_group_id, p_security_group_id)
    WHERE ATTRIBUTE_USAGE_ID = p_ATTRIBUTE_USAGE_ID
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
     p_ATTRIBUTE_USAGE_ID  NUMBER)
  IS
  BEGIN
    DELETE FROM PV_ATTRIBUTE_USAGES
     WHERE ATTRIBUTE_USAGE_ID = p_ATTRIBUTE_USAGE_ID;
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
           p_attribute_usage_id    NUMBER,
           p_last_update_date    DATE,
           p_last_updated_by    NUMBER,
           p_creation_date    DATE,
           p_created_by    NUMBER,
           p_last_update_login    NUMBER,
           p_request_id    NUMBER,
           p_program_application_id    NUMBER,
           p_program_id    NUMBER,
           p_program_update_date    DATE,
           p_object_version_number    NUMBER,
           p_attribute_usage_type    VARCHAR2,
           p_attribute_usage_code    VARCHAR2,
           p_attribute_id    NUMBER,
           p_enabled_flag    VARCHAR2
           --p_security_group_id    NUMBER
           )

  IS
    CURSOR C IS
         SELECT *
          FROM PV_ATTRIBUTE_USAGES
         WHERE ATTRIBUTE_USAGE_ID =  p_ATTRIBUTE_USAGE_ID
         FOR UPDATE of ATTRIBUTE_USAGE_ID NOWAIT;
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
            (      Recinfo.attribute_usage_id = p_attribute_usage_id)
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
        AND (    ( Recinfo.request_id = p_request_id)
             OR (    ( Recinfo.request_id IS NULL )
                 AND (  p_request_id IS NULL )))
        AND (    ( Recinfo.program_application_id = p_program_application_id)
             OR (    ( Recinfo.program_application_id IS NULL )
                 AND (  p_program_application_id IS NULL )))
        AND (    ( Recinfo.program_id = p_program_id)
             OR (    ( Recinfo.program_id IS NULL )
                 AND (  p_program_id IS NULL )))
        AND (    ( Recinfo.program_update_date = p_program_update_date)
             OR (    ( Recinfo.program_update_date IS NULL )
                 AND (  p_program_update_date IS NULL )))
        AND (    ( Recinfo.object_version_number = p_object_version_number)
             OR (    ( Recinfo.object_version_number IS NULL )
                 AND (  p_object_version_number IS NULL )))
        AND (    ( Recinfo.attribute_usage_type = p_attribute_usage_type)
             OR (    ( Recinfo.attribute_usage_type IS NULL )
                 AND (  p_attribute_usage_type IS NULL )))
        AND (    ( Recinfo.attribute_usage_code = p_attribute_usage_code)
             OR (    ( Recinfo.attribute_usage_code IS NULL )
                 AND (  p_attribute_usage_code IS NULL )))
        AND (    ( Recinfo.attribute_id = p_attribute_id)
             OR (    ( Recinfo.attribute_id IS NULL )
                 AND (  p_attribute_id IS NULL )))
        AND (    ( Recinfo.enabled_flag = p_enabled_flag)
             OR (    ( Recinfo.enabled_flag IS NULL )
                 AND (  p_enabled_flag IS NULL )))
/*
        AND (    ( Recinfo.security_group_id = p_security_group_id)
             OR (    ( Recinfo.security_group_id IS NULL )
                 AND (  p_security_group_id IS NULL )))
*/
        ) THEN
        RETURN;
    ELSE
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
 END Lock_Row;

 END PV_ATTRIBUTE_USAGES_PKG;


/
