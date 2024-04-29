--------------------------------------------------------
--  DDL for Package Body XDPCORE_FA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDPCORE_FA" AS
/* $Header: XDPCORFB.pls 120.1 2005/06/08 23:44:29 appldev  $ */


/****
 All Private Procedures for the Package
****/

type RowidArrayType is table of rowid index by binary_integer;

Function HandleOtherWFFuncmode (funcmode in varchar2) return varchar2;

Function InitializeFAList(itemtype in varchar2,
                           itemkey in varchar2)  return varchar2;

Function AreAllFAsDone (itemtype in varchar2,
                        itemkey in varchar2) return varchar2;

Procedure LaunchFAProvisioningProcess (itemtype in varchar2,
                                       itemkey in varchar2);

Procedure LaunchFAProcess (itemtype in varchar2,
                           itemkey in varchar2);

Procedure LaunchFAProcessSeq (itemtype in varchar2,
                              itemkey in varchar2);

Procedure InitializeFA(itemtype in varchar2,
                       itemkey in varchar2);

Function GetFe(itemtype in varchar2,
                itemkey in varchar2)  return varchar2;

Procedure IsFEPreDefined(FAInstanceID in number,
			 ConfigError OUT NOCOPY varchar2,
			 FEID OUT NOCOPY number);

Function GetLocateFEProc (FAInstanceID in number) return varchar2;

Function GetFPProc (FAInstanceID in number, FeTypeID in number,
                    FeSwGeneric in varchar2, AdapterType in varchar2)
                   return varchar2;

Function IsChannelAvailable(itemtype in varchar2,
                            itemkey in varchar2,
			    CODFlag in varchar2,
			    AdapterStatus in varchar2) return varchar2;

Function IsAnyChannelAvailable(itemtype in varchar2,
                            itemkey in varchar2) return varchar2;

Function VerifyChannel(itemtype in varchar2,
                        itemkey in varchar2) return varchar2;

Function ProvisionFE(itemtype in varchar2,
                     itemkey in varchar2) return varchar2;

Procedure ExamineErrorCodes(errcode in number,
                            FAInstanceID in number,
                            AbortFAFlag OUT NOCOPY boolean,
                            action OUT NOCOPY varchar2);

Procedure ReleaseFEChannel(itemtype in varchar2,
                           itemkey in varchar2);

Procedure StopFAProcessing(itemtype in varchar2,
                           itemkey in varchar2,
                           actid in number);

Procedure ResetChannel(itemtype in varchar2,
                       itemkey in varchar2);

Function ResolveIndDepFAs (itemtype in varchar2,
                           itemkey in varchar2) return varchar2;

Function LaunchAllIndFAs(itemtype in varchar2,
                       itemkey in varchar2) return varchar2;

Procedure InitializeDepFAProcess(itemtype in varchar2,
                       itemkey in varchar2);

Function GetFaCaller(itemtype in varchar2,
                     itemkey in varchar2,
                     actid in number) return varchar2;

Procedure FindAdminRequestAndPublish (ChannelName in varchar2,
                                      RequestFound OUT NOCOPY BOOLEAN,
                                      Request OUT NOCOPY varchar2);

Function GetResubmissionJobID (itemtype in varchar2,
                               itemkey in varchar2) return number;

Procedure GetWorkitemFAMappingProc(WIInstanceID in number,
				   MappingProcFound OUT NOCOPY varchar2,
				   MappingProc OUT NOCOPY varchar2 );

Procedure PopulateFAs (WIInstanceID in number);

Function ConnectOnDemand (itemtype in varchar2,
                               itemkey in varchar2) return varchar2;

Function IsThresholdExceeded (p_fp_name in varchar2) return varchar2;

Function ErrorDuringRetry (itemtype in varchar2,
                               itemkey in varchar2) return varchar2;

Function IsThresholdReached (p_fp_name in varchar2) return varchar2;

Procedure ResetSystemHold (p_fp_name in varchar2);

Procedure DisconnectOnDemand(   ChannelName in varchar2,
				FeName in varchar2,
				ErrCode OUT NOCOPY number,
				ErrStr OUT NOCOPY varchar2);

Procedure SendAdapterErrorNotif(itemtype in varchar2,
				itemkey in varchar2,
				ChannelName in varchar2,
				FEName in varchar2,
				ErrorDescription in varchar2);

Procedure OverrideFE ( p_faInstanceID IN VARCHAR2,
                       p_FEName IN VARCHAR2,
                       resultout OUT NOCOPY varchar2 );

/*
 skilaru : modified the signature to accept fa status and system hold status
   as part of fixing the bug # 1945013.
   NOTE: System hold status will be 'Y' for fa status SYSTEM_HOLD hold status
   and 'N' for the rest of the fa statuses.
*/
Procedure EnqueueFPQueue(itemtype in varchar2,
                         itemkey in varchar2,
                         p_system_hold in varchar2 DEFAULT 'N')
is
 l_FeID number;

 l_OrderID number;
 l_WIInstanceID number;
 l_FAInstanceID number;
 l_ResubmissionJobID number;

 l_ChannelUsageCode varchar2(40) := 'NORMAL';

 l_ReProcessEnqTime DATE;
 l_ReProcessFlag varchar2(5);
 lv_fa_status varchar2(80);

 x_Progress                     VARCHAR2(2000);

begin
 l_FeID := wf_engine.GetItemAttrNumber(itemtype => EnqueueFPQueue.itemtype,
                                     itemkey => EnqueueFPQueue.itemkey,
                                     aname => 'FE_ID');

 l_OrderID := wf_engine.GetItemAttrNumber(itemtype => EnqueueFPQueue.itemtype,
                                        itemkey => EnqueueFPQueue.itemkey,
                                        aname => 'ORDER_ID');

 l_WIInstanceID := wf_engine.GetItemAttrNumber(itemtype => EnqueueFPQueue.itemtype,
                                        itemkey => EnqueueFPQueue.itemkey,
                                        aname => 'WORKITEM_INSTANCE_ID');

 l_FAInstanceID := wf_engine.GetItemAttrNumber(itemtype => EnqueueFPQueue.itemtype,
                                        itemkey => EnqueueFPQueue.itemkey,
                                        aname => 'FA_INSTANCE_ID');

 l_ReProcessFlag := wf_engine.GetItemAttrText(itemtype => EnqueueFPQueue.itemtype,
                                              itemkey => EnqueueFPQueue.itemkey,
                                              aname => 'RE_PROCESS_FLAG');


  l_ResubmissionJobID := GetResubmissionJobID(itemtype => EnqueueFPQueue.itemtype,
                                              itemkey => EnqueueFPQueue.itemkey);

 SavePoint EnqueueAbortFA;

 if l_ResubmissionJobID <> 0 then
    l_ChannelUsageCode := 'RESUBMISSION';
 end if;

 /*
 ** If the Re-Process flag is set to 'Y' then there was a problem with the Dequeueing
 ** of the Order for a previous channel. The enqueue of the order into the adapter job queue
 ** should have the enqueue time or the previous enqueeu time into the Channel Queue. THis is
 ** set by the Channel Queue Dequeuer. Also the flag needs to be RESET/
 **/

 if l_ReProcessFlag = 'Y' then

    /* Reset the flag */
    wf_engine.SetItemAttrText(itemtype => EnqueueFPQueue.itemtype,
                              itemkey => EnqueueFPQueue.itemkey,
                              aname => 'RE_PROCESS_FLAG',
                              avalue => 'N');

   l_ReProcessEnqTime := wf_engine.GetItemAttrDate(itemtype => EnqueueFPQueue.itemtype,
                                                   itemkey => EnqueueFPQueue.itemkey,
                                                   aname => 'RE_PROCESS_ENQ_TIME');
 else
  l_ReProcessEnqTime := SYSDATE;
 end if;


 insert into XDP_ADAPTER_JOB_QUEUE (
                                   JOB_ID,
                                   FE_ID,
                                   ORDER_ID,
                                   WORKITEM_INSTANCE_ID,
                                   FA_INSTANCE_ID,
                                   QUEUED_ON,
                                   WF_ITEM_TYPE,
                                   CHANNEL_USAGE_CODE,
                                   WF_ITEM_KEY,
                                   SYSTEM_HOLD,
                                   created_by,
                                   creation_date,
                                   last_updated_by,
                                   last_update_date,
                                   last_update_login
                                   )
                           values (XDP_ADAPTER_JOB_QUEUE_S.NEXTVAL,
                                   l_FeID,
                                   l_OrderID,
                                   l_WIInstanceID,
                                   l_FAInstanceID,
                                   NVL(l_ReProcessEnqTime, SYSDATE),
                                   EnqueueFPQueue.itemtype,
                                   l_ChannelUsageCode,
                                   EnqueueFPQueue.itemkey,
                                   p_system_hold,
                                   FND_GLOBAL.USER_ID,
                                   sysdate,
                                   FND_GLOBAL.USER_ID,
                                   sysdate,
                                   FND_GLOBAL.LOGIN_ID);



    IF p_system_hold = 'Y' THEN
       lv_fa_status := XDP_UTILITIES.g_system_hold;
    ELSE
       lv_fa_status := XDP_UTILITIES.g_wait_for_resource;
    END IF;
    -- Change FA Instance status...

    UPDATE xdp_fa_runtime_list
       SET status_code = lv_fa_status
     WHERE fa_instance_id = l_fainstanceid ;

    /* Check if the FA is aborted. If so abort the process immediately */
    if IsFAAborted(l_FAInstanceID) = TRUE then
       rollback to EnqueueAbortFA;
       wf_engine.abortprocess(itemtype => EnqueueFPQueue.itemtype,
                              itemkey => EnqueueFPQueue.itemkey);

       return;
    end if;

exception
when others then
   x_Progress := 'XDPCORE_FA.EnqueueFPQueue. Unhandled Exception: ' || SUBSTR(SQLERRM, 1,1500);
   wf_core.context('XDPCORE_FA', 'EnqueueFPQueue', itemtype, itemkey, null, x_Progress);
   raise;
end EnqueueFPQueue;


PROCEDURE UPDATE_FA_STATUS(p_fa_instance_id IN NUMBER,
                           p_status_code    IN VARCHAR2,
                           p_itemtype       IN VARCHAR2,
                           p_itemkey        IN VARCHAR2 ) ;

/***********************************************
* END of Private Procedures/Function Definitions
************************************************/


--  INITIALIZE_FA_LIST
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--

Procedure INITIALIZE_FA_LIST (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2 ) IS

	x_Progress                     VARCHAR2(2000);

	l_result varchar2(15);
	e_InitFAFailed exception;

BEGIN
-- RUN mode - normal process execution
--
        savepoint InitFA;
	IF (funcmode = 'RUN') THEN
                l_result := InitializeFAList(itemtype, itemkey);
		resultout := 'COMPLETE:'||l_result;

                IF l_result = 'FAILURE' THEN
                  raise e_InitFAFailed;
                END IF;

                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;


EXCEPTION
	WHEN e_InitFAFailed THEN
		Rollback to InitFA;
		XDPCORE.context('XDPCORE_FA', 'INITIALIZE_FA_LIST', itemtype, itemkey );

  --Log the error at the top level call
		XDPCORE_ERROR.LOG_SESSION_ERROR( 'BUSINESS' );
		return;

	WHEN OTHERS THEN
		wf_core.context('XDPCORE_FA', 'INITIALIZE_FA_LIST', itemtype, itemkey, to_char(actid), funcmode);
		raise;
END INITIALIZE_FA_LIST;


--  ARE_ALL_FAS_DONE
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--

Procedure ARE_ALL_FAS_DONE (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2 ) IS
	l_result 	varchar2(10);
	x_Progress      VARCHAR2(2000);

BEGIN
-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN
                l_result := AreAllFAsDone(itemtype, itemkey);
		resultout := 'COMPLETE:' || l_result;
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;



EXCEPTION
	WHEN OTHERS THEN
		wf_core.context('XDPCORE_FA', 'ARE_ALL_FAS_DONE', itemtype, itemkey, to_char(actid), funcmode);
		raise;
END ARE_ALL_FAS_DONE;


--  LAUNCH_FA_PROVISIONING_PROCESS
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--

Procedure LAUNCH_FA_PROVISIONING_PROCESS (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2 ) IS

	x_Progress                     VARCHAR2(2000);

BEGIN
-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN
                LaunchFAProvisioningProcess(itemtype, itemkey);
		resultout := 'COMPLETE:ACTIVITY_PERFORMED';
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;

EXCEPTION
	WHEN OTHERS THEN
		wf_core.context('XDPCORE_FA', 'LAUNCH_FA_PROVISIONING_PROCESS', itemtype, itemkey, to_char(actid), funcmode);
		raise;
END LAUNCH_FA_PROVISIONING_PROCESS;




--  LAUNCH_FA_PROCESS
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--

Procedure LAUNCH_FA_PROCESS (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2 ) IS

	x_Progress	VARCHAR2(2000);

BEGIN
-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN
                LaunchFAProcess(itemtype, itemkey);
		resultout := 'COMPLETE:ACTIVITY_PERFORMED';
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;

EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE_FA', 'LAUNCH_FA_PROCESS', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END LAUNCH_FA_PROCESS;


--  LAUNCH_FA_PROCESS_SEQ
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:

Procedure LAUNCH_FA_PROCESS_SEQ (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2 ) IS

 x_Progress                     VARCHAR2(2000);

BEGIN
-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN
                LaunchFAProcessSeq(itemtype, itemkey);
		resultout := 'COMPLETE:ACTIVITY_PERFORMED';
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;

EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE_FA', 'LAUNCH_FA_PROCESS_SEQ', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END LAUNCH_FA_PROCESS_SEQ;



--  GET_FE
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:

Procedure GET_FE (itemtype        in varchar2,
                  itemkey         in varchar2,
                  actid           in number,
                  funcmode        in varchar2,
                  resultout       OUT NOCOPY varchar2 ) IS

 x_Progress                     VARCHAR2(2000);
 l_result varchar2(15);
 e_GetFEFailed exception;

BEGIN
-- RUN mode - normal process execution
--
        Savepoint get_FE;
	IF (funcmode = 'RUN') THEN
                l_result := GetFe(itemtype, itemkey);
		resultout := 'COMPLETE:' || l_result;
                IF l_result = 'FAILURE' THEN
                  raise e_GetFEFailed;
                END IF;
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;

EXCEPTION

 WHEN e_GetFEFailed THEN
   Rollback to get_FE;
   XDPCORE.context('XDPCORE_FA', 'GET_FE', itemtype, itemkey );

   --Log the error at the top level call
   XDPCORE_ERROR.LOG_SESSION_ERROR( 'BUSINESS' );
   return;

