--------------------------------------------------------
--  DDL for Package IEM_MAILPREPROCWF_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_MAILPREPROCWF_PUB" AUTHID CURRENT_USER as
/* $Header: iempwfps.pls 115.11 2002/12/05 19:39:06 sboorela shipped $*/
G_STAT		varchar2(1):='S';

-- PROCEDURE IEM_STARTPROCESS
--
-- Starts The Workflow Application
--
-- IN
--	Workflowprocess	- Name Of The Process
--   Item_Type  - type of the current item
--   ItemKey Itemkey for the workflow process
--   p_itemuserkey itemuserkey to identify the wf status
--   p_msgid Message Id
--   p_msgsize Message Size
--   p_sender Sender name
--   p_username User name
--   p_domain Domain
--   p_priority  Message priority
--   p_msg_status Message status
-- OUT
--	None
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an error.

	PROCEDURE 	IEM_STARTPROCESS(
     		WorkflowProcess IN VARCHAR2,
     		ItemType in VARCHAR2 ,
			ItemKey in number,
			p_itemuserkey in varchar2,
			p_msgid in varchar2,
			p_msgsize in number,
			p_sender in varchar2,
			p_username in varchar2,
			p_domain in varchar2,
			p_priority in varchar2,
			p_msg_status in varchar2,
			p_email_account_id in number,
			p_flow in varchar2,
			x_outval out nocopy varchar2,
			x_process	 OUT NOCOPY varchar2);


-- PROCEDURE IEM_WF_CHKAUTH
--
-- Check The User Authentication
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--	None
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an error.

procedure IEM_WF_CHKAUTH(
				itemtype in varchar2,
				itemkey in varchar2,
				actid   in number,
				funcmode	in varchar2,
				result in out nocopy varchar2);

-- PROCEDURE IEM_WF_MSGHDR
--
-- Process The Message To get the standard Header and populate the attribute
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--	None
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an error.

procedure IEM_WF_MSGHDR(
				itemtype in varchar2,
				itemkey in varchar2,
				actid   in number,
				funcmode	in varchar2,
				result in out nocopy varchar2);

-- PROCEDURE IEM_AUTH_FAILED
--
-- Indicate That User Authentication Is Failed
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--	None
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an error.

procedure IEM_WF_AUTHFAILED(
				itemtype in varchar2,
				itemkey in varchar2,
				actid   in number,
				funcmode	in varchar2,
				result in out nocopy varchar2);

-- PROCEDURE IEM_WF_CHKUSERGRP
--
-- Check The User Group and Branch into the corresponding activity.
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--	None
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an error.

procedure IEM_WF_CHKUSERGRP(
				itemtype in varchar2,
				itemkey in varchar2,
				actid   in number,
				funcmode	in varchar2,
				result in out nocopy varchar2);

-- PROCEDURE IEM_WF_GETEXTHEADER
--
-- Perform The Extended Header Processing
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--	None
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an error.

procedure IEM_WF_GETEXTHEADER(
				itemtype in varchar2,
				itemkey in varchar2,
				actid   in number,
				funcmode	in varchar2,
				result in out nocopy varchar2);

-- PROCEDURE IEM_WF_GETPART
--
-- Get The Message Part.

-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--	None
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an error.

procedure IEM_WF_GETPART(
				itemtype in varchar2,
				itemkey in varchar2,
				actid   in number,
				funcmode	in varchar2,
				result in out nocopy varchar2);

-- PROCEDURE IEM_WF_ENQUEUE
--
-- Enqueue the process mail into AQ2
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--	None
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an error.

procedure IEM_WF_ENQUEUE(
				itemtype in varchar2,
				itemkey in varchar2,
				actid   in number,
				funcmode	in varchar2,
				result in out nocopy varchar2);

-- PROCEDURE IEM_WF_NOGRP
--
-- Process The mail when no user group are defined for the mail.
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--	None
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an error.

procedure IEM_WF_NOGRP(
				itemtype in varchar2,
				itemkey in varchar2,
				actid   in number,
				funcmode	in varchar2,
				result in out nocopy varchar2);

-- PROCEDURE IEM_WF_IS_STRUCT
--
-- Check The mail Whether Structured or Not .
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--	None
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an error.

procedure IEM_WF_IS_STRUCT(
				itemtype in varchar2,
				itemkey in varchar2,
				actid   in number,
				funcmode	in varchar2,
				result in out nocopy varchar2);

-- PROCEDURE IEM_WF_STRUCT_PROC
--
-- Node For Processing Structured Mail. This Will call another workflow start
-- process for processing structured e-mail.
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--	None
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an error.

procedure IEM_WF_STRUCT_PROC(
				itemtype in varchar2,
				itemkey in varchar2,
				actid   in number,
				funcmode	in varchar2,
				result in out nocopy varchar2);


-- PROCEDURE IEM_WF_BCC_TO
--
-- Node For BCC The mail to a reciepient .
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--	None
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an error.

