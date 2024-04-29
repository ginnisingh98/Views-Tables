--------------------------------------------------------
--  DDL for Package Body INV_SUPPLIER_OWNED_STOCK_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_SUPPLIER_OWNED_STOCK_GRP" AS
--$Header: INVGTPSB.pls 115.3 2003/01/23 01:09:55 vma noship $
--============================================================================+
--|                    Copyright (c) 2002 Oracle Corporation                  |
--|                       Redwood Shores, California, USA                     |
--|                            All rights reserved.                           |
--============================================================================+
--|                                                                           |
--|  FILENAME :            INVGTPSS.pls                                       |
--|                                                                           |
--|  DESCRIPTION:          OBSOLETED FILE                                     |
--|                        This package is used to check on hand consigned    |
--|                        or VMI stock of suppliers                          |
--|                                                                           |
--|  HISTORY:              18-NOV-2002  vma  Created                          |
--|                        22-Jan-2003  vma  Obsolete the file by replacing   |
--|                                          functions with empty stubs.      |
--|                                          Active functions are now in file |
--|                                          INVMPOXB.pls                     |
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
-- CHANGE HISTORY : 18-Nov-2002   vma   Created
--                  22-Jan-2003   vma   Obsoleted
--========================================================================
FUNCTION supplier_owns_tps (p_vendor_id IN NUMBER) RETURN BOOLEAN IS
BEGIN
  RETURN FALSE;
END supplier_owns_tps;


--========================================================================
-- FUNCTION     : SUP_SITE_OWNS_TPS PUBLIC
-- PARAMETERS   : p_vendor_site_id IN NUMBER
-- RETURN       : TRUE if on hand consigned or VMI stock exist for the
--                supplier site; FALSE otherwise.
-- DESCRIPTION  : Check whether on hand consigned or VMI stock exists for
--                a given supplier site.
--
-- CHANGE HISTORY : 18-Nov-2002  vma   Created
--                  22-Jan-2003  vma   Obsoleted
--========================================================================
FUNCTION sup_site_owns_tps(p_vendor_site_id IN Number) RETURN BOOLEAN IS
BEGIN
  RETURN FALSE;
END sup_site_owns_tps;


END INV_SUPPLIER_OWNED_STOCK_GRP;

/
