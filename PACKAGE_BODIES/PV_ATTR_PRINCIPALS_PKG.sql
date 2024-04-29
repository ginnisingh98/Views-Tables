--------------------------------------------------------
--  DDL for Package Body PV_ATTR_PRINCIPALS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_ATTR_PRINCIPALS_PKG" AS
 /* $Header: pvxtatpb.pls 120.0 2007/12/20 07:10:07 abnagapp noship $ */
 -- ===============================================================
 -- Start of Comments
 -- Package name
 --          PV_ATTRIBUTE_PRINCIPALS_PKG
 -- Purpose
 --
 -- History
 --
 -- NOTE
 --
 -- End of Comments
 -- ===============================================================


 G_PKG_NAME CONSTANT VARCHAR2(30):= 'PV_ATTR_PRINCIPALS_PKG';
 G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxtatpb.pls';


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
           px_attr_principal_id   IN OUT  NOCOPY NUMBER,
           p_last_update_date    DATE,
           p_last_updated_by    NUMBER,
           p_creation_date    DATE,
           p_created_by    NUMBER,
           p_last_update_login    NUMBER,
           px_object_version_number   IN OUT  NOCOPY NUMBER,
           p_attribute_id    NUMBER,
           p_jtf_auth_principal_id    NUMBER
           )
  IS
    x_rowid    VARCHAR2(30);


 BEGIN


    px_object_version_number := 1;


    INSERT INTO PV_ATTR_PRINCIPALS(
            attr_principal_id,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login,
            object_version_number,
            attribute_id,
            jtf_auth_principal_id
    ) VALUES (
            DECODE( px_attr_principal_id, FND_API.g_miss_num, NULL, px_attr_principal_id),
            DECODE( p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date),
            DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by),
            DECODE( p_creation_date, FND_API.g_miss_date, NULL, p_creation_date),
            DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by),
            DECODE( p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login),
            DECODE( px_object_version_number, FND_API.g_miss_num, NULL, px_object_version_number),
            DECODE( p_attribute_id, FND_API.g_miss_num, NULL, p_attribute_id),
            DECODE( p_jtf_auth_principal_id, FND_API.g_miss_num, NULL, p_jtf_auth_principal_id)
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
           p_attr_principal_id    NUMBER,
           p_last_update_date    DATE,
           p_last_updated_by    NUMBER,
           p_creation_date    DATE := FND_API.g_miss_date ,
           p_created_by    NUMBER := FND_API.g_miss_num ,
           p_last_update_login    NUMBER,
           p_object_version_number    NUMBER,
           p_attribute_id    NUMBER,
           p_jtf_auth_principal_id    NUMBER
           )

  IS
  BEGIN
     Update PV_ATTR_PRINCIPALS
     SET
               attr_principal_id = DECODE( p_attr_principal_id, FND_API.g_miss_num, attr_principal_id, p_attr_principal_id),
               last_update_date = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
               last_updated_by = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
               --creation_date = DECODE( p_creation_date, FND_API.g_miss_date, creation_date, p_creation_date),
               --created_by = DECODE( p_created_by, FND_API.g_miss_num, created_by, p_created_by),
               last_update_login = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
               object_version_number = DECODE( p_object_version_number, FND_API.g_miss_num, object_version_number, p_object_version_number+1),
               attribute_id = DECODE( p_attribute_id, FND_API.g_miss_num, attribute_id, p_attribute_id),
               jtf_auth_principal_id = DECODE( p_jtf_auth_principal_id, FND_API.g_miss_num, jtf_auth_principal_id, p_jtf_auth_principal_id)
    WHERE attr_principal_id = p_attr_principal_id
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
     p_attr_principal_id  NUMBER)
  IS
  BEGIN
    DELETE FROM PV_ATTR_PRINCIPALS
     WHERE attr_principal_id = p_attr_principal_id;
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
           p_attr_principal_id    NUMBER,
           p_last_update_date    DATE,
           p_last_updated_by    NUMBER,
           p_creation_date    DATE,
           p_created_by    NUMBER,
           p_last_update_login    NUMBER,
           p_object_version_number    NUMBER,
           p_attribute_id    NUMBER,
           p_jtf_auth_principal_id    NUMBER
           )

  IS
    CURSOR C IS
         SELECT *
          FROM PV_ATTR_PRINCIPALS
         WHERE attr_principal_id =  p_attr_principal_id
         FOR UPDATE of attr_principal_id NOWAIT;
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
            (      Recinfo.attr_principal_id = p_attr_principal_id)
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
        AND (    ( Recinfo.attribute_id = p_attribute_id)
             OR (    ( Recinfo.attribute_id IS NULL )
                 AND (  p_attribute_id IS NULL )))
        AND (    ( Recinfo.jtf_auth_principal_id = p_jtf_auth_principal_id)
             OR (    ( Recinfo.jtf_auth_principal_id IS NULL )
                 AND (  p_jtf_auth_principal_id IS NULL )))
        ) THEN
        RETURN;
    ELSE
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
 END Lock_Row;
END;

/
