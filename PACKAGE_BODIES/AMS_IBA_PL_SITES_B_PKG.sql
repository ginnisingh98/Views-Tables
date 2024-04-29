--------------------------------------------------------
--  DDL for Package Body AMS_IBA_PL_SITES_B_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_IBA_PL_SITES_B_PKG" as
/* $Header: amstsitb.pls 115.18 2003/03/12 00:28:51 ryedator ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--        AMS_IBA_PL_SITES_B_PKG
-- Purpose
--		Table api to insert/update/delete iMarketing Sites.
-- History
--      18-Apr-2000 	sodixit		Created.
-- NOTE
--
-- End of Comments
-- ===============================================================

G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_IBA_PL_SITES_B_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amstsitb.pls';

--  ========================================================
--
--  NAME
--  		createInsertBody
--  PURPOSE
--		Table api to insert iMarketing Sites.
--  NOTES
--
--  HISTORY
--
--  ========================================================
AMS_DEBUG_HIGH_ON constant boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON constant boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON constant boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Insert_Row(
          px_site_id   IN OUT NOCOPY NUMBER,
          p_site_ref_code    VARCHAR2,
          p_site_category_type    VARCHAR2,
          p_site_category_object_id    NUMBER,
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


   INSERT INTO ams_iba_pl_sites_b(
           site_id,
           site_ref_code,
           site_category_type,
           site_category_object_id,
           status_code,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login,
           object_version_number
   ) VALUES (
           DECODE( px_site_id, FND_API.g_miss_num, NULL, px_site_id),
           DECODE( p_site_ref_code, FND_API.g_miss_char, NULL, p_site_ref_code),
           DECODE( p_site_category_type, FND_API.g_miss_char, NULL, p_site_category_type),
           DECODE( p_site_category_object_id, FND_API.g_miss_num, NULL, p_site_category_object_id),
           DECODE( p_status_code, FND_API.g_miss_char, NULL, p_status_code),
           DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by),
           DECODE( p_creation_date, FND_API.g_miss_date, NULL, p_creation_date),
           DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by),
           DECODE( p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date),
           DECODE( p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login),
           DECODE( px_object_version_number, FND_API.g_miss_num, NULL, px_object_version_number));

  INSERT INTO ams_iba_pl_sites_tl (
		site_id,
		name,
		description,
		created_by,
		creation_date,
		last_updated_by,
		last_update_date,
		last_update_login,
		object_version_number,
		language,
		source_lang
  )
  SELECT
		DECODE( px_site_id, FND_API.g_miss_num, NULL, px_site_id),
          DECODE( p_name, FND_API.g_miss_char, NULL, p_name),
		DECODE( p_description, FND_API.g_miss_char, NULL, p_description),
          DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by),
		DECODE( p_creation_date, FND_API.g_miss_date, NULL, p_creation_date),
		DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by),
		DECODE( p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date),
		DECODE( p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login),
	     DECODE( px_object_version_number, FND_API.g_miss_num, NULL, px_object_version_number),
		l.language_code,
		USERENV('LANG')
  FROM 	fnd_languages l
  WHERE 	l.installed_flag in ('I', 'B')
  AND 	NOT EXISTS(
			    	 SELECT NULL
				 FROM ams_iba_pl_sites_tl t
				 WHERE t.site_id = DECODE( px_site_id, FND_API.g_miss_num, NULL, px_site_id)
				    AND t.language = l.language_code);

END Insert_Row;


--  ========================================================
--
--  NAME
--  		createUpdateBody
--  PURPOSE
--		Table api to update iMarketing Sites.
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Update_Row(
          p_site_id    NUMBER,
          p_site_ref_code    VARCHAR2,
          p_site_category_type    VARCHAR2,
          p_site_category_object_id    NUMBER,
          p_status_code    VARCHAR2,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
	  p_name	VARCHAR2,
	  p_description VARCHAR2)
IS
BEGIN
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('table handler : before update site_id = ' || p_site_id );
   END IF;
    UPDATE ams_iba_pl_sites_b
    SET
              last_update_date = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
              last_updated_by = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
              last_update_login = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
              site_ref_code = DECODE( p_site_ref_code, FND_API.g_miss_char, site_ref_code, p_site_ref_code),
	      site_category_object_id  = DECODE(p_site_category_object_id , FND_API.g_miss_num, site_category_object_id, p_site_category_object_id )
	      -- anchaudh 12/26/2002 : fixed bug#2678933.
   WHERE site_id = p_site_id;

   IF (SQL%NOTFOUND) THEN
		RAISE no_data_found;
   END IF;


  UPDATE ams_iba_pl_sites_tl
  SET
	 	name 			= DECODE(p_name,FND_API.g_miss_char,name,p_name),
		description 		= DECODE(p_description,FND_API.g_miss_char,description,p_description),
		last_update_date 	= DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
		last_updated_by 	= DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
		last_update_login 	= DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
		source_lang             = userenv('LANG')
  where 	site_id 		= p_site_id
  AND 	USERENV('LANG') in (language, source_lang);

  IF (SQL%NOTFOUND) THEN
		RAISE  no_data_found;
  END IF;


END Update_Row;


--  ========================================================
--
--  NAME
--  		createDeleteBody
--  PURPOSE
--		Table api to delete iMarketing Sites.
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Delete_Row(
    p_site_id  NUMBER,
    p_object_version_number NUMBER)
 IS
BEGIN
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('table handler : before delete of b; site_id = ' || p_site_id || ' object_version_num = ' || p_object_version_number);
   END IF;
   DELETE FROM ams_iba_pl_sites_b
   WHERE site_id = p_site_id
   AND   object_version_number = p_object_version_number;

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_UTILITY_PVT.debug_message('table handler : After delete of b; site_id = ' || p_site_id || ' object_version_num = ' || p_object_version_number);

   END IF;

   If (SQL%NOTFOUND) then
		RAISE no_data_found;
   End If;

   DELETE FROM ams_iba_pl_sites_tl
   WHERE site_id = p_site_id
   AND   object_version_number = p_object_version_number;

   If (SQL%NOTFOUND) then
		RAISE no_data_found;
   End If;
END Delete_Row ;

procedure ADD_LANGUAGE
is
begin
  delete from AMS_IBA_PL_SITES_TL T
  where not exists
    (select NULL
    from AMS_IBA_PL_SITES_B B
    where B.SITE_ID = T.SITE_ID
    );

  update AMS_IBA_PL_SITES_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from AMS_IBA_PL_SITES_TL B
    where B.SITE_ID = T.SITE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.SITE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.SITE_ID,
      SUBT.LANGUAGE
    from AMS_IBA_PL_SITES_TL SUBB, AMS_IBA_PL_SITES_TL SUBT
    where SUBB.SITE_ID = SUBT.SITE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into AMS_IBA_PL_SITES_TL (
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    SECURITY_GROUP_ID,
    OBJECT_VERSION_NUMBER,
    SITE_ID,
    NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.SECURITY_GROUP_ID,
    B.OBJECT_VERSION_NUMBER,
    B.SITE_ID,
    B.NAME,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AMS_IBA_PL_SITES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AMS_IBA_PL_SITES_TL T
    where T.SITE_ID = B.SITE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;


--  ========================================================
--
--  NAME
--  	createLockBody
--
--  PURPOSE
--	Table api to lock iMarketing Sites.
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Lock_Row(
          p_site_id    NUMBER,
          p_site_ref_code    VARCHAR2,
          p_site_category_type    VARCHAR2,
          p_site_category_object_id    NUMBER,
          p_status_code    VARCHAR2,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_name in VARCHAR2,
          p_description in VARCHAR2
)

 IS
   CURSOR C IS
        SELECT *
         FROM AMS_IBA_PL_SITES_B
        WHERE SITE_ID =  p_SITE_ID
        FOR UPDATE of SITE_ID NOWAIT;
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
           (      Recinfo.site_id = p_site_id)
       AND (    ( Recinfo.site_ref_code = p_site_ref_code)
            OR (    ( Recinfo.site_ref_code IS NULL )
                AND (  p_site_ref_code IS NULL )))
       AND (    ( Recinfo.site_category_type = p_site_category_type)
            OR (    ( Recinfo.site_category_type IS NULL )
                AND (  p_site_category_type IS NULL )))
       AND (    ( Recinfo.site_category_object_id = p_site_category_object_id)
            OR (    ( Recinfo.site_category_object_id IS NULL )
                AND (  p_site_category_object_id IS NULL )))
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
   x_site_id IN NUMBER,
   x_name IN VARCHAR2,
   x_description IN VARCHAR2,
   x_owner IN VARCHAR2,
   x_custom_mode  IN VARCHAR2
)
IS
  cursor c_last_updated_by is
    select last_updated_by
    from ams_iba_pl_sites_tl
    where site_id = x_site_id
    and  USERENV('LANG') = LANGUAGE;

    l_luby number; --last updated by

BEGIN
    open c_last_updated_by;
    fetch c_last_updated_by into l_luby;
    close c_last_updated_by;

    if (l_luby IN (0, 1, 2) or NVL(x_custom_mode, 'PRESERVE')='FORCE')
    then

    update ams_iba_pl_sites_tl set
       name = nvl(x_name, name),
       description = nvl(x_description, description),
       source_lang = userenv('LANG'),
       last_update_date = sysdate,
       last_updated_by = decode(x_owner, 'SEED', 1,
				'ORACLE', 2,
				'SYSADMIN', 0, -1),
       last_update_login = 0
    where  site_id = x_site_id
    and      userenv('LANG') in (language, source_lang);
    end if;
end TRANSLATE_ROW;

PROCEDURE load_row (
   x_site_id           IN NUMBER,
   x_site_ref_code     IN VARCHAR2,
   x_site_ctgy_type        IN VARCHAR2,
   x_site_ctgy_obj_id        IN NUMBER,
   x_status_code	IN VARCHAR2,
   x_name         IN VARCHAR2,
   x_description  IN VARCHAR2,
   x_owner               IN VARCHAR2,
  X_CUSTOM_MODE          IN VARCHAR2
)
IS
   l_user_id      number :=1;
   l_obj_verno    number;
   l_dummy_char   varchar2(1);
   l_row_id       varchar2(100);
   l_site_id     number;
   l_db_luby_id   number;

  /* cursor  c_obj_verno is
     select object_version_number
     from    ams_iba_pl_sites_b
     where  site_id =  x_site_id;*/

     cursor c_db_data_details is
     select last_updated_by, nvl(object_version_number,1)
     from ams_iba_pl_sites_b
     where site_id =  x_site_id;

   cursor c_chk_site_exists is
     select 'x'
     from   ams_iba_pl_sites_b
     where  site_id = x_site_id;

   cursor c_get_site_id is
      select ams_iba_pl_sites_b_s.nextval
      from dual;
