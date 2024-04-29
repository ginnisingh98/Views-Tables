--------------------------------------------------------
--  DDL for Package INV_SUPPLIER_OWNED_STOCK_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_SUPPLIER_OWNED_STOCK_GRP" AUTHID CURRENT_USER AS
--$Header: INVGTPSS.pls 115.0 2002/11/19 21:37:02 vma noship $
--============================================================================+
--|                    Copyright (c) 2002 Oracle Corporation                  |
--|                       Redwood Shores, California, USA                     |
--|                            All rights reserved.                           |
--============================================================================+
--|                                                                           |
--|  FILENAME :            INVSTPSS.pls                                       |
--|                                                                           |
--|  DESCRIPTION:          This package is used to check on hand consigned    |
--|                        or VMI stock of suppliers                          |
--|                                                                           |
--|  HISTORY:              18-NOV-2002 : vma                                  |
--|===========================================================================+

--========================================================================
-- FUNCTION     : SUPPLIER_OWNS_TPS PUBLIC
-- PARAMETERS   : p_vendor_id IN NUMBER
-- RETURN       : TRUE if on hand consigned stock exist for the supplier;
--                FALSE otherwise.
-- DESCRIPTION  : Check whether on hand consigned stock exists for a given
--                supplier. The function checks whether any supplier site
--                of this supplier owns on hand consigned stock.
--
-- CHANGE HISTORY : 18-Nov-2002      Created by VMA
--========================================================================
FUNCTION supplier_owns_tps (p_vendor_id IN NUMBER) RETURN BOOLEAN;


--========================================================================
-- FUNCTION     : SUP_SITE_OWNS_TPS PUBLIC
-- PARAMETERS   : p_vendor_site_id IN NUMBER
-- RETURN       : TRUE if on hand consigned or VMI stock exist for the
--                supplier site; FALSE otherwise.
-- DESCRIPTION  : Check whether on hand consigned or VMI stock exists for
--                a given supplier site.
--
-- CHANGE HISTORY : 18-Nov-2002     Created by VMA
--========================================================================
FUNCTION sup_site_owns_tps(p_vendor_site_id IN Number) RETURN BOOLEAN;


END INV_SUPPLIER_OWNED_STOCK_GRP;

 

/
