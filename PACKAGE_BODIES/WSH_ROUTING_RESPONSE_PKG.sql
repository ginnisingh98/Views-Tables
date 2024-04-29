--------------------------------------------------------
--  DDL for Package Body WSH_ROUTING_RESPONSE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_ROUTING_RESPONSE_PKG" AS
/* $Header: WSHRESPB.pls 120.0 2005/05/27 05:10:10 appldev noship $ */

--
-- Pre-reqs	: None
--
-- Parameters
--	p_deliveryIdTab - table of delivery_ids to generate routing responses for
--	x_routingRespIdTab - table of routing response Ids
--	x_RetStatus - Return status from this API
--
-- Purpose	: This is a wrapper API that is called by the Delivery
--		  Group API in order to generate routing responses for a
--		  given set of delivery Ids.  This API implements the
--		  following logic:
--		  (1) Validate each delivery.
--		  (2) Create a record in WSH_INBOUND_TXN_HISTORY
--		  (3) Raise a business event for each delivery Id
--		  (4) Log a message to indicate to the user whether the
--		      operation was successful or not.
--
-- Version : 1.0
--
PROCEDURE GenerateRoutingResponse(
	p_deliveryIdTab 	IN  wsh_util_core.id_tab_type,
	x_routingRespIdTab 	OUT NOCOPY wsh_util_core.id_tab_type,
	x_RetStatus  		OUT NOCOPY VARCHAR2) IS
  --
  l_Status	VARCHAR2(10);
  l_TxnId	NUMBER;
  l_RevNum	NUMBER;
  l_RespNum	NUMBER;
  l_numErrors	NUMBER := 0;
  l_numWarnings NUMBER := 0;
  l_DelName 	VARCHAR2(30);
  i		NUMBER;
  l_SuccDels	NUMBER := 0;
  l_debugOn     BOOLEAN;
  l_moduleName  CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.GenerateRoutingResponse';
  --
BEGIN
  --
  l_debugOn := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debugOn IS NULL THEN
     l_debugOn := wsh_debug_sv.is_debug_enabled;
  END IF;
  --
  IF l_debugOn THEN
    wsh_debug_sv.push(l_moduleName);
    wsh_debug_sv.log(l_moduleName, 'p_deliveryIdTab.COUNT', p_deliveryIdTab.COUNT);
  END IF;
  --
  x_RetStatus := WSH_UTIL_CORE.g_RET_STS_SUCCESS;
  --
  -- Now for each delivery, let's generate a notification
  --
  i := p_deliveryIdTab.FIRST;
  --
  WHILE i IS NOT NULL LOOP
   --{
   BEGIN
     --
     IF l_debugOn THEN
       wsh_debug_sv.log(l_moduleName, 'Delivery ID', p_DeliveryIdTab(i));
     END IF;
     --
     -- First validate the delivery
     --
     ValidateDelivery(p_deliveryIdTab(i), l_Status);
     --
     wsh_util_core.api_post_call(p_return_status => l_Status,
				 x_num_warnings  => l_numWarnings,
				 x_num_errors    => l_numErrors);
     --
     l_SuccDels := l_SuccDels + 1;
     --
     -- Delivery is valid, so proceed to create a record
     -- in WSH_INBOUND_TXN_HISTORY
     --
     CreateTxnHistory(p_delId    => p_deliveryIdTab(i),
		      x_TxnId    => l_TxnId,
		      x_RespNum  => l_RespNum,
		      x_DelName  => l_DelName,
	              x_Status   => l_Status);
     --
     wsh_util_core.api_post_call(p_return_status => l_Status,
				 x_num_warnings  => l_numWarnings,
				 x_num_errors    => l_numErrors);
     --
     x_routingRespIdTab(x_routingRespIdTab.COUNT + 1) := l_txnId;
     --
     -- Raise a business event for the delivery
     --
     SendNotification(p_delivId => p_deliveryIdTab(i),
		        p_TxnId    => l_TxnId,
	                p_DelName  => l_DelName,
	                p_RespNum  => l_RespNum,
	                x_RetSts   => l_Status);
     --
     wsh_util_core.api_post_call(p_return_status => l_Status,
				 x_num_warnings  => l_numWarnings,
				 x_num_errors    => l_numErrors);
     --
     IF l_Status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
       FND_MESSAGE.SET_NAME('WSH', 'WSH_ROUTING_RESP_SUCCESS');
       FND_MESSAGE.SET_TOKEN('RESP_NUM', l_RespNum);
       FND_MESSAGE.SET_TOKEN('DELIVERY_NAME',
		WSH_NEW_DELIVERIES_PVT.Get_Name(p_deliveryIdTab(i)));
       WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_SUCCESS,
				 l_moduleName);
     ELSE
       FND_MESSAGE.SET_NAME('WSH', 'WSH_ROUTING_RESP_WARNING');
       FND_MESSAGE.SET_TOKEN('RESP_NUM', l_RespNum);
       FND_MESSAGE.SET_TOKEN('DELIVERY_NAME',
		WSH_NEW_DELIVERIES_PVT.Get_Name(p_deliveryIdTab(i)));
       WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_WARNING,
				 l_moduleName);
     END IF;
     --
     EXCEPTION
       --
       WHEN FND_API.G_EXC_ERROR THEN
         --
         IF l_debugOn THEN
           wsh_debug_sv.logmsg(l_moduleName, 'Expected error ' || SUBSTRB(SQLERRM,1,200));
         END IF;
         --
         FND_MESSAGE.SET_NAME('WSH', 'WSH_ROUTING_RESP_FAILURE');
	 FND_MESSAGE.SET_TOKEN('DELIVERY_NAME',
		WSH_NEW_DELIVERIES_PVT.Get_Name(p_deliveryIdTab(i)));
         WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR,
				 l_moduleName);
	 --

   END;
   --
   i := p_deliveryIdTab.NEXT(i);
   --}
  END LOOP;
  --
  IF l_SuccDels = 0 THEN
    x_RetStatus := WSH_UTIL_CORE.G_RET_STS_ERROR;
  ELSIF l_SuccDels < p_deliveryIdTab.COUNT THEN
    x_RetStatus := WSH_UTIL_CORE.G_RET_STS_WARNING;
  ELSIF l_numWarnings > 0 THEN
    x_RetStatus := WSH_UTIL_CORE.G_RET_STS_WARNING;
  ELSE
    x_RetStatus := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  END IF;
  --
  --WSH_UTIL_CORE.ADD_MESSAGE(x_RetStatus, l_moduleName);
  --
  IF l_debugOn THEN
   wsh_debug_sv.log(l_moduleName, 'x_routingRespIdTab.COUNT', x_routingRespIdTab.COUNT);
   wsh_debug_sv.log(l_moduleName, 'l_numWarnings', l_numWarnings);
   wsh_debug_sv.log(l_moduleName, 'l_SuccDels', l_SuccDels);
   wsh_debug_sv.log(l_moduleName, 'p_deliveryIdTab.COUNT', p_deliveryIdTab.COUNT);
   wsh_debug_sv.log(l_moduleName, '# of messages', FND_MSG_PUB.COUNT_MSG);
   wsh_debug_sv.pop(l_moduleName, x_RetStatus);
  END IF;
  --
  EXCEPTION
   --
   WHEN FND_API.G_EXC_ERROR THEN
     --
     x_RetStatus := WSH_UTIL_CORE.g_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('WSH', 'WSH_ROUTING_RESP_FAILURE');
     WSH_UTIL_CORE.ADD_MESSAGE(x_RetStatus, l_moduleName);
     --
     IF l_debugOn THEN
       wsh_debug_sv.logmsg(l_moduleName, 'Expected error ' || SUBSTRB(SQLERRM,1,200));
       wsh_debug_sv.pop(l_moduleName);
     END IF;
     --
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     --
     x_RetStatus := WSH_UTIL_CORE.g_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('WSH', 'WSH_ROUTING_RESP_FAILURE');
     WSH_UTIL_CORE.ADD_MESSAGE(x_RetStatus, l_moduleName);
     --
     IF l_debugOn THEN
       wsh_debug_sv.logmsg(l_moduleName, 'Unexpected error ' || SUBSTRB(SQLERRM,1,200));
       wsh_debug_sv.pop(l_moduleName);
     END IF;
     --
   WHEN OTHERS THEN
     --
     wsh_util_core.default_handler('WSH_ROUTING_RESPONSE_PKG.GenerateRoutingResponse', l_moduleName);
     --
     x_RetStatus := WSH_UTIL_CORE.g_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('WSH', 'WSH_ROUTING_RESP_FAILURE');
     WSH_UTIL_CORE.ADD_MESSAGE(x_RetStatus, l_moduleName);
     --
     IF l_debugOn THEN
       wsh_debug_sv.logmsg(l_moduleName, 'Unexpected error ' || SUBSTRB(SQLERRM,1,100));
       wsh_debug_sv.pop(l_moduleName);
     END IF;
     --
END GenerateRoutingResponse;


--
-- Pre-reqs	: None
--
-- Parameters
--	p_delivId - delivery ID for which the business event should be raised
--	p_TxnId	  - transaction_id from wsh_inbound_txn_history that serves
--		    as the item key for the business event.
--	p_DelName - Delivery Name
--	p_RespNum - Routing response Number.  This maps to receipt_number from
--		    wsh_inbound_txn_history
--	x_RetSts  - Return status from this API.
--
-- Purpose	: This is a API that raises a business event to trigger
--		  the routing response WF process.  The following logic
--		  is implemented in this API
--		  (1) Determine the from and to roles for the WF item
--		  (2) Set the various item attributes of the WF item
--		  (3) Raise the business event (oracle.apps.fte.inbound.routresp.send)
--
-- Version : 1.0
--
PROCEDURE SendNotification(p_delivId    IN NUMBER,
			   p_TxnId	IN NUMBER,
			   p_DelName	IN VARCHAR2,
			   p_RespNum    IN NUMBER,
                           x_RetSts     OUT NOCOPY VARCHAR2) IS
  --
  l_eventName 		VARCHAR2(50) := g_eventName;
  l_itemType  		VARCHAR2(30) := 'FTERRESP';
  l_itemKey   		VARCHAR2(30);
  l_parameter_list 	wf_parameter_list_t;
  l_orgId     		NUMBER;
  l_FromRole  		VARCHAR2(100);
  l_ToRole		VARCHAR2(100);
  --
  l_debugOn     BOOLEAN;
  l_moduleName  CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.SendNotification';
  --
