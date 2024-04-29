--------------------------------------------------------
--  DDL for Package ASP_ALERTS_SVC_CONTRACT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASP_ALERTS_SVC_CONTRACT" AUTHID CURRENT_USER as
/* $Header: aspaescs.pls 120.0 2005/08/19 12:57 axavier noship $ */

---------------------------------------------------------------------------
-- Package Name:   ASP_ALERTS_SVC_CONTRACT
---------------------------------------------------------------------------
-- Description:
--  Alerts for expiring service contract is obtained by this
--  Concurrent Program, which periodically looks at the transaction tables
--  in Oracle Service Contract.
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
--  Procedure: Alert_Expiring_SvcContracts
--  Finds all the Active Service Contracts that are expiring in X days.
--
--  Arguments IN/OUT:
--   P_subscription_guid  - which uniquely identifies the subscription.
--   P_event   - encapulates the Event, Parameters and other event related
--               accessor methods.
--
--------------------------------------------------------------------------------


PROCEDURE Alert_Expiring_SvcContracts(
      errbuf     OUT NOCOPY    VARCHAR2,
      retcode    OUT NOCOPY    VARCHAR2,
      p_num_days IN      VARCHAR2);

END ASP_ALERTS_SVC_CONTRACT;

 

/
