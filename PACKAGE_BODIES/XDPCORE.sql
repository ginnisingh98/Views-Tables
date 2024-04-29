--------------------------------------------------------
--  DDL for Package Body XDPCORE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDPCORE" AS
/* $Header: XDPCOREB.pls 120.1 2005/06/15 22:36:52 appldev  $ */


/****
 All Private Procedures for the Package
****/
/***
Procedure EnqueuePendingQueue(itemtype in varchar2,
                              itemkey  in varchar2);
***/
Function GetOrderType(itemtype in varchar2,
                      itemkey  in varchar2,
                      actid    in number) return varchar2;

Function GetOrderSource(itemtype in varchar2,
                        itemkey  in varchar2,
                        actid    in number) return varchar2;

Function IsOANeeded(itemtype in varchar2,
                    itemkey  in varchar2,
                    actid    in number) return varchar2;

Procedure LaunchOrderAnalyzer(itemtype in varchar2,
                              itemkey  in varchar2,
                              actid    in number);

Procedure ResumeSDP(itemtype  in varchar2,
                    itemkey   in varchar2,
                    actid     in number,
                    funcmode  in varchar2,
                    resultout OUT NOCOPY varchar2);

Function HandleOtherWFFuncmode (funcmode in varchar2) return varchar2;

type RowidArrayType is table of rowid index by binary_integer;



/***********************************************
* END of Private Procedures/Function Definitions
************************************************/


-- StartWfProcess
-- Generic Procedure which starts up a  workflow process.
-- Used to Start Main Order Provisioning Process

Procedure StartWfProcess ( ItemType     in VARCHAR2,
                           ItemKey      in VARCHAR2,
                           OrderID      in number,
                           WorkflowProcess VARCHAR2,
                           Caller       in VARCHAR2) is

 x_Progress                     VARCHAR2(2000);

begin

  IF  ( ItemType is NOT NULL ) AND
      ( ItemKey is NOT NULL )  AND
      (OrderID is NOT NULL) then

	wf_engine.CreateProcess( ItemType => ItemType,
 				 ItemKey  => ItemKey,
				 process  => WorkflowProcess);
	--   *****
	-- Initialize workflow item attributes below
	--   *****

        wf_engine.SetItemAttrNumber(ItemType => ItemType,
                                    ItemKey  => ItemKey,
                                    aname    => 'ORDER_ID',
                                    avalue   => OrderID);

	wf_engine.StartProcess(itemtype => ItemType,
			       itemkey  => ItemKey);
  ELSE
     /* Set the Error Message */
     x_ErrMsg := 'Got Null value';
     RAISE e_NullValueException;
  END IF;

EXCEPTION
     WHEN e_NullValueException then

          x_Progress := 'XDPCORE.StartWfProcess: Cannot Start Workflow process with null values for Itemtype: '
                 || NVL(itemtype, 'NULL') || ' Itemkey: ' || NVL(itemkey, 'NULL') || ' OrderID ' || NVL(OrderID,  'NULL')
                 || ' Process: ' || NVL(WorkflowProcess, 'NULL');

          wf_core.context('XDPCORE', 'StartWfProcess', itemtype, itemkey, x_Progress);
          raise;
     WHEN OTHERS THEN
          wf_core.context('XDPCORE', 'StartWfProcess', itemtype, itemkey, null, null);
          raise;
END StartWfProcess;




-- StartInitOrderProcess Process
-- Creates and Starts the OA process

Procedure StartInitOrderProcess ( OrderID in number)

IS

 x_Progress   VARCHAR2(2000);
 Itemtype     VARCHAR2(8);
 itemkey      VARCHAR2(240);
 process      VARCHAR2(80);

BEGIN

  if OrderID is NOT NULL then

    SELECT to_char(XDP_WF_ITEMKEY_S.NEXTVAL)
      INTO itemkey
      FROM dual;

    ItemType := 'XDPPROV';
    itemkey  := to_char(OrderID) || '-INIT-' || itemkey;

     process := 'INIT_PROCESS_ORDER';

	wf_engine.CreateProcess( ItemType => ItemType,
			 	 ItemKey  => ItemKey,
				 process  => process);
	--   *****
	-- Initialize workflow item attributes below
	--   *****

        wf_engine.SetItemAttrNumber(ItemType => ItemType,
                                    ItemKey  => ItemKey,
                                    aname    => 'ORDER_ID',
                                    avalue   => OrderID);

	wf_engine.StartProcess(itemtype        => ItemType,
				itemkey        => ItemKey);
  else
      /* Set the Error Message */
      x_Progress := 'Got Null value';
      RAISE e_NullValueException;
   end if;

exception
when others then
   wf_core.context('XDPCORE', 'StartInitOrderProcess', itemtype, itemkey, null, x_progress);
   raise;
end StartInitOrderProcess;





-- StartORUProcess Process
-- Creates and Starts the Order Resubmission process

Procedure StartORUProcess ( ResubmissionJobID in number,
                            Itemtype         OUT NOCOPY varchar2,
                            itemkey          OUT NOCOPY varchar2)

IS

 x_Progress   VARCHAR2(2000);
 l_ErrCode    NUMBER;
 l_ErrStr     VARCHAR2(4000);
 process      VARCHAR2(80);

 e_AddAttributeException exception;

BEGIN

  IF ResubmissionJobID is NOT NULL then

    SELECT to_char(XDP_WF_ITEMKEY_S.NEXTVAL)
      INTO itemkey
      FROM dual;

    ItemType := 'XDPPROV';
    itemkey  := to_char(ResubmissionJobID) || '-ORU-' || itemkey;

     process := 'ORDER_RESUBMISSION_PROCESS';


	wf_engine.CreateProcess( ItemType => ItemType,
				 ItemKey  => ItemKey,
				 process  => process);
	--   *****
	-- Initialize workflow item attributes below
	--   *****

        CheckNAddItemAttrNumber (itemtype  => itemtype,
                                 itemkey   => itemkey,
                                 AttrName  => 'RESUBMISSION_JOB_ID',
                                 AttrValue => ResubmissionJobID,
                                 ErrCode   => l_ErrCode,
                                 ErrStr    => l_ErrStr);

    if l_ErrCode <> 0 then
       x_progress := 'In XDPCORE.StartORUProcess. Error when adding RESUBMISSION_JOB_ID attribute. ';
       raise e_AddAttributeException;
    end if;

	wf_engine.StartProcess(itemtype => ItemType,
				itemkey => ItemKey);
  else
      /* Set the Error Message */
      x_Progress := 'Got Null value';
      RAISE e_NullValueException;
   end if;

