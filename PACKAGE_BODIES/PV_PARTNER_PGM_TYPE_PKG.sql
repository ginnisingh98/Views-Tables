--------------------------------------------------------
--  DDL for Package Body PV_PARTNER_PGM_TYPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_PARTNER_PGM_TYPE_PKG" as
/* $Header: pvxtpptb.pls 120.0 2005/05/27 16:28:16 appldev noship $*/
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_PARTNER_PGM_TYPE_PKG
-- Purpose
--
-- History
--         22-APR-2002    Peter.Nixon     Created
--         11-JUN-2002    Karen.Tsao      Modified to reverse logic of G_MISS_XXX and NULL.
--
-- NOTE
--
-- Copyright (c) 2002 Oracle Corporation Redwood Shores, California, USA
--                          All rights reserved.
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'PV_PARTNER_PGM_TYPE_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxtpttb.pls';


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
PV_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
PV_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
PV_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Insert_Row(
           px_PROGRAM_TYPE_ID     IN OUT NOCOPY NUMBER
          ,p_active_flag                       VARCHAR2
          ,p_enabled_flag                      VARCHAR2
          ,p_object_version_number             NUMBER
          ,p_creation_date                     DATE
          ,p_created_by                        NUMBER
          ,p_last_update_date                  DATE
          ,p_last_updated_by                   NUMBER
          ,p_last_update_login                 NUMBER
          ,p_program_type_name                 VARCHAR2
          ,p_program_type_description          VARCHAR2
          )

 IS

