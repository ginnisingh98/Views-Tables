--------------------------------------------------------
--  DDL for Package INV_MGD_POSITIONS_CP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_MGD_POSITIONS_CP" AUTHID CURRENT_USER AS
-- $Header: INVCPOSS.pls 120.1 2005/06/21 06:25:23 appldev ship $
--+=======================================================================+
--|               Copyright (c) 2000 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVCPOSS.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Concurrent programs implementation for Inventory Position View    |
--|     and Export                                                        |
--|                                                                       |
--| HISTORY                                                               |
--|     09/01/2000 Paolo Juvara      Created                              |
--+=======================================================================+

--===================
-- TYPES
--===================
-- add your type declarations here if any

--===================
-- CONSTANTS
--===================
-- add your constants here if any

--===================
-- PUBLIC VARIABLES
--===================
-- add your public global variables here if any

--===================
-- PROCEDURES AND FUNCTIONS
--===================

--========================================================================
-- PROCEDURE : Build                   PUBLIC
-- PARAMETERS: x_errbuf                error buffer
--             x_retcode               0 success, 1 warning, 2 error
--             p_data_set_name         data set name
--             p_hierarchy_id          organization hierarchy
--             p_hierarchy_level       hierarchy level
--             p_item_from             item range from
--             p_item_to               item range to
--             p_category_id           item category
--             p_date_from             date range from
--             p_date_to               date range to
--             p_bucket_size           bucket size
-- COMMENT   : Inventory Position Build concurrent program
--========================================================================
PROCEDURE Build
( x_errbuff            OUT NOCOPY VARCHAR2
, x_retcode            OUT NOCOPY NUMBER
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
-- PARAMETERS: x_errbuf                error buffer
--             x_retcode               0 success, 1 warning, 2 error
--             p_purge_all             Y to purge all, N otherwise
--             p_data_set_name         purge specific data set name
--             p_created_by            purge data set for specific user ID
--             p_creation_date         purge data set created before date
-- COMMENT   : Inventory Position Purge concurrent program; p_purge_all takes
--             priority over other parameters
--========================================================================
PROCEDURE Purge
( x_errbuff            OUT NOCOPY VARCHAR2
, x_retcode            OUT NOCOPY NUMBER
, p_purge_all          IN  VARCHAR2
, p_data_set_name      IN  VARCHAR2
, p_created_by         IN  VARCHAR2
, p_creation_date      IN  VARCHAR2
);

END INV_MGD_POSITIONS_CP;

 

/
