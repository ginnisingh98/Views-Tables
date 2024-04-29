--------------------------------------------------------
--  DDL for Package Body AMS_MET_TPL_HEADERS_B_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_MET_TPL_HEADERS_B_PKG" AS
/* $Header: amslmthb.pls 115.14 2003/10/16 11:26:04 sunkumar ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_MET_TPL_HEADERS_B_PKG
-- Purpose
--
-- History
--   03/05/2002  dmvincen  Created.
--   03/07/2002  dmvincen  Added LOAD_ROW.
--   08/19/2002  dmvincen  Added add_language for MLS compliance. BUG2501425.
--   03/06/2003  dmvincen  BUG2819067: Do not update if customized.
--   08-Sep-2003 Sunkumar  Bug#3130095 Metric Template UI Enh. 11510
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_MET_TPL_HEADERS_B_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amslmthb.pls';


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
          px_metric_tpl_header_id   NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   NUMBER,
          p_enabled_flag    VARCHAR2,
          p_application_id    NUMBER,
          p_metric_tpl_header_name VARCHAR2,
          p_description VARCHAR2,
          p_object_type VARCHAR2,
          p_association_type VARCHAR2,
          p_used_by_id NUMBER,
          p_used_by_code VARCHAR2)

 IS
   x_rowid    VARCHAR2(30);


BEGIN

--   px_object_version_number := 1;

   INSERT INTO AMS_MET_TPL_HEADERS_B(
           metric_tpl_header_id,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           object_version_number,
           enabled_flag,
           application_id,
	   object_type,
	   association_type,
	   used_by_id,
	   used_by_code
   ) VALUES (
           DECODE( px_metric_tpl_header_id, FND_API.g_miss_num, NULL, px_metric_tpl_header_id),
           DECODE( p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date),
           DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by),
           DECODE( p_creation_date, FND_API.g_miss_date, NULL, p_creation_date),
           DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by),
           DECODE( p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login),
           1, --DECODE( px_object_version_number, FND_API.g_miss_num, NULL, px_object_version_number),
           DECODE( p_enabled_flag, FND_API.g_miss_char, NULL, p_enabled_flag),
           DECODE( p_application_id, FND_API.g_miss_num, NULL, p_application_id),
           DECODE( p_object_type, FND_API.g_miss_char, NULL, p_object_type),
           DECODE( p_association_type, FND_API.g_miss_char, NULL, p_association_type),
           DECODE( p_used_by_id, FND_API.g_miss_num, NULL, p_used_by_id),
	   DECODE( p_used_by_code, FND_API.g_miss_char, NULL, p_used_by_code));


  INSERT INTO AMS_MET_TPL_HEADERS_TL (
   METRIC_TPL_HEADER_ID   ,
   LAST_UPDATE_DATE       ,
   LAST_UPDATED_BY        ,
   CREATION_DATE          ,
   CREATED_BY             ,
   LAST_UPDATE_LOGIN      ,
   LANGUAGE               ,
   SOURCE_LANG            ,
   METRIC_TPL_HEADER_NAME ,
   DESCRIPTION
  ) SELECT
    DECODE( px_metric_tpl_header_id, FND_API.g_miss_num, NULL, px_metric_tpl_header_id),
    DECODE( p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date),
    DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by),
    DECODE( p_creation_date, FND_API.g_miss_date, NULL, p_creation_date),
    DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by),
    DECODE( p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login),
    L.LANGUAGE_CODE,
    USERENV('LANG'),
    DECODE( p_metric_tpl_header_name, FND_API.g_miss_char, NULL, p_metric_tpl_header_name),
    DECODE( p_description, FND_API.g_miss_char, NULL, p_description)
  FROM FND_LANGUAGES L
  WHERE L.INSTALLED_FLAG IN ('I', 'B')
  AND NOT EXISTS
    (SELECT NULL
    FROM AMS_MET_TPL_HEADERS_TL T
    WHERE T.METRIC_TPL_HEADER_ID = px_metric_tpl_header_id
    AND T.LANGUAGE = L.LANGUAGE_CODE);
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
          p_metric_tpl_header_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_enabled_flag    VARCHAR2,
          p_application_id    NUMBER,
          p_metric_tpl_header_name VARCHAR2,
          p_description VARCHAR2,
	  p_object_type VARCHAR2,
          p_association_type VARCHAR2,
          p_used_by_id NUMBER,
          p_used_by_code VARCHAR2)

 IS
 BEGIN
    IF p_metric_tpl_header_id IS NULL OR
      p_metric_tpl_header_id = FND_API.g_miss_num OR
      p_object_version_number IS NULL OR
      p_object_version_number = FND_API.g_miss_num THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

    UPDATE AMS_MET_TPL_HEADERS_B
    SET
       last_update_date = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
       last_updated_by = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
       last_update_login = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
       enabled_flag = DECODE( p_enabled_flag, FND_API.g_miss_char, enabled_flag, p_enabled_flag),
       application_id = DECODE( p_application_id, FND_API.g_miss_num, application_id, p_application_id),
       object_version_number = DECODE( p_object_version_number, FND_API.g_miss_num, object_version_number, p_object_version_number),
       object_type =  DECODE( p_object_type, FND_API.g_miss_char, object_type, p_object_type),
       association_type = DECODE( p_association_type, FND_API.g_miss_char, association_type, p_association_type),
       used_by_id = DECODE( p_used_by_id, FND_API.g_miss_num, used_by_id, p_used_by_id),
       used_by_code = DECODE( p_used_by_code, FND_API.g_miss_char, used_by_code, p_used_by_code)
   WHERE METRIC_TPL_HEADER_ID = p_METRIC_TPL_HEADER_ID;
--   AND   object_version_number = p_object_version_number;

   IF (SQL%NOTFOUND) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   UPDATE AMS_MET_TPL_HEADERS_TL SET
       last_update_date = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
       last_updated_by = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
       last_update_login = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
       SOURCE_LANG = USERENV('LANG'),
       metric_tpl_header_name = DECODE( p_metric_tpl_header_name, FND_API.g_miss_char, metric_tpl_header_name, p_metric_tpl_header_name),
       description = DECODE( p_description, FND_API.g_miss_char, description, p_description)
   WHERE METRIC_TPL_HEADER_ID = p_METRIC_TPL_HEADER_ID
   AND USERENV('LANG') IN (LANGUAGE, SOURCE_LANG);

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
    p_METRIC_TPL_HEADER_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM AMS_MET_TPL_HEADERS_B
    WHERE METRIC_TPL_HEADER_ID = p_METRIC_TPL_HEADER_ID;
   IF (SQL%NOTFOUND) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   DELETE FROM AMS_MET_TPL_HEADERS_TL
    WHERE METRIC_TPL_HEADER_ID = p_METRIC_TPL_HEADER_ID;
   IF (SQL%NOTFOUND) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
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
          p_metric_tpl_header_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_enabled_flag    VARCHAR2,
          p_application_id    NUMBER)

 IS
   CURSOR C IS
        SELECT *
         FROM AMS_MET_TPL_HEADERS_B
        WHERE METRIC_TPL_HEADER_ID =  p_METRIC_TPL_HEADER_ID
        FOR UPDATE OF METRIC_TPL_HEADER_ID NOWAIT;
   Recinfo C%ROWTYPE;
 BEGIN
    OPEN c;
    FETCH c INTO Recinfo;
    IF (c%NOTFOUND) THEN
        CLOSE c;
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
    CLOSE C;
    IF (
           (      Recinfo.metric_tpl_header_id = p_metric_tpl_header_id)
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
       AND (    ( Recinfo.enabled_flag = p_enabled_flag)
            OR (    ( Recinfo.enabled_flag IS NULL )
                AND (  p_enabled_flag IS NULL )))
       AND (    ( Recinfo.application_id = p_application_id)
            OR (    ( Recinfo.application_id IS NULL )
                AND (  p_application_id IS NULL )))
       ) THEN
       RETURN;
   ELSE
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
END Lock_Row;


PROCEDURE LOAD_ROW (
        X_METRIC_TPL_HEADER_ID IN NUMBER,
        X_OBJECT_VERSION_NUMBER IN NUMBER,
        X_METRIC_TPL_HEADER_NAME IN VARCHAR2,
        X_DESCRIPTION IN VARCHAR2,
        X_ENABLED_FLAG IN VARCHAR2,
	X_APPLICATION_ID IN NUMBER,
        X_Owner   IN VARCHAR2,
        X_CUSTOM_MODE IN VARCHAR2,
	X_OBJECT_TYPE IN VARCHAR2,
	X_ASSOCIATION_TYPE IN VARCHAR2,
	X_USED_BY_ID IN NUMBER,
	X_USED_BY_CODE IN VARCHAR2
)
IS
l_user_id   NUMBER := 0;
l_obj_verno  NUMBER;
l_row_id    VARCHAR2(100);
l_metric_tpl_header_id   NUMBER;
l_db_luby_id NUMBER;

CURSOR  c_db_data_details IS
  SELECT last_updated_by, object_version_number
  FROM    AMS_MET_TPL_HEADERS_B
  WHERE  METRIC_TPL_HEADER_ID =  X_METRIC_TPL_HEADER_ID;

CURSOR c_get_mthid IS
   SELECT AMS_MET_TPL_HEADERS_ALL_S.NEXTVAL
   FROM dual;

BEGIN

  -- set the last_updated_by to be used while updating the data in customer data.
  if X_OWNER = 'SEED' then
    l_user_id := 1;
  elsif X_OWNER = 'ORACLE' THEN
    l_user_id := 2;
  elsif X_OWNER = 'SYSADMIN' THEN
    l_user_id := 0;
  end if ;

   OPEN c_db_data_details;
   FETCH c_db_data_details INTO l_db_luby_id, l_obj_verno;
 IF c_db_data_details%NOTFOUND
 THEN
   CLOSE c_db_data_details;

    IF x_metric_tpl_header_id IS NULL THEN
        OPEN c_get_mthid;
        FETCH c_get_mthid INTO l_metric_tpl_header_id;
        CLOSE c_get_mthid;
    ELSE
        l_metric_tpl_header_id := x_metric_tpl_header_id;
    END IF ;

    l_obj_verno := 1;


  Insert_Row(
          px_metric_tpl_header_id => L_METRIC_TPL_HEADER_ID,
          p_last_update_date    => SYSDATE,
          p_last_updated_by    => l_user_id,
          p_creation_date    => SYSDATE,
          p_created_by    => l_user_id,
          p_last_update_login    => 0,
          px_object_version_number   => l_obj_verno,
          p_enabled_flag    => X_ENABLED_FLAG,
          p_application_id    => X_APPLICATION_ID,
          p_metric_tpl_header_name => X_METRIC_TPL_HEADER_NAME,
          p_description => X_DESCRIPTION,
	  p_object_type => X_OBJECT_TYPE,
	  p_association_type => X_ASSOCIATION_TYPE,
	  p_used_by_id => X_USED_BY_ID,
	  p_used_by_code => X_USED_BY_CODE);

ELSE
   CLOSE c_db_data_details;
    if ( l_db_luby_id IN (1, 2, 0)
      OR NVL(x_custom_mode,'PRESERVE') = 'FORCE') THEN
   Update_Row(
          p_metric_tpl_header_id    => X_METRIC_TPL_HEADER_ID,
          p_last_update_date    => SYSDATE,
          p_last_updated_by    => l_user_id,
          p_last_update_login    => 0,
          p_object_version_number    => l_obj_verno + 1,
          p_enabled_flag    => X_ENABLED_FLAG,
          p_application_id    => X_APPLICATION_ID,
          p_metric_tpl_header_name => X_METRIC_TPL_HEADER_NAME,
          p_description => X_DESCRIPTION,
	  p_object_type => X_OBJECT_TYPE,
	  p_association_type => X_ASSOCIATION_TYPE,
	  p_used_by_id => X_USED_BY_ID,
	  p_used_by_code => X_USED_BY_CODE);

   END IF;
END IF;
END LOAD_ROW;

-- MLS compatibility.
procedure ADD_LANGUAGE
is
begin
  delete from AMS_MET_TPL_HEADERS_TL T
  where not exists
    (select NULL
    from AMS_MET_TPL_HEADERS_B B
    where B.METRIC_TPL_HEADER_ID = T.METRIC_TPL_HEADER_ID
    );

  update AMS_MET_TPL_HEADERS_TL T set (
      METRIC_TPL_HEADER_NAME,
      DESCRIPTION
    ) = (select
      B.METRIC_TPL_HEADER_NAME,
      B.description
    from AMS_MET_TPL_HEADERS_TL B
    where B.METRIC_TPL_HEADER_ID = T.METRIC_TPL_HEADER_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.METRIC_TPL_HEADER_ID,
      T.LANGUAGE
  ) in (select
      SUBT.METRIC_TPL_HEADER_ID,
      SUBT.LANGUAGE
    from AMS_MET_TPL_HEADERS_TL SUBB, AMS_MET_TPL_HEADERS_TL SUBT
    where SUBB.METRIC_TPL_HEADER_ID = SUBT.METRIC_TPL_HEADER_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.METRIC_TPL_HEADER_NAME <> SUBT.METRIC_TPL_HEADER_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into AMS_MET_TPL_HEADERS_TL (
    LAST_UPDATE_DATE,
    CREATION_DATE,
    LAST_UPDATED_BY,
    CREATED_BY,
    METRIC_TPL_HEADER_ID,
    METRIC_TPL_HEADER_NAME,
    DESCRIPTION,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.LAST_UPDATE_DATE,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.CREATED_BY,
    B.METRIC_TPL_HEADER_ID,
    B.METRIC_TPL_HEADER_NAME,
    B.DESCRIPTION,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AMS_MET_TPL_HEADERS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AMS_MET_TPL_HEADERS_TL T
    where T.METRIC_TPL_HEADER_ID = B.METRIC_TPL_HEADER_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW(
       X_METRIC_TPL_HEADER_ID    in NUMBER
     , X_METRIC_TPL_HEADER_NAME  in VARCHAR2
     , X_DESCRIPTION    in VARCHAR2
     , x_owner   in VARCHAR2
 ) is
 begin
  update AMS_MET_TPL_HEADERS_TL set
    METRIC_TPL_HEADER_NAME = nvl(X_METRIC_TPL_HEADER_NAME, METRIC_TPL_HEADER_NAME),
    description = nvl(x_description, description),
    source_lang = userenv('LANG'),
    last_update_date = sysdate,
    last_updated_by = decode(x_owner, 'SEED', 1, 0),
    last_update_login = 0
 where  METRIC_TPL_HEADER_ID = x_METRIC_TPL_HEADER_ID
 and      userenv('LANG') in (language, source_lang);
end TRANSLATE_ROW;

END AMS_MET_TPL_HEADERS_B_PKG;

/
