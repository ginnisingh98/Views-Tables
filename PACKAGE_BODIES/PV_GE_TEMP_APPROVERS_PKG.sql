--------------------------------------------------------
--  DDL for Package Body PV_GE_TEMP_APPROVERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_GE_TEMP_APPROVERS_PKG" as
/* $Header: pvxtptab.pls 120.1 2006/01/25 15:42:36 ktsao noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          Pv_Ge_Temp_Approvers_PKG
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


G_PKG_NAME CONSTANT VARCHAR2(30):= 'Pv_Ge_Temp_Approvers_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxtptab.pls';




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
          px_entity_approver_id   IN OUT NOCOPY NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_arc_appr_for_entity_code    VARCHAR2,
          p_appr_for_entity_id    NUMBER,
          p_approver_id    NUMBER,
          p_approver_type_code    VARCHAR2,
          p_approval_status_code    VARCHAR2,
          p_workflow_item_key    VARCHAR2,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER)

 IS
   x_rowid    VARCHAR2(30);


BEGIN


   px_object_version_number := nvl(px_object_version_number, 1);


   INSERT INTO pv_ge_temp_approvers(
           entity_approver_id,
           object_version_number,
           arc_appr_for_entity_code,
           appr_for_entity_id,
           approver_id,
           approver_type_code,
           approval_status_code,
           workflow_item_key,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login
   ) VALUES (
           DECODE( px_entity_approver_id, FND_API.G_MISS_NUM, NULL, px_entity_approver_id),
           DECODE( px_object_version_number, FND_API.G_MISS_NUM, 1, px_object_version_number),
           DECODE( p_arc_appr_for_entity_code, FND_API.g_miss_char, NULL, p_arc_appr_for_entity_code),
           DECODE( p_appr_for_entity_id, FND_API.G_MISS_NUM, NULL, p_appr_for_entity_id),
           DECODE( p_approver_id, FND_API.G_MISS_NUM, NULL, p_approver_id),
           DECODE( p_approver_type_code, FND_API.g_miss_char, NULL, p_approver_type_code),
           DECODE( p_approval_status_code, FND_API.g_miss_char, NULL, p_approval_status_code),
           DECODE( p_workflow_item_key, FND_API.g_miss_char, NULL, p_workflow_item_key),
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
          p_entity_approver_id    NUMBER,
          p_object_version_number   IN NUMBER,
          p_arc_appr_for_entity_code    VARCHAR2,
          p_appr_for_entity_id    NUMBER,
          p_approver_id    NUMBER,
          p_approver_type_code    VARCHAR2,
          p_approval_status_code    VARCHAR2,
          p_workflow_item_key    VARCHAR2,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER)

 IS
 BEGIN
    Update pv_ge_temp_approvers
    SET
              entity_approver_id = DECODE( p_entity_approver_id, null, entity_approver_id, FND_API.G_MISS_NUM, null, p_entity_approver_id),
            object_version_number = nvl(p_object_version_number,0) + 1 ,
              arc_appr_for_entity_code = DECODE( p_arc_appr_for_entity_code, null, arc_appr_for_entity_code, FND_API.g_miss_char, null, p_arc_appr_for_entity_code),
              appr_for_entity_id = DECODE( p_appr_for_entity_id, null, appr_for_entity_id, FND_API.G_MISS_NUM, null, p_appr_for_entity_id),
              approver_id = DECODE( p_approver_id, null, approver_id, FND_API.G_MISS_NUM, null, p_approver_id),
              approver_type_code = DECODE( p_approver_type_code, null, approver_type_code, FND_API.g_miss_char, null, p_approver_type_code),
              approval_status_code = DECODE( p_approval_status_code, null, approval_status_code, FND_API.g_miss_char, null, p_approval_status_code),
              workflow_item_key = DECODE( p_workflow_item_key, null, workflow_item_key, FND_API.g_miss_char, null, p_workflow_item_key),
              last_updated_by = DECODE( p_last_updated_by, null, last_updated_by, FND_API.G_MISS_NUM, null, p_last_updated_by),
              last_update_date = DECODE( p_last_update_date, null, last_update_date, FND_API.G_MISS_DATE, null, p_last_update_date),
              last_update_login = DECODE( p_last_update_login, null, last_update_login, FND_API.G_MISS_NUM, null, p_last_update_login)
   WHERE entity_approver_id = p_entity_approver_id
   AND   object_version_number = p_object_version_number;


   IF (SQL%NOTFOUND) THEN
      RAISE PVX_Utility_PVT.API_RECORD_CHANGED;
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
    p_entity_approver_id  NUMBER,
    p_object_version_number  NUMBER)
 IS
 BEGIN
   DELETE FROM pv_ge_temp_approvers
    WHERE entity_approver_id = p_entity_approver_id
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
    p_entity_approver_id  NUMBER,
    p_object_version_number  NUMBER)
 IS
   CURSOR C IS
        SELECT *
         FROM pv_ge_temp_approvers
        WHERE entity_approver_id =  p_entity_approver_id
        AND object_version_number = p_object_version_number
        FOR UPDATE OF entity_approver_id NOWAIT;
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



END Pv_Ge_Temp_Approvers_PKG;

/
