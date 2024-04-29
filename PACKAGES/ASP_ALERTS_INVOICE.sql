--------------------------------------------------------
--  DDL for Package ASP_ALERTS_INVOICE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASP_ALERTS_INVOICE" AUTHID CURRENT_USER as
/* $Header: aspaodis.pls 120.0 2005/08/19 12:57 axavier noship $ */

---------------------------------------------------------------------------
-- Package Name:   ASP_ALERTS_INVOICE
---------------------------------------------------------------------------
-- Description:
--  Alerts for overdue invoice is obtained by this
--  Concurrent Program, which periodically looks at the transaction tables
--  in Oracle Collections.
--
-- Procedures:
--   (see below for specification)
--
-- History:
--   16-Aug-2005  axavier created.
---------------------------------------------------------------------------

/*-------------------------------------------------------------------------*
 |                             PUBLIC CONSTANTS
 *-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 |                             PUBLIC DATATYPES
 *-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 |                             PUBLIC VARIABLES
 *-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 |                             PUBLIC ROUTINES
 *-------------------------------------------------------------------------*/

--------------------------------------------------------------------------------
--
--  Procedure: Alert_Overdue_Invoice
--  Finds all the overdue invoices.
--
--  Arguments IN/OUT:
--   P_subscription_guid  - which uniquely identifies the subscription.
--   P_event   - encapulates the Event, Parameters and other event related
--               accessor methods.
--
--------------------------------------------------------------------------------


PROCEDURE Alert_Overdue_Invoice(
      errbuf     OUT NOCOPY    VARCHAR2,
      retcode    OUT NOCOPY    VARCHAR2);

END ASP_ALERTS_INVOICE;

 

/
