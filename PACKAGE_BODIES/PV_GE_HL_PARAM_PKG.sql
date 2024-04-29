--------------------------------------------------------
--  DDL for Package Body PV_GE_HL_PARAM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_GE_HL_PARAM_PKG" as
/* $Header: pvxtghpb.pls 120.1 2005/07/19 09:38:43 appldev ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_Ge_Hl_Param_PKG
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


G_PKG_NAME CONSTANT VARCHAR2(30):= 'PV_Ge_Hl_Param_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxtghpb.pls';




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
          px_history_log_param_id   IN OUT NOCOPY NUMBER,
          p_entity_history_log_id    NUMBER,
          p_param_name    VARCHAR2,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_param_value    VARCHAR2,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          p_param_type        VARCHAR2,
          p_lookup_type       VARCHAR2)

 IS
   x_rowid    VARCHAR2(30);


BEGIN

   --dbms_output.put_line('value of px_hist_log_id '||to_char(px_history_log_param_id));
   px_object_version_number := nvl(px_object_version_number, 1);


   INSERT INTO pv_ge_history_log_params(
           history_log_param_id,
           entity_history_log_id,
           param_name,
           object_version_number,
           param_value,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login,
           param_type,
           lookup_type
   ) VALUES (
           DECODE( px_history_log_param_id, FND_API.G_MISS_NUM, NULL, px_history_log_param_id),
           DECODE( p_entity_history_log_id, FND_API.G_MISS_NUM, NULL, p_entity_history_log_id),
           DECODE( p_param_name, FND_API.g_miss_char, NULL, p_param_name),
           DECODE( px_object_version_number, FND_API.G_MISS_NUM, 1, px_object_version_number),
           DECODE( p_param_value, FND_API.g_miss_char, NULL, p_param_value),
           DECODE( p_created_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_created_by),
           DECODE( p_creation_date, FND_API.G_MISS_DATE, SYSDATE, p_creation_date),
           DECODE( p_last_updated_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_last_updated_by),
           DECODE( p_last_update_date, FND_API.G_MISS_DATE, SYSDATE, p_last_update_date),
           DECODE( p_last_update_login, FND_API.G_MISS_NUM, FND_GLOBAL.CONC_LOGIN_ID, p_last_update_login),
           DECODE( p_param_type, FND_API.g_miss_char, NULL, p_param_type),
           DECODE( p_lookup_type, FND_API.g_miss_char, NULL, p_lookup_type));

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
          p_history_log_param_id    NUMBER,
          p_entity_history_log_id    NUMBER,
          p_param_name    VARCHAR2,
          p_object_version_number   IN NUMBER,
          p_param_value    VARCHAR2,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          p_param_type        VARCHAR2,
          p_lookup_type       VARCHAR2)

 IS
 BEGIN
    Update pv_ge_history_log_params
    SET
              history_log_param_id = DECODE( p_history_log_param_id, null, history_log_param_id, FND_API.G_MISS_NUM, null, p_history_log_param_id),
              entity_history_log_id = DECODE( p_entity_history_log_id, null, entity_history_log_id, FND_API.G_MISS_NUM, null, p_entity_history_log_id),
              param_name = DECODE( p_param_name, null, param_name, FND_API.g_miss_char, null, p_param_name),
            object_version_number = nvl(p_object_version_number,0) + 1 ,
              param_value = DECODE( p_param_value, null, param_value, FND_API.g_miss_char, null, p_param_value),
              last_updated_by = DECODE( p_last_updated_by, null, last_updated_by, FND_API.G_MISS_NUM, null, p_last_updated_by),
              last_update_date = DECODE( p_last_update_date, null, last_update_date, FND_API.G_MISS_DATE, null, p_last_update_date),
              last_update_login = DECODE( p_last_update_login, null, last_update_login, FND_API.G_MISS_NUM, null, p_last_update_login),
              param_type = DECODE( p_param_type, null, p_param_type, FND_API.g_miss_char, null, p_param_type),
              lookup_type = DECODE( p_lookup_type, null, p_lookup_type, FND_API.g_miss_char, null, p_lookup_type)
   WHERE history_log_param_id = p_history_log_param_id
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
    p_history_log_param_id  NUMBER,
    p_object_version_number  NUMBER)
 IS
 BEGIN
   DELETE FROM pv_ge_history_log_params
    WHERE history_log_param_id = p_history_log_param_id
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
    p_history_log_param_id  NUMBER,
    p_object_version_number  NUMBER)
 IS
   CURSOR C IS
        SELECT *
         FROM pv_ge_history_log_params
        WHERE history_log_param_id =  p_history_log_param_id
        AND object_version_number = p_object_version_number
        FOR UPDATE OF history_log_param_id NOWAIT;
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



END PV_Ge_Hl_Param_PKG;

/
