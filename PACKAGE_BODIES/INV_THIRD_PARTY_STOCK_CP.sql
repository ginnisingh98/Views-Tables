--------------------------------------------------------
--  DDL for Package Body INV_THIRD_PARTY_STOCK_CP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_THIRD_PARTY_STOCK_CP" AS
-- $Header: INVCCCPB.pls 115.0 2002/12/03 02:27:29 dherring noship $
--+=======================================================================+
--|               Copyright (c) 2002 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVCCCPB.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    Consigned Inventory Consumption Concurrent Program Wrapper         |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|     cons_txn_work                                                     |
--|     consumption_txn_manager                                           |
--|                                                                       |
--| HISTORY                                                               |
--|     11/13/02 dherring        Created                                  |
--+========================================================================

--===================
-- CONSTANTS
--===================
G_PKG_NAME CONSTANT VARCHAR2(30) := 'INV_THIRD_PARTY_STOCK_CP';

--=================
-- TYPES
--=================

TYPE g_cons_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE g_cons_date_tbl_type IS TABLE OF DATE INDEX BY BINARY_INTEGER;
TYPE g_cons_varchar_tbl_type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

TYPE g_request_tbl_type IS TABLE OF NUMBER
  INDEX BY BINARY_INTEGER;

--========================================================================
-- PROCEDURE : Consumption_Transaction_Work      PRIVATE
-- COMMENT   : This procedure will copy all the records of a context batch
--             from MTL_CONSUMPTION_TRANSACTIONS to
--             MTL_CONSUMPTION_TRANSACTIONS_TEMP
--             summarize the net quantity  and call the create consumption
--             advice procedure
--=========================================================================
PROCEDURE  cons_txn_work
( x_retcode            OUT NOCOPY VARCHAR2
, x_errbuff            OUT NOCOPY VARCHAR2
, p_batch_id           IN  NUMBER
)
IS
BEGIN

  x_retcode := FND_API.G_RET_STS_SUCCESS;

  INV_THIRD_PARTY_STOCK_CAD_PVT.cons_txn_work
                               (x_retcode
                               ,p_batch_id
                                );

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_retcode := 2;
    x_errbuff := substrb(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE),1,250);
  RAISE;

  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                                ,'consumption_txn_worker'
                                );
        x_retcode := 2;
        x_errbuff  :=
          substrb(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE),1,250);
    RAISE;

    END IF;

END cons_txn_work;

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
, p_batch_size         IN    NUMBER
, p_max_workers        IN    NUMBER
, p_vendor_name        IN    VARCHAR2
, p_vendor_site_id     IN    NUMBER
, p_item_id            IN    NUMBER
, p_org_id             IN    NUMBER
)
IS
BEGIN

  x_retcode := FND_API.G_RET_STS_SUCCESS;

  INV_THIRD_PARTY_STOCK_CAD_PVT.consumption_txn_manager
                               (x_retcode
                               ,p_batch_size
                               ,p_max_workers
                               ,p_vendor_site_id
                               ,p_item_id
                               ,p_org_id
                               );

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_retcode := 2;
    x_errbuff  := substrb(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE),1,250);
  RAISE;

  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                               , 'consumption_txn_manager'
                               );
        x_retcode := 2;
        x_errbuff :=
          substrb(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE),1,250);
    RAISE;

    END IF;

END consumption_txn_manager;

END INV_THIRD_PARTY_STOCK_CP;

/
