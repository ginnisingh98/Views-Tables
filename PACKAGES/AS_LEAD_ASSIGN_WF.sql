--------------------------------------------------------
--  DDL for Package AS_LEAD_ASSIGN_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_LEAD_ASSIGN_WF" AUTHID CURRENT_USER AS
/* $Header: asxlasns.pls 115.2 2002/11/06 00:43:06 appldev ship $ */

-- Start of Comments
-- Package name     : AS_LEAD_ASSIGN_WF
-- Purpose          : Sales Leads Assignment Workflow Code
-- NOTE             :
-- History          :
-- END of Comments


-- PROCEDURE StartProcess
--
-- StartProcess is called to start the structured inbound workflow process.
-- Assigns attributes such as message ID, message size, sender name, domain
-- name, user id , pwd and priority.  Creates and kicks of the workflow.
--
-- IN
--   sales_lead_id - unique identifier of the sales lead.
-- OUT
--
-- None

PROCEDURE StartProcess(
    p_sales_lead_id             in  INTEGER,
    p_assigned_resource_id      in  INTEGER,
    x_return_status     in      out VARCHAR2,
    x_item_type                 out VARCHAR2,
    x_item_key                  out VARCHAR2
    );


-- PROCEDURE CheckAssignID
--
-- Checks to see if the inbound sales lead has an ID assigned to it.
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode.
--               Set by the engine as either 'RUN', 'CANCEL', or 'TIMEOUT'
-- OUT
-- result:
--   COMPLETE[:<result>] - activity has completed with the indicated result
--   WAITING - activity is waiting for additional transitions
--   DEFERED - execution should be defered to background
--   NOTIFIED[:<notification_id>:<assigned_user>] -
--          activity has notified an external entity that this
--          step must be performed.  A call to wf_engine.CompleteActivty
--          will signal when this step is complete.  Optional
--          return of notification ID and assigned user.
--   ERROR[:<error_code>] - function encountered an error.
-- None

PROCEDURE CheckAssignID(
    itemtype                   in VARCHAR2,
    itemkey                    in VARCHAR2,
    actid                      in NUMBER,
    funcmode                   in VARCHAR2,
    result                     out VARCHAR2
    );


-- PROCEDURE AssignLead
--
-- Assigns sales lead to given resource id
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode.
--               Set by the engine as either 'RUN', 'CANCEL', or 'TIMEOUT'
-- OUT
-- result
--   COMPLETE[:<result>] - activity has completed with the indicated result
--   WAITING - activity is waiting for additional transitions
--   DEFERED - execution should be defered to background
--   NOTIFIED[:<notification_id>:<assigned_user>] -
--          activity has notified an external entity that this
--          step must be performed.  A call to wf_engine.CompleteActivty
--          will signal when this step is complete.  Optional
--          return of notification ID and assigned user.
--   ERROR[:<error_code>] -  function encountered an error.
-- None

PROCEDURE AssignLead (
    itemtype                  in VARCHAR2,
    itemkey                   in VARCHAR2,
    actid                     in NUMBER,
    funcmode                  in VARCHAR2,
    result                    out VARCHAR2 );


-- PROCEDURE GetAcceptTime
--
-- Retrieves time to wait for sales lead acceptance
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode.
--               Set by the engine as either 'RUN', 'CANCEL', or 'TIMEOUT'
-- OUT
-- result
-- COMPLETE[:<result>] - activity has completed with the indicated result
--   WAITING - activity is waiting for additional transitions
--   DEFERED - execution should be defered to background
--   NOTIFIED[:<notification_id>:<assigned_user>] -
--          activity has notified an external entity that this
--          step must be performed.  A call to wf_engine.CompleteActivty
--          will signal when this step is complete.  Optional
--          return of notification ID and assigned user.
--   ERROR[:<error_code>] - function encountered an error.
-- None

PROCEDURE GetAcceptTime (
    itemtype                   in VARCHAR2,
    itemkey                    in VARCHAR2,
    actid                      in NUMBER,
    funcmode                   in VARCHAR2,
    result                     out VARCHAR2
    );


-- PROCEDURE CheckAccepted
--
-- Checks to see if sales lead has been accepted
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode.
--               Set by the engine as either 'RUN', 'CANCEL', or 'TIMEOUT'
-- OUT
-- result
--   COMPLETE[:<result>] - activity has completed with the indicated result
--   WAITING - activity is waiting for additional transitions
--   DEFERED - execution should be defered to background
--   NOTIFIED[:<notification_id>:<assigned_user>] -
--          activity has notified an external entity that this
--          step must be performed.  A call to wf_engine.CompleteActivty
--          will signal when this step is complete.  Optional
--          return of notification ID and assigned user.
--   ERROR[:<error_code>] - function encountered an error.
-- None

PROCEDURE CheckAccepted (
    itemtype                   in VARCHAR2,
    itemkey                    in VARCHAR2,
    actid                      in NUMBER,
    funcmode                   in VARCHAR2,
    result                     out VARCHAR2
    );


-- PROCEDURE CheckforAbandon
--
-- Determines if the action for not accepting a sales lead = to abandon it
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode.
--               Set by the engine as either 'RUN', 'CANCEL', or 'TIMEOUT'
-- OUT
-- result
--   COMPLETE[:<result>] - activity has completed with the indicated result
--   WAITING - activity is waiting for additional transitions
--   DEFERED - execution should be defered to background
--   NOTIFIED[:<notification_id>:<assigned_user>] -
--          activity has notified an external entity that this
--          step must be performed.  A call to wf_engine.CompleteActivty
--          will signal when this step is complete.  Optional
--          return of notification ID and assigned user.
--   ERROR[:<error_code>] - function encountered an error.
-- None

PROCEDURE CheckforAbandon (
    itemtype                   in VARCHAR2,
    itemkey                    in VARCHAR2,
    actid                      in NUMBER,
    funcmode                   in VARCHAR2,
    result                     out VARCHAR2
    );

END AS_LEAD_ASSIGN_WF ;

 

/
