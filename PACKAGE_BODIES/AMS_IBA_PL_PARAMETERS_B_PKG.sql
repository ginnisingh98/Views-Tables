--------------------------------------------------------
--  DDL for Package Body AMS_IBA_PL_PARAMETERS_B_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_IBA_PL_PARAMETERS_B_PKG" as
/* $Header: amstparb.pls 120.0 2005/05/31 15:23:03 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_IBA_PL_PARAMETERS_B_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_IBA_PL_PARAMETERS_B_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amstparb.pls';


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
          px_parameter_id   IN OUT NOCOPY NUMBER,
          p_site_id    NUMBER,
          p_site_ref_code    VARCHAR2,
          p_parameter_ref_code    VARCHAR2,
          p_execution_order    NUMBER,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_name              VARCHAR2,
          p_description       VARCHAR2
)

 IS
   x_rowid    VARCHAR2(30);
BEGIN

   px_object_version_number := 1;

   INSERT INTO AMS_IBA_PL_PARAMETERS_B(
           parameter_id,
           site_id,
           site_ref_code,
           parameter_ref_code,
           execution_order,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login,
           object_version_number
   ) VALUES (
           DECODE( px_parameter_id, FND_API.g_miss_num, NULL, px_parameter_id),
           DECODE( p_site_id, FND_API.g_miss_num, NULL, p_site_id),
           DECODE( p_site_ref_code, FND_API.g_miss_char, NULL, p_site_ref_code),
           DECODE( p_parameter_ref_code, FND_API.g_miss_char, NULL, p_parameter_ref_code),
           DECODE( p_execution_order, FND_API.g_miss_num, NULL, p_execution_order),
           DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by),
           DECODE( p_creation_date, FND_API.g_miss_date, NULL, p_creation_date),
           DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by),
           DECODE( p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date),
           DECODE( p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login),
           DECODE( px_object_version_number, FND_API.g_miss_num, NULL, px_object_version_number));

  insert into AMS_IBA_PL_PARAMETERS_TL (
    PARAMETER_ID,
    NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER,
    LANGUAGE,
    SOURCE_LANG
  ) select
           DECODE( px_parameter_id, FND_API.g_miss_num, NULL, px_parameter_id),
           DECODE( p_name, FND_API.g_miss_char, NULL, p_name),
           DECODE( p_description, FND_API.g_miss_char, NULL, p_description),
           DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by),DECODE( p_creation_date, FND_API.g_miss_date, NULL, p_creation_date),
           DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by),
           DECODE( p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date),
           DECODE( p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login),
           DECODE( px_object_version_number, FND_API.g_miss_num, NULL, px_object_version_number),
           l.language_code,
           USERENV('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from AMS_IBA_PL_PARAMETERS_TL T
    where T.PARAMETER_ID = DECODE( px_parameter_id, FND_API.g_miss_num, NULL, px_parameter_id)
    and T.LANGUAGE = L.LANGUAGE_CODE);

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
          p_parameter_id    NUMBER,
          p_site_id    NUMBER,
          p_site_ref_code    VARCHAR2,
          p_parameter_ref_code    VARCHAR2,
          p_execution_order    NUMBER,
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
 BEGIN
    Update AMS_IBA_PL_PARAMETERS_B
    SET
          site_id = DECODE( p_site_id, FND_API.g_miss_num, site_id, p_site_id),
          site_ref_code = DECODE( p_site_ref_code, FND_API.g_miss_char, site_ref_code, p_site_ref_code),
          parameter_ref_code = DECODE( p_parameter_ref_code, FND_API.g_miss_char, parameter_ref_code, p_parameter_ref_code),
          execution_order = DECODE( p_execution_order, FND_API.g_miss_num, execution_order, p_execution_order),
          last_updated_by = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
          last_update_date = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
          last_update_login = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
          object_version_number = DECODE( p_object_version_number, FND_API.g_miss_num, object_version_number, p_object_version_number)
   WHERE PARAMETER_ID = p_PARAMETER_ID
   AND   object_version_number = p_object_version_number;

   IF (SQL%NOTFOUND) THEN
	RAISE  no_data_found;
   END IF;

  UPDATE ams_iba_pl_parameters_tl
  SET
          name                    = DECODE(p_name,FND_API.g_miss_char,name,p_name),
          description             = DECODE(p_description,FND_API.g_miss_char,description,p_description),
          last_update_date        = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
          last_updated_by         = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
          last_update_login       = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
          source_lang             = userenv('LANG')
  WHERE parameter_id = DECODE( p_parameter_id, FND_API.g_miss_num, parameter_id, p_parameter_id)
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
    p_PARAMETER_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM AMS_IBA_PL_PARAMETERS_B
    WHERE PARAMETER_ID = p_PARAMETER_ID;
   If (SQL%NOTFOUND) then
	RAISE no_data_found;
   End If;
 END Delete_Row ;

procedure ADD_LANGUAGE
is
begin
  delete from AMS_IBA_PL_PARAMETERS_TL T
  where not exists
    (select NULL
    from AMS_IBA_PL_PARAMETERS_B B
    where B.PARAMETER_ID = T.PARAMETER_ID
    );

  update AMS_IBA_PL_PARAMETERS_TL T set (
      NAME,
      description
    ) = (select
      B.NAME,
      B.description
    from AMS_IBA_PL_PARAMETERS_TL B
    where B.PARAMETER_ID = T.PARAMETER_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.PARAMETER_ID,
      T.LANGUAGE
  ) in (select
      SUBT.PARAMETER_ID,
      SUBT.LANGUAGE
    from AMS_IBA_PL_PARAMETERS_TL SUBB, AMS_IBA_PL_PARAMETERS_TL SUBT
    where SUBB.PARAMETER_ID = SUBT.PARAMETER_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.LANGUAGE <> SUBT.LANGUAGE
  ));

  insert into AMS_IBA_PL_PARAMETERS_TL (
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER,
    PARAMETER_ID,
    NAME,
    DESCRIPTION,
    CREATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.OBJECT_VERSION_NUMBER,
    B.PARAMETER_ID,
    B.NAME,
    B.DESCRIPTION,
    B.CREATED_BY,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AMS_IBA_PL_PARAMETERS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AMS_IBA_PL_PARAMETERS_TL T
    where T.PARAMETER_ID = B.PARAMETER_ID
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
          p_parameter_id    NUMBER,
          p_site_id    NUMBER,
          p_site_ref_code    VARCHAR2,
          p_parameter_ref_code    VARCHAR2,
          p_execution_order    NUMBER,
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
         FROM AMS_IBA_PL_PARAMETERS_B
        WHERE PARAMETER_ID =  p_PARAMETER_ID
        FOR UPDATE of PARAMETER_ID NOWAIT;
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
           (      Recinfo.parameter_id = p_parameter_id)
       AND (    ( Recinfo.site_id = p_site_id)
            OR (    ( Recinfo.site_id IS NULL )
                AND (  p_site_id IS NULL )))
       AND (    ( Recinfo.site_ref_code = p_site_ref_code)
            OR (    ( Recinfo.site_ref_code IS NULL )
                AND (  p_site_ref_code IS NULL )))
       AND (    ( Recinfo.parameter_ref_code = p_parameter_ref_code)
            OR (    ( Recinfo.parameter_ref_code IS NULL )
                AND (  p_parameter_ref_code IS NULL )))
       AND (    ( Recinfo.execution_order = p_execution_order)
            OR (    ( Recinfo.execution_order IS NULL )
                AND (  p_execution_order IS NULL )))
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
   x_parameter_id  IN NUMBER,
   x_name          IN VARCHAR2,
   x_description   IN VARCHAR2,
   x_owner         IN VARCHAR2,
   x_custom_mode   IN VARCHAR2
  )
IS
    cursor c_last_updated_by is
    select last_updated_by
    from ams_iba_pl_parameters_tl
    where parameter_id = x_parameter_id
    and  USERENV('LANG') = LANGUAGE;

    l_luby number; --last updated by

BEGIN
   open c_last_updated_by;
    fetch c_last_updated_by into l_luby;
    close c_last_updated_by;

    if (l_luby IN (0, 1, 2) or NVL(x_custom_mode, 'PRESERVE')='FORCE')
    then

    update ams_iba_pl_parameters_tl set
       name = nvl(x_name, name),
       description = nvl(x_description, description),
       source_lang = userenv('LANG'),
       last_update_date = sysdate,
       last_updated_by = decode(x_owner, 'SEED', 1,
				'ORACLE', 2,
				'SYSADMIN', 0, -1),
       last_update_login = 0
    where  parameter_id = x_parameter_id
    and      userenv('LANG') in (language, source_lang);
    end if;
END translate_row;

PROCEDURE load_row (
   x_parameter_id       IN NUMBER,
   x_site_id            IN NUMBER,
   x_site_ref_code      IN VARCHAR2,
   x_parameter_ref_code IN VARCHAR2,
   x_execution_order    IN NUMBER,
   x_name               IN VARCHAR2,
   x_description        IN VARCHAR2,
   x_owner              IN VARCHAR2,
   X_CUSTOM_MODE        IN VARCHAR2
  )
IS
   l_user_id      number := 1;
   l_obj_verno    number;
   l_dummy_char   varchar2(1);
   l_row_id       varchar2(100);
   l_parameter_id number;
   l_db_luby_id   number;

  /* cursor  c_obj_verno is
     select object_version_number
     from    ams_iba_pl_parameters_b
     where  parameter_id =  x_parameter_id;*/

     cursor c_db_data_details is
     select last_updated_by, nvl(object_version_number,1)
     from ams_iba_pl_parameters_b
     where parameter_id =  x_parameter_id;

   cursor c_chk_parameter_exists is
     select 'x'
     from   ams_iba_pl_parameters_b
     where  parameter_id = x_parameter_id;

   cursor c_get_parameter_id is
      select ams_iba_pl_params_b_s.nextval
      from dual;