exception
when others then
   wf_core.context('XDPCORE', 'StartORUProcess', itemtype, itemkey, null, x_progress);
   raise;
end StartORUProcess;


-- StartOA Process
-- Creates and Starts the OA process

Procedure StartOAProcess ( OrderID in number)

is

 x_Progress VARCHAR2(2000);
 Itemtype   VARCHAR2(8);
 itemkey    VARCHAR2(240);
 process    VARCHAR2(80);

BEGIN

  if OrderID is NOT NULL then

    SELECT to_char(XDP_WF_ITEMKEY_S.NEXTVAL)
      INTO itemkey
      FROM dual;

    ItemType := 'XDPPROV';
    itemkey  := to_char(OrderID) || '-OA-' || itemkey;

     process := 'PROV_PROCESS';

	wf_engine.CreateProcess( ItemType => ItemType,
				 ItemKey  => ItemKey,
				 process  => process);
	--   *****
	-- Initialize workflow item attributes below
	--   *****

        wf_engine.SetItemAttrNumber(ItemType => ItemType,
                                    ItemKey  => ItemKey,
                                    aname    => 'ORDER_ID',
                                    avalue   => OrderID);

	wf_engine.StartProcess(itemtype        => ItemType,
				itemkey        => ItemKey);
  else
      /* Set the Error Message */
      x_Progress := 'Got Null value';
      RAISE e_NullValueException;
   end if;

exception
when others then
   wf_core.context('XDPCORE', 'StartOAProcess', itemtype, itemkey, null, x_progress);
   raise;
end StartOAProcess;






-- CreateOrderProcess
-- then creates the Main Order Process which the Order processor Dequer starts off
--
Procedure CreateOrderProcess (OrderID   in number,
                              ItemType OUT NOCOPY VARCHAR2,
                              ItemKey  OUT NOCOPY VARCHAR2 )

is

 x_Progress  VARCHAR2(2000);

begin

    SELECT to_char(XDP_WF_ITEMKEY_S.NEXTVAL)
      INTO itemkey
      FROM dual;

    ItemType := 'XDPPROV';
    itemkey  := to_char(OrderID) || '-MAIN-' || itemkey;

    wf_engine.CreateProcess( ItemType => ItemType,
                             ItemKey  => ItemKey,
                             process  => 'MAIN_ORDER_PROCESS');

	--   *****
	-- Initialize workflow item attributes below
	--   *****

     wf_engine.SetItemAttrNumber(ItemType => ItemType,
                                 ItemKey  => ItemKey,
                                 aname    => 'ORDER_ID',
                                 avalue   => OrderID);


exception
when others then
   x_progress := 'XDPCORE.CreateOrderProcess. Unhandled Excepton: ' || SUBSTR(SQLERRM, 1, 1500);
   wf_core.context('XDPCORE', 'CreateOrderProcess', itemtype, itemkey, null, x_progress);
   raise;
end CreateOrderProcess;




--  IS_OA_NEEDED
--   Resultout
--     yes/no
--
-- Your Description here: This procedure determines if the Order Analyzer is
--			  to Process the current Order


Procedure IS_OA_NEEDED (itemtype        in varchar2,
                        itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2 ) IS


 x_Progress                     VARCHAR2(2000);
 l_Result varchar2(1);

BEGIN

-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN

                l_Result  := IsOANeeded(itemtype, itemkey ,actid);
		resultout := 'COMPLETE:' || l_Result;
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;


EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE', 'IS_OA_NEEDED', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END IS_OA_NEEDED;






--  LAUNCH_ORDER_ANALYZER
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:

Procedure LAUNCH_ORDER_ANALYZER (itemtype  in varchar2,
			         itemkey   in varchar2,
			         actid     in number,
			         funcmode  in varchar2,
			         resultout OUT NOCOPY varchar2 ) IS

 x_Progress   VARCHAR2(2000);

BEGIN
-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN
                LaunchOrderAnalyzer(itemtype, itemkey, actid);
		resultout := 'COMPLETE:ACTIVITY_PERFORMED';
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;

EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE', 'LAUNCH_ORDER_ANALYZER', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END LAUNCH_ORDER_ANALYZER;


--  SET_ORDER_STATUS_TO_HOLD
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:

Procedure SET_ORDER_STATUS_TO_HOLD (itemtype  in varchar2,
			            itemkey   in varchar2,
			            actid     in number,
			            funcmode  in varchar2,
			            resultout OUT NOCOPY varchar2 ) IS

 x_Progress  VARCHAR2(2000);

BEGIN
-- RUN mode - normal process execution
--
        IF (funcmode = 'RUN') THEN
--      <your procedure here>
                resultout := 'COMPLETE:<result>';
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;

EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE', 'SET_ORDER_STATUS_TO_HOLD', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END SET_ORDER_STATUS_TO_HOLD;


--  ENQUEUE_PENDING_QUEUE
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:
/*****

Procedure ENQUEUE_PENDING_QUEUE (itemtype  in varchar2,
		 	         itemkey   in varchar2,
			         actid     in number,
			         funcmode  in varchar2,
			         resultout OUT NOCOPY varchar2 ) IS

 x_Progress   VARCHAR2(2000);

BEGIN
-- RUN mode - normal process execution
--
        IF (funcmode = 'RUN') THEN
                EnqueuePendingQueue(itemtype, itemkey);
                resultout := 'COMPLETE:ACTIVITY_PERFORMED';
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;

EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE', 'ENQUEUE_PENDING_QUEUE', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END ENQUEUE_PENDING_QUEUE;

****/



--  WHAT_SOURCE
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:

Procedure WHAT_SOURCE (itemtype  in varchar2,
		       itemkey   in varchar2,
		       actid     in number,
		       funcmode  in varchar2,
		       resultout OUT NOCOPY varchar2 ) IS

 x_Progress  VARCHAR2(2000);
 l_Result    VARCHAR2(40);

BEGIN

