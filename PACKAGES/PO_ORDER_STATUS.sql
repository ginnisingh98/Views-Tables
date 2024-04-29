--------------------------------------------------------
--  DDL for Package PO_ORDER_STATUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_ORDER_STATUS" AUTHID CURRENT_USER AS
/* $Header: CLNPOSS.pls 120.0 2006/07/03 08:59:15 amchaudh noship $ */
-- Package
--   PO_ORDER_STATUS
--
-- Purpose
--    Initially we have used this package for show sales order inbound
--    But we thought that we will not use PO_ name any more
--    Now we have decommissioned this file
--    Use CLNPOSSS.pls and CLNPOSSB.pls instead of this file
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
         p_dummy                     IN VARCHAR2);



END PO_ORDER_STATUS;

 

/