BEGIN
  --
  l_debugOn := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debugOn IS NULL THEN
     l_debugOn := wsh_debug_sv.is_debug_enabled;
  END IF;
  --
  IF l_debugOn THEN
    wsh_debug_sv.push(l_moduleName);
    wsh_debug_sv.log(l_moduleName, 'p_TxnId', p_TxnId);
    wsh_debug_sv.log(l_moduleName, 'p_RespNum', p_RespNum);
    wsh_debug_sv.log(l_moduleName, 'Delivery Id', p_delivId);
    wsh_debug_sv.log(l_moduleName, 'Delivery Name', p_delName);
    wsh_debug_sv.log(l_moduleName, 'Event Name', l_eventName);
    wsh_debug_sv.log(l_moduleName, 'Item Type', l_itemType);
  END IF;
  --
  x_RetSts := WSH_UTIL_CORE.g_Ret_STS_SUCCESS;
  l_itemKey := p_TxnId;
  fnd_profile.get('ORG_ID', l_orgId);
  --
  -- Determine what the from and to roles are
  --
  l_FromRole := GetFromRole(FND_GLOBAL.USER_ID);
  l_ToRole   := GetToRole(p_delivId);
  --
  IF l_debugOn THEN
   wsh_debug_sv.log(l_moduleName, 'Org ID', l_orgId);
   wsh_debug_sv.log(l_moduleName, 'From Role', l_FromRole);
   wsh_debug_sv.log(l_moduleName, 'To Role', l_ToRole);
  END IF;
  --
  -- Set the item attributes for the FTERRESP workflow item
  --
  WF_EVENT.AddParameterToList (p_name  => 'ORG_ID',
                               p_value => l_orgId,
                               p_parameterlist => l_parameter_list);
  --
  WF_EVENT.AddParameterToList (p_name  => 'USER_ID',
                               p_value => FND_GLOBAL.USER_ID,
                               p_parameterlist => l_parameter_list);
  --
  WF_EVENT.AddParameterToList (p_name  => 'APPLICATION_ID',
                               p_value => FND_GLOBAL.RESP_APPL_ID,
                               p_parameterlist => l_parameter_list);
  --
  WF_EVENT.AddParameterToList (p_name  => 'RESPONSIBILITY_ID',
                               p_value => FND_GLOBAL.RESP_ID,
                               p_parameterlist => l_parameter_list);
  --
  WF_EVENT.AddParameterToList (p_name  => 'FROM_USER',
                               p_value => l_FromRole,
                               p_parameterlist => l_parameter_list);
  --
  WF_EVENT.AddParameterToList(p_name => 'WF_ADMINISTRATOR',
			      p_value => l_FromRole,
			      p_parameterlist => l_parameter_list);
  --
  WF_EVENT.AddParameterToList(p_name => 'TO_USER',
			      p_value => l_ToRole,
			      p_parameterlist => l_parameter_list);
  --
  WF_EVENT.AddParameterToList (p_name  => 'DELIVERY_ID',
                               p_value => p_delivId,
                               p_parameterlist => l_parameter_list);
  --
  WF_EVENT.AddParameterToList(p_name   => 'TRANSACTION_ID',
			      p_value  => p_TxnId,
			      p_parameterlist => l_parameter_list);
  --
  WF_EVENT.AddParameterToList (p_name  => 'ROUT_RESP_NUM',
                               p_value => p_RespNum,
                               p_parameterlist => l_parameter_list);
  --
  IF l_debugOn THEN
    wsh_debug_sv.log(l_moduleName, 'Event Name', l_eventName);
    wsh_debug_sv.log(l_moduleName, 'Item Key', l_itemKey);
    wsh_debug_sv.logmsg(l_moduleName, 'Now Raising business event');
  END IF;
  --
  -- Raise the business event
  --
  wf_event.raise(p_event_name => l_eventName,
                 p_event_key =>  l_itemkey,
                 p_parameters => l_parameter_list
                );
  --
  IF l_debugOn THEN
    wsh_debug_sv.logmsg(l_moduleName, 'After raising business event');
    wsh_debug_sv.pop(l_moduleName);
  END IF;
  --
  EXCEPTION
   --
   WHEN OTHERS THEN
     --
     x_RetSts := WSH_UTIL_CORE.g_Ret_STS_ERROR;
     --
     wsh_util_core.default_handler('WSH_ROUTING_RESPONSE_PKG.SendNotification');
     --
     IF l_debugOn THEN
       wsh_debug_sv.logmsg(l_moduleName, 'Unexpected error ' || SUBSTRB(SQLERRM,1,200));
       wsh_debug_sv.pop(l_moduleName);
     END IF;
     --
     RAISE;
     --
END SendNotification;


--
-- Pre-reqs	: None
--
-- Parameters
--	itemtype - represents the WF item type.  In this case, it is FTERRESP
--	itemKey  - identifies the unique item Key.  In this case, it is the transaction_id
--		   from wsh_inbound_txn_history
--	actid    - Standard WF attribute to represent the activity ID inside the process
--	funcmode - Standard WF attribute representing the function execution mode
--	resultout - Standard WF attribute that represents the return status of this API
--
-- Purpose	: This is a API that is called as part of the actual routing response WF.
--		  This API performs some additional checks prior to actually
--		  firing the notification.  The following logic is implemented in this API
--		  (1) Lock the delivery so no other attribute can be altered.
--		  (2) Validate the delivery again to ensure that it is still a valid one
--		      to generate the routing response.
--		  (3) Determine the various Ids (routing request num, revision number,
--		      pickup and dropoff stop Ids, trip Id) that are reqd for the notification.
--		  (4) If the delivery and trip are not planned, call the respective APIs
--		      to plan them.
--		  (5) If there is an error in any of the above processes, set the notfn.
--		      subject and body of the email that will be sent to the user.
--
-- Version : 1.0
--
PROCEDURE PreNotification(itemtype    IN VARCHAR2,
        		  itemkey     IN VARCHAR2,
        		  actid       IN NUMBER,
        		  funcmode    IN VARCHAR2,
        		  resultout   OUT NOCOPY VARCHAR2) IS
  --
  l_deliveryId	NUMBER;
  l_status	VARCHAR2(10);
  l_orgId	NUMBER;
  l_routreqIdTab WSH_UTIL_CORE.ID_TAB_TYPE;
  l_routreqNum 	VARCHAR2(30);
  l_revNum	NUMBER;
  l_delName     VARCHAR2(30);
  l_pickupStopId NUMBER;
  l_dropoffStopId NUMBER;
  l_TripId	NUMBER;
  l_numWarnings	NUMBER := 0;
  l_numErrors	NUMBER := 0;
  l_msgSubject	VARCHAR2(1000);
  l_msgFailSubject VARCHAR2(1000);
  l_failReason	VARCHAR2(32767);
  l_routrespNum	NUMBER;
  l_performer	VARCHAR2(30);
  l_delIdTab	WSH_UTIL_CORE.ID_TAB_TYPE;
  l_tripIdTab	WSH_UTIL_CORE.ID_TAB_TYPE;
  l_delPlanFlag VARCHAR2(1);
  l_tripPlanFlag VARCHAR2(1);
  l_retStatus	 VARCHAR2(10);
  l_planDelSts	BOOLEAN := TRUE;
  --
  l_debugOn     BOOLEAN;
  l_moduleName  CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.PreNotification';
  --
  -- Get the routing request Ids associated with the delivery
  --
  CURSOR c_RoutReqId(p_delId IN NUMBER) IS
  SELECT DISTINCT routing_req_id
  FROM wsh_delivery_details wdd, wsh_delivery_assignments_v wda
  WHERE wdd.delivery_detail_id = wda.delivery_detail_id
  AND wda.delivery_id = p_delId;
  --
  -- Given a routing request Id, get the routing request number
  --
  CURSOR c_RoutReqNum(p_routreqId IN NUMBER) IS
  SELECT receipt_number
  FROM wsh_inbound_txn_history wth
  WHERE wth.transaction_id = p_routreqId
  AND   wth.transaction_type = 'ROUTING_REQUEST';
  --
  -- Get the pickup stop Id, trip Id
  --
  CURSOR c_GetPickupStopId(p_delId IN NUMBER) IS
  SELECT wdl.pick_up_stop_id, wt.trip_id, wnd.name, wt.planned_flag, wnd.planned_flag
  FROM   wsh_trip_stops wts, wsh_new_deliveries wnd, wsh_delivery_legs wdl, wsh_Trips wt
  WHERE  wnd.delivery_id = p_delId
  and    wnd.delivery_id = wdl.delivery_id
  and    wdl.pick_up_stop_id = wts.stop_id
  and    wnd.initial_pickup_location_id = wts.stop_location_id
  and    wts.trip_id = wt.trip_id;
  --
  -- Get the drop off Stop Id
  --
  CURSOR c_GetDropoffStopId(p_delId IN NUMBER) IS
  SELECT nvl(wts.physical_stop_id,drop_off_stop_id) drop_off_stop_id
  FROM   wsh_trip_stops wts, wsh_new_deliveries wnd, wsh_delivery_legs wdl
  WHERE  wnd.delivery_id = p_delId
  and    wnd.delivery_id = wdl.delivery_id
  and    wdl.drop_off_stop_id = wts.stop_id
  and    wnd.ultimate_dropoff_location_id = wts.stop_location_id;
  --
