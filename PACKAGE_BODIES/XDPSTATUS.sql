--------------------------------------------------------
--  DDL for Package Body XDPSTATUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDPSTATUS" AS
/* $Header: XDPSTATB.pls 120.1 2005/06/09 00:32:17 appldev  $ */


/****
 All Private Procedures for the Package
****/

Procedure SetOrderStatus(itemtype in varchar2,
                         itemkey in varchar2);

Procedure SendOrderStatus(itemtype in varchar2,
                         itemkey in varchar2,
                         actid in number);

Procedure SetBundleStatus(itemtype in varchar2,
                         itemkey in varchar2);

Procedure SetLineStatus(itemtype in varchar2,
                        itemkey in varchar2);

Procedure SendLineStatus(itemtype in varchar2,
                         itemkey in varchar2,
                         actid in number);

Procedure SetPackageStatus(itemtype in varchar2,
                           itemkey in varchar2);

/***
Procedure SetWorkitemStatus(itemtype in varchar2,
                           itemkey in varchar2);
***/

Procedure SetWIStatusSuccess(itemtype in varchar2,
                             itemkey in varchar2);

Procedure SaveWorkitem(itemtype in varchar2,
                       itemkey in varchar2,
                       actid in number);

Procedure SendWorkitemStatus(itemtype in varchar2,
                             itemkey in varchar2,
                             actid in number);

Procedure SetFAStatus(itemtype in varchar2,
                      itemkey in varchar2,
                      actid in number);

Procedure SetFeExecStatus(itemtype in varchar2,
                          itemkey in varchar2);

Procedure SendFeProvStatus(itemtype in varchar2,
                           itemkey in varchar2,
                           actid in number);

Function GetResubmissionJobID (itemtype in varchar2,
                               itemkey in varchar2) return number;

Procedure UpdateFAStatus(faid in number, status in varchar2, provmode in varchar2);

PROCEDURE SetErrorStatus(itemtype IN VARCHAR2,
                         itemkey  IN VARCHAR2,
                         actid    IN NUMBER);

PROCEDURE SetNodeWIStatus(itemtype IN VARCHAR2,
                          itemkey  IN VARCHAR2,
                          actid    IN NUMBER);


PROCEDURE SetNodeLineStatus(itemtype IN VARCHAR2,
                          itemkey  IN VARCHAR2,
                          actid    IN NUMBER);

/***********************************************
* END of Private Procedures/Function Definitions
************************************************/



--  SET_ERROR_STATUS
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:

Procedure SET_ERROR_STATUS (itemtype        in varchar2,
			    itemkey         in varchar2,
			    actid           in number,
			    funcmode        in varchar2,
			    resultout       OUT NOCOPY varchar2 ) IS

BEGIN
-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN
                SetErrorStatus(itemtype, itemkey,actid);
		resultout := 'COMPLETE:ACTIVITY_PERFORMED';
	END IF;
-- CANCEL mode - activity 'compensation'
--
-- This is in the event that the activity must be undone
-- for example when a process is reset to an earlier point
-- due to a loop back.
--

        IF (funcmode = 'CANCEL') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'RESPOND') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'FORWARD') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'TRANSFER') THEN
                return;
        END IF;

        IF (funcmode = 'TIMEOUT') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'others') THEN
                resultout := ' ';
                return;
        END IF;


EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPSTATUS', 'SET_ERROR_STATUS', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END SET_ERROR_STATUS;

--  SET_ORDER_STATUS
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:

Procedure SET_ORDER_STATUS (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2 ) IS

BEGIN
-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN
                SetOrderStatus(itemtype, itemkey);
		resultout := 'COMPLETE:ACTIVITY_PERFORMED';
	END IF;
-- CANCEL mode - activity 'compensation'
--
-- This is in the event that the activity must be undone
-- for example when a process is reset to an earlier point
-- due to a loop back.
--

        IF (funcmode = 'CANCEL') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'RESPOND') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'FORWARD') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'TRANSFER') THEN
                return;
        END IF;

        IF (funcmode = 'TIMEOUT') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'others') THEN
                resultout := ' ';
                return;
        END IF;


EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPSTATUS', 'SET_ORDER_STATUS', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END SET_ORDER_STATUS;


--  SEND_ORDER_STATUS
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:

Procedure SEND_ORDER_STATUS (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2 ) IS

BEGIN
-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN
                SendOrderStatus(itemtype, itemkey, actid);
		resultout := 'COMPLETE:ACTIVITY_PERFORMED';
	END IF;
-- CANCEL mode - activity 'compensation'
--
-- This is in the event that the activity must be undone
-- for example when a process is reset to an earlier point
-- due to a loop back.
--

        IF (funcmode = 'CANCEL') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'RESPOND') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'FORWARD') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'TRANSFER') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'TIMEOUT') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'others') THEN
                resultout := ' ';
                return;
        END IF;

EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPSTATUS', 'SEND_ORDER_STATUS', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END SEND_ORDER_STATUS;



--  SEND_LINE_STATUS
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:

Procedure SEND_LINE_STATUS (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2 ) IS

BEGIN
-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN
                SendLineStatus(itemtype, itemkey, actid);
		resultout := 'COMPLETE:ACTIVITY_PERFORMED';
	END IF;
-- CANCEL mode - activity 'compensation'
--
-- This is in the event that the activity must be undone
-- for example when a process is reset to an earlier point
-- due to a loop back.
--

        IF (funcmode = 'CANCEL') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'RESPOND') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'FORWARD') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'TRANSFER') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'TIMEOUT') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'others') THEN
                resultout := ' ';
                return;
        END IF;

EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPSTATUS', 'SEND_LINE_STATUS', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END SEND_LINE_STATUS;



--  SET_BUNDLE_STATUS
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:

Procedure SET_BUNDLE_STATUS (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2 ) IS

BEGIN
-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN
                SetBundleStatus(itemtype, itemkey);
		resultout := 'COMPLETE:ACTIVITY_PERFORMED';
	END IF;
-- CANCEL mode - activity 'compensation'
--
-- This is in the event that the activity must be undone
-- for example when a process is reset to an earlier point
-- due to a loop back.
--

        IF (funcmode = 'CANCEL') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'RESPOND') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'FORWARD') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'TRANSFER') THEN
                return;
        END IF;

        IF (funcmode = 'TIMEOUT') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'others') THEN
                resultout := ' ';
                return;
        END IF;


EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPSTATUS', 'SET_BUNDLE_STATUS', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END SET_BUNDLE_STATUS;


--  SET_LINE_STATUS
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:

Procedure SET_LINE_STATUS (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2 ) IS

BEGIN
-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN
                SetLineStatus(itemtype, itemkey);
		resultout := 'COMPLETE:ACTIVITY_PERFORMED';
	END IF;
-- CANCEL mode - activity 'compensation'
--
-- This is in the event that the activity must be undone
-- for example when a process is reset to an earlier point
-- due to a loop back.
--

        IF (funcmode = 'CANCEL') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'RESPOND') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'FORWARD') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'TRANSFER') THEN
                return;
        END IF;

        IF (funcmode = 'TIMEOUT') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'others') THEN
                resultout := ' ';
                return;
        END IF;


EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPSTATUS', 'SET_LINE_STATUS', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END SET_LINE_STATUS;




--  SET_PACKAGE_STATUS
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:

Procedure SET_PACKAGE_STATUS (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2 ) IS

BEGIN
-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN
                SetPackageStatus(itemtype, itemkey);
		resultout := 'COMPLETE:ACTIVITY_PERFORMED';
	END IF;
-- CANCEL mode - activity 'compensation'
--
-- This is in the event that the activity must be undone
-- for example when a process is reset to an earlier point
-- due to a loop back.
--

        IF (funcmode = 'CANCEL') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'RESPOND') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'FORWARD') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'TRANSFER') THEN
                return;
        END IF;

        IF (funcmode = 'TIMEOUT') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'others') THEN
                resultout := ' ';
                return;
        END IF;


EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPSTATUS', 'SET_PACKAGE_STATUS', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END SET_PACKAGE_STATUS;




--  l_OrderID
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:

Procedure SET_WORKITEM_STATUS (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2 ) IS

BEGIN
-- RUN mode - normal process execution
--
        IF (funcmode = 'RUN') THEN
                SetWorkitemStatus(itemtype, itemkey);
                resultout := 'COMPLETE:ACTIVITY_PERFORMED';
        END IF;
-- CANCEL mode - activity 'compensation'
--
-- This is in the event that the activity must be undone
-- for example when a process is reset to an earlier point
-- due to a loop back.
--


        IF (funcmode = 'RESPOND') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'FORWARD') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'TRANSFER') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'TIMEOUT') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'others') THEN
                resultout := ' ';
                return;
        END IF;

EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPSTATUS', 'SET_WORKITEM_STATUS', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END SET_WORKITEM_STATUS;


--  SET_WI_STATUS_SUCCESS
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:

Procedure SET_WI_STATUS_SUCCESS (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2 ) IS

BEGIN
-- RUN mode - normal process execution
--
        IF (funcmode = 'RUN') THEN
                SetWIStatusSuccess(itemtype, itemkey);
                resultout := 'COMPLETE:ACTIVITY_PERFORMED';
        END IF;
-- CANCEL mode - activity 'compensation'
--
-- This is in the event that the activity must be undone
-- for example when a process is reset to an earlier point
-- due to a loop back.
--


        IF (funcmode = 'RESPOND') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'FORWARD') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'TRANSFER') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'TIMEOUT') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'others') THEN
                resultout := ' ';
                return;
        END IF;

EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPSTATUS', 'SET_WI_STATUS_SUCCESS', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END SET_WI_STATUS_SUCCESS;




--  SEND_WORKITEM_STATUS
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:

Procedure SEND_WORKITEM_STATUS (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2 ) IS
BEGIN
-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN
                SendWorkitemStatus(itemtype, itemkey, actid);
		resultout := 'COMPLETE:ACTIVITY_PERFORMED';

	END IF;
-- CANCEL mode - activity 'compensation'
--
-- This is in the event that the activity must be undone
-- for example when a process is reset to an earlier point
-- due to a loop back.
--

        IF (funcmode = 'CANCEL') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'RESPOND') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'FORWARD') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'TRANSFER') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'TIMEOUT') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'others') THEN
                resultout := ' ';
                return;
        END IF;

EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPSTATUS', 'SEND_WORKITEM_STATUS', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END SEND_WORKITEM_STATUS;


--  SAVE_WORKITEM
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:

Procedure SAVE_WORKITEM (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2 ) IS

BEGIN
-- RUN mode - normal process execution
--
        IF (funcmode = 'RUN') THEN
                SaveWorkitem(itemtype, itemkey, actid);
                resultout := 'COMPLETE:ACTIVITY_PERFORMED';
        END IF;
-- CANCEL mode - activity 'compensation'
--
-- This is in the event that the activity must be undone
-- for example when a process is reset to an earlier point
-- due to a loop back.
--


        IF (funcmode = 'RESPOND') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'FORWARD') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'TRANSFER') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'TIMEOUT') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'others') THEN
                resultout := ' ';
                return;
        END IF;

EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPSTATUS', 'SAVE_WORKITEM', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END SAVE_WORKITEM;


--  SET_FA_STATUS
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:

Procedure SET_FA_STATUS (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2 ) IS

BEGIN
-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN
                SetFAStatus(itemtype, itemkey, actid);
		resultout := 'COMPLETE:ACTIVITY_PERFORMED';
	END IF;
-- CANCEL mode - activity 'compensation'
--
-- This is in the event that the activity must be undone
-- for example when a process is reset to an earlier point
-- due to a loop back.
--

        IF (funcmode = 'CANCEL') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'RESPOND') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'FORWARD') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'TRANSFER') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'TIMEOUT') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'others') THEN
                resultout := ' ';
                return;
        END IF;

EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPSTATUS', 'SET_FA_STATUS', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END SET_FA_STATUS;



-- SEND_FE_PROV_STATUS
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:

Procedure SEND_FE_PROV_STATUS (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2 ) IS

BEGIN
-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN
                SendFeProvStatus(itemtype, itemkey, actid);
		resultout := 'COMPLETE:ACTIVITY_PERFORMED';
	END IF;
-- CANCEL mode - activity 'compensation'
--
-- This is in the event that the activity must be undone
-- for example when a process is reset to an earlier point
-- due to a loop back.
--

        IF (funcmode = 'CANCEL') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'RESPOND') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'FORWARD') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'TRANSFER') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'TIMEOUT') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'others') THEN
                resultout := ' ';
                return;
        END IF;

EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPSTATUS', 'SEND_FE_PROV_STATUS', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END SEND_FE_PROV_STATUS;



--  SET_FE_EXEC_STATUS
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:

Procedure SET_FE_EXEC_STATUS (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2 ) IS

BEGIN
-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN
                SetFeExecStatus(itemtype, itemkey);
		resultout := 'COMPLETE:ACTIVITY_PERFORMED';
	END IF;
-- CANCEL mode - activity 'compensation'
--
-- This is in the event that the activity must be undone
-- for example when a process is reset to an earlier point
-- due to a loop back.
--

        IF (funcmode = 'CANCEL') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'RESPOND') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'FORWARD') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'TRANSFER') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'TIMEOUT') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'others') THEN
                resultout := ' ';
                return;
        END IF;

EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPSTATUS', 'SET_FE_EXEC_STATUS', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END SET_FE_EXEC_STATUS;


--  SET_FE_PROV_STATE
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:

Procedure SET_FE_PROV_STATE (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2 ) IS

BEGIN
-- RUN mode - normal process execution
--
        IF (funcmode = 'RUN') THEN
                resultout := 'COMPLETE:ACTIVITY_PERFORMED';
        END IF;
-- CANCEL mode - activity 'compensation'
--
-- This is in the event that the activity must be undone
-- for example when a process is reset to an earlier point
-- due to a loop back.
--


        IF (funcmode = 'RESPOND') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'FORWARD') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'TRANSFER') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'TIMEOUT') THEN
                resultout := 'COMPLETE';
                return;
        END IF;

        IF (funcmode = 'others') THEN
                resultout := ' ';
                return;
        END IF;

EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPSTATUS', 'SET_FE_PROV_STATE', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END SET_FE_PROV_STATE;

--This procedure sets the Line item status to the status
--that is assigned to the node in the workflow..
Procedure SET_NODE_LINE_STATUS (itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       OUT NOCOPY varchar2 ) IS

BEGIN
-- RUN mode - normal process execution
--
        IF (funcmode = 'RUN') THEN
                SetNodeLineStatus(itemtype, itemkey,actid);
                resultout := 'COMPLETE';
        ELSE
                resultout := 'COMPLETE';
                return;
        END IF;


EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPSTATUS', 'SET_NODE_LINE_STATUS', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END SET_NODE_LINE_STATUS;
--This procedure sets the work item status to the status
--that is assigned to the node in the workflow..
Procedure SET_NODE_WI_STATUS (itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       OUT NOCOPY varchar2 ) IS

BEGIN
-- RUN mode - normal process execution
--
        IF (funcmode = 'RUN') THEN
                SetNodeWIStatus(itemtype, itemkey,actid);
                resultout := 'COMPLETE';
        ELSE
                resultout := 'COMPLETE';
                return;
        END IF;


EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPSTATUS', 'SET_NODE_WI_STATUS', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END SET_NODE_WI_STATUS;




Function GetResubmissionJobID (itemtype in varchar2,
                               itemkey in varchar2) return number is
 l_JobID number;
 e_UnhandledException exception;
begin
 begin
   l_JobID := wf_engine.GetItemAttrNumber(itemtype => GetResubmissionJobID.itemtype,
                                          itemkey => GetResubmissionJobID.itemkey,
                                          aname => 'RESUBMISSION_JOB_ID');

 exception
 when others then
  if sqlcode = -20002 then
      l_JobID := 0;
      wf_core.clear;
  else
    raise e_UnhandledException;
  end if;
 end;

 return l_JobID;

End GetResubmissionJobID;

PROCEDURE SetErrorStatus(itemtype IN VARCHAR2,
                         itemkey  IN VARCHAR2,
                         actid    IN NUMBER)
IS

 l_error_itemtype  VARCHAR2(240);
 l_error_itemkey   VARCHAR2(240);
 l_OrderID         NUMBER;
 l_lineitemId      NUMBER ;
 l_WIInstanceID    NUMBER ;
 l_FAInstanceID    NUMBER ;
 l_order_count     NUMBER;
 l_line_count      NUMBER;
 l_pkg_count       NUMBER;
 l_workitem_count  NUMBER;
 l_fa_count        NUMBER;
 l_status          VARCHAR2(40);
 l_url             VARCHAR2(1000);

BEGIN
     l_error_itemtype  := WF_ENGINE.GETITEMATTRTEXT(itemtype => SetErrorStatus.itemtype,
                                                      itemkey  => SetErrorStatus.itemkey,
                                                      aname    => 'ERROR_ITEM_TYPE');

     l_error_itemkey   := WF_ENGINE.GETITEMATTRTEXT(itemtype => SetErrorStatus.itemtype,
                                                      itemkey  => SetErrorStatus.itemkey,
                                                      aname    => 'ERROR_ITEM_KEY');

     l_status          := WF_ENGINE.GetActivityattrtext(itemtype =>SetErrorStatus.itemtype,
                                                        itemkey  =>SetErrorStatus.itemkey,
                                                        actid    =>SetErrorStatus.actid,
                                                        aname    =>'STATUS');

     l_order_count     := instr(l_error_itemkey,'MAIN') ;
     l_line_count      := instr(l_error_itemkey,'SVC') ;
     l_pkg_count       := instr(l_error_itemkey,'LINE');
     l_workitem_count  := instr(l_error_itemkey,'WI') ;
     l_fa_count        := instr(l_error_itemkey,'FA') ;

     IF l_order_count > 0 THEN
        l_OrderID := WF_ENGINE.GETITEMATTRNUMBER(itemtype => l_error_itemtype,
                                                 itemkey  => l_error_itemkey,
                                                 aname    => 'ORDER_ID');
        UPDATE_XDP_ORDER_STATUS(l_status,l_orderID );

     ELSIF (l_line_count > 0 OR l_pkg_count > 0  )  THEN
           l_lineitemId := WF_ENGINE.GETITEMATTRNUMBER(itemtype => l_error_itemtype,
                                                       itemkey  => l_error_itemkey,
                                                       aname    => 'LINE_ITEM_ID');
           UPDATE_XDP_ORDER_LINE_STATUS(l_status,l_lineitemID);

     ELSIF (l_workitem_count > 0 AND l_fa_count = 0) THEN

           l_OrderID := WF_ENGINE.GETITEMATTRNUMBER(itemtype => l_error_itemtype,
                                                 itemkey  => l_error_itemkey,
                                                 aname    => 'ORDER_ID');

           l_WIInstanceID := wf_engine.GetItemAttrNumber(itemtype => l_error_itemtype,
                                                         itemkey  => l_error_itemkey,
                                                         aname    => 'WORKITEM_INSTANCE_ID');

           UPDATE_XDP_WORKITEM_STATUS(l_status,l_WIInstanceID);

           XDP_NOTIFICATIONS.Get_WI_Update_URL(l_WIInstanceID,
                                               l_OrderID,
                                               itemtype,
                                               itemKey,
                                               l_url);
           --10/04/2002 HBCHUNG
           --setting Notification URL
           wf_engine.SetItemAttrText(itemtype => itemtype,
                                      itemkey => itemkey,
                                        aname => 'ERROR_WI_UPDATE_URL',
                                       avalue => l_url);



     ELSIF l_fa_count > 0 THEN
           l_FAInstanceID := wf_engine.GetItemAttrNumber(itemtype => l_error_itemtype,
                                                         itemkey  => l_error_itemkey,
                                                         aname    => 'FA_INSTANCE_ID');
           UPDATE_XDP_FA_STATUS(l_status,l_FAInstanceID);
     END IF;

EXCEPTION
     WHEN others THEN
          wf_core.context('XDPSTATUS', 'SetErrorStatus', itemtype, itemkey, null,null);
          RAISE;
END SetErrorStatus;

PROCEDURE SETORDERSTATUS(itemtype IN VARCHAR2,
                         itemkey IN VARCHAR2)
