--------------------------------------------------------
--  DDL for Package INV_THIRD_PARTY_STOCK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_THIRD_PARTY_STOCK_PVT" AUTHID CURRENT_USER AS
-- $Header: INVVTPSS.pls 120.2.12010000.1 2008/07/24 01:53:01 appldev ship $ --
--+=======================================================================+
--|               Copyright (c) 2002 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVVTPSS.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Consignment Financial Document API                                |
--| HISTORY                                                               |
--|     09/30/2002 pseshadr       Created                                 |
--      JUl-29-2002 rajkrish   FP-J projects updates
--+========================================================================


--===================
-- PROCEDURES AND FUNCTIONS
--===================

--========================================================================
-- PROCEDURE : Process_Financial_Info PUBLIC
-- PARAMETERS: p_mtl_transaction_id          Material transaction id issue
--             p_rct_transaction_id          Material transaction rct side
--             p_transaction_source_type_id  Txn source Type
--             p_transaction_action_id       Txn action
--             p_inventory_item_id           item
--             p_owning_organization_id      owning organization
--             p_owning_tp_type              owning tp type
--             p_organization_id             Inv. organization
--             p_transaction_quantity        Transaction Quantity
--             p_transaction_source_id       Txn source
--             p_item_revision               Revision
--             x_po_price                    PO price
--             x_account_id                  Accrual Account
--             x_rate                        Exchange Rate
--             x_rate_type                   Exchange Rate type
--             x_rate_date                   Exchange rate date
--             x_currency_code               Currency Code
--             x_message_count
--             x_message_data
--             x_return_status               status
--             p_secondary_transaction_qty   Transaction quantity
--                                           in secondary uom
-- COMMENT   : Process Finanical information for consigned transactions
--             This procedure is invoked by the Inventory TM during
--             the insert of consigned transactions from MMTT to MMT
--========================================================================
PROCEDURE Process_Financial_Info
( p_mtl_transaction_id         IN   NUMBER
, p_rct_transaction_id         IN   NUMBER
, p_transaction_source_type_id IN   NUMBER
, p_transaction_action_id      IN   NUMBER
, p_inventory_item_id          IN   NUMBER
, p_owning_organization_id     IN   NUMBER
, p_xfr_owning_organization_id IN   NUMBER
, p_organization_id            IN   NUMBER
, p_transaction_quantity       IN   NUMBER
, p_transaction_date           IN   DATE
, p_transaction_source_id      IN OUT  NOCOPY NUMBER
, p_item_revision              IN   VARCHAR2 DEFAULT NULL
, x_po_price                   OUT  NOCOPY NUMBER
, x_account_id                 OUT  NOCOPY NUMBER
, x_rate                       OUT  NOCOPY NUMBER
, x_rate_type                  OUT  NOCOPY VARCHAR2
, x_rate_date                  OUT  NOCOPY DATE
, x_currency_code              OUT  NOCOPY VARCHAR2
, x_msg_count                  OUT  NOCOPY NUMBER
, x_msg_data                   OUT  NOCOPY VARCHAR2
, x_return_status              OUT  NOCOPY VARCHAR2
, p_secondary_transaction_qty  IN   NUMBER --INVCONV
);

--========================================================================
-- PROCEDURE : Process_Financial_Info OVERLOAD API
-- PARAMETERS: p_mtl_transaction_id          Material transaction id issue
--             p_rct_transaction_id          Material transaction rct side
--             p_transaction_source_type_id  Txn source Type
--             p_transaction_action_id       Txn action
--             p_inventory_item_id           item
--             p_owning_organization_id      owning organization
--             p_owning_tp_type              owning tp type
--             p_organization_id             Inv. organization
--             p_transaction_quantity        Transaction Quantity
--             p_transaction_source_id       Txn source
--             p_item_revision               RevisionS
--             p_calling_action
--                Will be used to differentiate if the
--                calling program is DIAGNOSTICS or not
--             x_po_price                    PO price
--             x_account_id                  Accrual Account
--             x_rate                        Exchange Rate
--             x_rate_type                   Exchange Rate type
--             x_rate_date                   Exchange rate date
--             x_currency_code               Currency Code
--             x_message_count
--             x_message_data
--             x_return_status               status
-- COMMENT   : This procedure will be used by the
--             INV Consigned Inventory Diagnostics program
--             This procedure will inturn invoke the process_financial_info
--             to validate the moqd data waiting for ownership transfer
--             transaction process.
--             The process_financial_info API will also be modified
--             to make sure that it does not insert/update
--             any records as such and just perform and return
--             the validation results

--             This API will inturn the call the original API
--              Process_Financial_Info
--========================================================================
PROCEDURE Process_Financial_Info
( p_mtl_transaction_id         IN   NUMBER
, p_rct_transaction_id         IN   NUMBER
, p_transaction_source_type_id IN   NUMBER
, p_transaction_action_id      IN   NUMBER
, p_inventory_item_id          IN   NUMBER
, p_owning_organization_id     IN   NUMBER
, p_xfr_owning_organization_id IN   NUMBER
, p_organization_id            IN   NUMBER
, p_transaction_quantity       IN   NUMBER
, p_transaction_date           IN   DATE
, p_transaction_source_id      IN   OUT  NOCOPY NUMBER
, p_item_revision              IN   VARCHAR2 DEFAULT NULL
, p_calling_action             IN   VARCHAR2
, x_po_price                   OUT  NOCOPY NUMBER
, x_account_id                 OUT  NOCOPY NUMBER
, x_rate                       OUT  NOCOPY NUMBER
, x_rate_type                  OUT  NOCOPY VARCHAR2
, x_rate_date                  OUT  NOCOPY DATE
, x_currency_code              OUT  NOCOPY VARCHAR2
, x_msg_count                  OUT  NOCOPY NUMBER
, x_msg_data                   OUT  NOCOPY VARCHAR2
, x_return_status              OUT  NOCOPY VARCHAR2
, x_error_code                 OUT  NOCOPY VARCHAR2
, x_po_header_id               OUT  NOCOPY NUMBER
, x_purchasing_UOM             OUT  NOCOPY VARCHAR2
, x_primary_UOM                OUT  NOCOPY VARCHAR2
);


END INV_THIRD_PARTY_STOCK_PVT;

/