BEGIN
  --
  l_debugOn := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debugOn IS NULL THEN
     l_debugOn := wsh_debug_sv.is_debug_enabled;
  END IF;
  --
  IF l_debugOn THEN
    wsh_debug_sv.push(l_moduleName);
    wsh_debug_sv.log(l_moduleName, 'itemtype', itemtype);
    wsh_debug_sv.log(l_moduleName, 'itemKey', itemKey);
    wsh_debug_sv.log(l_moduleName, 'actid', actid);
    wsh_debug_sv.log(l_moduleName, 'funcmode', funcmode);
  END IF;
  --
  IF (funcmode = 'RUN') THEN
   --{
   l_deliveryId := WF_ENGINE.GetItemAttrNumber(itemtype, itemkey, 'DELIVERY_ID');
   l_orgId      := WF_ENGINE.GetItemAttrNumber(itemtype, itemKey, 'ORG_ID');
   l_routrespNum := WF_ENGINE.GetItemAttrText(itemtype, itemKey, 'ROUT_RESP_NUM');
   l_performer   := WF_ENGINE.GetItemAttrText(itemtype, itemKey, 'TO_USER');
   --
   -- Check whether the to role is NULL.  If yes, then the WF cannot progress
   --
   IF l_performer IS NULL THEN
    --
    FND_MESSAGE.SET_NAME('FTE', 'FTE_RRESP_NO_PERFORMER');
    WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR, l_moduleName);
    --
   END IF;
   --
   -- Lock the delivery
   --
   IF LockDelivery(l_deliveryId) THEN
    --{
    IF l_debugOn THEN
      wsh_debug_sv.logmsg(l_moduleName, 'Delivery ' || l_deliveryID || ' locked Successfully');
      wsh_debug_sv.log(l_moduleName, 'Org ID', l_orgId);
      wsh_debug_sv.log(l_moduleName, 'Routing response Number', l_routrespNum);
    END IF;
    --
    -- Re-validate the delivery
    --
    ValidateDelivery(l_deliveryId, l_status);
    --
    wsh_util_core.api_post_call(p_return_status => l_Status,
    				x_num_warnings  => l_numWarnings,
				x_num_errors    => l_numErrors,
				p_raise_error_flag => FALSE);
    --
    IF l_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) OR
       l_performer IS NULL THEN
     --
     IF l_debugOn THEN
       wsh_debug_sv.logmsg(l_moduleName, 'Routing response cannot be generated');
       wsh_debug_sv.log(l_moduleName, '# of error messages', FND_MSG_PUB.COUNT_MSG);
     END IF;
     --
     -- Delivery failed validation (or) the to Role is null.
     -- Set the failure notification subject and message body
     --
     FND_MESSAGE.SET_NAME('FTE', 'FTE_RRESP_GEN_FAILED_SUBJ');
     FND_MESSAGE.SET_TOKEN('DELIVERY_NAME', WSH_NEW_DELIVERIES_PVT.Get_Name(l_deliveryId));
     l_msgFailSubject := FND_MESSAGE.GET;
     --
     FND_MESSAGE.SET_NAME('FTE', 'FTE_RRESP_PRE_FAILURE_REASON');
     l_failReason := FND_MESSAGE.GET;
     --
     FOR i IN 1..FND_MSG_PUB.COUNT_MSG LOOP
      --
      l_failReason := l_failReason || FND_GLOBAL.local_chr(10) ||
		      FND_MSG_PUB.GET(p_encoded => FND_API.G_FALSE);
      --
     END LOOP;
     --
     IF l_debugOn THEN
       wsh_debug_sv.log(l_moduleName, 'Failure Message subject', l_msgFailSubject);
       wsh_debug_sv.log(l_moduleName, 'Body', l_failReason);
     END IF;
     --
     WF_ENGINE.SetItemAttrText(itemType, itemKey, 'SUBJECT_FAIL', l_msgFailSubject);
     WF_ENGINE.SetItemAttrText(itemType, itemKey, 'NOTFN_FAILED_BODY', l_failReason);
     resultout := 'F';
     --
    ELSE
      --
      -- Delivery has been locked and has been determined to be valid
      --
      --{
      IF l_debugOn THEN
       wsh_debug_sv.logmsg(l_moduleName, 'Delivery is locked and is valid');
      END IF;
      --
      -- Determine how many routing requests are tied to this delivery
      --
      OPEN c_RoutReqId(l_deliveryId);
      FETCH c_RoutReqId BULK COLLECT INTO l_routReqIdTab;
      --
      IF c_RoutReqId%ROWCOUNT > 1 THEN
        --
        IF l_debugOn THEN
          wsh_debug_sv.log(l_moduleName, '# of routing requests', c_RoutReqId%ROWCOUNT);
	  wsh_debug_sv.log(l_moduleName, 'l_routReqIdTab.COUNT', l_routReqIdTab.COUNT);
        END IF;
        --
        FND_MESSAGE.SET_NAME('FTE', 'FTE_RRESP_MULTIPLE_RREQ');
        FND_MESSAGE.SET_TOKEN('RESP_NUM', l_routrespNum);
        l_msgSubject := FND_MESSAGE.GET;
        --
      END IF;
      --
      CLOSE c_RoutReqId;
      --
      -- Get the routing request number tied to the delivery
      --
      IF l_routReqIdTab.COUNT > 0 THEN
        OPEN c_RoutReqNum(l_routReqIdTab(l_routReqIdTab.FIRST));
        FETCH c_RoutReqNum INTO l_routReqNum;
        CLOSE c_RoutReqNum;
      END IF;
      --
      IF l_debugOn THEN
       wsh_debug_sv.log(l_moduleName, 'Routing Request ID',
		l_routReqIdTab(l_routReqIdTab.FIRST));
       wsh_debug_sv.log(l_ModuleName, 'Routing Request Number', l_routReqNum);
      END IF;
      --
      -- Get the highest routing response revision
      -- and bump it up by 1
      --
      SELECT MAX(revision_number)
      INTO   l_revNum
      FROM   wsh_inbound_txn_history
      WHERE  shipment_header_id = l_deliveryId
      AND    transaction_type = 'ROUTING_RESPONSE'
      AND    status = 'GENERATED';
      --
      l_revNum := NVL(l_revNum, 0) + 1;
      --
      IF l_debugOn THEN
        wsh_debug_sv.log(l_moduleName, 'Revision Number', l_revNum);
      END IF;
      --
      -- Get the pickup and dropoff stop Ids
      --
      OPEN c_GetPickupStopId(l_deliveryId);
      FETCH c_GetPickupStopId INTO l_pickupStopId, l_TripId,
      			l_DelName, l_delPlanFlag, l_tripPlanFlag;
      CLOSE c_GetPickupStopId;
      --
      OPEN c_GetDropoffStopId(l_deliveryId);
      FETCH c_GetDropoffStopId INTO l_dropOffStopId;
      CLOSE c_GetDropoffStopId;
      --
      IF l_debugOn THEN
        wsh_debug_sv.log(l_moduleName, 'Pickup Stop ID', l_pickupStopId);
        wsh_debug_sv.log(l_moduleName, 'Dropoff Stop Id', l_dropoffStopId);
        wsh_debug_sv.log(l_moduleName, 'Trip Id', l_TripId);
        wsh_debug_sv.log(l_moduleName, 'Delivery Name', l_delName);
        wsh_debug_sv.log(l_moduleName, 'Delivery Plan Flag', l_delPlanFlag);
        wsh_debug_sv.log(l_moduleName, 'Trip Plan Flag', l_tripPlanFlag);
      END IF;
      --
      -- Bug 317799 : If delivery/trip is not planned,
      -- go ahead and plan them
      --
      IF NVL(l_delPlanFlag, 'N') NOT IN ('F', 'P') THEN
       --{
       l_delIdTab(l_delIdTab.COUNT + 1) := l_deliveryId;
       WSH_NEW_DELIVERY_ACTIONS.Plan(p_del_rows => l_delIdTab,
       				     x_return_status => l_retStatus);
       --
       wsh_util_core.api_post_call(p_return_status => l_retStatus,
    				x_num_warnings  => l_numWarnings,
				x_num_errors    => l_numErrors,
				p_raise_error_flag => FALSE);
       --
       IF l_retStatus <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
         --{
	 l_planDelSts := FALSE;
	 --
         IF l_debugOn THEN
           wsh_debug_sv.logmsg(l_moduleName, 'Error in Plan Delivery API');
	 END IF;
	 --
         FND_MESSAGE.SET_NAME('FTE', 'FTE_RRESP_GEN_FAILED_SUBJ');
         FND_MESSAGE.SET_TOKEN('DELIVERY_NAME', WSH_NEW_DELIVERIES_PVT.Get_Name(l_deliveryId));
         l_msgFailSubject := FND_MESSAGE.GET;
         FND_MESSAGE.SET_NAME('FTE', 'FTE_RRESP_PRE_FAILURE_REASON');
         l_failReason := FND_MESSAGE.GET;
         --
         FOR i IN 1..FND_MSG_PUB.COUNT_MSG LOOP
          l_failReason := l_failReason || FND_GLOBAL.local_chr(10) ||
 			 FND_MSG_PUB.GET(p_encoded=>FND_API.G_FALSE);
         END LOOP;
         --}
       END IF;
       --}
      END IF;
      --
      IF l_planDelSts AND
	 NVL(l_tripPlanFlag, 'N') NOT IN ('F', 'P') THEN
       --{
       l_tripIdTab(l_tripIdTab.COUNT+1) := l_tripId;
       WSH_TRIPS_ACTIONS.Plan(p_trip_rows => l_tripIdTab,
       			      p_action     => 'PLAN',
       			      x_return_status => l_retStatus);
       --
       wsh_util_core.api_post_call(p_return_status => l_retStatus,
    				x_num_warnings  => l_numWarnings,
				x_num_errors    => l_numErrors,
				p_raise_error_flag => FALSE);
       --
       IF l_retStatus NOT IN (WSH_UTIL_CORE.G_RET_STS_SUCCESS, WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
         --{
	 IF l_debugOn THEN
           wsh_debug_sv.logmsg(l_moduleName, 'Error in TripPlan API');
         END IF;
         --
         FND_MESSAGE.SET_NAME('WSH', 'WSH_TRIP_PLAN_ERROR');
         FND_MESSAGE.SET_TOKEN('TRIP_NAME', WSH_TRIPS_PVT.Get_Name(l_tripId));
         WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_WARNING);
         --}
       END IF;
       --}
      END IF;
      --
      IF l_debugOn THEN
        wsh_debug_sv.log(l_moduleName, 'Message Subject', l_msgSubject);
        wsh_debug_sv.log(l_moduleName, 'Message Fail Subject', l_msgFailSubject);
        wsh_debug_sv.log(l_ModuleName, 'Failure Reason', l_failReason);
        wsh_debug_sv.log(l_moduleName, 'WF_HEADER_ATTR', wf_core.translate('WF_HEADER_ATTR'));
        wsh_debug_sv.log(l_moduleName, 'l_planDelSts', l_planDelSts);
      END IF;
      --
      IF NOT l_planDelSts THEN
       --{
       WF_ENGINE.SetItemAttrText(itemType, itemKey, 'SUBJECT_FAIL', l_msgFailSubject);
       WF_ENGINE.SetItemAttrText(itemType, itemKey, 'NOTFN_FAILED_BODY', l_failReason);
       resultout := 'F';
       --}
      ELSE
       --{
       -- Delivery is tied to only one routing request
       --
       IF l_msgSubject IS NULL THEN
         --
         FND_MESSAGE.SET_NAME('FTE', 'FTE_RRESP_SINGLE_RREQ');
         FND_MESSAGE.SET_TOKEN('RESP_NUM', l_routrespNum);
	 FND_MESSAGE.SET_TOKEN('REQ_NUM', l_routreqNum);
         l_msgSubject := FND_MESSAGE.GET;
         --
       END IF;
       --
       IF l_debugOn THEN
         wsh_debug_sv.logmsg(l_moduleName, 'No failures or errors');
         wsh_debug_sv.log(l_moduleName, 'E-mail Subject', l_msgSubject);
       END IF;
       --
       -- Set the WF item attributes for the routing response OA
       -- region to be rendered
       --
       WF_ENGINE.SetItemAttrText(itemType, itemKey, 'ROUT_REQ_NUM',l_routreqNum);
       WF_ENGINE.SetItemAttrNumber(itemType, itemKey, 'P_STOPID', l_pickupStopId);
       WF_ENGINE.SetItemAttrNumber(itemType, itemKey, 'D_STOPID', l_dropoffStopId);
       WF_ENGINE.SetItemAttrNumber(itemType, itemKey, 'TRIP_ID', l_TripId);
       WF_ENGINE.SetItemAttrText(itemType, itemKey, 'SUBJECT', l_msgSubject);
       WF_ENGINE.SetItemAttrText(itemType, itemKey, 'REVISION_NUM', l_revNum);
       --
       IF nvl(wf_core.translate('WF_HEADER_ATTR'),'N') = 'Y' THEN
        --
        WF_ENGINE.SetItemAttrText(itemType, itemKey, 'DELIVERY_NAME',l_DelName);
        --
       END IF;
       --
       resultout := 'T';
      --}
      END IF;
      --}
    END IF;
    --}
   ELSE
    --
    -- Delivery could not be locked, so set error message
    --
    --{
    IF l_debugOn THEN
       wsh_debug_sv.logmsg(l_moduleName, 'Delivery ' || l_deliveryId || ' not locked');
    END IF;
    --
    FND_MESSAGE.SET_NAME('FTE', 'FTE_RRESP_GEN_FAILED_SUBJ');
    FND_MESSAGE.SET_TOKEN('DELIVERY_NAME', WSH_NEW_DELIVERIES_PVT.Get_Name(l_deliveryId));
    l_msgFailSubject := FND_MESSAGE.GET;
    --
    FND_MESSAGE.SET_NAME('FTE', 'FTE_RRESP_PRE_DEL_LOCKED');
    l_failReason := FND_MESSAGE.GET;
    --
    IF l_debugOn THEN
      wsh_debug_sv.log(l_moduleName, 'Failure Message subject', l_msgFailSubject);
      wsh_debug_sv.log(l_moduleName, 'Body', l_failReason);
    END IF;
    --
    WF_ENGINE.SetItemAttrText(itemType, itemKey, 'SUBJECT_FAIL', l_msgFailSubject);
    WF_ENGINE.SetItemAttrText(itemType, itemKey, 'NOTFN_FAILED_BODY', l_failReason);
    --
    resultout := 'F';
    --}
   END IF;
   --}
  END IF;
  --
  IF (funcmode = 'CANCEL') THEN
   resultout := 'T';
  END IF;
  --
  IF (funcmode = 'TIMEOUT') THEN
   resultout := 'F';
  END IF;
  --
  IF l_debugOn THEN
    wsh_debug_sv.log(l_moduleName, 'resultout', resultout);
    wsh_debug_sv.pop(l_moduleName);
  END IF;
  --
  EXCEPTION
    --
    WHEN OTHERS THEN
     --
     resultout := 'F';
     wf_core.context('WSH_ROUTING_RESPONSE_PKG','PreNotification',
                       itemtype, itemkey,TO_CHAR(actid),funcmode);
     --
     IF l_debugOn THEN
      wsh_debug_sv.logmsg(l_moduleName, 'Unexpected error ' || SUBSTRB(SQLERRM,1,200));
      wsh_debug_sv.log(l_moduleName, 'resultout', resultout);
      wsh_debug_sv.pop(l_moduleName);
     END IF;
     --
END PreNotification;


