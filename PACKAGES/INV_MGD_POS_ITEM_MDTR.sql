--------------------------------------------------------
--  DDL for Package INV_MGD_POS_ITEM_MDTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_MGD_POS_ITEM_MDTR" AUTHID CURRENT_USER AS
/* $Header: INVMPITS.pls 115.1 2002/12/24 23:08:02 vjavli ship $ */
--+=======================================================================+
--|               Copyright (c) 2000 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVMPITS.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Inventory Position View and Export: Item Mediator                 |
--| HISTORY                                                               |
--|     09/05/2000 Paolo Juvara      Created                              |
--+======================================================================*/


--===================
-- PROCEDURES AND FUNCTIONS
--===================

--========================================================================
-- PROCEDURE : Build_Item_List PUBLIC
-- PARAMETERS: p_organization_tbl      list of organization
--             p_master_org_id         master item organization
--             p_item_from             item from range
--             p_item_to               item to range
--             p_category_id           category id
--             x_item_tbl              item list
-- COMMENT   : Builds the list of items to view
-- PRE-COND  : p_organization_tbl is not empty
-- POST-COND : x_item_tbl is not empty
--========================================================================
PROCEDURE Build_Item_List
( p_organization_tbl   IN            INV_MGD_POS_UTIL.organization_tbl_type
, p_master_org_id      IN            NUMBER DEFAULT NULL
, p_item_from          IN            VARCHAR2 DEFAULT NULL
, p_item_to            IN            VARCHAR2 DEFAULT NULL
, p_category_id        IN            NUMBER   DEFAULT NULL
, x_item_tbl           IN OUT NOCOPY INV_MGD_POS_UTIL.item_tbl_type
);



END INV_MGD_POS_ITEM_MDTR;

 

/
