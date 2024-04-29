--------------------------------------------------------
--  DDL for Package EDR_TEMPLATE_SUBS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDR_TEMPLATE_SUBS" AUTHID CURRENT_USER AS
/* $Header: EDRTMPSS.pls 120.0.12000000.1 2007/01/18 05:55:50 appldev ship $ */

-- EDR_TEMPLATE_SUBS.UPLOAD_TEMPLATE
-- This procedure is a post process function called from RTFUPLOAF Workflow process.
-- It gets the name of file being approved and converts it to XSLFO if it is EDR_EREC_TEMPLATE
-- and File Extension is RTF.

-- P_ITEMTYPE  The internal name for the item type. Item types are
--             defined in the Oracle Workflow Builder.

-- P_ITEMKEY   A string that represents a primary key generated
--             by the workflow-enabled application for the item
--             type. The string uniquely identifies the item within
--             an item type.

-- P_ACTID     The ID number of the activity from which this
--              procedure is called.

-- P_FUNCMODE  The execution mode of the activity. If the activity is
--             a function activity, the mode is either RUN or
--             CANCEL. If the activity is a notification activity,
--             with a postnotification function, then the mode
--             can be RESPOND, FORWARD, TRANSFER,
--             TIMEOUT, or RUN.

-- P_RESULTOUT If a result type is specified in the Activities
--             properties page for the activity in the Oracle
--             Workflow Builder, this parameter represents the
--             expected result that is returned when the
--             procedure completes. The possible results are:
--             COMPLETE:<result_code> activity completes
--             with the indicated result code. The result code
--             must match one of the result codes specified in the
--             result type of the function activity.
--             WAITING-activity is pending, waiting on
--             another activity to complete before it completes.
--             An example is the Standard AND activity.
--             DEFERRED:<date>activity is deferred to a
--             background engine for execution until a given date.
--             <date> must be of the format:
--             to_char(<date_string>, wf_engine.date_format)
--             NOTIFIED:<notification_id>:<assigned_user>-a
--             n external entity is notified that an action must be
--             performed. A notification ID and an assigned user
--             can optionally be returned with this result. Note
--             that the external entity must call CompleteActivity( )
--             to inform the Workflow Engine when the action
--             completes.
--             ERROR:<error_code>-activity encounters an
--             error and returns the indicated error code.

PROCEDURE UPLOAD_TEMPLATE
(
 		  	   P_ITEMTYPE VARCHAR2,
   			   P_ITEMKEY VARCHAR2,
 			   P_ACTID NUMBER,
 			   P_FUNCMODE VARCHAR2,
 			   P_RESULTOUT OUT NOCOPY VARCHAR2
);

END EDR_TEMPLATE_SUBS;

 

/