--
-- Pre-reqs	: None
--
-- Parameters
--	itemtype - represents the WF item type.  In this case, it is FTERRESP
--	itemKey  - identifies the unique item Key.  In this case, it is the transaction_id
--		   from wsh_inbound_txn_history
--	actid    - Standard WF attribute to represent the activity ID inside the process
--	funcmode - Standard WF attribute representing the fuction execution mode.
--	resultout - Standard WF attribute that represents the return status of this API
--
-- Purpose	: This is the API that is called as part of the actual routing response WF.
--	  	  Control would be transferred to this API after the actual notification
--		  has been fired.  This API in turn calls procedure UpdateTxnHistory to
--		  update WSH_NEW_DELIVERIES and WSH_INBOUND_TXN_HISTORY
--
-- Version : 1.0
--
PROCEDURE PostNotification(itemtype    IN VARCHAR2,
        		   itemkey     IN VARCHAR2,
        		   actid       IN NUMBER,
        		   funcmode    IN VARCHAR2,
        		   resultout   OUT NOCOPY VARCHAR2) IS
  --
  l_deliveryId  NUMBER;
  l_TxnId	NUMBER;
  l_RevNum	NUMBER;
  l_RespNum	NUMBER;
  l_Status	VARCHAR2(10);
  v_ErrCount	NUMBER;
  l_failReason	VARCHAR2(2000);
  l_msgFailSubject VARCHAR2(1000);
  --
  l_debugOn     BOOLEAN;
  l_moduleName  CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.PostNotification';
  --
BEGIN
  --
  l_debugOn := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debugOn IS NULL THEN
     l_debugOn := wsh_debug_sv.is_debug_enabled;
  END IF;
  --
  IF l_debugOn THEN
    wsh_debug_sv.push(l_moduleName);
    wsh_debug_sv.log(l_moduleName, 'itemtype', itemtype);
    wsh_debug_sv.log(l_moduleName, 'itemKey', itemKey);
    wsh_debug_sv.log(l_moduleName, 'actid', actid);
    wsh_debug_sv.log(l_moduleName, 'funcmode', funcmode);
  END IF;
  --
  IF (funcmode = 'RUN') THEN
   --
   l_deliveryId := WF_ENGINE.GetItemAttrNumber(itemtype, itemkey, 'DELIVERY_ID');
   l_TxnId      := WF_ENGINE.GetItemAttrText(itemtype, itemkey, 'TRANSACTION_ID');
   l_revNum	:= WF_ENGINE.GetItemAttrText(itemtype, itemKey, 'REVISION_NUM');
   l_respNum	:= WF_ENGINE.GetItemAttrText(itemtype, itemKey, 'ROUT_RESP_NUM');
   --
   IF l_debugOn THEN
     wsh_debug_sv.log(l_moduleName, 'l_deliveryId', l_deliveryId);
     wsh_debug_sv.log(l_moduleName, 'l_TxnId', l_TxnId);
     wsh_debug_sv.log(l_moduleName, 'l_revNum', l_revNum);
     wsh_debug_sv.log(l_moduleName, 'l_respNum', l_respNum);
   END IF;
   --
   -- Call API to perform updates
   --
   UpdateTxnHistory(p_deliveryId => l_deliveryId,
		    p_TxnId      => l_TxnId,
	            p_RevNum     => l_RevNum,
		    x_Status     => l_Status);
   --
   IF l_Status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
      resultout := 'T';
   ELSE
      --
      FND_MESSAGE.SET_NAME('FTE', 'FTE_RRESP_POST_FAILED_SUBJ');
      FND_MESSAGE.SET_TOKEN('DELIVERY_NAME', WSH_NEW_DELIVERIES_PVT.Get_Name(l_deliveryId));
      l_msgFailSubject := FND_MESSAGE.GET;
      --
      FND_MESSAGE.SET_NAME('FTE', 'FTE_RRESP_POST_FAILURE_REASON');
      l_failReason := FND_MESSAGE.GET;
      --
      WF_ENGINE.SetItemAttrText(itemType, itemKey, 'SUBJECT_FAIL', l_msgFailSubject);
      WF_ENGINE.SetItemAttrText(itemType, itemKey, 'NOTFN_FAILED_BODY', l_failReason);
      resultout := 'F';
      --
   END IF;
   --
  END IF;
  --
  IF (funcmode = 'CANCEL') THEN
   resultout := 'T';
  END IF;
  --
  IF (funcmode = 'TIMEOUT') THEN
   resultout := 'F';
  END IF;
  --
  IF l_debugOn THEN
    wsh_debug_sv.log(l_moduleName, 'resultout', resultout);
    wsh_debug_sv.pop(l_moduleName);
  END IF;
  --
  EXCEPTION
    --
    WHEN OTHERS THEN
     --
     resultout := 'F';
     wf_core.context('WSH_ROUTING_RESPONSE_PKG','PostNotification',
                       itemtype, itemkey,TO_CHAR(actid),funcmode);
     --
     IF l_debugOn THEN
       wsh_debug_sv.logmsg(l_moduleName, 'Unexpected error ' || SUBSTRB(SQLERRM,1,100));
       wsh_debug_sv.log(l_moduleName, 'resultout', resultout);
       wsh_debug_sv.pop(l_moduleName);
     END IF;
     --
END PostNotification;


--
-- Pre-reqs	: None
--
-- Parameters
--	p_userId - represents the Apps User Id
--
-- Purpose	: This function is used to determine the sender of the routing
--		  response notification.  Given the Apps User Id, we obtain
--		  the Apps User name and this is used as the From Role of the
--		  WF item.
--
-- Version : 1.0
--
FUNCTION GetFromRole(p_UserId IN NUMBER) RETURN VARCHAR2 IS
  --
  CURSOR c_GetUser is
  SELECT user_name
  FROM fnd_user
  WHERE user_id = p_UserId;
  --
  v_Name 	fnd_user.user_name%TYPE;
  --
  l_debugOn     BOOLEAN;
  l_moduleName  CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.GetFromRole';
  --
BEGIN
  --
  l_debugOn := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debugOn IS NULL THEN
     l_debugOn := wsh_debug_sv.is_debug_enabled;
  END IF;
  --
  IF l_debugOn THEN
    wsh_debug_sv.push(l_moduleName);
    wsh_debug_sv.log(l_moduleName, 'User Id', p_userId);
  END IF;
  --
  OPEN c_GetUser;
  FETCH c_GetUser INTO v_Name;
  --
  IF c_GetUser%NOTFOUND THEN
    v_Name := NULL;
  END IF;
  --
  CLOSE c_GetUser;
  --
  IF l_debugOn THEN
    wsh_Debug_sv.log(l_moduleName, 'v_Name', v_Name);
    wsh_debug_sv.pop(l_moduleName);
  END IF;
  --
  RETURN (v_Name);
  --
  EXCEPTION
   --
   WHEN OTHERS THEN
    --
    v_Name := NULL;
    --
    wsh_util_core.default_handler('WSH_ROUTING_RESPONSE_PKG.GetFromRole');
    IF l_debugOn THEN
      wsh_debug_sv.logmsg(l_moduleName, 'Unexpected error ' || SUBSTRB(SQLERRM, 1, 200));
      wsh_debug_sv.pop(l_moduleName);
    END IF;
    --
    RAISE;
    --
END GetFromRole;


--
-- Pre-reqs	: None
--
-- Parameters
--	p_delivId - represents the delivery Id for which the routing response
--		    is being generated.
--
-- Purpose	: This function is used to determine the recipient of the routing
--		  response notification.  This API assumes that the concurrent
--		  program "Synchronize Local WF tables" has been run to transfer
--		  data from TCA tables to WF tables.
--
--		  The following logic is implemented in this API.
--		  (1) Obtain the vendor Id and pickup location Id for the delivery.
--		  (2) Obtain the party relationship Id from the TCA tables to
--		      the pickup location Id and delivery party Id.
--		  (3) The To Role attribute of the WF item is then set to
--		      'HZ_PARTY:' + party relationship Id.
--
-- Version : 1.0
--
FUNCTION GetToRole(p_delivId IN NUMBER) RETURN VARCHAR2 IS
  --
  CURSOR c_DelInfo IS
  SELECT initial_pickup_location_id, party_id, vendor_id, name -- IB-Phase-2
  FROM wsh_new_deliveries
  WHERE delivery_id = p_delivId;
  --
  CURSOR c_GetShipperPartyRelId(p_locId NUMBER, p_delpartyId NUMBER) IS
  SELECT hrel.party_id, contact_person.party_id, email_record.email_address, hrel.end_date
  FROM   hz_party_sites      hps,
         hz_party_site_uses  hpsu,
         hz_parties          contact_person,
         hz_org_contacts     supplier_contact,
         hz_contact_points   phone_record,
         hz_contact_points   email_record,
         hz_relationships    hrel
  WHERE  hps.party_site_id = hpsu.party_site_id
  AND    hpsu.site_use_type = 'SUPPLIER_SHIP_FROM'
  AND    hrel.subject_id = contact_person.party_id
  AND    hrel.subject_table_name = 'HZ_PARTIES'
  AND    hrel.subject_type = 'PERSON'
  AND    hrel.object_id = hps.party_id
  AND    hrel.object_table_name = 'HZ_PARTIES'
  AND    hrel.object_type = 'ORGANIZATION'
  AND    hrel.relationship_code = 'CONTACT_OF'
  AND    hrel.directional_flag = 'F'
  AND    supplier_contact.party_relationship_id =hrel.relationship_id
  AND    supplier_contact.party_site_id = hps.party_site_id
  AND    phone_record.owner_table_name(+) = 'HZ_PARTIES'
  AND    phone_record.owner_table_id(+) = hrel.party_id
  AND    phone_record.contact_point_type(+) = 'PHONE'
  AND    email_record.owner_table_name = 'HZ_PARTIES'
  AND    email_record.owner_table_id = hrel.party_id
  AND    email_record.contact_point_type = 'EMAIL'
  AND    hps.location_id = p_locId
  AND    hps.party_id  = p_delpartyId;
  --
  CURSOR c_GetWFRole(p_relId NUMBER) IS
  SELECT display_name
  FROM wf_roles
  WHERE name = 'HZ_PARTY:' || p_relId;
  --
  CURSOR c_GetPOUser(p_vendorID NUMBER) IS
  SELECT fu.user_name, fu.email_address
  FROM fnd_user fu, hz_relationships hz
  WHERE hz.subject_id = p_vendorId
  AND  hz.object_id = fu.person_party_id  --IB-phase-2 Vendor Merge
  AND hz.subject_type = 'ORGANIZATION'
  AND hz.object_type = 'PERSON'
  AND hz.relationship_type = 'POS_EMPLOYMENT'
  AND hz.relationship_code = 'EMPLOYER_OF'
  AND hz.subject_table_name = 'HZ_PARTIES'
  AND hz.object_table_name = 'HZ_PARTIES'
  AND hz.status  = 'A'
  AND hz.start_date <= sysdate
  AND hz.end_date >= sysdate;
  --
  CURSOR c_GetTxnId(p_delId NUMBER) IS
  SELECT transaction_id
  FROM   wsh_inbound_txn_history
  WHERE  shipment_header_id = p_delId
  AND    transaction_type = 'ROUTING_RESPONSE'
  ORDER BY revision_number DESC;
  --
  v_LocId	NUMBER;
  v_PartyId	NUMBER;
  v_VendorId	NUMBER;
  v_Name	VARCHAR2(30);
  v_FndUserName	VARCHAR2(30);
  v_relId	NUMBER;
  v_hzPartyId	NUMBER;
  v_DocId	NUMBER;
  v_DocType	VARCHAR2(30);
  v_SupEmail	VARCHAR2(2000);
  v_POEmail	VARCHAR2(2000);
  --
  i		NUMBER;
  l_roleName	VARCHAR2(30) := 'WSH_RRESP_ROLE';
  l_displayName  VARCHAR2(30) := 'WSH_RRESP_ROLE';
  l_UserList	VARCHAR2(32767);
  l_TxnId	NUMBER;
  l_relationship_end_date    DATE; --IB Phase 2
  l_del_name    VARCHAR2(30);
  l_end_date    DATE;
  --
  l_debugOn     BOOLEAN;
  l_moduleName  CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.GetToRole';
  --
