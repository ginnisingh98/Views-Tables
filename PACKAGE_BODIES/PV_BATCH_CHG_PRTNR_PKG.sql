--------------------------------------------------------
--  DDL for Package Body PV_BATCH_CHG_PRTNR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_BATCH_CHG_PRTNR_PKG" as
/* $Header: pvxtchpb.pls 115.0 2003/10/15 04:01:26 rdsharma noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_TAP_BATCH_CHG_PARTNERS_PKG
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


G_PKG_NAME CONSTANT VARCHAR2(30):= 'PV_TAP_BATCH_CHG_PARTNERS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxtchpb.pls';

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
          px_partner_id   IN OUT NOCOPY NUMBER,
          p_last_update_date    DATE,
          p_last_update_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_request_id    NUMBER,
          p_program_application_id    NUMBER,
          p_program_id    NUMBER,
          p_program_update_date    DATE,
          p_processed_flag    VARCHAR2,
	  p_vad_partner_id   NUMBER,
	  x_return_status  IN OUT NOCOPY VARCHAR2)

 IS
   x_rowid    VARCHAR2(30);
   l_object_version_number NUMBER;
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Insert_Row';

BEGIN

   -- Standard Start of API savepoint
   SAVEPOINT Insert_Chng_Partner_Row;

   l_object_version_number := nvl(p_object_version_number, 1);

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;


   INSERT INTO PV_TAP_BATCH_CHG_PARTNERS(
           partner_id,
           last_update_date,
           last_update_by,
           creation_date,
           created_by,
           last_update_login,
	   object_version_number,
           request_id,
           program_application_id,
           program_id,
           program_update_date,
           processed_flag,
	   vad_partner_id
   ) VALUES (
           DECODE( px_partner_id, FND_API.G_MISS_NUM, NULL,NULL,NULL, px_partner_id),
           DECODE( p_last_update_date, FND_API.G_MISS_DATE, SYSDATE,NULL, SYSDATE, p_last_update_date),
           DECODE( p_last_update_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, NULL, FND_GLOBAL.USER_ID, p_last_update_by),
           DECODE( p_creation_date, FND_API.G_MISS_DATE, SYSDATE,NULL, SYSDATE, p_creation_date),
           DECODE( p_created_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID,NULL, FND_GLOBAL.USER_ID, p_created_by),
           DECODE( p_last_update_login, FND_API.G_MISS_NUM, FND_GLOBAL.CONC_LOGIN_ID, NULL, FND_GLOBAL.CONC_LOGIN_ID, p_last_update_login),
	   DECODE( p_object_version_number,FND_API.G_MISS_NUM, l_object_version_number, NULL, l_object_version_number, p_object_version_number),
           DECODE( p_request_id, FND_API.G_MISS_NUM, NULL, p_request_id),
           DECODE( p_program_application_id, FND_API.G_MISS_NUM, NULL, p_program_application_id),
           DECODE( p_program_id, FND_API.G_MISS_NUM, NULL, p_program_id),
           DECODE( p_program_update_date, FND_API.G_MISS_DATE, NULL, p_program_update_date),
           DECODE( p_processed_flag, FND_API.g_miss_char, 'P', p_processed_flag),
	   DECODE( p_vad_partner_id, FND_API.g_miss_num, null, NULL, NULL, p_vad_partner_id));

EXCEPTION
    WHEN OTHERS THEN
       ROLLBACK TO Insert_Chng_Partner_Row;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;

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
          p_partner_id    NUMBER,
          p_last_update_date    DATE,
          p_last_update_by    NUMBER,
          p_last_update_login    NUMBER,
	  p_object_version_number NUMBER,
          p_request_id    NUMBER,
          p_program_application_id    NUMBER,
          p_program_id    NUMBER,
          p_program_update_date    DATE,
          p_processed_flag    VARCHAR2,
	  p_vad_partner_id    NUMBER,
	  x_return_status  IN OUT NOCOPY VARCHAR2)

 IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Row';
 BEGIN

     -- Standard Start of API savepoint
    SAVEPOINT Update_Chng_Partner_Row;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    Update PV_TAP_BATCH_CHG_PARTNERS
    SET
              partner_id = DECODE( p_partner_id, null, partner_id, FND_API.G_MISS_NUM, null, p_partner_id),
              last_update_date = DECODE( p_last_update_date, null, last_update_date, FND_API.G_MISS_DATE, null, p_last_update_date),
              last_update_by = DECODE( p_last_update_by, null, last_update_by, FND_API.G_MISS_NUM, null, p_last_update_by),
              last_update_login = DECODE( p_last_update_login, null, last_update_login, FND_API.G_MISS_NUM, null, p_last_update_login),
	      object_version_number = nvl(p_object_version_number,0) + 1 ,
              request_id = DECODE( p_request_id, null, request_id, FND_API.G_MISS_NUM, null, p_request_id),
              program_application_id = DECODE( p_program_application_id, null, program_application_id, FND_API.G_MISS_NUM, null, p_program_application_id),
              program_id = DECODE( p_program_id, null, program_id, FND_API.G_MISS_NUM, null, p_program_id),
              program_update_date = DECODE( p_program_update_date, null, program_update_date, FND_API.G_MISS_DATE, null, p_program_update_date),
              processed_flag = DECODE( p_processed_flag, null, processed_flag, FND_API.g_miss_char, null, p_processed_flag),
	      vad_partner_id = DECODE( p_vad_partner_id,null,null,FND_API.g_miss_num, NULL, p_vad_partner_id)
   WHERE partner_id = p_partner_id
   AND   object_version_number = p_object_version_number;


   IF (SQL%NOTFOUND) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

  EXCEPTION

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO Update_Chng_Partner_Row;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;

    WHEN OTHERS THEN
       ROLLBACK TO Update_Chng_Partner_Row;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
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
    p_partner_id  NUMBER,
    p_object_version_number  NUMBER,
    x_return_status  IN OUT NOCOPY VARCHAR2)
 IS
    L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Row';
 BEGIN
     -- Standard Start of API savepoint
    SAVEPOINT Delete_Chng_Partner_Row;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

   DELETE FROM PV_TAP_BATCH_CHG_PARTNERS
    WHERE partner_id = p_partner_id
    AND object_version_number = p_object_version_number;
    If (SQL%NOTFOUND) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   End If;

 EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO Delete_Chng_Partner_Row;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;

   WHEN OTHERS THEN
       ROLLBACK TO Delete_Chng_Partner_Row;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;

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
    p_partner_id  NUMBER,
    p_object_version_number  NUMBER,
    x_return_status  IN OUT NOCOPY VARCHAR2)
 IS
   CURSOR C IS
        SELECT *
         FROM PV_TAP_BATCH_CHG_PARTNERS
        WHERE partner_id =  p_partner_id
        AND object_version_number = p_object_version_number
        FOR UPDATE OF partner_id NOWAIT;
   Recinfo C%ROWTYPE;

   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Row';

 BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT Lock_Chng_Partner_Row;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

   OPEN c;
   FETCH c INTO Recinfo;
   IF (c%NOTFOUND) THEN
      CLOSE c;
      PVX_Utility_PVT.error_message ('PV_API_RECORD_NOT_FOUND');
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   CLOSE c;
 EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO Lock_Chng_Partner_Row;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
   WHEN OTHERS THEN
       ROLLBACK TO Lock_Chng_Partner_Row;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;

END Lock_Row;



END PV_BATCH_CHG_PRTNR_PKG;

/
