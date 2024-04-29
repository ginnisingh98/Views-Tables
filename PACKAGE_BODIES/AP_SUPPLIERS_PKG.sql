--------------------------------------------------------
--  DDL for Package Body AP_SUPPLIERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_SUPPLIERS_PKG" AS
-- $Header: apsupbab.pls 120.2 2004/10/29 19:03:01 pjena noship $

-- +==================================================================+
-- |                Copyright (c) 1999 Oracle Corporation
-- |                   Redwood Shores, California, USA
-- |                        All rights reserved.
-- +==================================================================+
-- |  Name
-- |    apsupbab.pls
-- |
-- |  Description
-- |    Package Body
-- |
-- |  History
-- |    27-NOV-99  Created by Rajkrish
-- |    01/19/2000 tsimmond Updated
-- |    18/04/2000 Rajkrish Updated - Bug Fix 1172996
-- |    10/09/2001 tsimmond updated -Bug fix 2041933
-- |    11/28/2001 tsimmond  updated, added dbrv
-- |    03/25/2002 tsimmond updated, code removed for patch 'H' remove
-- ==================================================================+


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
)
IS
BEGIN

  NULL;

END ap_update_supplier_and_bank;

END AP_SUPPLIERS_PKG;

/
