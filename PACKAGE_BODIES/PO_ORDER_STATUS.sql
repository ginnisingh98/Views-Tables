--------------------------------------------------------
--  DDL for Package Body PO_ORDER_STATUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_ORDER_STATUS" AS
/* $Header: CLNPOSB.pls 120.0 2006/07/03 08:59:42 amchaudh noship $ */
-- Package
--   PO_ORDER_STATUS
--
-- Purpose
--    Specification of package body: PO_ORDER_STATUS.
--    Initially we have used this package for show sales order inbound
--    But we thought that we will not use PO_ name any more
--    Now we have decommissioned this file
--    Use CLNPOSSS.pls and CLNPOSSB.pls instead of this file
--
-- History
--    Aug-06-2002       Viswanthan Umapathy         Created
--    Dec-10-2003       Kodanda Ram                 Stubbed out

   -- Name
   --    DUMMY
   -- Purpose
   --    Not used
   -- Arguments
   --   Dummy
   -- Notes
   --    Dummy procedure

      PROCEDURE DUMMY(
         p_dummy                     IN VARCHAR2)
      IS
      BEGIN
        NULL; -- Do nothing
      END;


END PO_ORDER_STATUS;

/
