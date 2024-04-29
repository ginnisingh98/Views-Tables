--------------------------------------------------------
--  DDL for Package Body MTL_MVT_STATS_RULE_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_MVT_STATS_RULE_SETS_PKG" AS
-- $Header: INVGVRSB.pls 115.1 2002/12/03 22:09:25 vma ship $
--+=======================================================================+
--|            Copyright (c) 1998,1999 Oracle Corporation                 |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVGVRSB.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Use this package to create procedure for inserting rows, updating |
--|     rows, locking rows and deleting rows on tables                    |
--|     MTL_MVT_STATS_RULE_SETS and MTL_MVT_STATS_RULE_SETS_TL            |
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
--|     07/13/00 Komal Saini  Created                                     |
--|     11/26/02 Vivian Ma    Added NOCOPY to x_rowid of Insert_Row to    |
--|                           comply with new PL/SQL standard for better  |
--|                           performance                                 |
--|                                                                       |
--+======================================================================*/

--==================
--CONSTANTS
--==================
G_PKG_NAME CONSTANT VARCHAR2(30) := 'MTL_MVT_STATS_RULE_SETS_PKG';

--==================
--PUBLIC PROCEDURE
--==================
--=========================================================================
--PRECEDURE : Insert_Row		Public
--PARAMETERS: see below
--COMMENT   : table handler for inserting data into table mtl_mvt_stats_rule_sets
--            _b and table mtl_mvt_stats_rule_sets_tl
--==========================================================================
PROCEDURE Insert_Row
( x_rowid             IN OUT NOCOPY VARCHAR2
, p_rule_set_code         IN     VARCHAR2
, p_rule_set_display_name IN     VARCHAR2
, p_rule_set_description  IN     VARCHAR2
, p_rule_set_type     IN     VARCHAR2
, p_category_set_id   IN     NUMBER
, p_seeded_flag       IN     VARCHAR2
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
    MTL_MVT_STATS_RULE_SETS_B
  WHERE Rule_Set_code = p_rule_set_code;
BEGIN
  INSERT INTO MTL_MVT_STATS_RULE_SETS_B
  ( Rule_Set_code
  , Rule_set_type
  , Seeded_Flag
  , Category_Set_Id
  , creation_date
  , created_by
  , last_update_date
  , last_updated_by
  , last_update_login
  )
  VALUES
  ( p_rule_set_code
  , p_Rule_set_type
  , p_seeded_flag
  , p_category_set_id
  , p_creation_date
  , p_created_by
  , p_last_update_date
  , p_last_updated_by
  , p_last_update_login
  );

  INSERT INTO MTL_MVT_STATS_RULE_SETS_TL
  ( Rule_Set_code
  , Rule_Set_display_name
  , Rule_Set_description
  , created_by
  , creation_date
  , last_updated_by
  , last_update_date
  , last_update_login
  , language
  , source_lang
  )
  SELECT
    p_rule_set_code
  , p_rule_set_display_name
  , p_rule_set_description
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
          MTL_MVT_STATS_RULE_SETS_TL T
        WHERE T.Rule_Set_code = p_rule_set_code
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
--COMMENT   : table handler for locking table mtl_mvt_stats_rule_sets_b and
--            table mtl_mvt_stats_rule_sets_tl
--EXCEPTION : record_changed;
--==========================================================================
PROCEDURE Lock_Row
( p_rule_set_code          IN VARCHAR2
, p_rule_set_display_name  IN VARCHAR2
, p_rule_set_description   IN VARCHAR2
)
IS
CURSOR c IS
  SELECT *
  FROM
    MTL_MVT_STATS_RULE_SETS_B
  WHERE Rule_Set_code = p_rule_set_code
  FOR UPDATE OF Rule_Set_code NOWAIT;
recinfo c%ROWTYPE;

CURSOR c1 IS
  SELECT
    Rule_Set_display_name
  , Rule_Set_description
  , decode(language, USERENV('LANG'), 'Y', 'N') baselang
  FROM
    MTL_MVT_STATS_RULE_SETS_TL
  WHERE Rule_Set_code = p_rule_set_code
  FOR UPDATE OF Rule_Set_code NOWAIT;

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
      IF NOT (    (tlinfo.Rule_Set_display_name  = p_rule_set_display_name )
              AND (tlinfo.Rule_Set_description = p_rule_set_description) )
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
--COMMENT   : table handler for updating data of table mtl_mvt_stats_rule_sets
--            _b and table mtl_mvt_stats_rule_sets_tl
--==========================================================================
PROCEDURE Update_Row
( p_rule_set_code         IN VARCHAR2
, p_rule_set_display_name IN VARCHAR2
, p_rule_set_description  IN VARCHAR2
, p_rule_set_type     IN     VARCHAR2
, p_category_set_id   IN NUMBER
, p_last_update_date  IN DATE
, p_last_updated_by   IN NUMBER
, p_last_update_login IN NUMBER
)
IS
BEGIN
  UPDATE MTL_MVT_STATS_RULE_SETS_B
  SET
    last_update_date  = p_last_update_date
  , last_updated_by  = p_last_updated_by
  , last_update_login  = p_last_update_login
  , Rule_Set_type = p_rule_set_type
  , Category_Set_Id = p_category_set_id
  WHERE Rule_Set_code = p_rule_set_code;

  IF (SQL%NOTFOUND)
  THEN
    RAISE NO_DATA_FOUND;
  END IF;

  UPDATE MTL_MVT_STATS_RULE_SETS_TL
  SET
    Rule_Set_display_name  = p_rule_set_display_name
  , Rule_Set_description = p_rule_set_description
  , last_update_date  = p_last_update_date
  , last_updated_by  = p_last_updated_by
  , last_update_login  = p_last_update_login
  , source_lang = USERENV('LANG')
  WHERE Rule_Set_code = p_rule_set_code
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
--COMMENT   : table handler for deleting data from table mtl_mvt_stats_rule_sets
--            _b and table mtl_mvt_stats_rule_sets_tl
--==========================================================================
PROCEDURE Delete_Row
( p_rule_set_code IN VARCHAR2
)
IS
BEGIN
  DELETE FROM MTL_MVT_STATS_RULE_SETS_TL
  WHERE Rule_Set_code = p_rule_set_code;

  IF (SQL%NOTFOUND)
  THEN
    RAISE NO_DATA_FOUND;
  END IF;

  DELETE FROM MTL_MVT_STATS_RULE_SETS_B
  WHERE Rule_Set_code = p_rule_set_code;

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
  DELETE FROM MTL_MVT_STATS_RULE_SETS_TL T
  WHERE NOT EXISTS
    (SELECT
       NULL
     FROM
       MTL_MVT_STATS_RULE_SETS_B B
     WHERE B.Rule_Set_code = T.Rule_Set_code
     );

  UPDATE MTL_MVT_STATS_RULE_SETS_TL T
  SET (Rule_Set_display_name
       ,Rule_Set_description ) =
      (SELECT
         B.Rule_Set_display_name
         , B.Rule_Set_description
       FROM
         MTL_MVT_STATS_RULE_SETS_TL B
       WHERE B.Rule_Set_code = T.Rule_Set_code
         AND B.language = T.source_lang)
  WHERE (T.Rule_Set_code
        , T.language
     )IN (SELECT
            SUBT.Rule_Set_code
          , SUBT.language
          FROM
            MTL_MVT_STATS_RULE_SETS_TL SUBB
          , MTL_MVT_STATS_RULE_SETS_TL SUBT
          WHERE SUBB.Rule_Set_code = SUBT.Rule_Set_code
            AND SUBB.language = SUBT.source_lang
            AND (SUBB.Rule_Set_display_name  <> SUBT.Rule_Set_display_name
                 OR SUBB.Rule_Set_description <> SUBT.Rule_Set_description));

  INSERT INTO MTL_MVT_STATS_RULE_SETS_TL
  ( Rule_Set_code
  , Rule_Set_display_name
  , Rule_Set_description
  , created_by
  , creation_date
  , last_updated_by
  , last_update_date
  , last_update_login
  , language
  , source_lang
  )
  SELECT
      B.Rule_Set_code
    , B.Rule_Set_display_name
    , B.Rule_Set_description
    , B.created_by
    , B.creation_date
    , B.last_updated_by
    , B.last_update_date
    , B.last_update_login
    , L.language_CODE
    , B.source_lang
  FROM
    MTL_MVT_STATS_RULE_SETS_TL B
  , FND_LANGUAGES L
  WHERE L.INSTALLED_FLAG IN ('I', 'B')
    AND B.language = USERENV('LANG')
    AND NOT EXISTS
       (SELECT
          NULL
        FROM
          MTL_MVT_STATS_RULE_SETS_TL T
        WHERE T.Rule_Set_code = B.Rule_Set_code
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
-- PARAMETERS: p_rule_set_code         rule sets code (develper's key)
--             p_rule_set_display_name rule sets name
--             p_rule_set_description  description
--             p_owner             user owning the row (SEED or other)
-- COMMENT   : used to upload seed data in NLS mode
--========================================================================
PROCEDURE Translate_Row
( p_rule_set_code         IN  VARCHAR2
, p_rule_set_display_name IN  VARCHAR2
, p_rule_set_description  IN  VARCHAR2
, p_owner             IN  VARCHAR2
)
IS
BEGIN

  UPDATE mtl_mvt_stats_rule_sets_tl
    SET Rule_Set_display_name = p_rule_set_display_name
      , Rule_Set_description  = p_rule_set_description
      , last_update_date  = SYSDATE
      , last_updated_by   = DECODE(p_owner, 'SEED', 1, 0)
      , last_update_login = 0
      , source_lang       = userenv('LANG')
    WHERE Rule_Set_code = p_rule_set_code
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
-- PARAMETERS: p_rule_set_code         rule sets code (develper's key)
--             p_owner             user owning the row (SEED or other)
--             p_rule_set_display_name rule sets name
--             p_rule_set_description  description
-- COMMENT   : used to upload seed data in MLS mode
--========================================================================
PROCEDURE Load_Row
( p_rule_set_code 	      IN  VARCHAR2
, p_owner             IN  VARCHAR2
, p_rule_set_display_name IN  VARCHAR2
, p_rule_set_description  IN  VARCHAR2
, p_Rule_set_type         IN  VARCHAR2
, p_category_set_id       IN  NUMBER
, p_seeded_flag           IN  VARCHAR2
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
    ( p_rule_set_code         => p_rule_set_code
    , p_rule_set_display_name => p_rule_set_display_name
    , p_rule_set_description  => p_rule_set_description
    , p_rule_set_type  => p_rule_set_type
    , p_category_set_id  => p_category_set_id
    , p_last_update_date  => SYSDATE
    , p_last_updated_by   => l_user_id
    , p_last_update_login => 0
    );
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      -- insert row
      Insert_Row
      ( x_rowid             => l_row_id
      , p_rule_set_code         => p_rule_set_code
      , p_rule_set_display_name => p_rule_set_display_name
      , p_rule_set_description  => p_rule_set_description
      , p_rule_set_type  => p_rule_set_type
      , p_category_set_id  => p_category_set_id
      , p_seeded_flag      => p_seeded_flag
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


END MTL_MVT_STATS_RULE_SETS_PKG;

/
