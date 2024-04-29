--------------------------------------------------------
--  DDL for Package ASP_ALERT_ENGINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASP_ALERT_ENGINE" AUTHID CURRENT_USER as
/* $Header: aspaengs.pls 120.1 2005/08/19 12:58 axavier noship $ */
---------------------------------------------------------------------------
-- Package Name:   ASP_ALERT_ENGINE
---------------------------------------------------------------------------
-- Description:
--   Core Alert Engine Package for Sales Alerts Backend Workflow Processing.
--   This package is used by the workflow activity nodes.
--
-- Procedures:
--   (see below for specification)
--
-- History:
--   08-Aug-2005  axavier created.
---------------------------------------------------------------------------

/*-------------------------------------------------------------------------*
 |                             Public Constants
 *-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 |                             Public Datatypes
 *-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 |                             Public Variables
 *-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 |                             Public Routines
 *-------------------------------------------------------------------------*/

--------------------------------------------------------------------------------
--
--  Procedure: Get_Alert_Agent
--   This is a factory method, which produces appropriate agents based on the
--   Alert Types.
--
--  Arguments IN/OUT:
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - function execution mode. This is set by the engine
--               as either 'RUN', 'CANCEL', 'TIMEOUT'
--   resultout -
--               ORDER_ALERT_AGENT if Alert is related to Order
--               SVCCONTRACT_ALERT_AGENT if Alert is related to Service Contract
--               INVOICE_ALERT_AGENT if Alert is related to Invoice
--               SERVICE_ALERT_AGENT if Alert is related to Service
--               CUSTOM if Alert is not supported out of the box.
--                      Custom Agent to process the request.
--
--------------------------------------------------------------------------------

PROCEDURE Get_Alert_Agent(
  itemtype  in VARCHAR2,
  itemkey   in VARCHAR2,
  actid     in NUMBER,
  funcmode  in VARCHAR2,
  resultout in out NOCOPY VARCHAR2);

--------------------------------------------------------------------------------
--
--  Procedure: Get_Content_Provider
--   This is a factory method, which produces appropriate providers based on the
--   Alert Types.
--
--  Arguments IN/OUT:
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - function execution mode. This is set by the engine
--               as either 'RUN', 'CANCEL', 'TIMEOUT'
--   resultout -
--               ORDER_CONTENT_PROVIDER if Alert is related to Order
--               SVCCONTRACT_CONTENT_PROVIDER if Alert is related to Service Contract
--               INVOICE_CONTENT_PROVIDER if Alert is related to Invoice
--               SERVICE_CONTENT_PROVIDER if Alert is related to Service
--               CUSTOM if Alert is not supported out of the box.
--                      Custom Provider to process the request.
--
--------------------------------------------------------------------------------

PROCEDURE Get_Content_Provider(
  itemtype  in VARCHAR2,
  itemkey   in VARCHAR2,
  actid     in NUMBER,
  funcmode  in VARCHAR2,
  resultout in out NOCOPY VARCHAR2);


--------------------------------------------------------------------------------
--
--  Procedure: Get_Delivery_Agent
--   This is a factory method, which produces appropriate agents based on the
--   Alert Types.
--
--  Arguments IN/OUT:
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - function execution mode. This is set by the engine
--               as either 'RUN', 'CANCEL', 'TIMEOUT'
--   resultout -
--               ASP_DELIVERY_AGENT if Alert is related to Order, Service Contract,
--               Invoice, and Service Request.
--               CUSTOM if Alert is not supported out of the box.
--                      Custom Agent to process the request.
--
--------------------------------------------------------------------------------

PROCEDURE Get_Delivery_Agent(
  itemtype  in VARCHAR2,
  itemkey   in VARCHAR2,
  actid     in NUMBER,
  funcmode  in VARCHAR2,
  resultout in out NOCOPY VARCHAR2);


--------------------------------------------------------------------------------
--
--  Procedure: NOOP
--   This is a No Operation method, which does nothing. This is the mathod call
--   associated with the Custom Activity Node, that the end customer would use for
--   extensibility.
--
--  Arguments IN/OUT:
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - function execution mode. This is set by the engine
--               as either 'RUN', 'CANCEL', 'TIMEOUT'
--   resultout - NULL
--
--
--------------------------------------------------------------------------------

PROCEDURE NOOP(
    itemtype  in VARCHAR2,
    itemkey   in VARCHAR2,
    actid     in NUMBER,
    funcmode  in VARCHAR2,
    resultout in out NOCOPY VARCHAR2);

------------------------------------------------------------------------------
-- Alerts_Selector
--   This procedure sets up the responsibility and organization context for
--   multi-org sensitive code.
------------------------------------------------------------------------------

PROCEDURE Alerts_Selector(
  itemtype      IN      VARCHAR2,
  itemkey       IN      VARCHAR2,
  actid         IN      NUMBER,
  funcmode      IN      VARCHAR2,
  resultout     OUT     NOCOPY VARCHAR2);

END ASP_ALERT_ENGINE;

 

/