IS
 l_OrderID        NUMBER;
 l_WorkitemStatus VARCHAR2(30);
 l_Status         VARCHAR2(30);
 l_AbortCount     NUMBER := 0;
 l_ErrorCount     NUMBER := 0;
 l_overridecount  NUMBER :=  0;
 l_Counter        NUMBER := 0;
 l_status_code    VARCHAR2(30);

 CURSOR c_getlines(orderid NUMBER) IS
  SELECT status_code
  FROM xdp_order_line_items
  WHERE order_id = orderid ;

BEGIN

 l_OrderID := WF_ENGINE.GETITEMATTRNUMBER(itemtype => SetOrderStatus.itemtype,
                                          itemkey  => SetOrderStatus.itemkey,
                                          aname    => 'ORDER_ID');


  IF c_GetLines%ISOPEN THEN
     CLOSE c_GetLines;
  END IF;


  OPEN c_GetLines(l_OrderID);

  LOOP
    FETCH c_GetLines INTO l_Status;
    EXIT WHEN c_GetLines%NOTFOUND;

     l_Counter := l_Counter + 1;

     IF l_Status = 'ERROR' THEN
        l_ErrorCount := l_ErrorCount + 1;
     END IF;

     IF l_Status = 'ABORTED' THEN
        l_AbortCount := l_AbortCount + 1;
     END IF;

     IF l_Status = 'SUCCESS_WITH_OVERRIDE' THEN
        l_overridecount := l_overridecount + 1;
     END IF;

  END LOOP;

    IF  l_ErrorCount > 0 THEN

        UPDATE_XDP_ORDER_STATUS('ERROR' , l_orderid );

    ELSIF l_overridecount > 0 THEN

          UPDATE_XDP_ORDER_STATUS('SUCCESS_WITH_OVERRIDE' , l_orderid );

    ELSIF l_AbortCount > 0 AND l_Counter = l_AbortCount THEN

          UPDATE_XDP_ORDER_STATUS('ABORTED' , l_orderid );
          XDP_ENGINE.Set_Order_Param_Value(l_orderid,'FULFILLMENT_STATUS','ABORTED');
    ELSE
        UPDATE_XDP_ORDER_STATUS('SUCCESS' , l_orderid );

    END IF;

 COMMIT;
EXCEPTION
WHEN others THEN
     wf_core.context('XDPSTATUS', 'SetOrderStatus', itemtype, itemkey, null,null);
     RAISE;
END SetOrderStatus;



PROCEDURE SendOrderStatus(itemtype in varchar2,
                         itemkey in varchar2,
                         actid in number)
is

 l_OrderID number;

 l_Message varchar2(80);
 l_SendFlag varchar2(10);

begin

 l_SendFlag :=  wf_engine.GetActivityAttrText( itemtype => SendOrderStatus.itemtype,
                                                itemkey => SendOrderStatus.itemkey,
                                                actid => SendOrderStatus.actid,
                                                aname => 'SEND_FLAG');

 /* Only if the SEND_FLAG is set to 'Y' will the message be sent */

 if l_SendFlag = 'Y' then

      l_OrderID := wf_engine.GetItemAttrNumber(itemtype => SendOrderStatus.itemtype,
                                             itemkey => SendOrderStatus.itemkey,
                                             aname => 'ORDER_ID');

      /* Enqueue into the Outboud Queue with the appropriate message */
      l_Message :=  wf_engine.GetActivityAttrText( itemtype => SendOrderStatus.itemtype,
                                                   itemkey => SendOrderStatus.itemkey,
                                                   actid => SendOrderStatus.actid,
                                                   aname => 'MESSAGE');

      if l_Message is null then
          l_Message := 'ORDER_STATUS';
      end if;

      /* Enqueue into the Outbound queue */

       /*
          SDP_AQ_UTILITIES.Enqeuee....
       */

  end if;

exception
when others then
   wf_core.context('XDPSTATUS', 'SendOrderStatus', itemtype, itemkey, to_char(actid),null);
   raise;
end SendOrderStatus;





PROCEDURE SETWORKITEMSTATUS(itemtype IN VARCHAR2,
                            itemkey  IN VARCHAR2)
IS
 l_WIInstanceID   NUMBER;
 l_dummy          NUMBER;
 l_Counter        NUMBER := 0;
 l_ErrorCount     NUMBER := 0;
 l_AbortCount     NUMBER := 0;
 l_RunningCount   NUMBER := 0;
 l_overridecount  NUMBER :=  0;
 l_status_code    VARCHAR2(30);
 l_Status         VARCHAR2(30);
 l_FAInstanceID   NUMBER;


 CURSOR c_GetFA(WIInstanceID NUMBER) IS
        SELECT STATUS_CODE,
               FA_INSTANCE_ID
          FROM XDP_FA_RUNTIME_LIST
         WHERE WORKITEM_INSTANCE_ID = WIInstanceID ;

BEGIN

 l_WIInstanceID := wf_engine.GetItemAttrNumber(itemtype => SetWorkitemStatus.itemtype,
                                               itemkey => SetWorkitemStatus.itemkey,
                                               aname => 'WORKITEM_INSTANCE_ID');


 IF c_GetFA%ISOPEN THEN
    CLOSE c_GetFA;
 END IF;

 OPEN c_GetFA(l_WIInstanceID);

 LOOP
   FETCH c_GetFA
    INTO l_Status, l_FAInstanceID ;
    EXIT WHEN c_GetFA%NOTFOUND;
     l_Counter := l_Counter + 1;
     IF l_Status = 'ERROR' THEN
        l_ErrorCount := l_ErrorCount + 1;
     END IF;

     IF l_Status = 'ABORTED' THEN
        l_AbortCount := l_AbortCount + 1;
     END IF;

     IF l_Status = 'SUCCESS_WITH_OVERRIDE' THEN
        l_overridecount := l_overridecount + 1;
     END IF;

 END LOOP;

 CLOSE c_GetFA;

            IF  l_ErrorCount > 0 then

                UPDATE_XDP_WORKITEM_STATUS('ERROR' , l_WIInstanceid );

            ELSIF  l_overridecount > 0 then

                UPDATE_XDP_WORKITEM_STATUS('SUCCESS_WITH_OVERRIDE' , l_WIInstanceid );

            ELSIF l_AbortCount > 0  AND l_AbortCount = l_Counter then

                UPDATE_XDP_WORKITEM_STATUS('ABORTED' , l_WIInstanceid );

            ELSE
                UPDATE_XDP_WORKITEM_STATUS('SUCCESS' , l_WIInstanceid );
        END IF;

EXCEPTION
     WHEN others THEN
          wf_core.context('XDPSTATUS', 'SetWorkitemStatus', itemtype, itemkey, null,null);
          RAISE;
END SETWORKITEMSTATUS;



PROCEDURE SetWIStatusSuccess (itemtype IN VARCHAR2,
                              itemkey  IN VARCHAR2)
IS
 l_WIInstanceID NUMBER;
BEGIN

 l_WIInstanceID := wf_engine.GetItemAttrNumber(itemtype => SetWIStatusSuccess.itemtype,
                                               itemkey  => SetWIStatusSuccess.itemkey,
                                               aname    => 'WORKITEM_INSTANCE_ID');

 UPDATE_XDP_WORKITEM_STATUS('SUCCESS' , l_WIInstanceID );

EXCEPTION
     WHEN others THEN
          wf_core.context('XDPSTATUS', 'SetWIStatusSuccess', itemtype, itemkey, null,null);
          RAISE;
END SetWIStatusSuccess;




Procedure SendWorkitemStatus(itemtype in varchar2,
                         itemkey in varchar2,
                         actid in number)
is

 l_OrderID number;
 l_WorkitemStatus varchar2(80);
 l_WIInstanceID number;

 l_Message varchar2(80);
 l_SendFlag varchar2(10);

begin

 l_SendFlag :=  wf_engine.GetActivityAttrText( itemtype => SendWorkitemStatus.itemtype,
                                                itemkey => SendWorkitemStatus.itemkey,
                                                actid => SendWorkitemStatus.actid,
                                                aname => 'SEND_FLAG');


 /* Only if the SEND_FLAG is 'Y' will  the message be sent */

 if l_SendFlag = 'Y' then

      l_OrderID := wf_engine.GetItemAttrNumber(itemtype => SendWorkitemStatus.itemtype,
                                               itemkey => SendWorkitemStatus.itemkey,
                                               aname => 'ORDER_ID');

      l_WIInstanceID := wf_engine.GetItemAttrNumber(itemtype => SendWorkitemStatus.itemtype,
                                                    itemkey => SendWorkitemStatus.itemkey,
                                                    aname => 'WORKITEM_INSTANCE_ID');


        /* Enqueue into the Outboud Queue with the appropriate message */
        l_Message :=  wf_engine.GetActivityAttrText( itemtype => SendWorkitemStatus.itemtype,
                                                     itemkey => SendWorkitemStatus.itemkey,
                                                     actid => SendWorkitemStatus.actid,
                                                     aname => 'MESSAGE');

        if l_Message is null then
            l_Message := 'WORKITEM_STATUS';
        end if;

        /* Enqueue into the Outbound queue */

         /*
            SDP_AQ_UTILITIES.Enqeuee....
         */

 end if;



exception
when others then
   wf_core.context('XDPSTATUS', 'SendWorkitemStatus', itemtype, itemkey, to_char(actid),null);
   raise;
end SendWorkitemStatus;




PROCEDURE SetFAStatus(itemtype IN VARCHAR2,
                      itemkey  IN VARCHAR2,
                      actid    IN NUMBER)
IS

 l_FAStatus          VARCHAR2(80);
 l_FAInstanceID      NUMBER;
 l_WIInstanceID      NUMBER;
 l_OrderID           NUMBER;
 l_LineItemID        NUMBER;
 l_ResubmissionJobID NUMBER;
 ErrCode             NUMBER;
 ErrStr              VARCHAR(2000);
 l_Event             VARCHAR2(80);
 l_ProvMode          VARCHAR2(80);
 x_progress          VARCHAR2(2000);

 e_SetFAStatusException EXCEPTION;

