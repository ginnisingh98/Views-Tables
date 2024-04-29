--------------------------------------------------------
--  DDL for Package Body INV_CONSUMPTION_ADVICE_CP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_CONSUMPTION_ADVICE_CP" AS
-- $Header: INVCCADB.pls 115.1 2003/02/03 23:09:32 dherring noship $
--+=======================================================================+
--|               Copyright (c) 2002 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVCCADB.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    Consigned Inventory Consumption Concurrent Program Wrapper         |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|     consumption_txn_worker                                            |
--|     consumption_txn_manager                                           |
--|                                                                       |
--| HISTORY                                                               |
--|     11/13/02 dherring        Created                                  |
--+========================================================================

--========================================================================
-- PROCEDURE : Consumption_Transaction_Work      PRIVATE
-- COMMENT   : This procedure will copy all the records of a context batch
--             from MTL_CONSUMPTION_TRANSACTIONS to
--             MTL_CONSUMPTION_TRANSACTIONS_TEMP
--             summarize the net quantity  and call the create consumption
--             advice procedure
--=========================================================================
PROCEDURE  consumption_txn_worker
( x_retcode            OUT NOCOPY VARCHAR2
, x_errbuff            OUT NOCOPY VARCHAR2
, p_batch_id           IN  NUMBER
)
IS
BEGIN

  INV_CONSUMPTION_ADVICE_PROC.consumption_txn_worker(p_batch_id);

EXCEPTION

  WHEN OTHERS THEN
    x_retcode := 2;
    x_errbuff := SUBSTRB(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE)
                        ,1
                        ,250);

END consumption_txn_worker;

--========================================================================
-- PROCEDURE : Consumption_Txn_Manager     PUBLIC
-- COMMENT   : This procedure will assign each unprocessed record in
--             MTL_CONSUMPTION_TRANSACTIONS to a batch and then call the
--             Consumption_Transaction_Worker for that batch. The manager
--             will continue until all records
--             in MTL_CONSUMPTION_TRANSACTIONS
--             have been assigned to a batch.
--=========================================================================
PROCEDURE  consumption_txn_manager
( x_retcode            OUT NOCOPY VARCHAR2
, x_errbuff            OUT NOCOPY VARCHAR2
, p_batch_size         IN  NUMBER
, p_max_workers        IN  NUMBER
, p_vendor_id          IN  NUMBER
, p_vendor_site_id     IN  NUMBER
, p_item_id            IN  NUMBER
, p_org_id             IN  NUMBER
)
IS
BEGIN

  INV_CONSUMPTION_ADVICE_PROC.consumption_txn_manager
                              ( p_batch_size
                              , p_max_workers
                              , p_vendor_id
                              , p_vendor_site_id
                              , p_item_id
                              , p_org_id
                              );

EXCEPTION

  WHEN OTHERS THEN
    x_retcode := 2;
    x_errbuff := SUBSTRB(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE)
                        ,1
                        ,250);

END consumption_txn_manager;

END INV_CONSUMPTION_ADVICE_CP;

/
