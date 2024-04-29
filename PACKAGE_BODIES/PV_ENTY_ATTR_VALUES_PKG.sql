--------------------------------------------------------
--  DDL for Package Body PV_ENTY_ATTR_VALUES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_ENTY_ATTR_VALUES_PKG" as
/* $Header: pvxteavb.pls 115.3 2002/12/10 19:41:57 amaram ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_ENTY_ATTR_VALUES_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================

G_PKG_NAME CONSTANT     VARCHAR2(30) := 'PV_ENTY_ATTR_VALUES_PKG';
G_FILE_NAME CONSTANT    VARCHAR2(12) := 'pvxteavb.pls';

----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

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
PROCEDURE Insert_Row(
           px_enty_attr_val_id          IN OUT NOCOPY  NUMBER
          ,p_last_update_date                   DATE
          ,p_last_updated_by                    NUMBER
          ,p_creation_date                      DATE
          ,p_created_by                         NUMBER
          ,p_last_update_login                  NUMBER
          ,px_object_version_number     IN OUT NOCOPY  NUMBER
          ,p_entity                             VARCHAR2
          ,p_attribute_id                       NUMBER
          ,p_party_id                           NUMBER
          ,p_attr_value                         VARCHAR2
          ,p_score                              VARCHAR2
          ,p_enabled_flag                       VARCHAR2
          ,p_entity_id                          NUMBER
          -- p_security_group_id    NUMBER
	  ,p_version				NUMBER
	  ,p_latest_flag			VARCHAR2
	  ,p_attr_value_extn			VARCHAR2
	  ,p_validation_id			NUMBER
          )

 IS
	x_rowid    VARCHAR2(30);

BEGIN

   px_object_version_number := 1;

   INSERT INTO PV_ENTY_ATTR_VALUES(
            enty_attr_val_id
           ,last_update_date
           ,last_updated_by
           ,creation_date
           ,created_by
           ,last_update_login
           ,object_version_number
           ,entity
           ,attribute_id
           ,party_id
           ,attr_value
           ,score
           ,enabled_flag
           ,entity_id
           -- security_group_id
	   ,version
	   ,latest_flag
	   ,attr_value_extn
	   ,validation_id
	) VALUES (
            DECODE( px_enty_attr_val_id, FND_API.g_miss_num, NULL, px_enty_attr_val_id)
           ,DECODE( p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date)
           ,DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by)
           ,DECODE( p_creation_date, FND_API.g_miss_date, NULL, p_creation_date)
           ,DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by)
           ,DECODE( p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login)
           ,DECODE( px_object_version_number, FND_API.g_miss_num, NULL, px_object_version_number)
           ,DECODE( p_entity, FND_API.g_miss_char, NULL, p_entity)
           ,DECODE( p_attribute_id, FND_API.g_miss_num, NULL, p_attribute_id)
           ,DECODE( p_party_id, FND_API.g_miss_num, NULL, p_party_id)
           ,DECODE( p_attr_value, FND_API.g_miss_char, NULL, p_attr_value)
           ,DECODE( p_score, FND_API.g_miss_char, NULL, p_score)
           ,DECODE( p_enabled_flag, FND_API.g_miss_char, NULL, p_enabled_flag)
           ,DECODE( p_entity_id, FND_API.g_miss_num, NULL, p_entity_id)
           -- DECODE( p_security_group_id, FND_API.g_miss_num, NULL, p_security_group_id)
	   ,DECODE( p_version, FND_API.g_miss_num, NULL, p_version)
	   ,DECODE( p_latest_flag, FND_API.g_miss_char, NULL, p_latest_flag)
	   ,DECODE( p_attr_value_extn, FND_API.g_miss_char, NULL, p_attr_value_extn)
	   ,DECODE( p_validation_id, FND_API.g_miss_num, NULL, p_validation_id)
           );
END Insert_Row;


----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

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
           p_enty_attr_val_id           NUMBER
          ,p_last_update_date           DATE
          ,p_last_updated_by            NUMBER
          -- p_creation_date               DATE
          -- p_created_by                  NUMBER
          ,p_last_update_login          NUMBER
          ,p_object_version_number      NUMBER
          ,p_entity                     VARCHAR2
          ,p_attribute_id               NUMBER
          ,p_party_id                   NUMBER
          ,p_attr_value                 VARCHAR2
          ,p_score                      VARCHAR2
          ,p_enabled_flag               VARCHAR2
          ,p_entity_id                  NUMBER
          -- p_security_group_id    NUMBER
	  ,p_version				NUMBER
	  ,p_latest_flag			VARCHAR2
	  ,p_attr_value_extn			VARCHAR2
	  ,p_validation_id			NUMBER
          )

 IS

 BEGIN
    Update PV_ENTY_ATTR_VALUES
    SET
	 enty_attr_val_id       = DECODE( p_enty_attr_val_id, FND_API.g_miss_num, enty_attr_val_id, p_enty_attr_val_id)
	,last_update_date       = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date)
	,last_updated_by        = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by)
	-- creation_date           = DECODE( p_creation_date, FND_API.g_miss_date, creation_date, p_creation_date)
	-- created_by              = DECODE( p_created_by, FND_API.g_miss_num, created_by, p_created_by)
	,last_update_login      = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login)
	,object_version_number  = DECODE( p_object_version_number, FND_API.g_miss_num, object_version_number
                                    ,p_object_version_number+1)
	,entity                 = DECODE( p_entity, FND_API.g_miss_char, entity, p_entity)
	,attribute_id           = DECODE( p_attribute_id, FND_API.g_miss_num, attribute_id, p_attribute_id)
	,party_id               = DECODE( p_party_id, FND_API.g_miss_num, party_id, p_party_id)
	,attr_value             = DECODE( p_attr_value, FND_API.g_miss_char, attr_value, p_attr_value)
	,score                  = DECODE( p_score, FND_API.g_miss_char, score, p_score)
	,enabled_flag           = DECODE( p_enabled_flag, FND_API.g_miss_char, enabled_flag, p_enabled_flag)
	,entity_id              = DECODE( p_entity_id, FND_API.g_miss_num, entity_id, p_entity_id)
	-- security_group_id = DECODE( p_security_group_id, FND_API.g_miss_num, security_group_id, p_security_group_id)

	,version		= DECODE( p_version, FND_API.g_miss_num, version, p_version)
	,latest_flag		= DECODE( p_latest_flag, FND_API.g_miss_char, latest_flag, p_latest_flag)
	,attr_value_extn	= DECODE( p_attr_value_extn, FND_API.g_miss_char, attr_value_extn, p_attr_value_extn)
	,validation_id		= DECODE( p_validation_id, FND_API.g_miss_num, validation_id, p_validation_id)
   WHERE ENTY_ATTR_VAL_ID = p_ENTY_ATTR_VAL_ID
   AND   object_version_number = p_object_version_number;

   IF (SQL%NOTFOUND) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
END Update_Row;


----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createDeleteBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Delete_Row(
    p_ENTY_ATTR_VAL_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM PV_ENTY_ATTR_VALUES
    WHERE ENTY_ATTR_VAL_ID = p_ENTY_ATTR_VAL_ID;
   IF (SQL%NOTFOUND) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
 END Delete_Row ;


----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createLockBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Lock_Row(
           p_enty_attr_val_id        NUMBER
          ,p_last_update_date        DATE
          ,p_last_updated_by         NUMBER
          ,p_creation_date           DATE
          ,p_created_by              NUMBER
          ,p_last_update_login       NUMBER
          ,p_object_version_number   NUMBER
          ,p_entity                  VARCHAR2
          ,p_attribute_id            NUMBER
          ,p_party_id                NUMBER
          ,p_attr_value              VARCHAR2
          ,p_score                   VARCHAR2
          ,p_enabled_flag            VARCHAR2
          ,p_entity_id               NUMBER
          -- p_security_group_id    NUMBER
	  ,p_version				NUMBER
	  ,p_latest_flag			VARCHAR2
	  ,p_attr_value_extn			VARCHAR2
	  ,p_validation_id			NUMBER
          )

 IS
   CURSOR C IS
        SELECT *
         FROM PV_ENTY_ATTR_VALUES
        WHERE ENTY_ATTR_VAL_ID =  p_ENTY_ATTR_VAL_ID
        FOR UPDATE of ENTY_ATTR_VAL_ID NOWAIT;
   Recinfo C%ROWTYPE;

 BEGIN
    OPEN c;
    FETCH c INTO Recinfo;
    IF (c%NOTFOUND) THEN
        CLOSE c;
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
    CLOSE C;
    IF (
           (      Recinfo.enty_attr_val_id = p_enty_attr_val_id)
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
       AND (    ( Recinfo.object_version_number = p_object_version_number)
            OR (    ( Recinfo.object_version_number IS NULL )
                AND (  p_object_version_number IS NULL )))
       AND (    ( Recinfo.entity = p_entity)
            OR (    ( Recinfo.entity IS NULL )
                AND (  p_entity IS NULL )))
       AND (    ( Recinfo.attribute_id = p_attribute_id)
            OR (    ( Recinfo.attribute_id IS NULL )
                AND (  p_attribute_id IS NULL )))
       AND (    ( Recinfo.party_id = p_party_id)
            OR (    ( Recinfo.party_id IS NULL )
                AND (  p_party_id IS NULL )))
       AND (    ( Recinfo.attr_value = p_attr_value)
            OR (    ( Recinfo.attr_value IS NULL )
                AND (  p_attr_value IS NULL )))
       AND (    ( Recinfo.score = p_score)
            OR (    ( Recinfo.score IS NULL )
                AND (  p_score IS NULL )))
       AND (    ( Recinfo.enabled_flag = p_enabled_flag)
            OR (    ( Recinfo.enabled_flag IS NULL )
                AND (  p_enabled_flag IS NULL )))
       AND (    ( Recinfo.entity_id = p_entity_id)
            OR (    ( Recinfo.entity_id IS NULL )
                AND (  p_entity_id IS NULL )))

	AND (    ( Recinfo.version = p_version)
            OR (    ( Recinfo.version IS NULL )
                AND (  p_version IS NULL )))
	AND (    ( Recinfo.latest_flag = p_latest_flag)
            OR (    ( Recinfo.latest_flag IS NULL )
                AND (  p_latest_flag IS NULL )))
	AND (    ( Recinfo.attr_value_extn = p_attr_value_extn)
            OR (    ( Recinfo.attr_value_extn IS NULL )
                AND (  p_attr_value_extn IS NULL )))
	AND (    ( Recinfo.validation_id = p_validation_id)
            OR (    ( Recinfo.validation_id IS NULL )
                AND (  p_validation_id IS NULL )))





/*
       AND (    ( Recinfo.security_group_id = p_security_group_id)
            OR (    ( Recinfo.security_group_id IS NULL )
                AND (  p_security_group_id IS NULL )))
*/
       ) THEN
       RETURN;
   ELSE
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
END Lock_Row;

END PV_ENTY_ATTR_VALUES_PKG;

/
