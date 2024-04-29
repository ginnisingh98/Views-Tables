--------------------------------------------------------
--  DDL for Package Body PV_GE_CHKLST_RESP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_GE_CHKLST_RESP_PKG" as
/* $Header: pvxtgcrb.pls 115.4 2002/12/10 10:24:11 anubhavk ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_Ge_Chklst_Resp_PKG
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


G_PKG_NAME CONSTANT VARCHAR2(30):= 'PV_Ge_Chklst_Resp_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxtgcrb.pls';




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
          px_chklst_response_id   IN OUT NOCOPY NUMBER,
          p_checklist_item_id    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_arc_response_for_entity_code    VARCHAR2,
          p_response_flag    VARCHAR2,
          p_response_for_entity_id    NUMBER,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER)

 IS
   x_rowid    VARCHAR2(30);


BEGIN


   px_object_version_number := nvl(px_object_version_number, 1);


   INSERT INTO pv_ge_chklst_responses(
           chklst_response_id,
           checklist_item_id,
           object_version_number,
           arc_response_for_entity_code,
           response_flag,
           response_for_entity_id,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login
   ) VALUES (
           DECODE( px_chklst_response_id, FND_API.G_MISS_NUM, NULL, px_chklst_response_id),
           DECODE( p_checklist_item_id, FND_API.G_MISS_NUM, NULL, p_checklist_item_id),
           DECODE( px_object_version_number, FND_API.G_MISS_NUM, 1, px_object_version_number),
           DECODE( p_arc_response_for_entity_code, FND_API.g_miss_char, NULL, p_arc_response_for_entity_code),
           DECODE( p_response_flag, FND_API.g_miss_char, NULL, p_response_flag),
           DECODE( p_response_for_entity_id, FND_API.G_MISS_NUM, NULL, p_response_for_entity_id),
           DECODE( p_created_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_created_by),
           DECODE( p_creation_date, FND_API.G_MISS_DATE, SYSDATE, p_creation_date),
           DECODE( p_last_updated_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_last_updated_by),
           DECODE( p_last_update_date, FND_API.G_MISS_DATE, SYSDATE, p_last_update_date),
           DECODE( p_last_update_login, FND_API.G_MISS_NUM, FND_GLOBAL.CONC_LOGIN_ID, p_last_update_login));

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
          p_chklst_response_id    NUMBER,
          p_checklist_item_id    NUMBER,
          p_object_version_number   IN NUMBER,
          p_arc_response_for_entity_code    VARCHAR2,
          p_response_flag    VARCHAR2,
          p_response_for_entity_id    NUMBER,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER)

 IS
 BEGIN
    Update pv_ge_chklst_responses
    SET
              chklst_response_id = DECODE( p_chklst_response_id, null, chklst_response_id, FND_API.G_MISS_NUM, null, p_chklst_response_id),
              checklist_item_id = DECODE( p_checklist_item_id, null, checklist_item_id, FND_API.G_MISS_NUM, null, p_checklist_item_id),
            object_version_number = nvl(p_object_version_number,0) + 1 ,
              arc_response_for_entity_code = DECODE( p_arc_response_for_entity_code, null, arc_response_for_entity_code, FND_API.g_miss_char, null, p_arc_response_for_entity_code),
              response_flag = DECODE( p_response_flag, null, response_flag, FND_API.g_miss_char, null, p_response_flag),
              response_for_entity_id = DECODE( p_response_for_entity_id, null, response_for_entity_id, FND_API.G_MISS_NUM, null, p_response_for_entity_id),
              last_updated_by = DECODE( p_last_updated_by, null, last_updated_by, FND_API.G_MISS_NUM, null, p_last_updated_by),
              last_update_date = DECODE( p_last_update_date, null, last_update_date, FND_API.G_MISS_DATE, null, p_last_update_date),
              last_update_login = DECODE( p_last_update_login, null, last_update_login, FND_API.G_MISS_NUM, null, p_last_update_login)
   WHERE chklst_response_id = p_chklst_response_id
   AND   object_version_number = p_object_version_number;


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
    p_chklst_response_id  NUMBER,
    p_object_version_number  NUMBER)
 IS
 BEGIN
   DELETE FROM pv_ge_chklst_responses
    WHERE chklst_response_id = p_chklst_response_id
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
    p_chklst_response_id  NUMBER,
    p_object_version_number  NUMBER)
 IS
   CURSOR C IS
        SELECT *
         FROM pv_ge_chklst_responses
        WHERE chklst_response_id =  p_chklst_response_id
        AND object_version_number = p_object_version_number
        FOR UPDATE OF chklst_response_id NOWAIT;
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



END PV_Ge_Chklst_Resp_PKG;

/
