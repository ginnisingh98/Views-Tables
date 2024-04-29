--------------------------------------------------------
--  DDL for Package Body PV_PRGM_BENEFITS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_PRGM_BENEFITS_PKG" as
/* $Header: pvxtppbb.pls 115.9 2003/11/07 06:13:54 ktsao ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_PROGRAM_BENEFITS_PKG
-- Purpose
--
-- History
--         28-FEB-2002    Jessica.Lee         Created
--          1-APR-2002    Peter.Nixon         Modified
--                        Changed benefit_id NUMBER to benefit_code VARCHAR2
--         24-SEP-2003    Karen.Tsao          Modified for 11.5.10
--         02-OCT-2003    Karen.Tsao          Modified for new column responsibility_id
--         06-NOV-2003    Karen.Tsao          Took out column responsibility_id
-- NOTE
--
-- End of Comments
-- ===============================================================

G_PKG_NAME CONSTANT VARCHAR2(30):= 'PV_PROGRAM_BENEFITS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxtpbbb.pls';


--  ========================================================
--
--  NAME
--  createInsertBody
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
           px_program_benefits_id       IN OUT NOCOPY  NUMBER
          ,p_program_id                         NUMBER
          ,p_benefit_code                       VARCHAR2
          ,p_benefit_id                         NUMBER
          ,p_benefit_type_code                  VARCHAR2
          ,p_delete_flag                        VARCHAR2
          ,p_last_update_login                  NUMBER
          ,p_last_update_date                   DATE
          ,p_last_updated_by                    NUMBER
          ,p_created_by                         NUMBER
          ,p_creation_date                      DATE
          ,p_object_version_number              NUMBER
          )

 IS

BEGIN

   INSERT INTO PV_PROGRAM_BENEFITS(
            program_benefits_id
           ,program_id
           ,benefit_code
           ,benefit_id
           ,benefit_type_code
           ,delete_flag
           ,last_update_login
           ,last_update_date
           ,last_updated_by
           ,created_by
           ,creation_date
           ,object_version_number
   ) VALUES (
       --     DECODE( px_program_benefits_id, FND_API.g_miss_num, NULL, px_program_benefits_id)
       --    ,DECODE( p_program_id, FND_API.g_miss_num, NULL, p_program_id)
       --    ,DECODE( p_benefit_code, FND_API.g_miss_char, NULL, p_benefit_code)
       --    ,DECODE( p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login)
       --    ,DECODE( p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date)
       --    ,DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by)
       --    ,DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by)
       --    ,DECODE( p_creation_date, FND_API.g_miss_date, NULL, p_creation_date)
       --    ,DECODE( p_object_version_number, FND_API.g_miss_num, NULL, p_object_version_number)

            DECODE( px_program_benefits_id, NULL,px_program_benefits_id, FND_API.g_miss_num, NULL, px_program_benefits_id)
           ,DECODE( p_program_id, NULL,p_program_id, FND_API.g_miss_num, NULL, p_program_id)
           ,DECODE( p_benefit_code, NULL,p_benefit_code, FND_API.g_miss_char, NULL, p_benefit_code)
           ,DECODE( p_benefit_id, NULL,p_benefit_id, FND_API.g_miss_num, NULL, p_benefit_id)
           ,DECODE( p_benefit_type_code, NULL,p_benefit_type_code, FND_API.g_miss_char, NULL, p_benefit_type_code)
           ,DECODE( p_delete_flag, NULL,p_delete_flag, FND_API.g_miss_char, NULL, p_delete_flag)
           ,DECODE( p_last_update_login, NULL, p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login)
           ,DECODE( p_last_update_date, NULL, p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date)
           ,DECODE( p_last_updated_by, NULL, p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by)
           ,DECODE( p_created_by, NULL, p_created_by, FND_API.g_miss_num, NULL, p_created_by)
           ,DECODE( p_creation_date, NULL, p_creation_date, FND_API.g_miss_date, NULL, p_creation_date)
           ,DECODE( p_object_version_number, NULL, p_object_version_number, FND_API.g_miss_num, NULL, p_object_version_number)

          );
END Insert_Row;


--  ========================================================
--
--  NAME
--  createUpdateBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Update_Row(
           p_program_benefits_id                NUMBER
          ,p_program_id                         NUMBER
          ,p_benefit_code                       VARCHAR2
          ,p_benefit_id                         NUMBER
          ,p_benefit_type_code                  VARCHAR2
          ,p_delete_flag                        VARCHAR2
          ,p_last_update_login                  NUMBER
          ,p_object_version_number              NUMBER
          ,p_last_update_date                   DATE
          ,p_last_updated_by                    NUMBER
          )

 IS
 BEGIN
    Update PV_PROGRAM_BENEFITS
    SET
          --     program_benefits_id   = DECODE( p_program_benefits_id, FND_API.g_miss_num, program_benefits_id, p_program_benefits_id)
          --    ,program_id            = DECODE( p_program_id, FND_API.g_miss_num, program_id, p_program_id)
          --    ,benefit_code          = DECODE( p_benefit_code, FND_API.g_miss_char, benefit_code, p_benefit_code)
          --    ,last_update_login     = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login)
          --    ,object_version_number = DECODE( p_object_version_number, FND_API.g_miss_num, object_version_number, p_object_version_number+1)
          --    ,last_update_date      = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date)
          --    ,last_updated_by       = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by)
               program_benefits_id   = DECODE( p_program_benefits_id, NULL, program_benefits_id, FND_API.g_miss_num, NULL, p_program_benefits_id)
              ,program_id            = DECODE( p_program_id, NULL, program_id, FND_API.g_miss_num, NULL, p_program_id)
              ,benefit_code          = DECODE( p_benefit_code, NULL, benefit_code, FND_API.g_miss_char, NULL, p_benefit_code)
              ,benefit_id            = DECODE( p_benefit_id, NULL, benefit_id, FND_API.g_miss_num, NULL, p_benefit_id)
              ,benefit_type_code     = DECODE( p_benefit_type_code, NULL, benefit_type_code, FND_API.g_miss_char, NULL, p_benefit_type_code)
              ,delete_flag           = DECODE( p_delete_flag, NULL, delete_flag, FND_API.g_miss_char, NULL, p_delete_flag)
              ,last_update_login     = DECODE( p_last_update_login, NULL, last_update_login, FND_API.g_miss_num, NULL, p_last_update_login)
              ,object_version_number = DECODE( p_object_version_number, NULL, object_version_number, FND_API.g_miss_num, NULL, p_object_version_number+1)
              ,last_update_date      = DECODE( p_last_update_date, NULL, last_update_date, FND_API.g_miss_date, NULL, p_last_update_date)
              ,last_updated_by       = DECODE( p_last_updated_by, NULL, last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by)

   WHERE PROGRAM_BENEFITS_ID = p_program_benefits_id
   AND object_version_number = p_object_version_number;

   IF (SQL%NOTFOUND) THEN
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('PV', 'PV_RECORD_NOT_FOUND');
       FND_MSG_PUB.add;
     END IF;
   RAISE FND_API.g_exc_error;
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
     p_program_benefits_id    NUMBER
    ,p_object_version_number  NUMBER
    )
 IS
 BEGIN
   UPDATE PV_PROGRAM_BENEFITS
   SET
      --program_benefits_id       = DECODE( p_program_benefits_id, NULL ,program_benefits_id, FND_API.g_miss_num,  NULL , p_program_benefits_id)
      delete_flag               ='Y'
     ,last_update_date          = SYSDATE
     ,last_updated_by           = FND_GLOBAL.user_id
     ,last_update_login         = FND_GLOBAL.conc_login_id
     ,object_version_number     = DECODE( p_object_version_number, NULL ,object_version_number, FND_API.g_miss_num,  NULL , p_object_version_number+1)

   WHERE program_benefits_id = p_program_benefits_id
   AND object_version_number = p_object_version_number;

   IF (SQL%NOTFOUND) THEN
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('PV', 'PV_RECORD_NOT_FOUND');
       FND_MSG_PUB.add;
     END IF;
     RAISE FND_API.g_exc_error;
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
           px_program_benefits_id       IN OUT NOCOPY  NUMBER
          ,p_program_id                         NUMBER
          ,p_benefit_code                       VARCHAR2
          ,p_benefit_id                         NUMBER
          ,p_benefit_type_code                  VARCHAR2
          ,p_delete_flag                        VARCHAR2
          ,p_last_update_login                  NUMBER
          ,px_object_version_number     IN OUT NOCOPY  NUMBER
          ,p_last_update_date                   DATE
          ,p_last_updated_by                    NUMBER
          ,p_created_by                         NUMBER
          ,p_creation_date                      DATE
          )

 IS
   CURSOR C IS
        SELECT *
         FROM PV_PROGRAM_BENEFITS
        WHERE PROGRAM_BENEFITS_ID =  px_program_benefits_id
        FOR UPDATE of PROGRAM_BENEFITS_ID NOWAIT;
   Recinfo C%ROWTYPE;

 BEGIN
    OPEN c;
    FETCH c INTO Recinfo;
    If (c%NOTFOUND) then
        CLOSE c;
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
    CLOSE C;
    IF (
           (      Recinfo.program_benefits_id = px_program_benefits_id)
       AND (    ( Recinfo.program_id = p_program_id)
            OR (    ( Recinfo.program_id IS NULL )
                AND (  p_program_id IS NULL )))
       AND (    ( Recinfo.benefit_code = p_benefit_code)
            OR (    ( Recinfo.benefit_code IS NULL )
                AND (  p_benefit_code IS NULL )))
       AND (    ( Recinfo.benefit_id = p_benefit_id)
            OR (    ( Recinfo.benefit_id IS NULL )
                AND (  p_benefit_id IS NULL )))
       AND (    ( Recinfo.benefit_type_code = p_benefit_type_code)
            OR (    ( Recinfo.benefit_type_code IS NULL )
                AND (  p_benefit_type_code IS NULL )))
       AND (    ( Recinfo.delete_flag = p_delete_flag)
            OR (    ( Recinfo.delete_flag IS NULL )
                AND (  p_delete_flag IS NULL )))
       AND (    ( Recinfo.last_update_login = p_last_update_login)
            OR (    ( Recinfo.last_update_login IS NULL )
                AND (  p_last_update_login IS NULL )))
       AND (    ( Recinfo.object_version_number = px_object_version_number)
            OR (    ( Recinfo.object_version_number IS NULL )
                AND (  px_object_version_number IS NULL )))
       AND (    ( Recinfo.last_update_date = p_last_update_date)
            OR (    ( Recinfo.last_update_date IS NULL )
                AND (  p_last_update_date IS NULL )))
       AND (    ( Recinfo.last_updated_by = p_last_updated_by)
            OR (    ( Recinfo.last_updated_by IS NULL )
                AND (  p_last_updated_by IS NULL )))
       AND (    ( Recinfo.created_by = p_created_by)
            OR (    ( Recinfo.created_by IS NULL )
                AND (  p_created_by IS NULL )))
       AND (    ( Recinfo.creation_date = p_creation_date)
            OR (    ( Recinfo.creation_date IS NULL )
                AND (  p_creation_date IS NULL )))
       ) THEN
       RETURN;
   ELSE
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
END Lock_Row;

END PV_PRGM_BENEFITS_PKG;

/
