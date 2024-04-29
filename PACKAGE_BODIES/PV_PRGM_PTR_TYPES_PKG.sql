--------------------------------------------------------
--  DDL for Package Body PV_PRGM_PTR_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_PRGM_PTR_TYPES_PKG" as
/* $Header: pvxtprpb.pls 115.4 2002/12/10 20:51:55 ktsao ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_PRGM_PTR_TYPES_PKG
-- Purpose
--
-- History
--         28-FEB-2002    Paul.Ukken      Created
--         29-APR-2002    Peter.Nixon     Modified
--         14-JUN-2002    Karen.Tsao      Modified to reverse logic of G_MISS_XXX and NULL.
--
-- NOTE
--
-- Copyright (c) 2002 Oracle Corporation Redwood Shores, California, USA
--                          All rights reserved.
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30)  := 'PV_PRGM_PTR_TYPES_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxtprpb.pls';


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
            px_program_partner_types_id   IN OUT NOCOPY NUMBER
           ,p_PROGRAM_TYPE_ID              NUMBER
           ,p_partner_type                       VARCHAR2
           ,p_last_update_date                   DATE
           ,p_last_updated_by                    NUMBER
           ,p_creation_date                      DATE
           ,p_created_by                         NUMBER
           ,p_last_update_login                  NUMBER
           ,p_object_version_number              NUMBER
           )

  IS

 BEGIN

    INSERT INTO PV_PROGRAM_PARTNER_TYPES(
             program_partner_types_id
            ,PROGRAM_TYPE_ID
            ,partner_type
            ,last_update_date
            ,last_updated_by
            ,creation_date
            ,created_by
            ,last_update_login
            ,object_version_number
    ) VALUES (
             DECODE( px_program_partner_types_id, NULL, px_program_partner_types_id, FND_API.g_miss_num, NULL, px_program_partner_types_id)
            ,DECODE( p_PROGRAM_TYPE_ID, NULL, p_PROGRAM_TYPE_ID, FND_API.g_miss_num, NULL, p_PROGRAM_TYPE_ID)
            ,DECODE( p_partner_type, NULL, p_partner_type, FND_API.g_miss_char, NULL, p_partner_type)
            ,DECODE( p_last_update_date, NULL, p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date)
            ,DECODE( p_last_updated_by, NULL, p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by)
            ,DECODE( p_creation_date, NULL, p_creation_date, FND_API.g_miss_date, NULL, p_creation_date)
            ,DECODE( p_created_by, NULL, p_created_by, FND_API.g_miss_num, NULL, p_created_by)
            ,DECODE( p_last_update_login, NULL, p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login)
            ,DECODE( p_object_version_number, NULL, p_object_version_number, FND_API.g_miss_num, NULL, p_object_version_number)
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
            p_program_partner_types_id    NUMBER
           ,p_PROGRAM_TYPE_ID       NUMBER
           ,p_partner_type                VARCHAR2
           ,p_last_update_date            DATE
           ,p_last_updated_by             NUMBER
           ,p_last_update_login           NUMBER
           ,p_object_version_number       NUMBER
           )

  IS

  BEGIN

     UPDATE PV_PROGRAM_PARTNER_TYPES
     SET
        program_partner_types_id = DECODE( p_program_partner_types_id, NULL, program_partner_types_id, FND_API.g_miss_num, NULL, p_program_partner_types_id)
       ,PROGRAM_TYPE_ID          = DECODE( p_PROGRAM_TYPE_ID, NULL, PROGRAM_TYPE_ID, FND_API.g_miss_num, NULL, p_PROGRAM_TYPE_ID)
       ,partner_type             = DECODE( p_partner_type, NULL, partner_type, FND_API.g_miss_char, NULL, p_partner_type)
       ,last_update_date         = DECODE( p_last_update_date, NULL, last_update_date, FND_API.g_miss_date, NULL, p_last_update_date)
       ,last_updated_by          = DECODE( p_last_updated_by, NULL, last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by)
       ,last_update_login        = DECODE( p_last_update_login, NULL, last_update_login, FND_API.g_miss_num, NULL, p_last_update_login)
       ,object_version_number    = DECODE( p_object_version_number, NULL, object_version_number, FND_API.g_miss_num, NULL, p_object_version_number+1)
    WHERE PROGRAM_PARTNER_TYPES_ID = p_program_partner_types_id
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
     p_program_partner_types_id  NUMBER
    ,p_object_version_number     NUMBER
    )
 IS

 BEGIN

   DELETE FROM PV_PROGRAM_PARTNER_TYPES
    WHERE program_partner_types_id = p_program_partner_types_id
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
            px_program_partner_types_id   IN OUT NOCOPY    NUMBER
           ,p_PROGRAM_TYPE_ID                 NUMBER
           ,p_partner_type                          VARCHAR2
           ,p_last_update_date                      DATE
           ,p_last_updated_by                       NUMBER
           ,p_creation_date                         DATE
           ,p_created_by                            NUMBER
           ,p_last_update_login                     NUMBER
           ,px_object_version_number        IN OUT NOCOPY  NUMBER
           )

  IS
    CURSOR C IS
         SELECT *
          FROM PV_PROGRAM_PARTNER_TYPES
         WHERE PROGRAM_PARTNER_TYPES_ID =  px_program_partner_types_id
         FOR UPDATE of PROGRAM_PARTNER_TYPES_ID NOWAIT;
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
            (      Recinfo.program_partner_types_id = px_program_partner_types_id)
        AND (    ( Recinfo.PROGRAM_TYPE_ID = p_PROGRAM_TYPE_ID)
             OR (    ( Recinfo.PROGRAM_TYPE_ID IS NULL )
                 AND (  p_PROGRAM_TYPE_ID IS NULL )))
        AND (    ( Recinfo.partner_type = p_partner_type)
             OR (    ( Recinfo.partner_type IS NULL )
                 AND (  p_partner_type IS NULL )))
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

 END PV_PRGM_PTR_TYPES_PKG;

/
