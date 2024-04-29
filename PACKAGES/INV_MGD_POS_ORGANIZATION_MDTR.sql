--------------------------------------------------------
--  DDL for Package INV_MGD_POS_ORGANIZATION_MDTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_MGD_POS_ORGANIZATION_MDTR" AUTHID CURRENT_USER AS
/* $Header: INVMPORS.pls 115.1 2002/12/24 23:16:36 vjavli ship $ */
--+=======================================================================+
--|               Copyright (c) 2000 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVMPORS.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Inventory Position View and Export: Organization Mediator         |
--| HISTORY                                                               |
--|     09/05/2000 Paolo Juvara      Created                              |
--+======================================================================*/


--===================
-- PROCEDURES AND FUNCTIONS
--===================

--========================================================================
-- PROCEDURE : Build_Organization_List PUBLIC
-- PARAMETERS: p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--             p_hierarchy_id          organization hierarchy
--             p_hierarchy_level_id    organization ID identifying the level
--             x_organization_tbl      list of organization
-- COMMENT   : Builds the list of organizations that belong to a hierarchy level
-- POST-COND : x_organization_tbl is not empty
--========================================================================
PROCEDURE Build_Organization_List
( p_hierarchy_id       IN            NUMBER
, p_hierarchy_level_id IN            NUMBER
, x_organization_tbl   IN OUT NOCOPY INV_MGD_POS_UTIL.organization_tbl_type
);



END INV_MGD_POS_ORGANIZATION_MDTR;

 

/
