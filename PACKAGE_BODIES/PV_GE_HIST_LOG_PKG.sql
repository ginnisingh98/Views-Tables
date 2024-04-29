--------------------------------------------------------
--  DDL for Package Body PV_GE_HIST_LOG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_GE_HIST_LOG_PKG" as
/* $Header: pvxtghlb.pls 120.0 2005/05/27 16:20:38 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_Ge_Hist_Log_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- This Api is generated with Latest version of
-- Rosetta, where g_miss indicates NULL and
-- NULL indicates missing value. Rosetta Version 1.55
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'PV_Ge_Hist_Log_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxtghlb.pls';




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
PROCEDURE Insert_Row(
        px_entity_history_log_id   IN OUT NOCOPY NUMBER,
        px_object_version_number   IN OUT NOCOPY NUMBER,
        p_arc_history_for_entity_code    VARCHAR2,
        p_history_for_entity_id    NUMBER,
        p_message_code    VARCHAR2,
        p_history_category_code    VARCHAR2,
        p_created_by    NUMBER,
        p_creation_date    DATE,
        p_last_updated_by    NUMBER,
        p_last_update_date    DATE,
        p_last_update_login    NUMBER,
        p_partner_id    NUMBER,
        p_access_level_flag    VARCHAR2,
        p_interaction_level    NUMBER,
        p_COMMENTS    VARCHAR2
)

IS
 x_rowid    VARCHAR2(30);


BEGIN


 px_object_version_number := nvl(px_object_version_number, 1);


 INSERT INTO pv_ge_history_log_b(
         entity_history_log_id,
         object_version_number,
         arc_history_for_entity_code,
         history_for_entity_id,
         message_code,
         history_category_code,
         created_by,
         creation_date,
         last_updated_by,
         last_update_date,
         last_update_login,
         partner_id,
         access_level_flag,
         interaction_level
 ) VALUES (
         DECODE( px_entity_history_log_id, FND_API.G_MISS_NUM, NULL, px_entity_history_log_id),
         DECODE( px_object_version_number, FND_API.G_MISS_NUM, 1, px_object_version_number),
         DECODE( p_arc_history_for_entity_code, FND_API.g_miss_char, NULL, p_arc_history_for_entity_code),
         DECODE( p_history_for_entity_id, FND_API.G_MISS_NUM, NULL, p_history_for_entity_id),
         DECODE( p_message_code, FND_API.g_miss_char, NULL, p_message_code),
         DECODE( p_history_category_code, FND_API.g_miss_char, NULL, p_history_category_code),
         DECODE( p_created_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_created_by),
         DECODE( p_creation_date, FND_API.G_MISS_DATE, SYSDATE, p_creation_date),
         DECODE( p_last_updated_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_last_updated_by),
         DECODE( p_last_update_date, FND_API.G_MISS_DATE, SYSDATE, p_last_update_date),
         DECODE( p_last_update_login, FND_API.G_MISS_NUM, FND_GLOBAL.CONC_LOGIN_ID, p_last_update_login),
         DECODE( p_partner_id, FND_API.G_MISS_NUM, NULL, p_partner_id),
         DECODE( p_access_level_flag, FND_API.g_miss_char, NULL, p_access_level_flag),
         DECODE( p_interaction_level, FND_API.G_MISS_NUM, NULL, p_interaction_level));

 INSERT INTO pv_ge_history_log_tl(
         entity_history_log_id ,
         language ,
         last_update_date ,
         last_updated_by ,
         creation_date ,
         created_by ,
         last_update_login ,
         source_lang ,
         COMMENTS
)
SELECT
         DECODE( px_entity_history_log_id, FND_API.G_MISS_NUM, NULL, px_entity_history_log_id),
         l.language_code,
         DECODE( p_last_update_date, NULL, SYSDATE, p_last_update_date),
         DECODE( p_last_updated_by, NULL, FND_GLOBAL.USER_ID, p_last_updated_by),
         DECODE( p_creation_date, NULL, SYSDATE, p_creation_date),
         DECODE( p_created_by, NULL, FND_GLOBAL.USER_ID, p_created_by),
         DECODE( p_last_update_login, NULL, FND_GLOBAL.CONC_LOGIN_ID, p_last_update_login),
         USERENV('LANG'),
         DECODE( p_COMMENTS , FND_API.G_MISS_CHAR, NULL, p_COMMENTS)
 FROM fnd_languages l
 WHERE l.installed_flag IN ('I','B')
 AND   NOT EXISTS(SELECT NULL FROM pv_ge_history_log_tl t
                  WHERE t.entity_history_log_id = DECODE( px_entity_history_log_id, FND_API.G_MISS_NUM, NULL, px_entity_history_log_id)
                  AND   t.language = l.language_code);
END Insert_Row;




--  ========================================================
--
--  NAME
--  Update_Row
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Update_Row(
        p_entity_history_log_id    NUMBER,
        p_object_version_number   IN NUMBER,
        p_arc_history_for_entity_code    VARCHAR2,
        p_history_for_entity_id    NUMBER,
        p_message_code    VARCHAR2,
        p_history_category_code    VARCHAR2,
        p_last_updated_by    NUMBER,
        p_last_update_date    DATE,
        p_last_update_login    NUMBER,
        p_partner_id    NUMBER,
        p_access_level_flag    VARCHAR2,
        p_interaction_level    NUMBER,
        p_COMMENTS    VARCHAR2
)

IS
BEGIN
  Update pv_ge_history_log_b
  SET
            entity_history_log_id = DECODE( p_entity_history_log_id, null, entity_history_log_id, FND_API.G_MISS_NUM, null, p_entity_history_log_id),
          object_version_number = nvl(p_object_version_number,0) + 1 ,
            arc_history_for_entity_code = DECODE( p_arc_history_for_entity_code, null, arc_history_for_entity_code, FND_API.g_miss_char, null, p_arc_history_for_entity_code),
            history_for_entity_id = DECODE( p_history_for_entity_id, null, history_for_entity_id, FND_API.G_MISS_NUM, null, p_history_for_entity_id),
            message_code = DECODE( p_message_code, null, message_code, FND_API.g_miss_char, null, p_message_code),
            history_category_code = DECODE( p_history_category_code, null, history_category_code, FND_API.g_miss_char, null, p_history_category_code),
            last_updated_by = DECODE( p_last_updated_by, null, last_updated_by, FND_API.G_MISS_NUM, null, p_last_updated_by),
            last_update_date = DECODE( p_last_update_date, null, last_update_date, FND_API.G_MISS_DATE, null, p_last_update_date),
            last_update_login = DECODE( p_last_update_login, null, last_update_login, FND_API.G_MISS_NUM, null, p_last_update_login),
            partner_id = DECODE( p_partner_id, null, partner_id, FND_API.G_MISS_NUM, null, p_partner_id),
            access_level_flag = DECODE( p_access_level_flag, null, access_level_flag, FND_API.g_miss_char, null, p_access_level_flag),
            interaction_level = DECODE( p_interaction_level, null, interaction_level, FND_API.G_MISS_NUM, null, p_interaction_level)
 WHERE entity_history_log_id = p_entity_history_log_id
 AND   object_version_number = p_object_version_number;

 UPDATE pv_ge_history_log_tl
 set COMMENTS   = DECODE( p_COMMENTS, null, COMMENTS, FND_API.g_miss_char, null, p_COMMENTS),
     last_update_date   = DECODE( p_last_update_date, null, last_update_date, FND_API.G_MISS_DATE, null, p_last_update_date),
     last_updated_by   = DECODE( p_last_updated_by, null, last_updated_by, FND_API.G_MISS_NUM, null, p_last_updated_by),
     last_update_login   = DECODE( p_last_update_login, null, last_update_login, FND_API.G_MISS_NUM, null, p_last_update_login),
     source_lang = USERENV('LANG')
 WHERE entity_history_log_id = p_entity_history_log_id
 AND USERENV('LANG') IN (language, source_lang);

 IF (SQL%NOTFOUND) THEN
    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
 END IF;


END Update_Row;




--  ========================================================
--
--  NAME
--  Delete_Row
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Delete_Row(
  p_entity_history_log_id  NUMBER,
  p_object_version_number  NUMBER)
IS
BEGIN
 DELETE FROM pv_ge_history_log_b
  WHERE entity_history_log_id = p_entity_history_log_id
  AND object_version_number = p_object_version_number;
 If (SQL%NOTFOUND) then
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 End If;
END Delete_Row ;





--  ========================================================
--
--  NAME
--  Lock_Row
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Lock_Row(
  p_entity_history_log_id  NUMBER,
  p_object_version_number  NUMBER)
IS
 CURSOR C IS
      SELECT *
       FROM pv_ge_history_log_b
      WHERE entity_history_log_id =  p_entity_history_log_id
      AND object_version_number = p_object_version_number
      FOR UPDATE OF entity_history_log_id NOWAIT;
 Recinfo C%ROWTYPE;
BEGIN

 OPEN c;
 FETCH c INTO Recinfo;
 IF (c%NOTFOUND) THEN
    CLOSE c;
    AMS_Utility_PVT.error_message ('AMS_API_RECORD_NOT_FOUND');
    RAISE FND_API.g_exc_error;
 END IF;
 CLOSE c;
END Lock_Row;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           add_language
--   Type
--           Private
--   History
--
--   NOTE
--
-- End of Comments
-- ===============================================================


PROCEDURE Add_Language
IS
BEGIN

  -- changing by pukken as per performance team guidelines to fix performance issue
  -- as described in bug 3723612 (*** RTIKKU  03/24/05 12:46pm ***)
  INSERT /*+ append parallel(tt) */ INTO  pv_ge_history_log_tl tt
  (
     entity_history_log_id,
     creation_date,
     created_by,
     last_update_date,
     last_updated_by,
     last_update_login,
     comments,
     language,
     source_lang
  )
  SELECT /*+ parallel(v) parallel(t) use_nl(t)  */ v.*
  FROM
     (
        SELECT /*+ no_merge ordered parallel(b) */
        b.entity_history_log_id,
        b.creation_date,
        b.created_by,
        b.last_update_date,
        b.last_updated_by,
        b.last_update_login,
        b.comments,
        l.language_code,
        b.source_lang
        FROM   pv_ge_history_log_tl B , FND_LANGUAGES L
        WHERE L.INSTALLED_FLAG IN ( 'I','B' ) AND B.LANGUAGE = USERENV ( 'LANG' )
     ) v
     ,  pv_ge_history_log_tl t
  WHERE t.entity_history_log_id(+) = v.entity_history_log_id
  AND t.language(+) = v.language_code
  AND t.entity_history_log_id IS NULL ;


END ADD_LANGUAGE;

END PV_Ge_Hist_Log_PKG;

/
