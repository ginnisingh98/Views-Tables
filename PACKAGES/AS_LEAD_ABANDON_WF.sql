--------------------------------------------------------
--  DDL for Package AS_LEAD_ABANDON_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_LEAD_ABANDON_WF" AUTHID CURRENT_USER as
/* $Header: asxslabs.pls 115.2 2002/11/06 00:49:25 appldev ship $ */


-- PROCEDURE StartProcess
--
-- DESCRIPTION: Procedure is called to start the structured inbound workflow
--              process.  Assigns attributes such as message ID, message size,
--              sender name, domain name, user id , pwd and priority.  Creates
--              and kicks of the workflow.
--
-- IN
--     sales_lead_id - unique identifier of the sales_lead.
-- OUT
--
-- None

PROCEDURE StartProcess(
    p_sales_lead_id	         in INTEGER,
    p_assigned_resource_id   in INTEGER,
    x_return_status          in out VARCHAR2,
    x_item_type              out VARCHAR2,
    x_item_key               out VARCHAR2     ) ;


-- PROCEDURE GetAbandonTime
--
-- DESCRIPTION Retrieves Time to abandon lead
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode.  Set by the engine as either 'RUN',
--               'CANCEL', or 'TIMEOUT'
-- OUT
-- result
--      - COMPLETE[:<result>]
--           activity has completed with the indicated result
--      - WAITING
--          activity is waiting for additional transitions
--      - DEFERED
--          execution should be defered to background
--      - NOTIFIED[:<notification_id>:<assigned_user>]
--          activity has notified an external entity that this
--          step must be performed.  A call to wf_engine.CompleteActivty
--          will signal when this step is complete.  Optional
--          return of notification ID and assigned user.
--      - ERROR[:<error_code>]
--          function encountered an error.
-- None

PROCEDURE GetAbandonTime (
    itemtype        in VARCHAR2,
    itemkey         in VARCHAR2,
    actid	          in NUMBER,
    funcmode        in VARCHAR2,
    result          out VARCHAR2 );


-- PROCEDURE GetAbandonAction
--
-- DESCRIPTION Retrieves abandon decision
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode.  Set by the engine as either 'RUN',
--               'CANCEL', or 'TIMEOUT'
-- OUT
-- result
--      - COMPLETE[:<result>]
--           activity has completed with the indicated result
--      - WAITING
--          activity is waiting for additional transitions
--      - DEFERED
--          execution should be defered to background
--      - NOTIFIED[:<notification_id>:<assigned_user>]
--          activity has notified an external entity that this
--          step must be performed.  A call to wf_engine.CompleteActivty
--          will signal when this step is complete.  Optional
--          return of notification ID and assigned user.
--      - ERROR[:<error_code>]
--          function encountered an error.
-- None

PROCEDURE GetAbandonAction (
    itemtype      in VARCHAR2,
    itemkey       in VARCHAR2,
    actid         in NUMBER,
    funcmode      in VARCHAR2,
    result        out VARCHAR2 );


-- PROCEDURE GetResourceGroup
--
-- DESCRIPTION Retrieves abandon decision
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode.  Set by the engine as either 'RUN',
--               'CANCEL', or 'TIMEOUT'
-- OUT
-- result
--      - COMPLETE[:<result>]
--           activity has completed with the indicated result
--      - WAITING
--          activity is waiting for additional transitions
--      - DEFERED
--          execution should be defered to background
--      - NOTIFIED[:<notification_id>:<assigned_user>]
--          activity has notified an external entity that this
--          step must be performed.  A call to wf_engine.CompleteActivty
--          will signal when this step is complete.  Optional
--          return of notification ID and assigned user.
--      - ERROR[:<error_code>]
--          function encountered an error.
-- None

PROCEDURE GetResourceGroup (
    itemtype        in VARCHAR2,
    itemkey         in VARCHAR2,
    actid           in NUMBER,
    funcmode        in VARCHAR2,
    result          out VARCHAR2 );

END AS_LEAD_ABANDON_WF ;


 

/
