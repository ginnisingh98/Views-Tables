--------------------------------------------------------
--  DDL for Package Body PV_PG_MMBR_TRANSITIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_PG_MMBR_TRANSITIONS_PKG" as
/* $Header: pvxtmbtb.pls 115.1 2002/12/10 20:59:05 pukken ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          pv_pg_mmbr_transitions_PKG
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


G_PKG_NAME CONSTANT VARCHAR2(30):= 'pv_pg_mmbr_transitions_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxtmbtb.pls';




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
          px_mmbr_transition_id   IN OUT NOCOPY NUMBER,
          p_from_membership_id    NUMBER,
          p_to_membership_id    NUMBER,
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


   INSERT INTO pv_pg_mmbr_transitions(
           mmbr_transition_id,
           from_membership_id,
           to_membership_id,
           object_version_number,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login
   ) VALUES (
           DECODE( px_mmbr_transition_id, FND_API.G_MISS_NUM, NULL, px_mmbr_transition_id),
           DECODE( p_from_membership_id, FND_API.G_MISS_NUM, NULL, p_from_membership_id),
           DECODE( p_to_membership_id, FND_API.G_MISS_NUM, NULL, p_to_membership_id),
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
          p_mmbr_transition_id    NUMBER,
          p_from_membership_id    NUMBER,
          p_to_membership_id    NUMBER,
          p_object_version_number   IN NUMBER,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER)

 IS
 BEGIN
    Update pv_pg_mmbr_transitions
    SET
              mmbr_transition_id = DECODE( p_mmbr_transition_id, null, mmbr_transition_id, FND_API.G_MISS_NUM, null, p_mmbr_transition_id),
              from_membership_id = DECODE( p_from_membership_id, null, from_membership_id, FND_API.G_MISS_NUM, null, p_from_membership_id),
              to_membership_id = DECODE( p_to_membership_id, null, to_membership_id, FND_API.G_MISS_NUM, null, p_to_membership_id),
            object_version_number = nvl(p_object_version_number,0) + 1 ,
              last_updated_by = DECODE( p_last_updated_by, null, last_updated_by, FND_API.G_MISS_NUM, null, p_last_updated_by),
              last_update_date = DECODE( p_last_update_date, null, last_update_date, FND_API.G_MISS_DATE, null, p_last_update_date),
              last_update_login = DECODE( p_last_update_login, null, last_update_login, FND_API.G_MISS_NUM, null, p_last_update_login)
   WHERE mmbr_transition_id = p_mmbr_transition_id
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
    p_mmbr_transition_id  NUMBER,
    p_object_version_number  NUMBER)
 IS
 BEGIN
   DELETE FROM pv_pg_mmbr_transitions
    WHERE mmbr_transition_id = p_mmbr_transition_id
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
    p_mmbr_transition_id  NUMBER,
    p_object_version_number  NUMBER)
 IS
   CURSOR C IS
        SELECT *
         FROM pv_pg_mmbr_transitions
        WHERE mmbr_transition_id =  p_mmbr_transition_id
        AND object_version_number = p_object_version_number
        FOR UPDATE OF mmbr_transition_id NOWAIT;
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



END pv_pg_mmbr_transitions_PKG;

/
