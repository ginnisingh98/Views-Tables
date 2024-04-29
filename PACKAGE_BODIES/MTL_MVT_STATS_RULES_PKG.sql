--------------------------------------------------------
--  DDL for Package Body MTL_MVT_STATS_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_MVT_STATS_RULES_PKG" AS
-- $Header: INVGMVRB.pls 115.2 2002/12/03 21:48:40 vma ship $
--+=======================================================================+
--|               Copyright (c) 1998 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVGMVRB.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Use this package to create procedure for inserting row, updating  |
--|     row, locking row and deleting row on tables MTL_MVT_STATS_RULES   |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|      PROCEDURE Insert_Row                                             |
--|      PROCEDURE Update_Row                                             |
--|      PROCEDURE Lock_Row                                               |
--|      PROCEDURE Delete_Row                                             |
--| HISTORY                                                               |
--|     07/14/00 ksaini      Created                                      |
--|     09/18/00 ksaini      Delete_Row procedure corrected               |
--|     11/22/02 vma         Added NOCOPY to x_rowid of Insert_Row to     |
--|                          comply with new PL/SQL standard for better   |
--|                          performance                                  |
--|                                                                       |
--+======================================================================*/

--==================
--CONSTANTS
--==================
G_PKG_NAME CONSTANT VARCHAR2(30) := 'MTL_MVT_STATS_RULES_PKG';

--==================
--PUBLIC PROCEDURE
--==================
--========================================================================
--PRECEDURE : Insert_Row		Public
--PARAMETERS: see below
--COMMENT   : table handler for inserting data to table mtl_mvt_stats_rules
--            assignments
--========================================================================
PROCEDURE Insert_Row
( x_rowid                IN OUT NOCOPY VARCHAR2
, p_rule_set_code        IN     VARCHAR2
, p_rule_number          IN     NUMBER
, p_source_type          IN     VARCHAR2
, p_attribute_code       IN     VARCHAR2
, p_attribute_property_code IN  VARCHAR2
, p_attribute_lookup_type   IN  VARCHAR2
, p_commodity_code       IN     VARCHAR2
, p_creation_date        IN     DATE
, p_created_by           IN     NUMBER
, p_last_update_date     IN     DATE
, p_last_updated_by      IN     NUMBER
, p_last_update_login    IN     NUMBER
)
IS
  CURSOR c IS
  SELECT
    rowid
  FROM
    mtl_mvt_stats_rules
  WHERE rule_set_code = p_rule_set_code
    AND rule_number = p_rule_number;

BEGIN
  INSERT INTO mtl_mvt_stats_rules
  ( rule_set_code
  , rule_number
  , source_type
  , attribute_code
  , attribute_property_code
  , attribute_lookup_type
  , commodity_code
  , creation_date
  , created_by
  , last_update_date
  , last_updated_by
  , last_update_login
  )
  VALUES
  ( p_rule_set_code
  , p_rule_number
  , p_source_type
  , p_attribute_code
  , p_attribute_property_code
  , p_attribute_lookup_type
  , p_commodity_code
  , p_creation_date
  , p_created_by
  , p_last_update_date
  , p_last_updated_by
  , p_last_update_login
  );

  OPEN c;
  FETCH c into x_rowid;
  IF (c%NOTFOUND)
  THEN
  CLOSE c;
  RAISE no_data_found;
  END IF;
  CLOSE c;

EXCEPTION
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'Insert_Row');
    END IF;
    RAISE;

END Insert_Row;

--========================================================================
--PRECEDURE : Lock_Row		        Public
--PARAMETERS: see below
--COMMENT   : table handler for locking table mtl_mvt_stats_rules
--EXCEPTION : record_changed
--========================================================================
PROCEDURE Lock_Row
( p_rowid          IN VARCHAR2
, p_rule_set_code        IN     VARCHAR2
, p_rule_number          IN     NUMBER
, p_source_type          IN     VARCHAR2
, p_attribute_code       IN     VARCHAR2
, p_attribute_property_code IN  VARCHAR2
, p_attribute_lookup_type   IN  VARCHAR2
, p_commodity_code       IN     VARCHAR2
)
IS
  cursor c IS
    SELECT *
    FROM
      mtl_mvt_stats_rules
    WHERE
      rowid = p_rowid
    FOR UPDATE OF rule_set_code nowait;
  recinfo c%ROWTYPE;
  record_changed EXCEPTION;

