--------------------------------------------------------
--  DDL for Package Body PV_PRGM_CONTRACTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_PRGM_CONTRACTS_PKG" as
/* $Header: pvxtppcb.pls 120.0 2005/05/27 15:35:21 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_PRGM_CONTRACTS_PKG
-- Purpose
--
-- History
--         7-MAR-2002    Peter.Nixon     Created
--        30-APR-2002    Peter.Nixon     Modified
--        11-JUN-2002    Karen.Tsao      Modified to reverse logic of G_MISS_XXX and NULL.
--        27-NOV-2002    Karen.Tsao      1. Debug message to be wrapped with IF check.
--                                       2. Replace of COPY with NOCOPY string.
--        28-AUG-2003    Karen.Tsao      Change membership_type to member_type_code.
-- NOTE
--
-- Copyright (c) 2002 Oracle Corporation Redwood Shores, California, USA
--                          All rights reserved.
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'PV_PRGM_CONTRACTS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxtppcb.pls';


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
           px_program_contracts_id    IN OUT NOCOPY   NUMBER
          ,p_program_id                        NUMBER
          ,p_geo_hierarchy_id                  NUMBER
          ,p_contract_id                       NUMBER
          ,p_last_update_date                  DATE
          ,p_last_updated_by                   NUMBER
          ,p_creation_date                     DATE
          ,p_created_by                        NUMBER
          ,p_last_update_login                 NUMBER
          ,p_object_version_number             NUMBER
          ,p_member_type_code                  VARCHAR2
          )

 IS

BEGIN

   INSERT INTO PV_PROGRAM_CONTRACTS(
            program_contracts_id
           ,program_id
           ,geo_hierarchy_id
           ,contract_id
           ,last_update_date
           ,last_updated_by
           ,creation_date
           ,created_by
           ,last_update_login
           ,object_version_number
           ,member_type_code
           )
       VALUES (
            DECODE( px_program_contracts_id, NULL, px_program_contracts_id, FND_API.g_miss_num, NULL, px_program_contracts_id)
           ,DECODE( p_program_id, NULL, p_program_id, FND_API.g_miss_num, NULL, p_program_id)
           ,DECODE( p_geo_hierarchy_id, NULL, p_geo_hierarchy_id, FND_API.g_miss_num, NULL, p_geo_hierarchy_id)
           ,DECODE( p_contract_id, NULL, p_contract_id, FND_API.g_miss_num, NULL, p_contract_id)
           ,DECODE( p_last_update_date, NULL, p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date)
           ,DECODE( p_last_updated_by, NULL, p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by)
           ,DECODE( p_creation_date, NULL, p_creation_date, FND_API.g_miss_date, NULL, p_creation_date)
           ,DECODE( p_created_by, NULL, p_created_by, FND_API.g_miss_num, NULL, p_created_by)
           ,DECODE( p_last_update_login, NULL, p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login)
           ,DECODE( p_object_version_number, NULL, p_object_version_number, FND_API.g_miss_num, NULL, p_object_version_number)
           ,DECODE( p_member_type_code, NULL, p_member_type_code, FND_API.g_miss_num, NULL, p_member_type_code)
           );
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
           p_program_contracts_id            NUMBER
          ,p_program_id                      NUMBER
          ,p_geo_hierarchy_id                NUMBER
          ,p_contract_id                     NUMBER
          ,p_last_update_date                DATE
          ,p_last_updated_by                 NUMBER
          ,p_last_update_login               NUMBER
          ,p_object_version_number           NUMBER
          ,p_member_type_code                 VARCHAR2
         )

 IS
 BEGIN
    Update PV_PROGRAM_CONTRACTS
    SET
               program_contracts_id  = DECODE( p_program_contracts_id, NULL, program_contracts_id, FND_API.g_miss_num, NULL, p_program_contracts_id)
              ,program_id            = DECODE( p_program_id, NULL, program_id, FND_API.g_miss_num, NULL, p_program_id)
              ,geo_hierarchy_id      = DECODE( p_geo_hierarchy_id, NULL, geo_hierarchy_id, FND_API.g_miss_num, NULL, p_geo_hierarchy_id)
              ,contract_id           = DECODE( p_contract_id, NULL, contract_id, FND_API.g_miss_num, NULL, p_contract_id)
              ,last_update_date      = DECODE( p_last_update_date, NULL, last_update_date, FND_API.g_miss_date, NULL, p_last_update_date)
              ,last_updated_by       = DECODE( p_last_updated_by, NULL, last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by)
              ,last_update_login     = DECODE( p_last_update_login, NULL, last_update_login, FND_API.g_miss_num, NULL, p_last_update_login)
              ,object_version_number = DECODE( p_object_version_number, NULL, object_version_number, FND_API.g_miss_num, NULL, p_object_version_number+1)
              ,member_type_code       = DECODE( p_member_type_code, NULL, member_type_code, FND_API.g_miss_char, NULL, p_member_type_code)
   WHERE program_contracts_id = p_program_contracts_id
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
     p_program_contracts_id  NUMBER
    ,p_object_version_number NUMBER
    )
 IS

 BEGIN

   DELETE FROM PV_PROGRAM_CONTRACTS
    WHERE program_contracts_id = p_program_contracts_id
     AND object_version_number = p_object_version_number;

   IF (SQL%NOTFOUND) THEN
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('PV', 'PV_RECORD_NOT_FOUND');
       FND_MSG_PUB.add;
     END IF;
     RAISE FND_API.g_exc_error;
   END IF;

 END DELETE_ROW ;




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
           px_program_contracts_id     IN OUT NOCOPY  NUMBER
          ,p_program_id                        NUMBER
          ,p_geo_hierarchy_id                  NUMBER
          ,p_contract_id                       NUMBER
          ,p_last_update_date                  DATE
          ,p_last_updated_by                   NUMBER
          ,p_creation_date                     DATE
          ,p_created_by                        NUMBER
          ,p_last_update_login                 NUMBER
          ,p_member_type_code                  VARCHAR2
          ,px_object_version_number    IN OUT NOCOPY  NUMBER
          )

 IS
   CURSOR C IS
        SELECT *
         FROM PV_PROGRAM_CONTRACTS
        WHERE program_contracts_id =  px_program_contracts_id
        FOR UPDATE of program_contracts_id NOWAIT;
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
           (      Recinfo.program_contracts_id = px_program_contracts_id)
       AND (    ( Recinfo.program_id = p_program_id)
            OR (    ( Recinfo.program_id IS NULL )
                AND (  p_program_id IS NULL )))
       AND (    ( Recinfo.geo_hierarchy_id = p_geo_hierarchy_id)
            OR (    ( Recinfo.geo_hierarchy_id IS NULL )
                AND (  p_geo_hierarchy_id IS NULL )))
       AND (    ( Recinfo.contract_id = p_contract_id)
            OR (    ( Recinfo.contract_id IS NULL )
                AND (  p_contract_id IS NULL )))
       AND (    ( Recinfo.last_update_date = p_last_update_date)
            OR (    ( Recinfo.last_update_date IS NULL )
                AND (  p_last_update_date IS NULL )))
       AND (    ( Recinfo.last_updated_by = p_last_updated_by)
            OR (    ( Recinfo.last_updated_by IS NULL )
                AND (  p_last_updated_by IS NULL )))
       AND (    ( Recinfo.creation_date = p_creation_date)
            OR (    ( Recinfo.creation_date IS NULL )
                AND (  p_creation_date IS NULL )))
       AND (    ( Recinfo.created_by = p_created_by)
            OR (    ( Recinfo.created_by IS NULL )
                AND (  p_created_by IS NULL )))
       AND (    ( Recinfo.last_update_login = p_last_update_login)
            OR (    ( Recinfo.last_update_login IS NULL )
                AND (  p_last_update_login IS NULL )))
       AND (    ( Recinfo.member_type_code = p_member_type_code)
            OR (    ( Recinfo.member_type_code IS NULL )
                AND (  p_member_type_code IS NULL )))
       AND (    ( Recinfo.object_version_number = px_object_version_number)
            OR (    ( Recinfo.object_version_number IS NULL )
                AND (  px_object_version_number IS NULL )))
       ) THEN
       RETURN;
   ELSE
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
END Lock_Row;


END PV_PRGM_CONTRACTS_PKG;

/