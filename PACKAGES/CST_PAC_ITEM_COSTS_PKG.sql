--------------------------------------------------------
--  DDL for Package CST_PAC_ITEM_COSTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CST_PAC_ITEM_COSTS_PKG" AUTHID CURRENT_USER AS
/* $Header: CSTGLICS.pls 120.1 2005/08/25 11:43:04 sheyu noship $ */
/*======================================================================+
|                 Copyright (c) 1999 Oracle Corporation                 |
|                         Redwood Shores, CA, USA                       |
|                           All rights reserved.                        |
|                                                                       |
|   FILENAME : CSTGLICS.pls                                             |
|                                                                       |
|   DESCRIPTION: Use this package to insert,lock,update and             |
|                delete records from the table CST_PAC_ITEM_COSTS       |
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
--
--
--========================================================================
-- PUBLIC PROCEDURES
--========================================================================

--========================================================================
-- PROCEDURE : Insert_row            PUBLIC
-- PARAMETERS  p_row_id              ROWID of the current record
--             p_pac_period_id       period id
--             p_cost_group_id       cost group id
--             p_inventory_item_id   inventory item id
--             p_item_cost           item cost
--             p_market_value        market value
--             p_justification       justification
--             p_creation_date       date,when the record was inserted
--             p_created_by          userid of the person,who inserted the record
-- COMMENT   : Procedure inserts record into the table CST_PAC_ITEM_COSTS
--========================================================================
 PROCEDURE Insert_row (
   p_row_id            IN OUT NOCOPY VARCHAR2
 , p_pac_period_id            NUMBER
 , p_cost_group_id            NUMBER
 , p_inventory_item_id        NUMBER
 , p_item_cost                NUMBER
 , p_market_value             NUMBER
 , p_justification            VARCHAR2
 , p_creation_date            DATE
 , p_created_by               NUMBER
 );
--
--
--========================================================================
-- PROCEDURE : Lock_row              PUBLIC
-- PARAMETERS: p_row_id              ROWID of the current record
--             p_market_value        market value
--             p_justification       justification
-- COMMENT   : Procedure locks record in the table CST_PAC_ITEM_COSTS.
-- EXCEPTION : CST_PAC_ITEM_COSTS_PKG.g_record_changed
--             CST_PAC_ITEM_COSTS_PKG.g_record_deleted
--             CST_PAC_ITEM_COSTS_PKG.g_record_locked
--========================================================================
PROCEDURE Lock_row (
  p_row_id            VARCHAR2
 ,p_market_value      NUMBER
 ,p_justification     VARCHAR2
 );
--
--
--========================================================================
-- PROCEDURE : Update_row              PUBLIC
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
);
--
--
--========================================================================
-- PROCEDURE : Delete_row              PUBLIC
-- PARAMETERS: p_row_id                ROWID of the current record
-- COMMENT   : Procedure deletes record with ROWID=p_row_id from the
--             table CST_PAC_ITEM_COSTS.
--========================================================================
PROCEDURE Delete_row (
 p_row_id VARCHAR2);
--
--
END CST_PAC_ITEM_COSTS_PKG;

 

/
