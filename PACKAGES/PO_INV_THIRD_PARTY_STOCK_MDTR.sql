--------------------------------------------------------
--  DDL for Package PO_INV_THIRD_PARTY_STOCK_MDTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_INV_THIRD_PARTY_STOCK_MDTR" AUTHID CURRENT_USER AS
-- $Header: POXMTPSS.pls 115.1 2002/12/13 01:24:38 fdubois noship $ --
--+=======================================================================+
--|               Copyright (c) 2002 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     POXMTPSS.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Consiged Inventory PO/INV dependency wrapper API.                 |
--|     This mediator package is used to access INV objects from          |
--|     PO product.                                                       |
--|                                                                       |
--| HISTORY                                                               |
--|     12/09/2002 vchu       Created                                     |
--|     12/12/2002 vma        Added two functions Supplier_Owns_Tps and   |
--|                           Sup_Site_Owns_Tps.                          |
--+=======================================================================+

--=========================================================================
-- PROCEDURES AND FUNCTIONS
--=========================================================================

--=========================================================================
-- FUNCTION  : consumption_trans_exist
-- PARAMETERS: p_transaction_source_id      ID of the parent blanket
--                                          agreement
--             p_inventory_item_id          Item ID of the transaction.
--                                          This field
-- RETURNS   : Return 'Y' if there exists a consumption transaction
--             that is in process for the passed in transaction source
--             agreement ID and and item ID.  The value 'Y' is returned
--             if the passed in item ID is null and if there exists
--             consumption transactions that are in process and match
--             with the passed in transaction source ID.  The value 'N'
--             is returned if no corresponding consumption transactions
--             that are in process are found.
-- COMMENT   : This function is called by PO Summary form to decide
--             whether it can provide the "Finally Close" and "Cancel"
--             actions in the the list of control actions for a PO
--             Header or a PO Line.
--=========================================================================

FUNCTION consumption_trans_exist
( p_transaction_source_id IN NUMBER
, p_item_id               IN NUMBER
)
RETURN VARCHAR2;

--========================================================================
-- FUNCTION     : Supplier_Owns_Tps PUBLIC
-- PARAMETERS   : p_vendor_id IN NUMBER
-- RETURN       : TRUE if on hand consigned stock exist for the supplier;
--                FALSE otherwise.
-- DESCRIPTION  : Check whether on hand consigned stock exists for a given
--                supplier. The function checks whether any supplier site
--                of this supplier owns on hand consigned stock.
--
-- HISTORY      : 18-Nov-2002      Created by VMA
--========================================================================
FUNCTION Supplier_Owns_Tps (p_vendor_id IN NUMBER) RETURN BOOLEAN;

--========================================================================
-- FUNCTION     : Sup_Site_Owns_Tps PUBLIC
-- PARAMETERS   : p_vendor_site_id IN NUMBER
-- RETURN       : TRUE if on hand consigned or VMI stock exist for the
--                supplier site; FALSE otherwise.
-- DESCRIPTION  : Check whether on hand consigned or VMI stock exists for
--                a given supplier site.
--
-- HISTORY      : 18-Nov-2002     Created by VMA
--========================================================================
FUNCTION Sup_Site_Owns_Tps(p_vendor_site_id IN Number) RETURN BOOLEAN;


END PO_INV_THIRD_PARTY_STOCK_MDTR;


 

/
