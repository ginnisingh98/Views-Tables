--------------------------------------------------------
--  DDL for Package Body MTL_ECONOMIC_ZONES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_ECONOMIC_ZONES_PKG" AS
-- $Header: INVGEZNB.pls 115.7 2002/12/03 21:41:31 vma ship $
--+=======================================================================+
--|            Copyright (c) 1998,1999 Oracle Corporation                 |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVGEZNB.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Use this package to create procedure for inserting rows, updateing|
--|     rows, locking rows and deleting rows on tables MTL_ECONOMIC_ZONES |
--|     and MTL_ECONOMIC_ZONES_TL                                         |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|      PROCEDURE Insert_Row                                             |
--|      PROCEDURE Update_Row                                             |
--|      PROCEDURE Lock_Row                                               |
--|      PROCEDURE Delete_Row                                             |
--|      PROCEDURE Add_Language                                           |
--|      PROCEDURE Translate_Row                                          |
--|      PROCEDURE Load_Row                                               |
--|                                                                       |
--| HISTORY                                                               |
--|     12/17/98 Yanping Wang  Created                                    |
--|     07/06/99 Paolo Juvara  added translate_row, laod_row              |
--|     11/26/02 Vivian Ma     added NOCOPY to x_rowid of Insert_Row to   |
--|                            comply with new PL/SQL standard for better |
--|                            performance                                |
--|                                                                       |
--+======================================================================*/

--==================
--CONSTANTS
--==================
G_PKG_NAME CONSTANT VARCHAR2(30) := 'MTL_ECONOMIC_ZONES_PKG';

--==================
--PUBLIC PROCEDURE
--==================
--=========================================================================
--PRECEDURE : Insert_Row		Public
--PARAMETERS: see below
--COMMENT   : table handler for inserting data into table mtl_economic_zones
--            _b and table mtl_economic_zones_tl
--==========================================================================
PROCEDURE Insert_Row
( x_rowid             IN OUT NOCOPY VARCHAR2
, p_zone_code         IN     VARCHAR2
, p_zone_display_name IN     VARCHAR2
, p_zone_description  IN     VARCHAR2
, p_creation_date     IN     DATE
, p_created_by        IN     NUMBER
, p_last_update_date  IN     DATE
, p_last_updated_by   IN     NUMBER
, p_last_update_login IN     NUMBER
)
IS
CURSOR c IS
  SELECT
    rowid
  FROM
    MTL_ECONOMIC_ZONES_B
  WHERE zone_code = p_zone_code;
BEGIN
  INSERT INTO MTL_ECONOMIC_ZONES_B
  ( zone_code
  , creation_date
  , created_by
  , last_update_date
  , last_updated_by
  , last_update_login
  )
  VALUES
  ( p_zone_code
  , p_creation_date
  , p_created_by
  , p_last_update_date
  , p_last_updated_by
  , p_last_update_login
  );

  INSERT INTO MTL_ECONOMIC_ZONES_TL
  ( zone_code
  , zone_display_name
  , zone_description
  , created_by
  , creation_date
  , last_updated_by
  , last_update_date
  , last_update_login
  , language
  , source_lang
  )
  SELECT
    p_zone_code
  , p_zone_display_name
  , p_zone_description
  , p_created_by
  , p_creation_date
  , p_last_updated_by
  , p_last_update_date
  , p_last_update_login
  , L.language_code
  , USERENV('LANG')
  FROM
    FND_LANGUAGES L
  WHERE L.installed_flag IN ('I', 'B')
    AND NOT EXISTS
       (SELECT
          NULL
        FROM
          MTL_ECONOMIC_ZONES_TL T
        WHERE T.zone_code = p_zone_code
          AND T.language = L.language_code);

  OPEN c;
  FETCH c INTO x_rowid;
  IF (c%NOTFOUND)
  THEN
    CLOSE c;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE c;

EXCEPTION
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'Insert_Row');
    END IF;
    RAISE;

END INSERT_ROW;

--=========================================================================
--PRECEDURE : Lock_Row		        Public
--PARAMETERS: see below
--COMMENT   : table handler for locking table mtl_economic_zones_b and
--            table mtl_economic_zones_tl
--EXCEPTION : record_changed;
--==========================================================================
PROCEDURE Lock_Row
( p_zone_code          IN VARCHAR2
, p_zone_display_name  IN VARCHAR2
, p_zone_description   IN VARCHAR2
)
IS
CURSOR c IS
  SELECT *
  FROM
    MTL_ECONOMIC_ZONES_B
  WHERE zone_code = p_zone_code
  FOR UPDATE OF zone_code NOWAIT;