BEGIN

 l_FAInstanceID := wf_engine.GetItemAttrNumber(itemtype => SetFAStatus.itemtype,
                                               itemkey => SetFAStatus.itemkey,
                                               aname => 'FA_INSTANCE_ID');

 l_OrderID := wf_engine.GetItemAttrNumber(itemtype => SetFAStatus.itemtype,
                                               itemkey => SetFAStatus.itemkey,
                                               aname => 'ORDER_ID');

 l_WIInstanceID := wf_engine.GetItemAttrNumber(itemtype => SetFAStatus.itemtype,
                                               itemkey => SetFAStatus.itemkey,
                                               aname => 'WORKITEM_INSTANCE_ID');

 l_LineItemID := wf_engine.GetItemAttrNumber(itemtype => SetFAStatus.itemtype,
                                               itemkey => SetFAStatus.itemkey,
                                               aname => 'LINE_ITEM_ID');

   l_FAStatus := wf_engine.GetActivityAttrText( itemtype => SetFAStatus.itemtype,
                                                itemkey => SetFAStatus.itemkey,
                                                actid => SetFAStatus.actid,
                                                aname => 'FA_STATUS');

   l_ResubmissionJobID := GetResubmissionJobID(itemtype => SetFAStatus.itemtype,
                                              itemkey => SetFAStatus.itemkey);

   l_Event := wf_engine.GetActivityAttrText( itemtype => SetFAStatus.itemtype,
                                                itemkey => SetFAStatus.itemkey,
                                                actid => SetFAStatus.actid,
                                                aname => 'NOTIF_RESPONSE');

  /* Check if the FA is aborted. If so set the status of execution and abort yourself*/

  IF XDPCORE_FA.IsFAAborted(l_FAInstanceID) = TRUE THEN

     UPDATE_XDP_FA_STATUS(l_FAStatus,l_FAInstanceID);

      wf_engine.AbortProcess(itemtype => SetFAStatus.itemtype,
                             itemkey => SetFAStatus.itemkey);

      return;
  else
     /*
     ** If the Processing of the FA is Order Resubmission Only the FA Status is to be updated
     ** The complete Order status/state logic is to be ignored
     */

     IF l_ResubmissionJobID <>0 THEN
        SetFActionStatus(l_OrderID, l_LineItemID, l_WIInstanceID, l_FAInstanceID, 'FA_RE_EXECUTION', l_Event, 'FA_'||l_FAStatus, SetFAStatus.itemtype,SetFAStatus.itemkey,ErrCode, ErrStr);
     ELSE
        SetFActionStatus(l_OrderID, l_LineItemID, l_WIInstanceID, l_FAInstanceID, 'FA_EXECUTION', l_Event, 'FA_'||l_FAStatus, SetFAStatus.itemtype,SetFAStatus.itemkey,ErrCode, ErrStr);
     END IF;

     IF ErrCode <>0 THEN
        x_progress := 'In XDP_STATUS.SetFActionStatus. Error when updating status. Error: ' || SUBSTR(ErrStr, 1, 1500);
        RAISE e_SetFAStatusException;
     END IF;

 END If;


EXCEPTION
     WHEN e_SetFAStatusException THEN
          wf_core.context('XDPSTATUS', 'SetFAStatus', itemtype, itemkey, to_char(actid), x_progress);
          RAISE;
     WHEN others THEN
        wf_core.context('XDPSTATUS', 'SetFAStatus', itemtype, itemkey, to_char(actid),null);
        RAISE;
END SetFAStatus;



Procedure SetFeExecStatus(itemtype in varchar2,
                          itemkey in varchar2)
is
begin

 null;

exception
when others then
   wf_core.context('XDPSTATUS', 'SetFeExecStatus', itemtype, itemkey, null,null);
   raise;
end SetFeExecStatus;




Procedure SendFeProvStatus(itemtype in varchar2,
                           itemkey in varchar2,
                           actid in number)

is

 l_OrderID number;
 l_WIInstanceID number;
 l_FAInstanceID number;
 l_dummy1 number;

 l_FaCaller varchar2(10);
 l_ErrCode number;
 l_ErrDescription varchar2(800);

 l_Message varchar2(80);
 l_SendFlag varchar2(10);
 l_FeExecStatus varchar2(40);
 l_FAStatus varchar2(40);

 cursor cur_fa_status( cp_FAInstanceID in VARCHAR2 ) IS
 SELECT status_code
   FROM xdp_fa_runtime_list
  WHERE fa_instance_id = cp_FAInstanceID;

 e_SendMessageException exception;

 x_progress varchar2(2000);

