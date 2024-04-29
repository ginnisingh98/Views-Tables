--------------------------------------------------------
--  DDL for Package INV_MGD_POSITIONS_PROC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_MGD_POSITIONS_PROC" AUTHID CURRENT_USER AS
-- $Header: INVSPOSS.pls 120.1 2005/06/22 05:48:00 appldev ship $
--+=======================================================================+
--|               Copyright (c) 2000 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--| FILENAME                                                              |
--|     INVSPOSS.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Inventory Position View and Export Processor                      |
--|                                                                       |
--| HISTORY                                                               |
--|     09/11/2000 Paolo Juvara      Created                              |
--+=======================================================================+


--===================
-- PROCEDURES AND FUNCTIONS
--===================

--========================================================================
-- PROCEDURE : Build                   PUBLIC
-- PARAMETERS: p_init_msg_list         standard API parameter
--             x_return_status         standard API parameter
--             x_msg_count             standard API parameter
--             x_msg_data              standard API parameter
--             p_data_set_name         data set name
--             p_hierarchy_id          organization hierarchy
--             p_hierarchy_level       hierarchy level
--             p_item_from             item range from (in canonical frmt)
--             p_item_to               item range to (in canonical frmt)
--             p_category_id           item category
--             p_date_from             date range from
--             p_date_to               date range to
--             p_bucket_size           bucket size
-- COMMENT   : Inventory Position Build processor
-- PRE-COND  : all organization in hierarchy share same item master
--========================================================================
PROCEDURE Build
( p_init_msg_list      IN  VARCHAR2 DEFAULT FND_API.G_FALSE
, x_return_status      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
, x_msg_count          OUT NOCOPY /* file.sql.39 change */ NUMBER
, x_msg_data           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
, p_data_set_name      IN  VARCHAR2
, p_hierarchy_id       IN  NUMBER
, p_hierarchy_level    IN  VARCHAR2
, p_item_from          IN  VARCHAR2
, p_item_to            IN  VARCHAR2
, p_category_id        IN  NUMBER
, p_date_from          IN  VARCHAR2
, p_date_to            IN  VARCHAR2
, p_bucket_size        IN  VARCHAR2
);


--========================================================================
-- PROCEDURE : Purge                   PUBLIC
-- PARAMETERS: p_init_msg_list         standard API parameter
--             x_return_status         standard API parameter
--             x_msg_count             standard API parameter
--             x_msg_data              standard API parameter
--             p_purge_all             Y to purge all, N otherwise
--             p_created_by            purge data set for specific user ID
--             p_creation_date         purge data set created before date
--                                     (in canonical format)
--             p_data_set_name         purge specific data set name
-- COMMENT   : Inventory Position Purge; p_purge_all takes
--             priority over other parameters
--========================================================================
PROCEDURE Purge
( p_init_msg_list      IN  VARCHAR2 DEFAULT FND_API.G_FALSE
, x_return_status      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
, x_msg_count          OUT NOCOPY /* file.sql.39 change */ NUMBER
, x_msg_data           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
, p_purge_all          IN  VARCHAR2
, p_data_set_name      IN  VARCHAR2
, p_created_by         IN  VARCHAR2
, p_creation_date      IN  VARCHAR2
);

END INV_MGD_POSITIONS_PROC;

 

/
