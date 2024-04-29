--------------------------------------------------------
--  DDL for Package Body AMS_IBA_PS_STRATS_B_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_IBA_PS_STRATS_B_PKG" as
/* $Header: amststrb.pls 120.1 2006/09/21 07:38:16 mayjain noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_IBA_PS_STRATS_B_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================

G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_IBA_PS_STRATS_B_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amststrb.pls';

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
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          px_strategy_id   IN OUT NOCOPY NUMBER,
          p_max_returned    NUMBER,
          p_strategy_type    VARCHAR2,
          p_content_type    VARCHAR2,
          p_strategy_ref_code    VARCHAR2,
          p_selector_class    VARCHAR2,
          p_strategy_name   IN VARCHAR2,
          p_strategy_description    IN VARCHAR2)

 IS
   x_rowid    VARCHAR2(30);

BEGIN

   px_object_version_number := 1;

   INSERT INTO AMS_IBA_PS_STRATS_B(
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login,
           object_version_number,
           strategy_id,
           max_returned,
           strategy_type,
           content_type,
           strategy_ref_code,
           selector_class
   ) VALUES (
           DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by),
           DECODE( p_creation_date, FND_API.g_miss_date, NULL, p_creation_date),
           DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by),
           DECODE( p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date),
           DECODE( p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login),
           DECODE( px_object_version_number, FND_API.g_miss_num, NULL, px_object_version_number),
           DECODE( px_strategy_id, FND_API.g_miss_num, NULL, px_strategy_id),
           DECODE( p_max_returned, FND_API.g_miss_num, NULL, p_max_returned),
           DECODE( p_strategy_type, FND_API.g_miss_char, NULL, p_strategy_type),
           DECODE( p_content_type, FND_API.g_miss_char, NULL, p_content_type),
           DECODE( p_strategy_ref_code, FND_API.g_miss_char, NULL, p_strategy_ref_code),
           DECODE( p_selector_class, FND_API.g_miss_char, NULL, p_selector_class));

INSERT INTO AMS_IBA_PS_STRATS_TL (
    created_by,
    creation_date,
    last_updated_by,
    last_update_date,
    last_update_login,
    object_version_number,
    strategy_id,
    strategy_name,
    strategy_description,
    language,
    source_lang
  ) SELECT
      DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by),
      DECODE( p_creation_date, FND_API.g_miss_date, NULL, p_creation_date),
      DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by),
      DECODE( p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date),
      DECODE( p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login),
     DECODE( px_object_version_number, FND_API.g_miss_num, NULL, px_object_version_number),
     DECODE( px_strategy_id, FND_API.g_miss_num, NULL, px_strategy_id),
     DECODE( p_strategy_name, FND_API.G_MISS_CHAR, NULL, p_strategy_name),
     DECODE( p_strategy_description, FND_API.G_MISS_CHAR, NULL, p_strategy_description),
    l.language_code,
    USERENV('LANG')
  FROM fnd_languages l
    WHERE l.installed_flag IN ('I', 'B')
     AND NOT EXISTS
    (SELECT null
      FROM ams_iba_ps_strats_tl t
      WHERE t.strategy_id = DECODE( px_strategy_id, FND_API.g_miss_num, NULL, px_strategy_id)
      AND t.language = l.language_code);

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
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_strategy_id    NUMBER,
          p_max_returned    NUMBER,
          p_strategy_type    VARCHAR2,
          p_content_type    VARCHAR2,
          p_strategy_ref_code    VARCHAR2,
          p_selector_class    VARCHAR2,
          p_strategy_name   IN VARCHAR2,
          p_strategy_description    IN VARCHAR2)

 IS
 BEGIN
    Update AMS_IBA_PS_STRATS_B
    SET
         created_by = DECODE( p_created_by, FND_API.g_miss_num, created_by, p_created_by),
         creation_date = DECODE( p_creation_date, FND_API.g_miss_date, creation_date, p_creation_date),
         last_updated_by = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
         last_update_date = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
         last_update_login = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
         object_version_number = DECODE( p_object_version_number, FND_API.g_miss_num, object_version_number, p_object_version_number),
--         strategy_id = DECODE( p_strategy_id, FND_API.g_miss_num, strategy_id, p_strategy_id),
         max_returned = DECODE( p_max_returned, FND_API.g_miss_num, max_returned, p_max_returned),
         strategy_type = DECODE( p_strategy_type, FND_API.g_miss_char, strategy_type, p_strategy_type),
         content_type = DECODE( p_content_type, FND_API.g_miss_char, content_type, p_content_type),
         strategy_ref_code = DECODE( p_strategy_ref_code, FND_API.g_miss_char, strategy_ref_code, p_strategy_ref_code),
         selector_class = DECODE( p_selector_class, FND_API.g_miss_char, selector_class, p_selector_class)
   WHERE STRATEGY_ID = p_STRATEGY_ID;
--   AND   object_version_number = p_object_version_number;

   IF (SQL%NOTFOUND) THEN
	RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

UPDATE ams_iba_ps_strats_tl SET
    strategy_name = decode( p_strategy_NAME, FND_API.G_MISS_CHAR, strategy_NAME, p_strategy_NAME),
    strategy_description = decode( p_strategy_DESCRIPTION, FND_API.G_MISS_CHAR, STRATEGY_DESCRIPTION, p_strategy_DESCRIPTION),
    last_updated_by = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
    last_update_date = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
    last_update_login = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
    source_lang = USERENV('LANG')
  WHERE strategy_id = p_strategy_id
  AND USERENV('LANG') IN (language, source_lang);

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END Update_Row;

----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  =======================================================
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
    p_STRATEGY_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM AMS_IBA_PS_STRATS_B
    WHERE STRATEGY_ID = p_STRATEGY_ID;
   If (SQL%NOTFOUND) then
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   End If;

   DELETE FROM AMS_IBA_PS_STRATS_TL
    WHERE STRATEGY_ID = p_STRATEGY_ID;
   If (SQL%NOTFOUND) then
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   End If;

 END Delete_Row ;

procedure ADD_LANGUAGE
is
begin
  delete from AMS_IBA_PS_STRATS_TL T
  where not exists
    (select NULL
    from AMS_IBA_PS_STRATS_B B
    where B.STRATEGY_ID = T.STRATEGY_ID
    );

  update AMS_IBA_PS_STRATS_TL T set (
      STRATEGY_NAME,
      STRATEGY_DESCRIPTION
    ) = (select
      B.STRATEGY_NAME,
      B.STRATEGY_DESCRIPTION
    from AMS_IBA_PS_STRATS_TL B
    where B.STRATEGY_ID = T.STRATEGY_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.STRATEGY_ID,
      T.LANGUAGE
  ) in (select
      SUBT.STRATEGY_ID,
      SUBT.LANGUAGE
    from AMS_IBA_PS_STRATS_TL SUBB, AMS_IBA_PS_STRATS_TL SUBT
    where SUBB.STRATEGY_ID = SUBT.STRATEGY_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.STRATEGY_NAME <> SUBT.STRATEGY_NAME
      or SUBB.STRATEGY_DESCRIPTION <> SUBT.STRATEGY_DESCRIPTION
      or (SUBB.STRATEGY_DESCRIPTION is null and SUBT.STRATEGY_DESCRIPTION is not null)
      or (SUBB.STRATEGY_DESCRIPTION is not null and SUBT.STRATEGY_DESCRIPTION is null)
  ));

  insert into AMS_IBA_PS_STRATS_TL (
    LAST_UPDATE_DATE,
    CREATION_DATE,
    LAST_UPDATED_BY,
    CREATED_BY,
    STRATEGY_ID,
    STRATEGY_NAME,
    STRATEGY_DESCRIPTION,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.LAST_UPDATE_DATE,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.CREATED_BY,
    B.STRATEGY_ID,
    B.STRATEGY_NAME,
    B.STRATEGY_DESCRIPTION,
    B.LAST_UPDATE_LOGIN,
    B.OBJECT_VERSION_NUMBER,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AMS_IBA_PS_STRATS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AMS_IBA_PS_STRATS_TL T
    where T.STRATEGY_ID = B.STRATEGY_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

--------------------------------------------------
----          MEDIA           ----
--------------------------------------------------

--  =======================================================
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
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_strategy_id    NUMBER,
          p_max_returned    NUMBER,
          p_strategy_type    VARCHAR2,
          p_content_type    VARCHAR2,
          p_strategy_ref_code    VARCHAR2,
          p_selector_class    VARCHAR2)

 IS
   CURSOR C IS
        SELECT *
         FROM AMS_IBA_PS_STRATS_B
        WHERE STRATEGY_ID =  p_STRATEGY_ID
        FOR UPDATE of STRATEGY_ID NOWAIT;
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
           (      Recinfo.created_by = p_created_by)
       AND (    ( Recinfo.creation_date = p_creation_date)
            OR (    ( Recinfo.creation_date IS NULL )
                AND (  p_creation_date IS NULL )))
       AND (    ( Recinfo.last_updated_by = p_last_updated_by)
            OR (    ( Recinfo.last_updated_by IS NULL )
                AND (  p_last_updated_by IS NULL )))
       AND (    ( Recinfo.last_update_date = p_last_update_date)
            OR (    ( Recinfo.last_update_date IS NULL )
                AND (  p_last_update_date IS NULL )))
       AND (    ( Recinfo.last_update_login = p_last_update_login)
            OR (    ( Recinfo.last_update_login IS NULL )
                AND (  p_last_update_login IS NULL )))
       AND (    ( Recinfo.object_version_number = p_object_version_number)
            OR (    ( Recinfo.object_version_number IS NULL )
                AND (  p_object_version_number IS NULL )))
       AND (    ( Recinfo.strategy_id = p_strategy_id)
            OR (    ( Recinfo.strategy_id IS NULL )
                AND (  p_strategy_id IS NULL )))
       AND (    ( Recinfo.max_returned = p_max_returned)
            OR (    ( Recinfo.max_returned IS NULL )
                AND (  p_max_returned IS NULL )))
       AND (    ( Recinfo.strategy_type = p_strategy_type)
            OR (    ( Recinfo.strategy_type IS NULL )
                AND (  p_strategy_type IS NULL )))
       AND (    ( Recinfo.content_type = p_content_type)
            OR (    ( Recinfo.content_type IS NULL )
                AND (  p_content_type IS NULL )))
       AND (    ( Recinfo.strategy_ref_code = p_strategy_ref_code)
            OR (    ( Recinfo.strategy_ref_code IS NULL )
                AND (  p_strategy_ref_code IS NULL )))
       AND (    ( Recinfo.selector_class = p_selector_class)
            OR (    ( Recinfo.selector_class IS NULL )
                AND (  p_selector_class IS NULL )))
       ) THEN
       RETURN;
   ELSE
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
END Lock_Row;

PROCEDURE TRANSLATE_ROW (
         x_strategy_id  IN NUMBER,
         x_strategy_name  IN VARCHAR2,
         x_strategy_description   IN VARCHAR2,
         x_owner   IN VARCHAR2,
         x_custom_mode  IN VARCHAR2
        )
IS
    cursor c_last_updated_by is
    select last_updated_by
    from ams_iba_ps_strats_tl
    where strategy_id = X_STRATEGY_ID
    and  USERENV('LANG') = LANGUAGE;

    l_luby number; --last updated by

BEGIN
    open c_last_updated_by;
    fetch c_last_updated_by into l_luby;
    close c_last_updated_by;

    if (l_luby IN (0, 1, 2) or NVL(x_custom_mode, 'PRESERVE')='FORCE')
    then
     update ams_iba_ps_strats_tl
     set
       strategy_name = nvl(x_strategy_name, strategy_name),
       strategy_description = nvl(x_strategy_description, strategy_description),
       source_lang = userenv('LANG'),
       last_update_date = sysdate,
       last_updated_by = decode(x_owner, 'SEED', 1,
				'ORACLE', 2,
				'SYSADMIN', 0, -1),
       last_update_login = 0
     where  strategy_id = x_strategy_id
     and   userenv('LANG') in (language, source_lang);
    end if;
END TRANSLATE_ROW;

PROCEDURE LOAD_ROW (
          X_STRATEGY_ID          IN NUMBER,
          X_MAX_RETURNED         IN NUMBER,
          X_CONTENT_TYPE         IN VARCHAR2,
          X_STRATEGY_TYPE        IN VARCHAR2,
          X_STRATEGY_REF_CODE    IN VARCHAR2,
          X_SELECTOR_CLASS       IN VARCHAR2,
          X_STRATEGY_NAME        IN VARCHAR2,
          X_STRATEGY_DESCRIPTION IN VARCHAR2,
          X_OWNER                IN VARCHAR2,
          X_CUSTOM_MODE          IN VARCHAR2
         )
IS
   l_user_id      number := 1;
   l_obj_verno    number;
   l_dummy_char   varchar2(1);
   l_row_id       varchar2(100);
   l_strategy_id  number;
   l_db_luby_id   number;
/*
   cursor c_obj_verno is
     select object_version_number
     from ams_iba_ps_strats_b
     where strategy_id = x_strategy_id;
*/
   cursor c_db_data_details is
     select last_updated_by, nvl(object_version_number,1)
     from ams_iba_ps_strats_b
     where strategy_id = x_strategy_id;

   cursor c_chk_strategy_exists is
     select 'x'
     from ams_iba_ps_strats_b
     where strategy_id = x_strategy_id;

   cursor c_get_strategy_id is
      select ams_iba_ps_strats_b_s.nextval
      from dual;
