--------------------------------------------------------
--  DDL for Package ASP_ALERTS_SUBS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASP_ALERTS_SUBS" AUTHID CURRENT_USER as
/* $Header: aspasubs.pls 120.1 2005/08/19 12:58 axavier noship $ */

---------------------------------------------------------------------------
-- Package Name:   ASP_ALERTS_SUBS
---------------------------------------------------------------------------
-- Description:
--      Generic Subscription Package for Sales Alerts Related Business Events.
--
-- Procedures:
--   (see below for specification)
--
-- History:
--   08-Aug-2005  axavier created.
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
--  Procedure: Initiate_Alerts
--   Generic Subscription Function for Sales Alerts Related Business Events.
--   This function will be called by the BES if a Service Request is Escalated.
--   This could be used by the end-customer for extending the Alerting System.
--
--  Arguments IN/OUT:
--   P_subscription_guid  - which uniquely identifies the subscription.
--   P_event   - encapulates the Event, Parameters and other event related
--               accessor methods.
--
--------------------------------------------------------------------------------


FUNCTION Initiate_Alerts(
  P_subscription_guid  in RAW,
  P_event              in out NOCOPY WF_EVENT_T) RETURN VARCHAR2;

END ASP_ALERTS_SUBS;

 

/