BEGIN

   INSERT INTO PV_PARTNER_PROGRAM_TYPE_B(
           PROGRAM_TYPE_ID
          ,active_flag
          ,enabled_flag
          ,object_version_number
          ,creation_date
          ,created_by
          ,last_update_date
          ,last_updated_by
          ,last_update_login
   ) VALUES (
           DECODE( px_PROGRAM_TYPE_ID, NULL, px_PROGRAM_TYPE_ID, FND_API.g_miss_num, NULL, px_PROGRAM_TYPE_ID)
          ,DECODE( p_active_flag, NULL, p_active_flag, FND_API.g_miss_char, NULL, p_active_flag)
          ,DECODE( p_enabled_flag, NULL, p_enabled_flag, FND_API.g_miss_char, NULL, p_enabled_flag)
          ,DECODE( p_object_version_number, NULL, p_object_version_number, FND_API.g_miss_num, NULL, p_object_version_number)
          ,DECODE( p_creation_date, NULL, p_creation_date, FND_API.g_miss_date, NULL, p_creation_date)
          ,DECODE( p_created_by, NULL, p_created_by, FND_API.g_miss_num, NULL, p_created_by)
          ,DECODE( p_last_update_date, NULL, p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date)
          ,DECODE( p_last_updated_by, NULL, p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by)
          ,DECODE( p_last_update_login, NULL, p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login)
          );


   INSERT INTO PV_PARTNER_PROGRAM_TYPE_TL(
           PROGRAM_TYPE_ID
          ,creation_date
          ,created_by
          ,last_update_date
          ,last_updated_by
          ,last_update_login
          ,language
          ,source_lang
          ,program_type_name
          ,program_type_description
          )
   SELECT
           DECODE( px_PROGRAM_TYPE_ID,  NULL, px_PROGRAM_TYPE_ID, FND_API.g_miss_num, NULL, px_PROGRAM_TYPE_ID)
          ,SYSDATE
          ,FND_GLOBAL.user_id
          ,SYSDATE
          ,FND_GLOBAL.user_id
          ,FND_GLOBAL.conc_login_id
          ,l.language_code
          ,USERENV('LANG')
          ,DECODE( p_program_type_name, NULL, p_program_type_name, FND_API.g_miss_char, NULL, p_program_type_name)
          ,DECODE( p_program_type_description, NULL, p_program_type_description, FND_API.g_miss_char, NULL, p_program_type_description)
   FROM FND_LANGUAGES l
   WHERE l.installed_flag IN ('I','B')
   AND NOT EXISTS(
          SELECT NULL
          FROM PV_PARTNER_PROGRAM_TYPE_TL t
          WHERE t.PROGRAM_TYPE_ID = DECODE( px_PROGRAM_TYPE_ID, NULL, px_PROGRAM_TYPE_ID, FND_API.g_miss_num, NULL, px_PROGRAM_TYPE_ID)
          AND t.language = l.language_code
          );

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
           p_PROGRAM_TYPE_ID           NUMBER
          ,p_active_flag                     VARCHAR2
          ,p_enabled_flag                    VARCHAR2
          ,p_object_version_number           NUMBER
          ,p_last_update_date                DATE
          ,p_last_updated_by                 NUMBER
          ,p_last_update_login               NUMBER
          ,p_program_type_name               VARCHAR2
          ,p_program_type_description        VARCHAR2
          )

 IS
 BEGIN

   IF (PV_DEBUG_HIGH_ON) THEN



   PVX_Utility_PVT.debug_message('Within PV_PARTNER_PGM_TYPE_PKG.UPDATE_ROW API: ');

   END IF;
   IF (PV_DEBUG_HIGH_ON) THEN

   PVX_Utility_PVT.debug_message('Within PV_PARTNER_PGM_TYPE_PKG.UPDATE_ROW API : object_version_number ' ||p_object_version_number );
   END IF;


    Update PV_PARTNER_PROGRAM_TYPE_B
    SET
           PROGRAM_TYPE_ID          = DECODE( p_PROGRAM_TYPE_ID, NULL, PROGRAM_TYPE_ID, FND_API.g_miss_num, NULL, p_PROGRAM_TYPE_ID)
          ,active_flag              = DECODE( p_active_flag, NULL, active_flag, FND_API.g_miss_char, NULL, p_active_flag)
          ,enabled_flag             = DECODE( p_enabled_flag, NULL, enabled_flag, FND_API.g_miss_char, NULL, p_enabled_flag)
          ,object_version_number    = DECODE( p_object_version_number, NULL, object_version_number, FND_API.g_miss_num, NULL, p_object_version_number+1)
          ,last_update_date         = DECODE( p_last_update_date, NULL, last_update_date, FND_API.g_miss_date, NULL, p_last_update_date)
          ,last_updated_by          = DECODE( p_last_updated_by, NULL, last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by)
          ,last_update_login        = DECODE( p_last_update_login, NULL, last_update_login, FND_API.g_miss_num, NULL, p_last_update_login)

   WHERE PROGRAM_TYPE_ID = p_PROGRAM_TYPE_ID
     AND object_version_number = p_object_version_number;

    IF (SQL%NOTFOUND) THEN
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('PV', 'PV_RECORD_NOT_FOUND');
      FND_MSG_PUB.add;
   END IF;
   RAISE FND_API.g_exc_error;
  END IF;

   UPDATE PV_PARTNER_PROGRAM_TYPE_TL
   SET
        last_update_date               = SYSDATE
       ,last_updated_by                = FND_GLOBAL.user_id
       ,last_update_login              = FND_GLOBAL.conc_login_id
       ,source_lang                    = USERENV('LANG')
       ,program_type_name              = DECODE( p_program_type_name,  NULL, program_type_name, FND_API.g_miss_char, NULL, p_program_type_name)
       ,program_type_description       = DECODE( p_program_type_description, NULL, program_type_description, FND_API.g_miss_char, NULL, p_program_type_description)
   WHERE PROGRAM_TYPE_ID = p_PROGRAM_TYPE_ID
     AND USERENV('LANG') IN (language, source_lang);

   IF (SQL%NOTFOUND) THEN
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('PV', 'PV_RECORD_NOT_FOUND');
      FND_MSG_PUB.add;
   END IF;
   RAISE FND_API.g_exc_error;
  END IF;

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
         p_PROGRAM_TYPE_ID  NUMBER
        ,p_object_version_number  NUMBER
        )
 IS
 BEGIN

   DELETE FROM PV_PARTNER_PROGRAM_TYPE_TL
    WHERE PROGRAM_TYPE_ID = p_PROGRAM_TYPE_ID;

   IF (SQL%NOTFOUND) THEN
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('PV', 'PV_RECORD_NOT_FOUND');
       FND_MSG_PUB.add;
     END IF;
     RAISE FND_API.g_exc_error;
   END IF;

   DELETE FROM PV_PARTNER_PROGRAM_TYPE_B
    WHERE PROGRAM_TYPE_ID = p_PROGRAM_TYPE_ID
     AND object_version_number = p_object_version_number;

   IF (SQL%NOTFOUND) THEN
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('PV', 'PV_RECORD_NOT_FOUND');
       FND_MSG_PUB.add;
     END IF;
     RAISE FND_API.g_exc_error;
   END IF;

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
            px_PROGRAM_TYPE_ID  IN OUT NOCOPY  NUMBER
           ,p_active_flag                     VARCHAR2
           ,p_enabled_flag                    VARCHAR2
           ,px_object_version_number  IN OUT NOCOPY  NUMBER
           ,p_creation_date                   DATE
           ,p_created_by                      NUMBER
           ,p_last_update_date                DATE
           ,p_last_updated_by                 NUMBER
           ,p_last_update_login               NUMBER
           )

 IS
   CURSOR C IS
        SELECT *
         FROM PV_PARTNER_PROGRAM_TYPE_B
        WHERE PROGRAM_TYPE_ID =  px_PROGRAM_TYPE_ID
        FOR UPDATE of PROGRAM_TYPE_ID NOWAIT;
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
           (      Recinfo.PROGRAM_TYPE_ID = px_PROGRAM_TYPE_ID)
       AND (    ( Recinfo.active_flag = p_active_flag)
            OR (    ( Recinfo.active_flag IS NULL )
                AND (  p_active_flag IS NULL )))
       AND (    ( Recinfo.enabled_flag = p_enabled_flag)
            OR (    ( Recinfo.enabled_flag IS NULL )
                AND (  p_enabled_flag IS NULL )))
       AND (    ( Recinfo.object_version_number = px_object_version_number)
            OR (    ( Recinfo.object_version_number IS NULL )
                AND (  px_object_version_number IS NULL )))
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
       ) THEN
       RETURN;
   ELSE
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;

