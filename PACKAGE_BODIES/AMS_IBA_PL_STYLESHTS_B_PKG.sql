--------------------------------------------------------
--  DDL for Package Body AMS_IBA_PL_STYLESHTS_B_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_IBA_PL_STYLESHTS_B_PKG" as
/* $Header: amststyb.pls 120.0 2005/05/31 23:24:49 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_IBA_PL_STYLESHTS_B_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_IBA_PL_STYLESHTS_B_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amststyb.pls';


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
AMS_DEBUG_HIGH_ON constant boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON constant boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON constant boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Insert_Row(
          px_stylesheet_id   IN OUT NOCOPY NUMBER,
          p_content_type    VARCHAR2,
          p_stylesheet_filename    VARCHAR2,
          p_status_code    VARCHAR2,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_name in VARCHAR2,
          p_description in VARCHAR2
)
IS
   x_rowid    VARCHAR2(30);

BEGIN


   px_object_version_number := 1;


IF (AMS_DEBUG_HIGH_ON) THEN
  AMS_UTILITY_PVT.debug_message('table handler : before actual insert');
END IF;

   INSERT INTO AMS_IBA_PL_STYLESHTS_B(
           stylesheet_id,
           content_type,
           stylesheet_filename,
           status_code,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login,
           object_version_number
   ) VALUES (
           DECODE( px_stylesheet_id, FND_API.g_miss_num, NULL, px_stylesheet_id),
           DECODE( p_content_type, FND_API.g_miss_char, NULL, p_content_type),
           DECODE( p_stylesheet_filename, FND_API.g_miss_char, NULL, p_stylesheet_filename),
           DECODE( p_status_code, FND_API.g_miss_char, NULL, p_status_code),
           DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by),
           DECODE( p_creation_date, FND_API.g_miss_date, NULL, p_creation_date),
           DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by),
           DECODE( p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date),
           DECODE( p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login),
           DECODE( px_object_version_number, FND_API.g_miss_num, NULL, px_object_version_number));

IF (AMS_DEBUG_HIGH_ON) THEN



AMS_UTILITY_PVT.debug_message( 'table handler : after insert into B table');

END IF;

  insert into AMS_IBA_PL_STYLESHTS_TL (
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER,
    STYLESHEET_ID,
    NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select
          DECODE( p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login),
          DECODE( px_object_version_number, FND_API.g_miss_num, NULL, px_object_version_number),
          DECODE( px_stylesheet_id, FND_API.g_miss_num, NULL, px_stylesheet_id),
          DECODE( p_name, FND_API.g_miss_char, NULL, p_name),
          DECODE( p_description, FND_API.g_miss_char, NULL, p_description),
          DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by),
          DECODE( p_creation_date, FND_API.g_miss_date, NULL, p_creation_date),
          DECODE( p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date),
          DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by),
    	  L.LANGUAGE_CODE,
	  userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
	    from AMS_IBA_PL_STYLESHTS_TL T
	    where T.STYLESHEET_ID = DECODE( px_stylesheet_id, FND_API.g_miss_num, NULL, px_stylesheet_id)
	    and T.LANGUAGE = L.LANGUAGE_CODE);

  IF (AMS_DEBUG_HIGH_ON) THEN



  AMS_UTILITY_PVT.debug_message('table handler : after insert into tl table');

  END IF;

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
          p_stylesheet_id    NUMBER,
          p_content_type    VARCHAR2,
          p_stylesheet_filename    VARCHAR2,
          p_status_code    VARCHAR2,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_name        VARCHAR2,
          p_description VARCHAR2)
 IS
 BEGIN
    Update AMS_IBA_PL_STYLESHTS_B
    SET
              content_type = DECODE( p_content_type, FND_API.g_miss_char, content_type, p_content_type),
              stylesheet_filename = DECODE( p_stylesheet_filename, FND_API.g_miss_char, stylesheet_filename, p_stylesheet_filename),
              status_code = DECODE( p_status_code, FND_API.g_miss_char, status_code, p_status_code),
              last_updated_by = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
              last_update_date = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
              last_update_login = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
              object_version_number = DECODE( p_object_version_number, FND_API.g_miss_num, object_version_number, p_object_version_number)
   WHERE STYLESHEET_ID = p_STYLESHEET_ID
   AND   object_version_number = p_object_version_number;

   IF (SQL%NOTFOUND) THEN
RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

  UPDATE ams_iba_pl_styleshts_tl SET
	    name 		= DECODE(p_name,FND_API.g_miss_char,name,p_name),
	    description 	= DECODE(p_description,FND_API.g_miss_char,description,p_description),
	    last_update_date 	= DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
	    last_updated_by 	= DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
	    last_update_login 	= DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
	    source_lang		= userenv('LANG')
  where stylesheet_id 		= p_stylesheet_iD
  and userenv('lang') in (language, source_lang);

  IF (SQL%NOTFOUND) THEN
                RAISE  FND_API.g_exc_error;
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
    p_STYLESHEET_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM ams_iba_pl_styleshts_b
    WHERE stylesheet_id = p_stylesheet_id;

   If (SQL%NOTFOUND) then
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   End If;

   DELETE FROM ams_iba_pl_styleshts_tl
   WHERE stylesheet_id = p_stylesheet_id;

 END Delete_Row ;

procedure ADD_LANGUAGE
is
begin
  delete from AMS_IBA_PL_STYLESHTS_TL T
  where not exists
    (select NULL
    from AMS_IBA_PL_STYLESHTS_B B
    where B.STYLESHEET_ID = T.STYLESHEET_ID
    );

  update AMS_IBA_PL_STYLESHTS_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from AMS_IBA_PL_STYLESHTS_TL B
    where B.STYLESHEET_ID = T.STYLESHEET_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.STYLESHEET_ID,
      T.LANGUAGE
  ) in (select
      SUBT.STYLESHEET_ID,
      SUBT.LANGUAGE
    from AMS_IBA_PL_STYLESHTS_TL SUBB, AMS_IBA_PL_STYLESHTS_TL SUBT
    where SUBB.STYLESHEET_ID = SUBT.STYLESHEET_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into AMS_IBA_PL_STYLESHTS_TL (
    OBJECT_VERSION_NUMBER,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    STYLESHEET_ID,
    NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.OBJECT_VERSION_NUMBER,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.STYLESHEET_ID,
    B.NAME,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AMS_IBA_PL_STYLESHTS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AMS_IBA_PL_STYLESHTS_TL T
    where T.STYLESHEET_ID = B.STYLESHEET_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;


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
          p_stylesheet_id    NUMBER,
          p_content_type    VARCHAR2,
          p_stylesheet_filename    VARCHAR2,
          p_status_code    VARCHAR2,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER)

 IS
   CURSOR C IS
        SELECT *
         FROM AMS_IBA_PL_STYLESHTS_B
        WHERE STYLESHEET_ID =  p_STYLESHEET_ID
        FOR UPDATE of STYLESHEET_ID NOWAIT;
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
           (      Recinfo.stylesheet_id = p_stylesheet_id)
       AND (    ( Recinfo.content_type = p_content_type)
            OR (    ( Recinfo.content_type IS NULL )
                AND (  p_content_type IS NULL )))
       AND (    ( Recinfo.stylesheet_filename = p_stylesheet_filename)
            OR (    ( Recinfo.stylesheet_filename IS NULL )
                AND (  p_stylesheet_filename IS NULL )))
       AND (    ( Recinfo.status_code = p_status_code)
            OR (    ( Recinfo.status_code IS NULL )
                AND (  p_status_code IS NULL )))
       AND (    ( Recinfo.created_by = p_created_by)
            OR (    ( Recinfo.created_by IS NULL )
                AND (  p_created_by IS NULL )))
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
       ) THEN
       RETURN;
   ELSE
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
END Lock_Row;

PROCEDURE translate_row (
   x_stylesheet_id IN NUMBER,
   x_name IN VARCHAR2,
   x_description IN VARCHAR2,
   x_owner IN VARCHAR2,
   x_custom_mode  IN VARCHAR2
  )
IS
cursor c_last_updated_by is
    select last_updated_by
    from AMS_IBA_PL_STYLESHTS_TL
    where stylesheet_id = x_stylesheet_id
    and  USERENV('LANG') = LANGUAGE;

    l_luby number; --last updated by

BEGIN
    open c_last_updated_by;
    fetch c_last_updated_by into l_luby;
    close c_last_updated_by;

  if (l_luby IN (0, 1, 2) or NVL(x_custom_mode, 'PRESERVE')='FORCE')
    then

    update AMS_IBA_PL_STYLESHTS_TL set
       name = nvl(x_name, name),
       description = nvl(x_description, description),
       source_lang = userenv('LANG'),
       last_update_date = sysdate,
        last_updated_by = decode(x_owner, 'SEED', 1,
				'ORACLE', 2,
				'SYSADMIN', 0, -1),
       last_update_login = 0
    where  stylesheet_id = x_stylesheet_id
    and      userenv('LANG') in (language, source_lang);
    end if;
end TRANSLATE_ROW;

PROCEDURE load_row (
   x_stylesheet_id           IN NUMBER,
   x_content_type            IN VARCHAR2,
   x_stylesheet_filename     IN VARCHAR2,
   x_status_code       IN VARCHAR2,
   x_name         IN VARCHAR2,
   x_description  IN VARCHAR2,
   x_owner               IN VARCHAR2,
   X_CUSTOM_MODE          IN VARCHAR2
  )
IS
   l_user_id      number := 1;
   l_obj_verno    number;
   l_dummy_char   varchar2(1);
   l_row_id       varchar2(100);
   l_stylesheet_id     number;
   l_db_luby_id   number;

   /*cursor  c_obj_verno is
     select object_version_number
     from    ams_iba_pl_styleshts_b
     where  stylesheet_id =  x_stylesheet_id;*/

 cursor c_db_data_details is
     select last_updated_by, nvl(object_version_number,1)
     from ams_iba_pl_styleshts_b
     where stylesheet_id =  x_stylesheet_id;

   cursor c_chk_style_exists is
     select 'x'
     from  ams_iba_pl_styleshts_b
     where stylesheet_id =  x_stylesheet_id;

   cursor c_get_stylesheet_id is
      select ams_iba_pl_styleshts_b_s.nextval
      from dual;