BEGIN

   if X_OWNER = 'SEED' then
      l_user_id := 1;
   elsif X_OWNER = 'ORACLE' then
      l_user_id := 2;
   elsif X_OWNER = 'SYSADMIN' then
      l_user_id := 0;
   end if;

   open c_chk_strategy_exists;
   fetch c_chk_strategy_exists into l_dummy_char;
   if c_chk_strategy_exists%notfound THEN
      if x_strategy_id is null then
         open c_get_strategy_id;
         fetch c_get_strategy_id into l_strategy_id;
         close c_get_strategy_id;
      else
         l_strategy_id := x_strategy_id;
      end if;

      l_obj_verno := 1;

      AMS_IBA_PS_STRATS_B_PKG.INSERT_ROW (
          p_created_by    =>  l_user_id,
          p_creation_date  =>  SYSDATE,
          p_last_updated_by  =>  l_user_id,
          p_last_update_date  =>  SYSDATE,
          p_last_update_login  =>   1,
          px_object_version_number  =>  l_obj_verno,
          px_strategy_id   =>   l_strategy_id,
          p_max_returned   =>   x_max_returned,
          p_strategy_type  => x_strategy_type,
          p_content_type  => x_content_type,
          p_strategy_ref_code  => x_strategy_ref_code,
          p_selector_class  => x_selector_class,
          p_strategy_name  => x_strategy_name,
          p_strategy_description => x_strategy_description
      );
   else
      open c_db_data_details;
      fetch c_db_data_details into l_db_luby_id, l_obj_verno;
      close c_db_data_details;

      if (l_db_luby_id IN (0, 1, 2) or NVL(x_custom_mode, 'PRESERVE')='FORCE')
      then
       l_strategy_id := x_strategy_id;

       AMS_IBA_PS_STRATS_B_PKG.UPDATE_ROW (
          p_created_by   => l_user_id,
          p_creation_date => SYSDATE,
          p_last_updated_by => l_user_id,
          p_last_update_date => SYSDATE,
          p_last_update_login => 1,
          p_object_version_number => l_obj_verno+1,
          p_strategy_id  => l_strategy_id,
          p_max_returned =>  x_max_returned,
          p_strategy_type => x_strategy_type,
          p_content_type => x_content_type,
          p_strategy_ref_code => x_strategy_ref_code,
          p_selector_class => x_selector_class,
          p_strategy_name => x_strategy_name,
          p_strategy_description => x_strategy_description
       );
      end if;

   end if;
   close c_chk_strategy_exists;
END LOAD_ROW;

END AMS_IBA_PS_STRATS_B_PKG;

/
