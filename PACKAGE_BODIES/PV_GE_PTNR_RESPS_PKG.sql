--------------------------------------------------------
--  DDL for Package Body PV_GE_PTNR_RESPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_GE_PTNR_RESPS_PKG" as
/* $Header: pvxtgprb.pls 115.2 2003/11/18 22:51:17 ktsao noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_Ge_Ptnr_Resps_PKG
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


G_PKG_NAME CONSTANT VARCHAR2(30):= 'PV_Ge_Ptnr_Resps_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxtgprb.pls';




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
        px_ptnr_resp_id   IN OUT NOCOPY NUMBER,
        p_partner_id    NUMBER,
        p_user_role_code    VARCHAR2,
        p_program_id    NUMBER,
        p_responsibility_id    NUMBER,
        p_source_resp_map_rule_id    NUMBER,
        p_resp_type_code VARCHAR2,
        px_object_version_number   IN OUT NOCOPY NUMBER,
        p_created_by    NUMBER,
        p_creation_date    DATE,
        p_last_updated_by    NUMBER,
        p_last_update_date    DATE,
        p_last_update_login    NUMBER)

IS
 x_rowid    VARCHAR2(30);


BEGIN


 px_object_version_number := nvl(px_object_version_number, 1);


 INSERT INTO pv_ge_ptnr_resps(
         ptnr_resp_id,
         partner_id,
         user_role_code,
         program_id,
         responsibility_id,
         source_resp_map_rule_id,
         resp_type_code,
         object_version_number,
         created_by,
         creation_date,
         last_updated_by,
         last_update_date,
         last_update_login
 ) VALUES (
         DECODE( px_ptnr_resp_id, FND_API.G_MISS_NUM, NULL, px_ptnr_resp_id),
         DECODE( p_partner_id, FND_API.G_MISS_NUM, NULL, p_partner_id),
         DECODE( p_user_role_code, FND_API.g_miss_char, NULL, p_user_role_code),
         DECODE( p_program_id, FND_API.G_MISS_NUM, NULL, p_program_id),
         DECODE( p_responsibility_id, FND_API.G_MISS_NUM, NULL, p_responsibility_id),
         DECODE( p_source_resp_map_rule_id, FND_API.G_MISS_NUM, NULL, p_source_resp_map_rule_id),
         DECODE( p_resp_type_code, FND_API.g_miss_char, NULL, p_resp_type_code),
         DECODE( px_object_version_number, FND_API.G_MISS_NUM, 1, px_object_version_number),
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
        p_ptnr_resp_id    NUMBER,
        p_partner_id    NUMBER,
        p_user_role_code    VARCHAR2,
        p_program_id    NUMBER,
        p_responsibility_id    NUMBER,
        p_source_resp_map_rule_id    NUMBER,
        p_resp_type_code VARCHAR2,
        p_object_version_number   IN NUMBER,
        p_last_updated_by    NUMBER,
        p_last_update_date    DATE,
        p_last_update_login    NUMBER)

IS
BEGIN
  Update pv_ge_ptnr_resps
  SET
            ptnr_resp_id = DECODE( p_ptnr_resp_id, null, ptnr_resp_id, FND_API.G_MISS_NUM, null, p_ptnr_resp_id),
            partner_id = DECODE( p_partner_id, null, partner_id, FND_API.G_MISS_NUM, null, p_partner_id),
            user_role_code = DECODE( p_user_role_code, null, user_role_code, FND_API.g_miss_char, null, p_user_role_code),
            program_id = DECODE( p_program_id, null, program_id, FND_API.G_MISS_NUM, null, p_program_id),
            responsibility_id = DECODE( p_responsibility_id, null, responsibility_id, FND_API.G_MISS_NUM, null, p_responsibility_id),
            source_resp_map_rule_id = DECODE( p_source_resp_map_rule_id, null, source_resp_map_rule_id, FND_API.G_MISS_NUM, null, p_source_resp_map_rule_id),
            resp_type_code = DECODE( p_resp_type_code, null, resp_type_code, FND_API.g_miss_char, null, p_resp_type_code),
            object_version_number = nvl(p_object_version_number,0) + 1 ,
            last_updated_by = DECODE( p_last_updated_by, null, last_updated_by, FND_API.G_MISS_NUM, null, p_last_updated_by),
            last_update_date = DECODE( p_last_update_date, null, last_update_date, FND_API.G_MISS_DATE, null, p_last_update_date),
            last_update_login = DECODE( p_last_update_login, null, last_update_login, FND_API.G_MISS_NUM, null, p_last_update_login)
 WHERE ptnr_resp_id = p_ptnr_resp_id
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
  p_ptnr_resp_id  NUMBER,
  p_object_version_number  NUMBER)
IS
BEGIN
 DELETE FROM pv_ge_ptnr_resps
  WHERE ptnr_resp_id = p_ptnr_resp_id
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
  p_ptnr_resp_id  NUMBER,
  p_object_version_number  NUMBER)
IS
 CURSOR C IS
      SELECT *
       FROM pv_ge_ptnr_resps
      WHERE ptnr_resp_id =  p_ptnr_resp_id
      AND object_version_number = p_object_version_number
      FOR UPDATE OF ptnr_resp_id NOWAIT;
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



END PV_Ge_Ptnr_Resps_PKG;

/
