--------------------------------------------------------
--  DDL for Package ASP_ORDER_CONTENT_PROVIDER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASP_ORDER_CONTENT_PROVIDER" AUTHID CURRENT_USER as
/* $Header: aspaorcs.pls 120.0 2005/08/19 12:57 axavier noship $ */
---------------------------------------------------------------------------
-- Package Name:   ASP_ORDER_CONTENT_PROVIDER
---------------------------------------------------------------------------
-- Description:
--      Provides content for the Sales Agreement Alert.
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
--  Procedure: Create_Content
--   Provides content for the Service Alert.
--
--  Arguments IN/OUT:
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - function execution mode. This is set by the engine
--               as either 'RUN', 'CANCEL', 'TIMEOUT'
--   resultout - COMPLETE:SUCCESS or NULL
--                               activity has completed with the indicated
--                               result
--
--------------------------------------------------------------------------------

PROCEDURE Create_Content(
  itemtype  in VARCHAR2,
  itemkey   in VARCHAR2,
  actid     in NUMBER,
  funcmode  in VARCHAR2,
  resultout in out NOCOPY VARCHAR2);

END ASP_ORDER_CONTENT_PROVIDER;

 

/