BEGIN
  --
  l_debugOn := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debugOn IS NULL THEN
     l_debugOn := wsh_debug_sv.is_debug_enabled;
  END IF;
  --
  IF l_debugOn THEN
    wsh_debug_sv.push(l_moduleName);
    wsh_debug_sv.log(l_moduleName, 'Delivery Id', p_delivId);
  END IF;
  --
  -- Get the transaction Id associated with the delivery
  --
  OPEN c_GetTxnId(p_delivId);
  FETCH c_GetTxnId INTO l_txnId;
  CLOSE c_GetTxnId;
  --
  l_roleName := l_roleName || '-' || l_txnId;
  --
  -- Get the pickup location, party Id and vendor Id for delivery
  --
  OPEN c_DelInfo;
  FETCH c_DelInfo INTO v_LocId, v_PartyId, v_VendorId,l_del_name; --IB Phase 2
  --
  IF c_DelInfo%NOTFOUND THEN
   v_LocId := NULL;
   v_PartyId := NULL;
   v_VendorId := NULL;
  END IF;
  --
  CLOSE c_DelInfo;
  --
  IF l_debugOn THEN
    wsh_debug_sv.log(l_moduleName, 'Pickup Location Id', v_LocId);
    wsh_debug_sv.log(l_moduleName, 'Delivery Party ID', v_PartyId);
    wsh_debug_sv.log(l_moduleName, 'Vendor ID', v_VendorId);
    wsh_debug_sv.log(l_moduleName, 'Role Name', l_roleName);
  END IF;
  --
  -- Get the party relationship Id
  --
  IF v_LocId IS NOT NULL AND
     v_PartyId IS NOT NULL THEN
   --
   OPEN c_GetShipperPartyRelId(v_LocId, v_PartyId);
   FETCH c_GetShipperPartyRelId INTO v_relId, v_hzPartyId, v_SupEmail,l_relationship_end_date; -- IB-Phase-2
   --
   IF c_GetShipperPartyRelId%NOTFOUND THEN
    v_relId := NULL;
    v_hzPartyId := NULL;
    v_SupEmail := NULL;
   END IF;
   --
   CLOSE c_GetShipperPartyRelId;
   --
  END IF;
  --
  IF l_debugOn THEN
    wsh_debug_sv.log(l_moduleName, 'Relationship ID', v_relId);
    wsh_debug_sv.log(l_moduleName, 'Hz Party ID', v_hzPartyId);
    wsh_debug_sv.log(l_moduleName, 'Shipper Email', v_SupEmail);
    wsh_debug_sv.log(l_moduleName, 'Relationship End Date', l_end_date);
  END IF;

  -- { IB-Phase-2
  IF l_relationship_end_date < SYSDATE
  THEN
    FND_MESSAGE.SET_NAME('WSH', 'WSH_SUPP_CONTACT_INACTIVE');
    FND_MESSAGE.SET_TOKEN('DELIVERY_NAME',l_del_name);
    WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR, l_moduleName);
    raise FND_API.G_EXC_ERROR;
  END IF;
  -- } IB-Phase-2

  --
  -- Build the to_role
  --
  IF v_relId IS NOT NULL THEN
   v_Name := 'HZ_PARTY:' || v_relId;
  ELSE
   v_Name := NULL;
  END IF;
  --
  -- Get the email address of the vendor
  --
  IF v_VendorId IS NOT NULL THEN
   --{
   OPEN c_GetPOUser(v_VendorId);
   FETCH c_GetPOUser INTO v_FndUserName, v_POEmail;
   --
   IF c_GetPOUser%NOTFOUND THEN
     v_FndUserName := NULL;
     v_POEmail := NULL;
   END IF;
   --
   CLOSE c_GetPOUser;
   --
   IF l_debugOn THEN
    wsh_debug_sv.log(l_moduleName, 'User Name for Vendor', v_FndUserName);
    wsh_debug_sv.log(l_moduleName, 'Email address', v_POEmail);
   END IF;
   --}
  END IF;
  --
  -- If vendor email address matches the email
  -- address that was uploaded from teh routing request
  -- create a adhoc role and set the to Role attribute
  -- as this adhoc role.
  --
  IF v_POEmail IS NOT NULL AND
     v_SupEmail IS NOT NULL AND
     v_POEmail = v_SupEmail THEN
   --{
   l_UserList := v_Name || ',' || v_FndUserName;
   --
   IF l_debugOn THEN
    wsh_debug_sv.log(l_moduleName, 'User List', l_UserList);
    wsh_debug_sv.log(l_moduleName, 'Email', v_SupEmail);
    wsh_debug_sv.logmsg(l_moduleName, 'Calling WF API');
   END IF;
   --
   -- Create adhoc role
   --
   WF_DIRECTORY.CreateAdHocRole(role_name	 => l_roleName,
			       role_display_name => l_displayName,
			       role_users	 => l_UserList,
 			       email_address     => v_SupEmail,
			       expiration_date	 => g_RoleExpDate);
   --}
  ELSE
   --{
   IF l_debugOn THEN
    wsh_debug_sv.logmsg(l_moduleName, 'Only one user to be notified');
   END IF;
   --
   l_roleName := v_Name;
   --}
  END IF;
  --
  IF l_debugOn THEN
    wsh_Debug_sv.log(l_moduleName, 'v_Name', v_Name);
    wsh_debug_sv.log(l_moduleName, 'l_userList', l_UserList);
    wsh_debug_sv.log(l_moduleName, 'l_roleName', l_roleName);
    wsh_debug_sv.pop(l_moduleName);
  END IF;
  --
  RETURN (l_roleName);
  --
  EXCEPTION
   --
   WHEN FND_API.G_EXC_ERROR THEN
     --
     --
     IF l_debugOn THEN
      wsh_debug_sv.logmsg(l_moduleName,'FND_API.G_EXC_ERROR exception has occured.',
			  wsh_debug_sv.C_EXCEP_LEVEL);
      wsh_debug_sv.pop(l_moduleName,'EXCEPTION:FND_API.G_EXC_ERROR');
     END IF;
     --
     --

   WHEN OTHERS THEN
    --
    l_roleName := NULL;
    --
    wsh_util_core.default_handler('WSH_ROUTING_RESPONSE_PKG.GetToRole', l_moduleName);
    IF l_debugOn THEN
      wsh_debug_sv.logmsg(l_moduleName, 'Unexpected error ' || SUBSTRB(SQLERRM, 1, 200));
      wsh_debug_sv.pop(l_moduleName);
    END IF;
    --
    RAISE;
    --
END GetToRole;


--
-- Pre-reqs	: None
--
-- Parameters
--	p_delId - represents the delivery Id for which the routing response
--		  is being generated.
--	x_TxnId - transaction_id from WSH_INBOUND_TXN_HISTORY
--	x_RespNum - routing response number
-- 	x_DelName - Delivery Name
--	x_Status  - Return status of this API.
--
-- Purpose	: This API is used to create a record in WSH_INBOUND_TXN_HISTORY
--		  to indicate that the routing response WF was triggered successfully.
--
-- Version : 1.0
--
PROCEDURE CreateTxnHistory(p_delId IN NUMBER,
		           x_TxnId  OUT NOCOPY NUMBER,
			   x_RespNum OUT NOCOPY NUMBER,
			   x_DelName OUT NOCOPY VARCHAR2,
		           x_Status OUT NOCOPY VARCHAR2) IS
  --
  l_receiptNum		NUMBER;
  l_txnId 		NUMBER;
  l_txnHistoryRec  	WSH_INBOUND_TXN_HISTORY_PKG.ib_txn_history_rec_type;
  l_Status	   	VARCHAR2(10);
  l_revNum		NUMBER;
  l_numWarnings		NUMBER;
  l_numErrors		NUMBER;
  l_orgId		NUMBER;
  l_vendorId		NUMBER;
  l_delivName		VARCHAR2(30);
  --
  l_debugOn 	BOOLEAN;
  l_moduleName 	CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CreateTxnHistory';
  --
  CURSOR c_DelivData IS
  SELECT name, organization_id, vendor_id
  FROM wsh_new_deliveries
  WHERE delivery_id = p_delId;
  --
  CURSOR c_ResponseNum IS
  SELECT receipt_number
  FROM wsh_inbound_txn_history
  WHERE shipment_header_id = p_delId
  ORDER BY receipt_date DESC;
  --
BEGIN
  --
  l_debugOn := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debugOn IS NULL THEN
     l_debugOn := wsh_debug_sv.is_debug_enabled;
  END IF;
  --
  IF l_debugOn THEN
    wsh_debug_sv.push(l_moduleName);
    wsh_debug_sv.log(l_moduleName, 'Delivery Id', p_delId);
  END IF;
  --
  -- Get the routing response number
  --
  OPEN c_ResponseNum;
  FETCH c_ResponseNum INTO l_receiptNum;
  --
  IF l_debugOn THEN
    wsh_debug_sv.log(l_moduleName, 'c_ResponseNum%ROWCOUNT', c_ResponseNum%ROWCOUNT);
    wsh_debug_sv.log(l_moduleName, 'l_receiptNum', l_receiptNum);
  END IF;
  --
  IF c_ResponseNum%NOTFOUND THEN
   SELECT WSH_ROUTING_RESPONSE_S.nextval INTO l_receiptNum FROM dual;
  END IF;
  --
  CLOSE c_ResponseNum;
  --
  IF l_debugOn THEN
   wsh_debug_sv.log(l_moduleName, 'Receipt Number', l_receiptNum);
  END IF;
  --
  x_Status := WSH_UTIL_CORE.g_RET_STS_SUCCESS;
  --
  -- Obtain the delivery name, org Id and vendor Id
  --
  OPEN c_DelivData;
  FETCH c_DelivData INTO l_delivName, l_orgId, l_vendorId;
  CLOSE c_DelivData;
  --
  IF l_debugOn THEN
    wsh_debug_sv.log(l_moduleName, 'Delivery name', l_delivName);
    wsh_debug_sv.log(l_moduleName, 'Org ID', l_orgId);
    wsh_debug_sv.log(l_moduleName, 'Vendor ID', l_vendorId);
  END IF;
  --
  -- Set the values of the WSH_INBOUND_TXN_HISTORY record structure
  --
  l_txnHistoryRec.receipt_number     := l_receiptNum;
  l_txnHistoryRec.revision_number    := NULL;
  l_txnHistoryRec.shipment_number    := l_delivName;
  l_txnHistoryRec.transaction_type   := 'ROUTING_RESPONSE';
  l_txnHistoryRec.shipment_header_id := p_delId;
  l_txnHistoryRec.organization_id    := l_orgId;
  l_txnHistoryRec.supplier_id        := l_vendorId;
  l_txnHistoryRec.receipt_date       := SYSDATE;
  l_txnHistoryRec.status             := 'TRIGGERED';
  --
  IF l_debugOn THEN
   wsh_debug_sv.logmsg(l_moduleName,'** Input record to Create_txn_History **');
   wsh_debug_sv.log(l_moduleName,'Receipt Num',l_txnHistoryRec.receipt_number);
   wsh_debug_sv.log(l_moduleName, 'Rev Num',l_txnHistoryRec.revision_number);
   wsh_debug_sv.log(l_moduleName, 'Shpmt Num',l_txnHistoryRec.shipment_number);
   wsh_debug_sv.log(l_moduleName, 'Txn Type',l_txnHistoryRec.transaction_type);
   wsh_debug_sv.log(l_moduleName, 'Shp Hdr Id',
			l_txnHistoryRec.shipment_header_id);
   wsh_debug_sv.log(l_moduleName, 'Org Id', l_txnHistoryRec.organization_id);
   wsh_debug_sv.log(l_moduleName, 'Supplier Id', l_txnHistoryRec.supplier_id);
   wsh_debug_sv.log(l_moduleName, 'Receipt Date',
		to_char(l_txnHistoryRec.receipt_date,'DD-MON-YYYY HH24:MI:SS'));   wsh_debug_sv.log(l_moduleName, 'Status', l_txnHistoryRec.status);
  END IF;
  --
  -- Call the table handler to create a record
  --
  WSH_INBOUND_TXN_HISTORY_PKG.create_txn_history(p_txn_history_rec => l_txnHistoryRec,
						 x_txn_id          => l_txnId,
						 x_return_status   => l_Status);
  --
  WSH_UTIL_CORE.api_post_call(p_return_status => l_Status,
		              x_num_warnings  => l_numWarnings,
			      x_num_Errors    => l_numErrors);
  --
  x_TxnId   := l_txnId;
  x_RespNum := l_receiptNum;
  x_DelName := l_delivName;
  x_Status  := l_Status;
  --
  IF l_debugOn THEN
    wsh_debug_sv.log(l_moduleName, 'Transaction ID', x_TxnId);
    wsh_debug_sv.log(l_moduleName, 'Delivery Name', x_DelName);
    wsh_debug_sv.log(l_moduleName, 'Routing Resp Number', x_RespNum);
    wsh_debug_sv.pop(l_moduleName);
  END IF;
  --
  EXCEPTION
   --
   WHEN FND_API.G_EXC_ERROR THEN
     --
     x_Status := WSH_UTIL_CORE.G_RET_STS_ERROR;
     --
     IF l_debugOn THEN
       wsh_debug_sv.logmsg(l_moduleName, 'Expected error ' || SUBSTRB(SQLERRM,1,200));
       wsh_debug_sv.pop(l_moduleName);
     END IF;
     --
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     --
     x_Status := WSH_UTIL_CORE.g_RET_STS_UNEXP_ERROR;
     --
     IF l_debugOn THEN
       wsh_debug_sv.logmsg(l_moduleName, 'Unexpected error ' || SUBSTRB(SQLERRM,1,200));
       wsh_debug_sv.pop(l_moduleName);
     END IF;
     --
   WHEN OTHERS THEN
    --
    x_Status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    --
    wsh_util_core.default_handler('WSH_ROUTING_RESPONSE_PKG.CreateTxnHistory', l_moduleName);
    --
    IF l_debugOn THEN
      wsh_debug_sv.logmsg(l_moduleName, 'Unexpected error ' || SUBSTRB(SQLERRM,1,200));
      wsh_debug_sv.log(l_moduleName, 'Transaction ID', x_TxnId);
      wsh_debug_sv.log(l_moduleName, 'Revision Number', l_revNum);
      wsh_debug_sv.pop(l_moduleName);
    END IF;
    --
    RAISE;
    --