recinfo c%ROWTYPE;

CURSOR c1 IS
  SELECT
    zone_display_name
  , zone_description
  , decode(language, USERENV('LANG'), 'Y', 'N') baselang
  FROM
    MTL_ECONOMIC_ZONES_TL
  WHERE zone_code = p_zone_code
  FOR UPDATE OF zone_code NOWAIT;

record_changed EXCEPTION;

BEGIN
  OPEN c;
  FETCH C INTO recinfo;
  IF (c%NOTFOUND)
  THEN
    CLOSE c;
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
    APP_EXCEPTION.Raise_Exception;
  END IF;
  CLOSE c;

  FOR tlinfo IN c1
  LOOP
    IF (tlinfo.baselang = 'Y')
    THEN
      IF NOT (    (tlinfo.zone_display_name  = p_zone_display_name )
              AND (tlinfo.zone_description = p_zone_description))
      THEN
        RAISE record_changed;
      END IF;
    END IF;
  END LOOP;
  RETURN;

EXCEPTION
  WHEN record_changed THEN
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.raise_exception;
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'Insert_Row');
    END IF;
    RAISE;

END LOCK_ROW;

--=========================================================================
--PRECEDURE : Update_Row		Public
--PARAMETERS: see below
--COMMENT   : table handler for updating data of table mtl_economic_zones
--            _b and table mtl_economic_zones_tl
--==========================================================================
PROCEDURE Update_Row
( p_zone_code         IN VARCHAR2
, p_zone_display_name IN VARCHAR2
, p_zone_description  IN VARCHAR2
, p_last_update_date  IN DATE
, p_last_updated_by   IN NUMBER
, p_last_update_login IN NUMBER
)
IS
BEGIN
  UPDATE MTL_ECONOMIC_ZONES_B
  SET
    last_update_date  = p_last_update_date
  , last_updated_by  = p_last_updated_by
  , last_update_login  = p_last_update_login
  WHERE zone_code = p_zone_code;

  IF (SQL%NOTFOUND)
  THEN
    RAISE NO_DATA_FOUND;
  END IF;

  UPDATE MTL_ECONOMIC_ZONES_TL
  SET
    zone_display_name  = p_zone_display_name
  , zone_description = p_zone_description
  , last_update_date  = p_last_update_date
  , last_updated_by  = p_last_updated_by
  , last_update_login  = p_last_update_login
  , source_lang = USERENV('LANG')
  WHERE zone_code = p_zone_code
    AND USERENV('LANG') IN (language, source_lang);

  IF (SQL%NOTFOUND)
  THEN
    RAISE NO_DATA_FOUND;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'Update_Row');
    END IF;
  RAISE;

END Update_Row;

--=========================================================================
--PRECEDURE : Delete_Row	        Public
--PARAMETERS: see below
--COMMENT   : table handler for deleting data from table mtl_economic_zones
--            _b and table mtl_economic_zones_tl
--==========================================================================
PROCEDURE Delete_Row
( p_zone_code IN VARCHAR2
)
IS
BEGIN
  DELETE FROM MTL_ECONOMIC_ZONES_TL
  WHERE zone_code = p_zone_code;

  IF (SQL%NOTFOUND)
  THEN
    RAISE NO_DATA_FOUND;
  END IF;

  DELETE FROM MTL_ECONOMIC_ZONES_B
  WHERE zone_code = p_zone_code;

  IF (SQL%NOTFOUND)
  THEN
    RAISE NO_DATA_FOUND;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'Delete_Row');
    END IF;
    RAISE;

END DELETE_ROW;