-- RUN mode - normal process execution
--
        IF (funcmode = 'RUN') THEN
                l_Result := GetOrderSource(itemtype, itemkey , actid);
                resultout := 'COMPLETE:' || l_Result;
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;

EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE', 'WHAT_SOURCE', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END WHAT_SOURCE;



--  ORDER_TYPE
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:

Procedure ORDER_TYPE (itemtype  in varchar2,
		      itemkey   in varchar2,
		      actid     in number,
		      funcmode  in varchar2,
		      resultout OUT NOCOPY varchar2 ) IS

 x_Progress   VARCHAR2(2000);
 l_Result     VARCHAR2(40);

BEGIN

-- RUN mode - normal process execution
--
        IF (funcmode = 'RUN') THEN
                l_Result := GetOrderType(itemtype, itemkey, actid);
                resultout := 'COMPLETE:' || l_Result;
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;

EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE', 'ORDER_TYPE', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END ORDER_TYPE;



--  RESUME_SDP
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here: Put the Order requiring Order Analyzer into the
--			  Order Analyzer Queue for processing.

Procedure RESUME_SDP (itemtype   in varchar2,
                      itemkey    in varchar2,
                      actid      in number,
                      funcmode   in varchar2,
                      resultout  OUT NOCOPY varchar2 ) IS

 x_Progress VARCHAR2(2000);

BEGIN
-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN
                ResumeSDP(itemtype, itemkey, actid, funcmode,resultout);
		resultout := 'COMPLETE';
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;

EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE', 'RESUME_SDP', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END RESUME_SDP;


Procedure OP_START (itemtype  in varchar2,
                    itemkey   in varchar2,
                    actid     in number,
                    funcmode  in varchar2,
                    resultout OUT NOCOPY varchar2 ) IS

BEGIN

  null;

EXCEPTION

     WHEN OTHERS THEN
          wf_core.context('XDPCORE', 'OP_START', itemtype, itemkey, to_char(actid), funcmode);
          raise;
END OP_START;

Procedure OP_END (itemtype  in varchar2,
                  itemkey   in varchar2,
                  actid     in number,
                  funcmode  in varchar2,
                  resultout OUT NOCOPY varchar2 ) IS

BEGIN
  null;
EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE', 'OP_END', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END OP_END;


/****
 All the Private Functions
****/

Function HandleOtherWFFuncmode( funcmode in varchar2) return varchar2
is
resultout    VARCHAR2(30);
x_Progress   VARCHAR2(2000);

begin

        IF (funcmode = 'CANCEL') THEN
                resultout := 'COMPLETE';
        END IF;

        IF (funcmode = 'RESPOND') THEN
                resultout := 'COMPLETE';
        END IF;

        IF (funcmode = 'FORWARD') THEN
                resultout := 'COMPLETE';
        END IF;

        IF (funcmode = 'TRANSFER') THEN
                resultout := 'COMPLETE';
        END IF;

        IF (funcmode = 'TIMEOUT') THEN
                resultout := 'COMPLETE';
        END IF;

        IF (funcmode = 'others') THEN
                resultout := 'COMPLETE';
        END IF;


        return resultout;

end;



/******

PROCEDURE EnqueuePendingQueue (itemtype IN VARCHAR2,
                               itemkey  IN VARCHAR2)
IS

 l_OrderID          NUMBER;
 l_ErrCode          NUMBER;
 l_ErrStr           VARCHAR2(2000);
 x_progress         VARCHAR2(2000);
 e_EnqueueException EXCEPTION;

BEGIN

 l_OrderID := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                          itemkey  => itemkey,
                                          aname    => 'ORDER_ID');

 UPDATE xdp_order_headers
  SET state             = 'WAIT',
      last_update_date  = sysdate,
      last_updated_by   = fnd_global.user_id,
      last_update_login = fnd_global.login_id
 WHERE order_id = l_orderid
   AND state    = 'PREPROCESS';

 UPDATE xdp_order_line_items
  SET state = 'WAIT',
      last_update_date  = sysdate,
      last_updated_by   = fnd_global.user_id,
      last_update_login = fnd_global.login_id
 WHERE order_id = l_orderid
   AND state    = 'PREPROCESS';

 XDP_AQ_UTILITIES.Pending_Order_EQ( p_order_id          => l_OrderID,
                                    p_prov_date         => sysdate,
                                    p_priority          => 100,
                                    p_return_code       => l_ErrCode,
                                    p_error_description => l_ErrStr);

 IF l_ErrCode <> 0 then
    x_Progress := 'XDPCORE.EnqueuePendingQueue. Error when enqueuing into the Pending Order Queue. Error: ' || SUBSTR(l_ErrStr, 1, 1500);
    raise e_EnqueueException;
 END IF;

EXCEPTION
    WHEN e_EnqueueException THEN
         wf_core.context('XDPCORE', 'EnqueuePendingQueue',itemtype,itemkey, null,x_progress);
         raise;
    WHEN others THEN
         x_progress := 'XDPCORE.EnqueuePendingQueue. Unhandled Exception: ' || SUBSTR(SQLERRM, 1, 1500);
         wf_core.context('XDPCORE', 'EnqueuePendingQueue',itemtype,itemkey, null,x_progress);
         raise;
END EnqueuePendingQueue;
*******/

PROCEDURE ResumeSDP (itemtype   IN VARCHAR2,
                     itemkey    IN VARCHAR2,
                     actid      IN NUMBER,
                     funcmode   IN VARCHAR2,
                     resultout OUT NOCOPY VARCHAR2)
IS
 x_progress VARCHAR2(2000);
 l_Status   VARCHAR2(40);


 l_wi_instance_id number;
 l_error_code number;

 e_deregister_exception exception;
