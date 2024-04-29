--------------------------------------------------------
--  DDL for Package AS_LEAD_ROUTING_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_LEAD_ROUTING_WF" AUTHID CURRENT_USER AS
/* $Header: asxldrts.pls 120.0 2005/06/02 17:16:38 appldev noship $ */

/*-------------------------------------------------------------------------*
 |
 |                             PRIVATE DATATYPES
 |
 *-------------------------------------------------------------------------*/
TYPE NUMBER_TABLE IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE FLAG_TABLE IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;

TYPE Resource_Record_type IS RECORD
(
       RESOURCE_ID NUMBER,
       GROUP_ID NUMBER,
       WORKLOAD NUMBER
);

G_MISS_LEAD_RESOURCE_REC          Resource_Record_type;

TYPE available_resource_table IS TABLE OF Resource_record_type
                                       INDEX BY BINARY_INTEGER;

G_AVAILABLE_RESOURCE_TABLE        available_resource_table;

/*-------------------------------------------------------------------------*
 |
 |                             PUBLIC APIS
 |
 *-------------------------------------------------------------------------*/
-- PROCEDURE StartProcess
--
-- DESCRIPTION Procedure is called to start the structured inbound workflow
-- process.  Assigns attributes such as message ID, message size, sender name,
-- domain name, user id , pwd and priority.  Creates and kicks of the workflow.
--
-- IN
--   sales_lead_id - unique identifier of the sales_lead.
-- OUT
--
-- None

PROCEDURE StartProcess(
    p_sales_lead_id           IN     NUMBER,
    p_salesgroup_id           IN     NUMBER,
    p_reject_reason_code      IN     VARCHAR2 := NULL,
    x_return_status           IN OUT NOCOPY VARCHAR2,
    x_item_type               OUT NOCOPY    VARCHAR2,
    x_item_key                OUT NOCOPY    VARCHAR2
    ) ;

-- PROCEDURE GetAvailableResource
--
-- DESCRIPTION Retrieves available resources to work on lead.
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--	actid     - process activity instance id
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

PROCEDURE GetAvailableResource (
    itemtype    IN  VARCHAR2,
    itemkey     IN  VARCHAR2,
    actid       IN  NUMBER,
    funcmode    IN  VARCHAR2,
    result      OUT NOCOPY VARCHAR2 );


-- PROCEDURE GetAvailableResources
--
-- DESCRIPTION Retrieves available resources to work on lead.
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--	actid     - process activity instance id
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

PROCEDURE GetAvailableResources (
    itemtype    IN  VARCHAR2,
    itemkey     IN  VARCHAR2,
    actid       IN  NUMBER,
    funcmode    IN  VARCHAR2,
    result      OUT NOCOPY VARCHAR2 );


-- PROCEDURE GetOwner
--
-- DESCRIPTION Decide the owner of sales lead
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--	actid     - process activity instance id
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

PROCEDURE GetOwner(
    itemtype    IN  VARCHAR2,
    itemkey     IN  VARCHAR2,
    actid       IN  NUMBER,
    funcmode    IN  VARCHAR2,
    result      OUT NOCOPY VARCHAR2 );


-- PROCEDURE GetResourceWorkload
--
-- DESCRIPTION Retrieves current workload for each resource
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

PROCEDURE GetResourceWorkload (
    itemtype    in VARCHAR2,
    itemkey     in VARCHAR2,
    actid	      in NUMBER,
    funcmode    in VARCHAR2,
    result      OUT NOCOPY VARCHAR2 );


-- PROCEDURE BalanceWorkload
--
-- DESCRIPTION Selects resource based on balanced workload
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--	actid     - process activity instance id
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

PROCEDURE BalanceWorkload (
    itemtype  in VARCHAR2,
    itemkey   in VARCHAR2,
    actid	    in NUMBER,
    funcmode  in VARCHAR2,
    result    OUT NOCOPY VARCHAR2 );


-- PROCEDURE UpdateSalesLeads
--
-- DESCRIPTION Use Sales Lead APIs to update sales leads
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

PROCEDURE UpdateSalesLeads (
    itemtype      IN  VARCHAR2,
    itemkey       IN  VARCHAR2,
    actid         IN  NUMBER,
    funcmode      IN  VARCHAR2,
    result        OUT NOCOPY VARCHAR2 );


-- PROCEDURE EscalatetoManager
--
-- DESCRIPTION If a resource is not found, escalate to the manager
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode.  Set by the engine as either 'RUN', 'CANCEL', or 'TIMEOUT'
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

PROCEDURE EscalatetoManager (
    itemtype    in VARCHAR2,
    itemkey     in VARCHAR2,
    actid       in NUMBER,
    funcmode    in VARCHAR2,
    result      OUT NOCOPY VARCHAR2 );


END AS_LEAD_ROUTING_WF ;


 

/
