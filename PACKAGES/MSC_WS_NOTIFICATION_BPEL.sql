--------------------------------------------------------
--  DDL for Package MSC_WS_NOTIFICATION_BPEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_WS_NOTIFICATION_BPEL" AUTHID CURRENT_USER AS
     /* $Header: MSCWNOTS.pls 120.1.12010000.2 2008/07/08 18:41:44 bnaghi ship $ */


    -- =============================================================
    -- Desc: This procedure is invoked from workflow to create an ad-hoc
    --       role for the receiver. The input parameters are
    --       itemtype: workflow name
    --       itemkey: unique identifier of this workflow's instance
    --       The possible return statuses are:
    --       complete:y - meaning the procedure finished successfully
    --       complete:n - meaning an error was encountered
    -- =============================================================

       PROCEDURE set_wf_approver_role
       (itemtype IN VARCHAR2,
	itemkey IN VARCHAR2,
	actid IN NUMBER, funcmode IN VARCHAR2, result in out nocopy varchar2);

 -- =============================================================
    -- Desc: This procedure is invoked from workflow to translate
    --       the activity type id into activity type name( uses mfg_lookups).
    --       The input parameters are:
    --       itemtype: workflow name
    --       itemkey: unique identifier of this workflow's instance
    --       The possible return statuses are:
    --       complete:y - meaning the procedure finished successfully
    --       complete:n - meaning an error was encountered
    -- =============================================================

     procedure Lookup
       (itemtype IN VARCHAR2,
	itemkey IN VARCHAR2,
	actid IN NUMBER, funcmode IN VARCHAR2, result in out nocopy varchar2);

-- =============================================================
    -- Desc: This procedure is invoked from workflow to translate
    --       the plan id into plan name( uses msc_plans).
    --       The input parameters are:
    --       itemtype: workflow name
    --       itemkey: unique identifier of this workflow's instance
    --       The possible return statuses are:
    --       complete:y - meaning the procedure finished successfully
    --       complete:n - meaning an error was encountered
    -- =============================================================

     procedure Lookup_Plan
       (itemtype IN VARCHAR2,
	itemkey IN VARCHAR2,
	actid IN NUMBER, funcmode IN VARCHAR2, result in out nocopy varchar2);

-- =============================================================
    -- Desc: This procedure is invoked from workflow to translate
    --       the excalation level id into escalation level name.
    --       The input parameters are:
    --       itemtype: workflow name
    --       itemkey: unique identifier of this workflow's instance
    --       The possible return statuses are:
    --       complete:y - meaning the procedure finished successfully
    --       complete:n - meaning an error was encountered
    -- =============================================================
     procedure Lookup_Escalation
       (itemtype IN VARCHAR2,
	itemkey IN VARCHAR2,
	actid IN NUMBER, funcmode IN VARCHAR2, result in out nocopy varchar2);

-- =============================================================
    -- Desc: This procedure is invoked from the Web Service to send
    --       a notification from userId to receiver
    --       The input parameters are:
    --       userID: user id of the sender
    --       respID: responsibility id of the sender
    --       receiver : receiver of the notification
    --       language: this parameter is for future use, right now not used
    --       wfName: workflow name to be instantiated to send the notification
    --       wfProcessName : provess name in the workflow, to be instantiated to send the notification
    --       tokenValues : pairs of token_name - token_value. Token_name is a name that identifies
    --       an attribute to be set; token_value is the string value of that attribute
    --       The possible return statuses are:
    --       SUCCESS- meaning the procedure finished successfully
    --       UNKNOWN_ERROR - meaning an error was encountered  and the notification was not send.
    -- =============================================================

     FUNCTION SendFYINotification (userID IN NUMBER, ---sender user id
				   respID in NUMBER, --sender resp id
				   receiver in varchar2,
				   language IN Varchar2,
				   wfName IN VARCHAR2,
				   wfProcessName IN varchar2,
				   tokenValues IN MsgTokenValuePairList)
  return VARCHAR2;

  FUNCTION SendFYINotificationPublic (
           UserName               IN VARCHAR2,
           RespName     IN VARCHAR2,
           RespApplName IN VARCHAR2,
           SecurityGroupName      IN VARCHAR2,
				   receiver in varchar2,
				   language IN Varchar2,
				   wfName IN VARCHAR2,
				   wfProcessName IN varchar2,
				   tokenValues IN MsgTokenValuePairList)
  return VARCHAR2;


END MSC_WS_NOTIFICATION_BPEL;


/