BEGIN
 --
 -- The next line is commented out as l_Status is not used in this context.
 -- Commenting out this line allows us to remove attribue WORKITEM_STATUS in
 -- the workflow activity 'complete workitem and update status'
 -- Bug 1224293
 -- Anping Wang
 -- 12/21/2000

 -- Bug 1790288
 -- Once the Work Item completes all the waiting Events and Timers must be
 -- Expired
 -- Raja 5/30/2001

 l_wi_instance_id := wf_engine.GetItemAttrNumber(itemtype => ResumeSDP.itemtype,
					         itemkey => ResumeSDP.itemkey,
					         aname => 'WORKITEM_INSTANCE_ID');

 xnp_timer_standard.deregister_for_workitem(p_workitem_instance_id => l_wi_instance_id,
					    x_error_code => l_error_code,
					    x_error_message => x_progress);

 if (l_error_code <> 0 ) then
	raise e_deregister_exception;
 end if;

 xnp_event.deregister_for_workitem(p_workitem_instance_id => l_wi_instance_id,
				   x_error_code => l_error_code,
				   x_error_message => x_progress);

 if (l_error_code <> 0 ) then
	raise e_deregister_exception;
 end if;

 /* Call API to Set Workitem Status */

 XDPSTATUS.SetWorkitemStatus(ResumeSDP.itemtype, ResumeSDP.itemkey);


-- WF_STANDARD.CONTINUEFLOW(itemtype, itemkey, actid, funcmode,resultout);
 XDP_UTILITIES.CONTINUEFLOW(itemtype, itemkey);



EXCEPTION
     WHEN e_deregister_exception then
          x_progress := 'XDPCORE.ResumeSDP. Error when Deregistering Timers and Callback Events' || SUBSTR(x_progress, 1, 1800);
          wf_core.context('XDPCORE', 'ResumeSDP', itemtype, itemkey, to_char(actid), x_progress);
	  raise;
     WHEN others THEN
          x_progress := 'XDPCORE.ResumeSDP. Unhandled Exception: ' || SUBSTR(SQLERRM, 1, 1500);
          wf_core.context('XDPCORE', 'ResumeSDP', itemtype, itemkey, to_char(actid), x_progress);
	  raise;
END ResumeSDP;



FUNCTION GetOrderType (itemtype IN VARCHAR2,
                       itemkey  IN VARCHAR2,
                       actid    IN NUMBER) RETURN VARCHAR2

IS

 x_progress  VARCHAR2(2000);
 l_OrderType VARCHAR2(40);

BEGIN

 l_OrderType := 'NORMAL';

 return l_OrderType;


EXCEPTION
     WHEN others THEN
          x_progress := 'XDPCORE.GetOrderType. Unhandled Exception: ' || SUBSTR(SQLERRM, 1, 1500);
          wf_core.context('XDPCORE', 'GetOrderType', itemtype, itemkey, to_char(actid), x_progress);
END GetOrderType;




FUNCTION GetOrderSource (itemtype IN VARCHAR2,
                         itemkey  IN VARCHAR2,
                         actid    IN NUMBER) RETURN VARCHAR2

IS

 x_progress    VARCHAR2(2000);
 l_OrderSource VARCHAR2(40);

BEGIN

 l_OrderSource := 'PROV';

 return l_OrderSource;


EXCEPTION
     WHEN others THEN
          x_progress := 'XDPCORE.GetOrderSource. Unhandled Exception: ' || SUBSTR(SQLERRM, 1, 1500);
          wf_core.context('XDPCORE', 'GetOrderSource', itemtype, itemkey, to_char(actid), x_progress);
END GetOrderSource;


FUNCTION IsOANeeded (itemtype IN VARCHAR2,
                     itemkey  IN VARCHAR2,
                     actid    IN NUMBER) RETURN VARCHAR2

IS

 x_progress VARCHAR2(2000);
 l_OAFlag   VARCHAR2(40);

BEGIN

 l_OAFlag := wf_engine.GetActivityAttrText(itemtype => IsOANeeded.itemtype,
                                           itemkey  => IsOANeeded.itemkey,
                                           actid    => actid,
                                           aname    => 'IS_OA_REQUIRED');

 return l_OAFlag;


EXCEPTION
     WHEN others THEN
          x_progress := 'XDPCORE.IsOANeeded. Unhandled Exception: ' || SUBSTR(SQLERRM, 1, 1500);
          wf_core.context('XDPCORE', 'IsOANeeded', itemtype, itemkey, to_char(actid), x_progress);
END IsOANeeded;


PROCEDURE LaunchOrderAnalyzer (itemtype IN VARCHAR2,
                               itemkey  IN VARCHAR2,
                               actid    IN NUMBER)

IS

 x_progress VARCHAR2(2000);

BEGIN

/*
   XDP_ANALYZER.AnalyzeOrder;
*/
   null;

EXCEPTION
     WHEN others THEN
          x_progress := 'XDPCORE.LaunchOrderAnalyzer. Unhandled Exception: ' || SUBSTR(SQLERRM, 1, 1500);
          wf_core.context('XDPCORE', 'LaunchOrderAnalyzer', itemtype, itemkey, to_char(actid), x_progress);
END LaunchOrderAnalyzer;




PROCEDURE SEND_NOTIFICATION (role         IN VARCHAR2,
                             msg_type     IN VARCHAR2,
                             msg_name     IN VARCHAR2,
                             due_date     IN VARCHAR2,
                             itemtype     IN VARCHAR2,
                             itemkey      IN VARCHAR2,
                             actid        IN NUMBER,
                             priority in number default 100,
                             OrderID in number default null,
                             WIInstanceID IN NUMBER DEFAULT NULL,
                             FAInstanceID IN NUMBER DEFAULT NULL,
                             notifID     OUT NOCOPY NUMBER)
IS

 l_context   VARCHAR2(2000);
 x_Progress  VARCHAR2(2000);

BEGIN

 l_context := SEND_NOTIFICATION.itemtype || ':' || SEND_NOTIFICATION.itemkey || ':' || to_char(SEND_NOTIFICATION.actid);


 notifID := wf_notification.SEND(role,
                                 msg_type,
                                 msg_name,
                                 due_date,
                                 'wf_engine.cb',
                                 l_context,
                                 null,
                                 priority);

EXCEPTION
     WHEN others THEN
          wf_core.context('XDPCORE', 'SEND_NOTIFICATION',null,null, null,null);
          raise;
END SEND_NOTIFICATION;



PROCEDURE CheckNAddItemAttrText(itemtype  IN VARCHAR2,
                                itemkey   IN VARCHAR2,
                                AttrName  IN VARCHAR2,
                                AttrValue IN VARCHAR2,
                                ErrCode  OUT NOCOPY NUMBER,
                                ErrStr   OUT NOCOPY VARCHAR2)
IS
 l_AttrFound NUMBER := 0;
 l_Dummy     VARCHAR2(4000);
 x_Progress  VARCHAR2(2000);

