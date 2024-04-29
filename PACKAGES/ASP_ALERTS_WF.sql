--------------------------------------------------------
--  DDL for Package ASP_ALERTS_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASP_ALERTS_WF" AUTHID CURRENT_USER as
/* $Header: aspalrts.pls 120.1 2005/08/19 12:58 axavier noship $ */
---------------------------------------------------------------------------
-- Package Name:   ASP_ALERTS_WF
---------------------------------------------------------------------------
-- Description:
--    This package contains functions associated with the Workflow Activity
--     node that interfaces with BSA Workflow and used in the Sales Alerts System.
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
--  Procedure: Initiate_Bsa_Alerts
--   This function is associated with the BSA activity node  and will launch the
--   ASP ALERTS workflow Process.
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
--               .
--------------------------------------------------------------------------------

PROCEDURE Initiate_Bsa_Alerts(
  itemtype  in VARCHAR2,
  itemkey   in VARCHAR2,
  actid     in NUMBER,
  funcmode  in VARCHAR2,
  resultout in out NOCOPY VARCHAR2);



END ASP_ALERTS_WF;

 

/
