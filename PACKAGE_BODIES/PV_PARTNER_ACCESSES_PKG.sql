--------------------------------------------------------
--  DDL for Package Body PV_PARTNER_ACCESSES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_PARTNER_ACCESSES_PKG" as
/* $Header: pvxtprab.pls 115.0 2003/10/15 04:13:17 rdsharma noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_Partner_Accesses_PKG
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


G_PKG_NAME CONSTANT VARCHAR2(30):= 'PV_Partner_Accesses_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxtprab.pls';

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
          px_partner_access_id   IN OUT NOCOPY NUMBER,
          p_partner_id    NUMBER,
          p_resource_id    NUMBER,
          p_keep_flag    VARCHAR2,
          p_created_by_tap_flag    VARCHAR2,
          p_access_type    VARCHAR2,
          p_vad_partner_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_request_id    NUMBER,
          p_program_application_id    NUMBER,
          p_program_id    NUMBER,
          p_program_update_date    DATE,
          p_attribute_category    VARCHAR2,
          p_attribute1    VARCHAR2,
          p_attribute2    VARCHAR2,
          p_attribute3    VARCHAR2,
          p_attribute4    VARCHAR2,
          p_attribute5    VARCHAR2,
          p_attribute6    VARCHAR2,
          p_attribute7    VARCHAR2,
          p_attribute8    VARCHAR2,
          p_attribute9    VARCHAR2,
          p_attribute10    VARCHAR2,
          p_attribute11    VARCHAR2,
          p_attribute12    VARCHAR2,
          p_attribute13    VARCHAR2,
          p_attribute14    VARCHAR2,
          p_attribute15    VARCHAR2,
	  x_return_status  IN OUT NOCOPY VARCHAR2
)

 IS
   x_rowid    VARCHAR2(30);
   l_object_version_number NUMBER;
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Insert_Row';

BEGIN

   -- Standard Start of API savepoint
   SAVEPOINT Insert_PAccesses_Row ;

   l_object_version_number := nvl(p_object_version_number, 1);

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   INSERT INTO pv_partner_accesses(
           partner_access_id,
           partner_id,
           resource_id,
           keep_flag,
           created_by_tap_flag,
           access_type,
           vad_partner_id,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
	   object_version_number,
           request_id,
           program_application_id,
           program_id,
           program_update_date,
           attribute_category,
           attribute1,
           attribute2,
           attribute3,
           attribute4,
           attribute5,
           attribute6,
           attribute7,
           attribute8,
           attribute9,
           attribute10,
           attribute11,
           attribute12,
           attribute13,
           attribute14,
           attribute15
   ) VALUES (
           DECODE( px_partner_access_id, FND_API.G_MISS_NUM, NULL, px_partner_access_id),
           DECODE( p_partner_id, FND_API.G_MISS_NUM, NULL, p_partner_id),
           DECODE( p_resource_id, FND_API.G_MISS_NUM, NULL, p_resource_id),
           DECODE( p_keep_flag, FND_API.g_miss_char, NULL, p_keep_flag),
           DECODE( p_created_by_tap_flag, FND_API.g_miss_char, NULL, p_created_by_tap_flag),
           DECODE( p_access_type, FND_API.g_miss_char, NULL, p_access_type),
           DECODE( p_vad_partner_id, FND_API.G_MISS_NUM, NULL, p_vad_partner_id),
	   DECODE( p_last_update_date, FND_API.G_MISS_DATE, SYSDATE,NULL, SYSDATE, p_last_update_date),
           DECODE( p_last_updated_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, NULL, FND_GLOBAL.USER_ID, p_last_updated_by),
           DECODE( p_creation_date, FND_API.G_MISS_DATE, SYSDATE,NULL, SYSDATE, p_creation_date),
           DECODE( p_created_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID,NULL, FND_GLOBAL.USER_ID, p_created_by),
           DECODE( p_last_update_login, FND_API.G_MISS_NUM, FND_GLOBAL.CONC_LOGIN_ID, NULL, FND_GLOBAL.CONC_LOGIN_ID, p_last_update_login),
           DECODE( p_object_version_number,FND_API.G_MISS_NUM, l_object_version_number, NULL, l_object_version_number, p_object_version_number),
           DECODE( p_request_id, FND_API.G_MISS_NUM, NULL, p_request_id),
           DECODE( p_program_application_id, FND_API.G_MISS_NUM, NULL, p_program_application_id),
           DECODE( p_program_id, FND_API.G_MISS_NUM, NULL, p_program_id),
           DECODE( p_program_update_date, FND_API.G_MISS_DATE, NULL, p_program_update_date),
           DECODE( p_attribute_category, FND_API.g_miss_char, NULL, p_attribute_category),
           DECODE( p_attribute1, FND_API.g_miss_char, NULL, p_attribute1),
           DECODE( p_attribute2, FND_API.g_miss_char, NULL, p_attribute2),
           DECODE( p_attribute3, FND_API.g_miss_char, NULL, p_attribute3),
           DECODE( p_attribute4, FND_API.g_miss_char, NULL, p_attribute4),
           DECODE( p_attribute5, FND_API.g_miss_char, NULL, p_attribute5),
           DECODE( p_attribute6, FND_API.g_miss_char, NULL, p_attribute6),
           DECODE( p_attribute7, FND_API.g_miss_char, NULL, p_attribute7),
           DECODE( p_attribute8, FND_API.g_miss_char, NULL, p_attribute8),
           DECODE( p_attribute9, FND_API.g_miss_char, NULL, p_attribute9),
           DECODE( p_attribute10, FND_API.g_miss_char, NULL, p_attribute10),
           DECODE( p_attribute11, FND_API.g_miss_char, NULL, p_attribute11),
           DECODE( p_attribute12, FND_API.g_miss_char, NULL, p_attribute12),
           DECODE( p_attribute13, FND_API.g_miss_char, NULL, p_attribute13),
           DECODE( p_attribute14, FND_API.g_miss_char, NULL, p_attribute14),
           DECODE( p_attribute15, FND_API.g_miss_char, NULL, p_attribute15));

  EXCEPTION
     WHEN OTHERS THEN
       ROLLBACK TO Insert_PAccesses_Row ;
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
          p_partner_access_id    NUMBER,
          p_partner_id    NUMBER,
          p_resource_id    NUMBER,
          p_keep_flag    VARCHAR2,
          p_created_by_tap_flag    VARCHAR2,
          p_access_type    VARCHAR2,
          p_vad_partner_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_request_id    NUMBER,
          p_program_application_id    NUMBER,
          p_program_id    NUMBER,
          p_program_update_date    DATE,
          p_attribute_category    VARCHAR2,
          p_attribute1    VARCHAR2,
          p_attribute2    VARCHAR2,
          p_attribute3    VARCHAR2,
          p_attribute4    VARCHAR2,
          p_attribute5    VARCHAR2,
          p_attribute6    VARCHAR2,
          p_attribute7    VARCHAR2,
          p_attribute8    VARCHAR2,
          p_attribute9    VARCHAR2,
          p_attribute10    VARCHAR2,
          p_attribute11    VARCHAR2,
          p_attribute12    VARCHAR2,
          p_attribute13    VARCHAR2,
          p_attribute14    VARCHAR2,
          p_attribute15    VARCHAR2,
	  x_return_status  IN OUT NOCOPY VARCHAR2)

 IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Row';
 BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT Update_PAccesses_Row ;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    Update pv_partner_accesses
    SET
              partner_access_id = DECODE( p_partner_access_id, null, partner_access_id, FND_API.G_MISS_NUM, null, p_partner_access_id),
              partner_id = DECODE( p_partner_id, null, partner_id, FND_API.G_MISS_NUM, null, p_partner_id),
              resource_id = DECODE( p_resource_id, null, resource_id, FND_API.G_MISS_NUM, null, p_resource_id),
              keep_flag = DECODE( p_keep_flag, null, keep_flag, FND_API.g_miss_char, null, p_keep_flag),
              created_by_tap_flag = DECODE( p_created_by_tap_flag, null, created_by_tap_flag, FND_API.g_miss_char, null, p_created_by_tap_flag),
              access_type = DECODE( p_access_type, null, access_type, FND_API.g_miss_char, null, p_access_type),
              vad_partner_id = DECODE( p_vad_partner_id, null, vad_partner_id, FND_API.G_MISS_NUM, null, p_vad_partner_id),
              last_update_date = DECODE( p_last_update_date, null, last_update_date, FND_API.G_MISS_DATE, null, p_last_update_date),
              last_updated_by = DECODE( p_last_updated_by, null, last_updated_by, FND_API.G_MISS_NUM, null, p_last_updated_by),
              last_update_login = DECODE( p_last_update_login, null, last_update_login, FND_API.G_MISS_NUM, null, p_last_update_login),
	      object_version_number = nvl(p_object_version_number,0) + 1 ,
              request_id = DECODE( p_request_id, null, request_id, FND_API.G_MISS_NUM, null, p_request_id),
              program_application_id = DECODE( p_program_application_id, null, program_application_id, FND_API.G_MISS_NUM, null, p_program_application_id),
              program_id = DECODE( p_program_id, null, program_id, FND_API.G_MISS_NUM, null, p_program_id),
              program_update_date = DECODE( p_program_update_date, null, program_update_date, FND_API.G_MISS_DATE, null, p_program_update_date),
              attribute_category = DECODE( p_attribute_category, null, attribute_category, FND_API.g_miss_char, null, p_attribute_category),
              attribute1 = DECODE( p_attribute1, null, attribute1, FND_API.g_miss_char, null, p_attribute1),
              attribute2 = DECODE( p_attribute2, null, attribute2, FND_API.g_miss_char, null, p_attribute2),
              attribute3 = DECODE( p_attribute3, null, attribute3, FND_API.g_miss_char, null, p_attribute3),
              attribute4 = DECODE( p_attribute4, null, attribute4, FND_API.g_miss_char, null, p_attribute4),
              attribute5 = DECODE( p_attribute5, null, attribute5, FND_API.g_miss_char, null, p_attribute5),
              attribute6 = DECODE( p_attribute6, null, attribute6, FND_API.g_miss_char, null, p_attribute6),
              attribute7 = DECODE( p_attribute7, null, attribute7, FND_API.g_miss_char, null, p_attribute7),
              attribute8 = DECODE( p_attribute8, null, attribute8, FND_API.g_miss_char, null, p_attribute8),
              attribute9 = DECODE( p_attribute9, null, attribute9, FND_API.g_miss_char, null, p_attribute9),
              attribute10 = DECODE( p_attribute10, null, attribute10, FND_API.g_miss_char, null, p_attribute10),
              attribute11 = DECODE( p_attribute11, null, attribute11, FND_API.g_miss_char, null, p_attribute11),
              attribute12 = DECODE( p_attribute12, null, attribute12, FND_API.g_miss_char, null, p_attribute12),
              attribute13 = DECODE( p_attribute13, null, attribute13, FND_API.g_miss_char, null, p_attribute13),
              attribute14 = DECODE( p_attribute14, null, attribute14, FND_API.g_miss_char, null, p_attribute14),
              attribute15 = DECODE( p_attribute15, null, attribute15, FND_API.g_miss_char, null, p_attribute15)
   WHERE partner_access_id = p_partner_access_id
   AND   object_version_number = p_object_version_number;


   IF (SQL%NOTFOUND) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

  EXCEPTION

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO Update_PAccesses_Row ;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;

    WHEN OTHERS THEN
       ROLLBACK TO Update_PAccesses_Row ;
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
    p_partner_access_id  NUMBER,
    p_object_version_number  NUMBER,
    x_return_status   IN OUT NOCOPY   VARCHAR2)
 IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Row';
 BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT Delete_PAccesses_Row;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

   DELETE FROM pv_partner_accesses
    WHERE partner_access_id = p_partner_access_id
    AND object_version_number = p_object_version_number;
   If (SQL%NOTFOUND) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   End If;

 EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO Delete_PAccesses_Row;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;

   WHEN OTHERS THEN
       ROLLBACK TO Delete_PAccesses_Row;
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
    p_partner_access_id  NUMBER,
    p_object_version_number  NUMBER,
    x_return_status   IN OUT NOCOPY   VARCHAR2)
 IS
   CURSOR C IS
        SELECT *
         FROM pv_partner_accesses
        WHERE partner_access_id =  p_partner_access_id
        AND object_version_number = p_object_version_number
        FOR UPDATE OF partner_access_id NOWAIT;
   Recinfo C%ROWTYPE;

   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Row';
 BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT Lock_PAccesses_Row;

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
       ROLLBACK TO Lock_PAccesses_Row;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
   WHEN OTHERS THEN
       ROLLBACK TO Lock_PAccesses_Row;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
END Lock_Row;

END PV_Partner_Accesses_PKG;

/
