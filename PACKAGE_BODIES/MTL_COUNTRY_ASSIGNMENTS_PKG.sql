--------------------------------------------------------
--  DDL for Package Body MTL_COUNTRY_ASSIGNMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_COUNTRY_ASSIGNMENTS_PKG" AS
-- $Header: INVGCTRB.pls 115.4 2002/12/03 21:15:23 vma ship $
--+=======================================================================+
--|               Copyright (c) 1998 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVGCTRB.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Use this package to create procedure for inserting row, updateing |
--|     row, locking row and deleting row on tables MTL_COUNTRY_ASSIGNMENTS|                                         |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|      PROCEDURE Insert_Row                                             |
--|      PROCEDURE Update_Row                                             |
--|      PROCEDURE Lock_Row                                               |
--|      PROCEDURE Delete_Row                                             |
--|                                                                       |                                                               |
--| HISTORY                                                               |
--|     12/18/98 yawang      Created                                      |
--|     11/22/02 vma         Added NOCOPY to IN OUT parameter of          |
--|                          to improve performance.                      |
--|                                                                       |
--+======================================================================*/

--==================
--CONSTANTS
--==================
G_PKG_NAME CONSTANT VARCHAR2(30) := 'MTL_COUNTRY_ASSIGNMENTS_PKG';

--==================
--PUBLIC PROCEDURE
--==================
--========================================================================
--PRECEDURE : Insert_Row		Public
--PARAMETERS: see below
--COMMENT   : table handler for inserting data to table mtl_country_
--            assignments
--========================================================================
PROCEDURE Insert_Row
( x_rowid                IN OUT NOCOPY VARCHAR2
, p_zone_code            IN     VARCHAR2
, p_territory_code       IN     VARCHAR2
, p_territory_short_name IN     VARCHAR2
, p_start_date           IN     DATE
, p_end_date             IN     DATE
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
    mtl_country_assignments
  WHERE zone_code = p_zone_code
    AND territory_code = p_territory_code;

BEGIN
  INSERT INTO mtl_country_assignments
  ( zone_code
  , territory_code
  , start_date
  , end_date
  , creation_date
  , created_by
  , last_update_date
  , last_updated_by
  , last_update_login
  )
  VALUES
  ( p_zone_code
  , p_territory_code
  , p_start_date
  , p_end_date
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
--COMMENT   : table handler for locking table mtl_country_assignments
--EXCEPTION : record_changed
--========================================================================
PROCEDURE Lock_Row
( p_rowid          IN VARCHAR2
, p_zone_code      IN VARCHAR2
, p_territory_code IN VARCHAR2
, p_start_date     IN DATE
, p_end_date       IN DATE
)
IS
  cursor c IS
    SELECT *
    FROM
      mtl_country_assignments
    WHERE
      rowid = p_rowid
    FOR UPDATE OF zone_code nowait;
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
  IF NOT( (recinfo.zone_code = p_zone_code)
         AND(recinfo.territory_code = p_territory_code)
         AND(recinfo.start_date = p_start_date)
         AND((recinfo.end_date = p_end_date )
             OR((recinfo.end_date IS NULL)
                AND(p_end_date IS NULL))))
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
--COMMENT   : table handler for updating data of table mtl_country_
--            assignments
--========================================================================
PROCEDURE Update_Row
( p_rowid             IN VARCHAR2
, p_zone_code         IN VARCHAR2
, p_territory_code    IN VARCHAR2
, p_start_date        IN DATE
, p_end_date          IN DATE
, p_last_update_date  IN DATE
, p_last_updated_by   IN NUMBER
, p_last_update_login IN NUMBER
)
IS
BEGIN
  UPDATE mtl_country_assignments
  SET
    zone_code = p_zone_code
    , territory_code = p_territory_code
    , start_date = p_start_date
    , end_date = p_end_date
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
--COMMENT   : table handler for deleting data from table mtl_country_
--            assignments
--========================================================================
PROCEDURE Delete_row
( p_rowid IN VARCHAR2
)
IS
BEGIN
  DELETE FROM
    mtl_country_assignments
  WHERE
    rowid = p_rowid;
  IF (SQL%NOTFOUND)
  THEN
    RAISE no_data_found;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'Delete_Row');
    END IF;
    RAISE;

END Delete_row;

END MTL_COUNTRY_ASSIGNMENTS_PKG;

/