END CreateTxnHistory;


--
-- Pre-reqs	: None
--
-- Parameters
--	p_delId - represents the delivery Id for which the routing response
--		  is being generated.
--	p_TxnId - transaction_id from WSH_INBOUND_TXN_HISTORY
--	p_RevNum - routing response revision number
--	x_Status  - Return status of this API.
--
-- Purpose	: This API is used to update the record in WSH_INBOUND_TXN_HISTORY
--		  for this delivery to indicate that the routing response WF
--	          completed successfully.  Also, an update to WSH_NEW_DELIVERIES
--		  is performed to set the routing_response_id.
--
-- Version : 1.0
--
PROCEDURE UpdateTxnHistory(p_deliveryId IN NUMBER,
			   p_TxnId      IN NUMBER,
			   p_RevNum     IN NUMBER,
			   x_Status     OUT NOCOPY VARCHAR2) IS
  --
  l_Status	VARCHAR2(10);
  l_txnHistoryRec WSH_INBOUND_TXN_HISTORY_PKG.ib_txn_history_rec_type;
  l_numWarnings	NUMBER;
  l_numErrors	NUMBER;
  l_Date	DATE := SYSDATE;
  --
  l_debugOn 	BOOLEAN;
  l_moduleName 	CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UpdateTxnHistory';
  --
BEGIN
  --
  l_debugOn := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debugOn IS NULL THEN
     l_debugOn := wsh_debug_sv.is_debug_enabled;
  END IF;
  --
  IF l_debugOn THEN
    wsh_debug_sv.push(l_moduleName);
    wsh_debug_sv.log(l_moduleName, 'Delivery Id', p_deliveryId);
    wsh_debug_sv.log(l_moduleName, 'Transaction ID', p_TxnId);
    wsh_debug_sv.log(l_moduleName, 'Revision Number', p_RevNum);
    wsh_debug_sv.log(l_moduleName, 'l_Date', to_char(l_Date, 'DD/MM/YYYY HH24:MI:SS'));
  END IF;
  --
  -- Update WSH_NEW_DELIVERIES
  --
  UPDATE wsh_new_deliveries
  SET routing_response_id = p_TxnId,
      last_update_date = l_Date
  WHERE delivery_id = p_deliveryId;
  --
  IF l_debugOn THEN
    wsh_debug_sv.logmsg(l_moduleName, 'No. of rows updated', SQL%ROWCOUNT);
  END IF;
  --
  -- Set the inbound txn history record components
  --
  l_txnHistoryRec.status := 'GENERATED';
  l_txnHistoryRec.receipt_date := l_Date;
  l_txnHistoryRec.revision_number := p_revNum;
  l_txnHistoryRec.transaction_id := p_txnId;
  l_txnHistoryRec.shipment_header_id := p_deliveryId;
  --
  IF l_debugOn THEN
   wsh_debug_sv.logmsg(l_moduleName,'** Input record to update_txn_History **');
   wsh_debug_sv.log(l_moduleName, 'Status', l_txnHistoryRec.status);
   wsh_debug_sv.log(l_moduleName, 'Receipt Date',
	to_char(l_txnHistoryRec.receipt_date,'DD-MON-YYYY HH24:MI:SS'));
   wsh_debug_sv.log(l_moduleName, 'Rev Num',l_txnHistoryRec.revision_number);
   wsh_debug_sv.log(l_moduleName, 'Txn ID',l_txnHistoryRec.transaction_id);
   wsh_debug_sv.log(l_moduleName, 'Shp Hdr Id',
			l_txnHistoryRec.shipment_header_id);
  END IF;
  --
  -- Call table handler to update existing record
  --
  WSH_INBOUND_TXN_HISTORY_PKG.update_txn_history(p_txn_history_rec => l_txnHistoryRec,
						 x_return_status   => l_Status);
  --
  wsh_util_core.api_post_call(p_return_status => l_Status,
			      x_num_warnings  => l_numWarnings,
			      x_num_errors    => l_numErrors);
  --
  x_Status := l_Status;
  --
  IF l_debugOn THEN
    wsh_debug_sv.log(l_moduleName, 'Return status after update_Txn_history', l_Status);
    wsh_debug_sv.pop(l_moduleName);
  END IF;
  --
  EXCEPTION
   --
   WHEN FND_API.G_EXC_ERROR THEN
     --
     x_Status := WSH_UTIL_CORE.G_RET_STS_ERROR;
     --
     IF l_debugOn THEN
       wsh_debug_sv.logmsg(l_moduleName, 'Expected error ' || SUBSTRB(SQLERRM,1,200));
       wsh_debug_sv.pop(l_moduleName);
     END IF;
     --
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     --
     x_Status := WSH_UTIL_CORE.g_RET_STS_UNEXP_ERROR;
     --
     IF l_debugOn THEN
       wsh_debug_sv.logmsg(l_moduleName, 'Unexpected error ' || SUBSTRB(SQLERRM,1,200));
       wsh_debug_sv.pop(l_moduleName);
     END IF;
     --
   WHEN OTHERS THEN
    --
    x_Status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    --
    wsh_util_core.default_handler('WSH_ROUTING_RESPONSE_PKG.UpdateTxnHistory');
    IF l_debugOn THEN
      wsh_debug_sv.logmsg(l_moduleName, 'Unexpected error ' || SUBSTRB(SQLERRM,1,200));
      wsh_debug_sv.pop(l_moduleName);
    END IF;
    --
    RAISE;
    --
END UpdateTxnHistory;


--
-- Pre-reqs     : None
--
-- Parameters
--      p_delivery_id - represents the delivery Id for which PO need to validate.
--      x_return_status  - Return status of this API.
--
-- Purpose    : This API is used to Validate an input delivery for
--              sending Routing Response. Api validates
--              1.PO is in correct Hold and Approval status. PO should not be in Hold and Unapproved.
--              2.Delivery has first leg.
--              3.None Carrier, Service level or Mode of transport for the trip associated with delivery is not null.
--              4.
--                Success: If trip load tender status in 'ACCEPTED','AUTO_ACCEPTED'.
--                Warning: If trip load tender status in 'OPEN','SHIPPER_CANCELLED',NULL and carrier is Auto tender enable.
--                Error: Else.
-- Version : 1.0
--
PROCEDURE ValidateDelivery(p_delivery_id   IN NUMBER,
			   x_return_status OUT NOCOPY VARCHAR2) IS
  --Cursor to find ,if first leg is created for a delivery.
  CURSOR validate_first_leg_csr(cp_delivery_id NUMBER) IS
  SELECT wts.trip_id,wnd.organization_id,wnd.shipping_control
  FROM   wsh_new_deliveries wnd,
     	 wsh_delivery_legs wdl,
     	 wsh_trip_stops wts
  WHERE wnd.delivery_id = p_delivery_id
  AND   wnd.delivery_id = wdl.delivery_id
  AND   wdl.pick_up_stop_id = wts.stop_id
  AND   wnd.initial_pickup_location_id = wts.stop_location_id;


  --Cursor to find,if carrier is auto load tender enable.
  CURSOR validate_auto_tender_csr(p_carrier_id NUMBER,p_organization_id NUMBER) IS
  SELECT  1
  FROM 	hz_relationships rel,
	wsh_carrier_sites wcs,
	hz_party_sites hps,
	hz_org_contacts hoc,
	hz_contact_points hcp,
	hz_contact_points hcp2,
	hz_parties party_rel,
	wsh_org_carrier_sites wocs
  WHERE wcs.carrier_site_id = hps.party_site_id
  AND hps.party_id = rel.object_id
  AND hps.party_site_id = hoc.party_site_id
  AND hoc.party_relationship_id = rel.relationship_id
  AND party_rel.party_id = rel.subject_id
  AND hcp.owner_table_id = rel.party_id
  AND hcp.contact_point_type = 'EMAIL'
  AND hcp.owner_table_name = 'HZ_PARTIES'
  AND wcs.carrier_id=  p_carrier_id
  AND hoc.decision_maker_flag = 'Y'
  AND hcp2.owner_table_id(+) = rel.party_id
  AND hcp2.contact_point_type(+) = 'PHONE'
  AND hcp2.owner_table_name(+)  = 'HZ_PARTIES'
  AND wcs.carrier_site_id = wocs.carrier_site_id
  AND wocs.organization_id = p_organization_id;

  --Cursor to get carrier,Mode of transport,Service level and load tender status for a trip.
  CURSOR validate_trip_csr(p_trip_id NUMBER) IS
  SELECT carrier_id,mode_of_transport,service_level, load_tender_status
  FROM wsh_trips
  WHERE trip_id = p_trip_id;
  --

  --Cursor to get carrier name.
  CURSOR get_carrier_name(p_carrier_id NUMBER) IS
   SELECT party_name
   FROM   wsh_carriers, hz_parties
   WHERE  carrier_id =party_id
   AND    carrier_id= p_carrier_id;
  --

  l_trip_id		number;
  l_organization_id	number;
  l_carrier_id		number;
  l_mode_of_transport	varchar2(30);
  l_service_level	varchar2(30);
  l_load_tender_status	varchar2(30);
  l_email_address	varchar2(2000);
  l_carrier_name	varchar2(2000);
  l_return_status	varchar2(1);
  l_tmp			number;
  l_shipping_control	varchar2(2000);
  --
  l_debugOn BOOLEAN;
  l_moduleName CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'ValidateDelivery';
  --
