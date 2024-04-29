--------------------------------------------------------
--  DDL for Package INV_THIRD_PARTY_STOCK_AP_MDTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_THIRD_PARTY_STOCK_AP_MDTR" AUTHID CURRENT_USER AS
-- $Header: INVCAPDS.pls 115.3 2002/12/07 00:08:49 pseshadr noship $ --
--+=======================================================================+
--|               Copyright (c) 2002 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVCAPDS.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Consignment Dependency wrapper API                                |
--| HISTORY                                                               |
--|     12/01/2002 pseshadr       Created                                 |
--|     12/01/2002 dherring       Created                                 |
--+========================================================================

--===================
-- PROCEDURES AND FUNCTIONS
--===================

--========================================================================
-- PROCEDURE  : Calculate_Tax         PUBLIC
-- PARAMETERS:
--             p_header_id            PO Header Id
--             p_org_id               Operating Unit
--             p_item_id              Item
--             p_need_by_date         Consumption Date
--             p_ship_to_organization Inventory Organization
--             p_account_id           Accrual account
--             p_tax_code_id          Tax code id from PO Lines
--             p_transaction_quantity Transaction Qty
--             p_po_price             PO price
--             x_tax_rate             Tax rate
--             x_tax_recovery_rate    Recovery rate
--             x_recoverable_Tax      Recoverable tax
--             x_nonrecoverable_tax   Non recoverable tax
-- COMMENT   : Return the recoverable and nonrecoverable tax
--========================================================================
PROCEDURE calculate_tax
( p_header_id               IN NUMBER
, p_line_id                 IN NUMBER
, p_org_id                  IN NUMBER
, p_item_id                 IN NUMBER
, p_need_by_date            IN DATE
, p_ship_to_organization_id IN NUMBER
, p_account_id              IN NUMBER
, p_tax_code_id             IN OUT NOCOPY NUMBER
, p_transaction_quantity    IN NUMBER
, p_po_price                IN NUMBER
, x_tax_rate                OUT NOCOPY NUMBER
, x_tax_recovery_rate       OUT NOCOPY NUMBER
, x_recoverable_tax         OUT NOCOPY NUMBER
, x_nonrecoverable_tax      OUT NOCOPY NUMBER
);

END INV_THIRD_PARTY_STOCK_AP_MDTR;

 

/