begin

  l_FAInstanceID := wf_engine.GetItemAttrNumber(itemtype => SendFeProvStatus.itemtype,
                                                itemkey => SendFeProvStatus.itemkey,
                                                aname => 'FA_INSTANCE_ID');

  --From now on we will get this from runtime table.
  --Before we are doing it using Activity Attribute..
  FOR lv_fa_rec in cur_fa_status( l_FAInstanceID ) LOOP
    l_FeExecStatus :=  lv_fa_rec.STATUS_CODE;
  END LOOP;

  -- We reach this node only when the FA is success or
  -- Aborted. In Success with override case we have to publish
  -- this as SUCCESS case only, then only the user defined
  -- workflows will go thru as there will be either
  -- SUCCESS or ABORTED  transitions..
  IF l_FeExecStatus <> 'ABORTED' THEN
    l_FeExecStatus := 'SUCCESS';
  END IF;

  /* Check if the FA is aborted. If so set the status of execution and abort yourself*/

  if XDPCORE_FA.IsFAAborted(l_FAInstanceID) = TRUE then

     UPDATE_XDP_FA_STATUS(l_FeExecStatus,l_FAInstanceID);

      wf_engine.AbortProcess(itemtype => SendFeProvStatus.itemtype,
                             itemkey => SendFeProvStatus.itemkey);

  else

     l_SendFlag :=  wf_engine.GetActivityAttrText( itemtype => SendFeProvStatus.itemtype,
                                                   itemkey => SendFeProvStatus.itemkey,
                                                   actid => SendFeProvStatus.actid,
                                                   aname => 'SEND_FLAG');

     /* Only if the Send Flag has been set to be 'Y' the message will be sent */
     if l_SendFlag = 'Y' then

        l_WIInstanceID := wf_engine.GetItemAttrNumber(itemtype => SendFeProvStatus.itemtype,
                                                      itemkey => SendFeProvStatus.itemkey,
                                                      aname => 'WORKITEM_INSTANCE_ID');



        l_OrderID := wf_engine.GetItemAttrNumber(itemtype => SendFeProvStatus.itemtype,
                                                 itemkey => SendFeProvStatus.itemkey,
                                                 aname => 'ORDER_ID');


        l_Message :=  wf_engine.GetActivityAttrText( itemtype => SendFeProvStatus.itemtype,
                                                     itemkey => SendFeProvStatus.itemkey,
                                                     actid => SendFeProvStatus.actid,
                                                     aname => 'MESSAGE');

           if l_Message is null then
               l_Message := 'FE_EXEC_DONE';
           end if;

           -- if defined publish the status that user wants..
           -- bug fix 2617807. In case user is not publishing the FA_STATUS(ER#2350281)
           -- catch 1403 and ignore..
           BEGIN
             l_FAStatus := xdp_engine.get_fa_param_value( l_FAInstanceID, 'FA_STATUS' );
           EXCEPTION
             WHEN NO_DATA_FOUND THEN
               NULL;
             WHEN OTHERS THEN
              RAISE;
           END;
           IF( l_FAStatus is NOT NULL ) THEN
             l_FeExecStatus := l_FAStatus;
           END IF;

           /* Enqueue into the Message into event manager queue */

            XNP_FA_DONE_U.Publish(XNP$SDP_RESULT_CODE => l_FeExecStatus,
                            X_MESSAGE_ID => l_dummy1,
                            X_ERROR_CODE => l_ErrCode,
                            X_ERROR_MESSAGE =>l_ErrDescription,
                            P_CONSUMER_LIST => null,
                            P_SENDER_NAME  => null,
                            P_RECIPIENT_LIST => null,
                            P_VERSION   => null,
                            P_REFERENCE_ID => l_FAInstanceID,
                            P_OPP_REFERENCE_ID => null,
                            P_ORDER_ID   => l_OrderID,
                            P_WI_INSTANCE_ID  => l_WIInstanceID,
                            P_FA_INSTANCE_ID=> l_FAInstanceID);

            if l_ErrCode <> 0 then
               x_progress := 'Error when trying to send FA_DONE Message. Code: ' ||
                              to_char(l_ErrCode) || ' Error String: ' ||
                              substr(l_ErrDescription, 1, 1000);
               Raise e_SendMessageException;
            end if;

       end if;
  end if;

exception
when e_SendMessageException then
   wf_core.context('XDPSTATUS', 'SendFeProvStatus', itemtype, itemkey, to_char(actid), x_progress);
   raise;
when others then
   wf_core.context('XDPSTATUS', 'SendFeProvStatus', itemtype, itemkey, to_char(actid),null);
   raise;
end SendFeProvStatus;


PROCEDURE UpdateFAStatus( faid     IN NUMBER,
                          status   IN VARCHAR2,
                          provmode IN VARCHAR2)
IS
l_status_code   VARCHAR2(30);

BEGIN
 IF status = 'SUCCESS' THEN

  /*
   * FA Execution is successful
   */

 /* The FA was retried and then success ful hence the status should be SUCCESS_WITH_OVERRIDE */

    IF provmode = 'RETRY' THEN

       UPDATE_XDP_FA_STATUS('SUCCESS_WITH_OVERRIDE' , faid) ;
    ELSE
       UPDATE_XDP_FA_STATUS('SUCCESS' , faid) ;
    END IF;

 ELSE
       UPDATE_XDP_FA_STATUS('SUCCESS' , faid) ;

 END IF;

EXCEPTION
     WHEN others THEN
          wf_core.context('XDPSTATUS', 'UpdateFAStatus', null, null, null,null);
          RAISE;
END UpdateFAStatus;


Procedure SendLineStatus(itemtype in varchar2,
                         itemkey in varchar2,
                         actid in number)
is

begin
   null;

exception
when others then
   wf_core.context('XDPSTATUS', 'SendLineStatus', null, null, null,null);
   raise;
end SendLineStatus;


Procedure SetBundleStatus (itemtype in varchar2,
                           itemkey in varchar2)
is

begin
   null;

exception
when others then
   wf_core.context('XDPSTATUS', 'SetBundleStatus', null, null, null,null);
   raise;
end SetBundleStatus;


PROCEDURE SetLineStatus (itemtype IN VARCHAR2,
                         itemkey  IN VARCHAR2)
IS

 l_LineItemID       NUMBER;
 l_WIInstanceID     NUMBER;
 l_OrderID          NUMBER;
 l_dummy            NUMBER;
 l_ErrorCount       NUMBER := 0;
 l_AbortCount       NUMBER := 0;
 l_Counter          NUMBER := 0;
 l_overridecount    NUMBER := 0;
 l_Status           VARCHAR2(40);
 l_Status_code      VARCHAR2(40);


 CURSOR c_GetWI(OrderID number, LineItemID number) IS
        SELECT STATUS_CODE,
               WORKITEM_INSTANCE_ID
          FROM XDP_FULFILL_WORKLIST
         WHERE ORDER_ID     = OrderID
           AND LINE_ITEM_ID = LineItemID ;

BEGIN

 l_OrderID := wf_engine.GetItemAttrNumber(itemtype => SetLineStatus.itemtype,
                                          itemkey => SetLineStatus.itemkey,
                                          aname => 'ORDER_ID');

 l_LineItemID := wf_engine.GetItemAttrNumber(itemtype => SetLineStatus.itemtype,
                                             itemkey => SetLineStatus.itemkey,
                                             aname => 'LINE_ITEM_ID');

 IF c_GetWI%ISOPEN THEN
    CLOSE c_GetWI;
 END IF;

 OPEN c_GetWI(l_OrderID, l_LineItemID);

 LOOP
   FETCH c_GetWI INTO l_Status, l_WIInstanceID;
    EXIT WHEN c_GetWI%NOTFOUND;

     l_Counter := l_Counter + 1;

     IF l_Status = 'ERROR' THEN
        l_ErrorCount := l_ErrorCount + 1;
     END IF;

     IF l_status = 'SUCCESS_WITH_OVERRIDE' THEN
        l_overridecount := l_overridecount + 1 ;
     END IF ;

     IF l_Status = 'ABORTED' THEN
        l_AbortCount := l_AbortCount + 1;
     END IF;

 END LOOP;

 CLOSE c_GetWI;

 IF  l_ErrorCount > 0 THEN
     UPDATE_XDP_ORDER_LINE_STATUS('ERROR' ,  l_lineitemid );

 ELSIF l_AbortCount > 0  AND  l_Counter = l_AbortCount THEN
     UPDATE_XDP_ORDER_LINE_STATUS('ABORTED' ,  l_lineitemid );

 ELSIF l_overridecount > 0 THEN
     UPDATE_XDP_ORDER_LINE_STATUS('SUCCESS_WITH_OVERRIDE' , l_lineitemid );

 ELSE
     UPDATE_XDP_ORDER_LINE_STATUS('SUCCESS' ,  l_lineitemid );

 END IF;

EXCEPTION
     WHEN others THEN
          wf_core.context('XDPSTATUS', 'SetLineStatus', null, null, null,null);
          RAISE;
END SetLineStatus;



Procedure SetPackageStatus (itemtype in varchar2,
                         itemkey in varchar2)
is

begin
   null;

exception
when others then
   wf_core.context('XDPSTATUS', 'SetPackageStatus', null, null, null,null);
   raise;
end SetPackageStatus;


Procedure SaveWorkitem (itemtype in varchar2,
                        itemkey in varchar2,
                        actid in number)
IS
 l_WIInstanceID number;

 l_Status varchar2(40);

BEGIN


  l_Status :=  wf_engine.GetActivityAttrText( itemtype => SaveWorkitem.itemtype,
                                              itemkey => SaveWorkitem.itemkey,
                                              actid => SaveWorkitem.actid,
                                              aname => 'WORKITEM_STATUS');

  l_WIInstanceID := wf_engine.GetItemAttrNumber(itemtype => SaveWorkitem.itemtype,
                                                itemkey => SaveWorkitem.itemkey,
                                                aname => 'WORKITEM_INSTANCE_ID');

  UPDATE_XDP_WORKITEM_STATUS(l_Status, l_WIINstanceID);

EXCEPTION
     WHEN others THEN
        wf_core.context('XDPSTATUS', 'SaveWorkitem', itemtype, itemkey, to_char(actid), null);
        raise;
END SaveWorkitem;


Procedure SetFActionStatus (OrderID            IN NUMBER,
                            LineItemID         IN NUMBER,
                            WorkitemInstanceID IN NUMBER,
                            FAInstanceID       IN NUMBER,
                            Caller             IN VARCHAR2,
                            Event              IN VARCHAR2,
                            Status             IN VARCHAR2,
                            ItemType           IN VARCHAR2,
                            Itemkey            IN VARCHAR2,
                            ErrCode           OUT NOCOPY NUMBER,
                            ErrStr            OUT NOCOPY VARCHAR2)
IS
 x_progress VARCHAR2(2000);

BEGIN

 IF Caller = 'FA_EXECUTION' THEN

       IF Status = 'FA_ERROR' AND Event IS null THEN
          /* Set the Status of the FA just to be Error */
          SetStatusForFA(FAInstanceID, 'ERROR', null);
--          SetStatusForWI(WorkitemInstanceID, 'ERROR', null);
--          SetStatusForLine(OrderID, WorkitemInstanceID, LineItemID, 'ERROR', null);
--          SetStatusForOrder(OrderID, 'ERROR', null);
       ELSIF Event = 'CONTINUE_FA_PROCESSING' THEN
          /* The Caller had done a Continue from the FMC */
          SetStatusForFA(FAInstanceID, 'SUCCESS_WITH_OVERRIDE', 'CONTINUE_FA_PROCESSING');
--          SetStatusForWI(WorkitemInstanceID, 'SUCCESS', null);
--          SetStatusForLine(OrderID, WorkitemInstanceID, LineItemID, 'SUCCESS', null);
--          SetStatusForOrder(OrderID, 'SUCCESS', null);
       ELSIF Event = 'STOP_FA_PROCESSING' THEN
          /* User selected Abort FA Processing from FMC */
          SetStatusForFA(FAInstanceID, 'ABORTED', 'STOP_FA_PROCESSING');
--          SetStatusForWI(WorkitemInstanceID, 'SUCCESS', null);
--          SetStatusForLine(OrderID, WorkitemInstanceID, LineItemID, 'SUCCESS', null);
--          SetStatusForOrder(OrderID, 'SUCCESS', null);
       ELSIF Status = 'FA_SUCCESS' THEN
          SetStatusForFA(FAInstanceID, 'SUCCESS', null);
--          SetStatusForWI(WorkitemInstanceID, 'SUCCESS', null);
--          SetStatusForLine(OrderID, WorkitemInstanceID, LineItemID, 'SUCCESS', null);
--          SetStatusForOrder(OrderID, 'SUCCESS', null);
       ELSIF Status = 'FA_IN_PROGRESS' THEN
          SetStatusForFA(FAInstanceID,'IN_PROGRESS',null);
       ELSIF Status = 'FA_SYSTEM_HOLD' THEN
          SetStatusForFA(FAInstanceID,'SYSTEM_HOLD',null);
       END IF;
 ELSIF Caller = 'FA_RE_EXECUTION' THEN
       IF Status = 'FA_ERROR' AND Event IS null THEN
          /* Set the Status of the FA just to be Error */
          SetStatusForFA(FAInstanceID, 'ERROR', null);
       ELSIF Event = 'CONTINUE_FA_PROCESSING' THEN
          /* The Caller had done a Continue from the FMC */
          SetStatusForFA(FAInstanceID, 'SUCCESS_WITH_OVERRIDE', 'CONTINUE_FA_PROCESSING');
       ELSIF Event = 'STOP_FA_PROCESSING' THEN
          /* User selected Abort FA Processing from FMC */
          SetStatusForFA(FAInstanceID, 'ABORTED', 'STOP_FA_PROCESSING');
       ELSIF Status = 'FA_SUCCESS' THEN
          SetStatusForFA(FAInstanceID, 'SUCCESS', null);
--          SetStatusForWI(WorkitemInstanceID, 'SUCCESS', null);
--          SetStatusForLine(OrderID, WorkitemInstanceID, LineItemID, 'SUCCESS', null);
--          SetStatusForOrder(OrderID, 'SUCCESS', null);
       ELSIF Status = 'FA_IN_PROGRESS' THEN
          SetStatusForFA(FAInstanceID,'IN_PROGRESS',null);
       ELSIF Status = 'FA_SYSTEM_HOLD' THEN
          SetStatusForFA(FAInstanceID,'SYSTEM_HOLD',null);
       END IF;
 ELSIF Caller = 'API_EXEC' THEN
   null;
 END IF;

EXCEPTION
     WHEN others THEN
          x_progress := 'In XDPSTATUS.SetFActionStatus. Unhandled Exception. Error: ' || SUBSTR(SQLERRM, 1, 1500);
          wf_core.context('XDPSTATUS', 'SetFActionStatus',itemtype, itemkey, null, x_progress);
          RAISE;
END SetFActionStatus;






PROCEDURE SetStatusForFA (FAInstanceID IN NUMBER,
                          Status       IN VARCHAR2,
                          Event        IN VARCHAR2)
IS

 l_FAStatus       VARCHAR2(40);
 l_FAState        VARCHAR2(40);
 l_fA_status_code VARCHAR2(40);

 CURSOR c_GetFaStat IS
        SELECT Status_code
          FROM XDP_FA_RUNTIME_LIST
         WHERE FA_INSTANCE_ID = FAInstanceID;
--         FOR UPDATE;

 x_progress VARCHAR2(2000);

 e_InvalidConfigException EXCEPTION;

BEGIN

   OPEN c_GetFaStat;
   FETCH c_GetFaStat INTO l_FAStatus;

   IF c_GetFAStat%NOTFOUND THEN
      RAISE e_InvalidConfigException;
   END IF;

   IF Event is null  AND Status = 'ERROR' THEN

      UPDATE_XDP_FA_STATUS(status , FAInstanceId );

   ELSIF Event IS NULL AND Status = 'SUCCESS' THEN
     IF l_FAStatus = 'ERROR' THEN

        UPDATE_XDP_FA_STATUS('SUCCESS_WITH_OVERRIDE' , FAInstanceId );

     ELSE
      UPDATE_XDP_FA_STATUS('SUCCESS' , FAInstanceId );

     END IF;

   ELSIF Event = 'CONTINUE_FA_PROCESSING' THEN
      UPDATE_XDP_FA_STATUS(status , FAInstanceId );

   ELSIF Event = 'STOP_FA_PROCESSING' THEN
      UPDATE_XDP_FA_STATUS(status , FAInstanceId );
   ELSIF Status = 'IN_PROGRESS' THEN
      UPDATE_XDP_FA_STATUS('IN PROGRESS' , FAInstanceId );
   ELSIF Status = 'FA_SYSTEM_HOLD' THEN
      UPDATE_XDP_FA_STATUS('SYSTEM_HOLD' , FAInstanceId );
   END IF;

   CLOSE c_GetFAStat;

EXCEPTION
     WHEN others THEN
          x_progress := 'In XDPSTATUS.SetStatusForFA. Unhandled Exception. Error: ' || SUBSTR(SQLERRM, 1,1500);
          wf_core.context('XDPSTATUS', 'SetStatusForFA', null, null, null, x_progress);
          RAISE;
END SetStatusForFA;

PROCEDURE SetStatusForWI (WorkitemInstanceID IN NUMBER,
                                Status       IN VARCHAR2,
                                Event        IN VARCHAR2)

IS
 CURSOR c_GetWIStat IS
        SELECT Status_code
          FROM XDP_FULFILL_WORKLIST
         WHERE WORKITEM_INSTANCE_ID = WorkitemInstanceID;
--           FOR UPDATE;

 CURSOR c_GetFA IS
        SELECT 1
          FROM XDP_FA_RUNTIME_LIST
         WHERE WORKITEM_INSTANCE_ID = WorkitemInstanceID
           AND STATUS_CODE          = 'ERROR' ;


 l_WIStatus VARCHAR2(40);
 l_WIState  VARCHAR2(40);
 l_FAStatus VARCHAR2(40);


 l_Counter         NUMBER  := 0 ;
 l_overridecounter NUMBER  := 0 ;
 x_progress        VARCHAR2(2000);

 e_InvalidConfigException EXCEPTION;

BEGIN

   OPEN c_GetWIStat;
   FETCH c_GetWIStat into l_WIStatus;

   IF c_GetWIStat%NOTFOUND then
      RAISE e_InvalidConfigException;
   END IF;


   IF Event IS NULL AND status = 'ERROR' THEN

      UPDATE_XDP_WORKITEM_STATUS(Status,WorkitemInstanceID);

   ELSIF Event IS NULL AND Status = 'SUCCESS' THEN

      FOR v_GetFA in c_GetFA
          LOOP
                l_Counter := l_Counter + 1;
          END LOOP;

      IF l_Counter = 0 THEN

         UPDATE_XDP_WORKITEM_STATUS('IN PROGRESS',workiteminstanceid);

      END IF;

   END IF;

   CLOSE c_GetWIStat;

EXCEPTION
     WHEN others THEN
          IF c_GetWIStat%ISOPEN THEN
             CLOSE c_GetWIStat;
          END IF;
          wf_core.context('XDPSTATUS', 'SetStatusForWI', null, null, null, x_progress);
          RAISE;
END SetStatusForWI;

PROCEDURE SetStatusForLine ( OrderID           IN NUMBER,
                            WorkitemInstanceID IN NUMBER,
                            LineItemID         IN NUMBER,
                            Status             IN VARCHAR2,
                            Event              IN VARCHAR2)

IS
 l_LineItemID NUMBER;
 CURSOR c_GetLineStat(LineID number) IS
        SELECT Status_code,
               IS_VIRTUAL_LINE_FLAG,
               NVL(BUNDLE_ID,-999)
          FROM XDP_ORDER_LINE_ITEMS
          WHERE LINE_ITEM_ID = LineID;
--         FOR UPDATE;

 CURSOR c_GetLineID IS
   SELECT line_item_id
     FROM XDP_FULFILL_WORKLIST
    WHERE WOrkitem_instance_id = WorkitemInstanceID;

 CURSOR c_GetWI(LineID number) IS
        SELECT STATUS_CODE,
               WORKITEM_INSTANCE_ID
          FROM XDP_FULFILL_WORKLIST
         WHERE LINE_ITEM_ID = LineID
           AND STATUS_CODE  = 'ERROR';

 CURSOR c_GetPackagedLines(VirtualLine number) IS
        SELECT RELATED_LINE_ITEM_ID
          FROM XDP_LINE_RELATIONSHIPS
         WHERE LINE_ITEM_ID = VirtualLine
           AND LINE_RELATIONSHIP = 'IS_PART_OF_PACKAGE';

 CURSOR c_UpdatePackage(PackageLineID number) IS
       SELECT 1
         FROM XDP_ORDER_LINE_ITEMS
        WHERE LINE_ITEM_ID  = PackageLineID;
--       FOR UPDATE;

 CURSOR c_GetPackagedLineStatus(VirtualLine number) IS
        SELECT XLR.RELATED_LINE_ITEM_ID,
               XOL.STATUS_CODE
          FROM XDP_LINE_RELATIONSHIPS XLR,
               XDP_ORDER_LINE_ITEMS XOL
         WHERE XLR.RELATED_LINE_ITEM_ID = (
                                    SELECT RELATED_LINE_ITEM_ID
                                      FROM XDP_LINE_RELATIONSHIPS
                                     WHERE LINE_ITEM_ID = VirtualLine)
           AND XLR.LINE_ITEM_ID = XOL.LINE_ITEM_ID
           AND XOL.IS_VIRTUAL_LINE_FLAG = 'Y';

 CURSOR c_GetBundledLines (LineItemID number, BundleID number) is
  SELECT LINE_ITEM_ID
   FROM XDP_ORDER_LINE_ITEMS
  WHERE LINE_ITEM_ID = LineItemID
    AND BUNDLE_ID = BundleID
    AND STATUS_CODE = 'ERROR';

 CURSOR C_UpdateBundleStatus(BundleID number) IS
        SELECT 1
          FROM XDP_ORDER_BUNDLES
         WHERE ORDER_ID = OrderID
           AND BUNDLE_ID = BundleID;
--           FOR UPDATE;


 l_LineStatus    VARCHAR2(40);
 l_LineState     VARCHAR2(40);
 l_Counter       NUMBER := 0;
 l_BundleID      NUMBER;
 l_RelatedLineID NUMBER := 0;
 l_PackageStatus VARCHAR2(40);
 l_PkgCount      NUMBER := 0;
 l_BundleCount   NUMBEr := 0;
 l_IsVirtualLine VARCHAR2(2);

 x_progress      VARCHAR2(2000);

 e_InvalidConfigException exception;
begin

  if LineItemID is null then
     Open c_GetLineID;
     Fetch c_GetLineID into l_LineItemID;
     close c_GetLineID;
  else
     l_LineItemID := LineItemID;
  end if;


   Open c_GetLineStat(l_LineItemID);
   Fetch c_GetLineStat
    INTO l_LineStatus,
         l_IsVirtualLine,
         l_BundleID;

   if c_GetLineStat%NOTFOUND then
      Raise e_InvalidConfigException;
   end if;


   if Event is null and Status = 'ERROR' then

      UPDATE_XDP_ORDER_LINE_STATUS(Status,l_LineItemID);

      if l_IsVirtualLine = 'Y' then

         FOR v_GetPackagedLine in c_GetPackagedLines(l_LineItemID) LOOP
             FOR v_UpdatePackageLine in c_UpdatePackage(v_GetPackagedLine.RELATED_LINE_ITEM_ID) LOOP

                 UPDATE_XDP_ORDER_LINE_STATUS(Status,v_GetPackagedLine.RELATED_LINE_ITEM_ID);

             END LOOP;
         END LOOP;
      end if;

      if l_BundleID <> -999 then

         UPDATE_XDP_ORDER_BUNDLE_STATUS('ERROR',OrderID,l_BundleID);

      end if;


   elsif Event is null and Status = 'SUCCESS' then
      FOR v_GetWI in c_GetWI(l_LineItemID) LOOP
        l_Counter := l_Counter + 1;
      END LOOP;

      if l_Counter = 0 then

         UPDATE_XDP_ORDER_LINE_STATUS('IN PROGRESS',l_LineItemID);

      end if;

      if l_IsVirtualLine = 'Y' then
         FOR v_GetPackagedLineStatus in c_GetPackagedLineStatus(l_LineItemID) LOOP
             l_RelatedLineID := v_GetPackagedLineStatus.RELATED_LINE_ITEM_ID;
             if v_GetPackagedLineStatus.STATUS_CODE = 'ERROR' THEN
               l_PkgCount := l_PkgCount + 1;
             end if;
         END LOOP;

         if l_PkgCount = 0 then

            UPDATE_XDP_ORDER_LINE_STATUS('IN PROGRESS',l_RelatedLineID);
         end if;
         if l_BundleID <> -999  then
            FOR v_GetBundlesLines in c_GetBundledLines(l_LineItemID, l_BundleID) LOOP
               l_BundleCount := l_BundleCount + 1;
            END LOOP;

            if l_PkgCount = 0 then

               UPDATE_XDP_ORDER_BUNDLE_STATUS('IN PROGRESS',OrderID,l_BundleID);

            end if;
         end if;
      end if;
   end if;

   close c_GetLineStat;

exception
when others then
  if c_GetLineStat%ISOPEN then
     close c_GetLineStat;
  end if;

  if c_GetLineID%ISOPEN then
     close c_GetLineID;
  end if;

  wf_core.context('XDPSTATUS', 'SetStatusForLine', null, null, null, x_progress);
  raise;
end SetStatusForLine;


Procedure SetStatusForOrder (OrderID in number,
                             Status in varchar2,
                             Event in varchar2)

is
 cursor c_GetOrderStat is
  select Status_code
   from XDP_ORDER_HEADERS
   where ORDER_ID = OrderID;
--  for update;

 cursor c_GetLines is
  select 1
  from XDP_ORDER_LINE_ITEMS
  where ORDER_ID = OrderID
    and STATUS_CODE = 'ERROR';

 l_OrderStatus varchar2(40);
 l_OrderState varchar2(40);
 l_Counter number := 0;

 x_progress varchar2(2000);

 e_InvalidConfigException exception;
begin

   Open c_GetOrderStat;
   Fetch c_GetOrderStat
    INTO l_OrderStatus;
   if c_GetOrderStat%NOTFOUND then
      Raise e_InvalidConfigException;
   end if;


   if Event is null and Status = 'ERROR' then

      UPDATE_XDP_ORDER_STATUS(Status,orderID) ;

   elsif Event is null and Status = 'SUCCESS' then
      FOR v_GetLines in c_GetLines LOOP
          l_Counter := l_Counter + 1;
      END LOOP;

      if l_Counter = 0 then

         UPDATE_XDP_ORDER_STATUS('IN PROGRESS',orderID) ;
     end if;
   end if;

   close c_GetOrderStat;

exception
when others then
  if c_GetOrderStat%ISOPEN then
     close c_GetOrderStat;
  end if;

  wf_core.context('XDPSTATUS', 'SetStatusForOrder', null, null, null, x_progress);
  raise;
end SetStatusForOrder;


PROCEDURE UPDATE_XDP_ORDER_BUNDLE_STATUS(p_status    IN VARCHAR2,
                                         p_order_id  IN NUMBER,
                                         p_bundle_id IN NUMBER) IS
PRAGMA AUTONOMOUS_TRANSACTION ;
x_progress VARCHAR2(2000);

BEGIN
         UPDATE xdp_order_bundles
            SET status            = p_status,
                last_update_date  = sysdate,
                last_updated_by   = fnd_global.user_id,
                last_update_login = fnd_global.login_id
          WHERE order_id  = p_order_id
            AND bundle_id = p_bundle_id ;
COMMIT;

EXCEPTION
     WHEN others THEN
          wf_core.context('XDPSTATUS', 'UPDATE_XDP_ORDER_STATUS', null, null, null, x_progress);
          ROLLBACK;
          RAISE ;

END UPDATE_XDP_ORDER_BUNDLE_STATUS ;



PROCEDURE UPDATE_XDP_ORDER_STATUS(p_status   IN VARCHAR2,
                                  p_order_id IN NUMBER) IS
PRAGMA AUTONOMOUS_TRANSACTION ;
x_progress VARCHAR2(2000);

BEGIN
   IF p_status IN ('SUCCESS_WITH_OVERRIDE','ABORTED','SUCCESS') THEN

     UPDATE xdp_order_headers
        SET status_code       = p_status ,
            completion_date   = sysdate ,
            last_update_date  = sysdate,
            last_updated_by   = fnd_global.user_id,
            last_update_login = fnd_global.login_id
      WHERE order_id          = p_order_id ;
   ELSE
     UPDATE xdp_order_headers
        SET status_code       = p_status ,
            last_update_date  = sysdate,
            last_updated_by   = fnd_global.user_id,
            last_update_login = fnd_global.login_id
      WHERE order_id          = p_order_id ;

   END IF ;

COMMIT;

EXCEPTION
     WHEN others THEN
          wf_core.context('XDPSTATUS', 'UPDATE_XDP_ORDER_STATUS', null, null, null, x_progress);
          ROLLBACK;
          RAISE ;
END UPDATE_XDP_ORDER_STATUS;



PROCEDURE UPDATE_XDP_ORDER_LINE_STATUS(p_status   IN VARCHAR2,
                                       p_line_item_id IN NUMBER)IS
PRAGMA AUTONOMOUS_TRANSACTION ;
x_progress VARCHAR2(2000);


BEGIN
  IF p_status IN ('IN PROGRESS','ERROR') THEN

     UPDATE xdp_order_line_items
        SET status_code       = p_status ,
            last_update_date  = sysdate,
            last_updated_by   = fnd_global.user_id,
            last_update_login = fnd_global.login_id
      WHERE line_item_id = p_line_item_id ;
  ELSE
     UPDATE xdp_order_line_items
        SET status_code       = p_status ,
            completion_date   = sysdate ,
            last_update_date  = sysdate,
            last_updated_by   = fnd_global.user_id,
            last_update_login = fnd_global.login_id
      WHERE line_item_id = p_line_item_id ;
  END IF ;

COMMIT;

EXCEPTION
     WHEN others THEN
          wf_core.context('XDPSTATUS', 'UPDATE_XDP_ORDER_LINE_STATUS', null, null, null, x_progress);
          ROLLBACK;
          RAISE ;
END UPDATE_XDP_ORDER_LINE_STATUS;



PROCEDURE UPDATE_XDP_WORKITEM_STATUS(p_status               IN VARCHAR2,
                                     p_workitem_instance_id IN NUMBER)IS
PRAGMA AUTONOMOUS_TRANSACTION ;
x_progress VARCHAR2(2000);


BEGIN
  IF p_status IN ('IN PROGRESS','ERROR') THEN

     UPDATE xdp_fulfill_worklist
        SET status_code       = p_status ,
            last_update_date  = sysdate,
            last_updated_by   = fnd_global.user_id,
            last_update_login = fnd_global.login_id
      WHERE workitem_instance_id = p_workitem_instance_id ;
  ELSE
     UPDATE xdp_fulfill_worklist
        SET status_code       = p_status ,
            completion_date   = sysdate ,
            last_update_date  = sysdate,
            last_updated_by   = fnd_global.user_id,
            last_update_login = fnd_global.login_id
      WHERE workitem_instance_id = p_workitem_instance_id ;
  END IF ;

COMMIT;

EXCEPTION
     WHEN others THEN
          wf_core.context('XDPSTATUS', 'UPDATE_XDP_WORKITEM_STATUS', null, null, null, x_progress);
          ROLLBACK;
          RAISE ;
END UPDATE_XDP_WORKITEM_STATUS;



PROCEDURE UPDATE_XDP_FA_STATUS(p_status         IN VARCHAR2,
                               p_fa_instance_id IN NUMBER)IS
PRAGMA AUTONOMOUS_TRANSACTION ;
x_progress VARCHAR2(2000);


BEGIN
  IF p_status IN ('IN PROGRESS','ERROR') THEN

     UPDATE xdp_fa_runtime_list
        SET status_code       = p_status ,
            last_update_date  = sysdate,
            last_updated_by   = fnd_global.user_id,
            last_update_login = fnd_global.login_id
      WHERE fa_instance_id = p_fa_instance_id ;
  ELSE
    UPDATE xdp_fa_runtime_list
        SET status_code       = p_status ,
            completion_date   = sysdate ,
            last_update_date  = sysdate,
            last_updated_by   = fnd_global.user_id,
            last_update_login = fnd_global.login_id
      WHERE fa_instance_id = p_fa_instance_id ;

  END IF ;

COMMIT;

EXCEPTION
     WHEN others THEN
          wf_core.context('XDPSTATUS', 'UPDATE_XDP_FA_STATUS', null, null, null, x_progress);
          ROLLBACK;
          RAISE ;
END UPDATE_XDP_FA_STATUS;


FUNCTION IS_ORDER_IN_ERROR (p_order_id IN NUMBER)
   RETURN BOOLEAN IS

l_status   BOOLEAN := FALSE ;

CURSOR c_order IS
     SELECT 'Y'
       FROM xdp_order_headers oh
      WHERE order_id = p_order_id
        AND (EXISTS  (SELECT 'Y'
                       FROM xdp_order_line_items oli
                      WHERE oli.order_id = oh.ordeR_id
                        AND oli.status_code = 'ERROR' ) OR
             EXISTS  (SELECT 'Y'
                       FROM xdp_fulfill_worklist fw
                      WHERE fw.order_id = oh.order_id
                        AND fw.status_code = 'ERROR') OR
             EXISTS  (SELECT 'Y'
                       FROM xdp_fulfill_worklist fw,
                            xdp_fa_runtime_list fr
                      WHERE fw.workitem_instance_id = fr.workitem_instance_id
                        AND fw.order_id = oh.order_id
                        AND fr.status_code = 'ERROR')) ;


BEGIN
     FOR c_order_rec IN c_order
         LOOP
            l_status := TRUE;
         END LOOP ;

RETURN l_status ;
END IS_ORDER_IN_ERROR ;


FUNCTION IS_LINE_IN_ERROR(p_lineitem_id IN NUMBER)
         RETURN BOOLEAN IS

l_status   BOOLEAN := FALSE ;

CURSOR c_lines IS
       SELECT 'Y' ,
              is_package_flag ,
              is_virtual_line_flag,
              line_item_id,
              ib_source,
              ib_source_id
         FROM xdp_order_line_items
        WHERE line_item_id = p_lineitem_id ;

CURSOR c_order_line IS
     SELECT 'Y'
       FROM xdp_order_line_items  oli
      WHERE line_item_id = p_lineitem_id
        AND ( EXISTS (SELECT 'Y'
                      FROM xdp_fulfill_worklist fw
                     WHERE fw.line_item_id  = oli.line_item_id
                       AND fw.status_code   = 'ERROR') OR
              EXISTS (SELECT 'Y'
                      FROM xdp_fulfill_worklist fw,
                           xdp_fa_runtime_list fr
                     WHERE fw.workitem_instance_id = fr.workitem_instance_id
                       AND fw.line_item_id         = oli.line_item_id
                       AND fr.status_code          = 'ERROR')) ;

CURSOR c_order_pkg_line(lv_line_item_id IN NUMBER) IS
       SELECT 'Y'
         FROM xdp_line_relationships lr
        WHERE lr.related_line_item_id = lv_line_item_id
          AND (EXISTS (SELECT 'Y'
                         FROM xdp_fulfill_worklist fw
                        WHERE fw.line_item_id  = lr.line_item_id
                          AND fw.status_code   = 'ERROR') OR
               EXISTS (SELECT 'Y'
                         FROM xdp_fulfill_worklist fw,
                              xdp_fa_runtime_list fr
                        WHERE fw.workitem_instance_id = fr.workitem_instance_id
                          AND fw.line_item_id         = lr.line_item_id
                          AND fr.status_code          = 'ERROR')) ;
BEGIN
     FOR c_lines_rec IN c_lines
         LOOP
             IF ((c_lines_rec.IS_PACKAGE_FLAG = 'Y') OR
                 (c_lines_rec.ib_source IN('CSI','TXN') AND c_lines_rec.ib_source_id IS NULL )
                ) THEN

                FOR c_order_pkg_line_rec IN c_order_pkg_line(c_lines_rec.line_item_id)
                    LOOP
                       l_status := TRUE ;
                    END LOOP ;

             ELSE
                FOR c_order_line_rec IN c_order_line
                    LOOP
                       l_status := TRUE ;
                    END LOOP ;

             END IF ;

         END LOOP ;

RETURN l_status ;

END IS_LINE_IN_ERROR ;

FUNCTION IS_WI_IN_ERROR(p_WIInstance_id IN NUMBER)
         RETURN BOOLEAN IS

l_status   BOOLEAN := FALSE ;

CURSOR c_order_line IS
     SELECT 'Y'
       FROM xdp_fulfill_worklist fw
      WHERE workitem_instance_id  = p_WIInstance_id
        AND EXISTS (SELECT 'Y'
                      FROM xdp_fa_runtime_list fr
                     WHERE fr.workitem_instance_id = fw.workitem_instance_id
                       AND fr.status_code          = 'ERROR') ;

BEGIN
     FOR c_order_line_rec IN c_order_line
         LOOP
            l_status := TRUE ;
         END LOOP ;

RETURN l_status ;

END IS_WI_IN_ERROR ;


FUNCTION IS_FA_IN_ERROR(p_FAInstance_id IN NUMBER)
         RETURN BOOLEAN IS

l_status   BOOLEAN := FALSE ;

CURSOR c_fa IS
     SELECT 'Y'
       FROM xdp_fa_runtime_list fr
      WHERE fr.fa_instance_id = p_FAInstance_id
        AND fr.status_code     = 'ERROR' ;

BEGIN
     FOR c_fa_rec IN c_fa
         LOOP
            l_status := TRUE ;
         END LOOP ;

RETURN l_status ;

END IS_FA_IN_ERROR ;

PROCEDURE SetNodeWIStatus(itemtype IN VARCHAR2,
                         itemkey  IN VARCHAR2,
                         actid    IN NUMBER)
IS

 l_WIInstanceID      NUMBER ;
 l_status          VARCHAR2(40);

BEGIN
           l_status := WF_ENGINE.GetActivityattrtext(itemtype =>SetNodeWIStatus.itemtype,
                                                     itemkey  =>SetNodeWIStatus.itemkey,
                                                     actid    =>SetNodeWIStatus.actid,
                                                     aname    =>'STATUS');

           l_WIInstanceID := wf_engine.GetItemAttrNumber(itemtype => SetNodeWIStatus.itemtype,
                                                         itemkey  => SetNodeWIStatus.itemkey,
                                                         aname    => 'WORKITEM_INSTANCE_ID');
           UPDATE_XDP_WORKITEM_STATUS(l_status,l_WIInstanceID);


EXCEPTION
     WHEN others THEN
          wf_core.context('XDPSTATUS', 'SetNodeWIStatus', itemtype, itemkey, null,null);
          RAISE;
END SetNodeWIStatus;

PROCEDURE SetNodeLineStatus(itemtype IN VARCHAR2,
                         itemkey  IN VARCHAR2,
                         actid    IN NUMBER)
IS

 l_LineItemID       NUMBER;
 l_status          VARCHAR2(40);

BEGIN

 l_LineItemID := wf_engine.GetItemAttrNumber(itemtype => SetNodeLineStatus.itemtype,
                                             itemkey => SetNodeLineStatus.itemkey,
                                             aname => 'LINE_ITEM_ID');
 l_status := WF_ENGINE.GetActivityattrtext(itemtype =>SetNodeLineStatus.itemtype,
                                           itemkey  =>SetNodeLineStatus.itemkey,
                                           actid    =>SetNodeLineStatus.actid,
                                           aname    =>'STATUS');


 UPDATE_XDP_ORDER_LINE_STATUS(l_status ,  l_LineItemID );


EXCEPTION
     WHEN others THEN
          wf_core.context('XDPSTATUS', 'SetNodeLineStatus', itemtype, itemkey, null,null);
          RAISE;


END SetNodeLineStatus;

FUNCTION GET_WI_STATUS(p_WIInstance_id IN NUMBER)
         RETURN VARCHAR2 IS
 cursor cur_wi_status is
 SELECT status_code
   FROM xdp_fulfill_worklist
  WHERE workitem_instance_id  = p_WIInstance_id;

 cursor cur_fa_status is
 SELECT status_code
   FROM xdp_fa_runtime_list
  WHERE workitem_instance_id  = p_WIInstance_id;

 l_status        VARCHAR2(200);
 l_system_hold   BOOLEAN := FALSE;
 l_error         BOOLEAN := FALSE;

BEGIN
     FOR lv_rec IN cur_wi_status LOOP
         l_status := lv_rec.STATUS_CODE;

         --Check whether the WI itself is in error..
         IF l_status = 'ERROR' THEN
           l_error := TRUE;
           EXIT;
         ELSE
           --Check whether any FAs are in error..
           FOR lv_fa_rec IN cur_fa_status LOOP
             l_status := lv_fa_rec.status_code;
             IF l_status = 'ERROR' THEN
               l_error := TRUE;
               EXIT;
             ELSIF l_status =  'SYSTEM_HOLD' THEN
               l_system_hold := TRUE;
               EXIT;
             END IF;
           END LOOP;
         END IF;
     END LOOP ;

     IF l_error THEN
       RETURN 'ERROR';
     ELSIF l_system_hold THEN
       RETURN 'SYSTEM_HOLD';
     ELSE
       RETURN l_status;
     END IF;
END GET_WI_STATUS;

FUNCTION GET_LINE_STATUS(p_line_item_id IN NUMBER)
         RETURN VARCHAR2 IS
 --cursor to figure out whether a line is package or not..
 CURSOR c_lines IS
 SELECT is_package_flag , is_virtual_line_flag,
        line_item_id, status_code,
        ib_source, ib_source_id
   FROM xdp_order_line_items
  WHERE line_item_id = p_line_item_id;

 CURSOR c_pkg_child_lines( cv_line_item_id IN NUMBER) IS
 SELECT xoli.line_item_id, xoli.status_code
   FROM xdp_line_relationships lr, xdp_order_line_items xoli
  WHERE lr.related_line_item_id = cv_line_item_id
    AND lr.line_item_id  = xoli.line_item_id;

 CURSOR c_line_status (cv_line_item_id IN NUMBER) IS
 SELECT workitem_instance_id
   FROM xdp_fulfill_worklist
  WHERE line_item_id  = cv_line_item_id;

 l_line_status        VARCHAR2(200);
 l_status        VARCHAR2(200);
 l_system_hold   BOOLEAN := FALSE;
 l_error         BOOLEAN := FALSE;

BEGIN
  FOR lv_rec_is_pkg IN c_lines LOOP
     IF ((lv_rec_is_pkg.IS_PACKAGE_FLAG = 'Y') OR
         (lv_rec_is_pkg.ib_source IN('CSI','TXN') AND
          lv_rec_is_pkg.ib_source_id IS NULL )) THEN

       --Check whether the package itself is in error...
       l_line_status := lv_rec_is_pkg.status_code;

       IF l_line_status = 'ERROR' THEN
         l_error := TRUE;
         EXIT;
       END IF;

       FOR lv_rec IN c_pkg_child_lines(  lv_rec_is_pkg.line_item_id ) LOOP
         -- check whether the child line itself is in error..
         IF lv_rec.status_code = 'ERROR' THEN
           l_error := TRUE;
           EXIT;
         END IF;

         -- check all the child lines
         FOR lv_child_line_rec IN c_line_status( lv_rec.line_item_id ) LOOP
           l_status := get_wi_status( lv_child_line_rec.workitem_instance_id );
           --IF any WI is in error exit..
           IF l_status = 'ERROR' THEN
             l_error := TRUE;
             EXIT;
           ELSIF l_status = 'SYSTEM_HOLD' THEN
             l_system_hold := TRUE;
           END IF;
         END LOOP;
       END LOOP;
     ELSE
       --Check whether the line itself is in error...
       l_line_status := lv_rec_is_pkg.status_code;

       IF l_line_status = 'ERROR' THEN
         l_error := TRUE;
         EXIT;
       END IF;

       -- Browse thru all WIs
       FOR lv_rec IN c_line_status( p_line_item_id ) LOOP
           l_status := get_wi_status( lv_rec.workitem_instance_id );
           IF l_status = 'ERROR' THEN
             l_error := TRUE;
             EXIT;
           ELSIF l_status = 'SYSTEM_HOLD' THEN
             l_system_hold := TRUE;
           END IF;
       END LOOP;
     END IF;
  END LOOP;

  IF l_error THEN
    RETURN 'ERROR';
  ELSIF l_system_hold THEN
    RETURN 'SYSTEM_HOLD';
  ELSE
    RETURN l_line_status;
  END IF;

END GET_LINE_STATUS;

FUNCTION GET_ORDER_STATUS(p_order_id IN NUMBER)
         RETURN VARCHAR2 IS

 CURSOR cur_order IS
 SELECT status_code
   FROM xdp_order_headers
  WHERE order_id =  p_order_id;

 CURSOR cur_lines IS
 SELECT status_code, line_item_id
   FROM xdp_order_line_items
  WHERE order_id =  p_order_id;

 lv_status        VARCHAR2(200);
 l_system_hold   BOOLEAN := FALSE;
 l_error         BOOLEAN := FALSE;

BEGIN
  FOR lv_rec IN cur_order LOOP
    lv_status := lv_rec.status_code;
    IF( lv_status = 'ERROR' ) THEN
      l_error := TRUE;
      EXIT;
    ELSE
      FOR lv_line_rec IN cur_lines LOOP
        lv_status := get_line_status(lv_line_rec.line_item_id);
        IF( lv_status = 'ERROR' ) THEN
          l_error := TRUE;
          EXIT;
        ELSIF lv_status = 'SYSTEM_HOLD' THEN
          l_system_hold := TRUE;
        END IF;
      END LOOP;
    END IF;
  END LOOP;

  IF l_error THEN
    RETURN 'ERROR';
  ELSIF l_system_hold THEN
    RETURN 'SYSTEM_HOLD';
  ELSE
    RETURN lv_status;
  END IF;


END GET_ORDER_STATUS;


End XDPSTATUS;

/
