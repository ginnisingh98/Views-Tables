--------------------------------------------------------
--  DDL for Package Body PV_TAP_ACCESS_TERRS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_TAP_ACCESS_TERRS_PKG" as
/* $Header: pvxttrab.pls 115.0 2003/10/15 04:20:26 rdsharma noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_TAP_ACCESS_TERRS_PKG
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


G_PKG_NAME CONSTANT VARCHAR2(30):= 'PV_TAP_ACCESS_TERRS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxttrab.pls';




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
          p_partner_access_id     NUMBER,
          p_terr_id               NUMBER,
          p_last_update_date      DATE,
          p_last_updated_by       NUMBER,
          p_creation_date         DATE,
          p_created_by            NUMBER,
          p_last_update_login     NUMBER,
          p_object_version_number NUMBER,
          p_request_id            NUMBER,
          p_program_application_id NUMBER,
          p_program_id            NUMBER,
          p_program_update_date   DATE,
	  x_return_status         IN OUT NOCOPY VARCHAR2)
 IS
   x_rowid    VARCHAR2(30);
   l_object_version_number               NUMBER;
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Insert_Row';


BEGIN

   -- Standard Start of API savepoint
   SAVEPOINT Insert_PAccesses_Row;

   l_object_version_number := nvl(p_object_version_number, 1);

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   INSERT INTO pv_TAP_ACCESS_TERRS(
           partner_access_id,
           terr_id,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           object_version_number,
           request_id,
           program_application_id,
           program_id,
           program_update_date
   ) VALUES (
           DECODE( p_partner_access_id, FND_API.G_MISS_NUM, NULL, p_partner_access_id),
           DECODE( p_terr_id, FND_API.G_MISS_NUM, NULL, p_terr_id),
           DECODE( p_last_update_date, FND_API.G_MISS_DATE, SYSDATE,NULL, SYSDATE, p_last_update_date),
           DECODE( p_last_updated_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, NULL, FND_GLOBAL.USER_ID, p_last_updated_by),
           DECODE( p_creation_date, FND_API.G_MISS_DATE, SYSDATE,NULL, SYSDATE, p_creation_date),
           DECODE( p_created_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID,NULL, FND_GLOBAL.USER_ID, p_created_by),
           DECODE( p_last_update_login, FND_API.G_MISS_NUM, FND_GLOBAL.CONC_LOGIN_ID, NULL, FND_GLOBAL.CONC_LOGIN_ID, p_last_update_login),
           DECODE( p_object_version_number,FND_API.G_MISS_NUM, l_object_version_number, NULL, l_object_version_number, p_object_version_number),
           DECODE( p_request_id, FND_API.G_MISS_NUM, NULL, p_request_id),
           DECODE( p_program_application_id, FND_API.G_MISS_NUM, NULL, p_program_application_id),
           DECODE( p_program_id, FND_API.G_MISS_NUM, NULL, p_program_id),
           DECODE( p_program_update_date, FND_API.G_MISS_DATE, NULL, p_program_update_date));

 EXCEPTION
     WHEN OTHERS THEN
       ROLLBACK TO Insert_PAccesses_Row;
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
          p_partner_access_id      NUMBER,
          p_terr_id                NUMBER,
          p_last_update_date       DATE,
          p_last_updated_by        NUMBER,
          p_last_update_login      NUMBER,
          p_object_version_number  NUMBER,
          p_request_id             NUMBER,
          p_program_application_id NUMBER,
          p_program_id             NUMBER,
          p_program_update_date    DATE,
	  x_return_status          IN OUT NOCOPY VARCHAR2)
 IS
    L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Row';
 BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT Update_TAccesses_Row;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    Update PV_TAP_ACCESS_TERRS
    SET
              partner_access_id = DECODE( p_partner_access_id, null, partner_access_id, FND_API.G_MISS_NUM, null, p_partner_access_id),
              terr_id = DECODE( p_terr_id, null, terr_id, FND_API.G_MISS_NUM, null, p_terr_id),
              last_update_date = DECODE( p_last_update_date, null, last_update_date, FND_API.G_MISS_DATE, null, p_last_update_date),
              last_updated_by = DECODE( p_last_updated_by, null, last_updated_by, FND_API.G_MISS_NUM, null, p_last_updated_by),
              last_update_login = DECODE( p_last_update_login, null, last_update_login, FND_API.G_MISS_NUM, null, p_last_update_login),
	      object_version_number = nvl(p_object_version_number,0) + 1 ,
              request_id = DECODE( p_request_id, null, request_id, FND_API.G_MISS_NUM, null, p_request_id),
              program_application_id = DECODE( p_program_application_id, null, program_application_id, FND_API.G_MISS_NUM, null, p_program_application_id),
              program_id = DECODE( p_program_id, null, program_id, FND_API.G_MISS_NUM, null, p_program_id),
              program_update_date = DECODE( p_program_update_date, null, program_update_date, FND_API.G_MISS_DATE, null, p_program_update_date)
   WHERE partner_access_id = p_partner_access_id
   AND terr_id = p_terr_id
   AND   object_version_number = p_object_version_number;


   IF (SQL%NOTFOUND) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

  EXCEPTION

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO Update_TAccesses_Row;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;

    WHEN OTHERS THEN
       ROLLBACK TO Update_TAccesses_Row;
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
    p_partner_access_id     NUMBER,
    p_terr_id               NUMBER,
    p_object_version_number NUMBER,
    x_return_status         IN OUT NOCOPY   VARCHAR2)
 IS
    L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Row';
 BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT Delete_TAccesses_Row;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

   DELETE FROM PV_TAP_ACCESS_TERRS
    WHERE partner_access_id = p_partner_access_id
    AND terr_id = p_terr_id
    AND object_version_number = p_object_version_number;
   If (SQL%NOTFOUND) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   End If;

 EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO Delete_TAccesses_Row;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
   WHEN OTHERS THEN
       ROLLBACK TO Delete_TAccesses_Row;
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
    p_partner_access_id NUMBER,
    p_terr_id NUMBER,
    p_object_version_number  NUMBER,
    x_return_status         IN OUT NOCOPY   VARCHAR2)
 IS
   CURSOR C IS
        SELECT *
         FROM PV_TAP_ACCESS_TERRS
        WHERE partner_access_id =  p_partner_access_id
        AND terr_id = p_terr_id
        AND object_version_number = p_object_version_number
        FOR UPDATE OF partner_access_id,terr_id NOWAIT;
   Recinfo C%ROWTYPE;

   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Row';

 BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT Lock_TAccesses_Row;

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
       ROLLBACK TO Lock_TAccesses_Row;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
   WHEN OTHERS THEN
       ROLLBACK TO Lock_TAccesses_Row;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;

END Lock_Row;

END PV_TAP_ACCESS_TERRS_PKG;

/
