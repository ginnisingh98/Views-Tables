--------------------------------------------------------
--  DDL for Package Body AMS_IBA_PS_CNDCLSES_B_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_IBA_PS_CNDCLSES_B_PKG" as
/* $Header: amstcclb.pls 120.0 2005/05/31 16:25:45 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_IBA_PS_CNDCLSES_B_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================

G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_IBA_PS_CNDCLSES_B_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amstcclb.pls';

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
          px_cnd_clause_id   IN OUT NOCOPY NUMBER,
          p_cnd_clause_datatype    VARCHAR2,
          p_cnd_clause_ref_code    VARCHAR2,
          p_cnd_comp_operator    VARCHAR2,
          p_cnd_default_value    VARCHAR2,
	  p_cnd_clause_name     VARCHAR2,
	  p_cnd_clause_description    VARCHAR2)
 IS
   x_rowid    VARCHAR2(30);

BEGIN

   px_object_version_number := 1;

   INSERT INTO AMS_IBA_PS_CNDCLSES_B(
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login,
           object_version_number,
           cnd_clause_id,
           cnd_clause_datatype,
           cnd_clause_ref_code,
           cnd_comp_operator,
           cnd_default_value
   ) VALUES (
           DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by),
           DECODE( p_creation_date, FND_API.g_miss_date, NULL, p_creation_date),
           DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by),
           DECODE( p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date),
           DECODE( p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login),
           DECODE( px_object_version_number, FND_API.g_miss_num, NULL, px_object_version_number),
           DECODE( px_cnd_clause_id, FND_API.g_miss_num, NULL, px_cnd_clause_id),
           DECODE( p_cnd_clause_datatype, FND_API.g_miss_char, NULL, p_cnd_clause_datatype),
           DECODE( p_cnd_clause_ref_code, FND_API.g_miss_char, NULL, p_cnd_clause_ref_code),
           DECODE( p_cnd_comp_operator, FND_API.g_miss_char, NULL, p_cnd_comp_operator),
           DECODE( p_cnd_default_value, FND_API.g_miss_char, NULL, p_cnd_default_value));

	INSERT INTO ams_iba_ps_cndclses_tl (
    		created_by,
    		creation_date,
    		last_updated_by,
    		last_update_date,
    		last_update_login,
    		cnd_clause_id,
    		object_version_number,
    		cnd_clause_name,
    		cnd_clause_description,
    		language,
    		source_lang
  	) SELECT
       FND_GLOBAL.user_id,
	  SYSDATE,
       FND_GLOBAL.user_id,
	  SYSDATE,
       FND_GLOBAL.conc_login_id,
	  DECODE( px_cnd_clause_id, FND_API.g_miss_num, NULL, px_cnd_clause_id),
	  DECODE( px_object_version_number, FND_API.g_miss_num, NULL, px_object_version_number),

      DECODE( p_CND_CLAUSE_NAME, FND_API.G_MISS_CHAR, NULL, p_CND_CLAUSE_NAME),
      DECODE( p_CND_CLAUSE_DESCRIPTION, FND_API.G_MISS_CHAR, NULL, p_CND_CLAUSE_DESCRIPTION),
    	 l.language_code,
    	 USERENV('LANG')
  	FROM fnd_languages l
  	 WHERE l.installed_flag IN ('I', 'B')
  	 AND NOT EXISTS
	 (SELECT null
    	   FROM ams_iba_ps_cndclses_tl t
    	   WHERE t.cnd_clause_id = DECODE( px_cnd_clause_id, FND_API.g_miss_num, NULL, px_cnd_clause_id)
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
          p_cnd_clause_id    NUMBER,
          p_cnd_clause_datatype    VARCHAR2,
          p_cnd_clause_ref_code    VARCHAR2,
          p_cnd_comp_operator    VARCHAR2,
          p_cnd_default_value    VARCHAR2,
          p_cnd_clause_name     VARCHAR2,
          p_cnd_clause_description    VARCHAR2)

 IS
 BEGIN
    Update AMS_IBA_PS_CNDCLSES_B
    SET
        created_by = DECODE( p_created_by, FND_API.g_miss_num, created_by, p_created_by),
        creation_date = DECODE( p_creation_date, FND_API.g_miss_date, creation_date, p_creation_date),
        last_updated_by = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
        last_update_date = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
        last_update_login = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
        object_version_number = DECODE( p_object_version_number, FND_API.g_miss_num, object_version_number, p_object_version_number),
        cnd_clause_id = DECODE( p_cnd_clause_id, FND_API.g_miss_num, cnd_clause_id, p_cnd_clause_id),
        cnd_clause_datatype = DECODE( p_cnd_clause_datatype, FND_API.g_miss_char, cnd_clause_datatype, p_cnd_clause_datatype),
        cnd_clause_ref_code = DECODE( p_cnd_clause_ref_code, FND_API.g_miss_char, cnd_clause_ref_code, p_cnd_clause_ref_code),
        cnd_comp_operator = DECODE( p_cnd_comp_operator, FND_API.g_miss_char, cnd_comp_operator, p_cnd_comp_operator),
        cnd_default_value = DECODE( p_cnd_default_value, FND_API.g_miss_char, cnd_default_value, p_cnd_default_value)
   WHERE CND_CLAUSE_ID = p_CND_CLAUSE_ID
   AND   object_version_number = p_object_version_number;

   IF (SQL%NOTFOUND) THEN
	RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

  UPDATE ams_iba_ps_cndclses_tl SET
      cnd_clause_name = DECODE( p_CND_CLAUSE_NAME, FND_API.G_MISS_CHAR, cnd_clause_name, p_CND_CLAUSE_NAME),
      cnd_clause_description = DECODE( p_CND_CLAUSE_DESCRIPTION, FND_API.G_MISS_CHAR, cnd_clause_description, p_CND_CLAUSE_DESCRIPTION),
      last_update_date = SYSDATE,
      last_updated_by = FND_GLOBAL.user_id,
      last_update_login = FND_GLOBAL.conc_login_id,
      source_lang = USERENV('LANG')
  WHERE cnd_clause_id = p_cnd_clause_id
  AND USERENV('LANG') IN (language, source_lang);

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
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
    p_CND_CLAUSE_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM AMS_IBA_PS_CNDCLSES_B
    WHERE CND_CLAUSE_ID = p_CND_CLAUSE_ID;
   If (SQL%NOTFOUND) then
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   End If;

   DELETE FROM AMS_IBA_PS_CNDCLSES_TL
    WHERE CND_CLAUSE_ID = p_CND_CLAUSE_ID;
   If (SQL%NOTFOUND) then
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   End If;

 END Delete_Row ;

procedure ADD_LANGUAGE
is
begin
  delete from AMS_IBA_PS_CNDCLSES_TL T
  where not exists
    (select NULL
    from AMS_IBA_PS_CNDCLSES_B B
    where B.CND_CLAUSE_ID = T.CND_CLAUSE_ID
    );

  update AMS_IBA_PS_CNDCLSES_TL T set (
      CND_CLAUSE_NAME,
      CND_CLAUSE_DESCRIPTION
    ) = (select
      B.CND_CLAUSE_NAME,
      B.CND_CLAUSE_DESCRIPTION
    from AMS_IBA_PS_CNDCLSES_TL B
    where B.CND_CLAUSE_ID = T.CND_CLAUSE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.CND_CLAUSE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.CND_CLAUSE_ID,
      SUBT.LANGUAGE
    from AMS_IBA_PS_CNDCLSES_TL SUBB, AMS_IBA_PS_CNDCLSES_TL SUBT
    where SUBB.CND_CLAUSE_ID = SUBT.CND_CLAUSE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.CND_CLAUSE_NAME <> SUBT.CND_CLAUSE_NAME
      or SUBB.CND_CLAUSE_DESCRIPTION <> SUBT.CND_CLAUSE_DESCRIPTION
      or (SUBB.CND_CLAUSE_DESCRIPTION is null and SUBT.CND_CLAUSE_DESCRIPTION is not null)
      or (SUBB.CND_CLAUSE_DESCRIPTION is not null and SUBT.CND_CLAUSE_DESCRIPTION is null)
  ));

  insert into AMS_IBA_PS_CNDCLSES_TL (
    LAST_UPDATE_DATE,
    CREATION_DATE,
    LAST_UPDATED_BY,
    CREATED_BY,
    CND_CLAUSE_ID,
    CND_CLAUSE_NAME,
    CND_CLAUSE_DESCRIPTION,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.LAST_UPDATE_DATE,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.CREATED_BY,
    B.CND_CLAUSE_ID,
    B.CND_CLAUSE_NAME,
    B.CND_CLAUSE_DESCRIPTION,
    B.LAST_UPDATE_LOGIN,
    B.OBJECT_VERSION_NUMBER,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AMS_IBA_PS_CNDCLSES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AMS_IBA_PS_CNDCLSES_TL T
    where T.CND_CLAUSE_ID = B.CND_CLAUSE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;


---------------------------------------------------
----          MEDIA           ----
---------------------------------------------------

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
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_cnd_clause_id    NUMBER,
          p_cnd_clause_datatype    VARCHAR2,
          p_cnd_clause_ref_code    VARCHAR2,
          p_cnd_comp_operator    VARCHAR2,
          p_cnd_default_value    VARCHAR2)

 IS
   CURSOR C IS
        SELECT *
         FROM AMS_IBA_PS_CNDCLSES_B
        WHERE CND_CLAUSE_ID =  p_CND_CLAUSE_ID
        FOR UPDATE of CND_CLAUSE_ID NOWAIT;
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
       AND (    ( Recinfo.cnd_clause_id = p_cnd_clause_id)
            OR (    ( Recinfo.cnd_clause_id IS NULL )
                AND (  p_cnd_clause_id IS NULL )))
       AND (    ( Recinfo.cnd_clause_datatype = p_cnd_clause_datatype)
            OR (    ( Recinfo.cnd_clause_datatype IS NULL )
                AND (  p_cnd_clause_datatype IS NULL )))
       AND (    ( Recinfo.cnd_clause_ref_code = p_cnd_clause_ref_code)
            OR (    ( Recinfo.cnd_clause_ref_code IS NULL )
                AND (  p_cnd_clause_ref_code IS NULL )))
       AND (    ( Recinfo.cnd_comp_operator = p_cnd_comp_operator)
            OR (    ( Recinfo.cnd_comp_operator IS NULL )
                AND (  p_cnd_comp_operator IS NULL )))
       AND (    ( Recinfo.cnd_default_value = p_cnd_default_value)
            OR (    ( Recinfo.cnd_default_value IS NULL )
                AND (  p_cnd_default_value IS NULL )))
       ) THEN
       RETURN;
   ELSE
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
END Lock_Row;

END AMS_IBA_PS_CNDCLSES_B_PKG;

/