BEGIn

  ErrCode := 0;
  ErrStr := null;

  BEGIN

       l_Dummy := wf_engine.GetItemAttrText (itemtype => CheckNAddItemAttrText.itemtype,
                                             itemkey  => CheckNAddItemAttrText.itemkey,
                                             aname    => AttrName);

          l_AttrFound := 1;

          wf_engine.SetItemAttrText(itemtype => CheckNAddItemAttrText.itemtype,
                                    itemkey  => CheckNAddItemAttrText.itemkey,
                                    aname    => AttrName,
                                    avalue   => AttrValue);

          return;

  EXCEPTION
       WHEN others THEN
        -- dbms_output.put_line(SQLCODE);
        IF SQLCODE = -20002 THEN
           l_AttrFound := 0;
           wf_core.clear;
        ELSE
           RAISE;
        END IF;
  END;


      IF l_AttrFound = 0 THEN

         wf_engine.AddItemAttr(itemtype => CheckNAddItemAttrText.itemtype,
                               itemkey  => CheckNAddItemAttrText.itemkey,
                               aname    => AttrName);

          wf_engine.SetItemAttrText(itemtype => CheckNAddItemAttrText.itemtype,
                                    itemkey  => CheckNAddItemAttrText.itemkey,
                                    aname    => AttrName,
                                    avalue   => AttrValue);
          return;
      END IF;

EXCEPTION
     WHEN others THEN
          ErrCode := SQLCODE;
          ErrStr := SQLERRM;
END CheckNAddItemAttrText;


PROCEDURE CheckNAddItemAttrNumber(itemtype  IN VARCHAR2,
                                  itemkey   IN VARCHAR2,
                                  AttrName  IN VARCHAR2,
                                  AttrValue IN NUMBER,
                                  ErrCode  OUT NOCOPY NUMBER,
                                  ErrStr   OUT NOCOPY VARCHAR2)
IS
 l_AttrFound NUMBER := 0;
 l_Dummy     NUMBER;
 x_Progress  VARCHAR2(2000);

BEGIN

  ErrCode := 0;
  ErrStr := null;

  BEGIN

       l_Dummy := wf_engine.GetItemAttrNumber (itemtype => CheckNAddItemAttrNumber.itemtype,
                                               itemkey  => CheckNAddItemAttrNumber.itemkey,
                                               aname    => AttrName);

          l_AttrFound := 1;

          wf_engine.SetItemAttrNumber(itemtype => CheckNAddItemAttrNumber.itemtype,
                                      itemkey  => CheckNAddItemAttrNumber.itemkey,
                                      aname    => AttrName,
                                      avalue   => AttrValue);

          return;

  EXCEPTION
       WHEN others THEN
        -- dbms_output.put_line(SQLCODE);

        IF SQLCODE = -20002 then
           l_AttrFound := 0;
           wf_core.clear;
        ELSE
           RAISE;
        END IF;
  END;


      If l_AttrFound = 0 then

         wf_engine.AddItemAttr(itemtype => CheckNAddItemAttrNumber.itemtype,
                               itemkey  => CheckNAddItemAttrNumber.itemkey,
                               aname    => AttrName);

          wf_engine.SetItemAttrNumber(itemtype => CheckNAddItemAttrNumber.itemtype,
                                      itemkey => CheckNAddItemAttrNumber.itemkey,
                                      aname => AttrName,
                                      avalue => AttrValue);
          return;
      end if;

EXCEPTION
     WHEN others THEN
          ErrCode := SQLCODE;
          ErrStr := SQLERRM;
END CheckNAddItemAttrNumber;



PROCEDURE CheckNAddItemAttrDate(itemtype  IN VARCHAR2,
                                itemkey   IN VARCHAR2,
                                AttrName  IN VARCHAR2,
                                AttrValue IN dATE,
                                ErrCode  OUT NOCOPY NUMBER,
                                ErrStr   OUT NOCOPY VARCHAR2)
IS
 l_AttrFound NUMBER := 0;
 l_Dummy     DATE;
 x_Progress  VARCHAR2(2000);

BEGIN

  ErrCode := 0;
  ErrStr := null;

  BEGIN

       l_Dummy := wf_engine.GetItemAttrDate (itemtype => CheckNAddItemAttrDate.itemtype,
                                             itemkey  => CheckNAddItemAttrDate.itemkey,
                                             aname    => AttrName);

          l_AttrFound := 1;

          wf_engine.SetItemAttrDate(itemtype => CheckNAddItemAttrDate.itemtype,
                                    itemkey  => CheckNAddItemAttrDate.itemkey,
                                    aname    => AttrName,
                                    avalue   => AttrValue);

          return;

  EXCEPTION
      WHEN others THEN
        -- dbms_output.put_line(SQLCODE);
        IF SQLCODE = -20002 then
           l_AttrFound := 0;
           wf_core.clear;
        ELSE
           RAISE;
        END IF;
  END;


      IF l_AttrFound = 0 THEN

         wf_engine.AddItemAttr(itemtype => CheckNAddItemAttrDate.itemtype,
                               itemkey  => CheckNAddItemAttrDate.itemkey,
                               aname    => AttrName);

          wf_engine.SetItemAttrDate(itemtype => CheckNAddItemAttrDate.itemtype,
                                    itemkey  => CheckNAddItemAttrDate.itemkey,
                                    aname    => AttrName,
                                    avalue   => AttrValue);
          return;
      END IF;

EXCEPTION
     WHEN others THEN
          ErrCode := SQLCODE;
          ErrStr := SQLERRM;
END CheckNAddItemAttrDate;

--This procedure creates the child process and sets the parent child
--relationship along with the label of wait flow activity in parent
-- bug fix for bug #2269403
Procedure CreateNAddAttrNParentLabel(itemtype in varchar2,
                              itemkey in varchar2,
                              processname in varchar2,
                              parentitemtype in varchar2,
                              parentitemkey in varchar2,
                              waitflowLabel in varchar2,
                              OrderID in number,
                              LineitemID in number,
                              WIInstanceID in number,
                              FAInstanceID in number)
IS

l_NameArray Wf_Engine.NameTabTyp;
l_ValueNumArray Wf_Engine.NumTabTyp;
l_ErrCode number;
l_ErrDescription varchar2(800);



