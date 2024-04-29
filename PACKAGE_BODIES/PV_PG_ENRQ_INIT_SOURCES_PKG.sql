--------------------------------------------------------
--  DDL for Package Body PV_PG_ENRQ_INIT_SOURCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_PG_ENRQ_INIT_SOURCES_PKG" as
/* $Header: pvxtpeib.pls 115.2 2002/12/10 20:36:23 jkylee ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_Pg_Enrq_Init_Sources_PKG
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


G_PKG_NAME CONSTANT VARCHAR2(30):= 'PV_Pg_Enrq_Init_Sources_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxtpeib.pls';




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
          px_initiation_source_id   IN OUT NOCOPY NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_enrl_request_id    NUMBER,
          p_prev_membership_id    NUMBER,
          p_enrl_change_rule_id    NUMBER,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER)

 IS
   x_rowid    VARCHAR2(30);


BEGIN


   px_object_version_number := nvl(px_object_version_number, 1);


   INSERT INTO pv_pg_enrq_init_sources(
           initiation_source_id,
           object_version_number,
           enrl_request_id,
           prev_membership_id,
           enrl_change_rule_id,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login
   ) VALUES (
           DECODE( px_initiation_source_id, FND_API.G_MISS_NUM, NULL, px_initiation_source_id),
           DECODE( px_object_version_number, FND_API.G_MISS_NUM, 1, px_object_version_number),
           DECODE( p_enrl_request_id, FND_API.G_MISS_NUM, NULL, p_enrl_request_id),
           DECODE( p_prev_membership_id, FND_API.G_MISS_NUM, NULL, p_prev_membership_id),
           DECODE( p_enrl_change_rule_id, FND_API.G_MISS_NUM, NULL, p_enrl_change_rule_id),
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
          p_initiation_source_id    NUMBER,
          p_object_version_number   IN NUMBER,
          p_enrl_request_id    NUMBER,
          p_prev_membership_id    NUMBER,
          p_enrl_change_rule_id    NUMBER,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER)

 IS
 BEGIN
    Update pv_pg_enrq_init_sources
    SET
              initiation_source_id = DECODE( p_initiation_source_id, null, initiation_source_id, FND_API.G_MISS_NUM, null, p_initiation_source_id),
            object_version_number = nvl(p_object_version_number,0) + 1 ,
              enrl_request_id = DECODE( p_enrl_request_id, null, enrl_request_id, FND_API.G_MISS_NUM, null, p_enrl_request_id),
              prev_membership_id = DECODE( p_prev_membership_id, null, prev_membership_id, FND_API.G_MISS_NUM, null, p_prev_membership_id),
              enrl_change_rule_id = DECODE( p_enrl_change_rule_id, null, enrl_change_rule_id, FND_API.G_MISS_NUM, null, p_enrl_change_rule_id),
              last_updated_by = DECODE( p_last_updated_by, null, last_updated_by, FND_API.G_MISS_NUM, null, p_last_updated_by),
              last_update_date = DECODE( p_last_update_date, null, last_update_date, FND_API.G_MISS_DATE, null, p_last_update_date),
              last_update_login = DECODE( p_last_update_login, null, last_update_login, FND_API.G_MISS_NUM, null, p_last_update_login)
   WHERE initiation_source_id = p_initiation_source_id
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
    p_initiation_source_id  NUMBER,
    p_object_version_number  NUMBER)
 IS
 BEGIN
   DELETE FROM pv_pg_enrq_init_sources
    WHERE initiation_source_id = p_initiation_source_id
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
    p_initiation_source_id  NUMBER,
    p_object_version_number  NUMBER)
 IS
   CURSOR C IS
        SELECT *
         FROM pv_pg_enrq_init_sources
        WHERE initiation_source_id =  p_initiation_source_id
        AND object_version_number = p_object_version_number
        FOR UPDATE OF initiation_source_id NOWAIT;
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



END PV_Pg_Enrq_Init_Sources_PKG;

/