BEGIN
  --
  l_debugOn := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debugOn IS NULL THEN
    l_debugOn := wsh_debug_sv.is_debug_enabled;
  END IF;
  --
  IF l_debugOn THEN
    wsh_debug_sv.push(l_moduleName);
    wsh_debug_sv.log(l_moduleName,'p_delivery_id',p_delivery_id);
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  --

  --Validate PO is in correct Hold and Approval status. PO should not be in Hold and Unapproved.
  Validate_PO(
        p_delivery_id   => p_delivery_id,
        x_return_status => l_return_status);
  --
  IF l_debugOn THEN
    wsh_debug_sv.log(l_moduleName,'l_return_status',l_return_status);
  END IF;
  --
  IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
       raise fnd_api.g_exc_error;
  END IF;
  --

  --Determine,if delivery has fist leg.
  OPEN validate_first_leg_csr(p_delivery_id);
  FETCH validate_first_leg_csr INTO l_trip_id,l_organization_id,l_shipping_control;
  --
  IF l_debugOn THEN
    wsh_debug_sv.log(l_moduleName,'l_trip_id',l_trip_id);
    wsh_debug_sv.log(l_moduleName,'l_organization_id',l_organization_id);
    wsh_debug_sv.log(l_moduleName,'l_shipping_control',l_shipping_control);
  END IF;
  --


   --If delivery did not have first leg then error.
  IF (validate_first_leg_csr %NOTFOUND) THEN
    --
    FND_MESSAGE.SET_NAME('WSH', 'WSH_RR_NO_FIRST_LEG');
    WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR, l_moduleName);
    CLOSE validate_first_leg_csr;
    raise fnd_api.g_exc_error;
    --
  END IF;
  --
  CLOSE validate_first_leg_csr;
  --

  --If transportation is not arranged by Buyer than error.
  IF (nvl(l_shipping_control,'$$$') <> 'BUYER') THEN
     FND_MESSAGE.SET_NAME('WSH','WSH_RR_NO_BUYER_DEL');
     FND_MESSAGE.SET_TOKEN('DEL_NAME', WSH_NEW_DELIVERIES_PVT.Get_Name(p_delivery_id));
     fnd_msg_pub.add;

     raise FND_API.G_EXC_ERROR;
  END IF;


  --Get the Carrier,Mode of transport,Service level and load tendered status of a trip.
  OPEN validate_trip_csr(l_trip_id);
  FETCH validate_trip_csr INTO l_carrier_id,l_mode_of_transport,
			      l_service_level,l_load_tender_status;
  CLOSE validate_trip_csr;
  --
  IF l_debugOn THEN
       wsh_debug_sv.log(l_moduleName,'l_carrier_id',l_carrier_id);
       wsh_debug_sv.log(l_moduleName,'l_mode_of_transport',l_mode_of_transport);
       wsh_debug_sv.log(l_moduleName,'l_service_level',l_service_level);
       wsh_debug_sv.log(l_moduleName,'l_load_tender_status',l_load_tender_status);
  END IF;
  --

  --Error, if any one of carrier,mode of transport or service level is NULL.
  IF (l_carrier_id IS NULL OR l_mode_of_transport IS NULL OR l_service_level IS NULL) THEN
    --
    FND_MESSAGE.SET_NAME('WSH', 'WSH_RR_NO_CARRIER_SETUP');
    FND_MESSAGE.SET_TOKEN('DEL_NAME', WSH_NEW_DELIVERIES_PVT.Get_Name(p_delivery_id));
    WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR, l_moduleName);
    RAISE fnd_api.g_exc_error;
    --
  END IF;
  --
  IF (l_load_tender_status IS NULL OR l_load_tender_status IN ('OPEN','SHIPPER_CANCELLED') ) THEN
   --
   --Find out if carrier acecpt auto tender.
   OPEN validate_auto_tender_csr(l_carrier_id,l_organization_id);
   FETCH validate_auto_tender_csr INTO l_tmp;
   --
   IF (validate_auto_tender_csr%FOUND) THEN
    --
    IF l_debugOn THEN
       wsh_debug_sv.logmsg(l_moduleName,'validate_auto_tender_csr FOUND');
    END IF;
    --

    --Warning if delivery is not tendered for carrier and accept auto tender.
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
    --
    OPEN get_carrier_name(l_carrier_id);
    FETCH get_carrier_name INTO l_carrier_name;
    CLOSE get_carrier_name;

    --Delivery DEL_NAME is not tendered for carrier CARRIER.
    FND_MESSAGE.SET_NAME('WSH', 'WSH_RR_NO_TENDER');
    FND_MESSAGE.SET_TOKEN('DEL_NAME', WSH_NEW_DELIVERIES_PVT.Get_Name(p_delivery_id));
    FND_MESSAGE.SET_TOKEN('CARRIER', l_carrier_name);
    WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_WARNING, l_moduleName);
   END IF;
   --
   CLOSE validate_auto_tender_csr;
   --
  ELSIF (l_load_tender_status IN ('ACCEPTED','AUTO_ACCEPTED')) THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  ELSE

     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR ;

    --Routing Response for delivery DEL_NAME
    --is waiting response from carrier CARRIER.
    OPEN get_carrier_name(l_carrier_id);
    FETCH get_carrier_name INTO l_carrier_name;
    CLOSE get_carrier_name;

    FND_MESSAGE.SET_NAME('WSH', 'WSH_RR_NO_TENDER_ACCEPT');
    FND_MESSAGE.SET_TOKEN('DEL_NAME', WSH_NEW_DELIVERIES_PVT.Get_Name(p_delivery_id));
    FND_MESSAGE.SET_TOKEN('CARRIER', l_carrier_name);
    WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_WARNING, l_moduleName);
  END IF;
  --
  IF l_debugOn THEN
    wsh_debug_sv.log(l_moduleName, 'Valid Delivery?', x_return_status);
    wsh_debug_sv.pop(l_moduleName);
  END IF;
  --
  EXCEPTION
   --
   WHEN FND_API.G_EXC_ERROR THEN
     --
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR ;
     --
     IF l_debugOn THEN
      wsh_debug_sv.logmsg(l_moduleName,'FND_API.G_EXC_ERROR exception has occured.',
			  wsh_debug_sv.C_EXCEP_LEVEL);
      wsh_debug_sv.pop(l_moduleName,'EXCEPTION:FND_API.G_EXC_ERROR');
     END IF;
     --
   WHEN OTHERS THEN
    --
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    --
    wsh_util_core.default_handler('WSH_ROUTING_RESPONSE_PKG.ValidateDelivery');
    IF l_debugOn THEN
      wsh_debug_sv.logmsg(l_moduleName,'Unexpected error '|| SQLERRM);
      wsh_debug_sv.pop(l_moduleName,'EXCEPTION:OTHERS');
    END IF;
    --
    RAISE;
    --
END ValidateDelivery;


--
-- Pre-reqs     : None
--
-- Parameters
--      p_delivery_id - represents the delivery Id for which PO need to validate.
--      x_return_status  - Return status of this API.
--
-- Purpose      : This API is used to validate PO status of corresponding input delivery.
--                Returns error if PO is in HOLD or Not Approved.
--
-- Version : 1.0
--
PROCEDURE Validate_PO(p_delivery_id       	IN      NUMBER,
        	      x_return_status         	OUT NOCOPY      VARCHAR2) IS

  --Cursor to get PO attributes
  CURSOR get_del_detail  IS
  SELECT source_header_id, source_line_id,
         po_shipment_line_id, source_blanket_reference_id
  FROM   wsh_delivery_details wdd,
  	 wsh_delivery_assignments_v wda
  WHERE  wda.delivery_id=p_delivery_id
  AND    wdd.delivery_detail_id = wda.delivery_detail_id
  AND    nvl(line_direction,'O') not in ('O','IO')
  AND    source_code='PO';
  --
  l_return_status		varchar2(1);
  l_delivery_status		varchar2(30);
  l_convert_qty			number;
  l_po_header_id		PO_TBL_NUMBER;
  l_sourceLineIds		PO_TBL_NUMBER;
  l_shpLineIds			PO_TBL_NUMBER;
  l_blkRefIds			PO_TBL_NUMBER;
  l_dummy_tbl_number 		po_tbl_number := po_tbl_number();
  l_dummy_tbl_varchar30 	po_tbl_varchar30 := po_tbl_varchar30();
  l_po_status_rec		PO_STATUS_REC_TYPE;
  --l_po_status_rec		STATUS_REC_TYPE;
  l_index			number;
  --
  l_debugOn BOOLEAN;
  l_moduleName CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Validate_PO';
  --
BEGIN
  --
  l_debugOn := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debugOn IS NULL THEN
    l_debugOn := wsh_debug_sv.is_debug_enabled;
  END IF;
  --
  IF l_debugOn THEN
    wsh_debug_sv.push(l_moduleName);
    wsh_debug_sv.log(l_moduleName,'p_delivery_id',p_delivery_id);
    wsh_debug_sv.log(l_moduleName,'Current_Release',PO_CODE_RELEASE_GRP.Current_Release);
    wsh_debug_sv.log(l_moduleName,'PRC_11i_Family_Pack_J',PO_CODE_RELEASE_GRP.PRC_11i_Family_Pack_J);
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  --Get the PO attributes of detail lines assign to delivery.
  OPEN get_del_detail;
  FETCH get_del_detail BULK COLLECT INTO
	l_po_header_id, l_sourceLineIds, l_shpLineIds, l_blkRefIds;
  --
  IF l_debugOn THEN
    wsh_debug_sv.log(l_moduleName,'Rec Count',get_del_detail%ROWCOUNT);
  END IF;
  --

  --No detail lines assign to delivery,error out.
  IF (l_po_header_id.count < 1) THEN
   --
   FND_MESSAGE.SET_NAME('WSH', 'WSH_DEL_NO_DETAILS');
   FND_MESSAGE.SET_TOKEN('DEL_NAME', WSH_NEW_DELIVERIES_PVT.Get_Name(p_delivery_id));
   WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR, l_moduleName);
   raise fnd_api.g_exc_error;
   --
  END IF;
  --
  CLOSE get_del_detail;
  --
  l_dummy_tbl_number.extend(l_po_header_id.count);
  l_dummy_tbl_varchar30.extend(l_po_header_id.count);
  --

  --PO release level should be PO_CODE_RELEASE_GRP.PRC_11i_Family_Pack_J or higher.
  IF (PO_CODE_RELEASE_GRP.Current_Release >= PO_CODE_RELEASE_GRP.PRC_11i_Family_Pack_J) THEN
    --{
    IF l_debugOn THEN
       wsh_debug_sv.logmsg(l_moduleName,'Before Calling PO_FTE_INTEGRATION_GRP.po_status_check');
    END IF;
    --
    PO_FTE_INTEGRATION_GRP.po_status_check (
     p_api_version           => 1,
     p_header_id             => l_po_header_id,
     p_line_id               => l_sourceLineIds,
     p_line_location_id	    => l_shpLineIds,
     p_release_id	    => l_blkRefIds,
     p_mode                  => 'GET_STATUS',
     p_document_type         => l_dummy_tbl_varchar30,
     p_document_subtype      => l_dummy_tbl_varchar30,
     p_document_num          => l_dummy_tbl_varchar30,
     p_vendor_order_num      => l_dummy_tbl_varchar30,
     p_distribution_id       => l_dummy_tbl_number,
     x_po_status_rec         => l_po_status_rec,
     x_return_status         => l_return_status);
    --
    IF l_debugOn THEN
       wsh_debug_sv.log(l_moduleName,'PO_FTE_INTEGRATION_GRP.po_status_check l_return_status',
			l_return_status);
       wsh_debug_sv.log(l_moduleName,'l_po_status_rec.approval_flag.count',
			l_po_status_rec.approval_flag.count);
    END IF;
    --
    IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
     --
     FND_MESSAGE.SET_NAME('WSH', 'WSH_RR_PO_INVALID');
     WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR, l_moduleName);
     raise fnd_api.g_exc_error;
     --
    END IF;
    --
    l_index:=l_po_status_rec.approval_flag.first;
    --
    WHILE (l_index IS NOT NULL) LOOP
     --
     IF l_debugOn THEN
       --
       wsh_debug_sv.log(l_moduleName,'approval_flag',l_po_status_rec.approval_flag(l_index));
       wsh_debug_sv.log(l_moduleName,'hold_flag',l_po_status_rec.hold_flag(l_index));
       --
     END IF;
     --

     --Error if PO is in Hold
     IF (l_po_status_rec.hold_flag(l_index) = 'Y') THEN
      --
      FND_MESSAGE.SET_NAME('WSH','WSH_RR_PO_ERROR_HOLD');
      WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR, l_moduleName);
      raise fnd_api.g_exc_error;
      --
     END IF;
     --
     --Error if PO is not Approved.
     IF (l_po_status_rec.approval_flag(l_index)<> 'Y' ) THEN
      --
      FND_MESSAGE.SET_NAME('WSH','WSH_RR_PO_ERROR_UNAPPROVED');
      WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR, l_moduleName);
      raise fnd_api.g_exc_error;
      --
     END IF;
     --
     l_index:=l_po_status_rec.approval_flag.next(l_index);
     --
    END LOOP;
    --}
  ELSE
    --
    IF l_debugOn THEN
      wsh_debug_sv.logmsg(l_moduleName,'Current Release is Not greater than J');
    END IF;
    --
    raise fnd_api.g_exc_error;
    --
  END IF;
  --
  IF l_debugOn THEN
    wsh_debug_sv.pop(l_moduleName);
  END IF;
  --
  EXCEPTION
   --
   WHEN FND_API.G_EXC_ERROR THEN
     --
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR ;
     --
     IF l_debugOn THEN
      wsh_debug_sv.logmsg(l_moduleName,'FND_API.G_EXC_ERROR exception has occured.',
			wsh_debug_sv.C_EXCEP_LEVEL);
      wsh_debug_sv.pop(l_moduleName,'EXCEPTION:FND_API.G_EXC_ERROR');
     END IF;
     --
   WHEN OTHERS THEN
     --
     x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
     --
     IF l_debugOn THEN
       wsh_debug_sv.logmsg(l_moduleName,'Unexpected error has occured. Oracle error message is '||
                                          SQLERRM,wsh_debug_sv.C_UNEXPEC_ERR_LEVEL);
       wsh_debug_sv.pop(l_moduleName,'EXCEPTION:OTHERS');
     END IF;
     --
     FND_MESSAGE.SET_NAME('WSH','WSH_UTIL_MESSAGE_U');
     FND_MESSAGE.SET_TOKEN('MSG_TEXT',sqlerrm);
     WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR, l_moduleName);
     --