BEGIN
   if X_OWNER = 'SEED' then
      l_user_id := 1;
 elsif X_OWNER = 'ORACLE' then
      l_user_id := 2;
   elsif X_OWNER = 'SYSADMIN' then
      l_user_id := 0;
   end if;

   open c_chk_style_exists;
   fetch c_chk_style_exists into l_dummy_char;
   if c_chk_style_exists%notfound THEN
      if x_stylesheet_id is null then
         open c_get_stylesheet_id;
         fetch c_get_stylesheet_id into l_stylesheet_id;
         close c_get_stylesheet_id;
      else
         l_stylesheet_id := x_stylesheet_id;
      end if;
      l_obj_verno := 1;

      AMS_IBA_PL_STYLESHTS_B_PKG.Insert_Row (
         px_stylesheet_id => l_stylesheet_id,
         p_content_type => x_content_type,
         p_stylesheet_filename => x_stylesheet_filename,
         p_status_code => x_status_code,
         p_created_by => l_user_id,
         p_creation_date => SYSDATE,
         p_last_updated_by => l_user_id,
         p_last_update_date => SYSDATE,
         p_last_update_login => 1,
         px_object_version_number => l_obj_verno,
         p_name => x_name,
         p_description => x_description
      );
   else
       open c_db_data_details;
      fetch c_db_data_details into l_db_luby_id, l_obj_verno;
      close c_db_data_details;

  if (l_db_luby_id IN (0, 1, 2) or NVL(x_custom_mode, 'PRESERVE')='FORCE')
      then
      AMS_IBA_PL_STYLESHTS_B_PKG.UPDATE_ROW (
         p_stylesheet_id => x_stylesheet_id,
         p_content_type => x_content_type,
         p_stylesheet_filename => x_stylesheet_filename,
         p_status_code => x_status_code,
         p_created_by => l_user_id,
         p_creation_date => SYSDATE,
         p_last_updated_by => l_user_id,
         p_last_update_date => SYSDATE,
         p_last_update_login => 1,
         p_object_version_number => l_obj_verno,
         p_name => x_name,
         p_description => x_description
      );
   end if;
   end if;
   close c_chk_style_exists;
END load_row;

END AMS_IBA_PL_STYLESHTS_B_PKG;

/