l_index number := 1;
begin

        wf_engine.CreateProcess(itemtype => CreateNAddAttrNParentLabel.itemtype,
                                itemkey => CreateNAddAttrNParentLabel.itemkey,
                                process => processname);

-- Only set its parent when it has one
        IF CreateNAddAttrNParentLabel.parentitemkey IS NOT NULL THEN
            wf_engine.SetItemParent(itemtype => CreateNAddAttrNParentLabel.itemtype,
                                itemkey => CreateNAddAttrNParentLabel.itemkey,
                                parent_itemtype => CreateNAddAttrNParentLabel.parentitemtype,
                                parent_itemkey => CreateNAddAttrNParentLabel.parentitemkey,
                                parent_context => CreateNAddAttrNParentLabel.waitflowlabel );
        END IF;

		if OrderID is not null then
			l_NameArray(l_index) := 'ORDER_ID';
			l_ValueNumArray(l_index) := OrderID;

			l_index := l_index + 1;
		end if;

		if LineItemID is not null  then
			l_NameArray(l_index) := 'LINE_ITEM_ID';
			l_ValueNumArray(l_index) := LineItemID;

                        l_index := l_index + 1;
		end if;

		if WIInstanceID is not null  then
			l_NameArray(l_index) := 'WORKITEM_INSTANCE_ID';
			l_ValueNumArray(l_index) := WIInstanceID;

			l_index := l_index + 1;
		end if;

		if FAInstanceID is not null then
			l_NameArray(l_index) := 'FA_INSTANCE_ID';
			l_ValueNumArray(l_index) := FAInstanceID;
		end if;


		if l_index > 1 then
          BEGIN
			wf_engine.SetItemAttrNumberArray
					(itemtype => CreateNAddAttrNParentLabel.itemtype,
					 itemkey  => CreateNAddAttrNParentLabel.itemKey,
					 aname => l_NameArray,
					 avalue => l_ValueNumArray);
                 EXCEPTION

                   WHEN OTHERS THEN
                       -- skilaru 01/10/2002
                       -- We get into this exception block only when the USER DEFINED Item type
                       -- does not contain any of the static Item attributes ORDER_ID, LINE_ITEM_ID,
                       -- WORKITEM_INSTANCE_ID, FA_INSTANCE_ID. We will go ahead and set them (IF THEY
                       -- ARE NOT DEFINED) dynamically for the User Defined Workflows.


		             if OrderID is not null then
                       CheckNAddItemAttrNumber (itemtype => CreateNAddAttrNParentLabel.itemtype,
                                                itemkey => CreateNAddAttrNParentLabel.itemKey,
                                                AttrName => 'ORDER_ID',
                                                AttrValue => OrderID,
                                                ErrCode => l_ErrCode,
                                                ErrStr => l_ErrDescription);


		             end if;
		             if LineItemID is not null  then
                       CheckNAddItemAttrNumber (itemtype => CreateNAddAttrNParentLabel.itemtype,
                                                itemkey => CreateNAddAttrNParentLabel.itemKey,
                                                AttrName => 'LINE_ITEM_ID',
                                                AttrValue => LineItemID,
                                                ErrCode => l_ErrCode,
                                                ErrStr => l_ErrDescription);

		             end if;
		             if WIInstanceID is not null  then
                       CheckNAddItemAttrNumber (itemtype => CreateNAddAttrNParentLabel.itemtype,
                                                itemkey => CreateNAddAttrNParentLabel.itemKey,
                                                AttrName => 'WORKITEM_INSTANCE_ID',
                                                AttrValue => WIInstanceID,
                                                ErrCode => l_ErrCode,
                                                ErrStr => l_ErrDescription);

		             end if;
		             if FAInstanceID is not null then
                       CheckNAddItemAttrNumber (itemtype => CreateNAddAttrNParentLabel.itemtype,
                                                itemkey => CreateNAddAttrNParentLabel.itemKey,
                                                AttrName => 'FA_INSTANCE_ID',
                                                AttrValue => FAInstanceID,
                                                ErrCode => l_ErrCode,
                                                ErrStr => l_ErrDescription);
		             end if;
          END;
		end if;
end CreateNAddAttrNParentLabel;



Procedure CreateAndAddAttrNum(itemtype 		IN VARCHAR2,
			      itemkey 		IN VARCHAR2,
			      processname 	IN VARCHAR2,
			      parentitemtype 	IN VARCHAR2,
			      parentitemkey 	IN VARCHAR2,
			      OrderID 		IN NUMBER,
			      LineitemID 	IN NUMBER,
			      WIInstanceID 	IN NUMBER,
			      FAInstanceID 	IN NUMBER)

IS

l_NameArray Wf_Engine.NameTabTyp;
l_ValueNumArray Wf_Engine.NumTabTyp;
l_ErrCode number;
l_ErrDescription varchar2(800);



l_index number := 1;
begin

        wf_engine.CreateProcess(itemtype => CreateAndAddAttrNum.itemtype,
                                itemkey => CreateAndAddAttrNum.itemkey,
                                process => processname);

