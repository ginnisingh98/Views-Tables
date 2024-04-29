--------------------------------------------------------
--  DDL for Package INV_THIRD_PARTY_STOCK_CAD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_THIRD_PARTY_STOCK_CAD_PVT" AUTHID CURRENT_USER AS
/* $Header: INVCADVS.pls 115.1 2002/12/20 00:00:37 pseshadr noship $ */
--+=======================================================================+
--|               Copyright (c) 2002 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVCADVS.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Create Consumption Advice                                         |
--| HISTORY                                                               |
--|     11/29/2002 David Herring       created                            |
--+========================================================================

--===================
-- CONSTANTS
--===================

G_LOG_ERROR                   CONSTANT NUMBER := 5;
G_LOG_EXCEPTION               CONSTANT NUMBER := 4;
G_LOG_EVENT                   CONSTANT NUMBER := 3;
G_LOG_PROCEDURE               CONSTANT NUMBER := 2;
G_LOG_STATEMENT               CONSTANT NUMBER := 1;


--===================
-- PROCEDURES AND FUNCTIONS
--===================

--========================================================================
-- PROCEDURE : Consumption_Txn_Manager     PUBLIC
-- PARAMETERS: x_retcode            OUT   return status
--             x_errbuff            OUT   return error messages
--             p_batch_id           IN    Organization Hierarchy
--
-- COMMENT   : This procedure will set in motion the creation of
--             one or more consumption advices
--=========================================================================
PROCEDURE  consumption_txn_manager
( x_retcode            OUT NOCOPY VARCHAR2
, p_batch_size         IN    NUMBER
, p_max_workers        IN    NUMBER
, p_vendor_site_id     IN    NUMBER
, p_inventory_item_id  IN    NUMBER
, p_organization_id    IN    NUMBER
);

--========================================================================
-- PROCEDURE : Consumption_Txn_Worker     PUBLIC
-- PARAMETERS: x_retcode            OUT   return status
--             x_errbuff            OUT   return error messages
--             p_batch_id           IN    Organization Hierarchy
--
-- COMMENT   : This procedure will set in motion the creation of
--             one consumption advice
--=========================================================================
PROCEDURE cons_txn_work
( x_retcode            OUT NOCOPY VARCHAR2
, p_batch_id           IN  NUMBER
);

--========================================================================
-- PROCEDURE  : Update_Consumption            PUBLIC
-- PARAMETERS:
--             p_consumption_po_header_id    PO Header Id
--             p_consumption_release_id      Release id
--             p_error_code                  Error code if any
--             p_batch_id                    batch id from concurrent pgm
--             p_consumption_processed_flag  E if error,else Y
--             p_rate                        exchange rate if applicable
--             p_transaction_date            Txn Date
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
);

END INV_THIRD_PARTY_STOCK_CAD_PVT;

 

/
