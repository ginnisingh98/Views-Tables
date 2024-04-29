--------------------------------------------------------
--  DDL for Package Body AMS_DM_TARGETS_B_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_DM_TARGETS_B_PKG" as
/* $Header: amstdtgb.pls 115.4 2003/09/15 12:44:47 rosharma noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_DM_TARGETS_B_PKG
-- Purpose
--
-- History
-- 10-Apr-2002 nyostos  Created.
-- 06-Mar-2003 choang   Added x_custom_mode to load_row for bug 2819067.
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_DM_TARGETS_B_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amstdtgb.pls';


----------------------------------------------------------
----          Data Mining Targets           ----
----------------------------------------------------------

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
          px_target_id			IN OUT NOCOPY NUMBER,
          p_last_update_date			DATE,
          p_last_updated_by			NUMBER,
          p_creation_date			DATE,
          p_created_by				NUMBER,
          p_last_update_login			NUMBER,
          px_object_version_number	IN OUT NOCOPY NUMBER,
          p_active_flag				VARCHAR2,
          p_model_type				VARCHAR2,
          p_data_source_id			NUMBER,
          p_source_field_id			NUMBER,
          p_target_name				VARCHAR2,
          p_description				VARCHAR2,
	  p_target_source_id                    NUMBER )

 IS
   x_rowid    VARCHAR2(30);


BEGIN


   px_object_version_number := 1;


   INSERT INTO AMS_DM_TARGETS_B(
           target_id,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           object_version_number,
           active_flag,
           model_type,
           data_source_id,
           source_field_id,
	   target_source_id
   ) VALUES (
           DECODE( px_target_id, FND_API.g_miss_num, NULL, px_target_id),
           DECODE( p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date),
           DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by),
           DECODE( p_creation_date, FND_API.g_miss_date, NULL, p_creation_date),
           DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by),
           DECODE( p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login),
           DECODE( px_object_version_number, FND_API.g_miss_num, NULL, px_object_version_number),
           DECODE( p_active_flag, FND_API.g_miss_char, NULL, p_active_flag),
           DECODE( p_model_type, FND_API.g_miss_char, NULL, p_model_type),
           DECODE( p_data_source_id, FND_API.g_miss_num, NULL, p_data_source_id),
           DECODE( p_source_field_id, FND_API.g_miss_num, NULL, p_source_field_id),
           DECODE( p_target_source_id, FND_API.g_miss_num, NULL, p_target_source_id));

   -- Insert target_name and description into TL table
   INSERT INTO ams_dm_targets_tl(
      target_id,
      language,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      source_lang,
      target_name,
      description
   )
   SELECT
      decode( px_target_id, FND_API.G_MISS_NUM, NULL, px_target_id),
      l.language_code,
      SYSDATE,
      FND_GLOBAL.user_id,
      SYSDATE,
      FND_GLOBAL.user_id,
      FND_GLOBAL.conc_login_id,
      USERENV('LANG'),
      decode( p_target_name, FND_API.G_MISS_CHAR, NULL, p_target_name),
      decode( p_description, FND_API.G_MISS_CHAR, NULL, p_description)
   FROM fnd_languages l
   WHERE l.installed_flag in ('I', 'B')
   AND NOT EXISTS(
         SELECT NULL
         FROM ams_dm_targets_tl t
         WHERE t.target_id = decode( px_target_id, FND_API.G_MISS_NUM, NULL, px_target_id)
         AND t.language = l.language_code );


END Insert_Row;


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
          p_target_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_active_flag    VARCHAR2,
          p_model_type    VARCHAR2,
          p_data_source_id    NUMBER,
          p_source_field_id    NUMBER,
          p_target_name    VARCHAR2,
          p_description    VARCHAR2,
	  p_target_source_id         NUMBER )

 IS
 BEGIN
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Table Handler Update going to Update AMS_DM_TARGETS_B' );
      END IF;
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message(p_target_id || ' ' || p_last_update_date || ' ' || p_last_updated_by);
      END IF;
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message(p_creation_date || ' ' || p_created_by || ' ' || p_last_update_login);
      END IF;
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message(p_object_version_number || ' ' || p_active_flag || ' ' || p_model_type);
      END IF;
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message(p_data_source_id || ' ' || p_source_field_id);
      END IF;
    Update AMS_DM_TARGETS_B
    SET
              target_id = DECODE( p_target_id, FND_API.g_miss_num, target_id, p_target_id),
              last_update_date = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
              last_updated_by = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
              creation_date = DECODE( p_creation_date, FND_API.g_miss_date, creation_date, p_creation_date),
              created_by = DECODE( p_created_by, FND_API.g_miss_num, created_by, p_created_by),
              last_update_login = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
              object_version_number = DECODE( p_object_version_number, FND_API.g_miss_num, object_version_number, p_object_version_number),
              active_flag = DECODE( p_active_flag, FND_API.g_miss_char, active_flag, p_active_flag),
              model_type = DECODE( p_model_type, FND_API.g_miss_char, model_type, p_model_type),
              data_source_id = DECODE( p_data_source_id, FND_API.g_miss_num, data_source_id, p_data_source_id),
              source_field_id = DECODE( p_source_field_id, FND_API.g_miss_num, source_field_id, p_source_field_id),
              target_source_id = DECODE( p_target_source_id, FND_API.g_miss_num, target_source_id, p_target_source_id)
   WHERE TARGET_ID = p_TARGET_ID
   AND   object_version_number = p_object_version_number;

   IF (SQL%NOTFOUND) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

      IF (AMS_DEBUG_HIGH_ON) THEN



      AMS_UTILITY_PVT.debug_message('Table Handler Update going to Update ams_dm_targets_tl' );

      END IF;

   -- update target name and description in TL table
   update ams_dm_targets_tl set
      target_name = decode( p_target_name, FND_API.G_MISS_CHAR, TARGET_NAME, p_target_name),
      description = decode( p_description, FND_API.G_MISS_CHAR, DESCRIPTION, p_description),
      last_update_date = SYSDATE,
      last_updated_by = p_last_updated_by,
      last_update_login = p_last_update_login,
      source_lang = USERENV('LANG')
   WHERE target_id = p_target_id
   AND USERENV('LANG') IN (language, source_lang);


END Update_Row;


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
    p_TARGET_ID  NUMBER)
 IS
 BEGIN

   DELETE FROM AMS_DM_TARGETS_B
    WHERE TARGET_ID = p_TARGET_ID;
   If (SQL%NOTFOUND) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   End If;

   DELETE FROM ams_dm_targets_tl
    WHERE TARGET_ID = p_TARGET_ID;
   If (SQL%NOTFOUND) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   End If;

 END Delete_Row ;


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
          p_target_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_active_flag    VARCHAR2,
          p_model_type    VARCHAR2,
          p_data_source_id    NUMBER,
          p_source_field_id    NUMBER,
	  p_target_source_id   NUMBER )

 IS
     CURSOR C IS
         SELECT *
           FROM AMS_DM_TARGETS_B
          WHERE TARGET_ID =  p_TARGET_ID
            FOR UPDATE of TARGET_ID NOWAIT;
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
           (      Recinfo.target_id = p_target_id)
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
       AND (    ( Recinfo.active_flag = p_active_flag)
            OR (    ( Recinfo.active_flag IS NULL )
                AND (  p_active_flag IS NULL )))
       AND (    ( Recinfo.model_type = p_model_type)
            OR (    ( Recinfo.model_type IS NULL )
                AND (  p_model_type IS NULL )))
       AND (    ( Recinfo.data_source_id = p_data_source_id)
            OR (    ( Recinfo.data_source_id IS NULL )
                AND (  p_data_source_id IS NULL )))
       AND (    ( Recinfo.source_field_id = p_source_field_id)
            OR (    ( Recinfo.source_field_id IS NULL )
                AND (  p_source_field_id IS NULL )))
       AND (    ( Recinfo.target_source_id = p_target_source_id)
            OR (    ( Recinfo.target_source_id IS NULL )
                AND (  p_target_source_id IS NULL )))
       ) THEN
       RETURN;
   ELSE
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
END Lock_Row;


PROCEDURE add_language
IS
BEGIN
  delete from AMS_DM_TARGETS_TL T
  where not exists
    (select NULL
    from AMS_DM_TARGETS_B B
    where B.TARGET_ID = T.TARGET_ID
    );

  update AMS_DM_TARGETS_TL T set (
      TARGET_NAME,
      DESCRIPTION
    ) = (select
      B.TARGET_NAME,
      B.DESCRIPTION
    from AMS_DM_TARGETS_TL B
    where B.TARGET_ID = T.TARGET_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.TARGET_ID,
      T.LANGUAGE
  ) in (select
      SUBT.TARGET_ID,
      SUBT.LANGUAGE
    from AMS_DM_TARGETS_TL SUBB, AMS_DM_TARGETS_TL SUBT
    where SUBB.TARGET_ID = SUBT.TARGET_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.TARGET_NAME <> SUBT.TARGET_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into AMS_DM_TARGETS_TL (
    TARGET_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    TARGET_NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.TARGET_ID,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.TARGET_NAME,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AMS_DM_TARGETS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AMS_DM_TARGETS_TL T
    where T.TARGET_ID = B.TARGET_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
END add_language;

PROCEDURE translate_row (
   x_target_id IN NUMBER,
   x_target_name IN VARCHAR2,
   x_description IN VARCHAR2,
   x_owner IN VARCHAR2
)
IS
BEGIN
    update ams_dm_targets_tl set
       target_name = nvl(x_target_name, target_name),
       description = nvl(x_description, description),
       source_lang = userenv('LANG'),
       last_update_date = sysdate,
       last_updated_by = decode(x_owner, 'SEED', 1, 0),
       last_update_login = 0
    where  target_id = x_target_id
    and    userenv('LANG') in (language, source_lang);
end TRANSLATE_ROW;


PROCEDURE load_row (
   x_target_id          IN NUMBER,
   x_active_flag        VARCHAR2,
   x_model_type         VARCHAR2,
   x_data_source_id     NUMBER,
   x_source_field_id    NUMBER,
   x_target_name        VARCHAR2,
   x_description        VARCHAR2,
   x_target_source_id   NUMBER,
   x_owner              IN VARCHAR2,
   x_custom_mode        IN VARCHAR2
)
IS
   l_user_id      number := 0;
   l_obj_verno    number;
   l_db_luby_id   number;
   l_row_id       varchar2(100);
   l_target_id     number;

   cursor c_chk_target_exists is
     select last_updated_by, nvl(object_version_number, 1)
     from   ams_dm_targets_b
     where  target_id = x_target_id;

   cursor c_get_target_id is
      select ams_dm_targets_b_s.nextval
      from dual;
BEGIN

   if x_owner = 'SEED' then
      l_user_id := 1;
   end if;

   open c_chk_target_exists;
   fetch c_chk_target_exists into l_db_luby_id, l_obj_verno;
   if c_chk_target_exists%notfound THEN
      if x_target_id is null then
         open c_get_target_id;
         fetch c_get_target_id into l_target_id;
         close c_get_target_id;
      else
         l_target_id := x_target_id;
      end if;
      l_obj_verno := 1;

      AMS_DM_TARGETS_B_PKG.INSERT_ROW (
         px_target_id => l_target_id,
         p_last_update_date => SYSDATE,
         p_last_updated_by => l_user_id,
         p_creation_date => SYSDATE,
         p_created_by => l_user_id,
         p_last_update_login => 0,
         px_object_version_number => l_obj_verno,
         p_active_flag  => x_active_flag,
         p_model_type  => x_model_type,
         p_data_source_id  => x_data_source_id,
         p_source_field_id  => x_source_field_id,
         p_target_name =>  x_target_name,
         p_description =>  x_description,
         p_target_source_id =>  x_target_source_id
      );
   else
      if ( l_db_luby_id IN (1, 2, 0) OR NVL(x_custom_mode,'PRESERVE') = 'FORCE') THEN
         AMS_DM_TARGETS_B_PKG.UPDATE_ROW (
            p_target_id => x_target_id,
            p_last_update_date => SYSDATE,
            p_last_updated_by => l_user_id,
            p_creation_date  => SYSDATE,
            p_created_by  => l_user_id,
            p_last_update_login => 0,
            p_object_version_number => l_obj_verno,
            p_active_flag  => x_active_flag,
            p_model_type  => x_model_type,
            p_data_source_id  => x_data_source_id,
            p_source_field_id  => x_source_field_id,
            p_target_name =>  x_target_name,
            p_description =>  x_description,
            p_target_source_id =>  x_target_source_id
         );
      end if;  -- last updated by and force update
   end if;
   close c_chk_target_exists;
END load_row;



END AMS_DM_TARGETS_B_PKG;

/