-- Only set its parent when it has one
        IF CreateAndAddAttrNum.parentitemkey IS NOT NULL THEN
            wf_engine.SetItemParent(itemtype => CreateAndAddAttrNum.itemtype,
                                itemkey => CreateAndAddAttrNum.itemkey,
                                parent_itemtype => CreateAndAddAttrNum.parentitemtype,
                                parent_itemkey => CreateAndAddAttrNum.parentitemkey,
                                parent_context => null);
        END IF;

		if OrderID is not null then
			l_NameArray(l_index) := 'ORDER_ID';
			l_ValueNumArray(l_index) := OrderID;

			l_index := l_index + 1;
		end if;

		if LineItemID is not null  then
			l_NameArray(l_index) := 'LINE_ITEM_ID';
			l_ValueNumArray(l_index) := LineItemID;

                        l_index := l_index + 1;
		end if;

		if WIInstanceID is not null  then
			l_NameArray(l_index) := 'WORKITEM_INSTANCE_ID';
			l_ValueNumArray(l_index) := WIInstanceID;

			l_index := l_index + 1;
		end if;

		if FAInstanceID is not null then
			l_NameArray(l_index) := 'FA_INSTANCE_ID';
			l_ValueNumArray(l_index) := FAInstanceID;
		end if;


		if l_index > 1 then
          BEGIN
			wf_engine.SetItemAttrNumberArray
					(itemtype => CreateAndAddAttrNum.itemtype,
					 itemkey  => CreateAndAddAttrNum.itemKey,
					 aname => l_NameArray,
					 avalue => l_ValueNumArray);
                 EXCEPTION

                   WHEN OTHERS THEN
                       -- skilaru 01/10/2002
                       -- We get into this exception block only when the USER DEFINED Item type
                       -- does not contain any of the static Item attributes ORDER_ID, LINE_ITEM_ID,
                       -- WORKITEM_INSTANCE_ID, FA_INSTANCE_ID. We will go ahead and set them (IF THEY
                       -- ARE NOT DEFINED) dynamically for the User Defined Workflows.


		             if OrderID is not null then
                       CheckNAddItemAttrNumber (itemtype => CreateAndAddAttrNum.itemtype,
                                                itemkey => CreateAndAddAttrNum.itemKey,
                                                AttrName => 'ORDER_ID',
                                                AttrValue => OrderID,
                                                ErrCode => l_ErrCode,
                                                ErrStr => l_ErrDescription);


		             end if;
		             if LineItemID is not null  then
                       CheckNAddItemAttrNumber (itemtype => CreateAndAddAttrNum.itemtype,
                                                itemkey => CreateAndAddAttrNum.itemKey,
                                                AttrName => 'LINE_ITEM_ID',
                                                AttrValue => LineItemID,
                                                ErrCode => l_ErrCode,
                                                ErrStr => l_ErrDescription);

		             end if;
		             if WIInstanceID is not null  then
                       CheckNAddItemAttrNumber (itemtype => CreateAndAddAttrNum.itemtype,
                                                itemkey => CreateAndAddAttrNum.itemKey,
                                                AttrName => 'WORKITEM_INSTANCE_ID',
                                                AttrValue => WIInstanceID,
                                                ErrCode => l_ErrCode,
                                                ErrStr => l_ErrDescription);

		             end if;
		             if FAInstanceID is not null then
                       CheckNAddItemAttrNumber (itemtype => CreateAndAddAttrNum.itemtype,
                                                itemkey => CreateAndAddAttrNum.itemKey,
                                                AttrName => 'FA_INSTANCE_ID',
                                                AttrValue => FAInstanceID,
                                                ErrCode => l_ErrCode,
                                                ErrStr => l_ErrDescription);
		             end if;
          END;
		end if;

end CreateAndAddAttrNum;


Procedure START_FA_RESUBMIT_PROCESS( p_fe_id                IN NUMBER,
                                    p_start_date           IN DATE ,
                                    p_end_date             IN DATE,
                                    p_resubmission_job_id  IN NUMBER,
                                    x_error_code          OUT NOCOPY NUMBER,
                                    x_error_message       OUT NOCOPY VARCHAR2) IS

l_fa_instance_id NUMBER;
l_item_key       VARCHAR2(240);
l_item_type      VARCHAR2(240);

CURSOR c_fa IS
       SELECT fr.workitem_instance_id ,
              fr.fulfillment_action_id,
              fr.fa_instance_id
         FROM xdp_fa_runtime_list fr
        WHERE fr.fe_id = p_fe_id
          AND fr.status_code IN ('SUCCESS','SUCCESS_WITH_OVERRIDE')
          AND fr.completion_date >= p_start_date
          AND fr.completion_date <= NVL(p_end_date , sysdate)
          AND fr.resubmission_job_id IS NULL ;

BEGIN

     -- Resubmit FA

     FOR c_fa_rec IN c_fa
         LOOP
            l_fa_instance_id := XDP_ENG_UTIL.RESUBMIT_FA
                                     ( p_resubmission_job_id => p_resubmission_job_id,
                                       p_resub_fa_instance_id => c_fa_rec.fa_instance_id );

         END LOOP ;

     -- Start ORU Process

            STARTORUPROCESS
                       (resubmissionjobid => p_resubmission_job_id,
                        itemtype          => l_item_type,
                        itemkey           => l_item_key );

     COMMIT;

EXCEPTION
     WHEN others THEN
          x_error_code := -191266;
          FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
          FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPCORE.START_RESUBMITT_PROCESS');
          FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
          x_error_message := FND_MESSAGE.GET;
          RAISE ;
END START_FA_RESUBMIT_PROCESS;

Procedure START_RESUBMISSION_CHANNELS( p_fe_id              IN NUMBER,
                                       p_channels_reqd      IN NUMBER,
                                       p_usage_code         IN VARCHAR2,
                                       x_channels_started  OUT NOCOPY NUMBER,
                                       x_error_code        OUT NOCOPY NUMBER,
                                       x_error_message     OUT NOCOPY VARCHAR2) IS

l_channels_to_start   NUMBER := 0;
l_current_channels    NUMBER;
l_channel_started     NUMBER;
e_exception           EXCEPTION;
l_error_code          NUMBER;
l_error_message       VARCHAR2(240);

CURSOR c_channel(channel_count IN NUMBER) IS
       SELECT channel_name,
              adapter_status ,
              seq_in_fe
         FROM xdp_adapter_reg
        WHERE fe_id = p_fe_id
          AND usage_code = p_usage_code
          AND rownum = channel_count
        ORDER BY seq_in_fe ;

BEGIN
          if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'XDPCORE.START_RESUBMISSION_CHANNELS',
                                                 'P_FE_ID is '||p_fe_id||
                                                 '   P_CHANNEL_REQD is '||p_channels_reqd||
                                                 '  P_USAGE_CODE is '||p_usage_code);
	  end if;

          SELECT count(*)
            INTO l_current_channels
            FROM xdp_adapter_reg
           WHERE fe_id      = p_fe_id
             AND usage_code = p_usage_code ;

          IF p_channels_reqd >= l_current_channels THEN
             l_channels_to_start := l_current_channels ;
          ELSIF p_channels_reqd < l_current_channels THEN
             l_channels_to_start := p_channels_reqd ;
          END IF ;

          l_channel_started := 0 ;

          FOR c_channel_rec IN c_channel(l_channels_to_start)
              LOOP
                 IF c_channel_rec.adapter_status NOT IN ('IDLE','BUSY') THEN

                    XDP_ADAPTER.START_ADAPTER
                            (p_channelname  => c_channel_rec.channel_name,
                             p_retcode      => l_error_code ,
                             p_errbuf       => l_error_message );

                    IF l_error_code <> 0 THEN
                       RAISE e_exception ;
                    ELSE
                       l_channel_started := l_channel_started + 1 ;
                    END IF ;
                 ELSE
                    null ;
                 END IF ;

              END LOOP ;
              COMMIT;

             x_channels_started := l_channel_started ;
             if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then --Fix Bug: 4256771, dputhiye, 28 Apr 05
                 FND_LOG.STRING(fnd_log.level_statement,'XDPCORE.START_RESUBMISSION_CHANNELS',
                                                    ' No. Of Channels Required '||p_channels_reqd ||
                                                    ' No Of Channel Started '||x_channels_started);
	     end if;