--=========================================================================
--PRECEDURE : Add_Language		Public
--PARAMETERS: none
--COMMENT   : called by NLADD script whenever a new language is added or
--            after any other operation
--==========================================================================
PROCEDURE Add_Language
IS
BEGIN
  DELETE FROM MTL_ECONOMIC_ZONES_TL T
  WHERE NOT EXISTS
    (SELECT
       NULL
     FROM
       MTL_ECONOMIC_ZONES_B B
     WHERE B.zone_code = T.zone_code
     );

  UPDATE MTL_ECONOMIC_ZONES_TL T
  SET (zone_display_name
       ,zone_description) =
      (SELECT
         B.zone_display_name
         , B.zone_description
       FROM
         MTL_ECONOMIC_ZONES_TL B
       WHERE B.zone_code = T.zone_code
         AND B.language = T.source_lang)
  WHERE (T.zone_code
        , T.language
     )IN (SELECT
            SUBT.zone_code
          , SUBT.language
          FROM
            MTL_ECONOMIC_ZONES_TL SUBB
          , MTL_ECONOMIC_ZONES_TL SUBT
          WHERE SUBB.zone_code = SUBT.zone_code
            AND SUBB.language = SUBT.source_lang
            AND (SUBB.zone_display_name  <> SUBT.zone_display_name
                 OR SUBB.zone_description <> SUBT.zone_description));

  INSERT INTO MTL_ECONOMIC_ZONES_TL
  ( zone_code
  , zone_display_name
  , zone_description
  , created_by
  , creation_date
  , last_updated_by
  , last_update_date
  , last_update_login
  , language
  , source_lang
  )
  SELECT
      B.zone_code
    , B.zone_display_name
    , B.zone_description
    , B.created_by
    , B.creation_date
    , B.last_updated_by
    , B.last_update_date
    , B.last_update_login
    , L.language_CODE
    , B.source_lang
  FROM
    MTL_ECONOMIC_ZONES_TL B
  , FND_LANGUAGES L
  WHERE L.INSTALLED_FLAG IN ('I', 'B')
    AND B.language = USERENV('LANG')
    AND NOT EXISTS
       (SELECT
          NULL
        FROM
          MTL_ECONOMIC_ZONES_TL T
        WHERE T.zone_code = B.zone_code
          AND T.language = L.language_CODE);

EXCEPTION
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'Add_Language');
    END IF;
    RAISE;

END Add_Language;

--========================================================================
-- PROCEDURE : Translate_Row       PUBLIC
-- PARAMETERS: p_zone_code         economic zone code (develper's key)
--             p_zone_display_name economic zone name
--             p_zone_description  description
--             p_owner             user owning the row (SEED or other)
-- COMMENT   : used to upload seed data in NLS mode
--========================================================================
PROCEDURE Translate_Row
( p_zone_code         IN  VARCHAR2
, p_zone_display_name IN  VARCHAR2
, p_zone_description  IN  VARCHAR2
, p_owner             IN  VARCHAR2
)
IS
BEGIN

  UPDATE mtl_economic_zones_tl
    SET zone_display_name = p_zone_display_name
      , zone_description  = p_zone_description
      , last_update_date  = SYSDATE
      , last_updated_by   = DECODE(p_owner, 'SEED', 1, 0)
      , last_update_login = 0
      , source_lang       = userenv('LANG')
    WHERE zone_code = p_zone_code
      AND userenv('LANG') IN (language, source_lang);

EXCEPTION
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'Translate_Row');
    END IF;
    RAISE;

END Translate_Row;

--========================================================================
-- PRECEDURE : Load_Row		         PUBLIC
-- PARAMETERS: p_zone_code         economic zone code (develper's key)
--             p_owner             user owning the row (SEED or other)
--             p_zone_display_name economic zone name
--             p_zone_description  description
-- COMMENT   : used to upload seed data in MLS mode
--========================================================================
PROCEDURE Load_Row
( p_zone_code 	      IN  VARCHAR2
, p_owner             IN  VARCHAR2
, p_zone_display_name IN  VARCHAR2
, p_zone_description  IN  VARCHAR2
)
IS

l_row_id  VARCHAR2(20);
l_user_id NUMBER;

BEGIN

  -- assign user ID
  IF (p_owner = 'SEED')
  THEN
    l_user_id := 1;
  ELSE
    l_user_id := 0;
  END IF;

  BEGIN
    -- update row if present
    Update_Row
    ( p_zone_code         => p_zone_code
    , p_zone_display_name => p_zone_display_name
    , p_zone_description  => p_zone_description
    , p_last_update_date  => SYSDATE
    , p_last_updated_by   => l_user_id
    , p_last_update_login => 0
    );
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      -- insert row
      Insert_Row
      ( x_rowid             => l_row_id
      , p_zone_code         => p_zone_code
      , p_zone_display_name => p_zone_display_name
      , p_zone_description  => p_zone_description
      , p_creation_date     => SYSDATE
      , p_created_by        => l_user_id
      , p_last_update_date  => SYSDATE
      , p_last_updated_by   => l_user_id
      , p_last_update_login => 0
      );
  END;

EXCEPTION
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'Load_Row');
    END IF;
    RAISE;

END Load_Row;


END MTL_ECONOMIC_ZONES_PKG;

/