procedure IEM_WF_BCC_TO(
				itemtype in varchar2,
				itemkey in varchar2,
				actid   in number,
				funcmode	in varchar2,
				result in out nocopy varchar2);
-- PROCEDURE IEM_WF_DELETE_MSG
--
-- Delete The current Message .
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--	None
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an error.

procedure IEM_WF_DELETEMSG(
				itemtype in varchar2,
				itemkey in varchar2,
				actid   in number,
				funcmode	in varchar2,
				result in out nocopy varchar2);

-- PROCEDURE IEM_WF_MOVETO
--
-- Move The Message To The Specified Folder
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--	None
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an error.

procedure IEM_WF_MOVETO(
				itemtype in varchar2,
				itemkey in varchar2,
				actid   in number,
				funcmode	in varchar2,
				result in out nocopy varchar2);

-- PROCEDURE IEM_WF_COPYTO
--
-- Copy the Messaage To the given folder
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--	None
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an error.

procedure IEM_WF_COPYTO(
				itemtype in varchar2,
				itemkey in varchar2,
				actid   in number,
				funcmode	in varchar2,
				result in out nocopy varchar2);

-- PROCEDURE IEM_WF_FORWARDTO
--
-- Forward the Messaage with a notes attached
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--	None
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an error.

procedure IEM_WF_FORWARDTO(
				itemtype in varchar2,
				itemkey in varchar2,
				actid   in number,
				funcmode	in varchar2,
				result in out nocopy varchar2);
-- PROCEDURE IEM_WF_SIMPLESEARCH
--
-- Search The KB Repository
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--	None
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an error.

procedure IEM_WF_SIMPLESEARCH(
				itemtype in varchar2,
				itemkey in varchar2,
				actid   in number,
				funcmode	in varchar2,
				result in out nocopy varchar2);

-- PROCEDURE IEM_WF_SPECIFICSEARCH
--
-- Do a specific search on the KB Repository
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--	None
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an error.

procedure IEM_WF_SPECIFICSEARCH(
				itemtype in varchar2,
				itemkey in varchar2,
				actid   in number,
				funcmode	in varchar2,
				result in out nocopy varchar2);

-- PROCEDURE IEM_WF_SEARCHMESSAGE
--
-- Based on the search criteria looks for the content in Message
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--	None
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an error.

procedure IEM_WF_SEARCHMESSAGE(
				itemtype in varchar2,
				itemkey in varchar2,
				actid   in number,
				funcmode	in varchar2,
				result in out nocopy varchar2);

-- PROCEDURE IEM_WF_PROCTHEMEREPOS
--
-- Generate the Theme and classification Repository
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--	None
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an error.

procedure IEM_WF_STORETHEME(
				itemtype in varchar2,
				itemkey in varchar2,
				actid   in number,
				funcmode	in varchar2,
				result in out nocopy varchar2);

-- PROCEDURE IEM_WF_THEMEPROC
--
-- Process the Theme for each classification and keep max seven classification
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--	None
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an error.

procedure IEM_WF_THEMEPROC(
				itemtype in varchar2,
				itemkey in varchar2,
				actid   in number,
				funcmode	in varchar2,
				result in out nocopy varchar2);
-- PROCEDURE IEM_WF_KEYVAL
--
-- Process the Theme for each classification and keep max seven classification
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--	None
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an error.
procedure IEM_WF_KEYVAL(
				itemtype in varchar2,
				itemkey in varchar2,
				actid   in number,
				funcmode	in varchar2,
				result in out nocopy varchar2);

-- PROCEDURE IEM_WF_CLASSRULE
--
-- Check the classification score with the thresh hold score and return T/F
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--	None
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an error.
procedure IEM_WF_CLASSRULE(
				itemtype in varchar2,
				itemkey in varchar2,
				actid   in number,
				funcmode	in varchar2,
				result in out nocopy varchar2);

-- PROCEDURE IEM_WF_CHKAUTO
--
-- Check the classification score with the thresh hold score and return T/F
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--	None
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an error.

procedure IEM_WF_CHKAUTO(
				itemtype in varchar2,
				itemkey in varchar2,
				actid   in number,
				funcmode	in varchar2,
				result in out nocopy varchar2);

-- PROCEDURE IEM_WF_AUTORESP
--
-- Auto respond a set of documnets to the sender
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--	None
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an error.

procedure IEM_WF_AUTORESP(
				itemtype in varchar2,
				itemkey in varchar2,
				actid   in number,
				funcmode	in varchar2,
				result in out nocopy varchar2);

-- PROCEDURE IEM_WF_ORDSTAT
--
-- Auto respond the order status to the sender
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--	None
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an error.

procedure IEM_WF_ORDSTAT(
				itemtype in varchar2,
				itemkey in varchar2,
				actid   in number,
				funcmode	in varchar2,
				result in out nocopy varchar2);

end IEM_Mailpreprocwf_PUB;

 

/
