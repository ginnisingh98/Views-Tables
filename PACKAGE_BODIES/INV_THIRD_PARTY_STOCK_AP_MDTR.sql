--------------------------------------------------------
--  DDL for Package Body INV_THIRD_PARTY_STOCK_AP_MDTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_THIRD_PARTY_STOCK_AP_MDTR" AS
-- $Header: INVCAPDB.pls 120.0 2005/05/25 04:49:53 appldev noship $
--+=======================================================================+
--|               Copyright (c) 2002 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVAPDB.pls                                                       |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    Consignment Dependency wrapper API                                 |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|     Calculate_Tax                                                     |
--|                                                                       |
--| HISTORY                                                               |
--|     12/01/02 pseshadr  Created                                        |
--|     12/01/02 dherring  Created                                        |
--+========================================================================


--===================
-- PRIVATE PROCEDURES
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

PROCEDURE Calculate_Tax
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
)
IS

BEGIN

  NULL;

END Calculate_Tax;

END INV_THIRD_PARTY_STOCK_AP_MDTR;

/