BEGIN
  OPEN c;
  FETCH c INTO recinfo;
  IF (c%NOTFOUND)
  THEN
    CLOSE c;
    FND_MESSAGE.set_name('FND', 'FORM_RECORD_DELETED');
    APP_EXCEPTION.raise_exception;
  END IF;
  CLOSE c;

  --  check that mandatory and non-mandatory columns match values in form
  IF NOT( (recinfo.rule_set_code = p_rule_set_code)
         AND(recinfo.rule_number = p_rule_number)
         AND(recinfo.attribute_code = p_attribute_code)
         AND((recinfo.source_type = p_source_type )
             OR((recinfo.source_type IS NULL)
                AND(p_source_type IS NULL)))
         AND((recinfo.attribute_lookup_type = p_attribute_lookup_type )
             OR((recinfo.attribute_lookup_type IS NULL)
                AND(p_attribute_lookup_type IS NULL)))
         AND((recinfo.attribute_property_code = p_attribute_property_code )
             OR((recinfo.attribute_property_code IS NULL)
                AND(p_attribute_property_code IS NULL)))
         AND((recinfo.commodity_code = p_commodity_code )
             OR((recinfo.commodity_code IS NULL)
                AND(p_commodity_code IS NULL))))
  THEN
    RAISE record_changed;
  END IF;

EXCEPTION
  WHEN record_changed THEN
    FND_MESSAGE.set_name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.raise_exception;
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'Lock_Row');
    END IF;
    RAISE;

END Lock_Row;

--========================================================================
--PRECEDURE : Update_Row		Public
--PARAMETERS: see below
--COMMENT   : table handler for updating data of table MTL_MVT_STATS_RULES
--========================================================================
PROCEDURE Update_Row
( p_rowid             IN VARCHAR2
, p_rule_set_code        IN     VARCHAR2
, p_rule_number          IN     NUMBER
, p_source_type          IN     VARCHAR2
, p_attribute_code       IN     VARCHAR2
, p_attribute_property_code IN  VARCHAR2
, p_attribute_lookup_type   IN  VARCHAR2
, p_commodity_code       IN     VARCHAR2
, p_last_update_date  IN DATE
, p_last_updated_by   IN NUMBER
, p_last_update_login IN NUMBER
)
IS
BEGIN
  UPDATE mtl_mvt_stats_rules
  SET  rule_set_code = p_rule_set_code
     , rule_number = p_rule_number
     , source_type  = p_source_type
     , attribute_code = p_attribute_code
     , attribute_property_code = p_attribute_property_code
     , attribute_lookup_type = p_attribute_lookup_type
     , commodity_code = p_commodity_code
     , last_update_date = p_last_update_date
     , last_updated_by = p_last_updated_by
     , last_update_login = p_last_update_login
  WHERE rowid = p_rowid;
  IF (SQL%NOTFOUND)
  THEN
    RAISE no_data_found;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'Update_Row');
    END IF;
    RAISE;

END Update_row;

--========================================================================
--PRECEDURE : Delete_Row		Public
--PARAMETERS: see below
--COMMENT   : table handler for deleting data from table MTL_MVT_STATS_RULES
--========================================================================
PROCEDURE Delete_row
( p_rule_set_code IN VARCHAR2
)
IS
BEGIN
  DELETE FROM
    mtl_mvt_stats_rules
  WHERE
    rule_set_code = p_rule_set_code;
  IF (SQL%NOTFOUND)
  THEN
    RAISE no_data_found;
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    NULL;
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'Delete_Row'||substr(sqlerrm,1,100));
    END IF;
    RAISE;

END Delete_row;

END MTL_MVT_STATS_RULES_PKG;

/
