--------------------------------------------------------
--  DDL for Package ASP_SERVICE_ALERT_AGENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASP_SERVICE_ALERT_AGENT" AUTHID CURRENT_USER as
/* $Header: aspaesas.pls 120.1 2005/08/19 12:58 axavier noship $ */
---------------------------------------------------------------------------
-- Package Name:   ASP_SERVICE_ALERT_AGENT
---------------------------------------------------------------------------
-- Description:
--      Package contains methods for evaluating the alert condition and
--      finds the subscribers for various alerts.
--
-- Procedures:
--   (see below for specification)
--
-- History:
--   10-Aug-2005  axavier created.
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
--  Procedure: Evaluate_Alerts
--    Finds all the subscribers of this alert for SMS and EMAIL Channels.
--
--  Arguments IN/OUT:
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - function execution mode. This is set by the engine
--               as either 'RUN', 'CANCEL', 'TIMEOUT'
--   resultout -  COMPLETE:SUCCESS or NULL
--                               activity has completed with the indicated
--                               resultout
--
--
--------------------------------------------------------------------------------

PROCEDURE Evaluate_Alerts(
  itemtype  in VARCHAR2,
  itemkey   in VARCHAR2,
  actid     in NUMBER,
  funcmode  in VARCHAR2,
  resultout in out NOCOPY VARCHAR2);

END ASP_SERVICE_ALERT_AGENT;

 

/
