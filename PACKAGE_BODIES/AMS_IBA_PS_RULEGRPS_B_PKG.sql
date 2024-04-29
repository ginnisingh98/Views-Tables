--------------------------------------------------------
--  DDL for Package Body AMS_IBA_PS_RULEGRPS_B_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_IBA_PS_RULEGRPS_B_PKG" as
/* $Header: amstrgpb.pls 120.0 2005/05/31 15:34:15 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_IBA_PS_RULEGRPS_B_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================

G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_IBA_PS_RULEGRPS_B_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amstrgpb.pls';

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
          px_rulegroup_id   IN OUT NOCOPY NUMBER,
          p_posting_id    NUMBER,
          p_strategy_type    VARCHAR2,
          p_exec_priority    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_RULE_NAME	IN VARCHAR2,
          p_RULE_DESCRIPTION	IN VARCHAR2)
    IS
    x_rowid    VARCHAR2(30);

BEGIN

   px_object_version_number := 1;

   INSERT INTO AMS_IBA_PS_RULEGRPS_B(
           rulegroup_id,
           posting_id,
           strategy_type,
           exec_priority,
           last_update_date,
           last_update_login,
           created_by,
           creation_date,
           last_updated_by,
           object_version_number
   ) VALUES (
        DECODE( px_rulegroup_id, FND_API.g_miss_num, NULL, px_rulegroup_id),
        DECODE( p_posting_id, FND_API.g_miss_num, NULL, p_posting_id),
        DECODE( p_strategy_type, FND_API.g_miss_char, NULL, p_strategy_type),
        DECODE( p_exec_priority, FND_API.g_miss_num, NULL, p_exec_priority),
        DECODE( p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date),
        DECODE( p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login),
        DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by),
        DECODE( p_creation_date, FND_API.g_miss_date, NULL, p_creation_date),
        DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by),
        DECODE( px_object_version_number, FND_API.g_miss_num, NULL, px_object_version_number));


   INSERT INTO AMS_IBA_PS_RULEGRPS_TL(
    	RULEGROUP_NAME,
	RULEGROUP_DESCRIPTION,
	RULEGROUP_ID,
    	CREATED_BY,
    	CREATION_DATE,
        LAST_UPDATED_BY,
    	LAST_UPDATE_DATE,
    	LAST_UPDATE_LOGIN,
    	OBJECT_VERSION_NUMBER,
    	LANGUAGE,
    	SOURCE_LANG

   ) SELECT

        decode( p_RULE_NAME, FND_API.G_MISS_CHAR, NULL, p_RULE_NAME),
        decode( p_RULE_DESCRIPTION, FND_API.G_MISS_CHAR, NULL, p_RULE_DESCRIPTION),
        DECODE( px_rulegroup_id, FND_API.g_miss_num, NULL, px_rulegroup_id),
        FND_GLOBAL.user_id,
        SYSDATE,
        FND_GLOBAL.user_id,
        SYSDATE,
        FND_GLOBAL.conc_login_id,
        DECODE( px_object_version_number, FND_API.g_miss_num, NULL, px_object_version_number),
        l.language_code,
        USERENV('LANG')
     FROM fnd_languages l
	WHERE l.installed_flag in ('I', 'B')
	AND NOT EXISTS(
		SELECT NULL
		FROM AMS_IBA_PS_RULEGRPS_TL t
		WHERE t.rulegroup_id = DECODE( px_rulegroup_id, FND_API.g_miss_num, NULL, px_rulegroup_id)
		AND t.language = l.language_code
	);

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
          p_rulegroup_id    NUMBER,
          p_posting_id    NUMBER,
          p_strategy_type    VARCHAR2,
          p_exec_priority    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_object_version_number    NUMBER,
          p_RULE_NAME   VARCHAR2,
          p_RULE_DESCRIPTION    VARCHAR2)


 IS
 BEGIN
    Update AMS_IBA_PS_RULEGRPS_B
    SET
       rulegroup_id = DECODE( p_rulegroup_id, FND_API.g_miss_num, rulegroup_id, p_rulegroup_id),
       posting_id = DECODE( p_posting_id, FND_API.g_miss_num, posting_id, p_posting_id),
       strategy_type = DECODE( p_strategy_type, FND_API.g_miss_char, NULL, p_strategy_type),
       exec_priority = DECODE( p_exec_priority, FND_API.g_miss_num, exec_priority, p_exec_priority),
       last_update_date = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
       last_update_login = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
       created_by = DECODE( p_created_by, FND_API.g_miss_num, created_by, p_created_by),
       creation_date = DECODE( p_creation_date, FND_API.g_miss_date, creation_date, p_creation_date),
       last_updated_by = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
       object_version_number = DECODE( p_object_version_number, FND_API.g_miss_num, object_version_number, p_object_version_number)
   WHERE RULEGROUP_ID = p_RULEGROUP_ID
   AND object_version_number = p_object_version_number;

   IF (SQL%NOTFOUND) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

  UPDATE ams_iba_ps_rulegrps_tl SET
    rulegroup_name = decode( p_rule_name, FND_API.G_MISS_CHAR, rulegroup_name, p_rule_name),
    rulegroup_description = decode( p_rule_description, FND_API.G_MISS_CHAR, rulegroup_description, p_rule_description),
    last_update_date = SYSDATE,
    last_updated_by = FND_GLOBAL.user_id,
    last_update_login = FND_GLOBAL.conc_login_id,
    source_lang = USERENV('LANG')
  WHERE rulegroup_id = p_rulegroup_id
  AND USERENV('LANG') IN (language, source_lang);

  IF (SQL%NOTFOUND) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

END Update_Row;


----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ======================================================
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
--  ====================================================
PROCEDURE Delete_Row(
    p_RULEGROUP_ID  NUMBER)
 IS
 BEGIN

   DELETE FROM AMS_IBA_PS_RULEGRPS_B
   WHERE RULEGROUP_ID = p_RULEGROUP_ID;

   If (SQL%NOTFOUND) then
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   End If;

   DELETE FROM AMS_IBA_PS_RULEGRPS_TL
   WHERE RULEGROUP_ID = P_RULEGROUP_ID;

   If (SQL%NOTFOUND) then
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   End If;

   DELETE FROM AMS_IBA_PS_RULES
   WHERE RULEGROUP_ID = P_RULEGROUP_ID;

   If (SQL%NOTFOUND) then
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   End If;

   DELETE FROM AMS_IBA_PS_RL_ST_PARAMS
   WHERE RULEGROUP_ID = P_RULEGROUP_ID;

   DELETE FROM AMS_IBA_PS_RL_ST_FLTRS
   WHERE RULEGROUP_ID = P_RULEGROUP_ID;

 END Delete_Row ;

procedure ADD_LANGUAGE
is
begin
  delete from AMS_IBA_PS_RULEGRPS_TL T
  where not exists
    (select NULL
    from AMS_IBA_PS_RULEGRPS_B B
    where B.RULEGROUP_ID = T.RULEGROUP_ID
    );

  update AMS_IBA_PS_RULEGRPS_TL T set (
      RULEGROUP_NAME,
      RULEGROUP_DESCRIPTION
    ) = (select
      B.RULEGROUP_NAME,
      B.RULEGROUP_DESCRIPTION
    from AMS_IBA_PS_RULEGRPS_TL B
    where B.RULEGROUP_ID = T.RULEGROUP_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.RULEGROUP_ID,
      T.LANGUAGE
  ) in (select
      SUBT.RULEGROUP_ID,
      SUBT.LANGUAGE
    from AMS_IBA_PS_RULEGRPS_TL SUBB, AMS_IBA_PS_RULEGRPS_TL SUBT
    where SUBB.RULEGROUP_ID = SUBT.RULEGROUP_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.RULEGROUP_NAME <> SUBT.RULEGROUP_NAME
      or SUBB.RULEGROUP_DESCRIPTION <> SUBT.RULEGROUP_DESCRIPTION
      or (SUBB.RULEGROUP_DESCRIPTION is null and SUBT.RULEGROUP_DESCRIPTION is not null)
      or (SUBB.RULEGROUP_DESCRIPTION is not null and SUBT.RULEGROUP_DESCRIPTION is null)
  ));

  insert into AMS_IBA_PS_RULEGRPS_TL (
    LAST_UPDATE_DATE,
    CREATION_DATE,
    LAST_UPDATED_BY,
    CREATED_BY,
    RULEGROUP_ID,
    RULEGROUP_NAME,
    RULEGROUP_DESCRIPTION,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.LAST_UPDATE_DATE,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.CREATED_BY,
    B.RULEGROUP_ID,
    B.RULEGROUP_NAME,
    B.RULEGROUP_DESCRIPTION,
    B.LAST_UPDATE_LOGIN,
    B.OBJECT_VERSION_NUMBER,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AMS_IBA_PS_RULEGRPS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AMS_IBA_PS_RULEGRPS_TL T
    where T.RULEGROUP_ID = B.RULEGROUP_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

--------------------------------------------
----          MEDIA           ----
--------------------------------------------
-- =========================================
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
--  ========================================
PROCEDURE Lock_Row(
          p_rulegroup_id    NUMBER,
          p_posting_id    NUMBER,
          p_strategy_type VARCHAR2,
          p_exec_priority    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_object_version_number    NUMBER)

 IS
   CURSOR C IS
        SELECT *
         FROM AMS_IBA_PS_RULEGRPS_B
        WHERE RULEGROUP_ID =  p_RULEGROUP_ID
        FOR UPDATE of RULEGROUP_ID NOWAIT;
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
           (      Recinfo.rulegroup_id = p_rulegroup_id)
       AND (    ( Recinfo.posting_id = p_posting_id)
            OR (    ( Recinfo.posting_id IS NULL )
                AND (  p_posting_id IS NULL )))
       AND (    ( Recinfo.strategy_type = p_strategy_type)
            OR (    ( Recinfo.strategy_type IS NULL )
                AND (  p_strategy_type IS NULL )))
       AND (    ( Recinfo.exec_priority = p_exec_priority)
            OR (    ( Recinfo.exec_priority IS NULL )
                AND (  p_exec_priority IS NULL )))
       AND (    ( Recinfo.last_update_date = p_last_update_date)
            OR (    ( Recinfo.last_update_date IS NULL )
                AND (  p_last_update_date IS NULL )))
       AND (    ( Recinfo.last_update_login = p_last_update_login)
            OR (    ( Recinfo.last_update_login IS NULL )
                AND (  p_last_update_login IS NULL )))
       AND (    ( Recinfo.created_by = p_created_by)
            OR (    ( Recinfo.created_by IS NULL )
                AND (  p_created_by IS NULL )))
       AND (    ( Recinfo.creation_date = p_creation_date)
            OR (    ( Recinfo.creation_date IS NULL )
                AND (  p_creation_date IS NULL )))
       AND (    ( Recinfo.last_updated_by = p_last_updated_by)
            OR (    ( Recinfo.last_updated_by IS NULL )
                AND (  p_last_updated_by IS NULL )))
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

END AMS_IBA_PS_RULEGRPS_B_PKG;

/