EXCEPTION
     WHEN e_exception THEN
          x_error_code := l_error_code ;
          x_error_message := l_error_message ;
          rollback;
          RAISE ;

     WHEN others THEN
          x_error_code := -191266;
          FND_MESSAGE.SET_NAME('XDP', 'XDP_API_WHEN_OTHERS');
          FND_MESSAGE.SET_TOKEN('API_NAME', 'XDPCORE.START_RESUBMISSION_CHANNELS');
          FND_MESSAGE.SET_TOKEN('ERROR_STRING', SQLERRM);
          x_error_message := FND_MESSAGE.GET;
          RAISE ;
END START_RESUBMISSION_CHANNELS ;


--
-- Context
--   set procedure context (for stack trace)
-- IN
--   pkg_name   - package name
--   proc_name  - procedure/function name
--   arg1       - first IN argument
--   argn       - n'th IN argument
-- EXCEPTIONS
--   none
--
procedure Context(pkg_name  in varchar2,
                  proc_name in varchar2,
                  arg1      in varchar2 default '*none*',
                  arg2      in varchar2 default '*none*',
                  arg3      in varchar2 default '*none*',
                  arg4      in varchar2 default '*none*',
                  arg5      in varchar2 default '*none*',
                  arg6      in varchar2 default '*none*',
                  arg7      in varchar2 default '*none*',
                  arg8      in varchar2 default '*none*',
                  arg9      in varchar2 default '*none*',
                  arg10     in varchar2 default '*none*') is

    buf varchar2(32000);
begin
    -- Start with package and proc name.
    buf := wf_core.newline||pkg_name||'.'||proc_name||'(';

    -- Add all defined args.
    if (arg1 <> '*none*') then
      buf := substrb(buf||arg1, 1, 32000);
    end if;
    if (arg2 <> '*none*') then
      buf := substrb(buf||', '||arg2, 1, 32000);
    end if;
    if (arg3 <> '*none*') then
      buf := substrb(buf||', '||arg3, 1, 32000);
    end if;
    if (arg4 <> '*none*') then
      buf := substrb(buf||', '||arg4, 1, 32000);
    end if;
    if (arg5 <> '*none*') then
      buf := substrb(buf||', '||arg5, 1, 32000);
    end if;
    if (arg6 <> '*none*') then
      buf := substrb(buf||',' ||arg6, 1, 32000);
    end if;
    if (arg7 <> '*none*') then
      buf := substrb(buf||', '||arg7, 1, 32000);
    end if;
    if (arg8 <> '*none*') then
      buf := substrb(buf||', '||arg8, 1, 32000);
    end if;
    if (arg9 <> '*none*') then
      buf := substrb(buf||', '||arg9, 1, 32000);
    end if;
    if (arg10 <> '*none*') then
      buf := substrb(buf||', '||arg10, 1, 32000);
    end if;

    buf := substrb(buf||')', 1, 32000);

    -- Concatenate to the error_stack buffer
    xdpcore.error_stack := substrb(xdpcore.error_stack||buf, 1, 32000);

end Context;

Procedure error_context (object_type in varchar2,
		        object_key in varchar2,
			error_name in varchar2,
			error_message in varchar2)
is

begin

  xdpcore.business_error := 'Y';
  xdpcore.object_type := object_type;
  xdpcore.object_key := object_key;
  xdpcore.error_name := error_name;
  xdpcore.error_message := error_message;

end error_context;

function is_business_error return varchar2
is
begin
  return (NVL(xdpcore.business_error,'N'));

end is_business_error;

procedure Clear is
begin
  xdpcore.business_error := 'N';
  xdpcore.object_type := '';
  xdpcore.object_key := '';
  xdpcore.error_name := '';
  xdpcore.error_number := '';
  xdpcore.error_message := '';
  xdpcore.error_stack := '';

end Clear;


-- Get_Error
--   Return current error info and clear error stack.
--   Returns null if no current error.
-- OUT
--   error_name - error name - varchar2(30)
--   error_message - substituted error message - varchar2(2000)
--   error_stack - error call stack, truncated if needed  - varchar2(2000)
-- EXCEPTIONS
--   none
--
procedure Get_Error(object_type OUT NOCOPY varchar2,
		    object_key OUT NOCOPY varchar2,
		    err_name OUT NOCOPY varchar2,
		    err_message OUT NOCOPY varchar2,
                    err_stack OUT NOCOPY varchar2)
is
begin
  object_type := xdpcore.object_type;
  object_key := xdpcore.object_key;
  err_name := xdpcore.error_name;
  err_message := xdpcore.error_message;
  err_stack := xdpcore.error_stack;
  xdpcore.clear;
end Get_Error;


--
-- Raise
--   Raise an exception to the caller
-- IN
--   none
-- EXCEPTIONS
--   Raises an a user-defined (20002) exception with the error message.
--
procedure Raise(err_number in number default -20001,
		err_message in varchar2 default null)
is
begin
  xdpcore.error_number := err_number;

  if (xdpcore.error_number = -20001) then
    xdpcore.error_message := substrb(to_char(sqlcode)||
                                     ': '||sqlerrm, 1, 2000);
  elsif (xdpcore.error_number is not null) then
    xdpcore.error_message := substrb(to_char(xdpcore.error_number)||
                                     ': '||err_message, 1, 2000);
  end if;

  -- Raise the error
  raise_application_error(err_number, xdpcore.error_message);

exception
  when others then
    raise;
end Raise;

End XDPCORE;

/