END Validate_PO;


--
-- Pre-reqs	: None
--
-- Parameters
--	p_delId - represents the delivery Id for which the routing response
--		  is being generated.
--
-- Purpose	: This function is used to lock the delivery so that no
--		  other operation can be performed on it for the duration
--		  of the routing response process.
--
-- Version : 1.0
--
FUNCTION LockDelivery(p_deliveryId IN NUMBER) RETURN BOOLEAN IS
  --
  CURSOR c_Deliv IS
  SELECT *
  FROM wsh_new_deliveries
  WHERE delivery_id = p_deliveryId
  FOR UPDATE NOWAIT;
  --
  l_debugOn BOOLEAN;
  l_moduleName CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LockDelivery';
  --
BEGIN
  --
  l_debugOn := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debugOn IS NULL THEN
    l_debugOn := wsh_debug_sv.is_debug_enabled;
  END IF;
  --
  IF l_debugOn THEN
    wsh_debug_sv.push(l_moduleName);
    wsh_debug_sv.log(l_moduleName,'p_deliveryId',p_deliveryId);
  END IF;
  --
  OPEN c_Deliv;
  CLOSE c_Deliv;
  --
  IF l_debugOn THEN
    wsh_debug_sv.logmsg(l_moduleName, 'Returning True');
    wsh_debug_sv.pop(l_moduleName);
  END IF;
  --
  RETURN(TRUE);
  --
  EXCEPTION
    --
    WHEN APP_EXCEPTION.RECORD_LOCK_EXCEPTION THEN
      --
      IF l_debugOn THEN
        wsh_debug_sv.logmsg(l_moduleName, 'Could not lock delivery');
        wsh_debug_sv.pop(l_moduleName);
      END IF;
      --
      RETURN(FALSE);
      --
END LockDelivery;


--
-- Pre-reqs	: None
--
-- Parameters
--	itemtype - represents the WF item type.  Here it is FTERRESP
--	itemKey  - identifies the unique item Key.  Here it is the transaction_id
--		   from wsh_inbound_txn_history
--	actid    - Standard WF attribute to represent the activity ID inside the process
--	funcmode - Standard WF attribute representing the fuction execution mode.
--	resultout - Standard WF attribute that represents the return status of this API
--
-- Purpose	: This is a selector/callback function to initialize data for each
--		  routing response process instance.  In particular, this procedure
--		  set the apps context for the WF item type. It can be used in the foll.
--		  modes - TEST_CTX, SET_CTX and RUN.
--
-- Version : 1.0
--
PROCEDURE FTERRESP_SELECTOR(itemType       IN      VARCHAR2,
                           itemKey        IN      VARCHAR2,
                           actid          IN      NUMBER,
                           funcmode       IN      VARCHAR2,
                           resultout      IN OUT NOCOPY   VARCHAR2) IS
  --
  l_userId       	NUMBER;
  l_respId       	NUMBER;
  l_respAppId  		NUMBER;
  l_orgId        	NUMBER;
  l_currentOrgId      	NUMBER;
  l_clientOrgId 	NUMBER;
  v_Fname		VARCHAR2(32767);
  v_MsgCnt      	NUMBER;
  v_Msg         	VARCHAR2(32767);
  v_Sts          	VARCHAR2(32767);
  --
  l_debugOn 		BOOLEAN;
  l_moduleName CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'FTERRESP_SELECTOR';
  --
BEGIN
  --
  l_debugOn := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debugOn IS NULL THEN
    l_debugOn := wsh_debug_sv.is_debug_enabled;
  END IF;
  --
  --wsh_debug_sv.start_debugger(v_Fname, v_Sts, v_MsgCnt, v_Msg);
  --
  IF l_debugOn THEN
    wsh_debug_sv.push(l_moduleName, 'FTERRESP_SELECTOR');
    wsh_debug_sv.log(l_moduleName, 'Item Type', itemtype);
    wsh_debug_sv.log(l_moduleName, 'ItemKey', itemKey);
    wsh_debug_sv.log(l_moduleName, 'Funcmode', funcmode);
  END IF;
  --
  IF(funcmode = 'RUN') THEN
    --
    resultout := 'COMPLETE';
    --
  ELSIF(funcmode = 'SET_CTX') THEN
    --{
    l_userId    := wf_engine.GetItemAttrNumber('FTERRESP',itemKey,'USER_ID');
    l_respAppId := wf_engine.GetItemAttrNumber('FTERRESP',itemKey, 'APPLICATION_ID');
    l_respId    := wf_engine.GetItemAttrNumber('FTERRESP',itemKey,'RESPONSIBILITY_ID');
    --
    IF(l_respAppId IS NULL OR l_respId IS NULL) THEN
      RAISE no_data_found;
    ELSE
      FND_GLOBAL.Apps_Initialize(l_userId, l_respId, l_respAppId);
    END IF;
    --
    resultout := 'COMPLETE';
    --}
  ELSIF(funcmode = 'TEST_CTX') THEN
    --
    l_orgId :=  wf_engine.GetItemAttrNumber( 'FTERRESP', itemKey, 'ORG_ID');
    --
    IF l_debugOn THEN
      wsh_debug_sv.log(l_moduleName, 'l_orgId', l_orgId);
    END IF;
    --
    IF l_orgId IS NULL THEN
      resultout := 'TRUE';
    ELSE
      --
      l_currentOrgId := TO_NUMBER(FND_PROFILE.VALUE('ORG_ID'));
      --
      IF l_debugOn THEN
        wsh_debug_sv.log (l_moduleName, 'l_currentOrgId', l_currentOrgId);
      END IF;
      --
      IF l_currentOrgId IS NOT NULL THEN
        --{
        IF l_orgId <> l_currentOrgId THEN
          resultout := 'FALSE';
        ELSE
         --{
         SELECT NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1), ' ',
		    NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)
         INTO l_clientOrgId FROM DUAL;
         --
         IF l_debugOn THEN
            wsh_debug_sv.log (l_moduleName, 'l_clientOrgId',l_clientOrgId);
         END IF;
         --
         IF l_clientOrgId = l_orgId THEN
            resultout := 'TRUE';
         ELSE
          --{
          IF l_debugOn THEN
             wsh_debug_sv.logmsg(l_moduleName, 'SELECTOR: PROFILE ORG = WF ORG');
	     wsh_debug_sv.logmsg(l_moduleName, 'BUT CLIENT ORG <> WF ORG');
          END IF;
          --
          resultout := 'FALSE';
          --}
         END IF;
         --}
        END IF;
        --}
      ELSE
        resultout := 'FALSE';
      END IF;
      --
   END IF;
   --
  END IF;
  --
  IF l_debugOn THEN
    wsh_debug_sv.log (l_moduleName, 'resultout', resultout);
    wsh_debug_sv.pop(l_moduleName);
  END IF;
  --
  wsh_debug_sv.stop_debug;
  --
  EXCEPTION
    --
    WHEN OTHERS THEN
      --
      resultout := 'COMPLETE:FAILURE';
      --
      IF l_debugOn THEN
         wsh_debug_sv.logmsg(l_moduleName,'Unexpected error '|| SQLERRM);
         wsh_debug_sv.pop(l_moduleName,'EXCEPTION:OTHERS');
      END IF;
      --
      wsh_debug_sv.stop_debug;
      --
      RAISE;
      --
END FTERRESP_SELECTOR;


--
-- Pre-reqs	: None
--
-- Parameters
--	p_routRespNum - Routing response number
--	x_Changed     - Indicates whether the delivery attribs have changed
--		        since the routing response was generated.
--
-- Purpose	: This procedure is called from the iSP routing response details
--		  page to determine whether any delivery characteristics have
--		  changed since the time the routing response was generated.
--		  This API calls the PO integration group API that checks the
--		  last_update_date on all the tables related to the routing
--		  response and if any of the dates is greater than the
--		  last_update_date from WSH_INBOUND_TXN_HISTORY, this API
--		  returns Y, else it returns N.
--
-- Version : 1.0
--
PROCEDURE CheckDeliveryInfo(p_routRespNum	IN	VARCHAR2,
			    x_changed		OUT NOCOPY VARCHAR2) IS
  --
  l_debugOn     BOOLEAN;
  l_moduleName  CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.GenerateRoutingResponse';
  --
  v_InRec       WSH_PO_INTG_TYPES_GRP.delInfo_in_recType;
  v_OutRec      WSH_PO_INTG_TYPES_GRP.delInfo_out_recType;
  v_Status      VARCHAR2(1);
  v_msgData     VARCHAR2(2000);
  v_msgCount    NUMBER;
  l_numErrors	NUMBER := 0;
  l_numWarnings NUMBER := 0;
  --
BEGIN
  --
  l_debugOn := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debugOn IS NULL THEN
     l_debugOn := wsh_debug_sv.is_debug_enabled;
  END IF;
  --
  IF l_debugOn THEN
    wsh_debug_sv.push(l_moduleName);
    wsh_debug_sv.log(l_moduleName, 'Routing Response Number', p_routRespNum);
  END IF;
  --
  v_InRec.routingRespNum := p_routRespNum;
  --
  -- Call PO Integration group API
  --
  WSH_PO_INTEGRATION_GRP.HasDeliveryInfoChanged(
        p_api_version_number    => 1.0,
        p_init_msg_list         => FND_API.G_TRUE,
        p_commit                => FND_API.G_FALSE,
        x_return_status         => v_Status,
        x_msg_Count             => v_msgCount,
        x_msg_data              => v_msgData,
        p_in_rec                => v_InRec,
        x_out_rec               => v_OutRec);
  --
  wsh_util_core.api_post_call(p_return_status => v_Status,
			      x_num_warnings  => l_numWarnings,
			      x_num_errors    => l_numErrors);
  --
  IF v_OutRec.hasChanged THEN
    x_changed := 'Y'; /* has changed */
  ELSE
    x_changed := 'N'; /* no change */
  END IF;
  --
  IF l_debugOn THEN
    wsh_debug_sv.log(l_moduleName, 'Changed', x_changed);
    wsh_debug_sv.pop(l_moduleName);
  END IF;
  --
END CheckDeliveryInfo;


END WSH_ROUTING_RESPONSE_PKG;

/
