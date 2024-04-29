--------------------------------------------------------
--  DDL for Package AML_MONITOR_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AML_MONITOR_WF" AUTHID CURRENT_USER AS
/* $Header: amlldmns.pls 115.11 2003/09/09 23:50:52 swkhanna ship $ */



/*-------------------------------------------------------------------------*
 |
 |                             PRIVATE DATATYPES
 |
 *-------------------------------------------------------------------------*/
TYPE NUMBER_TABLE IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE FLAG_TABLE IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;


g_item_type VARCHAR2(30) := 'ASXSLASW';


/*-------------------------------------------------------------------------*
 |
 |                             PUBLIC APIS
 |
 *-------------------------------------------------------------------------*/


-- PROCEDURE GetMonitors
--
-- DESCRIPTION Retrieves eligible monitors
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




 PROCEDURE LAUNCH_MONITOR (
    P_Api_Version_Number         IN  NUMBER,
    P_Init_Msg_List              IN  VARCHAR2    := FND_API.G_FALSE,
    p_commit                     IN  VARCHAR2    := FND_API.G_FALSE,
    P_Sales_Lead_Id              IN  NUMBER,
    P_Changed_From_stage         IN VARCHAR2 ,
    P_Lead_Action                IN VARCHAR2 ,
    P_Attribute_Changed          IN VARCHAR2 ,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    );

PROCEDURE Get_Monitor_Details(
    itemtype         IN  VARCHAR2,
    itemkey          IN  VARCHAR2,
    actid            IN  NUMBER,
    funcmode         IN  VARCHAR2,
    result           OUT NOCOPY VARCHAR2 ) ;

PROCEDURE Owner_Needed (
    itemtype         IN  VARCHAR2,
    itemkey          IN  VARCHAR2,
    actid            IN  NUMBER,
    funcmode         IN  VARCHAR2,
    result           OUT NOCOPY VARCHAR2 ) ;

PROCEDURE Timeout_Defined (
    itemtype         IN  VARCHAR2,
    itemkey          IN  VARCHAR2,
    actid            IN  NUMBER,
    funcmode         IN  VARCHAR2,
    result           OUT NOCOPY VARCHAR2 );

PROCEDURE SET_NOTIFY_ATTRIBUTES (
    itemtype         IN  VARCHAR2,
    itemkey          IN  VARCHAR2,
    actid            IN  NUMBER,
    funcmode         IN  VARCHAR2,
    result           OUT NOCOPY VARCHAR2 );

PROCEDURE LOG_ACTION (
    itemtype         IN  VARCHAR2,
    itemkey          IN  VARCHAR2,
    actid            IN  NUMBER,
    funcmode         IN  VARCHAR2,
    result           OUT NOCOPY VARCHAR2 );

PROCEDURE CHK_MAX_REMINDERS (
    itemtype         IN  VARCHAR2,
    itemkey          IN  VARCHAR2,
    actid            IN  NUMBER,
    funcmode         IN  VARCHAR2,
    result           OUT NOCOPY VARCHAR2 );

PROCEDURE SET_REMINDER_ATTRIBUTES (
    itemtype         IN  VARCHAR2,
    itemkey          IN  VARCHAR2,
    actid            IN  NUMBER,
    funcmode         IN  VARCHAR2,
    result           OUT NOCOPY VARCHAR2 );

PROCEDURE Set_Timeout (
    itemtype         IN  VARCHAR2,
    itemkey          IN  VARCHAR2,
    actid            IN  NUMBER,
    funcmode         IN  VARCHAR2,
    result           OUT NOCOPY VARCHAR2 );

PROCEDURE Chk_Max_Reroutes (
    itemtype         IN  VARCHAR2,
    itemkey          IN  VARCHAR2,
    actid            IN  NUMBER,
    funcmode         IN  VARCHAR2,
    result           OUT NOCOPY VARCHAR2 );

  /*******************************/
PROCEDURE INCREMENT_CURR_REMINDER (
    itemtype         IN  VARCHAR2,
    itemkey          IN  VARCHAR2,
    actid            IN  NUMBER,
    funcmode         IN  VARCHAR2,
    result           OUT NOCOPY VARCHAR2 );

   /*******************************/
 PROCEDURE  INCREMENT_CURR_REROUTES (
    itemtype         IN  VARCHAR2,
    itemkey          IN  VARCHAR2,
    actid            IN  NUMBER,
    funcmode         IN  VARCHAR2,
    result           OUT NOCOPY VARCHAR2 )  ;

/*******************************/
-- API: CHK_TIMELAG_CONDITION_TRUE
/*******************************/
PROCEDURE CHK_TIMELAG_CONDITION_TRUE (
    itemtype         IN  VARCHAR2,
    itemkey          IN  VARCHAR2,
    actid            IN  NUMBER,
    funcmode         IN  VARCHAR2,
    result           OUT NOCOPY VARCHAR2 );

/*******************************/
-- API: SET_DEFAULT_RESOURCE
/*******************************/
PROCEDURE SET_DEFAULT_RESOURCE (
    itemtype         IN  VARCHAR2,
    itemkey          IN  VARCHAR2,
    actid            IN  NUMBER,
    funcmode         IN  VARCHAR2,
    result           OUT NOCOPY VARCHAR2 );


PROCEDURE CHK_RESTART_REQD (
    itemtype         IN  VARCHAR2,
    itemkey          IN  VARCHAR2,
    actid            IN  NUMBER,
    funcmode         IN  VARCHAR2,
    result           OUT NOCOPY VARCHAR2 );

 PROCEDURE SET_RESTART_ATTR (
    itemtype         IN  VARCHAR2,
    itemkey          IN  VARCHAR2,
    actid            IN  NUMBER,
    funcmode         IN  VARCHAR2,
    result           OUT NOCOPY VARCHAR2 );


procedure set_timelag
(p_start_date in date,
 p_timeout in out NOCOPY number,
 x_due_date out NOCOPY date,
x_total_timeout out NOCOPY number);


Procedure get_lead_owner
   ( itemtype         IN  VARCHAR2,
     itemkey          IN  VARCHAR2);


END AML_MONITOR_WF ;

 

/
