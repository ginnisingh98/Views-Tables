--------------------------------------------------------
--  DDL for Package INV_CONSUMPTION_ADVICE_PROC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_CONSUMPTION_ADVICE_PROC" AUTHID CURRENT_USER AS
/* $Header: INVRCADS.pls 115.1 2003/01/28 03:01:11 dherring noship $ */
--+=======================================================================+
--|               Copyright (c) 2002 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVRCADS.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Create Consumption Advice                                         |
--| HISTORY                                                               |
--|     12/11/2002 David Herring       created                            |
--+========================================================================

--===================
-- CONSTANTS
--===================

G_LOG_PROCEDURE               CONSTANT NUMBER := 2;

--===================
-- PROCEDURES AND FUNCTIONS
--===================

--========================================================================
-- PROCEDURE : Consumption_Txn_Manager     PUBLIC
-- PARAMETERS: p_batch_size         IN    Size of a batch
--             p_max_workers        IN    Number of workers allowed
--             p_vendor_id          IN    Records for supplier
--             p_vendor_site_id     IN    Records for supplier site
--             p_inventory_item_id  IN    Records for specific item
--             p_organization_id    IN    Records for specific org
--
-- COMMENT   : This procedure will assign records to a batch id
--=========================================================================
PROCEDURE  consumption_txn_manager
( p_batch_size         IN    NUMBER
, p_max_workers        IN    NUMBER
, p_vendor_id          IN    NUMBER
, p_vendor_site_id     IN    NUMBER
, p_inventory_item_id  IN    NUMBER
, p_organization_id    IN    NUMBER
);

--========================================================================
-- PROCEDURE : Consumption_Txn_Worker     PUBLIC
-- PARAMETERS: p_batch_id           IN    Id of records to be processed
--
-- COMMENT   : This procedure will set in motion the creation of
--             one consumption advice
--=========================================================================
PROCEDURE consumption_txn_worker
( p_batch_id           IN  NUMBER
);

END INV_CONSUMPTION_ADVICE_PROC;

 

/
