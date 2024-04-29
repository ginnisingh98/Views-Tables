--------------------------------------------------------
--  DDL for Package Body AMS_LIST_CONT_RESTRICTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_LIST_CONT_RESTRICTIONS_PKG" as
/* $Header: amstascb.pls 120.0 2005/05/31 21:00:56 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_LIST_CONT_RESTRICTIONS_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_LIST_CONT_RESTRICTIONS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amstascb.pls';


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
          px_list_cont_restrictions_id   IN OUT NOCOPY NUMBER,
          p_list_header_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_do_not_contact_flag    VARCHAR2,
          p_media_id    NUMBER,
          p_list_used_by    VARCHAR2,
          p_list_used_by_id    NUMBER
          )

 IS
   x_rowid    VARCHAR2(30);


BEGIN


   px_object_version_number := 1;


   INSERT INTO AMS_LIST_CONT_RESTRICTIONS(
           list_contact_restrictions_id,
           list_header_id,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           object_version_number,
           do_not_contact_flag,
           media_id,
           list_used_by,
           list_used_by_id
   ) VALUES (
           DECODE( px_list_cont_restrictions_id, FND_API.g_miss_num, NULL, px_list_cont_restrictions_id),
           DECODE( p_list_header_id, FND_API.g_miss_num, NULL, p_list_header_id),
           DECODE( p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date),
           DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by),
           DECODE( p_creation_date, FND_API.g_miss_date, NULL, p_creation_date),
           DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by),
           DECODE( p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login),
           DECODE( px_object_version_number, FND_API.g_miss_num, NULL, px_object_version_number),
           DECODE( p_do_not_contact_flag, FND_API.g_miss_char, NULL, p_do_not_contact_flag),
           DECODE( p_media_id, FND_API.g_miss_num, NULL, p_media_id),
           DECODE( p_list_used_by, FND_API.g_miss_char, NULL, p_list_used_by),
           DECODE( p_list_used_by_id, FND_API.g_miss_num, NULL, p_list_used_by_id));
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
          p_list_cont_restrictions_id    NUMBER,
          p_list_header_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_do_not_contact_flag    VARCHAR2,
          p_media_id    NUMBER,
          p_list_used_by    VARCHAR2,
          p_list_used_by_id    NUMBER)

 IS
 BEGIN

    Update AMS_LIST_CONT_RESTRICTIONS
    SET
              list_contact_restrictions_id = DECODE( p_list_cont_restrictions_id, FND_API.g_miss_num, list_contact_restrictions_id, p_list_cont_restrictions_id),
              list_header_id = DECODE( p_list_header_id, FND_API.g_miss_num, list_header_id, p_list_header_id),
              last_update_date = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
              last_updated_by = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
              creation_date = DECODE( p_creation_date, FND_API.g_miss_date, creation_date, p_creation_date),
              created_by = DECODE( p_created_by, FND_API.g_miss_num, created_by, p_created_by),
              last_update_login = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
              object_version_number = DECODE( p_object_version_number, FND_API.g_miss_num, object_version_number, p_object_version_number),
              do_not_contact_flag = DECODE( p_do_not_contact_flag, FND_API.g_miss_char, do_not_contact_flag, p_do_not_contact_flag),
              media_id = DECODE( p_media_id, FND_API.g_miss_num, media_id, p_media_id),
              list_used_by = DECODE( p_list_used_by, FND_API.g_miss_char, list_used_by, p_list_used_by),
              list_used_by_id = DECODE( p_list_used_by_id, FND_API.g_miss_num, list_used_by_id, p_list_used_by_id)
   WHERE LIST_CONTACT_RESTRICTIONs_ID = p_LIST_CONT_RESTRICTIONs_ID
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
    p_LIST_CONT_RESTRICTIONs_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM AMS_LIST_CONT_RESTRICTIONS
    WHERE LIST_CONTACT_RESTRICTIONs_ID = p_LIST_CONT_RESTRICTIONs_ID;
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
          p_list_cont_restrictions_id    NUMBER,
          p_list_header_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_do_not_contact_flag    VARCHAR2,
          p_media_id    NUMBER,
          p_list_used_by    VARCHAR2,
          p_list_used_by_id    NUMBER)

 IS
   CURSOR C IS
        SELECT *
         FROM AMS_LIST_CONT_RESTRICTIONS
        WHERE LIST_CONTACT_RESTRICTIONs_ID =  p_LIST_CONT_RESTRICTIONs_ID
        FOR UPDATE of LIST_CONTACT_RESTRICTIONs_ID NOWAIT;
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
           (      Recinfo.list_contact_restrictions_id = p_list_cont_restrictions_id)
       AND (    ( Recinfo.list_header_id = p_list_header_id)
            OR (    ( Recinfo.list_header_id IS NULL )
                AND (  p_list_header_id IS NULL )))
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
       AND (    ( Recinfo.do_not_contact_flag = p_do_not_contact_flag)
            OR (    ( Recinfo.do_not_contact_flag IS NULL )
                AND (  p_do_not_contact_flag IS NULL )))
       AND (    ( Recinfo.media_id = p_media_id)
            OR (    ( Recinfo.media_id IS NULL )
                AND (  p_media_id IS NULL )))
       AND (    ( Recinfo.list_used_by = p_list_used_by)
            OR (    ( Recinfo.list_used_by IS NULL )
                AND (  p_list_used_by IS NULL )))
       AND (    ( Recinfo.list_used_by_id = p_list_used_by_id)
            OR (    ( Recinfo.list_used_by_id IS NULL )
                AND (  p_list_used_by_id IS NULL )))
       ) THEN
       RETURN;
   ELSE
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
END Lock_Row;

PROCEDURE LOAD_ROW(
          p_owner    VARCHAR2,
          p_list_cont_restrictions_id    NUMBER,
          p_list_header_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_do_not_contact_flag    VARCHAR2,
          p_media_id    NUMBER,
          p_list_used_by    VARCHAR2,
          p_list_used_by_id    NUMBER,
          p_custom_mode    VARCHAR2
          ) is
l_dummy_char  varchar2(1);
x_return_status    varchar2(1);
l_row_id    varchar2(100);
l_user_id    number;
l_last_updated_by number;
l_obj_verno NUMBER;


l_object_version_number    NUMBER := p_object_version_number   ;
l_list_cont_restrictions_id    NUMBER := p_list_cont_restrictions_id   ;
cursor c_chk_col_exists is
select 'x'
from   ams_list_cont_restrictions
where  list_contact_restrictions_id = p_list_cont_restrictions_id;

   CURSOR  c_obj_verno IS
     SELECT object_version_number, last_updated_by
     FROM   ams_list_cont_restrictions
     where  list_contact_restrictions_id = p_list_cont_restrictions_id;


begin
  if p_OWNER = 'SEED' then
    l_user_id := 1;
   elsif p_OWNER = 'ORACLE' then
      l_user_id := 2;
  elsif p_OWNER = 'SYSADMIN' THEN
     l_user_id := 0;
   end if;

  open c_chk_col_exists;
  fetch c_chk_col_exists into l_dummy_char;
  if c_chk_col_exists%notfound then
     close c_chk_col_exists;
      Insert_Row(
          px_list_cont_restrictions_id  => l_list_cont_restrictions_id    ,
          p_list_header_id   => p_list_header_id     ,
          p_last_update_date   => p_last_update_date     ,
          p_last_updated_by   => p_last_updated_by     ,
          p_creation_date   => p_creation_date     ,
          p_created_by   => p_created_by     ,
          p_last_update_login   => p_last_update_login   ,
          px_object_version_number  => l_object_version_number    ,
          p_do_not_contact_flag   => p_do_not_contact_flag     ,
          p_media_id   => p_media_id     ,
          p_list_used_by   => p_list_used_by     ,
          p_list_used_by_id => p_list_used_by_id   );


      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
 else
    close c_chk_col_exists;

          OPEN c_obj_verno;
          FETCH c_obj_verno INTO l_obj_verno  ,l_last_updated_by;
          CLOSE c_obj_verno;

     if (l_last_updated_by in (1,2,0) OR
              NVL(p_custom_mode,'PRESERVE')='FORCE') THEN



       Update_Row(
          p_list_cont_restrictions_id    => p_list_cont_restrictions_id     ,
          p_list_header_id    => p_list_header_id     ,
          p_last_update_date  => p_last_update_date   ,
          p_last_updated_by   => p_last_updated_by    ,
          p_creation_date    => p_creation_date     ,
          p_created_by    => p_created_by     ,
          p_last_update_login    => p_last_update_login     ,
          p_object_version_number => l_obj_verno  ,
          p_do_not_contact_flag    => p_do_not_contact_flag     ,
          p_media_id    => p_media_id     ,
          p_list_used_by    => p_list_used_by     ,
          p_list_used_by_id    => p_list_used_by_id     );
      --

      end if;
 end if;
end ;


END AMS_LIST_CONT_RESTRICTIONS_PKG;

/
