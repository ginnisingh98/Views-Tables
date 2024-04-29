--------------------------------------------------------
--  DDL for Package Body PV_GE_CHKLST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_GE_CHKLST_PKG" as
/* $Header: pvxtgcib.pls 120.0 2005/05/27 16:03:10 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_Ge_Chklst_PKG
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


G_PKG_NAME CONSTANT VARCHAR2(30):= 'PV_Ge_Chklst_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxtgcib.pls';




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
          px_checklist_item_id   IN OUT NOCOPY NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_arc_used_by_entity_code    VARCHAR2,
          p_used_by_entity_id    NUMBER,
          p_sequence_num    NUMBER,
          p_is_required_flag    VARCHAR2,
          p_enabled_flag    VARCHAR2,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          p_checklist_item_name    VARCHAR2
)

 IS
   x_rowid    VARCHAR2(30);


BEGIN


   px_object_version_number := nvl(px_object_version_number, 1);


   INSERT INTO pv_ge_chklst_items_b(
           checklist_item_id,
           object_version_number,
           arc_used_by_entity_code,
           used_by_entity_id,
           sequence_num,
           is_required_flag,
           enabled_flag,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login
   ) VALUES (
           DECODE( px_checklist_item_id, FND_API.G_MISS_NUM, NULL, px_checklist_item_id),
           DECODE( px_object_version_number, FND_API.G_MISS_NUM, 1, px_object_version_number),
           DECODE( p_arc_used_by_entity_code, FND_API.g_miss_char, NULL, p_arc_used_by_entity_code),
           DECODE( p_used_by_entity_id, FND_API.G_MISS_NUM, NULL, p_used_by_entity_id),
           DECODE( p_sequence_num, FND_API.G_MISS_NUM, NULL, p_sequence_num),
           DECODE( p_is_required_flag, FND_API.g_miss_char, NULL, p_is_required_flag),
           DECODE( p_enabled_flag, FND_API.g_miss_char, NULL, p_enabled_flag),
           DECODE( p_created_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_created_by),
           DECODE( p_creation_date, FND_API.G_MISS_DATE, SYSDATE, p_creation_date),
           DECODE( p_last_updated_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_last_updated_by),
           DECODE( p_last_update_date, FND_API.G_MISS_DATE, SYSDATE, p_last_update_date),
           DECODE( p_last_update_login, FND_API.G_MISS_NUM, FND_GLOBAL.CONC_LOGIN_ID, p_last_update_login));

   INSERT INTO pv_ge_chklst_items_tl(
           checklist_item_id ,
           language ,
           last_update_date ,
           last_updated_by ,
           creation_date ,
           created_by ,
           last_update_login ,
           source_lang ,
           checklist_item_name
)
SELECT
           DECODE( px_checklist_item_id, FND_API.G_MISS_NUM, NULL, px_checklist_item_id),
           l.language_code,
           DECODE( p_last_update_date, NULL, SYSDATE, p_last_update_date),
           DECODE( p_last_updated_by, NULL, FND_GLOBAL.USER_ID, p_last_updated_by),
           DECODE( p_creation_date, NULL, SYSDATE, p_creation_date),
           DECODE( p_created_by, NULL, FND_GLOBAL.USER_ID, p_created_by),
           DECODE( p_last_update_login, NULL, FND_GLOBAL.CONC_LOGIN_ID, p_last_update_login),
           USERENV('LANG'),
           DECODE( p_checklist_item_name , FND_API.G_MISS_CHAR, NULL, p_checklist_item_name)
   FROM fnd_languages l
   WHERE l.installed_flag IN ('I','B')
   AND   NOT EXISTS(SELECT NULL FROM pv_ge_chklst_items_tl t
                    WHERE t.checklist_item_id = DECODE( px_checklist_item_id, FND_API.G_MISS_NUM, NULL, px_checklist_item_id)
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
          p_checklist_item_id    NUMBER,
          p_object_version_number   IN NUMBER,
          p_arc_used_by_entity_code    VARCHAR2,
          p_used_by_entity_id    NUMBER,
          p_sequence_num    NUMBER,
          p_is_required_flag    VARCHAR2,
          p_enabled_flag    VARCHAR2,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          p_checklist_item_name    VARCHAR2
)

 IS
 BEGIN
    Update pv_ge_chklst_items_b
    SET
              checklist_item_id = DECODE( p_checklist_item_id, null, checklist_item_id, FND_API.G_MISS_NUM, null, p_checklist_item_id),
            object_version_number = nvl(p_object_version_number,0) + 1 ,
              arc_used_by_entity_code = DECODE( p_arc_used_by_entity_code, null, arc_used_by_entity_code, FND_API.g_miss_char, null, p_arc_used_by_entity_code),
              used_by_entity_id = DECODE( p_used_by_entity_id, null, used_by_entity_id, FND_API.G_MISS_NUM, null, p_used_by_entity_id),
              sequence_num = DECODE( p_sequence_num, null, sequence_num, FND_API.G_MISS_NUM, null, p_sequence_num),
              is_required_flag = DECODE( p_is_required_flag, null, is_required_flag, FND_API.g_miss_char, null, p_is_required_flag),
              enabled_flag = DECODE( p_enabled_flag, null, enabled_flag, FND_API.g_miss_char, null, p_enabled_flag),
              last_updated_by = DECODE( p_last_updated_by, null, last_updated_by, FND_API.G_MISS_NUM, null, p_last_updated_by),
              last_update_date = DECODE( p_last_update_date, null, last_update_date, FND_API.G_MISS_DATE, null, p_last_update_date),
              last_update_login = DECODE( p_last_update_login, null, last_update_login, FND_API.G_MISS_NUM, null, p_last_update_login)
   WHERE checklist_item_id = p_checklist_item_id;
   --AND   object_version_number = p_object_version_number;

   UPDATE pv_ge_chklst_items_tl
   set checklist_item_name   = DECODE( p_checklist_item_name, null, checklist_item_name, FND_API.g_miss_char, null, p_checklist_item_name),
       last_update_date   = DECODE( p_last_update_date, null, last_update_date, FND_API.G_MISS_DATE, null, p_last_update_date),
       last_updated_by   = DECODE( p_last_updated_by, null, last_updated_by, FND_API.G_MISS_NUM, null, p_last_updated_by),
       last_update_login   = DECODE( p_last_update_login, null, last_update_login, FND_API.G_MISS_NUM, null, p_last_update_login),
       source_lang = USERENV('LANG')
   WHERE checklist_item_id = p_checklist_item_id
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
    p_checklist_item_id  NUMBER,
    p_object_version_number  NUMBER)
 IS
 BEGIN
   DELETE FROM pv_ge_chklst_items_b
    WHERE checklist_item_id = p_checklist_item_id
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
    p_checklist_item_id  NUMBER,
    p_object_version_number  NUMBER)
 IS
   CURSOR C IS
        SELECT *
         FROM pv_ge_chklst_items_b
        WHERE checklist_item_id =  p_checklist_item_id
        AND object_version_number = p_object_version_number
        FOR UPDATE OF checklist_item_id NOWAIT;
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
   -- changing by ktsao as per performance team guidelines to fix performance issue
   -- as described in bug 3723612 (*** RTIKKU  03/24/05 12:46pm ***)
   INSERT /*+ append parallel(tt) */  INTO pv_ge_chklst_items_tl tt (
   checklist_item_id,
   creation_date,
   created_by,
   last_update_date,
   last_updated_by,
   last_update_login,
   checklist_item_name,
   language,
   source_lang
   )
   select /*+ parallel(v) parallel(t) use_nl(t)  */ v.* from
    ( SELECT /*+ no_merge ordered parallel(b) */
       b.checklist_item_id,
       b.creation_date,
       b.created_by,
       b.last_update_date,
       b.last_updated_by,
       b.last_update_login,
       b.checklist_item_name,
       l.language_code,
       b.source_lang
      FROM pv_ge_chklst_items_tl B ,
        FND_LANGUAGES L
   WHERE L.INSTALLED_FLAG IN ( 'I','B' )
     AND B.LANGUAGE = USERENV ( 'LANG' )
   ) v, pv_ge_chklst_items_tl t
    WHERE t.checklist_item_id(+) = v.checklist_item_id
   AND t.language(+) = v.language_code
   AND t.checklist_item_id IS NULL;

END ADD_LANGUAGE;




END PV_Ge_Chklst_PKG;

/
