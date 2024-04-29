--------------------------------------------------------
--  DDL for Package Body PV_PEC_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_PEC_RULES_PKG" as
/* $Header: pvxtecrb.pls 115.3 2002/12/10 10:26:37 swkulkar ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_Pec_Rules_PKG
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


G_PKG_NAME CONSTANT VARCHAR2(30):= 'PV_Pec_Rules_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxtecrb.pls';




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
          px_enrl_change_rule_id   IN OUT NOCOPY NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_change_from_program_id    NUMBER,
          p_change_to_program_id    NUMBER,
          p_change_direction_code    VARCHAR2,
          p_effective_from_date    DATE,
          p_effective_to_date    DATE,
          p_active_flag    VARCHAR2,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER)

 IS
   x_rowid    VARCHAR2(30);


BEGIN


   px_object_version_number := nvl(px_object_version_number, 1);


   INSERT INTO pv_pg_enrl_change_rules(
           enrl_change_rule_id,
           object_version_number,
           change_from_program_id,
           change_to_program_id,
           change_direction_code,
           effective_from_date,
           effective_to_date,
           active_flag,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login
   ) VALUES (
           DECODE( px_enrl_change_rule_id, FND_API.G_MISS_NUM, NULL, px_enrl_change_rule_id),
           DECODE( px_object_version_number, FND_API.G_MISS_NUM, 1, px_object_version_number),
           DECODE( p_change_from_program_id, FND_API.G_MISS_NUM, NULL, p_change_from_program_id),
           DECODE( p_change_to_program_id, FND_API.G_MISS_NUM, NULL, p_change_to_program_id),
           DECODE( p_change_direction_code, FND_API.g_miss_char, NULL, p_change_direction_code),
           DECODE( p_effective_from_date, FND_API.G_MISS_DATE, NULL, p_effective_from_date),
           DECODE( p_effective_to_date, FND_API.G_MISS_DATE, NULL, p_effective_to_date),
           DECODE( p_active_flag, FND_API.g_miss_char, NULL, p_active_flag),
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
          p_enrl_change_rule_id    	NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_change_from_program_id  NUMBER,
          p_change_to_program_id   	NUMBER,
          p_change_direction_code  	VARCHAR2,
          p_effective_from_date   DATE,
          p_effective_to_date   DATE,
          p_active_flag   VARCHAR2,
          p_last_updated_by   NUMBER,
          p_last_update_date   DATE,
          p_last_update_login   NUMBER)

 IS
 BEGIN
    Update pv_pg_enrl_change_rules
    SET
              enrl_change_rule_id = DECODE( p_enrl_change_rule_id, null, enrl_change_rule_id, FND_API.G_MISS_NUM, null, p_enrl_change_rule_id),
            object_version_number = object_version_number + 1 ,
              change_from_program_id = DECODE( p_change_from_program_id, null, change_from_program_id, FND_API.G_MISS_NUM, null, p_change_from_program_id),
              change_to_program_id = DECODE( p_change_to_program_id, null, change_to_program_id, FND_API.G_MISS_NUM, null, p_change_to_program_id),
              change_direction_code = DECODE( p_change_direction_code, null, change_direction_code, FND_API.g_miss_char, null, p_change_direction_code),
              effective_from_date = DECODE( p_effective_from_date, null, effective_from_date, FND_API.G_MISS_DATE, null, p_effective_from_date),
              effective_to_date = DECODE( p_effective_to_date, null, effective_to_date, FND_API.G_MISS_DATE, null, p_effective_to_date),
              active_flag = DECODE( p_active_flag, null, active_flag, FND_API.g_miss_char, null, p_active_flag),
              last_updated_by = DECODE( p_last_updated_by, null, last_updated_by, FND_API.G_MISS_NUM, null, p_last_updated_by),
              last_update_date = DECODE( p_last_update_date, null, last_update_date, FND_API.G_MISS_DATE, null, p_last_update_date),
              last_update_login = DECODE( p_last_update_login, null, last_update_login, FND_API.G_MISS_NUM, null, p_last_update_login)
   WHERE enrl_change_rule_id = p_enrl_change_rule_id;
--   AND   object_version_number = px_object_version_number;


   IF (SQL%NOTFOUND) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   px_object_version_number := nvl(px_object_version_number,0) + 1;

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
    p_enrl_change_rule_id  NUMBER,
    p_object_version_number  NUMBER)
 IS
 BEGIN
   DELETE FROM pv_pg_enrl_change_rules
    WHERE enrl_change_rule_id = p_enrl_change_rule_id
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
    p_enrl_change_rule_id  NUMBER,
    p_object_version_number  NUMBER)
 IS
   CURSOR C IS
        SELECT *
         FROM pv_pg_enrl_change_rules
        WHERE enrl_change_rule_id =  p_enrl_change_rule_id
        AND object_version_number = p_object_version_number
        FOR UPDATE OF enrl_change_rule_id NOWAIT;
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



END PV_Pec_Rules_PKG;

/