BEGIN
   if X_OWNER = 'SEED' then
      l_user_id := 1;
elsif X_OWNER = 'ORACLE' then
      l_user_id := 2;
   elsif X_OWNER = 'SYSADMIN' then
      l_user_id := 0;
   end if;

   open c_chk_site_exists;
   fetch c_chk_site_exists into l_dummy_char;
   if c_chk_site_exists%notfound THEN
      if x_site_id is null then
         open c_get_site_id;
         fetch c_get_site_id into l_site_id;
         close c_get_site_id;
      else
         l_site_id := x_site_id;
      end if;
      l_obj_verno := 1;

      AMS_IBA_PL_SITES_B_PKG.Insert_Row (
         px_site_id => l_site_id,
         p_site_ref_code => x_site_ref_code,
	 p_site_category_type => x_site_ctgy_type,
	 p_site_category_object_id => x_site_ctgy_obj_id,
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
      AMS_IBA_PL_SITES_B_PKG.UPDATE_ROW (
         p_site_id => x_site_id,
         p_site_ref_code => x_site_ref_code,
	 p_site_category_type => x_site_ctgy_type,
	 p_site_category_object_id => x_site_ctgy_obj_id,
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
   close c_chk_site_exists;
END load_row;

END AMS_IBA_PL_SITES_B_PKG;

/