END Lock_Row;




--  ========================================================
--
--  NAME
--  Add_Language
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Add_Language
IS
BEGIN
   -- changing by ktsao as per performance team guidelines to fix performance issue
   -- as described in bug 3723612 (*** RTIKKU  03/24/05 12:46pm ***)
   INSERT /*+ append parallel(tt) */  INTO PV_PARTNER_PROGRAM_TYPE_TL tt (
            PROGRAM_TYPE_ID
           ,LAST_UPDATE_DATE
           ,LAST_UPDATED_BY
           ,CREATION_DATE
           ,CREATED_BY
           ,LAST_UPDATE_LOGIN
           ,LANGUAGE
           ,SOURCE_LANG
           ,PROGRAM_TYPE_NAME
           ,PROGRAM_TYPE_DESCRIPTION
   )
   select /*+ parallel(v) parallel(t) use_nl(t)  */ v.* from
    ( SELECT /*+ no_merge ordered parallel(b) */
            B.PROGRAM_TYPE_ID
           ,B.LAST_UPDATE_DATE
           ,B.LAST_UPDATED_BY
           ,B.CREATION_DATE
           ,B.CREATED_BY
           ,B.LAST_UPDATE_LOGIN
           ,L.LANGUAGE_CODE
           ,B.SOURCE_LANG
           ,B.PROGRAM_TYPE_NAME
           ,B.PROGRAM_TYPE_DESCRIPTION

      FROM PV_PARTNER_PROGRAM_TYPE_TL B ,
        FND_LANGUAGES L
   WHERE L.INSTALLED_FLAG IN ( 'I','B' )
     AND B.LANGUAGE = USERENV ( 'LANG' )
   ) v, PV_PARTNER_PROGRAM_TYPE_TL t
    WHERE t.PROGRAM_TYPE_ID(+) = v.PROGRAM_TYPE_ID
   AND t.language(+) = v.language_code
   AND t.PROGRAM_TYPE_ID IS NULL;

END Add_Language;




--  ========================================================
--
--  NAME
--  Translate_Row
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Translate_Row(
       px_PROGRAM_TYPE_ID      	 IN  NUMBER
      ,p_program_type_name               IN  VARCHAR2
      ,p_program_type_description        IN  VARCHAR2
      ,p_owner             	         IN  VARCHAR2
      )

IS

 BEGIN
    UPDATE PV_PARTNER_PROGRAM_TYPE_TL SET
       PROGRAM_TYPE_NAME               = NVL(p_program_type_name, program_type_name)
      ,PROGRAM_TYPE_DESCRIPTION        = NVL(p_program_type_description, program_type_description)
      ,SOURCE_LANG                     = USERENV('LANG')
      ,LAST_UPDATE_DATE                = SYSDATE
      ,LAST_UPDATED_BY                 = DECODE(p_owner, 'SEED', 1, 0)
      ,LAST_UPDATE_LOGIN               = 0
    WHERE  PROGRAM_TYPE_ID = px_PROGRAM_TYPE_ID
    AND      USERENV('LANG') IN (language, source_lang);

END TRANSLATE_ROW;


END PV_PARTNER_PGM_TYPE_PKG;

/
