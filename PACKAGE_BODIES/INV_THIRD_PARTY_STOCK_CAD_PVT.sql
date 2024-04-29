--------------------------------------------------------
--  DDL for Package Body INV_THIRD_PARTY_STOCK_CAD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_THIRD_PARTY_STOCK_CAD_PVT" AS
-- $Header: INVCADVB.pls 115.5 2002/12/20 00:03:52 pseshadr noship $
--+=======================================================================+
--|               Copyright (c) 2002 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVCADVB.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    Create Consumption Advice Concurrent Program                       |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|     Update_Consumption                                                |
--|     Consumption_Txn_Manager                                           |
--|     Load Consumption                                                  |
--|     Load_Summarized_Quantity                                          |
--|     Delete Record                                                     |
--|     Batch Allocation                                                  |
--|     Submit Worker                                                     |
--|     Wait_For_All_Workers                                              |
--|     Wait_For_Worker                                                   |
--|     Has_Worker_Completed                                              |
--|     Generate_Batch_Id                                                 |
--|     Generate_Log                                                      |
--|     Log                                                               |
--|     Log_Initialize                                                    |
--|     Cons_Txn_Worker                                                   |
--|                                                                       |
--| HISTORY                                                               |
--|     11/29/02 David Herring   Created procedure                        |
--+========================================================================

--===================
-- GLOBALS
--===================

G_PKG_NAME CONSTANT    VARCHAR2(30) := 'INV_THIRD_PARTY_STOCK_CAD_PVT';
g_submit_failure_exc   EXCEPTION;

--===================
-- PRIVATE PROCEDURES
--===================

--========================================================================
-- PROCEDURE  : Update_Consumption            PRIVATE
-- PARAMETERS:
--             p_consumption_po_header_id    PO Header Id
--             p_consumption_release_id      Release id
--             p_error_code                  Error code if any
--             p_batch_id                    batch id from concurrent pgm
--             p_consumption_processed_flag  E if error,else Y
--             p_accrual_account_id          Accrual account
--             p_variance_account_id         Variance account
--             p_charg_account_id            Charge account
-- COMMENT   : Update  mtl_consumption_transactions table
--             This procedure is called by the Create_Consumption_Advice
--             procedures after creation of the
--             document. Update the table with the appropriate release
--             info or the po_header info.
--========================================================================
PROCEDURE Update_Consumption
( p_consumption_po_header_id       IN   NUMBER
, p_consumption_release_id         IN   NUMBER
, p_error_code                     IN   VARCHAR2
, p_batch_id                       IN   NUMBER
, p_transaction_source_id          IN   NUMBER
, p_consumption_processed_flag     IN   VARCHAR2
, p_accrual_account_id             IN   NUMBER
, p_variance_account_id            IN   NUMBER
, p_charge_account_id              IN   NUMBER
)
IS
BEGIN
  NULL;
END Update_Consumption;



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
, p_batch_id            IN NUMBER
)
IS

BEGIN

  x_retcode := FND_API.G_RET_STS_SUCCESS;

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
, p_batch_size         IN    NUMBER
, p_max_workers        IN    NUMBER
, p_vendor_site_id     IN    NUMBER
, p_inventory_item_id  IN    NUMBER
, p_organization_id    IN    NUMBER
)
IS


BEGIN

  x_retcode := FND_API.G_RET_STS_SUCCESS;

END consumption_txn_manager;

END INV_THIRD_PARTY_STOCK_CAD_PVT;

/
