--------------------------------------------------------
--  DDL for Package Body PV_GE_NOTIF_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_GE_NOTIF_RULES_PKG" as
/* $Header: pvxtgnrb.pls 115.5 2004/03/12 01:29:45 pukken ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_Ge_Notif_Rules_PKG
-- Purpose
--
-- History
--  15 Nov 2002  anubhavk created
--  19 Nov 2002 anubhavk  Updated - For NOCOPY by running nocopy.sh
--
-- NOTE
--
-- This Api is generated with Latest version of
-- Rosetta, where g_miss indicates NULL and
-- NULL indicates missing value. Rosetta Version 1.55
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'PV_Ge_Notif_Rules_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxtgnrb.pls';




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
PV_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
PV_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
PV_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Insert_Row(
          px_notif_rule_id   IN OUT NOCOPY NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_arc_notif_for_entity_code    VARCHAR2,
          p_notif_for_entity_id    NUMBER,
          p_wf_item_type_code    VARCHAR2,
          p_notif_type_code    VARCHAR2,
          p_active_flag    VARCHAR2,
          p_repeat_freq_unit    VARCHAR2,
          p_repeat_freq_value    NUMBER,
          p_send_notif_before_unit    VARCHAR2,
          p_send_notif_before_value    NUMBER,
          p_send_notif_after_unit    VARCHAR2,
          p_send_notif_after_value    NUMBER,
          p_repeat_until_unit    VARCHAR2,
          p_repeat_until_value    NUMBER,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          p_notif_name    VARCHAR2,
          p_notif_content    VARCHAR2,
          p_notif_desc    VARCHAR2
)

 IS
   x_rowid    VARCHAR2(30);


BEGIN


   px_object_version_number := nvl(px_object_version_number, 1);


   INSERT INTO pv_ge_notif_rules_b(
           notif_rule_id,
           object_version_number,
           arc_notif_for_entity_code,
           notif_for_entity_id,
           wf_item_type_code,
           notif_type_code,
           active_flag,
           repeat_freq_unit,
           repeat_freq_value,
           send_notif_before_unit,
           send_notif_before_value,
           send_notif_after_unit,
           send_notif_after_value,
           repeat_until_unit,
           repeat_until_value,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login
   ) VALUES (
           DECODE( px_notif_rule_id, FND_API.G_MISS_NUM, NULL, px_notif_rule_id),
           DECODE( px_object_version_number, FND_API.G_MISS_NUM, 1, px_object_version_number),
           DECODE( p_arc_notif_for_entity_code, FND_API.g_miss_char, NULL, p_arc_notif_for_entity_code),
           DECODE( p_notif_for_entity_id, FND_API.G_MISS_NUM, NULL, p_notif_for_entity_id),
           DECODE( p_wf_item_type_code, FND_API.g_miss_char, NULL, p_wf_item_type_code),
           DECODE( p_notif_type_code, FND_API.g_miss_char, NULL, p_notif_type_code),
           DECODE( p_active_flag, FND_API.g_miss_char, NULL, p_active_flag),
           DECODE( p_repeat_freq_unit, FND_API.g_miss_char, NULL, p_repeat_freq_unit),
           DECODE( p_repeat_freq_value, FND_API.G_MISS_NUM, NULL, p_repeat_freq_value),
           DECODE( p_send_notif_before_unit, FND_API.g_miss_char, NULL, p_send_notif_before_unit),
           DECODE( p_send_notif_before_value, FND_API.G_MISS_NUM, NULL, p_send_notif_before_value),
           DECODE( p_send_notif_after_unit, FND_API.g_miss_char, NULL, p_send_notif_after_unit),
           DECODE( p_send_notif_after_value, FND_API.G_MISS_NUM, NULL, p_send_notif_after_value),
           DECODE( p_repeat_until_unit, FND_API.g_miss_char, NULL, p_repeat_until_unit),
           DECODE( p_repeat_until_value, FND_API.G_MISS_NUM, NULL, p_repeat_until_value),
           DECODE( p_created_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_created_by),
           DECODE( p_creation_date, FND_API.G_MISS_DATE, SYSDATE, p_creation_date),
           DECODE( p_last_updated_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_last_updated_by),
           DECODE( p_last_update_date, FND_API.G_MISS_DATE, SYSDATE, p_last_update_date),
           DECODE( p_last_update_login, FND_API.G_MISS_NUM, FND_GLOBAL.CONC_LOGIN_ID, p_last_update_login));

   INSERT INTO pv_ge_notif_rules_tl(
           notif_rule_id ,
           language ,
           last_update_date ,
           last_updated_by ,
           creation_date ,
           created_by ,
           last_update_login ,
           source_lang ,
           notif_name,
           notif_content,
           notif_desc
)
SELECT
           DECODE( px_notif_rule_id, FND_API.G_MISS_NUM, NULL, px_notif_rule_id),
           l.language_code,
           DECODE( p_last_update_date, NULL, SYSDATE, p_last_update_date),
           DECODE( p_last_updated_by, NULL, FND_GLOBAL.USER_ID, p_last_updated_by),
           DECODE( p_creation_date, NULL, SYSDATE, p_creation_date),
           DECODE( p_created_by, NULL, FND_GLOBAL.USER_ID, p_created_by),
           DECODE( p_last_update_login, NULL, FND_GLOBAL.CONC_LOGIN_ID, p_last_update_login),
           USERENV('LANG'),
           DECODE( p_notif_name , FND_API.G_MISS_CHAR, NULL, p_notif_name),
           DECODE( p_notif_content , FND_API.G_MISS_CHAR, NULL, p_notif_content),
           DECODE( p_notif_desc , FND_API.G_MISS_CHAR, NULL, p_notif_desc)
   FROM fnd_languages l
   WHERE l.installed_flag IN ('I','B')
   AND   NOT EXISTS(SELECT NULL FROM pv_ge_notif_rules_tl t
                    WHERE t.notif_rule_id = DECODE( px_notif_rule_id, FND_API.G_MISS_NUM, NULL, px_notif_rule_id)
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
          p_notif_rule_id    NUMBER,
          p_object_version_number   IN NUMBER,
          p_arc_notif_for_entity_code    VARCHAR2,
          p_notif_for_entity_id    NUMBER,
          p_wf_item_type_code    VARCHAR2,
          p_notif_type_code    VARCHAR2,
          p_active_flag    VARCHAR2,
          p_repeat_freq_unit    VARCHAR2,
          p_repeat_freq_value    NUMBER,
          p_send_notif_before_unit    VARCHAR2,
          p_send_notif_before_value    NUMBER,
          p_send_notif_after_unit    VARCHAR2,
          p_send_notif_after_value    NUMBER,
          p_repeat_until_unit    VARCHAR2,
          p_repeat_until_value    NUMBER,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          p_notif_name    VARCHAR2,
          p_notif_content    VARCHAR2,
          p_notif_desc    VARCHAR2
)

 IS
 BEGIN
    Update pv_ge_notif_rules_b
    SET
              notif_rule_id = DECODE( p_notif_rule_id, null, notif_rule_id, FND_API.G_MISS_NUM, null, p_notif_rule_id),
            object_version_number = nvl(p_object_version_number,0) + 1 ,
              arc_notif_for_entity_code = DECODE( p_arc_notif_for_entity_code, null, arc_notif_for_entity_code, FND_API.g_miss_char, null, p_arc_notif_for_entity_code),
              notif_for_entity_id = DECODE( p_notif_for_entity_id, null, notif_for_entity_id, FND_API.G_MISS_NUM, null, p_notif_for_entity_id),
              wf_item_type_code = DECODE( p_wf_item_type_code, null, wf_item_type_code, FND_API.g_miss_char, null, p_wf_item_type_code),
              notif_type_code = DECODE( p_notif_type_code, null, notif_type_code, FND_API.g_miss_char, null, p_notif_type_code),
              active_flag = DECODE( p_active_flag, null, active_flag, FND_API.g_miss_char, null, p_active_flag),
              repeat_freq_unit = DECODE( p_repeat_freq_unit, null, repeat_freq_unit, FND_API.g_miss_char, null, p_repeat_freq_unit),
              repeat_freq_value = DECODE( p_repeat_freq_value, null, repeat_freq_value, FND_API.G_MISS_NUM, null, p_repeat_freq_value),
              send_notif_before_unit = DECODE( p_send_notif_before_unit, null, send_notif_before_unit, FND_API.g_miss_char, null, p_send_notif_before_unit),
              send_notif_before_value = DECODE( p_send_notif_before_value, null, send_notif_before_value, FND_API.G_MISS_NUM, null, p_send_notif_before_value),
              send_notif_after_unit = DECODE( p_send_notif_after_unit, null, send_notif_after_unit, FND_API.g_miss_char, null, p_send_notif_after_unit),
              send_notif_after_value = DECODE( p_send_notif_after_value, null, send_notif_after_value, FND_API.G_MISS_NUM, null, p_send_notif_after_value),
              repeat_until_unit = DECODE( p_repeat_until_unit, null, repeat_until_unit, FND_API.g_miss_char, null, p_repeat_until_unit),
              repeat_until_value = DECODE( p_repeat_until_value, null, repeat_until_value, FND_API.G_MISS_NUM, null, p_repeat_until_value),
              last_updated_by = DECODE( p_last_updated_by, null, last_updated_by, FND_API.G_MISS_NUM, null, p_last_updated_by),
              last_update_date = DECODE( p_last_update_date, null, last_update_date, FND_API.G_MISS_DATE, null, p_last_update_date),
              last_update_login = DECODE( p_last_update_login, null, last_update_login, FND_API.G_MISS_NUM, null, p_last_update_login)
   WHERE notif_rule_id = p_notif_rule_id;
   --AND   object_version_number = p_object_version_number;

   UPDATE pv_ge_notif_rules_tl
   set notif_name   = DECODE( p_notif_name, null, notif_name, FND_API.g_miss_char, null, p_notif_name),
       notif_content   = DECODE( p_notif_content, null, notif_content, FND_API.g_miss_char, null, p_notif_content),
       notif_desc   = DECODE( p_notif_desc, null, notif_desc, FND_API.g_miss_char, null, p_notif_desc),
       last_update_date   = DECODE( p_last_update_date, null, last_update_date, FND_API.G_MISS_DATE, null, p_last_update_date),
       last_updated_by   = DECODE( p_last_updated_by, null, last_updated_by, FND_API.G_MISS_NUM, null, p_last_updated_by),
       last_update_login   = DECODE( p_last_update_login, null, last_update_login, FND_API.G_MISS_NUM, null, p_last_update_login),
       source_lang = USERENV('LANG')
   WHERE notif_rule_id = p_notif_rule_id
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
    p_notif_rule_id  NUMBER,
    p_object_version_number  NUMBER)
 IS
 BEGIN
   DELETE FROM pv_ge_notif_rules_b
    WHERE notif_rule_id = p_notif_rule_id
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
    p_notif_rule_id  NUMBER,
    p_object_version_number  NUMBER)
 IS
   CURSOR C IS
        SELECT *
         FROM pv_ge_notif_rules_b
        WHERE notif_rule_id =  p_notif_rule_id
        AND object_version_number = p_object_version_number
        FOR UPDATE OF notif_rule_id NOWAIT;
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
   delete from pv_ge_notif_rules_tl T
   where not exists
   (select NULL
   from pv_ge_notif_rules_b b
   where b.notif_rule_id = t.notif_rule_id
   );

   update pv_ge_notif_rules_tl t set (
   --notif_rule_name
   --, description
   notif_name,
   notif_content,
   notif_desc
   ) = (select
   --b.notif_rule_name
   --, b.description
   b.notif_name,
   b.notif_content,
   b.notif_desc
   from pv_ge_notif_rules_tl b
   where b.notif_rule_id = t.notif_rule_id
   and b.language = t.source_lang)
   where (
   t.notif_rule_id,
   t.language
   ) in (select
           subt.notif_rule_id,
           subt.language
           from pv_ge_notif_rules_tl subb, pv_ge_notif_rules_tl subt
           where subb.notif_rule_id  = subt.notif_rule_id
           and subb.language = subt.source_lang
	   and (subb.notif_name <> subt.notif_name
           or   subb.notif_content <> subt.notif_content
           or subb.notif_desc <> subt.notif_desc
           or (subb.notif_desc is null and subt.notif_desc is not null)
           or (subb.notif_desc is not null and subt.notif_desc is null)
           --and (subb.notif_rule_name <> subt.notif_rule_name
           --or subb.description <> subt.description
           --or (subb.description is null and subt.description is not null)
           --or (subb.description is not null and subt.description is null)
           ));

   insert into pv_ge_notif_rules_tl (
   notif_rule_id,
   creation_date,
   created_by,
   last_update_date,
   last_updated_by,
   last_update_login,
   notif_name,
   notif_content,
   notif_desc,
   --notif_rule_name,
   --description,
   language,
   source_lang
   ) select
       b.notif_rule_id,
       b.creation_date,
       b.created_by,
       b.last_update_date,
       b.last_updated_by,
       b.last_update_login,
       b.notif_name,
       b.notif_content,
       b.notif_desc,
       --b.notif_rule_name,
       --b.description,
       l.language_code,
       b.source_lang
       from pv_ge_notif_rules_tl b, fnd_languages l
       where l.installed_flag in ('I', 'B')
           and b.language = userenv('lang')
           and not exists
           (select null
               from pv_ge_notif_rules_tl t
               where t.notif_rule_id = b.notif_rule_id
               and t.language = l.language_code);
END ADD_LANGUAGE;




END PV_Ge_Notif_Rules_PKG;

/
