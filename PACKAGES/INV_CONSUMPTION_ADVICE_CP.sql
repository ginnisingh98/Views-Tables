--------------------------------------------------------
--  DDL for Package INV_CONSUMPTION_ADVICE_CP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_CONSUMPTION_ADVICE_CP" AUTHID CURRENT_USER AS
-- $Header: INVCCADS.pls 115.0 2002/12/17 01:34:23 dherring noship $
--+=======================================================================+
--|               Copyright (c) 2002 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVCCADS.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Consumption Transactions Concurrent Program                       |
--| HISTORY                                                               |
--|     12/11/02 David Herring        Created                             |
--+======================================================================--

--===================
-- PROCEDURES AND FUNCTIONS
--===================

--========================================================================
-- PROCEDURE : Consumption_Txn_Manager     PUBLIC
-- PARAMETERS: x_retcode            OUT NOCOPY Return status
--             x_errbuff            OUT NOCOPY Return error message
--             p_batch_size         IN    Size of a batch
--             p_max_workers        IN    Number of workers allowed
--             p_vendor_id          IN    Specific supplier
--             p_vendor_site_code   IN    Specific supplier site
--             p_item_id            IN    Specific item
--             p_org_id             IN    Specific organization
--
-- COMMENT   : This procedure will assign records to a batch id
--=========================================================================
PROCEDURE consumption_txn_manager
( x_retcode            OUT NOCOPY VARCHAR2
, x_errbuff            OUT NOCOPY VARCHAR2
, p_batch_size         IN  NUMBER
, p_max_workers        IN  NUMBER
, p_vendor_id          IN  NUMBER
, p_vendor_site_id     IN  NUMBER
, p_item_id            IN  NUMBER
, p_org_id             IN  NUMBER
);

--========================================================================
-- PROCEDURE : Consumption_Txn_Worker     PUBLIC
-- PARAMETERS: x_retcode            OUT NOCOPY  Return status
--             x_errbuff            OUT NOCOPY  Return error message
--             p_batch_id           IN    Batch identifier
--
-- COMMENT   : This procedure will set in motion the creation of
--             one consumption advice
--=========================================================================
PROCEDURE consumption_txn_worker
( x_retcode            OUT NOCOPY VARCHAR2
, x_errbuff            OUT NOCOPY VARCHAR2
, p_batch_id           IN  NUMBER
);

END INV_CONSUMPTION_ADVICE_CP;

 

/
