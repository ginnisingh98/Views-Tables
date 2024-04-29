--------------------------------------------------------
--  DDL for Package Body CST_PAC_ITEM_COSTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CST_PAC_ITEM_COSTS_PKG" AS
/* $Header: CSTGLICB.pls 115.7 2002/11/08 20:33:53 awwang ship $ */
/*======================================================================+
|                 Copyright (c) 1999 Oracle Corporation                 |
|                         Redwood Shores, CA, USA                       |
|                           All rights reserved.                        |
|   FILENAME : CSTGLICS.pls                                             |
|                                                                       |
|   DESCRIPTION: Use this package  to insert,lock,update and  delete    |
|                       records from the table CST_PAC_ITEM_COSTS       |
|                                                                       |
|   PROCEDURE LIST:                                                     |
|        PROCEDURE Insert_row,                                          |
|        PROCEDURE Lock_row,                                            |
|        PROCEDURE Update_row,                                          |
|        PROCEDURE Delete_row                                           |
|                                                                       |
|   HISTORY:                                                            |
|            02/15/99   Tatiana Simmonds  Created                       |
+=======================================================================*/

--======================================================================
--CONSTANTS
--======================================================================
G_PKG_NAME CONSTANT VARCHAR2(30)    :='CST_PAC_ITEM_COSTS_PKG';


--========================================================================
-- PROCEDURE : Insert_row            PUBLIC
-- PARAMETERS: p_row_id              ROWID of the current record
--             p_pac_period_id       period id
--             p_cost_group_id       cost group id
--             p_inventory_item_id   inventory item id
--             p_item_cost           item cost
--             p_market_value        market value
--             p_justification       justification
--             p_creation_date       date, when a record was inserted
--             p_created_by          userid of the person,who inserted a record
-- COMMENT   : Procedure inserts record into the table CST_PAC_ITEM_COSTS
--========================================================================
 PROCEDURE Insert_row (
   p_row_id IN OUT NOCOPY     VARCHAR2
 , p_pac_period_id     NUMBER
 , p_cost_group_id     NUMBER
 , p_inventory_item_id NUMBER
 , p_item_cost         NUMBER
 , p_market_value      NUMBER
 , p_justification     VARCHAR2
 , p_creation_date     DATE
 , p_created_by        NUMBER
 )
IS
CURSOR C IS
  SELECT
    rowid
  FROM
    CST_PAC_ITEM_COSTS
  WHERE pac_period_id=p_pac_period_id
    AND cost_group_id=p_cost_group_id
      AND inventory_item_id=p_inventory_item_id;

BEGIN
  INSERT
  INTO cst_pac_item_costs
  ( pac_period_id
  , cost_group_id
  , inventory_item_id
  , item_cost
  , market_value
  , justification
  , creation_date
  , created_by
  )
  VALUES
  ( p_pac_period_id
  , p_cost_group_id
  , p_inventory_item_id
  , p_item_cost
  , p_market_value
  , p_justification
  , p_creation_date
  , p_created_by
  );

  OPEN c;
  FETCH  c INTO p_row_id;
  IF (c%NOTFOUND)
  THEN
    CLOSE c;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE c;
EXCEPTION
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
       FND_MSG_PUB.Add_exc_msg(G_PKG_NAME,'Insert_row');
    END IF;
    RAISE;

 END Insert_row;


--========================================================================
-- PROCEDURE : Lock_row              PUBLIC
-- PARAMETERS: p_row_id              ROWID of the current record
--             p_market_value        market value
--             p_justification       justification
-- COMMENT   : Procedure locks current record in the table CST_PAC_ITEM_COSTS.
--========================================================================
PROCEDURE Lock_row (
  p_row_id            VARCHAR2
 ,p_market_value      NUMBER
 ,p_justification     VARCHAR2
 )
IS
  CURSOR c
  IS
    SELECT *
    FROM CST_PAC_ITEM_COSTS
    WHERE ROWID=CHARTOROWID(p_row_id)
    FOR UPDATE OF market_value NOWAIT;

  recinfo c%ROWTYPE;

BEGIN

  OPEN c;
  FETCH c INTO recinfo;
  IF (c%NOTFOUND)
  THEN
    CLOSE c;
    FND_MESSAGE.Set_name('FND', 'FORM_RECORD_DELETED');
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE c;

  IF
    ((recinfo.market_value=p_market_value)
      OR (recinfo.market_value is NULL AND p_market_value is NULL))
    AND
    ((recinfo.justification=p_justification)
      OR (recinfo.justification is NULL AND p_justification is NULL))
  THEN
     NULL;
  ELSE
     FND_MESSAGE.set_name('FND', 'FORM_RECORD_CHANGED');
     APP_EXCEPTION.raise_exception;
  END IF;

END Lock_Row;


--========================================================================
-- PROCEDURE : Update_row             PUBLIC
-- PARAMETERS: p_row_id               ROWID of the current record
--             p_item_cost            item cost
--             p_market_value         market value
--             p_justification        justification
--             p_last_update_date     date,when the record was updated
--             p_last_updated_by      userid of the person,who updated the record
-- COMMENT   : Procedure updates columns market_value and justification
--             in the table CST_PAC_ITEM_COSTS for the record
--             with ROWID,passed as a parameter p_row_id.
--========================================================================
PROCEDURE Update_row (
  p_row_id             VARCHAR2
, p_item_cost          NUMBER
, p_market_value       NUMBER
, p_justification      VARCHAR2
, p_last_update_date   DATE
, p_last_updated_by    NUMBER
)
IS

BEGIN
  UPDATE CST_PAC_ITEM_COSTS
  SET
    item_cost=p_item_cost
   ,market_value=p_market_value
   ,justification=p_justification
   ,last_update_date=p_last_update_date
   ,last_updated_by=p_last_updated_by
  WHERE ROWID=CHARTOROWID(p_row_id);


 IF (SQL%NOTFOUND)
  THEN
       RAISE NO_DATA_FOUND;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
       FND_MSG_PUB.Add_exc_msg(G_PKG_NAME,'Update_row');
    END IF;
  RAISE;

  END Update_Row;


--========================================================================
-- PROCEDURE : Delete_row              PUBLIC
-- PARAMETERS: p_row_id                ROWID of the current record
-- COMMENT   : Procedure deletes record with ROWID=p_row_id from the
--             table CST_PAC_ITEM_COSTS.
--========================================================================
PROCEDURE Delete_row (
 p_row_id VARCHAR2)
IS
BEGIN
  DELETE
  FROM CST_PAC_ITEM_COSTS
  WHERE ROWID=p_row_id;

    IF (SQL%NOTFOUND)
    THEN
      RAISE NO_DATA_FOUND;
    END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
       FND_MSG_PUB.Add_exc_msg(G_PKG_NAME,'Delete_row');
    END IF;
  RAISE;

END Delete_row;

END CST_PAC_ITEM_COSTS_PKG;

/