BEGIN
   if X_OWNER = 'SEED' then
      l_user_id := 1;
   elsif X_OWNER = 'ORACLE' then
      l_user_id := 2;
   elsif X_OWNER = 'SYSADMIN' then
      l_user_id := 0;
   end if;

   open c_chk_parameter_exists;
   fetch c_chk_parameter_exists into l_dummy_char;
   if c_chk_parameter_exists%notfound THEN
      if x_parameter_id is null then
         open c_get_parameter_id;
         fetch c_get_parameter_id into l_parameter_id;
         close c_get_parameter_id;
      else
         l_parameter_id := x_parameter_id;
      end if;
      l_obj_verno := 1;

      AMS_IBA_PL_PARAMETERS_B_PKG.Insert_Row (
         px_parameter_id => l_parameter_id,
         p_site_id => x_site_id,
         p_site_ref_code => x_site_ref_code,
         p_parameter_ref_code => x_parameter_ref_code,
         p_execution_order => x_execution_order,
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
      AMS_IBA_PL_PARAMETERS_B_PKG.UPDATE_ROW (
         p_parameter_id => x_parameter_id,
         p_site_id => x_site_id,
         p_site_ref_code => x_site_ref_code,
         p_parameter_ref_code => x_parameter_ref_code,
         p_execution_order => x_execution_order,
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
   close c_chk_parameter_exists;
END load_row;

END AMS_IBA_PL_PARAMETERS_B_PKG;

/
