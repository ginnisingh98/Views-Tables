--------------------------------------------------------
--  DDL for Package OE_RMA_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_RMA_WF" AUTHID CURRENT_USER as
/* $Header: OEXWRMAS.pls 120.0.12010000.2 2010/02/12 11:55:01 nshah ship $	*/

-- PROCEDURE XX_ACTIVITY_NAME
--
-- <describe the activity here>
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of	the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--	 - COMPLETE[:<result>]
--	     activity has completed with the indicated result
--	 - WAITING
--	     activity is waiting for additional	transitions
--	 - DEFERED
--	     execution should be defered to background
--	 - NOTIFIED[:<notification_id>:<assigned_user>]
--	     activity has notified an external entity that this
--	     step must be performed.  A	call to	wf_engine.CompleteActivty
--	     will signal when this step	is complete.  Optional
--	     return of notification ID and assigned user.
--	 - ERROR[:<error_code>]
--	     function encountered an error.

procedure Create_Outbound_Shipment(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2 /* file.sql.39 change */
);

procedure Is_Return_Line(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2 /* file.sql.39 change */
);

procedure Is_Line_Receivable(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2 /* file.sql.39 change */
);

procedure Wait_For_Receiving(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2 /* file.sql.39 change */
);

/* 6629220: Start */
PROCEDURE UPD_FLOW_STATUS_CODE_REJ(
 itemtype 	IN 	VARCHAR2
,itemkey 	IN 	VARCHAR2
,actid 	IN 	NUMBER
,funcmode 	IN 	VARCHAR2
,resultout 	IN OUT NOCOPY /* file.sql.39 change */ 	VARCHAR2
);

PROCEDURE UPD_FLOW_STATUS_CODE_MIX_REJ(
 itemtype 	IN 	VARCHAR2
,itemkey 	IN 	VARCHAR2
,actid 	IN 	NUMBER
,funcmode 	IN 	VARCHAR2
,resultout 	IN OUT NOCOPY /* file.sql.39 change */ 	VARCHAR2
);
/* 6629220: End */

end OE_RMA_WF;

/
