--------------------------------------------------------
--  DDL for Package AP_SUPPLIERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_SUPPLIERS_PKG" AUTHID CURRENT_USER AS
-- $Header: apsupbas.pls 120.2 2004/10/29 19:04:15 pjena noship $

-- ==================================================================
-- |                Copyright (c) 1999 Oracle Corporation
-- |                   Redwood Shores, California, USA
-- |                        All rights reserved.
-- +==================================================================
-- |  Name
-- |    apsupbas.pls
-- |
-- |  Description
-- |    Package Specification for Supplier Master/Site and Bank
-- |    account conversion.
-- |
-- |  History
-- |    Created
-- |    27/DEc/1999   Rajesh Krishnan RAJKRISH
-- |    01/19/2000    tsimmond  Updated
-- |    11/28/2001    tsimmond  updated
-- ==================================================================


--========================================================================
-- PROCEDURE : ap_update_supplier_and_bank PUBLIC
-- PARAMETERS:
--
-- COMMENT   : Procedure  to update the invoice currency, payment
--    currency and invoice amount limit for each supplier and
--    supplier site. It will also update the currency code,
--    max outlay, max check amount and min check amount for
--    supplier bank accounts.
--
--    The Bank accounst are converted only at the
--    site conversion stage.
--    The bank accounts are converted to EURO only for the
--    following conditions
--    a) The Primary Usage Flag = 'Y'
--    b) The Bank Account Currency Code matches the
--        Site Invoice currency being processed.
--========================================================================
PROCEDURE ap_update_supplier_and_bank
( p_vendor_id             IN NUMBER
, p_vendor_site_id        IN NUMBER
, p_rounding_type         IN VARCHAR2
, p_rounding_factor       IN VARCHAR2
);

END AP_SUPPLIERS_PKG;

 

/