WHEN OTHERS THEN
 wf_core.context('XDPCORE_FA', 'GET_FE', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END GET_FE;


-- INITIALIZE_FA
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:

Procedure INITIALIZE_FA (itemtype        in varchar2,
                        itemkey         in varchar2,
                        actid           in number,
                        funcmode        in varchar2,
                        resultout       OUT NOCOPY varchar2 ) IS


 x_Progress                     VARCHAR2(2000);

BEGIN
-- RUN mode - normal process execution
--
        IF (funcmode = 'RUN') THEN
                InitializeFA(itemtype, itemkey);
                resultout := 'COMPLETE:ACTIVITY_PERFORMED';
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;


EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE_FA', 'INITIALIZE_FA', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END INITIALIZE_FA;



--  ENQUEUE_FP_QUEUE
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure ENQUEUE_FP_QUEUE (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2 ) IS

 x_Progress                     VARCHAR2(2000);

BEGIN
-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN
                EnqueueFPQueue( itemtype => ENQUEUE_FP_QUEUE.itemtype,
                                itemkey => ENQUEUE_FP_QUEUE.itemkey);

		resultout := 'COMPLETE:ACTIVITY_PERFORMED';
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;

EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE_FA', 'ENQUEUE_FP_QUEUE', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END ENQUEUE_FP_QUEUE;


Procedure ENQUEUE_FP_HOLD (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2 ) IS

 x_Progress                     VARCHAR2(2000);

BEGIN
-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN
                EnqueueFPQueue(itemtype, itemkey, 'Y');
		resultout := 'COMPLETE:ACTIVITY_PERFORMED';
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;

EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE_FA', 'ENQUEUE_FP_HOLD', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END ENQUEUE_FP_HOLD;


--  PROVISION_FE
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:

Procedure PROVISION_FE (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2 ) IS

l_result varchar2(20);
 x_Progress                     VARCHAR2(2000);

BEGIN
-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN
                l_result := ProvisionFE(itemtype, itemkey);
		resultout := 'COMPLETE:' || l_result;
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;

EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE_FA', 'PROVISION_FE', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END PROVISION_FE;


--  GET_FA_CALLER
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure GET_FA_CALLER (itemtype        in varchar2,
                         itemkey         in varchar2,
                         actid           in number,
                         funcmode        in varchar2,
                         resultout       OUT NOCOPY varchar2 )
is

l_result varchar2(80);
 x_Progress                     VARCHAR2(2000);

BEGIN
-- RUN mode - normal process execution
--
        IF (funcmode = 'RUN') THEN
                l_result := GetFaCaller(itemtype, itemkey, actid);
                resultout := 'COMPLETE:' || l_result;
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;


EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE_FA', 'GET_FA_CALLER', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END GET_FA_CALLER;



--  RELEASE_FE_CHANNEL
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:

Procedure RELEASE_FE_CHANNEL (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2 ) IS

 x_Progress                     VARCHAR2(2000);

BEGIN
-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN
                ReleaseFEChannel(itemtype, itemkey);
		resultout := 'COMPLETE:ACTIVITY_PERFORMED';
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;


EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE_FA', 'RELEASE_FE_CHANNEL', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END RELEASE_FE_CHANNEL;



--  STOP_FA_PROCESSING
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:

Procedure STOP_FA_PROCESSING (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2 ) IS

 x_Progress                     VARCHAR2(2000);

BEGIN
-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN
                StopFAProcessing(itemtype, itemkey, actid);
		resultout := 'COMPLETE:ACTIVITY_PERFORMED';
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;


EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE_FA', 'STOP_FA_PROCESSING', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END STOP_FA_PROCESSING;


--  IS_CHANNEL_AVAILABLE
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:

Procedure IS_CHANNEL_AVAILABLE (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2 ) IS
 l_result varchar2(80);
 x_Progress                     VARCHAR2(2000);

BEGIN
-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN
                l_result := IsChannelAvailable(itemtype, itemkey, 'N', 'IDLE');
		resultout := 'COMPLETE:' || l_result;
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;


EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE_FA', 'IS_CHANNEL_AVAILABLE', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END IS_CHANNEL_AVAILABLE;

Procedure IS_ANY_CHANNEL_AVAILABLE (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2 ) IS
 l_result varchar2(80);
 x_Progress                     VARCHAR2(2000);

BEGIN
-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN
                l_result := IsAnyChannelAvailable(itemtype, itemkey);
		resultout := 'COMPLETE:' || l_result;
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;


EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE_FA', 'IS_ANY_CHANNEL_AVAILABLE', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END IS_ANY_CHANNEL_AVAILABLE;


--  IS_COD_CHANNEL_AVAILABLE
--   Resultout
--	Yes/No - Yes if a Connect-On-Demand Channel is available
--		 No if No such channel is configured or not available
--		 to be used at this time
--
-- Your Description here:

Procedure IS_COD_CHANNEL_AVAILABLE (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2 ) IS
 l_result varchar2(80);
 x_Progress                     VARCHAR2(2000);

BEGIN
-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN
                l_result := IsChannelAvailable(itemtype, itemkey, 'Y', 'DISCONNECTED');
		resultout := 'COMPLETE:' || l_result;
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;


EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE_FA', 'IS_COD_CHANNEL_AVAILABLE', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END IS_COD_CHANNEL_AVAILABLE;



-- CONNECT_ON_DEMAND
-- Resultout
--	Success/Failure - Success if the Adapter Connected Successfully
--			  Failure if the Connect Procedure fails

Procedure CONNECT_ON_DEMAND (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2) IS
 l_result varchar2(10);
 x_Progress                     VARCHAR2(2000);

BEGIN
-- RUN mode - normal process execution
--
        IF (funcmode = 'RUN') THEN
                l_result := ConnectOnDemand(itemtype, itemkey);
                resultout := 'COMPLETE:' || l_result;
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;

EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE_FA', 'CONNECT_ON_DEMAND', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END CONNECT_ON_DEMAND;


--  WAIT_IN_FP_QUEUE
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:

Procedure WAIT_IN_FP_QUEUE (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2 ) IS

 x_Progress                     VARCHAR2(2000);

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
 wf_core.context('XDPCORE_FA', 'WAIT_IN_FP_QUEUE', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END WAIT_IN_FP_QUEUE;



--  VERIFY_CHANNEL
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:

Procedure VERIFY_CHANNEL (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2 ) IS

 x_Progress                     VARCHAR2(2000);
 l_Result varchar2(30);
BEGIN
-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN
                l_Result := VerifyChannel(itemtype, itemkey);
		resultout := 'COMPLETE:' || l_Result;
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;


EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE_FA', 'VERIFY_CHANNEL', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END VERIFY_CHANNEL;



--  RESET_CHANNEL
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:

Procedure RESET_CHANNEL (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2 ) IS

 x_Progress                     VARCHAR2(2000);

BEGIN
-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN
                ResetChannel(itemtype, itemkey);
		resultout := 'COMPLETE:ACTIVITY_PERFORMED';
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;


EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE_FA', 'RESET_CHANNEL', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END RESET_CHANNEL;


Procedure RESOLVE_IND_DEP_FAS (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2 ) IS

 x_Progress                     VARCHAR2(2000);
 l_Result VARCHAR2(15);

BEGIN
-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN
                l_Result := ResolveIndDepFAs(itemtype, itemkey);
		resultout := 'COMPLETE:' || l_Result;
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;


EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE_FA', 'RESOLVE_IND_DEP_FAS', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END RESOLVE_IND_DEP_FAS;

Procedure LAUNCH_ALL_IND_FAS (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2 ) IS

 x_Progress                     VARCHAR2(2000);

 l_result varchar2(1) := 'N';
BEGIN
-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN
                l_result := LaunchAllIndFAs(itemtype, itemkey);
		resultout := 'COMPLETE:' || l_result;
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;


EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE_FA', 'LAUNCH_ALL_IND_FAS', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END LAUNCH_ALL_IND_FAS;

Procedure INITIALIZE_DEP_FA_PROCESS (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2 ) IS

 x_Progress                     VARCHAR2(2000);

BEGIN
-- RUN mode - normal process execution
--
	IF (funcmode = 'RUN') THEN
                InitializeDepFAProcess(itemtype, itemkey);
		resultout := 'COMPLETE';
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;


EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE_FA', 'INITIALIZE_DEP_FA_PROCESS', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END INITIALIZE_DEP_FA_PROCESS;


Procedure IS_THRESHOLD_EXCEEDED (itemtype        in varchar2,
                        itemkey         in varchar2,
                        actid           in number,
                        funcmode        in varchar2,
                        resultout       OUT NOCOPY varchar2 ) IS

 x_Progress                     VARCHAR2(2000);
 l_result varchar2(1) := 'N';
 lv_fp_name varchar2(80);
 ErrCode NUMBER;
 ErrStr varchar2(1000);
BEGIN
-- RUN mode - normal process execution
--
        IF (funcmode = 'RUN') THEN
           lv_fp_name := wf_engine.getItemAttrText( itemtype => IS_THRESHOLD_EXCEEDED.itemtype,
                                                    itemkey => IS_THRESHOLD_EXCEEDED.itemkey,
                                                    aname => g_fp_name );
           l_result := IsThresholdExceeded(lv_fp_name);
           -- set the channel name attribute.. so that dequeuing fe ready queue will not fail..
           IF ( l_result = 'Y' ) THEN
               XDPCORE.CheckNAddItemAttrText (itemtype => IS_THRESHOLD_EXCEEDED.itemtype,
                                 itemkey => IS_THRESHOLD_EXCEEDED.itemkey,
                                 AttrName => 'CHANNEL_NAME',
                                 AttrValue => NULL,
                                 ErrCode => ErrCode,
                                 ErrStr => ErrStr);
           END IF;

           resultout := 'COMPLETE:' || l_result;
           return;
        ELSE
           resultout := HandleOtherWFFuncmode(funcmode);
           return;
        END IF;


EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE_FA', 'IS_THRESHOLD_EXCEEDED', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END IS_THRESHOLD_EXCEEDED;



Procedure ERROR_DURING_RETRY (itemtype        in varchar2,
                        itemkey         in varchar2,
                        actid           in number,
                        funcmode        in varchar2,
                        resultout       OUT NOCOPY varchar2 ) IS

 x_Progress                     VARCHAR2(2000);
 l_result varchar2(1) := 'N';
BEGIN
-- RUN mode - normal process execution
--
        IF (funcmode = 'RUN') THEN
                l_result := ErrorDuringRetry(itemtype, itemkey);
                resultout := 'COMPLETE:' || l_result;
                return;
        ELSE
                resultout := HandleOtherWFFuncmode(funcmode);
                return;
        END IF;


EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE_FA', 'ERROR_DURING_RETRY', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END ERROR_DURING_RETRY;


Procedure IS_THRESHOLD_REACHED (itemtype        in varchar2,
                        itemkey         in varchar2,
                        actid           in number,
                        funcmode        in varchar2,
                        resultout       OUT NOCOPY varchar2 ) IS

 x_Progress                     VARCHAR2(2000);
 l_result varchar2(40);
 lv_fp_name varchar2(80);
BEGIN
-- RUN mode - normal process execution
--
        IF (funcmode = 'RUN') THEN
           lv_fp_name := wf_engine.getItemAttrText( itemtype => IS_THRESHOLD_REACHED.itemtype,
                                                    itemkey => IS_THRESHOLD_REACHED.itemkey,
                                                    aname => g_fp_name );


           l_result := IsThresholdReached(lv_fp_name);
           resultout := 'COMPLETE:' || l_result;
           return;
        ELSE
           resultout := HandleOtherWFFuncmode(funcmode);
           return;
        END IF;


EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE_FA', 'IS_THRESHOLD_REACHED', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END IS_THRESHOLD_REACHED;


Procedure RESET_SYSTEM_HOLD (itemtype        in varchar2,
                        itemkey         in varchar2,
                        actid           in number,
                        funcmode        in varchar2,
                        resultout       OUT NOCOPY varchar2 ) IS

 lv_fp_name varchar2(80);
 x_Progress                     VARCHAR2(2000);
BEGIN
-- RUN mode - normal process execution
--
        IF (funcmode = 'RUN') THEN
           lv_fp_name := wf_engine.getItemAttrText( itemtype => RESET_SYSTEM_HOLD.itemtype,
                                                    itemkey => RESET_SYSTEM_HOLD.itemkey,
                                                    aname => g_fp_name );
           ResetSystemHold( lv_fp_name);
           resultout := 'COMPLETE';
           return;
        ELSE
           resultout := HandleOtherWFFuncmode(funcmode);
           return;
        END IF;


EXCEPTION
WHEN OTHERS THEN
 wf_core.context('XDPCORE_FA', 'RESET_SYSTEM_HOLD', itemtype, itemkey, to_char(actid), funcmode);
 raise;
END RESET_SYSTEM_HOLD;

Procedure OVERRIDE_FE (itemtype        in varchar2,
                itemkey         in varchar2,
                actid           in number,
                funcmode        in varchar2,
                resultout       OUT NOCOPY varchar2) IS
l_nid NUMBER;
l_faInstanceID NUMBER;
l_newFeName VARCHAR2(100);
BEGIN
-- RUN mode - normal process execution
--
        IF (funcmode = 'RESPOND') THEN
          l_nid := WF_ENGINE.context_nid;
          l_newFeName := wf_notification.GetAttrText( l_nid, 'FE_NAME');

          -- User havent entered any overriding FE Name..
          IF l_newFeName IS NOT NULL THEN
            l_faInstanceID := wf_engine.getItemAttrNumber( itemtype, itemkey, 'FA_INSTANCE_ID' );
            OverrideFE( l_faInstanceID, l_newFeName, resultout );
          END IF;

        ELSIF (funcmode = 'RUN') THEN

          -- skilaru 05/30/2002
          -- This function is a post-notification function so it
          -- will be called in RUN mode after being called in RESPOND mode
          -- do nothing..

          IF XDPCORE.is_business_error = 'Y' THEN
            resultout := 'COMPLETE:FE_NOT_FOUND';
          END IF;

        ELSE
           resultout := HandleOtherWFFuncmode(funcmode);
           return;
        END IF;
EXCEPTION
 WHEN OTHERS THEN
  wf_core.context('XDPCORE_FA', 'OVERRIDE_FE', itemtype, itemkey, to_char(actid), funcmode);
  raise;
END OVERRIDE_FE;

Procedure AUTO_RETRY_ENABLED (itemtype        in varchar2,
                             itemkey         in varchar2,
                             actid           in number,
                             funcmode        in varchar2,
                             resultout       OUT NOCOPY varchar2 ) IS
l_autoRetryEnabled VARCHAR2(1);
BEGIN
  IF( funcmode = 'RUN' ) THEN

    l_autoRetryEnabled := XDP_MACROS.AUTO_RETRY_ENABLED;

    if ( l_autoRetryEnabled = 'Y' ) THEN
      resultout := 'COMPLETE:Y';
    ELSE
      resultout := 'COMPLETE:N';
    END IF;
  ELSE
    resultout := HandleOtherWFFuncmode(funcmode);
    return;
  END IF;

EXCEPTION
 WHEN OTHERS THEN
  wf_core.context('XDPCORE_FA', 'AUTO_RETRY_ENABLED', itemtype, itemkey, to_char(actid), funcmode);
  raise;
END AUTO_RETRY_ENABLED;

/****
 All the Private Functions
****/

Function HandleOtherWFFuncmode( funcmode in varchar2) return varchar2
is
resultout varchar2(30);
 x_Progress                     VARCHAR2(2000);

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

Function InitializeFAList (itemtype in varchar2,
                            itemkey in varchar2) return varchar2
is

 l_WIInstanceID number;
 l_OrderID number;
 l_LineItemID number;
 l_FAListProc varchar2(80);
 l_wi_disp_name varchar2(80);
 l_message_params varchar2(2000);
 l_FAInstanceID number;
 l_ErrCode number;
 l_ProcFound varchar2(1) := 'N';
 l_ProvSeq number;
 l_FAsfound number := 0;

 l_ErrStr varchar2(4000);

 e_ProcExecException exception;
 e_UnHandledException exception;
 e_CallFAMapProcException exception;
 e_AddFAToWIException exception;
 e_NoFAsFound exception;
 e_business_error exception;
 x_Progress                     VARCHAR2(2000);
 l_result varchar2(15) := 'SUCCESS';

begin

 l_WIInstanceID := wf_engine.GetItemAttrNumber(itemtype => InitializeFAList.itemtype,
                                               itemkey => InitializeFAList.itemkey,
                                               aname => 'WORKITEM_INSTANCE_ID');

 l_OrderID := wf_engine.GetItemAttrNumber(itemtype => InitializeFAList.itemtype,
                                          itemkey => InitializeFAList.itemkey,
                                          aname => 'ORDER_ID');

 l_LineItemID := wf_engine.GetItemAttrNumber(itemtype => InitializeFAList.itemtype,
                                             itemkey => InitializeFAList.itemkey,
                                             aname => 'LINE_ITEM_ID');

  GetWorkitemFAMappingProc(l_WIInstanceID, l_ProcFound, l_FAListProc);

 if l_ProcFound = 'N' then
    /* No Procedure has been declared. Hence normal process of executing workitems */

   /* Populate all the FA's in the FA_RUNTIME_LIST Table */

     begin
	PopulateFAs(l_WIInstanceID);
        l_FAsfound := 1;
     exception
     when others then
       x_Progress := 'XDPCORE_FA.InitializeFAList. Exception when Adding FA to Workitem. Order: ' || l_OrderID || ' WorkitemInstanceID: ' || l_WIInstanceID || 'Error: ' || SUBSTR(SQLERRM,1,200);
       xdpcore.context('XDPCORE_FA', 'InitializeFAList', itemtype, itemkey, null, x_Progress);
       l_result := 'FAILURE';
     end;

 else
   /*
    * Found a FA runtime mapping procedure.
    * Need to execute it dynamically to populate all the FA's
    */

    XDP_UTILITIES.CallFAMapProc (P_PROCEDURE_NAME =>  l_FAListProc,
                                 P_ORDER_ID => l_OrderID,
                                 P_LINE_ITEM_ID => l_LineItemID,
                                 P_WI_INSTANCE_ID => l_WIInstanceID,
                                 P_RETURN_CODE => l_ErrCode,
                                 P_ERROR_DESCRIPTION => l_ErrStr);

    if l_ErrCode <> 0 then
      l_wi_disp_name := XDPCORE_WI.get_display_name( l_WIInstanceID );

      -- build the token string for xdp_errors_log..
      l_message_params := 'WI='||l_wi_disp_name||'#XDP#';

      -- set the business error...
      XDPCORE.error_context( 'WI', l_WIInstanceID, 'XDP_UNABLE_TO_RESOLVE_FAS', l_message_params );


      x_Progress := l_ErrStr || 'XDPCORE_FA.InitializeFAList. Error when Executing Procedure: ' || l_FAListProc || ' to dynamically get the FA List for Order: ' || l_OrderID;
      x_Progress := x_Progress || ' WorkitemInstanceID: ' || l_WIInstanceID || ' Error: ' || SUBSTR(l_ErrStr, 1, 1500);
      xdpcore.context('XDPCORE_FA', 'InitializeFAList', itemtype, itemkey, null, x_Progress);
      l_result := 'FAILURE';
    end if;
    l_FAsfound := 1;

 end if;

  -- If FAs not found then
  if l_FAsfound = 0 then
    -- if the error is not set then
    -- HINT: Fa parameter evaluation might fail..
    IF XDPCORE.is_business_error <> 'Y' THEN
      l_wi_disp_name := XDPCORE_WI.get_display_name( l_WIInstanceID );

      -- build the token string for xdp_errors_log..
      l_message_params := 'WI='||l_wi_disp_name||'#XDP#';

      -- set the business error...
      XDPCORE.error_context( 'WI', l_WIInstanceID, 'XDP_UNABLE_TO_RESOLVE_FAS', l_message_params );
    END IF;
    xdpcore.context('XDPCORE_FA', 'InitializeFAList', itemtype, itemkey, null, x_Progress);
    l_result := 'FAILURE';
  end if;
  return l_result;
exception
when e_ProcExecException then
   xdpcore.context('XDPCORE_FA', 'InitializeFAList', itemtype, itemkey, null, x_Progress);
   wf_core.context('XDPCORE_FA', 'InitializeFAList', itemtype, itemkey, null, x_Progress);
   raise;

when e_UnHandledException then
   xdpcore.context('XDPCORE_FA', 'InitializeFAList', itemtype, itemkey, null, x_Progress);
   wf_core.context('XDPCORE_FA', 'InitializeFAList', itemtype, itemkey, null, x_Progress);
   raise;

when e_CallFAMapProcException then
   xdpcore.context('XDPCORE_FA', 'InitializeFAList', itemtype, itemkey, null, x_Progress);
   wf_core.context('XDPCORE_FA', 'InitializeFAList', itemtype, itemkey, null, x_Progress);
   raise;

when e_AddFAToWIException then
   xdpcore.context('XDPCORE_FA', 'InitializeFAList', itemtype, itemkey, null, x_Progress);
   wf_core.context('XDPCORE_FA', 'InitializeFAList', itemtype, itemkey, null, x_Progress);
   raise;

when others then
   x_Progress := 'XDPCORE_FA.InitializeFAList. Unhandled Exception: ' || SUBSTR(SQLERRM, 1,1500);
   xdpcore.context('XDPCORE_FA', 'InitializeFAList', itemtype, itemkey, null, x_Progress);
   wf_core.context('XDPCORE_FA', 'InitializeFAList', itemtype, itemkey, null, x_Progress);
   raise;
end InitializeFAList;


Function AreAllFAsDone (itemtype in varchar2,
                        itemkey in varchar2) return varchar2

is
 cursor c_FaList (wi_id number, prov_seq number) is
  select FA_INSTANCE_ID, PROVISIONING_SEQUENCE
  from XDP_FA_RUNTIME_LIST
  where WORKITEM_INSTANCE_ID = wi_id
    and STATUS_CODE  = 'STANDBY'
    and PROVISIONING_SEQUENCE = (
                                 select MIN(PROVISIONING_SEQUENCE)
                                 from XDP_FA_RUNTIME_LIST
                                 where WORKITEM_INSTANCE_ID = wi_id
                                   and STATUS_CODE  = 'STANDBY'
                                  and PROVISIONING_SEQUENCE > prov_seq);

 l_WIInstanceID number;
 l_PrevFASeq number;

 e_NoFAsFoundException exception;
 x_Progress                     VARCHAR2(2000);

begin

 l_WIInstanceID := WF_engine.GetItemAttrNumber(itemtype => AreAllFAsDone.itemtype,
                                               itemkey => AreAllFAsDone.itemkey,
                                               aname => 'WORKITEM_INSTANCE_ID');


 l_PrevFASeq := wf_engine.GetItemAttrNumber(itemtype => AreAllFAsDone.itemtype,
                                               itemkey => AreAllFAsDone.itemkey,
                                               aname => 'CURRENT_FA_SEQUENCE');


 if c_FaList%ISOPEN then
    Close c_FaList;
 end if;

 open c_FaList(l_WIInstanceID, l_PrevFASeq);

 Fetch c_FaList into l_WIInstanceID, l_PrevFASeq;

 if c_FaList%NOTFOUND  then
     /* No more FA's to be done */
      return ('Y');
 else
   /* There are more FA's to be done */
      return ('N');
 end if;

exception
when e_NoFAsFoundException then
 if c_FaList%ISOPEN then
    Close c_FaList;
 end if;

   wf_core.context('XDPCORE_FA', 'AreAllFAsDone', itemtype, itemkey, null, x_Progress);
   raise;

when others then
 if c_FaList%ISOPEN then
    Close c_FaList;
 end if;

   x_Progress := 'XDPCORE_FA.AreAllFAsDone. Unhandled Exception: ' || SUBSTR(SQLERRM, 1,1500);
   wf_core.context('XDPCORE_FA', 'AreAllFAsDone', itemtype, itemkey, null, x_Progress);
   raise;
end AreAllFAsDone;


Procedure LaunchFAProvisioningProcess (itemtype in varchar2,
                                       itemkey in varchar2)
is

 l_WIInstanceID number;
 l_FAID number;
 l_FAInstanceID number;
 l_OrderID number;
 l_priority number;
 l_ErrCode number;
 l_ErrDescription varchar2(800);

 l_FAItemType varchar2(10);
 l_FAItemKey varchar2(240);
 l_tempKey varchar2(240);

 e_CreatFAWFException exception;
 e_AddFAtoQException exception;

 x_Progress                     VARCHAR2(2000);

begin

 l_OrderID := WF_engine.GetItemAttrNumber(itemtype => LaunchFAProvisioningProcess.itemtype,
                                          itemkey => LaunchFAProvisioningProcess.itemkey,
                                          aname => 'ORDER_ID');

 l_WIInstanceID := WF_engine.GetItemAttrNumber(itemtype => LaunchFAProvisioningProcess.itemtype,
                                               itemkey => LaunchFAProvisioningProcess.itemkey,
                                               aname => 'WORKITEM_INSTANCE_ID');

 l_FAInstanceID := WF_engine.GetItemAttrNumber(itemtype => LaunchFAProvisioningProcess.itemtype,
                                               itemkey => LaunchFAProvisioningProcess.itemkey,
                                               aname => 'FA_INSTANCE_ID');

 l_Priority := WF_engine.GetItemAttrNumber(itemtype => LaunchFAProvisioningProcess.itemtype,
                                               itemkey => LaunchFAProvisioningProcess.itemkey,
                                               aname => 'FA_PRIORITY');




         CreateFAProcess(itemtype, itemkey, l_FAInstanceID, l_WIInstanceID,
                         l_OrderID, 'INTERNAL','WAITFORFLOW-IND_FA',
                         l_FAItemType, l_FAItemKey,
                         l_ErrCode, l_ErrDescription);

    if l_ErrCode <> 0 then
       x_Progress := 'XDPCORE_FA.LaunchFAProvisioningProcess. Error when creating FA Process for Order: '
                || l_OrderID || ' Workitem InstabceID: ' || l_WIInstanceID || ' FAInstanceID: ' || l_FAInstanceID
                || ' Error: ' || SUBSTR(l_ErrDescription, 1, 1500);
       RAISE e_CreatFAWFException;
    end if;


/* Update the XDP_FA_RUNTIME_LIST table with the User defined Workitem Item Type and Item Key */

               update XDP_FA_RUNTIME_LIST
                   set WF_ITEM_TYPE = l_FAItemType,
                       WF_ITEM_KEY = l_FAItemKey,
                       LAST_UPDATE_DATE = sysdate, LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
                       LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
               where   FA_INSTANCE_ID = l_FAInstanceID;

           /* Enqueue the FA into the FA Queue */

           XDP_AQ_UTILITIES.Add_FA_ToQ ( P_ORDER_ID => l_OrderID,
                                         P_WI_INSTANCE_ID => l_WIInstanceID,
                                         P_FA_INSTANCE_ID => l_FAInstanceID,
                                         P_WF_ITEM_TYPE => l_FAItemType,
                                         P_WF_ITEM_KEY => l_FAItemKey,
                                         P_PRIORITY => l_Priority,
                                         P_RETURN_CODE => l_ErrCode,
                                         P_ERROR_DESCRIPTION => l_ErrDescription);

           if l_ErrCode <> 0 then
              x_Progress := 'XDPCORE_FA.LaunchFAProvisioningProcess. Error when Ading FA to Queue for for Order: '
                      || l_OrderID || ' Workitem InstabceID: ' || l_WIInstanceID || ' FAInstanceID: ' || l_FAInstanceID
                      || ' Error: ' || SUBSTR(l_ErrDescription, 1, 1500);

              RAISE e_AddFAtoQException;
           end if;

exception
when e_CreatFAWFException then
   wf_core.context('XDPCORE_FA', 'LaunchFAProvisioningProcess', itemtype, itemkey, null, x_Progress);
   raise;

when e_AddFAtoQException then
   wf_core.context('XDPCORE_FA', 'LaunchFAProvisioningProcess', itemtype, itemkey, null, x_Progress);
   raise;

when others then
   x_Progress := 'XDPCORE_FA.LaunchFAProvisioningProcess. Unhandled Exception: ' || SUBSTR(SQLERRM, 1,1500);
   wf_core.context('XDPCORE_FA', 'LaunchFAProvisioningProcess', itemtype, itemkey, null, x_Progress);
   raise;
end LaunchFAProvisioningProcess;




Procedure InitializeFA (itemtype in varchar2,
                        itemkey in varchar2) IS

 l_FAInstanceID number;
 l_ResubmissionJobID number;

 e_InvalidConfigException exception;
 x_Progress                     VARCHAR2(2000);

begin

 l_FAInstanceID := wf_engine.GetItemAttrNumber(itemtype => InitializeFA.itemtype,
                                             itemkey => InitializeFA.itemkey,
                                             aname => 'FA_INSTANCE_ID');

  l_ResubmissionJobID := GetResubmissionJobID(itemtype => InitializeFA.itemtype,
                                              itemkey => InitializeFA.itemkey);


 /* if the resubmission job is not zero the parent of the fa process is actually the
 ** ORU process. THe Execute FA activity does not set FA Master currently. Hence this
 ** Logic.
 */

 SavePoint InitializeAbortFA;

 if l_FAInstanceID is null then
    RAISE e_InvalidConfigException;
 else

   /* Update the XDP_FA_RUNTIME table with the status of the FA, the state of processing,
    * FA WF item type and item key
    */

      UPDATE_FA_STATUS( p_fa_instance_id => l_FAInstanceID ,
                       p_status_code    => 'IN PROGRESS',
                       p_itemtype       => InitializeFA.itemtype,
                       p_itemkey        => InitializeFA.itemkey );

 end if;

 /* Check if the FA is aborted. If so abort the process immediately */
 if IsFAAborted(l_FAInstanceID) = TRUE then
    rollback to InitializeAbortFA;
    wf_engine.abortprocess(itemtype => InitializeFA.itemtype,
                           itemkey => InitializeFA.itemkey);

    return;
 end if;
exception
when others then
   x_Progress := 'XDPCORE_FA.InitializeFA. Unhandled Exception: ' || SUBSTR(SQLERRM, 1,1500);
   wf_core.context('XDPCORE_FA', 'InitializeFA', itemtype, itemkey, null, x_Progress);
   raise;
end InitializeFA;



Function GetFe (itemtype in varchar2,
                 itemkey in varchar2) return varchar2

is

 l_ConfigError varchar2(1);
 l_FeName varchar2(40);
 l_LocateFEProc varchar2(40);
 l_FeTypeID number;
 l_FeType varchar2(40);
 l_FeID number;
 l_FeSWGeneric varchar2(40);
 l_FAInstanceID number;
 l_WIInstanceID number;
 l_OrderID number;
 l_LineItemID number;
 l_AdapterType varchar2(40);
 l_FAID number;
 l_FaProvProc varchar2(40);
 l_routing_proc_disp_name varchar2(100);
 l_ErrCode number;
 l_ErrStr varchar2(4000);
 l_fa_disp_name varchar2(200);
 l_result varchar2(15) := 'SUCCESS';

 l_message_params varchar2(2000);

 ErrCode number;
 ErrStr varchar2(4000);

 e_InvalidConfigException exception;
 e_InvalidFEConfigException exception;
 e_CallFeRoutingProcException exception;
 e_ProcExecException exception;
 e_GetFeConfigException exception;
 e_AddAttributeException exception;

 x_Progress                     VARCHAR2(2000);

 cursor c_UpdateFEID (p_FAInstanceID number) is
  select 'Update FE ID'
   from XDP_FA_RUNTIME_LIST
  where FA_INSTANCE_ID = p_FAInstanceID
  for update of FE_ID, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN;

begin

 l_FAInstanceID := wf_engine.GetItemAttrNumber(itemtype => GetFE.itemtype,
                                               itemkey => GetFE.itemkey,
                                               aname => 'FA_INSTANCE_ID');

 l_WIInstanceID := wf_engine.GetItemAttrNumber(itemtype => GetFE.itemtype,
                                               itemkey => GetFE.itemkey,
                                               aname => 'WORKITEM_INSTANCE_ID');

 l_OrderID := wf_engine.GetItemAttrNumber(itemtype => GetFE.itemtype,
                                               itemkey => GetFE.itemkey,
                                               aname => 'ORDER_ID');

 l_LineItemID := wf_engine.GetItemAttrNumber(itemtype => GetFE.itemtype,
                                             itemkey => GetFE.itemkey,
                                             aname => 'LINE_ITEM_ID');

 SavePoint GetFEAbortFA;

 IsFEPreDefined(l_FAInstanceID, l_ConfigError, l_FeID);

 if l_ConfigError = 'Y' then
    l_fa_disp_name := get_display_name( l_FAInstanceID );
    -- build the token string for xdp_errors_log..
    l_message_params := 'FA='||l_fa_disp_name||'#XDP#';

    -- set the business error...
    XDPCORE.error_context( 'FA', l_FAInstanceID, 'XDP_FE_NOT_FOUND', l_message_params );

    x_Progress := 'XDPCORE_FA.GetFE. No entries for FA InstanceID: ' || l_FAInstanceID || ' found. Check Order: ' || l_OrderID || ' Workitem InstanceID : ' || l_WIInstanceID;

    xdpcore.context('XDPCORE_FA', 'GetFe', itemtype, itemkey, null, x_Progress);
    return 'FAILURE';
 end if;

 if l_FeID is not null then
   /* Already got the FE_ID need the FE Name and FE information
   /* Got the FEID now get the FE Name. Fetype, FE SW/Generic etc... */

      begin

         XDP_ENGINE.GET_FE_CONFIGINFO (l_FeID,
                                       l_FeName,
                                       l_FetypeID,
                                       l_FeType,
                                       l_FeSWGeneric,
                                       l_AdapterType);
      exception
      when others then
        x_Progress := 'XDPCORE_FA.GeFe. Exception when Getting FE Config Info for FEID: ' || l_FeID || ' FA InstanceID: ' || l_FAInstanceID || ' Order: ' || l_OrderID || ' Workitem InstanceID : ' || l_WIInstanceID || ' Error: ' || SUBSTR(SQLERRM,1,500);

        RAISE e_GetFeConfigException;
      end;

 else

    /* FE NAME IS NOT ALREADY DEFINED  */
    /* Get the LOCATE FE Procedure and execute to determine the FE Name */

    l_LocateFEProc := GetLocateFEProc(l_FAInstanceID);

    if l_LocateFEProc IS NULL then
        x_Progress := 'XDPCORE_FA.GeFe. Could not locate te FE Routing Procedure for FA InstanceID: ' || l_FAInstanceID || ' Order: ' || l_OrderID || ' Workitem InstanceID : ' || l_WIInstanceID;

        RAISE e_InvalidConfigException;
    end if;

    /*
     dynamically execute the Locate FE procedure and get the FE into l_FeName
    */

      XDP_UTILITIES.CallFERoutingProc ( P_PROCEDURE_NAME => l_LocateFEProc,
                                        P_ORDER_ID => l_OrderID,
                                        P_LINE_ITEM_ID => l_LineItemID,
                                        P_WI_INSTANCE_ID => l_WIInstanceID,
                                        P_FA_INSTANCE_ID => l_FAInstanceID,
                                        P_FE_NAME => l_FeName,
                                        P_RETURN_CODE => l_ErrCode,
                                        P_ERROR_DESCRIPTION => l_ErrStr);

      if l_ErrCode <> 0 then
      l_fa_disp_name := get_display_name( l_FAInstanceID );

      -- build the token string for xdp_errors_log..
      l_message_params := 'FA='||l_fa_disp_name||'#XDP#';

      -- set the business error...
      XDPCORE.error_context( 'FA', l_WIInstanceID, 'XDP_EXCEP_IN_FE_RT_PROC', l_message_params );

      xdpcore.context('XDPCORE_FA', 'InitializeFAList', 'FA', l_FAInstanceID, null, l_ErrStr);
      return 'FAILURE';
      end if;

    /* Got the FE Name. Now get the FetypeID, FEID, SW/Generic */

      begin
         XDP_ENGINE.GET_FE_CONFIGINFO( l_FeName,
                                       l_FeID,
                                       l_FetypeID,
                                       l_FeType,
                                       l_FeSWGeneric,
                                       l_AdapterType);
      exception
        when others then

        l_fa_disp_name := get_display_name( l_FAInstanceID );

        SELECT display_name into l_routing_proc_disp_name FROM XDP_PROC_BODY_VL
        WHERE proc_name = l_LocateFEProc;

        -- build the token string for xdp_errors_log..
        l_message_params := 'FA='||l_fa_disp_name|| '#XDP#FE=' || l_FeName ||'#XDP#ROUT_PROC='||l_routing_proc_disp_name||'#XDP#';

        -- set the business error...
        XDPCORE.error_context( 'FE', l_FeID, 'XDP_ROUT_PROC_RETND_INVALID_FE', l_message_params );
        x_Progress := 'XDPCORE_FA.GeFe. Exception when Getting FE Config Info for FE: ' || l_FeName || ' FA InstanceID: ' || l_FAInstanceID || ' Order: ' || l_OrderID || ' Workitem InstanceID : ' || l_WIInstanceID || ' Error: ' || SUBSTR(SQLERRM,1,500);
        xdpcore.context('XDPCORE_FA', 'GetFe', itemtype, itemkey, null, x_Progress);
        return 'FAILURE';
      end;

    FOR v_UpdateFEID in c_UpdateFEID(l_FAInstanceID) LOOP
     update XDP_FA_RUNTIME_LIST set FE_ID = l_FeID,
           LAST_UPDATE_DATE = sysdate, LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
           LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
     where current of c_UpdateFEID;
    END LOOP;

  end if;

    /* Got the FE Name now set the wf item attribute */
    XDPCORE.CheckNAddItemAttrText (itemtype => GetFE.itemtype,
                                   itemkey => GetFE.itemkey,
                                   AttrName => 'FE_NAME',
                                   AttrValue => l_FeName,
                                   ErrCode => ErrCode,
                                   ErrStr => ErrStr);

    if ErrCode <> 0 then
       x_progress := 'In XDPCORE_FA.GetFE. Error when adding FE_NAME attribute. ';
       raise e_AddAttributeException;
    end if;

    XDPCORE.CheckNAddItemAttrNumber (itemtype => GetFE.itemtype,
                                     itemkey => GetFE.itemkey,
                                     AttrName => 'FE_ID',
                                     AttrValue => l_FeID,
                                     ErrCode => ErrCode,
                                     ErrStr => ErrStr);

    if ErrCode <> 0 then
       x_progress := 'In XDPCORE_FA.GetFE. Error when adding FE_ID attribute. ';
       raise e_AddAttributeException;
    end if;

    l_FaProvProc := GetFPProc (l_FAInstanceID, l_FeTypeID,
                               l_FeSwGeneric, l_AdapterType) ;
    if l_FaProvProc is NULL then
      -- get FA display name..
      l_fa_disp_name := get_display_name( l_FAInstanceID );
      -- build the token string for xdp_errors_log..
      l_message_params := 'FA='||l_fa_disp_name||'#XDP#';

      -- set the business error...
      XDPCORE.error_context( 'FA', l_FAInstanceID, 'XDP_FE_FP_NOT_FOUND', l_message_params );

      x_Progress := 'XDPCORE_FA.GetFe. Could not find and FP for FA InstanceID: ' || l_FAInstanceID || ' Order: ' || l_OrderID || ' Workitem InstanceID : ' || l_WIInstanceID;

      xdpcore.context('XDPCORE_FA', 'GetFe', itemtype, itemkey, null, x_Progress);
      return 'FAILURE';
    end if;

     -- skilaru 04/05/02
     -- fa runtime list with the FP name ( fix for the bug # 1945013 )
     update XDP_FA_RUNTIME_LIST set PROC_NAME = l_FaProvProc,
           LAST_UPDATE_DATE = sysdate, LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
           LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
     where fa_instance_id = l_FAInstanceID;

    XDPCORE.CheckNAddItemAttrText (itemtype => GetFE.itemtype,
                                   itemkey => GetFE.itemkey,
                                   AttrName => 'FP_NAME',
                                   AttrValue => l_FaProvProc,
                                   ErrCode => ErrCode,
                                   ErrStr => ErrStr);

    if ErrCode <> 0 then
       x_progress := 'In XDPCORE_FA.GetFE. Error when adding FP_NAME attribute. ';
       raise e_AddAttributeException;
    end if;


 /* Check if the FA is aborted. If so abort the process immediately */
 if IsFAAborted(l_FAInstanceID) = TRUE then
    rollback to GetFEAbortFA;
    wf_engine.abortprocess(itemtype => GetFE.itemtype,
                           itemkey => GetFE.itemkey);
    -- are we still doing faaborted???? skilaru 03/06/02
    return l_result;
 end if;

return l_result;

exception
when e_InvalidConfigException then
   xdpcore.context('XDPCORE_FA', 'GetFe', itemtype, itemkey, null, x_Progress);
   wf_core.context('XDPCORE_FA', 'GetFe', itemtype, itemkey, null, x_Progress);
   raise;

when e_InvalidFEConfigException then
   xdpcore.context('XDPCORE_FA', 'GetFe', itemtype, itemkey, null, x_Progress);
   wf_core.context('XDPCORE_FA', 'GetFe', itemtype, itemkey, null, x_Progress);

when e_CallFeRoutingProcException then
   xdpcore.context('XDPCORE_FA', 'GetFe', itemtype, itemkey, null, x_Progress);
   wf_core.context('XDPCORE_FA', 'GetFe', itemtype, itemkey, null, x_Progress);
  raise;

when e_ProcExecException then
   xdpcore.context('XDPCORE_FA', 'GetFe', itemtype, itemkey, null, x_Progress);
   wf_core.context('XDPCORE_FA', 'GetFe', itemtype, itemkey, null, x_Progress);
  raise;

when e_GetFeConfigException then
   xdpcore.context('XDPCORE_FA', 'GetFe', itemtype, itemkey, null, x_Progress);
   wf_core.context('XDPCORE_FA', 'GetFe', itemtype, itemkey, null, x_Progress);
  raise;

when others then
   x_Progress := 'XDPCORE_FA.GetFe. Unhandled Exception: ' || SUBSTR(SQLERRM, 1,1500);
   xdpcore.context('XDPCORE_FA', 'GetFe', itemtype, itemkey, null, x_Progress);
   wf_core.context('XDPCORE_FA', 'GetFe', itemtype, itemkey, null, x_Progress);
  raise;
end GetFe;



Function IsChannelAvailable (itemtype in varchar2,
                             itemkey in varchar2,
			     CODFlag in varchar2,
			     AdapterStatus in varchar2) return varchar2

is

 e_AddAttributeException exception;

 l_dummy number;

 l_FAInstanceID number;
 l_GotChannelFlag varchar2(1) := 'N';
 l_ChannelName varchar2(40);
 l_ChannelUsageCode varchar2(40) := 'NORMAL';
 l_FeName varchar2(40);
 l_FeID number;
 l_ResubmissionJobID number;
 l_Counter number := 0;

 l_FPFuncMode varchar2(20);
 l_AdapterConnectMode varchar2(40);

 x_Progress                     VARCHAR2(2000);

 ErrCode number;
 ErrStr varchar2(1996);
 l_Status varchar2(1) := 'N';

begin

  l_FAInstanceID := wf_engine.GetItemAttrNumber(itemtype => IsChannelAvailable.itemtype,
                                                itemkey => IsChannelAvailable.itemkey,
                                                aname => 'FA_INSTANCE_ID');

  l_FPFuncMode := wf_engine.GetItemAttrText(itemtype => IsChannelAvailable.itemtype,
                                            itemkey => IsChannelAvailable.itemkey,
                                            aname => 'FP_FUNC_MODE');

 SavePoint GetChannelAbortFA;

  if l_FPFuncMode <> 'RUN' then
   /* Reset the Func Mode */
     wf_engine.SetItemAttrText(itemtype => IsChannelAvailable.itemtype,
                               itemkey => IsChannelAvailable.itemkey,
                               aname => 'FP_FUNC_MODE',
                               avalue => 'RUN');
  end if;

 l_FeID := wf_engine.GetItemAttrNumber(itemtype => IsChannelAvailable.itemtype,
                                        itemkey => IsChannelAvailable.itemkey,
                                        aname => 'FE_ID');

  XDPCORE.CheckNAddItemAttrText (itemtype => IsChannelAvailable.itemtype,
                                 itemkey => IsChannelAvailable.itemkey,
                                 AttrName => 'CHANNEL_NAME',
                                 AttrValue => NULL,
                                 ErrCode => ErrCode,
                                 ErrStr => ErrStr);

  if ErrCode <> 0 then
     x_progress := 'In XDPCORE_FA.IsChannelAvailable. Error when adding CHANNEL_NAME attribute. ';
     raise e_AddAttributeException;
  end if;

  /* If the Resubmission JobID is non zero the fa must look for "RESUBMISSION" type
  ** of adapters.
  */
  l_ResubmissionJobID := GetResubmissionJobID(itemtype => IsChannelAvailable.itemtype,
                                              itemkey => IsChannelAvailable.itemkey);


  if l_ResubmissionJobID <> 0 then
     l_ChannelUsageCode := 'RESUBMISSION';
  end if;

    SearchAndLockChannel( l_FEID ,
		 	  l_ChannelUsageCode ,
			  CODFlag,
			  AdapterStatus ,
                       	  l_GotChannelFlag ,
		 	  l_ChannelName );


     if l_GotChannelFlag = 'Y' then


	if CODFlag = 'N' then

          --skilaru 05/17/2002
          --Lock the channel only if it is pipe based adapter...

	  if  XDP_ADAPTER_CORE_DB.checkLockRequired( l_ChannelName )  then
		XDP_ADAPTER_CORE_DB.Update_Adapter_Status (
				p_ChannelName => l_ChannelName,
				p_Status => XDP_ADAPTER.pv_statusInUse,
				p_WFItemType => IsChannelAvailable.itemtype,
				p_WFItemKey => IsChannelAvailable.itemkey);
	  end if;
	end if;

         XDPCORE.CheckNAddItemAttrText (itemtype => IsChannelAvailable.itemtype,
                                        itemkey => IsChannelAvailable.itemkey,
                                        AttrName => 'CHANNEL_NAME',
                                        AttrValue => l_ChannelName,
                                        ErrCode => ErrCode,
                                        ErrStr => ErrStr);

         if ErrCode <> 0 then
            x_progress := 'In XDPCORE_FA.IsChannelAvailable. Error when adding CHANNEL_NAME attribute. ';
            raise e_AddAttributeException;
         end if;

         /* Check if the FA is aborted. If so abort the process immediately */
         if IsFAAborted(l_FAInstanceID) = TRUE then
            rollback to GetChannelAbortFA;
            wf_engine.abortprocess(itemtype => IsChannelAvailable.itemtype,
                                   itemkey => IsChannelAvailable.itemkey);

            return wf_engine.eng_force;
         end if;

         return 'Y';
     else
         /* Check if the FA is aborted. If so abort the process immediately */
         if IsFAAborted(l_FAInstanceID) = TRUE then
            rollback to GetChannelAbortFA;
            wf_engine.abortprocess(itemtype => IsChannelAvailable.itemtype,
                                   itemkey => IsChannelAvailable.itemkey);

            return wf_engine.eng_force;
         end if;
           return 'N';
     end if;

exception
when others then
   x_Progress := 'XDPCORE_FA.IsChannelAvailable. Unhandled Exception: ' || SUBSTR(SQLERRM, 1,1500);
   wf_core.context('XDPCORE_FA', 'IsChannelAvailable', itemtype, itemkey, null, x_Progress);
   l_Status  := XDP_ADAPTER_CORE_DB.ReleaseAdapterLock (p_ChannelName => l_ChannelName);
   raise;
end IsChannelAvailable;


Function VerifyChannel (itemtype in varchar2,
                         itemkey in varchar2) return varchar2
is
 l_ChannelName varchar2(40);
 l_AdapterStatus varchar2(40);
 l_FAInstanceID number;
 l_ResubmissionJOBID number;
 l_ErrCode number;
 l_ErrStr varchar2(4000);

 x_Progress                     VARCHAR2(2000);

 l_Result varchar2(30) := 'CONTINUE';
 l_Status varchar2(1);
 l_channellock   boolean := FALSE ;
 l_isLockRequired   boolean;
 l_channelstatus varchar2(1) ;

 cursor c_CheckChannel(ChannelName varchar2) is
 select adapter_status
 from XDP_ADAPTER_REG
 where channel_name = ChannelName;

 resource_busy exception;
 pragma exception_init(resource_busy, -00054);

 e_HandOverChannelException exception;
begin

 l_ChannelName := wf_engine.GetItemAttrText(itemtype => VerifyChannel.itemtype,
                                        itemkey => VerifyChannel.itemkey,
                                        aname => 'CHANNEL_NAME');

 l_FAInstanceID := wf_engine.GetItemAttrNumber(itemtype => VerifyChannel.itemtype,
                                               itemkey => VerifyChannel.itemkey,
                                               aname => 'FA_INSTANCE_ID');


 /* If the Channel Name does not exist then the dequeuer has started processing
 ** and the current Channel is not valid any more. The Output is to Reprocess.
 ** Also set the Re-Process flag to 'Y' so that When the order is being enqueued, the enqueue time
 ** is the time the order was enqueued in the Channel Queue. This value is set by the channel
 ** Dequer.
 **/

-- 11.5.6 On-wards.
-- Instead of row level lock. Check for a DB lock
        open c_CheckChannel(l_ChannelName);

        if C_CheckChannel%NOTFOUND then
          close c_CheckChannel;
          return 'RE_PROCESS';
        end if;
        -- skilaru 05/16/2002
        -- ER# 2013681 Lock the channel only if it is of application mode PIPE..

        l_isLockRequired := XDP_ADAPTER_CORE_DB.checkLockRequired( l_ChannelName );
        IF( l_isLockRequired ) THEN

	  l_Status := XDP_ADAPTER_CORE_DB.ObtainAdapterLock_FA
				(p_ChannelName => l_ChannelName);

        END IF;

	if l_Status = 'N' AND l_isLockRequired then
		l_Result := 'RE_PROCESS';
	else
                l_channellock := TRUE ;
	end if;

   if l_Result <> 'RE_PROCESS' then
      Fetch c_CheckChannel into l_AdapterStatus;
         if l_AdapterStatus in ('BUSY', 'STARTING UP', 'DISCONNECTED', 'SUSPENDED', 'SESSION_LOST') then
            /* Raja: Added on 8/31/1999. Verify Channel activity should also update the channel status */
            /* Update the Adapter Status to be BUSY */

		-- Also why are we checking for above statuses?

             if XDP_ADAPTER_CORE_DB.Verify_Adapter (l_ChannelName) then
               l_Result := 'CONTINUE';
             else
               -- Release the Lock
               l_Status  := XDP_ADAPTER_CORE_DB.ReleaseAdapterLock (l_ChannelName);
               l_Result := 'RE_PROCESS';
             END IF;

             -- skilaru 05/16/2002 ER# 2013681
             -- If we dont lock the channel then the status of the adapter is
             -- always Running. Dont update to In Use

             IF( l_isLockRequired ) THEN

		XDP_ADAPTER_CORE_DB.Update_Adapter_Status (
				p_ChannelName => l_ChannelName,
				p_Status => XDP_ADAPTER.pv_statusInUse,
				p_WFItemType => VerifyChannel.itemtype,
				p_WFItemKey => VerifyChannel.itemkey);

             END IF;
           l_Result := 'CONTINUE';
         else
           l_Status  := XDP_ADAPTER_CORE_DB.ReleaseAdapterLock (l_ChannelName);
           l_Result := 'RE_PROCESS';
         end if;
    end if;

    if  l_Result = 'RE_PROCESS' then
      wf_engine.SetItemAttrText(itemtype => VerifyChannel.itemtype,
                                itemkey => VerifyChannel.itemkey,
                                aname => 'RE_PROCESS_FLAG',
                                avalue => 'Y');
    else
        l_Result := 'CONTINUE';
    end if;

    if c_CheckChannel%ISOPEN then
       close c_CheckChannel;
    end if;

 /* Check if the FA is aborted. If so abort the process immediately */
 if IsFAAborted(l_FAInstanceID) = TRUE then
     /*
     ** Call the HAND Over Process which releases the channel to the next
     ** waiting wf process
     */

        HandOverChannel(l_ChannelName, 0, NULL, 'FA', l_ErrCode, l_ErrStr);

        if l_ErrCode <> 0 then
          RAISE e_HandOverChannelException;
        end if;

    wf_engine.AbortProcess(itemtype => VerifyChannel.itemtype,
                           itemkey => VerifyChannel.itemkey);

    return wf_engine.eng_force;
 else
    return l_Result;
 end if;

exception
when others then
    if c_CheckChannel%ISOPEN then
       close c_CheckChannel;
    end if;

     IF l_channellock THEN
        l_channelstatus  := XDP_ADAPTER_CORE_DB.ReleaseAdapterLock (p_ChannelName => l_ChannelName);
     END IF ;

   Rollback to VerifyChannel;

   x_Progress := 'XDPCORE_FA.VerifyChannel. Unhandled Exception: ' || SUBSTR(SQLERRM, 1,1500);
   wf_core.context('XDPCORE_FA', 'VerifyChannel', itemtype, itemkey, null, x_Progress);
   raise;
end VerifyChannel;




Function ProvisionFE (itemtype in varchar2,
                      itemkey in varchar2) return varchar2

is
 l_OrderID number;
 l_WIInstanceID number;
 l_FAInstanceID number;
 l_LineItemID number;
 l_ResubmissionJobID number;
 l_ErrCode number;
 l_ErrActionCode number;
 ErrCode number;
 ErrStr varchar2(1996);



 l_ProcessMode varchar2(40);
 l_ChannelName varchar2(40);
 l_FeName varchar2(40);
 l_FPName varchar2(40);
 l_FeID number;
 l_Result varchar2(20);
 l_ErrAction varchar2(40);
 l_AdapterStatus varchar2(40);
 l_ChannelUsageCode varchar2(40) := 'NORMAL';

 l_FPFuncMode varchar2(20);
 l_ResumeFAFlag varchar2(20);
 l_AbortFAFlag boolean := FALSE;
 l_SuspendFAFlag varchar2(20);
 l_HandOverChannelFlag  varchar2(10);
 l_ErrStr varchar2(32767);

 e_HandOverChannelException exception;
 e_AddAttributeException exception;

 x_Progress                     VARCHAR2(2000);
 x_parameters                     VARCHAR2(4000);

 cursor c_UpdateFAStatus(FAInstanceID number)is
  select 'Update FA Status'
  from XDP_FA_RUNTIME_LIST
  where FA_INSTANCE_ID = FAInstanceID
  for update of STATUS_CODE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN;

 l_Status	varchar2(1);
begin

 l_FPFuncMode := wf_engine.GetItemAttrText(itemtype => ProvisionFE.itemtype,
                                           itemkey => ProvisionFE.itemkey,
                                           aname => 'FP_FUNC_MODE');


 l_FAInstanceID := wf_engine.GetItemAttrNumber(itemtype => ProvisionFE.itemtype,
                                               itemkey => ProvisionFE.itemkey,
                                               aname => 'FA_INSTANCE_ID');


 /* If the FP is Retried as part of an exception which occured previously
 ** from the FMC, then the FP should go through the regular path of
 ** Getting the Channel etc..
 */

 if l_FPFuncMode <> 'RUN' then
    /* Check if the FA is aborted. If so abort the process immediately */
    if IsFAAborted(l_FAInstanceID) = TRUE then
       wf_engine.abortprocess(itemtype => ProvisionFE.itemtype,
                           itemkey => ProvisionFE.itemkey);

       return wf_engine.eng_force;
    else
       return 'ERROR_RETRY';
    end if;

 end if;


 l_ChannelName := wf_engine.GetItemAttrText(itemtype => ProvisionFE.itemtype,
                                            itemkey => ProvisionFE.itemkey,
                                            aname => 'CHANNEL_NAME');

 l_FeID := wf_engine.GetItemAttrNumber(itemtype => ProvisionFE.itemtype,
                                       itemkey => ProvisionFE.itemkey,
                                       aname => 'FE_ID');

 /* If the AbortFlag is set to True then before aborting the process the Channel being used
 ** must be handed over.
 */

 /* Check if the FA is aborted. If so abort the process immediately */
 if IsFAAborted(l_FAInstanceID) = TRUE then
    if l_HandOverChannelFlag = 'TRUE' then
      /* Call the HAND Over Process which releases the channel to the next waiting wf process */


        l_ResubmissionJobID := GetResubmissionJobID(itemtype => ProvisionFE.itemtype,
                                              itemkey => ProvisionFE.itemkey);

        if l_ResubmissionJobID <>0 then
           l_ChannelUsageCode := 'RESUBMISSION';
        end if;

        HandOverChannel(l_ChannelName, l_FeID, l_ChannelUsageCode, 'FA', l_ErrCode, l_ErrStr);

        if l_ErrCode <> 0 then
        RAISE e_HandOverChannelException;
        end if;
    end if;

    wf_engine.AbortProcess(itemtype => ProvisionFE.itemtype,
                           itemkey => ProvisionFE.itemkey);

    return wf_engine.eng_force;
 end if;



 l_FeName := wf_engine.GetItemAttrText(itemtype => ProvisionFE.itemtype,
                                       itemkey => ProvisionFE.itemkey,
                                       aname => 'FE_NAME');

 l_FPName := wf_engine.GetItemAttrText(itemtype => ProvisionFE.itemtype,
                                       itemkey => ProvisionFE.itemkey,
                                       aname => 'FP_NAME');

 l_OrderID := wf_engine.GetItemAttrNumber(itemtype => ProvisionFE.itemtype,
                                          itemkey => ProvisionFE.itemkey,
                                          aname => 'ORDER_ID');

 l_WIInstanceID := wf_engine.GetItemAttrNumber(itemtype => ProvisionFE.itemtype,
                                               itemkey => ProvisionFE.itemkey,
                                               aname => 'WORKITEM_INSTANCE_ID');

 l_LineItemID := wf_engine.GetItemAttrNumber(itemtype => ProvisionFE.itemtype,
                                             itemkey => ProvisionFE.itemkey,
                                             aname => 'LINE_ITEM_ID');

  /* Need to dynamically execute the FP with te above parameters */


     XDP_UTILITIES.CALLFULFILLMENTPROC (P_PROCEDURE_NAME =>  l_FPName,
                                        P_ORDER_ID => l_OrderID,
                                        P_LINE_ITEM_ID => l_LineItemID,
                                        P_WI_INSTANCE_ID => l_WIInstanceID,
                                        P_FA_INSTANCE_ID => l_FAInstanceID,
                                        P_CHANNEL_NAME => l_ChannelName,
                                        P_FE_NAME => l_FeName,
                                        P_FA_ITEM_TYPE => ProvisionFE.itemtype,
                                        P_FA_ITEM_KEY => ProvisionFE.itemkey,
                                        P_RETURN_CODE => l_ErrCode,
                                        P_ERROR_DESCRIPTION => l_ErrStr);

   select adapter_status into l_AdapterStatus
   from XDP_ADAPTER_REG
   where channel_name = l_ChannelName;


   --skilaru 05/19/2002
   --NON-PIPE based adapters are always available never be BUSY..
   if NOT XDP_ADAPTER_CORE_DB.checkLockRequired( l_ChannelName ) then
      wf_engine.SetItemAttrText(itemtype => ProvisionFe.itemtype,
                                itemkey => ProvisionFe.itemkey,
                                aname => 'HANDOVER_CHANNEL_FLAG',
                                avalue => 'TRUE');
   elsif l_AdapterStatus <> 'BUSY' then
      wf_engine.SetItemAttrText(itemtype => ProvisionFe.itemtype,
                                itemkey => ProvisionFe.itemkey,
                                aname => 'HANDOVER_CHANNEL_FLAG',
                                avalue => 'FALSE');
   else
      wf_engine.SetItemAttrText(itemtype => ProvisionFe.itemtype,
                                itemkey => ProvisionFe.itemkey,
                                aname => 'HANDOVER_CHANNEL_FLAG',
                                avalue => 'TRUE');
   end if;


   if l_ErrCode <> 0 then
      xdpcore.context('XDPCORE_FA', 'ProvisionFe', 'FE', l_FeName);
      ExamineErrorCodes(l_ErrCode, l_FAInstanceID, l_AbortFAFlag, l_ErrAction);
      if l_ErrAction = 'PROVISIONING_ERROR' then
         l_result := 'FAILURE';

         -- This error is due to the NOTIFY_ERROR Macro call...
         XDPCORE.CheckNAddItemAttrText (itemtype => ProvisionFE.itemtype,
                                        itemkey => ProvisionFE.itemkey,
                                        AttrName => 'FE_ERROR_TYPE',
                                        AttrValue => 'NOTIFY_ERROR',
                                        ErrCode => ErrCode,
                                        ErrStr => ErrStr);

         /* Need to Set the Error Description */
         XDPCORE.CheckNAddItemAttrText (itemtype => ProvisionFE.itemtype,
                                        itemkey => ProvisionFE.itemkey,
                                        AttrName => 'FE_ERROR_DESCRIPTION',
                                        AttrValue => substr(l_ErrStr,1,2000),
                                        ErrCode => ErrCode,
                                        ErrStr => ErrStr);

         if ErrCode <> 0 then
            x_progress := 'In XDPCORE_FA.ProvisionFE. Error when adding FE_ERROR_DESCRIPTION attribute. ';
            raise e_AddAttributeException;
         end if;

      elsif l_ErrAction = 'NE_SESSION_LOST' then
         l_result := 'SESSION_LOST';

         -- This error is due to the NOTIFY_ERROR Macro call...
         XDPCORE.CheckNAddItemAttrText (itemtype => ProvisionFE.itemtype,
                                        itemkey => ProvisionFE.itemkey,
                                        AttrName => 'FE_ERROR_TYPE',
                                        AttrValue => 'SESSION_LOST',
                                        ErrCode => ErrCode,
                                        ErrStr => ErrStr);

         /* Need to Set the Error Description */
         XDPCORE.CheckNAddItemAttrText (itemtype => ProvisionFE.itemtype,
                                        itemkey => ProvisionFE.itemkey,
                                        AttrName => 'FE_ERROR_DESCRIPTION',
                                        AttrValue => substr(l_ErrStr,1,2000),
                                        ErrCode => ErrCode,
                                        ErrStr => ErrStr);

         if ErrCode <> 0 then
            x_progress := 'In XDPCORE_FA.ProvisionFE. Error when adding FE_ERROR_DESCRIPTION attribute. ';
            raise e_AddAttributeException;
         end if;

      elsif l_ErrAction = 'NE_TIMED_OUT' then
         l_result := 'SUCCESS';

         /* Need to Set the Error Description */
         XDPCORE.CheckNAddItemAttrText (itemtype => ProvisionFE.itemtype,
                                        itemkey => ProvisionFE.itemkey,
                                        AttrName => 'FE_ERROR_DESCRIPTION',
                                        AttrValue => substr(l_ErrStr,1,2000),
                                        ErrCode => ErrCode,
                                        ErrStr => ErrStr);

         if ErrCode <> 0 then
            x_progress := 'In XDPCORE_FA.ProvisionFE. Error when adding FE_ERROR_DESCRIPTION attribute. ';
            raise e_AddAttributeException;
         end if;
      elsif l_ErrAction = 'DYNAMIC_EXEC_ERROR' then

         x_ErrorID := -1;

/* bug fix 1945013
   dont set the adapte status to error..

	x_parameters := 'PROC_NAME='||l_FPName||'#XDP#'||
			'ERROR_STRING='||substr(l_ErrStr,1,1500)||'#XDP#';

	XDP_ADAPTER_CORE_DB.Update_Adapter_Status (
                p_ChannelName 	=> l_ChannelName,
	        p_Status 	=> XDP_ADAPTER.pv_statusError,
		p_ErrorMsg 	=> 'XDP_DYNAMIC_PROC_EXEC_ERROR',
		p_ErrorMsgParams => x_parameters
		);

         COMMIT;
*/

         /* Need to Set the Error Description */
         XDPCORE.CheckNAddItemAttrText (itemtype => ProvisionFE.itemtype,
                                        itemkey => ProvisionFE.itemkey,
                                        AttrName => 'FE_ERROR_DESCRIPTION',
                                        AttrValue => substr(l_ErrStr,1,2000),
                                        ErrCode => ErrCode,
                                        ErrStr => ErrStr);

         l_result := 'EXCEPTION';

      elsif l_ErrAction = 'INTERNAL_SDP_ERROR' then


         x_ErrorID := -1;

/* bug fix 1945013
   dont set the adapte status to error..

	x_parameters := 'PROC_NAME='||l_FPName||'#XDP#'||
			'CHANNEL_NAME='||l_ChannelName||'#XDP#'||
			'FE_NAME='||l_FeName||'#XDP#'||
			'ERROR_STRING='||substr(l_ErrStr,1,1500)||'#XDP#';



	XDP_ADAPTER_CORE_DB.Update_Adapter_Status (
                p_ChannelName 	=> l_ChannelName,
	        p_Status 	=> XDP_ADAPTER.pv_statusError,
		p_ErrorMsg 	=> 'XDP_INTERNAL_CHANNEL_ERROR',
		p_ErrorMsgParams => x_parameters
		);

         COMMIT;
*/

         /* Need to Set the Error Description */
         XDPCORE.CheckNAddItemAttrText (itemtype => ProvisionFE.itemtype,
                                        itemkey => ProvisionFE.itemkey,
                                        AttrName => 'FE_ERROR_DESCRIPTION',
                                        AttrValue => substr(l_ErrStr,1,2000),
                                        ErrCode => ErrCode,
                                        ErrStr => ErrStr);

         l_result := 'EXCEPTION';

      elsif l_ErrAction = 'CHANGE_CONNECTION_ERROR' then

/* bug fix 1945013
   dont set the adapte status to error..

	XDP_ADAPTER_CORE_DB.Update_Adapter_Status (
                p_ChannelName 	=> l_ChannelName,
	        p_Status 	=> XDP_ADAPTER.pv_statusDisconnected
		);

         COMMIT;
*/

         wf_engine.SetItemAttrText(itemtype => ProvisionFE.itemtype,
                                   itemkey => ProvisionFE.itemkey,
                                   aname => 'HANDOVER_CHANNEL_FLAG',
                                   avalue => 'FALSE');

         XDPCORE.CheckNAddItemAttrText (itemtype => ProvisionFE.itemtype,
                                        itemkey => ProvisionFE.itemkey,
                                        AttrName => 'FE_ERROR_DESCRIPTION',
                                        AttrValue => substr(l_ErrStr,1,2000),
                                        ErrCode => ErrCode,
                                        ErrStr => ErrStr);

         if ErrCode <> 0 then
            x_progress := 'In XDPCORE_FA.ProvisionFE. Error when adding FE_ERROR_DESCRIPTION attribute. ';
            raise e_AddAttributeException;
         end if;
         l_result := 'FAILURE';

      elsif l_ErrAction = 'UNHANDLED_EXCEPTION' then


         x_ErrorID := -1;

/* bug fix 1945013
   dont set the adapte status to error..

	x_parameters := 'PROC_NAME='||l_FPName||'#XDP#'||
			'ERROR_STRING='||substr(l_ErrStr,1,1500)||'#XDP#';

	XDP_ADAPTER_CORE_DB.Update_Adapter_Status (
                p_ChannelName 	=> l_ChannelName,
	        p_Status 	=> XDP_ADAPTER.pv_statusError,
		p_ErrorMsg 	=> 'XDP_UNHANDLED_FP_EXEC_ERROR',
		p_ErrorMsgParams => x_parameters
		);

         COMMIT;

*/

         /* Need to Set the Error Description */
         XDPCORE.CheckNAddItemAttrText (itemtype => ProvisionFE.itemtype,
                                        itemkey => ProvisionFE.itemkey,
                                        AttrName => 'FE_ERROR_DESCRIPTION',
                                        AttrValue => substr(l_ErrStr,1,2000),
                                        ErrCode => ErrCode,
                                        ErrStr => ErrStr);


         l_result := 'EXCEPTION';
      end if;
   else

      l_Result := 'SUCCESS';
   end if;

   /* Check the FA Abort Flag and set the FA Execution Status accordingly */
   if (l_AbortFAFlag = TRUE) OR (IsFAAborted(l_FAInstanceID) = TRUE) then
      if l_HandOverChannelFlag = 'TRUE' then
        /* Call the HAND Over Process which releases the channel to the next waiting wf process */


        l_ResubmissionJobID := GetResubmissionJobID(itemtype => ProvisionFE.itemtype,
                                              itemkey => ProvisionFE.itemkey);

          if l_ResubmissionJobID <>0 then
             l_ChannelUsageCode := 'RESUBMISSION';
          end if;

          HandOverChannel(l_ChannelName, l_FeID, l_ChannelUsageCode, 'FA', l_ErrCode, l_ErrStr);

          if l_ErrCode <> 0 then
            RAISE e_HandOverChannelException;
          end if;
      end if;

          /* Set the status of Execution */
          FOR v_UpdateFAStatus in c_UpdateFAStatus(l_FAInstanceID) LOOP
             update XDP_FA_RUNTIME_LIST set STATUS_CODE = l_Result,
               LAST_UPDATE_DATE = sysdate, LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
               LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
             where current of c_UpdateFAStatus;
          END LOOP;


      wf_engine.AbortProcess(itemtype => ProvisionFE.itemtype,
                             itemkey => ProvisionFE.itemkey);

      return wf_engine.eng_force;
   else
      return l_Result;
   end if;

exception
when e_HandOverChannelException then

       l_Status := XDP_ADAPTER_CORE_DB.ReleaseAdapterLock
                                (p_ChannelName => l_ChannelName);

wf_core.context('XDPCORE_FA', 'HandOverChannel', null, null, x_Progress,null);
  raise;

when others then

       l_Status := XDP_ADAPTER_CORE_DB.ReleaseAdapterLock
                                (p_ChannelName => l_ChannelName);

   /* Set the FP_FUNC_MODE to be RETRY so that when the user retries the activity it goes
   ** back to the regular get Channel Process
   */

   wf_engine.SetItemAttrText(itemtype => ProvisionFE.itemtype,
                             itemkey => ProvisionFE.itemkey,
                             aname => 'FP_FUNC_MODE',
                             avalue => 'RETRY');

   COMMIT;
   x_Progress := 'XDPCORE_FA.ProvisionFE. Unhandled Exception: ' || SUBSTR(SQLERRM, 1,1500);
   wf_core.context('XDPCORE_FA', 'ProvisionFE', itemtype, itemkey, null, x_Progress);
   raise;

end ProvisionFE;


Procedure ExamineErrorCodes (errcode in number,
                             FAInstanceID in number,
                             AbortFAFlag OUT NOCOPY boolean,
                             action OUT NOCOPY varchar2)

is

 x_Progress                     VARCHAR2(2000);

begin

 /* Check if the FA is aborted. If so abort the process immediately */
 if IsFAAborted(FAInstanceID) = TRUE then
    AbortFAFlag := TRUE;
 end if;

 if (errcode = -666) OR (errcode = -20050) or (errcode = -20051) then
  action := 'PROVISIONING_ERROR';
  return;
 elsif errcode >= -20300 and errcode <= -20101 then
  action :=  'INTERNAL_SDP_ERROR';
  return;
 elsif (errcode >= -20503 and errcode <= -20501) OR
        errcode = -20003 then
  action := 'DYNAMIC_EXEC_ERROR';
  return;
 elsif errcode >= -20035 and errcode <= -20031 then
  action := 'CHANGE_CONNECTION_ERROR';
  return;
 elsif errcode = -20610 then
  action := 'NE_SESSION_LOST';
 elsif errcode = -20620 then
  action := 'NE_TIMED_OUT';
 else
  action := 'UNHANDLED_EXCEPTION';
  return;
 end if;


exception
when others then
   x_Progress := 'XDPCORE_FA.ExamineErrorCodes. Unhandled Exception: ' || SUBSTR(SQLERRM, 1,1500);
   wf_core.context('XDPCORE_FA', 'ExamineErrorCodes', null, null, x_Progress,null);
   raise;
end ExamineErrorCodes;



Procedure ReleaseFEChannel (itemtype in varchar2,
                            itemkey in varchar2)
is
 l_ChannelName varchar2(40);
 l_FeName varchar2(40);
 l_HandOverChannelFlag varchar2(40);
 l_ErrStr varchar2(4000);

 l_ErrCode number;
 l_OrderID number;
 l_FeID number;
 l_WIInstanceID number;
 l_FAInstanceID number;
 l_ChannelUsageCode varchar2(40) := 'NORMAL';
 l_ResubmissionJobID number;

 l_AdminRequest varchar2(40);
 l_RequestFlag BOOLEAN;
 l_Status varchar2(1);

 e_HandOverChannelException exception;

 x_Progress                     VARCHAR2(2000);

begin

 l_ChannelName := wf_engine.GetItemAttrText(itemtype => ReleaseFEChannel.itemtype,
                                            itemkey => ReleaseFEChannel.itemkey,
                                            aname => 'CHANNEL_NAME');

 l_FeID := wf_engine.GetItemAttrNumber(itemtype => ReleaseFEChannel.itemtype,
                                       itemkey => ReleaseFEChannel.itemkey,
                                       aname => 'FE_ID');

 l_OrderID := wf_engine.GetItemAttrNumber(itemtype => ReleaseFEChannel.itemtype,
                                          itemkey => ReleaseFEChannel.itemkey,
                                          aname => 'ORDER_ID');

 l_WIInstanceID := wf_engine.GetItemAttrNumber(itemtype => ReleaseFEChannel.itemtype,
                                               itemkey => ReleaseFEChannel.itemkey,
                                               aname => 'WORKITEM_INSTANCE_ID');

 l_FAInstanceID := wf_engine.GetItemAttrNumber(itemtype => ReleaseFEChannel.itemtype,
                                               itemkey => ReleaseFEChannel.itemkey,
                                               aname => 'FA_INSTANCE_ID');


 l_ResubmissionJobID := GetResubmissionJobID(itemtype => ReleaseFEChannel.itemtype,
                                              itemkey => ReleaseFEChannel.itemkey);

 l_HandOverChannelFlag := wf_engine.GetItemAttrText(itemtype => ReleaseFEChannel.itemtype,
                                                    itemkey => ReleaseFEChannel.itemkey,
                                                    aname => 'HANDOVER_CHANNEL_FLAG');

 if l_ResubmissionJobID <> 0 then
    l_ChannelUsageCode := 'RESUBMISSION';
 end if;

	l_Status := XDP_ADAPTER_CORE_DB.ReleaseAdapterLock
				(p_ChannelName => l_ChannelName);

    if l_HandOverChannelFlag = 'TRUE' then
      /* Call the HAND Over Process which releases the channel to the next waiting wf process */

        HandOverChannel(l_ChannelName, l_FeID, l_ChannelUsageCode, 'FA', l_ErrCode, l_ErrStr);

        if l_ErrCode <> 0 then
        RAISE e_HandOverChannelException;
        end if;
    end if;
      wf_engine.SetItemAttrText(itemtype => ReleaseFEChannel.itemtype,
                                itemkey => ReleaseFEChannel.itemkey,
                                aname => 'HANDOVER_CHANNEL_FLAG',
                                avalue => 'TRUE');

    COMMIT;

 /* Check if the FA is aborted. If so abort the process immediately */
 if IsFAAborted(l_FAInstanceID) = TRUE then
    wf_engine.abortprocess(itemtype => ReleaseFEChannel.itemtype,
                           itemkey => ReleaseFEChannel.itemkey);

    return;
 end if;

exception
when others then
   x_Progress := 'XDPCORE_FA.ReleaseFEChannel. Unhandled Exception: ' || SUBSTR(SQLERRM, 1,1500);
   wf_core.context('XDPCORE_FA', 'ReleaseFEChannel', itemtype, itemkey, null, x_Progress);
   l_Status := XDP_ADAPTER_CORE_DB.ReleaseAdapterLock (p_ChannelName => l_ChannelName);
   raise;
end ReleaseFEChannel;



Procedure StopFAProcessing (itemtype in varchar2,
                            itemkey in varchar2,
                            actid in number)
is
 l_FAInstanceID number;
 x_Progress                     VARCHAR2(2000);

begin

 l_FAInstanceID := wf_engine.GetItemAttrNumber(itemtype => StopFAProcessing.itemtype,
                                               itemkey => StopFAProcessing.itemkey,
                                               aname => 'FA_INSTANCE_ID');



 if l_FAInstanceID is null then
    /* SOME THING IS WRONG !!! */
    /* RAISE ???? */
    null;
 else



   /* DO I ABORT the Processing ??
   */
   /* Stop the FA Processing.. Hence mark the status of the FA to be ABORTED
   update XDP_FA_RUNTIME_LIST
   set STATUS_CODE = 'ABORTED'
   where FA_INSTANCE_ID = l_FAInstanceID;
    */


    null;
 end if;




exception
when others then
   x_Progress := 'XDPCORE_FA.StopFAProcessing. Unhandled Exception: ' || SUBSTR(SQLERRM, 1,1500);
   wf_core.context('XDPCORE_FA', 'StopFAProcessing', itemtype, itemkey, to_char(actid),null);
   raise;
end StopFAProcessing;



Procedure ResetChannel (itemtype in varchar2,
                        itemkey in varchar2)
is

 x_Progress                     VARCHAR2(2000);

begin

 /*
  * 1. Reset the channel to NULL
  * 2. Set the mode to be 'RETRY'
  */




  wf_engine.SetItemAttrText(itemtype => ResetChannel.itemtype,
                            itemkey => ResetChannel.itemkey,
                            aname => 'CHANNEL_NAME',
                            avalue => null);

exception
when others then
   x_Progress := 'XDPCORE_FA.ResetChannel. Unhandled Exception: ' || SUBSTR(SQLERRM, 1,1500);
   wf_core.context('XDPCORE_FA', 'ResetChannel', itemtype, itemkey, null, x_Progress);
   raise;
end ResetChannel;





Function GetFaCaller (itemtype in varchar2,
                      itemkey in varchar2,
                      actid in number) return varchar2

is

 l_FaCaller varchar2(40);
 x_Progress                     VARCHAR2(2000);

begin

 l_FaCaller := wf_engine.GetItemAttrText(itemtype => GetFaCaller.itemtype,
                                       itemkey => GetFaCaller.itemkey,
                                       aname => 'FA_CALLER');




 return (l_FaCaller);

exception
when others then
   x_Progress := 'XDPCORE_FA.GetFaCaller. Unhandled Exception: ' || SUBSTR(SQLERRM, 1,1500);
   wf_core.context('XDPCORE_FA', 'GetFaCaller', itemtype, itemkey, to_char(actid),null);
   raise;
end GetFaCaller;



Procedure CreateFAProcess (parentitemtype in varchar2,
                           parentitemkey in varchar2,
                           FAInstanceID in number,
                           WIInstanceID in number,
                           OrderID in number,
                           FaCaller in varchar2 DEFAULT 'EXTERNAL',
                           FaMaster in varchar2,
                           FaItemtype OUT NOCOPY varchar2,
                           FaItemkey OUT NOCOPY varchar2,
                           ErrCode OUT NOCOPY number,
                           ErrStr OUT NOCOPY varchar2)

is

l_tempKey varchar2(240);
l_LineItemID number;

 x_Progress                     VARCHAR2(2000);

l_NameArray Wf_Engine.NameTabTyp;
l_ValueNumArray Wf_Engine.NumTabTyp;
begin
        FaItemtype := 'XDPPROV';
        ErrCode := 0;
        ErrStr := null;

        l_LineItemID := wf_engine.GetItemAttrNumber(itemtype => parentitemtype,
                                                    itemkey => parentitemkey,
                                                    aname => 'LINE_ITEM_ID');

        select to_char(XDP_WF_ITEMKEY_S.NEXTVAL) into l_tempKey from dual;
        FaItemkey := to_char(OrderID) || '-WI-' || to_char(WIInstanceID) || '-FA' || l_tempKey;


-- Create Process and Bulk Set Item Attribute
	  XDPCORE.CreateNAddAttrNParentLabel(itemtype => FaItemtype,
			      itemkey => FaItemkey,
			      processname => 'FA_PROCESS',
			      parentitemtype => parentitemtype,
			      parentitemkey => parentitemkey,
			      waitflowlabel => FaMaster,
			      OrderID => OrderID,
			      LineitemID => l_LineItemID,
			      WIInstanceID => WIInstanceID,
			      FAInstanceID => FAInstanceID);

          wf_engine.SetItemAttrText(itemtype => 'XDPPROV',
                                    itemkey => FaItemkey,
                                    aname => 'MASTER_TO_CONTINUE',
                                    avalue => FaMaster);

          XDPCORE.CheckNAddItemAttrText (itemtype => FaItemtype,
                                         itemkey => FaItemkey,
                                         AttrName => 'FA_CALLER',
                                         AttrValue => FaCaller,
                                         ErrCode => ErrCode,
                                         ErrStr => ErrStr);

          if ErrCode <> 0 then
             return;
          end if;

          XDPCORE.CheckNAddItemAttrText (itemtype => FaItemtype,
                                         itemkey => FaItemkey,
                                         AttrName => 'HANDOVER_CHANNEL_FLAG',
                                         AttrValue => 'TRUE',
                                         ErrCode => ErrCode,
                                         ErrStr => ErrStr);

          if ErrCode <> 0 then
             return;
          end if;

          XDPCORE.CheckNAddItemAttrText (itemtype => FaItemtype,
                                         itemkey => FaItemkey,
                                         AttrName => 'FP_FUNC_MODE',
                                         AttrValue => 'RUN',
                                         ErrCode => ErrCode,
                                         ErrStr => ErrStr);

          if ErrCode <> 0 then
             return;
          end if;

          XDPCORE.CheckNAddItemAttrText (itemtype => FaItemtype,
                                         itemkey => FaItemkey,
                                         AttrName => 'RE_PROCESS_FLAG',
                                         AttrValue => 'N',
                                         ErrCode => ErrCode,
                                         ErrStr => ErrStr);

          if ErrCode <> 0 then
             return;
          end if;


          XDPCORE.CheckNAddItemAttrDate (itemtype => FaItemtype,
                                         itemkey => FaItemkey,
                                         AttrName => 'RE_PROCESS_ENQ_TIME',
                                         AttrValue => SYSDATE,
                                         ErrCode => ErrCode,
                                         ErrStr => ErrStr);

          if ErrCode <> 0 then
             return;
          end if;

exception
when others then
 ErrCode := SQLCODE;
 ErrStr := SUBSTR(SQLERRM, 1, 800);
end CreateFAProcess;


Procedure CreateFAProcess(parentitemtype in varchar2,
                          parentitemkey in varchar2,
                          FAInstanceID in number,
                          WIInstanceID in number,
                          OrderID in number,
                          LineItemID in number,
                          ResubmissionJobID in number,
                          FaCaller in varchar2 DEFAULT 'EXTERNAL',
                          FaMaster in varchar2,
                          FaItemtype OUT NOCOPY varchar2,
                          FaItemkey OUT NOCOPY varchar2,
                          ErrCode OUT NOCOPY number,
                          ErrStr OUT NOCOPY varchar2)

is

l_tempKey varchar2(240);

 x_Progress                     VARCHAR2(2000);

l_NameArray Wf_Engine.NameTabTyp;
l_ValueNumArray Wf_Engine.NumTabTyp;

begin
        FaItemtype := 'XDPPROV';
        ErrCode := 0;
        ErrStr := null;

        select to_char(XDP_WF_ITEMKEY_S.NEXTVAL) into l_tempKey from dual;
        FaItemkey := to_char(OrderID) || '-WI-' || to_char(WIInstanceID) || '-FA' || l_tempKey;



-- Bulk Set Item Attribute
	  XDPCORE.CreateAndAddAttrNum(itemtype => FaItemtype,
			      itemkey => FaItemkey,
			      processname => 'FA_PROCESS',
			      parentitemtype => parentitemtype,
			      parentitemkey => parentitemkey,
			      OrderID => OrderID,
			      LineitemID => LineItemID,
			      WIInstanceID => WIInstanceID,
			      FAInstanceID => FAInstanceID);


          wf_engine.SetItemAttrText(itemtype => 'XDPPROV',
                                    itemkey => FaItemkey,
                                    aname => 'MASTER_TO_CONTINUE',
                                    avalue => FaMaster);

          XDPCORE.CheckNAddItemAttrText (itemtype => FaItemtype,
                                         itemkey => FaItemkey,
                                         AttrName => 'FA_CALLER',
                                         AttrValue => FaCaller,
                                         ErrCode => ErrCode,
                                         ErrStr => ErrStr);

          if ErrCode <> 0 then
             return;
          end if;

          XDPCORE.CheckNAddItemAttrNumber (itemtype => FaItemtype,
                                           itemkey => FaItemkey,
                                           AttrName => 'RESUBMISSION_JOB_ID',
                                           AttrValue => ResubmissionJobID,
                                           ErrCode => ErrCode,
                                           ErrStr => ErrStr);

          if ErrCode <> 0 then
             return;
          end if;

          XDPCORE.CheckNAddItemAttrText (itemtype => FaItemtype,
                                         itemkey => FaItemkey,
                                         AttrName => 'HANDOVER_CHANNEL_FLAG',
                                         AttrValue => 'TRUE',
                                         ErrCode => ErrCode,
                                         ErrStr => ErrStr);

          if ErrCode <> 0 then
             return;
          end if;

          XDPCORE.CheckNAddItemAttrText (itemtype => FaItemtype,
                                         itemkey => FaItemkey,
                                         AttrName => 'FP_FUNC_MODE',
                                         AttrValue => 'RUN',
                                         ErrCode => ErrCode,
                                         ErrStr => ErrStr);

          if ErrCode <> 0 then
             return;
          end if;

          XDPCORE.CheckNAddItemAttrText (itemtype => FaItemtype,
                                         itemkey => FaItemkey,
                                         AttrName => 'RE_PROCESS_FLAG',
                                         AttrValue => 'N',
                                         ErrCode => ErrCode,
                                         ErrStr => ErrStr);

          if ErrCode <> 0 then
             return;
          end if;


          XDPCORE.CheckNAddItemAttrDate (itemtype => FaItemtype,
                                         itemkey => FaItemkey,
                                         AttrName => 'RE_PROCESS_ENQ_TIME',
                                         AttrValue => SYSDATE,
                                         ErrCode => ErrCode,
                                         ErrStr => ErrStr);

          if ErrCode <> 0 then
             return;
          end if;

exception
when others then
 ErrCode := SQLCODE;
 ErrStr := SUBSTR(SQLERRM, 1, 800);
end CreateFAProcess;


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



Procedure LaunchFAProcess (itemtype in varchar2,
                           itemkey in varchar2)

is
 l_OrderID number;
 l_WIInstanceID number;
 l_LineItemID number;
 l_Counter number := 0;
 l_FAInstanceID number;
 l_FAID number;
 l_Priority number;

 l_ErrCode number;
 l_ErrStr varchar2(1996);

 l_tempKey varchar2(240);

 cursor c_GetIndFA (WIInstanceID number) is
   select FA_INSTANCE_ID, FULFILLMENT_ACTION_ID, PRIORITY
   from XDP_FA_RUNTIME_LIST
   where WORKITEM_INSTANCE_ID = WIInstanceID
     and STATUS_CODE               = 'STANDBY'
     and (PROVISIONING_SEQUENCE IS NULL or PROVISIONING_SEQUENCE = 0) ;

 cursor c_GetDepFA (WIInstanceID number) is
   select FA_INSTANCE_ID, FULFILLMENT_ACTION_ID, PRIORITY
   from XDP_FA_RUNTIME_LIST
   where WORKITEM_INSTANCE_ID = WIInstanceID
     and STATUS_CODE               = 'STANDBY'
     and PROVISIONING_SEQUENCE > 0;

 TYPE t_ChildKeyTable is table of varchar2(240) INDEX BY BINARY_INTEGER;
 t_ChildKeys t_ChildKeyTable;

 TYPE t_ChildTypeTable is table of varchar2(10) INDEX BY BINARY_INTEGER;
 t_ChildTypes t_ChildTypeTable;


 e_NoFAsFoundException exception;
 e_AddAttributeException exception;

 x_Progress                     VARCHAR2(2000);

begin

  l_OrderID := wf_engine.GetItemAttrNumber(itemtype => LaunchFAProcess.itemtype,
                                           itemkey => LaunchFAProcess.itemkey,
                                           aname => 'ORDER_ID');

  l_WIInstanceID := wf_engine.GetItemAttrNumber(itemtype => LaunchFAProcess.itemtype,
                                                itemkey => LaunchFAProcess.itemkey,
                                                aname => 'WORKITEM_INSTANCE_ID');

  l_LineItemID := wf_engine.GetItemAttrNumber(itemtype => LaunchFAProcess.itemtype,
                                              itemkey => LaunchFAProcess.itemkey,
                                              aname => 'LINE_ITEM_ID');

  /* Launch all the Independent FA Processes */

  if c_GetIndFA%ISOPEN then
     close c_GetIndFA;
  end if;

  open c_GetIndFA(l_WIInstanceID);

  LOOP

    Fetch c_GetIndFA into l_FAInstanceID, l_FAID, l_Priority;
     EXIT when c_GetIndFA%NOTFOUND;

      l_Counter := l_Counter + 1;

        select to_char(XDP_WF_ITEMKEY_S.NEXTVAL) into l_tempKey from dual;
        l_tempKey := to_char(l_OrderID) || '-WI-' || to_char(l_WIInstanceID) || '-INDFA-' || l_tempKey;

        t_ChildTypes(l_Counter) := 'XDPPROV';
        t_ChildKeys(l_Counter) := l_tempKey;

-- Create Process and Bulk Set Item Attribute
	  XDPCORE.CreateAndAddAttrNum(itemtype => t_ChildTypes(l_Counter),
			      itemkey => t_ChildKeys(l_Counter),
			      processname => 'INDEPENDENT_FA_PROCESS',
			      parentitemtype => LaunchFAProcess.itemtype,
			      parentitemkey => LaunchFAProcess.itemkey,
			      OrderID => l_OrderID,
			      LineitemID => l_LineItemID,
			      WIInstanceID => l_WIInstanceID,
			      FAInstanceID => l_FAInstanceID);


        XDPCORE.CheckNAddItemAttrText (itemtype => t_ChildTypes(l_Counter),
                                       itemkey => t_ChildKeys(l_Counter),
                                       AttrName => 'FA_PRIORITY',
                                       AttrValue => to_char(l_Priority),
                                       ErrCode => l_ErrCode,
                                       ErrStr => l_ErrStr);

        if l_ErrCode <> 0 then
          x_progress := 'XDPCORE_FA.LaunchFAProcess. Error when adding item attribute FA_PRIORITY. Order ID: ' || l_OrderID || ' Workitem Instance ID: ' || l_WIInstanceID || ' Line Item ID: ' || l_LineItemID;

          raise e_AddAttributeException;
        end if;


        XDPCORE.CheckNAddItemAttrNumber (itemtype => t_ChildTypes(l_Counter),
                                         itemkey => t_ChildKeys(l_Counter),
                                         AttrName => 'CURRENT_FA_SEQUENCE',
                                         AttrValue => 0,
                                         ErrCode => l_ErrCode,
                                         ErrStr => l_ErrStr);

        if l_ErrCode <> 0 then
          x_progress := 'XDPCORE_FA.LaunchFAProcess. Error when adding item attribute CURRENT_FA_SEQUENCE. Order ID: ' || l_OrderID || ' Workitem Instance ID: ' || l_WIInstanceID || ' Line Item ID: ' || l_LineItemID;

          raise e_AddAttributeException;
        end if;

  END LOOP;

  close c_GetIndFA;

  /* Now Create the processes for ONE Dependent FA process */

  if c_GetDepFA%ISOPEN then
     close c_GetDepFA;
  end if;

  open c_GetDepFA(l_WIInstanceID);
  Fetch c_GetDepFA into l_FAInstanceID, l_FAID, l_Priority;

   if c_GetDepFA%FOUND then
      l_Counter := l_Counter + 1;

        select to_char(XDP_WF_ITEMKEY_S.NEXTVAL) into l_tempKey from dual;
        l_tempKey := to_char(l_OrderID) || '-WI-' || to_char(l_WIInstanceID) || '-DEPFA-' || l_tempKey;

        t_ChildTypes(l_Counter) := 'XDPPROV';
        t_ChildKeys(l_Counter) := l_tempKey;


-- Create Process and Bulk Set Item Attribute
	  XDPCORE.CreateAndAddAttrNum(itemtype => t_ChildTypes(l_Counter),
			      itemkey => t_ChildKeys(l_Counter),
			      processname => 'DEPENDENT_FA_PROCESS',
			      parentitemtype => LaunchFAProcess.itemtype,
			      parentitemkey => LaunchFAProcess.itemkey,
			      OrderID => l_OrderID,
			      LineitemID => l_LineItemID,
			      WIInstanceID => l_WIInstanceID,
			      FAInstanceID => l_FAInstanceID);


        XDPCORE.CheckNAddItemAttrText (itemtype => t_ChildTypes(l_Counter),
                                       itemkey => t_ChildKeys(l_Counter),
                                       AttrName => 'FA_PRIORITY',
                                       AttrValue => to_char(l_Priority),
                                       ErrCode => l_ErrCode,
                                       ErrStr => l_ErrStr);

        if l_ErrCode <> 0 then
          x_progress := 'XDPCORE_FA.LaunchFAProcess. Error when adding item attribute FA_PRIORITY. Order ID: ' || l_OrderID || ' Workitem Instance ID: ' || l_WIInstanceID || ' Line Item ID: ' || l_LineItemID;

          raise e_AddAttributeException;
        end if;


        XDPCORE.CheckNAddItemAttrNumber (itemtype => t_ChildTypes(l_Counter),
                                         itemkey => t_ChildKeys(l_Counter),
                                         AttrName => 'CURRENT_FA_SEQUENCE',
                                         AttrValue => 0,
                                         ErrCode => l_ErrCode,
                                         ErrStr => l_ErrStr);

        if l_ErrCode <> 0 then
          x_progress := 'XDPCORE_FA.LaunchFAProcess. Error when adding item attribute CURRENT_FA_SEQUENCE. Order ID: ' || l_OrderID || ' Workitem Instance ID: ' || l_WIInstanceID || ' Line Item ID: ' || l_LineItemID;

          raise e_AddAttributeException;
        end if;

   end if;

  if l_Counter = 0 then
    x_Progress := 'XDPCORE_FA.LaunchFAProcess. No FA''s found to be processed for Order: ' || l_OrderID || ' WorkitemInstanceID: ' || l_WIInstanceID;
    RAISE e_NoFAsFoundException;
  end if;

   /* Launch all the WOrkflows */
   FOR i in 1..l_Counter LOOP
       wf_engine.StartProcess(t_ChildTypes(i),
                              t_ChildKeys(i));
   END LOOP;


exception
when e_AddAttributeException then
  if c_GetIndFA%ISOPEN then
     close c_GetIndFA;
  end if;

  if c_GetDepFA%ISOPEN then
     close c_GetDepFA;
  end if;

 wf_core.context('XDPCORE_FA', 'LaunchFAProcess', itemtype, itemkey, null, x_Progress);
  raise;

when e_NoFAsFoundException then
  if c_GetIndFA%ISOPEN then
     close c_GetIndFA;
  end if;

  if c_GetDepFA%ISOPEN then
     close c_GetDepFA;
  end if;

 wf_core.context('XDPCORE_FA', 'LaunchFAProcess', itemtype, itemkey, null, x_Progress);
  raise;

when others then
  if c_GetIndFA%ISOPEN then
     close c_GetIndFA;
  end if;

  if c_GetDepFA%ISOPEN then
     close c_GetDepFA;
  end if;

   x_Progress := 'XDPCORE_FA.LaunchFAProcess. Unhandled Exception: ' || SUBSTR(SQLERRM, 1,1500);
 wf_core.context('XDPCORE_FA', 'LaunchFAProcess', itemtype, itemkey, null, x_Progress);
  raise;
end LaunchFAProcess;




Procedure LaunchFAProcessSeq (itemtype in varchar2,
                           itemkey in varchar2)

is

 l_Counter number;
 l_tempKey varchar2(240);
 l_CurrentFASeq number;
 l_PrevFASeq number;
 l_WIInstanceID number;
 l_FAID number;
 l_FAInstanceID number;
 l_OrderID number;
 l_priority number;
 l_ErrCode number;
 l_ErrDescription varchar2(1996);

 cursor c_FAList (wi_id number, prov_seq  number) is
  select FULFILLMENT_ACTION_ID, FA_INSTANCE_ID, PROVISIONING_SEQUENCE, PRIORITY
  from XDP_FA_RUNTIME_LIST
  where WORKITEM_INSTANCE_ID = wi_id
    and PROVISIONING_SEQUENCE = (
                                select MIN(PROVISIONING_SEQUENCE)
                                from XDP_FA_RUNTIME_LIST
                                where WORKITEM_INSTANCE_ID = wi_id
                                  and PROVISIONING_SEQUENCE > prov_seq);

TYPE t_ChildKeyTable is table of varchar2(240) INDEX BY BINARY_INTEGER;
t_ChildKeys t_ChildKeyTable;

TYPE t_ChildTypeTable is table of varchar2(10) INDEX BY BINARY_INTEGER;
t_ChildTypes t_ChildTypeTable;

TYPE t_IdTable is table of number INDEX BY BINARY_INTEGER;
t_FaIDList t_IdTable;
t_PriorityList t_IdTable;

 e_NoFAsFoundException exception;
 e_AddFAtoQException exception;
 e_AddAttributeException exception;
 e_CreateFAProcessException exception;

 x_Progress                     VARCHAR2(2000);


begin

 l_Counter := 0;

 l_OrderID := WF_engine.GetItemAttrNumber(itemtype => LaunchFAProcessSeq.itemtype,
                                          itemkey => LaunchFAProcessSeq.itemkey,
                                          aname => 'ORDER_ID');

 l_WIInstanceID := WF_engine.GetItemAttrNumber(itemtype => LaunchFAProcessSeq.itemtype,
                                               itemkey => LaunchFAProcessSeq.itemkey,
                                               aname => 'WORKITEM_INSTANCE_ID');


 l_PrevFASeq := wf_engine.GetItemAttrNumber(itemtype => LaunchFAProcessSeq.itemtype,
                                               itemkey => LaunchFAProcessSeq.itemkey,
                                               aname => 'CURRENT_FA_SEQUENCE');

 if c_FAList%ISOPEN then
    close c_FAList ;
 end if;

 open c_FAList(l_WIInstanceID, l_PrevFASeq);

 LOOP
      Fetch c_FAList into l_FAID, l_FAInstanceID, l_CurrentFASeq, l_Priority;

      EXIT when c_FAList%NOTFOUND;

      l_Counter := l_Counter + 1;

         CreateFAProcess(itemtype, itemkey, l_FAInstanceID, l_WIInstanceID,
                         l_OrderID, 'INTERNAL','WAITFORFLOW-FA-DEP',
                         t_ChildTypes(l_Counter), t_childKeys(l_Counter),
                         l_ErrCode, l_ErrDescription);

         if l_ErrCode <> 0 then
            x_Progress := 'XDPCORE_FA.LaunchFAProcessSeq. Error when creating FA Process for Order: ' || l_OrderID || ' WorkitemInstanceID: ' || l_WIInstanceID || ' Error: ' || SUBSTR(l_ErrDescription, 1, 1500);
            RAISE e_CreateFAProcessException;
         end if;

         t_FaIdList(l_Counter) := l_FAInstanceID;
         t_PriorityList(l_Counter) := l_Priority;

  END LOOP;

  if c_FAList%ISOPEN then
    close c_FAList ;
  end if;


  if l_Counter = 0 and l_CurrentFASeq = 0 then
    x_Progress := 'XDPCORE_FA.LaunchFAProcess. No FA''s found to be processed for Order: ' || l_OrderID || ' WorkitemInstanceID: ' || l_WIInstanceID;
    RAISE e_NoFAsFoundException;

  else

        XDPCORE.CheckNAddItemAttrNumber (itemtype => itemtype,
                                         itemkey => itemkey,
                                         AttrName => 'CURRENT_FA_SEQUENCE',
                                         AttrValue => l_CurrentFASeq,
                                         ErrCode => l_ErrCode,
                                         ErrStr => l_ErrDescription);

        if l_ErrCode <> 0 then
          x_progress := 'XDPCORE_FA.LaunchFAProcessSeq. Error when adding item attribute CURRENT_FA_SEQUENCE.';
          raise e_AddAttributeException;
        end if;

/* Update the XDP_FA_RUNTIME_LIST table with the User defined Workitem Item Type and Item Key */

               update XDP_FA_RUNTIME_LIST
                   set WF_ITEM_TYPE = t_ChildTypes(l_Counter),
                       WF_ITEM_KEY = t_childKeys(l_Counter),
                       LAST_UPDATE_DATE = sysdate, LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
                       LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
               where   FA_INSTANCE_ID = l_FAInstanceID;

      FOR i in 1..l_Counter LOOP
           /* Enqueue all the FA's into the FA Queue */

           XDP_AQ_UTILITIES.Add_FA_ToQ ( P_ORDER_ID => l_OrderID,
                                         P_WI_INSTANCE_ID => l_WIInstanceID,
                                         P_FA_INSTANCE_ID => t_FaIdList(i),
                                         P_WF_ITEM_TYPE => t_ChildTypes(i),
                                         P_WF_ITEM_KEY => t_childKeys(i),
                                         P_PRIORITY => t_PriorityList(i),
                                         P_RETURN_CODE => l_ErrCode,
                                         P_ERROR_DESCRIPTION => l_ErrDescription);

           if l_ErrCode <> 0 then
              x_Progress := 'XDPCORE_FA.LaunchFAProcessSeq. Error When Adding FA: ' || t_FaIdList(i) || ' to Queue for Order: ' || l_OrderID || ' WorkitemInstanceID: ' || l_WIInstanceID || '  Error: ' || SUBSTR(l_ErrDescription, 1, 1500);

              RAISE e_AddFAtoQException;
           end if;

      END LOOP;

  end if;


exception
when e_AddAttributeException then
  if c_FAList%ISOPEN then
    close c_FAList ;
  end if;

 wf_core.context('XDPCORE_FA', 'LaunchFAProcessSeq', itemtype, itemkey, null, x_Progress);
  raise;

when e_NoFAsFoundException then
  if c_FAList%ISOPEN then
    close c_FAList ;
  end if;

 wf_core.context('XDPCORE_FA', 'LaunchFAProcessSeq', itemtype, itemkey, null, x_Progress);
  raise;

when e_AddFAtoQException then
  if c_FAList%ISOPEN then
    close c_FAList ;
  end if;

 wf_core.context('XDPCORE_FA', 'LaunchFAProcessSeq', itemtype, itemkey, null, x_Progress);
  raise;

when e_CreateFAProcessException then
  if c_FAList%ISOPEN then
    close c_FAList ;
  end if;

 wf_core.context('XDPCORE_FA', 'LaunchFAProcessSeq', itemtype, itemkey, null, x_Progress);
  raise;

when others then
  if c_FAList%ISOPEN then
    close c_FAList ;
  end if;

   x_Progress := 'XDPCORE_FA.LaunchFAProcessSeq. Unhandled Exception: ' || SUBSTR(SQLERRM, 1,1500);
 wf_core.context('XDPCORE_FA', 'LaunchFAProcessSeq', itemtype, itemkey, null, x_Progress);
  raise;
end LaunchFAProcessSeq;

-- This version of HandOver is used When the HandOver is called from the Adapter
-- The Adapter calls this as part of the Initialization

Procedure HandOverChannel (p_ChannelName in varchar2,
                           p_FeName in varchar2,
                           p_ErrCode OUT NOCOPY number,
                           p_ErrStr OUT NOCOPY varchar2)
is

 cursor c_AdapterJobQueue(p_FeID number, p_ChannelUsageCode varchar2) is
   select ROWID
   from XDP_ADAPTER_JOB_QUEUE
   where FE_ID = p_FeID
     and channel_usage_code = p_ChannelUsageCode
     and SYSTEM_HOLD = 'N'
   order by QUEUED_ON ASC;
   -- order by JOB_ID ASC;

 resource_busy exception;
 pragma exception_init(resource_busy, -00054);

 invalid_rowid exception;
 pragma exception_init(invalid_rowid, -01410);
 l_channellock   BOOLEAN := FALSE ;
 l_channelstatus varchar2(1);

 e_UnhandledException exception;
 e_UpdateAdapterRegException Exception;
 e_HandOverChannelException Exception;

 idarr RowidArrayType;
 arrsize number;
 eligible boolean;

 l_New_itemtype VARCHAR2(8);
 l_New_itemkey   VARCHAR2(240);
 l_rowID        VARCHAR2(80);
 l_FeName       varchar2(80);

 l_ChannelUsageCode VARCHAR2(40);
 l_Counter number := 0;

 l_OrderID number;
 l_WIInstanceID number;
 l_FAInstanceID number;
 i              NUMBER;
 l_FeID       number;
 l_isLockRequired   boolean;

 l_ErrCode number;
 l_ErrStr varchar2(2000);

 l_Status varchar2(1);
 x_Progress                     VARCHAR2(2000);
 x_parameters                     VARCHAR2(4000);

 cursor c_GetFEid is
  select fe_id
    from xdp_fes
  where fulfillment_element_name = p_FeName;

 cursor c_GetUsageCode is
  select USAGE_CODE
    from xdp_adapter_reg
  where channel_name = p_ChannelName;

BEGIN

  p_ErrCode := 0;

-- Get FE ID first..
 for v_GetFeId in c_GetFEid loop
	l_FeID := v_GetFeId.fe_id;
 end loop;

-- Get the Channel Usage Code
 for v_GetUsageCode in c_GetUsageCode loop
	l_ChannelUsageCode := v_GetUsageCode.usage_code;
 end loop;

  -- 11.5.6 On wards
  -- First Release the Lock. as of 11.5.6 the FA Fulfillment process will not
  -- Check for any waiting Adapter Admin Requests. The admin request will be a DBMS
  -- JOB and the job will wait on the Named Channel Lock.
  -- So when the lock is released the dbms_job will acquire the lock and perform the
  -- ADMIN operation.
  -- The actual handover process will try to re-acquire the lock again. If there are
  -- no DBMS Jobs waiting then the channel handover will be performed. Else the hand over
  -- will not be performed.
  --
  --

  -- 11.5.6 On wards
  -- Try to acquire the lock
  --
        -- skilaru 05/16/2002
        -- ER# 2013681 Lock the channel only if it is of application mode PIPE..

        l_isLockRequired := XDP_ADAPTER_CORE_DB.checkLockRequired( HandOverChannel.p_ChannelName );

        IF( l_isLockRequired ) THEN

	  l_Status := XDP_ADAPTER_CORE_DB.ObtainAdapterLock_FA
				  (p_ChannelName => HandOverChannel.p_ChannelName);
        END IF;

	if l_Status = 'N' AND l_isLockRequired then
		-- Could not Acquire Lock. An admin job is being performed.
		-- Just exit.
		return;
        else l_channellock := TRUE ;

	end if;


/* Check if there are any jobs for this particular NE to be Done */

/* First Fetch All the Eligible ROW ID's into a table.
 * Then try to obtain a lock on one of these (select for update with no wait)
 * When u get a lock process it.
 */

 arrsize := 0;

 /* Fetch all the rows */

   OPEN c_AdapterJobQueue(l_FeID, l_ChannelUsageCode);
     LOOP

       FETCH c_AdapterJobQueue into l_rowID;
       EXIT WHEN c_AdapterJobQueue%NOTFOUND;

       arrsize := arrsize + 1;
       idarr(arrsize) := l_rowID;
     END LOOP;

     IF c_AdapterJobQueue%ISOPEN THEN
        close c_AdapterJobQueue;
     END IF;

  /* Got all the rows Process them */
     If arrsize > 0 THEN  -- {

       for i in 1 .. arrsize loop -- {

         /*
          * Try to get a lock on each of the fetched rows. If possible
          * Process them. If you cannot get the lock go to the next row
          */
          BEGIN
             select WF_ITEM_TYPE, WF_ITEM_KEY, ROWID, ORDER_ID, WORKITEM_INSTANCE_ID, FA_INSTANCE_ID
             into l_New_itemtype, l_New_itemkey, l_rowID, l_OrderID, l_WIInstanceID, l_FAInstanceID
             from XDP_ADAPTER_JOB_QUEUE
             where ROWID = idarr(i)
             for update NOWAIT;

             /* Check if the FA Waiting has been CANCELED
              * If so the FA must actually be deleted from the adapter job queue
              */

             if IsFAAborted(l_FAInstanceID) = FALSE then
                eligible := TRUE;
                l_Counter := l_Counter + 1;
                GOTO  l_EndofLoop;
             else
               eligible := FALSE;

               delete from XDP_ADAPTER_JOB_QUEUE
               where ROWID = l_rowid;
             end if;

          EXCEPTION
          WHEN resource_busy or no_data_found THEN
            /* Could not obtain a lock */
            eligible := FALSE;
          WHEN invalid_rowid then
            /* By the time the list of FA's was selected into the array. Some other dqer
             * had obtained a lock and already done the hand over process
             */
            eligible := FALSE;
          WHEN OTHERS THEN
             RAISE;
          END;

      END LOOP; -- }

      <<l_EndofLoop>>
       IF (eligible)  THEN  -- {
         BEGIN

            SAVEPOINT HandOverPoint;

            delete from XDP_ADAPTER_JOB_QUEUE
            where ROWID = l_rowid;

         /* Need to Enqueue in the AQ */

            -- skilaru 05/16/2002 ER# 2013681
            -- If we dont lock the channel then the status of the adapter is
            -- always Running. Dont update to In Use

            IF( l_isLockRequired ) THEN

	      XDP_ADAPTER_CORE_DB.Update_Adapter_Status (
                    p_ChannelName 	=> p_ChannelName,
	            p_Status 	=> XDP_ADAPTER.pv_statusInUse
		    );

            END IF;

            XDP_AQ_UTILITIES.HANDOVER_CHANNEL( p_ChannelName,
                                               p_FeName,
                                               l_New_itemtype,
                                               l_New_itemkey,
                                               'WAIT_IN_FP_QUEUE',
                                               l_OrderID,
                                               l_WIInstanceID,
                                               l_FAInstanceID,
                                               p_ErrCode,
                                               p_ErrStr);


           if p_ErrCode <> 0 then
              x_Progress := 'XDPCORE_FA.HandOverChannel. Exception when handing Over Channel: ' || p_ChannelName
                      || ' for FE: ' || p_FeName || ' to itemtype: ' || l_New_itemtype || ' with itemkey: '
                      || l_New_itemkey || ' Current Order: ' || l_OrderID || ' WIInstanceID: ' || l_WIInstanceID
                      || ' FA InstanceID: ' || l_FAInstanceID || ' Error: ' || SUBSTR(p_ErrStr, 1, 1000);

              RAISE e_HandOverChannelException;
           end if;

         EXCEPTION
         WHEN OTHERS THEN
/** Raja: Added on 05-Oct-1999 **/
              rollback to HandOverPoint;

              x_ErrorID := -1;

		x_parameters := 'PROC_NAME='||'HAND_OVER'||'#XDP#'||
			'CHANNEL_NAME='||p_ChannelName||'#XDP#'||
			'FE_NAME='||p_FeName||'#XDP#'||
			'ERROR_STRING='||substr(x_progress,1,1500)||'#XDP#';


	XDP_ADAPTER_CORE_DB.Update_Adapter_Status (
                p_ChannelName 	=> p_ChannelName,
	        p_Status 	=> XDP_ADAPTER.pv_statusError,
		p_ErrorMsg 	=> 'XDP_INTERNAL_CHANNEL_ERROR',
		p_ErrorMsgParams => x_parameters
		);

              RAISE e_UnhandledException;
         END;

       END IF; -- }
    END IF; -- arrasize -- }
--     ELSE   -- arrasize > 0 {

    if l_Counter = 0 or arrsize = 0 then -- {
     /* No jobs found */

	 BEGIN

	XDP_ADAPTER_CORE_DB.Update_Adapter_Status (
                p_ChannelName 	=> p_ChannelName,
	        p_Status 	=> XDP_ADAPTER.pv_statusRunning
		);


       	  EXCEPTION
       	  WHEN OTHERS THEN
       	  x_Progress := 'XDPCORE_FA.HandOverChannel. Exception when updating the Adapter Registration to be IDLE for Channel: '
       	           || p_ChannelName || ' for FE: ' || l_FeID || ' Current Order: ' || l_OrderID || ' WIInstanceID: '
       	           || l_WIInstanceID || ' FA InstanceID: ' || l_FAInstanceID || ' Error: ' || SUBSTR(SQLERRM,1,500);

       	    RAISE e_UpdateAdapterRegException;
       	  END;

    END IF; -- }

 IF c_AdapterJobQueue%ISOPEN THEN
    Close c_AdapterJobQueue;
 END IF;


 p_ErrCode := 0;
 p_ErrStr := 'No Errors';

-- 11.5.6 On-Wards..
-- Release Lock...

	l_Status := XDP_ADAPTER_CORE_DB.ReleaseAdapterLock
				(p_ChannelName => HandOverChannel.p_ChannelName);

exception
when e_UnhandledException then
     IF c_AdapterJobQueue%ISOPEN THEN
        close c_AdapterJobQueue;
     END IF;
     IF l_channellock THEN
        l_channelstatus  := XDP_ADAPTER_CORE_DB.ReleaseAdapterLock (p_ChannelName => HandOverChannel.p_ChannelName);
     END IF ;

   x_Progress := 'XDPCORE_FA.HandOverChannel. Unhandled Exception: ' || SUBSTR(SQLERRM, 1,1500);
wf_core.context('XDPCORE_FA', 'HandOverChannel', null, null, x_Progress,null);
  raise;

when e_UpdateAdapterRegException then
     IF c_AdapterJobQueue%ISOPEN THEN
        close c_AdapterJobQueue;
     END IF;

     IF l_channellock THEN
        l_channelstatus  := XDP_ADAPTER_CORE_DB.ReleaseAdapterLock (p_ChannelName => HandOverChannel.p_ChannelName);
     END IF ;

wf_core.context('XDPCORE_FA', 'HandOverChannel', null, null, x_Progress,null);
  raise;

when e_HandOverChannelException then
     IF c_AdapterJobQueue%ISOPEN THEN
        close c_AdapterJobQueue;
     END IF;

     IF l_channellock THEN
        l_channelstatus  := XDP_ADAPTER_CORE_DB.ReleaseAdapterLock (p_ChannelName => HandOverChannel.p_ChannelName);
     END IF ;

wf_core.context('XDPCORE_FA', 'HandOverChannel', null, null, x_Progress,null);
  raise;

when others then
     IF c_AdapterJobQueue%ISOPEN THEN
        close c_AdapterJobQueue;
     END IF;

     IF l_channellock THEN
        l_channelstatus  := XDP_ADAPTER_CORE_DB.ReleaseAdapterLock (p_ChannelName => HandOverChannel.p_ChannelName);
     END IF ;

   x_Progress := 'XDPCORE_FA.HandOverChannel. Unhandled Exception: ' || SUBSTR(SQLERRM, 1,1500);
wf_core.context('XDPCORE_FA', 'HandOverChannel', null, null, x_Progress,null);
  raise;
end HandOverChannel;


-- This version of HandOver is used from within the FA Workflow Execution
-- There is a release of the Channel Before any other operations are performed
-- on the channel.

Procedure HandOverChannel (ChannelName in varchar2,
                           FeID in number,
                           ChannelUsageCode in varchar2,
                           Caller in varchar2,
                           ErrCode OUT NOCOPY number,
                           ErrStr OUT NOCOPY varchar2)
is

 cursor c_AdapterJobQueue(p_FeID number, p_ChannelUsageCode varchar2) is
   select ROWID
   from XDP_ADAPTER_JOB_QUEUE
   where FE_ID = p_FeID
     and channel_usage_code = p_ChannelUsageCode
     and SYSTEM_HOLD = 'N'
   order by QUEUED_ON ASC;
   --order by JOB_ID ASC;

 resource_busy exception;
 pragma exception_init(resource_busy, -00054);

 invalid_rowid exception;
 pragma exception_init(invalid_rowid, -01410);

 e_UnhandledException exception;
 e_UpdateAdapterRegException Exception;
 e_HandOverChannelException Exception;

 idarr RowidArrayType;
 arrsize number;
 eligible boolean;
 l_channellock    BOOLEAN := FALSE ;
 l_channelstatus  varchar2(1) ;

 l_New_itemtype VARCHAR2(8);
 l_New_itemkey   VARCHAR2(240);
 l_rowID        VARCHAR2(80);
 l_FeName       varchar2(80);

 l_ChannelUsageCode VARCHAR2(40);
 l_Counter number := 0;

 l_OrderID number;
 l_WIInstanceID number;
 l_FAInstanceID number;
 i              NUMBER;
 l_FeID       number;
 l_isLockRequired   boolean;


 l_ErrCode number;
 l_ErrStr varchar2(2000);

 l_Status varchar2(1);

 x_Progress                     VARCHAR2(2000);
 x_parameters                     VARCHAR2(4000);


BEGIN

  ErrCode := 0;


  -- 11.5.6 On wards
  -- First Release the Lock. as of 11.5.6 the FA Fulfillment process will not
  -- Check for any waiting Adapter Admin Requests. The admin request will be a DBMS
  -- JOB and the job will wait on the Named Channel Lock.
  -- So when the lock is released the dbms_job will acquire the lock and perform the
  -- ADMIN operation.
  -- The actual handover process will try to re-acquire the lock again. If there are
  -- no DBMS Jobs waiting then the channel handover will be performed. Else the hand over
  -- will not be performed.
  --
  --

-- TO DO ERROR HANDLING!!
	l_Status := XDP_ADAPTER_CORE_DB.ReleaseAdapterLock
				(p_ChannelName => HandOverChannel.ChannelName);


  /* This part of the Code is to support the Adapter's hand over process.
  ** The adapter does not have the FE_ID in its context.
  ** If and interactive adapter detects a session lost it may automatically try to
  ** Re connect to the FE. If it successfully reconnects the adapter should do the normal
  ** handover process. As the Adapter does not have the FE ID in its context it passes a 0
  ** to this procedure.
  ** Upon detectinf a 0 the fe_id associated with the channel name is found and the handover
  ** process is carried out.
  */

  if FeID = 0 then
    select fe_id, usage_code
    into l_FeID, l_ChannelUsageCode
    from XDP_ADAPTER_REG
    where channel_name = ChannelName;
  else
    l_FeID := FeID;
    l_ChannelUsageCode := ChannelUsageCode;
  end if;


  -- 11.5.6 On wards
  -- Try to re-acquire the lock
  --
        -- skilaru 05/16/2002
        -- ER# 2013681 Lock the channel only if it is of application mode PIPE..

        l_isLockRequired := XDP_ADAPTER_CORE_DB.checkLockRequired( HandOverChannel.ChannelName );

        IF( l_isLockRequired ) THEN

	  l_Status := XDP_ADAPTER_CORE_DB.ObtainAdapterLock_FA
				(p_ChannelName => HandOverChannel.ChannelName);
        END IF;

	if l_Status = 'N' then
		-- Could not Acquire Lock. An admin job is being performed.
		-- Just exit.
		return;
        else
            l_channellock := TRUE;
	end if;


/* Check if there are any jobs for this particular NE to be Done */

/* First Fetch All the Eligible ROW ID's into a table.
 * Then try to obtain a lock on one of these (select for update with no wait)
 * When u get a lock process it.
 */

 arrsize := 0;

 /* Fetch all the rows */

   OPEN c_AdapterJobQueue(l_FeID, l_ChannelUsageCode);
     LOOP

       FETCH c_AdapterJobQueue into l_rowID;
       EXIT WHEN c_AdapterJobQueue%NOTFOUND;

       arrsize := arrsize + 1;
       idarr(arrsize) := l_rowID;
     END LOOP;

     IF c_AdapterJobQueue%ISOPEN THEN
        close c_AdapterJobQueue;
     END IF;

  /* Got all the rows Process them */
     If arrsize > 0 THEN  -- {

       for i in 1 .. arrsize loop -- {

         /*
          * Try to get a lock on each of the fetched rows. If possible
          * Process them. If you cannot get the lock go to the next row
          */
          BEGIN
             select WF_ITEM_TYPE, WF_ITEM_KEY, ROWID, ORDER_ID, WORKITEM_INSTANCE_ID, FA_INSTANCE_ID
             into l_New_itemtype, l_New_itemkey, l_rowID, l_OrderID, l_WIInstanceID, l_FAInstanceID
             from XDP_ADAPTER_JOB_QUEUE
             where ROWID = idarr(i)
             for update NOWAIT;

             /* Check if the FA Waiting has been CANCELED
              * If so the FA must actually be deleted from the adapter job queue
              */

             if IsFAAborted(l_FAInstanceID) = FALSE then
                eligible := TRUE;
                l_Counter := l_Counter + 1;
                GOTO  l_EndofLoop;
             else
               eligible := FALSE;

               delete from XDP_ADAPTER_JOB_QUEUE
               where ROWID = l_rowid;
             end if;

          EXCEPTION
          WHEN resource_busy or no_data_found THEN
            /* Could not obtain a lock */
            eligible := FALSE;
          WHEN invalid_rowid then
            /* By the time the list of FA's was selected into the array. Some other dqer
             * had obtained a lock and already done the hand over process
             */
            eligible := FALSE;
          WHEN OTHERS THEN
             RAISE;
          END;

      END LOOP; -- }

      <<l_EndofLoop>>
       IF (eligible)  THEN  -- {
         BEGIN

            SAVEPOINT HandOverPoint;

            delete from XDP_ADAPTER_JOB_QUEUE
            where ROWID = l_rowid;

         /* Need to Enqueue in the AQ */

            select FULFILLMENT_ELEMENT_NAME into l_FeName
            from XDP_FES
            where FE_ID = l_FeID;

            if Caller = 'ADMIN' then

              -- skilaru 05/16/2002 ER# 2013681
              -- If we dont lock the channel then the status of the adapter is
              -- always Running. Dont update to In Use

              IF( l_isLockRequired ) THEN

	        XDP_ADAPTER_CORE_DB.Update_Adapter_Status (
                      p_ChannelName 	=> ChannelName,
	              p_Status 	=> XDP_ADAPTER.pv_statusInUse
		      );
              END IF;

            end if;

           XDP_AQ_UTILITIES.HANDOVER_CHANNEL( ChannelName,
                                              l_FeName,
                                              l_New_itemtype,
                                              l_New_itemkey,
                                              'WAIT_IN_FP_QUEUE',
                                              l_OrderID,
                                              l_WIInstanceID,
                                              l_FAInstanceID,
                                              ErrCode,
                                              ErrStr);


           if ErrCode <> 0 then
              x_Progress := 'XDPCORE_FA.HandOverChannel. Exception when handing Over Channel: ' || ChannelName
                      || ' for FE: ' || l_FeID || ' to itemtype: ' || l_New_itemtype || ' with itemkey: '
                      || l_New_itemkey || ' Current Order: ' || l_OrderID || ' WIInstanceID: ' || l_WIInstanceID
                      || ' FA InstanceID: ' || l_FAInstanceID || ' Error: ' || SUBSTR(ErrStr, 1, 1000);

              RAISE e_HandOverChannelException;
           end if;

         EXCEPTION
         WHEN OTHERS THEN
/** Raja: Added on 05-Oct-1999 **/
              rollback to HandOverPoint;

              x_ErrorID := -1;

		x_parameters := 'PROC_NAME='||'HAND_OVER'||'#XDP#'||
			'CHANNEL_NAME='||ChannelName||'#XDP#'||
			'FE_NAME='||l_FeName||'#XDP#'||
			'ERROR_STRING='||substr(x_progress,1,1500)||'#XDP#';


	XDP_ADAPTER_CORE_DB.Update_Adapter_Status (
                p_ChannelName 	=> ChannelName,
	        p_Status 	=> XDP_ADAPTER.pv_statusError,
		p_ErrorMsg 	=> 'XDP_INTERNAL_CHANNEL_ERROR',
		p_ErrorMsgParams => x_parameters
		);

              RAISE e_UnhandledException;
         END;

       END IF; -- }
    END IF; -- arrasize -- }
--     ELSE   -- arrasize > 0 {

    if l_Counter = 0 or arrsize = 0 then -- {
     /* No jobs found */

	 BEGIN

	XDP_ADAPTER_CORE_DB.Update_Adapter_Status (
                p_ChannelName 	=> ChannelName,
	        p_Status 	=> XDP_ADAPTER.pv_statusRunning
		);


       	  EXCEPTION
       	  WHEN OTHERS THEN
       	  x_Progress := 'XDPCORE_FA.HandOverChannel. Exception when updating the Adapter Registration to be IDLE for Channel: '
       	           || ChannelName || ' for FE: ' || l_FeID || ' Current Order: ' || l_OrderID || ' WIInstanceID: '
       	           || l_WIInstanceID || ' FA InstanceID: ' || l_FAInstanceID || ' Error: ' || SUBSTR(SQLERRM,1,500);

       	    RAISE e_UpdateAdapterRegException;
       	  END;

    END IF; -- }

 IF c_AdapterJobQueue%ISOPEN THEN
    Close c_AdapterJobQueue;
 END IF;


 ErrCode := 0;
 ErrStr := 'No Errors';

-- 11.5.6 On-Wards..
-- Release Lock...

	l_Status := XDP_ADAPTER_CORE_DB.ReleaseAdapterLock
				(p_ChannelName => HandOverChannel.ChannelName);

exception
when e_UnhandledException then
     IF c_AdapterJobQueue%ISOPEN THEN
        close c_AdapterJobQueue;
     END IF;

     IF l_channellock THEN
        l_channelstatus := XDP_ADAPTER_CORE_DB.ReleaseAdapterLock(p_ChannelName => HandOverChannel.ChannelName);
     END IF ;

   x_Progress := 'XDPCORE_FA.HandOverChannel. Unhandled Exception: ' || SUBSTR(SQLERRM, 1,1500);
wf_core.context('XDPCORE_FA', 'HandOverChannel', null, null, x_Progress,null);
  raise;

when e_UpdateAdapterRegException then
     IF c_AdapterJobQueue%ISOPEN THEN
        close c_AdapterJobQueue;
     END IF;

     IF l_channellock THEN
        l_channelstatus := XDP_ADAPTER_CORE_DB.ReleaseAdapterLock(p_ChannelName => HandOverChannel.ChannelName);
     END IF ;

wf_core.context('XDPCORE_FA', 'HandOverChannel', null, null, x_Progress,null);
  raise;

when e_HandOverChannelException then
     IF c_AdapterJobQueue%ISOPEN THEN
        close c_AdapterJobQueue;
     END IF;

     IF l_channellock THEN
        l_channelstatus := XDP_ADAPTER_CORE_DB.ReleaseAdapterLock(p_ChannelName => HandOverChannel.ChannelName);
     END IF ;

wf_core.context('XDPCORE_FA', 'HandOverChannel', null, null, x_Progress,null);
  raise;

when others then
     IF c_AdapterJobQueue%ISOPEN THEN
        close c_AdapterJobQueue;
     END IF;

     IF l_channellock THEN
        l_channelstatus := XDP_ADAPTER_CORE_DB.ReleaseAdapterLock(p_ChannelName => HandOverChannel.ChannelName);
     END IF ;

   x_Progress := 'XDPCORE_FA.HandOverChannel. Unhandled Exception: ' || SUBSTR(SQLERRM, 1,1500);
wf_core.context('XDPCORE_FA', 'HandOverChannel', null, null, x_Progress,null);
  raise;
end HandOverChannel;

Procedure FindAdminRequestAndPublish (ChannelName in varchar2,
                                      RequestFound OUT NOCOPY BOOLEAN,
                                      Request OUT NOCOPY varchar2)

is
cursor c_AdapterAdmin(ChannelName varchar2) is
  select REQUEST_ID, REQUEST_TYPE
  from XDP_ADAPTER_ADMIN_REQS
  where CHANNEL_NAME = ChannelName and
        REQUEST_STATUS = 'PENDING' and
        REQUEST_TYPE IN ('SUSPEND', 'DISCONNECT', 'SHUTDOWN') and
        REQUEST_DATE = (
                   select MIN(REQUEST_DATE)
                   from XDP_ADAPTER_ADMIN_REQS
                   where CHANNEL_NAME = ChannelName and
                         REQUEST_STATUS = 'PENDING' and
                         REQUEST_TYPE IN ('SUSPEND', 'DISCONNECT', 'SHUTDOWN') and
                         REQUEST_DATE <= SYSDATE );

 l_RequestID number;
 l_ErrCode number;
 l_dummy number;

 l_ErrDescription varchar2(4000);
 x_Progress                     VARCHAR2(2000);

 e_SendMessageException exception;
begin

  Request := 'FALSE';

 if c_AdapterAdmin%ISOPEN then
    close c_AdapterAdmin;
 end if;


 open c_AdapterAdmin(ChannelName);
 Fetch c_AdapterAdmin into l_RequestID, Request;

 if c_AdapterAdmin%NOTFOUND then
    /* No Jobs Found */
    close c_AdapterAdmin;

    RequestFound := FALSE;
    return;
 else
    if c_AdapterAdmin%FOUND then
     /* Job Found. Publish an Event to Execute the task */
      close c_AdapterAdmin;

      /* Construct The CallbackProcedure */

         XNP_ADAPTER_ADMIN_U.Publish(XNP$REQUEST_TYPE => Request,
                               XNP$REQUEST_ID => to_char(l_RequestID),
                               X_MESSAGE_ID => l_dummy,
                               X_ERROR_CODE => l_ErrCode,
                               X_ERROR_MESSAGE =>l_ErrDescription,
                               P_CONSUMER_LIST => null,
                               P_SENDER_NAME  => null,
                               P_RECIPIENT_LIST => null,
                               P_VERSION   => null,
                               P_REFERENCE_ID => null,
                               P_OPP_REFERENCE_ID => null,
                               P_ORDER_ID   => null,
                               P_WI_INSTANCE_ID  => null,
                               P_FA_INSTANCE_ID=> null);

            if l_ErrCode <> 0 then
               x_progress := 'Error when trying to send ADAPTER_ADMIN Message. Code: ' ||
                              to_char(l_ErrCode) || ' Error String: ' ||
                              substr(l_ErrDescription, 1, 1000);
               Raise e_SendMessageException;
            end if;
      RequestFound := TRUE;
      return;
    end if;
 end if;

exception
when e_SendMessageException then
 if c_AdapterAdmin%ISOPEN then
    close c_AdapterAdmin;
 end if;

   wf_core.context('XDPCORE_FA', 'FindAdminRequestAndPublish', null, null, null, x_progress);
   raise;
when others then
 if c_AdapterAdmin%ISOPEN then
    close c_AdapterAdmin;
 end if;

   x_Progress := 'XDPCORE_FA.FindAdminRequestAndPublish. Unhandled Exception: ' || SUBSTR(SQLERRM, 1,1500);
wf_core.context('XDPCORE_FA', 'FindAdminRequestAndPublish', null, null, x_Progress,null);
  raise;
end FindAdminRequestAndPublish;


Procedure GetWorkitemFAMappingProc(WIInstanceID in number,
				   MappingProcFound OUT NOCOPY varchar2,
				   MappingProc OUT NOCOPY varchar2 )
is
begin
  MappingProcFound := 'N';
  begin
     select XDW.FA_EXEC_MAP_PROC
       into MappingProc
       from XDP_WORKITEMS XDW, XDP_FULFILL_WORKLIST XFW
            where XFW.WORKITEM_INSTANCE_ID = WIInstanceID
            and XDW.FA_EXEC_MAP_PROC is not null
            and XFW.WORKITEM_ID = XDW.WORKITEM_ID;

     MappingProcFound := 'Y';
  exception
  when no_data_found then
     MappingProcFound := 'N';
     MappingProc := NULL;
  when others then
     RAISE ;
  end;
exception
when others then
 raise;
end GetWorkitemFAMappingProc;


Procedure PopulateFAs (WIInstanceID in number)
is
 cursor c_GetFaList (wi_id number) is
  select XWF.FULFILLMENT_ACTION_ID, XWF.PROVISIONING_SEQ
  from  XDP_WI_FA_MAPPING XWF, XDP_FULFILL_WORKLIST XFW
  where XFW.WORKITEM_INSTANCE_ID = wi_id
    and XFW.WORKITEM_ID =  XWF.WORKITEM_ID;

 l_FAInstanceID number;
 l_FAsFound number := 0;
 lv_wi_name varchar2(100);
 lv_message_params varchar2(500);
 e_NoFAsFound exception;
begin

    if c_GetFaList%ISOPEN then
       close c_GetFaList;
    end if;

   /* Populate all the FA's in the FA_RUNTIME_LIST Table */
   For v_GetFaList in c_GetFaList(WIInstanceID) LOOP
     BEGIN
       -- skilaru 04/30/2002 bug # 2349463
       -- modified the call to not pass NULL values and use defaults instead
       l_FAInstanceID :=
        XDP_ENG_UTIL.Add_FA_ToWI ( P_WI_INSTANCE_ID => WIInstanceID,
                                   P_FULFILLMENT_ACTION_ID => v_GetFaList.FULFILLMENT_ACTION_ID,
                                  P_PROVISIONING_SEQ => v_GetFaList.PROVISIONING_SEQ);
     EXCEPTION
       WHEN others THEN
       raise;
     END;
     l_FAsFound := 1;
   END LOOP;

   if l_FAsFound = 0 then
     raise e_NoFAsFound;
   end if;
exception
when others then
 xdpcore.context( 'XDPCORE_FA', 'PopulateFAs', 'WI',WIInstanceID);
 if c_GetFaList%ISOPEN then
    close c_GetFaList;
 end if;
 raise;
end PopulateFAs;

Function GetLocateFEProc (FAInstanceID in number) return varchar2
is

 cursor c_GetLocateFEProc(FaID number) is
  select XFA.FE_ROUTING_PROC
   from XDP_FULFILL_ACTIONS XFA, XDP_FA_RUNTIME_LIST XFL
   where XFL.FA_INSTANCE_ID = FaID
     and XFA.FULFILLMENT_ACTION_ID = XFL.FULFILLMENT_ACTION_ID;

 l_LocateFEProc varchar2(80);

begin
    if c_GetLocateFEProc%ISOPEN then
      close c_GetLocateFEProc;
    end if;

    open c_GetLocateFEProc(FAInstanceID);
    Fetch c_GetLocateFEProc into l_LocateFEProc;

    if c_GetLocateFEProc%NOTFOUND then
	l_LocateFEProc := NULL;
    end if;
    close c_GetLocateFEProc;

    return (l_LocateFEProc);

exception
when others then
 if c_GetLocateFEProc%ISOPEN then
   close c_GetLocateFEProc;
 end if;
 raise;
end GetLocateFEProc;

Function GetFPProc (FAInstanceID in number, FeTypeID in number,
                    FeSwGeneric in varchar2, AdapterType in varchar2)
                   return varchar2
is
 cursor c_GetFP(FaID number, FeTypeID number, FeSWGeneric varchar2, AdapterType varchar2) is
   select XFP.FULFILLMENT_PROC
   from XDP_FA_FULFILLMENT_PROC XFP, XDP_FA_RUNTIME_LIST XFL, XDP_FE_SW_GEN_LOOKUP XFS
   where XFL.FA_INSTANCE_ID = FaID
     and XFP.FULFILLMENT_ACTION_ID = XFL.FULFILLMENT_ACTION_ID
     and XFP.FE_SW_GEN_LOOKUP_ID = XFS.FE_SW_GEN_LOOKUP_ID
     and XFS.FETYPE_ID = FeTypeID
     and XFS.SW_GENERIC = FeSWGeneric
     and XFS.ADAPTER_TYPE = AdapterType;

 l_FaProvProc varchar2(80);
begin

    /* Get the FP Name */
    if c_GetFP%ISOPEN then
       close c_GetFP;
    end if;

    open c_GetFP(FAInstanceID, FeTypeID, FeSwGeneric, AdapterType);

    Fetch c_GetFP into l_FaProvProc;
    if c_GetFP%NOTFOUND then
	l_FaProvProc := NULL;
    end if;

    close c_GetFP;

    return(l_FaProvProc);
exception
when others then
    if c_GetFP%ISOPEN then
       close c_GetFP;
    end if;
    raise;
end GetFPProc;

Procedure IsFEPreDefined(FAInstanceID in number,
			 ConfigError OUT NOCOPY varchar2,
			 FEID OUT NOCOPY number)
is
 cursor c_CheckFeID (FaID number) is
  select NVL(FE_ID, null)
   from XDP_FA_RUNTIME_LIST
   where FA_INSTANCE_ID = FaID;
begin
 ConfigError := 'N';

 if c_CheckFeID%ISOPEN then
    close c_CheckFeID;
 end if;

 open c_CheckFeID(FAInstanceID);
 Fetch c_CheckFeID into FeID;

 if c_CheckFeID%NOTFOUND then
	ConfigError := 'Y';
 end if;


exception
when others then
 if c_CheckFeID%ISOPEN then
    close c_CheckFeID;
 end if;

 raise;
end IsFePreDefined;

Procedure SearchAndLockChannel( p_FEID in number,
			 	p_ChannelUsageCode in varchar2,
				p_CODFlag in varchar2,
				p_AdapterStatus in varchar2,
                         	x_LockedFlag OUT NOCOPY varchar2,
			 	x_ChannelName OUT NOCOPY varchar2)

is

 cursor c_GetChannel(feid number, ChannelUsageCode varchar2,
                     AdapterStatus varchar2) is
  select ROWID, channel_name
  from XDP_ADAPTER_REG
  where FE_ID = feid
    and ADAPTER_STATUS = AdapterStatus
    and USAGE_CODE = ChannelUsageCode
  order by NVL(SEQ_IN_FE, 10);

 cursor c_GetCODChannel(feid number, ChannelUsageCode varchar2,
                     AdapterStatus varchar2, CODFlag varchar2) is
  select ROWID, channel_name
  from XDP_ADAPTER_REG
  where FE_ID = feid
    and ADAPTER_STATUS = AdapterStatus
    and NVL(CONNECT_ON_DEMAND_FLAG, 'N') = CODFlag
    and USAGE_CODE = ChannelUsageCode
  order by NVL(SEQ_IN_FE, 10);

 resource_busy exception;
 pragma exception_init(resource_busy, -00054);

 l_RowID ROWID;
 l_RowIDArray RowidArrayType;

 l_GotChannelFlag varchar2(1) := 'N';
 l_Counter number := 0;

 l_Status varchar2(1) := 'N';
begin

   x_ChannelName := NULL;
   x_LockedFlag := 'N';

   if p_CODFlag = 'N' then
	   FOR v_GetChannel in c_GetChannel(p_FeID, p_ChannelUsageCode,
				p_AdapterStatus) LOOP

                -- skilaru 05/16/2002
                -- ER# 2013681 Lock the channel only if it is of application mode PIPE..

                IF( XDP_ADAPTER_CORE_DB.checkLockRequired( v_GetChannel.channel_name ) ) THEN
	  	  l_Status := XDP_ADAPTER_CORE_DB.ObtainAdapterLock_FA(v_GetChannel.channel_name);
                ELSE
                  -- skilaru 05/16/2002
                  -- IF it is NON-PIPE based channel we dont need a lock at all..
                  -- so mimic as if we acuired a lock..
		  x_LockedFlag := 'Y';
	          x_ChannelName := v_GetChannel.channel_name;
	          return;
                END IF;

		if l_Status = 'Y' then

			x_LockedFlag := 'Y';
			x_ChannelName := v_GetChannel.channel_name;

			if XDP_ADAPTER_CORE_DB.Verify_Adapter (v_GetChannel.channel_name) then
				return;
			else
				-- Release the Lock
        			l_Status  := XDP_ADAPTER_CORE_DB.ReleaseAdapterLock
						(p_ChannelName => v_GetChannel.channel_name);
				x_LockedFlag := 'N';
				x_ChannelName := NULL;
			END IF;
		else
			x_LockedFlag := 'N';
			x_ChannelName := NULL;
			--return;
		end if;

	   END LOOP;

   elsif p_CODFlag = 'Y' then
	   FOR v_GetCODChannel in c_GetCODChannel(p_FeID, p_ChannelUsageCode,
				p_AdapterStatus, p_CODFlag) LOOP

                -- skilaru 05/16/2002
                -- ER# 2013681 Lock the channel only if it is of application mode PIPE..

                IF( XDP_ADAPTER_CORE_DB.checkLockRequired( v_GetCODChannel.channel_name ) ) THEN

		  l_Status := XDP_ADAPTER_CORE_DB.ObtainAdapterLock_FA(v_GetCODChannel.channel_name);
                ELSE
                  -- skilaru 05/16/2002
                  -- IF it is NON-PIPE based channel we dont need a lock at all..
                  -- so mimic as if we acuired a lock..
		  x_LockedFlag := 'Y';
	          x_ChannelName := v_GetCODChannel.channel_name;
	          return;
                END IF;

		if l_Status = 'Y' then

			x_LockedFlag := 'Y';
			x_ChannelName := v_GetCODChannel.channel_name;

			if XDP_ADAPTER_CORE_DB.Verify_Adapter (v_GetCODChannel.channel_name) then
				return;
			else
				-- Release the Lock
        			l_Status  := XDP_ADAPTER_CORE_DB.ReleaseAdapterLock
						(p_ChannelName => v_GetCODChannel.channel_name);
				x_LockedFlag := 'N';
				x_ChannelName := NULL;
			END IF;

		else
			x_LockedFlag := 'N';
			x_ChannelName := NULL;
			--return;
		end if;

	   END LOOP;

   end if;

        x_LockedFlag := 'N';
	x_ChannelName := NULL;

exception
when others then
 if c_GetChannel%ISOPEN then
    close c_GetChannel;
 end if;

     IF x_LockedFlag = 'Y' and x_ChannelName is not null THEN
        l_Status  := XDP_ADAPTER_CORE_DB.ReleaseAdapterLock (p_ChannelName => x_ChannelName);
     END IF ;
 raise;
end SearchAndLockChannel;


Function IsFAAborted(FAInstanceID in number) return boolean

 is
 l_Status boolean := FALSE;
 l_FAState varchar2(40);
 l_WIState varchar2(40);
 l_WIInstanceID number;


 cursor c_GetFAState(p_FAInstanceID number) is
  select status_code ,workitem_instance_id from
  xdp_fa_runtime_list
  where fa_instance_id = p_FAInstanceID
  for update;

 cursor c_GetWIState(p_WIInstanceID number) is
  select status_code from
  XDP_FULFILL_WORKLIST
  where workitem_instance_id  = p_WIInstanceID
  for update;

e_NoFAFoundException exception;
e_NoWIFoundException exception;
begin

 Savepoint GetFAState;

 open c_GetFAState(FAInstanceID);
 Fetch c_GetFAState into l_FAState, l_WIInstanceID;

 if c_GetFAState%NOTFOUND then
   rollback to GetFAState;
   raise e_NoFAFoundException;
 end if;

 close c_GetFAState;

 if l_FAState IN ('CANCELED','ABORTED') then
    l_Status := TRUE;
    rollback to GetFAState;
    return l_Status;
 else
    open c_GetWIState(l_WIInstanceID);
    Fetch c_GetWIState into l_WIState;

    if c_GetWIState%NOTFOUND then
      rollback to GetFAState;
      raise e_NoWIFoundException;
    end if;

    close c_GetWIState;

    if l_WIState IN ('CANCELED','ABORTED') then
       l_Status := TRUE;
       rollback to GetFAState;
       return l_Status;
    end if;

 end if;

  rollback to GetFAState;
  l_Status := FALSE;
  return l_Status;


exception
when others then
  if c_GetWIState%ISOPEN then
     close c_GetWIState;
  end if;
  if c_GetFAState%ISOPEN then
     close c_GetFAState;
  end if;
  rollback to GetFAState;
  raise;
end IsFAAborted;


Function ConnectOnDemand(itemtype in varchar2,
			 itemkey in varchar2) return varchar2
is

 l_ChannelName varchar2(40);
 l_AdapterStatus varchar2(80);
 l_FeName varchar2(80);
 l_ConnectProc varchar2(80);
 l_DisconnectProc varchar2(80);

 l_Status varchar2(1);

 ErrCode number;
 ErrStr varchar2(2000);
 l_ErrCode number;
 l_ErrStr varchar2(2000);
 l_Result varchar2(20);

 x_progress varchar2(2000);
 x_parameters    varchar2(4000);


begin
 BEGIN
 	l_ChannelName := wf_engine.GetItemAttrText(itemtype => ConnectOnDemand.itemtype,
					    itemkey => ConnectOnDemand.itemkey,
					    aname => 'CHANNEL_NAME');

 	l_FeName := wf_engine.GetItemAttrText(itemtype => ConnectOnDemand.itemtype,
				       itemkey => ConnectOnDemand.itemkey,
				       aname => 'FE_NAME');

	ErrStr := ConnectOnDemand(l_channelName,l_ErrCode,l_ErrStr);

	if(l_ErrCode <> 0) THEN
		l_Result := 'FAILURE';
       else
      		l_Result := 'SUCCESS';
       end if;

 EXCEPTION
 WHEN OTHERS THEN
	l_Result := 'FAILURE';
 END;

 if l_Result = 'FAILURE' then
        l_Status  := XDP_ADAPTER_CORE_DB.ReleaseAdapterLock (p_ChannelName => l_ChannelName);
 end if;

 return (l_Result);
end ConnectOnDemand;

Function ConnectOnDemand(
        p_Channel_Name in varchar2,
        x_return_code OUT NOCOPY number,
        x_error_description OUT NOCOPY varchar2
    ) return varchar2
IS

l_Result varchar2(20);
x_progress varchar2(2000);
x_parameters    varchar2(4000);
l_Status varchar2(1) := 'N';
l_Status1 varchar2(4000);

BEGIN
 BEGIN
   -- Need to perform Connect On Demand Feature
	begin
		x_return_code := 0;

		-- Updated sacsharm
		-- Adapter business object API should not be used as it locks/releases lock
		-- does Handover, etc.

		if (XDP_ADAPTER_CORE_DB.Is_Adapter_Implemented (p_ChannelName=>p_Channel_Name)) then

			XDP_ADAPTER_CORE.ProcessControlCommand(p_ChannelName => p_Channel_Name,
						p_Operation => XDP_ADAPTER.pv_opConnect,
						p_Status => l_Status1,
						p_ErrorMessage => x_error_description);

			if l_Status1 <> XDP_ADAPTER_CORE.pv_AdapterResponseSuccess then
				x_return_code := XDP_ADAPTER.pv_retAdapterOpFailed;
			end if;
		END IF;

	exception
	when others then
		x_return_code := SQLCODE;
		x_error_description := SQLERRM;
	end;

    if x_return_code <> 0 then
        x_progress := 'Error when executing connect Error: ' || SUBSTR(x_error_description,1, 1500);
        begin

		x_parameters := 'ERROR_CODE='||to_char(x_return_code)||'#XDP#'||
				'ERROR_DESC='||substr(x_error_description,1,1500)||'#XDP#';

-- Changed sacsharm Use autonomous transaction instead

		XDP_ADAPTER_CORE_DB.Update_Adapter_Status (
	                p_ChannelName 	=> p_Channel_Name,
       		        -- p_Status 	=> XDP_ADAPTER.pv_statusDisconnected,
       		        p_Status 	=> XDP_ADAPTER.pv_statusError,
			p_ErrorMsg 	=> 'INTERNAL_ERROR',
			p_ErrorMsgParams => x_parameters
			);

    	exception
	    when others then
		  x_error_description := SQLERRM;
    	end;
    	l_Result := 'N';
    else
-- Update The Adapter Status to be BUSY

	XDP_ADAPTER_CORE_DB.Update_Adapter_Status (
                p_ChannelName 	=> p_Channel_Name,
	        p_Status 	=> XDP_ADAPTER.pv_statusInUse
		);

        l_Result := 'Y';
    end if;
EXCEPTION
    WHEN OTHERS THEN
        x_return_code := SQLCODE;
        x_error_description := SQLERRM;
	l_Result := 'N';
    END;
    l_Status  := XDP_ADAPTER_CORE_DB.ReleaseAdapterLock (p_ChannelName => p_Channel_Name);
    return (l_Result);
end ConnectOnDemand;


Procedure DisconnectOnDemand(   ChannelName in varchar2,
				FeName in varchar2,
				ErrCode OUT NOCOPY number,
				ErrStr OUT NOCOPY varchar2)
is
 l_ConnectProc varchar2(80);
 l_DisconnectProc varchar2(80);
begin

      XDP_ENGINE.GET_FE_CONNECTIONPROC( FeName,
					l_ConnectProc,
					l_DisconnectProc);

      XDP_UTILITIES.Call_NEConnection_Proc(l_DisConnectProc,
					   FeName,
					   ChannelName,
					   ErrCode,
					   ErrStr);


end DisconnectOnDemand;


Procedure SendAdapterErrorNotif(itemtype in varchar2,
				itemkey in varchar2,
				ChannelName in varchar2,
				FEName in varchar2,
				ErrorDescription in varchar2)
is
 l_item_type varchar2(8);
 l_item_key varchar2(240);

 l_order_id number;
begin

	l_item_type := 'XDPWFSTD' ;
        select to_char(XDP_WF_ITEMKEY_S.NEXTVAL) into l_item_key from dual;

	l_order_id := wf_engine.GetItemAttrNumber(
			itemtype => SendAdapterErrorNotif.itemtype,
			itemkey => SendAdapterErrorNotif.itemkey,
			aname => 'ORDER_ID');

	l_item_key := l_order_id || '-' || ChannelName || l_item_key;


	wf_core.context('XDP_WF_STANDARD',
		'ADAPTER_ERROR',
		l_item_type,
		l_item_key) ;

	wf_engine.createprocess(l_item_type,
		l_item_key,
		'ADAPTER_ERROR_NOTIFICATION') ;

	wf_engine.SetItemAttrText(
		ItemType=>l_item_type,
		ItemKey=>l_item_key,
		aname=>'FE_NAME',
		avalue=>FEName);

	wf_engine.SetItemAttrText(
		ItemType=>l_item_type,
		ItemKey=>l_item_key,
		aname=>'CHANNEL_NAME',
		avalue=>ChannelName);

	wf_engine.SetItemAttrText(
		ItemType=>l_item_type,
		ItemKey=>l_item_key,
		aname=>'DESCRIPTION',
		avalue=>ErrorDescription);

	wf_engine.startprocess(l_item_type,
                         l_item_key ) ;

end SendAdapterErrorNotif;

PROCEDURE UPDATE_FA_STATUS(p_fa_instance_id IN NUMBER,
                           p_status_code    IN VARCHAR2,
                           p_itemtype       IN VARCHAR2,
                           p_itemkey        IN VARCHAR2 ) IS
PRAGMA AUTONOMOUS_TRANSACTION;
x_progress VARCHAR2(2000) ;
BEGIN
      UPDATE xdp_fa_runtime_list
         SET status_code       = p_status_code ,
             wf_item_type      = p_itemtype ,
             wf_item_key       = p_itemkey ,
             last_update_date  = sysdate ,
             last_updated_by   = fnd_global.user_id ,
             last_update_login = fnd_global.login_id
       WHERE fa_instance_id    = p_fa_instance_id ;

COMMIT;

EXCEPTION
     WHEN others THEN
          x_Progress := 'XDPCORE_FA.UPDATE_FA_STATUS. Unhandled Exception: ' || SUBSTR(SQLERRM, 1,1500);
          wf_core.context('XDPCORE_FA', 'UPDATE_FA_STATUS', p_itemtype, p_itemkey, null, x_Progress);
          rollback;
          raise;
END UPDATE_FA_STATUS ;

Function ResolveIndDepFAs (itemtype in varchar2,
                           itemkey in varchar2) return varchar2
is

 l_WIInstanceID number;

 l_IndFound number := 0;
 l_DepFound number := 0;

 cursor c_GetIndFAs (WIInstanceID number) is
   select FA_INSTANCE_ID, FULFILLMENT_ACTION_ID, PRIORITY
   from XDP_FA_RUNTIME_LIST
   where WORKITEM_INSTANCE_ID = WIInstanceID
     and STATUS_CODE               = 'STANDBY'
     and (PROVISIONING_SEQUENCE IS NULL or PROVISIONING_SEQUENCE = 0) ;

 cursor c_GetDepFAs (WIInstanceID number) is
   select FA_INSTANCE_ID, FULFILLMENT_ACTION_ID, PRIORITY
   from XDP_FA_RUNTIME_LIST
   where WORKITEM_INSTANCE_ID = WIInstanceID
     and STATUS_CODE               = 'STANDBY'
     and PROVISIONING_SEQUENCE > 0;

x_progress varchar2(2000);

BEGIN

  l_WIInstanceID := wf_engine.GetItemAttrNumber(itemtype => ResolveIndDepFAs.itemtype,
                                                itemkey => ResolveIndDepFAs.itemkey,
                                                aname => 'WORKITEM_INSTANCE_ID');

 FOR lv_FARec in c_GetIndFAs( l_WIInstanceID ) LOOP
  l_IndFound := 1;
  EXIT;
 END LOOP;

 FOR lv_FARec in c_GetDepFAs( l_WIInstanceID ) LOOP
  l_DepFound := 1;
  EXIT;
 END LOOP;

 if( l_IndFound = 1 AND l_DepFound = 1 ) THEN
   RETURN 'BOTH';
 elsif( l_IndFound = 1) THEN
   RETURN 'INDEPENDENT';
 elsif( l_DepFound = 1 ) THEN
   RETURN 'DEPENDENT';
 end if;


exception
 when others then

 x_Progress := 'XDPCORE_FA.ResolveIndDepFAs. Unhandled Exception: ' || SUBSTR(SQLERRM, 1, 1200);
 wf_core.context('XDPCORE_FA', 'ResolveIndDepFAs', itemtype, itemkey, null, x_Progress);
  raise;
end ResolveIndDepFAs;

Function LaunchAllIndFAs(itemtype in varchar2,
                       itemkey in varchar2) return varchar2
IS
 l_OrderID number;
 l_WIInstanceID number;
 l_LineItemID number;
 l_Counter number := 0;
 l_FAInstanceID number;
 l_FAID number;
 l_Priority number;
 l_FAItemType varchar2(10);
 l_FAItemKey varchar2(240);

 l_result varchar2(1) := 'N';

 l_ErrCode number;
 l_ErrStr varchar2(1996);

 l_tempKey varchar2(240);

 cursor c_GetIndFAs (WIInstanceID number) is
   select FA_INSTANCE_ID, FULFILLMENT_ACTION_ID, PRIORITY
   from XDP_FA_RUNTIME_LIST
   where WORKITEM_INSTANCE_ID = WIInstanceID
     and STATUS_CODE               = 'STANDBY'
     and (PROVISIONING_SEQUENCE IS null or PROVISIONING_SEQUENCE = 0) ;

 TYPE t_ChildKeyTable is table of varchar2(240) INDEX BY BINARY_INTEGER;
 t_ChildKeys t_ChildKeyTable;

 e_NoFAsFoundException exception;
 e_AddAttributeException exception;
 e_CreatFAWFException exception;
 e_AddFAtoQException exception;

 x_Progress                     VARCHAR2(2000);

BEGIN

  l_OrderID := wf_engine.GetItemAttrNumber(itemtype => LaunchAllIndFAs.itemtype,
                                           itemkey => LaunchAllIndFAs.itemkey,
                                           aname => 'ORDER_ID');

  l_WIInstanceID := wf_engine.GetItemAttrNumber(itemtype => LaunchAllIndFAs.itemtype,
                                                itemkey => LaunchAllIndFAs.itemkey,
                                                aname => 'WORKITEM_INSTANCE_ID');

  l_LineItemID := wf_engine.GetItemAttrNumber(itemtype => LaunchAllIndFAs.itemtype,
                                              itemkey => LaunchAllIndFAs.itemkey,
                                              aname => 'LINE_ITEM_ID');


 FOR lv_FARec in c_GetIndFAs( l_WIInstanceID ) LOOP
      l_result := 'Y';
      l_Counter := l_Counter + 1;

      l_FAInstanceID := lv_FARec.FA_INSTANCE_ID;
      l_Priority := lv_FARec.PRIORITY;


      CreateFAProcess('XDPPROV', LaunchAllIndFAs.itemkey, l_FAInstanceID, l_WIInstanceID,
                         l_OrderID, 'INTERNAL','WAITFORFLOW-FA-IND',
                         l_FAItemType, l_FAItemKey,
                         l_ErrCode, l_ErrStr);


    if l_ErrCode <> 0 then
       x_Progress := 'XDPCORE_FA.LaunchAllIndFAs. Error when creating FA Process for Order: '
                || l_OrderID || ' Workitem InstanceID: ' || l_WIInstanceID || ' FAInstanceID: ' || l_FAInstanceID
                || ' Error: ' || SUBSTR(l_ErrStr, 1, 1500);
       RAISE e_CreatFAWFException;
    end if;

/* Update the XDP_FA_RUNTIME_LIST table with the User defined Workitem Item Type and Item Key */

               update XDP_FA_RUNTIME_LIST
                   set WF_ITEM_TYPE = l_FAItemType,
                       WF_ITEM_KEY = l_FAItemKey,
                       LAST_UPDATE_DATE = sysdate, LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
                       LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
               where   FA_INSTANCE_ID = l_FAInstanceID;

           /* Enqueue the FA into the FA Queue */

           XDP_AQ_UTILITIES.Add_FA_ToQ ( P_ORDER_ID => l_OrderID,
                                         P_WI_INSTANCE_ID => l_WIInstanceID,
                                         P_FA_INSTANCE_ID => l_FAInstanceID,
                                         P_WF_ITEM_TYPE => l_FAItemType,
                                         P_WF_ITEM_KEY => l_FAItemKey,
                                         P_PRIORITY => l_Priority,
                                         P_RETURN_CODE => l_ErrCode,
                                         P_ERROR_DESCRIPTION => l_ErrStr);

           if l_ErrCode <> 0 then
              x_Progress := 'XDPCORE_FA.LaunchFAProvisioningProcess. Error when Ading FA to Queue for for Order: '
                      || l_OrderID || ' Workitem InstabceID: ' || l_WIInstanceID || ' FAInstanceID: ' || l_FAInstanceID
                      || ' Error: ' || SUBSTR(l_ErrStr, 1, 1500);

              RAISE e_AddFAtoQException;
           end if;

 END LOOP;

 return l_result;

exception
 when others then
 x_Progress := 'XDPCORE_FA.LaunchAllIndFAs. Unhandled Exception: ' || SUBSTR(SQLERRM, 1, 1200);
 wf_core.context('XDPCORE_FA', 'LaunchAllIndFAs', itemtype, itemkey, null, x_Progress);
  raise;

END LaunchAllIndFAs;

Procedure InitializeDepFAProcess(itemtype in varchar2,
                       itemkey in varchar2)
IS
 l_ErrCode number;
 l_ErrStr varchar2(1996);
 x_progress varchar2(1996);

BEGIN

        XDPCORE.CheckNAddItemAttrNumber (itemtype => 'XDPPROV',
                                         itemkey => InitializeDepFAProcess.itemkey,
                                         AttrName => 'CURRENT_FA_SEQUENCE',
                                         AttrValue => 0,
                                         ErrCode => l_ErrCode,
                                         ErrStr => l_ErrStr);


EXCEPTION
 when others then
 x_Progress := 'XDPCORE_FA.InitializeDepFAProcess. Unhandled Exception: ' || SUBSTR(SQLERRM, 1, 1200);
 wf_core.context('XDPCORE_FA', 'InitializeDepFAProcess', itemtype, itemkey, null, x_Progress);
  raise;

END InitializeDepFAProcess;

Function IsAnyChannelAvailable(itemtype in varchar2,
                            itemkey in varchar2) return varchar2
IS
 x_Progress varchar2(2000);
 l_result varchar2(40);
BEGIN
  -- check whether regular channel is available...
  IF( IsChannelAvailable(itemtype, itemkey, 'N', 'IDLE') = 'Y' ) THEN
    RETURN 'AVAILABLE';
  -- check whether COD channel is available...
  ELSIF ( IsChannelAvailable(itemtype, itemkey, 'Y', 'DISCONNECTED') = 'Y' ) THEN
    RETURN 'ON_DEMAND_AVAILABLE';
  ELSE
    RETURN 'NOT_AVAILABLE';
  END IF;

EXCEPTION
 when others then
 x_Progress := 'XDPCORE_FA.IsAnyChannelAvailable. Unhandled Exception: ' || SUBSTR(SQLERRM, 1, 1200);
 wf_core.context('XDPCORE_FA', 'IsAnyChannelAvailable', itemtype, itemkey, null, x_Progress);
  raise;

END;

Function get_display_name( p_FAInstanceID IN NUMBER) return varchar2
IS
l_display_name varchar2(100);

BEGIN
 SELECT display_name into l_display_name
 FROM xdp_fulfill_actions_vl fas
 WHERE fas.fulfillment_action_id IN ( SELECT lst.fulfillment_action_id
                          FROM xdp_fa_runtime_list lst
                        WHERE  fa_instance_id = p_FAInstanceID );
 return l_display_name;

EXCEPTION
   WHEN others THEN
          wf_core.context('XDPCORE_FA', 'get_display_name', null, null, null,p_FAInstanceID );
 raise;
END get_display_name;

Function IsThresholdExceeded (p_fp_name in varchar2) return varchar2 IS
  lv_error_threshold_str VARCHAR2(40);
  lv_revalidated_flag VARCHAR2(1);
  lv_error_threshold NUMBER;
  lv_error_count NUMBER;
  lv_result VARCHAR2(1) := 'N';

  --Lock the row so that no body else can read it..
  CURSOR cur_error_count IS
  SELECT error_count
    FROM xdp_error_count
   WHERE object_key = p_fp_name
     AND object_type = XDP_UTILITIES.g_fp_object_type FOR UPDATE;

BEGIN

  -- get the threshold..
  IF( fnd_profile.defined( g_xdp_fp_error_threshold) ) THEN
      fnd_profile.get( g_xdp_fp_error_threshold,  lv_error_threshold_str );
  END IF;

  lv_error_threshold := TO_NUMBER( lv_error_threshold_str );

  SAVEPOINT readErrorCount;

  FOR lv_rec IN cur_error_count LOOP
    lv_error_count := lv_rec.error_count;

    IF (lv_error_count > lv_error_threshold) THEN
       lv_result := 'Y';
    END IF;
    -- for code readability sake.. we should always have only one record
    EXIT;
  END LOOP;

  -- rollback to release the lock..
  ROLLBACK TO readErrorCount;

  return lv_result;

EXCEPTION
   WHEN others THEN
     -- rollback to release the lock..
     ROLLBACK TO readErrorCount;
     raise;
END IsThresholdExceeded;


Function ErrorDuringRetry (itemtype in varchar2,
                               itemkey in varchar2) return varchar2
IS

  lv_fp_in_error VARCHAR2(1) := 'N';
  lv_result VARCHAR2(1);
  ErrStr VARCHAR2(2000);
  ErrCode NUMBER;
BEGIN

    BEGIN
      lv_fp_in_error := wf_engine.getItemAttrText( itemtype => ErrorDuringRetry.itemtype,
                                               itemkey => ErrorDuringRetry.itemkey,
                                               aname => g_fp_in_error );
      -- This FAs FP errored out already.. so this is a retry on that error..

    EXCEPTION
      -- If 'FP_IN_ERROR' not defined then this is the first time this FAs FP errored out..
      WHEN others THEN
         -- set the wf attribute..
         XDPCORE.CheckNAddItemAttrText (itemtype => ErrorDuringRetry.itemtype,
                                        itemkey => ErrorDuringRetry.itemkey,
                                        AttrName => g_fp_in_error,
                                        AttrValue => 'Y',
                                        ErrCode => ErrCode,
                                        ErrStr => ErrStr);

    END;

  RETURN lv_fp_in_error;

EXCEPTION
   WHEN others THEN
      wf_core.context('XDPCORE_FA', 'ErrorDuringRetry',  itemtype, itemkey );
   raise;
END ErrorDuringRetry;


Function IsThresholdReached (p_fp_name in varchar2) return varchar2 IS
  lv_error_count NUMBER;
  lv_no_data_found NUMBER := 0;
  lv_error_threshold NUMBER;
  lv_error_threshold_str VARCHAR2(40);
  lv_result VARCHAR2(30);

  --Lock the row so that no body else can read it..
  CURSOR cur_error_count IS
  SELECT error_count
    FROM xdp_error_count
   WHERE object_key = p_fp_name
     AND object_type = XDP_UTILITIES.g_fp_object_type FOR UPDATE;

BEGIN

  -- get the threshold..
  IF( fnd_profile.defined( g_xdp_fp_error_threshold) ) THEN
      fnd_profile.get( g_xdp_fp_error_threshold,  lv_error_threshold_str );
  END IF;

  lv_error_threshold := TO_NUMBER( lv_error_threshold_str );


  FOR lv_rec IN cur_error_count LOOP
    lv_error_count := lv_rec.error_count;
    lv_no_data_found := 1;


    IF lv_error_count = lv_error_threshold THEN
       lv_result := 'THRESHOLD_REACHED';
    ELSIF lv_error_count < lv_error_threshold THEN
       lv_result := 'THRESHOLD_NOT_REACHED';
    ELSIF lv_error_count > lv_error_threshold THEN
       lv_result := 'THRESHOLD_EXCEEDED';
    --If users make the threshold intentionally 0 or NULL then
    --we dont provide the System hold functionality...
    --It works as if we havent introduced this status..
    ELSIF ( lv_error_threshold = 0 ) OR ( lv_error_threshold IS NULL ) THEN
       lv_result := 'THRESHOLD_NOT_REACHED';
    END IF;

    -- we have to update the error count in any case..

    lv_error_count := lv_error_count + 1;

    UPDATE xdp_error_count
       SET error_count = lv_error_count,
           last_updated_by = FND_GLOBAL.USER_ID,
           last_update_date = sysdate,
           last_update_login = FND_GLOBAL.USER_ID
     WHERE CURRENT OF cur_error_count;
    -- for code readability sake.. we should always have only one record
    EXIT;
  END LOOP;


  -- If there is no row for this fp_name then the FP has never gone into error..
  -- So insert the first record with error count 1..
  IF lv_no_data_found = 0 THEN
     INSERT INTO XDP_ERROR_COUNT(
                                 object_type,
                                 object_key,
                                 error_count,
                                 created_by,
                                 creation_date,
                                 last_updated_by,
                                 last_update_date,
                                 last_update_login
                                 )
                              VALUES (
                                 XDP_UTILITIES.g_fp_object_type,
                                 p_fp_name,
                                 1,
                                 FND_GLOBAL.USER_ID,
                                 sysdate,
                                 FND_GLOBAL.USER_ID,
                                 sysdate,
                                 FND_GLOBAL.LOGIN_ID);
    --This is the first error while executing the  FP..
    lv_result := 'THRESHOLD_NOT_REACHED';

  END IF;

  RETURN lv_result;

EXCEPTION
   WHEN others THEN
   raise;
END IsThresholdReached;


Procedure ResetSystemHold (p_fp_name in varchar2) IS
PRAGMA AUTONOMOUS_TRANSACTION;

  lv_error_count NUMBER;
  lv_error_threshold NUMBER;
  lv_error_threshold_str VARCHAR2(40);
  lv_revalidated_flag VARCHAR2(1);

  --Lock the row so that no body else can read it..
  CURSOR cur_error_count IS
  SELECT error_count
    FROM xdp_error_count
   WHERE object_key = p_fp_name
     AND object_type = XDP_UTILITIES.g_fp_object_type FOR UPDATE;

BEGIN
  -- get the threshold..
  IF( fnd_profile.defined( g_xdp_fp_error_threshold) ) THEN
      fnd_profile.get( g_xdp_fp_error_threshold,  lv_error_threshold_str );
  END IF;

  lv_error_threshold := TO_NUMBER( lv_error_threshold_str );


  FOR lv_rec IN cur_error_count LOOP
    lv_error_count := lv_rec.error_count;

    -- on success of any FA first check whether there are any FAs waiting
    -- with System Hold status 'Y' then update them to 'N' so that they
    -- will be picked up in Handover Process..
    IF (lv_error_count > lv_error_threshold) THEN
      -- reset System Hold to 'N' so that adapter will pick it up..
      UPDATE xdp_adapter_job_queue
         SET system_hold = 'N',
             last_updated_by = FND_GLOBAL.USER_ID,
             last_update_date = sysdate,
             last_update_login = FND_GLOBAL.USER_ID
       WHERE fa_instance_id in ( SELECT fa_instance_id
                                   FROM xdp_fa_runtime_list
                                  WHERE proc_name = p_fp_name
                                    AND status_code = XDP_UTILITIES.g_system_hold );
      UPDATE xdp_fa_runtime_list
         SET status_code = XDP_UTILITIES.g_wait_for_resource,
             last_updated_by = FND_GLOBAL.USER_ID,
             last_update_date = sysdate,
             last_update_login = FND_GLOBAL.USER_ID
       WHERE proc_name = p_fp_name
         AND status_code =  XDP_UTILITIES.g_system_hold;
    END IF;

    -- finally set the error count to Zero..
    UPDATE xdp_error_count
    SET error_count = 0,
        last_updated_by = FND_GLOBAL.USER_ID,
        last_update_date = sysdate,
        last_update_login = FND_GLOBAL.USER_ID
    WHERE CURRENT OF cur_error_count;
    -- for code readability sake.. we should always have only one record
    EXIT;
  END LOOP;

  -- commit the autonomous transaction to release the lock..
  COMMIT;

EXCEPTION
   WHEN others THEN
      -- rollback the autonomous transaction to release the lock..
      ROLLBACK;
      raise;
END ResetSystemHold;

-- skilaru 05/29/2002.
-- This procedure has to be in an autonomous transaction
-- in order to avoid dead lock while updating the fa status
-- in the next activity..

Procedure OverrideFE ( p_faInstanceID IN VARCHAR2,
                       p_FEName IN VARCHAR2,
                       resultout OUT NOCOPY varchar2 )
IS PRAGMA AUTONOMOUS_TRANSACTION;

 l_faDispName VARCHAR2(200);
 l_feFound BOOLEAN := FALSE;
 l_messageParams varchar2(2000);
 x_Progress varchar2(2000);

 CURSOR c_getFEID IS
 SELECT fe_id
   FROM XDP_FES
  WHERE fulfillment_element_name = p_FEName;

BEGIN

  FOR lv_rec IN c_getFEID  LOOP
    l_feFound := TRUE;
    UPDATE xdp_fa_runtime_list
       SET fe_id = lv_rec.fe_id
     WHERE fa_instance_id = p_faInstanceID;
    -- commit autonomous transaction..
    COMMIT;
  END LOOP;

  IF NOT l_feFound THEN
    l_faDispName := get_display_name( p_FAInstanceID );
    l_messageParams := 'FA='||l_faDispName|| '#XDP#FE=' || p_FEName ||'#XDP#';

    -- set the business error...
    XDPCORE.error_context( 'FA', p_faInstanceID, 'XDP_USER_ENTERED_INVALID_FE', l_messageParams );
    xdpcore.context('XDPCORE_FA', 'OverrideFE', 'FA', p_faInstanceID);
    resultout := 'COMPLETE:FE_NOT_FOUND';
  END IF;

EXCEPTION
   WHEN others THEN
      raise;
END OverrideFE;



End XDPCORE_FA;

/
