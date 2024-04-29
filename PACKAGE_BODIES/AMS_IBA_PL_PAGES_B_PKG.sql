--------------------------------------------------------
--  DDL for Package Body AMS_IBA_PL_PAGES_B_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_IBA_PL_PAGES_B_PKG" as
/* $Header: amstpagb.pls 115.11 2003/03/12 00:26:04 ryedator ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_IBA_PL_PAGES_B_PKG
-- Purpose
--		Table api to insert/update/delete placement pages
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================

G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_IBA_PL_PAGES_B_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amstpagb.pls';

----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  		createInsertBody
--  PURPOSE
--		Table api to insert placement pages
--  NOTES
--
--  HISTORY
--
--  ========================================================
AMS_DEBUG_HIGH_ON constant boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON constant boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON constant boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Insert_Row(
          px_page_id   IN OUT NOCOPY NUMBER,
          p_site_id    NUMBER,
          p_site_ref_code    VARCHAR2,
          p_page_ref_code    VARCHAR2,
          p_status_code    VARCHAR2,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
	p_name         VARCHAR2,
	p_description  VARCHAR2)

 IS
   x_rowid    VARCHAR2(30);

BEGIN

   px_object_version_number := 1;

IF (AMS_DEBUG_HIGH_ON) THEN

AMS_UTILITY_PVT.debug_message( 'Table Handler : Just before insert');

END IF;
   INSERT INTO AMS_IBA_PL_PAGES_B(
           page_id,
           site_id,
           site_ref_code,
           page_ref_code,
           status_code,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login,
           object_version_number
   ) VALUES (
           DECODE( px_page_id, FND_API.g_miss_num, NULL, px_page_id),
           DECODE( p_site_id, FND_API.g_miss_num, NULL, p_site_id),
           DECODE( p_site_ref_code, FND_API.g_miss_char, NULL, p_site_ref_code),
           DECODE( p_page_ref_code, FND_API.g_miss_char, NULL, p_page_ref_code),
           DECODE( p_status_code, FND_API.g_miss_char, NULL, p_status_code),
           DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by),
           DECODE( p_creation_date, FND_API.g_miss_date, NULL, p_creation_date),
           DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by),
           DECODE( p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date),
           DECODE( p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login),
           DECODE( px_object_version_number, FND_API.g_miss_num, NULL, px_object_version_number)
);
IF (AMS_DEBUG_HIGH_ON) THEN

AMS_UTILITY_PVT.debug_message( 'Table Handler : Just after insert into b table');
END IF;
IF (AMS_DEBUG_HIGH_ON) THEN

AMS_UTILITY_PVT.debug_message( 'Table Handler : Just before insert into tl table');
END IF;

  INSERT INTO ams_iba_pl_pages_tl (
		page_id,
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
		DECODE( px_page_id, FND_API.g_miss_num, NULL, px_page_id),
		DECODE( p_name, FND_API.g_miss_char, NULL, p_name),
		DECODE( p_description, FND_API.g_miss_char, NULL, p_description),
		DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by),DECODE( p_creation_date, FND_API.g_miss_date, NULL, p_creation_date),
		DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by),
		DECODE( p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date),
		DECODE( p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login),
		DECODE( px_object_version_number, FND_API.g_miss_num, NULL, px_object_version_number),
		l.language_code,
		USERENV('LANG')
  FROM    fnd_languages l
  WHERE   l.installed_flag in ('I', 'B')
  AND     NOT EXISTS(
				SELECT NULL
				FROM ams_iba_pl_pages_tl t
				WHERE t.page_id = DECODE( px_page_id, FND_API.g_miss_num, NULL, px_page_id)
				AND t.language = l.language_code);
IF (AMS_DEBUG_HIGH_ON) THEN

AMS_UTILITY_PVT.debug_message( 'Table Handler : Just after insert into tl table');
END IF;

END Insert_Row;


----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  		createUpdateBody
--  PURPOSE
--		Table api to update placement pages
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Update_Row(
          p_page_id    NUMBER,
          p_site_id    NUMBER,
          p_site_ref_code    VARCHAR2,
          p_page_ref_code    VARCHAR2,
          p_status_code    VARCHAR2,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
		p_name              VARCHAR2,
		p_description       VARCHAR2)
IS
BEGIN
    Update AMS_IBA_PL_PAGES_B
    SET
        site_ref_code 	= DECODE( p_site_ref_code, FND_API.g_miss_char, site_ref_code, p_site_ref_code),
        page_ref_code 	= DECODE( p_page_ref_code, FND_API.g_miss_char, page_ref_code, p_page_ref_code),
       status_code 	= DECODE( p_status_code, FND_API.g_miss_char, status_code, p_status_code),
       last_updated_by 	= DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
              last_update_date 	= DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
              last_update_login 	= DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
              object_version_number = DECODE( p_object_version_number, FND_API.g_miss_num, object_version_number, p_object_version_number)
   WHERE PAGE_ID = p_PAGE_ID
   AND   object_version_number = p_object_version_number;

   IF (SQL%NOTFOUND) THEN
	RAISE  no_data_found;
   END IF;

  UPDATE ams_iba_pl_pages_tl
  SET
	name = DECODE(p_name,FND_API.g_miss_char,name,p_name),
	description 	= DECODE(p_description,FND_API.g_miss_char,description,p_description),
	last_update_date = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
	last_updated_by	= DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
	last_update_login = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
	source_lang 	= userenv('LANG')
  WHERE page_id = DECODE( p_page_id, FND_API.g_miss_num, page_id, p_page_id)
  AND USERENV('lang') IN (language, source_lang);


   IF (SQL%NOTFOUND) THEN
	RAISE  no_data_found;
   END IF;
END Update_Row;


----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  		createDeleteBody
--  PURPOSE
--		Table api to delete placement pages
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Delete_Row(p_page_id  NUMBER)
IS
BEGIN
   DELETE from ams_iba_pl_pages_b
    WHERE PAGE_ID = p_page_id;

   IF (SQL%NOTFOUND) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   DELETE FROM ams_iba_pl_pages_tL
    WHERE PAGE_ID = p_page_id;

   IF (SQL%NOTFOUND) THEN
	RAISE no_data_found;
   END IF;


 END Delete_Row ;


procedure ADD_LANGUAGE
is
begin
  delete from AMS_IBA_PL_PAGES_TL T
  where not exists
    (select NULL
    from AMS_IBA_PL_PAGES_B B
    where B.PAGE_ID = T.PAGE_ID
    );

  update AMS_IBA_PL_PAGES_TL T set (
      NAME,
      description
    ) = (select
      B.NAME,
      B.description
    from AMS_IBA_PL_PAGES_TL B
    where B.PAGE_ID = T.PAGE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.PAGE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.PAGE_ID,
      SUBT.LANGUAGE
    from AMS_IBA_PL_PAGES_TL SUBB, AMS_IBA_PL_PAGES_TL SUBT
    where SUBB.PAGE_ID = SUBT.PAGE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.LANGUAGE <> SUBT.LANGUAGE
  ));

  insert into AMS_IBA_PL_PAGES_TL (
    LAST_UPDATE_DATE,
    CREATION_DATE,
    LAST_UPDATED_BY,
    CREATED_BY,
    PAGE_ID,
    NAME,
    DESCRIPTION,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.LAST_UPDATE_DATE,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.CREATED_BY,
    B.PAGE_ID,
    B.NAME,
    B.DESCRIPTION,
    B.LAST_UPDATE_LOGIN,
    B.OBJECT_VERSION_NUMBER,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AMS_IBA_PL_PAGES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AMS_IBA_PL_PAGES_TL T
    where T.PAGE_ID = B.PAGE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;


----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  		createLockBody
--  PURPOSE
--		Table api to delete placement pages
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Lock_Row(
          p_page_id    NUMBER,
          p_site_id    NUMBER,
          p_site_ref_code    VARCHAR2,
          p_page_ref_code    VARCHAR2,
          p_status_code    VARCHAR2,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
		p_name              VARCHAR2,
		p_description       VARCHAR2
)
 IS
   CURSOR C IS
        SELECT *
         FROM AMS_IBA_PL_PAGES_B
        WHERE PAGE_ID =  p_PAGE_ID
        FOR UPDATE of PAGE_ID NOWAIT;
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
           (      Recinfo.page_id = p_page_id)
       AND (    ( Recinfo.site_id = p_site_id)
            OR (    ( Recinfo.site_id IS NULL )
                AND (  p_site_id IS NULL )))
       AND (    ( Recinfo.site_ref_code = p_site_ref_code)
            OR (    ( Recinfo.site_ref_code IS NULL )
                AND (  p_site_ref_code IS NULL )))
       AND (    ( Recinfo.page_ref_code = p_page_ref_code)
            OR (    ( Recinfo.page_ref_code IS NULL )
                AND (  p_page_ref_code IS NULL )))
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
   x_page_id IN NUMBER,
   x_name IN VARCHAR2,
   x_description IN VARCHAR2,
   x_owner IN VARCHAR2,
   x_custom_mode IN VARCHAR2
)
IS
    cursor c_last_updated_by is
    select last_updated_by
    from ams_iba_pl_pages_tl
    where page_id = X_page_ID
    and  USERENV('LANG') = LANGUAGE;

    l_luby number; --last updated by

BEGIN
    open c_last_updated_by;
    fetch c_last_updated_by into l_luby;
    close c_last_updated_by;

    if (l_luby IN (0, 1, 2) or NVL(x_custom_mode, 'PRESERVE')='FORCE')
    then
     update ams_iba_pl_pages_tl set
       name = nvl(x_name, name),
       description = nvl(x_description, description),
       source_lang = userenv('LANG'),
       last_update_date = sysdate,
       last_updated_by = decode(x_owner, 'SEED', 1,
                                'ORACLE', 2,
                                'SYSADMIN', 0, -1),
       last_update_login = 0
      where page_id = x_page_id
      and  userenv('LANG') in (language, source_lang);
    end if;
end TRANSLATE_ROW;

PROCEDURE load_row (
   x_page_id         IN NUMBER,
   x_site_id         IN NUMBER,
   x_site_ref_code   IN VARCHAR2,
   x_page_ref_code   IN VARCHAR2,
   x_status_code     IN VARCHAR2,
   x_name         IN VARCHAR2,
   x_description  IN VARCHAR2,
   x_owner        IN VARCHAR2,
   x_custom_mode IN VARCHAR2
)
IS
   l_user_id      number := 1;
   l_obj_verno    number;
   l_dummy_char   varchar2(1);
   l_row_id       varchar2(100);
   l_page_id     number;
   l_db_luby_id   number;

/*
   cursor  c_obj_verno is
     select object_version_number
     from   ams_iba_pl_pages_b
     where  page_id =  x_page_id;
*/
     cursor c_db_data_details is
     select last_updated_by, nvl(object_version_number,1)
     from ams_iba_pl_pages_b
     where page_id = x_page_id;

   cursor c_chk_page_exists is
     select 'x'
     from   ams_iba_pl_pages_b
     where  page_id = x_page_id;

   cursor c_get_page_id is
      select ams_iba_pl_pages_b_s.nextval
      from dual;
BEGIN

   if X_OWNER = 'SEED' then
      l_user_id := 1;
   elsif X_OWNER = 'ORACLE' then
      l_user_id := 2;
   elsif X_OWNER = 'SYSADMIN' then
      l_user_id := 0;
   end if;

   open c_chk_page_exists;
   fetch c_chk_page_exists into l_dummy_char;
   if c_chk_page_exists%notfound THEN
      if x_page_id is null then
         open c_get_page_id;
         fetch c_get_page_id into l_page_id;
         close c_get_page_id;
      else
         l_page_id := x_page_id;
      end if;
      l_obj_verno := 1;

      AMS_IBA_PL_PAGES_B_PKG.Insert_Row (
         px_page_id => l_page_id,
         p_site_id => x_site_id,
         p_site_ref_code => x_site_ref_code,
         p_page_ref_code => x_page_ref_code,
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
       AMS_IBA_PL_PAGES_B_PKG.UPDATE_ROW (
         p_page_id => x_page_id,
         p_site_id => x_site_id,
         p_site_ref_code => x_site_ref_code,
         p_page_ref_code => x_page_ref_code,
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
   close c_chk_page_exists;
END load_row;

END AMS_IBA_PL_PAGES_B_PKG;

/
