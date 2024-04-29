--------------------------------------------------------
--  DDL for Package Body MTL_LE_ECONOMIC_ZONES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_LE_ECONOMIC_ZONES_PKG" AS
-- $Header: INVGLEZB.pls 115.2 99/07/16 10:51:22 porting ship $
--+=======================================================================+
--|               Copyright (c) 1998 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     <filename.pls>                                                    |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     add description here                                              |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|     add list of procedures and functions here in order of             |
--|     declaration                                                       |
--|                                                                       |
--| HISTORY                                                               |
--|     MM/DD/YY <Author>        Created                                  |
--+======================================================================*/

--===================
-- CONSTANTS
--===================
G_PKG_NAME CONSTANT VARCHAR2(30) := 'MTL_LE_ECONOMIC_ZONES_PKG';
-- add your constants here if any

--===================
-- GLOBAL VARIABLES
--===================
-- add your private global variables here if any

--===================
-- PUBLIC PROCEDURES AND FUNCTIONS
--===================

--========================================================================
-- PROCEDURE : Insert_Row              PRIVATE
-- PARAMETERS:
--
--
-- COMMENT   :
--
-- EXCEPTIONS:
--========================================================================
PROCEDURE Insert_Row
( p_rowid           IN OUT  VARCHAR2
, p_legal_entity_id         NUMBER
, p_zone_code               VARCHAR2
, p_last_update_date        DATE
, p_last_updated_by         NUMBER
, p_last_update_login       NUMBER
, p_created_by              NUMBER
, p_creation_date           DATE
)
IS
l_count NUMBER;
CURSOR C IS
  SELECT
    rowid
  FROM
    MTL_LE_ECONOMIC_ZONES
  WHERE Legal_Entity_ID = p_legal_entity_id
    AND Zone_Code       = p_zone_code;

BEGIN

  SELECT
    COUNT(*)
  INTO
    l_count
  FROM
    MTL_LE_ECONOMIC_ZONES
  WHERE Legal_Entity_id = p_legal_entity_id
    AND Zone_Code       = p_zone_code;

  IF l_count = 0 THEN
    INSERT INTO MTL_LE_ECONOMIC_ZONES(
      Legal_Entity_ID
    , Zone_Code
    , Last_Update_Date
    , Last_Updated_By
    , Last_Update_Login
    , Created_By
    , Creation_Date
    )
    VALUES(
      p_legal_entity_id
    , p_zone_code
    , p_last_update_date
    , p_last_updated_by
    , p_last_update_login
    , p_created_by
    , p_creation_date
    );

    OPEN C;
    FETCH C INTO p_rowid;
    IF (C%NOTFOUND) THEN
      CLOSE C;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE C;
  END IF;

END Insert_Row;


--========================================================================
-- PROCEDURE : Lock_Row              PRIVATE
-- PARAMETERS:
--
--
-- COMMENT   :
--
-- EXCEPTIONS:
--========================================================================
PROCEDURE Lock_Row
( p_rowid           IN  VARCHAR2
, p_legal_entity_id     NUMBER
, p_zone_code           VARCHAR2
)
IS
CURSOR C IS
  SELECT *
    FROM MTL_LE_ECONOMIC_ZONES
   WHERE ROWID = p_rowid
   FOR UPDATE OF Legal_Entity_ID NOWAIT;
Recinfo C%ROWTYPE;

BEGIN

  OPEN C;
  FETCH C INTO Recinfo;
  IF (C%NOTFOUND) THEN
    CLOSE C;
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
    APP_EXCEPTION.Raise_Exception;
  END IF;
  CLOSE C;

  IF (
      (Recinfo.Legal_Entity_ID = p_legal_entity_id)
      AND
      (Recinfo.zone_code = p_zone_code)
     )
  THEN
    RETURN;
  ELSE
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.Raise_Exception;
  END IF;

END Lock_Row;


--========================================================================
-- PROCEDURE : Update_Row              PRIVATE
-- PARAMETERS:
--
--
-- COMMENT   :
--
-- EXCEPTIONS:
--========================================================================
PROCEDURE Update_Row
( p_rowid           IN  VARCHAR2
, p_legal_entity_id     NUMBER
, p_zone_code           VARCHAR2
, p_last_update_date    DATE
, p_last_updated_by     NUMBER
, p_last_update_login   NUMBER
, p_created_by          NUMBER
, p_creation_date       DATE
)
IS
BEGIN

  UPDATE MTL_LE_ECONOMIC_ZONES
    SET
      Legal_Entity_ID         = p_legal_entity_id
    , zone_code               = p_zone_code
    , last_update_date        = p_last_update_date
    , last_updated_by         = p_last_updated_by
    , last_update_login       = p_last_update_login
    , created_by              = p_created_by
    , creation_date           = p_creation_date
  WHERE ROWID = p_rowid;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END Update_Row;


--========================================================================
-- PROCEDURE : Delete_Row              PRIVATE
-- PARAMETERS:
--
--
-- COMMENT   :
--
-- EXCEPTIONS:
--========================================================================
PROCEDURE Delete_Row
( p_rowid IN  VARCHAR2
)
IS
BEGIN

  DELETE FROM MTL_LE_ECONOMIC_ZONES
  WHERE ROWID = p_rowid;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END Delete_Row;

END MTL_LE_ECONOMIC_ZONES_PKG;

/
