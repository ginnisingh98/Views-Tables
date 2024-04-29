--------------------------------------------------------
--  DDL for Package Body AMS_LIST_SRC_TYPE_ASSOCS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_LIST_SRC_TYPE_ASSOCS_PKG" as
/* $Header: amststab.pls 120.0 2005/05/31 20:47:13 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_LIST_SRC_TYPE_ASSOCS_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_LIST_SRC_TYPE_ASSOCS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amststab.pls';


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
          px_list_source_type_assoc_id   IN OUT NOCOPY NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_master_source_type_id    NUMBER,
          p_sub_source_type_id    NUMBER,
          p_sub_source_type_pk_column    VARCHAR2,
          p_enabled_flag    VARCHAR2,
          p_description    VARCHAR2,
          p_master_source_type_pk_column varchar2
          )

 IS
   x_rowid    VARCHAR2(30);


BEGIN


   px_object_version_number := 1;


   INSERT INTO AMS_LIST_SRC_TYPE_ASSOCS(
           list_source_type_assoc_id,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           object_version_number,
           master_source_type_id,
           sub_source_type_id,
           sub_source_type_pk_column,
           enabled_flag,
           description,
           master_source_type_pk_column
   ) VALUES (
           DECODE( px_list_source_type_assoc_id, FND_API.g_miss_num, NULL, px_list_source_type_assoc_id),
           DECODE( p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date),
           DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by),
           DECODE( p_creation_date, FND_API.g_miss_date, NULL, p_creation_date),
           DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by),
           DECODE( p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login),
           DECODE( px_object_version_number, FND_API.g_miss_num, NULL, px_object_version_number),
           DECODE( p_master_source_type_id, FND_API.g_miss_num, NULL, p_master_source_type_id),
           DECODE( p_sub_source_type_id, FND_API.g_miss_num, NULL, p_sub_source_type_id),
           DECODE( p_sub_source_type_pk_column, FND_API.g_miss_char, NULL, p_sub_source_type_pk_column),
           DECODE( p_enabled_flag, FND_API.g_miss_char, NULL, p_enabled_flag),
           DECODE( p_description, FND_API.g_miss_char, NULL, p_description),
           DECODE( p_master_source_type_pk_column, FND_API.g_miss_char, NULL, p_master_source_type_pk_column));
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
          p_list_source_type_assoc_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_master_source_type_id    NUMBER,
          p_sub_source_type_id    NUMBER,
          p_sub_source_type_pk_column    VARCHAR2,
          p_enabled_flag    VARCHAR2,
          p_description    VARCHAR2,
          p_master_source_type_pk_column  VARCHAR2)

 IS
 BEGIN
    Update AMS_LIST_SRC_TYPE_ASSOCS
    SET
              list_source_type_assoc_id = DECODE( p_list_source_type_assoc_id, FND_API.g_miss_num, list_source_type_assoc_id, p_list_source_type_assoc_id),
              last_update_date = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
              last_updated_by = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
              creation_date = DECODE( p_creation_date, FND_API.g_miss_date, creation_date, p_creation_date),
              created_by = DECODE( p_created_by, FND_API.g_miss_num, created_by, p_created_by),
              last_update_login = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
              object_version_number = DECODE( p_object_version_number, FND_API.g_miss_num, object_version_number, p_object_version_number),
              master_source_type_id = DECODE( p_master_source_type_id, FND_API.g_miss_num, master_source_type_id, p_master_source_type_id),
              sub_source_type_id = DECODE( p_sub_source_type_id, FND_API.g_miss_num, sub_source_type_id, p_sub_source_type_id),
              sub_source_type_pk_column = DECODE( p_sub_source_type_pk_column, FND_API.g_miss_char, sub_source_type_pk_column, p_sub_source_type_pk_column),
              enabled_flag = DECODE( p_enabled_flag, FND_API.g_miss_char, enabled_flag, p_enabled_flag),
              description = DECODE( p_description, FND_API.g_miss_char, description, p_description),
              master_source_type_pk_column= DECODE( p_master_source_type_pk_column, FND_API.g_miss_char, master_source_type_pk_column, p_master_source_type_pk_column)
   WHERE LIST_SOURCE_TYPE_ASSOC_ID = p_LIST_SOURCE_TYPE_ASSOC_ID
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
    p_LIST_SOURCE_TYPE_ASSOC_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM AMS_LIST_SRC_TYPE_ASSOCS
    WHERE LIST_SOURCE_TYPE_ASSOC_ID = p_LIST_SOURCE_TYPE_ASSOC_ID;
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
          p_list_source_type_assoc_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_master_source_type_id    NUMBER,
          p_sub_source_type_id    NUMBER,
          p_sub_source_type_pk_column    VARCHAR2,
          p_enabled_flag    VARCHAR2,
          p_description    VARCHAR2,
          p_master_source_type_pk_column VARCHAR2)

 IS
   CURSOR C IS
        SELECT *
         FROM AMS_LIST_SRC_TYPE_ASSOCS
        WHERE LIST_SOURCE_TYPE_ASSOC_ID =  p_LIST_SOURCE_TYPE_ASSOC_ID
        FOR UPDATE of LIST_SOURCE_TYPE_ASSOC_ID NOWAIT;
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
           (      Recinfo.list_source_type_assoc_id = p_list_source_type_assoc_id)
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
       AND (    ( Recinfo.master_source_type_id = p_master_source_type_id)
            OR (    ( Recinfo.master_source_type_id IS NULL )
                AND (  p_master_source_type_id IS NULL )))
       AND (    ( Recinfo.sub_source_type_id = p_sub_source_type_id)
            OR (    ( Recinfo.sub_source_type_id IS NULL )
                AND (  p_sub_source_type_id IS NULL )))
       AND (    ( Recinfo.sub_source_type_pk_column = p_sub_source_type_pk_column)
            OR (    ( Recinfo.sub_source_type_pk_column IS NULL )
                AND (  p_sub_source_type_pk_column IS NULL )))
       AND (    ( Recinfo.enabled_flag = p_enabled_flag)
            OR (    ( Recinfo.enabled_flag IS NULL )
                AND (  p_enabled_flag IS NULL )))
       AND (    ( Recinfo.description = p_description)
            OR (    ( Recinfo.description IS NULL )
                AND (  p_description IS NULL )))
       AND (    ( Recinfo.master_source_type_pk_column = p_master_source_type_pk_column)
            OR (    ( Recinfo.master_source_type_pk_column IS NULL )
                AND (  p_master_source_type_pk_column IS NULL )))
       ) THEN
       RETURN;
   ELSE
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
END Lock_Row;

PROCEDURE load_row (
  x_list_source_type_assoc_id IN NUMBER,
  x_enabled_flag IN VARCHAR2,
  x_master_source_type_id IN NUMBER,
  x_sub_source_type_id IN NUMBER,
  x_sub_source_type_pk_column IN VARCHAR2,
  x_description IN VARCHAR2,
  x_owner IN VARCHAR2,
  x_custom_mode IN VARCHAR2,
  x_master_source_type_pk_column IN VARCHAR2
)
IS
   l_user_id   number := 0;
   l_obj_verno  number;
   l_dummy_char  varchar2(1);
   l_row_id    varchar2(100);
   l_list_source_type_assoc_id   number;
   l_last_updated_by number;

   CURSOR  c_obj_verno IS
     SELECT object_version_number, last_updated_by
     FROM   ams_list_src_type_assocs
     WHERE  list_source_type_assoc_id =  x_list_source_type_assoc_id;

   CURSOR c_chk_exists is
     SELECT 'x'
     FROM   ams_list_src_type_assocs
     WHERE  list_source_type_assoc_id = x_list_source_type_assoc_id;

   CURSOR c_get_id is
      SELECT ams_list_src_type_assocs_s.NEXTVAL
      FROM DUAL;
BEGIN
   if X_OWNER = 'SEED' then
      l_user_id := 1;
   elsif X_OWNER = 'ORACLE' then
      l_user_id := 2;
   elsif X_OWNER = 'SYSADMIN' THEN
     l_user_id := 0;
   end if;

   OPEN c_chk_exists;
   FETCH c_chk_exists INTO l_dummy_char;
   IF c_chk_exists%notfound THEN
      CLOSE c_chk_exists;

      IF x_list_source_type_assoc_id IS NULL THEN
         OPEN c_get_id;
         FETCH c_get_id INTO l_list_source_type_assoc_id;
         CLOSE c_get_id;
      ELSE
         l_list_source_type_assoc_id := x_list_source_type_assoc_id;
      END IF;
      l_obj_verno := 1;

      ams_list_src_type_assocs_pkg.insert_row (
         --x_rowid                       => l_row_id,
         px_list_source_type_assoc_id   => l_list_source_type_assoc_id,
         p_last_update_date            => SYSDATE,
         p_last_updated_by             => l_user_id,
         p_creation_date               => SYSDATE,
         p_created_by                  => l_user_id,
         p_last_update_login           => 0,
         px_object_version_number       => l_obj_verno,
         p_enabled_flag                => x_enabled_flag,
         p_master_source_type_id       => x_master_source_type_id,
         p_sub_source_type_id          => x_sub_source_type_id,
         p_sub_source_type_pk_column   => x_sub_source_type_pk_column,
         p_description                 => x_description,
         p_master_source_type_pk_column=> x_master_source_type_pk_column
      );


   ELSE
      CLOSE c_chk_exists;
      OPEN c_obj_verno;
      FETCH c_obj_verno INTO l_obj_verno, l_last_updated_by;
      CLOSE c_obj_verno;


  if (l_last_updated_by in (1,2,0) OR
          NVL(x_custom_mode,'PRESERVE')='FORCE') THEN

      ams_list_src_type_assocs_pkg.update_row (
         p_list_source_type_assoc_id   => x_list_source_type_assoc_id,
         p_last_update_date            => SYSDATE,
         p_last_updated_by             => l_user_id,
         p_creation_date              => sysdate,
         p_created_by                => l_user_id,
         p_last_update_login           => 0,
         p_enabled_flag                => x_enabled_flag,
         p_object_version_number       => l_obj_verno,
         p_master_source_type_id       => x_master_source_type_id,
         p_sub_source_type_id          => x_sub_source_type_id,
         p_sub_source_type_pk_column   => x_sub_source_type_pk_column,
         p_description                 => x_description,
         p_master_source_type_pk_column=> x_master_source_type_pk_column
      );
   end if;

   END IF;
END load_row;

END AMS_LIST_SRC_TYPE_ASSOCS_PKG;

/
