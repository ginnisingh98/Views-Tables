--------------------------------------------------------
--  DDL for Package Body AMS_DM_TARGET_VALUES_B_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_DM_TARGET_VALUES_B_PKG" as
/* $Header: amstdtvb.pls 115.5 2003/03/07 03:54:23 choang noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_DM_TARGET_VALUES_B_PKG
-- Purpose
--
-- History
-- 08-Oct-2002 nyostos  Added value_condition column
-- 16-Oct-2002 choang   Added target_operator and range_value, replacing value_condition
-- 06-Mar-2003 choang   Added x_custom_mode to load_row for bug 2819067.
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME  CONSTANT VARCHAR2(30)   := 'AMS_DM_TARGET_VALUES_B_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12)   := 'amstdtvb.pls';


----------------------------------------------------------
----          Data Mining Target Values           ----
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
   px_target_value_id         IN OUT NOCOPY NUMBER,
   p_last_update_date         DATE,
   p_last_updated_by          NUMBER,
   p_creation_date            DATE,
   p_created_by               NUMBER,
   p_last_update_login        NUMBER,
   px_object_version_number   IN OUT NOCOPY NUMBER,
   p_target_id                NUMBER,
   p_target_value             VARCHAR2,
   p_target_operator          IN VARCHAR2,
   p_range_value              IN VARCHAR2,
   p_description              VARCHAR2)
IS
   x_rowid    VARCHAR2(30);
BEGIN
   px_object_version_number := 1;


   INSERT INTO AMS_DM_TARGET_VALUES_B(
           target_value_id,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           object_version_number,
           target_id,
           target_value,
           target_operator,
           range_value
   ) VALUES (
           DECODE( px_target_value_id, FND_API.g_miss_num, NULL, px_target_value_id),
           DECODE( p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date),
           DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by),
           DECODE( p_creation_date, FND_API.g_miss_date, NULL, p_creation_date),
           DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by),
           DECODE( p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login),
           DECODE( px_object_version_number, FND_API.g_miss_num, NULL, px_object_version_number),
           DECODE( p_target_id, FND_API.g_miss_num, NULL, p_target_id),
           DECODE( p_target_value, FND_API.g_miss_char, NULL, p_target_value),
           DECODE( p_target_operator, FND_API.g_miss_char, NULL, p_target_operator),
           DECODE( p_range_value, FND_API.g_miss_char, NULL, p_range_value)
   );

   -- Insert target value description into TL table
   INSERT INTO ams_dm_target_values_tl(
      target_value_id,
      language,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      source_lang,
      description
   )
   SELECT
      decode( px_target_value_id, FND_API.G_MISS_NUM, NULL, px_target_value_id),
      l.language_code,
      SYSDATE,
      FND_GLOBAL.user_id,
      SYSDATE,
      FND_GLOBAL.user_id,
      FND_GLOBAL.conc_login_id,
      USERENV('LANG'),
      decode( p_description, FND_API.G_MISS_CHAR, NULL, p_description)
   FROM fnd_languages l
   WHERE l.installed_flag in ('I', 'B')
   AND NOT EXISTS(
         SELECT NULL
         FROM ams_dm_target_values_tl t
         WHERE t.target_value_id = decode( px_target_value_id, FND_API.G_MISS_NUM, NULL, px_target_value_id)
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
         p_target_value_id          NUMBER,
         p_last_update_date         DATE,
         p_last_updated_by          NUMBER,
         p_last_update_login        NUMBER,
         p_object_version_number    NUMBER,
         p_target_id                NUMBER,
         p_target_value             VARCHAR2,
         p_target_operator          IN VARCHAR2,
         p_range_value              IN VARCHAR2,
         p_description              VARCHAR2)
 IS
 BEGIN
    Update AMS_DM_TARGET_VALUES_B
    SET
              target_value_id       = DECODE( p_target_value_id,  FND_API.g_miss_num, target_value_id, p_target_value_id),
              last_update_date      = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
              last_updated_by       = DECODE( p_last_updated_by,  FND_API.g_miss_num, last_updated_by, p_last_updated_by),
              last_update_login     = DECODE( p_last_update_login,FND_API.g_miss_num, last_update_login, p_last_update_login),
              object_version_number = DECODE( p_object_version_number, FND_API.g_miss_num, object_version_number, p_object_version_number),
              target_id             = DECODE( p_target_id,        FND_API.g_miss_num, target_id, p_target_id),
              target_value          = DECODE( p_target_value,     FND_API.g_miss_char, target_value, p_target_value),
              target_operator       = DECODE( p_target_operator,  FND_API.g_miss_char, target_operator, p_target_operator),
              range_value           = DECODE( p_range_value,  FND_API.g_miss_char, range_value, p_range_value)
   WHERE TARGET_VALUE_ID = p_TARGET_VALUE_ID
   ;

   IF (SQL%NOTFOUND) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- update target value description in TL table
   update ams_dm_target_values_tl set
      description = decode( p_description, FND_API.G_MISS_CHAR, DESCRIPTION, p_description),
      last_update_date = SYSDATE,
      last_updated_by = FND_GLOBAL.user_id,
      last_update_login = FND_GLOBAL.conc_login_id,
      source_lang = USERENV('LANG')
   WHERE target_value_id = p_target_value_id
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
    p_TARGET_VALUE_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM AMS_DM_TARGET_VALUES_B
    WHERE TARGET_VALUE_ID = p_TARGET_VALUE_ID;
   If (SQL%NOTFOUND) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   End If;


   DELETE FROM ams_dm_target_values_tl
    WHERE TARGET_VALUE_ID = p_TARGET_VALUE_ID;
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
         p_target_value_id          NUMBER,
         p_last_update_date         DATE,
         p_last_updated_by          NUMBER,
         p_creation_date            DATE,
         p_created_by               NUMBER,
         p_last_update_login        NUMBER,
         p_object_version_number    NUMBER,
         p_target_id                NUMBER,
         p_target_value             VARCHAR2)
 IS
   CURSOR C IS
        SELECT *
         FROM AMS_DM_TARGET_VALUES_B
        WHERE TARGET_VALUE_ID =  p_TARGET_VALUE_ID
        FOR UPDATE of TARGET_VALUE_ID NOWAIT;
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
           (      Recinfo.target_value_id = p_target_value_id)
       AND (    ( Recinfo.object_version_number = p_object_version_number)
            OR (    ( Recinfo.object_version_number IS NULL )
                AND (  p_object_version_number IS NULL )))
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

  delete from AMS_DM_TARGET_VALUES_TL T
  where not exists
    (select NULL
    from AMS_DM_TARGET_VALUES_B B
    where B.TARGET_VALUE_ID = T.TARGET_VALUE_ID
    );

  update AMS_DM_TARGET_VALUES_TL T set (
      DESCRIPTION
    ) = (select
      B.DESCRIPTION
    from AMS_DM_TARGET_VALUES_TL B
    where B.TARGET_VALUE_ID = T.TARGET_VALUE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.TARGET_VALUE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.TARGET_VALUE_ID,
      SUBT.LANGUAGE
    from AMS_DM_TARGET_VALUES_TL SUBB, AMS_DM_TARGET_VALUES_TL SUBT
    where SUBB.TARGET_VALUE_ID = SUBT.TARGET_VALUE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into AMS_DM_TARGET_VALUES_TL (
    TARGET_VALUE_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.TARGET_VALUE_ID,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AMS_DM_TARGET_VALUES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AMS_DM_TARGET_VALUES_TL T
    where T.TARGET_VALUE_ID = B.TARGET_VALUE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
END add_language;


PROCEDURE translate_row (
   x_target_value_id	IN NUMBER,
   x_description	IN VARCHAR2,
   x_owner		IN VARCHAR2
)
IS
BEGIN
    update ams_dm_target_values_tl set
       description = nvl(x_description, description),
       source_lang = userenv('LANG'),
       last_update_date = sysdate,
       last_updated_by = decode(x_owner, 'SEED', 1, 0),
       last_update_login = 0
    where  target_value_id = x_target_value_id
    and    userenv('LANG') in (language, source_lang);
end TRANSLATE_ROW;


PROCEDURE load_row (
   x_target_value_id IN NUMBER,
   x_target_id       IN NUMBER,
   x_target_value    VARCHAR2,
   x_target_operator IN VARCHAR2,
   x_range_value     IN VARCHAR2,
   x_description     VARCHAR2,
   x_owner           IN VARCHAR2,
   x_custom_mode     IN VARCHAR2
)
IS
   l_user_id         number := 0;
   l_obj_verno       number;
   l_db_luby_id      number;
   l_row_id          varchar2(100);
   l_target_value_id number;

   cursor c_chk_target_value_exists is
     select last_updated_by, nvl(object_version_number, 1)
     from   ams_dm_target_values_b
     where  target_value_id = x_target_value_id;

   cursor c_get_target_value_id is
      select ams_dm_target_values_b_s.nextval
      from dual;

BEGIN

   if x_owner = 'SEED' then
      l_user_id := 1;
   end if;

   open c_chk_target_value_exists;
   fetch c_chk_target_value_exists into l_db_luby_id, l_obj_verno;
   if c_chk_target_value_exists%notfound THEN
      if x_target_value_id is null then
         open c_get_target_value_id;
         fetch c_get_target_value_id into l_target_value_id;
         close c_get_target_value_id;
      else
         l_target_value_id := x_target_value_id;
      end if;

      l_obj_verno := 1;

      AMS_DM_TARGET_VALUES_B_PKG.INSERT_ROW (
         px_target_value_id         => l_target_value_id,
         p_last_update_date         => SYSDATE,
         p_last_updated_by          => l_user_id,
         p_creation_date            => SYSDATE,
         p_created_by               => l_user_id,
         p_last_update_login        => 0,
         px_object_version_number   => l_obj_verno,
         p_target_id                =>  x_target_id,
         p_target_value             =>  x_target_value,
         p_target_operator          => x_target_operator,
         p_range_value              => x_range_value,
         p_description              => x_description
      );
   else
      if ( l_db_luby_id IN (1, 2, 0) OR NVL(x_custom_mode,'PRESERVE') = 'FORCE') THEN
         AMS_DM_TARGET_VALUES_B_PKG.UPDATE_ROW (
            p_target_value_id       => x_target_value_id,
            p_last_update_date      => SYSDATE,
            p_last_updated_by       => l_user_id,
            p_last_update_login     => 0,
            p_object_version_number => l_obj_verno,
            p_target_id             => x_target_id,
            p_target_value          => x_target_value,
            p_target_operator       => x_target_operator,
            p_range_value           => x_range_value,
            p_description           => x_description
         );
      end if;  -- last updated by and force update
   end if;
   close c_chk_target_value_exists;
END load_row;

END AMS_DM_TARGET_VALUES_B_PKG;

/
